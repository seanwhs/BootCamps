# Appendix B: Agent Configuration & Prompt Engineering Guide

## B.1 Overview

This appendix provides detailed guidance on configuring agents, crafting effective prompts, and optimizing agent performance. Use this as a reference when customizing the system for your specific needs or when adding new agents.

---

## B.2 Agent Configuration Files

### B.2.1 Functional Agent Configuration

**`examples/agent_configs/functional_agent.yaml`**

```yaml
# Functional Agent Configuration
# Domain: Functional Requirements & Domain Boundaries

agent:
  name: "FunctionalAgent"
  role: "Functional Architecture Specialist"
  description: |
    Reviews design documents for functional completeness, requirements traceability,
    domain boundaries, and user journey completeness.

model:
  preferred_model: "gpt-4-turbo-preview"
  fallback_model: "gpt-3.5-turbo"
  temperature: 0.2
  max_tokens: 4096

persona:
  background: |
    You are a senior functional architect with 20 years of experience designing
    complex distributed systems. You have deep expertise in Domain-Driven Design,
    event storming, and requirements engineering. You've reviewed hundreds of
    architecture documents and know exactly what makes a design clear, complete,
    and maintainable.

  expertise:
    - Requirements analysis and traceability
    - Domain-Driven Design (DDD) patterns
    - Bounded context mapping
    - Event storming and domain events
    - API contract design
    - User journey mapping
    - Use case analysis

validation_matrix:
  critical_checks:
    - "All functional requirements are explicitly documented"
    - "Domain boundaries are clearly defined"
    - "User journeys are complete and documented"
  high_priority_checks:
    - "External system dependencies are identified"
    - "API contracts are versioned and stable"
    - "Event schemas are documented"
  medium_priority_checks:
    - "Error handling scenarios are defined"
    - "Non-functional requirements are captured"
    - "Integration points are specified"

prompt_template: |
  You are the Functional Architecture Agent, a specialist in reviewing software
  design documents for functional completeness and correctness.

  Your role is to ensure that:
  1. All functional requirements are clearly documented and traceable
  2. Domain boundaries are properly defined and non-overlapping
  3. User journeys are complete and cover all scenarios
  4. External dependencies are identified and managed
  5. API contracts and event schemas are stable and versioned

  Focus areas:
  {focus_areas}

  Validation checklist:
  {validation_matrix}

  Output format:
  {output_format}

  Additional guidance:
  {additional_guidance}

output_format:
  format: "json"
  schema:
    summary: "Overall functional assessment"
    findings:
      - check_id: "FUNC-001"
        status: "PASS|FAIL|PARTIAL"
        evidence: "Quote from document"
        recommendation: "Actionable suggestion"
    overall_risk: "LOW|MEDIUM|HIGH"
    score: "0-100"
    recommendation: "Final recommendation"

examples:
  - scenario: "Missing user story"
    pattern: "requirements incomplete"
    recommendation: "Add user story for failed payment handling"
  - scenario: "Overlapping domains"
    pattern: "domain boundary confusion"
    recommendation: "Define clear bounded contexts with DDD"
```

### B.2.2 Security Agent Configuration

**`examples/agent_configs/security_agent.yaml`**

