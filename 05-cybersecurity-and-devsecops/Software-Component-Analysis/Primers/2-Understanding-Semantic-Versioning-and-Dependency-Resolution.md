# Primer 2: Understanding Semantic Versioning and Dependency Resolution

Welcome to the second primer of our tutorial series. This primer explains how npm handles versioning and dependency resolution—critical knowledge for understanding how packages are selected, installed, and potentially exploited in supply chain attacks.

---

## What is Semantic Versioning (SemVer)?

### The SemVer Format

Semantic Versioning is a versioning scheme that communicates meaning about the underlying changes in a release.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SEMANTIC VERSIONING (SemVer)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  MAJOR.MINOR.PATCH                                                         │
│    │     │     │                                                            │
│    │     │     └───► PATCH (0.0.1)                                         │
│    │     │           • Bug fixes                                            │
│    │     │           • No breaking changes                                 │
│    │     │           • No new features                                     │
│    │     │                                                                  │
│    │     └─────────► MINOR (0.1.0)                                        │
│    │                   • New features                                      │
│    │                   • No breaking changes                               │
│    │                   • Backward compatible                               │
│    │                                                                        │
│    └─────────────────► MAJOR (1.0.0)                                      │
│                        • Breaking changes                                  │
│                        • Incompatible API changes                          │
│                        • Major redesign                                    │
│                                                                              │
│  Pre-release versions: MAJOR.MINOR.PATCH-<tag>.<number>                   │
│  Example: 2.0.0-alpha.1, 2.0.0-beta.2, 2.0.0-rc.1                        │
│                                                                              │
│  Build metadata: MAJOR.MINOR.PATCH+<build>                                 │
│  Example: 1.0.0+20130313144700                                             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Version Comparison Examples

```javascript
/**
 * SEMVER COMPARISON EXAMPLES
 * How versions compare to each other
 */

const versionComparisons = {
    // Major version comparisons
    '1.0.0 < 2.0.0': true,
    '2.0.0 < 1.0.0': false,
    '1.0.0 === 1.0.0': true,
    
    // Minor version comparisons
    '1.0.0 < 1.1.0': true,
    '1.1.0 < 1.0.0': false,
    '1.1.0 === 1.1.0': true,
    
    // Patch version comparisons
    '1.0.0 < 1.0.1': true,
    '1.0.1 < 1.0.0': false,
    '1.0.1 === 1.0.1': true,
    
    // Pre-release comparisons
    '1.0.0-alpha < 1.0.0': true,
    '1.0.0-alpha.1 < 1.0.0-alpha.2': true,
    '1.0.0-alpha < 1.0.0-beta': true,
    '1.0.0-beta < 1.0.0-rc.1': true,
    '1.0.0-rc.1 < 1.0.0': true,
    
    // Mixed comparisons
    '1.0.0-alpha < 1.0.0-alpha.1': true,
    '1.0.0-alpha.1 < 1.0.0-alpha.beta': true,
    '1.0.0-alpha.beta < 1.0.0-beta': true
};
```

### Version Ranges

```javascript
/**
 * VERSION RANGE SYNTAX
 * How npm interprets version ranges
 */

const versionRanges = {
    // Exact version
    exact: '1.2.3',              // Exactly version 1.2.3
    
    // Caret (^)
    caret: '^1.2.3',             // 1.x.x (>=1.2.3 <2.0.0)
    '^0.2.3': '0.x.x (>=0.2.3 <0.3.0)',
    '^0.0.3': '0.0.x (>=0.0.3 <0.0.4)',
    '^1.0.0': '>=1.0.0 <2.0.0',
    
    // Tilde (~)
    tilde: '~1.2.3',             // 1.2.x (>=1.2.3 <1.3.0)
    '~1.2': '>=1.2.0 <1.3.0',
    '~1': '>=1.0.0 <2.0.0',
    
    // Inequality
    '>1.2.3': 'Greater than 1.2.3',
    '>=1.2.3': 'Greater than or equal to 1.2.3',
    '<1.2.3': 'Less than 1.2.3',
    '<=1.2.3': 'Less than or equal to 1.2.3',
    
    // Range
    '1.2.3 - 2.3.4': '>=1.2.3 <=2.3.4',
    
    // X (wildcard)
    '1.2.x': '1.2.x',
    '1.x.x': '1.x.x',
    '*': 'Any version',
    
    // OR
    '||': '1.2.3 || 1.3.0 - 2.0.0',
    
    // AND (implicit)
    '&&': '1.2.3 && 1.3.0 - 2.0.0',
    
    // Pre-release
    '-alpha': '1.2.3-alpha.1',
    '-beta': '1.2.3-beta.1',
    '-rc': '1.2.3-rc.1'
};
```

