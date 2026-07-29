# Part 4: Testing, Performance & Production Deployment
## Phase 1: Testing Strategies

Welcome to the final part of the series! Your TaskFlow app is feature-complete, visually stunning, and responsive. Now it's time to make it bulletproof. In this phase, you'll learn comprehensive testing strategies—unit tests, integration tests, and component tests—to ensure your app works flawlessly in production.

---

## Target 1: Setting Up the Testing Environment

**The Target:** Configure Jest and React Native Testing Library.

**The Concept:** Testing is your safety net. It catches bugs before users do, ensures features work as expected, and gives you confidence when refactoring code.

### Installation

```bash
# Install testing dependencies
npm install --save-dev @testing-library/react-native jest jest-expo
npm install --save-dev @testing-library/jest-native
npm install --save-dev @testing-library/react-hooks
npm install --save-dev @types/jest

# For mocking and utilities
npm install --save-dev ts-jest react-test-renderer

# For native module mocking
npm install --save-dev react-native-mock-render
```

### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: [
    '<rootDir>/jest.setup.js',
    '@testing-library/jest-native/extend-expect',
  ],
  transformIgnorePatterns: [
    'node_modules/(?!(jest-)?react-native|react-native|@react-native|@react-navigation|expo|@expo|expo-notifications|expo-asset|expo-constants|@expo/vector-icons)',
  ],
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.types.ts',
    '!src/**/index.ts',
    '!src/**/*.stories.tsx',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};
```

### Test Setup File

```typescript
// jest.setup.js
import { NativeModules } from 'react-native';

// Mock React Native modules
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

// Mock Expo modules
jest.mock('expo-notifications', () => ({
  addNotificationReceivedListener: jest.fn(),
  addNotificationResponseReceivedListener: jest.fn(),
  requestPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  getPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  scheduleNotificationAsync: jest.fn().mockResolvedValue('test-notification-id'),
  cancelScheduledNotificationAsync: jest.fn(),
  cancelAllScheduledNotificationsAsync: jest.fn(),
}));

jest.mock('expo-location', () => ({
  requestForegroundPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  getCurrentPositionAsync: jest.fn().mockResolvedValue({
    coords: { latitude: 37.78825, longitude: -122.4324 },
    timestamp: Date.now(),
  }),
  reverseGeocodeAsync: jest.fn().mockResolvedValue([
    { street: 'Test St', city: 'Test City', region: 'Test Region', country: 'Test Country' },
  ]),
}));

jest.mock('expo-camera', () => ({
  requestCameraPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
  Camera: {
    Constants: {
      Type: { back: 'back', front: 'front' },
      FlashMode: { on: 'on', off: 'off' },
    },
  },
}));

jest.mock('expo-image-picker', () => ({
  launchCameraAsync: jest.fn().mockResolvedValue({
    canceled: false,
    assets: [{ uri: 'test-uri', width: 100, height: 100 }],
  }),
  launchImageLibraryAsync: jest.fn().mockResolvedValue({
    canceled: false,
    assets: [{ uri: 'test-uri', width: 100, height: 100 }],
  }),
  requestMediaLibraryPermissionsAsync: jest.fn().mockResolvedValue({ status: 'granted' }),
}));

jest.mock('expo-secure-store', () => ({
  setItemAsync: jest.fn().mockResolvedValue(undefined),
  getItemAsync: jest.fn().mockResolvedValue('test-token'),
  deleteItemAsync: jest.fn().mockResolvedValue(undefined),
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  setItem: jest.fn(),
  getItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
  getAllKeys: jest.fn(),
}));

jest.mock('react-native-mmkv', () => ({
  MMKV: jest.fn().mockImplementation(() => ({
    set: jest.fn(),
    getString: jest.fn(),
    getNumber: jest.fn(),
    getBoolean: jest.fn(),
    delete: jest.fn(),
    getAllKeys: jest.fn(),
    clearAll: jest.fn(),
  })),
}));

// Mock React Navigation
jest.mock('@react-navigation/native', () => ({
  ...jest.requireActual('@react-navigation/native'),
  useNavigation: () => ({
    navigate: jest.fn(),
    goBack: jest.fn(),
    replace: jest.fn(),
    reset: jest.fn(),
    canGoBack: jest.fn(() => true),
  }),
  useRoute: () => ({
    params: {},
  }),
}));

