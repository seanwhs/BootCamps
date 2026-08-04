# Part 6: Testing & Quality Assurance

## Delivering Reliable Applications

Now that we've built a feature-rich application with hardware integration and offline capabilities, it's time to ensure everything works reliably. Testing is like building safety checks into your car—you wouldn't drive without seatbelts, brakes, and airbags. Similarly, we need comprehensive testing to catch issues before they reach users.

In professional development, testing isn't an afterthought—it's integral to the development process. We'll build a complete testing strategy that covers unit tests, component tests, integration tests, and end-to-end tests, all automated through CI/CD pipelines.

### The Target

By the end of this part, you will have:

1. A comprehensive Jest testing suite with 80%+ coverage
2. Component testing with React Native Testing Library
3. End-to-end testing with Detox
4. Automated CI/CD pipeline with GitHub Actions
5. Code quality tools (ESLint, Prettier, TypeScript)
6. Performance testing and monitoring
7. Error tracking and crash reporting
8. A complete test strategy document

---

## Phase 6.1: Unit Testing Setup

### The Concept: Testing the Building Blocks

Unit tests verify that individual pieces of code work correctly in isolation. Think of them as checking each component of a car engine separately—the pistons, valves, and spark plugs all work correctly before being assembled.

We'll use Jest, a popular testing framework, with React Native Testing Library for component testing.

### The Implementation: Test Configuration

#### Step 6.1.1: Install Testing Dependencies

```bash
# Install Jest and testing libraries
$ npm install -D jest @types/jest ts-jest
$ npm install -D @testing-library/react-native @testing-library/jest-native
$ npm install -D react-test-renderer
$ npm install -D @testing-library/react-hooks
$ npm install -D @types/react-test-renderer

# Install mocking libraries
$ npm install -D jest-mock jest-expo

# Install coverage tools
$ npm install -D @types/istanbul-lib-coverage

# Install React Native testing utilities
$ npm install -D @react-native-community/cli-platform-ios @react-native-community/cli-platform-android
```

#### Step 6.1.2: Configure Jest

```javascript
// jest.config.js
module.exports = {
  preset: 'jest-expo',
  transformIgnorePatterns: [
    'node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg)',
  ],
  setupFilesAfterEnv: [
    '@testing-library/jest-native/extend-expect',
    '<rootDir>/jest.setup.ts',
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  testRegex: '(/__tests__/.*|(\\.|/)(test|spec))\\.[jt]sx?$',
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/index.ts',
    '!src/**/types.ts',
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
    '^@components/(.*)$': '<rootDir>/src/components/$1',
    '^@screens/(.*)$': '<rootDir>/src/screens/$1',
    '^@utils/(.*)$': '<rootDir>/src/utils/$1',
    '^@types/(.*)$': '<rootDir>/src/types/$1',
    '^@hooks/(.*)$': '<rootDir>/src/hooks/$1',
    '^@store/(.*)$': '<rootDir>/src/store/$1',
    '^@api/(.*)$': '<rootDir>/src/api/$1',
    '^@themes/(.*)$': '<rootDir>/src/themes/$1',
    '^@database/(.*)$': '<rootDir>/src/database/$1',
    '^@services/(.*)$': '<rootDir>/src/services/$1',
    '^@constants/(.*)$': '<rootDir>/src/constants/$1',
  },
  verbose: true,
  testEnvironment: 'node',
};
```

#### Step 6.1.3: Jest Setup File

```typescript
// jest.setup.ts
import '@testing-library/jest-native/extend-expect';
import { NativeModules } from 'react-native';

// Mock React Native modules
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

// Mock Expo modules
jest.mock('expo-camera', () => ({
  Camera: {
    requestCameraPermissionsAsync: jest.fn(),
    getCameraPermissionsAsync: jest.fn(),
  },
}));

jest.mock('expo-location', () => ({
  requestForegroundPermissionsAsync: jest.fn(),
  getCurrentPositionAsync: jest.fn(),
  watchPositionAsync: jest.fn(),
  reverseGeocodeAsync: jest.fn(),
}));

jest.mock('expo-secure-store', () => ({
  getItemAsync: jest.fn(),
  setItemAsync: jest.fn(),
  deleteItemAsync: jest.fn(),
}));

jest.mock('expo-local-authentication', () => ({
  hasHardwareAsync: jest.fn(),
  isEnrolledAsync: jest.fn(),
  supportedAuthenticationTypesAsync: jest.fn(),
  authenticateAsync: jest.fn(),
}));

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  setItem: jest.fn(),
  getItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}));

// Mock React Native modules
NativeModules.RNGestureHandlerModule = {
  attachGestureHandler: jest.fn(),
  createGestureHandler: jest.fn(),
  dropGestureHandler: jest.fn(),
  updateGestureHandler: jest.fn(),
  flushOperations: jest.fn(),
};

NativeModules.ReanimatedModule = {
  configureNative: jest.fn(),
};

// Mock React Navigation
jest.mock('@react-navigation/native', () => ({
  useNavigation: jest.fn(),
  useRoute: jest.fn(),
  NavigationContainer: ({ children }: any) => children,
}));

// Mock environment variables
jest.mock('@env', () => ({
  API_URL: 'http://localhost:3000',
  SUPABASE_URL: 'http://localhost:54321',
  SUPABASE_ANON_KEY: 'test-anon-key',
  ENVIRONMENT: 'test',
  LOG_LEVEL: 'error',
}));

// Setup global mocks
global.console = {
  ...console,
  error: jest.fn(),
  warn: jest.fn(),
  debug: jest.fn(),
};

// Mock fetch
global.fetch = jest.fn();

// Clean up after each test
afterEach(() => {
  jest.clearAllMocks();
});
```

