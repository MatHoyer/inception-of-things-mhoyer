#!/bin/bash

set -e
set +H  # disable history expansion so ! in gitlab-rails runner code is not interpreted

REPO_NAME="inception-repo"
ROOT_PW=$(kubectl get secret --namespace gitlab gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode)

echo "Creating public repository $REPO_NAME..."
REPO_FULL_PATH=$(kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- gitlab-rails runner "
  ApplicationSetting.current_without_cache.update!(restricted_visibility_levels: [])
  user = User.find_by(username: 'root')
  ns = nil
  org = nil
  begin
    org = Organization.first
    ns = Namespace.find_by(organization_id: org.id, parent_id: nil)
    if ns.nil? && org
      ns = Group.create!(name: 'inception', path: 'inception', visibility_level: 20, organization_id: org.id)
      ns.add_owner(user)
    end
  rescue NameError
  end
  ns = user.namespace if ns.nil?
  Project.find_by(path: '$REPO_NAME')&.destroy
  p = Project.create!(
    name: '$REPO_NAME',
    path: '$REPO_NAME',
    visibility_level: 20,
    creator: user,
    namespace: ns
  )
  Project.where(id: p.id).update_all(visibility_level: 20)
  p.add_member(user, Gitlab::Access::OWNER) unless p.member?(user)
  puts p.full_path
" 2>/dev/null | tail -1)
REPO_FULL_PATH=${REPO_FULL_PATH:-root/$REPO_NAME}

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