# Appendix D: API Reference & Extension Guide

## D.1 Overview

This appendix provides a comprehensive API reference for the Multi-Agent Architecture Review System and a guide for extending the system with new agents, tools, and integrations. Use this as a reference when building on top of the system or integrating it with other tools.

---

## D.2 Core API Reference

### D.2.1 Configuration API

**`src/utils/config.py`**

```python
class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.
    
    Attributes:
        openai_api_key (str): OpenAI API key
        anthropic_api_key (Optional[str]): Anthropic API key
        deepseek_api_key (Optional[str]): DeepSeek API key
        default_model (str): Default model for agents
        secondary_model (str): Fallback model
        max_tokens (int): Maximum tokens per API call
        temperature (float): Default temperature (0.0-1.0)
        environment (str): 'development', 'testing', or 'production'
        log_level (str): Logging level
        review_budget_usd (float): Maximum budget per review
        project_root (Path): Project root directory
        logs_dir (Path): Logs directory
    """
    
    def get_api_key(self, provider: str) -> Optional[str]:
        """
        Get API key for a specific provider.
        
        Args:
            provider: 'openai', 'anthropic', or 'deepseek'
            
        Returns:
            The API key or None if not configured
        """
        pass
    
    def is_provider_available(self, provider: str) -> bool:
        """
        Check if a provider is properly configured.
        
        Args:
            provider: 'openai', 'anthropic', or 'deepseek'
            
        Returns:
            True if the provider has a valid API key
        """
        pass

def get_settings() -> Settings:
    """Get the global settings instance."""
    pass

def setup_logging(level: Optional[str] = None) -> None:
    """Configure logging for the application."""
    pass
```

### D.2.2 Logger API

**`src/utils/logger.py`**

```python
class Logger:
    """
    Structured logger with context management.
    
    Features:
    - Context binding for correlation IDs
    - Structured JSON output
    - Automatic timestamp and level
    """
    
    def bind(self, **kwargs) -> 'Logger':
        """
        Create a new logger with additional context.
        
        Args:
            **kwargs: Key-value pairs to add to context
            
        Returns:
            A new Logger instance with added context
        """
        pass
    
    def debug(self, msg: str, **kwargs) -> None:
        """Log a debug message."""
        pass
    
    def info(self, msg: str, **kwargs) -> None:
        """Log an info message."""
        pass
    
    def warning(self, msg: str, **kwargs) -> None:
        """Log a warning message."""
        pass
    
    def error(self, msg: str, **kwargs) -> None:
        """Log an error message."""
        pass
    
    def critical(self, msg: str, **kwargs) -> None:
        """Log a critical message."""
        pass

def get_logger(name: str, **context) -> Logger:
    """
    Factory function to create a logger.
    
    Args:
        name: Logger name
        **context: Initial context fields
        
    Returns:
        A configured Logger instance
    """
    pass
```

### D.2.3 Base Agent API

**`src/agents/base_agent.py`**

```python
class BaseAgent(ABC):
    """
    Abstract base class for all AI agents.
    
    Subclasses must implement:
    - review(): Perform the review
    - get_prompt(): Generate the prompt messages
    
    Inherited methods:
    - _call_llm(): Call the LLM with messages
    - _init_llm_client(): Initialize the appropriate client
    """
    
    def __init__(self, name: str, model: Optional[str] = None):
        """
        Initialize the agent.
        
        Args:
            name: Agent name
            model: Optional model override
        """
        pass
    
    @abstractmethod
    def review(self, document: str) -> Dict[str, Any]:
        """
        Review a design document and return structured findings.
        
        Args:
            document: The design document text
            
        Returns:
            Dict containing findings, recommendations, and metadata
        """
        pass
    
    @abstractmethod
    def get_prompt(self, document: str) -> List[Dict[str, str]]:
        """
        Generate the prompt messages for this agent.
        
        Args:
            document: The design document text
            
        Returns:
            List of messages for the LLM
        """
        pass
    
    def _call_llm(
        self,
        messages: List[Dict[str, str]],
        temperature: Optional[float] = None,
        max_tokens: Optional[int] = None
    ) -> str:
        """
        Call the LLM with a list of messages.
        
        Args:
            messages: List of message dicts
            temperature: Optional temperature override
            max_tokens: Optional max tokens override
            
        Returns:
            The LLM's response text
        """
        pass
    
    def _init_llm_client(self) -> None:
        """Initialize the appropriate LLM client."""
        pass
```

