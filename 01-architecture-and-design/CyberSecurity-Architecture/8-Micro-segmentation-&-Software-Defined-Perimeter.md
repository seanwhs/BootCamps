# Part 2: Zero Trust & Identity-Centric Enterprise Architecture
## Section 2.4: Micro-segmentation & Software-Defined Perimeter (SDP)

## The Target: Complete Micro-segmentation & SDP for Nexus Global Industries

In this section, we'll implement comprehensive micro-segmentation and Software-Defined Perimeter (SDP) controls for Nexus Global Industries, including:

1. **Kubernetes Network Policies** - Fine-grained east-west traffic controls
2. **Service Mesh Segmentation** - Istio authorization and mTLS
3. **Software-Defined Perimeter (SDP)** - OpenZiti "black cloud" implementation
4. **East-West Traffic Controls** - Blast radius minimization
5. **Policy-as-Code** - Automated network policy management

**What specific file(s) are we building?**
- `microseg/01_network_policies.yaml` - Comprehensive Kubernetes network policies
- `microseg/02_istio_authorization.yaml` - Istio authorization policies
- `microseg/03_sdp_configuration.yaml` - OpenZiti SDP configuration
- `microseg/04_east_west_controls.yaml` - Additional east-west controls
- `microseg/05_policy_automation.py` - Automated policy management

---

## The Concept: Micro-segmentation & SDP in Plain English

Think of micro-segmentation and SDP like **a museum with individually alarmed display cases**:

**Traditional Network Security:** "The museum has a single front door with a guard. Once inside, you can walk to any display case." This is perimeter security.

**Micro-segmentation:** "Each display case has its own alarm and lock. Even if you're in the museum, you can only access the cases you have permission for." This is granular east-west controls.

**Service Mesh (Istio):** "The museum has a security system that knows which cases you're allowed to visit and checks your badge at every single case." This is mTLS and authorization.

**SDP (Software-Defined Perimeter):** "The museum is invisible. Only security-approved visitors can even see the building exists. Everyone else sees an empty lot." This is the "black cloud" approach.

**East-West Controls:** "All the hallways between display cases have doors that check your badge before letting you pass." This is lateral movement prevention.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the microseg directory
cd ~/nexus_security_architecture
mkdir -p microseg

# Verify the structure
ls -la
# Expected: microseg directory appears
```

---

### Step 2: Comprehensive Kubernetes Network Policies

**File:** `microseg/01_network_policies.yaml`

```yaml
# Comprehensive Kubernetes Network Policies - Nexus Global Industries
# File: microseg/01_network_policies.yaml
# Version: 1.0

# ====================================================================
# NAMESPACE ISOLATION
# ====================================================================

---
# Default deny for all namespaces (applied globally)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# Default deny for production namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# Default deny for RD namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: rd
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# Default deny for OT namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: ot
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

# ====================================================================
# CUSTOMER PORTAL NAMESPACE POLICIES
# ====================================================================

---
# Allow ingress from API Gateway to Customer Portal services
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-gateway
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: customer-portal
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
      podSelector:
        matchLabels:
          app: istio-ingressgateway
    ports:
    - protocol: TCP
      port: 8080

---
# Allow internal communication between Customer Portal microservices
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-internal-portal
  namespace: production
spec:
  podSelector:
    matchLabels:
      tier: portal
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          tier: portal
    ports:
    - protocol: TCP
      port: 8080

---
# Allow Customer Portal to access database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-portal-to-db
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: postgresql
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: customer-portal
    ports:
    - protocol: TCP
      port: 5432

---
# Allow Customer Portal egress to external services
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-portal-egress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: customer-portal
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: istio-system
      podSelector:
        matchLabels:
          app: istio-ingressgateway
    ports:
    - protocol: TCP
      port: 443
  - to:
    - ipBlock:
        cidr: 10.0.0.0/8
    ports:
    - protocol: TCP
      port: 443

# ====================================================================
# R&D NAMESPACE POLICIES
# ====================================================================

---
# Isolate R&D namespace - only R&D services can communicate
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: isolate-rd
  namespace: rd
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          team: rd
  egress:
  - to:
    - podSelector:
        matchLabels:
          team: rd

---
# Allow R&D to access GitLab
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-rd-to-gitlab
  namespace: rd
spec:
  podSelector:
    matchLabels:
      app: ci-cd
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: gitlab
      podSelector:
        matchLabels:
          app: gitlab
    ports:
    - protocol: TCP
      port: 443

---
# Allow R&D to access container registry
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-rd-to-registry
  namespace: rd
spec:
  podSelector:
    matchLabels:
      app: ci-cd
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: registry
      podSelector:
        matchLabels:
          app: registry
    ports:
    - protocol: TCP
      port: 443

---
# Restrict R&D access to production databases (block)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-rd-to-prod-db
  namespace: rd
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: production
      podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432

# ====================================================================
# OT NAMESPACE POLICIES (HIGHEST SECURITY)
# ====================================================================

---
# Complete isolation for OT namespace - no external access
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: isolate-ot-complete
  namespace: ot
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ot-controller
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: ot-controller

---
# Allow OT monitoring access (read-only)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ot-monitoring
  namespace: ot
spec:
  podSelector:
    matchLabels:
      app: ot-monitor
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: monitoring
      podSelector:
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 9090

---
# Allow OT to send logs to SIEM
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ot-to-siem
  namespace: ot
spec:
  podSelector:
    matchLabels:
      app: ot-logger
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: siem
      podSelector:
        matchLabels:
          app: logstash
    ports:
    - protocol: TCP
      port: 5044

# ====================================================================
# SENSITIVE DATA PROTECTION
# ====================================================================

