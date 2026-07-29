# 📌 Repository Overview

This monorepo is a unified workspace for documenting my technical growth, code evolution, product thinking, architectural decisions, security practices, and engineering deliverables across several intensive bootcamp tracks.

The work spans the complete technology lifecycle:

1. Discovering a customer or business problem.
2. Defining product requirements and measurable outcomes.
3. Designing the system and documenting architectural decisions.
4. Building web, data, AI, and security capabilities.
5. Testing and securing the application.
6. Provisioning infrastructure through code.
7. Automating integration and deployment.
8. Monitoring systems and responding to operational events.
9. Continuously improving the product and its supporting platform.

The repository includes both individual track exercises and multidisciplinary capstones that combine product strategy, software engineering, architecture, data, security, and operations.

---

## 🌱 Open-Source-First Approach

The projects in this repository use FOSS tools wherever practical. This approach keeps the work inspectable, reproducible, portable, and suitable for local or self-hosted environments.

### Guiding Principles

* Prefer tools licensed under recognized open-source licenses.
* Favor open standards and portable configuration formats.
* Avoid mandatory dependence on proprietary SaaS platforms.
* Keep infrastructure, policies, documentation, and diagrams in version control.
* Use reproducible builds and documented development environments.
* Support local, self-hosted, bare-metal, virtualized, and cloud-agnostic deployment.
* Integrate security throughout the software-delivery lifecycle.
* Treat accessibility, privacy, maintainability, and observability as core requirements.
* Record important decisions, assumptions, risks, and trade-offs.
* Verify the licenses of dependencies, datasets, container images, and AI models.

### GitOps Clarification

**Argo CD and Flux CD are both FOSS.** Their core projects are licensed under the Apache License 2.0 and are graduated projects of the Cloud Native Computing Foundation.

Commercial vendors may offer hosted platforms, enterprise support, or proprietary services built around them, but the self-hosted Argo CD and Flux CD projects remain open source.

The same distinction applies throughout this repository: an open-source project may have commercial hosting or enterprise offerings, but only its FOSS components are used here.

### CI/CD Clarification

GitHub Actions workflow syntax may be familiar to many developers, but the GitHub-hosted Actions service is not itself a fully open-source, self-hostable CI/CD platform.

This repository therefore prioritizes FOSS alternatives such as:

* **Forgejo Actions**
* **Woodpecker CI**
* **Jenkins**
* **Tekton Pipelines**
* **Argo Workflows**

Forgejo Actions provides an Actions-style workflow experience while supporting a self-hosted, open-source development platform.

---

## 🎯 Roles These Bootcamps Prepare For

The bootcamps are designed to build foundational and portfolio-ready skills relevant to roles such as:

* Software Architect
* Solution Architect
* Junior Enterprise Architect
* Technical Product Manager
* Product Owner
* Product Analyst
* Full Stack Developer
* Frontend Developer
* Backend Developer
* Data Analyst
* Junior Data Scientist
* Machine Learning Engineer
* Cybersecurity Analyst
* Security Operations Center Analyst
* Vulnerability Management Analyst
* Application Security Analyst
* DevOps Engineer
* DevSecOps Engineer
* Platform Engineer
* Cloud-Native Engineer
* Site Reliability Engineer
* Infrastructure Automation Engineer
* AI Application Engineer
* Generative AI Engineer
* Database Administrator
* Technical Lead or Engineering Manager

Role readiness depends on prior experience, project depth, and the requirements of each organization. The repository is intended to demonstrate practical capabilities and transferable engineering knowledge rather than guarantee qualification for a specific position.

---

## 📌 Repository Structure

```text
.
├── 00-languages-and-tools
├── 01-architecture-and-design
├── 02-product-management
│   └── Zero-to-PM
├── 03-full-stack-web-dev
├── 04-data-engineering-and-ai
├── 05-cybersecurity-and-devsecops
│   └── Threat-Modelling
├── 07-databases
└── README.md
```

### 📁 Directory Overview

