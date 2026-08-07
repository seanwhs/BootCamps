# Student Notes: Beyond CVEs - The Evolution of Software Composition Analysis

## Complete Companion Notes for the Tutorial Series

---

## PART 0: INTRODUCTION

### Key Concepts

**Software Composition Analysis (SCA)**
- The process of analyzing open-source dependencies for security vulnerabilities
- Traditional SCA: Matches package versions against CVE databases
- Modern SCA: Analyzes behavior, capabilities, and supply chain risks

**Supply Chain Security**
- The security of the entire software development lifecycle
- Includes package sources, build processes, and distribution
- Attackers target dependencies because they're trusted

### Series Overview

```
📚 4 Phases, 5 Primers, 4 Reference Appendices
📖 60-90 minutes total video content
💻 Hands-on coding in every section
🎯 Build a complete production-ready system
```

### Environment Setup Cheatsheet

```bash
# Node.js version
node --version   # Must be 18.x or higher

# npm version
npm --version    # Must be 9.x or higher

# Install tools
npm install -g nodemon json serve

# Project structure
mkdir beyond-cves-tutorial
cd beyond-cves-tutorial

# API keys (optional)
export OPENAI_API_KEY=your_key
export SNYK_API_KEY=your_key
export SOCKET_API_KEY=your_key
```

---

## PHASE 1: FOUNDATIONS

### 1.1 JavaScript Execution Model

#### The Call Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CALL STACK VISUALIZATION                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Synchronous Code Execution:                                        │
│                                                                      │
│  1. main() ─────►                                                    │
│  2. functionA() ─────►                                              │
│  3. functionB() ─────►                                              │
│  4. functionC() ─────►                                              │
│  5. functionC returns                                               │
│  6. functionB returns                                               │
│  7. functionA returns                                               │
│  8. main() returns                                                  │
│                                                                      │
│  LIFO (Last In, First Out)                                         │
│  Stack Overflow: When the stack exceeds its limit                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### The Heap

```
┌─────────────────────────────────────────────────────────────────────┐
│                    HEAP VISUALIZATION                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Memory for dynamic allocation:                                    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Objects    │  Functions  │  Closures  │  Buffers        │    │
│  │  {          │  function  │  () => {}  │  <Buffer 00 01> │    │
│  │    name: 'A'│  () => {}  │            │                   │    │
│  │  }          │            │            │                   │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Garbage Collector: Automatically frees unused memory             │
│  Memory Leak: When objects are never freed                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### The Event Loop

```
┌─────────────────────────────────────────────────────────────────────┐
│                    EVENT LOOP VISUALIZATION                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Priority Order:                                                    │
│                                                                      │
│  1. process.nextTick      (Highest Priority)                       │
│  2. Promise.then          (Microtask)                             │
│  3. queueMicrotask        (Microtask)                             │
│  4. setTimeout(0)         (Macrotask)                             │
│  5. setImmediate          (Macrotask - Check Phase)               │
│  6. I/O Operations        (Macrotask - Poll Phase)                │
│  7. setInterval           (Macrotask - Timer Phase)               │
│  8. close callbacks       (Macrotask - Close Phase)               │
│                                                                      │
│  KEY INSIGHT: Microtasks run BEFORE macrotasks                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Security Implications

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SECURITY IMPLICATIONS                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. process.nextTick Hijacking                                      │
│     → Runs before any other async operation                       │
│     → Can execute immediately after install                      │
│                                                                      │
│  2. Promise.then Exploitation                                       │
│     → Runs before setTimeout                                       │
│     → Can hide malicious activity                                  │
│                                                                      │
│  3. setTimeout(0) Evasion                                           │
│     → NOT guaranteed immediate execution                          │
│     → Can delay malicious activity                                │
│                                                                      │
│  4. Event Loop Starvation                                            │
│     → Infinite loop blocks everything                              │
│     → Denial of Service                                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Quick Reference: Queue Types

| Queue | Priority | Examples |
|-------|----------|----------|
| **Microtask** | High | Promise.then, process.nextTick, queueMicrotask |
| **Macrotask** | Low | setTimeout, setInterval, setImmediate, I/O |

---

### 1.2 npm Install Lifecycle

#### Lifecycle Phases

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NPM INSTALL LIFECYCLE                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Phase 1: PREINSTALL                                                │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Runs: BEFORE package is installed                         │    │
│  │  Risk: HIGH                                                │    │
│  │  Attack: Code executes before any security checks         │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  Phase 2: INSTALL                                                  │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Runs: DURING installation                                 │    │
│  │  Risk: CRITICAL                                            │    │
│  │  Attack: Full system access during install                │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  Phase 3: POSTINSTALL                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Runs: AFTER installation                                  │    │
│  │  Risk: CRITICAL                                            │    │
│  │  Attack: Most common attack vector                        │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Lifecycle Script Risks

| Script | Risk Level | Common Attack |
|--------|------------|---------------|
| preinstall | HIGH | Pre-install reconnaissance |
| install | CRITICAL | Shell command execution |
| postinstall | CRITICAL | Data exfiltration |
| prepare | HIGH | Build-time attacks |
| preuninstall | MEDIUM | Persistence |
| uninstall | MEDIUM | Cleanup attacks |

#### Detection Patterns

