# Primer 1 – Linux Fundamentals for Docker Users

Docker is built on Linux technologies. While Docker Desktop abstracts much of this complexity on macOS and Windows, understanding the Linux fundamentals will make you a significantly better Docker user. This primer covers the essential Linux concepts you need to know.

## Why Linux Matters for Docker

Docker containers are Linux processes with special isolation features. Even when running on Windows or macOS (through a VM), containers use the Linux kernel. Understanding Linux gives you:

- **Better debugging skills** – You'll understand what's happening inside containers
- **More efficient containers** – You'll know which Linux features to use
- **Security awareness** – You'll understand Linux security models
- **Cross-platform confidence** – Linux knowledge transfers to any environment

**Key Insight:** Every Docker container is just a Linux process with additional isolation. When you run a container, Docker creates a new process with its own view of the system.

---

## P1.1 The Linux Process Model

### Processes and PIDs

In Linux, everything is a process. Every running program has a Process ID (PID).

```bash
# On your Linux host or inside a container
ps aux
```
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  22564  2796 ?        Ss   10:00   0:00 /sbin/init
root         2  0.0  0.0      0     0 ?        S    10:00   0:00 [kthreadd]
...
```

**Key PID Concepts:**

| PID | Description |
|-----|-------------|
| PID 1 | The first process started by the kernel (init system) |
| PID 2 | Kernel thread daemon (kthreadd) |
| Other PIDs | User processes, system services, etc. |

**Why this matters in Docker:** The first process in a container (PID 1) has special responsibilities. It must handle signals and reap zombie processes. Your application becomes PID 1 when you run it in a container.

### Signals

Linux uses signals to communicate with processes. Common signals include:

| Signal | Number | Description | Default Action |
|--------|--------|-------------|----------------|
| SIGTERM | 15 | Termination request | Terminate |
| SIGKILL | 9 | Immediate termination | Terminate |
| SIGINT | 2 | Interrupt (Ctrl+C) | Terminate |
| SIGQUIT | 3 | Quit | Terminate (core dump) |
| SIGCHLD | 17 | Child process stopped/terminated | Ignore |
| SIGHUP | 1 | Hangup | Terminate |

**Testing Signals in a Container:**

```bash
# Run a container and send it signals
docker run -it --name signal-test ubuntu:22.04 bash

# In another terminal, send SIGTERM
docker kill --signal=SIGTERM signal-test
```

**Why this matters:** Docker sends SIGTERM when you run `docker stop`. Your application should handle SIGTERM gracefully to clean up resources.

```python
# Python example: Graceful shutdown
import signal
import sys

def handle_sigterm(signum, frame):
    print("Received SIGTERM, shutting down gracefully...")
    # Clean up connections, save state, etc.
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_sigterm)
```

### Zombie Processes

When a child process exits, it becomes a zombie until the parent reads its exit status. PID 1 (init) is responsible for reaping zombies.

```bash
# Inside a container
ps aux | grep defunct
```

**Why this matters:** If your container's PID 1 doesn't reap zombie processes, they can accumulate and consume system resources.

**Solution:** Use an init system in your container:
```dockerfile
# Add tini as an init system
FROM python:3.11-slim
RUN apt-get update && apt-get install -y tini
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python", "app.py"]
```

---

## P1.2 The Linux Filesystem

### Filesystem Hierarchy Standard (FHS)

Linux follows the Filesystem Hierarchy Standard. Key directories include:

| Directory | Purpose |
|-----------|---------|
| `/` | Root filesystem |
| `/bin` | Essential user binaries |
| `/boot` | Boot loader files |
| `/dev` | Device files |
| `/etc` | System configuration |
| `/home` | User home directories |
| `/lib` | Shared libraries |
| `/media` | Removable media mount points |
| `/mnt` | Temporary mount points |
| `/opt` | Optional software packages |
| `/proc` | Process and system information (virtual) |
| `/root` | Root user's home directory |
| `/run` | Runtime variable data |
| `/sbin` | System binaries (for system admin) |
| `/srv` | Service data |
| `/sys` | Kernel and device information (virtual) |
| `/tmp` | Temporary files |
| `/usr` | User system resources |
| `/var` | Variable data (logs, mail, spool) |

**Why this matters in Docker:** When you use a base image like `ubuntu:22.04`, you get this directory structure. Alpine Linux uses a slightly different structure to be smaller.

### File Permissions

Linux uses a permission model based on:

- **Owner** (user) – The user who owns the file
- **Group** – The group that owns the file
- **Others** – Everyone else

Permissions:
- **r** (read) – View file contents
- **w** (write) – Modify file
- **x** (execute) – Run file as program

```bash
# View permissions
ls -la
```
```
-rw-r--r-- 1 root root  1234 Jan 15 10:00 file.txt
drwxr-xr-x 2 root root  4096 Jan 15 10:00 directory/
```

**Permission Breakdown:**
```
-rw-r--r--
││││││││││
│││││││││└── Other: read (r)
││││││││└─── Other: write (w)
│││││││└──── Other: execute (x)
││││││└───── Group: read (r)
│││││└────── Group: write (w)
││││└─────── Group: execute (x)
│││└──────── User: read (r)
││└───────── User: write (w)
│└────────── User: execute (x)
└─────────── File type (- = file, d = directory, l = link)
```

### Special Permissions

**SetUID (SUID):** Run with owner's permissions
```bash
chmod u+s /path/to/file
```

**SetGID (SGID):** Run with group's permissions
```bash
chmod g+s /path/to/file
```

**Sticky Bit:** Only owner can delete file in directory
```bash
chmod +t /path/to/directory
```

**Why this matters in Docker:** When you mount volumes, permission issues often arise. Understanding Linux permissions helps you resolve them.

### Ownership and Groups

```bash
# Change ownership
chown user:group /path/to/file

