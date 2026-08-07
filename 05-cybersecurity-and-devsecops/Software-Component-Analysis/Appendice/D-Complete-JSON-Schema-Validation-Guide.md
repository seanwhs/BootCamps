# Reference D: Complete JSON Schema Validation Guide

Welcome to the fourth reference section. This comprehensive guide covers everything you need to know about JSON Schema validation for security data structures, including schema design, validation techniques, error handling, and practical examples specific to security applications.

---

## Understanding JSON Schema

### What is JSON Schema?

JSON Schema is a powerful tool for validating the structure and content of JSON data. It acts as a contract between systems, ensuring that data exchanged between components meets expected formats and constraints.

```
┌─────────────────────────────────────────────────────────────┐
│                    JSON SCHEMA WORKFLOW                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    SCHEMA                            │  │
│  │  Defines expected structure, types, constraints     │  │
│  │  {                                                  │  │
│  │    "type": "object",                               │  │
│  │    "properties": { ... },                          │  │
│  │    "required": ["name", "version"]                 │  │
│  │  }                                                 │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│                         ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    DATA                             │  │
│  │  The actual JSON to validate                        │  │
│  │  {                                                  │  │
│  │    "name": "express",                               │  │
│  │    "version": "4.18.2"                             │  │
│  │  }                                                 │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│                         ▼                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                 VALIDATOR                           │  │
│  │  Checks data against schema                         │  │
│  │  ✅ Valid / ❌ Invalid                             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Why Use JSON Schema for Security?

1. **Data Integrity** - Ensures security data is complete and correctly formatted
2. **Type Safety** - Prevents type mismatches in critical security decisions
3. **Documentation** - Serves as living documentation for data structures
4. **Validation** - Catches errors before they reach production
5. **Security** - Prevents injection attacks by validating data shape
6. **Compatibility** - Ensures consistent data between different system components

---

## 1. Core Schema Concepts

### Basic Schema Structure

```javascript
/**
 * BASIC JSON SCHEMA
 * The fundamental structure of a JSON Schema
 */
const basicSchema = {
    // Schema metadata
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "https://security-scanner.example.com/schemas/package-analysis.json",
    "title": "Package Security Analysis",
    "description": "Schema for package security analysis results",
    
    // Root type
    "type": "object",
    
    // Properties definition
    "properties": {
        "name": {
            "type": "string",
            "description": "Package name",
            "minLength": 1,
            "maxLength": 100,
            "pattern": "^[a-zA-Z0-9@/-]+$"
        },
        "version": {
            "type": "string",
            "description": "Package version",
            "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-zA-Z0-9.]+)?$"
        }
    },
    
    // Required fields
    "required": ["name", "version"],
    
    // Additional properties
    "additionalProperties": false
};
```

### Common Schema Keywords

```javascript
/**
 * COMMON SCHEMA KEYWORDS
 * Essential keywords for schema definition
 */
const schemaKeywords = {
    // Type validation
    type: ['string', 'number', 'integer', 'boolean', 'array', 'object', 'null'],
    
    // String constraints
    string: {
        minLength: "Minimum string length",
        maxLength: "Maximum string length",
        pattern: "Regex pattern",
        format: "Predefined formats: date, email, uri, etc.",
        enum: "Allowed values"
    },
    
    // Number constraints
    number: {
        minimum: "Minimum value (inclusive)",
        maximum: "Maximum value (inclusive)",
        exclusiveMinimum: "Minimum value (exclusive)",
        exclusiveMaximum: "Maximum value (exclusive)",
        multipleOf: "Must be multiple of value"
    },
    
    // Array constraints
    array: {
        items: "Schema for array items",
        minItems: "Minimum number of items",
        maxItems: "Maximum number of items",
        uniqueItems: "All items must be unique",
        contains: "Array must contain at least one matching item"
    },
    
    // Object constraints
    object: {
        properties: "Property definitions",
        required: "Required properties",
        additionalProperties: "Allow additional properties",
        patternProperties: "Properties matching pattern",
        minProperties: "Minimum number of properties",
        maxProperties: "Maximum number of properties"
    },
    
    // Logical constraints
    logical: {
        allOf: "Must match all schemas",
        anyOf: "Must match at least one schema",
        oneOf: "Must match exactly one schema",
        not: "Must not match the schema",
        if: "Conditional validation",
        then: "Schema if condition is true",
        else: "Schema if condition is false"
    }
};
```

---

## 2. Security-Specific Schema Templates

### Package Security Analysis Schema

```javascript
/**
 * COMPLETE SECURITY ANALYSIS SCHEMA
 * Validates package security analysis output
 */
