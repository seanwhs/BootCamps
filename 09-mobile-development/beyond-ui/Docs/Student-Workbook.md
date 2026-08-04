# Mastering Mobile Development Beyond the UI
## Student Workbook

Welcome to the comprehensive student workbook for the "Mastering Mobile Development Beyond the UI" tutorial series. This workbook is designed to accompany the course materials and provide hands-on exercises, note-taking sections, code practice spaces, and self-assessment tools.

---

## HOW TO USE THIS WORKBOOK

1. **Before Each Module:** Review the learning objectives and complete the pre-assessment
2. **During the Module:** Take notes in the provided sections and complete code exercises
3. **After the Module:** Complete the review questions and practical exercises
4. **Track Your Progress:** Use the progress tracker to monitor your learning

---

## TABLE OF CONTENTS

**MODULE 0: Introduction & Course Setup** (Page 4)
- Learning Objectives
- Pre-Assessment
- Environment Setup Checklist
- Course Notes

**MODULE 1: Native Foundations & Build Environments** (Page 8)
- Learning Objectives
- Pre-Assessment
- Guided Exercises
- Code Practice
- Review Questions
- Self-Assessment

**MODULE 2: Project Architecture & Core Setup** (Page 16)
- Learning Objectives
- Pre-Assessment
- Guided Exercises
- Code Practice
- Review Questions
- Self-Assessment

**MODULE 3: Backend Integration & Authentication** (Page 24)
- Learning Objectives
- Pre-Assessment
- Guided Exercises
- Code Practice
- Review Questions
- Self-Assessment

**MODULE 4: Data Management & Offline Sync** (Page 32)
- Learning Objectives
- Pre-Assessment
- Guided Exercises
- Code Practice
- Review Questions
- Self-Assessment

**MODULE 5: Hardware Integration** (Page 40)
- Learning Objectives
- Pre-Assessment
- Guided Exercises
- Code Practice
- Review Questions
- Self-Assessment

**MODULE 6: Testing & Quality Assurance** (Page 48)
- Learning Objectives
- Pre-Assessment
- Guided Exercises
- Code Practice
- Review Questions
- Self-Assessment

**MODULE 7: Security & Production Deployment** (Page 56)
- Learning Objectives
- Pre-Assessment
- Guided Exercises
- Code Practice
- Review Questions
- Self-Assessment

**FINAL PROJECT WORKSHEETS** (Page 64)
- Project Plan
- Architecture Design
- Implementation Checklist
- Code Review Checklist

**APPENDICES**
- Appendix A: Command Reference
- Appendix B: Code Snippet Library
- Appendix C: Troubleshooting Guide
- Appendix D: Glossary of Terms

---

## MODULE 0: INTRODUCTION & COURSE SETUP

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Understand the course structure and learning outcomes
- [ ] Set up your development environment
- [ ] Install all required software and tools
- [ ] Verify your environment is working correctly
- [ ] Understand the NexusCollect project architecture

### Pre-Assessment

**Rate your current knowledge (1-5):**
- React Native Basics: ___ 1 2 3 4 5
- JavaScript/TypeScript: ___ 1 2 3 4 5
- Mobile Development: ___ 1 2 3 4 5
- Git/GitHub: ___ 1 2 3 4 5
- API Integration: ___ 1 2 3 4 5

**What are your goals for this course?**

1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

---

### Environment Setup Checklist

#### Hardware Requirements
- [ ] Computer (Mac for iOS development, Windows/Linux for Android)
- [ ] Minimum 8GB RAM (16GB recommended)
- [ ] 15GB+ free storage space

#### Software Installation

**MacOS Users Only:**
- [ ] Xcode (from Mac App Store) - ~12GB
- [ ] Xcode Command Line Tools: `xcode-select --install`
- [ ] CocoaPods: `sudo gem install cocoapods`
- [ ] iOS Simulator (via Xcode)
- [ ] **Verification:** `pod --version` → Output: _____________

**All Users:**
- [ ] Node.js v18+ - `node --version` → Output: _____________
- [ ] npm v9+ - `npm --version` → Output: _____________
- [ ] Git - `git --version` → Output: _____________
- [ ] Watchman - `watchman --version` → Output: _____________
- [ ] Android Studio (for Android development)
- [ ] Android SDK Platform 33+
- [ ] Android Emulator configured

**Environment Variables (Android):**
- [ ] ANDROID_HOME set: `echo $ANDROID_HOME` → Output: _____________
- [ ] PATH includes Android tools: `echo $PATH` → Contains: _____________

**Accounts:**
- [ ] GitHub Account
- [ ] Supabase Account
- [ ] Apple Developer Account (free tier, optional)
- [ ] Google Play Developer Account ($25, optional)

---

### Course Notes

#### Key Concepts

**What is React Native?**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**What is Expo?**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**What is the New Architecture?**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

#### Architecture Overview

Draw the NexusCollect architecture diagram:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Key Technologies

| Technology | Purpose | Your Notes |
|------------|---------|------------|
| React Native | | |
| Expo | | |
| TypeScript | | |
| Zustand | | |
| Supabase | | |
| WatermelonDB | | |
| Detox | | |

---

### Module 0 Self-Assessment

| Learning Objective | Not Started | In Progress | Completed |
|-------------------|-------------|-------------|-----------|
| Understand course structure | ☐ | ☐ | ☐ |
| Set up development environment | ☐ | ☐ | ☐ |
| Install all required software | ☐ | ☐ | ☐ |
| Verify environment is working | ☐ | ☐ | ☐ |
| Understand NexusCollect architecture | ☐ | ☐ | ☐ |

**Troubleshooting Notes:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Questions for the Instructor:**
1. _________________________________________________
2. _________________________________________________

---

## MODULE 1: NATIVE FOUNDATIONS & BUILD ENVIRONMENTS

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Understand mobile platform architecture
- [ ] Set up professional development environments
- [ ] Configure code signing and certificates
- [ ] Create native modules in Swift and Kotlin
- [ ] Run React Native apps on devices and simulators

### Pre-Assessment