// Mock Device
jest.mock('expo-device', () => ({
  isDevice: true,
  modelName: 'Test Device',
}));

// Mock haptics
jest.mock('expo-haptics', () => ({
  impactAsync: jest.fn(),
  notificationAsync: jest.fn(),
  selectionAsync: jest.fn(),
  ImpactFeedbackStyle: { Light: 'light', Medium: 'medium', Heavy: 'heavy' },
  NotificationFeedbackType: { Success: 'success', Warning: 'warning', Error: 'error' },
}));
```

---

## Target 2: Unit Testing - Testing Isolated Logic

**The Target:** Write comprehensive unit tests for pure functions and utilities.

**The Concept:** Unit tests verify individual pieces of logic in isolation. They're fast, reliable, and help catch edge cases early.

### Testing Utility Functions

```typescript
// src/__tests__/utils/dateUtils.test.ts
import {
  formatDate,
  isOverdue,
  getDaysRemaining,
  isToday,
  isTomorrow,
  getRelativeDate,
} from '../../utils/dateUtils';

describe('Date Utilities', () => {
  describe('formatDate', () => {
    it('formats date correctly', () => {
      const date = new Date(2024, 0, 15); // Jan 15, 2024
      expect(formatDate(date, 'short')).toBe('01/15/2024');
      expect(formatDate(date, 'long')).toBe('January 15, 2024');
      expect(formatDate(date, 'relative')).toBe('Jan 15');
    });

    it('handles invalid dates gracefully', () => {
      expect(formatDate(null as any, 'short')).toBe('Invalid date');
      expect(formatDate(undefined as any, 'short')).toBe('Invalid date');
    });
  });

  describe('isOverdue', () => {
    it('returns true for past dates', () => {
      const pastDate = new Date(Date.now() - 86400000); // Yesterday
      expect(isOverdue(pastDate)).toBe(true);
    });

    it('returns false for future dates', () => {
      const futureDate = new Date(Date.now() + 86400000); // Tomorrow
      expect(isOverdue(futureDate)).toBe(false);
    });

    it('returns false for today', () => {
      const today = new Date();
      expect(isOverdue(today)).toBe(false);
    });
  });

  describe('getDaysRemaining', () => {
    it('returns positive days for future dates', () => {
      const futureDate = new Date(Date.now() + 86400000 * 3); // 3 days
      expect(getDaysRemaining(futureDate)).toBe(3);
    });

    it('returns negative days for past dates', () => {
      const pastDate = new Date(Date.now() - 86400000 * 2); // 2 days ago
      expect(getDaysRemaining(pastDate)).toBe(-2);
    });

    it('returns 0 for today', () => {
      const today = new Date();
      expect(getDaysRemaining(today)).toBe(0);
    });
  });

  describe('isToday', () => {
    it('returns true for today', () => {
      const today = new Date();
      expect(isToday(today)).toBe(true);
    });

    it('returns false for other dates', () => {
      const yesterday = new Date(Date.now() - 86400000);
      expect(isToday(yesterday)).toBe(false);
    });
  });

  describe('isTomorrow', () => {
    it('returns true for tomorrow', () => {
      const tomorrow = new Date(Date.now() + 86400000);
      expect(isTomorrow(tomorrow)).toBe(true);
    });

    it('returns false for other dates', () => {
      const today = new Date();
      expect(isTomorrow(today)).toBe(false);
    });
  });

  describe('getRelativeDate', () => {
    it('returns "Today" for today', () => {
      const today = new Date();
      expect(getRelativeDate(today)).toBe('Today');
    });

    it('returns "Tomorrow" for tomorrow', () => {
      const tomorrow = new Date(Date.now() + 86400000);
      expect(getRelativeDate(tomorrow)).toBe('Tomorrow');
    });

    it('returns "Yesterday" for yesterday', () => {
      const yesterday = new Date(Date.now() - 86400000);
      expect(getRelativeDate(yesterday)).toBe('Yesterday');
    });

    it('returns formatted date for other days', () => {
      const futureDate = new Date(Date.now() + 86400000 * 3);
      expect(getRelativeDate(futureDate)).toMatch(/\d{2}\/\d{2}\/\d{4}/);
    });
  });
});
```

### Testing Validation Logic

```typescript
// src/__tests__/utils/validation.test.ts
import {
  validateEmail,
  validatePassword,
  validateTaskTitle,
  validateTaskDueDate,
  validateTaskPriority,
  validateTaskCategory,
} from '../../utils/validation';

