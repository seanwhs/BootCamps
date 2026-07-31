# QUIZ AND TEST BANK
## Python for Hackers: Advanced Engineering & Defensive Architecture

### Comprehensive Assessment Suite with Answer Keys

---

```
[STARTING: Quiz and Test Bank Generation]
[COMPLETED: Student Notes]
[GENERATING: Complete Assessment Package]
```

---

## TABLE OF CONTENTS

### Part 0: Introduction & Setup
- [Quiz 0.1: Course Fundamentals](#quiz-01-course-fundamentals)
- [Quiz 0.2: Environment Setup](#quiz-02-environment-setup)

### Part 1: Infrastructure Automation & Protocol Analysis
- [Quiz 1.1: Configuration Management](#quiz-11-configuration-management)
- [Quiz 1.2: Logging Systems](#quiz-12-logging-systems)
- [Quiz 1.3: Session Management](#quiz-13-session-management)
- [Quiz 1.4: Paramiko Fundamentals](#quiz-14-paramiko-fundamentals)
- [Quiz 1.5: Netmiko Fundamentals](#quiz-15-netmiko-fundamentals)
- [Quiz 1.6: Scapy Fundamentals](#quiz-16-scapy-fundamentals)
- [Quiz 1.7: Protocol Abstraction](#quiz-17-protocol-abstraction)

### Part 2: High-Speed Packet Sniffing & Asynchronous Integration
- [Quiz 2.1: Event Loop & Async Basics](#quiz-21-event-loop--async-basics)
- [Quiz 2.2: Async Packet Sniffing](#quiz-22-async-packet-sniffing)
- [Quiz 2.3: Queue Management](#quiz-23-queue-management)
- [Quiz 2.4: Packet Injection](#quiz-24-packet-injection)

### Part 3: Stealth Reconnaissance & Asynchronous Tooling
- [Quiz 3.1: Async Scanning](#quiz-31-async-scanning)
- [Quiz 3.2: Brute Forcing](#quiz-32-brute-forcing)
- [Quiz 3.3: DOM Analysis](#quiz-33-dom-analysis)
- [Quiz 3.4: Modular Recon](#quiz-34-modular-recon)

### Part 4: Advanced Tooling Design, Obfuscation & Hardening
- [Quiz 4.1: Plugin Architecture](#quiz-41-plugin-architecture)
- [Quiz 4.2: Code Obfuscation](#quiz-42-code-obfuscation)
- [Quiz 4.3: Security Hardening](#quiz-43-security-hardening)
- [Quiz 4.4: Production CLI](#quiz-44-production-cli)

### Comprehensive Exams
- [Midterm Examination](#midterm-examination)
- [Final Examination](#final-examination)
- [Practical Exam: Packet Analysis](#practical-exam-packet-analysis)
- [Practical Exam: Reconnaissance Tool](#practical-exam-reconnaissance-tool)

### Answer Keys
- [Answer Key: Part 0 Quizzes](#answer-key-part-0-quizzes)
- [Answer Key: Part 1 Quizzes](#answer-key-part-1-quizzes)
- [Answer Key: Part 2 Quizzes](#answer-key-part-2-quizzes)
- [Answer Key: Part 3 Quizzes](#answer-key-part-3-quizzes)
- [Answer Key: Part 4 Quizzes](#answer-key-part-4-quizzes)
- [Answer Key: Midterm Examination](#answer-key-midterm-examination)
- [Answer Key: Final Examination](#answer-key-final-examination)

---

## QUIZ 0.1: COURSE FUNDAMENTALS

### Multiple Choice (Circle the correct answer)

**1. What is the primary purpose of this course?**
- A) To learn basic Python programming
- B) To build a production-grade security framework
- C) To become a system administrator
- D) To learn web development

**2. Which library is NOT covered in this course?**
- A) Scapy
- B) Netmiko
- C) Django
- D) Paramiko

**3. The course follows what teaching methodology?**
- A) Lecture only
- B) Code-heavy with verification steps
- C) Theory only
- D) Group projects only

**4. What is the name of the framework you will build?**
- A) PySec Suite
- B) PyHack Suite
- C) Python Shield
- D) SecurityForge

**5. Which of the following is NOT a prerequisite?**
- A) Basic Python proficiency
- B) Networking fundamentals
- C) Web development experience
- D) Command-line familiarity

### True/False

**6. This course teaches techniques that can be used for illegal activities without restriction.**

**7. The course uses asynchronous programming for performance.**

**8. Scapy is used for network device automation in this course.**

**9. Docker is required for this course.**

**10. The framework built in this course includes a plugin architecture.**

### Short Answer

**11. List four key features of the PyHack Suite framework.**

1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________
4. _______________________________________________________________

**12. What is the "Pyramid of Understanding" in this course?**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**13. Name three libraries you'll learn in Part 1 and their purposes.**

| Library | Purpose |
|---------|---------|
| 1. | |
| 2. | |
| 3. | |

---

## QUIZ 0.2: ENVIRONMENT SETUP

### Multiple Choice

**1. What command creates a Python virtual environment?**
- A) `python venv`
- B) `python -m venv venv`
- C) `virtualenv create`
- D) `python --venv`

**2. How do you activate a virtual environment on Linux?**
- A) `venv\Scripts\activate`
- B) `source venv/bin/activate`
- C) `activate venv`
- D) `venv activate`

**3. Which command installs development dependencies?**
- A) `pip install requirements.txt`
- B) `pip install -r requirements.txt`
- C) `pip install --dev`
- D) `pip install development`

**4. What does the Playwright command `playwright install` do?**
- A) Installs the Playwright package
- B) Downloads browser binaries
- C) Installs dependencies
- D) Creates a configuration file

**5. Which file contains environment variables for the project?**
- A) `.env`
- B) `config.py`
- C) `settings.json`
- D) `variables.txt`

### Fill in the Blanks

**6. The command to upgrade pip is `pip install --upgrade ______`**

**7. To install the project in development mode, use `pip install -e .` which means "______"**

**8. The verification script checks if packages are installed by trying to ______ them.**

**9. On Windows, the virtual environment activation command is `______\Scripts\activate`**

**10. The `__init__.py` file makes a directory a Python ______**

### Matching

**Match the tool to its purpose:**

| Tool | Purpose |
|------|---------|
| 1. pytest | A) Code formatting |
| 2. black | B) Type checking |
| 3. mypy | C) Testing |
| 4. ruff | D) Linting |
| 5. pre-commit | E) Git hooks |

- 1. ___
- 2. ___
- 3. ___
- 4. ___
- 5. ___

---

## QUIZ 1.1: CONFIGURATION MANAGEMENT

### Multiple Choice

**1. Why should you use environment variables for configuration?**
- A) They are faster
- B) They keep secrets out of code
- C) They are easier to write
- D) They are required by Python

**2. What is the Singleton pattern used for in the ConfigLoader?**
- A) To create multiple configurations
- B) To ensure only one configuration instance exists
- C) To make configuration faster
- D) To allow configuration changes

**3. Which dataclass field type would you use for a boolean configuration value?**
- A) `str`
- B) `int`
- C) `bool`
- D) `float`

**4. How do you convert an environment variable to an integer in Python?**
- A) `os.getenv("PORT")`
- B) `int(os.getenv("PORT", "8000"))`
- C) `os.environ["PORT"].to_int()`
- D) `parse_int(os.getenv("PORT"))`

**5. What is the purpose of the `__post_init__` method in a dataclass?**
- A) To initialize the class
- B) To validate configuration after initialization
- C) To save configuration to disk
- D) To load environment variables

### Fill in the Blanks

**6. The `python-dotenv` package loads variables from a ______ file.**