**True or False:**
1. React Native only works on Android. ___ T / F
2. CocoaPods is a dependency manager for iOS. ___ T / F
3. Android Studio is required for React Native Android development. ___ T / F
4. The Bridge is part of React Native's New Architecture. ___ T / F
5. Native modules allow JavaScript to call native code. ___ T / F

**Fill in the blanks:**
6. The command to create a new Expo project with TypeScript is _____________
7. The environment variable for Android SDK location is _____________
8. iOS development requires a computer running _____________
9. The _____________ is React Native's communication layer between JS and native
10. Native modules in iOS are written in _____________

---

### Guided Exercises

#### Exercise 1.1: Project Creation

**Step 1: Create a new project**

```bash
# Write your commands here:
_________________________________________________
_________________________________________________
```

**Step 2: Verify the project structure**

```bash
# List the project contents:
_________________________________________________
```

**Expected output:** (Write what you see)
_________________________________________________
_________________________________________________

**What did you learn?**
_________________________________________________
_________________________________________________

---

#### Exercise 1.2: Running the App

**Step 1: Start the development server**

```bash
# Write your command:
_________________________________________________
```

**Step 2: Run on iOS Simulator (Mac only)**

```bash
# Write your command:
_________________________________________________
```

**Step 3: Run on Android Emulator**

```bash
# Write your command:
_________________________________________________
```

**What worked? What didn't?**
_________________________________________________
_________________________________________________

---

#### Exercise 1.3: Native Module Creation

**iOS Native Module (Swift):**

```swift
// Write the code for DeviceInfoModule.swift
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

**Android Native Module (Kotlin):**

```kotlin
// Write the code for DeviceInfoModule.kt
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

**JavaScript Usage:**

```typescript
// Write the code to call the native module
_________________________________________________
_________________________________________________
```

---

### Code Practice

#### Practice 1.1: Fix the Code

**The following code has errors. Fix them:**

```typescript
// ERROR: This code has issues
import { NativeModules } from 'react-native';

const DeviceInfoModule = NativeModules.DeviceInfoModule;

// Missing error handling
DeviceInfoModule.getDeviceInfo.then(info => console.log(info));

// FIXED VERSION:
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

#### Practice 1.2: Complete the Code

**Complete the Android native module:**

```kotlin
// Complete the missing parts
class DeviceInfoModule(reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {
    
    override fun getName(): String {
        // Return the module name
        _________________________________
    }
    
    @ReactMethod
    fun getDeviceInfo(promise: Promise) {
        // Get device information
        // Hint: Use Build class
        _________________________________
        _________________________________
        _________________________________
    }
}
```

---

#### Practice 1.3: Debug the Build

**You encounter this error: "xcodebuild: command not found"**

What is the cause?
_________________________________________________

How do you fix it?
_________________________________________________

---

### Review Questions

**Multiple Choice:**

1. Which of the following is required for iOS development?
   - A) Android Studio
   - B) Xcode
   - C) Visual Studio Code
   - D) Eclipse

**Answer:** ______

2. What is the purpose of CocoaPods?
   - A) To compile Swift code
   - B) To manage iOS dependencies
   - C) To run the iOS simulator
   - D) To sign iOS applications

**Answer:** ______

3. Which command creates a new Expo project with TypeScript?
   - A) `npx react-native init MyApp`
   - B) `expo init MyApp`
   - C) `npx create-expo-app MyApp --template`
   - D) `npm init expo MyApp`

**Answer:** ______

**Short Answer:**

4. What is the React Native Bridge and what does it do?
_________________________________________________________________
_________________________________________________________________

5. What are the steps to create an Android native module?
_________________________________________________________________
_________________________________________________________________

6. What is code signing and why is it important?
_________________________________________________________________
_________________________________________________________________

---

### Self-Assessment

| Skill | Not Started | Developing | Proficient | Expert |
|-------|-------------|------------|------------|--------|
| Xcode installation and setup | ☐ | ☐ | ☐ | ☐ |
| Android Studio configuration | ☐ | ☐ | ☐ | ☐ |
| Creating React Native projects | ☐ | ☐ | ☐ | ☐ |
| Running on simulators/devices | ☐ | ☐ | ☐ | ☐ |
| Creating native modules | ☐ | ☐ | ☐ | ☐ |
| Code signing configuration | ☐ | ☐ | ☐ | ☐ |

**What I Found Challenging:**
_________________________________________________________________
_________________________________________________________________

**What I Found Interesting:**
_________________________________________________________________
_________________________________________________________________

**Questions I Still Have:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

---

## MODULE 2: PROJECT ARCHITECTURE & CORE SETUP

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Design application architecture with separation of concerns
- [ ] Set up navigation with React Navigation
- [ ] Implement state management with Zustand
- [ ] Build theme and styling system
- [ ] Create reusable base components

### Pre-Assessment

**Match the concept to its description:**

| Concept | Description |
|---------|-------------|
| ___ Zustand | A. Mobile navigation system |
| ___ React Navigation | B. State management library |
| ___ Separation of Concerns | C. Styling and theming |
| ___ Theme System | D. Architecture principle |
| ___ Repository Pattern | E. Data access abstraction |

**Fill in the blanks:**
6. The command to install React Navigation is _____________
7. Zustand uses the _____________ pattern for state selection
8. Path aliases are configured in _____________
9. The _____________ component provides theme context
10. Base components are stored in the _____________ folder

---

### Guided Exercises

#### Exercise 2.1: Folder Structure Creation

**Create the complete folder structure:**

```bash
# Write your commands here:
mkdir -p src/
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

**Verify the structure:**

```bash
# List the src directory:
_________________________________________________
```

**Expected output:**
_________________________________________________
_________________________________________________

---

#### Exercise 2.2: Navigation Setup

**Create the navigation types:**

```typescript
// src/types/navigation.ts
// Define the AuthStackParamList
_________________________________________________
_________________________________________________
_________________________________________________

// Define the MainTabParamList
_________________________________________________
_________________________________________________
_________________________________________________

// Define the RootStackParamList
_________________________________________________
_________________________________________________
_________________________________________________
```

**Create the AuthStack:**

```typescript
// src/navigation/stacks/AuthStack.tsx
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Write the complete AuthStack component
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

#### Exercise 2.3: Zustand Store Creation

**Create the Auth Store:**

```typescript
// src/store/slices/authSlice.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

// Define the AuthStore interface
_________________________________________________
_________________________________________________
_________________________________________________

// Create the store
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

**Create the Settings Store:**

```typescript
// src/store/slices/settingsSlice.ts
// Write the complete settings store
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

### Code Practice

#### Practice 2.1: Complete the Theme System

**Complete the theme colors:**

```typescript
// src/themes/colors.ts
export const colors = {
  primary: {
    50: '#e8f4fd',
    // Add other primary shades
    _________________________________
    _________________________________
    _________________________________
  },
  secondary: {
    // Define secondary colors
    _________________________________
    _________________________________
  },
  gray: {
    // Define gray scale
    _________________________________
    _________________________________
  },
  // Add semantic colors
  success: _____________,
  warning: _____________,
  error: _____________,
  background: _____________,
  text: _____________,
};
```

---

#### Practice 2.2: Build the Button Component

**Complete the Button component:**

```typescript
// src/components/common/Button.tsx
interface ButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'small' | 'medium' | 'large';
  loading?: boolean;
  disabled?: boolean;
}

