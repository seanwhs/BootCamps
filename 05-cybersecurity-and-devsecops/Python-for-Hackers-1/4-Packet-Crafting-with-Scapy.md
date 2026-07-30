# Phase 1: Foundations & Network Fundamentals
## Part 4: Packet Crafting with Scapy

### The Target: Packet Manipulation Framework

By the end of this part, you will:
- Understand the Scapy library and its capabilities
- Create custom network packets from scratch
- Build a packet crafting framework for protocol testing
- Implement packet sniffing and analysis tools
- Create a network relay/proxy for intercepting and modifying traffic
- Understand how to use Scapy for reconnaissance and manipulation

### The Concept: What is Packet Crafting?

Think of packet crafting like being a mail sorter in a post office. Normally, you just deliver mail (normal network traffic). But with packet crafting, you can:
- **Create new mail** from scratch (craft custom packets)
- **Modify existing mail** (change packet contents)
- **Read mail contents** (sniff and analyze packets)
- **Create fake mail** (spoof packets)
- **Redirect mail** (manipulate routing)

**Scapy** is Python's most powerful packet manipulation library. It allows you to:
- Create packets at any layer (Ethernet, IP, TCP, UDP, etc.)
- Send packets and receive responses
- Sniff network traffic
- Analyze packet contents
- Implement custom protocols

### The Implementation: Basic Scapy Operations

#### File: `~/hacking-toolkit/recon/packet_crafter.py`

