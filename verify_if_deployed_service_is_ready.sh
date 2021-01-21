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

# SECONDS is internal shell clock timer
SECONDS=0
TIMEOUT=300
RETRY_INTERVAL=10

main() {
    SERVICE_NAME="$1"
    KUBECTL_COMMAND=$(echo "${@:2}")
    echo "$KUBECTL_COMMAND"

    serviceReady="False"

    echo "Validating if service ${SERVICE_NAME} is up and running"
    echo -n "Will retry every $RETRY_INTERVAL for $TIMEOUT seconds... "
    while [ $SECONDS -lt $TIMEOUT ] && [ "$serviceReady" != "True" ];
    do
        serviceReady=$(is_service_ready)
        if [ "$serviceReady" != "True" ];
        then :
            echo -n " ${SECONDS}"
            sleep $RETRY_INTERVAL
        fi
    done
    echo ""

    if [ "$serviceReady" != "True" ];
    then :
       echo "Service ${SERVICE_NAME}: IS NOT RUNNING"
       exit 1
    else
       echo "Service ${SERVICE_NAME}: IS RUNNING"
    fi
}

is_service_ready() {
  bash -c "$KUBECTL_COMMAND"
}

main $*