const Button: React.FC<ButtonProps> = ({
  title,
  onPress,
  variant = 'primary',
  size = 'medium',
  loading = false,
  disabled = false,
}) => {
  // Get the theme
  const theme = useTheme();
  
  // Get variant styles
  const getVariantStyles = () => {
    // Implement variant styles
    _________________________________
    _________________________________
  };
  
  // Get size styles
  const getSizeStyles = () => {
    // Implement size styles
    _________________________________
    _________________________________
  };
  
  return (
    // Implement the button JSX
    _________________________________
    _________________________________
    _________________________________
  );
};
```

---

### Review Questions

**Multiple Choice:**

1. Which library is recommended for navigation in React Native?
   - A) React Router
   - B) React Navigation
   - C) React Router Native
   - D) Expo Router

**Answer:** ______

2. What is Zustand primarily used for?
   - A) Navigation
   - B) State Management
   - C) API Calls
   - D) UI Rendering

**Answer:** ______

3. What is the purpose of the `create()` function in Zustand?
   - A) To create a new component
   - B) To create a new store
   - C) To create a new navigation stack
   - D) To create a new theme

**Answer:** ______

**Short Answer:**

4. Explain the Separation of Concerns principle in application architecture.
_________________________________________________________________
_________________________________________________________________

5. How does Zustand's selector pattern prevent unnecessary re-renders?
_________________________________________________________________
_________________________________________________________________

6. What are the benefits of using a theme system?
_________________________________________________________________
_________________________________________________________________

---

### Self-Assessment

| Skill | Not Started | Developing | Proficient | Expert |
|-------|-------------|------------|------------|--------|
| Folder structure design | ☐ | ☐ | ☐ | ☐ |
| Navigation setup | ☐ | ☐ | ☐ | ☐ |
| Zustand store creation | ☐ | ☐ | ☐ | ☐ |
| Theme system implementation | ☐ | ☐ | ☐ | ☐ |
| Base component creation | ☐ | ☐ | ☐ | ☐ |
| Path alias configuration | ☐ | ☐ | ☐ | ☐ |

**Code I'm Proud Of:**
_________________________________________________
_________________________________________________

**What I Need to Practice:**
_________________________________________________
_________________________________________________

---

## MODULE 3: BACKEND INTEGRATION & AUTHENTICATION

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Configure Supabase backend services
- [ ] Implement email/password authentication
- [ ] Add social login (Google, Apple)
- [ ] Set up Row Level Security (RLS)
- [ ] Manage user sessions securely

### Pre-Assessment

**True or False:**
1. Supabase uses PostgreSQL as its database. ___ T / F
2. RLS stands for Row Level Security. ___ T / F
3. Social login is not supported by Supabase. ___ T / F
4. JWT tokens are used for authentication in Supabase. ___ T / F
5. Supabase requires a separate server for real-time features. ___ T / F

**Fill in the blanks:**
6. The method to sign in with email/password is _____________
7. Supabase's real-time feature uses _____________
8. The Supabase client can be configured with a _____________ adapter
9. User metadata is stored in _____________
10. The _____________ option enables automatic token refresh

---

### Guided Exercises

#### Exercise 3.1: Supabase Schema Creation

**Write the SQL to create the profiles table:**

```sql
-- Create profiles table
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

**Write the RLS policies for profiles:**

```sql
-- Enable RLS
_________________________________________________

-- Create SELECT policy
_________________________________________________
_________________________________________________

-- Create UPDATE policy
_________________________________________________
_________________________________________________
```

---

#### Exercise 3.2: Authentication Service

**Complete the authentication service:**

```typescript
// src/api/services/authService.ts
import { supabase } from '@api/supabase';

export interface LoginCredentials {
  // Define the interface
  _________________________________
  _________________________________
}

export interface RegisterData {
  // Define the interface
  _________________________________
  _________________________________
}

export const authService = {
  login: async (credentials: LoginCredentials) => {
    // Implement login
    _________________________________
    _________________________________
    _________________________________
  },
  
  register: async (data: RegisterData) => {
    // Implement registration
    _________________________________
    _________________________________
    _________________________________
  },
  
  resetPassword: async (email: string) => {
    // Implement password reset
    _________________________________
  },
};
```

---

#### Exercise 3.3: Login Screen

**Complete the Login Screen:**

```typescript
// src/screens/auth/LoginScreen.tsx
function LoginScreen() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login, isLoading, error } = useAuth();
  const navigation = useNavigation();

  const validate = () => {
    // Implement validation
    _________________________________
    _________________________________
  };

  const handleLogin = async () => {
    // Implement login handler
    _________________________________
    _________________________________
  };

  return (
    // Implement the UI
    _________________________________
    _________________________________
    _________________________________
  );
}
```

---

### Code Practice

#### Practice 3.1: Fix the Code