### D.2.4 Agent Implementations

```python
# Functional Agent
class FunctionalAgent(BaseAgent):
    """Agent specialized in functional requirements analysis."""
    def review(self, document: str) -> Dict[str, Any]:
        """Review document for functional completeness."""
        pass

# Security Agent
class SecurityAgent(BaseAgent):
    """Agent specialized in security architecture review."""
    def review(self, document: str) -> Dict[str, Any]:
        """Review document for security vulnerabilities."""
        pass

# Data Agent
class DataAgent(BaseAgent):
    """Agent specialized in data architecture review."""
    def review(self, document: str) -> Dict[str, Any]:
        """Review document for data modeling issues."""
        pass

# DevOps Agent
class DevOpsAgent(BaseAgent):
    """Agent specialized in DevOps and cloud review."""
    def review(self, document: str) -> Dict[str, Any]:
        """Review document for operational readiness."""
        pass

# Reliability Agent
class ReliabilityAgent(BaseAgent):
    """Agent specialized in reliability and performance review."""
    def review(self, document: str) -> Dict[str, Any]:
        """Review document for reliability concerns."""
        pass
```

### D.2.5 Orchestration API

**`src/orchestration/unified_orchestrator.py`**

```python
class UnifiedOrchestrator:
    """
    Unified orchestrator combining LangGraph and CrewAI.
    
    Features:
    - LangGraph: Stateful review workflow with human gates
    - CrewAI: Professional documentation generation
    - Checkpointing: Resume interrupted reviews
    - Cost tracking: Monitor and control costs
    """
    
    def __init__(self, model: Optional[str] = None):
        """
        Initialize the unified orchestrator.
        
        Args:
            model: Optional model override
        """
        pass
    
    def review_and_document(
        self, 
        document: str, 
        document_path: str = "Unknown"
    ) -> Dict[str, Any]:
        """
        Complete workflow: review and document.
        
        Args:
            document: Document text to review
            document_path: Path to the document
            
        Returns:
            Complete results including documentation
        """
        pass
    
    def resume_review(self, thread_id: str) -> Dict[str, Any]:
        """
        Resume a previously interrupted review.
        
        Args:
            thread_id: The thread ID to resume
            
        Returns:
            Complete results
        """
        pass
    
    def list_reviews(self) -> list:
        """List all available review checkpoints."""
        pass
```

### D.2.6 Repository API

**`src/repository/scanner.py`**

```python
class RepositoryScanner:
    """
    Scans Git repositories and extracts relevant files.
    
    Features:
    - Repository traversal
    - File type detection
    - Content extraction
    - Context building
    - Change detection
    """
    
    def __init__(self, repo_path: Path):
        """
        Initialize the repository scanner.
        
        Args:
            repo_path: Path to the Git repository
        """
        pass
    
    def scan(self, target_files: Optional[List[str]] = None) -> Dict[str, Any]:
        """
        Scan the repository and extract relevant files.
        
        Args:
            target_files: Optional list of specific files to scan
            
        Returns:
            Dict with files, context, changes, and structure
        """
        pass
    
    def get_context_for_review(self, design_doc_path: Path) -> Dict[str, Any]:
        """
        Get context specifically for reviewing a design document.
        
        Args:
            design_doc_path: Path to the design document
            
        Returns:
            Context dictionary for the review
        """
        pass
```

**`src/repository/rag.py`**

```python
class RAGContext:
    """
    RAG system for providing repository context to agents.
    
    Features:
    - Embedding generation for files
    - Semantic search
    - Context retrieval
    - Cache management
    """
    
    def __init__(self, repo_path: Path, model_name: str = "all-MiniLM-L6-v2"):
        """
        Initialize the RAG system.
        
        Args:
            repo_path: Path to the Git repository
            model_name: Name of the embedding model
        """
        pass
    
    def search(self, query: str, top_k: int = 5) -> List[Dict[str, Any]]:
        """
        Search the repository for content relevant to a query.
        
        Args:
            query: Search query
            top_k: Number of results to return
            
        Returns:
            List of relevant documents with scores
        """
        pass
    
    def get_context_for_agent(self, agent_name: str, query: str) -> str:
        """
        Get relevant context for a specific agent.
        
        Args:
            agent_name: Name of the agent
            query: Specific query for this agent
            
        Returns:
            Relevant context as a string
        """
        pass
    
    def get_related_adrs(self, topic: str) -> List[Dict[str, Any]]:
        """
        Find ADRs related to a specific topic.
        
        Args:
            topic: Topic to search for
            
        Returns:
            List of relevant ADRs
        """
        pass
```

