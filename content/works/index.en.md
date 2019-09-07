---
title: "Works"
date: 2019-08-28T19:52:12+02:00
draft: false
---
Whenever possible, I try to make my projects Open-Source so others can collaborate and use the project as the wish. Most of my projects are therefor published on [Github](https://github.com/localleon)

Here are some of my *favorite* Projects:

<br>

## octoprint-exporter
Some of you may now [Ocotprint](https://octoprint.org/), the snappy web interface for your 3D printer. Octorpints lets you monitor and control your 3D-Printer remotely. I use a stack of [Grafana](https://grafana.com/) and [Prometheus](https://prometheus.io/) for local monitoring and wanted to integrate Octorprint into my Prometheus server. I had to write an [exporter](https://prometheus.io/docs/instrumenting/exporters/) to integrate the data from the Octoprint REST API into Prometheus.

- **Technologies:** Golang
- **Links:** https://github.com/localleon/octoprint-exporter

--- 

## barco-slm-network
This project was partly created out of necessity. After the remote control of a Barco SLM R6 Performer broke down, I needed a way to still continue using it. Because of its age, there weren't any cheap spare parts. Luckily this beamer had a somewhat documented RS232 Interface that one could use to control most of the functions. So a friend of mine and myself started working on an application that could control the beamer (shutter and stuff) by webinterface and sACN. 

- **Technologies:** Golang
- **Links:** https://github.com/localleon/barco-slm-network