**The following code has errors. Fix them:**

```typescript
// ERROR: This code has issues
const handleLogin = () => {
  login(email, password);
  navigation.navigate('Main');
};

// FIXED VERSION:
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

#### Practice 3.2: Complete the Code

**Complete the social login handler:**

```typescript
const handleGoogleLogin = async () => {
  try {
    // 1. Start Google OAuth flow
    _________________________________
    
    if (result?.type === 'success') {
      // 2. Extract tokens
      _________________________________
      
      // 3. Sign in with Supabase
      _________________________________
      
      // 4. Handle errors
      _________________________________
    }
  } catch (error) {
    // Handle errors
    _________________________________
  }
};
```

---

### Review Questions

**Multiple Choice:**

1. What is Supabase?
   - A) A React Native UI framework
   - B) An open-source Firebase alternative
   - C) A testing library for React Native
   - D) A state management solution

**Answer:** ______

2. Which database does Supabase use?
   - A) MongoDB
   - B) PostgreSQL
   - C) SQLite
   - D) MySQL

**Answer:** ______

3. What is Row Level Security (RLS)?
   - A) A way to protect rows from deletion
   - B) A policy-based security system for database rows
   - C) A way to encrypt database rows
   - D) A method to restrict user access to columns

**Answer:** ______

**Short Answer:**

4. Explain the authentication flow in Supabase.
_________________________________________________________________
_________________________________________________________________

5. How do you implement Google social login?
_________________________________________________________________
_________________________________________________________________

6. What are the benefits of using Row Level Security?
_________________________________________________________________
_________________________________________________________________

---

### Self-Assessment

| Skill | Not Started | Developing | Proficient | Expert |
|-------|-------------|------------|------------|--------|
| Supabase setup and configuration | ☐ | ☐ | ☐ | ☐ |
| Database schema design | ☐ | ☐ | ☐ | ☐ |
| RLS policy creation | ☐ | ☐ | ☐ | ☐ |
| Email/password authentication | ☐ | ☐ | ☐ | ☐ |
| Social login implementation | ☐ | ☐ | ☐ | ☐ |
| Session management | ☐ | ☐ | ☐ | ☐ |

**What I Found Challenging:**
_________________________________________________________________
_________________________________________________________________

**What I Found Interesting:**
_________________________________________________________________
_________________________________________________________________

---

## MODULE 4: DATA MANAGEMENT & OFFLINE SYNC

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Set up WatermelonDB local database
- [ ] Design database schemas and models
- [ ] Implement offline-first architecture
- [ ] Build sync engine with conflict resolution
- [ ] Manage offline queue operations

### Pre-Assessment

**True or False:**
1. WatermelonDB is a cloud database service. ___ T / F
2. Offline-first means the app only works offline. ___ T / F
3. The sync queue tracks pending operations. ___ T / F
4. Conflict resolution is optional in offline sync. ___ T / F
5. WatermelonDB uses SQLite as its underlying storage. ___ T / F

**Fill in the blanks:**
6. The `appSchema` function creates the _____________
7. The _____________ pattern is used for data access abstraction
8. The _____________ method creates a new database record
9. _____________ is used to filter query results
10. The _____________ decorator defines a text column

---

### Guided Exercises

#### Exercise 4.1: Database Schema

**Complete the database schema:**

```typescript
// src/database/schema.ts
import { appSchema, tableSchema } from '@nozbe/watermelondb';

export const schema = appSchema({
  version: 1,
  tables: [
    // Forms table
    tableSchema({
      name: 'forms',
      columns: [
        // Define columns
        _________________________________
        _________________________________
        _________________________________
      ],
    }),
    
    // Collections table
    tableSchema({
      name: 'collections',
      columns: [
        // Define columns
        _________________________________
        _________________________________
        _________________________________
      ],
    }),
    
    // Sync Queue table
    tableSchema({
      name: 'sync_queue',
      columns: [
        // Define columns
        _________________________________
        _________________________________
      ],
    }),
  ],
});
```

---

#### Exercise 4.2: Repository Pattern

**Complete the Form Repository:**

```typescript
// src/database/repositories/FormRepository.ts
import { database } from '@database';
import FormModel from '@database/models/Form';

export class FormRepository {
  static async getAll(userId: string): Promise<FormModel[]> {
    // Query all forms for a user
    _________________________________
    _________________________________
  }
  
  static async create(userId: string, data: any): Promise<FormModel> {
    // Create a new form
    _________________________________
    _________________________________
  }
  
  static async update(id: string, data: any): Promise<FormModel> {
    // Update a form
    _________________________________
    _________________________________
  }
  
  static async delete(id: string): Promise<void> {
    // Soft delete a form
    _________________________________
    _________________________________
  }
}
```

---

#### Exercise 4.3: Sync Engine

**Complete the sync engine:**

```typescript
// src/database/sync/SyncEngine.ts
export class SyncEngine {
  private isSyncing = false;
  
  async sync(): Promise<SyncResult> {
    // Check if already syncing
    _________________________________
    
    // Check network connectivity
    _________________________________
    
    // Get user
    _________________________________
    
    this.isSyncing = true;
    
    try {
      // 1. Upload pending items
      _________________________________
      
      // 2. Download updates
      _________________________________
      
      // 3. Handle conflicts
      _________________________________
      
      // 4. Clean up
      _________________________________
    } finally {
      this.isSyncing = false;
    }
    
    return { success: true, itemsProcessed: 0, itemsFailed: 0 };
  }
}
```

---

### Code Practice

#### Practice 4.1: Complete the Code

**Complete the sync queue manager:**

```typescript
// src/database/sync/SyncQueueManager.ts
export class SyncQueueManager {
  static async enqueue(
    operation: 'create' | 'update' | 'delete',
    tableName: string,
    recordId: string,
    data: any
  ) {
    // Create sync queue item
    _________________________________
    _________________________________
  }
  
  static async markCompleted(id: string) {
    // Mark item as completed
    _________________________________
    _________________________________
  }
  
