# React Native: From Blueprint to Production
## Student Workbook

---

# STUDENT WORKBOOK

## Mobile Development with React Native: From Blueprint to Production

---

**Student Name:** _______________________

**Course Dates:** _______________________

**Instructor:** _______________________

---

## How to Use This Workbook

This workbook is designed to accompany the "Mobile Development with React Native: From Blueprint to Production" course. It contains:

- **Lesson Notes:** Space to take notes during lectures
- **Lab Exercises:** Hands-on activities to practice concepts
- **Code Templates:** Starter code for labs
- **Checkpoint Questions:** Self-assessment questions
- **Project Planning:** Space to plan your TaskFlow application
- **Troubleshooting Log:** Track issues and solutions
- **Reflection Prompts:** Think about what you've learned

---

## Table of Contents

| Part | Topic | Page |
|------|-------|------|
| 0 | Introduction & Mental Model Shift | 4 |
| 1 | Foundations & Environment Architecture | 8 |
| 2 | State Management & Local Persistence | 16 |
| 3 | Device Capabilities & Native Features | 24 |
| 4 | Testing, Performance & Deployment | 30 |
| | Appendices & Reference | 36 |

---

# PART 0: INTRODUCTION

## Lesson Notes: React Native Mental Model

### Key Concepts

**What is React Native?**
___________________________________________________________________
___________________________________________________________________

**Web vs. Mobile Development**
| Web | React Native |
|-----|--------------|
| | |
| | |
| | |

**The Bridge Architecture**
Draw a diagram of the bridge here:
```
[Insert drawing]
```

**The Three Threads**
1. **JavaScript Thread:** _________________________________________
2. **UI Thread:** ________________________________________________
3. **Shadow Thread:** ____________________________________________

**The React Native Mindset**
- Think in ______________, not pages
- Think ______________, not web
- Think ______________: 60fps target
- Think ______________
- Think ______________

### Comprehension Check

1. What is the bridge in React Native?
   ___________________________________________________________________

2. Why is the bridge asynchronous?
   ___________________________________________________________________

3. What happens if the JavaScript thread is blocked?
   ___________________________________________________________________

---

## Lab 0: Exploring React Native

### Objectives
- Create your first React Native project
- Run the app on iOS and/or Android simulators
- Modify the default app
- Understand the development workflow

### Step 1: Create Your Project

```bash
npx create-expo-app TaskFlow --template
```

**Project Name:** TaskFlow

**What template did you choose?** ____________________________

### Step 2: Project Structure

| File/Folder | Purpose |
|-------------|---------|
| App.tsx | |
| app.json | |
| assets/ | |
| node_modules/ | |
| package.json | |

### Step 3: Run the App

```bash
cd TaskFlow
npm start
```

**Which commands did you use to run on each platform?**
- iOS: _____________
- Android: _____________
- Physical Device: _____________

### Step 4: Make Your First Change

Find the `App.tsx` file and replace the content with:

```tsx
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';

export default function App() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Hello, React Native!</Text>
      <Text style={styles.subtitle}>My first mobile app</Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2c3e50',
  },
  subtitle: {
    fontSize: 16,
    color: '#7f8c8d',
    marginTop: 8,
  },
});
```

**What changed when you saved the file?**
___________________________________________________________________

### Step 5: Troubleshooting

| Issue | Solution |
|-------|----------|
| "Command not found: expo" | |
| iOS simulator won't start | |
| Android emulator won't start | |

### Reflection

What was the most surprising thing about your first React Native experience?
___________________________________________________________________
___________________________________________________________________

---

# PART 1: FOUNDATIONS & ENVIRONMENT

## Lesson Notes: Core Components & Styling

### Core Components Reference

| Component | Purpose | Key Props |
|-----------|---------|-----------|
| View | | |
| Text | | |
| SafeAreaView | | |
| ScrollView | | |
| FlatList | | |
| TouchableOpacity | | |
| TextInput | | |
| Image | | |

### StyleSheet Patterns

```tsx
const styles = StyleSheet.create({
  // Write your own examples below
});
```

### Flexbox Properties Cheat Sheet

