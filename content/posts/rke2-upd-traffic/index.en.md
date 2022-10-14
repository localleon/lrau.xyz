---
title: RKE2 Cluster running Calico seemingly losing UDP traffic 
date: 2022-10-04
author: Leon R.
draft: false
toc: false
tags: ["rke2","kubernetes","networking","bug"]
---

We found interesting behavior where UDP DNS queries are unable to be resolved when transiting via the service IP for CoreDNS i.e. 10.43.0.10. If we directly addressed the coredns pod, we could make our DNS queries with no issue. It did not matter whether we were in or out of a pod, i.e. on the node or not.

Here's the setup: 

- RKE2 Version: v1.22.3-rc3+rke2r2
- RedHat Enterprise Linux 8.6, Kernel Version: 4.18.0-372.9.1
- Cluster Configuration: 3 server nodes. Also reproducible on 3 etcd, 1 controlplane, and 3 worker nodes

After installing the cluster, I noticed some strange behavior. The `kubectl` API was responding very slowly and the DNS-Containers in namespace `kube-system`. After trying to install longhorn, we observed that DNS-Resolution was not working properly in the cluster. 

```log
kube-system       rke2-coredns-rke2-coredns-6775f768c8-l5vzw                    1/1     Running     2 (4m11s ago)   22h
kube-system       rke2-coredns-rke2-coredns-6775f768c8-v7rh8                    1/1     Running     2 (4m58s ago)   22h
kube-system       rke2-coredns-rke2-coredns-autoscaler-7c77dcfb76-k59sb         1/1     Running     2 (4m58s ago)   22h
```

Resolving the DNS-Names of Services in the Cluster didn't work. You can use [this container](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/) from Google to debug DNS Issues.

```
[rke@test-cluster-1-mgt1 ~]$ kubectl exec -it -t dnsutils /bin/bash
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
root@dnsutils:/# nslookup longhorn-backend
Server:		10.43.0.10
Address:	10.43.0.10#53

** server can't find longhorn-backend: REFUSED

root@dnsutils:/# exit
root@dnsutils:/# ping 10.0.0.17
PING 10.0.0.17 (10.0.0.17) 56(84) bytes of data.
64 bytes from 10.0.0.17: icmp_seq=1 ttl=63 time=0.238 ms
64 bytes from 10.0.0.17: icmp_seq=2 ttl=63 time=0.379 ms
64 bytes from 10.0.0.17: icmp_seq=3 ttl=63 time=0.333 ms
```

Pings from the container to outside network seemed fine. Looking into the `coredns`-Container we see the following. 

```log
[rke@test-cluster-1-mgt1 ~]$ k logs rke2-coredns-rke2-coredns-6775f768c8-v7rh8 -n kube-system 
.:53
[ERROR] plugin/errors: 2 1753043861658997237.2789327144841871883. HINFO: read udp 10.42.2.34:47756->10.0.0.1:53: i/o timeout
[ERROR] plugin/errors: 2 1753043861658997237.2789327144841871883. HINFO: read udp 10.42.2.34:40407->10.0.0.2:53: i/o timeout
[ERROR] plugin/errors: 2 1753043861658997237.2789327144841871883. HINFO: read udp 10.42.2.34:38719->10.0.0.1:53: i/o timeout
[ERROR] plugin/errors: 2 1753043861658997237.2789327144841871883. HINFO: read udp 10.42.2.34:38836->10.0.0.2:53: i/o timeout
[ERROR] plugin/errors: 2 1753043861658997237.2789327144841871883. HINFO: read udp 10.42.2.34:51925->10.0.0.1:53: i/o timeout
[ERROR] plugin/errors: 2 1753043861658997237.2789327144841871883. HINFO: read udp 10.42.2.34:50221->10.0.0.2:53: i/o timeout
[ERROR] plugin/errors: 2 1753043861658997237.2789327144841871883. HINFO: read udp 10.42.2.34:41126->10.0.0.1:53: i/o timeout
```
The container can't reach our upstream dns server. Something is wrong with `canal` and the networking. 

## The Fix 

Apparently, the kernel driver miscalculates the checksum when the vxlan offloading is on if the packet is natted, which is our case when accessing the service via the ClusterIP. This was fixed [here](https://github.com/torvalds/linux/commit/ea64d8d6c675c0bb712689b13810301de9d8f77a)

You can manually try to `sudo ethtool -K vxlan.calico tx-checksum-ip-generic off` on all nodes. My cluster runs fine after this. 

Rancher writes in the [docs](https://docs.rke2.io/known_issues/#calico-with-vxlan-encapsulation): 

*Calico hits a kernel bug when using vxlan encapsulation and the checksum offloading of the vxlan interface is on. The issue is described in the calico project and in rke2 project. The workaround we are applying is disabling the checksum offloading by default by applying the value ChecksumOffloadBroken=true in the calico helm chart.* 

This automatic workaround from Rancher doesn't seem to work in RHEL 8.6. We need to persist the `ethtool` changes via NetworkManager. Here's an Ansible-Task to make the changes persistent. 

```yaml
--- files/etc/NetworkManager/dispatcher.d/ifup-vxlan
#!/bin/bash
if [ "$1" = "vxlan.calico" ] && [ "$2" = "up" ]; then
  /sbin/ethtool -K vxlan.calico tx-checksum-ip-generic off
  echo "vxlan.calcio disabled tx-checksum-ip-generic"
fi

--- 
- name: Create network service script to turn off tx-checksum-ip on vxlan.calcio
  template: 
    src: files/etc/NetworkManager/dispatcher.d/ifup-vxlan
    dest: /etc/NetworkManager/dispatcher.d/ifup-vxlan
    mode: 755
    owner: root
    group: root

- name: Enable NetworkManager-Dispatcher for Custom Network-Scripts 
  systemd: 
    name: NetworkManager-dispatcher
    state: enabled
```

That's it! 


## More Information 
Here are some links that helped me debunk the bug. 
- https://github.com/rancher/rke2/issues/1541
- https://docs.rke2.io/known_issues/#calico-with-vxlan-encapsulation
- https://github.com/projectcalico/calico/issues/3145#issuecomment-742845013