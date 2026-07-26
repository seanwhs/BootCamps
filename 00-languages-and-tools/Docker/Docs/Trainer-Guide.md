# DOCKER MASTERY: CONTAINERIZE ANYTHING FROM ZERO TO PRODUCTION

## Trainer Guide

---

**Purpose:** This comprehensive trainer guide accompanies the Docker Mastery series. It provides everything needed to deliver the course effectively, including lesson plans, teaching strategies, classroom management tips, and assessment guidance.

**Intended Audience:** Instructors, trainers, bootcamp facilitators, corporate trainers, and anyone teaching Docker to others.

**How to Use:**
- Follow the lesson structure for each session
- Use the teaching strategies for different learning styles
- Adapt the pacing based on student progress
- Use assessment tools to measure learning outcomes

---

---

# SECTION 1: COURSE OVERVIEW

## 1.1 Course Description

**Course Title:** Docker Mastery: Containerize Anything From Zero to Production

**Duration:** 20-30 hours of instruction (varies by delivery format)

**Prerequisites:**
- Basic command-line familiarity
- Some programming experience (any language)
- Understanding of web applications (client-server model)

**Target Audience:**
- Developers new to containers
- System administrators modernizing infrastructure
- DevOps engineers building container workflows
- Students learning modern infrastructure
- Freelancers needing consistent deployments

---

## 1.2 Course Objectives

Upon completion, students will be able to:

1. **Understand** the fundamentals of containerization and why it matters
2. **Install and configure** Docker on their development environment
3. **Run and manage** containers using Docker commands
4. **Build custom images** using Dockerfiles with best practices
5. **Manage data persistence** using volumes and bind mounts
6. **Configure networking** between containers
7. **Orchestrate multi-container applications** using Docker Compose
8. **Harden containers** for production with security best practices
9. **Implement resource limits** and health checks
10. **Debug and optimize** containerized applications
11. **Set up CI/CD pipelines** for container workflows
12. **Sign and scan images** for security compliance
13. **Understand orchestration concepts** with Swarm and Kubernetes

---

## 1.3 Course Prerequisites

**For Students:**
- A computer with at least 8GB RAM (16GB recommended)
- 20GB free disk space
- Admin/root access (for installing Docker)
- Stable internet connection
- A text editor or IDE (VS Code recommended)
- Basic terminal/command prompt comfort

**For Instructors:**
- Deep knowledge of Docker and containerization
- Experience with Linux command line
- Familiarity with at least one programming language
- Experience teaching technical subjects
- Prepared examples and solutions

---

## 1.4 Course Materials

**Provided Materials:**
- Complete series content (Parts 0-8)
- Student notes (condensed reference)
- Student workbook (exercises and checkpoints)
- Quiz and test bank with answer keys
- Presentation deck (minimalist, text-based)
- Primer materials (Linux, networking, storage, security)
- Appendices (command reference, Dockerfile reference, etc.)

**Optional Materials:**
- Projector/screen for demonstrations
- Student workstations (if in-person)
- Docker Hub accounts (optional)
- GitHub accounts (optional)
- Cloud provider accounts (optional)

---

# SECTION 2: LESSON PLANS

## 2.1 Part 0: Introduction (30 minutes)

---

**Objectives:**
- Understand the problem containers solve
- See the ultimate architecture
- Know what to expect from the series
- Assess current knowledge level

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-5 min | Welcome | Introduce yourself, course overview |
| 5-10 min | The Problem | Explain environment drift with real examples |
| 10-15 min | The Solution | Contrast VMs vs containers |
| 15-20 min | Architecture | Show the ultimate architecture diagram |
| 20-25 min | Roadmap | Walk through the series structure |
| 25-30 min | Pre-Assessment | Have students complete pre-assessment |

---

**Teaching Tips:**
- Share a personal story about environment drift
- Use the shipping container analogy
- Have students share their "it works on my machine" stories
- Set expectations about the hands-on nature of the course

**Student Workbook:**
- Complete Pre-Assessment
- Set personal goals

---

## 2.2 Part 1: Core Foundation (2.5 hours)

---

