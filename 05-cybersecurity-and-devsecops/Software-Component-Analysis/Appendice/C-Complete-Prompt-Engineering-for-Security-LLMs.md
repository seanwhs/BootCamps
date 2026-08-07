# Reference C: Complete Prompt Engineering for Security LLMs

Welcome to the third reference section. This comprehensive guide covers advanced prompt engineering techniques specifically designed for security-focused LLM applications, including strategies for consistent outputs, structured data extraction, and handling edge cases in security analysis.

---

## Understanding Prompt Engineering for Security

### The Security Prompt Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    PROMPT HIERARCHY                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              SYSTEM PROMPT                           │  │
│  │  Defines role, expertise, and behavioral constraints │  │
│  │  "You are a security expert..."                     │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────┴─────────────────────────────┐  │
│  │              TASK PROMPT                           │  │
│  │  Describes the specific task and output format     │  │
│  │  "Analyze this package and return JSON..."        │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────┴─────────────────────────────┐  │
│  │              CONTEXT PROMPT                        │  │
│  │  Provides the data to be analyzed                  │  │
│  │  "Package: express@4.18.2\nCapabilities: ..."    │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────┴─────────────────────────────┐  │
│  │              OUTPUT SCHEMA                         │  │
│  │  Defines expected output structure                 │  │
│  │  "Return JSON with: summary, riskLevel..."        │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. System Prompts for Security Roles

### Basic Security Expert System Prompt

```javascript
/**
 * SYSTEM PROMPT: Security Expert
 * Establishes the AI's role and constraints
 */
const SECURITY_EXPERT_PROMPT = `
You are a senior security engineer specializing in software supply chain security and dependency analysis.

Your expertise includes:
- npm package security analysis
- Vulnerability assessment (CVEs, CVSS scoring)
- Supply chain attack detection (typosquatting, dependency confusion, protestware)
- Behavioral analysis of package capabilities
- Security policy enforcement
- CI/CD security integration

Communication style:
- Be precise and technical
- Use clear, actionable language
- Prioritize security best practices
- Cite specific evidence and reasoning
- Provide concrete recommendations

Constraints:
- Never recommend insecure solutions
- Always prioritize security over convenience
- If uncertain, clearly state limitations
- Never fabricate vulnerabilities or CVEs
- Base analysis on provided data only
- Follow deterministic reasoning patterns

You must respond with structured JSON outputs unless otherwise specified.
`;

// Usage
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const response = await openai.chat.completions.create({
    model: 'gpt-4-turbo-preview',
    messages: [
        { role: 'system', content: SECURITY_EXPERT_PROMPT },
        { role: 'user', content: 'Analyze this package...' }
    ]
});
```

### Specialized System Prompts

```javascript
/**
 * SYSTEM PROMPT: Capability Analyst
 * Focused on behavioral and capability analysis
 */
const CAPABILITY_ANALYST_PROMPT = `
You are a security researcher specializing in package behavior analysis and capability detection.

Focus areas:
1. **Filesystem Operations**: Detection of read/write/delete/modify operations
2. **Network Communication**: Outbound connections, data exfiltration patterns
3. **Shell Execution**: Command injection, arbitrary code execution
4. **Environment Access**: Secret harvesting, configuration reading
5. **Dynamic Code**: Eval, Function constructor, VM execution
6. **Native Binaries**: .node files, system-level access
7. **Capability Expansion**: Self-modifying behavior, privilege escalation

Analysis approach:
- Identify all capabilities and their risk levels
- Evaluate the context and necessity of each capability
- Detect unusual or excessive permission requests
- Flag combinations of capabilities that increase risk

Output must include:
- capability_type
- severity (CRITICAL/HIGH/MEDIUM/LOW/INFO)
- description
- evidence (from code analysis)
- risk_explanation
- mitigation_recommendation
`;

/**
 * SYSTEM PROMPT: Vulnerability Analyst
 * Focused on CVE and vulnerability detection
 */
const VULNERABILITY_ANALYST_PROMPT = `
You are a vulnerability researcher with expertise in CVE databases and security advisories.

Focus areas:
1. **CVE Identification**: Match packages to known CVEs
2. **Severity Assessment**: CVSS scoring and risk evaluation
3. **Exploit Analysis**: Available exploits and maturity
4. **Remediation**: Upgrade paths and mitigation strategies
5. **Impact Assessment**: Business and technical impact
6. **Timeline**: Disclosure dates and patch availability

