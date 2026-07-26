# Appendix E – Complete Docker Glossary of Terms

This comprehensive glossary defines all the key terms, concepts, and acronyms used throughout the Docker Mastery series. Use this as your reference when you encounter unfamiliar terminology.

## E.1 Core Docker Concepts

### Container
A lightweight, standalone, executable package that includes everything needed to run a piece of software: code, runtime, system tools, system libraries, and settings. Containers share the host OS kernel but run as isolated processes in user space.

**Analogy:** A shipping container that contains everything needed to transport goods—standardized, portable, and isolated from other containers on the same ship.

### Image
A read-only template containing instructions for creating a container. Images are built from Dockerfiles and consist of multiple layers. You can run multiple containers from the same image.

**Analogy:** A blueprint or recipe that defines how to create a container.

### Dockerfile
A text file that contains all the commands needed to build a Docker image. Each instruction in a Dockerfile creates a new layer in the image.

### Registry
A server that stores and distributes Docker images. Examples include Docker Hub, GitHub Container Registry (GHCR), and Amazon ECR.

**Analogy:** A library or repository where images are stored and can be downloaded.

### Docker Hub
The default public registry for Docker images. Hosts official images from software vendors and community-contributed images.

### Layer
Each instruction in a Dockerfile creates a layer. Layers are stacked on top of each other to form the final image. Layers are cached and reused between builds, making Docker efficient.

**Analogy:** Layers are like the pages of a book—each page adds content on top of the previous ones.

### Union Filesystem
A filesystem that allows files and directories to be overlaid on top of each other. Docker uses union filesystems (like OverlayFS) to create efficient, layered images.

### Container Runtime
The software that actually runs containers. Docker uses containerd and runc. Other runtimes include CRI-O and Podman.

### Docker Daemon (dockerd)
The background service that manages Docker containers, images, networks, and volumes. It listens for Docker API requests and handles container lifecycle.

**Analogy:** The engine room of a ship—it runs everything behind the scenes.

### Docker Client (docker)
The command-line tool that users interact with to send commands to the Docker daemon.

## E.2 Container Lifecycle Terms

### Container Lifecycle
The states a container goes through: Created → Running → Paused → Exited → Removed.

### Detached Mode (-d)
Running a container in the background. The container starts but doesn't attach to your terminal.

### Interactive Mode (-it)
Running a container with an interactive terminal attached. Used for debugging, shell access, or interactive applications.

### Restart Policy
Defines what happens when a container exits. Options: `no`, `always`, `on-failure`, `unless-stopped`.

### Health Check
A command or test that Docker runs periodically to verify a container is working properly. If the check fails, the container is marked as "unhealthy."

### Graceful Shutdown
Allowing a container to clean up resources before exiting. Docker sends SIGTERM, waits for the container to exit, then sends SIGKILL if it doesn't.

## E.3 Networking Terms

### Bridge Network
The default network driver in Docker. Creates a virtual network on the host that containers can connect to. Containers on the same bridge network can communicate.

### User-Defined Bridge Network
A custom bridge network created by the user. Provides DNS resolution between containers and better isolation than the default bridge.

### Host Network
A network mode where the container uses the host's network stack directly. No network isolation, but better performance.

### None Network
A network mode where the container has its own network namespace but no network interfaces. Completely isolated from the network.

### Overlay Network
A network driver that connects multiple Docker daemons together, used in Swarm mode. Enables containers on different hosts to communicate.

### Macvlan
A network driver that assigns a MAC address to each container, making them appear as physical devices on the network.

### DNS Resolution
The ability to convert service names to IP addresses. In user-defined networks, containers can reach each other by name.

### Service Discovery
The automatic detection of services on a network. In Docker, this is provided by DNS resolution on user-defined networks.

### Port Mapping
Publishing a container's port to the host. Traffic to the host port is forwarded to the container port.

### IPAM (IP Address Management)
The component that manages IP address assignment for Docker networks.

## E.4 Storage Terms

### Volume
A Docker-managed storage mechanism for persisting data. Volumes exist independently of containers and can be shared between containers.

**Analogy:** A portable hard drive that can be plugged into different computers.

### Bind Mount
Mounting a host directory directly into a container. The container sees the host's filesystem. Used primarily for development.

**Analogy:** Opening a shared folder that both your computer and the container can access.

### tmpfs Mount
An in-memory filesystem that exists only in the container's memory. Data is lost when the container stops.

**Analogy:** RAM disk—fast but volatile.

### Named Volume
A volume with a user-specified name. Easier to manage and reference than anonymous volumes.

### Anonymous Volume
A volume without a user-specified name. Docker generates a random name. Harder to manage.

### Volume Driver
A plugin that provides advanced volume features like NFS, cloud storage, or encryption.

### Persistent Data
Data that survives container restarts and removal. Achieved through volumes.

### Ephemeral Data
Data that exists only while the container is running. Lost when the container stops or is removed.

## E.5 Dockerfile Terms

### Build Context
The set of files and directories available to the Docker build process. Usually the directory containing the Dockerfile.