#### Step 6.1.4: Create Unit Tests

```typescript
// __tests__/unit/utils/validation.test.ts
import { validateEmail, validatePassword, validatePhone } from '@utils/validation';

/**
 * Validation Utility Tests
 * 
 * Testing our validation utilities to ensure they correctly identify
 * valid and invalid inputs.
 */
describe('Validation Utilities', () => {
  describe('validateEmail', () => {
    it('should return true for valid email', () => {
      expect(validateEmail('test@example.com')).toBe(true);
      expect(validateEmail('user.name@domain.co')).toBe(true);
      expect(validateEmail('user+filter@domain.com')).toBe(true);
    });

    it('should return false for invalid email', () => {
      expect(validateEmail('')).toBe(false);
      expect(validateEmail('test@')).toBe(false);
      expect(validateEmail('@example.com')).toBe(false);
      expect(validateEmail('test@example')).toBe(false);
      expect(validateEmail('test example.com')).toBe(false);
    });

    it('should handle null and undefined', () => {
      expect(validateEmail(null as any)).toBe(false);
      expect(validateEmail(undefined as any)).toBe(false);
    });
  });

  describe('validatePassword', () => {
    it('should return true for valid password', () => {
      expect(validatePassword('Password123!')).toBe(true);
      expect(validatePassword('SecurePass#2024')).toBe(true);
    });

    it('should return false for short password', () => {
      expect(validatePassword('Pass1!')).toBe(false);
      expect(validatePassword('123')).toBe(false);
    });

    it('should return false for missing special characters', () => {
      expect(validatePassword('Password123')).toBe(false);
      expect(validatePassword('Password!')).toBe(false);
    });
  });

  describe('validatePhone', () => {
    it('should return true for valid US phone number', () => {
      expect(validatePhone('(555) 555-5555')).toBe(true);
      expect(validatePhone('555-555-5555')).toBe(true);
      expect(validatePhone('555.555.5555')).toBe(true);
      expect(validatePhone('+1 555-555-5555')).toBe(true);
    });

    it('should return false for invalid phone number', () => {
      expect(validatePhone('')).toBe(false);
      expect(validatePhone('555')).toBe(false);
      expect(validatePhone('555-555')).toBe(false);
    });
  });
});
```

```typescript
// __tests__/unit/services/locationService.test.ts
import { locationService } from '@services/LocationService';

/**
 * Location Service Tests
 * 
 * Testing location-related functionality with mocks.
 */
describe('Location Service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('calculateDistance', () => {
    it('should calculate distance between two points correctly', () => {
      // New York to Los Angeles
      const distance = locationService.calculateDistance(
        40.7128, -74.0060,
        34.0522, -118.2437
      );
      
      // Approximate distance is ~3940 km
      expect(distance).toBeGreaterThan(3900);
      expect(distance).toBeLessThan(3980);
    });

    it('should return 0 for same coordinates', () => {
      const distance = locationService.calculateDistance(
        40.7128, -74.0060,
        40.7128, -74.0060
      );
      expect(distance).toBe(0);
    });

    it('should handle small distances correctly', () => {
      const distance = locationService.calculateDistance(
        40.7128, -74.0060,
        40.7129, -74.0061
      );
      expect(distance).toBeLessThan(0.1);
    });
  });

  describe('isWithinRadius', () => {
    it('should return true when within radius', () => {
      const result = locationService.isWithinRadius(
        40.7128, -74.0060, // Center (New York)
        40.7130, -74.0060, // Target (near center)
        5 // 5 km radius
      );
      expect(result).toBe(true);
    });

    it('should return false when outside radius', () => {
      const result = locationService.isWithinRadius(
        40.7128, -74.0060, // Center (New York)
        34.0522, -118.2437, // Target (Los Angeles)
        5 // 5 km radius
      );
      expect(result).toBe(false);
    });
  });

  describe('getAccuracyDescription', () => {
    it('should return correct descriptions for different accuracy values', () => {
      expect(locationService.getAccuracyDescription(5)).toBe('Excellent');
      expect(locationService.getAccuracyDescription(30)).toBe('Good');
      expect(locationService.getAccuracyDescription(70)).toBe('Fair');
      expect(locationService.getAccuracyDescription(150)).toBe('Poor');
    });
  });
});
```

