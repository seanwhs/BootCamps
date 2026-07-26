# PRIMER 5: Environment Variables and Configuration

## Welcome to the Environment Variables Primer!

Every real-world application needs to handle configuration — database credentials, API keys, port numbers, and environment-specific settings. Environment variables are the industry-standard way to manage these settings securely and flexibly.

### What This Primer Covers

| Section | Topic | What You'll Learn |
|---------|-------|-------------------|
| 1 | What Are Environment Variables? | The concept and why they matter |
| 2 | Using Environment Variables in Node.js | `process.env` and accessing variables |
| 3 | The .env File | Managing variables with dotenv |
| 4 | Configuration Best Practices | Organizing and validating config |
| 5 | Environment-Specific Config | Development, testing, production |
| 6 | Security Considerations | Keeping secrets safe |
| 7 | Advanced Configuration Patterns | Config factories, hierarchical config |
| 8 | Deployment Configurations | Setting vars on hosting platforms |

---

## Section 1: What Are Environment Variables?

**Environment variables** are dynamic values that affect how running processes behave on a computer. They're like settings that your application can read at runtime.

### A Simple Analogy

Think of environment variables like the **settings on a thermostat**:

```
┌─────────────────────────────────────────────────────────────┐
│                    Thermostat Analogy                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Thermostat Settings    →    Environment Variables          │
│                                                             │
│  Temperature: 72°F      →    PORT=3000                     │
│  Mode: Heat             →    NODE_ENV=production           │
│  Schedule: Away         →    DB_HOST=localhost             │
│  WiFi Password          →    JWT_SECRET=secret123          │
│                                                             │
│  Just like a thermostat controls how your HVAC system       │
│  behaves, environment variables control how your            │
│  application behaves in different environments.             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why Environment Variables?

| Benefit | Explanation |
|---------|-------------|
| **Security** | Keep secrets out of your source code |
| **Flexibility** | Change settings without redeploying |
| **Portability** | Same code works in different environments |
| **Team Collaboration** | Each developer can use their own settings |
| **Container Support** | Essential for Docker and cloud deployments |
| **Industry Standard** | Used by all major platforms and frameworks |

### Common Use Cases

```javascript
// 1. Server configuration
PORT=3000
HOST=localhost

// 2. Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=admin
DB_PASSWORD=secret

// 3. API keys and secrets
JWT_SECRET=your-secret-key
API_KEY=abc123
STRIPE_SECRET_KEY=sk_test_...

// 4. Feature flags
ENABLE_LOGGING=true
ENABLE_CACHE=false
FEATURE_NEW_UI=true

// 5. Environment identification
NODE_ENV=development
APP_ENV=production
```

---

## Section 2: Using Environment Variables in Node.js

### Accessing Environment Variables

Node.js makes environment variables available through `process.env`, which is a global object containing all environment variables.

```javascript
// Accessing environment variables
const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';
const dbHost = process.env.DB_HOST || 'localhost';

console.log(`Server running on port ${port}`);
console.log(`Environment: ${nodeEnv}`);

// Checking if a variable exists
if (process.env.API_KEY) {
    console.log('API key is set');
} else {
    console.log('API key is not set, using default');
}

// All environment variables
console.log(process.env);
// Or for specific keys
Object.keys(process.env).forEach(key => {
    console.log(`${key}: ${process.env[key]}`);
});
```

### Setting Environment Variables

#### Method 1: Command Line (Temporary)

```bash
# Single variable
PORT=3000 node server.js

# Multiple variables
PORT=3000 NODE_ENV=development DB_HOST=localhost node server.js

# On Windows (Command Prompt)
set PORT=3000 && node server.js

# On Windows (PowerShell)
$env:PORT=3000; node server.js
```

#### Method 2: Export in Shell (Session)

```bash
# Set for current terminal session
export PORT=3000
export NODE_ENV=development

# Run your app
node server.js

# Check variables
echo $PORT
```

#### Method 3: Package.json Scripts

```json
{
  "scripts": {
    "start": "NODE_ENV=production node server.js",
    "dev": "NODE_ENV=development nodemon server.js",
    "test": "NODE_ENV=test jest"
  }
}
```

### Type Safety with Environment Variables

```javascript
// Basic type conversion
const port = parseInt(process.env.PORT, 10) || 3000;
const isProduction = process.env.NODE_ENV === 'production';
const isDebug = process.env.DEBUG === 'true';
const timeout = parseInt(process.env.TIMEOUT_MS, 10) || 5000;