### D.2.7 Governance API

**`src/governance/permissions.py`**

```python
class Permission(Enum):
    """Permissions that can be granted to agents."""
    READ_DESIGN_DOCS = "read_design_docs"
    READ_CODE = "read_code"
    READ_CONFIGS = "read_configs"
    READ_ADRS = "read_adrs"
    READ_LOGS = "read_logs"
    GENERATE_ADR = "generate_adr"
    GENERATE_REPORT = "generate_report"
    WRITE_LOGS = "write_logs"
    EXECUTE_SCRIPTS = "execute_scripts"
    RUN_TESTS = "run_tests"
    MAKE_API_CALLS = "make_api_calls"

class PermissionManager:
    """
    Manages permissions and sandboxing for agents.
    
    Features:
    - Role-based access control
    - Action logging
    - Permission validation
    - Sandboxed execution
    """
    
    def get_permissions(self, agent_role: str) -> Set[Permission]:
        """Get permissions for a specific agent role."""
        pass
    
    def has_permission(self, agent_role: str, permission: Permission) -> bool:
        """Check if an agent has a specific permission."""
        pass
    
    def check_and_log(
        self, 
        agent_name: str, 
        agent_role: str, 
        action: str, 
        resource: str
    ) -> bool:
        """Check permission and log the attempt."""
        pass
    
    def get_audit_log(
        self, 
        agent_name: Optional[str] = None,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Get the audit log, optionally filtered by agent."""
        pass

class SandboxedExecutor:
    """Sandboxed execution environment for agents."""
    
    def __init__(self, workspace_dir: Path):
        """Initialize the sandboxed executor."""
        pass
    
    def is_path_allowed(self, path: Path) -> bool:
        """Check if a path is within the allowed workspace."""
        pass
    
    def execute_read(
        self, 
        agent_name: str, 
        agent_role: str,
        file_path: Path
    ) -> Optional[str]:
        """Execute a read operation with sandboxing."""
        pass
    
    def execute_write(
        self, 
        agent_name: str, 
        agent_role: str,
        file_path: Path, 
        content: str
    ) -> bool:
        """Execute a write operation with sandboxing."""
        pass
    
    def execute_api_call(
        self, 
        agent_name: str, 
        agent_role: str,
        provider: str
    ) -> bool:
        """Execute an API call with permission checking."""
        pass
```

**`src/governance/adr_generator.py`**

```python
class ADRGenerator:
    """
    Generates formal ADRs from review results.
    
    Features:
    - MADR format compliance
    - Automatic decision extraction
    - Risk-based status determination
    - Cross-reference generation
    """
    
    def __init__(self, output_dir: Optional[Path] = None):
        """
        Initialize the ADR generator.
        
        Args:
            output_dir: Directory to save ADRs
        """
        pass
    
    def generate_adr(self, review_results: Dict[str, Any]) -> Dict[str, Any]:
        """
        Generate an ADR from review results.
        
        Args:
            review_results: Results from the review workflow
            
        Returns:
            Dict with ADR content and metadata
        """
        pass
```

### D.2.8 Cost Tracker API

**`src/utils/cost_tracker.py`**

```python
class CostTracker:
    """
    Tracks API costs across all agents.
    
    Features:
    - Running total maintenance
    - Budget enforcement
    - Cost reporting
    - Persistent storage
    """
    
    def __init__(self):
        """Initialize the cost tracker."""
        pass
    
    def add_entry(self, entry: CostEntry) -> None:
        """Add a new cost entry."""
        pass
    
    def total_cost(self) -> float:
        """Calculate total cost of all entries."""
        pass
    
    def cost_last_24h(self) -> float:
        """Calculate cost for the last 24 hours."""
        pass
    
    def cost_by_agent(self) -> Dict[str, float]:
        """Calculate cost breakdown by agent."""
        pass
    
    def cost_by_model(self) -> Dict[str, float]:
        """Calculate cost breakdown by model."""
        pass
    
    def format_report(self) -> str:
        """Generate a human-readable cost report."""
        pass

def get_cost_tracker() -> CostTracker:
    """Get the global cost tracker instance."""
    pass
```

---

## D.3 Extension Guide

### D.3.1 Adding a New Agent