```javascript
// Dangerous Patterns to Detect
const patterns = {
    // Environment Variables
    envAccess: /process\.env/,
    
    // Shell Commands
    shellExec: /(exec|spawn|child_process)/,
    
    // Network Access
    networkAccess: /(http\.|https\.|fetch|axios)/,
    
    // Filesystem Operations
    fsAccess: /(fs\.|readFile|writeFile)/,
    
    // Dynamic Code
    dynamicCode: /(eval|new Function|vm\.)/,
    
    // Persistence
    persistence: /(cron|startup|service|systemd)/
};
```

---

### 1.3 Building the Scanner

#### Scanner Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SCANNER ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Input: Package Directory                                           │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 1: Parse package.json                                │    │
│  │  ├─ Extract scripts                                        │    │
│  │  ├─ Extract dependencies                                   │    │
│  │  └─ Extract metadata                                       │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 2: Scan Dependencies                                 │    │
│  │  ├─ Read lock file                                         │    │
│  │  ├─ Check vulnerabilities                                  │    │
│  │  └─ Analyze dependency tree                                │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 3: Behavioral Analysis                               │    │
│  │  ├─ Scan JavaScript files                                  │    │
│  │  ├─ Detect capabilities                                    │    │
│  │  └─ Identify patterns                                      │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Step 4: Risk Scoring                                      │    │
│  │  ├─ Calculate score                                        │    │
│  │  ├─ Determine level                                        │    │
│  │  └─ Generate recommendations                               │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Output: Security Report                                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Risk Scoring System

| Severity | Points | Action |
|----------|--------|--------|
| CRITICAL | 25 | Immediate block |
| HIGH | 15 | Urgent review |
| MEDIUM | 8 | Scheduled review |
| LOW | 3 | Monitor |
| INFO | 0 | No action |

```
Total Score = Sum of (Severity Points × Frequency)

Risk Level:
  • 0-9:   LOW
  • 10-29: MEDIUM
  • 30-49: HIGH
  • 50+:   CRITICAL
```

#### Command Reference

```bash
# Run the scanner
node phase-1/08-complete-scanner.js

# Run CI/CD integration
node phase-1/09-ci-integration.js

# Generate HTML report
node phase-1/08-complete-scanner.js --html

# CI mode (exit codes)
node phase-1/09-ci-integration.js --ci
```

---

### 1.4 Key Takeaways

#### Module 1 Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                    KEY TAKEAWAYS                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. JavaScript Execution Model                                     │
│     → Understanding the event loop is crucial for security         │
│     → Microtasks run before macrotasks                            │
│     → Malicious packages exploit this order                       │
│                                                                      │
│  2. npm Install Lifecycle                                          │
│     → Every phase has security implications                       │
│     → preinstall, install, postinstall are most dangerous        │
│     → Always check scripts before installing                     │
│                                                                      │
│  3. Behavioral Detection                                           │
│     → Traditional CVE scanning is not enough                      │
│     → Look for suspicious patterns                               │
│     → Detect unknown threats                                      │
│                                                                      │
│  4. Risk Scoring                                                   │
│     → Combine multiple factors                                    │
│     → Prioritize critical issues                                 │
│     → Make decisions automated                                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Quick Commands

```bash
# Check installed packages
npm list --depth=0

# Audit vulnerabilities
npm audit

# Check package scripts
npm view <package-name> scripts

# Run package in isolation
docker run -it --rm node:18 bash
```

---

## PHASE 2: MODERN DEPENDENCY RISK ANALYSIS

### 2.1 Package Manifest Analysis

#### package.json Structure

```json
{
  // Identity
  "name": "my-package",
  "version": "1.0.0",
  
  // Scripts (Security Risk!)
  "scripts": {
    "preinstall": "...",    // HIGH
    "install": "...",        // CRITICAL
    "postinstall": "..."     // CRITICAL
  },
  
  // Dependencies
  "dependencies": {},        // Production
  "devDependencies": {},     // Development
  "peerDependencies": {},    // Required
  
  // Security
  "private": false,          // Public/Private
  "license": "MIT"           // License
}
```

#### Lock File Analysis

```json
// package-lock.json
{
  "packages": {
    "node_modules/express": {
      "version": "4.18.2",        // Exact version
      "resolved": "https://...",  // Download URL
      "integrity": "sha512-..."   // Integrity hash
    }
  }
}
```

#### Dependency Confusion Detection

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DEPENDENCY CONFUSION                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Attack Pattern:                                                    │
│  1. Internal package: @company/internal-utils                     │
│  2. Attacker publishes: internal-utils to public registry        │
│  3. Higher version: 999.0.0                                       │
│  4. npm install picks public version                              │
│  5. Malicious code executes                                       │
│                                                                      │
│  Detection:                                                        │
│  ✅ Private package + unscoped dependencies                       │
│  ✅ Suspicious version numbers (999.0.0)                         │
│  ✅ Missing private registry configuration                        │
│                                                                      │
│  Mitigation:                                                       │
│  ✅ Use scoped packages (@company/package)                       │
│  ✅ Configure private registry                                    │
│  ✅ Pin exact versions                                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Typosquatting Detection