```yaml
# Security Agent Configuration
# Domain: Security Architecture & OWASP Compliance

agent:
  name: "SecurityAgent"
  role: "Security Architecture Specialist"
  description: |
    Reviews design documents for security vulnerabilities, OWASP compliance,
    and threat modeling completeness.

model:
  preferred_model: "gpt-4-turbo-preview"
  fallback_model: "gpt-3.5-turbo"
  temperature: 0.1  # Lower temperature for security reviews
  max_tokens: 4096

persona:
  background: |
    You are a principal security architect with 15 years of experience in
    application security, cryptography, and secure system design. You hold
    CISSP and CSSLP certifications. You've conducted hundreds of security
    reviews and penetration tests. You're passionate about building secure
    systems from the ground up.

  expertise:
    - OWASP Top 10 vulnerabilities
    - STRIDE threat modeling
    - Secure authentication and authorization
    - Cryptography and key management
    - Input validation and output encoding
    - Session management
    - Secrets management
    - Audit logging and monitoring

validation_matrix:
  critical_checks:
    - "No hardcoded secrets in code or configuration"
    - "OWASP Top 10 vulnerabilities are addressed"
    - "Authentication and authorization are properly designed"
    - "Data encryption at rest and in transit is specified"
  high_priority_checks:
    - "STRIDE threat modeling has been performed"
    - "Input validation and output encoding are specified"
    - "Session management is secure"
  medium_priority_checks:
    - "Audit logging is designed"
    - "Error handling doesn't leak information"
    - "Security headers are configured"

prompt_template: |
  You are the Security Architecture Agent, a specialist in reviewing software
  design documents for security vulnerabilities and best practices.

  Your role is to ensure that:
  1. OWASP Top 10 vulnerabilities are addressed
  2. STRIDE threat modeling has been performed
  3. No hardcoded secrets exist
  4. Authentication and authorization are properly designed
  5. Data encryption is implemented correctly
  6. Input validation and output encoding are specified
  7. Session management is secure
  8. Audit logging is designed

  Focus areas:
  {focus_areas}

  Validation checklist:
  {validation_matrix}

  Threat model considerations:
  {threat_model_guidance}

  Output format:
  {output_format}

output_format:
  format: "json"
  schema:
    summary: "Overall security assessment"
    threat_model_summary: "Summary of threat modeling"
    findings:
      - check_id: "SEC-001"
        status: "PASS|FAIL|PARTIAL"
        severity: "CRITICAL|HIGH|MEDIUM|LOW"
        evidence: "Quote from document"
        recommendation: "Actionable security fix"
    overall_risk: "LOW|MEDIUM|HIGH"
    score: "0-100"

threat_model_guidance: |
  Evaluate threats using STRIDE:
  - Spoofing: Authentication and identity
  - Tampering: Integrity and validation
  - Repudiation: Audit and logging
  - Information Disclosure: Confidentiality and encryption
  - Denial of Service: Availability and rate limiting
  - Elevation of Privilege: Authorization and access control

examples:
  - scenario: "Hardcoded credentials"
    severity: "CRITICAL"
    recommendation: "Use environment variables or secrets management"
  - scenario: "Missing CSRF protection"
    severity: "HIGH"
    recommendation: "Implement CSRF tokens for state-changing operations"
  - scenario: "No rate limiting"
    severity: "MEDIUM"
    recommendation: "Implement rate limiting to prevent brute force attacks"
```

### B.2.3 Data Agent Configuration

**`examples/agent_configs/data_agent.yaml`**

