# Appendix C: Troubleshooting & Error Handling Guide

## C.1 Overview

This appendix provides comprehensive troubleshooting guidance, common error patterns, and solutions for the Multi-Agent Architecture Review System. Use this as a reference when diagnosing and resolving issues in your deployment.

---

## C.2 Common Error Categories

### C.2.1 Setup & Installation Errors

| Error | Symptoms | Root Cause | Solution |
|-------|----------|------------|----------|
| **ModuleNotFoundError** | "No module named 'openai'" | Missing dependencies | `pip install -r requirements.txt` |
| **Python Version Error** | "Python 3.11+ required" | Wrong Python version | Install Python 3.11+ or use `pyenv` |
| **Virtual Environment Issues** | "Command not found: review" | venv not activated | `source venv/bin/activate` |
| **Path Errors** | "Module not found: src" | Wrong working directory | `cd` to project root |
| **Permission Denied** | "Permission denied: review.py" | File permissions | `chmod +x review.py` |

### C.2.2 Configuration Errors

| Error | Symptoms | Root Cause | Solution |
|-------|----------|------------|----------|
| **Missing API Key** | "OpenAI API key not configured" | .env not set | Add `OPENAI_API_KEY` to .env |
| **Invalid API Key** | "Invalid API key" | Key is wrong or expired | Regenerate API key |
| **Budget Exceeded** | "Cost exceeded budget limit" | Review costs exceeding limit | Increase `REVIEW_BUDGET_USD` |
| **Missing Model** | "Model not found" | Model name typo | Check model name in config |
| **Environment Error** | "KeyError: 'OPENAI_API_KEY'" | .env not loaded | Ensure .env exists and has keys |

### C.2.3 Agent Errors

| Error | Symptoms | Root Cause | Solution |
|-------|----------|------------|----------|
| **Prompt Length** | "Max tokens exceeded" | Document too long | Use `--truncate` or split document |
| **Parsing Error** | "Failed to parse JSON" | LLM returns invalid format | Add stricter format instructions |
| **Agent Timeout** | "Request timed out" | Large document or network | Increase timeout or use faster model |
| **Rate Limit** | "Rate limit exceeded" | Too many API calls | Implement retry with backoff |
| **Content Filter** | "Content filtered" | Unsafe content | Review document content |

### C.2.4 Repository Errors

| Error | Symptoms | Root Cause | Solution |
|-------|----------|------------|----------|
| **Not a Git Repo** | "Not a Git repository" | Path not a repo | Initialize git or use correct path |
| **File Not Found** | "No such file or directory" | Incorrect file path | Use absolute or correct relative path |
| **File Locked** | "Permission denied" | File in use by another process | Close other processes |
| **Large Repository** | "Memory error" | Repository too large | Use `--max-depth` or filter files |
| **RAG Cache Issue** | "Embedding cache corrupted" | Cache file corrupted | Delete cache and rebuild |

---

## C.3 Diagnostic Tools

### C.3.1 System Diagnostic Script

**`scripts/diagnose.py`**

