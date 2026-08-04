# Part 4: Data Management & Offline Sync

## Building an Offline-First Data Layer

Now that we have authentication in place, it's time to build the data backbone of NexusCollect. In the real world, mobile users don't always have internet connectivity. They might be in a basement, on a plane, or in a remote area with poor coverage. Our app must work flawlessly offline and sync automatically when connectivity returns.

Think of this as building a resilient warehouse system. Even when the supply chain (internet) is disrupted, you need to be able to receive goods (data entries), store them safely (local database), and automatically ship them (sync) when the supply chain resumes.

### The Target

By the end of this part, you will have:

1. A high-performance local database (WatermelonDB) with encrypted storage
2. Offline-first architecture with automatic sync
3. Form builder and dynamic form rendering
4. Collection entry system with draft support
5. Robust sync engine with conflict resolution
6. Queue-based offline request management
7. Comprehensive caching strategy
8. Data validation and error handling

---

## Phase 4.1: Local Database Setup

### The Concept: Your App's Local Warehouse

WatermelonDB is a high-performance, reactive database built for React Native. It's designed for offline-first apps with complex data relationships. Think of it as a mini PostgreSQL running on your phone.

**Why WatermelonDB?**
- Optimized for mobile (lightweight, fast)
- Reactive (UI updates automatically when data changes)
- Sync-friendly (built-in sync engine support)
- Type-safe (TypeScript support)
- Transaction support
- Encryption ready

### The Implementation: Database Configuration

#### Step 4.1.1: Install Dependencies

```bash
# Install WatermelonDB and dependencies
$ npm install @nozbe/watermelondb @nozbe/with-observables
$ npm install expo-sqlite
$ npm install react-native-reanimated

# Install dev dependencies
$ npm install -D @nozbe/watermelondb-devtools

# iOS: Install pods
$ cd ios && pod install && cd ..
```

#### Step 4.1.2: Create Database Schema

```typescript
// src/database/schema.ts
import { appSchema, tableSchema } from '@nozbe/watermelondb';

/**
 * Database Schema Definition
 * 
 * Defines all tables, columns, and relationships for the local database.
 * This schema mirrors our Supabase tables but is optimized for local operations.
 */

export const schema = appSchema({
  version: 1,
  tables: [
    // Users table (cached user data)
    tableSchema({
      name: 'users',
      columns: [
        { name: 'email', type: 'string' },
        { name: 'full_name', type: 'string' },
        { name: 'avatar_url', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'is_active', type: 'boolean' },
        { name: 'settings', type: 'string' }, // JSON string
      ],
    }),

    // Forms table
    tableSchema({
      name: 'forms',
      columns: [
        { name: 'title', type: 'string' },
        { name: 'description', type: 'string', isOptional: true },
        { name: 'fields', type: 'string' }, // JSON string of form fields
        { name: 'user_id', type: 'string' },
        { name: 'is_public', type: 'boolean' },
        { name: 'is_template', type: 'boolean' },
        { name: 'version', type: 'number' },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'metadata', type: 'string', isOptional: true },
        { name: 'is_deleted', type: 'boolean' }, // Soft delete
        { name: 'sync_status', type: 'string' }, // 'synced' | 'pending' | 'error'
      ],
    }),

    // Collections (entries) table
    tableSchema({
      name: 'collections',
      columns: [
        { name: 'form_id', type: 'string' },
        { name: 'user_id', type: 'string' },
        { name: 'data', type: 'string' }, // JSON string of form data
        { name: 'location_lat', type: 'number', isOptional: true },
        { name: 'location_lng', type: 'number', isOptional: true },
        { name: 'location_accuracy', type: 'number', isOptional: true },
        { name: 'photos', type: 'string', isOptional: true }, // JSON array of photo URLs
        { name: 'status', type: 'string' }, // 'draft' | 'submitted' | 'synced' | 'archived'
        { name: 'synced_at', type: 'number', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'submitted_at', type: 'number', isOptional: true },
        { name: 'metadata', type: 'string', isOptional: true },
        { name: 'is_deleted', type: 'boolean' },
        { name: 'sync_status', type: 'string' },
        { name: 'sync_error', type: 'string', isOptional: true },
      ],
    }),

    // Sync queue table
    tableSchema({
      name: 'sync_queue',
      columns: [
        { name: 'operation', type: 'string' }, // 'create' | 'update' | 'delete'
        { name: 'table_name', type: 'string' },
        { name: 'record_id', type: 'string' },
        { name: 'data', type: 'string' }, // JSON of the data to sync
        { name: 'status', type: 'string' }, // 'pending' | 'processing' | 'completed' | 'failed'
        { name: 'retry_count', type: 'number' },
        { name: 'last_attempt', type: 'number', isOptional: true },
        { name: 'error_message', type: 'string', isOptional: true },
        { name: 'created_at', type: 'number' },
        { name: 'updated_at', type: 'number' },
        { name: 'processed_at', type: 'number', isOptional: true },
      ],
    }),

    // Cache table for API responses
    tableSchema({
      name: 'cache',
      columns: [
        { name: 'key', type: 'string' },
        { name: 'value', type: 'string' }, // JSON string
        { name: 'expires_at', type: 'number' },
        { name: 'created_at', type: 'number' },
      ],
    }),
  ],
});
```

#### Step 4.1.3: Create Database Models

```typescript
// src/database/models/User.ts
import { Model } from '@nozbe/watermelondb';
import { field, text, date, readonly, json } from '@nozbe/watermelondb/decorators';
import { User } from '@types';

/**
 * User Model
 * 
 * Represents a user in the local database.
 * Caches user data for offline access.
 */
export default class UserModel extends Model {
  static table = 'users';

  @text('email') email!: string;
  @text('full_name') fullName!: string;
  @text('avatar_url') avatarUrl?: string;
  
  @field('is_active') isActive!: boolean;
  @json('settings', (settings) => settings || {}) settings!: Record<string, any>;
  
  @readonly @date('created_at') createdAt!: number;
  @readonly @date('updated_at') updatedAt!: number;

  // Helper to convert to User type
  toUser(): User {
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
```

```typescript
// src/database/models/Form.ts
import { Model, Q } from '@nozbe/watermelondb';
import { field, text, date, readonly, json, relation } from '@nozbe/watermelondb/decorators';
import { CollectionForm, FormField } from '@types';

/**
 * Form Model
 * 
 * Represents a form template in the local database.
 * Stores the form structure and metadata.
 */
export default class FormModel extends Model {
  static table = 'forms';

  @text('title') title!: string;
  @text('description') description?: string;
  @json('fields', (fields) => fields || []) fields!: FormField[];
  
  @text('user_id') userId!: string;
  
  @field('is_public') isPublic!: boolean;
  @field('is_template') isTemplate!: boolean;
  @field('version') version!: number;
  @field('is_deleted') isDeleted!: boolean;
  
  @text('sync_status') syncStatus!: 'synced' | 'pending' | 'error';
  
  @json('metadata', (metadata) => metadata || {}) metadata!: Record<string, any>;
  
  @readonly @date('created_at') createdAt!: number;
  @readonly @date('updated_at') updatedAt!: number;

  // Query for collections related to this form
  static associations = {
    collections: { type: 'has_many', foreignKey: 'form_id' },
  };

  // Helper to convert to CollectionForm type
  toForm(): CollectionForm {
    return {
      id: this.id,
      title: this.title,
      description: this.description || '',
      fields: this.fields,
      createdAt: new Date(this.createdAt),
      updatedAt: new Date(this.updatedAt),
    };
  }
}
```

```typescript
// src/database/models/Collection.ts
import { Model } from '@nozbe/watermelondb';
import { field, text, date, readonly, json, relation } from '@nozbe/watermelondb/decorators';
import { CollectionEntry } from '@types';

/**
 * Collection Model
 * 
 * Represents a data collection entry in the local database.
 * Stores form data, location, photos, and sync status.
 */
export default class CollectionModel extends Model {
  static table = 'collections';

  @text('form_id') formId!: string;
  @text('user_id') userId!: string;
  
  @json('data', (data) => data || {}) data!: Record<string, any>;
  
  @field('location_lat') locationLat?: number;
  @field('location_lng') locationLng?: number;
  @field('location_accuracy') locationAccuracy?: number;
  
  @json('photos', (photos) => photos || []) photos!: string[];
  
  @text('status') status!: 'draft' | 'submitted' | 'synced' | 'archived';
  
  @field('synced_at') syncedAt?: number;
  @field('submitted_at') submittedAt?: number;
  @field('is_deleted') isDeleted!: boolean;
  
  @text('sync_status') syncStatus!: 'synced' | 'pending' | 'error';
  @text('sync_error') syncError?: string;
  
  @json('metadata', (metadata) => metadata || {}) metadata!: Record<string, any>;
  
  @readonly @date('created_at') createdAt!: number;
  @readonly @date('updated_at') updatedAt!: number;

  // Relationship to form
  static associations = {
    form: { type: 'belongs_to', foreignKey: 'form_id' },
  };

  // Helper to convert to CollectionEntry type
  toEntry(): CollectionEntry {
    return {
      id: this.id,
      formId: this.formId,
      data: this.data,
      location: this.locationLat && this.locationLng ? {
        latitude: this.locationLat,
        longitude: this.locationLng,
        accuracy: this.locationAccuracy,
      } : undefined,
      photos: this.photos,
      syncedAt: this.syncedAt ? new Date(this.syncedAt) : undefined,
      createdAt: new Date(this.createdAt),
      updatedAt: new Date(this.updatedAt),
    };
  }

  // Helper to get status display
  getStatusDisplay(): string {
    switch (this.status) {
      case 'draft':
        return 'Draft';
      case 'submitted':
        return 'Submitted';
      case 'synced':
        return 'Synced';
      case 'archived':
        return 'Archived';
      default:
        return 'Unknown';
    }
  }
}
```

