# Part 1: Infrastructure Automation & Protocol Analysis

## Section 1: Project Structure & Foundation

### The Target
Setting up our complete PyHack Suite project structure with proper Python packaging, configuration management, and development tooling.

### The Concept
Before we can build anything, we need a solid foundation. Think of this as laying the concrete slab for a house—if it's not level and well-constructed, everything built on top will be unstable. We'll create a professional Python project with:
- Proper package structure for imports
- Environment variable management for secrets
- Centralized configuration
- Development tooling (formatting, linting, type checking)

---

## Step 1.1: Project Directory Structure

### The Implementation

Create the following directory structure. I'll show you the complete tree, then we'll build each file.

```bash
# Create all directories
mkdir -p pyhack_suite/{core,network,recon,modules,utils,cli}
mkdir -p pyhack_suite/modules/examples
mkdir -p tests
mkdir -p scripts
mkdir -p docs
mkdir -p .github/workflows
mkdir -p logs
mkdir -p data

# Create empty __init__.py files to make Python packages
touch pyhack_suite/__init__.py
touch pyhack_suite/core/__init__.py
touch pyhack_suite/network/__init__.py
touch pyhack_suite/recon/__init__.py
touch pyhack_suite/modules/__init__.py
touch pyhack_suite/utils/__init__.py
touch pyhack_suite/cli/__init__.py
```

### Complete Project Tree
```
pyhack_suite/
├── pyhack_suite/                 # Main package
│   ├── __init__.py               # Package initialization
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py             # Configuration management
│   │   ├── session_manager.py    # Unified connections
│   │   └── event_loop.py         # Async event management
│   ├── network/
│   │   ├── __init__.py
│   │   ├── packet_handler.py     # Scapy integration
│   │   ├── device_automation.py  # Netmiko/Paramiko
│   │   └── protocol_abstractions.py
│   ├── recon/
│   │   ├── __init__.py
│   │   ├── scanner.py
│   │   ├── brute_forcer.py
│   │   ├── dom_analyzer.py
│   │   └── evasion.py
│   ├── modules/
│   │   ├── __init__.py
│   │   ├── loader.py
│   │   ├── base.py
│   │   └── examples/
│   │       ├── __init__.py
│   │       └── example_module.py
│   ├── utils/
│   │   ├── __init__.py
│   │   ├── crypto.py
│   │   ├── logging.py
│   │   ├── validators.py
│   │   └── sandbox.py
│   └── cli/
│       ├── __init__.py
│       └── main.py
├── tests/                        # Unit and integration tests
│   ├── __init__.py
│   ├── test_core/
│   ├── test_network/
│   └── test_recon/
├── scripts/                      # Utility scripts
│   ├── setup_dev.sh
│   └── run_tests.py
├── docs/                         # Documentation
│   └── architecture.md
├── logs/                         # Runtime logs
│   └── .gitkeep
├── data/                         # Data files (wordlists, configs)
│   └── .gitkeep
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore file
├── .pre-commit-config.yaml       # Pre-commit hooks
├── pyproject.toml                # Modern Python project config
├── setup.py                      # Package setup (backward compatibility)
├── requirements.txt              # Production dependencies
├── requirements-dev.txt          # Development dependencies
├── README.md                     # Project documentation
├── LICENSE                       # License file
├── Makefile                      # Common task automation
└── Dockerfile                    # Containerization
```

---

## Step 1.2: Configuration Management

### The Target
`pyhack_suite/core/config.py` - Centralized configuration management with environment variable support

### The Concept
Configuration management is like the control panel for your application. Instead of hardcoding values (which is insecure and inflexible), we'll use environment variables with sensible defaults. This approach:
- **Separates code from configuration** - Changes don't require code changes
- **Secures secrets** - API keys, passwords stored in environment variables
- **Enables different environments** - Development vs. production settings

### The Implementation

Create `pyhack_suite/core/config.py`:

```python
#!/usr/bin/env python3
"""
Configuration management for PyHack Suite.

This module provides a centralized configuration system that loads settings
from environment variables with sensible defaults. It follows the
"configuration as code" pattern where settings are validated at startup.

Why this approach?
- Environment variables are the standard for 12-factor apps
- Secrets never hardcoded in source code
- Easy to override for different environments (dev, test, prod)
- Type validation prevents runtime errors
"""

import os
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, Dict, Any, List
import logging
from dotenv import load_dotenv  # python-dotenv

# Set up module-level logger
logger = logging.getLogger(__name__)


@dataclass
class NetworkConfig:
    """Network-related configuration settings."""
    
    # Scapy settings
    scapy_interface: str = field(default="eth0")
    """Default network interface for packet operations."""
    
    scapy_buffer_size: int = field(default=65535)
    """Buffer size for packet capture (MTU typically 1500, but 65535 captures everything)."""
    
    scapy_promiscuous: bool = field(default=True)
    """Enable promiscuous mode to capture all packets on the network."""
    
    # Connection timeouts
    ssh_timeout: int = field(default=10)
    """SSH connection timeout in seconds."""
    
    netmiko_timeout: int = field(default=30)
    """Netmiko device connection timeout in seconds."""
    
    # Packet sniffing
    sniff_timeout: int = field(default=60)
    """Default timeout for packet sniffing operations."""
    
    max_packet_queue: int = field(default=10000)
    """Maximum number of packets to queue before dropping (backpressure handling)."""
    
    # Device automation
    device_auth_retries: int = field(default=3)
    """Number of authentication retries for device connections."""
    
    def __post_init__(self):
        """Validate network configuration after initialization."""
        if self.scapy_buffer_size < 1500:
            logger.warning(
                f"Buffer size {self.scapy_buffer_size} is less than MTU (1500). "
                "Some packets may be truncated."
            )
        if self.max_packet_queue < 100:
            logger.warning(
                f"Packet queue size {self.max_packet_queue} is very small. "
                "Consider increasing for high-volume networks."
            )


@dataclass
class ReconConfig:
    """Reconnaissance and scanning configuration."""
    
    # HTTP settings
    http_timeout: float = field(default=10.0)
    """HTTP request timeout in seconds."""
    
    http_max_connections: int = field(default=100)
    """Maximum concurrent HTTP connections."""
    
    http_rate_limit: int = field(default=50)
    """Maximum requests per second (evasion)."""
    
    http_user_agents: List[str] = field(default_factory=lambda: [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15",
    ])
    """Common user agents for rotation to avoid detection."""
    
    # Scanning
    default_ports: List[int] = field(default_factory=lambda: [21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1723, 3306, 3389, 5900, 8080])
    """Common ports to scan by default."""
    
    scan_timeout: float = field(default=2.0)
    """Per-port scan timeout in seconds."""
    
    # Brute forcing
    brute_force_delay: float = field(default=0.5)
    """Delay between brute force attempts to avoid lockout."""
    
    wordlist_path: Optional[Path] = field(default=None)
    """Path to wordlist file for brute forcing."""
    
    # Evasion
    jitter_range: tuple = field(default=(0.0, 0.5))
    """Random delay range (min, max) in seconds to add to requests."""
    
    def __post_init__(self):
        """Validate reconnaissance configuration."""
        if self.http_rate_limit <= 0:
            raise ValueError("HTTP rate limit must be greater than 0")
        if self.http_max_connections <= 0:
            raise ValueError("Max connections must be greater than 0")
        if self.brute_force_delay < 0:
            raise ValueError("Brute force delay cannot be negative")


@dataclass
class SecurityConfig:
    """Security and hardening configuration."""
    
    # Encryption
    encryption_key: Optional[str] = field(default=None)
    """Master encryption key (loaded from environment)."""
    
    secret_key: Optional[str] = field(default=None)
    """Secret key for signing and verification."""
    
    # Sandboxing
    enable_sandbox: bool = field(default=True)
    """Enable sandboxed execution for untrusted modules."""
    
    sandbox_path: Optional[Path] = field(default=None)
    """Path for sandbox file system."""
    
    # Input validation
    enable_strict_validation: bool = field(default=True)
    """Enable strict input validation to prevent injection attacks."""
    
    # Logging
    redact_sensitive_data: bool = field(default=True)
    """Redact passwords, tokens, and other sensitive data from logs."""
    
    def __post_init__(self):
        """Validate security configuration."""
        # Ensure encryption keys are loaded from environment (not hardcoded)
        if self.encryption_key and len(self.encryption_key) < 32:
            logger.warning(
                "Encryption key is less than 32 characters. "
                "Consider using a longer key for better security."
            )
        if self.secret_key and len(self.secret_key) < 16:
            logger.warning(
                "Secret key is less than 16 characters. "
                "Consider using a longer key for better security."
            )


@dataclass
class LoggingConfig:
    """Logging configuration."""
    
    level: str = field(default="INFO")
    """Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)."""
    
    format: str = field(default="%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    """Log message format."""
    
    file_path: Optional[Path] = field(default=Path("logs/pyhack.log"))
    """Path to log file."""
    
    max_file_size: int = field(default=10485760)  # 10 MB
    """Maximum log file size before rotation."""
    
    backup_count: int = field(default=5)
    """Number of backup log files to keep."""
    
    # Console logging
    console_enabled: bool = field(default=True)
    """Enable console logging."""
    
    # Structured logging (JSON format for log aggregation)
    structured: bool = field(default=False)
    """Enable structured JSON logging for production."""

    def __post_init__(self):
        """Validate logging configuration."""
        valid_levels = ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]
        if self.level.upper() not in valid_levels:
            raise ValueError(f"Invalid log level. Must be one of: {valid_levels}")


@dataclass
class AppConfig:
    """Main application configuration."""
    
    # Environment
    env: str = field(default="development")
    """Current environment (development, testing, production)."""
    
    debug: bool = field(default=True)
    """Enable debug mode."""
    
    # Sub-configurations
    network: NetworkConfig = field(default_factory=NetworkConfig)
    recon: ReconConfig = field(default_factory=ReconConfig)
    security: SecurityConfig = field(default_factory=SecurityConfig)
    logging: LoggingConfig = field(default_factory=LoggingConfig)
    
    # Application paths
    project_root: Path = field(default_factory=lambda: Path(__file__).parent.parent.parent)
    """Root directory of the project."""
    
    data_dir: Path = field(default_factory=lambda: Path(__file__).parent.parent.parent / "data")
    """Directory for data files (wordlists, configs)."""
    
    logs_dir: Path = field(default_factory=lambda: Path(__file__).parent.parent.parent / "logs")
    """Directory for log files."""
    
    modules_dir: Path = field(default_factory=lambda: Path(__file__).parent.parent.parent / "modules")
    """Directory for plugin modules."""
    
    def __post_init__(self):
        """Initialize application configuration."""
        # Create necessary directories if they don't exist
        self.data_dir.mkdir(parents=True, exist_ok=True)
        self.logs_dir.mkdir(parents=True, exist_ok=True)
        self.modules_dir.mkdir(parents=True, exist_ok=True)
        
        # Set logging level based on debug mode
        if self.debug and self.logging.level.upper() not in ["DEBUG", "INFO"]:
            # Override if debug is True but logging level is higher than INFO
            logger.info("Debug mode enabled, setting log level to DEBUG")
            self.logging.level = "DEBUG"


class ConfigLoader:
    """
    Configuration loader that loads settings from environment variables.
    
    This class follows the Singleton pattern to ensure only one configuration
    instance exists throughout the application.
    """
    
    _instance = None
    _config = None
    
    def __new__(cls):
        """Implement Singleton pattern."""
        if cls._instance is None:
            cls._instance = super(ConfigLoader, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize the configuration loader."""
        if hasattr(self, '_initialized') and self._initialized:
            return
        self._initialized = True
        
        # Load environment variables from .env file
        env_file = Path(__file__).parent.parent.parent / ".env"
        if env_file.exists():
            load_dotenv(env_file)
            logger.info(f"Loaded environment from {env_file}")
        else:
            # Try .env.example if .env doesn't exist
            env_example = Path(__file__).parent.parent.parent / ".env.example"
            if env_example.exists():
                logger.info(f"No .env file found. Example available at {env_example}")
        
        # Build configuration from environment variables
        self._config = self._load_from_environment()
    
    def _load_from_environment(self) -> AppConfig:
        """Load configuration from environment variables."""
        # Network configuration
        network_config = NetworkConfig(
            scapy_interface=os.getenv("SCAPY_INTERFACE", "eth0"),
            scapy_buffer_size=int(os.getenv("SCAPY_BUFFER_SIZE", "65535")),
            scapy_promiscuous=os.getenv("SCAPY_PROMISCUOUS", "true").lower() == "true",
            ssh_timeout=int(os.getenv("SSH_TIMEOUT", "10")),
            netmiko_timeout=int(os.getenv("NETMIKO_TIMEOUT", "30")),
            sniff_timeout=int(os.getenv("SNIFF_TIMEOUT", "60")),
            max_packet_queue=int(os.getenv("MAX_PACKET_QUEUE", "10000")),
            device_auth_retries=int(os.getenv("DEVICE_AUTH_RETRIES", "3")),
        )
        
        # Reconnaissance configuration
        user_agents = os.getenv("HTTP_USER_AGENTS", "").split(",")
        if not user_agents or user_agents == [""]:
            # Use defaults if not provided
            user_agents = [
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
                "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
                "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15",
            ]
        
        # Parse port list from environment
        ports_str = os.getenv("DEFAULT_PORTS", "")
        default_ports = [int(p.strip()) for p in ports_str.split(",") if p.strip()] if ports_str else None
        
        recon_config = ReconConfig(
            http_timeout=float(os.getenv("HTTP_TIMEOUT", "10.0")),
            http_max_connections=int(os.getenv("HTTP_MAX_CONNECTIONS", "100")),
            http_rate_limit=int(os.getenv("HTTP_RATE_LIMIT", "50")),
            http_user_agents=user_agents,
            default_ports=default_ports or ReconConfig.default_ports,
            scan_timeout=float(os.getenv("SCAN_TIMEOUT", "2.0")),
            brute_force_delay=float(os.getenv("BRUTE_FORCE_DELAY", "0.5")),
            wordlist_path=Path(os.getenv("WORDLIST_PATH", "data/wordlists/common.txt")) if os.getenv("WORDLIST_PATH") else None,
            jitter_range=(
                float(os.getenv("JITTER_MIN", "0.0")),
                float(os.getenv("JITTER_MAX", "0.5")),
            ),
        )
        
        # Security configuration
        security_config = SecurityConfig(
            encryption_key=os.getenv("ENCRYPTION_KEY", None),
            secret_key=os.getenv("SECRET_KEY", None),
            enable_sandbox=os.getenv("ENABLE_SANDBOX", "true").lower() == "true",
            sandbox_path=Path(os.getenv("SANDBOX_PATH", "/tmp/pyhack_sandbox")) if os.getenv("SANDBOX_PATH") else None,
            enable_strict_validation=os.getenv("ENABLE_STRICT_VALIDATION", "true").lower() == "true",
            redact_sensitive_data=os.getenv("REDACT_SENSITIVE_DATA", "true").lower() == "true",
        )
        
        # Logging configuration
        logging_config = LoggingConfig(
            level=os.getenv("LOG_LEVEL", "INFO"),
            format=os.getenv("LOG_FORMAT", "%(asctime)s - %(name)s - %(levelname)s - %(message)s"),
            file_path=Path(os.getenv("LOG_FILE", "logs/pyhack.log")),
            max_file_size=int(os.getenv("LOG_MAX_SIZE", "10485760")),
            backup_count=int(os.getenv("LOG_BACKUP_COUNT", "5")),
            console_enabled=os.getenv("LOG_CONSOLE", "true").lower() == "true",
            structured=os.getenv("LOG_STRUCTURED", "false").lower() == "true",
        )
        
        # Main application configuration
        app_config = AppConfig(
            env=os.getenv("ENV", "development"),
            debug=os.getenv("DEBUG", "true").lower() == "true",
            network=network_config,
            recon=recon_config,
            security=security_config,
            logging=logging_config,
        )
        
        logger.info(f"Configuration loaded for environment: {app_config.env}")
        return app_config
    
    def get_config(self) -> AppConfig:
        """Get the application configuration."""
        return self._config
    
    def reload(self):
        """Reload configuration from environment."""
        logger.info("Reloading configuration...")
        self._config = self._load_from_environment()


# Convenience function for accessing configuration
def get_config() -> AppConfig:
    """
    Get the application configuration singleton.
    
    Returns:
        AppConfig: The application configuration instance.
    """
    loader = ConfigLoader()
    return loader.get_config()


# Initialize configuration on import
config = get_config()
logger.info("Configuration module initialized")
```

### The Verification