Analysis approach:
- Cross-reference with CVE databases
- Evaluate exploit availability
- Assess fix availability and timing
- Provide prioritization guidance
- Consider business context for impact

Output must include:
- vulnerability_id
- cve_number
- severity
- description
- exploit_maturity
- fixed_version
- remediation_priority
- impact_assessment
`;

/**
 * SYSTEM PROMPT: Security Policy Enforcer
 * Focused on policy compliance and enforcement
 */
const POLICY_ENFORCER_PROMPT = `
You are a security policy enforcer responsible for evaluating package compliance.

Policy domains:
1. **Risk Thresholds**: Critical, High, Medium, Low risk levels
2. **Capability Restrictions**: Allowed vs. prohibited capabilities
3. **Vulnerability Policies**: Acceptable vulnerability windows
4. **License Compliance**: Approved licenses
5. **Maintainer Requirements**: Trust and activity metrics
6. **Supply Chain Policies**: Typosquatting and dependency confusion rules

Decision framework:
- Apply policies consistently
- Consider context and exceptions
- Provide clear reasoning for each decision
- Flag ambiguous cases for human review
- Document override conditions

Output must include:
- policy_violations (list)
- compliance_status (COMPLIANT/NON_COMPLIANT/PENDING_REVIEW)
- required_actions (list)
- exception_conditions (if applicable)
- justification
`;
```

---

## 2. Task-Specific Prompt Templates

### Package Analysis Template

```javascript
/**
 * PACKAGE ANALYSIS PROMPT
 * Analyzes a package's security posture
 */
function createPackageAnalysisPrompt(packageData) {
    return `
Analyze the following npm package for security risks and provide a structured assessment.

Package Information:
- Name: ${packageData.name}
- Version: ${packageData.version}
- Description: ${packageData.description || 'No description provided'}
- Author: ${packageData.author || 'Unknown'}
- License: ${packageData.license || 'Unknown'}
- Total Dependencies: ${packageData.dependencyCount || 0}
- Scripts: ${JSON.stringify(packageData.scripts || {}, null, 2)}

Capabilities Detected:
${packageData.capabilities ? JSON.stringify(packageData.capabilities, null, 2) : 'No capabilities detected'}

Vulnerabilities Found:
${packageData.vulnerabilities ? JSON.stringify(packageData.vulnerabilities, null, 2) : 'No vulnerabilities detected'}

Dependencies:
${packageData.dependencies ? JSON.stringify(packageData.dependencies, null, 2) : 'No dependencies listed'}

Provide a comprehensive security analysis with the following structure:
1. Executive Summary: Brief risk overview
2. Capability Assessment: Analysis of detected capabilities
3. Vulnerability Assessment: CVE and security issue analysis
4. Supply Chain Risk: Typosquatting, dependency confusion, protestware
5. Recommendations: Actionable steps
6. Risk Score: 0-100 (0 = safe, 100 = critical risk)
7. Risk Level: CRITICAL/HIGH/MEDIUM/LOW/INFO

Return your analysis in valid JSON format following this schema:
{
  "summary": "Brief overview (max 200 chars)",
  "riskLevel": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "riskScore": 0-100,
  "capabilities": [
    {
      "type": "string",
      "severity": "string",
      "description": "string",
      "riskExplanation": "string"
    }
  ],
  "vulnerabilities": [
    {
      "id": "string",
      "severity": "string",
      "description": "string",
      "cve": "string|null",
      "fixedVersion": "string|null"
    }
  ],
  "supplyChainRisks": [
    {
      "type": "string",
      "severity": "string",
      "description": "string"
    }
  ],
  "recommendations": [
    {
      "priority": "IMMEDIATE|HIGH|MEDIUM|LOW",
      "action": "string",
      "description": "string"
    }
  ],
  "trustScore": 0-100
}
`;
}
```

### Vulnerability Triage Template

```javascript
/**
 * VULNERABILITY TRIAGE PROMPT
 * Prioritizes and triages vulnerabilities
 */
function createVulnerabilityTriagePrompt(vulnerabilities) {
    return `
You are triaging ${vulnerabilities.length} vulnerabilities found in a package.

