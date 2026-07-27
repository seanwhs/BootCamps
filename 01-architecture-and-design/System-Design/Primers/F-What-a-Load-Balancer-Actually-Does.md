# Primer F: What a Load Balancer Actually Does

When traffic grows beyond what a single machine can handle, we put multiple machines behind a **load balancer**. This primer explains what a load balancer really does, the main ways it chooses targets, and the practical differences that matter in system design.

### 1. The Basic Job

A load balancer sits in front of a group of backend instances (application servers, containers, etc.) and performs three core functions:

1. **Accepts** incoming client connections.
2. **Chooses** one healthy backend instance for each request (or connection).
3. **Forwards** the traffic and returns the response to the client.

From the client’s point of view there is a single address. From the backend’s point of view each instance only sees a fraction of the total traffic.

Analogy: a receptionist who directs visitors to whichever available clerk is best suited to help them.

### 2. Layer 4 vs Layer 7

Load balancers are commonly classified by how much of the traffic they inspect.

**Layer 4 (Transport)**  
- Looks at IP addresses, ports, and TCP/UDP connections.  
- Does not understand HTTP paths, headers, or cookies.  
- Very fast and efficient.  
- Typically routes entire connections, not individual HTTP requests.

**Layer 7 (Application)**  
- Understands HTTP (and sometimes other protocols).  
- Can route based on URL path, headers, cookies, query parameters, etc.  
- Can terminate TLS, perform authentication checks, add headers, rate-limit, and more.  
- Slightly higher latency and resource cost than L4, but far more flexible.

In modern systems you often see both: an L4 balancer or network load balancer at the outer edge, and L7 balancers or API gateways closer to the applications.

### 3. How a Load Balancer Chooses a Backend

Common algorithms:

| Algorithm | Behavior | Good when… |
|-----------|----------|------------|
| **Round-robin** | Cycles through the list of instances | Instances are roughly equal in capacity |
| **Least connections** | Sends the next request to the instance with the fewest open connections | Request durations vary widely |
| **Least response time** | Prefers instances currently responding fastest | You want to avoid slow or overloaded instances |
| **Consistent hashing** | Same client or key tends to land on the same instance | You want session affinity or cache locality |
| **Random** | Simple random choice | Surprisingly effective and easy to reason about |

Many load balancers also support **weighted** versions of these algorithms so more powerful instances receive more traffic.

### 4. Health Checks

A load balancer continuously checks whether each backend is healthy. Common methods:

- Simple TCP connection attempt
- HTTP request to a `/health` or `/ready` endpoint
- More sophisticated checks that verify critical dependencies

Unhealthy instances are removed from the pool until they pass checks again. This is one of the primary mechanisms for automatic failover.

Two related concepts:

- **Liveness** – “Is the process running?”
- **Readiness** – “Is the process ready to receive traffic right now?” (It may be alive but still warming up or overloaded.)

### 5. Sticky Sessions (Session Affinity)

Sometimes you want the same client to keep talking to the same backend instance (for example, when session state lives in memory). Load balancers can provide this via cookies or source-IP hashing.

**Important design note**: Sticky sessions make scaling and failure handling harder. Prefer **stateless** application servers and externalize session state (Redis, database, etc.) whenever possible. Sticky sessions should be a last resort, not the default.

### 6. TLS Termination

Many load balancers terminate TLS: they decrypt the incoming HTTPS traffic and forward plain HTTP (or re-encrypted traffic) to the backends. Benefits include:

- Centralized certificate management
- Reduced CPU load on application servers
- Ability to inspect and route based on HTTP content

In higher-security environments you may use **end-to-end encryption** or **mTLS** instead of (or in addition to) simple termination.

### 7. What a Load Balancer Does *Not* Do by Itself

- It does not automatically make a stateful application safe to scale.
- It does not fix slow database queries.
- It does not replace proper timeouts, retries, and circuit breakers.
- It does not guarantee even load if the application itself creates hot spots (for example, through poor sharding or in-memory state).

### 8. How Load Balancers Appear in Larger Designs

You will see them (or their cloud equivalents) in almost every architecture:

- Distributing traffic across application servers
- Separating public traffic from internal service-to-service traffic
- Acting as the enforcement point for rate limiting, WAF rules, and authentication at the edge
- Enabling zero-downtime deployments (new instances are added to the pool; old ones are drained)

API Gateways are essentially sophisticated L7 load balancers with extra policy features.

### 9. What You Should Be Able to Do After This Primer

- Explain the primary job of a load balancer in one or two sentences.
- Contrast L4 and L7 load balancing and give a situation where each is appropriate.
- Describe round-robin, least connections, and consistent hashing at a high level.
- Explain why health checks matter and the difference between liveness and readiness.
- Argue why sticky sessions should usually be avoided.
- Sketch where a load balancer sits in a typical request path.

This primer supports the networking and traffic-management material in Part 2 and appears repeatedly in the architectural blueprints of later parts.

**[END OF PRIMER F]**
