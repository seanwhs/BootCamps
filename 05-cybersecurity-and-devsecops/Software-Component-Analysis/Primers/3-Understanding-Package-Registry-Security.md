# Primer 3: Understanding Package Registry Security

Welcome to the third primer of our tutorial series. This primer explains how package registries work, their security implications, and how attackers exploit registry vulnerabilities—essential knowledge for understanding the full supply chain attack surface.

---

## What is a Package Registry?

### Registry Architecture

A package registry is a central repository that stores and distributes packages. It acts as the source of truth for package metadata, versions, and files.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PACKAGE REGISTRY ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    PUBLIC REGISTRY (npmjs.com)                     │  │
│  │  ┌──────────────────────────────────────────────────────────────┐ │  │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │ │  │
│  │  │  │ Package │  │ Package │  │ Package │  │ Package │       │ │  │
│  │  │  │   A     │  │   B     │  │   C     │  │   D     │       │ │  │
│  │  │  │ 1.0.0   │  │ 2.1.3   │  │ 3.0.0   │  │ 1.2.4   │       │ │  │
│  │  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘       │ │  │
│  │  └──────────────────────────────────────────────────────────────┘ │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    REGISTRY SERVICES                               │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │  │
│  │  │  Search      │  │  Authentication│  │  Rate Limiting      │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘  │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │  │
│  │  │  Package     │  │  User        │  │  Download            │  │  │
│  │  │  Management  │  │  Management  │  │  Statistics          │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                    PRIVATE REGISTRIES                              │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │  │
│  │  │  Verdaccio   │  │  GitHub      │  │  AWS CodeArtifact    │  │  │
│  │  │  (Self-hosted)│  │  Packages   │  │                      │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Registry Operations

```javascript
/**
 * REGISTRY OPERATIONS
 * Key operations performed by package registries
 */

const registryOperations = {
    // 1. Package Publishing
    publish: {
        description: 'Uploading a package to the registry',
        steps: [
            'Verify user authentication',
            'Check package name availability',
            'Validate package.json',
            'Store package metadata',
            'Upload package tarball',
            'Update search index',
            'Trigger webhooks'
        ],
        security: `
            ✅ Requires authentication
            ✅ Validates package format
            ✅ Verifies publisher permissions
            ✅ Checks for name squatting
        `
    },
    
    // 2. Package Installation
    install: {
        description: 'Downloading a package from the registry',
        steps: [
            'User requests package',
            'Registry resolves version',
            'Registry returns metadata',
            'Registry serves tarball',
            'npm verifies integrity'
        ],
        security: `
            ✅ Checks package availability
            ✅ Enforces rate limiting
            ✅ Validates package integrity
            ✅ Provides metadata
        `
    },
    
    // 3. Package Management
    management: {
        description: 'Managing package versions and metadata',
        operations: [
            'Deprecate versions',
            'Remove versions',
            'Update metadata',
            'Transfer ownership',
            'Manage collaborators'
        ],
        security: `
            ✅ Requires ownership verification
            ✅ Audits management actions
            ✅ Tracks changes history
            ✅ Enforces permissions
        `
    }
};
```

---

## Registry Security Model

### Authentication and Authorization

