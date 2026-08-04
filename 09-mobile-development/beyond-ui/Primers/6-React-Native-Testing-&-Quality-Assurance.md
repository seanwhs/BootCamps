# Primer 6: React Native Testing & Quality Assurance

## Your Complete Guide to Testing Mobile Applications

Welcome to the Testing Primer! This guide covers everything you need to know about testing React Native applications. Testing is like having a safety net for your code—it catches bugs before they reach users, gives you confidence when making changes, and ensures your app works as expected.

---

## T.1 Why Testing Matters

### The Concept: Building Reliable Applications

Testing is the process of verifying that your code works correctly. It's not just about finding bugs—it's about preventing them, understanding your code better, and maintaining quality as your app grows.

**Simple Analogy:** Think of testing like a quality control process in a factory. Each product (feature) goes through multiple checks (tests) before shipping. If a check fails, the product is fixed before it reaches the customer.

### The Testing Pyramid

```
        /\
       /  \      E2E Tests (User journeys)
      /    \     Integration Tests (Multiple components)
     /______\    Unit Tests (Individual units)
```

---

## T.2 Unit Testing with Jest

### The Concept: Testing the Building Blocks

Unit tests verify that individual pieces of code work correctly in isolation. They're fast, focused, and form the foundation of your test suite.

### Complete Unit Testing Guide

```bash
# 1. Install Jest and dependencies
npm install -D jest @types/jest ts-jest
npm install -D @testing-library/react-native @testing-library/jest-native
npm install -D react-test-renderer

# 2. Configure Jest (jest.config.js)
module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  testRegex: '(/__tests__/.*|(\\.|/)(test|spec))\\.[jt]sx?$',
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest',
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};
```

### Writing Unit Tests

```typescript
// 1. Testing Utility Functions
// __tests__/unit/utils/validation.test.ts
import { validateEmail, validatePassword } from '@utils/validation';

describe('Validation Utilities', () => {
  describe('validateEmail', () => {
    it('should return true for valid emails', () => {
      expect(validateEmail('test@example.com')).toBe(true);
      expect(validateEmail('user.name@domain.co')).toBe(true);
      expect(validateEmail('user+filter@domain.com')).toBe(true);
    });

    it('should return false for invalid emails', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('test@example')).toBe(false);
      expect(validateEmail('test example.com')).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('should validate password strength', () => {
      expect(validatePassword('Password123!')).toBe(true);
      expect(validatePassword('Pass1!')).toBe(false);
      expect(validatePassword('Password123')).toBe(false);
    });
  });
});

// 2. Testing Custom Hooks
// __tests__/unit/hooks/useDebounce.test.ts
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

    // Update value
    rerender({ value: 'updated', delay: 500 });
    
    // Value shouldn't change immediately
    expect(result.current).toBe('initial');
    
    // After timer, value should update
    act(() => {
      jest.advanceTimersByTime(500);
    });
    
    expect(result.current).toBe('updated');
  });
});

// 3. Testing API Service
// __tests__/unit/api/authService.test.ts
import { authService } from '@api/services/authService';
import { supabase } from '@api/supabase';

jest.mock('@api/supabase');

describe('Auth Service', () => {
  const mockUser = { id: '1', email: 'test@example.com' };
  const mockSession = { access_token: 'token' };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('login', () => {
    it('should login successfully', async () => {
      (supabase.auth.signInWithPassword as jest.Mock).mockResolvedValue({
        data: { user: mockUser, session: mockSession },
        error: null,
      });

      const result = await authService.login({
        email: 'test@example.com',
        password: 'password123',
      });

      expect(result.user).toEqual(mockUser);
      expect(result.session).toEqual(mockSession);
    });

    it('should handle login error', async () => {
      (supabase.auth.signInWithPassword as jest.Mock).mockResolvedValue({
        data: null,
        error: { message: 'Invalid credentials' },
      });

      await expect(
        authService.login({
          email: 'test@example.com',
          password: 'wrong',
        })
      ).rejects.toThrow('Invalid credentials');
    });
  });
});
```

---

## T.3 Component Testing

### The Concept: Testing Your UI

Component tests verify that your UI components render correctly and respond to user interactions as expected.

### Complete Component Testing Guide