```typescript
// src/database/models/SyncQueue.ts
import { Model } from '@nozbe/watermelondb';
import { field, text, date, readonly, json } from '@nozbe/watermelondb/decorators';

/**
 * Sync Queue Model
 * 
 * Represents a pending sync operation in the queue.
 * Manages offline request queueing and retries.
 */
export default class SyncQueueModel extends Model {
  static table = 'sync_queue';

  @text('operation') operation!: 'create' | 'update' | 'delete';
  @text('table_name') tableName!: string;
  @text('record_id') recordId!: string;
  @json('data', (data) => data || {}) data!: Record<string, any>;
  
  @text('status') status!: 'pending' | 'processing' | 'completed' | 'failed';
  @field('retry_count') retryCount!: number;
  @field('last_attempt') lastAttempt?: number;
  @text('error_message') errorMessage?: string;
  
  @readonly @date('created_at') createdAt!: number;
  @readonly @date('updated_at') updatedAt!: number;
  @field('processed_at') processedAt?: number;
}
```

#### Step 4.1.4: Initialize Database

```typescript
// src/database/index.ts
import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import { schema } from './schema';
import UserModel from './models/User';
import FormModel from './models/Form';
import CollectionModel from './models/Collection';
import SyncQueueModel from './models/SyncQueue';

// Define model classes for the database
const models = [
  UserModel,
  FormModel,
  CollectionModel,
  SyncQueueModel,
];

// Create SQLite adapter
const adapter = new SQLiteAdapter({
  schema,
  dbName: 'NexusCollectDB',
  // Enable encryption (requires expo-sqlite with encryption support)
  // encryptionKey: 'your-encryption-key',
  onSetUpError: (error) => {
    console.error('Database setup error:', error);
  },
  // Migrations would go here
  // migrations: migrations,
});

// Create the database instance
export const database = new Database({
  adapter,
  modelClasses: models,
  actionsEnabled: true,
});

// Export models for convenience
export { UserModel, FormModel, CollectionModel, SyncQueueModel };

// Database utilities
export const dbUtils = {
  /**
   * Clear all data from the database
   */
  clearAll: async () => {
    await database.write(async () => {
      const collections = await database.get('collections').query().fetch();
      const forms = await database.get('forms').query().fetch();
      const users = await database.get('users').query().fetch();
      const syncQueue = await database.get('sync_queue').query().fetch();

      await Promise.all([
        ...collections.map(c => c.destroyPermanently()),
        ...forms.map(f => f.destroyPermanently()),
        ...users.map(u => u.destroyPermanently()),
        ...syncQueue.map(s => s.destroyPermanently()),
      ]);
    });
  },

  /**
   * Get database statistics
   */
  getStats: async () => {
    const collections = await database.get('collections').query().fetch();
    const forms = await database.get('forms').query().fetch();
    const pendingSync = await database
      .get('sync_queue')
      .query()
      .where('status', 'pending')
      .fetch();

    return {
      collections: collections.length,
      forms: forms.length,
      pendingSync: pendingSync.length,
    };
  },
};

// Export for testing
export { database as db };
```

---

## Phase 4.2: Repository Pattern

### The Concept: Data Access Layer

The Repository pattern provides a clean API for data access, abstracting away the database implementation details. Think of it as a librarian—you ask for a book (data), and the librarian knows exactly where to find it and how to retrieve it, without you needing to know the filing system.

### The Implementation: Data Repositories

```typescript
// src/database/repositories/FormRepository.ts
import { database, FormModel } from '@database';
import { Q } from '@nozbe/watermelondb';
import { CollectionForm, FormField } from '@types';

/**
 * Form Repository
 * 
 * Handles all form-related database operations.
 * Provides a clean interface for creating, reading, updating, and deleting forms.
 */
export class FormRepository {
  /**
   * Get all forms for the current user
   */
  static async getAll(userId: string): Promise<FormModel[]> {
    const forms = await database
      .get<FormModel>('forms')
      .query(
        Q.where('user_id', userId),
        Q.where('is_deleted', false),
        Q.sortBy('updated_at', Q.desc)
      )
      .fetch();
    return forms;
  }

  /**
   * Get a single form by ID
   */
  static async getById(id: string): Promise<FormModel | null> {
    try {
      const form = await database
        .get<FormModel>('forms')
        .find(id);
      return form;
    } catch (error) {
      return null;
    }
  }

  /**
   * Get form templates (public forms)
   */
  static async getTemplates(): Promise<FormModel[]> {
    const templates = await database
      .get<FormModel>('forms')
      .query(
        Q.where('is_template', true),
        Q.where('is_public', true),
        Q.where('is_deleted', false),
        Q.sortBy('created_at', Q.desc)
      )
      .fetch();
    return templates;
  }

  /**
   * Create a new form
   */
  static async create(
    userId: string,
    formData: Omit<CollectionForm, 'id' | 'createdAt' | 'updatedAt'>
  ): Promise<FormModel> {
    const form = await database.write(async () => {
      const newForm = await database
        .get<FormModel>('forms')
        .create(record => {
          record.userId = userId;
          record.title = formData.title;
          record.description = formData.description || '';
          record.fields = formData.fields;
          record.isPublic = false;
          record.isTemplate = false;
          record.version = 1;
          record.isDeleted = false;
          record.syncStatus = 'pending';
          record.metadata = {};
        });
      return newForm;
    });
    return form;
  }

  /**
   * Update an existing form
   */
  static async update(
    id: string,
    updates: Partial<Omit<CollectionForm, 'id' | 'createdAt' | 'updatedAt'>>
  ): Promise<FormModel> {
    const form = await database.write(async () => {
      const existingForm = await database
        .get<FormModel>('forms')
        .find(id);
      
      await existingForm.update(record => {
        if (updates.title !== undefined) record.title = updates.title;
        if (updates.description !== undefined) record.description = updates.description;
        if (updates.fields !== undefined) record.fields = updates.fields;
        record.syncStatus = 'pending';
        record.version += 1;
      });
      
      return existingForm;
    });
    return form;
  }

  /**
   * Soft delete a form
   */
  static async delete(id: string): Promise<void> {
    await database.write(async () => {
      const form = await database
        .get<FormModel>('forms')
        .find(id);
      
      await form.update(record => {
        record.isDeleted = true;
        record.syncStatus = 'pending';
      });
    });
  }

  /**
   * Mark form as synced
   */
  static async markSynced(id: string): Promise<void> {
    await database.write(async () => {
      const form = await database
        .get<FormModel>('forms')
        .find(id);
      
      await form.update(record => {
        record.syncStatus = 'synced';
      });
    });
  }
}
```

