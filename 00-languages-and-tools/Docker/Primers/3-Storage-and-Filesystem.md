# Primer 3 – Storage and Filesystem Fundamentals for Docker Users

Understanding how storage works in Linux and Docker is crucial for managing persistent data, troubleshooting permission issues, and optimizing performance. This primer covers everything from basic filesystem concepts to Docker's storage drivers, volumes, and best practices.

By the end, you'll understand how data flows from your application to the physical disk and how to make informed decisions about storage in Docker.

---

## P3.1 Linux Filesystem Basics

### Filesystem Types

Linux supports many filesystem types. The most common are:

| Filesystem | Description | Use Case |
|------------|-------------|----------|
| **ext4** | Default for many Linux distributions | General purpose, good performance |
| **XFS** | High-performance journaling filesystem | Large files, high throughput |
| **ZFS** | Advanced filesystem with volume management | Data integrity, snapshots |
| **Btrfs** | Copy-on-write filesystem | Advanced features, Docker storage |
| **tmpfs** | In-memory filesystem | Temporary data, caches |
| **OverlayFS** | Union filesystem | Docker layers |

### Filesystem Hierarchy

Linux organizes files in a tree structure starting from `/` (root).

```
/
├── bin/           # Essential user binaries
├── boot/          # Boot loader files
├── dev/           # Device files
├── etc/           # System configuration
├── home/          # User home directories
├── lib/           # Shared libraries
├── media/         # Removable media
├── mnt/           # Temporary mounts
├── opt/           # Optional software
├── proc/          # Process information (virtual)
├── root/          # Root user's home
├── run/           # Runtime data
├── sbin/          # System binaries
├── srv/           # Service data
├── sys/           # Kernel parameters (virtual)
├── tmp/           # Temporary files
├── usr/           # User system resources
└── var/           # Variable data (logs, etc.)
```

### Inodes and Data Blocks

Files in Linux are stored using:
- **Inodes:** Store metadata (permissions, ownership, size, timestamps, pointers to data blocks)
- **Data blocks:** Store the actual file content

```bash
# Check inode usage
df -i
```
```
Filesystem      Inodes  IUsed   IFree IUse% Mounted on
/dev/sda1      6553600  82345 6471255    2% /
```

```bash
# View inode details of a file
stat /etc/passwd
```
```
  File: /etc/passwd
  Size: 2977       Blocks: 8          IO Block: 4096   regular file
Device: 802h/2050d Inode: 165682      Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-01-15 10:00:00.000000000 +0000
Modify: 2024-01-15 09:30:00.000000000 +0000
Change: 2024-01-15 09:30:00.000000000 +0000
 Birth: -
```

**Why this matters in Docker:** Container filesystems are built on layers. Understanding how files are stored helps you optimize image sizes and troubleshoot storage issues.

---

## P3.2 Docker's Storage Architecture

### The Layered Filesystem

Docker images are composed of layers stacked on top of each other.

```
┌─────────────────────────────────────────────┐
│ Container (writable layer)                   │
├─────────────────────────────────────────────┤
│ Image Layer 3: CMD ["python", "app.py"]     │
├─────────────────────────────────────────────┤
│ Image Layer 2: COPY . /app                  │
├─────────────────────────────────────────────┤
│ Image Layer 1: FROM python:3.11-slim       │
├─────────────────────────────────────────────┤
│ Base Layer: OS filesystem                  │
└─────────────────────────────────────────────┘
```

