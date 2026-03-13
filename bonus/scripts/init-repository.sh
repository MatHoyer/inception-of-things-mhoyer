#!/bin/bash

set -e

REPO_NAME="inception-repo"
GITLAB_API="https://gitlab.local/api/v4"
ROOT_PW=$(kubectl get secret --namespace gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode)

echo "Creating GitLab token for $REPO_NAME..."
GITLAB_TOKEN=$(kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- \
  gitlab-rails runner "
    u = User.find_by_username('root');
    u.personal_access_tokens.find_by(name: '${REPO_NAME}-token')&.destroy;
    token = u.personal_access_tokens.create(
      name: '${REPO_NAME}-token',
      scopes: ['api','write_repository'],
      expires_at: 30.days.from_now
    );
    puts token.token;
  " | tail -1 | tr -d '\r\n')

echo "Creating public repository $REPO_NAME..."
curl -sS -k -H "PRIVATE-TOKEN: $GITLAB_TOKEN" -H "Content-Type: application/json" \
  -X POST "$GITLAB_API/projects" -d "{\"name\":\"$REPO_NAME\",\"path\":\"$REPO_NAME\",\"visibility\":\"public\"}"

REPO_FULL_PATH="root/$REPO_NAME"

PROJECT_FOLDER="project-v1"
echo "Initializing project $PROJECT_FOLDER..."
cp -r /home/vagrant/default-project /tmp/$PROJECT_FOLDER

git -C "/tmp/$PROJECT_FOLDER" init -b main
git -C "/tmp/$PROJECT_FOLDER" config http.sslVerify false
git -C "/tmp/$PROJECT_FOLDER" add app.yaml ingress.yaml
git -C "/tmp/$PROJECT_FOLDER" commit -m "Initial commit"
git -C "/tmp/$PROJECT_FOLDER" remote add origin "https://root:${ROOT_PW}@gitlab.local/${REPO_FULL_PATH}.git"
git -C "/tmp/$PROJECT_FOLDER" push -u origin main
rm -rf "/tmp/$PROJECT_FOLDER"

echo "Public repo: https://gitlab.local/${REPO_FULL_PATH}"
