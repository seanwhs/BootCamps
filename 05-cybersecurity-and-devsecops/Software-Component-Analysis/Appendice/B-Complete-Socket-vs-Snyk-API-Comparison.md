# Reference B: Complete Socket vs. Snyk API Comparison

Welcome to the second reference section. This comprehensive guide provides a detailed side-by-side comparison of the Socket and Snyk APIs, including authentication, endpoints, rate limits, response structures, and practical integration examples.

---

## Architecture Comparison

### Socket Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SOCKET ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              API Gateway                             │  │
│  │  https://api.socket.dev/v1                          │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────┴─────────────────────────────┐  │
│  │              Analysis Engine                        │  │
│  │  ┌───────────┐  ┌───────────┐  ┌──────────────┐  │  │
│  │  │ Capability│  │  Package  │  │  Supply Chain│  │  │
│  │  │ Scanner   │  │  Analyzer │  │  Scanner     │  │  │
│  │  └───────────┘  └───────────┘  └──────────────┘  │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────┴─────────────────────────────┐  │
│  │              Data Sources                          │  │
│  │  ┌───────────┐  ┌───────────┐  ┌──────────────┐  │  │
│  │  │  npm      │  │  GitHub   │  │  Community   │  │  │
│  │  │  Registry │  │  Analysis │  │  Reports     │  │  │
│  │  └───────────┘  └───────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  Key Focus: Behavioral Analysis & Capabilities              │
└─────────────────────────────────────────────────────────────┘
```

### Snyk Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SNYK ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              API Gateway                             │  │
│  │  https://api.snyk.io/rest                          │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────┴─────────────────────────────┐  │
│  │              Security Engine                        │  │
│  │  ┌───────────┐  ┌───────────┐  ┌──────────────┐  │  │
│  │  │  CVE      │  │  Package  │  │  Remediation │  │  │
│  │  │ Database  │  │  Scanner  │  │  Engine      │  │  │
│  │  └───────────┘  └───────────┘  └──────────────┘  │  │
│  └──────────────────────┬─────────────────────────────┘  │
│                         │                                  │
│  ┌──────────────────────┴─────────────────────────────┐  │
│  │              Data Sources                          │  │
│  │  ┌───────────┐  ┌───────────┐  ┌──────────────┐  │  │
│  │  │  NVD      │  │  GitHub   │  │  Community   │  │  │
│  │  │  Database │  │  Advisories│  │  Reports     │  │  │
│  │  └───────────┘  └───────────┘  └──────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  Key Focus: Vulnerability Detection & Remediation          │
└─────────────────────────────────────────────────────────────┘
```

---

## API Authentication Comparison

### Socket Authentication

```javascript
// Socket API Authentication
class SocketAuth {
    constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://api.socket.dev/v1';
    }

    getHeaders() {
        const headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        };
        
        // Socket uses Bearer token authentication
        if (this.apiKey) {
            headers['Authorization'] = `Bearer ${this.apiKey}`;
        }
        
        return headers;
    }

    // Alternative: API key as query parameter
    getQueryParams() {
        return {
            api_key: this.apiKey
        };
    }
}

// Usage
const socketAuth = new SocketAuth(process.env.SOCKET_API_KEY);
const headers = socketAuth.getHeaders();
```

### Snyk Authentication

```javascript
// Snyk API Authentication
class SnykAuth {
    constructor(apiKey, orgId) {
        this.apiKey = apiKey;
        this.orgId = orgId;
        this.baseUrl = 'https://api.snyk.io/rest';
    }

    getHeaders() {
        const headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        };
        
        // Snyk uses Token authentication
        if (this.apiKey) {
            headers['Authorization'] = `token ${this.apiKey}`;
        }
        
        return headers;
    }

    // Snyk requires organization ID for most endpoints
    getBaseParams() {
        return {
            orgId: this.orgId
        };
    }
}

// Usage
const snykAuth = new SnykAuth(
    process.env.SNYK_API_KEY,
    process.env.SNYK_ORG_ID
);
const headers = snykAuth.getHeaders();
```

---

## API Endpoint Comparison

### 1. Package Analysis

#### Socket: Package Analysis

