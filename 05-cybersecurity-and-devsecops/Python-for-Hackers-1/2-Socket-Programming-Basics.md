# Phase 1: Foundations & Network Fundamentals
## Part 2: Socket Programming Basics

### The Target: Understanding Network Communication

By the end of this part, you will:
- Understand what sockets are and how they work
- Build a TCP client-server application from scratch
- Build a UDP client-server application
- Create a simple network sniffer
- Understand the difference between TCP and UDP protocols

### The Concept: What Are Sockets?

Think of a socket like a telephone line between two computers. Just as you need a phone to call someone, your computer needs a socket to communicate over a network.

**Imagine this scenario:**
- You want to order pizza (request data)
- You pick up your phone (create a socket)
- You dial the pizza place's number (connect to server IP and port)
- You talk to the person who answers (send request)
- They take your order and give you a confirmation (receive response)
- You hang up (close connection)

This is exactly how sockets work in networking! Your program creates a socket, connects to a server, sends data, receives a response, and closes the connection.

### The Implementation: TCP Client-Server

Let's start with TCP (Transmission Control Protocol), which is like a phone call where you establish a connection, talk, and hang up. TCP is reliable and ensures all data arrives in order.

#### File: `~/hacking-toolkit/recon/tcp_server.py`

```python
#!/usr/bin/env python3
"""
tcp_server.py - A basic TCP echo server
This server listens for connections and echoes back whatever it receives.
Used to demonstrate fundamental socket programming concepts.
"""

import socket
import sys
import threading
import time
from typing import Optional

class TCPEchoServer:
    """
    A TCP echo server that handles multiple clients concurrently.
    For each client connection, it creates a new thread to handle communication.
    """
    
    def __init__(self, host: str = '0.0.0.0', port: int = 9999):
        """
        Initialize the TCP server
        
        Args:
            host: IP address to bind to (0.0.0.0 means all interfaces)
            port: Port number to listen on
        """
        self.host = host
        self.port = port
        self.server_socket: Optional[socket.socket] = None
        self.running = False
        self.clients = []  # Track connected clients
        
    def start(self):
        """
        Start the TCP server and begin listening for connections
        """
        try:
            # Create a TCP socket
            # socket.AF_INET = IPv4, socket.SOCK_STREAM = TCP
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            
            # Allow reuse of the address (helps when restarting server)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            # Bind the socket to the host and port
            # This is like "claiming" this address for our server
            self.server_socket.bind((self.host, self.port))
            
            # Start listening for connections
            # The argument is the maximum number of queued connections
            self.server_socket.listen(5)
            
            self.running = True
            print(f"[*] TCP Echo Server listening on {self.host}:{self.port}")
            
            # Main loop to accept connections
            while self.running:
                try:
                    # Accept a new connection
                    # This blocks until a client connects
                    client_socket, client_address = self.server_socket.accept()
                    print(f"[+] New connection from {client_address[0]}:{client_address[1]}")
                    
                    # Create a new thread to handle this client
                    # This allows multiple clients to connect simultaneously
                    client_thread = threading.Thread(
                        target=self.handle_client,
                        args=(client_socket, client_address)
                    )
                    client_thread.daemon = True  # Thread exits when main thread exits
                    client_thread.start()
                    
                except socket.timeout:
                    # No connection received within timeout period
                    continue
                except Exception as e:
                    if self.running:  # Only log if not shutting down
                        print(f"[-] Error accepting connection: {e}")
                        
        except KeyboardInterrupt:
            print("\n[!] Server stopped by user")
        except Exception as e:
            print(f"[-] Server error: {e}")
        finally:
            self.stop()
    
    def handle_client(self, client_socket: socket.socket, client_address: tuple):
        """
        Handle communication with a connected client
        
        Args:
            client_socket: The socket for this client connection
            client_address: The client's IP address and port
        """
        try:
            # Set a timeout for receiving data (prevents hanging)
            client_socket.settimeout(5.0)
            
            # Keep track of this client
            self.clients.append(client_socket)
            
            # Send welcome message to client
            welcome_msg = b"Welcome to the TCP Echo Server!\n"
            client_socket.send(welcome_msg)
            
            while True:
                try:
                    # Receive data from client (up to 1024 bytes)
                    # This blocks until data is received or connection closes
                    data = client_socket.recv(1024)
                    
                    if not data:
                        # Client disconnected gracefully
                        print(f"[*] Client {client_address[0]}:{client_address[1]} disconnected")
                        break
                    
                    # Echo the data back to the client
                    # This is the "echo" functionality
                    client_socket.send(data)
                    
                    # Log the transaction
                    print(f"[*] Received from {client_address[0]}: {data.decode().strip()}")
                    
                except socket.timeout:
                    # No data received within timeout period, continue loop
                    continue
                except ConnectionResetError:
                    # Client disconnected abruptly
                    print(f"[!] Client {client_address[0]}:{client_address[1]} disconnected abruptly")
                    break
                except socket.error as e:
                    print(f"[-] Socket error: {e}")
                    break
                    
        except Exception as e:
            print(f"[-] Error handling client {client_address}: {e}")
        finally:
            # Clean up client connection
            if client_socket in self.clients:
                self.clients.remove(client_socket)
            client_socket.close()
            print(f"[*] Connection to {client_address[0]}:{client_address[1]} closed")
    
    def stop(self):
        """
        Stop the server and clean up resources
        """
        print("[*] Shutting down server...")
        self.running = False
        
        # Close all client connections
        for client in self.clients:
            try:
                client.close()
            except:
                pass
        self.clients.clear()
        
        # Close server socket
        if self.server_socket:
            self.server_socket.close()
            self.server_socket = None
            
        print("[*] Server stopped")

def main():
    """Main entry point for the TCP echo server"""
    # Parse command line arguments if provided
    host = '0.0.0.0'  # Listen on all interfaces
    port = 9999       # Default port
    
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print(f"[-] Invalid port: {sys.argv[1]}")
            sys.exit(1)
    
    # Create and start the server
    server = TCPEchoServer(host, port)
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Interrupt received, shutting down...")
        server.stop()

if __name__ == "__main__":
    main()
```

