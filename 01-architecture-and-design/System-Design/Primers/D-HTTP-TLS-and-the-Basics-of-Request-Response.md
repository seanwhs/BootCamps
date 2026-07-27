# Primer D: HTTP, TLS, and the Basics of Request/Response

Almost every system we design speaks HTTP (or an HTTP-based protocol) at the edge. This primer gives you a clear, practical mental model of how a request and response actually work, what TLS adds, and which parts matter for system design.

### 1. The Basic Request/Response Cycle

HTTP is a **request-response** protocol. The client sends a request; the server sends a response. In its simplest form the client then closes the conversation.

A typical request contains:

- **Method** – what the client wants to do (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`, etc.)
- **URL / path** – which resource (`/api/v1/tasks/123`)
- **Headers** – metadata (authentication tokens, content type, caching instructions, etc.)
- **Body** (optional) – the data being sent (JSON, form data, file, etc.)

A typical response contains:

- **Status code** – how the request turned out (`200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `404 Not Found`, `500 Internal Server Error`, etc.)
- **Headers** – metadata (content type, caching, rate-limit information, etc.)
- **Body** (optional) – the returned data

You do not need to memorize every status code. You do need to know the major families:

- 2xx = success
- 3xx = redirection
- 4xx = client error (the client did something wrong)
- 5xx = server error (the server failed)

### 2. Common Methods and Their Meaning

| Method | Intended meaning | Safe? | Idempotent? |
|--------|------------------|-------|-------------|
| `GET` | Read a resource | Yes | Yes |
| `POST` | Create something or trigger an action | No | No |
| `PUT` | Replace a resource | No | Yes |
| `PATCH` | Partially update a resource | No | Usually |
| `DELETE` | Remove a resource | No | Yes |

**Safe** means the method should not change server state.  
**Idempotent** means doing the same request multiple times has the same effect as doing it once. This property becomes important when we add retries.

### 3. What TLS (HTTPS) Actually Does

TLS (Transport Layer Security) is the layer that turns HTTP into HTTPS. It provides three critical properties:

1. **Encryption** – outsiders cannot read the traffic.
2. **Integrity** – outsiders cannot modify the traffic without detection.
3. **Authentication** – the client can verify it is talking to the real server (and optionally vice versa).

The TLS handshake happens before any HTTP data is sent. It adds some latency (extra round-trips), which is why connection reuse and modern protocol features matter.

In system design you will often see:

- **TLS termination** at the load balancer or API gateway – the public traffic is encrypted, but internal traffic inside the data center may be plaintext or use a separate internal certificate system.
- **mTLS (mutual TLS)** – both client and server present certificates. This is common for service-to-service security inside a zero-trust architecture.

### 4. Connections, Keep-Alive, and Why They Matter

Opening a new TCP connection (and especially a new TLS connection) is expensive. Modern HTTP uses **persistent connections** (keep-alive) so multiple requests can share the same connection.

Later versions of the protocol improve this further:

- **HTTP/1.1** – persistent connections, but usually only one request in flight at a time per connection.
- **HTTP/2** – multiplexing: many requests share one connection at the same time.
- **HTTP/3** – runs over QUIC (UDP-based) and further reduces some latency and connection-setup costs.

You do not need to design systems around the differences every day, but you should know that connection management and protocol version affect latency and resource usage under high concurrency.

### 5. Headers That Appear Constantly in System Design

A few headers have outsized importance:

- `Authorization` – carries credentials or tokens.
- `Content-Type` – describes the body format (`application/json`, etc.).
- `Cache-Control` / `ETag` / `If-None-Match` – control caching behavior.
- `Retry-After` – tells a client how long to wait before retrying.
- `X-Request-ID` or similar – used for tracing a request across services.
- Rate-limit headers (`X-RateLimit-Remaining`, etc.) – communicate quota status.

When we design APIs, we decide what headers we accept, what we require, and what we emit.

### 6. How This Fits into Larger Systems

In later parts of the series you will see designs that rely on these basics:

- API gateways inspect and modify headers.
- Load balancers make decisions based on path or headers (L7).
- Caches key entries on URL + selected headers.
- Retries are only safe when the method and the operation are idempotent.
- TLS termination points become important security and performance boundaries.
- Tracing systems inject and propagate request IDs through headers.

Understanding the request/response model lets you reason clearly about all of the above.

### 7. What You Should Be Able to Do After This Primer

- Describe the main parts of an HTTP request and response.
- Explain the difference between safe and idempotent methods and why idempotency matters for retries.
- State the three properties TLS provides.
- Explain what “TLS termination” means and why it is commonly done at the edge.
- Recognize a few high-value headers and the role they play in caching, auth, and observability.
- Sketch the path of a request from client → TLS → load balancer → application and back.

This primer supports the networking and API discussions in Parts 1, 2, and 6 of the series.

**[END OF PRIMER D]**
