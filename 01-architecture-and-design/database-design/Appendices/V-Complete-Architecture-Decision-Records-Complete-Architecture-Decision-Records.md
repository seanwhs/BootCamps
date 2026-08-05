# APPENDIX V — Complete Architecture Decision Records (ADR)

## Documenting Key Architectural Decisions for ScaleCart

---

## V.1 Introduction

This appendix documents the key architectural decisions made during the design and development of the ScaleCart platform using the Architecture Decision Record (ADR) format. It covers:

1. **Database Selection** – Why PostgreSQL, MongoDB, Redis, Neo4j
2. **API Design** – REST vs GraphQL, versioning strategy
3. **Authentication** – JWT vs OAuth2 vs session-based
4. **Deployment** – Container orchestration choice
5. **Caching Strategy** – Multi-level caching approach
6. **Message Queue** – Event-driven architecture decisions
7. **Monitoring** – Observability stack selection

---

## V.2 ADR Template

```markdown
# ADR-XXX: [Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
[Describe the context and problem that prompted this decision]

## Decision
[Describe the decision that was made]

## Consequences
[Describe the consequences of this decision]

## Alternatives Considered
[List and evaluate alternatives]

## References
[Links to relevant documents, discussions, or resources]
```

---

## V.3 ADR-001: Database Technology Selection

```markdown
# ADR-001: Database Technology Selection

## Status
Accepted

## Context
ScaleCart required a database solution that could handle:
- 100+ million product records
- High transaction volume (500+ TPS)
- Complex relationships (orders, customers, products)
- Full-text search capabilities
- Graph-based recommendations
- Time-series analytics

## Decision
Adopt a **polyglot persistence** architecture with:

### Primary Database: PostgreSQL 15+
- ACID compliance for transactions
- Rich SQL support for complex queries
- Strong community and ecosystem
- Built-in full-text search (pg_trgm, tsvector)
- pgvector extension for vector search
- Partitioning support for large tables
- Read replicas for scaling

### Document Cache: MongoDB 7.0
- Flexible schema for product catalog
- Fast reads for product listings
- Native JSON support
- Sharding capability

### Session & Cache: Redis 7.0
- Sub-millisecond latency
- Built-in data structures (hashes, sets, sorted sets)
- TTL support for automatic expiry
- Sentinel for high availability

### Graph Database: Neo4j 5.0
- Native graph processing for recommendations
- Cypher query language
- Relationship traversal performance
- Social graph support

### Time-Series: TimescaleDB
- PostgreSQL extension
- Time-based partitioning
- Continuous aggregates
- Native SQL support

## Consequences
**Positive:**
- Best tool for each workload
- Independent scaling per service
- High performance for all use cases

**Negative:**
- Operational complexity (multiple databases)
- Cross-database consistency challenges
- Higher infrastructure costs
- Training required for each technology

## Alternatives Considered
1. **Single Database (PostgreSQL only)**
   - Pro: Simplicity
   - Con: Poor performance for graph and time-series

2. **MongoDB only**
   - Pro: Single technology
   - Con: No ACID transactions, poor graph support

3. **Cassandra + Elasticsearch**
   - Pro: High write throughput
   - Con: Operations complexity, different query patterns

## References
- [PostgreSQL Performance Tuning Guide](https://www.postgresql.org/docs/current/performance-tips.html)
- [MongoDB Use Cases](https://www.mongodb.com/use-cases)
- [Redis Patterns](https://redis.io/patterns)
- [Neo4j for Recommendations](https://neo4j.com/use-cases/recommendation-engines/)
```

---

## V.4 ADR-002: API Design Pattern

