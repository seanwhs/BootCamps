# Primer 5: Offline-First Development with WatermelonDB

## Your Complete Guide to Local Database Management

Welcome to the WatermelonDB Primer! This guide covers everything you need to know about building offline-first applications using WatermelonDB, a high-performance reactive database for React Native. In the real world, users don't always have internet connectivity—your app needs to work offline and sync automatically when connectivity returns.

---

## W.1 Why Offline-First?

### The Concept: Apps That Work Anywhere

Offline-first means your app works perfectly even without an internet connection. Users can create, edit, and delete data offline, and the app automatically syncs when connectivity is restored.

**Simple Analogy:** Think of offline-first apps like a field notebook. You can write notes anywhere, even without internet. When you get back to your desk with Wi-Fi, you copy everything into your computer system. The notebook always works, and the sync is automatic.

### Why WatermelonDB?

| Feature | WatermelonDB | SQLite | Realm | AsyncStorage |
|---------|--------------|--------|-------|--------------|
| Performance | ⚡ Excellent | Good | Good | Slow |
| Reactive | ✅ Built-in | ❌ Manual | ✅ Built-in | ❌ No |
| Sync Engine | ✅ Built-in | ❌ Manual | ✅ Built-in | ❌ No |
| TypeScript | ✅ Full support | Limited | ✅ Good | ❌ No |
| Size | Small | Small | Large | Tiny |
| Complexity | Moderate | Low | High | Very Low |

---

## W.2 Getting Started

### The Concept: Setting Up Your Database

Before you can use WatermelonDB, you need to set up the database, define your schema, and create models.

### Complete Setup Guide

```bash
# 1. Install WatermelonDB
npm install @nozbe/watermelondb
npm install @nozbe/with-observables

# 2. Install SQLite adapter
npm install expo-sqlite

# 3. Install dev tools
npm install -D @nozbe/watermelondb-devtools

# 4. Install Reanimated (for reactive features)
npm install react-native-reanimated

# 5. iOS: Install pods
cd ios && pod install && cd ..
```

### Basic Setup

```typescript
// 1. Define Your Schema
// database/schema.ts
import { appSchema, tableSchema } from '@nozbe/watermelondb';

export const schema = appSchema({
  version: 1,
  tables: [
    // Users table
    tableSchema({
      name: 'users',
      columns: [
        { name: 'email', type: 'string' },
        { name: 'full_name', type: 'string' },
        { name: 'avatar_url', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
      ],
    }),
    
    // Forms table
    tableSchema({
      name: 'forms',
      columns: [
        { name: 'title', type: 'string' },
        { name: 'description', type: 'string', isOptional: true },
        { name: 'fields', type: 'string' }, // JSON string
        { name: 'user_id', type: 'string' },
        { name: 'is_public', type: 'boolean' },
        { name: 'is_template', type: 'boolean' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'sync_status', type: 'string' },
        { name: 'is_deleted', type: 'boolean' },
      ],
    }),
    
    // Collections (entries) table
    tableSchema({
      name: 'collections',
      columns: [
        { name: 'form_id', type: 'string' },
        { name: 'user_id', type: 'string' },
        { name: 'data', type: 'string' }, // JSON string
        { name: 'location_lat', type: 'number', isOptional: true },
        { name: 'location_lng', type: 'number', isOptional: true },
        { name: 'photos', type: 'string', isOptional: true },
        { name: 'status', type: 'string' },
        { name: 'synced_at', type: 'number', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'sync_status', type: 'string' },
        { name: 'is_deleted', type: 'boolean' },
      ],
    }),
  ],
});

// 2. Create Database Models
// database/models/User.ts
import { Model } from '@nozbe/watermelondb';
import { field, text, date, readonly } from '@nozbe/watermelondb/decorators';

export default class User extends Model {
  static table = 'users';
  
  @text('email') email!: string;
  @text('full_name') fullName!: string;
  @text('avatar_url') avatarUrl?: string;
  @readonly @date('created_at') createdAt!: number;
  @readonly @date('updated_at') updatedAt!: number;
  
  // Helper methods
  toJSON() {
    return {
      id: this.id,
      email: this.email,
      fullName: this.fullName,
      avatarUrl: this.avatarUrl,
      createdAt: new Date(this.createdAt),
      updatedAt: new Date(this.updatedAt),
    };
  }
}

// 3. Initialize Database
// database/index.ts
import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import { schema } from './schema';
import User from './models/User';
import Form from './models/Form';
import Collection from './models/Collection';

// Define model classes
const models = [User, Form, Collection];

// Create adapter
const adapter = new SQLiteAdapter({
  schema,
  dbName: 'NexusCollectDB',
  // Enable encryption (optional)
  // encryptionKey: 'your-encryption-key',
});

// Create database
export const database = new Database({
  adapter,
  modelClasses: models,
  actionsEnabled: true,
});

// 4. Use Database in App
// App.tsx
import React, { useEffect } from 'react';
import { database } from '@database';

export default function App() {
  useEffect(() => {
    // Database is ready
    console.log('Database initialized');
  }, []);

  return (
    // Your app
  );
}
```