**Objectives:**
- Install Docker on their system
- Run containers from existing images
- Understand container lifecycle
- Use basic Docker commands
- Understand namespaces and cgroups conceptually

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-15 min | Lecture | Namespaces, cgroups, Docker architecture |
| 15-45 min | Lab | Installation verification |
| 45-75 min | Lab | Running and managing containers |
| 75-105 min | Lab | Container lifecycle and inspection |
| 105-120 min | Lab | Port mapping and web servers |
| 120-150 min | Review | Common issues, Q&A |

---

**Key Commands to Demonstrate:**

```bash
# Installation verification
docker --version
docker run hello-world

# Basic commands
docker run -d --name web nginx:alpine
docker ps
docker logs web
docker exec -it web /bin/sh
docker stop web
docker rm web

# Interactive containers
docker run -it ubuntu:22.04 bash
# Inside: ps aux, cat /etc/os-release, exit

# Port mapping
docker run -d --name web -p 8080:80 nginx:alpine
curl http://localhost:8080
```

---

**Teaching Tips:**
- Have students follow along on their own machines
- Emphasize the "why" behind each command
- Demonstrate the difference between `stop` and `kill`
- Show `docker ps -a` early to prevent confusion
- Use the `--rm` flag in examples to keep systems clean

**Common Student Questions:**
- "Why does my container exit immediately?" – Explain PID 1 concept
- "What's the difference between image and container?" – Use the blueprint analogy
- "Why can't I access my container's port?" – Explain port mapping

---

## 2.3 Part 2: Custom Images (2 hours)

---

**Objectives:**
- Write Dockerfiles from scratch
- Understand key directives
- Optimize images with multi-stage builds
- Use .dockerignore
- Run containers as non-root users

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-15 min | Lecture | Dockerfile directives |
| 15-45 min | Lab | Create first Dockerfile |
| 45-75 min | Lab | Optimize Dockerfile |
| 75-105 min | Lab | Multi-stage builds |
| 105-120 min | Review | Best practices, Q&A |

---

**Key Concepts to Cover:**

| Concept | Key Points |
|---------|------------|
| FROM | Use specific versions, never latest |
| COPY vs ADD | Use COPY unless you need ADD features |
| CMD vs ENTRYPOINT | CMD is overridable, ENTRYPOINT is not |
| RUN | Chain commands with `&&` for fewer layers |
| WORKDIR | Use instead of `cd` |
| USER | Always run as non-root in production |
| HEALTHCHECK | Add to production images |
| Multi-stage | Separate build and runtime stages |

---

**Key Commands:**

```bash
# Build an image
docker build -t my-app:1.0 .

# Build with specific Dockerfile
docker build -f Dockerfile.prod -t my-app:prod .

# Build with build args
docker build --build-arg VERSION=1.0 -t my-app:1.0 .

# Build without cache
docker build --no-cache -t my-app:1.0 .

# View image history
docker history my-app:1.0

# Image size
docker images my-app:1.0
```

---

**Teaching Tips:**
- Start with a simple Dockerfile that works
- Add one optimization at a time
- Show the size difference before/after
- Use `docker history` to show layers
- Have students write a Dockerfile for their own app

**Common Student Questions:**
- "Why use slim/alpine base images?" – Show size comparison
- "What's the point of multi-stage?" – Show build tools in final image
- "When should I use ENTRYPOINT vs CMD?" – Give examples

---

## 2.4 Part 3: Persistence and Networking (2 hours)

---

**Objectives:**
- Understand container ephemerality
- Use named volumes for persistence
- Use bind mounts for development
- Create user-defined networks
- Enable DNS-based service discovery

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-15 min | Lecture | Volumes, bind mounts, tmpfs |
| 15-45 min | Lab | Named volumes persistence |
| 45-60 min | Lab | Bind mounts for development |
| 60-90 min | Lab | User-defined networks |
| 90-120 min | Lab | Complete three-tier stack |

---

**Key Concepts to Cover:**

| Concept | Key Points |
|---------|------------|
| Ephemeral | Container data is temporary by default |
| Named Volumes | Docker-managed, production persistence |
| Bind Mounts | Host directory, development hot reload |
| tmpfs | In-memory, caches, secrets |
| Bridge Network | Default, isolated, single-host |
| User-Defined Bridge | DNS resolution, better isolation |
| Host Network | No isolation, performance |

---

**Key Commands:**