# Change permissions
chmod 755 /path/to/file  # rwxr-xr-x
chmod 644 /path/to/file  # rw-r--r--

# User management
adduser username          # Debian/Ubuntu
useradd username          # RHEL/CentOS
groupadd groupname
usermod -aG groupname username
```

**Common Permission Patterns in Docker:**

```dockerfile
# Create user and set permissions
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

# Ensure application directories have proper permissions
COPY --chown=appuser:appgroup . /app
RUN chmod 755 /app && chmod 644 /app/app.py
```

---

## P1.3 The Linux Kernel

### What the Kernel Does

The Linux kernel is the core of the operating system. It:

1. **Manages hardware** – CPU, memory, disk, network
2. **Provides system calls** – The interface between user space and kernel
3. **Schedules processes** – Decides which process runs when
4. **Manages memory** – Allocates and protects memory
5. **Provides filesystems** – Handles file storage and access

### System Calls

System calls are how user space programs interact with the kernel. Common system calls include:

| System Call | Purpose |
|-------------|---------|
| `fork()` | Create a new process |
| `exec()` | Replace process image |
| `open()` | Open a file |
| `read()` | Read from a file descriptor |
| `write()` | Write to a file descriptor |
| `socket()` | Create a network socket |
| `connect()` | Connect to a socket |
| `accept()` | Accept a connection |

**Why this matters in Docker:** `strace` lets you see system calls made by a process. This is powerful for debugging.

```bash
# Trace system calls in a container
docker run --rm ubuntu:22.04 strace ls
```
```
execve("/bin/ls", ["ls"], 0x7ffc... ) = 0
brk(NULL)                               = 0x55...
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT
...
```

### Namespaces – The Isolation Feature

Namespaces are what make containers possible. They provide isolated views of system resources.

**The 8 Linux Namespaces:**

| Namespace | Isolates | Docker Default |
|-----------|----------|----------------|
| **Mount (mnt)** | Filesystem mount points | Yes |
| **UTS** | Hostname and domain name | Yes |
| **IPC** | System V IPC (shared memory, semaphores) | Yes |
| **PID** | Process IDs | Yes |
| **Network (net)** | Network interfaces, routing tables | Yes |
| **User (user)** | User and group IDs | Yes |
| **Cgroup** | Control group hierarchy | Yes (since 4.6) |
| **Time** | System time | Yes (since 5.6) |

**View Namespaces of a Process:**
```bash
# Find a container's PID on the host
docker inspect container-name --format='{{.State.Pid}}'