---

## W.3 CRUD Operations

### The Concept: Create, Read, Update, Delete

CRUD operations are the foundation of any data-driven app. WatermelonDB provides a clean API for all four operations.

### Complete CRUD Guide

```typescript
// 1. Creating Records
import { database } from '@database';
import User from '@database/models/User';

async function createUser(name: string, email: string) {
  await database.write(async () => {
    const user = await database
      .get<User>('users')
      .create((record) => {
        record.fullName = name;
        record.email = email;
        record.createdAt = Date.now();
        record.updatedAt = Date.now();
      });
    
    console.log('User created:', user.id);
    return user;
  });
}

// 2. Reading Records
async function getUsers() {
  const users = await database
    .get<User>('users')
    .query()
    .fetch();
  
  return users;
}

// Query with conditions
async function getActiveUsers() {
  const users = await database
    .get<User>('users')
    .query(
      Q.where('is_active', true),
      Q.sortBy('full_name', Q.asc)
    )
    .fetch();
  
  return users;
}

// 3. Updating Records
async function updateUser(id: string, name: string) {
  await database.write(async () => {
    const user = await database
      .get<User>('users')
      .find(id);
    
    await user.update((record) => {
      record.fullName = name;
      record.updatedAt = Date.now();
    });
  });
}

// 4. Deleting Records
async function deleteUser(id: string) {
  await database.write(async () => {
    const user = await database
      .get<User>('users')
      .find(id);
    
    await user.destroyPermanently();
  });
}

// 5. Soft Delete
async function softDeleteUser(id: string) {
  await database.write(async () => {
    const user = await database
      .get<User>('users')
      .find(id);
    
    await user.update((record) => {
      record.isDeleted = true;
      record.deletedAt = Date.now();
    });
  });
}

// 6. Batch Operations
async function batchCreateUsers(users: UserData[]) {
  await database.write(async () => {
    const userCollection = database.get<User>('users');
    
    // Create all users in a single transaction
    const records = users.map((data) =>
      userCollection.create((record) => {
        record.fullName = data.name;
        record.email = data.email;
        record.createdAt = Date.now();
        record.updatedAt = Date.now();
      })
    );
    
    await Promise.all(records);
  });
}
```

---

## W.4 Reactive Queries

### The Concept: UI That Updates Automatically

Reactive queries automatically update your UI when data changes. This is one of WatermelonDB's most powerful features.

### Complete Reactive Guide

