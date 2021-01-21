# K3dcontainer

The k3dcontainer container was created to easily setup the lightweight Kubernetes cluster with the k3d tool on a Docker
environment. This k8 cluster is primarily used for Kubernetes integration tests executed on the development machine or
on a continuous integration environment.

The k3dcontainer provides kubectl client and Kube config for other test libraries/frameworks to use in their Kubernetes
tests. 

The k3dcontainer will be running in a infinite loop until the manually stopped by user or automatically by test
libraries/frameworks.

## Get started

Here is an example of initiating the kubernetes cluster with help of the k3dcontainer. It's important to provide
docker socket volume to be able to talk to the Kubernetes cluster container. Directories as volumes must be provided
to be able to do configmap setups. Default secret environment must be provided if you want to create secret environment
variables defined by the HOST environment and used by the K8 manifest files. Volume directory containing 
the Kubernetes manifest yaml files must be provided to deploy pods, services and deployments etc. It's important
the right number ordering of the yaml files is set if they are dependent on each other.

### Reference

https://hub.docker.com/r/jsquadab/k3dcontainer/

### Example

```bash
docker run --net=host \
-v /var/run/docker.sock:/var/run/docker.sock \
-v "$(pwd)"/service:/service \
-v "$(pwd)"/security:/security \
-v "$(pwd)"/deployment:/deployment \
--env CLUSTER_NAME="jsquad" \
--env CLUSTER_API_PORT="6443" \
--env LOAD_BALANCER_PORTS="1080 80 443" \
--env SECRET_ENVIRONMENT="openbank-spring-secret" \
--env SECRETS_ENVIRONMENT_VARIABLES="MASTER_KEY=$MASTER_KEY ROOT_PASSWORD=$ROOT_PASSWORD \
OPENBANK_PASSWORD=$OPENBANK_PASSWORD SECURITY_PASSWORD=$SECURITY_PASSWORD" \
--env CREATE_CONFIG_MAPS_VOLUMES_FROM_FILES_COMMAND="kubectl create configmap ssl-volume \
--from-file=/service/src/test/resources/test/ssl/truststore && \
kubectl create configmap flyway-ddl-volume --from-file=/security/sql" \
--env DEPLOY_YAML_FILES_PATH="/deployment" jsquadab/k3dcontainer:latest
```