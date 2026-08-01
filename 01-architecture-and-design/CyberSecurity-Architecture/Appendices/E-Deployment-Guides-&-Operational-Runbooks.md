# Appendix E: Deployment Guides & Operational Runbooks
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Operations Reference

## Overview

This appendix provides step-by-step deployment guides and operational runbooks for all major components of the security architecture. Each guide includes prerequisites, step-by-step instructions, verification steps, and troubleshooting guides.

---

## 1. Keycloak Identity Provider Deployment

### 1.1 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Kubernetes | 1.24+ | Production-ready cluster |
| PostgreSQL | 13+ | External or in-cluster |
| TLS Certificate | Valid | For HTTPS endpoints |
| Storage Class | Any | For persistent data |

### 1.2 Deployment Steps

```bash
# Step 1: Create namespace
kubectl create namespace keycloak

# Step 2: Create secrets
kubectl create secret generic keycloak-admin \
  --from-literal=admin-user=admin \
  --from-literal=admin-password=nexus-cloud-2026!! \
  -n keycloak

kubectl create secret generic keycloak-db \
  --from-literal=database-user=keycloak \
  --from-literal=database-password=postgres-keycloak \
  -n keycloak

# Step 3: Deploy PostgreSQL
kubectl apply -f iam/01_keycloak_configuration.yaml

# Step 4: Wait for database ready
kubectl wait --for=condition=ready pod -l app=keycloak-db -n keycloak --timeout=300s

# Step 5: Deploy Keycloak
kubectl apply -f iam/01_keycloak_configuration.yaml

# Step 6: Wait for Keycloak ready
kubectl wait --for=condition=ready pod -l app=keycloak -n keycloak --timeout=300s

# Step 7: Import realm configuration
kubectl exec -it deployment/keycloak -n keycloak -- \
  /opt/keycloak/bin/kc.sh import --file /opt/keycloak/data/import/realm.json

# Step 8: Verify deployment
kubectl get pods -n keycloak
kubectl get svc -n keycloak
```

### 1.3 Verification

```bash
# Check Keycloak health
curl -k https://keycloak.nexus.com/health/live

# Test authentication
curl -X POST https://keycloak.nexus.com/realms/nexus/protocol/openid-connect/token \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=nexus-cloud-2026!!" \
  -d "grant_type=password"

# Expected: Returns JWT access token
```

### 1.4 Troubleshooting

| Issue | Resolution |
|-------|------------|
| Pod stuck in CrashLoopBackoff | Check logs: `kubectl logs -f pod/keycloak-xxx -n keycloak` |
| Database connection failed | Verify PostgreSQL credentials and service connectivity |
| Realm import failed | Check realm.json syntax: `cat iam/02_realm_configuration.json | jq .` |
| SSL certificate errors | Verify TLS certificates are valid and mounted |

---

## 2. OPA Policy Engine Deployment

### 2.1 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Kubernetes | 1.24+ | Production-ready cluster |
| Istio | 1.20+ | For sidecar integration |

### 2.2 Deployment Steps

```bash
# Step 1: Create namespace
kubectl create namespace opa

# Step 2: Create ConfigMap with policies
kubectl create configmap opa-policies \
  --from-file=zero_trust/02_pdp_policies.rego \
  -n opa

# Step 3: Deploy OPA server
kubectl apply -f zero_trust/03_pep_configuration.yaml

# Step 4: Wait for OPA ready
kubectl wait --for=condition=ready pod -l app=opa-server -n opa --timeout=300s

# Step 5: Test OPA
kubectl run -it --rm test-opa --image=curlimages/curl -n opa -- \
  curl -X POST -H "Content-Type: application/json" \
  -d '{"input": {"user": {"authenticated": true, "mfa_enabled": true}}}' \
  http://opa-server:8181/v1/data/nexus/zero_trust/allow

# Step 6: Configure Istio sidecar injection
kubectl label namespace default istio-injection=enabled
kubectl annotate namespace default sidecar.istio.io/inject=true
```

### 2.3 Verification

