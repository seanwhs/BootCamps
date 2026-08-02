# Primer 4: Cloud-Native Security Explained
## Enterprise Cybersecurity Architecture & Frameworks
### Understanding Cloud, Containers, Kubernetes & API Security

## Welcome to Cloud-Native Security

### What Is This Primer?

This primer explains the key concepts of **cloud-native security**—the security of modern cloud-based applications. In the series, we'll implement these concepts in detail, but this primer gives you the foundation you need to understand what we're building.

**By the end of this primer, you'll understand:**
- What cloud-native means and why it matters
- The shared responsibility model
- Container and Kubernetes security
- API security
- DevSecOps and CI/CD security

---

## 1. Cloud-Native: The Big Picture

### 1.1 What Is Cloud-Native?

**Cloud-native** means building and running applications that take full advantage of the cloud computing model. It's not just "running in the cloud"—it's *designed* for the cloud.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CLOUD-NATIVE VS. TRADITIONAL                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRADITIONAL (Lift and Shift)                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Applications run on virtual machines                             │   │
│  │  • Scale by adding more VMs                                         │   │
│  │  • Long release cycles                                               │   │
│  │  • Manual operations                                                 │   │
│  │  • Monolithic architecture                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  CLOUD-NATIVE                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Applications run in containers                                  │   │
│  │  • Scale automatically                                             │   │
│  │  • Continuous delivery                                              │   │
│  │  • Automated operations                                             │   │
│  │  • Microservices architecture                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Key Cloud-Native Technologies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CLOUD-NATIVE TECHNOLOGY STACK                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Containers                                                             │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Lightweight, portable runtime                                   ││
│     │  • Package code and dependencies together                         ││
│     │  • Run consistently anywhere                                       ││
│     │  • Examples: Docker, containerd                                   ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  2. Kubernetes (K8s)                                                       │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Container orchestration                                       ││
│     │  • Automates deployment, scaling, management                     ││
│     │  • Self-healing                                                   ││
│     │  • Example: EKS (AWS), AKS (Azure), GKE (GCP)                   ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  3. Microservices                                                         │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Applications broken into small services                        ││
│     │  • Each service does one thing                                    ││
│     │  • Services communicate via APIs                                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  4. Service Mesh                                                          │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Network layer for microservices                                ││
│     │  • Manages communication between services                         ││
│     │  • Provides security, observability                               ││
│     │  • Example: Istio, Linkerd                                        ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  5. API Gateways                                                          │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Entry point for API requests                                   ││
│     │  • Handles authentication, rate limiting                         ││
│     │  • Routes requests to services                                   ││
│     │  • Example: Kong, AWS API Gateway, Azure API Management          ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  6. CI/CD Pipelines                                                       │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Automated build, test, deploy                                   ││
│     │  • Security scanning built-in                                     ││
│     │  • Example: GitLab CI, GitHub Actions, Jenkins                   ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Why Cloud-Native Changes Security

Cloud-native introduces new security challenges:

| Challenge | Description |
|-----------|-------------|
| **Dynamic Infrastructure** | Containers come and go constantly |
| **Distributed Systems** | Many services to secure |
| **Supply Chain** | Dependencies from many sources |
| **API Exposure** | More APIs = more attack surface |
| **DevOps Speed** | Security must keep up with rapid deployment |

---

## 2. The Shared Responsibility Model

### 2.1 What It Is

The **Shared Responsibility Model** divides security responsibilities between the cloud provider and the customer.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SHARED RESPONSIBILITY MODEL                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CUSTOMER RESPONSIBILITY:                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Your data                                                      │   │
│  │  • Your applications                                              │   │
│  │  • Your operating systems and patches                             │   │
│  │  • Your network configuration                                    │   │
│  │  • Your identity and access management                           │   │
│  │  • Your security controls                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  CLOUD PROVIDER RESPONSIBILITY:                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Physical data centers                                         │   │
│  │  • Hardware (servers, networking, storage)                        │   │
│  │  • Hypervisor                                                     │   │
│  │  • Managed services (S3, RDS, etc.)                              │   │
│  │  • Compliance certifications (SOC 2, PCI DSS, etc.)              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 By Service Model