```javascript
/**
 * REGISTRY AUTHENTICATION
 * How npm verifies user identity
 */

const registryAuthentication = {
    // 1. Token-Based Authentication
    tokenAuth: {
        description: 'Using authentication tokens for API access',
        tokenTypes: [
            'npm_token',        // Personal access token
            'npm_otp',          // One-time password token
            'npm_auth_token',   // Automation token
            'github_token',     // GitHub token
            'gitlab_token'      // GitLab token
        ],
        security: `
            ✅ Tokens are encrypted
            ✅ Tokens have expiration
            ✅ Tokens can be revoked
            ✅ Tokens have scoped permissions
        `,
        risks: `
            ⚠️ Token leakage in .npmrc
            ⚠️ Token leakage in CI/CD logs
            ⚠️ Token theft via malicious packages
            ⚠️ Token reuse across services
        `,
        bestPractices: `
            ✅ Use environment variables for tokens
            ✅ Rotate tokens regularly
            ✅ Use least privilege permissions
            ✅ Never commit tokens to version control
        `
    },
    
    // 2. Two-Factor Authentication (2FA)
    twoFactorAuth: {
        description: 'Adding a second layer of authentication',
        methods: [
            'Authenticator app (TOTP)',
            'SMS verification',
            'Hardware token (U2F)',
            'Email verification'
        ],
        requirements: `
            ✅ npm requires 2FA for publishing
            ✅ 2FA for deleting packages
            ✅ 2FA for resetting passwords
            ✅ 2FA for changing settings
        `,
        risks: `
            ⚠️ Time-based OTP can be stolen
            ⚠️ SMS verification can be intercepted
            ⚠️ Hardware tokens can be lost
        `
    },
    
    // 3. OAuth and SSO
    oauth: {
        description: 'Using OAuth and Single Sign-On',
        providers: [
            'GitHub OAuth',
            'Google OAuth',
            'Enterprise SSO (SAML)',
            'Active Directory'
        ],
        benefits: `
            ✅ Centralized identity management
            ✅ Reduced password fatigue
            ✅ Easy user provisioning
            ✅ Audit trails
        `
    }
};

// Example: Managing tokens securely
class SecureTokenManager {
    constructor() {
        this.tokens = new Map();
        this.tokenExpiry = 3600000; // 1 hour
    }
    
    createToken(user, scopes = ['read']) {
        const token = crypto.randomBytes(32).toString('hex');
        const expires = Date.now() + this.tokenExpiry;
        
        this.tokens.set(token, {
            user,
            scopes,
            expires,
            createdAt: Date.now()
        });
        
        return token;
    }
    
    validateToken(token, requiredScope = 'read') {
        const tokenData = this.tokens.get(token);
        
        if (!tokenData) {
            return { valid: false, reason: 'Token not found' };
        }
        
        if (Date.now() > tokenData.expires) {
            this.tokens.delete(token);
            return { valid: false, reason: 'Token expired' };
        }
        
        if (!tokenData.scopes.includes(requiredScope)) {
            return { valid: false, reason: 'Insufficient scope' };
        }
        
        return { valid: true, user: tokenData.user };
    }
    
    revokeToken(token) {
        this.tokens.delete(token);
        return { revoked: true };
    }
}
```

### Package Integrity

```javascript
/**
 * PACKAGE INTEGRITY
 * Ensuring packages haven't been tampered with
 */

const packageIntegrity = {
    // 1. Integrity Hashes
    integrityHashes: {
        description: 'Cryptographic hashes to verify package contents',
        algorithms: ['sha512', 'sha1', 'md5'],
        format: 'algorithm-hash',
        example: 'sha512-abc123def456...',
        verification: `
            npm calculates hash of downloaded package
            npm compares to registry hash
            If mismatch, installation fails
        `
    },
    
    // 2. Package Signing
    packageSigning: {
        description: 'Cryptographic signatures from publishers',
        methods: [
            'PGP/GPG signing',
            'npm sign',
            'sigstore',
            'cosign'
        ],
        verification: `
            ✅ Verifies publisher identity
            ✅ Confirms package hasn't been tampered with
            ✅ Prevents impersonation
            ✅ Enables trust chains
        `
    },
    
    // 3. Provenance
    provenance: {
        description: 'Tracking package origin and build process',
        information: [
            'Source repository',
            'Build system',
            'Build environment',
            'Build timestamp',
            'Publisher identity'
        ],
        benefits: `
            ✅ Traceability to source
            ✅ Build reproducibility
            ✅ Trust verification
            ✅ Supply chain transparency
        `
    }
};

// Example: Verifying package integrity
class IntegrityVerifier {
    constructor(registry) {
        this.registry = registry;
    }
    
    async verifyPackage(packageName, version) {
        // 1. Get package metadata from registry
        const metadata = await this.registry.getMetadata(packageName, version);
        
        // 2. Get integrity hash
        const integrityHash = metadata.integrity;
        if (!integrityHash) {
            throw new Error('No integrity hash available');
        }
        
        // 3. Download package
        const tarball = await this.registry.downloadTarball(packageName, version);
        
        // 4. Calculate hash
        const hash = crypto.createHash('sha512');
        hash.update(tarball);
        const computedHash = `sha512-${hash.digest('base64')}`;
        
        // 5. Compare
        if (computedHash !== integrityHash) {
            throw new Error('Integrity check failed!');
        }
        
        // 6. Verify signature if available
        if (metadata.signatures) {
            await this.verifySignatures(tarball, metadata.signatures);
        }
        
        return {
            verified: true,
            integrity: integrityHash,
            packageName,
            version
        };
    }
    
    async verifySignatures(tarball, signatures) {
        // Implementation would use PGP, sigstore, etc.
        console.log('🔍 Verifying signatures...');
        // ... signature verification logic
        return true;
    }
}
```