```
┌─────────────────────────────────────────────────────────────────────┐
│                    TYPOSQUATTING DETECTION                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Techniques:                                                        │
│                                                                      │
│  1. Letter Swap: expreess → express                                │
│  2. Missing Letter: expres → express                              │
│  3. Extra Letter: expresss → express                              │
│  4. Suffix Addition: express-latest → express                    │
│  5. Prefix Addition: node-express → express                       │
│                                                                      │
│  Detection Algorithm:                                              │
│  • Levenshtein distance for similarity                            │
│  • Pattern matching for common techniques                        │
│  • Popular package list for reference                            │
│                                                                      │
│  Risk Levels:                                                      │
│  • >0.9 similarity: CRITICAL                                     │
│  • 0.8-0.89: HIGH                                                │
│  • 0.7-0.79: MEDIUM                                              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 2.2 Capability Scanning

#### Capability Types

| Capability | Risk | Detection Pattern |
|------------|------|-------------------|
| FILESYSTEM_ACCESS | HIGH | `fs.`, `readFile`, `writeFile` |
| NETWORK_ACCESS | HIGH | `http.`, `axios`, `fetch` |
| SHELL_EXECUTION | CRITICAL | `exec`, `spawn`, `child_process` |
| ENVIRONMENT_ACCESS | MEDIUM | `process.env`, `os.homedir` |
| DYNAMIC_CODE | CRITICAL | `eval`, `new Function`, `vm` |
| NATIVE_BINARIES | HIGH | `.node`, `dlopen` |
| TELEMETRY | MEDIUM | `analytics`, `sentry` |
| CRYPTOGRAPHY | MEDIUM | `crypto.createCipher` |

#### AST-Based Analysis

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AST ANALYSIS PROCESS                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Code:                                                              │
│  const fs = require('fs');                                          │
│  fs.readFileSync('/etc/passwd');                                   │
│                                                                      │
│  AST Representation:                                                │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  VariableDeclaration                                        │    │
│  │  ├─ Identifier: fs                                          │    │
│  │  └─ CallExpression: require('fs')                           │    │
│  │  MemberExpression: fs.readFileSync                         │    │
│  │  └─ CallExpression: fs.readFileSync('/etc/passwd')        │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Detection: Filesystem Access (HIGH RISK)                         │
│  Evidence: fs.readFileSync with '/etc/passwd'                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Risk Scoring

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CAPABILITY RISK SCORING                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Score Calculation:                                                 │
│  • Each capability detection adds points                          │
│  • CRITICAL: 15 points                                             │
│  • HIGH: 10 points                                                 │
│  • MEDIUM: 5 points                                                │
│  • LOW: 2 points                                                   │
│                                                                      │
│  Risk Level:                                                       │
│  • 0-39:  LOW                                                      │
│  • 40-59: MEDIUM                                                   │
│  • 60-79: HIGH                                                     │
│  • 80-100: CRITICAL                                                │
│                                                                      │
│  Example:                                                          │
│  • 2 SHELL_EXECUTION (CRITICAL) = 30 points                      │
│  • 1 NETWORK_ACCESS (HIGH) = 10 points                           │
│  • 1 ENVIRONMENT_ACCESS (MEDIUM) = 5 points                      │
│  • Total = 45 points → MEDIUM risk                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 2.3 Socket vs. Snyk Comparison

#### Feature Comparison

| Feature | Socket | Snyk |
|---------|--------|------|
| Primary Focus | Behavioral Analysis | Vulnerability Detection |
| CVE Database | Limited | Comprehensive |
| Zero-Day Detection | Yes | Limited |
| Supply Chain Risks | Full | Partial |
| Remediation Advice | Basic | Detailed |
| CI/CD Integration | Yes | Yes |
| Free Tier | 50 scans/mo | 200 scans/mo |

#### When to Use Each

```
┌─────────────────────────────────────────────────────────────────────┐
│                    WHEN TO USE EACH TOOL                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Use Socket When:                                                   │
│  ✓ Evaluating a new package                                        │
│  ✓ Concerned about supply chain attacks                           │
│  ✓ Need behavioral analysis                                       │
│  ✓ Detecting zero-day threats                                    │
│  ✓ Building dependency approval process                          │
│                                                                      │
│  Use Snyk When:                                                    │
│  ✓ Managing existing dependencies                                 │
│  ✓ Need to fix known vulnerabilities                             │
│  ✓ Require CVE-based compliance                                   │
│  ✓ Need remediation advice                                        │
│  ✓ Integrating with existing tools                               │
│                                                                      │
│  Use Both When:                                                    │
│  ✓ Comprehensive security coverage                                │
│  ✓ Critical security decisions                                    │
│  ✓ Building a security pipeline                                  │
│  ✓ Justifying security decisions                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Integration Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    COMPARATIVE ANALYSIS FLOW                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Input: Package Name + Version                                     │
│                                                                      │
│  ┌─────────────────┐     ┌─────────────────┐                       │
│  │    Socket       │     │     Snyk        │                       │
│  │  Analysis       │     │   Analysis      │                       │
│  └────────┬────────┘     └────────┬────────┘                       │
│           │                       │                                 │
│           └───────────┬───────────┘                                 │
│                       │                                             │
│          ┌────────────▼────────────┐                               │
│          │   Comparative Engine    │                               │
│          │  • Merge results        │                               │
│          │  • Identify conflicts   │                               │
│          │  • Generate unified     │                               │
│          │    recommendations      │                               │
│          └─────────────────────────┘                               │
│                       │                                             │
│          ┌────────────▼────────────┐                               │
│          │    Unified Report       │                               │
│          │  • Combined findings    │                               │
│          │  • Unified risk score   │                               │
│          │  • Actionable insights  │                               │
│          └─────────────────────────┘                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### API Quick Reference