### Build Cache
Cached layers from previous builds. Docker reuses these layers if the instructions haven't changed, making builds faster.

### Multi-Stage Build
A technique using multiple `FROM` statements in a Dockerfile. Allows copying artifacts from one stage to another, reducing final image size.

**Analogy:** A construction site where different crews work on different stages, then the final product is assembled.

### Base Image
The starting image for a Dockerfile (specified with `FROM`). Examples: `ubuntu:22.04`, `python:3.11-slim`.

### Scratch Image
An empty image with no base. Used for building minimal containers (like Go static binaries).

### Distroless Image
Images that contain only your application and its runtime dependencies, without package managers, shells, or other OS tools. Smaller and more secure.

### Intermediate Image
An image created during the build process that isn't the final output. Used in multi-stage builds.

### Final Image
The image produced at the end of the Docker build. Contains only what's needed to run the application.

### Build Arguments (ARG)
Variables passed at build time to customize the build. Not persisted in the final image.

### Environment Variables (ENV)
Variables set in the image that persist at runtime. Can be overridden when running the container.

### Entrypoint
The command that runs when the container starts. Can't be overridden (but can receive arguments).

### CMD
Default arguments for the entrypoint or the default command if no entrypoint is set. Can be overridden.

## E.6 Docker Compose Terms

### Compose File (docker-compose.yml)
A YAML file that defines multi-container applications. Describes services, networks, and volumes declaratively.

### Service
A container definition in a Compose file. Can be scaled to multiple replicas.

### Project
A group of services defined in a Compose file. The project name is used for naming containers and networks.

### Profile
A way to selectively start services. Services can be assigned to profiles and only started when the profile is active.

### Extends
A Compose feature for sharing common configuration between services.

### Overrides
A technique for customizing Compose configurations for different environments (development, staging, production).

### Depends On
A Compose declaration that specifies service dependencies. Determines start order.

## E.7 Swarm and Orchestration Terms

### Orchestration
The automated management of multiple containers, including scaling, deployment, health monitoring, and recovery.

**Analogy:** A conductor directing an orchestra—each musician (container) plays their part, and the conductor ensures everything works together.

### Swarm Mode
Docker's built-in orchestration solution. Turns a group of Docker hosts into a cluster.

### Manager Node
A node in a Swarm cluster that controls the cluster, schedules services, and maintains the desired state.

### Worker Node
A node in a Swarm cluster that runs containers (tasks). Receives instructions from manager nodes.

### Task
A running container in a Swarm service. Each task is a single container instance.

### Service (Swarm)
A group of identical tasks (containers) in Swarm mode. Services can be scaled, updated, and rolled back.

### Stack (Swarm)
A group of related services defined in a Compose file and deployed to Swarm mode.

### Service Discovery (Swarm)
Automatic detection and routing of services in Swarm mode. Services are reachable by name.

## E.8 Kubernetes Terms (Overview)

### Pod
The smallest deployable unit in Kubernetes. One or more containers that share network and storage.

### Node
A worker machine in Kubernetes. Can be a physical or virtual machine.

### Cluster
A group of nodes managed by Kubernetes.

### Deployment
A Kubernetes resource that defines the desired state for pods. Handles replicas, updates, and rollbacks.

### Service (Kubernetes)
An abstraction that defines a logical set of pods and a policy to access them. Provides stable networking.

### Ingress
A Kubernetes resource that manages external access to services. Handles HTTP routing and SSL termination.

### ConfigMap
A Kubernetes resource for storing configuration data separate from pod definitions.

### Secret
A Kubernetes resource for storing sensitive data (passwords, tokens, keys).

### PersistentVolume (PV)
A Kubernetes resource that represents storage in the cluster. Abstracted from the underlying storage provider.

### PersistentVolumeClaim (PVC)
A request for storage by a user or pod. Binds to a PersistentVolume.

## E.9 Security Terms

### Non-Root User
Running containers with a user other than root (UID 0). Reduces the impact of security vulnerabilities.

### Capabilities (Linux Capabilities)
Fine-grained permissions that can be granted to processes. Docker can drop or add capabilities.

### Seccomp
A Linux kernel feature for restricting system calls. Used to limit what a container can do.

### AppArmor/SELinux
Linux security modules that provide mandatory access control. Can be used to restrict containers.

### Image Signing
Cryptographically signing images to verify authenticity and integrity. Tools: Cosign, Notary.

### SBOM (Software Bill of Materials)
A list of all components, libraries, and dependencies in an image. Used for security and compliance.

### Vulnerability Scanning
Automatically scanning images for known security vulnerabilities. Tools: Trivy, Grype, Docker Scout.

### Secret Management
Secure storage and access control for sensitive data (passwords, API keys, certificates).

### Zero Trust Security
A security model where no component is trusted by default. Everything must be authenticated and authorized.

## E.10 CI/CD Terms

### CI/CD
Continuous Integration / Continuous Deployment. Automated process for building, testing, and deploying applications.

