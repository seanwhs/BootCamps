# Appendix F: Security Checklist & Best Practices

## Securing Your Orchestrator System

This appendix provides a comprehensive security checklist and best practices for the Orchestrator system. Think of this like the security system for your restaurant chain - protecting your assets, data, and customers from threats.

### 1. Security Overview

#### Security Layers

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SECURITY LAYERS                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       Network Security                               │   │
│  │  • HTTPS/TLS • DDoS Protection • WAF • API Gateway                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       Application Security                           │   │
│  │  • Authentication • Authorization • Input Validation • Rate Limit  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       Data Security                                  │   │
│  │  • Encryption • Secrets Management • Backup • Audit Trail          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                       Operational Security                           │   │
│  │  • Monitoring • Logging • Incident Response • Compliance            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Authentication & Authorization

#### JWT Implementation

**File:** `src/infrastructure/adapters/auth/jwt.ts`

```typescript
import jwt from 'jsonwebtoken';
import { createHash } from 'crypto';

// Secure JWT Configuration
const JWT_CONFIG = {
    algorithm: 'RS256', // Use RS256, not HS256
    expiresIn: '1h',
    issuer: 'orchestrator-system',
    audience: 'orchestrator-api',
};

// Token Generation
export async function generateToken(userId: string, roles: string[]): Promise<string> {
    // Use strong secret (stored in AWS Secrets Manager)
    const privateKey = await getPrivateKey();
    
    return jwt.sign(
        {
            sub: userId,
            roles,
            iat: Math.floor(Date.now() / 1000),
            jti: generateTokenId(),
        },
        privateKey,
        {
            algorithm: JWT_CONFIG.algorithm,
            expiresIn: JWT_CONFIG.expiresIn,
            issuer: JWT_CONFIG.issuer,
            audience: JWT_CONFIG.audience,
        }
    );
}

// Token Validation
export async function validateToken(token: string): Promise<JWTPayload> {
    try {
        const publicKey = await getPublicKey();
        const decoded = jwt.verify(token, publicKey, {
            algorithms: [JWT_CONFIG.algorithm],
            issuer: JWT_CONFIG.issuer,
            audience: JWT_CONFIG.audience,
        }) as JWTPayload;

        // Check token blacklist
        if (await isTokenRevoked(decoded.jti)) {
            throw new Error('Token revoked');
        }

        return decoded;
    } catch (error) {
        throw new Error('Invalid token');
    }
}

// Token Blacklist (Redis)
async function isTokenRevoked(jti: string): Promise<boolean> {
    const result = await redis.get(`token:blacklist:${jti}`);
    return result !== null;
}
```

#### Role-Based Access Control

**File:** `src/infrastructure/adapters/auth/rbac.ts`

```typescript
// Define roles and permissions
export enum Role {
    ADMIN = 'admin',
    MANAGER = 'manager',
    USER = 'user',
    READONLY = 'readonly',
}

export const PERMISSIONS = {
    // User permissions
    'user:create': [Role.ADMIN, Role.MANAGER],
    'user:read': [Role.ADMIN, Role.MANAGER, Role.USER],
    'user:update': [Role.ADMIN, Role.MANAGER, Role.USER],
    'user:delete': [Role.ADMIN],
    'user:deactivate': [Role.ADMIN, Role.MANAGER],
    
    // Task permissions
    'task:create': [Role.ADMIN, Role.MANAGER, Role.USER],
    'task:read': [Role.ADMIN, Role.MANAGER, Role.USER],
    'task:update': [Role.ADMIN, Role.MANAGER, Role.USER],
    'task:delete': [Role.ADMIN, Role.MANAGER],
    'task:assign': [Role.ADMIN, Role.MANAGER],
    
    // Admin permissions
    'admin:metrics': [Role.ADMIN],
    'admin:projections': [Role.ADMIN],
    'admin:users': [Role.ADMIN],
};

// Authorization middleware
export function authorize(permission: string) {
    return async (request: FastifyRequest, reply: FastifyReply) => {
        const user = request.user;
        if (!user) {
            return reply.status(401).send({ error: 'Unauthorized' });
        }

        const allowedRoles = PERMISSIONS[permission];
        if (!allowedRoles) {
            return reply.status(403).send({ error: 'Permission denied' });
        }

        const hasPermission = user.roles.some(role => allowedRoles.includes(role));
        if (!hasPermission) {
            return reply.status(403).send({ error: 'Insufficient permissions' });
        }
    };
}

// Usage in routes
fastify.get('/api/admin/users', { 
    preHandler: [authorize('admin:users')] 
}, getUserList);
```

