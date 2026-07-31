# Primer 1: Python Network Programming Fundamentals

## P1.1 Introduction to Network Programming

### What is Network Programming?

Network programming is the practice of writing software that communicates across computer networks. Think of it like making phone calls between computers—your program dials a number (IP address and port), establishes a connection, and then talks (sends data) to the other end.

### Why Python for Network Programming?

Python is excellent for network programming because:
- **Simple syntax** - Write complex networking code concisely
- **Batteries included** - Built-in socket library
- **Rich ecosystem** - Libraries for every protocol (requests, paramiko, scapy)
- **Cross-platform** - Works on Windows, Linux, macOS
- **Rapid prototyping** - Test ideas quickly

---

## P1.2 Socket Programming Basics

### What is a Socket?

A socket is like a telephone line - it's the endpoint for communication between two programs. Think of:
- **IP Address** = Phone number
- **Port** = Extension number
- **Socket** = The active phone call

### Creating a Socket

```python
import socket

# Create a TCP socket
tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Create a UDP socket
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Create a Unix domain socket (local IPC)
unix_socket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
```

### Socket Address Family

```python
# IPv4
socket.AF_INET

# IPv6
socket.AF_INET6

# Unix domain (local communication)
socket.AF_UNIX

# Bluetooth
socket.AF_BLUETOOTH
```

### Socket Types

```python
# TCP - Reliable, ordered, connection-oriented
socket.SOCK_STREAM

# UDP - Unreliable, unordered, connectionless
socket.SOCK_DGRAM

# RAW - Raw IP packets (requires root)
socket.SOCK_RAW
```

---

## P1.3 TCP Client-Server Communication

### TCP Server

```python
import socket
import threading

class TCPServer:
    """Simple TCP server implementation."""
    
    def __init__(self, host='localhost', port=8888):
        self.host = host
        self.port = port
        self.socket = None
        self.clients = []
        self.running = False
    
    def start(self):
        """Start the TCP server."""
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.socket.bind((self.host, self.port))
        self.socket.listen(5)
        self.running = True
        
        print(f"Server listening on {self.host}:{self.port}")
        
        while self.running:
            try:
                client_socket, address = self.socket.accept()
                print(f"Connection from {address}")
                
                # Handle client in new thread
                client_thread = threading.Thread(
                    target=self.handle_client,
                    args=(client_socket, address)
                )
                client_thread.daemon = True
                client_thread.start()
                self.clients.append(client_socket)
                
            except Exception as e:
                if self.running:
                    print(f"Server error: {e}")
                break
    
    def handle_client(self, client_socket, address):
        """Handle a client connection."""
        try:
            while True:
                # Receive data
                data = client_socket.recv(1024)
                if not data:
                    break
                
                # Decode and echo back
                message = data.decode('utf-8')
                print(f"Received from {address}: {message}")
                
                # Echo response
                response = f"Echo: {message}"
                client_socket.send(response.encode('utf-8'))
                
        except Exception as e:
            print(f"Client error: {e}")
        finally:
            client_socket.close()
            self.clients.remove(client_socket)
            print(f"Connection closed: {address}")
    
    def stop(self):
        """Stop the server."""
        self.running = False
        if self.socket:
            self.socket.close()
        
        # Close all client connections
        for client in self.clients:
            try:
                client.close()
            except:
                pass
        self.clients.clear()
        print("Server stopped")

# Usage
server = TCPServer(host='localhost', port=8888)
try:
    server.start()
except KeyboardInterrupt:
    server.stop()
```

### TCP Client