```markdown
# ADR-002: API Design Pattern

## Status
Accepted

## Context
ScaleCart needed an API strategy that would support:
- Public API for third-party integrations
- Internal service communication
- Mobile and web clients
- Long-term versioning strategy
- Documentation and discoverability

## Decision
Use **RESTful API** with the following design choices:

### API Style: REST
- Resource-oriented URLs (/api/v1/products)
- Standard HTTP methods (GET, POST, PUT, DELETE)
- Status codes (200, 201, 400, 401, 403, 404, 429, 500)
- JSON request/response bodies

### Versioning: URL-based
- /api/v1/products
- /api/v2/products
- Deprecated versions supported for 12 months

### Documentation: OpenAPI 3.0
- Auto-generated docs at /docs (Swagger UI)
- Redoc at /redoc
- OpenAPI JSON at /openapi.json

### Authentication: JWT Bearer Tokens
- Stateless tokens
- Short-lived access tokens (30 minutes)
- Refresh tokens (7 days)
- Tokens stored in Authorization header

### Rate Limiting
- Per user/client rate limits
- Token bucket algorithm
- Headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
- 429 responses with Retry-After header

### Pagination
- Offset-based (page, limit)
- Page parameter (1-indexed)
- Limit parameter (default 20, max 100)
- Total count in response

### Sorting and Filtering
- Query parameters for filters
- sort_by and sort_order parameters
- Multiple filter support

## Consequences
**Positive:**
- Wide ecosystem support
- Simple and familiar to developers
- Clear API versioning
- Auto-generated documentation
- Stateless authentication

**Negative:**
- Chatty API (multiple requests for complex operations)
- Over-fetching/under-fetching issues
- GraphQL might be better for complex queries

## Alternatives Considered
1. **GraphQL**
   - Pro: Flexible queries, single endpoint
   - Con: Complexity, caching challenges, wider learning curve

2. **gRPC**
   - Pro: High performance, typed contracts
   - Con: Limited browser support, more complex

3. **SOAP**
   - Pro: Standard, enterprise-ready
   - Con: Heavy, outdated, XML-based

4. **WebSocket**
   - Pro: Real-time updates
   - Con: Not suitable for all endpoints, connection overhead

## References
- [RESTful API Design Guide](https://restfulapi.net/)
- [OpenAPI Specification](https://swagger.io/specification/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [RFC 7231 HTTP Methods](https://datatracker.ietf.org/doc/html/rfc7231)
```

---

## V.5 ADR-003: Authentication Strategy

```markdown
# ADR-003: Authentication Strategy

## Status
Accepted

## Context
ScaleCart required a secure, scalable authentication solution supporting:
- User registration and login
- Password management
- Social login (Google, GitHub, Facebook)
- API authentication
- Role-based access control (RBAC)
- Audit logging

## Decision
Implement **OAuth2 + JWT** hybrid authentication:

### Authentication Flow
1. **Registration**: User creates account (email/password)
2. **Login**: User authenticates, receives JWT
3. **Authorization**: JWT validated on each request
4. **Refresh**: Short-lived access tokens + refresh tokens
5. **Logout**: Token invalidation (blacklist)

### Password Management
- **Hashing**: bcrypt with salt rounds = 12
- **Minimum Length**: 8 characters
- **Requirements**: Uppercase, lowercase, number, special character
- **Password Reset**: Secure email-based reset flow

### Social Login Support
- OAuth2 providers: Google, GitHub, Facebook
- Account linking for existing users
- Profile data enrichment

### Role-Based Access Control (RBAC)
- **Roles**: customer, admin, support, employee
- **Permissions**: Fine-grained access control
- **Middleware**: FastAPI dependency injection

### JWT Configuration
- **Algorithm**: HS256 (symmetric) for simplicity
- **Access Token Expiry**: 30 minutes
- **Refresh Token Expiry**: 7 days
- **Claims**: sub (user_id), role, email

### Security Considerations
- **CORS**: Restricted to trusted origins
- **CSRF Protection**: SameSite cookies for web clients
- **Session Security**: HTTP-only, secure cookies
- **Rate Limiting**: Login endpoints (5/min per IP)
- **Account Lockout**: After 5 failed attempts

## Consequences
**Positive:**
- Stateless authentication
- Scalable (no session store needed)
- Industry standard
- Supports multiple client types

**Negative:**
- Token revocation requires blacklist
- Token size overhead
- Refresh token management complexity

## Alternatives Considered
1. **Session-based (Cookie)**
   - Pro: Simple, built-in revocation
   - Con: Not stateless, scaling issues

2. **OAuth2 (Authorization Code Flow)**
   - Pro: Better security, third-party support
   - Con: More complex setup

3. **SAML/SSO**
   - Pro: Enterprise integration
   - Con: Heavy, XML-based

4. **No Authentication (Public)**
   - Pro: Simplest
   - Con: Not feasible for e-commerce

## References
- [OAuth2 RFC 6749](https://tools.ietf.org/html/rfc6749)
- [JWT RFC 7519](https://tools.ietf.org/html/rfc7519)
- [bcrypt Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)
```

---

## V.6 ADR-004: Caching Strategy