**Socket API**

```javascript
// Base URL
https://api.socket.dev/v1

// Authentication
Authorization: Bearer ${API_KEY}

// Endpoints
GET /packages/{name}
GET /packages/{name}/capabilities
GET /packages/{name}/risks
POST /scan
```

**Snyk API**

```javascript
// Base URL
https://api.snyk.io/rest

// Authentication
Authorization: token ${API_KEY}

// Endpoints
GET /vulnerabilities
GET /dependencies
GET /remediation
POST /orgs/{orgId}/projects
```

---

### 2.4 Key Takeaways

#### Module 2 Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                    KEY TAKEAWAYS                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Package Analysis                                                │
│     → package.json and lock files are critical                    │
│     → Scripts reveal malicious intent                            │
│     → Dependencies can be confusing                              │
│                                                                      │
│  2. Capability Scanning                                             │
│     → What a package CAN do matters                               │
│     → AST analysis is safe and effective                           │
│     → Risk scoring helps prioritize                               │
│                                                                      │
│  3. Socket vs. Snyk                                                 │
│     → Different approaches complement each other                  │
│     → Use both for comprehensive coverage                          │
│     → Comparative analysis is powerful                            │
│                                                                      │
│  4. Detection Techniques                                            │
│     → Typosquatting: Name similarity                              │
│     → Dependency confusion: Private + unscoped                   │
│     → Behavioral analysis: Capability detection                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Quick Reference: Detection Rules

```javascript
// Detecting Typosquatting
const similarity = calculateSimilarity(name, popularPackage);
if (similarity > 0.7) {
    // Suspicious - investigate
}

// Detecting Dependency Confusion
if (isPrivatePackage && hasUnscopedDependencies) {
    // High risk - check registry
}

// Detecting Capabilities
if (scriptContains('exec') || scriptContains('spawn')) {
    // SHELL_EXECUTION detected
}
```

---

## PHASE 3: ASYNCHRONOUS EXECUTION & SECURE ORCHESTRATION

### 3.1 Concurrency Patterns

#### Concurrency Models

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CONCURRENCY MODELS                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Sequential Processing (Slowest)                                │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐                       │
│     │ Item 1   │→│ Item 2   │→│ Item 3   │                       │
│     └──────────┘ └──────────┘ └──────────┘                       │
│     Total Time = N × TimePerItem                                  │
│                                                                      │
│  2. Parallel Processing (Faster)                                   │
│     ┌──────────┐                                                  │
│     │ Item 1   │                                                  │
│     ├──────────┤                                                  │
│     │ Item 2   │                                                  │
│     ├──────────┤                                                  │
│     │ Item 3   │                                                  │
│     └──────────┘                                                  │
│     Total Time = TimePerItem × (N / Workers)                     │
│                                                                      │
│  3. Pipeline Processing (Best for streaming)                       │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐                       │
│     │ Stage 1  │→│ Stage 2  │→│ Stage 3  │                       │
│     └──────────┘ └──────────┘ └──────────┘                       │
│     Items flow through stages                                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Concurrency Controller

```javascript
// Basic Worker Pool Pattern
class ConcurrencyController {
    async process(items, processor) {
        const workers = [];
        const concurrency = this.options.concurrency;
        
        // Start workers
        for (let i = 0; i < concurrency; i++) {
            workers.push(this.worker(processor));
        }
        
        // Wait for all workers
        await Promise.all(workers);
        
        return this.results;
    }
    
    async worker(processor) {
        while (this.queue.length > 0) {
            const item = this.queue.shift();
            const result = await processor(item);
            this.results.push(result);
        }
    }
}
```

#### Timeout and Cancellation

```javascript
// AbortController Pattern
async function processWithTimeout(item, timeoutMs) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => {
        controller.abort();
    }, timeoutMs);
    
    try {
        const result = await processor(item, controller.signal);
        clearTimeout(timeoutId);
        return result;
    } catch (error) {
        clearTimeout(timeoutId);
        if (error.name === 'AbortError') {
            throw new Error('Operation timed out');
        }
        throw error;
    }
}
```

---

### 3.2 Resource Management

#### Resource Types to Monitor

