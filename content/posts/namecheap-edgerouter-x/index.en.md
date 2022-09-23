---
title: Configure Namecheap DnyDNS on Edgerouter-X
date: 2022-09-23
author: Leon
draft: false
toc: false
tags: networking, dns
---

In case anyone is still wondering how to set up Namecheap's DynDns service on an Ubiquiti Edgerouter-X. Here is a quick guide


## Configure via Web-Interface 

For more information on how to configure DynDns for your domain see [Namecheap - Enable DynDns](https://www.namecheap.com/support/knowledgebase/article.aspx/595/11/how-do-i-enable-dynamic-dns-for-a-domain/)

Navigate to Services > DNS > Dynamic DNS and configure the following Values: 

| Name      | My own Value                                  | Description                                              |
| --------- | --------------------------------------------- | -------------------------------------------------------- |
| Interface | ppoe1                                         | Your Router-Interface with your public ip                |
| Web       | https://dynamicdns.park-your-domain.com/getip | this is a public service of namecheap (DONT CHANGE)      |
| Web-Skip  |                                               | Leave it blank                                           |
| Service   | namecheap                                     | Select namecheap from dropdown                           |
| Hostname  | subdomain                                     | Your Dynamic-Dns Record Subdomain Entry                  |
| Login     | lrau.xyz                                      | Your Domain-Name                                         |
| Password  | NOT-GONNA-SHOW-YOU-THAT                       | Your Namecheap API Key. Find it on the namecheap website |
| Protocol  |                                               | Leave it blank                                           |
| Server    |                                               | Leave it blank                                           |

That's it! 

Namecheap operates `park-your-domain.com`, it's a simple way for DynDns-Clients to retreive your public IP. 

## CLI-Reference 

```
dynamic {
    interface null {
        service namecheap {
            host-name YOUR-SUBDOMAIN
            login YOUR-DOMAIN-NAME
            password ****************
            server /update?domain=YOUR-DOMAIN&password=YOUR-PASSWORT&host=
        }
        web dyndns
    }
}
```

## See also 
- https://help.ui.com/hc/en-us/articles/204976324
- https://www.namecheap.com/support/knowledgebase/article.aspx/9356/11/how-to-configure-a-ddwrt-router/