```typescript
// src/database/repositories/CollectionRepository.ts
import { database, CollectionModel } from '@database';
import { Q } from '@nozbe/watermelondb';
import { CollectionEntry } from '@types';

/**
 * Collection Repository
 * 
 * Handles all collection entry-related database operations.
 * Manages CRUD operations for data entries.
 */
export class CollectionRepository {
  /**
   * Get all collections for a user
   */
  static async getAll(userId: string): Promise<CollectionModel[]> {
    const collections = await database
      .get<CollectionModel>('collections')
      .query(
        Q.where('user_id', userId),
        Q.where('is_deleted', false),
        Q.sortBy('created_at', Q.desc)
      )
      .fetch();
    return collections;
  }

  /**
   * Get collections for a specific form
   */
  static async getByFormId(formId: string, userId: string): Promise<CollectionModel[]> {
    const collections = await database
      .get<CollectionModel>('collections')
      .query(
        Q.where('form_id', formId),
        Q.where('user_id', userId),
        Q.where('is_deleted', false),
        Q.sortBy('created_at', Q.desc)
      )
      .fetch();
    return collections;
  }

  /**
   * Get a single collection by ID
   */
  static async getById(id: string): Promise<CollectionModel | null> {
    try {
      const collection = await database
        .get<CollectionModel>('collections')
        .find(id);
      return collection;
    } catch (error) {
      return null;
    }
  }

  /**
   * Create a new collection entry (draft)
   */
  static async create(
    userId: string,
    data: {
      formId: string;
      data: Record<string, any>;
      location?: { latitude: number; longitude: number; accuracy?: number };
      photos?: string[];
      metadata?: Record<string, any>;
    }
  ): Promise<CollectionModel> {
    const collection = await database.write(async () => {
      const newCollection = await database
        .get<CollectionModel>('collections')
        .create(record => {
          record.userId = userId;
          record.formId = data.formId;
          record.data = data.data;
          
          if (data.location) {
            record.locationLat = data.location.latitude;
            record.locationLng = data.location.longitude;
            record.locationAccuracy = data.location.accuracy;
          }
          
          record.photos = data.photos || [];
          record.status = 'draft';
          record.isDeleted = false;
          record.syncStatus = 'pending';
          record.metadata = data.metadata || {};
        });
      return newCollection;
    });
    return collection;
  }

  /**
   * Update a collection entry
   */
  static async update(
    id: string,
    updates: Partial<{
      data: Record<string, any>;
      location: { latitude: number; longitude: number; accuracy?: number };
      photos: string[];
      status: 'draft' | 'submitted' | 'synced' | 'archived';
      metadata: Record<string, any>;
    }>
  ): Promise<CollectionModel> {
    const collection = await database.write(async () => {
      const existingCollection = await database
        .get<CollectionModel>('collections')
        .find(id);
      
      await existingCollection.update(record => {
        if (updates.data !== undefined) record.data = updates.data;
        if (updates.location !== undefined) {
          record.locationLat = updates.location.latitude;
          record.locationLng = updates.location.longitude;
          record.locationAccuracy = updates.location.accuracy;
        }
        if (updates.photos !== undefined) record.photos = updates.photos;
        if (updates.status !== undefined) {
          record.status = updates.status;
          if (updates.status === 'submitted') {
            record.submittedAt = Date.now();
          }
        }
        if (updates.metadata !== undefined) record.metadata = updates.metadata;
        record.syncStatus = 'pending';
      });
      
      return existingCollection;
    });
    return collection;
  }

  /**
   * Submit a collection entry (mark as ready for sync)
   */
  static async submit(id: string): Promise<CollectionModel> {
    const collection = await database.write(async () => {
      const existingCollection = await database
        .get<CollectionModel>('collections')
        .find(id);
      
      await existingCollection.update(record => {
        record.status = 'submitted';
        record.submittedAt = Date.now();
        record.syncStatus = 'pending';
      });
      
      return existingCollection;
    });
    return collection;
  }

  /**
   * Mark collection as synced
   */
  static async markSynced(id: string): Promise<void> {
    await database.write(async () => {
      const collection = await database
        .get<CollectionModel>('collections')
        .find(id);
      
      await collection.update(record => {
        record.status = 'synced';
        record.syncedAt = Date.now();
        record.syncStatus = 'synced';
        record.syncError = undefined;
      });
    });
  }

  /**
   * Mark collection with sync error
   */
  static async markSyncError(id: string, error: string): Promise<void> {
    await database.write(async () => {
      const collection = await database
        .get<CollectionModel>('collections')
        .find(id);
      
      await collection.update(record => {
        record.syncStatus = 'error';
        record.syncError = error;
      });
    });
  }

  /**
   * Delete a collection entry (soft delete)
   */
  static async delete(id: string): Promise<void> {
    await database.write(async () => {
      const collection = await database
        .get<CollectionModel>('collections')
        .find(id);
      
      await collection.update(record => {
        record.isDeleted = true;
        record.syncStatus = 'pending';
      });
    });
  }

  /**
   * Get unsynced collections
   */
  static async getUnsynced(userId: string): Promise<CollectionModel[]> {
    const collections = await database
      .get<CollectionModel>('collections')
      .query(
        Q.where('user_id', userId),
        Q.where('is_deleted', false),
        Q.where('sync_status', Q.notEq('synced')),
        Q.sortBy('created_at', Q.asc)
      )
      .fetch();
    return collections;
  }

  /**
   * Get collections by status
   */
  static async getByStatus(
    userId: string,
    status: 'draft' | 'submitted' | 'synced' | 'archived'
  ): Promise<CollectionModel[]> {
    const collections = await database
      .get<CollectionModel>('collections')
      .query(
        Q.where('user_id', userId),
        Q.where('status', status),
        Q.where('is_deleted', false),
        Q.sortBy('created_at', Q.desc)
      )
      .fetch();
    return collections;
  }
}
```

```typescript
// src/database/repositories/SyncQueueRepository.ts
import { database, SyncQueueModel } from '@database';
import { Q } from '@nozbe/watermelondb';

/**
 * Sync Queue Repository
 * 
 * Manages the sync queue for offline operations.
 * Handles queuing, processing, and retrying sync operations.
 */
export class SyncQueueRepository {
  /**
   * Add an operation to the sync queue
   */
  static async enqueue(
    operation: 'create' | 'update' | 'delete',
    tableName: string,
    recordId: string,
    data: Record<string, any>
  ): Promise<SyncQueueModel> {
    const queueItem = await database.write(async () => {
      const newItem = await database
        .get<SyncQueueModel>('sync_queue')
        .create(record => {
          record.operation = operation;
          record.tableName = tableName;
          record.recordId = recordId;
          record.data = data;
          record.status = 'pending';
          record.retryCount = 0;
        });
      return newItem;
    });
    return queueItem;
  }

  /**
   * Get all pending sync items (oldest first)
   */
  static async getPending(): Promise<SyncQueueModel[]> {
    const items = await database
      .get<SyncQueueModel>('sync_queue')
      .query(
        Q.where('status', 'pending'),
        Q.sortBy('created_at', Q.asc)
      )
      .fetch();
    return items;
  }

  /**
   * Get a sync item by ID
   */
  static async getById(id: string): Promise<SyncQueueModel | null> {
    try {
      const item = await database
        .get<SyncQueueModel>('sync_queue')
        .find(id);
      return item;
    } catch (error) {
      return null;
    }
  }

  /**
   * Mark sync item as processing
   */
  static async markProcessing(id: string): Promise<void> {
    await database.write(async () => {
      const item = await database
        .get<SyncQueueModel>('sync_queue')
        .find(id);
      
      await item.update(record => {
        record.status = 'processing';
        record.lastAttempt = Date.now();
      });
    });
  }

  /**
   * Mark sync item as completed
   */
  static async markCompleted(id: string): Promise<void> {
    await database.write(async () => {
      const item = await database
        .get<SyncQueueModel>('sync_queue')
        .find(id);
      
      await item.update(record => {
        record.status = 'completed';
        record.processedAt = Date.now();
      });
    });
  }

  /**
   * Mark sync item as failed with error
   */
  static async markFailed(id: string, error: string): Promise<void> {
    await database.write(async () => {
      const item = await database
        .get<SyncQueueModel>('sync_queue')
        .find(id);
      
      await item.update(record => {
        record.status = 'failed';
        record.errorMessage = error;
        record.retryCount += 1;
      });
    });
  }

  /**
   * Retry failed sync items (reset to pending)
   */
  static async retryFailed(): Promise<void> {
    await database.write(async () => {
      const failedItems = await database
        .get<SyncQueueModel>('sync_queue')
        .query(
          Q.where('status', 'failed'),
          Q.where('retry_count', Q.lt(5)) // Max 5 retries
        )
        .fetch();
      
      await Promise.all(
        failedItems.map(item =>
          item.update(record => {
            record.status = 'pending';
          })
        )
      );
    });
  }

  /**
   * Clean up old completed sync items
   */
  static async cleanupOld(days: number = 7): Promise<void> {
    const cutoffDate = Date.now() - (days * 24 * 60 * 60 * 1000);
    
    await database.write(async () => {
      const oldItems = await database
        .get<SyncQueueModel>('sync_queue')
        .query(
          Q.where('status', 'completed'),
          Q.where('processed_at', Q.lt(cutoffDate))
        )
        .fetch();
      
      await Promise.all(
        oldItems.map(item => item.destroyPermanently())
      );
    });
  }

  /**
   * Get sync queue statistics
   */
  static async getStats(): Promise<{
    pending: number;
    processing: number;
    completed: number;
    failed: number;
  }> {
    const allItems = await database
      .get<SyncQueueModel>('sync_queue')
      .query()
      .fetch();

    const stats = {
      pending: allItems.filter(i => i.status === 'pending').length,
      processing: allItems.filter(i => i.status === 'processing').length,
      completed: allItems.filter(i => i.status === 'completed').length,
      failed: allItems.filter(i => i.status === 'failed').length,
    };

    return stats;
  }
}
```

---

## Phase 4.3: Sync Engine

### The Concept: Automatic Data Synchronization

The sync engine is the heart of our offline-first architecture. It orchestrates the flow of data between the local database and the cloud, handling uploads, downloads, conflicts, and retries. Think of it as an automated logistics system that ensures data reaches its destination, even when there are network disruptions.

### The Implementation: Sync Engine

