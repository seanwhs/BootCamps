# Appendix I: Authentication and Security Reference

## Overview

This appendix provides a comprehensive reference for implementing authentication, authorization, and security in your MCP and A2A systems. It covers everything from basic API key authentication to advanced security patterns.

---

## Part 1: Authentication Methods

### 1.1 API Key Authentication

**Overview:** API keys are simple, stateless tokens used to authenticate requests.

**Implementation:**

```typescript
import crypto from 'crypto';

/**
 * API Key Management
 */
export class APIKeyManager {
  private keys: Map<string, { hash: string; createdAt: Date; metadata: any }> = new Map();
  
  /**
   * Generate a new API key
   * Format: mcp_{32 random hex characters}
   */
  generateKey(metadata?: any): { key: string; hash: string } {
    const key = `mcp_${crypto.randomBytes(32).toString('hex')}`;
    const hash = this.hashKey(key);
    
    this.keys.set(hash, {
      hash,
      createdAt: new Date(),
      metadata: metadata || {}
    });
    
    return { key, hash };
  }
  
  /**
   * Hash an API key for storage
   * Uses SHA-256 for secure hashing
   */
  hashKey(key: string): string {
    return crypto.createHash('sha256').update(key).digest('hex');
  }
  
  /**
   * Validate an API key
   */
  validateKey(key: string): boolean {
    const hash = this.hashKey(key);
    return this.keys.has(hash);
  }
  
  /**
   * Get key metadata
   */
  getKeyMetadata(key: string): any {
    const hash = this.hashKey(key);
    return this.keys.get(hash)?.metadata || null;
  }
  
  /**
   * Revoke an API key
   */
  revokeKey(key: string): boolean {
    const hash = this.hashKey(key);
    return this.keys.delete(hash);
  }
  
  /**
   * List all keys (for admin purposes)
   */
  listKeys(): Array<{ hash: string; createdAt: Date; metadata: any }> {
    return Array.from(this.keys.values());
  }
}

// Usage in MCP server
const keyManager = new APIKeyManager();

// Generate keys during setup
const { key, hash } = keyManager.generateKey({ 
  service: 'knowledge-server',
  environment: 'production'
});

console.log('API Key:', key); // Store this securely
console.log('Hash:', hash); // Store this in the server

// Validate in middleware
function authenticateAPIKey(headers: Record<string, string>): boolean {
  const apiKey = headers['x-api-key'] || headers['Authorization']?.replace('Bearer ', '');
  if (!apiKey) return false;
  return keyManager.validateKey(apiKey);
}
```

**Environment Variables:**
```env
# Store multiple API keys (comma-separated)
MCP_API_KEYS=mcp_key1_1234567890abcdef,mcp_key2_0987654321fedcba

# Or use a secrets manager in production
MCP_API_KEYS_FILE=/run/secrets/api_keys.txt
```

---

### 1.2 JWT Authentication

**Overview:** JWTs provide stateless, signed authentication with expiration.

**Implementation:**

```typescript
import jwt from 'jsonwebtoken';

/**
 * JWT Manager
 */
export class JWTManager {
  private secret: string;
  private issuer: string;
  private audience: string;
  private expiresIn: string;
  
  constructor(config: {
    secret: string;
    issuer?: string;
    audience?: string;
    expiresIn?: string;
  }) {
    this.secret = config.secret;
    this.issuer = config.issuer || 'ai-platform';
    this.audience = config.audience || 'ai-clients';
    this.expiresIn = config.expiresIn || '24h';
  }
  
  /**
   * Generate a JWT token
   */
  sign(payload: Record<string, any>): string {
    return jwt.sign(
      payload,
      this.secret,
      {
        issuer: this.issuer,
        audience: this.audience,
        expiresIn: this.expiresIn
      }
    );
  }
  
  /**
   * Verify and decode a JWT token
   */
  verify(token: string): any {
    try {
      return jwt.verify(token, this.secret, {
        issuer: this.issuer,
        audience: this.audience
      });
    } catch (error) {
      return null;
    }
  }
  
  /**
   * Decode a JWT without verification
   */
  decode(token: string): any {
    return jwt.decode(token);
  }
  
  /**
   * Refresh a token
   */
  refresh(token: string): string | null {
    const decoded = this.verify(token);
    if (!decoded) return null;
    
    // Remove expiration and re-sign
    const { exp, iat, ...payload } = decoded;
    return this.sign(payload);
  }
}

// Usage
const jwtManager = new JWTManager({
  secret: process.env.JWT_SECRET || 'your-secret-key',
  expiresIn: '24h'
});

// Generate token
const token = jwtManager.sign({
  userId: 'user-123',
  roles: ['admin', 'editor']
});

// Verify token
const decoded = jwtManager.verify(token);
if (decoded) {
  console.log('Valid token for user:', decoded.userId);
}
```

