#!/bin/bash

# This script tests the high level end-to-end functionality demonstrated
# as part of the examples/sample-app

set -o errexit
set -o nounset
set -o pipefail

OS_ROOT=$(dirname "${BASH_SOURCE}")/../..
source "${OS_ROOT}/hack/util.sh"
os::log::install_errexit

ROUTER_TESTS_ENABLED="${ROUTER_TESTS_ENABLED:-true}"
TEST_ASSETS="${TEST_ASSETS:-false}"


function wait_for_app() {
  echo "[INFO] Waiting for app in namespace $1"
  echo "[INFO] Waiting for database pod to start"
  wait_for_command "oc get -n $1 pods -l name=database | grep -i Running" $((60*TIME_SEC))
  oc logs dc/database -n $1 --follow

  echo "[INFO] Waiting for database service to start"
  wait_for_command "oc get -n $1 services | grep database" $((20*TIME_SEC))
  DB_IP=$(oc get -n $1 --output-version=v1beta3 --template="{{ .spec.portalIP }}" service database)

  echo "[INFO] Waiting for frontend pod to start"
  wait_for_command "oc get -n $1 pods | grep frontend | grep -i Running" $((120*TIME_SEC))
  oc logs dc/frontend -n $1 --follow

  echo "[INFO] Waiting for frontend service to start"
  wait_for_command "oc get -n $1 services | grep frontend" $((20*TIME_SEC))
  FRONTEND_IP=$(oc get -n $1 --output-version=v1beta3 --template="{{ .spec.portalIP }}" service frontend)

  echo "[INFO] Waiting for database to start..."
  wait_for_url_timed "http://${DB_IP}:5434" "[INFO] Database says: " $((3*TIME_MIN))

  echo "[INFO] Waiting for app to start..."
  wait_for_url_timed "http://${FRONTEND_IP}:5432" "[INFO] Frontend says: " $((2*TIME_MIN))

  echo "[INFO] Testing app"
  wait_for_command '[[ "$(curl -s -X POST http://${FRONTEND_IP}:5432/keys/foo -d value=1337)" = "Key created" ]]'
  wait_for_command '[[ "$(curl -s http://${FRONTEND_IP}:5432/keys/foo)" = "1337" ]]'
}

# service dns entry is visible via master service
# find the IP of the master service by asking the API_HOST to verify DNS is running there
MASTER_SERVICE_IP="$(dig @${API_HOST} "kubernetes.default.svc.cluster.local." +short A | head -n 1)"
# find the IP of the master service again by asking the IP of the master service, to verify port 53 tcp/udp is routed by the service
#[ "$(dig +tcp @${MASTER_SERVICE_IP} "kubernetes.default.svc.cluster.local." +short A | head -n 1)" == "${MASTER_SERVICE_IP}" ]
#[ "$(dig +notcp @${MASTER_SERVICE_IP} "kubernetes.default.svc.cluster.local." +short A | head -n 1)" == "${MASTER_SERVICE_IP}" ]

echo "[INFO] Installing the registry"
openshift admin registry --create --credentials="${MASTER_CONFIG_DIR}/openshift-registry.kubeconfig" --config="${ADMIN_KUBECONFIG}" --images="${USE_IMAGES}"

echo "[INFO] Waiting for Docker registry pod to start"
wait_for_registry

echo "[INFO] Confirming the regitstry is started"
oc describe service docker-registry --config="${ADMIN_KUBECONFIG}"

echo "[INFO] Logining in as test-admin using any password"
oc login --certificate-authority="${MASTER_CONFIG_DIR}/ca.crt" -u test-admin


echo "[INFO] Creating a new project in OpenShift. This creates a namespace test to contain the builds and app that we will generate"
oc new-project test --display-name="OpenShift 3 Sample" --description="This is an example project to demonstrate OpenShift v3"


echo "[INFO] Submitting the application template for processing and then request creation of the processed template"
oc new-app --docker-image=openshift/deployment-example:lei
#oc new-app --docker-image=/openshift/deployment-example:v2

echo "[INFO] Monitoring the builds and wait for the status to go to "complete" (this can take a few minutes)"
oc status

# wait_for_command '[[ "$(oc status || echo "0")" != "0" ]]'
echo "[INFO] Wait for the application's frontend pod and database pods to be started"
curl http://172.30.192.169:8080 # (example)
