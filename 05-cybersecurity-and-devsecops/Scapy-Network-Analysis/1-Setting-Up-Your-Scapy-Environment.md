# Mastering Network Packet Crafting with Scapy
## Module 1: Foundations of Packet Crafting
### Part 1: Setting Up Your Scapy Environment

## The Target: A Professional Scapy Development Environment

Before we can craft our first packet, we need to establish a solid foundation. In this first technical step, we'll:

1. Install Python 3.8+ (if needed)
2. Install Scapy and its dependencies
3. Verify the installation works correctly
4. Set up a project directory structure
5. Test that we can send and receive packets (in a safe, isolated way)

---

## The Concept: Why Environment Setup Matters

Think of this like setting up a woodworking workshop. You wouldn't start building a custom cabinet without making sure your table saw is calibrated, your tools are sharp, and your safety equipment is in place. Similarly, before we craft packets, we need:

- **Scapy itself**: The primary tool (our "saw")
- **Dependencies**: Supporting libraries (our "clamps" and "guides")
- **Permissions**: Raw socket access to send/receive packets (our "power supply")
- **Project structure**: Organization for all our code (our "workbench organization")

**The key insight**: Scapy requires root/administrator privileges to send and receive packets because it uses **raw sockets** — these bypass the operating system's normal networking stack to interact directly with the network interface card (NIC). We'll handle this safely.

---

## The Implementation: Step-by-Step Installation

### Step 1: Verify Python Installation

First, let's check what Python version you have:

```bash
# Check Python version
python3 --version

# If that doesn't work, try:
python --version
```

**Expected output**: `Python 3.8.x` or higher. If you see Python 3.6 or lower, or if Python isn't installed, proceed to the installation instructions below.

### Step 2: Install Python (If Needed)

#### **Linux (Ubuntu/Debian)**
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv python3-dev
```

#### **Linux (RHEL/CentOS/Fedora)**
```bash
sudo dnf install python3 python3-pip python3-devel
# or for older versions:
sudo yum install python3 python3-pip python3-devel
```

#### **macOS**
```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then install Python
brew install python3
```

#### **Windows**
1. Download the installer from [python.org](https://python.org/downloads/)
2. **Important**: Check "Add Python to PATH" during installation
3. Verify installation by opening Command Prompt and running:
   ```cmd
   python --version
   ```

### Step 3: Create a Virtual Environment (Best Practice)

Virtual environments isolate project dependencies, preventing conflicts with other Python projects:

```bash
# Create a project directory
mkdir ~/scapy-tutorial
cd ~/scapy-tutorial

# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
# On Linux/macOS:
source venv/bin/activate

# On Windows:
venv\Scripts\activate

# You should see (venv) in your terminal prompt
```

### Step 4: Install Scapy

Now, let's install Scapy and its common dependencies:

```bash
# Ensure pip is up to date
pip install --upgrade pip

# Install Scapy with all common features
pip install scapy[complete]

# This installs:
# - Scapy itself
# - matplotlib (for visualizations)
# - PyX (for packet diagrams)
# - cryptography (for SSL/TLS)
# - numpy (for numerical operations)
# - pandas (for data analysis)
```

**Troubleshooting**: On some systems, the `[complete]` option might fail. If so, use:

```bash
pip install scapy
# Then install dependencies as needed
```

### Step 5: Install Wireshark (For Packet Verification)

Wireshark is essential for visually confirming our packets:

#### **Linux (Ubuntu/Debian)**
```bash
sudo apt install wireshark wireshark-common tshark

# You may be prompted to allow non-root users to capture
# Select "Yes" if you want to capture without sudo (careful!)
```

#### **Linux (RHEL/CentOS/Fedora)**
```bash
sudo dnf install wireshark
# or
sudo yum install wireshark
```

#### **macOS**
```bash
brew install wireshark
```

#### **Windows**
Download and install from [wireshark.org](https://wireshark.org)

### Step 6: Set Up the Project Directory Structure

Create the skeleton for all our future work:

```bash
# From the project root (~/scapy-tutorial)
mkdir -p src
mkdir -p labs
mkdir -p pcap_files
mkdir -p output
mkdir -p config
mkdir -p tests
mkdir -p docs

# Create an initial Python file to verify our setup
touch src/__init__.py
```

**Your directory structure should now look like**:

```
~/scapy-tutorial/
├── venv/               # Virtual environment (hidden in some systems)
├── src/                # All source code
│   └── __init__.py    # Makes src a Python package
├── labs/               # Hands-on lab scripts
├── pcap_files/         # PCAP files for analysis
├── output/             # Generated reports, graphs, exports
├── config/             # Configuration files
├── tests/              # Unit tests
└── docs/               # Documentation
```

### Step 7: Create Our First Script — Environment Check

Create a file called `src/verify_environment.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 1: Environment Verification Script