```javascript
// Socket - Get package analysis
async function socketPackageAnalysis(packageName, version = 'latest') {
    const response = await axios.get(
        `https://api.socket.dev/v1/packages/${packageName}`,
        {
            params: { version },
            headers: { Authorization: `Bearer ${process.env.SOCKET_API_KEY}` }
        }
    );
    
    return response.data;
}

// Socket - Get package capabilities
async function socketCapabilities(packageName, version = 'latest') {
    const response = await axios.get(
        `https://api.socket.dev/v1/packages/${packageName}/capabilities`,
        {
            params: { version },
            headers: { Authorization: `Bearer ${process.env.SOCKET_API_KEY}` }
        }
    );
    
    return response.data;
}

// Socket - Get package risks
async function socketRisks(packageName, version = 'latest') {
    const response = await axios.get(
        `https://api.socket.dev/v1/packages/${packageName}/risks`,
        {
            params: { version },
            headers: { Authorization: `Bearer ${process.env.SOCKET_API_KEY}` }
        }
    );
    
    return response.data;
}
```

#### Snyk: Package Analysis

```javascript
// Snyk - Get vulnerabilities
async function snykVulnerabilities(packageName, version, ecosystem = 'npm') {
    const response = await axios.get(
        `https://api.snyk.io/rest/vulnerabilities`,
        {
            params: {
                pkgName: packageName,
                version: version,
                ecosystem: ecosystem,
                orgId: process.env.SNYK_ORG_ID
            },
            headers: { Authorization: `token ${process.env.SNYK_API_KEY}` }
        }
    );
    
    return response.data;
}

// Snyk - Get dependency tree
async function snykDependencies(packageName, version, ecosystem = 'npm') {
    const response = await axios.get(
        `https://api.snyk.io/rest/dependencies`,
        {
            params: {
                pkgName: packageName,
                version: version,
                ecosystem: ecosystem,
                orgId: process.env.SNYK_ORG_ID
            },
            headers: { Authorization: `token ${process.env.SNYK_API_KEY}` }
        }
    );
    
    return response.data;
}

// Snyk - Get remediation advice
async function snykRemediation(packageName, version, ecosystem = 'npm') {
    const response = await axios.get(
        `https://api.snyk.io/rest/remediation`,
        {
            params: {
                pkgName: packageName,
                version: version,
                ecosystem: ecosystem,
                orgId: process.env.SNYK_ORG_ID
            },
            headers: { Authorization: `token ${process.env.SNYK_API_KEY}` }
        }
    );
    
    return response.data;
}
```

### 2. Project Scanning

#### Socket: Project Scanning

```javascript
// Socket - Scan project dependencies
async function socketScanProject(projectPath) {
    const fs = require('fs');
    const path = require('path');
    
    // Read package.json and lock file
    const packageJson = JSON.parse(
        fs.readFileSync(path.join(projectPath, 'package.json'), 'utf8')
    );
    
    const response = await axios.post(
        'https://api.socket.dev/v1/scan',
        {
            manifest: packageJson,
            lockfile: fs.readFileSync(
                path.join(projectPath, 'package-lock.json'),
                'utf8'
            )
        },
        {
            headers: { Authorization: `Bearer ${process.env.SOCKET_API_KEY}` }
        }
    );
    
    return response.data;
}

// Socket - Get scan results
async function socketScanResults(scanId) {
    const response = await axios.get(
        `https://api.socket.dev/v1/scans/${scanId}`,
        {
            headers: { Authorization: `Bearer ${process.env.SOCKET_API_KEY}` }
        }
    );
    
    return response.data;
}
```

#### Snyk: Project Scanning

```javascript
// Snyk - Scan project dependencies
async function snykScanProject(projectPath) {
    const fs = require('fs');
    const path = require('path');
    const FormData = require('form-data');
    
    const form = new FormData();
    form.append('file', fs.createReadStream(
        path.join(projectPath, 'package.json')
    ));
    
    const response = await axios.post(
        `https://api.snyk.io/rest/orgs/${process.env.SNYK_ORG_ID}/projects`,
        form,
        {
            params: {
                type: 'npm'
            },
            headers: {
                ...form.getHeaders(),
                Authorization: `token ${process.env.SNYK_API_KEY}`
            }
        }
    );
    
    return response.data;
}

