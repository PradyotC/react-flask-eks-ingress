# React + Flask Microservices on AWS EKS with Ingress

This project demonstrates a minimal yet real-world microservices architecture:
- **React frontend** (TypeScript + CSS)
- **Flask backend** (Python)
- Orchestrated on **AWS Elastic Kubernetes Service (EKS)**
- **Kubernetes Ingress** transparently routes frontend and backend traffic under a single public endpoint

---

## 🚀 Quick Start: Local Deployment

### 1. Prerequisites

- Docker installed locally
- AWS credentials (`.aws/`) configured with sufficient permissions for EKS/ECR
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (if running outside container)
- Create your `.env` file in the project root by copying `.env.format` and filling in necessary values:
    ```bash
    cp .env.format .env
    # Edit .env as needed (AWS region, cluster name, etc.)
    ```

### 2. Start the Deployment Container

**Do not build the image yourself. An image `pradyotc/eks-deployer:latest` is already published and should be pulled automatically on first use.**

```bash
docker run --rm -it \
  --env-file .env \
  -v $(pwd)/k8s-manifests:/workspace/k8s-manifests \
  pradyotc/eks-deployer:latest
```

This provides a consistent environment with all required tools and scripts pre-installed.

---

## 📦 Running the Deployment

Once inside the `eks-deployer` container’s shell:

### 1. Deploy the Stack

```bash
bash /usr/local/bin/deploy.sh
```

- This script will:
  - Create/configure the EKS cluster and supporting infrastructure
  - Deploy the microservices (React frontend, Flask backend)
  - Set up Kubernetes Services and Ingress for unified access

### 2. Access the Application

- After deployment, run:
    ```bash
    kubectl get ingress capstone-ingress
    ```
- Use the provided EXTERNAL-IP (AWS ELB endpoint) in your browser:
    - `http://<EXTERNAL-IP>/` - React frontend
    - `http://<EXTERNAL-IP>/dashboard` - Frontend dashboard
    - `http://<EXTERNAL-IP>/api/v1/health` - Flask API health endpoint

---

## 🛠️ Tearing Down the Stack

**When finished, always clean up resources to avoid AWS charges:**

From inside the container:
```bash
bash /usr/local/bin/destroy.sh
```

---

## 🔚 Clean Up Local Docker

1. **Exit** the `eks-deployer` container:
    ```bash
    exit
    ```

2. **Remove the container** (not needed if you used `--rm`).
    ```bash
    docker rm <container-id-or-name>
    ```
    _(Optional, only if container isn't auto-removed.)_

3. **Remove the local image** (optional):
    ```bash
    docker rmi pradyotc/eks-deployer:latest
    ```

---

## 🧩 Architecture Overview

```
User ──> [AWS ELB/Ingress] ──/────────> React Service (frontend)
                               \
                                └─────> Flask Service (backend)
```
- **Ingress** routes external HTTP(S) traffic by path to the right service, so end-users see a single unified app.

---

## 🗂️ Repo Structure

- `frontend/` - React (TypeScript/CSS) source code
- `backend/` - Flask (Python) source code
- `k8s-manifests/` - Kubernetes deployments, services, ingress
- `Dockerfile`, etc. - Reference Dockerfiles for each service **(for understanding or building your own images if desired)**
    - _NOTE:_ If you build your own images, **edit the image names in the Kubernetes YAML files accordingly!_
- `deploy.sh`, `destroy.sh` - Automated scripts for provisioning and cleanup  
- `important_commands.sh` - Example workflow and one-liners

---

## 📝 NOTE ON DOCKER IMAGES

- The provided image `pradyotc/eks-deployer:latest` is already published; you don't need to build it yourself.
- If you wish to customize or build your own, use the included Dockerfiles—but **update the k8s manifests** to match your new image names.
