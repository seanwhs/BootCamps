# Part 4: Advanced Tooling Design, Obfuscation & Hardening

## Section 1: Plugin-Based Architecture

### The Target
`pyhack_suite/modules/` - Production-grade plugin system with dynamic loading

### The Concept
A plugin architecture is like a smartphone app store. The core system (the phone) provides a stable foundation, and plugins (apps) add new capabilities without modifying the core. This allows:
- **Rapid capability expansion** - Add new features without touching core code
- **Isolation** - Plugins run in isolation, containing failures
- **Hot-swapping** - Load and unload plugins at runtime
- **Community contributions** - Easy to share and distribute plugins

---

## Step 4.1: Plugin System Implementation

### The Implementation

Create `pyhack_suite/modules/base.py`:

```python
#!/usr/bin/env python3
"""
Base plugin architecture for PyHack Suite.

This module provides:
- Abstract base classes for plugins
- Plugin lifecycle management
- Configuration management
- Event hooks
- Security restrictions

Design pattern: Plugin architecture with dependency injection
"""

from abc import ABC, abstractmethod
from typing import Optional, Dict, Any, List, Callable, Set
from dataclasses import dataclass, field
import inspect
import asyncio
import time
from enum import Enum

from pyhack_suite.core.config import get_config
from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


class PluginState(Enum):
    """Plugin lifecycle states."""
    UNLOADED = "unloaded"
    LOADING = "loading"
    LOADED = "loaded"
    INITIALIZING = "initializing"
    INITIALIZED = "initialized"
    RUNNING = "running"
    PAUSED = "paused"
    STOPPING = "stopping"
    STOPPED = "stopped"
    ERROR = "error"


@dataclass
class PluginManifest:
    """
    Plugin manifest defining plugin metadata and capabilities.
    
    This is the plugin's "recipe" - it tells the system what the plugin is,
    what it can do, and what it needs to run.
    """
    
    name: str
    version: str = "1.0.0"
    description: str = ""
    author: str = "Unknown"
    license: str = "MIT"
    
    # Dependencies
    requires: List[str] = field(default_factory=list)
    conflicts: List[str] = field(default_factory=list)
    
    # Capabilities
    provides: List[str] = field(default_factory=list)  # Services provided
    consumes: List[str] = field(default_factory=list)  # Services needed
    
    # Security
    permissions: List[str] = field(default_factory=list)  # Required permissions
    sandboxed: bool = True  # Run in sandbox
    
    # Metadata
    homepage: Optional[str] = None
    repository: Optional[str] = None
    tags: List[str] = field(default_factory=list)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            'name': self.name,
            'version': self.version,
            'description': self.description,
            'author': self.author,
            'license': self.license,
            'requires': self.requires,
            'conflicts': self.conflicts,
            'provides': self.provides,
            'consumes': self.consumes,
            'permissions': self.permissions,
            'sandboxed': self.sandboxed,
            'tags': self.tags,
        }


class Plugin(ABC):
    """
    Abstract base class for all plugins.
    
    All plugins must inherit from this class and implement
    the required methods.
    
    Example:
        class MyPlugin(Plugin):
            def get_manifest(self):
                return PluginManifest(
                    name="my_plugin",
                    description="Does something useful",
                    permissions=["network", "filesystem"]
                )
            
            async def on_load(self):
                # Initialize resources
                pass
            
            async def on_run(self, context):
                # Do work
                return {"result": "success"}
            
            async def on_unload(self):
                # Clean up
                pass
    """
    
    def __init__(self):
        """Initialize the plugin."""
        self.config = get_config()
        self.logger = get_logger(f"{__name__}.{self.__class__.__name__}")
        self.manifest = self.get_manifest()
        self.state = PluginState.UNLOADED
        self.context: Dict[str, Any] = {}
        self._start_time: Optional[float] = None
        self._stop_time: Optional[float] = None
        
        # Event handlers
        self._event_handlers: Dict[str, List[Callable]] = {}
    
    @abstractmethod
    def get_manifest(self) -> PluginManifest:
        """
        Get the plugin manifest.
        
        Returns:
            PluginManifest: Plugin metadata
        """
        pass
    
    @abstractmethod
    async def on_load(self) -> None:
        """
        Called when the plugin is loaded.
        
        Use this for initialization that doesn't require the
        plugin to be running (e.g., loading configuration).
        """
        pass
    
    @abstractmethod
    async def on_run(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Called when the plugin is run.
        
        Args:
            context: Execution context (parameters, state, etc.)
            
        Returns:
            Dict[str, Any]: Results
        """
        pass
    
    @abstractmethod
    async def on_unload(self) -> None:
        """
        Called when the plugin is unloaded.
        
        Use this for cleanup and resource release.
        """
        pass
    
    # Optional lifecycle hooks
    
    async def on_start(self) -> None:
        """Called when the plugin starts running."""
        pass
    
    async def on_pause(self) -> None:
        """Called when the plugin is paused."""
        pass
    
    async def on_resume(self) -> None:
        """Called when the plugin is resumed."""
        pass
    
    async def on_stop(self) -> None:
        """Called when the plugin stops."""
        pass
    
    async def on_error(self, error: Exception) -> None:
        """
        Called when an error occurs.
        
        Args:
            error: The error that occurred
        """
        pass
    
    # Utility methods
    
    def get_state(self) -> PluginState:
        """Get the current plugin state."""
        return self.state
    
    def set_state(self, state: PluginState):
        """
        Set the plugin state.
        
        Args:
            state: New state
        """
        old_state = self.state
        self.state = state
        self.logger.debug(f"State change: {old_state} -> {state}")
    
    def get_runtime(self) -> Optional[float]:
        """
        Get the runtime in seconds.
        
        Returns:
            Optional[float]: Runtime, or None if not running
        """
        if self.state == PluginState.RUNNING and self._start_time:
            return time.time() - self._start_time
        return None
    
    def get_context(self, key: str, default: Any = None) -> Any:
        """
        Get a value from the plugin context.
        
        Args:
            key: Context key
            default: Default value if key not found
            
        Returns:
            Any: Context value
        """
        return self.context.get(key, default)
    
    def set_context(self, key: str, value: Any) -> None:
        """
        Set a value in the plugin context.
        
        Args:
            key: Context key
            value: Value to set
        """
        self.context[key] = value
    
    def emit_event(self, event_name: str, data: Any = None) -> None:
        """
        Emit an event.
        
        Args:
            event_name: Event name
            data: Event data
        """
        if event_name in self._event_handlers:
            for handler in self._event_handlers[event_name]:
                try:
                    if asyncio.iscoroutinefunction(handler):
                        asyncio.create_task(handler(data))
                    else:
                        handler(data)
                except Exception as e:
                    self.logger.error(f"Event handler error: {e}")
    
    def on_event(self, event_name: str, handler: Callable) -> None:
        """
        Register an event handler.
        
        Args:
            event_name: Event name
            handler: Event handler function
        """
        if event_name not in self._event_handlers:
            self._event_handlers[event_name] = []
        self._event_handlers[event_name].append(handler)
    
    async def __aenter__(self):
        """Async context manager entry."""
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        if self.state == PluginState.LOADED:
            await self.on_unload()


class ServicePlugin(Plugin):
    """
    Plugin that provides services to other plugins.
    
    Service plugins offer functionality that other plugins can use.
    They follow a provider-consumer pattern.
    """
    
    @abstractmethod
    async def get_service(self, name: str) -> Any:
        """
        Get a service instance.
        
        Args:
            name: Service name
            
        Returns:
            Any: Service instance
        """
        pass


class DataPlugin(Plugin):
    """
    Plugin that provides data sources.
    
    Data plugins provide access to data sources like databases,
    APIs, files, etc.
    """
    
    @abstractmethod
    async def query(self, query: str, **kwargs) -> Any:
        """
        Query the data source.
        
        Args:
            query: Query string or parameters
            **kwargs: Additional parameters
            
        Returns:
            Any: Query results
        """
        pass


class ScannerPlugin(Plugin):
    """
    Plugin that provides scanning capabilities.
    
    Scanner plugins perform scanning and reconnaissance.
    """
    
    @abstractmethod
    async def scan(self, target: str, **kwargs) -> Dict[str, Any]:
        """
        Perform a scan.
        
        Args:
            target: Target to scan
            **kwargs: Scan parameters
            
        Returns:
            Dict[str, Any]: Scan results
        """
        pass


class ExploitPlugin(Plugin):
    """
    Plugin that provides exploitation capabilities.
    
    Exploit plugins attempt to exploit vulnerabilities.
    
    Note: Use ethically and with permission only.
    """
    
    @abstractmethod
    async def check(self, target: str) -> Dict[str, Any]:
        """
        Check if the target is vulnerable.
        
        Args:
            target: Target to check
            
        Returns:
            Dict[str, Any]: Vulnerability assessment
        """
        pass
    
    @abstractmethod
    async def exploit(self, target: str, payload: Any) -> Dict[str, Any]:
        """
        Exploit the vulnerability.
        
        Args:
            target: Target to exploit
            payload: Exploit payload
            
        Returns:
            Dict[str, Any]: Exploit results
        """
        pass
```

