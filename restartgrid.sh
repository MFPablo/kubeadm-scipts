#!/bin/bash
kubectl delete deployments --all;
kubectl delete services --all;
sleep 30;
kubectl apply -f full-grid-deployment.yaml