  static async markFailed(id: string, error: string) {
    // Mark item as failed with retry logic
    _________________________________
    _________________________________
  }
}
```

---

#### Practice 4.2: Debug the Code

**This code has a bug. Find and fix it:**

```typescript
// BUG: What's wrong with this code?
async function syncData() {
  const pending = await getPendingItems();
  for (const item of pending) {
    try {
      await uploadItem(item);
      // Missing: Mark item as processed
    } catch (error) {
      // Missing: Handle error
    }
  }
}

// FIXED VERSION:
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

### Review Questions

**Multiple Choice:**

1. What is WatermelonDB?
   - A) A cloud database service
   - B) A local database for React Native
   - C) A state management library
   - D) A file storage system

**Answer:** ______

2. Which of the following is a key feature of WatermelonDB?
   - A) NoSQL storage
   - B) Reactive queries
   - C) Cloud synchronization
   - D) All of the above

**Answer:** ______

3. What is the purpose of the sync queue?
   - A) To store all data
   - B) To track pending sync operations
   - C) To cache API responses
   - D) To store user preferences

**Answer:** ______

**Short Answer:**

4. Explain the offline-first architecture and its benefits.
_________________________________________________________________
_________________________________________________________________

5. How does conflict resolution work in offline sync?
_________________________________________________________________
_________________________________________________________________

6. What is the purpose of soft delete?
_________________________________________________________________
_________________________________________________________________

---

### Self-Assessment

| Skill | Not Started | Developing | Proficient | Expert |
|-------|-------------|------------|------------|--------|
| WatermelonDB setup | ☐ | ☐ | ☐ | ☐ |
| Schema design | ☐ | ☐ | ☐ | ☐ |
| Repository pattern | ☐ | ☐ | ☐ | ☐ |
| Sync engine implementation | ☐ | ☐ | ☐ | ☐ |
| Conflict resolution | ☐ | ☐ | ☐ | ☐ |
| Offline queue management | ☐ | ☐ | ☐ | ☐ |

**What I Found Challenging:**
_________________________________________________________________
_________________________________________________________________

**What I Found Interesting:**
_________________________________________________________________
_________________________________________________________________

---

## MODULE 5: HARDWARE INTEGRATION

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Integrate camera and photo gallery
- [ ] Implement GPS location tracking
- [ ] Add biometric authentication
- [ ] Configure push notifications
- [ ] Handle device permissions

### Pre-Assessment

**Match the Expo package to its purpose:**

| Package | Purpose |
|---------|---------|
| ___ expo-camera | A. Location services |
| ___ expo-location | B. Biometric authentication |
| ___ expo-local-authentication | C. Camera and photo capture |
| ___ expo-notifications | D. Push notifications |
| ___ expo-image-picker | E. Image selection |

**Fill in the blanks:**
6. The method to get current location is _____________
7. The method to check biometric availability is _____________
8. Push notification tokens are obtained using _____________
9. The _____________ hook provides camera functionality
10. Location tracking uses _____________ for continuous updates

---

### Guided Exercises

#### Exercise 5.1: Camera Service

**Complete the Camera Service:**

```typescript
// src/services/CameraService.ts
export class CameraService {
  private static instance: CameraService;
  
  static getInstance(): CameraService {
    // Implement singleton
    _________________________________
    _________________________________
  }
  
  async capturePhoto(options?: { quality?: number; base64?: boolean }) {
    // Request permissions
    _________________________________
    
    // Launch camera
    _________________________________
    
    // Process result
    _________________________________
    _________________________________
  }
  
  async pickFromGallery(options?: { selectionLimit?: number }) {
    // Request permissions
    _________________________________
    
    // Launch gallery
    _________________________________
    
    // Process result
    _________________________________
    _________________________________
  }
}
```

---

#### Exercise 5.2: Location Service

**Complete the Location Service:**

```typescript
// src/services/LocationService.ts
export class LocationService {
  private currentLocation: LocationData | null = null;
  
  async getCurrentLocation(): Promise<LocationData | null> {
    // Request permissions
    _________________________________
    
    // Get location
    _________________________________
    
    // Return location data
    _________________________________
  }
  
  async reverseGeocode(lat: number, lng: number) {
    // Reverse geocode coordinates
    _________________________________
    _________________________________
  }
  
  calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    // Calculate distance using Haversine formula
    _________________________________
    _________________________________
  }
}
```

---

#### Exercise 5.3: Biometric Service

**Complete the Biometric Service:**

```typescript
// src/services/BiometricService.ts
export class BiometricService {
  async checkAvailability() {
    // Check hardware
    _________________________________
    
    // Check enrollment
    _________________________________
    
    // Get supported types
    _________________________________
    
    return {
      isAvailable: _____________,
      supportedTypes: _____________,
    };
  }
  
  async authenticate(config?: { title: string }) {
    // Perform authentication
    _________________________________
    _________________________________
  }
}
```

---

### Code Practice

#### Practice 5.1: Complete the Code

**Complete the notification service:**

```typescript
// src/services/NotificationService.ts
export class NotificationService {
  private pushToken: string | null = null;
  
  async initialize(): Promise<void> {
    // Request permissions
    _________________________________
    
    // Get push token
    _________________________________
    
    // Register token with backend
    _________________________________
    
    // Setup listeners
    _________________________________
  }
  
  async sendNotification(recipient: string, payload: any) {
    // Send push notification
    _________________________________
    _________________________________
  }
}
```

---

#### Practice 5.2: Debug the Code

**This code has issues. Fix them:**

