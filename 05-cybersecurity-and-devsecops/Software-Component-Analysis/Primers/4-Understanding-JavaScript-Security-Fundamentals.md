# Primer 4: Understanding JavaScript Security Fundamentals

Welcome to the fourth primer of our tutorial series. This primer explains the core JavaScript security concepts that underpin package vulnerabilities—understanding prototype pollution, XSS, code injection, and other fundamental JavaScript security issues that malicious packages exploit.

---

## JavaScript Security Model

### The JavaScript Runtime Environment

Understanding how JavaScript executes is crucial for understanding security vulnerabilities.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    JAVASCRIPT RUNTIME ENVIRONMENT                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    V8 ENGINE (Node.js/Browser)                     │  │
│  │  ┌──────────────────────────────────────────────────────────────┐ │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │ │  │
│  │  │  │   Call      │  │   Memory    │  │   Garbage           │ │ │  │
│  │  │  │   Stack     │  │   Heap      │  │   Collector         │ │ │  │
│  │  │  └─────────────┘  └─────────────┘  └─────────────────────┘ │ │  │
│  │  └──────────────────────────────────────────────────────────────┘ │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    SECURITY BOUNDARIES                             │  │
│  │  ┌──────────────────────────────────────────────────────────────┐ │  │
│  │  │  • Same-Origin Policy (Browser)                              │ │  │
│  │  │  • Process Isolation (Node.js)                               │ │  │
│  │  │  • Module Sandboxing                                         │ │  │
│  │  │  • Permissions System                                        │ │  │
│  │  └──────────────────────────────────────────────────────────────┘ │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### JavaScript Security Boundaries

```javascript
/**
 * JAVASCRIPT SECURITY BOUNDARIES
 * How JavaScript isolates code
 */

const securityBoundaries = {
    // 1. Same-Origin Policy (Browser)
    sameOrigin: {
        description: 'Prevents cross-origin access to sensitive data',
        rules: `
            ✅ Same protocol (http vs https)
            ✅ Same hostname (example.com vs evil.com)
            ✅ Same port (80 vs 8080)
        `,
        bypasses: `
            ⚠️ CORS misconfigurations
            ⚠️ XSS attacks
            ⚠️ JSONP vulnerabilities
            ⚠️ PostMessage attacks
        `
    },
    
    // 2. Node.js Process Isolation
    processIsolation: {
        description: 'Separate processes for different applications',
        mechanisms: [
            'Child processes (fork, spawn)',
            'Worker threads',
            'Cluster mode',
            'VM module sandboxing'
        ],
        risks: `
            ⚠️ Shared memory vulnerabilities
            ⚠️ Process injection attacks
            ⚠️ IPC channel attacks
        `
    },
    
    // 3. Module Sandboxing
    moduleSandboxing: {
        description: 'Isolating modules from each other',
        mechanisms: [
            'Module scope',
            'require() cache isolation',
            'ES modules strict mode'
        ],
        bypasses: `
            ⚠️ Module prototype pollution
            ⚠️ Module caching attacks
            ⚠️ Require injection
        `
    }
};
```

---

## Common JavaScript Vulnerabilities

### 1. Prototype Pollution