| Service Model | Provider Responsibility | Customer Responsibility |
|---------------|----------------------|----------------------|
| **IaaS** (Infrastructure) | Physical, hardware, hypervisor | OS, apps, data, config |
| **PaaS** (Platform) | Physical, hardware, OS, platform | Apps, data, config |
| **SaaS** (Software) | Almost everything | Data, user management |

### 2.3 What This Means for Security

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    IMPLICATIONS FOR SECURITY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  You are responsible for:                                                  │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ✅ Configuring security controls                                   │   │
│  │  ✅ Patching operating systems                                     │   │
│  │  ✅ Encrypting your data                                           │   │
│  │  ✅ Managing access controls                                       │   │
│  │  ✅ Monitoring your systems                                        │   │
│  │  ✅ Responding to incidents                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  The provider is responsible for:                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ✅ Physical security of data centers                              │   │
│  │  ✅ Hardware security                                              │   │
│  │  ✅ Hypervisor security                                            │   │
│  │  ✅ Managed service security                                       │   │
│  │  ✅ Compliance of infrastructure                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Common Mistakes:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ❌ Assuming the cloud provider secures everything                 │   │
│  │  ❌ Leaving storage publicly accessible                           │   │
│  │  ❌ Not encrypting data                                           │   │
│  │  ❌ Not patching virtual machines                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Container Security

### 3.1 What Is a Container?

A **container** is a lightweight, standalone, executable package that includes everything needed to run an application: code, runtime, system tools, libraries, and settings.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONTAINER VS. VM                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Virtual Machine:                                                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  Application + Libraries                                    │   │   │
│  │  ├─────────────────────────────────────────────────────────────┤   │   │
│  │  │  Guest OS                                                  │   │   │
│  │  ├─────────────────────────────────────────────────────────────┤   │   │
│  │  │  Hypervisor                                                │   │   │
│  │  ├─────────────────────────────────────────────────────────────┤   │   │
│  │  │  Host OS                                                   │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │  • Heavy (GBs)                                                   │   │
│  │  • Slow to start                                                 │   │
│  │  • More isolated                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  Container:                                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │  Application + Libraries                                    │   │   │
│  │  ├─────────────────────────────────────────────────────────────┤   │   │
│  │  │  Container Runtime                                           │   │   │
│  │  ├─────────────────────────────────────────────────────────────┤   │   │
│  │  │  Host OS                                                   │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │  • Lightweight (MBs)                                             │   │
│  │  • Fast to start                                                 │   │
│  │  • Less isolated (share kernel)                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Container Security Challenges

| Challenge | Description | Mitigation |
|-----------|-------------|------------|
| **Image Vulnerabilities** | Vulnerabilities in container images | Vulnerability scanning (Trivy) |
| **Supply Chain Risks** | Malicious code in dependencies | SBOM generation, signing |
| **Runtime Attacks** | Attacks on running containers | Falco, runtime monitoring |
| **Privilege Escalation** | Container escaping to host | Pod security standards |
| **Secret Exposure** | Secrets in images | Secure secret management |

### 3.3 Container Security Controls

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CONTAINER SECURITY CONTROLS                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Image Security                                                         │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Scan for vulnerabilities (Trivy, Snyk)                         ││
│     │  • Generate SBOM (Software Bill of Materials)                     ││
│     │  • Sign images (Cosign)                                          ││
│     │  • Only use trusted registries                                    ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  2. Deployment Security                                                    │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Enforce policies (Kyverno)                                     ││
│     │  • Run as non-root                                                ││
│     │  • Read-only filesystem                                           ││
│     │  • Drop unnecessary capabilities                                 ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  3. Runtime Security                                                       │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Monitor for suspicious activity (Falco)                        ││
│     │  • Restrict network access (Network Policies)                     ││
│     │  • Limit resource usage                                           ││
│     │  • Audit logging                                                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Kubernetes Security

### 4.1 What Is Kubernetes?

