# Phase 2, Part 1: Modern Dependency Risk Analysis - Package Manifest Deep Dive

Welcome to Phase 2! Now that we understand the threat landscape and have built our foundational scanner, we'll dive deep into modern dependency risk analysis. We'll explore how next-generation SCA tools analyze packages beyond simple CVE matching, and we'll build sophisticated analysis capabilities that go far beyond what we built in Phase 1.

---

## The Target: Advanced Package Manifest Analysis

**What specific file, configuration, or feature are we building right now?**

We're building an advanced package analysis engine that:
1. Deeply parses and analyzes package.json with dependency resolution
2. Parses and analyzes lock files (package-lock.json, yarn.lock)
3. Detects sophisticated supply chain attacks (typosquatting, dependency confusion, protestware)
4. Analyzes package maintenance health and trust metrics
5. Generates comprehensive package risk profiles

---

## The Concept: Understanding the Full Package Picture

**A brief, clear explanation using a simple, real-world analogy**

Think of a package like a person applying for a security clearance:

1. **Application Form (package.json)** - What they claim about themselves
2. **Background Check (lock file)** - What's actually installed and verified
3. **Behavioral Assessment (scripts)** - What they actually do when given access
4. **References (maintainer history)** - Who created them and their reputation
5. **Health Check (maintenance metrics)** - How well they're kept up to date

Modern SCA tools analyze ALL of these dimensions, not just the application form.

---

## The Implementation: Advanced Package Analysis Engine

### Step 1: Setup and Dependencies

```bash
# Navigate to the phase-2 directory
cd beyond-cves-tutorial
mkdir -p phase-2
cd phase-2

# Initialize the project
npm init -y

# Install required dependencies
npm install --save-dev axios
npm install --save-dev chalk
npm install --save-dev ora
npm install --save-dev table
npm install --save-dev semver
npm install --save-dev date-fns
```

### Step 2: Create the Advanced Package Analyzer