```python
#!/usr/bin/env python3
"""
packet_crafter.py - Advanced Packet Crafting Framework with Scapy
This module provides a complete framework for creating, sending, and analyzing network packets.
"""

import sys
import time
import threading
from typing import Optional, List, Dict, Any, Tuple
from scapy.all import (
    IP, TCP, UDP, ICMP, Ether, ARP, DNS, DNSQR, DNSRR,
    sr1, srp, send, sniff, wrpcap, rdpcap,
    conf, RandIP, RandShort, RandMAC
)
from scapy.layers.inet import traceroute
import socket

# Try to import colorama for colored output
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    HAS_COLOR = True
except ImportError:
    class Fore:
        RED = GREEN = YELLOW = BLUE = CYAN = MAGENTA = WHITE = RESET = ''
    Style = Fore
    HAS_COLOR = False

class PacketCrafter:
    """
    A comprehensive packet crafting framework using Scapy.
    Provides methods for creating, sending, and analyzing network packets.
    """
    
    def __init__(self, verbose: bool = True):
        """
        Initialize the packet crafter
        
        Args:
            verbose: Enable verbose output
        """
        self.verbose = verbose
        self.packets_sent = 0
        self.packets_received = 0
        self.packet_log = []
        
        # Configure Scapy
        conf.verb = 1 if verbose else 0
        
    def log_packet(self, packet: Any, direction: str = 'sent'):
        """
        Log packet information
        
        Args:
            packet: Scapy packet object
            direction: 'sent' or 'received'
        """
        self.packet_log.append({
            'timestamp': time.time(),
            'direction': direction,
            'packet': packet
        })
        
        if self.verbose:
            print(f"[*] {direction.upper()} packet:")
            packet.show()
    
    def create_ip_packet(self, src_ip: str = None, dst_ip: str = None,
                         ttl: int = 64, flags: str = None) -> IP:
        """
        Create an IP packet
        
        Args:
            src_ip: Source IP address (None = random)
            dst_ip: Destination IP address
            ttl: Time To Live
            flags: IP flags ('DF', 'MF', etc.)
            
        Returns:
            Scapy IP layer
        """
        # Create IP packet
        ip = IP()
        
        # Set source IP (or randomize)
        if src_ip:
            ip.src = src_ip
        else:
            ip.src = RandIP()
        
        # Set destination IP
        if dst_ip:
            ip.dst = dst_ip
        else:
            ip.dst = '127.0.0.1'
        
        # Set TTL
        ip.ttl = ttl
        
        # Set flags
        if flags:
            ip.flags = flags
        
        return ip
    
    def create_tcp_packet(self, src_port: int = None, dst_port: int = 80,
                          flags: str = 'S', seq: int = None, ack: int = None) -> TCP:
        """
        Create a TCP packet
        
        Args:
            src_port: Source port (None = random)
            dst_port: Destination port
            flags: TCP flags ('S'=SYN, 'A'=ACK, 'F'=FIN, 'R'=RST, 'P'=PSH)
            seq: Sequence number (None = random)
            ack: Acknowledgment number (None = random)
            
        Returns:
            Scapy TCP layer
        """
        tcp = TCP()
        
        # Set source port (or randomize)
        if src_port:
            tcp.sport = src_port
        else:
            tcp.sport = RandShort()
        
        # Set destination port
        tcp.dport = dst_port
        
        # Set flags
        tcp.flags = flags
        
        # Set sequence number
        if seq:
            tcp.seq = seq
        else:
            tcp.seq = RandShort()
        
        # Set acknowledgment number
        if ack:
            tcp.ack = ack
        else:
            tcp.ack = RandShort()
        
        return tcp
    
    def create_udp_packet(self, src_port: int = None, dst_port: int = 53) -> UDP:
        """
        Create a UDP packet
        
        Args:
            src_port: Source port (None = random)
            dst_port: Destination port
            
        Returns:
            Scapy UDP layer
        """
        udp = UDP()
        
        # Set source port (or randomize)
        if src_port:
            udp.sport = src_port
        else:
            udp.sport = RandShort()
        
        # Set destination port
        udp.dport = dst_port
        
        return udp
    
    def create_icmp_packet(self, type: int = 8, code: int = 0,
                          payload: bytes = None) -> ICMP:
        """
        Create an ICMP packet
        
        Args:
            type: ICMP type (8 = Echo Request, 0 = Echo Reply)
            code: ICMP code
            payload: Custom payload
            
        Returns:
            Scapy ICMP layer
        """
        icmp = ICMP()
        icmp.type = type
        icmp.code = code
        
        if payload:
            icmp.payload = payload
        
        return icmp
    
    def craft_packet(self, layers: List[Any]) -> Any:
        """
        Craft a packet from multiple layers
        
        Args:
            layers: List of Scapy layers
            
        Returns:
            Combined packet
        """
        packet = layers[0]
        for layer in layers[1:]:
            packet = packet / layer
        return packet
    
    def send_packet(self, packet: Any, count: int = 1) -> List[Any]:
        """
        Send a packet (no response expected)
        
        Args:
            packet: Scapy packet to send
            count: Number of times to send
            
        Returns:
            List of sent packets
        """
        sent_packets = []
        
        for _ in range(count):
            try:
                send(packet, verbose=self.verbose)
                self.packets_sent += 1
                sent_packets.append(packet)
                self.log_packet(packet, 'sent')
            except Exception as e:
                print(f"[-] Error sending packet: {e}")
        
        return sent_packets
    
    def send_and_receive(self, packet: Any, timeout: int = 2,
                        retries: int = 2) -> Optional[Any]:
        """
        Send a packet and wait for a response
        
        Args:
            packet: Scapy packet to send
            timeout: Timeout in seconds
            retries: Number of retries
            
        Returns:
            Response packet or None
        """
        try:
            response = sr1(packet, timeout=timeout, retry=retries,
                          verbose=self.verbose)
            
            if response:
                self.packets_received += 1
                self.log_packet(response, 'received')
                return response
            else:
                print(f"[-] No response received")
                return None
                
        except Exception as e:
            print(f"[-] Error sending/receiving: {e}")
            return None
    
    def send_packet_loop(self, packet: Any, count: int = 10, delay: float = 0.1):
        """
        Send a packet multiple times in a loop
        
        Args:
            packet: Scapy packet to send
            count: Number of times to send
            delay: Delay between packets in seconds
        """
        print(f"[*] Sending {count} packets with {delay}s delay")
        
        for i in range(count):
            self.send_packet(packet, count=1)
            time.sleep(delay)
            if i % 10 == 0 and i > 0:
                print(f"[*] Sent {i}/{count} packets")
    
    def sniff_packets(self, count: int = 10, filter: str = None,
                     timeout: int = 10, iface: str = None) -> List[Any]:
        """
        Sniff network packets
        
        Args:
            count: Number of packets to capture
            filter: BPF filter string
            timeout: Capture timeout in seconds
            iface: Network interface
            
        Returns:
            List of captured packets
        """
        print(f"[*] Sniffing {count} packets...")
        
        try:
            # Default filter to capture TCP/IP packets
            if not filter:
                filter = "ip"
            
            # Sniff packets
            packets = sniff(
                count=count,
                filter=filter,
                timeout=timeout,
                iface=iface
            )
            
            self.packets_received += len(packets)
            
            print(f"[*] Captured {len(packets)} packets")
            
            return packets
            
        except Exception as e:
            print(f"[-] Error sniffing packets: {e}")
            return []
    
    def analyze_packet(self, packet: Any) -> Dict[str, Any]:
        """
        Analyze a packet and extract useful information
        
        Args:
            packet: Scapy packet
            
        Returns:
            Dictionary with packet information
        """
        info = {
            'src_ip': None,
            'dst_ip': None,
            'src_port': None,
            'dst_port': None,
            'protocol': None,
            'ttl': None,
            'length': len(packet)
        }
        
        try:
            # Extract IP information
            if IP in packet:
                ip = packet[IP]
                info['src_ip'] = ip.src
                info['dst_ip'] = ip.dst
                info['ttl'] = ip.ttl
                
                # Determine protocol
                if TCP in packet:
                    tcp = packet[TCP]
                    info['protocol'] = 'TCP'
                    info['src_port'] = tcp.sport
                    info['dst_port'] = tcp.dport
                    info['flags'] = tcp.flags
                elif UDP in packet:
                    udp = packet[UDP]
                    info['protocol'] = 'UDP'
                    info['src_port'] = udp.sport
                    info['dst_port'] = udp.dport
                elif ICMP in packet:
                    icmp = packet[ICMP]
                    info['protocol'] = 'ICMP'
                    info['type'] = icmp.type
                    info['code'] = icmp.code
                    
        except Exception as e:
            print(f"[-] Error analyzing packet: {e}")
        
        return info
    
    def save_packets(self, packets: List[Any], filename: str = 'capture.pcap'):
        """
        Save packets to a PCAP file
        
        Args:
            packets: List of packets
            filename: Output filename
        """
        try:
            wrpcap(filename, packets)
            print(f"[*] Saved {len(packets)} packets to {filename}")
        except Exception as e:
            print(f"[-] Error saving packets: {e}")
    
    def load_packets(self, filename: str) -> List[Any]:
        """
        Load packets from a PCAP file
        
        Args:
            filename: PCAP filename
            
        Returns:
            List of packets
        """
        try:
            packets = rdpcap(filename)
            print(f"[*] Loaded {len(packets)} packets from {filename}")
            return packets
        except Exception as e:
            print(f"[-] Error loading packets: {e}")
            return []
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Get packet statistics
        
        Returns:
            Dictionary with statistics
        """
        return {
            'packets_sent': self.packets_sent,
            'packets_received': self.packets_received,
            'total_packets': self.packets_sent + self.packets_received,
            'log_size': len(self.packet_log)
        }

class AdvancedPacketTools(PacketCrafter):
    """
    Advanced packet crafting tools for specific use cases
    """
    
    def arp_spoof(self, target_ip: str, spoof_ip: str, iface: str = None):
        """
        ARP spoofing attack (educational use only)
        
        Args:
            target_ip: Target IP address to spoof
            spoof_ip: IP address to impersonate
            iface: Network interface
        """
        # Create ARP packet
        arp = ARP()
        arp.psrc = spoof_ip  # IP we're impersonating
        arp.pdst = target_ip  # Target IP
        
        # Send ARP packet
        print(f"[*] Sending ARP spoof packet: {spoof_ip} is at {arp.hwsrc}")
        send(arp, iface=iface, verbose=self.verbose)
    
    def dns_spoof(self, target_ip: str, domain: str, spoof_ip: str,
                  iface: str = None):
        """
        DNS spoofing (educational use only)
        
        Args:
            target_ip: Target IP address
            domain: Domain to spoof
            spoof_ip: IP address to return for the domain
            iface: Network interface
        """
        # Craft DNS response packet
        dns_response = IP(dst=target_ip) / UDP(dport=53) / DNS(
            id=12345,
            qr=1,  # Response
            aa=1,  # Authoritative answer
            qd=DNSQR(qname=domain),
            an=DNSRR(rrname=domain, rdata=spoof_ip)
        )
        
        # Send DNS response
        print(f"[*] Sending DNS spoof response: {domain} -> {spoof_ip}")
        send(dns_response, iface=iface, verbose=self.verbose)
    
    def tcp_connect_scan(self, target: str, ports: List[int],
                         timeout: int = 2) -> List[int]:
        """
        TCP connect scan using Scapy
        
        Args:
            target: Target IP address
            ports: List of ports to scan
            timeout: Timeout in seconds
            
        Returns:
            List of open ports
        """
        open_ports = []
        total = len(ports)
        
        print(f"[*] Performing TCP connect scan on {target}")
        print(f"[*] Scanning {total} ports")
        
        for i, port in enumerate(ports, 1):
            # Create TCP SYN packet
            packet = self.create_ip_packet(dst_ip=target)
            tcp = self.create_tcp_packet(dst_port=port, flags='S')
            packet = packet / tcp
            
            # Send and receive
            response = self.send_and_receive(packet, timeout=timeout)
            
            if response:
                # Check if we got SYN-ACK
                if TCP in response and response[TCP].flags & 0x12:
                    # Port is open
                    open_ports.append(port)
                    print(f"[+] Port {port} is OPEN")
                    # Send RST to close connection
                    rst = IP(dst=target) / TCP(dport=port, sport=tcp.sport,
                                               flags='R', seq=tcp.seq+1)
                    self.send_packet(rst)
                else:
                    print(f"[-] Port {port} is closed")
            else:
                print(f"[-] Port {port} is filtered/timeout")
            
            # Progress indicator
            if i % 10 == 0:
                print(f"[*] Progress: {i}/{total} ports scanned")
        
        return open_ports
    
    def traceroute(self, target: str, max_hops: int = 30) -> List[str]:
        """
        Perform a traceroute using Scapy
        
        Args:
            target: Target IP address or hostname
            max_hops: Maximum number of hops
            
        Returns:
            List of hop IPs
        """
        print(f"[*] Performing traceroute to {target}")
        print(f"[*] Max hops: {max_hops}")
        
        try:
            # Resolve hostname if needed
            if not target.replace('.', '').isdigit():
                target = socket.gethostbyname(target)
            
            hops = []
            
            for ttl in range(1, max_hops + 1):
                # Create ICMP packet with TTL
                packet = IP(dst=target, ttl=ttl) / ICMP()
                
                # Send and wait for response
                response = self.send_and_receive(packet, timeout=2)
                
                if response:
                    src_ip = response.src
                    hops.append(src_ip)
                    print(f"[{ttl}] {src_ip}")
                    
                    if src_ip == target:
                        print("[*] Traceroute complete")
                        break
                else:
                    print(f"[{ttl}] * (timeout)")
                    hops.append('*')
            
            return hops
            
        except Exception as e:
            print(f"[-] Traceroute error: {e}")
            return []
    
    def port_knocking(self, target: str, ports: List[int], delay: float = 0.5):
        """
        Perform port knocking (sequential connection attempts)
        
        Args:
            target: Target IP address
            ports: List of ports to knock in sequence
            delay: Delay between knocks
        """
        print(f"[*] Performing port knocking on {target}")
        print(f"[*] Sequence: {ports}")
        
        for i, port in enumerate(ports, 1):
            # Create TCP SYN packet
            packet = self.create_ip_packet(dst_ip=target)
            tcp = self.create_tcp_packet(dst_port=port, flags='S')
            packet = packet / tcp
            
            # Send packet (no response needed)
            self.send_packet(packet)
            print(f"[*] Knock {i}/{len(ports)}: Port {port}")
            
            # Wait before next knock
            if i < len(ports):
                time.sleep(delay)
        
        print("[*] Port knocking completed")

def main():
    """Interactive packet crafting demonstration"""
    print("="*60)
    print("  PACKET CRAFTING FRAMEWORK")
    print("="*60)
    print("\nThis tool demonstrates various packet crafting techniques")
    print("Available functions:\n")
    print("1. Craft and send custom TCP packets")
    print("2. Craft and send custom UDP packets")
    print("3. Craft and send ICMP (ping) packets")
    print("4. Sniff network traffic")
    print("5. TCP connect scan with Scapy")
    print("6. Traceroute")
    print("7. Analyze packet captures")
    print("\nNote: Some functions require root privileges (sudo)")
    
    # Create packet crafter
    crafter = AdvancedPacketTools(verbose=True)
    
    # Demo 1: Craft and send a custom TCP packet
    print("\n" + "="*60)
    print("DEMO 1: Custom TCP Packet")
    print("="*60)
    
    # Create TCP SYN packet
    ip = crafter.create_ip_packet(dst_ip='8.8.8.8')
    tcp = crafter.create_tcp_packet(dst_port=80, flags='S')
    packet = ip / tcp
    
    print("Crafted packet:")
    packet.show()
    
    # Send packet
    # response = crafter.send_and_receive(packet, timeout=3)
    # if response:
    #     print("Response received!")
    #     response.show()
    
    # Demo 2: Create ICMP (ping) packet
    print("\n" + "="*60)
    print("DEMO 2: ICMP Ping Packet")
    print("="*60)
    
    ping = crafter.create_ip_packet(dst_ip='8.8.8.8') / crafter.create_icmp_packet()
    print("Ping packet:")
    ping.show()
    
    # Demo 3: Sniff packets
    print("\n" + "="*60)
    print("DEMO 3: Packet Sniffing")
    print("="*60)
    
    print("[*] Sniffing 5 ICMP packets...")
    print("[*] Generate ping traffic in another terminal")
    
    # Sniff ICMP packets
    packets = crafter.sniff_packets(count=5, filter="icmp", timeout=10)
    
    if packets:
        print(f"[*] Captured {len(packets)} ICMP packets")
        
        # Analyze first packet
        info = crafter.analyze_packet(packets[0])
        print("[*] Packet info:")
        for key, value in info.items():
            print(f"  {key}: {value}")
    
    # Demo 4: Traceroute
    print("\n" + "="*60)
    print("DEMO 4: Traceroute")
    print("="*60)
    
    hops = crafter.traceroute('google.com', max_hops=10)
    print(f"\n[*] Traceroute complete: {len(hops)} hops")
    
    print("\n[*] For more advanced usage, see the class documentation")
    print("[*] Example: crafter.tcp_connect_scan('192.168.1.1', [22,80,443])")
    print("[*] Example: crafter.port_knocking('192.168.1.1', [22,80,443])")

if __name__ == "__main__":
    main()
```

