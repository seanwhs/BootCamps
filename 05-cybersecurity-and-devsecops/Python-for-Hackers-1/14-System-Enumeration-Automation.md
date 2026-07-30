# Phase 4: Post-Exploitation & Automation Frameworks
## Part 2: System Enumeration Automation

### The Target: System Enumeration Framework

By the end of this part, you will:
- Understand system enumeration techniques and objectives
- Build automated enumeration modules for various OS platforms
- Collect system information, users, processes, and network configuration
- Implement a modular enumeration framework
- Generate comprehensive system intelligence reports

### The Concept: Understanding System Enumeration

Think of system enumeration like a detective gathering evidence at a crime scene:

- **System Information** = The building's blueprints
- **Users & Groups** = Who lives in the building
- **Processes** = What's happening in the building
- **Network Configuration** = How the building connects to the outside world
- **Files & Services** = What's inside the building

**Why We Enumerate:**
- **Lateral Movement**: Find other systems to compromise
- **Privilege Escalation**: Identify weaknesses to gain higher privileges
- **Data Discovery**: Find sensitive information
- **Persistence**: Identify places to maintain access
- **Environment Understanding**: Map the target landscape

### The Implementation: System Enumeration Framework

#### File: `~/hacking-toolkit/post-exploit/enumerator.py`

