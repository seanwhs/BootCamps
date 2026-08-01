# Appendix F: Complete Environment Setup & Prerequisites Guide
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Development Environment Reference

## Overview

This appendix provides a complete guide to setting up the development and production environment for the entire security architecture. It includes all prerequisites, installation steps, configuration files, and verification procedures.

---

## 1. Hardware & Infrastructure Requirements

### 1.1 Development Environment

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| **CPU** | 8 cores | 16+ cores | For running multiple containers |
| **Memory** | 16 GB | 32+ GB | For Kubernetes and security tools |
| **Storage** | 100 GB SSD | 250+ GB SSD | For images, logs, and data |
| **Network** | 100 Mbps | 1 Gbps | For pulling images and cloud access |
| **OS** | Linux (Ubuntu 22.04+) | Linux (Ubuntu 22.04+) | WSL2 for Windows, Docker for Mac |

### 1.2 Production Environment

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|-------|
| **Kubernetes Nodes** | 3 nodes | 5+ nodes | For HA and redundancy |
| **CPU per Node** | 4 cores | 8+ cores | For workloads and security tools |
| **Memory per Node** | 16 GB | 32+ GB | For containers and sidecars |
| **Storage per Node** | 100 GB | 250+ GB SSD | For persistent data |
| **Network** | 1 Gbps | 10 Gbps | For east-west traffic |

### 1.3 Cloud Account Requirements

| Cloud Provider | Required Services | Cost Estimate |
|----------------|-------------------|---------------|
| **AWS** | EKS, RDS, S3, Security Hub, GuardDuty, CloudTrail | $5K-10K/month |
| **Azure** | AKS, SQL, Blob, Security Center, Sentinel | $5K-10K/month |

---

## 2. Software Installation Guide

### 2.1 Core Tools

#### Kubernetes & Container Tools

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install minikube (for local development)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install kind (Kubernetes in Docker)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

#### Infrastructure as Code Tools

```bash
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install Terragrunt
curl -LO https://github.com/gruntwork-io/terragrunt/releases/download/v0.48.6/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
```

#### Security Tools

```bash
# Install OPA
curl -L -o opa https://openpolicyagent.org/downloads/v0.60.0/opa_linux_amd64
chmod +x opa
sudo mv opa /usr/local/bin/

# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Install Terrascan
curl -L -o terrascan https://github.com/tenable/terrascan/releases/download/v1.18.0/terrascan_1.18.0_Linux_x86_64.tar.gz
tar -xzf terrascan_1.18.0_Linux_x86_64.tar.gz
sudo mv terrascan /usr/local/bin/

# Install Checkov
pip3 install checkov

# Install Kube-bench
git clone https://github.com/aquasecurity/kube-bench.git
cd kube-bench
docker build -t kube-bench:latest .

# Install Falco
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main" | sudo tee /etc/apt/sources.list.d/falcosecurity.list
sudo apt update && sudo apt install falco
```

### 2.2 Cloud CLI Tools

#### AWS CLI

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS
aws configure
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region name: us-east-1
# Default output format: json
```

#### Azure CLI

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Set subscription
az account set --subscription <subscription-id>
```

### 2.3 Development Tools

```bash
# Install Python 3.11+
sudo apt update
sudo apt install python3.11 python3-pip -y
python3 -m pip install --upgrade pip

# Install Node.js for API security tools
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install jq for JSON processing
sudo apt install jq -y

# Install yq for YAML processing
sudo snap install yq

# Install git
sudo apt install git -y

# Install VSCode or preferred IDE
# Download from https://code.visualstudio.com/
```

### 2.4 Python Dependencies

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install required Python packages
pip install -r requirements.txt
```

**File:** `requirements.txt`

```
# Core Dependencies
flask==3.0.0
flask-cors==4.0.0
requests==2.31.0
redis==5.0.1
pyyaml==6.0.1
jsonpickle==3.0.2
python-dotenv==1.0.0

# Kubernetes
kubernetes==28.1.0

