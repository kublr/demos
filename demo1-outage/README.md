
## Demo 1.  Minor Outage

### Build

1.  Build randstr application

```
go build -o target/randstr randstr.go
```

2. Build docker images

```
docker build -t kublr/randstr:0.2.5 .
docker build -t kublr/randstr:latest .
```

3. Build helm package

```
(cd target && helm lint ../randstr && helm package ../randstr)
```

4. Run in kublr cluster

```
export KUBE_API_ENDPOINT=<kublr_cluster_api> # e.g. https://52.12.46.126
helm install --name demo --namespace default target/randstr-0.2.5.tgz
helm upgrade -i --namespace kube-system --set influxdb.enabled=false kublr-feature-monitoring https://repo.kublr.com/repository/helm/kublr-feature-monitoring-0.4.1.tgz
helm install --name monitoring --namespace monitoring -f kublr_demo1.yaml --set kubernetesApiEndpoint=$KUBE_API_ENDPOINT https://repo.kublr.com/repository/helm/app-monitoring-0.2.1.tgz
```