---

## Dependency Resolution

### How npm Resolves Dependencies

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NPM DEPENDENCY RESOLUTION                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Step 1: Parse package.json                                                │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  {                                                                   │  │
│  │    "dependencies": {                                                 │  │
│  │      "express": "^4.18.0",                                          │  │
│  │      "react": "^18.0.0"                                             │  │
│  │    }                                                                 │  │
│  │  }                                                                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  Step 2: Build dependency tree                                            │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  project@1.0.0                                                       │  │
│  │  ├── express@4.18.2                                                 │  │
│  │  │   ├── accepts@1.3.8                                              │  │
│  │  │   ├── body-parser@1.20.1                                         │  │
│  │  │   │   └── qs@6.11.0                                              │  │
│  │  │   └── debug@2.6.9                                                │  │
│  │  └── react@18.2.0                                                   │  │
│  │      ├── loose-envify@1.4.0                                         │  │
│  │      └── scheduler@0.23.0                                           │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  Step 3: Resolve conflicts (deduplication)                               │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  If two packages require different versions of the same package:    │  │
│  │                                                                      │  │
│  │  Package A requires lodash@^4.0.0                                   │  │
│  │  Package B requires lodash@^3.0.0                                   │  │
│  │                                                                      │  │
│  │  Result: Install both versions                                      │  │
│  │  node_modules/                                                      │  │
│  │  ├── lodash@4.17.21                                                │  │
│  │  └── package-b/                                                     │  │
│  │      └── node_modules/                                              │  │
│  │          └── lodash@3.10.1                                         │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  Step 4: Check lock file (if exists)                                     │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  package-lock.json records exact versions:                          │  │
│  │  "express": {                                                       │  │
│  │    "version": "4.18.2",                                             │  │
│  │    "resolved": "https://registry.npmjs.org/express/-/express-4.18.2.tgz",│
│  │    "integrity": "sha512-..."                                        │  │
│  │  }                                                                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Dependency Resolution Algorithm