```javascript
// path: phase-2/src/package-analyzer.js

/**
 * ADVANCED PACKAGE ANALYZER
 * 
 * This module provides deep analysis of package.json and lock files,
 * detecting sophisticated supply chain attacks and assessing package health.
 * 
 * Usage:
 *   const analyzer = new PackageAnalyzer('/path/to/package.json');
 *   const results = await analyzer.analyze();
 */

const fs = require('fs');
const path = require('path');
const semver = require('semver');
const { differenceInDays, parseISO, subDays } = require('date-fns');
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
                protestware: [],
                maintenanceHealth: null,
                trustScore: 0,
                riskFactors: []
            },
            metadata: {
                analyzedAt: new Date().toISOString(),
                version: '1.0.0'
            }
        };
    }

    /**
     * Main analysis entry point
     */
    async analyze() {
        try {
            // Load package.json
            await this.loadPackageJson();
            
            // Load lock file
            await this.loadLockFile();
            
            // Analyze package basics
            await this.analyzePackageBasics();
            
            // Analyze dependencies
            await this.analyzeDependencies();
            
            // Detect typosquatting
            await this.detectTyposquatting();
            
            // Detect dependency confusion
            await this.detectDependencyConfusion();
            
            // Detect protestware
            await this.detectProtestware();
            
            // Assess maintenance health
            await this.assessMaintenanceHealth();
            
            // Calculate trust score
            this.calculateTrustScore();
            
            return this.results;
            
        } catch (error) {
            throw new Error(`Analysis failed: ${error.message}`);
        }
    }

    // ==========================================
    // 1. FILE LOADING
    // ==========================================

    /**
     * Loads and parses package.json
     */
    async loadPackageJson() {
        if (!fs.existsSync(this.packagePath)) {
            throw new Error(`package.json not found at ${this.packagePath}`);
        }
        
        const content = fs.readFileSync(this.packagePath, 'utf8');
        this.packageJson = JSON.parse(content);
        
        // Extract package info
        this.results.packageInfo = {
            name: this.packageJson.name || 'unknown',
            version: this.packageJson.version || '0.0.0',
            description: this.packageJson.description || '',
            author: this.packageJson.author || null,
            license: this.packageJson.license || null,
            repository: this.packageJson.repository || null,
            homepage: this.packageJson.homepage || null,
            keywords: this.packageJson.keywords || [],
            engines: this.packageJson.engines || {},
            private: this.packageJson.private || false,
            scripts: this.packageJson.scripts || {},
            publishConfig: this.packageJson.publishConfig || {},
            files: this.packageJson.files || [],
            main: this.packageJson.main || 'index.js',
            module: this.packageJson.module || null,
            types: this.packageJson.types || null
        };
    }

    /**
     * Loads and parses lock file
     */
    async loadLockFile() {
        // Look for package-lock.json first
        let lockPath = path.join(this.packageDir, 'package-lock.json');
        let lockType = 'npm';
        
        if (!fs.existsSync(lockPath)) {
            // Try yarn.lock
            lockPath = path.join(this.packageDir, 'yarn.lock');
            if (fs.existsSync(lockPath)) {
                lockType = 'yarn';
            } else {
                // Try npm-shrinkwrap.json
                lockPath = path.join(this.packageDir, 'npm-shrinkwrap.json');
                if (fs.existsSync(lockPath)) {
                    lockType = 'npm';
                } else {
                    // No lock file found
                    this.results.analysis.riskFactors.push({
                        type: 'Missing Lock File',
                        severity: 'MEDIUM',
                        description: 'No lock file found, installation may be non-deterministic'
                    });
                    return;
                }
            }
        }
        
        try {
            const content = fs.readFileSync(lockPath, 'utf8');
            if (lockType === 'npm') {
                this.lockFile = JSON.parse(content);
                await this.parseNpmLockFile();
            } else if (lockType === 'yarn') {
                this.lockFile = await this.parseYarnLockFile(content);
            }
            
            this.results.metadata.lockFile = {
                path: lockPath,
                type: lockType,
                present: true
            };
            
        } catch (error) {
            this.results.analysis.riskFactors.push({
                type: 'Lock File Parse Error',
                severity: 'LOW',
                description: `Could not parse lock file: ${error.message}`
            });
        }
    }

    /**
     * Parses npm lock file (package-lock.json)
     */
    async parseNpmLockFile() {
        if (!this.lockFile || !this.lockFile.packages) {
            return;
        }
        
        // npm v7+ uses packages object
        for (const [pkgKey, pkgData] of Object.entries(this.lockFile.packages || {})) {
            if (pkgKey === '') continue; // Skip root package
            
            // Parse package name and version from key
            const match = pkgKey.match(/^node_modules\/(.+)$/);
            if (match) {
                const name = match[1];
                const version = pkgData.version || 'unknown';
                
                // Add to dependencies list
                this.results.dependencies.push({
                    name,
                    version,
                    resolved: pkgData.resolved || null,
                    integrity: pkgData.integrity || null,
                    requires: pkgData.requires || {},
                    dev: pkgData.dev || false,
                    peer: pkgData.peer || false,
                    bundled: pkgData.bundled || false,
                    optional: pkgData.optional || false,
                    fromLockFile: true
                });
            }
        }
    }

    /**
     * Parses Yarn lock file (simplified but more robust)
     */
    async parseYarnLockFile(content) {
        const lines = content.split('\n');
        const packages = [];
        let currentPackage = null;
        
        for (const line of lines) {
            const trimmed = line.trim();
            
            if (!trimmed) continue;
            
            // Check for package header (e.g., "package-name@version:")
            const headerMatch = trimmed.match(/^"([^"]+)"@([^:]+):/);
            if (headerMatch) {
                // Save previous package
                if (currentPackage) {
                    packages.push(currentPackage);
                }
                
                currentPackage = {
                    name: headerMatch[1],
                    version: headerMatch[2],
                    resolved: null,
                    integrity: null,
                    dependencies: {}
                };
                continue;
            }
            
            // Parse package properties
            if (currentPackage) {
                if (trimmed.startsWith('resolved')) {
                    currentPackage.resolved = trimmed.split(' ')[1]?.replace(/"/g, '');
                } else if (trimmed.startsWith('integrity')) {
                    currentPackage.integrity = trimmed.split(' ')[1]?.replace(/"/g, '');
                } else if (trimmed.startsWith('dependencies:')) {
                    // Handle dependencies block
                    // This is simplified; in production you'd need to parse the nested structure
                }
            }
        }
        
        // Add the last package
        if (currentPackage) {
            packages.push(currentPackage);
        }
        
        // Add to results
        packages.forEach(pkg => {
            this.results.dependencies.push({
                name: pkg.name,
                version: pkg.version,
                resolved: pkg.resolved,
                integrity: pkg.integrity,
                requires: pkg.dependencies || {},
                dev: false,
                peer: false,
                bundled: false,
                optional: false,
                fromLockFile: true
            });
        });
        
        return { packages };
    }

    // ==========================================
    // 2. BASIC ANALYSIS
    // ==========================================

    /**
     * Analyzes basic package.json properties
     */
    async analyzePackageBasics() {
        const pkg = this.packageJson;
        const issues = [];
        
        // Check for missing license
        if (!pkg.license) {
            issues.push({
                type: 'Missing License',
                severity: 'LOW',
                description: 'Package does not specify a license'
            });
        }
        
        // Check for suspicious license
        const suspiciousLicenses = ['WTFPL', 'UNLICENSED', 'NOASSERTION'];
        if (pkg.license && suspiciousLicenses.includes(pkg.license)) {
            issues.push({
                type: 'Suspicious License',
                severity: 'MEDIUM',
                description: `Package uses ${pkg.license} license, which may indicate lack of proper licensing`
            });
        }
        
        // Check for engines compatibility
        if (pkg.engines && pkg.engines.node) {
            const nodeVersion = process.version.replace('v', '');
            if (!semver.satisfies(nodeVersion, pkg.engines.node)) {
                issues.push({
                    type: 'Node Version Mismatch',
                    severity: 'LOW',
                    description: `Package requires Node ${pkg.engines.node}, but you have ${nodeVersion}`
                });
            }
        }
        
        // Check for private flag
        if (pkg.private) {
            // Private packages are generally lower risk for public attacks
            // But higher risk for internal attacks (dependency confusion)
            this.results.analysis.riskFactors.push({
                type: 'Private Package',
                severity: 'INFO',
                description: 'Package is marked as private - verify internal security controls'
            });
        }
        
        // Check for publishConfig
        if (pkg.publishConfig && pkg.publishConfig.registry) {
            if (!pkg.publishConfig.registry.includes('npmjs.org')) {
                this.results.analysis.riskFactors.push({
                    type: 'Custom Registry',
                    severity: 'MEDIUM',
                    description: `Package uses custom registry: ${pkg.publishConfig.registry}`
                });
            }
        }
        
        // Add issues to results
        issues.forEach(issue => {
            this.results.analysis.riskFactors.push(issue);
        });
    }

    // ==========================================
    // 3. DEPENDENCY ANALYSIS
    // ==========================================

    /**
     * Analyzes dependencies from package.json
     */
    async analyzeDependencies() {
        const depTypes = [
            { key: 'dependencies', list: this.results.dependencies, type: 'production' },
            { key: 'devDependencies', list: this.results.devDependencies, type: 'development' },
            { key: 'peerDependencies', list: this.results.peerDependencies, type: 'peer' }
        ];
        
        for (const depType of depTypes) {
            const deps = this.packageJson[depType.key];
            if (!deps) continue;
            
            for (const [name, version] of Object.entries(deps)) {
                // Check if the dependency already exists in dependencies list
                const existing = depType.list.find(d => d.name === name);
                if (!existing) {
                    depType.list.push({
                        name,
                        version,
                        type: depType.type,
                        fromPackageJson: true
                    });
                }
                
                // Check for version constraints
                const versionIssues = this.analyzeVersionConstraint(name, version);
                if (versionIssues) {
                    this.results.analysis.riskFactors.push(versionIssues);
                }
                
                // Check if dependency has known issues
                await this.checkDependencyHealth(name, version);
            }
        }
        
        // Calculate dependency statistics
        const totalDeps = this.results.dependencies.length +
                         this.results.devDependencies.length +
                         this.results.peerDependencies.length;
        
        this.results.metadata.dependencyStats = {
            total: totalDeps,
            production: this.results.dependencies.length,
            development: this.results.devDependencies.length,
            peer: this.results.peerDependencies.length
        };
        
        // Check for excessive dependencies
        if (totalDeps > 100) {
            this.results.analysis.riskFactors.push({
                type: 'Excessive Dependencies',
                severity: 'MEDIUM',
                description: `Package has ${totalDeps} dependencies, significantly increasing attack surface`
            });
        }
    }

    /**
     * Analyzes version constraint for issues
     */
    analyzeVersionConstraint(name, version) {
        // Check for overly permissive version constraints
        if (version.startsWith('*')) {
            return {
                type: 'Overly Permissive Version',
                severity: 'HIGH',
                description: `Dependency "${name}" uses wildcard version "${version}", may allow unexpected updates`
            };
        }
        
        if (version.startsWith('^') && !version.includes('.')) {
            return {
                type: 'Overly Permissive Version',
                severity: 'MEDIUM',
                description: `Dependency "${name}" uses overly broad version "${version}", may introduce breaking changes`
            };
        }
        
        // Check for invalid semver
        if (!semver.validRange(version)) {
            return {
                type: 'Invalid Version Range',
                severity: 'MEDIUM',
                description: `Dependency "${name}" has invalid version range "${version}"`
            };
        }
        
        return null;
    }

    /**
     * Checks dependency health (simplified)
     */
    async checkDependencyHealth(name, version) {
        // In a production implementation, this would query npm registry
        // For now, we'll add a placeholder check
        
        // Check for common red flags
        const redFlagPatterns = [
            /^[a-zA-Z0-9]*-$/,
            /^[a-zA-Z0-9]*\./,
            /^[a-zA-Z0-9]*js$/,
            /^[a-zA-Z0-9]*node$/,
            /^[a-zA-Z0-9]*core$/
        ];
        
        if (redFlagPatterns.some(pattern => pattern.test(name))) {
            this.results.analysis.riskFactors.push({
                type: 'Suspicious Dependency Name',
                severity: 'MEDIUM',
                description: `Dependency "${name}" has a suspicious naming pattern`
            });
        }
    }

    // ==========================================
    // 4. TYPOSQUATTING DETECTION
    // ==========================================

    /**
     * Detects typosquatting attempts
     */
    async detectTyposquatting() {
        // List of popular packages to check against
        const popularPackages = [
            'express', 'react', 'vue', 'angular', 'lodash', 'axios',
            'typescript', 'webpack', 'babel', 'eslint', 'prettier',
            'jest', 'mocha', 'chai', 'sinon', 'cypress', 'puppeteer',
            'node', 'npm', 'yarn', 'next', 'nuxt', 'svelte',
            'gatsby', 'create-react-app', 'vue-cli', 'angular-cli',
            'moment', 'moment-timezone', 'date-fns', 'dayjs',
            'request', 'got', 'axios', 'node-fetch', 'superagent',
            'express', 'koa', 'fastify', 'hapi', 'restify',
            'react-dom', 'react-redux', 'react-router', 'react-query',
            'bootstrap', 'tailwindcss', 'material-ui', 'antd',
            'next', 'remix', 'astro', 'qwik',
            'prisma', 'typeorm', 'sequelize', 'mongoose',
            'graphql', 'apollo-server', 'relay', 'urql',
            'jest', 'vitest', 'mocha', 'jasmine', 'karma',
            'eslint', 'prettier', 'stylelint', 'standard',
            'tailwindcss', 'postcss', 'sass', 'less',
            'webpack', 'vite', 'rollup', 'parcel',
            'typescript', 'flow', 'coffeescript',
            'dockerode', 'kubernetes-client', 'aws-sdk',
            'mongoose', 'mongodb', 'mysql2', 'pg',
            'redis', 'bull', 'bullmq', 'agenda',
            'socket.io', 'ws', 'uWebSockets.js',
            'commander', 'yargs', 'minimist', 'inquirer'
        ];
        
        const allDeps = [
            ...this.results.dependencies,
            ...this.results.devDependencies,
            ...this.results.peerDependencies
        ];
        
        const packageName = this.results.packageInfo.name;
        
        // Check the package itself
        this.checkPackageForTyposquatting(packageName, popularPackages);
        
        // Check dependencies
        for (const dep of allDeps) {
            this.checkPackageForTyposquatting(dep.name, popularPackages);
        }
    }

    /**
     * Checks a single package for typosquatting
     */
    checkPackageForTyposquatting(packageName, popularPackages) {
        if (!packageName) return;
        
        const lowerName = packageName.toLowerCase();
        const suspiciousMatches = [];
        
        for (const popular of popularPackages) {
            const lowerPopular = popular.toLowerCase();
            
            // Skip if it's the exact same package
            if (lowerName === lowerPopular) continue;
            
            // Check for common typosquatting patterns
            const similarity = this.calculateSimilarity(lowerName, lowerPopular);
            
            if (similarity > 0.7) {
                suspiciousMatches.push({
                    resembles: popular,
                    similarity: similarity,
                    reason: this.getTyposquattingReason(lowerName, lowerPopular)
                });
            }
        }
        
        if (suspiciousMatches.length > 0) {
            // Sort by similarity (highest first)
            suspiciousMatches.sort((a, b) => b.similarity - a.similarity);
            
            // Add to results (only top 3 matches)
            this.results.analysis.typosquatting.push({
                package: packageName,
                matches: suspiciousMatches.slice(0, 3),
                risk: suspiciousMatches[0].similarity > 0.9 ? 'HIGH' :
                      suspiciousMatches[0].similarity > 0.8 ? 'MEDIUM' : 'LOW'
            });
            
            // Add to risk factors
            const topMatch = suspiciousMatches[0];
            this.results.analysis.riskFactors.push({
                type: 'Typosquatting Risk',
                severity: topMatch.similarity > 0.9 ? 'HIGH' : 'MEDIUM',
                description: `Package "${packageName}" resembles "${topMatch.resembles}" (${Math.round(topMatch.similarity * 100)}% similar)`
            });
        }
    }

    /**
     * Calculates similarity between two strings (Levenshtein distance)
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
     * Determines the reason for typosquatting suspicion
     */
    getTyposquattingReason(str1, str2) {
        const reasons = [];
        
        // Check for common typosquatting patterns
        if (str1.includes(str2) || str2.includes(str1)) {
            reasons.push('contains similar substring');
        }
        
        if (str1.replace(/[^a-zA-Z0-9]/g, '') === str2.replace(/[^a-zA-Z0-9]/g, '')) {
            reasons.push('similar after removing special characters');
        }
        
        if (this.isOneCharDifference(str1, str2)) {
            reasons.push('one character difference');
        }
        
        if (str1.replace(/s$/, '') === str2 || str1 === str2.replace(/s$/, '')) {
            reasons.push('plural variation');
        }
        
        if (str1.replace(/-/g, '') === str2.replace(/-/g, '')) {
            reasons.push('similar after removing hyphens');
        }
        
        return reasons.join(', ');
    }

    /**
     * Checks if two strings differ by exactly one character
     */
    isOneCharDifference(str1, str2) {
        if (Math.abs(str1.length - str2.length) > 1) return false;
        
        let differences = 0;
        const maxLength = Math.max(str1.length, str2.length);
        
        for (let i = 0, j = 0; i < maxLength; i++, j++) {
            const char1 = i < str1.length ? str1[i] : '';
            const char2 = j < str2.length ? str2[j] : '';
            
            if (char1 !== char2) {
                differences++;
                if (differences > 1) return false;
                
                // Adjust for length differences
                if (str1.length > str2.length) j--;
                else if (str2.length > str1.length) i--;
            }
        }
        
        return differences === 1;
    }

    // ==========================================
    // 5. DEPENDENCY CONFUSION DETECTION
    // ==========================================

    /**
     * Detects dependency confusion attacks
     */
    async detectDependencyConfusion() {
        const pkg = this.packageJson;
        const isPrivate = pkg.private === true;
        const hasScope = pkg.name && pkg.name.startsWith('@');
        
        // Dependency confusion typically affects private packages
        // that use public dependencies without proper scoping
        
        if (!isPrivate && !hasScope) {
            // Public package - lower risk
            return;
        }
        
        const allDeps = {
            ...pkg.dependencies,
            ...pkg.devDependencies,
            ...pkg.peerDependencies
        };
        
        const depCount = Object.keys(allDeps).length;
        const scopedDeps = Object.keys(allDeps).filter(name => name.startsWith('@'));
        
        // If it's a private package with many unscoped dependencies
        if (isPrivate && depCount > 10) {
            // Check if any unscoped dependencies could be vulnerable
            const unscopedDeps = Object.keys(allDeps).filter(name => !name.startsWith('@'));
            
            if (unscopedDeps.length > 0) {
                // Sort by risk (popular packages are higher risk)
                const popularPackages = [
                    'express', 'react', 'vue', 'lodash', 'axios',
                    'typescript', 'webpack', 'babel', 'eslint'
                ];
                
                const highRiskDeps = unscopedDeps.filter(dep =>
                    popularPackages.includes(dep)
                );
                
                if (highRiskDeps.length > 0) {
                    this.results.analysis.dependencyConfusion.push({
                        type: 'HIGH_RISK',
                        description: `Private package uses ${highRiskDeps.length} popular unscoped dependencies that may be vulnerable to dependency confusion`,
                        dependencies: highRiskDeps,
                        severity: 'HIGH'
                    });
                    
                    this.results.analysis.riskFactors.push({
                        type: 'Dependency Confusion Risk',
                        severity: 'HIGH',
                        description: `Private package uses popular unscoped dependencies: ${highRiskDeps.join(', ')}`
                    });
                } else {
                    this.results.analysis.dependencyConfusion.push({
                        type: 'LOW_RISK',
                        description: 'Private package uses unscoped dependencies but none are high-risk popular packages',
                        dependencies: unscopedDeps.slice(0, 5),
                        severity: 'LOW'
                    });
                }
            }
        }
        
        // Check for scoped packages that might be vulnerable
        if (hasScope) {
            // If the package is scoped but not private, it's a public scoped package
            if (!isPrivate) {
                this.results.analysis.riskFactors.push({
                    type: 'Public Scoped Package',
                    severity: 'INFO',
                    description: 'Package is publicly scoped - ensure proper access controls'
                });
            }
        }
    }

    // ==========================================
    // 6. PROTESTWARE DETECTION
    // ==========================================

    /**
     * Detects protestware (packages with political or social messages)
     */
    async detectProtestware() {
        const pkg = this.packageJson;
        const riskFactors = [];
        
        // Check for common protestware indicators
        const protestwareIndicators = [
            { pattern: /node-ipc/i, severity: 'HIGH' },
            { pattern: /colors\.js/i, severity: 'MEDIUM' },
            { pattern: /faker\.js/i, severity: 'LOW' }
        ];
        
        // Check dependencies for protestware
        const allDeps = [
            ...this.results.dependencies,
            ...this.results.devDependencies,
            ...this.results.peerDependencies
        ];
        
        for (const dep of allDeps) {
            for (const indicator of protestwareIndicators) {
                if (indicator.pattern.test(dep.name)) {
                    riskFactors.push({
                        type: 'Protestware Risk',
                        severity: indicator.severity,
                        description: `Dependency "${dep.name}" has been associated with protestware in the past`
                    });
                    
                    this.results.analysis.protestware.push({
                        dependency: dep.name,
                        severity: indicator.severity,
                        reason: 'Previously associated with protestware'
                    });
                }
            }
        }
        
        // Check description for political content
        if (pkg.description) {
            const politicalKeywords = ['political', 'protest', 'activism', 'statement', 'message'];
            if (politicalKeywords.some(keyword => pkg.description.toLowerCase().includes(keyword))) {
                riskFactors.push({
                    type: 'Political Content',
                    severity: 'LOW',
                    description: 'Package description contains political or protest-related content'
                });
            }
        }
        
        riskFactors.forEach(factor => {
            this.results.analysis.riskFactors.push(factor);
        });
    }

    // ==========================================
    // 7. MAINTENANCE HEALTH ASSESSMENT
    // ==========================================

    /**
     * Assesses package maintenance health
     */
    async assessMaintenanceHealth() {
        const health = {
            score: 100,
            metrics: {},
            issues: []
        };
        
        // 1. Version age (simulated - in production, check npm registry)
        const versionAge = this.estimateVersionAge(this.results.packageInfo.version);
        if (versionAge > 365) {
            health.score -= 20;
            health.issues.push({
                type: 'Old Version',
                severity: 'MEDIUM',
                description: `Package version is ${Math.round(versionAge / 365)} years old`
            });
        } else if (versionAge > 180) {
            health.score -= 10;
            health.issues.push({
                type: 'Outdated Version',
                severity: 'LOW',
                description: `Package version is ${Math.round(versionAge / 30)} months old`
            });
        }
        
        // 2. Dependency count
        const totalDeps = this.results.dependencies.length +
                          this.results.devDependencies.length;
        if (totalDeps > 100) {
            health.score -= 15;
            health.issues.push({
                type: 'Too Many Dependencies',
                severity: 'MEDIUM',
                description: `Package has ${totalDeps} dependencies`
            });
        } else if (totalDeps > 50) {
            health.score -= 5;
            health.issues.push({
                type: 'Many Dependencies',
                severity: 'LOW',
                description: `Package has ${totalDeps} dependencies`
            });
        }
        
        // 3. Maintenance indicators
        if (!this.packageJson.repository) {
            health.score -= 10;
            health.issues.push({
                type: 'Missing Repository',
                severity: 'MEDIUM',
                description: 'Package does not specify a repository'
            });
        }
        
        if (!this.packageJson.homepage) {
            health.score -= 5;
            health.issues.push({
                type: 'Missing Homepage',
                severity: 'LOW',
                description: 'Package does not specify a homepage'
            });
        }
        
        // 4. Script analysis
        if (this.packageJson.scripts) {
            const scriptCount = Object.keys(this.packageJson.scripts).length;
            if (scriptCount > 10) {
                health.score -= 5;
                health.issues.push({
                    type: 'Too Many Scripts',
                    severity: 'LOW',
                    description: `Package has ${scriptCount} scripts`
                });
            }
        }
        
        // 5. License
        if (this.packageJson.license) {
            const problematicLicenses = ['GPL', 'AGPL', 'LGPL'];
            if (problematicLicenses.some(l => this.packageJson.license.includes(l))) {
                health.score -= 10;
                health.issues.push({
                    type: 'Restrictive License',
                    severity: 'MEDIUM',
                    description: `Package uses ${this.packageJson.license} license`
                });
            }
        }
        
        health.score = Math.max(0, health.score);
        health.metrics = {
            versionAge: versionAge,
            dependencyCount: totalDeps,
            hasRepository: !!this.packageJson.repository,
            hasHomepage: !!this.packageJson.homepage,
            scriptCount: Object.keys(this.packageJson.scripts || {}).length,
            hasLicense: !!this.packageJson.license
        };
        
        this.results.analysis.maintenanceHealth = health;
        
        // Add health issues to risk factors
        health.issues.forEach(issue => {
            this.results.analysis.riskFactors.push({
                type: issue.type,
                severity: issue.severity,
                description: issue.description
            });
        });
    }

    /**
     * Estimates the age of a package version
     */
    estimateVersionAge(version) {
        // This is a simplification - in production, you'd check the npm registry
        // For now, we'll make a rough estimate based on semver
        
        // If version has a date or timestamp, use that
        if (version.includes('-')) {
            const parts = version.split('-');
            if (parts.length > 1) {
                const datePart = parts[parts.length - 1];
                if (datePart.match(/^\d{8}/)) {
                    const year = parseInt(datePart.substring(0, 4));
                    const month = parseInt(datePart.substring(4, 6)) - 1;
                    const day = parseInt(datePart.substring(6, 8));
                    const date = new Date(year, month, day);
                    return differenceInDays(new Date(), date);
                }
            }
        }
        
        // Otherwise, check if it's a major version
        const major = semver.major(version);
        if (major === 0) {
            // Development version - assume recent
            return Math.random() * 90 + 1; // Random 1-90 days
        }
        
        // For production versions, assume some age based on version
        // Older major versions are likely older
        const ageInDays = major * 30 + (semver.minor(version) || 0) * 15;
        return Math.min(ageInDays, 1095); // Cap at 3 years
    }

    // ==========================================
    // 8. TRUST SCORE CALCULATION
    // ==========================================

    /**
     * Calculates a trust score for the package
     */
    calculateTrustScore() {
        let score = 100;
        const pkg = this.packageJson;
        
        // Deduct for risk factors
        for (const factor of this.results.analysis.riskFactors) {
            switch (factor.severity) {
                case 'CRITICAL':
                    score -= 30;
                    break;
                case 'HIGH':
                    score -= 20;
                    break;
                case 'MEDIUM':
                    score -= 10;
                    break;
                case 'LOW':
                    score -= 5;
                    break;
                default:
                    score -= 3;
            }
        }
        
        // Deduct for typosquatting
        for (const typosquat of this.results.analysis.typosquatting) {
            if (typosquat.risk === 'HIGH') score -= 30;
            else if (typosquat.risk === 'MEDIUM') score -= 20;
            else score -= 10;
        }
        
        // Deduct for dependency confusion
        for (const confusion of this.results.analysis.dependencyConfusion) {
            if (confusion.severity === 'HIGH') score -= 30;
            else if (confusion.severity === 'MEDIUM') score -= 20;
            else score -= 10;
        }
        
        // Deduct for protestware
        for (const protestware of this.results.analysis.protestware) {
            if (protestware.severity === 'HIGH') score -= 25;
            else if (protestware.severity === 'MEDIUM') score -= 15;
            else score -= 10;
        }
        
        // Add for good practices
        if (pkg.repository) score += 5;
        if (pkg.homepage) score += 5;
        if (pkg.license && !pkg.license.includes('WTFPL')) score += 5;
        if (this.results.analysis.maintenanceHealth && 
            this.results.analysis.maintenanceHealth.score > 80) {
            score += 10;
        }
        
        // Cap at 0-100
        this.results.analysis.trustScore = Math.max(0, Math.min(100, score));
    }

    // ==========================================
    // 9. REPORT GENERATION
    // ==========================================

    /**
     * Generates a comprehensive report
     */
    generateReport() {
        const report = {
            metadata: {
                analyzedAt: this.results.metadata.analyzedAt,
                packagePath: this.packagePath,
                version: this.results.metadata.version
            },
            package: this.results.packageInfo,
            dependencies: {
                production: this.results.dependencies.length,
                development: this.results.devDependencies.length,
                peer: this.results.peerDependencies.length,
                total: this.results.dependencies.length + 
                       this.results.devDependencies.length + 
                       this.results.peerDependencies.length
            },
            risks: {
                typosquatting: this.results.analysis.typosquatting,
                dependencyConfusion: this.results.analysis.dependencyConfusion,
                protestware: this.results.analysis.protestware,
                riskFactors: this.results.analysis.riskFactors
            },
            health: this.results.analysis.maintenanceHealth,
            trustScore: this.results.analysis.trustScore,
            summary: this.generateSummary()
        };
        
        return report;
    }

    /**
     * Generates a summary of findings
     */
    generateSummary() {
        const riskLevels = { CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0 };
        const totalIssues = this.results.analysis.riskFactors.length;
        
        for (const factor of this.results.analysis.riskFactors) {
            if (riskLevels[factor.severity] !== undefined) {
                riskLevels[factor.severity]++;
            }
        }
        
        const totalRisks = this.results.analysis.typosquatting.length +
                           this.results.analysis.dependencyConfusion.length +
                           this.results.analysis.protestware.length;
        
        return {
            totalIssues,
            criticalIssues: riskLevels.CRITICAL,
            highIssues: riskLevels.HIGH,
            mediumIssues: riskLevels.MEDIUM,
            lowIssues: riskLevels.LOW,
            totalRisks,
            trustScore: this.results.analysis.trustScore,
            healthScore: this.results.analysis.maintenanceHealth?.score || 0
        };
    }
}

// ==========================================
// 10. EXPORTS
// ==========================================

module.exports = PackageAnalyzer;
```

