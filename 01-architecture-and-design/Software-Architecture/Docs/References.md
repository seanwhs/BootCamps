# References & Resources

## Essential Reading

### Comprehensive Framework & Architecture Books

- **Building Your Own JavaScript Framework: Architect Extensible and Reusable Framework Systems** by Vlad Filippov (Packt Publishing, 2023)
  - *A practical guide for structuring, designing, and maintaining software architecture in JavaScript. Covers framework planning, module structuring, API design, and software maintenance.*
  - Access via O'Reilly Online Learning.

### Software Architecture & Design

- **Designing Data-Intensive Applications** by Martin Kleppmann — The definitive guide to distributed systems, data models, storage, and consistency.
- **Building Microservices** by Sam Newman — Essential reading for designing, deploying, and maintaining microservice architectures.
- **The Pragmatic Programmer** by David Thomas & Andrew Hunt — Timeless advice on practical software craftsmanship.

## Official Documentation

### Runtime & Languages

- **[Node.js Official Documentation](https://nodejs.org/en/docs/)** – The definitive reference for the Node.js runtime, modules, and APIs.
- **[TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)** – Comprehensive guide to TypeScript's type system and language features.

### Data Storage & Caching

- **[PostgreSQL Documentation](https://www.postgresql.org/docs/)** – Full reference for PostgreSQL, including SQL, administration, and advanced features.
- **[Redis Documentation](https://redis.io/docs/)** – Covers Redis data types, commands, patterns, and configuration.

### Cloud Platforms

- **[AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)** – Serverless compute service documentation with deployment and optimization guides.
- **[AWS SDK for JavaScript](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)** – Official AWS SDK v3 for JavaScript/TypeScript.
- **[Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)** – Edge computing platform with V8 isolates, deployment, and caching.
- **[Terraform Documentation](https://developer.hashicorp.com/terraform/docs)** – Infrastructure as Code for provisioning cloud resources.

### AI & LLMs

- **[OpenAI API Documentation](https://platform.openai.com/docs/api-reference)** – Chat completions, function calling, embeddings, and more.
- **[LangChain.js Documentation](https://js.langchain.com/docs/)** – Framework for building LLM applications with agents, chains, and tools.

### Message Queues & Streaming

- **[RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)** – Message broker with AMQP, exchanges, queues, and reliability patterns.
- **[Apache Kafka Documentation](https://kafka.apache.org/documentation/)** – Distributed event streaming platform for high-throughput data pipelines.

## Learning Platforms

- **[Frontend Masters – Code Architecture Courses](https://frontendmasters.com/topics/architecture/)** – Covers scalable web apps, microfrontends, domain modeling, monorepos, and design patterns.
- **[O'Reilly Online Learning](https://www.oreilly.com/online-learning/)** – Extensive library of books, courses, and videos on distributed systems and JavaScript architecture.

## Tools & Libraries

### Core Stack

| Tool | Purpose |
|------|---------|
| **Fastify** | High-performance HTTP framework |
| **pino** | Structured, low-overhead logging |
| **zod** | Schema validation for TypeScript |
| **pg** | PostgreSQL driver with connection pooling |
| **ioredis** | Redis client with cluster support |

### Development

| Tool | Purpose |
|------|---------|
| **tsx** | TypeScript execution and hot reload |
| **vitest** | Fast, modern test runner |
| **esbuild** | JavaScript bundler and minifier |
| **wrangler** | Cloudflare Workers CLI |
| **Terraform** | Infrastructure as Code |
| **GitHub Actions** | CI/CD pipeline automation |

## Community & Support

- **[Stack Overflow](https://stackoverflow.com/questions/tagged/node.js)** – Node.js and JavaScript community Q&A.
- **[Node.js GitHub](https://github.com/nodejs/node)** – Source code, issues, and discussions.
- **[TypeScript GitHub](https://github.com/microsoft/TypeScript)** – TypeScript development and community.
- **[Fastify Discord](https://discord.gg/fastify)** – Community support for Fastify framework.

## Useful Command References

```bash
# Check versions
node --version
tsc --version
docker --version
terraform --version
wrangler --version

# Start local services
docker-compose up -d

# Run migrations
npm run admin:db-migrate

# Deploy to Lambda
npm run deploy:lambda

# Deploy to Cloudflare Workers
npm run deploy:worker
```

## Additional Learning Paths

- **Kubernetes** – Container orchestration and service management.
- **GraphQL** – API query language for flexible data fetching.
- **WebSockets** – Real-time, full-duplex communication.
- **Service Mesh (Istio/Linkerd)** – Advanced service-to-service communication.
- **Apache Kafka** – Event streaming at scale.

---

*This reference guide compiles key resources referenced throughout the JavaScript Systems Architecture series. See the main course content for detailed implementations and walkthroughs.*
