# Appendix N: Offline-First Architecture Deep Dive

Welcome to Appendix N! This comprehensive guide covers everything you need to know about building offline-first applications with React Native. You'll learn how to design systems that work seamlessly without internet connectivity, sync data intelligently, and provide a smooth user experience in any network condition.

---

## Table of Contents

1. [Offline-First Principles](#offline-first-principles)
2. [Local Database Strategies](#local-database-strategies)
3. [Sync Engine Architecture](#sync-engine-architecture)
4. [Conflict Resolution](#conflict-resolution)
5. [Optimistic UI Updates](#optimistic-ui-updates)
6. [Background Sync](#background-sync)
7. [Network Detection & Queue Management](#network-detection--queue-management)
8. [Offline-First Testing](#offline-first-testing)

---

## Offline-First Principles

### Core Offline-First Architecture

```typescript
// src/offline/architecture.ts
/**
 * Offline-First Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     USER INTERFACE                             │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Optimistic UI Updates  │  Loading States  │  Error    │   │
 * │  │  (Immediate Feedback)   │  (Skeleton)      │  Recovery │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     LOCAL DATA LAYER                           │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  SQLite DB  │  MMKV  │  AsyncStorage  │  Redux Persist│   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                      SYNC ENGINE                               │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  Conflict Resolution  │  Queue Manager  │  Replay      │   │
 * │  │  (CRDT/OT)            │  (Priority)     │  (Retry)     │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 *                              │
 *                              ▼
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                     NETWORK LAYER                              │
 * │  ┌─────────────────────────────────────────────────────────┐   │
 * │  │  HTTP Client  │  WebSocket  │  Background Fetch        │   │
 * │  │  (Retry)      │  (Realtime) │  (iOS/Android)           │   │
 * │  └─────────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────────┘
 */

export const OfflineFirstPrinciples = {
  // 1. Local First
  localFirst: {
    description: 'Always read from and write to local storage first',
    implementation: 'All CRUD operations go to local DB before network',
    benefits: [
      'Instant UI updates',
      'No network dependency',
      'Data availability at all times',
    ],
  },

  // 2. Conflict-Free Data Types
  conflictFree: {
    description: 'Use data types that naturally merge without conflicts',
    implementation: 'CRDTs (Conflict-free Replicated Data Types)',
    examples: [
      'Last Write Wins (LWW)',
      'Multi-value Register',
      'Observed-Removed Set',
    ],
  },

  // 3. Sync Later
  syncLater: {
    description: 'Sync with server when connectivity is available',
    implementation: 'Queue-based sync with exponential backoff',
    benefits: [
      'No blocking operations',
      'Automatic retry',
      'Network efficiency',
    ],
  },

  // 4. Optimistic UI
  optimisticUI: {
    description: 'Update UI immediately, rollback on sync failure',
    implementation: 'Temporary IDs and undo stacks',
    benefits: [
      'Responsive feel',
      'User confidence',
      'Better UX',
    ],
  },
};
```

---

## Local Database Strategies

### Unified Local Storage Layer

```typescript
// src/offline/LocalStorage.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as SQLite from 'expo-sqlite';
import { MMKV } from 'react-native-mmkv';

/**
 * Local Storage Strategies
 * 
 * This provides a unified interface for local storage:
 * - SQLite for relational data
 * - MMKV for fast key-value
 * - AsyncStorage for simple data
 * - IndexedDB for large datasets
 */

export interface StorageAdapter {
  get<T>(key: string): Promise<T | null>;
  set<T>(key: string, value: T): Promise<void>;
  delete(key: string): Promise<void>;
  clear(): Promise<void>;
  getAllKeys(): Promise<string[]>;
  batch?(operations: Array<{ type: 'set' | 'delete'; key: string; value?: any }>): Promise<void>;
}

// SQLite Adapter for complex relational data
export class SQLiteAdapter implements StorageAdapter {
  private db: SQLite.SQLiteDatabase;

  constructor(dbName: string) {
    this.db = SQLite.openDatabaseSync(dbName);
  }

  async get<T>(key: string): Promise<T | null> {
    try {
      const result = await this.db.execSync(
        'SELECT * FROM storage WHERE key = ?',
        [key]
      );
      return result.length > 0 ? JSON.parse(result[0].value) : null;
    } catch (error) {
      console.error('SQLite get error:', error);
      return null;
    }
  }

  async set<T>(key: string, value: T): Promise<void> {
    try {
      await this.db.execSync(
        'INSERT OR REPLACE INTO storage (key, value, updated_at) VALUES (?, ?, ?)',
        [key, JSON.stringify(value), new Date().toISOString()]
      );
    } catch (error) {
      console.error('SQLite set error:', error);
      throw error;
    }
  }

  async delete(key: string): Promise<void> {
    await this.db.execSync('DELETE FROM storage WHERE key = ?', [key]);
  }

  async clear(): Promise<void> {
    await this.db.execSync('DELETE FROM storage');
  }

  async getAllKeys(): Promise<string[]> {
    const result = await this.db.execSync('SELECT key FROM storage');
    return result.map(row => row.key);
  }

  async batch(operations: Array<{ type: 'set' | 'delete'; key: string; value?: any }>): Promise<void> {
    const db = this.db;
    await db.execAsync('BEGIN TRANSACTION');
    try {
      for (const op of operations) {
        if (op.type === 'set') {
          await db.execSync(
            'INSERT OR REPLACE INTO storage (key, value, updated_at) VALUES (?, ?, ?)',
            [op.key, JSON.stringify(op.value), new Date().toISOString()]
          );
        } else {
          await db.execSync('DELETE FROM storage WHERE key = ?', [op.key]);
        }
      }
      await db.execAsync('COMMIT');
    } catch (error) {
      await db.execAsync('ROLLBACK');
      throw error;
    }
  }
}

// MMKV Adapter for fast key-value storage
export class MMKVAdapter implements StorageAdapter {
  private mmkv: MMKV;

  constructor(id: string) {
    this.mmkv = new MMKV({ id });
  }

  async get<T>(key: string): Promise<T | null> {
    try {
      const value = this.mmkv.getString(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('MMKV get error:', error);
      return null;
    }
  }

  async set<T>(key: string, value: T): Promise<void> {
    this.mmkv.set(key, JSON.stringify(value));
  }

  async delete(key: string): Promise<void> {
    this.mmkv.delete(key);
  }

  async clear(): Promise<void> {
    this.mmkv.clearAll();
  }

  async getAllKeys(): Promise<string[]> {
    return this.mmkv.getAllKeys();
  }
}

// AsyncStorage Adapter for simple data
export class AsyncStorageAdapter implements StorageAdapter {
  async get<T>(key: string): Promise<T | null> {
    try {
      const value = await AsyncStorage.getItem(key);
      return value ? JSON.parse(value) : null;
    } catch (error) {
      console.error('AsyncStorage get error:', error);
      return null;
    }
  }

  async set<T>(key: string, value: T): Promise<void> {
    await AsyncStorage.setItem(key, JSON.stringify(value));
  }

  async delete(key: string): Promise<void> {
    await AsyncStorage.removeItem(key);
  }

  async clear(): Promise<void> {
    await AsyncStorage.clear();
  }

  async getAllKeys(): Promise<string[]> {
    return AsyncStorage.getAllKeys();
  }

  async batch(operations: Array<{ type: 'set' | 'delete'; key: string; value?: any }>): Promise<void> {
    const pairs: any[] = [];
    const keysToRemove: string[] = [];

    for (const op of operations) {
      if (op.type === 'set') {
        pairs.push([op.key, JSON.stringify(op.value)]);
      } else {
        keysToRemove.push(op.key);
      }
    }

    if (pairs.length > 0) {
      await AsyncStorage.multiSet(pairs);
    }

    if (keysToRemove.length > 0) {
      await AsyncStorage.multiRemove(keysToRemove);
    }
  }
}

// Unified Storage Manager
export class StorageManager {
  private static instance: StorageManager;
  private adapters: Map<string, StorageAdapter> = new Map();
  private defaultAdapter: string = 'mmkv';

  private constructor() {
    // Initialize adapters
    this.adapters.set('sqlite', new SQLiteAdapter('taskflow.db'));
    this.adapters.set('mmkv', new MMKVAdapter('app-storage'));
    this.adapters.set('async', new AsyncStorageAdapter());
  }

  static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }

  getAdapter(name?: string): StorageAdapter {
    return this.adapters.get(name || this.defaultAdapter)!;
  }

  async get<T>(key: string, adapter?: string): Promise<T | null> {
    return this.getAdapter(adapter).get<T>(key);
  }

  async set<T>(key: string, value: T, adapter?: string): Promise<void> {
    return this.getAdapter(adapter).set(key, value);
  }

  async delete(key: string, adapter?: string): Promise<void> {
    return this.getAdapter(adapter).delete(key);
  }

  async clear(adapter?: string): Promise<void> {
    return this.getAdapter(adapter).clear();
  }

  async batch(operations: Array<{ type: 'set' | 'delete'; key: string; value?: any }>, adapter?: string): Promise<void> {
    const storage = this.getAdapter(adapter);
    if (storage.batch) {
      return storage.batch(operations);
    }
    // Fallback to individual operations
    for (const op of operations) {
      if (op.type === 'set') {
        await storage.set(op.key, op.value);
      } else {
        await storage.delete(op.key);
      }
    }
  }

  setDefaultAdapter(adapter: string): void {
    if (this.adapters.has(adapter)) {
      this.defaultAdapter = adapter;
    }
  }
}

export const storage = StorageManager.getInstance();
```

---

## Sync Engine Architecture

### Complete Sync Engine

```typescript
// src/offline/SyncEngine.ts
import { storage } from './LocalStorage';
import { NetInfo } from '@react-native-community/netinfo';
import { EventEmitter } from 'events';

/**
 * Sync Engine
 * 
 * This provides a complete sync engine with:
 * - Priority-based queuing
 * - Exponential backoff retry
 * - Conflict resolution
 * - Real-time sync
 * - Background sync
 */

export interface SyncOperation {
  id: string;
  type: 'create' | 'update' | 'delete';
  entity: string;
  data: any;
  timestamp: number;
  priority: 'high' | 'medium' | 'low';
  retries: number;
  maxRetries: number;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  error?: string;
}

export interface SyncConfig {
  batchSize: number;
  retryDelay: number;
  maxRetries: number;
  syncInterval: number;
  priorityThresholds: {
    high: number;
    medium: number;
    low: number;
  };
}

export class SyncEngine extends EventEmitter {
  private static instance: SyncEngine;
  private queue: SyncOperation[] = [];
  private isSyncing: boolean = false;
  private isOnline: boolean = true;
  private syncInterval: NodeJS.Timeout | null = null;
  private config: SyncConfig = {
    batchSize: 20,
    retryDelay: 1000,
    maxRetries: 5,
    syncInterval: 30000,
    priorityThresholds: {
      high: 100,
      medium: 50,
      low: 0,
    },
  };

  private constructor() {
    super();
    this.setupNetworkListener();
    this.loadQueue();
    this.startPeriodicSync();
  }

  static getInstance(): SyncEngine {
    if (!SyncEngine.instance) {
      SyncEngine.instance = new SyncEngine();
    }
    return SyncEngine.instance;
  }

  /**
   * Setup network listener
   */
  private setupNetworkListener() {
    NetInfo.addEventListener((state) => {
      const wasOnline = this.isOnline;
      this.isOnline = state.isConnected ?? false;

      if (!wasOnline && this.isOnline) {
        // Came back online - sync immediately
        console.log('📡 Back online - syncing...');
        this.sync();
      }
    });
  }

  /**
   * Load queue from storage
   */
  private async loadQueue() {
    try {
      const data = await storage.get<SyncOperation[]>('sync_queue');
      if (data) {
        this.queue = data.filter(op => op.status === 'pending' || op.status === 'failed');
      }
    } catch (error) {
      console.error('Failed to load sync queue:', error);
    }
  }

  /**
   * Save queue to storage
   */
  private async saveQueue() {
    try {
      await storage.set('sync_queue', this.queue);
    } catch (error) {
      console.error('Failed to save sync queue:', error);
    }
  }

  /**
   * Start periodic sync
   */
  private startPeriodicSync() {
    this.syncInterval = setInterval(() => {
      if (this.isOnline && this.queue.length > 0) {
        this.sync();
      }
    }, this.config.syncInterval);
  }

  /**
   * Enqueue operation
   */
  enqueue(type: SyncOperation['type'], entity: string, data: any, priority: 'high' | 'medium' | 'low' = 'medium'): string {
    const operation: SyncOperation = {
      id: `op-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
      type,
      entity,
      data,
      timestamp: Date.now(),
      priority,
      retries: 0,
      maxRetries: this.config.maxRetries,
      status: 'pending',
    };

    // Insert at appropriate position based on priority
    const threshold = this.config.priorityThresholds[priority];
    let insertIndex = this.queue.length;

    for (let i = 0; i < this.queue.length; i++) {
      const opPriority = this.queue[i].priority;
      const opThreshold = this.config.priorityThresholds[opPriority];
      if (opThreshold < threshold) {
        insertIndex = i;
        break;
      }
    }

    this.queue.splice(insertIndex, 0, operation);
    this.saveQueue();

    // Emit event
    this.emit('enqueued', operation);

    // Start sync if online
    if (this.isOnline) {
      this.sync();
    }

    return operation.id;
  }

  /**
   * Sync operations
   */
  async sync(): Promise<void> {
    if (!this.isOnline || this.isSyncing || this.queue.length === 0) {
      return;
    }

    this.isSyncing = true;
    this.emit('syncStarted');

    try {
      // Get pending operations
      const pendingOps = this.queue.filter(op => op.status === 'pending' || op.status === 'failed');
      const batch = pendingOps.slice(0, this.config.batchSize);

      for (const operation of batch) {
        try {
          await this.processOperation(operation);
          operation.status = 'completed';
          this.emit('operationCompleted', operation);
        } catch (error) {
          operation.retries++;
          operation.status = 'failed';
          operation.error = error.message;

          // Check if max retries exceeded
          if (operation.retries >= operation.maxRetries) {
            this.emit('operationFailed', operation);
            // Notify for manual intervention
          } else {
            // Requeue with delay
            setTimeout(() => {
              operation.status = 'pending';
              this.saveQueue();
              this.emit('operationRetry', operation);
            }, this.config.retryDelay * Math.pow(2, operation.retries));
          }
        }

        // Save queue after each operation
        await this.saveQueue();
      }

      this.emit('syncCompleted');
    } catch (error) {
      console.error('Sync error:', error);
      this.emit('syncError', error);
    } finally {
      this.isSyncing = false;

      // Check if more operations to sync
      const remaining = this.queue.filter(op => op.status === 'pending' || op.status === 'failed');
      if (remaining.length > 0 && this.isOnline) {
        // Continue syncing
        this.sync();
      }
    }
  }

  /**
   * Process a single operation
   */
  private async processOperation(operation: SyncOperation): Promise<void> {
    switch (operation.type) {
      case 'create':
        await this.handleCreate(operation);
        break;
      case 'update':
        await this.handleUpdate(operation);
        break;
      case 'delete':
        await this.handleDelete(operation);
        break;
      default:
        throw new Error(`Unknown operation type: ${operation.type}`);
    }
  }

  /**
   * Handle create operation
   */
  private async handleCreate(operation: SyncOperation): Promise<void> {
    // In production, send POST to API
    console.log(`📤 Creating ${operation.entity}:`, operation.data);
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 500));

    // Update local data with server response
    // const response = await api.create(operation.entity, operation.data);
    // await storage.set(`${operation.entity}_${response.id}`, response);
  }

  /**
   * Handle update operation
   */
  private async handleUpdate(operation: SyncOperation): Promise<void> {
    console.log(`📤 Updating ${operation.entity}:`, operation.data);
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 500));

    // Conflict resolution would happen here
    // const response = await api.update(operation.entity, operation.data.id, operation.data);
    // await storage.set(`${operation.entity}_${response.id}`, response);
  }

  /**
   * Handle delete operation
   */
  private async handleDelete(operation: SyncOperation): Promise<void> {
    console.log(`📤 Deleting ${operation.entity}:`, operation.data);
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 500));
    // const response = await api.delete(operation.entity, operation.data.id);
    // await storage.delete(`${operation.entity}_${operation.data.id}`);
  }

  /**
   * Get sync status
   */
  getSyncStatus(): {
    pending: number;
    processing: number;
    completed: number;
    failed: number;
    isSyncing: boolean;
    isOnline: boolean;
  } {
    const stats = { pending: 0, processing: 0, completed: 0, failed: 0 };
    this.queue.forEach(op => {
      stats[op.status as keyof typeof stats]++;
    });

    return {
      ...stats,
      isSyncing: this.isSyncing,
      isOnline: this.isOnline,
    };
  }

  /**
   * Get pending operations
   */
  getPendingOperations(): SyncOperation[] {
    return this.queue.filter(op => op.status === 'pending' || op.status === 'failed');
  }

  /**
   * Clear completed operations
   */
  async clearCompleted(): Promise<void> {
    this.queue = this.queue.filter(op => op.status !== 'completed');
    await this.saveQueue();
  }

  /**
   * Retry failed operations
   */
  async retryFailed(): Promise<void> {
    this.queue.forEach(op => {
      if (op.status === 'failed') {
        op.status = 'pending';
        op.retries = 0;
      }
    });
    await this.saveQueue();
    this.sync();
  }

  /**
   * Cancel an operation
   */
  async cancelOperation(id: string): Promise<void> {
    this.queue = this.queue.filter(op => op.id !== id);
    await this.saveQueue();
  }

  /**
   * Clean up
   */
  cleanup(): void {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
    }
  }
}