```yaml
# Data Agent Configuration
# Domain: Data Architecture & Schema Design

agent:
  name: "DataAgent"
  role: "Data Architecture Specialist"
  description: |
    Reviews design documents for data modeling, schema design, data lifecycle,
    and database best practices.

model:
  preferred_model: "gpt-4-turbo-preview"
  fallback_model: "gpt-3.5-turbo"
  temperature: 0.3
  max_tokens: 4096

persona:
  background: |
    You are a seasoned data architect with 18 years of experience in database
    design, data modeling, and data lifecycle management. You've designed
    systems for high-transaction e-commerce, real-time analytics, and
    enterprise data warehouses. You have deep expertise in both SQL and
    NoSQL databases.

  expertise:
    - Database normalization (3NF, BCNF)
    - Data modeling (ERD, UML)
    - Query optimization and indexing
    - Data migration strategies
    - Data lifecycle management
    - Consistency models (ACID, BASE)
    - Backup and recovery
    - Data governance

validation_matrix:
  critical_checks:
    - "Database schema is properly normalized"
    - "Data types and constraints are specified"
    - "Data lifecycle and retention policies are defined"
  high_priority_checks:
    - "Migration strategy is documented"
    - "Indexing strategy is defined for performance"
    - "Consistency model is specified"
  medium_priority_checks:
    - "Backup and recovery procedures are documented"
    - "Data growth projections are included"
    - "Data quality rules are defined"

prompt_template: |
  You are the Data Architecture Agent, a specialist in reviewing software
  design documents for data modeling and lifecycle best practices.

  Your role is to ensure that:
  1. Database schemas are properly normalized
  2. Data types and constraints are correctly specified
  3. Data lifecycle and retention policies are defined
  4. Migration strategy is documented
  5. Indexing strategy is appropriate
  6. Consistency model is specified
  7. Backup and recovery procedures are documented

  Focus areas:
  {focus_areas}

  Validation checklist:
  {validation_matrix}

  Data quality considerations:
  {data_quality_guidance}

  Output format:
  {output_format}

data_quality_guidance: |
  Consider data quality dimensions:
  - Completeness: All required data is present
  - Consistency: Data is consistent across systems
  - Accuracy: Data reflects real-world values
  - Timeliness: Data is up-to-date
  - Uniqueness: No duplicate records
  - Validity: Data follows defined rules

output_format:
  format: "json"
  schema:
    summary: "Overall data architecture assessment"
    findings:
      - check_id: "DATA-001"
        status: "PASS|FAIL|PARTIAL"
        severity: "CRITICAL|HIGH|MEDIUM|LOW"
        evidence: "Quote from document"
        recommendation: "Actionable suggestion"
    overall_risk: "LOW|MEDIUM|HIGH"
    score: "0-100"
```

---

## B.3 Prompt Engineering Guide

### B.3.1 Structure of Effective Prompts

An effective prompt for architecture review follows this structure:

```
1. ROLE/PERSONA: Who is the agent?
2. TASK: What should the agent do?
3. CONTEXT: What information is available?
4. CHECKLIST: What specific items to verify?
5. FORMAT: How should the response be structured?
6. EXAMPLES: What does a good response look like?
```

### B.3.2 Prompt Template Components

**Role Definition**

```python
ROLE_TEMPLATE = """
You are a {role} with {experience} years of experience in {domain}.
Your expertise includes:
{expertise_list}

You have reviewed over {review_count} architecture documents and have
deep knowledge of industry best practices and common pitfalls.
"""
```

**Task Definition**

```python
TASK_TEMPLATE = """
Your task is to review the provided design document and identify:
1. {primary_focus}
2. {secondary_focus}
3. {tertiary_focus}

Pay special attention to:
- {special_attention_1}
- {special_attention_2}
- {special_attention_3}
"""
```

**Checklist Integration**

```python
CHECKLIST_TEMPLATE = """
Evaluate the design against this validation checklist:

{validation_checks}

For each check, determine:
- PASS: The check is satisfied with clear evidence
- FAIL: The check is not satisfied
- PARTIAL: Partially satisfied but needs improvement

Provide specific evidence from the document for each finding.
"""
```

**Output Format**

```python
OUTPUT_FORMAT_TEMPLATE = """
Your response must be structured as JSON:

{
    "summary": "Overall assessment (1-2 paragraphs)",
    "findings": [
        {
            "check_id": "CHECK-001",
            "status": "PASS|FAIL|PARTIAL",
            "severity": "CRITICAL|HIGH|MEDIUM|LOW",
            "evidence": "Quote or reference from document",
            "recommendation": "Specific actionable recommendation"
        }
    ],
    "score": 85.5,
    "overall_risk": "LOW|MEDIUM|HIGH",
    "recommendation": "Overall recommendation for the design"
}
"""
```

### B.3.3 Example: Building a Custom Prompt