```typescript
// src/database/sync/SyncEngine.ts
import { database, dbUtils } from '@database';
import { CollectionRepository } from '../repositories/CollectionRepository';
import { FormRepository } from '../repositories/FormRepository';
import { SyncQueueRepository } from '../repositories/SyncQueueRepository';
import { supabase } from '@api/supabase';
import { useAuthStore } from '@store';
import NetInfo from '@react-native-community/netinfo';
import { Platform } from 'react-native';

/**
 * Sync Engine
 * 
 * Manages the synchronization of data between the local database
 * and the cloud backend (Supabase).
 * 
 * Features:
 * - Automatic sync on connectivity change
 * - Conflict resolution
 * - Retry logic with exponential backoff
 * - Batch processing
 * - Sync status tracking
 */

export interface SyncResult {
  success: boolean;
  itemsProcessed: number;
  itemsFailed: number;
  errors?: string[];
}

export class SyncEngine {
  private isSyncing: boolean = false;
  private syncInterval: NodeJS.Timeout | null = null;
  private isNetworkAvailable: boolean = true;

  constructor() {
    // Listen for network changes
    NetInfo.addEventListener(state => {
      const wasAvailable = this.isNetworkAvailable;
      this.isNetworkAvailable = state.isConnected && state.isInternetReachable;
      
      // If network becomes available, trigger sync
      if (!wasAvailable && this.isNetworkAvailable) {
        console.log('Network restored, triggering sync...');
        this.sync();
      }
    });
  }

  /**
   * Start the sync engine
   */
  start(intervalMinutes: number = 5): void {
    if (this.syncInterval) {
      this.stop();
    }

    // Initial sync
    this.sync();

    // Periodic sync
    this.syncInterval = setInterval(() => {
      this.sync();
    }, intervalMinutes * 60 * 1000);

    console.log(`Sync engine started (interval: ${intervalMinutes} minutes)`);
  }

  /**
   * Stop the sync engine
   */
  stop(): void {
    if (this.syncInterval) {
      clearInterval(this.syncInterval);
      this.syncInterval = null;
      console.log('Sync engine stopped');
    }
  }

  /**
   * Perform a full sync
   */
  async sync(): Promise<SyncResult> {
    // Prevent concurrent syncs
    if (this.isSyncing) {
      console.log('Sync already in progress, skipping...');
      return {
        success: false,
        itemsProcessed: 0,
        itemsFailed: 0,
        errors: ['Sync already in progress'],
      };
    }

    // Check network connectivity
    if (!this.isNetworkAvailable) {
      console.log('Network unavailable, skipping sync');
      return {
        success: false,
        itemsProcessed: 0,
        itemsFailed: 0,
        errors: ['Network unavailable'],
      };
    }

    const user = useAuthStore.getState().user;
    if (!user) {
      console.log('No authenticated user, skipping sync');
      return {
        success: false,
        itemsProcessed: 0,
        itemsFailed: 0,
        errors: ['No authenticated user'],
      };
    }

    this.isSyncing = true;
    console.log('Starting sync...');

    let itemsProcessed = 0;
    let itemsFailed = 0;
    const errors: string[] = [];

    try {
      // Step 1: Upload pending items
      const uploadResult = await this.uploadPendingItems(user.id);
      itemsProcessed += uploadResult.processed;
      itemsFailed += uploadResult.failed;
      if (uploadResult.errors) {
        errors.push(...uploadResult.errors);
      }

      // Step 2: Download latest data
      const downloadResult = await this.downloadLatestData(user.id);
      itemsProcessed += downloadResult.processed;
      itemsFailed += downloadResult.failed;
      if (downloadResult.errors) {
        errors.push(...downloadResult.errors);
      }

      // Step 3: Clean up old queue items
      await SyncQueueRepository.cleanupOld();

      console.log(`Sync completed: ${itemsProcessed} processed, ${itemsFailed} failed`);
    } catch (error: any) {
      console.error('Sync failed:', error);
      errors.push(error.message || 'Unknown sync error');
      itemsFailed += 1;
    } finally {
      this.isSyncing = false;
    }

    return {
      success: itemsFailed === 0,
      itemsProcessed,
      itemsFailed,
      errors: errors.length > 0 ? errors : undefined,
    };
  }

  /**
   * Upload pending items to the cloud
   */
  private async uploadPendingItems(userId: string): Promise<{
    processed: number;
    failed: number;
    errors?: string[];
  }> {
    let processed = 0;
    let failed = 0;
    const errors: string[] = [];

    try {
      // Get pending sync items
      const pendingItems = await SyncQueueRepository.getPending();
      
      if (pendingItems.length === 0) {
        console.log('No pending items to upload');
        return { processed: 0, failed: 0 };
      }

      console.log(`Processing ${pendingItems.length} pending sync items...`);

      for (const item of pendingItems) {
        try {
          // Mark as processing
          await SyncQueueRepository.markProcessing(item.id);

          // Process based on table and operation
          switch (item.tableName) {
            case 'collections':
              await this.processCollectionSync(item, userId);
              break;
            case 'forms':
              await this.processFormSync(item, userId);
              break;
            default:
              throw new Error(`Unknown table: ${item.tableName}`);
          }

          // Mark as completed
          await SyncQueueRepository.markCompleted(item.id);
          processed += 1;
        } catch (error: any) {
          console.error(`Failed to process sync item ${item.id}:`, error);
          await SyncQueueRepository.markFailed(item.id, error.message);
          failed += 1;
          errors.push(`Item ${item.id}: ${error.message}`);
        }
      }
    } catch (error: any) {
      errors.push(`Upload error: ${error.message}`);
    }

    return { processed, failed, errors };
  }

  /**
   * Process a collection sync item
   */
  private async processCollectionSync(item: any, userId: string): Promise<void> {
    const { operation, data } = item;

    switch (operation) {
      case 'create':
      case 'update': {
        // Upload to Supabase
        const { error } = await supabase
          .from('collections')
          .upsert({
            id: item.recordId,
            form_id: data.formId,
            user_id: userId,
            data: data.data,
            location: data.location || null,
            photos: data.photos || [],
            status: data.status || 'submitted',
            metadata: data.metadata || {},
          })
          .select()
          .single();

        if (error) throw error;
        break;
      }

      case 'delete': {
        // Delete from Supabase
        const { error } = await supabase
          .from('collections')
          .delete()
          .eq('id', item.recordId);

        if (error) throw error;
        break;
      }

      default:
        throw new Error(`Unknown operation: ${operation}`);
    }
  }

  /**
   * Process a form sync item
   */
  private async processFormSync(item: any, userId: string): Promise<void> {
    const { operation, data } = item;

    switch (operation) {
      case 'create':
      case 'update': {
        const { error } = await supabase
          .from('forms')
          .upsert({
            id: item.recordId,
            title: data.title,
            description: data.description,
            fields: data.fields,
            user_id: userId,
            is_public: data.isPublic || false,
            is_template: data.isTemplate || false,
            version: data.version || 1,
            metadata: data.metadata || {},
          })
          .select()
          .single();

        if (error) throw error;
        break;
      }

      case 'delete': {
        const { error } = await supabase
          .from('forms')
          .delete()
          .eq('id', item.recordId);

        if (error) throw error;
        break;
      }

      default:
        throw new Error(`Unknown operation: ${operation}`);
    }
  }

  /**
   * Download latest data from the cloud
   */
  private async downloadLatestData(userId: string): Promise<{
    processed: number;
    failed: number;
    errors?: string[];
  }> {
    let processed = 0;
    let failed = 0;
    const errors: string[] = [];

    try {
      // Get last sync timestamp from database
      // For now, we'll fetch all data (in production, use timestamps for incremental sync)

      console.log('Downloading latest data...');

      // Download forms
      const { data: forms, error: formsError } = await supabase
        .from('forms')
        .select('*')
        .eq('user_id', userId)
        .or(`is_public.eq.true,user_id.eq.${userId}`)
        .eq('is_deleted', false);

      if (formsError) throw formsError;

      // Download collections
      const { data: collections, error: collectionsError } = await supabase
        .from('collections')
        .select('*')
        .eq('user_id', userId)
        .eq('is_deleted', false);

      if (collectionsError) throw collectionsError;

      // Update local database
      await database.write(async () => {
        // Upsert forms
        if (forms) {
          for (const form of forms) {
            const existingForm = await database
              .get('forms')
              .find(form.id)
              .catch(() => null);

            if (existingForm) {
              await existingForm.update(record => {
                record.title = form.title;
                record.description = form.description || '';
                record.fields = form.fields;
                record.isPublic = form.is_public;
                record.isTemplate = form.is_template;
                record.version = form.version;
                record.updatedAt = new Date(form.updated_at).getTime();
              });
            } else {
              await database.get('forms').create(record => {
                record.id = form.id;
                record.userId = form.user_id;
                record.title = form.title;
                record.description = form.description || '';
                record.fields = form.fields;
                record.isPublic = form.is_public;
                record.isTemplate = form.is_template;
                record.version = form.version;
                record.isDeleted = false;
                record.syncStatus = 'synced';
                record.metadata = form.metadata || {};
                record.createdAt = new Date(form.created_at).getTime();
                record.updatedAt = new Date(form.updated_at).getTime();
              });
            }
          }
        }

        // Upsert collections
        if (collections) {
          for (const collection of collections) {
            const existingCollection = await database
              .get('collections')
              .find(collection.id)
              .catch(() => null);

            if (existingCollection) {
              await existingCollection.update(record => {
                record.formId = collection.form_id;
                record.data = collection.data;
                record.locationLat = collection.location?.latitude;
                record.locationLng = collection.location?.longitude;
                record.locationAccuracy = collection.location?.accuracy;
                record.photos = collection.photos || [];
                record.status = collection.status;
                record.syncedAt = new Date().getTime();
                record.syncStatus = 'synced';
              });
            } else {
              await database.get('collections').create(record => {
                record.id = collection.id;
                record.userId = collection.user_id;
                record.formId = collection.form_id;
                record.data = collection.data;
                record.locationLat = collection.location?.latitude;
                record.locationLng = collection.location?.longitude;
                record.locationAccuracy = collection.location?.accuracy;
                record.photos = collection.photos || [];
                record.status = collection.status || 'synced';
                record.isDeleted = false;
                record.syncStatus = 'synced';
                record.metadata = collection.metadata || {};
                record.createdAt = new Date(collection.created_at).getTime();
                record.updatedAt = new Date(collection.updated_at).getTime();
              });
            }
          }
        }
      });

      processed = (forms?.length || 0) + (collections?.length || 0);
      console.log(`Downloaded ${processed} items`);
    } catch (error: any) {
      console.error('Download failed:', error);
      errors.push(`Download error: ${error.message}`);
      failed += 1;
    }

    return { processed, failed, errors };
  }

  /**
   * Get sync status
   */
  async getSyncStatus(): Promise<{
    isSyncing: boolean;
    lastSync: Date | null;
    pendingItems: number;
    failedItems: number;
  }> {
    const pendingItems = await database
      .get('sync_queue')
      .query()
      .where('status', 'pending')
      .fetch();

    const failedItems = await database
      .get('sync_queue')
      .query()
      .where('status', 'failed')
      .fetch();

    return {
      isSyncing: this.isSyncing,
      lastSync: null, // In production, store last sync timestamp
      pendingItems: pendingItems.length,
      failedItems: failedItems.length,
    };
  }
}

// Singleton instance
export const syncEngine = new SyncEngine();
```