export const syncEngine = SyncEngine.getInstance();
```

---

## Conflict Resolution

### Conflict Resolution Strategies

```typescript
// src/offline/ConflictResolver.ts
/**
 * Conflict Resolution
 * 
 * This provides comprehensive conflict resolution strategies:
 * - Last Write Wins (LWW)
 * - Merge strategies
 * - Manual resolution
 * - Version vectors
 * - Custom resolvers
 */

export interface Conflict<T = any> {
  id: string;
  local: T;
  remote: T;
  localVersion: number;
  remoteVersion: number;
  timestamp: number;
}

export interface ConflictResolution<T = any> {
  resolved: T;
  strategy: string;
  details: string;
  conflicts: boolean;
}

export class ConflictResolver {
  private static instance: ConflictResolver;
  private resolvers: Map<string, (conflict: Conflict) => ConflictResolution> = new Map();

  private constructor() {
    this.registerDefaultResolvers();
  }

  static getInstance(): ConflictResolver {
    if (!ConflictResolver.instance) {
      ConflictResolver.instance = new ConflictResolver();
    }
    return ConflictResolver.instance;
  }

  /**
   * Register default resolvers
   */
  private registerDefaultResolvers() {
    // Last Write Wins
    this.registerResolver('lww', (conflict) => {
      const resolved = conflict.localVersion > conflict.remoteVersion ? conflict.local : conflict.remote;
      return {
        resolved,
        strategy: 'Last Write Wins',
        details: `Local version ${conflict.localVersion} vs Remote ${conflict.remoteVersion}`,
        conflicts: false,
      };
    });

    // Merge strategy for tasks
    this.registerResolver('task_merge', (conflict) => {
      const resolved = {
        ...conflict.remote,
        ...conflict.local,
        // Combine properties
        status: conflict.remote.status === 'done' ? 'done' : conflict.local.status,
        priority: conflict.remote.priority !== conflict.local.priority ? 
          Math.max(conflict.remote.priority, conflict.local.priority) : 
          conflict.local.priority,
        // Merge tags
        tags: Array.from(new Set([...conflict.local.tags, ...conflict.remote.tags])),
        // Use latest updated_at
        updated_at: Math.max(conflict.local.updated_at, conflict.remote.updated_at),
      };
      return {
        resolved,
        strategy: 'Task Merge',
        details: 'Merged task properties',
        conflicts: false,
      };
    });

    // Manual resolution fallback
    this.registerResolver('manual', (conflict) => {
      return {
        resolved: null as any,
        strategy: 'Manual Resolution Required',
        details: 'User must resolve this conflict manually',
        conflicts: true,
      };
    });
  }

