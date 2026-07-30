# Quiz & Test Bank with Answer Keys

## JavaScript Systems Architecture Series

---

## PART 0: INTRODUCTION

### Quiz 0.1: Course Overview

**1. What is the primary goal of this course?**
a) To learn basic JavaScript syntax
b) To build a production-grade distributed system
c) To master React.js
d) To learn Python

**Answer: b) To build a production-grade distributed system**

**2. Which of the following is NOT a prerequisite for this course?**
a) Node.js (v20+)
b) Docker
c) Python
d) Git

**Answer: c) Python**

**3. What system will you build during this course?**
a) Task Manager
b) E-commerce Platform
c) Orchestrator System
d) Social Media App

**Answer: c) Orchestrator System**

**4. How many phases are in this course?**
a) 5
b) 6
c) 7
d) 8

**Answer: c) 7**

**5. What is the recommended code editor for this course?**
a) Sublime Text
b) VS Code
c) Atom
d) Notepad++

**Answer: b) VS Code**

---

## PHASE 1: RUNTIME & EXECUTION

### Quiz 1.1: JavaScript Runtime

**1. Which component is responsible for the JavaScript event loop?**
a) V8 Engine
b) Libuv
c) Node.js Core
d) Chrome DevTools

**Answer: b) Libuv**

**2. JavaScript is single-threaded but ________.**
a) Blocking
b) Synchronous
c) Non-blocking
d) Multi-threaded

**Answer: c) Non-blocking**

**3. Which of the following is NOT a phase of the event loop?**
a) Timers
b) Check
c) Poll
d) Render

**Answer: d) Render**

**4. What is the correct order of event loop phases?**
a) Timers → Poll → Check → Close
b) Timers → Check → Poll → Close
c) Check → Timers → Poll → Close
d) Poll → Timers → Check → Close

**Answer: a) Timers → Poll → Check → Close**

**5. Microtasks are executed:**
a) Before every macrotask
b) After every macrotask
c) Only when the queue is empty
d) Never

**Answer: a) Before every macrotask**

**6. Which of the following is a microtask?**
a) setTimeout
b) setInterval
c) Promise.then
d) setImmediate

**Answer: c) Promise.then**

**7. What happens when you block the event loop?**
a) Only the blocking operation slows down
b) All operations are delayed
c) The process crashes
d) Nothing happens

**Answer: b) All operations are delayed**

**8. Which of the following is NOT a valid solution to event loop blocking?**
a) Using worker threads
b) Using setImmediate
c) Using synchronous operations
d) Offloading to separate service

**Answer: c) Using synchronous operations**

**9. What is the purpose of Libuv's thread pool?**
a) To run JavaScript code
b) To handle I/O operations
c) To compile TypeScript
d) To render HTML

**Answer: b) To handle I/O operations**

**10. Which of the following operations would block the event loop?**
a) Database query (async)
b) Reading a file (async)
c) Loop with 1 billion iterations
d) Network request (async)

**Answer: c) Loop with 1 billion iterations**

### Quiz 1.2: 12-Factor Applications

**1. How many factors are in the 12-Factor App methodology?**
a) 10
b) 11
c) 12
d) 13

**Answer: c) 12**

**2. Which factor states that configuration should be stored in the environment?**
a) Factor II
b) Factor III
c) Factor IV
d) Factor V

**Answer: b) Factor III**

**3. What is the correct way to handle secrets in a 12-Factor app?**
a) Store in source code
b) Store in environment variables
c) Store in configuration files
d) Store in comments

**Answer: b) Store in environment variables**

**4. Which factor requires processes to be stateless?**
a) Factor V
b) Factor VI
c) Factor VII
d) Factor VIII

**Answer: b) Factor VI**

**5. In a 12-Factor app, logs should be:**
a) Written to files
b) Written to a database
c) Written to stdout/stderr
d) Written to a separate service

**Answer: c) Written to stdout/stderr**

**6. What is the purpose of Factor IX (Disposability)?**
a) Fast startup and graceful shutdown
b) Storing configuration in environment
c) Treating logs as event streams
d) Running admin tasks as one-off processes

**Answer: a) Fast startup and graceful shutdown**

**7. Which factor deals with backing services as attached resources?**
a) Factor III
b) Factor IV
c) Factor VIII
d) Factor XI

**Answer: b) Factor IV**

**8. What is the separation of Build, Release, Run known as?**
a) Factor IV
b) Factor V
c) Factor VI
d) Factor VII

**Answer: b) Factor V**

**9. Which factor covers admin processes as one-off tasks?**
a) Factor X
b) Factor XI
c) Factor XII
d) Factor IX