**Environment Variables:**
```env
JWT_SECRET=your_secure_jwt_secret_key
JWT_ISSUER=ai-platform
JWT_AUDIENCE=ai-clients
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d
```

---

### 1.3 OAuth 2.0

**Overview:** OAuth 2.0 provides delegated authorization for user-based access.

**Implementation (Simplified):**

```typescript
import axios from 'axios';

/**
 * OAuth 2.0 Client
 */
export class OAuthClient {
  private clientId: string;
  private clientSecret: string;
  private tokenEndpoint: string;
  private authorizationEndpoint: string;
  
  constructor(config: {
    clientId: string;
    clientSecret: string;
    tokenEndpoint: string;
    authorizationEndpoint: string;
  }) {
    this.clientId = config.clientId;
    this.clientSecret = config.clientSecret;
    this.tokenEndpoint = config.tokenEndpoint;
    this.authorizationEndpoint = config.authorizationEndpoint;
  }
  
  /**
   * Get authorization URL for user login
   */
  getAuthorizationURL(redirectUri: string, scope: string, state: string): string {
    const params = new URLSearchParams({
      response_type: 'code',
      client_id: this.clientId,
      redirect_uri: redirectUri,
      scope,
      state
    });
    return `${this.authorizationEndpoint}?${params.toString()}`;
  }
  
  /**
   * Exchange authorization code for access token
   */
  async exchangeCode(code: string, redirectUri: string): Promise<any> {
    const params = new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: redirectUri,
      client_id: this.clientId,
      client_secret: this.clientSecret
    });
    
    const response = await axios.post(this.tokenEndpoint, params.toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    
    return response.data;
  }
  
  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string): Promise<any> {
    const params = new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshToken,
      client_id: this.clientId,
      client_secret: this.clientSecret
    });
    
    const response = await axios.post(this.tokenEndpoint, params.toString(), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    });
    
    return response.data;
  }
}

// Usage
const oauth = new OAuthClient({
  clientId: process.env.OAUTH_CLIENT_ID,
  clientSecret: process.env.OAUTH_CLIENT_SECRET,
  tokenEndpoint: 'https://auth.example.com/oauth/token',
  authorizationEndpoint: 'https://auth.example.com/oauth/authorize'
});
```

---

## Part 2: Authorization

### 2.1 Role-Based Access Control (RBAC)

**Overview:** RBAC controls access based on user roles.

**Implementation:**

