# Part 7 – Security Fundamentals and Registry-Centric Workflows

You've built secure containers, optimized performance, and mastered debugging. Now it's time to think about the complete lifecycle—from code commit to production deployment—with a focus on security and registry workflows.

This part transforms how you think about container security, moving beyond basic hardening to advanced concepts like image signing, provenance, and secrets management. You'll also design a complete CI/CD pipeline that builds, scans, and pushes images to a registry, ready for deployment.

By the end, you'll have a professional-grade container workflow that meets enterprise security requirements.

## 7.1 The Security Maturity Model

Understanding where you are on the security journey helps you know what to prioritize:

| Level | Description | Key Practices |
|-------|-------------|---------------|
| **Level 1: Basic** | Containers work, but minimal security | Root user, latest tags, no scanning |
| **Level 2: Production** | Standard security practices | Non-root user, specific versions, basic scanning |
| **Level 3: Hardened** | Defense in depth | Read-only FS, capability dropping, image signing |
| **Level 4: Enterprise** | Zero-trust security | SBOM, provenance, policy enforcement, secrets vault |

Let's move from Level 2 to Level 4.

## 7.2 Image Signing and Provenance

### Why Sign Images?

Image signing ensures that:
- Images come from a trusted source (not tampered with)
- Images haven't been modified after build
- You know exactly what's in the image

### Signing with Cosign (Sigstore)

**Install Cosign:**
```bash
# macOS
brew install sigstore/tap/cosign

# Linux
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
chmod +x cosign-linux-amd64
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
```

**Generate key pair:**
```bash
cosign generate-key-pair
```
```
Private key written to cosign.key
Public key written to cosign.pub
```

**Build and sign image:**
```bash
# Build image
docker build -t ghcr.io/username/app:v1.0.0 .

# Push to registry
docker push ghcr.io/username/app:v1.0.0

# Sign the image
cosign sign ghcr.io/username/app:v1.0.0 \
  --key cosign.key \
  --yes
```

**Verify signature:**
```bash
cosign verify ghcr.io/username/app:v1.0.0 \
  --key cosign.pub \
  --yes
```
```
Verification for ghcr.io/username/app:v1.0.0 --
The following checks were performed on each signature:
  - The cosign claims were validated
  - The signatures were verified against the specified public key
{"Critical":{"Identity":{"docker-reference":""},"Image":{"Docker-manifest-digest":"sha256:..."},"Type":"cosign container image signature"},"Optional":null}
```

### Automated Signing in CI/CD

**`.github/workflows/sign.yml`:**
```yaml
name: Build, Sign, and Push

on:
  push:
    tags:
      - 'v*'

jobs:
  build-and-sign:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:${{ github.ref_name }}
            ghcr.io/${{ github.repository }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Install Cosign
        uses: sigstore/cosign-installer@v3
      
      - name: Sign image
        run: |
          cosign sign \
            --key env://COSIGN_PRIVATE_KEY \
            ghcr.io/${{ github.repository }}:${{ github.ref_name }}
        env:
          COSIGN_PRIVATE_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
          COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
```

### Software Bill of Materials (SBOM)

**Generate SBOM with Syft:**
```bash
# Install Syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Generate SBOM
syft ghcr.io/username/app:v1.0.0 -o spdx-json > sbom.json
```

**Generate SBOM in CI:**
```yaml
- name: Generate SBOM
  uses: anchore/sbom-action@v0
  with:
    image: ghcr.io/${{ github.repository }}:${{ github.ref_name }}
    output-file: sbom.spdx.json
    format: spdx-json

- name: Upload SBOM to registry
  run: |
    cosign attest --key env://COSIGN_PRIVATE_KEY \
      --predicate sbom.spdx.json \
      ghcr.io/${{ github.repository }}:${{ github.ref_name }}
```

### Trust Policy

**`policy.yml`:**
```yaml
# cosign policy
apiVersion: policy.sigstore.dev/v1beta1
kind: ClusterImagePolicy
metadata:
  name: image-policy
spec:
  images:
  - glob: "ghcr.io/mycompany/*"
  authorities:
  - key:
      kms: "hashivault://cosign-key"
    attestations:
    - name: must-have-sbom
      predicateType: spdx
      policy:
        type: cue
        data: |
          predicatedType: "spdx"
          predicate: {
            SPDXID: string
            name: string
            documentNamespace: string
          }
```

## 7.3 Advanced Secrets Management

### Docker Secrets (Swarm Mode)