---

## Registry Attack Vectors

### 1. Name Squatting and Hijacking

```javascript
/**
 * NAME SQUATTING ATTACKS
 * Exploiting package names before legitimate owners
 */

const nameSquatting = {
    // 1. Typosquatting
    typosquatting: {
        description: 'Registering names similar to popular packages',
        examples: [
            'exprees' (express),
            'loash' (lodash),
            'reactt' (react),
            'anglar' (angular),
            'vuee' (vue)
        ],
        impact: 'Users accidentally install malicious packages',
        detection: `
            ✅ Check for similar names
            ✅ Monitor download statistics
            ✅ Use typosquatting detectors
            ✅ Implement naming policies
        `
    },
    
    // 2. Dependency Confusion
    dependencyConfusion: {
        description: 'Publishing internal package names to public registry',
        scenario: `
            Company uses internal package @company/auth
            Attacker publishes auth to npm
            npm install auth gets attacker's version
        `,
        impact: 'Malicious code in internal applications',
        mitigation: `
            ✅ Use scoped packages (@company/package)
            ✅ Configure private registries
            ✅ Use .npmrc with registry priority
            ✅ Implement package name reservation
        `
    },
    
    // 3. Brandjacking
    brandjacking: {
        description: 'Registering company or product names',
        examples: [
            'microsoft',      // Company name
            'google-cloud',   // Product name
            'aws-sdk',        // SDK name
            'react-native'    // Framework name
        ],
        impact: 'Reputation damage, phishing, malware',
        prevention: `
            ✅ Proactive name registration
            ✅ Legal action
            ✅ Registry reporting
            ✅ Trademark protection
        `
    }
};

// Example: Name squatting detection
class NameSquattingDetector {
    constructor(popularPackages) {
        this.popularPackages = popularPackages;
        this.suspiciousPatterns = [
            /^[a-zA-Z0-9]*-$/,        // Trailing hyphen
            /^[a-zA-Z0-9]*\./,        // Contains dot
            /^[a-zA-Z0-9]*js$/,       // Ends with 'js'
            /^[a-zA-Z0-9]*node$/,     // Ends with 'node'
            /^[a-zA-Z0-9]*core$/,     // Ends with 'core'
            /^[a-zA-Z0-9]*lib$/,      // Ends with 'lib'
            /^[a-zA-Z0-9]*s$/,        // Pluralization
            /^[a-zA-Z0-9]*2$/,        // Numeric suffix
            /^[a-zA-Z0-9]*3$/,
            /^[a-zA-Z0-9]*4$/
        ];
    }
    
    detectSquatting(packageName) {
        const suspicions = [];
        
        // Check against popular packages
        for (const popular of this.popularPackages) {
            const similarity = this.calculateSimilarity(packageName, popular);
            if (similarity > 0.7) {
                suspicions.push({
                    resembles: popular,
                    similarity,
                    reason: 'High name similarity'
                });
            }
        }
        
        // Check for suspicious patterns
        for (const pattern of this.suspiciousPatterns) {
            if (pattern.test(packageName)) {
                suspicions.push({
                    pattern: pattern.toString(),
                    reason: 'Suspicious naming pattern'
                });
            }
        }
        
        return suspicions;
    }
    
    calculateSimilarity(str1, str2) {
        // Levenshtein distance
        const track = Array(str2.length + 1)
            .fill(null)
            .map(() => Array(str1.length + 1).fill(null));
        
        for (let i = 0; i <= str1.length; i++) {
            track[0][i] = i;
        }
        for (let j = 0; j <= str2.length; j++) {
            track[j][0] = j;
        }
        
        for (let j = 1; j <= str2.length; j++) {
            for (let i = 1; i <= str1.length; i++) {
                const indicator = str1[i - 1] === str2[j - 1] ? 0 : 1;
                track[j][i] = Math.min(
                    track[j][i - 1] + 1,
                    track[j - 1][i] + 1,
                    track[j - 1][i - 1] + indicator
                );
            }
        }
        
        const distance = track[str2.length][str1.length];
        const maxLength = Math.max(str1.length, str2.length);
        return 1 - (distance / maxLength);
    }
}
```

