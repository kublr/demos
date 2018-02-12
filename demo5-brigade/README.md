

helm lint brigade/charts/brigade
helm package brigade/charts/brigade

helm lint brigade/charts/brigade-project
helm package brigade/charts/brigade-project

helm lint kashti/charts/kashti
helm package kashti/charts/kashti

helm upgrade -i -f brigade.yaml brigade ./brigade-0.9.0.tgz
helm upgrade -i -f kashti.yaml kashti ./kashti-0.1.0.tgz


# Check the urls

http://kashti.demo.kublr.com
http://brgd-api.demo.kublr.com/v1/projects-build  ( [ ] )
http://brgd-api.demo.kublr.com/events/github ( 404 - not found)

# Webhook

Create webhook in alex-egorov/smackapi repository

- Payload URL: http://brgd-gw.demo.kublr.com/events/github
- Content type: application/json
- Secret: SecretPassword
- Let me select individual events.
  + Push
  + Pull request




helm upgrade -i -f smackapi.yaml --set github.token=<yout_token> --set secrets.dockerPassword=<your_dockerhub_pass> smackapi ./brigade-project-0.9.0.tgz

helm lint smackapi/charts/smackapi
helm package smackapi/charts/smackapi

helm lint  smackapi/charts/smackweb
helm package  smackapi/charts/smackweb

helm upgrade -i smackapi-prod ./smackapi-1.1.tgz
helm upgrade -i smackweb ./smackweb-0.1.0.tgz


```
helm install -n brigade brigade/brigade --set rbac.enabled=true --set service.type=ClusterIP
helm upgrade -i -f kube-con-2017-values.yaml kube-con-2017 brigade/brigade-project 

kubectl create -f <(istioctl kube-inject -f web.yaml) -n microsmack 

kubectl create -f <(istioctl kube-inject -f api-svc.yaml) -n microsmack


helm upgrade -i kashti ./charts/kashti --set service.type=LoadBalancer \
  --set brigade.apiServer=http://brigade-brigade-api:7745
  
  
helm inspect values brigade/brigade-project > myvalues.yaml
```


helm upgrade -i -f brigade-test.yaml --set github.token=e449c4bb7af40fadba093a624e1bc90102db9ac2 brigade-test brigade/brigade-project

helm upgrade -i -f ../../kube-con-2017-values.yaml --set github.token=e449c4bb7af40fadba093a624e1bc90102db9ac2 kube-con-2017 brigade-project-0.9.0.tgz

e449c4bb7af40fadba093a624e1bc90102db9ac2