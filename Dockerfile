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
FROM rancher/k3d:v4.4.6-dind

RUN curl -fsSL -o /get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod 700 /get_helm.sh
RUN /get_helm.sh && rm /get_helm.sh
RUN mkdir -p /app

COPY health_check.sh /app/health_check.sh
COPY initiate_kubernetes_cluster.sh /app/initiate_kubernetes_cluster.sh
COPY verify_if_deployed_service_is_ready.sh /app/verify_if_deployed_service_is_ready.sh

HEALTHCHECK CMD ["bash", "-c", "/app/health_check.sh /app/"]
CMD ["bash", "-c", "/app/initiate_kubernetes_cluster.sh \"${CLUSTER_NAME}\" \"${CLUSTER_API_PORT}\" \
\"${LOAD_BALANCER_PORTS}\" \"${SECRET_ENVIRONMENT}\" \"${SECRETS_ENVIRONMENT_VARIABLES}\" \
\"${CREATE_CONFIG_MAPS_VOLUMES_FROM_FILES_COMMAND}\" \"${DEPLOY_YAML_FILES_PATH}\" \
&& tail -f /dev/null"]