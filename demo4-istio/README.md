

### Add to clustre config

```yaml
  kublrAgentConfig:
    kublr:
      kube_api_server_flag:
        runtime_config:
          flag: '--runtime-config='
          values:
            admissionregistration:
              value: admissionregistration.k8s.io/v1alpha1
              order: '020'
    
```

## Generate cluster configs

```
docker run --rm \
    -v "$(pwd)/gen-out:/gen-out" \
    -v "$(pwd):/gen" \
    -v ~/.aws:/.aws \
    -u "$(id -u)" \
    -e HOME=/ \
    cr.kublr.com/kublr/gen:1.8.0 -f /gen/.cluster-config.yaml -o /gen-out
```  
  
## Install kublr cluster

```
(cd gen-out && bash aws-istio4-aws1.sh)
```  
   
## Download and untar istion v0.5.0

...   
   
## Install istio   
    
```
kubectl apply -f istio-0.5.0/install/kubernetes/istio.yaml
```

(if fails run once again)

Install istio addons (if needed)

```
kubectl apply -f istio-0.5.0/install/kubernetes/addons/grafana.yaml
kubectl apply -f istio-0.5.0/install/kubernetes/addons/prometheus.yaml
kubectl apply -f istio-0.5.0/install/kubernetes/addons/servicegraph.yaml
kubectl apply -f istio-0.5.0/install/kubernetes/addons/zipkin.yaml
```

Install istio automatic inkection (as istio 0.5.0 requires k8s 1.9+ we use installation file from 0.4.0)

```
kubectl apply -f istio-initializer.yaml
```

```
export ISTIO=$(kubectl get svc --namespace istio-system istio-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

## Deploy smackapi

```
helm upgrade -i smackapi smackapi/charts/smackapi
```

Check that istio ingress works and routes to smackapi

```
curl --fail $ISTIO/getconfig
```

should return json

## Deploy smackweb

```
helm upgrade -i -f smackweb.yaml smackweb smackweb/charts/smackweb
```

```
export SMACKWEB=$(kubectl get svc --namespace default smackweb-smackweb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

Open in browser 
```
echo http://$SMACKWEB
```

Web page should work


## Canary Deploy

Make changes in smackapi
Change color in smackapi/smackapi/handlers.go, line number 31, e.g to "DarkGreen"

Commit changes

```
( cd smackapi/smackapi \
    && git add -A \
    && git commit -m "changed bgColor to DarkGreen" \
)
```

Build go binary, docker image, push docker into registry and update helm package with DOCKER_TAG we have used to push

```
sh build.sh
```


Change  weights of v1 and v2 smackapi microservices:

```
helm upgrade -i --set image.v1.weight=50 --set image.v2.weight=50 --set image.v2.tag=${DOCKER_TAG} smackapi smackapi/charts/smackapi
```

Open http://$SMACKWEB in browser once again. Some of cells are colored in Colar (v1), some in Dark Green (v2)