Vulnerabilities:
${vulnerabilities.map((v, i) => `
${i + 1}. ${v.id || 'Unknown ID'}
   Title: ${v.title || 'No title'}
   Severity: ${v.severity || 'Unknown'}
   CVSS Score: ${v.cvssScore || 'N/A'}
   CVE: ${v.cve || 'None'}
   Fixed Version: ${v.fixedVersion || 'None'}
   Exploit Available: ${v.exploitAvailable ? 'Yes' : 'No'}
   Description: ${v.description || 'No description'}
`).join('\n')}

Prioritize these vulnerabilities based on:
1. CVSS Score (higher = higher priority)
2. Exploit Availability (available exploits increase priority)
3. Fix Availability (no fix increases priority)
4. Business Impact (critical packages increase priority)
5. Exploit Maturity (mature exploits increase priority)

Provide:
1. Overall priority ranking (1 = highest priority to ${vulnerabilities.length} = lowest)
2. Priority categories: IMMEDIATE, HIGH, MEDIUM, LOW
3. Urgency assessment for each vulnerability
4. Recommended remediation timeline
5. Dependencies between vulnerabilities (if any)

Return JSON with:
{
  "prioritized": [
    {
      "vulnerabilityId": "string",
      "priority": 1-10,
      "category": "IMMEDIATE|HIGH|MEDIUM|LOW",
      "urgency": "string",
      "remediationTimeline": "string",
      "dependencies": ["string"]
    }
  ],
  "summary": {
    "immediateCount": 0,
    "highCount": 0,
    "mediumCount": 0,
    "lowCount": 0,
    "estimatedHours": 0
  }
}
`;
}
```

### Remediation Planning Template

```javascript
/**
 * REMEDIATION PLANNING PROMPT
 * Creates a remediation plan for identified issues
 */
function createRemediationPrompt(packageName, issues) {
    return `
Create a remediation plan for ${packageName} based on the following issues:

${issues.map((issue, i) => `
${i + 1}. ${issue.type}: ${issue.description}
   Severity: ${issue.severity}
   Source: ${issue.source || 'Unknown'}
   Current Version: ${issue.currentVersion || 'Unknown'}
   Fixed Version: ${issue.fixedVersion || 'Unknown'}
`).join('\n')}

Provide a detailed remediation plan including:
1. Priority order for fixing issues
2. Specific steps for each remediation
3. Estimated effort (hours)
4. Dependencies between remediations
5. Testing requirements
6. Rollback plan

Consider:
- Critical issues must be fixed immediately
- High issues should be fixed within 24 hours
- Medium issues within 1 week
- Low issues in next sprint

Return JSON:
{
  "plan": [
    {
      "issueId": "string",
      "priority": 0,
      "action": "string",
      "steps": ["string"],
      "estimatedHours": 0,
      "dependencies": ["string"],
      "testing": ["string"],
      "rollbackPlan": "string"
    }
  ],
  "summary": {
    "totalIssues": 0,
    "estimatedHours": 0,
    "criticalCount": 0,
    "highCount": 0
  },
  "timeline": {
    "immediate": "string",
    "shortTerm": "string",
    "mediumTerm": "string",
    "longTerm": "string"
  }
}
`;
}
```

---

## 3. Advanced Prompt Techniques

### Few-Shot Learning

```javascript
/**
 * FEW-SHOT LEARNING EXAMPLE
 * Provides examples for consistent output formatting
 */
function createFewShotPrompt(inputData) {
    return `
You are a security analyst. Analyze the following package and provide a security assessment.

Here are examples of well-formatted security assessments:

Example 1 (Package with critical risk):
Input: express@4.18.2 - Contains filesystem access, network communication, and 2 critical CVEs
Output:
{
  "summary": "Critical risk: Multiple CVEs and dangerous capabilities detected",
  "riskLevel": "CRITICAL",
  "riskScore": 85,
  "capabilities": [
    {
      "type": "FILESYSTEM_ACCESS",
      "severity": "HIGH",
      "description": "Package reads and writes files",
      "riskExplanation": "Can access sensitive files on the system"
    }
  ],
  "vulnerabilities": [
    {
      "id": "CVE-2023-12345",
      "severity": "CRITICAL",
      "description": "Denial of Service vulnerability",
      "cve": "CVE-2023-12345",
      "fixedVersion": "4.19.0"
    }
  ],
  "recommendations": [
    {
      "priority": "IMMEDIATE",
      "action": "BLOCK",
      "description": "Block this package version immediately"
    }
  ]
}