**7. A dataclass with field defaults uses the `field(default=______)` syntax.**

**8. Environment variables should be loaded from a file called `______`**

**9. The configuration loader follows the ______ pattern.**

**10. The `os.getenv()` function returns ______ if the variable is not found.**

### Code Analysis

**11. What does this code do?**
```python
@dataclass
class NetworkConfig:
    scapy_interface: str = field(default="eth0")
```

_________________________________________________________________

**12. Why is this validation important?**
```python
if self.scapy_buffer_size < 1500:
    logger.warning("Buffer size is less than MTU")
```

_________________________________________________________________

### Short Answer

**13. List three benefits of using environment variables for configuration.**

1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________

---

## QUIZ 1.2: LOGGING SYSTEMS

### Multiple Choice

**1. Which log level would you use for detailed debugging information?**
- A) INFO
- B) DEBUG
- C) WARNING
- D) ERROR

**2. What is log rotation?**
- A) Changing log levels
- B) Creating new log files after reaching a size limit
- C) Moving logs to a different directory
- D) Deleting all logs

**3. Why is sensitive data redaction important in logging?**
- A) To save disk space
- B) To prevent credential leakage
- C) To make logs faster
- D) To comply with style guides

**4. What does the `StructuredFormatter` produce?**
- A) Plain text logs
- B) JSON logs
- C) XML logs
- D) Binary logs

**5. Which Python module provides logging functionality?**
- A) `log`
- B) `logging`
- C) `logger`
- D) `syslog`

### Fill in the Blanks

**6. The five standard log levels in order from lowest to highest are: ______, ______, ______, ______, ______**

**7. A log filter that redacts sensitive data is called a `______`**

**8. A rotating file handler with max bytes of 10MB and 5 backups is created with `maxBytes=______` and `backupCount=______`**

**9. The `logger.exception()` method automatically adds ______ information to logs.**

**10. Structured logging outputs logs in ______ format for machine parsing.**

### Code Analysis

**11. What does this code do?**
```python
class RedactingFilter(logging.Filter):
    def filter(self, record):
        record.msg = pattern.sub('[REDACTED]', record.msg)
        return True
```

_________________________________________________________________

**12. What is the purpose of this formatter?**
```python
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
```

_________________________________________________________________

### Short Answer

**13. List three best practices for secure logging.**

1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________

---

## QUIZ 1.3: SESSION MANAGEMENT

### Multiple Choice

**1. What is connection pooling?**
- A) Connecting to multiple devices at once
- B) Reusing connections to improve performance
- C) Pooling network traffic
- D) Combining multiple connections into one

**2. Which connection state means the connection is ready for commands?**
- A) CONNECTING
- B) CONNECTED
- C) AUTHENTICATED
- D) INITIALIZED

**3. What is the purpose of a session ID?**
- A) To identify a user
- B) To uniquely identify a connection
- C) To encrypt data
- D) To authenticate requests

**4. Which connection type uses Netmiko?**
- A) SSH
- B) Network device automation
- C) Raw socket
- D) HTTP

**5. What happens when a session is closed?**
- A) The connection is terminated
- B) The connection is returned to the pool
- C) Both A and B
- D) Neither A nor B

### True/False

**6. Session cleanup runs automatically in the background.**

**7. Connections are always created from scratch when requested.**

**8. The session manager is thread-safe.**

**9. Netmiko requires a device_type to be specified.**

**10. All connection types support command execution.**

### Fill in the Blanks

**11. The session manager implements the ______ pattern to ensure only one instance exists.**

**12. A session ID is generated by combining the connection type, host, port, and ______**

**13. The `ConnectionPool` uses a `queue.Queue` with a maximum size of ______**

**14. The `session_context` function is a ______ manager for automatic cleanup.**

**15. Connection status is tracked using an ______ enum.**

### Short Answer

**16. Describe the lifecycle of a session from creation to cleanup.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

---

## QUIZ 1.4: PARAMIKO FUNDAMENTALS

### Multiple Choice

**1. What is Paramiko primarily used for in this course?**
- A) Packet manipulation
- B) SSH automation
- C) Network device management
- D) Web scraping

**2. Which policy should you use for missing host keys?**
- A) `RejectPolicy`
- B) `AutoAddPolicy`
- C) `WarningPolicy`
- D) `IgnorePolicy`

**3. What is the SFTP client used for?**
- A) Command execution
- B) File transfers
- C) Packet sniffing
- D) Device configuration

**4. How do you execute a command with sudo in Paramiko?**
- A) Pass `sudo=True` to exec_command
- B) Wrap the command with sudo and provide password
- C) Use a special sudo method
- D) It's not possible

**5. What is an interactive shell used for?**
- A) Running commands that need terminal interaction
- B) File transfers
- C) Packet sniffing
- D) Device discovery

### Fill in the Blanks

**6. Paramiko's `SSHClient` uses `set_missing_host_key_policy()` to handle ______**

**7. The `exec_command()` method returns `(stdin, stdout, ______)`**

**8. To load a private key, use `paramiko.RSAKey.from_private_key_______()`**

**9. The `invoke_shell()` method creates an ______ shell session.**

**10. When using sudo, the password is sent via ______**

### Code Analysis

**11. What is wrong with this code?**
```python
client = paramiko.SSHClient()
client.connect(host='localhost', username='user', password='pass')
```

_________________________________________________________________

**12. What does this code accomplish?**
```python
sftp = client.open_sftp()
sftp.put(local_path, remote_path)
sftp.close()
```

_________________________________________________________________

### Short Answer

**13. List three authentication methods supported by Paramiko.**

1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________

---

## QUIZ 1.5: NETMIKO FUNDAMENTALS

### Multiple Choice

**1. What is Netmiko primarily used for?**
- A) Packet manipulation
- B) Multi-vendor device automation
- C) SSH automation
- D) Web scraping

**2. Which device type is NOT supported by Netmiko?**
- A) `cisco_ios`
- B) `juniper_junos`
- C) `arista_eos`
- D) `windows_server`

**3. How do you send configuration commands in Netmiko?**
- A) `send_command()`
- B) `send_config_set()`
- C) `configure()`
- D) `apply_config()`

**4. What does the `send_command()` method return?**
- A) A dictionary
- B) A string of command output
- C) A tuple of stdout/stderr
- D) A boolean success value

**5. How do you save configuration in Netmiko?**
- A) `save_config()`
- B) `write_memory()`
- C) `commit()`
- D) Depends on device type

### True/False

**6. Netmiko only supports Cisco devices.**

**7. Netmiko handles device-specific syntax automatically.**

**8. You can use both password and secret in device configuration.**

**9. Netmiko requires a timeout parameter for all connections.**

**10. The `send_commands()` method sends multiple commands sequentially.**

### Fill in the Blanks

**11. Netmiko is built on top of the ______ library.**

**12. The `ConnectHandler()` function creates a ______ object.**

**13. Device families are detected by checking the ______ field.**

**14. The `send_command()` method has parameters for stripping ______ and ______**

**15. Juniper devices require entering ______ mode for configuration.**

### Short Answer

**16. Explain the difference between Paramiko and Netmiko use cases.**

_________________________________________________________________

_________________________________________________________________

---

## QUIZ 1.6: SCAPY FUNDAMENTALS

### Multiple Choice

**1. What is Scapy primarily used for?**
- A) SSH automation
- B) Packet manipulation and analysis
- C) Device automation
- D) Web scraping

**2. How do you build a packet in Scapy?**
- A) `PacketBuilder()`
- B) Layer composition using `/`
- C) `create_packet()`
- D) `PacketFactory()`

