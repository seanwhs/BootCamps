# Primer 12: Testing Patterns & Best Practices

## Your Complete Guide to Effective Mobile Testing

Welcome to the Testing Patterns & Best Practices Primer! This guide covers advanced testing strategies, patterns, and best practices for React Native applications. Testing is not just about writing tests—it's about building a reliable, maintainable application that you can confidently ship to users.

---

## T.1 Testing Strategy Overview

### The Concept: A Holistic Testing Approach

A comprehensive testing strategy ensures your app works correctly at every level—from individual functions to complete user flows.

**Simple Analogy:** Think of testing like a quality control process in manufacturing. You have multiple checks:
- **Unit testing** = Inspecting individual components before assembly
- **Integration testing** = Checking how components fit together
- **E2E testing** = Testing the final product as a complete unit
- **Manual testing** = Having a human test the final product

### Testing Pyramid

```
        /\
       /  \      E2E Tests (Few, Slow, Expensive)
      /    \     
     /______\    Integration Tests (Some, Medium)
    /        \
   /__________\  Unit Tests (Many, Fast, Cheap)
```

### Test Types Comparison

| Type | Purpose | Speed | Cost | Frequency |
|------|---------|-------|------|-----------|
| Unit Test | Individual functions | ⚡ Fast | 💰 Cheap | Every commit |
| Component Test | UI components | 🏃 Medium | 💰 Cheap | Every commit |
| Integration Test | Multiple units | 🏃 Medium | 💰💰 Medium | Every PR |
| E2E Test | Complete flows | 🐢 Slow | 💰💰💰 Expensive | Release |

---

## T.2 Unit Testing Patterns

### The Concept: Testing Individual Units

Unit tests verify that individual pieces of code work correctly in isolation.

### Complete Unit Testing Patterns

```typescript
// 1. Arrange-Act-Assert Pattern
import { loginService } from '@services/loginService';

describe('Login Service', () => {
  it('should login successfully with valid credentials', async () => {
    // Arrange - Setup test data
    const credentials = {
      email: 'test@example.com',
      password: 'password123',
    };
    const mockResponse = { token: 'jwt-token', user: { id: 1, email: 'test@example.com' } };
    (apiClient.post as jest.Mock).mockResolvedValue(mockResponse);

    // Act - Execute the function
    const result = await loginService.login(credentials);

    // Assert - Verify the result
    expect(result).toEqual(mockResponse);
    expect(apiClient.post).toHaveBeenCalledWith('/auth/login', credentials);
  });

  it('should handle invalid credentials', async () => {
    // Arrange
    const credentials = { email: 'wrong@example.com', password: 'wrong' };
    const mockError = new Error('Invalid credentials');
    (apiClient.post as jest.Mock).mockRejectedValue(mockError);

    // Act & Assert
    await expect(loginService.login(credentials)).rejects.toThrow('Invalid credentials');
  });
});

// 2. Given-When-Then Pattern
describe('UserRepository', () => {
  describe('When creating a new user', () => {
    // Given - Setup
    const userData = { name: 'John', email: 'john@example.com' };
    
    it('should create user with correct data', async () => {
      // When - Execute
      const user = await userRepository.create(userData);
      
      // Then - Verify
      expect(user.name).toBe('John');
      expect(user.email).toBe('john@example.com');
      expect(user.id).toBeDefined();
    });
  });
});

// 3. Setup and Teardown
describe('Database Operations', () => {
  let userId: string;

  // Setup before each test
  beforeEach(async () => {
    // Create test data
    const user = await userRepository.create({
      name: 'Test User',
      email: 'test@example.com',
    });
    userId = user.id;
  });

  // Cleanup after each test
  afterEach(async () => {
    // Delete test data
    if (userId) {
      await userRepository.delete(userId);
    }
  });

  it('should find user by ID', async () => {
    const user = await userRepository.getById(userId);
    expect(user).toBeDefined();
    expect(user?.id).toBe(userId);
  });
});

// 4. Mocking External Dependencies
jest.mock('@api/supabase');
jest.mock('@react-native-async-storage/async-storage');

describe('Auth Store', () => {
  let authStore: any;

  beforeEach(() => {
    // Create fresh store for each test
    authStore = useAuthStore.getState();
    jest.clearAllMocks();
  });

  it('should handle login flow correctly', async () => {
    // Mock successful login
    (supabase.auth.signInWithPassword as jest.Mock).mockResolvedValue({
      data: { user: mockUser, session: mockSession },
      error: null,
    });

    await authStore.login('test@example.com', 'password');

    expect(authStore.user).toEqual(mockUser);
    expect(authStore.isAuthenticated).toBe(true);
    expect(authStore.error).toBe(null);
  });
});

// 5. Snapshot Testing
import renderer from 'react-test-renderer';

describe('Button Component', () => {
  it('should match snapshot for primary button', () => {
    const tree = renderer
      .create(
        <Button 
          title="Click Me" 
          variant="primary" 
          onPress={() => {}}
        />
      )
      .toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('should match snapshot for disabled button', () => {
    const tree = renderer
      .create(
        <Button 
          title="Click Me" 
          variant="primary" 
          disabled 
          onPress={() => {}}
        />
      )
      .toJSON();
    expect(tree).toMatchSnapshot();
  });
});
```