```markdown
# ADR-004: Caching Strategy

## Status
Accepted

## Context
ScaleCart required a caching strategy to:
- Reduce database load
- Improve API response times
- Handle high read throughput
- Cache product catalog, sessions, and computed results
- Support cache invalidation and consistency

## Decision
Implement **multi-level caching**:

### Level 1: In-Memory Cache (Python LRU)
- **Use Case**: Repeated function calls within same process
- **Implementation**: functools.lru_cache
- **TTL**: Process lifetime
- **Invalidation**: On code reload

### Level 2: Redis Cache (Distributed)
- **Use Case**: Shared cache across service instances
- **Data Types**: Strings, Hashes, Sets, Sorted Sets
- **TTL**: 3600 seconds (products), 86400 seconds (sessions)
- **Patterns**: Cache-aside, Write-through, Write-behind

### Level 3: CDN (CloudFront)
- **Use Case**: Static assets, images, CSS, JS
- **TTL**: 24 hours
- **Invalidation**: On deployment

### Caching Patterns
1. **Cache-Aside (Lazy Loading)**
   - Read: Check cache, load from DB on miss
   - Write: Update DB, invalidate cache

2. **Write-Through**
   - Write: Update DB and cache simultaneously
   - Read: Serve from cache

3. **Write-Behind**
   - Write: Update cache, async DB update
   - Risk: Data consistency issues

### Cache Invalidation
- **Time-based**: TTL expiration
- **Event-based**: On data changes
- **Manual**: Admin API for cache clearing
- **Pattern**: Delete, not update (avoid consistency issues)

### Cache Key Design
- Consistent format: `{prefix}:{entity}:{id}:{context}`
- Example: `product:123:details`
- Example: `category:5:products`

### Cache Monitoring
- Hit rate metrics (target > 90%)
- Memory usage
- Eviction rate
- Response time improvement

## Consequences
**Positive:**
- Significant performance improvement
- Reduced database load
- Better user experience
- Lower costs

**Negative:**
- Cache invalidation complexity
- Memory overhead
- Potential stale data
- Increased operational complexity

## Alternatives Considered
1. **No Cache**
   - Pro: Simple
   - Con: Poor performance, expensive scaling

2. **Database-only caching (Materialized Views)**
   - Pro: Built-in consistency
   - Con: Not distributed, less flexible

3. **Single Redis Cache (No multi-level)**
   - Pro: Simpler setup
   - Con: Less performance gain, single point of failure

## References
- [Redis Caching Patterns](https://redis.io/topics/patterns)
- [CDN Best Practices](https://aws.amazon.com/cloudfront/best-practices/)
- [Python LRU Cache](https://docs.python.org/3/library/functools.html#functools.lru_cache)
- [Cache-Aside Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/cache-aside)
```

---

## V.7 ADR-005: Deployment Architecture

```markdown
# ADR-005: Deployment Architecture

## Status
Accepted

## Context
ScaleCart needed a deployment architecture that supports:
- High availability (99.95% uptime)
- Zero-downtime deployments
- Auto-scaling
- Multiple environments (dev, staging, production)
- Disaster recovery
- Cost optimization

## Decision
Use **containerized microservices with orchestration**:

### Container Platform: Docker
- Consistent runtime across environments
- Isolation and resource limits
- Reproducible builds
- Multi-stage builds

### Orchestration: Kubernetes (Production)
- Auto-scaling (HPA)
- Self-healing
- Rolling updates
- Service discovery
- Config management

### Load Balancer: AWS ALB / NGINX Ingress
- SSL termination
- Routing
- Health checks
- Web Application Firewall (WAF)

### Infrastructure as Code: Terraform
- Version-controlled infrastructure
- Cloud-agnostic
- State management
- Resource dependencies

### CI/CD: GitHub Actions
- Automated testing
- Build and push images
- Deployment automation
- Rollback capability

### Environment Strategy
1. **Development**: Local Docker Compose
2. **Staging**: Kubernetes (pre-production validation)
3. **Production**: Kubernetes (multi-AZ)

### Deployment Strategy: Blue-Green
- Two identical environments
- Zero-downtime switch
- Instant rollback capability
- Traffic mirroring for canary

### Infrastructure Components
- **API Service**: 3+ replicas
- **Worker Service**: 2+ replicas
- **PostgreSQL**: Multi-AZ RDS with read replicas
- **Redis**: Cluster with sentinel
- **MongoDB**: Replica set
- **Neo4j**: Enterprise cluster
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK stack

## Consequences
**Positive:**
- High availability
- Scalable infrastructure
- Automated deployments
- Clear separation of concerns

**Negative:**
- Complex setup and maintenance
- Higher infrastructure costs
- Required specialized knowledge
- Longer deployment times

## Alternatives Considered
1. **AWS ECS Fargate**
   - Pro: Managed, simpler than Kubernetes
   - Con: Less flexible, vendor lock-in

2. **VM-based (EC2)**
   - Pro: Full control
   - Con: Manual management, scaling challenges

3. **Serverless (Lambda)**
   - Pro: No server management
   - Con: Cold starts, timeout limits, state management

4. **Heroku**
   - Pro: Simple setup
   - Con: Cost, limited customization

## References
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/overview/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Blue-Green Deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [AWS ECS vs EKS](https://aws.amazon.com/containers/)
```