// Snyk - Get project vulnerabilities
async function snykProjectVulnerabilities(projectId) {
    const response = await axios.get(
        `https://api.snyk.io/rest/orgs/${process.env.SNYK_ORG_ID}/projects/${projectId}/issues`,
        {
            params: {
                type: 'vulnerability',
                status: 'open'
            },
            headers: { Authorization: `token ${process.env.SNYK_API_KEY}` }
        }
    );
    
    return response.data;
}
```

### 3. Comparative Endpoint Table

| Feature | Socket Endpoint | Snyk Endpoint |
|---------|----------------|---------------|
| Package Analysis | `/packages/{name}` | `/vulnerabilities?pkgName={name}` |
| Capabilities | `/packages/{name}/capabilities` | N/A (behavioral analysis not included) |
| Risks | `/packages/{name}/risks` | N/A |
| Vulnerabilities | `/packages/{name}/vulnerabilities` | `/vulnerabilities` |
| Remediation | N/A | `/remediation` |
| Project Scan | `/scan` | `/orgs/{orgId}/projects` |
| Scan Results | `/scans/{id}` | `/orgs/{orgId}/projects/{id}/issues` |
| Dependencies | `/packages/{name}/dependencies` | `/dependencies` |

---

## Response Structure Comparison

### Socket Response Structure

```javascript
// Socket - Package Analysis Response
{
  "data": {
    "id": "express-4.18.2",
    "type": "package",
    "attributes": {
      "name": "express",
      "version": "4.18.2",
      "score": 85,
      "riskLevel": "LOW",
      "maintainerTrust": 92,
      "packageHealth": 88,
      "totalDependencies": 45,
      "directDependencies": 12,
      "capabilities": [
        {
          "type": "filesystem",
          "severity": "MEDIUM",
          "description": "Filesystem access detected",
          "evidence": "require('fs')"
        },
        {
          "type": "network",
          "severity": "LOW",
          "description": "Network communication detected",
          "evidence": "require('http')"
        }
      ],
      "risks": [
        {
          "type": "typosquatting",
          "severity": "LOW",
          "description": "Package name is similar to popular packages",
          "similarPackages": ["exprees", "expresss"]
        }
      ],
      "dependencies": [
        {
          "name": "accepts",
          "version": "1.3.8",
          "direct": true,
          "riskLevel": "LOW"
        }
      ],
      "recommendations": [
        "Update to version 4.19.0 for security patches",
        "Review network capabilities in production"
      ]
    },
    "relationships": {
      "scan": {
        "data": {
          "id": "scan-123",
          "type": "scan"
        }
      }
    }
  }
}
```

### Snyk Response Structure

```javascript
// Snyk - Vulnerabilities Response
{
  "data": [
    {
      "id": "SNYK-JS-EXPRESS-12345",
      "type": "vulnerability",
      "attributes": {
        "title": "Denial of Service in Express",
        "description": "Express versions 4.18.0 and below are vulnerable to a denial of service attack...",
        "severity": "medium",
        "cvss_v3_score": 5.3,
        "cvss_v3_vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:L",
        "cve": "CVE-2023-12345",
        "disclosure_time": "2023-01-15T00:00:00Z",
        "exploit_maturity": "mature",
        "fixed_versions": ["4.18.1", "4.19.0"],
        "patches": [
          {
            "id": "patch-123",
            "url": "https://snyk.io/r/123"
          }
        ],
        "affected_versions": [
          {
            "version": "4.0.0",
            "introduced": "4.0.0",
            "fixed": "4.18.1"
          }
        ],
        "remediation": {
          "upgrade": {
            "package": "express",
            "version": "4.18.1"
          },
          "patch": {
            "package": "express",
            "id": "patch-123"
          }
        }
      },
      "relationships": {
        "package": {
          "data": {
            "id": "express",
            "type": "package"
          }
        }
      }
    }
  ],
  "meta": {
    "total": 15,
    "page": 1,
    "per_page": 100
  }
}
```

---

## Rate Limiting Comparison

### Socket Rate Limits

```javascript
// Socket Rate Limit Headers
// Headers returned in API responses:
// X-RateLimit-Limit: 1000
// X-RateLimit-Remaining: 998
// X-RateLimit-Reset: 1700000000