```typescript
// 1. Testing Basic Component
// __tests__/components/common/Button.test.tsx
import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { Button } from '@components/common/Button';

describe('Button Component', () => {
  it('renders correctly', () => {
    render(<Button title="Click Me" onPress={jest.fn()} />);
    expect(screen.getByText('Click Me')).toBeTruthy();
  });

  it('handles press events', () => {
    const onPress = jest.fn();
    render(<Button title="Click Me" onPress={onPress} />);
    
    const button = screen.getByText('Click Me');
    fireEvent.press(button);
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('disables button when disabled prop is true', () => {
    const onPress = jest.fn();
    render(<Button title="Click Me" onPress={onPress} disabled />);
    
    const button = screen.getByText('Click Me');
    fireEvent.press(button);
    expect(onPress).not.toHaveBeenCalled();
  });

  it('shows loading state', () => {
    render(<Button title="Click Me" onPress={jest.fn()} loading />);
    expect(screen.getByTestId('activity-indicator')).toBeTruthy();
  });
});

// 2. Testing Input Component
// __tests__/components/common/Input.test.tsx
import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { Input } from '@components/common/Input';

describe('Input Component', () => {
  it('renders with label', () => {
    render(<Input label="Email" value="" onChangeText={jest.fn()} />);
    expect(screen.getByText('Email')).toBeTruthy();
  });

  it('handles text input', () => {
    const onChangeText = jest.fn();
    render(<Input value="" onChangeText={onChangeText} />);
    
    const input = screen.getByTestId('text-input');
    fireEvent.changeText(input, 'test@example.com');
    expect(onChangeText).toHaveBeenCalledWith('test@example.com');
  });

  it('displays error message', () => {
    render(
      <Input
        value=""
        onChangeText={jest.fn()}
        error="Invalid email"
        touched
      />
    );
    expect(screen.getByText('Invalid email')).toBeTruthy();
  });
});

// 3. Testing Screen with Navigation
// __tests__/components/screens/LoginScreen.test.tsx
import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react-native';
import LoginScreen from '@screens/auth/LoginScreen';
import { useAuth } from '@hooks/useAuth';

jest.mock('@hooks/useAuth');

describe('LoginScreen', () => {
  const mockLogin = jest.fn();
  const mockNavigate = jest.fn();

  beforeEach(() => {
    (useAuth as jest.Mock).mockReturnValue({
      login: mockLogin,
      isLoading: false,
      error: null,
    });
    mockLogin.mockClear();
    mockNavigate.mockClear();
  });

  it('renders login form', () => {
    render(<LoginScreen navigation={{ navigate: mockNavigate }} />);
    
    expect(screen.getByPlaceholderText('Email')).toBeTruthy();
    expect(screen.getByPlaceholderText('Password')).toBeTruthy();
    expect(screen.getByText('Sign In')).toBeTruthy();
  });

  it('handles form submission', async () => {
    mockLogin.mockResolvedValue({ success: true });
    
    render(<LoginScreen navigation={{ navigate: mockNavigate }} />);
    
    const emailInput = screen.getByPlaceholderText('Email');
    const passwordInput = screen.getByPlaceholderText('Password');
    const submitButton = screen.getByText('Sign In');
    
    fireEvent.changeText(emailInput, 'test@example.com');
    fireEvent.changeText(passwordInput, 'password123');
    fireEvent.press(submitButton);
    
    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password123');
    });
  });

  it('shows validation errors', async () => {
    render(<LoginScreen navigation={{ navigate: mockNavigate }} />);
    
    const submitButton = screen.getByText('Sign In');
    fireEvent.press(submitButton);
    
    await waitFor(() => {
      expect(screen.getByText('Email is required')).toBeTruthy();
      expect(screen.getByText('Password is required')).toBeTruthy();
    });
  });
});
```

---

## T.4 Integration Testing

### The Concept: Testing Multiple Units Together

Integration tests verify that different parts of your application work together correctly.

### Complete Integration Testing Guide