```typescript
// ERROR: This code has problems
const requestPermission = async () => {
  const { status } = await Camera.requestCameraPermissionsAsync();
  if (status = 'granted') {
    takePhoto();
  }
};

// FIXED VERSION:
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

### Review Questions

**Multiple Choice:**

1. Which Expo package is used for camera integration?
   - A) `expo-camera`
   - B) `expo-image`
   - C) `expo-media`
   - D) `expo-photo`

**Answer:** ______

2. What is the purpose of `Location.watchPositionAsync()`?
   - A) To get a single location update
   - B) To continuously track location changes
   - C) To stop location tracking
   - D) To pause location tracking

**Answer:** ______

3. Which of the following is NOT a biometric authentication type?
   - A) Fingerprint
   - B) Face Recognition
   - C) Iris Scan
   - D) Voice Recognition

**Answer:** ______

**Short Answer:**

4. Explain the camera permission flow.
_________________________________________________________________
_________________________________________________________________

5. How do you implement continuous location tracking?
_________________________________________________________________
_________________________________________________________________

6. What are the steps to set up push notifications?
_________________________________________________________________
_________________________________________________________________

---

### Self-Assessment

| Skill | Not Started | Developing | Proficient | Expert |
|-------|-------------|------------|------------|--------|
| Camera integration | ☐ | ☐ | ☐ | ☐ |
| Location services | ☐ | ☐ | ☐ | ☐ |
| Biometric authentication | ☐ | ☐ | ☐ | ☐ |
| Push notifications | ☐ | ☐ | ☐ | ☐ |
| Permission handling | ☐ | ☐ | ☐ | ☐ |
| Hardware API usage | ☐ | ☐ | ☐ | ☐ |

**What I Found Challenging:**
_________________________________________________________________
_________________________________________________________________

**What I Found Interesting:**
_________________________________________________________________
_________________________________________________________________

---

## MODULE 6: TESTING & QUALITY ASSURANCE

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Implement unit testing with Jest
- [ ] Add component testing with React Native Testing Library
- [ ] Configure E2E testing with Detox
- [ ] Set up code quality tools
- [ ] Configure CI/CD pipeline

### Pre-Assessment

**True or False:**
1. Jest is a testing framework for React Native. ___ T / F
2. Unit tests are slower than E2E tests. ___ T / F
3. Detox is used for End-to-End testing. ___ T / F
4. Code coverage measures how much code is tested. ___ T / F
5. ESLint is a testing framework. ___ T / F

**Fill in the blanks:**
6. The command to run all tests is _____________
7. The _____________ function renders components for testing
8. E2E tests are written using _____________
9. The _____________ configuration defines Jest settings
10. CI/CD stands for _____________

---

### Guided Exercises

#### Exercise 6.1: Jest Configuration

**Complete the Jest configuration:**

```javascript
// jest.config.js
module.exports = {
  preset: _____________,
  setupFilesAfterEnv: [_____________],
  moduleFileExtensions: [_____________],
  testRegex: _____________,
  moduleNameMapper: {
    // Add path aliases
    _________________________________
  },
  collectCoverageFrom: [
    // Define coverage collection
    _________________________________
  ],
  coverageThreshold: {
    global: {
      // Set coverage thresholds
      _________________________________
    },
  },
};
```

---

#### Exercise 6.2: Unit Testing

**Write tests for the validation utilities:**

```typescript
// __tests__/unit/utils/validation.test.ts
import { validateEmail, validatePassword } from '@utils/validation';

describe('Validation Utilities', () => {
  describe('validateEmail', () => {
    it('should return true for valid emails', () => {
      // Write test
      _________________________________
    });
    
    it('should return false for invalid emails', () => {
      // Write test
      _________________________________
    });
  });
  
  describe('validatePassword', () => {
    it('should validate password strength', () => {
      // Write test
      _________________________________
    });
  });
});
```

---

#### Exercise 6.3: Component Testing

**Write tests for the Button component:**

```typescript
// __tests__/components/Button.test.tsx
import { render, fireEvent, screen } from '@testing-library/react-native';
import { Button } from '@components/common/Button';

describe('Button Component', () => {
  it('renders correctly', () => {
    // Write render test
    _________________________________
  });
  
  it('handles press events', () => {
    // Write interaction test
    _________________________________
  });
  
  it('disables button when disabled', () => {
    // Write disabled test
    _________________________________
  });
});
```

---

### Code Practice

#### Practice 6.1: Complete the Code

**Complete the E2E test:**

```typescript
// e2e/auth.e2e.js
describe('Authentication Flow', () => {
  beforeAll(async () => {
    // Launch app
    _________________________________
  });
  
  it('should login successfully', async () => {
    // Enter credentials
    _________________________________
    
    // Tap sign in
    _________________________________
    
    // Verify success
    _________________________________
  });
});
```

---

#### Practice 6.2: Debug the Code

**This test has issues. Fix them:**

```typescript
// ERROR: This test has problems
test('increments counter', () => {
  const { getByText } = render(<Counter />);
  const button = getByText('+');
  fireEvent.click(button);
  expect(getByText('Count: 1')).toBeTruthy();
});

// FIXED VERSION:
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

### Review Questions

**Multiple Choice:**

1. Which testing framework is recommended for React Native?
   - A) Mocha
   - B) Jasmine
   - C) Jest
   - D) Chai

**Answer:** ______

2. Which tool is used for End-to-End testing?
   - A) Jest
   - B) Detox
   - C) Mocha
   - D) Jasmine

**Answer:** ______

3. What is the purpose of code coverage?
   - A) To measure how much code is tested
   - B) To measure code quality
   - C) To measure app performance
   - D) To measure app size

**Answer:** ______

**Short Answer:**

4. Explain the testing pyramid.
_________________________________________________________________
_________________________________________________________________

5. How do you mock API calls in tests?
_________________________________________________________________
_________________________________________________________________

6. What are the benefits of CI/CD?
_________________________________________________________________
_________________________________________________________________

---

### Self-Assessment

| Skill | Not Started | Developing | Proficient | Expert |
|-------|-------------|------------|------------|--------|
| Unit testing with Jest | ☐ | ☐ | ☐ | ☐ |
| Component testing | ☐ | ☐ | ☐ | ☐ |
| Integration testing | ☐ | ☐ | ☐ | ☐ |
| E2E testing with Detox | ☐ | ☐ | ☐ | ☐ |
| Code quality tools | ☐ | ☐ | ☐ | ☐ |
| CI/CD pipeline | ☐ | ☐ | ☐ | ☐ |

**What I Found Challenging:**
_________________________________________________________________
_________________________________________________________________

**What I Found Interesting:**
_________________________________________________________________
_________________________________________________________________

---