### GitHub Actions
A CI/CD platform integrated with GitHub. Automates workflows based on repository events.

### Pipeline
A sequence of automated steps in CI/CD. Build → Test → Scan → Deploy.

### Build Runner
A machine that executes CI/CD tasks. Can be hosted (GitHub Actions) or self-hosted.

### Artifact
A file or directory produced by a CI/CD build. Can be stored for later use.

### Registry Push
Uploading a built image to a container registry.

### Rollback
Reverting to a previous version of a deployment. Used when a new version has issues.

### Blue-Green Deployment
A deployment strategy with two identical environments (blue and green). Traffic is switched to the new version after testing.

### Canary Deployment
Rolling out a new version to a small percentage of users first. Monitors for issues before full rollout.

## E.11 Performance Terms

### Layer Caching
Reusing layers from previous builds to speed up subsequent builds.

### Build Cache
Stored layers that can be reused to avoid rebuilding unchanged portions.

### Image Size
The total storage space required by an image. Smaller images are faster to download and more secure.

### Resource Limits
Restrictions on CPU and memory usage for containers. Prevents a container from consuming all host resources.

### Resource Reservations
Guaranteed resources for a container. Ensures a minimum amount of CPU and memory.

### OOM Killer
Out Of Memory Killer. Linux feature that terminates processes when the system runs out of memory.

### Log Rotation
Automatically archiving and removing old log files to prevent disk space exhaustion.

### Hot Reload
Automatically reloading an application when source code changes. Essential for development.

## E.12 Development Terms

### Development Environment
The environment where code is written and tested. Often uses bind mounts and hot reloading.

### Staging Environment
A production-like environment for final testing before deployment.

### Production Environment
The live environment where users access the application.

### Local Development
Running the application on your laptop or workstation.

### Remote Development
Running the application on a remote server or VM.

### Environment Drift
When environments diverge over time due to different configurations, causing issues.

### Reproducible Builds
Builds that produce the same output every time, regardless of the build environment.

## E.13 Quick Reference: Docker CLI Terms

| Term | Meaning |
|------|---------|
| `docker run` | Create and start a container |
| `docker ps` | List containers |
| `docker logs` | Show container logs |
| `docker inspect` | Show detailed container info |
| `docker exec` | Run command in running container |
| `docker build` | Build an image from a Dockerfile |
| `docker pull` | Download an image from a registry |
| `docker push` | Upload an image to a registry |
| `docker compose` | Manage multi-container applications |
| `docker swarm` | Manage Swarm mode |
| `docker stack` | Manage Swarm stacks |

## E.14 Acronyms Cheat Sheet

| Acronym | Full Form |
|---------|-----------|
| API | Application Programming Interface |
| CI | Continuous Integration |
| CD | Continuous Deployment |
| CPU | Central Processing Unit |
| DNS | Domain Name System |
| ECR | Elastic Container Registry (AWS) |
| GHCR | GitHub Container Registry |
| GPU | Graphics Processing Unit |
| HTTP | Hypertext Transfer Protocol |
| IaC | Infrastructure as Code |
| IP | Internet Protocol |
| IPAM | IP Address Management |
| JSON | JavaScript Object Notation |
| K8s | Kubernetes (K + 8 letters + s) |
| OCI | Open Container Initiative |
| OOM | Out Of Memory |
| OS | Operating System |
| PID | Process ID |
| RAM | Random Access Memory |
| SDK | Software Development Kit |
| SBOM | Software Bill of Materials |
| SSL | Secure Sockets Layer |
| TCP | Transmission Control Protocol |
| TLS | Transport Layer Security |
| UID | User ID |
| UUID | Universally Unique Identifier |
| VM | Virtual Machine |
| YAML | YAML Ain't Markup Language |

---

# Series Completion

This concludes the complete **Docker Mastery: Containerize Anything From Zero to Production** series, including all main parts (0-8) and all appendices (A-E).

## Summary of Series Contents

| Section | Title | Focus |
|---------|-------|-------|
| Part 0 | Introduction | Series overview, architecture, expectations |
| Part 1 | Core Foundation | Why containers, namespaces, cgroups, basics |
| Part 2 | Custom Images | Dockerfiles, multi-stage builds, optimization |
| Part 3 | Persistence & Networking | Volumes, bind mounts, networks, service discovery |
| Part 4 | Docker Compose | Multi-container apps, YAML config, environments |
| Part 5 | Production Readiness | Security, resources, logging, CI/CD |
| Part 6 | Debugging & Operations | Troubleshooting, optimization, daily ops |
| Part 7 | Security & Registries | Signing, SBOM, secrets, advanced CI/CD |
| Part 8 | Orchestration | Swarm, Kubernetes, cluster management |
| Appendix A | Command Reference | Complete Docker CLI reference |
| Appendix B | Dockerfile Reference | All Dockerfile instructions and patterns |
| Appendix C | Compose Reference | Complete docker-compose.yml reference |
| Appendix D | Error Solutions | Common errors and troubleshooting |
| Appendix E | Glossary | Complete Docker terminology reference |
