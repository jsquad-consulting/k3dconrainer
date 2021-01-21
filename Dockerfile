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

FROM  ubuntu:bionic

RUN mkdir -p /app

COPY health_check.sh /app/health_check.sh
COPY initiate_kubernetes_cluster.sh /app/initiate_kubernetes_cluster.sh
COPY verify_if_deployed_service_is_ready.sh /app/verify_if_deployed_service_is_ready.sh

RUN apt-get update && apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common wget -y

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
RUN apt-get update
RUN apt-get install kubectl=1.20.1-00 -y
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add -
RUN echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update
RUN apt-get install helm -y
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

RUN apt-get update
RUN apt-get install docker-ce docker-ce-cli containerd.io -y

HEALTHCHECK CMD ["sh", "-c", "/app/health_check.sh /app/"]
CMD ["sh", "-c", "/app/initiate_kubernetes_cluster.sh \"${CLUSTER_NAME}\" \"${CLUSTER_API_PORT}\" \
\"${LOAD_BALANCER_PORTS}\" \"${SECRET_ENVIRONMENT}\" \"${SECRETS_ENVIRONMENT_VARIABLES}\" \
\"${CREATE_CONFIG_MAPS_VOLUMES_FROM_FILES_COMMAND}\" \"${DEPLOY_YAML_FILES_PATH}\" \
&& tail -f /dev/null"]