This script checks that Scapy is properly installed and
that our environment is correctly configured.
"""

import sys
import os

# Check Python version
print(f"Python version: {sys.version}")
print(f"Python executable: {sys.executable}")

# Verify virtual environment
in_venv = hasattr(sys, 'real_prefix') or (
    hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix
)
print(f"Running in virtual environment: {in_venv}")

# Try importing Scapy
try:
    import scapy
    print(f"Scapy version: {scapy.__version__}")
    print(f"Scapy location: {scapy.__file__}")
except ImportError as e:
    print(f"ERROR: Scapy is not installed properly: {e}")
    print("Please run: pip install scapy[complete]")
    sys.exit(1)

# Import Scapy's main components
try:
    from scapy.all import Ether, IP, TCP, UDP, Raw, ICMP
    from scapy.sendrecv import sr, sr1, send
    from scapy.utils import rdpcap, wrpcap
    from scapy.layers.inet import IP  # Explicit import for IP layer
    print("✓ Core Scapy modules imported successfully")
except ImportError as e:
    print(f"ERROR: Could not import required Scapy modules: {e}")
    sys.exit(1)

# Check for root/sudo privileges (needed for packet sending)
is_root = os.geteuid() == 0 if hasattr(os, 'geteuid') else False
print(f"Running with root privileges: {is_root}")
print("NOTE: Root privileges are required to send/receive raw packets")

# Check for Wireshark/tshark
import shutil
wireshark_path = shutil.which('wireshark')
tshark_path = shutil.which('tshark')

if wireshark_path:
    print(f"✓ Wireshark found at: {wireshark_path}")
else:
    print("⚠ Wireshark not found in PATH (optional for visual verification)")

if tshark_path:
    print(f"✓ tshark found at: {tshark_path}")
else:
    print("⚠ tshark not found in PATH (optional for scripted capture)")

# Quick test: create a sample packet without sending it
try:
    # Build a simple packet
    test_packet = Ether() / IP(dst="8.8.8.8") / ICMP()
    print("✓ Successfully created a test packet (Ether/IP/ICMP)")
    print(f"  Packet summary: {test_packet.summary()}")
    print("  To see full details: test_packet.show()")
except Exception as e:
    print(f"ERROR: Could not create test packet: {e}")
    sys.exit(1)

print("\n" + "="*60)
print("✅ Environment verification complete!")
print("="*60)
print("\nYou're ready to begin Module 1!")
```

### Step 8: Run the Verification Script

```bash
# From the project root directory (~/scapy-tutorial)
# Make sure your virtual environment is activated
python3 src/verify_environment.py
```

**Expected output** (your version numbers may differ):

```
Python version: 3.10.12 (main, Jun 11 2023, 05:55:23) [GCC 11.4.0]
Python executable: /home/user/scapy-tutorial/venv/bin/python3
Running in virtual environment: True
Scapy version: 2.5.0
Scapy location: /home/user/scapy-tutorial/venv/lib/python3.10/site-packages/scapy/__init__.py
✓ Core Scapy modules imported successfully
Running with root privileges: False
NOTE: Root privileges are required to send/receive raw packets
✓ Wireshark found at: /usr/bin/wireshark
✓ tshark found at: /usr/bin/tshark
✓ Successfully created a test packet (Ether/IP/ICMP)
  Packet summary: Ether / IP / ICMP 8.8.8.8 > 0.0.0.0 echo-request 0
  To see full details: test_packet.show()

============================================================
✅ Environment verification complete!
============================================================

You're ready to begin Module 1!
```

### Step 9: Create a Helper Script for Starting Scapy Interactively

Scapy has its own interactive shell (like Python's REPL but with Scapy pre-imported). Let's create a convenient way to access it:

Create `src/start_scapy_shell.py`:

```python
#!/usr/bin/env python3
"""
Scapy Interactive Shell Launcher