```bash
# Volumes
docker volume create my-data
docker run -d -v my-data:/data postgres
docker volume inspect my-data
docker volume ls

# Bind mounts
docker run -d -v $(pwd):/app node:18

# Networks
docker network create app-net
docker run -d --network app-net --name redis redis
docker run -d --network app-net --name api my-api
docker exec api ping redis  # Works by name!
```

---

**Teaching Tips:**
- Show data loss by creating and removing a container
- Demonstrate volume persistence after container removal
- Show hot reload with bind mounts
- Create two networks and show containers can't talk across them
- Use `docker exec` to test connectivity

**Common Student Questions:**
- "Why can't containers on default bridge talk by name?" – Explain DNS
- "When should I use volumes vs bind mounts?" – Production vs development
- "What's the performance difference?" – Bind mounts are fast on Linux

---

## 2.5 Part 4: Docker Compose (2 hours)

---

**Objectives:**
- Write docker-compose.yml files
- Use environment variables
- Configure dependencies
- Use profiles for different environments
- Enable hot reload for development

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-15 min | Lecture | Compose structure and concepts |
| 15-45 min | Lab | Convert manual runs to Compose |
| 45-75 min | Lab | Environment variables |
| 75-105 min | Lab | Development vs production |
| 105-120 min | Review | Common issues, Q&A |

---

**Key Concepts to Cover:**

| Concept | Key Points |
|---------|------------|
| services | Define containers |
| volumes | Named volumes |
| networks | Custom networks |
| depends_on | Service dependencies (start order) |
| environment | Runtime variables |
| env_file | Variables from file |
| profiles | Selective service startup |
| deploy | Resource limits (Swarm mode) |

---

**Key Compose File Example:**

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    depends_on:
      - backend
    networks:
      - app-net

  backend:
    build: ./backend
    environment:
      - DB_HOST=postgres
    volumes:
      - ./backend:/app
    depends_on:
      postgres:
        condition: service_healthy

  postgres:
    image: postgres:15
    volumes:
      - pg-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]

volumes:
  pg-data:

networks:
  app-net:
```

---

**Key Commands:**

```bash
# Start services
docker compose up -d

# Stop and remove
docker compose down -v

# View logs
docker compose logs -f backend

# Execute command
docker compose exec backend bash

# Rebuild
docker compose build --no-cache

# Scale
docker compose up -d --scale backend=3

# With env file
docker compose --env-file .env.production up
```

---

**Teaching Tips:**
- Start with a simple Compose file, then add complexity
- Show the difference between `depends_on` and health check conditions
- Demonstrate hot reload with bind mounts in development
- Show environment-specific configurations with override files

**Common Student Questions:**
- "Why use Compose instead of scripts?" – Declarative vs imperative
- "How do I pass secrets?" – Use env files, not committed to git
- "What's the difference between `docker compose up` and `docker stack deploy`?" – Swarm vs non-Swarm

---

## 2.6 Part 5: Production Readiness (2 hours)

---

**Objectives:**
- Harden containers for production
- Set resource limits
- Configure logging
- Implement health checks
- Use CI/CD with GitHub Actions

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-15 min | Lecture | Security fundamentals |
| 15-45 min | Lab | Security hardening |
| 45-75 min | Lab | Resource limits and health checks |
| 75-105 min | Lab | CI/CD pipeline with GitHub Actions |
| 105-120 min | Review | Best practices, Q&A |

---

**Key Concepts to Cover:**

| Concept | Key Points |
|---------|------------|
| Non-root User | `USER appuser` in Dockerfile |
| Read-Only FS | `--read-only`, `tmpfs` for writes |
| Capabilities | Drop ALL, add only needed |
| Seccomp | System call filtering |
| Resource Limits | CPU, memory limits |
| Health Checks | HTTP, TCP, command |
| Logging | stdout/stderr, rotation |
| Secrets | Never in images |

---

**Security Checklist:**

```dockerfile
FROM python:3.11-slim

# 1. Non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

# 2. Minimal packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 3. Set ownership
COPY --chown=appuser:appgroup . /app

# 4. Switch user
USER appuser

# 5. Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/health || exit 1
```

---

**Key Commands:**

```bash
# Run with security
docker run -d \
  --read-only \
  --user 1001:1001 \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt seccomp=default.json \
  --memory=512M \
  --cpus=1 \
  my-app