**Kubernetes** (K8s) is an open-source container orchestration platform. It automates the deployment, scaling, and management of containerized applications.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    KUBERNETES ARCHITECTURE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  CONTROL PLANE                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │   │
│  │  │  API Server │  │  etcd      │  │ Controller │                │   │
│  │  │  (Kubectl)  │  │  (Storage) │  │  Manager   │                │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                               │                                             │
│  ┌────────────────────────────▼────────────────────────────────────────┐   │
│  │  WORKER NODES                                                       │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐│   │
│  │  │  Pod 1          Pod 2          Pod 3                           ││   │
│  │  │  ┌──────────┐   ┌──────────┐   ┌──────────┐                   ││   │
│  │  │  │ Container│   │ Container│   │ Container│                   ││   │
│  │  │  └──────────┘   └──────────┘   └──────────┘                   ││   │
│  │  │  ┌─────────────────────────────────────────────────────────┐   ││   │
│  │  │  │  kubelet (Node Agent)  |  kube-proxy (Network)        │   ││   │
│  │  │  └─────────────────────────────────────────────────────────┘   ││   │
│  │  └─────────────────────────────────────────────────────────────────┘│   │
│  │  ┌─────────────────────────────────────────────────────────────────┐│   │
│  │  │  Pod 4          Pod 5          Pod 6                           ││   │
│  │  │  ┌──────────┐   ┌──────────┐   ┌──────────┐                   ││   │
│  │  │  │ Container│   │ Container│   │ Container│                   ││   │
│  │  │  └──────────┘   └──────────┘   └──────────┘                   ││   │
│  │  │  ┌─────────────────────────────────────────────────────────┐   ││   │
│  │  │  │  kubelet (Node Agent)  |  kube-proxy (Network)        │   ││   │
│  │  │  └─────────────────────────────────────────────────────────┘   ││   │
│  │  └─────────────────────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Kubernetes Security Controls

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    KUBERNETES SECURITY CONTROLS                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. API Server Security                                                    │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Authentication (X.509 certs, OIDC)                             ││
│     │  • Authorization (RBAC)                                           ││
│     │  • Admission Controllers (Kyverno)                               ││
│     │  • Audit Logging                                                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  2. Pod Security                                                           │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Pod Security Standards (Restricted, Baseline, Privileged)       ││
│     │  • Security Context (runAsNonRoot, readOnlyRootFilesystem)        ││
│     │  • Resource limits (CPU, Memory)                                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  3. Network Security                                                       │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Network Policies (Default Deny)                                ││
│     │  • Service Mesh (mTLS, Istio)                                    ││
│     │  • Encryption (TLS)                                              ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  4. Secrets Management                                                     │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Kubernetes Secrets (encrypted at rest)                         ││
│     │  • External Secrets (Vault)                                      ││
│     │  • Secret rotation                                               ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.3 Kubernetes Security Example

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    K8S SECURITY EXAMPLE                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ✘ Vulnerable Pod:                                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  apiVersion: v1                                                     │   │
│  │  kind: Pod                                                          │   │
│  │  metadata:                                                          │   │
│  │    name: vulnerable-app                                             │   │
│  │  spec:                                                              │   │
│  │    containers:                                                      │   │
│  │    - name: app                                                      │   │
│  │      image: myapp:latest     ❌ 'latest' tag                        │   │
│  │      securityContext:                                               │   │
│  │        privileged: true      ❌ Privileged container                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ✅ Secure Pod:                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  apiVersion: v1                                                     │   │
│  │  kind: Pod                                                          │   │
│  │  metadata:                                                          │   │
│  │    name: secure-app                                                 │   │
│  │  spec:                                                              │   │
│  │    securityContext:                                                 │   │
│  │      runAsNonRoot: true      ✅ Non-root user                       │   │
│  │    containers:                                                      │   │
│  │    - name: app                                                      │   │
│  │      image: myregistry/myapp:1.0.0 ✅ Specific tag                 │   │
│  │      imagePullPolicy: Always    ✅ Pull fresh image                │   │
│  │      securityContext:                                               │   │
│  │        readOnlyRootFilesystem: true  ✅ Read-only filesystem        │   │
│  │        allowPrivilegeEscalation: false ✅ No privilege escalation   │   │
│  │        capabilities:                                               │   │
│  │          drop:                     ✅ Drop all capabilities         │   │
│  │          - ALL                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. API Security