class SocketRateLimiter {
    constructor() {
        this.limit = 1000;
        this.remaining = 1000;
        this.resetTime = 0;
        this.lastRequestTime = 0;
    }

    updateHeaders(headers) {
        if (headers['x-ratelimit-limit']) {
            this.limit = parseInt(headers['x-ratelimit-limit']);
        }
        if (headers['x-ratelimit-remaining']) {
            this.remaining = parseInt(headers['x-ratelimit-remaining']);
        }
        if (headers['x-ratelimit-reset']) {
            this.resetTime = parseInt(headers['x-ratelimit-reset']) * 1000;
        }
    }

    async waitIfNeeded() {
        if (this.remaining <= 0) {
            const now = Date.now();
            const waitTime = this.resetTime - now;
            if (waitTime > 0) {
                console.log(`Rate limit exceeded, waiting ${waitTime}ms`);
                await new Promise(resolve => setTimeout(resolve, waitTime + 1000));
            }
            this.remaining = this.limit;
        }
    }

    async makeRequest(apiCall) {
        await this.waitIfNeeded();
        this.lastRequestTime = Date.now();
        const response = await apiCall();
        this.updateHeaders(response.headers);
        this.remaining--;
        return response.data;
    }
}

// Usage
const limiter = new SocketRateLimiter();
const data = await limiter.makeRequest(() => 
    axios.get('https://api.socket.dev/v1/packages/express', {
        headers: { Authorization: `Bearer ${process.env.SOCKET_API_KEY}` }
    })
);
```

### Snyk Rate Limits

```javascript
// Snyk Rate Limit Headers
// Headers returned in API responses:
// X-RateLimit-Limit: 1000
// X-RateLimit-Remaining: 998
// X-RateLimit-Reset: 1700000000
// Retry-After: 60

class SnykRateLimiter {
    constructor() {
        this.limit = 1000;
        this.remaining = 1000;
        this.resetTime = 0;
        this.retryAfter = 0;
        this.lastRequestTime = 0;
    }

    updateHeaders(headers) {
        if (headers['x-ratelimit-limit']) {
            this.limit = parseInt(headers['x-ratelimit-limit']);
        }
        if (headers['x-ratelimit-remaining']) {
            this.remaining = parseInt(headers['x-ratelimit-remaining']);
        }
        if (headers['x-ratelimit-reset']) {
            this.resetTime = parseInt(headers['x-ratelimit-reset']) * 1000;
        }
        if (headers['retry-after']) {
            this.retryAfter = parseInt(headers['retry-after']) * 1000;
        }
    }

    async handleRateLimit(error) {
        if (error.response && error.response.status === 429) {
            const retryAfter = error.response.headers['retry-after'] || 60;
            const waitTime = parseInt(retryAfter) * 1000;
            console.log(`Rate limit hit, waiting ${waitTime}ms`);
            await new Promise(resolve => setTimeout(resolve, waitTime + 1000));
            return true;
        }
        return false;
    }

    async makeRequest(apiCall, maxRetries = 3) {
        let retries = 0;
        
        while (retries < maxRetries) {
            await this.waitIfNeeded();
            this.lastRequestTime = Date.now();
            
            try {
                const response = await apiCall();
                this.updateHeaders(response.headers);
                this.remaining--;
                return response.data;
            } catch (error) {
                if (await this.handleRateLimit(error)) {
                    retries++;
                    continue;
                }
                throw error;
            }
        }
        throw new Error('Max retries exceeded');
    }

    async waitIfNeeded() {
        if (this.remaining <= 0) {
            const now = Date.now();
            const waitTime = this.resetTime - now;
            if (waitTime > 0) {
                console.log(`Rate limit exceeded, waiting ${waitTime}ms`);
                await new Promise(resolve => setTimeout(resolve, waitTime + 1000));
            }
            this.remaining = this.limit;
        }
    }
}