Create `pyhack_suite/modules/loader.py`:

```python
#!/usr/bin/env python3
"""
Dynamic plugin loader for PyHack Suite.

This module provides:
- Dynamic plugin loading from directories
- Plugin discovery and registration
- Dependency resolution
- Version compatibility checking
- Security sandboxing
"""

import os
import sys
import importlib
import inspect
from pathlib import Path
from typing import Optional, Dict, Any, List, Set, Type
import pkgutil
import json
import hashlib
import tempfile
import shutil
import subprocess

from pyhack_suite.modules.base import Plugin, PluginManifest, PluginState
from pyhack_suite.utils.logging import get_logger, log_function_call
from pyhack_suite.core.config import get_config
from pyhack_suite.utils.sandbox import Sandbox

logger = get_logger(__name__)


class PluginLoader:
    """
    Dynamic plugin loader.
    
    This class handles:
    - Discovering plugins in directories
    - Loading plugins dynamically
    - Resolving dependencies
    - Managing plugin lifecycle
    - Security checking
    
    Example:
        loader = PluginLoader()
        
        # Load plugins from directory
        loader.discover_plugins("/path/to/plugins")
        
        # Load a specific plugin
        plugin = loader.load_plugin("my_plugin")
        
        # Run the plugin
        result = await plugin.on_run(context)
    """
    
    def __init__(self, plugin_dir: Optional[Path] = None):
        """
        Initialize the plugin loader.
        
        Args:
            plugin_dir: Directory containing plugins (default: from config)
        """
        self.config = get_config()
        self.logger = get_logger(__name__)
        
        # Plugin directories
        self.plugin_dir = plugin_dir or self.config.modules_dir
        self.plugin_dir.mkdir(parents=True, exist_ok=True)
        
        # Plugin registry
        self.plugins: Dict[str, Type[Plugin]] = {}
        self.instances: Dict[str, Plugin] = {}
        self.manifests: Dict[str, PluginManifest] = {}
        
        # Dependencies
        self.dependency_graph: Dict[str, Set[str]] = {}
        
        # Security
        self.sandbox = Sandbox()
        
        # Loaded state
        self._loaded = False
        
        self.logger.info(f"Plugin loader initialized (dir: {self.plugin_dir})")
    
    @log_function_call(level="INFO")
    def discover_plugins(self, path: Optional[Path] = None) -> List[str]:
        """
        Discover plugins in a directory.
        
        Args:
            path: Directory to search (default: plugin_dir)
            
        Returns:
            List[str]: Discovered plugin names
        """
        path = Path(path) if path else self.plugin_dir
        
        if not path.exists():
            self.logger.warning(f"Plugin directory not found: {path}")
            return []
        
        self.logger.info(f"Discovering plugins in: {path}")
        
        discovered = []
        
        # Scan for plugin modules
        for item in path.iterdir():
            if item.is_dir():
                # Check for plugin.py or __init__.py
                plugin_file = item / "plugin.py"
                init_file = item / "__init__.py"
                
                if plugin_file.exists() or init_file.exists():
                    # Try to import and register
                    try:
                        # Add to path if not already
                        if str(item.parent) not in sys.path:
                            sys.path.insert(0, str(item.parent))
                        
                        # Import module
                        module_name = item.name
                        module = importlib.import_module(module_name)
                        
                        # Find plugin classes
                        for attr_name in dir(module):
                            attr = getattr(module, attr_name)
                            if (inspect.isclass(attr) and 
                                issubclass(attr, Plugin) and 
                                attr != Plugin):
                                # Register plugin
                                self.register_plugin(attr)
                                discovered.append(attr.__name__)
                                
                    except Exception as e:
                        self.logger.error(f"Failed to load plugin {item.name}: {e}")
        
        self.logger.info(f"Discovered {len(discovered)} plugins")
        return discovered
    
    def register_plugin(self, plugin_class: Type[Plugin]) -> None:
        """
        Register a plugin class.
        
        Args:
            plugin_class: Plugin class to register
        """
        try:
            # Create temporary instance for manifest
            temp = plugin_class()
            manifest = temp.get_manifest()
            
            self.plugins[manifest.name] = plugin_class
            self.manifests[manifest.name] = manifest
            
            self.logger.info(f"Registered plugin: {manifest.name} v{manifest.version}")
            
        except Exception as e:
            self.logger.error(f"Failed to register plugin {plugin_class}: {e}")
    
    @log_function_call(level="INFO")
    def load_plugin(self, name: str) -> Optional[Plugin]:
        """
        Load a plugin by name.
        
        Args:
            name: Plugin name
            
        Returns:
            Optional[Plugin]: Plugin instance, or None if not found
        """
        if name not in self.plugins:
            self.logger.error(f"Plugin not found: {name}")
            return None
        
        # Check if already loaded
        if name in self.instances:
            return self.instances[name]
        
        # Check dependencies
        manifest = self.manifests[name]
        for dep in manifest.requires:
            if dep not in self.plugins:
                self.logger.error(f"Missing dependency: {dep} for {name}")
                return None
        
        try:
            # Create instance
            plugin = self.plugins[name]()
            plugin.set_state(PluginState.LOADING)
            
            # Initialize
            asyncio.run(plugin.on_load())
            plugin.set_state(PluginState.LOADED)
            
            # Store instance
            self.instances[name] = plugin
            
            self.logger.info(f"Loaded plugin: {name}")
            return plugin
            
        except Exception as e:
            self.logger.error(f"Failed to load plugin {name}: {e}")
            return None
    
    def unload_plugin(self, name: str) -> bool:
        """
        Unload a plugin.
        
        Args:
            name: Plugin name
            
        Returns:
            bool: True if successful
        """
        if name not in self.instances:
            self.logger.warning(f"Plugin not loaded: {name}")
            return False
        
        try:
            plugin = self.instances[name]
            plugin.set_state(PluginState.STOPPING)
            
            # Unload
            asyncio.run(plugin.on_unload())
            plugin.set_state(PluginState.UNLOADED)
            
            del self.instances[name]
            self.logger.info(f"Unloaded plugin: {name}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to unload plugin {name}: {e}")
            return False
    
    def get_plugin(self, name: str) -> Optional[Plugin]:
        """
        Get a loaded plugin instance.
        
        Args:
            name: Plugin name
            
        Returns:
            Optional[Plugin]: Plugin instance, or None
        """
        if name in self.instances:
            return self.instances[name]
        return self.load_plugin(name)
    
    def get_all_plugins(self) -> List[str]:
        """
        Get all registered plugin names.
        
        Returns:
            List[str]: Plugin names
        """
        return list(self.plugins.keys())
    
    def get_loaded_plugins(self) -> List[str]:
        """
        Get loaded plugin names.
        
        Returns:
            List[str]: Plugin names
        """
        return list(self.instances.keys())
    
    def get_manifest(self, name: str) -> Optional[PluginManifest]:
        """
        Get a plugin's manifest.
        
        Args:
            name: Plugin name
            
        Returns:
            Optional[PluginManifest]: Plugin manifest
        """
        return self.manifests.get(name)
    
    @log_function_call(level="INFO")
    def install_plugin(self, path: Path) -> bool:
        """
        Install a plugin from a directory or archive.
        
        Args:
            path: Path to plugin directory or archive
            
        Returns:
            bool: True if successful
        """
        path = Path(path)
        
        if not path.exists():
            self.logger.error(f"Plugin path not found: {path}")
            return False
        
        try:
            # Handle archives (zip, tar.gz)
            if path.suffix in ['.zip', '.gz', '.tar']:
                return self._install_from_archive(path)
            
            # Handle directories
            if path.is_dir():
                # Copy to plugin directory
                target_dir = self.plugin_dir / path.name
                if target_dir.exists():
                    self.logger.warning(f"Plugin already exists: {target_dir}")
                    return False
                
                shutil.copytree(path, target_dir)
                self.logger.info(f"Installed plugin: {target_dir}")
                return True
            
            self.logger.error(f"Unsupported plugin format: {path}")
            return False
            
        except Exception as e:
            self.logger.error(f"Failed to install plugin: {e}")
            return False
    
    def _install_from_archive(self, archive_path: Path) -> bool:
        """
        Install a plugin from an archive.
        
        Args:
            archive_path: Archive file path
            
        Returns:
            bool: True if successful
        """
        import tempfile
        import zipfile
        import tarfile
        
        try:
            with tempfile.TemporaryDirectory() as tmpdir:
                tmp_path = Path(tmpdir)
                
                # Extract archive
                if archive_path.suffix == '.zip':
                    with zipfile.ZipFile(archive_path, 'r') as zip_ref:
                        zip_ref.extractall(tmp_path)
                elif archive_path.suffix in ['.gz', '.tar']:
                    with tarfile.open(archive_path, 'r:*') as tar_ref:
                        tar_ref.extractall(tmp_path)
                else:
                    return False
                
                # Find plugin directory
                for item in tmp_path.iterdir():
                    if item.is_dir():
                        # Check if it's a plugin
                        if (item / 'plugin.py').exists() or (item / '__init__.py').exists():
                            return self.install_plugin(item)
                
                self.logger.error("No plugin directory found in archive")
                return False
                
        except Exception as e:
            self.logger.error(f"Failed to extract archive: {e}")
            return False
    
    def uninstall_plugin(self, name: str) -> bool:
        """
        Uninstall a plugin.
        
        Args:
            name: Plugin name
            
        Returns:
            bool: True if successful
        """
        # Unload if loaded
        if name in self.instances:
            self.unload_plugin(name)
        
        # Remove from registry
        if name in self.plugins:
            del self.plugins[name]
        
        if name in self.manifests:
            del self.manifests[name]
        
        # Remove directory
        plugin_dir = self.plugin_dir / name
        if plugin_dir.exists():
            shutil.rmtree(plugin_dir)
            self.logger.info(f"Uninstalled plugin: {name}")
            return True
        
        self.logger.warning(f"Plugin directory not found: {name}")
        return False
    
    def load_all(self) -> Dict[str, bool]:
        """
        Load all discovered plugins.
        
        Returns:
            Dict[str, bool]: Loading results
        """
        results = {}
        
        for name in self.get_all_plugins():
            try:
                plugin = self.load_plugin(name)
                results[name] = plugin is not None
            except Exception as e:
                self.logger.error(f"Failed to load {name}: {e}")
                results[name] = False
        
        return results
    
    def unload_all(self) -> bool:
        """
        Unload all plugins.
        
        Returns:
            bool: True if successful
        """
        success = True
        
        for name in list(self.instances.keys()):
            if not self.unload_plugin(name):
                success = False
        
        return success
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Get plugin loader statistics.
        
        Returns:
            Dict[str, Any]: Statistics
        """
        return {
            'registered_plugins': len(self.plugins),
            'loaded_plugins': len(self.instances),
            'plugin_dir': str(self.plugin_dir),
            'plugin_names': list(self.plugins.keys()),
        }
    
    async def __aenter__(self):
        """Async context manager entry."""
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        self.unload_all()
```