```
┌─────────────────────────────────────────────────────────────────────┐
│                    RESOURCE MONITORING                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Memory Usage                                                    │
│     • Total memory: os.totalmem()                                  │
│     • Free memory: os.freemem()                                    │
│     • Used memory: total - free                                   │
│     • Threshold: 80% memory pressure                              │
│                                                                      │
│  2. CPU Usage                                                       │
│     • Load average: os.loadavg()                                   │
│     • CPU cores: os.cpus().length                                  │
│     • Threshold: 80% CPU pressure                                 │
│                                                                      │
│  3. File Handles                                                    │
│     • Open files: process._getActiveHandles()                     │
│     • Max files: ulimit -n                                        │
│     • Threshold: 90% file handle usage                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Memory-Aware Scheduling

```javascript
// Adaptive Concurrency
class MemoryAwareScheduler {
    adjustConcurrency(currentConcurrency) {
        const memoryUsage = this.getMemoryUsage();
        const cpuUsage = this.getCPUUsage();
        
        if (memoryUsage > 80) {
            // Reduce concurrency
            return Math.max(1, currentConcurrency - 2);
        }
        
        if (cpuUsage > 80) {
            // Reduce concurrency
            return Math.max(1, currentConcurrency - 1);
        }
        
        if (memoryUsage < 50 && cpuUsage < 50) {
            // Increase concurrency
            return currentConcurrency + 1;
        }
        
        return currentConcurrency;
    }
}
```

#### Graceful Degradation

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GRACEFUL DEGRADATION                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Step 1: Detect Resource Pressure                                  │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  if (memory > 80%) {                                       │    │
│  │    degradeService();                                       │    │
│  │  }                                                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  Step 2: Reduce Concurrency                                        │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  concurrency = Math.max(1, concurrency - 2);              │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  Step 3: Pause Non-Critical Tasks                                 │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  pauseBackgroundTasks();                                   │    │
│  │  prioritizeCriticalTasks();                               │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  Step 4: Alert                                                  │    │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  sendAlert({ severity: 'WARNING', message: '...' });     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 3.3 Priority Queuing

#### Priority Levels

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PRIORITY LEVELS                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Level      │ Use Case           │ Example                         │
│  ───────────┼────────────────────┼─────────────────────────────────┤
│  CRITICAL   │ Security patches   │ Known vulnerabilities          │
│  HIGH       │ Production pkgs    │ Core dependencies              │
│  MEDIUM     │ Development pkgs   │ Build tools                    │
│  LOW        │ Optional pkgs      │ Documentation                  │
│  BACKGROUND │ Non-critical       │ Test packages                  │
│                                                                      │
│  Queue Behavior:                                                    │
│  • Higher priority items are always processed first                │
│  • Lower priority items wait                                      │
│  • Priority inversion prevention (aging)                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Queue Implementation

```javascript
// Priority Queue Pattern
class PriorityQueue {
    constructor() {
        this.queues = {
            critical: [],
            high: [],
            medium: [],
            low: [],
            background: []
        };
    }
    
    add(item, priority) {
        this.queues[priority].push(item);
    }
    
    next() {
        for (const priority of ['critical', 'high', 'medium', 'low', 'background']) {
            if (this.queues[priority].length > 0) {
                return this.queues[priority].shift();
            }
        }
        return null;
    }
}
```

#### Priority Aging (Starvation Prevention)

```javascript
// Prevent lower priority items from starving
class PriorityQueueWithAging extends PriorityQueue {
    constructor(options) {
        super(options);
        this.maxWaitTime = options.maxWaitTime || 300000; // 5 minutes
        this.waitTimes = {};
    }
    
    next() {
        // Check for aging
        for (const [priority, items] of Object.entries(this.queues)) {
            for (const item of items) {
                if (Date.now() - item.addedAt > this.maxWaitTime) {
                    // Promote to higher priority
                    this.promoteItem(item);
                }
            }
        }
        
        return super.next();
    }
    
    promoteItem(item) {
        // Remove from current queue
        const currentQueue = this.queues[item.priority];
        const index = currentQueue.indexOf(item);
        if (index > -1) {
            currentQueue.splice(index, 1);
        }
        
        // Add to higher priority
        const newPriority = this.getHigherPriority(item.priority);
        this.queues[newPriority].push({
            ...item,
            priority: newPriority,
            promoted: true
        });
    }
}
```

---

### 3.4 Key Takeaways

#### Module 3 Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                    KEY TAKEAWAYS                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Concurrency                                                     │
│     → Parallel processing improves performance                    │
│     → Worker pool pattern is efficient                            │
│     → Timeouts prevent hanging                                    │
│                                                                      │
│  2. Resource Management                                             │
│     → Monitor memory, CPU, file handles                          │
│     → Adapt concurrency to load                                   │
│     → Graceful degradation protects system                       │
│                                                                      │
│  3. Priority Queuing                                                │
│     → Critical packages first                                     │
│     → Aging prevents starvation                                   │
│     → Different priorities for different needs                   │
│                                                                      │
│  4. Production Readiness                                            │
│     → Error handling is essential                                 │
│     → Retries and backoff are important                           │
│     → Monitoring and alerts are necessary                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Quick Reference: Concurrency Patterns

```javascript
// 1. Worker Pool (Most Common)
async function workerPool(items, processor, concurrency) {
    const results = [];
    const queue = [...items];
    
    const workers = [];
    for (let i = 0; i < concurrency; i++) {
        workers.push((async () => {
            while (queue.length > 0) {
                const item = queue.shift();
                const result = await processor(item);
                results.push(result);
            }
        })());
    }
    
    await Promise.all(workers);
    return results;
}

