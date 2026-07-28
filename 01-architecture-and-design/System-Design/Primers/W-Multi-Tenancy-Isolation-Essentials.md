# Primer W: Multi-Tenancy Isolation Essentials

Most modern SaaS systems are multi-tenant: a single running system serves many customers (tenants). Isolation is what prevents one tenant from seeing another tenant’s data or from harming the performance and availability of others. This primer covers the essential mental models and techniques.

### 1. What Multi-Tenancy Means

A **tenant** is a customer or organizational unit that expects its data and usage to be separate from everyone else’s. Examples:

- A company using your project-management tool
- A workspace in a collaboration product
- A customer account in an analytics platform

**Multi-tenancy** means many tenants share the same application and usually much of the same infrastructure, while still receiving strong logical (and sometimes physical) separation.

### 2. The Two Isolation Goals

1. **Data isolation**  
   Tenant A must never be able to read or write Tenant B’s data.

2. **Performance / noisy-neighbor isolation**  
   Heavy usage (or misbehavior) by Tenant A must not significantly degrade the experience of Tenant B.

Both are required. Perfect data isolation with terrible noisy-neighbor behavior still produces an unacceptable product.

### 3. Data Isolation Approaches

| Approach | How it works | Strengths | Trade-offs |
|----------|--------------|-----------|------------|
| **Shared tables with tenant_id** | Every row carries a tenant identifier; every query filters by it | Simple, cost-efficient, easy to operate | Risk of application bugs leaking data; harder to restore a single tenant |
| **Separate schema per tenant** | Each tenant gets its own database schema | Stronger separation, easier per-tenant operations | More operational complexity at large scale |
| **Separate database per tenant** | Each tenant gets its own database | Strong isolation, independent scaling and restore | Higher cost and operational overhead |
| **Hybrid** | Small tenants share; large tenants get dedicated resources | Balances cost and isolation | More routing and provisioning logic |

Most systems start with shared tables + a mandatory `tenant_id` (or equivalent) on every relevant row and in every query. Larger or higher-security customers may later be moved to dedicated resources.

**Critical rule**: the tenant filter must be applied consistently — ideally in a single, well-tested place (middleware, query builder, row-level security, etc.) rather than manually in every SQL statement.

### 4. Noisy-Neighbor Isolation Techniques

Even with perfect data separation, one tenant can still hurt others by consuming too many resources.

Common defenses:

- **Per-tenant rate limiting**  
  Limit requests, API calls, or jobs per tenant.

- **Per-tenant quotas**  
  Cap storage, number of records, concurrent connections, background jobs, etc.

- **Separate connection pools or concurrency limits**  
  Prevent one tenant from exhausting the database connection pool.

- **Workload isolation**  
  Put heavy or unpredictable work (exports, large reports, search indexing) onto separate queues or worker pools.

- **Throttling and prioritization**  
  Under load, prefer smaller or higher-priority tenants.

- **Dedicated resources for large tenants**  
  Move the noisiest customers onto their own compute or database instances.

### 5. Authentication and Authorization Implications

In a multi-tenant system every request must establish two things:

1. **Who is the user?** (Authentication)
2. **Which tenant(s) are they allowed to act in, and with what permissions?** (Authorization)

A common pattern:

- The user authenticates and receives a token that includes tenant membership and roles.
- Every subsequent request carries that identity.
- The application enforces that the user may only access data belonging to tenants they belong to, and only performs actions allowed by their role.

Never trust a client-supplied tenant ID without verifying membership.

### 6. Common Failure Modes

- Forgetting the tenant filter on a new query → cross-tenant data leak.
- Using a global cache key that does not include tenant ID → one tenant sees another’s data.
- Shared rate limits with no per-tenant breakdown → one tenant can exhaust the global limit.
- Background jobs that process all tenants in one batch without isolation or prioritization → one large tenant delays everyone else.
- Backup and restore processes that cannot restore a single tenant independently.

### 7. Design Checklist

When reviewing a multi-tenant design, ask:

- How is tenant identity attached to every piece of data?
- Where is the tenant filter enforced, and how do we prevent it from being forgotten?
- How are caches keyed? Do they include tenant identity?
- What per-tenant limits and quotas exist?
- What happens when one tenant generates 100× normal load?
- Can we restore or delete a single tenant without affecting others?
- How is tenant membership and authorization determined on each request?

### 8. What You Should Be Able to Do After This Primer

- Define multi-tenancy and the two primary isolation goals.
- Compare shared-table, separate-schema, and separate-database approaches.
- Explain why a mandatory tenant filter is necessary and where it should be enforced.
- List practical techniques for protecting against noisy neighbors.
- Describe how authentication tokens and authorization checks typically incorporate tenant context.
- Identify common cross-tenant leakage and noisy-neighbor failure modes in a design.

This primer supports the security, isolation, and production topics in Part 6 and is directly relevant to most real SaaS blueprints in Part 7.

**[END OF PRIMER W]**