### 2. Registry Compromise

```javascript
/**
 * REGISTRY COMPROMISE
 * Attackers targeting the registry itself
 */

const registryCompromise = {
    // 1. Registry Hijacking
    registryHijacking: {
        description: 'Compromising the registry infrastructure',
        attackTypes: [
            'DNS hijacking',
            'Mirror compromise',
            'CDN cache poisoning',
            'Registry API exploitation'
        ],
        impact: 'Massive supply chain compromise',
        detection: `
            ✅ Monitor registry for anomalies
            ✅ Verify package integrity
            ✅ Use multiple registries
            ✅ Implement incident response
        `
    },
    
    // 2. Mirror Poisoning
    mirrorPoisoning: {
        description: 'Compromising npm mirror servers',
        scenario: `
            Attacker compromises a mirror
            Mirror serves malicious packages
            Users downloading from mirror get malware
        `,
        mitigation: `
            ✅ Use official registry
            ✅ Verify package integrity
            ✅ Use multiple mirrors
            ✅ Implement mirror monitoring
        `
    },
    
    // 3. CDN Cache Poisoning
    cdnPoisoning: {
        description: 'Cache poisoning of CDN content',
        scenario: `
            Attacker poisons CDN cache
            Serves malicious tarballs
            Users get malware from CDN
        `,
        mitigation: `
            ✅ Use SRI (Subresource Integrity)
            ✅ Verify integrity hashes
            ✅ Use HTTPS
            ✅ Implement caching policies
        `
    }
};

// Example: Registry health monitoring
class RegistryHealthMonitor {
    constructor(registry) {
        this.registry = registry;
        this.healthChecks = [];
        this.alerts = [];
    }
    
    async checkRegistryHealth() {
        const checks = {
            // 1. Availability
            availability: await this.checkAvailability(),
            
            // 2. Response Time
            responseTime: await this.checkResponseTime(),
            
            // 3. Integrity
            integrity: await this.checkIntegrity(),
            
            // 4. Package Availability
            packages: await this.checkPackages(),
            
            // 5. Security Headers
            securityHeaders: await this.checkSecurityHeaders()
        };
        
        // Check for issues
        if (checks.availability.status !== 'healthy') {
            this.alerts.push({
                severity: 'CRITICAL',
                message: 'Registry unavailable',
                details: checks.availability
            });
        }
        
        if (checks.responseTime.responseTime > 1000) {
            this.alerts.push({
                severity: 'WARNING',
                message: 'High response time',
                details: `Response time: ${checks.responseTime.responseTime}ms`
            });
        }
        
        if (checks.integrity.status !== 'healthy') {
            this.alerts.push({
                severity: 'CRITICAL',
                message: 'Integrity check failed',
                details: checks.integrity
            });
        }
        
        return {
            status: this.alerts.some(a => a.severity === 'CRITICAL') ? 'unhealthy' : 'healthy',
            checks,
            alerts: this.alerts
        };
    }
    
    async checkAvailability() {
        try {
            const response = await this.registry.request('/-/ping');
            return {
                status: 'healthy',
                message: 'Registry is available'
            };
        } catch (error) {
            return {
                status: 'unhealthy',
                message: `Registry unavailable: ${error.message}`
            };
        }
    }
    
    async checkResponseTime() {
        const start = Date.now();
        try {
            await this.registry.request('/-/ping');
            const duration = Date.now() - start;
            return {
                responseTime: duration,
                status: duration < 500 ? 'healthy' : 
                       duration < 1000 ? 'degraded' : 'unhealthy'
            };
        } catch (error) {
            return {
                status: 'unhealthy',
                message: error.message
            };
        }
    }
    
    async checkIntegrity() {
        // Check a sample of packages for integrity
        const testPackages = ['express', 'lodash', 'react'];
        
        for (const pkg of testPackages) {
            try {
                const metadata = await this.registry.getMetadata(pkg, 'latest');
                const tarball = await this.registry.downloadTarball(pkg, metadata.version);
                
                // Verify integrity
                const hash = crypto.createHash('sha512');
                hash.update(tarball);
                const computed = `sha512-${hash.digest('base64')}`;
                
                if (computed !== metadata.integrity) {
                    return {
                        status: 'unhealthy',
                        message: `Integrity mismatch for ${pkg}`
                    };
                }
            } catch (error) {
                return {
                    status: 'degraded',
                    message: `Could not verify ${pkg}: ${error.message}`
                };
            }
        }
        
        return {
            status: 'healthy',
            message: 'Integrity checks passed'
        };
    }
    
    async checkSecurityHeaders() {
        try {
            const response = await this.registry.request('/');
            const headers = response.headers;
            
            const requiredHeaders = [
                'X-Content-Type-Options',
                'X-Frame-Options',
                'X-XSS-Protection',
                'Strict-Transport-Security'
            ];
            
            const missingHeaders = requiredHeaders.filter(h => !headers[h]);
            
            if (missingHeaders.length > 0) {
                return {
                    status: 'degraded',
                    message: `Missing security headers: ${missingHeaders.join(', ')}`
                };
            }
            
            return {
                status: 'healthy',
                message: 'Security headers present'
            };
        } catch (error) {
            return {
                status: 'unknown',
                message: `Could not check headers: ${error.message}`
            };
        }
    }
}
```