  /**
   * Register custom resolver
   */
  registerResolver(strategy: string, resolver: (conflict: Conflict) => ConflictResolution): void {
    this.resolvers.set(strategy, resolver);
  }

  /**
   * Resolve conflict
   */
  resolve<T>(conflict: Conflict<T>, strategy: string = 'lww'): ConflictResolution<T> {
    const resolver = this.resolvers.get(strategy);
    if (!resolver) {
      throw new Error(`No resolver found for strategy: ${strategy}`);
    }
    return resolver(conflict);
  }

  /**
   * Detect conflicts between local and remote data
   */
  detectConflicts<T>(local: T, remote: T): Conflict<T> | null {
    // Check for version differences
    const localVersion = (local as any).version || 0;
    const remoteVersion = (remote as any).version || 0;

    // Check for data differences
    const localHash = this.hashData(local);
    const remoteHash = this.hashData(remote);

    if (localVersion !== remoteVersion && localHash !== remoteHash) {
      return {
        id: (local as any).id || (remote as any).id,
        local,
        remote,
        localVersion,
        remoteVersion,
        timestamp: Date.now(),
      };
    }

    return null;
  }

  /**
   * Hash data for comparison
   */
  private hashData(data: any): string {
    // Simple hash for comparison
    const json = JSON.stringify(data);
    let hash = 0;
    for (let i = 0; i < json.length; i++) {
      const char = json.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return hash.toString(36);
  }

  /**
   * Version vector for tracking changes
   */
  createVersionVector(entityId: string): {
    entityId: string;
    version: number;
    timestamp: number;
    changes: Array<{ field: string; value: any }>;
  } {
    return {
      entityId,
      version: Date.now(),
      timestamp: Date.now(),
      changes: [],
    };
  }

  /**
   * Update version vector
   */
  updateVersionVector(
    vector: ReturnType<ConflictResolver['createVersionVector']>,
    changes: Array<{ field: string; value: any }>
  ): typeof vector {
    return {
      ...vector,
      version: Date.now(),
      timestamp: Date.now(),
      changes: [...vector.changes, ...changes],
    };
  }

  /**
   * Compare version vectors
   */
  compareVersionVectors(
    local: ReturnType<ConflictResolver['createVersionVector']>,
    remote: ReturnType<ConflictResolver['createVersionVector']>
  ): 'local' | 'remote' | 'conflict' {
    if (local.version === remote.version) return 'local';
    if (local.version > remote.version) return 'local';
    if (remote.version > local.version) return 'remote';
    return 'conflict';
  }
}

export const conflictResolver = ConflictResolver.getInstance();
```

---

## Optimistic UI Updates

### Optimistic UI Implementation

```typescript
// src/offline/OptimisticUI.ts
import { storage } from './LocalStorage';
import { syncEngine } from './SyncEngine';

/**
 * Optimistic UI Updates
 * 
 * This provides optimistic UI update capabilities:
 * - Instant UI updates
 * - Rollback on failure
 * - Temporary IDs
 * - Pending state management
 */

export interface OptimisticOperation<T = any> {
  id: string;
  type: 'create' | 'update' | 'delete';
  entity: string;
  data: T;
  optimisticData: T;
  originalData?: T;
  timestamp: number;
  status: 'pending' | 'committed' | 'rolledback';
  syncOperationId?: string;
}

export class OptimisticUIManager {
  private static instance: OptimisticUIManager;
  private pendingOperations: Map<string, OptimisticOperation> = new Map();
  private rollbackCallbacks: Map<string, (data: any) => void> = new Map();