| Property | Values | Purpose |
|----------|--------|---------|
| flexDirection | row, column | |
| justifyContent | flex-start, center, flex-end, space-between, space-around, space-evenly | |
| alignItems | flex-start, center, flex-end, stretch | |
| flex | number | |
| flexWrap | wrap, nowrap | |

### Your Flexbox Notes

Draw a diagram of flexbox axes:
```
[Insert drawing]
```

### Comprehension Check

1. What is the difference between `justifyContent` and `alignItems`?
   ___________________________________________________________________

2. How do you make a component fill the remaining space?
   ___________________________________________________________________

3. What is the minimum touch target size recommended for accessibility?
   ___________________________________________________________________

---

## Lab 1: Building the TaskCard Component

### Objectives
- Create a reusable TaskCard component
- Implement proper styling with StyleSheet
- Use Flexbox for layout
- Handle press events

### Step 1: Create the Component

Create `src/components/TaskCard.tsx`:

```tsx
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

interface TaskCardProps {
  title: string;
  description?: string;
  priority: 'low' | 'medium' | 'high';
  status: 'todo' | 'in-progress' | 'done';
  onPress?: () => void;
}

// Your implementation goes here

export default TaskCard;
```

### Step 2: Implement the Component

Write your implementation below:
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________

### Step 3: Style the Component

```tsx
const styles = StyleSheet.create({
  // Write your styles here
});
```

### Step 4: Test the Component

Render the component in App.tsx:

```tsx
<TaskCard
  title="Learn React Native"
  description="Complete the tutorial series"
  priority="high"
  status="todo"
  onPress={() => console.log('Task pressed!')}
/>
```

**Screenshot of your component:**

[Insert screenshot here]

### Checkpoint Questions

1. How did you handle different priority colors?
   ___________________________________________________________________

2. How did you handle the status indicator?
   ___________________________________________________________________

3. How did you make the component pressable?
   ___________________________________________________________________

---

## Lesson Notes: Navigation

### Navigation Types

| Type | When to Use | Example |
|------|-------------|---------|
| Stack | | |
| Tab | | |
| Drawer | | |

### Navigation Setup

```tsx
// Installation commands
npm install @react-navigation/native @react-navigation/stack @react-navigation/bottom-tabs @react-navigation/drawer
```

### Stack Navigation Notes

**Key Concepts:**
- `navigation.push()` vs `navigation.navigate()`
- Passing parameters
- Going back
- Screen options

### Tab Navigation Notes

**Key Concepts:**
- Bottom tab bar
- Icons and labels
- Badge indicators

### Drawer Navigation Notes

**Key Concepts:**
- Side menu
- Custom drawer content

### Comprehension Check

1. When would you use Stack navigation vs Tab navigation?
   ___________________________________________________________________

2. How do you pass parameters between screens?
   ___________________________________________________________________

3. What is a navigation guard?
   ___________________________________________________________________

---

## Lab 2: Implementing Navigation

### Objectives
- Set up Stack navigation for TaskFlow
- Set up Tab navigation for main sections
- Set up Drawer navigation for settings
- Implement navigation guards

### Step 1: Install Navigation Dependencies

```bash
# Write the installation commands here
```

### Step 2: Create Root Stack Navigator

Create `src/navigation/RootStackNavigator.tsx`:

```tsx
// Your implementation
```

### Step 3: Create Main Tab Navigator

Create `src/navigation/MainTabNavigator.tsx`:

```tsx
// Your implementation
```

### Step 4: Create Drawer Navigator

Create `src/navigation/DrawerNavigator.tsx`:

```tsx
// Your implementation
```

### Step 5: Implement Navigation Types

Create `src/navigation/types.ts`:

```tsx
// Type definitions
```

### Step 6: Implement Auth Guard

Create `src/navigation/AuthGuard.tsx`:

```tsx
// Your implementation
```

### Navigation Flow Diagram

Draw the navigation flow for TaskFlow:
```
[Insert drawing]
```

### Checkpoint Questions

1. What is the root navigator in your app?
   ___________________________________________________________________

2. How do tabs and drawers work together?
   ___________________________________________________________________

3. How does the AuthGuard protect routes?
   ___________________________________________________________________

---

# PART 2: STATE MANAGEMENT & PERSISTENCE

## Lesson Notes: State Management

### The Three Types of State