```python
import socket
import time

class TCPClient:
    """Simple TCP client implementation."""
    
    def __init__(self, host='localhost', port=8888):
        self.host = host
        self.port = port
        self.socket = None
        self.connected = False
    
    def connect(self):
        """Connect to the server."""
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.host, self.port))
            self.connected = True
            print(f"Connected to {self.host}:{self.port}")
            return True
        except Exception as e:
            print(f"Connection failed: {e}")
            return False
    
    def send(self, message):
        """Send a message to the server."""
        if not self.connected:
            raise Exception("Not connected")
        
        try:
            self.socket.send(message.encode('utf-8'))
            
            # Receive response
            data = self.socket.recv(1024)
            response = data.decode('utf-8')
            return response
            
        except Exception as e:
            print(f"Send error: {e}")
            self.connected = False
            return None
    
    def close(self):
        """Close the connection."""
        if self.socket:
            self.socket.close()
            self.connected = False
            print("Connection closed")

# Usage
client = TCPClient(host='localhost', port=8888)

if client.connect():
    # Send multiple messages
    messages = ["Hello", "World", "How are you?"]
    for msg in messages:
        response = client.send(msg)
        print(f"Server response: {response}")
        time.sleep(1)
    
    client.close()
```

### TCP Communication Example

```python
# Full example: Echo Server and Client

# server.py
import socket

def run_echo_server(host='localhost', port=8888):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind((host, port))
    server_socket.listen(5)
    
    print(f"Echo server on {host}:{port}")
    
    while True:
        client_socket, addr = server_socket.accept()
        print(f"Connection from {addr}")
        
        while True:
            data = client_socket.recv(1024)
            if not data:
                break
            
            message = data.decode('utf-8')
            print(f"Received: {message}")
            
            # Echo back
            client_socket.send(f"ECHO: {message}".encode('utf-8'))
        
        client_socket.close()
        print(f"Connection closed: {addr}")

# client.py
def run_echo_client(host='localhost', port=8888):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((host, port))
    
    print(f"Connected to {host}:{port}")
    
    while True:
        message = input("Enter message (or 'quit'): ")
        if message.lower() == 'quit':
            break
        
        client_socket.send(message.encode('utf-8'))
        response = client_socket.recv(1024).decode('utf-8')
        print(f"Response: {response}")
    
    client_socket.close()
```

---

## P1.4 UDP Communication

### UDP Server

```python
import socket

class UDPServer:
    """Simple UDP server implementation."""
    
    def __init__(self, host='localhost', port=8889):
        self.host = host
        self.port = port
        self.socket = None
        self.running = False
    
    def start(self):
        """Start the UDP server."""
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.bind((self.host, self.port))
        self.running = True
        
        print(f"UDP server listening on {self.host}:{self.port}")
        
        while self.running:
            try:
                # Receive data (up to 4096 bytes)
                data, address = self.socket.recvfrom(4096)
                message = data.decode('utf-8')
                print(f"Received from {address}: {message}")
                
                # Send response
                response = f"UDP Echo: {message}"
                self.socket.sendto(response.encode('utf-8'), address)
                
            except Exception as e:
                if self.running:
                    print(f"Server error: {e}")
    
    def stop(self):
        """Stop the server."""
        self.running = False
        if self.socket:
            self.socket.close()
        print("UDP server stopped")
```

### UDP Client

```python
import socket

class UDPClient:
    """Simple UDP client implementation."""
    
    def __init__(self, host='localhost', port=8889):
        self.host = host
        self.port = port
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    def send(self, message, timeout=2.0):
        """Send a message and wait for response."""
        self.socket.settimeout(timeout)
        
        try:
            # Send message
            self.socket.sendto(message.encode('utf-8'), (self.host, self.port))
            
            # Wait for response
            data, address = self.socket.recvfrom(4096)
            response = data.decode('utf-8')
            return response
            
        except socket.timeout:
            print("Response timeout")
            return None
        except Exception as e:
            print(f"Error: {e}")
            return None
    
    def close(self):
        """Close the socket."""
        self.socket.close()

# Usage
client = UDPClient(host='localhost', port=8889)

response = client.send("Hello UDP!")
if response:
    print(f"Response: {response}")

client.close()
```

---

## P1.5 TCP vs UDP Comparison

### TCP (Transmission Control Protocol)

**Characteristics:**
- Connection-oriented (requires handshake)
- Reliable (ensures delivery)
- Ordered (packets arrive in order)
- Flow control (prevents overwhelming receiver)
- Error checking and correction