Let's test our configuration management system:

```bash
# Create the .env file from the example
cat > .env << 'EOF'
# PyHack Suite Environment Configuration
# Copy this to .env and adjust for your environment

# Environment
ENV=development
DEBUG=true

# Network Settings
SCAPY_INTERFACE=eth0
SCAPY_BUFFER_SIZE=65535
SCAPY_PROMISCUOUS=true
SSH_TIMEOUT=10
NETMIKO_TIMEOUT=30
SNIFF_TIMEOUT=60

# Reconnaissance Settings
HTTP_TIMEOUT=10.0
HTTP_MAX_CONNECTIONS=100
HTTP_RATE_LIMIT=50
DEFAULT_PORTS=21,22,23,25,53,80,110,135,139,143,443,445,993,995,1723,3306,3389,5900,8080
BRUTE_FORCE_DELAY=0.5

# Security
ENCRYPTION_KEY=your-encryption-key-here
SECRET_KEY=your-secret-key-here
ENABLE_SANDBOX=true
REDACT_SENSITIVE_DATA=true

# Logging
LOG_LEVEL=DEBUG
LOG_FILE=logs/pyhack.log
EOF

# Create a test script
cat > test_config.py << 'EOF'
#!/usr/bin/env python3
"""Test script for configuration management."""

import sys
from pathlib import Path

# Add project root to Python path
sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.core.config import get_config

def main():
    """Test configuration loading."""
    config = get_config()
    
    print("=" * 60)
    print("PyHack Suite Configuration Test")
    print("=" * 60)
    
    print(f"\nEnvironment: {config.env}")
    print(f"Debug Mode: {config.debug}")
    
    print("\nNetwork Configuration:")
    print(f"  Interface: {config.network.scapy_interface}")
    print(f"  Buffer Size: {config.network.scapy_buffer_size}")
    print(f"  Promiscuous: {config.network.scapy_promiscuous}")
    print(f"  SSH Timeout: {config.network.ssh_timeout}s")
    
    print("\nReconnaissance Configuration:")
    print(f"  HTTP Timeout: {config.recon.http_timeout}s")
    print(f"  Max Connections: {config.recon.http_max_connections}")
    print(f"  Rate Limit: {config.recon.http_rate_limit} req/s")
    print(f"  Default Ports: {len(config.recon.default_ports)} ports")
    print(f"  Jitter Range: {config.recon.jitter_range}")
    
    print("\nSecurity Configuration:")
    print(f"  Sandbox: {config.security.enable_sandbox}")
    print(f"  Strict Validation: {config.security.enable_strict_validation}")
    print(f"  Redact Sensitive: {config.security.redact_sensitive_data}")
    
    print("\nLogging Configuration:")
    print(f"  Level: {config.logging.level}")
    print(f"  Console: {config.logging.console_enabled}")
    print(f"  Structured: {config.logging.structured}")
    
    print("\nPaths:")
    print(f"  Project Root: {config.project_root}")
    print(f"  Data Directory: {config.data_dir}")
    print(f"  Logs Directory: {config.logs_dir}")
    print("=" * 60)
    
    # Verify directories were created
    print("\nDirectory Check:")
    dirs = [
        config.data_dir,
        config.logs_dir,
        config.modules_dir,
    ]
    for d in dirs:
        exists = d.exists()
        status = "✓" if exists else "✗"
        print(f"  {status} {d} (exists: {exists})")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOF

# Run the test
python test_config.py
```

**Expected Output:**
```
============================================================
PyHack Suite Configuration Test
============================================================

Environment: development
Debug Mode: True

Network Configuration:
  Interface: eth0
  Buffer Size: 65535
  Promiscuous: True
  SSH Timeout: 10s

Reconnaissance Configuration:
  HTTP Timeout: 10.0s
  Max Connections: 100
  Rate Limit: 50 req/s
  Default Ports: 19 ports
  Jitter Range: (0.0, 0.5)

Security Configuration:
  Sandbox: True
  Strict Validation: True
  Redact Sensitive: True

Logging Configuration:
  Level: DEBUG
  Console: True
  Structured: False

Paths:
  Project Root: /path/to/pyhack_suite
  Data Directory: /path/to/pyhack_suite/data
  Logs Directory: /path/to/pyhack_suite/logs
============================================================

Directory Check:
  ✓ /path/to/pyhack_suite/data (exists: True)
  ✓ /path/to/pyhack_suite/logs (exists: True)
  ✓ /path/to/pyhack_suite/modules (exists: True)
```

---

## Step 1.3: Structured Logging

### The Target
`pyhack_suite/utils/logging.py` - Professional logging with rotation, structured output, and security features

### The Concept
Logging is like keeping a detailed diary of your application's activities. Good logging is essential for:
- Debugging issues when things go wrong
- Auditing activities for security compliance
- Monitoring system health and performance
- Providing evidence of proper operation

Our logging system will include:
- **Log rotation** - Prevents logs from filling up disk space
- **Structured logging** - JSON output for log aggregation tools
- **Sensitive data redaction** - Prevents credentials from being logged
- **Contextual logging** - Adds useful metadata to each log entry

### The Implementation

Create `pyhack_suite/utils/logging.py`:

```python
#!/usr/bin/env python3
"""
Structured logging system for PyHack Suite.

This module provides logging with:
- Log rotation to prevent disk filling
- Structured JSON output for log aggregation
- Sensitive data redaction for security
- Contextual information (module, line, etc.)
- Multiple output destinations (file, console, syslog)
"""

import logging
import logging.handlers
import sys
import json
import re
from pathlib import Path
from typing import Dict, Any, Optional, Union
from datetime import datetime
import traceback
from functools import wraps

# Sensitive data patterns for redaction
SENSITIVE_PATTERNS = {
    'password': re.compile(r'(password|passwd|pwd)[\s]*[:=][\s]*[^\s,}]+', re.IGNORECASE),
    'token': re.compile(r'(token|access_token|api_key|apikey|secret)[\s]*[:=][\s]*[^\s,}]+', re.IGNORECASE),
    'authorization': re.compile(r'(authorization|auth)[\s]*[:=][\s]*[^\s,}]+', re.IGNORECASE),
    'key': re.compile(r'(key|private_key|ssh_key)[\s]*[:=][\s]*[^\s,}]+', re.IGNORECASE),
    # IPv4 addresses (optional - may want to keep for debugging)
    # 'ip': re.compile(r'\b(?:\d{1,3}\.){3}\d{1,3}\b'),
}


class RedactingFilter(logging.Filter):
    """
    Log filter that redacts sensitive information from log messages.
    
    This filter scans log messages for patterns like passwords, tokens,
    and API keys, replacing them with [REDACTED] to prevent credential leakage.
    """
    
    def __init__(self, redact_patterns: Optional[Dict[str, re.Pattern]] = None):
        """
        Initialize the redacting filter.
        
        Args:
            redact_patterns: Custom patterns to redact (merges with defaults)
        """
        self.patterns = SENSITIVE_PATTERNS.copy()
        if redact_patterns:
            self.patterns.update(redact_patterns)
    
    def filter(self, record: logging.LogRecord) -> bool:
        """
        Redact sensitive data from the log record.
        
        Args:
            record: The log record to process
            
        Returns:
            bool: Always True (we're modifying the record, not filtering it)
        """
        if hasattr(record, 'msg') and isinstance(record.msg, str):
            # Redact in the main message
            original_msg = record.msg
            for pattern_name, pattern in self.patterns.items():
                record.msg = pattern.sub(f'[{pattern_name.upper()}_REDACTED]', record.msg)
            
            # Store original for potential debugging
            if record.msg != original_msg:
                record.redacted = True
        
        # Also redact any extra attributes
        if hasattr(record, 'extra') and isinstance(record.extra, dict):
            for key, value in record.extra.items():
                if isinstance(value, str):
                    for pattern_name, pattern in self.patterns.items():
                        if pattern.search(value):
                            record.extra[key] = f'[{pattern_name.upper()}_REDACTED]'
        
        return True


class StructuredFormatter(logging.Formatter):
    """
    Log formatter that outputs JSON structured logs.
    
    This formatter creates JSON log entries that are compatible with
    log aggregation tools like ELK, Splunk, or Datadog.
    """
    
    def __init__(self, include_location: bool = True, redact: bool = True):
        """
        Initialize the structured formatter.
        
        Args:
            include_location: Include file name and line number
            redact: Enable sensitive data redaction
        """
        super().__init__()
        self.include_location = include_location
        self.redact = redact
        self.redacting_filter = RedactingFilter() if redact else None
    
    def format(self, record: logging.LogRecord) -> str:
        """
        Format the log record as JSON.
        
        Args:
            record: The log record to format
            
        Returns:
            str: JSON-formatted log entry
        """
        # Create the base log entry
        log_entry = {
            'timestamp': datetime.fromtimestamp(record.created).isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
            'thread': record.threadName,
            'process': record.process,
        }
        
        # Include location info if requested
        if self.include_location:
            log_entry['file'] = record.filename
            log_entry['path'] = record.pathname
        
        # Include exception info if present
        if record.exc_info:
            log_entry['exception'] = {
                'type': record.exc_info[0].__name__,
                'message': str(record.exc_info[1]),
                'traceback': ''.join(traceback.format_tb(record.exc_info[2])),
            }
        
        # Include extra attributes
        if hasattr(record, 'extra') and isinstance(record.extra, dict):
            for key, value in record.extra.items():
                log_entry[key] = value
        
        # Apply redaction if enabled
        if self.redact and self.redacting_filter:
            # Convert to JSON string and redact
            json_str = json.dumps(log_entry, default=str)
            for pattern_name, pattern in self.redacting_filter.patterns.items():
                json_str = pattern.sub(f'[{pattern_name.upper()}_REDACTED]', json_str)
            return json_str
        
        return json.dumps(log_entry, default=str)


class LoggerFactory:
    """
    Factory for creating configured loggers.
    
    This class manages logger instances and ensures consistent configuration
    across the application.
    """
    
    _loggers = {}
    _config = None
    
    @classmethod
    def configure(cls, config):
        """
        Configure the logging system.
        
        Args:
            config: Application configuration object
        """
        cls._config = config
        
        # Get logging config
        log_config = config.logging
        
        # Set root logger level
        root_logger = logging.getLogger()
        root_logger.setLevel(log_config.level.upper())
        
        # Remove existing handlers
        for handler in root_logger.handlers[:]:
            root_logger.removeHandler(handler)
        
        # Create formatters
        if log_config.structured:
            # Structured JSON formatter
            formatter = StructuredFormatter(
                include_location=True,
                redact=config.security.redact_sensitive_data
            )
            file_formatter = formatter
            console_formatter = formatter
        else:
            # Standard text formatter
            file_formatter = logging.Formatter(log_config.format)
            console_formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
        
        # File handler with rotation
        if log_config.file_path:
            log_path = Path(log_config.file_path)
            log_path.parent.mkdir(parents=True, exist_ok=True)
            
            file_handler = logging.handlers.RotatingFileHandler(
                filename=str(log_path),
                maxBytes=log_config.max_file_size,
                backupCount=log_config.backup_count,
                encoding='utf-8',
            )
            file_handler.setFormatter(file_formatter)
            if config.security.redact_sensitive_data:
                file_handler.addFilter(RedactingFilter())
            root_logger.addHandler(file_handler)
        
        # Console handler
        if log_config.console_enabled:
            console_handler = logging.StreamHandler(sys.stdout)
            console_handler.setFormatter(console_formatter)
            if config.security.redact_sensitive_data:
                console_handler.addFilter(RedactingFilter())
            root_logger.addHandler(console_handler)
        
        # Set to DEBUG if in debug mode
        if config.debug and root_logger.level > logging.DEBUG:
            root_logger.setLevel(logging.DEBUG)
        
        # Log startup message
        root_logger.info(f"Logging configured for environment: {config.env}")
    
    @classmethod
    def get_logger(cls, name: str) -> logging.Logger:
        """
        Get a configured logger instance.
        
        Args:
            name: Logger name (typically __name__ from the calling module)
            
        Returns:
            logging.Logger: Configured logger instance
        """
        if name not in cls._loggers:
            logger = logging.getLogger(name)
            cls._loggers[name] = logger
        return cls._loggers[name]


def get_logger(name: str, config=None) -> logging.Logger:
    """
    Convenience function to get a configured logger.
    
    Args:
        name: Logger name
        config: Optional configuration override
        
    Returns:
        logging.Logger: Configured logger instance
    """
    if config:
        LoggerFactory.configure(config)
    
    # Import here to avoid circular import
    from pyhack_suite.core.config import get_config
    
    if not LoggerFactory._config:
        LoggerFactory.configure(get_config())
    
    return LoggerFactory.get_logger(name)


def log_function_call(logger: Optional[logging.Logger] = None, level=logging.DEBUG):
    """
    Decorator to log function calls with arguments and return values.
    
    This is useful for debugging complex operations and tracking flow.
    
    Args:
        logger: Logger to use (creates one if None)
        level: Log level for the call logging
        
    Returns:
        Decorated function
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Get or create logger
            if logger is None:
                log = get_logger(func.__module__)
            else:
                log = logger
            
            # Log function call
            args_repr = [repr(a) for a in args]
            kwargs_repr = [f"{k}={repr(v)}" for k, v in kwargs.items()]
            signature = ", ".join(args_repr + kwargs_repr)
            
            log.log(level, f"Calling {func.__name__}({signature})")
            
            try:
                result = func(*args, **kwargs)
                log.log(level, f"{func.__name__} returned {repr(result)}")
                return result
            except Exception as e:
                log.exception(f"{func.__name__} raised {type(e).__name__}: {e}")
                raise
        
        return wrapper
    return decorator


# Initialize logging
def init_logging():
    """Initialize the logging system with default configuration."""
    from pyhack_suite.core.config import get_config
    config = get_config()
    LoggerFactory.configure(config)


# Initialize on import
init_logging()
```

### The Verification

Test the logging system:

```bash
cat > test_logging.py << 'EOF'
#!/usr/bin/env python3
"""Test script for logging system."""

import sys
import logging
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.core.config import get_config
from pyhack_suite.utils.logging import get_logger, log_function_call

def test_logging():
    """Test the logging system."""
    # Get configuration
    config = get_config()
    print(f"Log level: {config.logging.level}")
    print(f"Log file: {config.logging.file_path}")
    print(f"Structured: {config.logging.structured}")
    
    # Get logger
    logger = get_logger(__name__)
    
    # Test different log levels
    logger.debug("This is a debug message")
    logger.info("This is an info message")
    logger.warning("This is a warning message")
    logger.error("This is an error message")
    
    # Test with sensitive data
    sensitive_msg = "User logged in with password=supersecret123 and token=abc123xyz"
    logger.info(sensitive_msg)
    
    # Test with structured data
    logger.info("User action", extra={
        'user_id': 12345,
        'action': 'login',
        'ip': '192.168.1.100',
        'headers': {'Authorization': 'Bearer token123'}
    })
    
    # Test function decorator
    @log_function_call(level=logging.INFO)
    def test_function(a, b, password=None):
        """Test function with password parameter."""
        return a + b
    
    test_function(10, 20, password="secret123")
    
    # Test exception logging
    try:
        1 / 0
    except ZeroDivisionError:
        logger.exception("Division by zero error")
    
    # Check if log file was created
    log_file = config.logging.file_path
    if log_file and Path(log_file).exists():
        size = Path(log_file).stat().st_size
        print(f"\nLog file created: {log_file} ({size} bytes)")
        
        # Show a few lines
        print("\nFirst 5 lines of log file:")
        with open(log_file, 'r') as f:
            lines = f.readlines()[:5]
            for line in lines:
                print(f"  {line.strip()}")
    else:
        print(f"\nLog file not created: {log_file}")
    
    return 0

if __name__ == "__main__":
    sys.exit(test_logging())
EOF

python test_logging.py
```

**Expected Output (summary):**
```
Log level: DEBUG
Log file: logs/pyhack.log
Structured: False
This is a debug message
This is an info message
This is a warning message
This is an error message
User logged in with [PASSWORD_REDACTED] and [TOKEN_REDACTED]
User action {'user_id': 12345, 'action': 'login', 'ip': '192.168.1.100', 'headers': {'Authorization': '[TOKEN_REDACTED]'}}
Calling test_function(10, 20, password='[PASSWORD_REDACTED]')
test_function returned 30
Division by zero error
Traceback (most recent call last):
  ...
ZeroDivisionError: division by zero

Log file created: logs/pyhack.log (1234 bytes)
```

---

## Step 1.4: Project Metadata & Dependencies

### The Target
`pyproject.toml`, `setup.py`, `requirements.txt` - Modern Python packaging

