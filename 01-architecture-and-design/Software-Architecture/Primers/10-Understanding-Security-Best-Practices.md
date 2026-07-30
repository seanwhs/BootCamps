# Primer 10: Understanding Security Best Practices

## A Deep Dive into Building Secure Systems

Welcome to the tenth primer! This is a comprehensive deep dive into security best practices for distributed systems. Think of this like building a fortress with multiple layers of defense - you need protection at every level, from the outer walls to the inner vaults.

### 1. The Big Picture

#### Security Layers

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    NETWORK SECURITY                                 │   │
│  │  • Firewalls • HTTPS/TLS • DDoS Protection • Network Segmentation  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    APPLICATION SECURITY                             │   │
│  │  • Authentication • Authorization • Input Validation               │   │
│  │  • Session Management • Error Handling                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DATA SECURITY                                    │   │
│  │  • Encryption (at rest/transit) • Key Management                   │   │
│  │  • Data Masking • Backups • Compliance                             │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    OPERATIONAL SECURITY                             │   │
│  │  • Monitoring • Logging • Incident Response                        │   │
│  │  • Auditing • Vulnerability Scanning                               │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Authentication & Authorization

#### JWT Implementation

```typescript
import jwt from 'jsonwebtoken';
import { randomBytes, createHash, timingSafeEqual } from 'crypto';

class JWTService {
    private readonly privateKey: string;
    private readonly publicKey: string;
    private readonly issuer: string;
    private readonly audience: string;

    constructor() {
        // Load keys from secure storage (AWS KMS, HashiCorp Vault, etc.)
        this.privateKey = process.env.JWT_PRIVATE_KEY!;
        this.publicKey = process.env.JWT_PUBLIC_KEY!;
        this.issuer = process.env.JWT_ISSUER!;
        this.audience = process.env.JWT_AUDIENCE!;
    }

    generateToken(userId: string, roles: string[], expiresIn: string = '1h'): string {
        const tokenId = this.generateTokenId();
        const now = Math.floor(Date.now() / 1000);

        return jwt.sign(
            {
                sub: userId,
                roles,
                jti: tokenId,
                iat: now,
                iss: this.issuer,
                aud: this.audience,
                // Additional claims
                scope: roles,
                userType: 'user',
            },
            this.privateKey,
            {
                algorithm: 'RS256',
                expiresIn,
            }
        );
    }

    verifyToken(token: string): JWTPayload {
        try {
            const decoded = jwt.verify(token, this.publicKey, {
                algorithms: ['RS256'],
                issuer: this.issuer,
                audience: this.audience,
            });

            // Check if token is revoked
            if (this.isTokenRevoked(decoded.jti)) {
                throw new Error('Token has been revoked');
            }

            return decoded;
        } catch (error) {
            throw new Error('Invalid token');
        }
    }

    private generateTokenId(): string {
        return randomBytes(16).toString('hex');
    }

    private isTokenRevoked(tokenId: string): boolean {
        // Check against Redis or database
        // return await redis.get(`token:revoked:${tokenId}`) !== null;
        return false;
    }

    async revokeToken(tokenId: string, expiresIn: number = 3600): Promise<void> {
        // Store in Redis with TTL
        // await redis.set(`token:revoked:${tokenId}`, 'true', 'EX', expiresIn);
    }

    refreshToken(refreshToken: string): { accessToken: string; refreshToken: string } {
        // Validate refresh token
        const payload = this.verifyToken(refreshToken);
        
        // Generate new tokens
        const accessToken = this.generateToken(payload.sub, payload.roles, '1h');
        const newRefreshToken = this.generateToken(payload.sub, payload.roles, '7d');
        
        return { accessToken, refreshToken: newRefreshToken };
    }
}
```

#### Role-Based Access Control (RBAC)