// Validate required variables
function requireEnv(name) {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Required environment variable ${name} is not set`);
    }
    return value;
}

// Usage
const apiKey = requireEnv('API_KEY');
const jwtSecret = requireEnv('JWT_SECRET');
```

---

## Section 3: The .env File

### What is a .env File?

A `.env` file is a plain text file that stores environment variables in a simple key-value format. It's the most common way to manage environment variables in Node.js applications.

```bash
# .env file example
# Server
PORT=3000
NODE_ENV=development

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=admin
DB_PASSWORD=secret123

# APIs
JWT_SECRET=your-super-secret-jwt-key
API_KEY=test-api-key-123

# Feature flags
ENABLE_LOGGING=true
ENABLE_CACHE=false
```

### Using dotenv

The `dotenv` package loads environment variables from a `.env` file into `process.env`.

```bash
npm install dotenv
```

```javascript
// Load .env file (at the very top of your entry file)
require('dotenv').config();

// Now you can access the variables
console.log(process.env.PORT);
console.log(process.env.DB_HOST);

// With error handling
const result = require('dotenv').config();
if (result.error) {
    console.error('Failed to load .env file:', result.error);
} else {
    console.log('Environment variables loaded successfully');
}
```

### .env File Best Practices

```bash
# 1. Never commit .env to version control
# .gitignore
.env
.env.local
.env.*.local
.env.production

# 2. Create a .env.example file
# .env.example (commit this!)
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_db_name
DB_USER=your_username
DB_PASSWORD=your_password
JWT_SECRET=change-this-in-production
API_KEY=your-api-key-here

# 3. Use different .env files for different environments
# .env.development - Development settings
# .env.test - Test settings
# .env.production - Production settings

# 4. Keep it organized
# Server settings
PORT=3000
HOST=localhost

# Database settings
# ---
DB_HOST=localhost
DB_PORT=5432

# Security
# ---
JWT_SECRET=your-secret-key

# 5. Use comments for documentation
# Port the server will listen on
PORT=3000

# Environment: development, test, production
NODE_ENV=development
```

### Loading Custom .env Files

```javascript
// Load specific .env file based on environment
const path = require('path');
require('dotenv').config({
    path: path.join(__dirname, `.env.${process.env.NODE_ENV || 'development'}`)
});

// Load multiple files (development)
require('dotenv').config({ path: '.env' });
require('dotenv').config({ path: '.env.local', override: true });
require('dotenv').config({ path: `.env.${process.env.NODE_ENV}`, override: true });

// Custom example
const envFile = process.env.NODE_ENV === 'production' 
    ? '.env.production' 
    : '.env.development';

require('dotenv').config({ path: envFile });
```

---

## Section 4: Configuration Best Practices

### Configuration Module

Create a dedicated configuration module to centralize all environment variable access.

```javascript
// =====================================================
// FILE: config/config.js
// DESCRIPTION: Centralized configuration
// =====================================================

require('dotenv').config();

const config = {
    // Server
    port: parseInt(process.env.PORT, 10) || 3000,
    host: process.env.HOST || 'localhost',
    env: process.env.NODE_ENV || 'development',

    // Database
    database: {
        host: process.env.DB_HOST || 'localhost',
        port: parseInt(process.env.DB_PORT, 10) || 5432,
        name: process.env.DB_NAME || 'mydb',
        user: process.env.DB_USER || 'admin',
        password: process.env.DB_PASSWORD || '',
    },

    // Security
    security: {
        jwtSecret: process.env.JWT_SECRET,
        apiKey: process.env.API_KEY,
        bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS, 10) || 12,
    },

    // Features
    features: {
        logging: process.env.ENABLE_LOGGING === 'true',
        caching: process.env.ENABLE_CACHE === 'true',
        debug: process.env.DEBUG === 'true',
    },

    // External APIs
    apis: {
        stripeSecretKey: process.env.STRIPE_SECRET_KEY,
        sendgridApiKey: process.env.SENDGRID_API_KEY,
    },

    // Helper methods
    isDevelopment: () => process.env.NODE_ENV === 'development',
    isProduction: () => process.env.NODE_ENV === 'production',
    isTest: () => process.env.NODE_ENV === 'test',

    // Validation
    validate: () => {
        const required = ['JWT_SECRET', 'API_KEY'];
        const missing = required.filter(key => !process.env[key]);
        if (missing.length > 0) {
            throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
        }
        return true;
    }
};

module.exports = config;
```

### Using the Configuration Module

```javascript
// In your application
const config = require('./config/config');

console.log(`Server running on port ${config.port}`);
console.log(`Environment: ${config.env}`);

// Database connection
const dbConfig = config.database;
const connectionString = `postgres://${dbConfig.user}:${dbConfig.password}@${dbConfig.host}:${dbConfig.port}/${dbConfig.name}`;

// Feature flags
if (config.features.logging) {
    console.log('Logging is enabled');
}

// Validate configuration
try {
    config.validate();
    console.log('Configuration valid');
} catch (error) {
    console.error('Configuration error:', error.message);
    process.exit(1);
}
```

### Validation with Joi

```javascript
// =====================================================
// FILE: config/validation.js
// DESCRIPTION: Environment variable validation with Joi
// =====================================================

const Joi = require('joi');
require('dotenv').config();

// Define schema for environment variables
const envSchema = Joi.object({
    // Required
    NODE_ENV: Joi.string()
        .valid('development', 'production', 'test')
        .default('development'),
    PORT: Joi.number().default(3000),
    JWT_SECRET: Joi.string().required(),
    API_KEY: Joi.string().required(),

    // Optional with defaults
    DB_HOST: Joi.string().default('localhost'),
    DB_PORT: Joi.number().default(5432),
    DB_NAME: Joi.string().default('mydb'),
    DB_USER: Joi.string().default('admin'),
    DB_PASSWORD: Joi.string().default(''),
    
    BCRYPT_ROUNDS: Joi.number().default(12),
    ENABLE_LOGGING: Joi.boolean().default(true),
    ENABLE_CACHE: Joi.boolean().default(false),
}).unknown(); // Allow other variables not in schema

// Validate
const { error, value: validatedEnv } = envSchema.validate(process.env, {
    abortEarly: false, // Return all errors
    stripUnknown: true, // Remove unknown keys
});

if (error) {
    console.error('❌ Invalid environment configuration:');
    error.details.forEach(detail => {
        console.error(`  - ${detail.message}`);
    });
    process.exit(1);
}

// Export validated config
module.exports = {
    env: validatedEnv.NODE_ENV,
    port: validatedEnv.PORT,
    jwtSecret: validatedEnv.JWT_SECRET,
    apiKey: validatedEnv.API_KEY,
    database: {
        host: validatedEnv.DB_HOST,
        port: validatedEnv.DB_PORT,
        name: validatedEnv.DB_NAME,
        user: validatedEnv.DB_USER,
        password: validatedEnv.DB_PASSWORD,
    },
    bcryptRounds: validatedEnv.BCRYPT_ROUNDS,
    features: {
        logging: validatedEnv.ENABLE_LOGGING,
        caching: validatedEnv.ENABLE_CACHE,
    },
};
```

---

## Section 5: Environment-Specific Configuration

### Environment-Based Configuration

```javascript
// =====================================================
// FILE: config/index.js
// DESCRIPTION: Environment-specific configuration
// =====================================================

const base = {
    appName: 'MyApp',
    version: '1.0.0',
    
    // Common settings
    logging: {
        level: 'info',
        format: 'json',
    },
};

const development = {
    ...base,
    env: 'development',
    debug: true,
    logging: {
        ...base.logging,
        level: 'debug',
        format: 'pretty',
    },
    database: {
        host: 'localhost',
        port: 5432,
        name: 'app_dev',
        user: 'dev_user',
        password: 'dev_password',
    },
    apiUrl: 'http://localhost:3000',
};

const production = {
    ...base,
    env: 'production',
    debug: false,
    logging: {
        ...base.logging,
        level: 'info',
        format: 'json',
    },
    database: {
        host: process.env.DB_HOST,
        port: parseInt(process.env.DB_PORT, 10),
        name: process.env.DB_NAME,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
    },
    apiUrl: process.env.API_URL,
};

const test = {
    ...base,
    env: 'test',
    debug: false,
    logging: {
        ...base.logging,
        level: 'error',
        format: 'pretty',
    },
    database: {
        host: 'localhost',
        port: 5432,
        name: 'app_test',
        user: 'test_user',
        password: 'test_password',
    },
    apiUrl: 'http://localhost:3001',
};

// Export based on environment
const env = process.env.NODE_ENV || 'development';

const configs = { development, production, test };
module.exports = configs[env] || development;
```

### Feature Flags

```javascript
// =====================================================
// FILE: config/features.js
// DESCRIPTION: Feature flags for gradual rollout
// =====================================================

const features = {
    // Core features (always on)
    core: {
        userAuth: true,
        taskManagement: true,
    },

    // Beta features (controlled by environment or user)
    beta: {
        darkMode: process.env.ENABLE_DARK_MODE === 'true',
        aiAssistant: process.env.ENABLE_AI_ASSISTANT === 'true',
        newDashboard: process.env.ENABLE_NEW_DASHBOARD === 'true',
    },

    // Experimental features (internal use)
    experimental: {
        realTimeSync: process.env.ENABLE_REALTIME_SYNC === 'true',
        webhooks: process.env.ENABLE_WEBHOOKS === 'true',
    },

    // Check if a feature is enabled
    isEnabled: (feature, category = 'beta') => {
        if (category === 'core') {
            return features.core[feature] || false;
        }
        return features[category]?.[feature] || false;
    },

    // Get all enabled features
    getAllEnabled: () => {
        return {
            ...features.core,
            ...features.beta,
            ...features.experimental,
        };
    },
};

module.exports = features;
```

---

## Section 6: Security Considerations

### Keeping Secrets Safe

```javascript
// 1. Never commit .env files
// Add to .gitignore:
.env
.env.*
*.env
.env.local

// 2. Use .env.example for documentation
# .env.example
JWT_SECRET=your-secret-key-here
DB_PASSWORD=your-password-here

// 3. Use different secrets for different environments
// Production should use strong, unique secrets
// Development can use simpler values

// 4. Rotate secrets periodically
// Change JWT_SECRET, API keys regularly

// 5. Use secrets management tools
// - AWS Secrets Manager
// - HashiCorp Vault
// - Azure Key Vault
// - Google Secret Manager
```

### Avoiding Common Mistakes

```javascript
// ❌ DON'T: Hardcode secrets in code
const jwtSecret = 'my-super-secret-key'; // NEVER DO THIS!

// ✅ DO: Use environment variables
const jwtSecret = process.env.JWT_SECRET;

// ❌ DON'T: Expose environment variables to clients
app.get('/api/env', (req, res) => {
    res.json(process.env); // NEVER DO THIS!
});

// ✅ DO: Only expose what's necessary
app.get('/api/config', (req, res) => {
    res.json({
        env: process.env.NODE_ENV,
        version: '1.0.0',
        // Only expose safe values
    });
});

// ❌ DON'T: Log environment variables
console.log(process.env); // NEVER DO THIS IN PRODUCTION!

// ✅ DO: Log only what's safe
console.log(`Environment: ${process.env.NODE_ENV}`);
console.log(`Port: ${process.env.PORT}`);
```

### Environment Variable Security Checklist

```bash
# 1. Secrets in environment variables
✅ JWT_SECRET stored in .env
✅ Database passwords stored in .env
✅ API keys stored in .env

# 2. .gitignore configuration
✅ .env in .gitignore
✅ .env.* in .gitignore
✅ .env.example in repository (with placeholder values)

# 3. Validation
✅ Required variables validated at startup
✅ Configuration validation with Joi or similar

# 4. Production considerations
✅ Secrets not logged
✅ Secrets not exposed in error messages
✅ Environment variables set securely in deployment

# 5. Access control
✅ Only application has access to secrets
✅ Developers use local .env files
✅ Production secrets managed securely
```

---

## Section 7: Advanced Configuration Patterns

### Configuration Factory Pattern

```javascript
// =====================================================
// FILE: config/factory.js
// DESCRIPTION: Configuration factory for dynamic config
// =====================================================

class ConfigFactory {
    constructor() {
        this.configs = new Map();
        this.defaults = {};
    }

    // Register a configuration
    register(name, config) {
        this.configs.set(name, config);
        return this;
    }

    // Set defaults
    setDefaults(defaults) {
        this.defaults = defaults;
        return this;
    }

    // Build configuration
    build(overrides = {}) {
        const merged = {
            ...this.defaults,
        };

        for (const [name, config] of this.configs) {
            merged[name] = this._mergeConfig(config, overrides[name] || {});
        }

        return merged;
    }

    // Merge configurations with environment variables
    _mergeConfig(config, overrides) {
        const result = {};

        for (const [key, value] of Object.entries(config)) {
            // Check if there's an environment variable override
            const envKey = key.toUpperCase();
            const envValue = process.env[envKey];

            if (envValue !== undefined) {
                // Convert based on type
                if (typeof value === 'boolean') {
                    result[key] = envValue === 'true';
                } else if (typeof value === 'number') {
                    result[key] = parseInt(envValue, 10);
                } else {
                    result[key] = envValue;
                }
            } else if (overrides[key] !== undefined) {
                result[key] = overrides[key];
            } else {
                result[key] = value;
            }
        }

        return result;
    }
}

// Usage
const factory = new ConfigFactory()
    .setDefaults({
        port: 3000,
        host: 'localhost',
        debug: false,
    })
    .register('database', {
        host: 'localhost',
        port: 5432,
        name: 'app_db',
        user: 'app_user',
        password: 'app_password',
    })
    .register('redis', {
        host: 'localhost',
        port: 6379,
        password: '',
        db: 0,
    });

const config = factory.build({
    database: {
        name: 'app_dev',
    },
});

console.log(config);
```

### Hierarchical Configuration

```javascript
// =====================================================
// FILE: config/hierarchical.js
// DESCRIPTION: Hierarchical configuration with overrides
// =====================================================

const config = {
    // Base configuration
    app: {
        name: 'MyApp',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
    },

    // Server configuration
    server: {
        port: parseInt(process.env.PORT, 10) || 3000,
        host: process.env.HOST || '0.0.0.0',
        cors: {
            enabled: true,
            origins: ['http://localhost:3000'],
        },
    },

    // Database configuration (environment-specific)
    database: {
        development: {
            host: 'localhost',
            port: 5432,
            name: 'app_dev',
            user: 'dev_user',
            password: 'dev_password',
        },
        test: {
            host: 'localhost',
            port: 5432,
            name: 'app_test',
            user: 'test_user',
            password: 'test_password',
        },
        production: {
            host: process.env.DB_HOST || 'localhost',
            port: parseInt(process.env.DB_PORT, 10) || 5432,
            name: process.env.DB_NAME || 'app_prod',
            user: process.env.DB_USER || 'prod_user',
            password: process.env.DB_PASSWORD || '',
        },
    },

    // Logging configuration
    logging: {
        level: process.env.LOG_LEVEL || 'info',
        format: process.env.NODE_ENV === 'production' ? 'json' : 'pretty',
        output: process.env.LOG_OUTPUT || 'console',
    },

    // Feature flags
    features: {
        auth: {
            enabled: true,
            jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
        },
        caching: {
            enabled: process.env.ENABLE_CACHE === 'true',
            ttl: parseInt(process.env.CACHE_TTL, 10) || 3600,
        },
    },

    // Method to get environment-specific config
    getDatabaseConfig() {
        const env = this.app.environment;
        return this.database[env] || this.database.development;
    },

    // Method to get a nested value
    get(path, defaultValue = null) {
        const keys = path.split('.');
        let current = this;
        
        for (const key of keys) {
            if (current && typeof current === 'object' && key in current) {
                current = current[key];
            } else {
                return defaultValue;
            }
        }
        
        return current;
    },

    // Method to validate configuration
    validate() {
        const required = [
            'server.port',
            'database.production.host',
        ];
        
        const missing = [];
        for (const path of required) {
            if (!this.get(path)) {
                missing.push(path);
            }
        }
        
        if (missing.length > 0) {
            throw new Error(`Missing configuration: ${missing.join(', ')}`);
        }
        
        return true;
    },
};

module.exports = config;
```

---

## Section 8: Deployment Configurations

### Setting Environment Variables on Hosting Platforms

#### Render.com
```bash
# In Render Dashboard
# Environment > Environment Variables
PORT=3000
NODE_ENV=production
JWT_SECRET=your-secret-key
DB_HOST=your-database-host
```

#### Railway.app
```bash
# Railway Dashboard
# Variables
PORT=3000
NODE_ENV=production
JWT_SECRET=your-secret-key
```

#### Heroku
```bash
# Using Heroku CLI
heroku config:set JWT_SECRET=your-secret-key
heroku config:set NODE_ENV=production
heroku config:set DB_HOST=your-database-host

# View all config vars
heroku config
```

#### Vercel
```bash
# Using Vercel CLI
vercel env add JWT_SECRET

# Or in Vercel Dashboard
# Project Settings > Environment Variables
```

### Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

# Environment variables are set at runtime
EXPOSE ${PORT:-3000}

CMD ["node", "server.js"]
```

```bash
# Run with environment variables
docker run -p 3000:3000 \
  -e PORT=3000 \
  -e NODE_ENV=production \
  -e JWT_SECRET=secret123 \
  myapp

# Or use .env file
docker run --env-file .env myapp
```

### Kubernetes Deployment

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        env:
        - name: NODE_ENV
          value: production
        - name: PORT
          value: "3000"
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: jwt-secret
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: db-host
```

---

## Practice Exercises

### Exercise 1: Basic Environment Setup

```bash
# Create a .env file with the following variables:
# PORT=4000
# NODE_ENV=development
# DB_HOST=localhost
# DB_NAME=test_db
# API_KEY=test-key-123

# Then create a script that:
# 1. Loads the .env file
# 2. Logs all variables
# 3. Validates that required variables exist

# Your code here
```

### Exercise 2: Configuration Module

```javascript
// Create a configuration module that:
// 1. Loads environment variables
// 2. Provides typed access to configuration
// 3. Includes validation
// 4. Provides environment-specific settings

class AppConfig {
    // Your code here
}

// Test
const config = new AppConfig();
console.log(config.port); // Should return number
console.log(config.isProduction); // Should return boolean
```

### Exercise 3: Feature Flags System

```javascript
// Create a feature flag system that:
// 1. Allows enabling/disabling features via environment variables
// 2. Provides a simple API to check if a feature is enabled
// 3. Supports different environments

// Example:
// if (flags.isEnabled('darkMode')) { ... }

const featureFlags = {
    // Your code here
};
```

### Exercise 4: Environment Detection

```javascript
// Create utilities to detect the current environment
// and provide environment-specific configuration

const envUtils = {
    // Your code here
};

// Should work like:
console.log(envUtils.isDevelopment()); // true/false
console.log(envUtils.getDatabaseConfig()); // environment-specific
console.log(envUtils.getApiUrl()); // environment-specific
```

---

## Summary

You now have a complete understanding of environment variables and configuration management:

| Topic | Key Concepts |
|-------|--------------|
| **What They Are** | Dynamic settings that control application behavior |
| **Accessing** | `process.env` object in Node.js |
| **.env Files** | Store variables locally with dotenv |
| **Best Practices** | Validate, don't commit secrets, use examples |
| **Security** | Keep secrets safe, avoid exposure |
| **Deployment** | Set variables on hosting platforms |
| **Advanced Patterns** | Factories, hierarchies, feature flags |

---

**[GENERATED: Primer 5 - Environment Variables and Configuration]**

---

## Complete Primer Series Summary

You've now completed all five primers!

| Primer | Topic | Skills Gained |
|--------|-------|---------------|
| **Primer 1** | JavaScript Fundamentals | Variables, functions, async/await, modules |
| **Primer 2** | HTTP and Web Fundamentals | Requests, responses, status codes, REST |
| **Primer 3** | Command Line Basics | Navigation, files, npm, processes |
| **Primer 4** | JSON and Data Formats | Parse, stringify, validation, files |
| **Primer 5** | Environment Variables | Configuration, security, deployment |

With these fundamentals, you're now fully prepared to tackle the main tutorial series:
**Node.js + Express: From Zero to Building Real Web Apps**
