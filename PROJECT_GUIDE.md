# Project Guide: Docker Compose → Kubernetes/Helm → OpenShift

This guide is your embedded expert, designed to walk you through the process of converting Docker Compose files into OpenShift-friendly Kubernetes manifests and Helm charts, then deploying them using raw YAML, Helm, or OpenShift GitOps.

---

## 1. Goals of This Project

- **Learn**: Understand how Compose concepts map to Kubernetes/OpenShift.
- **Practice**: Convert real Compose files to working OpenShift workloads.
- **Deploy**: Try three deployment methods — YAML via UI, Helm, and GitOps.
- **Automate**: Prepare for continuous delivery with GitHub integration.

---

## 2. Prerequisites

Install the following tools locally:

- **Docker** or **Podman** (optional, to run/test Compose locally)
- **kompose**: Converts Compose files to Kubernetes/OpenShift manifests  
  https://kompose.io/
- **oc** CLI: Matches your OpenShift cluster version
- **helm** CLI: v3+  
- **helmify** (optional): Converts raw manifests into a Helm chart

Example installation (Linux/Fedora/RHEL):

```bash
sudo dnf install -y helm
curl -L https://github.com/kubernetes/kompose/releases/latest/download/kompose-linux-amd64 -o kompose && chmod +x kompose && sudo mv kompose /usr/local/bin/
# oc: download from OpenShift cluster's "Command Line Tools" page
```

---

## 3. Project Structure

```
.
├── apps/                        # Source Compose files
│   └── demo-nginx/
│       └── docker-compose.yaml
├── generated/                    # Output from kompose
│   └── k8s/
│       └── demo-nginx/
│           └── all-in-one.yaml
├── charts/                       # Helm charts (manually written or helmify output)
│   └── demo-nginx/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
├── gitops/                       # Argo CD Application CRs
│   └── demo-nginx-app.yaml
├── scripts/                      # Helper scripts
│   ├── convert.sh
│   ├── deploy-oc-yaml.sh
│   ├── deploy-helm.sh
│   └── bootstrap-gitops.sh
├── Makefile                      # Make targets for common tasks
└── README.md
```

---

## 4. Workflow Overview

### Step 1: Convert Docker Compose to Kubernetes YAML

```bash
make convert APP=demo-nginx
```
- Uses `kompose` to output `generated/k8s/<APP>/all-in-one.yaml`.
- If `helmify` is installed, can also generate a Helm chart.

**Tip:** Start with simple Compose files. Avoid complex volumes or build contexts for your first try.

---

### Step 2: Deploy Using OpenShift Web Console (YAML)

1. Open **Developer** perspective in OpenShift Console.
2. Go to **+Add** → **Import YAML**.
3. Paste contents of `generated/k8s/<APP>/all-in-one.yaml`.
4. Adjust for:
   - Arbitrary UID support (securityContext changes)
   - Service type and adding a Route for HTTP exposure

---

### Step 3: Deploy Using Helm

```bash
make deploy-helm APP=demo-nginx NAMESPACE=demo-nginx
```

- Uses the chart in `charts/<APP>`.
- Can be done via CLI or uploaded through OpenShift Console → **Helm** → **Releases**.
- Values in `values.yaml` control replicas, image, service port, and route settings.

---

### Step 4: Deploy Using OpenShift GitOps (Argo CD)

Edit `gitops/<APP>-app.yaml`:

```yaml
repoURL: https://github.com/<you>/<repo>.git
path: charts/<APP>
```

Then:

```bash
make bootstrap-gitops APP=demo-nginx NAMESPACE=demo-nginx   GIT_URL=https://github.com/<you>/<repo>.git   GIT_PATH=charts/demo-nginx
```

- Application will appear in OpenShift GitOps (Argo CD UI).
- Syncs changes from your Git repo automatically.

---

## 5. Common OpenShift-Specific Adjustments

- **SecurityContext**: OpenShift runs containers with arbitrary UIDs by default. Avoid hardcoding UID/GID.
- **Routes**: Use `route.enabled` in Helm values to expose apps without editing YAML manually.
- **PVCs**: Adjust `accessModes` and `storageClassName` for your cluster.
- **Health Checks**: Add readiness/liveness probes — `kompose` may not set these.

---

## 6. GitHub Integration (Optional but Recommended)

1. Initialize and push the repo:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main
```

2. Optional: Add a GitHub Actions workflow to:
   - Run `kompose` on new Compose files
   - Update generated manifests and charts
   - Push to a branch watched by Argo CD

---

## 7. Troubleshooting

- **Pod fails to start**: Check `oc logs <pod>` and `oc describe <pod>` for SCC or image errors.
- **Service not reachable**: Ensure Route exists and targets correct Service port.
- **Helm upgrade fails**: Delete release (`helm uninstall <name>`) and redeploy.

---

## 8. Cleanup

```bash
helm uninstall demo-nginx -n demo-nginx || true
oc delete project demo-nginx || true
oc delete -f generated/k8s/demo-nginx/all-in-one.yaml -n demo-nginx || true
```

---

## 9. Best Practices for Learning

- Start with stateless apps (nginx, httpd, simple APIs).
- Incrementally add complexity: PVCs, secrets, environment configs.
- Compare raw YAML vs. Helm chart to understand templating benefits.
- Use GitOps last — once you trust your manifests/charts.

---

Happy learning — and remember: OpenShift isn't just Kubernetes with a red hat, it’s Kubernetes with opinions, so lean into them.