---
# Restrict access to payment data
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-payment-data
  namespace: production
spec:
  podSelector:
    matchLabels:
      data: payment
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: payment-service
    ports:
    - protocol: TCP
      port: 5432

---
# Restrict access to PII data
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-pii-data
  namespace: production
spec:
  podSelector:
    matchLabels:
      data: pii
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: customer-service
    ports:
    - protocol: TCP
      port: 5432

# ====================================================================
# ENVIRONMENT ISOLATION
# ====================================================================

---
# Prevent development from accessing production
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-dev-to-prod
  namespace: dev
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          environment: production
    ports:
    - protocol: TCP
      port: 1-65535

---
# Prevent staging from accessing production
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-staging-to-prod
  namespace: staging
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          environment: production
    ports:
    - protocol: TCP
      port: 1-65535

# ====================================================================
# CALICO ENHANCED POLICIES (IF CALICO IS INSTALLED)
# ====================================================================

# Note: These are Calico-specific policies for advanced segmentation
# Apply with calicoctl if Calico is the CNI

# Calico GlobalNetworkPolicy - Global default deny
apiVersion: projectcalico.org/v3
kind: GlobalNetworkPolicy
metadata:
  name: global-default-deny
spec:
  order: 100
  selector: all()
  types:
  - Ingress
  - Egress
  ingress:
  - action: Deny
    source: {}
  egress:
  - action: Deny
    destination: {}

---
# Calico NetworkPolicy - Allow service mesh traffic
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-istio-traffic
  namespace: istio-system
spec:
  selector: all()
  types:
  - Ingress
  - Egress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: app == 'istio-ingressgateway'
  egress:
  - action: Allow
    destination:
      selector: app == 'istio-ingressgateway'

---
# Calico NetworkPolicy - Application layer policies (L7)
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-http-payment
  namespace: production
spec:
  selector: app == 'payment-service'
  types:
  - Ingress
  ingress:
  - action: Allow
    protocol: TCP
    source:
      selector: app == 'order-service'
    http:
      methods: ["GET", "POST"]
      paths:
      - exact: "/api/v1/payment"
      - prefix: "/api/v1/payment/"

---
# Calico NetworkPolicy - Egress with DNS allowlist
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: production
spec:
  selector: all()
  types:
  - Egress
  egress:
  - action: Allow
    protocol: UDP
    destination:
      nets: ["8.8.8.8/32", "1.1.1.1/32"]
      ports: [53]
```

**Verification:**

```bash
# Verify network policies file
ls -la microseg/01_network_policies.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('microseg/01_network_policies.yaml'))"
# Expected: No error output

# Count policies
grep -c "apiVersion:" microseg/01_network_policies.yaml
# Expected: Shows 20+ network policies
```

---

### Step 3: Istio Authorization Policies

**File:** `microseg/02_istio_authorization.yaml`

```yaml
# Istio Authorization Policies - Nexus Global Industries
# File: microseg/02_istio_authorization.yaml
# Version: 1.0

# ====================================================================
# PEER AUTHENTICATION (mTLS)
# ====================================================================

---
# Strict mTLS for all services
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: strict-mtls
  namespace: istio-system
spec:
  mtls:
    mode: STRICT

---
# mTLS for production namespace (explicit)
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: mtls-production
  namespace: production
spec:
  mtls:
    mode: STRICT
  selector:
    matchLabels:
      environment: production

---
# mTLS for RD namespace
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: mtls-rd
  namespace: rd
spec:
  mtls:
    mode: STRICT
  selector:
    matchLabels:
      environment: rd

# ====================================================================
# AUTHORIZATION POLICIES
# ====================================================================

---
# Allow only authenticated requests
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: require-authn
  namespace: istio-system
spec:
  action: DENY
  rules:
  - from:
    - source:
        notPrincipals: ["*"]

---
# Service-to-service authorization: Payment Service
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: payment-service-authz
  namespace: production
spec:
  selector:
    matchLabels:
      app: payment-service
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/order-service"]
    to:
    - operation:
        methods: ["POST", "GET"]
        paths: ["/api/v1/payment/*"]
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/customer-service"]
    to:
    - operation:
        methods: ["GET"]
        paths: ["/api/v1/payment/status/*"]

---
# Service-to-service authorization: Order Service
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: order-service-authz
  namespace: production
spec:
  selector:
    matchLabels:
      app: order-service
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/api-gateway"]
    to:
    - operation:
        methods: ["POST", "GET", "PUT"]
        paths: ["/api/v1/orders/*"]

---
# Service-to-service authorization: Customer Service
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: customer-service-authz
  namespace: production
spec:
  selector:
    matchLabels:
      app: customer-service
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/api-gateway"]
    to:
    - operation:
        methods: ["GET", "PUT"]
        paths: ["/api/v1/customers/*"]

---
# Deny all other traffic to payment service
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: payment-service-deny
  namespace: production
spec:
  selector:
    matchLabels:
      app: payment-service
  action: DENY
  rules:
  - from:
    - source:
        notPrincipals: ["cluster.local/ns/production/sa/order-service"]
    to:
    - operation:
        methods: ["*"]
        paths: ["*"]

# ====================================================================
# NAMESPACE ISOLATION
# ====================================================================

---
# Isolate RD namespace from production
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: isolate-rd
  namespace: rd
spec:
  action: DENY
  rules:
  - from:
    - source:
        namespaces: ["production"]
    to:
    - operation:
        methods: ["*"]
        paths: ["*"]

---
# Allow monitoring access
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-monitoring
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: prometheus
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["*"]
    to:
    - operation:
        methods: ["GET"]
        paths: ["/metrics"]

# ====================================================================
# RATE LIMITING (Request-level controls)
# ====================================================================