**Answer: c) Factor XII**

**10. What is the benefit of Factor VIII (Concurrency)?**
a) Ability to scale out via process model
b) Storing configuration in environment
c) Treating logs as event streams
d) Fast startup and graceful shutdown

**Answer: a) Ability to scale out via process model**

### Quiz 1.3: Graceful Shutdown

**1. Which signals should be handled for graceful shutdown?**
a) SIGUSR1 and SIGUSR2
b) SIGTERM and SIGINT
c) SIGHUP and SIGCHLD
d) SIGALRM and SIGPIPE

**Answer: b) SIGTERM and SIGINT**

**2. What is the first step in a graceful shutdown?**
a) Close database connections
b) Stop accepting new requests
c) Wait for existing connections
d) Log the shutdown

**Answer: b) Stop accepting new requests**

**3. Why is graceful shutdown important in Kubernetes?**
a) For logging purposes
b) Because Kubernetes sends SIGTERM on pod termination
c) For debugging purposes
d) For security purposes

**Answer: b) Because Kubernetes sends SIGTERM on pod termination**

**4. What should you do if connections don't close within a timeout period?**
a) Exit immediately
b) Force close remaining connections
c) Wait indefinitely
d) Restart the process

**Answer: b) Force close remaining connections**

**5. Which component should be closed LAST in a graceful shutdown?**
a) HTTP server
b) Database connections
c) Redis connections
d) All should be closed simultaneously

**Answer: b) Database connections (after server stops accepting requests)**

### Quiz 1.4: Health Checks

**1. What is the purpose of a readiness probe?**
a) To check if the process is alive
b) To check if the service is ready to accept traffic
c) To check if the service is healthy
d) To check if the service is secure

**Answer: b) To check if the service is ready to accept traffic**

**2. What is the purpose of a liveness probe?**
a) To check if the process is alive
b) To check if the service is ready to accept traffic
c) To check if the service is secure
d) To check if the service is logged in

**Answer: a) To check if the process is alive**

**3. What HTTP status code should a health check return?**
a) 200 OK
b) 404 Not Found
c) 500 Internal Server Error
d) 302 Found

**Answer: a) 200 OK**

**4. When would a service report itself as NOT ready?**
a) When the service is healthy
b) When dependencies are unavailable
c) When the service is idle
d) When the service is under load

**Answer: b) When dependencies are unavailable**

**5. What should a health check endpoint return?**
a) {"status": "ok"}
b) The entire application state
c) HTML response
d) XML response

**Answer: a) {"status": "ok"}**

---

## PHASE 2: STRUCTURAL FOUNDATIONS

### Quiz 2.1: Hexagonal Architecture

**1. What is another name for Hexagonal Architecture?**
a) Clean Architecture
b) Layered Architecture
c) Ports & Adapters
d) Monolithic Architecture

**Answer: c) Ports & Adapters**

**2. What is the Dependency Inversion Principle?**
a) Dependencies should point outward
b) Dependencies should point inward
c) Dependencies should be avoided
d) Dependencies should be global

**Answer: b) Dependencies should point inward**

**3. Which layer contains business logic?**
a) Infrastructure
b) Application
c) Domain
d) Presentation

**Answer: c) Domain**

**4. Which layer contains use cases?**
a) Infrastructure
b) Application
c) Domain
d) Presentation

**Answer: b) Application**

**5. What is a port in Hexagonal Architecture?**
a) An implementation
b) An interface
c) A database
d) A controller

**Answer: b) An interface**

**6. What is an adapter in Hexagonal Architecture?**
a) An interface
b) An implementation
c) A domain entity
d) A use case

**Answer: b) An implementation**

**7. What should the domain layer NOT know about?**
a) Business rules
b) Entities
c) Database
d) Value objects

**Answer: c) Database**

**8. Which of the following is a benefit of Hexagonal Architecture?**
a) Faster performance
b) Easier testing
c) Less code
d) Simpler setup

**Answer: b) Easier testing**

**9. What is the composition root?**
a) Where objects are created
b) Where objects are destroyed
c) Where dependencies are wired
d) Where business logic lives

**Answer: c) Where dependencies are wired**

**10. Which principle does Hexagonal Architecture heavily rely on?**
a) Single Responsibility
b) Dependency Inversion
c) Open/Closed
d) Liskov Substitution

**Answer: b) Dependency Inversion**

### Quiz 2.2: Domain Entities

**1. What defines an entity?**
a) Immutability
b) Identity
c) Value
d) Primitive

**Answer: b) Identity**

**2. What should domain entities contain?**
a) Business logic
b) Database logic
c) HTTP logic
d) UI logic

**Answer: a) Business logic**

