#!/usr/bin/env bash

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

SCRIPT_PATH=${1:-'./'}

PODS=$(kubectl get pods | awk 'FNR > 1 {print $1}' | xargs)

for pod in $PODS;
do
  STATUS=$(kubectl get pod "$pod" | awk 'FNR > 1 {print $3}')
  if [ "$STATUS" == "Running" ];
  then :
    command="kubectl describe pod ${pod} | grep -Po 'ContainersReady.*True' | head -1 | grep -Po 'True'"
    "$SCRIPT_PATH"verify_if_deployed_service_is_ready.sh "$pod" "$command"
  fi
done

DEPLOYMENTS=$(kubectl get deployments| awk 'FNR > 1 {print $1}' | xargs)

for deployment in $DEPLOYMENTS;
do
    command="kubectl describe deployment ${deployment} | grep -Po 'Available.*True' | head -1 | grep -Po 'True'"
    "$SCRIPT_PATH"verify_if_deployed_service_is_ready.sh "$pod" "$command"

    command="kubectl describe deployment ${deployment} | grep -Po 'Progressing.*True' | head -1 | grep -Po 'True'"
    "$SCRIPT_PATH"verify_if_deployed_service_is_ready.sh "$pod" "$command"
done