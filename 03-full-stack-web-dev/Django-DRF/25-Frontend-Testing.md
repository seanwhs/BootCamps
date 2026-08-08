# Part 25: Frontend Testing

## Testing Your React Components and User Interactions

Welcome to **Part 25** of the Django REST Framework & Next.js 16 masterclass. Now that we have a comprehensive backend test suite, it's time to test our frontend. We'll build a complete test suite covering React components, user interactions, form validation, and API integration.

In this part, we'll:
- Set up React Testing Library and Jest
- Write component tests
- Test user interactions
- Test forms and validation
- Mock API calls
- Implement end-to-end tests with Playwright

Think of frontend tests as your **user experience insurance**. Just as a pilot runs through a checklist before takeoff, your tests verify that every button works, every form validates, and every interaction behaves as expected.

---

## The Target

We'll build a comprehensive frontend test suite:

```
frontend/
├── tests/
│   ├── unit/
│   │   ├── components/
│   │   │   ├── Button.test.tsx
│   │   │   ├── Input.test.tsx
│   │   │   └── Card.test.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.test.ts
│   │   └── utils/
│   │       └── helpers.test.ts
│   ├── integration/
│   │   ├── forms/
│   │   │   ├── LoginForm.test.tsx
│   │   │   └── TaskForm.test.tsx
│   │   └── pages/
│   │       ├── TasksPage.test.tsx
│   │       └── ProjectPage.test.tsx
│   ├── e2e/
│   │   ├── auth.spec.ts
│   │   ├── tasks.spec.ts
│   │   └── projects.spec.ts
│   └── setup/
│       ├── jest.setup.ts
│       └── test-utils.tsx
├── jest.config.js
├── jest.setup.js
└── playwright.config.ts
```

---

## The Concept

### Testing Pyramid for Frontend

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend Testing Pyramid                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│                  ┌──────────┐                                │
│                  │  E2E     │  Critical paths               │
│                  │  Tests   │  Full user flows              │
│               ┌──┴──────────┴──┐                            │
│               │  Integration   │  Component interactions    │
│               │  Tests         │  Page-level behavior       │
│            ┌──┴────────────────┴──┐                         │
│            │     Unit Tests       │  Individual components  │
│            │                      │  Utility functions      │
│            └──────────────────────┘                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Testing Tools

| Tool | Purpose | Use Case |
|------|---------|----------|
| **Jest** | Test runner | Running all tests |
| **React Testing Library** | Component testing | Testing React components |
| **User Event** | User simulation | Simulating user interactions |
| **MSW** | API mocking | Mocking API responses |
| **Playwright** | E2E testing | Testing full user flows |

### Testing Principles

1. **Test Behavior, Not Implementation**: Test what users see and do
2. **Use Semantic Queries**: Query by role, text, label
3. **Test Accessibility**: Use `getByRole`, `getByLabelText`
4. **Mock External Dependencies**: Mock APIs, not components
5. **Keep Tests Focused**: One assertion per test

---

## The Implementation

### Step 1: Install Testing Dependencies

```bash
cd frontend
npm install -D @testing-library/react @testing-library/jest-dom @testing-library/user-event
npm install -D @testing-library/dom @testing-library/react-hooks
npm install -D jest jest-environment-jsdom @types/jest
npm install -D msw
npm install -D @playwright/test
npm install -D @types/react @types/react-dom
```

### Step 2: Configure Jest

**frontend/jest.config.js** (create)

```javascript
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  dir: './',
});

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
  testMatch: [
    '**/tests/unit/**/*.test.[jt]s?(x)',
    '**/tests/integration/**/*.test.[jt]s?(x)',
  ],
  collectCoverageFrom: [
    'app/**/*.{js,jsx,ts,tsx}',
    'components/**/*.{js,jsx,ts,tsx}',
    'hooks/**/*.{js,jsx,ts,tsx}',
    'lib/**/*.{js,jsx,ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/*.stories.{js,jsx,ts,tsx}',
  ],
  coverageThreshold: {
    global: {
      statements: 70,
      branches: 60,
      functions: 70,
      lines: 70,
    },
  },
};

module.exports = createJestConfig(customJestConfig);
```

**frontend/jest.setup.js** (create)

