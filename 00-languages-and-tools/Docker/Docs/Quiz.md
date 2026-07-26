# DOCKER MASTERY: CONTAINERIZE ANYTHING FROM ZERO TO PRODUCTION

## Quiz and Test Bank with Answer Keys

---

**Purpose:** This comprehensive assessment bank accompanies the Docker Mastery series. It includes quizzes for each part, a comprehensive final exam, and answer keys for all questions.

**How to Use:**
- Self-assessment: Test your knowledge after each part
- Instructor use: Create tests and exams
- Certification prep: Practice for Docker certification
- Review: Identify areas needing further study

**Question Types:**
- Multiple Choice
- True/False
- Fill in the Blank
- Short Answer
- Scenario-Based
- Practical Exercises

---

---

# PART 1: CORE FOUNDATION

## Quiz 1.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. What is the primary purpose of containerization?**

A. To virtualize hardware
B. To package applications with their dependencies for consistent deployment
C. To replace operating systems
D. To increase hardware utilization

**Answer: B**

---

**2. Which of the following is a key difference between containers and virtual machines?**

A. Containers are slower than VMs
B. Containers share the host OS kernel while VMs have their own OS
C. Containers require more resources than VMs
D. Containers cannot be used in production

**Answer: B**

---

**3. What Linux feature provides isolation of process IDs for containers?**

A. Cgroups
B. Namespaces
C. UnionFS
D. Systemd

**Answer: B**

---

**4. Which command starts a container in detached mode?**

A. `docker run -it nginx`
B. `docker run -d nginx`
C. `docker run --rm nginx`
D. `docker start nginx`

**Answer: B**

---

**5. What is the default network driver in Docker?**

A. Host
B. Overlay
C. Bridge
D. Macvlan

**Answer: C**

---

**6. Which command shows all containers including stopped ones?**

A. `docker ps`
B. `docker ps -a`
C. `docker containers`
D. `docker list`

**Answer: B**

---

**7. What is the role of containerd in the Docker architecture?**

A. It's the command-line client
B. It manages container lifecycle
C. It creates namespaces and cgroups
D. It builds images

**Answer: B**

---

**8. Which command would you use to view the logs of a running container?**

A. `docker inspect container`
B. `docker logs container`
C. `docker ps container`
D. `docker stats container`

**Answer: B**

---

**9. What does the `-p 8080:80` flag in `docker run` do?**

A. Publishes port 80 on the container to port 8080 on the host
B. Publishes port 8080 on the container to port 80 on the host
C. Sets the container's PID to 8080
D. Sets the container's priority to 80

**Answer: A**

---

**10. Which Linux feature limits resource usage for containers?**

A. Namespaces
B. Cgroups
C. SELinux
D. AppArmor

**Answer: B**

---

## Quiz 1.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. Containers run faster than virtual machines because they don't have a full OS.**

**Answer: T**

---

**2. A Docker image is a running instance of a container.**

**Answer: F** (A container is a running instance of an image)

---

**3. The Docker daemon is also known as `dockerd`.**

**Answer: T**

---

**4. Docker containers are persistent by default and never lose data.**

**Answer: F** (Containers are ephemeral; data is lost when removed unless using volumes)

---

**5. The `docker stop` command sends SIGKILL to the container.**

**Answer: F** (It sends SIGTERM first, then SIGKILL after grace period)

---

**6. All containers on the default bridge network can resolve each other by container name.**

**Answer: F** (Only user-defined bridge networks provide DNS resolution)

---

**7. The `docker rm` command removes a container.**

**Answer: T**

---

**8. Port mapping is required to access a container's service from the host.**

**Answer: T**

---

**9. The `docker stats` command shows real-time resource usage of containers.**

**Answer: T**

---

**10. Docker images are built from Dockerfiles.**

**Answer: T**

---

## Quiz 1.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The command to run a container with an interactive terminal is `docker run ____`. **

**Answer: -it**

---

**2. __________ provide isolated views of system resources for containers.**

**Answer: Namespaces**

---

**3. __________ limit and account for resource usage in containers.**

**Answer: Cgroups**

---

**4. The default bridge network in Docker uses the IP range __________.**

**Answer: 172.17.0.0/16**

---

**5. The command to view the IP address of a container is `docker inspect --format='{{.NetworkSettings.IPAddress}}' __________`.**

**Answer: container-name**

---

**6. The __________ is the background service that manages Docker objects.**

**Answer: Docker daemon (dockerd)**

---

**7. A __________ is a running instance of a Docker image.**

**Answer: container**

---

**8. The __________ is the default network driver in Docker.**

**Answer: bridge**

---

**9. The command to remove all stopped containers is `docker container __________`.**

**Answer: prune**

---

**10. The __________ namespace isolates hostname and domain name.**

**Answer: UTS**

---

## Quiz 1.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. Explain the difference between an image and a container.**

**Answer:** An image is a read-only template containing the application code, dependencies, and configuration. It's like a blueprint. A container is a running instance of that image, with a writable layer added for runtime changes. Multiple containers can run from the same image.

---

**2. What is environment drift and how does Docker solve it?**

**Answer:** Environment drift occurs when development, testing, and production environments differ, causing applications to work in one environment but fail in another. Docker solves this by packaging the application with all its dependencies and configuration into a container that runs consistently across any environment with Docker installed.

---

**3. Describe the Docker architecture and the role of each major component.**

**Answer:**
- **Docker Client:** The command-line tool users interact with.
- **Docker Daemon (dockerd):** The background service that manages containers, images, networks, and volumes.
- **containerd:** The container runtime that manages the container lifecycle.
- **runc:** The low-level OCI runtime that creates namespaces and cgroups.

---

**4. What is the purpose of port mapping in Docker?**

**Answer:** Port mapping publishes a container's port to the host machine, allowing external traffic to reach services running inside the container. Without port mapping, containers are only accessible from within Docker's internal network.

---

**5. How do you view the logs of a container and follow them in real-time?**

**Answer:** Use `docker logs -f container-name` or `docker logs --follow container-name`. The `-f` flag follows the logs in real-time, similar to `tail -f`.

---

## Quiz 1.5: Scenario-Based

**Instructions:** Read each scenario and provide the appropriate solution.

---

**Scenario 1:**
You've just installed Docker and want to verify it's working correctly. You also want to run a test container to see the welcome message.

**What commands would you use?**

**Answer:**
```bash
docker --version
docker run hello-world
```

---

**Scenario 2:**
You need to run an Ubuntu 22.04 container with an interactive bash shell. When you exit, you want the container to be automatically removed.

**What command would you use?**

**Answer:**
```bash
docker run -it --rm ubuntu:22.04 bash
```

---

**Scenario 3:**
You have a web server running in a container called `web` on port 80 inside the container. You want to access it from your browser at `http://localhost:8080`.

**What command would you use to run this container?**

**Answer:**
```bash
docker run -d --name web -p 8080:80 nginx:alpine
```

---

**Scenario 4:**
Your container named `api` is behaving strangely. You want to check its logs, inspect its configuration, and see what processes are running inside it.

**What commands would you use?**

**Answer:**
```bash
docker logs api
docker inspect api
docker top api
```

---

**Scenario 5:**
You have several stopped containers taking up disk space. You want to remove all stopped containers at once.

**What command would you use?**

**Answer:**
```bash
docker container prune
```

---

---

# PART 2: CUSTOM IMAGES

## Quiz 2.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. Which Dockerfile instruction specifies the base image?**

A. BASE
B. IMAGE
C. FROM
D. START

**Answer: C**

---

**2. What is the difference between CMD and ENTRYPOINT?**

A. CMD can be overridden, ENTRYPOINT cannot
B. ENTRYPOINT can be overridden, CMD cannot
C. They are the same thing
D. CMD is for development, ENTRYPOINT is for production

**Answer: A**

---

**3. Why should you order Dockerfile instructions from least-changing to most-changing?**

A. To improve image security
B. To optimize layer caching
C. To reduce image size
D. To improve readability

**Answer: B**

---

**4. Which of the following is a benefit of multi-stage builds?**

A. Faster builds
B. Smaller final images
C. Better security
D. All of the above

**Answer: D**

---

**5. What is the purpose of a `.dockerignore` file?**