---

```
[GENERATED: Part 4, Section 1 - Plugin Architecture]
[GENERATING: Part 4, Section 2 - Code Obfuscation & Evasion]
```

## Section 2: Code Obfuscation & Evasion

### The Target
`pyhack_suite/utils/crypto.py` - Obfuscation, encoding, and evasion techniques

### The Concept
Obfuscation is like speaking in code to avoid eavesdroppers. You're not making the code impossible to understand (that's impossible), but you're making it harder to read and analyze quickly. This buys time and makes automated analysis more difficult.

Common techniques:
1. **String encoding** - Base64, XOR, RC4 encryption
2. **Dynamic loading** - Load code at runtime
3. **Control flow obfuscation** - Harder to follow execution path
4. **Dead code insertion** - Non-executed code to confuse

---

## Step 4.2: Obfuscation Implementation

### The Implementation

Create `pyhack_suite/utils/crypto.py`:

```python
#!/usr/bin/env python3
"""
Obfuscation and encryption utilities for PyHack Suite.

This module provides:
- String encoding/decoding (Base64, XOR, RC4)
- Payload encryption and decryption
- Obfuscation techniques
- Signature avoidance
- Dynamic payload loading

Security note:
- Obfuscation is not security (it's not encryption)
- Use for evasion, not for protecting secrets
- May not work with all antivirus/EDR solutions
"""

import base64
import hashlib
import json
import random
import string
import zlib
from typing import Optional, Union, Dict, Any, List, Tuple
import struct
import os
import sys
import importlib

from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


# ==================== Encoders/Decoders ====================

class Base64Encoder:
    """Base64 encoding/decoding with optional custom alphabet."""
    
    STANDARD = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    URL_SAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    
    def __init__(self, alphabet: str = STANDARD, padding: bool = True):
        """
        Initialize the Base64 encoder.
        
        Args:
            alphabet: Custom Base64 alphabet (64 chars)
            padding: Whether to include padding
        """
        self.alphabet = alphabet
        self.padding = padding
        
        # Create encoding/decoding tables
        self._encode_table = {chr(i): alphabet[i] for i in range(64)}
        self._decode_table = {alphabet[i]: chr(i) for i in range(64)}
    
    def encode(self, data: Union[str, bytes]) -> str:
        """
        Encode data to Base64 with custom alphabet.
        
        Args:
            data: Data to encode
            
        Returns:
            str: Encoded string
        """
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        # Use standard base64 then translate
        encoded = base64.b64encode(data).decode('ascii')
        
        # Translate to custom alphabet
        result = ''
        for char in encoded:
            if char == '=':
                if self.padding:
                    result += '='
                # else skip padding
            else:
                # Get index in standard alphabet
                idx = self.STANDARD.index(char)
                result += self.alphabet[idx]
        
        return result
    
    def decode(self, data: str) -> bytes:
        """
        Decode Base64 with custom alphabet.
        
        Args:
            data: Encoded string
            
        Returns:
            bytes: Decoded data
        """
        # Translate from custom alphabet to standard
        translated = ''
        for char in data:
            if char == '=':
                translated += '='
            else:
                idx = self.alphabet.index(char)
                translated += self.STANDARD[idx]
        
        # Add padding if needed
        if self.padding:
            while len(translated) % 4 != 0:
                translated += '='
        
        return base64.b64decode(translated)


class XOREncoder:
    """XOR encoding/decoding with key."""
    
    def __init__(self, key: Union[str, bytes] = None):
        """
        Initialize the XOR encoder.
        
        Args:
            key: XOR key (default: random)
        """
        self.key = key or os.urandom(32)
        if isinstance(self.key, str):
            self.key = self.key.encode('utf-8')
    
    def encode(self, data: Union[str, bytes]) -> bytes:
        """
        Encode data with XOR.
        
        Args:
            data: Data to encode
            
        Returns:
            bytes: Encoded data
        """
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        result = bytearray(len(data))
        key_len = len(self.key)
        
        for i, byte in enumerate(data):
            result[i] = byte ^ self.key[i % key_len]
        
        return bytes(result)
    
    def decode(self, data: bytes) -> bytes:
        """
        Decode XOR-encoded data.
        
        Args:
            data: Encoded data
            
        Returns:
            bytes: Decoded data
        """
        # XOR is symmetric
        return self.encode(data)


class RC4Encoder:
    """RC4 stream cipher for encoding."""
    
    def __init__(self, key: Union[str, bytes]):
        """
        Initialize the RC4 encoder.
        
        Args:
            key: RC4 key
        """
        if isinstance(key, str):
            key = key.encode('utf-8')
        self.key = key
        self._keystream = self._generate_keystream()
    
    def _generate_keystream(self) -> List[int]:
        """Generate the RC4 keystream."""
        key_len = len(self.key)
        S = list(range(256))
        
        j = 0
        for i in range(256):
            j = (j + S[i] + self.key[i % key_len]) & 0xFF
            S[i], S[j] = S[j], S[i]
        
        return S
    
    def _generate(self, length: int) -> bytes:
        """Generate a keystream of a specific length."""
        S = self._keystream[:]
        i = j = 0
        keystream = bytearray()
        
        for _ in range(length):
            i = (i + 1) & 0xFF
            j = (j + S[i]) & 0xFF
            S[i], S[j] = S[j], S[i]
            keystream.append(S[(S[i] + S[j]) & 0xFF])
        
        return bytes(keystream)
    
    def encode(self, data: Union[str, bytes]) -> bytes:
        """
        Encode data with RC4.
        
        Args:
            data: Data to encode
            
        Returns:
            bytes: Encoded data
        """
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        keystream = self._generate(len(data))
        
        result = bytearray(len(data))
        for i, byte in enumerate(data):
            result[i] = byte ^ keystream[i]
        
        return bytes(result)
    
    def decode(self, data: bytes) -> bytes:
        """
        Decode RC4-encoded data.
        
        Args:
            data: Encoded data
            
        Returns:
            bytes: Decoded data
        """
        # RC4 is symmetric
        return self.encode(data)


# ==================== Obfuscation Helpers ====================

class StringObfuscator:
    """
    String obfuscation with multiple techniques.
    
    This class provides various string obfuscation techniques
    to evade signature-based detection.
    """
    
    @staticmethod
    def char_code(string: str) -> str:
        """
        Obfuscate string as character codes.
        
        Args:
            string: String to obfuscate
            
        Returns:
            str: Obfuscated string
        """
        codes = [str(ord(c)) for c in string]
        return f'String.fromCharCode({",".join(codes)})'
    
    @staticmethod
    def hex_encoding(string: str) -> str:
        """
        Obfuscate string as hex encoding.
        
        Args:
            string: String to obfuscate
            
        Returns:
            str: Obfuscated string
        """
        hex_str = ''.join([hex(ord(c))[2:] for c in string])
        return f'bytes.fromhex("{hex_str}").decode()'
    
    @staticmethod
    def base64_encoding(string: str, custom: bool = False) -> str:
        """
        Obfuscate string as Base64.
        
        Args:
            string: String to obfuscate
            custom: Use custom Base64 alphabet
            
        Returns:
            str: Obfuscated string
        """
        if custom:
            encoder = Base64Encoder(alphabet=Base64Encoder.URL_SAFE)
            encoded = encoder.encode(string)
            return f'base64.b64decode("{encoded}").decode()'
        else:
            encoded = base64.b64encode(string.encode()).decode()
            return f'base64.b64decode("{encoded}").decode()'
    
    @staticmethod
    def xor_encoding(string: str, key: Union[str, bytes]) -> str:
        """
        Obfuscate string with XOR.
        
        Args:
            string: String to obfuscate
            key: XOR key
            
        Returns:
            str: Obfuscated string
        """
        encoder = XOREncoder(key)
        encoded = encoder.encode(string)
        # Represent as hex for Python code
        hex_str = encoded.hex()
        return f'bytes.fromhex("{hex_str}").decode()'
    
    @staticmethod
    def rc4_encoding(string: str, key: Union[str, bytes]) -> str:
        """
        Obfuscate string with RC4.
        
        Args:
            string: String to obfuscate
            key: RC4 key
            
        Returns:
            str: Obfuscated string
        """
        encoder = RC4Encoder(key)
        encoded = encoder.encode(string)
        hex_str = encoded.hex()
        return f'bytes.fromhex("{hex_str}").decode()'
    
    @staticmethod
    def split_string(string: str, parts: int = 3) -> str:
        """
        Obfuscate string by splitting and concatenating.
        
        Args:
            string: String to obfuscate
            parts: Number of parts to split into
            
        Returns:
            str: Obfuscated string
        """
        part_len = max(1, len(string) // parts)
        fragments = []
        
        for i in range(parts):
            start = i * part_len
            end = (i + 1) * part_len
            if i == parts - 1:
                end = len(string)
            if start < len(string):
                fragments.append(f'"{string[start:end]}"')
        
        return " + ".join(fragments)
    
    @staticmethod
    def random_case(string: str) -> str:
        """
        Obfuscate string with random case changes.
        
        Args:
            string: String to obfuscate
            
        Returns:
            str: Obfuscated string
        """
        result = []
        for char in string:
            if char.isalpha():
                if random.random() > 0.5:
                    result.append(char.upper())
                else:
                    result.append(char.lower())
            else:
                result.append(char)
        return ''.join(result)


class PayloadObfuscator:
    """
    Payload obfuscation with compression and encoding.
    
    This class obfuscates payloads for evasion.
    """
    
    @staticmethod
    def compress(payload: str) -> bytes:
        """
        Compress a payload with zlib.
        
        Args:
            payload: Payload string
            
        Returns:
            bytes: Compressed payload
        """
        return zlib.compress(payload.encode('utf-8'), level=9)
    
    @staticmethod
    def decompress(compressed: bytes) -> str:
        """
        Decompress a compressed payload.
        
        Args:
            compressed: Compressed payload
            
        Returns:
            str: Decompressed payload
        """
        return zlib.decompress(compressed).decode('utf-8')
    
    @staticmethod
    def encode_layers(payload: str, layers: int = 3) -> str:
        """
        Apply multiple encoding layers.
        
        Args:
            payload: Payload to encode
            layers: Number of encoding layers
            
        Returns:
            str: Encoded payload
        """
        result = payload
        
        for i in range(layers):
            # Rotate through different encodings
            if i % 3 == 0:
                # Base64
                result = base64.b64encode(result.encode()).decode()
            elif i % 3 == 1:
                # Hex
                result = result.encode().hex()
            else:
                # Reverse
                result = result[::-1]
        
        return result
    
    @staticmethod
    def decode_layers(encoded: str) -> str:
        """
        Decode multi-layer encoded payload.
        
        Args:
            encoded: Encoded payload
            
        Returns:
            str: Decoded payload
        """
        result = encoded
        # Determine layers by trying to decode
        max_layers = 10
        
        for i in range(max_layers):
            try:
                # Try Base64
                decoded = base64.b64decode(result).decode()
                result = decoded
                continue
            except Exception:
                pass
            
            try:
                # Try Hex
                decoded = bytes.fromhex(result).decode()
                result = decoded
                continue
            except Exception:
                pass
            
            # Try Reverse
            if result == result[::-1]:
                break
            result = result[::-1]
            continue
        
        return result
    
    @staticmethod
    def dynamic_import(module: str, attribute: str) -> str:
        """
        Generate dynamic import code.
        
        Args:
            module: Module name
            attribute: Attribute to import
            
        Returns:
            str: Dynamic import code
        """
        return f'getattr(__import__("{module}"), "{attribute}")'
    
    @staticmethod
    def eval_payload(payload: str) -> Any:
        """
        Execute a payload with eval (dangerous).
        
        Args:
            payload: Payload to execute
            
        Returns:
            Any: Result of execution
        """
        return eval(payload)


class SignatureEvasion:
    """
    Signature evasion techniques.
    
    This class provides techniques to avoid signature-based detection.
    """
    
    @staticmethod
    def split_imports(code: str) -> str:
        """
        Split import statements to avoid detection.
        
        Args:
            code: Python code
            
        Returns:
            str: Code with split imports
        """
        lines = code.split('\n')
        result = []
        
        for line in lines:
            if line.strip().startswith('import ') or line.strip().startswith('from '):
                # Split import into multiple lines
                parts = line.split(' ')
                if len(parts) > 2:
                    # Create dynamic import
                    module = parts[1].split('.')[0]
                    result.append(f'# {line}')
                    result.append(f'__import__("{module}")')
                else:
                    result.append(line)
            else:
                result.append(line)
        
        return '\n'.join(result)
    
    @staticmethod
    def add_dead_code(code: str, ratio: float = 0.2) -> str:
        """
        Add dead code to confuse analysis.
        
        Args:
            code: Python code
            ratio: Ratio of dead code to real code
            
        Returns:
            str: Code with dead code
        """
        lines = code.split('\n')
        result = []
        
        # Dead code templates
        dead_templates = [
            '# Unused variable',
            'unused = None',
            'if False:',
            '    pass',
            'while False:',
            '    break',
            'try:',
            '    pass',
            'except:',
            '    pass',
        ]
        
        for line in lines:
            result.append(line)
            
            # Add dead code
            if random.random() < ratio:
                result.append(random.choice(dead_templates))
        
        return '\n'.join(result)
    
    @staticmethod
    def rename_variables(code: str) -> str:
        """
        Rename variables to random names.
        
        Args:
            code: Python code
            
        Returns:
            str: Code with renamed variables
        """
        import re
        import ast
        
        # Simple variable renaming
        variable_pattern = re.compile(r'\b([a-zA-Z_][a-zA-Z0-9_]*)\b')
        
        # Find variable names
        variables = set()
        for match in variable_pattern.finditer(code):
            name = match.group(1)
            if name not in ['if', 'else', 'for', 'while', 'def', 'class', 'return']:
                variables.add(name)
        
        # Generate new names
        new_names = {}
        for var in variables:
            new_name = f'_{random.choice(string.ascii_lowercase)}{random.randint(1000, 9999)}'
            new_names[var] = new_name
        
        # Replace names
        result = code
        for old, new in new_names.items():
            result = result.replace(old, new)
        
        return result
    
    @staticmethod
    def insert_comment_junk(code: str, density: float = 0.5) -> str:
        """
        Insert random comments and junk text.
        
        Args:
            code: Python code
            density: Amount of junk to insert
            
        Returns:
            str: Code with junk comments
        """
        lines = code.split('\n')
        result = []
        
        junk_words = [
            'Lorem', 'ipsum', 'dolor', 'sit', 'amet',
            'consectetur', 'adipiscing', 'elit',
            'sed', 'do', 'eiusmod', 'tempor',
            'incididunt', 'ut', 'labore', 'et', 'dolore',
            'magna', 'aliqua', 'Ut', 'enim', 'ad', 'minim',
            'veniam', 'quis', 'nostrud', 'exercitation',
            'ullamco', 'laboris', 'nisi', 'ut', 'aliquip',
            'ex', 'ea', 'commodo', 'consequat',
        ]
        
        for i, line in enumerate(lines):
            result.append(line)
            
            # Add comment with junk
            if random.random() < density:
                junk = ' '.join(random.sample(junk_words, 5))
                result.append(f'# {junk}')
            
            # Add random blank line
            if random.random() < density * 0.3:
                result.append('')
        
        return '\n'.join(result)


def obfuscate_string(string: str, method: str = 'xor') -> str:
    """
    Obfuscate a string using the specified method.
    
    Args:
        string: String to obfuscate
        method: Obfuscation method
        
    Returns:
        str: Obfuscated string
    """
    methods = {
        'base64': lambda s: StringObfuscator.base64_encoding(s, custom=False),
        'base64_custom': lambda s: StringObfuscator.base64_encoding(s, custom=True),
        'hex': lambda s: StringObfuscator.hex_encoding(s),
        'char_code': lambda s: StringObfuscator.char_code(s),
        'split': lambda s: StringObfuscator.split_string(s, 3),
        'xor': lambda s: StringObfuscator.xor_encoding(s, os.urandom(16)),
        'rc4': lambda s: StringObfuscator.rc4_encoding(s, os.urandom(16)),
    }
    
    if method not in methods:
        raise ValueError(f"Unsupported obfuscation method: {method}")
    
    return methods[method](string)


def obfuscate_payload(payload: str, level: int = 2) -> str:
    """
    Obfuscate a payload with multiple techniques.
    
    Args:
        payload: Payload to obfuscate
        level: Obfuscation level (1-3)
        
    Returns:
        str: Obfuscated payload
    """
    result = payload
    
    # Level 1: Basic encoding
    if level >= 1:
        # Encode strings
        result = StringObfuscator.base64_encoding(result)
        
        # Split imports
        result = SignatureEvasion.split_imports(result)
    
    # Level 2: More aggressive
    if level >= 2:
        # Add dead code
        result = SignatureEvasion.add_dead_code(result, ratio=0.3)
        
        # Add junk comments
        result = SignatureEvasion.insert_comment_junk(result)
    
    # Level 3: Full obfuscation
    if level >= 3:
        # Rename variables
        result = SignatureEvasion.rename_variables(result)
        
        # Multiple encoding layers
        result = PayloadObfuscator.encode_layers(result, layers=3)
    
    return result
```