**3. Which function sends a packet at Layer 3?**
- A) `send()`
- B) `sendp()`
- C) `sr()`
- D) `sr1()`

**4. How do you sniff packets in Scapy?**
- A) `sniff()`
- B) `capture()`
- C) `listen()`
- D) `grab()`

**5. What does `store=False` do in sniffing?**
- A) Saves packets to disk
- B) Doesn't store packets in memory
- C) Disables packet capture
- D) Compresses packets

### Fill in the Blanks

**6. A packet is built by combining layers using the ______ operator.**

**7. The `sr1()` function sends a packet and waits for one ______**

**8. To save packets to a file, use the `wrpcap()` function with a ______ extension.**

**9. The `fuzz()` function randomizes packet ______**

**10. An ARP request is created with `ARP(pdst="______")`**

### Code Analysis

**11. What does this code do?**
```python
packet = IP(dst="192.168.1.1") / TCP(dport=80, flags="S")
```

_________________________________________________________________

**12. What is the purpose of this code?**
```python
packets = sniff(filter="tcp port 80", count=10, store=False)
```

_________________________________________________________________

### Short Answer

**13. List four protocols that Scapy supports.**

1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________
4. _______________________________________________________________

---

## QUIZ 1.7: PROTOCOL ABSTRACTION

### Multiple Choice

**1. What is the purpose of the protocol abstraction layer?**
- A) To make protocols faster
- B) To provide a unified interface for different protocols
- C) To encrypt all traffic
- D) To automatically select the best protocol

**2. Which design pattern is used by ProtocolFactory?**
- A) Singleton
- B) Factory
- C) Observer
- D) Strategy

**3. What does the `NetworkInterface` abstract class define?**
- A) Common methods for all protocols
- B) Specific protocol implementations
- C) Configuration options
- D) Error handling

**4. How does the UnifiedNetworkManager handle connections?**
- A) Creates a new connection for each operation
- B) Reuses connections by name
- C) Always uses SSH
- D) Uses a connection pool

**5. What is the benefit of protocol abstraction?**
- A) Better performance
- B) Code reuse and simpler API
- C) Stronger encryption
- D) Automatic protocol selection

### Fill in the Blanks

**6. The `ProtocolFactory.create_interface()` method returns a ______ object.**

**7. The `UnifiedNetworkManager` stores connections in a ______ mapping names to interfaces.**

**8. Convenience methods like `ssh_command()` handle connection ______ automatically.**

**9. Protocol detection can be based on the target ______**

**10. The abstraction layer follows the ______ principle by defining a common interface.**

### Short Answer

**11. Describe the benefits of using a protocol abstraction layer.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

---

## QUIZ 2.1: EVENT LOOP & ASYNC BASICS

### Multiple Choice

**1. What does `async def` define?**
- A) A normal function
- B) A coroutine function
- C) A class method
- D) A decorator

**2. What does the `await` keyword do?**
- A) Pauses the coroutine until the awaited object completes
- B) Creates a new coroutine
- C) Cancels a task
- D) Starts an event loop

**3. What is the entry point for running async code?**
- A) `asyncio.start()`
- B) `asyncio.run()`
- C) `asyncio.loop()`
- D) `asyncio.begin()`

**4. How do you create a background task?**
- A) `asyncio.create_task()`
- B) `asyncio.background()`
- C) `asyncio.schedule()`
- D) `asyncio.run_task()`

**5. What does the event loop manage?**
- A) Only network I/O
- B) All async tasks and I/O
- C) Only CPU operations
- D) Only file operations

### True/False

**6. `await` can be used outside of async functions.**

**7. The event loop runs in a single thread.**

**8. Tasks are scheduled to run immediately when created.**

**9. `asyncio.sleep()` blocks the event loop.**

**10. The event loop must be closed after use.**

### Fill in the Blanks

**11. A function defined with `async def` returns a ______ object when called.**

**12. The `run_coroutine_threadsafe()` method is used for thread-______ scheduling.**

**13. The `shutdown()` method should handle ______ gracefully.**

**14. The event loop schedules tasks based on ______ completion.**

**15. A `Future` is a placeholder for a ______ that will be available later.**

---

## QUIZ 2.2: ASYNC PACKET SNIFFING

### Multiple Choice

**1. What is the purpose of `AsyncSniffer` in Scapy?**
- A) To block packet capture
- B) To provide non-blocking packet capture
- C) To save packets to disk
- D) To analyze packets

**2. How are packets passed from the sniffing thread to the async loop?**
- A) Using a shared memory buffer
- B) Using an async queue
- C) Using callback functions
- D) Using socket pairs

**3. What is backpressure in the context of queue management?**
- A) Increasing processing speed
- B) Slowing down producers when consumers are overwhelmed
- C) Dropping all packets
- D) Redirecting traffic

**4. What is the benefit of `store=False` in sniffing?**
- A) Faster capture
- B) Lower memory usage
- C) Better packet analysis
- D) Both A and B

**5. What does the `stream()` method in `AsyncPacketSniffer` do?**
- A) Saves packets to a stream file
- B) Provides an async iterator of packets
- C) Sends packets in a stream
- D) Filters packets in real-time

### Fill in the Blanks

**6. The `AsyncSniffer` runs in a ______ thread while the async loop processes packets.**

**7. A packet queue with backpressure prevents ______ exhaustion.**

**8. The `_on_packet_captured()` method adds packets to the async ______**

**9. Packet processing is done in the ______ loop to avoid blocking the sniffer.**

**10. The `AsyncPacketSniffer` uses the `event_loop` to schedule the ______ loop.**

### Code Analysis

**11. What is the purpose of this code?**
```python
def _on_packet_captured(self, packet):
    try:
        self.packet_queue.put_nowait(packet)
    except asyncio.QueueFull:
        self.stats.total_dropped += 1
```

_________________________________________________________________

---

## QUIZ 2.3: QUEUE MANAGEMENT

### Multiple Choice

**1. What is a priority queue?**
- A) A queue where all items are equal
- B) A queue where items are ordered by priority
- C) A queue that drops low priority items
- D) A queue that processes items in order of arrival

**2. What is a ring buffer?**
- A) A circular buffer with fixed size
- B) A buffer that grows infinitely
- C) A buffer that stores only metadata
- D) A buffer that uses linked lists

**3. What does the backpressure manager do?**
- A) Increases pressure on the system
- B) Detects when consumers are overwhelmed and prevents overload
- C) Sends backpressure signals to producers
- D) Forces data loss

**4. What is a throttled queue?**
- A) A queue with rate limiting
- B) A queue that never blocks
- C) A queue that only processes one item at a time
- D) A queue that uses priority ordering

**5. Which queue is best for high-performance packet storage?**
- A) FIFO queue
- B) Priority queue
- C) Ring buffer
- D) Throttled queue

### Fill in the Blanks

**6. A ring buffer uses a fixed-size ______ array.**

**7. The `heapq` module is used to implement ______ queues.**

**8. Backpressure is a form of ______ control.**

**9. A throttled queue limits the rate of ______**

**10. Queue statistics include `total_enqueued`, `total_dequeued`, and ______**

### Short Answer

**11. Explain the difference between a FIFO queue and a priority queue.**

_________________________________________________________________

_________________________________________________________________

---

## QUIZ 2.4: PACKET INJECTION

### Multiple Choice

**1. What is scheduled injection?**
- A) Sending packets at specific times
- B) Sending packets in response to triggers
- C) Sending fuzzed packets
- D) Sending packets to a specific host

**2. What is trigger-based injection?**
- A) Sending packets at specific times
- B) Sending packets in response to packet triggers
- C) Sending fuzzed packets
- D) Sending packets to a specific host

