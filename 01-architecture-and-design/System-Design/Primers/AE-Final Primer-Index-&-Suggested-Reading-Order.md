# Primer AE: Final Primer Index & Suggested Reading Order

This primer is the map of the entire primer collection. Use it to find a specific topic quickly or to follow a deliberate learning path.

### 1. Complete Primer Index

| ID | Title | Main Theme |
|----|-------|------------|
| **A** | Latency, Throughput, and What Happens When You Click a Button | Foundations |
| **B** | Processes, Threads, and Why Stateless Services Matter | Foundations / Scaling |
| **C** | What a Database Index Actually Does | Data |
| **D** | HTTP, TLS, and the Basics of Request/Response | Networking |
| **E** | Consistency at a Glance (Strong vs Eventual) | Data / Consistency |
| **F** | What a Load Balancer Actually Does | Networking |
| **G** | Caching Fundamentals in One Picture | Performance |
| **H** | Synchronous vs Asynchronous Communication | Communication |
| **I** | What “Fan-out” Means and Why It Matters | Scaling / Architecture |
| **J** | Idempotency in Plain Language | Reliability |
| **K** | Timeouts, Retries, and Why They Belong Together | Reliability |
| **L** | What “Back-pressure” Means | Reliability |
| **M** | Circuit Breakers in Plain Language | Reliability |
| **N** | Bulkheads and Failure Isolation | Reliability |
| **O** | Graceful Degradation | Reliability |
| **P** | Health Checks (Liveness vs Readiness) | Operations |
| **Q** | Observability Basics (Metrics, Logs, Traces) | Operations |
| **R** | SLOs, SLIs, and Error Budgets at a Glance | Operations |
| **S** | Deployment Strategies (Rolling, Canary, Blue-Green) | Operations |
| **T** | Feature Flags and Progressive Delivery | Operations |
| **U** | Expand/Contract Migrations | Operations / Data |
| **V** | Secrets Management Basics | Security |
| **W** | Multi-Tenancy Isolation Essentials | Security / Architecture |
| **X** | Rate Limiting in Practice | Traffic / Reliability |
| **Y** | Authentication vs Authorization | Security |
| **Z** | The Capstone Preparation Checklist | Synthesis |
| **AA** | Common Observability Anti-Patterns | Operations |
| **AB** | Putting the Primers Together – A Mini Design Walkthrough | Synthesis |
| **AC** | Messaging Semantics (At-Most-Once, At-Least-Once, Exactly-Once) | Communication / Reliability |
| **AD** | Common Security Anti-Patterns | Security |

### 2. Suggested Reading Orders

#### Path 1 – Complete Beginner (Follow the Series)
Read primers roughly in the order they support the main parts:

1. A, B, D, F → foundations and networking  
2. C, E, U → data and consistency  
3. G, H, I → performance and communication patterns  
4. J, K, L, M, N, O, P → reliability toolkit  
5. Q, R, AA → observability and SLOs  
6. S, T → deployment and progressive delivery  
7. V, W, X, Y, AD → security, multi-tenancy, rate limiting  
8. Z, AB, AC → synthesis and messaging semantics  

#### Path 2 – Interview-Focused (Highest Leverage First)
1. A, E, H, J, K, M, G, I, W, Y, Z, AB  
2. Then fill gaps with C, F, X, Q, R, S, T, U, V, AC, AD as needed  

#### Path 3 – Production / On-Call Focused
1. K, L, M, N, O, P, Q, R, AA  
2. S, T, U, V  
3. W, X, AD  
4. Supporting foundations: A, B, E, G, H, J  

#### Path 4 – Just-in-Time (Use as Reference)
Keep the index handy. When you encounter a concept you cannot explain cleanly in 60 seconds, jump to the corresponding primer.

### 3. Mapping Primers to Main Series Parts

| Series Part | Most Relevant Primers |
|-------------|-----------------------|
| Part 1 – Foundations | A, B, D, E |
| Part 2 – Networking & Traffic | D, F, X, H |
| Part 3 – Data & Consistency | C, E, U, AC |
| Part 4 – Caching & Async | G, H, I, J |
| Part 5 – Reliability | J, K, L, M, N, O, P, Q, R |
| Part 6 – Security & Production | V, W, Y, S, T, U, AD, AA |
| Part 7 – Blueprints | I, W, G, H, AB + many others |
| Part 8 – Interview & Decision-Making | Z, AB + all |

### 4. How to Use the Primers Going Forward

- **Before a design session or interview**: skim the Capstone checklist (Z) and the mini walkthrough (AB).  
- **When you get stuck on a concept**: return to the single primer that owns that idea.  
- **After finishing a practice design**: use the index to notice which topics you avoided or handled weakly.  
- **In real work**: the anti-pattern primers (AA, AD) are especially useful during design reviews and post-incident discussions.

### 5. What You Should Be Able to Do After This Primer

- Locate any primer topic quickly.
- Choose a reading order that matches your current goal (interview, production work, or systematic learning).
- See how the primers map onto the main series parts.
- Treat the collection as a durable reference rather than a one-time read.

**[END OF PRIMER AE]**