```bash
# Check OPA health
kubectl get pods -n opa
curl -s http://localhost:8181/health

# Test policy evaluation
curl -X POST http://localhost:8181/v1/data/nexus/zero_trust/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"user": {"authenticated": true, "mfa_enabled": true, "role": "admin"}, "resource": {"classification": "restricted"}, "device": {"posture": "compliant"}}}'
```

### 2.4 Troubleshooting

| Issue | Resolution |
|-------|------------|
| OPA not responding | Check logs: `kubectl logs -f deployment/opa-server -n opa` |
| Policy evaluation errors | Validate Rego syntax: `opa check zero_trust/02_pdp_policies.rego` |
| Istio sidecar not injecting | Verify namespace label: `kubectl get ns default --show-labels` |

---

## 3. HashiCorp Vault Deployment

### 3.1 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Kubernetes | 1.24+ | Production-ready cluster |
| Consul | 1.14+ | For HA storage |

### 3.2 Deployment Steps

```bash
# Step 1: Create namespace
kubectl create namespace vault

# Step 2: Deploy Vault
kubectl apply -f pam/02_vault_deployment.yaml

# Step 3: Wait for Vault ready
kubectl wait --for=condition=ready pod -l app=vault -n vault --timeout=300s

# Step 4: Initialize Vault
kubectl exec -it vault-0 -n vault -- vault operator init -format=json > vault-keys.json

# Step 5: Unseal Vault
UNSEAL_KEYS=$(cat vault-keys.json | jq -r '.unseal_keys_b64[]')
for key in $(echo $UNSEAL_KEYS); do
  kubectl exec -it vault-0 -n vault -- vault operator unseal $key
done

# Step 6: Get root token
ROOT_TOKEN=$(cat vault-keys.json | jq -r '.root_token')

# Step 7: Enable Kubernetes auth
kubectl exec -it vault-0 -n vault -- vault auth enable kubernetes

# Step 8: Configure Kubernetes auth
kubectl exec -it vault-0 -n vault -- vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc"
```

### 3.3 Verification

```bash
# Check Vault status
kubectl exec -it vault-0 -n vault -- vault status

# Verify unsealed
kubectl exec -it vault-0 -n vault -- vault status | grep Sealed

# Test Vault
kubectl exec -it vault-0 -n vault -- vault kv put secret/test key=value
kubectl exec -it vault-0 -n vault -- vault kv get secret/test
```

### 3.4 Troubleshooting

| Issue | Resolution |
|-------|------------|
| Vault sealed | Run unseal steps with all keys |
| Root token lost | Regenerate: `vault operator generate-root` |
| Storage backend failed | Check Consul connectivity |
| Authentication errors | Verify service account permissions |

---

## 4. ELK Stack Deployment

### 4.1 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Kubernetes | 1.24+ | Production-ready cluster |
| Storage Class | Any | For logs and indices |

### 4.2 Deployment Steps

```bash
# Step 1: Create namespace
kubectl create namespace siem

# Step 2: Deploy Elasticsearch
kubectl apply -f siem/01_elasticsearch.yaml

# Step 3: Wait for Elasticsearch ready
kubectl wait --for=condition=ready pod -l app=elasticsearch -n siem --timeout=600s

# Step 4: Deploy Logstash
kubectl apply -f siem/02_logstash_pipelines.yaml

# Step 5: Wait for Logstash ready
kubectl wait --for=condition=ready pod -l app=logstash -n siem --timeout=300s

# Step 6: Deploy Kibana
kubectl apply -f siem/03_kibana_dashboards.yaml

# Step 7: Wait for Kibana ready
kubectl wait --for=condition=ready pod -l app=kibana -n siem --timeout=300s

# Step 8: Import dashboards
kubectl exec -it deployment/kibana -n siem -- \
  /usr/share/kibana/bin/kibana-import-dashboards

# Step 9: Create index templates
kubectl exec -it pod/elasticsearch-0 -n siem -- \
  curl -X PUT "https://localhost:9200/_index_template/security-logs" \
  -H "Content-Type: application/json" \
  -d @/usr/share/elasticsearch/config/templates/security-logs-template.json
```