# View its namespaces
ls -la /proc/<PID>/ns/
```
```
total 0
lrwxrwxrwx 1 root root 0 Jan 15 10:00 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 Jan 15 10:00 ipc -> 'ipc:[4026532801]'
lrwxrwxrwx 1 root root 0 Jan 15 10:00 mnt -> 'mnt:[4026532800]'
lrwxrwxrwx 1 root root 0 Jan 15 10:00 net -> 'net:[4026532803]'
lrwxrwxrwx 1 root root 0 Jan 15 10:00 pid -> 'pid:[4026532802]'
lrwxrwxrwx 1 root root 0 Jan 15 10:00 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 Jan 15 10:00 uts -> 'uts:[4026532799]'
```

### Cgroups – Resource Control

Cgroups (Control Groups) limit and account for resource usage (CPU, memory, disk I/O, network).

```bash
# View cgroup of a container
docker inspect container-name --format='{{.State.Pid}}'
cat /proc/<PID>/cgroup
```
```
12:blkio:/docker/abc123...
11:memory:/docker/abc123...
10:cpu,cpuacct:/docker/abc123...
```

**Why this matters:** Docker uses cgroups to enforce resource limits. When you set `--memory=512M`, Docker creates cgroup limits for your container.

```bash
# Check cgroup memory limit
cat /sys/fs/cgroup/memory/docker/abc123.../memory.limit_in_bytes
```

---

## P1.4 Essential Linux Commands

### Process Commands

```bash
# List processes
ps aux          # All processes with details
ps -ef          # Full format
ps -e --forest  # Tree view

# Process monitoring
top             # Interactive process viewer
htop            # Enhanced top (install separately)

# Kill processes
kill -9 PID     # Force kill (SIGKILL)
kill -15 PID    # Graceful kill (SIGTERM)
killall name    # Kill all processes by name

# Process details
lsof -p PID     # Open files for process
strace -p PID   # Trace system calls for process
```

### File System Commands

```bash
# File operations
ls -la          # List all files with details
cp -r           # Recursive copy
mv              # Move/rename
rm -rf          # Recursive force remove (dangerous!)

# Find files
find / -name "*.log"  # Search for log files
grep -r "error" /var/log  # Search in files

# File permissions
chmod 755 file
chown user:group file

# Disk usage
df -h           # Filesystem disk usage
du -sh *        # Directory sizes

# Mount points
mount           # Show mounted filesystems
mount -t tmpfs tmpfs /tmp  # Mount tmpfs
```

### Network Commands

```bash
# Network interfaces
ip addr         # Show IP addresses
ifconfig        # Legacy (may not be installed)

# Network connections
netstat -tulpn  # Show listening ports
ss -tulpn       # Modern alternative
lsof -i :8080   # Find process using port 8080

# DNS resolution
ping google.com
nslookup google.com
dig google.com

# Network testing
curl -v http://example.com
wget -O- http://example.com

# Firewall
iptables -L -n  # List firewall rules
ufw status      # Ubuntu firewall status
```

### Package Management

```bash
# Debian/Ubuntu (apt/apt-get)
sudo apt update              # Update package lists
sudo apt upgrade             # Upgrade packages
sudo apt install nginx      # Install package
sudo apt remove nginx       # Remove package
apt search nginx            # Search for package

# Alpine Linux (apk)
apk update                  # Update package lists
apk add nginx               # Install package
apk del nginx               # Remove package
apk search nginx            # Search for package

# RHEL/CentOS (yum/dnf)
sudo yum install nginx      # Install package
sudo dnf install nginx      # Install package
```

---

## P1.5 Inside a Container: Hands-On Exercise

### Exercise 1: Explore the Container Filesystem

```bash
# Run a container
docker run -it --name explore ubuntu:22.04 bash

# Inside the container, explore the filesystem
ls -la /
ps aux
cat /etc/os-release
df -h
mount
exit
```

### Exercise 2: Create a User and Run as Non-Root

```bash
# Create container with user
docker run -it ubuntu:22.04 bash

# Inside container
adduser appuser
su - appuser
whoami
# Should show 'appuser'
exit
exit
```

### Exercise 3: Test Permissions and Mounts

```bash
# Create a test container
docker run -it --name perm-test ubuntu:22.04 bash

# Inside container
touch /root/test.txt  # Should fail (permission denied)
mkdir /data
touch /data/test.txt  # Works (as root)

# Exit and restart with specific user
docker run -it --user 1001 ubuntu:22.04 bash
touch /test.txt  # Fails (no permission)
exit
```

### Exercise 4: View a Container's Namespaces

```bash
# Run a container in the background
docker run -d --name ns-test alpine sleep 300

# Get the container's PID on the host
PID=$(docker inspect ns-test --format='{{.State.Pid}}')
echo "Container PID: $PID"

# View its namespaces
ls -la /proc/$PID/ns/

# Clean up
docker rm -f ns-test
```

---

## P1.6 Linux Tools for Docker Debugging

### strace – System Call Tracing

```bash
# Trace the 'ls' command inside a container
docker run --rm ubuntu:22.04 strace ls -la /app 2>&1 | head -20

