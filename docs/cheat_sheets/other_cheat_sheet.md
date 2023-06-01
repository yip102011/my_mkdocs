---
title: Other Cheat Sheet
date: "2022-10-10"
tags:
  - cheat-sheet
aliases:
  - my-other-cheat-sheet
---

My other cheat Sheet

<!--more-->

## Docker

```bash
# remove image
docker image rm my-reg/my-image:latest

# remove image with filter
docker image rm $(docker images --filter=reference='my-reg/*' --format "{{.Repository}}:{{.Tag}}")

# add new tag
docker tag "my-reg/my-image:latest" "my-reg/my-image:new-tag"

# docker save image as file
docker save -o "my-image.tar" "my-reg/my-image:latest"

# docker load image file
docker load --input "my-image.tar"

# rm all image that is not latest tag
docker image rm $(docker images | awk 'NR!=1 && $2 !~ /<none>/ && $2 !~ /^latest$)/ {print $1":"$2}')
```

## mongodb

```bash
# backup database to file
mongodump --uri="mongodb://admin:XXXXXW@192.168.0.101:10001,192.168.0.102:10002,192.168.0.103:10003/?authSource=admin&replicaSet=my_replica_set&readPreference=primary" --out=mongodump/ --db=my_db

# restore database from file
mongorestore --uri="mongodb://admin:XXXXXW@192.168.0.101:10001,192.168.0.102:10002,192.168.0.103:10003/?authSource=admin&replicaSet=my_replica_set&readPreference=primary" --db=my_db mongodump/my_db
```

## minio-client

```bash
# create config file
mkdir -p $HOME/.mc/
tee $HOME/.mc/config.json <<EOF
{
  "version": "10",
  "aliases": {
    "myminio": {
      "url": "http://192.168.0.100:9000",
      "accessKey": "xxxxxxxxxxxxxxxx",
      "secretKey": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "api": "s3v4",
      "path": "auto"
    }
  }
}
EOF

# upload files in /minio-tmp/* to minio server
docker run --rm -it --entrypoint='' \
-v /minio-tmp/:/minio-tmp/ \
-v $HOME/.mc/config.json:$HOME/.mc/config.json \
minio/mc \
sh -c 'mc cp /minio-tmp/* myminio/my-bucket'

# delete files older than 7 days in minio server
docker run --rm -it --entrypoint='' \
-v $HOME/.mc/config.json:$HOME/.mc/config.json \
minio/mc \
sh -c 'mc find myminio/my-bucket --older-than 7d --exec 'mc rm {}''

```

## jasper report

```bash
# export
JASPER_INSTALLED_PATH=/mnt/jasper/
cd /${JASPER_INSTALLED_PATH}/buildomatic/
./js-export.sh --everything --keyalias deprecatedImportExportEncSecret --output-zip /mnt/jasper_backup/jasper_full_backup_$(date +'%Y%m%d_%H%M').zip

# crontab for backup every day and keep 7 days
0 5 * * * find /mnt/jasper_backup/ -mtime +1 -name "jasper_full_backup_*.zip" -delete && cd $JASPER_INSTALLED_PATH/buildomatic/ && ./js-export.sh --everything --keyalias deprecatedImportExportEncSecret --output-zip /mnt/jasper_backup/jasper_full_backup_$(date +'%Y%m%d_%H%M').zip
```

## tls renew ca cert

```bash
# generate csr using public key and cert info from `root_ca.crt`
openssl x509 -x509toreq -in root_ca.crt -signkey root_ca.key -out new_root_ca.csr

# sign new csr file with old private key and set expire date
openssl x509 -req -days 36500 -in new_root_ca.csr -signkey root_ca.key -out new_root_ca.crt
```

## tls cert verify

```bash
# verify cert and key are match
KEY_MD5=$(openssl rsa -noout -modulus -in root_ca.key | openssl md5 | cut -c 10-)
CERT_MD5=$(openssl x509 -noout -modulus -in new_root_ca.crt | openssl md5 | cut -c 10-)
if [ "$KEY_MD5" = "$CERT_MD5" ]; then echo "match"; else echo "not match"; fi

# verify server cert is issuer by ca
openssl verify -CAfile ca.crt -verbose server.crt
```
