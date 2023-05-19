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

# 