Example 2 (Package with low risk):
Input: lodash@4.17.21 - No capabilities, no CVEs, well-maintained
Output:
{
  "summary": "Low risk: Well-maintained package with no security issues",
  "riskLevel": "LOW",
  "riskScore": 10,
  "capabilities": [],
  "vulnerabilities": [],
  "recommendations": [
    {
      "priority": "LOW",
      "action": "MONITOR",
      "description": "Monitor for future updates"
    }
  ]
}

Now analyze this package:
${JSON.stringify(inputData, null, 2)}

Provide the analysis in the same format as the examples above.
`;
}
```

### Chain-of-Thought Prompting

```javascript
/**
 * CHAIN-OF-THOUGHT PROMPTING
 * Encourages step-by-step reasoning
 */
function createChainOfThoughtPrompt(packageData) {
    return `
Analyze the security of ${packageData.name}@${packageData.version} using step-by-step reasoning.

Step 1: Package Context
- What is this package used for?
- Who maintains it?
- How popular is it?
- When was it last updated?

Step 2: Capability Analysis
- What capabilities does the package have?
- Are these capabilities necessary?
- What is the risk level of each capability?
- Are there any suspicious combinations?

Step 3: Vulnerability Analysis
- Are there any known CVEs?
- What is the severity of each vulnerability?
- Are fixes available?
- Are there any vulnerabilities with public exploits?

Step 4: Supply Chain Risk
- Is this a typosquatting attempt?
- Is there risk of dependency confusion?
- Does the package contain protestware?
- Are maintainer credentials compromised?

Step 5: Business Context
- Is this a critical dependency?
- What is the business impact?
- Are there alternatives?
- What is the cost of not fixing issues?

Step 6: Overall Assessment
- What is the overall risk level?
- What actions are required?
- What is the urgency?

Package Data:
${JSON.stringify(packageData, null, 2)}

Provide your analysis with clear reasoning for each step, then return a final JSON assessment.
`;
}
```

### Dynamic Prompt Generation

```javascript
/**
 * DYNAMIC PROMPT GENERATION
 * Adapts prompts based on package characteristics
 */
class DynamicPromptGenerator {
    constructor() {
        this.templates = {
            critical: this.getCriticalPrompt.bind(this),
            high: this.getHighPrompt.bind(this),
            medium: this.getMediumPrompt.bind(this),
            low: this.getLowPrompt.bind(this)
        };
    }

    generatePrompt(packageData, riskLevel) {
        const template = this.templates[riskLevel.toLowerCase()] || this.getDefaultPrompt;
        return template(packageData);
    }

    getCriticalPrompt(packageData) {
        return `
🚨 CRITICAL SECURITY ALERT

Package: ${packageData.name}@${packageData.version}

This package has been flagged as CRITICAL risk. Immediate action is required.

Key Issues:
${packageData.issues.map(i => `- ${i.severity}: ${i.description}`).join('\n')}

Urgent Actions Required:
1. Block this package immediately
2. Investigate all dependencies
3. Determine if an alternative package exists
4. If no alternative exists, plan for emergency mitigation

Provide a comprehensive analysis focusing on:
- Immediate risk assessment
- Mitigation strategies
- Emergency workarounds
- Communication plan for stakeholders

Analysis:
`;
    }

    getHighPrompt(packageData) {
        return `
⚠️ HIGH RISK PACKAGE DETECTED

Package: ${packageData.name}@${packageData.version}

This package requires urgent review and action.

Issues Found:
${packageData.issues.map(i => `- ${i.severity}: ${i.description}`).join('\n')}

Required Actions:
1. Review all issues within 24 hours
2. Determine upgrade path
3. Test in staging environment
4. Schedule production deployment

Provide detailed analysis with:
- Risk assessment
- Remediation strategy
- Testing requirements
- Deployment plan

Analysis:
`;
    }

    getMediumPrompt(packageData) {
        return `
ℹ️ MEDIUM RISK PACKAGE

Package: ${packageData.name}@${packageData.version}

This package requires review in the current sprint.

Issues:
${packageData.issues.map(i => `- ${i.description}`).join('\n')}

Actions:
1. Review during current sprint
2. Plan for next major version
3. Monitor for changes