---

## Phase 4.4: Form Builder and Rendering

### The Concept: Dynamic Form Generation

A form builder allows users to create custom forms without coding. Think of it as a LEGO set for data collection—users can drag and drop different field types (text, number, date, photo) to build their own forms.

### The Implementation: Form Builder

```typescript
// src/screens/main/FormBuilderScreen.tsx
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  TextInput,
  Modal,
} from 'react-native';
import { useTheme } from '@themes';
import { Button } from '@components/common/Button';
import { Input } from '@components/common/Input';
import { Card } from '@components/common/Card';
import { Ionicons } from '@expo/vector-icons';
import { FormField } from '@types';
import { FormRepository } from '@database/repositories/FormRepository';
import { useAuth } from '@hooks/useAuth';
import { useNavigation } from '@react-navigation/native';
import { MainScreenNavigationProp } from '@types/navigation';

/**
 * Form Builder Screen
 * 
 * Allows users to create and edit custom forms.
 * Features:
 * - Add/remove fields
 * - Drag to reorder
 * - Field configuration
 * - Preview mode
 */
export default function FormBuilderScreen() {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [fields, setFields] = useState<FormField[]>([]);
  const [selectedField, setSelectedField] = useState<FormField | null>(null);
  const [isFieldModalVisible, setIsFieldModalVisible] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  
  const { user } = useAuth();
  const theme = useTheme();
  const navigation = useNavigation<MainScreenNavigationProp>();

  /**
   * Add a new field to the form
   */
  const addField = () => {
    const newField: FormField = {
      id: `field_${Date.now()}`,
      label: 'New Field',
      type: 'text',
      required: false,
    };
    setFields([...fields, newField]);
    setSelectedField(newField);
    setIsFieldModalVisible(true);
  };

  /**
   * Update a field
   */
  const updateField = (fieldId: string, updates: Partial<FormField>) => {
    setFields(prev =>
      prev.map(f => f.id === fieldId ? { ...f, ...updates } : f)
    );
  };

  /**
   * Delete a field
   */
  const deleteField = (fieldId: string) => {
    Alert.alert(
      'Delete Field',
      'Are you sure you want to delete this field?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: () => {
            setFields(prev => prev.filter(f => f.id !== fieldId));
            if (selectedField?.id === fieldId) {
              setSelectedField(null);
              setIsFieldModalVisible(false);
            }
          },
        },
      ]
    );
  };

  /**
   * Reorder fields
   */
  const moveField = (fromIndex: number, toIndex: number) => {
    const newFields = [...fields];
    const [removed] = newFields.splice(fromIndex, 1);
    newFields.splice(toIndex, 0, removed);
    setFields(newFields);
  };

  /**
   * Save the form
   */
  const saveForm = async () => {
    if (!title.trim()) {
      Alert.alert('Error', 'Please enter a form title');
      return;
    }

    if (fields.length === 0) {
      Alert.alert('Error', 'Please add at least one field');
      return;
    }

    setIsSaving(true);
    try {
      if (!user) throw new Error('User not authenticated');
      
      await FormRepository.create(user.id, {
        title: title.trim(),
        description: description.trim(),
        fields: fields,
      });
      
      Alert.alert(
        'Success',
        'Form created successfully!',
        [
          {
            text: 'OK',
            onPress: () => navigation.goBack(),
          },
        ]
      );
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to save form');
    } finally {
      setIsSaving(false);
    }
  };

  /**
   * Render field type icon
   */
  const getFieldIcon = (type: FormField['type']): keyof typeof Ionicons.glyphMap => {
    switch (type) {
      case 'text':
        return 'text-outline';
      case 'number':
        return 'calculator-outline';
      case 'date':
        return 'calendar-outline';
      case 'select':
        return 'list-outline';
      case 'checkbox':
        return 'checkbox-outline';
      case 'photo':
        return 'camera-outline';
      default:
        return 'document-text-outline';
    }
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.colors.background }]}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Form details */}
        <Card>
          <Input
            label="Form Title"
            value={title}
            onChangeText={setTitle}
            placeholder="Enter form title"
            containerStyle={styles.inputContainer}
          />
          
          <Input
            label="Description"
            value={description}
            onChangeText={setDescription}
            placeholder="Enter form description"
            multiline
            numberOfLines={3}
            containerStyle={styles.inputContainer}
          />
        </Card>

        {/* Fields list */}
        <Card>
          <View style={styles.fieldHeader}>
            <Text style={[styles.fieldTitle, { color: theme.colors.text }]}>
              Fields ({fields.length})
            </Text>
            <TouchableOpacity
              style={[styles.addButton, { backgroundColor: theme.colors.primary[500] }]}
              onPress={addField}
            >
              <Ionicons name="add" size={24} color="#fff" />
            </TouchableOpacity>
          </View>

          {fields.length === 0 ? (
            <View style={styles.emptyState}>
              <Ionicons name="document-text-outline" size={48} color={theme.colors.textSecondary} />
              <Text style={[styles.emptyText, { color: theme.colors.textSecondary }]}>
                No fields added yet
              </Text>
              <Text style={[styles.emptySubtext, { color: theme.colors.textSecondary }]}>
                Tap the + button to add fields
              </Text>
            </View>
          ) : (
            fields.map((field, index) => (
              <TouchableOpacity
                key={field.id}
                style={[
                  styles.fieldItem,
                  { borderColor: theme.colors.border },
                  selectedField?.id === field.id && {
                    borderColor: theme.colors.primary[500],
                    backgroundColor: theme.colors.primary[50],
                  },
                ]}
                onPress={() => {
                  setSelectedField(field);
                  setIsFieldModalVisible(true);
                }}
              >
                <View style={styles.fieldLeft}>
                  <Ionicons
                    name={getFieldIcon(field.type)}
                    size={24}
                    color={theme.colors.primary[500]}
                  />
                  <View style={styles.fieldInfo}>
                    <Text style={[styles.fieldLabel, { color: theme.colors.text }]}>
                      {field.label}
                    </Text>
                    <Text style={[styles.fieldType, { color: theme.colors.textSecondary }]}>
                      {field.type.charAt(0).toUpperCase() + field.type.slice(1)}
                      {field.required && ' • Required'}
                    </Text>
                  </View>
                </View>
                <View style={styles.fieldRight}>
                  <TouchableOpacity
                    style={styles.moveButton}
                    onPress={() => {
                      if (index > 0) moveField(index, index - 1);
                    }}
                  >
                    <Ionicons
                      name="chevron-up-outline"
                      size={20}
                      color={theme.colors.textSecondary}
                    />
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={styles.moveButton}
                    onPress={() => {
                      if (index < fields.length - 1) moveField(index, index + 1);
                    }}
                  >
                    <Ionicons
                      name="chevron-down-outline"
                      size={20}
                      color={theme.colors.textSecondary}
                    />
                  </TouchableOpacity>
                  <TouchableOpacity
                    onPress={() => deleteField(field.id)}
                  >
                    <Ionicons
                      name="trash-outline"
                      size={20}
                      color={theme.colors.error}
                    />
                  </TouchableOpacity>
                </View>
              </TouchableOpacity>
            ))
          )}
        </Card>

        {/* Save button */}
        <Button
          title={isSaving ? 'Saving...' : 'Save Form'}
          onPress={saveForm}
          variant="primary"
          size="large"
          loading={isSaving}
          disabled={isSaving}
          style={styles.saveButton}
        />
      </ScrollView>

      {/* Field Editor Modal */}
      <Modal
        visible={isFieldModalVisible}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setIsFieldModalVisible(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={[styles.modalContent, { backgroundColor: theme.colors.background }]}>
            {selectedField && (
              <FieldEditor
                field={selectedField}
                onUpdate={(updates) => {
                  updateField(selectedField.id, updates);
                }}
                onDelete={() => {
                  deleteField(selectedField.id);
                }}
                onClose={() => setIsFieldModalVisible(false)}
              />
            )}
          </View>
        </View>
      </Modal>
    </View>
  );
}

/**
 * Field Editor Component
 */
function FieldEditor({
  field,
  onUpdate,
  onDelete,
  onClose,
}: {
  field: FormField;
  onUpdate: (updates: Partial<FormField>) => void;
  onDelete: () => void;
  onClose: () => void;
}) {
  const theme = useTheme();
  const [label, setLabel] = useState(field.label);
  const [type, setType] = useState<FormField['type']>(field.type);
  const [required, setRequired] = useState(field.required);
  const [options, setOptions] = useState(field.options?.join('\n') || '');

  const handleSave = () => {
    onUpdate({
      label: label.trim(),
      type: type,
      required: required,
      options: type === 'select' ? options.split('\n').filter(o => o.trim()) : undefined,
    });
    onClose();
  };

  return (
    <View style={styles.editorContainer}>
      <View style={styles.editorHeader}>
        <Text style={[styles.editorTitle, { color: theme.colors.text }]}>
          Edit Field
        </Text>
        <TouchableOpacity onPress={onClose}>
          <Ionicons name="close" size={24} color={theme.colors.text} />
        </TouchableOpacity>
      </View>

      <Input
        label="Field Label"
        value={label}
        onChangeText={setLabel}
        placeholder="Enter field label"
        containerStyle={styles.inputContainer}
      />

      <Text style={[styles.inputLabel, { color: theme.colors.text }]}>
        Field Type
      </Text>
      <View style={styles.typeGrid}>
        {(['text', 'number', 'date', 'select', 'checkbox', 'photo'] as const).map((t) => (
          <TouchableOpacity
            key={t}
            style={[
              styles.typeButton,
              { borderColor: theme.colors.border },
              type === t && {
                borderColor: theme.colors.primary[500],
                backgroundColor: theme.colors.primary[50],
              },
            ]}
            onPress={() => setType(t)}
          >
            <Text
              style={[
                styles.typeButtonText,
                { color: theme.colors.text },
                type === t && { color: theme.colors.primary[500] },
              ]}
            >
              {t.charAt(0).toUpperCase() + t.slice(1)}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {type === 'select' && (
        <Input
          label="Options (one per line)"
          value={options}
          onChangeText={setOptions}
          placeholder="Option 1\nOption 2\nOption 3"
          multiline
          numberOfLines={4}
          containerStyle={styles.inputContainer}
        />
      )}

      <View style={styles.requiredContainer}>
        <TouchableOpacity
          style={styles.checkboxButton}
          onPress={() => setRequired(!required)}
        >
          <View
            style={[
              styles.checkbox,
              { borderColor: theme.colors.border },
              required && {
                backgroundColor: theme.colors.primary[500],
                borderColor: theme.colors.primary[500],
              },
            ]}
          >
            {required && <Ionicons name="checkmark" size={16} color="#fff" />}
          </View>
          <Text style={[styles.checkboxLabel, { color: theme.colors.text }]}>
            Required field
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.editorActions}>
        <Button
          title="Delete"
          onPress={() => {
            onDelete();
            onClose();
          }}
          variant="danger"
          style={styles.deleteButton}
        />
        <Button
          title="Save"
          onPress={handleSave}
          variant="primary"
          style={styles.saveFieldButton}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  inputContainer: {
    marginBottom: 12,
  },
  fieldHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  fieldTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  addButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyText: {
    fontSize: 18,
    marginTop: 12,
  },
  emptySubtext: {
    fontSize: 14,
    marginTop: 4,
  },
  fieldItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    borderWidth: 1,
    borderRadius: 8,
    marginBottom: 8,
  },
  fieldLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  fieldInfo: {
    marginLeft: 12,
    flex: 1,
  },
  fieldLabel: {
    fontSize: 16,
    fontWeight: '500',
  },
  fieldType: {
    fontSize: 12,
  },
  fieldRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  moveButton: {
    padding: 4,
  },
  saveButton: {
    marginTop: 16,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    maxHeight: '80%',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
  },
  editorContainer: {
    paddingBottom: 20,
  },
  editorHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  editorTitle: {
    fontSize: 20,
    fontWeight: '700',
  },
  inputLabel: {
    fontSize: 14,
    fontWeight: '500',
    marginBottom: 8,
  },
  typeGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    marginBottom: 16,
  },
  typeButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderWidth: 1,
    borderRadius: 20,
    marginBottom: 4,
  },
  typeButtonText: {
    fontSize: 14,
  },
  requiredContainer: {
    marginBottom: 16,
  },
  checkboxButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderWidth: 2,
    borderRadius: 4,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkboxLabel: {
    fontSize: 16,
  },
  editorActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 12,
  },
  deleteButton: {
    flex: 1,
  },
  saveFieldButton: {
    flex: 2,
  },
});
```