```python
#!/usr/bin/env python3
"""
System diagnostic tool for the Multi-Agent Architecture Review System.
Run this to diagnose and report issues with your setup.
"""

import sys
import os
import subprocess
from pathlib import Path
import json
import datetime

def print_header(text: str):
    """Print a diagnostic section header."""
    print("\n" + "=" * 70)
    print(f"  {text}")
    print("=" * 70)

def print_result(test: str, status: str, details: str = ""):
    """Print a diagnostic test result."""
    symbols = {
        "PASS": "✅",
        "FAIL": "❌",
        "WARN": "⚠️",
        "INFO": "ℹ️"
    }
    symbol = symbols.get(status, "•")
    print(f"{symbol} {test}")
    if details:
        print(f"   → {details}")

class DiagnosticRunner:
    """Run comprehensive system diagnostics."""
    
    def __init__(self):
        self.results = []
        self.project_root = Path(__file__).parent.parent
    
    def run_all(self):
        """Run all diagnostic tests."""
        print_header("Multi-Agent Architecture Review System - Diagnostic")
        print(f"Run at: {datetime.datetime.now().isoformat()}")
        print(f"Project root: {self.project_root}")
        
        self.check_python()
        self.check_dependencies()
        self.check_environment()
        self.check_configuration()
        self.check_api_keys()
        self.check_git()
        self.check_agents()
        self.check_orchestration()
        self.check_repository()
        self.check_logs()
        self.check_performance()
        
        self.print_summary()
    
    def check_python(self):
        """Check Python version and installation."""
        print_header("Python Environment")
        
        version = sys.version_info
        version_ok = version.major >= 3 and version.minor >= 11
        status = "PASS" if version_ok else "FAIL"
        details = f"Python {version.major}.{version.minor}.{version.micro}"
        print_result("Python Version", status, details)
        
        if not version_ok:
            print_result("Python 3.11+ Required", "FAIL", 
                        "Please install Python 3.11 or higher")
    
    def check_dependencies(self):
        """Check if all dependencies are installed."""
        print_header("Dependencies")
        
        required_packages = [
            'openai', 'anthropic', 'langgraph', 'crewai',
            'git', 'click', 'rich', 'pydantic', 'dotenv',
            'pytest', 'sentence_transformers', 'sklearn'
        ]
        
        missing = []
        for package in required_packages:
            try:
                __import__(package.replace('-', '_'))
            except ImportError:
                missing.append(package)
        
        if missing:
            print_result("Dependencies", "FAIL", 
                        f"Missing: {', '.join(missing)}")
            print_result("Fix", "INFO", 
                        "Run: pip install -r requirements.txt")
        else:
            print_result("All Dependencies", "PASS")
    
    def check_environment(self):
        """Check environment variables."""
        print_header("Environment Variables")
        
        required_vars = ['OPENAI_API_KEY']
        optional_vars = ['ANTHROPIC_API_KEY', 'DEEPSEEK_API_KEY',
                        'ENVIRONMENT', 'LOG_LEVEL', 'REVIEW_BUDGET_USD']
        
        # Check .env exists
        env_file = self.project_root / '.env'
        if env_file.exists():
            print_result(".env file", "PASS", f"Found at {env_file}")
        else:
            print_result(".env file", "WARN", 
                        "Not found - create from .env.template")
        
        # Check environment variables
        for var in required_vars:
            value = os.getenv(var)
            if value:
                masked = value[:8] + "..." if len(value) > 8 else "***"
                print_result(f"{var}", "PASS", f"Set: {masked}")
            else:
                print_result(f"{var}", "FAIL", "Not set - add to .env")
        
        for var in optional_vars:
            value = os.getenv(var)
            if value:
                print_result(f"{var}", "PASS", "Set")
            else:
                print_result(f"{var}", "WARN", "Not set - optional")
    
    def check_configuration(self):
        """Check configuration validity."""
        print_header("Configuration")
        
        try:
            sys.path.insert(0, str(self.project_root))
            from src.utils.config import get_settings
            settings = get_settings()
            
            print_result("Configuration Load", "PASS", 
                        f"Environment: {settings.environment}")
            print_result("Default Model", "PASS", settings.default_model)
            print_result("Budget", "PASS", f"${settings.review_budget_usd}")
            
            # Check if project structure is correct
            required_dirs = ['src', 'src/agents', 'src/orchestration', 
                           'src/repository', 'src/governance', 'src/utils']
            for dir_name in required_dirs:
                path = self.project_root / dir_name
                if path.exists():
                    print_result(f"Directory: {dir_name}", "PASS")
                else:
                    print_result(f"Directory: {dir_name}", "FAIL")
                    
        except Exception as e:
            print_result("Configuration", "FAIL", f"Error: {e}")
    
    def check_api_keys(self):
        """Test API keys by making a lightweight call."""
        print_header("API Key Tests")
        
        try:
            from src.utils.config import get_settings
            settings = get_settings()
            
            # Test OpenAI
            if settings.is_provider_available('openai'):
                try:
                    from openai import OpenAI
                    client = OpenAI(api_key=settings.openai_api_key)
                    # Make minimal call
                    response = client.chat.completions.create(
                        model='gpt-3.5-turbo',
                        messages=[{"role": "user", "content": "Test"}],
                        max_tokens=5
                    )
                    print_result("OpenAI API", "PASS", "Working")
                except Exception as e:
                    print_result("OpenAI API", "FAIL", f"Error: {str(e)[:50]}")
            else:
                print_result("OpenAI API", "WARN", "Not configured")
                
        except Exception as e:
            print_result("API Tests", "FAIL", f"Error: {e}")
    
    def check_git(self):
        """Check git installation and repository."""
        print_header("Git Repository")
        
        try:
            import git
            
            # Check if project is a git repo
            try:
                repo = git.Repo(self.project_root)
                branch = repo.active_branch.name
                print_result("Git Repository", "PASS", 
                            f"Branch: {branch}")
                
                # Check if clean
                if repo.is_dirty():
                    print_result("Git Status", "WARN", 
                                "Working directory has uncommitted changes")
                else:
                    print_result("Git Status", "PASS", "Clean")
                    
            except git.InvalidGitRepositoryError:
                print_result("Git Repository", "WARN", 
                            "Not a git repository")
                
        except ImportError:
            print_result("Git", "WARN", "GitPython not installed")
    
    def check_agents(self):
        """Check if all agents can be imported."""
        print_header("Agents")
        
        try:
            sys.path.insert(0, str(self.project_root))
            from src.agents import (
                FunctionalAgent, SecurityAgent, DataAgent,
                DevOpsAgent, ReliabilityAgent
            )
            
            print_result("FunctionalAgent", "PASS")
            print_result("SecurityAgent", "PASS")
            print_result("DataAgent", "PASS")
            print_result("DevOpsAgent", "PASS")
            print_result("ReliabilityAgent", "PASS")
            
            # Test agent initialization
            try:
                agent = FunctionalAgent()
                print_result("Agent Initialization", "PASS", 
                            f"{agent.name} ready")
            except Exception as e:
                print_result("Agent Initialization", "FAIL", f"{e}")
                
        except Exception as e:
            print_result("Agent Import", "FAIL", f"{e}")
    
    def check_orchestration(self):
        """Check orchestration components."""
        print_header("Orchestration")
        
        try:
            sys.path.insert(0, str(self.project_root))
            from src.orchestration.unified_orchestrator import UnifiedOrchestrator
            
            print_result("UnifiedOrchestrator", "PASS")
            
            # Check if LangGraph is available
            try:
                import langgraph
                print_result("LangGraph", "PASS", f"v{langgraph.__version__}")
            except ImportError:
                print_result("LangGraph", "FAIL", "Not installed")
            
            # Check if CrewAI is available
            try:
                import crewai
                print_result("CrewAI", "PASS", f"v{crewai.__version__}")
            except ImportError:
                print_result("CrewAI", "FAIL", "Not installed")
                
        except Exception as e:
            print_result("Orchestration", "FAIL", f"{e}")
    
    def check_repository(self):
        """Check repository scanner."""
        print_header("Repository Scanner")
        
        try:
            sys.path.insert(0, str(self.project_root))
            from src.repository.scanner import RepositoryScanner
            
            scanner = RepositoryScanner(self.project_root)
            results = scanner.scan()
            
            print_result("Repository Scanner", "PASS", 
                        f"Found {len(results['files'])} files")
            print_result("File Types", "PASS",
                        f"{len(results['context'].keys())} types")
            
            # Check RAG
            try:
                from src.repository.rag import RAGContext
                rag = RAGContext(self.project_root)
                print_result("RAG System", "PASS", "Available")
            except Exception as e:
                print_result("RAG System", "WARN", f"Error: {e}")
                
        except Exception as e:
            print_result("Repository Scanner", "FAIL", f"{e}")
    
    def check_logs(self):
        """Check log files and permissions."""
        print_header("Logs")
        
        log_dir = self.project_root / 'logs'
        
        if log_dir.exists():
            print_result("Log Directory", "PASS")
            
            # Check if log files exist
            log_files = ['app.log', 'costs.json', 'audit.json']
            for log_file in log_files:
                path = log_dir / log_file
                if path.exists():
                    size = path.stat().st_size
                    print_result(f"Log: {log_file}", "PASS", 
                                f"{size:,} bytes")
                else:
                    print_result(f"Log: {log_file}", "WARN", "Not created yet")
        else:
            print_result("Log Directory", "WARN", "Not created yet")
            print_result("Fix", "INFO", "mkdir logs")
    
    def check_performance(self):
        """Check performance metrics."""
        print_header("Performance")
        
        try:
            sys.path.insert(0, str(self.project_root))
            from src.utils.cost_tracker import get_cost_tracker
            
            tracker = get_cost_tracker()
            total = tracker.total_cost()
            entries = len(tracker.entries)
            
            print_result("Cost Tracker", "PASS", 
                        f"Total: ${total:.4f}, Calls: {entries}")
            
            # Check if budget is close
            budget = tracker.budget_limit
            if total > 0:
                usage_pct = (total / budget) * 100
                if usage_pct > 80:
                    print_result("Budget Status", "WARN", 
                                f"{usage_pct:.1f}% used")
                else:
                    print_result("Budget Status", "PASS", 
                                f"{usage_pct:.1f}% used")
            
        except Exception as e:
            print_result("Performance Check", "WARN", f"{e}")
    
    def print_summary(self):
        """Print a summary of diagnostic results."""
        print_header("Diagnostic Summary")
        
        # Count results
        total = len(self.results)
        passed = sum(1 for r in self.results if r[1] == "PASS")
        failed = sum(1 for r in self.results if r[1] == "FAIL")
        warnings = sum(1 for r in self.results if r[1] == "WARN")
        
        print(f"Total Tests: {total}")
        print(f"  ✅ Passed: {passed}")
        print(f"  ❌ Failed: {failed}")
        print(f"  ⚠️ Warnings: {warnings}")
        print()
        
        if failed > 0:
            print("⚠️ Issues detected. Please review the output above.")
            print("Common fixes:")
            print("  1. Run: pip install -r requirements.txt")
            print("  2. Configure: Edit .env with your API keys")
            print("  3. Check: Python version (3.11+)")
            print("  4. Re-run: python scripts/verify_setup.py")
        elif warnings > 0:
            print("⚠️ Minor issues detected. System should still work.")
        else:
            print("✅ All checks passed! System is ready to use.")
    
    def log_result(self, test: str, status: str, details: str = ""):
        """Store a result for summary."""
        self.results.append((test, status, details))
    
    # Override print_result to log
    def print_result(self, test: str, status: str, details: str = ""):
        """Print and store a diagnostic result."""
        symbols = {
            "PASS": "✅",
            "FAIL": "❌",
            "WARN": "⚠️",
            "INFO": "ℹ️"
        }
        symbol = symbols.get(status, "•")
        print(f"{symbol} {test}")
        if details:
            print(f"   → {details}")
        self.log_result(test, status, details)

def main():
    """Run diagnostics."""
    runner = DiagnosticRunner()
    runner.run_all()

if __name__ == "__main__":
    main()
```