  private constructor() {
    // Listen for sync events
    syncEngine.on('operationCompleted', this.handleSyncComplete.bind(this));
    syncEngine.on('operationFailed', this.handleSyncFailed.bind(this));
  }

  static getInstance(): OptimisticUIManager {
    if (!OptimisticUIManager.instance) {
      OptimisticUIManager.instance = new OptimisticUIManager();
    }
    return OptimisticUIManager.instance;
  }

  /**
   * Perform optimistic operation
   */
  async optimisticOperation<T>(
    type: OptimisticOperation['type'],
    entity: string,
    data: T,
    updateUI: (data: T) => void,
    rollback: () => void
  ): Promise<void> {
    const operationId = `opt-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;

    // Create operation
    const operation: OptimisticOperation<T> = {
      id: operationId,
      type,
      entity,
      data,
      optimisticData: data,
      timestamp: Date.now(),
      status: 'pending',
    };

    // Store original data for rollback
    const originalData = await storage.get(`${entity}_${data.id}`);
    if (originalData) {
      operation.originalData = originalData;
    }

    // Store operation
    this.pendingOperations.set(operationId, operation);

    // Register rollback
    this.rollbackCallbacks.set(operationId, rollback);

    // Update UI optimistically
    updateUI(data);

    // Update local storage
    await this.updateLocalStorage(operation);

    // Enqueue sync operation
    const syncId = syncEngine.enqueue(type, entity, data, 'high');
    operation.syncOperationId = syncId;

    // Save operation
    await this.saveOperations();

    // Clean up if sync completes immediately
    if (syncEngine.isOnline && syncEngine.getPendingOperations().length === 0) {
      await this.commitOperation(operationId);
    }
  }

  /**
   * Update local storage
   */
  private async updateLocalStorage(operation: OptimisticOperation): Promise<void> {
    const { type, entity, data } = operation;

    switch (type) {
      case 'create':
        await storage.set(`${entity}_${data.id}`, data);
        break;
      case 'update':
        await storage.set(`${entity}_${data.id}`, data);
        break;
      case 'delete':
        await storage.delete(`${entity}_${data.id}`);
        break;
    }
  }

  /**
   * Handle sync complete
   */
  private async handleSyncComplete(operation: any): Promise<void> {
    // Find matching optimistic operation
    for (const [id, optOp] of this.pendingOperations) {
      if (optOp.syncOperationId === operation.id) {
        await this.commitOperation(id);
        break;
      }
    }
  }

  /**
   * Handle sync failed
   */
  private async handleSyncFailed(operation: any): Promise<void> {
    // Find matching optimistic operation
    for (const [id, optOp] of this.pendingOperations) {
      if (optOp.syncOperationId === operation.id) {
        await this.rollbackOperation(id);
        break;
      }
    }
  }

  /**
   * Commit operation
   */
  private async commitOperation(id: string): Promise<void> {
    const operation = this.pendingOperations.get(id);
    if (!operation) return;

    operation.status = 'committed';
    await this.saveOperations();

    // Clear rollback callback
    this.rollbackCallbacks.delete(id);

    // Clean up after delay
    setTimeout(() => {
      this.pendingOperations.delete(id);
    }, 60000);

    console.log(`✅ Optimistic operation committed: ${id}`);
  }

  /**
   * Rollback operation
   */
  private async rollbackOperation(id: string): Promise<void> {
    const operation = this.pendingOperations.get(id);
    if (!operation) return;

    operation.status = 'rolledback';
    await this.saveOperations();

    // Restore original data
    if (operation.originalData) {
      await storage.set(`${operation.entity}_${operation.data.id}`, operation.originalData);
    } else if (operation.type === 'create') {
      await storage.delete(`${operation.entity}_${operation.data.id}`);
    }

    // Execute rollback callback
    const rollback = this.rollbackCallbacks.get(id);
    if (rollback) {
      rollback();
    }

    // Clean up
    this.rollbackCallbacks.delete(id);
    this.pendingOperations.delete(id);

    console.log(`↩️ Optimistic operation rolled back: ${id}`);
  }

  /**
   * Save operations
   */
  private async saveOperations(): Promise<void> {
    const operations = Array.from(this.pendingOperations.values());
    await storage.set('optimistic_operations', operations);
  }

  /**
   * Load operations
   */
  async loadOperations(): Promise<void> {
    const operations = await storage.get<OptimisticOperation[]>('optimistic_operations');
    if (operations) {
      operations.forEach(op => {
        this.pendingOperations.set(op.id, op);
      });
    }
  }

  /**
   * Get pending operations
   */
  getPendingOperations(): OptimisticOperation[] {
    return Array.from(this.pendingOperations.values()).filter(op => op.status === 'pending');
  }

  /**
   * Get operation by ID
   */
  getOperation(id: string): OptimisticOperation | undefined {
    return this.pendingOperations.get(id);
  }

  /**
   * Clean up
   */
  cleanup(): void {
    this.pendingOperations.clear();
    this.rollbackCallbacks.clear();
  }
}

export const optimisticUI = OptimisticUIManager.getInstance();
```

---

## Quick Reference: Offline Commands

```bash
# Offline commands
npm run offline:status       # Check offline status
npm run offline:sync         # Force sync
npm run offline:queue        # View sync queue
npm run offline:clear        # Clear sync queue
npm run offline:retry        # Retry failed operations

# Database commands
npm run db:init              # Initialize local database
npm run db:reset             # Reset local database
npm run db:backup            # Backup local database
npm run db:stats             # Show database statistics
```

---

This appendix provides a comprehensive offline-first architecture for your React Native application. By implementing these patterns, you'll create apps that work seamlessly in any network condition and provide a smooth, responsive user experience.