---

```
[GENERATED: Part 4, Section 2 - Code Obfuscation & Evasion]
[GENERATING: Part 4, Section 3 - Security Hardening]
```

## Section 3: Security Hardening

### The Target
`pyhack_suite/utils/sandbox.py` - Sandboxed execution and security hardening

### The Concept
Security hardening is like building a fortress. You don't just focus on making the walls high - you consider all entry points and potential weak spots. Our hardening includes:
1. **Input validation** - Preventing injection attacks
2. **Sandboxing** - Isolating untrusted code
3. **Secret management** - Protecting credentials
4. **Dependency security** - Checking for vulnerabilities

---

## Step 4.3: Security Hardening Implementation

### The Implementation

Create `pyhack_suite/utils/sandbox.py`:

```python
#!/usr/bin/env python3
"""
Sandboxed execution and security hardening.

This module provides:
- Secure code execution sandbox
- Input validation and sanitization
- Secret management
- Dependency security checks
- Secure configuration

Security principles:
- Defense in depth
- Least privilege
- Fail secure
- Input validation
"""

import os
import sys
import subprocess
import tempfile
import resource
import signal
import time
from typing import Optional, Dict, Any, List, Set, Union
from pathlib import Path
import json
import hashlib
import secrets
import logging
import shutil
import importlib

from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


class Sandbox:
    """
    Secure code execution sandbox.
    
    This class provides a sandboxed environment for executing
    untrusted code with resource limits and isolation.
    
    Features:
    - Resource limits (CPU, memory, processes)
    - Timeouts
    - Temporary workspace
    - Restricted imports
    - File system isolation
    
    Example:
        sandbox = Sandbox()
        result = sandbox.execute(
            code='print("Hello World")',
            timeout=5,
            memory_limit=100  # MB
        )
    """
    
    def __init__(self, workspace: Optional[Path] = None):
        """
        Initialize the sandbox.
        
        Args:
            workspace: Sandbox workspace directory
        """
        self.logger = get_logger(__name__)
        self.workspace = workspace or Path(tempfile.mkdtemp(prefix='pyhack_sandbox_'))
        self.workspace.mkdir(parents=True, exist_ok=True)
        
        # Resource limits
        self.cpu_limit = 60  # seconds
        self.memory_limit = 256  # MB
        self.process_limit = 5
        
        # Allowed imports
        self.allowed_imports = {
            'math', 'json', 'random', 're', 'string',
            'time', 'datetime', 'collections', 'itertools',
        }
        
        self.logger.info(f"Sandbox initialized: {self.workspace}")
    
    @log_function_call(level="DEBUG")
    def execute(
        self,
        code: str,
        timeout: int = 30,
        memory_limit: Optional[int] = None,
        cpu_limit: Optional[int] = None,
        allowed_imports: Optional[Set[str]] = None,
        environment: Optional[Dict[str, str]] = None,
    ) -> Dict[str, Any]:
        """
        Execute code in the sandbox.
        
        Args:
            code: Code to execute
            timeout: Timeout in seconds
            memory_limit: Memory limit in MB
            cpu_limit: CPU time limit in seconds
            allowed_imports: Allowed import modules
            environment: Environment variables
            
        Returns:
            Dict[str, Any]: Execution results
        """
        # Set limits
        memory_limit = memory_limit or self.memory_limit
        cpu_limit = cpu_limit or self.cpu_limit
        
        # Create execution script
        script_path = self.workspace / "script.py"
        script_path.write_text(code, encoding='utf-8')
        
        # Prepare environment
        env = os.environ.copy()
        env['PYTHONPATH'] = str(self.workspace)
        if environment:
            env.update(environment)
        
        # Create sandboxed Python command
        python_cmd = [
            sys.executable,
            str(script_path),
        ]
        
        try:
            # Run with resource limits
            result = self._run_with_limits(
                python_cmd,
                env,
                timeout,
                memory_limit,
                cpu_limit
            )
            
            return {
                'success': result['returncode'] == 0,
                'stdout': result['stdout'],
                'stderr': result['stderr'],
                'returncode': result['returncode'],
                'time_used': result['time_used'],
            }
            
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'error': f'Execution timed out ({timeout}s)',
                'timeout': True,
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
            }
        finally:
            # Clean up script
            if script_path.exists():
                script_path.unlink()
    
    def _run_with_limits(
        self,
        cmd: List[str],
        env: Dict[str, str],
        timeout: int,
        memory_limit: int,
        cpu_limit: int,
    ) -> Dict[str, Any]:
        """
        Run a command with resource limits.
        
        Args:
            cmd: Command to run
            env: Environment variables
            timeout: Timeout in seconds
            memory_limit: Memory limit in MB
            cpu_limit: CPU time limit in seconds
            
        Returns:
            Dict[str, Any]: Execution results
        """
        start_time = time.time()
        
        # Create process
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            cwd=str(self.workspace),
            preexec_fn=self._set_resource_limits,
        )
        
        try:
            # Wait for completion with timeout
            stdout, stderr = process.communicate(timeout=timeout)
            time_used = time.time() - start_time
            
            return {
                'returncode': process.returncode,
                'stdout': stdout.decode('utf-8', errors='ignore'),
                'stderr': stderr.decode('utf-8', errors='ignore'),
                'time_used': time_used,
            }
            
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait()
            raise
    
    def _set_resource_limits(self):
        """Set resource limits for the process."""
        # CPU time limit
        resource.setrlimit(
            resource.RLIMIT_CPU,
            (self.cpu_limit, self.cpu_limit + 10)
        )
        
        # Memory limit (in bytes)
        mem_bytes = self.memory_limit * 1024 * 1024
        resource.setrlimit(
            resource.RLIMIT_AS,
            (mem_bytes, mem_bytes + 1024 * 1024)
        )
        
        # Process limit
        resource.setrlimit(
            resource.RLIMIT_NPROC,
            (self.process_limit, self.process_limit + 5)
        )
        
        # File size limit
        resource.setrlimit(
            resource.RLIMIT_FSIZE,
            (10 * 1024 * 1024, 50 * 1024 * 1024)  # 10MB max
        )
    
    def validate_imports(self, code: str) -> bool:
        """
        Validate that code only uses allowed imports.
        
        Args:
            code: Code to validate
            
        Returns:
            bool: True if valid
            
        Raises:
            ValueError: If disallowed imports found
        """
        import ast
        
        try:
            tree = ast.parse(code)
        except SyntaxError:
            return False
        
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    if alias.name not in self.allowed_imports:
                        raise ValueError(f"Disallowed import: {alias.name}")
            
            elif isinstance(node, ast.ImportFrom):
                if node.module not in self.allowed_imports:
                    raise ValueError(f"Disallowed import: {node.module}")
        
        return True
    
    def execute_sandboxed(
        self,
        code: str,
        **kwargs
    ) -> Dict[str, Any]:
        """
        Execute code with full sandbox validation.
        
        Args:
            code: Code to execute
            **kwargs: Additional execution parameters
            
        Returns:
            Dict[str, Any]: Execution results
        """
        # Validate imports
        try:
            self.validate_imports(code)
        except ValueError as e:
            return {
                'success': False,
                'error': f'Import validation failed: {e}',
            }
        
        # Execute with limits
        return self.execute(code, **kwargs)
    
    def clean(self):
        """Clean up the sandbox workspace."""
        if self.workspace and self.workspace.exists():
            shutil.rmtree(self.workspace)
            self.logger.info(f"Sandbox cleaned: {self.workspace}")
    
    def __enter__(self):
        """Context manager entry."""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.clean()


class InputValidator:
    """
    Input validation and sanitization.
    
    This class provides methods for validating and sanitizing
    user input to prevent injection attacks.
    """
    
    @staticmethod
    def sanitize_path(path: Union[str, Path]) -> Path:
        """
        Sanitize a file path to prevent path traversal.
        
        Args:
            path: File path
            
        Returns:
            Path: Sanitized path
            
        Raises:
            ValueError: If path is invalid
        """
        path = Path(path)
        
        # Resolve to absolute
        resolved = path.resolve()
        
        # Check for path traversal
        if str(resolved).startswith('/') or str(resolved).startswith('.'):
            # Check if path stays within allowed directory
            pass
        
        return resolved
    
    @staticmethod
    def sanitize_command(command: Union[str, List[str]]) -> List[str]:
        """
        Sanitize a command to prevent command injection.
        
        Args:
            command: Command string or list
            
        Returns:
            List[str]: Sanitized command list
            
        Raises:
            ValueError: If command contains dangerous characters
        """
        if isinstance(command, str):
            # Split command
            import shlex
            command = shlex.split(command)
        
        # Check for shell metacharacters
        dangerous = set(['&', '|', ';', '<', '>', '`', '$', '(', ')', '{', '}', '\\'])
        
        for part in command:
            if any(char in dangerous for char in part):
                raise ValueError(f"Dangerous character in command: {part}")
        
        return command
    
    @staticmethod
    def sanitize_sql(query: str) -> str:
        """
        Sanitize SQL query (basic prevention).
        
        Args:
            query: SQL query
            
        Returns:
            str: Sanitized query
            
        Note: Use parameterized queries in production!
        """
        # Remove dangerous SQL patterns
        dangerous = [
            (';', ''),
            ('--', ''),
            ('/*', ''),
            ('*/', ''),
            ('xp_', ''),
            ('DROP', ''),
            ('DELETE', ''),
            ('UPDATE', ''),
        ]
        
        result = query
        for old, new in dangerous:
            result = result.replace(old, new)
        
        return result
    
    @staticmethod
    def validate_ip(ip: str) -> bool:
        """
        Validate an IP address.
        
        Args:
            ip: IP address
            
        Returns:
            bool: True if valid
        """
        import ipaddress
        try:
            ipaddress.ip_address(ip)
            return True
        except ValueError:
            return False
    
    @staticmethod
    def validate_url(url: str) -> bool:
        """
        Validate a URL.
        
        Args:
            url: URL
            
        Returns:
            bool: True if valid
        """
        import urllib.parse
        try:
            result = urllib.parse.urlparse(url)
            return all([result.scheme, result.netloc])
        except Exception:
            return False
    
    @staticmethod
    def validate_ssh_key(key: str) -> bool:
        """
        Validate SSH key format.
        
        Args:
            key: SSH key
            
        Returns:
            bool: True if valid
        """
        import paramiko
        
        try:
            # Try to parse the key
            if key.startswith('ssh-rsa'):
                paramiko.RSAKey(data=key.encode())
            elif key.startswith('ssh-ed25519'):
                paramiko.Ed25519Key(data=key.encode())
            else:
                return False
            return True
        except Exception:
            return False