**Use Cases:**
- HTTP/HTTPS (web browsing)
- SSH (secure shell)
- FTP (file transfer)
- SMTP (email)
- Telnet

**Visual:**
```
Client          Server
  |               |
  |----SYN------->|
  |<---SYN-ACK----|
  |----ACK------->|
  |               |
  |---DATA------->|
  |<---ACK--------|
  |<---DATA-------|
  |---ACK-------->|
  |               |
  |----FIN------->|
  |<---ACK--------|
  |<---FIN--------|
  |---ACK-------->|
```

### UDP (User Datagram Protocol)

**Characteristics:**
- Connectionless (no handshake)
- Unreliable (may lose packets)
- Unordered (packets may arrive out of order)
- No flow control
- Minimal error checking

**Use Cases:**
- DNS (domain name resolution)
- DHCP (IP address assignment)
- SNMP (network management)
- Streaming media (video/audio)
- Online gaming

**Visual:**
```
Client          Server
  |               |
  |---DATA------->|
  |               | (No ACK guaranteed)
  |<---DATA-------| (May be lost)
  |---DATA------->|
```

### Decision Matrix

| Criteria | TCP | UDP |
|----------|-----|-----|
| **Reliability** | ✅ Yes | ❌ No |
| **Ordering** | ✅ Yes | ❌ No |
| **Connection** | ✅ Yes | ❌ No |
| **Speed** | ❌ Slower | ✅ Faster |
| **Overhead** | ❌ Higher | ✅ Lower |
| **Flow Control** | ✅ Yes | ❌ No |
| **When to Use** | Reliable data transfer | Speed-critical applications |

---

## P1.6 Non-Blocking Sockets

### Blocking vs Non-Blocking

```python
import socket
import time

# Blocking socket (default)
def blocking_example():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('www.google.com', 80))  # Blocks until connected
    
    sock.send(b"GET / HTTP/1.1\r\nHost: google.com\r\n\r\n")
    
    # Blocks until data is received
    data = sock.recv(1024)
    print(f"Received {len(data)} bytes")
    
    sock.close()

# Non-blocking socket
def non_blocking_example():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setblocking(False)  # Make non-blocking
    
    try:
        sock.connect(('www.google.com', 80))
    except BlockingIOError:
        # Connection is in progress
        pass
    
    # Use select to check if socket is ready
    import select
    ready = select.select([sock], [sock], [], 5)
    
    if ready[1]:  # Socket is writable (connection established)
        sock.send(b"GET / HTTP/1.1\r\nHost: google.com\r\n\r\n")
        
        # Check if data is available
        ready = select.select([sock], [], [], 5)
        if ready[0]:  # Socket is readable
            data = sock.recv(1024)
            print(f"Received {len(data)} bytes")
    
    sock.close()

# Timeout-based blocking
def timeout_example():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)  # 5 second timeout
    
    try:
        sock.connect(('www.google.com', 80))
        sock.send(b"GET / HTTP/1.1\r\nHost: google.com\r\n\r\n")
        
        # This will timeout if no data in 5 seconds
        data = sock.recv(1024)
        print(f"Received {len(data)} bytes")
        
    except socket.timeout:
        print("Operation timed out")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sock.close()
```

### Using select for I/O Multiplexing