### The Implementation: Network Relay/Proxy

#### File: `~/hacking-toolkit/recon/network_relay.py`

```python
#!/usr/bin/env python3
"""
network_relay.py - TCP/UDP Network Relay/Proxy
This creates a relay that intercepts and forwards traffic, allowing for
traffic analysis and modification.
"""

import socket
import threading
import sys
import time
from typing import Optional, Callable

class NetworkRelay:
    """
    A network relay that forwards traffic between two endpoints
    Can be used as a proxy or man-in-the-middle for traffic analysis
    """
    
    def __init__(self, listen_host: str = '0.0.0.0', listen_port: int = 8080,
                 target_host: str = '127.0.0.1', target_port: int = 80,
                 buffer_size: int = 4096):
        """
        Initialize the network relay
        
        Args:
            listen_host: Host to listen on
            listen_port: Port to listen on
            target_host: Target host to forward to
            target_port: Target port to forward to
            buffer_size: Buffer size for data transfer
        """
        self.listen_host = listen_host
        self.listen_port = listen_port
        self.target_host = target_host
        self.target_port = target_port
        self.buffer_size = buffer_size
        self.running = False
        self.socket: Optional[socket.socket] = None
        self.modify_callback: Optional[Callable] = None
        self.log_callback: Optional[Callable] = None
        
    def set_modify_callback(self, callback: Callable):
        """
        Set a callback function to modify data before forwarding
        
        Args:
            callback: Function that takes bytes and returns modified bytes
        """
        self.modify_callback = callback
    
    def set_log_callback(self, callback: Callable):
        """
        Set a callback function to log data
        
        Args:
            callback: Function that takes data and direction
        """
        self.log_callback = callback
    
    def start(self):
        """
        Start the relay server
        """
        try:
            # Create listening socket
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.socket.bind((self.listen_host, self.listen_port))
            self.socket.listen(5)
            
            self.running = True
            print(f"[*] Relay listening on {self.listen_host}:{self.listen_port}")
            print(f"[*] Forwarding to {self.target_host}:{self.target_port}")
            
            while self.running:
                try:
                    # Accept client connection
                    client_sock, client_addr = self.socket.accept()
                    print(f"[+] Connection from {client_addr[0]}:{client_addr[1]}")
                    
                    # Create thread to handle this connection
                    thread = threading.Thread(
                        target=self._handle_connection,
                        args=(client_sock, client_addr)
                    )
                    thread.daemon = True
                    thread.start()
                    
                except socket.timeout:
                    continue
                except Exception as e:
                    if self.running:
                        print(f"[-] Error accepting connection: {e}")
                        
        except KeyboardInterrupt:
            print("\n[!] Relay stopped by user")
        except Exception as e:
            print(f"[-] Relay error: {e}")
        finally:
            self.stop()
    
    def _handle_connection(self, client_sock: socket.socket,
                           client_addr: tuple):
        """
        Handle a client connection and forward traffic
        
        Args:
            client_sock: Client socket
            client_addr: Client address
        """
        target_sock = None
        
        try:
            # Connect to target
            target_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            target_sock.connect((self.target_host, self.target_port))
            print(f"[*] Connected to target {self.target_host}:{self.target_port}")
            
            # Create bidirectional forwarding
            # Client -> Target
            client_thread = threading.Thread(
                target=self._forward_data,
                args=(client_sock, target_sock, 'client->target')
            )
            client_thread.daemon = True
            client_thread.start()
            
            # Target -> Client
            target_thread = threading.Thread(
                target=self._forward_data,
                args=(target_sock, client_sock, 'target->client')
            )
            target_thread.daemon = True
            target_thread.start()
            
            # Wait for either thread to finish
            client_thread.join()
            target_thread.join()
            
        except Exception as e:
            print(f"[-] Error in connection handler: {e}")
        finally:
            # Clean up
            if client_sock:
                client_sock.close()
            if target_sock:
                target_sock.close()
            print(f"[*] Connection to {client_addr[0]}:{client_addr[1]} closed")
    
    def _forward_data(self, src_sock: socket.socket, dst_sock: socket.socket,
                      direction: str):
        """
        Forward data from source to destination
        
        Args:
            src_sock: Source socket
            dst_sock: Destination socket
            direction: Direction string for logging
        """
        try:
            while self.running:
                # Read data from source
                data = src_sock.recv(self.buffer_size)
                
                if not data:
                    # End of stream
                    break
                
                # Log data
                if self.log_callback:
                    self.log_callback(data, direction)
                
                # Modify data if callback is set
                if self.modify_callback and direction == 'client->target':
                    data = self.modify_callback(data)
                
                # Send data to destination
                dst_sock.send(data)
                
        except socket.timeout:
            pass
        except Exception as e:
            if self.running:
                print(f"[-] Error forwarding data ({direction}): {e}")
    
    def stop(self):
        """
        Stop the relay server
        """
        self.running = False
        
        if self.socket:
            try:
                self.socket.close()
            except:
                pass
            self.socket = None
        
        print("[*] Relay stopped")

# Example modification callbacks
def http_modify(data: bytes) -> bytes:
    """
    Modify HTTP traffic (example: add X-Forwarded-For header)
    
    Args:
        data: HTTP request data
        
    Returns:
        Modified data
    """
    try:
        decoded = data.decode('utf-8', errors='ignore')
        
        # Check if it's an HTTP request
        if decoded.startswith(('GET', 'POST', 'PUT', 'DELETE')):
            # Add custom header
            lines = decoded.split('\r\n')
            
            # Insert header after request line
            if len(lines) > 1:
                lines.insert(1, 'X-Forwarded-For: 127.0.0.1')
                modified = '\r\n'.join(lines)
                return modified.encode('utf-8')
        
    except:
        pass
    
    return data

def http_log(data: bytes, direction: str):
    """
    Log HTTP traffic
    
    Args:
        data: HTTP data
        direction: Traffic direction
    """
    try:
        # Try to extract HTTP method or status line
        decoded = data.decode('utf-8', errors='ignore')
        lines = decoded.split('\r\n')
        
        if lines:
            first_line = lines[0]
            if first_line.startswith(('GET', 'POST', 'PUT', 'DELETE')):
                print(f"[HTTP {direction}] Request: {first_line}")
            elif first_line.startswith(('HTTP')):
                print(f"[HTTP {direction}] Response: {first_line}")
            
    except:
        pass

def main():
    """Main entry point for the relay"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="TCP Network Relay/Proxy",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic HTTP proxy
  python3 network_relay.py -l 8080 -t example.com -p 80
  
  # HTTP proxy with modification
  python3 network_relay.py -l 8080 -t example.com -p 80 --modify
  
  # Logging HTTP traffic
  python3 network_relay.py -l 8080 -t example.com -p 80 --log
        """
    )
    
    parser.add_argument('-l', '--listen-port', type=int, default=8080,
                       help='Port to listen on (default: 8080)')
    parser.add_argument('-t', '--target-host', default='127.0.0.1',
                       help='Target host to forward to (default: 127.0.0.1)')
    parser.add_argument('-p', '--target-port', type=int, default=80,
                       help='Target port to forward to (default: 80)')
    parser.add_argument('--modify', action='store_true',
                       help='Modify HTTP traffic (add X-Forwarded-For)')
    parser.add_argument('--log', action='store_true',
                       help='Log HTTP traffic')
    
    args = parser.parse_args()
    
    # Create relay
    relay = NetworkRelay(
        listen_port=args.listen_port,
        target_host=args.target_host,
        target_port=args.target_port
    )
    
    # Set callbacks
    if args.modify:
        relay.set_modify_callback(http_modify)
        print("[*] HTTP modification enabled")
    
    if args.log:
        relay.set_log_callback(http_log)
        print("[*] HTTP logging enabled")
    
    # Start relay
    try:
        relay.start()
    except KeyboardInterrupt:
        print("\n[!] Interrupt received, shutting down...")
        relay.stop()

if __name__ == "__main__":
    main()
```

