# Primer B: Processes, Threads, and Why Stateless Services Matter

Modern systems scale by running many copies of the same program. To understand why that works (and when it breaks), you need a clear mental model of processes, threads, and the difference between stateful and stateless services.

### 1. Process vs Thread (Simple Mental Model)

**Process**  
A process is an independent program running on a computer. It has its own memory space. If one process crashes, it normally does not take other processes down with it.  
Analogy: a separate workshop with its own tools and workbench.

**Thread**  
A thread is a lightweight unit of execution *inside* a process. Multiple threads in the same process share the same memory. They can communicate very quickly, but if one thread corrupts shared memory, it can hurt the whole process.  
Analogy: several workers inside the same workshop sharing the same tools and benches.

Key consequences:

- Threads are cheaper to create and switch between than processes.  
- Because threads share memory, they need careful synchronization (locks, etc.).  
- A crash or runaway memory leak in one thread can kill the entire process.

### 2. What “Blocking” Means

When code makes a network call or reads from disk, it often *blocks* — the thread sits and waits until the answer comes back. While it is waiting, that thread cannot do other useful work.

If you have only a few threads and many of them are blocked waiting for a database, your service stops responding even though the CPU is mostly idle. This is why thread pools, timeouts, and asynchronous designs matter.

### 3. Stateful vs Stateless Services

**Stateful service**  
The service keeps important information about the client in its own memory.  
Examples: an in-memory shopping cart, an open WebSocket connection with session data, a local cache that is the only copy of some data.

Problem: if that particular instance dies, or if the load balancer sends the next request to a different instance, the information is gone or unreachable. Scaling and failover become harder.

**Stateless service**  
Every request contains (or can look up) everything the service needs. The instance itself does not remember previous requests. Any instance can handle any request.

Benefits:

- You can add or remove instances freely.  
- Load balancers can distribute traffic without “sticky” sessions.  
- When an instance dies, almost no user data is lost.  
- Horizontal scaling becomes straightforward.

The usual pattern is:

> Keep the application servers as stateless as possible.  
> Push state into external stores that are designed for it (databases, Redis, object storage, etc.).

### 4. Why This Distinction Appears Everywhere in System Design

Horizontal scaling (adding more machines) only works cleanly when the new machines can immediately take work from the existing ones. That is only true if they do not hold unique state in memory.

This is why you will repeatedly see these design choices:

- Session data stored in Redis instead of in the application process.  
- File uploads sent directly to object storage instead of being held on the application server.  
- WebSocket connection state carefully managed or moved to a specialized layer.  
- Caches treated as disposable; the source of truth lives elsewhere.

### 5. Practical Consequences You Will Use Later

| Situation | Stateful approach | Stateless approach |
|-----------|-------------------|--------------------|
| User session | Stored in server memory | Stored in Redis or a database, keyed by session ID |
| Shopping cart | Local to one server | External store; any server can read/write it |
| File upload | Saved to local disk | Streamed to S3 / Cloud Storage |
| Real-time connection | Tied to one machine | Connection broker or sticky routing + external state |

The stateless approach almost always wins for services that must scale and survive instance failures.

### 6. What You Should Be Able to Do After This Primer

- Explain the difference between a process and a thread in plain language.  
- Describe what it means for a service to be stateful versus stateless.  
- Give at least two reasons why stateless services are easier to scale horizontally.  
- Recognize when a design is accidentally introducing state into the application tier and suggest where that state should live instead.

This primer directly supports the scaling discussions in Parts 1, 4, and 5 of the series.

**[END OF PRIMER B]**