### 4.3 Verification

```bash
# Check Elasticsearch health
curl -k https://elasticsearch:9200/_cluster/health

# Check Logstash pipelines
curl http://logstash:9600/_node/pipelines

# Check Kibana
curl http://kibana:5601/api/status

# Verify logs ingestion
kubectl logs -f deployment/logstash -n siem
```

### 4.4 Troubleshooting

| Issue | Resolution |
|-------|------------|
| Elasticsearch not ready | Check resource limits and storage |
| Logstash pipeline errors | Validate pipeline config: `logstash -t -f pipeline.conf` |
| Kibana not loading | Check Elasticsearch connectivity and credentials |
| Missing indices | Verify index templates and ILM policies |

---

## 5. Istio Service Mesh Deployment

### 5.1 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Kubernetes | 1.24+ | Production-ready cluster |
| Helm | 3.0+ | For Istio installation |

### 5.2 Deployment Steps

```bash
# Step 1: Download Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*

# Step 2: Install Istio
istioctl install --set profile=demo -y

# Step 3: Enable sidecar injection
kubectl label namespace default istio-injection=enabled
kubectl label namespace production istio-injection=enabled
kubectl label namespace rd istio-injection=enabled

# Step 4: Deploy authorization policies
kubectl apply -f microseg/02_istio_authorization.yaml

# Step 5: Verify installation
istioctl verify-install

# Step 6: Check sidecar injection
kubectl get ns -L istio-injection
```

### 5.3 Verification

```bash
# Check Istio components
kubectl get pods -n istio-system

# Test mTLS
kubectl exec -it deployment/sleep -n default -- \
  curl -s http://httpbin:8000/ip

# Check authorization
kubectl exec -it deployment/sleep -n default -- \
  curl -s http://payment-service:8080/api/v1/payment

# Verify telemetry
kubectl get virtualservice -n default
kubectl get destinationrule -n default
```

### 5.4 Troubleshooting

| Issue | Resolution |
|-------|------------|
| Sidecar not injected | Restart pod: `kubectl delete pod xxx` |
| mTLS errors | Verify PeerAuthentication: `kubectl get peerauthentication -A` |
| Authorization denied | Check AuthorizationPolicy: `kubectl get authorizationpolicy -A` |
| Telemetry missing | Check Envoy config: `istioctl proxy-config` |

---

## 6. Kong API Gateway Deployment

### 6.1 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Kubernetes | 1.24+ | Production-ready cluster |
| Helm | 3.0+ | For Kong installation |

### 6.2 Deployment Steps

```bash
# Step 1: Add Kong Helm repo
helm repo add kong https://charts.konghq.com
helm repo update

# Step 2: Install Kong
helm install kong kong/kong -f api/01_gateway_security.yaml

# Step 3: Wait for Kong ready
kubectl wait --for=condition=ready pod -l app=kong -n kong --timeout=300s

# Step 4: Apply Kong plugins
kubectl apply -f api/01_gateway_security.yaml

# Step 5: Deploy API services
kubectl apply -f api/01_gateway_security.yaml

# Step 6: Get Kong external IP
kubectl get svc kong-proxy -n kong
```

### 6.3 Verification

```bash
# Check Kong health
curl http://kong-proxy:8000/status

# Test API access
curl -X GET http://kong-proxy:8000/api/v1/orders \
  -H "Authorization: Bearer <JWT_TOKEN>"

# Check rate limiting
for i in {1..110}; do
  curl -s -o /dev/null -w "%{http_code}\n" http://kong-proxy:8000/api/v1/orders \
    -H "Authorization: Bearer <JWT_TOKEN>"
done
# Expected: 429 after 100 requests
```

### 6.4 Troubleshooting

| Issue | Resolution |
|-------|------------|
| Kong pods not starting | Check resource limits and image pull |
| Plugins not applying | Verify plugin configs: `kubectl get kongplugins` |
| Rate limiting not working | Check Redis connectivity: `kubectl get svc redis` |
| JWT validation failing | Verify Keycloak integration: `kubectl logs -f deployment/kong -n kong` |