---

## T.3 Component Testing Patterns

### The Concept: Testing UI Components

Component tests verify that UI components render correctly and respond to user interactions.

### Complete Component Testing Patterns

```typescript
// 1. Render Tests
import { render, screen } from '@testing-library/react-native';

describe('Button Component', () => {
  it('renders correctly with title', () => {
    render(<Button title="Click Me" onPress={jest.fn()} />);
    expect(screen.getByText('Click Me')).toBeTruthy();
  });

  it('renders loading state', () => {
    render(<Button title="Click Me" onPress={jest.fn()} loading />);
    expect(screen.getByTestId('activity-indicator')).toBeTruthy();
    expect(screen.queryByText('Click Me')).toBeNull();
  });
});

// 2. Interaction Tests
describe('Input Component', () => {
  it('handles text input correctly', () => {
    const onChangeText = jest.fn();
    render(<Input value="" onChangeText={onChangeText} />);
    
    const input = screen.getByTestId('text-input');
    fireEvent.changeText(input, 'Hello World');
    
    expect(onChangeText).toHaveBeenCalledWith('Hello World');
  });

  it('shows error state when error prop is provided', () => {
    render(
      <Input 
        value="test" 
        onChangeText={jest.fn()} 
        error="Invalid input" 
        touched 
      />
    );
    expect(screen.getByText('Invalid input')).toBeTruthy();
  });
});

// 3. Integration with State
import { useAuthStore } from '@store';
import { render, fireEvent } from '@testing-library/react-native';

describe('Login Screen', () => {
  it('handles login flow', async () => {
    const mockLogin = jest.fn();
    (useAuthStore as jest.Mock).mockReturnValue({
      login: mockLogin,
      isLoading: false,
      error: null,
    });

    render(<LoginScreen navigation={mockNavigation} />);

    // Fill form
    fireEvent.changeText(screen.getByPlaceholderText('Email'), 'test@example.com');
    fireEvent.changeText(screen.getByPlaceholderText('Password'), 'password123');
    
    // Submit
    fireEvent.press(screen.getByText('Sign In'));

    expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password123');
  });
});

// 4. Testing Custom Hooks
import { renderHook, act } from '@testing-library/react-hooks';
import { useDebounce } from '@hooks/useDebounce';

describe('useDebounce', () => {
  jest.useFakeTimers();

  it('should debounce value changes', () => {
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      { initialProps: { value: 'initial', delay: 500 } }
    );

    expect(result.current).toBe('initial');

    rerender({ value: 'updated', delay: 500 });
    
    act(() => {
      jest.advanceTimersByTime(300);
    });
    expect(result.current).toBe('initial');
    
    act(() => {
      jest.advanceTimersByTime(200);
    });
    expect(result.current).toBe('updated');
  });
});

// 5. Testing Navigation
describe('Navigation Flow', () => {
  it('navigates correctly to detail screen', () => {
    const navigation = useNavigation();
    const screen = render(<HomeScreen navigation={navigation} />);
    
    fireEvent.press(screen.getByText('View Detail'));
    
    expect(navigation.navigate).toHaveBeenCalledWith('Detail', { id: '123' });
  });
});
```