Analysis:
`;
    }

    getLowPrompt(packageData) {
        return `
✅ LOW RISK PACKAGE

Package: ${packageData.name}@${packageData.version}

No immediate action required.

Notes:
${packageData.notes || 'Standard review recommended'}

Analysis:
`;
    }

    getDefaultPrompt(packageData) {
        return `
Security Analysis: ${packageData.name}@${packageData.version}

Package Data:
${JSON.stringify(packageData, null, 2)}

Provide a comprehensive security analysis.
`;
    }
}
```

---

## 4. Structured Output Validation

### JSON Schema Definition

```javascript
/**
 * JSON SCHEMA FOR SECURITY ANALYSIS
 * Defines expected output structure for validation
 */
const SECURITY_ANALYSIS_SCHEMA = {
    type: 'object',
    required: ['summary', 'riskLevel', 'riskScore', 'capabilities', 'vulnerabilities', 'recommendations'],
    properties: {
        summary: {
            type: 'string',
            maxLength: 200,
            description: 'Brief overview of the security assessment'
        },
        riskLevel: {
            type: 'string',
            enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO'],
            description: 'Overall risk level'
        },
        riskScore: {
            type: 'integer',
            minimum: 0,
            maximum: 100,
            description: 'Numerical risk score (0-100)'
        },
        capabilities: {
            type: 'array',
            items: {
                type: 'object',
                required: ['type', 'severity', 'description'],
                properties: {
                    type: {
                        type: 'string',
                        enum: ['FILESYSTEM_ACCESS', 'NETWORK_ACCESS', 'SHELL_EXECUTION', 
                               'ENVIRONMENT_ACCESS', 'DYNAMIC_CODE', 'NATIVE_BINARIES',
                               'TELEMETRY', 'CRYPTOGRAPHY']
                    },
                    severity: {
                        type: 'string',
                        enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
                    },
                    description: {
                        type: 'string',
                        maxLength: 500
                    },
                    riskExplanation: {
                        type: 'string',
                        maxLength: 500
                    }
                }
            }
        },
        vulnerabilities: {
            type: 'array',
            items: {
                type: 'object',
                required: ['severity', 'description'],
                properties: {
                    id: { type: 'string' },
                    severity: {
                        type: 'string',
                        enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
                    },
                    description: { type: 'string' },
                    cve: { type: ['string', 'null'] },
                    fixedVersion: { type: ['string', 'null'] }
                }
            }
        },
        supplyChainRisks: {
            type: 'array',
            items: {
                type: 'object',
                required: ['type', 'description'],
                properties: {
                    type: {
                        type: 'string',
                        enum: ['TYPOSQUATTING', 'DEPENDENCY_CONFUSION', 'PROTESTWARE', 
                               'MALICIOUS_SCRIPT', 'DATA_EXFILTRATION']
                    },
                    severity: {
                        type: 'string',
                        enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
                    },
                    description: { type: 'string' }
                }
            }
        },
        recommendations: {
            type: 'array',
            items: {
                type: 'object',
                required: ['action', 'description'],
                properties: {
                    priority: {
                        type: 'string',
                        enum: ['IMMEDIATE', 'HIGH', 'MEDIUM', 'LOW']
                    },
                    action: { type: 'string' },
                    description: { type: 'string' }
                }
            }
        },
        trustScore: {
            type: 'integer',
            minimum: 0,
            maximum: 100
        },
        context: {
            type: 'object',
            properties: {
                packageMaintainer: { type: 'string' },
                lastUpdate: { type: 'string' },
                dependencyCount: { type: 'integer' }
            }
        }
    },
    additionalProperties: false
};

// Validator implementation
const Ajv = require('ajv');
const ajv = new Ajv({ strict: true });
const validate = ajv.compile(SECURITY_ANALYSIS_SCHEMA);

function validateSecurityOutput(data) {
    const valid = validate(data);
    if (!valid) {
        throw new Error(`Validation failed: ${JSON.stringify(validate.errors, null, 2)}`);
    }
    return data;
}
```

### Response Parsing and Cleaning