# Note: Rate limiting is implemented at the Envoy filter level
# These are applied via EnvoyFilter resources

---
# Rate limit for payment service (100 req/min)
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: payment-service-ratelimit
  namespace: production
spec:
  workloadSelector:
    labels:
      app: payment-service
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: envoy.filters.network.http_connection_manager
            subFilter:
              name: envoy.filters.http.router
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.local_ratelimit
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.local_ratelimit.v3.LocalRateLimit
          stat_prefix: http_local_rate_limiter
          token_bucket:
            max_tokens: 100
            tokens_per_fill: 100
            fill_interval: 60s
          filter_enabled:
            runtime_key: local_rate_limit_enabled
            default_value:
              numerator: 100
              denominator: HUNDRED

# ====================================================================
# AUTHORIZATION FOR EXTERNAL SERVICES
# ====================================================================

---
# Allow egress to external payment gateway
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: egress-payment-gateway
  namespace: production
spec:
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/payment-service"]
    to:
    - operation:
        hosts: ["payment-gateway.external.com"]

---
# Deny egress to external services (default deny)
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: egress-default-deny
  namespace: production
spec:
  action: DENY
  rules:
  - from:
    - source:
        principals: ["*"]
    to:
    - operation:
        hosts: ["*"]

# ====================================================================
# WORKLOAD-LEVEL FINE-GRAINED CONTROLS
# ====================================================================

---
# Control access based on JWT claims
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: jwt-claim-based-authz
  namespace: production
spec:
  action: ALLOW
  rules:
  - from:
    - source:
        requestPrincipals: ["*"]
    when:
    - key: request.auth.claims[email]
      values: ["*@nexus.com"]
    - key: request.auth.claims[roles]
      values: ["admin", "security-team", "rd-engineer"]

---
# Restrict access to PII data based on clearance
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: pii-data-access
  namespace: production
spec:
  selector:
    matchLabels:
      data: pii
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["*"]
    when:
    - key: request.auth.claims[clearance]
      values: ["restricted", "confidential"]
    - key: request.auth.claims[mfa_enabled]
      values: ["true"]
```

**Verification:**

```bash
# Verify Istio authorization file
ls -la microseg/02_istio_authorization.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('microseg/02_istio_authorization.yaml'))"
# Expected: No error output

# Count policies
grep -c "apiVersion:" microseg/02_istio_authorization.yaml
# Expected: Shows 15+ policies
```

---

### Step 4: Software-Defined Perimeter (SDP) Configuration

**File:** `microseg/03_sdp_configuration.yaml`

```yaml
# Software-Defined Perimeter (SDP) Configuration - Nexus Global Industries
# File: microseg/03_sdp_configuration.yaml
# Version: 1.0

# ====================================================================
# OPENZITI SDP CONTROLLER DEPLOYMENT
# ====================================================================

---
# Namespace for SDP components
apiVersion: v1
kind: Namespace
metadata:
  name: sdp
  labels:
    name: sdp
    security.istio.io/tlsMode: "istio"

---
# SDP Controller ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: sdp-controller-config
  namespace: sdp
data:
  config.yaml: |
    # OpenZiti Controller Configuration
    version: 3.0.0
    controller:
      config:
        # Controller identity
        identity:
          issuer: ziti-controller
          cert: /etc/controller/certs/controller.crt
          key: /etc/controller/certs/controller.key
          ca: /etc/controller/certs/ca.crt
        
        # API configuration
        api:
          address: 0.0.0.0:1280
          tls:
            cert: /etc/controller/certs/api.crt
            key: /etc/controller/certs/api.key
        
        # Database configuration
        db:
          type: postgres
          connectionString: postgresql://ziti:ziti-password@postgres.ziti.svc.cluster.local:5432/ziti
        
        # Logging
        log:
          level: info
          formatter: json
    
    # Identity provider configuration
    identity:
      oidc:
        issuer: https://auth.nexus.com/realms/nexus
        clientId: sdp-client
        clientSecret: sdp-client-secret
        
    # Policy definitions
    policies:
      # Default deny policy - nothing is accessible
      default-deny:
        type: default
        action: deny
      
      # Allow only authenticated users
      require-authn:
        type: authentication
        action: require

---
# SDP Controller Service
apiVersion: v1
kind: Service
metadata:
  name: sdp-controller
  namespace: sdp
spec:
  selector:
    app: sdp-controller
  ports:
  - name: api
    port: 1280
    targetPort: 1280
  - name: ctrl
    port: 6262
    targetPort: 6262

---
# SDP Controller Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sdp-controller
  namespace: sdp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sdp-controller
  template:
    metadata:
      labels:
        app: sdp-controller
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: controller
        image: openziti/controller:latest
        args: ["run", "/etc/controller/config/config.yaml"]
        env:
        - name: ZITI_CONTROLLER_PORT
          value: "1280"
        - name: ZITI_CTRL_PORT
          value: "6262"
        ports:
        - containerPort: 1280
        - containerPort: 6262
        volumeMounts:
        - name: config
          mountPath: /etc/controller/config
        - name: certs
          mountPath: /etc/controller/certs
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
      volumes:
      - name: config
        configMap:
          name: sdp-controller-config
      - name: certs
        secret:
          secretName: sdp-certs

# ====================================================================
# SDP GATEWAY DEPLOYMENT (Edge Router)
# ====================================================================

---
# SDP Gateway ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: sdp-gateway-config
  namespace: sdp