```python
import socket
import select
import sys

class MultiplexingServer:
    """Server using select for handling multiple clients."""
    
    def __init__(self, host='localhost', port=8888):
        self.host = host
        self.port = port
        self.server_socket = None
        self.clients = {}
        self.running = False
    
    def start(self):
        """Start the multiplexing server."""
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((self.host, self.port))
        self.server_socket.listen(5)
        self.server_socket.setblocking(False)
        self.running = True
        
        print(f"Multiplexing server on {self.host}:{self.port}")
        
        # List of sockets to monitor
        inputs = [self.server_socket]
        outputs = []
        
        while self.running:
            try:
                # Monitor sockets with select
                readable, writable, exceptional = select.select(
                    inputs, outputs, inputs, 1.0
                )
                
                # Handle readable sockets
                for sock in readable:
                    if sock is self.server_socket:
                        # New connection
                        client_socket, address = sock.accept()
                        client_socket.setblocking(False)
                        inputs.append(client_socket)
                        self.clients[client_socket.fileno()] = {
                            'socket': client_socket,
                            'address': address,
                            'data': b''
                        }
                        print(f"New connection from {address}")
                    else:
                        # Data from existing client
                        try:
                            data = sock.recv(1024)
                            if data:
                                # Store data
                                fd = sock.fileno()
                                self.clients[fd]['data'] += data
                                
                                # Check for complete message (newline)
                                if b'\n' in self.clients[fd]['data']:
                                    # Process message
                                    message = self.clients[fd]['data'].decode('utf-8')
                                    print(f"From {self.clients[fd]['address']}: {message.strip()}")
                                    
                                    # Echo back
                                    response = f"Echo: {message}"
                                    sock.send(response.encode('utf-8'))
                                    
                                    # Clear buffer
                                    self.clients[fd]['data'] = b''
                            else:
                                # Connection closed
                                self._remove_client(sock)
                        except Exception as e:
                            print(f"Error reading from client: {e}")
                            self._remove_client(sock)
                
                # Handle exceptional sockets
                for sock in exceptional:
                    self._remove_client(sock)
                    
            except KeyboardInterrupt:
                break
            except Exception as e:
                print(f"Server error: {e}")
        
        self.stop()
    
    def _remove_client(self, sock):
        """Remove a client connection."""
        if sock.fileno() in self.clients:
            address = self.clients[sock.fileno()]['address']
            del self.clients[sock.fileno()]
            sock.close()
            print(f"Connection closed: {address}")
    
    def stop(self):
        """Stop the server."""
        self.running = False
        if self.server_socket:
            self.server_socket.close()
        
        # Close all client connections
        for fd, client in self.clients.items():
            try:
                client['socket'].close()
            except:
                pass
        self.clients.clear()
        print("Server stopped")
```

---

## P1.7 Common Network Utilities

### Port Scanner

```python
import socket
import threading
import time

class PortScanner:
    """Simple port scanner implementation."""
    
    def __init__(self, target, timeout=2.0):
        self.target = target
        self.timeout = timeout
        self.open_ports = []
        self.closed_ports = []
        self.filtered_ports = []
    
    def scan_port(self, port):
        """Scan a single port."""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            result = sock.connect_ex((self.target, port))
            
            if result == 0:
                self.open_ports.append(port)
                print(f"Port {port}: Open")
            elif result == 111:
                self.filtered_ports.append(port)
            else:
                self.closed_ports.append(port)
            
            sock.close()
            
        except Exception as e:
            self.filtered_ports.append(port)
    
    def scan_range(self, start_port=1, end_port=1024, threads=50):
        """Scan a range of ports using multiple threads."""
        print(f"Scanning {self.target} from {start_port} to {end_port}")
        start_time = time.time()
        
        # Create thread pool
        thread_pool = []
        ports = range(start_port, end_port + 1)
        
        for port in ports:
            thread = threading.Thread(target=self.scan_port, args=(port,))
            thread.daemon = True
            thread_pool.append(thread)
            thread.start()
            
            # Limit concurrent threads
            if len(thread_pool) >= threads:
                for t in thread_pool:
                    t.join()
                thread_pool = []
        
        # Wait for remaining threads
        for thread in thread_pool:
            thread.join()
        
        elapsed = time.time() - start_time
        print(f"\nScan complete in {elapsed:.2f} seconds")
        print(f"Open ports: {len(self.open_ports)}")
        print(f"Closed ports: {len(self.closed_ports)}")
        print(f"Filtered ports: {len(self.filtered_ports)}")
        print(f"Open ports: {sorted(self.open_ports)}")

# Usage
scanner = PortScanner('localhost')
scanner.scan_range(1, 100, threads=20)
```