// Usage
const limiter = new SnykRateLimiter();
const data = await limiter.makeRequest(() => 
    axios.get('https://api.snyk.io/rest/vulnerabilities', {
        params: { pkgName: 'express', version: '4.18.2' },
        headers: { Authorization: `token ${process.env.SNYK_API_KEY}` }
    })
);
```

---

## Error Handling Comparison

### Socket Error Handling

```javascript
// Socket Error Responses
// 400 - Bad Request
// 401 - Unauthorized
// 403 - Forbidden
// 404 - Not Found
// 429 - Rate Limit Exceeded
// 500 - Internal Server Error

class SocketErrorHandler {
    constructor() {
        this.errorCodes = {
            400: 'Invalid request parameters',
            401: 'Invalid API key or authentication failed',
            403: 'Insufficient permissions',
            404: 'Package or resource not found',
            429: 'Rate limit exceeded',
            500: 'Internal server error'
        };
    }

    handleError(error) {
        if (!error.response) {
            return {
                code: 'NETWORK_ERROR',
                message: 'Network error occurred',
                details: error.message
            };
        }

        const status = error.response.status;
        const defaultMessage = 'Unknown error occurred';
        const message = this.errorCodes[status] || defaultMessage;
        const data = error.response.data || {};

        // Log error
        console.error(`Socket API Error [${status}]: ${message}`);
        if (data.details) {
            console.error(`Details: ${data.details}`);
        }

        return {
            code: `HTTP_${status}`,
            message,
            status,
            details: data.details || data.message || '',
            originalError: error
        };
    }
}

// Socket - Exponential Backoff Retry
async function socketWithRetry(apiCall, maxRetries = 3) {
    let retries = 0;
    const handler = new SocketErrorHandler();

    while (retries < maxRetries) {
        try {
            return await apiCall();
        } catch (error) {
            const handled = handler.handleError(error);
            if (handled.status === 429) {
                // Rate limit - retry with backoff
                const waitTime = Math.pow(2, retries) * 1000;
                console.log(`Rate limited, waiting ${waitTime}ms`);
                await new Promise(resolve => setTimeout(resolve, waitTime));
                retries++;
                continue;
            }
            if (handled.status >= 500) {
                // Server error - retry with backoff
                const waitTime = Math.pow(2, retries) * 1000;
                console.log(`Server error, waiting ${waitTime}ms`);
                await new Promise(resolve => setTimeout(resolve, waitTime));
                retries++;
                continue;
            }
            // Client error - don't retry
            throw handled;
        }
    }

    throw new Error('Max retries exceeded');
}
```

### Snyk Error Handling

```javascript
// Snyk Error Responses
// 400 - Bad Request
// 401 - Unauthorized
// 403 - Forbidden
// 404 - Not Found
// 422 - Unprocessable Entity
// 429 - Rate Limit Exceeded
// 500 - Internal Server Error

class SnykErrorHandler {
    constructor() {
        this.errorCodes = {
            400: 'Invalid request parameters',
            401: 'Invalid API key or authentication failed',
            403: 'Insufficient permissions or organization access',
            404: 'Resource not found',
            422: 'Validation error - check request data',
            429: 'Rate limit exceeded',
            500: 'Internal server error'
        };
    }

    handleError(error) {
        if (!error.response) {
            return {
                code: 'NETWORK_ERROR',
                message: 'Network error occurred',
                details: error.message
            };
        }

        const status = error.response.status;
        const defaultMessage = 'Unknown error occurred';
        const message = this.errorCodes[status] || defaultMessage;
        const data = error.response.data || {};

        // Log error
        console.error(`Snyk API Error [${status}]: ${message}`);
        if (data.errors) {
            data.errors.forEach(err => {
                console.error(`  - ${err.detail || err.title}`);
            });
        }

        return {
            code: `HTTP_${status}`,
            message,
            status,
            errors: data.errors || [],
            originalError: error
        };
    }
}