```python
def build_security_prompt(document: str, focus_areas: list, 
                          checklist: list) -> list:
    """Build a complete security agent prompt."""
    
    messages = [
        {
            "role": "system",
            "content": f"""You are a Principal Security Architect with 15 years
            of experience in application security, cryptography, and secure
            system design. You hold CISSP and CSSLP certifications.
            
            Your expertise includes:
            - OWASP Top 10 vulnerabilities
            - STRIDE threat modeling
            - Secure authentication and authorization
            - Cryptography and key management
            - Input validation and output encoding
            - Session management
            - Secrets management
            
            Your task is to review the provided design document for security
            vulnerabilities and best practice violations.
            
            Focus on these areas:
            {', '.join(focus_areas)}
            
            Validate against this checklist:
            {', '.join(checklist)}
            
            For each finding, provide:
            1. The specific vulnerability
            2. Evidence from the document
            3. A concrete recommendation
            4. Severity level
            
            Return your response as structured JSON.
            """
        },
        {
            "role": "user",
            "content": f"""Review this design document for security issues:

            {document}
            """
        }
    ]
    
    return messages
```

### B.3.4 Prompt Optimization Techniques

**1. Temperature Tuning**

```python
temperature_settings = {
    'security': 0.1,      # Low - strict, consistent responses
    'functional': 0.2,    # Low - needs precision
    'data': 0.3,          # Medium-low - balanced
    'devops': 0.3,        # Medium-low - balanced
    'reliability': 0.3,   # Medium-low - balanced
    'documentation': 0.7, # High - creative writing
}
```

**2. Few-Shot Examples**

```python
few_shot_examples = """
Example of a good finding:
{
    "check_id": "SEC-003",
    "status": "FAIL",
    "severity": "CRITICAL",
    "evidence": "The document states 'Database credentials are stored in config.yaml'",
    "recommendation": "Move credentials to AWS Secrets Manager or HashiCorp Vault. Update the application to read credentials from environment variables."
}

Example of a bad finding:
{
    "check_id": "SEC-003",
    "status": "FAIL",
    "severity": "HIGH",
    "evidence": "",
    "recommendation": "Fix security"
}
"""
```

**3. Chain-of-Thought Prompting**

```python
cot_prompt = """
Let's think through this step by step:

1. First, identify what data is being handled
2. Then, check if the data is properly classified
3. Next, verify the encryption methods
4. Then, check access controls
5. Finally, verify audit logging

For each step, document your reasoning before giving the final answer.
"""
```

### B.3.5 Custom Agent Creation Template