### 3. Account Compromise

```javascript
/**
 * ACCOUNT COMPROMISE
 * Attackers targeting package maintainer accounts
 */

const accountCompromise = {
    // 1. Credential Theft
    credentialTheft: {
        description: 'Stealing maintainer credentials',
        methods: [
            'Phishing',
            'Malware',
            'Credential reuse',
            'Session hijacking'
        ],
        impact: 'Malicious packages published under legitimate names',
        detection: `
            ✅ Monitor for unusual activity
            ✅ Check for new maintainers
            ✅ Verify 2FA usage
            ✅ Track account changes
        `
    },
    
    // 2. Social Engineering
    socialEngineering: {
        description: 'Manipulating maintainers into compromising accounts',
        methods: [
            'Fake security alerts',
            'Impersonation',
            'Fake package takedown requests',
            'Urgent requests for access'
        ],
        prevention: `
            ✅ Verify identities
            ✅ Use official communication channels
            ✅ Implement approval processes
            ✅ Train maintainers on security
        `
    },
    
    // 3. Insider Threats
    insiderThreats: {
        description: 'Legitimate maintainers going rogue',
        scenarios: [
            'Disgruntled employee',
            'Compromised maintainer',
            'Package sold to attacker',
            'Extortion attempt'
        ],
        detection: `
            ✅ Monitor maintainer behavior
            ✅ Implement code review
            ✅ Use multi-party approval
            ✅ Conduct regular audits
        `
    }
};

// Example: Account security monitoring
class AccountSecurityMonitor {
    constructor(registry) {
        this.registry = registry;
        this.suspiciousActivities = [];
        this.accountHistory = new Map();
    }
    
    async monitorAccount(accountId) {
        const history = this.accountHistory.get(accountId) || [];
        const recentActivity = await this.getRecentActivity(accountId);
        
        // Check for suspicious patterns
        const suspicions = [];
        
        // 1. Unusual login locations
        if (recentActivity.locations) {
            const unusualLocations = this.detectUnusualLocations(recentActivity.locations);
            if (unusualLocations.length > 0) {
                suspicions.push({
                    type: 'Unusual Login Location',
                    details: unusualLocations
                });
            }
        }
        
        // 2. Unusual publish patterns
        if (recentActivity.publishedPackages) {
            const unusualPublishes = this.detectUnusualPublishes(recentActivity.publishedPackages);
            if (unusualPublishes.length > 0) {
                suspicions.push({
                    type: 'Unusual Publish Pattern',
                    details: unusualPublishes
                });
            }
        }
        
        // 3. Account changes
        if (recentActivity.accountChanges) {
            const suspiciousChanges = this.detectSuspiciousChanges(recentActivity.accountChanges);
            if (suspiciousChanges.length > 0) {
                suspicions.push({
                    type: 'Suspicious Account Changes',
                    details: suspiciousChanges
                });
            }
        }
        
        // Update history
        this.accountHistory.set(accountId, recentActivity);
        
        // Store suspicions
        this.suspiciousActivities.push({
            accountId,
            timestamp: Date.now(),
            suspicions
        });
        
        return {
            accountId,
            suspicious: suspicions.length > 0,
            suspicions
        };
    }
    
    detectUnusualLocations(locations) {
        const unusual = [];
        const recent = locations.slice(-10);
        
        for (const location of recent) {
            // Check for uncommon countries
            if (this.isUncommonCountry(location.country)) {
                unusual.push(location);
            }
            
            // Check for multiple locations in short time
            const timeWindow = 3600000; // 1 hour
            const nearby = recent.filter(l => 
                l.country !== location.country &&
                Math.abs(l.timestamp - location.timestamp) < timeWindow
            );
            if (nearby.length > 0) {
                unusual.push(...nearby);
            }
        }
        
        return unusual;
    }
    
    detectUnusualPublishes(publishes) {
        const unusual = [];
        const recent = publishes.slice(-10);
        
        for (const publish of recent) {
            // Check for new package creation
            if (publish.isNewPackage && !this.isKnownPackage(publish.name)) {
                unusual.push(publish);
            }
            
            // Check for unusual version bumps
            if (publish.version && this.isUnusualVersionBump(publish.version)) {
                unusual.push(publish);
            }
        }
        
        return unusual;
    }
    
    detectSuspiciousChanges(changes) {
        const suspicious = [];
        
        for (const change of changes) {
            // Check for maintainer additions
            if (change.type === 'maintainer_added' && !this.knownMaintainers.includes(change.email)) {
                suspicious.push(change);
            }
            
            // Check for package deletion
            if (change.type === 'package_deleted') {
                suspicious.push(change);
            }
            
            // Check for ownership transfer
            if (change.type === 'ownership_transfer') {
                suspicious.push(change);
            }
        }
        
        return suspicious;
    }
    
    isUncommonCountry(country) {
        const commonCountries = ['US', 'GB', 'DE', 'FR', 'CA', 'AU', 'JP', 'KR', 'IN'];
        return !commonCountries.includes(country);
    }
    
    isKnownPackage(name) {
        // Check if package has existed for at least 30 days
        // Implementation would check registry history
        return true;
    }
    
    isUnusualVersionBump(version) {
        // Check for suspicious version numbers
        if (version.includes('999.0.0')) return true;
        if (version.includes('9999.0.0')) return true;
        if (version.includes('-malicious')) return true;
        if (version.includes('-hacked')) return true;
        return false;
    }
}
```