```typescript
/**
 * Role definitions
 */
export type Role = 'admin' | 'editor' | 'viewer' | 'agent' | 'system';

/**
 * Permission definitions
 */
export type Permission = 
  | 'read:all'
  | 'read:tools'
  | 'read:resources'
  | 'read:prompts'
  | 'write:tools'
  | 'write:resources'
  | 'write:prompts'
  | 'execute:tools'
  | 'admin:users'
  | 'admin:permissions';

/**
 * Role-Permission mapping
 */
const rolePermissions: Record<Role, Permission[]> = {
  admin: [
    'read:all',
    'read:tools',
    'read:resources',
    'read:prompts',
    'write:tools',
    'write:resources',
    'write:prompts',
    'execute:tools',
    'admin:users',
    'admin:permissions'
  ],
  editor: [
    'read:all',
    'read:tools',
    'read:resources',
    'read:prompts',
    'write:tools',
    'write:resources',
    'write:prompts',
    'execute:tools'
  ],
  viewer: [
    'read:tools',
    'read:resources',
    'read:prompts'
  ],
  agent: [
    'read:tools',
    'read:resources',
    'read:prompts',
    'execute:tools'
  ],
  system: [
    'read:all',
    'read:tools',
    'read:resources',
    'read:prompts',
    'execute:tools'
  ]
};

/**
 * Authorization Manager
 */
export class AuthorizationManager {
  private userRoles: Map<string, Role[]> = new Map();
  private userPermissions: Map<string, Set<Permission>> = new Map();
  
  /**
   * Assign role to user
   */
  assignRole(userId: string, role: Role): void {
    if (!this.userRoles.has(userId)) {
      this.userRoles.set(userId, []);
    }
    const roles = this.userRoles.get(userId)!;
    if (!roles.includes(role)) {
      roles.push(role);
    }
    // Update permissions cache
    this.updatePermissions(userId);
  }
  
  /**
   * Remove role from user
   */
  removeRole(userId: string, role: Role): void {
    const roles = this.userRoles.get(userId);
    if (roles) {
      const index = roles.indexOf(role);
      if (index !== -1) {
        roles.splice(index, 1);
        this.updatePermissions(userId);
      }
    }
  }
  
  /**
   * Check if user has a permission
   */
  hasPermission(userId: string, permission: Permission): boolean {
    const permissions = this.userPermissions.get(userId);
    if (!permissions) return false;
    return permissions.has(permission);
  }
  
  /**
   * Check if user has any of the required permissions
   */
  hasAnyPermission(userId: string, permissions: Permission[]): boolean {
    const userPerms = this.userPermissions.get(userId);
    if (!userPerms) return false;
    return permissions.some(p => userPerms.has(p));
  }
  
  /**
   * Update user permissions cache
   */
  private updatePermissions(userId: string): void {
    const roles = this.userRoles.get(userId) || [];
    const permissions = new Set<Permission>();
    
    for (const role of roles) {
      const perms = rolePermissions[role] || [];
      for (const perm of perms) {
        permissions.add(perm);
      }
    }
    
    this.userPermissions.set(userId, permissions);
  }
  
  /**
   * Get user roles
   */
  getRoles(userId: string): Role[] {
    return this.userRoles.get(userId) || [];
  }
  
  /**
   * Get user permissions
   */
  getPermissions(userId: string): Permission[] {
    const perms = this.userPermissions.get(userId);
    return perms ? Array.from(perms) : [];
  }
}

// Usage
const authManager = new AuthorizationManager();

// Assign roles
authManager.assignRole('user-123', 'admin');
authManager.assignRole('user-456', 'viewer');

// Check permissions
if (authManager.hasPermission('user-123', 'write:tools')) {
  // Allow write operation
}

// MCP tool authorization middleware
function authorizeTool(userId: string, toolName: string): boolean {
  // Check if user can execute tools
  if (!authManager.hasPermission(userId, 'execute:tools')) {
    return false;
  }
  
  // Additional tool-specific checks
  if (toolName === 'delete_users') {
    return authManager.hasPermission(userId, 'admin:users');
  }
  
  return true;
}
```

---

### 2.2 Attribute-Based Access Control (ABAC)

**Overview:** ABAC controls access based on attributes of the user, resource, and environment.

**Implementation:**