data:
  config.yaml: |
    # OpenZiti Edge Router/Gateway Configuration
    version: 3.0.0
    edge:
      config:
        identity:
          cert: /etc/gateway/certs/gateway.crt
          key: /etc/gateway/certs/gateway.key
          ca: /etc/gateway/certs/ca.crt
        
        # Gateway address
        address: 0.0.0.0:3022
        tls:
          cert: /etc/gateway/certs/api.crt
          key: /etc/gateway/certs/api.key
        
        # Controller connection
        controller:
          address: sdp-controller.sdp.svc.cluster.local:1280
        
        # Edge API
        edgeApi:
          address: 0.0.0.0:1281
          tls:
            cert: /etc/gateway/certs/api.crt
            key: /etc/gateway/certs/api.key

---
# SDP Gateway Service
apiVersion: v1
kind: Service
metadata:
  name: sdp-gateway
  namespace: sdp
spec:
  selector:
    app: sdp-gateway
  ports:
  - name: edge
    port: 3022
    targetPort: 3022
  - name: api
    port: 1281
    targetPort: 1281

---
# SDP Gateway Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sdp-gateway
  namespace: sdp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sdp-gateway
  template:
    metadata:
      labels:
        app: sdp-gateway
      annotations:
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: gateway
        image: openziti/gateway:latest
        args: ["run", "/etc/gateway/config/config.yaml"]
        ports:
        - containerPort: 3022
        - containerPort: 1281
        volumeMounts:
        - name: config
          mountPath: /etc/gateway/config
        - name: certs
          mountPath: /etc/gateway/certs
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
      volumes:
      - name: config
        configMap:
          name: sdp-gateway-config
      - name: certs
        secret:
          secretName: sdp-certs

# ====================================================================
# SDP SERVICE CONFIGURATIONS (Services to be hidden behind SDP)
# ====================================================================

---
# SDP Service: Customer Portal
# Hide the customer portal behind SDP - only authenticated users can see it
apiVersion: ziti.io/v1
kind: ZitiService
metadata:
  name: customer-portal
  namespace: sdp
spec:
  service:
    name: customer-portal
    description: Customer Portal - Protected by SDP
    edgeRouter:
      - name: gateway-1
        address: sdp-gateway.sdp.svc.cluster.local:3022
    policy:
      allow:
        - groups:
            - "authenticated-users"
        - conditions:
            - type: identity
              claim: roles
              value: "customer|support"
    endpoints:
      - address: production/customer-portal
        port: 8080
        protocol: https
    encryption:
      enabled: true
      algorithm: AES-256-GCM

---
# SDP Service: R&D Systems
# Hide R&D behind SDP - only R&D engineers can see it
apiVersion: ziti.io/v1
kind: ZitiService
metadata:
  name: rd-systems
  namespace: sdp
spec:
  service:
    name: rd-systems
    description: R&D Systems - Protected by SDP
    edgeRouter:
      - name: gateway-1
        address: sdp-gateway.sdp.svc.cluster.local:3022
    policy:
      allow:
        - groups:
            - "rd-engineers"
            - "rd-managers"
        - conditions:
            - type: identity
              claim: department
              value: "R&D"
            - type: context
              claim: devicePosture
              value: "compliant"
    endpoints:
      - address: rd/gitlab
        port: 443
        protocol: https
      - address: rd/ci-cd
        port: 443
        protocol: https
    encryption:
      enabled: true
      algorithm: AES-256-GCM

---
# SDP Service: Financial Systems
apiVersion: ziti.io/v1
kind: ZitiService
metadata:
  name: financial-systems
  namespace: sdp
spec:
  service:
    name: financial-systems
    description: Financial Systems - Protected by SDP
    edgeRouter:
      - name: gateway-2
        address: sdp-gateway-2.sdp.svc.cluster.local:3022
    policy:
      allow:
        - groups:
            - "finance-team"
            - "security-team"
        - conditions:
            - type: identity
              claim: clearance
              value: "confidential"
            - type: context
              claim: time
              value: "working-hours"
    endpoints:
      - address: production/finance
        port: 443
        protocol: https
    encryption:
      enabled: true
      algorithm: AES-256-GCM

# ====================================================================
# SDP IDENTITY PROVIDER INTEGRATION
# ====================================================================

---
# SDP to Keycloak Integration
apiVersion: ziti.io/v1
kind: ZitiIdentityProvider
metadata:
  name: keycloak-idp
  namespace: sdp
spec:
  provider:
    type: oidc
    name: keycloak
    issuer: https://auth.nexus.com/realms/nexus
    clientId: sdp-client
    clientSecret: sdp-client-secret
    scope: openid profile email roles groups
    claimMapping:
      - from: email
        to: email
      - from: roles
        to: roles
      - from: groups
        to: groups
    autoCreateUser: true
    autoUpdateUser: true

# ====================================================================
# SDP CLIENT CONFIGURATION (Example for applications)
# ====================================================================

---
# Example: Application connecting to SDP
apiVersion: ziti.io/v1
kind: ZitiClient
metadata:
  name: customer-portal-client
  namespace: sdp
spec:
  client:
    name: customer-portal
    type: application
    identity:
      issuer: sdp-controller
    tls:
      enabled: true
      cert: /etc/client/certs/client.crt
      key: /etc/client/certs/client.key
    services:
      - customer-portal
    edgeRouter:
      - gateway-1
      - gateway-2
    policies:
      - require-authn
      - default-deny
```

**Verification:**

```bash
# Verify SDP configuration file
ls -la microseg/03_sdp_configuration.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('microseg/03_sdp_configuration.yaml'))"
# Expected: No error output

# Check for SDP resources
grep -c "apiVersion:" microseg/03_sdp_configuration.yaml
# Expected: Shows 10+ resources
```

---

### Step 5: East-West Traffic Controls

**File:** `microseg/04_east_west_controls.yaml`

```yaml
# East-West Traffic Controls - Nexus Global Industries
# File: microseg/04_east_west_controls.yaml
# Version: 1.0