```javascript
/**
 * NPM DEPENDENCY RESOLUTION ALGORITHM
 * Simplified version of how npm resolves dependencies
 */

class DependencyResolver {
    constructor() {
        this.registry = {}; // Package registry
        this.cache = {}; // Resolved dependencies
        this.conflicts = []; // Version conflicts
    }

    /**
     * Resolve all dependencies for a package
     */
    resolve(packageName, versionRange, path = []) {
        const key = `${packageName}@${versionRange}`;
        
        // Check cache
        if (this.cache[key]) {
            return this.cache[key];
        }
        
        // 1. Find the best matching version
        const version = this.findBestVersion(packageName, versionRange);
        if (!version) {
            throw new Error(`Could not find version for ${packageName}@${versionRange}`);
        }
        
        // 2. Get package metadata
        const packageInfo = this.registry[packageName]?.[version];
        if (!packageInfo) {
            throw new Error(`Package ${packageName}@${version} not found`);
        }
        
        // 3. Resolve dependencies
        const resolvedDependencies = {};
        const dependencies = packageInfo.dependencies || {};
        
        for (const [depName, depRange] of Object.entries(dependencies)) {
            // Check for circular dependencies
            if (path.includes(depName)) {
                console.warn(`Circular dependency detected: ${path.join(' -> ')} -> ${depName}`);
                continue;
            }
            
            // Resolve the dependency
            const depPath = [...path, packageName];
            resolvedDependencies[depName] = this.resolve(
                depName, 
                depRange, 
                depPath
            );
        }
        
        // 4. Resolve conflicts
        const resolved = {
            name: packageName,
            version: version,
            dependencies: resolvedDependencies
        };
        
        // Cache the result
        this.cache[key] = resolved;
        
        return resolved;
    }

    /**
     * Find the best version matching a range
     */
    findBestVersion(packageName, versionRange) {
        const versions = this.registry[packageName] || {};
        const versionKeys = Object.keys(versions);
        
        // Parse the version range
        const range = this.parseRange(versionRange);
        
        // Find versions that satisfy the range
        const satisfyingVersions = versionKeys.filter(v => 
            this.satisfiesRange(v, range)
        );
        
        if (satisfyingVersions.length === 0) {
            return null;
        }
        
        // Sort by semantic versioning
        satisfyingVersions.sort((a, b) => this.compareVersions(a, b));
        
        // Return the latest version
        return satisfyingVersions[satisfyingVersions.length - 1];
    }

    /**
     * Parse a version range
     */
    parseRange(versionRange) {
        // Simplified range parser
        if (versionRange.startsWith('^')) {
            const version = versionRange.slice(1);
            const parts = version.split('.');
            return {
                type: 'caret',
                major: parseInt(parts[0]),
                minor: parseInt(parts[1]) || 0,
                patch: parseInt(parts[2]) || 0
            };
        } else if (versionRange.startsWith('~')) {
            const version = versionRange.slice(1);
            const parts = version.split('.');
            return {
                type: 'tilde',
                major: parseInt(parts[0]),
                minor: parseInt(parts[1]) || 0,
                patch: parseInt(parts[2]) || 0
            };
        } else if (versionRange.includes('||')) {
            // OR range
            const ranges = versionRange.split('||');
            return {
                type: 'or',
                ranges: ranges.map(r => this.parseRange(r.trim()))
            };
        } else {
            // Exact version or other
            return {
                type: 'exact',
                version: versionRange
            };
        }
    }

    /**
     * Check if a version satisfies a range
     */
    satisfiesRange(version, range) {
        const parts = version.split('.').map(Number);
        const major = parts[0];
        const minor = parts[1] || 0;
        const patch = parts[2] || 0;
        
        switch (range.type) {
            case 'caret':
                if (range.major === 0) {
                    // 0.x.x releases
                    return major === 0 && minor >= range.minor;
                } else {
                    // 1.x.x releases
                    return major === range.major && minor >= range.minor;
                }
                
            case 'tilde':
                return major === range.major && 
                       minor === range.minor && 
                       patch >= range.patch;
                       
            case 'exact':
                return version === range.version;
                
            case 'or':
                return range.ranges.some(r => this.satisfiesRange(version, r));
                
            default:
                return false;
        }
    }

    /**
     * Compare two versions
     */
    compareVersions(a, b) {
        const aParts = a.split('.').map(Number);
        const bParts = b.split('.').map(Number);
        
        for (let i = 0; i < Math.max(aParts.length, bParts.length); i++) {
            const aVal = aParts[i] || 0;
            const bVal = bParts[i] || 0;
            
            if (aVal !== bVal) {
                return aVal - bVal;
            }
        }
        
        return 0;
    }
}
```

---

## Lock Files

### package-lock.json Structure

```javascript
/**
 * PACKAGE-LOCK.JSON STRUCTURE
 * Understanding the lock file format
 */

const lockFileExample = {
    "name": "my-project",
    "version": "1.0.0",
    "lockfileVersion": 2,
    "requires": true,
    "packages": {
        "": {
            "name": "my-project",
            "version": "1.0.0",
            "dependencies": {
                "express": "^4.18.0"
            }
        },
        "node_modules/express": {
            "version": "4.18.2",
            "resolved": "https://registry.npmjs.org/express/-/express-4.18.2.tgz",
            "integrity": "sha512-...",
            "dependencies": {
                "accepts": "~1.3.8",
                "body-parser": "1.20.1"
            }
        },
        "node_modules/accepts": {
            "version": "1.3.8",
            "resolved": "https://registry.npmjs.org/accepts/-/accepts-1.3.8.tgz",
            "integrity": "sha512-...",
            "dependencies": {
                "mime-types": "~2.1.34",
                "negotiator": "0.6.3"
            }
        },
        "node_modules/body-parser": {
            "version": "1.20.1",
            "resolved": "https://registry.npmjs.org/body-parser/-/body-parser-1.20.1.tgz",
            "integrity": "sha512-...",
            "dependencies": {
                "bytes": "3.1.2",
                "content-type": "~1.0.4",
                "debug": "2.6.9"
            }
        }
    }
};
```