**3. What is jitter used for in injection?**
- A) To improve performance
- B) To avoid detection by randomizing timing
- C) To increase packet loss
- D) To reduce packet size

**4. What does the `create_tcp_syn_flood` helper do?**
- A) Creates a TCP SYN flood attack
- B) Creates a UDP flood attack
- C) Creates an ICMP flood attack
- D) Creates an ARP spoofing attack

**5. What is fuzzing injection used for?**
- A) Testing protocol implementations
- B) Avoiding detection
- C) Improving performance
- D) Encrypting traffic

### Fill in the Blanks

**6. The `InjectionConfig` class defines parameters like `delay`, `interval`, and ______**

**7. Trigger-based injection uses a ______ sniffer to detect trigger packets.**

**8. Jitter adds ______ to packet timing to avoid detection.**

**9. The `send_ip_packet()` method sends packets at the ______ layer.**

**10. ARP spoofing involves sending ______ ARP replies to redirect traffic.**

---

## QUIZ 3.1: ASYNC SCANNING

### Multiple Choice

**1. What is the advantage of async scanning over synchronous scanning?**
- A) Simpler code
- B) Better security
- C) Higher throughput
- D) More accurate results

**2. What is the difference between TCP Connect and SYN scanning?**
- A) SYN scanning completes the handshake
- B) TCP Connect completes the handshake
- C) TCP Connect is stealthier
- D) There is no difference

**3. What is service detection?**
- A) Detecting if a service is running
- B) Identifying the version of a service
- C) Both A and B
- D) Neither A nor B

**4. How does OS fingerprinting work?**
- A) By analyzing TCP options
- B) By checking open ports
- C) By analyzing packet TTL
- D) All of the above

**5. What is a stealth scan?**
- A) A scan that doesn't log anything
- B) A scan that avoids detection by using jitter and randomization
- C) A scan that uses encryption
- D) A scan that runs at night

### Fill in the Blanks

**6. Asynchronous scanning uses a ______ to control concurrency.**

**7. The `default_ports` configuration defines which ports to scan by ______**

**8. OS fingerprinting uses ______ signatures based on open ports.**

**9. Service detection checks for ______ in banners.**

**10. Rate limiting controls ______ per second.**

---

## QUIZ 3.2: BRUTE FORCING

### Multiple Choice

**1. What is HTTP Basic Auth brute forcing?**
- A) Trying username/password combinations
- B) Trying different URLs
- C) Trying different HTTP methods
- D) Trying different headers

**2. What is directory brute forcing?**
- A) Discovering web directories
- B) Trying different passwords
- C) Discovering subdomains
- D) Scanning for open ports

**3. What is subdomain brute forcing?**
- A) Discovering subdomains
- B) Discovering web directories
- C) Trying different passwords
- D) Scanning for open ports

**4. What is jitter used for in brute forcing?**
- A) To improve performance
- B) To avoid detection
- C) To increase success rate
- D) To reduce memory usage

**5. How can you detect a successful credential?**
- A) By checking response code
- B) By checking response content
- C) By checking response time
- D) All of the above

### Fill in the Blanks

**6. HTTP Basic Auth uses the `Authorization` header with the value `Basic ______`**

**7. A wordlist contains possible ______ to try.**

**8. Rate limiting in brute forcing prevents ______ lockouts.**

**9. User-agent rotation helps avoid ______**

**10. The `bruteforce_http_basic()` method takes `usernames` and ______ lists.**

---

## QUIZ 3.3: DOM ANALYSIS

### Multiple Choice

**1. Why use a headless browser for DOM analysis?**
- A) To render JavaScript content
- B) To make requests faster
- C) To save bandwidth
- D) To avoid detection

**2. What is Playwright used for in this course?**
- A) Packet sniffing
- B) Headless browser automation
- C) SSH connections
- D) Configuration management

**3. What is BeautifulSoup used for?**
- A) Parsing HTML content
- B) Making HTTP requests
- C) Sniffing packets
- D) Managing connections

**4. What are common vulnerabilities detected by DOM analysis?**
- A) Missing security headers
- B) Forms without CSRF tokens
- C) Inline JavaScript with eval
- D) All of the above

**5. What is web crawling in the context of DOM analysis?**
- A) Following links to analyze multiple pages
- B) Making multiple HTTP requests
- C) Sniffing web traffic
- D) Analyzing packet captures

### Fill in the Blanks

**6. Playwright launches a headless ______ browser.**

**7. The `analyze_page()` method can either render JS or use ______ HTTP.**

**8. DOM analysis extracts forms, links, and ______ from the page.**

**9. Security headers are checked for missing values like ______**

**10. Web crawling respects `max_pages` and ______ depth.**

---

## QUIZ 3.4: MODULAR RECON

### Multiple Choice

**1. What is the benefit of modular architecture?**
- A) Easier to extend
- B) Better performance
- C) Stronger security
- D) All of the above

**2. What does the `ReconModule` abstract class define?**
- A) The interface for all modules
- B) Specific module implementations
- C) Configuration options
- D) Testing utilities

**3. What is the ModuleRegistry used for?**
- A) Storing module instances
- B) Tracking module dependencies
- C) Registering and discovering modules
- D) Running modules

**4. What are module hooks (pre_run, post_run)?**
- A) Error handling mechanisms
- B) Setup and cleanup methods
- C) Performance optimizations
- D) Security checks

**5. What is the purpose of module metadata?**
- A) To describe module capabilities and dependencies
- B) To store module results
- C) To track module performance
- D) To encrypt module data

### Fill in the Blanks

**6. The `ModuleManager` uses a ______ to manage module execution.**

**7. Modules can have ______ that must be satisfied before loading.**

**8. Module results are stored in the `self.results` ______**

**9. The `export_results()` method can output ______ or text format.**

**10. The base module interface uses the ______ pattern.**

---

## QUIZ 4.1: PLUGIN ARCHITECTURE

### Multiple Choice

**1. What is the plugin lifecycle?**
- A) UNLOADED → LOADING → RUNNING → STOPPED
- B) INITIALIZED → RUNNING → STOPPED → UNLOADED
- C) UNLOADED → LOADING → LOADED → INITIALIZING → RUNNING → STOPPED
- D) LOADING → RUNNING → UNLOADED

**2. What is a plugin manifest?**
- A) A configuration file
- B) Metadata about the plugin
- C) Plugin source code
- D) Plugin dependencies

**3. What does the `requires` field in a manifest define?**
- A) Required permissions
- B) Required dependencies
- C) Required features
- D) Required versions

**4. What is the purpose of the plugin loader?**
- A) To discover and load plugins
- B) To run plugins
- C) To test plugins
- D) To delete plugins

**5. What does `sandboxed: True` indicate?**
- A) The plugin runs in a sandbox
- B) The plugin is not secure
- C) The plugin requires root privileges
- D) The plugin is a service

### Fill in the Blanks

**6. Plugin states are defined using an ______ enum.**

**7. The `on_load()` method is called when the plugin is ______**

**8. Dependencies are checked before a plugin is ______**

**9. The plugin loader uses ______ import for dynamic loading.**

**10. Plugins can have ______ to resolve conflicts.**

---

## QUIZ 4.2: CODE OBFUSCATION

### Multiple Choice

**1. What is the purpose of code obfuscation?**
- A) To make code run faster
- B) To make code harder to read and analyze
- C) To encrypt the code
- D) To compress the code

**2. What is XOR encoding?**
- A) A symmetric encryption method
- B) A simple encoding using XOR operations
- C) A hashing algorithm
- D) A compression method

