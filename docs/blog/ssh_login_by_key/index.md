---
title: SSH - 使用私錀登入
date: "2022-10-03"
tags:
  - ssh
  - linux
---

如何使用私錀登入 Linux

<!--more-->
# SSH - 使用私錀登入

1. 生成一對公鑰和私鑰

```bash
# works on linux and windows
ssh-keygen
ls ~/.ssh
```

預設生成在 ~/.ssh，id_rsa 是私鑰，id_rsa.pub 是公鑰

> id_rsa id_rsa.pub

2. 上傳公鑰到伺服器

```bash
# only for linux
ssh-copy-id username@remote_host
```

如果使用 windows，打開 cmd，使用 scp 上傳金鑰

```shell
# only for cmd
scp %USERPROFILE%/.ssh/id_rsa.pub isaac@192.168.0.100:~/tmpe_id_rsa.pub
ssh isaac@192.168.0.100 "mkdir -p ~/.ssh && cat ~/tmpe_id_rsa.pub >> ~/.ssh/authorized_keys && rm ~/tmpe_id_rsa.pub"
```

以上命令會把公鑰上傳到伺服器的檔案 `~/.ssh/authorized_keys`。

3.現在登入不用密碼了

```shell
ssh isaac@192.168.0.100
```
