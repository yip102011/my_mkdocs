---
title: install signel-node k3s
date: 2025-01-01
tags:
  - kubernetes
  - k3s
slug: install-signel-node-k3s
---

# install signel-node k3s

## versions

- Linux: Ubuntu 24.04.1 LTS
- k3s: v1.30.5

## System Minimum Recommended

- CPU 1 core
- RAM 512 MB

## install k3s

```bash
# disable firewall
sudo ufw disable

# run install script
sudo curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode=600 --disable=traefik --disable-helm-controller

# copy kubeconfig file to user folder
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
sudo chmod 600 ~/.kube/config

# check if node reday
kubectl get node
```

## install helm

I don't like to use Helm Controller from k3s so i also install helm

```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## reference document

[K3S Quick-Start Guide](https://docs.k3s.io/quick-start)
[K3S server cli options](https://docs.k3s.io/cli/server)
