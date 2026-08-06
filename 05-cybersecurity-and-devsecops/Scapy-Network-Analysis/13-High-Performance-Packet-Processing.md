# Mastering Network Packet Crafting with Scapy
## Module 6: Automation, Performance & Custom Protocols
### Part 1: High-Performance Packet Processing

## The Target: Building Production-Ready Packet Processing Systems

In this part, we'll optimize our packet processing tools for production environments. By the end, you'll be able to:

1. Implement high-performance packet capture and processing
2. Build multi-threaded and asynchronous processing pipelines
3. Optimize memory usage for large-scale captures
4. Implement efficient data structures for packet analysis
5. Create producer-consumer patterns for throughput
6. Build a production-ready packet processing engine

---

## The Concept: Packet Processing Pipelines

Think of high-performance packet processing as a **factory assembly line**:

```
Raw Packets (High Volume)
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│              PRODUCER (Capture)                                 │
│         Sniffs packets and adds to queue                       │
└─────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│              QUEUE (Buffer)                                     │
│         Manages flow between producer and consumers            │
└─────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│              CONSUMERS (Process)                                │
│    Multiple threads process packets in parallel               │
└─────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│              OUTPUT (Storage/Display)                           │
│         Results aggregated and stored                          │
└─────────────────────────────────────────────────────────────────┘
```

**Key insight**: The key to high performance is separating capture from processing, using queues to buffer, and processing packets in parallel.

---

## The Implementation: Building High-Performance Tools

### Step 1: High-Performance Packet Capture Engine