### Lock File Benefits and Risks

```javascript
/**
 * LOCK FILE BENEFITS AND SECURITY RISKS
 * Understanding the trade-offs
 */

const lockFileAnalysis = {
    benefits: {
        deterministic: `
            ✅ Ensures every installation uses the exact same versions
            ✅ Prevents unexpected version changes
            ✅ Enables reproducible builds
            ✅ Speeds up installation (no version resolution)
        `,
        integrity: `
            ✅ Includes integrity hashes (sha512)
            ✅ Verifies package contents match
            ✅ Prevents tampering during download
        `,
        transitive: `
            ✅ Records all transitive dependencies
            ✅ Shows complete dependency tree
            ✅ Enables auditing of all dependencies
        `
    },
    
    risks: {
        staleness: `
            ⚠️ Can become stale if not updated regularly
            ⚠️ May include outdated packages with vulnerabilities
            ⚠️ Update risk: developers may forget to update lock files
        `,
        bloat: `
            ⚠️ Can become very large (thousands of lines)
            ⚠️ Difficult to review manually
            ⚠️ Merge conflicts can be challenging
        `,
        supplyChain: `
            ⚠️ Lock file doesn't prevent malicious package versions
            ⚠️ If a malicious version is locked, it will be installed
            ⚠️ Integrity hashes can be forged in MITM attacks
        `
    },
    
    bestPractices: `
        ✅ Always commit lock files to version control
        ✅ Update lock files regularly (npm update)
        ✅ Audit dependencies regularly (npm audit)
        ✅ Use package-lock.json for deterministic builds
        ✅ Review lock file changes in pull requests
        ✅ Use --no-optional to avoid optional dependencies
    `
};
```

---

## Dependency Resolution Security Implications

### Version Confusion Attacks

```javascript
/**
 * VERSION CONFUSION ATTACKS
 * Exploiting version resolution to install malicious packages
 */

const versionConfusionAttacks = {
    // 1. Dependency Confusion
    dependencyConfusion: {
        description: 'Publishing internal package names to public registry',
        scenario: `
            Internal package: @company/internal-utils
            Attacker publishes: internal-utils@999.0.0 to npm
            npm installs the higher version from public registry
        `,
        mitigation: `
            ✅ Use scoped packages (@company/package)
            ✅ Configure private registry for scoped packages
            ✅ Use --registry flag to specify registry
            ✅ Use .npmrc to configure registries
            ✅ Pin exact versions with lock files
            ✅ Use npm config to prevent public installation
        `,
        example: `
            // .npmrc
            @company:registry=https://private-registry.company.com
            // Prevents public installation
            always-auth=true
        `
    },
    
    // 2. Version Pinning Bypass
    versionPinningBypass: {
        description: 'Using version ranges that allow unexpected updates',
        scenario: `
            Dependency: "express": "^4.18.0"
            npm may install 4.18.2 (patch) or 4.19.0 (minor)
            If 4.19.0 has a vulnerability, it will be installed
        `,
        mitigation: `
            ✅ Use exact versions in production
            ✅ Use lock files to pin exact versions
            ✅ Review range usage
            ✅ Use npm shrinkwrap for strict control
        `,
        example: `
            // Use exact version
            "express": "4.18.2"
            
            // Or use with lock file
            "express": "^4.18.0"  // Lock file ensures exact version
        `
    },
    
    // 3. Lock File Poisoning
    lockFilePoisoning: {
        description: 'Falsifying lock file integrity hashes',
        scenario: `
            Attacker modifies package-lock.json
            Changes integrity hash to match malicious package
            User runs npm install, downloads malicious version
        `,
        mitigation: `
            ✅ Use npm ci in CI/CD
            ✅ Verify lock file integrity with git
            ✅ Use npm audit to verify
            ✅ Use package-lock.json signatures
            ✅ Run npm install --no-audit to skip audit
        `,
        example: `
            // npm ci uses lock file exclusively
            npm ci  // Only installs from lock file
            
            // Verify lock file
            npm install --package-lock-only
        `
    },
    
    // 4. Registry Hijacking
    registryHijacking: {
        description: 'Hijacking npm registry or package names',
        scenario: `
            Attacker takes over a package name
            Publishes malicious version
            npm install downloads malicious version
        `,
        mitigation: `
            ✅ Use npm audit to check for known malicious packages
            ✅ Use package signing (npm sign)
            ✅ Monitor package activity
            ✅ Use private registries
            ✅ Implement security policies
        `,
        example: `
            // Check package provenance
            npm audit
            
            // Use verified packages
            npm install --provenance
        `
    }
};
```