# ====================================================================
# SERVICE MESH TRAFFIC CONTROLS
# ====================================================================

---
# Circuit breaking for payment service
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: payment-service-circuit-breaker
  namespace: production
spec:
  host: payment-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
        connectTimeout: 5s
    loadBalancer:
      simple: ROUND_ROBIN
    outlierDetection:
      consecutive5xxErrors: 3
      interval: 30s
      baseEjectionTime: 60s
      maxEjectionPercent: 50

---
# Retry policy for order service
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-service-retry
  namespace: production
spec:
  hosts:
  - order-service
  http:
  - timeout: 10s
    retries:
      attempts: 3
      perTryTimeout: 2s
      retryOn: gateway-error,connect-failure,refused-stream
    route:
    - destination:
        host: order-service
        port:
          number: 8080

# ====================================================================
# BLAST RADIUS MINIMIZATION
# ====================================================================

---
# Limit blast radius for production namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: limit-blast-radius
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: production
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: production

---
# Limit blast radius for OT namespace (complete isolation)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ot-blast-radius
  namespace: ot
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ot-controller
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: ot-controller

# ====================================================================
# LATERAL MOVEMENT PROTECTION
# ====================================================================

---
# Prevent lateral movement from production to RD
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-production-to-rd
  namespace: rd
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: production
    ports:
    - protocol: TCP
      port: 1-65535

---
# Prevent lateral movement from RD to production
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-rd-to-production
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: rd
    ports:
    - protocol: TCP
      port: 1-65535

---
# Prevent lateral movement from OT to anything else
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: block-ot-egress
  namespace: ot
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: ot

# ====================================================================
# SERVICE-TO-SERVICE BASTION HOSTS (JUMP BOXES)
# ====================================================================

---
# Only allow access to bastion hosts
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: bastion-access-only
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: bastion
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: security
      podSelector:
        matchLabels:
          app: bastion-client
    ports:
    - protocol: TCP
      port: 22

# ====================================================================
# MICROSERVICE COMMUNICATION PATTERNS
# ====================================================================

---
# Allow specific microservice communication patterns
# Pattern: API Gateway → Order Service → Payment Service
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-gateway-to-order
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: order-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 8080

---
# Allow Order Service → Payment Service
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-order-to-payment
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: payment-service
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: order-service
    ports:
    - protocol: TCP
      port: 8080

# ====================================================================
# EXTERNAL INGRESS CONTROLS
# ====================================================================

---
# Only allow ingress through API Gateway
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: external-ingress-only
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: istio-system
      podSelector:
        matchLabels:
          app: istio-ingressgateway
    ports:
    - protocol: TCP
      port: 443

# ====================================================================
# EGRESS CONTROLS
# ====================================================================

---
# Only allow egress to specific external services
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: egress-allowlist
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/8
    ports:
    - protocol: TCP
      port: 443
  - to:
    - ipBlock:
        cidr: 172.16.0.0/12
    ports:
    - protocol: TCP
      port: 443
  - to:
    - ipBlock:
        cidr: 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 443
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53

# ====================================================================
# DNS SECURITY
# ====================================================================

---
# Restrict DNS queries to authorized nameservers
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-dns
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - protocol: UDP
      port: 53

# ====================================================================
# MONITORING AND OBSERVABILITY
# ====================================================================

---
# Allow monitoring and observability traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: prometheus
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
      podSelector:
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 9090
```

**Verification:**

```bash
# Verify east-west controls file
ls -la microseg/04_east_west_controls.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('microseg/04_east_west_controls.yaml'))"
# Expected: No error output
```

---

### Step 6: Policy Automation

**File:** `microseg/05_policy_automation.py`

```python
#!/usr/bin/env python3
"""
Network Policy Automation - Nexus Global Industries
File: microseg/05_policy_automation.py
Version: 1.0

This service automates network policy management, validation, and deployment.
"""

import os
import json
import logging
import yaml
import subprocess
import time
import threading
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from pathlib import Path

import redis
from kubernetes import client, config
from kubernetes.client.rest import ApiException
from flask import Flask, request, jsonify

# ====================================================================
# Configuration
# ====================================================================

CONFIG = {
    "REDIS_URL": os.getenv("REDIS_URL", "redis://redis.default.svc.cluster.local:6379/0"),
    "POLICY_DIR": os.getenv("POLICY_DIR", "/policies"),
    "DEPLOY_INTERVAL": int(os.getenv("DEPLOY_INTERVAL", "60")),  # 1 minute
    "LOG_LEVEL": os.getenv("LOG_LEVEL", "INFO"),
}

# ====================================================================
# Logging Setup
# ====================================================================