* **`00-languages-and-tools`** — Deep-dives into core programming languages (Python, JavaScript, TypeScript), runtime mechanics, CPython/V8 internals, Git workflows, and CLI tooling.
* **`01-architecture-and-design`** — Architectural blueprints, system design patterns, C4 diagrams, ADRs, Domain-Driven Design, and event-driven specs.
* **`02-product-management`** — Product specs, discovery frameworks, user story mapping, roadmaps, release planning, and outcome-driven metrics. Includes the `Zero-to-PM` subfolder with foundational product-management coursework.
* **`03-full-stack-web-dev`** — End-to-end web engineering modules covering frontend UI frameworks, backend HTTP APIs, databases, server-side rendering, and production web deployment.
* **`04-data-engineering-and-ai`** — Exploratory data analysis, ETL/ELT pipelines, analytical SQL, statistical modeling, machine learning workflows, local inference, embeddings, vector databases, Retrieval-Augmented Generation (RAG), and agentic AI systems.
* **`05-cybersecurity-and-devsecops`** — Threat modeling, defensive security, host hardening, packet analysis, OWASP vulnerability assessments, SIEM rules, incident triage, CI/CD automation, Infrastructure as Code, container orchestration, GitOps, secrets management, and observability. Includes the `Threat-Modelling` subfolder with structured threat-analysis exercises.
* **`07-databases`** — Relational schema design, normalization, query optimization (`EXPLAIN ANALYZE`), indexing strategies, and ORM abstractions (Active Record vs. Data Mapper).

---

# 🛠️ Track Breakdowns & Highlights

## 1. 🏛️ Architecture

> **Key Focus:** Designing secure, scalable, resilient, observable, and maintainable systems across application, data, integration, and infrastructure layers.

This track explores how product and business requirements are translated into technical systems. It emphasizes clear boundaries, deployment topology, communication patterns, data ownership, operational requirements, and architectural trade-offs.

### Core Learning Areas

* Enterprise, solution, software, and platform architecture
* Functional and non-functional requirements
* C4 system-context, container, component, and deployment diagrams
* Domain-Driven Design and bounded contexts
* Modular monolith and microservice architectures
* Event-driven and message-oriented systems
* API-first and contract-driven design
* Synchronous and asynchronous communication
* Relational, document, graph, and time-series data patterns
* Scalability, availability, resilience, and fault tolerance
* Caching, load balancing, replication, and partitioning
* Authentication, authorization, and trust boundaries
* Threat modeling and secure architecture
* Observability and operational readiness
* Architecture Decision Records
* Backup, restoration, and disaster recovery

### FOSS Tooling

* **Diagramming:** Mermaid, PlantUML, diagrams.net
* **Architecture Modeling:** Structurizr Lite
* **Documentation:** Markdown, MkDocs, Antora
* **API Specifications:** OpenAPI, AsyncAPI, Redoc
* **Identity:** Keycloak
* **Messaging:** Apache Kafka, RabbitMQ, NATS
* **Data:** PostgreSQL, MariaDB, Valkey, Apache Cassandra
* **Proxy and Gateway:** NGINX, Envoy, Traefik, Apache APISIX
* **Private Cloud:** OpenStack, Apache CloudStack

### Featured Assets

* End-to-end architectural specification for an event-driven platform.
* C4 diagrams covering system context, containers, components, and deployment.
* ADRs evaluating data stores, messaging systems, authentication, and deployment models.
* OpenAPI and AsyncAPI contracts for services and events.
* Threat model identifying assets, actors, attack surfaces, and trust boundaries.
* Non-functional requirements covering reliability, security, privacy, and performance.
* Capacity, resilience, backup, restoration, and disaster-recovery plans.

### Roles Supported

* Software Architect
* Solution Architect
* Junior Enterprise Architect
* Platform Architect
* Technical Lead
* Systems Designer

---

## 2. 📋 Product Management

> **Key Focus:** Connecting customer needs, product strategy, user experience, engineering delivery, and measurable outcomes.

This track covers the product lifecycle from discovery and problem validation through prioritization, delivery planning, experimentation, release management, and performance measurement.

### Core Learning Areas

* Product vision and strategy
* Customer discovery and problem validation
* Product Requirement Documents
* Lean product briefs
* Personas and problem statements
* Jobs to Be Done
* User journeys and service blueprints
* User story maps and acceptance criteria
* Market and competitor analysis
* MVP definition and release planning
* RICE, MoSCoW, and value-versus-effort prioritization
* Objectives and Key Results
* Product roadmaps
* Product analytics and experimentation
* Accessibility and inclusive design
* Privacy-aware product development
* Stakeholder communication and decision records