```typescript
/**
 * ABAC Policy
 */
export interface ABACPolicy {
  id: string;
  description: string;
  conditions: ABACCondition[];
  effect: 'allow' | 'deny';
}

/**
 * ABAC Condition
 */
export interface ABACCondition {
  attribute: string;
  operator: 'equals' | 'contains' | 'startsWith' | 'endsWith' | 'greaterThan' | 'lessThan' | 'in';
  value: any;
}

/**
 * User attributes
 */
export interface UserAttributes {
  id: string;
  roles: string[];
  department?: string;
  clearance?: string;
  location?: string;
  [key: string]: any;
}

/**
 * Resource attributes
 */
export interface ResourceAttributes {
  type: string;
  ownerId?: string;
  classification?: string;
  tags: string[];
  [key: string]: any;
}

/**
 * Environment attributes
 */
export interface EnvironmentAttributes {
  timeOfDay: string;
  ipAddress: string;
  userAgent: string;
  authenticationMethod: string;
  [key: string]: any;
}

/**
 * ABAC Manager
 */
export class ABACManager {
  private policies: ABACPolicy[] = [];
  
  /**
   * Add a policy
   */
  addPolicy(policy: ABACPolicy): void {
    this.policies.push(policy);
  }
  
  /**
   * Evaluate a policy against user, resource, and environment
   */
  evaluate(
    user: UserAttributes,
    resource: ResourceAttributes,
    environment: EnvironmentAttributes
  ): 'allow' | 'deny' {
    // Find first matching policy
    for (const policy of this.policies) {
      const matches = this.evaluateConditions(
        policy.conditions,
        user,
        resource,
        environment
      );
      
      if (matches) {
        return policy.effect;
      }
    }
    
    // Default deny
    return 'deny';
  }
  
  /**
   * Evaluate conditions
   */
  private evaluateConditions(
    conditions: ABACCondition[],
    user: UserAttributes,
    resource: ResourceAttributes,
    environment: EnvironmentAttributes
  ): boolean {
    // Evaluate each condition
    for (const condition of conditions) {
      // Determine which attribute set to use
      const parts = condition.attribute.split('.');
      let value: any;
      
      if (parts[0] === 'user' && parts[1]) {
        value = user[parts[1]];
      } else if (parts[0] === 'resource' && parts[1]) {
        value = resource[parts[1]];
      } else if (parts[0] === 'environment' && parts[1]) {
        value = environment[parts[1]];
      } else {
        value = condition.attribute;
      }
      
      // Evaluate condition
      const result = this.evaluateCondition(
        condition.operator,
        value,
        condition.value
      );
      
      if (!result) {
        return false;
      }
    }
    
    return true;
  }
  
  /**
   * Evaluate a single condition
   */
  private evaluateCondition(operator: string, actual: any, expected: any): boolean {
    switch (operator) {
      case 'equals':
        return actual === expected;
      case 'contains':
        if (Array.isArray(actual)) {
          return actual.includes(expected);
        }
        if (typeof actual === 'string') {
          return actual.includes(expected);
        }
        return false;
      case 'startsWith':
        return typeof actual === 'string' && actual.startsWith(expected);
      case 'endsWith':
        return typeof actual === 'string' && actual.endsWith(expected);
      case 'greaterThan':
        return actual > expected;
      case 'lessThan':
        return actual < expected;
      case 'in':
        return expected.includes(actual);
      default:
        return false;
    }
  }
}

// Usage
const abac = new ABACManager();

// Define policies
abac.addPolicy({
  id: 'admin-access',
  description: 'Admins can access everything',
  conditions: [
    { attribute: 'user.roles', operator: 'contains', value: 'admin' }
  ],
  effect: 'allow'
});

abac.addPolicy({
  id: 'resource-owner',
  description: 'Users can access their own resources',
  conditions: [
    { attribute: 'user.id', operator: 'equals', value: 'resource.ownerId' }
  ],
  effect: 'allow'
});

abac.addPolicy({
  id: 'restricted-time',
  description: 'No access outside business hours',
  conditions: [
    { attribute: 'environment.timeOfDay', operator: 'equals', value: 'business-hours' }
  ],
  effect: 'deny'
});

// Evaluate
const user: UserAttributes = {
  id: 'user-123',
  roles: ['editor'],
  department: 'engineering'
};

const resource: ResourceAttributes = {
  type: 'database',
  ownerId: 'user-123',
  tags: ['production']
};

const environment: EnvironmentAttributes = {
  timeOfDay: 'business-hours',
  ipAddress: '192.168.1.100',
  userAgent: 'Mozilla/5.0',
  authenticationMethod: 'jwt'
};

const result = abac.evaluate(user, resource, environment);
console.log('Access:', result); // 'allow'
```

---

## Part 3: Security Headers

### 3.1 HTTP Security Headers

**Overview:** HTTP security headers protect against common web vulnerabilities.

**Implementation:**