```javascript
/**
 * RESPONSE PARSER
 * Extracts and validates JSON from LLM responses
 */
class SecurityResponseParser {
    constructor() {
        this.validator = validate;
    }

    /**
     * Parses LLM response into structured JSON
     */
    parseResponse(response) {
        const content = response.content || response.message || '';
        
        // Try to extract JSON from the response
        let jsonData = this.extractJSON(content);
        
        // If extraction failed, try to fix common issues
        if (!jsonData) {
            jsonData = this.repairJSON(content);
        }
        
        // Validate against schema
        if (jsonData) {
            try {
                return this.validator(jsonData);
            } catch (error) {
                console.warn('Validation failed, trying to repair...');
                jsonData = this.repairData(jsonData);
                return this.validator(jsonData);
            }
        }
        
        // If all else fails, return a default response
        return this.getDefaultResponse();
    }

    /**
     * Extracts JSON from text
     */
    extractJSON(text) {
        // Try to find JSON block
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            try {
                return JSON.parse(jsonMatch[0]);
            } catch (e) {
                // Invalid JSON
                return null;
            }
        }
        
        // Try to find JSON in code blocks
        const codeMatch = text.match(/```(?:json)?\s*([\s\S]*?)```/);
        if (codeMatch) {
            try {
                return JSON.parse(codeMatch[1]);
            } catch (e) {
                return null;
            }
        }
        
        return null;
    }

    /**
     * Attempts to repair malformed JSON
     */
    repairJSON(text) {
        // Common repair strategies
        let repaired = text;
        
        // Fix missing quotes
        repaired = repaired.replace(/(['"])?([a-zA-Z_][a-zA-Z0-9_]*)(['"])?\s*:/g, '"$2":');
        
        // Fix trailing commas
        repaired = repaired.replace(/,\s*}/g, '}');
        repaired = repaired.replace(/,\s*\]/g, ']');
        
        // Fix single quotes to double quotes
        repaired = repaired.replace(/'/g, '"');
        
        // Fix undefined values
        repaired = repaired.replace(/undefined/g, 'null');
        
        try {
            return JSON.parse(repaired);
        } catch (e) {
            return null;
        }
    }

    /**
     * Repairs data to match schema
     */
    repairData(data) {
        const defaultData = {
            summary: 'Security analysis completed with issues',
            riskLevel: 'MEDIUM',
            riskScore: 50,
            capabilities: [],
            vulnerabilities: [],
            recommendations: []
        };

        // Ensure all required fields exist
        const repaired = { ...defaultData, ...data };
        
        // Validate and fix arrays
        if (!Array.isArray(repaired.capabilities)) repaired.capabilities = [];
        if (!Array.isArray(repaired.vulnerabilities)) repaired.vulnerabilities = [];
        if (!Array.isArray(repaired.recommendations)) repaired.recommendations = [];
        
        // Fix risk level
        const validLevels = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO'];
        if (!validLevels.includes(repaired.riskLevel)) {
            repaired.riskLevel = 'MEDIUM';
        }
        
        // Fix risk score
        if (typeof repaired.riskScore !== 'number' || 
            repaired.riskScore < 0 || repaired.riskScore > 100) {
            repaired.riskScore = 50;
        }
        
        return repaired;
    }

    /**
     * Returns a safe default response
     */
    getDefaultResponse() {
        return {
            summary: 'Analysis unavailable - default response',
            riskLevel: 'MEDIUM',
            riskScore: 50,
            capabilities: [],
            vulnerabilities: [],
            supplyChainRisks: [],
            recommendations: [
                {
                    priority: 'HIGH',
                    action: 'REVIEW_MANUALLY',
                    description: 'AI analysis failed. Manual review required.'
                }
            ],
            trustScore: 0
        };
    }
}
```

---

## 5. Practical Examples

### Example 1: Package Security Analysis

