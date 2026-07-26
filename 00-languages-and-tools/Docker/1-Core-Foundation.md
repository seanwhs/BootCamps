# Part 1 – The Core Foundation: Why Containers and How They Run

Welcome to the practical beginning of your Docker journey. In this part, we'll build a rock-solid mental model of what containers actually are, how they work under the hood, and why they're such a powerful tool for software delivery. By the end, you'll have Docker installed and running, and you'll have launched your first containerized application.

## 1.1 The Problem: Environment Drift and Deployment Friction

Before we dive into containers, let's understand the problem they solve with a concrete example.

**Meet Alice**, a developer at a growing startup. Alice has been building a Python web application on her MacBook Pro. She uses Python 3.11, PostgreSQL 15, Redis 7, and a specific set of system libraries. Everything works perfectly on her machine.

**Meet Bob**, the operations engineer responsible for deploying Alice's application to the production servers. Bob's servers run Ubuntu 20.04 LTS. They have Python 3.8 installed by default, PostgreSQL 13, and different system libraries. When Bob runs Alice's code, it crashes. The error messages are cryptic and unrelated to the actual code logic.

**The Cost:** Alice spends two days debugging environment differences, rewriting code to work around system discrepancies, and manually documenting setup procedures that are already outdated. The feature that was supposed to ship on Monday ships on Thursday.

**Meet Docker.** Docker solves this problem by creating consistent, isolated environments that work the same everywhere. Instead of saying "It works on my machine," you say "It works in my container" – and that container runs identically on any machine with Docker installed.

## 1.2 The Solution: Virtual Machines vs. Containers

To understand containers, it helps to compare them with alternatives.

### The Bare Metal Era

In the beginning, every application ran directly on the operating system. This was simple but problematic. Different applications might require different versions of the same library (e.g., two apps needing different versions of Python). Conflicts were common, and isolating applications was difficult.

```
┌─────────────────────────────────────┐
│         Application A               │
├─────────────────────────────────────┤
│         Application B               │
├─────────────────────────────────────┤
│    Operating System (Linux)         │
├─────────────────────────────────────┤
│    Hardware (CPU, Memory, Disk)     │
└─────────────────────────────────────┘
```
**Problem:** Applications share the same OS, leading to dependency conflicts.

### The Virtual Machine Era

Virtual machines (VMs) solved the isolation problem by running a complete operating system (called a guest OS) on top of a hypervisor, which sits between the hardware and the VM. Each VM has its own kernel, system libraries, and dependencies.

```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   App A     │  │   App B     │  │   App C     │       │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤       │
│  │ Guest OS    │  │ Guest OS    │  │ Guest OS    │       │
│  │ (Linux)     │  │ (Windows)   │  │ (Linux)     │       │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤       │
│  │ Hypervisor  │  │ Hypervisor  │  │ Hypervisor  │       │
│  └─────────────┘  └─────────────┘  └─────────────┘       │
│                    Hardware (Host)                         │
└─────────────────────────────────────────────────────────────┘
```

**Pros:** Strong isolation, can run different OSes.
**Cons:** Heavy overhead (each VM has a full OS), slow boot times (minutes), resource-intensive (GBs of RAM per VM).

### The Container Era

Containers take a different approach. They share the host operating system's kernel but isolate processes at the user space level. Each container runs as an isolated process with its own filesystem, network, and process space.

```
┌─────────────────────────────────────────────────────────────┐
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │   App A     │  │   App B     │  │   App C     │       │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤       │
│  │  Libraries  │  │  Libraries  │  │  Libraries  │       │
│  ├─────────────┤  ├─────────────┤  ├─────────────┤       │
│  │     Container Engine (Docker)                        │       │
│  ├─────────────────────────────────────────────────────┤       │
│  │           Host Operating System (Linux)             │       │
│  ├─────────────────────────────────────────────────────┤       │
│  │              Hardware (Host)                        │       │
│  └─────────────────────────────────────────────────────┘       │
```

**Pros:** Lightweight (MBs of RAM), fast boot (milliseconds to seconds), efficient (many containers per host).
**Cons:** Shared kernel (all containers must run the same OS type).