```javascript
/**
 * PROTOTYPE POLLUTION
 * Modifying the prototype chain to inject malicious properties
 */

// The vulnerability: Object prototype is accessible
const prototypePollutionExample = {
    vulnerable: `
        // ❌ VULNERABLE: User-controlled input used to set properties
        function merge(target, source) {
            for (let key in source) {
                if (source.hasOwnProperty(key)) {
                    target[key] = source[key];
                }
            }
            return target;
        }
        
        // Attacker payload
        const payload = JSON.parse('{"__proto__": {"isAdmin": true}}');
        const obj = {};
        merge(obj, payload);
        
        // Now EVERY object has isAdmin = true
        console.log({}.isAdmin); // true
        console.log([] .isAdmin); // true
    `,
    
    mitigation: `
        // ✅ SAFE: Prevent prototype pollution
        function safeMerge(target, source) {
            const prototypes = ['__proto__', 'constructor', 'prototype'];
            
            for (let key in source) {
                if (source.hasOwnProperty(key)) {
                    // Block prototype access
                    if (prototypes.includes(key)) {
                        continue;
                    }
                    target[key] = source[key];
                }
            }
            return target;
        }
        
        // Use Object.create(null) for safe objects
        const safeObj = Object.create(null);
        
        // Use Map instead of objects
        const safeMap = new Map();
    `,
    
    exploitPatterns: `
        // Common attack patterns
        const attacks = [
            // 1. __proto__ pollution
            '{"__proto__": {"malicious": true}}',
            
            // 2. Constructor pollution
            '{"constructor": {"prototype": {"malicious": true}}}',
            
            // 3. Prototype chain overwrite
            '{"__proto__": {"__proto__": {"malicious": true}}}',
            
            // 4. Array prototype pollution
            '{"__proto__": {"push": "malicious"}}'
        ];
    `
};

// Example: Prototype pollution detection
class PrototypePollutionDetector {
    constructor() {
        this.blockedKeys = ['__proto__', 'constructor', 'prototype'];
        this.suspiciousPatterns = [
            /__proto__/,
            /constructor/,
            /prototype/,
            /\.push\s*=/,
            /\.constructor\s*=/
        ];
    }
    
    analyzeObject(obj) {
        const issues = [];
        
        // Check for prototype pollution attempts
        for (const key of Object.keys(obj)) {
            if (this.blockedKeys.includes(key)) {
                issues.push({
                    type: 'Prototype Pollution',
                    key,
                    value: obj[key],
                    severity: 'CRITICAL',
                    description: `Attempt to modify ${key}`
                });
            }
        }
        
        // Check for suspicious property names
        for (const key of Object.keys(obj)) {
            if (this.suspiciousPatterns.some(p => p.test(key))) {
                issues.push({
                    type: 'Suspicious Property',
                    key,
                    value: obj[key],
                    severity: 'HIGH',
                    description: `Suspicious property name: ${key}`
                });
            }
        }
        
        // Check for deep prototype access
        this.checkDeepPrototype(obj, '', issues);
        
        return issues;
    }
    
    checkDeepPrototype(obj, path, issues) {
        for (const [key, value] of Object.entries(obj)) {
            const fullPath = path ? `${path}.${key}` : key;
            
            if (this.blockedKeys.includes(key)) {
                issues.push({
                    type: 'Deep Prototype Pollution',
                    path: fullPath,
                    key,
                    value,
                    severity: 'CRITICAL'
                });
            }
            
            if (value && typeof value === 'object') {
                this.checkDeepPrototype(value, fullPath, issues);
            }
        }
    }
}
```

### 2. Cross-Site Scripting (XSS)

