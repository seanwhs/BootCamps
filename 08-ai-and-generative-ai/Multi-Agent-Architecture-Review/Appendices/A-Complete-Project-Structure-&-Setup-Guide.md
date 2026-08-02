# Appendix A: Complete Project Structure & Setup Guide

## A.1 Overview

This appendix provides the complete project structure, setup instructions, and dependency management for the Multi-Agent Architecture Review System. Use this as a reference when setting up the system from scratch or troubleshooting installation issues.

---

## A.2 Complete Directory Structure

```
multi-agent-arch-review/
├── .env                          # Environment variables (API keys)
├── .gitignore                    # Git ignore file
├── README.md                     # Project documentation
├── requirements.txt              # Python dependencies
├── pyproject.toml                # Project metadata and tool configuration
├── review.py                     # Main entry point
│
├── src/                          # Source code
│   ├── __init__.py               # Package initialization
│   ├── cli.py                    # Complete CLI implementation
│   │
│   ├── agents/                   # Agent implementations
│   │   ├── __init__.py           # Agent exports
│   │   ├── base_agent.py         # Abstract base class
│   │   ├── review_agent.py       # General-purpose agent (POC)
│   │   ├── functional_agent.py   # Functional domain specialist
│   │   ├── security_agent.py     # Security domain specialist
│   │   ├── data_agent.py         # Data domain specialist
│   │   ├── devops_agent.py       # DevOps domain specialist
│   │   └── reliability_agent.py  # Reliability domain specialist
│   │
│   ├── orchestration/            # Orchestration frameworks
│   │   ├── __init__.py
│   │   ├── simple_orchestrator.py # Sequential orchestrator
│   │   ├── langgraph_orchestrator.py # LangGraph workflow
│   │   ├── crewai_docs.py        # CrewAI documentation team
│   │   └── unified_orchestrator.py # Combined orchestrator
│   │
│   ├── repository/               # Git integration
│   │   ├── __init__.py
│   │   ├── scanner.py            # Repository scanner
│   │   └── rag.py                # RAG system
│   │
│   ├── governance/               # Production governance
│   │   ├── __init__.py
│   │   ├── permissions.py        # Permissions and sandboxing
│   │   └── adr_generator.py      # Automated ADR generation
│   │
│   ├── prompts/                  # Agent prompt templates
│   │   ├── __init__.py
│   │   └── validation_matrix.py  # Domain validation matrices
│   │
│   └── utils/                    # Helper functions
│       ├── __init__.py
│       ├── config.py             # Configuration management
│       ├── logger.py             # Structured logging
│       └── cost_tracker.py       # API cost tracking
│
├── tests/                        # Test suite
│   ├── __init__.py
│   ├── test_config.py            # Configuration tests
│   ├── test_agents.py            # Agent tests
│   ├── test_orchestration.py     # Orchestration tests
│   └── test_repository.py        # Repository tests
│
├── docs/                         # Documentation
│   ├── designs/                  # Design documents to review
│   │   └── sample-payment-service.md
│   ├── adrs/                     # Generated ADRs
│   │   └── 0001-adopt-multi-agent-orchestration.md
│   └── outputs/                  # Generated outputs
│
├── logs/                         # Log files
│   ├── app.log                   # Application logs
│   ├── costs.json                # Cost tracking data
│   ├── audit.json                # Audit log
│   └── checkpoints/              # LangGraph checkpoints
│       └── reviews.db            # SQLite checkpoint database
│
└── examples/                     # Example configurations
    ├── agent_configs/            # Agent configuration examples
    │   ├── functional_agent.yaml
    │   ├── security_agent.yaml
    │   ├── data_agent.yaml
    │   ├── devops_agent.yaml
    │   └── reliability_agent.yaml
    └── review_configs/           # Review configuration examples
        └── default_review.yaml
```

---

## A.3 Complete requirements.txt

