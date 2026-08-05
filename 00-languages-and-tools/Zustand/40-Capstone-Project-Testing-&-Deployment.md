# Capstone Project — Phase 6: Testing & Deployment

With all features built, it's time to ensure TaskFlow is reliable, maintainable, and ready for production. This phase covers comprehensive testing strategies—unit, integration, and end-to-end tests—and deployment pipelines for web and mobile. You'll also set up monitoring, logging, and error tracking to keep your application healthy in production.

---

## The Target: Production-Ready, Tested Application

By the end of this phase, you'll have:
- Unit tests covering all stores and utilities
- Integration tests for component-store interactions
- End-to-end tests for critical user journeys
- CI/CD pipeline (GitHub Actions) for automated testing and deployment
- Docker configuration for containerized deployment
- Environment configuration for development, staging, and production
- Monitoring with Sentry and performance tracking
- Deployment scripts for Vercel/Netlify (web) and Expo (mobile)

---

## Implementation: Testing

### Step 1: Unit Testing Setup (Vitest)

```typescript
// packages/shared/vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: ['node_modules/', 'dist/', '**/*.test.ts', '**/test/**'],
      thresholds: {
        statements: 80,
        branches: 75,
        functions: 80,
        lines: 80,
      },
    },
    testTimeout: 10000,
    hookTimeout: 10000,
  },
});
```

### Step 2: Unit Test for Auth Store

```typescript
// packages/shared/src/store/__tests__/auth.store.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { useAuthStore } from '../auth/authStore';
import { authApi } from '../../services/authApi';

// Mock the API
vi.mock('../../services/authApi', () => ({
  authApi: {
    login: vi.fn(),
    register: vi.fn(),
    logout: vi.fn(),
    refreshToken: vi.fn(),
    getCurrentUser: vi.fn(),
    updateUser: vi.fn(),
  },
}));

describe('Auth Store', () => {
  beforeEach(() => {
    useAuthStore.setState({
      user: null,
      tokens: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
    vi.clearAllMocks();
  });

  describe('login', () => {
    it('should login successfully', async () => {
      const mockUser = { id: 'user-1', name: 'Test', email: 'test@example.com', role: 'user' };
      const mockTokens = { accessToken: 'access', refreshToken: 'refresh', expiresIn: 3600 };
      (authApi.login as any).mockResolvedValue({ user: mockUser, tokens: mockTokens });

      const { login } = useAuthStore.getState();
      await login({ email: 'test@example.com', password: 'password123' });

      const state = useAuthStore.getState();
      expect(state.isAuthenticated).toBe(true);
      expect(state.user).toEqual(mockUser);
      expect(state.tokens).toEqual(mockTokens);
      expect(state.isLoading).toBe(false);
      expect(state.error).toBeNull();
    });

    it('should handle login failure', async () => {
      (authApi.login as any).mockRejectedValue(new Error('Invalid credentials'));

      const { login } = useAuthStore.getState();
      await expect(login({ email: 'test@example.com', password: 'wrong' })).rejects.toThrow('Invalid credentials');

      const state = useAuthStore.getState();
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBeNull();
      expect(state.isLoading).toBe(false);
      expect(state.error).toBe('Invalid credentials');
    });
  });

  describe('logout', () => {
    it('should logout successfully', async () => {
      // Set authenticated state
      useAuthStore.setState({
        user: { id: 'user-1', name: 'Test', email: 'test@example.com', role: 'user' },
        tokens: { accessToken: 'access', refreshToken: 'refresh', expiresIn: 3600 },
        isAuthenticated: true,
      });

      (authApi.logout as any).mockResolvedValue(undefined);

      const { logout } = useAuthStore.getState();
      await logout();

      const state = useAuthStore.getState();
      expect(state.isAuthenticated).toBe(false);
      expect(state.user).toBeNull();
      expect(state.tokens).toBeNull();
      expect(state.isLoading).toBe(false);
    });
  });
});
```

### Step 3: Integration Test for Task List Component

```tsx
// apps/web/src/components/tasks/__tests__/TaskList.integration.test.tsx
import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TaskList } from '../TaskList';
import { useTaskStore } from '@taskflow/shared';

describe('TaskList Integration', () => {
  beforeEach(() => {
    useTaskStore.setState({
      tasks: {},
      taskIds: [],
      loading: false,
      error: null,
      filters: { status: 'all', priority: 'all', assignee: 'all', tags: [], dueDate: 'all', searchQuery: '' },
      sort: { field: 'createdAt', direction: 'desc' },
      selectedTaskId: null,
      selectedIds: [],
    });
  });

  it('should display loading state', () => {
    useTaskStore.setState({ loading: true });
    render(<TaskList />);
    expect(screen.getByText('Loading tasks...')).toBeInTheDocument();
  });

  it('should display error state', () => {
    useTaskStore.setState({ error: 'Failed to load tasks' });
    render(<TaskList />);
    expect(screen.getByText(/Error loading tasks/)).toBeInTheDocument();
  });

  it('should display tasks when loaded', async () => {
    const mockTasks = [
      { id: 'task-1', title: 'Task 1', completed: false, priority: 'high' },
      { id: 'task-2', title: 'Task 2', completed: true, priority: 'low' },
    ];
    const tasksMap = {};
    const ids = [];
    for (const t of mockTasks) {
      tasksMap[t.id] = t;
      ids.push(t.id);
    }
    useTaskStore.setState({ tasks: tasksMap, taskIds: ids });

    render(<TaskList />);

    await waitFor(() => {
      expect(screen.getByText('Task 1')).toBeInTheDocument();
      expect(screen.getByText('Task 2')).toBeInTheDocument();
    });
  });

  it('should toggle task completion', async () => {
    const user = userEvent.setup();
    const mockTask = { id: 'task-1', title: 'Task 1', completed: false, priority: 'medium' };
    useTaskStore.setState({ tasks: { 'task-1': mockTask }, taskIds: ['task-1'] });

    render(<TaskList />);
    const toggleButton = screen.getByRole('button', { name: /Toggle/ }); // adjust based on actual aria-label
    await user.click(toggleButton);

    const state = useTaskStore.getState();
    expect(state.tasks['task-1'].completed).toBe(true);
  });
});
```

