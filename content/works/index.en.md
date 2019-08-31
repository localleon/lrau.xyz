---
title: "Works"
date: 2019-08-28T19:52:12+02:00
draft: false
---
Whenever possible, I try to make my projects Open-Source so others can collaborate and use the project as the wish. Most of my projects are therefor published on [Github](https://github.com/localleon)

Here are some of my *favorite* Projects:

## octoprint-exporter
Some of you may now [Ocotprint](https://octoprint.org/), the snappy web interface for your 3D printer. Octorpints let's you monitor and control your 3D-Printer remotly. I use a stack of [Grafana](https://grafana.com/) and [Prometheus](https://prometheus.io/) for local monitoring and wanted to integrate Octorprint into my Prometheus server. I had to write an [exporter](https://prometheus.io/docs/instrumenting/exporters/) to integrate the data from the Octoprint REST API into Prometheus.

- **Technologies:** Golang
- **Links:** https://github.com/localleon/octoprint-exporter