### Dependency Tree Exploitation

```javascript
/**
 * DEPENDENCY TREE EXPLOITATION
 * How attackers exploit the dependency tree
 */

const treeExploitation = {
    // 1. Deep Transitive Dependencies
    deepTransitive: {
        description: 'Hiding malicious code in deep transitive dependencies',
        scenario: `
            Package A depends on Package B
            Package B depends on Package C (malicious)
            C is installed automatically and executes
            No one reviews C because it's deep in the tree
        `,
        impact: 'Malicious code can be hidden 10+ levels deep',
        detection: `
            ✅ Scan all transitive dependencies
            ✅ Use dependency graph visualization
            ✅ Monitor package popularity (sudden changes)
            ✅ Audit all dependencies, including transitive
        `,
        example: `
            // Find all transitive dependencies
            npm ls --all
            
            // Visualize dependency graph
            npm ls --depth=10
            npm ls --parseable
        `
    },
    
    // 2. Duplicate Installation
    duplicateInstallation: {
        description: 'Exploiting duplicate package installations',
        scenario: `
            Package A installs lodash@4.17.21
            Package B installs lodash@3.10.1
            Both versions are installed
            Attacker targets the older, vulnerable version
        `,
        impact: 'Vulnerable versions remain even with updates',
        detection: `
            ✅ Check for duplicate versions
            ✅ Audit all versions installed
            ✅ Use npm dedupe to resolve duplicates
        `,
        example: `
            // Find duplicate versions
            npm ls --depth=1
            
            // Deduplicate
            npm dedupe
            
            // Check for vulnerable duplicates
            npm audit --production
        `
    },
    
    // 3. Package Replacement
    packageReplacement: {
        description: 'Replacing a package with a malicious version',
        scenario: `
            Attacker publishes a malicious version
            npm install picks the malicious version
            Package behaves normally but has backdoor
        `,
        impact: 'Hard to detect because behavior appears normal',
        detection: `
            ✅ Use behavioral analysis (Socket)
            ✅ Check for capability changes
            ✅ Monitor package version changes
            ✅ Audit package source code
        `,
        example: `
            // Check package capabilities
            node phase-2/test-capability-scanner.js
            
            // Compare versions
            npm view <package> versions
            npm view <package> dist-tags
        `
    }
};
```

---

## Security Best Practices for Versioning

### Version Management Policy

```javascript
/**
 * VERSION MANAGEMENT SECURITY POLICY
 * Best practices for managing versions securely
 */

const versionManagementPolicy = {
    // 1. Version Pinning
    versionPinning: {
        production: `
            ✅ Pin exact versions in production
            ✅ Use lock files for all environments
            ✅ Use npm ci instead of npm install in CI/CD
            ✅ Review version changes before deployment
        `,
        development: `
            ✅ Use ranges in development for compatibility
            ✅ Pin versions in package-lock.json
            ✅ Update lock file regularly
            ✅ Test with latest versions
        `,
        example: `
            // package.json (production)
            {
                "dependencies": {
                    "express": "4.18.2",
                    "react": "18.2.0"
                }
            }
            
            // package.json (development)
            {
                "dependencies": {
                    "express": "^4.18.0",
                    "react": "^18.0.0"
                }
            }
        `
    },
    
    // 2. Update Strategy
    updateStrategy: {
        security: `
            ✅ Apply security updates immediately
            ✅ Test updates in staging environment
            ✅ Monitor for vulnerabilities
            ✅ Use automated update tools (Dependabot)
        `,
        minor: `
            ✅ Plan minor updates regularly
            ✅ Test compatibility
            ✅ Review changelogs
            ✅ Monitor for breaking changes
        `,
        major: `
            ✅ Plan major updates carefully
            ✅ Test extensively
            ✅ Review API changes
            ✅ Plan migration strategy
        `
    },
    
    // 3. Version Validation
    versionValidation: {
        preInstall: `
            ✅ Validate version ranges
            ✅ Check for suspicious version patterns
            ✅ Verify package integrity
            ✅ Scan for known vulnerabilities
        `,
        postInstall: `
            ✅ Verify installed versions
            ✅ Audit for vulnerabilities
            ✅ Check for unexpected behavior
            ✅ Monitor for anomalies
        `,
        example: `
            // Validate version before install
            const semver = require('semver');
            const version = '1.2.3';
            
            if (!semver.valid(version)) {
                throw new Error('Invalid version');
            }
            
            // Check for suspicious versions
            if (version.includes('alpha') || version.includes('beta')) {
                console.warn('Pre-release version detected');
            }
        `
    }
};
```