```javascript
import '@testing-library/jest-dom';

// Mock Next.js router
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    refresh: jest.fn(),
    back: jest.fn(),
    forward: jest.fn(),
  }),
  usePathname: () => '/',
  useSearchParams: () => new URLSearchParams(),
}));

// Mock Next.js Image
jest.mock('next/image', () => ({
  __esModule: true,
  default: (props) => {
    // eslint-disable-next-line jsx-a11y/alt-text
    return <img {...props} />;
  },
}));

// Mock environment variables
process.env.NEXT_PUBLIC_API_URL = 'http://localhost:8000/api/v1';
```

### Step 3: Create Test Utilities

**frontend/tests/setup/test-utils.tsx** (create)

```tsx
import { render } from '@testing-library/react';
import { ReactElement } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider } from '@/lib/auth/AuthContext';
import { ToastProvider } from '@/lib/context/ToastContext';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

export function renderWithProviders(ui: ReactElement) {
  return render(
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <ToastProvider>
          {ui}
        </ToastProvider>
      </AuthProvider>
    </QueryClientProvider>
  );
}

export * from '@testing-library/react';
export { renderWithProviders as render };
```

### Step 4: Create Unit Tests

**frontend/tests/unit/components/Button.test.tsx** (create)

```tsx
import { render, screen, fireEvent } from '@/tests/setup/test-utils';
import { Button } from '@/components/ui/Button';

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('handles click events', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByRole('button', { name: 'Click me' }));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('shows loading state', () => {
    render(<Button isLoading>Loading</Button>);
    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
    expect(button.querySelector('.animate-spin')).toBeInTheDocument();
  });

  it('applies variant classes', () => {
    render(<Button variant="destructive">Delete</Button>);
    const button = screen.getByRole('button', { name: 'Delete' });
    expect(button).toHaveClass('bg-danger-600');
  });

  it('applies size classes', () => {
    render(<Button size="lg">Large</Button>);
    const button = screen.getByRole('button', { name: 'Large' });
    expect(button).toHaveClass('h-11');
  });
});
```

**frontend/tests/unit/utils/helpers.test.ts** (create)

```tsx
import { formatDate, formatDateTime, truncateText, cn } from '@/lib/utils/helpers';

describe('Helpers', () => {
  describe('formatDate', () => {
    it('formats date correctly', () => {
      const date = '2026-01-15T12:00:00Z';
      expect(formatDate(date)).toBe('Jan 15, 2026');
    });
  });

  describe('formatDateTime', () => {
    it('formats date and time correctly', () => {
      const date = '2026-01-15T12:00:00Z';
      expect(formatDateTime(date)).toContain('Jan 15, 2026');
      expect(formatDateTime(date)).toContain('12:00');
    });
  });

  describe('truncateText', () => {
    it('truncates text correctly', () => {
      const text = 'This is a long text that should be truncated';
      expect(truncateText(text, 10)).toBe('This is a ...');
    });

    it('does not truncate short text', () => {
      const text = 'Short';
      expect(truncateText(text, 10)).toBe('Short');
    });
  });

  describe('cn', () => {
    it('merges class names correctly', () => {
      expect(cn('class1', 'class2')).toBe('class1 class2');
      expect(cn('class1', null, false, 'class2')).toBe('class1 class2');
    });
  });
});
```

### Step 5: Create Integration Tests

**frontend/tests/integration/forms/LoginForm.test.tsx** (create)

```tsx
import { render, screen, fireEvent, waitFor } from '@/tests/setup/test-utils';
import { LoginForm } from '@/components/auth/LoginForm';
import { useAuth } from '@/lib/auth/AuthContext';

// Mock the auth hook
jest.mock('@/lib/auth/AuthContext', () => ({
  useAuth: jest.fn(),
}));

describe('LoginForm', () => {
  const mockLogin = jest.fn();

  beforeEach(() => {
    (useAuth as jest.Mock).mockReturnValue({
      login: mockLogin,
    });
  });

  it('renders login form', () => {
    render(<LoginForm />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();
  });

  it('handles form submission', async () => {
    render(<LoginForm />);
    
    const emailInput = screen.getByLabelText(/email/i);
    const passwordInput = screen.getByLabelText(/password/i);
    const submitButton = screen.getByRole('button', { name: /sign in/i });

    fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
    fireEvent.change(passwordInput, { target: { value: 'password123' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password123');
    });
  });

  it('shows validation errors', async () => {
    mockLogin.mockRejectedValueOnce(new Error('Invalid credentials'));
    render(<LoginForm />);
    
    const submitButton = screen.getByRole('button', { name: /sign in/i });
    fireEvent.click(submitButton);

    // Should show error message
    await waitFor(() => {
      expect(screen.getByText(/invalid credentials/i)).toBeInTheDocument();
    });
  });
});
```