### 5.1 What Is an API?

An **API** (Application Programming Interface) is how different software applications communicate with each other.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         API COMMUNICATION                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────┐                     ┌─────────┐                             │
│  │         │   GET /api/orders   │         │                             │
│  │  Client │ ──────────────────▶ │  Server │                             │
│  │  App    │                     │  API    │                             │
│  │         │   {                 │         │                             │
│  │         │     order_id: 123   │         │                             │
│  │         │   }                 │         │                             │
│  │         │ ◀────────────────── │         │                             │
│  └─────────┘                     └─────────┘                             │
│                                                                             │
│  • APIs are how microservices communicate                                  │
│  • APIs are how customers interact with your services                     │
│  • APIs are the most common attack vector today                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 OWASP API Security Top 10

OWASP (Open Web Application Security Project) publishes the API Security Top 10:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    OWASP API SECURITY TOP 10                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Broken Object Level Authorization (BOLA)                              │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  User can access objects they shouldn't                           ││
│     │  Example: GET /api/orders/1234 (but user only owns order 5678)    ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  2. Broken Authentication                                                  │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  Weak or broken authentication                                   ││
│     │  Example: No MFA, session fixation                                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  3. Excessive Data Exposure                                               │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  API returns more data than needed                                ││
│     │  Example: GET /api/users returns passwords, PII, admin flags      ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  4. Lack of Resources & Rate Limiting                                     │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  No limits on API usage                                          ││
│     │  Example: 1 million requests per minute crash the service          ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  5. Broken Function Level Authorization                                   │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  User can access functions they shouldn't                        ││
│     │  Example: Regular user calls admin API endpoint                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  6. Mass Assignment                                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  User can modify fields they shouldn't                           ││
│     │  Example: POST /api/users with "is_admin": true                   ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  7. Security Misconfiguration                                              │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  Misconfigured security settings                                 ││
│     │  Example: Debug mode enabled in production                        ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  8. Injection                                                              │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  SQL, NoSQL, command injection                                   ││
│     │  Example: GET /api/search?q=' OR '1'='1                          ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  9. Improper Asset Management                                              │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  Exposed old API versions                                        ││
│     │  Example: /api/v1 (vulnerable) still accessible                  ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  10. Insufficient Logging & Monitoring                                     │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  No visibility into attacks                                      ││
│     │  Example: Attack happens but no one notices                     ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 API Security Controls

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    API SECURITY CONTROLS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. API Gateway                                                            │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Centralized security enforcement                               ││
│     │  • Authentication and authorization                                ││
│     │  • Rate limiting and throttling                                   ││
│     │  • Request validation                                              ││
│     │  • Logging and monitoring                                         ││
│     │  • Example: Kong, AWS API Gateway                                 ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  2. Authentication & Authorization                                        │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • OAuth 2.1 / OIDC                                               ││
│     │  • JWT validation                                                 ││
│     │  • MFA enforcement                                                ││
│     │  • Scope-based authorization                                      ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  3. Input Validation                                                       │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Schema validation                                              ││
│     │  • SQL injection prevention                                       ││
│     │  • XSS prevention                                                 ││
│     │  • Parameter validation                                           ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
│  4. Rate Limiting                                                          │
│     ┌─────────────────────────────────────────────────────────────────────┐│
│     │  • Per-user limits                                                ││
│     │  • Per-IP limits                                                 ││
│     │  • Per-API limits                                                ││
│     │  • Circuit breaking                                               ││
│     └─────────────────────────────────────────────────────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. DevSecOps & CI/CD Security

### 6.1 What Is DevSecOps?

