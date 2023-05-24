# apache pulsar cheat sheet

## create namespace

```bash
bin/pulsar-admin namespaces create my_tenant/my_namespace
```

## create partitioned topic

```bash
bin/pulsar-admin topics create-partitioned-topic -p 6 persistent://my_tenant/my_namespace/my_topic
```

## delete topic

```bash
bin/pulsar-admin topics delete-partitioned-topic --force persistent://my_tenant/my_namespace/my_topic
bin/pulsar-admin topics delete --force persistent://my_tenant/my_namespace/my_topic

# delete all non-partitioned topics
for one_topic in $(bin/pulsar-admin topics list "my_tenant/my_namespace"); do bin/pulsar-admin topics delete --force "$one_topic"; done
# delete all partitioned topic
for one_topic in $(bin/pulsar-admin topics list-partitioned-topics "my-tenant/my-namespace"); do bin/pulsar-admin topics delete-partitioned-topics --force "$one_topic"; done

```

## list topic

```bash
bin/pulsar-admin topics list-partitioned-topics "my_tenant/my_namespace"
```

## clear backlog

```bash
# clear for my_subscription under my_namespace in all topics
bin/pulsar-admin namespaces clear-backlog "my_tenant/my_namespace" --force -s "my_subscription"

# clear for topic
bin/pulsar-admin topics clear-backlog "persistent://my_tenant/my_namespace/my_topic" --subscription "my_subscription";

# loop all partitioned-topics in namespace and clear-backlog
for one_topic in $(bin/pulsar-admin topics list-partitioned-topics "my_tenant/my_namespace");
    do (
        for one_sub in $(bin/pulsar-admin topics subscriptions "$one_topic");
            do bin/pulsar-admin topics clear-backlog $one_topic --subscription $one_sub; echo "$one_topic : $one_sub";
        done
        );
done
```

## test send message

```bash
bin/pulsar-client produce my_tenant/my_namespace/my_topic  -m "---------this is my message-------"
```

## skip message

```bash
bin/pulsar-admin topics skip --count 1 --subscription my_subscription "persistent://my_tenant/my_namespace/my_topic"

# skip all message in all non-partitioned topic in namespace
for one_topic in $(bin/pulsar-admin topics list "my_tenant/my_namespace");
    do (
        for one_sub in $(bin/pulsar-admin topics subscriptions "$one_topic");
            do bin/pulsar-admin topics skip --count 9999999 --subscription $one_sub $one_topic; echo "$one_topic : $one_sub";
        done
        );
done
```

## check broker

```bash
bin/pulsar-admin brokers get-runtime-config
bin/pulsar-admin brokers healthcheck
bin/pulsar-admin broker-stats monitoring-metrics -i
bin/pulsar-admin broker-stats topics -i
```

## check bookie

```bash
curl http://localhost:8000/metrics | grep bookie
```

## check topic

```bash
bin/pulsar admin persistent stats-internal "persistent://my_tenant/my_namespace/my_topic"
```

## delpoy pulsar manager UI

```bash
pulsar_broker_url=http://localhost:7750
docker pull apachepulsar/pulsar-manager:v0.3.0
docker run -it -d \
 -p 9527:9527 -p 7750:7750 \
 -e SPRING_CONFIGURATION_FILE=/mnt/pulsar/application.properties \
 apachepulsar/pulsar-manager:v0.3.0

CSRF_TOKEN=$(curl $pulsar_broker_url/pulsar-manager/csrf-token)
curl \
    -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
    -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
 -H 'Content-Type: application/json' \
 -X PUT $pulsar_broker_url/pulsar-manager/users/superuser \
 -d '{"name": "pulsar", "password": "pulsar", "description": "pulsar", "email": "pulsar@my_domain.com"}'
```

## kubectl go in pulsar

```bash
kubectl exec -i -t -n pulsar pulsar-broker-0 -c pulsar-broker -- sh -c "clear; (bash || ash || sh)"
```