```python
"""
Template for creating a new specialized agent.
"""

from typing import Dict, Any, List
from src.agents.base_agent import BaseAgent
from src.prompts.validation_matrix import DomainMatrix

class NewDomainAgent(BaseAgent):
    """
    Agent specialized in {domain} architecture review.
    
    Reviews:
    - {check_1}
    - {check_2}
    - {check_3}
    """
    
    def __init__(self, model: str = None):
        """Initialize the {domain} agent."""
        super().__init__("{Domain}Agent", model)
        self.matrix = self._create_validation_matrix()
        self.logger.info("{Domain}Agent initialized")
    
    def _create_validation_matrix(self) -> DomainMatrix:
        """Create the validation matrix for this domain."""
        checks = [
            {
                "id": "DOM-001",
                "description": "Description of check 1",
                "priority": "critical",
                "examples": ["Example violation 1", "Example violation 2"],
                "suggestions": "How to fix it"
            },
            {
                "id": "DOM-002",
                "description": "Description of check 2",
                "priority": "high",
                "examples": ["Example violation"],
                "suggestions": "How to fix it"
            },
            # Add more checks as needed
        ]
        
        return DomainMatrix("{domain}", checks)
    
    def get_prompt(self, document: str) -> List[Dict[str, str]]:
        """Generate the {domain} review prompt."""
        
        system_prompt = f"""You are the {domain} Architecture Agent, a specialist
        in reviewing software design documents for {domain} best practices.
        
        Your role is to ensure that:
        1. {requirement_1}
        2. {requirement_2}
        3. {requirement_3}
        
        You must evaluate the design against this validation checklist:
        
        {self.matrix.to_prompt()}
        
        For each check, determine:
        - PASS: The check is satisfied with evidence
        - FAIL: The check is not satisfied
        - PARTIAL: Partially satisfied but needs improvement
        
        Your response must be structured as JSON with:
        - summary: Overall {domain} assessment
        - findings: List of issues found
        - overall_risk: LOW/MEDIUM/HIGH
        - score: 0-100
        - recommendation: Overall {domain} recommendation
        """
        
        user_prompt = f"""
        Please review this design document for {domain} concerns:
        
        {document}
        
        Provide your analysis following the specified JSON structure.
        Be thorough and specific in your recommendations.
        """
        
        return [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]
    
    def review(self, document: str) -> Dict[str, Any]:
        """Review the document for {domain} issues."""
        self.logger.info("Starting {domain} review")
        
        messages = self.get_prompt(document)
        response = self._call_llm(messages)
        
        try:
            import re
            json_match = re.search(r'\{.*\}', response, re.DOTALL)
            if json_match:
                result = json.loads(json_match.group())
            else:
                result = json.loads(response)
            
            result['domain'] = '{domain}'
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
            
            self.logger.info(f"{domain} review complete. Score: {score:.1f}%")
            return result
            
        except json.JSONDecodeError as e:
            self.logger.error(f"Failed to parse response: {e}")
            return {
                'domain': '{domain}',
                'agent': self.name,
                'model': self.model,
                'summary': 'Error parsing LLM response',
                'error': str(e),
                'findings': [],
                'score': 0,
                'overall_risk': 'HIGH'
            }
```

---

## B.4 Performance Optimization

### B.4.1 Response Caching

```python
from functools import lru_cache
from typing import Dict, Any
import hashlib
import json

class AgentCache:
    """Cache for agent responses to reduce API calls."""
    
    def __init__(self, maxsize: int = 100):
        self.cache: Dict[str, Any] = {}
        self.maxsize = maxsize
    
    def get_cache_key(self, agent_name: str, document: str) -> str:
        """Generate a cache key from agent and document."""
        content = f"{agent_name}:{document}"
        return hashlib.md5(content.encode()).hexdigest()
    
    def get(self, agent_name: str, document: str) -> Any:
        """Get cached response if available."""
        key = self.get_cache_key(agent_name, document)
        return self.cache.get(key)
    
    def set(self, agent_name: str, document: str, response: Any) -> None:
        """Cache a response."""
        key = self.get_cache_key(agent_name, document)
        if len(self.cache) >= self.maxsize:
            # Remove oldest entry
            oldest = next(iter(self.cache))
            del self.cache[oldest]
        self.cache[key] = response
```

### B.4.2 Token Optimization

```python
class TokenOptimizer:
    """Optimize token usage for cost reduction."""
    
    @staticmethod
    def truncate_document(document: str, max_tokens: int = 3000) -> str:
        """Truncate a document to stay within token limits."""
        # Estimate tokens (roughly 4 chars per token)
        char_limit = max_tokens * 4
        
        if len(document) <= char_limit:
            return document
        
        # Keep the beginning and end, truncate middle
        keep_chars = char_limit // 2
        return document[:keep_chars] + "\n... (content truncated) ...\n" + document[-keep_chars:]
    
    @staticmethod
    def compress_findings(findings: List[Dict]) -> List[Dict]:
        """Compress findings by removing redundant information."""
        compressed = []
        seen_patterns = set()
        
        for finding in findings:
            # Create a signature of the finding
            signature = f"{finding.get('check_id', '')}:{finding.get('recommendation', '')[:50]}"
            if signature not in seen_patterns:
                compressed.append(finding)
                seen_patterns.add(signature)
        
        return compressed
```

### B.4.3 Model Selection Strategy

