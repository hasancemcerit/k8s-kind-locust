
#!/usr/bin/env bash
# This script deploys the nginx ingress controller
set -e

CLUSTER_NAME=demo-cl

# create cluster if it doesn't exist
if ! kind get clusters -q | grep -qx "$CLUSTER_NAME" ; then 
    kind create cluster --config deploy/cluster-config.yaml
    kubectl get --raw='/livez'
    echo
fi

# load images into cluster
kind load docker-image demo-cs:0.1 demo-py:0.1 --name $CLUSTER_NAME

# install nginx ingress controller
kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

# apply deployment, nginx ingress routes
kubectl apply -f deploy/app-svc.yaml -f deploy/nginx-ingress.yaml
kubectl wait deployment/cs-app -n demo-ns --for=condition=available --timeout=2m
kubectl wait deployment/py-app -n demo-ns --for=condition=available --timeout=2m 
kubectl wait pod -l app=cs-app -n demo-ns --for=condition=ready --timeout=2m 
kubectl wait pod -l app=py-app -n demo-ns --for=condition=ready --timeout=2m 

# test via curl
# nginx ingress does not need to be port-forwarded
echo 
curl --fail "http://localhost/py/ping" && curl --fail "http://localhost/cs/random"
echo
echo "Success!"

# delete cluster and everything in it
# kind delete cluster -n demo-cl