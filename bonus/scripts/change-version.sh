#!/bin/bash

set -e

REPO_NAME="inception-repo"
REPO_URL="https://gitlab.local/root/${REPO_NAME}.git"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

ROOT_PW=$(kubectl get secret --namespace gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode)
GIT_SSL_NO_VERIFY=1 git clone "https://root:${ROOT_PW}@gitlab.local/root/${REPO_NAME}.git" "$WORK_DIR"
cd "$WORK_DIR"
GIT_SSL_NO_VERIFY=1 git config http.sslVerify false

if grep -q 'image: wil42/playground:v1' app.yaml; then
  sed -i 's/playground:v1/playground:v2/' app.yaml
  new_ver=v2
else
  sed -i 's/playground:v2/playground:v1/' app.yaml
  new_ver=v1
fi

git add app.yaml
git commit -m "Bump image to $new_ver"
git push origin main
echo "Pushed version $new_ver"