```typescript
// 1. Basic Reactive Query
import { useDatabase } from '@nozbe/watermelondb/react';
import { useObservable } from '@nozbe/watermelondb/react';
import { switchMap } from 'rxjs/operators';

function UserList() {
  const database = useDatabase();
  
  // Subscribe to users and update automatically
  const users = useObservable(
    database
      .get<User>('users')
      .query()
      .observe()
  );
  
  if (!users) return <Text>Loading...</Text>;
  
  return (
    <FlatList
      data={users}
      renderItem={({ item }) => <Text>{item.fullName}</Text>}
    />
  );
}

// 2. Reactive with Conditions
function ActiveUserList() {
  const database = useDatabase();
  
  const users = useObservable(
    database
      .get<User>('users')
      .query(
        Q.where('is_active', true),
        Q.sortBy('full_name', Q.asc)
      )
      .observe()
  );
  
  return (
    <FlatList
      data={users || []}
      renderItem={({ item }) => <UserCard user={item} />}
    />
  );
}

// 3. Reactive with Count
function UserCount() {
  const database = useDatabase();
  
  const count = useObservable(
    database
      .get<User>('users')
      .query()
      .observeCount()
  );
  
  return <Text>Total Users: {count || 0}</Text>;
}

// 4. Reactive Single Record
function UserDetail({ userId }: { userId: string }) {
  const database = useDatabase();
  
  const user = useObservable(
    database
      .get<User>('users')
      .findAndObserve(userId)
  );
  
  if (!user) return <Text>Loading...</Text>;
  
  return (
    <View>
      <Text>{user.fullName}</Text>
      <Text>{user.email}</Text>
    </View>
  );
}

// 5. Custom Reactive Hook
import { useDatabase } from '@nozbe/watermelondb/react';
import { useMemo } from 'react';
import { Observable } from 'rxjs';

function useQuery<T extends Model>(
  tableName: string,
  queryFn: (collection: Collection<T>) => Query<T>
) {
  const database = useDatabase();
  const collection = database.get<T>(tableName);
  const query = useMemo(
    () => queryFn(collection),
    [collection, queryFn]
  );
  
  const data = useObservable(query.observe());
  return data;
}

// Usage
function UserList() {
  const users = useQuery('users', (collection) =>
    collection.query(Q.where('is_active', true))
  );
  
  return (
    <FlatList
      data={users || []}
      renderItem={({ item }) => <UserCard user={item} />}
    />
  );
}
```

---

## W.5 Sync Engine

### The Concept: Automatic Data Synchronization

The sync engine handles the complex task of keeping your local database in sync with your backend.

### Complete Sync Guide

