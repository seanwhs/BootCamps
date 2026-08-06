# Appendix C: Complete Network Programming Reference

## Practical Code Examples for Network Applications, Tools, and Utilities

---

## Overview

This appendix provides a comprehensive reference of network programming examples covering all protocols discussed in the series. Every example includes complete, production-ready code with error handling, logging, and best practices.

**Purpose**: Serve as a reference for building network applications, tools, and utilities across multiple programming languages.

**Organization**: Organized by protocol and use case, with both Python and Node.js examples where applicable.

---

## Table of Contents

1. [Socket Programming Basics](#1-socket-programming-basics)
2. [TCP Applications](#2-tcp-applications)
3. [UDP Applications](#3-udp-applications)
4. [HTTP Clients and Servers](#4-http-clients-and-servers)
5. [DNS Tools](#5-dns-tools)
6. [Email Utilities](#6-email-utilities)
7. [Network Scanning and Discovery](#7-network-scanning-and-discovery)
8. [Packet Generation and Manipulation](#8-packet-generation-and-manipulation)
9. [Network Monitoring](#9-network-monitoring)
10. [Security Tools](#10-security-tools)

---

## 1. Socket Programming Basics

### Python Socket Creation

```python
#!/usr/bin/env python3
"""
socket_basics.py - Socket creation and configuration examples
"""

import socket
import sys

def create_tcp_socket():
    """Create and configure a TCP socket"""
    # Create socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Configure socket options
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    
    # Set timeout
    sock.settimeout(30.0)
    
    # Get socket info
    print(f"Socket created: {sock}")
    print(f"  Family: {socket.AF_INET}")
    print(f"  Type: {socket.SOCK_STREAM}")
    print(f"  Protocol: {socket.IPPROTO_TCP}")
    
    return sock

def create_udp_socket():
    """Create and configure a UDP socket"""
    # Create socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    # Configure socket options
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    
    # Set timeout
    sock.settimeout(5.0)
    
    # Get socket info
    print(f"Socket created: {sock}")
    print(f"  Family: {socket.AF_INET}")
    print(f"  Type: {socket.SOCK_DGRAM}")
    
    return sock

def create_raw_socket():
    """Create a raw socket (requires root privileges)"""
    try:
        # Create raw socket for ICMP
        sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
        
        # Set IP_HDRINCL to include IP header
        sock.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)
        
        print(f"Raw socket created: {sock}")
        return sock
        
    except PermissionError:
        print("Error: Raw sockets require root privileges")
        sys.exit(1)
    except Exception as e:
        print(f"Error creating raw socket: {e}")
        sys.exit(1)

def main():
    """Demonstrate socket creation"""
    print("=" * 60)
    print("Socket Programming Basics")
    print("=" * 60)
    
    # TCP socket
    print("\n1. TCP Socket:")
    tcp_sock = create_tcp_socket()
    tcp_sock.close()
    
    # UDP socket
    print("\n2. UDP Socket:")
    udp_sock = create_udp_socket()
    udp_sock.close()
    
    # Raw socket
    print("\n3. Raw Socket:")
    try:
        raw_sock = create_raw_socket()
        raw_sock.close()
    except:
        pass

if __name__ == "__main__":
    main()
```

### Node.js Socket Creation

```javascript
#!/usr/bin/env node
/**
 * socket_basics.js - Socket creation in Node.js
 */

const net = require('net');
const dgram = require('dgram');

function createTcpSocket() {
    // Create TCP server socket
    const server = net.createServer();
    
    server.on('error', (err) => {
        console.error(`Socket error: ${err.message}`);
    });
    
    console.log('TCP socket created');
    return server;
}

function createUdpSocket() {
    // Create UDP socket
    const socket = dgram.createSocket('udp4');
    
    socket.on('error', (err) => {
        console.error(`Socket error: ${err.message}`);
    });
    
    console.log('UDP socket created');
    return socket;
}

function main() {
    console.log('='.repeat(60));
    console.log('Socket Programming Basics (Node.js)');
    console.log('='.repeat(60));
    
    // TCP socket
    console.log('\n1. TCP Socket:');
    const tcpSocket = createTcpSocket();
    tcpSocket.close();
    
    // UDP socket
    console.log('\n2. UDP Socket:');
    const udpSocket = createUdpSocket();
    udpSocket.close();
}

main();
```

---

## 2. TCP Applications

### Complete TCP Echo Server with Threading

```python
#!/usr/bin/env python3
"""
tcp_echo_server_advanced.py - Advanced TCP echo server with thread pool
"""

import socket
import threading
import queue
import time
import logging
from datetime import datetime
from typing import Optional, Dict

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

class TCPEchoServer:
    """
    Advanced TCP echo server with connection pooling and statistics
    """
    
    def __init__(self, host: str = '', port: int = 8080, max_workers: int = 10):
        self.host = host
        self.port = port
        self.max_workers = max_workers
        self.server_socket = None
        self.running = False
        self.thread_pool = queue.Queue()
        self.active_connections = 0
        self.total_connections = 0
        self.stats = {
            'bytes_received': 0,
            'bytes_sent': 0,
            'connections': 0,
            'errors': 0
        }
        self.lock = threading.Lock()
        
        # Initialize thread pool
        for i in range(max_workers):
            worker = threading.Thread(target=self.worker_loop, daemon=True, name=f"Worker-{i}")
            worker.start()
    
    def start(self):
        """Start the server"""
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.host, self.port))
            self.server_socket.listen(100)
            self.running = True
            
            logger.info(f"TCP Echo Server listening on port {self.port}")
            logger.info(f"Max workers: {self.max_workers}")
            
            while self.running:
                try:
                    client_socket, client_address = self.server_socket.accept()
                    client_socket.settimeout(30.0)
                    
                    # Increment connection count
                    with self.lock:
                        self.total_connections += 1
                        self.active_connections += 1
                    
                    # Submit to thread pool
                    self.thread_pool.put((client_socket, client_address))
                    
                except socket.timeout:
                    continue
                except socket.error as e:
                    if self.running:
                        logger.error(f"Accept error: {e}")
                        with self.lock:
                            self.stats['errors'] += 1
                        
        except Exception as e:
            logger.error(f"Server error: {e}")
        finally:
            self.shutdown()
    
    def worker_loop(self):
        """Worker thread loop"""
        while True:
            try:
                # Get task from queue
                task = self.thread_pool.get(timeout=1.0)
                client_socket, client_address = task
                
                # Handle client
                self.handle_client(client_socket, client_address)
                
                # Decrement active connections
                with self.lock:
                    self.active_connections -= 1
                
                self.thread_pool.task_done()
                
            except queue.Empty:
                continue
            except Exception as e:
                logger.error(f"Worker error: {e}")
    
    def handle_client(self, client_socket: socket.socket, address: tuple):
        """Handle a client connection"""
        client_id = f"{address[0]}:{address[1]}"
        logger.info(f"New connection from {client_id} (Active: {self.active_connections})")
        
        try:
            buffer = bytearray()
            bytes_received = 0
            
            while self.running:
                # Receive data
                data = client_socket.recv(4096)
                if not data:
                    break
                
                buffer.extend(data)
                bytes_received += len(data)
                
                # Update statistics
                with self.lock:
                    self.stats['bytes_received'] += len(data)
                
                # Echo data back
                client_socket.send(data)
                
                with self.lock:
                    self.stats['bytes_sent'] += len(data)
                
                # Log if we received a complete line
                if b'\n' in data:
                    line = buffer.split(b'\n')[-2] if b'\n' in buffer else buffer
                    logger.debug(f"Echoed {len(data)} bytes to {client_id}")
                
        except socket.timeout:
            logger.warning(f"Connection timeout from {client_id}")
        except socket.error as e:
            logger.error(f"Socket error with {client_id}: {e}")
            with self.lock:
                self.stats['errors'] += 1
        finally:
            try:
                client_socket.close()
            except:
                pass
            logger.info(f"Connection from {client_id} closed")
    
    def get_stats(self):
        """Return server statistics"""
        with self.lock:
            return {
                'port': self.port,
                'active_connections': self.active_connections,
                'total_connections': self.total_connections,
                'bytes_received': self.stats['bytes_received'],
                'bytes_sent': self.stats['bytes_sent'],
                'errors': self.stats['errors'],
                'running': self.running
            }
    
    def shutdown(self):
        """Shutdown the server gracefully"""
        self.running = False
        
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        
        logger.info("Server shutdown complete")
        logger.info(f"Final statistics: {self.get_stats()}")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Advanced TCP Echo Server")
    parser.add_argument('-p', '--port', type=int, default=8080, help='Port to listen on')
    parser.add_argument('-w', '--workers', type=int, default=10, help='Max workers')
    
    args = parser.parse_args()
    
    server = TCPEchoServer(port=args.port, max_workers=args.workers)
    
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n")
        logger.info("Shutting down...")
        server.shutdown()

if __name__ == "__main__":
    main()
```

### TCP Load Balancer

```python
#!/usr/bin/env python3
"""
tcp_load_balancer.py - Simple TCP load balancer
"""

import socket
import threading
import queue
import logging
import time
from typing import List, Tuple

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class TCPLoadBalancer:
    """
    Simple TCP load balancer with round-robin distribution
    """
    
    def __init__(self, listen_host: str = '0.0.0.0', listen_port: int = 8080):
        self.listen_host = listen_host
        self.listen_port = listen_port
        self.backends: List[Tuple[str, int]] = []
        self.current_backend = 0
        self.running = False
        self.server_socket = None
        self.lock = threading.Lock()
    
    def add_backend(self, host: str, port: int):
        """Add a backend server"""
        self.backends.append((host, port))
        logger.info(f"Added backend: {host}:{port}")
    
    def get_next_backend(self) -> Tuple[str, int]:
        """Get the next backend using round-robin"""
        with self.lock:
            if not self.backends:
                return None
            backend = self.backends[self.current_backend]
            self.current_backend = (self.current_backend + 1) % len(self.backends)
            return backend
    
    def start(self):
        """Start the load balancer"""
        if not self.backends:
            logger.error("No backends configured")
            return
        
        try:
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.server_socket.bind((self.listen_host, self.listen_port))
            self.server_socket.listen(100)
            self.running = True
            
            logger.info(f"Load balancer listening on {self.listen_host}:{self.listen_port}")
            logger.info(f"Backends: {self.backends}")
            
            while self.running:
                try:
                    client_socket, client_address = self.server_socket.accept()
                    client_thread = threading.Thread(
                        target=self.handle_client,
                        args=(client_socket, client_address),
                        daemon=True
                    )
                    client_thread.start()
                    
                except socket.error:
                    if self.running:
                        continue
                    
        except Exception as e:
            logger.error(f"Load balancer error: {e}")
        finally:
            self.shutdown()
    
    def handle_client(self, client_socket: socket.socket, address: tuple):
        """Handle client connection by forwarding to backend"""
        backend = self.get_next_backend()
        if not backend:
            logger.warning("No backend available")
            client_socket.close()
            return
        
        backend_host, backend_port = backend
        backend_socket = None
        
        try:
            # Connect to backend
            backend_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            backend_socket.settimeout(30.0)
            backend_socket.connect((backend_host, backend_port))
            
            client_socket.settimeout(30.0)
            
            logger.info(f"Forwarding {address[0]}:{address[1]} -> {backend_host}:{backend_port}")
            
            # Forward data between client and backend
            self.forward_data(client_socket, backend_socket)
            
        except Exception as e:
            logger.error(f"Error forwarding connection: {e}")
        finally:
            try:
                client_socket.close()
            except:
                pass
            try:
                if backend_socket:
                    backend_socket.close()
            except:
                pass
    
    def forward_data(self, sock1: socket.socket, sock2: socket.socket):
        """Forward data between two sockets"""
        # Use select or threading for full duplex
        def forward(src: socket.socket, dst: socket.socket):
            try:
                while True:
                    data = src.recv(4096)
                    if not data:
                        break
                    dst.send(data)
            except:
                pass
        
        # Create threads for each direction
        t1 = threading.Thread(target=forward, args=(sock1, sock2), daemon=True)
        t2 = threading.Thread(target=forward, args=(sock2, sock1), daemon=True)
        t1.start()
        t2.start()
        t1.join(timeout=60)
        t2.join(timeout=60)
    
    def shutdown(self):
        """Shutdown the load balancer"""
        self.running = False
        if self.server_socket:
            try:
                self.server_socket.close()
            except:
                pass
        logger.info("Load balancer shutdown complete")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="TCP Load Balancer")
    parser.add_argument('-l', '--listen-port', type=int, default=8080, help='Listen port')
    parser.add_argument('-b', '--backend', action='append', help='Backend (host:port)')
    
    args = parser.parse_args()
    
    if not args.backend:
        print("Error: At least one backend required")
        sys.exit(1)
    
    lb = TCPLoadBalancer(listen_port=args.listen_port)
    
    for backend in args.backend:
        host, port = backend.split(':')
        lb.add_backend(host, int(port))
    
    try:
        lb.start()
    except KeyboardInterrupt:
        print("\n")
        logger.info("Shutting down...")
        lb.shutdown()

if __name__ == "__main__":
    import sys
    main()
```

---

## 3. UDP Applications

### UDP Multicast Server

```python
#!/usr/bin/env python3
"""
udp_multicast_server.py - UDP multicast server
"""

import socket
import time
import sys
import json
from datetime import datetime

class UDPMulticastServer:
    """
    UDP multicast server for group communication
    """
    
    def __init__(self, group: str = '224.0.0.1', port: int = 9999):
        self.group = group
        self.port = port
        self.socket = None
        self.running = False
    
    def start(self):
        """Start multicast server"""
        try:
            # Create UDP socket
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
            
            # Set TTL to 2 (stay within local network)
            self.socket.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
            
            # Allow reuse of address
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            self.running = True
            
            print(f"[*] UDP Multicast Server started on {self.group}:{self.port}")
            print("[*] Press Ctrl+C to stop\n")
            
            message_count = 0
            
            while self.running:
                # Create message
                message = {
                    'timestamp': datetime.now().isoformat(),
                    'sequence': message_count,
                    'message': f'Hello from multicast server #{message_count}',
                    'source': socket.gethostname()
                }
                
                # Send message
                data = json.dumps(message).encode('utf-8')
                self.socket.sendto(data, (self.group, self.port))
                
                print(f"[*] Sent message {message_count}: {message['message']}")
                
                message_count += 1
                time.sleep(2)
                
        except Exception as e:
            print(f"[!] Error: {e}")
        finally:
            self.shutdown()
    
    def shutdown(self):
        """Shutdown the server"""
        self.running = False
        if self.socket:
            self.socket.close()
        print("[*] Server shutdown complete")

def main():
    """Main entry point"""
    server = UDPMulticastServer()
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Shutting down...")
        server.shutdown()

if __name__ == "__main__":
    main()
```

### UDP Multicast Client

```python
#!/usr/bin/env python3
"""
udp_multicast_client.py - UDP multicast client
"""

import socket
import struct
import json
import sys

class UDPMulticastClient:
    """
    UDP multicast client for group communication
    """
    
    def __init__(self, group: str = '224.0.0.1', port: int = 9999):
        self.group = group
        self.port = port
        self.socket = None
        self.running = False
    
    def start(self):
        """Start multicast client"""
        try:
            # Create UDP socket
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
            
            # Allow reuse of address
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            # Bind to the port
            self.socket.bind(('', self.port))
            
            # Join multicast group
            mreq = struct.pack("4sl", socket.inet_aton(self.group), socket.INADDR_ANY)
            self.socket.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)
            
            self.running = True
            
            print(f"[*] UDP Multicast Client joined {self.group}:{self.port}")
            print("[*] Press Ctrl+C to stop\n")
            
            while self.running:
                try:
                    data, address = self.socket.recvfrom(4096)
                    
                    # Parse message
                    try:
                        message = json.loads(data.decode('utf-8'))
                        
                        # Display message
                        print(f"[*] Received from {address[0]}:{address[1]}")
                        print(f"    Timestamp: {message.get('timestamp', 'Unknown')}")
                        print(f"    Sequence: {message.get('sequence', 'Unknown')}")
                        print(f"    Message: {message.get('message', 'Unknown')}")
                        print(f"    Source: {message.get('source', 'Unknown')}")
                        print("")
                        
                    except json.JSONDecodeError:
                        print(f"[*] Received raw data from {address}: {data[:50]}...")
                    
                except socket.timeout:
                    continue
                except Exception as e:
                    print(f"[!] Error: {e}")
                    break
                
        except Exception as e:
            print(f"[!] Error: {e}")
        finally:
            self.shutdown()
    
    def shutdown(self):
        """Shutdown the client"""
        self.running = False
        if self.socket:
            try:
                # Leave multicast group
                mreq = struct.pack("4sl", socket.inet_aton(self.group), socket.INADDR_ANY)
                self.socket.setsockopt(socket.IPPROTO_IP, socket.IP_DROP_MEMBERSHIP, mreq)
            except:
                pass
            self.socket.close()
        print("[*] Client shutdown complete")

def main():
    """Main entry point"""
    client = UDPMulticastClient()
    try:
        client.start()
    except KeyboardInterrupt:
        print("\n[!] Shutting down...")
        client.shutdown()

if __name__ == "__main__":
    main()
```

---

## 4. HTTP Clients and Servers

### Complete HTTP Client with Session Management

```python
#!/usr/bin/env python3
"""
http_client.py - Complete HTTP client with session management
"""

import http.client
import urllib.parse
import json
import gzip
import io
import sys
from typing import Dict, Optional, Any
from datetime import datetime

class HTTPClient:
    """
    Complete HTTP client with session management and compression support
    """
    
    def __init__(self, host: str, port: int = 80, use_https: bool = False):
        self.host = host
        self.port = port
        self.use_https = use_https
        self.connection = None
        self.cookies = {}
        self.headers = {
            'User-Agent': 'HTTPClient/1.0',
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive'
        }
        self.timeout = 30.0
    
    def connect(self):
        """Establish connection"""
        try:
            if self.use_https:
                self.connection = http.client.HTTPSConnection(self.host, self.port, timeout=self.timeout)
            else:
                self.connection = http.client.HTTPConnection(self.host, self.port, timeout=self.timeout)
            
            return True
        except Exception as e:
            print(f"Connection error: {e}")
            return False
    
    def set_header(self, name: str, value: str):
        """Set request header"""
        self.headers[name] = value
    
    def set_cookie(self, name: str, value: str):
        """Set cookie"""
        self.cookies[name] = value
    
    def get(self, path: str, params: Optional[Dict] = None) -> Dict:
        """Perform GET request"""
        # Build URL with parameters
        if params:
            query_string = urllib.parse.urlencode(params)
            path = f"{path}?{query_string}"
        
        # Build headers with cookies
        headers = self.headers.copy()
        if self.cookies:
            cookie_string = "; ".join([f"{k}={v}" for k, v in self.cookies.items()])
            headers['Cookie'] = cookie_string
        
        # Execute request
        try:
            self.connection.request('GET', path, headers=headers)
            response = self.connection.getresponse()
            
            return self._process_response(response)
            
        except Exception as e:
            return {'status': 0, 'error': str(e)}
    
    def post(self, path: str, data: Optional[Any] = None, content_type: str = 'application/json') -> Dict:
        """Perform POST request"""
        # Build headers with cookies
        headers = self.headers.copy()
        headers['Content-Type'] = content_type
        
        if self.cookies:
            cookie_string = "; ".join([f"{k}={v}" for k, v in self.cookies.items()])
            headers['Cookie'] = cookie_string
        
        # Prepare data
        if data is not None:
            if isinstance(data, dict):
                body = json.dumps(data).encode('utf-8')
            elif isinstance(data, str):
                body = data.encode('utf-8')
            else:
                body = data
            headers['Content-Length'] = str(len(body))
        else:
            body = None
        
        # Execute request
        try:
            self.connection.request('POST', path, body, headers)
            response = self.connection.getresponse()
            
            return self._process_response(response)
            
        except Exception as e:
            return {'status': 0, 'error': str(e)}
    
    def _process_response(self, response) -> Dict:
        """Process HTTP response"""
        # Read response body
        body = response.read()
        
        # Handle compression
        content_encoding = response.getheader('Content-Encoding')
        if content_encoding == 'gzip':
            try:
                body = gzip.decompress(body)
            except:
                pass
        elif content_encoding == 'deflate':
            try:
                body = zlib.decompress(body)
            except:
                pass
        
        # Parse response
        result = {
            'status': response.status,
            'reason': response.reason,
            'headers': dict(response.getheaders()),
            'body': body,
            'body_string': None
        }
        
        # Try to decode body
        content_type = response.getheader('Content-Type', '')
        if 'text' in content_type or 'json' in content_type:
            try:
                result['body_string'] = body.decode('utf-8')
                if 'json' in content_type:
                    result['body_json'] = json.loads(result['body_string'])
            except:
                pass
        
        # Extract cookies
        cookie_headers = response.getheaders().get('Set-Cookie', [])
        if cookie_headers:
            for cookie_str in cookie_headers:
                parts = cookie_str.split(';')
                if '=' in parts[0]:
                    name, value = parts[0].split('=', 1)
                    self.cookies[name] = value
        
        return result
    
    def close(self):
        """Close the connection"""
        if self.connection:
            self.connection.close()

def main():
    """Example usage"""
    # Create client for HTTP
    client = HTTPClient('httpbin.org', 80)
    
    if not client.connect():
        sys.exit(1)
    
    # GET request
    print("GET Request:")
    response = client.get('/get', {'test': 'hello'})
    print(f"  Status: {response['status']}")
    if response.get('body_json'):
        print(f"  Response: {json.dumps(response['body_json'], indent=2)[:200]}...")
    
    # POST request
    print("\nPOST Request:")
    response = client.post('/post', {'name': 'test', 'value': 123})
    print(f"  Status: {response['status']}")
    if response.get('body_json'):
        print(f"  Response: {json.dumps(response['body_json'], indent=2)[:200]}...")
    
    client.close()

if __name__ == "__main__":
    main()
```

### HTTP/2 Client with ALPN

```python
#!/usr/bin/env python3
"""
http2_client.py - HTTP/2 client with ALPN support
"""

import ssl
import socket
import sys
import json
import h2.connection
import h2.config
import h2.events
from typing import Dict, Any

class HTTP2Client:
    """
    HTTP/2 client with ALPN (Application-Layer Protocol Negotiation)
    """
    
    def __init__(self, host: str, port: int = 443):
        self.host = host
        self.port = port
        self.socket = None
        self.conn = None
        self.stream_id = 1
        self.response_data = {}
    
    def connect(self):
        """Establish HTTP/2 connection"""
        try:
            # Create SSL context
            ctx = ssl.create_default_context()
            ctx.set_alpn_protocols(['h2'])
            ctx.check_hostname = True
            
            # Create socket and wrap with SSL
            sock = socket.create_connection((self.host, self.port))
            self.socket = ctx.wrap_socket(sock, server_hostname=self.host)
            
            # Check ALPN negotiation
            negotiated = self.socket.selected_alpn_protocol()
            if negotiated != 'h2':
                print(f"Error: ALPN negotiation failed: {negotiated}")
                return False
            
            # Initialize HTTP/2 connection
            config = h2.config.H2Configuration(client_side=True)
            self.conn = h2.connection.H2Connection(config=config)
            self.conn.initiate_connection()
            self.socket.send(self.conn.data_to_send())
            
            print(f"[*] Connected to {self.host}:{self.port} (HTTP/2)")
            return True
            
        except Exception as e:
            print(f"Connection error: {e}")
            return False
    
    def get(self, path: str = '/') -> Dict:
        """Perform HTTP/2 GET request"""
        if not self.conn:
            return {'error': 'Not connected'}
        
        # Send request
        headers = [
            (':method', 'GET'),
            (':path', path),
            (':scheme', 'https'),
            (':authority', self.host),
            ('user-agent', 'HTTP2Client/1.0'),
            ('accept', '*/*')
        ]
        
        self.conn.send_headers(self.stream_id, headers)
        self.socket.send(self.conn.data_to_send())
        
        # Receive response
        response_data = b''
        response_headers = {}
        
        while True:
            try:
                data = self.socket.recv(65535)
                if not data:
                    break
                
                events = self.conn.receive_data(data)
                
                for event in events:
                    if isinstance(event, h2.events.ResponseReceived):
                        response_headers = dict(event.headers)
                        print(f"  Status: {response_headers.get(':status', 'Unknown')}")
                    
                    elif isinstance(event, h2.events.DataReceived):
                        response_data += event.data
                        self.conn.acknowledge_received_data(event.flow_controlled_length, event.stream_id)
                        self.socket.send(self.conn.data_to_send())
                    
                    elif isinstance(event, h2.events.StreamEnded):
                        # Stream complete
                        self.socket.close()
                        break
                
                if self.socket.fileno() == -1:
                    break
                    
            except Exception as e:
                print(f"Error: {e}")
                break
        
        # Parse response
        content_type = response_headers.get('content-type', [''])[0]
        body_string = None
        body_json = None
        
        try:
            body_string = response_data.decode('utf-8')
            if 'json' in content_type:
                body_json = json.loads(body_string)
        except:
            pass
        
        return {
            'status': response_headers.get(':status', [''])[0],
            'headers': response_headers,
            'body': response_data,
            'body_string': body_string,
            'body_json': body_json
        }
    
    def close(self):
        """Close the connection"""
        if self.socket:
            try:
                self.socket.close()
            except:
                pass

def main():
    """Example usage"""
    # Create HTTP/2 client
    client = HTTP2Client('nghttp2.org')
    
    if client.connect():
        # GET request
        print("\nGET /httpbin/get:")
        response = client.get('/httpbin/get')
        
        if response.get('body_json'):
            print(f"  Response: {json.dumps(response['body_json'], indent=2)[:300]}...")
        
        client.close()

if __name__ == "__main__":
    main()
```

---

## 5. DNS Tools

### DNS Client with All Record Types

```python
#!/usr/bin/env python3
"""
dns_client.py - Complete DNS client with all record types
"""

import socket
import struct
import random
import sys
from typing import List, Dict, Any, Optional

class DNSClient:
    """
    Complete DNS client supporting all common record types
    """
    
    # DNS record types
    QTYPES = {
        'A': 1, 'NS': 2, 'CNAME': 5, 'SOA': 6, 'PTR': 12,
        'MX': 15, 'TXT': 16, 'AAAA': 28, 'SRV': 33, 'ANY': 255
    }
    
    def __init__(self, server: str = '8.8.8.8', port: int = 53):
        self.server = server
        self.port = port
        self.socket = None
    
    def create_socket(self):
        """Create UDP socket for DNS"""
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.settimeout(5.0)
    
    def close_socket(self):
        """Close DNS socket"""
        if self.socket:
            self.socket.close()
    
    def build_query(self, domain: str, qtype: str = 'A') -> bytes:
        """Build DNS query packet"""
        # Generate random transaction ID
        transaction_id = random.randint(0, 65535)
        
        # Header
        flags = 0x0100  # RD flag set
        qcount = 1      # 1 question
        
        # Build header
        header = struct.pack('>HHHHHH', 
                           transaction_id, 
                           flags, 
                           qcount, 
                           0,     # Answer count
                           0,     # Authority count
                           0)     # Additional count
        
        # Build question section
        qname_parts = domain.split('.')
        qname = b''
        for part in qname_parts:
            qname += bytes([len(part)]) + part.encode('utf-8')
        qname += b'\x00'  # End of name
        
        # QTYPE and QCLASS
        qtype_value = self.QTYPES.get(qtype.upper(), 1)
        qclass = 1  # IN
        
        question = qname + struct.pack('>HH', qtype_value, qclass)
        
        return header + question
    
    def parse_response(self, response: bytes) -> Dict[str, Any]:
        """Parse DNS response"""
        result = {
            'transaction_id': 0,
            'flags': 0,
            'qcount': 0,
            'ancount': 0,
            'nscount': 0,
            'arcount': 0,
            'answers': [],
            'authorities': [],
            'additional': [],
            'raw': response
        }
        
        try:
            # Parse header
            header = response[:12]
            (result['transaction_id'], result['flags'], 
             result['qcount'], result['ancount'], 
             result['nscount'], result['arcount']) = struct.unpack('>HHHHHH', header)
            
            # Skip question section
            pos = 12
            while pos < len(response):
                if response[pos] == 0:
                    pos += 1
                    break
                if response[pos] & 0xC0:  # Compression pointer
                    pos += 2
                    break
                pos += response[pos] + 1
            
            pos += 4  # Skip QTYPE and QCLASS
            
            # Parse answers
            for i in range(result['ancount']):
                answer = self.parse_rr(response, pos)
                if answer:
                    result['answers'].append(answer)
                    pos = answer['end_pos']
            
        except Exception as e:
            print(f"Parse error: {e}")
        
        return result
    
    def parse_rr(self, data: bytes, pos: int) -> Optional[Dict]:
        """Parse a resource record"""
        try:
            # Parse name (compressed or uncompressed)
            name = ''
            if data[pos] & 0xC0:  # Compression
                pointer = ((data[pos] & 0x3F) << 8) | data[pos + 1]
                pos += 2
            else:
                while data[pos] != 0:
                    length = data[pos]
                    name += data[pos + 1:pos + length + 1].decode('utf-8') + '.'
                    pos += length + 1
                pos += 1
                name = name.rstrip('.')
            
            # Parse RDTYPE, RDCLASS, TTL, RDLENGTH
            rdtype, rdclass, ttl, rdlength = struct.unpack('>HHIH', data[pos:pos + 10])
            pos += 10
            
            # Parse RDATA based on type
            rdata = data[pos:pos + rdlength]
            
            rr = {
                'name': name,
                'type': rdtype,
                'class': rdclass,
                'ttl': ttl,
                'data': rdata,
                'end_pos': pos + rdlength
            }
            
            # Parse specific record types
            if rdtype == 1:  # A
                rr['address'] = socket.inet_ntoa(rdata)
            elif rdtype == 28:  # AAAA
                rr['address'] = socket.inet_ntop(socket.AF_INET6, rdata)
            elif rdtype == 5:  # CNAME
                rr['cname'] = self.decode_name(data, pos)
            elif rdtype == 15:  # MX
                preference = struct.unpack('>H', rdata[:2])[0]
                exchange = self.decode_name(data, pos + 2)
                rr['preference'] = preference
                rr['exchange'] = exchange
            elif rdtype == 16:  # TXT
                rr['text'] = rdata[1:].decode('utf-8')
            
            return rr
            
        except Exception as e:
            print(f"Error parsing RR at position {pos}: {e}")
            return None
    
    def decode_name(self, data: bytes, pos: int) -> str:
        """Decode a DNS name from compressed form"""
        name = ''
        while True:
            if data[pos] & 0xC0:
                pointer = ((data[pos] & 0x3F) << 8) | data[pos + 1]
                # Recursively decode the referenced name
                name += self.decode_name(data, pointer)
                break
            elif data[pos] == 0:
                break
            else:
                length = data[pos]
                name += data[pos + 1:pos + length + 1].decode('utf-8') + '.'
                pos += length + 1
        return name.rstrip('.')
    
    def query(self, domain: str, qtype: str = 'A') -> Optional[Dict]:
        """Perform DNS query"""
        if not self.socket:
            self.create_socket()
        
        # Build and send query
        query = self.build_query(domain, qtype)
        self.socket.sendto(query, (self.server, self.port))
        
        # Receive response
        try:
            response, _ = self.socket.recvfrom(4096)
            return self.parse_response(response)
        except socket.timeout:
            print(f"Timeout: DNS server {self.server} not responding")
            return None
        except Exception as e:
            print(f"Error: {e}")
            return None
    
    def resolve(self, domain: str, qtype: str = 'A') -> List[str]:
        """Resolve domain to IP addresses"""
        response = self.query(domain, qtype)
        
        if not response:
            return []
        
        results = []
        for answer in response.get('answers', []):
            if answer.get('type') in [1, 28]:  # A or AAAA
                results.append(answer.get('address'))
        
        return results

def main():
    """Example usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description="DNS Client")
    parser.add_argument('domain', help='Domain to query')
    parser.add_argument('-t', '--type', default='A', help='Record type')
    parser.add_argument('-s', '--server', default='8.8.8.8', help='DNS server')
    
    args = parser.parse_args()
    
    client = DNSClient(server=args.server)
    
    print(f"Querying {args.domain} ({args.type}) from {args.server}")
    
    response = client.query(args.domain, args.type)
    
    if response:
        print(f"\nTransaction ID: 0x{response['transaction_id']:04X}")
        print(f"Flags: 0x{response['flags']:04X}")
        print(f"Answers: {response['ancount']}")
        
        for i, answer in enumerate(response.get('answers', []), 1):
            print(f"\nAnswer {i}:")
            print(f"  Name: {answer['name']}")
            print(f"  Type: {answer['type']}")
            print(f"  TTL: {answer['ttl']}")
            
            if 'address' in answer:
                print(f"  Address: {answer['address']}")
            elif 'cname' in answer:
                print(f"  CNAME: {answer['cname']}")
            elif 'exchange' in answer:
                print(f"  MX: {answer['exchange']} (pref {answer['preference']})")
            elif 'text' in answer:
                print(f"  TXT: {answer['text']}")
    
    client.close_socket()

if __name__ == "__main__":
    main()
```

---

## 6. Email Utilities

### SMTP Client for Sending Email

```python
#!/usr/bin/env python3
"""
smtp_client.py - Complete SMTP client for sending email
"""

import socket
import base64
import ssl
import sys
from typing import Dict, List, Optional

class SMTPClient:
    """
    Complete SMTP client with authentication and TLS support
    """
    
    def __init__(self, server: str, port: int = 25, use_tls: bool = True):
        self.server = server
        self.port = port
        self.use_tls = use_tls
        self.socket = None
        self.connected = False
        self.buffer = ""
    
    def connect(self) -> bool:
        """Connect to SMTP server"""
        try:
            if self.use_tls:
                # Create SSL context
                context = ssl.create_default_context()
                self.socket = socket.create_connection((self.server, self.port))
                self.socket = context.wrap_socket(self.socket, server_hostname=self.server)
            else:
                self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                self.socket.connect((self.server, self.port))
            
            self.connected = True
            
            # Read greeting
            response = self.read_response()
            if response.startswith('220'):
                print(f"[*] Connected to {self.server}:{self.port}")
                return True
            else:
                print(f"[!] Unexpected response: {response}")
                return False
                
        except Exception as e:
            print(f"[!] Connection error: {e}")
            return False
    
    def read_response(self) -> str:
        """Read SMTP server response"""
        response = ""
        while True:
            data = self.socket.recv(1024).decode('utf-8')
            response += data
            if data.endswith('\n'):
                break
        self.buffer = response
        return response.strip()
    
    def send_command(self, command: str) -> str:
        """Send SMTP command and read response"""
        if not self.connected:
            raise Exception("Not connected")
        
        self.socket.send((command + '\r\n').encode('utf-8'))
        return self.read_response()
    
    def auth_login(self, username: str, password: str) -> bool:
        """Authenticate using LOGIN mechanism"""
        # Send EHLO first
        response = self.send_command(f'EHLO {socket.gethostname()}')
        if not response.startswith('250'):
            print(f"[!] EHLO failed: {response}")
            return False
        
        # Start authentication
        response = self.send_command('AUTH LOGIN')
        if not response.startswith('334'):
            print(f"[!] AUTH LOGIN failed: {response}")
            return False
        
        # Send username (base64 encoded)
        username_b64 = base64.b64encode(username.encode('utf-8')).decode('utf-8')
        response = self.send_command(username_b64)
        if not response.startswith('334'):
            print(f"[!] Username rejected: {response}")
            return False
        
        # Send password (base64 encoded)
        password_b64 = base64.b64encode(password.encode('utf-8')).decode('utf-8')
        response = self.send_command(password_b64)
        if response.startswith('235'):
            print("[*] Authentication successful")
            return True
        else:
            print(f"[!] Authentication failed: {response}")
            return False
    
    def send_email(self, from_addr: str, to_addr: str, 
                   subject: str, body: str, 
                   cc: List[str] = None, bcc: List[str] = None) -> bool:
        """Send an email"""
        try:
            # MAIL FROM
            response = self.send_command(f'MAIL FROM:<{from_addr}>')
            if not response.startswith('250'):
                print(f"[!] MAIL FROM failed: {response}")
                return False
            
            # RCPT TO
            response = self.send_command(f'RCPT TO:<{to_addr}>')
            if not response.startswith('250'):
                print(f"[!] RCPT TO failed: {response}")
                return False
            
            # CC recipients
            if cc:
                for addr in cc:
                    response = self.send_command(f'RCPT TO:<{addr}>')
                    if not response.startswith('250'):
                        print(f"[!] RCPT TO (CC) failed: {response}")
            
            # BCC recipients
            if bcc:
                for addr in bcc:
                    response = self.send_command(f'RCPT TO:<{addr}>')
                    if not response.startswith('250'):
                        print(f"[!] RCPT TO (BCC) failed: {response}")
            
            # DATA
            response = self.send_command('DATA')
            if not response.startswith('354'):
                print(f"[!] DATA failed: {response}")
                return False
            
            # Build email
            email = f"From: {from_addr}\r\n"
            email += f"To: {to_addr}\r\n"
            if cc:
                email += f"Cc: {', '.join(cc)}\r\n"
            email += f"Subject: {subject}\r\n"
            email += "\r\n"
            email += body
            email += "\r\n.\r\n"
            
            # Send email
            self.socket.send(email.encode('utf-8'))
            response = self.read_response()
            
            if response.startswith('250'):
                print("[*] Email sent successfully")
                return True
            else:
                print(f"[!] Failed to send email: {response}")
                return False
                
        except Exception as e:
            print(f"[!] Error sending email: {e}")
            return False
    
    def close(self):
        """Close connection"""
        if self.connected:
            try:
                self.send_command('QUIT')
            except:
                pass
            self.socket.close()
            self.connected = False
            print("[*] Connection closed")

def main():
    """Example usage"""
    import argparse
    
    parser = argparse.ArgumentParser(description="SMTP Client")
    parser.add_argument('-s', '--server', required=True, help='SMTP server')
    parser.add_argument('-p', '--port', type=int, default=587, help='Port')
    parser.add_argument('-f', '--from', dest='from_addr', required=True, help='From address')
    parser.add_argument('-t', '--to', required=True, help='To address')
    parser.add_argument('--subject', required=True, help='Subject')
    parser.add_argument('--body', required=True, help='Message body')
    parser.add_argument('--username', help='SMTP username')
    parser.add_argument('--password', help='SMTP password')
    parser.add_argument('--no-tls', action='store_true', help='Disable TLS')
    
    args = parser.parse_args()
    
    client = SMTPClient(args.server, args.port, not args.no_tls)
    
    if not client.connect():
        sys.exit(1)
    
    # Authenticate if username/password provided
    if args.username and args.password:
        if not client.auth_login(args.username, args.password):
            sys.exit(1)
    
    # Send email
    success = client.send_email(
        args.from_addr,
        args.to,
        args.subject,
        args.body
    )
    
    client.close()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
```

---

## 7. Network Scanning and Discovery

### Network Scanner with ARP Discovery

```python
#!/usr/bin/env python3
"""
network_scanner.py - Network scanner with ARP discovery
"""

import socket
import struct
import sys
import time
import threading
from typing import Dict, List, Tuple
import ipaddress

class NetworkScanner:
    """
    Network scanner with ARP discovery and port scanning
    """
    
    def __init__(self, network: str):
        self.network = ipaddress.ip_network(network, strict=False)
        self.hosts = []
        self.results = {}
    
    def scan_arp(self, timeout: float = 1.0) -> Dict[str, Dict]:
        """
        Scan network using ARP requests
        Requires root privileges
        """
        # Get local IP and MAC
        local_ip = socket.gethostbyname(socket.gethostname())
        
        # Create ARP request socket
        try:
            sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.ETH_P_ARP)
        except PermissionError:
            print("Error: ARP scanning requires root privileges")
            return {}
        
        results = {}
        
        # Send ARP requests to all hosts
        for host in self.network.hosts():
            if host == local_ip:
                continue
            
            # Build ARP request
            arp_request = self.build_arp_request(local_ip, str(host))
            
            # Send request
            sock.send(arp_request)
            
            # Wait for response
            sock.settimeout(timeout)
            
            try:
                while True:
                    data, addr = sock.recvfrom(1024)
                    if self.is_arp_reply(data):
                        mac = self.extract_mac_from_arp(data)
                        if mac:
                            results[str(host)] = {
                                'ip': str(host),
                                'mac': mac,
                                'status': 'active'
                            }
                            break
            except socket.timeout:
                # No response
                results[str(host)] = {
                    'ip': str(host),
                    'mac': None,
                    'status': 'inactive'
                }
        
        sock.close()
        return results
    
    def build_arp_request(self, src_ip: str, dst_ip: str) -> bytes:
        """Build ARP request packet"""
        # TODO: Implement ARP packet construction
        # This is a simplified version
        return b''
    
    def is_arp_reply(self, data: bytes) -> bool:
        """Check if packet is an ARP reply"""
        # TODO: Implement ARP reply detection
        return False
    
    def extract_mac_from_arp(self, data: bytes) -> str:
        """Extract MAC address from ARP reply"""
        # TODO: Implement MAC extraction
        return ''
    
    def scan_ports(self, host: str, ports: List[int], timeout: float = 1.0) -> Dict[int, bool]:
        """
        Scan TCP ports on a host
        """
        results = {}
        
        def check_port(port: int):
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.settimeout(timeout)
                result = sock.connect_ex((host, port))
                sock.close()
                results[port] = (result == 0)
            except:
                results[port] = False
        
        # Scan ports in parallel
        threads = []
        for port in ports:
            thread = threading.Thread(target=check_port, args=(port,))
            thread.start()
            threads.append(thread)
        
        # Wait for completion
        for thread in threads:
            thread.join()
        
        return results
    
    def discover_services(self, host: str) -> Dict[int, str]:
        """
        Discover services running on common ports
        """
        common_services = {
            21: 'FTP',
            22: 'SSH',
            23: 'Telnet',
            25: 'SMTP',
            53: 'DNS',
            80: 'HTTP',
            110: 'POP3',
            111: 'RPC',
            135: 'MSRPC',
            139: 'NetBIOS',
            143: 'IMAP',
            443: 'HTTPS',
            445: 'SMB',
            993: 'IMAPS',
            995: 'POP3S',
            3306: 'MySQL',
            3389: 'RDP',
            5432: 'PostgreSQL',
            8080: 'HTTP-Alt'
        }
        
        open_ports = self.scan_ports(host, list(common_services.keys()))
        
        services = {}
        for port, is_open in open_ports.items():
            if is_open:
                services[port] = common_services.get(port, 'Unknown')
        
        return services
    
    def run_scan(self) -> Dict:
        """
        Run complete network scan
        """
        print(f"[*] Scanning network: {self.network}")
        print("[*] Running ARP discovery...")
        
        arp_results = self.scan_arp()
        
        print(f"[*] Found {len([h for h in arp_results.values() if h['status'] == 'active'])} active hosts")
        
        # Scan ports on active hosts
        for host, info in arp_results.items():
            if info['status'] == 'active':
                print(f"\n[*] Scanning {host} ({info['mac']})...")
                services = self.discover_services(host)
                if services:
                    print(f"  Open ports:")
                    for port, service in sorted(services.items()):
                        print(f"    {port}: {service}")
                info['services'] = services
        
        return arp_results

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Network Scanner")
    parser.add_argument('-n', '--network', default='192.168.1.0/24', help='Network to scan')
    
    args = parser.parse_args()
    
    scanner = NetworkScanner(args.network)
    results = scanner.run_scan()
    
    print("\n" + "=" * 60)
    print("Scan Results")
    print("=" * 60)
    
    for host, info in results.items():
        status = "ACTIVE" if info['status'] == 'active' else "INACTIVE"
        mac = info['mac'] or 'Unknown'
        print(f"{host:>16}  {status:>8}  {mac:>20}")
        if info.get('services'):
            for port, service in info['services'].items():
                print(f"  └─ {port:>6}: {service}")

if __name__ == "__main__":
    main()
```

---

## 8. Packet Generation and Manipulation

### Packet Sniffer with Protocol Decoding

```python
#!/usr/bin/env python3
"""
packet_sniffer.py - Packet sniffer with protocol decoding
"""

import socket
import struct
import sys
import datetime
from typing import Dict, Any

class PacketSniffer:
    """
    Packet sniffer with support for multiple protocols
    """
    
    def __init__(self, interface: str = None):
        self.interface = interface
        self.socket = None
        self.running = False
    
    def start(self):
        """Start packet capture"""
        try:
            # Create raw socket
            self.socket = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.ntohs(3))
            self.running = True
            
            print("[*] Packet sniffer started")
            print("[*] Press Ctrl+C to stop\n")
            
            while self.running:
                try:
                    data, addr = self.socket.recvfrom(65536)
                    self.process_packet(data, addr)
                except KeyboardInterrupt:
                    break
                except Exception as e:
                    print(f"Error: {e}")
                    
        except PermissionError:
            print("Error: Packet capture requires root privileges")
        finally:
            self.close()
    
    def process_packet(self, data: bytes, addr: tuple):
        """Process and decode a packet"""
        timestamp = datetime.datetime.now().strftime('%H:%M:%S.%f')[:-3]
        
        # Decode Ethernet header
        ethernet = self.decode_ethernet(data)
        if not ethernet:
            return
        
        # Decode IP header
        ip = self.decode_ip(data[14:])
        if not ip:
            return
        
        # Decode transport protocol
        transport = self.decode_transport(data[14 + ip['ihl']:], ip['protocol'])
        
        # Display packet info
        print(f"[{timestamp}] {addr[0]}")
        print(f"  Ethernet: {ethernet['src']} -> {ethernet['dst']}")
        print(f"  IP: {ip['src']} -> {ip['dst']} (TTL: {ip['ttl']})")
        
        if transport:
            print(f"  {transport['name']}: {transport.get('sport', '')} -> {transport.get('dport', '')}")
            if transport.get('flags'):
                print(f"  Flags: {transport['flags']}")
            if transport.get('payload'):
                payload = transport['payload'][:32].hex()
                print(f"  Payload: {payload}...")
        
        print("")
    
    def decode_ethernet(self, data: bytes) -> Dict:
        """Decode Ethernet header"""
        if len(data) < 14:
            return None
        
        dst_mac = ':'.join(f'{b:02x}' for b in data[:6])
        src_mac = ':'.join(f'{b:02x}' for b in data[6:12])
        eth_type = struct.unpack('>H', data[12:14])[0]
        
        return {
            'dst': dst_mac,
            'src': src_mac,
            'type': eth_type
        }
    
    def decode_ip(self, data: bytes) -> Dict:
        """Decode IP header"""
        if len(data) < 20:
            return None
        
        # Parse IP header
        version_ihl = data[0]
        version = version_ihl >> 4
        ihl = (version_ihl & 0xF) * 4
        
        if version != 4:
            return None
        
        tos = data[1]
        total_len = struct.unpack('>H', data[2:4])[0]
        identification = struct.unpack('>H', data[4:6])[0]
        flags_offset = struct.unpack('>H', data[6:8])[0]
        ttl = data[8]
        protocol = data[9]
        checksum = struct.unpack('>H', data[10:12])[0]
        src_ip = socket.inet_ntoa(data[12:16])
        dst_ip = socket.inet_ntoa(data[16:20])
        
        return {
            'version': version,
            'ihl': ihl,
            'tos': tos,
            'total_len': total_len,
            'id': identification,
            'flags_offset': flags_offset,
            'ttl': ttl,
            'protocol': protocol,
            'checksum': checksum,
            'src': src_ip,
            'dst': dst_ip,
            'data': data[ihl:]
        }
    
    def decode_transport(self, data: bytes, protocol: int) -> Dict:
        """Decode transport protocol (TCP, UDP, ICMP)"""
        if protocol == 6:  # TCP
            return self.decode_tcp(data)
        elif protocol == 17:  # UDP
            return self.decode_udp(data)
        elif protocol == 1:  # ICMP
            return self.decode_icmp(data)
        else:
            return {'name': f'Protocol-{protocol}'}
    
    def decode_tcp(self, data: bytes) -> Dict:
        """Decode TCP segment"""
        if len(data) < 20:
            return None
        
        sport = struct.unpack('>H', data[:2])[0]
        dport = struct.unpack('>H', data[2:4])[0]
        seq = struct.unpack('>I', data[4:8])[0]
        ack = struct.unpack('>I', data[8:12])[0]
        offset_flags = struct.unpack('>H', data[12:14])[0]
        window = struct.unpack('>H', data[14:16])[0]
        checksum = struct.unpack('>H', data[16:18])[0]
        urgent = struct.unpack('>H', data[18:20])[0]
        
        # Parse flags
        flags = []
        flag_names = {
            0x01: 'FIN',
            0x02: 'SYN',
            0x04: 'RST',
            0x08: 'PSH',
            0x10: 'ACK',
            0x20: 'URG',
            0x40: 'ECE',
            0x80: 'CWR'
        }
        for flag_bit, flag_name in flag_names.items():
            if offset_flags & flag_bit:
                flags.append(flag_name)
        
        return {
            'name': 'TCP',
            'sport': sport,
            'dport': dport,
            'seq': seq,
            'ack': ack,
            'flags': ','.join(flags),
            'window': window,
            'checksum': checksum,
            'urgent': urgent,
            'payload': data[20:]
        }
    
    def decode_udp(self, data: bytes) -> Dict:
        """Decode UDP datagram"""
        if len(data) < 8:
            return None
        
        sport = struct.unpack('>H', data[:2])[0]
        dport = struct.unpack('>H', data[2:4])[0]
        length = struct.unpack('>H', data[4:6])[0]
        checksum = struct.unpack('>H', data[6:8])[0]
        
        return {
            'name': 'UDP',
            'sport': sport,
            'dport': dport,
            'length': length,
            'checksum': checksum,
            'payload': data[8:]
        }
    
    def decode_icmp(self, data: bytes) -> Dict:
        """Decode ICMP message"""
        if len(data) < 4:
            return None
        
        icmp_type = data[0]
        icmp_code = data[1]
        checksum = struct.unpack('>H', data[2:4])[0]
        
        type_names = {
            0: 'Echo Reply',
            3: 'Destination Unreachable',
            8: 'Echo Request',
            11: 'Time Exceeded'
        }
        
        return {
            'name': 'ICMP',
            'type': icmp_type,
            'type_name': type_names.get(icmp_type, 'Unknown'),
            'code': icmp_code,
            'checksum': checksum,
            'payload': data[4:]
        }
    
    def close(self):
        """Close the socket"""
        self.running = False
        if self.socket:
            self.socket.close()
        print("\n[*] Packet sniffer stopped")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Packet Sniffer")
    parser.add_argument('-i', '--interface', help='Network interface')
    
    args = parser.parse_args()
    
    sniffer = PacketSniffer(args.interface)
    
    try:
        sniffer.start()
    except KeyboardInterrupt:
        sniffer.close()

if __name__ == "__main__":
    main()
```

---

## 9. Network Monitoring

### Network Traffic Monitor with Statistics

```python
#!/usr/bin/env python3
"""
traffic_monitor.py - Network traffic monitor with real-time statistics
"""

import socket
import time
import threading
from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, List, Any

@dataclass
class TrafficStats:
    """Traffic statistics for a protocol or host"""
    bytes_rx: int = 0
    bytes_tx: int = 0
    packets_rx: int = 0
    packets_tx: int = 0
    connections: int = 0

class TrafficMonitor:
    """
    Real-time network traffic monitor
    """
    
    def __init__(self, interface: str = None):
        self.interface = interface
        self.socket = None
        self.running = False
        self.stats = {
            'protocols': defaultdict(TrafficStats),
            'hosts': defaultdict(TrafficStats)
        }
        self.tcp_connections = {}
        self.lock = threading.Lock()
    
    def start(self):
        """Start traffic monitoring"""
        try:
            self.socket = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.ntohs(3))
            self.running = True
            
            print("[*] Traffic monitor started")
            print("[*] Press Ctrl+C to stop\n")
            
            # Start statistics reporting thread
            report_thread = threading.Thread(target=self.report_stats, daemon=True)
            report_thread.start()
            
            while self.running:
                try:
                    data, addr = self.socket.recvfrom(65536)
                    self.process_packet(data)
                except KeyboardInterrupt:
                    break
                except Exception as e:
                    print(f"Error: {e}")
                    
        except PermissionError:
            print("Error: Traffic monitoring requires root privileges")
        finally:
            self.close()
    
    def process_packet(self, data: bytes):
        """Process a captured packet"""
        # Extract IP header
        if len(data) < 34:  # Minimum: Ethernet(14) + IP(20)
            return
        
        # Parse IP header
        ip_header = data[14:34]
        version = ip_header[0] >> 4
        
        if version == 4:
            self.process_ipv4(data)
        elif version == 6:
            self.process_ipv6(data)
    
    def process_ipv4(self, data: bytes):
        """Process IPv4 packet"""
        # Parse IPv4 header
        src_ip = socket.inet_ntoa(data[26:30])
        dst_ip = socket.inet_ntoa(data[30:34])
        protocol = data[23]
        total_len = struct.unpack('>H', data[16:18])[0]
        
        # Update host statistics
        with self.lock:
            self.stats['hosts'][src_ip].bytes_tx += total_len
            self.stats['hosts'][src_ip].packets_tx += 1
            self.stats['hosts'][dst_ip].bytes_rx += total_len
            self.stats['hosts'][dst_ip].packets_rx += 1
    
    def process_ipv6(self, data: bytes):
        """Process IPv6 packet (simplified)"""
        # IPv6 header is at offset 14
        if len(data) < 54:  # Ethernet(14) + IPv6(40)
            return
        
        src_ip = self.bytes_to_ipv6(data[22:38])
        dst_ip = self.bytes_to_ipv6(data[38:54])
        payload_len = struct.unpack('>H', data[18:20])[0]
        
        # Update host statistics
        with self.lock:
            self.stats['hosts'][src_ip].bytes_tx += (40 + payload_len)
            self.stats['hosts'][src_ip].packets_tx += 1
            self.stats['hosts'][dst_ip].bytes_rx += (40 + payload_len)
            self.stats['hosts'][dst_ip].packets_rx += 1
    
    def bytes_to_ipv6(self, data: bytes) -> str:
        """Convert 16 bytes to IPv6 string"""
        parts = []
        for i in range(0, 16, 2):
            parts.append(f'{data[i]:02x}{data[i+1]:02x}')
        return ':'.join(parts)
    
    def report_stats(self):
        """Report traffic statistics periodically"""
        while self.running:
            time.sleep(5)
            self.display_stats()
    
    def display_stats(self):
        """Display traffic statistics"""
        with self.lock:
            print("\n" + "=" * 60)
            print("Traffic Statistics")
            print("=" * 60)
            
            # Top hosts by traffic
            print("\nTop Hosts by Traffic:")
            hosts = sorted(
                self.stats['hosts'].items(),
                key=lambda x: x[1].bytes_rx + x[1].bytes_tx,
                reverse=True
            )[:10]
            
            for host, stats in hosts:
                total_bytes = stats.bytes_rx + stats.bytes_tx
                total_mb = total_bytes / (1024 * 1024)
                print(f"  {host:<20} TX: {stats.bytes_tx/1024:>8.1f}KB "
                      f"RX: {stats.bytes_rx/1024:>8.1f}KB "
                      f"Total: {total_mb:>6.2f}MB "
                      f"Packets: {stats.packets_rx + stats.packets_tx}")
            
            # Total traffic
            total_rx = sum(s.bytes_rx for s in self.stats['hosts'].values())
            total_tx = sum(s.bytes_tx for s in self.stats['hosts'].values())
            total_mb = (total_rx + total_tx) / (1024 * 1024)
            
            print(f"\nTotal Traffic:")
            print(f"  RX: {total_rx/1024/1024:.2f} MB")
            print(f"  TX: {total_tx/1024/1024:.2f} MB")
            print(f"  Total: {total_mb:.2f} MB")
            print("=" * 60)
    
    def close(self):
        """Close the monitor"""
        self.running = False
        if self.socket:
            self.socket.close()
        print("\n[*] Traffic monitor stopped")

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Traffic Monitor")
    parser.add_argument('-i', '--interface', help='Network interface')
    
    args = parser.parse_args()
    
    monitor = TrafficMonitor(args.interface)
    
    try:
        monitor.start()
    except KeyboardInterrupt:
        monitor.close()

if __name__ == "__main__":
    import struct
    main()
```

---

## 10. Security Tools

### Port Scanner with OS Detection

```python
#!/usr/bin/env python3
"""
port_scanner.py - Advanced port scanner with OS detection
"""

import socket
import threading
import queue
import time
import sys
from typing import Dict, List, Tuple

class PortScanner:
    """
    Advanced port scanner with OS fingerprinting
    """
    
    def __init__(self, target: str, num_threads: int = 20):
        self.target = target
        self.num_threads = num_threads
        self.open_ports = {}
        self.lock = threading.Lock()
        self.queue = queue.Queue()
        self.running = False
    
    def scan_ports(self, ports: List[int], timeout: float = 1.0) -> Dict[int, Dict]:
        """Scan a list of ports"""
        self.running = True
        self.open_ports = {}
        
        # Queue all ports
        for port in ports:
            self.queue.put(port)
        
        # Start worker threads
        threads = []
        for i in range(self.num_threads):
            thread = threading.Thread(
                target=self.scan_worker,
                args=(timeout,),
                daemon=True
            )
            thread.start()
            threads.append(thread)
        
        # Wait for completion
        self.queue.join()
        self.running = False
        
        # Wait for threads to finish
        for thread in threads:
            thread.join(timeout=1.0)
        
        return self.open_ports
    
    def scan_worker(self, timeout: float):
        """Worker thread for scanning ports"""
        while self.running:
            try:
                port = self.queue.get(timeout=0.1)
            except queue.Empty:
                if not self.running:
                    break
                continue
            
            # Scan port
            result = self.check_port(port, timeout)
            
            if result:
                with self.lock:
                    self.open_ports[port] = result
            
            self.queue.task_done()
    
    def check_port(self, port: int, timeout: float) -> Dict:
        """Check if a port is open"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            start_time = time.time()
            result = sock.connect_ex((self.target, port))
            end_time = time.time()
            sock.close()
            
            if result == 0:
                # Port is open
                # Try to detect service
                service = self.detect_service(port)
                return {
                    'port': port,
                    'service': service,
                    'response_time': end_time - start_time
                }
            
        except:
            pass
        
        return None
    
    def detect_service(self, port: int) -> str:
        """Detect service on a port"""
        common_services = {
            21: 'FTP',
            22: 'SSH',
            23: 'Telnet',
            25: 'SMTP',
            53: 'DNS',
            80: 'HTTP',
            110: 'POP3',
            111: 'RPC',
            135: 'MSRPC',
            139: 'NetBIOS',
            143: 'IMAP',
            443: 'HTTPS',
            445: 'SMB',
            993: 'IMAPS',
            995: 'POP3S',
            3306: 'MySQL',
            3389: 'RDP',
            5432: 'PostgreSQL',
            8080: 'HTTP-Alt'
        }
        
        # Try to connect and read banner
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(3.0)
            sock.connect((self.target, port))
            sock.send(b'\n')
            banner = sock.recv(1024).decode('utf-8', errors='ignore')
            sock.close()
            
            # Check for known services
            if 'SSH' in banner.upper():
                return 'SSH'
            elif 'HTTP' in banner.upper():
                return 'HTTP'
            elif 'SMTP' in banner.upper():
                return 'SMTP'
            elif 'FTP' in banner.upper():
                return 'FTP'
            
        except:
            pass
        
        return common_services.get(port, 'Unknown')
    
    def detect_os(self) -> str:
        """Detect operating system using TTL"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
            sock.settimeout(2.0)
            
            # Send ICMP echo request
            packet = self.build_icmp_packet()
            sock.sendto(packet, (self.target, 0))
            
            # Wait for response
            data, addr = sock.recvfrom(1024)
            sock.close()
            
            # Extract TTL from IP header
            ttl = data[8]
            
            # Determine OS based on TTL
            if ttl <= 64:
                return 'Linux/Unix'
            elif ttl <= 128:
                return 'Windows'
            else:
                return 'Unknown'
            
        except:
            return 'Unknown'
    
    def build_icmp_packet(self) -> bytes:
        """Build ICMP echo request packet"""
        # ICMP header: Type(1) + Code(1) + Checksum(2) + ID(2) + Seq(2)
        type_code = 0x0800  # Echo request
        id_seq = 0x0001     # ID and sequence
        
        # Build packet
        packet = struct.pack('>HH', type_code, id_seq)
        checksum = self.calculate_checksum(packet)
        packet = struct.pack('>HH', type_code, checksum) + packet[2:4]
        
        return packet
    
    def calculate_checksum(self, data: bytes) -> int:
        """Calculate ICMP checksum"""
        if len(data) % 2 != 0:
            data += b'\x00'
        
        checksum = 0
        for i in range(0, len(data), 2):
            word = (data[i] << 8) + data[i + 1]
            checksum += word
            checksum = (checksum & 0xFFFF) + (checksum >> 16)
        
        return ~checksum & 0xFFFF

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Port Scanner")
    parser.add_argument('target', help='Target IP or hostname')
    parser.add_argument('-p', '--ports', default='1-1000', help='Port range')
    parser.add_argument('-t', '--threads', type=int, default=20, help='Number of threads')
    
    args = parser.parse_args()
    
    # Parse port range
    if '-' in args.ports:
        start, end = args.ports.split('-')
        ports = list(range(int(start), int(end) + 1))
    else:
        ports = [int(p) for p in args.ports.split(',')]
    
    print(f"Scanning {args.target}...")
    print(f"Ports: {len(ports)}")
    print(f"Threads: {args.threads}\n")
    
    scanner = PortScanner(args.target, args.threads)
    
    # Detect OS
    print("Detecting OS...")
    os_info = scanner.detect_os()
    print(f"OS: {os_info}\n")
    
    # Scan ports
    print("Scanning ports...")
    open_ports = scanner.scan_ports(ports)
    
    if open_ports:
        print("\nOpen Ports:")
        print("-" * 40)
        for port, info in sorted(open_ports.items()):
            service = info.get('service', 'Unknown')
            response_time = info.get('response_time', 0) * 1000
            print(f"  {port:>5}: {service:<20} ({response_time:.1f}ms)")
    else:
        print("\nNo open ports found")
    
    print("\nScan complete")

if __name__ == "__main__":
    import struct
    main()
```

---

**[END OF APPENDIX C]**