---

## T.4 Integration Testing Patterns

### The Concept: Testing Multiple Units Together

Integration tests verify that different parts of your app work together correctly.

### Complete Integration Testing Patterns

```typescript
// 1. Store + API Integration
describe('Auth Store Integration', () => {
  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
    jest.clearAllMocks();
  });

  it('should integrate with login API', async () => {
    // Mock API response
    (authService.login as jest.Mock).mockResolvedValue({
      user: mockUser,
      session: mockSession,
    });

    const { login } = useAuthStore.getState();
    await login('test@example.com', 'password');

    expect(authService.login).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password',
    });
    
    const state = useAuthStore.getState();
    expect(state.user).toEqual(mockUser);
    expect(state.isAuthenticated).toBe(true);
  });
});

// 2. Database + Repository Integration
describe('Form Repository Integration', () => {
  let testFormId: string;

  beforeEach(async () => {
    await dbUtils.clearAll();
  });

  it('should create and retrieve a form', async () => {
    const form = await FormRepository.create('user-123', {
      title: 'Test Form',
      description: 'Test Description',
      fields: [],
    });

    const retrieved = await FormRepository.getById(form.id);
    expect(retrieved).toBeDefined();
    expect(retrieved?.title).toBe('Test Form');
  });

  it('should update a form', async () => {
    const form = await FormRepository.create('user-123', {
      title: 'Original Title',
      description: 'Original Description',
      fields: [],
    });

    const updated = await FormRepository.update(form.id, {
      title: 'Updated Title',
    });

    expect(updated.title).toBe('Updated Title');
    expect(updated.syncStatus).toBe('pending');
  });
});

// 3. Navigation + State Integration
describe('Auth Navigation Integration', () => {
  it('should navigate to main screen after login', async () => {
    const navigation = useNavigation();
    const { login } = useAuthStore.getState();
    (authService.login as jest.Mock).mockResolvedValue({ user: mockUser });

    await login('test@example.com', 'password');

    expect(navigation.replace).toHaveBeenCalledWith('Main');
  });
});
```

---

## T.5 E2E Testing Patterns

### The Concept: Testing Complete User Journeys

E2E tests simulate real user interactions with your app.

### Complete E2E Testing Patterns

```typescript
// 1. Authentication Flow
// e2e/auth.e2e.js
describe('Authentication Flow', () => {
  beforeAll(async () => {
    await device.launchApp({
      newInstance: true,
      permissions: { notifications: 'YES' },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should login successfully', async () => {
    // Enter credentials
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.id('passwordInput')).typeText('Password123!');
    await element(by.text('Sign In')).tap();

    // Verify login success
    await waitFor(element(by.text('Dashboard')))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('should show validation errors for empty fields', async () => {
    await element(by.text('Sign In')).tap();
    
    await expect(element(by.text('Email is required'))).toBeVisible();
    await expect(element(by.text('Password is required'))).toBeVisible();
  });
});

// 2. Data Collection Flow
describe('Data Collection Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
    await login(); // Helper function to login
  });

  it('should create a new collection entry', async () => {
    // Navigate to forms
    await element(by.text('Forms')).tap();
    await waitFor(element(by.text('Sample Form')))
      .toBeVisible()
      .withTimeout(5000);

    // Fill form
    await element(by.id('field1')).typeText('Test Entry');
    await element(by.id('field2')).typeText('test@example.com');
    
    // Submit
    await element(by.text('Submit')).tap();
    
    await waitFor(element(by.text('Entry submitted successfully')))
      .toBeVisible()
      .withTimeout(5000);
  });

  it('should save and recover draft', async () => {
    await element(by.text('Forms')).tap();
    await element(by.text('Sample Form')).tap();
    
    await element(by.id('field1')).typeText('Draft Entry');
    await element(by.text('Save Draft')).tap();
    
    await waitFor(element(by.text('Draft saved successfully')))
      .toBeVisible()
      .withTimeout(5000);
    
    await element(by.text('Collections')).tap();
    await element(by.text('Drafts')).tap();
    
    await expect(element(by.text('Draft Entry'))).toBeVisible();
  });
});

// 3. Offline Sync Flow
describe('Offline Sync Flow', () => {
  it('should sync data when coming online', async () => {
    // Disable network
    await device.setBiometricEnrollment(true);
    await device.setOrientation('portrait');
    
    // Create entry offline
    await element(by.text('Forms')).tap();
    await element(by.text('Sample Form')).tap();
    await element(by.id('field1')).typeText('Offline Entry');
    await element(by.text('Submit')).tap();
    
    // Enable network
    await device.setBiometricEnrollment(true);
    
    // Wait for sync
    await waitFor(element(by.text('All synced')))
      .toBeVisible()
      .withTimeout(15000);
  });
});
```