**The Key Difference:** VMs virtualize hardware, containers virtualize the operating system. Containers don't run a full OS – they run just the application and its dependencies, sharing the host kernel.

## 1.3 How Containers Actually Work: Namespaces and Cgroups

Containers aren't magic. They're built on two fundamental Linux kernel features: **namespaces** and **cgroups**. Understanding these gives you superpowers – you'll know exactly what Docker is doing under the hood.

### Namespaces: Isolation of Resources

Namespaces are a Linux feature that allows a process to have its own isolated view of system resources. Think of them like giving each container its own "bubble" of reality.

**The Seven Linux Namespaces (as of Linux 4.10+):**

| Namespace | What It Isolates | Why It Matters |
|-----------|------------------|----------------|
| **PID** | Process IDs | Each container sees its own process tree starting from PID 1 |
| **NET** | Network interfaces, routing tables | Containers get their own network stack and IP address |
| **IPC** | Inter-process communication (shared memory, semaphores) | Prevents processes from different containers communicating directly |
| **MNT** | Filesystem mount points | Each container has its own filesystem view |
| **UTS** | Hostname and domain name | Containers can have their own hostname |
| **USER** | User and group IDs | Map container UIDs to different host UIDs for security |
| **CGROUP** | Control group information | Kernel version 4.6+ adds this for better cgroup management |

Let's see namespaces in action. Run this command to launch a container and see its isolated hostname:

```bash
docker run --rm ubuntu:22.04 hostname
```
```
# Output:
0b42e67d8f34
```

Each container gets a unique hostname. Now let's set it explicitly:

```bash
docker run --rm --hostname my-app ubuntu:22.04 hostname
```
```
# Output:
my-app
```

**What's happening:** Docker creates a new UTS namespace for this container, giving it an isolated hostname that doesn't affect the host machine.

### Cgroups: Resource Limiting

**Cgroups** (Control Groups) limit, account for, and isolate resource usage (CPU, memory, disk I/O, network) for a group of processes. While namespaces give containers their own view of resources, cgroups ensure they don't consume more than their fair share.

```
┌──────────────────────────────────────────────────────┐
│                   Host System                        │
│  ┌────────────────────────────────────────────┐     │
│  │  Container A  │  Container B  │  Container C│     │
│  │  CPU: 25%     │  CPU: 25%     │  CPU: 25%  │     │
│  │  Memory: 1GB  │  Memory: 2GB  │  Memory:   │     │
│  │               │               │   512MB    │     │
│  └────────────────────────────────────────────┘     │
│              Cgroups Enforce Limits                  │
└──────────────────────────────────────────────────────┘
```

**Example:** Limit a container to 50% of a single CPU core:

```bash
docker run --rm --cpus=0.5 ubuntu:22.04 stress --cpu 1 --timeout 10
```

### The Docker Architecture

Now that you understand the underlying technologies, let's see how Docker orchestrates them:

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Client                         │
│  ┌────────────────────────────────────────────────────┐    │
│  │  docker run, docker build, docker pull, etc.       │    │
│  └────────────────────┬───────────────────────────────┘    │
│                       │ REST API                           │
│                       ▼                                    │
│                   Docker Daemon (dockerd)                  │
│  ┌────────────────────────────────────────────────────┐    │
│  │  - Manages containers, images, networks, volumes   │    │
│  │  - Listens for Docker API requests                 │    │
│  │  - Uses containerd for container lifecycle        │    │
│  └────────────────────────────────────────────────────┘    │
│                       │                                    │
│                       ▼                                    │
│                 containerd (Runtime)                       │
│  ┌────────────────────────────────────────────────────┐    │
│  │  - Pulls images, manages container lifecycle       │    │
│  │  - Uses runc for actual container execution       │    │
│  └────────────────────────────────────────────────────┘    │
│                       │                                    │
│                       ▼                                    │
│                  runc (Low-level)                          │
│  ┌────────────────────────────────────────────────────┐    │
│  │  - Creates namespaces and cgroups                  │    │
│  │  - Executes the container process                  │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

