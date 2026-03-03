#!/bin/bash
# Install K3s on the master node (bind to host-only IP so node and API use 192.168.56.110)
curl -sfL https://get.k3s.io | sh -s - server --node-ip=192.168.56.110

# Make sure kubectl is set up for the vagrant user
sudo mkdir -p /home/vagrant/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
sudo chown -R vagrant:vagrant /home/vagrant/.kube/config

# Copy app HTML to a real path (vboxsf synced folders can't be used as hostPath by containerd)
sudo mkdir -p /var/lib/k3s-apps
for app in app1 app2 app3; do
  sudo mkdir -p /var/lib/k3s-apps/"$app"
  sudo cp /home/vagrant/apps/"$app"/"$app".html /var/lib/k3s-apps/"$app"/index.html
done

# Apply app manifests (nginx + HTML per app)
for f in /home/vagrant/configs/*.yaml; do
  [ -f "$f" ] && sudo /usr/local/bin/kubectl apply -f "$f"
done