// Snyk - Exponential Backoff Retry with Jitter
async function snykWithRetry(apiCall, maxRetries = 3) {
    let retries = 0;
    const handler = new SnykErrorHandler();

    while (retries < maxRetries) {
        try {
            return await apiCall();
        } catch (error) {
            const handled = handler.handleError(error);
            
            // Handle rate limiting
            if (handled.status === 429) {
                const waitTime = Math.pow(2, retries) * 1000 + 
                    Math.random() * 1000; // Add jitter
                console.log(`Rate limited, waiting ${waitTime}ms`);
                await new Promise(resolve => setTimeout(resolve, waitTime));
                retries++;
                continue;
            }
            
            // Handle server errors
            if (handled.status >= 500) {
                const waitTime = Math.pow(2, retries) * 1000 + 
                    Math.random() * 1000;
                console.log(`Server error, waiting ${waitTime}ms`);
                await new Promise(resolve => setTimeout(resolve, waitTime));
                retries++;
                continue;
            }
            
            // Client errors - don't retry
            throw handled;
        }
    }

    throw new Error('Max retries exceeded');
}
```

---

## Complete Integration Example

### Unified Package Scanner

```javascript
/**
 * UNIFIED PACKAGE SCANNER
 * Combines Socket and Snyk for comprehensive analysis
 */

class UnifiedScanner {
    constructor(socketApiKey, snykApiKey, snykOrgId) {
        this.socketClient = new SocketClient(socketApiKey);
        this.snykClient = new SnykClient(snykApiKey, snykOrgId);
    }

    async scanPackage(packageName, version = 'latest') {
        console.log(`🔍 Scanning ${packageName}@${version}...`);
        
        const startTime = Date.now();
        const results = {
            packageName,
            version,
            timestamp: new Date().toISOString(),
            socket: null,
            snyk: null,
            unified: {
                score: 0,
                riskLevel: 'LOW',
                issues: [],
                recommendations: []
            }
        };

        try {
            // Run both analyses in parallel
            const [socketResults, snykResults] = await Promise.all([
                this.socketClient.analyze(packageName, version),
                this.snykClient.analyze(packageName, version)
            ]);

            results.socket = socketResults;
            results.snyk = snykResults;

            // Merge results
            this.mergeResults(results);
            this.generateRecommendations(results);

            results.duration = Date.now() - startTime;
            return results;

        } catch (error) {
            console.error(`❌ Scan failed: ${error.message}`);
            throw error;
        }
    }

    mergeResults(results) {
        const socket = results.socket;
        const snyk = results.snyk;
        const unified = results.unified;

        // Calculate unified score
        let score = 100;
        let criticalCount = 0;
        let highCount = 0;
        let issues = [];

        // Socket contributions
        if (socket.capabilities) {
            for (const cap of socket.capabilities) {
                const severity = cap.severity;
                const points = severity === 'CRITICAL' ? 20 :
                               severity === 'HIGH' ? 10 :
                               severity === 'MEDIUM' ? 5 : 2;
                score -= points;
                issues.push({
                    source: 'Socket',
                    type: 'Capability',
                    description: cap.description,
                    severity: severity
                });
                if (severity === 'CRITICAL') criticalCount++;
                if (severity === 'HIGH') highCount++;
            }
        }

        // Snyk contributions
        if (snyk.vulnerabilities) {
            for (const vuln of snyk.vulnerabilities) {
                const severity = vuln.severity;
                const points = severity === 'CRITICAL' ? 25 :
                               severity === 'HIGH' ? 15 :
                               severity === 'MEDIUM' ? 8 : 3;
                score -= points;
                issues.push({
                    source: 'Snyk',
                    type: 'Vulnerability',
                    description: vuln.title || vuln.id,
                    severity: severity,
                    cve: vuln.cve,
                    fixedVersions: vuln.fixedVersions
                });
                if (severity === 'CRITICAL') criticalCount++;
                if (severity === 'HIGH') highCount++;
            }
        }

        // Determine unified risk level
        let riskLevel = 'LOW';
        if (criticalCount > 0) riskLevel = 'CRITICAL';
        else if (highCount > 2) riskLevel = 'HIGH';
        else if (highCount > 0) riskLevel = 'MEDIUM';

        unified.score = Math.max(0, Math.min(100, score));
        unified.riskLevel = riskLevel;
        unified.issues = issues;
        unified.criticalCount = criticalCount;
        unified.highCount = highCount;
        unified.totalIssues = issues.length;
    }

