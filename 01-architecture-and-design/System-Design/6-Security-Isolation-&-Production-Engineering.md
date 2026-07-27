# Part 6 – Security, Isolation & Production Engineering

A system that is fast and reliable is still not production-ready if it is easy to attack, hard to operate, or dangerous to change. This part covers the security boundaries, identity, isolation, and operational practices that turn an architecture diagram into something real teams can run safely.

By the end you will know how to protect service boundaries, manage secrets, limit blast radius, and ship changes with confidence.

---

### 6.1 Microservice Boundary Security & Zero-Trust Principles

**The Target**  
Understand why perimeter security is no longer enough and how zero-trust changes the way services authenticate each other.

**The Concept**  
Traditional “castle-and-moat” security assumes everything inside the network is trusted. In a microservice world that assumption is false: a single compromised service or developer laptop can become a pivot point.

**Zero-trust** means:

- Never trust, always verify.  
- Every request is authenticated and authorized, even inside the private network.  
- Least privilege is applied at every hop.  
- Encryption in transit is the default (mTLS).

**Analogy**  
Instead of a single locked front door, every room in the building requires its own keycard, and the keycard is checked on every entry.

**The Implementation**  
A minimal mutual-TLS mental model and a token-based service-to-service identity example (the pattern most teams start with before full mTLS mesh).

```python
# file: part6/zero_trust_identity.py
import hmac
import hashlib
import time
import secrets
from dataclasses import dataclass
from typing import Optional

@dataclass
class ServiceIdentity:
    name: str
    secret: str                     # in reality this lives in a secret manager

class TokenIssuer:
    """Issues short-lived tokens for service-to-service calls."""
    def __init__(self, issuer_name: str, signing_key: str):
        self.issuer_name = issuer_name
        self.signing_key = signing_key.encode()

    def issue(self, audience: str, ttl_seconds: int = 60) -> str:
        exp = int(time.time()) + ttl_seconds
        payload = f"{self.issuer_name}:{audience}:{exp}"
        sig = hmac.new(self.signing_key, payload.encode(), hashlib.sha256).hexdigest()
        return f"{payload}:{sig}"

    def verify(self, token: str, expected_audience: str) -> bool:
        try:
            issuer, audience, exp, sig = token.rsplit(":", 3)
            if audience != expected_audience:
                return False
            if int(exp) < time.time():
                return False
            payload = f"{issuer}:{audience}:{exp}"
            expected_sig = hmac.new(self.signing_key, payload.encode(), hashlib.sha256).hexdigest()
            return hmac.compare_digest(sig, expected_sig)
        except Exception:
            return False

# ---------- Demo ----------
if __name__ == "__main__":
    # Shared signing key (in production this comes from a secret manager)
    SIGNING_KEY = secrets.token_hex(32)

    issuer = TokenIssuer("order-service", SIGNING_KEY)
    token = issuer.issue(audience="payment-service", ttl_seconds=30)
    print("Issued token:", token)

    # Payment service verifies the token
    verifier = TokenIssuer("payment-service", SIGNING_KEY)   # same key material
    print("Token valid for payment-service?", verifier.verify(token, "payment-service"))
    print("Token valid for inventory-service?", verifier.verify(token, "inventory-service"))
```

**The Verification**  
```bash
cd part6
python zero_trust_identity.py
```
You will see a short-lived token that validates only for the intended audience. In production this pattern is usually replaced by a service mesh (Istio, Linkerd, Consul Connect) or cloud IAM roles that issue tokens automatically.

---

### 6.2 API Authentication / Authorization & Secrets Management

**The Target**  
Protect external APIs with proper authentication and authorization, and keep secrets out of source code and images.

**The Concept**  

- **Authentication** (“who are you?”) – typically JWT, API keys, OAuth2, or mTLS.  
- **Authorization** (“what are you allowed to do?”) – RBAC, ABAC, or policy engines (OPA).  
- **Secrets management** – never store passwords, API keys, or certificates in git or Docker images. Use a dedicated secret store (HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Kubernetes Secrets with encryption at rest, etc.).

**The Implementation**  
A complete, minimal JWT-style authentication + role-based authorization middleware, plus a safe way to load secrets from environment variables.