#### File: `~/hacking-toolkit/recon/tcp_client.py`

```python
#!/usr/bin/env python3
"""
tcp_client.py - A basic TCP client for testing the echo server
This client connects to the echo server, sends messages, and displays responses.
"""

import socket
import sys
import time
from typing import Optional

class TCPEchoClient:
    """
    A TCP client that connects to an echo server and sends/receives messages.
    Demonstrates how to establish a connection, send data, and receive responses.
    """
    
    def __init__(self, host: str = '127.0.0.1', port: int = 9999):
        """
        Initialize the TCP client
        
        Args:
            host: Server IP address
            port: Server port number
        """
        self.host = host
        self.port = port
        self.socket: Optional[socket.socket] = None
        self.connected = False
    
    def connect(self) -> bool:
        """
        Establish connection to the server
        
        Returns:
            bool: True if connection successful, False otherwise
        """
        try:
            # Create a TCP socket
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            
            # Set connection timeout (3 seconds)
            self.socket.settimeout(3.0)
            
            # Connect to the server
            # This is like dialing the phone number
            self.socket.connect((self.host, self.port))
            self.connected = True
            
            print(f"[+] Connected to {self.host}:{self.port}")
            
            # Receive welcome message
            welcome = self.socket.recv(1024)
            print(f"[*] Server: {welcome.decode()}")
            
            return True
            
        except socket.timeout:
            print(f"[-] Connection to {self.host}:{self.port} timed out")
        except ConnectionRefusedError:
            print(f"[-] Connection refused - Is the server running?")
        except Exception as e:
            print(f"[-] Connection error: {e}")
        
        return False
    
    def send_message(self, message: str) -> Optional[str]:
        """
        Send a message to the server and receive the response
        
        Args:
            message: The message to send
            
        Returns:
            Optional[str]: The server's response, or None if failed
        """
        if not self.connected or not self.socket:
            print("[-] Not connected to server")
            return None
        
        try:
            # Send the message (encode string to bytes)
            self.socket.send(message.encode('utf-8'))
            print(f"[*] Sent: {message}")
            
            # Receive the response (this is the echo)
            response = self.socket.recv(1024)
            decoded_response = response.decode('utf-8')
            print(f"[*] Received: {decoded_response}")
            
            return decoded_response
            
        except socket.timeout:
            print("[-] Response timeout")
        except ConnectionError:
            print("[-] Connection lost")
            self.connected = False
        except Exception as e:
            print(f"[-] Error sending message: {e}")
        
        return None
    
    def disconnect(self):
        """
        Close the connection to the server
        """
        if self.socket:
            try:
                self.socket.close()
                print("[*] Disconnected from server")
            except:
                pass
            self.socket = None
        
        self.connected = False

def interactive_client():
    """
    Run an interactive client that allows sending messages from the command line
    """
    # Get server details from user
    host = input("Enter server IP (default: 127.0.0.1): ").strip() or '127.0.0.1'
    port_input = input("Enter server port (default: 9999): ").strip()
    port = int(port_input) if port_input else 9999
    
    # Create client and connect
    client = TCPEchoClient(host, port)
    
    if not client.connect():
        return
    
    print("\n[*] Type 'quit' to exit, 'help' for commands")
    
    while True:
        try:
            # Get user input
            message = input("\nEnter message: ").strip()
            
            if not message:
                continue
            
            if message.lower() == 'quit':
                break
            elif message.lower() == 'help':
                print("Commands:")
                print("  quit - Exit the client")
                print("  help - Show this help message")
                continue
            
            # Send message and get response
            response = client.send_message(message)
            if response is None:
                # Failed to send, attempt to reconnect
                print("[*] Attempting to reconnect...")
                if not client.connect():
                    break
                continue
                
        except KeyboardInterrupt:
            print("\n[!] Interrupted")
            break
        except EOFError:
            break
    
    client.disconnect()
    print("[*] Client exited")

def test_client():
    """
    Automated test client that sends a series of test messages
    """
    client = TCPEchoClient('127.0.0.1', 9999)
    
    if not client.connect():
        return
    
    print("\n[*] Running automated tests...")
    
    test_messages = [
        "Hello, Server!",
        "This is a test message.",
        "1234567890",
        "!@#$%^&*()",
        "Python for Hackers is awesome!",
        "Testing 123..."
    ]
    
    for i, msg in enumerate(test_messages, 1):
        print(f"\n[Test {i}/{len(test_messages)}]")
        response = client.send_message(msg)
        if response is None:
            print("[-] Test failed!")
            break
        time.sleep(0.5)  # Small delay between tests
    
    print("\n[*] Tests completed")
    client.disconnect()

def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] == '--test':
        test_client()
    else:
        interactive_client()

if __name__ == "__main__":
    main()
```

