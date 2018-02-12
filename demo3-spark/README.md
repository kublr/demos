
# Demo 3 - Machine Learning using Spark


## Install monitoring tools 

```
helm upgrade -i kublr-feature-logging --namespace kube-system https://repo.kublr.com/repository/helm/kublr-feature-logging-0.4.5.tgz
helm upgrade -i kublr-feature-monitoring --namespace kube-system --set influxdb.enabled=false https://repo.kublr.com/repository/helm/kublr-feature-monitoring-0.4.1.tgz
helm upgrade -i monitoring --namespace monitoring --set kubernetesApiEndpoint=<clusterApiEndpoint> https://repo.kublr.com/repository/helm/app-monitoring-0.2.3.tgz
```

## Install spark

```
helm lint spark
helm upgrade -i spark ./spark
```

Export LoadBalancer IPS

```
export SPARK_SERVICE_IP=$(kubectl get svc --namespace default spark-webui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
export ZEPPELIN_SERVICE_IP=$(kubectl get svc --namespace default spark-zeppelin -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Open in browser spark admin panel

```
echo http://$SPARK_SERVICE_IP:8080
```

and Zeppelin 

```
 echo http://$ZEPPELIN_SERVICE_IP:8080
```


In Zeppelin WebUI create new note and add code from CreditPredictor.scala

Run notebook and see the results.
 