**frontend/tests/integration/pages/TasksPage.test.tsx** (create)

```tsx
import { render, screen, waitFor } from '@/tests/setup/test-utils';
import TasksPage from '@/app/(dashboard)/tasks/page';
import { useTasks } from '@/lib/api/hooks';

// Mock the tasks hook
jest.mock('@/lib/api/hooks', () => ({
  useTasks: jest.fn(),
}));

describe('TasksPage', () => {
  const mockTasks = {
    data: {
      results: [
        { id: 1, title: 'Task 1', status: 'todo', priority: 'high' },
        { id: 2, title: 'Task 2', status: 'in_progress', priority: 'medium' },
      ],
      count: 2,
      total_pages: 1,
    },
    isLoading: false,
    error: null,
  };

  it('renders tasks list', async () => {
    (useTasks as jest.Mock).mockReturnValue(mockTasks);
    
    render(<TasksPage />);
    
    await waitFor(() => {
      expect(screen.getByText('Task 1')).toBeInTheDocument();
      expect(screen.getByText('Task 2')).toBeInTheDocument();
    });
  });

  it('shows loading state', () => {
    (useTasks as jest.Mock).mockReturnValue({
      ...mockTasks,
      isLoading: true,
    });
    
    render(<TasksPage />);
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });

  it('shows error state', () => {
    (useTasks as jest.Mock).mockReturnValue({
      ...mockTasks,
      error: new Error('Failed to fetch'),
    });
    
    render(<TasksPage />);
    expect(screen.getByText(/failed to fetch/i)).toBeInTheDocument();
  });

  it('shows empty state', () => {
    (useTasks as jest.Mock).mockReturnValue({
      ...mockTasks,
      data: { ...mockTasks.data, results: [], count: 0 },
    });
    
    render(<TasksPage />);
    expect(screen.getByText(/no tasks found/i)).toBeInTheDocument();
  });
});
```

### Step 6: Create API Mocking with MSW

**frontend/tests/setup/msw.ts** (create)

```typescript
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

export const handlers = [
  // Auth endpoints
  http.post('http://localhost:8000/api/v1/token/', async ({ request }) => {
    const body = await request.json();
    if (body.email === 'test@example.com' && body.password === 'password123') {
      return HttpResponse.json({
        access: 'mock-access-token',
        refresh: 'mock-refresh-token',
        user: { id: 1, email: 'test@example.com', username: 'testuser' },
      });
    }
    return new HttpResponse(null, { status: 401 });
  }),

  // Tasks endpoints
  http.get('http://localhost:8000/api/v1/tasks/', () => {
    return HttpResponse.json({
      results: [
        { id: 1, title: 'Test Task 1', status: 'todo', priority: 'high' },
        { id: 2, title: 'Test Task 2', status: 'in_progress', priority: 'medium' },
      ],
      count: 2,
      total_pages: 1,
    });
  }),

  // Projects endpoints
  http.get('http://localhost:8000/api/v1/projects/', () => {
    return HttpResponse.json({
      results: [
        { id: 1, name: 'Test Project 1', description: 'Description 1' },
        { id: 2, name: 'Test Project 2', description: 'Description 2' },
      ],
      count: 2,
      total_pages: 1,
    });
  }),
];

export const server = setupServer(...handlers);
```

**frontend/tests/setup/msw-setup.js** (create)

```javascript
import { server } from './msw';

// Establish API mocking before all tests
beforeAll(() => server.listen());

// Reset any request handlers that we may add during the tests
afterEach(() => server.resetHandlers());

// Clean up after the tests are finished
afterAll(() => server.close());
```