### The Verification: Testing TCP Client-Server

Now let's test our TCP implementation:

```bash
# Terminal 1: Start the server
cd ~/hacking-toolkit
source hacker-env/bin/activate
cd recon
python3 tcp_server.py

# Terminal 2: Run the client in interactive mode
cd ~/hacking-toolkit
source hacker-env/bin/activate
cd recon
python3 tcp_client.py

# In the client, try these commands:
Enter server IP (default: 127.0.0.1): 
Enter server port (default: 9999): 

Enter message: Hello Server!
Enter message: This is a test
Enter message: quit

# Or run the automated test:
python3 tcp_client.py --test
```

**Expected Server Output:**
```
[*] TCP Echo Server listening on 0.0.0.0:9999
[+] New connection from 127.0.0.1:54321
[*] Received from 127.0.0.1: Hello Server!
[*] Received from 127.0.0.1: This is a test
[*] Client 127.0.0.1:54321 disconnected
[*] Connection to 127.0.0.1:54321 closed
```

**Expected Client Output:**
```
[+] Connected to 127.0.0.1:9999
[*] Server: Welcome to the TCP Echo Server!

Enter message: Hello Server!
[*] Sent: Hello Server!
[*] Received: Hello Server!

Enter message: quit
[*] Disconnected from server
[*] Client exited
```

### The Implementation: UDP Client-Server

Now let's build UDP (User Datagram Protocol), which is like sending postcards. UDP doesn't establish a connection - you just send packets and hope they arrive. It's faster but less reliable than TCP.

#### File: `~/hacking-toolkit/recon/udp_server.py`