Create `src/high_performance_capture.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 1: High-Performance Packet Capture Engine

This script implements a production-ready packet capture engine
with optimized performance and memory management.
"""

from scapy.all import sniff, PcapReader, conf, get_if_list
from scapy.all import IP, TCP, UDP, ICMP, Ether
import os
import sys
import time
import threading
import queue
import multiprocessing as mp
from datetime import datetime
from collections import deque
import argparse
import json
import psutil
import gc

class HighPerformanceCapture:
    """
    High-performance packet capture engine.
    
    Features:
    - Asynchronous packet capture
    - Configurable buffer sizes
    - Multi-threaded processing
    - Memory optimization
    - Performance monitoring
    - Flow control
    """
    
    def __init__(self, interface=None, buffer_size=10000, max_workers=4,
                 filter_str=None, promiscuous=True):
        """
        Initialize high-performance capture engine.
        
        Args:
            interface: Network interface
            buffer_size: Maximum packet buffer size
            max_workers: Number of processing threads
            filter_str: BPF filter
            promiscuous: Enable promiscuous mode
        """
        self.interface = interface or conf.iface
        self.buffer_size = buffer_size
        self.max_workers = max_workers
        self.filter_str = filter_str
        self.promiscuous = promiscuous
        
        # Queues for packet processing
        self.packet_queue = queue.Queue(maxsize=buffer_size)
        self.result_queue = queue.Queue()
        
        # Statistics
        self.stats = {
            'packets_captured': 0,
            'packets_processed': 0,
            'packets_dropped': 0,
            'processing_time': 0,
            'memory_usage': 0,
            'cpu_usage': 0,
            'start_time': None,
            'end_time': None
        }
        
        # Workers
        self.workers = []
        self.running = False
        
        # Performance monitoring
        self.monitor_thread = None
        self.monitor_interval = 5  # seconds
        
        # Processing functions
        self.processor = None
        
        print(f"\n[HighPerf] Initialized:")
        print(f"  Interface: {self.interface}")
        print(f"  Buffer size: {self.buffer_size} packets")
        print(f"  Workers: {self.max_workers}")
        print(f"  Filter: {self.filter_str or 'None'}")
        print(f"  Promiscuous: {self.promiscuous}")
    
    def packet_callback(self, packet):
        """
        Callback for captured packets.
        
        Args:
            packet: Captured packet
        """
        try:
            # Add to queue (non-blocking if full)
            if self.packet_queue.full():
                self.stats['packets_dropped'] += 1
                return
            
            self.packet_queue.put_nowait(packet)
            self.stats['packets_captured'] += 1
            
        except queue.Full:
            self.stats['packets_dropped'] += 1
        except Exception as e:
            print(f"Error in packet_callback: {e}")
    
    def worker_thread(self, worker_id):
        """
        Worker thread for processing packets.
        
        Args:
            worker_id: Worker identifier
        """
        print(f"[Worker {worker_id}] Started")
        
        while self.running:
            try:
                # Get packet from queue with timeout
                packet = self.packet_queue.get(timeout=0.5)
                
                # Process packet
                start_time = time.time()
                result = self.process_packet(packet)
                process_time = time.time() - start_time
                
                # Add result to result queue
                if result:
                    self.result_queue.put({
                        'worker_id': worker_id,
                        'packet': packet,
                        'result': result,
                        'process_time': process_time
                    })
                
                self.stats['packets_processed'] += 1
                self.packet_queue.task_done()
                
            except queue.Empty:
                # No packets available, continue
                continue
            except Exception as e:
                print(f"[Worker {worker_id}] Error: {e}")
                self.packet_queue.task_done()
        
        print(f"[Worker {worker_id}] Stopped")
    
    def process_packet(self, packet):
        """
        Process a single packet (override for custom processing).
        
        Args:
            packet: Packet to process
        
        Returns:
            dict: Processing result
        """
        # Basic processing - extract information
        result = {
            'timestamp': packet.time,
            'length': len(packet),
            'protocols': []
        }
        
        # Extract protocol information
        if packet.haslayer(IP):
            ip = packet[IP]
            result['src_ip'] = ip.src
            result['dst_ip'] = ip.dst
            result['protocols'].append('IP')
            
            if packet.haslayer(TCP):
                tcp = packet[TCP]
                result['protocol'] = 'TCP'
                result['sport'] = tcp.sport
                result['dport'] = tcp.dport
                result['flags'] = tcp.flags
                result['protocols'].append('TCP')
            elif packet.haslayer(UDP):
                udp = packet[UDP]
                result['protocol'] = 'UDP'
                result['sport'] = udp.sport
                result['dport'] = udp.dport
                result['protocols'].append('UDP')
            elif packet.haslayer(ICMP):
                result['protocol'] = 'ICMP'
                result['protocols'].append('ICMP')
        else:
            result['protocol'] = 'Other'
        
        return result
    
    def monitor_performance(self):
        """Monitor and log performance metrics."""
        
        while self.running:
            time.sleep(self.monitor_interval)
            
            # Update statistics
            memory_info = psutil.virtual_memory()
            cpu_percent = psutil.cpu_percent(interval=1)
            
            self.stats['memory_usage'] = memory_info.used / (1024 * 1024)  # MB
            self.stats['cpu_usage'] = cpu_percent
            
            # Log performance
            if self.stats['start_time']:
                elapsed = time.time() - self.stats['start_time']
                
                print(f"\n[Performance]")
                print(f"  Packets captured: {self.stats['packets_captured']}")
                print(f"  Packets processed: {self.stats['packets_processed']}")
                print(f"  Queue size: {self.packet_queue.qsize()}")
                print(f"  Memory usage: {self.stats['memory_usage']:.1f} MB")
                print(f"  CPU usage: {self.stats['cpu_usage']:.1f}%")
                print(f"  Processing rate: {self.stats['packets_processed'] / max(1, elapsed):.1f} pkts/s")
    
    def start_capture(self, count=None, timeout=None, processor=None):
        """
        Start the capture engine.
        
        Args:
            count: Number of packets to capture (None for unlimited)
            timeout: Timeout in seconds
            processor: Custom processing function
        """
        if processor:
            self.processor = processor
        
        print("\n" + "=" * 60)
        print("HIGH-PERFORMANCE CAPTURE ENGINE")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print(f"Workers: {self.max_workers}")
        print(f"Buffer: {self.buffer_size} packets")
        print(f"Count: {count if count else 'Unlimited'}")
        print(f"Timeout: {timeout if timeout else 'None'}")
        print("-" * 60)
        
        self.running = True
        self.stats['start_time'] = time.time()
        
        # Start worker threads
        for i in range(self.max_workers):
            worker = threading.Thread(target=self.worker_thread, args=(i,))
            worker.daemon = True
            worker.start()
            self.workers.append(worker)
        
        # Start performance monitor
        self.monitor_thread = threading.Thread(target=self.monitor_performance)
        self.monitor_thread.daemon = True
        self.monitor_thread.start()
        
        try:
            # Start sniffing
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self.packet_callback,
                count=count,
                timeout=timeout,
                store=False,
                promisc=self.promiscuous
            )
            
        except KeyboardInterrupt:
            print("\nCapture interrupted by user")
        except Exception as e:
            print(f"Error during capture: {e}")
        finally:
            self.stop_capture()
    
    def stop_capture(self):
        """Stop the capture engine."""
        
        self.running = False
        self.stats['end_time'] = time.time()
        
        # Wait for workers to finish
        for worker in self.workers:
            worker.join(timeout=2)
        
        # Display final statistics
        self.display_stats()
    
    def display_stats(self):
        """Display capture statistics."""
        
        elapsed = self.stats['end_time'] - self.stats['start_time'] if self.stats['start_time'] else 0
        
        print("\n" + "=" * 60)
        print("CAPTURE STATISTICS")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f} seconds")
        print(f"Packets captured: {self.stats['packets_captured']}")
        print(f"Packets processed: {self.stats['packets_processed']}")
        print(f"Packets dropped: {self.stats['packets_dropped']}")
        print(f"Queue size: {self.packet_queue.qsize()}")
        
        if elapsed > 0:
            print(f"Capture rate: {self.stats['packets_captured'] / elapsed:.1f} pkts/s")
            print(f"Processing rate: {self.stats['packets_processed'] / elapsed:.1f} pkts/s")
        
        if self.stats['memory_usage']:
            print(f"Memory usage: {self.stats['memory_usage']:.1f} MB")
        if self.stats['cpu_usage']:
            print(f"CPU usage: {self.stats['cpu_usage']:.1f}%")
        
        # Queue statistics
        print(f"\nQueue Statistics:")
        print(f"  Queue size: {self.packet_queue.qsize()}")
        print(f"  Queue capacity: {self.buffer_size}")
        print(f"  Queue utilization: {self.packet_queue.qsize() / self.buffer_size * 100:.1f}%")
        
        print("\n" + "=" * 60)
    
    def export_results(self, filename=None):
        """Export results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/capture_stats_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'interface': self.interface,
            'stats': self.stats,
            'config': {
                'buffer_size': self.buffer_size,
                'max_workers': self.max_workers,
                'filter': self.filter_str
            }
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2)
        
        print(f"\nStatistics exported to: {filename}")

def main():
    """Main function for high-performance capture."""
    
    parser = argparse.ArgumentParser(description='High-Performance Capture Engine')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-f', '--filter', help='BPF filter')
    parser.add_argument('-c', '--count', type=int, help='Number of packets to capture')
    parser.add_argument('-t', '--timeout', type=int, help='Capture timeout in seconds')
    parser.add_argument('-w', '--workers', type=int, default=4,
                        help='Number of processing threads')
    parser.add_argument('-b', '--buffer', type=int, default=10000,
                        help='Buffer size in packets')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export statistics')
    
    args = parser.parse_args()
    
    # Create capture engine
    engine = HighPerformanceCapture(
        interface=args.interface or conf.iface,
        buffer_size=args.buffer,
        max_workers=args.workers,
        filter_str=args.filter
    )
    
    # Start capture
    try:
        engine.start_capture(count=args.count, timeout=args.timeout)
        
        if args.export:
            engine.export_results()
    
    except KeyboardInterrupt:
        print("\nCapture stopped")
    
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("HIGH-PERFORMANCE CAPTURE ENGINE")
        print("=" * 60)
        
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        workers = input("Number of workers (default: 4): ").strip()
        workers = int(workers) if workers else 4
        
        engine = HighPerformanceCapture(
            interface=interface,
            max_workers=workers
        )
        
        engine.start_capture()
    else:
        main()
```