```typescript
/**
 * Security Headers Middleware
 */
export function securityHeaders() {
  return (req: any, res: any, next: () => void) => {
    // Set security headers
    res.setHeader('X-Frame-Options', 'DENY');
    res.setHeader('X-Content-Type-Options', 'nosniff');
    res.setHeader('X-XSS-Protection', '1; mode=block');
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
    res.setHeader('Content-Security-Policy', [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline'",
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data:",
      "connect-src 'self'",
      "font-src 'self'",
      "object-src 'none'",
      "frame-ancestors 'none'",
      "base-uri 'self'",
      "form-action 'self'"
    ].join('; '));
    res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
    res.setHeader('Permissions-Policy', [
      'geolocation=()',
      'microphone=()',
      'camera=()',
      'payment=()',
      'usb=()'
    ].join(', '));
    
    next();
  };
}

// Usage in Express
import express from 'express';
const app = express();
app.use(securityHeaders());
```

---

### 3.2 CORS Configuration

**Overview:** CORS controls cross-origin resource sharing.

**Implementation:**

```typescript
/**
 * CORS Configuration
 */
export function corsMiddleware(options: {
  origins: string[];
  methods: string[];
  headers: string[];
  maxAge: number;
}) {
  const allowedOrigins = options.origins;
  const allowedMethods = options.methods || ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'];
  const allowedHeaders = options.headers || ['Content-Type', 'Authorization', 'X-API-Key'];
  const maxAge = options.maxAge || 86400;
  
  return (req: any, res: any, next: () => void) => {
    const origin = req.headers.origin;
    
    // Check if origin is allowed
    if (origin && allowedOrigins.includes(origin)) {
      res.setHeader('Access-Control-Allow-Origin', origin);
      res.setHeader('Access-Control-Allow-Credentials', 'true');
    }
    
    // Preflight request handling
    if (req.method === 'OPTIONS') {
      res.setHeader('Access-Control-Allow-Methods', allowedMethods.join(', '));
      res.setHeader('Access-Control-Allow-Headers', allowedHeaders.join(', '));
      res.setHeader('Access-Control-Max-Age', String(maxAge));
      return res.status(204).end();
    }
    
    next();
  };
}

// Usage
app.use(corsMiddleware({
  origins: [
    'https://app.example.com',
    'https://admin.example.com',
    'http://localhost:3000'
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  headers: ['Content-Type', 'Authorization'],
  maxAge: 86400
}));
```

---

## Part 4: Data Protection

### 4.1 Encryption

**Overview:** Encrypt sensitive data at rest and in transit.

**Implementation:**

```typescript
import crypto from 'crypto';

/**
 * Encryption Service
 */
export class EncryptionService {
  private algorithm: string = 'aes-256-gcm';
  private key: Buffer;
  
  constructor(encryptionKey: string) {
    if (encryptionKey.length !== 64) {
      throw new Error('Encryption key must be 64 hex characters (32 bytes)');
    }
    this.key = Buffer.from(encryptionKey, 'hex');
  }
  
  /**
   * Encrypt data
   */
  encrypt(text: string): { encrypted: string; iv: string; authTag: string } {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag().toString('hex');
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag
    };
  }
  
  /**
   * Decrypt data
   */
  decrypt(encrypted: string, iv: string, authTag: string): string {
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      this.key,
      Buffer.from(iv, 'hex')
    );
    decipher.setAuthTag(Buffer.from(authTag, 'hex'));
    
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
  
  /**
   * Hash data (one-way)
   */
  hash(data: string, salt?: string): string {
    const hash = crypto.createHash('sha256');
    hash.update(salt || '');
    hash.update(data);
    return hash.digest('hex');
  }
  
  /**
   * Verify hash
   */
  verifyHash(data: string, hash: string, salt?: string): boolean {
    return this.hash(data, salt) === hash;
  }
}

// Usage
const encryption = new EncryptionService(process.env.ENCRYPTION_KEY || '');

// Encrypt sensitive data
const { encrypted, iv, authTag } = encryption.encrypt('sensitive-data');

// Decrypt data
const decrypted = encryption.decrypt(encrypted, iv, authTag);
console.log('Decrypted:', decrypted);

// Hash password
const passwordHash = encryption.hash('user-password', 'random-salt');
```

**Environment Variables:**
```env
ENCRYPTION_KEY=64_character_hex_encryption_key
```

---

### 4.2 Data Masking

**Overview:** Mask sensitive data in logs and responses.

**Implementation:**