### FOSS Tooling

* **Wireframes and UI Design:** Penpot, Pencil Project
* **Whiteboarding:** Excalidraw
* **Planning:** OpenProject, Taiga
* **Documentation:** Markdown, HedgeDoc, BookStack
* **Analytics:** Matomo, Plausible Community Edition
* **Dashboards:** Apache Superset, Metabase
* **Surveys:** LimeSurvey
* **Diagrams:** Mermaid, PlantUML, diagrams.net

### Featured Assets

* PRD for an open-source AI-assisted learning platform.
* Product vision connecting customer needs to strategic outcomes.
* Personas, journey maps, and Jobs-to-Be-Done analysis.
* Story map covering discovery, MVP, launch, and later releases.
* RICE-based feature-prioritization model with documented assumptions.
* Product roadmap balancing value, risk, effort, and dependencies.
* Metrics framework for acquisition, activation, engagement, and retention.
* Accessible Penpot wireframes and interaction prototypes.
* Experiment plan defining hypotheses, metrics, guardrails, and success criteria.

### Roles Supported

* Technical Product Manager
* Associate Product Manager
* Product Owner
* Product Analyst
* Platform Product Manager
* Product Operations Specialist
* Technical Program Coordinator

---

## 3. 🌐 Full Stack Web Development

> **Key Focus:** Building accessible, secure, testable, and production-ready web applications across frontend, backend, database, and deployment layers.

This track develops practical experience in delivering complete web products. It covers user interfaces, backend services, API contracts, relational data models, authentication, testing, observability, and automated delivery.

### Core Technologies

* TypeScript and JavaScript
* React and Next.js
* Node.js and Express
* HTML, CSS, and Tailwind CSS
* REST, OpenAPI, and WebSockets
* PostgreSQL, ORM frameworks (Prisma, Drizzle, TypeORM), and relational databases
* Keycloak or application-managed authentication
* Vitest, Playwright, and Testing Library
* Podman and Buildah
* NGINX, Caddy, or Traefik

### Core Learning Areas

* Component-based frontend architecture
* Responsive and accessible interface development
* Server-side rendering and client-side interactions
* API design, validation, pagination, and versioning
* Relational modeling, ORM abstractions, migrations, indexing, and transactions
* Authentication, authorization, and role-based access control
* Secure cookies, sessions, and token handling
* Error handling and structured logging
* Unit, integration, API, and end-to-end testing
* Background jobs and asynchronous processing
* Caching and performance optimization
* Dependency and configuration management
* Containerized development and deployment
* Health, readiness, and liveness checks

### Featured Projects

* Multi-tenant SaaS-style platform with authentication and role-based access.
* Node.js and Express REST API backed by PostgreSQL and Prisma ORM.
* Responsive Next.js frontend with reusable, accessible components.
* Registration, login, email verification, password reset, and session-revocation workflows.
* OpenAPI-documented service with validation and integration tests.
* Background-processing workflow using an open-source message broker.
* Containerized environment using Podman and Compose-compatible tooling.
* Automated build, test, scan, and deployment pipeline using Forgejo Actions or Woodpecker CI.

### Roles Supported

* Full Stack Developer
* Frontend Developer
* Backend Developer
* Node.js Developer
* Web Application Developer
* Junior Software Engineer
* Application Support Engineer

---

## 4. 📊 Data Engineering & AI

> **Key Focus:** Transforming raw data into reproducible insights and production-ready AI systems through data pipelines, statistical analysis, machine learning, and generative AI integration.

This track covers the complete data and AI workflow: collecting and validating data, building ETL pipelines, conducting exploratory analysis, engineering features, training models, implementing RAG systems, and deploying local inference — all with an emphasis on open-source tooling and responsible AI practices.

### FOSS Tooling

* Python and JupyterLab
* Pandas, Polars, and NumPy
* Matplotlib, Seaborn, Plotly, and Altair
* PostgreSQL, DuckDB, and SQL
* Scikit-learn
* PyTorch and TensorFlow
* SciPy and Statsmodels
* Apache Airflow or Dagster
* DVC for data and experiment versioning
* MLflow for experiment tracking
* Apache Superset and Metabase
* Hugging Face Transformers libraries
* llama.cpp, Ollama, and vLLM
* LangChain and Haystack
* Qdrant and Chroma
* Model Context Protocol (MCP) SDKs
* Agent-to-Agent (A2A) protocols
* FastAPI

