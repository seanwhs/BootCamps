# Primer AD: Common Security Anti-Patterns

Security problems in system design are often less about exotic attacks and more about repeated, predictable mistakes. This primer lists the most common anti-patterns that appear in architecture discussions and real systems, along with practical corrections.

### 1. Why Anti-Patterns Matter

Most serious incidents involving data leaks, privilege escalation, or service compromise trace back to a small set of recurring design and implementation errors. Recognizing these patterns lets you avoid them early—while the system is still on the whiteboard.

### 2. Anti-Pattern Catalog

| Anti-Pattern | What it looks like | Why it hurts | Better approach |
|--------------|--------------------|--------------|-----------------|
| **Trusting the client** | Authorization or tenant ID taken from the request body/headers without server-side verification | Attackers can simply change the ID and access other tenants’ data | Always establish identity server-side; treat any client-supplied tenant/user ID as a claim that must be verified |
| **Security only at the UI** | UI hides buttons, but the API has no authorization checks | Anyone who can call the API directly bypasses the controls | Enforce authentication and authorization on every API endpoint |
| **Long-lived, powerful secrets** | Static API keys or passwords that never rotate and have broad permissions | A single leak gives lasting, wide access | Prefer short-lived credentials, least privilege, and automated rotation |
| **Secrets in code or images** | Passwords, keys, or tokens committed to git or baked into container images | Source code and images leak frequently | Inject secrets at runtime from a secret manager |
| **Overly privileged service accounts** | One service account that can read/write everything | Compromise of any single service becomes a full system compromise | Give each service the minimum permissions it needs |
| **No network isolation** | All services can talk to all other services and databases | Lateral movement becomes trivial after one compromise | Default-deny network policies; allow only required paths |
| **Missing or weak authentication between services** | Internal traffic assumed “safe” because it is inside the VPC | Once an attacker is inside, everything is reachable | Use mTLS, workload identity, or short-lived service tokens even for internal calls |
| **Logging sensitive data** | Tokens, passwords, personal data, or full request bodies written to logs | Logs become a treasure trove for attackers and a compliance liability | Scrub secrets and sensitive PII before logging |
| **Privilege escalation via feature flags or admin APIs** | Flags or admin endpoints that can grant broad access without strong controls | A single bug or misconfiguration creates super-users | Treat privilege-granting operations with the same care as authentication itself |
| **Insecure direct object references** | URLs or IDs that let any authenticated user access any object by guessing the ID | Horizontal privilege escalation | Always check that the authenticated user is allowed to access the specific object |
| **Relying solely on perimeter security** | Strong edge defenses but flat internal trust | Classic “soft inside” problem; zero-trust principles are ignored | Authenticate and authorize every request, even internal ones |
| **Ignoring the threat of compromised dependencies** | No process for scanning or updating third-party libraries and base images | Supply-chain attacks and known CVEs remain exploitable | Automated vulnerability scanning + regular patching cadence |

### 3. Multi-Tenant Specific Anti-Patterns

| Anti-Pattern | Better approach |
|--------------|-----------------|
| Forgetting `tenant_id` in a query or cache key | Centralize tenant filtering; include tenant in every cache key |
| Global rate limits only | Add per-tenant (and often per-user) rate limits and quotas |
| Shared mutable state without isolation | Prefer designs that make cross-tenant influence impossible by construction |
| One noisy tenant able to exhaust shared connection pools or queues | Bulkheads, per-tenant concurrency limits, separate worker pools |

### 4. Practical Design Checklist

When reviewing any design, ask:

- Where is authentication performed, and what credential is used?
- Where is authorization performed, and does it cover every path to the data?
- Can a user or service act on a tenant or object they do not own simply by changing an ID?
- How are secrets stored, injected, and rotated?
- What is the blast radius if this service’s credentials are stolen?
- Is internal traffic authenticated, or do we still have a flat trust network?
- Do logs and traces ever contain secrets or sensitive personal data?
- Are privilege-escalating operations specially protected?

### 5. Relationship to Earlier Primers

- **Primer V** (Secrets Management) addresses storage and injection of secrets.
- **Primer Y** (Authentication vs Authorization) clarifies the two core questions.
- **Primer W** (Multi-Tenancy Isolation) covers data and noisy-neighbor separation.
- **Primer M / N / O** (Circuit breakers, bulkheads, graceful degradation) limit the impact of compromised or misbehaving components.
- This primer focuses on the recurring *mistakes* that undermine those controls.

### 6. What Good Looks Like (Short Version)

- Identity is established on every request (user or service).
- Authorization is checked on every sensitive action and object access.
- Secrets are short-lived or regularly rotated and never stored in code or images.
- Network and permission policies follow least privilege and default-deny.
- Multi-tenant boundaries are enforced in data access, caching, and rate limiting.
- Sensitive data is kept out of logs.
- The design assumes that any single component can be compromised and limits the resulting damage.

### 7. What You Should Be Able to Do After This Primer

- Recognize the most common security anti-patterns in an architecture discussion.
- Explain why “the UI already prevents that” is never a sufficient authorization strategy.
- Describe practical alternatives to long-lived, overly powerful secrets.
- Identify multi-tenant data-leakage and noisy-neighbor risks.
- Ask focused, high-leverage security questions during a design review.
- Connect security controls to the broader reliability and isolation patterns already covered.

This primer strengthens the security material in Part 6 and is especially useful when evaluating real designs or preparing for interviews that probe threat awareness.

**[END OF PRIMER AD]**