```javascript
/**
 * COMPLETE EXAMPLE: Package Security Analysis
 */
async function analyzePackageWithAI(packageData) {
    // 1. Build the prompt
    const prompt = createPackageAnalysisPrompt(packageData);
    
    // 2. Add system context
    const messages = [
        { role: 'system', content: SECURITY_EXPERT_PROMPT },
        { role: 'user', content: prompt }
    ];
    
    // 3. Call LLM
    const response = await openai.chat.completions.create({
        model: 'gpt-4-turbo-preview',
        messages,
        temperature: 0.3,
        max_tokens: 2000
    });
    
    // 4. Parse and validate response
    const parser = new SecurityResponseParser();
    const result = parser.parseResponse(response.choices[0].message);
    
    // 5. Store analysis
    const analysis = {
        timestamp: new Date().toISOString(),
        packageName: packageData.name,
        version: packageData.version,
        analysis: result
    };
    
    return analysis;
}

// Example usage
const packageData = {
    name: 'example-package',
    version: '1.0.0',
    description: 'A sample package for testing',
    author: 'Test Author',
    license: 'MIT',
    dependencyCount: 15,
    scripts: {
        'postinstall': 'node -e "console.log(\'Installed\')"'
    },
    capabilities: [
        {
            type: 'FILESYSTEM_ACCESS',
            severity: 'HIGH',
            description: 'Reads configuration files'
        }
    ],
    vulnerabilities: [
        {
            id: 'CVE-2023-12345',
            severity: 'CRITICAL',
            description: 'Remote code execution vulnerability',
            cve: 'CVE-2023-12345',
            fixedVersion: '1.1.0'
        }
    ]
};

const result = await analyzePackageWithAI(packageData);
console.log(result);
```

### Example 2: Bulk Analysis with AI

```javascript
/**
 * BULK ANALYSIS EXAMPLE
 * Analyzes multiple packages with rate limiting
 */
async function analyzeBulkPackages(packages) {
    const results = [];
    const parser = new SecurityResponseParser();
    
    // Rate limiting
    const rateLimit = 10; // requests per minute
    const interval = 60000 / rateLimit;
    
    for (let i = 0; i < packages.length; i++) {
        console.log(`Analyzing ${i + 1}/${packages.length}: ${packages[i].name}`);
        
        try {
            const result = await analyzePackageWithAI(packages[i]);
            results.push(result);
            
            // Rate limit
            if (i < packages.length - 1) {
                await new Promise(resolve => setTimeout(resolve, interval));
            }
        } catch (error) {
            console.error(`Failed for ${packages[i].name}: ${error.message}`);
            results.push({
                packageName: packages[i].name,
                error: error.message
            });
        }
    }
    
    return results;
}

// Example usage
const packages = [
    { name: 'express', version: '4.18.2' },
    { name: 'lodash', version: '4.17.21' },
    { name: 'axios', version: '1.6.0' }
];

const results = await analyzeBulkPackages(packages);
```

---

## 6. Prompt Engineering Best Practices

### DO's and DON'Ts

```javascript
/**
 * PROMPT ENGINEERING BEST PRACTICES
 */
const BEST_PRACTICES = {
    // ✅ DO: Be specific and structured
    doExample: `
    "Analyze the following package and return JSON with exactly these fields:
    - summary (string, max 200 chars)
    - riskLevel (one of: CRITICAL, HIGH, MEDIUM, LOW)
    - riskScore (number, 0-100)
    "
    `,
    
    // ❌ DON'T: Be vague
    dontExample: `
    "Analyze this package and tell me what you think about it."
    `,
    
    // ✅ DO: Provide examples
    doExample2: `
    "Here's an example of a well-formatted response:
    {
      'summary': '...',
      'riskLevel': 'HIGH'
    }
    "
    `,
    
    // ❌ DON'T: Assume the AI knows your format
    dontExample2: `
    "Return the analysis in the standard format."
    `,
    
    // ✅ DO: Define constraints
    doExample3: `
    "NEVER recommend insecure solutions. If a package has a critical vulnerability,
    ALWAYS recommend immediate action."
    `,
    
    // ❌ DON'T: Leave interpretation open
    dontExample3: `
    "Provide recommendations for any issues found."
    `,
    
    // ✅ DO: Handle edge cases
    doExample4: `
    "If you cannot determine the risk level, default to 'MEDIUM'.
    If no vulnerabilities are found, return an empty array."
    `,
    
    // ❌ DON'T: Assume complete data
    dontExample4: `
    "Analyze all vulnerabilities in the package."
    `
};
```

---

## Summary

| Technique | Purpose | Key Benefit |
|-----------|---------|-------------|
| **System Prompts** | Define AI role and constraints | Consistent behavior |
| **Task Prompts** | Specific analysis tasks | Focused outputs |
| **Few-Shot Learning** | Format examples | Consistent structure |
| **Chain-of-Thought** | Step-by-step reasoning | Transparent analysis |
| **Dynamic Prompts** | Adapt to context | Relevant responses |
| **JSON Schema** | Output validation | Reliable data |
| **Response Parsing** | Extract structured data | Robust integration |