**3. What is a value object?**
a) An object with identity
b) An object without identity
c) An object with database methods
d) An object with UI methods

**Answer: b) An object without identity**

**4. Which of the following is a valid business rule?**
a) Email must be unique
b) Database must be PostgreSQL
c) HTTP port must be 3000
d) UI must be React

**Answer: a) Email must be unique**

**5. What is the purpose of domain events?**
a) To log operations
b) To capture significant business events
c) To store database queries
d) To handle HTTP requests

**Answer: b) To capture significant business events**

### Quiz 2.3: Repository Pattern

**1. What is the purpose of the Repository Pattern?**
a) To abstract data access
b) To handle HTTP requests
c) To manage user sessions
d) To render views

**Answer: a) To abstract data access**

**2. What does a repository interface define?**
a) Implementation details
b) Data access methods
c) Database schema
d) HTTP endpoints

**Answer: b) Data access methods**

**3. Which of the following is NOT a repository method?**
a) save
b) findById
c) delete
d) render

**Answer: d) render**

**4. What is the benefit of using a repository interface?**
a) Faster code execution
b) Easier to swap implementations
c) Less memory usage
d) Automatic database optimization

**Answer: b) Easier to swap implementations**

**5. A repository should return:**
a) Database rows directly
b) Domain entities
c) HTTP responses
d) UI components

**Answer: b) Domain entities**

### Quiz 2.4: CQRS

**1. What does CQRS stand for?**
a) Command Query Responsibility Segregation
b) Command Query Request Service
c) Central Query Response System
d) Concurrent Query Response Service

**Answer: a) Command Query Responsibility Segregation**

**2. What is the purpose of commands in CQRS?**
a) To read data
b) To write data
c) To render views
d) To handle errors

**Answer: b) To write data**

**3. What is the purpose of queries in CQRS?**
a) To write data
b) To read data
c) To process events
d) To validate input

**Answer: b) To read data**

**4. In CQRS, read and write models are:**
a) Always the same
b) Usually different
c) Never used
d) Always combined

**Answer: b) Usually different**

**5. What is a benefit of CQRS?**
a) Simpler architecture
b) Optimized reads and writes
c) Less code
d) Fewer dependencies

**Answer: b) Optimized reads and writes**

### Quiz 2.5: PostgreSQL Integration

**1. What is connection pooling?**
a) Reusing database connections
b) Creating new connections for each query
c) Closing connections after each query
d) Using multiple databases

**Answer: a) Reusing database connections**

**2. Why is connection pooling important?**
a) It's faster
b) It saves resources
c) It's more secure
d) It's easier to debug

**Answer: b) It saves resources**

**3. What is the purpose of database migrations?**
a) To backup data
b) To version control database schema
c) To optimize queries
d) To create indexes

**Answer: b) To version control database schema**

**4. What does ON CONFLICT do in PostgreSQL?**
a) Creates a conflict
b) Handles duplicate key errors
c) Deletes conflicting rows
d) Ignores conflicts

**Answer: b) Handles duplicate key errors**

**5. Which of the following is a good practice with transactions?**
a) Keep them long
b) Keep them short
c) Never use them
d) Use them for all queries

**Answer: b) Keep them short**

### Quiz 2.6: Caching with Redis

**1. What is the cache-aside pattern?**
a) Write to cache first, then database
b) Write to database first, then cache
c) Check cache first, then database
d) Write to cache and database simultaneously

**Answer: c) Check cache first, then database**

**2. What is a cache miss?**
a) Data is found in cache
b) Data is not found in cache
c) Cache is full
d) Cache is empty

**Answer: b) Data is not found in cache**

**3. What is TTL in caching?**
a) Total Time Limit
b) Time To Live
c) Time To Load
d) Total Transfer Limit

**Answer: b) Time To Live**

**4. What is cache invalidation?**
a) Removing stale data from cache
b) Adding data to cache
c) Checking cache
d) Updating cache

**Answer: a) Removing stale data from cache**

**5. What is a common cache invalidation strategy?**
a) Write-through
b) Write-back
c) Event-based
d) All of the above

**Answer: d) All of the above**

**6. What is multi-level caching?**
a) Using multiple cache providers
b) Using L1 and L2 caches
c) Using different cache strategies
d) Using the same cache for all data

**Answer: b) Using L1 and L2 caches**

**7. Which Redis data type is best for storing user sessions?**
a) String
b) Hash
c) List
d) Set

**Answer: a) String (with TTL)**

**8. What is a common use case for Redis?**
a) Relational data
b) Session storage
c) Document storage
d) Graph data

**Answer: b) Session storage**

---

