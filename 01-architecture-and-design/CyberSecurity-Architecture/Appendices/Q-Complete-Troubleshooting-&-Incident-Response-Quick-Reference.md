# Appendix Q: Complete Troubleshooting & Incident Response Quick Reference
## Enterprise Cybersecurity Architecture & Frameworks
### Nexus Global Industries - Troubleshooting & IR Quick Reference

## Overview

This appendix provides a quick reference guide for troubleshooting common issues and responding to security incidents. Use this as a fast-reference during operational incidents and troubleshooting sessions.

---

## 1. Quick Troubleshooting Flowcharts

### 1.1 Authentication Failure

```
┌─────────────────────────────────────────────────────────────────┐
│                 AUTHENTICATION FAILURE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  User cannot login                                              │
│       │                                                         │
│       ▼                                                         │
│  Check Keycloak health                                          │
│  curl https://auth.nexus.com/health/live                       │
│       │                                                         │
│       ├── Unhealthy → Check Keycloak pods:                     │
│       │              kubectl get pods -n keycloak              │
│       │                                                        │
│       ▼                                                         │
│  Check user account                                            │
│  - Is account active?                                          │
│  - Is MFA enrolled?                                           │
│  - Is password expired?                                       │
│       │                                                         │
│       ├── Account issues → Reset password / enable account     │
│       │                                                        │
│       ▼                                                         │
│  Check OPA policies                                            │
│  curl -X POST http://opa-server:8181/v1/data/nexus/zero_trust/allow \
│    -d '{"input": {"user": {"authenticated": true}}}'          │
│       │                                                         │
│       ├── Policy denies → Check policy logs                   │
│       │                                                        │
│       ▼                                                         │
│  Check network connectivity                                    │
│  - Is Keycloak reachable?                                     │
│  - Is OPA reachable?                                          │
│  - Are there network policies blocking?                       │
│       │                                                         │
│       ├── Network issues → Check Calico policies              │
│       │                                                        │
│       ▼                                                         │
│  Check logs                                                    │
│  kubectl logs -f deployment/keycloak -n keycloak              │
│  kubectl logs -f deployment/opa-server -n opa                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 API Gateway Error

```
┌─────────────────────────────────────────────────────────────────┐
│                    API GATEWAY ERROR                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  API request fails                                              │
│       │                                                         │
│       ▼                                                         │
│  Check Kong status                                              │
│  kubectl get pods -n kong                                      │
│  curl http://kong-admin:8001/status                           │
│       │                                                         │
│       ├── Kong unhealthy → Restart Kong                       │
│       │                                                        │
│       ▼                                                         │
│  Check response status code                                    │
│       │                                                         │
│       ├── 401 Unauthorized → Check JWT token                  │
│       │   - Is token valid?                                   │
│       │   - Has token expired?                                │
│       │                                                        │
│       ├── 403 Forbidden → Check OPA policies                  │
│       │   - Does user have required permissions?              │
│       │   - Is device compliant?                              │
│       │                                                        │
│       ├── 429 Too Many Requests → Check rate limiting         │
│       │   - Is rate limit configured?                         │
│       │   - Has user exceeded limit?                          │
│       │                                                        │
│       ├── 500 Internal Error → Check backend service          │
│       │   - Is service running?                               │
│       │   - Are there errors in service logs?                 │
│       │                                                        │
│       ▼                                                         │
│  Check Kong logs                                                │
│  kubectl logs -f deployment/kong -n kong                      │
│  kubectl logs -f deployment/kong-ingress-controller -n kong   │
│                                                                 │
│  Check OPA logs                                                │
│  kubectl logs -f deployment/opa-server -n opa                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Kubernetes Pod Issues