### C.3.2 Running Diagnostics

```bash
# Run full diagnostic
python scripts/diagnose.py

# Run specific checks
python scripts/diagnose.py --check python
python scripts/diagnose.py --check api
python scripts/diagnose.py --check logs

# Output to file
python scripts/diagnose.py --output diagnostics.txt
```

---

## C.4 Common Error Scenarios and Solutions

### C.4.1 API Rate Limiting

**Error Pattern:**
```
openai.RateLimitError: Rate limit exceeded. Please retry after 20 seconds.
```

**Solution:**
```python
# Implement exponential backoff retry
import time
from functools import wraps

def retry_with_backoff(max_retries=5, base_delay=2):
    """Decorator for retrying with exponential backoff."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            delay = base_delay
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if "rate limit" in str(e).lower() and attempt < max_retries - 1:
                        time.sleep(delay)
                        delay *= 2
                        continue
                    raise
            return func(*args, **kwargs)
        return wrapper
    return decorator

# Usage
@retry_with_backoff(max_retries=5, base_delay=2)
def make_api_call():
    # Your API call here
    pass
```

### C.4.2 JSON Parsing Failures

**Error Pattern:**
```
json.JSONDecodeError: Expecting value: line 1 column 1 (char 0)
```

**Solution:**
```python
def safe_json_parse(text: str) -> Dict[str, Any]:
    """Safely parse JSON with fallback strategies."""
    import re
    
    # Strategy 1: Try direct parse
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    
    # Strategy 2: Extract JSON from markdown code block
    code_block_pattern = r'```(?:json)?\s*\n(.*?)\n```'
    match = re.search(code_block_pattern, text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group(1))
        except json.JSONDecodeError:
            pass
    
    # Strategy 3: Extract JSON object with regex
    json_pattern = r'\{.*\}'
    match = re.search(json_pattern, text, re.DOTALL)
    if match:
        try:
            return json.loads(match.group())
        except json.JSONDecodeError:
            pass
    
    # Strategy 4: Return error dict
    return {
        'error': 'Failed to parse LLM response as JSON',
        'raw_response': text[:500],
        'status': 'PARSE_ERROR'
    }
```