// 2. Rate Limiter
async function rateLimiter(items, processor, ratePerSecond) {
    const interval = 1000 / ratePerSecond;
    const results = [];
    
    for (const item of items) {
        const start = Date.now();
        const result = await processor(item);
        results.push(result);
        const elapsed = Date.now() - start;
        const delay = Math.max(0, interval - elapsed);
        if (delay > 0) {
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }
    
    return results;
}
```

---

## PHASE 4: AI-AUGMENTED SOFTWARE SUPPLY CHAIN SECURITY

### 4.1 LLM Integration

#### Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LLM INTEGRATION ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Input: Security Findings                                           │
│                                                                      │
│  1. Prompt Engineering                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  System: "You are a security expert..."                   │    │
│  │  Task: "Analyze this package..."                         │    │
│  │  Output: "Return JSON with fields..."                    │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  2. LLM API Call                                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  OpenAI / Anthropic / DeepSeek                            │    │
│  │  Token Usage: ~2450 tokens                              │    │
│  │  Cost: ~$0.0124                                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  3. Response Processing                                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Parse JSON                                                 │    │
│  │  Validate against schema                                   │    │
│  │  Extract structured data                                  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  Output: Structured Security Analysis                             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Provider Configuration

```javascript
// OpenAI
const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
    model: 'gpt-4-turbo-preview'
});

// Anthropic
const anthropic = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY,
    model: 'claude-3-opus-20240229'
});

// DeepSeek
const deepseek = new OpenAI({
    apiKey: process.env.DEEPSEEK_API_KEY,
    baseURL: 'https://api.deepseek.com/v1'
});
```

#### Response Schema

```json
{
  "summary": "Brief overview (max 200 chars)",
  "riskLevel": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "riskScore": 0-100,
  "capabilities": [
    {
      "type": "string",
      "severity": "string",
      "description": "string"
    }
  ],
  "vulnerabilities": [
    {
      "id": "string",
      "severity": "string",
      "description": "string",
      "cve": "string|null"
    }
  ],
  "recommendations": [
    {
      "priority": "IMMEDIATE|HIGH|MEDIUM|LOW",
      "action": "string",
      "description": "string"
    }
  ]
}
```

---

### 4.2 Prompt Engineering

#### Prompt Components

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
│                                                                      │
│  4. OUTPUT SCHEMA                                                   │
│     Format: "JSON with fields: summary, riskLevel..."            │
│     Examples: "Example 1: { summary: '...' }"                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Prompt Engineering Techniques

| Technique | Description | When to Use |
|-----------|-------------|-------------|
| **System Prompt** | Define role and constraints | Always |
| **Few-Shot Learning** | Provide examples | Inconsistent outputs |
| **Chain-of-Thought** | Step-by-step reasoning | Complex analysis |
| **Output Schema** | Define structure | Machine parsing |
| **Temperature Control** | Lower = more deterministic | Critical decisions |

#### Security Prompt Template

```javascript
const SECURITY_EXPERT_PROMPT = `
You are a senior security engineer specializing in supply chain security.

Analyze the following package and provide a comprehensive security assessment.

Package: ${packageName}@${version}
Capabilities: ${JSON.stringify(capabilities)}
Vulnerabilities: ${JSON.stringify(vulnerabilities)}

Provide your analysis in the following JSON format:
{
  "summary": "Brief overview (max 200 chars)",
  "riskLevel": "CRITICAL|HIGH|MEDIUM|LOW|INFO",
  "riskScore": 0-100,
  "capabilities": [...],
  "vulnerabilities": [...],
  "recommendations": [...]
}

Always prioritize security best practices. Never recommend insecure solutions.
`;
```

---

### 4.3 Policy Engine

#### Policy Types

```
┌─────────────────────────────────────────────────────────────────────┐
│                    POLICY TYPES                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Risk Level Policies                                             │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  CRITICAL: BLOCK (No override)                             │    │
│  │  HIGH: REVIEW (Override with justification)                │    │
│  │  MEDIUM: REVIEW (Override with justification)              │    │
│  │  LOW: APPROVE (No override)                                │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  2. Capability Policies                                              │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  SHELL_EXECUTION: BLOCK (No override)                      │    │
│  │  DYNAMIC_CODE: BLOCK (No override)                         │    │
│  │  FILESYSTEM_ACCESS: REVIEW (Override possible)            │    │
│  │  NETWORK_ACCESS: REVIEW (Override possible)               │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  3. Vulnerability Policies                                          │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  CRITICAL: BLOCK (No override)                             │    │
│  │  HIGH: REVIEW (Override possible)                         │    │
│  │  MEDIUM: REVIEW (Override possible)                       │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Decision Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DECISION FLOW                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Input: Scan Result + AI Analysis                                  │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  1. Evaluate against policies                              │    │
│  │     ├─ Check risk level                                  │    │
│  │     ├─ Check capabilities                                │    │
│  │     └─ Check vulnerabilities                            │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  2. Determine action                                      │    │
│  │     ├─ APPROVE: Continue                                 │    │
│  │     ├─ REVIEW: Manual review required                    │    │
│  │     └─ BLOCK: Stop the pipeline                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  3. Execute action                                        │    │
│  │     ├─ Notify team                                       │    │
│  │     ├─ Log decision                                      │    │
│  │     └─ Return result                                     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Policy Evaluation Example

