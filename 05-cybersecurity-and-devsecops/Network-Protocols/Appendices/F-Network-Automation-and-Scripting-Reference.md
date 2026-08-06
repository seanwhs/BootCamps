# Appendix F: Network Automation and Scripting Reference

## Complete Automation Framework for Network Engineers

---

## Overview

This appendix provides a comprehensive reference for automating network tasks, configuration management, monitoring, and operations. It includes complete scripts, templates, and frameworks for common network automation scenarios.

**Purpose**: Enable network engineers and DevOps professionals to automate repetitive tasks, manage network devices programmatically, and build self-service network infrastructure.

**Organization**: Organized by automation domains, from simple scripting to complete orchestration frameworks.

---

## Table of Contents

1. [Python Network Automation Fundamentals](#1-python-network-automation-fundamentals)
2. [Device Configuration Management](#2-device-configuration-management)
3. [Network Monitoring and Alerting](#3-network-monitoring-and-alerting)
4. [DNS Automation](#4-dns-automation)
5. [DHCP Automation](#5-dhcp-automation)
6. [Firewall Management Automation](#6-firewall-management-automation)
7. [Load Balancer Automation](#7-load-balancer-automation)
8. [Network Discovery and Inventory](#8-network-discovery-and-inventory)
9. [Network Testing and Validation](#9-network-testing-and-validation)
10. [Infrastructure as Code for Networking](#10-infrastructure-as-code-for-networking)

---

## 1. Python Network Automation Fundamentals

### Environment Setup

```bash
# Create Python virtual environment
python3 -m venv network-automation
source network-automation/bin/activate

# Install essential packages
pip install netmiko                # SSH management
pip install napalm                 # Multi-vendor abstraction
pip install paramiko               # SSH client
pip install pyyaml                 # YAML configuration
pip install jinja2                 # Template rendering
pip install python-dotenv          # Environment variables
pip install requests               # HTTP/REST API
pip install netaddr                # IP address manipulation
pip install scapy                  # Packet manipulation
pip install ping3                  # ICMP ping
pip install python-nmap            # Network scanning
pip install docker                 # Container management
pip install boto3                  # AWS SDK
pip install azure-mgmt-network     # Azure SDK
pip install google-cloud-network   # GCP SDK
```

### Network Connection Utility

```python
#!/usr/bin/env python3
"""
network_connection.py - Universal network device connection utility
"""

import os
import json
import yaml
import logging
from typing import Dict, Optional, List
from netmiko import ConnectHandler
from netmiko.ssh_exception import NetMikoTimeoutException, NetMikoAuthenticationException
import paramiko

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

class NetworkDeviceConnection:
    """
    Universal connection manager for network devices
    Supports multiple vendors and connection methods
    """
    
    def __init__(self, config_file: str = 'devices.yaml'):
        """Initialize with device configuration"""
        self.devices = self.load_config(config_file)
        self.connections = {}
    
    def load_config(self, config_file: str) -> Dict:
        """Load device configuration from YAML file"""
        try:
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
                logger.info(f"Loaded configuration for {len(config.get('devices', []))} devices")
                return config
        except FileNotFoundError:
            logger.error(f"Configuration file {config_file} not found")
            return {}
        except yaml.YAMLError as e:
            logger.error(f"Error parsing YAML: {e}")
            return {}
    
    def connect(self, device_name: str) -> Optional[ConnectHandler]:
        """Connect to a network device using Netmiko"""
        if device_name not in self.devices:
            logger.error(f"Device '{device_name}' not found in configuration")
            return None
        
        device_config = self.devices[device_name]
        
        # Use environment variables for credentials
        if 'username' in device_config:
            device_config['username'] = os.environ.get('NETWORK_USERNAME', device_config.get('username'))
        if 'password' in device_config:
            device_config['password'] = os.environ.get('NETWORK_PASSWORD', device_config.get('password'))
        
        try:
            logger.info(f"Connecting to {device_name} ({device_config.get('host')})...")
            connection = ConnectHandler(**device_config)
            
            # Send initial command to verify connection
            output = connection.send_command('show version' if 'cisco' in device_config.get('device_type', '') else '')
            logger.info(f"Connected to {device_name} successfully")
            
            self.connections[device_name] = connection
            return connection
            
        except NetMikoTimeoutException:
            logger.error(f"Connection timeout to {device_name}")
            return None
        except NetMikoAuthenticationException:
            logger.error(f"Authentication failed for {device_name}")
            return None
        except Exception as e:
            logger.error(f"Error connecting to {device_name}: {e}")
            return None
    
    def execute_command(self, device_name: str, command: str) -> Optional[str]:
        """Execute a command on a device"""
        if device_name not in self.connections:
            logger.error(f"Device '{device_name}' not connected")
            return None
        
        try:
            result = self.connections[device_name].send_command(command)
            logger.debug(f"Command '{command}' executed on {device_name}")
            return result
        except Exception as e:
            logger.error(f"Error executing command on {device_name}: {e}")
            return None
    
    def execute_commands(self, device_name: str, commands: List[str]) -> Dict[str, str]:
        """Execute multiple commands on a device"""
        results = {}
        
        if device_name not in self.connections:
            logger.error(f"Device '{device_name}' not connected")
            return results
        
        try:
            results = self.connections[device_name].send_commands(commands)
            logger.info(f"Executed {len(commands)} commands on {device_name}")
        except Exception as e:
            logger.error(f"Error executing commands on {device_name}: {e}")
        
        return results
    
    def disconnect(self, device_name: str):
        """Disconnect from a device"""
        if device_name in self.connections:
            try:
                self.connections[device_name].disconnect()
                del self.connections[device_name]
                logger.info(f"Disconnected from {device_name}")
            except:
                pass
    
    def disconnect_all(self):
        """Disconnect from all devices"""
        for device_name in list(self.connections.keys()):
            self.disconnect(device_name)
        logger.info("Disconnected from all devices")

class NetworkConnectionManager:
    """
    Context manager for network connections
    Ensures proper cleanup
    """
    
    def __init__(self, config_file: str = 'devices.yaml'):
        self.config_file = config_file
        self.manager = NetworkDeviceConnection(config_file)
    
    def __enter__(self):
        return self.manager
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.manager.disconnect_all()

def main():
    """Example usage"""
    # Sample device configuration file (devices.yaml):
    """
    devices:
      cisco-router:
        device_type: cisco_ios
        host: 192.168.1.1
        username: admin
        password: admin
        secret: enable
        
      juniper-switch:
        device_type: juniper_junos
        host: 192.168.1.2
        username: admin
        password: admin
      
      arista-switch:
        device_type: arista_eos
        host: 192.168.1.3
        username: admin
        password: admin
        secret: enable
    """
    
    # Use context manager
    with NetworkConnectionManager('devices.yaml') as manager:
        # Connect to a device
        device = manager.connect('cisco-router')
        
        if device:
            # Execute commands
            version = manager.execute_command('cisco-router', 'show version')
            if version:
                print(version)
            
            # Multiple commands
            commands = ['show ip interface brief', 'show running-config | include hostname']
            results = manager.execute_commands('cisco-router', commands)
            
            for cmd, output in results.items():
                print(f"Command: {cmd}")
                print(f"Output: {output[:200]}...\n")
    
    # Direct usage (requires manual cleanup)
    manager = NetworkDeviceConnection('devices.yaml')
    try:
        device = manager.connect('juniper-switch')
        if device:
            output = manager.execute_command('juniper-switch', 'show version')
            print(output)
    finally:
        manager.disconnect_all()

if __name__ == "__main__":
    main()
```

### Multi-Device Command Runner

```python
#!/usr/bin/env python3
"""
multi_device_runner.py - Execute commands across multiple devices in parallel
"""

import threading
import queue
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Dict, List, Tuple
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class MultiDeviceRunner:
    """
    Execute commands across multiple devices in parallel
    """
    
    def __init__(self, devices: List[Dict]):
        self.devices = devices
        self.results = {}
        self.lock = threading.Lock()
    
    def execute_command_on_device(self, device: Dict, command: str) -> Tuple[str, str, bool]:
        """Execute command on a single device"""
        try:
            from netmiko import ConnectHandler
            
            # Connect to device
            connection = ConnectHandler(**device)
            
            # Execute command
            output = connection.send_command(command)
            
            # Disconnect
            connection.disconnect()
            
            return (device.get('host', 'unknown'), output, True)
            
        except Exception as e:
            error_msg = f"Error: {str(e)}"
            logger.error(f"Error on {device.get('host')}: {error_msg}")
            return (device.get('host', 'unknown'), error_msg, False)
    
    def execute_commands_parallel(self, devices: List[Dict], commands: List[str]) -> Dict:
        """
        Execute commands on multiple devices in parallel
        """
        results = {device['host']: {} for device in devices}
        
        # Create a thread pool
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = []
            
            # Submit tasks for each device and command
            for device in devices:
                for command in commands:
                    future = executor.submit(self.execute_command_on_device, device, command)
                    futures.append((future, device['host'], command))
            
            # Collect results
            for future, host, command in futures:
                try:
                    result_host, output, success = future.result(timeout=60)
                    results[host][command] = {
                        'output': output,
                        'success': success
                    }
                except Exception as e:
                    logger.error(f"Timeout or error for {host} command '{command}': {e}")
                    results[host][command] = {
                        'output': f"Error: {str(e)}",
                        'success': False
                    }
        
        return results
    
    def execute_commands_sequential(self, devices: List[Dict], commands: List[str]) -> Dict:
        """
        Execute commands on multiple devices sequentially
        """
        results = {}
        
        for device in devices:
            host = device.get('host', 'unknown')
            results[host] = {}
            
            try:
                from netmiko import ConnectHandler
                connection = ConnectHandler(**device)
                
                for command in commands:
                    try:
                        output = connection.send_command(command)
                        results[host][command] = {
                            'output': output,
                            'success': True
                        }
                    except Exception as e:
                        results[host][command] = {
                            'output': f"Error: {str(e)}",
                            'success': False
                        }
                
                connection.disconnect()
                
            except Exception as e:
                logger.error(f"Error connecting to {host}: {e}")
                for command in commands:
                    results[host][command] = {
                        'output': f"Connection error: {str(e)}",
                        'success': False
                    }
        
        return results

def main():
    """Example usage"""
    # Sample devices
    devices = [
        {
            'device_type': 'cisco_ios',
            'host': '192.168.1.1',
            'username': 'admin',
            'password': 'password123',
        },
        {
            'device_type': 'cisco_ios',
            'host': '192.168.1.2',
            'username': 'admin',
            'password': 'password123',
        },
        {
            'device_type': 'cisco_ios',
            'host': '192.168.1.3',
            'username': 'admin',
            'password': 'password123',
        },
    ]
    
    commands = ['show version', 'show ip interface brief']
    
    # Sequential execution
    print("Sequential Execution:")
    runner = MultiDeviceRunner(devices)
    start = time.time()
    results_seq = runner.execute_commands_sequential(devices, commands)
    elapsed_seq = time.time() - start
    
    # Display results
    for host, results in results_seq.items():
        print(f"\n=== {host} ===")
        for cmd, data in results.items():
            status = "✓" if data['success'] else "✗"
            print(f"{status} {cmd}")
            print(data['output'][:200] + "...\n")
    
    # Parallel execution
    print(f"\nParallel Execution:")
    start = time.time()
    results_par = runner.execute_commands_parallel(devices, commands)
    elapsed_par = time.time() - start
    
    # Display results
    for host, results in results_par.items():
        print(f"\n=== {host} ===")
        for cmd, data in results.items():
            status = "✓" if data['success'] else "✗"
            print(f"{status} {cmd}")
            print(data['output'][:200] + "...\n")
    
    print(f"\nSequential: {elapsed_seq:.2f}s")
    print(f"Parallel: {elapsed_par:.2f}s")
    print(f"Speedup: {elapsed_seq/elapsed_par:.2f}x")

if __name__ == "__main__":
    main()
```

---

## 2. Device Configuration Management

### Configuration Backup System

```python
#!/usr/bin/env python3
"""
config_backup.py - Automated network device configuration backup
"""

import os
import yaml
import json
import datetime
import logging
import hashlib
from typing import Dict, List, Optional
from netmiko import ConnectHandler

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class ConfigBackupSystem:
    """
    Automated configuration backup for network devices
    """
    
    def __init__(self, config_file: str = 'devices.yaml', backup_dir: str = 'backups'):
        self.config_file = config_file
        self.backup_dir = backup_dir
        self.devices = self.load_devices()
        self.backup_history = {}
        
        # Create backup directory
        os.makedirs(backup_dir, exist_ok=True)
    
    def load_devices(self) -> List[Dict]:
        """Load device configuration from file"""
        try:
            with open(self.config_file, 'r') as f:
                config = yaml.safe_load(f)
                devices = config.get('devices', [])
                logger.info(f"Loaded {len(devices)} devices from {self.config_file}")
                return devices
        except Exception as e:
            logger.error(f"Error loading devices: {e}")
            return []
    
    def backup_device(self, device: Dict) -> Dict:
        """Backup configuration for a single device"""
        result = {
            'device': device.get('host'),
            'timestamp': datetime.datetime.now().isoformat(),
            'success': False,
            'file': None,
            'hash': None,
            'error': None
        }
        
        try:
            # Connect to device
            connection = ConnectHandler(**device)
            
            # Get running configuration
            if 'cisco' in device.get('device_type', ''):
                config = connection.send_command('show running-config')
            elif 'juniper' in device.get('device_type', ''):
                config = connection.send_command('show configuration')
            elif 'arista' in device.get('device_type', ''):
                config = connection.send_command('show running-config')
            else:
                config = connection.send_command('show running-config')
            
            connection.disconnect()
            
            # Save configuration
            timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"{device['host']}_{timestamp}.cfg"
            filepath = os.path.join(self.backup_dir, filename)
            
            with open(filepath, 'w') as f:
                f.write(config)
            
            # Calculate hash
            file_hash = hashlib.sha256(config.encode()).hexdigest()
            
            result['success'] = True
            result['file'] = filepath
            result['hash'] = file_hash
            
            logger.info(f"Backup created for {device['host']}: {filename}")
            
        except Exception as e:
            result['error'] = str(e)
            logger.error(f"Error backing up {device['host']}: {e}")
        
        return result
    
    def backup_all_devices(self) -> List[Dict]:
        """Backup all devices"""
        results = []
        
        for device in self.devices:
            result = self.backup_device(device)
            results.append(result)
        
        # Save backup history
        self.save_backup_history(results)
        
        return results
    
    def save_backup_history(self, results: List[Dict]):
        """Save backup history to JSON file"""
        history_file = os.path.join(self.backup_dir, 'backup_history.json')
        
        # Load existing history
        if os.path.exists(history_file):
            try:
                with open(history_file, 'r') as f:
                    history = json.load(f)
            except:
                history = []
        else:
            history = []
        
        # Add new results
        history.extend(results)
        
        # Limit history size
        if len(history) > 1000:
            history = history[-1000:]
        
        # Save history
        with open(history_file, 'w') as f:
            json.dump(history, f, indent=2)
    
    def compare_configs(self, device: str, n1: int = 1, n2: int = 2) -> Dict:
        """Compare two versions of a device configuration"""
        # Find the two most recent backups
        history_file = os.path.join(self.backup_dir, 'backup_history.json')
        
        if not os.path.exists(history_file):
            return {'error': 'No backup history found'}
        
        try:
            with open(history_file, 'r') as f:
                history = json.load(f)
        except:
            return {'error': 'Error reading backup history'}
        
        # Filter for the device
        device_history = [h for h in history if h.get('device') == device and h.get('success')]
        
        if len(device_history) < 2:
            return {'error': f'Less than 2 backups for {device}'}
        
        # Get the two most recent backups
        device_history = sorted(device_history, key=lambda x: x['timestamp'], reverse=True)
        backup1 = device_history[n1 - 1] if len(device_history) >= n1 else None
        backup2 = device_history[n2 - 1] if len(device_history) >= n2 else None
        
        if not backup1 or not backup2:
            return {'error': f'Backup not found for {device}'}
        
        # Read configurations
        try:
            with open(backup1['file'], 'r') as f:
                config1 = f.read()
            
            with open(backup2['file'], 'r') as f:
                config2 = f.read()
        except Exception as e:
            return {'error': f'Error reading configuration: {e}'}
        
        # Compare configurations
        lines1 = config1.splitlines()
        lines2 = config2.splitlines()
        
        differences = {
            'added': [],
            'removed': [],
            'modified': []
        }
        
        # Simple line-by-line comparison
        max_len = max(len(lines1), len(lines2))
        
        for i in range(max_len):
            line1 = lines1[i] if i < len(lines1) else None
            line2 = lines2[i] if i < len(lines2) else None
            
            if line1 is None and line2 is not None:
                differences['added'].append((i, line2))
            elif line1 is not None and line2 is None:
                differences['removed'].append((i, line1))
            elif line1 != line2:
                differences['modified'].append((i, line1, line2))
        
        return {
            'device': device,
            'backup1': backup1,
            'backup2': backup2,
            'differences': differences,
            'total_differences': len(differences['added']) + len(differences['removed']) + len(differences['modified'])
        }

class ConfigBackupScheduler:
    """Scheduled configuration backups"""
    
    def __init__(self, config_file: str = 'devices.yaml', backup_dir: str = 'backups'):
        self.backup_system = ConfigBackupSystem(config_file, backup_dir)
    
    def run_daily(self):
        """Run daily backup"""
        logger.info("Starting daily backup")
        results = self.backup_system.backup_all_devices()
        
        # Send notification
        success = sum(1 for r in results if r['success'])
        total = len(results)
        
        if success < total:
            logger.warning(f"Backup issues: {success}/{total} devices backed up")
        else:
            logger.info(f"Backup completed: {success}/{total} devices")
        
        return results
    
    def run_weekly(self):
        """Run weekly backup (full)"""
        logger.info("Starting weekly backup")
        # Additional cleanup and verification
        results = self.run_daily()
        
        # Clean old backups
        self.clean_backups(days=30)
        
        return results
    
    def clean_backups(self, days: int = 30):
        """Clean backups older than specified days"""
        cutoff = datetime.datetime.now() - datetime.timedelta(days=days)
        
        history_file = os.path.join(self.backup_system.backup_dir, 'backup_history.json')
        
        if not os.path.exists(history_file):
            return
        
        try:
            with open(history_file, 'r') as f:
                history = json.load(f)
        except:
            return
        
        # Filter history
        filtered_history = []
        for entry in history:
            timestamp = datetime.datetime.fromisoformat(entry['timestamp'])
            if timestamp > cutoff:
                filtered_history.append(entry)
        
        # Save filtered history
        with open(history_file, 'w') as f:
            json.dump(filtered_history, f, indent=2)
        
        logger.info(f"Cleaned backups older than {days} days")

def main():
    """Main entry point"""
    # Backup all devices
    backup_system = ConfigBackupSystem()
    results = backup_system.backup_all_devices()
    
    # Display results
    print("\nBackup Results:")
    print("=" * 60)
    
    for result in results:
        status = "✓" if result['success'] else "✗"
        print(f"{status} {result['device']:20} {result.get('file', 'ERROR')}")
        if not result['success']:
            print(f"  Error: {result.get('error', 'Unknown')}")
    
    # Compare configurations (example)
    print("\nConfiguration Comparison:")
    print("=" * 60)
    
    # Compare the last two backups for first device
    if results and results[0]['success']:
        device = results[0]['device']
        comparison = backup_system.compare_configs(device, 1, 2)
        
        if 'error' not in comparison:
            print(f"Device: {comparison['device']}")
            print(f"Total differences: {comparison['total_differences']}")
            
            print(f"\nAdded lines: {len(comparison['differences']['added'])}")
            for line_num, line in comparison['differences']['added'][:5]:
                print(f"  + Line {line_num}: {line[:80]}")
            
            print(f"\nRemoved lines: {len(comparison['differences']['removed'])}")
            for line_num, line in comparison['differences']['removed'][:5]:
                print(f"  - Line {line_num}: {line[:80]}")
            
            print(f"\nModified lines: {len(comparison['differences']['modified'])}")
            for line_num, old, new in comparison['differences']['modified'][:5]:
                print(f"  * Line {line_num}:")
                print(f"    - {old[:80]}")
                print(f"    + {new[:80]}")

if __name__ == "__main__":
    main()
```

### Configuration Deployment System

```python
#!/usr/bin/env python3
"""
config_deploy.py - Automated configuration deployment system
"""

import os
import yaml
import logging
import jinja2
from typing import Dict, List, Optional
from netmiko import ConnectHandler
import time
import json

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class ConfigDeploymentSystem:
    """
    Automated configuration deployment with templating
    """
    
    def __init__(self, template_dir: str = 'templates', config_dir: str = 'configs'):
        self.template_dir = template_dir
        self.config_dir = config_dir
        self.jinja_env = jinja2.Environment(
            loader=jinja2.FileSystemLoader(template_dir),
            trim_blocks=True,
            lstrip_blocks=True
        )
    
    def generate_config(self, template_name: str, variables: Dict) -> str:
        """Generate configuration from template"""
        try:
            template = self.jinja_env.get_template(template_name)
            config = template.render(**variables)
            return config
        except Exception as e:
            logger.error(f"Error generating config from {template_name}: {e}")
            return None
    
    def deploy_config(self, device: Dict, config: str, commit: bool = True) -> Dict:
        """Deploy configuration to device"""
        result = {
            'device': device.get('host'),
            'success': False,
            'error': None,
            'timestamp': time.time()
        }
        
        try:
            # Connect to device
            connection = ConnectHandler(**device)
            
            # Enter config mode
            connection.config_mode()
            
            # Send configuration
            output = connection.send_config_set(config.splitlines())
            
            if commit:
                # Save configuration
                if 'cisco' in device.get('device_type', ''):
                    connection.save_config()
                
                result['output'] = output
                result['success'] = True
                logger.info(f"Configuration deployed to {device['host']}")
            else:
                # Rollback
                connection.send_command('rollback')
                result['output'] = "Configuration not committed (dry run)"
                result['success'] = True
                logger.info(f"Configuration dry-run on {device['host']}")
            
            connection.disconnect()
            
        except Exception as e:
            result['error'] = str(e)
            logger.error(f"Error deploying config to {device['host']}: {e}")
        
        return result
    
    def deploy_configs(self, devices: List[Dict], template_name: str, variables: Dict, commit: bool = True) -> List[Dict]:
        """Deploy configuration to multiple devices"""
        results = []
        
        for device in devices:
            # Generate configuration
            config = self.generate_config(template_name, variables)
            
            if config is None:
                results.append({
                    'device': device.get('host'),
                    'success': False,
                    'error': 'Failed to generate configuration'
                })
                continue
            
            # Save generated config
            filename = f"{device['host']}_{template_name.replace('.j2', '')}.cfg"
            filepath = os.path.join(self.config_dir, filename)
            
            with open(filepath, 'w') as f:
                f.write(config)
            
            # Deploy configuration
            result = self.deploy_config(device, config, commit)
            results.append(result)
        
        return results

def main():
    """Example usage"""
    # Create templates directory
    os.makedirs('templates', exist_ok=True)
    os.makedirs('configs', exist_ok=True)
    
    # Sample template (templates/cisco_interface.j2)
    """
    interface {{ interface_name }}
      description {{ description }}
      ip address {{ ip_address }} {{ subnet_mask }}
      no shutdown
    """
    
    # Sample variables
    variables = {
        'interface_name': 'GigabitEthernet0/1',
        'description': 'Connection to Core Switch',
        'ip_address': '10.0.0.1',
        'subnet_mask': '255.255.255.0'
    }
    
    # Sample devices
    devices = [
        {
            'device_type': 'cisco_ios',
            'host': '192.168.1.1',
            'username': 'admin',
            'password': 'password123',
            'secret': 'enable'
        }
    ]
    
    deployment = ConfigDeploymentSystem()
    results = deployment.deploy_configs(devices, 'cisco_interface.j2', variables, commit=False)
    
    print("\nDeployment Results:")
    print("=" * 60)
    for result in results:
        status = "✓" if result['success'] else "✗"
        print(f"{status} {result['device']:20} {'COMMITTED' if result.get('success') else 'ERROR'}")
        if 'error' in result:
            print(f"  Error: {result['error']}")

if __name__ == "__main__":
    main()
```

---

## 3. Network Monitoring and Alerting

### Network Health Monitor

```python
#!/usr/bin/env python3
"""
network_health_monitor.py - Continuous network health monitoring
"""

import time
import threading
import json
import datetime
from typing import Dict, List, Optional
import socket
import ping3
import logging
from dataclasses import dataclass, field

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class DeviceHealth:
    """Health status for a device"""
    ip: str
    hostname: str
    status: str = 'unknown'  # up, down, degraded
    last_ping: float = 0.0
    packet_loss: float = 0.0
    min_latency: float = 0.0
    avg_latency: float = 0.0
    max_latency: float = 0.0
    last_check: float = 0.0
    history: List[Dict] = field(default_factory=list)

class NetworkHealthMonitor:
    """
    Continuous network health monitoring with alerting
    """
    
    def __init__(self, config_file: str = 'monitoring_config.json'):
        self.config = self.load_config(config_file)
        self.devices: Dict[str, DeviceHealth] = {}
        self.running = False
        self.alert_callbacks = []
    
    def load_config(self, config_file: str) -> Dict:
        """Load monitoring configuration"""
        default_config = {
            'devices': [
                {'ip': '8.8.8.8', 'hostname': 'google-dns'},
                {'ip': '1.1.1.1', 'hostname': 'cloudflare-dns'},
                {'ip': '192.168.1.1', 'hostname': 'gateway'},
            ],
            'monitoring': {
                'interval': 60,  # seconds
                'ping_count': 5,
                'ping_timeout': 2.0,
                'packet_loss_threshold': 10,  # percent
                'latency_threshold': 200,  # ms
            },
            'alerting': {
                'enabled': True,
                'cooldown': 300,  # seconds between alerts
            }
        }
        
        try:
            with open(config_file, 'r') as f:
                config = json.load(f)
                # Merge with defaults
                for key in default_config:
                    if key not in config:
                        config[key] = default_config[key]
                return config
        except:
            return default_config
    
    def initialize_devices(self):
        """Initialize device tracking"""
        for device in self.config['devices']:
            self.devices[device['ip']] = DeviceHealth(
                ip=device['ip'],
                hostname=device.get('hostname', device['ip'])
            )
    
    def ping_device(self, ip: str, count: int = 5) -> Dict:
        """Ping a device and return statistics"""
        results = []
        
        for i in range(count):
            try:
                latency = ping3.ping(ip, timeout=self.config['monitoring']['ping_timeout'])
                if latency is not None:
                    results.append(latency)
            except:
                pass
        
        if results:
            return {
                'success': True,
                'avg': sum(results) / len(results),
                'min': min(results),
                'max': max(results),
                'packet_loss': ((count - len(results)) / count) * 100
            }
        else:
            return {
                'success': False,
                'avg': 0,
                'min': 0,
                'max': 0,
                'packet_loss': 100
            }
    
    def check_device(self, ip: str) -> DeviceHealth:
        """Check health of a single device"""
        health = self.devices.get(ip)
        
        if not health:
            return None
        
        # Perform ping
        stats = self.ping_device(ip, self.config['monitoring']['ping_count'])
        
        # Update health
        health.last_check = time.time()
        
        if stats['success']:
            health.status = 'up'
            health.packet_loss = stats['packet_loss']
            health.avg_latency = stats['avg']
            health.min_latency = stats['min']
            health.max_latency = stats['max']
            
            # Check for degradation
            if stats['packet_loss'] > self.config['monitoring']['packet_loss_threshold']:
                health.status = 'degraded'
            elif stats['avg'] > self.config['monitoring']['latency_threshold']:
                health.status = 'degraded'
        else:
            health.status = 'down'
            health.packet_loss = 100
        
        # Update history
        health.history.append({
            'timestamp': datetime.datetime.now().isoformat(),
            'status': health.status,
            'avg_latency': health.avg_latency,
            'packet_loss': health.packet_loss
        })
        
        # Keep last 100 entries
        if len(health.history) > 100:
            health.history = health.history[-100:]
        
        return health
    
    def check_all_devices(self):
        """Check all devices"""
        results = {}
        
        for ip in self.devices:
            health = self.check_device(ip)
            if health:
                results[ip] = health
        
        # Check for alerts
        self.check_alerts(results)
        
        return results
    
    def check_alerts(self, results: Dict):
        """Check for alerts based on device status"""
        for ip, health in results.items():
            if health.status in ['down', 'degraded']:
                self.trigger_alert(health)
    
    def trigger_alert(self, health: DeviceHealth):
        """Trigger an alert for a device"""
        message = f"ALERT: {health.hostname} ({health.ip}) is {health.status}"
        
        if health.status == 'down':
            message += f" - Last check: no response"
        else:
            message += f" - Packet loss: {health.packet_loss:.1f}%, Latency: {health.avg_latency:.1f}ms"
        
        logger.warning(message)
        
        # Call registered alert callbacks
        for callback in self.alert_callbacks:
            try:
                callback(health)
            except Exception as e:
                logger.error(f"Error in alert callback: {e}")
    
    def register_alert_callback(self, callback):
        """Register an alert callback function"""
        self.alert_callbacks.append(callback)
    
    def start_monitoring(self):
        """Start the monitoring loop"""
        self.running = True
        self.initialize_devices()
        
        logger.info("Starting network health monitor")
        logger.info(f"Monitoring {len(self.devices)} devices at {self.config['monitoring']['interval']}s intervals")
        
        while self.running:
            start_time = time.time()
            
            # Check all devices
            results = self.check_all_devices()
            
            # Log status
            status_counts = {}
            for ip, health in results.items():
                status_counts[health.status] = status_counts.get(health.status, 0) + 1
            
            logger.debug(f"Status: {status_counts}")
            
            # Wait for next interval
            elapsed = time.time() - start_time
            wait_time = max(0, self.config['monitoring']['interval'] - elapsed)
            time.sleep(wait_time)
    
    def stop_monitoring(self):
        """Stop the monitoring loop"""
        self.running = False
        logger.info("Stopping network health monitor")
    
    def get_health_report(self) -> Dict:
        """Get current health report"""
        report = {
            'timestamp': datetime.datetime.now().isoformat(),
            'devices': {}
        }
        
        for ip, health in self.devices.items():
            report['devices'][ip] = {
                'hostname': health.hostname,
                'status': health.status,
                'avg_latency': health.avg_latency,
                'packet_loss': health.packet_loss,
                'last_check': health.last_check
            }
        
        return report
    
    def get_statistics(self) -> Dict:
        """Get statistics for all devices"""
        stats = {
            'total': len(self.devices),
            'up': 0,
            'down': 0,
            'degraded': 0,
            'unknown': 0
        }
        
        for health in self.devices.values():
            stats[health.status] = stats.get(health.status, 0) + 1
        
        return stats

class AlertManager:
    """Alert management and notification"""
    
    def __init__(self):
        self.alerts = []
    
    def email_alert(self, health: DeviceHealth):
        """Send alert via email (placeholder)"""
        print(f"EMAIL ALERT: {health.hostname} is {health.status}")
    
    def sms_alert(self, health: DeviceHealth):
        """Send alert via SMS (placeholder)"""
        print(f"SMS ALERT: {health.hostname} is {health.status}")
    
    def slack_alert(self, health: DeviceHealth):
        """Send alert via Slack (placeholder)"""
        print(f"SLACK ALERT: {health.hostname} is {health.status}")

def main():
    """Main entry point"""
    # Create monitor
    monitor = NetworkHealthMonitor()
    
    # Create alert manager
    alert_manager = AlertManager()
    
    # Register alert callbacks
    monitor.register_alert_callback(alert_manager.email_alert)
    monitor.register_alert_callback(alert_manager.slack_alert)
    
    try:
        # Start monitoring in a separate thread
        monitor_thread = threading.Thread(target=monitor.start_monitoring, daemon=True)
        monitor_thread.start()
        
        # Let it run for a while
        time.sleep(30)
        
        # Get health report
        report = monitor.get_health_report()
        print("\nHealth Report:")
        print(json.dumps(report, indent=2))
        
        # Get statistics
        stats = monitor.get_statistics()
        print("\nStatistics:")
        print(json.dumps(stats, indent=2))
        
    finally:
        monitor.stop_monitoring()

if __name__ == "__main__":
    main()
```

---

## 4. DNS Automation

### DNS Management System

```python
#!/usr/bin/env python3
"""
dns_manager.py - Automated DNS record management
"""

import json
import yaml
import time
import socket
import dns.resolver
import dns.update
import dns.query
import dns.tsigkeyring
from typing import Dict, List, Optional
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class DNSManager:
    """
    Automated DNS record management with DNSSEC support
    """
    
    def __init__(self, config_file: str = 'dns_config.yaml'):
        self.config = self.load_config(config_file)
        self.resolver = dns.resolver.Resolver()
        self.resolver.nameservers = self.config.get('nameservers', ['8.8.8.8'])
    
    def load_config(self, config_file: str) -> Dict:
        """Load DNS configuration"""
        default_config = {
            'nameservers': ['8.8.8.8', '1.1.1.1'],
            'zone': 'example.com',
            'ttl': 300,
            'tsig': {
                'key': None,
                'algorithm': 'hmac-md5',
                'secret': None
            }
        }
        
        try:
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
                for key in default_config:
                    if key not in config:
                        config[key] = default_config[key]
                return config
        except:
            return default_config
    
    def resolve(self, domain: str, record_type: str = 'A') -> List[str]:
        """Resolve a domain"""
        try:
            answers = self.resolver.resolve(domain, record_type)
            return [str(answer) for answer in answers]
        except Exception as e:
            logger.error(f"Error resolving {domain}: {e}")
            return []
    
    def resolve_mx(self, domain: str) -> List[Dict]:
        """Resolve MX records"""
        try:
            answers = self.resolver.resolve(domain, 'MX')
            return [{'exchange': str(answer.exchange), 'preference': answer.preference} 
                    for answer in answers]
        except Exception as e:
            logger.error(f"Error resolving MX for {domain}: {e}")
            return []
    
    def resolve_txt(self, domain: str) -> List[str]:
        """Resolve TXT records"""
        try:
            answers = self.resolver.resolve(domain, 'TXT')
            return [str(answer) for answer in answers]
        except Exception as e:
            logger.error(f"Error resolving TXT for {domain}: {e}")
            return []
    
    def update_record(self, domain: str, record_type: str, value: str, ttl: int = None) -> bool:
        """Update a DNS record using TSIG"""
        if not self.config['tsig']['key']:
            logger.warning("TSIG not configured, cannot update records")
            return False
        
        try:
            # Create update
            update = dns.update.Update(self.config['zone'])
            
            # Remove existing record
            update.delete(domain, record_type)
            
            # Add new record
            update.add(domain, ttl or self.config['ttl'], record_type, value)
            
            # Send update with TSIG
            keyring = dns.tsigkeyring.from_text({
                self.config['tsig']['key']: self.config['tsig']['secret']
            })
            
            response = dns.query.tcp(update, self.config['nameservers'][0], keyring=keyring)
            
            if response.rcode() == 0:
                logger.info(f"Updated {domain} {record_type} -> {value}")
                return True
            else:
                logger.error(f"Update failed for {domain}: {response.rcode()}")
                return False
                
        except Exception as e:
            logger.error(f"Error updating {domain}: {e}")
            return False
    
    def add_record(self, domain: str, record_type: str, value: str, ttl: int = None) -> bool:
        """Add a new DNS record"""
        return self.update_record(domain, record_type, value, ttl)
    
    def delete_record(self, domain: str, record_type: str) -> bool:
        """Delete a DNS record"""
        if not self.config['tsig']['key']:
            logger.warning("TSIG not configured, cannot delete records")
            return False
        
        try:
            # Create update
            update = dns.update.Update(self.config['zone'])
            
            # Delete record
            update.delete(domain, record_type)
            
            # Send update with TSIG
            keyring = dns.tsigkeyring.from_text({
                self.config['tsig']['key']: self.config['tsig']['secret']
            })
            
            response = dns.query.tcp(update, self.config['nameservers'][0], keyring=keyring)
            
            if response.rcode() == 0:
                logger.info(f"Deleted {domain} {record_type}")
                return True
            else:
                logger.error(f"Delete failed for {domain}: {response.rcode()}")
                return False
                
        except Exception as e:
            logger.error(f"Error deleting {domain}: {e}")
            return False
    
    def batch_update(self, records: List[Dict]) -> List[Dict]:
        """Batch update multiple DNS records"""
        results = []
        
        for record in records:
            result = {
                'domain': record['domain'],
                'type': record['type'],
                'value': record.get('value'),
                'success': False,
                'error': None
            }
            
            if 'value' in record:
                success = self.update_record(
                    record['domain'],
                    record['type'],
                    record['value'],
                    record.get('ttl')
                )
                result['success'] = success
            else:
                success = self.delete_record(record['domain'], record['type'])
                result['success'] = success
            
            results.append(result)
        
        return results
    
    def reverse_lookup(self, ip: str) -> List[str]:
        """Perform reverse DNS lookup"""
        try:
            # Create reverse domain
            parts = ip.split('.')
            reverse_domain = '.'.join(reversed(parts)) + '.in-addr.arpa'
            
            answers = self.resolver.resolve(reverse_domain, 'PTR')
            return [str(answer) for answer in answers]
        except Exception as e:
            logger.error(f"Error reverse resolving {ip}: {e}")
            return []

def main():
    """Example usage"""
    manager = DNSManager()
    
    # Resolve domain
    print("Resolving google.com:")
    ips = manager.resolve('google.com')
    for ip in ips:
        print(f"  {ip}")
    
    # Resolve MX
    print("\nMX records for gmail.com:")
    mx_records = manager.resolve_mx('gmail.com')
    for mx in mx_records:
        print(f"  {mx['preference']}: {mx['exchange']}")
    
    # Reverse lookup
    print("\nReverse lookup for 8.8.8.8:")
    names = manager.reverse_lookup('8.8.8.8')
    for name in names:
        print(f"  {name}")
    
    # Update record (requires TSIG configuration)
    # manager.add_record('www.example.com', 'A', '192.168.1.100')
    # manager.delete_record('www.example.com', 'A')
    
    # Batch update
    updates = [
        {'domain': 'test1.example.com', 'type': 'A', 'value': '192.168.1.1'},
        {'domain': 'test2.example.com', 'type': 'A', 'value': '192.168.1.2'},
        {'domain': 'test3.example.com', 'type': 'A'},  # Delete
    ]
    
    # results = manager.batch_update(updates)

if __name__ == "__main__":
    main()
```

---

## 5. DHCP Automation

### DHCP Management System

```python
#!/usr/bin/env python3
"""
dhcp_manager.py - Automated DHCP management
"""

import json
import yaml
import subprocess
import tempfile
import os
from typing import Dict, List, Optional
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class DHCPManager:
    """
    Automated DHCP management (ISC DHCPD)
    """
    
    def __init__(self, config_file: str = 'dhcp_config.yaml'):
        self.config = self.load_config(config_file)
        self.dhcp_conf_path = self.config.get('dhcp_conf_path', '/etc/dhcp/dhcpd.conf')
    
    def load_config(self, config_file: str) -> Dict:
        """Load DHCP configuration"""
        default_config = {
            'dhcp_conf_path': '/etc/dhcp/dhcpd.conf',
            'lease_file': '/var/lib/dhcp/dhcpd.leases',
            'subnets': [],
            'hosts': []
        }
        
        try:
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
                for key in default_config:
                    if key not in config:
                        config[key] = default_config[key]
                return config
        except:
            return default_config
    
    def parse_leases(self) -> List[Dict]:
        """Parse DHCP lease file"""
        leases = []
        
        if not os.path.exists(self.config['lease_file']):
            return leases
        
        try:
            with open(self.config['lease_file'], 'r') as f:
                content = f.read()
            
            # Parse lease blocks
            current_lease = {}
            
            for line in content.split('\n'):
                line = line.strip()
                
                if line.startswith('lease'):
                    current_lease = {}
                    parts = line.split()
                    if len(parts) >= 2:
                        current_lease['ip'] = parts[1]
                
                elif line.startswith('starts'):
                    parts = line.split()
                    if len(parts) >= 3:
                        date_parts = parts[2].split('/')
                        if len(date_parts) == 3:
                            current_lease['start'] = f"{date_parts[0]}-{date_parts[1]}-{date_parts[2]}"
                
                elif line.startswith('ends'):
                    parts = line.split()
                    if len(parts) >= 3:
                        date_parts = parts[2].split('/')
                        if len(date_parts) == 3:
                            current_lease['end'] = f"{date_parts[0]}-{date_parts[1]}-{date_parts[2]}"
                
                elif line.startswith('hardware'):
                    parts = line.split()
                    if len(parts) >= 3:
                        current_lease['mac'] = parts[2]
                
                elif line.startswith('client-hostname'):
                    parts = line.split()
                    if len(parts) >= 2:
                        current_lease['hostname'] = parts[1]
                
                elif line == '}':
                    if current_lease:
                        leases.append(current_lease)
                    current_lease = {}
            
        except Exception as e:
            logger.error(f"Error parsing leases: {e}")
        
        return leases
    
    def add_host(self, mac: str, ip: str, hostname: str = None) -> bool:
        """Add a DHCP host reservation"""
        host_entry = {
            'mac': mac,
            'ip': ip,
            'hostname': hostname or '',
            'added': datetime.now().isoformat()
        }
        
        self.config['hosts'].append(host_entry)
        
        return self.update_config()
    
    def remove_host(self, mac: str) -> bool:
        """Remove a DHCP host reservation"""
        self.config['hosts'] = [h for h in self.config['hosts'] if h['mac'] != mac]
        return self.update_config()
    
    def update_config(self) -> bool:
        """Update DHCP configuration file"""
        try:
            # Generate configuration
            config = self.generate_config()
            
            # Write to temporary file
            with tempfile.NamedTemporaryFile(mode='w', delete=False) as temp:
                temp.write(config)
                temp_name = temp.name
            
            # Backup existing config
            if os.path.exists(self.dhcp_conf_path):
                backup_path = f"{self.dhcp_conf_path}.backup"
                os.rename(self.dhcp_conf_path, backup_path)
            
            # Copy new config
            os.rename(temp_name, self.dhcp_conf_path)
            
            # Verify configuration
            result = subprocess.run(
                ['dhcpd', '-t', '-cf', self.dhcp_conf_path],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                logger.info("DHCP configuration updated successfully")
                # Restart DHCP service
                subprocess.run(['systemctl', 'restart', 'isc-dhcp-server'])
                return True
            else:
                # Restore backup
                if os.path.exists(f"{self.dhcp_conf_path}.backup"):
                    os.rename(f"{self.dhcp_conf_path}.backup", self.dhcp_conf_path)
                logger.error(f"DHCP configuration error: {result.stderr}")
                return False
            
        except Exception as e:
            logger.error(f"Error updating DHCP config: {e}")
            return False
    
    def generate_config(self) -> str:
        """Generate DHCP configuration from data"""
        config = [
            "# DHCP Configuration - Auto-generated",
            f"# Generated: {datetime.now().isoformat()}",
            "",
            "ddns-update-style none;",
            "default-lease-time 86400;",
            "max-lease-time 172800;",
            "",
            "subnet 192.168.1.0 netmask 255.255.255.0 {",
            "    range 192.168.1.100 192.168.1.200;",
            "    option routers 192.168.1.1;",
            "    option domain-name-servers 8.8.8.8, 1.1.1.1;",
            "    option domain-name 'example.com';",
            "}"
        ]
        
        # Add host reservations
        if self.config['hosts']:
            config.append("")
            config.append("# Host Reservations")
            
            for host in self.config['hosts']:
                config.append(f"host {host.get('hostname', host['mac'].replace(':', ''))} {{")
                config.append(f"    hardware ethernet {host['mac']};")
                config.append(f"    fixed-address {host['ip']};")
                if host.get('hostname'):
                    config.append(f"    option host-name '{host['hostname']}';")
                config.append("}")
        
        return '\n'.join(config)
    
    def get_leases(self) -> List[Dict]:
        """Get current DHCP leases"""
        return self.parse_leases()
    
    def get_hosts(self) -> List[Dict]:
        """Get configured hosts"""
        return self.config['hosts']
    
    def get_statistics(self) -> Dict:
        """Get DHCP statistics"""
        leases = self.parse_leases()
        hosts = self.config['hosts']
        
        stats = {
            'total_leases': len(leases),
            'active_leases': sum(1 for l in leases if 'end' in l),
            'expired_leases': sum(1 for l in leases if 'end' not in l),
            'reserved_hosts': len(hosts)
        }
        
        # Count leases by subnet
        subnet_counts = {}
        for lease in leases:
            ip = lease.get('ip', '')
            if ip:
                parts = ip.split('.')
                if len(parts) >= 4:
                    subnet = f"{parts[0]}.{parts[1]}.{parts[2]}"
                    subnet_counts[subnet] = subnet_counts.get(subnet, 0) + 1
        
        stats['subnets'] = subnet_counts
        
        return stats

def main():
    """Example usage"""
    manager = DHCPManager()
    
    # Add host reservation
    # manager.add_host('00:11:22:33:44:55', '192.168.1.100', 'test-host')
    
    # Get current leases
    leases = manager.get_leases()
    print(f"\nActive leases: {len(leases)}")
    for lease in leases[:5]:
        print(f"  {lease.get('ip')} -> {lease.get('mac')} ({lease.get('hostname')})")
    
    # Get statistics
    stats = manager.get_statistics()
    print("\nDHCP Statistics:")
    print(json.dumps(stats, indent=2))
    
    # Get reserved hosts
    hosts = manager.get_hosts()
    print(f"\nReserved hosts: {len(hosts)}")
    for host in hosts:
        print(f"  {host['mac']} -> {host['ip']} ({host.get('hostname')})")

if __name__ == "__main__":
    main()
```

---

## 6. Firewall Management Automation

### Firewall Rule Management

```python
#!/usr/bin/env python3
"""
firewall_manager.py - Automated firewall rule management
"""

import json
import yaml
import subprocess
import re
from typing import Dict, List, Optional
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class FirewallManager:
    """
    Automated firewall rule management (iptables)
    """
    
    def __init__(self, config_file: str = 'firewall_config.yaml'):
        self.config = self.load_config(config_file)
        self.rules = []
    
    def load_config(self, config_file: str) -> Dict:
        """Load firewall configuration"""
        default_config = {
            'policy': 'DROP',
            'chains': ['INPUT', 'OUTPUT', 'FORWARD'],
            'rules': []
        }
        
        try:
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
                for key in default_config:
                    if key not in config:
                        config[key] = default_config[key]
                return config
        except:
            return default_config
    
    def add_rule(self, chain: str, rule: Dict) -> bool:
        """Add a firewall rule"""
        rule['chain'] = chain
        self.config['rules'].append(rule)
        return self.apply_rules()
    
    def remove_rule(self, rule_id: int) -> bool:
        """Remove a firewall rule"""
        self.config['rules'] = [r for i, r in enumerate(self.config['rules']) if i != rule_id]
        return self.apply_rules()
    
    def apply_rules(self) -> bool:
        """Apply firewall rules"""
        try:
            # Reset firewall
            self._reset_firewall()
            
            # Set default policy
            for chain in self.config['chains']:
                self._set_policy(chain, self.config['policy'])
            
            # Apply rules
            for rule in self.config['rules']:
                self._apply_rule(rule)
            
            return True
            
        except Exception as e:
            logger.error(f"Error applying firewall rules: {e}")
            return False
    
    def _reset_firewall(self):
        """Reset firewall to default state"""
        # Flush all rules
        subprocess.run(['iptables', '-F'], check=True)
        subprocess.run(['iptables', '-t', 'nat', '-F'], check=True)
        subprocess.run(['iptables', '-t', 'mangle', '-F'], check=True)
        
        # Delete user-defined chains
        subprocess.run(['iptables', '-X'], check=True)
    
    def _set_policy(self, chain: str, policy: str):
        """Set chain policy"""
        subprocess.run(['iptables', '-P', chain, policy], check=True)
    
    def _apply_rule(self, rule: Dict):
        """Apply a single firewall rule"""
        cmd = ['iptables']
        
        chain = rule.get('chain', 'INPUT')
        cmd.extend(['-A', chain])
        
        # Protocol
        if 'protocol' in rule:
            cmd.extend(['-p', rule['protocol']])
        
        # Source
        if 'source' in rule:
            cmd.extend(['-s', rule['source']])
        
        # Destination
        if 'destination' in rule:
            cmd.extend(['-d', rule['destination']])
        
        # Port
        if 'port' in rule:
            if rule.get('protocol') in ['tcp', 'udp']:
                cmd.extend(['--dport', str(rule['port'])])
        
        # Action
        if 'action' in rule:
            cmd.extend(['-j', rule['action']])
        
        # Log
        if rule.get('log', False):
            # Add logging rule before action
            log_cmd = cmd.copy()
            log_cmd.extend(['-j', 'LOG', '--log-prefix', f"FW: {chain}: "])
            subprocess.run(log_cmd, check=True)
        
        subprocess.run(cmd, check=True)
        logger.info(f"Applied rule: {' '.join(cmd)}")
    
    def get_rules(self) -> List[Dict]:
        """Get current firewall rules"""
        result = subprocess.run(
            ['iptables', '-S'],
            capture_output=True,
            text=True,
            check=True
        )
        
        rules = []
        for line in result.stdout.split('\n'):
            if line and line.startswith('-A'):
                rules.append(self._parse_rule(line))
        
        return rules
    
    def _parse_rule(self, rule_line: str) -> Dict:
        """Parse a rule line"""
        # Remove '-A'
        parts = rule_line.split(' ')[1:]
        
        rule = {'chain': parts[0] if parts else 'INPUT'}
        
        for i, part in enumerate(parts[1:], 1):
            if part == '-p':
                rule['protocol'] = parts[i + 1] if i + 1 < len(parts) else None
            elif part == '-s':
                rule['source'] = parts[i + 1] if i + 1 < len(parts) else None
            elif part == '-d':
                rule['destination'] = parts[i + 1] if i + 1 < len(parts) else None
            elif part == '--dport':
                rule['port'] = int(parts[i + 1]) if i + 1 < len(parts) else None
            elif part == '-j':
                rule['action'] = parts[i + 1] if i + 1 < len(parts) else None
        
        return rule
    
    def add_blacklist(self, ip: str) -> bool:
        """Add an IP to the blacklist"""
        return self.add_rule('INPUT', {
            'source': ip,
            'action': 'DROP',
            'log': True
        })
    
    def add_whitelist(self, ip: str, port: int = None) -> bool:
        """Add an IP to the whitelist"""
        rule = {
            'source': ip,
            'action': 'ACCEPT'
        }
        
        if port:
            rule['protocol'] = 'tcp'
            rule['port'] = port
        
        return self.add_rule('INPUT', rule)
    
    def get_statistics(self) -> Dict:
        """Get firewall statistics"""
        result = subprocess.run(
            ['iptables', '-L', '-n', '-v'],
            capture_output=True,
            text=True,
            check=True
        )
        
        stats = {
            'packets': 0,
            'bytes': 0,
            'chains': {}
        }
        
        current_chain = None
        
        for line in result.stdout.split('\n'):
            if not line.strip():
                continue
            
            # Chain header
            if line.startswith('Chain'):
                parts = line.split()
                if len(parts) >= 2:
                    current_chain = parts[1]
                    stats['chains'][current_chain] = {
                        'packets': 0,
                        'bytes': 0
                    }
            elif current_chain and line and not line.startswith('pkts'):
                parts = line.split()
                if len(parts) >= 2:
                    try:
                        packets = int(parts[0])
                        bytes_val = int(parts[1])
                        stats['packets'] += packets
                        stats['bytes'] += bytes_val
                        stats['chains'][current_chain]['packets'] += packets
                        stats['chains'][current_chain]['bytes'] += bytes_val
                    except:
                        pass
        
        return stats

def main():
    """Example usage"""
    manager = FirewallManager()
    
    # Add rules
    manager.add_whitelist('192.168.1.100', 22)
    manager.add_blacklist('203.0.113.50')
    
    # Get current rules
    rules = manager.get_rules()
    print("\nCurrent Rules:")
    for rule in rules:
        print(json.dumps(rule, indent=2))
    
    # Get statistics
    stats = manager.get_statistics()
    print("\nFirewall Statistics:")
    print(json.dumps(stats, indent=2))

if __name__ == "__main__":
    main()
```

---

## 7. Load Balancer Automation

### Load Balancer Configuration Manager

```python
#!/usr/bin/env python3
"""
load_balancer_manager.py - Automated load balancer configuration
"""

import json
import yaml
import requests
import time
from typing import Dict, List, Optional
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class LoadBalancerManager:
    """
    Automated load balancer configuration (HAProxy/Nginx)
    """
    
    def __init__(self, config_file: str = 'lb_config.yaml'):
        self.config = self.load_config(config_file)
        self.config_file = config_file
    
    def load_config(self, config_file: str) -> Dict:
        """Load load balancer configuration"""
        default_config = {
            'type': 'haproxy',  # haproxy, nginx
            'frontend': {
                'port': 80,
                'bind': '0.0.0.0',
                'mode': 'http'
            },
            'backends': [],
            'ssl': {
                'enabled': False,
                'cert_path': None,
                'key_path': None
            },
            'health_check': {
                'enabled': True,
                'path': '/health',
                'interval': 10,
                'timeout': 5
            }
        }
        
        try:
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
                for key in default_config:
                    if key not in config:
                        config[key] = default_config[key]
                return config
        except:
            return default_config
    
    def add_backend(self, name: str, host: str, port: int, weight: int = 1) -> bool:
        """Add a backend server"""
        backend = {
            'name': name,
            'host': host,
            'port': port,
            'weight': weight,
            'status': 'unknown'
        }
        
        self.config['backends'].append(backend)
        return self.apply_config()
    
    def remove_backend(self, name: str) -> bool:
        """Remove a backend server"""
        self.config['backends'] = [b for b in self.config['backends'] if b['name'] != name]
        return self.apply_config()
    
    def apply_config(self) -> bool:
        """Apply load balancer configuration"""
        # Generate configuration based on type
        if self.config['type'] == 'haproxy':
            config = self._generate_haproxy_config()
        elif self.config['type'] == 'nginx':
            config = self._generate_nginx_config()
        else:
            logger.error(f"Unknown load balancer type: {self.config['type']}")
            return False
        
        # Write configuration
        try:
            with open('/etc/haproxy/haproxy.cfg', 'w') as f:
                f.write(config)
            
            # Reload service
            import subprocess
            subprocess.run(['systemctl', 'reload', 'haproxy'], check=True)
            logger.info("Load balancer configuration applied")
            return True
            
        except Exception as e:
            logger.error(f"Error applying load balancer config: {e}")
            return False
    
    def _generate_haproxy_config(self) -> str:
        """Generate HAProxy configuration"""
        config = [
            "global",
            "    daemon",
            "    log /dev/log local0",
            "    maxconn 4096",
            "",
            "defaults",
            "    log global",
            "    mode http",
            "    option httplog",
            "    option dontlognull",
            f"    timeout connect {self.config.get('health_check', {}).get('timeout', 5)}s",
            "    timeout client 50s",
            "    timeout server 50s",
            "",
            f"frontend http-in",
            f"    bind {self.config['frontend']['bind']}:{self.config['frontend']['port']}",
            f"    default_backend servers",
            "",
            f"backend servers"
        ]
        
        # Add health check
        if self.config.get('health_check', {}).get('enabled'):
            config.append("    option httpchk GET /health")
        
        # Add backends
        for backend in self.config['backends']:
            config.append(
                f"    server {backend['name']} {backend['host']}:{backend['port']} "
                f"weight {backend['weight']} check inter {self.config.get('health_check', {}).get('interval', 10)}s"
            )
        
        return '\n'.join(config)
    
    def _generate_nginx_config(self) -> str:
        """Generate Nginx configuration"""
        config = [
            "upstream backend {"
        ]
        
        for backend in self.config['backends']:
            config.append(f"    server {backend['host']}:{backend['port']} weight={backend['weight']};")
        
        config.extend([
            "}",
            "",
            "server {",
            f"    listen {self.config['frontend']['port']};",
            f"    server_name _;",
            ""
        ])
        
        # SSL configuration
        if self.config.get('ssl', {}).get('enabled'):
            config.extend([
                f"    ssl_certificate {self.config['ssl']['cert_path']};",
                f"    ssl_certificate_key {self.config['ssl']['key_path']};",
                "    ssl_protocols TLSv1.2 TLSv1.3;",
                "    ssl_ciphers HIGH:!aNULL:!MD5;",
                ""
            ])
        
        # Health check
        if self.config.get('health_check', {}).get('enabled'):
            config.extend([
                "    location /health {",
                "        access_log off;",
                "        return 200 'healthy';",
                "        add_header Content-Type text/plain;",
                "    }",
                ""
            ])
        
        config.extend([
            "    location / {",
            "        proxy_pass http://backend;",
            "        proxy_set_header Host $host;",
            "        proxy_set_header X-Real-IP $remote_addr;",
            "        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;",
            "        proxy_set_header X-Forwarded-Proto $scheme;",
            "    }",
            "}"
        ])
        
        return '\n'.join(config)
    
    def get_statistics(self) -> Dict:
        """Get load balancer statistics"""
        stats = {
            'backends': self.config['backends'],
            'total_backends': len(self.config['backends']),
            'active_backends': sum(1 for b in self.config['backends'] if b.get('status') == 'active'),
            'type': self.config['type'],
            'port': self.config['frontend']['port']
        }
        
        return stats
    
    def health_check(self) -> Dict:
        """Perform health check on all backends"""
        results = {}
        
        for backend in self.config['backends']:
            url = f"http://{backend['host']}:{backend['port']}/health"
            try:
                response = requests.get(url, timeout=5)
                if response.status_code == 200:
                    backend['status'] = 'active'
                    results[backend['name']] = 'healthy'
                else:
                    backend['status'] = 'error'
                    results[backend['name']] = f'error: {response.status_code}'
            except Exception as e:
                backend['status'] = 'down'
                results[backend['name']] = f'down: {str(e)}'
        
        return results

def main():
    """Example usage"""
    manager = LoadBalancerManager()
    
    # Add backends
    manager.add_backend('web1', '192.168.1.10', 80, 1)
    manager.add_backend('web2', '192.168.1.11', 80, 2)
    manager.add_backend('web3', '192.168.1.12', 80, 1)
    
    # Health check
    print("Health Check Results:")
    health = manager.health_check()
    for name, status in health.items():
        print(f"  {name}: {status}")
    
    # Get statistics
    stats = manager.get_statistics()
    print("\nLoad Balancer Statistics:")
    print(json.dumps(stats, indent=2))

if __name__ == "__main__":
    main()
```

---

## 8. Network Discovery and Inventory

### Network Discovery System

```python
#!/usr/bin/env python3
"""
network_discovery.py - Automated network discovery and inventory
"""

import socket
import ipaddress
import subprocess
import threading
import queue
from typing import List, Dict, Optional
import nmap
import logging
from concurrent.futures import ThreadPoolExecutor

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class NetworkDiscovery:
    """
    Automated network discovery and inventory
    """
    
    def __init__(self):
        self.nm = nmap.PortScanner()
        self.inventory = {
            'devices': [],
            'total_discovered': 0,
            'scan_time': None
        }
    
    def discover_hosts(self, network: str) -> List[Dict]:
        """Discover hosts in a network"""
        logger.info(f"Discovering hosts in {network}")
        
        # Ping scan
        self.nm.scan(hosts=network, arguments='-sn -PE -PA21,22,23,80,443,445 -T4')
        
        hosts = []
        for host in self.nm.all_hosts():
            if self.nm[host].state() == 'up':
                host_info = {
                    'ip': host,
                    'hostname': socket.gethostbyaddr(host)[0] if self._reverse_lookup(host) else None,
                    'mac': self.nm[host].get('addresses', {}).get('mac'),
                    'vendor': self.nm[host].get('vendor', {}).get(self.nm[host].get('addresses', {}).get('mac', ''), ''),
                    'status': 'up',
                    'ports': []
                }
                hosts.append(host_info)
                logger.info(f"Discovered: {host_info['ip']} ({host_info.get('hostname', 'unknown')})")
        
        self.inventory['devices'] = hosts
        self.inventory['total_discovered'] = len(hosts)
        
        return hosts
    
    def scan_ports(self, ip: str, ports: List[int] = None) -> List[Dict]:
        """Scan ports on a host"""
        if ports is None:
            ports = [21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 993, 995, 3306, 3389, 5432, 8080]
        
        port_str = ','.join(str(p) for p in ports)
        self.nm.scan(hosts=ip, arguments=f'-p {port_str} -sS -T4')
        
        host_ports = []
        
        if ip in self.nm.all_hosts():
            for proto in self.nm[ip].all_protocols():
                for port in self.nm[ip][proto].keys():
                    if self.nm[ip][proto][port]['state'] == 'open':
                        host_ports.append({
                            'port': port,
                            'protocol': proto,
                            'service': self.nm[ip][proto][port].get('name', 'unknown'),
                            'product': self.nm[ip][proto][port].get('product', ''),
                            'version': self.nm[ip][proto][port].get('version', ''),
                            'state': 'open'
                        })
        
        return host_ports
    
    def discover_services(self, ip: str) -> Dict:
        """Discover services on a host"""
        logger.info(f"Scanning services on {ip}")
        ports = self.scan_ports(ip)
        
        services = {}
        for port in ports:
            services[port['port']] = {
                'service': port['service'],
                'product': port['product'],
                'version': port['version']
            }
        
        return services
    
    def _reverse_lookup(self, ip: str) -> bool:
        """Check if reverse lookup is possible"""
        try:
            socket.gethostbyaddr(ip)
            return True
        except:
            return False
    
    def scan_network(self, network: str, scan_services: bool = False) -> Dict:
        """Scan network and optionally discover services"""
        # Discover hosts
        hosts = self.discover_hosts(network)
        
        # Optionally scan services
        if scan_services:
            for host in hosts:
                try:
                    host['services'] = self.discover_services(host['ip'])
                except Exception as e:
                    logger.error(f"Error scanning services on {host['ip']}: {e}")
        
        self.inventory['scan_time'] = time.time()
        return self.inventory
    
    def get_inventory(self) -> Dict:
        """Get current inventory"""
        return self.inventory
    
    def export_inventory(self, format: str = 'json') -> str:
        """Export inventory in specified format"""
        import json
        return json.dumps(self.inventory, indent=2)

class InventoryManager:
    """
    Inventory management and synchronization
    """
    
    def __init__(self, inventory_file: str = 'inventory.json'):
        self.inventory_file = inventory_file
        self.inventory = self.load_inventory()
    
    def load_inventory(self) -> Dict:
        """Load inventory from file"""
        try:
            import json
            with open(self.inventory_file, 'r') as f:
                return json.load(f)
        except:
            return {'devices': []}
    
    def save_inventory(self):
        """Save inventory to file"""
        import json
        with open(self.inventory_file, 'w') as f:
            json.dump(self.inventory, f, indent=2)
        logger.info(f"Inventory saved to {self.inventory_file}")
    
    def add_device(self, device: Dict):
        """Add device to inventory"""
        # Check if device already exists
        for i, existing in enumerate(self.inventory['devices']):
            if existing.get('ip') == device.get('ip'):
                self.inventory['devices'][i] = device
                self.save_inventory()
                return
        
        self.inventory['devices'].append(device)
        self.save_inventory()
    
    def remove_device(self, ip: str):
        """Remove device from inventory"""
        self.inventory['devices'] = [d for d in self.inventory['devices'] if d.get('ip') != ip]
        self.save_inventory()
    
    def get_device(self, ip: str) -> Optional[Dict]:
        """Get device by IP"""
        for device in self.inventory['devices']:
            if device.get('ip') == ip:
                return device
        return None
    
    def search_devices(self, query: str) -> List[Dict]:
        """Search devices in inventory"""
        results = []
        for device in self.inventory['devices']:
            for key, value in device.items():
                if query.lower() in str(value).lower():
                    results.append(device)
                    break
        return results

def main():
    """Example usage"""
    # Discover network
    discovery = NetworkDiscovery()
    
    # Scan network (without service scanning)
    network = '192.168.1.0/24'
    inventory = discovery.scan_network(network, scan_services=True)
    
    print(f"\nDiscovered {inventory['total_discovered']} hosts")
    
    # Display devices
    print("\nDevice Inventory:")
    print("=" * 60)
    
    for device in inventory['devices']:
        hostname = device.get('hostname', 'unknown')
        mac = device.get('mac', 'unknown')
        vendor = device.get('vendor', '')
        services = device.get('services', {})
        
        print(f"IP: {device['ip']}")
        print(f"  Hostname: {hostname}")
        print(f"  MAC: {mac} ({vendor})")
        
        if services:
            print("  Services:")
            for port, service in services.items():
                print(f"    {port}: {service['service']} {service['product']} {service['version']}")
        
        print()
    
    # Save inventory
    manager = InventoryManager()
    manager.inventory = inventory
    manager.save_inventory()

if __name__ == "__main__":
    import time
    main()
```

---

## 9. Network Testing and Validation

### Network Validation Framework

```python
#!/usr/bin/env python3
"""
network_validation.py - Automated network validation framework
"""

import socket
import ipaddress
import subprocess
import time
from typing import Dict, List, Optional
import logging
from dataclasses import dataclass, field

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class TestResult:
    """Result of a network test"""
    name: str
    passed: bool
    message: str
    details: Dict = field(default_factory=dict)
    timestamp: float = field(default_factory=time.time)

class NetworkValidation:
    """
    Automated network validation framework
    """
    
    def __init__(self):
        self.tests = []
        self.results = []
    
    def add_test(self, name: str, test_func):
        """Add a test to the validation suite"""
        self.tests.append({'name': name, 'func': test_func})
    
    def run_tests(self) -> List[TestResult]:
        """Run all tests"""
        self.results = []
        
        for test in self.tests:
            try:
                logger.info(f"Running test: {test['name']}")
                result = test['func']()
                if isinstance(result, TestResult):
                    self.results.append(result)
                else:
                    self.results.append(TestResult(
                        name=test['name'],
                        passed=bool(result),
                        message=str(result)
                    ))
            except Exception as e:
                self.results.append(TestResult(
                    name=test['name'],
                    passed=False,
                    message=f"Test error: {str(e)}"
                ))
        
        return self.results
    
    def get_summary(self) -> Dict:
        """Get test summary"""
        passed = sum(1 for r in self.results if r.passed)
        failed = len(self.results) - passed
        
        return {
            'total': len(self.results),
            'passed': passed,
            'failed': failed,
            'success_rate': (passed / len(self.results) * 100) if self.results else 0
        }
    
    def print_summary(self):
        """Print test summary"""
        summary = self.get_summary()
        
        print("\n" + "=" * 60)
        print("Network Validation Summary")
        print("=" * 60)
        print(f"Total Tests: {summary['total']}")
        print(f"Passed: {summary['passed']} ✓")
        print(f"Failed: {summary['failed']} ✗")
        print(f"Success Rate: {summary['success_rate']:.1f}%")
        print("=" * 60)
        
        if summary['failed'] > 0:
            print("\nFailed Tests:")
            for result in self.results:
                if not result.passed:
                    print(f"  ✗ {result.name}")
                    print(f"    {result.message}")

class NetworkChecks:
    """
    Common network check functions
    """
    
    @staticmethod
    def ping_check(host: str, count: int = 4, timeout: int = 5) -> TestResult:
        """Check if host is reachable via ping"""
        try:
            result = subprocess.run(
                ['ping', '-c', str(count), '-W', str(timeout), host],
                capture_output=True,
                text=True,
                timeout=timeout + 2
            )
            
            if result.returncode == 0:
                # Parse packet loss
                for line in result.stdout.split('\n'):
                    if 'packet loss' in line:
                        parts = line.split(',')
                        for part in parts:
                            if 'packet loss' in part:
                                loss = part.strip().split()[0]
                                if loss == '0%':
                                    return TestResult(
                                        name=f"Ping to {host}",
                                        passed=True,
                                        message=f"Host {host} is reachable"
                                    )
                                else:
                                    return TestResult(
                                        name=f"Ping to {host}",
                                        passed=False,
                                        message=f"Packet loss: {loss}"
                                    )
                
                return TestResult(
                    name=f"Ping to {host}",
                    passed=True,
                    message=f"Host {host} is reachable"
                )
            else:
                return TestResult(
                    name=f"Ping to {host}",
                    passed=False,
                    message=f"Host {host} is not reachable"
                )
                
        except Exception as e:
            return TestResult(
                name=f"Ping to {host}",
                passed=False,
                message=f"Ping error: {str(e)}"
            )
    
    @staticmethod
    def port_check(host: str, port: int, timeout: int = 5) -> TestResult:
        """Check if port is open"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((host, port))
            sock.close()
            
            if result == 0:
                return TestResult(
                    name=f"Port {port} on {host}",
                    passed=True,
                    message=f"Port {port} is open"
                )
            else:
                return TestResult(
                    name=f"Port {port} on {host}",
                    passed=False,
                    message=f"Port {port} is closed"
                )
                
        except Exception as e:
            return TestResult(
                name=f"Port {port} on {host}",
                passed=False,
                message=f"Port check error: {str(e)}"
            )
    
    @staticmethod
    def dns_check(domain: str, record_type: str = 'A') -> TestResult:
        """Check DNS resolution"""
        try:
            import dns.resolver
            resolver = dns.resolver.Resolver()
            answers = resolver.resolve(domain, record_type)
            
            return TestResult(
                name=f"DNS {domain} {record_type}",
                passed=True,
                message=f"Resolved to {[str(a) for a in answers]}"
            )
            
        except Exception as e:
            return TestResult(
                name=f"DNS {domain} {record_type}",
                passed=False,
                message=f"DNS resolution failed: {str(e)}"
            )
    
    @staticmethod
    def http_check(url: str, timeout: int = 10) -> TestResult:
        """Check HTTP endpoint"""
        try:
            import requests
            response = requests.get(url, timeout=timeout)
            
            if 200 <= response.status_code < 400:
                return TestResult(
                    name=f"HTTP {url}",
                    passed=True,
                    message=f"Status: {response.status_code}"
                )
            else:
                return TestResult(
                    name=f"HTTP {url}",
                    passed=False,
                    message=f"Status: {response.status_code}"
                )
                
        except Exception as e:
            return TestResult(
                name=f"HTTP {url}",
                passed=False,
                message=f"HTTP error: {str(e)}"
            )
    
    @staticmethod
    def traceroute_check(host: str, hops: int = 30) -> TestResult:
        """Check route to host"""
        try:
            result = subprocess.run(
                ['traceroute', '-n', '-m', str(hops), host],
                capture_output=True,
                text=True,
                timeout=60
            )
            
            lines = result.stdout.split('\n')
            response = []
            
            for line in lines:
                if line.strip():
                    response.append(line.strip())
            
            if len(response) > 1:
                return TestResult(
                    name=f"Traceroute to {host}",
                    passed=True,
                    message=f"Route found ({len(response)} hops)"
                )
            else:
                return TestResult(
                    name=f"Traceroute to {host}",
                    passed=False,
                    message="No route found"
                )
                
        except Exception as e:
            return TestResult(
                name=f"Traceroute to {host}",
                passed=False,
                message=f"Traceroute error: {str(e)}"
            )

def main():
    """Example usage"""
    # Create validation suite
    validator = NetworkValidation()
    
    # Add tests
    validator.add_test("Ping to Google", lambda: NetworkChecks.ping_check('8.8.8.8'))
    validator.add_test("Ping to Gateway", lambda: NetworkChecks.ping_check('192.168.1.1'))
    validator.add_test("DNS google.com", lambda: NetworkChecks.dns_check('google.com'))
    validator.add_test("DNS example.com", lambda: NetworkChecks.dns_check('example.com'))
    validator.add_test("HTTP to google.com", lambda: NetworkChecks.http_check('https://google.com'))
    validator.add_test("HTTP to example.com", lambda: NetworkChecks.http_check('https://example.com'))
    validator.add_test("Traceroute to google.com", lambda: NetworkChecks.traceroute_check('google.com'))
    
    # Run tests
    results = validator.run_tests()
    
    # Print summary
    validator.print_summary()
    
    # Show all results
    print("\nDetailed Results:")
    print("=" * 60)
    for result in results:
        status = "✓" if result.passed else "✗"
        print(f"{status} {result.name}")
        print(f"  {result.message}")
        print()

if __name__ == "__main__":
    main()
```

---

## 10. Infrastructure as Code for Networking

### Terraform Network Configuration

```python
#!/usr/bin/env python3
"""
terraform_network.py - Generate Terraform configurations for networks
"""

import json
import yaml
import os
from typing import Dict, List, Optional
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s')
logger = logging.getLogger(__name__)

class TerraformNetworkGenerator:
    """
    Generate Terraform configurations for network infrastructure
    """
    
    def __init__(self, config_file: str = 'network_terraform_config.yaml'):
        self.config = self.load_config(config_file)
        self.terraform_dir = self.config.get('terraform_dir', 'terraform')
        self.templates = {}
        
        # Create terraform directory
        os.makedirs(self.terraform_dir, exist_ok=True)
    
    def load_config(self, config_file: str) -> Dict:
        """Load terraform configuration"""
        default_config = {
            'provider': 'aws',
            'region': 'us-east-1',
            'environment': 'production',
            'vpc': {
                'cidr': '10.0.0.0/16',
                'enable_dns': True,
                'enable_dns_hostnames': True
            },
            'subnets': [
                {'name': 'public', 'cidr': '10.0.1.0/24', 'availability_zone': 'us-east-1a'},
                {'name': 'private', 'cidr': '10.0.2.0/24', 'availability_zone': 'us-east-1a'},
            ],
            'security_groups': [],
            'load_balancers': []
        }
        
        try:
            with open(config_file, 'r') as f:
                config = yaml.safe_load(f)
                for key in default_config:
                    if key not in config:
                        config[key] = default_config[key]
                return config
        except:
            return default_config
    
    def generate_provider(self) -> str:
        """Generate provider configuration"""
        provider_config = []
        
        if self.config['provider'] == 'aws':
            provider_config.extend([
                'provider "aws" {',
                f'  region = "{self.config["region"]}"',
                '}',
                ''
            ])
        elif self.config['provider'] == 'azure':
            provider_config.extend([
                'provider "azurerm" {',
                '  features {}',
                '}',
                ''
            ])
        elif self.config['provider'] == 'gcp':
            provider_config.extend([
                'provider "google" {',
                f'  project = "{self.config.get("gcp_project", "my-project")}"',
                f'  region = "{self.config["region"]}"',
                '}',
                ''
            ])
        
        return '\n'.join(provider_config)
    
    def generate_vpc(self) -> str:
        """Generate VPC configuration"""
        vpc_config = []
        
        if self.config['provider'] == 'aws':
            vpc_config.extend([
                'resource "aws_vpc" "main" {',
                f'  cidr_block = "{self.config["vpc"]["cidr"]}"',
                f'  enable_dns_support = {str(self.config["vpc"].get("enable_dns", True)).lower()}',
                f'  enable_dns_hostnames = {str(self.config["vpc"].get("enable_dns_hostnames", True)).lower()}',
                '',
                '  tags = {',
                f'    Name = "{self.config["environment"]}-vpc"',
                '    Environment = "' + self.config['environment'] + '"',
                '  }',
                '}',
                ''
            ])
            
            # Subnets
            for subnet in self.config['subnets']:
                vpc_config.extend([
                    f'resource "aws_subnet" "{subnet["name"]}" {',
                    f'  vpc_id = aws_vpc.main.id',
                    f'  cidr_block = "{subnet["cidr"]}"',
                    f'  availability_zone = "{subnet["availability_zone"]}"',
                    '',
                    '  tags = {',
                    f'    Name = "{self.config["environment"]}-{subnet["name"]}"',
                    f'    Environment = "{self.config["environment"]}"',
                    '  }',
                    '}',
                    ''
                ])
            
            # Internet gateway
            vpc_config.extend([
                'resource "aws_internet_gateway" "main" {',
                '  vpc_id = aws_vpc.main.id',
                '',
                '  tags = {',
                f'    Name = "{self.config["environment"]}-igw"',
                f'    Environment = "{self.config["environment"]}"',
                '  }',
                '}',
                ''
            ])
            
            # Route tables
            vpc_config.extend([
                'resource "aws_route_table" "public" {',
                '  vpc_id = aws_vpc.main.id',
                '',
                '  route {',
                '    cidr_block = "0.0.0.0/0"',
                '    gateway_id = aws_internet_gateway.main.id',
                '  }',
                '',
                '  tags = {',
                f'    Name = "{self.config["environment"]}-public"',
                f'    Environment = "{self.config["environment"]}"',
                '  }',
                '}',
                ''
            ])
        
        return '\n'.join(vpc_config)
    
    def generate_security_groups(self) -> str:
        """Generate security group configuration"""
        sg_config = []
        
        if self.config['provider'] == 'aws':
            for sg in self.config.get('security_groups', []):
                sg_config.extend([
                    f'resource "aws_security_group" "{sg["name"]}" {',
                    f'  vpc_id = aws_vpc.main.id',
                    f'  name = "{self.config["environment"]}-{sg["name"]}"',
                    f'  description = "{sg.get("description", sg["name"])}"',
                    ''
                ])
                
                for rule in sg.get('ingress', []):
                    sg_config.extend([
                        '  ingress {',
                        f'    from_port = {rule.get("from_port", rule.get("port"))}',
                        f'    to_port = {rule.get("to_port", rule.get("port"))}',
                        f'    protocol = "{rule.get("protocol", "tcp")}"',
                    ])
                    
                    if 'cidr' in rule:
                        sg_config.append(f'    cidr_blocks = ["{rule["cidr"]}"]')
                    elif 'security_group' in rule:
                        sg_config.append(f'    security_groups = [aws_security_group.{rule["security_group"]}.id]')
                    
                    sg_config.append('  }')
                
                sg_config.extend([
                    '  tags = {',
                    f'    Name = "{self.config["environment"]}-{sg["name"]}"',
                    f'    Environment = "{self.config["environment"]}"',
                    '  }',
                    '}',
                    ''
                ])
        
        return '\n'.join(sg_config)
    
    def generate_load_balancers(self) -> str:
        """Generate load balancer configuration"""
        lb_config = []
        
        if self.config['provider'] == 'aws':
            for lb in self.config.get('load_balancers', []):
                lb_config.extend([
                    f'resource "aws_lb" "{lb["name"]}" {',
                    f'  name = "{self.config["environment"]}-{lb["name"]}"',
                    f'  internal = {str(lb.get("internal", False)).lower()}',
                    f'  load_balancer_type = "{lb.get("type", "application")}"',
                    f'  security_groups = [aws_security_group.{lb["security_group"]}.id]',
                    f'  subnets = [{", ".join(f"aws_subnet.{s}.id" for s in lb.get("subnets", []))}]',
                    '',
                    '  enable_deletion_protection = false',
                    '',
                    '  tags = {',
                    f'    Name = "{self.config["environment"]}-{lb["name"]}"',
                    f'    Environment = "{self.config["environment"]}"',
                    '  }',
                    '}',
                    ''
                ])
                
                # Target groups
                for tg in lb.get('target_groups', []):
                    lb_config.extend([
                        f'resource "aws_lb_target_group" "{tg["name"]}" {',
                        f'  name = "{self.config["environment"]}-{tg["name"]}"',
                        f'  port = {tg["port"]}',
                        f'  protocol = "{tg.get("protocol", "HTTP")}"',
                        f'  vpc_id = aws_vpc.main.id',
                        '',
                        '  health_check {',
                        f'    path = "{tg.get("health_path", "/health")}"',
                        f'    interval = {tg.get("health_interval", 30)}',
                        f'    timeout = {tg.get("health_timeout", 5)}',
                        f'    healthy_threshold = {tg.get("healthy_threshold", 2)}',
                        f'    unhealthy_threshold = {tg.get("unhealthy_threshold", 2)}',
                        '  }',
                        '',
                        '  tags = {',
                        f'    Name = "{self.config["environment"]}-{tg["name"]}"',
                        f'    Environment = "{self.config["environment"]}"',
                        '  }',
                        '}',
                        ''
                    ])
        
        return '\n'.join(lb_config)
    
    def generate_outputs(self) -> str:
        """Generate output variables"""
        outputs = [
            'output "vpc_id" {',
            '  value = aws_vpc.main.id',
            '}',
            '',
            'output "subnet_ids" {',
            '  value = {',
        ]
        
        for subnet in self.config['subnets']:
            outputs.append(f'    {subnet["name"]} = aws_subnet.{subnet["name"]}.id')
        
        outputs.extend([
            '  }',
            '}',
            ''
        ])
        
        return '\n'.join(outputs)
    
    def generate_terraform(self) -> str:
        """Generate complete Terraform configuration"""
        sections = [
            self.generate_provider(),
            self.generate_vpc(),
            self.generate_security_groups(),
            self.generate_load_balancers(),
            self.generate_outputs()
        ]
        
        return '\n'.join(sections)
    
    def write_terraform_files(self):
        """Write Terraform files to disk"""
        # Main configuration
        main_tf = self.generate_terraform()
        with open(os.path.join(self.terraform_dir, 'main.tf'), 'w') as f:
            f.write(main_tf)
        logger.info(f"Wrote main.tf to {self.terraform_dir}")
        
        # Variables
        variables = [
            'variable "environment" {',
            f'  default = "{self.config["environment"]}"',
            '}',
            ''
        ]
        
        with open(os.path.join(self.terraform_dir, 'variables.tf'), 'w') as f:
            f.write('\n'.join(variables))
        logger.info(f"Wrote variables.tf to {self.terraform_dir}")
        
        # Terraform version file
        version = [
            'terraform {',
            '  required_version = ">= 1.0.0"',
            '}',
            ''
        ]
        
        with open(os.path.join(self.terraform_dir, 'versions.tf'), 'w') as f:
            f.write('\n'.join(version))
        logger.info(f"Wrote versions.tf to {self.terraform_dir}")
    
    def run_terraform(self, command: str = 'plan'):
        """Run Terraform commands"""
        import subprocess
        
        cmd = ['terraform', '-chdir=' + self.terraform_dir, command]
        
        if command == 'plan':
            cmd.append('-out=tfplan')
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            logger.info(f"Terraform {command} completed successfully")
            print(result.stdout)
        else:
            logger.error(f"Terraform {command} failed")
            print(result.stderr)
        
        return result.returncode == 0

def main():
    """Example usage"""
    # Sample configuration
    config = {
        'provider': 'aws',
        'region': 'us-east-1',
        'environment': 'production',
        'vpc': {
            'cidr': '10.0.0.0/16',
            'enable_dns': True,
            'enable_dns_hostnames': True
        },
        'subnets': [
            {'name': 'public1', 'cidr': '10.0.1.0/24', 'availability_zone': 'us-east-1a'},
            {'name': 'public2', 'cidr': '10.0.2.0/24', 'availability_zone': 'us-east-1b'},
            {'name': 'private1', 'cidr': '10.0.3.0/24', 'availability_zone': 'us-east-1a'},
            {'name': 'private2', 'cidr': '10.0.4.0/24', 'availability_zone': 'us-east-1b'},
        ],
        'security_groups': [
            {
                'name': 'web_sg',
                'description': 'Web security group',
                'ingress': [
                    {'from_port': 80, 'to_port': 80, 'protocol': 'tcp', 'cidr': '0.0.0.0/0'},
                    {'from_port': 443, 'to_port': 443, 'protocol': 'tcp', 'cidr': '0.0.0.0/0'},
                ]
            },
            {
                'name': 'ssh_sg',
                'description': 'SSH security group',
                'ingress': [
                    {'from_port': 22, 'to_port': 22, 'protocol': 'tcp', 'cidr': '192.168.1.0/24'},
                ]
            }
        ],
        'load_balancers': [
            {
                'name': 'web_lb',
                'type': 'application',
                'security_group': 'web_sg',
                'subnets': ['public1', 'public2'],
                'target_groups': [
                    {
                        'name': 'web_tg',
                        'port': 80,
                        'protocol': 'HTTP',
                        'health_path': '/health',
                        'health_interval': 30
                    }
                ]
            }
        ]
    }
    
    # Save config
    with open('network_terraform_config.yaml', 'w') as f:
        yaml.dump(config, f)
    
    # Generate Terraform
    generator = TerraformNetworkGenerator('network_terraform_config.yaml')
    generator.write_terraform_files()
    
    # Preview the configuration
    print("\nGenerated Terraform Configuration:")
    print("=" * 60)
    with open('terraform/main.tf', 'r') as f:
        print(f.read())
    
    # Optional: Run terraform plan
    # generator.run_terraform('plan')

if __name__ == "__main__":
    main()
```

---

## Summary

This appendix has covered comprehensive network automation and scripting across multiple domains:

1. **Python Automation Fundamentals** - Connection management, parallel execution
2. **Configuration Management** - Backup, deployment, templating
3. **Network Monitoring** - Health monitoring, alerting
4. **DNS Automation** - Record management, batch updates
5. **DHCP Automation** - Lease management, configuration
6. **Firewall Automation** - Rule management, blacklist/whitelist
7. **Load Balancer Automation** - Configuration, health checks
8. **Network Discovery** - Host discovery, inventory management
9. **Network Validation** - Testing framework, checks
10. **Infrastructure as Code** - Terraform generation

**Key Takeaways**:

1. **Automate repetitive tasks** - Reduce errors and save time
2. **Use templates** - Standardize configurations across devices
3. **Implement version control** - Track configuration changes
4. **Add validation** - Verify changes before deployment
5. **Monitor continuously** - Detect issues proactively
6. **Use infrastructure as code** - Manage network infrastructure programmatically
7. **Document automation** - Maintain clear documentation

---

**[END OF APPENDIX F]**