const securityAnalysisSchema = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "https://security-scanner.example.com/schemas/security-analysis.json",
    "title": "Security Analysis Schema",
    "description": "Schema for validating security analysis results",
    
    "type": "object",
    "required": [
        "packageName",
        "version",
        "riskLevel",
        "riskScore",
        "timestamp"
    ],
    
    "properties": {
        // Package identification
        "packageName": {
            "type": "string",
            "description": "Name of the analyzed package",
            "minLength": 1,
            "maxLength": 100,
            "pattern": "^[a-zA-Z0-9@/_-]+$"
        },
        "version": {
            "type": "string",
            "description": "Package version",
            "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-zA-Z0-9.]+)?$"
        },
        
        // Risk assessment
        "riskLevel": {
            "type": "string",
            "description": "Overall risk level",
            "enum": ["CRITICAL", "HIGH", "MEDIUM", "LOW", "INFO"]
        },
        "riskScore": {
            "type": "integer",
            "description": "Numerical risk score 0-100",
            "minimum": 0,
            "maximum": 100
        },
        
        // Analysis results
        "capabilities": {
            "type": "array",
            "description": "Detected package capabilities",
            "items": {
                "type": "object",
                "required": ["type", "severity", "description"],
                "properties": {
                    "type": {
                        "type": "string",
                        "enum": [
                            "FILESYSTEM_ACCESS",
                            "NETWORK_ACCESS",
                            "SHELL_EXECUTION",
                            "ENVIRONMENT_ACCESS",
                            "DYNAMIC_CODE",
                            "NATIVE_BINARIES",
                            "TELEMETRY",
                            "CRYPTOGRAPHY"
                        ]
                    },
                    "severity": {
                        "type": "string",
                        "enum": ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
                    },
                    "description": {
                        "type": "string",
                        "maxLength": 500
                    },
                    "riskExplanation": {
                        "type": "string",
                        "maxLength": 500
                    }
                }
            }
        },
        
        "vulnerabilities": {
            "type": "array",
            "description": "Detected vulnerabilities",
            "items": {
                "type": "object",
                "required": ["severity", "description"],
                "properties": {
                    "id": {
                        "type": "string",
                        "pattern": "^[A-Z0-9-]+$"
                    },
                    "severity": {
                        "type": "string",
                        "enum": ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
                    },
                    "description": {
                        "type": "string",
                        "maxLength": 500
                    },
                    "cve": {
                        "type": ["string", "null"],
                        "pattern": "^CVE-\\d{4}-\\d{4,}$|^$"
                    },
                    "fixedVersion": {
                        "type": ["string", "null"],
                        "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-zA-Z0-9.]+)?$|^$"
                    }
                }
            }
        },
        
        "recommendations": {
            "type": "array",
            "description": "Security recommendations",
            "items": {
                "type": "object",
                "required": ["action", "description"],
                "properties": {
                    "priority": {
                        "type": "string",
                        "enum": ["IMMEDIATE", "HIGH", "MEDIUM", "LOW"]
                    },
                    "action": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 50
                    },
                    "description": {
                        "type": "string",
                        "maxLength": 500
                    },
                    "packages": {
                        "type": "array",
                        "items": {
                            "type": "string"
                        }
                    }
                }
            }
        },
        
        // Metadata
        "timestamp": {
            "type": "string",
            "format": "date-time"
        },
        "duration": {
            "type": "number",
            "minimum": 0
        },
        "scannerVersion": {
            "type": "string",
            "pattern": "^\\d+\\.\\d+\\.\\d+$"
        }
    },
    
    // Additional validation
    "allOf": [
        {
            "if": {
                "properties": { "riskLevel": { "const": "CRITICAL" } }
            },
            "then": {
                "required": ["recommendations"],
                "properties": {
                    "recommendations": {
                        "contains": {
                            "properties": {
                                "priority": { "const": "IMMEDIATE" }
                            }
                        }
                    }
                }
            }
        }
    ],
    
    "additionalProperties": false
};
```

### Dependency Graph Schema

```javascript
/**
 * DEPENDENCY GRAPH SCHEMA
 * Validates dependency tree structures
 */