## MODULE 7: SECURITY & PRODUCTION DEPLOYMENT

### Learning Objectives

By the end of this module, you will be able to:
- [ ] Implement OWASP Mobile Top 10 security controls
- [ ] Configure code signing and certificates
- [ ] Build and sign production apps
- [ ] Set up OTA updates
- [ ] Deploy to App Store and Google Play

### Pre-Assessment

**True or False:**
1. OWASP Mobile Top 10 lists security risks. ___ T / F
2. Code obfuscation makes code harder to reverse engineer. ___ T / F
3. Certificate pinning allows any certificate. ___ T / F
4. OTA updates require App Store review. ___ T / F
5. Fastlane automates app deployment. ___ T / F

**Fill in the blanks:**
6. The command to generate an Android keystore is _____________
7. Certificate pinning validates _____________
8. OTA stands for _____________
9. The _____________ tool automates deployment
10. The _____________ discloses data collection for iOS

---

### Guided Exercises

#### Exercise 7.1: Security Implementation

**Implement the encryption service:**

```typescript
// src/utils/encryption.ts
export class EncryptionService {
  private encryptionKey: string | null = null;
  
  async initialize() {
    // Get or generate encryption key
    _________________________________
    _________________________________
  }
  
  async encrypt(data: string): Promise<string> {
    // Encrypt data
    _________________________________
    _________________________________
  }
  
  async decrypt(encryptedData: string): Promise<string> {
    // Decrypt data
    _________________________________
    _________________________________
  }
}
```

---

#### Exercise 7.2: OTA Updates

**Implement the OTA update service:**

```typescript
// src/utils/ota.ts
import * as Updates from 'expo-updates';

export class OTAService {
  static async checkForUpdates() {
    // Check for updates
    _________________________________
    
    if (update.isAvailable) {
      // Download update
      _________________________________
      
      // Apply update
      _________________________________
    }
  }
  
  static getUpdateStatus() {
    // Get update status
    _________________________________
  }
}
```

---

#### Exercise 7.3: Deployment Script

**Complete the deployment script:**

```javascript
// scripts/version.js
async function main() {
  // Get current version
  _________________________________
  
  // Prompt for new version
  _________________________________
  
  // Update version in files
  _________________________________
  
  // Commit and tag
  _________________________________
}
```

---

### Code Practice

#### Practice 7.1: Complete the Code

**Complete the integrity check:**

```typescript
// src/utils/integrity.ts
export class IntegrityChecker {
  static async checkDeviceIntegrity() {
    // Check for root/jailbreak
    _________________________________
    
    // Check for emulator
    _________________________________
    
    // Check for debug mode
    _________________________________
    
    return {
      isCompromised: _____________,
      checks: {
        isRooted: _____________,
        isEmulator: _____________,
        isDebug: _____________,
      },
    };
  }
}
```

---

#### Practice 7.2: Debug the Code

**This code has issues. Fix them:**

```typescript
// ERROR: This code has problems
const signingConfig = {
  storeFile: 'nexuscollect-release.keystore',
  storePassword: 'password', // Hardcoded
};

// FIXED VERSION:
_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________
```

---

### Review Questions

**Multiple Choice:**

1. What is OWASP Mobile Top 10?
   - A) A list of security frameworks
   - B) A list of mobile security risks
   - C) A list of testing tools
   - D) A list of deployment strategies

**Answer:** ______

2. Which of the following is NOT an OWASP Mobile Top 10 risk?
   - A) Insecure Data Storage
   - B) Code Obfuscation
   - C) Insecure Authentication
   - D) Insecure Communication

**Answer:** ______

3. What is the purpose of OTA updates?
   - A) To update app without store review
   - B) To update app version
   - C) To update OS version
   - D) To update device firmware

**Answer:** ______

**Short Answer:**

4. Explain certificate pinning and its benefits.
_________________________________________________________________
_________________________________________________________________

5. How do you implement code obfuscation?
_________________________________________________________________
_________________________________________________________________

6. What are the steps to submit an app to the App Store?
_________________________________________________________________
_________________________________________________________________

---

### Self-Assessment

| Skill | Not Started | Developing | Proficient | Expert |
|-------|-------------|------------|------------|--------|
| Security implementation | ☐ | ☐ | ☐ | ☐ |
| Code signing configuration | ☐ | ☐ | ☐ | ☐ |
| Production build creation | ☐ | ☐ | ☐ | ☐ |
| OTA update setup | ☐ | ☐ | ☐ | ☐ |
| App Store submission | ☐ | ☐ | ☐ | ☐ |
| Play Store submission | ☐ | ☐ | ☐ | ☐ |

**What I Found Challenging:**
_________________________________________________________________
_________________________________________________________________

**What I Found Interesting:**
_________________________________________________________________
_________________________________________________________________

---

## FINAL PROJECT WORKSHEETS

### Project Plan

**Project Title:** _________________________________

**Project Description:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Features to Implement:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

**Timeline:**
| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Environment Setup | _____________ | ☐ |
| Project Architecture | _____________ | ☐ |
| Backend Integration | _____________ | ☐ |
| Offline Sync | _____________ | ☐ |
| Hardware Integration | _____________ | ☐ |
| Testing | _____________ | ☐ |
| Security & Deployment | _____________ | ☐ |

---

### Architecture Design

**Draw your application architecture:**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Key Components:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________

**Data Flow:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

### Implementation Checklist

#### Module 1: Native Foundations
- [ ] Xcode installed and configured
- [ ] Android Studio installed and configured
- [ ] React Native project created
- [ ] iOS Simulator working
- [ ] Android Emulator working
- [ ] Native module created (iOS)
- [ ] Native module created (Android)

#### Module 2: Project Architecture
- [ ] Folder structure created
- [ ] Navigation system configured
- [ ] Zustand stores created
- [ ] Theme system implemented
- [ ] Base components built

#### Module 3: Backend Integration
- [ ] Supabase project created
- [ ] Database tables created
- [ ] RLS policies configured
- [ ] Authentication service implemented
- [ ] Login screen built
- [ ] Registration screen built
- [ ] Social login added

