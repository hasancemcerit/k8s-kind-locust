
### build

Build an image and tag it (optional).
```
cd demo

docker build -f .\src\charp\Dockerfile .\src\csharp -t demo-cs:0.1
# optional
docker tag demo-cs:0.1 demo:latest

```
### create cluster
The following command will create `kind` cluster.
```
kind create cluster --config deploy\cluster-config.yaml
# check cluster info 
kubectl cluster-info --context kind-demo-cl
# live probe
# 💡change the port number from above
curl -k https://localhost:57826/livez?verbose
```
### load images
```
kind load docker-image demo-cs:0.1 demo-py:0.1 --name demo-cl
```
### create nginx ingress
```
kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
```
### apply yaml
The following command will create
- namespace
- 2 deployments
- loadbalancer
- ingress
```
kubectl apply -f .\deploy\demo.yaml
# check pods
kubectl get pods -n demo-ns
# describe ingress and check for rules
kubectl describe ingress demo-ingress -n demo-ns
```
### test
```
curl localhost/ping
# Hello random!
curl localhost/random
# pong from demo-6b4d75d467-78ckb!
```
### change image
```
# after loading a new version
kubectl set image deployment/demo demo=demo:0.2 -n demo-ns
# check pods refreshing
kubectl get pods -n demo-ns
```

### delete 
```
kubectl delete all --all -n demo-ns
```

### (optional) metrics server
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl patch -n kube-system deployment metrics-server --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

### reference commands
```
kubectl expose deployment demo-deploy --type=LoadBalancer --port 80 --target-port=80 --name demo-lb --namespace demo-ns
```