```typescript
// Permission definitions
const PERMISSIONS = {
    // User permissions
    'user:create': ['admin', 'manager'],
    'user:read': ['admin', 'manager', 'user'],
    'user:update': ['admin', 'manager', 'user'],
    'user:delete': ['admin'],
    'user:deactivate': ['admin', 'manager'],
    
    // Task permissions
    'task:create': ['admin', 'manager', 'user'],
    'task:read': ['admin', 'manager', 'user'],
    'task:update': ['admin', 'manager', 'user'],
    'task:delete': ['admin', 'manager'],
    'task:assign': ['admin', 'manager'],
    
    // Admin permissions
    'admin:metrics': ['admin'],
    'admin:audit': ['admin'],
    'admin:users': ['admin'],
} as const;

type Permission = keyof typeof PERMISSIONS;

class AuthService {
    private tokenService: JWTService;
    private userRepository: IUserRepository;

    constructor(tokenService: JWTService, userRepository: IUserRepository) {
        this.tokenService = tokenService;
        this.userRepository = userRepository;
    }

    async authenticate(email: string, password: string): Promise<AuthResult> {
        // 1. Find user
        const user = await this.userRepository.findByEmail(email);
        if (!user) {
            throw new Error('Invalid credentials');
        }

        // 2. Check if user is active
        if (!user.isActive) {
            throw new Error('Account is deactivated');
        }

        // 3. Verify password with constant-time comparison
        const isPasswordValid = await this.verifyPassword(password, user.passwordHash);
        if (!isPasswordValid) {
            // Use same error message to prevent user enumeration
            throw new Error('Invalid credentials');
        }

        // 4. Generate tokens
        const roles = await this.getUserRoles(user.id);
        const accessToken = this.tokenService.generateToken(user.id, roles, '1h');
        const refreshToken = this.tokenService.generateToken(user.id, roles, '7d');

        // 5. Log login event
        await this.logLogin(user.id);

        return {
            user: user.toJSON(),
            accessToken,
            refreshToken,
            expiresIn: 3600,
        };
    }

    async authorize(userId: string, permission: Permission): Promise<boolean> {
        const roles = await this.getUserRoles(userId);
        const allowedRoles = PERMISSIONS[permission];
        
        return roles.some(role => allowedRoles.includes(role));
    }

    private async verifyPassword(password: string, hash: string): Promise<boolean> {
        // Use bcrypt or similar with constant-time comparison
        // return await bcrypt.compare(password, hash);
        return true; // Placeholder
    }

    private async getUserRoles(userId: string): Promise<string[]> {
        const user = await this.userRepository.findById(userId);
        return user?.roles || ['user'];
    }

    private async logLogin(userId: string): Promise<void> {
        // Log login event for audit
        // await auditLog.create({ userId, action: 'login', timestamp: new Date() });
    }
}

// Authorization middleware
function authorize(permission: Permission) {
    return async (request: FastifyRequest, reply: FastifyReply) => {
        const authService = container.resolve<AuthService>('AuthService');
        const user = (request as any).user;
        
        if (!user) {
            reply.status(401).send({ error: 'Unauthorized' });
            return;
        }

        const authorized = await authService.authorize(user.id, permission);
        if (!authorized) {
            reply.status(403).send({ error: 'Forbidden' });
            return;
        }
    };
}
```

### 3. Input Validation & Sanitization

#### Validation Pipeline

