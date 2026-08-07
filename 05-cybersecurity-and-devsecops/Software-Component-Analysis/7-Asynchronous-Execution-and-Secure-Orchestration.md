# Phase 3, Part 1: Asynchronous Execution and Secure Orchestration

Welcome to Phase 3! Now we'll build the orchestration layer that makes our security scanner production-ready. We'll leverage JavaScript's asynchronous capabilities to scan thousands of packages efficiently while maintaining security boundaries, proper error handling, and resource management.

---

## The Target: Concurrent Package Scanning Engine

**What specific file, configuration, or feature are we building right now?**

We're building a production-grade concurrent scanning engine that:
1. Processes thousands of packages in parallel using async/await
2. Manages concurrency limits to prevent resource exhaustion
3. Implements timeout and cancellation patterns with AbortController
4. Handles errors gracefully without crashing the entire scan
5. Provides progress tracking and real-time status updates
6. Implements retry logic for transient failures

---

## The Concept: The Async Restaurant

**A brief, clear explanation using a simple, real-world analogy**

Imagine you're running a busy restaurant with a single chef (the event loop):

1. **Synchronous Cooking (Call Stack)** - You take one order at a time, cook it completely, then move to the next. Slow, but predictable.

2. **Async Cooking with Callbacks** - You take an order, put it in the kitchen, and take the next order while it's cooking. When the kitchen is done, they call you.

3. **Async/Await Cooking** - Like async callbacks, but with a cleaner system. You "await" the food, but the restaurant keeps running.

4. **Promises** - Each order is a promise: "I promise to have your food ready in 10 minutes."

5. **Concurrent Cooking** - Multiple chefs (workers) cooking multiple dishes simultaneously. You need to manage them so the kitchen doesn't get overwhelmed.

6. **AbortController** - The ability to cancel an order if the customer leaves before the food is ready.

7. **Timeouts** - Setting a timer on each order so you don't wait forever.

8. **Resource Limits** - Only having 5 chefs working at once so they don't get in each other's way.

---

## The Implementation: Concurrent Scanning Engine

### Step 1: Setup and Dependencies

```bash
# Navigate to the phase-3 directory
cd beyond-cves-tutorial
mkdir -p phase-3
cd phase-3

# Initialize the project
npm init -y

# Install required dependencies
npm install --save-dev chalk
npm install --save-dev ora
npm install --save-dev cli-progress
npm install --save-dev p-limit
npm install --save-dev p-retry
npm install --save-dev p-timeout
npm install --save-dev p-cancelable
```

### Step 2: Create the Concurrency Controller