### Network Scanner (ARP-based)

```python
import socket
import struct
import time

class NetworkScanner:
    """Simple network scanner using ARP requests."""
    
    def __init__(self, interface=None):
        self.interface = interface
        
    def get_local_network(self):
        """Get the local network address."""
        import netifaces
        
        if self.interface:
            addrs = netifaces.ifaddresses(self.interface)
        else:
            # Get default interface
            default = netifaces.gateways()['default']
            addrs = netifaces.ifaddresses(default[1])
        
        ip = addrs[netifaces.AF_INET][0]['addr']
        netmask = addrs[netifaces.AF_INET][0]['netmask']
        
        # Calculate network address
        ip_parts = ip.split('.')
        mask_parts = netmask.split('.')
        
        network = '.'.join([str(int(ip_parts[i]) & int(mask_parts[i])) 
                           for i in range(4)])
        
        return network, netmask
    
    def scan_network(self):
        """Scan the local network using ARP."""
        import subprocess
        
        network, netmask = self.get_local_network()
        print(f"Scanning network: {network}/{netmask}")
        
        # Use arp-scan if available
        try:
            result = subprocess.run(
                ['arp-scan', '--local', '--interface', self.interface or ''],
                capture_output=True,
                text=True
            )
            
            hosts = []
            for line in result.stdout.split('\n'):
                if line and '\t' in line:
                    parts = line.split('\t')
                    if len(parts) >= 3:
                        hosts.append({
                            'ip': parts[0].strip(),
                            'mac': parts[1].strip(),
                            'vendor': parts[2].strip()
                        })
            
            return hosts
        except FileNotFoundError:
            print("arp-scan not found. Using ping sweep...")
            return self.ping_sweep(network)
    
    def ping_sweep(self, network):
        """Ping sweep to discover hosts."""
        import subprocess
        
        # Parse network
        network_parts = network.split('.')
        base = '.'.join(network_parts[:3])
        
        hosts = []
        
        for i in range(1, 255):
            ip = f"{base}.{i}"
            # Ping with 1 second timeout
            result = subprocess.run(
                ['ping', '-c', '1', '-W', '1', ip],
                capture_output=True
            )
            
            if result.returncode == 0:
                hosts.append({'ip': ip, 'mac': 'unknown', 'vendor': 'unknown'})
                print(f"Found: {ip}")
            
            time.sleep(0.1)  # Prevent network flooding
        
        return hosts

# Usage
scanner = NetworkScanner()
hosts = scanner.scan_network()
print(f"\nFound {len(hosts)} hosts:")
for host in hosts:
    print(f"  {host['ip']} - {host['mac']} ({host['vendor']})")
```

---

## P1.8 HTTP Client Examples

### Using Python's HTTP Client

```python
import http.client
import json

class HTTPClient:
    """Simple HTTP client using Python's built-in http.client."""
    
    def __init__(self, host, use_https=False):
        self.host = host
        self.use_https = use_https
        
        if use_https:
            self.connection = http.client.HTTPSConnection(host)
        else:
            self.connection = http.client.HTTPConnection(host)
    
    def get(self, path, headers=None):
        """Perform GET request."""
        headers = headers or {}
        self.connection.request('GET', path, headers=headers)
        return self.connection.getresponse()
    
    def post(self, path, data, headers=None):
        """Perform POST request."""
        headers = headers or {}
        headers['Content-Type'] = 'application/json'
        
        if isinstance(data, dict):
            data = json.dumps(data)
        
        self.connection.request('POST', path, data, headers)
        return self.connection.getresponse()
    
    def put(self, path, data, headers=None):
        """Perform PUT request."""
        headers = headers or {}
        headers['Content-Type'] = 'application/json'
        
        if isinstance(data, dict):
            data = json.dumps(data)
        
        self.connection.request('PUT', path, data, headers)
        return self.connection.getresponse()
    
    def delete(self, path, headers=None):
        """Perform DELETE request."""
        headers = headers or {}
        self.connection.request('DELETE', path, headers=headers)
        return self.connection.getresponse()
    
    def close(self):
        """Close the connection."""
        self.connection.close()

# Usage
client = HTTPClient('jsonplaceholder.typicode.com', use_https=True)

# GET request
response = client.get('/posts/1')
data = response.read().decode('utf-8')
print(f"GET Response: {data[:100]}...")

# POST request
post_data = {'title': 'New Post', 'body': 'Content', 'userId': 1}
response = client.post('/posts', post_data)
data = response.read().decode('utf-8')
print(f"POST Response: {data}")

client.close()
```