**3. What is the difference between obfuscation and encryption?**
- A) Obfuscation is stronger
- B) Encryption is reversible with a key
- C) There is no difference
- D) Obfuscation is reversible

**4. What is dead code insertion?**
- A) Adding non-executed code to confuse analysis
- B) Removing unused code
- C) Optimizing code
- D) Testing code

**5. What is variable renaming used for in obfuscation?**
- A) To improve readability
- B) To make analysis harder
- C) To reduce file size
- D) To fix bugs

### Fill in the Blanks

**6. RC4 is a ______ cipher used for encoding.**

**7. Base64 encoding is ______, not secure.**

**8. The `StringObfuscator` class provides multiple ______ techniques.**

**9. Signature evasion helps avoid ______ detection.**

**10. Obfuscation is for ______, not for protecting secrets.**

---

## QUIZ 4.3: SECURITY HARDENING

### Multiple Choice

**1. What is input validation?**
- A) Checking that input is safe before use
- B) Making input faster
- C) Encrypting input
- D) Storing input

**2. What is path traversal?**
- A) Reading files outside the allowed directory
- B) Moving through directory structures
- C) Creating new directories
- D) Deleting files

**3. What is sandboxing?**
- A) Running code in an isolated environment
- B) Running code in production
- C) Running code in a container
- D) Running code in a virtual machine

**4. What is command injection?**
- A) Executing arbitrary commands
- B) Injecting SQL commands
- C) Injecting HTML
- D) Injecting packets

**5. Why use bcrypt for password hashing?**
- A) It's fast
- B) It's designed for passwords with salt and work factor
- C) It's the default
- D) It's simple

### Fill in the Blanks

**6. Parameterized queries prevent ______ injection.**

**7. A sandbox has resource limits for CPU, memory, and ______**

**8. The `InputValidator` class provides methods for ______ input.**

**9. Secrets should be stored in ______ variables, not in code.**

**10. The `SecretManager` class logs ______ to track access.**

---

## QUIZ 4.4: PRODUCTION CLI

### Multiple Choice

**1. What is Click used for in this course?**
- A) Building CLI applications
- B) Building web applications
- C) Managing packages
- D) Testing code

**2. What is the purpose of the `@click.group()` decorator?**
- A) To define a command group
- B) To define a single command
- C) To define options
- D) To define arguments

**3. What is Rich used for in the CLI?**
- A) Beautiful output formatting
- B) Making HTTP requests
- C) Packet sniffing
- D) Configuration management

**4. What is a subcommand?**
- A) A command under a command group
- B) A command with options
- C) A command with arguments
- D) A standalone command

**5. How does the CLI handle errors?**
- A) By crashing
- B) By displaying formatted error messages
- C) By ignoring them
- D) By retrying

### Fill in the Blanks

**6. The `cli` function is decorated with `@click.______()`**

**7. The `scan` command uses `@click.______()` for arguments and `@click.______()` for options.**

**8. Rich provides `Table`, `Progress`, and ______ classes.**

**9. The `console.print()` method displays ______ output.**

**10. The CLI uses a ______ pattern for command organization.**

---

## MIDTERM EXAMINATION

### Part A: Multiple Choice (40 points, 2 points each)

**1. What is the primary purpose of the Session Manager?**
- A) To manage user sessions
- B) To manage network connections
- C) To manage configuration
- D) To manage logging

**2. Which library is used for multi-vendor device automation?**
- A) Paramiko
- B) Netmiko
- C) Scapy
- D) asyncio

**3. What does `store=False` do in Scapy sniffing?**
- A) Prevents packet capture
- B) Prevents storing packets in memory
- C) Disables filters
- D) Enables compression

**4. What is a coroutine in Python?**
- A) A function defined with `async def`
- B) A normal function
- C) A class method
- D) A decorator

**5. What is connection pooling?**
- A) Creating many connections
- B) Reusing connections for performance
- C) Dropping connections
- D) Encrypting connections

**6. What is the purpose of log rotation?**
- A) To change log levels
- B) To prevent disk filling
- C) To encrypt logs
- D) To compress logs

**7. Which function sends a packet at Layer 2?**
- A) `send()`
- B) `sendp()`
- C) `sr()`
- D) `sr1()`

**8. What is the purpose of the event loop?**
- A) To run sync code
- B) To schedule and run async tasks
- C) To manage memory
- D) To handle errors

**9. What is backpressure?**
- A) Increasing producer speed
- B) Slowing producers when consumers are overwhelmed
- C) Dropping all packets
- D) Increasing queue size

**10. Which of the following is a stealth scanning technique?**
- A) Random port order
- B) Jitter
- C) Rate limiting
- D) All of the above

**11. What is service detection?**
- A) Identifying service versions from banners
- B) Checking if a service is running
- C) Both A and B
- D) Neither A nor B

**12. What is the purpose of Playwright in this course?**
- A) Packet sniffing
- B) Headless browser automation
- C) SSH connections
- D) Device automation

**13. What is a plugin manifest?**
- A) Metadata about the plugin
- B) Plugin source code
- C) Plugin configuration
- D) Plugin dependencies

**14. What is code obfuscation?**
- A) Making code run faster
- B) Making code harder to read
- C) Encrypting code
- D) Compressing code

**15. What is sandboxing?**
- A) Running code in production
- B) Running code in an isolated environment
- C) Running code in a container
- D) Running code in a VM

**16. What does Click provide in this course?**
- A) Web framework
- B) CLI framework
- C) Testing framework
- D) Security framework

**17. What is the Singleton pattern used for?**
- A) Creating multiple instances
- B) Ensuring only one instance exists
- C) Making code faster
- D) Sharing data

**18. What is a ring buffer?**
- A) A circular fixed-size buffer
- B) An infinite buffer
- C) A priority buffer
- D) A compressed buffer

**19. What is parameterized query used for?**
- A) SQL injection prevention
- B) XSS prevention
- C) Command injection prevention
- D) Path traversal prevention

**20. What is the benefit of modular architecture?**
- A) Extensibility
- B) Maintainability
- C) Testability
- D) All of the above

### Part B: Fill in the Blanks (20 points, 2 points each)

**21. The `python-dotenv` package loads variables from a ______ file.**

**22. Netmiko is built on top of the ______ library.**

**23. A packet is built by combining layers using the ______ operator.**

**24. The `asyncio.create_task()` function creates a ______ task.**

**25. The `AsyncSniffer` runs in a ______ thread while the async loop processes packets.**

**26. OS fingerprinting uses ______ signatures based on open ports.**

**27. BeautifulSoup is used for parsing ______ content.**

**28. The `ModuleManager` uses a ______ to manage module execution.**

**29. The `on_load()` method is called when the plugin is ______**

**30. Secrets should be stored in ______ variables, not in code.**

### Part C: Short Answer (20 points, 5 points each)

**31. Explain the difference between Paramiko, Netmiko, and Scapy, and when you would use each.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**32. Describe the asynchronous packet sniffing architecture and how packets move from capture to processing.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**33. Explain the plugin lifecycle and why it's important for security.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**34. List and explain three security hardening techniques implemented in the framework.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

### Part D: Code Analysis (20 points)

**35. Analyze the following code and answer the questions:**

```python
class AsyncPacketSniffer:
    def __init__(self, interface=None, filter_str=None):
        self.interface = interface or "eth0"
        self.filter_str = filter_str
        self.packet_queue = asyncio.Queue(maxsize=1000)
        self.sniffer = None
        self._running = False
    
    async def start(self):
        self._running = True
        
        def packet_handler(packet):
            try:
                self.packet_queue.put_nowait(packet)
            except asyncio.QueueFull:
                self.stats.total_dropped += 1
        
        self.sniffer = AsyncSniffer(
            iface=self.interface,
            filter=self.filter_str,
            prn=packet_handler,
            store=False
        )
        self.sniffer.start()
        await self._process_loop()
    
    async def _process_loop(self):
        while self._running:
            packet = await self.packet_queue.get()
            await self._process_packet(packet)
```