Docker secrets provide encrypted storage for sensitive data.

**Create a secret:**
```bash
# From a string
echo "my-secret-password" | docker secret create db_password -

# From a file
docker secret create db_password ./secrets/db_password.txt
```

**Use in service:**
```yaml
version: '3.8'

services:
  backend:
    image: backend:latest
    secrets:
      - db_password
      - api_key
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    external: true
  api_key:
    file: ./secrets/api_key.txt
```

**Read secret in application:**
```python
import os

# Read secret from file (Swarm)
def get_secret(secret_name):
    try:
        with open(f'/run/secrets/{secret_name}', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        # Fallback to environment variable (development)
        return os.getenv(secret_name.upper())

db_password = get_secret('db_password')
```

### HashiCorp Vault Integration

**Vault Agent Sidecar:**
```yaml
services:
  backend:
    image: backend:latest
    volumes:
      - ./vault-agent-config.hcl:/vault/config/config.hcl
    environment:
      - VAULT_ADDR=http://vault:8200
      - VAULT_TOKEN=${VAULT_TOKEN}
    command: |
      sh -c "vault agent -config=/vault/config/config.hcl &
             sleep 5 &&
             python app.py"

  vault:
    image: hashicorp/vault:latest
    container_name: vault
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_DEV_ROOT_TOKEN_ID=root
      - VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200
    ports:
      - "8200:8200"
    volumes:
      - ./vault/config:/vault/config
```

**`vault-agent-config.hcl`:**
```hcl
pid_file = "/tmp/vault-agent-pid"

vault {
  address = "http://vault:8200"
  token   = "root"  # In production, use AppRole or K8s auth
}

auto_auth {
  method {
    type = "token"
    config {
      token = "root"
    }
  }
}

template {
  destination = "/app/secrets/env"
  contents = <<EOH
DB_PASSWORD={{ with secret "secret/data/db" }}{{ .Data.data.password }}{{ end }}
API_KEY={{ with secret "secret/data/api" }}{{ .Data.data.key }}{{ end }}
EOH
  
  command = "source /app/secrets/env && python app.py"
}
```

### AWS Secrets Manager Integration

```python
import boto3
import json
import os

def get_secret_aws(secret_name):
    """Fetch secret from AWS Secrets Manager."""
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=os.getenv('AWS_REGION', 'us-east-1')
    )
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except Exception as e:
        print(f"Error fetching secret: {e}")
        return None

# Usage
secrets = get_secret_aws('myapp/production/db')
db_password = secrets.get('password')
```

## 7.4 Registry Strategies

### Choosing a Registry

| Registry | Best For | Key Features |
|----------|----------|--------------|
| **Docker Hub** | Open source, public images | Free public repos, Docker official images |
| **GitHub Container Registry (GHCR)** | GitHub users | Integrated with GitHub Actions, free private repos |
| **AWS ECR** | AWS deployments | Deep AWS integration, IAM auth |
| **Google Artifact Registry** | GCP deployments | Integrated with GCP services |
| **Azure Container Registry** | Azure deployments | Integrated with Azure services |
| **Harbor** | Self-hosted | Open source, vulnerability scanning |
| **JFrog Artifactory** | Enterprise | Universal artifact management |

### Tagging Strategy

**Semantic Versioning:**
```yaml
# Build tags
- v1.0.0          # Release version
- v1.0.0-alpha.1  # Pre-release
- v1.0.0-rc.1     # Release candidate

# Environment tags
- latest          # Latest stable (use carefully)
- stable          # Stable version
- staging         # Staging environment
- production      # Production environment

# Git reference tags
- main-abc123     # Branch + commit SHA
- pr-42           # Pull request number
- feature-xyz     # Feature branch name

# Date tags
- 2024-01-15      # Build date
- 2024-01-15-abc123  # Date + commit SHA
```

**Automated tagging in CI:**
```yaml
- name: Generate tags
  id: tags
  uses: docker/metadata-action@v4
  with:
    images: ghcr.io/mycompany/app
    tags: |
      type=ref,event=branch
      type=ref,event=pr
      type=semver,pattern={{version}}
      type=semver,pattern={{major}}.{{minor}}
      type=sha,prefix={{branch}}-,format=short
      type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}
```

### Registry Cleanup Policies