```txt
# ============================================================
# Multi-Agent Architecture Review System - Dependencies
# ============================================================
# Python 3.11+ required

# --------------------------------------------
# Core Utilities
# --------------------------------------------
python-dotenv>=1.0.0              # Environment variable management
pydantic>=2.5.0                   # Data validation
pydantic-settings>=2.1.0          # Settings management
typing-extensions>=4.8.0          # Type hints for older Python versions

# --------------------------------------------
# AI/LLM Libraries
# --------------------------------------------
openai>=1.6.0                     # OpenAI API client
anthropic>=0.18.0                 # Anthropic API client (Claude)
langchain>=0.1.0                  # LangChain core
langchain-openai>=0.0.5           # LangChain OpenAI integration
langchain-anthropic>=0.0.5        # LangChain Anthropic integration
langgraph>=0.0.20                 # LangGraph orchestration

# --------------------------------------------
# Orchestration Frameworks
# --------------------------------------------
crewai>=0.28.0                    # CrewAI multi-agent framework
pyautogen>=0.2.0                  # AutoGen (optional, for comparison)

# --------------------------------------------
# Repository Tools
# --------------------------------------------
gitpython>=3.1.0                  # Git repository interaction
pygithub>=1.58.0                  # GitHub API (optional)
sentence-transformers>=2.2.0      # Embeddings for RAG
scikit-learn>=1.3.0              # Similarity calculations

# --------------------------------------------
# Documentation & Outputs
# --------------------------------------------
markdown>=3.5.0                   # Markdown processing
pyyaml>=6.0                       # YAML parsing
jinja2>=3.1.0                     # Template rendering
weasyprint>=60.0                  # PDF generation (optional)
python-markdown>=3.5.0            # Markdown rendering

# --------------------------------------------
# CLI and Terminal Output
# --------------------------------------------
click>=8.1.0                      # CLI framework
rich>=13.7.0                      # Beautiful terminal output
tqdm>=4.66.0                      # Progress bars
prompt-toolkit>=3.0.0             # Interactive prompts

# --------------------------------------------
# Testing
# --------------------------------------------
pytest>=7.4.0                     # Testing framework
pytest-cov>=4.1.0                 # Coverage reporting
pytest-asyncio>=0.21.0            # Async test support
pytest-mock>=3.12.0               # Mocking support

# --------------------------------------------
# Code Quality
# --------------------------------------------
black>=23.11.0                    # Code formatting
ruff>=0.1.0                       # Linting
mypy>=1.7.0                       # Type checking
pre-commit>=3.5.0                 # Git hooks

# --------------------------------------------
# Logging and Monitoring
# --------------------------------------------
structlog>=24.1.0                 # Structured logging
python-json-logger>=2.0.0         # JSON log formatting
```

---

## A.4 Complete pyproject.toml

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "multi-agent-arch-review"
version = "1.0.0"
description = "Multi-Agent AI Architecture Review System - Production Ready"
readme = "README.md"
requires-python = ">=3.11"
authors = [
    {name = "Architecture Team", email = "architecture@company.com"},
]
license = {text = "MIT"}
classifiers = [
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "Intended Audience :: System Administrators",
    "Topic :: Software Development :: Build Tools",
    "Topic :: Software Development :: Documentation",
    "Topic :: System :: Monitoring",
]

[project.urls]
Homepage = "https://github.com/yourcompany/multi-agent-arch-review"
Documentation = "https://github.com/yourcompany/multi-agent-arch-review/wiki"
Issues = "https://github.com/yourcompany/multi-agent-arch-review/issues"
Repository = "https://github.com/yourcompany/multi-agent-arch-review"

[project.scripts]
review-arch = "src.cli:main"

[project.optional-dependencies]
dev = [
    "black>=23.11.0",
    "ruff>=0.1.0",
    "mypy>=1.7.0",
    "pre-commit>=3.5.0",
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
]
pdf = ["weasyprint>=60.0"]
all = [
    "weasyprint>=60.0",
    "pyautogen>=0.2.0",
    "pygithub>=1.58.0",
]

[tool.black]
line-length = 100
target-version = ['py311', 'py312']
include = '\.pyi?$'
extend-exclude = '''
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
  | docs/outputs
  | logs
)/
'''

[tool.ruff]
line-length = 100
select = ["E", "F", "W", "I", "N", "D"]
ignore = ["E501", "D100", "D104", "D107"]
target-version = "py311"

