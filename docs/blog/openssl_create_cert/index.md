---
title: OpenSSL - 使用 openssl 生成 TLS 憑證
date: "2022-05-01"
tags:
  - openssl
  - tls
aliases:
  - openssl-create-cert
---

如何使用 openssl 生成 TLS 需要的憑證

<!--more-->

# 使用 openssl 生成 TLS 憑證

## 生成自簽伺服器證書

```bash
openssl req -x509 -nodes -newkey rsa:2048 \
-subj='/CN=Self Sign Cert' \
-extensions usr_cert \
-addext "keyUsage           = nonRepudiation, digitalSignature, keyEncipherment" \
-addext "extendedKeyUsage   = serverAuth" \
-addext "subjectAltName     = DNS:www.server.com,DNS:localhost,IP:127.0.0.1" \
-out=crt.pem -keyout=key.pem
```

## 生成完整憑證鏈

### 生成自簽根憑證 Generate self sign root CA cert

```bash
# 生成私鑰
# generate private key
openssl genrsa -out=root_ca_key.pem 2048

# 用私鑰生成根憑證
# generate root cert from private key
openssl req -x509 -sha256 -new -days=10950 \
-subj='/CN=Root CA/C=HK/L=Hong Kong' \
-addext "keyUsage = critical, keyCertSign, cRLSign" \
-key=root_ca_key.pem -out=root_ca_crt.pem

# 生成流水號，每次簽發證書，流水號會加一
# create root ca serial number file, this will record how many cert this ca issued
openssl rand -hex -out=root_ca_srl.txt 20

# 檢查憑證訊息
# check cert info
openssl x509 -in root_ca_crt.pem -text
```

### 生成中間憑證 Issue intermediate CA cert

```bash
# 憑證配置
# cert config
tee inter_ca_ext.cnf <<EOF
[inter_ca_ext]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always,issuer
basicConstraints        = critical, CA:TRUE, pathlen:0
keyUsage                = critical, keyCertSign, cRLSign
EOF

# 生成私鑰
# generate private key
openssl genrsa -out=inter_ca_key.pem 2048

# 生成 CSR
# generate CSR (Certificate Signing Request)
openssl req -sha256 -new -subj='/CN=Intermediate CA/C=HK/L=Hong Kong' \
-key=inter_ca_key.pem -out=inter_ca_csr.pem

# 簽發中間憑證
# issue intermediate ca with root ca
openssl x509 -req -days=1095 -CAserial=root_ca_srl.txt \
-CA=root_ca_crt.pem -CAkey=root_ca_key.pem \
-extfile=inter_ca_ext.cnf -extensions=inter_ca_ext \
-in=inter_ca_csr.pem -out=inter_ca_crt.pem

# 生成流水號，每次簽發證書，流水號會加一
# create root ca serial number file, this will record how many cert this ca issued
openssl rand -hex -out=inter_ca_srl.txt 20

# 檢查憑證訊息
# check cert info
openssl x509 -in inter_ca_crt.pem -text
```

### 生成伺服器憑證 Generate Server Cert

```bash
# 憑證配置
# cert config
tee server_ext.cnf <<EOF
[server_ext]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
basicConstraints        = critical, CA:FALSE
keyUsage                = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage        = critical, serverAuth
subjectAltName          = @server_ext_san

[server_ext_san]
DNS.1 = nginx.test.isaac.com
DNS.2 = localhost
IP.1  = 127.0.0.1
EOF

# 生成私鑰
# generate private key
openssl genrsa -out=server_key.pem 2048

# 生成 CSR
openssl req -sha256 -new -subj "/CN=Server Cert/C=HK/L=Hong Kong" \
-key=server_key.pem -out=server_csr.pem

# 簽發伺服器憑證
# issue server cert with intermediate ca
openssl x509 -req -days=365 -CAserial=inter_ca_srl.txt \
-CA=inter_ca_crt.pem \-CAkey=inter_ca_key.pem \
-extfile=server_ext.cnf -extensions=server_ext \
-in=server_csr.pem -out=server_crt.pem

# 檢查憑證訊息
# check cert info
openssl x509 -in server_crt.pem -text
```

### 生成客戶端憑證 Generate Client Cert

```bash
# 憑證配置
# cert config
tee client_ext.cnf <<EOF
[client_ext]
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer
basicConstraints        = critical, CA:FALSE
keyUsage                = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage        = critical, clientAuth
EOF

# 生成私鑰
# generate private key
openssl genrsa -out=client_key.pem 2048

# 生成 CSR
openssl req -sha256 -new -subj "/CN=Client Cert/C=HK/L=Hong Kong" \
-key=client_key.pem -out=client_csr.pem

# 簽發客戶端憑證
# issue client cert with intermediate ca
openssl x509 -req -days=365 -CAserial=inter_ca_srl.txt \
-CA=inter_ca_crt.pem \-CAkey=inter_ca_key.pem \
-extfile=client_ext.cnf -extensions=client_ext \
-in=client_csr.pem -out=client_crt.pem

# 檢查憑證訊息
# check cert info
openssl x509 -in client_crt.pem -text
```

## 其他實用命令

### 下載伺服器憑證

```bash
echo -n | openssl s_client -connect www.google.com:443 | openssl x509 > google_crt.pem
```

### 下載憑證鏈

```bash
openssl s_client -showcerts -verify 5 -connect www.google.com:443 < /dev/null | awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/{ if(/BEGIN CERTIFICATE/){a++}; out="cert_chain.pem"; print >out}'
```

### 增加信任憑證

ubuntu

```bash
sudo apt-get install -y ca-certificates
sudo cp ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates
```

powershell

```powershell
Import-Certificate -FilePath "C:\crt.pem" -CertStoreLocation cert:\CurrentUser\Root
Import-Certificate -FilePath "C:\crt.pem" -CertStoreLocation Cert:\LocalMachine\Root
```

docker ubuntu container

```bash
docker run --rm -it \
-v=/my_certs/root_crt.pem:/etc/ssl/certs/root_crt.pem \
wbitt/network-multitool bash
```

### 加密/解密私鑰

```bash
# 生成 RSA 私鑰
openssl genrsa -out=rsa_key.pem 2048
# 將私鑰轉換 pkcs8 格式
openssl pkcs8 -topk8 -in rsa_key.pem     -out key.pem         -nocrypt
# 加密私鑰
openssl pkcs8 -topk8 -in key.pem         -out key_encrypt.pem
# 解密私鑰
openssl pkcs8 -topk8 -in key_encrypt.pem -out key_decrypt.pem
```

### 格式轉換

```bash
## 生成自簽證書
openssl req -x509 -nodes -newkey rsa:2048 -subj='/CN=Self Sign Cert' -out=crt.pem -keyout=key.pem

## PEM 轉 PFX
openssl pkcs12 -in=crt.pem -inkey=key.pem -export -out=crt.pfx
## PFX 轉 PEM
openssl pkcs12 -in=crt.pfx -out=crt_key.pem -nodes

## PEM 轉 DER
openssl x509 -outform der -in crt.pem -out crt.der
## DER 轉 PEM
openssl x509 -inform der  -in crt.der -out crt_from_der.pem

## PKCS#8 轉 PKCS#1
openssl rsa -in key.pem -out key_pkcs1.pem
```

## 參考資料

- <https://www.openssl.org/docs/man1.1.1/man1/>
- <https://www.openssl.org/docs/man1.1.1/man5/x509v3_config.html>
- <https://datatracker.ietf.org/doc/html/rfc5280>
- <https://en.wikipedia.org/wiki/PKCS>