```javascript
class PolicyEngine {
    evaluate(scanResult) {
        const decision = {
            approved: false,
            blocked: false,
            requiresReview: false,
            reasons: []
        };
        
        // Check risk level
        if (scanResult.riskLevel === 'CRITICAL') {
            decision.blocked = true;
            decision.reasons.push('Critical risk level');
        }
        
        // Check capabilities
        for (const cap of scanResult.capabilities) {
            if (cap.type === 'SHELL_EXECUTION') {
                decision.blocked = true;
                decision.reasons.push('Shell execution detected');
            }
            if (cap.type === 'FILESYSTEM_ACCESS') {
                decision.requiresReview = true;
                decision.reasons.push('Filesystem access detected');
            }
        }
        
        // Check vulnerabilities
        for (const vuln of scanResult.vulnerabilities) {
            if (vuln.severity === 'CRITICAL') {
                decision.blocked = true;
                decision.reasons.push(`Critical vulnerability: ${vuln.id}`);
            }
            if (vuln.severity === 'HIGH') {
                decision.requiresReview = true;
                decision.reasons.push(`High vulnerability: ${vuln.id}`);
            }
        }
        
        // Final decision
        if (!decision.blocked && !decision.requiresReview) {
            decision.approved = true;
        }
        
        return decision;
    }
}
```

---

### 4.4 CI/CD Integration

#### Integration Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CI/CD INTEGRATION FLOW                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Trigger Event                                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Push to branch / PR / Scheduled scan                      │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  2. Security Scan                                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Run analysis                                              │    │
│  │  Generate report                                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  3. Policy Check                                                    │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  Evaluate policies                                        │    │
│  │  Determine action                                        │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│                              ▼                                      │
│  4. Decision                                                        │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │  APPROVE → Continue                                     │    │
│  │  REVIEW → Manual intervention                           │    │
│  │  BLOCK → Fail the build                                 │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### GitHub Actions Workflow

```yaml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run security scan
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          node phase-4/ci-cd-integration.js \
            --mode ci \
            --github \
            --notify
      
      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: security-report
          path: security-report.json
```

#### Webhook Integration

```javascript
// Webhook Server
const express = require('express');
const app = express();

app.post('/webhook/security-scan', (req, res) => {
    const { scanId, results } = req.body;
    
    // Process scan results
    const decision = policyEngine.evaluate(results);
    
    // Send response
    res.json({
        status: 'processed',
        scanId,
        decision
    });
});

// Notification Service
class NotificationService {
    async sendAlert(alert) {
        // Slack
        if (this.slackWebhook) {
            await this.sendSlack(alert);
        }
        
        // Email
        if (this.emailConfig) {
            await this.sendEmail(alert);
        }
        
        // Teams
        if (this.teamsWebhook) {
            await this.sendTeams(alert);
        }
    }
}
```

---

### 4.5 Key Takeaways

#### Module 4 Summary