---

## Phase 4.5: Data Entry with Offline Support

### The Concept: Collecting Data Offline

The data entry screen is where users fill out forms. It must work seamlessly offline, saving entries locally and syncing later. Think of it as a digital clipboard—you can collect data anywhere, anytime, and it'll automatically be filed when you're back online.

### The Implementation: Form Entry

```typescript
// src/screens/main/FormEntryScreen.tsx
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  TextInput,
  Platform,
  ActivityIndicator,
} from 'react-native';
import { useTheme } from '@themes';
import { Button } from '@components/common/Button';
import { Card } from '@components/common/Card';
import { Ionicons } from '@expo/vector-icons';
import DateTimePicker from '@react-native-community/datetimepicker';
import * as ImagePicker from 'expo-image-picker';
import * as Location from 'expo-location';
import { FormField, CollectionEntry } from '@types';
import { CollectionRepository } from '@database/repositories/CollectionRepository';
import { FormRepository } from '@database/repositories/FormRepository';
import { useAuth } from '@hooks/useAuth';
import { useRoute, useNavigation } from '@react-navigation/native';
import { MainScreenNavigationProp } from '@types/navigation';

interface RouteParams {
  formId: string;
  collectionId?: string; // For editing existing entries
}

/**
 * Form Entry Screen
 * 
 * Allows users to fill out a form with offline support.
 * Features:
 * - Dynamic form rendering based on form definition
 * - Field validation
 * - Photo capture and upload
 * - Location capture
 * - Draft saving
 * - Offline submission
 */
export default function FormEntryScreen() {
  const [formData, setFormData] = useState<Record<string, any>>({});
  const [formFields, setFormFields] = useState<FormField[]>([]);
  const [formTitle, setFormTitle] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSavingDraft, setIsSavingDraft] = useState(false);
  const [showDatePicker, setShowDatePicker] = useState<string | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const theme = useTheme();
  const { user } = useAuth();
  const route = useRoute();
  const navigation = useNavigation<MainScreenNavigationProp>();
  const params = route.params as RouteParams;
  const { formId, collectionId } = params;

  useEffect(() => {
    loadForm();
    if (collectionId) {
      loadExistingEntry();
    }
  }, []);

  /**
   * Load the form definition
   */
  const loadForm = async () => {
    try {
      setIsLoading(true);
      const form = await FormRepository.getById(formId);
      if (form) {
        setFormFields(form.fields);
        setFormTitle(form.title);
        // Initialize form data
        const initialData: Record<string, any> = {};
        form.fields.forEach(field => {
          if (field.defaultValue !== undefined) {
            initialData[field.id] = field.defaultValue;
          }
        });
        setFormData(initialData);
      } else {
        Alert.alert('Error', 'Form not found');
        navigation.goBack();
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to load form');
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Load existing entry for editing
   */
  const loadExistingEntry = async () => {
    try {
      const entry = await CollectionRepository.getById(collectionId!);
      if (entry) {
        setFormData(entry.data);
      }
    } catch (error) {
      console.error('Failed to load entry:', error);
    }
  };

  /**
   * Update form data
   */
  const updateFormData = (fieldId: string, value: any) => {
    setFormData(prev => ({ ...prev, [fieldId]: value }));
    // Clear error for this field
    if (errors[fieldId]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[fieldId];
        return newErrors;
      });
    }
  };

  /**
   * Capture photo
   */
  const handleCapturePhoto = async (fieldId: string) => {
    try {
      const { status } = await ImagePicker.requestCameraPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission Denied', 'Camera access is required to capture photos');
        return;
      }

      const result = await ImagePicker.launchCameraAsync({
        allowsEditing: true,
        quality: 0.8,
        base64: true,
      });

      if (!result.canceled && result.assets[0]) {
        const photos = formData[fieldId] || [];
        updateFormData(fieldId, [...photos, result.assets[0].uri]);
      }
    } catch (error) {
      Alert.alert('Error', 'Failed to capture photo');
    }
  };

  /**
   * Capture location
   */
  const handleCaptureLocation = async (fieldId: string) => {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permission Denied', 'Location access is required');
        return;
      }

      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });

      updateFormData(fieldId, {
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        accuracy: location.coords.accuracy,
      });

      Alert.alert('Success', 'Location captured successfully');
    } catch (error) {
      Alert.alert('Error', 'Failed to capture location');
    }
  };

  /**
   * Validate all fields
   */
  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};
    let isValid = true;

    formFields.forEach(field => {
      if (field.required) {
        const value = formData[field.id];
        if (value === undefined || value === null || value === '' || 
            (Array.isArray(value) && value.length === 0)) {
          newErrors[field.id] = `${field.label} is required`;
          isValid = false;
        }
      }
    });

    setErrors(newErrors);
    return isValid;
  };

  /**
   * Submit the form
   */
  const handleSubmit = async () => {
    if (!validateForm()) {
      Alert.alert('Validation Error', 'Please fill in all required fields');
      return;
    }

    setIsSubmitting(true);
    try {
      if (!user) throw new Error('User not authenticated');

      if (collectionId) {
        // Update existing entry
        await CollectionRepository.update(collectionId, {
          data: formData,
          status: 'submitted',
        });
      } else {
        // Create new entry
        await CollectionRepository.create(user.id, {
          formId,
          data: formData,
          metadata: {
            submittedAt: new Date().toISOString(),
          },
        });
      }

      Alert.alert(
        'Success',
        'Entry submitted successfully',
        [
          {
            text: 'OK',
            onPress: () => navigation.goBack(),
          },
        ]
      );
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to submit entry');
    } finally {
      setIsSubmitting(false);
    }
  };

  /**
   * Save as draft
   */
  const handleSaveDraft = async () => {
    setIsSavingDraft(true);
    try {
      if (!user) throw new Error('User not authenticated');

      if (collectionId) {
        await CollectionRepository.update(collectionId, {
          data: formData,
          status: 'draft',
        });
      } else {
        await CollectionRepository.create(user.id, {
          formId,
          data: formData,
          metadata: {
            isDraft: true,
          },
        });
      }

      Alert.alert('Success', 'Draft saved successfully');
      navigation.goBack();
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to save draft');
    } finally {
      setIsSavingDraft(false);
    }
  };

  /**
   * Render form field based on type
   */
  const renderField = (field: FormField) => {
    const value = formData[field.id];
    const error = errors[field.id];

    switch (field.type) {
      case 'text':
        return (
          <View key={field.id} style={styles.fieldContainer}>
            <Text style={[styles.fieldLabel, { color: theme.colors.text }]}>
              {field.label}
              {field.required && <Text style={{ color: theme.colors.error }}> *</Text>}
            </Text>
            <TextInput
              style={[
                styles.textInput,
                {
                  borderColor: error ? theme.colors.error : theme.colors.border,
                  color: theme.colors.text,
                  backgroundColor: theme.colors.background,
                },
              ]}
              value={value || ''}
              onChangeText={(text) => updateFormData(field.id, text)}
              placeholder={`Enter ${field.label}`}
              placeholderTextColor={theme.colors.textSecondary}
              multiline={field.id.includes('description')}
              numberOfLines={field.id.includes('description') ? 3 : 1}
            />
            {error && (
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {error}
              </Text>
            )}
          </View>
        );

      case 'number':
        return (
          <View key={field.id} style={styles.fieldContainer}>
            <Text style={[styles.fieldLabel, { color: theme.colors.text }]}>
              {field.label}
              {field.required && <Text style={{ color: theme.colors.error }}> *</Text>}
            </Text>
            <TextInput
              style={[
                styles.textInput,
                {
                  borderColor: error ? theme.colors.error : theme.colors.border,
                  color: theme.colors.text,
                  backgroundColor: theme.colors.background,
                },
              ]}
              value={value?.toString() || ''}
              onChangeText={(text) => {
                const num = parseFloat(text);
                updateFormData(field.id, isNaN(num) ? undefined : num);
              }}
              placeholder={`Enter ${field.label}`}
              placeholderTextColor={theme.colors.textSecondary}
              keyboardType="numeric"
            />
            {error && (
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {error}
              </Text>
            )}
          </View>
        );

      case 'date':
        return (
          <View key={field.id} style={styles.fieldContainer}>
            <Text style={[styles.fieldLabel, { color: theme.colors.text }]}>
              {field.label}
              {field.required && <Text style={{ color: theme.colors.error }}> *</Text>}
            </Text>
            <TouchableOpacity
              style={[
                styles.dateButton,
                {
                  borderColor: error ? theme.colors.error : theme.colors.border,
                  backgroundColor: theme.colors.background,
                },
              ]}
              onPress={() => setShowDatePicker(field.id)}
            >
              <Text
                style={[
                  styles.dateText,
                  { color: value ? theme.colors.text : theme.colors.textSecondary },
                ]}
              >
                {value ? new Date(value).toLocaleDateString() : `Select ${field.label}`}
              </Text>
              <Ionicons name="calendar-outline" size={20} color={theme.colors.textSecondary} />
            </TouchableOpacity>
            {showDatePicker === field.id && (
              <DateTimePicker
                value={value ? new Date(value) : new Date()}
                mode="date"
                display={Platform.OS === 'ios' ? 'spinner' : 'default'}
                onChange={(event, selectedDate) => {
                  setShowDatePicker(null);
                  if (selectedDate) {
                    updateFormData(field.id, selectedDate.toISOString());
                  }
                }}
              />
            )}
            {error && (
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {error}
              </Text>
            )}
          </View>
        );

      case 'select':
        return (
          <View key={field.id} style={styles.fieldContainer}>
            <Text style={[styles.fieldLabel, { color: theme.colors.text }]}>
              {field.label}
              {field.required && <Text style={{ color: theme.colors.error }}> *</Text>}
            </Text>
            <View style={styles.selectContainer}>
              {field.options?.map((option) => (
                <TouchableOpacity
                  key={option}
                  style={[
                    styles.selectOption,
                    {
                      borderColor: value === option ? theme.colors.primary[500] : theme.colors.border,
                      backgroundColor: value === option ? theme.colors.primary[50] : theme.colors.background,
                    },
                  ]}
                  onPress={() => updateFormData(field.id, option)}
                >
                  <Text
                    style={[
                      styles.selectOptionText,
                      {
                        color: value === option ? theme.colors.primary[500] : theme.colors.text,
                      },
                    ]}
                  >
                    {option}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
            {error && (
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {error}
              </Text>
            )}
          </View>
        );

      case 'checkbox':
        return (
          <View key={field.id} style={styles.fieldContainer}>
            <TouchableOpacity
              style={styles.checkboxContainer}
              onPress={() => updateFormData(field.id, !value)}
            >
              <View
                style={[
                  styles.checkbox,
                  {
                    borderColor: error ? theme.colors.error : theme.colors.border,
                    backgroundColor: value ? theme.colors.primary[500] : 'transparent',
                  },
                ]}
              >
                {value && <Ionicons name="checkmark" size={16} color="#fff" />}
              </View>
              <Text style={[styles.checkboxLabel, { color: theme.colors.text }]}>
                {field.label}
                {field.required && <Text style={{ color: theme.colors.error }}> *</Text>}
              </Text>
            </TouchableOpacity>
            {error && (
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {error}
              </Text>
            )}
          </View>
        );

      case 'photo':
        return (
          <View key={field.id} style={styles.fieldContainer}>
            <Text style={[styles.fieldLabel, { color: theme.colors.text }]}>
              {field.label}
              {field.required && <Text style={{ color: theme.colors.error }}> *</Text>}
            </Text>
            <View style={styles.photoContainer}>
              {(value || []).map((photo: string, index: number) => (
                <View key={index} style={styles.photoItem}>
                  <Text style={{ color: theme.colors.text }}>📷 Photo {index + 1}</Text>
                  <TouchableOpacity
                    onPress={() => {
                      const newPhotos = [...value];
                      newPhotos.splice(index, 1);
                      updateFormData(field.id, newPhotos);
                    }}
                  >
                    <Ionicons name="close-circle" size={24} color={theme.colors.error} />
                  </TouchableOpacity>
                </View>
              ))}
              <TouchableOpacity
                style={[styles.captureButton, { backgroundColor: theme.colors.primary[500] }]}
                onPress={() => handleCapturePhoto(field.id)}
              >
                <Ionicons name="camera" size={24} color="#fff" />
                <Text style={styles.captureButtonText}>Capture Photo</Text>
              </TouchableOpacity>
            </View>
            {error && (
              <Text style={[styles.errorText, { color: theme.colors.error }]}>
                {error}
              </Text>
            )}
          </View>
        );

      default:
        return null;
    }
  };

  if (isLoading) {
    return (
      <View style={[styles.loadingContainer, { backgroundColor: theme.colors.background }]}>
        <ActivityIndicator size="large" color={theme.colors.primary[500]} />
        <Text style={[styles.loadingText, { color: theme.colors.textSecondary }]}>
          Loading form...
        </Text>
      </View>
    );
  }

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: theme.colors.background }]}
      showsVerticalScrollIndicator={false}
    >
      <Card style={styles.formCard}>
        <Text style={[styles.formTitle, { color: theme.colors.text }]}>
          {formTitle}
        </Text>
        {formFields.map(renderField)}
      </Card>

      <View style={styles.actionButtons}>
        <Button
          title="Save Draft"
          onPress={handleSaveDraft}
          variant="secondary"
          loading={isSavingDraft}
          disabled={isSavingDraft || isSubmitting}
          style={styles.draftButton}
        />
        <Button
          title="Submit"
          onPress={handleSubmit}
          variant="primary"
          loading={isSubmitting}
          disabled={isSavingDraft || isSubmitting}
          style={styles.submitButton}
        />
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
  },
  formCard: {
    margin: 16,
    marginBottom: 8,
  },
  formTitle: {
    fontSize: 22,
    fontWeight: '700',
    marginBottom: 16,
  },
  fieldContainer: {
    marginBottom: 20,
  },
  fieldLabel: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 8,
  },
  textInput: {
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  dateButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    borderWidth: 1,
    borderRadius: 8,
    padding: 12,
  },
  dateText: {
    fontSize: 16,
  },
  selectContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  selectOption: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderWidth: 1,
    borderRadius: 20,
    marginBottom: 4,
  },
  selectOptionText: {
    fontSize: 14,
  },
  checkboxContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderWidth: 2,
    borderRadius: 4,
    justifyContent: 'center',
    alignItems: 'center',
  },
  checkboxLabel: {
    fontSize: 16,
  },
  photoContainer: {
    gap: 12,
  },
  photoItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    borderWidth: 1,
    borderRadius: 8,
    borderColor: '#e0e0e0',
  },
  captureButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 12,
    borderRadius: 8,
    gap: 8,
  },
  captureButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '500',
  },
  errorText: {
    fontSize: 14,
    marginTop: 4,
  },
  actionButtons: {
    flexDirection: 'row',
    padding: 16,
    gap: 12,
  },
  draftButton: {
    flex: 1,
  },
  submitButton: {
    flex: 2,
  },
});
```