describe('Validation Utilities', () => {
  describe('validateEmail', () => {
    it('validates correct email addresses', () => {
      expect(validateEmail('test@example.com')).toBe(true);
      expect(validateEmail('user.name@domain.co')).toBe(true);
      expect(validateEmail('test@sub.domain.com')).toBe(true);
    });

    it('rejects invalid email addresses', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail('test')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('test@domain')).toBe(false);
      expect(validateEmail('test domain.com')).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('validates strong passwords', () => {
      expect(validatePassword('Password123!')).toBe(true);
      expect(validatePassword('SecurePass#2024')).toBe(true);
    });

    it('rejects weak passwords', () => {
      expect(validatePassword('')).toBe(false);
      expect(validatePassword('12345')).toBe(false);
      expect(validatePassword('password')).toBe(false);
      expect(validatePassword('PASSWORD123')).toBe(false);
      expect(validatePassword('pass123')).toBe(false); // Too short
    });
  });

  describe('validateTaskTitle', () => {
    it('validates valid titles', () => {
      expect(validateTaskTitle('Complete project')).toBe(true);
      expect(validateTaskTitle('Team meeting')).toBe(true);
      expect(validateTaskTitle('Review design mockups')).toBe(true);
    });

    it('rejects invalid titles', () => {
      expect(validateTaskTitle('')).toBe(false);
      expect(validateTaskTitle('  ')).toBe(false);
      expect(validateTaskTitle('ab')).toBe(false); // Too short
      expect(validateTaskTitle('a'.repeat(101))).toBe(false); // Too long
    });
  });

  describe('validateTaskDueDate', () => {
    it('validates future dates', () => {
      const futureDate = new Date(Date.now() + 86400000);
      expect(validateTaskDueDate(futureDate)).toBe(true);
    });

    it('rejects past dates', () => {
      const pastDate = new Date(Date.now() - 86400000);
      expect(validateTaskDueDate(pastDate)).toBe(false);
    });

    it('allows today', () => {
      const today = new Date();
      expect(validateTaskDueDate(today)).toBe(true);
    });
  });

  describe('validateTaskPriority', () => {
    it('validates valid priorities', () => {
      expect(validateTaskPriority('low')).toBe(true);
      expect(validateTaskPriority('medium')).toBe(true);
      expect(validateTaskPriority('high')).toBe(true);
    });

    it('rejects invalid priorities', () => {
      expect(validateTaskPriority('')).toBe(false);
      expect(validateTaskPriority('invalid')).toBe(false);
      expect(validateTaskPriority('HIGH')).toBe(false);
    });
  });

  describe('validateTaskCategory', () => {
    it('validates valid categories', () => {
      expect(validateTaskCategory('Work')).toBe(true);
      expect(validateTaskCategory('Personal')).toBe(true);
      expect(validateTaskCategory('Shopping')).toBe(true);
    });

    it('rejects invalid categories', () => {
      expect(validateTaskCategory('')).toBe(false);
      expect(validateTaskCategory('  ')).toBe(false);
      expect(validateTaskCategory('a')).toBe(false); // Too short
      expect(validateTaskCategory('a'.repeat(51))).toBe(false); // Too long
    });
  });
});
```

---

## Target 3: Component Testing - Testing UI Components

**The Target:** Write integration tests for React Native components.

**The Concept:** Component tests verify that your UI renders correctly and responds to user interactions as expected.

### Testing a Simple Component

```typescript
// src/__tests__/components/TaskCard.test.tsx
import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react-native';
import { TaskCard } from '../../components/TaskCard';

