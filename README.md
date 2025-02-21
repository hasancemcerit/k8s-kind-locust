## 🚀 Introduction
This is a personal playground to learn little more about [locust.io](https://docs.locust.io/en/stable/what-is-locust.html).

While load testing simple APIs written in `C#` and `Python`, it could be an idea💡to run these SUT in a load-balanced, containerized applications running in Kubernetes cluster.

### 🛠️ Toolset 

<p align="left">
   <img src="https://skillicons.dev/icons?i=vscode,powershell,bash,docker,kubernetes,nginx,cs,python,flask" />
</p>

| 🛠️ | ℹ️ |
| ----- | --- |
| [Docker](https://www.docker.com/get-started/) | Docker is an open platform for developing, shipping, and running applications. |
| [Kubernetes](https://kubernetes.io/) | Kubernetes (K8s) is an open-source system for automating deployment, scaling, and management of containerized applications. |
| [locust](https://locust.io/) | Locust is an open source performance/load testing tool for HTTP and other protocols. |
| [kind](https://kind.sigs.k8s.io/) | 'Kubernetes-in-Docker' is a tool for running local Kubernetes clusters using Docker container 'nodes'. |
| [MicroK8s](https://microk8s.io/) | MicroK8s is a low-ops, minimal production-like Kubernetes, and one of the the easiest and fastest way to get K8s up and running. |
| [Flask](https://flask.palletsprojects.com) | Flask is a micro web framework written in Python. |
| [Gunicorn](https://gunicorn.org/) | 'Green Unicorn' is a Python WSGI HTTP Server for UNIX. |


## 📃 Steps

0. Clone the repo

   ```bash
   git clone git@github.com:hasancemcerit/k8s-kind-locust.git
   cd k8s-kind-locust
   ```

1. Build API images

   ```bash
   docker build -f src/csharp/Dockerfile src/csharp/ -t demo-cs:0.1
   docker build -f src/python/Dockerfile src/python/ -t demo-py:0.1
   # optionally tag images as latest
   docker tag demo-cs:0.1 demo-cs:latest
   docker tag demo-py:0.1 demo-py:latest
   ```
  
2. Create local K8s cluster

   ⚔️ Choose your weapon of choice for local K8s environment.

   - <details>
      <summary>kind</summary>
      <p></p>
      
      Follow [kind installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) instructions.
      
      If you are using Windows/Powershell, the easiest way to install is 
      ```bash
      winget install Kubernetes.Kind         
      ```

      #### create cluster

      The following command will create cluster.

      ⚠️ This cluster uses port 8️⃣0️⃣ allow ingress traffic, as specified under `extraPortMappings` in `cluster-config.yaml` file. If you are running any web server or application that has already claimed this port, cluster creation will fail.

      ```bash
      kind create cluster --config deploy/cluster-config.yaml
      # check cluster info 
      kubectl cluster-info --context kind-demo-cl
      # live probe
      # 💡change the port number from above
      curl -k https://localhost:57826/livez?verbose
      ```

      #### load images
      ```bash
      kind load docker-image demo-cs:0.1 demo-py:0.1 --name demo-cl
      ```
   </details>

   <p></p>

   - <details>
      <summary>MicroK8s</summary>
      <p></p>

      Follow [MicroK8s installation](https://microk8s.io/docs/install-alternatives) instructions.

      In this setup, MicroK8s is insalled to [WSL/Ubuntu](https://learn.microsoft.com/en-us/windows/wsl/install) running on Windows 11, by running

      ```bash
      sudo snap install microk8s --classic
      ```

      #### configure cluster

      The following commands will configure MicroK8s cluster.

      ```bash
      # add your user to microK8s group
      sudo usermod -a -G microk8s $USER
      # check status
      microk8s status --wait-ready

      # enable storage
      microk8s enable hostpath-storage
      # disable dns and ha-cluster (not needed for this setup)
      microk8s disable dns
      microk8s disable ha-cluster --force
      ```

      #### load images
      ```bash
      # export local image to tarball
      docker save demo-py:0.1 > demo-py.tar
      docker save demo-cs:0.1 > demo-cs.tar
      # import images to microK8s cluster
      microk8s images import < demo-py.tar
      microk8s images import < demo-cs.tar
      ```
      ### create alias
      
      Bash alias for *nix shells
      ```bash
      alias kubectl='microk8s kubectl'
      ```
      Powershell alias for Windows
      ```cmd
      Set-Alias -Name 'microk8s kubectl' -Value kubectl
      ```

   </details>

   <p></p>

3. Create NGINX Ingress Controller

   for kind:
   ```bash
   kubectl apply --filename https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

   kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s
   ```

   for MicroK8s:
   ```bash
   microk8s enable ingress
   ```

4. Deploy API Pods

   The following command will create
   - namespace
      - demo-ns
   - 2 deployments
      - cs-app
      - py-app
   - 2 services
      - cs-svc
      - py-svc
   - ingress
      - demo-ingress
   
   ```bash
   kubectl apply -f deploy/app-svc.yaml -f deploy/nginx-ingress.yaml
   # wait for deployment is completed and pods are running
   kubectl wait deployment/cs-app -n demo-ns --for=condition=available --timeout=2m
   # check pods
   kubectl get pods -n demo-ns
   # describe ingress and check for rules
   kubectl describe ingress demo-ingress -n demo-ns
   # get all objects belong to the namespace
   kubectl get all -n demo-ns
   ```

5. Test Endpoints

   ```bash
   curl -f localhost/cs/ping
   # 🪒: pong from demo-cs-798475b757-9mbww
   curl -f localhost/py/random
   # 🐍: demo-py-5d78b48f8b-t4vmp generated random 8012255827640168882
   ```

6. (optional) Change Images

   This step is optional to use another image for the setup, assuming new images are imported into the cluster.

   ```bash
   # after loading a new version
   kubectl set image deployment/cs-app cs-app=demo-cs:0.2 -n demo-ns
   # check pods refreshing
   kubectl get pods -n demo-ns
   ```

6. Swarm locusts a.k.a run load test 🦗

   Assuming you already have or installed `python`, `pip(3)`, and `python-venv` that are required to run locust.

   If not, please do so. There are million ways to install these tools, you can choose depending on your OS/liking.
   
   - create and activate virtual environment
   
   It's advisable to run python on it's own virtual environment.

   ```
   python -m venv .env/locust-env
   source .env/locust-env/bin/activate
   or
   . .\.env\locust-env\Scripts\Activate.ps1
   ```
   - install locust
   
   ```
   pip3 install locust
   ```
   - run load test

   `locust.conf` file has some [sensible defaults](https://docs.locust.io/en/stable/configuration.html) to run the load test. You can customize this file, or add command line arguments to overwrite them.

   🔥 Be careful not to burn your CPUs. 😉

   ```
   locust -f get_command.py
   ```

   Sit back and relax while bugs are in action.

   <a href="https://asciinema.org/a/atsqrwnpKEcxmnSL9oh70J9J3?autoplay=1" rel="nofollow"><img src="https://asciinema.org/a/atsqrwnpKEcxmnSL9oh70J9J3.svg" alt="Test Results" data-canonical-src="https://asciinema.org/a/atsqrwnpKEcxmnSL9oh70J9J3.svg" style="max-width: 50%;"></a>

7. Cleanup

   ```bash
   kubectl delete all --all -n demo-ns
   # You can delete the kind cluster
   kind delete cluster -n demo-cl
   # or stop MicroK8s, depending on your environment.
   microk8s stop
   ```

#### Other useful commands

- Install metrics server (optional)
```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

   kubectl patch -n kube-system deployment metrics-server --type=json -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
   ```
- manual expose
```bash
kubectl expose deployment demo-deploy --type=LoadBalancer --port 80 --target-port=80 --name demo-lb --namespace demo-ns
```

[docker_logo]: https://www.docker.com/wp-content/uploads/2023/08/logo-guide-logos-2.svg
[docker_ico]: https://www.docker.com/favicon.ico
[k8s_ico]: https://kubernetes.io/images/favicon.png