### 3. Input Validation & Sanitization

#### Validation Schema

**File:** `src/infrastructure/adapters/http/validation/schemas.ts`

```typescript
import { z } from 'zod';

// Strict validation schemas
export const userSchema = z.object({
    email: z.string()
        .email('Invalid email format')
        .min(3, 'Email too short')
        .max(255, 'Email too long')
        .toLowerCase(),
    username: z.string()
        .min(3, 'Username must be at least 3 characters')
        .max(30, 'Username must be at most 30 characters')
        .regex(/^[a-zA-Z0-9_]+$/, 'Only letters, numbers, and underscores')
        .toLowerCase(),
    password: z.string()
        .min(8, 'Password must be at least 8 characters')
        .max(100, 'Password too long')
        .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
        .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
        .regex(/\d/, 'Password must contain at least one number')
        .regex(/[^a-zA-Z0-9]/, 'Password must contain at least one special character'),
    firstName: z.string()
        .min(1, 'First name required')
        .max(50, 'First name too long')
        .regex(/^[a-zA-Z\s\-']+$/, 'Invalid characters in first name'),
    lastName: z.string()
        .min(1, 'Last name required')
        .max(50, 'Last name too long')
        .regex(/^[a-zA-Z\s\-']+$/, 'Invalid characters in last name'),
});

export const taskSchema = z.object({
    title: z.string()
        .min(3, 'Title must be at least 3 characters')
        .max(255, 'Title too long')
        .trim()
        .transform(val => val.replace(/\s+/g, ' ')),
    description: z.string()
        .min(10, 'Description must be at least 10 characters')
        .max(5000, 'Description too long'),
    priority: z.enum(['low', 'medium', 'high', 'critical']),
    dueDate: z.string()
        .datetime()
        .refine(
            date => new Date(date) > new Date(),
            'Due date must be in the future'
        )
        .optional(),
});

// SQL Injection Prevention
import { escape } from 'sqlstring';
function sanitizeSQL(input: string): string {
    return escape(input);
}

// XSS Prevention
import xss from 'xss';
function sanitizeXSS(input: string): string {
    return xss(input);
}
```

### 4. Data Protection

#### Encryption

**File:** `src/infrastructure/adapters/security/encryption.ts`

```typescript
import crypto from 'crypto';

// AES-256-GCM Encryption
export class EncryptionService {
    private readonly algorithm = 'aes-256-gcm';
    private readonly key: Buffer;

    constructor() {
        // Key from environment (use KMS in production)
        this.key = Buffer.from(process.env.ENCRYPTION_KEY || '', 'hex');
        if (this.key.length !== 32) {
            throw new Error('Invalid encryption key length');
        }
    }

    encrypt(text: string): EncryptedData {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
        
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        
        const authTag = cipher.getAuthTag();
        
        return {
            encrypted,
            iv: iv.toString('hex'),
            authTag: authTag.toString('hex'),
        };
    }

    decrypt(data: EncryptedData): string {
        const iv = Buffer.from(data.iv, 'hex');
        const authTag = Buffer.from(data.authTag, 'hex');
        const decipher = crypto.createDecipheriv(this.algorithm, this.key, iv);
        
        decipher.setAuthTag(authTag);
        
        let decrypted = decipher.update(data.encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        
        return decrypted;
    }
}

// Encrypt PII fields
class UserService {
    async createUser(userData: any): Promise<User> {
        // Encrypt sensitive data
        const encrypted = {
            email: this.encryption.encrypt(userData.email),
            name: this.encryption.encrypt(userData.name),
            // ... other fields
        };
        
        return await this.userRepository.save(encrypted);
    }
}
```

#### Secrets Management