### Step 2: Asynchronous Packet Processing with asyncio

Create `src/async_packet_processor.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 1: Asynchronous Packet Processing

This script implements asynchronous packet processing
using asyncio for high-performance network analysis.
"""

import asyncio
import sys
import time
import json
from datetime import datetime
from collections import defaultdict
import argparse
import os

# Scapy is synchronous, but we can use it in async contexts
from scapy.all import rdpcap, IP, TCP, UDP, ICMP, Ether
from scapy.all import PcapReader, conf, get_if_list

class AsyncPacketProcessor:
    """
    Asynchronous packet processing engine.
    
    Features:
    - Asynchronous I/O
    - Parallel processing
    - Configurable concurrency
    - Non-blocking operations
    - Pipeline processing
    """
    
    def __init__(self, max_concurrent=10, batch_size=100):
        """
        Initialize async packet processor.
        
        Args:
            max_concurrent: Maximum concurrent tasks
            batch_size: Batch size for processing
        """
        self.max_concurrent = max_concurrent
        self.batch_size = batch_size
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.stats = defaultdict(int)
        self.results = []
        self.packet_count = 0
        
        print(f"\n[Async Processor] Initialized:")
        print(f"  Max concurrent: {max_concurrent}")
        print(f"  Batch size: {batch_size}")
    
    async def process_packet(self, packet):
        """
        Asynchronously process a single packet.
        
        Args:
            packet: Scapy packet
        """
        async with self.semaphore:
            # Simulate processing (in real use, this would be actual analysis)
            await asyncio.sleep(0.001)  # Simulate work
            
            # Extract information
            info = {
                'length': len(packet),
                'timestamp': packet.time
            }
            
            if packet.haslayer(IP):
                ip = packet[IP]
                info['src_ip'] = ip.src
                info['dst_ip'] = ip.dst
                
                if packet.haslayer(TCP):
                    info['protocol'] = 'TCP'
                    info['sport'] = packet[TCP].sport
                    info['dport'] = packet[TCP].dport
                    self.stats['TCP'] += 1
                elif packet.haslayer(UDP):
                    info['protocol'] = 'UDP'
                    info['sport'] = packet[UDP].sport
                    info['dport'] = packet[UDP].dport
                    self.stats['UDP'] += 1
                elif packet.haslayer(ICMP):
                    info['protocol'] = 'ICMP'
                    self.stats['ICMP'] += 1
                else:
                    info['protocol'] = 'Other_IP'
                    self.stats['Other_IP'] += 1
            else:
                info['protocol'] = 'Other'
                self.stats['Other'] += 1
            
            self.packet_count += 1
            self.results.append(info)
    
    async def process_batch(self, packets):
        """
        Process a batch of packets asynchronously.
        
        Args:
            packets: List of packets to process
        """
        tasks = []
        for packet in packets:
            task = asyncio.create_task(self.process_packet(packet))
            tasks.append(task)
        
        # Wait for all tasks to complete
        await asyncio.gather(*tasks)
        
        # Update statistics
        self.stats['packets_processed'] += len(packets)
    
    async def process_pcap(self, pcap_file):
        """
        Process a PCAP file asynchronously.
        
        Args:
            pcap_file: Path to PCAP file
        """
        print(f"\n[Async] Processing PCAP: {pcap_file}")
        
        # Read packets using PcapReader for memory efficiency
        start_time = time.time()
        packet_batch = []
        
        try:
            with PcapReader(pcap_file) as reader:
                for packet in reader:
                    packet_batch.append(packet)
                    
                    if len(packet_batch) >= self.batch_size:
                        await self.process_batch(packet_batch)
                        packet_batch = []
                
                # Process remaining packets
                if packet_batch:
                    await self.process_batch(packet_batch)
        
        except Exception as e:
            print(f"Error processing PCAP: {e}")
        
        elapsed = time.time() - start_time
        
        print(f"\n[Async] Processing complete:")
        print(f"  Packets processed: {self.packet_count}")
        print(f"  Time: {elapsed:.2f}s")
        print(f"  Rate: {self.packet_count / elapsed:.1f} pkts/s")
        
        return self.results
    
    async def process_pcap_with_workers(self, pcap_file, num_workers=4):
        """
        Process PCAP with multiple workers.
        
        Args:
            pcap_file: PCAP file path
            num_workers: Number of parallel workers
        """
        print(f"\n[Async] Processing with {num_workers} workers")
        
        # Read all packets
        packets = list(rdpcap(pcap_file))
        total_packets = len(packets)
        
        # Split into chunks
        chunk_size = total_packets // num_workers
        chunks = []
        
        for i in range(0, total_packets, chunk_size):
            if i + chunk_size < total_packets:
                chunks.append(packets[i:i+chunk_size])
            else:
                chunks.append(packets[i:])
        
        # Process chunks in parallel
        start_time = time.time()
        
        tasks = []
        for chunk in chunks:
            task = asyncio.create_task(self.process_batch(chunk))
            tasks.append(task)
        
        await asyncio.gather(*tasks)
        
        elapsed = time.time() - start_time
        
        print(f"\n[Async] Parallel processing complete:")
        print(f"  Packets processed: {self.packet_count}")
        print(f"  Time: {elapsed:.2f}s")
        print(f"  Rate: {self.packet_count / elapsed:.1f} pkts/s")
        
        return self.results
    
    def display_stats(self):
        """Display processing statistics."""
        
        print("\n" + "=" * 60)
        print("ASYNC PROCESSING STATISTICS")
        print("=" * 60)
        
        total = sum(self.stats.values())
        print(f"Total packets: {total}")
        
        print("\nProtocol Distribution:")
        print("-" * 40)
        for protocol, count in sorted(self.stats.items(), 
                                     key=lambda x: x[1], reverse=True):
            if protocol != 'packets_processed':
                percentage = (count / total) * 100 if total > 0 else 0
                print(f"  {protocol:<10}: {count:>6} ({percentage:>5.1f}%)")
    
    def export_results(self, filename=None):
        """Export results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/async_results_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'stats': dict(self.stats),
            'sample_results': self.results[:100]  # Only first 100
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"\nResults exported to: {filename}")

async def main_async(pcap_file, workers=1, batch_size=100):
    """Async main function."""
    
    processor = AsyncPacketProcessor(
        max_concurrent=10,
        batch_size=batch_size
    )
    
    if workers > 1:
        await processor.process_pcap_with_workers(pcap_file, workers)
    else:
        await processor.process_pcap(pcap_file)
    
    processor.display_stats()
    
    export = input("\nExport results? (y/n): ").strip().lower()
    if export == 'y':
        processor.export_results()

def main():
    """Main function for async processor."""
    
    parser = argparse.ArgumentParser(description='Async Packet Processor')
    parser.add_argument('pcap_file', help='PCAP file to process')
    parser.add_argument('-w', '--workers', type=int, default=1,
                        help='Number of parallel workers')
    parser.add_argument('-b', '--batch', type=int, default=100,
                        help='Batch size for processing')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export results to JSON')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.pcap_file):
        print(f"PCAP file not found: {args.pcap_file}")
        sys.exit(1)
    
    # Run async main
    asyncio.run(main_async(args.pcap_file, args.workers, args.batch))

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("ASYNC PACKET PROCESSOR")
        print("=" * 60)
        
        pcap_file = input("Enter PCAP file path: ").strip()
        if not pcap_file:
            print("No PCAP file specified")
            sys.exit(1)
        
        workers = input("Number of workers (default: 1): ").strip()
        workers = int(workers) if workers else 1
        
        asyncio.run(main_async(pcap_file, workers))
    else:
        main()
```

