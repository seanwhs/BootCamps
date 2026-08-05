# APPENDIX PRIMER 8 — Introduction to DevOps & Cloud Infrastructure

## Understanding How Applications Run in Production

---

## P8.1 Introduction

Welcome to the eighth primer! You've learned about databases, APIs, and application architecture. Now it's time to understand how applications actually run in the real world—the infrastructure and operations that keep them running.

**By the end of this primer, you will understand:**
- What DevOps is and why it matters
- The difference between IaaS, PaaS, and SaaS
- Containers and Docker basics
- Cloud computing concepts
- How to deploy applications
- Monitoring and logging
- How ScaleCart runs in production

**Estimated time:** 30-45 minutes

---

## P8.2 What Is DevOps?

### P8.2.1 The Analogy: Building a House

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEVOPS ANALOGY                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Traditional Approach (Siloed):                                │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Architects design (Developers)                            │ │
│   │  Builders build (Operations)                               │ │
│   │                                                             │ │
│   │  Problems:                                                 │ │
│   │  • Architects design things builders can't build          │ │
│   │  • Builders build things architects didn't plan for       │ │
│   │  • "It works on my machine!"                              │ │
│   │  • Long time to hand off                                  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   DevOps Approach (Collaborative):                              │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Architects and builders work together                    │ │
│   │  • Plan together                                          │ │
│   │  • Build together                                         │ │
│   │  • Automate the process                                   │ │
│   │  • Continuous improvement                                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P8.2.2 What Is DevOps?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEVOPS DEFINITION                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   DevOps = Development + Operations                              │
│                                                                     │
│   It's a culture and set of practices that:                     │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. COLLABORATION                                         │ │
│   │  • Developers and operations work together                 │ │
│   │  • Shared responsibility for the system                   │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  2. AUTOMATION                                            │ │
│   │  • Automate repetitive tasks                               │ │
│   │  • CI/CD pipelines                                         │ │
│   │  • Infrastructure as Code                                 │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  3. MONITORING                                            │ │
│   │  • Monitor everything                                      │ │
│   │  • Learn from failures                                    │ │
│   │  • Continuously improve                                   │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.3 Cloud Computing Models

### P8.3.1 IaaS, PaaS, SaaS

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CLOUD COMPUTING MODELS                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  IaaS = Infrastructure as a Service                       │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • You manage: Applications, Data, Runtime, Middleware,││ │
│   │  │    OS                                                   ││ │
│   │  │  • Provider manages: Virtualization, Servers, Storage,││ │
│   │  │    Networking                                           ││ │
│   │  │  • Examples: AWS EC2, Google Compute Engine           ││ │
│   │  │  • Best for: Full control, custom configurations      ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  PaaS = Platform as a Service                             │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • You manage: Applications, Data                     ││ │
│   │  │  • Provider manages: Runtime, Middleware, OS,         ││ │
│   │  │    Virtualization, Servers, Storage, Networking        ││ │
│   │  │  • Examples: Heroku, Google App Engine, AWS Elastic  ││ │
│   │  │  • Best for: Focus on code, less infrastructure      ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SaaS = Software as a Service                             │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • You manage: Just use the software                  ││ │
│   │  │  • Provider manages: Everything else                  ││ │
│   │  │  • Examples: Gmail, Salesforce, Dropbox              ││ │
│   │  │  • Best for: Ready-to-use applications               ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P8.3.2 Major Cloud Providers

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CLOUD PROVIDERS                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  AWS (Amazon Web Services)                                │ │
│   │  • Largest and most mature                                │ │
│   │  • Most services (200+)                                   │ │
│   │  • Global presence                                        │ │
│   │  • Examples: EC2, RDS, S3, ECS, EKS                     │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  GCP (Google Cloud Platform)                              │ │
│   │  • Strong in data and AI                                  │ │
│   │  • Excellent networking                                  │ │
│   │  • Kubernetes originated here (GKE)                       │ │
│   │  • Examples: Compute Engine, Cloud SQL, BigQuery         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  Azure (Microsoft)                                        │ │
│   │  • Strong for enterprise and Windows                     │ │
│   │  • Good hybrid cloud capabilities                         │ │
│   │  • Integrated with Microsoft products                     │ │
│   │  • Examples: Virtual Machines, SQL Azure, Functions       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.4 Containers & Docker