```typescript
// AWS Secrets Manager
import { SecretsManager } from '@aws-sdk/client-secrets-manager';

export class SecretManager {
    private client: SecretsManager;

    constructor() {
        this.client = new SecretsManager({
            region: process.env.AWS_REGION || 'us-east-1',
        });
    }

    async getSecret(secretName: string): Promise<string> {
        try {
            const response = await this.client.getSecretValue({
                SecretId: secretName,
            });
            
            return response.SecretString || '';
        } catch (error) {
            throw new Error(`Failed to get secret: ${secretName}`);
        }
    }

    async getSecretJSON<T>(secretName: string): Promise<T> {
        const secret = await this.getSecret(secretName);
        return JSON.parse(secret) as T;
    }
}

// Usage
const secrets = new SecretManager();
const dbConfig = await secrets.getSecretJSON<DBConfig>('orchestrator/database');
```

### 5. API Security

#### Rate Limiting

```typescript
// src/infrastructure/adapters/security/rate-limit.ts
export class RateLimiter {
    private store: Map<string, { count: number; windowStart: number }> = new Map();
    
    async check(key: string, limit: number, windowMs: number): Promise<RateLimitInfo> {
        const now = Date.now();
        const entry = this.store.get(key) || { count: 0, windowStart: now };
        
        // Reset if window expired
        if (now - entry.windowStart > windowMs) {
            entry.count = 0;
            entry.windowStart = now;
        }
        
        const allowed = entry.count < limit;
        if (allowed) {
            entry.count++;
        }
        
        this.store.set(key, entry);
        
        return {
            allowed,
            remaining: limit - entry.count,
            resetAt: new Date(entry.windowStart + windowMs),
            limit,
        };
    }
}

// Per-endpoint rate limits
const rateLimits = {
    'POST /api/users': { limit: 10, window: 60000 },     // 10 per minute
    'POST /api/tasks': { limit: 100, window: 60000 },    // 100 per minute
    'GET /api/users': { limit: 500, window: 60000 },     // 500 per minute
    'POST /api/auth': { limit: 5, window: 300000 },      // 5 per 5 minutes
};
```

#### CORS Configuration

```typescript
// Secure CORS configuration
const corsOptions = {
    origin: (origin: string, callback: (err: Error | null, allow: boolean) => void) => {
        const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];
        
        // Allow requests with no origin (like mobile apps)
        if (!origin) {
            return callback(null, true);
        }
        
        if (allowedOrigins.includes(origin) || allowedOrigins.includes('*')) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'), false);
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
    exposedHeaders: ['X-Request-ID', 'X-RateLimit-*'],
    credentials: true,
    maxAge: 86400, // 24 hours
};
```

### 6. Monitoring & Logging

#### Security Logging

```typescript
// src/infrastructure/adapters/security/audit-log.ts
export class AuditLogger {
    async logSecurityEvent(event: SecurityEvent): Promise<void> {
        const log = {
            timestamp: new Date().toISOString(),
            eventType: event.type,
            userId: event.userId,
            ip: event.ip,
            userAgent: event.userAgent,
            details: event.details,
            success: event.success,
            ...this.getAdditionalContext(),
        };

        // Send to multiple destinations
        await Promise.all([
            // Console (for development)
            console.log('SECURITY EVENT:', JSON.stringify(log)),
            
            // File (for persistent storage)
            this.writeToFile(log),
            
            // SIEM (for security monitoring)
            this.sendToSIEM(log),
            
            // Elasticsearch (for search)
            this.indexInElasticsearch(log),
        ]);
    }

    private getAdditionalContext(): Record<string, any> {
        return {
            requestId: RequestContextManager.getRequestId(),
            environment: process.env.NODE_ENV,
            service: process.env.SERVICE_NAME,
            host: os.hostname(),
            pid: process.pid,
        };
    }
}

// Security events to log
const securityEvents = {
    AUTH_SUCCESS: 'Authentication successful',
    AUTH_FAILURE: 'Authentication failed',
    AUTH_TOKEN_REFRESH: 'Token refreshed',
    AUTH_LOGOUT: 'User logged out',
    
    ACCESS_DENIED: 'Access denied',
    PERMISSION_DENIED: 'Permission denied',
    
    USER_CREATED: 'User created',
    USER_UPDATED: 'User updated',
    USER_DELETED: 'User deleted',
    USER_DEACTIVATED: 'User deactivated',
    
    PASSWORD_CHANGED: 'Password changed',
    EMAIL_CHANGED: 'Email changed',
    
    RATE_LIMIT_EXCEEDED: 'Rate limit exceeded',
    SUSPICIOUS_ACTIVITY: 'Suspicious activity detected',
};
```