### Step 3: Efficient Data Structures for Packet Analysis

Create `src/efficient_data_structures.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 1: Efficient Data Structures for Packet Analysis

This script demonstrates efficient data structures
for high-performance packet analysis.
"""

import sys
import time
from collections import defaultdict, Counter, deque
import array
import struct
from datetime import datetime
import argparse
import os
import pickle

class EfficientPacketStorage:
    """
    Memory-efficient packet storage and analysis.
    
    Features:
    - Fixed-size arrays for performance
    - Packet summarization for memory efficiency
    - Bloom filters for fast lookups
    - Time-series data structures
    - Aggregation and rollups
    """
    
    def __init__(self, max_packets=1000000):
        """
        Initialize efficient storage.
        
        Args:
            max_packets: Maximum packets to store
        """
        self.max_packets = max_packets
        self.packet_buffer = deque(maxlen=max_packets)
        
        # Time-series data
        self.timestamps = deque(maxlen=max_packets)
        self.packet_lengths = deque(maxlen=max_packets)
        self.protocols = deque(maxlen=max_packets)
        
        # Aggregations
        self.ip_pairs = defaultdict(int)
        self.port_pairs = defaultdict(int)
        self.protocol_counts = defaultdict(int)
        
        # Time buckets (aggregated)
        self.time_buckets = defaultdict(int)
        self.bucket_size = 60  # seconds
        
        # Bloom filter for IP addresses (simple version)
        self.ip_bloom = bytearray(1024)  # 8KB bloom filter
        
        print(f"\n[Efficient] Initialized:")
        print(f"  Max packets: {self.max_packets}")
        print(f"  Bucket size: {self.bucket_size}s")
    
    def add_packet(self, packet):
        """Add a packet to storage efficiently."""
        
        # Extract basic info
        timestamp = int(packet.time)
        length = len(packet)
        protocol = self.get_protocol(packet)
        
        # Store in buffers
        self.packet_buffer.append(packet)
        self.timestamps.append(timestamp)
        self.packet_lengths.append(length)
        self.protocols.append(protocol)
        
        # Update aggregations
        self.protocol_counts[protocol] += 1
        
        # Update IP pairs
        if packet.haslayer(IP):
            ip = packet[IP]
            ip_pair = f"{ip.src}:{ip.dst}"
            self.ip_pairs[ip_pair] += 1
            
            # Add to bloom filter
            self.add_to_bloom(ip.src)
            self.add_to_bloom(ip.dst)
            
            # Update port pairs
            if packet.haslayer(TCP):
                tcp = packet[TCP]
                port_pair = f"{tcp.sport}:{tcp.dport}"
                self.port_pairs[port_pair] += 1
            elif packet.haslayer(UDP):
                udp = packet[UDP]
                port_pair = f"{udp.sport}:{udp.dport}"
                self.port_pairs[port_pair] += 1
        
        # Time bucket
        bucket = timestamp - (timestamp % self.bucket_size)
        self.time_buckets[bucket] += 1
    
    def get_protocol(self, packet):
        """Extract protocol from packet."""
        if packet.haslayer(TCP):
            return 'TCP'
        elif packet.haslayer(UDP):
            return 'UDP'
        elif packet.haslayer(ICMP):
            return 'ICMP'
        elif packet.haslayer(IP):
            return 'Other_IP'
        else:
            return 'Other'
    
    def add_to_bloom(self, ip):
        """Add IP to bloom filter."""
        # Simple hash functions
        h1 = hash(ip) % len(self.ip_bloom)
        h2 = (hash(ip) * 3 + 1) % len(self.ip_bloom)
        h3 = (hash(ip) * 5 + 2) % len(self.ip_bloom)
        
        self.ip_bloom[h1] = 1
        self.ip_bloom[h2] = 1
        self.ip_bloom[h3] = 1
    
    def ip_in_bloom(self, ip):
        """Check if IP is in bloom filter (may have false positives)."""
        h1 = hash(ip) % len(self.ip_bloom)
        h2 = (hash(ip) * 3 + 1) % len(self.ip_bloom)
        h3 = (hash(ip) * 5 + 2) % len(self.ip_bloom)
        
        return (self.ip_bloom[h1] == 1 and 
                self.ip_bloom[h2] == 1 and 
                self.ip_bloom[h3] == 1)
    
    def get_stats(self):
        """Get aggregated statistics."""
        total = len(self.packet_buffer)
        
        if total == 0:
            return {}
        
        # Calculate average packet size
        avg_size = sum(self.packet_lengths) / total
        
        # Get top talkers
        top_ip_pairs = sorted(self.ip_pairs.items(), 
                             key=lambda x: x[1], reverse=True)[:10]
        top_port_pairs = sorted(self.port_pairs.items(), 
                               key=lambda x: x[1], reverse=True)[:10]
        
        # Time distribution
        time_dist = sorted(self.time_buckets.items())
        
        return {
            'total_packets': total,
            'avg_packet_size': avg_size,
            'protocol_distribution': dict(self.protocol_counts),
            'top_ip_pairs': top_ip_pairs,
            'top_port_pairs': top_port_pairs,
            'time_distribution': time_dist[:20],  # First 20 buckets
            'bloom_fill_rate': sum(self.ip_bloom) / len(self.ip_bloom) * 100
        }
    
    def save_to_file(self, filename):
        """Save efficient storage to file."""
        with open(filename, 'wb') as f:
            pickle.dump({
                'packets': list(self.packet_buffer),
                'timestamps': list(self.timestamps),
                'packet_lengths': list(self.packet_lengths),
                'protocols': list(self.protocols),
                'ip_pairs': dict(self.ip_pairs),
                'port_pairs': dict(self.port_pairs),
                'protocol_counts': dict(self.protocol_counts),
                'time_buckets': dict(self.time_buckets),
                'ip_bloom': self.ip_bloom
            }, f)
        
        print(f"\nStorage saved to: {filename}")
    
    def load_from_file(self, filename):
        """Load efficient storage from file."""
        with open(filename, 'rb') as f:
            data = pickle.load(f)
            
            self.packet_buffer = deque(data['packets'], maxlen=self.max_packets)
            self.timestamps = deque(data['timestamps'], maxlen=self.max_packets)
            self.packet_lengths = deque(data['packet_lengths'], maxlen=self.max_packets)
            self.protocols = deque(data['protocols'], maxlen=self.max_packets)
            self.ip_pairs = defaultdict(int, data['ip_pairs'])
            self.port_pairs = defaultdict(int, data['port_pairs'])
            self.protocol_counts = defaultdict(int, data['protocol_counts'])
            self.time_buckets = defaultdict(int, data['time_buckets'])
            self.ip_bloom = data['ip_bloom']
        
        print(f"\nStorage loaded from: {filename}")

def main():
    """Main function for efficient data structures demo."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Efficient Data Structures')
    parser.add_argument('pcap_file', help='PCAP file to process')
    parser.add_argument('-m', '--max-packets', type=int, default=10000,
                        help='Maximum packets to process')
    parser.add_argument('-s', '--save', help='Save storage to file')
    parser.add_argument('-l', '--load', help='Load storage from file')
    
    args = parser.parse_args()
    
    # Create storage
    storage = EfficientPacketStorage(max_packets=args.max_packets)
    
    if args.load:
        storage.load_from_file(args.load)
        stats = storage.get_stats()
        print("\nLoaded Statistics:")
        print("-" * 40)
        for key, value in stats.items():
            if key != 'time_distribution':
                print(f"  {key}: {value}")
        return
    
    # Process PCAP
    from scapy.all import rdpcap
    print(f"\nProcessing PCAP: {args.pcap_file}")
    
    packets = rdpcap(args.pcap_file)
    total = min(len(packets), args.max_packets)
    
    print(f"Adding {total} packets to storage...")
    start_time = time.time()
    
    for packet in packets[:total]:
        storage.add_packet(packet)
    
    elapsed = time.time() - start_time
    
    # Get statistics
    stats = storage.get_stats()
    
    print(f"\nProcessed {total} packets in {elapsed:.2f}s")
    print(f"Rate: {total / elapsed:.1f} pkts/s")
    
    print("\nStatistics:")
    print("-" * 40)
    for key, value in stats.items():
        if key != 'time_distribution':
            if isinstance(value, dict):
                print(f"\n  {key}:")
                for k, v in sorted(value.items(), key=lambda x: x[1], reverse=True)[:5]:
                    print(f"    {k}: {v}")
            else:
                print(f"  {key}: {value}")
    
    # Show bloom filter performance
    print(f"\nBloom Filter Fill Rate: {stats['bloom_fill_rate']:.1f}%")
    print(f"Bloom Filter Size: {len(storage.ip_bloom)} bytes")
    
    # Save if requested
    if args.save:
        storage.save_to_file(args.save)

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("EFFICIENT DATA STRUCTURES DEMO")
        print("=" * 60)
        
        pcap_file = input("Enter PCAP file path: ").strip()
        if not pcap_file:
            print("No PCAP file specified")
            sys.exit(1)
        
        max_packets = input("Max packets to process (default: 10000): ").strip()
        max_packets = int(max_packets) if max_packets else 10000
        
        storage = EfficientPacketStorage(max_packets=max_packets)
        
        from scapy.all import rdpcap
        packets = rdpcap(pcap_file)
        total = min(len(packets), max_packets)
        
        print(f"Processing {total} packets...")
        for packet in packets[:total]:
            storage.add_packet(packet)
        
        stats = storage.get_stats()
        print("\nStatistics:")
        for key, value in stats.items():
            print(f"  {key}: {value}")
        
        save = input("\nSave storage to file? (y/n): ").strip().lower()
        if save == 'y':
            filename = input("Filename: ").strip()
            storage.save_to_file(filename)
    else:
        main()
```