```typescript
/**
 * Data Masking Service
 */
export class DataMasking {
  /**
   * Mask email addresses
   */
  maskEmail(email: string): string {
    if (!email) return '';
    const [local, domain] = email.split('@');
    if (!domain) return email;
    const maskedLocal = local.length > 2 
      ? local[0] + '*'.repeat(Math.min(local.length - 2, 5)) + local[local.length - 1]
      : '*'.repeat(local.length);
    return `${maskedLocal}@${domain}`;
  }
  
  /**
   * Mask phone numbers
   */
  maskPhone(phone: string): string {
    if (!phone) return '';
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length <= 4) return '*'.repeat(cleaned.length);
    return '*'.repeat(cleaned.length - 4) + cleaned.slice(-4);
  }
  
  /**
   * Mask credit card numbers
   */
  maskCreditCard(card: string): string {
    if (!card) return '';
    const cleaned = card.replace(/\D/g, '');
    if (cleaned.length <= 4) return '*'.repeat(cleaned.length);
    return '*'.repeat(cleaned.length - 4) + cleaned.slice(-4);
  }
  
  /**
   * Mask arbitrary sensitive data
   */
  maskSensitive(data: any, sensitiveFields: string[]): any {
    if (typeof data !== 'object' || data === null) {
      return data;
    }
    
    if (Array.isArray(data)) {
      return data.map(item => this.maskSensitive(item, sensitiveFields));
    }
    
    const masked = { ...data };
    for (const field of sensitiveFields) {
      if (field in masked) {
        const value = masked[field];
        if (typeof value === 'string') {
          // Mask based on field name or value type
          if (field.toLowerCase().includes('email')) {
            masked[field] = this.maskEmail(value);
          } else if (field.toLowerCase().includes('phone')) {
            masked[field] = this.maskPhone(value);
          } else if (field.toLowerCase().includes('card')) {
            masked[field] = this.maskCreditCard(value);
          } else {
            masked[field] = '***REDACTED***';
          }
        } else if (value !== null && value !== undefined) {
          masked[field] = '***REDACTED***';
        }
      }
    }
    
    return masked;
  }
  
  /**
   * Mask data for logging
   */
  maskForLog(data: any): any {
    const sensitiveFields = [
      'password', 'token', 'apiKey', 'secret', 'key',
      'authorization', 'creditCard', 'ssn', 'email', 'phone'
    ];
    return this.maskSensitive(data, sensitiveFields);
  }
}

// Usage
const masker = new DataMasking();

// Log masking
console.log('User:', masker.maskForLog({
  id: 1,
  email: 'alice@example.com',
  token: 'abcdef123456'
}));
// { id: 1, email: 'a*****e@example.com', token: '***REDACTED***' }
```

---

## Part 5: Security Auditing

### 5.1 Audit Logger

**Overview:** Log all security-relevant events for auditing.

**Implementation:**