**`registry-cleanup.sh`:**
```bash
#!/bin/bash
# Cleanup script for container registry

REGISTRY="ghcr.io"
REPO="mycompany/app"
DAYS_KEEP=30

# Get list of tags older than DAYS_KEEP
echo "Finding tags older than $DAYS_KEEP days..."

TAGS_TO_DELETE=$(gh api "/user/packages/container/$REPO/versions" \
  --paginate \
  --jq ".[] | select(.created_at < \"$(date -d "$DAYS_KEEP days ago" -Iseconds)\") | .id")

for tag in $TAGS_TO_DELETE; do
    echo "Deleting tag $tag"
    gh api -X DELETE "/user/packages/container/$REPO/versions/$tag"
done

echo "Cleanup complete!"
```

### Registry Mirroring

**`docker-compose.mirror.yml`:**
```yaml
services:
  registry-mirror:
    image: registry:2
    environment:
      - REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io
    volumes:
      - mirror-data:/var/lib/registry
    ports:
      - "5000:5000"
    restart: unless-stopped

volumes:
  mirror-data:
```

**Use the mirror:**
```bash
# Configure Docker to use mirror
echo '{
  "registry-mirrors": ["http://localhost:5000"]
}' | sudo tee /etc/docker/daemon.json
```

## 7.5 Advanced Security Scanning

### Continuous Scanning Pipeline

**`.github/workflows/security-scan.yml`:**
```yaml
name: Security Scan

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'  # Daily scan

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t app:scan .
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'app:scan'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'
      
      - name: Scan with Grype
        uses: anchore/grype-action@v0
        with:
          image: 'app:scan'
          fail-on: high
          output: grype-results.json
      
      - name: Scan dependencies
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'deps-results.sarif'
      
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: '*.sarif'
      
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          image: 'app:scan'
          output-file: 'sbom.spdx.json'
      
      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: sbom.spdx.json
```

### Policy Enforcement with OPA

**`policy.rego`:**
```rego
package main

deny[msg] {
    input.image.vulnerabilities.count > 0
    msg = sprintf("Image contains %d vulnerabilities", [input.image.vulnerabilities.count])
}

deny[msg] {
    input.image.label != "verified"
    msg = "Image must be verified (signed)"
}

deny[msg] {
    not input.image.sbom
    msg = "Image must have an SBOM"
}

allow[msg] {
    input.image.vulnerabilities.count == 0
    input.image.label == "verified"
    input.image.sbom
    msg = "Image meets security requirements"
}
```

**`docker-compose.policy.yml`:**
```yaml
services:
  policy-enforcer:
    image: openpolicyagent/opa:latest
    volumes:
      - ./policy.rego:/policy/policy.rego
    command: eval --data /policy/policy.rego
    environment:
      - OPA_DATA=/policy
```

## 7.6 Complete CI/CD Workflow

### Production Pipeline: Build → Scan → Sign → Deploy

**`.github/workflows/production.yml`:**
```yaml
name: Production Build & Deploy

on:
  push:
    tags:
      - 'v*.*.*'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  ENVIRONMENT: production

jobs:
  # ============================================================
  # Job 1: Build and Test
  # ============================================================
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # ============================================================
  # Job 2: Security Scan
  # ============================================================
  security-scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Log in to Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'
          ignore-unfixed: true
      
      - name: Fail if vulnerabilities found
        run: |
          if jq -e '.runs[].results | length > 0' trivy-results.sarif; then
            echo "High/Critical vulnerabilities found!"
            exit 1
          fi
      
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          image: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}
          output-file: 'sbom.spdx.json'
      
      - name: Attach SBOM
        run: |
          cosign attach sbom --sbom sbom.spdx.json \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}

  # ============================================================
  # Job 3: Sign Image
  # ============================================================
  sign:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    steps:
      - name: Install Cosign
        uses: sigstore/cosign-installer@v3
      
      - name: Log in to Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Sign image
        run: |
          cosign sign \
            --key env://COSIGN_PRIVATE_KEY \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}
        env:
          COSIGN_PRIVATE_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
          COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
      
      - name: Verify signature
        run: |
          cosign verify \
            --key cosign.pub \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}
      
      - name: Create signed attestation
        run: |
          cosign attest \
            --key env://COSIGN_PRIVATE_KEY \
            --predicate ./metadata.json \
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}

  # ============================================================
  # Job 4: Deploy to Production
  # ============================================================
  deploy:
    needs: sign
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy with verified image
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.PRODUCTION_HOST }}
          username: ${{ secrets.PRODUCTION_USER }}
          key: ${{ secrets.PRODUCTION_SSH_KEY }}
          script: |
            # Pull the image
            docker pull ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }}
            
            # Verify signature
            cosign verify \
              --key /etc/cosign/cosign.pub \
              ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.ref_name }} \
              || exit 1
            
            # Deploy
            cd /app
            docker compose down
            docker compose pull
            docker compose up -d
            
            # Verify deployment
            sleep 10
            if curl -s -f http://localhost/health; then
              echo "✅ Deployment successful"
            else
              echo "❌ Deployment failed, rolling back..."
              docker compose down
              docker compose up -d
              exit 1
            fi
```