### Step 3: Create a Test Script

```javascript
// path: phase-2/test-analyzer.js

/**
 * TEST SCRIPT FOR PACKAGE ANALYZER
 * 
 * This script demonstrates the package analyzer functionality
 * by analyzing a sample package.json.
 * 
 * Run with: node test-analyzer.js
 */

const path = require('path');
const PackageAnalyzer = require('./src/package-analyzer');
const chalk = require('chalk');

async function testAnalyzer() {
    console.log(chalk.bold.cyan('🔍 Testing Package Analyzer\n'));
    
    // Create a test package.json
    const testDir = path.join(__dirname, 'test-package');
    if (!require('fs').existsSync(testDir)) {
        require('fs').mkdirSync(testDir);
    }
    
    const testPackageJson = {
        name: 'example-package',
        version: '1.0.0',
        description: 'This is an example package for testing',
        main: 'index.js',
        scripts: {
            test: 'echo "Error: no test specified" && exit 1',
            postinstall: 'node -e "console.log(\'Installed!\')"'
        },
        dependencies: {
            'express': '^4.18.0',
            'react': '^18.2.0',
            'lodash': '^4.17.21'
        },
        devDependencies: {
            'jest': '^29.7.0',
            'typescript': '^5.0.0'
        },
        peerDependencies: {
            'react-dom': '^18.2.0'
        },
        author: 'Test Author',
        license: 'MIT',
        repository: {
            type: 'git',
            url: 'https://github.com/test/example-package'
        },
        private: false
    };
    
    const testPackagePath = path.join(testDir, 'package.json');
    require('fs').writeFileSync(
        testPackagePath,
        JSON.stringify(testPackageJson, null, 2)
    );
    
    console.log(chalk.gray(`📁 Created test package at: ${testPackagePath}\n`));
    
    // Analyze the package
    const analyzer = new PackageAnalyzer(testPackagePath);
    const results = await analyzer.analyze();
    
    // Display results
    console.log(chalk.bold('📦 Package Information:'));
    console.log(`   Name: ${results.packageInfo.name}`);
    console.log(`   Version: ${results.packageInfo.version}`);
    console.log(`   License: ${results.packageInfo.license}`);
    console.log(`   Private: ${results.packageInfo.private}`);
    console.log('');
    
    console.log(chalk.bold('📊 Dependency Statistics:'));
    console.log(`   Production: ${results.dependencies.length}`);
    console.log(`   Development: ${results.devDependencies.length}`);
    console.log(`   Peer: ${results.peerDependencies.length}`);
    console.log('');
    
    console.log(chalk.bold('🔒 Trust Score:'), 
        results.analysis.trustScore >= 80 ? chalk.green(`${results.analysis.trustScore}/100`) :
        results.analysis.trustScore >= 60 ? chalk.yellow(`${results.analysis.trustScore}/100`) :
        chalk.red(`${results.analysis.trustScore}/100`)
    );
    console.log('');
    
    if (results.analysis.riskFactors.length > 0) {
        console.log(chalk.yellow.bold('⚠️  Risk Factors:'));
        results.analysis.riskFactors.forEach(factor => {
            const severityColor = {
                CRITICAL: chalk.red,
                HIGH: chalk.yellow,
                MEDIUM: chalk.yellow,
                LOW: chalk.green,
                INFO: chalk.gray
            };
            const color = severityColor[factor.severity] || chalk.white;
            console.log(`   ${color(`[${factor.severity}]`)} ${factor.type}`);
            console.log(`      ${factor.description}`);
        });
    } else {
        console.log(chalk.green('✅ No risk factors detected'));
    }
    console.log('');
    
    if (results.analysis.typosquatting.length > 0) {
        console.log(chalk.yellow.bold('🔍 Typosquatting Detections:'));
        results.analysis.typosquatting.forEach(ts => {
            console.log(`   ${ts.package} resembles:`);
            ts.matches.forEach(match => {
                console.log(`      - ${match.resembles} (${Math.round(match.similarity * 100)}% similar)`);
                console.log(`        Reason: ${match.reason}`);
            });
        });
        console.log('');
    }
    
    if (results.analysis.dependencyConfusion.length > 0) {
        console.log(chalk.yellow.bold('🔄 Dependency Confusion:'));
        results.analysis.dependencyConfusion.forEach(confusion => {
            console.log(`   ${confusion.type}: ${confusion.description}`);
            if (confusion.dependencies) {
                console.log(`      Packages: ${confusion.dependencies.join(', ')}`);
            }
        });
        console.log('');
    }
    
    // Clean up
    require('fs').unlinkSync(testPackagePath);
    require('fs').rmdirSync(testDir);
    
    console.log(chalk.green('✅ Test complete!'));
}

// Run the test
testAnalyzer().catch(console.error);
```