### The Concept
Proper packaging makes your project:
- **Installable** - `pip install -e .` for development
- **Shareable** - Easy to distribute to others
- **Dependency-managed** - All required packages tracked
- **Version-controlled** - Clear version tracking

### The Implementation

Create `pyproject.toml`:

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "pyhack-suite"
version = "0.1.0"
description = "A modular offensive security framework for Python"
readme = "README.md"
requires-python = ">=3.9"
license = {text = "MIT"}
authors = [
    {name = "Security Researcher", email = "researcher@example.com"}
]
keywords = ["security", "penetration-testing", "network", "automation"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "Topic :: Security",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    "scapy>=2.5.0",
    "paramiko>=3.0.0",
    "netmiko>=4.0.0",
    "httpx>=0.25.0",
    "aiohttp>=3.9.0",
    "asyncio>=3.4.3",
    "beautifulsoup4>=4.12.0",
    "lxml>=4.9.0",
    "playwright>=1.40.0",
    "python-dotenv>=1.0.0",
    "pyyaml>=6.0",
    "cryptography>=41.0.0",
    "pydantic>=2.0.0",
    "click>=8.1.0",
    "rich>=13.0.0",
    "orjson>=3.9.0",
    "uvloop>=0.19.0",  # Faster event loop
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "black>=23.11.0",
    "mypy>=1.7.0",
    "ruff>=0.1.0",
    "pre-commit>=3.5.0",
    "pylint>=3.0.0",
    "sphinx>=7.0.0",  # Documentation
    "sphinx-rtd-theme>=1.3.0",
]
test = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "coverage>=7.3.0",
]
docs = [
    "sphinx>=7.0.0",
    "sphinx-rtd-theme>=1.3.0",
    "myst-parser>=2.0.0",
]

[project.urls]
Homepage = "https://github.com/yourusername/pyhack-suite"
Documentation = "https://pyhack-suite.readthedocs.io/"
Repository = "https://github.com/yourusername/pyhack-suite.git"
Issues = "https://github.com/yourusername/pyhack-suite/issues"

[tool.setuptools.packages.find]
where = ["."]
include = ["pyhack_suite*"]
exclude = ["tests*", "docs*"]

[tool.black]
line-length = 100
target-version = ['py39', 'py310', 'py311', 'py312']
include = '\.pyi?$'
exclude = '''
/(
    \.eggs
    | \.git
    | \.hg
    | \.mypy_cache
    | \.tox
    | \.venv
    | _build
    | buck-out
    | build
    | dist
    | venv
)/
'''

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
ignore_missing_imports = true
exclude = ['tests/']

[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra -q --tb=short --strict-markers"
testpaths = ["tests"]
python_files = "test_*.py"
python_classes = "Test*"
python_functions = "test_*"

[tool.ruff]
line-length = 100
target-version = "py39"
exclude = ["tests/*"]

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "D", "UP", "B", "C4"]
ignore = ["D100", "D101", "D102", "D103", "D104", "D105"]  # Missing docstrings

[tool.coverage.run]
source = ["pyhack_suite"]
omit = ["*/tests/*", "*/__init__.py"]

[tool.coverage.report]
fail_under = 80
show_missing = true
```

Create `setup.py` (for backward compatibility):

```python
#!/usr/bin/env python3
"""Setup script for PyHack Suite."""

from setuptools import setup, find_packages

if __name__ == "__main__":
    setup(
        packages=find_packages(include=["pyhack_suite", "pyhack_suite.*"]),
    )
```

Create `requirements.txt`:

```txt
# Core dependencies
scapy>=2.5.0
paramiko>=3.0.0
netmiko>=4.0.0
httpx>=0.25.0
aiohttp>=3.9.0
beautifulsoup4>=4.12.0
lxml>=4.9.0
playwright>=1.40.0
python-dotenv>=1.0.0
pyyaml>=6.0
cryptography>=41.0.0
pydantic>=2.0.0
click>=8.1.0
rich>=13.0.0
orjson>=3.9.0
uvloop>=0.19.0
```

Create `requirements-dev.txt`:

```txt
-r requirements.txt
pytest>=7.4.0
pytest-asyncio>=0.21.0
pytest-cov>=4.1.0
black>=23.11.0
mypy>=1.7.0
ruff>=0.1.0
pre-commit>=3.5.0
pylint>=3.0.0
sphinx>=7.0.0
sphinx-rtd-theme>=1.3.0
myst-parser>=2.0.0
coverage>=7.3.0
```

Create `.gitignore`:

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
pythonenv*
*.egg-info/
.eggs/
dist/
build/
develop-eggs/
downloads/
eggs/
.installed.cfg
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.mypy_cache/
.ruff_cache/
.pytest_cache/

# Environment
.env
.env.local
.env.*.local
*.pem
*.key
*.crt
*.p12
*.p7b

# Logs
logs/
*.log
*.pid

# Data
data/wordlists/
data/screenshots/
data/reports/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Misc
*.tmp
*.bak
*.temp
```

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: detect-private-key
      - id: fix-encoding-pragma

  - repo: https://github.com/psf/black
    rev: 23.11.0
    hooks:
      - id: black

  - repo: https://github.com/charliermarsh/ruff-pre-commit
    rev: v0.1.0
    hooks:
      - id: ruff
        args: [--fix]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.7.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
        args: [--ignore-missing-imports]
```

### The Verification

Verify the project structure and packaging:

```bash
# Install in development mode
pip install -e ".[dev]"

# Run pre-commit hooks on all files
pre-commit run --all-files

# Check that packages can be imported
python -c "import pyhack_suite; print('Import successful!')"

# Show installed dependencies
pip freeze | grep -E "scapy|paramiko|netmiko|httpx|aiohttp"
```

**Expected Output:**
```
Import successful!
aiohttp==3.9.0
httpx==0.25.0
netmiko==4.1.0
paramiko==3.4.0
scapy==2.5.0
```

---

```
[COMPLETED: Part 1, Section 1 - Project Structure & Foundation]
[GENERATING: Part 1, Section 2 - Building Unified Connection Handlers]
```

## Section 2: Building Unified Connection Handlers

### The Target
`pyhack_suite/core/session_manager.py` - Unified connection management for SSH, network devices, and packet operations

### The Concept
A connection handler is like a universal remote control. Instead of learning different controls for each device, you have one interface that works with multiple devices. Our session manager will:

1. **Abstract connection details** - Whether SSH, Telnet, or raw sockets
2. **Handle authentication** - Keys, passwords, tokens
3. **Manage sessions** - Keep connections alive, handle reconnection
4. **Provide unified API** - Same methods regardless of underlying transport

### The Implementation

Create `pyhack_suite/core/session_manager.py`:

```python
#!/usr/bin/env python3
"""
Unified session manager for PyHack Suite.

This module provides a single interface for managing connections to:
- SSH servers (via Paramiko)
- Network devices (via Netmiko)
- Raw sockets (for packet operations)
- Custom protocol handlers

The session manager handles authentication, connection pooling,
reconnection logic, and session persistence.

Why a unified session manager?
- Reduces code duplication across modules
- Centralizes connection configuration
- Provides consistent error handling
- Enables easy switching between protocols
- Handles connection lifecycle (open, close, re-open)
"""

from __future__ import annotations

import asyncio
import socket
import time
from dataclasses import dataclass, field
from enum import Enum
from typing import Optional, Dict, Any, Callable, Union, List, Tuple
from contextlib import contextmanager
import threading
import queue

import paramiko
from netmiko import ConnectHandler
from netmiko.base_connection import BaseConnection

from pyhack_suite.core.config import get_config
from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


class ConnectionType(Enum):
    """Types of connections supported by the session manager."""
    SSH = "ssh"
    TELNET = "telnet"
    NETMIKO = "netmiko"
    RAW_SOCKET = "raw_socket"
    HTTP = "http"
    HTTPS = "https"


class ConnectionStatus(Enum):
    """Status of a connection session."""
    DISCONNECTED = "disconnected"
    CONNECTING = "connecting"
    CONNECTED = "connected"
    AUTHENTICATING = "authenticating"
    AUTHENTICATED = "authenticated"
    ERROR = "error"
    CLOSED = "closed"


@dataclass
class ConnectionConfig:
    """Configuration for a connection."""
    
    connection_type: ConnectionType
    host: str
    port: int
    username: Optional[str] = None
    password: Optional[str] = None
    private_key_path: Optional[str] = None
    passphrase: Optional[str] = None
    timeout: int = 10
    auth_retries: int = 3
    device_type: Optional[str] = None  # For Netmiko
    
    # Additional options
    options: Dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        """Validate connection configuration."""
        if self.connection_type in [ConnectionType.SSH, ConnectionType.NETMIKO]:
            if not self.username:
                raise ValueError(f"Username required for {self.connection_type.value}")
        
        if self.connection_type == ConnectionType.NETMIKO and not self.device_type:
            raise ValueError("Device type required for Netmiko connections")
        
        if self.port <= 0 or self.port > 65535:
            raise ValueError(f"Invalid port number: {self.port}")


class ConnectionPool:
    """
    Pool of reusable connections.
    
    Connection pooling reduces the overhead of creating new connections
    by reusing existing ones. This is especially useful for:
    - Short-lived operations
    - High-volume requests
    - Rate-limited connections
    """
    
    def __init__(self, max_size: int = 10):
        """
        Initialize the connection pool.
        
        Args:
            max_size: Maximum number of connections to keep in the pool
        """
        self.max_size = max_size
        self._pool: queue.Queue = queue.Queue(maxsize=max_size)
        self._active_connections: Dict[str, int] = {}  # host -> count
        self._lock = threading.Lock()
        logger.info(f"Connection pool initialized with max size: {max_size}")
    
    def get_connection(self, key: str) -> Optional[Any]:
        """
        Get a connection from the pool.
        
        Args:
            key: Unique identifier for the connection
            
        Returns:
            Optional[Any]: The connection object, or None if not available
        """
        try:
            # Try to get a connection with timeout (non-blocking)
            conn = self._pool.get(block=False)
            logger.debug(f"Connection retrieved from pool: {key}")
            return conn
        except queue.Empty:
            logger.debug(f"No available connection in pool for: {key}")
            return None
    
    def return_connection(self, key: str, conn: Any):
        """
        Return a connection to the pool.
        
        Args:
            key: Unique identifier for the connection
            conn: The connection object to return
        """
        try:
            if self._pool.qsize() < self.max_size:
                self._pool.put(conn, block=False)
                logger.debug(f"Connection returned to pool: {key}")
            else:
                # Pool is full, close the connection
                self._close_connection(conn)
                logger.debug(f"Pool full, connection closed: {key}")
        except queue.Full:
            self._close_connection(conn)
            logger.warning(f"Pool full, connection closed: {key}")
    
    def _close_connection(self, conn: Any):
        """
        Close a connection properly.
        
        Args:
            conn: The connection to close
        """
        try:
            if hasattr(conn, 'close'):
                conn.close()
            elif hasattr(conn, 'disconnect'):
                conn.disconnect()
        except Exception as e:
            logger.warning(f"Error closing connection: {e}")
    
    def clear(self):
        """Clear the connection pool."""
        while not self._pool.empty():
            try:
                conn = self._pool.get(block=False)
                self._close_connection(conn)
            except queue.Empty:
                break
        logger.info("Connection pool cleared")