    generateRecommendations(results) {
        const unified = results.unified;
        const recommendations = [];

        // Critical issues
        if (unified.criticalCount > 0) {
            recommendations.push({
                priority: 'CRITICAL',
                action: 'BLOCK_IMMEDIATELY',
                message: `${unified.criticalCount} critical issues found`,
                details: 'Block this package and investigate immediately'
            });
        }

        // High issues
        if (unified.highCount > 0) {
            recommendations.push({
                priority: 'HIGH',
                action: 'REVIEW_WITH_URGENCY',
                message: `${unified.highCount} high-risk issues found`,
                details: 'Conduct urgent security review'
            });
        }

        // Snyk-specific recommendations
        if (results.snyk.remediation && results.snyk.remediation.isUpgradable) {
            recommendations.push({
                priority: 'MEDIUM',
                action: 'UPGRADE',
                message: 'Upgrade available for vulnerabilities',
                details: `Upgrade to ${results.snyk.remediation.upgrades[0]?.version || 'latest'}`
            });
        }

        // Socket-specific recommendations
        if (results.socket.recommendations) {
            for (const rec of results.socket.recommendations) {
                recommendations.push({
                    priority: 'LOW',
                    action: 'REVIEW',
                    message: rec
                });
            }
        }

        unified.recommendations = recommendations;
    }
}

// Usage
const scanner = new UnifiedScanner(
    process.env.SOCKET_API_KEY,
    process.env.SNYK_API_KEY,
    process.env.SNYK_ORG_ID
);

const results = await scanner.scanPackage('express', '4.18.2');
console.log(JSON.stringify(results, null, 2));
```

---

## Feature Comparison Matrix

| Feature | Socket | Snyk | Notes |
|---------|--------|------|-------|
| **Vulnerability Detection** | Limited | ✅ Full | Snyk has comprehensive CVE database |
| **Behavioral Analysis** | ✅ Full | ❌ No | Socket specializes in capability analysis |
| **Supply Chain Attacks** | ✅ Full | Partial | Socket excels at detecting supply chain risks |
| **Remediation Advice** | Basic | ✅ Full | Snyk provides detailed upgrade paths |
| **Dependency Tree** | ✅ Full | ✅ Full | Both provide dependency analysis |
| **CI/CD Integration** | ✅ Full | ✅ Full | Both support major CI/CD platforms |
| **IDE Integration** | ✅ Full | ✅ Full | Both have IDE plugins |
| **SAST Integration** | ✅ Full | ✅ Full | Both integrate with SAST tools |
| **Protestware Detection** | ✅ Full | Limited | Socket detects protestware patterns |
| **Typosquatting Detection** | ✅ Full | Limited | Socket has advanced detection |
| **Dependency Confusion** | ✅ Full | Partial | Socket detects dependency confusion |
| **License Analysis** | Basic | ✅ Full | Snyk provides license compliance |
| **Policy Enforcement** | ✅ Full | ✅ Full | Both support custom policies |
| **API Rate Limits** | 1000/min | 1000/min | Similar rate limits |
| **Free Tier** | 50 scans/month | 200 scans/month | Snyk has more generous free tier |
| **Enterprise Features** | ✅ Full | ✅ Full | Both support enterprise requirements |
| **AI Integration** | Limited | Partial | Both exploring AI capabilities |
| **Real-time Monitoring** | ✅ Full | ✅ Full | Both support real-time scanning |

---

## Quick API Reference

### Socket API Quick Reference

```javascript
// Base URL
const SOCKET_BASE = 'https://api.socket.dev/v1';

// Authentication
const SOCKET_HEADERS = {
    'Authorization': `Bearer ${API_KEY}`
};

// Endpoints
// 1. Package Analysis
GET `${SOCKET_BASE}/packages/{name}?version={version}`

// 2. Package Capabilities
GET `${SOCKET_BASE}/packages/{name}/capabilities?version={version}`

// 3. Package Risks
GET `${SOCKET_BASE}/packages/{name}/risks?version={version}`

// 4. Package Dependencies
GET `${SOCKET_BASE}/packages/{name}/dependencies?version={version}`

// 5. Scan Project
POST `${SOCKET_BASE}/scan`
Body: { manifest, lockfile }

// 6. Scan Results
GET `${SOCKET_BASE}/scans/{scanId}`
```

### Snyk API Quick Reference

```javascript
// Base URL
const SNYK_BASE = 'https://api.snyk.io/rest';