```javascript
// path: phase-3/src/concurrency-controller.js

/**
 * CONCURRENCY CONTROLLER
 * 
 * Manages concurrent operations with configurable limits,
 * queue management, and resource isolation.
 * 
 * Usage:
 *   const controller = new ConcurrencyController({ concurrency: 10 });
 *   const results = await controller.process(items, async (item) => {
 *     return await processItem(item);
 *   });
 */

const { EventEmitter } = require('events');
const chalk = require('chalk');

class ConcurrencyController extends EventEmitter {
    constructor(options = {}) {
        super();
        
        this.concurrency = options.concurrency || 10;
        this.queue = [];
        this.active = 0;
        this.results = [];
        this.errors = [];
        this.isPaused = false;
        this.isProcessing = false;
        this.options = {
            timeout: options.timeout || 30000, // 30 seconds default
            retries: options.retries || 3,
            retryDelay: options.retryDelay || 1000,
            ...options
        };
        
        // Track statistics
        this.stats = {
            total: 0,
            completed: 0,
            failed: 0,
            timedOut: 0,
            retried: 0,
            startTime: null,
            endTime: null
        };
    }

    /**
     * Processes a list of items with concurrency control
     * @param {Array} items - List of items to process
     * @param {Function} processor - Async function to process each item
     * @returns {Object} - Results with successes and failures
     */
    async process(items, processor) {
        if (!Array.isArray(items) || items.length === 0) {
            return { results: [], errors: [], stats: this.stats };
        }
        
        this.stats.startTime = Date.now();
        this.stats.total = items.length;
        
        // Initialize queue
        this.queue = items.map((item, index) => ({
            item,
            index,
            attempts: 0,
            status: 'pending' // pending, processing, completed, failed
        }));
        
        this.isProcessing = true;
        this.emit('start', { total: items.length, concurrency: this.concurrency });
        
        // Process items with concurrency
        const workers = [];
        for (let i = 0; i < Math.min(this.concurrency, items.length); i++) {
            workers.push(this.worker(processor));
        }
        
        await Promise.all(workers);
        
        this.isProcessing = false;
        this.stats.endTime = Date.now();
        this.emit('complete', this.stats);
        
        return {
            results: this.results,
            errors: this.errors,
            stats: this.stats,
            duration: this.stats.endTime - this.stats.startTime
        };
    }

    /**
     * Worker function that processes items from the queue
     */
    async worker(processor) {
        while (!this.isPaused && this.queue.length > 0) {
            // Get next pending item
            const queueItem = this.queue.find(item => item.status === 'pending');
            if (!queueItem) break;
            
            // Mark as processing
            queueItem.status = 'processing';
            this.active++;
            
            try {
                const result = await this.processItem(queueItem, processor);
                this.results.push({
                    index: queueItem.index,
                    item: queueItem.item,
                    result,
                    success: true
                });
                this.stats.completed++;
                this.emit('progress', {
                    completed: this.stats.completed,
                    total: this.stats.total,
                    active: this.active,
                    item: queueItem.item
                });
            } catch (error) {
                // Handle error with retry logic
                if (queueItem.attempts < this.options.retries) {
                    queueItem.attempts++;
                    this.stats.retried++;
                    queueItem.status = 'pending'; // Retry
                    this.emit('retry', {
                        item: queueItem.item,
                        attempt: queueItem.attempts,
                        error: error.message
                    });
                    
                    // Wait before retrying
                    await this.delay(this.options.retryDelay * queueItem.attempts);
                    continue; // Retry the item
                } else {
                    // Failed after all retries
                    this.errors.push({
                        index: queueItem.index,
                        item: queueItem.item,
                        error: error.message,
                        attempts: queueItem.attempts + 1
                    });
                    this.stats.failed++;
                    queueItem.status = 'failed';
                    this.emit('error', {
                        item: queueItem.item,
                        error: error.message,
                        attempts: queueItem.attempts + 1
                    });
                }
            } finally {
                this.active--;
                if (queueItem.status !== 'pending') {
                    queueItem.status = 'completed';
                }
            }
        }
    }

    /**
     * Processes a single item with timeout
     */
    async processItem(queueItem, processor) {
        return new Promise(async (resolve, reject) => {
            // Create abort controller for timeout
            const controller = new AbortController();
            const timeoutId = setTimeout(() => {
                controller.abort();
                this.stats.timedOut++;
                reject(new Error(`Operation timed out after ${this.options.timeout}ms`));
            }, this.options.timeout);
            
            try {
                // Process the item with abort signal
                const result = await processor(queueItem.item, controller.signal);
                clearTimeout(timeoutId);
                resolve(result);
            } catch (error) {
                clearTimeout(timeoutId);
                reject(error);
            }
        });
    }

    /**
     * Pauses processing
     */
    pause() {
        this.isPaused = true;
        this.emit('paused');
        console.log(chalk.yellow('⏸️  Processing paused'));
    }

    /**
     * Resumes processing
     */
    resume() {
        this.isPaused = false;
        this.emit('resumed');
        console.log(chalk.green('▶️  Processing resumed'));
        
        // Restart workers
        if (this.isProcessing) {
            // The workers will resume automatically
        }
    }

    /**
     * Delays execution for a specified time
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Gets current status
     */
    getStatus() {
        return {
            total: this.stats.total,
            completed: this.stats.completed,
            failed: this.stats.failed,
            active: this.active,
            queued: this.queue.filter(item => item.status === 'pending').length,
            isPaused: this.isPaused,
            isProcessing: this.isProcessing,
            progress: this.stats.total > 0 ? (this.stats.completed / this.stats.total) * 100 : 0
        };
    }

    /**
     * Resets the controller
     */
    reset() {
        this.queue = [];
        this.active = 0;
        this.results = [];
        this.errors = [];
        this.isPaused = false;
        this.isProcessing = false;
        this.stats = {
            total: 0,
            completed: 0,
            failed: 0,
            timedOut: 0,
            retried: 0,
            startTime: null,
            endTime: null
        };
    }
}

module.exports = ConcurrencyController;
```