### Production Environment Configuration

**`kubernetes/deployment.yaml` (with verification):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: production
  annotations:
    cosign.sigstore.dev/attestation: |
      {
        "mediaType": "application/vnd.dev.sigstore.bundle+json",
        "digest": "sha256:..."
      }
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
      annotations:
        cosign.sigstore.dev/policy: "verified"
    spec:
      containers:
      - name: app
        image: ghcr.io/mycompany/app:v1.0.0
        securityContext:
          runAsNonRoot: true
          runAsUser: 1001
          readOnlyRootFilesystem: true
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        resources:
          limits:
            memory: 512Mi
            cpu: 500m
          requests:
            memory: 256Mi
            cpu: 250m
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
```

## 7.7 Image Promotion Strategy

### Promotion Workflow

**`.github/workflows/promote.yml`:**
```yaml
name: Promote Image

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to promote (e.g., v1.0.0)'
        required: true
      environment:
        description: 'Target environment (staging/production)'
        required: true
        default: 'staging'

jobs:
  promote:
    runs-on: ubuntu-latest
    steps:
      - name: Log in to Registry
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Verify image exists
        run: |
          docker manifest inspect ghcr.io/${{ github.repository }}:${{ github.event.inputs.version }}
      
      - name: Verify image is signed
        run: |
          cosign verify \
            --key cosign.pub \
            ghcr.io/${{ github.repository }}:${{ github.event.inputs.version }}
      
      - name: Promote to environment
        run: |
          # Tag for target environment
          docker tag \
            ghcr.io/${{ github.repository }}:${{ github.event.inputs.version }} \
            ghcr.io/${{ github.repository }}:${{ github.event.inputs.environment }}
          
          docker push ghcr.io/${{ github.repository }}:${{ github.event.inputs.environment }}
          
          # Sign environment tag
          cosign sign \
            --key env://COSIGN_PRIVATE_KEY \
            ghcr.io/${{ github.repository }}:${{ github.event.inputs.environment }}
      
      - name: Deploy to environment
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets[format('{0}_HOST', github.event.inputs.environment)] }}
          username: ${{ secrets[format('{0}_USER', github.event.inputs.environment)] }}
          key: ${{ secrets[format('{0}_SSH_KEY', github.event.inputs.environment)] }}
          script: |
            cd /app
            docker compose pull
            docker compose up -d --force-recreate
```

## 7.8 Compliance and Auditing

### Audit Logging

**`audit-logger.py`:**
```python
import json
import hashlib
import os
from datetime import datetime

class AuditLogger:
    def __init__(self, log_file='/var/log/audit.log'):
        self.log_file = log_file
        self.create_log()
    
    def create_log(self):
        if not os.path.exists(self.log_file):
            with open(self.log_file, 'w') as f:
                f.write('[]')
    
    def log_event(self, event_type, user, resource, action, details=None):
        """Log an audit event."""
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'user': user,
            'resource': resource,
            'action': action,
            'details': details,
            'hash': self.calculate_hash(event_type, user, resource, action)
        }
        
        with open(self.log_file, 'r') as f:
            logs = json.load(f)
        
        logs.append(event)
        
        with open(self.log_file, 'w') as f:
            json.dump(logs, f, indent=2)
        
        # Also log to stdout for Docker logging
        print(json.dumps(event))
    
    def calculate_hash(self, *args):
        """Create tamper-proof hash of event."""
        chain = ''.join(str(arg) for arg in args)
        return hashlib.sha256(chain.encode()).hexdigest()

# Usage
audit = AuditLogger()

# Log deployment events
audit.log_event(
    'deployment',
    'deploy-robot',
    'app-v1.0.0',
    'deploy',
    {'environment': 'production', 'replicas': 3}
)

# Log image pulls
audit.log_event(
    'image_pull',
    'kubernetes-node',
    'ghcr.io/myapp/app:v1.0.0',
    'pull',
    {'node': 'k8s-node-01', 'digest': 'sha256:...'}
)
```

### Compliance Reports

**`generate-compliance-report.sh`:**
```bash
#!/bin/bash
# Generate compliance report for audit