**a) What is the purpose of the packet queue? (4 points)**

_________________________________________________________________

**b) What happens when the queue is full? (4 points)**

_________________________________________________________________

**c) Why is `store=False` used? (4 points)**

_________________________________________________________________

**d) How does the sniffer avoid blocking the main thread? (4 points)**

_________________________________________________________________

**e) What would happen if `_process_packet()` takes a long time? (4 points)**

_________________________________________________________________

---

## FINAL EXAMINATION

### Part A: Multiple Choice (50 points, 2 points each)

**1. Which of the following is NOT a valid connection type in the Session Manager?**
- A) SSH
- B) Netmiko
- C) HTTP
- D) Raw Socket

**2. What is the difference between synchronous and asynchronous programming?**
- A) Sync is faster
- B) Async can handle multiple I/O operations concurrently
- C) Sync is more secure
- D) There is no difference

**3. What is the purpose of the `prn` parameter in `AsyncSniffer`?**
- A) To specify the interface
- B) To specify the callback function for each packet
- C) To specify the filter
- D) To specify the count

**4. What is the role of jitter in stealth reconnaissance?**
- A) To improve performance
- B) To avoid detection by randomizing timing
- C) To increase accuracy
- D) To reduce network usage

**5. Which of the following is a common vulnerability detected by DOM analysis?**
- A) Missing security headers
- B) Missing CSRF tokens
- C) Inline JavaScript with eval
- D) All of the above

**6. What is the purpose of the `sandboxed` field in a plugin manifest?**
- A) To indicate the plugin runs in isolation
- B) To indicate the plugin is secure
- C) To indicate the plugin is fast
- D) To indicate the plugin is tested

**7. What is the benefit of using `asyncio.gather()`?**
- A) Runs coroutines sequentially
- B) Runs coroutines concurrently
- C) Cancels all coroutines
- D) Handles errors

**8. What is the difference between TCP Connect and SYN scanning?**
- A) SYN scanning completes the handshake
- B) TCP Connect completes the handshake
- C) TCP Connect is stealthier
- D) There is no difference

**9. What is the purpose of the `R` flag in TCP packets?**
- A) Reset connection
- B) Finish connection
- C) Synchronize sequence
- D) Acknowledge data

**10. What is the Module Registry used for in the recon system?**
- A) Storing module instances
- B) Registering and discovering modules
- C) Running modules
- D) Configuring modules

**11. What is the purpose of log redaction?**
- A) To save disk space
- B) To prevent credential leakage
- C) To make logs faster
- D) To comply with style guides

**12. What is the role of the Event Loop Manager?**
- A) To manage threads
- B) To schedule and run async tasks
- C) To handle errors
- D) To manage memory

**13. Which of the following is a valid BPF filter?**
- A) `tcp port 80`
- B) `host 192.168.1.1`
- C) `not arp`
- D) All of the above

**14. What is the purpose of the `pre_run` hook in modules?**
- A) Setup before execution
- B) Cleanup after execution
- C) Error handling
- D) Performance optimization

**15. What is the benefit of using a headless browser?**
- A) Faster requests
- B) JavaScript rendering
- C) Lower memory usage
- D) Better security

**16. What is the purpose of the `infinite` flag in InjectionConfig?**
- A) To send packets indefinitely
- B) To stop after one packet
- C) To send in a loop
- D) To send with jitter

**17. Which of the following is a security best practice for passwords?**
- A) Store in plaintext
- B) Use bcrypt with salt
- C) Use MD5
- D) Use SHA1

**18. What is the purpose of the `export_results()` method?**
- A) To save results to disk
- B) To display results
- C) To analyze results
- D) To delete results

**19. What is the benefit of connection pooling?**
- A) Better performance
- B) Lower memory usage
- C) Faster connections
- D) All of the above

**20. What is the purpose of the `Rich` library in the CLI?**
- A) Beautiful output formatting
- B) HTTP requests
- C) Packet sniffing
- D) Configuration management

**21. What is the difference between obfuscation and encryption?**
- A) Obfuscation is stronger
- B) Encryption is reversible with a key
- C) Obfuscation is reversible
- D) There is no difference

**22. What is the purpose of the `on_unload()` method in plugins?**
- A) Cleanup when plugin is unloaded
- B) Setup when plugin is loaded
- C) Running plugin logic
- D) Error handling

**23. What is the role of the `semaphore` in async scanning?**
- A) To limit concurrency
- B) To handle errors
- C) To manage memory
- D) To log events

**24. Which of the following is NOT a stealth technique?**
- A) Jitter
- B) Rate limiting
- C) User-agent rotation
- D) Fast scanning

**25. What is the purpose of the `click` library?**
- A) Building CLI applications
- B) Building web applications
- C) Managing packages
- D) Testing code

### Part B: Fill in the Blanks (20 points, 2 points each)

**26. A `Future` is a placeholder for a ______ that will be available later.**

**27. The `AsyncSniffer` uses a background ______ for packet capture.**

**28. OS fingerprinting can identify the ______ system of a target.**

**29. The `requires` field in a plugin manifest defines ______**

**30. Base64 encoding is ______, not secure.**

**31. The `SecretManager` logs access to track who accessed each ______**

**32. The `CLI` uses a ______ pattern for command organization.**

**33. BeautifulSoup is used for parsing ______**

**34. The `_process_loop` method processes packets from the ______ queue.**

**35. Parameterized queries prevent ______ injection.**

### Part C: Short Answer (20 points, 5 points each)

**36. Explain the architecture of the PyHack Suite framework, including the purpose of each major component.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**37. Describe how you would implement a new reconnaissance module. Include the required methods and how to register it.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**38. Explain the security hardening techniques implemented in the framework and why they are important.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

**39. Compare and contrast Paramiko, Netmiko, and Scapy. Include use cases for each.**

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

### Part D: Practical Code (10 points)

**40. Write a complete implementation of a packet sniffer that:**

- Uses AsyncSniffer for non-blocking capture
- Filters for TCP packets on port 80
- Processes packets asynchronously
- Implements backpressure to prevent memory exhaustion
- Provides statistics on captured packets

```python
# Your code here (10 points)

```

---

## ANSWER KEY: PART 0 QUIZZES

### Quiz 0.1: Course Fundamentals

**Multiple Choice:**
1. B
2. C
3. B
4. B
5. C

**True/False:**
6. False
7. True
8. False (Scapy is for packet manipulation)
9. False (Docker is optional)
10. True

**Short Answer:**
11. Four key features: (Any 4)
   - Unified connection management
   - High-speed packet sniffing
   - Stealth reconnaissance tools
   - Plugin-based architecture
   - Security hardening
   - Professional CLI
   - Code obfuscation

12. The Pyramid of Understanding shows the progression from foundational infrastructure automation (Part 1) through high-speed sniffing (Part 2), stealth reconnaissance (Part 3), and finally production hardening (Part 4).

13. Library Table:
   - Paramiko: SSH automation
   - Netmiko: Multi-vendor device automation
   - Scapy: Packet manipulation and analysis

### Quiz 0.2: Environment Setup

**Multiple Choice:**
1. B
2. B
3. B
4. B
5. A

**Fill in the Blanks:**
6. pip
7. editable
8. import
9. venv
10. package

**Matching:**
1. C
2. A
3. B
4. D
5. E

---

## ANSWER KEY: PART 1 QUIZZES