### The Verification: Testing Packet Crafting

#### Test 1: Basic Packet Creation

```bash
cd ~/hacking-toolkit/recon
python3 packet_crafter.py
```

**Expected Output:**
```
============================================================
  PACKET CRAFTING FRAMEWORK
============================================================

This tool demonstrates various packet crafting techniques
Available functions:

1. Craft and send custom TCP packets
2. Craft and send custom UDP packets
3. Craft and send ICMP (ping) packets
4. Sniff network traffic
5. TCP connect scan with Scapy
6. Traceroute
7. Analyze packet captures

Note: Some functions require root privileges (sudo)

============================================================
DEMO 1: Custom TCP Packet
============================================================
Crafted packet:
###[ IP ]###
  version   = 4
  ihl       = None
  tos       = 0x0
  len       = None
  id        = 1
  flags     = 
  frag      = 0
  ttl       = 64
  proto     = tcp
  chksum    = None
  src       = 192.168.1.100
  dst       = 8.8.8.8
  \options   \
###[ TCP ]###
     sport     = 54321
     dport     = 80
     seq       = 12345
     ack       = 67890
     dataofs   = None
     reserved  = 0
     flags     = S
     window    = 8192
     chksum    = None
     urgptr    = 0
     options   = []

...
```

#### Test 2: TCP Connect Scan

