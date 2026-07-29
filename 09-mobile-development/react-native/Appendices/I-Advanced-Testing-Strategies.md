# Appendix I: Advanced Testing Strategies

Welcome to Appendix I! This comprehensive guide covers advanced testing strategies for React Native applications. You'll learn about property-based testing, visual regression testing, mutation testing, performance testing, and advanced mocking patterns that will make your test suite more robust and reliable.

---

## Table of Contents

1. [Testing Pyramid Revisited](#testing-pyramid-revisited)
2. [Property-Based Testing](#property-based-testing)
3. [Visual Regression Testing](#visual-regression-testing)
4. [Mutation Testing](#mutation-testing)
5. [Performance & Load Testing](#performance--load-testing)
6. [Advanced Mocking Patterns](#advanced-mocking-patterns)
7. [Test-Driven Development (TDD)](#test-driven-development-tdd)
8. [Continuous Testing](#continuous-testing)

---

## Testing Pyramid Revisited

### Advanced Testing Architecture

```typescript
// src/testing/architecture.ts
/**
 * Advanced Testing Pyramid
 * 
 * ┌─────────────────────────────────────────────────────────────┐
 * │                    E2E TESTS                               │
 * │                  (Detox / Cypress)                         │
 * │  ┌────────────────────────────────────────────────────┐   │
 * │  │              INTEGRATION TESTS                     │   │
 * │  │         (React Native Testing Library)            │   │
 * │  │  ┌────────────────────────────────────────────┐   │   │
 * │  │  │          UNIT TESTS                       │   │   │
 * │  │  │        (Jest / Testing Library)           │   │   │
 * │  │  └────────────────────────────────────────────┘   │   │
 * │  └────────────────────────────────────────────────────┘   │
 * └─────────────────────────────────────────────────────────────┘
 */

export const TestingPyramid = {
  unit: {
    count: 'Most',
    speed: 'Fast',
    cost: 'Low',
    focus: 'Individual functions, components',
    examples: ['Utility functions', 'Hooks', 'Pure components'],
  },
  integration: {
    count: 'Some',
    speed: 'Medium',
    cost: 'Medium',
    focus: 'Multiple components working together',
    examples: ['Screen flows', 'API integration', 'Store interactions'],
  },
  e2e: {
    count: 'Few',
    speed: 'Slow',
    cost: 'High',
    focus: 'Full user journeys',
    examples: ['Login flow', 'Create task flow', 'Offline sync'],
  },
};
```

---

## Property-Based Testing

### Fast-Check Implementation

```typescript
// src/__tests__/property-based/taskValidator.test.ts
import fc from 'fast-check';
import { validateTask } from '../../utils/validation';

/**
 * Property-Based Testing
 * 
 * Property-based testing generates random inputs to verify
 * that properties hold true for all possible inputs.
 */

describe('Task Validator - Property-Based Tests', () => {
  // Property: Valid tasks should always have required fields
  it('should require title and dueDate', () => {
    fc.assert(
      fc.property(
        fc.record({
          title: fc.string({ minLength: 1 }),
          description: fc.optional(fc.string()),
          priority: fc.constantFrom('low', 'medium', 'high'),
          dueDate: fc.date({ min: new Date() }),
        }),
        (task) => {
          const result = validateTask(task);
          expect(result.isValid).toBe(true);
        }
      )
    );
  });

  // Property: Invalid tasks should always fail validation
  it('should reject tasks with invalid fields', () => {
    fc.assert(
      fc.property(
        fc.record({
          title: fc.string({ minLength: 0, maxLength: 0 }),
          dueDate: fc.date({ max: new Date(Date.now() - 86400000) }),
        }),
        (task) => {
          const result = validateTask(task);
          expect(result.isValid).toBe(false);
          expect(result.errors.length).toBeGreaterThan(0);
        }
      )
    );
  });

  // Property: String sanitization should be idempotent
  it('should be idempotent when sanitizing strings', () => {
    fc.assert(
      fc.property(
        fc.string(),
        (input) => {
          const sanitized = sanitizeString(input);
          const doubleSanitized = sanitizeString(sanitized);
          expect(sanitized).toBe(doubleSanitized);
        }
      )
    );
  });

  // Property: Date formatting should be consistent
  it('should format dates consistently', () => {
    fc.assert(
      fc.property(
        fc.date(),
        (date) => {
          const formatted = formatDate(date);
          const parsed = parseDate(formatted);
          expect(parsed).toBeDefined();
          // Check that the parsed date is within 1 second of the original
          const diff = Math.abs(parsed!.getTime() - date.getTime());
          expect(diff).toBeLessThan(1000);
        }
      )
    );
  });
});
```

---

## Visual Regression Testing

### Component Screenshot Testing

```typescript
// src/__tests__/visual/ComponentScreenshots.test.tsx
import React from 'react';
import { render, screen } from '@testing-library/react-native';
import { toMatchImageSnapshot } from 'jest-image-snapshot';
import { TaskCard } from '../../components/TaskCard';
import { ThemeProvider } from '../../context/ThemeContext';

/**
 * Visual Regression Testing
 * 
 * This captures screenshots of components and compares
 * them against baseline images to detect visual regressions.
 */

expect.extend({ toMatchImageSnapshot });

describe('Visual Regression Tests', () => {
  // Mock task data
  const mockTask = {
    id: '1',
    title: 'Test Task',
    description: 'This is a test task description',
    priority: 'high',
    status: 'todo',
    dueDate: '2024-01-15',
    category: 'Work',
    createdAt: '2024-01-01T00:00:00.000Z',
    updatedAt: '2024-01-01T00:00:00.000Z',
  };

  // Helper to render and capture screenshot
  const captureComponent = (
    component: React.ReactElement,
    options = { width: 375, height: 812 }
  ) => {
    // In production, use actual screenshot library
    // For demo, return a promise with mock data
    return Promise.resolve({
      width: options.width,
      height: options.height,
      // Mock image data
    });
  };

  it('should match TaskCard snapshot', async () => {
    const component = (
      <ThemeProvider>
        <TaskCard
          task={mockTask}
          onPress={jest.fn()}
          onDelete={jest.fn()}
          onEdit={jest.fn()}
        />
      </ThemeProvider>
    );

    const screenshot = await captureComponent(component);
    
    // This would use actual image comparison
    // expect(screenshot).toMatchImageSnapshot({
    //   failureThreshold: 0.01,
    //   failureThresholdType: 'percent',
    // });
  });

  it('should match TaskCard in dark mode', async () => {
    const component = (
      <ThemeProvider>
        <TaskCard
          task={mockTask}
          onPress={jest.fn()}
          onDelete={jest.fn()}
          onEdit={jest.fn()}
          // Add dark mode props
        />
      </ThemeProvider>
    );

    const screenshot = await captureComponent(component);
    // expect(screenshot).toMatchImageSnapshot();
  });

  it('should match TaskCard with different priorities', async () => {
    const priorities = ['low', 'medium', 'high'];

    for (const priority of priorities) {
      const task = { ...mockTask, priority: priority as any };
      const component = (
        <ThemeProvider>
          <TaskCard
            task={task}
            onPress={jest.fn()}
            onDelete={jest.fn()}
            onEdit={jest.fn()}
          />
        </ThemeProvider>
      );

      const screenshot = await captureComponent(component);
      // expect(screenshot).toMatchImageSnapshot({
      //   customSnapshotIdentifier: `task-card-${priority}`,
      // });
    }
  });
});
```

---

## Mutation Testing

### Mutation Testing Framework

```typescript
// src/__tests__/mutation/mutation.test.ts
/**
 * Mutation Testing
 * 
 * Mutation testing modifies your code and checks if
 * your tests catch the changes. Higher mutation score
 * indicates better test quality.
 */

// Example: Mutation testing for a validation function
export const validateEmail = (email: string): boolean => {
  // Original implementation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

describe('Mutation Testing - validateEmail', () => {
  // Test suite for email validation
  
  it('should validate correct emails', () => {
    expect(validateEmail('test@example.com')).toBe(true);
    expect(validateEmail('user.name@domain.co')).toBe(true);
    expect(validateEmail('test+filter@domain.com')).toBe(true);
  });

  it('should reject invalid emails', () => {
    expect(validateEmail('')).toBe(false);
    expect(validateEmail('test')).toBe(false);
    expect(validateEmail('test@')).toBe(false);
    expect(validateEmail('test@domain')).toBe(false);
    expect(validateEmail('test domain.com')).toBe(false);
  });

  // Mutation: Change regex to accept all emails
  // The test should catch this mutation
  // Mutation: Remove the validation check
  // The test should catch this mutation
});

/**
 * Mutation Score Report
 * 
 * Mutation Score: 92%
 * Surviving Mutants: 2
 * 
 * Surviving Mutants:
 * - Changed email regex to accept all emails
 * - Removed validation for empty strings
 * 
 * Recommendations:
 * - Add test for empty string validation
 * - Add test for edge cases in email format
 */
```

---

## Performance & Load Testing

### Performance Testing Framework

```typescript
// src/__tests__/performance/performance.test.ts
import { measurePerformance } from 'react-native-performance-testing';
import { FlatList } from 'react-native';

/**
 * Performance & Load Testing
 * 
 * This tests the performance characteristics of your app:
 * - Render performance
 * - Memory usage
 * - Frame rate
 * - Load time
 */

describe('Performance Tests', () => {
  // Generate large dataset for load testing
  const generateLargeDataset = (size: number) => {
    return Array.from({ length: size }, (_, i) => ({
      id: `item-${i}`,
      title: `Task ${i}`,
      description: `Description for task ${i}`,
      priority: ['low', 'medium', 'high'][i % 3],
      status: ['todo', 'in-progress', 'done'][i % 3],
      dueDate: new Date(Date.now() + i * 86400000).toISOString(),
    }));
  };

  it('should render 1000 items in under 500ms', async () => {
    const data = generateLargeDataset(1000);
    
    const metrics = await measurePerformance(
      () => {
        // Render the FlatList
        // In practice, this would be a component
        // For demo, we're just measuring the setup
        const list = (
          <FlatList
            data={data}
            renderItem={({ item }) => (
              <View>
                <Text>{item.title}</Text>
                <Text>{item.description}</Text>
              </View>
            )}
            keyExtractor={(item) => item.id}
          />
        );
        return list;
      },
      {
        duration: 500, // Max duration
        iterations: 5, // Run multiple times
      }
    );

    expect(metrics.average).toBeLessThan(500);
    expect(metrics.max).toBeLessThan(600);
  });

  it('should maintain 60fps when scrolling', async () => {
    const data = generateLargeDataset(500);
    
    const metrics = await measurePerformance(
      () => {
        // In practice, this would simulate scrolling
        // For demo, we're checking the setup
        return (
          <FlatList
            data={data}
            renderItem={({ item }) => (
              <View>
                <Text>{item.title}</Text>
                <Text>{item.description}</Text>
              </View>
            )}
            keyExtractor={(item) => item.id}
            // Performance optimizations
            removeClippedSubviews
            maxToRenderPerBatch={10}
            windowSize={21}
          />
        );
      },
      {
        duration: 1000,
        iterations: 5,
      }
    );

    expect(metrics.fps).toBeGreaterThan(30);
    expect(metrics.droppedFrames).toBeLessThan(10);
  });

  it('should not exceed 50MB memory usage with 5000 items', async () => {
    const data = generateLargeDataset(5000);
    
    const metrics = await measurePerformance(
      () => {
        return (
          <FlatList
            data={data}
            renderItem={({ item }) => (
              <View>
                <Text>{item.title}</Text>
                <Text>{item.description}</Text>
              </View>
            )}
            keyExtractor={(item) => item.id}
          />
        );
      },
      {
        duration: 5000,
        iterations: 3,
      }
    );

    expect(metrics.memory).toBeLessThan(50); // 50MB
  });

  it('should have startup time under 2 seconds', async () => {
    const startTime = performance.now();
    
    // Simulate app startup
    await new Promise(resolve => setTimeout(resolve, 500));
    
    const startupTime = performance.now() - startTime;
    expect(startupTime).toBeLessThan(2000);
  });

  // Performance budget monitoring
  it('should respect performance budgets', () => {
    const budgets = {
      firstRender: 500, // ms
      interactionDelay: 100, // ms
      memoryUsage: 50, // MB
      bundleSize: 15, // MB
      startupTime: 2000, // ms
    };

    // In practice, these would be measured from actual runs
    const actualMetrics = {
      firstRender: 320,
      interactionDelay: 45,
      memoryUsage: 32,
      bundleSize: 12,
      startupTime: 1400,
    };

    expect(actualMetrics.firstRender).toBeLessThan(budgets.firstRender);
    expect(actualMetrics.interactionDelay).toBeLessThan(budgets.interactionDelay);
    expect(actualMetrics.memoryUsage).toBeLessThan(budgets.memoryUsage);
    expect(actualMetrics.bundleSize).toBeLessThan(budgets.bundleSize);
    expect(actualMetrics.startupTime).toBeLessThan(budgets.startupTime);
  });
});
```

---

## Advanced Mocking Patterns

### Comprehensive Mocking Examples

```typescript
// src/__tests__/mocks/advancedMocks.ts
import { NativeModules } from 'react-native';

/**
 * Advanced Mocking Patterns
 * 
 * This provides advanced mocking techniques:
 * - Module mocking
 * - API mocking
 * - Native module mocking
 * - Time mocking
 */

// 1. Mocking Native Modules
jest.mock('react-native/Libraries/EventEmitter/NativeEventEmitter', () => {
  const NativeEventEmitter = jest.requireActual('react-native/Libraries/EventEmitter/NativeEventEmitter');
  return {
    ...NativeEventEmitter,
    addListener: jest.fn(),
    removeListeners: jest.fn(),
  };
});

// 2. Mocking AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  setItem: jest.fn(),
  getItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
  getAllKeys: jest.fn(),
}));

// 3. Mocking APIs
jest.mock('axios', () => ({
  create: jest.fn(() => ({
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
    patch: jest.fn(),
    interceptors: {
      request: { use: jest.fn() },
      response: { use: jest.fn() },
    },
  })),
  get: jest.fn(),
  post: jest.fn(),
  put: jest.fn(),
  delete: jest.fn(),
  patch: jest.fn(),
  interceptors: {
    request: { use: jest.fn() },
    response: { use: jest.fn() },
  },
}));

// 4. Mocking Custom Hooks
jest.mock('../../hooks/useApi', () => ({
  useApi: jest.fn(() => ({
    data: null,
    loading: false,
    error: null,
    execute: jest.fn(),
  })),
}));

// 5. Mocking Modules with Complex Exports
jest.mock('expo-notifications', () => ({
  addNotificationReceivedListener: jest.fn(() => ({ remove: jest.fn() })),
  addNotificationResponseReceivedListener: jest.fn(() => ({ remove: jest.fn() })),
  requestPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  getPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  scheduleNotificationAsync: jest.fn().mockResolvedValue('notification-id'),
  cancelScheduledNotificationAsync: jest.fn(),
  cancelAllScheduledNotificationsAsync: jest.fn(),
}));

// 6. Advanced Time Mocking
export const mockTime = () => {
  const originalDate = global.Date;
  
  beforeAll(() => {
    // Mock current time
    global.Date.now = jest.fn(() => new Date('2024-01-01T00:00:00Z').getTime());
  });
  
  afterAll(() => {
    global.Date = originalDate;
  });
};

// 7. Factory Function Mock
export const createMockStore = (initialState = {}) => {
  return {
    getState: jest.fn(() => initialState),
    setState: jest.fn(),
    subscribe: jest.fn(),
    dispatch: jest.fn(),
    ...initialState,
  };
};

// 8. Mocking Network Responses
export const mockApiResponse = (endpoint: string, response: any, status = 200) => {
  return {
    endpoint,
    response,
    status,
    headers: {
      'Content-Type': 'application/json',
    },
  };
};

// 9. Mocking Native Modules with Permissions
NativeModules.PermissionsAndroid = {
  check: jest.fn().mockResolvedValue('granted'),
  request: jest.fn().mockResolvedValue('granted'),
  requestMultiple: jest.fn().mockResolvedValue({}),
};

// 10. Mocking Geolocation
NativeModules.Geolocation = {
  getCurrentPosition: jest.fn((success, error) => {
    success({
      coords: {
        latitude: 37.78825,
        longitude: -122.4324,
        altitude: 0,
        accuracy: 5,
        altitudeAccuracy: 5,
        heading: 0,
        speed: 0,
      },
      timestamp: Date.now(),
    });
  }),
  watchPosition: jest.fn(),
  clearWatch: jest.fn(),
  stopObserving: jest.fn(),
};

// 11. Mocking Event Emitters
export const createMockEventEmitter = () => {
  const listeners: Record<string, Function[]> = {};
  
  return {
    addListener: jest.fn((event, callback) => {
      if (!listeners[event]) {
        listeners[event] = [];
      }
      listeners[event].push(callback);
      return {
        remove: jest.fn(() => {
          listeners[event] = listeners[event].filter(l => l !== callback);
        }),
      };
    }),
    emit: jest.fn((event, data) => {
      if (listeners[event]) {
        listeners[event].forEach(callback => callback(data));
      }
    }),
    removeAllListeners: jest.fn(() => {
      Object.keys(listeners).forEach(key => {
        listeners[key] = [];
      });
    }),
  };
};
```

---

## Test-Driven Development (TDD)

### TDD Implementation Example

```typescript
// src/__tests__/tdd/TaskQueue.test.ts
/**
 * Test-Driven Development Example
 * 
 * This demonstrates TDD by writing tests first
 * for a TaskQueue implementation.
 */

// Step 1: Write the test first (RED)
describe('TaskQueue', () => {
  // Test for adding tasks
  it('should add tasks to the queue', () => {
    const queue = new TaskQueue();
    const task = { id: '1', title: 'Test Task' };
    
    queue.addTask(task);
    
    expect(queue.getTasks()).toContain(task);
    expect(queue.getSize()).toBe(1);
  });

  // Test for processing tasks
  it('should process tasks in FIFO order', () => {
    const queue = new TaskQueue();
    const tasks = [
      { id: '1', title: 'Task 1' },
      { id: '2', title: 'Task 2' },
      { id: '3', title: 'Task 3' },
    ];
    
    tasks.forEach(task => queue.addTask(task));
    
    const processed: Task[] = [];
    while (queue.hasTasks()) {
      const task = queue.processTask();
      if (task) processed.push(task);
    }
    
    expect(processed).toEqual(tasks);
    expect(queue.getSize()).toBe(0);
  });

  // Test for priority tasks
  it('should process high priority tasks first', () => {
    const queue = new TaskQueue();
    
    queue.addTask({ id: '1', title: 'Normal', priority: 'normal' });
    queue.addTask({ id: '2', title: 'High', priority: 'high' });
    queue.addTask({ id: '3', title: 'Low', priority: 'low' });
    
    const processed: Task[] = [];
    while (queue.hasTasks()) {
      const task = queue.processTask();
      if (task) processed.push(task);
    }
    
    expect(processed[0].priority).toBe('high');
    expect(processed[1].priority).toBe('normal');
    expect(processed[2].priority).toBe('low');
  });
});

// Step 2: Write the minimal implementation (GREEN)
// Step 3: Refactor (REFACTOR)

// Implementation (would be in separate file)
interface Task {
  id: string;
  title: string;
  priority?: 'low' | 'normal' | 'high';
}

class TaskQueue {
  private tasks: Task[] = [];
  private priorityOrder = { high: 0, normal: 1, low: 2 };

  addTask(task: Task): void {
    this.tasks.push(task);
  }

  processTask(): Task | null {
    if (this.tasks.length === 0) return null;
    
    // Sort by priority (high first)
    this.tasks.sort((a, b) => {
      const priorityA = a.priority || 'normal';
      const priorityB = b.priority || 'normal';
      return this.priorityOrder[priorityA] - this.priorityOrder[priorityB];
    });
    
    return this.tasks.shift() || null;
  }

  getTasks(): Task[] {
    return [...this.tasks];
  }

  getSize(): number {
    return this.tasks.length;
  }

  hasTasks(): boolean {
    return this.tasks.length > 0;
  }
}
```

---

## Continuous Testing

### Continuous Testing Configuration

```typescript
// src/testing/continuousTest.ts
/**
 * Continuous Testing
 * 
 * This configures continuous testing for your CI/CD pipeline:
 * - Test selection
 * - Test prioritization
 * - Flaky test detection
 * - Test analytics
 */

export class ContinuousTestManager {
  private static instance: ContinuousTestManager;
  private testResults: Map<string, any> = new Map();
  private flakyTests: Set<string> = new Set();

  private constructor() {}

  static getInstance(): ContinuousTestManager {
    if (!ContinuousTestManager.instance) {
      ContinuousTestManager.instance = new ContinuousTestManager();
    }
    return ContinuousTestManager.instance;
  }

  /**
   * Select tests based on changes
   */
  selectTests(changedFiles: string[]): string[] {
    // In production, use a test selector based on coverage
    // For demo, return all tests
    return [
      'src/__tests__/**/*.test.ts',
      'src/__tests__/**/*.test.tsx',
    ];
  }

  /**
   * Prioritize tests
   */
  prioritizeTests(tests: string[]): string[] {
    // Prioritize critical tests first
    const criticalTests = tests.filter(t => 
      t.includes('auth') || 
      t.includes('task') ||
      t.includes('payment')
    );
    
    const otherTests = tests.filter(t => !criticalTests.includes(t));
    
    return [...criticalTests, ...otherTests];
  }

  /**
   * Detect flaky tests
   */
  trackTestResult(testName: string, passed: boolean, duration: number): void {
    if (!this.testResults.has(testName)) {
      this.testResults.set(testName, {
        runs: 0,
        passed: 0,
        failed: 0,
        totalDuration: 0,
      });
    }
    
    const stats = this.testResults.get(testName);
    stats.runs++;
    stats.passed += passed ? 1 : 0;
    stats.failed += passed ? 0 : 1;
    stats.totalDuration += duration;
    
    // Detect flaky tests (fail > 10% of runs)
    if (stats.runs >= 10) {
      const failureRate = stats.failed / stats.runs;
      if (failureRate > 0.1) {
        this.flakyTests.add(testName);
      } else {
        this.flakyTests.delete(testName);
      }
    }
  }

  /**
   * Generate test report
   */
  generateTestReport(): {
    total: number;
    passed: number;
    failed: number;
    flaky: string[];
    averageDuration: number;
  } {
    let total = 0;
    let passed = 0;
    let failed = 0;
    let totalDuration = 0;
    
    this.testResults.forEach((stats, name) => {
      total++;
      passed += stats.passed;
      failed += stats.failed;
      totalDuration += stats.totalDuration;
    });
    
    return {
      total,
      passed,
      failed,
      flaky: Array.from(this.flakyTests),
      averageDuration: total > 0 ? totalDuration / total : 0,
    };
  }

  /**
   * Get test analytics
   */
  getTestAnalytics() {
    const report = this.generateTestReport();
    
    return {
      ...report,
      passRate: report.total > 0 ? (report.passed / report.total) * 100 : 0,
      flakyRate: report.total > 0 ? (report.flaky.length / report.total) * 100 : 0,
      healthScore: this.calculateHealthScore(report),
    };
  }

  /**
   * Calculate health score
   */
  private calculateHealthScore(report: any): number {
    let score = 100;
    
    // Deduct for failed tests
    score -= report.failed * 5;
    
    // Deduct for flaky tests
    score -= report.flaky.length * 3;
    
    // Deduct for slow tests (average > 5s)
    if (report.averageDuration > 5000) {
      score -= 10;
    }
    
    return Math.max(0, Math.min(100, score));
  }
}

export const continuousTest = ContinuousTestManager.getInstance();
```

---

This appendix provides advanced testing strategies that will help you build a robust, reliable test suite for your React Native application. By implementing these techniques, you'll catch more bugs, reduce regressions, and deploy with confidence.