### 7. Secure Headers

```typescript
// Security headers middleware
function securityHeaders(request: FastifyRequest, reply: FastifyReply) {
    // Prevent MIME type sniffing
    reply.header('X-Content-Type-Options', 'nosniff');
    
    // Prevent clickjacking
    reply.header('X-Frame-Options', 'DENY');
    
    // XSS protection
    reply.header('X-XSS-Protection', '1; mode=block');
    
    // Content Security Policy
    reply.header('Content-Security-Policy', [
        "default-src 'self'",
        "connect-src 'self' https://api.orchestrator.com",
        "img-src 'self' data: https:",
        "script-src 'self' 'unsafe-inline'",
        "style-src 'self' 'unsafe-inline'",
        "font-src 'self'",
    ].join('; '));
    
    // Referrer Policy
    reply.header('Referrer-Policy', 'strict-origin-when-cross-origin');
    
    // HSTS (in production)
    if (process.env.NODE_ENV === 'production') {
        reply.header('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
    }
    
    // Remove server information
    reply.header('X-Powered-By', '');
    reply.header('Server', '');
}
```

### 8. Security Checklist

#### Infrastructure Security
- [ ] Use VPC with private subnets
- [ ] Enable security groups with least privilege
- [ ] Use IAM roles, not access keys
- [ ] Enable AWS Shield/WAF
- [ ] Use AWS Certificate Manager for SSL
- [ ] Enable CloudTrail logging
- [ ] Use AWS Config for compliance

#### Application Security
- [ ] Use JWT with RS256
- [ ] Implement RBAC
- [ ] Validate all input
- [ ] Sanitize output (prevent XSS)
- [ ] Use prepared statements (prevent SQL injection)
- [ ] Rate limit all endpoints
- [ ] Implement CORS properly
- [ ] Use security headers
- [ ] Disable debug mode in production

#### Data Security
- [ ] Encrypt data at rest
- [ ] Encrypt data in transit (TLS 1.2+)
- [ ] Hash passwords with bcrypt/Argon2
- [ ] Use AWS KMS/Secrets Manager
- [ ] Implement data backup
- [ ] Enable database encryption
- [ ] Secure API keys and tokens

#### Monitoring & Response
- [ ] Enable comprehensive logging
- [ ] Set up security alerts
- [ ] Monitor for anomalies
- [ ] Have incident response plan
- [ ] Regular security audits
- [ ] Penetration testing
- [ ] Vulnerability scanning

#### Dependencies
- [ ] Regularly update dependencies
- [ ] Audit dependencies (npm audit)
- [ ] Use dependency scanning tools
- [ ] Pin dependency versions
- [ ] Use private registry

### 9. Incident Response Plan

```typescript
class IncidentResponse {
    async handleSecurityIncident(incident: SecurityIncident): Promise<void> {
        // 1. Detect and analyze
        const severity = this.assessSeverity(incident);
        
        // 2. Contain
        await this.containIncident(incident);
        
        // 3. Eradicate
        await this.eradicateThreat(incident);
        
        // 4. Recover
        await this.recoverSystems(incident);
        
        // 5. Notify
        await this.notifyStakeholders(incident, severity);
        
        // 6. Document
        await this.documentIncident(incident);
        
        // 7. Review and improve
        await this.conductPostMortem(incident);
    }
    
    private async assessSeverity(incident: SecurityIncident): Promise<Severity> {
        // Severity: CRITICAL, HIGH, MEDIUM, LOW
        if (incident.type === 'DATA_BREACH' || incident.type === 'RANSOMWARE') {
            return Severity.CRITICAL;
        }
        // ... other severity assessments
    }
}
```

---

This security checklist provides a comprehensive framework for securing your Orchestrator system. Review and implement these measures regularly to maintain a strong security posture.