// Mock task data
const mockTask = {
  id: '1',
  title: 'Test Task',
  description: 'Test Description',
  priority: 'high',
  status: 'todo',
  dueDate: '2024-01-15',
  category: 'Work',
  createdAt: '2024-01-01T00:00:00.000Z',
  updatedAt: '2024-01-01T00:00:00.000Z',
};

describe('TaskCard', () => {
  it('renders task information correctly', () => {
    render(
      <TaskCard
        task={mockTask}
        onPress={jest.fn()}
        onDelete={jest.fn()}
        onEdit={jest.fn()}
      />
    );

    // Check if task title is rendered
    expect(screen.getByText('Test Task')).toBeTruthy();
    
    // Check if task description is rendered
    expect(screen.getByText('Test Description')).toBeTruthy();
    
    // Check if priority indicator is rendered
    const priorityDot = screen.getByTestId('priority-indicator');
    expect(priorityDot.props.style).toContainEqual(
      expect.objectContaining({ backgroundColor: '#e74c3c' })
    );
    
    // Check if due date is rendered
    expect(screen.getByText(/Due: 2024-01-15/)).toBeTruthy();
  });

  it('calls onPress when tapped', () => {
    const mockOnPress = jest.fn();
    
    render(
      <TaskCard
        task={mockTask}
        onPress={mockOnPress}
        onDelete={jest.fn()}
        onEdit={jest.fn()}
      />
    );

    const card = screen.getByTestId('task-card');
    fireEvent.press(card);
    
    expect(mockOnPress).toHaveBeenCalledTimes(1);
    expect(mockOnPress).toHaveBeenCalledWith(mockTask);
  });

  it('calls onEdit when edit button is pressed', () => {
    const mockOnEdit = jest.fn();
    
    render(
      <TaskCard
        task={mockTask}
        onPress={jest.fn()}
        onDelete={jest.fn()}
        onEdit={mockOnEdit}
      />
    );

    const editButton = screen.getByTestId('edit-button');
    fireEvent.press(editButton);
    
    expect(mockOnEdit).toHaveBeenCalledTimes(1);
    expect(mockOnEdit).toHaveBeenCalledWith(mockTask);
  });

  it('calls onDelete when delete button is pressed', () => {
    const mockOnDelete = jest.fn();
    
    render(
      <TaskCard
        task={mockTask}
        onPress={jest.fn()}
        onDelete={mockOnDelete}
        onEdit={jest.fn()}
      />
    );

    const deleteButton = screen.getByTestId('delete-button');
    fireEvent.press(deleteButton);
    
    expect(mockOnDelete).toHaveBeenCalledTimes(1);
    expect(mockOnDelete).toHaveBeenCalledWith(mockTask.id);
  });

  it('displays different colors for different priorities', () => {
    const priorities = ['low', 'medium', 'high'];
    const expectedColors = ['#2ecc71', '#f39c12', '#e74c3c'];

    priorities.forEach((priority, index) => {
      const task = { ...mockTask, priority: priority as any };
      const { rerender } = render(
        <TaskCard
          task={task}
          onPress={jest.fn()}
          onDelete={jest.fn()}
          onEdit={jest.fn()}
        />
      );

      const priorityDot = screen.getByTestId('priority-indicator');
      expect(priorityDot.props.style).toContainEqual(
        expect.objectContaining({ backgroundColor: expectedColors[index] })
      );

      rerender(<TaskCard
        task={task}
        onPress={jest.fn()}
        onDelete={jest.fn()}
        onEdit={jest.fn()}
      />);
    });
  });

  it('shows different status indicators', () => {
    const statuses = ['todo', 'in-progress', 'done'];
    
    statuses.forEach((status) => {
      const task = { ...mockTask, status: status as any };
      const { rerender } = render(
        <TaskCard
          task={task}
          onPress={jest.fn()}
          onDelete={jest.fn()}
          onEdit={jest.fn()}
        />
      );

      const statusBadge = screen.getByTestId('status-badge');
      const statusText = screen.getByTestId('status-text');
      
      if (status === 'done') {
        expect(statusText.props.children).toBe('✓');
      } else {
        expect(statusText.props.children).toBe('○');
      }

      rerender(<TaskCard
        task={task}
        onPress={jest.fn()}
        onDelete={jest.fn()}
        onEdit={jest.fn()}
      />);
    });
  });
});
```

### Testing a Form Component

```typescript
// src/__tests__/components/TaskForm.test.tsx
import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react-native';
import { TaskForm } from '../../components/TaskForm';