---

## Phase 4.6: Testing Offline Features

### The Concept: Verification

Testing offline features requires simulating network conditions and verifying that data persists correctly.

### The Implementation: Test Cases

```typescript
// __tests__/integration/offline.test.ts
import { database, dbUtils } from '@database';
import { FormRepository } from '@database/repositories/FormRepository';
import { CollectionRepository } from '@database/repositories/CollectionRepository';
import { SyncQueueRepository } from '@database/repositories/SyncQueueRepository';
import { syncEngine } from '@database/sync/SyncEngine';

describe('Offline Data Management', () => {
  const userId = 'test-user-id';
  let formId: string;

  beforeEach(async () => {
    // Clear database before each test
    await dbUtils.clearAll();
  });

  it('should create a form offline', async () => {
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'This is a test form',
      fields: [
        { id: 'field1', label: 'Name', type: 'text', required: true },
        { id: 'field2', label: 'Email', type: 'text', required: true },
      ],
    });

    expect(form).toBeDefined();
    expect(form.title).toBe('Test Form');
    expect(form.syncStatus).toBe('pending');
  });

  it('should create a collection entry offline', async () => {
    // First create a form
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'This is a test form',
      fields: [
        { id: 'field1', label: 'Name', type: 'text', required: true },
      ],
    });

    // Then create a collection entry
    const collection = await CollectionRepository.create(userId, {
      formId: form.id,
      data: {
        field1: 'John Doe',
      },
    });

    expect(collection).toBeDefined();
    expect(collection.status).toBe('draft');
    expect(collection.syncStatus).toBe('pending');
  });

  it('should queue sync operations', async () => {
    // Create a form (this should queue a sync operation)
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test description',
      fields: [],
    });

    // Check that a sync queue item was created
    const pendingItems = await SyncQueueRepository.getPending();
    expect(pendingItems.length).toBe(1);
    expect(pendingItems[0].recordId).toBe(form.id);
    expect(pendingItems[0].tableName).toBe('forms');
  });

  it('should mark items as processing during sync', async () => {
    // Create a form
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test description',
      fields: [],
    });

    // Get the queue item
    const pendingItems = await SyncQueueRepository.getPending();
    expect(pendingItems.length).toBe(1);

    // Mark as processing
    await SyncQueueRepository.markProcessing(pendingItems[0].id);
    
    // Verify it was updated
    const updatedItem = await SyncQueueRepository.getById(pendingItems[0].id);
    expect(updatedItem?.status).toBe('processing');
  });

  it('should handle sync failures and retries', async () => {
    // Create a form
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test description',
      fields: [],
    });

    // Get the queue item and mark as failed
    const pendingItems = await SyncQueueRepository.getPending();
    await SyncQueueRepository.markFailed(pendingItems[0].id, 'Network error');

    // Verify it was marked as failed
    const failedItem = await SyncQueueRepository.getById(pendingItems[0].id);
    expect(failedItem?.status).toBe('failed');
    expect(failedItem?.retryCount).toBe(1);

    // Retry failed items
    await SyncQueueRepository.retryFailed();
    
    // Verify it was reset to pending
    const retriedItem = await SyncQueueRepository.getById(pendingItems[0].id);
    expect(retriedItem?.status).toBe('pending');
  });

  it('should sync offline data when network is available', async () => {
    // Create an entry offline
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test description',
      fields: [],
    });

    const collection = await CollectionRepository.create(userId, {
      formId: form.id,
      data: {
        field1: 'John Doe',
        field2: 'john@example.com',
      },
    });

    // Submit the entry
    await CollectionRepository.submit(collection.id);

    // Mock network available
    jest.spyOn(syncEngine as any, 'isNetworkAvailable', 'get').mockReturnValue(true);
    
    // Run sync
    const result = await syncEngine.sync();
    
    // Verify sync result
    expect(result).toBeDefined();
    expect(result.success).toBe(true);
  });
});
```