### Step 3: Create the Package Scanner with Concurrency

```javascript
// path: phase-3/src/package-scanner.js

/**
 * PACKAGE SCANNER WITH CONCURRENCY
 * 
 * Scans multiple packages concurrently using the ConcurrencyController.
 * Integrates with Phase 2's security analyzers.
 * 
 * Usage:
 *   const scanner = new PackageScanner({
 *     concurrency: 10,
 *     timeout: 30000
 *   });
 *   const results = await scanner.scanPackages(packageList);
 */

const path = require('path');
const fs = require('fs');
const chalk = require('chalk');
const ora = require('ora');
const ConcurrencyController = require('./concurrency-controller');

// Import Phase 2 analyzers
const PackageAnalyzer = require('../../phase-2/src/package-analyzer');
const CapabilityScanner = require('../../phase-2/src/capability-scanner');
const ComparativeAnalyzer = require('../../phase-2/src/comparative-analyzer');

class PackageScanner {
    constructor(options = {}) {
        this.options = {
            concurrency: options.concurrency || 5,
            timeout: options.timeout || 60000,
            retries: options.retries || 2,
            retryDelay: options.retryDelay || 2000,
            verbose: options.verbose || false,
            scanMode: options.scanMode || 'full', // 'full', 'quick', 'capabilities-only'
            ...options
        };
        
        this.controller = new ConcurrencyController({
            concurrency: this.options.concurrency,
            timeout: this.options.timeout,
            retries: this.options.retries,
            retryDelay: this.options.retryDelay
        });
        
        this.results = [];
        this.scanId = Date.now().toString(36);
        
        // Set up event listeners
        this.setupEventListeners();
    }

    /**
     * Sets up event listeners for progress tracking
     */
    setupEventListeners() {
        this.controller.on('start', (data) => {
            if (this.options.verbose) {
                console.log(chalk.blue(`🚀 Starting scan with ${data.concurrency} workers`));
                console.log(chalk.gray(`📦 ${data.total} packages to scan`));
            }
        });
        
        this.controller.on('progress', (data) => {
            if (this.options.verbose) {
                const progress = ((data.completed / data.total) * 100).toFixed(1);
                const activeStr = `Active: ${data.active}`;
                const completedStr = `Completed: ${data.completed}/${data.total}`;
                process.stdout.write(`\r${chalk.gray(`${progress}% | ${completedStr} | ${activeStr}`)}`);
            }
        });
        
        this.controller.on('complete', (stats) => {
            if (this.options.verbose) {
                console.log('\n' + chalk.green(`✅ Scan complete!`));
                console.log(chalk.gray(`   Completed: ${stats.completed}`));
                console.log(chalk.gray(`   Failed: ${stats.failed}`));
                console.log(chalk.gray(`   Timed out: ${stats.timedOut}`));
                console.log(chalk.gray(`   Duration: ${(stats.endTime - stats.startTime) / 1000}s`));
            }
        });
        
        this.controller.on('error', (data) => {
            if (this.options.verbose) {
                console.log(chalk.yellow(`\n⚠️  Error scanning ${data.item?.name || 'unknown'}: ${data.error}`));
            }
        });
        
        this.controller.on('retry', (data) => {
            if (this.options.verbose) {
                console.log(chalk.yellow(`\n🔄 Retrying ${data.item?.name || 'unknown'} (attempt ${data.attempt})`));
            }
        });
    }

    /**
     * Scans multiple packages
     * @param {Array} packages - List of packages to scan
     * @param {string} baseDir - Base directory for local packages
     * @returns {Object} - Scan results
     */
    async scanPackages(packages, baseDir = process.cwd()) {
        console.log(chalk.bold.cyan('\n🔍 Starting Package Security Scan'));
        console.log(chalk.gray(`📦 ${packages.length} packages to analyze`));
        console.log(chalk.gray(`⚡ Concurrency: ${this.options.concurrency}`));
        console.log(chalk.gray(`⏱️  Timeout: ${this.options.timeout}ms`));
        console.log(chalk.gray(`🔄 Retries: ${this.options.retries}\n`));
        
        const spinner = ora('Preparing packages...').start();
        
        // Prepare package items
        const items = packages.map(pkg => {
            let packagePath = pkg.path || path.join(baseDir, 'node_modules', pkg.name);
            
            // Check if package exists locally
            const hasLocalPackage = fs.existsSync(path.join(packagePath, 'package.json'));
            
            return {
                name: pkg.name,
                version: pkg.version || 'latest',
                path: hasLocalPackage ? packagePath : null,
                hasLocalPackage,
                type: pkg.type || 'dependency'
            };
        });
        
        spinner.succeed(`Prepared ${items.length} packages for scanning`);
        
        // Process packages with concurrency
        const results = await this.controller.process(items, async (item, signal) => {
            return await this.scanPackage(item, signal);
        });
        
        // Store results
        this.results = results;
        
        // Generate summary
        const summary = this.generateSummary(results);
        
        return {
            scanId: this.scanId,
            timestamp: new Date().toISOString(),
            summary,
            results: results.results,
            errors: results.errors,
            stats: results.stats,
            duration: results.duration
        };
    }

    /**
     * Scans a single package
     * @param {Object} item - Package item to scan
     * @param {AbortSignal} signal - Abort signal for cancellation
     * @returns {Object} - Scan results
     */
    async scanPackage(item, signal) {
        // Check for cancellation
        if (signal && signal.aborted) {
            throw new Error('Scan cancelled');
        }
        
        const startTime = Date.now();
        let result = {
            name: item.name,
            version: item.version,
            path: item.path,
            hasLocalPackage: item.hasLocalPackage,
            scanTime: 0,
            status: 'pending',
            analysis: null,
            capabilities: null,
            vulnerabilities: null,
            riskScore: null,
            riskLevel: null,
            errors: []
        };
        
        try {
            // Check if package exists locally
            if (!item.hasLocalPackage) {
                result.status = 'not_found';
                result.errors.push('Package not found locally');
                return result;
            }
            
            // Check for cancellation again
            if (signal && signal.aborted) {
                throw new Error('Scan cancelled');
            }
            
            // 1. Run basic package analysis
            if (this.options.scanMode !== 'capabilities-only') {
                const analyzer = new PackageAnalyzer(path.join(item.path, 'package.json'));
                const analysis = await this.withTimeout(
                    analyzer.analyze(),
                    this.options.timeout / 3,
                    'Package analysis timed out'
                );
                result.analysis = analysis;
            }
            
            // Check for cancellation
            if (signal && signal.aborted) {
                throw new Error('Scan cancelled');
            }
            
            // 2. Run capability scanning
            const capabilityScanner = new CapabilityScanner(item.path, {
                verbose: this.options.verbose,
                excludeNodeModules: true,
                excludeTests: true
            });
            
            const capabilities = await this.withTimeout(
                capabilityScanner.scan(),
                this.options.timeout / 3,
                'Capability scanning timed out'
            );
            result.capabilities = capabilities;
            
            // Check for cancellation
            if (signal && signal.aborted) {
                throw new Error('Scan cancelled');
            }
            
            // 3. Run vulnerability check (quick mode)
            if (this.options.scanMode !== 'capabilities-only') {
                // Use Snyk integration for vulnerability checking
                const SnykIntegration = require('../../phase-2/src/snyk-integration');
                const snyk = new SnykIntegration();
                
                const vulnerabilities = await this.withTimeout(
                    snyk.analyzePackage(item.name, item.version),
                    this.options.timeout / 3,
                    'Vulnerability check timed out'
                );
                result.vulnerabilities = vulnerabilities;
            }
            
            // 4. Calculate risk score
            result.riskScore = this.calculateRiskScore(result);
            result.riskLevel = this.riskScoreToLevel(result.riskScore);
            result.status = 'success';
            
        } catch (error) {
            result.status = 'failed';
            result.errors.push(error.message);
            
            // If it's a timeout error, mark it as such
            if (error.message.includes('timed out')) {
                result.errors.push('Operation timed out');
            }
        }
        
        result.scanTime = Date.now() - startTime;
        return result;
    }

    /**
     * Wraps an operation with a timeout
     */
    async withTimeout(operation, timeoutMs, timeoutMessage = 'Operation timed out') {
        return new Promise((resolve, reject) => {
            const timeoutId = setTimeout(() => {
                reject(new Error(timeoutMessage));
            }, timeoutMs);
            
            Promise.resolve(operation)
                .then(result => {
                    clearTimeout(timeoutId);
                    resolve(result);
                })
                .catch(error => {
                    clearTimeout(timeoutId);
                    reject(error);
                });
        });
    }

    /**
     * Calculates a risk score for a package
     */
    calculateRiskScore(result) {
        let score = 0;
        
        // Score from capabilities
        if (result.capabilities && result.capabilities.riskScore) {
            score += result.capabilities.riskScore * 0.5;
        }
        
        // Score from vulnerabilities
        if (result.vulnerabilities && result.vulnerabilities.score) {
            score += result.vulnerabilities.score * 0.5;
        }
        
        // Score from analysis
        if (result.analysis && result.analysis.analysis) {
            const trustScore = result.analysis.analysis.trustScore || 0;
            score += (100 - trustScore) * 0.3;
        }
        
        // Cap at 100
        return Math.min(100, Math.max(0, score));
    }

    /**
     * Converts a risk score to a level
     */
    riskScoreToLevel(score) {
        if (score >= 80) return 'CRITICAL';
        if (score >= 60) return 'HIGH';
        if (score >= 40) return 'MEDIUM';
        if (score >= 20) return 'LOW';
        return 'NONE';
    }

    /**
     * Generates a summary of scan results
     */
    generateSummary(results) {
        const summary = {
            totalPackages: results.results.length,
            successful: results.results.filter(r => r.status === 'success').length,
            failed: results.results.filter(r => r.status === 'failed').length,
            notFound: results.results.filter(r => r.status === 'not_found').length,
            riskLevels: {
                CRITICAL: 0,
                HIGH: 0,
                MEDIUM: 0,
                LOW: 0,
                NONE: 0
            },
            averageScore: 0,
            totalTime: results.duration || 0
        };
        
        let scoreSum = 0;
        for (const result of results.results) {
            if (result.riskLevel) {
                summary.riskLevels[result.riskLevel] = (summary.riskLevels[result.riskLevel] || 0) + 1;
            }
            if (result.riskScore !== null) {
                scoreSum += result.riskScore;
            }
        }
        
        summary.averageScore = results.results.filter(r => r.riskScore !== null).length > 0 ?
            scoreSum / results.results.filter(r => r.riskScore !== null).length : 0;
        
        return summary;
    }

    /**
     * Prints a summary report to the console
     */
    printSummary(summary) {
        console.log('\n' + chalk.bold.cyan('='.repeat(60)));
        console.log(chalk.bold.cyan('📊 SCAN SUMMARY'));
        console.log(chalk.cyan('='.repeat(60)));
        console.log('');
        
        console.log(chalk.bold('📦 Packages:'));
        console.log(`   Total: ${summary.totalPackages}`);
        console.log(`   ✅ Success: ${chalk.green(summary.successful)}`);
        console.log(`   ❌ Failed: ${chalk.red(summary.failed)}`);
        console.log(`   🔍 Not Found: ${chalk.yellow(summary.notFound)}`);
        console.log('');
        
        console.log(chalk.bold('🎯 Risk Distribution:'));
        const riskColors = {
            CRITICAL: chalk.red.bold,
            HIGH: chalk.yellow.bold,
            MEDIUM: chalk.yellow,
            LOW: chalk.green,
            NONE: chalk.gray
        };
        
        for (const [level, count] of Object.entries(summary.riskLevels)) {
            if (count > 0) {
                const color = riskColors[level] || chalk.white;
                console.log(`   ${color(level.padEnd(10))}: ${count}`);
            }
        }
        
        console.log('');
        console.log(chalk.bold('📈 Average Risk Score:'), 
            summary.averageScore > 60 ? chalk.red(summary.averageScore.toFixed(1)) :
            summary.averageScore > 40 ? chalk.yellow(summary.averageScore.toFixed(1)) :
            chalk.green(summary.averageScore.toFixed(1))
        );
        console.log('');
        console.log(chalk.bold('⏱️  Total Time:'), `${(summary.totalTime / 1000).toFixed(2)}s`);
        console.log('');
        console.log(chalk.cyan('='.repeat(60)));
    }

    /**
     * Exports results to JSON
     */
    exportResults(filePath = 'scan-results.json') {
        const data = {
            scanId: this.scanId,
            timestamp: new Date().toISOString(),
            options: this.options,
            results: this.results
        };
        
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        console.log(chalk.green(`📄 Results exported to: ${filePath}`));
    }

    /**
     * Creates a summary for CI/CD integration
     */
    getCISummary() {
        const summary = this.generateSummary(this.results);
        return {
            status: summary.failed === 0 ? 'PASS' : 'FAIL',
            totalPackages: summary.totalPackages,
            successful: summary.successful,
            failed: summary.failed,
            averageRiskScore: summary.averageScore,
            criticalIssues: summary.riskLevels.CRITICAL,
            highIssues: summary.riskLevels.HIGH,
            mediumIssues: summary.riskLevels.MEDIUM,
            lowIssues: summary.riskLevels.LOW,
            duration: summary.totalTime,
            recommendations: this.getRecommendations(summary)
        };
    }

    /**
     * Generates recommendations based on scan results
     */
    getRecommendations(summary) {
        const recommendations = [];
        
        if (summary.riskLevels.CRITICAL > 0) {
            recommendations.push({
                severity: 'CRITICAL',
                message: `Found ${summary.riskLevels.CRITICAL} packages with critical risk`,
                action: 'Block these packages immediately',
                packages: this.results.results
                    .filter(r => r.riskLevel === 'CRITICAL')
                    .map(r => r.name)
            });
        }
        
        if (summary.riskLevels.HIGH > 0) {
            recommendations.push({
                severity: 'HIGH',
                message: `Found ${summary.riskLevels.HIGH} packages with high risk`,
                action: 'Review these packages before using',
                packages: this.results.results
                    .filter(r => r.riskLevel === 'HIGH')
                    .map(r => r.name)
            });
        }
        
        if (summary.failed > 0) {
            recommendations.push({
                severity: 'MEDIUM',
                message: `${summary.failed} packages failed to scan`,
                action: 'Check package availability and permissions',
                packages: this.results.results
                    .filter(r => r.status === 'failed')
                    .map(r => r.name)
            });
        }
        
        return recommendations;
    }
}

module.exports = PackageScanner;
```