**Step 1: Create the Agent Class**

```python
# src/agents/compliance_agent.py

from typing import Dict, Any, List
from .base_agent import BaseAgent
from src.prompts.validation_matrix import DomainMatrix

class ComplianceAgent(BaseAgent):
    """
    Agent specialized in compliance and regulatory review.
    
    Reviews:
    - GDPR compliance
    - HIPAA compliance
    - SOC2 controls
    - Industry-specific regulations
    """
    
    def __init__(self, model: str = None):
        """Initialize the compliance agent."""
        super().__init__("ComplianceAgent", model)
        self.matrix = self._create_validation_matrix()
        self.logger.info("ComplianceAgent initialized")
    
    def _create_validation_matrix(self) -> DomainMatrix:
        """Create the compliance validation matrix."""
        checks = [
            {
                "id": "COMP-001",
                "description": "GDPR data protection requirements are addressed",
                "priority": "critical",
                "examples": ["No data processing agreement", "Missing data subject rights"],
                "suggestions": "Document GDPR compliance measures"
            },
            {
                "id": "COMP-002",
                "description": "Data retention and deletion policies are defined",
                "priority": "high",
                "examples": ["No retention period", "Missing deletion procedures"],
                "suggestions": "Define data retention and deletion policies"
            },
            # Add more compliance checks
        ]
        return DomainMatrix("Compliance", checks)
    
    def get_prompt(self, document: str) -> List[Dict[str, str]]:
        """Generate the compliance review prompt."""
        system_prompt = f"""You are the Compliance Architecture Agent, a specialist
        in reviewing software design documents for regulatory compliance.
        
        Your role is to ensure that:
        1. GDPR data protection requirements are addressed
        2. Data retention and deletion policies are defined
        3. Audit trail requirements are met
        4. Privacy by design principles are followed
        5. Regulatory reporting requirements are captured
        
        Validation checklist:
        {self.matrix.to_prompt()}
        
        Return your analysis as structured JSON.
        """
        
        user_prompt = f"""
        Review this design document for compliance concerns:
        
        {document}
        """
        
        return [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
    
    def review(self, document: str) -> Dict[str, Any]:
        """Review the document for compliance issues."""
        self.logger.info("Starting compliance review")
        
        messages = self.get_prompt(document)
        response = self._call_llm(messages)
        
        try:
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
            else:
                result = json.loads(response)
            
            result['domain'] = 'compliance'
            result['agent'] = self.name
            result['model'] = self.model
            
            # Calculate score
            findings = result.get('findings', [])
            if findings:
                passed = sum(1 for f in findings if f.get('status') == 'PASS')
                score = (passed / len(findings)) * 100
            else:
                score = 100
            
            result['score'] = round(score, 1)
            
            self.logger.info(f"Compliance review complete. Score: {score:.1f}%")
            return result
            
        except json.JSONDecodeError as e:
            self.logger.error(f"Failed to parse response: {e}")
            return {
                'domain': 'compliance',
                'agent': self.name,
                'model': self.model,
                'summary': 'Error parsing LLM response',
                'error': str(e),
                'findings': [],
                'score': 0,
                'overall_risk': 'HIGH'
            }
```

**Step 2: Update the Validation Matrix**

```python
# src/prompts/validation_matrix.py

def get_compliance_matrix() -> DomainMatrix:
    """Get the compliance validation matrix."""
    checks = [
        {
            "id": "COMP-001",
            "description": "GDPR data protection requirements are addressed",
            "priority": "critical",
            "examples": ["No data processing agreement", "Missing data subject rights"],
            "suggestions": "Document GDPR compliance measures"
        },
        {
            "id": "COMP-002",
            "description": "Data retention and deletion policies are defined",
            "priority": "high",
            "examples": ["No retention period", "Missing deletion procedures"],
            "suggestions": "Define data retention and deletion policies"
        },
        {
            "id": "COMP-003",
            "description": "Audit trail requirements are documented",
            "priority": "high",
            "examples": ["No audit logging", "Missing compliance report requirements"],
            "suggestions": "Design audit trail with compliance requirements"
        },
        {
            "id": "COMP-004",
            "description": "Privacy by design principles are followed",
            "priority": "medium",
            "examples": ["No data minimization", "Missing privacy impact assessment"],
            "suggestions": "Implement privacy by design principles"
        },
        {
            "id": "COMP-005",
            "description": "Regulatory reporting requirements are captured",
            "priority": "medium",
            "examples": ["No breach notification procedure", "Missing regulatory reporting"],
            "suggestions": "Define regulatory reporting requirements"
        }
    ]
    return DomainMatrix("Compliance", checks)

# Update VALIDATION_MATRICES dictionary
VALIDATION_MATRICES = {
    "functional": get_functional_matrix(),
    "security": get_security_matrix(),
    "data": get_data_matrix(),
    "devops": get_devops_matrix(),
    "reliability": get_reliability_matrix(),
    "compliance": get_compliance_matrix(),  # Add new matrix
}
```

