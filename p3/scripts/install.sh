#!/bin/bash

# Docker
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# K3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

sudo k3d cluster create mycluster -p "80:80@loadbalancer" -p "443:443@loadbalancer"
sudo /usr/local/bin/kubectl get nodes
sudo /usr/local/bin/kubectl create namespace argocd
sudo /usr/local/bin/kubectl create namespace dev
sudo /usr/local/bin/kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo /usr/local/bin/kubectl get pods -n argocd

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# ArgoCD en HTTP derrière Traefik (server.insecure + Ingress port 80)
sudo /usr/local/bin/kubectl apply -f "$(dirname "$0")/../configs/argocd/cmd-params-insecure.yaml"
sudo /usr/local/bin/kubectl apply -f "$(dirname "$0")/../configs/argocd/ingress.yaml"
sudo /usr/local/bin/kubectl rollout restart deployment argocd-server -n argocd

until [ -n "$(argocd admin initial-password -n argocd 2>/dev/null)" ]; do echo "Waiting for initial password..."; sleep 5; done

sudo bash -c 'echo "127.0.0.1 argocd.local app.local" >> /etc/hosts'
echo "Argo CD UI: http://argocd.local"
echo "App UI: http://app.local"
echo "Initial username: admin"
echo "Initial password: $(argocd admin initial-password -n argocd)"