```python
#!/usr/bin/env python3
"""
enumerator.py - System Enumeration Automation Framework
Provides comprehensive system information gathering across platforms.
"""

import sys
import os
import platform
import subprocess
import socket
import json
import psutil
import datetime
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field

# Platform-specific imports
if platform.system() == 'Windows':
    try:
        import winreg
        import wmi
        HAS_WMI = True
    except ImportError:
        HAS_WMI = False
else:
    HAS_WMI = False

@dataclass
class SystemInfo:
    """Container for system information"""
    hostname: str = ''
    os_name: str = ''
    os_version: str = ''
    kernel_version: str = ''
    architecture: str = ''
    cpu_count: int = 0
    memory_total: int = 0
    memory_available: int = 0
    disk_usage: Dict = field(default_factory=dict)
    network_interfaces: List[Dict] = field(default_factory=list)
    
    def to_dict(self) -> Dict:
        return {
            'hostname': self.hostname,
            'os_name': self.os_name,
            'os_version': self.os_version,
            'kernel_version': self.kernel_version,
            'architecture': self.architecture,
            'cpu_count': self.cpu_count,
            'memory_total': self.memory_total,
            'memory_available': self.memory_available,
            'disk_usage': self.disk_usage,
            'network_interfaces': self.network_interfaces
        }

@dataclass
class UserInfo:
    """Container for user information"""
    username: str
    uid: int
    gid: int
    home_dir: str
    shell: str
    groups: List[str]
    last_login: str = ''
    
    def to_dict(self) -> Dict:
        return {
            'username': self.username,
            'uid': self.uid,
            'gid': self.gid,
            'home_dir': self.home_dir,
            'shell': self.shell,
            'groups': self.groups,
            'last_login': self.last_login
        }

@dataclass
class ProcessInfo:
    """Container for process information"""
    pid: int
    name: str
    username: str
    cpu_percent: float
    memory_percent: float
    create_time: str
    cmdline: str
    connections: List[Dict]
    
    def to_dict(self) -> Dict:
        return {
            'pid': self.pid,
            'name': self.name,
            'username': self.username,
            'cpu_percent': self.cpu_percent,
            'memory_percent': self.memory_percent,
            'create_time': self.create_time,
            'cmdline': self.cmdline,
            'connections': self.connections
        }

class SystemEnumerator:
    """
    Comprehensive system enumeration framework
    Gathers system information across multiple platforms
    """
    
    def __init__(self, verbose: bool = True):
        """
        Initialize the system enumerator
        
        Args:
            verbose: Enable verbose output
        """
        self.verbose = verbose
        self.system = {}
        self.users = []
        self.processes = []
        self.network = {}
        self.services = []
        self.cron_jobs = []
        self.file_system = {}
        self.environment = {}
        self.security = {}
        
        self._detect_platform()
        
    def _detect_platform(self):
        """Detect the operating system platform"""
        self.platform = platform.system()
        self.platform_version = platform.version()
        self.platform_release = platform.release()
        
        if self.verbose:
            print(f"[*] Platform: {self.platform} {self.platform_release}")
    
    def _run_command(self, command: str) -> str:
        """Execute a shell command and return output"""
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True
            )
            return result.stdout.strip()
        except:
            return ''
    
    def get_system_info(self) -> SystemInfo:
        """
        Gather basic system information
        
        Returns:
            SystemInfo object
        """
        info = SystemInfo()
        
        try:
            # Hostname
            info.hostname = socket.gethostname()
            
            # OS information
            info.os_name = platform.system()
            info.os_version = platform.version()
            info.kernel_version = platform.release()
            info.architecture = platform.machine()
            
            # CPU
            info.cpu_count = psutil.cpu_count()
            
            # Memory
            mem = psutil.virtual_memory()
            info.memory_total = mem.total
            info.memory_available = mem.available
            
            # Disk usage
            disk = psutil.disk_usage('/')
            info.disk_usage = {
                'total': disk.total,
                'used': disk.used,
                'free': disk.free,
                'percent': disk.percent
            }
            
            # Network interfaces
            info.network_interfaces = self.get_network_info()
            
            self.system = info.to_dict()
            
            if self.verbose:
                print(f"[+] System info gathered")
                
        except Exception as e:
            print(f"[-] Error gathering system info: {e}")
        
        return info
    
    def get_network_info(self) -> List[Dict]:
        """
        Gather network interface information
        
        Returns:
            List of network interface dictionaries
        """
        network_info = []
        
        try:
            interfaces = psutil.net_if_addrs()
            stats = psutil.net_if_stats()
            
            for interface, addrs in interfaces.items():
                info = {
                    'name': interface,
                    'addresses': [],
                    'status': stats.get(interface, {}).isup if interface in stats else False
                }
                
                for addr in addrs:
                    if addr.family == socket.AF_INET:
                        info['addresses'].append({
                            'type': 'IPv4',
                            'address': addr.address,
                            'netmask': addr.netmask
                        })
                    elif addr.family == socket.AF_INET6:
                        info['addresses'].append({
                            'type': 'IPv6',
                            'address': addr.address,
                            'netmask': addr.netmask
                        })
                
                network_info.append(info)
            
            self.network = network_info
            
            if self.verbose:
                print(f"[+] Network info gathered ({len(network_info)} interfaces)")
                
        except Exception as e:
            print(f"[-] Error gathering network info: {e}")
        
        return network_info
    
    def get_users(self) -> List[UserInfo]:
        """
        Gather user information
        
        Returns:
            List of UserInfo objects
        """
        users = []
        
        try:
            if self.platform == 'Windows':
                # Windows user enumeration
                import win32api
                import win32net
                
                try:
                    user_info = win32net.NetUserGetInfo(None, win32api.GetUserName(), 2)
                    user = UserInfo(
                        username=user_info['name'],
                        uid=0,
                        gid=0,
                        home_dir=user_info.get('home_dir', ''),
                        shell=user_info.get('script_path', ''),
                        groups=[]
                    )
                    users.append(user)
                except:
                    pass
                    
            else:
                # Unix/Linux/Mac user enumeration
                # Get /etc/passwd
                with open('/etc/passwd', 'r') as f:
                    for line in f:
                        if line.startswith('#'):
                            continue
                        parts = line.strip().split(':')
                        if len(parts) >= 7:
                            user = UserInfo(
                                username=parts[0],
                                uid=int(parts[2]),
                                gid=int(parts[3]),
                                home_dir=parts[5],
                                shell=parts[6],
                                groups=[]
                            )
                            users.append(user)
                
                # Get group memberships
                with open('/etc/group', 'r') as f:
                    for line in f:
                        parts = line.strip().split(':')
                        if len(parts) >= 4:
                            group_name = parts[0]
                            members = parts[3].split(',') if parts[3] else []
                            
                            for member in members:
                                for user in users:
                                    if user.username == member:
                                        user.groups.append(group_name)
            
            self.users = [u.to_dict() for u in users]
            
            if self.verbose:
                print(f"[+] User info gathered ({len(users)} users)")
                
        except Exception as e:
            print(f"[-] Error gathering user info: {e}")
        
        return users
    
    def get_processes(self, include_connections: bool = False) -> List[ProcessInfo]:
        """
        Gather process information
        
        Args:
            include_connections: Include network connections
            
        Returns:
            List of ProcessInfo objects
        """
        processes = []
        
        try:
            for proc in psutil.process_iter(['pid', 'name', 'username', 'cmdline', 'create_time']):
                try:
                    info = proc.info
                    
                    # Get CPU and memory usage
                    cpu_percent = proc.cpu_percent(interval=0.1)
                    memory_percent = proc.memory_percent()
                    
                    # Get connections
                    connections = []
                    if include_connections:
                        try:
                            conns = proc.connections()
                            for conn in conns:
                                connections.append({
                                    'status': conn.status,
                                    'local': f"{conn.laddr.ip}:{conn.laddr.port}" if conn.laddr else '',
                                    'remote': f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else ''
                                })
                        except:
                            pass
                    
                    # Format create time
                    create_time = datetime.datetime.fromtimestamp(
                        info['create_time']
                    ).isoformat() if info['create_time'] else ''
                    
                    process = ProcessInfo(
                        pid=info['pid'],
                        name=info['name'] or '',
                        username=info['username'] or '',
                        cpu_percent=round(cpu_percent, 2),
                        memory_percent=round(memory_percent, 2),
                        create_time=create_time,
                        cmdline=' '.join(info['cmdline']) if info['cmdline'] else '',
                        connections=connections
                    )
                    
                    processes.append(process)
                    
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    continue
            
            self.processes = [p.to_dict() for p in processes]
            
            if self.verbose:
                print(f"[+] Process info gathered ({len(processes)} processes)")
                
        except Exception as e:
            print(f"[-] Error gathering process info: {e}")
        
        return processes
    
    def get_environment(self) -> Dict[str, str]:
        """
        Get environment variables
        
        Returns:
            Dictionary of environment variables
        """
        env = {}
        
        try:
            for key, value in os.environ.items():
                if any(sensitive in key.lower() for sensitive in ['key', 'secret', 'token', 'password']):
                    env[key] = f"*** REDACTED ***"
                else:
                    env[key] = value[:100] + ('...' if len(value) > 100 else '')
            
            self.environment = env
            
            if self.verbose:
                print(f"[+] Environment info gathered ({len(env)} variables)")
                
        except Exception as e:
            print(f"[-] Error gathering environment: {e}")
        
        return env
    
    def get_services(self) -> List[Dict[str, Any]]:
        """
        Get system services
        
        Returns:
            List of service information
        """
        services = []
        
        try:
            if self.platform == 'Windows':
                # Windows services using WMI
                if HAS_WMI:
                    c = wmi.WMI()
                    for service in c.Win32_Service():
                        services.append({
                            'name': service.Name,
                            'display_name': service.DisplayName,
                            'status': service.State,
                            'start_mode': service.StartMode,
                            'path': service.PathName
                        })
                else:
                    # Try using sc command
                    output = self._run_command('sc query state= all')
                    # Parse output
                    for line in output.split('\n'):
                        if 'SERVICE_NAME:' in line:
                            name = line.split(':')[1].strip()
                            services.append({'name': name})
            else:
                # Linux services
                # Check for systemd
                if os.path.exists('/bin/systemctl'):
                    output = self._run_command('systemctl list-units --type=service --all')
                    for line in output.split('\n'):
                        if '.service' in line and not line.startswith(' '):
                            parts = line.split()
                            if len(parts) >= 3:
                                services.append({
                                    'name': parts[0],
                                    'status': parts[2]
                                })
                else:
                    # Check for init.d
                    if os.path.exists('/etc/init.d'):
                        init_dir = '/etc/init.d'
                        for item in os.listdir(init_dir):
                            path = os.path.join(init_dir, item)
                            if os.path.isfile(path) and os.access(path, os.X_OK):
                                services.append({
                                    'name': item,
                                    'status': 'unknown'
                                })
            
            self.services = services
            
            if self.verbose:
                print(f"[+] Service info gathered ({len(services)} services)")
                
        except Exception as e:
            print(f"[-] Error gathering services: {e}")
        
        return services
    
    def get_cron_jobs(self) -> List[Dict[str, str]]:
        """
        Get cron jobs (Unix/Linux only)
        
        Returns:
            List of cron job information
        """
        jobs = []
        
        if self.platform == 'Windows':
            # Windows scheduled tasks
            output = self._run_command('schtasks /query /fo CSV /v')
            # Parse CSV output
            for line in output.split('\n'):
                if 'TaskName' in line or not line.strip():
                    continue
                parts = line.split(',')
                if len(parts) >= 3:
                    jobs.append({
                        'name': parts[0].strip('"'),
                        'status': parts[1].strip('"'),
                        'schedule': parts[2].strip('"')
                    })
        else:
            # Linux cron jobs
            cron_locations = [
                '/etc/crontab',
                '/etc/cron.d/',
                '/var/spool/cron/',
                '/var/spool/cron/crontabs/'
            ]
            
            for location in cron_locations:
                if os.path.exists(location):
                    if os.path.isfile(location):
                        with open(location, 'r') as f:
                            for line in f:
                                if not line.startswith('#') and line.strip():
                                    jobs.append({
                                        'file': location,
                                        'entry': line.strip()
                                    })
                    elif os.path.isdir(location):
                        for filename in os.listdir(location):
                            filepath = os.path.join(location, filename)
                            if os.path.isfile(filepath):
                                try:
                                    with open(filepath, 'r') as f:
                                        for line in f:
                                            if not line.startswith('#') and line.strip():
                                                jobs.append({
                                                    'file': filepath,
                                                    'entry': line.strip()
                                                })
                                except:
                                    pass
        
        self.cron_jobs = jobs
        
        if self.verbose:
            print(f"[+] Cron job info gathered ({len(jobs)} jobs)")
        
        return jobs
    
    def get_file_system_info(self, paths: List[str] = None) -> Dict[str, Any]:
        """
        Get file system information
        
        Args:
            paths: List of paths to check (default: ['/', '/etc', '/var', '/home'])
            
        Returns:
            Dictionary of file system information
        """
        if paths is None:
            paths = ['/', '/etc', '/var', '/home']
        
        info = {}
        
        try:
            for path in paths:
                if os.path.exists(path):
                    # Get directory listing
                    if os.path.isdir(path):
                        try:
                            files = os.listdir(path)
                            info[path] = {
                                'type': 'directory',
                                'files': len(files),
                                'sample_files': files[:10]
                            }
                        except PermissionError:
                            info[path] = {
                                'type': 'directory',
                                'error': 'Permission denied'
                            }
                    else:
                        # Get file info
                        stat = os.stat(path)
                        info[path] = {
                            'type': 'file',
                            'size': stat.st_size,
                            'modified': datetime.datetime.fromtimestamp(stat.st_mtime).isoformat()
                        }
            
            self.file_system = info
            
            if self.verbose:
                print(f"[+] File system info gathered")
                
        except Exception as e:
            print(f"[-] Error gathering file system info: {e}")
        
        return info
    
    def get_security_info(self) -> Dict[str, Any]:
        """
        Get security-related information
        
        Returns:
            Dictionary of security information
        """
        security = {
            'firewall_status': 'unknown',
            'selinux_status': 'unknown',
            'apparmor_status': 'unknown',
            'antivirus_status': 'unknown'
        }
        
        try:
            if self.platform == 'Linux':
                # Check SELinux
                se_status = self._run_command('getenforce')
                if se_status:
                    security['selinux_status'] = se_status
                
                # Check AppArmor
                aa_status = self._run_command('apparmor_status')
                if aa_status:
                    security['apparmor_status'] = 'enabled'
                
                # Check firewall
                fw_status = self._run_command('ufw status')
                if fw_status:
                    security['firewall_status'] = fw_status
                else:
                    fw_status = self._run_command('iptables -L')
                    if fw_status and 'Chain INPUT' in fw_status:
                        security['firewall_status'] = 'iptables configured'
            
            elif self.platform == 'Windows':
                # Check Windows Defender
                defender_status = self._run_command('powershell Get-MpPreference')
                if defender_status:
                    security['antivirus_status'] = 'Windows Defender'
                
                # Check firewall
                fw_status = self._run_command('netsh advfirewall show allprofiles')
                if fw_status:
                    security['firewall_status'] = 'Windows Firewall'
            
            self.security = security
            
            if self.verbose:
                print(f"[+] Security info gathered")
                
        except Exception as e:
            print(f"[-] Error gathering security info: {e}")
        
        return security
    
    def enumerate_all(self) -> Dict[str, Any]:
        """
        Perform complete system enumeration
        
        Returns:
            Dictionary with all gathered information
        """
        print("="*60)
        print("  SYSTEM ENUMERATION")
        print("="*60)
        
        results = {}
        
        # System information
        print("\n[1] Gathering System Information...")
        results['system'] = self.get_system_info().to_dict()
        
        # Network information
        print("\n[2] Gathering Network Information...")
        results['network'] = self.get_network_info()
        
        # User information
        print("\n[3] Gathering User Information...")
        results['users'] = [u.to_dict() for u in self.get_users()]
        
        # Process information
        print("\n[4] Gathering Process Information...")
        results['processes'] = [p.to_dict() for p in self.get_processes(include_connections=True)]
        
        # Services
        print("\n[5] Gathering Service Information...")
        results['services'] = self.get_services()
        
        # Cron/Scheduled tasks
        print("\n[6] Gathering Scheduled Tasks...")
        results['scheduled_tasks'] = self.get_cron_jobs()
        
        # Environment variables
        print("\n[7] Gathering Environment Variables...")
        results['environment'] = self.get_environment()
        
        # File system
        print("\n[8] Gathering File System Information...")
        results['file_system'] = self.get_file_system_info()
        
        # Security
        print("\n[9] Gathering Security Information...")
        results['security'] = self.get_security_info()
        
        # Add metadata
        results['metadata'] = {
            'timestamp': datetime.datetime.now().isoformat(),
            'platform': self.platform,
            'platform_release': self.platform_release,
            'hostname': socket.gethostname()
        }
        
        print("\n" + "="*60)
        print("  ENUMERATION COMPLETE")
        print("="*60)
        print(f"  System: {self.platform} {self.platform_release}")
        print(f"  Users: {len(results['users'])}")
        print(f"  Processes: {len(results['processes'])}")
        print(f"  Services: {len(results['services'])}")
        print(f"  Scheduled tasks: {len(results['scheduled_tasks'])}")
        
        return results
    
    def save_report(self, results: Dict, filename: str = None):
        """
        Save enumeration results to a file
        
        Args:
            results: Results dictionary
            filename: Output filename
        """
        if not filename:
            filename = f"enumeration_report_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        try:
            with open(filename, 'w') as f:
                json.dump(results, f, indent=2, default=str)
            print(f"\n[+] Report saved to {filename}")
        except Exception as e:
            print(f"[-] Error saving report: {e}")

def main():
    """Interactive enumeration demonstration"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="System Enumeration Automation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Full enumeration
  python3 enumerator.py --all -o report.json
  
  # System only
  python3 enumerator.py --system
  
  # User and process info
  python3 enumerator.py --users --processes
        """
    )
    
    parser.add_argument('--system', action='store_true', help='Gather system information')
    parser.add_argument('--network', action='store_true', help='Gather network information')
    parser.add_argument('--users', action='store_true', help='Gather user information')
    parser.add_argument('--processes', action='store_true', help='Gather process information')
    parser.add_argument('--services', action='store_true', help='Gather service information')
    parser.add_argument('--cron', action='store_true', help='Gather scheduled tasks')
    parser.add_argument('--environment', action='store_true', help='Gather environment variables')
    parser.add_argument('--security', action='store_true', help='Gather security information')
    parser.add_argument('--all', action='store_true', help='Gather all information')
    parser.add_argument('-o', '--output', help='Output file for report')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    # Create enumerator
    enumerator = SystemEnumerator(verbose=args.verbose)
    
    # Determine what to enumerate
    if args.all:
        results = enumerator.enumerate_all()
    else:
        results = {}
        
        if args.system or not any(vars(args).values()):
            results['system'] = enumerator.get_system_info().to_dict()
        
        if args.network:
            results['network'] = enumerator.get_network_info()
        
        if args.users:
            results['users'] = [u.to_dict() for u in enumerator.get_users()]
        
        if args.processes:
            results['processes'] = [p.to_dict() for p in enumerator.get_processes(include_connections=True)]
        
        if args.services:
            results['services'] = enumerator.get_services()
        
        if args.cron:
            results['scheduled_tasks'] = enumerator.get_cron_jobs()
        
        if args.environment:
            results['environment'] = enumerator.get_environment()
        
        if args.security:
            results['security'] = enumerator.get_security_info()
    
    # Save report
    if results:
        if args.output:
            enumerator.save_report(results, args.output)
        else:
            # Print summary
            print("\n[*] Enumeration Summary:")
            for key in results:
                if isinstance(results[key], list):
                    print(f"  {key}: {len(results[key])} items")
                elif isinstance(results[key], dict):
                    print(f"  {key}: {len(results[key])} items")
                else:
                    print(f"  {key}: {results[key]}")

if __name__ == "__main__":
    main()
```