---

## Registry Best Practices

### Secure Registry Configuration

```javascript
/**
 * SECURE REGISTRY CONFIGURATION
 * Best practices for registry security
 */

const secureRegistryConfig = {
    // 1. .npmrc Configuration
    npmrc: `
        # .npmrc - Secure registry configuration
        
        # Use HTTPS
        registry=https://registry.npmjs.org/
        
        # Use private registry for scoped packages
        @company:registry=https://private-registry.company.com/
        
        # Always authenticate
        always-auth=true
        
        # Set strict SSL
        strict-ssl=true
        
        # Use specific registry for vulnerable packages
        @vulnerable:registry=https://vulnerability-registry.company.com/
        
        # Enable audit
        audit=true
        
        # Enable funding
        fund=false
    `,
    
    // 2. Registry Access Control
    accessControl: `
        # Restrict publishing to authorized users
        # Use npm team management
        npm team create @company:developers
        npm team add @company:developers user1 user2 user3
        
        # Set package access
        npm access restricted @company/package
        npm access public @company/package
        
        # Set package ownership
        npm owner add user1 @company/package
        npm owner rm user2 @company/package
        
        # Enable 2FA for publishing
        npm profile enable-2fa auth-only
        npm profile enable-2fa auth-and-writes
    `,
    
    // 3. Private Registry Setup (Verdaccio)
    verdaccio: `
        # verdaccio/config.yaml
        
        # Storage location
        storage: ./storage
        
        # Authentication
        auth:
          htpasswd:
            file: ./htpasswd
            max_users: 100
        
        # Access control
        packages:
          '@*/*':
            access: $authenticated
            publish: $authenticated
            unpublish: $authenticated
          '**':
            access: $authenticated
            publish: $authenticated
            unpublish: $authenticated
        
        # Uplinks
        uplinks:
          npmjs:
            url: https://registry.npmjs.org/
        
        # Logging
        logs:
          - {type: stdout, format: pretty, level: http}
    `
};

// Example: Secure registry client
class SecureRegistryClient {
    constructor(options = {}) {
        this.options = {
            registry: options.registry || 'https://registry.npmjs.org/',
            token: options.token || process.env.NPM_TOKEN,
            strictSSL: options.strictSSL !== false,
            timeout: options.timeout || 30000,
            retries: options.retries || 3,
            ...options
        };
        
        this.requestCount = 0;
        this.lastRequestTime = 0;
    }
    
    /**
     * Make a secure request to the registry
     */
    async request(endpoint, options = {}) {
        // Rate limiting
        await this.applyRateLimit();
        
        // Build request
        const url = new URL(endpoint, this.options.registry);
        const headers = {
            'Content-Type': 'application/json',
            'User-Agent': 'SecureRegistryClient/1.0.0'
        };
        
        // Add authentication
        if (this.options.token) {
            headers['Authorization'] = `Bearer ${this.options.token}`;
        }
        
        // Add OTP if available
        if (this.options.otp) {
            headers['npm-otp'] = this.options.otp;
        }
        
        // Make request with retries
        let lastError;
        for (let i = 0; i < this.options.retries; i++) {
            try {
                const response = await fetch(url, {
                    method: options.method || 'GET',
                    headers,
                    body: options.body ? JSON.stringify(options.body) : undefined,
                    timeout: this.options.timeout
                });
                
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
                }
                
                this.requestCount++;
                return await response.json();
                
            } catch (error) {
                lastError = error;
                if (i < this.options.retries - 1) {
                    const delay = Math.pow(2, i) * 1000;
                    await new Promise(resolve => setTimeout(resolve, delay));
                }
            }
        }
        
        throw lastError;
    }
    
    /**
     * Apply rate limiting
     */
    async applyRateLimit() {
        const now = Date.now();
        const rateLimit = 10; // requests per second
        const window = 1000;
        const interval = window / rateLimit;
        
        const elapsed = now - this.lastRequestTime;
        if (elapsed < interval) {
            const delay = interval - elapsed;
            await new Promise(resolve => setTimeout(resolve, delay));
        }
        
        this.lastRequestTime = Date.now();
    }
}
```