```
┌─────────────────────────────────────────────────────────────────┐
│                 KUBERNETES POD ISSUES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Pod not running                                                │
│       │                                                         │
│       ▼                                                         │
│  Check pod status                                               │
│  kubectl get pods -n <namespace>                               │
│       │                                                         │
│       ├── Pending → Check resources                            │
│       │   - Is there enough CPU/memory?                        │
│       │   - Are there node issues?                             │
│       │                                                        │
│       ├── CrashLoopBackOff → Check logs                       │
│       │   kubectl logs <pod-name> -n <namespace>              │
│       │                                                        │
│       ├── ImagePullBackOff → Check image                      │
│       │   - Is image tag correct?                             │
│       │   - Is registry accessible?                            │
│       │   - Is image pull secret valid?                       │
│       │                                                        │
│       ├── Failed → Check event logs                           │
│       │   kubectl describe pod <pod-name> -n <namespace>      │
│       │                                                        │
│       ▼                                                         │
│  Check security policies                                       │
│  - Is Kyverno policy blocking?                                │
│  - Is Pod Security Admission blocking?                        │
│  - Is network policy blocking?                                │
│                                                                 │
│  Check Istio sidecar                                           │
│  - Is sidecar injected?                                       │
│  - Is sidecar healthy?                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.4 SIEM Log Ingestion Failure

```
┌─────────────────────────────────────────────────────────────────┐
│                  SIEM LOG INGESTION FAILURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Logs not appearing in SIEM                                     │
│       │                                                         │
│       ▼                                                         │
│  Check Logstash status                                          │
│  kubectl get pods -n siem -l app=logstash                     │
│  curl http://logstash:9600/_node/stats                        │
│       │                                                         │
│       ├── Logstash unhealthy → Restart Logstash               │
│       │                                                        │
│       ▼                                                         │
│  Check Logstash pipelines                                      │
│  kubectl logs -f deployment/logstash -n siem                  │
│       │                                                         │
│       ├── Pipeline errors → Check config                      │
│       │   kubectl get configmap logstash-pipelines -n siem    │
│       │                                                        │
│       ▼                                                         │
│  Check source logs                                             │
│  - Is source sending logs?                                    │
│  - Is source configured correctly?                            │
│  - Are there network issues?                                  │
│       │                                                         │
│       ▼                                                         │
│  Check Elasticsearch                                           │
│  curl -k https://elasticsearch:9200/_cluster/health           │
│  curl -k https://elasticsearch:9200/_cat/indices             │
│       │                                                         │
│       ├── Elasticsearch issues → Check storage                │
│       │   - Is storage full?                                  │
│       │   - Are shards healthy?                               │
│       │                                                        │
│       ▼                                                         │
│  Check Kibana                                                  │
│  curl http://kibana:5601/api/status                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Component-Specific Troubleshooting

### 2.1 Keycloak Troubleshooting

| Issue | Symptom | Resolution |
|-------|---------|------------|
| **Pod CrashLoopBackOff** | Pods restarting continuously | Check logs: `kubectl logs -f pod/keycloak-xxx -n keycloak` |
| **Database Connection Failure** | Errors in logs about DB connection | Verify PostgreSQL credentials and connectivity |
| **Realm Import Failed** | Realm not configured | Check JSON syntax, verify import file path |
| **SSL Certificate Error** | TLS handshake failures | Verify certificates are valid and mounted |
| **Token Validation Fails** | JWT invalid errors | Check issuer and audience configuration |
| **MFA Not Enforcing** | Users can login without MFA | Verify MFA policy configuration |
| **SCIM Provisioning Fails** | Users not created | Check SCIM endpoint configuration, verify permissions |

**Quick Commands:**

```bash
# Check Keycloak health
curl -k https://auth.nexus.com/health/live

# Restart Keycloak deployment
kubectl rollout restart deployment/keycloak -n keycloak

# Check Keycloak logs
kubectl logs -f deployment/keycloak -n keycloak --tail=100

# Re-import realm
kubectl exec -it deployment/keycloak -n keycloak -- \
  /opt/keycloak/bin/kc.sh import --file /opt/keycloak/data/import/realm.json

# Check Keycloak pods
kubectl get pods -n keycloak
kubectl describe pod <pod-name> -n keycloak
```