**Key Concepts:**
- **Layers are read-only** (except the container's writable layer)
- **Copy-on-Write (CoW):** When a container modifies a file from an image layer, Docker copies it to the container layer first
- **Union mounts:** Combine multiple filesystem layers into a single view

### Storage Drivers

Docker uses storage drivers to manage layers. The choice of driver affects performance and storage efficiency.

| Driver | Description | Best For |
|--------|-------------|----------|
| **overlay2** | Modern, stable, fast | Most Linux distributions (default) |
| **overlay** | Older version of overlay | Legacy systems |
| **aufs** | Original Docker driver | Old Ubuntu/Debian |
| **devicemapper** | Based on thin provisioning | RHEL/CentOS (deprecated) |
| **btrfs** | Native Btrfs support | Systems using Btrfs |
| **zfs** | Native ZFS support | Systems using ZFS |
| **vfs** | No CoW, simple | Testing |

**Check your storage driver:**
```bash
docker info | grep "Storage Driver"
```
```
Storage Driver: overlay2
```

### How Overlay2 Works

Overlay2 uses three directories to manage layers:

```
/var/lib/docker/overlay2/
├── lower/           # Lower directories (image layers)
├── upper/           # Container's writable layer
├── merged/          # Combined view (what container sees)
└── work/            # Internal work directory

Container sees: /merged/
```

**Copy-on-Write Example:**

1. **File exists in lower layer**
   - Container reads from lower layer (fast)

2. **Container writes to file**
   - File is copied to upper layer
   - File in upper layer is modified
   - From then on, reads use the upper layer version

3. **Container deletes file**
   - A "whiteout" file is created in upper layer
   - The file appears deleted in merged view

### Viewing Container Filesystem

```bash
# See the merged directory for a container
docker inspect container-name --format='{{.GraphDriver.Data.MergedDir}}'

# View the filesystem contents
sudo ls -la /var/lib/docker/overlay2/abc123.../merged/

# Check disk usage of layers
docker system df -v | grep "Layers"
```

---

## P3.3 Understanding Docker Storage Drivers in Detail

### Overlay2 Configuration

**`/etc/docker/daemon.json`:**
```json
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true",
    "overlay2.size=20G",
    "overlay2.mount_opt=user_xattr,seclabel",
    "overlay2.override_kernel_check=true"
  ]
}
```

**Performance Optimizations:**
```json
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "data-root": "/new/docker/path"  # Move storage location
}
```

### Other Storage Drivers

**Btrfs:**
```json
{
  "storage-driver": "btrfs"
}
```

**ZFS:**
```json
{
  "storage-driver": "zfs",
  "storage-opts": [
    "zfs.fsname=zroot/docker"
  ]
}
```

**Device Mapper (deprecated):**
```json
{
  "storage-driver": "devicemapper",
  "storage-opts": [
    "dm.thinpooldev=/dev/mapper/docker-pool",
    "dm.use_deferred_removal=true",
    "dm.use_deferred_deletion=true"
  ]
}
```

---

## P3.4 Docker Volumes: The Persistent Storage Solution

### Volume Types Comparison

| Type | Managed By | Use Case | Performance |
|------|------------|----------|-------------|
| **Named Volume** | Docker | Production data | Fast |
| **Anonymous Volume** | Docker | Temporary data | Fast |
| **Bind Mount** | User | Development | Fast (Linux) |
| **tmpfs** | Docker (memory) | Caches, secrets | Fastest |

### How Volumes Work Internally

**Named volumes:**
```
/var/lib/docker/volumes/
└── volume-name/
    └── _data/          # The actual data directory
```

**Bind mounts:**
- Direct link to host directory
- No Docker management
- Permission sensitive

### Volume Lifecycle

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Create      │───►│ Mount       │───►│ Use         │
│ Volume      │    │ to          │    │ Container   │
└─────────────┘    │ Container   │    └─────────────┘
                   └─────────────┘          │
                                           ▼
                    ┌─────────────┐    ┌─────────────┐
                    │ Unmount     │◄───│ Remove      │
                    │ Volume      │    │ Container   │
                    └─────────────┘    └─────────────┘
```

### Volume Drivers

Volume drivers allow volumes to be stored in different locations:

| Driver | Description |
|--------|-------------|
| **local** | Default, stores on host |
| **nfs** | Network File System |
| **cloud** | AWS EBS, GCE, etc. |
| **custom** | Third-party plugins |

**Example: NFS Volume**
```bash
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/exported/path \
  nfs-volume
```

---

## P3.5 File Permissions in Detail

### Linux Permission Model

**Three User Types:**
- Owner (u) – The user who owns the file
- Group (g) – Users in the file's group
- Others (o) – Everyone else

**Three Permissions:**
- Read (r) – View contents
- Write (w) – Modify contents
- Execute (x) – Run as program

**Permission Bits:**
```
-rwxr-xr-x
││││││││││
│││││││││└── Other: execute (1)
││││││││└─── Other: write (2)
│││││││└──── Other: read (4)
││││││└───── Group: execute (1)
│││││└────── Group: write (2)
││││└─────── Group: read (4)
│││└──────── User: execute (1)
││└───────── User: write (2)
│└────────── User: read (4)
└─────────── File type (-, d, l)
```

**Common Permission Modes:**
```bash
chmod 755 file  # rwxr-xr-x (owner can rwx, others can r-x)
chmod 644 file  # rw-r--r-- (owner can rw, others can r)
chmod 750 file  # rwxr-x--- (owner rwx, group r-x, others nothing)
chmod 777 file  # rwxrwxrwx (everyone can do anything - DANGEROUS)
```

### User and Group Management

```bash
# Create a user
useradd -r -s /bin/false appuser      # System user (no login)
adduser --system appuser               # Debian/Ubuntu

# Create a group
groupadd -r appgroup                   # System group
addgroup --system appgroup             # Debian/Ubuntu

# Add user to group
usermod -a -G appgroup appuser
adduser appuser appgroup                # Debian/Ubuntu

# Change ownership
chown appuser:appgroup /app/data
chown -R appuser:appgroup /app

# Change permissions
chmod 755 /app
chmod 640 /app/config.json
```

### Special Permissions for Volumes

**SUID (Set User ID):** Runs with owner's permissions
```bash
chmod u+s /path/to/file
```

**SGID (Set Group ID):** Runs with group's permissions
```bash
chmod g+s /path/to/directory
```

**Sticky Bit:** Only owner can delete files in directory
```bash
chmod +t /path/to/directory
```

---

## P3.6 Permission Troubleshooting in Docker

### Common Permission Scenarios

**Scenario 1: Container Can't Write to Mounted Volume**

**Error:**
```
PermissionError: [Errno 13] Permission denied: '/app/data/'
```

**Diagnosis:**
```bash
# Check ownership inside container
docker exec container-name ls -la /app/data

# Check UID/GID
docker exec container-name id
docker exec container-name cat /proc/1/status | grep Uid

# Check host permissions
ls -la /host/path
```

**Solutions:**
```bash
# 1. Match UID in Dockerfile
FROM python:3.11
RUN adduser -u 1001 appuser
USER appuser

# 2. Run container with specific UID
docker run --user 1001:1001 my-image

# 3. Change ownership on host
sudo chown -R 1001:1001 /host/path

# 4. Use user namespace remapping
# /etc/docker/daemon.json
{
  "userns-remap": "default"
}
```

**Scenario 2: Container Creates Files with Root Ownership**

**Problem:** Files created by container are owned by root on the host.

**Solution:**
```dockerfile
# Dockerfile
FROM python:3.11-slim
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

```bash
# Or run with specific user
docker run --user 1001:1001 my-image
```

**Scenario 3: Permission Denied When Mounting Socket**

**Error:**
```
docker: Error response from daemon: error while creating mount source path '/var/run/docker.sock': stat /var/run/docker.sock: permission denied
```

**Solution:**
```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER

# Or use specific group ID
docker run --group-add $(getent group docker | cut -d: -f3) ...
```

### Best Practice: User Management in Dockerfiles

```dockerfile
# Production Dockerfile with proper user management
FROM python:3.11-slim

# Create user and group with specific IDs
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

# Create directories with proper ownership
WORKDIR /app
RUN mkdir -p data logs uploads && \
    chown -R appuser:appgroup /app && \
    chmod 755 data logs uploads

# Copy and set ownership
COPY --chown=appuser:appgroup . /app

# Switch to non-root user
USER appuser

# Application is now running as appuser
CMD ["python", "app.py"]
```

---

## P3.7 Performance Optimization

### Storage Driver Performance

| Driver | Read Performance | Write Performance | Overhead |
|--------|------------------|-------------------|----------|
| **overlay2** | Excellent | Excellent | Low |
| **btrfs** | Good | Good | Medium |
| **zfs** | Good | Good | Medium |
| **devicemapper** | Fair | Fair | High |

### Performance Best Practices

**1. Use Overlay2 (default)**
```json
{
  "storage-driver": "overlay2"
}
```

**2. Move storage to fast disk**
```bash
# Stop Docker
sudo systemctl stop docker

# Move data
sudo mv /var/lib/docker /new/fast/disk/docker

# Create symlink
sudo ln -s /new/fast/disk/docker /var/lib/docker

# Start Docker
sudo systemctl start docker
```

**3. Use tmpfs for temporary data**
```yaml
services:
  app:
    tmpfs:
      - /tmp:size=100M,mode=0700
      - /run:size=50M
```

**4. Avoid bind mounts in production**
```yaml
services:
  app:
    volumes:
      - app-data:/app/data  # Use named volumes
```

**5. Monitor IO performance**
```bash
# Monitor disk I/O
docker stats --no-stream

# Use iostat
iostat -x 1

# Monitor Docker storage
docker system df -v
```

---

## P3.8 Storage Commands Reference

### Filesystem Commands

```bash
# Disk usage
df -h
df -i  # Inode usage
du -sh *  # Directory sizes
du -sh /var/lib/docker

# Filesystem info
mount
lsblk
fdisk -l

# File info
stat file
file file

# Permission management
chown user:group file
chmod 755 file
umask 022  # Default permissions
```

### Docker Storage Commands

```bash
# Check storage usage
docker system df
docker system df -v  # Detailed

# Cleanup
docker system prune
docker system prune -a --volumes
docker container prune
docker image prune -a
docker volume prune
docker builder prune -a

# Volume management
docker volume ls
docker volume create my-vol
docker volume inspect my-vol
docker volume rm my-vol
docker volume prune

# Storage driver info
docker info | grep "Storage Driver"
docker inspect container-name --format='{{.GraphDriver}}'
```

### Data Operations

```bash
# Backup a volume
docker run --rm \
  -v my-volume:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /source .

# Restore a volume
docker run --rm \
  -v my-volume:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /target

# Copy data between volumes
docker run --rm \
  -v source-volume:/from \
  -v target-volume:/to \
  alpine cp -a /from/. /to/

# Copy files to/from container
docker cp container:/app/data ./data-backup
docker cp ./config.json container:/app/config.json

# View volume contents
docker run --rm -v my-volume:/data alpine ls -la /data
```

---

## P3.9 Storage Lab: Permission and Volume Exercise

### Lab Setup

```bash
# Create a test application
cat > app.py << EOF
#!/usr/bin/env python3
import os
import time

DATA_DIR = '/app/data'
LOG_DIR = '/app/logs'

def main():
    print(f"Running as: {os.geteuid()}")
    print(f"Data directory: {DATA_DIR}")
    print(f"Log directory: {LOG_DIR}")
    
    # Write to data directory
    with open(f'{DATA_DIR}/data.txt', 'w') as f:
        f.write(f"Data written at {time.ctime()}")
    
    # Write to logs directory
    with open(f'{LOG_DIR}/app.log', 'w') as f:
        f.write(f"Log written at {time.ctime()}")
    
    # List directory contents
    for dir_path in [DATA_DIR, LOG_DIR]:
        print(f"\nContents of {dir_path}:")
        for item in os.listdir(dir_path):
            print(f"  - {item}")

if __name__ == '__main__':
    main()
EOF

cat > Dockerfile << EOF
FROM python:3.11-slim

RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app
COPY app.py .

USER appuser
CMD ["python", "app.py"]
EOF

# Build the image
docker build -t app-perms .
```

### Exercise 1: Permission Basics

```bash
# 1. Run container with volume
mkdir -p data logs
docker run --rm \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/logs:/app/logs \
  app-perms

# This will fail because the container user (UID 1001) can't write
# to host directories owned by your user (UID 1000)

# 2. Check the failure
ls -la data  # File might be missing or created with different owner

# 3. Fix by matching UID
sudo chown 1001:1001 data logs
docker run --rm \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/logs:/app/logs \
  app-perms

# 4. Now it works! Check the files
cat data/data.txt
cat logs/app.log
```

### Exercise 2: Named Volumes

```bash
# 1. Create named volumes
docker volume create app-data
docker volume create app-logs

# 2. Run container with named volumes
docker run --rm \
  -v app-data:/app/data \
  -v app-logs:/app/logs \
  app-perms

# 3. Check volume contents
docker run --rm \
  -v app-data:/data \
  alpine cat /data/data.txt
docker run --rm \
  -v app-logs:/data \
  alpine cat /data/app.log

# 4. Inspect volumes
docker volume inspect app-data
docker volume inspect app-logs
```

### Exercise 3: Permission Fix

```bash
# 1. Create a volume with specific permissions
docker volume create \
  --driver local \
  --opt type=tmpfs \
  --opt device=tmpfs \
  --opt o=size=100m,uid=1001,gid=1001 \
  tmpfs-volume

# 2. Use the volume
docker run --rm \
  -v tmpfs-volume:/app/data \
  app-perms

# 3. Verify
docker run --rm \
  -v tmpfs-volume:/data \
  alpine ls -la /data
```

---

## P3.10 Summary: Storage Fundamentals

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Layers** | Read-only image layers stacked to form filesystem |
| **Copy-on-Write** | Modifications are copied to container layer |
| **Storage Driver** | Manages layers (overlay2, btrfs, etc.) |
| **Volumes** | Persistent data managed by Docker |
| **Bind Mounts** | Host directory mounted into container |
| **Permissions** | UID/GID determine file access |

### Best Practices Checklist

- [ ] Use named volumes for persistent data
- [ ] Avoid bind mounts in production
- [ ] Always run as non-root user
- [ ] Match UID/GID between container and host
- [ ] Use tmpfs for temporary data
- [ ] Clean up unused volumes regularly
- [ ] Monitor disk usage with `docker system df`
- [ ] Use overlay2 storage driver
- [ ] Store volumes on fast storage
- [ ] Implement regular volume backups

### Troubleshooting Checklist

- [ ] Check container user: `docker exec container id`
- [ ] Check directory permissions: `ls -la /path`
- [ ] Check volume driver: `docker volume inspect volume-name`
- [ ] Check storage driver: `docker info | grep Storage`
- [ ] Check disk space: `df -h`
- [ ] Check inode usage: `df -i`
- [ ] Check Docker storage usage: `docker system df -v`
- [ ] Check for permission errors: `docker logs container-name`
- [ ] Verify mount points: `docker inspect container-name --format='{{.Mounts}}'`
