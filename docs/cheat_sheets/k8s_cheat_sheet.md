---
title: K8S Cheat Sheet
tags:
  - k8s
  - kubernetes
  - cheat-sheet
slug: k8s-cheat-sheet

---

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
```

### Kubernetes - create nodeport svc

```bash
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
```

### Kubernetes - Create kubeconfig file

```bash
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

## Helm chart

```yaml
# add checksum to auto update deployment yaml if config map is changed
annotations:
  checksum/configmap: { { include (print $.Template.BasePath "/configmap.yaml") . | sha256sum } }

# print yaml with nindent in every line
{{- toYaml .Values.resources | nindent 12 }}

# if else
{{- if .Values.enabled }}
{{- else }}
{{- end }}

# redefine root var in scrope
{{- with .Values.nodeSelector }}
      nodeSelector:
{{- toYaml . | nindent 8 }}
{{- end }}

# avoid null error
{{- if (.Values.pvc).enabled -}}{{- end -}}

# rename var
{{- $ingressPath := .Values.ingress.path -}}

# prefer deploy pod in diff node
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app: "{{ $name }}"
        topologyKey: "kubernetes.io/hostname"

# loop key value
{{- range $key, $value := .Values.config }}
{{- if and (ne $key "my_key") }}
  {{ $key }}: "{{ $value }}"
{{- end }}

# base64 encode for secret
{{ $value | b64enc }}

# default value
{{ $service.type | default "ClusterIP" }}
```

```yaml
# add config as json file or key value
{{- if .Values.config }}
kind: ConfigMap
apiVersion: v1
metadata:
  name: dotnet-config-cm
data:

{{- $config_json := .Values.config.config_json -}}
{{- if $config_json }}
  config.json: |
{{ $config_json | indent 4 }}
{{- end }}

{{- range $key, $value := .Values.config_key_value }}
  {{ $key }}: "{{ $value }}"
{{- end }}

{{- end }}
```

```yaml
# distribute pod into diff node
# pod.spec.
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: "{{ $app_name }}"
          topologyKey: "kubernetes.io/hostname"
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