### Step 4: End-to-End Test with Playwright

```typescript
// apps/web/e2e/taskflow.spec.ts
import { test, expect } from '@playwright/test';

test.describe('TaskFlow E2E', () => {
  test('user can login and manage tasks', async ({ page }) => {
    // Navigate to login
    await page.goto('/login');
    await page.fill('input[name="email"]', 'user@taskflow.com');
    await page.fill('input[name="password"]', 'user123');
    await page.click('button[type="submit"]');

    // Expect redirect to dashboard
    await expect(page).toHaveURL('/dashboard');

    // Add a task
    await page.fill('input[placeholder="What needs to be done?"]', 'E2E Test Task');
    await page.click('button:has-text("Add Task")');

    // Verify task appears in list
    await expect(page.locator('text=E2E Test Task')).toBeVisible();

    // Toggle task completion
    await page.click('input[type="checkbox"]');

    // Verify task is marked completed
    await expect(page.locator('text=E2E Test Task')).toHaveClass(/line-through/);

    // Delete task
    await page.click('button[aria-label="Delete task"]');

    // Verify task removed
    await expect(page.locator('text=E2E Test Task')).not.toBeVisible();
  });

  test('user can filter tasks', async ({ page }) => {
    // Login and add tasks...
    // Then test filters
  });
});
```

### Step 5: CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [20.x]

    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'pnpm'
      - name: Install pnpm
        run: npm install -g pnpm
      - name: Install dependencies
        run: pnpm install
      - name: Lint
        run: pnpm lint
      - name: Build
        run: pnpm build
      - name: Test
        run: pnpm test -- --coverage
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          directory: packages/shared/coverage
          flags: unittests
          name: codecov-umbrella

  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install pnpm
        run: npm install -g pnpm
      - name: Install dependencies
        run: pnpm install
      - name: Build application
        run: pnpm build
      - name: Run Playwright tests
        run: pnpm test:e2e
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

### Step 6: Docker Configuration

```dockerfile
# Dockerfile (web)
FROM node:20-alpine AS builder

WORKDIR /app
RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

FROM node:20-alpine AS runner

WORKDIR /app
COPY --from=builder /app/apps/web/.next ./.next
COPY --from=builder /app/apps/web/public ./public
COPY --from=builder /app/apps/web/package.json ./package.json
COPY --from=builder /app/packages ./packages

RUN npm install -g pnpm
RUN pnpm install --prod

EXPOSE 3000
CMD ["pnpm", "start"]
```

### Step 7: Environment Configuration

```typescript
// apps/web/.env.example
NEXT_PUBLIC_API_URL=http://localhost:3001/api
NEXT_PUBLIC_WS_URL=ws://localhost:3001/ws
NEXT_PUBLIC_SENTRY_DSN=your-sentry-dsn
NEXT_PUBLIC_ANALYTICS_ID=your-analytics-id

# Production
NEXT_PUBLIC_API_URL=https://api.taskflow.com
NEXT_PUBLIC_WS_URL=wss://api.taskflow.com/ws
```

### Step 8: Deployment Scripts

```json
// package.json (root)
{
  "scripts": {
    "deploy:web": "pnpm --filter web build && pnpm --filter web deploy",
    "deploy:mobile": "pnpm --filter native build",
    "deploy:all": "pnpm deploy:web && pnpm deploy:mobile"
  }
}
```

### Step 9: Monitoring Setup (Sentry)

```typescript
// apps/web/src/services/sentry.ts
import * as Sentry from '@sentry/nextjs';

export function initSentry() {
  Sentry.init({
    dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
    environment: process.env.NODE_ENV,
    tracesSampleRate: 0.1,
    integrations: [
      new Sentry.BrowserTracing(),
    ],
  });
}
```

### Step 10: Performance Monitoring Dashboard

```tsx
// apps/web/src/components/PerformanceDashboard.tsx (reuse from earlier)
// Already implemented in Section 32. Include it here and wire to production.
```

---

## The Verification

### Step 1: Run Tests

```bash
# Unit tests
pnpm test

# Integration tests
pnpm test:integration

# E2E tests
pnpm test:e2e

# Coverage
pnpm test:coverage
```

### Step 2: Build for Production

```bash
pnpm build
```

### Step 3: Docker Build

```bash
docker build -t taskflow-web -f Dockerfile .
docker run -p 3000:3000 taskflow-web
```

### Step 4: Deploy to Vercel

```bash
# Install Vercel CLI
pnpm add -g vercel

# Deploy
vercel --prod
```

### Step 5: Deploy Mobile (Expo)

```bash
# Build for Android/iOS
eas build --platform android
eas build --platform ios

# Submit to stores
eas submit --platform android
eas submit --platform ios
```

---

## Key Takeaways

- **Unit tests** ensure individual pieces work in isolation
- **Integration tests** verify components and stores work together
- **E2E tests** simulate real user journeys
- **CI/CD** automates testing and deployment
- **Docker** provides consistent runtime environments
- **Environment configs** enable different settings per stage
- **Monitoring** (Sentry, performance dashboards) keeps the app healthy in production
- **Deployment scripts** simplify releases
- **Code coverage thresholds** maintain quality standards

---

## What's Next

You've built and tested a complete production-ready application! The capstone project is now fully realized. Congratulations on completing the entire Zustand tutorial series.