### Quiz 1.1: Configuration Management

**Multiple Choice:**
1. B
2. B
3. C
4. B
5. B

**Fill in the Blanks:**
6. .env
7. value
8. .env
9. Singleton
10. None

**Code Analysis:**
11. This defines a NetworkConfig dataclass with a scapy_interface field that defaults to "eth0".

12. This validation ensures the buffer size is at least the MTU (1500 bytes) to prevent packet truncation.

**Short Answer:**
13. Three benefits:
    - Keeps secrets out of source code
    - Allows different configurations per environment
    - Easy to change without code changes

### Quiz 1.2: Logging Systems

**Multiple Choice:**
1. B
2. B
3. B
4. B
5. B

**Fill in the Blanks:**
6. DEBUG, INFO, WARNING, ERROR, CRITICAL
7. RedactingFilter
8. 10485760, 5
9. exception
10. JSON

**Code Analysis:**
11. This filter redacts sensitive data from log messages using regex patterns.

12. This creates a log formatter with timestamp, logger name, level, and message.

**Short Answer:**
13. Three best practices:
    - Never log passwords/sensitive data
    - Use appropriate log levels
    - Rotate logs to prevent disk filling

### Quiz 1.3: Session Management

**Multiple Choice:**
1. B
2. C
3. B
4. B
5. C

**True/False:**
6. True
7. False
8. True
9. True
10. False

**Fill in the Blanks:**
11. Singleton
12. username
13. 10
14. context
15. ConnectionStatus

**Short Answer:**
16. Session lifecycle:
    - CREATE: Generate session ID
    - CONNECT: Establish connection with authentication
    - EXECUTE: Run commands/operations
    - CLOSE: Clean up and return to pool

### Quiz 1.4: Paramiko Fundamentals

**Multiple Choice:**
1. B
2. B
3. B
4. B
5. A

**Fill in the Blanks:**
6. host keys
7. stderr
8. file
9. interactive
10. echo

**Code Analysis:**
11. Missing the set_missing_host_key_policy() call before connect.

12. This opens an SFTP session and uploads a file to the remote server.

**Short Answer:**
13. Three authentication methods:
    - Password authentication
    - Private key authentication
    - SSH agent authentication

### Quiz 1.5: Netmiko Fundamentals

**Multiple Choice:**
1. B
2. D
3. B
4. B
5. D

**True/False:**
6. False
7. True
8. True
9. False
10. True

**Fill in the Blanks:**
11. Paramiko
12. Netmiko
13. device_type
14. prompt, command
15. configuration

**Short Answer:**
16. Paramiko is for low-level SSH automation (custom commands, file transfers), while Netmiko builds on Paramiko to provide high-level, device-specific automation for network devices (Cisco, Juniper, etc.).

### Quiz 1.6: Scapy Fundamentals

**Multiple Choice:**
1. B
2. B
3. A
4. A
5. B

**Fill in the Blanks:**
6. /
7. response
8. .pcap
9. fields
10. ip_range

**Code Analysis:**
11. Builds a TCP SYN packet to 192.168.1.1 port 80.

12. Sniffs 10 TCP packets on port 80 without storing them in memory.

**Short Answer:**
13. Four supported protocols:
    - IP
    - TCP
    - UDP
    - ICMP
    (Also: ARP, DNS, HTTP, Ethernet)

### Quiz 1.7: Protocol Abstraction

**Multiple Choice:**
1. B
2. B
3. A
4. B
5. B

**Fill in the Blanks:**
6. NetworkInterface
7. dictionary
8. lifecycle
9. type
10. Strategy

**Short Answer:**
11. Benefits of protocol abstraction:
    - Single API for all protocols
    - Easy protocol switching
    - Consistent error handling
    - Reduced code duplication
    - Easier testing and maintenance

---

## ANSWER KEY: PART 2 QUIZZES

### Quiz 2.1: Event Loop & Async Basics

**Multiple Choice:**
1. B
2. A
3. B
4. A
5. B

**True/False:**
6. False
7. True
8. True
9. False (asyncio.sleep is non-blocking)
10. True

**Fill in the Blanks:**
11. coroutine
12. safe
13. shutdown
14. I/O
15. result

### Quiz 2.2: Async Packet Sniffing

**Multiple Choice:**
1. B
2. B
3. B
4. D
5. B

**Fill in the Blanks:**
6. background
7. memory
8. queue
9. event
10. processing

**Code Analysis:**
11. This puts a packet into the queue or drops it if the queue is full, implementing backpressure to prevent memory exhaustion.

### Quiz 2.3: Queue Management

**Multiple Choice:**
1. B
2. A
3. B
4. A
5. C

**Fill in the Blanks:**
6. circular
7. priority
8. flow
9. processing
10. total_dropped

**Short Answer:**
11. FIFO queue processes items in order of arrival (first-in-first-out), while priority queue processes items based on priority (higher priority first, regardless of arrival order).

### Quiz 2.4: Packet Injection

**Multiple Choice:**
1. A
2. B
3. B
4. A
5. A

**Fill in the Blanks:**
6. count
7. AsyncPacket
8. randomization
9. IP
10. spoofed

---

## ANSWER KEY: PART 3 QUIZZES

### Quiz 3.1: Async Scanning

**Multiple Choice:**
1. C
2. B
3. C
4. D
5. B

**Fill in the Blanks:**
6. semaphore
7. default
8. port
9. patterns
10. requests

### Quiz 3.2: Brute Forcing

**Multiple Choice:**
1. A
2. A
3. A
4. B
5. D

**Fill in the Blanks:**
6. base64
7. values
8. account
9. detection
10. passwords

### Quiz 3.3: DOM Analysis

**Multiple Choice:**
1. A
2. B
3. A
4. D
5. A

**Fill in the Blanks:**
6. chromium
7. simple
8. scripts
9. HSTS
10. maximum

### Quiz 3.4: Modular Recon

**Multiple Choice:**
1. A
2. A
3. C
4. B
5. A

**Fill in the Blanks:**
6. registry
7. dependencies
8. dictionary
9. JSON
10. Strategy

---

## ANSWER KEY: PART 4 QUIZZES

### Quiz 4.1: Plugin Architecture

**Multiple Choice:**
1. C
2. B
3. B
4. A
5. A

**Fill in the Blanks:**
6. PluginState
7. loaded
8. loaded
9. dynamic
10. conflicts

### Quiz 4.2: Code Obfuscation

**Multiple Choice:**
1. B
2. B
3. B
4. A
5. B

**Fill in the Blanks:**
6. stream
7. reversible
8. obfuscation
9. signature
10. evasion

### Quiz 4.3: Security Hardening

**Multiple Choice:**
1. A
2. A
3. A
4. A
5. B

**Fill in the Blanks:**
6. SQL
7. processes
8. validating
9. environment
10. access

### Quiz 4.4: Production CLI

**Multiple Choice:**
1. A
2. A
3. A
4. A
5. B

**Fill in the Blanks:**
6. group
7. argument, option
8. Panel
9. formatted
10. command

---

## ANSWER KEY: MIDTERM EXAMINATION

### Part A: Multiple Choice

1. B
2. B
3. B
4. A
5. B
6. B
7. B
8. B
9. B
10. D
11. C
12. B
13. A
14. B
15. B
16. B
17. B
18. A
19. A
20. D

### Part B: Fill in the Blanks

21. .env
22. Paramiko
23. /
24. background
25. background
26. port
27. HTML
28. registry
29. loaded
30. environment

### Part C: Short Answer

**31. Difference between Paramiko, Netmiko, and Scapy:**