### The Verification: Testing Enumeration

#### Test 1: System Information

```bash
cd ~/hacking-toolkit/post-exploit
python3 enumerator.py --system
```

**Expected Output:**
```
[*] Platform: Linux 5.15.0
[+] System info gathered

[*] Enumeration Summary:
  system: 1 items
  hostname: kali
  os_name: Linux
  os_version: #1 SMP... 
  cpu_count: 4
  memory_total: 8363565056
```

#### Test 2: Full Enumeration

```bash
python3 enumerator.py --all -o enumeration.json
```

**Expected Output:**
```
============================================================
  SYSTEM ENUMERATION
============================================================

[1] Gathering System Information...
[+] System info gathered

[2] Gathering Network Information...
[+] Network info gathered (3 interfaces)

[3] Gathering User Information...
[+] User info gathered (5 users)

[4] Gathering Process Information...
[+] Process info gathered (156 processes)

...

============================================================
  ENUMERATION COMPLETE
============================================================
  System: Linux 5.15.0
  Users: 5
  Processes: 156
  Services: 89
  Scheduled tasks: 12

[+] Report saved to enumeration.json
```

#### Test 3: Windows-Specific Enumeration (if on Windows)

```bash
python3 enumerator.py --services --processes
```

### Advanced Usage: Automated Post-Exploitation