### Step 4: Producer-Consumer Pattern for High Throughput

Create `src/producer_consumer_engine.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 1: Producer-Consumer Pattern Engine

This script implements a high-throughput producer-consumer
engine for packet processing with configurable pipelines.
"""

from scapy.all import sniff, rdpcap, conf, get_if_list
from scapy.all import IP, TCP, UDP, ICMP
import sys
import time
import threading
import queue
import multiprocessing as mp
from datetime import datetime
import argparse
import os
import signal

class ProducerConsumerEngine:
    """
    High-throughput producer-consumer engine.
    
    Features:
    - Producer-Consumer pattern
    - Configurable pipeline stages
    - Backpressure handling
    - Performance metrics
    - Graceful shutdown
    """
    
    def __init__(self, num_producers=1, num_consumers=4, queue_size=10000,
                 stage_count=1, interface=None, filter_str=None):
        """
        Initialize producer-consumer engine.
        
        Args:
            num_producers: Number of producer threads
            num_consumers: Number of consumer threads
            queue_size: Size of the queue
            stage_count: Number of processing stages
            interface: Network interface
            filter_str: BPF filter
        """
        self.num_producers = num_producers
        self.num_consumers = num_consumers
        self.queue_size = queue_size
        self.stage_count = stage_count
        self.interface = interface or conf.iface
        self.filter_str = filter_str
        
        # Create queues for each stage
        self.queues = []
        for i in range(stage_count + 1):
            self.queues.append(queue.Queue(maxsize=queue_size))
        
        # Producers and consumers
        self.producers = []
        self.consumers = []
        self.stage_processors = []
        
        # Statistics
        self.stats = {
            'produced': 0,
            'consumed': 0,
            'stage_1': 0,
            'stage_2': 0,
            'stage_3': 0,
            'dropped': 0,
            'start_time': None,
            'end_time': None
        }
        
        # Running state
        self.running = False
        self.stats_lock = threading.Lock()
        
        print(f"\n[ProducerConsumer] Initialized:")
        print(f"  Producers: {self.num_producers}")
        print(f"  Consumers: {self.num_consumers}")
        print(f"  Stages: {self.stage_count}")
        print(f"  Queue size: {self.queue_size}")
        print(f"  Interface: {self.interface}")
    
    def producer_thread(self, producer_id):
        """
        Producer thread - captures packets and adds to queue.
        
        Args:
            producer_id: Producer identifier
        """
        print(f"[Producer {producer_id}] Started")
        
        def packet_callback(packet):
            if not self.running:
                return
            
            try:
                # Add to first queue (non-blocking)
                self.queues[0].put_nowait(packet)
                
                with self.stats_lock:
                    self.stats['produced'] += 1
                    
            except queue.Full:
                with self.stats_lock:
                    self.stats['dropped'] += 1
        
        try:
            # Start sniffing
            sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=packet_callback,
                store=False
            )
        except Exception as e:
            print(f"[Producer {producer_id}] Error: {e}")
        finally:
            print(f"[Producer {producer_id}] Stopped")
    
    def stage_processor(self, stage_id, input_queue, output_queue, stage_func=None):
        """
        Stage processor - processes packets through a pipeline stage.
        
        Args:
            stage_id: Stage identifier
            input_queue: Input queue
            output_queue: Output queue
            stage_func: Processing function
        """
        print(f"[Stage {stage_id}] Started")
        
        while self.running:
            try:
                # Get packet from input queue
                packet = input_queue.get(timeout=0.5)
                
                # Process packet
                if stage_func:
                    result = stage_func(packet)
                else:
                    result = packet  # Passthrough
                
                # Send to next stage
                if output_queue:
                    try:
                        output_queue.put_nowait(result)
                    except queue.Full:
                        # Drop if output queue is full
                        pass
                
                with self.stats_lock:
                    self.stats[f'stage_{stage_id}'] += 1
                
                input_queue.task_done()
                
            except queue.Empty:
                continue
            except Exception as e:
                print(f"[Stage {stage_id}] Error: {e}")
                input_queue.task_done()
        
        print(f"[Stage {stage_id}] Stopped")
    
    def consumer_thread(self, consumer_id):
        """
        Consumer thread - final processing of packets.
        
        Args:
            consumer_id: Consumer identifier
        """
        print(f"[Consumer {consumer_id}] Started")
        
        while self.running:
            try:
                # Get packet from last queue
                packet = self.queues[-1].get(timeout=0.5)
                
                # Final processing
                self.process_final(packet)
                
                with self.stats_lock:
                    self.stats['consumed'] += 1
                
                self.queues[-1].task_done()
                
            except queue.Empty:
                continue
            except Exception as e:
                print(f"[Consumer {consumer_id}] Error: {e}")
                self.queues[-1].task_done()
        
        print(f"[Consumer {consumer_id}] Stopped")
    
    def process_final(self, packet):
        """
        Final processing for consumed packets.
        
        Args:
            packet: Packet to process
        """
        # This can be customized
        # For demonstration, just count
        pass
    
    def start_engine(self):
        """Start the producer-consumer engine."""
        
        print("\n" + "=" * 60)
        print("PRODUCER-CONSUMER ENGINE")
        print("=" * 60)
        print(f"Interface: {self.interface}")
        print(f"Stages: {self.stage_count}")
        print(f"Producers: {self.num_producers}")
        print(f"Consumers: {self.num_consumers}")
        print("Press Ctrl+C to stop")
        print("-" * 60)
        
        self.running = True
        self.stats['start_time'] = time.time()
        
        # Start producers
        for i in range(self.num_producers):
            producer = threading.Thread(target=self.producer_thread, args=(i,))
            producer.daemon = True
            producer.start()
            self.producers.append(producer)
        
        # Start stage processors
        for i in range(self.stage_count):
            processor = threading.Thread(
                target=self.stage_processor,
                args=(i+1, self.queues[i], self.queues[i+1], None)
            )
            processor.daemon = True
            processor.start()
            self.stage_processors.append(processor)
        
        # Start consumers
        for i in range(self.num_consumers):
            consumer = threading.Thread(target=self.consumer_thread, args=(i,))
            consumer.daemon = True
            consumer.start()
            self.consumers.append(consumer)
        
        # Wait for interruption
        try:
            while self.running:
                time.sleep(1)
                
                # Display status every 5 seconds
                if int(time.time()) % 5 == 0:
                    self.display_status()
                
        except KeyboardInterrupt:
            print("\nShutting down engine...")
        finally:
            self.stop_engine()
    
    def stop_engine(self):
        """Stop the producer-consumer engine."""
        
        self.running = False
        self.stats['end_time'] = time.time()
        
        # Wait for producers
        for producer in self.producers:
            producer.join(timeout=2)
        
        # Wait for stage processors
        for processor in self.stage_processors:
            processor.join(timeout=2)
        
        # Wait for consumers
        for consumer in self.consumers:
            consumer.join(timeout=2)
        
        # Display final statistics
        self.display_stats()
    
    def display_status(self):
        """Display current status."""
        
        elapsed = time.time() - self.stats['start_time']
        
        print(f"\n[Status]")
        print(f"  Produced: {self.stats['produced']}")
        print(f"  Consumed: {self.stats['consumed']}")
        print(f"  Dropped: {self.stats['dropped']}")
        print(f"  Queue sizes:", end="")
        for i, q in enumerate(self.queues):
            print(f" Q{i}:{q.qsize()}", end="")
        print()
        print(f"  Rate: {self.stats['consumed'] / max(1, elapsed):.1f} pkts/s")
    
    def display_stats(self):
        """Display final statistics."""
        
        elapsed = self.stats['end_time'] - self.stats['start_time'] if self.stats['start_time'] else 0
        
        print("\n" + "=" * 60)
        print("ENGINE STATISTICS")
        print("=" * 60)
        print(f"Duration: {elapsed:.2f}s")
        print(f"Packets produced: {self.stats['produced']}")
        print(f"Packets consumed: {self.stats['consumed']}")
        print(f"Packets dropped: {self.stats['dropped']}")
        
        if elapsed > 0:
            print(f"Production rate: {self.stats['produced'] / elapsed:.1f} pkts/s")
            print(f"Consumption rate: {self.stats['consumed'] / elapsed:.1f} pkts/s")
        
        print(f"\nStage Processing:")
        for i in range(self.stage_count):
            key = f'stage_{i+1}'
            count = self.stats.get(key, 0)
            print(f"  Stage {i+1}: {count} packets")
        
        print("\n" + "=" * 60)

def main():
    """Main function for producer-consumer engine."""
    
    parser = argparse.ArgumentParser(description='Producer-Consumer Engine')
    parser.add_argument('-i', '--interface', help='Network interface')
    parser.add_argument('-f', '--filter', help='BPF filter')
    parser.add_argument('-p', '--producers', type=int, default=1,
                        help='Number of producers')
    parser.add_argument('-c', '--consumers', type=int, default=4,
                        help='Number of consumers')
    parser.add_argument('-s', '--stages', type=int, default=1,
                        help='Number of processing stages')
    parser.add_argument('-q', '--queue-size', type=int, default=10000,
                        help='Queue size')
    
    args = parser.parse_args()
    
    # Create engine
    engine = ProducerConsumerEngine(
        num_producers=args.producers,
        num_consumers=args.consumers,
        queue_size=args.queue_size,
        stage_count=args.stages,
        interface=args.interface or conf.iface,
        filter_str=args.filter
    )
    
    # Start engine
    try:
        engine.start_engine()
    except KeyboardInterrupt:
        print("\nEngine stopped by user")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("PRODUCER-CONSUMER ENGINE")
        print("=" * 60)
        
        interfaces = get_if_list()
        print("\nAvailable interfaces:")
        for i, iface in enumerate(interfaces):
            print(f"  {i+1}. {iface}")
        
        choice = input("\nSelect interface number: ").strip()
        if choice:
            try:
                idx = int(choice) - 1
                interface = interfaces[idx]
            except:
                interface = conf.iface
        else:
            interface = conf.iface
        
        producers = input("Number of producers (default: 1): ").strip()
        producers = int(producers) if producers else 1
        
        consumers = input("Number of consumers (default: 4): ").strip()
        consumers = int(consumers) if consumers else 4
        
        engine = ProducerConsumerEngine(
            num_producers=producers,
            num_consumers=consumers,
            interface=interface
        )
        
        engine.start_engine()
    else:
        main()
```