```typescript
// 1. Sync Configuration
// database/sync/syncEngine.ts
import { database } from '@database';
import { sync } from '@nozbe/watermelondb/sync';
import { supabase } from '@api/supabase';
import NetInfo from '@react-native-community/netinfo';

interface SyncContext {
  userId: string;
  lastSync: number;
}

export class SyncEngine {
  private isSyncing = false;
  private lastSync = 0;
  
  async sync(userId: string) {
    // Prevent concurrent syncs
    if (this.isSyncing) return;
    
    // Check network
    const { isConnected } = await NetInfo.fetch();
    if (!isConnected) {
      console.log('No network, skipping sync');
      return;
    }
    
    this.isSyncing = true;
    
    try {
      await sync({
        database,
        pullChanges: async ({ lastPulledAt }) => {
          // Fetch changes from server
          const { data, error } = await supabase
            .rpc('get_changes', {
              user_id: userId,
              last_pull: lastPulledAt || 0,
            });
          
          if (error) throw error;
          
          return {
            changes: data,
            timestamp: Date.now(),
          };
        },
        pushChanges: async ({ changes }) => {
          // Push local changes to server
          const { error } = await supabase
            .rpc('apply_changes', {
              changes,
              user_id: userId,
            });
          
          if (error) throw error;
        },
        migrationsEnabledAtVersion: 1,
      });
      
      this.lastSync = Date.now();
      console.log('Sync completed successfully');
    } catch (error) {
      console.error('Sync failed:', error);
      throw error;
    } finally {
      this.isSyncing = false;
    }
  }
}

// 2. Sync Queue Management
// database/sync/syncQueue.ts
import { database } from '@database';
import SyncQueue from '@database/models/SyncQueue';

export class SyncQueueManager {
  // Add item to sync queue
  static async enqueue(
    operation: 'create' | 'update' | 'delete',
    tableName: string,
    recordId: string,
    data: any
  ) {
    await database.write(async () => {
      await database
        .get<SyncQueue>('sync_queue')
        .create((record) => {
          record.operation = operation;
          record.tableName = tableName;
          record.recordId = recordId;
          record.data = data;
          record.status = 'pending';
          record.retryCount = 0;
          record.createdAt = Date.now();
          record.updatedAt = Date.now();
        });
    });
  }
  
  // Process pending items
  static async processPending() {
    const items = await database
      .get<SyncQueue>('sync_queue')
      .query(
        Q.where('status', 'pending'),
        Q.sortBy('created_at', Q.asc),
        Q.take(100) // Process in batches
      )
      .fetch();
    
    for (const item of items) {
      try {
        await SyncQueueManager.processItem(item);
        await SyncQueueManager.markCompleted(item.id);
      } catch (error) {
        await SyncQueueManager.markFailed(item.id, error.message);
      }
    }
  }
  
  // Process individual item
  static async processItem(item: SyncQueue) {
    switch (item.operation) {
      case 'create':
        // Send to server
        break;
      case 'update':
        // Send to server
        break;
      case 'delete':
        // Send to server
        break;
    }
  }
  
  // Mark as completed
  static async markCompleted(id: string) {
    await database.write(async () => {
      const item = await database
        .get<SyncQueue>('sync_queue')
        .find(id);
      
      await item.update((record) => {
        record.status = 'completed';
        record.processedAt = Date.now();
        record.updatedAt = Date.now();
      });
    });
  }
  
  // Mark as failed
  static async markFailed(id: string, error: string) {
    await database.write(async () => {
      const item = await database
        .get<SyncQueue>('sync_queue')
        .find(id);
      
      await item.update((record) => {
        record.status = 'failed';
        record.errorMessage = error;
        record.retryCount += 1;
        record.updatedAt = Date.now();
        
        // Schedule retry if max retries not reached
        if (record.retryCount < 5) {
          record.nextRetryAt = Date.now() + (2 ** record.retryCount) * 1000;
        }
      });
    });
  }
}

// 3. Auto-Sync Hook
import { useEffect } from 'react';
import { useAuth } from '@hooks/useAuth';
import { useAppState } from '@hooks/useAppState';
import { syncEngine } from '@database/sync/syncEngine';

export const useAutoSync = () => {
  const { user } = useAuth();
  const { isActive } = useAppState();
  
  useEffect(() => {
    if (isActive && user) {
      // Sync when app comes to foreground
      syncEngine.sync(user.id);
    }
  }, [isActive, user]);
  
  useEffect(() => {
    // Sync every 5 minutes when app is active
    const interval = setInterval(() => {
      if (isActive && user) {
        syncEngine.sync(user.id);
      }
    }, 5 * 60 * 1000);
    
    return () => clearInterval(interval);
  }, [isActive, user]);
};
```

---

## W.6 Repository Pattern

### The Concept: Clean Data Access

The Repository pattern provides a clean abstraction for data access, making your code more maintainable and testable.

### Complete Repository Guide