REPORT_FILE="compliance-report-$(date +%Y%m%d).json"

# Collect SBOM
echo "Collecting SBOM..."
docker run --rm anchore/syft:latest \
  ghcr.io/mycompany/app:latest \
  -o spdx-json > $REPORT_FILE

# Add vulnerability report
echo "Adding vulnerability data..."
trivy image ghcr.io/mycompany/app:latest \
  --format json \
  --severity HIGH,CRITICAL \
  --ignore-unfixed >> $REPORT_FILE

# Add signature verification
echo "Adding signature verification..."
cosign verify --key cosign.pub ghcr.io/mycompany/app:latest >> $REPORT_FILE

# Generate summary
echo "Generating summary..."
jq -n \
  --slurpfile sbom $REPORT_FILE \
  --arg date "$(date)" \
  '{
    "report_date": $date,
    "image": "ghcr.io/mycompany/app:latest",
    "sbom": $sbom[0],
    "vulnerabilities": $sbom[1],
    "signature_verified": true
  }' > $REPORT_FILE

echo "Report generated: $REPORT_FILE"
```

## 7.9 Lab: Build a Secure CI/CD Pipeline

### Part 1: Set Up Registry and Secrets

```bash
# 1. Create GitHub Container Registry secrets
# Go to GitHub repo -> Settings -> Secrets and variables -> Actions

# Add these secrets:
# COSIGN_PRIVATE_KEY: Your Cosign private key
# COSIGN_PASSWORD: Password for private key
# PRODUCTION_HOST: Production server IP
# PRODUCTION_USER: SSH username
# PRODUCTION_SSH_KEY: SSH private key
```

### Part 2: Create the Pipeline

**`.github/workflows/secure-pipeline.yml`:**
```yaml
name: Secure Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t app:scan .
      
      - name: Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'app:scan'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'
      
      - name: Check for critical vulnerabilities
        run: |
          if jq -e '.runs[].results[] | select(.level == "error")' trivy-results.sarif; then
            echo "❌ Critical vulnerabilities found!"
            exit 1
          fi
          echo "✅ No critical vulnerabilities"
      
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          image: 'app:scan'
          output-file: 'sbom.spdx.json'
      
      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: sbom.spdx.json

  build-and-push:
    needs: security-scan
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to GHCR
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Sign image
        uses: sigstore/cosign-installer@v3
        with:
          cosign-release: 'v2.0.0'
      
      - name: Sign with Cosign
        run: |
          cosign sign \
            --key env://COSIGN_PRIVATE_KEY \
            ghcr.io/${{ github.repository }}:latest \
            ghcr.io/${{ github.repository }}:${{ github.sha }}
        env:
          COSIGN_PRIVATE_KEY: ${{ secrets.COSIGN_PRIVATE_KEY }}
          COSIGN_PASSWORD: ${{ secrets.COSIGN_PASSWORD }}
```

### Part 3: Test the Pipeline

```bash
# 1. Make a change and push to main
git add .
git commit -m "Test security pipeline"
git push origin main

# 2. Check Actions tab for pipeline run

# 3. Verify image is signed
cosign verify --key cosign.pub ghcr.io/username/repo:latest

# 4. Deploy to staging
gh workflow run promote.yml -f version=latest -f environment=staging
```

## 7.10 Summary

You've mastered enterprise-grade container security and registry workflows:

**Security:**
- ✅ Image signing with Cosign/Sigstore
- ✅ Software Bill of Materials (SBOM)
- ✅ Advanced secrets management (Vault, AWS Secrets Manager)
- ✅ Trust policies and verification
- ✅ Vulnerability scanning automation

**Registry:**
- ✅ Registry selection and strategy
- ✅ Tagging best practices
- ✅ Registry cleanup and mirroring
- ✅ Image promotion workflows

**CI/CD:**
- ✅ Complete production pipeline
- ✅ Security scanning integration
- ✅ Image signing automation
- ✅ Deployment with verification

**Mental Models:**
- **Trust but verify**: Always verify images before deployment
- **Defense in depth**: Multiple layers of security throughout the pipeline
- **Provenance matters**: Know where your images come from and what's in them
- **Automate everything**: Security should be built into CI/CD, not added later

**What's Next:** Part 8 is the grand finale—moving from single-host Docker to orchestration. You'll understand why orchestration matters, explore Docker Swarm and Kubernetes concepts, and prepare for the next level of container management.