```typescript
// 1. Testing Store with API
// __tests__/integration/authFlow.test.ts
import { useAuthStore } from '@store';
import { authService } from '@api/services/authService';

jest.mock('@api/services/authService');

describe('Authentication Flow', () => {
  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
    jest.clearAllMocks();
  });

  it('should handle full login flow', async () => {
    const mockUser = { id: '1', email: 'test@example.com' };
    (authService.login as jest.Mock).mockResolvedValue({
      user: mockUser,
      session: { access_token: 'token' },
    });

    const { login } = useAuthStore.getState();
    await login('test@example.com', 'password');

    const state = useAuthStore.getState();
    expect(state.user).toEqual(mockUser);
    expect(state.isAuthenticated).toBe(true);
    expect(state.isLoading).toBe(false);
    expect(state.error).toBe(null);
  });

  it('should handle login errors', async () => {
    (authService.login as jest.Mock).mockRejectedValue(
      new Error('Invalid credentials')
    );

    const { login } = useAuthStore.getState();
    await login('test@example.com', 'wrong');

    const state = useAuthStore.getState();
    expect(state.user).toBe(null);
    expect(state.isAuthenticated).toBe(false);
    expect(state.error).toBe('Invalid credentials');
  });

  it('should handle logout flow', async () => {
    // Set logged in state
    useAuthStore.setState({
      user: { id: '1', email: 'test@example.com' },
      isAuthenticated: true,
    });

    const { logout } = useAuthStore.getState();
    await logout();

    const state = useAuthStore.getState();
    expect(state.user).toBe(null);
    expect(state.isAuthenticated).toBe(false);
  });
});

// 2. Testing Database Operations
// __tests__/integration/database.test.ts
import { database } from '@database';
import { UserRepository } from '@database/repositories/UserRepository';
import { dbUtils } from '@database';

describe('Database Integration', () => {
  const userRepo = new UserRepository();

  beforeEach(async () => {
    await dbUtils.clearAll();
  });

  it('should create and retrieve user', async () => {
    const user = await userRepo.create({
      fullName: 'John Doe',
      email: 'john@example.com',
      isActive: true,
    });

    const retrieved = await userRepo.getById(user.id);
    expect(retrieved).toBeDefined();
    expect(retrieved?.fullName).toBe('John Doe');
    expect(retrieved?.email).toBe('john@example.com');
  });

  it('should update user', async () => {
    const user = await userRepo.create({
      fullName: 'John Doe',
      email: 'john@example.com',
    });

    await userRepo.update(user.id, {
      fullName: 'Jane Doe',
    });

    const updated = await userRepo.getById(user.id);
    expect(updated?.fullName).toBe('Jane Doe');
  });

  it('should delete user', async () => {
    const user = await userRepo.create({
      fullName: 'John Doe',
      email: 'john@example.com',
    });

    await userRepo.delete(user.id);

    const deleted = await userRepo.getById(user.id);
    expect(deleted).toBeNull();
  });
});
```

---

## T.5 End-to-End Testing with Detox

### The Concept: Testing Complete User Journeys

End-to-End (E2E) tests simulate real user interactions with your app. They test the complete app stack from the user's perspective.

### Complete E2E Testing Guide

```bash
# 1. Install Detox
npm install -D detox jest-jasmine2

# 2. Install iOS dependencies (Mac only)
brew tap wix/brew
brew install applesimutils

# 3. Configure Detox (package.json)
"detox": {
  "configurations": {
    "ios.sim.debug": {
      "binaryPath": "ios/build/Build/Products/Debug-iphonesimulator/NexusCollect.app",
      "build": "xcodebuild -workspace ios/NexusCollect.xcworkspace -scheme NexusCollect -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build",
      "type": "ios.simulator",
      "device": {
        "type": "iPhone 15 Pro"
      }
    },
    "android.emu.debug": {
      "binaryPath": "android/app/build/outputs/apk/debug/app-debug.apk",
      "build": "cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug && cd ..",
      "type": "android.emulator",
      "device": {
        "avdName": "Pixel_4_API_33"
      }
    }
  },
  "testRunner": "jest",
  "runnerConfig": "e2e/config.json"
}

// 4. Create E2E Tests
// e2e/auth.e2e.js
describe('Authentication Flow', () => {
  beforeAll(async () => {
    await device.launchApp({
      newInstance: true,
      permissions: {
        notifications: 'YES',
      },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show login screen', async () => {
    await expect(element(by.text('Welcome Back'))).toBeVisible();
    await expect(element(by.text('Sign In'))).toBeVisible();
  });

  it('should show validation errors', async () => {
    await element(by.text('Sign In')).tap();
    await expect(element(by.text('Email is required'))).toBeVisible();
    await expect(element(by.text('Password is required'))).toBeVisible();
  });

  it('should navigate to registration', async () => {
    await element(by.text('Sign Up')).tap();
    await expect(element(by.text('Create Account'))).toBeVisible();
  });

  it('should login successfully', async () => {
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.id('passwordInput')).typeText('TestPass123!');
    await element(by.text('Sign In')).tap();

    await waitFor(element(by.text('Dashboard')))
      .toBeVisible()
      .withTimeout(10000);
  });
});

// e2e/collection.e2e.js
describe('Data Collection Flow', () => {
  beforeAll(async () => {
    await device.launchApp();
    
    // Login first
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.id('passwordInput')).typeText('TestPass123!');
    await element(by.text('Sign In')).tap();
    
    await waitFor(element(by.text('Dashboard')))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('should create a collection entry', async () => {
    // Navigate to forms
    await element(by.text('Forms')).tap();
    await waitFor(element(by.text('Sample Form')))
      .toBeVisible()
      .withTimeout(5000);

    // Fill form
    await element(by.id('field1')).typeText('John Doe');
    await element(by.id('field2')).typeText('john@example.com');
    
    // Submit
    await element(by.text('Submit')).tap();
    
    await waitFor(element(by.text('Entry submitted successfully')))
      .toBeVisible()
      .withTimeout(5000);
  });

  it('should save and retrieve draft', async () => {
    await element(by.text('Forms')).tap();
    await element(by.text('Sample Form')).tap();
    
    await element(by.id('field1')).typeText('Draft Entry');
    await element(by.text('Save Draft')).tap();
    
    await waitFor(element(by.text('Draft saved successfully')))
      .toBeVisible()
      .withTimeout(5000);
    
    // Navigate to drafts
    await element(by.text('Collections')).tap();
    await element(by.text('Drafts')).tap();
    
    await expect(element(by.text('Draft Entry'))).toBeVisible();
  });
});
```