---

## T.6 Test Data Management

### The Concept: Managing Test Data

Proper test data management ensures reliable, repeatable tests.

### Complete Test Data Guide

```typescript
// 1. Test Data Factory
// __tests__/factories.ts
export const factories = {
  user: (overrides = {}) => ({
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: new Date().toISOString(),
    ...overrides,
  }),
  
  form: (overrides = {}) => ({
    id: 'form-123',
    title: 'Test Form',
    description: 'Test Description',
    fields: [
      { id: 'field1', label: 'Name', type: 'text', required: true },
      { id: 'field2', label: 'Email', type: 'text', required: true },
    ],
    userId: 'user-123',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    ...overrides,
  }),
  
  collection: (overrides = {}) => ({
    id: 'collection-123',
    formId: 'form-123',
    userId: 'user-123',
    data: { field1: 'John Doe', field2: 'john@example.com' },
    status: 'draft',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    ...overrides,
  }),
};

// 2. Test Database Setup
// __tests__/setup/database.ts
import { database, dbUtils } from '@database';

export const setupTestDatabase = async () => {
  await dbUtils.clearAll();
  
  // Insert test data
  await database.write(async () => {
    // Create test user
    await database.get('users').create(record => {
      record.id = 'test-user';
      record.email = 'test@example.com';
      record.fullName = 'Test User';
    });
  });
};

// 3. Test API Mock
// __tests__/mocks/api.ts
export const mockApi = {
  auth: {
    login: jest.fn().mockResolvedValue({
      user: factories.user(),
      token: 'jwt-token',
    }),
    logout: jest.fn().mockResolvedValue({ success: true }),
  },
  forms: {
    get: jest.fn().mockResolvedValue([factories.form()]),
    create: jest.fn().mockResolvedValue(factories.form()),
    update: jest.fn().mockResolvedValue(factories.form()),
    delete: jest.fn().mockResolvedValue({ success: true }),
  },
};
```

---

## T.7 CI/CD Testing Integration

### The Concept: Automated Testing in CI/CD

Integrating tests into CI/CD ensures quality before deployment.

### Complete CI/CD Testing Guide

```yaml
# .github/workflows/test.yml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linting
        run: npm run lint
      
      - name: Run type checking
        run: npm run type-check
      
      - name: Run unit and integration tests
        run: npm run test:ci
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          directory: ./coverage

  e2e:
    name: E2E Tests
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Detox dependencies
        run: brew tap wix/brew && brew install applesimutils
      
      - name: Build and run E2E tests
        run: npm run test:e2e:ci
```

---

## T.8 Quick Reference

### Testing Commands

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- --testPathPattern=button

# Run E2E tests
npm run test:e2e

# Run E2E with specific configuration
detox test -c ios.sim.debug
detox test -c android.emu.debug

# Run CI tests
npm run test:ci

# Generate coverage report
npm run coverage
```

### Testing Checklist

| Item | Status |
|------|--------|
| Unit tests for utilities | ✅ |
| Component tests for UI | ✅ |
| Integration tests for stores | ✅ |
| E2E tests for critical flows | ✅ |
| Code coverage ≥ 70% | ✅ |
| Tests run in CI | ✅ |
| E2E tests pass | ✅ |
| Linting passes | ✅ |
| Type checking passes | ✅ |
| No flaky tests | ✅ |

---

**Ready to build a tested, reliable app? Let's build NexusCollect!**