### Core Learning Areas

* Data collection, profiling, and validation
* Missing values, duplicates, outliers, and inconsistent data
* Exploratory Data Analysis
* Statistical analysis and hypothesis testing
* Relational modeling and analytical SQL
* Feature engineering and feature selection
* Classification, regression, and clustering
* Train, validation, and test strategies
* Cross-validation and hyperparameter tuning
* Model interpretation and bias analysis
* ETL and reproducible data pipelines
* Dashboard design and data storytelling
* Dataset licensing, privacy, and responsible use
* Neural networks and transformer concepts
* Local model inference
* Embeddings and semantic search
* Vector indexing and retrieval
* Retrieval-Augmented Generation (RAG)
* Document ingestion, parsing, and chunking
* Prompt design and structured outputs
* Tool calling and agent workflows
* Model Context Protocol (MCP) server & client integration
* Agent-to-Agent (A2A) multi-agent orchestration and task delegation
* Model and response evaluation
* Hallucination detection and mitigation
* Prompt-injection and data-poisoning risks
* Privacy and sensitive-data handling
* Model, prompt, and dataset versioning
* Latency, quality, and resource optimization
* AI observability and audit logging

### Featured Projects

* Customer-retention analysis with EDA and predictive classification.
* Reproducible pipeline for cleaning incomplete and inconsistent data.
* SQL analysis using joins, aggregations, CTEs, and window functions.
* ETL workflow combining structured data from multiple sources.
* Model-comparison report using appropriate metrics and cross-validation.
* MLflow experiment history documenting parameters, metrics, and artifacts.
* Interactive analytics dashboard using Apache Superset or Metabase.
* Data-quality assessment covering completeness, consistency, validity, and bias.
* Local RAG assistant for querying technical documentation.
* Document-ingestion pipeline with parsing, chunking, embeddings, indexing, retrieval, and citations using LangChain and Qdrant.
* Self-hosted vector search using Qdrant or Chroma.
* AI agent capable of selecting approved tools and returning validated structured results via MCP.
* Multi-agent orchestration layer leveraging A2A protocols for delegated code generation and review.
* Evaluation framework comparing relevance, groundedness, latency, and resource usage.
* FastAPI service exposing a locally hosted language model.
* Prompt-injection defense and untrusted-content isolation experiments.
* AI application with authentication, conversation history, retrieval, and observability.
* Model card documenting intended use, limitations, evaluation results, and licensing.

### Roles Supported

* Data Analyst
* Business Intelligence Analyst
* Junior Data Scientist
* Analytics Engineer
* Junior Machine Learning Engineer
* Data Quality Analyst
* Reporting and Visualization Specialist
* AI Application Engineer
* Generative AI Engineer
* Applied AI Developer
* RAG Engineer
* AI Platform Engineer
* Machine Learning Operations Engineer
* AI Solutions Developer

---

## 5. 🛡️ Cybersecurity & DevSecOps

> **Key Focus:** Understanding attack surfaces, identifying vulnerabilities, hardening systems, analyzing network activity, responding to security events, and embedding security throughout software delivery while automating integration, testing, infrastructure, deployment, policy enforcement, and observability.

This track develops defensive-security skills through authorized labs and controlled environments, then connects them to modern platform engineering. It combines Linux security, network analysis, application testing, vulnerability management, log analysis, threat modeling, security automation, CI/CD, Infrastructure as Code, GitOps, and runtime monitoring.

### FOSS Tooling

* Wireshark and tcpdump
* Nmap
* OWASP ZAP
* mitmproxy
* Greenbone/OpenVAS
* Wazuh
* Suricata and Zeek
* YARA and Sigma
* OpenSCAP and Lynis
* Bash and Python
* nftables
* GnuPG and OpenSSL
* Git and Forgejo
* Forgejo Actions, Woodpecker CI, Jenkins, Tekton
* Argo Workflows
* OpenTofu
* Ansible
* Podman, Buildah, Skopeo
* Kubernetes and K3s
* Helm and Kustomize
* Argo CD or Flux CD
* Keycloak
* OpenBao, SOPS, Sealed Secrets
* Open Policy Agent, Gatekeeper, Kyverno
* Harbor
* OpenTelemetry, Prometheus, Grafana, Loki
* Falco
* Terratest and pytest
* k6
* OpenGrep
* OWASP Dependency-Check
* Gitleaks
* Trivy and Grype
* Syft
* Checkov
* Cosign