## PHASE 3: DISTRIBUTED SYSTEMS

### Quiz 3.1: Distributed Patterns

**1. What is the main challenge of distributed systems?**
a) Cost
b) Complexity
c) Security
d) Performance

**Answer: b) Complexity**

**2. What does API composition do?**
a) Combines results from multiple services
b) Combines multiple API requests into one
c) Compresses API responses
d) Caches API responses

**Answer: a) Combines results from multiple services**

**3. What are the three states of a circuit breaker?**
a) ON, OFF, WAITING
b) CLOSED, OPEN, HALF_OPEN
c) STARTED, RUNNING, STOPPED
d) READY, BUSY, ERROR

**Answer: b) CLOSED, OPEN, HALF_OPEN**

**4. When does a circuit breaker move to HALF_OPEN?**
a) On first failure
b) After reset timeout
c) On success
d) After multiple failures

**Answer: b) After reset timeout**

**5. What is the purpose of the Saga pattern?**
a) To manage distributed transactions
b) To cache data
c) To route requests
d) To load balance

**Answer: a) To manage distributed transactions**

**6. What is a compensating action in a Saga?**
a) The main action
b) The rollback action
c) The success action
d) The failure action

**Answer: b) The rollback action**

**7. What is exponential backoff?**
a) Increasing delay between retries
b) Decreasing delay between retries
c) Constant delay between retries
d) Random delay between retries

**Answer: a) Increasing delay between retries**

**8. What is the purpose of jitter in retry logic?**
a) To increase performance
b) To prevent thundering herd
c) To reduce latency
d) To increase throughput

**Answer: b) To prevent thundering herd**

**9. Which HTTP status code is typically retryable?**
a) 200 OK
b) 404 Not Found
c) 429 Too Many Requests
d) 422 Unprocessable Entity

**Answer: c) 429 Too Many Requests**

**10. What is the difference between choreographed and orchestrated sagas?**
a) Choreography uses a central coordinator
b) Orchestration uses a central coordinator
c) Choreography is simpler
d) Orchestration is more reliable

**Answer: b) Orchestration uses a central coordinator**

### Quiz 3.2: Request Context & Cancellation

**1. What is AsyncLocalStorage used for?**
a) Storing data in the database
b) Propagating context across async operations
c) Caching HTTP responses
d) Logging operations

**Answer: b) Propagating context across async operations**

**2. What is the purpose of a correlation ID?**
a) To identify users
b) To trace requests across services
c) To authenticate requests
d) To encrypt data

**Answer: b) To trace requests across services**

**3. What does AbortController do?**
a) Cancels operations
b) Starts operations
c) Pauses operations
d) Resumes operations

**Answer: a) Cancels operations**

**4. What is the purpose of distributed tracing?**
a) To debug distributed systems
b) To cache data
c) To load balance
d) To secure systems

**Answer: a) To debug distributed systems**

**5. What is a span in distributed tracing?**
a) A single operation
b) A complete request
c) An error
d) A service

**Answer: a) A single operation**

**6. What is a trace in distributed tracing?**
a) A single operation
b) A complete request flow
c) An error
d) A service

**Answer: b) A complete request flow**

**7. How are trace IDs propagated?**
a) Via HTTP headers
b) Via cookies
c) Via query parameters
d) Via request body

**Answer: a) Via HTTP headers**

**8. Which HTTP headers are commonly used for tracing?**
a) x-request-id, x-trace-id
b) x-auth-token, x-user-id
c) x-version, x-env
d) x-host, x-port

**Answer: a) x-request-id, x-trace-id**

**9. What happens when a request is cancelled in a distributed system?**
a) Only the originating service is affected
b) The cancellation propagates to all services
c) The request continues to execute
d) The request is retried

**Answer: b) The cancellation propagates to all services**

**10. What is a dead letter queue used for?**
a) Storing failed messages
b) Storing successful messages
c) Storing all messages
d) Processing messages

**Answer: a) Storing failed messages**

---

## PHASE 4: CLOUD-NATIVE ARCHITECTURE

### Quiz 4.1: Serverless Concepts

**1. What is a cold start in serverless?**
a) When a function is invoked for the first time
b) When a function is warm
c) When a function is deployed
d) When a function is updated

**Answer: a) When a function is invoked for the first time**

**2. What is one way to mitigate cold starts?**
a) Increase memory
b) Use provisioned concurrency
c) Add more dependencies
d) Use larger bundles

**Answer: b) Use provisioned concurrency**

**3. What is the benefit of serverless computing?**
a) No server management
b) More control
c) Lower latency
d) Unlimited resources

**Answer: a) No server management**