```typescript
// 1. Base Repository
// database/repositories/BaseRepository.ts
import { Model, Database } from '@nozbe/watermelondb';
import { database } from '@database';

export abstract class BaseRepository<T extends Model> {
  protected tableName: string;
  
  constructor(tableName: string) {
    this.tableName = tableName;
  }
  
  protected get collection() {
    return database.get<T>(this.tableName);
  }
  
  // Get all records
  async getAll(): Promise<T[]> {
    return this.collection.query().fetch();
  }
  
  // Get by ID
  async getById(id: string): Promise<T | null> {
    try {
      return await this.collection.find(id);
    } catch {
      return null;
    }
  }
  
  // Create record
  async create(data: any): Promise<T> {
    return database.write(async () => {
      return this.collection.create((record) => {
        Object.assign(record, data);
      });
    });
  }
  
  // Update record
  async update(id: string, data: any): Promise<T> {
    return database.write(async () => {
      const record = await this.collection.find(id);
      await record.update((r) => {
        Object.assign(r, data);
      });
      return record;
    });
  }
  
  // Delete record
  async delete(id: string): Promise<void> {
    return database.write(async () => {
      const record = await this.collection.find(id);
      await record.destroyPermanently();
    });
  }
}

// 2. User Repository
// database/repositories/UserRepository.ts
import { BaseRepository } from './BaseRepository';
import User from '@database/models/User';
import { Q } from '@nozbe/watermelondb';

export class UserRepository extends BaseRepository<User> {
  constructor() {
    super('users');
  }
  
  // Get user by email
  async getByEmail(email: string): Promise<User | null> {
    const users = await this.collection
      .query(Q.where('email', email))
      .fetch();
    
    return users[0] || null;
  }
  
  // Get active users
  async getActive(): Promise<User[]> {
    return this.collection
      .query(
        Q.where('is_active', true),
        Q.sortBy('full_name', Q.asc)
      )
      .fetch();
  }
  
  // Search users
  async search(query: string): Promise<User[]> {
    return this.collection
      .query(
        Q.where('full_name', Q.like(`%${query}%`))
      )
      .fetch();
  }
}

// 3. Form Repository
// database/repositories/FormRepository.ts
import { BaseRepository } from './BaseRepository';
import Form from '@database/models/Form';
import { Q } from '@nozbe/watermelondb';

export class FormRepository extends BaseRepository<Form> {
  constructor() {
    super('forms');
  }
  
  // Get forms by user
  async getByUser(userId: string): Promise<Form[]> {
    return this.collection
      .query(
        Q.where('user_id', userId),
        Q.where('is_deleted', false),
        Q.sortBy('updated_at', Q.desc)
      )
      .fetch();
  }
  
  // Get templates
  async getTemplates(): Promise<Form[]> {
    return this.collection
      .query(
        Q.where('is_template', true),
        Q.where('is_public', true),
        Q.where('is_deleted', false)
      )
      .fetch();
  }
  
  // Get forms by category
  async getByCategory(category: string): Promise<Form[]> {
    return this.collection
      .query(
        Q.where('category', category),
        Q.where('is_deleted', false)
      )
      .fetch();
  }
}

// 4. Collection Repository
// database/repositories/CollectionRepository.ts
import { BaseRepository } from './BaseRepository';
import Collection from '@database/models/Collection';
import { Q } from '@nozbe/watermelondb';

export class CollectionRepository extends BaseRepository<Collection> {
  constructor() {
    super('collections');
  }
  
  // Get collections by form
  async getByForm(formId: string): Promise<Collection[]> {
    return this.collection
      .query(
        Q.where('form_id', formId),
        Q.where('is_deleted', false),
        Q.sortBy('created_at', Q.desc)
      )
      .fetch();
  }
  
  // Get collections by status
  async getByStatus(status: string): Promise<Collection[]> {
    return this.collection
      .query(
        Q.where('status', status),
        Q.where('is_deleted', false)
      )
      .fetch();
  }
  
  // Get unsynced collections
  async getUnsynced(): Promise<Collection[]> {
    return this.collection
      .query(
        Q.where('sync_status', 'pending'),
        Q.where('is_deleted', false),
        Q.sortBy('created_at', Q.asc)
      )
      .fetch();
  }
}

// 5. Using Repositories
const userRepository = new UserRepository();
const formRepository = new FormRepository();
const collectionRepository = new CollectionRepository();

async function example() {
  // Create a user
  const user = await userRepository.create({
    fullName: 'John Doe',
    email: 'john@example.com',
    isActive: true,
  });
  
  // Create a form
  const form = await formRepository.create({
    title: 'My Form',
    fields: JSON.stringify([]),
    userId: user.id,
    isPublic: false,
  });
  
  // Create a collection entry
  const collection = await collectionRepository.create({
    formId: form.id,
    userId: user.id,
    data: JSON.stringify({ field1: 'value1' }),
    status: 'draft',
    syncStatus: 'pending',
  });
}
```