### P8.4.1 What Are Containers?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONTAINERS                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Containers package an application and its dependencies.         │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  BEFORE CONTAINERS:                                       │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  "It works on my machine!"                            ││ │
│   │  │  • Different OS versions                              ││ │
│   │  │  • Different library versions                         ││ │
│   │  │  • Different configurations                           ││ │
│   │  │  • Long setup times                                   ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  WITH CONTAINERS:                                          │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  ┌───────────────────────────────────────────────────┐ ││ │
│   │  │  │    CONTAINER                                    │ ││ │
│   │  │  │    ┌───────────────────────────────────────────┐  │ ││ │
│   │  │  │    │  Application Code                      │  │ ││ │
│   │  │  │    │  Dependencies (libraries, etc.)        │  │ ││ │
│   │  │  │    │  Runtime (Python, Node.js, etc.)       │  │ ││ │
│   │  │  │    │  Configuration                         │  │ ││ │
│   │  │  │    └───────────────────────────────────────────┘  │ ││ │
│   │  │  └───────────────────────────────────────────────────┘ ││ │
│   │  │                                                         ││ │
│   │  │  Runs the same EVERYWHERE! ✅                         ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P8.4.2 Docker vs. Virtual Machines

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DOCKER VS. VM                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  VIRTUAL MACHINE                                           │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  App 1    │  App 2    │  App 3    │                   ││ │
│   │  │  Libs     │  Libs     │  Libs     │                   ││ │
│   │  │  Guest OS │  Guest OS │  Guest OS │                   ││ │
│   │  ├──────────┼──────────┼──────────┤                   ││ │
│   │  │         Hypervisor                                    ││ │
│   │  ├─────────────────────────────────────────────────────────┤│ │
│   │  │         Host OS                                       ││ │
│   │  ├─────────────────────────────────────────────────────────┤│ │
│   │  │         Hardware                                       ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   │                                                             │ │
│   │  • Heavy (GBs per VM)                                      │ │
│   │  • Slower startup                                          │ │
│   │  • More isolation                                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  DOCKER CONTAINER                                         │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  App 1    │  App 2    │  App 3    │                   ││ │
│   │  │  Libs     │  Libs     │  Libs     │                   ││ │
│   │  ├──────────┼──────────┼──────────┤                   ││ │
│   │  │         Docker Engine                                 ││ │
│   │  ├─────────────────────────────────────────────────────────┤│ │
│   │  │         Host OS                                       ││ │
│   │  ├─────────────────────────────────────────────────────────┤│ │
│   │  │         Hardware                                       ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   │                                                             │ │
│   │  • Lightweight (MBs per container)                        │ │
│   │  • Fast startup                                           │ │
│   │  • Less isolation                                         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P8.4.3 Docker Commands

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DOCKER COMMANDS                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  IMAGE MANAGEMENT                                         │ │
│   │  docker build -t myapp:latest .   # Build an image        │ │
│   │  docker images                   # List images             │ │
│   │  docker rmi myapp:latest         # Remove image            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  CONTAINER MANAGEMENT                                      │ │
│   │  docker run -d -p 8000:8000 myapp:latest  # Run container │ │
│   │  docker ps                        # List running containers│ │
│   │  docker stop container_id         # Stop container         │ │
│   │  docker rm container_id           # Remove container       │ │
│   │  docker logs container_id         # View logs              │ │
│   │  docker exec -it container_id bash # Enter container      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  DOCKER COMPOSE (Multi-container)                          │ │
│   │  docker compose up -d          # Start all services        │ │
│   │  docker compose down           # Stop all services         │ │
│   │  docker compose logs           # View all logs             │ │
│   │  docker compose ps             # List all services         │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.5 Container Orchestration

### P8.5.1 What Is Orchestration?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONTAINER ORCHESTRATION                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Managing containers at scale:                                  │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  WITHOUT ORCHESTRATION                                    │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Manually deploy containers                        ││ │
│   │  │  • Monitor manually                                   ││ │
│   │  │  • Restart manually                                   ││ │
│   │  │  • Scale manually                                    ││ │
│   │  │  • "It was working yesterday!"                        ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  WITH ORCHESTRATION (Kubernetes)                         │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Automated deployment                                ││ │
│   │  │  • Self-healing (restarts failed containers)          ││ │
│   │  │  • Auto-scaling                                          ││ │
│   │  │  • Load balancing                                        ││ │
│   │  │  • Rolling updates                                      ││ │
│   │  │  • Service discovery                                   ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### P8.5.2 Kubernetes Basics