```python
#!/usr/bin/env python3
"""
udp_server.py - A basic UDP echo server
UDP is connectionless - each packet is handled independently.
This server receives UDP datagrams and sends responses.
"""

import socket
import sys

class UDPEchoServer:
    """
    A UDP echo server that responds to datagrams from any client.
    Unlike TCP, there's no connection - each datagram is independent.
    """
    
    def __init__(self, host: str = '0.0.0.0', port: int = 9998):
        """
        Initialize the UDP server
        
        Args:
            host: IP address to bind to
            port: Port number to listen on
        """
        self.host = host
        self.port = port
        self.socket: socket.socket = None
        self.running = False
    
    def start(self):
        """
        Start the UDP server and begin listening for datagrams
        """
        try:
            # Create a UDP socket
            # socket.SOCK_DGRAM = UDP (instead of SOCK_STREAM for TCP)
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            
            # Allow address reuse
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            # Bind to address
            self.socket.bind((self.host, self.port))
            
            self.running = True
            print(f"[*] UDP Echo Server listening on {self.host}:{self.port}")
            print("[*] Press Ctrl+C to stop")
            
            while self.running:
                try:
                    # Receive data from any client
                    # 4096 is the maximum buffer size
                    # UDP doesn't have connections, so we get the address too
                    data, client_address = self.socket.recvfrom(4096)
                    
                    if data:
                        print(f"[*] Received from {client_address[0]}:{client_address[1]}: {data.decode().strip()}")
                        
                        # Echo the data back to the client
                        self.socket.sendto(data, client_address)
                        print(f"[*] Echoed back to {client_address[0]}:{client_address[1]}")
                
                except socket.timeout:
                    # Continue if timeout (if we set one)
                    continue
                except Exception as e:
                    if self.running:
                        print(f"[-] Error: {e}")
                        
        except KeyboardInterrupt:
            print("\n[!] Server stopped by user")
        except Exception as e:
            print(f"[-] Server error: {e}")
        finally:
            self.stop()
    
    def stop(self):
        """Stop the server and clean up"""
        print("[*] Shutting down UDP server...")
        self.running = False
        if self.socket:
            self.socket.close()
        print("[*] Server stopped")

def main():
    """Main entry point"""
    host = '0.0.0.0'
    port = 9998
    
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print(f"[-] Invalid port: {sys.argv[1]}")
            sys.exit(1)
    
    server = UDPEchoServer(host, port)
    try:
        server.start()
    except KeyboardInterrupt:
        print("\n[!] Interrupt received, shutting down...")
        server.stop()

if __name__ == "__main__":
    main()
```

#### File: `~/hacking-toolkit/recon/udp_client.py`

```python
#!/usr/bin/env python3
"""
udp_client.py - A basic UDP client for testing
UDP is connectionless - we just send datagrams and wait for responses.
"""

import socket
import sys
import time

class UDPEchoClient:
    """
    A UDP client that sends datagrams to a server and receives responses.
    Since UDP is connectionless, we don't need to establish a connection.
    """
    
    def __init__(self, host: str = '127.0.0.1', port: int = 9998):
        """
        Initialize the UDP client
        
        Args:
            host: Server IP address
            port: Server port number
        """
        self.host = host
        self.port = port
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.socket.settimeout(3.0)  # 3 second timeout for responses
    
    def send_datagram(self, message: str) -> bool:
        """
        Send a datagram to the server and wait for a response
        
        Args:
            message: The message to send
            
        Returns:
            bool: True if response received, False otherwise
        """
        try:
            # Send the message (no connection needed!)
            self.socket.sendto(message.encode('utf-8'), (self.host, self.port))
            print(f"[*] Sent: {message}")
            
            # Wait for response
            # UDP doesn't guarantee delivery, so we might not get one
            response, server_address = self.socket.recvfrom(4096)
            decoded_response = response.decode('utf-8')
            print(f"[*] Received: {decoded_response}")
            print(f"[*] From: {server_address[0]}:{server_address[1]}")
            
            return True
            
        except socket.timeout:
            print("[-] No response (timeout) - UDP packet may have been lost")
        except ConnectionError:
            print("[-] Connection error (UDP is connectionless, but socket may be invalid)")
        except Exception as e:
            print(f"[-] Error sending datagram: {e}")
        
        return False
    
    def close(self):
        """Close the socket"""
        if self.socket:
            self.socket.close()

def interactive_client():
    """Run interactive UDP client"""
    host = input("Enter server IP (default: 127.0.0.1): ").strip() or '127.0.0.1'
    port_input = input("Enter server port (default: 9998): ").strip()
    port = int(port_input) if port_input else 9998
    
    client = UDPEchoClient(host, port)
    
    print("\n[*] UDP Client ready - messages may be lost!")
    print("[*] Type 'quit' to exit, 'help' for commands")
    
    while True:
        try:
            message = input("\nEnter message: ").strip()
            
            if not message:
                continue
            
            if message.lower() == 'quit':
                break
            elif message.lower() == 'help':
                print("Commands:")
                print("  quit - Exit the client")
                print("  help - Show this help message")
                print("\nNote: UDP is unreliable - some messages may be lost")
                continue
            
            client.send_datagram(message)
            
        except KeyboardInterrupt:
            print("\n[!] Interrupted")
            break
        except EOFError:
            break
    
    client.close()
    print("[*] Client exited")

def stress_test():
    """
    Send multiple packets to test UDP reliability
    """
    client = UDPEchoClient('127.0.0.1', 9998)
    
    print("\n[*] Running UDP stress test...")
    print("[*] Sending 10 packets (some may be lost)")
    
    sent = 0
    received = 0
    
    for i in range(10):
        message = f"Packet {i+1}"
        if client.send_datagram(message):
            received += 1
        sent += 1
        time.sleep(0.2)  # Small delay to avoid flooding
    
    print(f"\n[*] Results: {received}/{sent} packets received")
    print(f"[*] Loss rate: {(1 - received/sent) * 100:.1f}%")
    
    client.close()

def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] == '--stress':
        stress_test()
    else:
        interactive_client()

if __name__ == "__main__":
    main()
```