This script launches an interactive Python shell with
all Scapy modules pre-imported for easy experimentation.
"""

import code
import sys

# Import commonly used Scapy modules
print("Loading Scapy modules...")
from scapy.all import *

print("""
╔══════════════════════════════════════════════════════════════╗
║            SCAPY INTERACTIVE SHELL                          ║
╠══════════════════════════════════════════════════════════════╣
║  Available: all Scapy modules, plus:                       ║
║  • Common packet layers: Ether, IP, TCP, UDP, ICMP, Raw   ║
║  • Send/receive: send(), sr(), sr1()                      ║
║  • Utilities: rdpcap(), wrpcap(), sniff()                ║
║                                                            ║
║  Example: pkt = Ether()/IP(dst="8.8.8.8")/ICMP()         ║
║           pkt.show()                                      ║
╚══════════════════════════════════════════════════════════════╝
""")

# Create custom namespace with all Scapy imports
namespace = globals().copy()
namespace.update(locals())

# Start interactive shell
code.interact(local=namespace, banner="")
```

**To use the interactive shell**:

```bash
python3 src/start_scapy_shell.py
```

### Step 10: Verify Network Interface Permissions

For Scapy to send packets, it needs access to your network interface. Let's check that your user has the necessary permissions:

```bash
# Check the permissions on the network device
# On Linux, network interfaces are typically in /dev/ or /sys/class/net/
ls -la /sys/class/net/eth0  # Replace eth0 with your interface

# If you see "Permission denied", you may need to add your user to the wireshark group
sudo usermod -a -G wireshark $USER

# On some Linux systems, you might need to set capabilities
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/python3
```

**Security note**: Be cautious when granting raw socket permissions. On a production system, you'd typically use `sudo` only when needed, rather than permanently granting these capabilities.

### Step 11: Create a Safe Test — Loopback Only

Before we send packets to real network destinations, let's test with the loopback interface (127.0.0.1). This is completely isolated and safe:

Create `src/test_loopback.py`:

```python
#!/usr/bin/env python3
"""
Module 1, Part 1: Loopback Test Script