---

## The Verification: Testing High-Performance Tools

### Verification 1: Test High-Performance Capture

```bash
cd ~/scapy-tutorial

# Test with limited packets
sudo python3 src/high_performance_capture.py -c 1000 -w 4

# Test with filter
sudo python3 src/high_performance_capture.py -f "tcp" -c 500 -w 4
```

**Expected output**: High-performance capture with statistics showing queue utilization and processing rates.

### Verification 2: Test Async Processing

```bash
# Download a PCAP for testing
cd pcap_files
wget https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http.cap
cd ..

# Process with async
python3 src/async_packet_processor.py pcap_files/http.cap -w 4
```

**Expected output**: Asynchronous processing with worker distribution.

### Verification 3: Test Efficient Data Structures

```bash
python3 src/efficient_data_structures.py pcap_files/http.cap -m 5000
```

**Expected output**: Efficient storage with memory usage and bloom filter statistics.

### Verification 4: Test Producer-Consumer Engine

```bash
sudo python3 src/producer_consumer_engine.py -c 1000 -p 1 -c 4
```

**Expected output**: Producer-consumer engine with real-time status and final statistics.

---

## Reference: Performance Optimization Guide

### Memory Optimization

| Technique | Benefit | Implementation |
|-----------|---------|----------------|
| Packet Summarization | Reduce memory usage | Store only essential fields |
| Fixed-size Arrays | Predictable memory | Use `array` module |
| Buffering | Smooth processing | Use `deque` with maxlen |
| Bloom Filters | Fast membership tests | Bit array with hash functions |
| Batch Processing | Reduce overhead | Process packets in chunks |

