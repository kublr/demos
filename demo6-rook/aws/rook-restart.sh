#!/bin/sh

kubectl delete -f rook-operator.yaml
sleep 20


kubectl apply -f rook-cleanup-data-dangerous.yaml
sleep 10
kubectl delete -f rook-cleanup-data-dangerous.yaml
kubectl apply -f rook-operator.yaml
