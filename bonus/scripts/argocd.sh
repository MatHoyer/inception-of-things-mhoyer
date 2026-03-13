#!/bin/bash

set -e

IP=$1

kubectl create namespace argocd

kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

echo "Waiting for Argo CD server to be available..."
kubectl wait --namespace argocd --for=condition=available --timeout=180s deployment/argocd-server

kubectl apply -n argocd -f /home/vagrant/confs/argocd
kubectl rollout restart deployment argocd-server -n argocd

until [ -n "$(argocd admin initial-password -n argocd 2>/dev/null)" ]; do echo "Waiting for password..."; sleep 5; done

bash -c "echo '$IP argocd.local app.local' >> /etc/hosts"
echo "Argo CD UI: https://argocd.local"
echo "App UI: https://app.local"
echo "Initial username: admin"
echo "Initial password: $(argocd admin initial-password -n argocd)"