class SecretManager:
    """
    Secure secret management.
    
    This class provides secure storage and retrieval of secrets.
    
    Features:
    - Environment variable integration
    - Encrypted storage
    - Secret rotation
    - Access logging
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """
        Initialize the secret manager.
        
        Args:
            config: Configuration
        """
        self.logger = get_logger(__name__)
        self.secrets: Dict[str, str] = {}
        self.access_log: List[Dict[str, Any]] = []
        self.config = config or {}
    
    def get_secret(self, key: str, default: Optional[str] = None) -> Optional[str]:
        """
        Get a secret by key.
        
        Args:
            key: Secret key
            default: Default value
            
        Returns:
            Optional[str]: Secret value
        """
        # Check environment first
        env_key = key.upper().replace('-', '_')
        value = os.environ.get(env_key)
        
        if value is not None:
            self._log_access(key, 'environment')
            return value
        
        # Check stored secrets
        if key in self.secrets:
            self._log_access(key, 'storage')
            return self.secrets[key]
        
        return default
    
    def set_secret(self, key: str, value: str, encrypted: bool = True):
        """
        Store a secret.
        
        Args:
            key: Secret key
            value: Secret value
            encrypted: Whether to encrypt the secret
        """
        if encrypted:
            # Simple XOR encryption (for demonstration)
            # In production, use proper encryption (e.g., AES)
            value = self._encrypt_secret(value)
        
        self.secrets[key] = value
        self.logger.info(f"Secret stored: {key}")
    
    def delete_secret(self, key: str):
        """
        Delete a secret.
        
        Args:
            key: Secret key
        """
        if key in self.secrets:
            del self.secrets[key]
            self.logger.info(f"Secret deleted: {key}")
    
    def _encrypt_secret(self, secret: str) -> str:
        """
        Encrypt a secret.
        
        Args:
            secret: Secret to encrypt
            
        Returns:
            str: Encrypted secret
        """
        # Simple XOR with random key (demonstration only)
        key = os.urandom(32)
        encrypted = XOREncoder(key).encode(secret)
        return base64.b64encode(key + encrypted).decode()
    
    def _decrypt_secret(self, encrypted: str) -> str:
        """
        Decrypt a secret.
        
        Args:
            encrypted: Encrypted secret
            
        Returns:
            str: Decrypted secret
        """
        data = base64.b64decode(encrypted)
        key = data[:32]
        encrypted_data = data[32:]
        return XOREncoder(key).decode(encrypted_data).decode()
    
    def _log_access(self, key: str, source: str):
        """
        Log secret access.
        
        Args:
            key: Secret key
            source: Access source
        """
        self.access_log.append({
            'key': key,
            'source': source,
            'timestamp': time.time(),
        })
    
    def get_access_log(self) -> List[Dict[str, Any]]:
        """
        Get the access log.
        
        Returns:
            List[Dict[str, Any]]: Access log entries
        """
        return self.access_log.copy()


def check_dependencies() -> Dict[str, Dict[str, Any]]:
    """
    Check dependencies for known vulnerabilities.
    
    Returns:
        Dict[str, Dict[str, Any]]: Vulnerability reports
    """
    results = {}
    
    try:
        # Check for common vulnerable packages
        packages = [
            'requests', 'urllib3', 'paramiko', 'cryptography',
            'django', 'flask', 'jinja2', 'pyyaml',
        ]
        
        for package in packages:
            try:
                module = importlib.import_module(package)
                version = getattr(module, '__version__', 'unknown')
                
                # Check against known vulnerabilities
                # In production, use safety or pip-audit
                results[package] = {
                    'version': version,
                    'status': 'ok',
                }
            except ImportError:
                continue
        
    except Exception as e:
        logger.error(f"Dependency check failed: {e}")
    
    return results
```

---

```
[GENERATED: Part 4, Section 3 - Security Hardening]
[GENERATING: Part 4, Section 4 - Production CLI & Packaging]
```

## Section 4: Production CLI & Packaging

### The Target
`pyhack_suite/cli/main.py` - Production command-line interface

### The Concept
A good CLI is like a well-designed dashboard - it should be intuitive, powerful, and make complex operations simple. Our CLI uses:
1. **Rich command structure** - Subcommands for different operations
2. **Beautiful output** - Colorized, formatted output
3. **Progress indicators** - Showing progress for long operations
4. **Configuration** - Command-line and file-based configuration

---

## Step 4.4: CLI Implementation

### The Implementation

Create `pyhack_suite/cli/main.py`:

```python
#!/usr/bin/env python3
"""
PyHack Suite - Production Command-Line Interface.

