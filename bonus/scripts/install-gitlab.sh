curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

kubectl create namespace gitlab

echo "127.0.0.1 gitlab.local" >> /etc/hosts

helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm install --namespace gitlab gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=local \
  --set global.hosts.https=true \
  --set global.hosts.gitlab.name=gitlab.local \
  --set nginx-ingress.enabled=false \
  --set prometheus.install=false \
  --set gitlab-runner.install=false \
  --set registry.enabled=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.enabled=false \
  --set global.kas.enabled=false \
  --set global.pages.enabled=false \
  --set global.praefect.enabled=false \
  --set global.grafana.enabled=false \
  --set gitlab.gitlab-exporter.enabled=false \
  --set gitlab.toolbox.enabled=false \
  --set global.appConfig.lfs.enabled=false \
  --set global.appConfig.artifacts.enabled=false \
  --set global.appConfig.uploads.enabled=false \
  --set gitlab.webservice.minReplicas=1 \
  --set gitlab.webservice.maxReplicas=1 \
  --set gitlab.sidekiq.minReplicas=1 \
  --set gitlab.sidekiq.maxReplicas=1 \
  --set gitlab.gitlab-shell.minReplicas=1 \
  --set gitlab.gitlab-shell.maxReplicas=1 \
  --set gitlab.webservice.resources.requests.cpu=800m \
  --set gitlab.webservice.resources.requests.memory=1.5Gi \
  --set gitlab.sidekiq.resources.requests.cpu=300m \
  --set gitlab.sidekiq.resources.requests.memory=800Mi \
  --set gitlab.gitaly.resources.requests.cpu=300m \
  --set gitlab.gitaly.resources.requests.memory=800Mi \
  --set postgresql.resources.requests.cpu=300m \
  --set postgresql.resources.requests.memory=384Mi \
  --set redis.resources.requests.cpu=100m \
  --set redis.resources.requests.memory=128Mi \
  --set gitlab.migrations.resources.requests.cpu=300m \
  --set gitlab.migrations.resources.requests.memory=384Mi \
  --set minio.resources.requests.cpu=100m \
  --set minio.resources.requests.memory=128Mi

echo "Waiting for GitLab to be available..."
kubectl wait --namespace gitlab --for=condition=available --timeout=300s deployment/gitlab-webservice-default

kubectl apply -n gitlab -f /home/vagrant/confs/gitlab

echo "GitLab UI: https://gitlab.local"
echo "Initial username: root"
echo "Initial password: $(kubectl get secret --namespace gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode)"