```python
# file: part6/auth_and_secrets.py
import os
import time
import hmac
import hashlib
import json
import base64
from functools import wraps
from typing import Callable, List, Optional

# ---------- Secret loading (never hard-code) ----------
def get_secret(name: str, default: Optional[str] = None) -> str:
    value = os.environ.get(name, default)
    if value is None:
        raise RuntimeError(f"Required secret {name} is not set")
    return value

# ---------- Minimal JWT-like token (for illustration only) ----------
class SimpleJWT:
    def __init__(self, secret: str):
        self.secret = secret.encode()

    def _b64(self, data: bytes) -> str:
        return base64.urlsafe_b64encode(data).rstrip(b"=").decode()

    def _unb64(self, data: str) -> bytes:
        padding = 4 - len(data) % 4
        return base64.urlsafe_b64decode(data + "=" * padding)

    def issue(self, sub: str, roles: List[str], ttl: int = 3600) -> str:
        header = self._b64(json.dumps({"alg": "HS256", "typ": "JWT"}).encode())
        payload = self._b64(json.dumps({
            "sub": sub,
            "roles": roles,
            "exp": int(time.time()) + ttl,
        }).encode())
        sig = hmac.new(self.secret, f"{header}.{payload}".encode(), hashlib.sha256).digest()
        return f"{header}.{payload}.{self._b64(sig)}"

    def verify(self, token: str) -> Optional[dict]:
        try:
            header_b64, payload_b64, sig_b64 = token.split(".")
            expected_sig = hmac.new(
                self.secret, f"{header_b64}.{payload_b64}".encode(), hashlib.sha256
            ).digest()
            if not hmac.compare_digest(self._b64(expected_sig), sig_b64):
                return None
            payload = json.loads(self._unb64(payload_b64))
            if payload["exp"] < time.time():
                return None
            return payload
        except Exception:
            return None

# ---------- Authorization decorator ----------
def require_roles(*required_roles: str):
    def decorator(fn: Callable):
        @wraps(fn)
        def wrapper(claims: dict, *args, **kwargs):
            user_roles = set(claims.get("roles", []))
            if not user_roles.intersection(required_roles):
                raise PermissionError(f"Requires one of {required_roles}")
            return fn(claims, *args, **kwargs)
        return wrapper
    return decorator

# ---------- Example protected handlers ----------
jwt = SimpleJWT(get_secret("JWT_SECRET", "dev-only-change-me"))

@require_roles("admin", "order:write")
def create_order(claims: dict, order_id: str):
    return {"status": "created", "order_id": order_id, "by": claims["sub"]}

@require_roles("admin", "order:read")
def get_order(claims: dict, order_id: str):
    return {"order_id": order_id, "status": "paid"}

if __name__ == "__main__":
    # Issue tokens for different users
    admin_token = jwt.issue("alice", roles=["admin"])
    user_token = jwt.issue("bob", roles=["order:read"])

    print("Admin token:", admin_token)
    print("User token:", user_token)

    # Simulate request handling
    for label, token in [("admin", admin_token), ("user", user_token)]:
        claims = jwt.verify(token)
        print(f"\n--- {label} ---")
        try:
            print("create_order:", create_order(claims, "ord-1"))
        except PermissionError as e:
            print("create_order denied:", e)
        try:
            print("get_order:", get_order(claims, "ord-1"))
        except PermissionError as e:
            print("get_order denied:", e)
```

**The Verification**  
```bash
export JWT_SECRET="super-secret-value-change-in-prod"
python auth_and_secrets.py
```
The admin token can both create and read; the ordinary user token can only read. The secret is loaded from the environment, never from source.

---

### 6.3 Resource Isolation, Rate Limiting & DDoS-Style Protection

**The Target**  
Limit the damage any single client, tenant, or runaway process can inflict.

**The Concept**  
Even with authentication, a legitimate (or compromised) client can still overwhelm the system. Defense in depth includes:

- Per-client / per-tenant rate limits.  
- Connection and concurrency limits.  
- Bulkheads (already covered in Part 5).  
- Edge-level protection (CDN, WAF, cloud DDoS shields).  
- Graceful rejection (429 Too Many Requests) instead of cascading failure.

**The Implementation**  
A practical per-API-key token-bucket rate limiter that can be placed at the gateway or inside each service.

```python
# file: part6/per_client_rate_limit.py
import time
import threading
from collections import defaultdict
from dataclasses import dataclass

@dataclass
class Bucket:
    tokens: float
    last_refill: float

class PerClientRateLimiter:
    def __init__(self, rate: float = 10.0, capacity: float = 20.0):
        self.rate = rate
        self.capacity = capacity
        self.buckets: dict[str, Bucket] = {}
        self.lock = threading.Lock()

    def allow(self, client_id: str) -> bool:
        with self.lock:
            now = time.monotonic()
            bucket = self.buckets.get(client_id)
            if bucket is None:
                bucket = Bucket(tokens=self.capacity, last_refill=now)
                self.buckets[client_id] = bucket

            # Refill
            elapsed = now - bucket.last_refill
            bucket.tokens = min(self.capacity, bucket.tokens + elapsed * self.rate)
            bucket.last_refill = now

            if bucket.tokens >= 1:
                bucket.tokens -= 1
                return True
            return False

if __name__ == "__main__":
    limiter = PerClientRateLimiter(rate=5, capacity=10)

    def simulate_client(client_id: str, requests: int):
        allowed = 0
        for _ in range(requests):
            if limiter.allow(client_id):
                allowed += 1
            time.sleep(0.05)
        print(f"{client_id}: {allowed}/{requests} allowed")

    # Two clients, one of them aggressive
    t1 = threading.Thread(target=simulate_client, args=("client-A", 30))
    t2 = threading.Thread(target=simulate_client, args=("client-B", 30))
    t1.start()
    t2.start()
    t1.join()
    t2.join()
```