// Authentication
const SNYK_HEADERS = {
    'Authorization': `token ${API_KEY}`
};

// Endpoints
// 1. Vulnerabilities
GET `${SNYK_BASE}/vulnerabilities?pkgName={name}&version={version}&ecosystem={ecosystem}`

// 2. Dependencies
GET `${SNYK_BASE}/dependencies?pkgName={name}&version={version}&ecosystem={ecosystem}`

// 3. Remediation
GET `${SNYK_BASE}/remediation?pkgName={name}&version={version}&ecosystem={ecosystem}`

// 4. Create Project
POST `${SNYK_BASE}/orgs/{orgId}/projects?type={ecosystem}`
Body: multipart/form-data with package.json

// 5. Project Issues
GET `${SNYK_BASE}/orgs/{orgId}/projects/{projectId}/issues?type=vulnerability`

// 6. Organization Info
GET `${SNYK_BASE}/orgs/{orgId}`
```

---

## Best Practices for Integration

### 1. Use Both Tools Together

```javascript
// ✅ DO: Use both tools for complete coverage
const scanner = new UnifiedScanner(apiKey1, apiKey2, orgId);
const results = await scanner.scanPackage('express');

// ❌ DON'T: Rely on only one tool
const socketOnly = await socketClient.analyze('express'); // Misses CVEs
const snykOnly = await snykClient.analyze('express'); // Misses capabilities
```

### 2. Implement Caching

```javascript
// ✅ DO: Cache results to reduce API calls
class CachedScanner {
    constructor() {
        this.cache = new Map();
        this.cacheTTL = 3600000; // 1 hour
    }

    async scan(packageName, version) {
        const key = `${packageName}@${version}`;
        const cached = this.cache.get(key);
        
        if (cached && (Date.now() - cached.timestamp < this.cacheTTL)) {
            console.log(`📦 Using cached results for ${key}`);
            return cached.data;
        }

        const results = await this.scanner.scanPackage(packageName, version);
        this.cache.set(key, { data: results, timestamp: Date.now() });
        return results;
    }
}

// ❌ DON'T: Make duplicate API calls
for (const pkg of packages) {
    await scanner.scan(pkg.name); // Each call hits the API
}
```

### 3. Handle Rate Limits Gracefully

```javascript
// ✅ DO: Implement rate limiting
const socketLimiter = new SocketRateLimiter();
const snykLimiter = new SnykRateLimiter();

const results = await Promise.all([
    socketLimiter.makeRequest(() => socketClient.analyze('express')),
    snykLimiter.makeRequest(() => snykClient.analyze('express'))
]);

// ❌ DON'T: Ignore rate limits
const results = await Promise.all([
    socketClient.analyze('express'), // May hit rate limit
    snykClient.analyze('express') // May hit rate limit
]);
```

### 4. Implement Fallbacks

```javascript
// ✅ DO: Implement fallback mechanisms
async function analyzeWithFallback(packageName, version) {
    try {
        return await primaryAnalyzer.analyze(packageName, version);
    } catch (error) {
        console.warn(`⚠️ Primary analyzer failed: ${error.message}`);
        try {
            return await fallbackAnalyzer.analyze(packageName, version);
        } catch (fallbackError) {
            console.warn(`⚠️ Fallback analyzer failed: ${fallbackError.message}`);
            return getFallbackResults(packageName, version);
        }
    }
}

// ❌ DON'T: Fail completely on API error
const results = await analyzer.analyze('express'); // May throw
// No fallback, scan fails
```

---

## Summary

| Aspect | Socket | Snyk |
|--------|--------|------|
| **Primary Focus** | Behavioral Analysis | Vulnerability Detection |
| **Best For** | Supply Chain Security | Known Vulnerabilities |
| **Strengths** | Capability detection, zero-day threats | Comprehensive CVE coverage, remediation |
| **Weaknesses** | Limited CVE coverage | Limited behavioral detection |
| **API Style** | REST | REST |
| **Authentication** | Bearer Token | Token |
| **Rate Limit** | 1000/min | 1000/min |
| **Response Format** | JSON API | JSON API |