---

### 2.2 OPA Troubleshooting

| Issue | Symptom | Resolution |
|-------|---------|------------|
| **Policy Not Loading** | Policy changes not applied | Check ConfigMap: `kubectl describe configmap opa-policies -n opa` |
| **Policy Evaluation Errors** | 500 errors from OPA | Validate Rego syntax: `opa check policies.rego` |
| **High Latency** | Slow policy evaluation | Check performance: `opa eval --profile` |
| **Policy Denies Authorized** | Legitimate access denied | Check policy logic, test with `opa eval` |
| **Istio Integration Fails** | Envoy filter errors | Verify OPA service: `kubectl get svc opa-server -n opa` |

**Quick Commands:**

```bash
# Check OPA health
curl http://opa-server:8181/health

# List policies
curl http://opa-server:8181/v1/policies

# Test policy
curl -X POST http://opa-server:8181/v1/data/nexus/zero_trust/allow \
  -d '{"input": {"user": {"authenticated": true, "mfa_enabled": true}}}'

# Reload policies
kubectl delete pod -l app=opa-server -n opa

# Validate Rego
opa check zero_trust/02_pdp_policies.rego
```

---

### 2.3 Vault Troubleshooting

| Issue | Symptom | Resolution |
|-------|---------|------------|
| **Vault Sealed** | Vault not responding | Unseal Vault with unseal keys |
| **Token Expired** | Auth errors | Generate new token: `vault token create` |
| **Secret Write Fails** | Permission errors | Check policy: `vault policy read <policy>` |
| **Dynamic Credentials Fail** | No credentials generated | Check engine: `vault secrets list` |
| **Audit Log Missing** | No audit logs | Enable audit: `vault audit enable file file_path=/vault/logs/audit.log` |
| **JIT Access Fails** | JIT not working | Check workflow: `kubectl logs -f deployment/pam-workflow` |

**Quick Commands:**

```bash
# Check Vault status
vault status

# Unseal Vault
vault operator unseal <unseal-key-1>
vault operator unseal <unseal-key-2>
vault operator unseal <unseal-key-3>

# List secrets
vault kv list secret/

# Enable audit
vault audit enable file file_path=/vault/logs/audit.log

# Check token
vault token lookup
```

---

### 2.4 Istio Troubleshooting

| Issue | Symptom | Resolution |
|-------|---------|------------|
| **Sidecar Not Injected** | Pods without sidecar | Check namespace label: `kubectl get ns -L istio-injection` |
| **mTLS Not Working** | Connection errors | Check PeerAuthentication: `kubectl get peerauthentication -A` |
| **Authorization Policy Fails** | Unexpected denials | Check AuthorizationPolicy: `kubectl get authorizationpolicy -A` |
| **Ingress Not Routing** | No traffic reaching services | Check VirtualService: `kubectl get virtualservice -A` |
| **Telemetry Missing** | No metrics, traces | Check Telemetry configuration: `kubectl get telemetry -A` |

**Quick Commands:**

```bash
# Check Istio installation
istioctl verify-install

# List Istio components
kubectl get pods -n istio-system

# Check sidecar status
kubectl get pods -A | grep -E '(istio-proxy|init)'

# Check authorization policies
kubectl get authorizationpolicy -A

# Debug routing
istioctl proxy-config all <pod-name>
```

---

### 2.5 Kong Troubleshooting

| Issue | Symptom | Resolution |
|-------|---------|------------|
| **Kong Pods Not Starting** | Pods crash | Check logs, resource limits |
| **Plugins Not Working** | Plugin features missing | Check plugin config: `kubectl get kongplugins` |
| **Rate Limiting Not Enforced** | No rate limiting | Check Redis connectivity |
| **JWT Validation Fails** | Token rejected | Check Keycloak integration, verify issuer/audience |
| **Route Not Found** | 404 errors | Check service/routes configuration |

**Quick Commands:**