### The Verification: Testing UDP Client-Server

```bash
# Terminal 1: Start UDP server
cd ~/hacking-toolkit/recon
python3 udp_server.py

# Terminal 2: Run UDP client
cd ~/hacking-toolkit/recon
python3 udp_client.py

# Terminal 2: Run stress test
python3 udp_client.py --stress
```

**Expected UDP Server Output:**
```
[*] UDP Echo Server listening on 0.0.0.0:9998
[*] Press Ctrl+C to stop
[*] Received from 127.0.0.1:54322: Hello UDP!
[*] Echoed back to 127.0.0.1:54322
```

### The Implementation: Network Sniffer

Now let's build a simple network sniffer that captures and analyzes packets. This is a foundational tool for network reconnaissance.

#### File: `~/hacking-toolkit/recon/sniffer.py`

```python
#!/usr/bin/env python3
"""
sniffer.py - A basic network packet sniffer
This captures raw network packets and displays their contents.
Uses raw sockets to capture all incoming/outgoing traffic.
"""

import socket
import struct
import time
from typing import Optional, Tuple, Dict

class PacketSniffer:
    """
    A network packet sniffer that captures and analyzes IP packets
    """
    
    # Protocol numbers to names
    PROTOCOLS = {
        1: 'ICMP',
        6: 'TCP',
        17: 'UDP'
    }
    
    def __init__(self, interface: str = 'eth0'):
        """
        Initialize the packet sniffer
        
        Args:
            interface: Network interface to sniff on
        """
        self.interface = interface
        self.socket: Optional[socket.socket] = None
        self.running = False
        self.packet_count = 0
        
    def start(self):
        """
        Start sniffing packets
        Requires root privileges (sudo) to access raw sockets
        """
        try:
            # Create a raw socket
            # socket.AF_PACKET = Linux packet interface
            # socket.SOCK_RAW = Raw socket (captures all packets)
            # socket.htons(0x0800) = Capture all packets (Ethernet frame)
            self.socket = socket.socket(
                socket.AF_PACKET,
                socket.SOCK_RAW,
                socket.htons(0x0800)
            )
            
            # Bind to specific interface
            self.socket.bind((self.interface, 0))
            
            self.running = True
            print(f"[*] Packet sniffer started on {self.interface}")
            print("[*] Press Ctrl+C to stop")
            print("[*] Capturing packets...\n")
            
            while self.running:
                # Receive a packet (up to 65535 bytes)
                packet, addr = self.socket.recvfrom(65535)
                self.packet_count += 1
                
                # Parse the packet
                self.parse_packet(packet, addr)
                
        except PermissionError:
            print("[-] Permission denied! Run with sudo (root privileges required)")
        except KeyboardInterrupt:
            print("\n[!] Sniffer stopped by user")
        except Exception as e:
            print(f"[-] Sniffer error: {e}")
        finally:
            self.stop()
    
    def parse_packet(self, packet: bytes, addr: Tuple):
        """
        Parse and display packet information
        
        Args:
            packet: Raw packet data
            addr: Address info (interface name)
        """
        try:
            # Parse Ethernet header (14 bytes)
            # Structure: dest_mac(6) + src_mac(6) + eth_type(2)
            eth_header = packet[:14]
            eth_unpacked = struct.unpack('!6s6sH', eth_header)
            
            eth_type = eth_unpacked[2]
            
            # Only process IP packets (type 0x0800)
            if eth_type == 0x0800:
                # Parse IP header (starts after Ethernet header)
                ip_header = packet[14:34]  # IP header is 20 bytes
                
                # Unpack IP header
                # Structure: ver_ihl(1) + tos(1) + total_len(2) + id(2) + 
                #           flags_frag(2) + ttl(1) + protocol(1) + checksum(2) +
                #           src_ip(4) + dest_ip(4)
                ip_unpacked = struct.unpack('!BBHHHBBH4s4s', ip_header)
                
                # Get IP header length (first 4 bits)
                ip_header_len = (ip_unpacked[0] & 0x0F) * 4
                
                # Extract important fields
                ttl = ip_unpacked[5]
                protocol = ip_unpacked[6]
                src_ip = socket.inet_ntoa(ip_unpacked[8])
                dest_ip = socket.inet_ntoa(ip_unpacked[9])
                
                # Get protocol name
                proto_name = self.PROTOCOLS.get(protocol, f'Unknown({protocol})')
                
                print(f"\n[Packet #{self.packet_count}]")
                print(f"[*] Source IP: {src_ip}")
                print(f"[*] Destination IP: {dest_ip}")
                print(f"[*] Protocol: {proto_name}")
                print(f"[*] TTL: {ttl}")
                
                # Parse TCP or UDP if applicable
                if protocol == 6 and len(packet) >= 54:  # TCP (20 bytes IP + 20 bytes TCP)
                    self.parse_tcp(packet[ip_header_len:], src_ip, dest_ip)
                elif protocol == 17 and len(packet) >= 42:  # UDP (20 bytes IP + 8 bytes UDP)
                    self.parse_udp(packet[ip_header_len:], src_ip, dest_ip)
                    
        except Exception as e:
            # Skip malformed packets
            pass
    
    def parse_tcp(self, tcp_data: bytes, src_ip: str, dest_ip: str):
        """
        Parse TCP segment
        """
        try:
            # TCP header is 20 bytes minimum
            # Structure: src_port(2) + dest_port(2) + seq(4) + ack(4) + 
            #           data_offset(1) + flags(1) + window(2) + checksum(2) + urgent(2)
            tcp_header = struct.unpack('!HHLLBBHHH', tcp_data[:20])
            
            src_port = tcp_header[0]
            dest_port = tcp_header[1]
            seq_num = tcp_header[2]
            ack_num = tcp_header[3]
            data_offset = (tcp_header[4] >> 4) * 4  # Convert to bytes
            
            print(f"[*] TCP: {src_ip}:{src_port} -> {dest_ip}:{dest_port}")
            print(f"[*] Seq: {seq_num}, Ack: {ack_num}")
            
        except:
            pass
    
    def parse_udp(self, udp_data: bytes, src_ip: str, dest_ip: str):
        """
        Parse UDP datagram
        """
        try:
            # UDP header is 8 bytes
            # Structure: src_port(2) + dest_port(2) + length(2) + checksum(2)
            udp_header = struct.unpack('!HHHH', udp_data[:8])
            
            src_port = udp_header[0]
            dest_port = udp_header[1]
            length = udp_header[2]
            
            print(f"[*] UDP: {src_ip}:{src_port} -> {dest_ip}:{dest_port}")
            print(f"[*] Length: {length} bytes")
            
        except:
            pass
    
    def stop(self):
        """
        Stop sniffing and clean up
        """
        print(f"\n[*] Packet sniffer stopped")
        print(f"[*] Total packets captured: {self.packet_count}")
        
        if self.socket:
            self.socket.close()
            self.socket = None
        
        self.running = False

def main():
    """Main entry point"""
    import sys
    
    # Get interface from command line, or use default
    interface = 'eth0'
    if len(sys.argv) > 1:
        interface = sys.argv[1]
    
    # Create and start sniffer
    sniffer = PacketSniffer(interface)
    try:
        sniffer.start()
    except KeyboardInterrupt:
        print("\n[!] Interrupt received, shutting down...")
        sniffer.stop()

if __name__ == "__main__":
    main()
```

### The Verification: Testing the Sniffer

```bash
# Start the sniffer (requires root)
sudo python3 sniffer.py eth0

# In another terminal, generate some traffic:
ping 8.8.8.8
curl http://google.com
python3 tcp_client.py --test

# Observe the captured packets
```

**Expected Output:**
```
[*] Packet sniffer started on eth0
[*] Press Ctrl+C to stop
[*] Capturing packets...

[Packet #1]
[*] Source IP: 192.168.1.100
[*] Destination IP: 8.8.8.8
[*] Protocol: ICMP
[*] TTL: 64

[Packet #2]
[*] Source IP: 192.168.1.100
[*] Destination IP: 142.250.185.142
[*] Protocol: TCP
[*] TTL: 64
[*] TCP: 192.168.1.100:45678 -> 142.250.185.142:443
[*] Seq: 1234567890, Ack: 987654321
```
