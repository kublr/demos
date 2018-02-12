
# Demo 2. OIDc Authentication

```
(cd target && helm lint ../ldap && helm package ../ldap) 
(cd target && helm lint ../dashboard-oidc-proxy && helm package ../dashboard-oidc-proxy) 

docker pull cr.kublr.com/kublr/gen:1.8.0

docker run --rm \
    -v "$(pwd)/gen-out:/gen-out" \
    -v "$(pwd):/gen" \
    -v ~/.aws:/.aws \
    -u "$(id -u)" \
    -e HOME=/ \
    cr.kublr.com/kublr/gen:1.8.0 -f /gen/.cluster-config.yaml -o /gen-out
    
cd gen-out
bash bash aws-cluster-demo3-aws1.sh
export KUBECONFIG=$(pwd)/config-demo3.yaml
export HELM_REPO_URL=https://repo.kublr.com/repository/helm
bash setup-packages.sh # remove --user in curl


helm upgrade -i demo2 --namespace kube-system ../target/ldap-0.2.0.tgz
helm upgrade -i demo3 --namespace kube-system ../target/dashboard-oidc-proxy-0.0.1.tgz


helm upgrade -i kublr-feature-logging --namespace kube-system -f ../demo3.yaml https://repo.kublr.com/repository/helm/kublr-feature-logging-0.4.3.tgz
helm upgrade -i kublr-feature-monitoring --namespace kube-system -f ../demo3.yaml https://repo.kublr.com/repository/helm/kublr-feature-monitoring-0.4.1.tgz
helm upgrade -i monitoring --namespace monitoring --set kubernetesApiEndpoint=<clusterApiEndpoint> -f ../demo3.yaml https://repo.kublr.com/repository/helm/app-monitoring-0.2.2.tgz



helm upgrade -i --namespace kube-system --set kubernetesApiEndpoint=<clusterApiEndpoint> -f auth-proxy.yaml https://nexus.ecp.eastbanctech.com/repository/helm/kublr-feature-logging-0.4.3-prEDS1804.3.tgz
helm install --name monitoring --namespace monitoring https://nexus.ecp.eastbanctech.com/repository/helm/app-monitoring-0.2.0.tgz

helm upgrade -i --namespace kube-system demo "https://${HELM_TARGET_REPO_USER}:${HELM_TARGET_REPO_PASSWORD}@nexus.ecp.eastbanctech.com/repository/helm/dashboard-oidc-proxy-0.0.1.tgz"
helm upgrade -i --namespace kube-system demo2 "https://${HELM_TARGET_REPO_USER}:${HELM_TARGET_REPO_PASSWORD}@nexus.ecp.eastbanctech.com/repository/helm/ldap-0.2.0.tgz"




helm upgrade --namespace monitoring -f auth-proxy.yaml monitoring app-monitoring-0.2.0-prEDS1803.1.tgz
helm upgrade -i --namespace kube-system -f auth-proxy.yaml kublr-feature-logging kublr-feature-logging-0.4.2-prEDS1804.tgz

```


# Error: UPGRADE FAILED: "kublr-feature-logging" has no deployed releases



```
helm lint ldap
helm package ldap
curl -X PUT -f --insecure --progress-bar --user "${HELM_TARGET_REPO_USER}:${HELM_TARGET_REPO_PASSWORD}" \
        --upload-file ldap-0.2.0.tgz "https://nexus.ecp.eastbanctech.com/repository/helm/ldap-0.2.0.tgz"


helm lint dashboard-oidc-proxy
helm package dashboard-oidc-proxy

curl -X PUT -f --insecure --progress-bar --user "${HELM_TARGET_REPO_USER}:${HELM_TARGET_REPO_PASSWORD}" \
        --upload-file dashboard-oidc-proxy-0.0.1.tgz "https://nexus.ecp.eastbanctech.com/repository/helm/dashboard-oidc-proxy-0.0.1.tgz"
```