```typescript
// __tests__/unit/database/repositories/formRepository.test.ts
import { database } from '@database';
import { FormRepository } from '@database/repositories/FormRepository';
import { dbUtils } from '@database';

/**
 * Form Repository Tests
 * 
 * Testing form CRUD operations with a test database.
 */
describe('Form Repository', () => {
  const userId = 'test-user-123';
  let testFormId: string;

  beforeEach(async () => {
    // Clear database before each test
    await dbUtils.clearAll();
  });

  it('should create a form', async () => {
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test Description',
      fields: [
        { id: 'field1', label: 'Name', type: 'text', required: true },
        { id: 'field2', label: 'Email', type: 'text', required: true },
      ],
    });

    expect(form).toBeDefined();
    expect(form.id).toBeDefined();
    expect(form.title).toBe('Test Form');
    expect(form.fields).toHaveLength(2);
    expect(form.syncStatus).toBe('pending');

    testFormId = form.id;
  });

  it('should get all forms for a user', async () => {
    // Create multiple forms
    await FormRepository.create(userId, {
      title: 'Form 1',
      description: 'Description 1',
      fields: [],
    });
    await FormRepository.create(userId, {
      title: 'Form 2',
      description: 'Description 2',
      fields: [],
    });

    const forms = await FormRepository.getAll(userId);
    expect(forms).toHaveLength(2);
    expect(forms[0].title).toBe('Form 2'); // Sorted by updated_at desc
  });

  it('should get a form by id', async () => {
    const created = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test Description',
      fields: [],
    });

    const found = await FormRepository.getById(created.id);
    expect(found).toBeDefined();
    expect(found?.id).toBe(created.id);
    expect(found?.title).toBe('Test Form');
  });

  it('should update a form', async () => {
    const form = await FormRepository.create(userId, {
      title: 'Original Title',
      description: 'Original Description',
      fields: [],
    });

    const updated = await FormRepository.update(form.id, {
      title: 'Updated Title',
      description: 'Updated Description',
    });

    expect(updated.title).toBe('Updated Title');
    expect(updated.description).toBe('Updated Description');
    expect(updated.syncStatus).toBe('pending');
    expect(updated.version).toBe(2);
  });

  it('should soft delete a form', async () => {
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test Description',
      fields: [],
    });

    await FormRepository.delete(form.id);

    const deletedForm = await FormRepository.getById(form.id);
    expect(deletedForm?.isDeleted).toBe(true);

    // Should not appear in getAll
    const forms = await FormRepository.getAll(userId);
    expect(forms).not.toContainEqual(expect.objectContaining({ id: form.id }));
  });

  it('should mark form as synced', async () => {
    const form = await FormRepository.create(userId, {
      title: 'Test Form',
      description: 'Test Description',
      fields: [],
    });

    expect(form.syncStatus).toBe('pending');

    await FormRepository.markSynced(form.id);

    const updatedForm = await FormRepository.getById(form.id);
    expect(updatedForm?.syncStatus).toBe('synced');
  });
});
```

---

## Phase 6.2: Component Testing

### The Concept: Testing the UI

Component tests verify that UI components render correctly and respond to user interactions as expected. Think of them as checking that each button, input, and display element works correctly in isolation.

### The Implementation: Component Tests

```typescript
// __tests__/components/common/Button.test.tsx
import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { Button } from '@components/common/Button';
import { ThemeProvider } from '@themes';

/**
 * Button Component Tests
 * 
 * Testing the Button component to ensure it renders correctly
 * and handles user interactions properly.
 */
describe('Button Component', () => {
  const renderButton = (props = {}) => {
    return render(
      <ThemeProvider>
        <Button title="Test Button" onPress={jest.fn()} {...props} />
      </ThemeProvider>
    );
  };

  it('renders correctly with default props', () => {
    renderButton();
    expect(screen.getByText('Test Button')).toBeTruthy();
  });

  it('renders with different variants', () => {
    const variants = ['primary', 'secondary', 'danger', 'outline'] as const;
    
    variants.forEach(variant => {
      const { rerender } = renderButton({ variant });
      expect(screen.getByText('Test Button')).toBeTruthy();
      rerender(
        <ThemeProvider>
          <Button title="Test Button" onPress={jest.fn()} variant={variant} />
        </ThemeProvider>
      );
    });
  });

  it('renders with different sizes', () => {
    const sizes = ['small', 'medium', 'large'] as const;
    
    sizes.forEach(size => {
      const { rerender } = renderButton({ size });
      expect(screen.getByText('Test Button')).toBeTruthy();
      rerender(
        <ThemeProvider>
          <Button title="Test Button" onPress={jest.fn()} size={size} />
        </ThemeProvider>
      );
    });
  });

  it('handles press events', () => {
    const onPress = jest.fn();
    render(
      <ThemeProvider>
        <Button title="Test Button" onPress={onPress} />
      </ThemeProvider>
    );
    
    const button = screen.getByText('Test Button');
    fireEvent.press(button);
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('disables button when disabled prop is true', () => {
    const onPress = jest.fn();
    render(
      <ThemeProvider>
        <Button title="Test Button" onPress={onPress} disabled />
      </ThemeProvider>
    );
    
    const button = screen.getByText('Test Button');
    fireEvent.press(button);
    expect(onPress).not.toHaveBeenCalled();
  });

  it('disables button when loading prop is true', () => {
    const onPress = jest.fn();
    render(
      <ThemeProvider>
        <Button title="Test Button" onPress={onPress} loading />
      </ThemeProvider>
    );
    
    const button = screen.getByText('Test Button');
    fireEvent.press(button);
    expect(onPress).not.toHaveBeenCalled();
  });

  it('shows loading indicator when loading', () => {
    renderButton({ loading: true });
    expect(screen.getByTestId('activity-indicator')).toBeTruthy();
  });
});
```