```
┌─────────────────────────────────────────────────────────────────────┐
│                    KUBERNETES CONCEPTS                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  POD                                                       │ │
│   │  • Smallest unit in Kubernetes                            │ │
│   │  • Contains one or more containers                        │ │
│   │  • Shares network and storage                            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  DEPLOYMENT                                               │ │
│   │  • Manages pods                                           │ │
│   │  • Handles rolling updates                               │ │
│   │  • Manages scaling                                        │ │
│   │  • Self-healing                                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SERVICE                                                  │ │
│   │  • Provides stable network endpoint                       │ │
│   │  • Load balances traffic                                  │ │
│   │  • Service discovery                                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  INGRESS                                                  │ │
│   │  • External access to services                           │ │
│   │  • SSL/TLS termination                                   │ │
│   │  • Routing rules                                          │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  CONFIGMAP                                                │ │
│   │  • Configuration without secrets                         │ │
│   │  • Can be shared across pods                            │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SECRET                                                   │ │
│   │  • Storing sensitive data                                │ │
│   │  • Encrypted at rest                                     │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.6 Monitoring & Logging

### P8.6.1 The Three Pillars of Observability

```
┌─────────────────────────────────────────────────────────────────────┐
│                    OBSERVABILITY PILLARS                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  1. METRICS                                                │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Numerical measurements                             ││ │
│   │  │  • CPU, memory, request count, error rate             ││ │
│   │  │  • Tools: Prometheus, StatsD                          ││ │
│   │  │  • Example: "API error rate is 0.1%"                 ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  2. LOGS                                                  │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Text records of events                            ││ │
│   │  │  • Error messages, access logs, application logs      ││ │
│   │  │  • Tools: ELK Stack (Elasticsearch, Logstash, Kibana)│ │
│   │  │  • Example: "ERROR: Database connection failed"      ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  3. TRACING                                               │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Request flow through system                        ││ │
│   │  │  • Identify bottlenecks                              ││ │
│   │  │  • Distributed traces                                 ││ │
│   │  │  • Tools: Jaeger, Zipkin                            ││ │
│   │  │  • Example: Request took 500ms, 400ms in database    ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.7 How ScaleCart Runs in Production

### P8.7.1 ScaleCart Production Infrastructure

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCALECART PRODUCTION INFRASTRUCTURE           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  USERS                                                    │ │
│   │  (Web/Mobile)                                             │ │
│   └──────────────────────────┬──────────────────────────────────┘ │
│                              │                                     │
│                              ▼                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  CLOUD PROVIDER (AWS/GCP/Azure)                           │ │
│   │                                                             │ │
│   │  ┌─────────────────────────────────────────────────────┐  │ │
│   │  │  LOAD BALANCER (ALB/NGINX)                       │  │ │
│   │  │  • SSL termination                                │  │ │
│   │  │  • Distributes traffic                            │  │ │
│   │  │  • Health checks                                   │  │ │
│   │  └─────────────────────────────────────────────────────┘  │ │
│   │                    │                                        │ │
│   │                    ▼                                        │ │
│   │  ┌─────────────────────────────────────────────────────┐  │ │
│   │  │  API SERVERS (Docker Containers)                  │  │ │
│   │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐            │  │ │
│   │  │  │ Pod 1   │ │ Pod 2   │ │ Pod 3   │            │  │ │
│   │  │  │ (API)   │ │ (API)   │ │ (API)   │            │  │ │
│   │  │  └─────────┘ └─────────┘ └─────────┘            │  │ │
│   │  └─────────────────────────────────────────────────────┘  │ │
│   │                    │                                        │ │
│   │                    ▼                                        │ │
│   │  ┌─────────────────────────────────────────────────────┐  │ │
│   │  │  DATA SERVICES                                    │  │ │
│   │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│  │ │
│   │  │  │PostgreSQL│ │  Redis │ │ MongoDB │ │  Neo4j  ││  │ │
│   │  │  │(Primary)│ │ (Cache) │ │(Doc)   │ │(Graph)  ││  │ │
│   │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘│  │ │
│   │  └─────────────────────────────────────────────────────┘  │ │
│   │                                                             │ │
│   │  ┌─────────────────────────────────────────────────────┐  │ │
│   │  │  MONITORING                                      │  │ │
│   │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐            │  │ │
│   │  │  │Prometheus│ │ Grafana │ │  ELK   │            │  │ │
│   │  │  │(Metrics)│ │(Dashboards)│(Logs)│            │  │ │
│   │  │  └─────────┘ └─────────┘ └─────────┘            │  │ │
│   │  └─────────────────────────────────────────────────────┘  │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.8 Infrastructure as Code (IaC)