# Attach to a running container's process
docker exec container-name strace -p 1 -e trace=network
```

### lsof – List Open Files

```bash
# See what files a container process has open
docker exec container-name lsof -p 1

# Or on the host
lsof -p $(docker inspect container-name --format='{{.State.Pid}}')
```

### /proc – Process Information

```bash
# Inside a container
cat /proc/1/status     # Process status
cat /proc/1/environ    # Environment variables
cat /proc/1/cmdline    # Command line
cat /proc/1/limits     # Resource limits
```

### /sys – System Information

```bash
# View cgroup limits
cat /sys/fs/cgroup/memory/memory.limit_in_bytes
cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us
```

### netstat / ss – Network Statistics

```bash
# Inside container
docker exec container-name ss -tulpn
docker exec container-name netstat -tulpn
```

---

## P1.7 Linux in Docker: Common Scenarios

### Scenario 1: Container Runs as Root, But Shouldn't

**Problem:** Container running as root creates files that are owned by root on the host.

**Solution:**
```bash
# Specify user when running
docker run --user 1001:1001 my-image

# Or in the Dockerfile
USER appuser
```

### Scenario 2: File Permission Errors on Mounts

**Problem:** Container can't write to a mounted volume.

**Solution:**
```bash
# Check UID/GID inside container
docker run --rm my-image id

# Match UID/GID on host
sudo chown -R 1001:1001 /host/path

# Or use user namespace remapping in Docker daemon
# /etc/docker/daemon.json
{
  "userns-remap": "default"
}
```

### Scenario 3: Signals Not Handled

**Problem:** Container doesn't shut down gracefully.

**Solution:**
```bash
# Ensure your application handles SIGTERM
# Or use a proper init system
docker run --init my-image
```

### Scenario 4: Zombie Processes

**Problem:** Child processes become zombies.

**Solution:**
```dockerfile
# Use tini as init
FROM python:3.11-slim
RUN apt-get update && apt-get install -y tini
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["python", "app.py"]
```

---

## P1.8 Quick Reference: Linux Commands for Docker

### Essential Commands Cheat Sheet

| Command | Description | Docker Context |
|---------|-------------|----------------|
| `ps aux` | List processes | Check what's running in container |
| `top` | Process monitor | Monitor resource usage |
| `kill -15 PID` | Send SIGTERM | Gracefully stop a process |
| `strace -p PID` | Trace system calls | Debug what a process is doing |
| `lsof -p PID` | List open files | See what files are being used |
| `df -h` | Disk usage | Check container disk usage |
| `du -sh *` | Directory sizes | Find large files |
| `netstat -tulpn` | Network connections | Check open ports |
| `ss -tulpn` | Network connections (modern) | Check open ports |
| `find / -name "*.log"` | Find files | Locate log files |
| `grep -r "error"` | Search files | Search logs for errors |
| `chmod 755` | Change permissions | Fix permission issues |
| `chown user:group` | Change ownership | Fix ownership issues |
| `mount` | Show mounts | See mount points |
| `cat /etc/os-release` | OS info | Check distribution |

### Docker + Linux Debug Flow

```bash
# 1. Enter the container
docker exec -it container-name /bin/bash

# 2. Check what's running
ps aux

# 3. Check resource usage
top
df -h

# 4. Check network
ss -tulpn
netstat -tulpn

# 5. Check logs
tail -f /var/log/app.log

# 6. Check file permissions
ls -la /app
cat /app/config.json

# 7. Check environment
env
cat /proc/1/environ

# 8. Test connectivity
ping other-service
curl http://localhost:8080/health
```

---

## P1.9 Summary

Understanding Linux fundamentals will transform you from a Docker user to a Docker expert. You now know:

**Processes:**
- ✅ PID 1 responsibilities
- ✅ Signals (SIGTERM, SIGKILL)
- ✅ Zombie processes and reaping

**Filesystem:**
- ✅ Linux directory structure
- ✅ File permissions (rwx, ownership)
- ✅ Special permissions (SUID, SGID, Sticky)

**Kernel:**
- ✅ Namespaces (isolation)
- ✅ Cgroups (resource limits)
- ✅ System calls

**Commands:**
- ✅ Process commands (ps, top, kill)
- ✅ Filesystem commands (ls, chmod, chown)
- ✅ Network commands (ss, netstat, curl)
- ✅ Debugging tools (strace, lsof)

**Docker Application:**
- ✅ Running as non-root
- ✅ Handling signals gracefully
- ✅ Reaping zombie processes
- ✅ File permission management