---

## Registry Security Threats Timeline

### Historical Incidents

```javascript
/**
 * REGISTRY SECURITY INCIDENTS
 * Major historical registry attacks
 */

const registryIncidents = {
    // 1. EventStream Hack (2018)
    eventStream: {
        date: 'November 2018',
        description: 'Malicious code injected into event-stream package',
        impact: 'Affected users of event-stream@3.3.6',
        details: `
            Attacker took over the package
            Added malicious code to steal cryptocurrency wallets
            Affected thousands of applications
        `,
        lesson: 'Monitor maintainer changes carefully'
    },
    
    // 2. ESLint Scope Hijack (2018)
    eslintHijack: {
        date: 'July 2018',
        description: 'ESLint packages hijacked via npm credentials',
        impact: 'Malicious versions published for 24 hours',
        details: `
            Attacker used stolen npm credentials
            Published malicious versions of eslint-scope
            Stole environment variables from users
        `,
        lesson: 'Use 2FA for package publishing'
    },
    
    // 3. FlatMap-Stream Attack (2020)
    flatMapStream: {
        date: 'September 2020',
        description: 'Malicious version of flatmap-stream published',
        impact: 'Affected users installing event-stream',
        details: `
            Attacker added malicious code to flatmap-stream
            Code targeted cryptocurrency wallets
            Remained undetected for weeks
        `,
        lesson: 'Audit transitive dependencies'
    },
    
    // 4. UA-Parser-JS Hack (2021)
    uaParserJS: {
        date: 'October 2021',
        description: 'ua-parser-js package compromised',
        impact: 'Malicious versions 0.7.29 and 0.8.0',
        details: `
            Attacker gained maintainer access
            Published versions with cryptominer
            Affected thousands of applications
        `,
        lesson: 'Implement package signing'
    },
    
    // 5. COA Hack (2021)
    coaHack: {
        date: 'November 2021',
        description: 'COA package compromised',
        impact: 'Malicious versions published',
        details: `
            Attacker stole maintainer credentials
            Published versions with malware
            Part of larger supply chain attack
        `,
        lesson: 'Enable 2FA for all maintainers'
    },
    
    // 6. Faker.js/Colors.js Protestware (2022)
    fakerColors: {
        date: 'January 2022',
        description: 'Protestware attack on popular packages',
        impact: 'Affected applications depending on faker.js and colors.js',
        details: `
            Maintainer intentionally broke packages
            Added malicious code to colors.js
            Destroyed faker.js repository
        `,
        lesson: 'Consider maintainer trust and stability'
    }
};
```

---

## Summary

| Aspect | Key Points |
|--------|------------|
| **Registry Architecture** | Central repository for package storage and distribution |
| **Security Model** | Authentication, integrity verification, access control |
| **Attack Vectors** | Name squatting, registry compromise, account takeover |
| **Best Practices** | Use 2FA, verify integrity, monitor activity |
| **Mitigation** | Private registries, package signing, continuous monitoring |
