# Mastering Network Packet Crafting with Scapy
## Primer 2: Linux Command Line for Network Engineers

## Overview

This primer provides a crash course in Linux command-line operations essential for network engineering and packet crafting. If you're already comfortable with Linux, you can skip this section. If you need a refresher or are new to Linux, this primer will get you up to speed quickly.

---

## Table of Contents

1. [Why Linux for Networking?](#why-linux-for-networking)
2. [Getting Started](#getting-started)
3. [File System Navigation](#file-system-navigation)
4. [File Operations](#file-operations)
5. [Text Processing](#text-processing)
6. [Network Commands](#network-commands)
7. [Process Management](#process-management)
8. [Permissions and Ownership](#permissions-and-ownership)
9. [Package Management](#package-management)
10. [Shell Scripting Basics](#shell-scripting-basics)
11. [Working with PCAPs](#working-with-pcaps)
12. [Common Troubleshooting](#common-troubleshooting)

---

## Why Linux for Networking?

Linux is the operating system of choice for network engineering because:

- **Open source**: Free and customizable
- **Powerful toolset**: Extensive networking tools
- **Scriptable**: Bash and Python for automation
- **Stable**: Reliable for production environments
- **Industry standard**: Most network devices run Linux

**Essential Linux Tools for Packet Crafting:**
- `tcpdump` - Packet capture
- `traceroute` - Path discovery
- `ping` - Connectivity testing
- `arp` - ARP cache management
- `netstat` - Network statistics
- `ss` - Socket statistics (modern netstat)
- `ip` - IP configuration (modern ifconfig)
- `nc` (netcat) - Network Swiss Army knife

---

## Getting Started

### Terminal Basics

```bash
# Open a terminal
# Linux: Ctrl+Alt+T
# Mac: Cmd+Space, type "Terminal"
# Windows WSL: Start -> Ubuntu

# Basic prompt structure
user@hostname:~$

# Show current user
whoami

# Show hostname
hostname

# Show current working directory
pwd

# Clear screen
clear
# or Ctrl+L

# Exit terminal
exit
# or Ctrl+D

# Show command history
history

# Repeat last command
!!

# Repeat command number N
!N
```

---

### Getting Help

```bash
# Manual pages
man tcpdump
man ping
man ip

# Search manual pages
man -k network    # Search for "network"
man -k "packet"

# Command help (short version)
tcpdump --help
ping -h
ip -h

# Info pages (more detailed than man)
info coreutils
```

---

## File System Navigation

### Directory Structure

```bash
# Linux directory structure
/           # Root directory
/bin        # Essential binaries
/etc        # System configuration
/home       # User home directories
/root       # Root user home
/tmp        # Temporary files
/usr        # User programs
/var        # Variable data (logs, etc.)
```

---

### Navigation Commands

```bash
# Show current directory
pwd

# List files
ls
ls -l      # Long format
ls -la     # All files (including hidden)
ls -lh     # Human readable sizes
ls -R      # Recursive
ls -ltr    # Sort by time, reverse

# Change directory
cd /home           # Absolute path
cd /var/log        # Absolute path
cd ~               # Home directory
cd ..              # Parent directory
cd -               # Previous directory
cd ../..           # Two levels up

# Tab completion (press Tab to autocomplete)
cd /et[Tab]        # Autocompletes to /etc/
cat /etc/h[Tab]    # Autocompletes to /etc/hosts
```

---

## File Operations

### Creating and Viewing Files

```bash
# Create empty file
touch file.txt

# Create directory
mkdir dir_name
mkdir -p path/to/dir   # Create parent directories too

# View file contents
cat file.txt        # Entire file
less file.txt       # Page by page (press q to quit)
head file.txt       # First 10 lines
tail file.txt       # Last 10 lines
tail -f file.txt    # Follow file (useful for logs)

# View file with line numbers
cat -n file.txt
nl file.txt
```

---

### Copying, Moving, and Deleting

```bash
# Copy files
cp source.txt dest.txt
cp -r source_dir dest_dir   # Recursive (copy directories)

# Move/rename
mv oldname.txt newname.txt
mv file.txt /tmp/           # Move to directory

# Delete files
rm file.txt
rm -r dir_name              # Delete directory
rm -rf dir_name             # Force delete (be careful!)

# Delete empty directory
rmdir dir_name

# Create symbolic link
ln -s /path/to/original link_name
```

---

### Wildcards

```bash
# * matches any characters
ls *.txt          # All .txt files
ls *.pcap         # All PCAP files
rm *.tmp          # Delete all .tmp files

# ? matches single character
ls file?.txt      # file1.txt, file2.txt, etc.

# [] matches any character in brackets
ls file[0-9].txt  # file0.txt through file9.txt

# Combined
ls *.pcap[0-9]    # capture.pcap0, capture.pcap1, etc.
```

---

## Text Processing

### Searching (grep)

```bash
# Search in files
grep "pattern" file.txt
grep "error" /var/log/syslog

# Search recursively
grep -r "error" /var/log/

# Case-insensitive
grep -i "error" file.txt

# Show line numbers
grep -n "error" file.txt

# Show context (lines before/after)
grep -A 2 "error" file.txt   # 2 lines after
grep -B 2 "error" file.txt   # 2 lines before
grep -C 2 "error" file.txt   # 2 lines before and after

# Search in command output
ps aux | grep python
tcpdump -c 10 | grep 192.168.1.100
```

---

### Text Manipulation

```bash
# sed - Stream editor
sed 's/old/new/' file.txt      # Replace first occurrence
sed 's/old/new/g' file.txt     # Replace all occurrences
sed -i 's/old/new/g' file.txt  # Edit in place

# awk - Text processing
awk '{print $1}' file.txt      # Print first column
awk '{print $NF}' file.txt     # Print last column
awk '/pattern/ {print $2}'     # Print column 2 from matching lines

# cut - Extract columns
cut -d',' -f1 file.csv         # Extract first column from CSV
cut -d' ' -f1-3 file.txt       # Extract first 3 columns

# sort - Sort lines
sort file.txt
sort -n file.txt               # Numeric sort
sort -r file.txt               # Reverse sort

# uniq - Unique lines
uniq file.txt                  # Remove duplicates (must be sorted)
sort file.txt | uniq           # Sort then deduplicate
sort file.txt | uniq -c        # Count occurrences

# wc - Word count
wc file.txt                    # Lines, words, characters
wc -l file.txt                 # Lines only
```

---

## Network Commands

### Network Configuration

```bash
# Show IP addresses
ip addr show
ip a

# Show specific interface
ip addr show eth0

# Show interfaces
ip link show
ifconfig -a

# Add IP address
sudo ip addr add 192.168.1.100/24 dev eth0

# Remove IP address
sudo ip addr del 192.168.1.100/24 dev eth0

# Bring interface up/down
sudo ip link set eth0 up
sudo ip link set eth0 down

# Show routing table
ip route show
route -n

# Add default gateway
sudo ip route add default via 192.168.1.1

# Show MAC address
ip link show eth0 | grep ether
```

---

### Network Testing

```bash
# Ping
ping 8.8.8.8
ping -c 4 8.8.8.8       # 4 pings
ping -i 0.5 8.8.8.8     # 0.5 second interval

# Traceroute
traceroute 8.8.8.8
traceroute -n 8.8.8.8   # No DNS resolution

# DNS resolution
dig google.com
dig -x 8.8.8.8           # Reverse DNS
nslookup google.com
host google.com

# Show network connections
ss -tuln                 # TCP/UDP listening ports
ss -tulnp                # With processes
netstat -tuln
netstat -tulnp

# Show open ports
ss -lntp                 # TCP listening
ss -lnup                 # UDP listening
lsof -i :80              # What's using port 80
```

---

### Network Capture (tcpdump)

```bash
# Basic capture
sudo tcpdump -i eth0

# Capture limited packets
sudo tcpdump -i eth0 -c 10

# Capture to file
sudo tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Filter by host
sudo tcpdump -i eth0 host 192.168.1.100

# Filter by port
sudo tcpdump -i eth0 port 80
sudo tcpdump -i eth0 tcp port 443

# Filter by protocol
sudo tcpdump -i eth0 tcp
sudo tcpdump -i eth0 udp
sudo tcpdump -i eth0 icmp

# Complex filters
sudo tcpdump -i eth0 "tcp port 80 and host 192.168.1.100"
sudo tcpdump -i eth0 "not arp and not icmp"

# Verbose output
sudo tcpdump -i eth0 -v
sudo tcpdump -i eth0 -vv
sudo tcpdump -i eth0 -vvv

# Show hex dump
sudo tcpdump -i eth0 -x
sudo tcpdump -i eth0 -X  # Hex and ASCII

# Snap length (capture first N bytes)
sudo tcpdump -i eth0 -s 1500

# No promiscuous mode
sudo tcpdump -i eth0 -p
```

---

### ARP Commands

```bash
# Show ARP cache
arp -n
ip neigh show

# Add ARP entry
sudo arp -s 192.168.1.100 00:11:22:33:44:55

# Delete ARP entry
sudo arp -d 192.168.1.100

# Clear ARP cache
sudo ip neigh flush all

# Show ARP table with details
ip neigh show dev eth0
```

---

## Process Management

### Viewing Processes

```bash
# Show all processes
ps aux
ps -ef

# Show processes by user
ps aux | grep username

# Tree view
pstree

# Show with CPU/memory info
top
htop  # Install if not available: sudo apt install htop

# Find process by name
pgrep python
ps aux | grep python

# Show process tree
ps -ef --forest
```

---

### Managing Processes

```bash
# Kill process by PID
kill PID
kill -9 PID     # Force kill
kill -15 PID    # Graceful kill

# Kill by name
pkill process_name
killall process_name

# Background a process
command &
# Ctrl+Z to suspend, then bg to background

# Bring to foreground
fg

# Show background jobs
jobs

# Nice values (priority)
nice -n 10 command
renice 10 -p PID
```

---

## Permissions and Ownership

### File Permissions

```bash
# Show permissions
ls -l file.txt
# -rw-r--r-- 1 user group 0 Mar 15 10:00 file.txt
# |----------| |---| |---|
# |          | user group
# permissions

# Permission types
# r = read, w = write, x = execute
# - = no permission

# Permission sets
# user (owner), group, others

# Change permissions
chmod 755 file.txt        # -rwxr-xr-x
chmod u+x file.txt        # Add execute for user
chmod g-w file.txt        # Remove write for group
chmod o+r file.txt        # Add read for others
chmod a+x file.txt        # Add execute for all

# Numeric permissions
# 4 = read, 2 = write, 1 = execute
# 755 = rwxr-xr-x
# 644 = rw-r--r--
# 600 = rw-------
```

---

### Ownership

```bash
# Change owner
sudo chown username file.txt

# Change group
sudo chgrp groupname file.txt

# Change both
sudo chown username:groupname file.txt

# Recursive
sudo chown -R username:groupname /path/to/dir
```

---

## Package Management

### Ubuntu/Debian (APT)

```bash
# Update package list
sudo apt update

# Upgrade packages
sudo apt upgrade

# Install package
sudo apt install scapy
sudo apt install wireshark
sudo apt install tcpdump

# Remove package
sudo apt remove scapy

# Search packages
apt search scapy

# Show package info
apt show scapy

# List installed packages
dpkg -l
apt list --installed

# Clean cache
sudo apt autoremove
sudo apt autoclean
```

---

### RHEL/Fedora (dnf/yum)

```bash
# Update package list
sudo dnf update

# Install package
sudo dnf install scapy

# Remove package
sudo dnf remove scapy

# Search
dnf search scapy

# List installed
dnf list installed
rpm -qa
```

---

### macOS (Homebrew)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update
brew update

# Install package
brew install scapy
brew install wireshark
brew install tcpdump

# Remove package
brew uninstall scapy

# List installed
brew list
```

---

### Windows (WSL)

```bash
# Enable WSL (PowerShell as Admin)
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Install WSL2
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d Ubuntu

# Then use APT commands above
```

---

## Shell Scripting Basics

### Variables

```bash
#!/bin/bash

# Define variable
NAME="Scapy"
VERSION=1.0
IP="192.168.1.100"

# Use variable
echo "Hello $NAME"
echo "Version: $VERSION"
echo "IP: $IP"

# Command substitution
CURRENT_DATE=$(date)
echo "Date: $CURRENT_DATE"

# Arithmetic
SUM=$((10 + 20))
echo "Sum: $SUM"

# Environment variables
echo $PATH
echo $HOME
echo $USER
```

---

### Conditions

```bash
#!/bin/bash

# If statement
if [ condition ]; then
    # commands
fi

# If-else
if [ condition ]; then
    # commands
else
    # commands
fi

# Else-if
if [ condition1 ]; then
    # commands
elif [ condition2 ]; then
    # commands
else
    # commands
fi

# File tests
if [ -f "/etc/hosts" ]; then
    echo "File exists"
fi

if [ -d "/var/log" ]; then
    echo "Directory exists"
fi

# String tests
if [ "$NAME" = "Scapy" ]; then
    echo "Name is Scapy"
fi

if [ -z "$VAR" ]; then
    echo "Variable is empty"
fi

# Numeric tests
if [ $COUNT -gt 10 ]; then
    echo "Count > 10"
fi
```

---

### Loops

```bash
#!/bin/bash

# For loop
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

# For loop with range
for i in {1..10}; do
    echo "Number: $i"
done

# For loop with files
for file in *.txt; do
    echo "Processing: $file"
done

# While loop
count=1
while [ $count -le 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done

# Until loop
count=1
until [ $count -gt 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done
```

---

### Functions

```bash
#!/bin/bash

# Define function
function hello() {
    echo "Hello $1"
}

# Call function
hello "World"

# Function with return value
function add() {
    echo $(($1 + $2))
}

result=$(add 5 3)
echo "Result: $result"

# Function with multiple statements
function scan() {
    echo "Scanning $1"
    ping -c 1 $1 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$1 is alive"
    else
        echo "$1 is dead"
    fi
}

scan "8.8.8.8"
```

---

### Example Network Scripts

```bash
#!/bin/bash
# scan.sh - Simple network scanner

NETWORK="192.168.1"
echo "Scanning: $NETWORK.0/24"

for i in {1..254}; do
    IP="$NETWORK.$i"
    ping -c 1 -W 1 $IP > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "$IP is alive"
    fi
done
```

```bash
#!/bin/bash
# capture.sh - Capture specific traffic

INTERFACE="eth0"
OUTPUT="capture_$(date +%Y%m%d_%H%M%S).pcap"

echo "Capturing on $INTERFACE"
echo "Output: $OUTPUT"
echo "Press Ctrl+C to stop"

sudo tcpdump -i $INTERFACE -w $OUTPUT \
    "tcp port 80 or tcp port 443 or udp port 53"
```

---

## Working with PCAPs

### tcpdump Command Reference

```bash
# Capture to file
sudo tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Read with filters
tcpdump -r capture.pcap "tcp port 80"

# Show packet details
tcpdump -r capture.pcap -v
tcpdump -r capture.pcap -vv

# Show hex dump
tcpdump -r capture.pcap -X

# Show time stamps
tcpdump -r capture.pcap -tt
tcpdump -r capture.pcap -ttt  # Delta time

# Limit number of packets
tcpdump -r capture.pcap -c 10

# Convert PCAP to text
tcpdump -r capture.pcap -n > output.txt

# Show statistics
tcpdump -r capture.pcap -q   # Quiet mode
tcpdump -r capture.pcap -s 0 # Full packet capture
```

---

### tshark Command Reference

```bash
# Install tshark
sudo apt install tshark

# Read PCAP
tshark -r capture.pcap

# Show fields
tshark -r capture.pcap -T fields -e ip.src -e ip.dst

# Filter
tshark -r capture.pcap -Y "tcp.port == 80"

# Show statistics
tshark -r capture.pcap -z io,stat,1

# Show protocol hierarchy
tshark -r capture.pcap -z proto,colinfo

# Export to JSON
tshark -r capture.pcap -T json
```

---

### Mergecap - Combine PCAPs

```bash
# Merge multiple PCAPs
mergecap -w merged.pcap file1.pcap file2.pcap

# Merge with timestamps sorted
mergecap -w merged.pcap -T file1.pcap file2.pcap

# Combine all PCAPs in directory
mergecap -w merged.pcap *.pcap
```

---

### Editcap - Modify PCAPs

```bash
# Extract first 100 packets
editcap capture.pcap first100.pcap 1-100

# Extract packets with specific timestamp
editcap -A "2024-01-01 00:00:00" -B "2024-01-02 00:00:00" capture.pcap filtered.pcap

# Remove duplicate packets
editcap -d capture.pcap dedup.pcap

# Truncate packets
editcap -s 1500 capture.pcap truncated.pcap
```

---

## Common Troubleshooting

### Network Connectivity

```bash
# Check interface status
ip link show
ethtool eth0

# Check IP configuration
ip addr show
ip route show

# Test connectivity
ping 8.8.8.8
ping google.com

# Trace route
traceroute 8.8.8.8
mtr 8.8.8.8   # My Traceroute (continuous)

# Check DNS
dig google.com
nslookup google.com

# Check open ports
nmap -sT -p 80,443,22 192.168.1.1

# Check local open ports
ss -tuln
netstat -tuln
```

---

### Performance Issues

```bash
# CPU usage
top
htop

# Memory usage
free -h
vmstat 2

# Disk usage
df -h
du -sh *

# Network throughput
iftop
nload

# Interface statistics
ip -s link show eth0
ifconfig eth0
```

---

### Scapy on Linux

```bash
# Install Scapy
sudo apt install python3-scapy
# or
pip install scapy[complete]

# Check Scapy version
python3 -c "import scapy; print(scapy.__version__)"

# Test with root privileges
sudo python3 -c "from scapy.all import *; send(IP(dst='8.8.8.8')/ICMP())"

# Check interfaces
python3 -c "from scapy.all import get_if_list; print(get_if_list())"

# Run Scapy interactively
sudo scapy

# In Scapy shell:
# >>> ls()           # List protocols
# >>> lsc()          # List commands
# >>> conf           # Show configuration
# >>> IP().show()    # Show IP fields
```

---

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| `Permission denied` | No root privileges | Use `sudo` |
| `Operation not permitted` | Missing capabilities | `sudo setcap cap_net_raw,cap_net_admin+eip /usr/bin/python3` |
| `Interface not found` | Wrong interface name | `ip link show` to list interfaces |
| `No response` | Firewall/network issues | Check connectivity with `ping` |
| `Buffer overflow` | Too many packets | Use filters or increase buffer |
| `Command not found` | Package not installed | `sudo apt install PACKAGE` |

---

## Primer Complete

This primer covers the essential Linux command-line skills needed for the series. You should now be comfortable with:

- **Basic terminal operations** and navigation
- **File system** management and manipulation
- **Text processing** with grep, sed, and awk
- **Network commands** for configuration and testing
- **Process management** and monitoring
- **Permissions** and ownership
- **Package management** for different systems
- **Shell scripting** for automation
- **PCAP handling** with Linux tools
- **Common troubleshooting** techniques

---

```
─────────────────────────────────────────────────────────────────────────
│  PRIMER: LINUX COMMAND LINE FOR NETWORK ENGINEERS COMPLETE          │
│                                                                     │
│  This primer covers:                                               │
│  ✅ Linux fundamentals                                             │
│  ✅ File system navigation                                         │
│  ✅ File operations                                                │
│  ✅ Text processing                                                │
│  ✅ Network commands                                               │
│  ✅ Process management                                             │
│  ✅ Permissions and ownership                                      │
│  ✅ Package management                                             │
│  ✅ Shell scripting                                                │
│  ✅ PCAP handling                                                  │
│  ✅ Troubleshooting                                                │
│                                                                     │
│  You are now ready to begin the series!                           │
└─────────────────────────────────────────────────────────────────────────
```

---

**Return to the series introduction** when you're ready, or proceed directly to **Module 1: Foundations of Packet Crafting**.