const dependencyGraphSchema = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "https://security-scanner.example.com/schemas/dependency-graph.json",
    "title": "Dependency Graph Schema",
    "description": "Schema for dependency graph structures",
    
    "type": "object",
    "required": ["root", "nodes", "edges"],
    
    "properties": {
        "root": {
            "type": "object",
            "required": ["id", "name", "version"],
            "properties": {
                "id": {
                    "type": "string",
                    "pattern": "^[a-zA-Z0-9@/_-]+@\\d+\\.\\d+\\.\\d+$"
                },
                "name": {
                    "type": "string",
                    "minLength": 1
                },
                "version": {
                    "type": "string",
                    "pattern": "^\\d+\\.\\d+\\.\\d+$"
                }
            }
        },
        
        "nodes": {
            "type": "array",
            "minItems": 1,
            "items": {
                "type": "object",
                "required": ["id", "name", "version"],
                "properties": {
                    "id": {
                        "type": "string",
                        "pattern": "^[a-zA-Z0-9@/_-]+@\\d+\\.\\d+\\.\\d+$"
                    },
                    "name": {
                        "type": "string",
                        "minLength": 1
                    },
                    "version": {
                        "type": "string",
                        "pattern": "^\\d+\\.\\d+\\.\\d+$"
                    },
                    "riskLevel": {
                        "type": "string",
                        "enum": ["CRITICAL", "HIGH", "MEDIUM", "LOW", "UNKNOWN"]
                    },
                    "isVulnerable": {
                        "type": "boolean"
                    }
                }
            }
        },
        
        "edges": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["source", "target", "type"],
                "properties": {
                    "source": {
                        "type": "string",
                        "pattern": "^[a-zA-Z0-9@/_-]+@\\d+\\.\\d+\\.\\d+$"
                    },
                    "target": {
                        "type": "string",
                        "pattern": "^[a-zA-Z0-9@/_-]+@\\d+\\.\\d+\\.\\d+$"
                    },
                    "type": {
                        "type": "string",
                        "enum": ["direct", "transitive", "dev", "peer"]
                    }
                }
            }
        },
        
        "metadata": {
            "type": "object",
            "properties": {
                "totalNodes": {
                    "type": "integer",
                    "minimum": 1
                },
                "totalEdges": {
                    "type": "integer",
                    "minimum": 0
                },
                "vulnerableNodes": {
                    "type": "integer",
                    "minimum": 0
                },
                "timestamp": {
                    "type": "string",
                    "format": "date-time"
                }
            }
        }
    },
    
    "additionalProperties": false
};
```

### Policy Result Schema

```javascript
/**
 * POLICY RESULT SCHEMA
 * Validates policy evaluation results
 */