[tool.ruff.per-file-ignores]
"tests/*" = ["D"]

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_ignores = true
disallow_untyped_defs = true
ignore_missing_imports = true
exclude = [
    "docs/",
    "tests/",
    "examples/",
]

[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra -q --cov=src --cov-report=term --cov-report=html"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]

[tool.coverage.run]
source = ["src"]
omit = ["tests/*", "examples/*"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
]

[tool.pip-audit]
skip-editable = true
require-hashes = false
```

---

## A.5 Complete .env Template

```bash
# ============================================================
# Multi-Agent Architecture Review System - Environment Variables
# ============================================================
# Copy this file to .env and fill in your values
# NEVER commit .env to version control!

# --------------------------------------------
# API Keys (Required: at least one)
# --------------------------------------------
# OpenAI API Key - Get from https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Anthropic API Key - Get from https://console.anthropic.com/
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# DeepSeek API Key - Get from https://platform.deepseek.com/
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# --------------------------------------------
# Model Configuration
# --------------------------------------------
# Default model for all agents
DEFAULT_MODEL=gpt-4-turbo-preview

# Secondary/fallback model
SECONDARY_MODEL=gpt-3.5-turbo

# Embedding model for RAG
EMBEDDING_MODEL=all-MiniLM-L6-v2

# --------------------------------------------
# API Settings
# --------------------------------------------
MAX_TOKENS=4096
TEMPERATURE=0.3
MAX_RETRIES=3
RETRY_DELAY_SECONDS=5

# --------------------------------------------
# Application Settings
# --------------------------------------------
ENVIRONMENT=development
LOG_LEVEL=INFO
REVIEW_BUDGET_USD=5.00
MAX_REVIEW_DOCS=10
WORKSPACE_DIR=./workspace

# --------------------------------------------
# Repository Settings
# --------------------------------------------
REPO_SCAN_DEPTH=3
REPO_MAX_FILE_SIZE_MB=10
ALLOWED_EXTENSIONS=.md,.yaml,.yml,.json,.toml,.py,.js,.ts,.go,.java

# --------------------------------------------
# Security Settings
# --------------------------------------------
SANDBOX_ENABLED=true
AUDIT_ENABLED=true
MAX_PERMITTED_FILES=100
```

---

## A.6 Complete .gitignore

```gitignore
# ============================================================
# Python
# ============================================================
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# ============================================================
# Virtual Environments
# ============================================================
venv/
.env/
.venv/
virtualenv/

# ============================================================
# IDE
# ============================================================
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# ============================================================
# Logs and Data
# ============================================================
logs/
*.log
*.pid
*.pid.lock
*.db
*.sqlite
*.sqlite3
*.dump

# ============================================================
# Testing
# ============================================================
.pytest_cache/
.coverage
htmlcov/
.tox/
.mypy_cache/
.ruff_cache/
.pytest_cache/

# ============================================================
# Project Specific
# ============================================================
# Generated ADRs
docs/adrs/*.md
!docs/adrs/0001-adopt-multi-agent-orchestration.md

# Generated outputs
docs/outputs/
*.report.txt
*.report.json

# Checkpoints
logs/checkpoints/
logs/costs.json
logs/audit.json

# Workspace
workspace/

# Examples
examples/outputs/

# Temporary files
*.tmp
*.temp
*.bak

# ============================================================
# OS Files
# ============================================================
.DS_Store
Thumbs.db
desktop.ini
```

---

## A.7 Complete README.md

```markdown
# Multi-Agent AI Architecture Review System

[![Python](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/yourcompany/multi-agent-arch-review)

## 🏗️ Overview

The Multi-Agent AI Architecture Review System is a production-grade tool that uses five specialized AI agents to perform comprehensive architecture reviews on design documents. It combines enterprise orchestration (LangGraph), role-based documentation (CrewAI), repository awareness, RAG, and automated ADR generation.

### ✨ Key Features

- **5 Specialized Agents**: Functional, Security, Data, DevOps, Reliability
- **Enterprise Orchestration**: LangGraph with human-in-the-loop gates
- **Documentation Generation**: CrewAI team for professional reports
- **Repository Awareness**: Git integration and context extraction
- **RAG**: Semantic search over your codebase
- **ADR Automation**: Auto-generate Architectural Decision Records
- **Production Governance**: Permissions, sandboxing, audit logging
- **Cost Tracking**: Monitor and control API costs

## 🚀 Quick Start

### Prerequisites

- Python 3.11 or higher
- API key for at least one LLM provider (OpenAI, Anthropic, or DeepSeek)
- Git 2.30 or higher

### Installation

```bash
# Clone the repository
git clone https://github.com/yourcompany/multi-agent-arch-review.git
cd multi-agent-arch-review

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment template
cp .env.template .env
# Edit .env with your API keys

# Run the system
python review.py --help
```

### Basic Usage

```bash
# Run a review with all features
python review.py review -d docs/designs/my-design.md --repo . --use-rag

# Generate an ADR from saved results
python review.py generate-adr --review-file docs/outputs/review_*.json

# Search your repository
python review.py search --query "authentication patterns"

# View audit log
python review.py audit

# Check cost report
python review.py cost
```

## 📚 Documentation

- **Part 0**: [Introduction](https://github.com/yourcompany/multi-agent-arch-review/wiki/Part-0)
- **Part 1**: [Foundations & Technical Landscape](https://github.com/yourcompany/multi-agent-arch-review/wiki/Part-1)
- **Part 2**: [Domain Specialization](https://github.com/yourcompany/multi-agent-arch-review/wiki/Part-2)
- **Part 3**: [Framework Selection & Orchestration](https://github.com/yourcompany/multi-agent-arch-review/wiki/Part-3)
- **Part 4**: [Repository Awareness & Production](https://github.com/yourcompany/multi-agent-arch-review/wiki/Part-4)
- **Appendix A**: [Setup Guide](https://github.com/yourcompany/multi-agent-arch-review/wiki/Appendix-A)

## 🏛️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                          CLI                                │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                Unified Orchestrator                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              LangGraph Workflow                       │  │
│  │  Init → Functional → Security → Data → DevOps →    │  │
│  │  Reliability → Aggregate → Human Gate → Report      │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         CrewAI Documentation Team                    │  │
│  │  Writer → Editor → Reviewer → Formatter              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│              Support Systems                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐ │
│  │  Repository  │  │     RAG      │  │   Governance      │ │
│  │   Scanner    │  │   Context    │  │  - Permissions    │ │
│  │              │  │              │  │  - Sandbox        │ │
│  └──────────────┘  └──────────────┘  │  - Audit         │ │
│                       ┌──────────────┐ │  - ADR Gen      │ │
│                       │   Cost       │ └──────────────────┘ │
│                       │   Tracker    │                      │
│                       └──────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Commands

| Command | Description |
|---------|-------------|
| `review` | Run an architecture review |
| `generate-adr` | Generate ADR from review results |
| `search` | Search repository using RAG |
| `scan-repo` | Scan and display repository structure |
| `audit` | View audit log |
| `cost` | View cost report |
| `status` | View system status |
| `list` | List review checkpoints |
| `resume` | Resume a review |
| `config` | View configuration |
| `version` | Display version |

## 💰 Cost Estimates

| Model | Single Review | Multi-Agent Review |
|-------|---------------|-------------------|
| GPT-4 Turbo | ~$0.04 | ~$0.20 |
| GPT-3.5 Turbo | ~$0.002 | ~$0.01 |
| DeepSeek | ~$0.0005 | ~$0.0025 |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `pytest`
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details

## 🙏 Acknowledgments

- [LangGraph](https://langchain-ai.github.io/langgraph/)
- [CrewAI](https://docs.crewai.com/)
- [OpenAI](https://openai.com/)
- [Anthropic](https://anthropic.com/)
- [DeepSeek](https://deepseek.com/)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourcompany/multi-agent-arch-review/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourcompany/multi-agent-arch-review/discussions)
- **Email**: architecture@company.com

---

*Built with ❤️ by the Architecture Team*
```

---

## A.8 Setup Verification Script

**`scripts/verify_setup.py`** - Verify installation and configuration:

```python
#!/usr/bin/env python3
"""
Setup verification script for the Multi-Agent Architecture Review System.

Run this after installation to verify everything is working correctly.
"""

import sys
import subprocess
from pathlib import Path

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.utils.config import get_settings, setup_logging
from src.utils.logger import get_logger

def print_section(title: str):
    """Print a section header."""
    print("\n" + "=" * 60)
    print(f"  {title}")
    print("=" * 60)

def print_check(item: str, status: bool, details: str = ""):
    """Print a check result."""
    symbol = "✅" if status else "❌"
    print(f"{symbol} {item}")
    if details and not status:
        print(f"   → {details}")

def verify_python():
    """Verify Python version."""
    version = sys.version_info
    return version.major >= 3 and version.minor >= 11, f"Python {version.major}.{version.minor}"

def verify_dependencies():
    """Verify required packages are installed."""
    required = [
        'openai',
        'langgraph',
        'crewai',
        'git',
        'click',
        'rich',
        'pydantic',
        'dotenv'
    ]
    
    missing = []
    for package in required:
        try:
            __import__(package)
        except ImportError:
            missing.append(package)
    
    return len(missing) == 0, f"Missing: {', '.join(missing)}" if missing else "All packages installed"

def verify_api_keys():
    """Verify API key configuration."""
    settings = get_settings()
    
    providers = {
        'OpenAI': settings.is_provider_available('openai'),
        'Anthropic': settings.is_provider_available('anthropic'),
        'DeepSeek': settings.is_provider_available('deepseek'),
    }
    
    available = any(providers.values())
    details = ", ".join([f"{k}: {'✓' if v else '✗'}" for k, v in providers.items()])
    
    return available, details

def verify_repository():
    """Verify repository scanner works."""
    try:
        from src.repository.scanner import RepositoryScanner
        scanner = RepositoryScanner(Path('.'))
        results = scanner.scan()
        return True, f"Found {len(results['files'])} relevant files"
    except Exception as e:
        return False, str(e)

def verify_orchestration():
    """Verify orchestration imports work."""
    try:
        from src.orchestration.unified_orchestrator import UnifiedOrchestrator
        return True, "Unified orchestrator available"
    except Exception as e:
        return False, str(e)

def verify_agents():
    """Verify all agents can be imported."""
    try:
        from src.agents import (
            FunctionalAgent, SecurityAgent, DataAgent,
            DevOpsAgent, ReliabilityAgent
        )
        return True, "All 5 agents available"
    except Exception as e:
        return False, str(e)

def main():
    """Run all verification checks."""
    print_section("Multi-Agent Architecture Review System - Setup Verification")
    
    checks = {
        "Python 3.11+": verify_python(),
        "Dependencies": verify_dependencies(),
        "API Keys": verify_api_keys(),
        "Repository Scanner": verify_repository(),
        "Orchestration": verify_orchestration(),
        "Agents": verify_agents(),
    }
    
    all_passed = True
    
    for name, (status, details) in checks.items():
        print_check(name, status, details)
        if not status:
            all_passed = False
    
    print_section("Summary")
    
    if all_passed:
        print("\n✅ All checks passed! System is ready for use.\n")
        print("Quick start:")
        print("  python review.py review -d docs/designs/sample-payment-service.md")
    else:
        print("\n⚠️ Some checks failed. Please review the issues above.\n")
        print("Common fixes:")
        print("  1. Check Python version: python --version")
        print("  2. Install dependencies: pip install -r requirements.txt")
        print("  3. Configure API keys in .env file")
        print("  4. Ensure you're in the project root directory")
    
    return all_passed

if __name__ == "__main__":
    sys.exit(0 if main() else 1)
```

---

## A.9 Quick Reference Commands

### Setup Commands
```bash
# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Verify setup
python scripts/verify_setup.py
```

### Development Commands
```bash
# Format code
black src/ tests/

# Lint code
ruff check src/

# Type check
mypy src/

# Run tests
pytest

# Run tests with coverage
pytest --cov=src --cov-report=html
```

### Docker Commands (if Docker is used)
```bash
# Build Docker image
docker build -t multi-agent-arch-review .

# Run with Docker
docker run -v $(pwd):/workspace multi-agent-arch-review \
    review -d docs/designs/sample-payment-service.md
```

*Need more help? Check the other appendices for advanced configuration, troubleshooting, and API reference.*