### CPU Optimization

| Technique | Benefit | Implementation |
|-----------|---------|----------------|
| Multi-threading | Parallel processing | `threading` module |
| Asynchronous I/O | Non-blocking operations | `asyncio` |
| Queue Management | Flow control | `queue.Queue` |
| Batch Operations | Reduce context switches | Process batches |
| Profiling | Identify bottlenecks | `cProfile` |

### I/O Optimization

| Technique | Benefit | Implementation |
|-----------|---------|----------------|
| Buffered Reading | Reduce I/O calls | `PcapReader` |
| Write Buffering | Batch writes | `queue.Queue` |
| Memory Mapping | Fast file access | `mmap` |
| Compression | Reduce storage | `gzip` |
| PCAPNG | Modern format | `PcapNgReader` |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Blocking Main Thread

```python
# DON'T: Block main thread with processing
for packet in packets:
    process(packet)  # Blocks capture

# DO: Use separate thread for processing
threading.Thread(target=process_loop).start()
```

### Pitfall 2: Queue Overload

```python
# DON'T: Unlimited queue size
queue.Queue()  # Could grow indefinitely

# DO: Limit queue size with backpressure
queue.Queue(maxsize=10000)  # Limits memory usage
```

### Pitfall 3: Not Monitoring Performance

```python
# DON'T: Blindly process without monitoring

# DO: Implement performance monitoring
def monitor_performance():
    while running:
        print(f"Queue size: {queue.qsize()}")
        print(f"Processing rate: {rate}")
        time.sleep(5)
```