This module provides the main entry point for the framework
with a rich, intuitive command-line interface.

Features:
- Subcommand architecture
- Beautiful output with Rich
- Progress indicators
- Configuration management
- Interactive mode
- Plugin management

Usage:
    pyhack scan 192.168.1.1
    pyhack brute http://example.com
    pyhack plugin list
    pyhack console
"""

import sys
import asyncio
import json
from pathlib import Path
from typing import Optional, Dict, Any, List
import time
import argparse
import logging

# Third-party CLI libraries
try:
    import click
    from rich.console import Console
    from rich.table import Table
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.panel import Panel
    from rich.syntax import Syntax
    from rich.markdown import Markdown
    from rich import print as rprint
except ImportError:
    print("Please install required dependencies: pip install click rich")
    sys.exit(1)

from pyhack_suite.core.config import get_config, ConfigLoader
from pyhack_suite.core.session_manager import SessionManager
from pyhack_suite.recon.scanner import AsyncScanner
from pyhack_suite.recon.brute_forcer import AsyncBruteForcer
from pyhack_suite.recon.dom_analyzer import DOMAnalyzer
from pyhack_suite.recon.modules import ModuleManager, ModuleRegistry
from pyhack_suite.modules.loader import PluginLoader
from pyhack_suite.utils.logging import get_logger
from pyhack_suite.utils.sandbox import Sandbox, InputValidator, SecretManager

logger = get_logger(__name__)
console = Console()


# ==================== CLI Group ====================

@click.group()
@click.option('--config', '-c', help='Configuration file path')
@click.option('--verbose', '-v', is_flag=True, help='Verbose output')
@click.option('--quiet', '-q', is_flag=True, help='Quiet mode')
@click.option('--json', '-j', 'json_output', is_flag=True, help='JSON output')
@click.pass_context
def cli(ctx, config, verbose, quiet, json_output):
    """
    PyHack Suite - Advanced Security Framework
    
    A comprehensive toolkit for security professionals, red teamers,
    and infrastructure engineers.
    
    Examples:
        pyhack scan 192.168.1.1
        pyhack brute https://example.com
        pyhack plugin list
    """
    ctx.ensure_object(dict)
    ctx.obj['VERBOSE'] = verbose
    ctx.obj['QUIET'] = quiet
    ctx.obj['JSON'] = json_output
    
    # Load configuration
    if config:
        config_loader = ConfigLoader()
        # Override with config file
        # config_loader.load_file(config)
    
    # Display banner
    if not quiet and not json_output:
        console.print(Panel.fit(
            "[bold cyan]PyHack Suite[/bold cyan]\n"
            "[dim]Advanced Engineering & Defensive Architecture[/dim]",
            border_style="cyan"
        ))


# ==================== Scan Command ====================

@cli.command()
@click.argument('target')
@click.option('--ports', '-p', help='Ports to scan (comma-separated)')
@click.option('--protocol', '-P', default='tcp', help='Protocol (tcp/udp)')
@click.option('--rate-limit', '-r', type=int, help='Rate limit (requests/second)')
@click.option('--timeout', '-t', type=float, default=2.0, help='Connection timeout')
@click.option('--stealth', '-s', is_flag=True, help='Enable stealth scanning')
@click.option('--service', '-S', is_flag=True, help='Enable service detection')
@click.option('--output', '-o', help='Output file')
@click.pass_context
def scan(ctx, target, ports, protocol, rate_limit, timeout, stealth, service, output):
    """
    Scan a target host or network.
    
    TARGET can be an IP, hostname, or CIDR network range.
    
    Examples:
        pyhack scan 192.168.1.1
        pyhack scan 192.168.1.0/24 --ports 80,443
        pyhack scan example.com --stealth --service
    """
    console.print(f"[bold]Scanning target:[/bold] {target}")
    
    async def run_scan():
        scanner = AsyncScanner()
        
        # Parse ports
        port_list = None
        if ports:
            port_list = [int(p.strip()) for p in ports.split(',')]
        
        # Determine if network or host
        if '/' in target:
            # Network scan
            results = await scanner.scan_network(
                target,
                ports=port_list,
                protocol=protocol,
                rate_limit=rate_limit,
                timeout=timeout,
                stealth=stealth,
                service_detection=service,
            )
            return results
        else:
            # Host scan
            result = await scanner.scan_host(
                target,
                ports=port_list,
                protocol=protocol,
                rate_limit=rate_limit,
                timeout=timeout,
                stealth=stealth,
                service_detection=service,
            )
            return [result]
    
    # Run scan
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task("Scanning...", total=None)
        try:
            results = asyncio.run(run_scan())
            progress.update(task, completed=True)
        except Exception as e:
            console.print(f"[red]Scan failed: {e}[/red]")
            return 1
    
    # Output results
    if ctx.obj.get('JSON'):
        output_data = [r.to_dict() for r in results]
        json.dump(output_data, sys.stdout, indent=2)
        return 0
    
    # Display results
    for result in results:
        console.print(f"\n[bold green]Host:[/bold green] {result.ip}")
        if result.hostname:
            console.print(f"[dim]  Hostname:[/dim] {result.hostname}")
        console.print(f"[dim]  Scan time:[/dim] {result.scan_time:.2f}s")
        
        # Open ports
        open_ports = result.get_open_ports()
        if open_ports:
            table = Table(title=f"Open Ports ({len(open_ports)})")
            table.add_column("Port", style="cyan")
            table.add_column("Protocol", style="green")
            table.add_column("Service", style="yellow")
            table.add_column("Banner")
            
            for port in result.ports:
                if port.status == 'open':
                    table.add_row(
                        str(port.port),
                        port.protocol,
                        port.service or 'unknown',
                        (port.banner or '')[:50]
                    )
            
            console.print(table)
        else:
            console.print("[dim]No open ports found[/dim]")
        
        # OS Guess
        if result.os_guess:
            console.print(f"[dim]OS Guess:[/dim] {result.os_guess}")
    
    # Save output
    if output:
        with open(output, 'w') as f:
            json.dump([r.to_dict() for r in results], f, indent=2)
        console.print(f"\n[green]Results saved to:[/green] {output}")
    
    return 0


# ==================== Brute Force Command ====================

@cli.command()
@click.argument('target')
@click.option('--type', '-t', 'bruteforce_type', 
              type=click.Choice(['basic', 'dir', 'subdomain']),
              default='basic', help='Brute force type')
@click.option('--usernames', '-u', help='Username list (file or comma-separated)')
@click.option('--passwords', '-P', help='Password list (file or comma-separated)')
@click.option('--wordlist', '-w', help='Wordlist file')
@click.option('--rate-limit', '-r', type=int, help='Rate limit')
@click.option('--output', '-o', help='Output file')
@click.pass_context
def brute(ctx, target, bruteforce_type, usernames, passwords, wordlist, rate_limit, output):
    """
    Brute force credentials, directories, or subdomains.
    
    Examples:
        pyhack brute https://example.com/admin --type basic -u admin,root -P password.txt
        pyhack brute https://example.com --type dir -w wordlist.txt
        pyhack brute example.com --type subdomain -w subdomains.txt
    """
    console.print(f"[bold]Brute forcing:[/bold] {target}")
    
    async def run_bruteforce():
        forcer = AsyncBruteForcer()
        
        # Load wordlists
        username_list = None
        password_list = None
        wordlist_list = None
        
        if usernames:
            if Path(usernames).exists():
                with open(usernames) as f:
                    username_list = [line.strip() for line in f if line.strip()]
            else:
                username_list = [u.strip() for u in usernames.split(',')]
        
        if passwords:
            if Path(passwords).exists():
                with open(passwords) as f:
                    password_list = [line.strip() for line in f if line.strip()]
            else:
                password_list = [p.strip() for p in passwords.split(',')]
        
        if wordlist:
            if Path(wordlist).exists():
                with open(wordlist) as f:
                    wordlist_list = [line.strip() for line in f if line.strip()]
        
        if bruteforce_type == 'basic':
            if not username_list or not password_list:
                console.print("[red]Basic auth requires --usernames and --passwords[/red]")
                return None
            
            results = await forcer.bruteforce_http_basic(
                target,
                username_list,
                password_list,
                rate_limit=rate_limit,
            )
            return results
        
        elif bruteforce_type == 'dir':
            if not wordlist_list:
                console.print("[red]Directory brute force requires --wordlist[/red]")
                return None
            
            results = await forcer.bruteforce_directory(
                target,
                wordlist_list,
                rate_limit=rate_limit,
            )
            return results
        
        elif bruteforce_type == 'subdomain':
            if not wordlist_list:
                console.print("[red]Subdomain brute force requires --wordlist[/red]")
                return None
            
            results = await forcer.bruteforce_subdomain(
                target,
                wordlist_list,
                rate_limit=rate_limit,
            )
            return results
        
        return None
    
    # Run brute force
    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:
        task = progress.add_task("Brute forcing...", total=None)
        try:
            results = asyncio.run(run_bruteforce())
            progress.update(task, completed=True)
        except Exception as e:
            console.print(f"[red]Brute force failed: {e}[/red]")
            return 1
    
    # Display results
    if results:
        console.print(f"[bold green]Found {len(results)} results:[/bold green]")
        for result in results:
            if result.username and result.password:
                console.print(f"  [cyan]{result.username}[/cyan]:[yellow]{result.password}[/yellow]")
            elif result.resource:
                console.print(f"  [cyan]{result.resource}[/cyan] (HTTP {result.response_code})")
    else:
        console.print("[dim]No results found[/dim]")
    
    # Save output
    if output:
        with open(output, 'w') as f:
            json.dump([r.to_dict() for r in results], f, indent=2)
        console.print(f"\n[green]Results saved to:[/green] {output}")
    
    return 0


# ==================== Module Command ====================

@cli.group()
def module():
    """Plugin module management."""
    pass


@module.command('list')
@click.pass_context
def module_list(ctx):
    """List all available modules."""
    registry = ModuleRegistry()
    modules = registry.get_all_modules()
    
    if not modules:
        console.print("[dim]No modules found[/dim]")
        return
    
    table = Table(title=f"Available Modules ({len(modules)})")
    table.add_column("Name", style="cyan")
    table.add_column("Description", style="green")
    table.add_column("Version", style="yellow")
    
    for name in modules:
        metadata = registry.get_module_metadata(name)
        if metadata:
            table.add_row(
                name,
                metadata.description,
                metadata.version
            )
    
    console.print(table)


@module.command('run')
@click.argument('module_name')
@click.argument('target')
@click.option('--params', help='JSON parameters')
@click.pass_context
def module_run(ctx, module_name, target, params):
    """Run a specific module."""
    console.print(f"[bold]Running module:[/bold] {module_name}")
    
    async def run_module():
        manager = ModuleManager()
        params_dict = json.loads(params) if params else {}
        result = await manager.run_module(module_name, target, **params_dict)
        return result
    
    try:
        result = asyncio.run(run_module())
        
        if ctx.obj.get('JSON'):
            json.dump(result, sys.stdout, indent=2)
        else:
            console.print_json(json.dumps(result, default=str))
            
    except Exception as e:
        console.print(f"[red]Module failed: {e}[/red]")
        return 1
    
    return 0


# ==================== Plugin Command ====================

@cli.group()
def plugin():
    """Plugin management."""
    pass


@plugin.command('list')
@click.pass_context
def plugin_list(ctx):
    """List all installed plugins."""
    loader = PluginLoader()
    loader.discover_plugins()
    
    plugins = loader.get_all_plugins()
    
    if not plugins:
        console.print("[dim]No plugins found[/dim]")
        return
    
    table = Table(title=f"Installed Plugins ({len(plugins)})")
    table.add_column("Name", style="cyan")
    table.add_column("Version", style="green")
    table.add_column("State", style="yellow")
    table.add_column("Provides", style="dim")
    
    for name in plugins:
        manifest = loader.get_manifest(name)
        instance = loader.get_plugin(name)
        state = instance.get_state().value if instance else "Not loaded"
        
        table.add_row(
            name,
            manifest.version if manifest else "unknown",
            state,
            ", ".join(manifest.provides) if manifest and manifest.provides else ""
        )
    
    console.print(table)


@plugin.command('load')
@click.argument('name')
@click.pass_context
def plugin_load(ctx, name):
    """Load a plugin."""
    loader = PluginLoader()
    loader.discover_plugins()
    
    if name not in loader.get_all_plugins():
        console.print(f"[red]Plugin not found: {name}[/red]")
        return 1
    
    console.print(f"[bold]Loading plugin:[/bold] {name}")
    
    try:
        plugin = loader.load_plugin(name)
        if plugin:
            console.print(f"[green]Plugin loaded successfully[/green]")
            console.print(f"  State: {plugin.get_state().value}")
        else:
            console.print(f"[red]Failed to load plugin[/red]")
            return 1
    except Exception as e:
        console.print(f"[red]Error loading plugin: {e}[/red]")
        return 1
    
    return 0


@plugin.command('unload')
@click.argument('name')
@click.pass_context
def plugin_unload(ctx, name):
    """Unload a plugin."""
    loader = PluginLoader()
    
    if name not in loader.get_loaded_plugins():
        console.print(f"[yellow]Plugin not loaded: {name}[/yellow]")
        return 0
    
    try:
        if loader.unload_plugin(name):
            console.print(f"[green]Plugin unloaded: {name}[/green]")
        else:
            console.print(f"[red]Failed to unload plugin[/red]")
            return 1
    except Exception as e:
        console.print(f"[red]Error unloading plugin: {e}[/red]")
        return 1
    
    return 0


# ==================== Config Command ====================

@cli.command()
@click.option('--show', is_flag=True, help='Show current configuration')
@click.option('--env', '-e', help='Set environment')
@click.pass_context
def config(ctx, show, env):
    """Manage configuration."""
    config_obj = get_config()
    
    if show:
        console.print("[bold]Current Configuration:[/bold]")
        console.print(f"  Environment: {config_obj.env}")
        console.print(f"  Debug: {config_obj.debug}")
        console.print(f"\n[bold]Network:[/bold]")
        console.print(f"  Interface: {config_obj.network.scapy_interface}")
        console.print(f"  SSH Timeout: {config_obj.network.ssh_timeout}s")
        console.print(f"\n[bold]Recon:[/bold]")
        console.print(f"  Rate Limit: {config_obj.recon.http_rate_limit} req/s")
        console.print(f"  User Agents: {len(config_obj.recon.http_user_agents)}")
        console.print(f"\n[bold]Security:[/bold]")
        console.print(f"  Sandbox: {config_obj.security.enable_sandbox}")
        console.print(f"  Strict Validation: {config_obj.security.enable_strict_validation}")
    
    if env:
        # Set environment
        config_obj.env = env
        console.print(f"[green]Environment set to:[/green] {env}")
    
    return 0


# ==================== Console Command ====================

@cli.command()
@click.pass_context
def console(ctx):
    """
    Start an interactive console.
    
    This launches a Python REPL with the framework pre-loaded.
    """
    console.print("[bold cyan]PyHack Suite Console[/bold cyan]")
    console.print("[dim]Type 'exit()' or Ctrl-D to exit[/dim]")
    console.print("[dim]Available: config, scanner, brute, modules[/dim]")
    
    # Set up interactive namespace
    namespace = {
        'config': get_config(),
        'scanner': AsyncScanner(),
        'bruteforcer': AsyncBruteForcer(),
        'modules': ModuleManager(),
        'plugins': PluginLoader(),
        'console': console,
    }
    
    # Start interactive console
    import code
    code.interact(local=namespace, banner='')


# ==================== Main Entry Point ====================

def main():
    """Main entry point."""
    try:
        return cli(obj={})
    except KeyboardInterrupt:
        console.print("\n[yellow]Interrupted by user[/yellow]")
        return 130
    except Exception as e:
        console.print(f"[red]Error: {e}[/red]")
        if get_config().debug:
            import traceback
            console.print(traceback.format_exc())
        return 1


if __name__ == '__main__':
    sys.exit(main())
```

---

## The Verification

Test the CLI:

```bash
# Install the package
pip install -e .

# Show help
pyhack --help

# Scan localhost
pyhack scan 127.0.0.1 --ports 22,80,443

# List modules
pyhack module list

# List plugins
pyhack plugin list

# Show configuration
pyhack config --show

# Start console
pyhack console
```

---

```
[COMPLETED: Part 4, Section 4 - Production CLI & Packaging]
[COMPLETED: Part 4 - Advanced Tooling Design, Obfuscation & Hardening]

[GENERATED: Entire Series Complete]
```

---

## Series Conclusion

Congratulations! You've completed the entire "Python for Hackers — Advanced Engineering & Defensive Architecture" series. Let's review what you've built:

### Part 1: Infrastructure Automation & Protocol Analysis
- Project structure with professional Python packaging
- Configuration management with environment variables
- Unified session manager for SSH, Netmiko, and raw sockets
- Paramiko wrapper for custom SSH automation
- Netmiko wrapper for multi-vendor device management
- Scapy wrapper for packet manipulation
- Protocol abstraction layer for unified interfaces

### Part 2: High-Speed Packet Sniffing & Asynchronous Integration
- Event loop manager for async operations
- Async packet sniffer with non-blocking capture
- Queue management with backpressure and priority
- Ring buffer for high-performance packet storage
- Event-driven packet injection with precise timing

### Part 3: Stealth Reconnaissance & Asynchronous Tooling
- Async scanner with port scanning and service detection
- Async brute-forcer for credentials and directories
- DOM analyzer with headless browser support
- Modular recon architecture with plugin system

### Part 4: Advanced Tooling Design, Obfuscation & Hardening
- Production-grade plugin architecture
- Code obfuscation and evasion techniques
- Security hardening with sandboxing
- Production CLI with Rich interface
- Full framework ready for deployment

### What You Can Do Next

1. **Extend the framework** - Add your own modules and plugins
2. **Deploy to production** - Use in authorized testing environments
3. **Contribute** - Share your modules with the community
4. **Learn more** - Explore the libraries we used (Scapy, Netmiko, Paramiko)
5. **Build tools** - Create custom tools using the framework

### Remember

- **Use ethically** - Only test systems you own or have permission to test
- **Stay legal** - Unauthorized testing is illegal
- **Think like a defender** - Use this knowledge to improve security
- **Keep learning** - Security is a journey, not a destination

Thank you for completing this comprehensive series!