```typescript
import { z } from 'zod';
import { escape } from 'html-escaper';

class ValidationService {
    // Sanitization
    sanitizeString(input: string): string {
        // Remove potential dangerous characters
        return input
            .trim()
            .replace(/[<>]/g, '') // Remove < and >
            .replace(/javascript:/gi, '') // Remove javascript: protocol
            .replace(/on\w+\s*=/gi, ''); // Remove event handlers
    }

    sanitizeSQL(input: string): string {
        // Prevent SQL injection
        return input.replace(/'/g, "''").replace(/\\/g, '\\\\');
    }

    sanitizeHTML(input: string): string {
        // Escape HTML to prevent XSS
        return escape(input);
    }

    // Validation schemas
    static userSchema = z.object({
        email: z.string()
            .email('Invalid email format')
            .min(3)
            .max(255)
            .transform(val => val.toLowerCase()),
        username: z.string()
            .min(3, 'Username must be at least 3 characters')
            .max(30, 'Username must be at most 30 characters')
            .regex(/^[a-zA-Z0-9_]+$/, 'Only letters, numbers, and underscores')
            .transform(val => val.toLowerCase()),
        password: z.string()
            .min(8, 'Password must be at least 8 characters')
            .max(100, 'Password too long')
            .regex(/[A-Z]/, 'Must contain uppercase letter')
            .regex(/[a-z]/, 'Must contain lowercase letter')
            .regex(/\d/, 'Must contain number')
            .regex(/[^a-zA-Z0-9]/, 'Must contain special character'),
        firstName: z.string()
            .min(1, 'First name required')
            .max(50, 'First name too long')
            .regex(/^[a-zA-Z\s\-']+$/, 'Invalid characters'),
        lastName: z.string()
            .min(1, 'Last name required')
            .max(50, 'Last name too long')
            .regex(/^[a-zA-Z\s\-']+$/, 'Invalid characters'),
    });

    static taskSchema = z.object({
        title: z.string()
            .min(3, 'Title must be at least 3 characters')
            .max(255, 'Title too long')
            .trim(),
        description: z.string()
            .min(10, 'Description must be at least 10 characters')
            .max(5000, 'Description too long'),
        priority: z.enum(['low', 'medium', 'high', 'critical']),
        dueDate: z.string()
            .datetime()
            .refine(date => new Date(date) > new Date(), {
                message: 'Due date must be in the future',
            })
            .optional(),
        userId: z.string().uuid('Invalid user ID'),
    });

    static validate<T>(schema: z.ZodSchema<T>, data: unknown): T {
        return schema.parse(data);
    }

    static validatePartial<T>(schema: z.ZodSchema<T>, data: unknown): Partial<T> {
        return schema.partial().parse(data);
    }

    // Sanitize request body
    static sanitizeBody(body: any): any {
        const sanitized = { ...body };
        
        for (const [key, value] of Object.entries(sanitized)) {
            if (typeof value === 'string') {
                // Remove control characters
                sanitized[key] = value.replace(/[\x00-\x1F\x7F]/g, '');
            } else if (typeof value === 'object' && value !== null) {
                sanitized[key] = this.sanitizeBody(value);
            }
        }
        
        return sanitized;
    }
}

// Validation middleware
function validateInput<T>(schema: z.ZodSchema<T>) {
    return async (request: FastifyRequest, reply: FastifyReply) => {
        try {
            // Sanitize body first
            const sanitized = ValidationService.sanitizeBody(request.body);
            
            // Then validate
            const validated = await schema.parseAsync(sanitized);
            request.body = validated;
        } catch (error) {
            if (error instanceof z.ZodError) {
                reply.status(400).send({
                    error: 'Validation Error',
                    details: error.errors.map(e => ({
                        path: e.path.join('.'),
                        message: e.message,
                    })),
                });
            } else {
                reply.status(400).send({ error: 'Invalid input' });
            }
        }
    };
}
```

### 4. Data Protection

#### Encryption Service

```typescript
import { createCipheriv, createDecipheriv, randomBytes, scryptSync } from 'crypto';

class EncryptionService {
    private readonly algorithm = 'aes-256-gcm';
    private readonly key: Buffer;
    private readonly salt: string;

    constructor() {
        // Use KMS or Vault for key management in production
        const keyMaterial = process.env.ENCRYPTION_KEY!;
        this.salt = process.env.ENCRYPTION_SALT!;
        
        // Derive key using PBKDF2
        this.key = scryptSync(keyMaterial, this.salt, 32);
    }

    encrypt(text: string): EncryptedData {
        const iv = randomBytes(16);
        const cipher = createCipheriv(this.algorithm, this.key, iv);
        
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        
        const authTag = cipher.getAuthTag();
        
        return {
            iv: iv.toString('hex'),
            encrypted,
            authTag: authTag.toString('hex'),
        };
    }

    decrypt(data: EncryptedData): string {
        const iv = Buffer.from(data.iv, 'hex');
        const authTag = Buffer.from(data.authTag, 'hex');
        const decipher = createDecipheriv(this.algorithm, this.key, iv);
        
        decipher.setAuthTag(authTag);
        
        let decrypted = decipher.update(data.encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        
        return decrypted;
    }
}

interface EncryptedData {
    iv: string;
    encrypted: string;
    authTag: string;
}

// Sensitive data handling
class SensitiveDataHandler {
    private encryptionService: EncryptionService;

    constructor() {
        this.encryptionService = new EncryptionService();
    }

    encryptEmail(email: string): string {
        // Encrypt PII
        return this.encryptionService.encrypt(email).encrypted;
    }

    decryptEmail(encrypted: string, iv: string, authTag: string): string {
        return this.encryptionService.decrypt({ encrypted, iv, authTag });
    }

    maskEmail(email: string): string {
        // For display purposes
        const [local, domain] = email.split('@');
        const maskedLocal = local.slice(0, 2) + '***' + local.slice(-1);
        return `${maskedLocal}@${domain}`;
    }
}
```

#### Secrets Management