| Type | Where | When to Use |
|------|-------|-------------|
| Local State | | |
| Global State | | |
| Persisted State | | |

### Zustand Store Template

```tsx
import { create } from 'zustand';

interface StoreState {
  // State fields
}

export const useStore = create<StoreState>((set, get) => ({
  // Initial state
  // Actions
}));
```

### Zustand Actions Patterns

**Basic Action:**
```tsx
increment: () => set((state) => ({ count: state.count + 1 }))
```

**Async Action:**
```tsx
fetchData: async () => {
  set({ loading: true });
  try {
    const data = await api.getData();
    set({ data, loading: false });
  } catch (error) {
    set({ error, loading: false });
  }
}
```

### Store Selectors

```tsx
const tasks = useTaskStore((state) => state.tasks);
const isLoading = useTaskStore((state) => state.isLoading);
```

### Comprehension Check

1. When should you use global state vs local state?
   ___________________________________________________________________

2. How do you handle async actions in Zustand?
   ___________________________________________________________________

3. Why use selectors instead of destructuring the entire store?
   ___________________________________________________________________

---

## Lab 3: Building TaskFlow Stores

### Objectives
- Create authStore for user authentication
- Create taskStore for task management
- Create uiStore for UI state
- Implement store persistence

### Step 1: Create Auth Store

Create `src/stores/authStore.ts`:

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Your implementation
```

**Store Interface:**
- `user`: User | null
- `token`: string | null
- `isAuthenticated`: boolean
- `isLoading`: boolean
- `error`: string | null
- `login`: (email, password) => Promise<void>
- `logout`: () => void
- `register`: (name, email, password) => Promise<void>

### Step 2: Create Task Store

Create `src/stores/taskStore.ts`:

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Your implementation
```

**Store Interface:**
- `tasks`: Task[]
- `filters`: TaskFilters
- `isLoading`: boolean
- `selectedTask`: Task | null
- `fetchTasks`: () => Promise<void>
- `createTask`: (task) => Promise<void>
- `updateTask`: (id, data) => Promise<void>
- `deleteTask`: (id) => Promise<void>

### Step 3: Create UI Store

Create `src/stores/uiStore.ts`:

```tsx
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Your implementation
```

**Store Interface:**
- `theme`: 'light' | 'dark' | 'system'
- `modal`: { visible: boolean; type: string; data: any }
- `toasts`: Toast[]
- `isLoading`: boolean
- `isOnline`: boolean

### Step 4: Using Stores in Components

Write an example of using a store in a component:
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________

### Store Diagram

Draw the relationship between your stores:
```
[Insert drawing]
```

### Checkpoint Questions

1. How did you handle persistence in your stores?
   ___________________________________________________________________

2. How did you handle errors in async actions?
   ___________________________________________________________________

3. How do stores communicate with each other?
   ___________________________________________________________________

---

## Lesson Notes: Offline-First Architecture

### Offline-First Principles

1. **Local First:** Always read from and write to local storage first
2. **Sync Later:** Sync with server when connectivity is available
3. **Conflict-Free:** Use data types that naturally merge
4. **Optimistic UI:** Update UI immediately, rollback on failure

### Sync Engine Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      SYNC ENGINE                               │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────┐   │
│  │  Operation  │  │  Conflict   │  │  Retry with Backoff  │   │
│  │  Queue      │──▶  Resolution │──▶  and Exponential     │   │
│  │  (Priority) │  │  (LWW/CRDT) │  │  Delay               │   │
│  └─────────────┘  └─────────────┘  └──────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Conflict Resolution Strategies

| Strategy | Description | When to Use |
|----------|-------------|-------------|
| Last Write Wins | Most recent timestamp wins | Simple data |
| Merge | Combine conflicting values | Complex data |
| Manual | Let user resolve | High-value data |

### Optimistic UI Pattern

```tsx
// 1. Update UI immediately
useTaskStore.getState().updateTask(id, newData);

// 2. Queue sync operation
syncEngine.enqueue('update', { id, ...newData });

// 3. Handle sync result
// Success → keep changes
// Failure → rollback to original
```

### Comprehension Check

1. What does "local first" mean?
   ___________________________________________________________________

2. How do you handle conflicts in offline-first apps?
   ___________________________________________________________________