class SessionManager:
    """
    Unified session manager for various connection types.
    
    This class manages the lifecycle of connections and provides
    a unified interface for different protocols.
    
    Key features:
    - Connection pooling for performance
    - Automatic reconnection on failure
    - Connection state tracking
    - Thread-safe operations
    """
    
    _instance = None
    
    def __new__(cls):
        """Singleton pattern for global session management."""
        if cls._instance is None:
            cls._instance = super(SessionManager, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize the session manager."""
        if hasattr(self, '_initialized') and self._initialized:
            return
        self._initialized = True
        
        self.config = get_config()
        self.logger = get_logger(__name__)
        
        # Connection pool
        self.pool = ConnectionPool(max_size=10)
        
        # Active sessions
        self._sessions: Dict[str, Dict[str, Any]] = {}
        self._status: Dict[str, ConnectionStatus] = {}
        self._lock = threading.Lock()
        
        # Session cleanup thread
        self._cleanup_thread = threading.Thread(
            target=self._cleanup_loop,
            daemon=True,
            name="SessionCleanupThread"
        )
        self._cleanup_thread.start()
        
        self.logger.info("Session manager initialized")
    
    def _generate_session_id(self, config: ConnectionConfig) -> str:
        """
        Generate a unique session ID for a connection.
        
        Args:
            config: Connection configuration
            
        Returns:
            str: Unique session identifier
        """
        # Simple but effective ID generation
        components = [
            config.connection_type.value,
            config.host,
            str(config.port),
            config.username or "anonymous",
        ]
        return ":".join(components)
    
    @log_function_call(level="DEBUG")
    def create_session(self, config: ConnectionConfig) -> str:
        """
        Create a new session.
        
        Args:
            config: Connection configuration
            
        Returns:
            str: Session ID for the new session
        """
        session_id = self._generate_session_id(config)
        
        with self._lock:
            if session_id in self._sessions:
                # Check if existing session is still valid
                if self._status.get(session_id) == ConnectionStatus.CONNECTED:
                    self.logger.info(f"Using existing session: {session_id}")
                    return session_id
            
            # Create new session
            self._sessions[session_id] = {
                'config': config,
                'connection': None,
                'created_at': time.time(),
                'last_used': time.time(),
                'usage_count': 0,
            }
            self._status[session_id] = ConnectionStatus.DISCONNECTED
            self.logger.info(f"Created new session: {session_id}")
            
        return session_id
    
    @log_function_call(level="DEBUG")
    def connect(self, session_id: str) -> bool:
        """
        Establish the actual connection for a session.
        
        Args:
            session_id: Session ID from create_session
            
        Returns:
            bool: True if connection successful
            
        Raises:
            ValueError: If session doesn't exist
            ConnectionError: If connection fails
        """
        with self._lock:
            if session_id not in self._sessions:
                raise ValueError(f"Session not found: {session_id}")
            
            session = self._sessions[session_id]
            config = session['config']
            
            # Check if already connected
            if self._status.get(session_id) == ConnectionStatus.CONNECTED:
                self.logger.debug(f"Already connected: {session_id}")
                return True
            
            # Try to get from pool first
            pool_key = f"{config.host}:{config.port}"
            conn = self.pool.get_connection(pool_key)
            if conn:
                session['connection'] = conn
                self._status[session_id] = ConnectionStatus.CONNECTED
                session['last_used'] = time.time()
                session['usage_count'] += 1
                self.logger.info(f"Reused connection from pool: {session_id}")
                return True
        
        # Connect based on type
        try:
            self._status[session_id] = ConnectionStatus.CONNECTING
            
            if config.connection_type == ConnectionType.SSH:
                conn = self._connect_ssh(config)
            elif config.connection_type == ConnectionType.NETMIKO:
                conn = self._connect_netmiko(config)
            elif config.connection_type == ConnectionType.RAW_SOCKET:
                conn = self._connect_raw_socket(config)
            else:
                raise ValueError(f"Unsupported connection type: {config.connection_type}")
            
            with self._lock:
                session = self._sessions[session_id]
                session['connection'] = conn
                self._status[session_id] = ConnectionStatus.CONNECTED
                session['last_used'] = time.time()
                session['usage_count'] += 1
            
            self.logger.info(f"Connected successfully: {session_id}")
            return True
            
        except Exception as e:
            with self._lock:
                self._status[session_id] = ConnectionStatus.ERROR
            self.logger.error(f"Connection failed for {session_id}: {e}")
            raise ConnectionError(f"Failed to connect: {e}") from e
    
    def _connect_ssh(self, config: ConnectionConfig) -> paramiko.SSHClient:
        """
        Establish an SSH connection using Paramiko.
        
        Args:
            config: Connection configuration
            
        Returns:
            paramiko.SSHClient: Connected SSH client
            
        Raises:
            paramiko.AuthenticationException: If authentication fails
            paramiko.SSHException: If SSH connection fails
        """
        self.logger.info(f"Connecting SSH to {config.host}:{config.port}")
        
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # Authentication options
        connect_kwargs = {
            'hostname': config.host,
            'port': config.port,
            'username': config.username,
            'timeout': config.timeout,
        }
        
        # Use private key if provided
        if config.private_key_path:
            try:
                key = paramiko.RSAKey.from_private_key_file(
                    config.private_key_path,
                    password=config.passphrase
                )
                connect_kwargs['pkey'] = key
                self.logger.debug("Using private key authentication")
            except Exception as e:
                self.logger.warning(f"Failed to load private key: {e}")
                # Fall back to password if available
                if config.password:
                    connect_kwargs['password'] = config.password
        elif config.password:
            connect_kwargs['password'] = config.password
        
        # Try with retries
        for attempt in range(config.auth_retries):
            try:
                client.connect(**connect_kwargs)
                self.logger.debug(f"SSH connection established (attempt {attempt + 1})")
                return client
            except paramiko.AuthenticationException:
                if attempt == config.auth_retries - 1:
                    raise
                self.logger.warning(f"Authentication failed, retrying ({attempt + 1}/{config.auth_retries})")
                time.sleep(1)
        
        raise paramiko.AuthenticationException("Authentication failed after retries")
    
    def _connect_netmiko(self, config: ConnectionConfig) -> BaseConnection:
        """
        Establish a connection to a network device using Netmiko.
        
        Args:
            config: Connection configuration
            
        Returns:
            BaseConnection: Netmiko connection object
            
        Raises:
            Exception: If Netmiko connection fails
        """
        self.logger.info(f"Connecting Netmiko to {config.host}:{config.port} ({config.device_type})")
        
        # Build Netmiko connection parameters
        conn_params = {
            'device_type': config.device_type,
            'host': config.host,
            'port': config.port,
            'username': config.username,
            'timeout': config.timeout,
        }
        
        # Authentication
        if config.password:
            conn_params['password'] = config.password
        if config.private_key_path:
            conn_params['ssh_config_file'] = config.private_key_path
        
        # Additional options
        conn_params.update(config.options)
        
        try:
            connection = ConnectHandler(**conn_params)
            self.logger.debug(f"Netmiko connection established")
            return connection
        except Exception as e:
            self.logger.error(f"Netmiko connection failed: {e}")
            raise
    
    def _connect_raw_socket(self, config: ConnectionConfig) -> socket.socket:
        """
        Establish a raw socket connection.
        
        Args:
            config: Connection configuration
            
        Returns:
            socket.socket: Connected socket
            
        Raises:
            socket.error: If socket connection fails
        """
        self.logger.info(f"Connecting raw socket to {config.host}:{config.port}")
        
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(config.timeout)
        
        try:
            sock.connect((config.host, config.port))
            self.logger.debug("Raw socket connection established")
            return sock
        except socket.error as e:
            self.logger.error(f"Socket connection failed: {e}")
            raise
    
    @log_function_call(level="DEBUG")
    def get_connection(self, session_id: str) -> Any:
        """
        Get the connection object for a session.
        
        Args:
            session_id: Session ID
            
        Returns:
            Any: The connection object
            
        Raises:
            ValueError: If session doesn't exist
            ConnectionError: If not connected
        """
        with self._lock:
            if session_id not in self._sessions:
                raise ValueError(f"Session not found: {session_id}")
            
            session = self._sessions[session_id]
            
            # Check if connected
            if self._status.get(session_id) != ConnectionStatus.CONNECTED:
                raise ConnectionError(f"Session not connected: {session_id}")
            
            # Update usage
            session['last_used'] = time.time()
            session['usage_count'] += 1
            
            return session['connection']
    
    @log_function_call(level="DEBUG")
    def execute_command(self, session_id: str, command: str) -> Tuple[str, str]:
        """
        Execute a command on the connection.
        
        Args:
            session_id: Session ID
            command: Command to execute
            
        Returns:
            Tuple[str, str]: (stdout, stderr)
            
        Raises:
            ValueError: If session doesn't exist
            ConnectionError: If not connected
        """
        conn = self.get_connection(session_id)
        
        try:
            # Determine connection type and execute accordingly
            session = self._sessions[session_id]
            config = session['config']
            
            if config.connection_type in [ConnectionType.SSH, ConnectionType.NETMIKO]:
                # SSH/Netmiko command execution
                if isinstance(conn, paramiko.SSHClient):
                    stdin, stdout, stderr = conn.exec_command(command)
                    stdout_output = stdout.read().decode('utf-8')
                    stderr_output = stderr.read().decode('utf-8')
                    return stdout_output, stderr_output
                elif hasattr(conn, 'send_command'):
                    # Netmiko
                    output = conn.send_command(command)
                    return output, ""
                else:
                    raise ValueError(f"Unsupported connection type for command execution: {type(conn)}")
            else:
                raise ValueError(f"Command execution not supported for {config.connection_type}")
                
        except Exception as e:
            self.logger.error(f"Command execution failed: {e}")
            raise
    
    def execute_async(self, session_id: str, command: str) -> asyncio.Future:
        """
        Execute a command asynchronously.
        
        Args:
            session_id: Session ID
            command: Command to execute
            
        Returns:
            asyncio.Future: Future that resolves to (stdout, stderr)
        """
        loop = asyncio.get_event_loop()
        future = loop.run_in_executor(
            None, self.execute_command, session_id, command
        )
        return future
    
    @log_function_call(level="DEBUG")
    def close_session(self, session_id: str):
        """
        Close a session and optionally return connection to pool.
        
        Args:
            session_id: Session ID to close
        """
        with self._lock:
            if session_id not in self._sessions:
                self.logger.warning(f"Session not found for closing: {session_id}")
                return
            
            session = self._sessions[session_id]
            conn = session.get('connection')
            
            if conn:
                # Try to return to pool
                config = session['config']
                pool_key = f"{config.host}:{config.port}"
                self.pool.return_connection(pool_key, conn)
            
            # Remove session
            del self._sessions[session_id]
            self._status[session_id] = ConnectionStatus.CLOSED
            self.logger.info(f"Session closed: {session_id}")
    
    def close_all(self):
        """Close all sessions."""
        session_ids = list(self._sessions.keys())
        for session_id in session_ids:
            self.close_session(session_id)
        self.logger.info("All sessions closed")
    
    def get_status(self, session_id: str) -> Optional[ConnectionStatus]:
        """
        Get the status of a session.
        
        Args:
            session_id: Session ID
            
        Returns:
            Optional[ConnectionStatus]: Session status
        """
        return self._status.get(session_id)
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Get session statistics.
        
        Returns:
            Dict[str, Any]: Statistics about sessions
        """
        with self._lock:
            total = len(self._sessions)
            connected = sum(1 for s in self._status.values() 
                          if s == ConnectionStatus.CONNECTED)
            
            return {
                'total_sessions': total,
                'connected_sessions': connected,
                'disconnected_sessions': total - connected,
                'pool_size': self.pool._pool.qsize(),
                'pool_max': self.pool.max_size,
            }
    
    def _cleanup_loop(self):
        """Background thread for cleaning up stale sessions."""
        while True:
            try:
                time.sleep(60)  # Check every minute
                self._cleanup_stale_sessions()
            except Exception as e:
                self.logger.error(f"Cleanup loop error: {e}")
    
    def _cleanup_stale_sessions(self, timeout: int = 300):
        """
        Clean up sessions that haven't been used for a while.
        
        Args:
            timeout: Maximum idle time in seconds
        """
        current_time = time.time()
        stale_sessions = []
        
        with self._lock:
            for session_id, session in self._sessions.items():
                last_used = session.get('last_used', 0)
                if current_time - last_used > timeout:
                    stale_sessions.append(session_id)
            
            for session_id in stale_sessions:
                self.logger.info(f"Cleaning up stale session: {session_id}")
                self.close_session(session_id)


# Convenience functions for common operations

@contextmanager
def session_context(config: ConnectionConfig):
    """
    Context manager for session lifecycle.
    
    Usage:
        with session_context(config) as session_id:
            manager.execute_command(session_id, "show ip")
    
    Args:
        config: Connection configuration
        
    Yields:
        str: Session ID
    """
    manager = SessionManager()
    session_id = manager.create_session(config)
    
    try:
        manager.connect(session_id)
        yield session_id
    finally:
        manager.close_session(session_id)


async def async_session_context(config: ConnectionConfig):
    """
    Async context manager for session lifecycle.
    
    Usage:
        async with async_session_context(config) as session_id:
            await manager.execute_async(session_id, "show ip")
    
    Args:
        config: Connection configuration
        
    Yields:
        str: Session ID
    """
    manager = SessionManager()
    session_id = manager.create_session(config)
    
    try:
        manager.connect(session_id)
        yield session_id
    finally:
        manager.close_session(session_id)


# Initialize session manager
session_manager = SessionManager()
```

### The Verification

Test the session manager:

```bash
cat > test_session_manager.py << 'EOF'
#!/usr/bin/env python3
"""Test script for session manager."""

import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.core.session_manager import (
    SessionManager,
    ConnectionConfig,
    ConnectionType,
    session_context,
    get_logger
)

logger = get_logger(__name__)

def test_session_manager():
    """Test session manager functionality."""
    logger.info("=" * 60)
    logger.info("Testing Session Manager")
    logger.info("=" * 60)
    
    # Create manager
    manager = SessionManager()
    
    # Create test configuration (using local SSH)
    config = ConnectionConfig(
        connection_type=ConnectionType.SSH,
        host="localhost",
        port=22,
        username="test",  # Change to valid username
        password="test",  # Change to valid password
        timeout=5,
        auth_retries=2,
    )
    
    logger.info(f"Created config for {config.host}:{config.port}")
    
    # Test session creation
    session_id = manager.create_session(config)
    logger.info(f"Created session: {session_id}")
    
    # Test session status
    status = manager.get_status(session_id)
    logger.info(f"Session status: {status}")
    
    # Test stats
    stats = manager.get_stats()
    logger.info(f"Stats: {stats}")
    
    # Test connection (will fail unless you have SSH enabled with these credentials)
    try:
        logger.info("Attempting connection...")
        manager.connect(session_id)
        logger.info("Connection successful!")
        
        # Test command execution (if connected)
        try:
            stdout, stderr = manager.execute_command(session_id, "echo 'Hello from PyHack!'")
            logger.info(f"Command output: {stdout.strip()}")
        except Exception as e:
            logger.warning(f"Command execution failed (expected if no SSH): {e}")
        
    except Exception as e:
        logger.warning(f"Connection failed (expected): {e}")
    
    # Test context manager
    logger.info("\nTesting context manager...")
    try:
        with session_context(config) as sid:
            logger.info(f"Context session ID: {sid}")
            # Would execute commands here if connected
    except Exception as e:
        logger.warning(f"Context manager failed: {e}")
    
    # Test stats after operations
    stats = manager.get_stats()
    logger.info(f"\nFinal stats: {stats}")
    
    # Clean up
    manager.close_all()
    logger.info("Cleanup complete")
    
    return 0

if __name__ == "__main__":
    sys.exit(test_session_manager())
EOF

python test_session_manager.py
```

**Expected Output (summarized):**
```
============================================================
Testing Session Manager
============================================================
Created config for localhost:22
Created session: ssh:localhost:22:test
Session status: ConnectionStatus.DISCONNECTED
Stats: {'total_sessions': 1, 'connected_sessions': 0, ...}
Attempting connection...
Connection failed (expected): [Errno 111] Connection refused

Testing context manager...
Context session ID: ssh:localhost:22:test
Context manager failed: [Errno 111] Connection refused

Final stats: {'total_sessions': 0, 'connected_sessions': 0, ...}
Cleanup complete
```

---

```
[COMPLETED: Part 1, Section 2 - Building Unified Connection Handlers]
[GENERATING: Part 1, Section 3 - Comparative Analysis: Paramiko vs. Netmiko vs. Scapy]
```

## Section 3: Comparative Analysis — Paramiko vs. Netmiko vs. Scapy

### The Target
Understanding when and how to use each library, with practical examples and use-case mapping.

### The Concept
This is like choosing between different tools in a toolkit:

| Library | Best For | Analogy |
|---------|----------|---------|
| **Paramiko** | Custom SSH automation | A precision scalpel - fine control for specific tasks |
| **Netmiko** | Multi-vendor device management | A power drill with different bits - standardized interface for various devices |
| **Scapy** | Packet manipulation and analysis | A chemistry set - raw materials to build custom molecules (packets) |

Let's explore each with concrete examples.

---

## Step 3.1: Paramiko Deep Dive

### The Target
`pyhack_suite/network/paramiko_wrapper.py` - Custom SSH automation

### The Concept
Paramiko is Python's SSH implementation. It gives you low-level control but requires more code. Think of it as building custom SSH utilities when you need something specific that Netmiko doesn't provide.

### The Implementation

Create `pyhack_suite/network/paramiko_wrapper.py`:

```python
#!/usr/bin/env python3
"""
Paramiko wrapper for SSH automation.

This module provides custom SSH automation using Paramiko, with:
- SFTP file transfers
- Command execution with sudo support
- Interactive session handling
- SSH key management
- Session persistence

Use cases for Paramiko over Netmiko:
- Custom SSH protocols (e.g., non-standard banners)
- File transfers with SFTP
- Interactive shell sessions
- When you need fine-grained control
- When the target device isn't in Netmiko's device types
"""

import paramiko
import socket
import time
from typing import Optional, Dict, Any, List, Tuple, Union
from pathlib import Path
import os

from pyhack_suite.core.session_manager import ConnectionConfig, ConnectionType
from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


class SSHWrapper:
    """
    Enhanced SSH client wrapper around Paramiko.
    
    This provides additional functionality beyond Paramiko's basic client:
    - Automatic retry with exponential backoff
    - SFTP with progress callbacks
    - Interactive shell handling
    - Command output parsing
    - Session persistence across commands
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize the SSH wrapper.
        
        Args:
            config: SSH configuration dictionary
        """
        self.config = config
        self.client: Optional[paramiko.SSHClient] = None
        self.transport: Optional[paramiko.Transport] = None
        self.sftp: Optional[paramiko.SFTPClient] = None
        self.is_connected = False
        self.logger = get_logger(f"{__name__}.SSHWrapper.{config.get('host', 'unknown')}")
    
    @log_function_call(level="DEBUG")
    def connect(self) -> bool:
        """
        Establish SSH connection with retries.
        
        Returns:
            bool: True if connection successful
        """
        host = self.config.get('host')
        port = self.config.get('port', 22)
        username = self.config.get('username')
        password = self.config.get('password')
        private_key_path = self.config.get('private_key_path')
        timeout = self.config.get('timeout', 10)
        max_retries = self.config.get('max_retries', 3)
        
        self.logger.info(f"Connecting to {host}:{port} as {username}")
        
        for attempt in range(max_retries):
            try:
                self.client = paramiko.SSHClient()
                self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                
                connect_kwargs = {
                    'hostname': host,
                    'port': port,
                    'username': username,
                    'timeout': timeout,
                }
                
                # Authentication
                if private_key_path:
                    self.logger.debug("Attempting private key authentication")
                    private_key = self._load_private_key(private_key_path)
                    if private_key:
                        connect_kwargs['pkey'] = private_key
                elif password:
                    self.logger.debug("Attempting password authentication")
                    connect_kwargs['password'] = password
                else:
                    raise ValueError("No authentication method provided")
                
                # Connect with backoff
                try:
                    self.client.connect(**connect_kwargs)
                except paramiko.AuthenticationException:
                    self.logger.warning(f"Authentication failed for {username}@{host}")
                    # Try SSH agent if available
                    try:
                        self.logger.debug("Attempting SSH agent authentication")
                        from paramiko.agent import Agent
                        agent = Agent()
                        for key in agent.get_keys():
                            try:
                                self.client.connect(
                                    hostname=host,
                                    port=port,
                                    username=username,
                                    pkey=key,
                                    timeout=timeout
                                )
                                self.logger.info("SSH agent authentication successful")
                                break
                            except Exception:
                                continue
                    except Exception as e:
                        self.logger.debug(f"SSH agent failed: {e}")
                    
                    if not self.client.get_transport() or not self.client.get_transport().is_active():
                        if attempt == max_retries - 1:
                            raise
                        self.logger.warning(f"Retrying ({attempt + 1}/{max_retries})...")
                        time.sleep(2 ** attempt)  # Exponential backoff
                        continue
                
                # Connection established
                self.is_connected = True
                self.transport = self.client.get_transport()
                self.sftp = self.client.open_sftp()
                self.logger.info(f"Connected successfully to {host}:{port}")
                return True
                
            except paramiko.SSHException as e:
                self.logger.error(f"SSH error: {e}")
                if attempt == max_retries - 1:
                    raise
                time.sleep(2 ** attempt)
            except socket.error as e:
                self.logger.error(f"Socket error: {e}")
                if attempt == max_retries - 1:
                    raise
                time.sleep(2 ** attempt)
            except Exception as e:
                self.logger.error(f"Connection error: {e}")
                if attempt == max_retries - 1:
                    raise
                time.sleep(2 ** attempt)
        
        return False
    
    def _load_private_key(self, key_path: str):
        """
        Load private key from file.
        
        Args:
            key_path: Path to private key file
            
        Returns:
            paramiko.PKey: Private key object
        """
        try:
            key_path = Path(key_path).expanduser()
            if not key_path.exists():
                self.logger.warning(f"Private key not found: {key_path}")
                return None
            
            # Try different key types
            for key_class, key_name in [
                (paramiko.RSAKey, "RSA"),
                (paramiko.DSSKey, "DSS"),
                (paramiko.ECDSAKey, "ECDSA"),
                (paramiko.Ed25519Key, "Ed25519"),
            ]:
                try:
                    if 'password' in self.config:
                        key = key_class.from_private_key_file(
                            str(key_path),
                            password=self.config['password']
                        )
                    else:
                        key = key_class.from_private_key_file(str(key_path))
                    self.logger.debug(f"Loaded {key_name} private key")
                    return key
                except paramiko.SSHException:
                    continue
            
            self.logger.warning(f"Unsupported private key format: {key_path}")
            return None
            
        except Exception as e:
            self.logger.error(f"Failed to load private key: {e}")
            return None
    
    @log_function_call(level="DEBUG")
    def execute_command(self, command: str, use_sudo: bool = False) -> Tuple[str, str]:
        """
        Execute a command on the remote system.
        
        Args:
            command: Command to execute
            use_sudo: Whether to use sudo (requires password)
            
        Returns:
            Tuple[str, str]: (stdout, stderr)
        """
        if not self.is_connected:
            raise ConnectionError("Not connected to SSH server")
        
        try:
            # If sudo is requested, wrap the command
            if use_sudo:
                sudo_password = self.config.get('sudo_password')
                if not sudo_password:
                    self.logger.warning("No sudo password provided, attempting without sudo")
                else:
                    # Using 'echo' to provide password is insecure but common
                    # In production, use expect-like handling or SSH keys
                    command = f"echo '{sudo_password}' | sudo -S {command} 2>&1"
            
            self.logger.debug(f"Executing: {command}")
            stdin, stdout, stderr = self.client.exec_command(command)
            
            # Read output
            stdout_output = stdout.read().decode('utf-8', errors='ignore')
            stderr_output = stderr.read().decode('utf-8', errors='ignore')
            
            # Log output (truncated for large outputs)
            if len(stdout_output) > 1000:
                self.logger.debug(f"Stdout ({len(stdout_output)} bytes, truncated): {stdout_output[:500]}...")
            else:
                self.logger.debug(f"Stdout: {stdout_output}")
            
            return stdout_output, stderr_output
            
        except Exception as e:
            self.logger.error(f"Command execution failed: {e}")
            raise
    
    @log_function_call(level="DEBUG")
    def execute_commands(self, commands: List[str]) -> Dict[str, Tuple[str, str]]:
        """
        Execute multiple commands in sequence.
        
        Args:
            commands: List of commands to execute
            
        Returns:
            Dict[str, Tuple[str, str]]: Mapping of command to (stdout, stderr)
        """
        results = {}
        for command in commands:
            self.logger.debug(f"Executing command {len(results) + 1}/{len(commands)}")
            results[command] = self.execute_command(command)
        return results
    
    @log_function_call(level="DEBUG")
    def upload_file(self, local_path: Union[str, Path], remote_path: str, 
                   show_progress: bool = True) -> bool:
        """
        Upload a file using SFTP.
        
        Args:
            local_path: Local file path
            remote_path: Remote file path
            show_progress: Whether to show upload progress
            
        Returns:
            bool: True if upload successful
        """
        if not self.sftp:
            raise ConnectionError("SFTP not available")
        
        local_path = Path(local_path)
        if not local_path.exists():
            raise FileNotFoundError(f"Local file not found: {local_path}")
        
        file_size = local_path.stat().st_size
        bytes_transferred = 0
        last_log_time = time.time()
        
        self.logger.info(f"Uploading {local_path} ({file_size} bytes) to {remote_path}")
        
        try:
            # Ensure remote directory exists
            remote_dir = str(Path(remote_path).parent)
            try:
                self.sftp.listdir(remote_dir)
            except IOError:
                # Directory doesn't exist, create it
                self.sftp.mkdir(remote_dir)
            
            def progress_callback(transferred: int, total: int):
                """Callback for upload progress."""
                nonlocal bytes_transferred, last_log_time
                bytes_transferred = transferred
                if show_progress and time.time() - last_log_time > 1:
                    progress = (transferred / total) * 100
                    self.logger.debug(f"Upload progress: {progress:.1f}%")
                    last_log_time = time.time()
            
            # Upload file
            self.sftp.put(str(local_path), remote_path, callback=progress_callback)
            
            # Verify upload
            remote_size = self.sftp.stat(remote_path).st_size
            if remote_size != file_size:
                self.logger.warning(f"Upload verification failed: {remote_size} != {file_size}")
                return False
            
            self.logger.info(f"Upload complete: {remote_path} ({remote_size} bytes)")
            return True
            
        except Exception as e:
            self.logger.error(f"Upload failed: {e}")
            return False
    
    @log_function_call(level="DEBUG")
    def download_file(self, remote_path: str, local_path: Union[str, Path],
                     show_progress: bool = True) -> bool:
        """
        Download a file using SFTP.
        
        Args:
            remote_path: Remote file path
            local_path: Local file path
            show_progress: Whether to show download progress
            
        Returns:
            bool: True if download successful
        """
        if not self.sftp:
            raise ConnectionError("SFTP not available")
        
        local_path = Path(local_path)
        remote_size = self.sftp.stat(remote_path).st_size
        bytes_transferred = 0
        last_log_time = time.time()
        
        self.logger.info(f"Downloading {remote_path} ({remote_size} bytes) to {local_path}")
        
        try:
            # Ensure local directory exists
            local_path.parent.mkdir(parents=True, exist_ok=True)
            
            def progress_callback(transferred: int, total: int):
                """Callback for download progress."""
                nonlocal bytes_transferred, last_log_time
                bytes_transferred = transferred
                if show_progress and time.time() - last_log_time > 1:
                    progress = (transferred / total) * 100
                    self.logger.debug(f"Download progress: {progress:.1f}%")
                    last_log_time = time.time()
            
            # Download file
            self.sftp.get(remote_path, str(local_path), callback=progress_callback)
            
            # Verify download
            local_size = local_path.stat().st_size
            if local_size != remote_size:
                self.logger.warning(f"Download verification failed: {local_size} != {remote_size}")
                return False
            
            self.logger.info(f"Download complete: {local_path} ({local_size} bytes)")
            return True
            
        except Exception as e:
            self.logger.error(f"Download failed: {e}")
            return False
    
    @log_function_call(level="DEBUG")
    def interactive_shell(self, commands: List[str]) -> str:
        """
        Execute commands in an interactive shell.
        
        This is useful for commands that require terminal interaction
        (e.g., enabling privilege mode on network devices).
        
        Args:
            commands: List of commands to send
            
        Returns:
            str: Combined output from the shell session
        """
        if not self.is_connected:
            raise ConnectionError("Not connected to SSH server")
        
        try:
            # Open an interactive shell session
            channel = self.client.invoke_shell()
            channel.settimeout(10)
            
            output = []
            for command in commands:
                channel.send(f"{command}\n")
                time.sleep(0.5)  # Wait for command to execute
                
                # Read output
                while channel.recv_ready():
                    data = channel.recv(1024).decode('utf-8', errors='ignore')
                    output.append(data)
            
            # Close channel
            channel.close()
            
            return ''.join(output)
            
        except Exception as e:
            self.logger.error(f"Interactive shell failed: {e}")
            raise
    
    def close(self):
        """Close the SSH connection."""
        if self.is_connected:
            try:
                if self.sftp:
                    self.sftp.close()
                if self.transport:
                    self.transport.close()
                if self.client:
                    self.client.close()
                self.is_connected = False
                self.logger.info("Connection closed")
            except Exception as e:
                self.logger.error(f"Error closing connection: {e}")
    
    def __enter__(self):
        """Context manager entry."""
        self.connect()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()


def create_ssh_config(
    host: str,
    username: str,
    password: Optional[str] = None,
    private_key_path: Optional[str] = None,
    port: int = 22,
    timeout: int = 10,
    max_retries: int = 3,
    **kwargs
) -> Dict[str, Any]:
    """
    Create an SSH configuration dictionary.
    
    Args:
        host: Target host
        username: Username
        password: Password (optional)
        private_key_path: Path to private key (optional)
        port: SSH port
        timeout: Connection timeout
        max_retries: Number of retries
        **kwargs: Additional configuration
        
    Returns:
        Dict[str, Any]: SSH configuration
    """
    config = {
        'host': host,
        'port': port,
        'username': username,
        'timeout': timeout,
        'max_retries': max_retries,
        **kwargs
    }
    
    if private_key_path:
        config['private_key_path'] = private_key_path
    elif password:
        config['password'] = password
    else:
        raise ValueError("Either password or private_key_path must be provided")
    
    return config
```

### The Verification

Test the Paramiko wrapper:

```bash
cat > test_paramiko.py << 'EOF'
#!/usr/bin/env python3
"""Test script for Paramiko wrapper."""

import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.network.paramiko_wrapper import SSHWrapper, create_ssh_config

def test_paramiko():
    """Test Paramiko wrapper functionality."""
    print("=" * 60)
    print("Testing Paramiko Wrapper")
    print("=" * 60)
    
    # Create test config
    config = create_ssh_config(
        host="localhost",
        username="test",
        password="test",
        timeout=5,
        max_retries=2
    )
    
    print(f"Config: {config['host']}:{config['port']} as {config['username']}")
    
    # Test connection (will fail unless SSH is available)
    try:
        with SSHWrapper(config) as ssh:
            print("Connection established!")
            
            # Test command execution
            stdout, stderr = ssh.execute_command("echo 'Hello from Paramiko'")
            print(f"Command output: {stdout.strip()}")
            
    except Exception as e:
        print(f"Connection failed (expected if SSH not available): {e}")
    
    # Demonstrate configuration creation for different scenarios
    print("\nScenario: Using private key")
    key_config = create_ssh_config(
        host="10.0.0.1",
        username="admin",
        private_key_path="~/.ssh/id_rsa",
        port=2222
    )
    print(f"Private key config: host={key_config['host']}, key={key_config.get('private_key_path')}")
    
    print("\nScenario: Device automation")
    device_config = create_ssh_config(
        host="192.168.1.1",
        username="cisco",
        password="cisco123",
        device_type="cisco_ios"
    )
    print(f"Device config: {device_config}")
    
    return 0

if __name__ == "__main__":
    sys.exit(test_paramiko())
EOF

python test_paramiko.py
```

---

## Step 3.2: Netmiko Deep Dive

### The Target
`pyhack_suite/network/netmiko_wrapper.py` - Multi-vendor device automation

### The Concept
Netmiko builds on Paramiko but adds device-specific logic for hundreds of network device types. Think of it as a universal translator for network devices—you speak to it in one way, and it adapts to speak to Cisco, Juniper, Arista, etc., in their native language.

### The Implementation

Create `pyhack_suite/network/netmiko_wrapper.py`:

```python
#!/usr/bin/env python3
"""
Netmiko wrapper for multi-vendor network device automation.

Netmiko provides unified interfaces for:
- Show commands (show version, show interfaces, etc.)
- Configuration commands (write memory, commit, etc.)
- Save and restore operations
- Compliance checking (NAPALM integration)

Supported device types: 
    cisco_ios, cisco_asa, cisco_nxos, juniper_junos,
    arista_eos, aruba_os, hp_procurve, dell_os9,
    paloalto_panos, f5_ltm, nokia_sros, and many more.

Architecture decision: Netmiko vs Paramiko
- Use Netmiko when you need to support multiple device vendors
- Use Netmiko for standard operations (show/config commands)
- Use Paramiko for custom protocol handling or non-standard interactions
"""

from netmiko import ConnectHandler
from netmiko.base_connection import BaseConnection
from netmiko.ssh_exception import NetMikoTimeoutException, NetMikoAuthenticationException
import time
from typing import Optional, Dict, Any, List, Union, Tuple
from pathlib import Path

from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


class NetmikoWrapper:
    """
    Enhanced Netmiko wrapper for network device automation.
    
    This provides additional functionality beyond Netmiko's base:
    - Batch command execution with error handling
    - Configuration management (backup, restore)
    - Compliance checking
    - Output parsing helper methods
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize the Netmiko wrapper.
        
        Args:
            config: Netmiko device configuration
        """
        self.config = config
        self.connection: Optional[BaseConnection] = None
        self.is_connected = False
        self.host = config.get('host', 'unknown')
        self.device_type = config.get('device_type', 'unknown')
        self.logger = get_logger(f"{__name__}.NetmikoWrapper.{self.host}")
        
        # Common device type families for feature detection
        self._device_family = self._detect_device_family()
    
    def _detect_device_family(self) -> str:
        """
        Detect device family from device_type.
        
        Returns:
            str: Device family (cisco, juniper, arista, etc.)
        """
        device_type = self.config.get('device_type', '').lower()
        
        if 'cisco' in device_type:
            return 'cisco'
        elif 'juniper' in device_type or 'junos' in device_type:
            return 'juniper'
        elif 'arista' in device_type:
            return 'arista'
        elif 'paloalto' in device_type or 'panos' in device_type:
            return 'paloalto'
        elif 'f5' in device_type or 'bigip' in device_type:
            return 'f5'
        else:
            return 'other'
    
    @log_function_call(level="INFO")
    def connect(self) -> bool:
        """
        Establish connection to the network device.
        
        Returns:
            bool: True if connection successful
            
        Raises:
            NetMikoTimeoutException: If connection times out
            NetMikoAuthenticationException: If authentication fails
        """
        try:
            self.logger.info(f"Connecting to {self.host} ({self.device_type})")
            
            # Add timeout and other standard parameters
            connection_params = self.config.copy()
            
            # Ensure required parameters
            if 'timeout' not in connection_params:
                connection_params['timeout'] = 30
            if 'session_timeout' not in connection_params:
                connection_params['session_timeout'] = 60
            
            self.connection = ConnectHandler(**connection_params)
            self.is_connected = True
            
            self.logger.info(f"Connected to {self.host}")
            return True
            
        except NetMikoTimeoutException as e:
            self.logger.error(f"Timeout connecting to {self.host}: {e}")
            raise
        except NetMikoAuthenticationException as e:
            self.logger.error(f"Authentication failed for {self.host}: {e}")
            raise
        except Exception as e:
            self.logger.error(f"Connection failed to {self.host}: {e}")
            raise
    
    @log_function_call(level="DEBUG")
    def send_command(self, command: str, expect_string: Optional[str] = None,
                    strip_prompt: bool = True, strip_command: bool = True) -> str:
        """
        Send a command and get the output.
        
        Args:
            command: Command to execute
            expect_string: Expected prompt pattern (for interactive commands)
            strip_prompt: Remove prompt from output
            strip_command: Remove command from output
            
        Returns:
            str: Command output
        """
        if not self.is_connected or not self.connection:
            raise ConnectionError(f"Not connected to {self.host}")
        
        try:
            self.logger.debug(f"Sending command: {command}")
            
            # Use different send methods based on device family
            output = self.connection.send_command(
                command,
                expect_string=expect_string,
                strip_prompt=strip_prompt,
                strip_command=strip_command,
                read_timeout=30,
            )
            
            # Truncate output for logging
            if len(output) > 200:
                self.logger.debug(f"Output ({len(output)} bytes, truncated): {output[:200]}...")
            else:
                self.logger.debug(f"Output: {output}")
            
            return output
            
        except Exception as e:
            self.logger.error(f"Command failed '{command}': {e}")
            raise
    
    @log_function_call(level="DEBUG")
    def send_commands(self, commands: List[str]) -> Dict[str, str]:
        """
        Send multiple commands and collect outputs.
        
        Args:
            commands: List of commands to execute
            
        Returns:
            Dict[str, str]: Mapping of command to output
        """
        results = {}
        for command in commands:
            try:
                results[command] = self.send_command(command)
            except Exception as e:
                self.logger.error(f"Command '{command}' failed: {e}")
                results[command] = f"ERROR: {e}"
        return results
    
    @log_function_call(level="INFO")
    def send_config(self, config_commands: List[str]) -> str:
        """
        Send configuration commands to the device.
        
        Args:
            config_commands: List of configuration commands
            
        Returns:
            str: Configuration output
        """
        if not self.is_connected or not self.connection:
            raise ConnectionError(f"Not connected to {self.host}")
        
        try:
            self.logger.info(f"Sending {len(config_commands)} config commands")
            
            # Platform-specific configuration handling
            if self._device_family == 'juniper':
                # Juniper requires entering configuration mode
                # Netmiko handles this with send_config_set
                output = self.connection.send_config_set(
                    config_commands,
                    read_timeout=60,
                )
            else:
                # Standard configuration for most platforms
                output = self.connection.send_config_set(
                    config_commands,
                    read_timeout=60,
                )
            
            self.logger.debug(f"Config output: {output[:500]}...")
            
            # Save configuration if needed
            if 'save' not in self.config:
                self.save_config()
            
            return output
            
        except Exception as e:
            self.logger.error(f"Configuration failed: {e}")
            raise
    
    @log_function_call(level="INFO")
    def save_config(self) -> str:
        """
        Save the running configuration to startup.
        
        Returns:
            str: Save command output
        """
        if not self.is_connected or not self.connection:
            raise ConnectionError(f"Not connected to {self.host}")
        
        try:
            self.logger.info("Saving configuration")
            
            # Device-specific save commands
            save_cmd = self._get_save_command()
            
            # Some devices require confirmation or special handling
            if self._device_family == 'juniper':
                output = self.connection.send_command(save_cmd, read_timeout=60)
            elif self._device_family == 'arista':
                output = self.connection.send_command(save_cmd, read_timeout=60)
            else:
                # Cisco and most others
                output = self.connection.send_command(save_cmd, read_timeout=60)
            
            self.logger.info("Configuration saved")
            return output
            
        except Exception as e:
            self.logger.error(f"Save config failed: {e}")
            raise
    
    def _get_save_command(self) -> str:
        """
        Get the appropriate save command for the device type.
        
        Returns:
            str: Save command
        """
        save_commands = {
            'cisco': 'write memory',
            'juniper': 'commit',
            'arista': 'write memory',
            'paloalto': 'commit',
            'f5': 'save sys config',
        }
        return save_commands.get(self._device_family, 'write memory')
    
    @log_function_call(level="INFO")
    def backup_config(self, backup_path: Optional[Path] = None) -> Path:
        """
        Backup the device configuration.
        
        Args:
            backup_path: Directory to save backup (auto-generates if None)
            
        Returns:
            Path: Path to backup file
        """
        if not self.is_connected or not self.connection:
            raise ConnectionError(f"Not connected to {self.host}")
        
        try:
            # Get running configuration
            self.logger.info("Backing up configuration")
            
            # Device-specific show run commands
            show_cmd = self._get_show_config_command()
            config_output = self.send_command(show_cmd)
            
            # Generate backup filename
            if backup_path is None:
                timestamp = time.strftime("%Y%m%d_%H%M%S")
                backup_path = Path(f"backups/{self.host}_{timestamp}.cfg")
            else:
                backup_path = Path(backup_path)
            
            # Create directory if needed
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            
            # Write backup
            backup_path.write_text(config_output)
            self.logger.info(f"Backup saved to {backup_path}")
            
            return backup_path
            
        except Exception as e:
            self.logger.error(f"Backup failed: {e}")
            raise
    
    def _get_show_config_command(self) -> str:
        """
        Get the appropriate show config command.
        
        Returns:
            str: Show config command
        """
        show_commands = {
            'cisco': 'show running-config',
            'juniper': 'show configuration | display set',
            'arista': 'show running-config',
            'paloalto': 'show config running',
            'f5': 'list sys config',
        }
        return show_commands.get(self._device_family, 'show running-config')
    
    @log_function_call(level="INFO")
    def restore_config(self, backup_path: Path, commit: bool = True) -> bool:
        """
        Restore configuration from backup.
        
        Args:
            backup_path: Path to backup file
            commit: Whether to commit/apply the configuration
            
        Returns:
            bool: True if restore successful
        """
        if not self.is_connected or not self.connection:
            raise ConnectionError(f"Not connected to {self.host}")
        
        try:
            self.logger.info(f"Restoring configuration from {backup_path}")
            
            # Read backup
            config_lines = backup_path.read_text().splitlines()
            
            # Remove comments and empty lines
            config_lines = [
                line.strip() for line in config_lines
                if line.strip() and not line.startswith('!')
            ]
            
            # Send configuration
            self.send_config(config_lines)
            
            if commit:
                # Save configuration
                self.save_config()
            
            self.logger.info("Configuration restored successfully")
            return True
            
        except Exception as e:
            self.logger.error(f"Restore failed: {e}")
            return False
    
    @log_function_call(level="INFO")
    def check_compliance(self, baseline_commands: List[str]) -> Dict[str, bool]:
        """
        Check device compliance against baseline.
        
        Args:
            baseline_commands: List of commands to check
            
        Returns:
            Dict[str, bool]: Mapping of check to pass/fail
        """
        results = {}
        
        for command in baseline_commands:
            try:
                output = self.send_command(command)
                # Simple check - command executed successfully
                results[command] = True
                
                # Additional checks can be added here based on command type
                if 'show' in command:
                    if 'error' in output.lower() or 'invalid' in output.lower():
                        results[command] = False
                        
            except Exception:
                results[command] = False
        
        return results
    
    def get_supported_devices(self) -> List[str]:
        """
        Get list of supported device types.
        
        Returns:
            List[str]: List of supported device types
        """
        from netmiko import PLATFORMS
        return list(PLATFORMS.keys())
    
    @log_function_call(level="DEBUG")
    def get_connection_details(self) -> Dict[str, Any]:
        """
        Get connection details for logging/debugging.
        
        Returns:
            Dict[str, Any]: Connection details
        """
        return {
            'host': self.host,
            'device_type': self.device_type,
            'device_family': self._device_family,
            'connected': self.is_connected,
            'session_id': self.connection.session_id if self.connection else None,
            'connected_at': time.time(),
        }
    
    def close(self):
        """Close the connection."""
        if self.is_connected and self.connection:
            try:
                self.connection.disconnect()
                self.is_connected = False
                self.logger.info(f"Connection closed to {self.host}")
            except Exception as e:
                self.logger.error(f"Error closing connection: {e}")
    
    def __enter__(self):
        """Context manager entry."""
        self.connect()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()


def create_netmiko_config(
    host: str,
    device_type: str,
    username: str,
    password: Optional[str] = None,
    secret: Optional[str] = None,
    port: int = 22,
    timeout: int = 30,
    **kwargs
) -> Dict[str, Any]:
    """
    Create a Netmiko device configuration.
    
    Args:
        host: Target host
        device_type: Device type (e.g., 'cisco_ios', 'juniper_junos')
        username: Username
        password: Password
        secret: Enable password (if needed)
        port: SSH port
        timeout: Connection timeout
        **kwargs: Additional Netmiko parameters
        
    Returns:
        Dict[str, Any]: Netmiko configuration
        
    Examples:
        cisco_config = create_netmiko_config(
            host="192.168.1.1",
            device_type="cisco_ios",
            username="admin",
            password="cisco123",
            secret="enable_secret"
        )
        
        juniper_config = create_netmiko_config(
            host="192.168.1.2",
            device_type="juniper_junos",
            username="root",
            password="juniper123"
        )
    """
    config = {
        'device_type': device_type,
        'host': host,
        'username': username,
        'port': port,
        'timeout': timeout,
        **kwargs
    }
    
    if password:
        config['password'] = password
    if secret:
        config['secret'] = secret
    
    return config
```

### The Verification

Test the Netmiko wrapper:

```bash
cat > test_netmiko.py << 'EOF'
#!/usr/bin/env python3
"""Test script for Netmiko wrapper."""

import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.network.netmiko_wrapper import NetmikoWrapper, create_netmiko_config

def test_netmiko():
    """Test Netmiko wrapper functionality."""
    print("=" * 60)
    print("Testing Netmiko Wrapper")
    print("=" * 60)
    
    # Create test configuration for Cisco device
    config = create_netmiko_config(
        host="192.168.1.1",  # Replace with actual device IP
        device_type="cisco_ios",
        username="admin",
        password="password",
        secret="enable_secret",
        timeout=10,
    )
    
    print(f"Config for {config['host']} ({config['device_type']})")
    
    # Test connection (will fail unless you have a device available)
    try:
        with NetmikoWrapper(config) as device:
            print("Connected to device!")
            
            # Test show command
            output = device.send_command("show version")
            print(f"Show version output length: {len(output)} bytes")
            print(f"First 200 chars: {output[:200]}...")
            
            # Test multiple commands
            commands = ["show interfaces", "show ip interface brief"]
            results = device.send_commands(commands)
            print(f"\nExecuted {len(results)} commands")
            
            # Test configuration
            config_commands = [
                "interface GigabitEthernet0/1",
                "description Test Interface",
                "no shutdown"
            ]
            print(f"\nSending {len(config_commands)} config commands...")
            output = device.send_config(config_commands)
            print(f"Config output length: {len(output)} bytes")
            
            # Test backup
            print("\nBacking up configuration...")
            backup_path = device.backup_config()
            print(f"Backup saved to: {backup_path}")
            
    except Exception as e:
        print(f"Connection failed (expected if device not available): {e}")
        print("Tip: Set up a lab device or use mock for testing")
    
    # Show supported devices (just list a sample)
    print("\nSupported device types (sample):")
    with NetmikoWrapper(config) as device:
        supported = device.get_supported_devices()
        for device_type in supported[:5]:
            print(f"  - {device_type}")
        print(f"  ... and {len(supported) - 5} more")
    
    return 0

if __name__ == "__main__":
    sys.exit(test_netmiko())
EOF

python test_netmiko.py
```

---

## Step 3.3: Scapy Deep Dive

### The Target
`pyhack_suite/network/scapy_wrapper.py` - Packet manipulation and analysis

### The Concept
Scapy is different from Paramiko and Netmiko—it works at the packet level rather than the application level. Think of it as a packet forge and sniffer combined. You can:

1. **Create packets** - Build custom packets from scratch
2. **Send packets** - Inject packets onto the network
3. **Sniff packets** - Capture network traffic
4. **Analyze packets** - Parse and inspect packet contents

### The Implementation

Create `pyhack_suite/network/scapy_wrapper.py`:

```python
#!/usr/bin/env python3
"""
Scapy wrapper for packet manipulation and analysis.

Scapy provides powerful packet crafting and sniffing capabilities:
- Build packets with custom fields
- Send packets at Layer 2 (Ethernet) or Layer 3 (IP)
- Sniff network traffic with filters
- Analyze packet contents and structure

Architecture decision: Scapy vs Netmiko/Paramiko
- Use Scapy for packet-level operations (custom protocols, fuzzing)
- Use Netmiko/Paramiko for device management (SSH, CLI)
- Combine them for comprehensive network assessment

Performance considerations:
- Use AsyncSniffer for non-blocking capture
- Use store=False to avoid memory accumulation
- Use filters to reduce captured packets
"""

import asyncio
import threading
import queue
import time
from typing import Optional, Dict, Any, List, Callable, Union, Tuple
from pathlib import Path
import socket
import struct

try:
    from scapy.all import (
        # Core
        IP, TCP, UDP, ICMP, Ethernet, ARP, DNS, HTTP,
        # Packet building
        IPOption, Ether, Raw, Padding,
        # Utilities
        sr, sr1, srp, send, sendp, sniff, wrpcap, rdpcap,
        # Async
        AsyncSniffer,
        # Helpers
        conf, L2Socket, L3Socket,
        # Layer types
        Ether, IP, TCP, UDP, ICMP, ARP,
        # Error handling
        Scapy_Exception,
        # Packet manipulation
        fuzz,
        # Packet fields
        MACField, IPField,
        # Packet classes
        Packet, PacketList,
    )
except ImportError:
    raise ImportError("Scapy not installed. Run: pip install scapy")

from pyhack_suite.core.config import get_config
from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


class ScapyWrapper:
    """
    Enhanced Scapy wrapper for packet operations.
    
    This provides high-level interfaces for common Scapy operations:
    - Sniff packets with filters and callbacks
    - Send packets with configurable timing
    - Analyze packet structures
    - Save and load PCAP files
    
    Features:
    - Non-blocking sniffing with AsyncSniffer
    - Thread-safe packet queues
    - Connection tracking
    - Protocol decoding helpers
    """
    
    def __init__(self, interface: Optional[str] = None):
        """
        Initialize the Scapy wrapper.
        
        Args:
            interface: Network interface to use (defaults to config)
        """
        self.config = get_config()
        self.interface = interface or self.config.network.scapy_interface
        
        # Configure Scapy
        conf.use_pcap = True  # Use pcap for better performance
        conf.verb = 0  # Quiet mode
        
        self.sniffer: Optional[AsyncSniffer] = None
        self.sniffing = False
        self.packet_queue: queue.Queue = queue.Queue()
        self.async_queue: Optional[asyncio.Queue] = None
        
        self.logger = get_logger(f"{__name__}.ScapyWrapper")
        self.logger.info(f"Initialized with interface: {self.interface}")
    
    # ==================== Sending Packets ====================
    
    @log_function_call(level="DEBUG")
    def send_ip_packet(
        self,
        dst_ip: str,
        src_ip: Optional[str] = None,
        payload: Optional[bytes] = None,
        ttl: int = 64,
        tos: int = 0,
        **kwargs
    ) -> Packet:
        """
        Send a custom IP packet.
        
        Args:
            dst_ip: Destination IP
            src_ip: Source IP (spoofing)
            payload: Payload data
            ttl: Time-to-live
            tos: Type of service
            **kwargs: Additional packet fields
            
        Returns:
            Packet: The constructed packet
        
        Example:
            # Send a TCP SYN packet
            wrapper.send_ip_packet(
                dst_ip="192.168.1.100",
                src_ip="10.0.0.1",
                proto="tcp",
                sport=12345,
                dport=80,
                flags="S"
            )
        """
        # Build IP layer
        ip_layer = IP(dst=dst_ip, ttl=ttl, tos=tos)
        if src_ip:
            ip_layer.src = src_ip
        
        # Build transport layer based on protocol
        proto = kwargs.get('proto', 'tcp').lower()
        
        if proto == 'tcp':
            sport = kwargs.get('sport', 12345)
            dport = kwargs.get('dport', 80)
            flags = kwargs.get('flags', 'S')
            seq = kwargs.get('seq', 1000)
            
            tcp_layer = TCP(sport=sport, dport=dport, flags=flags, seq=seq)
            packet = ip_layer / tcp_layer
            
        elif proto == 'udp':
            sport = kwargs.get('sport', 12345)
            dport = kwargs.get('dport', 53)
            
            udp_layer = UDP(sport=sport, dport=dport)
            packet = ip_layer / udp_layer
            
        elif proto == 'icmp':
            icmp_type = kwargs.get('icmp_type', 8)  # 8 = echo request
            icmp_code = kwargs.get('icmp_code', 0)
            
            icmp_layer = ICMP(type=icmp_type, code=icmp_code)
            packet = ip_layer / icmp_layer
            
        else:
            raise ValueError(f"Unsupported protocol: {proto}")
        
        # Add payload
        if payload:
            packet = packet / Raw(load=payload)
        
        # Send packet
        self.logger.info(f"Sending packet to {dst_ip}")
        send(packet, verbose=False)
        
        return packet
    
    @log_function_call(level="DEBUG")
    def send_ethernet_packet(
        self,
        dst_mac: str,
        src_mac: Optional[str] = None,
        ether_type: int = 0x0800,  # IPv4
        payload: Optional[bytes] = None,
        **kwargs
    ) -> Packet:
        """
        Send a custom Ethernet packet (Layer 2).
        
        Args:
            dst_mac: Destination MAC
            src_mac: Source MAC
            ether_type: Ethernet type (0x0800 for IPv4, 0x0806 for ARP)
            payload: Payload data
            **kwargs: Additional packet fields
            
        Returns:
            Packet: The constructed packet
        
        Example:
            # Send an ARP request
            wrapper.send_ethernet_packet(
                dst_mac="ff:ff:ff:ff:ff:ff",
                ether_type=0x0806,
                arp_op=1,
                arp_psrc="192.168.1.1",
                arp_pdst="192.168.1.100"
            )
        """
        # Build Ethernet layer
        eth_layer = Ether(dst=dst_mac)
        if src_mac:
            eth_layer.src = src_mac
        
        # Build payload layer
        if ether_type == 0x0800 and payload:
            # IPv4 packet
            packet = eth_layer / IP(load=payload)
        elif ether_type == 0x0806:
            # ARP packet
            arp_op = kwargs.get('arp_op', 1)  # 1 = request, 2 = reply
            arp_psrc = kwargs.get('arp_psrc', '0.0.0.0')
            arp_pdst = kwargs.get('arp_pdst', '0.0.0.0')
            
            arp_layer = ARP(
                op=arp_op,
                psrc=arp_psrc,
                pdst=arp_pdst,
            )
            
            # Set MAC addresses if provided
            if kwargs.get('hwsrc'):
                arp_layer.hwsrc = kwargs['hwsrc']
            if kwargs.get('hwdst'):
                arp_layer.hwdst = kwargs['hwdst']
            
            packet = eth_layer / arp_layer
        else:
            # Raw Ethernet packet
            packet = eth_layer / Raw(load=payload or b'')
        
        # Send packet
        self.logger.info(f"Sending Ethernet packet to {dst_mac}")
        sendp(packet, verbose=False, iface=self.interface)
        
        return packet
    
    # ==================== Sniffing Packets ====================
    
    @log_function_call(level="DEBUG")
    def sniff_sync(
        self,
        count: int = 100,
        timeout: int = 10,
        filter_str: Optional[str] = None,
        stop_filter: Optional[Callable] = None,
    ) -> List[Packet]:
        """
        Sniff packets synchronously (blocking).
        
        Args:
            count: Number of packets to capture
            timeout: Time to wait (seconds)
            filter_str: BPF filter (e.g., "tcp port 80")
            stop_filter: Stop filtering function
            
        Returns:
            List[Packet]: List of captured packets
        """
        self.logger.info(f"Starting sniff: count={count}, timeout={timeout}s, filter={filter_str}")
        
        try:
            packets = sniff(
                iface=self.interface,
                count=count,
                timeout=timeout,
                filter=filter_str,
                stop_filter=stop_filter,
                promisc=self.config.network.scapy_promiscuous,
                store=True,
            )
            
            self.logger.info(f"Captured {len(packets)} packets")
            return packets
            
        except Exception as e:
            self.logger.error(f"Sniff failed: {e}")
            raise
    
    @log_function_call(level="DEBUG")
    def sniff_async_start(
        self,
        callback: Optional[Callable] = None,
        filter_str: Optional[str] = None,
        timeout: int = 60,
        count: int = 0,
        stop_event: Optional[threading.Event] = None,
    ):
        """
        Start asynchronous packet sniffing in a background thread.
        
        Args:
            callback: Function to call for each packet
            filter_str: BPF filter
            timeout: Maximum sniff time
            count: Maximum packets to capture (0 = unlimited)
            stop_event: Event to signal stop
            
        Returns:
            AsyncSniffer: The sniffer object
            
        Example:
            def handle_packet(pkt):
                print(f"Captured: {pkt.summary()}")
            
            wrapper = ScapyWrapper()
            wrapper.sniff_async_start(
                callback=handle_packet,
                filter_str="tcp port 80",
                timeout=30
            )
            
            # Do other work while sniffing...
            time.sleep(10)
            
            # Stop sniffing
            wrapper.sniff_async_stop()
        """
        if self.sniffing:
            self.logger.warning("Sniffer already running")
            return
        
        self.logger.info(f"Starting async sniff: filter={filter_str}, timeout={timeout}s")
        
        # Create stop event if not provided
        if stop_event is None:
            stop_event = threading.Event()
        
        # Define packet handler
        def packet_handler(packet):
            """Handle each captured packet."""
            # Add to queue
            self.packet_queue.put(packet)
            
            # Call user callback if provided
            if callback:
                try:
                    callback(packet)
                except Exception as e:
                    self.logger.error(f"Callback error: {e}")
        
        # Create and start sniffer
        self.sniffer = AsyncSniffer(
            iface=self.interface,
            filter=filter_str,
            prn=packet_handler,
            count=count,
            timeout=timeout,
            promisc=self.config.network.scapy_promiscuous,
            store=False,  # Don't store packets in memory
        )
        
        self.sniffer.start()
        self.sniffing = True
        self.logger.info("Async sniff started")
        
        return self.sniffer
    
    def sniff_async_stop(self):
        """Stop asynchronous sniffing."""
        if self.sniffer and self.sniffing:
            self.logger.info("Stopping async sniff")
            self.sniffer.stop()
            self.sniffing = False
            
            # Clear queue
            while not self.packet_queue.empty():
                try:
                    self.packet_queue.get_nowait()
                except queue.Empty:
                    break
            
            self.logger.info("Async sniff stopped")
    
    def get_packets_from_queue(self, max_count: int = 100) -> List[Packet]:
        """
        Get packets from the queue.
        
        Args:
            max_count: Maximum packets to retrieve
            
        Returns:
            List[Packet]: Retrieved packets
        """
        packets = []
        for _ in range(max_count):
            try:
                packet = self.packet_queue.get_nowait()
                packets.append(packet)
            except queue.Empty:
                break
        return packets
    
    # ==================== Packet Analysis ====================
    
    @staticmethod
    def get_packet_summary(packet: Packet) -> Dict[str, Any]:
        """
        Get a structured summary of a packet.
        
        Args:
            packet: Scapy packet
            
        Returns:
            Dict[str, Any]: Packet summary
        """
        summary = {
            'layers': [],
            'size': len(packet),
            'time': packet.time if hasattr(packet, 'time') else None,
        }
        
        # Iterate through layers
        layers = []
        p = packet
        while p:
            layer_name = p.name
            layers.append(layer_name)
            
            # Extract common fields
            if layer_name == 'Ethernet':
                summary['eth'] = {
                    'src': p.src,
                    'dst': p.dst,
                    'type': p.type,
                }
            elif layer_name == 'IP':
                summary['ip'] = {
                    'src': p.src,
                    'dst': p.dst,
                    'ttl': p.ttl,
                    'proto': p.proto,
                }
            elif layer_name == 'TCP':
                summary['tcp'] = {
                    'sport': p.sport,
                    'dport': p.dport,
                    'flags': p.flags,
                    'seq': p.seq,
                    'ack': p.ack,
                }
            elif layer_name == 'UDP':
                summary['udp'] = {
                    'sport': p.sport,
                    'dport': p.dport,
                    'len': p.len,
                }
            elif layer_name == 'ICMP':
                summary['icmp'] = {
                    'type': p.type,
                    'code': p.code,
                }
            
            p = p.payload
            
        summary['layers'] = layers
        return summary
    
    @staticmethod
    def extract_payload(packet: Packet, max_size: int = 1024) -> Optional[bytes]:
        """
        Extract payload data from a packet.
        
        Args:
            packet: Scapy packet
            max_size: Maximum payload size to extract
            
        Returns:
            Optional[bytes]: Payload data
        """
        try:
            if packet.haslayer(Raw):
                payload = packet[Raw].load
                if len(payload) > max_size:
                    payload = payload[:max_size] + b'...[truncated]'
                return payload
        except Exception:
            pass
        return None
    
    # ==================== PCAP Operations ====================
    
    @log_function_call(level="DEBUG")
    def save_pcap(self, packets: List[Packet], filename: Union[str, Path]) -> Path:
        """
        Save packets to a PCAP file.
        
        Args:
            packets: List of packets
            filename: Output filename
            
        Returns:
            Path: Path to saved file
        """
        filename = Path(filename)
        filename.parent.mkdir(parents=True, exist_ok=True)
        
        self.logger.info(f"Saving {len(packets)} packets to {filename}")
        wrpcap(str(filename), packets)
        
        return filename
    
    @log_function_call(level="DEBUG")
    def load_pcap(self, filename: Union[str, Path]) -> PacketList:
        """
        Load packets from a PCAP file.
        
        Args:
            filename: PCAP file to load
            
        Returns:
            PacketList: Loaded packets
        """
        filename = Path(filename)
        if not filename.exists():
            raise FileNotFoundError(f"PCAP file not found: {filename}")
        
        self.logger.info(f"Loading packets from {filename}")
        packets = rdpcap(str(filename))
        self.logger.info(f"Loaded {len(packets)} packets")
        
        return packets
    
    # ==================== Scanning and Recon ====================
    
    @log_function_call(level="INFO")
    def tcp_ping(self, target: str, port: int = 80, timeout: int = 2) -> bool:
        """
        Perform a TCP ping (SYN scan).
        
        Args:
            target: Target IP
            port: Port to scan
            timeout: Timeout in seconds
            
        Returns:
            bool: True if target responds
        """
        self.logger.info(f"TCP ping to {target}:{port}")
        
        try:
            # Build SYN packet
            ip_layer = IP(dst=target)
            tcp_layer = TCP(dport=port, flags='S', seq=1000)
            packet = ip_layer / tcp_layer
            
            # Send and wait for response
            response = sr1(packet, timeout=timeout, verbose=False)
            
            if response:
                if response.haslayer(TCP):
                    if response[TCP].flags & 0x12:  # SYN-ACK
                        self.logger.debug(f"TCP ping successful: {target}:{port} is open")
                        return True
                    elif response[TCP].flags & 0x04:  # RST
                        self.logger.debug(f"TCP ping response: {target}:{port} is closed")
                        return False
            
            self.logger.debug(f"TCP ping failed: {target}:{port} no response")
            return False
            
        except Exception as e:
            self.logger.error(f"TCP ping error: {e}")
            return False
    
    @log_function_call(level="INFO")
    def arp_scan(self, ip_range: str) -> List[Dict[str, str]]:
        """
        Perform an ARP scan.
        
        Args:
            ip_range: IP range (e.g., "192.168.1.0/24")
            
        Returns:
            List[Dict[str, str]]: List of {ip: mac} mappings
        """
        self.logger.info(f"ARP scan: {ip_range}")
        
        try:
            # Build ARP request
            arp_request = ARP(pdst=ip_range)
            
            # Send and receive responses
            answered, unanswered = srp(
                arp_request,
                timeout=2,
                verbose=False,
                iface=self.interface
            )
            
            # Process responses
            results = []
            for sent, received in answered:
                results.append({
                    'ip': received.psrc,
                    'mac': received.hwsrc,
                })
            
            self.logger.info(f"Found {len(results)} hosts")
            return results
            
        except Exception as e:
            self.logger.error(f"ARP scan failed: {e}")
            return []
    
    # ==================== Cleanup ====================
    
    def close(self):
        """Close connections and clean up."""
        if self.sniffing:
            self.sniff_async_stop()
        
        # Clear queues
        while not self.packet_queue.empty():
            try:
                self.packet_queue.get_nowait()
            except queue.Empty:
                break
        
        self.logger.info("Scapy wrapper closed")
    
    def __enter__(self):
        """Context manager entry."""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.close()
```

### The Verification

Test the Scapy wrapper (requires root/admin privileges):

```bash
# Install Scapy if not already installed
pip install scapy

cat > test_scapy.py << 'EOF'
#!/usr/bin/env python3
"""Test script for Scapy wrapper."""

import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.network.scapy_wrapper import ScapyWrapper

def test_scapy():
    """Test Scapy wrapper functionality."""
    print("=" * 60)
    print("Testing Scapy Wrapper")
    print("=" * 60)
    
    # Create wrapper
    with ScapyWrapper(interface="eth0") as wrapper:
        print(f"Using interface: {wrapper.interface}")
        
        # Test packet creation and sending
        print("\n1. Creating and sending IP packet...")
        try:
            packet = wrapper.send_ip_packet(
                dst_ip="8.8.8.8",
                src_ip="10.0.0.1",
                proto="icmp",
                ttl=64
            )
            print(f"  Sent: {packet.summary()}")
        except Exception as e:
            print(f"  Send failed (expected without permissions): {e}")
        
        # Test ARP scan
        print("\n2. Performing ARP scan...")
        try:
            results = wrapper.arp_scan("192.168.1.0/24")
            print(f"  Found {len(results)} hosts")
            if results:
                for host in results[:5]:
                    print(f"    {host['ip']} -> {host['mac']}")
                if len(results) > 5:
                    print(f"    ... and {len(results) - 5} more")
        except Exception as e:
            print(f"  ARP scan failed: {e}")
        
        # Test TCP ping
        print("\n3. Testing TCP ping...")
        try:
            result = wrapper.tcp_ping("8.8.8.8", port=80)
            print(f"  8.8.8.8:80 is {'reachable' if result else 'unreachable'}")
        except Exception as e:
            print(f"  TCP ping failed: {e}")
        
        # Test sniffing (brief)
        print("\n4. Testing packet sniffing...")
        try:
            # Sniff for 5 packets with filter
            packets = wrapper.sniff_sync(
                count=5,
                timeout=5,
                filter_str="icmp or tcp port 80"
            )
            print(f"  Captured {len(packets)} packets")
            
            # Show summaries
            for packet in packets[:3]:
                summary = wrapper.get_packet_summary(packet)
                print(f"    Packet: {packet.summary()}")
                print(f"    Layers: {summary['layers']}")
                if 'ip' in summary:
                    print(f"    IP: {summary['ip']['src']} -> {summary['ip']['dst']}")
                
        except Exception as e:
            print(f"  Sniff failed (may need root permissions): {e}")
        
        # Test async sniffing
        print("\n5. Testing async sniffing...")
        try:
            packet_count = [0]
            
            def callback(pkt):
                packet_count[0] += 1
                print(f"  Got packet: {pkt.summary()}")
            
            wrapper.sniff_async_start(
                callback=callback,
                filter_str="icmp",
                timeout=3,
                count=3
            )
            
            # Wait for sniffing
            time.sleep(4)
            
            # Stop
            wrapper.sniff_async_stop()
            print(f"  Captured {packet_count[0]} packets async")
            
        except Exception as e:
            print(f"  Async sniff failed: {e}")
    
    print("\nScapy test complete!")
    return 0

if __name__ == "__main__":
    sys.exit(test_scapy())
EOF

# Run with root permissions if needed
sudo python test_scapy.py
```

---

## Step 3.4: Protocol Abstraction Layer

### The Target
`pyhack_suite/network/protocol_abstractions.py` - Unified interface for all network operations

### The Concept
Now that we understand Paramiko, Netmiko, and Scapy, we can build an abstraction layer that provides a single interface for all operations. This is like having a universal remote that works with your TV, sound system, and streaming device.

The abstraction layer:
1. **Unifies interfaces** - One API for SSH, device automation, and packet operations
2. **Vendor-agnostic** - Same code works with Cisco, Juniper, Arista, etc.
3. **Extensible** - Easy to add new protocols and devices
4. **Provides defaults** - Sensible defaults for common operations

### The Implementation

Create `pyhack_suite/network/protocol_abstractions.py`:

```python
#!/usr/bin/env python3
"""
Protocol abstraction layer for PyHack Suite.

This module provides unified interfaces for:
- Device management (SSH/Netmiko)
- Packet operations (Scapy)
- Custom protocols

The abstraction layer enables:
- Vendor-agnostic operations
- Easy protocol switching
- Common interface for all network operations

Design pattern: Strategy pattern with factories
"""

from abc import ABC, abstractmethod
from typing import Optional, Dict, Any, List, Union, Tuple
from enum import Enum
from pathlib import Path
import time

from pyhack_suite.core.config import get_config
from pyhack_suite.core.session_manager import (
    SessionManager,
    ConnectionConfig,
    ConnectionType,
    session_context,
)
from pyhack_suite.network.paramiko_wrapper import SSHWrapper, create_ssh_config
from pyhack_suite.network.netmiko_wrapper import NetmikoWrapper, create_netmiko_config
from pyhack_suite.network.scapy_wrapper import ScapyWrapper
from pyhack_suite.utils.logging import get_logger, log_function_call

logger = get_logger(__name__)


class ProtocolType(Enum):
    """Supported protocol types."""
    SSH = "ssh"
    NETMIKO = "netmiko"
    RAW_SOCKET = "raw_socket"
    SCAPY = "scapy"
    HTTP = "http"
    HTTPS = "https"
    TELNET = "telnet"


class DeviceFamily(Enum):
    """Network device families."""
    CISCO = "cisco"
    JUNIPER = "juniper"
    ARISTA = "arista"
    PALO_ALTO = "palo_alto"
    F5 = "f5"
    GENERIC = "generic"


class NetworkInterface(ABC):
    """
    Abstract base class for network interfaces.
    
    All network operation implementations should inherit from this
    to ensure a consistent API.
    """
    
    @abstractmethod
    def connect(self) -> bool:
        """Establish connection."""
        pass
    
    @abstractmethod
    def disconnect(self):
        """Close connection."""
        pass
    
    @abstractmethod
    def execute(self, command: str) -> Tuple[str, str]:
        """Execute a command."""
        pass
    
    @abstractmethod
    def is_connected(self) -> bool:
        """Check if connected."""
        pass


class SSHInterface(NetworkInterface):
    """
    SSH interface using Paramiko.
    
    This implementation uses Paramiko for fine-grained SSH control.
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize SSH interface.
        
        Args:
            config: SSH configuration
        """
        self.config = config
        self.wrapper: Optional[SSHWrapper] = None
        self._connected = False
        self.logger = get_logger(f"{__name__}.SSHInterface.{config.get('host', 'unknown')}")
    
    @log_function_call(level="INFO")
    def connect(self) -> bool:
        """Establish SSH connection."""
        self.wrapper = SSHWrapper(self.config)
        self._connected = self.wrapper.connect()
        return self._connected
    
    def disconnect(self):
        """Close SSH connection."""
        if self.wrapper:
            self.wrapper.close()
            self._connected = False
    
    @log_function_call(level="DEBUG")
    def execute(self, command: str) -> Tuple[str, str]:
        """Execute command over SSH."""
        if not self._connected or not self.wrapper:
            raise ConnectionError("Not connected")
        return self.wrapper.execute_command(command)
    
    def is_connected(self) -> bool:
        """Check if connected."""
        return self._connected


class NetmikoInterface(NetworkInterface):
    """
    Netmiko interface for network devices.
    
    This implementation uses Netmiko for multi-vendor device automation.
    """
    
    def __init__(self, config: Dict[str, Any]):
        """
        Initialize Netmiko interface.
        
        Args:
            config: Netmiko configuration
        """
        self.config = config
        self.wrapper: Optional[NetmikoWrapper] = None
        self._connected = False
        self.logger = get_logger(f"{__name__}.NetmikoInterface.{config.get('host', 'unknown')}")
    
    @log_function_call(level="INFO")
    def connect(self) -> bool:
        """Establish device connection."""
        self.wrapper = NetmikoWrapper(self.config)
        self._connected = self.wrapper.connect()
        return self._connected
    
    def disconnect(self):
        """Close connection."""
        if self.wrapper:
            self.wrapper.close()
            self._connected = False
    
    @log_function_call(level="DEBUG")
    def execute(self, command: str) -> Tuple[str, str]:
        """Execute command on device."""
        if not self._connected or not self.wrapper:
            raise ConnectionError("Not connected")
        output = self.wrapper.send_command(command)
        return output, ""  # Netmiko typically doesn't separate stderr
    
    def send_config(self, commands: List[str]) -> str:
        """
        Send configuration commands.
        
        Args:
            commands: Configuration commands
            
        Returns:
            str: Command output
        """
        if not self._connected or not self.wrapper:
            raise ConnectionError("Not connected")
        return self.wrapper.send_config(commands)
    
    def backup_config(self, backup_path: Optional[Path] = None) -> Path:
        """
        Backup device configuration.
        
        Args:
            backup_path: Backup file path
            
        Returns:
            Path: Path to backup
        """
        if not self._connected or not self.wrapper:
            raise ConnectionError("Not connected")
        return self.wrapper.backup_config(backup_path)
    
    def is_connected(self) -> bool:
        """Check if connected."""
        return self._connected


class PacketInterface(NetworkInterface):
    """
    Packet interface using Scapy.
    
    This implementation provides packet-level operations.
    """
    
    def __init__(self, interface: Optional[str] = None):
        """
        Initialize packet interface.
        
        Args:
            interface: Network interface
        """
        self.wrapper = ScapyWrapper(interface=interface)
        self._connected = True  # Always connected for packet operations
        self.logger = get_logger(f"{__name__}.PacketInterface")
    
    def connect(self) -> bool:
        """Packet interface is always connected."""
        return True
    
    def disconnect(self):
        """Clean up."""
        if self.wrapper:
            self.wrapper.close()
        self._connected = False
    
    @log_function_call(level="DEBUG")
    def execute(self, command: str) -> Tuple[str, str]:
        """
        Execute a packet operation.
        
        This is a string-based command interface for packet operations.
        Commands format: "type:target:port" or "action:target"
        
        Examples:
            "ping:8.8.8.8" - ICMP ping
            "tcp_ping:8.8.8.8:80" - TCP SYN scan
            "arp_scan:192.168.1.0/24" - ARP scan
        """
        parts = command.split(':')
        action = parts[0].lower()
        
        if action == 'ping':
            target = parts[1]
            return self._icmp_ping(target), ""
        
        elif action == 'tcp_ping':
            target = parts[1]
            port = int(parts[2]) if len(parts) > 2 else 80
            result = self.wrapper.tcp_ping(target, port)
            return f"TCP ping to {target}:{port} {'successful' if result else 'failed'}", ""
        
        elif action == 'arp_scan':
            target = parts[1]
            results = self.wrapper.arp_scan(target)
            output = f"Found {len(results)} hosts:\n"
            for host in results:
                output += f"  {host['ip']} -> {host['mac']}\n"
            return output, ""
        
        else:
            raise ValueError(f"Unknown packet action: {action}")
    
    def _icmp_ping(self, target: str) -> str:
        """
        Perform ICMP ping.
        
        Args:
            target: Target IP
            
        Returns:
            str: Ping results
        """
        from scapy.all import IP, ICMP, sr1
        
        packet = IP(dst=target) / ICMP()
        response = sr1(packet, timeout=2, verbose=False)
        
        if response:
            return f"Ping to {target}: Response received (RTT: {response.time - packet.time:.2f}s)"
        else:
            return f"Ping to {target}: No response"
    
    def sniff_packets(self, count: int = 10, timeout: int = 10,
                     filter_str: Optional[str] = None) -> List[Any]:
        """
        Sniff packets.
        
        Args:
            count: Number of packets
            timeout: Timeout in seconds
            filter_str: BPF filter
            
        Returns:
            List[Any]: Captured packets
        """
        return self.wrapper.sniff_sync(count=count, timeout=timeout, filter_str=filter_str)
    
    def is_connected(self) -> bool:
        """Check if connected."""
        return self._connected


class ProtocolFactory:
    """
    Factory for creating protocol interfaces.
    
    This factory implements the Abstract Factory pattern to create
    appropriate protocol interfaces based on configuration.
    """
    
    @staticmethod
    def create_interface(config: Dict[str, Any]) -> NetworkInterface:
        """
        Create a network interface based on configuration.
        
        Args:
            config: Configuration with 'protocol' field
            
        Returns:
            NetworkInterface: Protocol interface
            
        Raises:
            ValueError: If protocol is unsupported
        """
        protocol = config.get('protocol', 'ssh').lower()
        
        if protocol in ['ssh', 'paramiko']:
            # SSH configuration
            ssh_config = create_ssh_config(
                host=config['host'],
                username=config['username'],
                password=config.get('password'),
                private_key_path=config.get('private_key_path'),
                port=config.get('port', 22),
                timeout=config.get('timeout', 10),
            )
            return SSHInterface(ssh_config)
        
        elif protocol in ['netmiko', 'device']:
            # Netmiko configuration
            netmiko_config = create_netmiko_config(
                host=config['host'],
                device_type=config['device_type'],
                username=config['username'],
                password=config.get('password'),
                secret=config.get('secret'),
                port=config.get('port', 22),
                timeout=config.get('timeout', 30),
            )
            return NetmikoInterface(netmiko_config)
        
        elif protocol in ['scapy', 'packet', 'pcap']:
            # Packet interface
            interface = config.get('interface')
            return PacketInterface(interface=interface)
        
        else:
            raise ValueError(f"Unsupported protocol: {protocol}")


class UnifiedNetworkManager:
    """
    Unified network manager that provides a single interface for all operations.
    
    This manager combines SSH, Netmiko, and Scapy capabilities into one
    easy-to-use interface. It automatically selects the appropriate
    implementation based on the target type.
    """
    
    def __init__(self):
        """Initialize the network manager."""
        self.config = get_config()
        self.interfaces: Dict[str, NetworkInterface] = {}
        self.logger = get_logger(__name__)
        self.session_manager = SessionManager()
        
        # Default session timeout
        self.session_timeout = 300  # 5 minutes
    
    @log_function_call(level="INFO")
    def connect(self, name: str, config: Dict[str, Any]) -> bool:
        """
        Connect to a target.
        
        Args:
            name: Unique name for the connection
            config: Connection configuration
            
        Returns:
            bool: True if connection successful
        """
        # Create appropriate interface
        interface = ProtocolFactory.create_interface(config)
        
        # Connect
        try:
            result = interface.connect()
            if result:
                self.interfaces[name] = interface
                self.logger.info(f"Connected to {name}")
            return result
        except Exception as e:
            self.logger.error(f"Connection failed for {name}: {e}")
            return False
    
    def execute(self, name: str, command: str) -> Tuple[str, str]:
        """
        Execute a command on a connected target.
        
        Args:
            name: Target name (from connect)
            command: Command to execute
            
        Returns:
            Tuple[str, str]: (stdout, stderr)
        """
        if name not in self.interfaces:
            raise ValueError(f"Unknown connection: {name}")
        
        interface = self.interfaces[name]
        if not interface.is_connected():
            raise ConnectionError(f"Not connected to {name}")
        
        return interface.execute(command)
    
    def disconnect(self, name: str):
        """
        Disconnect from a target.
        
        Args:
            name: Target name
        """
        if name in self.interfaces:
            self.interfaces[name].disconnect()
            del self.interfaces[name]
            self.logger.info(f"Disconnected from {name}")
    
    def disconnect_all(self):
        """Disconnect from all targets."""
        for name in list(self.interfaces.keys()):
            self.disconnect(name)
        self.logger.info("Disconnected from all targets")
    
    def get_connection_stats(self) -> Dict[str, Dict[str, Any]]:
        """
        Get statistics about connections.
        
        Returns:
            Dict[str, Dict[str, Any]]: Connection statistics
        """
        stats = {}
        for name, interface in self.interfaces.items():
            stats[name] = {
                'connected': interface.is_connected(),
                'type': interface.__class__.__name__,
            }
        return stats
    
    # ==================== Convenience Methods ====================
    
    @log_function_call(level="INFO")
    def ssh_command(self, host: str, username: str, password: str,
                   command: str, port: int = 22) -> Tuple[str, str]:
        """
        Execute a command over SSH (one-off connection).
        
        Args:
            host: Target host
            username: SSH username
            password: SSH password
            command: Command to execute
            port: SSH port
            
        Returns:
            Tuple[str, str]: (stdout, stderr)
        """
        config = {
            'protocol': 'ssh',
            'host': host,
            'username': username,
            'password': password,
            'port': port,
        }
        
        name = f"ssh_{host}_{port}"
        try:
            if self.connect(name, config):
                return self.execute(name, command)
            else:
                return "", "Connection failed"
        finally:
            self.disconnect(name)
    
    @log_function_call(level="INFO")
    def netmiko_command(self, host: str, username: str, password: str,
                       device_type: str, command: str) -> Tuple[str, str]:
        """
        Execute a command on a network device (one-off connection).
        
        Args:
            host: Device IP
            username: Username
            password: Password
            device_type: Device type (e.g., 'cisco_ios')
            command: Command to execute
            
        Returns:
            Tuple[str, str]: (stdout, stderr)
        """
        config = {
            'protocol': 'netmiko',
            'host': host,
            'username': username,
            'password': password,
            'device_type': device_type,
        }
        
        name = f"netmiko_{host}"
        try:
            if self.connect(name, config):
                return self.execute(name, command)
            else:
                return "", "Connection failed"
        finally:
            self.disconnect(name)
    
    @log_function_call(level="INFO")
    def packet_ping(self, target: str, interface: Optional[str] = None) -> str:
        """
        ICMP ping a target.
        
        Args:
            target: Target IP
            interface: Network interface
            
        Returns:
            str: Ping result
        """
        config = {
            'protocol': 'scapy',
            'interface': interface,
        }
        
        name = f"packet_{int(time.time())}"
        try:
            if self.connect(name, config):
                stdout, _ = self.execute(name, f"ping:{target}")
                return stdout
            else:
                return "Packet interface initialization failed"
        finally:
            self.disconnect(name)
    
    @log_function_call(level="INFO")
    def arp_scan(self, ip_range: str, interface: Optional[str] = None) -> str:
        """
        Perform ARP scan.
        
        Args:
            ip_range: IP range (e.g., "192.168.1.0/24")
            interface: Network interface
            
        Returns:
            str: Scan results
        """
        config = {
            'protocol': 'scapy',
            'interface': interface,
        }
        
        name = f"packet_{int(time.time())}"
        try:
            if self.connect(name, config):
                stdout, _ = self.execute(name, f"arp_scan:{ip_range}")
                return stdout
            else:
                return "Packet interface initialization failed"
        finally:
            self.disconnect(name)
```

### The Verification

Test the unified network manager:

```bash
cat > test_unified.py << 'EOF'
#!/usr/bin/env python3
"""Test script for unified network manager."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pyhack_suite.network.protocol_abstractions import UnifiedNetworkManager

def test_unified():
    """Test unified network manager."""
    print("=" * 60)
    print("Testing Unified Network Manager")
    print("=" * 60)
    
    manager = UnifiedNetworkManager()
    
    # Test packet operations
    print("\n1. Testing packet operations...")
    try:
        # ICMP ping
        result = manager.packet_ping("8.8.8.8")
        print(f"  ICMP Ping: {result}")
        
        # ARP scan (on local network)
        result = manager.arp_scan("192.168.1.0/24")
        print(f"  ARP Scan: {result[:200]}...")
        
    except Exception as e:
        print(f"  Packet operations failed (may need root): {e}")
    
    # Test SSH connection (will fail without valid credentials)
    print("\n2. Testing SSH connection...")
    try:
        stdout, stderr = manager.ssh_command(
            host="localhost",
            username="test",
            password="test",
            command="echo 'Hello from SSH'"
        )
        print(f"  SSH command output: {stdout}")
        if stderr:
            print(f"  SSH errors: {stderr}")
    except Exception as e:
        print(f"  SSH failed (expected without valid credentials): {e}")
    
    # Test Netmiko connection
    print("\n3. Testing Netmiko connection...")
    try:
        stdout, stderr = manager.netmiko_command(
            host="192.168.1.1",
            username="admin",
            password="password",
            device_type="cisco_ios",
            command="show version"
        )
        print(f"  Netmiko command output length: {len(stdout)} bytes")
    except Exception as e:
        print(f"  Netmiko failed (expected without device): {e}")
    
    # Show connection stats
    print("\n4. Connection statistics:")
    stats = manager.get_connection_stats()
    print(f"  Active connections: {len(stats)}")
    for name, info in stats.items():
        print(f"    {name}: {info['connected']} ({info['type']})")
    
    # Clean up
    manager.disconnect_all()
    print("\nCleanup complete")
    
    return 0

if __name__ == "__main__":
    sys.exit(test_unified())
EOF

python test_unified.py
```

---

```
[COMPLETED: Part 1, Section 3 - Comparative Analysis]
[COMPLETED: Part 1, Section 4 - Protocol Abstraction Layer]
[GENERATED: Part 1 Complete]

[STARTING: Part 2 - High-Speed Packet Sniffing & Asynchronous Integration]
```

---

## Part 1 Summary & Next Steps

### What You've Built

Congratulations! In Part 1, you've constructed a complete infrastructure automation layer:

1. **Project Foundation** - Professional Python packaging, configuration, and logging
2. **Session Manager** - Unified connection handling with pooling and lifecycle management
3. **Paramiko Wrapper** - Custom SSH automation with file transfer and interactive shells
4. **Netmiko Wrapper** - Multi-vendor device automation with backup/restore capabilities
5. **Scapy Wrapper** - Packet manipulation, sniffing, and analysis
6. **Protocol Abstraction** - Unified interface for all network operations

### Architecture Decision Summary

| Component | Best Used For |
|-----------|---------------|
| **Paramiko** | Custom SSH, file transfers, interactive sessions |
| **Netmiko** | Multi-vendor device automation, configuration management |
| **Scapy** | Packet crafting, sniffing, protocol analysis |
| **Session Manager** | Connection pooling, lifecycle management |
| **Protocol Abstraction** | Unified interface across all protocols |

### Verification Checklist

- [x] Configuration loads from environment variables
- [x] Logging system works with rotation and redaction
- [x] Project installs with `pip install -e .`
- [x] Session manager handles multiple connection types
- [x] Paramiko wrapper connects and executes commands
- [x] Netmiko wrapper connects to network devices
- [x] Scapy wrapper sends and sniffs packets
- [x] Protocol abstraction provides unified interface

### Preview: Part 2

In Part 2, we'll build on this foundation to implement:
- **High-speed packet sniffing** with AsyncSniffer
- **Asyncio integration** with thread-safe queues
- **Buffer management** for high-volume traffic
- **Event-driven packet injection** for active reconnaissance

