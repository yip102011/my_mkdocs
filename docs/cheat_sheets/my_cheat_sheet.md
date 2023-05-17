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

## Kubernetes

- [official cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubectl](https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl/)
- [go template url](https://pkg.go.dev/text/template#hdr-Text_and_spaces)

```bash
# kubectl exec one of deployment pod
kubectl exec -it deploy/my-app -n bes -- bash

# kubectl get all resource includeing custom resource
kubectl get $(kubectl api-resources --namespaced=true --no-headers -o name | grep -v -E 'events|bindings$|localsubjectaccessreviews' | paste -s -d, - )

# kubectl show pod cpu and memory config of first container
kubectl get pod -o custom-columns=POD_NAME:.metadata.name,CONTAINER:.spec.containers[0].name,CPU_MIN:.spec.containers[0].resources.limits.cpu,CPU_MAX:.spec.containers[0].resources.requests.cpu,MEM_MAX:.spec.containers[0].resources.limits.memory,MEM_MIN:.spec.containers[0].resources.requests.memory,STATUS:.status.phase

# kubectl list all nodeport
kubectl get svc --all-namespaces -o go-template='{{range .items}}{{ $svc := . }}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{","}}{{if .name}}{{printf "%-10s" .name}}{{else}}{{printf "%-10s" ""}}{{end}}{{","}}{{$svc.metadata.namespace}}{{","}}{{$svc.metadata.name}}{{"\n"}}{{end}}{{end}}{{end}}'

# create nodeport svc
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: my-svc
  namespace: default
spec:
  ports:
    - port: 80
      nodePort: 30002
  selector:
    app: my-app
  type: NodePort
EOF

# backup etcd data
sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt \
  --key=/etc/kubernetes/pki/apiserver-etcd-client.key \
  snapshot save ~/etcd_backup
  
# view container log
sudo docker logs -n 100 -f $(sudo docker ps -f name=k8s_kube-vip -q)
sudo docker logs -n 100 -f $(sudo docker ps -f name=k8s_etcd -q)
sudo docker logs -n 100 -f $(sudo docker ps -f name=k8s_kube-apiserver -q)
sudo docker logs -n 100 -f $(sudo docker ps -f name=k8s_kube-scheduler -q)
sudo docker logs -n 100 -f $(sudo docker ps -f name=k8s_kube-controller-manager -q)

# create kubeconfig file
NAMESPACE=default
USER_NAME=my-user

USER_TOKEN_NAME=$(kubectl get serviceaccount ${USER_NAME} -n ${NAMESPACE} -o=jsonpath='{.secrets[0].name}')
USER_TOKEN_VALUE=$(kubectl get secret/${USER_TOKEN_NAME} -n ${NAMESPACE} -o=go-template='{{.data.token}}' | base64 --decode)
CURRENT_CONTEXT=$(kubectl config current-context)
CURRENT_CLUSTER=$(kubectl config view --raw -o=go-template='{{range .contexts}}{{if eq .name "'''${CURRENT_CONTEXT}'''"}}{{ index .context "cluster" }}{{end}}{{end}}')
CLUSTER_CA=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}"{{with index .cluster "certificate-authority-data" }}{{.}}{{end}}"{{ end }}{{ end }}')
CLUSTER_SERVER=$(kubectl config view --raw -o=go-template='{{range .clusters}}{{if eq .name "'''${CURRENT_CLUSTER}'''"}}{{ .cluster.server }}{{end}}{{ end }}')

sudo tee ${USER_NAME}.kubeconfig <<EOF
apiVersion: v1
kind: Config
current-context: ${CURRENT_CONTEXT}
contexts:
- name: ${CURRENT_CONTEXT}
  context:
    cluster: ${CURRENT_CONTEXT}
    user: ${USER_NAME}
    namespace: ${NAMESPACE}
clusters:
- name: ${CURRENT_CONTEXT}
  cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_SERVER}
users:
- name: ${USER_NAME}
  user:
    token: ${USER_TOKEN_VALUE}
EOF

kubectl get pods -n ${NAMESPACE} --kubeconfig=${USER_NAME}.kubeconfig
```

## Helm

```bash
# download helm chart
helm pull bitnami/redis --untar --untardir ./redis-helm-charts

# render helm template
helm template my-redis bitnami/redis --output-dir=./otuput-dir --dry-run -f="my-values.yaml"

# ls installed app
helm ls -A

# get installed values
helm get values my-redis -n redis
```

## ArgoCD

Ref: https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd/

```bash
# get init admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# create container
docker run --rm -it argoproj/argocd

# login
argocd login "192.168.0.1" --insecure --username "isaac" --password "xxxxxx"

# restart deployment
argocd app actions run "my-app" restart --kind Deployment

# update password
argocd account update-password --account admin

# set app param
kubectl patch Application --type=merge -n=argocd -p '{"spec":{"source":{"helm":{"parameters":[{"name":"replicaCount","value":"0"}]}}}}' my-app

# set app param2
kubectl exec deploy/argocd-server -n argocd -- bash -c "argocd login 127.0.0.1:8080 --insecure --username admin --password 'XXXXXX'"
kubectl exec deploy/argocd-server -n argocd -- bash -c "argocd app set my-app -p replicaCount=0"
```

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