# Cloud SDKs
boto3==1.34.0
azure-storage-blob==12.19.0
azure-identity==1.15.0

# Vault
hvac==2.1.0

# Elasticsearch
elasticsearch==8.10.0

# JWT
jose==1.0.0
pyjwt==2.8.0
cryptography==41.0.7

# Data Analysis
pandas==2.1.0
numpy==1.26.0
plotly==5.18.0

# Notebooks
jupyter==1.0.0
ipython==8.17.0

# Testing
pytest==7.4.0
pytest-cov==4.1.0

# Monitoring
prometheus-client==0.19.0

# Utils
click==8.1.7
colorama==0.4.6
tabulate==0.9.0
```

---

## 3. Kubernetes Cluster Setup

### 3.1 Local Development (Minikube)

```bash
# Start Minikube
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard

# Verify cluster
kubectl cluster-info
kubectl get nodes

# Set Docker environment
eval $(minikube docker-env)
```

### 3.2 Production (EKS/AKS)

#### AWS EKS Setup

```bash
# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Create EKS cluster
eksctl create cluster \
  --name nexus-security \
  --version 1.28 \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 3 \
  --nodes-max 6 \
  --managed

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name nexus-security

# Verify
kubectl get nodes
```

#### Azure AKS Setup

```bash
# Create AKS cluster
az aks create \
  --resource-group nexus-security \
  --name nexus-aks \
  --node-count 3 \
  --node-vm-size Standard_B2s \
  --enable-addons monitoring \
  --network-plugin azure

# Get credentials
az aks get-credentials --resource-group nexus-security --name nexus-aks

# Verify
kubectl get nodes
```

### 3.3 Istio Installation

```bash
# Download Istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
cd istio-1.20.0

# Install Istio with demo profile
./bin/istioctl install --set profile=demo -y

# Label namespace for sidecar injection
kubectl label namespace default istio-injection=enabled
kubectl label namespace production istio-injection=enabled
kubectl label namespace rd istio-injection=enabled

# Verify installation
./bin/istioctl verify-install
```

### 3.4 Ingress Controller Setup

```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/cloud/deploy.yaml

# Wait for ingress controller
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Get ingress IP
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

---

## 4. Security Tool Configuration

### 4.1 Environment Variables

**File:** `.env`

```bash
# ====================================================================
# CLOUD PROVIDERS
# ====================================================================
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_DEFAULT_REGION=us-east-1

AZURE_SUBSCRIPTION_ID=your-azure-subscription-id
AZURE_TENANT_ID=your-azure-tenant-id
AZURE_CLIENT_ID=your-azure-client-id
AZURE_CLIENT_SECRET=your-azure-client-secret

# ====================================================================
# IDENTITY PROVIDER (Keycloak)
# ====================================================================
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=nexus-cloud-2026!!
KEYCLOAK_REALM=nexus
KEYCLOAK_URL=https://auth.nexus.com

# ====================================================================
# SECRETS MANAGEMENT (Vault)
# ====================================================================
VAULT_ADDR=https://vault.nexus.com:8200
VAULT_TOKEN=your-vault-root-token

# ====================================================================
# SIEM (ELK Stack)
# ====================================================================
ELASTICSEARCH_HOST=https://elasticsearch:9200
ELASTICSEARCH_USER=elastic
ELASTICSEARCH_PASSWORD=elastic-password
KIBANA_URL=http://kibana:5601
LOGSTASH_URL=http://logstash:5044

# ====================================================================
# XDR (CrowdStrike)
# ====================================================================
CROWDSTRIKE_CLIENT_ID=your-crowdstrike-client-id
CROWDSTRIKE_CLIENT_SECRET=your-crowdstrike-client-secret
CROWDSTRIKE_BASE_URL=https://api.crowdstrike.com

# ====================================================================
# SOAR (TheHive/Cortex)
# ====================================================================
THEHIVE_API_KEY=your-thehive-api-key
THEHIVE_URL=https://thehive.nexus.com
CORTEX_URL=https://cortex.nexus.com

# ====================================================================
# COMMUNICATION
# ====================================================================
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/your-webhook
PAGERDUTY_INTEGRATION_KEY=your-pagerduty-key

# ====================================================================
# CHAOS ENGINEERING
# ====================================================================
GREMLIN_API_KEY=your-gremlin-api-key
GREMLIN_TEAM_ID=your-gremlin-team-id

# ====================================================================
# API GATEWAY
# ====================================================================
KONG_ADMIN_URL=http://kong-admin:8001
KONG_PROXY_URL=http://kong-proxy:8000

# ====================================================================
# DATABASE
# ====================================================================
POSTGRES_HOST=postgresql.default.svc.cluster.local
POSTGRES_PORT=5432
POSTGRES_USER=nexus
POSTGRES_PASSWORD=postgres-password

# ====================================================================
# REDIS
# ====================================================================
REDIS_HOST=redis.default.svc.cluster.local
REDIS_PORT=6379
REDIS_PASSWORD=redis-password

# ====================================================================
# APPLICATION
# ====================================================================
APP_ENV=production
APP_DEBUG=false
APP_LOG_LEVEL=INFO
```