---

## 7. CI/CD Pipeline Security Gates Setup

### 7.1 GitLab CI Configuration

```yaml
# .gitlab-ci.yml - Security Pipeline

stages:
  - validate
  - security-scan
  - policy-check
  - deploy

variables:
  TERRAFORM_VERSION: "1.5.0"
  TERRASCAN_VERSION: "1.18.0"
  CHECKOV_VERSION: "2.3.0"

# Security scanning stage
terraform-scan:
  stage: security-scan
  image: accurics/terrascan:${TERRASCAN_VERSION}
  script:
    - terrascan scan -i terraform -d . -o json
  artifacts:
    reports:
      terraform: terrascan-report.json
  only:
    - merge_requests
    - main

# OPA policy check
opa-policy:
  stage: policy-check
  image: openpolicyagent/opa:latest
  script:
    - opa eval -i terraform.tfplan.json -d policies/ -p terraform.aws
  only:
    - merge_requests
    - main

# Deployment (only after all checks pass)
deploy:
  stage: deploy
  image: hashicorp/terraform:${TERRAFORM_VERSION}
  script:
    - terraform plan
    - terraform apply -auto-approve
  only:
    - main
  when: manual
```

### 7.2 GitHub Actions Configuration

```yaml
# .github/workflows/terraform-security.yml

name: Terraform Security Scan

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Format
      run: terraform fmt -check -recursive
    
    - name: Terraform Validate
      run: terraform init && terraform validate
    
    - name: Run Terrascan
      uses: runatlantis/atlantis@v2
      with:
        args: terrascan scan -i terraform
    
    - name: Run Checkov
      uses: bridgecrewio/checkov-action@v12
      with:
        framework: terraform
    
    - name: Run OPA Policy
      uses: open-policy-agent/opa@v0.45.0
      with:
        args: eval -i terraform.tfplan.json -d policies/ -p terraform.aws
    
    - name: Upload Security Results
      uses: actions/upload-artifact@v3
      with:
        name: security-results
        path: |
          terrascan-report.json
          checkov-report.json
```

### 7.3 Pipeline Verification

```bash
# Trigger pipeline
git push origin main

# Check pipeline status
kubectl get pods -n gitlab --watch

# Verify security scans completed
kubectl logs -f job/terraform-scan -n gitlab
kubectl logs -f job/opa-policy -n gitlab
```

---

## 8. Chaos Engineering Setup (Gremlin)

### 8.1 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Kubernetes | 1.24+ | Production-ready cluster |
| Gremlin Account | Active | For API access |

### 8.2 Deployment Steps

```bash
# Step 1: Install Gremlin client
helm repo add gremlin https://helm.gremlin.com
helm repo update

# Step 2: Create Gremlin secret
kubectl create secret generic gremlin-secrets \
  --from-literal=api-key=<GREMLIN_API_KEY> \
  --from-literal=team-id=<GREMLIN_TEAM_ID> \
  -n gremlin

# Step 3: Deploy Gremlin
helm install gremlin gremlin/gremlin \
  --set gremlin.secret.name=gremlin-secrets \
  --set gremlin.secret.apiKeyKey=api-key \
  --set gremlin.secret.teamIdKey=team-id \
  -n gremlin

# Step 4: Deploy chaos tests
kubectl apply -f chaos/05_automation.py

# Step 5: Run test schedule
kubectl create -f chaos/01_failure_scenarios.yaml
```

### 8.3 Verification

```bash
# Check Gremlin agents
kubectl get pods -n gremlin

# Run a test attack
curl -X POST http://chaos-service:8080/api/chaos/run/CHAOS-001

# Check test status
curl http://chaos-service:8080/api/chaos/status/CHAOS-001

# Verify detection time
kubectl logs -f deployment/chaos-service -n chaos
```

### 8.4 Test Scenarios