---

## W.7 Migration Guide

### The Concept: Evolving Your Database

As your app evolves, your database schema will need to change. Migrations handle these changes safely.

### Complete Migration Guide

```typescript
// 1. Define Migrations
// database/migrations.ts
import { schemaMigrations } from '@nozbe/watermelondb/Schema/migrations';

export const migrations = schemaMigrations({
  migrations: [
    {
      version: 2,
      up: async (schema) => {
        // Add 'phone_number' column to users table
        await schema.table('users', (table) => {
          table.string('phone_number').optional();
        });
      },
    },
    {
      version: 3,
      up: async (schema) => {
        // Add 'category' column to forms table
        await schema.table('forms', (table) => {
          table.string('category').optional();
        });
        
        // Create new table for tags
        await schema.createTable('tags', (table) => {
          table.string('name');
          table.string('user_id');
        });
      },
    },
    {
      version: 4,
      up: async (schema) => {
        // Rename column 'full_name' to 'name' in users
        // Not directly supported, need to create new column and copy data
        await schema.table('users', (table) => {
          table.string('name');
        });
        
        // Migrate data in the up function
        // This would be handled separately
      },
    },
  ],
});

// 2. Apply Migrations
// database/index.ts
import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import { schema } from './schema';
import { migrations } from './migrations';

const adapter = new SQLiteAdapter({
  schema,
  migrations,
  dbName: 'NexusCollectDB',
});

// 3. Data Migration Functions
// database/migrationUtils.ts
import { database } from '@database';
import { Q } from '@nozbe/watermelondb';

export class MigrationUtils {
  // Migrate users: add phone number
  static async migrateUsersPhoneNumber() {
    const users = await database
      .get('users')
      .query()
      .fetch();
    
    await database.write(async () => {
      for (const user of users) {
        // If phone doesn't exist, extract from metadata
        const phoneNumber = user.metadata?.phoneNumber;
        if (phoneNumber) {
          await user.update((record) => {
            record.phoneNumber = phoneNumber;
          });
        }
      }
    });
  }
  
  // Migrate forms: add category
  static async migrateFormsCategory() {
    const forms = await database
      .get('forms')
      .query()
      .fetch();
    
    await database.write(async () => {
      for (const form of forms) {
        // Default category based on title
        let category = 'General';
        if (form.title.includes('Survey')) category = 'Survey';
        if (form.title.includes('Inspection')) category = 'Inspection';
        if (form.title.includes('Feedback')) category = 'Feedback';
        
        await form.update((record) => {
          record.category = category;
        });
      }
    });
  }
}
```

---

## W.8 Performance Optimization

### The Concept: Keeping Your Database Fast

Optimize your database for the best performance on mobile devices.

### Complete Performance Guide