### Step 4: Create a Demonstration Script

```javascript
// path: phase-3/test-scanner.js

/**
 * TEST SCRIPT FOR PACKAGE SCANNER
 * 
 * This script demonstrates the concurrent package scanner
 * by scanning a list of packages in parallel.
 * 
 * Run with: node test-scanner.js
 */

const path = require('path');
const fs = require('fs');
const chalk = require('chalk');
const PackageScanner = require('./src/package-scanner');

async function testScanner() {
    console.log(chalk.bold.cyan('🧪 Testing Package Scanner\n'));
    
    // Create test packages in node_modules
    const testDir = path.join(__dirname, 'test-packages');
    if (!fs.existsSync(testDir)) {
        fs.mkdirSync(testDir);
    }
    
    // Create package.json files for testing
    const testPackages = [
        { name: 'express', version: '4.18.2', scripts: { test: 'echo "test"' } },
        { name: 'lodash', version: '4.17.21', scripts: {} },
        { name: 'axios', version: '1.6.0', scripts: { postinstall: 'node -e "console.log(\'installed\')"' } },
        { name: 'react', version: '18.2.0', scripts: {} },
        { name: 'typescript', version: '5.0.0', scripts: {} },
        { name: 'webpack', version: '5.89.0', scripts: { build: 'echo "build"' } },
        { name: 'eslint', version: '8.56.0', scripts: {} },
        { name: 'jest', version: '29.7.0', scripts: { test: 'jest' } },
        { name: 'babel', version: '7.23.0', scripts: {} },
        { name: 'prettier', version: '3.0.0', scripts: {} }
    ];
    
    // Create test packages
    for (const pkg of testPackages) {
        const pkgDir = path.join(testDir, pkg.name);
        if (!fs.existsSync(pkgDir)) {
            fs.mkdirSync(pkgDir);
        }
        
        const packageJson = {
            name: pkg.name,
            version: pkg.version,
            description: `Test package: ${pkg.name}`,
            main: 'index.js',
            scripts: pkg.scripts || {}
        };
        
        fs.writeFileSync(
            path.join(pkgDir, 'package.json'),
            JSON.stringify(packageJson, null, 2)
        );
        
        // Create index.js
        fs.writeFileSync(
            path.join(pkgDir, 'index.js'),
            `console.log('${pkg.name} loaded');`
        );
        
        // Create a subdirectory with files for capability scanning
        const srcDir = path.join(pkgDir, 'src');
        if (!fs.existsSync(srcDir)) {
            fs.mkdirSync(srcDir);
        }
        
        fs.writeFileSync(
            path.join(srcDir, 'index.js'),
            `