```javascript
/**
 * CROSS-SITE SCRIPTING (XSS)
 * Injecting malicious scripts into applications
 */

const xssExploitation = {
    // 1. Reflected XSS
    reflectedXSS: {
        description: 'Injecting scripts via URL parameters',
        example: `
            // ❌ VULNERABLE: Unescaped user input
            app.get('/search', (req, res) => {
                const query = req.query.q;
                res.send(\`<h1>Search results for: \${query}</h1>\`);
            });
            
            // Attack: /search?q=<script>alert('XSS')</script>
        `,
        mitigation: `
            // ✅ SAFE: Escape user input
            app.get('/search', (req, res) => {
                const query = req.query.q;
                const escaped = escapeHtml(query);
                res.send(\`<h1>Search results for: \${escaped}</h1>\`);
            });
        `
    },
    
    // 2. Stored XSS
    storedXSS: {
        description: 'Storing malicious scripts in databases',
        example: `
            // ❌ VULNERABLE: Storing unsanitized comments
            app.post('/comment', (req, res) => {
                const comment = req.body.comment;
                db.insert({ comment });
                res.send('Comment added');
            });
            
            // Attack: Comment contains <script>alert('XSS')</script>
        `,
        mitigation: `
            // ✅ SAFE: Sanitize before storing
            app.post('/comment', (req, res) => {
                const comment = sanitizeHtml(req.body.comment);
                db.insert({ comment });
                res.send('Comment added');
            });
        `
    },
    
    // 3. DOM-Based XSS
    domXSS: {
        description: 'Injecting scripts via DOM manipulation',
        example: `
            // ❌ VULNERABLE: Using innerHTML
            document.getElementById('output').innerHTML = userInput;
            
            // Attack: userInput = '<img src=x onerror=alert("XSS")>'
        `,
        mitigation: `
            // ✅ SAFE: Use textContent
            document.getElementById('output').textContent = userInput;
            
            // Or use DOMPurify
            document.getElementById('output').innerHTML = DOMPurify.sanitize(userInput);
        `
    }
};

// Example: XSS detection in packages
class XSSDetector {
    constructor() {
        this.suspiciousPatterns = [
            /innerHTML\s*=/,
            /document\.write/,
            /eval\s*\(/,
            /setTimeout\s*\(.*['"]/,
            /setInterval\s*\(.*['"]/,
            /\.innerHTML\s*\+/,
            /\.outerHTML\s*=/,
            /\.insertAdjacentHTML/
        ];
        
        this.sanitizerPatterns = [
            /escapeHtml/,
            /DOMPurify/,
            /sanitize/,
            /textContent/,
            /createTextNode/
        ];
    }
    
    analyzeCode(code) {
        const issues = [];
        
        // Check for XSS patterns
        for (const pattern of this.suspiciousPatterns) {
            const matches = code.match(new RegExp(pattern, 'g'));
            if (matches) {
                // Check if sanitized
                const hasSanitizer = this.sanitizerPatterns.some(p => 
                    new RegExp(p, 'i').test(code)
                );
                
                issues.push({
                    type: 'Potential XSS',
                    pattern: pattern.toString(),
                    matches,
                    sanitized: hasSanitizer,
                    severity: hasSanitizer ? 'MEDIUM' : 'HIGH',
                    recommendation: hasSanitizer ? 
                        'Review sanitization implementation' :
                        'Implement input sanitization'
                });
            }
        }
        
        return issues;
    }
}
```

### 3. Command Injection

```javascript
/**
 * COMMAND INJECTION
 * Executing arbitrary system commands
 */

const commandInjection = {
    // 1. Shell Injection
    shellInjection: {
        description: 'Injecting commands into shell execution',
        example: `
            // ❌ VULNERABLE: Direct shell execution
            const { exec } = require('child_process');
            app.get('/ping', (req, res) => {
                const host = req.query.host;
                exec(\`ping \${host}\`, (error, stdout) => {
                    res.send(stdout);
                });
            });
            
            // Attack: /ping?host=example.com; rm -rf /
        `,
        mitigation: `
            // ✅ SAFE: Use execFile with arguments
            const { execFile } = require('child_process');
            app.get('/ping', (req, res) => {
                const host = req.query.host;
                // Validate host
                if (!isValidHost(host)) {
                    return res.status(400).send('Invalid host');
                }
                execFile('ping', ['-c', '4', host], (error, stdout) => {
                    res.send(stdout);
                });
            });
        `
    },
    
    // 2. SQL Injection
    sqlInjection: {
        description: 'Injecting SQL queries into database operations',
        example: `
            // ❌ VULNERABLE: Direct query construction
            app.get('/user', (req, res) => {
                const id = req.query.id;
                const query = \`SELECT * FROM users WHERE id = \${id}\`;
                db.query(query, (err, results) => {
                    res.send(results);
                });
            });
            
            // Attack: /user?id=1 OR 1=1
        `,
        mitigation: `
            // ✅ SAFE: Use parameterized queries
            app.get('/user', (req, res) => {
                const id = req.query.id;
                const query = 'SELECT * FROM users WHERE id = ?';
                db.query(query, [id], (err, results) => {
                    res.send(results);
                });
            });
        `
    },
    
    // 3. Template Injection
    templateInjection: {
        description: 'Injecting code into template engines',
        example: `
            // ❌ VULNERABLE: Unsafe template rendering
            app.render('template', { userInput: req.query.input });
            
            // Attack: input = {{ constructor.constructor('alert("XSS")')() }}
        `,
        mitigation: `
            // ✅ SAFE: Use context-aware escaping
            const template = require('lodash.template');
            const compiled = template('Hello <%= userInput %>');
            const result = compiled({ 
                userInput: escapeHtml(req.query.input) 
            });
        `
    }
};

// Example: Command injection detection
class CommandInjectionDetector {
    constructor() {
        this.dangerousFunctions = [
            'exec',
            'execSync',
            'spawn',
            'spawnSync',
            'fork',
            'execFile',
            'execFileSync'
        ];
        
        this.suspiciousPatterns = [
            /child_process\.exec/,
            /child_process\.spawn/,
            /child_process\.fork/,
            /execSync\s*\(/,
            /spawnSync\s*\(/,
            /`\${[^}]*`/  // Template literals in commands
        ];
    }
    
    analyzePackage(packagePath) {
        const fs = require('fs');
        const path = require('path');
        const issues = [];
        
        // Walk through all files
        const walkSync = (dir) => {
            const files = fs.readdirSync(dir);
            
            for (const file of files) {
                const filePath = path.join(dir, file);
                const stat = fs.statSync(filePath);
                
                if (stat.isDirectory()) {
                    if (file === 'node_modules' || file === '.git') continue;
                    walkSync(filePath);
                } else if (file.endsWith('.js')) {
                    const code = fs.readFileSync(filePath, 'utf8');
                    const detections = this.analyzeFile(code, filePath);
                    issues.push(...detections);
                }
            }
        };
        
        walkSync(packagePath);
        return issues;
    }
    
    analyzeFile(code, filePath) {
        const detections = [];
        
        // Check for dangerous function usage
        for (const func of this.dangerousFunctions) {
            const regex = new RegExp(`\\b${func}\\s*\\(`, 'g');
            const matches = code.match(regex);
            
            if (matches) {
                // Check if arguments are sanitized
                const hasValidation = this.hasInputValidation(code, func);
                
                detections.push({
                    file: filePath,
                    function: func,
                    count: matches.length,
                    hasValidation,
                    severity: hasValidation ? 'MEDIUM' : 'HIGH',
                    recommendation: hasValidation ?
                        'Review command validation' :
                        'Add input validation and sanitization'
                });
            }
        }
        
        // Check for template literals in command contexts
        const templateMatches = code.match(/`\${[^}]*}`/g);
        if (templateMatches) {
            detections.push({
                file: filePath,
                type: 'Template Literal in Command',
                count: templateMatches.length,
                severity: 'HIGH',
                recommendation: 'Avoid using template literals in shell commands'
            });
        }
        
        return detections;
    }
    
    hasInputValidation(code, functionName) {
        // Look for validation patterns around the function call
        const validationPatterns = [
            /validate\s*\(/,
            /sanitize\s*\(/,
            /escape\s*\(/,
            /\.test\s*\(/,
            /typeof\s*===/,
            /\.match\s*\(/,
            /\.replace\s*\(/
        ];
        
        // Find the function call location
        const funcIndex = code.indexOf(`${functionName}(`);
        if (funcIndex === -1) return false;
        
        // Look for validation in the surrounding 200 characters
        const context = code.substring(Math.max(0, funcIndex - 200), funcIndex + 200);
        
        return validationPatterns.some(pattern => pattern.test(context));
    }
}
```

### 4. Path Traversal

```javascript
/**
 * PATH TRAVERSAL
 * Accessing files outside the intended directory
 */

const pathTraversal = {
    // 1. Directory Traversal
    directoryTraversal: {
        description: 'Accessing files via relative paths (../)',
        example: `
            // ❌ VULNERABLE: Unsafe path construction
            const fs = require('fs');
            app.get('/file', (req, res) => {
                const filename = req.query.file;
                const filepath = path.join('./uploads/', filename);
                const content = fs.readFileSync(filepath);
                res.send(content);
            });
            
            // Attack: /file?file=../../etc/passwd
        `,
        mitigation: `
            // ✅ SAFE: Normalize and validate path
            app.get('/file', (req, res) => {
                const filename = req.query.file;
                
                // 1. Normalize path
                const baseDir = path.resolve('./uploads/');
                const fullPath = path.resolve(baseDir, filename);
                
                // 2. Check if inside base directory
                if (!fullPath.startsWith(baseDir)) {
                    return res.status(403).send('Access denied');
                }
                
                // 3. Check if file exists
                if (!fs.existsSync(fullPath)) {
                    return res.status(404).send('File not found');
                }
                
                const content = fs.readFileSync(fullPath);
                res.send(content);
            });
        `
    },
    
    // 2. Zip Slip
    zipSlip: {
        description: 'Extracting zip files to arbitrary locations',
        example: `
            // ❌ VULNERABLE: Unsafe zip extraction
            const AdmZip = require('adm-zip');
            app.post('/upload', (req, res) => {
                const zip = new AdmZip(req.file.buffer);
                zip.extractAllTo('./uploads/', true);
            });
            
            // Attack: Zip contains file with path ../../etc/passwd
        `,
        mitigation: `
            // ✅ SAFE: Validate extracted paths
            const yauzl = require('yauzl');
            
            app.post('/upload', (req, res) => {
                yauzl.fromBuffer(req.file.buffer, (err, zipfile) => {
                    zipfile.on('entry', (entry) => {
                        // Check entry path
                        const fullPath = path.join('./uploads/', entry.fileName);
                        const baseDir = path.resolve('./uploads/');
                        
                        if (!fullPath.startsWith(baseDir)) {
                            return; // Skip malicious entry
                        }
                        
                        // Extract safely
                        zipfile.openReadStream(entry, (err, readStream) => {
                            const writeStream = fs.createWriteStream(fullPath);
                            readStream.pipe(writeStream);
                        });
                    });
                });
            });
        `
    }
};

// Example: Path traversal detection
class PathTraversalDetector {
    constructor() {
        this.dangerousFunctions = [
            'readFile',
            'readFileSync',
            'writeFile',
            'writeFileSync',
            'createReadStream',
            'createWriteStream',
            'rename',
            'unlink',
            'mkdir',
            'rmdir'
        ];
        
        this.suspiciousPatterns = [
            /\b\.\.\//,                    // Directory traversal
            /path\.join\s*\([^)]*\.\.\//,   // Path join with ../
            /path\.resolve\s*\([^)]*\.\.\//,// Path resolve with ../
            /%2e%2e%2f/,                   // URL encoded ../
            /%2e%2e%5c/                    // URL encoded ..\ (Windows)
        ];
    }
    
    analyzeFile(code, filePath) {
        const detections = [];
        
        // Check for suspicious patterns
        for (const pattern of this.suspiciousPatterns) {
            const matches = code.match(new RegExp(pattern, 'g'));
            if (matches) {
                detections.push({
                    file: filePath,
                    pattern: pattern.toString(),
                    matches,
                    severity: 'HIGH',
                    type: 'Path Traversal',
                    recommendation: 'Validate all file paths with path.resolve and path.normalize'
                });
            }
        }
        
        // Check for dangerous file operations with user input
        for (const func of this.dangerousFunctions) {
            const regex = new RegExp(`\\b${func}\\s*\\([^)]*\\$\\{`, 'g');
            const matches = code.match(regex);
            
            if (matches) {
                detections.push({
                    file: filePath,
                    function: func,
                    type: 'Dynamic File Path',
                    severity: 'HIGH',
                    recommendation: 'Validate user input before file operations'
                });
            }
        }
        
        return detections;
    }
}
```

### 5. Insecure Deserialization

```javascript
/**
 * INSECURE DESERIALIZATION
 * Deserializing untrusted data
 */

const insecureDeserialization = {
    // 1. JSON Deserialization
    jsonDeserialization: {
        description: 'Deserializing untrusted JSON with reviver functions',
        example: `
            // ❌ VULNERABLE: Using eval in JSON reviver
            app.post('/data', (req, res) => {
                const data = JSON.parse(req.body, (key, value) => {
                    if (typeof value === 'string' && value.startsWith('function')) {
                        return eval(value);  // DANGEROUS!
                    }
                    return value;
                });
            });
        `,
        mitigation: `
            // ✅ SAFE: Use safe JSON parsing
            app.post('/data', (req, res) => {
                // Just parse without reviver
                const data = JSON.parse(req.body);
                
                // Or use safe reviver
                const data = JSON.parse(req.body, (key, value) => {
                    // Only allow specific transformations
                    if (key === 'date') {
                        return new Date(value);
                    }
                    return value;
                });
            });
        `
    },
    
    // 2. Node.js Serialization
    nodeSerialization: {
        description: 'Deserializing Node.js-specific formats',
        example: `
            // ❌ VULNERABLE: Using unsafe serialization
            const serialize = require('serialize-javascript');
            const vm = require('vm');
            
            app.post('/code', (req, res) => {
                const code = req.body.code;
                const obj = JSON.parse(code);
                // This can execute arbitrary code
                const result = vm.runInNewContext(serialize(obj));
            });
        `,
        mitigation: `
            // ✅ SAFE: Use JSON for serialization
            app.post('/data', (req, res) => {
                // Only use JSON.parse/stringify
                const data = JSON.parse(req.body);
                // Validate data structure
                if (typeof data !== 'object' || data === null) {
                    return res.status(400).send('Invalid data');
                }
                // Process safely
            });
        `
    }
};
```

---

## Vulnerability Detection in Packages

### Comprehensive Vulnerability Scanner

```javascript
/**
 * COMPREHENSIVE VULNERABILITY SCANNER
 * Detects all common JavaScript vulnerabilities in packages
 */

class JavaScriptVulnerabilityScanner {
    constructor() {
        this.detectors = {
            prototypePollution: new PrototypePollutionDetector(),
            xss: new XSSDetector(),
            commandInjection: new CommandInjectionDetector(),
            pathTraversal: new PathTraversalDetector()
        };
    }

    scanPackage(packagePath) {
        const results = {
            package: path.basename(packagePath),
            vulnerabilities: [],
            riskScore: 0,
            riskLevel: 'LOW'
        };

        // Run all detectors
        for (const [name, detector] of Object.entries(this.detectors)) {
            try {
                const detections = this.runDetector(detector, packagePath);
                results.vulnerabilities.push(...detections);
            } catch (error) {
                console.warn(`Detector ${name} failed: ${error.message}`);
            }
        }

        // Calculate risk score
        results.riskScore = this.calculateRiskScore(results.vulnerabilities);
        results.riskLevel = this.riskScoreToLevel(results.riskScore);

        return results;
    }

    runDetector(detector, packagePath) {
        if (detector.analyzePackage) {
            return detector.analyzePackage(packagePath);
        }
        return [];
    }

    calculateRiskScore(vulnerabilities) {
        const severityScores = {
            CRITICAL: 25,
            HIGH: 15,
            MEDIUM: 8,
            LOW: 3
        };

        let score = 0;
        for (const vuln of vulnerabilities) {
            score += severityScores[vuln.severity] || 5;
        }

        return Math.min(score, 100);
    }

    riskScoreToLevel(score) {
        if (score >= 70) return 'CRITICAL';
        if (score >= 50) return 'HIGH';
        if (score >= 30) return 'MEDIUM';
        return 'LOW';
    }

    generateReport(results) {
        const report = {
            scanTime: new Date().toISOString(),
            packages: results,
            summary: {
                totalPackages: results.length,
                totalVulnerabilities: results.reduce((sum, r) => sum + r.vulnerabilities.length, 0),
                bySeverity: this.summarizeBySeverity(results),
                highRiskPackages: results.filter(r => r.riskLevel === 'CRITICAL' || r.riskLevel === 'HIGH')
            }
        };

        return report;
    }

    summarizeBySeverity(results) {
        const summary = { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0 };
        
        for (const result of results) {
            for (const vuln of result.vulnerabilities) {
                if (summary[vuln.severity] !== undefined) {
                    summary[vuln.severity]++;
                }
            }
        }
        
        return summary;
    }
}
```

---

## Security Best Practices Summary

| Vulnerability | Prevention | Detection |
|--------------|------------|-----------|
| **Prototype Pollution** | Use Object.create(null), Map, freeze prototypes | Scan for __proto__, constructor access |
| **XSS** | Escape output, use textContent, sanitize input | Scan for innerHTML, document.write |
| **Command Injection** | Use execFile with arguments, validate input | Scan for exec, spawn with user input |
| **Path Traversal** | Normalize paths, validate boundaries | Scan for ../, path.join with user input |
| **Insecure Deserialization** | Use JSON.parse safely, validate data | Scan for eval, new Function, vm.run |