**The Verification**  
```bash
python per_client_rate_limit.py
```
Each client is limited independently. One noisy client cannot starve the other—an essential property for multi-tenant systems and for surviving DDoS-style traffic.

---

### 6.4 Operational Concerns – Deployments, Configuration, Rollouts & Safe Migrations

**The Target**  
Ship changes without taking the system down or corrupting data.

**The Concept**  

| Concern              | Good practice                                      | Bad practice                     |
|----------------------|----------------------------------------------------|----------------------------------|
| Configuration        | Environment variables / config service, immutable images | Config baked into the image or changed by SSH |
| Deployments          | Rolling, blue-green, or canary                     | “Stop everything, copy files, start” |
| Rollbacks            | Instant traffic shift back to previous version     | Manual rebuild of the old version |
| Database migrations  | Expand/contract (additive first, then remove)      | Destructive changes in one step  |
| Feature flags        | Decouple deployment from release                   | Big-bang feature launches        |

**Expand/contract migration example**  
1. Add new column / table (expand).  
2. Deploy code that writes to both old and new.  
3. Backfill data.  
4. Deploy code that reads from the new place.  
5. Remove old column (contract).

**The Implementation**  
A concrete illustration of a safe two-phase migration and a simple feature-flag check.

```python
# file: part6/safe_migration_and_flags.py
from typing import Optional
import os

# ---------- Feature flags (in reality use LaunchDarkly, Unleash, etc.) ----------
def flag_enabled(name: str, default: bool = False) -> bool:
    return os.environ.get(f"FLAG_{name.upper()}", str(default)).lower() in ("1", "true", "yes")

# ---------- Simulated database rows during migration ----------
class UserStore:
    """Illustrates expand/contract for renaming 'username' → 'display_name'."""
    def __init__(self):
        # Phase 0: only old column
        self.rows = {
            1: {"id": 1, "username": "alice"},
            2: {"id": 2, "username": "bob"},
        }

    def expand(self):
        """Phase 1: add new column, keep old."""
        for row in self.rows.values():
            row["display_name"] = row.get("username")

    def dual_write(self, user_id: int, name: str):
        """Phase 2: application writes to both columns."""
        row = self.rows[user_id]
        row["username"] = name
        row["display_name"] = name

    def read_new(self, user_id: int) -> Optional[str]:
        """Phase 3: application reads from new column."""
        return self.rows[user_id].get("display_name")

    def contract(self):
        """Phase 4: remove old column."""
        for row in self.rows.values():
            row.pop("username", None)

if __name__ == "__main__":
    store = UserStore()
    print("Phase 0 (old only):", store.rows)

    store.expand()
    print("Phase 1 (expanded):", store.rows)

    store.dual_write(1, "Alice Wonderland")
    print("Phase 2 (dual write):", store.rows)

    print("Read via new field:", store.read_new(1))

    store.contract()
    print("Phase 4 (contracted):", store.rows)

    # Feature flag example
    if flag_enabled("NEW_CHECKOUT", default=False):
        print("New checkout flow active")
    else:
        print("Old checkout flow active")
```

**The Verification**  
```bash
python safe_migration_and_flags.py
FLAG_NEW_CHECKOUT=true python safe_migration_and_flags.py
```
You can watch the data model evolve without ever losing the ability to read or write, and you can toggle behavior with an environment variable.

---

### Reference Section – Production Security & Ops Checklist

| Area                     | Minimum bar                                              |
|--------------------------|----------------------------------------------------------|
| Service-to-service auth  | mTLS or short-lived tokens with audience checks          |
| External API auth        | JWT / OAuth2 + HTTPS only                                |
| Secrets                  | Never in git or images; injected at runtime              |
| Rate limiting            | Per-client and global, at the edge and inside services   |
| Network policies         | Deny-by-default between namespaces / security groups     |
| Deployments              | Rolling or canary with automatic health-check gates      |
| Database changes         | Expand/contract; never destructive in one step           |
| Configuration            | Immutable images + external config; no SSH mutation      |
| Observability of security| Audit logs for authz failures, secret access, admin actions |

---

### What You Can Do Now

Before any service is considered production-ready you can ask:

1. Is every request authenticated and authorized, even inside the private network?  
2. Are all secrets injected at runtime and rotatable without rebuilding images?  
3. Can a single client or tenant be rate-limited without affecting others?  
4. Can we deploy a new version (or roll it back) without downtime?  
5. Can we change the database schema without breaking old or new code?

If the answer to any of these is “no”, the system still has important production gaps.