```typescript
// 1. Indexes for Faster Queries
// database/schema.ts
tableSchema({
  name: 'collections',
  columns: [
    { name: 'form_id', type: 'string', indexed: true },
    { name: 'user_id', type: 'string', indexed: true },
    { name: 'status', type: 'string', indexed: true },
    { name: 'created_at', type: 'number', indexed: true },
  ],
})

// 2. Batch Operations
// Bad: Individual writes
for (const item of items) {
  await database.write(async () => {
    await collection.create(record => { /* ... */ });
  });
}

// Good: Batch write
await database.write(async () => {
  for (const item of items) {
    await collection.create(record => { /* ... */ });
  }
});

// 3. Use Query Optimization
// Bad: Fetch all then filter
const all = await collection.query().fetch();
const filtered = all.filter(item => item.status === 'active');

// Good: Filter in query
const filtered = await collection
  .query(Q.where('status', 'active'))
  .fetch();

// 4. Use Observables for Reactivity
// Good: Reactive query only updates when data changes
const users = useObservable(
  database.get('users').query().observe()
);

// 5. Limit Query Results
const recent = await collection
  .query(
    Q.sortBy('created_at', Q.desc),
    Q.take(20) // Only get 20 most recent
  )
  .fetch();

// 6. Use Selectors for Specific Fields
// Instead of loading full objects, select only needed fields
const names = await database
  .get('users')
  .query()
  .select('id', 'full_name')
  .fetch();
```

---

## W.9 Common Patterns

### The Concept: Reusable Database Patterns

Common patterns for working with WatermelonDB.

### Complete Patterns Guide

```typescript
// 1. Caching Pattern
class CacheManager {
  private cache = new Map<string, any>();
  private ttl: number;
  
  constructor(ttlSeconds: number = 300) {
    this.ttl = ttlSeconds * 1000;
  }
  
  async get<T>(key: string, fetcher: () => Promise<T>): Promise<T> {
    if (this.cache.has(key)) {
      const { data, timestamp } = this.cache.get(key);
      if (Date.now() - timestamp < this.ttl) {
        return data;
      }
    }
    
    const data = await fetcher();
    this.cache.set(key, { data, timestamp: Date.now() });
    return data;
  }
  
  invalidate(key: string) {
    this.cache.delete(key);
  }
}

// 2. Observer Pattern
class ModelObserver<T extends Model> {
  private observers: Set<(data: T[]) => void> = new Set();
  private data: T[] = [];
  
  constructor(private collection: Collection<T>) {
    this.collection.query().observe().subscribe((data) => {
      this.data = data;
      this.notify();
    });
  }
  
  subscribe(callback: (data: T[]) => void) {
    this.observers.add(callback);
    callback(this.data);
    return () => this.observers.delete(callback);
  }
  
  private notify() {
    this.observers.forEach(callback => callback(this.data));
  }
}

// 3. Factory Pattern
class ModelFactory {
  static createUser(data: any) {
    return {
      fullName: data.fullName || '',
      email: data.email || '',
      isActive: true,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };
  }
  
  static createForm(data: any) {
    return {
      title: data.title || 'Untitled Form',
      description: data.description || '',
      fields: data.fields || [],
      isPublic: data.isPublic || false,
      isTemplate: data.isTemplate || false,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };
  }
  
  static createCollection(data: any) {
    return {
      formId: data.formId,
      userId: data.userId,
      data: data.data || {},
      status: data.status || 'draft',
      syncStatus: 'pending',
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };
  }
}
```

---

## W.10 Quick Reference

### WatermelonDB Commands

```bash
# Install
npm install @nozbe/watermelondb
npm install expo-sqlite

# iOS
cd ios && pod install && cd ..

# Dev Tools
npm install -D @nozbe/watermelondb-devtools
```

### Common Operations

```typescript
// 1. Get collection
const collection = database.get('table_name');

// 2. Query
const results = await collection.query(
  Q.where('field', 'value'),
  Q.sortBy('field', Q.asc)
).fetch();

// 3. Observe
const subscription = collection.query().observe().subscribe(data => {
  console.log(data);
});

// 4. Write
await database.write(async () => {
  await collection.create(record => {
    record.field = value;
  });
});

// 5. Update
await database.write(async () => {
  const record = await collection.find(id);
  await record.update(r => {
    r.field = value;
  });
});

// 6. Delete
await database.write(async () => {
  const record = await collection.find(id);
  await record.destroyPermanently();
});
```

---

**Ready to build offline-first apps? Let's dive into NexusCollect!**