---

## V.8 ADR-006: Event-Driven Architecture

```markdown
# ADR-006: Event-Driven Architecture

## Status
Accepted

## Context
ScaleCart required an event-driven architecture for:
- Order processing workflows
- Inventory updates
- Payment processing
- Customer notifications
- Analytics and reporting
- Decoupling services

## Decision
Implement **event-driven architecture with outbox pattern**:

### Event Types
1. **Domain Events**: OrderCreated, PaymentCompleted, InventoryUpdated
2. **Integration Events**: CustomerRegistered, ProductUpdated
3. **Analytics Events**: PageView, AddToCart, CheckoutStarted

### Event Storage: Outbox Pattern
- **Table**: outbox_messages
- **Transaction**: Same transaction as business operation
- **Publisher**: Separate process reading from outbox
- **Retry**: Exponential backoff with retries

### Message Broker: Redis Pub/Sub (initial), Kafka (future)
- **Redis Pub/Sub**: Simple, low-latency, good for initial scale
- **Kafka**: For high-volume, long-term retention, replay capability

### Event Flow
1. **Business Operation** → Write to outbox
2. **Outbox Publisher** → Read and publish events
3. **Subscribers** → Process events asynchronously
4. **Acknowledgement** → Mark as published

### Event Schema
```json
{
    "id": "uuid",
    "aggregate_id": "string",
    "aggregate_type": "string",
    "event_type": "string",
    "timestamp": "datetime",
    "payload": "object"
}
```

### Event Ordering
- **Per Aggregate**: Strong ordering within same aggregate
- **Across Aggregates**: No ordering guarantee

### Error Handling
- **Failed Publication**: Retry with backoff
- **Failed Processing**: DLQ (Dead Letter Queue)
- **Idempotency**: Deduplication by event_id

## Consequences
**Positive:**
- Loose coupling between services
- Scalable asynchronous processing
- Event sourcing capability
- Audit trail of business events

**Negative:**
- Eventual consistency
- Debugging complexity
- Duplicate event handling
- Additional infrastructure

## Alternatives Considered
1. **Synchronous API Calls**
   - Pro: Simple, predictable
   - Con: Tight coupling, latency issues

2. **Message Queue (RabbitMQ)**
   - Pro: Reliable delivery
   - Con: More complex setup, less flexible

3. **Event Sourcing (Full)**
   - Pro: Complete audit trail
   - Con: Significant complexity, storage overhead

## References
- [Outbox Pattern](https://microservices.io/patterns/data/transactional-outbox.html)
- [Event-Driven Architecture](https://martinfowler.com/articles/201701-event-driven.html)
- [Kafka vs Redis Pub/Sub](https://www.quora.com/What-are-the-differences-between-Kafka-and-Redis-Streams)
- [Idempotency Best Practices](https://stripe.com/blog/idempotency)
```

---

## V.9 ADR-007: Monitoring & Observability Stack