A. To ignore Docker commands
B. To exclude files from the build context
C. To ignore containers during pruning
D. To disable Docker daemon features

**Answer: B**

---

**6. Which base image is typically the smallest?**

A. Ubuntu
B. Debian
C. Alpine
D. CentOS

**Answer: C**

---

**7. What does the `--no-cache` flag do in `docker build`?**

A. Builds without using the build cache
B. Builds without network access
C. Builds without using the Docker daemon
D. Builds without saving the image

**Answer: A**

---

**8. Which instruction sets the working directory for subsequent commands?**

A. `DIR`
B. `WORKDIR`
C. `PWD`
D. `CD`

**Answer: B**

---

**9. How do you pass a build-time argument to `docker build`?**

A. `--arg`
B. `--build-arg`
C. `--env`
D. `--param`

**Answer: B**

---

**10. What is the purpose of the `HEALTHCHECK` instruction?**

A. To check if the image is corrupt
B. To verify the container is working properly
C. To check the Docker daemon health
D. To monitor host system health

**Answer: B**

---

## Quiz 2.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. The `COPY` instruction can download files from URLs.**

**Answer: F** (ADD can, but COPY cannot)

---

**2. Each instruction in a Dockerfile creates a new image layer.**

**Answer: T**

---

**3. Multi-stage builds were introduced to make images smaller and more secure.**

**Answer: T**

---

**4. The `USER` instruction changes the user for `RUN`, `CMD`, and `ENTRYPOINT` instructions.**

**Answer: T**

---

**5. Using `latest` tag is recommended for production images.**

**Answer: F** (Specific tags should be used in production)

---

**6. The `EXPOSE` instruction actually publishes the port to the host.**