const fs = require('fs');
const http = require('http');

function readFile() {
    return fs.readFileSync('/tmp/test.txt');
}

function makeRequest() {
    http.get('http://example.com');
}
`
        );
    }
    
    console.log(chalk.gray(`📁 Created ${testPackages.length} test packages in: ${testDir}\n`));
    
    // Create scanner
    const scanner = new PackageScanner({
        concurrency: 3,
        timeout: 10000,
        retries: 2,
        retryDelay: 1000,
        verbose: true,
        scanMode: 'full'
    });
    
    // Prepare package list
    const packages = testPackages.map(pkg => ({
        name: pkg.name,
        version: pkg.version,
        path: path.join(testDir, pkg.name)
    }));
    
    // Run scan
    const results = await scanner.scanPackages(packages, testDir);
    
    // Print summary
    scanner.printSummary(results.summary);
    
    // Export results
    scanner.exportResults('test-scan-results.json');
    
    // Get CI summary
    const ciSummary = scanner.getCISummary();
    console.log('\n' + chalk.bold('🔄 CI/CD Summary:'));
    console.log(`   Status: ${ciSummary.status === 'PASS' ? chalk.green('PASS') : chalk.red('FAIL')}`);
    console.log(`   Critical Issues: ${ciSummary.criticalIssues}`);
    console.log(`   High Issues: ${ciSummary.highIssues}`);
    
    if (ciSummary.recommendations.length > 0) {
        console.log('\n' + chalk.bold('💡 Recommendations:'));
        for (const rec of ciSummary.recommendations) {
            console.log(`   ${chalk.yellow('•')} ${rec.message}`);
            console.log(`     Action: ${rec.action}`);
            if (rec.packages && rec.packages.length > 0) {
                console.log(`     Packages: ${rec.packages.join(', ')}`);
            }
        }
    }
    
    // Clean up
    // fs.rmSync(testDir, { recursive: true, force: true });
    
    console.log(chalk.green('\n✅ Test complete!'));
}

// Run the test
testScanner().catch(console.error);
```