### C.4.3 Memory Issues with Large Repositories

**Error Pattern:**
```
MemoryError: Unable to allocate array with shape ...
```

**Solution:**
```python
class LargeRepositoryHandler:
    """Handle large repositories efficiently."""
    
    def __init__(self, repo_path: Path):
        self.repo_path = repo_path
        self.max_files = 100
        self.max_file_size_mb = 5
    
    def scan_safely(self):
        """Scan repository with memory limits."""
        files = []
        
        for path in self.repo_path.rglob('*'):
            # Limit number of files
            if len(files) >= self.max_files:
                break
            
            # Skip large files
            if path.is_file():
                size_mb = path.stat().st_size / (1024 * 1024)
                if size_mb > self.max_file_size_mb:
                    continue
                
                files.append(path)
        
        return files
    
    def process_batch(self, files: List[Path], batch_size: int = 10):
        """Process files in batches to manage memory."""
        for i in range(0, len(files), batch_size):
            batch = files[i:i+batch_size]
            yield batch
```

### C.4.4 Git Operations Failures

**Error Pattern:**
```
git.exc.GitCommandError: Cmd('git') failed due to: exit code(128)
```

**Solution:**
```python
def safe_git_operation(func):
    """Safely handle git operations with fallbacks."""
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except git.exc.GitCommandError as e:
            if "not a git repository" in str(e):
                # Fallback: use path walking
                from pathlib import Path
                repo_path = kwargs.get('repo_path', args[0] if args else '.')
                return walk_repository_fallback(Path(repo_path))
            raise
    return wrapper

def walk_repository_fallback(repo_path: Path) -> Dict[str, Any]:
    """Fallback method for non-git repositories."""
    files = []
    for path in repo_path.rglob('*'):
        if path.is_file():
            # Skip common ignore patterns
            if any(part.startswith('.') for part in path.parts):
                continue
            files.append(path)
    
    return {
        'files': files,
        'is_git': False,
        'message': 'Not a git repository - using file walker'
    }
```

