# Compose ➜ Kubernetes/Helm ➜ OpenShift (UI, Helm, GitOps)

This repo is a hands-on lab to convert Docker containers and Docker Compose files into Kubernetes/OpenShift manifests and Helm charts, then deploy them three ways:
1) **OpenShift Web Console (YAML)**,
2) **Helm** (UI or CLI),
3) **OpenShift GitOps** (Argo CD).

> Everything here is intentionally simple and vendor-agnostic, with an OpenShift-friendly twist (arbitrary UID, Routes).

---

## What you’ll practice

- Converting `docker-compose.yaml` to Kubernetes manifests with **kompose**
- Turning manifests into a Helm chart with **helm** (optionally **helmify**)
- Deploying via:
  - OpenShift Console ➜ “+Add” ➜ “Import YAML”
  - Helm (UI or `helm upgrade --install`)
  - OpenShift GitOps (Argo CD `Application` CR)
- Optional: pushing artifacts to your **GitHub** repo

---

## Prereqs

- Docker or Podman (to run original containers if you want to test locally)
- **kompose**: https://kompose.io/ (converts Compose to K8s/OpenShift)
- **oc** CLI (matches your cluster version)
- **helm** CLI (v3+)
- Optional: **helmify** (convert raw manifests into a templated Helm chart)
- An OpenShift cluster and a project/namespace where you can deploy

```bash
# Fedora/RHEL example (adjust for your OS)
sudo dnf install -y helm
curl -L https://github.com/kubernetes/kompose/releases/latest/download/kompose-linux-amd64 -o kompose && chmod +x kompose && sudo mv kompose /usr/local/bin/
# oc: download from your cluster's "Command Line Tools" page
```

---

## Repo layout

```
.
├── apps/
│   └── demo-nginx/
│       └── docker-compose.yaml         # Example Compose app (nginx)
├── generated/
│   └── k8s/
│       └── demo-nginx/
│           └── all-in-one.yaml         # Output from kompose
├── charts/
│   └── demo-nginx/                     # Example Helm chart (OpenShift-friendly)
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           └── route.yaml
├── gitops/
│   └── demo-nginx-app.yaml             # Argo CD Application CR (OpenShift GitOps)
├── scripts/
│   ├── convert.sh                      # Compose ➜ K8s; optional Helm chart via helmify
│   ├── deploy-oc-yaml.sh               # Apply raw YAML with oc
│   ├── deploy-helm.sh                  # Helm install/upgrade
│   └── bootstrap-gitops.sh             # Create Argo CD Application
└── Makefile                            # Nice wrappers for common tasks
```

---

## 1) Convert Compose to Kubernetes

Edit `apps/demo-nginx/docker-compose.yaml` or drop in your own app as `apps/<your-app>/docker-compose.yaml`.

Then run:

```bash
make convert APP=demo-nginx
```

This uses `kompose` to produce `generated/k8s/<APP>/all-in-one.yaml`.
If you have **helmify** installed, it can also generate a starting Helm chart.

> Tip: kompose has flags like `--controller-deployment`, `--build`, and `--volumes`. Start simple; you can refine later.

---

## 2) Deploy using YAML in the OpenShift UI

- Go to **Developer** perspective ➜ **+Add** ➜ **Import YAML**
- Paste the contents of `generated/k8s/<APP>/all-in-one.yaml`
- Save ➜ watch resources appear in **Topology**

You may need to tweak:
- **SecurityContext** to support arbitrary UIDs (OpenShift default)
- **Service** type and add a **Route** to expose HTTP

---

## 3) Deploy with Helm

You can use the provided chart in `charts/demo-nginx` or your own.

```bash
# create namespace if needed
oc new-project demo-nginx || true

# install/upgrade
make deploy-helm APP=demo-nginx NAMESPACE=demo-nginx
```

OpenShift Console ➜ **Helm** ➜ **Releases** shows status. You can also install from the UI by uploading the chart archive you package with `helm package charts/<APP>`.

**values.yaml knobs** include image, replicas, service port, and a simple `route.enabled` toggle to expose via Route.

---

## 4) Deploy with OpenShift GitOps (Argo CD)

Edit `gitops/demo-nginx-app.yaml` and set your Git repo URL and path (this repo structure works well). Then:

```bash
make bootstrap-gitops APP=demo-nginx NAMESPACE=demo-nginx   GIT_URL=https://github.com/<you>/<repo>.git   GIT_PATH=charts/demo-nginx
```

In the OpenShift Console ➜ **Argo CD** (from the OpenShift GitOps operator) you’ll see the application sync status.

> You can point Argo CD at either `charts/<APP>` for Helm or `generated/k8s/<APP>` for raw manifests. Pick one per Application.

---

## 5) Push to your GitHub repo (optional)

Initialize and push like any normal Git repo:

```bash
git init
git add .
git commit -m "Compose ➜ K8s/Helm ➜ OpenShift starter"
git branch -M main
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main
```

If you want to automate: add a simple GitHub Actions workflow later to lint manifests, template Helm, etc.

---

## Cleanup

```bash
# remove Helm release
helm uninstall demo-nginx -n demo-nginx || true
# delete namespace
oc delete project demo-nginx || true
# if you applied raw YAML:
oc delete -f generated/k8s/demo-nginx/all-in-one.yaml -n demo-nginx || true
```

Happy shipping.
