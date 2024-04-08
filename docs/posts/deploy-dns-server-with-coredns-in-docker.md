---
title: Deploy DNS server with CoreDNS in Docker
date: 2023-04-08
tags:
  - dns
  - dns-server
  - coredns
  - docker
slug: deploy-dns-server-with-coredns-in-docker
---

Sometimes application require domain name to work properly but you don't want to by a public domain for it. This will show you how to build a simple dns server using coredns and docker.

<!-- more -->

## prepare config file

Below config using hosts plugin, resolve coredns-example.com as 192.168.0.1. if query domain is not `coredns-example.com`, forward to 8.8.8.8 and 8.8.4.4..

```bash
sudo tee /etc/coredns/Corefile <<EOF
. {
  hosts {
    192.168.0.1  coredns-example.com
    fallthrough
  }
  log
  forward . 8.8.8.8 8.8.4.4
}
EOF
```

## run coredns container

```bash
docker run -d --name=coredns --restart=always -v=/etc/coredns/:/etc/coredns/ -p=53:53/udp -p=53:53/tcp coredns/coredns -conf=/etc/coredns/Corefile
```

## test dns server

Here using docker desktop, so it using host name to connect the dns server.

```bash
dig @host.docker.internal isaac-coredns-example.com
```

```text
; <<>> DiG 9.18.18-0ubuntu0.22.04.2-Ubuntu <<>> @host.docker.internal coredns-example.com
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7788
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 8470e928982e45e2 (echoed)
;; QUESTION SECTION:
;coredns-example.com.           IN      A

;; ANSWER SECTION:
coredns-example.com.    3600    IN      A       192.168.0.1

;; Query time: 0 msec
;; SERVER: 192.168.210.176#53(host.docker.internal) (UDP)
;; WHEN: Mon Apr 08 12:59:24 HKT 2024
;; MSG SIZE  rcvd: 95
```

## ios issue with custom dns server

ios didn't not use dns server list as failover. It will randomly pick a dns server from list. you have to remove all other dns server for your custom dns record to work.