```bash
# Check Kong health
curl http://kong-admin:8001/status

# List services
curl http://kong-admin:8001/services

# List routes
curl http://kong-admin:8001/routes

# List plugins
curl http://kong-admin:8001/plugins

# Restart Kong
kubectl rollout restart deployment/kong -n kong
```

---

### 2.6 ELK SIEM Troubleshooting

| Issue | Symptom | Resolution |
|-------|---------|------------|
| **Elasticsearch Not Ready** | Green status not achieved | Check storage, heap size, node count |
| **Logstash Pipeline Fails** | No logs ingested | Check pipeline config, logs: `kubectl logs -f deployment/logstash -n siem` |
| **Kibana Not Loading** | UI not accessible | Check Elasticsearch connectivity, credentials |
| **Indices Missing** | No data in Kibana | Check index templates, ILM policies |
| **Search Timeout** | Slow queries | Optimize query, reduce time range |

**Quick Commands:**

```bash
# Check Elasticsearch health
curl -k https://elasticsearch:9200/_cluster/health

# Check indices
curl -k https://elasticsearch:9200/_cat/indices

# Check Logstash pipelines
curl http://logstash:9600/_node/pipelines

# Check Kibana status
curl http://kibana:5601/api/status

# Force merge indices
curl -k -X POST https://elasticsearch:9200/_forcemerge
```

---

## 3. Incident Response Quick Reference

### 3.1 Incident Severity Matrix

| Severity | Description | Response Time | Escalation |
|----------|-------------|---------------|------------|
| **CRITICAL** | Active breach, data loss, system down | Immediate | CISO, Board |
| **HIGH** | Likely breach, imminent threat | < 15 minutes | Security Leadership |
| **MEDIUM** | Suspicious activity, investigation needed | < 1 hour | Security Team Lead |
| **LOW** | Potential issue, monitoring | < 4 hours | SOC Analyst |

### 3.2 Incident Response Commands

#### Detection Commands

```bash
# Check SIEM for recent alerts
curl -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "range": {"@timestamp": {"gte": "now-15m"}}
    },
    "sort": [{"@timestamp": "desc"}]
  }'

# Check XDR for detections
curl -X GET https://crowdstrike.nexus.com/api/v1/detections \
  -H "Authorization: Bearer $TOKEN"

# Check Kyverno for policy violations
kubectl get polr -A | grep -i violation
```

#### Containment Commands

```bash
# Isolate endpoint via XDR
curl -X POST https://crowdstrike.nexus.com/api/v1/hosts/{host_id}/isolate \
  -H "Authorization: Bearer $TOKEN"

# Block IP via Calico
kubectl apply -f - <<EOF
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: block-ip
spec:
  selector: all()
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
    source:
      nets: ["10.0.0.100/32"]
EOF

# Disable user account
curl -X PUT https://auth.nexus.com/admin/realms/nexus/users/{id}/disable \
  -H "Authorization: Bearer $TOKEN"

# Revoke sessions
curl -X POST https://auth.nexus.com/admin/realms/nexus/users/{id}/logout \
  -H "Authorization: Bearer $TOKEN"
```

#### Evidence Collection Commands

```bash
# Collect logs
kubectl logs -n <namespace> <pod-name> --tail=10000 > pod-logs.txt

# Collect audit logs
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin \
  --start-time $(date -d '24 hours ago' -I)

# Collect SIEM data
curl -X GET "https://elasticsearch:9200/security-logs-*/_search" \
  -u "elastic:elastic-password" \
  -H "Content-Type: application/json" \
  -d '{"query": {"range": {"@timestamp": {"gte": "now-24h"}}}}' \
  > incident-logs.json
```

---

## 4. Common Error Codes Reference

### 4.1 HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| **400** | Bad Request | Check request format and parameters |
| **401** | Unauthorized | Check JWT/token validity |
| **403** | Forbidden | Check permissions and OPA policies |
| **404** | Not Found | Check URL and service existence |
| **429** | Too Many Requests | Rate limit exceeded, wait and retry |
| **500** | Internal Server Error | Check service logs |
| **502** | Bad Gateway | Check backend service health |
| **503** | Service Unavailable | Check service availability |
| **504** | Gateway Timeout | Check timeout settings, service response |