3. What is optimistic UI and why is it important?
   ___________________________________________________________________

---

## Lab 4: Offline-First Task Management

### Objectives
- Implement local storage with SQLite/MMKV
- Build sync engine with priority queue
- Implement conflict resolution
- Add optimistic UI updates

### Step 1: Set Up Local Storage

```tsx
// src/offline/LocalStorage.ts
// Your implementation
```

### Step 2: Build Sync Engine

```tsx
// src/offline/SyncEngine.ts
// Your implementation
```

**Queue Operations:**
- `enqueue(type, data, priority)`
- `processQueue()`
- `retryFailed()`
- `clearCompleted()`

### Step 3: Implement Conflict Resolution

```tsx
// src/offline/ConflictResolver.ts
// Your implementation
```

### Step 4: Add Optimistic UI

```tsx
// src/offline/OptimisticUI.ts
// Your implementation
```

### Sync Flow Diagram

Draw how data flows through your offline-first system:
```
[Insert drawing]
```

### Checkpoint Questions

1. How does your sync engine handle retries?
   ___________________________________________________________________

2. What conflict resolution strategy did you use?
   ___________________________________________________________________

3. How does optimistic UI improve user experience?
   ___________________________________________________________________

---

# PART 3: DEVICE CAPABILITIES

## Lesson Notes: Camera & Photos

### Camera Setup

```bash
# Installation
npx expo install expo-camera expo-image-picker
```

### Permission Flow

```tsx
const requestCameraPermission = async () => {
  const { status } = await Camera.requestCameraPermissionsAsync();
  if (status === 'granted') {
    // Use camera
  } else {
    // Show permission explanation
  }
};
```

### Camera Component

```tsx
<Camera style={styles.camera} type={Camera.Constants.Type.back}>
  <View style={styles.buttonContainer}>
    <TouchableOpacity onPress={takePicture}>
      <Text style={styles.text}>Take Photo</Text>
    </TouchableOpacity>
  </View>
</Camera>
```

### Image Picker

```tsx
const pickImage = async () => {
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ImagePicker.MediaTypeOptions.Images,
    allowsEditing: true,
    aspect: [4, 3],
    quality: 1,
  });
  
  if (!result.canceled) {
    // Use result.assets[0].uri
  }
};
```

### Comprehension Check

1. What permissions are needed for camera access?
   ___________________________________________________________________

2. How do you handle camera permission rejection?
   ___________________________________________________________________

3. Why should you optimize images after capture?
   ___________________________________________________________________

---

## Lab 5: Task Attachments

### Objectives
- Add camera capture to task creation
- Add photo library picker
- Store and display images
- Optimize images for storage

### Step 1: Request Permissions

```tsx
// src/services/cameraService.ts
// Your implementation
```

### Step 2: Camera Capture

```tsx
// src/components/ImageCapture.tsx
// Your implementation
```

### Step 3: Image Picker

```tsx
// src/components/ImagePicker.tsx
// Your implementation
```

### Step 4: Image Optimization

```tsx
// src/utils/imageOptimization.ts
// Your implementation
```

**Optimization Options:**
- `maxWidth`: 1200
- `maxHeight`: 1200
- `quality`: 0.8
- `base64`: false

### Step 5: Display Images

```tsx
<Image source={{ uri: imageUri }} style={styles.image} />
```

### Checkpoint Questions

1. How did you handle permissions for camera and photo library?
   ___________________________________________________________________

2. What optimization did you apply to images?
   ___________________________________________________________________

3. How did you store images locally?
   ___________________________________________________________________

---

## Lesson Notes: Gestures & Animations

### Gesture Handler Setup

```bash
# Installation
npx expo install react-native-gesture-handler react-native-reanimated
```

### Gesture Types

| Gesture | When to Use |
|---------|-------------|
| Pan | Dragging, swiping |
| Tap | Single/double tap |
| LongPress | Context menus, actions |
| Pinch | Zoom, scaling |
| Rotation | Rotating elements |

### Reanimated 2 Basics

**Shared Value:**
```tsx
const translateX = useSharedValue(0);
```

**Animated Style:**
```tsx
const animatedStyle = useAnimatedStyle(() => ({
  transform: [{ translateX: translateX.value }],
}));
```