| Scenario ID | Name | Type | Duration |
|-------------|------|------|----------|
| CHAOS-001 | Kubernetes Node Failure | Infrastructure | 5m |
| CHAOS-002 | Network Partition | Network | 3m |
| CHAOS-003 | DNS Failure | Infrastructure | 2m |
| CHAOS-004 | Database Connection Failure | Database | 5m |
| CHAOS-005 | CPU Pressure | Resource | 5m |

---

## 9. RTO/RPO Validation

### 9.1 Validation Process

```bash
# Step 1: Run RTO/RPO validation
python3 bcr/05_rpo_rto_validation.py

# Step 2: Review results
cat /reports/bcp_report_*.txt

# Step 3: Check individual system validation
# Expected output format:
# ✅ PASS - Manufacturing OT (Tier 0)
#   RTO: 95s / 7200s ✅
#   RPO: 300s / 900s ✅
```

### 9.2 Test Schedule

| Test Type | Frequency | Owner | Scope |
|-----------|-----------|-------|-------|
| Tabletop Exercise | Quarterly | BCP Coordinator | All tiers |
| Backup Recovery Test | Monthly | IT Operations | Tier 0-1 |
| Full DR Test | Bi-annual | BCP Coordinator | All tiers |
| Chaos Test | Monthly | Security Team | Resilience validation |

### 9.3 Success Criteria

```yaml
success_criteria:
  tier_0:
    rto: "2 hours"
    rpo: "15 minutes"
    systems: ["Manufacturing OT", "Customer Portal"]
  
  tier_1:
    rto: "4 hours"
    rpo: "1 hour"
    systems: ["Financial Systems", "R&D Repositories"]
  
  tier_2:
    rto: "8 hours"
    rpo: "4 hours"
    systems: ["HR Systems", "Internal Collaboration"]
  
  tier_3:
    rto: "24 hours"
    rpo: "24 hours"
    systems: ["Public Website", "Analytics"]
```

---

## 10. Quick Reference: Key Commands

### 10.1 Kubernetes Operations

```bash
# Check pod status
kubectl get pods -A

# View logs
kubectl logs -f deployment/<name> -n <namespace>

# Port forward for testing
kubectl port-forward service/<name> 8080:80 -n <namespace>

# Restart deployment
kubectl rollout restart deployment/<name> -n <namespace>

# Scale deployment
kubectl scale deployment/<name> --replicas=3 -n <namespace>
```

### 10.2 Security Operations

```bash
# Test OPA policy
curl -X POST http://opa:8181/v1/data/nexus/zero_trust/allow \
  -d '{"input": {...}}'

# Check Vault status
vault status

# Query SIEM
curl -k -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -H "Content-Type: application/json" \
  -d '{"query": {"match": {"event.severity": "CRITICAL"}}}'

# Run Chaos test
curl -X POST http://chaos-service:8080/api/chaos/run/CHAOS-001
```

### 10.3 Cloud Operations

```bash
# AWS CLI
aws s3 ls
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin
aws configservice get-compliance-summary

# Azure CLI
az account show
az monitor activity-log list --max-events 10
az security assessment list
```

---

## 11. Troubleshooting Quick Reference

| Component | Common Issues | Resolution |
|-----------|---------------|------------|
| **Keycloak** | Pod crash, DB connection, SSL errors | Check logs, verify secrets, validate certs |
| **OPA** | Policy errors, sidecar issues | Validate Rego, check Istio injection |
| **Vault** | Sealed, root token lost, auth errors | Unseal, regenerate root, verify auth config |
| **ELK** | Index missing, pipeline errors, storage full | Apply templates, check configs, scale storage |
| **Istio** | mTLS errors, auth denied, missing telemetry | Check PeerAuthentication, AuthorizationPolicy |
| **Kong** | Plugin errors, rate limiting issues, JWT failures | Verify configs, check Redis, validate JWT |
| **Gremlin** | Agent not starting, API errors | Check secrets, verify connectivity |

---

**Document Owner**: Lead Enterprise Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX E]**

This appendix provides complete deployment guides and operational runbooks for all security components. Use these guides for day-to-day operations, troubleshooting, and disaster recovery scenarios.