### Using urllib

```python
import urllib.request
import urllib.parse
import urllib.error

class URLLibClient:
    """HTTP client using urllib."""
    
    @staticmethod
    def get(url, headers=None):
        """Perform GET request."""
        headers = headers or {}
        req = urllib.request.Request(url, headers=headers)
        
        try:
            response = urllib.request.urlopen(req, timeout=10)
            data = response.read().decode('utf-8')
            return {
                'status': response.getcode(),
                'headers': dict(response.headers),
                'data': data
            }
        except urllib.error.URLError as e:
            return {'error': str(e)}
        except urllib.error.HTTPError as e:
            return {
                'status': e.code,
                'headers': dict(e.headers),
                'error': str(e)
            }
    
    @staticmethod
    def post(url, data, headers=None):
        """Perform POST request."""
        headers = headers or {}
        headers['Content-Type'] = 'application/x-www-form-urlencoded'
        
        if isinstance(data, dict):
            data = urllib.parse.urlencode(data).encode('utf-8')
        elif isinstance(data, str):
            data = data.encode('utf-8')
        
        req = urllib.request.Request(url, data=data, headers=headers, method='POST')
        
        try:
            response = urllib.request.urlopen(req, timeout=10)
            response_data = response.read().decode('utf-8')
            return {
                'status': response.getcode(),
                'headers': dict(response.headers),
                'data': response_data
            }
        except urllib.error.URLError as e:
            return {'error': str(e)}
        except urllib.error.HTTPError as e:
            return {
                'status': e.code,
                'headers': dict(e.headers),
                'error': str(e)
            }

# Usage
result = URLLibClient.get('https://jsonplaceholder.typicode.com/posts/1')
print(f"Status: {result.get('status')}")
print(f"Data: {result.get('data', '')[:100]}...")

post_result = URLLibClient.post(
    'https://jsonplaceholder.typicode.com/posts',
    {'title': 'Test', 'body': 'Content'}
)
print(f"POST Status: {post_result.get('status')}")
```

---

## P1.9 Common Pitfalls & Best Practices

### Pitfall 1: Not Closing Sockets

```python
# WRONG - Socket leak
def wrong_socket_usage():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('example.com', 80))
    sock.send(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    data = sock.recv(1024)
    # Socket never closed!

# CORRECT - Use try/finally
def correct_socket_usage():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect(('example.com', 80))
        sock.send(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
        data = sock.recv(1024)
        return data
    finally:
        sock.close()

# CORRECT - Use with statement (Python 3.11+)
def with_socket_usage():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect(('example.com', 80))
        sock.send(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
        data = sock.recv(1024)
        return data
```

### Pitfall 2: Blocking the Main Thread

```python
# WRONG - Blocks the entire program
def wrong_blocking():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('example.com', 80))
    # This blocks indefinitely if no data arrives
    data = sock.recv(1024)
    return data

# CORRECT - Set timeout
def correct_timeout():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5.0)  # 5 second timeout
    try:
        sock.connect(('example.com', 80))
        data = sock.recv(1024)
        return data
    except socket.timeout:
        print("Timeout waiting for data")
        return None
    finally:
        sock.close()

# CORRECT - Non-blocking with select
def correct_non_blocking():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setblocking(False)
    
    try:
        sock.connect(('example.com', 80))
    except BlockingIOError:
        pass
    
    import select
    ready = select.select([sock], [sock], [], 5.0)
    if ready[1]:  # Socket is writable
        sock.send(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
        
        ready = select.select([sock], [], [], 5.0)
        if ready[0]:  # Socket is readable
            data = sock.recv(1024)
            sock.close()
            return data
    
    sock.close()
    return None
```