# Update resource limits
docker update --memory=1G --cpus=2 container-name

# View resource usage
docker stats container-name

# Check OOM status
docker inspect container-name --format='{{.State.OOMKilled}}'

# Scan for vulnerabilities
trivy image my-app:latest
```

---

**Teaching Tips:**
- Start with an insecure container, then harden step by step
- Show the difference in vulnerability count before/after
- Demonstrate OOM killer with a memory-consuming app
- Show log rotation in action
- Walk through a GitHub Actions pipeline

**Common Student Questions:**
- "Is Alpine more secure?" – Smaller attack surface, but fewer packages
- "Do I always need non-root?" – In production, yes
- "How do I know which capabilities to keep?" – Document, test, remove

---

## 2.7 Part 6: Debugging and Operations (1.5 hours)

---

**Objectives:**
- Use systematic debugging approach
- Inspect containers
- View and analyze logs
- Monitor resource usage
- Optimize image size and rebuild times

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-10 min | Lecture | Debugging mindset |
| 10-40 min | Lab | Inspection commands |
| 40-70 min | Lab | Debugging common issues |
| 70-90 min | Review | Optimization strategies, Q&A |

---

**Debugging Flow:**

```
1. docker ps -a          # Is container running?
2. docker logs           # What do logs say?
3. docker inspect        # What's the configuration?
4. docker exec           # Can I get inside?
5. docker stats          # What are resources?
6. docker top            # What processes are running?
7. docker diff           # What changed?
8. docker events         # What happened?
```

---

**Key Commands:**

```bash
# Status
docker ps -a
docker inspect container --format='{{.State.Status}}'

# Logs
docker logs -f --tail 100 container
docker logs --since 30m container
docker logs -t container

# Inside container
docker exec -it container /bin/bash
docker exec container ps aux
docker exec container env
docker exec container netstat -tulpn

# Resources
docker stats --no-stream container
docker top container
docker system df

# Copy files
docker cp container:/app/logs/app.log ./app.log
docker cp ./config.json container:/app/config.json

# Events
docker events --filter container=container
```

---

**Common Issues and Solutions:**

| Issue | Diagnosis | Solution |
|-------|-----------|----------|
| Exits immediately | `docker logs` | Check CMD/ENTRYPOINT |
| Port conflict | `docker ps --filter publish=8080` | Change port |
| Permission denied | `docker exec container id` | Fix UID/GID |
| OOM (137) | `docker inspect --format='{{.State.OOMKilled}}'` | Increase memory limit |
| No such network | `docker network ls` | Create network |

---

**Teaching Tips:**
- Create a "broken" container and have students debug it
- Show `docker logs` with `-f` and `--tail` options
- Demonstrate `docker cp` for moving files
- Show `docker events` to monitor what's happening
- Discuss log rotation strategies

---

## 2.8 Part 7: Security and Registries (2 hours)

---

**Objectives:**
- Sign and verify images with Cosign
- Generate SBOMs
- Scan images for vulnerabilities
- Use registry strategies
- Implement secure CI/CD

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-15 min | Lecture | Security maturity model |
| 15-45 min | Lab | Image signing with Cosign |
| 45-75 min | Lab | SBOM generation and vulnerability scanning |
| 75-105 min | Lab | Registry strategies and promotion |
| 105-120 min | Lab | Secure CI/CD pipeline |

---

**Key Concepts to Cover:**

| Concept | Key Points |
|---------|------------|
| Cosign | Image signing and verification |
| SBOM | Software Bill of Materials |
| Trivy/Grype | Vulnerability scanning |
| Registry | Docker Hub, GHCR, ECR |
| Tagging | Semantic versioning, environment tags |
| Promotion | Develop → Staging → Production |

---

**Key Commands:**

```bash
# Cosign installation
brew install sigstore/tap/cosign  # macOS
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64

# Generate keys
cosign generate-key-pair

# Sign image
cosign sign --key cosign.key ghcr.io/user/app:v1.0.0

# Verify
cosign verify --key cosign.pub ghcr.io/user/app:v1.0.0

# SBOM generation
syft ghcr.io/user/app:v1.0.0 -o spdx-json > sbom.json

