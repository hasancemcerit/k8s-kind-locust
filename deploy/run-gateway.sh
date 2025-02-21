
#!/usr/bin/env bash
# This script deploys the envoy gateway
# References:
# https://gateway-api.sigs.k8s.io/implementations/
# https://gateway.envoyproxy.io/docs/tasks/quickstart/
# https://docs.tetrate.io/envoy-gateway/howto/demo-chart
set -e

CLUSTER_NAME=demo-cl
HOST_PORT=81

# create cluster if it doesn't exist
if ! kind get clusters -q | grep -qx "$CLUSTER_NAME" ; then 
    kind create cluster --config deploy/cluster-config.yaml
    # TODO: 
    # check cluster info 
    #kubectl cluster-info --context kind-demo-cl
    # live probe
    # change the port number from above
    #curl -k https://localhost:57826/livez?verbose
fi

# load images into cluster
# TODO: sort by creation date and get the latest and check if exists
kind load docker-image demo-cs:0.1 demo-py:0.1 --name $CLUSTER_NAME

# install envoy gateway CRDs
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.3.0/install.yaml
kubectl wait deployment/envoy-gateway -n envoy-gateway-system --for=condition=available --timeout=2m

# apply deployment, gateway and routes
kubectl apply -f deploy/app-svc.yaml -f deploy/envoy-gw.yaml -f deploy/http-routes.yaml
kubectl wait deployment/cs-app -n demo-ns --for=condition=available --timeout=2m
kubectl wait deployment/py-app -n demo-ns --for=condition=available --timeout=2m 

export ENVOY_SERVICE=$(kubectl get svc -n envoy-gateway-system \
    --selector=gateway.envoyproxy.io/owning-gateway-namespace=demo-ns,gateway.envoyproxy.io/owning-gateway-name=envoy-gateway \
    -o jsonpath='{.items[0].metadata.name}')
kubectl wait deployment.apps/$ENVOY_SERVICE -n envoy-gateway-system --for=condition=available --timeout=3m

# port-forward envoy gateway
# this is needed for envoy gateway to route traffic to the services
ps aux | grep -i kubectl | grep -v grep | awk {'print $2'} | xargs -r kill
kubectl -n envoy-gateway-system port-forward service/${ENVOY_SERVICE} $HOST_PORT:80 &
sleep 3

# test via curl
echo 
curl --fail "http://localhost:$HOST_PORT/py/ping" && curl --fail "http://localhost:$HOST_PORT/cs/random"
echo
echo "Success!"

# delete cluster and everything in it
# kind delete cluster -n demo-cl