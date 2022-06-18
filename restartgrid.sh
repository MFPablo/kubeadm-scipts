#!/bin/bash
kubectl delete deployments --all;
kubectl delete services --all;
kubectl delete pods --all;
sleep 30;
kubectl apply -f full-grid-deployment.yaml;
sleep 5;
kubectl get pods -o wide
