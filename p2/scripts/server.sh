#!/bin/bash

IP=$1

# Install K3s on the master node (bind to host-only IP so node and API use 192.168.56.110)
curl -sfL https://get.k3s.io | sh -s - server --node-ip=$MASTER_IP

# Make sure kubectl is set up for the vagrant user (wait for k3s to write kubeconfig)
sudo mkdir -p /home/vagrant/.kube
until [ -f /etc/rancher/k3s/k3s.yaml ]; do sleep 2; done
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config
grep -q 'KUBECONFIG=' /home/vagrant/.bashrc 2>/dev/null || echo 'export KUBECONFIG=/home/vagrant/.kube/config' | sudo tee -a /home/vagrant/.bashrc
sudo chown vagrant:vagrant /home/vagrant/.bashrc

# Apply app manifests (Kustomize: all overlays) and ingress
sudo /usr/local/bin/kubectl apply -k /home/vagrant/configs/overlays
sudo /usr/local/bin/kubectl apply -f /home/vagrant/configs/ingress.yaml