**Step 3: Register the Agent**

```python
# src/agents/__init__.py

from .base_agent import BaseAgent
from .functional_agent import FunctionalAgent
from .security_agent import SecurityAgent
from .data_agent import DataAgent
from .devops_agent import DevOpsAgent
from .reliability_agent import ReliabilityAgent
from .compliance_agent import ComplianceAgent  # Import new agent
from .review_agent import ReviewAgent

__all__ = [
    'BaseAgent',
    'FunctionalAgent',
    'SecurityAgent',
    'DataAgent',
    'DevOpsAgent',
    'ReliabilityAgent',
    'ComplianceAgent',  # Add to exports
    'ReviewAgent',
]
```

**Step 4: Update the Orchestrator**

```python
# src/orchestration/simple_orchestrator.py

from src.agents import (
    FunctionalAgent,
    SecurityAgent,
    DataAgent,
    DevOpsAgent,
    ReliabilityAgent,
    ComplianceAgent,  # Import new agent
)

class SimpleOrchestrator:
    def __init__(self, model: Optional[str] = None):
        self.model = model
        self.logger = get_logger("simple_orchestrator")
        self.cost_tracker = get_cost_tracker()
        
        # Initialize all agents including the new one
        self.agents = {
            'functional': FunctionalAgent(model),
            'security': SecurityAgent(model),
            'data': DataAgent(model),
            'devops': DevOpsAgent(model),
            'reliability': ReliabilityAgent(model),
            'compliance': ComplianceAgent(model),  # Add new agent
        }
```

### D.3.2 Adding a New Tool

**Step 1: Create the Tool Class**

```python
# src/tools/security_scanner.py

"""
Security scanning tool for the repository.
"""

from typing import Dict, Any, List, Optional
from pathlib import Path
import re

from src.utils.logger import get_logger

class SecurityScanner:
    """
    Scans repository for security issues.
    
    Features:
    - Hardcoded secret detection
    - Vulnerability pattern scanning
    - Dependency checking
    """
    
    def __init__(self, repo_path: Path):
        """
        Initialize the security scanner.
        
        Args:
            repo_path: Path to the repository
        """
        self.repo_path = Path(repo_path)
        self.logger = get_logger("security_scanner")
        
        # Define patterns for secrets
        self.secret_patterns = {
            'api_key': re.compile(r'(api[_-]?key|apikey)\s*[:=]\s*["\']?([a-zA-Z0-9_\-]{20,})["\']?', re.IGNORECASE),
            'password': re.compile(r'(password|passwd|pwd)\s*[:=]\s*["\']?([^"\'\s]+)["\']?', re.IGNORECASE),
            'token': re.compile(r'(token|access_token|auth_token)\s*[:=]\s*["\']?([a-zA-Z0-9_\-\.]{20,})["\']?', re.IGNORECASE),
            'aws_key': re.compile(r'(AKIA|ASIA)[A-Z0-9]{16}'),
            'private_key': re.compile(r'-----BEGIN (RSA|DSA|EC|OPENSSH) PRIVATE KEY-----'),
        }
    
    def scan(self) -> Dict[str, Any]:
        """
        Scan the repository for security issues.
        
        Returns:
            Dict with security findings
        """
        self.logger.info(f"Scanning repository: {self.repo_path}")
        
        findings = {
            'secrets': [],
            'vulnerabilities': [],
            'dependencies': [],
        }
        
        # Scan all files
        for file_path in self.repo_path.rglob('*'):
            if not file_path.is_file():
                continue
            
            # Skip binary files
            try:
                content = file_path.read_text(encoding='utf-8', errors='ignore')
            except Exception:
                continue
            
            # Check for secrets
            secrets = self._check_secrets(content, file_path)
            if secrets:
                findings['secrets'].extend(secrets)
        
        self.logger.info(f"Found {len(findings['secrets'])} secrets")
        return findings
    
    def _check_secrets(self, content: str, file_path: Path) -> List[Dict[str, Any]]:
        """Check content for hardcoded secrets."""
        findings = []
        
        for secret_type, pattern in self.secret_patterns.items():
            matches = pattern.finditer(content)
            for match in matches:
                # Get context (lines around the match)
                lines = content.split('\n')
                line_num = content[:match.start()].count('\n')
                context_start = max(0, line_num - 2)
                context_end = min(len(lines), line_num + 3)
                context = '\n'.join(lines[context_start:context_end])
                
                findings.append({
                    'type': secret_type,
                    'file': str(file_path),
                    'line': line_num + 1,
                    'context': context,
                    'severity': 'CRITICAL',
                    'recommendation': f'Remove hardcoded {secret_type} and use environment variables'
                })
        
        return findings

# Register the tool with the system
# src/tools/__init__.py

from .security_scanner import SecurityScanner

__all__ = ['SecurityScanner']
```