```typescript
/**
 * Audit Log Entry
 */
export interface AuditLog {
  id: string;
  timestamp: Date;
  userId: string;
  action: string;
  resource: string;
  resourceId?: string;
  result: 'success' | 'failure' | 'denied';
  details?: Record<string, any>;
  ipAddress: string;
  userAgent: string;
}

/**
 * Audit Logger
 */
export class AuditLogger {
  private logs: AuditLog[] = [];
  private maxSize: number = 10000;
  
  /**
   * Log an audit event
   */
  log(event: Omit<AuditLog, 'id' | 'timestamp'>): void {
    const log: AuditLog = {
      id: `audit-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date(),
      ...event
    };
    
    this.logs.push(log);
    
    // Trim if exceeded max size
    if (this.logs.length > this.maxSize) {
      this.logs = this.logs.slice(-this.maxSize);
    }
    
    // Write to persistent storage
    this.persist(log);
  }
  
  /**
   * Query audit logs
   */
  query(params: {
    userId?: string;
    action?: string;
    resource?: string;
    result?: AuditLog['result'];
    startDate?: Date;
    endDate?: Date;
    limit?: number;
  }): AuditLog[] {
    let results = this.logs;
    
    if (params.userId) {
      results = results.filter(log => log.userId === params.userId);
    }
    
    if (params.action) {
      results = results.filter(log => log.action === params.action);
    }
    
    if (params.resource) {
      results = results.filter(log => log.resource === params.resource);
    }
    
    if (params.result) {
      results = results.filter(log => log.result === params.result);
    }
    
    if (params.startDate) {
      results = results.filter(log => log.timestamp >= params.startDate!);
    }
    
    if (params.endDate) {
      results = results.filter(log => log.timestamp <= params.endDate!);
    }
    
    results = results.slice(-(params.limit || 100));
    
    return results;
  }
  
  /**
   * Persist log entry
   */
  private async persist(log: AuditLog): Promise<void> {
    // In production, write to a database or file
    // This is a simplified example
    console.log('[AUDIT]', JSON.stringify(log));
    
    // Could also send to external logging service
    // await sendToELK(log);
  }
  
  /**
   * Create a security middleware
   */
  createMiddleware() {
    return (req: any, res: any, next: () => void) => {
      // Record all requests
      const startTime = Date.now();
      
      res.on('finish', () => {
        this.log({
          userId: req.user?.id || 'anonymous',
          action: `${req.method} ${req.path}`,
          resource: req.path,
          result: res.statusCode < 400 ? 'success' : 'failure',
          details: {
            statusCode: res.statusCode,
            responseTime: Date.now() - startTime,
            query: req.query,
            body: req.body ? { ...req.body } : undefined
          },
          ipAddress: req.ip || req.connection.remoteAddress,
          userAgent: req.headers['user-agent'] || 'unknown'
        });
      });
      
      next();
    };
  }
}

// Usage
const auditLogger = new AuditLogger();

// Log security events
auditLogger.log({
  userId: 'user-123',
  action: 'login',
  resource: 'auth',
  result: 'success',
  details: { method: 'jwt', ip: '192.168.1.100' },
  ipAddress: '192.168.1.100',
  userAgent: 'Mozilla/5.0'
});

// Log denied access
auditLogger.log({
  userId: 'user-456',
  action: 'tool/delete_users',
  resource: 'users',
  result: 'denied',
  details: { tool: 'delete_users', reason: 'Insufficient permissions' },
  ipAddress: '192.168.1.101',
  userAgent: 'Mozilla/5.0'
});

// Query audit logs
const failedLogins = auditLogger.query({
  action: 'login',
  result: 'failure',
  limit: 10
});
```

---

## Part 6: Rate Limiting

### 6.1 Rate Limiting Implementation

**Overview:** Rate limiting prevents abuse and protects against DoS attacks.

**Implementation:**

```typescript
import rateLimit from 'express-rate-limit';
import Redis from 'ioredis';

/**
 * Distributed Rate Limiter
 */
export class RateLimiter {
  private redis: Redis;
  private windowMs: number;
  private maxRequests: number;
  
  constructor(config: {
    redisUrl: string;
    windowMs?: number;
    maxRequests?: number;
  }) {
    this.redis = new Redis(config.redisUrl);
    this.windowMs = config.windowMs || 60000; // 1 minute
    this.maxRequests = config.maxRequests || 100;
  }
  
  /**
   * Check if request is allowed
   */
  async isAllowed(key: string): Promise<{
    allowed: boolean;
    remaining: number;
    reset: number;
  }> {
    const now = Date.now();
    const windowStart = Math.floor(now / this.windowMs) * this.windowMs;
    const redisKey = `rate:${key}:${windowStart}`;
    
    // Increment counter
    const count = await this.redis.incr(redisKey);
    
    // Set expiration if new key
    if (count === 1) {
      await this.redis.expire(redisKey, Math.ceil(this.windowMs / 1000));
    }
    
    const remaining = Math.max(0, this.maxRequests - count);
    const reset = windowStart + this.windowMs;
    
    return {
      allowed: count <= this.maxRequests,
      remaining,
      reset
    };
  }
  
  /**
   * Rate limiting middleware
   */
  middleware() {
    return async (req: any, res: any, next: () => void) => {
      // Determine rate limit key
      const key = this.getKey(req);
      
      try {
        const result = await this.isAllowed(key);
        
        // Set rate limit headers
        res.setHeader('X-RateLimit-Limit', String(this.maxRequests));
        res.setHeader('X-RateLimit-Remaining', String(result.remaining));
        res.setHeader('X-RateLimit-Reset', String(result.reset));
        
        if (!result.allowed) {
          return res.status(429).json({
            error: 'Rate limit exceeded',
            retryAfter: Math.ceil((result.reset - Date.now()) / 1000)
          });
        }
        
        next();
      } catch (error) {
        console.error('Rate limiter error:', error);
        // Fail open
        next();
      }
    };
  }
  