```bash
# Perform a TCP connect scan on localhost
sudo python3 -c "
from packet_crafter import AdvancedPacketTools
crafter = AdvancedPacketTools(verbose=False)
open_ports = crafter.tcp_connect_scan('127.0.0.1', [22, 80, 443, 3306])
print(f'Open ports: {open_ports}')
"
```

#### Test 3: Sniffing Packets

```bash
# In Terminal 1: Start sniffer
sudo python3 packet_crafter.py
# Select option 4 when prompted

# In Terminal 2: Generate traffic
ping -c 3 8.8.8.8
curl http://google.com
```

#### Test 4: Network Relay

```bash
# Start relay (Terminal 1)
python3 network_relay.py -l 8080 -t google.com -p 80 --log

# Test relay (Terminal 2)
curl -x http://localhost:8080 http://google.com
```

**Expected Relay Output:**
```
[*] Relay listening on 0.0.0.0:8080
[*] Forwarding to google.com:80
[*] HTTP logging enabled
[+] Connection from 127.0.0.1:54321
[*] Connected to google.com:80
[HTTP client->target] Request: GET / HTTP/1.1
[HTTP target->client] Response: HTTP/1.1 200 OK
[*] Connection to 127.0.0.1:54321 closed
```

#### Test 5: Packet Analysis