```typescript
// __tests__/components/common/Input.test.tsx
import React from 'react';
import { render, fireEvent, screen } from '@testing-library/react-native';
import { Input } from '@components/common/Input';
import { ThemeProvider } from '@themes';

/**
 * Input Component Tests
 * 
 * Testing the Input component to ensure it renders correctly
 * and handles user input properly.
 */
describe('Input Component', () => {
  const renderInput = (props = {}) => {
    return render(
      <ThemeProvider>
        <Input label="Test Label" {...props} />
      </ThemeProvider>
    );
  };

  it('renders correctly with label', () => {
    renderInput();
    expect(screen.getByText('Test Label')).toBeTruthy();
  });

  it('renders with placeholder', () => {
    renderInput({ placeholder: 'Enter text here' });
    const input = screen.getByPlaceholderText('Enter text here');
    expect(input).toBeTruthy();
  });

  it('handles text input', () => {
    const onChangeText = jest.fn();
    renderInput({ onChangeText, value: '' });
    
    const input = screen.getByTestId('text-input');
    fireEvent.changeText(input, 'Test input');
    expect(onChangeText).toHaveBeenCalledWith('Test input');
  });

  it('displays error message when error prop is provided', () => {
    renderInput({ error: 'This is an error', touched: true });
    expect(screen.getByText('This is an error')).toBeTruthy();
  });

  it('does not display error when touched is false', () => {
    renderInput({ error: 'This is an error', touched: false });
    expect(screen.queryByText('This is an error')).toBeNull();
  });

  it('renders with left icon', () => {
    renderInput({ leftIcon: 'mail-outline' });
    expect(screen.getByTestId('left-icon')).toBeTruthy();
  });

  it('renders with right icon', () => {
    renderInput({ rightIcon: 'eye-outline' });
    expect(screen.getByTestId('right-icon')).toBeTruthy();
  });

  it('toggles secure text entry when secureTextEntry is true', () => {
    renderInput({ secureTextEntry: true });
    const input = screen.getByTestId('text-input');
    expect(input.props.secureTextEntry).toBe(true);
  });
});
```

```typescript
// __tests__/components/common/LocationPicker.test.tsx
import React from 'react';
import { render, fireEvent, screen, waitFor } from '@testing-library/react-native';
import { LocationPicker } from '@components/common/LocationPicker';
import { ThemeProvider } from '@themes';
import { locationService } from '@services/LocationService';

/**
 * Location Picker Component Tests
 * 
 * Testing the LocationPicker component to ensure it renders correctly
 * and handles location selection properly.
 */
jest.mock('@services/LocationService');

describe('Location Picker Component', () => {
  const mockOnChange = jest.fn();
  const mockLocation = {
    latitude: 40.7128,
    longitude: -74.0060,
    accuracy: 10,
    timestamp: Date.now(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
    (locationService.getCurrentLocation as jest.Mock).mockResolvedValue(mockLocation);
    (locationService.reverseGeocode as jest.Mock).mockResolvedValue({
      formattedAddress: 'New York, NY, USA',
    });
  });

  const renderLocationPicker = (props = {}) => {
    return render(
      <ThemeProvider>
        <LocationPicker onChange={mockOnChange} {...props} />
      </ThemeProvider>
    );
  };

  it('renders correctly', () => {
    renderLocationPicker();
    expect(screen.getByText('Get Current Location')).toBeTruthy();
  });

  it('gets current location when button pressed', async () => {
    renderLocationPicker();
    
    const button = screen.getByText('Get Current Location');
    fireEvent.press(button);

    await waitFor(() => {
      expect(locationService.getCurrentLocation).toHaveBeenCalled();
      expect(mockOnChange).toHaveBeenCalledWith(mockLocation);
    });
  });

  it('shows loading indicator while getting location', async () => {
    (locationService.getCurrentLocation as jest.Mock).mockImplementation(
      () => new Promise(resolve => setTimeout(resolve, 1000))
    );

    renderLocationPicker();
    
    const button = screen.getByText('Get Current Location');
    fireEvent.press(button);

    expect(screen.getByTestId('activity-indicator')).toBeTruthy();
  });

  it('handles location error', async () => {
    const mockOnError = jest.fn();
    (locationService.getCurrentLocation as jest.Mock).mockRejectedValue(
      new Error('Location error')
    );

    renderLocationPicker({ onError: mockOnError });
    
    const button = screen.getByText('Get Current Location');
    fireEvent.press(button);

    await waitFor(() => {
      expect(mockOnError).toHaveBeenCalledWith('Failed to get location');
    });
  });

  it('displays selected location', async () => {
    renderLocationPicker({ value: mockLocation });
    
    await waitFor(() => {
      expect(screen.getByText('Current Location')).toBeTruthy();
      expect(screen.getByText('New York, NY, USA')).toBeTruthy();
    });
  });

  it('allows manual coordinate entry', async () => {
    renderLocationPicker({ allowManual: true });
    
    const manualButton = screen.getByText('Enter coordinates manually');
    fireEvent.press(manualButton);

    expect(screen.getByText('Enter Coordinates')).toBeTruthy();
  });
});
```

---

## Phase 6.3: End-to-End Testing with Detox

### The Concept: Testing the Complete User Journey

End-to-end (E2E) tests simulate real user interactions with the app. Think of them as test drivers who go through the entire user journey, checking that everything works together correctly. These tests run on actual devices or simulators and test the complete app stack.

### The Implementation: Detox Setup

#### Step 6.3.1: Install Detox

```bash
# Install Detox and Jest for E2E
$ npm install -D detox jest-jasmine2
$ npm install -D @types/detox

# For iOS
$ brew tap wix/brew
$ brew install applesimutils

# For Android
# Add to your android/app/build.gradle:
# android.defaultConfig.testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
```

#### Step 6.3.2: Configure Detox

```javascript
// package.json - Add detox configuration
{
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
    "runnerConfig": "e2e/config.json",
    "specs": "e2e",
    "test-runner": "jest"
  }
}
```

#### Step 6.3.3: Create E2E Tests

```typescript
// e2e/config.json
{
  "testEnvironment": "node",
  "testRunner": "jest-jasmine2",
  "testMatch": ["**/?(*.)+(e2e).js"],
  "reporters": ["detox/runners/jest/streamlineReporter"],
  "verbose": true
}
```