### D.3.3 Adding a New Output Format

**Step 1: Create the Formatter**

```python
# src/governance/formatters/pdf_formatter.py

"""
PDF formatter for review reports.
"""

from typing import Dict, Any
from pathlib import Path
import json

from weasyprint import HTML
from jinja2 import Template

from src.utils.logger import get_logger

class PDFFormatter:
    """
    Generates PDF reports from review results.
    """
    
    def __init__(self):
        """Initialize the PDF formatter."""
        self.logger = get_logger("pdf_formatter")
        self.template = self._load_template()
    
    def _load_template(self) -> str:
        """Load the HTML template for PDF generation."""
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>Architecture Review Report</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 40px; }
                h1 { color: #2c3e50; border-bottom: 2px solid #3498db; }
                h2 { color: #34495e; margin-top: 30px; }
                .summary { background: #ecf0f1; padding: 20px; border-radius: 5px; }
                .finding { margin: 10px 0; padding: 10px; border-left: 4px solid; }
                .critical { border-color: #e74c3c; }
                .high { border-color: #e67e22; }
                .medium { border-color: #f1c40f; }
                .low { border-color: #2ecc71; }
                table { width: 100%; border-collapse: collapse; }
                th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
                th { background-color: #34495e; color: white; }
                .footer { margin-top: 50px; font-size: 12px; color: #7f8c8d; text-align: center; }
            </style>
        </head>
        <body>
            <h1>Architecture Review Report</h1>
            <div class="summary">
                <h2>Summary</h2>
                <p><strong>Review ID:</strong> {{ review_id }}</p>
                <p><strong>Score:</strong> {{ score }}%</p>
                <p><strong>Overall Risk:</strong> {{ risk }}</p>
                <p><strong>Total Findings:</strong> {{ total_findings }}</p>
            </div>
            
            <h2>Agent Results</h2>
            <table>
                <tr>
                    <th>Agent</th>
                    <th>Score</th>
                    <th>Risk</th>
                    <th>Findings</th>
                </tr>
                {% for agent, result in agents.items() %}
                <tr>
                    <td>{{ agent|upper }}</td>
                    <td>{{ result.score }}%</td>
                    <td>{{ result.overall_risk }}</td>
                    <td>{{ result.findings|length }}</td>
                </tr>
                {% endfor %}
            </table>
            
            <h2>Detailed Findings</h2>
            {% for agent, result in agents.items() %}
                {% if result.findings %}
                <h3>{{ agent|upper }}</h3>
                {% for finding in result.findings %}
                <div class="finding {{ finding.severity|lower }}">
                    <strong>{{ finding.severity }}:</strong> {{ finding.recommendation }}
                    <br>
                    <em>Evidence:</em> {{ finding.evidence[:200] }}...
                </div>
                {% endfor %}
                {% endif %}
            {% endfor %}
            
            <div class="footer">
                Generated by Multi-Agent Architecture Review System
                <br>
                {{ timestamp }}
            </div>
        </body>
        </html>
        """
    
    def format(self, results: Dict[str, Any], output_path: Path) -> Path:
        """
        Generate a PDF report from review results.
        
        Args:
            results: Review results
            output_path: Path to save the PDF
            
        Returns:
            Path to the generated PDF
        """
        self.logger.info(f"Generating PDF report to {output_path}")
        
        # Prepare data for template
        template_data = {
            'review_id': results.get('review_id', 'N/A'),
            'score': results.get('aggregated_score', 0),
            'risk': results.get('overall_risk', 'UNKNOWN'),
            'total_findings': results.get('total_findings', 0),
            'agents': results.get('results', {}),
            'timestamp': results.get('timestamp', ''),
        }
        
        # Render HTML
        template = Template(self.template)
        html_content = template.render(**template_data)
        
        # Generate PDF
        output_path.parent.mkdir(parents=True, exist_ok=True)
        HTML(string=html_content).write_pdf(str(output_path))
        
        self.logger.info(f"PDF generated: {output_path}")
        return output_path
```

