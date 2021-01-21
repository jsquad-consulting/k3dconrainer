#!/bin/bash

#
# Copyright 2021 JSquad AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

CLUSTER_NAME="${1:-'test'}"
CLUSTER_API_PORT="${2:-'6443'}"
LOAD_BALANCER_PORTS="${3:-'80 443'}"
SECRET_ENVIRONMENT="${4}"
SECRETS_ENVIRONMENT_VARIABLES="${5}"
CREATE_CONFIG_MAPS_VOLUMES_FROM_FILES_COMMAND="${6}"
DEPLOY_YAML_FILES_PATH="${7}"
SECRETS_ARGUMENTS=""
LOAD_BALANCER_ARGUMENTS=""

for port in ${LOAD_BALANCER_PORTS}; do
  LOAD_BALANCER_ARGUMENTS="${LOAD_BALANCER_ARGUMENTS} --port ${port}:${port}@loadbalancer"
done

LOAD_BALANCER_ARGUMENTS=$(bash -c "echo ${LOAD_BALANCER_ARGUMENTS} | xargs")

wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v3.4.0 bash

bash -c "k3d cluster create ${CLUSTER_NAME} --api-port ${CLUSTER_API_PORT} ${LOAD_BALANCER_ARGUMENTS} \
--k3s-server-arg '--no-deploy=traefik'"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install my-nginx ingress-nginx/ingress-nginx

for secret_variable in ${SECRETS_ENVIRONMENT_VARIABLES}; do
  SECRETS_ARGUMENTS="${SECRETS_ARGUMENTS} --from-literal=${secret_variable}"
done

SECRETS_ARGUMENTS=$(bash -c "echo ${SECRETS_ARGUMENTS} | xargs")

if [[ ! -z "${SECRETS_ARGUMENTS}" ]]; then
  :
  kubectl create secret generic $SECRET_ENVIRONMENT ${SECRETS_ARGUMENTS}
fi

if [[ ! -z "${CREATE_CONFIG_MAPS_VOLUMES_FROM_FILES_COMMAND}" ]]; then
  :
  bash -c "${CREATE_CONFIG_MAPS_VOLUMES_FROM_FILES_COMMAND}"
fi

if [[ ! -z "${DEPLOY_YAML_FILES_PATH}" ]]; then
  :
  yaml_files=$(ls -v "${DEPLOY_YAML_FILES_PATH}" | xargs)
  for yaml_file in ${yaml_files}; do
    bash -c "kubectl apply -f "${DEPLOY_YAML_FILES_PATH}"/${yaml_file}"
    bash -c "/app/health_check.sh /app/"
  done
fi