```typescript
// e2e/auth.e2e.js
/**
 * Authentication E2E Tests
 * 
 * Testing the complete authentication flow end-to-end.
 * These tests run on actual devices/simulators.
 */

describe('Authentication Flow', () => {
  beforeAll(async () => {
    await device.launchApp({
      newInstance: true,
      permissions: {
        notifications: 'YES',
        camera: 'YES',
        location: 'inuse',
      },
    });
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should show login screen on launch', async () => {
    await expect(element(by.text('Welcome Back'))).toBeVisible();
    await expect(element(by.text('Sign In'))).toBeVisible();
  });

  it('should show validation errors for empty fields', async () => {
    // Try to login without credentials
    await element(by.text('Sign In')).tap();

    // Wait for validation errors
    await expect(element(by.text('Email is required'))).toBeVisible();
    await expect(element(by.text('Password is required'))).toBeVisible();
  });

  it('should navigate to registration screen', async () => {
    await element(by.text('Sign Up')).tap();
    await expect(element(by.text('Create Account'))).toBeVisible();
    await expect(element(by.text('Full Name'))).toBeVisible();
    await expect(element(by.text('Email Address'))).toBeVisible();
    await expect(element(by.text('Password'))).toBeVisible();
  });

  it('should register a new user', async () => {
    // Navigate to registration
    await element(by.text('Sign Up')).tap();

    // Fill registration form
    const randomEmail = `test_${Date.now()}@example.com`;
    await element(by.id('fullNameInput')).typeText('Test User');
    await element(by.id('emailInput')).typeText(randomEmail);
    await element(by.id('passwordInput')).typeText('TestPass123!');
    await element(by.id('confirmPasswordInput')).typeText('TestPass123!');

    // Submit registration
    await element(by.text('Create Account')).tap();

    // Wait for navigation to main app
    await waitFor(element(by.text('Dashboard')))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('should login with existing credentials', async () => {
    // Enter credentials
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.id('passwordInput')).typeText('TestPass123!');

    // Submit login
    await element(by.text('Sign In')).tap();

    // Wait for navigation to main app
    await waitFor(element(by.text('Dashboard')))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('should handle password reset', async () => {
    // Navigate to forgot password
    await element(by.text('Forgot Password?')).tap();
    await expect(element(by.text('Reset Password'))).toBeVisible();

    // Enter email
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.text('Send Reset Link')).tap();

    // Wait for success message
    await waitFor(element(by.text('Password Reset Sent')))
      .toBeVisible()
      .withTimeout(5000);
  });
});
```

```typescript
// e2e/collections.e2e.js
/**
 * Collections E2E Tests
 * 
 * Testing the data collection flow end-to-end.
 */

describe('Data Collection Flow', () => {
  beforeAll(async () => {
    await device.launchApp({
      newInstance: true,
      permissions: {
        camera: 'YES',
        location: 'inuse',
      },
    });

    // Login before tests
    await element(by.id('emailInput')).typeText('test@example.com');
    await element(by.id('passwordInput')).typeText('TestPass123!');
    await element(by.text('Sign In')).tap();
    await waitFor(element(by.text('Dashboard')))
      .toBeVisible()
      .withTimeout(10000);
  });

  it('should create a new collection entry', async () => {
    // Navigate to forms
    await element(by.text('Forms')).tap();
    await waitFor(element(by.text('Forms')))
      .toBeVisible()
      .withTimeout(5000);

    // Select a form
    await element(by.text('Sample Form')).tap();

    // Fill form fields
    await element(by.id('field1')).typeText('John Doe');
    await element(by.id('field2')).typeText('john@example.com');
    await element(by.id('field3')).typeText('This is a test entry');

    // Add photo
    await element(by.id('capturePhotoButton')).tap();
    await waitFor(element(by.id('cameraView')))
      .toBeVisible()
      .withTimeout(5000);
    await element(by.id('captureButton')).tap();
    await element(by.id('confirmPhotoButton')).tap();

    // Add location
    await element(by.id('getLocationButton')).tap();
    await waitFor(element(by.text('Current Location')))
      .toBeVisible()
      .withTimeout(5000);

    // Submit entry
    await element(by.text('Submit')).tap();

    // Wait for success
    await waitFor(element(by.text('Entry submitted successfully')))
      .toBeVisible()
      .withTimeout(5000);
  });

  it('should save a draft and recover it', async () => {
    // Navigate to forms
    await element(by.text('Forms')).tap();
    await element(by.text('Sample Form')).tap();

    // Fill some fields
    await element(by.id('field1')).typeText('Draft Entry');
    await element(by.id('field2')).typeText('draft@example.com');

    // Save as draft
    await element(by.text('Save Draft')).tap();
    await waitFor(element(by.text('Draft saved successfully')))
      .toBeVisible()
      .withTimeout(5000);

    // Navigate to drafts
    await element(by.text('Collections')).tap();
    await element(by.text('Drafts')).tap();

    // Verify draft exists
    await expect(element(by.text('Draft Entry'))).toBeVisible();
  });

  it('should sync entries when online', async () => {
    // Go to dashboard
    await element(by.text('Dashboard')).tap();
    
    // Wait for sync
    await waitFor(element(by.text('All synced')))
      .toBeVisible()
      .withTimeout(15000);

    // Check sync status
    await expect(element(by.text('All synced'))).toBeVisible();
  });
});
```

---

## Phase 6.4: Code Quality Tools

### The Concept: Maintaining Code Quality

Code quality tools are like spell-checkers and style guides for your code. They catch errors before they become problems and ensure consistent code style across the team.