```python
# Create a packet analysis script
cat > analyze_traffic.py << 'EOF'
#!/usr/bin/env python3
from packet_crafter import PacketCrafter
from scapy.all import IP, TCP, UDP, ICMP

crafter = PacketCrafter()

# Sniff some packets
print("[*] Sniffing 10 packets...")
packets = crafter.sniff_packets(count=10, filter="ip")

# Analyze each packet
print("\n[*] Analyzing packets:")
for i, packet in enumerate(packets, 1):
    info = crafter.analyze_packet(packet)
    print(f"\nPacket {i}:")
    for key, value in info.items():
        print(f"  {key}: {value}")

# Save to PCAP
crafter.save_packets(packets, 'captured_traffic.pcap')
print("\n[*] Traffic analysis complete")
EOF

python3 analyze_traffic.py
```

### Troubleshooting Common Issues

#### 1. Permission Denied

Many packet crafting operations require root privileges:

```bash
# Run with sudo
sudo python3 packet_crafter.py

# Or use capabilities
sudo setcap cap_net_raw=ep /usr/bin/python3
```

#### 2. Scapy Not Installed

```bash
# Install Scapy
pip install scapy

# Install additional dependencies
sudo apt install python3-scapy
```

#### 3. Network Interface Issues

```bash
# List available interfaces
ip link show

# Specify interface in sniffing
python3 -c "
from packet_crafter import PacketCrafter
crafter = PacketCrafter()
packets = crafter.sniff_packets(count=5, iface='eth0')
"
```

#### 4. Packet Capture Not Working

```bash
# Check if packet capture is enabled
sudo tcpdump -i eth0 -c 1

# If not, install necessary drivers
sudo apt install wireshark-common
sudo dpkg-reconfigure wireshark-common
```

### Reference: Scapy Packet Layers

Here's a quick reference for common Scapy layers:

| Layer | Class | Common Fields |
|-------|-------|---------------|
| Ethernet | Ether | src, dst, type |
| IP | IP | src, dst, ttl, flags |
| TCP | TCP | sport, dport, flags, seq, ack |
| UDP | UDP | sport, dport |
| ICMP | ICMP | type, code |
| ARP | ARP | psrc, pdst, hwsrc, hwdst |
| DNS | DNS | qr, opcode, qd, an |

**Common TCP Flags:**
- `S` = SYN (start connection)
- `A` = ACK (acknowledge)
- `F` = FIN (finish connection)
- `R` = RST (reset connection)
- `P` = PSH (push data)