**DevSecOps** means integrating security into the DevOps pipeline (Development + Operations + Security = DevSecOps).

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DEVSECOPS PIPELINE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PLAN ──► CODE ──► BUILD ──► TEST ──► RELEASE ──► DEPLOY ──► OPERATE      │
│   │         │         │         │          │           │           │        │
│   │    ┌────▼────┐   ┌─▼──────┐ ┌─▼───────┐ ┌────────▼┐ ┌───────▼────────┐│
│   │    │ Security│   │ Secret │ │ SAST/   │ │ Container│ │ Runtime/       ││
│   │    │ Reviews │   │ Scans  │ │ SCA     │ │ Scans   │ │ Monitoring     ││
│   │    └─────────┘   └────────┘ └─────────┘ └─────────┘ └────────────────┘│
│   │                                                                          │
│   └─────────────────────────── Security "Shift Left" ───────────────────────┘│
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Security in the Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SECURITY IN CI/CD                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  CODE:                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • SAST (Static Application Security Testing)                      │   │
│  │  • Secret scanning (TruffleHog, GitLeaks)                         │   │
│  │  • Code review (security-focused)                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  BUILD:                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • SCA (Software Composition Analysis)                            │   │
│  │  • Container scanning (Trivy)                                     │   │
│  │  • SBOM generation                                                │   │
│  │  • Image signing (Cosign)                                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  TEST:                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • DAST (Dynamic Application Security Testing)                    │   │
│  │  • API security testing                                            │   │
│  │  • Fuzzing                                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  DEPLOY:                                                                    │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • IaC scanning (Terrascan)                                       │   │
│  │  • Policy checks (OPA)                                            │   │
│  │  • Compliance validation                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  OPERATE:                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Runtime security (Falco)                                       │   │
│  │  • Continuous monitoring (SIEM)                                   │   │
│  │  • Vulnerability management                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Security Gates

Security gates are automated checks that must pass before code can proceed:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SECURITY GATES                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Gate 1: Pre-Commit                                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • No secrets in code                                              │   │
│  │  • Code formatting                                                 │   │
│  │  • Basic linting                                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                          │                                                  │
│                          ▼                                                  │
│  Gate 2: Build                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • No critical vulnerabilities in dependencies                    │   │
│  │  • No critical vulnerabilities in container images                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                          │                                                  │
│                          ▼                                                  │
│  Gate 3: Test                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • No critical security findings                                  │   │
│  │  • All security tests pass                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                          │                                                  │
│                          ▼                                                  │
│  Gate 4: Deploy                                                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Infrastructure complies with policies                          │   │
│  │  • Compliance checks pass                                          │   │
│  │  • Required approvals obtained                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Key Takeaways

### 7.1 Core Concepts

1. **Cloud-native** means building applications designed for the cloud
2. **Shared responsibility** means you are responsible for your security controls
3. **Containers** need security at every stage (build, deploy, run)
4. **Kubernetes** has many security controls (RBAC, network policies, pod security)
5. **APIs** need protection (BOLA, rate limiting, authentication)
6. **DevSecOps** shifts security left into the development pipeline

### 7.2 How This Fits in the Series

| Concept | Where We Build It | Part |
|---------|------------------|------|
| Multi-Cloud Security | Landing zones, CSPM | Part 3 |
| Container Security | Trivy, SBOM, signing | Part 3 |
| Kubernetes Security | RBAC, Kyverno, PSA | Part 3 |
| API Security | OWASP Top 10, Kong | Part 3 |
| DevSecOps | CI/CD pipeline security | Part 3 |

---

## Quick Reference Card

### Shared Responsibility
- **Provider**: Physical, hardware, hypervisor
- **You**: Data, apps, OS, config, access

### Container Security
- **Image**: Scan, SBOM, sign
- **Deployment**: Non-root, read-only, drop caps
- **Runtime**: Monitor, restrict, audit

### Kubernetes Security
- **API Server**: Auth, RBAC, admission
- **Pods**: SecurityContext, PSA
- **Network**: Network policies, mTLS

### OWASP API Top 10
1. BOLA
2. Broken Authentication
3. Excessive Data Exposure
4. Rate Limiting
5. Function Level Auth
6. Mass Assignment
7. Misconfiguration
8. Injection
9. Asset Management
10. Logging & Monitoring

### DevSecOps
**Shift Left** = Move security earlier in the development process

---

**Next**: Proceed to the main series with Part 0: Introduction, or continue to Primer 5 (Detection & Response Explained).

---

**[PRIMER 4 COMPLETE]**

---

*This primer is part of the "Enterprise Cybersecurity Architecture & Frameworks" series. Continue to Primer 5 for an introduction to detection, response, and resilience.*