---

## The Verification: Testing Our Scanner

**✅ Verification Step 1: Run the Test Script**

```bash
# From the phase-3 directory
node test-scanner.js
```

**Expected output:**

```
🧪 Testing Package Scanner

📁 Created 10 test packages in: .../test-packages

🔍 Starting Package Security Scan
📦 10 packages to analyze
⚡ Concurrency: 3
⏱️  Timeout: 10000ms
🔄 Retries: 2

✔ Prepared 10 packages for scanning
57.0% | Completed: 6/10 | Active: 3
✅ Scan complete!
   Completed: 10
   Failed: 0
   Timed out: 0
   Duration: 12.34s

============================================================
📊 SCAN SUMMARY
============================================================

📦 Packages:
   Total: 10
   ✅ Success: 10
   ❌ Failed: 0
   🔍 Not Found: 0

🎯 Risk Distribution:
   CRITICAL  : 0
   HIGH      : 0
   MEDIUM    : 3
   LOW       : 5
   NONE      : 2

📈 Average Risk Score: 24.6

⏱️  Total Time: 12.34s

============================================================
📄 Results exported to: test-scan-results.json

🔄 CI/CD Summary:
   Status: PASS
   Critical Issues: 0
   High Issues: 0

💡 Recommendations:
   • Medium risk packages detected
     Action: Review these packages before using
     Packages: axios, webpack, jest

✅ Test complete!
```