describe('TaskForm', () => {
  const mockOnSubmit = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders all form fields', () => {
    render(<TaskForm onSubmit={mockOnSubmit} />);

    expect(screen.getByTestId('title-input')).toBeTruthy();
    expect(screen.getByTestId('description-input')).toBeTruthy();
    expect(screen.getByTestId('priority-selector')).toBeTruthy();
    expect(screen.getByTestId('due-date-picker')).toBeTruthy();
    expect(screen.getByTestId('category-input')).toBeTruthy();
    expect(screen.getByTestId('assignee-input')).toBeTruthy();
  });

  it('validates required fields', async () => {
    render(<TaskForm onSubmit={mockOnSubmit} />);

    const submitButton = screen.getByTestId('submit-button');
    fireEvent.press(submitButton);

    // Wait for validation errors
    await waitFor(() => {
      expect(screen.getByText('Title is required')).toBeTruthy();
      expect(screen.getByText('Due date cannot be in the past')).toBeTruthy();
      expect(screen.getByText('Category is required')).toBeTruthy();
    });

    expect(mockOnSubmit).not.toHaveBeenCalled();
  });

  it('validates title length', async () => {
    render(<TaskForm onSubmit={mockOnSubmit} />);

    const titleInput = screen.getByTestId('title-input');
    fireEvent.changeText(titleInput, 'ab');
    fireEvent(titleInput, 'blur');

    await waitFor(() => {
      expect(screen.getByText('Title must be at least 3 characters')).toBeTruthy();
    });
  });

  it('submits valid form data', async () => {
    render(<TaskForm onSubmit={mockOnSubmit} />);

    // Fill in form
    const titleInput = screen.getByTestId('title-input');
    fireEvent.changeText(titleInput, 'Test Task');

    const descriptionInput = screen.getByTestId('description-input');
    fireEvent.changeText(descriptionInput, 'Test Description');

    const categoryInput = screen.getByTestId('category-input');
    fireEvent.changeText(categoryInput, 'Work');

    // Mock date picker
    const datePicker = screen.getByTestId('due-date-picker');
    fireEvent.press(datePicker);
    // Assuming date picker triggers onChange with selected date

    const submitButton = screen.getByTestId('submit-button');
    fireEvent.press(submitButton);

    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledTimes(1);
      expect(mockOnSubmit).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'Test Task',
          description: 'Test Description',
          category: 'Work',
          priority: 'medium',
        })
      );
    });
  });

  it('handles initial data correctly', () => {
    const initialData = {
      title: 'Existing Task',
      description: 'Existing Description',
      priority: 'high',
      dueDate: new Date('2024-02-01'),
      category: 'Personal',
      assignee: 'John Doe',
    };

    render(
      <TaskForm
        initialData={initialData}
        onSubmit={mockOnSubmit}
      />
    );

    const titleInput = screen.getByTestId('title-input');
    expect(titleInput.props.value).toBe('Existing Task');

    const descriptionInput = screen.getByTestId('description-input');
    expect(descriptionInput.props.value).toBe('Existing Description');

    const categoryInput = screen.getByTestId('category-input');
    expect(categoryInput.props.value).toBe('Personal');
  });

  it('shows loading state when isLoading is true', () => {
    render(
      <TaskForm
        onSubmit={mockOnSubmit}
        isLoading={true}
      />
    );

    const submitButton = screen.getByTestId('submit-button');
    expect(submitButton.props.disabled).toBe(true);
    expect(screen.getByTestId('loading-indicator')).toBeTruthy();
  });
});
```

### Testing Zustand Stores

```typescript
// src/__tests__/stores/authStore.test.ts
import { act, renderHook } from '@testing-library/react-native';
import { useAuthStore } from '../../stores/authStore';