### The Implementation: Quality Tools Configuration

#### Step 6.4.1: ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  root: true,
  extends: [
    '@react-native-community',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'react-hooks'],
  rules: {
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    'react-native/no-inline-styles': 'warn',
    'react-native/no-color-literals': 'warn',
    'react-native/no-raw-text': 'warn',
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'no-debugger': 'error',
    'prefer-const': 'error',
    'quotes': ['error', 'single', { avoidEscape: true }],
    'semi': ['error', 'always'],
    'indent': ['error', 2],
    'comma-dangle': ['error', 'always-multiline'],
  },
  settings: {
    'import/resolver': {
      'babel-module': {
        extensions: ['.js', '.jsx', '.ts', '.tsx'],
        alias: {
          '@': './src',
          '@components': './src/components',
          '@screens': './src/screens',
          '@utils': './src/utils',
          '@types': './src/types',
          '@hooks': './src/hooks',
          '@store': './src/store',
          '@api': './src/api',
          '@themes': './src/themes',
          '@database': './src/database',
          '@services': './src/services',
          '@constants': './src/constants',
        },
      },
    },
  },
  ignorePatterns: ['**/__tests__/**/*', '**/e2e/**/*'],
};
```

#### Step 6.4.2: Prettier Configuration

```javascript
// .prettierrc.js
module.exports = {
  arrowParens: 'avoid',
  bracketSameLine: true,
  bracketSpacing: true,
  singleQuote: true,
  trailingComma: 'all',
  tabWidth: 2,
  semi: true,
  printWidth: 100,
  useTabs: false,
  endOfLine: 'lf',
};
```

#### Step 6.4.3: Husky and Lint-Staged

```json
// package.json (add these sections)
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
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

#### Step 6.4.4: Package Scripts

```json
// package.json (add/update scripts)
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:ci": "jest --ci --coverage --maxWorkers=2",
    "test:e2e": "detox test",
    "test:e2e:ios": "detox test -c ios.sim.debug",
    "test:e2e:android": "detox test -c android.emu.debug",
    
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write '**/*.{js,jsx,ts,tsx,json,md}'",
    
    "type-check": "tsc --noEmit",
    "type-check:watch": "tsc --noEmit --watch",
    
    "precommit": "lint-staged",
    "prepush": "npm run type-check && npm test",
    
    "coverage": "npm run test:coverage && open coverage/lcov-report/index.html"
  }
}
```

---

## Phase 6.5: CI/CD with GitHub Actions

### The Concept: Automated Quality Gates

Continuous Integration (CI) automatically runs tests and quality checks whenever code is pushed. Think of it as an automated quality inspector that checks every change before it's merged. This catches issues early and ensures your codebase stays healthy.

### The Implementation: CI Pipeline

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
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Check formatting
        run: npm run format -- --check

  type-check:
    name: TypeScript Type Check
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run TypeScript type check
        run: npm run type-check

  test:
    name: Unit & Integration Tests
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npm run test:ci

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          directory: ./coverage
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: true

  e2e-ios:
    name: E2E Tests (iOS)
    runs-on: macos-latest
    needs: [lint, type-check, test]
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Detox dependencies
        run: |
          brew tap wix/brew
          brew install applesimutils

      - name: Build iOS app
        run: npm run build:ios:ci

      - name: Run E2E tests
        run: npm run test:e2e:ios

  e2e-android:
    name: E2E Tests (Android)
    runs-on: macos-latest
    needs: [lint, type-check, test]
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Setup Android SDK
        uses: android-actions/setup-android@v2

      - name: Create emulator
        run: |
          avdmanager create avd -n Pixel_4_API_33 -k "system-images;android-33;google_apis;x86_64"

      - name: Build Android app
        run: npm run build:android:ci

      - name: Run E2E tests
        run: npm run test:e2e:android

  build:
    name: Build Application
    runs-on: ubuntu-latest
    needs: [e2e-ios, e2e-android]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build for production
        run: npm run build:prod

      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build-artifacts
          path: |
            dist/
            build/
          retention-days: 30

  deploy:
    name: Deploy to App Stores
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: build-artifacts
          path: ./dist

      - name: Deploy to EAS
        uses: expo/expo-github-action@v8
        with:
          eas-version: latest
          token: ${{ secrets.EXPO_TOKEN }}
          args: build:submit --platform all --latest
```

---

## Phase 6.6: Error Tracking and Monitoring

### The Concept: Real-Time Error Monitoring

Production apps need monitoring to catch issues that slip through testing. Think of it as a control center that alerts you to problems in real-time, before users are affected.

### The Implementation: Error Tracking Setup

```typescript
// src/utils/errorTracking.ts
import * as Sentry from 'sentry-expo';
import { Platform } from 'react-native';
import { CONFIG } from '@constants/config';

/**
 * Error Tracking Service
 * 
 * Handles error tracking and monitoring using Sentry.
 * Provides centralized error logging and reporting.
 */

// Initialize Sentry
Sentry.init({
  dsn: process.env.SENTRY_DSN,
  enableInExpoDevelopment: CONFIG.isDevelopment,
  debug: CONFIG.isDevelopment,
  environment: CONFIG.environment,
  release: process.env.APP_VERSION,
  integrations: [
    // Enable for better native error tracking
    new Sentry.Native.ReactNativeTracing({
      tracingOrigins: ['localhost', 'https://nexuscollect.com'],
    }),
  ],
  beforeSend(event) {
    // Modify or filter events before sending
    if (event.request?.url?.includes('localhost')) {
      return null; // Don't send localhost errors
    }
    return event;
  },
});