### Best Practice: Graceful Shutdown

```python
def signal_handler(sig, frame):
    """Handle shutdown signals gracefully."""
    global running
    running = False
    # Wait for threads to finish
    for thread in threads:
        thread.join(timeout=5)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ High-performance packet capture engine
2. ✅ Asynchronous packet processing
3. ✅ Efficient data structures
4. ✅ Producer-consumer pattern
5. ✅ Performance monitoring
6. ✅ Memory optimization
7. ✅ Multi-threaded processing

---

## Next Steps: Preview of Part 2

In **Module 6, Part 2: Custom Protocol Development**, we'll:

1. Build custom protocol dissectors
2. Create custom packet classes
3. Implement protocol bindings
4. Extend Scapy with custom protocols
5. Build protocol analysis tools

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: MODULE 6, PART 1 COMPLETE                                  │
│  ✅ High-performance capture engine built                           │
│  ✅ Async processing implemented                                    │
│  ✅ Efficient data structures developed                             │
│  ✅ Producer-consumer pattern implemented                           │
│  ✅ Performance optimization techniques applied                     │
│  NEXT: MODULE 6, PART 2 — Custom Protocol Development             │
│  ● Custom protocol dissectors                                      │
│  ● Custom packet classes                                           │
│  ● Protocol bindings                                               │
│  ● Extending Scapy                                                │
│  ● Protocol analysis tools                                         │
└─────────────────────────────────────────────────────────────────────────
```

*When you're ready, proceed to Part 2, where we'll build custom protocol dissectors and extend Scapy to support proprietary and experimental protocols.*