### P8.8.1 What Is IaC?

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE AS CODE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   Managing infrastructure using code (not manual)                │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  BEFORE IaC:                                              │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  • Click in AWS Console                              ││ │
│   │  │  • Run manual commands                               ││ │
│   │  │  • "It was working, I don't know why it broke"       ││ │
│   │  │  • No history of changes                             ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  WITH IaC (Terraform):                                    │ │
│   │  ┌─────────────────────────────────────────────────────────┐│ │
│   │  │  resource "aws_instance" "web" {                     ││ │
│   │  │    ami           = "ami-0c55b159cbfafe1f0"           ││ │
│   │  │    instance_type = "t2.micro"                         ││ │
│   │  │    tags = {                                           ││ │
│   │  │      Name = "web-server"                             ││ │
│   │  │    }                                                  ││ │
│   │  │  }                                                    ││ │
│   │  └─────────────────────────────────────────────────────────┘│ │
│   │                                                             │ │
│   │  Benefits:                                                 │ │
│   │  • Version controlled                                        │ │
│   │  • Repeatable                                              │ │
│   │  • Reviewable                                              │ │
│   │  • Auditable                                              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.9 Why This Matters for ScaleCart

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEVOPS IMPORTANCE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ScaleCart's DevOps practices enable:                           │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  RELIABILITY                                              │ │
│   │  • Self-healing (Kubernetes restarts failed pods)         │ │
│   │  • Load balancing (distributes traffic)                   │ │
│   │  • Health checks (detects and removes unhealthy pods)    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SCALABILITY                                              │ │
│   │  • Auto-scaling (adds replicas on high load)              │ │
│   │  • Horizontal scaling (more pods)                        │ │
│   │  • Database scaling (read replicas)                      │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  SECURITY                                                │ │
│   │  • Secrets management (no passwords in code)             │ │
│   │  • Network policies (firewall rules)                     │ │
│   │  • SSL/TLS for all traffic                               │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │  DEPLOYMENT                                              │ │
│   │  • Zero-downtime deployments                             │ │
│   │  • Rollback capability                                   │ │
│   │  • Canary deployments                                    │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## P8.10 Glossary of New Terms

| Term | Definition |
|------|------------|
| **DevOps** | Development + Operations culture and practices |
| **IaaS** | Infrastructure as a Service |
| **PaaS** | Platform as a Service |
| **SaaS** | Software as a Service |
| **Docker** | Containerization platform |
| **Kubernetes** | Container orchestration platform |
| **Orchestration** | Automated management of containers |
| **Pod** | Smallest unit in Kubernetes |
| **Service** | Stable network endpoint in Kubernetes |
| **Ingress** | External access to services |
| **Observability** | Understanding system state from external outputs |
| **Metrics** | Numerical measurements |
| **Logs** | Text records of events |
| **Tracing** | Request flow through system |
| **IaC** | Infrastructure as Code |

---

## P8.11 Summary

### P8.11.1 Key Takeaways

1. **DevOps is about collaboration** between development and operations.

2. **Containers package applications** with all their dependencies.

3. **Kubernetes orchestrates containers** – manages scaling, healing, and deployment.

4. **Monitoring is essential** – metrics, logs, and tracing tell you what's happening.

5. **Infrastructure as Code** makes infrastructure repeatable and auditable.

6. **ScaleCart uses modern DevOps practices** for reliability and scalability.

### P8.11.2 What's Next?

You've completed all eight primers! You have a comprehensive foundation covering databases, performance, transactions, NoSQL, APIs, application architecture, and DevOps. You're fully prepared for the main series.

---

## P8.12 Quick Quiz

Test your understanding:

1. **What does DevOps combine?**
   - A) Development and Operations
   - B) Development and Testing
   - C) Operations and Security
   - D) Development and Design

2. **What is the difference between Docker and a VM?**
   - A) Docker is slower
   - B) Docker shares the host OS kernel
   - C) Docker requires more resources
   - D) Docker cannot run on Linux

3. **What does Kubernetes do?**
   - A) Creates containers
   - B) Orchestrates containers
   - C) Builds applications
   - D) Writes code

4. **What is IaC?**
   - A) Infrastructure as Code
   - B) Infrastructure and Code
   - C) Integrated Application Code
   - D) Internet and Cloud

5. **What are the three pillars of observability?**
   - A) Metrics, Logs, Traces
   - B) CPU, Memory, Disk
   - C) Development, Testing, Production
   - D) Code, Data, Infrastructure

**Answers:** 1-A, 2-B, 3-B, 4-A, 5-A

---

**[END OF PRIMER 8]**

