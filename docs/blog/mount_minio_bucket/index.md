---
title: How to mount minio bucket as linux folder
date: "2023-02-22"
tags:
  - minio
  - s3fs
  - s3
aliases:
  - how-to-mount-minio-bucket-as-linux-folder
---

<!--more-->

# How to mount minio bucket as linux folder

1. install [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse)

   ```bash
   # install s3fs-fuse
   apt install s3fs
   s3fs --version
   ```

2. mounting minio bucket

   ```bash
   MINIO_HOST="http://192.168.64.131:9000"
   BUCKET_NAME="my-bucket"
   ACCESS_KEY_ID="dU2mOQuZqPbrTfIg"
   ACCESS_SECRET="3T7qxg6ztoxVX3YqTHJAU6O46FqzZJ4k"
   MOUNT_FOLDER="/mnt/minio-buckets/my-bucket"

   # "us-east-1" is minio default region
   ENDPOINT="us-east-1"

   # perpare password file
   echo ${ACCESS_KEY_ID}:${ACCESS_SECRET} > ${HOME}/.passwd-s3fs
   chmod 600 ${HOME}/.passwd-s3fs

   # ensure folder exists and empty
   sudo mkdir -p ${MOUNT_FOLDER}

   ## try to mount, this will unmount when you press Ctrl+C
   sudo s3fs ${BUCKET_NAME} ${MOUNT_FOLDER} \
     -o dbglevel=info -f -o curldbg \
     -o passwd_file=${HOME}/.passwd-s3fs \
     -o host=${MINIO_HOST} \
     -o endpoint=${ENDPOINT} \
     -o use_path_request_style \
     -o allow_other

   # if mount successful, press Ctrl+C to exit

   # backup fstab file
   mkdir -p ${HOME}/backup
   sudo cp /etc/fstab ${HOME}/backup/fstab

   # append to fstab
   echo "${BUCKET_NAME} ${MOUNT_FOLDER} fuse.s3fs _netdev,passwd_file=${HOME}/.passwd-s3fs,host=${MINIO_HOST},endpoint=${ENDPOINT},use_path_request_style,allow_other 0 0" | sudo tee --append /etc/fstab

   # check fstab
   sudo cat /etc/fstab

   # apply updated fstab
   sudo mount -a

   # check mount status
   sudo df -h | grep s3fs

   # clearup command hsitory in this session
   history -c
   ```

3. other useful command option

   - -o ssl_verify_hostname=0 (for https, disable hostname checking)
   - -o no_check_certificate (for https, disable ca checking, usful when cert is self signed)
   - -o connect_timeout=5
   - -o logfile=/mnt/minio-buckets/s3fs.log
   - -o passwd_file=/mnt/minio-buckets/.passwd-s3fs
   - -o curldbg=normal

4. unmount

   ```bash
   ## remove config in /etc/fstab
   sudo vim /etc/fstab
   ## unmount folder
   sudo umount "/mnt/minio-buckets/my-bucket"
   ```

## Ref Docs

- https://github.com/s3fs-fuse/s3fs-fuse
- https://aws.amazon.com/cn/blogs/china/s3fs-amazon-ec2-linux/