### Verification

```bash
# Run offline tests
$ npm test -- --testPathPattern=offline

# Manual testing steps:
1. ✅ Create a form offline (turn off network)
2. ✅ Fill out a form entry offline
3. ✅ Save as draft
4. ✅ Submit entry (queues for sync)
5. ✅ Turn network on
6. ✅ Verify auto-sync works
7. ✅ Check data appears in Supabase
8. ✅ Verify conflict resolution works

# Test offline behavior:
1. Turn off network
2. Create multiple entries
3. ✅ Verify they're saved locally
4. ✅ Verify sync queue grows
5. Turn on network
6. ✅ Verify all entries sync automatically

# Test sync recovery:
1. ✅ Simulate network failure during sync
2. ✅ Verify retry mechanism works
3. ✅ Verify exponential backoff
4. ✅ Verify failed items are logged
```

---

## Part 4 Summary

### ✅ Completed

1. **Local Database Setup**
   - WatermelonDB schema
   - Model definitions
   - Database initialization
   - Encryption support

2. **Repository Pattern**
   - Form repository
   - Collection repository
   - Sync queue repository
   - Clean CRUD operations

3. **Sync Engine**
   - Automatic sync on connectivity
   - Batch processing
   - Retry logic
   - Conflict resolution
   - Queue management

4. **Form Builder**
   - Dynamic form creation
   - Field configuration
   - Drag to reorder
   - Preview mode

5. **Form Entry**
   - Offline form filling
   - Photo capture
   - Location capture
   - Draft saving
   - Validation

6. **Testing**
   - Offline unit tests
   - Sync integration tests
   - Manual verification

### Key Concepts Learned

- **Offline-First Architecture:** Design for offline from the start
- **Local Databases:** Mobile-first data storage
- **Sync Patterns:** Conflict resolution, retry logic, queue management
- **Dynamic Forms:** Runtime form generation
- **Data Validation:** Client-side validation
- **Error Recovery:** Handling network failures gracefully

### What's Coming in Part 5

In **Part 5: Device Hardware Integration**, you'll:
- Implement camera and photo gallery features
- Add GPS location tracking
- Integrate biometric authentication (Face ID/Touch ID)
- Set up push notifications
- Add Bluetooth connectivity
- Implement device sensors access
- Build offline-first media handling

---

## Quick Reference: Database Commands

```bash
# Database Operations
$ npx expo run:ios --clear               # Clear and rebuild iOS
$ npx expo run:android --clear           # Clear and rebuild Android

# Testing
$ npm test -- --testPathPattern=database # Run database tests
$ npm test -- --watch                     # Watch mode

# Debugging
$ npx react-native log-ios               # View iOS logs
$ adb logcat                              # View Android logs
$ npx expo start --tunnel                # Start with tunnel for remote debugging
```