---

## T.6 Code Quality Tools

### The Concept: Maintaining Clean Code

Code quality tools help maintain consistent, clean, and error-free code across your team.

### Complete Code Quality Guide

```bash
# 1. Install ESLint and Prettier
npm install -D eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
npm install -D prettier eslint-config-prettier eslint-plugin-prettier
npm install -D husky lint-staged

# 2. ESLint Configuration
// .eslintrc.js
module.exports = {
  root: true,
  extends: [
    '@react-native-community',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
    'prettier',
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'react-hooks'],
  rules: {
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'prefer-const': 'error',
    'quotes': ['error', 'single'],
    'semi': ['error', 'always'],
  },
};

// 3. Prettier Configuration
// .prettierrc.js
module.exports = {
  singleQuote: true,
  trailingComma: 'all',
  tabWidth: 2,
  semi: true,
  printWidth: 100,
  bracketSpacing: true,
  bracketSameLine: true,
  arrowParens: 'avoid',
};

// 4. Husky and Lint-Staged
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm run type-check && npm test"
    }
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ]
  }
}

// 5. TypeScript Configuration
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

---

## T.7 CI/CD Pipeline

### The Concept: Automated Quality Gates

Continuous Integration (CI) automatically runs your tests and quality checks whenever code is pushed.

### Complete CI/CD Guide

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run format -- --check

  type-check:
    name: TypeScript Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run type-check

  test:
    name: Unit & Integration Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:ci
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          directory: ./coverage

  e2e:
    name: E2E Tests
    runs-on: macos-latest
    needs: [lint, type-check, test]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: brew tap wix/brew && brew install applesimutils
      - run: npm run test:e2e
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

# Run linting
npm run lint

# Run type checking
npm run type-check

# Run full CI pipeline locally
npm run test:ci
```

### Testing Patterns Summary

| Test Type | What to Test | Tool |
|-----------|--------------|------|
| Unit Test | Functions, hooks, utilities | Jest |
| Component Test | UI components, interactions | React Native Testing Library |
| Integration Test | Store + API, database | Jest |
| E2E Test | Complete user flows | Detox |

### Common Testing Patterns

```typescript
// 1. Mocking
jest.mock('@api/services/authService');

// 2. Spy on functions
const mockFn = jest.fn();
expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith('arg');

// 3. Async testing
await expect(asyncFunction()).resolves.toBe('value');
await expect(asyncFunction()).rejects.toThrow('error');

// 4. Snapshots
expect(component).toMatchSnapshot();

// 5. Coverage
// Run: npm run test:coverage
// View: coverage/lcov-report/index.html
```

---

**Ready to test your mobile apps with confidence? Let's build NexusCollect!**