**4. What is the maximum execution time for AWS Lambda?**
a) 5 seconds
b) 15 seconds
c) 30 seconds
d) 15 minutes

**Answer: d) 15 minutes**

**5. What is a V8 isolate?**
a) A container
b) A lightweight execution environment
c) A virtual machine
d) A database

**Answer: b) A lightweight execution environment**

**6. Which platform uses V8 isolates for serverless functions?**
a) AWS Lambda
b) Cloudflare Workers
c) Google Cloud Functions
d) Azure Functions

**Answer: b) Cloudflare Workers**

**7. What is the purpose of bundling for serverless?**
a) To reduce cold start times
b) To improve security
c) To add dependencies
d) To increase function size

**Answer: a) To reduce cold start times**

**8. What is edge computing?**
a) Processing data at the edge of the network
b) Processing data in the cloud
c) Processing data on the client
d) Processing data in the database

**Answer: a) Processing data at the edge of the network**

**9. Which of the following is a benefit of edge computing?**
a) Reduced latency
b) More compute power
c) More storage
d) More bandwidth

**Answer: a) Reduced latency**

**10. What is infrastructure as code?**
a) Writing code to manage infrastructure
b) Writing code for applications
c) Writing code for databases
d) Writing code for caching

**Answer: a) Writing code to manage infrastructure**

### Quiz 4.2: Edge Caching & CDN

**1. What does CDN stand for?**
a) Content Delivery Network
b) Cloud Data Network
c) Centralized Distribution Network
d) Client Delivery Network

**Answer: a) Content Delivery Network**

**2. What is the purpose of a CDN?**
a) To cache content at edge locations
b) To process data
c) To store data
d) To compute data

**Answer: a) To cache content at edge locations**

**3. What is stale-while-revalidate?**
a) Serving stale content while updating cache
b) Always serving fresh content
c) Never serving content
d) Only serving stale content

**Answer: a) Serving stale content while updating cache**

**4. What is cache invalidation in CDN?**
a) Removing cached content
b) Adding cached content
c) Updating cached content
d) Checking cached content

**Answer: a) Removing cached content**

**5. How is cache controlled at the edge?**
a) By the CDN provider
b) By cache control headers
c) By the database
d) By the application

**Answer: b) By cache control headers**

---

## PHASE 5: DATA SYSTEMS

### Quiz 5.1: Event Sourcing

**1. What is event sourcing?**
a) Storing state as events
b) Storing state as snapshots
c) Storing state as queries
d) Storing state as commands

**Answer: a) Storing state as events**

**2. What is a domain event?**
a) A database event
b) A significant business event
c) An HTTP event
d) A UI event

**Answer: b) A significant business event**

**3. What is the benefit of event sourcing?**
a) Complete audit trail
b) Faster queries
c) Less storage
d) Simpler code

**Answer: a) Complete audit trail**

**4. What is an event store?**
a) A database for events
b) A queue for events
c) A cache for events
d) A log for events

**Answer: a) A database for events**

**5. What is a projection in event sourcing?**
a) A read model built from events
b) A write model
c) A database table
d) A query

**Answer: a) A read model built from events**

**6. What is event versioning?**
a) Changing existing events
b) Adding new event versions
c) Deleting old events
d) Ignoring events

**Answer: b) Adding new event versions**

**7. What is an upcaster?**
a) Converts old event versions to new
b) Deletes old events
c) Creates new events
d) Stores events

**Answer: a) Converts old event versions to new**

**8. What is the difference between event sourcing and CQRS?**
a) They are the same
b) Event sourcing is about storage, CQRS is about separation
c) CQRS is about storage, event sourcing is about separation
d) They are unrelated

**Answer: b) Event sourcing is about storage, CQRS is about separation**

**9. What is the purpose of snapshots in event sourcing?**
a) To improve performance
b) To reduce storage
c) To simplify logic
d) To increase security

**Answer: a) To improve performance**

**10. What is eventual consistency?**
a) Data is always consistent
b) Data will eventually become consistent
c) Data is never consistent
d) Data is always inconsistent

**Answer: b) Data will eventually become consistent**

### Quiz 5.2: Stream Processing

**1. What are the four types of Node.js streams?**
a) Readable, Writable, Transform, Duplex
b) Read, Write, Process, Stream
c) Source, Sink, Transform, Duplex
d) Input, Output, Process, Stream

**Answer: a) Readable, Writable, Transform, Duplex**

**2. What is backpressure in streams?**
a) A signal to slow down the producer
b) A signal to speed up the producer
c) A signal to stop the producer
d) A signal to start the producer

**Answer: a) A signal to slow down the producer**

**3. What does highWaterMark control?**
a) The buffer size
b) The processing speed
c) The number of streams
d) The error handling