### 4.2 Kubernetes Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| **ImagePullBackOff** | Can't pull image | Check image name, registry access |
| **CrashLoopBackOff** | Container crashes | Check container logs, memory, startup |
| **Pending** | Pod can't schedule | Check resources, nodes, PVC |
| **OOMKilled** | Out of Memory | Increase memory limits |
| **Evicted** | Pod evicted | Check node resources |
| **Failed** | Pod failed | Check pod logs, events |

---

## 5. Emergency Contacts

### 5.1 Incident Escalation

| Role | Contact | Primary | Secondary |
|------|---------|---------|-----------|
| **CISO** | ciso@nexus.com | +1 555-0101 | PagerDuty |
| **Security Lead** | security-lead@nexus.com | +1 555-0102 | Slack |
| **SOC Lead** | soc-lead@nexus.com | +1 555-0103 | PagerDuty |
| **IR Manager** | ir-manager@nexus.com | +1 555-0104 | PagerDuty |
| **Platform SRE** | sre@nexus.com | +1 555-0105 | PagerDuty |
| **Legal** | legal@nexus.com | +1 555-0106 | Phone |
| **PR** | pr@nexus.com | +1 555-0107 | Phone |

### 5.2 Emergency Procedures

```
Critical Incident:
1. Call CISO (Primary) - +1 555-0101
2. If no answer, call Security Lead - +1 555-0102
3. Activate PagerDuty escalation policy
4. Create incident channel in Slack
5. Open incident case in TheHive

PagerDuty Activation:
- Policy: "Security Incident - Critical"
- Auto-escalation: 5 minutes between levels
- On-call rotation: Weekly rotation
- Backup: Secondary on-call

Communication:
- Internal: #security-incident channel
- External: Security Communications Group
- Regulators: Legal must approve all communications
```

---

## 6. Troubleshooting Tools Quick Reference

### 6.1 Essential Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **kubectl** | Kubernetes management | `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` |
| **istioctl** | Istio management | `curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.0 sh -` |
| **vault** | Vault management | `wget https://releases.hashicorp.com/vault/1.15.6/vault_1.15.6_linux_amd64.zip` |
| **helm** | Kubernetes package manager | `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3` |
| **opa** | Policy evaluation | `curl -L -o opa https://openpolicyagent.org/downloads/v0.60.0/opa_linux_amd64` |
| **kubeseal** | Sealed secrets | `wget https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-linux-amd64` |
| **jq** | JSON processing | `sudo apt install jq -y` |
| **yq** | YAML processing | `sudo snap install yq` |

### 6.2 Useful Commands

```bash
# Kubernetes
kubectl get all -A
kubectl describe pod <pod> -n <namespace>
kubectl logs -f <pod> -n <namespace>
kubectl events -n <namespace> --watch

# Istio
istioctl proxy-config all <pod> -n <namespace>
istioctl analyze
kubectl get destinationrules -A
kubectl get virtualservices -A

# Network
kubectl get networkpolicies -A
calicoctl get networkpolicy -A
calicoctl get globalnetworkpolicy -A

# Security
kubectl get podsecuritypolicies
kubectl get clusterpolicies -A
kubectl get validatingwebhookconfigurations

# Logs
kubectl logs -f deployment/keycloak -n keycloak
kubectl logs -f deployment/opa-server -n opa
kubectl logs -f deployment/vault -n vault
kubectl logs -f deployment/kong -n kong
kubectl logs -f deployment/logstash -n siem
```

---

**Document Owner**: Incident Response Manager  
**Last Updated**: 2026-08-02  
**Version**: 1.0

---

**[END OF APPENDIX Q]**

This appendix provides a quick reference guide for troubleshooting common issues and responding to security incidents. Use this as a fast-reference during operational incidents and troubleshooting sessions.