```typescript
import { SecretsManager } from '@aws-sdk/client-secrets-manager';

class SecretManager {
    private client: SecretsManager;
    private cache: Map<string, { secret: any; expires: number }> = new Map();
    private cacheTTL = 3600000; // 1 hour

    constructor() {
        this.client = new SecretsManager({
            region: process.env.AWS_REGION || 'us-east-1',
        });
    }

    async getSecret<T>(secretName: string): Promise<T> {
        // Check cache
        const cached = this.cache.get(secretName);
        if (cached && cached.expires > Date.now()) {
            return cached.secret as T;
        }

        // Fetch from Secrets Manager
        try {
            const response = await this.client.getSecretValue({
                SecretId: secretName,
            });

            const secret = JSON.parse(response.SecretString || '{}');
            
            // Cache the secret
            this.cache.set(secretName, {
                secret,
                expires: Date.now() + this.cacheTTL,
            });

            return secret as T;
        } catch (error) {
            throw new Error(`Failed to get secret: ${secretName}`);
        }
    }

    async rotateSecret(secretName: string, newSecret: any): Promise<void> {
        await this.client.updateSecret({
            SecretId: secretName,
            SecretString: JSON.stringify(newSecret),
        });

        // Invalidate cache
        this.cache.delete(secretName);
    }

    async createSecret(secretName: string, secret: any): Promise<void> {
        await this.client.createSecret({
            Name: secretName,
            SecretString: JSON.stringify(secret),
        });
    }
}

// Usage
class DatabaseConfig {
    private secretManager: SecretManager;

    constructor() {
        this.secretManager = new SecretManager();
    }

    async getConnectionString(): Promise<string> {
        const config = await this.secretManager.getSecret<{
            host: string;
            username: string;
            password: string;
            database: string;
        }>('database/primary');
        
        return `postgresql://${config.username}:${config.password}@${config.host}/${config.database}`;
    }
}
```

### 5. API Security

#### Rate Limiting

```typescript
class RateLimiter {
    private store: Map<string, RateLimitEntry> = new Map();
    private cleanupInterval: NodeJS.Timeout;

    constructor(
        private windowMs: number = 60000,
        private maxRequests: number = 100
    ) {
        // Clean up expired entries every minute
        this.cleanupInterval = setInterval(() => this.cleanup(), 60000);
    }

    check(key: string): RateLimitResult {
        const now = Date.now();
        const entry = this.store.get(key);
        
        if (!entry || now - entry.windowStart > this.windowMs) {
            // New window
            this.store.set(key, {
                count: 1,
                windowStart: now,
            });
            
            return {
                allowed: true,
                remaining: this.maxRequests - 1,
                resetAt: new Date(now + this.windowMs),
                limit: this.maxRequests,
            };
        }

        // Check if over limit
        if (entry.count >= this.maxRequests) {
            return {
                allowed: false,
                remaining: 0,
                resetAt: new Date(entry.windowStart + this.windowMs),
                limit: this.maxRequests,
            };
        }

        // Increment and allow
        entry.count++;
        
        return {
            allowed: true,
            remaining: this.maxRequests - entry.count,
            resetAt: new Date(entry.windowStart + this.windowMs),
            limit: this.maxRequests,
        };
    }

    private cleanup(): void {
        const now = Date.now();
        for (const [key, entry] of this.store) {
            if (now - entry.windowStart > this.windowMs * 2) {
                this.store.delete(key);
            }
        }
    }

    destroy(): void {
        clearInterval(this.cleanupInterval);
    }
}

// Rate limiting middleware
function rateLimit(limiter: RateLimiter) {
    return async (request: FastifyRequest, reply: FastifyReply) => {
        const key = getRateLimitKey(request);
        const result = limiter.check(key);
        
        // Add headers
        reply.header('X-RateLimit-Limit', result.limit);
        reply.header('X-RateLimit-Remaining', result.remaining);
        reply.header('X-RateLimit-Reset', result.resetAt.toISOString());
        
        if (!result.allowed) {
            reply.status(429).send({
                error: 'Too Many Requests',
                retryAfter: Math.ceil((result.resetAt.getTime() - Date.now()) / 1000),
            });
            return;
        }
    };
}