**With Spring:**
```tsx
translateX.value = withSpring(100, {
  damping: 15,
  stiffness: 150,
});
```

### Swipe-to-Delete Pattern

```tsx
const panGesture = Gesture.Pan()
  .onUpdate((event) => {
    translateX.value = event.translationX;
  })
  .onEnd((event) => {
    if (Math.abs(event.translationX) > threshold) {
      // Trigger delete
    } else {
      // Snap back
      translateX.value = withSpring(0);
    }
  });
```

### Comprehension Check

1. What is the difference between Gesture Handler and TouchableOpacity?
   ___________________________________________________________________

2. When should you use Reanimated vs Animated API?
   ___________________________________________________________________

3. What is a Shared Value?
   ___________________________________________________________________

---

## Lab 6: Interactive Task List

### Objectives
- Implement swipe-to-delete for tasks
- Add drag-to-reorder
- Implement pull-to-refresh
- Add haptic feedback

### Step 1: Swipe-to-Delete

```tsx
// src/components/SwipeableTaskItem.tsx
// Your implementation
```

### Step 2: Drag-to-Reorder

```tsx
// src/components/DragReorderList.tsx
// Your implementation
```

### Step 3: Pull-to-Refresh

```tsx
// src/components/CustomPullToRefresh.tsx
// Your implementation
```

### Step 4: Haptic Feedback

```tsx
// src/services/hapticService.ts
// Your implementation
```

### Gesture Flow Diagram

Draw how gestures flow through your app:
```
[Insert drawing]
```

### Checkpoint Questions

1. How did you handle swipe-to-delete with confirmation?
   ___________________________________________________________________

2. How did you animate the reordering of tasks?
   ___________________________________________________________________

3. When did you trigger haptic feedback?
   ___________________________________________________________________

---

# PART 4: TESTING, PERFORMANCE & DEPLOYMENT

## Lesson Notes: Performance Optimization

### Performance Targets

- **Frame Rate:** 60 FPS
- **Frame Budget:** 16.67ms per frame
- **App Startup:** < 2 seconds
- **Memory Usage:** < 50MB
- **Bundle Size:** < 15MB

### Optimization Strategies

| Area | Strategy |
|------|----------|
| Rendering | Use memo, useMemo, useCallback |
| Lists | FlatList with getItemLayout |
| Images | Optimize size and format |
| Bridge | Batch updates, minimize traffic |
| Bundle | Lazy load, tree shaking |

### Common Bottlenecks

1. **Heavy JS:** Move heavy operations to native
2. **Bridge Traffic:** Batch updates
3. **Layout Thrashing:** Use native animations
4. **Memory Leaks:** Clean up subscriptions

### Performance Monitoring

```tsx
// Measure render time
const start = performance.now();
// ... render
const duration = performance.now() - start;

// Monitor FPS
// Use React DevTools Profiler
```

### Comprehension Check

1. What is the 60 FPS target and why is it important?
   ___________________________________________________________________

2. How do you identify performance bottlenecks?
   ___________________________________________________________________

3. What is the difference between useMemo and useCallback?
   ___________________________________________________________________

---

## Lab 7: Performance Optimization

### Objectives
- Profile app performance
- Implement memoization
- Optimize FlatList
- Reduce bundle size

### Step 1: Profile with React DevTools

**What bottlenecks did you find?**
___________________________________________________________________

### Step 2: Implement Memoization

```tsx
// src/components/OptimizedTaskItem.tsx
// Your implementation
```

### Step 3: Optimize FlatList

```tsx
<FlatList
  data={tasks}
  renderItem={renderItem}
  keyExtractor={keyExtractor}
  // Add optimizations here
  removeClippedSubviews
  maxToRenderPerBatch={10}
  windowSize={10}
  getItemLayout={getItemLayout}
/>
```

### Step 4: Bundle Analysis

```bash
# Run bundle analysis
npm run bundle:analyze
```

**Largest dependencies:**
1. ____________________________________________
2. ____________________________________________
3. ____________________________________________

### Performance Comparison

| Metric | Before | After |
|--------|--------|-------|
| App Startup | | |
| Screen Render | | |
| List Scroll FPS | | |
| Memory Usage | | |
| Bundle Size | | |

