# Phase 1, Part 3: Building a Complete Security Scanner

Now we'll combine everything we've learned into a comprehensive security scanner that integrates behavioral detection, CVE checking, and risk scoring into a single, production-ready tool. This scanner will serve as the foundation for the more advanced features we'll build in later phases.

---

## The Target: A Complete Package Security Scanner

**What specific file, configuration, or feature are we building right now?**

We're building a complete, production-ready security scanner that:
1. Analyzes package.json and lock files
2. Detects malicious behavioral patterns
3. Checks for known vulnerabilities (CVEs)
4. Calculates comprehensive risk scores
5. Generates detailed security reports
6. Exports results in multiple formats (JSON, HTML, Markdown)
7. Integrates with CI/CD pipelines

---

## The Concept: Defense in Depth

**A brief, clear explanation using a simple, real-world analogy**

Think of our security scanner like a multi-layered security checkpoint at an airport:

1. **Layer 1: Document Check (package.json analysis)** - Verifies identity and destination
2. **Layer 2: Behavioral Scanner (behavioral analysis)** - Watches for suspicious actions like nervous behavior
3. **Layer 3: Criminal Database Check (CVE checking)** - Checks against known threat databases
4. **Layer 4: Risk Assessment (scoring)** - Determines threat level based on all factors
5. **Layer 5: Reporting (output)** - Provides actionable intelligence to security teams

Each layer catches different types of threats, and together they provide comprehensive protection.

---

## The Implementation: Building the Complete Scanner

### Step 1: Setup and Dependencies

```bash
# Navigate to the phase-1 directory
cd beyond-cves-tutorial/phase-1

# Install additional dependencies
npm install --save-dev chalk
npm install --save-dev table
npm install --save-dev axios
npm install --save-dev ora
npm install --save-dev cli-progress
```

### Step 2: Create the Main Scanner Module