**Answer: a) The buffer size**

**4. What is the purpose of pipeline() in Node.js?**
a) To connect streams together
b) To disconnect streams
c) To create streams
d) To destroy streams

**Answer: a) To connect streams together**

**5. What is the benefit of processing events in batches?**
a) Better performance
b) Better accuracy
c) Better security
d) Better reliability

**Answer: a) Better performance**

---

## PHASE 6: AI & THE FINAL BOSS

### Quiz 6.1: AI Agents

**1. What are the components of an AI agent?**
a) LLM, Memory, Tools
b) CPU, RAM, Storage
c) Input, Output, Processing
d) Code, Data, Algorithm

**Answer: a) LLM, Memory, Tools**

**2. What is the agentic loop?**
a) Perceive → Plan → Execute → Reflect
b) Plan → Execute → Reflect → Perceive
c) Execute → Reflect → Perceive → Plan
d) Reflect → Perceive → Plan → Execute

**Answer: a) Perceive → Plan → Execute → Reflect**

**3. What is a tool in the context of AI agents?**
a) An API or function the agent can use
b) A programming language
c) A database
d) A framework

**Answer: a) An API or function the agent can use**

**4. What is vector memory?**
a) Memory that stores embeddings
b) Memory that stores strings
c) Memory that stores numbers
d) Memory that stores images

**Answer: a) Memory that stores embeddings**

**5. What is the purpose of embeddings?**
a) To convert text to vectors
b) To convert text to strings
c) To convert text to numbers
d) To convert text to images

**Answer: a) To convert text to vectors**

**6. What is semantic search?**
a) Searching by meaning
b) Searching by keyword
c) Searching by date
d) Searching by author

**Answer: a) Searching by meaning**

**7. What is a system prompt in LLM interaction?**
a) Setting the behavior of the AI
b) The user's question
c) The AI's response
d) The tool's output

**Answer: a) Setting the behavior of the AI**

**8. What is function calling in LLMs?**
a) AI's ability to call tools
b) A programming function
c) A callback function
d) An API call

**Answer: a) AI's ability to call tools**

**9. What is token optimization?**
a) Reducing token usage to save cost
b) Increasing token usage for better results
c) Changing the model
d) Changing the prompt

**Answer: a) Reducing token usage to save cost**

**10. What is chain of thought reasoning?**
a) Breaking down problems step by step
b) Making random guesses
c) Copying the input
d) Ignoring the input

**Answer: a) Breaking down problems step by step**

### Quiz 6.2: The Final Boss (Orchestration)

**1. What are the components of the production orchestrator?**
a) Rate Limiter, Deduplicator, Request Queue, Retry Policy, Bulk Processor
b) Cache, Database, Queue, Stream, Processor
c) HTTP, WebSocket, TCP, UDP
d) Monitor, Alert, Log, Trace

**Answer: a) Rate Limiter, Deduplicator, Request Queue, Retry Policy, Bulk Processor**

**2. What is the purpose of rate limiting?**
a) To prevent system overload
b) To improve performance
c) To cache data
d) To process data

**Answer: a) To prevent system overload**

**3. What is request deduplication?**
a) Preventing duplicate requests
b) Duplicating requests
c) Caching requests
d) Routing requests

**Answer: a) Preventing duplicate requests**

**4. What is the purpose of a priority queue?**
a) To process important requests first
b) To process requests in order
c) To process requests randomly
d) To ignore requests

**Answer: a) To process important requests first**

**5. What is the purpose of bulk processing?**
a) To group similar requests for efficiency
b) To process requests one by one
c) To ignore requests
d) To cache requests

**Answer: a) To group similar requests for efficiency**

**6. What does a retry policy handle?**
a) Failed requests
b) Successful requests
c) All requests
d) Cached requests

**Answer: a) Failed requests**

**7. What is the benefit of the orchestrator pattern?**
a) Centralized request management
b) Distributed request management
c) No request management
d) Manual request management

**Answer: a) Centralized request management**

**8. What is a sliding window rate limiter?**
a) Tracks requests in a time window
b) Tracks all requests
c) Tracks requests by user
d) Tracks requests by IP

**Answer: a) Tracks requests in a time window**

**9. What is the purpose of the orchestrator's status endpoint?**
a) To monitor the system
b) To handle requests
c) To process data
d) To cache data

**Answer: a) To monitor the system**

**10. What is the final component of the orchestration layer?**
a) The complete orchestrator class
b) The rate limiter
c) The request queue
d) The deduplicator

**Answer: a) The complete orchestrator class**

---

## PRACTICAL EXERCISES

