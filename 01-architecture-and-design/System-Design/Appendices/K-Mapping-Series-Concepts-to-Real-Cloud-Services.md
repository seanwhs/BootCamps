# Appendix K: Mapping Series Concepts to Real Cloud Services

This appendix connects the abstract patterns from the series to concrete services in the three major clouds (AWS, Google Cloud, Azure). Use it when you need to turn a whiteboard design into a realistic implementation sketch, or when an interviewer asks “How would you actually build this on cloud X?”

The mappings are deliberately pragmatic — they show the most common, production-proven choices rather than every possible option.

---

### K.1 Traffic Entry & Edge

| Concept | AWS | Google Cloud | Azure |
|---------|-----|--------------|-------|
| DNS | Route 53 | Cloud DNS | Azure DNS |
| CDN | CloudFront | Cloud CDN | Azure CDN / Front Door |
| Global load balancing / anycast | Global Accelerator + ALB/NLB | Cloud Load Balancing | Azure Front Door / Traffic Manager |
| L7 Load Balancer / API Gateway | Application Load Balancer + API Gateway | Cloud Load Balancing + API Gateway | Application Gateway + API Management |
| WAF / DDoS protection | AWS WAF + Shield | Cloud Armor | Azure WAF + DDoS Protection |
| Edge compute | Lambda@Edge / CloudFront Functions | Cloud Functions (2nd gen) at edge / Cloudflare Workers (common) | Azure Functions + Front Door |

---

### K.2 Compute & Application Tier

| Concept | AWS | Google Cloud | Azure |
|---------|-----|--------------|-------|
| Stateless containers (simple) | ECS / Fargate | Cloud Run | Azure Container Apps |
| Kubernetes | EKS | GKE | AKS |
| Serverless functions | Lambda | Cloud Functions | Azure Functions |
| Traditional VMs | EC2 | Compute Engine | Virtual Machines |
| Auto-scaling | Application Auto Scaling / EC2 Auto Scaling | Cloud Run scaling / GKE autoscaler | Azure Autoscale / VMSS |

---

### K.3 Caching & Session State

| Concept | AWS | Google Cloud | Azure |
|---------|-----|--------------|-------|
| Managed Redis | ElastiCache (Redis) | Memorystore for Redis | Azure Cache for Redis |
| Memcached | ElastiCache (Memcached) | Memorystore for Memcached | Azure Cache for Memcached |
| CDN caching | CloudFront | Cloud CDN | Azure CDN / Front Door |
| In-process + distributed | Application + ElastiCache | Application + Memorystore | Application + Azure Cache |

---

### K.4 Primary Data Storage

| Concept | AWS | Google Cloud | Azure |
|---------|-----|--------------|-------|
| Relational (general) | RDS (PostgreSQL / MySQL) / Aurora | Cloud SQL / AlloyDB | Azure Database for PostgreSQL / MySQL / SQL Database |
| Relational (globally distributed) | Aurora Global / DynamoDB (some patterns) | Spanner | Cosmos DB (with strong consistency) / Azure SQL Hyperscale |
| Document | DocumentDB / DynamoDB | Firestore / Document AI (related) | Cosmos DB |
| Key-Value / Wide-column | DynamoDB | Bigtable / Firestore | Cosmos DB / Table Storage |
| Analytics / Columnar | Redshift / Athena | BigQuery | Synapse / Fabric |
| Graph | Neptune | — (partner solutions) | Cosmos DB (Gremlin API) |
| Object / Blob storage | S3 | Cloud Storage | Azure Blob Storage |
| Time-series | Timestream | Bigtable / Monitoring | Azure Data Explorer / Time Series Insights |

---

### K.5 Messaging, Streaming & Async