**Answer: F** (It's documentation; `-p` publishes ports)

---

**7. Build cache is automatically cleared after each build.**

**Answer: F** (Cache persists until pruned)

---

**8. The `ADD` instruction can automatically extract tar files.**

**Answer: T**

---

**9. `ENTRYPOINT ["python"]` `CMD ["app.py"]` allows overriding `app.py` at runtime.**

**Answer: T**

---

**10. A `.dockerignore` file is required for every Docker build.**

**Answer: F** (Recommended but not required)

---

## Quiz 2.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The instruction to copy files from one stage to another in a multi-stage build is `COPY --from=__________`.**

**Answer: stage-name**

---

**2. The __________ instruction sets environment variables in the image.**

**Answer: ENV**

---

**3. A __________ is a Dockerfile with multiple `FROM` statements.**

**Answer: multi-stage build**

---

**4. The __________ instruction creates a mount point for external volumes.**

**Answer: VOLUME**

---

**5. The __________ instruction adds metadata to the image.**

**Answer: LABEL**

---

**6. The __________ variable in a Dockerfile can be overridden at build time.**

**Answer: ARG**

---

**7. The __________ instruction changes the default shell for shell-form commands.**

**Answer: SHELL**

---

**8. The command to build an image is `docker build -t __________ .`.**

**Answer: image-name:tag**

---

**9. __________ images contain only your application and its runtime dependencies, without a shell or package manager.**

**Answer: Distroless**

---

**10. The __________ image is an empty image with no base OS.**

**Answer: scratch**

---

## Quiz 2.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. Explain the concept of multi-stage builds and why they are beneficial.**

**Answer:** Multi-stage builds use multiple `FROM` statements in a single Dockerfile to separate build and runtime environments. Each stage builds on the previous one, but only the final stage is included in the final image. Benefits include smaller images (build tools and dev dependencies are excluded), improved security (fewer components in final image), and cleaner Dockerfiles.

---

**2. How does Docker's build cache work and why is it important to order instructions correctly?**

**Answer:** Docker caches each layer created by `RUN`, `COPY`, and `ADD` instructions. If the instruction hasn't changed, Docker reuses the cached layer. By ordering instructions from least-changing (like installing dependencies) to most-changing (like copying source code), you maximize cache reuse and speed up subsequent builds.

---

**3. What is the difference between `COPY` and `ADD`? When should you use each?**

**Answer:** `COPY` is straightforward and copies files/directories from the build context to the image. `ADD` includes additional features: automatic tar extraction, URL downloads, and advanced path handling. Best practice recommends using `COPY` unless you specifically need the extra features of `ADD`.

---

**4. Why should you run containers as a non-root user?**

**Answer:** Running as non-root follows the principle of least privilege. If a container is compromised, an attacker would have limited permissions—they couldn't install packages, modify system files, or access other containers' data. This significantly reduces the potential damage of a security breach.

---

**5. Write a multi-stage Dockerfile for a simple Python application.**

**Answer:**
```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
CMD ["python", "app.py"]
```

---

## Quiz 2.5: Scenario-Based

**Instructions:** Read each scenario and provide the appropriate solution.

---

**Scenario 1:**
Your Dockerfile builds a 1.2GB image. You need to reduce the image size for production.

**What strategies would you use?**

**Answer:**
1. Use a smaller base image (e.g., Alpine or slim)
2. Implement multi-stage builds
3. Combine `RUN` commands to reduce layers
4. Clean package manager caches
5. Remove build tools after use
6. Use `.dockerignore` to exclude unnecessary files
7. Use `--no-cache` or `--no-cache-dir` with package managers

---

**Scenario 2:**
Your Dockerfile has these instructions:
```dockerfile
COPY . .
RUN npm install
COPY package.json .
```
This build takes a long time.

**What's wrong and how would you fix it?**

**Answer:** The `COPY . .` before `npm install` invalidates the cache every time source code changes. The correct order should be:
```dockerfile
COPY package*.json .
RUN npm install
COPY . .
```
This installs dependencies first (which rarely changes) and copies source code last (which changes frequently), maximizing cache usage.

---

**Scenario 3:**
Your image contains secrets (database passwords) that were accidentally committed to the Dockerfile. You need to remove them securely.

**What approach would you take?**

**Answer:**
1. Use environment variables with `ENV` or at runtime with `-e`
2. Use `ARG` for build-time secrets (with caution)
3. Use Docker Secrets (Swarm mode) or Kubernetes Secrets
4. Mount secret files at runtime using volumes
5. Use tools like HashiCorp Vault
6. Never hardcode secrets in Dockerfiles

---

---

# PART 3: PERSISTENCE AND NETWORKING

## Quiz 3.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. Which storage option persists data outside the container lifecycle?**

A. tmpfs
B. Anonymous volume
C. Named volume
D. Both B and C

**Answer: D**

---

**2. What is the difference between a volume and a bind mount?**

A. Volumes are managed by Docker, bind mounts are managed by the user
B. Bind mounts are managed by Docker, volumes are managed by the user
C. They are the same thing
D. Volumes are faster than bind mounts

**Answer: A**

---

**3. Which network driver provides DNS resolution between containers on the same network?**

A. Default bridge
B. Host
C. User-defined bridge
D. None

**Answer: C**

---

**4. What is the purpose of `tmpfs` mounts?**

A. Persistent storage
B. In-memory temporary storage
C. Network storage
D. Backup storage

**Answer: B**

---

**5. Which command creates a named volume?**

A. `docker volume create my-volume`
B. `docker volume new my-volume`
C. `docker volume add my-volume`
D. `docker volume init my-volume`

**Answer: A**

---

**6. On a user-defined bridge network, how do containers reach each other?**

A. By IP address only
B. By container name
C. By hostname only
D. By MAC address

**Answer: B**

---

**7. What does the `-v my-data:/data` flag do?**

A. Binds host directory `/data` to container `/my-data`
B. Mounts named volume `my-data` to `/data` in container
C. Creates a bind mount
D. Mounts a tmpfs volume

**Answer: B**

---

**8. Which network driver is used for multi-host networking in Swarm mode?**

A. Bridge
B. Host
C. Overlay
D. Macvlan

**Answer: C**

---

**9. How do you connect a container to an existing network?**

A. `docker network connect container-name network-name`
B. `docker network connect network-name container-name`
C. `docker connect container-name network-name`
D. `docker attach network-name container-name`

**Answer: B**

---

**10. What is the default network driver in Docker?**

A. Host
B. Overlay
C. Bridge
D. None

**Answer: C**

---

## Quiz 3.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. Volumes are the preferred way to persist data in production.**

**Answer: T**

---

**2. Bind mounts work the same way on Windows, macOS, and Linux.**

**Answer: F** (Path syntax differs, and performance varies)

---

**3. Data written to a container's writable layer persists after container removal.**

**Answer: F** (Data is lost when container is removed)

---

**4. The `host` network driver provides the best isolation.**

**Answer: F** (Provides no isolation; `none` provides the best isolation)

---

**5. Containers on a user-defined bridge network can resolve each other by container name.**

**Answer: T**

---

**6. The `docker volume prune` command removes all volumes, including those in use.**

**Answer: F** (Only removes unused volumes)

---

**7. tmpfs mounts are stored in memory and are faster than disk storage.**

**Answer: T**

---

**8. On the default bridge network, containers can communicate by name without any extra configuration.**

**Answer: F** (Only user-defined bridge networks provide DNS resolution)

---

**9. The `--rm` flag removes a container when it stops.**

**Answer: T**

---

**10. All containers on the host network can see each other's ports.**

**Answer: T** (They share the host's network namespace)

---

## Quiz 3.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The command to create a network is `docker network __________`.**

**Answer: create**

---

**2. A __________ is a Docker-managed storage solution for persisting data.**

**Answer: volume**

---

**3. A __________ is a host directory mounted directly into a container.**

**Answer: bind mount**

---

**4. The __________ network driver provides no network isolation.**

**Answer: host**

---

**5. Containers on the same user-defined bridge network can communicate by __________.**

**Answer: name / container name**

---

**6. The command to backup a volume is `docker run --rm -v volume-name:/source -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C __________ .`.**

**Answer: /source**

---

**7. The __________ network driver is used for multi-host networking.**

**Answer: overlay**

---

**8. The __________ network driver provides a MAC address to each container.**

**Answer: macvlan**

---

**9. The command to list all volumes is `docker volume __________`.**

**Answer: ls**

---

**10. __________ mounts are stored in memory and are temporary.**

**Answer: tmpfs**

---

## Quiz 3.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. Explain the difference between a volume and a bind mount.**

**Answer:** Volumes are managed by Docker, stored in Docker's storage directory (`/var/lib/docker/volumes/`), and are the preferred way to persist data in production. Bind mounts are user-managed host directories mounted into containers and are commonly used for development. Volumes are more portable, easier to back up, and have better performance on some systems.

---

**2. Why are containers considered "ephemeral"?**

**Answer:** Containers are considered ephemeral because they are designed to be created, destroyed, and recreated easily. Any data written to the container's filesystem is lost when the container is removed. This is intentional, as it allows containers to be stateless and easily replaced.

---

**3. How does DNS resolution work on a user-defined bridge network?**

**Answer:** Docker provides a built-in DNS server at `127.0.0.11` that resolves container names to IP addresses. When a container on a user-defined bridge network tries to reach another container by name, the DNS server resolves it to the correct IP, allowing containers to communicate by name instead of IP address.

---

**4. What are the three storage options in Docker and when would you use each?**

**Answer:**
- **Volumes:** Production data persistence, managed by Docker
- **Bind Mounts:** Development, mounting source code for hot reload
- **tmpfs:** Temporary in-memory storage for caches and secrets

---

**5. Describe the steps to set up a custom bridge network with two containers that can communicate.**

**Answer:**
```bash
# 1. Create the network
docker network create app-net

# 2. Run containers on the network
docker run -d --name container1 --network app-net nginx
docker run -d --name container2 --network app-net redis

# 3. Test connectivity
docker exec container1 ping container2
```

---

## Quiz 3.5: Scenario-Based

**Instructions:** Read each scenario and provide the appropriate solution.

---

**Scenario 1:**
You have a PostgreSQL container that needs to persist data. The container is frequently restarted and recreated.

**What storage solution would you use and how?**

**Answer:** Use a named volume:
```bash
docker volume create pg-data
docker run -d --name postgres -v pg-data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=secret postgres:15
```

---

**Scenario 2:**
You're developing a Python application and want to see code changes immediately without rebuilding the image.

**What would you use and how?**

**Answer:** Use a bind mount:
```bash
docker run -d --name dev-app -v $(pwd):/app -p 5000:5000 python:3.11 python /app/app.py
```
With hot reload enabled in the application, changes will be reflected immediately.

---

**Scenario 3:**
You have two containers: a web server (`web`) and a backend API (`api`). They need to communicate, but they're on the default bridge network.

**What's the problem and how would you solve it?**

**Answer:** On the default bridge network, containers cannot resolve each other by name. The solution is to create a user-defined bridge network:
```bash
docker network create app-net
docker network connect app-net web
docker network connect app-net api
# Now web can ping api by name
```

---

---

# PART 4: DOCKER COMPOSE

## Quiz 4.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. What file format does Docker Compose use?**

A. JSON
B. YAML
C. XML
D. TOML

**Answer: B**

---

**2. Which command starts all services in a Compose file?**

A. `docker compose start`
B. `docker compose up`
C. `docker compose run`
D. `docker compose init`

**Answer: B**

---

**3. What is the purpose of the `depends_on` directive?**

A. To specify which services are dependent on each other for start order
B. To link containers together
C. To share volumes between services
D. To specify resource limits

**Answer: A**

---

**4. How do you specify environment variables in a Compose file?**

A. `env:`
B. `environment:`
C. `variables:`
D. `env_file:`

**Answer: B**

---

**5. Which command stops and removes all containers, networks, and volumes defined in a Compose file?**

A. `docker compose down`
B. `docker compose stop`
C. `docker compose rm`
D. `docker compose cleanup`

**Answer: A**

---

**6. What is the purpose of Compose profiles?**

A. To selectively start services
B. To create different versions of the compose file
C. To apply security policies
D. To manage Docker versions

**Answer: A**

---

**7. Which directive is used to define named volumes in a Compose file?**

A. `volumes:` at the service level
B. `volumes:` at the top level
C. `volume:` at the service level
D. `storage:` at the top level

**Answer: B**

---

**8. How do you scale a service in Docker Compose?**

A. `docker compose scale service=3`
B. `docker compose up -d --scale service=3`
C. `docker service scale service=3`
D. Both A and B

**Answer: D**

---

**9. What is the purpose of the `env_file` directive?**

A. To load environment variables from a file
B. To save environment variables to a file
C. To generate environment variable files
D. To encrypt environment variables

**Answer: A**

---

**10. Which command shows the logs of all services in a Compose project?**

A. `docker compose logs`
B. `docker compose ps`
C. `docker compose events`
D. `docker compose inspect`

**Answer: A**

---

## Quiz 4.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. Docker Compose is used to define and run multi-container Docker applications.**

**Answer: T**

---

**2. The `depends_on` directive waits for services to be fully healthy before starting dependent services.**

**Answer: F** (It only waits for start, not health; use `service_healthy` condition for health checks)

---

**3. Environment variables in Compose can reference variables from a `.env` file.**

**Answer: T**

---

**4. The `docker compose down` command removes all volumes by default.**

**Answer: F** (Use `-v` flag to remove volumes)

---

**5. Compose profiles allow you to conditionally start services.**

**Answer: T**

---

**6. You can override Compose configuration with `docker-compose.override.yml`.**

**Answer: T**

---

**7. The `build` directive in Compose always builds a new image for each `docker compose up`.**

**Answer: F** (It builds if no image exists or if `--build` is used)

---

**8. Compose files support both `ports` and `expose` directives.**

**Answer: T**

---

**9. The `restart: always` policy is available in Compose.**

**Answer: T**

---

**10. Compose volumes are only available in production configurations.**

**Answer: F** (Available in all environments)

---

## Quiz 4.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The top-level sections of a Compose file are `services:`, `volumes:`, and `__________`.**

**Answer: networks**

---

**2. The command to execute a command inside a running service is `docker compose __________`.**

**Answer: exec**

---

**3. The directive to specify service dependencies is `__________`.**

**Answer: depends_on**

---

**4. The Compose file version for current best practices is `__________`.**

**Answer: 3.8**

---

**5. The command to view the configuration with variables substituted is `docker compose __________`.**

**Answer: config**

---

**6. The __________ directive loads environment variables from a file.**

**Answer: env_file**

---

**7. __________ profiles allow selective service startup.**

**Answer: Compose**

---

**8. The command to pull all images defined in a Compose file is `docker compose __________`.**

**Answer: pull**

---

**9. The __________ directive defines resource limits for services.**

**Answer: deploy**

---

**10. The command to list all services in a Compose project is `docker compose __________`.**

**Answer: ps**

---

## Quiz 4.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. What is Docker Compose and why is it useful?**

**Answer:** Docker Compose is a tool for defining and running multi-container Docker applications. It uses a YAML file to configure application services, networks, and volumes. It's useful because it replaces long `docker run` commands with declarative configuration, ensures consistent environments, and makes it easy to start and stop complex multi-service applications.

---

**2. Describe the structure of a docker-compose.yml file.**

**Answer:** A Compose file has three main top-level sections:
- **services:** Define containers with configurations (image, build, ports, volumes, environment)
- **volumes:** Define named volumes for persistence
- **networks:** Define custom networks for service communication

---

**3. How do you handle different environments (development vs production) with Docker Compose?**

**Answer:** Use:
- Different Compose files: `docker-compose.yml` (base), `docker-compose.override.yml` (development), `docker-compose.prod.yml` (production)
- Environment variables with `.env` files
- Profiles for conditional service inclusion
- Compose extends functionality for sharing common config

---

**4. Write a simple docker-compose.yml for a web server and a database.**

**Answer:**
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - pg-data:/var/lib/postgresql/data

volumes:
  pg-data:
```

---

## Quiz 4.5: Scenario-Based

**Instructions:** Read each scenario and provide the appropriate solution.

---

**Scenario 1:**
You have a Compose file with three services. You want to start only two of them for development, excluding the monitoring service.

**How would you achieve this?**

**Answer:** Use profiles:
```yaml
services:
  app:
    # ...
  db:
    # ...
  monitoring:
    profiles:
      - production
```
Then start with `docker compose up -d app db` or use `--profile` as needed.

---

**Scenario 2:**
Your Compose application runs perfectly in development but fails in production because of different environment variables.

**How would you solve this?**

**Answer:** Use environment-specific configuration:
1. `.env` file for common variables
2. `docker-compose.override.yml` for development overrides
3. `docker-compose.prod.yml` for production
4. Or use `docker compose --env-file .env.production up`

---

---

# PART 5: PRODUCTION READINESS

## Quiz 5.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. Why should containers run as non-root users in production?**

A. To improve performance
B. To reduce the impact of security vulnerabilities
C. To enable volume mounts
D. To allow port binding below 1024

**Answer: B**

---

**2. Which capability is required for a web server to bind to port 80?**

A. CHOWN
B. DAC_OVERRIDE
C. NET_BIND_SERVICE
D. SYS_ADMIN

**Answer: C**

---

**3. What is the purpose of a health check in a container?**

A. To monitor host system health
B. To verify the container is working properly
C. To check image integrity
D. To measure resource usage

**Answer: B**

---

**4. Which command sets memory and CPU limits for a running container?**

A. `docker limit`
B. `docker update`
C. `docker set`
D. `docker config`

**Answer: B**

---

**5. What is the recommended way to handle secrets in Docker?**

A. Bake them into the image
B. Use environment variables only
C. Use Docker Secrets or external secret management
D. Hardcode them in the Dockerfile

**Answer: C**

---

**6. Which logging driver is recommended for production?**

A. none
B. json-file
C. syslog
D. Any driver with log rotation

**Answer: D** (All with proper rotation; json-file is common)

---

**7. What does a `read_only: true` configuration do?**

A. Makes the container's filesystem read-only
B. Prevents the container from writing to volumes
C. Stops the container if it tries to write
D. Makes the image read-only

**Answer: A**

---

**8. Which flag in `docker run` sets a memory limit?**

A. `--memory`
B. `--mem`
C. `--ram`
D. `--limit-memory`

**Answer: A**

---

**9. What is the purpose of `stop_grace_period`?**

A. Time to wait before killing the container
B. Time to wait after killing the container
C. Time to wait between restart attempts
D. Time to wait before starting the container

**Answer: A**

---

**10. Which of the following is NOT a recommended security practice?**

A. Running as non-root
B. Using read-only filesystem
C. Running with all capabilities
D. Dropping unnecessary capabilities

**Answer: C**

---

## Quiz 5.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. Resource limits are optional for production containers.**

**Answer: F** (They are essential to prevent noisy neighbor issues)

---

**2. Health checks should be used in production but not in development.**

**Answer: F** (Useful in all environments)

---

**3. The `json-file` logging driver supports log rotation.**

**Answer: T**

---

**4. Secrets should never be committed to version control.**

**Answer: T**

---

**5. All containers need the `NET_BIND_SERVICE` capability.**

**Answer: F** (Only those binding to ports below 1024)

---

**6. The `read_only` filesystem prevents all writes, including to volumes.**

**Answer: F** (Volumes and tmpfs can still be written)

---

**7. GitHub Actions can be used to build and scan Docker images.**

**Answer: T**

---

**8. Vulnerability scanning should only be done on production images.**

**Answer: F** (Should be done on all images)

---

**9. The `restart: unless-stopped` policy restarts containers unless manually stopped.**

**Answer: T**

---

**10. Memory limits prevent containers from using swap space.**

**Answer: F** (Memory limits and swap limits are separate)

---

## Quiz 5.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The __________ instruction in Dockerfile switches to a non-root user.**

**Answer: USER**

---

**2. The __________ flag in `docker run` makes the filesystem read-only.**

**Answer: --read-only**

---

**3. The __________ flag in `docker run` drops all capabilities.**

**Answer: --cap-drop=ALL**

---

**4. The __________ instruction in Dockerfile defines a health check.**

**Answer: HEALTHCHECK**

---

**5. __________ limits prevent noisy neighbor problems.**

**Answer: Resource**

---

**6. The __________ logging driver is the default in Docker.**

**Answer: json-file**

---

**7. The __________ command scans images for vulnerabilities using Trivy.**

**Answer: trivy image**

---

**8. __________ is the GitHub Actions workflow file location.**

**Answer: .github/workflows/**

---

**9. The __________ directive in Compose defines resource limits.**

**Answer: deploy.resources**

---

**10. The __________ signal is sent to containers by `docker stop`.**

**Answer: SIGTERM**

---

## Quiz 5.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. List five security best practices for production containers.**

**Answer:**
1. Run as non-root user
2. Use read-only filesystem
3. Drop unnecessary capabilities
4. Use seccomp profiles
5. Scan images for vulnerabilities
6. No secrets in images
7. Use minimal base images

---

**2. Why are resource limits important in a multi-container environment?**

**Answer:** Resource limits prevent any single container from consuming all host resources (CPU, memory, disk I/O), which would cause performance degradation for other containers. This prevents the "noisy neighbor" problem where one container negatively impacts others on the same host.

---

**3. Describe how to implement health checks in a container and why they're important.**

**Answer:** Health checks can be defined in Dockerfile using `HEALTHCHECK` or in compose using `healthcheck`. They verify that the container is working properly by running a command (e.g., HTTP check, TCP check, custom script). They're important because they allow Docker to detect unhealthy containers and take action (restart, remove from load balancer).

---

**4. What is the difference between `livenessProbe` and `readinessProbe` in Kubernetes?**

**Answer:** Liveness probes check if the container is still alive and should be restarted if it fails. Readiness probes check if the container is ready to serve traffic; if it fails, the container is removed from the service load balancer but not restarted.

---

## Quiz 5.5: Scenario-Based

**Instructions:** Read each scenario and provide the appropriate solution.

---

**Scenario 1:**
Your container is using 90% of available memory and causing performance issues for other containers on the same host.

**What would you do?**

**Answer:** Set memory limits:
```bash
docker update --memory=512M --memory-swap=1G container-name
```
Or in compose:
```yaml
deploy:
  resources:
    limits:
      memory: 512M
```

---

**Scenario 2:**
Your container has been compromised and the attacker is trying to escalate privileges.

**What security measures would you implement?**

**Answer:**
1. Drop all capabilities and add only needed ones
2. Run as non-root user
3. Use read-only filesystem
4. Apply seccomp profile
5. Use AppArmor or SELinux
6. Set `no-new-privileges` security option

---

---

# PART 6: DEBUGGING AND OPERATIONS

## Quiz 6.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. Which command shows the last 50 lines of a container's logs with timestamps?**

A. `docker logs -t --tail 50 container`
B. `docker logs --last 50 container`
C. `docker logs -n 50 container`
D. `docker inspect logs container`

**Answer: A**

---

**2. What is the significance of exit code 137?**

A. The container exited normally
B. The container was killed by the OOM killer
C. The container was stopped by `docker stop`
D. The container encountered a fatal error

**Answer: B**

---

**3. Which command shows real-time resource usage of containers?**

A. `docker inspect`
B. `docker top`
C. `docker stats`
D. `docker ps`

**Answer: C**

---

**4. How do you check if a container was killed by the OOM killer?**

A. `docker inspect container --format='{{.State.OOMKilled}}'`
B. `docker logs container | grep OOM`
C. `docker ps -a | grep OOM`
D. `docker stats container`

**Answer: A**

---

**5. Which command shows the processes running inside a container?**

A. `docker ps -a`
B. `docker top container`
C. `docker stats container`
D. `docker exec container ps aux`

**Answer: B** (and D works too)

---

**6. What does the `docker diff` command show?**

A. Changes to the container's filesystem
B. Differences between two images
C. Differences between two containers
D. Differences between two Dockerfiles

**Answer: A**

---

**7. Which command copies files from a container to the host?**

A. `docker cp container:/path /host/path`
B. `docker copy container:/path /host/path`
C. `docker transfer container:/path /host/path`
D. `docker export container:/path /host/path`

**Answer: A**

---

**8. How do you get the IP address of a container?**

A. `docker inspect container --format='{{.NetworkSettings.IPAddress}}'`
B. `docker ip container`
C. `docker network inspect container`
D. `docker inspect container --format='{{.IP}}'`

**Answer: A**

---

**9. Which command monitors Docker events in real-time?**

A. `docker monitor`
B. `docker events`
C. `docker watch`
D. `docker trace`

**Answer: B**

---

**10. What does `docker system df` show?**

A. Docker version information
B. Docker disk usage
C. Docker container status
D. Docker network configuration

**Answer: B**

---

## Quiz 6.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. Logs are the primary source of debugging information for containers.**

**Answer: T**

---

**2. A container with exit code 0 exited successfully.**

**Answer: T**

---

**3. The `docker inspect` command shows detailed configuration information about a container.**

**Answer: T**

---

**4. The `docker exec` command can only run commands in running containers.**

**Answer: T**

---

**5. Docker events show everything happening in the Docker daemon.**

**Answer: T**

---

**6. The `docker cp` command works on stopped containers.**

**Answer: T**

---

**7. `docker stats` shows historical resource usage data.**

**Answer: F** (It shows real-time data only)

---

**8. The `docker logs` command shows logs from the container's stdout and stderr.**

**Answer: T**

---

**9. Exit code 137 always indicates the OOM killer was invoked.**

**Answer: F** (137 = 128 + 9 = SIGKILL; often OOM but not always)

---

**10. Docker events can be filtered by event type.**

**Answer: T**

---

## Quiz 6.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The command to check a container's status is `docker __________`.**

**Answer: ps**

---

**2. The __________ command provides detailed JSON configuration of a container.**

**Answer: inspect**

---

**3. The __________ command allows you to run commands inside a running container.**

**Answer: exec**

---

**4. __________ shows real-time resource usage of containers.**

**Answer: docker stats**

---

**5. The __________ command shows changes to a container's filesystem.**

**Answer: diff**

---

**6. The __________ command copies files between a container and the host.**

**Answer: cp**

---

**7. __________ events can be filtered by container, type, or label.**

**Answer: docker**

---

**8. The __________ command shows disk usage of Docker objects.**

**Answer: system df**

---

**9. __________ cleanup removes unused containers, networks, and images.**

**Answer: docker system prune**

---

**10. The __________ flag shows all containers including stopped ones.**

**Answer: -a**

---

## Quiz 6.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. Describe your systematic approach to debugging a failing container.**

**Answer:**
1. Check if container is running: `docker ps -a`
2. View logs: `docker logs container`
3. Inspect configuration: `docker inspect container`
4. Enter container: `docker exec -it container bash`
5. Check processes: `docker top container`
6. Check resources: `docker stats container`
7. Check file changes: `docker diff container`
8. Monitor events: `docker events`

---

**2. What are the most common reasons containers fail to start?**

**Answer:**
1. Missing or incorrect CMD/ENTRYPOINT
2. Missing environment variables
3. Port conflicts
4. Volume permission issues
5. Missing dependencies
6. Configuration file errors

---

**3. How do you identify and fix an OOM (Out of Memory) issue?**

**Answer:**
1. Check exit code: `docker inspect container --format='{{.State.ExitCode}}'` (137)
2. Check OOM killed flag: `docker inspect container --format='{{.State.OOMKilled}}'`
3. Check memory usage: `docker stats container`
4. Fix: Increase memory limit with `docker update --memory=1G container` or optimize application memory usage

---

---

# PART 7: SECURITY AND REGISTRIES

## Quiz 7.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. What is image signing used for?**

A. To verify image authenticity and integrity
B. To encrypt image contents
C. To compress images
D. To speed up image pulls

**Answer: A**

---

**2. Which tool is used for image signing in the Sigstore ecosystem?**

A. Trivy
B. Cosign
C. Grype
D. Syft

**Answer: B**

---

**3. What is an SBOM?**

A. Software Build Optimization Manager
B. Software Bill of Materials
C. Secure Build Orchestration Module
D. System Binary Object Model

**Answer: B**

---

**4. Which tool generates SBOMs?**

A. Trivy
B. Cosign
C. Syft
D. Docker

**Answer: C**

---

**5. What is the purpose of vulnerability scanning?**

A. To find and fix security vulnerabilities in images
B. To encrypt images
C. To compress images
D. To verify image signatures

**Answer: A**

---

**6. Which of the following is NOT a common container registry?**

A. Docker Hub
B. GitHub Container Registry (GHCR)
C. AWS ECR
D. Docker Build

**Answer: D**

---

**7. What is a best practice for tagging container images?**

A. Always use `latest`
B. Use semantic versioning
C. Use only date stamps
D. Use random strings

**Answer: B**

---

**8. What is the purpose of Docker Secrets?**

A. To store sensitive data securely
B. To encrypt entire images
C. To manage secret Docker commands
D. To hide Docker containers

**Answer: A**

---

**9. Which tool integrates with Trivy for vulnerability scanning?**

A. GitHub Actions
B. Docker Hub
C. Both A and B
D. Neither

**Answer: C**

---

**10. What is OPA (Open Policy Agent) used for in container security?**

A. Policy enforcement
B. Image signing
C. Vulnerability scanning
D. Secret management

**Answer: A**

---

## Quiz 7.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. Image signing ensures images have not been tampered with.**

**Answer: T**

---

**2. SBOMs are only useful for security compliance.**

**Answer: F** (Also useful for vulnerability management, auditing, and supply chain security)

---

**3. Trivy can scan images, filesystems, and repositories.**

**Answer: T**

---

**4. `latest` is a reliable tag for production images.**

**Answer: F** (Never use `latest` in production)

---

**5. Docker Secrets are available in all Docker environments.**

**Answer: F** (Only in Swarm mode)

---

**6. Vulnerability scanning should be integrated into CI/CD pipelines.**

**Answer: T**

---

**7. Cosign requires a private key for signing and a public key for verification.**

**Answer: T**

---

**8. SBOMs can be attached to images as attestations.**

**Answer: T**

---

**9. Registry cleanup policies are not necessary for production.**

**Answer: F** (They are important for managing storage and costs)

---

**10. GitHub Container Registry (GHCR) integrates with GitHub Actions.**

**Answer: T**

---

## Quiz 7.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The __________ command signs a container image.**

**Answer: cosign sign**

---

**2. __________ stands for Software Bill of Materials.**

**Answer: SBOM**

---

**3. The __________ tool generates SBOMs.**

**Answer: syft**

---

**4. __________ is a vulnerability scanning tool.**

**Answer: Trivy** (or Grype)

---

**5. Docker Secrets are mounted at __________.**

**Answer: /run/secrets/**

---

**6. The __________ image tag is not recommended for production.**

**Answer: latest**

---

**7. __________ is the GitHub Container Registry.**

**Answer: GHCR**

---

**8. __________ is used for policy enforcement in Kubernetes.**

**Answer: OPA (Open Policy Agent)**

---

**9. The command to verify an image signature is `cosign __________`.**

**Answer: verify**

---

**10. __________ is a registry cleanup policy strategy.**

**Answer: Retention policy / Age-based cleanup**

---

## Quiz 7.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. Explain the importance of image signing and how it works.**

**Answer:** Image signing ensures that images come from a trusted source and haven't been tampered with. It works by cryptographically signing the image digest with a private key. Users verify the signature with a public key, ensuring the image's integrity and authenticity.

---

**2. What is an SBOM and why is it important?**

**Answer:** An SBOM (Software Bill of Materials) is a list of all components, libraries, and dependencies in a software artifact. It's important for supply chain security, vulnerability management, compliance, and auditing. It helps organizations understand what's in their software and respond quickly to security vulnerabilities.

---

**3. Describe a secure CI/CD pipeline that handles containers.**

**Answer:**
1. Build image
2. Run tests
3. Generate SBOM
4. Scan for vulnerabilities (Trivy/Grype)
5. Sign image (Cosign)
6. Push to registry
7. Deploy with verification

---

## Quiz 7.5: Scenario-Based

**Instructions:** Read each scenario and provide the appropriate solution.

---

**Scenario 1:**
Your organization needs to verify that all production images are from trusted sources and haven't been modified.

**What security controls would you implement?**

**Answer:**
1. Image signing with Cosign
2. Signature verification before deployment
3. Policy enforcement with OPA
4. Use trusted registries
5. SBOM generation for audit
6. Vulnerability scanning

---

---

# PART 8: ORCHESTRATION

## Quiz 8.1: Multiple Choice

**Instructions:** Choose the best answer for each question.

---

**1. What is orchestration in the context of containers?**

A. Automated management of multiple containers
B. Running a single container
C. Building container images
D. Writing Dockerfiles

**Answer: A**

---

**2. Which of the following is NOT a benefit of orchestration?**

A. Scaling
B. Self-healing
C. Manual port mapping
D. Rolling updates

**Answer: C**

---

**3. What is the smallest deployable unit in Kubernetes?**

A. Container
B. Pod
C. Service
D. Deployment

**Answer: B**

---

**4. Which command initializes a Docker Swarm?**

A. `docker swarm start`
B. `docker swarm init`
C. `docker swarm create`
D. `docker swarm begin`

**Answer: B**

---

**5. What is a "Pod" in Kubernetes?**

A. A single container
B. A group of one or more containers that share resources
C. A deployment strategy
D. A networking component

**Answer: B**

---

**6. Which command deploys a stack in Docker Swarm?**

A. `docker stack deploy`
B. `docker compose up`
C. `docker service create`
D. `docker swarm deploy`

**Answer: A**

---

**7. What is the "pets vs cattle" analogy?**

A. Treating containers like replaceable hardware rather than unique entities
B. Using different animals for testing
C. A Docker networking concept
D. A storage strategy

**Answer: A**

---

**8. Which Kubernetes resource manages external HTTP access?**

A. Service
B. Ingress
C. Deployment
D. Pod

**Answer: B**

---

**9. What does `kubectl scale` do?**

A. Changes the number of replicas
B. Updates the container image
C. Deletes a deployment
D. Shows pod logs

**Answer: A**

---

**10. Which orchestrator is simpler and more tightly integrated with Docker?**

A. Kubernetes
B. Docker Swarm
C. Mesos
D. Nomad

**Answer: B**

---

## Quiz 8.2: True/False

**Instructions:** Mark each statement as True (T) or False (F).

---

**1. Orchestration allows containers to run across multiple hosts.**

**Answer: T**

---

**2. Docker Swarm is more feature-rich than Kubernetes.**

**Answer: F** (Kubernetes is more feature-rich)

---

**3. Rolling updates enable zero-downtime deployments.**

**Answer: T**

---

**4. In Kubernetes, a Service provides stable access to pods.**

**Answer: T**

---

**5. Docker Swarm and Kubernetes can run on the same cluster.**

**Answer: T** (They can, but not recommended to run both on same nodes)

---

**6. The `docker stack` command is used for Swarm deployments.**

**Answer: T**

---

**7. In cattle vs pets, containers are treated like cattle.**

**Answer: T**

---

**8. Kubernetes is the only container orchestrator.**

**Answer: F** (Swarm, Mesos, Nomad are also available)

---

**9. Self-healing means containers can heal themselves without restart.**

**Answer: F** (It means containers are restarted automatically when they fail)

---

**10. Multi-host networking is a feature of orchestration.**

**Answer: T**

---

## Quiz 8.3: Fill in the Blank

**Instructions:** Fill in the missing word or phrase.

---

**1. The command to initialize a Swarm is `docker swarm __________`.**

**Answer: init**

---

**2. The smallest deployable unit in Kubernetes is a __________.**

**Answer: pod**

---

**3. __________ provides stable access to pods in Kubernetes.**

**Answer: Service**

---

**4. __________ is the orchestration platform built into Docker.**

**Answer: Swarm**

---

**5. __________ deployments update services without downtime.**

**Answer: Rolling**

---

**6. The analogy of __________ vs __________ applies to container management.**

**Answer: pets vs cattle**

---

**7. Kubernetes __________ manages external HTTP/HTTPS routing.**

**Answer: Ingress**

---

**8. The command to join a Swarm is `docker swarm __________`.**

**Answer: join**

---

**9. __________ can auto-restart failed containers in orchestration.**

**Answer: Self-healing**

---

**10. A __________ is a group of related services in Swarm mode.**

**Answer: stack**

---

## Quiz 8.4: Short Answer

**Instructions:** Write brief answers to the following questions.

---

**1. Explain the "pets vs cattle" analogy in the context of containers.**

**Answer:** In traditional IT, servers were treated like "pets" – given names, nurtured when sick, and replaced only when beyond help. In container orchestration, containers are treated like "cattle" – they're numbered, replaced when sick, and losing one is not a big deal because the system self-heals. This shift enables automation, scaling, and reliability.

---

**2. What are the key features of container orchestration?**

**Answer:**
- Scaling: Increase or decrease number of container instances
- Self-healing: Automatic restart of failed containers
- Rolling updates: Zero-downtime deployments
- Service discovery: Automatic registration and discovery of services
- Load balancing: Distribute traffic across instances
- Resource management: Efficient use of infrastructure

---

**3. Compare Docker Swarm and Kubernetes.**

**Answer:**

| Aspect | Docker Swarm | Kubernetes |
|--------|--------------|------------|
| Complexity | Low | High |
| Learning Curve | Easy | Steep |
| Features | Basic | Extensive |
| Community | Small | Huge |
| Cloud Support | Limited | All major |
| Use Case | Small teams, simple apps | Enterprise, complex apps |

---

---

# FINAL EXAM

## Comprehensive Exam

**Instructions:** Answer all questions. Time: 2 hours. Passing score: 70%.

---

### Section A: Multiple Choice (30 questions, 1 point each)

---

**1. What is the primary purpose of containerization?**

A. To virtualize hardware
B. To package applications with their dependencies
C. To replace operating systems
D. To increase hardware utilization

**Answer: B**

---

**2. Which command starts a container in detached mode?**

A. `docker run -it nginx`
B. `docker run -d nginx`
C. `docker run --rm nginx`
D. `docker start nginx`

**Answer: B**

---

**3. What is the difference between CMD and ENTRYPOINT?**

A. CMD can be overridden, ENTRYPOINT cannot
B. ENTRYPOINT can be overridden, CMD cannot
C. They are the same thing
D. CMD is for development only

**Answer: A**

---

**4. Which storage option persists data outside the container lifecycle?**

A. tmpfs
B. Anonymous volume
C. Named volume
D. Both B and C

**Answer: D**

---

**5. What is the purpose of the `depends_on` directive in Compose?**

A. To specify which services are dependent on each other
B. To link containers together
C. To share volumes between services
D. To specify resource limits

**Answer: A**

---

**6. Why should containers run as non-root users in production?**

A. To improve performance
B. To reduce the impact of security vulnerabilities
C. To enable volume mounts
D. To allow port binding below 1024

**Answer: B**

---

**7. Which command shows real-time resource usage of containers?**

A. `docker inspect`
B. `docker top`
C. `docker stats`
D. `docker ps`

**Answer: C**

---

**8. What is image signing used for?**

A. To verify image authenticity and integrity
B. To encrypt image contents
C. To compress images
D. To speed up image pulls

**Answer: A**

---

**9. What is a Pod in Kubernetes?**

A. A single container
B. A group of one or more containers that share resources
C. A deployment strategy
D. A networking component

**Answer: B**

---

**10. Which Linux feature provides isolation of process IDs for containers?**

A. Cgroups
B. Namespaces
C. UnionFS
D. Systemd

**Answer: B**

---

**11. Which command shows all containers including stopped ones?**

A. `docker ps`
B. `docker ps -a`
C. `docker containers`
D. `docker list`

**Answer: B**

---

**12. What is the role of containerd in the Docker architecture?**

A. It's the command-line client
B. It manages container lifecycle
C. It creates namespaces and cgroups
D. It builds images

**Answer: B**

---

**13. Why should you order Dockerfile instructions from least-changing to most-changing?**

A. To improve image security
B. To optimize layer caching
C. To reduce image size
D. To improve readability

**Answer: B**

---

**14. Which network driver provides DNS resolution between containers on the same network?**

A. Default bridge
B. Host
C. User-defined bridge
D. None

**Answer: C**

---

**15. What is an SBOM?**

A. Software Build Optimization Manager
B. Software Bill of Materials
C. Secure Build Orchestration Module
D. System Binary Object Model

**Answer: B**

---

**16. Which command initializes a Docker Swarm?**

A. `docker swarm start`
B. `docker swarm init`
C. `docker swarm create`
D. `docker swarm begin`

**Answer: B**

---

**17. What is the purpose of a health check in a container?**

A. To monitor host system health
B. To verify the container is working properly
C. To check image integrity
D. To measure resource usage

**Answer: B**

---

**18. Which tool is used for image signing in the Sigstore ecosystem?**

A. Trivy
B. Cosign
C. Grype
D. Syft

**Answer: B**

---

**19. What does the `-p 8080:80` flag in `docker run` do?**

A. Publishes port 80 on the container to port 8080 on the host
B. Publishes port 8080 on the container to port 80 on the host
C. Sets the container's PID to 8080
D. Sets the container's priority to 80

**Answer: A**

---

**20. Which Linux feature limits resource usage for containers?**

A. Namespaces
B. Cgroups
C. SELinux
D. AppArmor

**Answer: B**

---

**21. What is the purpose of a `.dockerignore` file?**

A. To ignore Docker commands
B. To exclude files from the build context
C. To ignore containers during pruning
D. To disable Docker daemon features

**Answer: B**

---

**22. Which base image is typically the smallest?**

A. Ubuntu
B. Debian
C. Alpine
D. CentOS

**Answer: C**

---

**23. What is the "pets vs cattle" analogy?**

A. Treating containers like replaceable hardware rather than unique entities
B. Using different animals for testing
C. A Docker networking concept
D. A storage strategy

**Answer: A**

---

**24. Which command stops and removes all containers, networks, and volumes defined in a Compose file?**

A. `docker compose down`
B. `docker compose stop`
C. `docker compose rm`
D. `docker compose cleanup`

**Answer: A**

---

**25. What is the difference between a volume and a bind mount?**

A. Volumes are managed by Docker, bind mounts are managed by the user
B. Bind mounts are managed by Docker, volumes are managed by the user
C. They are the same thing
D. Volumes are faster than bind mounts

**Answer: A**

---

**26. Which flag in `docker run` sets a memory limit?**

A. `--memory`
B. `--mem`
C. `--ram`
D. `--limit-memory`

**Answer: A**

---

**27. What is the purpose of Compose profiles?**

A. To selectively start services
B. To create different versions of the compose file
C. To apply security policies
D. To manage Docker versions

**Answer: A**

---

**28. Which command shows detailed configuration information about a container?**

A. `docker ps`
B. `docker logs`
C. `docker inspect`
D. `docker stats`

**Answer: C**

---

**29. What is the purpose of the `HEALTHCHECK` instruction?**

A. To check if the image is corrupt
B. To verify the container is working properly
C. To check the Docker daemon health
D. To monitor host system health

**Answer: B**

---

**30. Which command is used to scale a service in Kubernetes?**

A. `kubectl scale`
B. `kubectl resize`
C. `kubectl update`
D. `kubectl modify`

**Answer: A**

---

### Section B: True/False (20 questions, 1 point each)

---

**1. Containers run faster than virtual machines because they don't have a full OS.**

**Answer: T**

---

**2. A Docker image is a running instance of a container.**

**Answer: F**

---

**3. The Docker daemon is also known as `dockerd`.**

**Answer: T**

---

**4. Docker containers are persistent by default and never lose data.**

**Answer: F**

---

**5. The `docker stop` command sends SIGKILL to the container.**

**Answer: F**

---

**6. The `COPY` instruction can download files from URLs.**

**Answer: F**

---

**7. Multi-stage builds make images smaller and more secure.**

**Answer: T**

---

**8. Data written to a container's writable layer persists after container removal.**

**Answer: F**

---

**9. Containers on a user-defined bridge network can resolve each other by container name.**

**Answer: T**

---

**10. The `read_only` filesystem prevents all writes, including to volumes.**

**Answer: F**

---

**11. Health checks should be used in production but not in development.**

**Answer: F**

---

**12. Secrets should never be committed to version control.**

**Answer: T**

---

**13. Image signing ensures images have not been tampered with.**

**Answer: T**

---

**14. `latest` is a reliable tag for production images.**

**Answer: F**

---

**15. Orchestration allows containers to run across multiple hosts.**

**Answer: T**

---

**16. Docker Swarm is more feature-rich than Kubernetes.**

**Answer: F**

---

**17. The `docker exec` command can only run commands in running containers.**

**Answer: T**

---

**18. The `docker cp` command works on stopped containers.**

**Answer: T**

---

**19. Container orchestration eliminates the need for monitoring.**

**Answer: F**

---

**20. Vulnernability scanning should be integrated into CI/CD pipelines.**

**Answer: T**

---

### Section C: Fill in the Blank (20 questions, 1 point each)

---

**1. The command to run a container with an interactive terminal is `docker run ____`.**

**Answer: -it**

---

**2. __________ provide isolated views of system resources for containers.**

**Answer: Namespaces**

---

**3. The command to view logs with real-time following is `docker logs ____`.**

**Answer: -f**

---

**4. The __________ instruction in Dockerfile sets the base image.**

**Answer: FROM**

---

**5. A __________ is a Dockerfile with multiple `FROM` statements.**

**Answer: multi-stage build**

---

**6. The command to create a named volume is `docker volume __________`.**

**Answer: create**

---

**7. The __________ network driver provides no network isolation.**

**Answer: host**

---

**8. The top-level sections of a Compose file are `services:`, `volumes:`, and `__________`.**

**Answer: networks**

---

**9. The __________ directive in Compose defines resource limits.**

**Answer: deploy**

---

**10. __________ limits prevent noisy neighbor problems.**

**Answer: Resource**

---

**11. The __________ command provides detailed configuration of a container.**

**Answer: inspect**

---

**12. Exit code __________ indicates the container was killed by the OOM killer.**

**Answer: 137**

---

**13. The __________ command signs container images.**

**Answer: cosign sign**

---

**14. __________ stands for Software Bill of Materials.**

**Answer: SBOM**

---

**15. The smallest deployable unit in Kubernetes is a __________.**

**Answer: pod**

---

**16. The command to initialize a Swarm is `docker swarm __________`.**

**Answer: init**

---

**17. __________ provides stable access to pods in Kubernetes.**

**Answer: Service**

---

**18. Docker Secrets are mounted at __________.**

**Answer: /run/secrets/**

---

**19. The __________ flag makes the container's filesystem read-only.**

**Answer: --read-only**

---

**20. The __________ command shows changes to a container's filesystem.**

**Answer: diff**

---

### Section D: Short Answer (10 questions, 3 points each)

---

**1. Explain the difference between an image and a container.**

**Answer:** An image is a read-only template containing the application code, dependencies, and configuration. A container is a running instance of an image with a writable layer added for runtime changes. Multiple containers can run from the same image.

---

**2. What is the "pets vs cattle" analogy and why is it important?**

**Answer:** In traditional IT, servers are treated like "pets" – given names, nurtured, and replaced only when beyond help. In container orchestration, containers are treated like "cattle" – they're numbered, replaced when sick, and losing one is not a big deal because the system self-heals. This enables automation, scaling, and reliability.

---

**3. List five security best practices for production containers.**

**Answer:**
1. Run as non-root user
2. Use read-only filesystem
3. Drop unnecessary capabilities
4. Use seccomp profiles
5. Scan images for vulnerabilities
6. No secrets in images
7. Use minimal base images

---

**4. Describe how to implement health checks in a container.**

**Answer:** Health checks can be defined in Dockerfile using `HEALTHCHECK` or in compose using `healthcheck`. They verify the container is working by running a command (e.g., HTTP check, TCP check, custom script). Configuration includes interval, timeout, retries, and start period.

---

**5. What is Docker Compose and why is it useful?**

**Answer:** Docker Compose is a tool for defining and running multi-container Docker applications using a YAML configuration file. It replaces long `docker run` commands with declarative configuration, ensures consistent environments, and makes it easy to manage complex multi-service applications.

---

**6. Explain the concept of multi-stage builds.**

**Answer:** Multi-stage builds use multiple `FROM` statements to separate build and runtime environments. Each stage builds on the previous one, but only the final stage is included in the final image. Benefits include smaller images, improved security, and cleaner Dockerfiles.

---

**7. What are the three storage options in Docker and when would you use each?**

**Answer:**
- **Volumes:** Production data persistence, managed by Docker
- **Bind Mounts:** Development, mounting source code for hot reload
- **tmpfs:** Temporary in-memory storage for caches and secrets

---

**8. Describe a secure CI/CD pipeline for containers.**

**Answer:**
1. Build image
2. Run tests
3. Generate SBOM
4. Scan for vulnerabilities (Trivy/Grype)
5. Sign image (Cosign)
6. Push to registry
7. Deploy with verification
8. Monitor and alert

---

**9. Compare Docker Swarm and Kubernetes.**

**Answer:**

| Aspect | Docker Swarm | Kubernetes |
|--------|--------------|------------|
| Complexity | Low | High |
| Learning Curve | Easy | Steep |
| Features | Basic | Extensive |
| Community | Small | Huge |
| Cloud Support | Limited | All major |

---

**10. What is your systematic approach to debugging a failing container?**

**Answer:**
1. Check if running: `docker ps -a`
2. View logs: `docker logs container`
3. Inspect config: `docker inspect container`
4. Enter container: `docker exec -it container bash`
5. Check processes: `docker top container`
6. Check resources: `docker stats container`
7. Check file changes: `docker diff container`
8. Monitor events: `docker events`

---

### Section E: Practical Exercises (5 exercises, 6 points each)

---

**Exercise 1: Dockerfile Creation**

Write a multi-stage Dockerfile for a Node.js application that:
- Uses a Node 18 Alpine base image
- Installs dependencies in the builder stage
- Copies the built application to the runtime stage
- Runs as a non-root user
- Has a health check

**Answer:**
```dockerfile
# Builder stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM node:18-alpine
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup package*.json ./

USER appuser

HEALTHCHECK --interval=30s --timeout=3s \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

---

**Exercise 2: Compose File**

Write a docker-compose.yml for:
- A web service using nginx:alpine on port 8080
- A backend service using Python with Flask on port 5000
- A PostgreSQL database with persistent storage
- Proper dependencies and health checks

**Answer:**
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
      - app-net
    depends_on:
      backend:
        condition: service_healthy

  backend:
    build: ./backend
    environment:
      - DB_HOST=postgres
    ports:
      - "5000:5000"
    networks:
      - app-net
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
    restart: unless-stopped

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - pg-data:/var/lib/postgresql/data
    networks:
      - app-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  pg-data:

networks:
  app-net:
```

---

**Exercise 3: Security Hardening**

Given this insecure Dockerfile:
```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3
COPY . /app
CMD ["python3", "/app/app.py"]
```

Write a secure version.

**Answer:**
```dockerfile
FROM python:3.11-slim

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app

# Install dependencies first (cache optimization)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

EXPOSE 5000
CMD ["python", "app.py"]
```

---

**Exercise 4: Debugging**

You have a container named `web` that exits immediately with exit code 1.

List the commands you would use to debug this issue, in order.

**Answer:**
```bash
# 1. Check if container exists
docker ps -a | grep web

# 2. Check exit code
docker inspect web --format='{{.State.ExitCode}}'

# 3. View logs
docker logs web --tail 50

# 4. Inspect configuration
docker inspect web

# 5. Try interactive run
docker run --rm -it web_image /bin/bash

# 6. Check environment variables
docker inspect web --format='{{.Config.Env}}'

# 7. Check mounted volumes
docker inspect web --format='{{.Mounts}}'
```

---

**Exercise 5: CI/CD Pipeline**

Write a GitHub Actions workflow that:
- Builds a Docker image
- Scans it with Trivy
- Pushes to GHCR
- Deploys to a server

**Answer:**
```yaml
name: Build, Scan, and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to GHCR
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ghcr.io/${{ github.repository }}:${{ github.sha }}
          severity: 'HIGH,CRITICAL'
      
      - name: Deploy
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USER }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            docker pull ghcr.io/${{ github.repository }}:${{ github.sha }}
            docker compose up -d
```

---

# ANSWER KEY SUMMARY

## Part 1 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 1.1 Multiple Choice | 10 | 7 |
| 1.2 True/False | 10 | 7 |
| 1.3 Fill in the Blank | 10 | 7 |
| 1.4 Short Answer | 5 | 3 |
| 1.5 Scenario-Based | 5 | 3 |

## Part 2 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 2.1 Multiple Choice | 10 | 7 |
| 2.2 True/False | 10 | 7 |
| 2.3 Fill in the Blank | 10 | 7 |
| 2.4 Short Answer | 5 | 3 |
| 2.5 Scenario-Based | 3 | 2 |

## Part 3 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 3.1 Multiple Choice | 10 | 7 |
| 3.2 True/False | 10 | 7 |
| 3.3 Fill in the Blank | 10 | 7 |
| 3.4 Short Answer | 5 | 3 |
| 3.5 Scenario-Based | 3 | 2 |

## Part 4 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 4.1 Multiple Choice | 10 | 7 |
| 4.2 True/False | 10 | 7 |
| 4.3 Fill in the Blank | 10 | 7 |
| 4.4 Short Answer | 4 | 2 |
| 4.5 Scenario-Based | 2 | 1 |

## Part 5 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 5.1 Multiple Choice | 10 | 7 |
| 5.2 True/False | 10 | 7 |
| 5.3 Fill in the Blank | 10 | 7 |
| 5.4 Short Answer | 4 | 2 |
| 5.5 Scenario-Based | 2 | 1 |

## Part 6 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 6.1 Multiple Choice | 10 | 7 |
| 6.2 True/False | 10 | 7 |
| 6.3 Fill in the Blank | 10 | 7 |
| 6.4 Short Answer | 3 | 2 |

## Part 7 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 7.1 Multiple Choice | 10 | 7 |
| 7.2 True/False | 10 | 7 |
| 7.3 Fill in the Blank | 10 | 7 |
| 7.4 Short Answer | 3 | 2 |
| 7.5 Scenario-Based | 1 | 1 |

## Part 8 Quizzes

| Quiz | Total | Passing Score |
|------|-------|---------------|
| 8.1 Multiple Choice | 10 | 7 |
| 8.2 True/False | 10 | 7 |
| 8.3 Fill in the Blank | 10 | 7 |
| 8.4 Short Answer | 3 | 2 |

## Final Exam

| Section | Questions | Points per Question | Total Points |
|---------|-----------|---------------------|--------------|
| A: Multiple Choice | 30 | 1 | 30 |
| B: True/False | 20 | 1 | 20 |
| C: Fill in the Blank | 20 | 1 | 20 |
| D: Short Answer | 10 | 3 | 30 |
| E: Practical | 5 | 6 | 30 |
| **Total** | **85** | | **130** |

**Passing Score: 91 points (70%)**

---

**End of Quiz and Test Bank**