### Pitfall 3: Not Handling Partial Data

```python
# WRONG - Assumes recv gets all data
def wrong_recv():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('example.com', 80))
    sock.send(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    data = sock.recv(4096)  # May not get all data!
    sock.close()
    return data

# CORRECT - Loop until all data is received
def correct_recv():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('example.com', 80))
    sock.send(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    
    data = b''
    while True:
        chunk = sock.recv(4096)
        if not chunk:
            break
        data += chunk
    
    sock.close()
    return data

# CORRECT - HTTP with Content-Length
def correct_http_recv():
    import re
    
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('example.com', 80))
    sock.send(b"GET / HTTP/1.1\r\nHost: example.com\r\n\r\n")
    
    # Read headers
    headers = b''
    while b'\r\n\r\n' not in headers:
        headers += sock.recv(1)
    
    # Parse Content-Length
    content_length_match = re.search(rb'Content-Length: (\d+)', headers)
    if content_length_match:
        content_length = int(content_length_match.group(1))
        data = b''
        while len(data) < content_length:
            chunk = sock.recv(min(4096, content_length - len(data)))
            if not chunk:
                break
            data += chunk
    else:
        # Chunked or no length
        data = b''
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            data += chunk
    
    sock.close()
    return data
```

### Pitfall 4: Ignoring Errors

```python
# WRONG - Swallowing all errors
def wrong_error_handling():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(('example.com', 80))
        data = sock.recv(1024)
    except:
        pass  # Silently ignores all errors!
    return data

# CORRECT - Proper error handling
def correct_error_handling():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5.0)
        sock.connect(('example.com', 80))
        data = sock.recv(1024)
        return data
    except socket.timeout:
        print("Connection timed out")
        return None
    except socket.error as e:
        print(f"Socket error: {e}")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None
    finally:
        if 'sock' in locals():
            sock.close()
```

---

## P1.10 Quick Reference

### Socket Functions Reference

| Function | Description |
|----------|-------------|
| `socket.socket(family, type)` | Create a new socket |
| `socket.bind((host, port))` | Bind to address and port |
| `socket.listen(backlog)` | Start listening for connections |
| `socket.accept()` | Accept a connection |
| `socket.connect((host, port))` | Connect to a server |
| `socket.send(data)` | Send data |
| `socket.recv(bufsize)` | Receive data |
| `socket.sendto(data, address)` | Send UDP datagram |
| `socket.recvfrom(bufsize)` | Receive UDP datagram |
| `socket.close()` | Close socket |
| `socket.settimeout(timeout)` | Set timeout |
| `socket.setblocking(flag)` | Set blocking mode |

### Common Ports

| Port | Protocol | Service |
|------|----------|---------|
| 20/21 | TCP | FTP |
| 22 | TCP | SSH |
| 23 | TCP | Telnet |
| 25 | TCP | SMTP |
| 53 | TCP/UDP | DNS |
| 80 | TCP | HTTP |
| 110 | TCP | POP3 |
| 143 | TCP | IMAP |
| 443 | TCP | HTTPS |
| 3306 | TCP | MySQL |
| 5432 | TCP | PostgreSQL |
| 6379 | TCP | Redis |
| 27017 | TCP | MongoDB |

### Network Programming Checklist

- [ ] Use `with` statement or try/finally for socket cleanup
- [ ] Set timeouts for blocking operations
- [ ] Handle partial data properly
- [ ] Implement proper error handling
- [ ] Validate input data
- [ ] Use appropriate protocol (TCP/UDP)
- [ ] Handle connection resets gracefully
- [ ] Implement reconnection logic
- [ ] Use non-blocking or async for high performance
- [ ] Log network errors for debugging

---