# Vulnerability scanning
trivy image --severity HIGH,CRITICAL ghcr.io/user/app:v1.0.0
grype --fail-on high ghcr.io/user/app:v1.0.0
```

---

**Tagging Strategy:**

```bash
# Semantic versioning
docker tag app:latest ghcr.io/user/app:v1.0.0

# Environment tags
docker tag app:latest ghcr.io/user/app:production
docker tag app:staging ghcr.io/user/app:staging

# Git reference
docker tag app:latest ghcr.io/user/app:main-abc123

# Date
docker tag app:latest ghcr.io/user/app:2024-01-15
```

---

**Teaching Tips:**
- Demonstrate the full signing/verification workflow
- Show how to integrate scanning into CI/CD
- Discuss different registry options and when to use each
- Explain SBOM requirements for compliance

---

## 2.9 Part 8: Orchestration (2 hours)

---

**Objectives:**
- Understand why orchestration is needed
- Deploy services with Docker Swarm
- Understand Kubernetes concepts
- Map Docker concepts to orchestration

---

**Lesson Outline:**

| Time | Activity | Description |
|------|----------|-------------|
| 0-15 min | Lecture | Why orchestration? |
| 15-45 min | Lab | Docker Swarm |
| 45-75 min | Lab | Swarm stacks |
| 75-105 min | Lecture | Kubernetes concepts |
| 105-120 min | Lab | Kubernetes (if time) |

---

**Key Concepts to Cover:**

| Concept | Key Points |
|---------|------------|
| Orchestration | Scaling, self-healing, rolling updates |
| Swarm | Docker-native, simpler |
| Kubernetes | Industry standard, more features |
| Nodes | Manager and worker nodes |
| Services | Group of identical tasks |
| Pods | Smallest K8s unit |
| Deployments | Desired state for pods |
| Services | Stable access to pods |
| Ingress | External HTTP/HTTPS routing |

---

**Docker Swarm Commands:**

```bash
# Initialize swarm
docker swarm init --advertise-addr 192.168.1.100

# Join workers
docker swarm join --token SWMTKN-... 192.168.1.100:2377

# Deploy service
docker service create --name web --replicas 3 --publish 8080:80 nginx

# Manage service
docker service scale web=5
docker service update --image nginx:1.25 web
docker service rollback web
docker service rm web

