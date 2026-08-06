# Mastering Network Packet Crafting with Scapy
## Appendix E: Troubleshooting Guide

## Overview

This appendix provides a comprehensive troubleshooting guide for common issues encountered when working with Scapy and network packet crafting. Each section includes symptoms, causes, and solutions.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Permission Issues](#permission-issues)
3. [Packet Sending Issues](#packet-sending-issues)
4. [Packet Capture Issues](#packet-capture-issues)
5. [PCAP Issues](#pcap-issues)
6. [Protocol Issues](#protocol-issues)
7. [Performance Issues](#performance-issues)
8. [Custom Protocol Issues](#custom-protocol-issues)
9. [System-Specific Issues](#system-specific-issues)
10. [Debugging Techniques](#debugging-techniques)

---

## Installation Issues

### Issue: Scapy Not Found

**Symptoms:**
```python
ModuleNotFoundError: No module named 'scapy'
```

**Causes:**
- Scapy not installed
- Installed in different Python environment
- Virtual environment not activated

**Solutions:**

```bash
# Install Scapy
pip install scapy[complete]

# Check installation
python -c "import scapy; print(scapy.__version__)"

# If using virtual environment
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# Install in specific Python version
python3 -m pip install scapy[complete]
```

---

### Issue: Scapy Complete Installation Fails

**Symptoms:**
```
ERROR: Could not find a version that satisfies the requirement scapy[complete]
```

**Causes:**
- PyPI version issue
- Dependencies conflict
- Python version compatibility

**Solutions:**

```bash
# Install minimal version first
pip install scapy

# Install dependencies manually
pip install matplotlib numpy pandas

# Try using pip3
pip3 install scapy[complete]

# Install from GitHub
pip install git+https://github.com/secdev/scapy.git
```

---

### Issue: ImportError on Specific Modules

**Symptoms:**
```python
from scapy.all import Ether, IP, TCP  # Works
from scapy.layers.inet import IP      # Error
```

**Causes:**
- Module location changed
- Scapy version differences

**Solutions:**

```python
# Preferred import method
from scapy.all import *

# Specific imports
from scapy.all import IP, TCP, UDP

# If needed, use absolute imports
from scapy.layers.inet import IP  # May not work in all versions
```

---

## Permission Issues

### Issue: Permission Denied on Send

**Symptoms:**
```
PermissionError: [Errno 13] Permission denied
```
or
```
OSError: [Errno 1] Operation not permitted
```

**Causes:**
- Raw socket requires root/admin privileges
- Insufficient permissions on network interface

**Solutions:**

```bash
# Linux/macOS
sudo python3 script.py

# Windows - Run as Administrator
# Right-click -> Run as Administrator

# Check permissions on interface
ls -la /dev/net/tun  # Check tun device
```

---

### Issue: Cannot Enable Promiscuous Mode

**Symptoms:**
```
Warning: can't enable promiscuous mode
```

**Causes:**
- Missing capabilities
- Interface doesn't support promiscuous mode

**Solutions:**

```bash
# Linux - Grant capabilities
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/python3

# Linux - Add user to wireshark group
sudo usermod -a -G wireshark $USER
# Logout and login again

# Linux - Allow non-root capture
sudo chmod +x /usr/bin/dumpcap  # If using Wireshark
```

---

### Issue: Permission on Windows

**Symptoms:**
```
PermissionError: [WinError 10013] An attempt was made to access a socket in a way forbidden by its access permissions
```

**Causes:**
- Windows Firewall blocking
- Anti-virus interference
- Not running as Administrator

**Solutions:**

1. Run Command Prompt as Administrator
2. Check Windows Firewall rules
3. Temporarily disable anti-virus for testing
4. Install Npcap instead of WinPcap

```powershell
# Check if running as Administrator
net session  # Should not return error

# If not, restart as Administrator
# Right-click PowerShell/CMD -> Run as Administrator
```

---

## Packet Sending Issues

### Issue: Packets Not Being Sent

**Symptoms:**
- No packets appear in Wireshark
- `send()` returns without error

**Causes:**
- Wrong interface selected
- Packets filtered by system
- Loopback interface limitations

**Solutions:**

```python
from scapy.all import send, IP, ICMP, conf

# Check current interface
print(conf.iface)

# List available interfaces
from scapy.all import get_if_list
print(get_if_list())

# Specify interface explicitly
send(IP(dst="8.8.8.8")/ICMP(), iface="eth0")

# Use loopback for testing
send(IP(dst="127.0.0.1")/ICMP(), iface="lo")
```

---

### Issue: No Response to Packets

**Symptoms:**
- `sr1()` returns None
- No replies captured

**Causes:**
- Packet not reaching destination
- Destination not responding
- Firewall blocking replies
- Timeout too short

**Solutions:**

```python
# Increase timeout
reply = sr1(packet, timeout=5)

# Increase verbosity
reply = sr1(packet, timeout=3, verbose=True)

# Check destination is reachable
import subprocess
subprocess.call(['ping', '-c', '1', '8.8.8.8'])

# Use sr() for multiple attempts
answers, unanswered = sr(packet, timeout=3, retry=2)
```

---

### Issue: Checksum Errors

**Symptoms:**
- Wireshark shows checksum errors
- Packets not accepted by target

**Causes:**
- Scapy didn't calculate checksums
- Checksums corrupted during manipulation

**Solutions:**

```python
# Use show2() to calculate checksums
packet.show2()

# Force checksum recalculation
del packet[TCP].chksum
del packet[IP].chksum

# Or use send() which auto-calculates
send(packet)

# Manually fix checksums
from scapy.all import checksum
packet[IP].chksum = checksum(bytes(packet[IP]))
```

---

### Issue: Wrong Interface or IP

**Symptoms:**
- Packets go to wrong network
- Source IP incorrect

**Solutions:**

```python
from scapy.all import get_if_addr, get_if_hwaddr

# Get correct interface IP
local_ip = get_if_addr("eth0")
local_mac = get_if_hwaddr("eth0")

# Build packet with correct source
packet = IP(src=local_ip, dst="8.8.8.8") / ICMP()

# Check routing
import socket
def get_default_gateway():
    # Linux: route -n, Windows: route print
    pass
```

---

## Packet Capture Issues

### Issue: Sniff() Not Capturing Packets

**Symptoms:**
- `sniff()` returns empty list
- No packets shown

**Causes:**
- Wrong interface
- Filter too restrictive
- Promiscuous mode not enabled
- Low traffic

**Solutions:**

```python
# Use correct interface
sniff(iface="eth0", count=10)

# Test with no filter
sniff(count=10)

# Use longer timeout
packets = sniff(timeout=10)

# Check interface traffic
import subprocess
subprocess.call(['tcpdump', '-i', 'eth0', '-c', '10'])

# Use verbose mode
sniff(count=5, verbose=True)
```

---

### Issue: Sniff() Drops Packets

**Symptoms:**
- Dropped packet warnings
- Count mismatch in Wireshark vs Scapy

**Causes:**
- High traffic volume
- Slow callback processing
- Buffer overflow

**Solutions:**

```python
# Increase buffer size
sniff(count=1000, buffer_size=10000)

# Optimize callback
def fast_callback(packet):
    # Minimal processing
    print(packet.summary())

# Use store=False for capture only
sniff(prn=process, store=False)

# Use BPF filter to reduce volume
sniff(filter="tcp port 80", count=1000)
```

---

### Issue: BPF Filter Not Working

**Symptoms:**
- No packets with filter
- Filter syntax errors

**Causes:**
- Incorrect filter syntax
- Filter too specific
- Interface not supporting BPF

**Solutions:**

```python
# Test with simple filter first
sniff(filter="tcp", count=10)

# Check filter syntax
try:
    sniff(filter="tcp port 80", count=1, timeout=1)
except Exception as e:
    print(f"Filter error: {e}")

# Common filters with correct syntax
filters = [
    "tcp",                           # TCP packets
    "udp port 53",                   # DNS
    "host 8.8.8.8",                  # Specific IP
    "net 192.168.0.0/16",            # Network
    "tcp[13] & 0x02 != 0",          # SYN packets
]

# Debug BPF
from scapy.all import conf
conf.debug_dissector = True
sniff(filter="tcp port 80", count=1)
```

---

## PCAP Issues

### Issue: Cannot Read PCAP File

**Symptoms:**
```
FileNotFoundError: [Errno 2] No such file or directory: 'capture.pcap'
```

**Causes:**
- File doesn't exist
- Wrong path
- File permissions

**Solutions:**

```python
import os

# Check file exists
pcap_file = "capture.pcap"
if not os.path.exists(pcap_file):
    print(f"File not found: {pcap_file}")
    print(f"Current directory: {os.getcwd()}")

# Use absolute path
pcap_file = "/home/user/captures/capture.pcap"

# Check permissions
if os.path.exists(pcap_file):
    print(f"Readable: {os.access(pcap_file, os.R_OK)}")
```

---

### Issue: Corrupted PCAP File

**Symptoms:**
- `rdpcap()` raises exceptions
- Incomplete packet list

**Causes:**
- File corruption
- Incomplete download
- File format mismatch

**Solutions:**

```python
# Try PcapReader (more robust)
from scapy.utils import PcapReader
try:
    with PcapReader("corrupt.pcap") as reader:
        packets = list(reader)
except Exception as e:
    print(f"Error reading: {e}")

# Use tcpdump to repair/convert
# tcpdump -r corrupt.pcap -w repaired.pcap

# Try different PCAP format
from scapy.utils import PcapNgReader
with PcapNgReader("capture.pcapng") as reader:
    packets = list(reader)
```

---

### Issue: PCAP Too Large

**Symptoms:**
- MemoryError
- Slow processing
- System hangs

**Solutions:**

```python
# Use streaming reader
from scapy.utils import PcapReader

def process_large_pcap(filename):
    with PcapReader(filename) as reader:
        for packet in reader:
            # Process one packet at a time
            process(packet)

# Use chunking
packets = rdpcap(filename)
chunk_size = 1000
for i in range(0, len(packets), chunk_size):
    chunk = packets[i:i+chunk_size]
    process_chunk(chunk)
```

---

## Protocol Issues

### Issue: TCP Handshake Not Completing

**Symptoms:**
- No SYN-ACK response
- RST received instead of ACK

**Causes:**
- Port not open
- Firewall blocking
- Application not listening

**Solutions:**

```python
# Verify port is open
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
result = sock.connect_ex(('8.8.8.8', 80))
if result == 0:
    print("Port 80 is open")
else:
    print(f"Port 80 is closed (error: {result})")

# Use correct sequence numbers
tcp = TCP(sport=12345, dport=80, flags="S", seq=1000)
reply = sr1(IP(dst="8.8.8.8")/tcp, timeout=3)

if reply and reply.haslayer(TCP):
    # Extract correct sequence for ACK
    ack = TCP(sport=12345, dport=80, flags="A",
              seq=1001, ack=reply[TCP].seq + 1)
    send(IP(dst="8.8.8.8")/ack)
```

---

### Issue: UDP Packets Not Reaching Target

**Symptoms:**
- No response to UDP packets
- ICMP Port Unreachable

**Causes:**
- Port not open
- UDP filtering
- NAT/firewall blocking

**Solutions:**

```python
# Check for ICMP unreachable
reply = sr1(IP(dst="8.8.8.8")/UDP(dport=53), timeout=3)
if reply and reply.haslayer(ICMP):
    icmp_type = reply[ICMP].type
    if icmp_type == 3 and reply[ICMP].code == 3:
        print("Port is unreachable")

# Use different port
packet = IP(dst="8.8.8.8")/UDP(dport=33434)

# Check UDP connectivity
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.settimeout(2)
try:
    sock.sendto(b"test", ("8.8.8.8", 53))
    sock.recvfrom(1024)
    print("UDP communication successful")
except socket.timeout:
    print("UDP request timed out")
```

---

### Issue: ICMP Packets Blocked

**Symptoms:**
- No ping responses
- ICMP errors not received

**Causes:**
- ICMP disabled
- Firewall blocking
- Router filters

**Solutions:**

```python
# Test with different ICMP types
packets = [
    ICMP(type=8, code=0),   # Echo Request
    ICMP(type=13, code=0),  # Timestamp Request
    ICMP(type=17, code=0),  # Address Mask Request
]

for icmp in packets:
    reply = sr1(IP(dst="8.8.8.8")/icmp, timeout=2)
    if reply:
        print(f"Type {icmp.type}: Response received")

# Check system ICMP settings
# Linux: sysctl net.ipv4.icmp_echo_ignore_all
# Windows: Check Windows Firewall
```

---

## Performance Issues

### Issue: Slow Packet Processing

**Symptoms:**
- Processing lags behind capture
- High CPU usage

**Causes:**
- Inefficient callbacks
- Synchronous processing
- No filtering

**Solutions:**

```python
# Use BPF filter at kernel level
sniff(filter="tcp port 80", prn=process)

# Optimize callback
def fast_process(packet):
    # Only essential operations
    if packet.haslayer(TCP):
        tcp = packet[TCP]
        print(f"Port: {tcp.dport}")

# Use store=False
sniff(prn=process, store=False)

# Batch processing
packets = []
def batch_process(packet):
    packets.append(packet)
    if len(packets) >= 100:
        process_batch(packets)
        packets.clear()

# Multi-threading
import threading
queue = []
def worker():
    while True:
        if queue:
            packet = queue.pop()
            process(packet)
```

---

### Issue: Memory Usage Too High

**Symptoms:**
- MemoryError
- System slowdown

**Causes:**
- Storing all packets
- Memory leaks in callbacks
- Large PCAPs

**Solutions:**

```python
# Don't store all packets
sniff(prn=process, store=False)

# Use deque for limited storage
from collections import deque
packets = deque(maxlen=1000)

# Clear packet references
def process(packet):
    # Process packet
    del packet  # Explicit cleanup

# Use generator
from scapy.utils import PcapReader
def packet_generator(filename):
    with PcapReader(filename) as reader:
        for packet in reader:
            yield packet

for packet in packet_generator("large.pcap"):
    process(packet)
```

---

## Custom Protocol Issues

### Issue: Custom Protocol Not Recognized

**Symptoms:**
- Packets not dissected
- Raw payload instead of custom layer

**Causes:**
- Missing bindings
- Incorrect field definitions
- Payload not handled

**Solutions:**

```python
# Add binding
bind_layers(IP, MyProtocol, proto=250)

# Check fields
class MyProtocol(Packet):
    fields_desc = [
        ByteField("version", 1),
        # ... other fields
    ]

# Handle payload
class MyProtocol(Packet):
    fields_desc = [...]
    
    def guess_payload_class(self, payload):
        if payload.startswith(b'\x00'):
            return MyPayload
        return Raw

# Test binding
pkt = IP(proto=250) / MyProtocol()
assert pkt.haslayer(MyProtocol)
```

---

### Issue: Field Values Not Saving

**Symptoms:**
- Values reset to defaults
- Fields not persistent

**Causes:**
- Incorrect field definitions
- Field not included in fields_desc

**Solutions:**

```python
# Correct field definition
class MyProtocol(Packet):
    fields_desc = [
        ByteField("version", 1),      # Default value 1
        ByteField("type", 0),         # Default value 0
        ShortField("length", 0),      # Default value 0
    ]

# Create with values
pkt = MyProtocol(version=2, type=5)

# Verify
print(f"Version: {pkt.version}")
print(f"Type: {pkt.type}")

# Field types must match
ByteField("value", 0)     # 0-255
ShortField("value", 0)    # 0-65535
IntField("value", 0)      # 0-4294967295
```

---

### Issue: Protocol Not Binding Correctly

**Symptoms:**
- Wrong layer order
- Dissection fails

**Solutions:**

```python
# Check binding order
bind_layers(IP, MyProtocol, proto=250)
bind_layers(MyProtocol, MyPayload, type=1)

# Verify binding
pkt = IP(proto=250) / MyProtocol(type=1) / MyPayload()
assert pkt.haslayer(IP)
assert pkt.haslayer(MyProtocol)
assert pkt.haslayer(MyPayload)

# Remove incorrect bindings
unbind_layers(IP, MyProtocol)

# Use multiple bindings
bind_layers(IP, MyProtocol, proto=250)
bind_layers(IP, MyProtocol, proto=251)  # Different protocol number
```

---

## System-Specific Issues

### Linux Issues

**Issue: Missing Capabilities**

```bash
# Grant capabilities to Python
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/python3

# Or use environment
sudo python3 script.py

# Check capabilities
getcap /usr/bin/python3
```

---

**Issue: Interface Not Found**

```bash
# List interfaces
ip link show
ifconfig -a

# Check interface name
from scapy.all import get_if_list
print(get_if_list())
```

---

### Windows Issues

**Issue: WinPcap/Npcap Not Installed**

```bash
# Download Npcap
# https://npcap.com/

# Install with "Install in WinPcap API-compatible Mode"
# Required for Scapy compatibility
```

---

**Issue: Windows Firewall Blocking**

```powershell
# Add firewall rule (Administrator)
netsh advfirewall firewall add rule name="Scapy" dir=in action=allow program="C:\Python39\python.exe"

# Or temporarily disable
netsh advfirewall set allprofiles state off

# Check firewall status
netsh advfirewall show allprofiles
```

---

### macOS Issues

**Issue: Permission Denied**

```bash
# Grant permission in System Preferences
# Security & Privacy -> Privacy -> Full Disk Access

# Use sudo
sudo python3 script.py

# Or grant network access
sudo /usr/sbin/devp
```

---

## Debugging Techniques

### Enable Verbose Mode

```python
from scapy.all import conf

# Enable verbose output
conf.verbose = True

# Send with verbose
send(packet, verbose=True)

# Sniff with verbose
sniff(count=10, verbose=True)

# Check default settings
print(conf.verbose)
```

---

### Debug Packet Construction

```python
# Show packet details
packet.show()
packet.show2()

# Hex dump
hexdump(packet)

# Raw bytes
print(bytes(packet))

# Packet summary
print(packet.summary())

# Layer access
if packet.haslayer(TCP):
    print(packet[TCP].flags)
```

---

### Debug Send/Receive

```python
# Use verbose mode
reply = sr1(packet, verbose=True)

# Check sent packets
sent, received = srp(packet, verbose=True)
print(f"Sent: {len(sent)}")
print(f"Received: {len(received)}")

# Debug timeout
reply = sr1(packet, timeout=3)
if reply is None:
    print("No response received")

# Check for errors
try:
    send(packet)
except Exception as e:
    print(f"Error sending: {e}")
```

---

### Debug PCAP Reading

```python
# Check file exists
import os
if not os.path.exists(pcap_file):
    print(f"File not found: {pcap_file}")

# Get file size
print(f"Size: {os.path.getsize(pcap_file)} bytes")

# Try reading with try/except
try:
    packets = rdpcap(pcap_file)
except Exception as e:
    print(f"Error reading: {e}")
    # Try alternative method
    from scapy.utils import PcapReader
    with PcapReader(pcap_file) as reader:
        packets = list(reader)

# Check packet count
print(f"Packets: {len(packets)}")
```

---

### Debug Custom Protocols

```python
# Verify field definitions
class MyProtocol(Packet):
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
    ]

# Test creation
pkt = MyProtocol(version=2, type=5)
print(pkt.summary())
pkt.show()

# Test dissection
raw = bytes(pkt)
dissected = MyProtocol(raw)
print(dissected.summary())
assert dissected.version == 2
assert dissected.type == 5

# Check binding
bind_layers(IP, MyProtocol, proto=250)
pkt = IP(proto=250) / MyProtocol()
assert pkt.haslayer(MyProtocol)
```

---

### Debug Performance

```python
import time

# Time packet processing
start = time.time()
for packet in packets:
    process(packet)
elapsed = time.time() - start
print(f"Processed {len(packets)} packets in {elapsed:.2f}s")
print(f"Rate: {len(packets)/elapsed:.1f} pkts/s")

# Profile code
import cProfile
cProfile.run('process_large_pcap("large.pcap")')

# Check memory usage
import psutil
process = psutil.Process()
print(f"Memory: {process.memory_info().rss / 1024 / 1024:.1f} MB")
```

---

### Common Error Messages

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| `Permission denied` | Root/admin required | Use sudo or Administrator |
| `No module named 'scapy'` | Scapy not installed | pip install scapy[complete] |
| `No response` | Timeout or filtering | Increase timeout, check filters |
| `Invalid IP address` | Malformed address | Verify IP format |
| `Network is unreachable` | Interface down | Check interface connectivity |
| `Checksum error` | Invalid checksum | Use show2() or recalculate |
| `Buffer overflow` | Too many packets | Increase buffer or filter |
| `Cannot find interface` | Interface doesn't exist | Check interface name |
| `BPF filter error` | Invalid filter syntax | Check filter syntax |
| `PCAP file corrupted` | File corruption | Use PcapReader or repair |

---

## Appendix E Complete

This troubleshooting guide covers common issues and solutions for working with Scapy. For additional help:

- **Scapy Mailing List:** [https://groups.google.com/g/scapy](https://groups.google.com/g/scapy)
- **Scapy GitHub Issues:** [https://github.com/secdev/scapy/issues](https://github.com/secdev/scapy/issues)
- **Stack Overflow:** [https://stackoverflow.com/questions/tagged/scapy](https://stackoverflow.com/questions/tagged/scapy)

---

```
─────────────────────────────────────────────────────────────────────────
│  APPENDIX E: TROUBLESHOOTING GUIDE COMPLETE                         │
│                                                                     │
│  This appendix covers:                                             │
│  ✅ Installation issues                                            │
│  ✅ Permission issues                                              │
│  ✅ Packet sending issues                                          │
│  ✅ Packet capture issues                                          │
│  ✅ PCAP issues                                                    │
│  ✅ Protocol issues                                                │
│  ✅ Performance issues                                             │
│  ✅ Custom protocol issues                                         │
│  ✅ System-specific issues                                         │
│  ✅ Debugging techniques                                           │
│                                                                     │
│  END OF APPENDICES                                                 │
└─────────────────────────────────────────────────────────────────────────
```

xx