#### Module 4: Data Management
- [ ] WatermelonDB schema defined
- [ ] Database models created
- [ ] Repositories implemented
- [ ] Sync engine built
- [ ] Conflict resolution added
- [ ] Offline queue implemented

#### Module 5: Hardware Integration
- [ ] Camera integration added
- [ ] Location services added
- [ ] Biometric authentication added
- [ ] Push notifications added

#### Module 6: Testing & QA
- [ ] Jest configured
- [ ] Unit tests written
- [ ] Component tests written
- [ ] E2E tests written
- [ ] Code quality tools configured
- [ ] CI/CD pipeline set up

#### Module 7: Security & Deployment
- [ ] Security hardening implemented
- [ ] Code signing configured
- [ ] Production build created
- [ ] OTA updates configured
- [ ] App Store submission prepared
- [ ] Play Store submission prepared

---

### Code Review Checklist

#### Code Quality
- [ ] Code follows style guide
- [ ] Proper naming conventions used
- [ ] Comments explain complex logic
- [ ] No console.log statements in production code
- [ ] Error handling implemented

#### Architecture
- [ ] Separation of concerns maintained
- [ ] Reusable components extracted
- [ ] State management follows patterns
- [ ] Navigation is clear and intuitive
- [ ] API layer is clean and consistent

#### Security
- [ ] Sensitive data stored securely
- [ ] Authentication implemented correctly
- [ ] Authorization checked
- [ ] Input validation performed
- [ ] No hardcoded secrets

#### Performance
- [ ] FlatList used for lists
- [ ] Images optimized
- [ ] Memoization used where needed
- [ ] Unnecessary re-renders avoided
- [ ] Memory leaks addressed

#### Testing
- [ ] Unit tests written
- [ ] Component tests written
- [ ] Integration tests written
- [ ] E2E tests written
- [ ] Coverage goals met

---

## APPENDIX A: COMMAND REFERENCE

### Project Commands

```bash
# Create project
npx create-expo-app MyApp --template

# Start development
npx expo start
npx expo start --ios
npx expo start --android
npx expo start --web

# Build
eas build --platform ios --profile production
eas build --platform android --profile production
eas build --platform all --profile production

# Submit
eas submit --platform ios
eas submit --platform android
eas submit --platform all

# OTA Update
eas update --branch production --message "Update message"

# Testing
npm test
npm run test:coverage
npm run test:e2e

# Code Quality
npm run lint
npm run format
npx tsc --noEmit
```

### Git Commands

```bash
# Basic
git init
git add .
git commit -m "message"
git push origin main
git pull origin main

# Branching
git branch feature/name
git checkout feature/name
git merge feature/name

# History
git log
git log --oneline
git log --graph

# Reset
git reset HEAD~1
git reset --hard HEAD~1
git revert <commit-hash>
```

### Your Custom Commands

Add your frequently used commands here:

_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________

---

## APPENDIX B: CODE SNIPPET LIBRARY

### Zustand Store Template

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface StoreState {
  // State properties
  data: any;
  isLoading: boolean;
  error: string | null;
}

interface StoreActions {
  // Actions
  setData: (data: any) => void;
  reset: () => void;
}

type StoreType = StoreState & StoreActions;

export const useStore = create<StoreType>()(
  persist(
    (set) => ({
      // Initial state
      data: null,
      isLoading: false,
      error: null,

      // Actions
      setData: (data) => set({ data }),
      reset: () => set({ data: null, error: null }),
    }),
    {
      name: 'store-storage',
    }
  )
);
```

### Navigation Template

```typescript
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator<StackParamList>();

export const MyStack = () => {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Screen1" component={Screen1} />
      <Stack.Screen name="Screen2" component={Screen2} />
    </Stack.Navigator>
  );
};
```

### API Service Template

```typescript
import { supabase } from '@api/supabase';

export const myService = {
  getData: async (id: string) => {
    const { data, error } = await supabase
      .from('table')
      .select('*')
      .eq('id', id);
    
    if (error) throw error;
    return data;
  },
  
  createData: async (data: any) => {
    const { data: result, error } = await supabase
      .from('table')
      .insert(data)
      .select();
    
    if (error) throw error;
    return result;
  },
};
```

### Your Snippets

Add your custom code snippets here:

_________________________________________________
_________________________________________________
_________________________________________________
_________________________________________________

---

## APPENDIX C: TROUBLESHOOTING GUIDE

### Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| xcodebuild: command not found | Install Xcode Command Line Tools |
| pod: command not found | Install CocoaPods: `sudo gem install cocoapods` |
| Module not found | Run `npm install` |
| Build failed | Clear cache: `npx expo start --clear` |
| Simulator won't open | Check Xcode → Settings → Platforms |

### Error Log

Track errors you encounter and solutions:

| Date | Error | Solution |
|------|-------|----------|
| | | |
| | | |
| | | |
| | | |
| | | |

---

## APPENDIX D: GLOSSARY OF TERMS

| Term | Definition |
|------|------------|
| **Bridge** | Communication layer between JavaScript and native code in React Native |
| **CI/CD** | Continuous Integration/Continuous Deployment |
| **CRUD** | Create, Read, Update, Delete |
| **EAS** | Expo Application Services |
| **E2E** | End-to-End testing |
| **JSI** | JavaScript Interface - part of React Native's New Architecture |
| **OTA** | Over-The-Air updates |
| **RLS** | Row Level Security |
| **TurboModules** | Lazy-loaded native modules in React Native's New Architecture |

### Personal Glossary

Add terms you want to remember:

| Term | Definition |
|------|------------|
| | |
| | |
| | |
| | |

---

## FINAL NOTES & REFLECTIONS

### Overall Course Reflection

**What I Learned:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**What I Enjoyed Most:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**What I Found Most Challenging:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**How I Will Use These Skills:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

**Suggestions for Improvement:**
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________

---

**Course Completion Date:** _____________

**Certificate of Completion:** ☐ Awarded

**Next Steps:**
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

---

*This workbook belongs to:*

**Name:** _________________________________

**Date Started:** _________________________________

**Date Completed:** _________________________________