### Core Learning Areas

* Security principles and common threat models
* Linux administration and host hardening
* Network reconnaissance and service enumeration
* Packet capture and protocol analysis
* Web security and the OWASP Top 10
* Vulnerability identification and remediation
* Authentication and access-control weaknesses
* Secure configuration and patch management
* Centralized logging and security monitoring
* Detection engineering with Sigma and YARA
* Incident triage and evidence handling
* Risk assessment and vulnerability reporting
* Ethical testing and responsible disclosure
* DevSecOps culture and shared responsibility
* Secure Software Development Lifecycle
* Continuous Integration and Continuous Delivery
* Infrastructure as Code
* Configuration management
* GitOps and declarative deployment
* Policy as Code
* Secrets and identity management
* Least privilege and Zero Trust principles
* Container and Kubernetes security
* Software supply-chain security
* Reproducible builds and artifact provenance
* Observability and Site Reliability Engineering
* Incident response and operational readiness
* Compliance automation and audit evidence
* Security gates, exceptions, and risk acceptance
* Deployment frequency, lead time, failure rate, and recovery metrics

### Featured Labs & Projects

* Python utility for filtering and inspecting packet-capture files.
* Bash scripts for automated Linux audits and remediation checks.
* Web application assessments using OWASP ZAP.
* Network reconnaissance and service analysis using Nmap.
* Wireshark and Zeek investigations of suspicious traffic.
* Host-hardening assessments using Lynis and OpenSCAP.
* Wazuh monitoring for authentication, integrity, and system events.
* Sigma rules for suspicious process, account, and login behavior.
* Vulnerability reports documenting evidence, likelihood, impact, and remediation.
* Simulated incident investigation using host, network, and application logs.
* Self-hosted CI/CD pipeline with linting, tests, static analysis, dependency scanning, secret detection, and image scanning.
* Security and quality gates that reject builds exceeding documented thresholds.
* OpenTofu infrastructure using reusable modules, remote state, and automated validation.
* Ansible playbooks for repeatable host configuration and system hardening.
* Rootless container build workflow using Podman and Buildah.
* Kubernetes deployment with namespaces, RBAC, network policies, resource limits, and security contexts.
* GitOps continuous delivery using Argo CD or Flux CD.
* Helm or Kustomize configuration for repeatable environment deployment.
* SBOM generation using Syft and vulnerability analysis using Grype or Trivy.
* Artifact signing and verification using Cosign.
* Policy-as-code controls for infrastructure and Kubernetes workloads.
* Secrets-management workflow using OpenBao, SOPS, or Sealed Secrets.
* Prometheus and Grafana dashboards for application and platform telemetry.
* OpenTelemetry instrumentation for metrics, logs, and traces.
* Falco rules for detecting suspicious container and Kubernetes activity.
* Rollback, backup, restoration, and incident-response exercises.

### Roles Supported

* Cybersecurity Analyst
* SOC Analyst
* Junior Security Engineer
* Vulnerability Management Analyst
* Application Security Analyst
* Incident Response Analyst
* Security Operations Engineer
* Defensive Security Specialist
* DevOps Engineer
* DevSecOps Engineer
* Platform Engineer
* Site Reliability Engineer
* Infrastructure Automation Engineer
* Cloud-Native Engineer
* Kubernetes Engineer
* Build and Release Engineer
* CI/CD Engineer
* Platform Security Engineer

---

## 6. 🗄️ Databases

> **Key Focus:** Designing, modeling, optimizing, and interacting with relational and non-relational database systems using native drivers and Object-Relational Mapping (ORM) frameworks.

This track explores database architecture, relational theory, document and key-value storage, indexing strategies, query execution, migrations, and object-relational mapping abstractions.

### Core Learning Areas

* Relational database design, normalization, and relational algebra
* Schema migration strategies, versioning, and zero-downtime updates
* Object-Relational Mapping (ORM) design patterns (Active Record vs. Data Mapper)
* ORM performance optimization: avoiding N+1 queries, lazy loading vs. eager loading, and batching
* Query optimization, indexing strategies (B-Tree, GIN, GiST), and execution plan analysis (`EXPLAIN ANALYZE`)
* Connection pooling, transaction management, ACID properties, and isolation levels
* NoSQL patterns: document, key-value, and column-family stores

