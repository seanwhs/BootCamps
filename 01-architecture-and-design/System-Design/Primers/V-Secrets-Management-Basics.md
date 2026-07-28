# Primer V: Secrets Management Basics

Secrets (passwords, API keys, database credentials, certificates, encryption keys, etc.) are one of the most common sources of serious security incidents. This primer covers the practical rules and patterns for handling them safely in modern systems.

### 1. What Counts as a Secret

Anything that grants access or protects data:

- Database usernames and passwords
- API keys and tokens
- Private keys and certificates
- Encryption / signing keys
- OAuth client secrets
- Service-account credentials
- Webhook signing secrets

If an attacker obtaining the value would let them impersonate your system or read sensitive data, treat it as a secret.

### 2. The Golden Rules

1. **Never store secrets in source code or configuration committed to git.**  
2. **Never bake secrets into container images or VM images.**  
3. **Inject secrets at runtime** from a secure store.  
4. **Give every service or component only the secrets it actually needs** (least privilege).  
5. **Make secrets rotatable** without requiring a full code redeployment whenever possible.  
6. **Audit access** to secrets.

These rules exist because source code, images, and logs leak far more often than people expect.

### 3. Where Secrets Should Live

| Environment | Recommended approach |
|-------------|----------------------|
| Local development | Developer-specific secrets via environment variables, a local encrypted file, or a personal entry in a secret manager. Never shared “dev” passwords in git. |
| CI / CD pipelines | Short-lived credentials issued by the pipeline’s identity system, or secrets injected from a secret manager. |
| Production | A dedicated secret manager or cloud provider secret service. |
| Kubernetes | External secret operator or cloud secret store → injected as environment variables or mounted files. Avoid plain Kubernetes Secrets for highly sensitive values unless encrypted at rest and tightly access-controlled. |

Popular tools and services include HashiCorp Vault, AWS Secrets Manager, AWS SSM Parameter Store, Google Secret Manager, Azure Key Vault, and similar offerings.

### 4. Injection Patterns

**Environment variables**  
Simple and widely supported. The process reads `os.Getenv("DB_PASSWORD")` or equivalent. Good for many applications.

**Mounted files**  
The secret is written to a file on a memory-backed volume. Useful for larger secrets or when the application expects a file (TLS certificates, etc.).

**Sidecar or agent**  
A local agent retrieves and refreshes secrets; the application talks only to the local agent. Common with Vault.

**Dynamic secrets**  
Some systems (especially Vault) can generate short-lived, unique credentials on demand (for example, a database user that exists only for one hour). This is the gold standard when available.

### 5. Rotation

Secrets should not live forever. Rotation means replacing a secret with a new value and ensuring all legitimate consumers pick up the new value.

Good practices:

- Prefer short-lived credentials so rotation is automatic and frequent.
- For longer-lived secrets, support dual values during a transition window (similar to expand/contract): the system accepts both the old and new secret until all clients have switched.
- Automate rotation wherever possible; manual rotation is error-prone and often delayed.

### 6. Common Anti-Patterns (Avoid These)

- Secrets in `.env` files committed to the repository
- Secrets in Docker images or AMI / machine images
- Secrets printed to application logs
- One shared “god” credential used by many services
- Long-lived static access keys with broad permissions
- Secrets passed on the command line (visible in process lists)

### 7. Relationship to Identity

Modern systems increasingly prefer **identity-based access** over static secrets:

- Cloud IAM roles / managed identities
- Workload identity (Kubernetes service accounts bound to cloud identities)
- Mutual TLS with short-lived certificates
- OIDC / SPIFFE-style service identities

When a workload can prove “I am the order service” to the cloud platform, the platform can grant it temporary access to a database or queue without embedding a long-lived password. This is generally safer than distributing static secrets.

### 8. Minimal Practical Checklist

For any new service ask:

- Where does each secret come from at runtime?
- Is it possible to rotate this secret without redeploying the binary?
- Does this service have only the permissions it needs?
- Could we replace this static secret with a short-lived or identity-based credential?
- Are secrets ever written to logs or error messages?

### 9. What You Should Be Able to Do After This Primer

- List the main categories of secrets and explain why they must be protected.
- State the core rules (no secrets in git or images, inject at runtime, least privilege, rotatable).
- Describe two common ways secrets are injected into a running process.
- Explain why short-lived and dynamic credentials are preferable to long-lived static ones.
- Recognize dangerous anti-patterns in a design or codebase.
- Relate secret management to broader identity and least-privilege practices.

This primer supports the security and production-engineering topics in Part 6 and is relevant to any design that must run safely in a real environment.

**[END OF PRIMER V]**
