---
date: 2024-10-10
tags:
  - linux
slug: init-ubuntu
---
# Init Ubuntu

This document is to record those comment stuff that i do to setup Ubuntu.

<!-- more -->

## versions

|                | Version                           |
| -------------- | --------------------------------- |
| OS             | Ubuntu 24.04.1 LTS (Noble Numbat) |
| Docker         | 27.3.1                            |
| Docker Compose | 2.29.7                            |

## allow user sudo without password

```bash
echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USER}
```

## config system ntp time

```bash
# get available timezone list
# timedatectl list-timezones

# set timezone
timedatectl set-timezone "Asia/Hong_Kong"

# set NTP source,
# man page https://manpages.ubuntu.com/manpages/bionic/man5/timesyncd.conf.5.html
sudo mkdir /etc/systemd/timesyncd.conf.d
sudo tee /etc/systemd/timesyncd.conf.d/hk_ntp.conf << EOF
[Time]
NTP=stdtime.gov.hk
FallbackNTP=stdtime.gov.hk
EOF
sudo systemctl restart systemd-timesyncd
sudo systemctl status systemd-timesyncd | grep Status
```

## install docker

```bash
# Uninstall old versions
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
ARCH=$(dpkg --print-architecture)
UBUNTU_CODE=$(. /etc/os-release && echo "$VERSION_CODENAME")
echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODE} stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# config docker daemon
# https://docs.docker.com/reference/cli/dockerd/#daemon-configuration-file
```

### allow docker command without sudo

```bash
# create linux user group name docker
sudo groupadd docker
# add user to group
sudo usermod -aG docker $USER
# refresh user group
newgrp docker
# test
docker run hello-world
```

### set docker root dir

```bash
# set docker data folder, log driver
sudo tee /etc/docker/daemon.json << EOF
{
  "data-root": "/data/docker-data",
  "log-driver": "local",
  "log-opts": {
    "max-size": "20m",
    "max-file": "5"
  }
}
EOF
sudo systemctl restart docker.service
```

### set docker private registry

if private registry is HTTP without TLS, add host to `daemon.json` - `insecure-registry`

```json
{ "insecure-registries": ["192.168.0.100"] }
```

if private registry is using https with invalid or self-sign server cert, set ca cert
ref: https://docs.docker.com/engine/security/certificates/

```bash
REGISTRY_HOST=192.168.0.100:443
sudo mkdir -p "/etc/docker/certs.d/${REGISTRY_HOST}"
openssl s_client -connect ${REGISTRY_HOST} -showcerts </dev/null | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' > /etc/docker/certs.d/${REGISTRY_HOST}/ca.crt
```

## config logging file

```bash
# man page https://manpages.ubuntu.com/manpages/xenial/en/man8/logrotate.8.html
# TODO
```
