# WiseCow Application - CI/CD Pipeline

A bash script-based WiseCow application with fully automated CI/CD pipeline using GitHub Actions and ArgoCD, deployed on MicroK8s cluster running on AWS EC2.

## 🏗️ Architecture Overview

```
GitHub Repository
        ↓
    Code Push
        ↓
GitHub Actions (CI)
        ↓
Docker Image Build → Docker Hub
        ↓
Auto-update k8s/deployment.yml
        ↓
ArgoCD (CD) - Monitors k8s/ folder
        ↓
MicroK8s Cluster (AWS EC2)
        ↓
WiseCow Application (NodePort)
```

**Tech Stack:**
- **Application**: Bash-based WiseCow
- **CI**: GitHub Actions (Image build, tag, push, and manifest update)
- **CD**: ArgoCD (GitOps deployment via Helm)
- **Container Registry**: Docker Hub
- **Kubernetes**: MicroK8s on AWS EC2
- **Service Type**: NodePort

## 🎯 What This Setup Does

### Continuous Integration (Automated)
When you push code changes to the repository, GitHub Actions automatically:
- Builds a new Docker image
- Tags it with incremented version (1.0.0 → 1.0.1 → 1.0.2...)
- Pushes the image to Docker Hub
- Updates `k8s/deployment.yml` with the new image tag
- Commits the changes back to the repository

### Continuous Deployment (Automated)
ArgoCD continuously monitors the repository and:
- Detects the updated deployment manifest in `k8s/` folder
- Automatically syncs changes to the cluster (every 3 minutes)
- Can also be manually synced for immediate deployment
- Service configuration remains unchanged (stable NodePort)

## 🚀 Setup Instructions

### 1. Fork and Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/wisecow.git
cd wisecow
```

### 2. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and variables → Actions):
- `DOCKERUSER`: Your Docker Hub username
- `DOCKERPASS`: Your Docker Hub password or access token
- `GIT_USER`: Your GitHub username
- `GIT_EMAIL`: Your GitHub email
- `GIT_TOKEN`: GitHub Personal Access Token (for committing changes)

### 3. Setup MicroK8s on AWS EC2

```bash
# Install MicroK8s
sudo snap install microk8s --classic

# Add user to microk8s group
sudo usermod -a -G microk8s $USER
newgrp microk8s

# Enable required addons
microk8s enable dns
microk8s enable storage
microk8s enable helm3

# Verify
microk8s status
```

### 4. Create Kubernetes Namespace

```bash
kubectl create namespace wisecow
```

### 5. Install ArgoCD using Helm

```bash
# Add ArgoCD Helm repository
microk8s helm3 repo add argo https://argoproj.github.io/argo-helm
microk8s helm3 repo update

# Install ArgoCD
microk8s helm3 install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=NodePort

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 6. Access ArgoCD UI

```bash
# Get ArgoCD NodePort
kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}'

# Access in browser (update EC2 security group to allow the port)
https://YOUR-EC2-PUBLIC-IP:ARGOCD-NODEPORT
```

Login with:
- **Username**: `admin`
- **Password**: (from previous step)

### 7. Create ArgoCD Application via UI

In the ArgoCD UI, click **"+ NEW APP"** and configure:

**General:**
- **Application Name**: `wisecow`
- **Project**: `default`
- **Sync Policy**: `Automatic` (with Self Heal and Prune enabled)

**Source:**
- **Repository URL**: `https://github.com/YOUR_USERNAME/wisecow`
- **Revision**: `HEAD` or `main`
- **Path**: `k8s`

**Destination:**
- **Cluster URL**: `https://kubernetes.default.svc`
- **Namespace**: `wisecow`

Click **CREATE** and ArgoCD will start syncing your application!

## 🔄 How It Works

### On Code Push:
1. GitHub Actions builds new Docker image with incremented version tag
2. Pushes image to Docker Hub
3. Updates `k8s/deployment.yml` with new image tag
4. Commits changes back to repository

### ArgoCD Deployment:
1. Monitors `k8s/` folder every 3 minutes
2. Detects updated `deployment.yml`
3. Applies changes to the cluster automatically
4. `service.yml` remains unchanged (NodePort stable)

## 🌐 Accessing the Application

```bash
# Get the NodePort
kubectl get svc wisecow-service -n wisecow -o jsonpath='{.spec.ports[0].nodePort}'

# Access the application
http://YOUR-EC2-PUBLIC-IP:NODE_PORT
```

**Note**: Update your EC2 security group to allow inbound traffic on the NodePort.

## 📊 Monitoring

### Check Application Status:

```bash
# Check pods
kubectl get pods -n wisecow

# Check service
kubectl get svc -n wisecow

# View logs
kubectl logs -f deployment/wisecow-deployment -n wisecow
```

### Monitor ArgoCD:

```bash
# Check sync status in UI or CLI
argocd app get wisecow

# Manual sync (if needed)
argocd app sync wisecow
```

### Check Current Image Version:

```bash
kubectl get deployment wisecow-deployment -n wisecow -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## 🔧 Troubleshooting

**Pods Not Starting:**
```bash
kubectl describe pod -n wisecow <POD_NAME>
```

**ArgoCD Not Syncing:**
```bash
# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Force refresh
argocd app get wisecow --refresh
```

**Cannot Access Application:**
- Check EC2 security group allows the NodePort
- Verify pods are running: `kubectl get pods -n wisecow`
- Test from EC2 instance: `curl localhost:NODE_PORT`

## 📁 Repository Structure

```
wisecow/
├── .github/workflows/
│   └── main.yml              # CI pipeline
├── k8s/
│   ├── deployment.yml        # Auto-updated with image tags
│   └── service.yml           # NodePort service (stable)
├── Dockerfile
├── wisecow.sh
└── README.md
```

## 📝 Key Points

- **Auto-versioning**: Images tagged as 1.0.0, 1.0.1, 1.0.2... automatically
- **Auto-sync**: ArgoCD syncs every 3 minutes or manual sync available
- **Stable service**: NodePort configuration never changes
- **GitOps**: All changes tracked in Git, deployed via ArgoCD
- **Zero downtime**: Rolling updates for deployments

## 📄 License

This project is licensed under the Apache-2.0 License.

---

**Built with GitHub Actions, ArgoCD, and MicroK8s**