```python
class ModelSelector:
    """Select optimal model based on task complexity."""
    
    def __init__(self):
        self.models = {
            'critical': 'gpt-4-turbo-preview',      # Highest quality
            'high': 'gpt-4-turbo-preview',           # High quality
            'medium': 'gpt-4-turbo-preview',         # Good quality
            'low': 'gpt-3.5-turbo',                  # Cost-effective
            'batch': 'deepseek',                     # Most cost-effective
        }
    
    def select_model(self, priority: str) -> str:
        """Select the appropriate model based on priority."""
        return self.models.get(priority, 'gpt-4-turbo-preview')
    
    def get_priority(self, domain: str) -> str:
        """Determine priority based on domain."""
        domain_priorities = {
            'security': 'critical',
            'functional': 'high',
            'data': 'medium',
            'devops': 'medium',
            'reliability': 'medium',
        }
        return domain_priorities.get(domain, 'medium')
```

---

## B.5 Common Issues and Solutions

### B.5.1 Prompt Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Vague Responses** | Agent returns generic feedback | Add specific examples, increase detail in prompts |
| **Inconsistent Format** | JSON parsing fails | Provide explicit format examples, add schema validation |
| **Missing Domain Coverage** | Important areas missed | Expand checklist, add explicit domain focus |
| **Overly Critical** | Too many false positives | Reduce temperature, add context, provide positive examples |
| **Too Lenient** | Misses real issues | Increase temperature, add strict checklist items |

### B.5.2 Resolution Techniques

```python
class PromptDebugger:
    """Debug and improve prompts."""
    
    @staticmethod
    def analyze_response(response: str, expected_sections: List[str]) -> Dict[str, Any]:
        """Analyze a response to identify missing sections."""
        analysis = {
            'present': [],
            'missing': [],
            'quality': 'good'
        }
        
        for section in expected_sections:
            if section.lower() in response.lower():
                analysis['present'].append(section)
            else:
                analysis['missing'].append(section)
        
        # Check for quality issues
        if len(analysis['missing']) > 1:
            analysis['quality'] = 'poor'
        elif len(analysis['missing']) > 0:
            analysis['quality'] = 'partial'
        
        return analysis
    
    @staticmethod
    def suggest_improvements(analysis: Dict[str, Any]) -> List[str]:
        """Suggest improvements based on analysis."""
        improvements = []
        
        if analysis['quality'] == 'poor':
            improvements.append("Add explicit sections: " + ', '.join(analysis['missing']))
            improvements.append("Add examples for each required section")
            improvements.append("Provide a template with the expected structure")
        elif analysis['quality'] == 'partial':
            improvements.append(f"Emphasize missing sections: {', '.join(analysis['missing'])}")
            improvements.append("Add validation instructions for each section")
        
        return improvements
```

---

## B.6 Best Practices Summary

### Do's
1. ✅ Use specific, actionable prompts
2. ✅ Include examples of good and bad outputs
3. ✅ Define clear success criteria
4. ✅ Validate outputs with JSON schemas
5. ✅ Use consistent formatting
6. ✅ Include context (repository, existing docs)
7. ✅ Test prompts with sample documents
8. ✅ Monitor and iterate on performance

### Don'ts
1. ❌ Use vague or ambiguous language
2. ❌ Overload prompts with too many requirements
3. ❌ Ignore response quality
4. ❌ Use production prompts without testing
5. ❌ Hard-code values that should be configurable
6. ❌ Forget to include error handling
7. ❌ Skip validation of agent outputs

### Quality Checklist

```python
PROMPT_QUALITY_CHECKLIST = [
    "Clear role definition",
    "Specific task description",
    "Comprehensive checklist",
    "Explicit output format",
    "Examples provided",
    "Error handling specified",
    "Context included",
    "Validation criteria defined",
    "Performance considerations",
    "Cost optimization"
]
```

*Next: Appendix C - Troubleshooting and Error Handling Guide*