### 4.2 Secrets Management (Sealed Secrets)

```bash
# Install Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/controller.yaml

# Install kubeseal CLI
wget https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-linux-amd64
sudo install -m 755 kubeseal-linux-amd64 /usr/local/bin/kubeseal

# Create sealed secret
kubectl create secret generic my-secret --from-literal=key=value --dry-run=client -o yaml > secret.yaml
kubeseal -o yaml < secret.yaml > sealed-secret.yaml

# Apply sealed secret
kubectl apply -f sealed-secret.yaml
```

---

## 5. Network Configuration

### 5.1 DNS Configuration

```yaml
# DNS Records Required
auth.nexus.com      # Keycloak
vault.nexus.com     # HashiCorp Vault
api.nexus.com       # Kong API Gateway
portal.nexus.com    # Customer Portal
siem.nexus.com      # Kibana
thehive.nexus.com   # TheHive SOAR
gitlab.nexus.com    # GitLab
prometheus.nexus.com # Prometheus
grafana.nexus.com   # Grafana
```

### 5.2 Network Policies

```yaml
# Network policy for development
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dev-network
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: default
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: default
```

---

## 6. Storage Configuration

### 6.1 Persistent Volume Claims

```yaml
# Elasticsearch PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: elasticsearch-data
  namespace: siem
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: standard

# Postgres PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
  storageClassName: standard
```

### 6.2 Backup Storage

```yaml
# S3 Bucket Configuration
aws_s3:
  backup_bucket: nexus-backups
  region: us-east-1
  lifecycle:
    transition_to_glacier: 30
    expiration: 365

# Azure Blob Configuration
azure_blob:
  storage_account: nexusstorage
  container: backups
  access_tier: Cool
  lifecycle:
    tier_to_archive: 30
    delete_after: 365
```

---

## 7. Verification Checklist

### 7.1 Environment Verification

| Check | Command | Expected |
|-------|---------|----------|
| Kubernetes | `kubectl get nodes` | All nodes Ready |
| Docker | `docker version` | Client/Server running |
| Terraform | `terraform version` | v1.5.0+ |
| Python | `python3 --version` | 3.11+ |
| AWS CLI | `aws sts get-caller-identity` | Account details |
| Azure CLI | `az account show` | Subscription details |
| Kubectl | `kubectl get pods` | No errors |

### 7.2 Cluster Verification

```bash
# Check cluster health
kubectl get componentstatuses
kubectl get pods -A

# Check storage
kubectl get pv
kubectl get pvc -A

# Check network
kubectl get svc
kubectl get ingress

# Check Istio
kubectl get pods -n istio-system
istioctl analyze

# Check security policies
kubectl get networkpolicies -A
kubectl get podsecuritypolicies
```

### 7.3 Tool Verification