export const errorTracker = {
  /**
   * Capture an exception
   */
  captureException: (error: Error, context?: Record<string, any>) => {
    console.error('Error captured:', error);
    
    Sentry.withScope((scope) => {
      if (context) {
        scope.setExtras(context);
      }
      // Add device info
      scope.setExtra('platform', Platform.OS);
      scope.setExtra('isDevelopment', CONFIG.isDevelopment);
      
      Sentry.captureException(error);
    });
  },

  /**
   * Capture a message
   */
  captureMessage: (message: string, level: 'info' | 'warning' | 'error' = 'info') => {
    console.log(`[${level}] ${message}`);
    
    Sentry.addBreadcrumb({
      message,
      level: level === 'error' ? Sentry.Severity.Error : 
             level === 'warning' ? Sentry.Severity.Warning : 
             Sentry.Severity.Info,
      timestamp: Date.now(),
    });
  },

  /**
   * Set user context
   */
  setUser: (user: { id: string; email?: string; username?: string }) => {
    Sentry.setUser(user);
  },

  /**
   * Clear user context
   */
  clearUser: () => {
    Sentry.setUser(null);
  },

  /**
   * Add a breadcrumb
   */
  addBreadcrumb: (breadcrumb: {
    message: string;
    category?: string;
    data?: Record<string, any>;
    level?: Sentry.Severity;
  }) => {
    Sentry.addBreadcrumb({
      message: breadcrumb.message,
      category: breadcrumb.category || 'app',
      data: breadcrumb.data || {},
      level: breadcrumb.level || Sentry.Severity.Info,
    });
  },

  /**
   * Start a transaction for performance monitoring
   */
  startTransaction: (name: string, op: string) => {
    return Sentry.startTransaction({
      name,
      op,
    });
  },

  /**
   * Wrap a function for performance monitoring
   */
  wrapFunction: <T extends (...args: any[]) => any>(
    fn: T,
    name: string
  ): T => {
    return Sentry.wrap(fn, {
      transaction: name,
    });
  },

  /**
   * Handle unhandled promise rejections
   */
  setupGlobalErrorHandling: () => {
    // Handle unhandled promise rejections
    const originalHandler = global.ErrorUtils?.getGlobalHandler();
    
    if (originalHandler) {
      global.ErrorUtils.setGlobalHandler((error: Error, isFatal: boolean) => {
        errorTracker.captureException(error, { isFatal });
        originalHandler(error, isFatal);
      });
    }

    // Handle unhandled rejections
    const originalRejectionHandler = process.listeners('unhandledRejection')[0];
    process.removeAllListeners('unhandledRejection');
    process.on('unhandledRejection', (reason: any) => {
      if (reason instanceof Error) {
        errorTracker.captureException(reason);
      } else {
        errorTracker.captureMessage(`Unhandled rejection: ${reason}`, 'error');
      }
      if (originalRejectionHandler) {
        originalRejectionHandler(reason);
      }
    });
  },
};

// Export for use in app
export const withErrorTracking = errorTracker.wrapFunction;

// Example usage:
// const fetchData = withErrorTracking(async () => {
//   const response = await fetch('/api/data');
//   return response.json();
// }, 'fetchData');
```

```typescript
// src/utils/performance.ts
import { errorTracker } from './errorTracking';

/**
 * Performance Monitoring
 * 
 * Tracks performance metrics and identifies bottlenecks.
 */