### Exercise 1: Event Loop

**Task**: Write code that demonstrates the execution order of microtasks and macrotasks.

```javascript
// Write your solution here
console.log('A');
setTimeout(() => console.log('B'), 0);
Promise.resolve().then(() => console.log('C'));
process.nextTick(() => console.log('D'));
setImmediate(() => console.log('E'));
console.log('F');

// Expected output: A, F, D, C, B, E
```

### Exercise 2: Domain Entity

**Task**: Create a Task entity with business rules.

```typescript
// Write your solution here
export class Task {
    private id: string;
    private title: string;
    private description: string;
    private status: 'pending' | 'in_progress' | 'completed' | 'failed' | 'cancelled';
    private priority: 'low' | 'medium' | 'high' | 'critical';
    private dueDate: Date | null;
    
    constructor(props: {
        id?: string;
        title: string;
        description: string;
        priority?: 'low' | 'medium' | 'high' | 'critical';
        dueDate?: Date;
    }) {
        if (props.title.length < 3) throw new Error('Title too short');
        this.id = props.id || randomUUID();
        this.title = props.title;
        this.description = props.description;
        this.status = 'pending';
        this.priority = props.priority || 'medium';
        this.dueDate = props.dueDate || null;
    }
    
    start(): void {
        if (this.status === 'completed') throw new Error('Cannot start completed task');
        this.status = 'in_progress';
    }
    
    complete(): void {
        if (this.status === 'cancelled') throw new Error('Cannot complete cancelled task');
        if (this.status === 'completed') throw new Error('Task already completed');
        this.status = 'completed';
    }
}
```

### Exercise 3: Circuit Breaker

**Task**: Implement a circuit breaker.

```typescript
// Write your solution here
class CircuitBreaker {
    private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
    private failureCount = 0;
    private lastFailureTime = 0;
    private failureThreshold = 5;
    private resetTimeout = 60000;
    
    async execute<T>(
        operation: () => Promise<T>,
        fallback?: () => Promise<T>
    ): Promise<T> {
        this.checkState();
        
        if (this.state === 'OPEN') {
            if (fallback) return await fallback();
            throw new Error('Circuit breaker open');
        }
        
        try {
            const result = await operation();
            this.onSuccess();
            return result;
        } catch (error) {
            this.onFailure();
            if (fallback) return await fallback();
            throw error;
        }
    }
    
    private checkState(): void {
        if (this.state === 'OPEN' && Date.now() - this.lastFailureTime > this.resetTimeout) {
            this.state = 'HALF_OPEN';
        }
    }
    
    private onSuccess(): void {
        if (this.state === 'HALF_OPEN') {
            this.state = 'CLOSED';
            this.failureCount = 0;
        }
        this.failureCount = Math.max(0, this.failureCount - 1);
    }
    
    private onFailure(): void {
        this.failureCount++;
        this.lastFailureTime = Date.now();
        if (this.state === 'HALF_OPEN' || this.failureCount >= this.failureThreshold) {
            this.state = 'OPEN';
        }
    }
}
```

### Exercise 4: Event Sourcing

**Task**: Implement an event store.

```typescript
// Write your solution here
class EventStore {
    private events: DomainEvent[] = [];
    
    async appendEvents(aggregateId: string, events: DomainEvent[]): Promise<void> {
        const currentVersion = this.getCurrentVersion(aggregateId);
        for (const event of events) {
            if (event.version <= currentVersion) {
                throw new Error('Concurrency conflict');
            }
            this.events.push(event);
        }
    }
    
    async getEvents(aggregateId: string): Promise<DomainEvent[]> {
        return this.events
            .filter(e => e.aggregateId === aggregateId)
            .sort((a, b) => a.version - b.version);
    }
    
    private getCurrentVersion(aggregateId: string): number {
        const events = this.events.filter(e => e.aggregateId === aggregateId);
        return events.length > 0 ? events[events.length - 1].version : 0;
    }
}
```

### Exercise 5: Rate Limiter

**Task**: Implement a sliding window rate limiter.

```typescript
// Write your solution here
class RateLimiter {
    private requests: Map<string, number[]> = new Map();
    
    constructor(private maxRequests: number, private windowMs: number) {}
    
    isAllowed(key: string): boolean {
        const now = Date.now();
        const windowStart = now - this.windowMs;
        let timestamps = this.requests.get(key) || [];
        timestamps = timestamps.filter(t => t > windowStart);
        
        if (timestamps.length >= this.maxRequests) {
            return false;
        }
        
        timestamps.push(now);
        this.requests.set(key, timestamps);
        return true;
    }
}
```

---

## ANSWER KEY SUMMARY