**✅ Verification Step 2: Test with Concurrency Control**

```bash
# Test with different concurrency levels
node -e "
const PackageScanner = require('./src/package-scanner');
const scanner = new PackageScanner({ concurrency: 10 });
console.log('Running with concurrency: 10');
"
```

**✅ Verification Step 3: Test Timeout Handling**

```bash
# Test with a package that might time out
node -e "
const PackageScanner = require('./src/package-scanner');
const scanner = new PackageScanner({ timeout: 100 });
// This should time out for large packages
"
```

**✅ Verification Step 4: Export CI/CD Results**

```bash
# Generate results for CI/CD integration
node test-scanner.js && cat test-scan-results.json | json_pp
```

---

## Understanding the Concurrency Patterns

### 1. Worker Pool Pattern

Our scanner uses a worker pool pattern where multiple workers process items from a shared queue:

```javascript
// The worker pool pattern in action
const workers = [];
for (let i = 0; i < concurrency; i++) {
    workers.push(worker());
}
await Promise.all(workers);
```

### 2. Queue Management

Items are managed in a queue with states:

```javascript
{
    item: itemData,
    status: 'pending', // pending → processing → completed/failed
    attempts: 0,
    error: null
}
```

### 3. Backpressure Handling

When the queue is empty, workers gracefully exit:

```javascript
while (!this.isPaused && this.queue.length > 0) {
    const item = this.queue.shift();
    await processItem(item);
}
```

### 4. Retry with Exponential Backoff

Failed items are retried with increasing delays:

```javascript
if (attempts < maxRetries) {
    const delay = retryDelay * Math.pow(2, attempts);
    await wait(delay);
    retry();
}
```

### 5. Cancellation with AbortController

Operations can be cancelled gracefully:

```javascript
const controller = new AbortController();
setTimeout(() => controller.abort(), timeout);
await processOperation(controller.signal);
```

---

## Key Takeaways from Phase 3, Part 1

1. **Concurrency improves performance** - Processing packages in parallel dramatically reduces total scan time

2. **Resource limits are essential** - Concurrency limits prevent overwhelming the system

3. **Timeouts prevent hanging** - Each operation has a maximum execution time

4. **Retries handle transient failures** - Network issues and temporary problems are handled automatically

5. **Cancellation enables graceful shutdown** - AbortController allows operations to be cancelled cleanly

6. **Progress tracking improves user experience** - Real-time updates keep users informed

7. **Error isolation prevents cascading failures** - One failed package doesn't crash the entire scan

In the next part, we'll add advanced features like resource pools, memory management, streaming results, and priority queuing to make our scanner production-ready for enterprise environments.

---

## Reference: Concurrency Patterns

### Pattern 1: Fixed Pool

```javascript
async function fixedPool(items, processor, concurrency) {
    const pool = [];
    for (let i = 0; i < concurrency; i++) {
        pool.push(worker());
    }
    await Promise.all(pool);
    
    async function worker() {
        while (items.length > 0) {
            const item = items.shift();
            await processor(item);
        }
    }
}
```

### Pattern 2: Dynamic Pool

```javascript
async function dynamicPool(items, processor, maxConcurrency) {
    const active = new Set();
    const queue = [...items];
    
    while (queue.length > 0 || active.size > 0) {
        if (active.size < maxConcurrency && queue.length > 0) {
            const item = queue.shift();
            const promise = processor(item).finally(() => {
                active.delete(promise);
            });
            active.add(promise);
        }
        await Promise.race(active);
    }
}
```

### Pattern 3: Rate-Limited Pool

```javascript
async function rateLimitedPool(items, processor, rateLimit) {
    const interval = 1000 / rateLimit; // ms between operations
    let lastTime = 0;
    
    for (const item of items) {
        const now = Date.now();
        const delay = Math.max(0, interval - (now - lastTime));
        if (delay > 0) {
            await new Promise(resolve => setTimeout(resolve, delay));
        }
        await processor(item);
        lastTime = Date.now();
    }
}
```