### Tooling and Technologies

* **Relational Databases:** PostgreSQL, MariaDB/MySQL, SQLite
* **ORMs & Query Builders:** Prisma, Drizzle ORM, TypeORM, SQLAlchemy
* **Database Management & Inspection:** pgAdmin, DBeaver, Beekeeper Studio

### Featured Projects

* High-throughput relational schema design with automated ORM migrations and seeders.
* ORM performance benchmarking suite contrasting Active Record vs. Data Mapper patterns and evaluating raw SQL execution vs. ORM query abstraction overhead.
* Database migration and rollback pipeline supporting zero-downtime application deployments.

### Roles Supported

* Database Administrator (DBA)
* Backend Engineer
* Database Architect
* Data Engineer

---

## 🔗 Multidisciplinary Capstones

The capstones connect several tracks to reflect how real-world technology products are researched, designed, implemented, secured, delivered, and operated.

A typical capstone may include:

* Product vision, personas, PRD, roadmap, and success metrics.
* C4 diagrams, threat models, data models, and ADRs.
* Accessible full-stack application.
* PostgreSQL database and documented API contracts.
* Data pipeline, analytics dashboard, or predictive model.
* Locally hosted AI, RAG, or agentic capability.
* OpenTofu infrastructure and Ansible configuration.
* Rootless container build using Podman.
* Self-hosted CI/CD using Forgejo Actions or Woodpecker CI.
* Kubernetes deployment using Helm or Kustomize.
* GitOps delivery using Argo CD or Flux CD.
* Automated SAST, dependency, secret, IaC, and container scanning.
* SBOM generation and artifact-signing workflow.
* Policy enforcement using OPA, Gatekeeper, or Kyverno.
* Metrics, logs, traces, dashboards, and alerts.
* Backup, restoration, rollback, and incident-response exercises.
* Final architecture, security, operations, and product documentation.

---

## 📊 Bootcamp Track Matrix

| Track | Primary FOSS Tools and Artifacts | Core Focus | Example Roles | Status |
| --- | --- | --- | --- | --- |
| **00. Languages & Tools** | Python, JavaScript, TypeScript, V8, Node.js, Git | Core Syntax, Runtime Mechanics, & CLI Tooling | Software Engineer, Systems Developer | 🟢 Complete |
| **01. Architecture** | C4, ADRs, Mermaid, PlantUML, OpenAPI | System Design & Technical Strategy | Software Architect, Solution Architect | 🟡 In Progress |
| **02. Product Management** | PRDs, Penpot, OpenProject, Matomo | Product Discovery & Delivery | Product Manager, Product Owner | 🟡 In Progress |
| **03. Full Stack Web** | TypeScript, Next.js, Node.js, PostgreSQL | Web Application Engineering | Full Stack, Frontend, Backend Developer | 🟡 In Progress |
| **04. Data Engineering & AI** | Python, JupyterLab, SQL, Scikit-learn, PyTorch, Ollama, Qdrant, LangChain | Analytics, ETL, ML, RAG, & Local LLM Ops | Data Analyst, Junior Data Scientist, AI Application Engineer | 🟡 In Progress |
| **05. Cybersecurity & DevSecOps** | Wireshark, Nmap, OWASP ZAP, Wazuh, OpenTofu, Ansible, K3s, Forgejo, Argo | Threat Analysis, System Hardening, CI/CD, GitOps, & IaC | Cybersecurity Analyst, SOC Analyst, DevSecOps Engineer, Platform Engineer | 🟡 In Progress |
| **07. Databases** | PostgreSQL, Prisma, Drizzle, DBeaver | Schema Design & Query Tuning | Backend Engineer, Database Admin | 🟡 In Progress |

---

## 📜 License & Usage

All original code, documentation, and architecture diagrams in this monorepo are licensed under the [MIT License](https://www.google.com/search?q=LICENSE) or [Apache-2.0 License](https://www.google.com/search?q=LICENSE-APACHE) where specified. Content and datasets are provided for educational, reproducible, and non-commercial portfolio demonstration purposes.