**The Stack Explained:**
- **Docker Client** (`docker`): Your command-line tool. Sends commands to the daemon.
- **Docker Daemon** (`dockerd`): The brain that manages Docker objects.
- **containerd**: The industry-standard container runtime, manages container lifecycle.
- **runc**: The low-level OCI (Open Container Initiative) runtime, creates the actual container.

## 1.4 Installing Docker

Before we can run containers, we need to install Docker. The installation process varies by operating system, but Docker has made it increasingly straightforward.

### Installation on macOS

1. Download Docker Desktop for Mac from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Double-click the downloaded `.dmg` file and drag the Docker icon to your Applications folder
3. Open Docker from Applications
4. The first time, you'll see a prompt to authorize Docker with your system password
5. Wait for the Docker whale icon to appear in the status bar (top of screen). When it's steady without animation, Docker is running

**Verify installation:**
```bash
docker --version
```
```
# Expected output (version may vary):
Docker version 24.0.7, build afdd53b
```

```bash
docker run hello-world
```
```
# Expected output:
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

### Installation on Windows

1. Download Docker Desktop for Windows from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Double-click the installer and follow the prompts
3. Windows will prompt you to enable WSL 2 or Hyper-V. WSL 2 is recommended:
   - You'll need Windows 10 version 2004 or higher, or Windows 11
   - Enable WSL 2 during installation
4. After installation, restart your computer
5. Launch Docker Desktop from the Start menu

**Verify installation:**
```bash
docker --version
```
```
# Expected output:
Docker version 24.0.7, build afdd53b
```

### Installation on Linux (Ubuntu/Debian)

```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add the Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update again with Docker repo
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to the docker group (so you don't need sudo for docker commands)
sudo usermod -aG docker $USER

# Important: You need to log out and log back in for group changes to take effect
# Or use: newgrp docker

# Verify installation
docker --version
```
```
# Expected output:
Docker version 24.0.7, build afdd53b
```

## 1.5 Understanding Images, Containers, and Layers

Before we run our first container, let's build a mental model of the relationship between images and containers.

### Images: The Blueprint

A **Docker image** is a read-only template containing instructions for creating a container. Think of it like a blueprint or a recipe. It contains:
- A base operating system (or minimal runtime)
- Application code
- Dependencies (libraries, binaries)
- Environment variables
- Configuration files

Images are built in layers, with each instruction in a Dockerfile creating a new layer.

```
Image Layers (read-only):
┌─────────────────────────────┐
│ Layer 6: CMD ["python",...] │
├─────────────────────────────┤
│ Layer 5: COPY . /app        │
├─────────────────────────────┤
│ Layer 4: RUN pip install... │
├─────────────────────────────┤
│ Layer 3: COPY requirements  │
├─────────────────────────────┤
│ Layer 2: WORKDIR /app       │
├─────────────────────────────┤
│ Layer 1: FROM python:3.11   │
└─────────────────────────────┘
```

### Containers: The Running Instance

A **container** is a running instance of an image. When you run an image, Docker adds a writable layer on top of the image's read-only layers:

```
┌─────────────────────────────┐
│ Container (writable layer)  │ ← Runtime changes go here
├─────────────────────────────┤
│ Layer 6: CMD ["python",...] │
├─────────────────────────────┤
│ Layer 5: COPY . /app        │
├─────────────────────────────┤
│ Layer 4: RUN pip install... │
├─────────────────────────────┤
│ Layer 3: COPY requirements  │
├─────────────────────────────┤
│ Layer 2: WORKDIR /app       │
├─────────────────────────────┤
│ Layer 1: FROM python:3.11   │
└─────────────────────────────┘
```

**The key insight:** Multiple containers can run from the same image, each with its own writable layer and independent state. This is how Docker achieves efficiency – sharing layers between containers saves disk space and memory.

### Inspecting Images

Let's see what images you already have:

```bash
docker images
```
```
# Example output:
REPOSITORY    TAG       IMAGE ID       CREATED       SIZE
hello-world   latest    feb5d9fea6a5   3 weeks ago   13.3kB
```

Now let's pull a more substantial image:

```bash
docker pull ubuntu:22.04
```
```
# Output shows layer pulling:
22.04: Pulling from library/ubuntu
8c328e84ab0f: Pull complete
Digest: sha256:... 
Status: Downloaded newer image for ubuntu:22.04
docker.io/library/ubuntu:22.04
```

Notice the "Pull complete" messages – each line represents a layer being downloaded. Now check the image details:

```bash
docker images ubuntu:22.04
```
```
REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
ubuntu       22.04     d6a18f6e2bf1   3 weeks ago   77.8MB
```

Now inspect the image's layers:

```bash
docker history ubuntu:22.04
```
```
# Output shows each layer and its size:
IMAGE          CREATED       CREATED BY                                      SIZE
d6a18f6e2bf1   3 weeks ago   /bin/sh -c #(nop)  CMD ["/bin/bash"]           0B
<missing>      3 weeks ago   /bin/sh -c #(nop)  LABEL org.opencontainers…   0B
<missing>      3 weeks ago   /bin/sh -c #(nop) ADD file:... in /            77.8MB
```

### The Containers and Images Relationship: A Simple Analogy

**Think of it like a cake:**
- The **Dockerfile** is the recipe
- The **Docker image** is the pre-baked cake
- The **Docker container** is a slice of that cake
- Each slice (container) is separate but comes from the same cake (image)
- You can share multiple slices from the same cake (run multiple containers from one image)

## 1.6 Running Your First Container

Now for the moment you've been waiting for – running a real container!

### The `docker run` Command

The `docker run` command is the Swiss Army knife of Docker. Here's its basic structure:

```bash
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

Let's start with the simplest possible container:

```bash
docker run hello-world
```

You should see the welcome message with ASCII art. This container:
1. Downloads the `hello-world` image if you don't have it
2. Creates a container from that image
3. Runs the container's default command
4. Prints the output
5. Exits (since the process completed)

### Running an Interactive Container

Now let's run a container that stays alive and allows interaction:

```bash
docker run -it ubuntu:22.04 bash
```

**Flags explained:**
- `-i` (or `--interactive`): Keep STDIN open
- `-t` (or `--tty`): Allocate a pseudo-TTY (terminal)

You'll be dropped into a bash shell inside the Ubuntu container. Try these commands inside the container:

```bash
# Inside the container
cat /etc/os-release
```
```
# Output shows Ubuntu 22.04
```

```bash
# Check the hostname (it's the container ID)
hostname
```

```bash
# List processes (only the container's processes are visible)
ps aux
```
```
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   4604  3764 pts/0    Ss   10:15   0:00 bash
root          12  0.0  0.0   7060  3424 pts/0    R+   10:16   0:00 ps aux
```

Notice how you only see two processes – exactly what namespaces provide: process isolation.

**Important:** The container has PID 1 as `bash`. In a normal Linux system, PID 1 is `init` or `systemd`. Here, bash is the first process, and if it exits, the container stops.

### Exiting the Container

To exit the interactive session, type:
```bash
exit
```

After exiting, the container stops. Why? Because the bash process (PID 1) terminated.

### Running a Background Container

Sometimes you want a container to run in the background without interaction:

```bash
docker run -d --name my-nginx nginx:alpine
```

**Flags explained:**
- `-d` (or `--detach`): Run container in background
- `--name my-nginx`: Give the container a name instead of a random ID

Now check if it's running:

```bash
docker ps
```
```
# Output shows running containers:
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS     NAMES
e4f8a9d2b1c3   nginx:alpine   "/docker-entrypoint.…"   2 seconds ago   Up 1 second    80/tcp    my-nginx
```

We'll explore more about `docker ps` in the next section.

## 1.7 Container Lifecycle Management

Now that you can run containers, let's master the lifecycle commands.

### List Containers

View running containers:
```bash
docker ps
```

View all containers (including stopped):
```bash
docker ps -a
```

**Useful `docker ps` options:**
```bash
# Show only container IDs
docker ps -q

# Show latest created container
docker ps -l

# Show sizes
docker ps -s
```

### Start and Stop

Stop a running container:
```bash
docker stop my-nginx
```

Start a stopped container:
```bash
docker start my-nginx
```

Stop and start with different names:
```bash
# Stop gracefully (sends SIGTERM)
docker stop my-nginx

# Force stop (sends SIGKILL)
docker kill my-nginx

# The difference:
# stop allows container to clean up; kill immediately terminates
```

### Pause and Unpause

Suspend all processes in a container:
```bash
docker pause my-nginx
```

Resume:
```bash
docker unpause my-nginx
```

### Remove Containers

Remove a stopped container:
```bash
docker rm my-nginx
```

Remove a running container (force):
```bash
docker rm -f my-nginx
```

Remove all stopped containers:
```bash
docker container prune
```
```
# Confirmation prompt:
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
```

### The Container Lifecycle Diagram

```
                    ┌──────────┐
                    │  Created │
                    └────┬─────┘
                         │ docker start
                         ▼
                    ┌──────────┐
                    │ Running  │◄─────────┐
                    └────┬─────┘          │
                         │ docker stop    │ docker unpause
                         ▼                 │
                    ┌──────────┐    ┌─────────────┐
                    │  Exited  │    │   Paused    │──┘
                    └────┬─────┘    └─────────────┘
                         │ docker rm
                         ▼
                    ┌──────────┐
                    │ Removed  │
                    └──────────┘
```

### Practical Example: Running Nginx

Let's run a web server container and verify it's working:

```bash
# Run Nginx in background, mapping port 80
docker run -d --name web-server -p 8080:80 nginx:alpine
```

Now open your browser to `http://localhost:8080` – you should see the default Nginx welcome page.

**What's happening with `-p 8080:80`:**
- Maps port 8080 on your host to port 80 inside the container
- Traffic to `localhost:8080` is forwarded to container port 80

Check the container's logs:
```bash
docker logs web-server
```
```
# Output shows Nginx startup:
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
...
```

View continuous logs (like `tail -f`):
```bash
docker logs -f web-server
```
Press `Ctrl+C` to stop following logs.

Stop and remove the container:
```bash
docker stop web-server
docker rm web-server
```

### Experiment: Interactive Web Server

Let's combine everything we've learned:

```bash
# Run Nginx interactively
docker run -it --rm -p 8080:80 nginx:alpine sh
```

Now we're inside the container's shell. Let's modify the default page:

```bash
# Inside the container
echo "<h1>Hello from my container!</h1>" > /usr/share/nginx/html/index.html

# Check it's there
cat /usr/share/nginx/html/index.html
```

Open another terminal window and check:
```bash
curl http://localhost:8080
```
```
# Output:
<h1>Hello from my container!</h1>
```

Now exit the container shell (`exit`). Note the `--rm` flag automatically removed the container when it stopped.

## 1.8 Port Mapping Deep Dive

Port mapping is crucial for making services accessible. Let's explore it in detail.

### The `-p` Flag Syntax

```bash
docker run -p [host-port]:[container-port] [image]
```

Multiple ports:
```bash
docker run -p 8080:80 -p 8443:443 nginx:alpine
```

**Important:** If you don't map ports, the container's ports are accessible only from within Docker's network, not from your host machine.

### Example: Multiple Services

```bash
# Run two web servers on different host ports
docker run -d --name web1 -p 8081:80 nginx:alpine
docker run -d --name web2 -p 8082:80 nginx:alpine

# Check they're running
curl http://localhost:8081
curl http://localhost:8082

# Clean up
docker stop web1 web2
docker rm web1 web2
```

## 1.9 Inspecting Containers

Docker provides powerful introspection tools. Let's explore them.

### `docker inspect`

Shows detailed information about a container in JSON format:

```bash
docker run -d --name inspect-me nginx:alpine
docker inspect inspect-me
```

The output is massive. Let's query specific fields using `--format`:

```bash
# Get just the IP address
docker inspect inspect-me --format='{{.NetworkSettings.IPAddress}}'
```

```bash
# Get the container's status
docker inspect inspect-me --format='{{.State.Status}}'
```

```bash
# Get multiple fields
docker inspect inspect-me --format='{{.Name}} is {{.State.Status}}'
```

### `docker logs`

View a container's STDOUT and STDERR:

```bash
docker logs inspect-me
```

With timestamps:
```bash
docker logs -t inspect-me
```

With `--tail` and `--follow`:
```bash
docker logs --tail 10 -f inspect-me
```

### `docker top`

Show running processes inside a container:

```bash
docker top inspect-me
```
```
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                12345               12344               0                   10:30               ?                   00:00:00            nginx: master process nginx -g daemon off;
101                 12378               12345               0                   10:30               ?                   00:00:00            nginx: worker process
```

### `docker stats`

Real-time resource usage metrics:

```bash
docker stats inspect-me
```
```
CONTAINER ID   NAME         CPU %     MEM USAGE / LIMIT     MEM %     NET I/O           BLOCK I/O   PIDS
e4f8a9d2b1c3   inspect-me   0.00%     8.5MiB / 15.61GiB     0.05%     2.65kB / 0B       0B / 0B     5
```

## 1.10 Cleanup Commands

Good hygiene in Docker is important. Here's how to clean up:

### Remove All Stopped Containers
```bash
docker container prune
```

### Remove All Unused Images
```bash
docker image prune
```

### Remove Everything (Containers, Images, Networks, Build Cache)
```bash
docker system prune -a
```

**Warning:** The `-a` flag removes all unused images, not just dangling ones. This can be destructive!

## 1.11 Lab: Container Playground

This lab combines everything you've learned. **Don't skip it** – it's designed to reinforce the mental model.

### Step 1: Run a Multi-Container Web Server Setup

```bash
# Terminal 1: Run an interactive Ubuntu container
docker run -it --name lab-ubuntu ubuntu:22.04 bash
```

Inside the Ubuntu container:
```bash
# Install a web server
apt update
apt install -y nginx

# Start Nginx in the background
service nginx start

# Verify it's running
ps aux | grep nginx
curl localhost
```
```
# Expected output: Nginx welcome page HTML
```

Keep this terminal open.

### Step 2: Inspect from the Host

Open a second terminal and inspect the container:
```bash
# Check processes
docker top lab-ubuntu

# Check IP address
docker inspect lab-ubuntu --format='{{.NetworkSettings.IPAddress}}'
```

### Step 3: Port Mapping

Stop the container and run it with port mapping:
```bash
docker stop lab-ubuntu
docker rm lab-ubuntu

docker run -it --name lab-ubuntu -p 8080:80 ubuntu:22.04 bash
```

Inside the container again:
```bash
apt update
apt install -y nginx
service nginx start
```

Now visit `http://localhost:8080` in your browser.

### Step 4: Container Lifecycle Practice

```bash
# Pause the container (go back to browser and reload - it will hang)
docker pause lab-ubuntu

# Unpause
docker unpause lab-ubuntu

# Stop gracefully
docker stop lab-ubuntu

# Restart
docker start lab-ubuntu -ai
```

### Step 5: Clean Up Everything

```bash
# Exit the container if inside
exit

# Stop and remove
docker stop lab-ubuntu
docker rm lab-ubuntu

# Remove all unused containers and images
docker system prune
```

## 1.12 Troubleshooting Common Issues

### "Port is already allocated"

**Error:** `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Solution:**
```bash
# Find the container using the port
docker ps --filter "publish=8080"

# Or list all port mappings
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Stop the conflicting container
docker stop [container-name]
```

### "Cannot connect to the Docker daemon"

**Error:** `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`

**Solutions:**

On Linux:
```bash
# Start the Docker daemon
sudo systemctl start docker

# Check status
sudo systemctl status docker
```

On macOS/Windows: Open Docker Desktop.

### "Permission denied" on Linux

**Error:** `Got permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or use:
newgrp docker
```

### Container Exits Immediately

**Problem:** You run `docker run` and the container exits immediately.

**Reason:** The main process (PID 1) in the container exits.

**Example:**
```bash
# This will exit immediately
docker run ubuntu:22.04 echo "Hello"

# This stays running (bash interactive shell)
docker run -it ubuntu:22.04 bash
```

**Check:** `docker ps -a` to see exited containers.