const policyResultSchema = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "https://security-scanner.example.com/schemas/policy-result.json",
    "title": "Policy Result Schema",
    "description": "Schema for policy evaluation results",
    
    "type": "object",
    "required": ["packageName", "version", "decision", "timestamp"],
    
    "properties": {
        "packageName": {
            "type": "string",
            "minLength": 1
        },
        "version": {
            "type": "string",
            "pattern": "^\\d+\\.\\d+\\.\\d+(-[a-zA-Z0-9.]+)?$"
        },
        
        "decision": {
            "type": "object",
            "required": ["action", "isApproved", "isBlocked"],
            "properties": {
                "action": {
                    "type": "string",
                    "enum": ["APPROVE", "BLOCK", "REVIEW", "MANUAL_REVIEW"]
                },
                "isApproved": {
                    "type": "boolean"
                },
                "isBlocked": {
                    "type": "boolean"
                },
                "requiresReview": {
                    "type": "boolean"
                },
                "reason": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    }
                }
            }
        },
        
        "policies": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["name", "result"],
                "properties": {
                    "name": {
                        "type": "string",
                        "minLength": 1
                    },
                    "result": {
                        "type": "string",
                        "enum": ["PASS", "FAIL", "WARN", "NA"]
                    },
                    "description": {
                        "type": "string"
                    },
                    "details": {
                        "type": "string"
                    }
                }
            }
        },
        
        "overrides": {
            "type": "array",
            "items": {
                "type": "object",
                "required": ["reason", "reviewer", "timestamp"],
                "properties": {
                    "reason": {
                        "type": "string",
                        "minLength": 1
                    },
                    "reviewer": {
                        "type": "string",
                        "minLength": 1
                    },
                    "timestamp": {
                        "type": "string",
                        "format": "date-time"
                    },
                    "expires": {
                        "type": "string",
                        "format": "date-time"
                    }
                }
            }
        },
        
        "timestamp": {
            "type": "string",
            "format": "date-time"
        },
        "evaluationTime": {
            "type": "number",
            "minimum": 0
        }
    },
    
    "additionalProperties": false
};
```

---

## 3. Validation Implementation

### Complete Validator Class

```javascript
/**
 * COMPLETE JSON SCHEMA VALIDATOR
 * Full-featured validator for security data
 */
class SecuritySchemaValidator {
    constructor(options = {}) {
        const Ajv = require('ajv');
        
        this.options = {
            strict: options.strict !== false,
            verbose: options.verbose || false,
            allErrors: options.allErrors !== false,
            useDefaults: options.useDefaults || false,
            ...options
        };
        
        // Initialize Ajv with options
        this.ajv = new Ajv({
            strict: this.options.strict,
            verbose: this.options.verbose,
            allErrors: this.options.allErrors,
            useDefaults: this.options.useDefaults
        });
        
        // Add custom formats
        this.addCustomFormats();
        
        // Schema cache
        this.schemas = new Map();
        this.compiled = new Map();
        
        // Statistics
        this.stats = {
            validations: 0,
            passed: 0,
            failed: 0,
            bySchema: {}
        };
    }
    
    /**
     * Adds custom validation formats
     */
    addCustomFormats() {
        // Package name format
        this.ajv.addFormat('package-name', {
            type: 'string',
            validate: (value) => /^[a-zA-Z0-9@/_-]+$/.test(value)
        });
        
        // Package version format
        this.ajv.addFormat('package-version', {
            type: 'string',
            validate: (value) => /^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?$/.test(value)
        });
        
        // CVE format
        this.ajv.addFormat('cve', {
            type: 'string',
            validate: (value) => /^CVE-\d{4}-\d{4,}$/.test(value)
        });
        
        // Risk level format
        this.ajv.addFormat('risk-level', {
            type: 'string',
            validate: (value) => ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'INFO'].includes(value)
        });
        