### C.4.5 RAG Context Issues

**Error Pattern:**
```
IndexError: index 0 is out of bounds for axis 0 with size 0
```

**Solution:**
```python
class SafeRAGContext:
    """RAG context with safety checks."""
    
    def __init__(self, repo_path: Path):
        self.repo_path = repo_path
        self.embedding_cache = {}
    
    def get_context_safely(self, query: str) -> str:
        """Get RAG context with fallback."""
        try:
            # Try to get embeddings
            if not self.embedding_cache:
                self._build_embeddings()
            
            if not self.embedding_cache:
                return "No context available - repository may be empty"
            
            # Search
            results = self.search(query)
            
            if not results:
                return "No relevant context found"
            
            return self._format_results(results)
            
        except Exception as e:
            return f"RAG context unavailable: {str(e)}"
```

---

## C.5 Performance Troubleshooting

### C.5.1 Slow Performance

**Symptoms:**
- Reviews taking more than 2 minutes
- Agent responses timing out
- High latency in API calls

**Diagnosis:**
```python
import time
from contextlib import contextmanager

@contextmanager
def measure_time(operation: str):
    """Measure and log execution time."""
    start = time.time()
    try:
        yield
    finally:
        duration = time.time() - start
        print(f"{operation}: {duration:.2f}s")

# Usage
with measure_time("Document embedding"):
    embedding = model.encode(document)
```

**Solutions:**

1. **Use smaller documents:**
```bash
python review.py review -d design.md --truncate 2000
```

2. **Use faster models:**
```bash
python review.py review -d design.md --model gpt-3.5-turbo
```

3. **Enable caching:**
```python
# In configuration
ENABLE_RESPONSE_CACHE=true
CACHE_MAX_SIZE=100
```

4. **Reduce agent count:**
```python
# Use only essential agents
agents = ['security', 'functional']  # Skip others
```

### C.5.2 High Costs

**Symptoms:**
- Review costs exceeding budget
- Cost report showing high usage

**Solutions:**

1. **Use cheaper models:**
```bash
python review.py review -d design.md --model deepseek
```

2. **Implement document compression:**
```python
def compress_document(document: str) -> str:
    """Compress document to reduce tokens."""
    # Remove empty lines
    lines = [l.strip() for l in document.split('\n') if l.strip()]
    # Remove comments
    lines = [l for l in lines if not l.startswith('//')]
    # Keep key sections only
    keep_sections = ['## Architecture', '## Design', '## API', '## Security']
    compressed = []
    for line in lines:
        if any(section in line for section in keep_sections) or line.startswith('#'):
            compressed.append(line)
    return '\n'.join(compressed)
```