**Step 2: Register the Formatter**

```python
# src/governance/formatters/__init__.py

from .pdf_formatter import PDFFormatter

__all__ = ['PDFFormatter']

# Register formatters
FORMATTERS = {
    'json': 'json_formatter',
    'txt': 'txt_formatter',
    'pdf': 'pdf_formatter',
}
```

**Step 3: Update the CLI**

```python
# src/cli.py - Add PDF output option

@cli.command()
@click.option(
    '--format',
    '-f',
    type=click.Choice(['json', 'txt', 'pdf', 'all']),
    default='all',
    help='Output format(s)'
)
@click.option(
    '--output-pdf',
    type=click.Path(path_type=Path),
    help='Path for PDF output'
)
def generate_report(format: str, output_pdf: Optional[Path]):
    """Generate a report from review results."""
    # Implementation...
    
    if format in ['pdf', 'all']:
        from src.governance.formatters import PDFFormatter
        pdf_formatter = PDFFormatter()
        pdf_path = output_pdf or Path('docs/outputs/report.pdf')
        pdf_formatter.format(results, pdf_path)
        console.print(f"[green]✓ PDF report saved to: {pdf_path}[/green]")
```

---

## D.4 Integration Patterns

### D.4.1 REST API Integration

```python
# src/api/main.py

"""
REST API for the Multi-Agent Architecture Review System.
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from pathlib import Path
from typing import Optional

from src.orchestration.unified_orchestrator import UnifiedOrchestrator
from src.utils.logger import get_logger

app = FastAPI(title="Multi-Agent Architecture Review API")
logger = get_logger("api")

class ReviewRequest(BaseModel):
    """Request model for a review."""
    document: str
    document_path: Optional[str] = None
    model: Optional[str] = None
    use_rag: bool = False
    auto_approve: bool = False

class ReviewResponse(BaseModel):
    """Response model for a review."""
    review_id: Optional[str]
    status: str
    score: Optional[float]
    risk: Optional[str]
    findings: Optional[int]
    report_url: Optional[str]

@app.post("/api/review")
async def start_review(request: ReviewRequest) -> ReviewResponse:
    """
    Start a new architecture review.
    
    Args:
        request: Review request
        
    Returns:
        Review response with status
    """
    logger.info(f"Review request received for {request.document_path}")
    
    try:
        orchestrator = UnifiedOrchestrator(model=request.model)
        result = orchestrator.review_and_document(
            request.document,
            request.document_path or "API Request"
        )
        
        return ReviewResponse(
            review_id=result.get('review_id'),
            status=result.get('status', 'unknown'),
            score=result.get('aggregated_score'),
            risk=result.get('overall_risk'),
            findings=result.get('total_findings'),
            report_url=f"/reports/{result.get('review_id')}"
        )
    except Exception as e:
        logger.error(f"Review failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/status")
async def get_status():
    """Get system status."""
    return {
        'status': 'healthy',
        'version': '1.0.0',
        'environment': 'production'
    }
```

### D.4.2 CI/CD Integration

```yaml
# .github/workflows/architecture-review.yml

name: Architecture Review

on:
  pull_request:
    paths:
      - 'docs/designs/**/*.md'
      - '**.md'

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Run architecture review
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          python review.py review \
            -d docs/designs/**/*.md \
            --repo . \
            --use-rag \
            --approve \
            --output docs/outputs/
      
      - name: Upload review results
        uses: actions/upload-artifact@v4
        with:
          name: review-results
          path: docs/outputs/
      
      - name: Comment on PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const results = JSON.parse(fs.readFileSync('docs/outputs/latest.json'));
            const comment = `## Architecture Review Results
            **Score:** ${results.aggregated_score}%
            **Risk:** ${results.overall_risk}
            **Findings:** ${results.total_findings}
            **ADRs:** ${results.adr_count || 0}
            `;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: comment
            });
```