- **Paramiko**: Low-level SSH automation. Use for custom SSH operations, file transfers, interactive sessions.
- **Netmiko**: Multi-vendor device automation built on Paramiko. Use for automating network devices (Cisco, Juniper, etc.).
- **Scapy**: Packet manipulation and analysis. Use for crafting custom packets, sniffing, and protocol testing.

**32. Async packet sniffing architecture:**

1. Sniffer runs in background thread capturing packets
2. Packets are placed in async queue
3. Event loop processes packets from queue
4. Backpressure prevents memory exhaustion
5. Async processing allows other tasks to run concurrently

**33. Plugin lifecycle:**

- UNLOADED: Not yet loaded
- LOADING: Being loaded
- LOADED: Loaded but not initialized
- INITIALIZING: Being initialized
- INITIALIZED: Ready to run
- RUNNING: Active
- STOPPED: Finished
- ERROR: Failed state

Importance for security: Ensures proper cleanup, prevents resource leaks, allows isolation of failures.

**34. Three security hardening techniques:**

1. **Input validation**: Prevents injection attacks, path traversal
2. **Sandboxing**: Isolates untrusted code with resource limits
3. **Secret management**: Keeps secrets out of code using environment variables

### Part D: Code Analysis

**35. a) The packet queue buffers packets between the sniffing thread and the async processing loop, allowing decoupling of capture and processing.**

**35. b) When the queue is full, packets are dropped (backpressure) to prevent memory exhaustion.**

**35. c) `store=False` prevents Scapy from storing all packets in memory, reducing memory usage.**

**35. d) The sniffer runs in a background thread while the async loop processes packets from the queue.**

**35. e) If `_process_packet()` takes a long time, the queue will fill up and packets will be dropped (backpressure).**

---

## ANSWER KEY: FINAL EXAMINATION

### Part A: Multiple Choice

1. C
2. B
3. B
4. B
5. D
6. A
7. B
8. B
9. A
10. B
11. B
12. B
13. D
14. A
15. B
16. A
17. B
18. A
19. D
20. A
21. B
22. A
23. A
24. D
25. A

### Part B: Fill in the Blanks

26. result
27. thread
28. operating
29. dependencies
30. reversible
31. secret
32. command
33. HTML
34. packet
35. SQL

### Part C: Short Answer

**36. PyHack Suite Architecture:**

- **Core**: Configuration management, session management, event loop
- **Network**: Protocol implementations (Paramiko, Netmiko, Scapy)
- **Recon**: Scanning, brute forcing, DOM analysis
- **Modules**: Plugin architecture for extensibility
- **Utils**: Obfuscation, logging, validation, sandboxing
- **CLI**: Production command-line interface

**37. New Recon Module Implementation:**

1. Inherit from ReconModule base class
2. Implement get_metadata() with name, description, version
3. Implement run() with target and parameters
4. Use pre_run/post_run hooks for setup/cleanup
5. Register with ModuleRegistry
6. Export results in a consistent format

**38. Security Hardening Techniques:**

1. Input validation (injection prevention)
2. Sandboxing (isolated execution)
3. Secret management (environment variables)
4. Secure logging (redaction)
5. Parameterized queries (SQL injection prevention)

Importance: Protects the framework itself from being used as an attack vector.

**39. Comparison:**

- **Paramiko**: Low-level SSH, custom automation, file transfers
- **Netmiko**: High-level device automation, multi-vendor support
- **Scapy**: Packet manipulation, sniffing, protocol testing

Use cases:
- Paramiko: Custom SSH tools, interactive sessions
- Netmiko: Network device configuration, backup
- Scapy: Protocol fuzzing, security assessment

### Part D: Practical Code

**40. Packet Sniffer Implementation:**

```python
class PacketSniffer:
    def __init__(self, interface=None):
        self.interface = interface or "eth0"
        self.packet_queue = asyncio.Queue(maxsize=1000)
        self.sniffer = None
        self._running = False
        self.stats = {'captured': 0, 'dropped': 0}
    
    async def start(self):
        self._running = True
        
        def packet_handler(packet):
            try:
                self.packet_queue.put_nowait(packet)
                self.stats['captured'] += 1
            except asyncio.QueueFull:
                self.stats['dropped'] += 1
        
        self.sniffer = AsyncSniffer(
            iface=self.interface,
            filter="tcp port 80",
            prn=packet_handler,
            store=False
        )
        self.sniffer.start()
        await self._process_loop()
    
    async def _process_loop(self):
        while self._running:
            packet = await self.packet_queue.get()
            await self._process_packet(packet)
    
    async def _process_packet(self, packet):
        print(f"Packet: {packet.summary()}")
    
    async def stop(self):
        self._running = False
        if self.sniffer:
            self.sniffer.stop()
```

---

## PRACTICAL EXAM: PACKET ANALYSIS

### Instructions

You are given a PCAP file containing network traffic. Analyze the file and answer the following questions.

### Questions

**1. What is the total number of packets in the capture?** (5 points)

_________________________________________________________________

**2. Identify the top 5 source IPs.** (10 points)

_________________________________________________________________

**3. Identify the top 5 destination IPs.** (10 points)

**4. What protocols are present in the capture?** (10 points)

_________________________________________________________________

**5. Are there any HTTP requests? If so, what are the URLs?** (15 points)

_________________________________________________________________

**6. Are there any DNS queries? If so, what are the domains?** (15 points)

_________________________________________________________________

**7. Is there any suspicious activity? Explain.** (15 points)

_________________________________________________________________

**8. Provide the code used for the analysis.** (20 points)

---

## PRACTICAL EXAM: RECONNAISSANCE TOOL

### Instructions

Build a reconnaissance tool that combines multiple modules from the PyHack Suite framework.

### Requirements (100 points total)

**1. Functionality (30 points)**
- [ ] Port scanning (10 points)
- [ ] Service detection (10 points)
- [ ] HTTP analysis (10 points)

**2. Architecture (20 points)**
- [ ] Modular design (10 points)
- [ ] Proper error handling (10 points)

**3. Output (20 points)**
- [ ] Clear formatting (10 points)
- [ ] JSON export (10 points)

**4. Security (15 points)**
- [ ] Input validation (5 points)
- [ ] Rate limiting (5 points)
- [ ] Stealth features (5 points)

**5. Documentation (15 points)**
- [ ] Code comments (5 points)
- [ ] Usage guide (5 points)
- [ ] Sample output (5 points)

### Grading Rubric

| Criteria | Excellent (5) | Good (4) | Satisfactory (3) | Needs Improvement (2) | Unsatisfactory (1) |
|----------|---------------|----------|------------------|----------------------|-------------------|
| Functionality | All features work | Most features work | Basic features work | Some features work | Features don't work |
| Code Quality | Clean, documented | Good structure | Acceptable | Inconsistent | Poor structure |
| Architecture | Excellent design | Good patterns | Basic patterns | Limited patterns | Poor design |
| Security | All best practices | Most practices | Basic security | Some issues | Major issues |
| Documentation | Complete, clear | Good documentation | Basic docs | Limited docs | No docs |

---

```
[COMPLETED: Quiz and Test Bank Generation]
```

## Assessment Suite Statistics

| Component | Questions | Points |
|-----------|-----------|--------|
| Part 0 Quizzes | 20 | 100 |
| Part 1 Quizzes | 60 | 300 |
| Part 2 Quizzes | 60 | 300 |
| Part 3 Quizzes | 60 | 300 |
| Part 4 Quizzes | 60 | 300 |
| Midterm Exam | 35 | 100 |
| Final Exam | 40 | 100 |
| Practical Exams | 2 | 200 |
| **Total** | **337** | **1500** |

---

**[END OF QUIZ AND TEST BANK]**