### Automated Version Management

```javascript
/**
 * AUTOMATED VERSION MANAGEMENT
 * Tools and scripts for secure version management
 */

const automatedVersionManagement = {
    // 1. Dependabot Configuration
    dependabot: `
        # .github/dependabot.yml
        version: 2
        updates:
          - package-ecosystem: "npm"
            directory: "/"
            schedule:
              interval: "weekly"
              day: "monday"
              time: "09:00"
            open-pull-requests-limit: 10
            ignore:
              - dependency-name: "express"
                versions: ["5.x.x"]  # Ignore major version
            labels:
              - "dependencies"
              - "security"
            commit-message:
              prefix: "fix(deps)"
    `,
    
    // 2. Update Script
    updateScript: `
        // scripts/update-dependencies.js
        const { execSync } = require('child_process');
        const fs = require('fs');
        
        async function updateDependencies() {
            console.log('🔄 Updating dependencies...');
            
            // 1. Check for outdated packages
            const outdated = execSync('npm outdated --json', { encoding: 'utf8' });
            const outdatedPackages = JSON.parse(outdated);
            
            // 2. Update each package
            for (const [name, info] of Object.entries(outdatedPackages)) {
                console.log(\`📦 Updating \${name} from \${info.current} to \${info.latest}\`);
                
                // Check for breaking changes
                const breaking = checkForBreakingChanges(name, info.current, info.latest);
                if (breaking) {
                    console.log(\`⚠️  Breaking changes detected for \${name}\`);
                    continue;
                }
                
                // Update
                execSync(\`npm install \${name}@\${info.latest}\`);
                
                // Run tests
                try {
                    execSync('npm test', { stdio: 'pipe' });
                } catch (error) {
                    console.log(\`❌ Tests failed after updating \${name}\`);
                    execSync(\`npm install \${name}@\${info.current}\`);
                }
            }
            
            // 3. Update lock file
            execSync('npm install --package-lock-only');
        }
    `,
    
    // 3. Vulnerability Check Script
    vulnerabilityCheck: `
        // scripts/check-vulnerabilities.js
        const { execSync } = require('child_process');
        
        function checkVulnerabilities() {
            console.log('🔍 Checking for vulnerabilities...');
            
            // Run npm audit
            const output = execSync('npm audit --json', { encoding: 'utf8' });
            const audit = JSON.parse(output);
            
            // Check for critical vulnerabilities
            const critical = audit.vulnerabilities?.critical || {};
            const criticalCount = Object.keys(critical).length;
            
            if (criticalCount > 0) {
                console.log(\`🚨 Found \${criticalCount} critical vulnerabilities!\`);
                console.log('Packages with critical issues:');
                for (const [name, data] of Object.entries(critical)) {
                    console.log(\`  - \${name}: \${data.title}\`);
                }
                process.exit(1);
            }
            
            console.log('✅ No critical vulnerabilities found');
            return audit;
        }
    `
};
```

---

## Summary

| Concept | Key Points |
|---------|------------|
| **SemVer** | Major.Minor.Patch - communicates change significance |
| **Version Ranges** | ^, ~, >, <, ranges - determine what versions are allowed |
| **Lock Files** | Pin exact versions, ensure reproducible builds |
| **Dependency Resolution** | npm resolves conflicts, uses deduplication |
| **Security Risks** | Dependency confusion, version pinning bypass, lock file poisoning |
| **Best Practices** | Pin versions, use lock files, audit regularly, automate updates |
