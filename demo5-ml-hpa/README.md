

kube-apiserver.yaml 
--runtime-config=api/all=true


kube-controller-manager.yaml
--horizontal-pod-autoscaler-use-rest-clients=true
--master=<apiserver-address>:<port>


kubectl api-versions | grep "autoscaling/v2beta1"

kubectl apply -f custom-metrics.yaml

kubectl api-versions | grep "custom-metrics.metrics.k8s.io/v1alpha1"


helm upgrade -i kublr-feature-monitoring --namespace kube-system --set influxdb.enabled=false https://repo.kublr.com/repository/helm/kublr-feature-monitoring-0.4.1.tgz
helm upgrade -i monitoring --namespace monitoring --set kubernetesApiEndpoint=https://13.56.119.59  https://repo.kublr.com/repository/helm/app-monitoring-0.2.3.tgz









```bash
helm upgrade -i kublr-feature-monitoring --namespace kube-system --set influxdb.enabled=false https://repo.kublr.com/repository/helm/kublr-feature-monitoring-0.4.1.tgz
helm upgrade -i monitoring --namespace monitoring --set kubernetesApiEndpoint=https://54.176.215.107 arkadiy/app-monitoring-0.2.3-prEDS2036.1.tgz


helm upgrade -i rabbitmq --set replicaCount=1 ./app-rabbitmq

kubectl expose service rabbitmq-app-rabbitmq --type=LoadBalancer --name=rabbitmq-mgmt --port=80 --target-port=15672
kubectl expose service rabbitmq-app-rabbitmq --type=LoadBalancer --name=rabbitmq-svc --port=80 --target-port=5672

export RABBITMQ_HOST=afc7b756017c211e89b74061c64dbe2f-339207793.us-west-1.elb.amazonaws.com
export RABBITMQ_PORT=80
export RABBITMQ_USERNAME=guest
export RABBITMQ_PASSWORD=$(kubectl get secret --namespace default rabbitmq-app-rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 --decode)

python rabbitmq-consumer/new_task.py 1000 100000000

helm install --name test --set rabbitmq.host=rabbitmq-app-rabbitmq --set rabbitmq.password=$RABBITMQ_PASSWORD  ./rabbitmq-consumer/charts/rabbitmq-consumer
kubectl autoscale deployment test-rabbitmq-consumer --min=1 --max=5 --cpu-percent=70
kubectl get hpa

kubectl run php-apache --image=gcr.io/google_containers/hpa-example --requests=cpu=200m --expose --port=80
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl describe hpa php-apache

curl -vvv https://50.18.219.194/apis/metrics/v1alpha1/namespaces/staging/pods?labelSelector=app%3Davro-schema-registry%2Cconfluent-version%3D3.3.1%2Cenv%3Dstaging%2Cversion%3D0.11.0.1
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/default/pods | python -m json.tool
 
 
 
## Custom metrics
 
helm upgrade -i test --set image.tag=pause-10 --set rabbitmq.host=rabbitmq-app-rabbitmq --set rabbitmq.password=$RABBITMQ_PASSWORD rabbitmq-consumer/charts/rabbitmq-consumer
kubectl apply -f rabbitmq-consumer/custom-metrics.yaml
kubectl apply -f rabbitmq-consumer/autoscaler.yaml

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/rabbitmq_queue_messages_ready_current" | jq .

```

/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/%2A/rabbitmq_queue_messages_ready_current?labelSelector=app%3Drabbitmq-consumer%2Crelease%3Dtest:



/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/metrics/rabbitmq_queuesTotal
/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/%2A/cpu_system
/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/metrics/rabbitmq_queue_messages
/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/metrics/rabbitmq_up


kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/nodes/*/rabbitmq_node_mem_alarm" | jq '.'

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -v
docker run --rm -it -v $(pwd):/go/src/my/pkg/name -w /go/src/my/pkg/name \
    instrumentisto/glide make -B vendor


https://50.18.219.194/api/v1/proxy/namespaces/kube-system/services/heapster/api/v1/model/namespaces/kube-system/pod-list/monitoring-prometheus-84b5b97659-g4wj6/metrics/cpu-usage

kubectl get pod kubernetes-dashboard-7d9f68d7b4-57vrp -n kube-system -o yaml | kubectl replace --force -f -

https://github.com/luxas/kubeadm-workshop
https://itnext.io/monitoring-on-kubernetes-custom-metrics-c068165f82d3

4279


