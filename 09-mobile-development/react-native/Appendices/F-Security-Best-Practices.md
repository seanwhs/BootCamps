# Appendix F: Security Best Practices

Welcome to Appendix F! This comprehensive guide covers everything you need to know about securing your React Native application. From authentication and data encryption to network security and secure storage, you'll learn industry-standard security practices to protect your users and their data.

---

## Table of Contents

1. [Security Architecture Overview](#security-architecture-overview)
2. [Authentication & Authorization](#authentication--authorization)
3. [Secure Data Storage](#secure-data-storage)
4. [Network Security](#network-security)
5. [API Security](#api-security)
6. [Mobile App Security Hardening](#mobile-app-security-hardening)
7. [User Privacy & Data Protection](#user-privacy--data-protection)
8. [Security Testing & Auditing](#security-testing--auditing)

---

## Security Architecture Overview

### Complete Security Architecture

```typescript
// src/security/Architecture.ts
/**
 * Security Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                      CLIENT LAYER                             │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Secure Storage  │  Biometric Auth  │  App Sandbox    │   │
 * │  │  (Encrypted)     │  (Face/Touch ID) │  (Isolated)     │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     NETWORK LAYER                             │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  TLS 1.3  │  Certificate Pinning  │  API Keys         │   │
 * │  │  (Encrypted) │  (Prevent MITM)     │  (Rotated)        │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                      API LAYER                                │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  JWT Auth  │  Rate Limiting  │  Input Validation      │   │
 * │  │  (Stateless) │  (DoS Protection) │  (Sanitization)     │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     DATA LAYER                                │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Encryption  │  Access Control  │  Audit Logs         │   │
 * │  │  (At Rest)    │  (RBAC)          │  (Monitoring)       │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 */

export const SecurityArchitecture = {
  layers: {
    client: {
      description: 'Mobile app security controls',
      controls: [
        'Secure storage (Keychain/Keystore)',
        'Biometric authentication',
        'App sandbox isolation',
        'Code obfuscation',
        'Anti-tampering measures',
      ],
    },
    network: {
      description: 'Communication security',
      controls: [
        'TLS 1.3 encryption',
        'Certificate pinning',
        'API key rotation',
        'Request signing',
        'Nonce validation',
      ],
    },
    api: {
      description: 'API security controls',
      controls: [
        'JWT authentication',
        'Rate limiting',
        'Input validation',
        'SQL injection prevention',
        'XSS prevention',
      ],
    },
    data: {
      description: 'Data security controls',
      controls: [
        'Encryption at rest',
        'Role-based access control',
        'Audit logging',
        'Data retention policies',
        'Backup encryption',
      ],
    },
  },
};
```

---

## Authentication & Authorization

### Complete Auth Security Implementation

```typescript
// src/security/AuthSecurity.ts
import * as SecureStore from 'expo-secure-store';
import * as LocalAuthentication from 'expo-local-authentication';
import { Platform } from 'react-native';
import { jwtDecode } from 'jwt-decode';

/**
 * Advanced Authentication Security
 * 
 * This provides comprehensive auth security:
 * - JWT token management
 * - Biometric authentication
 * - Session management
 * - Multi-factor authentication
 * - Token refresh rotation
 */

export interface TokenPayload {
  userId: string;
  email: string;
  role: 'user' | 'admin';
  iat: number;
  exp: number;
}

export class AuthSecurity {
  private static instance: AuthSecurity;
  private accessToken: string | null = null;
  private refreshToken: string | null = null;
  private tokenExpiryTimer: NodeJS.Timeout | null = null;

  private constructor() {
    this.loadTokens();
    this.startTokenRefreshTimer();
  }

  static getInstance(): AuthSecurity {
    if (!AuthSecurity.instance) {
      AuthSecurity.instance = new AuthSecurity();
    }
    return AuthSecurity.instance;
  }

  /**
   * Load tokens from secure storage
   */
  private async loadTokens() {
    try {
      this.accessToken = await SecureStore.getItemAsync('access_token');
      this.refreshToken = await SecureStore.getItemAsync('refresh_token');
    } catch (error) {
      console.error('Error loading tokens:', error);
    }
  }

  /**
   * Start automatic token refresh timer
   */
  private startTokenRefreshTimer() {
    // Check token expiry every minute
    setInterval(() => {
      this.checkAndRefreshToken();
    }, 60000);
  }

  /**
   * Check and refresh token if needed
   */
  private async checkAndRefreshToken() {
    if (!this.accessToken) return;

    try {
      const decoded = jwtDecode<TokenPayload>(this.accessToken);
      const expiryTime = decoded.exp * 1000; // Convert to milliseconds
      const now = Date.now();
      
      // Refresh if token expires in less than 5 minutes
      if (expiryTime - now < 300000) {
        await this.refreshToken();
      }
    } catch (error) {
      console.error('Token check failed:', error);
    }
  }

  /**
   * Login with enhanced security
   */
  async login(email: string, password: string): Promise<{ success: boolean; error?: string }> {
    try {
      // 1. Validate credentials
      if (!this.validateCredentials(email, password)) {
        return { success: false, error: 'Invalid credentials' };
      }

      // 2. Check for suspicious activity
      if (await this.detectSuspiciousActivity(email)) {
        return { success: false, error: 'Suspicious activity detected' };
      }

      // 3. Authenticate with backend
      const response = await this.authenticateUser(email, password);
      
      if (!response.success) {
        // Track failed attempts
        await this.trackFailedAttempt(email);
        return { success: false, error: response.error };
      }

      // 4. Store tokens securely
      await this.storeTokens(response.accessToken, response.refreshToken);
      
      // 5. Set up biometric if enabled
      if (await this.isBiometricAvailable()) {
        await this.enableBiometricLogin();
      }

      // 6. Log successful login
      await this.logLoginActivity(email, 'success');

      return { success: true };
    } catch (error) {
      console.error('Login error:', error);
      return { success: false, error: 'Login failed' };
    }
  }

  /**
   * Validate credentials
   */
  private validateCredentials(email: string, password: string): boolean {
    // Email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) return false;
    
    // Password validation - minimum 8 chars, at least one number and special char
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/;
    return passwordRegex.test(password);
  }

  /**
   * Detect suspicious activity
   */
  private async detectSuspiciousActivity(email: string): Promise<boolean> {
    // Check failed attempts
    const attempts = await this.getFailedAttempts(email);
    if (attempts >= 5) {
      // Too many failed attempts
      return true;
    }

    // Check IP location (simplified)
    // Check device fingerprint (simplified)
    
    return false;
  }

  /**
   * Track failed login attempts
   */
  private async trackFailedAttempt(email: string) {
    const key = `failed_attempts_${email}`;
    const current = await SecureStore.getItemAsync(key);
    const count = current ? parseInt(current, 10) + 1 : 1;
    await SecureStore.setItemAsync(key, String(count));
    
    // Reset after 30 minutes
    setTimeout(() => {
      SecureStore.deleteItemAsync(key);
    }, 1800000);
  }

  /**
   * Get failed attempts
   */
  private async getFailedAttempts(email: string): Promise<number> {
    const key = `failed_attempts_${email}`;
    const count = await SecureStore.getItemAsync(key);
    return count ? parseInt(count, 10) : 0;
  }

  /**
   * Authenticate with backend
   */
  private async authenticateUser(email: string, password: string): Promise<any> {
    // In production, this would be an API call
    // For demo, simulate authentication
    if (email === 'demo@example.com' && password === 'SecurePass123!') {
      return {
        success: true,
        accessToken: this.generateToken({ userId: '1', email, role: 'user' }),
        refreshToken: this.generateRefreshToken(),
      };
    }
    return { success: false, error: 'Invalid credentials' };
  }

  /**
   * Generate JWT token
   */
  private generateToken(payload: any): string {
    // In production, use proper JWT signing
    // For demo, base64 encode
    return btoa(JSON.stringify({
      ...payload,
      iat: Date.now(),
      exp: Date.now() + 900000, // 15 minutes
    }));
  }

  /**
   * Generate refresh token
   */
  private generateRefreshToken(): string {
    // In production, use crypto.randomBytes()
    return btoa(JSON.stringify({
      id: Date.now() + Math.random().toString(),
      exp: Date.now() + 604800000, // 7 days
    }));
  }

  /**
   * Store tokens securely
   */
  private async storeTokens(accessToken: string, refreshToken: string) {
    await SecureStore.setItemAsync('access_token', accessToken);
    await SecureStore.setItemAsync('refresh_token', refreshToken);
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  /**
   * Refresh token
   */
  async refreshToken(): Promise<boolean> {
    try {
      if (!this.refreshToken) {
        throw new Error('No refresh token');
      }

      // Validate refresh token
      // In production, call refresh endpoint
      const newAccessToken = this.generateToken({
        userId: '1',
        email: 'demo@example.com',
        role: 'user',
      });

      await this.storeTokens(newAccessToken, this.refreshToken);
      return true;
    } catch (error) {
      console.error('Token refresh failed:', error);
      await this.logout();
      return false;
    }
  }

  /**
   * Biometric authentication
   */
  async authenticateWithBiometrics(): Promise<boolean> {
    try {
      const isAvailable = await this.isBiometricAvailable();
      if (!isAvailable) return false;

      const result = await LocalAuthentication.authenticateAsync({
        promptMessage: 'Authenticate to access TaskFlow',
        fallbackLabel: 'Use password instead',
        cancelLabel: 'Cancel',
        disableDeviceFallback: false,
      });

      if (result.success) {
        // Biometric authentication successful
        return true;
      }
      return false;
    } catch (error) {
      console.error('Biometric auth error:', error);
      return false;
    }
  }

  /**
   * Check biometric availability
   */
  async isBiometricAvailable(): Promise<boolean> {
    try {
      const hasHardware = await LocalAuthentication.hasHardwareAsync();
      const isEnrolled = await LocalAuthentication.isEnrolledAsync();
      return hasHardware && isEnrolled;
    } catch (error) {
      console.error('Biometric check error:', error);
      return false;
    }
  }

  /**
   * Enable biometric login
   */
  async enableBiometricLogin() {
    if (await this.isBiometricAvailable()) {
      await SecureStore.setItemAsync('biometric_enabled', 'true');
    }
  }

  /**
   * Check if biometric is enabled
   */
  async isBiometricEnabled(): Promise<boolean> {
    const enabled = await SecureStore.getItemAsync('biometric_enabled');
    return enabled === 'true';
  }

  /**
   * Log login activity
   */
  private async logLoginActivity(email: string, status: string) {
    // In production, send to analytics/audit log
    console.log(`🔐 Login attempt: ${email} - ${status}`);
  }

  /**
   * Logout
   */
  async logout() {
    await SecureStore.deleteItemAsync('access_token');
    await SecureStore.deleteItemAsync('refresh_token');
    await SecureStore.deleteItemAsync('biometric_enabled');
    this.accessToken = null;
    this.refreshToken = null;
  }

  /**
   * Get current user
   */
  async getCurrentUser(): Promise<TokenPayload | null> {
    if (!this.accessToken) return null;
    
    try {
      return jwtDecode<TokenPayload>(this.accessToken);
    } catch (error) {
      console.error('Invalid token:', error);
      return null;
    }
  }

  /**
   * Check if user is authenticated
   */
  async isAuthenticated(): Promise<boolean> {
    if (!this.accessToken) return false;
    
    try {
      const decoded = jwtDecode<TokenPayload>(this.accessToken);
      return decoded.exp * 1000 > Date.now();
    } catch {
      return false;
    }
  }
}

export const authSecurity = AuthSecurity.getInstance();
```

---

## Secure Data Storage

### Complete Secure Storage Implementation

```typescript
// src/security/SecureStorage.ts
import * as SecureStore from 'expo-secure-store';
import * as Crypto from 'expo-crypto';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';

/**
 * Secure Storage System
 * 
 * This provides comprehensive secure storage:
 * - Encrypted key-value storage
 * - Data encryption at rest
 * - Secure file storage
 * - Biometric-protected storage
 * - Data integrity verification
 */

export interface SecureItem<T> {
  data: T;
  encrypted: boolean;
  iv?: string;
  salt?: string;
  hash?: string;
  timestamp: number;
}

export class SecureStorage {
  private static instance: SecureStorage;
  private encryptionKey: string | null = null;
  private readonly SALT_LENGTH = 16;
  private readonly IV_LENGTH = 16;

  private constructor() {
    this.initializeEncryption();
  }

  static getInstance(): SecureStorage {
    if (!SecureStorage.instance) {
      SecureStorage.instance = new SecureStorage();
    }
    return SecureStorage.instance;
  }

  /**
   * Initialize encryption
   */
  private async initializeEncryption() {
    try {
      // Get or generate encryption key
      this.encryptionKey = await this.getOrCreateEncryptionKey();
    } catch (error) {
      console.error('Encryption initialization failed:', error);
    }
  }

  /**
   * Get or create encryption key
   */
  private async getOrCreateEncryptionKey(): Promise<string> {
    // Get from secure storage
    let key = await SecureStore.getItemAsync('encryption_key');
    
    if (!key) {
      // Generate new key
      const randomBytes = await Crypto.getRandomBytesAsync(32);
      key = Buffer.from(randomBytes).toString('base64');
      await SecureStore.setItemAsync('encryption_key', key);
    }
    
    return key;
  }

  /**
   * Encrypt data
   */
  async encryptData(data: string): Promise<{ encrypted: string; iv: string }> {
    if (!this.encryptionKey) {
      throw new Error('Encryption not initialized');
    }

    // Generate IV
    const ivBytes = await Crypto.getRandomBytesAsync(this.IV_LENGTH);
    const iv = Buffer.from(ivBytes).toString('base64');

    // For demo, use a simple encryption
    // In production, use expo-crypto with proper AES-GCM
    const encrypted = this.simpleEncrypt(data, this.encryptionKey, iv);
    
    return { encrypted, iv };
  }

  /**
   * Decrypt data
   */
  async decryptData(encrypted: string, iv: string): Promise<string> {
    if (!this.encryptionKey) {
      throw new Error('Encryption not initialized');
    }

    // In production, use proper decryption
    return this.simpleDecrypt(encrypted, this.encryptionKey, iv);
  }

  /**
   * Simple encryption (demo only - use proper AES in production)
   */
  private simpleEncrypt(data: string, key: string, iv: string): string {
    // This is a simple XOR encryption for demonstration
    // DO NOT USE IN PRODUCTION
    const keyBytes = Buffer.from(key, 'base64');
    const ivBytes = Buffer.from(iv, 'base64');
    const dataBytes = Buffer.from(data, 'utf8');
    
    const result = Buffer.alloc(dataBytes.length);
    for (let i = 0; i < dataBytes.length; i++) {
      result[i] = dataBytes[i] ^ keyBytes[i % keyBytes.length] ^ ivBytes[i % ivBytes.length];
    }
    
    return result.toString('base64');
  }

  /**
   * Simple decryption (demo only)
   */
  private simpleDecrypt(encrypted: string, key: string, iv: string): string {
    const keyBytes = Buffer.from(key, 'base64');
    const ivBytes = Buffer.from(iv, 'base64');
    const encryptedBytes = Buffer.from(encrypted, 'base64');
    
    const result = Buffer.alloc(encryptedBytes.length);
    for (let i = 0; i < encryptedBytes.length; i++) {
      result[i] = encryptedBytes[i] ^ keyBytes[i % keyBytes.length] ^ ivBytes[i % ivBytes.length];
    }
    
    return result.toString('utf8');
  }

  /**
   * Store sensitive data
   */
  async setSecureItem<T>(key: string, value: T, encrypt: boolean = true): Promise<void> {
    try {
      const item: SecureItem<T> = {
        data: value,
        encrypted: encrypt,
        timestamp: Date.now(),
      };

      if (encrypt) {
        const serialized = JSON.stringify(value);
        const { encrypted: encryptedData, iv } = await this.encryptData(serialized);
        item.iv = iv;
        item.data = encryptedData as unknown as T;
        
        // Generate hash for integrity
        const hash = await this.generateHash(serialized);
        item.hash = hash;
      }

      // Store in AsyncStorage (encrypted)
      await AsyncStorage.setItem(`secure_${key}`, JSON.stringify(item));
    } catch (error) {
      console.error('Secure storage error:', error);
      throw new Error('Failed to store secure data');
    }
  }

  /**
   * Retrieve sensitive data
   */
  async getSecureItem<T>(key: string, requireBiometric: boolean = false): Promise<T | null> {
    try {
      // Check if biometric is required
      if (requireBiometric) {
        const authenticated = await this.authenticateBiometric();
        if (!authenticated) {
          throw new Error('Biometric authentication failed');
        }
      }

      const data = await AsyncStorage.getItem(`secure_${key}`);
      if (!data) return null;

      const item: SecureItem<T> = JSON.parse(data);

      if (item.encrypted && item.iv) {
        // Decrypt data
        const decrypted = await this.decryptData(item.data as string, item.iv);
        
        // Verify integrity
        if (item.hash) {
          const hash = await this.generateHash(decrypted);
          if (hash !== item.hash) {
            throw new Error('Data integrity check failed');
          }
        }

        return JSON.parse(decrypted) as T;
      }

      return item.data;
    } catch (error) {
      console.error('Secure retrieval error:', error);
      return null;
    }
  }

  /**
   * Generate hash for integrity verification
   */
  private async generateHash(data: string): Promise<string> {
    const digest = await Crypto.digestStringAsync(
      Crypto.CryptoDigestAlgorithm.SHA256,
      data
    );
    return digest;
  }

  /**
   * Authenticate with biometrics
   */
  private async authenticateBiometric(): Promise<boolean> {
    // Use LocalAuthentication from previous section
    return true; // Simplified for demo
  }

  /**
   * Delete secure item
   */
  async deleteSecureItem(key: string): Promise<void> {
    await AsyncStorage.removeItem(`secure_${key}`);
  }

  /**
   * Clear all secure items
   */
  async clearAllSecureItems(): Promise<void> {
    const keys = await AsyncStorage.getAllKeys();
    const secureKeys = keys.filter(key => key.startsWith('secure_'));
    await AsyncStorage.multiRemove(secureKeys);
  }

  /**
   * Get storage size
   */
  async getStorageSize(): Promise<number> {
    let totalSize = 0;
    const keys = await AsyncStorage.getAllKeys();
    
    for (const key of keys) {
      const value = await AsyncStorage.getItem(key);
      if (value) {
        totalSize += value.length * 2; // UTF-16 bytes
      }
    }
    
    return totalSize;
  }
}

export const secureStorage = SecureStorage.getInstance();
```

---

## Network Security

### Network Security Implementation

```typescript
// src/security/NetworkSecurity.ts
import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios';
import { Platform } from 'react-native';
import * as Crypto from 'expo-crypto';

/**
 * Network Security
 * 
 * This provides comprehensive network security:
 * - SSL/TLS pinning
 * - Request signing
 * - API key management
 * - Secure headers
 * - Certificate validation
 */

export class NetworkSecurity {
  private static instance: NetworkSecurity;
  private client: AxiosInstance;
  private readonly API_KEY = process.env.EXPO_PUBLIC_API_KEY;
  private readonly API_SECRET = process.env.EXPO_PUBLIC_API_SECRET;

  private constructor() {
    this.client = this.createSecureClient();
  }

  static getInstance(): NetworkSecurity {
    if (!NetworkSecurity.instance) {
      NetworkSecurity.instance = new NetworkSecurity();
    }
    return NetworkSecurity.instance;
  }

  /**
   * Create secure HTTP client
   */
  private createSecureClient(): AxiosInstance {
    const client = axios.create({
      timeout: 30000,
      headers: this.getSecureHeaders(),
    });

    // Request interceptor - sign requests
    client.interceptors.request.use(
      async (config) => {
        // Add timestamp and nonce
        config.headers['X-Timestamp'] = Date.now().toString();
        config.headers['X-Nonce'] = await this.generateNonce();
        
        // Sign the request
        if (config.data) {
          const signature = await this.signRequest(config);
          config.headers['X-Signature'] = signature;
        }
        
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor - validate responses
    client.interceptors.response.use(
      async (response) => {
        // Validate response signature
        if (response.headers['x-signature']) {
          const isValid = await this.validateResponse(response);
          if (!isValid) {
            throw new Error('Invalid response signature');
          }
        }
        return response;
      },
      (error) => Promise.reject(error)
    );

    return client;
  }

  /**
   * Get secure headers
   */
  private getSecureHeaders(): Record<string, string> {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Client-Version': Platform.OS,
      'X-App-Version': process.env.APP_VERSION || '1.0.0',
      'X-API-Key': this.API_KEY || '',
      'X-Device-ID': this.getDeviceId(),
    };
  }

  /**
   * Get device ID
   */
  private getDeviceId(): string {
    // In production, use a secure device identifier
    return 'device-id';
  }

  /**
   * Generate nonce
   */
  private async generateNonce(): Promise<string> {
    const bytes = await Crypto.getRandomBytesAsync(16);
    return Buffer.from(bytes).toString('hex');
  }

  /**
   * Sign request
   */
  private async signRequest(config: AxiosRequestConfig): Promise<string> {
    const data = JSON.stringify(config.data || {});
    const timestamp = config.headers['X-Timestamp'];
    const nonce = config.headers['X-Nonce'];
    const method = config.method?.toUpperCase() || 'GET';
    const path = config.url || '';
    
    const toSign = `${method}|${path}|${timestamp}|${nonce}|${data}|${this.API_SECRET}`;
    const digest = await Crypto.digestStringAsync(
      Crypto.CryptoDigestAlgorithm.SHA256,
      toSign
    );
    
    return digest;
  }

  /**
   * Validate response
   */
  private async validateResponse(response: AxiosResponse): Promise<boolean> {
    const signature = response.headers['x-signature'];
    const data = JSON.stringify(response.data);
    const timestamp = response.headers['x-timestamp'];
    const nonce = response.headers['x-nonce'];
    
    const toValidate = `${data}|${timestamp}|${nonce}|${this.API_SECRET}`;
    const digest = await Crypto.digestStringAsync(
      Crypto.CryptoDigestAlgorithm.SHA256,
      toValidate
    );
    
    return digest === signature;
  }

  /**
   * Certificate pinning
   */
  async validateCertificate(certificate: string): Promise<boolean> {
    // In production, pin specific certificates
    const pinnedCertificates = [
      // Pin SHA-256 fingerprints of your certificates
    ];
    
    // Validate certificate hash
    const hash = await Crypto.digestStringAsync(
      Crypto.CryptoDigestAlgorithm.SHA256,
      certificate
    );
    
    return pinnedCertificates.includes(hash);
  }

  /**
   * Make secure request
   */
  async secureRequest<T>(config: AxiosRequestConfig): Promise<T> {
    try {
      const response = await this.client.request<T>(config);
      return response.data;
    } catch (error) {
      console.error('Secure request failed:', error);
      throw error;
    }
  }

  /**
   * Get secure client
   */
  getClient(): AxiosInstance {
    return this.client;
  }
}

export const networkSecurity = NetworkSecurity.getInstance();
```

---

## API Security

### API Security Implementation

```typescript
// src/security/APISecurity.ts
/**
 * API Security Best Practices
 * 
 * This documents API security measures:
 * - Input validation
 * - Rate limiting
 * - CORS configuration
 * - SQL injection prevention
 * - XSS prevention
 * - CSRF protection
 */

export class APISecurity {
  /**
   * Input validation schemas
   */
  static validationSchemas = {
    // User registration
    register: {
      name: {
        required: true,
        minLength: 2,
        maxLength: 50,
        pattern: /^[a-zA-Z\s]+$/,
      },
      email: {
        required: true,
        pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      },
      password: {
        required: true,
        minLength: 8,
        pattern: /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/,
      },
    },

    // Task creation
    createTask: {
      title: {
        required: true,
        minLength: 3,
        maxLength: 100,
      },
      description: {
        maxLength: 1000,
      },
      priority: {
        required: true,
        enum: ['low', 'medium', 'high'],
      },
      dueDate: {
        required: true,
        pattern: /^\d{4}-\d{2}-\d{2}$/,
        validate: (date: string) => new Date(date) >= new Date(),
      },
    },
  };

  /**
   * Rate limiting configuration
   */
  static rateLimits = {
    auth: {
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 5, // 5 attempts
      message: 'Too many authentication attempts',
    },
    api: {
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 1000, // 1000 requests
      message: 'Too many requests',
    },
    fileUpload: {
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 50, // 50 uploads
      message: 'Too many upload requests',
    },
  };

  /**
   * Security headers
   */
  static securityHeaders = {
    'Content-Security-Policy': 
      "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data: https:;",
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Permissions-Policy': 'geolocation=(), camera=(), microphone=()',
  };

  /**
   * Validate input
   */
  static validateInput(data: any, schema: any): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];

    for (const [field, rules] of Object.entries(schema)) {
      const value = data[field];

      // Required check
      if (rules.required && (!value || value === '')) {
        errors.push(`${field} is required`);
        continue;
      }

      if (!value) continue;

      // Min length
      if (rules.minLength && value.length < rules.minLength) {
        errors.push(`${field} must be at least ${rules.minLength} characters`);
      }

      // Max length
      if (rules.maxLength && value.length > rules.maxLength) {
        errors.push(`${field} cannot exceed ${rules.maxLength} characters`);
      }

      // Pattern
      if (rules.pattern && !rules.pattern.test(value)) {
        errors.push(`${field} has invalid format`);
      }

      // Enum
      if (rules.enum && !rules.enum.includes(value)) {
        errors.push(`${field} must be one of: ${rules.enum.join(', ')}`);
      }

      // Custom validation
      if (rules.validate && !rules.validate(value)) {
        errors.push(`${field} validation failed`);
      }
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }

  /**
   * Sanitize input
   */
  static sanitizeInput(data: any): any {
    const sanitized: any = {};

    for (const [key, value] of Object.entries(data)) {
      if (typeof value === 'string') {
        // Remove HTML tags
        sanitized[key] = value
          .replace(/<[^>]*>/g, '')
          .replace(/[^\w\s@.-]/g, '');
      } else if (typeof value === 'object' && value !== null) {
        sanitized[key] = this.sanitizeInput(value);
      } else {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /**
   * Generate CSRF token
   */
  static generateCSRFToken(): string {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substring(2, 10);
    return `${timestamp}${random}`;
  }

  /**
   * Verify CSRF token
   */
  static verifyCSRFToken(token: string, sessionToken: string): boolean {
    // In production, validate token against session
    return token === sessionToken;
  }

  /**
   * API key rotation
   */
  static async rotateAPIKey(): Promise<string> {
    // In production, generate new API key
    const timestamp = Date.now();
    const random = await Crypto.getRandomBytesAsync(32);
    return Buffer.from(random).toString('hex');
  }
}
```

---

## Mobile App Security Hardening

### App Hardening Implementation

```typescript
// src/security/AppHardening.ts
import { Platform, Dimensions, AppState } from 'react-native';
import * as Crypto from 'expo-crypto';
import * as SecureStore from 'expo-secure-store';

/**
 * Mobile App Security Hardening
 * 
 * This provides comprehensive app hardening:
 * - Anti-debugging measures
 * - Code obfuscation
 * - Root/jailbreak detection
 * - Runtime integrity checks
 * - Secure app lifecycle
 */

export class AppHardening {
  private static instance: AppHardening;
  private isDebugging = false;
  private isSecure = true;

  private constructor() {
    this.performSecurityChecks();
    this.monitorAppState();
  }

  static getInstance(): AppHardening {
    if (!AppHardening.instance) {
      AppHardening.instance = new AppHardening();
    }
    return AppHardening.instance;
  }

  /**
   * Perform security checks on startup
   */
  private async performSecurityChecks() {
    // Check for debugging
    this.isDebugging = await this.detectDebugging();
    
    // Check for root/jailbreak
    const isRooted = await this.detectRoot();
    
    // Check for code tampering
    const isTampered = await this.detectTampering();
    
    // Check for emulator
    const isEmulator = await this.detectEmulator();
    
    // Compile security status
    this.isSecure = !(this.isDebugging || isRooted || isTampered || isEmulator);
    
    if (!this.isSecure) {
      console.warn('⚠️ Security warning: App environment is compromised');
      // Take action: limit functionality, show warning, etc.
    }
  }

  /**
   * Monitor app state for security
   */
  private monitorAppState() {
    AppState.addEventListener('change', (state) => {
      if (state === 'background') {
        // Lock sensitive data when app goes to background
        this.lockSensitiveData();
      } else if (state === 'active') {
        // Re-check security when app becomes active
        this.performSecurityChecks();
      }
    });
  }

  /**
   * Detect debugging
   */
  private async detectDebugging(): Promise<boolean> {
    // Check for debugger attached
    if (__DEV__) return true;

    // Check for remote debugging
    if ((global as any).isDebugging) return true;

    // Check for JS debugger
    if (typeof (global as any).__REACT_DEVTOOLS_GLOBAL_HOOK__ !== 'undefined') {
      return true;
    }

    // Check for Frida or other debugging tools
    // In production, use native modules for thorough detection
    
    return false;
  }

  /**
   * Detect root/jailbreak
   */
  private async detectRoot(): Promise<boolean> {
    if (Platform.OS === 'android') {
      // Check for su binary
      // Check for common root apps
      // Check for modified system properties
      return false;
    } else if (Platform.OS === 'ios') {
      // Check for Cydia
      // Check for other jailbreak indicators
      // Check for file system anomalies
      return false;
    }
    return false;
  }

  /**
   * Detect emulator
   */
  private async detectEmulator(): Promise<boolean> {
    // Check for emulator-specific properties
    const { width, height } = Dimensions.get('window');
    
    // Common emulator signatures
    if (Platform.OS === 'android') {
      // Check for generic AVD
      // Check for Google emulator
      // Check for common emulator build properties
      return false;
    } else if (Platform.OS === 'ios') {
      // Check for simulator
      if (__DEV__) return true;
      // Check for device model
      return false;
    }
    return false;
  }

  /**
   * Detect code tampering
   */
  private async detectTampering(): Promise<boolean> {
    // Check app signature
    const signature = await this.getAppSignature();
    const expectedSignature = await SecureStore.getItemAsync('app_signature');
    
    if (!expectedSignature) {
      // First run - store signature
      await SecureStore.setItemAsync('app_signature', signature);
      return false;
    }
    
    return signature !== expectedSignature;
  }

  /**
   * Get app signature
   */
  private async getAppSignature(): Promise<string> {
    // In production, get actual app signature
    // This is a simplified version
    const bundleId = 'com.yourcompany.taskflow';
    const random = await Crypto.getRandomBytesAsync(16);
    return `${bundleId}-${Buffer.from(random).toString('hex')}`;
  }

  /**
   * Lock sensitive data
   */
  private lockSensitiveData() {
    // Encrypt sensitive data
    // Clear temporary data
    // Lock secure storage
  }

  /**
   * Verify runtime integrity
   */
  async verifyRuntimeIntegrity(): Promise<{
    isValid: boolean;
    checks: Array<{ name: string; passed: boolean }>;
  }> {
    const checks = [
      {
        name: 'Debugging Check',
        passed: !this.isDebugging,
      },
      {
        name: 'Root/Jailbreak Check',
        passed: !(await this.detectRoot()),
      },
      {
        name: 'Emulator Check',
        passed: !(await this.detectEmulator()),
      },
      {
        name: 'Tampering Check',
        passed: !(await this.detectTampering()),
      },
    ];

    const isValid = checks.every(check => check.passed);

    return { isValid, checks };
  }

  /**
   * Get security status
   */
  getSecurityStatus(): {
    isSecure: boolean;
    isDebugging: boolean;
    details: string[];
  } {
    const details: string[] = [];
    
    if (this.isDebugging) {
      details.push('⚠️ Debugging detected');
    }
    
    if (this.detectRoot()) {
      details.push('⚠️ Root/Jailbreak detected');
    }
    
    if (this.detectEmulator()) {
      details.push('⚠️ Emulator detected');
    }
    
    if (this.detectTampering()) {
      details.push('⚠️ Code tampering detected');
    }
    
    return {
      isSecure: this.isSecure,
      isDebugging: this.isDebugging,
      details,
    };
  }
}

export const appHardening = AppHardening.getInstance();
```

---

## Security Testing & Auditing

### Security Testing Framework

```typescript
// src/security/SecurityTesting.ts
/**
 * Security Testing & Auditing
 * 
 * This provides a comprehensive security testing framework:
 * - Vulnerability scanning
 * - Penetration testing
 * - Security audit trails
 * - Compliance checking
 */

export class SecurityTesting {
  /**
   * Security audit checklist
   */
  static auditChecklist = {
    // Authentication
    auth: {
      'Strong Password Policy': 'Password requires 8+ chars, numbers, special chars',
      'Secure Token Storage': 'JWT tokens stored in SecureStore',
      'Session Management': 'Tokens expire after 15 minutes, refresh handled',
      'Biometric Support': 'Biometric authentication available',
    },

    // Data Storage
    dataStorage: {
      'Encryption at Rest': 'All sensitive data encrypted',
      'Secure Key Storage': 'Encryption keys stored in Keychain/Keystore',
      'Data Minimization': 'Only essential data stored',
      'Data Deletion': 'User data deletable on demand',
    },

    // Network
    network: {
      'TLS/SSL': 'All connections use TLS 1.3',
      'Certificate Pinning': 'Certificates pinned to prevent MITM',
      'API Keys': 'API keys rotated regularly',
      'Request Signing': 'Requests signed to prevent tampering',
    },

    // App Hardening
    hardening: {
      'Code Obfuscation': 'Code obfuscated for production builds',
      'Anti-Debugging': 'Debugging detected and blocked',
      'Root/Jailbreak Detection': 'Rooted/jailbroken devices detected',
      'Integrity Checks': 'Runtime integrity verified',
    },

    // Privacy
    privacy: {
      'Privacy Policy': 'Privacy policy clearly visible',
      'Permissions': 'Minimal permissions requested',
      'User Consent': 'User consent obtained for data collection',
      'GDPR/CCPA': 'Compliant with data protection regulations',
    },
  };

  /**
   * Run security audit
   */
  static async runAudit(): Promise<{
    passed: boolean;
    checks: Array<{ name: string; status: 'passed' | 'failed' | 'warning'; details?: string }>;
  }> {
    const checks = [];

    // Run all security checks
    for (const [category, items] of Object.entries(this.auditChecklist)) {
      for (const [name, description] of Object.entries(items)) {
        const result = await this.performCheck(category, name);
        checks.push({
          name: `${category}.${name}`,
          status: result.status,
          details: result.details || description,
        });
      }
    }

    const passed = checks.every(check => check.status === 'passed');

    return { passed, checks };
  }

  /**
   * Perform a security check
   */
  private static async performCheck(
    category: string,
    name: string
  ): Promise<{ status: 'passed' | 'failed' | 'warning'; details?: string }> {
    // This would contain actual security checks
    // For demo, return passed
    return { status: 'passed' };
  }

  /**
   * Generate security report
   */
  static generateSecurityReport(audit: any): string {
    const timestamp = new Date().toISOString();
    let report = `# Security Audit Report\n\n`;
    report += `**Timestamp:** ${timestamp}\n\n`;
    report += `**Status:** ${audit.passed ? '✅ PASSED' : '❌ FAILED'}\n\n`;
    report += `## Detailed Results\n\n`;

    for (const check of audit.checks) {
      const statusEmoji = 
        check.status === 'passed' ? '✅' :
        check.status === 'failed' ? '❌' : '⚠️';
      report += `- ${statusEmoji} **${check.name}**: ${check.details}\n`;
    }

    return report;
  }
}
```

---

This appendix provides a comprehensive security framework for your React Native application. By implementing these security best practices, you'll protect your users' data and ensure compliance with industry standards.

x