        // Security score format
        this.ajv.addFormat('security-score', {
            type: 'integer',
            validate: (value) => value >= 0 && value <= 100
        });
    }
    
    /**
     * Registers a schema for validation
     */
    registerSchema(name, schema) {
        // Add custom validation keywords
        this.addCustomKeywords(schema);
        
        this.schemas.set(name, schema);
        
        // Compile the schema
        try {
            const compiled = this.ajv.compile(schema);
            this.compiled.set(name, compiled);
            return true;
        } catch (error) {
            console.error(`Failed to compile schema ${name}: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Adds custom validation keywords
     */
    addCustomKeywords(schema) {
        // Add keyword for ensuring at least one of a set of properties
        this.ajv.addKeyword({
            keyword: 'atLeastOne',
            validate: function(schema, data) {
                const keys = Object.keys(data);
                return schema.some(prop => keys.includes(prop));
            },
            errors: false
        });
        
        // Add keyword for conditional required fields
        this.ajv.addKeyword({
            keyword: 'requiredIf',
            validate: function(schema, data) {
                const [condition, required] = schema;
                if (data[condition]) {
                    return required.every(field => data[field] !== undefined);
                }
                return true;
            },
            errors: false
        });
    }
    
    /**
     * Validates data against a schema
     */
    validate(schemaName, data) {
        this.stats.validations++;
        
        // Get compiled schema
        const validate = this.compiled.get(schemaName);
        if (!validate) {
            throw new Error(`Schema "${schemaName}" not registered`);
        }
        
        // Validate
        const isValid = validate(data);
        
        // Track statistics
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
            errors: isValid ? [] : validate.errors,
            data: data
        };
    }
    
    /**
     * Validates and throws if invalid
     */
    validateOrThrow(schemaName, data) {
        const result = this.validate(schemaName, data);
        if (!result.isValid) {
            const errorMessages = result.errors.map(e => 
                `${e.instancePath} ${e.message}`
            ).join('\n');
            throw new Error(`Schema validation failed:\n${errorMessages}`);
        }
        return true;
    }
    
    /**
     * Validates with detailed error report
     */
    validateWithReport(schemaName, data) {
        const result = this.validate(schemaName, data);
        
        if (!result.isValid) {
            return {
                isValid: false,
                errors: result.errors.map(e => ({
                    path: e.instancePath || '/',
                    message: e.message || 'Validation error',
                    params: e.params || {},
                    schemaPath: e.schemaPath || ''
                })),
                report: this.generateErrorReport(result.errors)
            };
        }
        
        return {
            isValid: true,
            errors: [],
            report: '✅ Validation passed'
        };
    }
    
    /**
     * Generates a human-readable error report
     */
    generateErrorReport(errors) {
        const lines = ['❌ Validation Errors:'];
        
        for (const error of errors) {
            const path = error.instancePath || '/';
            const message = error.message || 'Invalid data';
            lines.push(`  ${path}: ${message}`);
            
            if (error.params) {
                const details = Object.entries(error.params)
                    .map(([key, value]) => `${key}=${value}`)
                    .join(', ');
                lines.push(`    (${details})`);
            }
        }
        
        return lines.join('\n');
    }
    
    /**
     * Gets validation statistics
     */
    getStats() {
        const total = this.stats.validations;
        const passed = this.stats.passed;
        const failed = this.stats.failed;
        
        return {
            totalValidations: total,
            passed,
            failed,
            successRate: total > 0 ? (passed / total) * 100 : 0,
            bySchema: this.stats.bySchema
        };
    }
    
    /**
     * Preprocesses data before validation
     */
    preprocessData(data) {
        // Handle common data issues
        const processed = { ...data };
        
        // Normalize strings
        for (const [key, value] of Object.entries(processed)) {
            if (typeof value === 'string') {
                // Trim whitespace
                processed[key] = value.trim();
                // Normalize empty strings to null
                if (processed[key] === '') {
                    processed[key] = null;
                }
            }
        }
        
        return processed;
    }
    
    /**
     * Adds default values to data
     */
    applyDefaults(schemaName, data) {
        const schema = this.schemas.get(schemaName);
        if (!schema) return data;
        
        const defaults = {};
        this.extractDefaults(schema, defaults, '');
        return { ...defaults, ...data };
    }
    
    /**
     * Extracts default values from schema
     */
    extractDefaults(schema, defaults, path) {
        if (schema.properties) {
            for (const [key, prop] of Object.entries(schema.properties)) {
                const fullPath = path ? `${path}.${key}` : key;
                if (prop.default !== undefined) {
                    defaults[key] = prop.default;
                }
                if (prop.properties) {
                    this.extractDefaults(prop, defaults, fullPath);
                }
            }
        }
    }
}
```

### Usage Examples

```javascript
/**
 * VALIDATOR USAGE EXAMPLES
 */

// 1. Initialize the validator
const validator = new SecuritySchemaValidator({
    strict: true,
    verbose: true,
    allErrors: true
});

// 2. Register schemas
validator.registerSchema('security-analysis', securityAnalysisSchema);
validator.registerSchema('dependency-graph', dependencyGraphSchema);
validator.registerSchema('policy-result', policyResultSchema);

// 3. Validate security analysis
const analysisData = {
    packageName: 'express',
    version: '4.18.2',
    riskLevel: 'HIGH',
    riskScore: 65,
    capabilities: [
        {
            type: 'FILESYSTEM_ACCESS',
            severity: 'HIGH',
            description: 'Reads configuration files'
        }
    ],
    vulnerabilities: [
        {
            severity: 'CRITICAL',
            description: 'Remote code execution',
            cve: 'CVE-2023-12345'
        }
    ],
    recommendations: [
        {
            priority: 'IMMEDIATE',
            action: 'UPDATE',
            description: 'Update to version 4.19.0'
        }
    ],
    timestamp: new Date().toISOString()
};

const result = validator.validate('security-analysis', analysisData);
console.log(`Valid: ${result.isValid}`);
if (!result.isValid) {
    console.log('Errors:', result.errors);
}

// 4. Validate with detailed report
const report = validator.validateWithReport('security-analysis', analysisData);
console.log(report.report);

// 5. Get statistics
const stats = validator.getStats();
console.log(`Success rate: ${stats.successRate.toFixed(1)}%`);
```

---

## 4. Advanced Schema Patterns

### Conditional Validation

```javascript
/**
 * CONDITIONAL VALIDATION
 * Validates data based on conditions
 */
const conditionalSchema = {
    type: 'object',
    properties: {
        riskLevel: {
            type: 'string',
            enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
        },
        action: {
            type: 'string',
            enum: ['BLOCK', 'REVIEW', 'APPROVE']
        },
        justification: {
            type: 'string'
        },
        reviewer: {
            type: 'string'
        }
    },
    required: ['riskLevel', 'action'],
    allOf: [
        // If risk level is CRITICAL, action must be BLOCK and justification required
        {
            if: {
                properties: { riskLevel: { const: 'CRITICAL' } }
            },
            then: {
                properties: {
                    action: { const: 'BLOCK' },
                    justification: { type: 'string', minLength: 1 }
                },
                required: ['justification']
            }
        },
        // If action is BLOCK, justification required
        {
            if: {
                properties: { action: { const: 'BLOCK' } }
            },
            then: {
                required: ['justification']
            }
        },
        // If action is APPROVE, reviewer required
        {
            if: {
                properties: { action: { const: 'APPROVE' } }
            },
            then: {
                required: ['reviewer']
            }
        }
    ]
};
```

### Recursive Schema

```javascript
/**
 * RECURSIVE SCHEMA
 * Validates nested dependency trees
 */
const recursiveSchema = {
    type: 'object',
    properties: {
        id: { type: 'string', pattern: '^[a-zA-Z0-9@/_-]+$' },
        name: { type: 'string', minLength: 1 },
        version: { type: 'string', pattern: '^\\d+\\.\\d+\\.\\d+$' },
        children: {
            type: 'array',
            items: { $ref: '#' } // Reference to itself for recursion
        }
    },
    required: ['id', 'name', 'version']
};

// Example data
const recursiveData = {
    id: 'root-1.0.0',
    name: 'root',
    version: '1.0.0',
    children: [
        {
            id: 'dep1-2.0.0',
            name: 'dep1',
            version: '2.0.0',
            children: [
                {
                    id: 'dep2-1.0.0',
                    name: 'dep2',
                    version: '1.0.0'
                }
            ]
        }
    ]
};
```

### Pattern Properties

```javascript
/**
 * PATTERN PROPERTIES
 * Validates properties that match a pattern
 */
const patternSchema = {
    type: 'object',
    properties: {
        packageName: { type: 'string' },
        version: { type: 'string' }
    },
    patternProperties: {
        // Any property starting with 'capability_' must follow this schema
        '^capability_': {
            type: 'object',
            required: ['type', 'severity'],
            properties: {
                type: {
                    type: 'string',
                    enum: ['filesystem', 'network', 'shell', 'environment']
                },
                severity: {
                    type: 'string',
                    enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
                },
                description: {
                    type: 'string'
                }
            }
        },
        // Any property starting with 'vuln_' must follow this schema
        '^vuln_': {
            type: 'object',
            required: ['id', 'severity'],
            properties: {
                id: {
                    type: 'string',
                    pattern: '^CVE-\\d{4}-\\d{4,}$'
                },
                severity: {
                    type: 'string',
                    enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW']
                },
                fixedVersion: {
                    type: 'string'
                }
            }
        }
    },
    additionalProperties: false
};
```

---

## 5. Error Handling and Reporting

### Comprehensive Error Handler

```javascript
/**
 * COMPREHENSIVE ERROR HANDLER
 * Handles validation errors with detailed reporting
 */
class ValidationErrorHandler {
    constructor(options = {}) {
        this.options = {
            includeDetails: options.includeDetails !== false,
            includeSuggestions: options.includeSuggestions !== false,
            maxErrors: options.maxErrors || 10,
            ...options
        };
    }

    /**
     * Formats validation errors for humans
     */
    formatErrors(errors) {
        const formatted = [];
        const limit = this.options.maxErrors;
        
        for (let i = 0; i < Math.min(errors.length, limit); i++) {
            const error = errors[i];
            const path = error.instancePath || '/';
            const message = error.message || 'Validation error';
            
            formatted.push({
                path,
                message,
                details: this.getErrorDetails(error),
                suggestion: this.getSuggestion(error)
            });
        }
        
        if (errors.length > limit) {
            formatted.push({
                path: '/...',
                message: `And ${errors.length - limit} more errors`,
                details: 'Truncated'
            });
        }
        
        return formatted;
    }

    /**
     * Gets error details
     */
    getErrorDetails(error) {
        const details = [];
        
        if (error.params) {
            if (error.params.allowedValues) {
                details.push(`Allowed: ${error.params.allowedValues.join(', ')}`);
            }
            if (error.params.required) {
                details.push(`Required: ${error.params.required.join(', ')}`);
            }
            if (error.params.minimum !== undefined) {
                details.push(`Minimum: ${error.params.minimum}`);
            }
            if (error.params.maximum !== undefined) {
                details.push(`Maximum: ${error.params.maximum}`);
            }
            if (error.params.minLength !== undefined) {
                details.push(`Min length: ${error.params.minLength}`);
            }
            if (error.params.maxLength !== undefined) {
                details.push(`Max length: ${error.params.maxLength}`);
            }
        }
        
        return details.join('; ');
    }

    /**
     * Gets a suggestion for fixing the error
     */
    getSuggestion(error) {
        const suggestions = {
            'additionalProperties': 'Remove the additional property or update the schema',
            'enum': `Use one of the allowed values: ${error.params.allowedValues?.join(', ')}`,
            'minLength': `Provide a value with at least ${error.params.minLength} characters`,
            'maxLength': `Provide a value with no more than ${error.params.maxLength} characters`,
            'required': `Add the required field: ${error.params.required?.join(', ')}`,
            'type': `Provide the correct data type (${error.params.type})`,
            'minimum': `Provide a value of at least ${error.params.minimum}`,
            'maximum': `Provide a value of at most ${error.params.maximum}`,
            'pattern': `Provide a value matching the required pattern`
        };
        
        return suggestions[error.keyword] || 'Review the data structure and try again';
    }

    /**
     * Generates a complete error report
     */
    generateErrorReport(errors, data) {
        const report = {
            valid: false,
            timestamp: new Date().toISOString(),
            errorCount: errors.length,
            errors: this.formatErrors(errors),
            data: this.options.includeDetails ? data : undefined,
            summary: this.generateSummary(errors)
        };
        
        return report;
    }

    /**
     * Generates a summary of errors
     */
    generateSummary(errors) {
        const summary = {
            critical: 0,
            required: 0,
            type: 0,
            value: 0,
            other: 0
        };
        
        for (const error of errors) {
            switch (error.keyword) {
                case 'required':
                    summary.required++;
                    break;
                case 'type':
                    summary.type++;
                    break;
                case 'enum':
                case 'const':
                case 'pattern':
                case 'minimum':
                case 'maximum':
                    summary.value++;
                    break;
                case 'error':
                    summary.critical++;
                    break;
                default:
                    summary.other++;
            }
        }
        
        return summary;
    }

    /**
     * Creates an auto-fix for common issues
     */
    createAutoFix(data, errors) {
        const fixed = { ...data };
        
        for (const error of errors) {
            const path = error.instancePath.replace(/^\//, '');
            
            // Handle missing required fields
            if (error.keyword === 'required' && error.params.required) {
                for (const field of error.params.required) {
                    // Add default value based on schema
                    fixed[field] = this.getDefaultValue(field);
                }
            }
            
            // Handle type mismatches
            if (error.keyword === 'type') {
                const pathParts = path.split('/');
                let target = fixed;
                for (let i = 0; i < pathParts.length - 1; i++) {
                    target = target[pathParts[i]] || {};
                }
                const key = pathParts[pathParts.length - 1];
                const expectedType = error.params.type;
                target[key] = this.getDefaultValueForType(expectedType);
            }
        }
        
        return fixed;
    }

    /**
     * Gets a default value for a field
     */
    getDefaultValue(field) {
        const defaults = {
            'name': '',
            'version': '0.0.0',
            'riskLevel': 'MEDIUM',
            'severity': 'MEDIUM',
            'description': '',
            'recommendations': [],
            'capabilities': [],
            'vulnerabilities': []
        };
        return defaults[field] || null;
    }

    /**
     * Gets a default value for a type
     */
    getDefaultValueForType(type) {
        const defaults = {
            'string': '',
            'number': 0,
            'integer': 0,
            'boolean': false,
            'array': [],
            'object': {},
            'null': null
        };
        return defaults[type] || null;
    }
}
```

---

## 6. Performance Optimization

### Compiled Schema Cache

```javascript
/**
 * SCHEMA CACHE WITH TTL
 * Optimizes validation performance
 */
class SchemaCache {
    constructor(options = {}) {
        this.options = {
            ttl: options.ttl || 3600000, // 1 hour
            maxSize: options.maxSize || 100,
            ...options
        };
        
        this.cache = new Map();
        this.accessTimes = new Map();
    }

    /**
     * Gets a schema from cache
     */
    get(key) {
        const cached = this.cache.get(key);
        if (!cached) return null;
        
        // Check TTL
        if (Date.now() - cached.timestamp > this.options.ttl) {
            this.cache.delete(key);
            this.accessTimes.delete(key);
            return null;
        }
        
        // Update access time
        this.accessTimes.set(key, Date.now());
        return cached.schema;
    }

    /**
     * Sets a schema in cache
     */
    set(key, schema) {
        // Check cache size
        if (this.cache.size >= this.options.maxSize) {
            this.evictLRU();
        }
        
        this.cache.set(key, {
            schema,
            timestamp: Date.now()
        });
        this.accessTimes.set(key, Date.now());
    }

    /**
     * Evicts least recently used items
     */
    evictLRU() {
        let oldest = null;
        let oldestTime = Infinity;
        
        for (const [key, time] of this.accessTimes) {
            if (time < oldestTime) {
                oldestTime = time;
                oldest = key;
            }
        }
        
        if (oldest) {
            this.cache.delete(oldest);
            this.accessTimes.delete(oldest);
        }
    }

    /**
     * Clears the cache
     */
    clear() {
        this.cache.clear();
        this.accessTimes.clear();
    }

    /**
     * Gets cache statistics
     */
    getStats() {
        return {
            size: this.cache.size,
            maxSize: this.options.maxSize,
            hitRate: this.getHitRate()
        };
    }

    /**
     * Calculates hit rate
     */
    getHitRate() {
        // This would require tracking hits/misses
        // For simplicity, we return a placeholder
        return 0.9;
    }
}
```

---

## Summary

| Aspect | Key Points |
|--------|------------|
| **Schema Design** | Use clear types, constraints, and descriptions |
| **Validation** | Validate all incoming data before processing |
| **Error Handling** | Provide detailed, actionable error messages |
| **Performance** | Cache compiled schemas for reuse |
| **Security** | Prevent injection attacks through validation |
| **Documentation** | Use schemas as living documentation |