### Checkpoint Questions

1. What made the biggest performance improvement?
   ___________________________________________________________________

2. What was the most challenging optimization?
   ___________________________________________________________________

3. How did you validate performance improvements?
   ___________________________________________________________________

---

## Lesson Notes: Testing

### Testing Pyramid

```
        ┌─────────────────────────────────────────────────────────────┐
        │                    E2E TESTS                               │
        │                  (Detox / Cypress)                         │
        │  ┌────────────────────────────────────────────────────┐   │
        │  │              INTEGRATION TESTS                     │   │
        │  │         (React Native Testing Library)            │   │
        │  │  ┌────────────────────────────────────────────┐   │   │
        │  │  │          UNIT TESTS                       │   │   │
        │  │  │        (Jest / Testing Library)           │   │   │
        │  │  └────────────────────────────────────────────┘   │   │
        │  └────────────────────────────────────────────────────┘   │
        └─────────────────────────────────────────────────────────────┘
```

### Test Types

| Type | What It Tests | Example |
|------|---------------|---------|
| Unit | Individual functions | calculateTotal() |
| Component | UI components | TaskCard renders |
| Integration | Feature flows | Create task flow |
| E2E | Full user journeys | Login → Create → Logout |

### Jest Setup

```bash
npm install --save-dev jest @testing-library/react-native @testing-library/jest-native
```

### Component Test Template

```tsx
import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';

describe('Component', () => {
  it('renders correctly', () => {
    const { getByText } = render(<Component />);
    expect(getByText('Hello')).toBeTruthy();
  });
});
```

### Comprehension Check

1. What is the difference between unit and integration tests?
   ___________________________________________________________________

2. Why are E2E tests important?
   ___________________________________________________________________

3. What is the testing pyramid?
   ___________________________________________________________________

---

## Lab 8: Testing TaskFlow

### Objectives
- Write unit tests for utilities
- Write component tests
- Write integration tests
- Set up CI testing

### Step 1: Unit Tests

```tsx
// src/__tests__/utils/validation.test.ts
// Your implementation
```

**Test Cases:**
- [ ] validateEmail works correctly
- [ ] validatePassword works correctly
- [ ] validateTaskTitle works correctly

### Step 2: Component Tests

```tsx
// src/__tests__/components/TaskCard.test.tsx
// Your implementation
```

**Test Cases:**
- [ ] Renders correctly
- [ ] Calls onPress when tapped
- [ ] Shows correct priority color

### Step 3: Store Tests

```tsx
// src/__tests__/stores/taskStore.test.ts
// Your implementation
```

**Test Cases:**
- [ ] Adds task correctly
- [ ] Updates task correctly
- [ ] Deletes task correctly

### Step 4: Integration Tests

```tsx
// src/__tests__/integration/taskFlow.test.tsx
// Your implementation
```

**Test Cases:**
- [ ] Creates task
- [ ] Completes task
- [ ] Deletes task

### Test Coverage Report

| File | Statements | Branches | Functions | Lines |
|------|------------|----------|-----------|-------|
| | | | | |
| | | | | |
| | | | | |

### Checkpoint Questions

1. What was the hardest test to write?
   ___________________________________________________________________

2. What did you learn from testing?
   ___________________________________________________________________

3. What is your test coverage percentage?
   ___________________________________________________________________

---

## Lesson Notes: CI/CD & Deployment

### EAS Build Configuration

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "distribution": "store",
      "channel": "production"
    }
  }
}
```

### GitHub Actions Workflow

```yaml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: npm ci
      - run: npm test
  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: eas build --platform all
```

### App Store Checklist

- [ ] App icon and splash screen
- [ ] App screenshots
- [ ] App description
- [ ] Privacy policy
- [ ] Support URL
- [ ] Marketing URL

### Comprehension Check

1. What is the difference between development, preview, and production builds?
   ___________________________________________________________________

2. Why is CI/CD important for mobile apps?
   ___________________________________________________________________

3. What are the key requirements for app store submission?
   ___________________________________________________________________

---

## Lab 9: Deploy TaskFlow

### Objectives
- Set up EAS Build
- Configure GitHub Actions
- Prepare app store metadata
- Submit to stores

### Step 1: EAS Build Configuration

```json
// eas.json
// Your configuration
```

### Step 2: GitHub Actions Setup

```yaml
// .github/workflows/ci.yml
// Your configuration
```

### Step 3: App Store Metadata

| Field | Value |
|-------|-------|
| App Name | |
| Subtitle | |
| Description | |
| Keywords | |

### Step 4: Build and Submit

```bash
# Build commands
eas build --platform ios --profile production
eas build --platform android --profile production