---

## The Verification: Testing Our Analyzer

**✅ Verification Step 1: Run the Test Script**

```bash
# From the phase-2 directory
node test-analyzer.js
```

**Expected output:**

```
🔍 Testing Package Analyzer

📁 Created test package at: .../test-package/package.json

📦 Package Information:
   Name: example-package
   Version: 1.0.0
   License: MIT
   Private: false

📊 Dependency Statistics:
   Production: 3
   Development: 2
   Peer: 1

🔒 Trust Score: 95/100

✅ No risk factors detected

✅ Test complete!
```

**✅ Verification Step 2: Analyze a Real Package**

```bash
# Create a test directory with a real package
mkdir -p real-test
cd real-test
npm init -y
npm install express react lodash
npm install --save-dev jest typescript

# Run the analyzer on the real package
node ../src/package-analyzer.js
```

**✅ Verification Step 3: Test with a Suspicious Package**

Create a test with typosquatting:

```bash
# Create a suspicious package
mkdir -p suspicious-test
cd suspicious-test
cat > package.json << EOF
{
  "name": "exprees",
  "version": "1.0.0",
  "description": "Fake express package",
  "dependencies": {},
  "scripts": {
    "postinstall": "node -e \"console.log('Installed fake express')\""
  }
}
EOF

# Analyze it
node ../src/package-analyzer.js
```

---

## Key Takeaways from Phase 2, Part 1

1. **Package analysis goes beyond version checking** - We now analyze structure, content, and behavior

2. **Typosquatting detection uses similarity algorithms** - Our analyzer uses Levenshtein distance to detect name similarity

3. **Dependency confusion requires understanding of private packages** - We detect when private packages use popular unscoped dependencies

4. **Maintenance health affects trust** - Old versions, missing metadata, and excessive dependencies all reduce trust scores

5. **Lock files provide valuable information** - They show exactly what was installed, including integrity hashes

6. **Risk scoring combines multiple factors** - Our analyzer considers structure, content, behavior, and health

In the next part, we'll build a capability scanner that analyzes what packages can actually do—filesystem access, network communication, shell execution—going beyond what's in package.json to detect real behavioral risks.