| Concept | AWS | Google Cloud | Azure |
|---------|-----|--------------|-------|
| Classic message queue | SQS | Cloud Tasks / Pub/Sub (pull) | Azure Queue Storage / Service Bus |
| Pub/Sub | SNS + SQS | Pub/Sub | Service Bus topics / Event Grid |
| High-throughput event log | MSK (Kafka) / Kinesis | Pub/Sub / Kafka on GKE / Managed Kafka | Event Hubs / Kafka on HDInsight |
| Managed Kafka | MSK | Managed Service for Apache Kafka | Event Hubs (Kafka protocol) |
| Workflow orchestration | Step Functions | Workflows | Logic Apps / Durable Functions |

---

### K.6 Service Communication & Identity

| Concept | AWS | Google Cloud | Azure |
|---------|-----|--------------|-------|
| Service identity / mTLS | IAM Roles + App Mesh / Private Link | Workload Identity + Anthos Service Mesh | Managed Identities + Service Mesh (Istio/Linkerd) |
| API authentication | Cognito / IAM + API Gateway | Identity Platform / Cloud Endpoints | Azure AD / Entra ID + API Management |
| Secret management | Secrets Manager / SSM Parameter Store | Secret Manager | Key Vault |
| Service mesh | App Mesh | Anthos Service Mesh | Open Service Mesh / Istio on AKS |

---

### K.7 Observability

| Concept | AWS | Google Cloud | Azure |
|---------|-----|--------------|-------|
| Metrics | CloudWatch | Cloud Monitoring | Azure Monitor |
| Logging | CloudWatch Logs | Cloud Logging | Azure Monitor Logs / Log Analytics |
| Tracing | X-Ray | Cloud Trace | Application Insights |
| Dashboards & alerting | CloudWatch Dashboards + Alarms | Cloud Monitoring dashboards + Alerting | Azure Dashboards + Alerts |
| OpenTelemetry support | Strong (ADOT) | Strong | Strong |

---

### K.8 Reliability & Traffic Management Patterns

| Concept | Typical Cloud Realization |
|---------|---------------------------|
| Rate limiting | API Gateway usage plans, Cloud Armor, Azure API Management policies, or application-level + Redis |
| Circuit breaking | Service mesh (App Mesh, Anthos, OSM) or application libraries (Resilience4j, etc.) |
| Bulkheads | Separate services / thread pools / separate queues + consumer groups |
| Health checks | ELB/ALB health checks, GKE readiness/liveness probes, Azure health probes |
| Canary / progressive delivery | CodeDeploy, Cloud Deploy, Azure Deployment Manager / Flagger / Argo Rollouts |
| Multi-region failover | Route 53 health checks + failover, Global Load Balancing, Azure Front Door / Traffic Manager |

---

### K.9 Quick “Default Stack” Examples

**Simple high-scale API (stateless)**  
- Edge: CloudFront / Cloud CDN / Front Door  
- Compute: Fargate / Cloud Run / Container Apps  
- Cache: ElastiCache / Memorystore / Azure Cache  
- Database: Aurora / Cloud SQL / Azure Database for PostgreSQL  
- Async: SQS / Pub/Sub / Service Bus  

**Event-driven notification system**  
- Ingestion: API Gateway / Cloud Endpoints  
- Event backbone: SNS+SQS or Kinesis / Pub/Sub / Event Hubs  
- Workers: Lambda / Cloud Functions / Azure Functions  
- Delivery: SES + Pinpoint / third-party + equivalent  

**Real-time chat**  
- Connection layer: API Gateway WebSockets / Cloud Run + third-party / Azure Web PubSub  
- Presence & fan-out: Redis + async messaging  
- Durable storage: DynamoDB / Firestore / Cosmos DB  

---

### K.10 How to Use This Appendix

- **In interviews**: When asked “How would you implement this on AWS/GCP/Azure?”, pick the corresponding row and justify the choice with the same reasoning you used in the abstract design.  
- **In real projects**: Start with the abstract design first, then use this map to select managed services that match your constraints (team skill, existing contracts, latency, cost, compliance).  
- **Avoiding lock-in thinking**: Notice that almost every concept has a counterpart in all three clouds. The important decisions are the patterns (stateless, cache-aside, Saga, etc.), not the specific product names.

---

**[END OF APPENDIX K]**