```markdown
# ADR-007: Monitoring & Observability Stack

## Status
Accepted

## Context
ScaleCart needed comprehensive observability for:
- System health monitoring
- Performance tracking
- Error detection and alerting
- Business metrics
- Capacity planning
- Debugging and troubleshooting

## Decision
Adopt **Prometheus + Grafana + ELK + Jaeger** stack:

### Metrics: Prometheus
- **Scraping**: Pull-based metrics collection
- **Storage**: Time-series database
- **Query Language**: PromQL
- **Alerting**: AlertManager with rules

### Visualization: Grafana
- Dashboards for all services
- Alert visualization
- Custom panels and queries
- Annotation support

### Logging: ELK Stack
- **Elasticsearch**: Log storage and search
- **Logstash**: Log processing and enrichment
- **Kibana**: Log visualization and exploration

### Tracing: Jaeger (OpenTelemetry)
- Distributed tracing
- Service dependency mapping
- Request flow visualization
- Performance bottleneck identification

### Health Checks
- **Liveness**: /health/live (container health)
- **Readiness**: /health/ready (service readiness)
- **Full Health**: /health/full (all dependencies)

### Key Metrics
1. **Application**: Request rate, latency, error rate
2. **Database**: Connections, query time, cache hit ratio
3. **Cache**: Hit rate, memory usage, eviction rate
4. **Infrastructure**: CPU, memory, disk, network

### Alerting
- **Critical**: Service down, database unreachable
- **Warning**: High error rate, slow responses
- **Info**: Deployment success, resource usage

### Dashboards
1. **API Performance**: Request rate, latency, errors
2. **Database**: Connections, query performance, storage
3. **Cache**: Hit rate, memory, operations
4. **Infrastructure**: CPU, memory, disk, network
5. **Business**: Orders, revenue, active users

## Consequences
**Positive:**
- Comprehensive observability
- Open-source, well-supported tools
- Scalable and cost-effective
- Rich visualization options

**Negative:**
- Multiple tools to manage
- Configuration complexity
- Storage costs for logs and metrics
- Learning curve for each tool

## Alternatives Considered
1. **Cloud Native (AWS CloudWatch + X-Ray)**
   - Pro: Managed, integrated
   - Con: Vendor lock-in, higher cost

2. **Datadog (All-in-one)**
   - Pro: Integrated, easy setup
   - Con: Expensive for large scale

3. **New Relic**
   - Pro: Full-stack observability
   - Con: Cost, vendor lock-in

4. **Splunk**
   - Pro: Powerful search
   - Con: Very expensive

## References
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Four Golden Signals](https://sre.google/sre-book/monitoring-distributed-systems/)
```

---

## V.10 ADR-008: Security Architecture

```markdown
# ADR-008: Security Architecture

## Status
Accepted

## Context
ScaleCart required a comprehensive security architecture covering:
- Authentication and authorization
- Data protection (encryption at rest and in transit)
- API security (rate limiting, input validation)
- Secrets management
- Compliance (GDPR, PCI-DSS)
- Security monitoring and incident response

## Decision
Implement **defense-in-depth** security approach:

### Authentication & Authorization
- **Authentication**: JWT with OAuth2 social login
- **Authorization**: RBAC with fine-grained permissions
- **Password Hashing**: bcrypt (work factor 12)
- **Session Management**: HTTP-only, secure cookies
- **MFA**: TOTP support (planned)

### Data Protection
- **In Transit**: TLS 1.2+ for all connections
- **At Rest**: AES-256 encryption for databases
- **Sensitive Data**: pgcrypto for field-level encryption
- **Backup Encryption**: AES-256

### API Security
- **Rate Limiting**: Per client/IP rate limits
- **Input Validation**: Pydantic validation
- **SQL Injection**: Parameterized queries
- **XSS Protection**: Output encoding
- **CSRF Protection**: SameSite cookies
- **CORS**: Strict origin validation

### Secrets Management
- **Storage**: AWS Secrets Manager / HashiCorp Vault
- **Rotation**: Automated rotation where possible
- **Access**: IAM policies and roles
- **Audit**: Secret access logging

### Compliance
- **GDPR**: Right to erasure, data portability
- **PCI-DSS**: Payment data tokenization
- **SOC2**: Security and availability controls

### Security Monitoring
- **Audit Logging**: All access and modifications
- **Intrusion Detection**: AWS GuardDuty
- **Vulnerability Scanning**: Snyk, Trivy
- **Penetration Testing**: Quarterly
- **Security Headers**: HSTS, CSP, X-Frame-Options

### Incident Response
- **Runbook**: Documented incident response
- **Escalation**: Defined escalation path
- **Communication**: Incident communication templates
- **Post-Mortem**: Root cause analysis after incidents

## Consequences
**Positive:**
- Comprehensive security coverage
- Regulatory compliance
- Defense-in-depth protection
- Audit-ready architecture

**Negative:**
- Complexity in implementation
- Performance overhead (encryption)
- Maintenance burden
- Training requirements

## Alternatives Considered
1. **Single-layer Security**
   - Pro: Simpler
   - Con: Vulnerable to attacks

2. **Third-party Security (Auth0, Okta)**
   - Pro: Managed, expertise
   - Con: Cost, vendor lock-in

3. **Homomorphic Encryption**
   - Pro: Can process encrypted data
   - Con: Not mature, performance issues

## References
- [OWASP Top 10](https://owasp.org/Top10/)
- [AWS Well-Architected Framework - Security](https://aws.amazon.com/architecture/well-architected/)
- [GDPR Compliance Checklist](https://gdpr.eu/checklist/)
- [PCI-DSS Requirements](https://www.pcisecuritystandards.org/pci_security/)
```