3. **Set budget limits:**
```python
# In .env
REVIEW_BUDGET_USD=2.00
MAX_REVIEWS_PER_DAY=10
```

### C.5.3 Memory Leaks

**Symptoms:**
- Memory usage growing over time
- System becoming slow after multiple reviews
- `MemoryError` exceptions

**Solutions:**

1. **Clear caches periodically:**
```python
def clear_caches():
    """Clear all caches to prevent memory leaks."""
    from src.agents.base_agent import AgentCache
    AgentCache._instance = None
    
    # Clear embedding cache
    if hasattr(SentenceTransformer, '_cache'):
        SentenceTransformer._cache = {}
    
    import gc
    gc.collect()
```

2. **Use streaming responses:**
```python
def stream_api_response(messages):
    """Stream API responses to reduce memory."""
    response = client.chat.completions.create(
        model="gpt-4-turbo-preview",
        messages=messages,
        stream=True,
    )
    for chunk in response:
        if chunk.choices[0].delta.content:
            yield chunk.choices[0].delta.content
```

---

## C.6 Logging and Monitoring

### C.6.1 Log Levels

```python
import logging

# Configure log levels
LOG_LEVELS = {
    'DEBUG': logging.DEBUG,      # Detailed debug information
    'INFO': logging.INFO,         # General operational info
    'WARNING': logging.WARNING,   # Warning conditions
    'ERROR': logging.ERROR,       # Error conditions
    'CRITICAL': logging.CRITICAL, # Critical conditions
}

# Recommended settings by environment
ENVIRONMENT_LOGGING = {
    'development': 'DEBUG',
    'testing': 'DEBUG',
    'production': 'INFO',
}
```

### C.6.2 Monitoring API Calls

```python
class APIMonitor:
    """Monitor API calls for troubleshooting."""
    
    def __init__(self):
        self.calls = []
    
    def log_call(self, provider: str, model: str, tokens: int, duration: float):
        """Log an API call."""
        self.calls.append({
            'timestamp': datetime.now().isoformat(),
            'provider': provider,
            'model': model,
            'tokens': tokens,
            'duration': duration
        })
    
    def get_stats(self) -> Dict[str, Any]:
        """Get API call statistics."""
        if not self.calls:
            return {'total_calls': 0}
        
        total_calls = len(self.calls)
        total_tokens = sum(c['tokens'] for c in self.calls)
        avg_duration = sum(c['duration'] for c in self.calls) / total_calls
        
        return {
            'total_calls': total_calls,
            'total_tokens': total_tokens,
            'avg_duration_ms': avg_duration * 1000,
            'calls_by_provider': self._group_by('provider'),
            'calls_by_model': self._group_by('model'),
        }
    
    def _group_by(self, key: str) -> Dict[str, int]:
        """Group calls by a key."""
        result = {}
        for call in self.calls:
            value = call.get(key, 'unknown')
            result[value] = result.get(value, 0) + 1
        return result
```

---

## C.7 Quick Reference: Error Resolution Steps

### Initial Troubleshooting Flowchart

```
1. System not working?
   ↓
2. Run: python scripts/diagnose.py
   ↓
3. Check output for FAIL or WARN
   ↓
4. If failures:
   a. Check Python version
   b. Install dependencies
   c. Configure API keys
   d. Verify file paths
   ↓
5. If warnings:
   a. Check log files
   b. Verify permissions
   c. Check disk space
   ↓
6. If still issues:
   a. Check API key validity
   b. Test API connectivity
   c. Review error logs
   ↓
7. If all else fails:
   a. Delete cache
   b. Reinstall dependencies
   c. Reclone repository
   d. Contact support
```

### Command Reference for Common Issues

```bash
# Check Python
python --version

# Check dependencies
pip list | grep -E "openai|langgraph|crewai"

# Check environment
python -c "import os; print(os.getenv('OPENAI_API_KEY', 'Not set'))"

# Check logs
tail -f logs/app.log

# Check costs
python review.py cost

# Check status
python review.py status

# Clear caches
rm -rf logs/checkpoints/
rm -f logs/costs.json

# Reset audit
rm -f logs/audit.json

# Rebuild embeddings
rm -rf .arch_review_cache.json
```

*Next: Appendix D - API Reference and Extension Guide*
