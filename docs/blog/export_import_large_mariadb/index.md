---
title: mariadb - export import large database
date: "2023-05-15"
tags:
  - mariadb
  - export-import
  - large-database
aliases:
  - mariadb-export-import-large-database
---

how to speed up for import and export large databse

<!--more-->

## check table size

```sql
SELECT table_name,
  round((data_length / 1024 / 1024 ), 2) AS table_data_size_mb,
  round((data_length / 1024 / 1024 / 1024), 2) AS table_data_size_gb,
  round((index_length / 1024 / 1024 ), 2) AS table_index_size_mb,
  round((index_length / 1024 / 1024 / 1024), 2) AS table_index_size_gb
FROM information_schema.tables
WHERE table_schema = 'my_schema'
ORDER BY data_length DESC
```

## install mariadb-dump (Ubuntu)

```bash
# ref doc: https://mariadb.com/docs/skysql-previous-release/data-operations/backup-restore/manual-backup/#Installation
sudo apt install wget
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
echo "ad125f01bada12a1ba2f9986a21c59d2cccbe8d584e7f55079ecbeb7f43a4da4 mariadb_repo_setup" | sha256sum -c -
chmod +x mariadb_repo_setup
sudo ./mariadb_repo_setup --mariadb-server-version="mariadb-10.6"
sudo apt update
sudo apt install mariadb-client
```

## export

```bash
# ref doc: https://mariadb.com/kb/en/mariadb-dumpmysqldump/
mariadb-dump --host "my-mariadb-host" --port 3306 --password --user my_db_user \
--insert-ignore=TRUE --skip-lock-tables=TRUE --skip-add-locks=TRUE --skip-add-drop-table=TRUE \
--events --routines \
--net-buffer-length=16777216 \
--max_allowed_packet=128M \
--log-error='~/mariadb-dump/error.log' \
--ssl --ssl-verify-server-cert --ssl-ca "~/mariadb-dump/ca.pem" \
my_db | gzip > ~/mariadb-dump/my_db.gz
```

- if want to avoid some super large table, use option `--ignore-table=my_super_large_table`
- to filter record in table, use option `--where "id > 10000"` and add table names after db name like `my_db my_table_one | gzip > ~/mariadb-dump/my_db.gz`

## split large to small file, easier to transfer

```bash
cd ~/mariadb-dump/
split --numeric-suffixes --bytes=500MB my_db.gz my_db.gz.part.
```

## Combine splited files

```bash
cat my_db.gz.part.* > my_db.gz
```

## perpare server config for large insert

ref doc: https://mariadb.com/kb/en/how-to-quickly-insert-data-into-mariadb/  
perpare config file for large import

```toml
# mariadb_large_import_server.cnf
[mariadb]
innodb_autoinc_lock_mode=2
innodb_buffer_pool_size=1073741824
key_buffer_size=1073741824
max_allowed_packet=134217728
```

## start mariadb with config file

```bash
mariadbd --defaults-extra-file='mariadb_large_import_server.cnf'
```

OR

```yaml
# https://hub.docker.com/_/mariadb
version: "2"
services:
  mariadb:
    container_name: mariadb
    image: mariadb:10.6
    restart: always
    volumes:
      - /mnt/mariadb/data/:/var/lib/mysql
      - /mnt/mariadb/mariadb_large_import_server.cnf:/etc/mysql/conf.d/mariadb_large_import_server.cnf
    ports:
      - "3306:3306"
    network_mode: host
```

## perpare client config for large insert

ref doc:
https://mariadb.com/kb/en/mysqld-options/
https://mariadb.com/kb/en/configuring-mariadb-with-option-files/

```toml
# mariadb_large_import_client.cnf
[client]
unique_checks=0
foreign_key_checks=0
```

## import

```bash
gunzip < my_db.gz | mariadb  --host "my-mariadb-host" --port 3306 --password --user my_db_user \
--defaults-extra-file /mnt/mariadb/mariadb_large_import_client.cnf --force
```