```python
# Automated post-exploitation script
cat > auto_enum.py << 'EOF'
#!/usr/bin/env python3
from enumerator import SystemEnumerator
import json
import time

def perform_enumeration():
    """Perform automated enumeration with persistence"""
    
    # Create enumerator
    enumerator = SystemEnumerator(verbose=True)
    
    # Stage 1: Basic System Info
    print("\n=== Stage 1: Basic System Info ===")
    system_info = enumerator.get_system_info()
    
    # Stage 2: Users and Groups
    print("\n=== Stage 2: User Enumeration ===")
    users = enumerator.get_users()
    
    # Check for high-privilege users
    admin_users = []
    for user in users:
        if user.uid == 0 or 'admin' in user.username.lower():
            admin_users.append(user.username)
    
    print(f"[*] Admin/root users: {admin_users}")
    
    # Stage 3: Process Analysis
    print("\n=== Stage 3: Process Analysis ===")
    processes = enumerator.get_processes(include_connections=True)
    
    # Look for interesting processes
    interesting = []
    for proc in processes:
        proc_dict = proc.to_dict()
        name = proc_dict['name'].lower()
        if any(x in name for x in ['apache', 'nginx', 'mysql', 'postgres', 'redis', 'docker']):
            interesting.append(name)
    
    print(f"[*] Interesting processes: {list(set(interesting))}")
    
    # Stage 4: Security Analysis
    print("\n=== Stage 4: Security Analysis ===")
    security = enumerator.get_security_info()
    print(f"[*] Firewall: {security['firewall_status']}")
    print(f"[*] SELinux: {security['selinux_status']}")
    
    # Stage 5: Find Sensitive Files
    print("\n=== Stage 5: Sensitive File Search ===")
    sensitive_paths = [
        '/etc/passwd', '/etc/shadow', '/etc/sudoers',
        '/var/log/auth.log', '/var/log/secure',
        '.ssh', '.bash_history', '.mysql_history'
    ]
    
    for path in sensitive_paths:
        if os.path.exists(path):
            print(f"[+] Found: {path}")
    
    # Generate final report
    print("\n=== Final Report ===")
    print(f"Platform: {system_info.os_name} {system_info.os_version}")
    print(f"Hostname: {system_info.hostname}")
    print(f"Users: {len(users)}")
    print(f"Processes: {len(processes)}")
    print(f"Admin users: {admin_users}")
    
    return {
        'system': system_info.to_dict(),
        'users': [u.to_dict() for u in users],
        'processes': [p.to_dict() for p in processes[:10]],
        'security': security
    }

# Run enumeration
print("[*] Starting automated enumeration...")
results = perform_enumeration()

# Save results
with open('auto_enum_results.json', 'w') as f:
    json.dump(results, f, indent=2, default=str)
print("\n[+] Results saved to auto_enum_results.json")
EOF

python3 auto_enum.py
```

### Reference: Enumeration Categories

| Category | What to Look For | Why Important |
|----------|------------------|---------------|
| System | OS, version, architecture | Identify exploits |
| Users | User list, groups, privileges | Privilege escalation |
| Processes | Running services, connections | Services to attack |
| Network | Interfaces, routes, ARP | Lateral movement |
| Services | Installed services, versions | Vulnerability matching |
| Cron/Scheduled | Automated tasks | Persistence, escalation |
| Security | Firewall, AV, SELinux | Detect defense mechanisms |
| Files | Config files, logs, creds | Data discovery |