describe('AuthStore', () => {
  beforeEach(() => {
    // Reset store before each test
    act(() => {
      useAuthStore.setState({
        user: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      });
    });
  });

  it('should initialize with default values', () => {
    const { result } = renderHook(() => useAuthStore());
    
    expect(result.current.user).toBeNull();
    expect(result.current.token).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it('should handle successful login', async () => {
    const { result } = renderHook(() => useAuthStore());
    
    await act(async () => {
      await result.current.login('demo@example.com', 'password');
    });

    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user).not.toBeNull();
    expect(result.current.user?.email).toBe('demo@example.com');
    expect(result.current.token).toBe('mock-jwt-token-12345');
    expect(result.current.error).toBeNull();
    expect(result.current.isLoading).toBe(false);
  });

  it('should handle login failure', async () => {
    const { result } = renderHook(() => useAuthStore());
    
    await act(async () => {
      try {
        await result.current.login('wrong@example.com', 'wrong');
      } catch (error) {
        // Expected error
      }
    });

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.user).toBeNull();
    expect(result.current.token).toBeNull();
    expect(result.current.error).toBe('Invalid email or password');
    expect(result.current.isLoading).toBe(false);
  });

  it('should validate email on login', async () => {
    const { result } = renderHook(() => useAuthStore());
    
    await act(async () => {
      try {
        await result.current.login('invalid-email', 'password');
      } catch (error) {
        // Expected error
      }
    });

    expect(result.current.error).toBe('Please enter a valid email address');
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('should handle logout correctly', () => {
    const { result } = renderHook(() => useAuthStore());
    
    act(() => {
      result.current.logout();
    });

    expect(result.current.user).toBeNull();
    expect(result.current.token).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.isLoading).toBe(false);
  });

  it('should update user data', () => {
    const { result } = renderHook(() => useAuthStore());
    
    // First login to set user
    act(() => {
      useAuthStore.setState({
        user: {
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: new Date().toISOString(),
        },
        isAuthenticated: true,
      });
    });

    // Update user
    act(() => {
      result.current.updateUser({ name: 'Updated Name' });
    });

    expect(result.current.user?.name).toBe('Updated Name');
    expect(result.current.user?.email).toBe('test@example.com'); // Unchanged
  });
});
```

---

## Target 4: Integration Testing - Testing Feature Flows

**The Target:** Test complete user flows and feature integrations.

**The Concept:** Integration tests verify that different parts of your app work together correctly. They test real user scenarios from start to finish.

### Testing Task Creation Flow

```typescript
// src/__tests__/integration/taskFlow.test.tsx
import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react-native';
import { NavigationContainer } from '@react-navigation/native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { TasksScreen } from '../../screens/tasks/TasksScreen';
import { useTaskStore } from '../../stores/taskStore';
import { useAuthStore } from '../../stores/authStore';

describe('Task Flow Integration', () => {
  beforeEach(() => {
    // Reset stores
    useTaskStore.setState({
      tasks: [],
      isLoading: false,
      error: null,
      filters: { search: '' },
    });

    useAuthStore.setState({
      user: { id: '1', name: 'Test User', email: 'test@example.com', createdAt: '2024-01-01' },
      isAuthenticated: true,
    });
  });

  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <SafeAreaProvider>
        <NavigationContainer>
          {component}
        </NavigationContainer>
      </SafeAreaProvider>
    );
  };

  it('should display empty state when no tasks exist', async () => {
    renderWithProviders(<TasksScreen />);

    await waitFor(() => {
      expect(screen.getByText('No tasks found')).toBeTruthy();
      expect(screen.getByText('Create a new task to get started')).toBeTruthy();
    });
  });

  it('should display tasks after loading', async () => {
    // Pre-populate tasks
    useTaskStore.setState({
      tasks: [
        {
          id: '1',
          title: 'Test Task 1',
          description: 'Description 1',
          priority: 'high',
          status: 'todo',
          dueDate: '2024-01-15',
          category: 'Work',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
        {
          id: '2',
          title: 'Test Task 2',
          description: 'Description 2',
          priority: 'medium',
          status: 'in-progress',
          dueDate: '2024-01-16',
          category: 'Personal',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
      ],
    });

    renderWithProviders(<TasksScreen />);

    await waitFor(() => {
      expect(screen.getByText('Test Task 1')).toBeTruthy();
      expect(screen.getByText('Test Task 2')).toBeTruthy();
    });
  });

  it('should filter tasks by status', async () => {
    // Pre-populate tasks with different statuses
    useTaskStore.setState({
      tasks: [
        {
          id: '1',
          title: 'Todo Task',
          description: 'Todo description',
          priority: 'low',
          status: 'todo',
          dueDate: '2024-01-15',
          category: 'Work',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
        {
          id: '2',
          title: 'Done Task',
          description: 'Done description',
          priority: 'low',
          status: 'done',
          dueDate: '2024-01-14',
          category: 'Work',
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
      ],
    });

    renderWithProviders(<TasksScreen />);

    // Press "Todo" filter button
    const todoFilter = screen.getByText('Todo');
    fireEvent.press(todoFilter);

    await waitFor(() => {
      expect(screen.getByText('Todo Task')).toBeTruthy();
      expect(screen.queryByText('Done Task')).toBeNull();
    });

    // Press "Done" filter button
    const doneFilter = screen.getByText('Done');
    fireEvent.press(doneFilter);

    await waitFor(() => {
      expect(screen.getByText('Done Task')).toBeTruthy();
      expect(screen.queryByText('Todo Task')).toBeNull();
    });
  });

  it('should delete a task', async () => {
    const mockDelete = jest.fn();
    const task = {
      id: '1',
      title: 'Task to Delete',
      description: 'Delete this task',
      priority: 'low',
      status: 'todo',
      dueDate: '2024-01-15',
      category: 'Work',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    // Mock delete function
    useTaskStore.setState({
      tasks: [task],
    });

    renderWithProviders(<TasksScreen />);

    // Find and press delete button
    const deleteButton = screen.getByTestId('delete-button');
    fireEvent.press(deleteButton);

    // Confirm deletion
    const confirmButton = screen.getByText('Delete');
    fireEvent.press(confirmButton);

    await waitFor(() => {
      expect(screen.queryByText('Task to Delete')).toBeNull();
    });
  });
});
```

---

## Target 5: End-to-End Testing with Detox

**The Target:** Set up and run end-to-end tests with Detox.

**The Concept:** E2E tests simulate real user interactions on actual devices or simulators. They're the closest you can get to manual testing but automated.

### Detox Configuration

```json
// package.json (add detox scripts)
{
  "scripts": {
    "test:e2e": "detox test --configuration ios.sim.debug",
    "test:e2e:android": "detox test --configuration android.emu.debug",
    "e2e:build": "detox build --configuration ios.sim.debug",
    "e2e:build:android": "detox build --configuration android.emu.debug"
  },
  "detox": {
    "testRunner": {
      "$0": "jest",
      "args": {
        "config": "e2e/config.json",
        "_": ["e2e"]
      }
    },
    "configurations": {
      "ios.sim.debug": {
        "binaryPath": "ios/build/Build/Products/Debug-iphonesimulator/TaskFlow.app",
        "build": "xcodebuild -workspace ios/TaskFlow.xcworkspace -scheme TaskFlow -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build",
        "type": "ios.simulator",
        "device": {
          "type": "iPhone 14"
        }
      },
      "android.emu.debug": {
        "binaryPath": "android/app/build/outputs/apk/debug/app-debug.apk",
        "build": "cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug",
        "type": "android.emulator",
        "device": {
          "avdName": "Pixel_4_API_30"
        }
      }
    }
  }
}
```

### E2E Test Examples

```typescript
// e2e/taskFlow.e2e.ts
import { device, expect, element, by, waitFor } from 'detox';

describe('TaskFlow', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show login screen', async () => {
    await expect(element(by.text('Sign In'))).toBeVisible();
    await expect(element(by.id('email-input'))).toBeVisible();
    await expect(element(by.id('password-input'))).toBeVisible();
  });

  it('should show validation errors on empty login', async () => {
    await element(by.id('login-button')).tap();
    
    await expect(element(by.text('Email and password are required'))).toBeVisible();
  });

  it('should login successfully', async () => {
    await element(by.id('email-input')).typeText('demo@example.com');
    await element(by.id('password-input')).typeText('password');
    await element(by.id('login-button')).tap();

    // Wait for navigation
    await waitFor(element(by.id('home-screen')))
      .toBeVisible()
      .withTimeout(5000);
  });

  it('should create a new task', async () => {
    // Login first
    await element(by.id('email-input')).typeText('demo@example.com');
    await element(by.id('password-input')).typeText('password');
    await element(by.id('login-button')).tap();

    // Navigate to tasks
    await element(by.id('tasks-tab')).tap();
    
    // Tap add task button
    await element(by.id('add-task-button')).tap();
    
    // Fill task form
    await element(by.id('task-title-input')).typeText('E2E Test Task');
    await element(by.id('task-description-input')).typeText('Created by Detox test');
    await element(by.id('task-priority-high')).tap();
    await element(by.id('task-category-input')).typeText('Testing');
    
    // Submit
    await element(by.id('save-task-button')).tap();

    // Verify task appears
    await expect(element(by.text('E2E Test Task'))).toBeVisible();
  });

  it('should complete a task', async () => {
    // Login and navigate to tasks
    await element(by.id('email-input')).typeText('demo@example.com');
    await element(by.id('password-input')).typeText('password');
    await element(by.id('login-button')).tap();
    await element(by.id('tasks-tab')).tap();

    // Find task and tap complete
    const task = element(by.text('E2E Test Task'));
    await task.swipe('right');
    
    // Verify status changed
    await expect(element(by.text('done'))).toBeVisible();
  });

  it('should delete a task', async () => {
    // Login and navigate to tasks
    await element(by.id('email-input')).typeText('demo@example.com');
    await element(by.id('password-input')).typeText('password');
    await element(by.id('login-button')).tap();
    await element(by.id('tasks-tab')).tap();

    // Swipe to delete
    const task = element(by.text('E2E Test Task'));
    await task.swipe('left');
    
    // Confirm delete
    await element(by.text('Delete')).tap();

    // Verify task is gone
    await expect(element(by.text('E2E Test Task'))).not.toBeVisible();
  });
});
```

---

## Verification: Run Tests

```bash
# Run unit tests
npm test

# Run unit tests with coverage
npm test -- --coverage

# Run specific test file
npm test -- src/__tests__/utils/dateUtils.test.ts

# Watch mode (auto-run on changes)
npm test -- --watch

# Run E2E tests (iOS)
npm run e2e:build
npm run test:e2e

# Run E2E tests (Android)
npm run e2e:build:android
npm run test:e2e:android
```

### Test Results Interpretation

```typescript
// Example test output
/*
 PASS  src/__tests__/utils/dateUtils.test.ts
 PASS  src/__tests__/utils/validation.test.ts
 PASS  src/__tests__/components/TaskCard.test.tsx
 PASS  src/__tests__/components/TaskForm.test.tsx
 PASS  src/__tests__/stores/authStore.test.ts
 PASS  src/__tests__/integration/taskFlow.test.tsx

Test Suites: 6 passed, 6 total
Tests:       34 passed, 34 total
Snapshots:   0 total
Time:        12.345 s
Ran all test suites.

Coverage summary:
  Statements   : 78.5% ( 245/312 )
  Branches     : 72.3% ( 102/141 )
  Functions    : 76.8% ( 63/82 )
  Lines        : 78.8% ( 238/302 )
*/
```

---

## What We've Accomplished

Congratulations! You've built a comprehensive testing suite for TaskFlow:

1. **Unit Tests:** Pure functions and utilities
2. **Component Tests:** UI components with interactions
3. **Store Tests:** Zustand stores and state management
4. **Integration Tests:** Complete feature flows
5. **E2E Tests:** Detox for real device/simulator testing
6. **Coverage Reports:** Measure test completeness

### What's Next: Part 4, Phase 2 - Performance Optimization

Next, you'll learn:
- **Performance Profiling:** Identifying bottlenecks
- **Optimization Strategies:** Reducing re-renders, optimizing lists
- **Memory Management:** Preventing leaks
- **Bundle Optimization:** Reducing app size

*Your app is now thoroughly tested and reliable! Next, we'll make it lightning-fast by optimizing performance, reducing bundle size, and ensuring it runs smoothly on all devices.*