# Submit commands
eas submit --platform ios
eas submit --platform android
```

### Deployment Checklist

- [ ] All tests passing
- [ ] Bundle size acceptable
- [ ] App store metadata ready
- [ ] Privacy policy available
- [ ] Support contact set up
- [ ] Build successful

### Checkpoint Questions

1. What challenges did you face during deployment?
   ___________________________________________________________________

2. What would you do differently next time?
   ___________________________________________________________________

3. What was the most rewarding part of the process?
   ___________________________________________________________________

---

# PROJECT PLANNING

## TaskFlow Project Plan

### Project Overview

**App Name:** TaskFlow

**Description:**
___________________________________________________________________
___________________________________________________________________

**Target Users:**
___________________________________________________________________
___________________________________________________________________

**Key Features:**
1. ____________________________________________
2. ____________________________________________
3. ____________________________________________
4. ____________________________________________
5. ____________________________________________

### Technical Architecture

| Component | Technology | Reason |
|-----------|------------|--------|
| Framework | | |
| Navigation | | |
| State Management | | |
| Storage | | |
| Backend | | |
| Testing | | |

### Development Timeline

| Phase | Tasks | Duration |
|-------|-------|----------|
| Setup | | |
| Core UI | | |
| Navigation | | |
| State Management | | |
| Device APIs | | |
| Testing | | |
| Deployment | | |

### Feature Implementation Checklist

| Feature | Status | Notes |
|---------|--------|-------|
| Authentication | ☐ | |
| Task CRUD | ☐ | |
| Offline Support | ☐ | |
| Push Notifications | ☐ | |
| Camera/Photos | ☐ | |
| Location | ☐ | |
| Animations | ☐ | |
| Testing | ☐ | |
| CI/CD | ☐ | |
| Deployment | ☐ | |

---

# TROUBLESHOOTING LOG

## Issues & Solutions

| Date | Issue | Solution | Status |
|------|-------|----------|--------|
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |
| | | | |

---

# REFLECTION

## Weekly Reflections

### Week 1: Introduction & Setup

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 2: Core Components & Styling

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 3: Navigation

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 4: State Management

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 5: Offline-First Architecture

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 6: Device Capabilities

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 7: Gestures & Animations

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 8: Testing

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

### Week 9: Performance & Deployment

**What I learned:**
___________________________________________________________________
___________________________________________________________________

**What challenged me:**
___________________________________________________________________
___________________________________________________________________

**What I want to explore more:**
___________________________________________________________________
___________________________________________________________________

---

# FINAL PROJECT EVALUATION

## Self-Evaluation

### Technical Skills

| Skill | Novice | Intermediate | Advanced |
|-------|--------|--------------|----------|
| React Native Fundamentals | ☐ | ☐ | ☐ |
| Navigation | ☐ | ☐ | ☐ |
| State Management | ☐ | ☐ | ☐ |
| Offline-First Architecture | ☐ | ☐ | ☐ |
| Performance Optimization | ☐ | ☐ | ☐ |
| Testing | ☐ | ☐ | ☐ |
| CI/CD & Deployment | ☐ | ☐ | ☐ |

### What I'm Most Proud Of
___________________________________________________________________
___________________________________________________________________

### What I Found Most Difficult
___________________________________________________________________
___________________________________________________________________

### What I Want to Learn Next
___________________________________________________________________
___________________________________________________________________

### Project Feedback
___________________________________________________________________
___________________________________________________________________

---

**Course Completion Date:** _______________________

**Instructor Signature:** _______________________

**Student Signature:** _______________________

---

*Congratulations on completing the React Native: From Blueprint to Production course! You are now equipped to build production-ready mobile applications with React Native.*

---

**[END OF WORKBOOK]**