### Phase 1: Runtime & Execution
| Question | Answer |
|----------|--------|
| 1.1.1 | b |
| 1.1.2 | c |
| 1.1.3 | d |
| 1.1.4 | a |
| 1.1.5 | a |
| 1.1.6 | c |
| 1.1.7 | b |
| 1.1.8 | c |
| 1.1.9 | b |
| 1.1.10 | c |
| 1.2.1 | c |
| 1.2.2 | b |
| 1.2.3 | b |
| 1.2.4 | b |
| 1.2.5 | c |
| 1.2.6 | a |
| 1.2.7 | b |
| 1.2.8 | b |
| 1.2.9 | c |
| 1.2.10 | a |
| 1.3.1 | b |
| 1.3.2 | b |
| 1.3.3 | b |
| 1.3.4 | b |
| 1.3.5 | b |
| 1.4.1 | b |
| 1.4.2 | a |
| 1.4.3 | a |
| 1.4.4 | b |
| 1.4.5 | a |

### Phase 2: Structural Foundations
| Question | Answer |
|----------|--------|
| 2.1.1 | c |
| 2.1.2 | b |
| 2.1.3 | c |
| 2.1.4 | b |
| 2.1.5 | b |
| 2.1.6 | b |
| 2.1.7 | c |
| 2.1.8 | b |
| 2.1.9 | c |
| 2.1.10 | b |
| 2.2.1 | b |
| 2.2.2 | a |
| 2.2.3 | b |
| 2.2.4 | a |
| 2.2.5 | b |
| 2.3.1 | a |
| 2.3.2 | b |
| 2.3.3 | d |
| 2.3.4 | b |
| 2.3.5 | b |
| 2.4.1 | a |
| 2.4.2 | b |
| 2.4.3 | b |
| 2.4.4 | b |
| 2.4.5 | b |
| 2.5.1 | a |
| 2.5.2 | b |
| 2.5.3 | b |
| 2.5.4 | b |
| 2.5.5 | b |
| 2.6.1 | c |
| 2.6.2 | b |
| 2.6.3 | b |
| 2.6.4 | a |
| 2.6.5 | d |
| 2.6.6 | b |
| 2.6.7 | a |
| 2.6.8 | b |

### Phase 3: Distributed Systems
| Question | Answer |
|----------|--------|
| 3.1.1 | b |
| 3.1.2 | a |
| 3.1.3 | b |
| 3.1.4 | b |
| 3.1.5 | a |
| 3.1.6 | b |
| 3.1.7 | a |
| 3.1.8 | b |
| 3.1.9 | c |
| 3.1.10 | b |
| 3.2.1 | b |
| 3.2.2 | b |
| 3.2.3 | a |
| 3.2.4 | a |
| 3.2.5 | a |
| 3.2.6 | b |
| 3.2.7 | a |
| 3.2.8 | a |
| 3.2.9 | b |
| 3.2.10 | a |

### Phase 4: Cloud-Native
| Question | Answer |
|----------|--------|
| 4.1.1 | a |
| 4.1.2 | b |
| 4.1.3 | a |
| 4.1.4 | d |
| 4.1.5 | b |
| 4.1.6 | b |
| 4.1.7 | a |
| 4.1.8 | a |
| 4.1.9 | a |
| 4.1.10 | a |
| 4.2.1 | a |
| 4.2.2 | a |
| 4.2.3 | a |
| 4.2.4 | a |
| 4.2.5 | b |

### Phase 5: Data Systems
| Question | Answer |
|----------|--------|
| 5.1.1 | a |
| 5.1.2 | b |
| 5.1.3 | a |
| 5.1.4 | a |
| 5.1.5 | a |
| 5.1.6 | b |
| 5.1.7 | a |
| 5.1.8 | b |
| 5.1.9 | a |
| 5.1.10 | b |
| 5.2.1 | a |
| 5.2.2 | a |
| 5.2.3 | a |
| 5.2.4 | a |
| 5.2.5 | a |

### Phase 6: AI & The Final Boss
| Question | Answer |
|----------|--------|
| 6.1.1 | a |
| 6.1.2 | a |
| 6.1.3 | a |
| 6.1.4 | a |
| 6.1.5 | a |
| 6.1.6 | a |
| 6.1.7 | a |
| 6.1.8 | a |
| 6.1.9 | a |
| 6.1.10 | a |
| 6.2.1 | a |
| 6.2.2 | a |
| 6.2.3 | a |
| 6.2.4 | a |
| 6.2.5 | a |
| 6.2.6 | a |
| 6.2.7 | a |
| 6.2.8 | a |
| 6.2.9 | a |
| 6.2.10 | a |