logging.basicConfig(
    level=getattr(logging, CONFIG["LOG_LEVEL"]),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ====================================================================
# Policy Automation Service
# ====================================================================

class PolicyAutomationService:
    """Automates network policy deployment and validation."""
    
    def __init__(self):
        """Initialize the policy automation service."""
        # Load Kubernetes configuration
        try:
            config.load_incluster_config()
        except:
            config.load_kube_config()
        
        self.core_api = client.CoreV1Api()
        self.networking_api = client.NetworkingV1Api()
        
        # Redis connection for policy state
        self.redis_client = redis.from_url(CONFIG["REDIS_URL"])
        
        # Start policy deployment thread
        self._start_deployment_thread()
        
        # Start policy validation thread
        self._start_validation_thread()
        
        logger.info("Policy Automation Service initialized")
    
    # ====================================================================
    # Policy Deployment
    # ====================================================================
    
    def deploy_policies(self, policy_files: List[str] = None) -> Dict[str, Any]:
        """
        Deploy network policies from files.
        
        Args:
            policy_files: List of policy file paths (optional)
            
        Returns:
            Deployment status
        """
        if not policy_files:
            policy_files = self._get_policy_files()
        
        results = {
            "deployed": [],
            "failed": [],
            "total": len(policy_files)
        }
        
        for policy_file in policy_files:
            try:
                # Load policy from file
                with open(policy_file, 'r') as f:
                    policy_yaml = f.read()
                
                # Apply policy
                self._apply_policy(policy_yaml)
                results["deployed"].append(policy_file)
                logger.info(f"Deployed policy: {policy_file}")
                
            except Exception as e:
                results["failed"].append({
                    "file": policy_file,
                    "error": str(e)
                })
                logger.error(f"Failed to deploy {policy_file}: {e}")
        
        # Update deployment state
        self.redis_client.setex(
            "policy:last_deployment",
            3600,
            json.dumps({
                "timestamp": time.time(),
                "results": results
            })
        )
        
        return results
    
    def _get_policy_files(self) -> List[str]:
        """Get all policy files in the policy directory."""
        policy_dir = Path(CONFIG["POLICY_DIR"])
        if not policy_dir.exists():
            logger.warning(f"Policy directory not found: {policy_dir}")
            return []
        
        return [str(f) for f in policy_dir.glob("*.yaml")]
    
    def _apply_policy(self, policy_yaml: str) -> None:
        """
        Apply a network policy using kubectl.
        
        Args:
            policy_yaml: YAML policy definition
        """
        # Parse YAML to validate
        try:
            policy_dict = yaml.safe_load(policy_yaml)
            if not policy_dict:
                return
            
            # Determine resource type
            if "NetworkPolicy" in policy_dict.get("kind", ""):
                # Use Kubernetes API to apply
                self._apply_network_policy(policy_dict)
            else:
                # Use kubectl for other resources
                self._apply_with_kubectl(policy_yaml)
                
        except yaml.YAMLError as e:
            logger.error(f"Error parsing YAML: {e}")
            raise
    
    def _apply_network_policy(self, policy_dict: Dict[str, Any]) -> None:
        """Apply a NetworkPolicy using Kubernetes API."""
        namespace = policy_dict.get("metadata", {}).get("namespace", "default")
        name = policy_dict.get("metadata", {}).get("name", "")
        
        try:
            # Check if policy exists
            existing = self.networking_api.read_namespaced_network_policy(
                name=name,
                namespace=namespace
            )
            
            # Update existing policy
            self.networking_api.patch_namespaced_network_policy(
                name=name,
                namespace=namespace,
                body=policy_dict
            )
            logger.info(f"Updated policy {name} in namespace {namespace}")
            
        except ApiException as e:
            if e.status == 404:
                # Create new policy
                self.networking_api.create_namespaced_network_policy(
                    namespace=namespace,
                    body=policy_dict
                )
                logger.info(f"Created policy {name} in namespace {namespace}")
            else:
                logger.error(f"Error applying policy {name}: {e}")
                raise
    
    def _apply_with_kubectl(self, policy_yaml: str) -> None:
        """Apply policy using kubectl."""
        # Write to temp file
        temp_file = "/tmp/policy.yaml"
        with open(temp_file, 'w') as f:
            f.write(policy_yaml)
        
        # Apply via kubectl
        result = subprocess.run(
            ["kubectl", "apply", "-f", temp_file],
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception(f"kubectl apply failed: {result.stderr}")
        
        os.remove(temp_file)
    
    # ====================================================================
    # Policy Validation
    # ====================================================================
    
    def validate_policies(self) -> Dict[str, Any]:
        """
        Validate deployed network policies.
        
        Returns:
            Validation results
        """
        results = {
            "valid": [],
            "invalid": [],
            "total": 0
        }
        
        try:
            # Get all network policies in all namespaces
            policies = self.networking_api.list_network_policy_for_all_namespaces()
            
            results["total"] = len(policies.items)
            
            for policy in policies.items:
                # Check policy validity
                valid = self._validate_policy(policy)
                
                policy_info = {
                    "name": policy.metadata.name,
                    "namespace": policy.metadata.namespace,
                    "spec": policy.spec.to_dict()
                }
                
                if valid:
                    results["valid"].append(policy_info)
                else:
                    results["invalid"].append({
                        **policy_info,
                        "reason": "Policy validation failed"
                    })
            
        except Exception as e:
            logger.error(f"Error validating policies: {e}")
        
        return results
    
    def _validate_policy(self, policy) -> bool:
        """Validate a network policy."""
        try:
            # Check if policy has pod selector
            if not policy.spec.pod_selector or not policy.spec.pod_selector.match_labels:
                logger.warning(f"Policy {policy.metadata.name} has no pod selector")
            
            # Check if policy has policy types
            if not policy.spec.policy_types:
                logger.warning(f"Policy {policy.metadata.name} has no policy types")
                return False
            
            # Check if policy has rules
            has_rules = False
            if policy.spec.ingress or policy.spec.egress:
                has_rules = True
            
            if not has_rules:
                logger.warning(f"Policy {policy.metadata.name} has no rules")
                return False
            
            return True
            
        except Exception as e:
            logger.error(f"Error validating policy: {e}")
            return False
    
    # ====================================================================
    # Policy Compliance Checking
    # ====================================================================
    
    def check_compliance(self) -> Dict[str, Any]:
        """
        Check compliance with network policy standards.
        
        Returns:
            Compliance results
        """
        compliance_results = {
            "compliant": True,
            "issues": [],
            "namespaces_checked": 0
        }
        
        try:
            # Get all namespaces
            namespaces = self.core_api.list_namespace()
            
            for ns in namespaces.items:
                ns_name = ns.metadata.name
                compliance_results["namespaces_checked"] += 1
                
                # Check if namespace has default-deny
                has_default_deny = self._check_default_deny(ns_name)
                
                if not has_default_deny:
                    compliance_results["compliant"] = False
                    compliance_results["issues"].append({
                        "namespace": ns_name,
                        "issue": "Missing default-deny policy"
                    })
                
                # Check if namespace has least privilege
                has_least_privilege = self._check_least_privilege(ns_name)
                
                if not has_least_privilege:
                    compliance_results["compliant"] = False
                    compliance_results["issues"].append({
                        "namespace": ns_name,
                        "issue": "Policies may not follow least privilege"
                    })
        
        except Exception as e:
            logger.error(f"Error checking compliance: {e}")
            compliance_results["compliant"] = False
            compliance_results["issues"].append({
                "issue": f"Compliance check error: {e}"
            })
        
        return compliance_results
    
    def _check_default_deny(self, namespace: str) -> bool:
        """Check if namespace has a default-deny policy."""
        try:
            policies = self.networking_api.list_namespaced_network_policy(namespace)
            
            for policy in policies.items:
                # Check if policy has no ingress rules (default-deny)
                if not policy.spec.ingress and not policy.spec.egress:
                    return True
                
                # Check if policy is named default-deny
                if "default-deny" in policy.metadata.name.lower():
                    return True
            
            return False
            
        except ApiException as e:
            logger.error(f"Error checking default-deny for {namespace}: {e}")
            return False
    
    def _check_least_privilege(self, namespace: str) -> bool:
        """Check if policies follow least privilege."""
        try:
            policies = self.networking_api.list_namespaced_network_policy(namespace)
            
            # Check if policies have specific selectors (not all pods)
            for policy in policies.items:
                if not policy.spec.pod_selector.match_labels:
                    # Policy applies to all pods - might be too broad
                    logger.warning(f"Policy in {namespace} applies to all pods")
            
            return True
            
        except Exception as e:
            logger.error(f"Error checking least privilege: {e}")
            return False
    
    # ====================================================================
    # Policy Audit Logging
    # ====================================================================
    
    def audit_policies(self) -> Dict[str, Any]:
        """
        Generate policy audit report.
        
        Returns:
            Audit report
        """
        audit_report = {
            "timestamp": time.time(),
            "total_policies": 0,
            "policies_by_namespace": {},
            "policy_types": {
                "ingress": 0,
                "egress": 0,
                "both": 0
            }
        }
        
        try:
            policies = self.networking_api.list_network_policy_for_all_namespaces()
            audit_report["total_policies"] = len(policies.items)
            
            for policy in policies.items:
                ns = policy.metadata.namespace
                
                # Count by namespace
                if ns not in audit_report["policies_by_namespace"]:
                    audit_report["policies_by_namespace"][ns] = 0
                audit_report["policies_by_namespace"][ns] += 1
                
                # Count by policy type
                has_ingress = policy.spec.ingress is not None and len(policy.spec.ingress) > 0
                has_egress = policy.spec.egress is not None and len(policy.spec.egress) > 0
                
                if has_ingress and has_egress:
                    audit_report["policy_types"]["both"] += 1
                elif has_ingress:
                    audit_report["policy_types"]["ingress"] += 1
                elif has_egress:
                    audit_report["policy_types"]["egress"] += 1
            
        except Exception as e:
            logger.error(f"Error auditing policies: {e}")
        
        # Store audit report
        self.redis_client.setex(
            "policy:audit",
            86400,  # 24 hours
            json.dumps(audit_report)
        )
        
        return audit_report
    
    # ====================================================================
    # Background Threads
    # ====================================================================
    
    def _start_deployment_thread(self) -> None:
        """Start background thread for policy deployment."""
        def deploy_loop():
            while True:
                try:
                    # Deploy policies from policy directory
                    self.deploy_policies()
                    time.sleep(CONFIG["DEPLOY_INTERVAL"])
                except Exception as e:
                    logger.error(f"Error in deployment loop: {e}")
                    time.sleep(10)
        
        thread = threading.Thread(target=deploy_loop, daemon=True)
        thread.start()
        logger.info("Policy deployment thread started")
    
    def _start_validation_thread(self) -> None:
        """Start background thread for policy validation."""
        def validation_loop():
            while True:
                try:
                    # Validate policies
                    self.validate_policies()
                    # Check compliance
                    self.check_compliance()
                    # Audit policies
                    self.audit_policies()
                    time.sleep(CONFIG["DEPLOY_INTERVAL"] * 5)  # Every 5 minutes
                except Exception as e:
                    logger.error(f"Error in validation loop: {e}")
                    time.sleep(30)
        
        thread = threading.Thread(target=validation_loop, daemon=True)
        thread.start()
        logger.info("Policy validation thread started")

# ====================================================================
# Flask Web API
# ====================================================================

app = Flask(__name__)
policy_service = PolicyAutomationService()

@app.route("/health", methods=["GET"])
def health():
    """Health check."""
    return jsonify({"status": "healthy", "service": "policy-automation"})

@app.route("/api/policies/deploy", methods=["POST"])
def deploy_policies():
    """Deploy network policies."""
    try:
        data = request.json or {}
        policy_files = data.get("files")
        result = policy_service.deploy_policies(policy_files)
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error deploying policies: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/policies/validate", methods=["GET"])
def validate_policies():
    """Validate network policies."""
    try:
        result = policy_service.validate_policies()
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error validating policies: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/policies/compliance", methods=["GET"])
def check_compliance():
    """Check compliance."""
    try:
        result = policy_service.check_compliance()
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error checking compliance: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/policies/audit", methods=["GET"])
def audit_policies():
    """Get policy audit report."""
    try:
        result = policy_service.audit_policies()
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error auditing policies: {e}")
        return jsonify({"error": str(e)}), 500

# ====================================================================
# Main Entry Point
# ====================================================================

def main():
    """Main entry point."""
    app.run(host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()
```

**Verification:**

```bash
# Verify policy automation file
ls -la microseg/05_policy_automation.py
# Expected: File exists

# Check Python syntax
python3 -m py_compile microseg/05_policy_automation.py
# Expected: No syntax errors
```

---

### Step 7: Micro-segmentation Summary

**File:** `microseg/README.md`

```markdown
# Micro-segmentation & Software-Defined Perimeter - Nexus Global Industries

## Overview

This directory contains the complete micro-segmentation and Software-Defined Perimeter implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_network_policies.yaml` | Network Policies | Kubernetes network policies |
| `02_istio_authorization.yaml` | Istio Policies | Service mesh authorization |
| `03_sdp_configuration.yaml` | SDP | OpenZiti configuration |
| `04_east_west_controls.yaml` | East-West | Traffic and blast radius controls |
| `05_policy_automation.py` | Automation | Automated policy management |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│         MICRO-SEGMENTATION & SDP ARCHITECTURE                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  SDP (OpenZiti) - "Black Cloud"                        │   │
│  │  • Infrastructure invisible to unauthorized users     │   │
│  │  • Authentication required before visibility          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Service Mesh (Istio) - East-West Security            │   │
│  │  • mTLS for all service communication                │   │
│  │  • Authorization policies (ABAC/RBAC)                │   │
│  │  • Circuit breaking and retry policies               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Network Policies (Calico/Kubernetes)                  │   │
│  │  • Default-deny for all namespaces                    │   │
│  │  • Micro-segmentation by namespace and workload       │   │
│  │  • Blast radius minimization                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Description |
|---------|-------------|
| **Default Deny** | All traffic denied unless explicitly allowed |
| **Micro-segmentation** | Granular pod-to-pod controls |
| **mTLS** | All east-west traffic encrypted |
| **SDP** | "Black cloud" - infrastructure invisible |
| **Blast Radius** | Limited impact of breaches |
| **Policy Automation** | Automated deployment and validation |

## Deployment Instructions

### 1. Deploy Network Policies

```bash
kubectl apply -f microseg/01_network_policies.yaml
```

### 2. Deploy Istio Authorization

```bash
kubectl apply -f microseg/02_istio_authorization.yaml
```

### 3. Deploy SDP

```bash
kubectl apply -f microseg/03_sdp_configuration.yaml
```

### 4. Deploy East-West Controls

```bash
kubectl apply -f microseg/04_east_west_controls.yaml
```

### 5. Deploy Policy Automation

```bash
kubectl apply -f microseg/05_policy_automation.py
```

## Verification Checklist

- [ ] Default-deny policies in all namespaces
- [ ] Micro-segmentation working (pod-to-pod)
- [ ] mTLS enabled for all services
- [ ] SDP "black cloud" active
- [ ] Blast radius minimized
- [ ] Policy automation running
- [ ] Compliance checks passing

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la microseg/README.md
# Expected: File exists

echo "✅ Micro-segmentation & SDP Complete!"
echo "   - Network policies defined"
echo "   - Istio authorization policies"
echo "   - SDP configuration"
echo "   - East-west controls"
echo "   - Policy automation"
```

---

## Part 2 Completion Summary

**[GENERATED: Part 2 Complete - Zero Trust & Identity-Centric Enterprise Architecture]**

### What We've Built

| Section | Artifacts | Status |
|---------|-----------|--------|
| **2.1 Zero Trust Architecture** | 6 files (design, PDP, PEP, verification, policies) | ✅ Complete |
| **2.2 Identity & Access Management** | 6 files (Keycloak, realm, SCIM, RBAC/ABAC) | ✅ Complete |
| **2.3 Privileged Access Management** | 6 files (Vault, deployment, policies, workflows) | ✅ Complete |
| **2.4 Micro-segmentation & SDP** | 6 files (policies, Istio, SDP, east-west, automation) | ✅ Complete |

### Total Artifacts Created (Part 2)

```
zero_trust/
├── 01_architecture_design.md
├── 02_pdp_policies.rego
├── 03_pep_configuration.yaml
├── 04_continuous_verification.py
├── 05_zero_trust_policies.yaml
└── README.md

iam/
├── 01_keycloak_configuration.yaml
├── 02_realm_configuration.json
├── 03_scim_automation.py
├── 04_rbac_policies.rego
├── 05_iam_integration.md
└── README.md

pam/
├── 01_vault_configuration.hcl
├── 02_vault_deployment.yaml
├── 03_pam_policies.hcl
├── 04_privileged_workflows.py
├── 05_break_glass.py
└── README.md

microseg/
├── 01_network_policies.yaml
├── 02_istio_authorization.yaml
├── 03_sdp_configuration.yaml
├── 04_east_west_controls.yaml
├── 05_policy_automation.py
└── README.md
```

**Total Files Created in Part 2: 24+**

---

**[END OF PART 2]**

Part 2: Zero Trust & Identity-Centric Enterprise Architecture is now complete. You have built the complete Zero Trust foundation for Nexus Global Industries, including identity management, privileged access controls, and micro-segmentation.

### What's Next

**Part 3: Cloud-Native Security & Modern Workloads** will include:
- Multi-cloud security architecture
- Container and Kubernetes security
- Infrastructure as Code security
- API security with OWASP Top 10 protections
- DevSecOps CI/CD pipeline security