function getRateLimitKey(request: FastifyRequest): string {
    // Use multiple factors for the key
    const userId = request.headers['x-user-id'];
    const apiKey = request.headers['x-api-key'];
    const ip = request.ip;
    const path = request.url;
    
    if (userId) {
        return `user:${userId}:${path}`;
    }
    if (apiKey) {
        return `apikey:${apiKey}:${path}`;
    }
    return `ip:${ip}:${path}`;
}
```

#### Security Headers

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
    
    // HSTS (production only)
    if (process.env.NODE_ENV === 'production') {
        reply.header('Strict-Transport-Security', [
            'max-age=31536000',
            'includeSubDomains',
            'preload',
        ].join('; '));
    }
    
    // Remove server information
    reply.header('X-Powered-By', '');
    reply.header('Server', '');
    
    // Cache control for sensitive data
    if (request.url.includes('/api/users') || 
        request.url.includes('/api/tasks')) {
        reply.header('Cache-Control', 'no-cache, no-store, must-revalidate');
        reply.header('Pragma', 'no-cache');
        reply.header('Expires', '0');
    }
}
```

### 6. Security Monitoring & Logging

#### Audit Logging

```typescript
class AuditLogger {
    private logger: Logger;

    constructor() {
        this.logger = createLogger('audit');
    }

    log(event: AuditEvent): void {
        const logEntry = {
            timestamp: new Date().toISOString(),
            eventType: event.type,
            userId: event.userId,
            ip: event.ip,
            userAgent: event.userAgent,
            resource: event.resource,
            action: event.action,
            result: event.result,
            details: event.details,
            requestId: event.requestId,
            correlationId: event.correlationId,
        };

        this.logger.info(logEntry);
    }
}

interface AuditEvent {
    type: string;
    userId?: string;
    ip?: string;
    userAgent?: string;
    resource?: string;
    action: string;
    result: 'success' | 'failure';
    details?: Record<string, any>;
    requestId?: string;
    correlationId?: string;
}

// Security event types
const SecurityEvents = {
    // Authentication
    LOGIN_ATTEMPT: 'auth.login.attempt',
    LOGIN_SUCCESS: 'auth.login.success',
    LOGIN_FAILURE: 'auth.login.failure',
    LOGOUT: 'auth.logout',
    TOKEN_REFRESH: 'auth.token.refresh',
    
    // Authorization
    ACCESS_GRANTED: 'auth.access.granted',
    ACCESS_DENIED: 'auth.access.denied',
    PERMISSION_CHANGED: 'auth.permission.changed',
    
    // User Management
    USER_CREATED: 'user.created',
    USER_UPDATED: 'user.updated',
    USER_DELETED: 'user.deleted',
    USER_DEACTIVATED: 'user.deactivated',
    
    // Data Access
    DATA_READ: 'data.read',
    DATA_WRITE: 'data.write',
    DATA_DELETE: 'data.delete',
    
    // Security Incidents
    RATE_LIMIT_EXCEEDED: 'security.rate_limit.exceeded',
    SUSPICIOUS_ACTIVITY: 'security.suspicious.activity',
    SECURITY_VIOLATION: 'security.violation',
};

// Usage
const audit = new AuditLogger();

audit.log({
    type: SecurityEvents.LOGIN_SUCCESS,
    userId: 'user-123',
    ip: '192.168.1.1',
    userAgent: 'Mozilla/5.0...',
    action: 'login',
    result: 'success',
    details: {
        method: 'email',
        timestamp: new Date(),
    },
});
```

### 7. Key Takeaways

1. **Defense in Depth:**
   - Multiple layers of security
   - No single point of failure
   - Redundancy in protection

2. **Authentication & Authorization:**
   - Use strong JWT with RS256
   - Implement proper RBAC
   - Secure password storage with bcrypt
   - Use MFA when possible

3. **Input Validation:**
   - Validate all input
   - Sanitize output
   - Use parameterized queries
   - Implement CSRF protection

4. **Data Protection:**
   - Encrypt sensitive data at rest
   - Use TLS for all communications
   - Implement proper key management
   - Regular security backups

5. **API Security:**
   - Rate limiting
   - Security headers
   - CORS properly configured
   - API key rotation

6. **Monitoring:**
   - Comprehensive audit logging
   - Security event monitoring
   - Real-time alerts
   - Regular security reviews

7. **Compliance:**
   - Know your regulatory requirements
   - Document security policies
   - Regular security audits
   - Incident response plan

---

This primer provides a comprehensive understanding of security best practices. A secure system protects users, data, and business operations from threats and vulnerabilities.