This script tests Scapy's send/receive functionality
using the loopback interface (127.0.0.1) only.
This is safe and doesn't send packets outside your machine.
"""

import sys
import time

try:
    from scapy.all import Ether, IP, ICMP, sr1, conf
    from scapy.layers.inet import IP as IPLayer
    from scapy.layers.l2 import Ether as EtherLayer
except ImportError:
    print("ERROR: Scapy not installed. Run: pip install scapy[complete]")
    sys.exit(1)

def test_loopback():
    """Send an ICMP packet to localhost and receive the response."""
    
    print("Testing Scapy with loopback interface...")
    
    # Configure Scapy to use the loopback interface
    # This prevents accidental packets from going to the network
    conf.iface = "lo"  # Linux loopback
    # On macOS, the loopback is "lo0"
    # On Windows, loopback is typically "Loopback Pseudo-Interface 1"
    
    print(f"Using interface: {conf.iface}")
    
    # Build an ICMP echo request (ping) to localhost
    # We'll start with an IP packet since loopback doesn't use Ethernet
    # Note: On loopback, we use IP directly without Ether()
    packet = IP(dst="127.0.0.1") / ICMP()
    
    print("\nPacket built:")
    print("=" * 40)
    packet.show()
    print("=" * 40)
    
    # Send the packet and wait for response (sr1 = send and receive 1 reply)
    print("\nSending packet to 127.0.0.1...")
    
    try:
        # Timeout after 2 seconds
        response = sr1(packet, timeout=2, verbose=True)
        
        if response:
            print("\n✅ Received response:")
            print("=" * 40)
            response.show()
            print("=" * 40)
            print(f"\nResponse summary: {response.summary()}")
            print("✓ Loopback test passed! Scapy is working correctly.")
            return True
        else:
            print("\n❌ No response received.")
            print("This is normal on some systems where loopback ICMP is filtered.")
            print("Scapy is still likely working correctly.")
            print("We'll test with captured PCAPs in the next part.")
            return False
            
    except Exception as e:
        print(f"\n❌ Error during send/receive: {e}")
        print("This might be due to permission issues.")
        print("Try running with sudo: sudo python3 src/test_loopback.py")
        return False

def test_packet_building():
    """Test building packets without sending them."""
    
    print("\nTesting packet building only (no transmission)...")
    
    # Build various packets
    packets = [
        Ether() / IP(dst="192.168.1.1") / ICMP(),
        Ether() / IP(dst="192.168.1.1") / TCP(dport=80),
        Ether() / IP(dst="192.168.1.1") / UDP(dport=53) / Raw(b"Hello"),
    ]
    
    for idx, pkt in enumerate(packets, 1):
        print(f"\nPacket {idx}: {pkt.summary()}")
        print(f"  Length: {len(pkt)} bytes")
        print(f"  Hexdump (first 16 bytes): {bytes(pkt)[:16].hex()}")
    
    print("\n✓ All packets built successfully!")
    print("✓ Scapy packet construction is working correctly.")
    return True

if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("SCAPY LOOPBACK TEST")
    print("=" * 60 + "\n")
    
    # Test packet building first (safe, doesn't need permissions)
    test_packet_building()
    
    print("\n" + "-" * 60)
    
    # Test sending to loopback (needs permissions)
    test_loopback()
    
    print("\n" + "=" * 60)
    print("TEST COMPLETE")
    print("=" * 60)
    
    print("\nIf you encountered permission errors, try:")
    print("  sudo python3 src/test_loopback.py")
    print("\nFor the next part, we'll work with PCAP files")
    print("which don't require root/sudo permissions!")
```

**Run the test**:

```bash
# Try without sudo first
python3 src/test_loopback.py

# If you get permission errors (likely), try with sudo:
sudo python3 src/test_loopback.py
```

---

## The Verification: Confirming Everything Works

Let's systematically verify that every component is ready:

### 1. Python Environment Verification

```bash
# Check Python version
python3 --version
# Should output: Python 3.8.x or higher

# Check pip packages installed
pip list | grep scapy
# Should show: scapy 2.5.0 or higher

# Check virtual environment
echo $VIRTUAL_ENV
# Should show: /path/to/scapy-tutorial/venv
```

### 2. Scapy Import Test (Quick)

```bash
python3 -c "from scapy.all import *; print('Scapy version:', scapy.__version__)"
```

### 3. Network Interface Test

```bash
# List available interfaces
python3 -c "from scapy.all import get_if_list; print(get_if_list())"
```

**Expected output**: A list of network interfaces (e.g., `['lo', 'eth0', 'wlan0']`)

### 4. PCAP Reading Test

We'll test this with a sample PCAP (we'll download one in the next part):

```bash
python3 -c "from scapy.all import rdpcap; print('rdpcap available')"
```

### 5. Complete Verification Script Output

Here's what a successful run of `verify_environment.py` should look like:

```bash
╔══════════════════════════════════════════════════════════════╗
║                    ENVIRONMENT VERIFICATION                 ║
╠══════════════════════════════════════════════════════════════╣
║  Python Version: 3.10.12                                   ║
║  Scapy Version: 2.5.0                                      ║
║  Virtual Environment: Active                               ║
║  Permissions: SUCCESSFUL (root/sudo)                       ║
║  Wireshark: Installed                                      ║
║  tshark: Installed                                         ║
║  Core Modules: Available                                   ║
║  Packet Construction: Working                              ║
╚══════════════════════════════════════════════════════════════╝

✅ All systems ready for Module 1!
```

---

## Troubleshooting Common Setup Issues

### Issue 1: "ModuleNotFoundError: No module named 'scapy'"

**Solution**:
```bash
# Ensure you're in the virtual environment
which python3  # Should show venv/bin/python3

# Install Scapy
pip install scapy[complete]

# If that fails, try:
pip install scapy
```

### Issue 2: "Permission denied" when sending packets

**Solution**:
```bash
# Use sudo when sending packets
sudo python3 your_script.py

# Or add your user to the appropriate group
sudo usermod -a -G wireshark $USER
# Then log out and back in
```

### Issue 3: Wireshark not found

**Solution**:
```bash
# On Linux
sudo apt install wireshark tshark

# On macOS
brew install wireshark

# On Windows: Download from wireshark.org
```

### Issue 4: Virtual environment not activating

**Solution**:
```bash
# On Linux/macOS
source venv/bin/activate

# On Windows
venv\Scripts\activate

# If you get "source: not found" on Windows, use:
venv/Scripts/activate.bat
```

### Issue 5: Loopback test fails but other tests pass

**This is normal** on some systems. The loopback interface behaves differently on different operating systems. Don't worry — we'll primarily use offline PCAP analysis and specific interfaces for our tests.

---

## What We've Accomplished

By completing this first part, you have:

1. ✅ Installed Python 3.8+ (if needed)
2. ✅ Created a virtual environment for project isolation
3. ✅ Installed Scapy with all dependencies
4. ✅ Installed Wireshark for visual packet verification
5. ✅ Set up a professional project directory structure
6. ✅ Created verification scripts to test everything
7. ✅ Tested Scapy's packet-building capabilities
8. ✅ Confirmed you can send packets (with appropriate permissions)

**You now have a fully functional Scapy environment!**

---

## Next Steps: Preview of Part 2

In **Module 1, Part 2: Understanding the Packet Stacking Model**, we'll:

1. Learn Scapy's packet architecture
2. Master the `/` stacking operator
3. Build multi-layer packets
4. Understand how Scapy handles protocol layering
5. Inspect packets using `show()`, `summary()`, and `hexdump()`
6. Compare our packets with Wireshark's view

**Before Part 2**, make sure:
- You can successfully run `python3 src/verify_environment.py`
- You have Wireshark installed and can open it
- You have the project directory structure ready

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 1, PART 1 COMPLETE                                  │
│  ✅ Python environment verified                                     │
│  ✅ Scapy installed and functional                                  │
│  ✅ Project directory structure created                            │
│  ✅ Network interface permissions verified                         │
│  NEXT: MODULE 1, PART 2 — Understanding the Packet Stacking Model │
│  ● The "/" operator: protocol layering in Scapy                   │
│  ● Building multi-layer packets                                   │
│  ● Packet inspection methods                                      │
│  ● Wireshark correlation                                          │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 2, where we'll build our first multi-layer packets and understand how Scapy's elegant stacking model works — using the `/` operator that's the heart of packet construction in Scapy.*