# Deploy stack
docker stack deploy -c docker-compose.swarm.yml myapp
docker stack services myapp
docker stack ps myapp
docker stack rm myapp
```

---

**Kubernetes Concepts Map:**

| Docker | Kubernetes |
|--------|------------|
| Container | Pod (one or more containers) |
| Image | Image |
| Volume | PersistentVolume |
| Network | Service, Ingress |
| docker run | kubectl run |
| docker-compose.yml | Deployment + Service |
| Port mapping | NodePort/LoadBalancer |
| Health check | Liveness/Readiness Probe |

---

**Teaching Tips:**
- Start with why orchestration matters (scale, HA, deployments)
- Show Swarm first (simpler to understand)
- Map each Swarm concept to its Kubernetes equivalent
- Emphasize that K8s is more complex but more powerful
- Discuss when to choose each orchestrator

---

# SECTION 3: TEACHING STRATEGIES

## 3.1 Instructional Methods

**Lecture (20% of time)**
- Keep lectures short (10-15 minutes)
- Use analogies and real-world examples
- Preview upcoming labs
- Summarize key points

**Hands-on Labs (60% of time)**
- Students follow along on their own machines
- Clear step-by-step instructions
- Intermediate checkpoints
- Debugging opportunities

**Discussion (10% of time)**
- Common questions
- Real-world scenarios
- Problem-solving together
- Sharing experiences

**Review (10% of time)**
- Recap key concepts
- Address pain points
- Preview next section
- Connect to previous content

---

## 3.2 Learner Personas

**The Developer**
- Focus: "How do I package my app?"
- Learning style: Tinkering, practical examples
- Motivation: Build something that works
- Challenge: Can get distracted by edge cases

**The System Administrator**
- Focus: "How do I deploy this securely?"
- Learning style: Documentation, best practices
- Motivation: Reliable production systems
- Challenge: Can be risk-averse

**The Student**
- Focus: "How does this work?"
- Learning style: Theory, concepts
- Motivation: Understanding fundamentals
- Challenge: May lack practical context

**The Manager**
- Focus: "How does this help my team?"
- Learning style: High-level overview
- Motivation: Business value
- Challenge: Needs enough detail for decisions

---

## 3.3 Addressing Common Learning Challenges

**Challenge: Command Overwhelm**
- Use the command reference as a "cheat sheet"
- Focus on the 20% of commands used 80% of the time
- Use `--help` frequently
- Show Tab completion

**Challenge: "It works on my machine"**
- Emphasize reproducibility
- Use environment variables
- Show container portability

**Challenge: Security Concerns**
- Start with security early
- Show insecure → secure transformation
- Use scanning tools to demonstrate vulnerabilities
- Discuss real-world breaches

**Challenge: Cloud vs Local**
- Use `host.docker.internal` for Mac/Windows
- Demonstrate portability across environments
- Show how to move from local to cloud

---

# SECTION 4: CLASSROOM MANAGEMENT

## 4.1 Setup Requirements

**For In-Person Training:**
- Projector or large screen
- Whiteboard or flip chart
- Student workstations with Docker installed
- Stable network connection
- Power for all laptops
- Spare power adapters

**For Virtual Training:**
- Web conferencing platform (Zoom, Teams, etc.)
- Screen sharing capability
- Chat for questions
- Breakout rooms for exercises
- Recorded sessions for review

**Software Requirements:**
- Docker Desktop (latest stable)
- Docker CLI
- Text editor/IDE
- Git
- Terminal/Command Prompt

---

## 4.2 Pacing Guidelines

**Full Course (30 hours):**
- 5 days (6 hours/day with breaks)
- Or 3 days (10 hours/day with breaks)
- Or 10 sessions (3 hours each)

**Accelerated Course (20 hours):**
- 4 days (5 hours/day)
- Or 2 days (10 hours/day)
- Or 8 sessions (2.5 hours each)

**Self-Paced:**
- 4-8 weeks
- Weekly sessions with check-ins
- Recorded lectures available

---

## 4.3 Break Schedule

**For Full-Day Sessions:**
- Morning break: 15 min (10:30)
- Lunch: 60 min (12:30)
- Afternoon break: 15 min (15:00)
- End: 17:00

**For Half-Day Sessions:**
- Break: 15 min halfway through
- End: 4 hours

---

## 4.4 Common Technical Issues

| Issue | Solution |
|-------|----------|
| Docker not installed | Provide installation guide before class |
| Permission denied | Add user to docker group |
| Port conflicts | Use different ports |
| Slow internet | Pre-download images |
| Different OS | Provide instructions for all platforms |
| RAM issues | Recommend minimum specs, use smaller images |

---

# SECTION 5: ASSESSMENT GUIDANCE

## 5.1 Formative Assessment

**During Sessions:**
- Checkpoint exercises in workbook
- Quick polls and questions
- "Show me" demonstrations
- Peer review of code

**Checkpoint Examples:**
- "Run `docker ps` and show me your running containers"
- "Show me your Dockerfile"
- "What does this command do?"

---

## 5.2 Summative Assessment

**Workbook Completion:**
- All exercises completed
- Checkpoints verified
- Reflection questions answered

**Practical Project:**
- Containerize a real application
- Write a Dockerfile
- Set up a three-tier stack with Compose
- Implement security and health checks

**Final Exam:**
- Multiple choice
- True/False
- Fill in the blank
- Short answer
- Practical exercises

---

## 5.3 Grading Rubric

**Workbook (30%):**
- Completion: 20%
- Correctness: 10%

**Practical Project (40%):**
- Dockerfile quality: 15%
- Compose configuration: 15%
- Security implementation: 10%

**Final Exam (30%):**
- Knowledge: 20%
- Practical: 10%

**Passing Score: 70%**

---

## 5.4 Certificate of Completion

**Recommended Requirements:**
- All course materials completed
- Final exam score ≥ 70%
- Practical project submitted

**Certificate Text:**
> This certifies that [Name] has successfully completed the Docker Mastery: Containerize Anything From Zero to Production course, demonstrating proficiency in Docker fundamentals, image creation, container orchestration, and production best practices.

---

# SECTION 6: ADDITIONAL RESOURCES

## 6.1 Recommended Reading

**Books:**
- "Docker Up & Running" by Karl Matthias and Sean Kane
- "The Docker Book" by James Turnbull
- "Kubernetes Up & Running" by Kelsey Hightower

**Online Resources:**
- Docker Official Documentation: docs.docker.com
- Docker Curriculum: docker-curriculum.com
- Play with Docker: play-with-docker.com
- Kubernetes Documentation: kubernetes.io/docs

---

## 6.2 Supplementary Videos

**Recommended Channels:**
- Docker Official YouTube
- TechWorld with Nana
- IBM Technology
- Kubernetes Official YouTube

**Key Topics:**
- Docker basics (if needed review)
- Kubernetes fundamentals
- CI/CD pipelines
- Security best practices

---

## 6.3 Practice Platforms

**Interactive Labs:**
- Katacoda (now killing, use alternatives)
- Play with Docker
- Docker Desktop Labs
- Killercoda

**Self-Paced Practice:**
- Docker Hub (public images)
- GitHub (CI/CD)
- Local development
- Cloud free tiers

---

## 6.4 Instructor Preparation Checklist

**Before Course Start:**
- [ ] Review all course materials
- [ ] Prepare slide deck
- [ ] Test all exercises on your machine
- [ ] Set up student environment
- [ ] Prepare demos
- [ ] Create backup plans for technical issues
- [ ] Review common questions and answers

**During Course:**
- [ ] Track attendance
- [ ] Monitor student progress
- [ ] Address questions promptly
- [ ] Adjust pacing based on student needs
- [ ] Collect feedback

**After Course:**
- [ ] Evaluate student performance
- [ ] Provide feedback to students
- [ ] Update materials based on feedback
- [ ] Issue certificates
- [ ] Post-course survey

---

# SECTION 7: FREQUENTLY ASKED QUESTIONS

## 7.1 Student FAQs

**Q: Do I need to know Linux to take this course?**
**A:** Basic command-line familiarity is helpful, but you don't need to be a Linux expert. Docker abstracts much of the Linux complexity, and we cover the essentials.

**Q: Can I use Windows or macOS?**
**A:** Yes! Docker Desktop works on Windows, macOS, and Linux. All examples work across platforms.

**Q: How much RAM do I need?**
**A:** 8GB minimum, 16GB recommended for running multiple containers comfortably.

**Q: Do I need a cloud account?**
**A:** Not for the main series. Some advanced sections may use registries, but free accounts work.

**Q: Will this course prepare me for Docker certification?**
**A:** Yes! This course covers the majority of topics on the Docker Certified Associate (DCA) exam.

---

## 7.2 Instructor FAQs

**Q: How do I handle students with different OS?**
**A:** Use Docker Desktop which provides consistent behavior across platforms. Highlight platform-specific notes where needed.

**Q: What if a student's machine can't run Docker?**
**A:** Have them use Play with Docker or a cloud-based environment.

**Q: How do I keep the course engaging?**
**A:** Use real-world examples, encourage discussion, and keep lectures short with lots of hands-on practice.

**Q: How do I handle students who are ahead or behind?**
**A:** Provide additional exercises for fast learners and encourage peer support. Use the workbook for self-paced progress.

**Q: How do I manage the Q&A flow?**
**A:** Use the "parking lot" method: write down questions, address them at appropriate times, and don't let them derail the session.

---

# SECTION 8: TRAINER NOTES BY PART

## 8.1 Part 1: Core Foundation

**Key Teaching Points:**
- **The Problem:** Start with a real "it works on my machine" story
- **Namespaces:** Use the "bubble" analogy
- **Cgroups:** Use the "budget" analogy
- **Images vs Containers:** Use the "blueprint vs building" analogy

**Common Mistakes:**
- Forgetting `docker ps -a` to see stopped containers
- Not using `--rm` and leaving stopped containers
- Misunderstanding port mapping direction

**Demonstration Ideas:**
- Show a container consuming CPU with a stress test
- Show process isolation with `ps aux`
- Show network isolation with `ip addr`

---

## 8.2 Part 2: Custom Images

**Key Teaching Points:**
- **Layering:** Visualize with `docker history`
- **Caching:** Show build speed with and without cache
- **Multi-stage:** Show the size difference

**Common Mistakes:**
- Using `latest` tag
- Not chaining `RUN` commands
- Forgetting `.dockerignore`

**Demonstration Ideas:**
- Build a 1GB image, then optimize to <100MB
- Show `docker history` to explain layers
- Show build time difference with caching

---

## 8.3 Part 3: Persistence and Networking

**Key Teaching Points:**
- **Ephemeral:** Demonstrate data loss
- **Volumes:** Demonstrate data persistence
- **Bind Mounts:** Demonstrate hot reload
- **Networks:** Demonstrate DNS resolution

**Common Mistakes:**
- Using bind mounts in production
- Not using named volumes for databases
- Forgetting to create networks

**Demonstration Ideas:**
- Run PostgreSQL, add data, remove container, show data persists
- Edit code with bind mounts, see changes live
- Two containers on same network, ping by name

---

## 8.4 Part 4: Docker Compose

**Key Teaching Points:**
- **Declarative:** Compare to manual commands
- **Environment:** Show `.env` usage
- **Dependencies:** Show `depends_on` and health checks
- **Profiles:** Show selective startup

**Common Mistakes:**
- Forgetting `down -v` to remove volumes
- Not understanding `depends_on` limitations
- Missing health check conditions

**Demonstration Ideas:**
- Convert long command to Compose file
- Show hot reload with bind mounts in Compose
- Show environment-specific configurations

---

## 8.5 Part 5: Production Readiness

**Key Teaching Points:**
- **Security:** Show insecure → secure transformation
- **Resources:** Show OOM killer in action
- **Health Checks:** Show unhealthy detection
- **CI/CD:** Walk through pipeline step by step

**Common Mistakes:**
- Running as root
- No resource limits
- No health checks
- Secrets in images

**Demonstration Ideas:**
- Container with no limits consuming memory
- Health check showing unhealthy then healthy
- GitHub Actions pipeline in action

---

## 8.6 Part 6: Debugging

**Key Teaching Points:**
- **Systematic:** Follow the checklist
- **Logs:** Primary debugging tool
- **Inspection:** Understand container state
- **Optimization:** Show before/after

**Common Mistakes:**
- Not checking logs first
- Not using `--tail` with logs
- Forgetting to check OOM status

**Demonstration Ideas:**
- Broken container, debug step by step
- Show `docker events` monitoring
- Optimize a slow build

---

## 8.7 Part 7: Security and Registries

**Key Teaching Points:**
- **Signing:** Trust but verify
- **SBOM:** Know what's in your images
- **Scanning:** Continuous security
- **Registries:** Strategy matters

**Common Mistakes:**
- Not signing production images
- No SBOM generation
- Using only one vulnerability scanner
- No registry cleanup policy

**Demonstration Ideas:**
- Sign image, verify it
- Generate SBOM, show package list
- Run scanning pipeline

---

## 8.8 Part 8: Orchestration

**Key Teaching Points:**
- **Orchestration:** Solve real problems
- **Swarm:** Simple, Docker-native
- **Kubernetes:** Industry standard, more complex
- **Mapping:** Connect Docker concepts

**Common Mistakes:**
- Underestimating orchestration complexity
- Choosing the wrong orchestrator
- Not understanding networking differences

**Demonstration Ideas:**
- Deploy Swarm, scale, rollback
- Show Swarm stack deployment
- Walk through Kubernetes deployment

---

# SECTION 9: COURSE EVALUATION

## 9.1 Student Feedback Survey

**Post-Course Survey Questions:**

1. Rate the overall quality of the course (1-5)

2. What was the most valuable part of the course?

3. What was the least valuable part?

4. How would you rate the instructor's knowledge? (1-5)

5. Were the hands-on exercises helpful? (1-5)

6. What additional topics would you like to see?

7. Would you recommend this course to others? (Yes/No)

8. What is one thing we could improve?

---

## 9.2 Instructor Self-Reflection

- Did I achieve the learning objectives?
- Were students engaged?
- Did I address all questions?
- Was the pacing appropriate?
- What could I do differently?
- What went well?
- What needs improvement?

---

## 9.3 Continuous Improvement

**Action Items:**

| Feedback Type | Action |
|---------------|--------|
| Technical issues | Update materials, test alternatives |
| Content gaps | Add supplementary materials |
| Pacing issues | Adjust timing, add optional sections |
| Clarity issues | Revise explanations, add examples |
| Student requests | Note for future sessions |

---

**End of Trainer Guide**
