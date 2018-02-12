

## Create secrets

kubectl create secret generic demo2-app-mysql abcd123456

## Create tls certificate

```
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout certs/keycloak.key -out certs/keycloak.crt -subj "/CN=keycloak.demo.kublr.com"
kubectl create secret tls demo2-keycloak-tls --key certs/keycloak.key --cert certs/keycloak.crt

```