```bash
# Verify OPA
opa version

# Verify Trivy
trivy --version

# Verify Terrascan
terrascan version

# Verify Checkov
checkov --version

# Verify Kube-bench
docker run -it aquasec/kube-bench:latest --help

# Verify Falco
sudo falco --version
```

---

## 8. Troubleshooting Environment Setup

### 8.1 Common Installation Issues

| Issue | Resolution |
|-------|------------|
| Kubernetes not starting | Check Docker service: `sudo systemctl status docker` |
| kubectl not connecting | Verify kubeconfig: `kubectl config view` |
| Minikube memory errors | Increase memory: `minikube config set memory 8192` |
| Helm install fails | Check Helm version: `helm version` |
| Terraform init errors | Verify provider credentials |
| Python dependencies failing | Use virtual environment, check Python version |

### 8.2 Network Issues

| Issue | Resolution |
|-------|------------|
| DNS resolution failures | Check /etc/resolv.conf, use `kubectl edit cm coredns -n kube-system` |
| Ingress not working | Verify ingress controller: `kubectl get pods -n ingress-nginx` |
| SSL certificate errors | Regenerate certificates: `openssl req -x509 -newkey rsa:4096 -nodes -out cert.crt -keyout cert.key -days 365` |

### 8.3 Performance Issues

| Issue | Resolution |
|-------|------------|
| Pods not scheduling | Check resource limits: `kubectl describe node` |
| Slow image pulls | Use local registry, increase Docker cache |
| High CPU usage | Scale down replicas, review resource requests |

---

## 9. Quick Setup Script

**File:** `scripts/setup_environment.sh`

```bash
#!/bin/bash
# Environment Setup Script - Nexus Global Industries
# Run: chmod +x setup_environment.sh && ./setup_environment.sh

set -e

echo "=========================================="
echo "Nexus Global Industries - Environment Setup"
echo "=========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}kubectl not installed${NC}"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}docker not installed${NC}"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo -e "${RED}helm not installed${NC}"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}terraform not installed${NC}"; exit 1; }

echo -e "${GREEN}✓ Prerequisites OK${NC}"

# Create namespaces
echo -e "${YELLOW}Creating namespaces...${NC}"

kubectl create namespace security --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace rd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace siem --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace opa --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace kong --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✓ Namespaces created${NC}"

# Install Istio
echo -e "${YELLOW}Installing Istio...${NC}"

if ! command -v istioctl &> /dev/null; then
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -
  cd istio-1.20.0
  ./bin/istioctl install --set profile=demo -y
  cd ..
  rm -rf istio-1.20.0
else
  istioctl install --set profile=demo -y
fi

echo -e "${GREEN}✓ Istio installed${NC}"

# Install Ingress Controller
echo -e "${YELLOW}Installing Ingress Controller...${NC}"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/cloud/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

echo -e "${GREEN}✓ Ingress Controller installed${NC}"

# Install OPA
echo -e "${YELLOW}Installing OPA...${NC}"

kubectl create configmap opa-policies --from-file=zero_trust/02_pdp_policies.rego -n opa --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f zero_trust/03_pep_configuration.yaml

echo -e "${GREEN}✓ OPA installed${NC}"

# Setup environment variables
echo -e "${YELLOW}Setting up environment variables...${NC}"

if [ ! -f .env ]; then
  cp .env.example .env
  echo -e "${YELLOW}Please update .env file with your credentials${NC}"
fi

# Source environment
source .env

# Verify setup
echo -e "${YELLOW}Verifying setup...${NC}"

kubectl get nodes
kubectl get pods -A

echo -e "${GREEN}=========================================="
echo "✓ Environment setup complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Update .env file with credentials"
echo "2. Deploy security components:"
echo "   - kubectl apply -f iam/"
echo "   - kubectl apply -f zero_trust/"
echo "   - kubectl apply -f siem/"
echo "   - kubectl apply -f api/"
echo "3. Run verification scripts"
```

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX F]**

This appendix provides complete guidance for setting up the development and production environment. Follow these steps carefully to ensure all prerequisites are met before deploying the security architecture components.