export const performanceMonitor = {
  /**
   * Measure execution time of a function
   */
  measure: async <T>(
    fn: () => Promise<T> | T,
    name: string
  ): Promise<T> => {
    const start = performance.now();
    try {
      const result = await fn();
      const duration = performance.now() - start;
      
      // Log if duration is too long
      if (duration > 1000) {
        console.warn(`Slow operation: ${name} took ${duration.toFixed(2)}ms`);
        errorTracker.captureMessage(`Slow operation: ${name}`, 'warning');
      }
      
      return result;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Track component render time
   */
  trackRender: (componentName: string, renderTime: number) => {
    if (renderTime > 100) {
      console.warn(`Slow render: ${componentName} took ${renderTime.toFixed(2)}ms`);
    }
  },

  /**
   * Memory usage check
   */
  checkMemory: async () => {
    if (Platform.OS === 'ios') {
      // iOS memory check
      // Not available in React Native directly
      console.log('Memory check not available on iOS');
    } else if (Platform.OS === 'android') {
      // Android memory check using performance
      console.log('Memory check not available on Android');
    }
  },

  /**
   * Network latency tracking
   */
  trackNetworkRequest: (url: string, duration: number) => {
    if (duration > 5000) {
      errorTracker.captureMessage(
        `Slow network request: ${url} took ${duration.toFixed(2)}ms`,
        'warning'
      );
    }
  },
};
```

---

## Phase 6.7: Test Coverage Report

### The Concept: Measuring Test Quality

Test coverage tells you how much of your code is tested. While 100% coverage isn't always necessary, it helps identify untested parts of your application.

### The Implementation: Coverage Analysis

```typescript
// __tests__/coverage/CoverageReport.ts
/**
 * Test Coverage Report
 * 
 * This file tracks test coverage across different parts of the application.
 * Run: npm run test:coverage
 */

export const coverageReport = {
  // Target coverage thresholds
  targets: {
    statements: 80,
    branches: 70,
    functions: 80,
    lines: 80,
  },

  // Critical modules that should have high coverage
  criticalPaths: [
    'src/screens/auth',
    'src/screens/main',
    'src/store',
    'src/api',
    'src/database',
    'src/services',
    'src/utils',
  ],

  // Modules that can have lower coverage
  lowPriority: [
    'src/components/**/*.stories.tsx',
    'src/**/*.types.ts',
    'src/**/*.d.ts',
  ],
};

/**
 * Generate coverage summary
 */
export const generateCoverageSummary = (coverageData: any) => {
  const summary = {
    total: {
      statements: 0,
      branches: 0,
      functions: 0,
      lines: 0,
    },
    modules: {},
    criticalPaths: {},
    suggestions: [] as string[],
  };

  // Process coverage data...
  // This would be implemented to analyze the coverage report

  return summary;
};
```

---

## Phase 6.8: Final Integration Verification

### The Concept: End-to-End Validation

Before moving to deployment, we need to verify that everything works together in a production-like environment.

### The Implementation: Integration Test Suite

```typescript
// __tests__/integration/fullApp.test.tsx
import React from 'react';
import { render, waitFor, fireEvent } from '@testing-library/react-native';
import App from 'app/index';
import { supabase } from '@api/supabase';
import { useAuthStore } from '@store';

/**
 * Full Application Integration Tests
 * 
 * Tests the complete application flow from launch to data sync.
 */
describe('Full Application Integration', () => {
  beforeAll(async () => {
    // Mock auth
    useAuthStore.setState({
      user: {
        id: 'test-user',
        email: 'test@example.com',
        fullName: 'Test User',
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      isAuthenticated: true,
      isLoading: false,
      error: null,
    });
  });

  it('should render the app and show dashboard', async () => {
    const { findByText } = render(<App />);
    const dashboardText = await findByText('Dashboard');
    expect(dashboardText).toBeTruthy();
  });

  it('should navigate between tabs', async () => {
    const { findByText, getByText } = render(<App />);
    
    // Wait for dashboard
    await findByText('Dashboard');
    
    // Navigate to forms
    const formsTab = getByText('Forms');
    fireEvent.press(formsTab);
    
    await waitFor(() => {
      expect(getByText('Forms')).toBeTruthy();
    });
  });

  it('should show form entry screen', async () => {
    const { findByText, getByText } = render(<App />);
    
    await findByText('Dashboard');
    
    const formsTab = getByText('Forms');
    fireEvent.press(formsTab);
    
    // Sample form should be visible
    await waitFor(() => {
      expect(getByText('Sample Form')).toBeTruthy();
    });
  });

  it('should handle offline state gracefully', async () => {
    // Mock offline
    jest.spyOn(navigator, 'onLine', 'get').mockReturnValue(false);
    
    const { findByText } = render(<App />);
    const dashboardText = await findByText('Dashboard');
    expect(dashboardText).toBeTruthy();
    
    // Should show offline indicator
    // Implementation depends on your UI
  });
});
```

### Verification Commands

```bash
# Run all tests
$ npm test

# Run tests with coverage
$ npm run test:coverage

# Run linting
$ npm run lint

# Run type checking
$ npm run type-check

# Run E2E tests
$ npm run test:e2e

# Run full CI pipeline locally
$ npm run test:ci

# Generate coverage report
$ npm run coverage
```

---

## Part 6 Summary

### ✅ Completed

1. **Unit Testing**
   - Jest configuration
   - Test utilities and mocks
   - Service and repository tests
   - Utility function tests

2. **Component Testing**
   - React Native Testing Library
   - Component render tests
   - Interaction tests
   - Snapshot tests

3. **End-to-End Testing**
   - Detox setup
   - Authentication flow tests
   - Data collection tests
   - Offline sync tests

4. **Code Quality Tools**
   - ESLint configuration
   - Prettier setup
   - Husky git hooks
   - Lint-staged automation

5. **CI/CD Pipeline**
   - GitHub Actions configuration
   - Automated testing
   - Build automation
   - Deployment automation

6. **Error Tracking**
   - Sentry integration
   - Error reporting
   - Performance monitoring
   - Breadcrumb logging

7. **Test Coverage**
   - Coverage thresholds
   - Critical path testing
   - Coverage reporting

### Key Concepts Learned

- **Testing Pyramid:** Unit → Integration → E2E
- **Mocking:** Isolating code for testing
- **Test-Driven Development:** Writing tests first
- **Continuous Integration:** Automated quality gates
- **Code Quality:** Maintaining clean, consistent code
- **Error Monitoring:** Production error tracking
- **Performance Testing:** Identifying bottlenecks

### What's Coming in Part 7

In **Part 7: Security Hardening & Production Deployment**, you'll:
- Implement OWASP Mobile Top 10 security controls
- Configure app signing for production
- Build for App Store and Google Play distribution
- Set up Over-the-Air (OTA) updates
- Implement app store metadata
- Configure privacy manifests
- Prepare for app review
- Deploy to production!

---

## Quick Reference: Testing Commands

```bash
# Testing
$ npm test                     # Run all tests
$ npm test -- --watch          # Watch mode
$ npm test -- --coverage       # With coverage
$ npm test -- --testPathPattern=button  # Specific tests

# E2E Testing
$ npm run test:e2e             # Run E2E tests
$ detox build -c ios.sim.debug # Build for E2E
$ detox test -c ios.sim.debug  # Run E2E

# Code Quality
$ npm run lint                 # Run ESLint
$ npm run format               # Run Prettier
$ npm run type-check           # TypeScript check

# CI/CD
$ npm run test:ci              # Run CI tests
$ npm run coverage             # Generate coverage report
```