  /**
   * Get rate limit key for request
   */
  private getKey(req: any): string {
    // Use API key if present, otherwise IP
    const apiKey = req.headers['x-api-key'] || req.query.apiKey;
    if (apiKey) {
      return `api:${apiKey}`;
    }
    
    const ip = req.ip || req.connection.remoteAddress;
    return `ip:${ip}`;
  }
}

// Usage in Express
const rateLimiter = new RateLimiter({
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  windowMs: 60000,
  maxRequests: 100
});

app.use(rateLimiter.middleware());

// Different limits for different endpoints
const strictLimiter = new RateLimiter({
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  windowMs: 60000,
  maxRequests: 10
});

app.post('/auth/login', strictLimiter.middleware());
app.post('/api/tools/*', rateLimiter.middleware());
```

---

## Part 7: Security Checklist

### Development Security

- [ ] Use environment variables for all secrets
- [ ] Never commit `.env` files
- [ ] Use `.env.example` for template
- [ ] Validate environment variables on startup
- [ ] Use strong, random API keys
- [ ] Rotate secrets regularly
- [ ] Use HTTPS in production

### Authentication

- [ ] Implement proper authentication (API keys, JWT, or OAuth)
- [ ] Use secure password hashing (bcrypt, Argon2)
- [ ] Implement session management
- [ ] Set appropriate token expiration
- [ ] Use refresh tokens for long-lived sessions
- [ ] Implement rate limiting on auth endpoints
- [ ] Log authentication events

### Authorization

- [ ] Implement RBAC or ABAC
- [ ] Apply principle of least privilege
- [ ] Validate all access permissions
- [ ] Use scoped API keys
- [ ] Audit authorization decisions

### Data Protection

- [ ] Encrypt sensitive data at rest
- [ ] Use TLS/HTTPS in transit
- [ ] Mask sensitive data in logs
- [ ] Implement proper data sanitization
- [ ] Validate all user inputs
- [ ] Prevent SQL injection (use parameterized queries)
- [ ] Prevent XSS attacks

### Monitoring

- [ ] Implement audit logging
- [ ] Monitor for suspicious activity
- [ ] Set up alerts for security events
- [ ] Regularly review logs
- [ ] Implement intrusion detection

### Deployment

- [ ] Use secure container images
- [ ] Keep dependencies updated
- [ ] Use secret management (Kubernetes Secrets, Vault)
- [ ] Implement network security (firewalls, network policies)
- [ ] Use security scanning tools
- [ ] Regular security audits

---

## Part 8: Security Tools and Resources

### Recommended Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| **Helmet.js** | HTTP security headers | Express security headers |
| **CORS** | Cross-origin resource sharing | CORS configuration |
| **express-rate-limit** | Rate limiting | Request throttling |
| **bcrypt** | Password hashing | Secure password storage |
| **jsonwebtoken** | JWT handling | Authentication tokens |
| **helmet** | Security headers | HTTP security |
| **node-crypto** | Encryption | Data encryption |
| **jest** | Testing | Security tests |

### Security Resources

**OWASP Top 10:**
1. Broken Access Control
2. Cryptographic Failures
3. Injection
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable and Outdated Components
7. Identification and Authentication Failures
8. Software and Data Integrity Failures
9. Security Logging and Monitoring Failures
10. Server-Side Request Forgery (SSRF)

### Best Practices

1. **Regular Security Audits** — Conduct regular security reviews
2. **Penetration Testing** — Test your systems for vulnerabilities
3. **Vulnerability Scanning** — Use automated scanners
4. **Security Training** — Train developers on security best practices
5. **Incident Response Plan** — Have a plan for security incidents

---

This appendix provides a comprehensive reference for implementing authentication, authorization, and security in your AI systems. Use it as a guide when securing your MCP servers, A2A agents, and production deployments.