---

## V.11 ADR-009: Testing Strategy

```markdown
# ADR-009: Testing Strategy

## Status
Accepted

## Context
ScaleCart needed a comprehensive testing strategy ensuring:
- Code quality and reliability
- Performance at scale
- Security vulnerabilities
- Integration with external services
- Deployment validation

## Decision
Implement **testing pyramid** with multiple levels:

### Unit Tests
- **Coverage Target**: 80%+
- **Frameworks**: pytest, unittest
- **Scope**: Individual functions and classes
- **Isolation**: Mock external dependencies

### Integration Tests
- **Coverage Target**: 70%+
- **Frameworks**: pytest with fixtures
- **Scope**: Database, API, external services
- **Isolation**: Test containers (Docker)

### Contract Tests
- **Frameworks**: Pact (for microservices)
- **Scope**: API contracts between services
- **Validation**: Consumer-driven contracts

### Performance Tests
- **Frameworks**: Locust, JMeter
- **Scope**: API performance under load
- **Metrics**: Response time, throughput, error rate

### Security Tests
- **Frameworks**: OWASP ZAP, Snyk, Trivy
- **Scope**: Vulnerabilities, dependencies
- **Frequency**: Every build and on demand

### End-to-End Tests
- **Frameworks**: Playwright, Selenium
- **Scope**: Complete user workflows
- **Validation**: User journeys and business logic

### Smoke Tests
- **Frameworks**: Custom scripts (curl, shell)
- **Scope**: Deployment validation
- **Frequency**: Every deployment

### Monitoring Tests
- **Frameworks**: Prometheus, Grafana
- **Scope**: System health in production
- **Frequency**: Continuous

### Test Environments
1. **Dev**: Local Docker Compose
2. **CI**: Isolated Docker containers
3. **Staging**: Full Kubernetes environment
4. **Production**: Canary deployment

### Continuous Testing
- **CI Pipeline**: Unit, integration, security tests
- **Deployment**: Smoke tests, health checks
- **Production**: Synthetic monitoring

## Consequences
**Positive:**
- High code quality
- Reduced defects
- Confidence in deployments
- Security vulnerabilities identified early

**Negative:**
- Significant test maintenance
- Longer CI pipeline
- Infrastructure for test environments

## Alternatives Considered
1. **Test-After Development**
   - Pro: Faster initial delivery
   - Con: Lower quality, more bugs

2. **Manual Testing Only**
   - Pro: No automation cost
   - Con: Unreliable, inconsistent

3. **Chaos Engineering**
   - Pro: Resilience testing
   - Con: Not a replacement for standard testing

## References
- [Test Pyramid](https://martinfowler.com/bliki/TestPyramid.html)
- [Pytest Documentation](https://docs.pytest.org/)
- [OWASP ZAP](https://www.zaproxy.org/)
- [Testing Kubernetes Applications](https://kubernetes.io/docs/tutorials/)
```

---

## V.12 ADR Template for Future Decisions

```markdown
# ADR-XXX: [Decision Title]

## Status
[Proposed | Accepted | Deprecated | Superseded]

## Context
[Describe the context and problem that prompted this decision]

## Decision
[Describe the decision that was made]

## Consequences
[Describe the consequences of this decision]

### Positive
- [List positive consequences]

### Negative
- [List negative consequences]

### Neutral
- [List neutral consequences]

## Alternatives Considered
### Alternative 1: [Name]
- **Pro**: [List pros]
- **Con**: [List cons]
- **Why Rejected**: [Explanation]

### Alternative 2: [Name]
- **Pro**: [List pros]
- **Con**: [List cons]
- **Why Rejected**: [Explanation]

## Implementation
- **Required Changes**: [List changes]
- **Dependencies**: [List dependencies]
- **Migration Plan**: [Describe migration]
- **Rollback Plan**: [Describe rollback]

## References
- [Link to relevant documentation]
- [Link to discussions]
- [Link to related ADRs]

## Decision Date
[YYYY-MM-DD]

## Decision Makers
- [Name, Role]
- [Name, Role]

## Review Date
[YYYY-MM-DD]
```

---

**[END OF APPENDIX V]**

*This comprehensive ADR appendix documents the key architectural decisions behind the ScaleCart platform. Use these records to understand the rationale behind design choices and to inform future decisions.*