```
┌─────────────────────────────────────────────────────────────────────┐
│                    KEY TAKEAWAYS                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. LLM Integration                                                 │
│     → AI augments, does not replace                               │
│     → Structured outputs are essential                           │
│     → Validation is mandatory                                    │
│                                                                      │
│  2. Prompt Engineering                                              │
│     → System prompts define role and constraints                  │
│     → Task prompts describe the work                              │
│     → Output schemas ensure structure                            │
│                                                                      │
│  3. Policy Engine                                                   │
│     → AI recommends, policies decide                             │
│     → Critical issues are blocked automatically                  │
│     → Overrides require justification                           │
│                                                                      │
│  4. CI/CD Integration                                               │
│     → Security checks should be automated                        │
│     → Failing builds prevents vulnerabilities                    │
│     → Notifications keep teams informed                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Quick Reference: AI Security Rules

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AI SECURITY RULES                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. AI Advises, Humans Decide                                       │
│     → AI provides recommendations                                 │
│     → Policies make decisions                                     │
│     → Humans can override                                         │
│                                                                      │
│  2. Structured Outputs                                              │
│     → Always request JSON                                         │
│     → Validate against schema                                    │
│     → Reject malformed responses                                 │
│                                                                      │
│  3. Fallback Required                                               │
│     → If AI fails, use fallback                                 │
│     → Never let AI failure break the system                     │
│     → Log all AI interactions                                   │
│                                                                      │
│  4. Audit Trail                                                     │
│     → Log all AI prompts and responses                          │
│     → Track decision-making process                             │
│     → Enable review and debugging                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## PRIMERS SUMMARY

### Primer 1: npm Package Structure and Installation

**Key Points:**
- package.json contains metadata, scripts, dependencies
- npm install executes scripts with full permissions
- Lifecycle scripts (preinstall, install, postinstall) are high-risk
- Lock files ensure deterministic installations

**Security Checklist:**
```
[ ] Check package.json scripts before installing
[ ] Use --ignore-scripts for suspicious packages
[ ] Always check lock files for integrity
[ ] Audit dependencies with npm audit
[ ] Test packages in isolation first
```

### Primer 2: Semantic Versioning and Dependency Resolution

**Key Points:**
- SemVer: Major.Minor.Patch
- Version ranges: ^, ~, >, <, ranges
- npm resolves dependencies and handles conflicts
- Lock files pin exact versions

**Security Checklist:**
```
[ ] Pin exact versions in production
[ ] Use lock files for deterministic builds
[ ] Review version ranges carefully
[ ] Update dependencies regularly
[ ] Test version upgrades in staging
```

### Primer 3: Package Registry Security

**Key Points:**
- Registries store and distribute packages
- Authentication via tokens, 2FA
- Integrity verified via hashes
- Various attack vectors: typosquatting, dependency confusion

**Security Checklist:**
```
[ ] Use private registries for internal packages
[ ] Enable 2FA for publishing
[ ] Verify package integrity
[ ] Monitor registry activity
[ ] Reserve package names proactively
```

### Primer 4: JavaScript Security Fundamentals

**Key Points:**
- Prototype pollution: modifying Object.prototype
- XSS: injecting scripts into applications
- Command injection: executing system commands
- Path traversal: accessing files outside intended directory

**Security Checklist:**
```
[ ] Use Object.create(null) for safe objects
[ ] Escape all user input (XSS prevention)
[ ] Use execFile instead of exec for commands
[ ] Normalize and validate all file paths
[ ] Avoid eval, new Function, vm.runInNewContext
```

### Primer 5: Supply Chain Attack Patterns

**Key Points:**
- Typosquatting: similar names to popular packages
- Dependency confusion: public versions of private packages
- Malicious scripts: install-time attacks
- Version hijacking: publishing malicious versions

**Security Checklist:**
```
[ ] Detect typosquatting with similarity algorithms
[ ] Scope internal packages (@company/)
[ ] Scan for malicious install scripts
[ ] Verify integrity of installed packages
[ ] Monitor for suspicious version changes
```

---

## FINAL PROJECT CHECKLIST

### Project: Complete Security System

**Phase 1: Foundations**
- [ ] JavaScript execution model understood
- [ ] npm lifecycle understood
- [ ] Malicious script detector built
- [ ] Security scanner built

**Phase 2: Modern Dependency Risk Analysis**
- [ ] Package analyzer built
- [ ] Capability scanner built
- [ ] Socket integration completed
- [ ] Snyk integration completed

**Phase 3: Async Execution & Orchestration**
- [ ] Concurrency controller built
- [ ] Resource manager built
- [ ] Priority queue implemented
- [ ] Orchestrator built

**Phase 4: AI-Augmented Security**
- [ ] LLM service built
- [ ] Prompt templates created
- [ ] Schema validator built
- [ ] Policy engine built
- [ ] CI/CD integration completed

**Final Deliverables:**
- [ ] Complete working system
- [ ] Documentation (README)
- [ ] Test suite
- [ ] Sample reports
- [ ] Deployment guide

---

## GLOSSARY

| Term | Definition |
|------|------------|
| **AST** | Abstract Syntax Tree - a tree representation of source code |
| **CVE** | Common Vulnerabilities and Exposures - a list of publicly disclosed security vulnerabilities |
| **CVSS** | Common Vulnerability Scoring System - a framework for rating the severity of vulnerabilities |
| **Event Loop** | A mechanism that handles asynchronous operations in JavaScript |
| **Heap** | A region of memory where objects are stored |
| **Lock File** | A file that records exact versions of dependencies (e.g., package-lock.json) |
| **Microtask** | A small task that runs immediately after the current stack (e.g., Promise.then) |
| **Macrotask** | A task that runs in the event loop (e.g., setTimeout) |
| **SCA** | Software Composition Analysis - analyzing open-source dependencies |
| **SemVer** | Semantic Versioning - a versioning scheme (Major.Minor.Patch) |
| **Supply Chain** | The entire process of developing, distributing, and using software |
| **Typosquatting** | Registering names similar to popular packages |
| **Dependency Confusion** | Publishing internal package names to public registries |
| **Protestware** | Packages with political or social messages |

---

## COMMAND REFERENCE

### npm Commands

```bash
# Install packages
npm install
npm install <package>
npm install --ignore-scripts
npm install --dry-run

# Manage dependencies
npm list
npm list --depth=0
npm list --all

# Audit dependencies
npm audit
npm audit --production
npm audit fix

# View package info
npm view <package>
npm view <package> scripts
npm view <package> versions

# Update
npm update
npm outdated

# Lock files
npm install --package-lock-only
npm ci
```

### Node.js Commands

```bash
# Run scripts
node <file>.js
node --inspect <file>.js
node --trace-gc <file>.js

# Memory management
node --max-old-space-size=4096 <file>.js
node --trace-warnings <file>.js

# Profiling
node --prof <file>.js
node --cpu-prof <file>.js
node --heap-prof <file>.js
```

### System Commands

```bash
# Memory usage
free -h
top -o %MEM
ps aux --sort=-%mem | head

# CPU usage
top -o %CPU
htop
mpstat

# File handles
ulimit -n
lsof | wc -l
sudo lsof -i -n -P
```

---

## TROUBLESHOOTING REFERENCE

### Common Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| Memory Exhaustion | "JavaScript heap out of memory" | Increase heap size, reduce concurrency |
| Rate Limiting | 429 Too Many Requests | Implement backoff, cache results |
| API Key Invalid | 401 Unauthorized | Check environment variables |
| Timeout | Operation timed out | Increase timeout, optimize processing |
| Schema Error | "Validation failed" | Check AI output format |
| Duplicate Packages | Unexpected behavior | Check package.json, deduplicate |

### Debugging Techniques

```javascript
// 1. Logging
console.log(JSON.stringify(data, null, 2));

// 2. Timing
console.time('operation');
// ... code ...
console.timeEnd('operation');

// 3. Memory Usage
console.log(process.memoryUsage());

// 4. CPU Usage
console.log(os.loadavg());

// 5. Error Handling
try {
    // ... code ...
} catch (error) {
    console.error(error.stack);
}
```

---

**🎉 Course Complete!**

You now have comprehensive knowledge of software supply chain security and a complete working system. Use these notes as a reference for your ongoing security journey.