### Step 7: Add MSW Setup to Jest

**frontend/jest.setup.js** (update)

```javascript
import '@testing-library/jest-dom';
import './tests/setup/msw-setup';

// ... rest of setup
```

### Step 8: Create E2E Tests with Playwright

**frontend/playwright.config.ts** (create)

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
  ],
  
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

**frontend/tests/e2e/auth.spec.ts** (create)

```typescript
import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {
  test('user can login', async ({ page }) => {
    await page.goto('/login');
    
    // Fill login form
    await page.fill('input[type="email"]', 'test@example.com');
    await page.fill('input[type="password"]', 'password123');
    await page.click('button[type="submit"]');
    
    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome back');
  });

  test('user can register', async ({ page }) => {
    await page.goto('/register');
    
    await page.fill('#email', 'newuser@example.com');
    await page.fill('#username', 'newuser');
    await page.fill('#first_name', 'New');
    await page.fill('#last_name', 'User');
    await page.fill('#password', 'Password123!');
    await page.fill('#confirm_password', 'Password123!');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL('/dashboard');
  });

  test('user can logout', async ({ page }) => {
    // First login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'test@example.com');
    await page.fill('input[type="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
    
    // Then logout
    await page.click('button[aria-label="Logout"]');
    await expect(page).toHaveURL('/login');
  });
});
```

**frontend/tests/e2e/tasks.spec.ts** (create)

```typescript
import { test, expect } from '@playwright/test';

test.describe('Task Management', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('input[type="email"]', 'test@example.com');
    await page.fill('input[type="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('user can create a task', async ({ page }) => {
    await page.goto('/tasks');
    await page.click('a:has-text("New Task")');
    
    await page.fill('#title', 'Test Task from E2E');
    await page.fill('#description', 'Test description');
    await page.selectOption('#project', { index: 1 });
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL(/\/tasks\/\d+/);
    await expect(page.locator('h1')).toContainText('Test Task from E2E');
  });

  test('user can edit a task', async ({ page }) => {
    // First create a task
    await page.goto('/tasks');
    await page.click('a:has-text("New Task")');
    await page.fill('#title', 'Task to Edit');
    await page.fill('#description', 'Description');
    await page.selectOption('#project', { index: 1 });
    await page.click('button[type="submit"]');
    
    // Then edit it
    await page.click('a:has-text("Edit")');
    await page.fill('#title', 'Updated Task Title');
    await page.click('button[type="submit"]');
    
    await expect(page.locator('h1')).toContainText('Updated Task Title');
  });

  test('user can update task status', async ({ page }) => {
    // Go to tasks page and click first task
    await page.goto('/tasks');
    await page.click('a:has-text("Task 1")');
    
    // Click status update button
    await page.click('button:has-text("In Progress")');
    
    // Should update status
    await expect(page.locator('.badge-status')).toContainText('In Progress');
  });
});
```

### Step 9: Add Test Scripts to package.json

**frontend/package.json** (update scripts)

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:headed": "playwright test --headed",
    "test:all": "npm run test && npm run test:e2e"
  }
}
```

---

## The Verification

### Step 1: Run Unit Tests

```bash
cd frontend
npm run test
```

### Step 2: Run Tests with Coverage

```bash
npm run test:coverage
```

### Step 3: Run E2E Tests

```bash
# Make sure the app is running first
npm run dev

# In a separate terminal
npm run test:e2e
```

### Step 4: Run E2E Tests with UI

```bash
npm run test:e2e:ui
```

---

## Key Takeaways

1. **React Testing Library** focuses on testing user behavior, not implementation.

2. **Unit tests** verify individual components and utilities.

3. **Integration tests** verify component interactions and flows.

4. **E2E tests** verify complete user workflows.

5. **MSW** provides powerful API mocking.

6. **Playwright** enables cross-browser E2E testing.

7. **Test coverage** helps identify untested code.

---

## What's Next

In **Part 26**, we'll implement API documentation:

- OpenAPI specification
- drf-spectacular
- Swagger UI
- ReDoc
- API reference

---

**End of Part 25**

*Next: Part 26 - API Documentation with OpenAPI*