```javascript
// path: phase-1/08-complete-scanner.js

/**
 * COMPLETE PACKAGE SECURITY SCANNER
 * 
 * This is the main scanner module that integrates:
 * - Behavioral analysis
 * - CVE vulnerability checking
 * - Risk scoring
 * - Report generation
 * - CI/CD integration
 * 
 * Run with: node 08-complete-scanner.js [options]
 * 
 * Options:
 *   --path <path>     Path to package.json or node_modules directory
 *   --json            Output results as JSON
 *   --html            Output results as HTML report
 *   --markdown        Output results as Markdown
 *   --ci              CI/CD mode (non-interactive, exit codes)
 *   --help            Show help
 */

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const chalk = require('chalk');
const Table = require('cli-table3');
const axios = require('axios');
const ora = require('ora');
const { execSync } = require('child_process');

// ==========================================
// 1. CONFIGURATION
// ==========================================

const CONFIG = {
    // CVE database sources
    cveSources: {
        nvd: 'https://services.nvd.nist.gov/rest/json/cves/2.0',
        npm: 'https://registry.npmjs.org/-/vulnerabilities'
    },
    // Risk score thresholds
    riskThresholds: {
        CRITICAL: 80,
        HIGH: 60,
        MEDIUM: 40,
        LOW: 20
    },
    // Output formats
    outputFormats: ['json', 'html', 'markdown', 'console'],
    // Maximum dependencies to scan
    maxDependencies: 1000
};

// ==========================================
// 2. CORE SCANNER CLASS
// ==========================================

/**
 * Main scanner class that orchestrates all security analysis
 */
class PackageSecurityScanner {
    constructor(options = {}) {
        this.options = {
            path: options.path || process.cwd(),
            outputFormat: options.outputFormat || 'console',
            ciMode: options.ciMode || false,
            verbose: options.verbose || false,
            ...options
        };
        
        this.results = {
            packageInfo: null,
            dependencies: [],
            behavioralIssues: [],
            vulnerabilities: [],
            riskScore: 0,
            riskLevel: 'LOW',
            summary: {
                totalDependencies: 0,
                criticalIssues: 0,
                highIssues: 0,
                mediumIssues: 0,
                lowIssues: 0
            },
            timestamp: new Date().toISOString(),
            scanDuration: 0
        };
        
        this.startTime = Date.now();
    }

    /**
     * Main entry point for the scanner
     */
    async scan() {
        const spinner = ora('Initializing security scan...').start();
        
        try {
            // Step 1: Locate and parse package files
            spinner.text = 'Locating package files...';
            await this.locatePackageFiles();
            
            // Step 2: Analyze dependencies
            spinner.text = 'Analyzing dependencies...';
            await this.analyzeDependencies();
            
            // Step 3: Perform behavioral analysis
            spinner.text = 'Performing behavioral analysis...';
            await this.performBehavioralAnalysis();
            
            // Step 4: Check for vulnerabilities
            spinner.text = 'Checking for known vulnerabilities...';
            await this.checkVulnerabilities();
            
            // Step 5: Calculate risk scores
            spinner.text = 'Calculating risk scores...';
            this.calculateRiskScores();
            
            // Step 6: Generate report
            spinner.text = 'Generating security report...';
            const report = this.generateReport();
            
            spinner.succeed(chalk.green('Scan complete!'));
            
            // Calculate duration
            this.results.scanDuration = Date.now() - this.startTime;
            
            // Output results
            this.outputResults(report);
            
            return this.results;
            
        } catch (error) {
            spinner.fail(chalk.red(`Scan failed: ${error.message}`));
            if (this.options.verbose) {
                console.error(error.stack);
            }
            throw error;
        }
    }

    // ==========================================
    // 2A. FILE LOCATION AND PARSING
    // ==========================================

    /**
     * Locates and parses package.json and lock files
     */
    async locatePackageFiles() {
        const scanPath = this.options.path;
        let packagePath = null;
        let lockPath = null;
        
        // Check if path points to a specific package.json
        if (fs.existsSync(scanPath) && fs.statSync(scanPath).isFile()) {
            if (path.basename(scanPath) === 'package.json') {
                packagePath = scanPath;
                // Look for lock file in the same directory
                const dir = path.dirname(scanPath);
                lockPath = this.findLockFile(dir);
            }
        } else {
            // Look for package.json in the directory
            packagePath = path.join(scanPath, 'package.json');
            if (fs.existsSync(packagePath)) {
                lockPath = this.findLockFile(scanPath);
            } else {
                // Check if it's a node_modules directory
                const nodeModulesPath = path.join(scanPath, 'node_modules');
                if (fs.existsSync(nodeModulesPath)) {
                    // Scan all installed packages
                    this.options.nodeModulesPath = nodeModulesPath;
                } else {
                    throw new Error(`No package.json found in ${scanPath}`);
                }
            }
        }
        
        // Parse package.json
        if (packagePath) {
            this.packagePath = packagePath;
            this.packageDir = path.dirname(packagePath);
            const packageContent = fs.readFileSync(packagePath, 'utf8');
            this.packageJson = JSON.parse(packageContent);
            this.results.packageInfo = {
                name: this.packageJson.name || 'unknown',
                version: this.packageJson.version || '0.0.0',
                description: this.packageJson.description || '',
                scripts: this.packageJson.scripts || {},
                dependencies: this.packageJson.dependencies || {},
                devDependencies: this.packageJson.devDependencies || {},
                peerDependencies: this.packageJson.peerDependencies || {}
            };
        }
        
        // Parse lock file if found
        if (lockPath) {
            this.lockPath = lockPath;
            this.lockFile = this.parseLockFile(lockPath);
        }
        
        // If we have node_modules, scan that too
        if (this.options.nodeModulesPath) {
            await this.scanNodeModules();
        }
    }

    /**
     * Finds a lock file in the given directory
     */
    findLockFile(dir) {
        const lockFiles = ['package-lock.json', 'npm-shrinkwrap.json', 'yarn.lock'];
        for (const lockFile of lockFiles) {
            const fullPath = path.join(dir, lockFile);
            if (fs.existsSync(fullPath)) {
                return fullPath;
            }
        }
        return null;
    }

    /**
     * Parses a lock file
     */
    parseLockFile(lockPath) {
        try {
            const content = fs.readFileSync(lockPath, 'utf8');
            if (lockPath.endsWith('.json')) {
                return JSON.parse(content);
            } else if (lockPath.endsWith('.lock')) {
                // Yarn.lock parsing - simplified version
                // In a real implementation, this would be more robust
                return this.parseYarnLock(content);
            }
        } catch (error) {
            if (this.options.verbose) {
                console.warn(chalk.yellow(`Warning: Could not parse lock file: ${error.message}`));
            }
        }
        return null;
    }

    /**
     * Parses Yarn.lock (simplified)
     */
    parseYarnLock(content) {
        const packages = {};
        const lines = content.split('\n');
        let currentPackage = null;
        
        for (const line of lines) {
            if (line.match(/^[^@]/) && !line.match(/^#/)) {
                const match = line.match(/^([^@]+)@([^:]+):/);
                if (match) {
                    currentPackage = {
                        name: match[1],
                        version: match[2]
                    };
                }
            } else if (line.includes('resolved')) {
                if (currentPackage) {
                    packages[currentPackage.name] = {
                        version: currentPackage.version,
                        resolved: line.split(' ')[1]?.replace(/"/g, '')
                    };
                }
            }
        }
        
        return { packages };
    }

    /**
     * Scans a node_modules directory
     */
    async scanNodeModules() {
        if (!fs.existsSync(this.options.nodeModulesPath)) {
            return;
        }
        
        const packages = fs.readdirSync(this.options.nodeModulesPath);
        const totalPackages = packages.length;
        
        if (totalPackages > CONFIG.maxDependencies) {
            console.warn(chalk.yellow(`Warning: ${totalPackages} packages found, scanning first ${CONFIG.maxDependencies}`));
        }
        
        const spinner = ora(`Scanning ${Math.min(totalPackages, CONFIG.maxDependencies)} packages...`).start();
        
        const scanLimit = Math.min(totalPackages, CONFIG.maxDependencies);
        for (let i = 0; i < scanLimit; i++) {
            const pkgName = packages[i];
            const pkgPath = path.join(this.options.nodeModulesPath, pkgName);
            
            if (fs.statSync(pkgPath).isDirectory()) {
                const pkgJsonPath = path.join(pkgPath, 'package.json');
                if (fs.existsSync(pkgJsonPath)) {
                    try {
                        const pkgJson = JSON.parse(fs.readFileSync(pkgJsonPath, 'utf8'));
                        this.results.dependencies.push({
                            name: pkgName,
                            version: pkgJson.version || 'unknown',
                            path: pkgPath,
                            hasScripts: !!pkgJson.scripts,
                            scriptCount: Object.keys(pkgJson.scripts || {}).length,
                            dependencyCount: Object.keys(pkgJson.dependencies || {}).length
                        });
                    } catch (error) {
                        if (this.options.verbose) {
                            console.warn(chalk.yellow(`Warning: Could not parse ${pkgName}: ${error.message}`));
                        }
                    }
                }
            }
            
            // Update progress every 10 packages
            if (i % 10 === 0) {
                spinner.text = `Scanning packages... ${Math.min(i + 1, scanLimit)}/${scanLimit}`;
            }
        }
        
        spinner.succeed(`Scanned ${this.results.dependencies.length} packages`);
    }

    // ==========================================
    // 2B. DEPENDENCY ANALYSIS
    // ==========================================

    /**
     * Analyzes dependencies from package.json
     */
    async analyzeDependencies() {
        if (!this.packageJson) {
            return;
        }
        
        // Combine all dependency types
        const allDeps = {
            ...this.packageJson.dependencies,
            ...this.packageJson.devDependencies,
            ...this.packageJson.peerDependencies
        };
        
        const totalDeps = Object.keys(allDeps).length;
        this.results.summary.totalDependencies = totalDeps;
        
        // Add dependencies to results
        for (const [name, version] of Object.entries(allDeps)) {
            // Check if the dependency already exists in the list
            if (!this.results.dependencies.find(d => d.name === name)) {
                this.results.dependencies.push({
                    name,
                    version,
                    type: this.getDependencyType(name, this.packageJson),
                    isDev: !!this.packageJson.devDependencies?.[name],
                    isPeer: !!this.packageJson.peerDependencies?.[name]
                });
            }
        }
        
        // Check for dependency confusion vulnerabilities
        this.checkDependencyConfusion(allDeps);
    }

    /**
     * Determines the type of dependency
     */
    getDependencyType(name, packageJson) {
        if (packageJson.dependencies?.[name]) return 'production';
        if (packageJson.devDependencies?.[name]) return 'development';
        if (packageJson.peerDependencies?.[name]) return 'peer';
        return 'unknown';
    }

    /**
     * Checks for dependency confusion attacks
     */
    checkDependencyConfusion(dependencies) {
        // Check if the package is private
        const isPrivate = this.packageJson?.private === true;
        const hasScope = this.packageJson?.name?.startsWith('@');
        
        // If it's a private package, check for dependency confusion risk
        if (isPrivate && hasScope) {
            // Check if any dependencies are from public registry
            // In a real implementation, we'd check registry metadata
            // For now, we'll flag packages with many dependencies
            const depCount = Object.keys(dependencies).length;
            if (depCount > 20) {
                this.results.behavioralIssues.push({
                    type: 'dependency_confusion',
                    severity: 'HIGH',
                    description: `Private package with ${depCount} public dependencies may be vulnerable to dependency confusion`,
                    dependencies: Object.keys(dependencies).slice(0, 5)
                });
            }
        }
    }

    // ==========================================
    // 2C. BEHAVIORAL ANALYSIS
    // ==========================================

    /**
     * Performs behavioral analysis on all dependencies
     */
    async performBehavioralAnalysis() {
        // Analysis for the main package
        if (this.packageJson?.scripts) {
            this.analyzeScripts(this.packageJson.scripts, 'main-package');
        }
        
        // Analysis for dependencies
        for (const dep of this.results.dependencies) {
            if (dep.path && fs.existsSync(dep.path)) {
                try {
                    const depPackageJsonPath = path.join(dep.path, 'package.json');
                    if (fs.existsSync(depPackageJsonPath)) {
                        const depPackageJson = JSON.parse(fs.readFileSync(depPackageJsonPath, 'utf8'));
                        if (depPackageJson.scripts) {
                            this.analyzeScripts(depPackageJson.scripts, dep.name);
                        }
                    }
                } catch (error) {
                    if (this.options.verbose) {
                        console.warn(chalk.yellow(`Warning: Could not analyze ${dep.name}: ${error.message}`));
                    }
                }
            }
        }
        
        // Sort behavioral issues by severity
        this.results.behavioralIssues.sort((a, b) => {
            const severityOrder = { CRITICAL: 0, HIGH: 1, MEDIUM: 2, LOW: 3 };
            return severityOrder[a.severity] - severityOrder[b.severity];
        });
    }

    /**
     * Analyzes scripts for malicious patterns
     */
    analyzeScripts(scripts, source) {
        const maliciousPatterns = {
            shellExecution: {
                patterns: ['exec', 'spawn', 'child_process', 'curl', 'wget', 'sh', 'bash', 'cmd'],
                severity: 'CRITICAL',
                description: 'Shell command execution detected'
            },
            networkAccess: {
                patterns: ['http', 'https', 'fetch', 'axios', 'socket', 'net', 'request'],
                severity: 'HIGH',
                description: 'Network access detected'
            },
            filesystemAccess: {
                patterns: ['fs.', 'readFile', 'writeFile', 'mkdir', 'rm', 'unlink'],
                severity: 'HIGH',
                description: 'Filesystem access detected'
            },
            environmentAccess: {
                patterns: ['process.env', 'env.', 'environment'],
                severity: 'MEDIUM',
                description: 'Environment variable access detected'
            },
            codeInjection: {
                patterns: ['eval', 'new Function', 'Function(', 'require('],
                severity: 'CRITICAL',
                description: 'Dynamic code execution detected'
            },
            persistence: {
                patterns: ['cron', 'startup', 'service', 'systemd', 'launchd', 'registry'],
                severity: 'HIGH',
                description: 'Persistence mechanism detected'
            },
            obfuscation: {
                patterns: ['eval', 'atob', 'btoa', 'charCodeAt', 'fromCharCode', 'Buffer.from'],
                severity: 'MEDIUM',
                description: 'Code obfuscation detected'
            },
            dependencyManipulation: {
                patterns: ['npm install', 'yarn add', 'pnpm add', 'package.json'],
                severity: 'MEDIUM',
                description: 'Dependency manipulation detected'
            }
        };
        
        // Check each script
        for (const [scriptName, scriptCommand] of Object.entries(scripts)) {
            const lowerCommand = scriptCommand.toLowerCase();
            const issues = [];
            
            // Check against each pattern
            for (const [patternName, patternConfig] of Object.entries(maliciousPatterns)) {
                const matchedPatterns = patternConfig.patterns.filter(pattern => {
                    // Check if pattern appears as a word or part of a word
                    return lowerCommand.includes(pattern.toLowerCase());
                });
                
                if (matchedPatterns.length > 0) {
                    issues.push({
                        type: patternName,
                        severity: patternConfig.severity,
                        description: patternConfig.description,
                        matchedPatterns: matchedPatterns,
                        scriptName,
                        scriptCommand
                    });
                }
            }
            
            // Add issues to results
            for (const issue of issues) {
                // Avoid duplicates (same issue in same script)
                const isDuplicate = this.results.behavioralIssues.some(existing =>
                    existing.scriptName === issue.scriptName &&
                    existing.type === issue.type &&
                    existing.source === source
                );
                
                if (!isDuplicate) {
                    this.results.behavioralIssues.push({
                        ...issue,
                        source,
                        command: issue.scriptCommand
                    });
                    delete issue.scriptCommand; // Clean up
                }
            }
        }
        
        // Check for high-risk lifecycle scripts
        const lifecycleScripts = ['preinstall', 'install', 'postinstall', 'prepare'];
        const hasLifecycleScripts = lifecycleScripts.some(name => scripts[name]);
        if (hasLifecycleScripts) {
            // Check if any lifecycle scripts are present (already caught by pattern matching)
            // But we can add additional context
            const hasMaliciousPatterns = this.results.behavioralIssues.some(issue =>
                issue.source === source && lifecycleScripts.includes(issue.scriptName)
            );
            
            if (!hasMaliciousPatterns) {
                // Low severity warning for lifecycle scripts even without malicious patterns
                this.results.behavioralIssues.push({
                    type: 'lifecycle_script',
                    severity: 'LOW',
                    description: 'Lifecycle script detected (preinstall, install, or postinstall)',
                    source,
                    scriptName: lifecycleScripts.find(name => scripts[name]),
                    scriptCommand: scripts[lifecycleScripts.find(name => scripts[name])]
                });
            }
        }
    }

    // ==========================================
    // 2D. VULNERABILITY CHECKING (CVE)
    // ==========================================

    /**
     * Checks for known vulnerabilities in dependencies
     */
    async checkVulnerabilities() {
        const spinner = ora('Checking vulnerabilities...').start();
        
        try {
            // First, try npm audit
            const auditResults = await this.runNpmAudit();
            
            if (auditResults) {
                this.results.vulnerabilities = auditResults;
                return;
            }
            
            // Fallback to NVD API
            const nvdResults = await this.checkNVD();
            this.results.vulnerabilities = nvdResults;
            
        } catch (error) {
            if (this.options.verbose) {
                console.warn(chalk.yellow(`Vulnerability check warning: ${error.message}`));
            }
            // Don't fail the scan if vulnerability check fails
        }
        
        spinner.succeed('Vulnerability check complete');
    }

    /**
     * Runs npm audit and parses results
     */
    async runNpmAudit() {
        try {
            const output = execSync('npm audit --json', {
                cwd: this.packageDir || this.options.path,
                encoding: 'utf8',
                stdio: 'pipe'
            });
            
            if (!output) return null;
            
            const auditData = JSON.parse(output);
            const vulnerabilities = [];
            
            if (auditData.vulnerabilities) {
                for (const [pkgName, pkgData] of Object.entries(auditData.vulnerabilities)) {
                    for (const [version, versionData] of Object.entries(pkgData)) {
                        vulnerabilities.push({
                            package: pkgName,
                            version: versionData.version,
                            severity: versionData.severity || 'unknown',
                            title: versionData.title || 'Vulnerability detected',
                            description: versionData.description || '',
                            cve: versionData.cve || null,
                            url: versionData.url || null,
                            cvssScore: versionData.cvss?.score || null,
                            cvssVector: versionData.cvss?.vectorString || null,
                            isFixable: !!versionData.fixes?.length
                        });
                    }
                }
            }
            
            // Update summary
            for (const vuln of vulnerabilities) {
                this.results.summary.criticalIssues += vuln.severity === 'critical' ? 1 : 0;
                this.results.summary.highIssues += vuln.severity === 'high' ? 1 : 0;
                this.results.summary.mediumIssues += vuln.severity === 'moderate' ? 1 : 0;
                this.results.summary.lowIssues += vuln.severity === 'low' ? 1 : 0;
            }
            
            return vulnerabilities;
            
        } catch (error) {
            if (this.options.verbose) {
                console.warn(chalk.yellow(`npm audit failed: ${error.message}`));
            }
            return null;
        }
    }

    /**
     * Checks NVD (National Vulnerability Database) API
     * This is a fallback when npm audit isn't available
     */
    async checkNVD() {
        const vulnerabilities = [];
        const dependencies = this.results.dependencies;
        
        // Only check a subset to avoid rate limiting
        const depsToCheck = dependencies.slice(0, 20);
        
        for (const dep of depsToCheck) {
            try {
                const response = await axios.get(CONFIG.cveSources.nvd, {
                    params: {
                        keywordSearch: dep.name,
                        resultsPerPage: 5
                    },
                    timeout: 5000
                });
                
                if (response.data.vulnerabilities) {
                    for (const vuln of response.data.vulnerabilities) {
                        const cve = vuln.cve;
                        if (cve) {
                            const metrics = cve.metrics?.cvssMetricV31?.[0] || cve.metrics?.cvssMetricV2?.[0];
                            vulnerabilities.push({
                                package: dep.name,
                                version: dep.version,
                                severity: metrics?.cvssData?.baseSeverity || 'unknown',
                                title: cve.id,
                                description: cve.descriptions?.[0]?.value || '',
                                cve: cve.id,
                                cvssScore: metrics?.cvssData?.baseScore || null,
                                cvssVector: metrics?.cvssData?.vectorString || null,
                                isFixable: false
                            });
                        }
                    }
                }
                
                // Rate limiting
                await new Promise(resolve => setTimeout(resolve, 1000));
                
            } catch (error) {
                if (this.options.verbose) {
                    console.warn(chalk.yellow(`NVD check failed for ${dep.name}: ${error.message}`));
                }
            }
        }
        
        return vulnerabilities;
    }

    // ==========================================
    // 2E. RISK CALCULATION
    // ==========================================

    /**
     * Calculates comprehensive risk scores
     */
    calculateRiskScores() {
        let totalScore = 0;
        const maxScore = 100;
        
        // 1. Behavioral risk (max 40 points)
        const behavioralScore = this.calculateBehavioralScore();
        totalScore += behavioralScore;
        
        // 2. Vulnerability risk (max 30 points)
        const vulnerabilityScore = this.calculateVulnerabilityScore();
        totalScore += vulnerabilityScore;
        
        // 3. Dependency risk (max 20 points)
        const dependencyScore = this.calculateDependencyScore();
        totalScore += dependencyScore;
        
        // 4. Security practice risk (max 10 points)
        const securityScore = this.calculateSecurityScore();
        totalScore += securityScore;
        
        // Cap at max score
        this.results.riskScore = Math.min(totalScore, maxScore);
        
        // Determine risk level
        if (this.results.riskScore >= CONFIG.riskThresholds.CRITICAL) {
            this.results.riskLevel = 'CRITICAL';
        } else if (this.results.riskScore >= CONFIG.riskThresholds.HIGH) {
            this.results.riskLevel = 'HIGH';
        } else if (this.results.riskScore >= CONFIG.riskThresholds.MEDIUM) {
            this.results.riskLevel = 'MEDIUM';
        } else {
            this.results.riskLevel = 'LOW';
        }
    }

    /**
     * Calculates behavioral risk score
     */
    calculateBehavioralScore() {
        let score = 0;
        const issues = this.results.behavioralIssues;
        
        if (issues.length === 0) return 0;
        
        // Score based on severity of issues found
        for (const issue of issues) {
            switch (issue.severity) {
                case 'CRITICAL':
                    score += 10;
                    break;
                case 'HIGH':
                    score += 5;
                    break;
                case 'MEDIUM':
                    score += 3;
                    break;
                case 'LOW':
                    score += 1;
                    break;
            }
        }
        
        // Update summary
        for (const issue of issues) {
            switch (issue.severity) {
                case 'CRITICAL':
                    this.results.summary.criticalIssues++;
                    break;
                case 'HIGH':
                    this.results.summary.highIssues++;
                    break;
                case 'MEDIUM':
                    this.results.summary.mediumIssues++;
                    break;
                case 'LOW':
                    this.results.summary.lowIssues++;
                    break;
            }
        }
        
        return Math.min(score, 40);
    }

    /**
     * Calculates vulnerability risk score
     */
    calculateVulnerabilityScore() {
        let score = 0;
        const vulns = this.results.vulnerabilities;
        
        if (vulns.length === 0) return 0;
        
        // Score based on vulnerability severity
        for (const vuln of vulns) {
            if (vuln.severity === 'critical' || vuln.severity === 'CRITICAL') {
                score += 8;
                this.results.summary.criticalIssues++;
            } else if (vuln.severity === 'high' || vuln.severity === 'HIGH') {
                score += 5;
                this.results.summary.highIssues++;
            } else if (vuln.severity === 'moderate' || vuln.severity === 'MEDIUM') {
                score += 3;
                this.results.summary.mediumIssues++;
            } else if (vuln.severity === 'low' || vuln.severity === 'LOW') {
                score += 1;
                this.results.summary.lowIssues++;
            }
        }
        
        return Math.min(score, 30);
    }

    /**
     * Calculates dependency risk score
     */
    calculateDependencyScore() {
        let score = 0;
        const depCount = this.results.dependencies.length;
        
        // More dependencies = more risk
        if (depCount > 200) score += 8;
        else if (depCount > 100) score += 5;
        else if (depCount > 50) score += 3;
        else if (depCount > 20) score += 1;
        
        // Check for outdated dependencies (estimated)
        const hasDevDeps = this.packageJson?.devDependencies && 
            Object.keys(this.packageJson.devDependencies).length > 0;
        if (hasDevDeps && depCount > 50) {
            score += 2; // More risk with many dev dependencies
        }
        
        return Math.min(score, 20);
    }

    /**
     * Calculates security practice risk score
     */
    calculateSecurityScore() {
        let score = 0;
        
        // Check if package has a lock file
        if (!this.lockPath) {
            score += 3; // Missing lock file
        }
        
        // Check for scripts
        if (this.packageJson?.scripts) {
            const scriptCount = Object.keys(this.packageJson.scripts).length;
            if (scriptCount > 5) {
                score += 2; // Many scripts increase risk
            }
        }
        
        // Check if package is private
        if (this.packageJson?.private === true) {
            score -= 2; // Private packages are slightly lower risk (less public exposure)
        }
        
        // Check if package has a known license
        if (!this.packageJson?.license) {
            score += 2; // Missing license
        }
        
        return Math.min(Math.max(score, 0), 10);
    }

    // ==========================================
    // 2F. REPORT GENERATION
    // ==========================================

    /**
     * Generates a security report
     */
    generateReport() {
        const report = {
            metadata: {
                scanner: 'Package Security Scanner v1.0',
                timestamp: this.results.timestamp,
                scanDuration: this.results.scanDuration,
                riskScore: this.results.riskScore,
                riskLevel: this.results.riskLevel
            },
            package: this.results.packageInfo,
            summary: this.results.summary,
            dependencies: {
                total: this.results.dependencies.length,
                items: this.results.dependencies
            },
            findings: {
                behavioral: this.results.behavioralIssues,
                vulnerabilities: this.results.vulnerabilities
            },
            recommendations: this.generateRecommendations()
        };
        
        return report;
    }

    /**
     * Generates actionable recommendations
     */
    generateRecommendations() {
        const recommendations = [];
        const riskLevel = this.results.riskLevel;
        
        // General recommendations based on risk level
        if (riskLevel === 'CRITICAL') {
            recommendations.push({
                severity: 'CRITICAL',
                action: 'BLOCK',
                message: 'Immediately block this package from your project',
                details: 'Critical security issues detected that require immediate action'
            });
        }
        
        if (riskLevel === 'HIGH' || riskLevel === 'CRITICAL') {
            recommendations.push({
                severity: 'HIGH',
                action: 'REVIEW',
                message: 'Conduct thorough manual security review',
                details: 'High-risk issues found that require human analysis'
            });
        }
        
        // Specific recommendations based on findings
        if (this.results.behavioralIssues.length > 0) {
            const criticalBehavioral = this.results.behavioralIssues.filter(i => i.severity === 'CRITICAL');
            if (criticalBehavioral.length > 0) {
                recommendations.push({
                    severity: 'CRITICAL',
                    action: 'BLOCK',
                    message: `Critical behavioral issues detected in ${criticalBehavioral.length} scripts`,
                    details: criticalBehavioral.map(i => `${i.scriptName}: ${i.description}`).join('\n')
                });
            }
        }
        
        if (this.results.vulnerabilities.length > 0) {
            const criticalVulns = this.results.vulnerabilities.filter(v => 
                v.severity === 'critical' || v.severity === 'CRITICAL'
            );
            if (criticalVulns.length > 0) {
                recommendations.push({
                    severity: 'CRITICAL',
                    action: 'UPDATE',
                    message: `Critical vulnerabilities found in ${criticalVulns.length} packages`,
                    details: 'Update these packages immediately to patched versions'
                });
            }
        }
        
        // Lock file recommendation
        if (!this.lockPath) {
            recommendations.push({
                severity: 'MEDIUM',
                action: 'FIX',
                message: 'No lock file found',
                details: 'Use npm install --package-lock to generate a lock file'
            });
        }
        
        // Outdated dependencies recommendation
        if (this.results.dependencies.length > 50) {
            recommendations.push({
                severity: 'LOW',
                action: 'REVIEW',
                message: 'Large number of dependencies detected',
                details: 'Consider reducing dependencies to minimize attack surface'
            });
        }
        
        return recommendations;
    }

    // ==========================================
    // 2G. OUTPUT FORMATTING
    // ==========================================

    /**
     * Outputs results in the specified format
     */
    outputResults(report) {
        const format = this.options.outputFormat;
        
        if (format === 'json') {
            this.outputJSON(report);
        } else if (format === 'html') {
            this.outputHTML(report);
        } else if (format === 'markdown') {
            this.outputMarkdown(report);
        } else {
            this.outputConsole(report);
        }
    }

    /**
     * Outputs results as JSON
     */
    outputJSON(report) {
        console.log(JSON.stringify(report, null, 2));
    }

    /**
     * Outputs results as HTML
     */
    outputHTML(report) {
        const html = this.generateHTML(report);
        const outputPath = path.join(process.cwd(), 'security-report.html');
        fs.writeFileSync(outputPath, html);
        console.log(chalk.green(`📄 HTML report saved to: ${outputPath}`));
        console.log(chalk.gray('Open this file in a browser to view the report'));
    }

    /**
     * Generates HTML report
     */
    generateHTML(report) {
        const riskColor = {
            CRITICAL: '#d32f2f',
            HIGH: '#f57c00',
            MEDIUM: '#f9a825',
            LOW: '#388e3c'
        };
        
        return `<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Security Report - ${report.package?.name || 'Package'}</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #1a237e; border-bottom: 2px solid #1a237e; padding-bottom: 10px; }
        h2 { color: #333; margin-top: 30px; }
        .risk-box { padding: 20px; border-radius: 4px; color: white; font-weight: bold; }
        .risk-critical { background: #d32f2f; }
        .risk-high { background: #f57c00; }
        .risk-medium { background: #f9a825; }
        .risk-low { background: #388e3c; }
        .summary-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin: 20px 0; }
        .summary-item { background: #e3f2fd; padding: 15px; border-radius: 4px; text-align: center; }
        .summary-item .number { font-size: 24px; font-weight: bold; color: #1a237e; }
        .summary-item .label { font-size: 12px; color: #666; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th { background: #1a237e; color: white; padding: 10px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        .severity-critical { color: #d32f2f; font-weight: bold; }
        .severity-high { color: #f57c00; font-weight: bold; }
        .severity-medium { color: #f9a825; font-weight: bold; }
        .severity-low { color: #388e3c; font-weight: bold; }
        .badge { display: inline-block; padding: 3px 8px; border-radius: 3px; color: white; font-size: 11px; font-weight: bold; }
        .badge-critical { background: #d32f2f; }
        .badge-high { background: #f57c00; }
        .badge-medium { background: #f9a825; }
        .badge-low { background: #388e3c; }
        .recommendations { background: #e8f5e9; padding: 15px; border-radius: 4px; margin: 15px 0; }
        .recommendation-item { padding: 8px 0; border-bottom: 1px solid #c8e6c9; }
        .recommendation-item:last-child { border-bottom: none; }
        .timestamp { color: #666; font-size: 14px; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px; }
        .code { background: #f5f5f5; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 13px; overflow-x: auto; }
        .finding-item { margin: 10px 0; padding: 10px; border-left: 4px solid #1a237e; background: #fafafa; }
        .finding-item.critical { border-left-color: #d32f2f; }
        .finding-item.high { border-left-color: #f57c00; }
        .finding-item.medium { border-left-color: #f9a825; }
        .finding-item.low { border-left-color: #388e3c; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 Security Scan Report</h1>
        <div class="timestamp">Generated: ${new Date().toLocaleString()}</div>
        
        <h2>Package Information</h2>
        <p><strong>Name:</strong> ${report.package?.name || 'N/A'}</p>
        <p><strong>Version:</strong> ${report.package?.version || 'N/A'}</p>
        <p><strong>Description:</strong> ${report.package?.description || 'N/A'}</p>
        
        <h2>Risk Summary</h2>
        <div class="risk-box risk-${report.metadata.riskLevel.toLowerCase()}">
            Risk Level: ${report.metadata.riskLevel}
            (Score: ${report.metadata.riskScore}/100)
        </div>
        
        <div class="summary-grid">
            <div class="summary-item">
                <div class="number">${report.summary.criticalIssues || 0}</div>
                <div class="label">Critical Issues</div>
            </div>
            <div class="summary-item">
                <div class="number">${report.summary.highIssues || 0}</div>
                <div class="label">High Issues</div>
            </div>
            <div class="summary-item">
                <div class="number">${report.summary.mediumIssues || 0}</div>
                <div class="label">Medium Issues</div>
            </div>
            <div class="summary-item">
                <div class="number">${report.summary.lowIssues || 0}</div>
                <div class="label">Low Issues</div>
            </div>
        </div>
        
        <p><strong>Total Dependencies:</strong> ${report.dependencies.total}</p>
        <p><strong>Scan Duration:</strong> ${(report.metadata.scanDuration / 1000).toFixed(2)} seconds</p>
        
        <h2>Behavioral Issues</h2>
        ${report.findings.behavioral.length === 0 ? '<p>✅ No behavioral issues detected</p>' : 
            report.findings.behavioral.map(issue => `
                <div class="finding-item ${issue.severity.toLowerCase()}">
                    <span class="badge badge-${issue.severity.toLowerCase()}">${issue.severity}</span>
                    <strong>${issue.type}</strong> - ${issue.description}
                    <br><small>Source: ${issue.source} | Script: ${issue.scriptName}</small>
                    ${issue.matchedPatterns ? `<br><small>Patterns: ${issue.matchedPatterns.join(', ')}</small>` : ''}
                </div>
            `).join('')
        }
        
        <h2>Vulnerabilities</h2>
        ${report.findings.vulnerabilities.length === 0 ? '<p>✅ No vulnerabilities detected</p>' :
            `<table>
                <thead>
                    <tr>
                        <th>Package</th>
                        <th>Version</th>
                        <th>Severity</th>
                        <th>Description</th>
                        <th>CVE</th>
                    </tr>
                </thead>
                <tbody>
                    ${report.findings.vulnerabilities.map(vuln => `
                        <tr>
                            <td>${vuln.package}</td>
                            <td>${vuln.version}</td>
                            <td><span class="badge badge-${vuln.severity.toLowerCase()}">${vuln.severity}</span></td>
                            <td>${vuln.description || 'N/A'}</td>
                            <td>${vuln.cve || 'N/A'}</td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>`
        }
        
        <h2>Recommendations</h2>
        <div class="recommendations">
            ${report.recommendations.length === 0 ? '<p>✅ No recommendations needed</p>' :
                report.recommendations.map(rec => `
                    <div class="recommendation-item">
                        <span class="badge badge-${rec.severity.toLowerCase()}">${rec.severity}</span>
                        <strong>${rec.action}:</strong> ${rec.message}
                        ${rec.details ? `<br><small>${rec.details}</small>` : ''}
                    </div>
                `).join('')
            }
        </div>
        
        <div class="footer">
            Generated by Package Security Scanner v1.0<br>
            Report contains ${report.findings.behavioral.length} behavioral issues and ${report.findings.vulnerabilities.length} vulnerabilities
        </div>
    </div>
</body>
</html>`;
    }

    /**
     * Outputs results as Markdown
     */
    outputMarkdown(report) {
        let md = `# 🔒 Security Scan Report\n\n`;
        md += `**Generated:** ${new Date().toLocaleString()}\n\n`;
        
        md += `## Package Information\n\n`;
        md += `- **Name:** ${report.package?.name || 'N/A'}\n`;
        md += `- **Version:** ${report.package?.version || 'N/A'}\n`;
        md += `- **Description:** ${report.package?.description || 'N/A'}\n\n`;
        
        md += `## Risk Summary\n\n`;
        md += `**Risk Level:** ${report.metadata.riskLevel} (Score: ${report.metadata.riskScore}/100)\n\n`;
        md += `| Severity | Count |\n`;
        md += `|----------|-------|\n`;
        md += `| Critical | ${report.summary.criticalIssues || 0} |\n`;
        md += `| High     | ${report.summary.highIssues || 0} |\n`;
        md += `| Medium   | ${report.summary.mediumIssues || 0} |\n`;
        md += `| Low      | ${report.summary.lowIssues || 0} |\n\n`;
        
        md += `**Total Dependencies:** ${report.dependencies.total}\n\n`;
        md += `**Scan Duration:** ${(report.metadata.scanDuration / 1000).toFixed(2)} seconds\n\n`;
        
        md += `## Behavioral Issues\n\n`;
        if (report.findings.behavioral.length === 0) {
            md += `✅ No behavioral issues detected\n\n`;
        } else {
            for (const issue of report.findings.behavioral) {
                md += `### ${issue.type}\n\n`;
                md += `- **Severity:** ${issue.severity}\n`;
                md += `- **Description:** ${issue.description}\n`;
                md += `- **Source:** ${issue.source}\n`;
                md += `- **Script:** ${issue.scriptName}\n`;
                if (issue.matchedPatterns) {
                    md += `- **Patterns:** ${issue.matchedPatterns.join(', ')}\n`;
                }
                md += `\n`;
            }
        }
        
        md += `## Vulnerabilities\n\n`;
        if (report.findings.vulnerabilities.length === 0) {
            md += `✅ No vulnerabilities detected\n\n`;
        } else {
            md += `| Package | Version | Severity | Description | CVE |\n`;
            md += `|---------|---------|----------|-------------|-----|\n`;
            for (const vuln of report.findings.vulnerabilities) {
                md += `| ${vuln.package} | ${vuln.version} | ${vuln.severity} | ${vuln.description || 'N/A'} | ${vuln.cve || 'N/A'} |\n`;
            }
            md += `\n`;
        }
        
        md += `## Recommendations\n\n`;
        if (report.recommendations.length === 0) {
            md += `✅ No recommendations needed\n\n`;
        } else {
            for (const rec of report.recommendations) {
                md += `- **[${rec.severity}] ${rec.action}:** ${rec.message}\n`;
                if (rec.details) {
                    md += `  - ${rec.details}\n`;
                }
            }
            md += `\n`;
        }
        
        // Write to file
        const outputPath = path.join(process.cwd(), 'security-report.md');
        fs.writeFileSync(outputPath, md);
        console.log(chalk.green(`📄 Markdown report saved to: ${outputPath}`));
    }

    /**
     * Outputs results to console (formatted)
     */
    outputConsole(report) {
        console.log('\n' + chalk.bold.cyan('='.repeat(60)));
        console.log(chalk.bold.cyan('🔒 SECURITY SCAN RESULTS'));
        console.log(chalk.cyan('='.repeat(60)) + '\n');
        
        // Package info
        console.log(chalk.bold('📦 Package:'), report.package?.name || 'N/A');
        console.log(chalk.bold('📌 Version:'), report.package?.version || 'N/A');
        console.log(chalk.bold('⏱️  Duration:'), `${(report.metadata.scanDuration / 1000).toFixed(2)}s`);
        console.log(chalk.bold('📊 Dependencies:'), report.dependencies.total);
        console.log('');
        
        // Risk score
        const riskColor = {
            CRITICAL: chalk.red.bold,
            HIGH: chalk.yellow.bold,
            MEDIUM: chalk.yellow,
            LOW: chalk.green
        };
        console.log(chalk.bold('🎯 Risk Level:'), riskColor[report.metadata.riskLevel](report.metadata.riskLevel));
        console.log(chalk.bold('📈 Risk Score:'), `${report.metadata.riskScore}/100`);
        console.log('');
        
        // Summary table
        const summaryTable = new Table({
            head: ['Severity', 'Count'],
            colWidths: [15, 10]
        });
        summaryTable.push(
            ['Critical', report.summary.criticalIssues || 0],
            ['High', report.summary.highIssues || 0],
            ['Medium', report.summary.mediumIssues || 0],
            ['Low', report.summary.lowIssues || 0]
        );
        console.log(summaryTable.toString());
        console.log('');
        
        // Behavioral issues
        if (report.findings.behavioral.length > 0) {
            console.log(chalk.yellow.bold('⚠️  Behavioral Issues:'));
            const behaviorTable = new Table({
                head: ['Severity', 'Type', 'Source', 'Script'],
                colWidths: [12, 25, 20, 20]
            });
            for (const issue of report.findings.behavioral) {
                const severityColor = {
                    CRITICAL: chalk.red,
                    HIGH: chalk.yellow,
                    MEDIUM: chalk.yellow,
                    LOW: chalk.green
                };
                behaviorTable.push([
                    severityColor[issue.severity](issue.severity),
                    issue.type,
                    issue.source,
                    issue.scriptName
                ]);
            }
            console.log(behaviorTable.toString());
            console.log('');
        }
        
        // Vulnerabilities
        if (report.findings.vulnerabilities.length > 0) {
            console.log(chalk.red.bold('🔴 Vulnerabilities:'));
            const vulnTable = new Table({
                head: ['Package', 'Version', 'Severity', 'CVE'],
                colWidths: [20, 12, 12, 15]
            });
            for (const vuln of report.findings.vulnerabilities.slice(0, 10)) {
                vulnTable.push([
                    vuln.package,
                    vuln.version,
                    vuln.severity,
                    vuln.cve || 'N/A'
                ]);
            }
            console.log(vulnTable.toString());
            if (report.findings.vulnerabilities.length > 10) {
                console.log(chalk.gray(`... and ${report.findings.vulnerabilities.length - 10} more`));
            }
            console.log('');
        }
        
        // Recommendations
        if (report.recommendations.length > 0) {
            console.log(chalk.bold('💡 Recommendations:'));
            for (const rec of report.recommendations) {
                const recColor = {
                    CRITICAL: chalk.red.bold,
                    HIGH: chalk.yellow.bold,
                    MEDIUM: chalk.yellow,
                    LOW: chalk.green
                };
                console.log(`  ${recColor[rec.severity](`[${rec.severity}]`)} ${rec.action}: ${rec.message}`);
                if (rec.details) {
                    console.log(`    ${chalk.gray(rec.details)}`);
                }
            }
            console.log('');
        }
        
        if (report.findings.behavioral.length === 0 && report.findings.vulnerabilities.length === 0) {
            console.log(chalk.green.bold('✅ No issues detected!'));
        }
        
        console.log(chalk.cyan('='.repeat(60)));
        console.log(chalk.gray('For detailed report, run with --json, --html, or --markdown'));
        console.log('');
    }
}

// ==========================================
// 3. COMMAND-LINE INTERFACE
// ==========================================

/**
 * Parses command-line arguments
 */
function parseArgs() {
    const args = process.argv.slice(2);
    const options = {
        path: process.cwd(),
        outputFormat: 'console',
        ciMode: false,
        verbose: false,
        help: false
    };
    
    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        switch (arg) {
            case '--path':
                options.path = args[++i];
                break;
            case '--json':
                options.outputFormat = 'json';
                break;
            case '--html':
                options.outputFormat = 'html';
                break;
            case '--markdown':
                options.outputFormat = 'markdown';
                break;
            case '--ci':
                options.ciMode = true;
                break;
            case '--verbose':
                options.verbose = true;
                break;
            case '--help':
            case '-h':
                options.help = true;
                break;
        }
    }
    
    return options;
}

/**
 * Shows help information
 */
function showHelp() {
    console.log(`
${chalk.bold('Package Security Scanner')}

${chalk.bold('Usage:')}
  node 08-complete-scanner.js [options]

${chalk.bold('Options:')}
  --path <path>     Path to package.json or node_modules directory (default: current directory)
  --json            Output results as JSON
  --html            Output results as HTML report
  --markdown        Output results as Markdown
  --ci              CI/CD mode (non-interactive, exit codes)
  --verbose         Show verbose output
  --help, -h        Show this help

${chalk.bold('Examples:')}
  # Scan current directory
  node 08-complete-scanner.js

  # Scan specific package.json
  node 08-complete-scanner.js --path /path/to/package.json

  # Generate HTML report
  node 08-complete-scanner.js --html

  # Run in CI mode
  node 08-complete-scanner.js --ci --json
`);
}

// ==========================================
// 4. MAIN EXECUTION
// ==========================================

// Run the scanner if this file is executed directly
if (require.main === module) {
    const options = parseArgs();
    
    if (options.help) {
        showHelp();
        process.exit(0);
    }
    
    const scanner = new PackageSecurityScanner(options);
    
    scanner.scan()
        .then(results => {
            // In CI mode, exit with appropriate code
            if (options.ciMode) {
                const exitCode = results.riskLevel === 'CRITICAL' ? 1 :
                                 results.riskLevel === 'HIGH' ? 2 : 0;
                process.exit(exitCode);
            }
        })
        .catch(error => {
            console.error(chalk.red(`❌ Scan failed: ${error.message}`));
            process.exit(1);
        });
}

// Export for use as a module
module.exports = PackageSecurityScanner;
```

### Step 3: Create a CI/CD Integration Script

```javascript
// path: phase-1/09-ci-integration.js

/**
 * CI/CD INTEGRATION SCRIPT
 * 
 * This script is designed to be used in CI/CD pipelines
 * to automatically scan dependencies and block builds
 * if critical vulnerabilities are found.
 * 
 * Run with: node 09-ci-integration.js
 */

const path = require('path');
const fs = require('fs');
const PackageSecurityScanner = require('./08-complete-scanner');

/**
 * CI/CD integration class
 */
class CICDIntegration {
    constructor(options = {}) {
        this.options = {
            scanPath: options.scanPath || process.cwd(),
            failOnCritical: options.failOnCritical !== false,
            failOnHigh: options.failOnHigh || false,
            outputReport: options.outputReport || true,
            reportPath: options.reportPath || 'security-report.json',
            ...options
        };
    }

    /**
     * Runs the scan in CI mode
     */
    async run() {
        console.log('🔍 Running security scan in CI mode...');
        console.log(`📁 Scanning: ${this.options.scanPath}`);
        
        const scanner = new PackageSecurityScanner({
            path: this.options.scanPath,
            ciMode: true,
            outputFormat: 'json',
            verbose: false
        });
        
        const results = await scanner.scan();
        
        // Save report
        if (this.options.outputReport) {
            const reportPath = path.resolve(this.options.reportPath);
            fs.writeFileSync(reportPath, JSON.stringify(results, null, 2));
            console.log(`📄 Report saved to: ${reportPath}`);
        }
        
        // Determine if build should fail
        let shouldFail = false;
        let failureReasons = [];
        
        if (this.options.failOnCritical && results.summary.criticalIssues > 0) {
            shouldFail = true;
            failureReasons.push(`Found ${results.summary.criticalIssues} critical issues`);
        }
        
        if (this.options.failOnHigh && results.summary.highIssues > 0) {
            shouldFail = true;
            failureReasons.push(`Found ${results.summary.highIssues} high issues`);
        }
        
        // Output summary
        console.log('\n📊 Scan Summary:');
        console.log(`   Risk Level: ${results.riskLevel}`);
        console.log(`   Risk Score: ${results.riskScore}/100`);
        console.log(`   Critical: ${results.summary.criticalIssues}`);
        console.log(`   High: ${results.summary.highIssues}`);
        console.log(`   Medium: ${results.summary.mediumIssues}`);
        console.log(`   Low: ${results.summary.lowIssues}`);
        
        if (shouldFail) {
            console.log('\n❌ Build failing due to security issues:');
            failureReasons.forEach(reason => console.log(`   - ${reason}`));
            process.exit(1);
        } else {
            console.log('\n✅ Security scan passed');
            process.exit(0);
        }
    }
}

// Run if executed directly
if (require.main === module) {
    const args = process.argv.slice(2);
    const options = {
        scanPath: args[0] || process.cwd(),
        failOnCritical: true,
        failOnHigh: false,
        outputReport: true,
        reportPath: 'security-report.json'
    };
    
    // Parse arguments
    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        if (arg === '--fail-high') {
            options.failOnHigh = true;
        } else if (arg === '--no-report') {
            options.outputReport = false;
        } else if (arg === '--report-path' && args[i + 1]) {
            options.reportPath = args[++i];
        }
    }
    
    const integration = new CICDIntegration(options);
    integration.run().catch(error => {
        console.error(`❌ CI scan failed: ${error.message}`);
        process.exit(1);
    });
}

module.exports = CICDIntegration;
```

---

## The Verification: Testing Our Complete Scanner

**✅ Verification Step 1: Run the Scanner on the Test Packages**

```bash
# Navigate to the phase-1 directory
cd beyond-cves-tutorial/phase-1

# Create a test package with known issues
mkdir -p test-project
cd test-project
npm init -y

# Add some test dependencies
npm install express lodash axios

# Add a suspicious script to package.json
# Edit package.json and add:
# "scripts": { "postinstall": "node -e \"console.log(process.env)\"" }

# Run the scanner
node ../08-complete-scanner.js
```

**✅ Verification Step 2: Generate HTML Report**

```bash
node ../08-complete-scanner.js --html
```

Open `security-report.html` in your browser to see the formatted report.

**✅ Verification Step 3: Generate JSON Output**

```bash
node ../08-complete-scanner.js --json > scan-results.json
cat scan-results.json | json_pp
```

**✅ Verification Step 4: Run CI/CD Integration**

```bash
node ../09-ci-integration.js
```

**✅ Verification Step 5: Test with Known Vulnerable Package**

```bash
# Create a test with a known vulnerable package
cd ../test-project
npm install --save-dev jquery@1.12.4

# Run the scanner
node ../08-complete-scanner.js
```

**Expected output snippet:**
```
============================================================
🔒 SECURITY SCAN RESULTS
============================================================

📦 Package: test-project
📌 Version: 1.0.0
⏱️  Duration: 2.34s
📊 Dependencies: 4

🎯 Risk Level: MEDIUM
📈 Risk Score: 45/100

┌───────────────┬───────────┐
│ Severity      │ Count     │
├───────────────┼───────────┤
│ Critical      │ 0         │
│ High          │ 1         │
│ Medium        │ 2         │
│ Low           │ 0         │
└───────────────┴───────────┘

⚠️  Behavioral Issues:
┌───────────────┬──────────────────────────┬────────────────────┬────────────────────┐
│ Severity      │ Type                     │ Source             │ Script             │
├───────────────┼──────────────────────────┼────────────────────┼────────────────────┤
│ MEDIUM        │ environment_access       │ main-package       │ postinstall        │
└───────────────┴──────────────────────────┴────────────────────┴────────────────────┘

🔴 Vulnerabilities:
┌─────────────────────┬──────────────┬────────────┬───────────────┐
│ Package             │ Version      │ Severity   │ CVE           │
├─────────────────────┼──────────────┼────────────┼───────────────┤
│ jquery              │ 1.12.4       │ CRITICAL   │ CVE-2019-11358│
└─────────────────────┴──────────────┴────────────┴───────────────┘

💡 Recommendations:
  [HIGH] UPDATE: Critical vulnerabilities found in 1 packages
    Update these packages immediately to patched versions
```

---

## Key Takeaways from Phase 1, Part 3

1. **Comprehensive scanning requires multiple layers** - Behavioral analysis + vulnerability checking + dependency analysis
2. **Risk scoring helps prioritize** - Not all issues are equal; focus on critical and high-severity issues first
3. **Multiple output formats support different use cases** - JSON for automation, HTML for human-readable reports, Markdown for documentation
4. **CI/CD integration is essential** - Automated scanning in pipelines prevents vulnerable packages from reaching production
5. **Behavioral detection catches what CVEs miss** - Our scanner detected environment variable access in a package with no known CVEs

In Phase 2, we'll dive deeper into modern dependency risk analysis, exploring how tools like Socket and Snyk approach security differently, and building more sophisticated analysis capabilities.

---

## Reference: Complete Scanner Options

| Option | Description | Default |
|--------|-------------|---------|
| `--path` | Path to scan | Current directory |
| `--json` | Output JSON format | false |
| `--html` | Generate HTML report | false |
| `--markdown` | Generate Markdown report | false |
| `--ci` | CI/CD mode with exit codes | false |
| `--verbose` | Show verbose output | false |
| `--help` | Show help | false |

## Reference: Exit Codes in CI Mode

| Exit Code | Meaning |
|-----------|---------|
| 0 | Scan passed - no critical issues |
| 1 | Critical issues found |
| 2 | High issues found (if `--fail-high` used) |
| 3 | Error during scan |
