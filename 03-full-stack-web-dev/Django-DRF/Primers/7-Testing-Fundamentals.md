# Primer 7: Testing Fundamentals

## Essential Testing Knowledge for the Masterclass

Welcome to **Primer 7** of the Django REST Framework & Next.js 16 masterclass. This primer is designed for developers who need a quick refresh or introduction to testing fundamentals before diving into the main series.

---

## Section 1: Testing Basics

### 1.1 Why Test?

**Benefits of Testing:**
- Catch bugs early
- Prevent regressions
- Document expected behavior
- Improve code quality
- Enable refactoring with confidence
- Facilitate collaboration
- Provide living documentation

**Testing Principles:**
- Test behavior, not implementation
- Write tests before code (TDD)
- Test edge cases
- Keep tests simple and readable
- Test one thing per test
- Use descriptive test names

### 1.2 Testing Pyramid

```
┌─────────────────────────────────────────────────────────────┐
│                     Testing Pyramid                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│                  ┌──────────┐                                │
│                  │  E2E     │  Few                          │
│                  │  Tests   │  Slow, comprehensive          │
│               ┌──┴──────────┴──┐                            │
│               │  Integration   │  Some                       │
│               │  Tests         │  Medium speed               │
│            ┌──┴────────────────┴──┐                         │
│            │     Unit Tests       │  Many                    │
│            │                      │  Fast, focused          │
│            └──────────────────────┘                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Test Types

| Type | Purpose | Tools |
|------|---------|-------|
| **Unit Tests** | Test individual components in isolation | pytest, Jest |
| **Integration Tests** | Test component interactions | pytest, DRF APIClient |
| **API Tests** | Test endpoints | DRF APIClient, Postman |
| **E2E Tests** | Test complete user flows | Playwright, Cypress |
| **Component Tests** | Test React components | React Testing Library |

---

## Section 2: Backend Testing

### 2.1 pytest Setup

```python
# pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = test_*.py *_test.py
testpaths = tests
addopts = 
    --verbose
    --cov=apps
    --cov-report=html
    --cov-report=term
    --cov-fail-under=70
```

### 2.2 Test Fixtures

```python
# conftest.py
import pytest
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from apps.projects.models import Project
from apps.tasks.models import Task

User = get_user_model()

@pytest.fixture
def user():
    """Create a regular user."""
    return User.objects.create_user(
        email='test@example.com',
        username='testuser',
        password='testpass123'
    )

@pytest.fixture
def admin_user():
    """Create an admin user."""
    return User.objects.create_superuser(
        email='admin@example.com',
        username='admin',
        password='adminpass123'
    )

@pytest.fixture
def api_client():
    """Return an unauthenticated API client."""
    return APIClient()

@pytest.fixture
def auth_client(user):
    """Return an authenticated API client."""
    client = APIClient()
    client.force_authenticate(user=user)
    return client

@pytest.fixture
def project(user):
    """Create a project."""
    return Project.objects.create(
        name='Test Project',
        description='Test project description',
        created_by=user
    )

@pytest.fixture
def task(user, project):
    """Create a task."""
    return Task.objects.create(
        title='Test Task',
        description='Test task description',
        status='todo',
        priority='high',
        project=project,
        created_by=user,
        assigned_to=user
    )
```

### 2.3 Model Tests

```python
# tests/test_models/test_user.py
import pytest
from django.contrib.auth import get_user_model

User = get_user_model()

@pytest.mark.django_db
class TestUserModel:
    def test_create_user(self):
        """Test creating a regular user."""
        user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            password='testpass123'
        )
        assert user.email == 'test@example.com'
        assert user.username == 'testuser'
        assert user.is_active
        assert not user.is_staff
        assert not user.is_superuser

    def test_create_superuser(self):
        """Test creating a superuser."""
        admin = User.objects.create_superuser(
            email='admin@example.com',
            username='admin',
            password='adminpass123'
        )
        assert admin.is_superuser
        assert admin.is_staff

    def test_user_str(self):
        """Test string representation."""
        user = User.objects.create_user(
            email='test@example.com',
            username='testuser'
        )
        assert str(user) == 'test@example.com'

    def test_get_full_name(self):
        """Test getting full name."""
        user = User.objects.create_user(
            email='test@example.com',
            username='testuser',
            first_name='Test',
            last_name='User'
        )
        assert user.get_full_name() == 'Test User'

    def test_has_project_access(self, user, project):
        """Test project access check."""
        assert user.has_project_access(project)
        
        other_user = User.objects.create_user(
            email='other@example.com',
            username='otheruser',
            password='pass123'
        )
        assert not other_user.has_project_access(project)
```

### 2.4 Serializer Tests

```python
# tests/test_serializers/test_task_serializer.py
import pytest
from apps.tasks.serializers import TaskSerializer, TaskCreateSerializer

@pytest.mark.django_db
class TestTaskSerializer:
    def test_task_serializer_fields(self, task):
        """Test TaskSerializer fields."""
        serializer = TaskSerializer(task)
        data = serializer.data
        
        expected_fields = [
            'id', 'title', 'description', 'status', 'status_display',
            'priority', 'priority_display', 'due_date', 'is_overdue',
            'project', 'project_name', 'assigned_to', 'assigned_to_username',
            'created_by', 'created_by_username', 'comment_count',
            'created_at', 'updated_at'
        ]
        for field in expected_fields:
            assert field in data

    def test_task_create_serializer_valid_data(self, user, project):
        """Test TaskCreateSerializer with valid data."""
        data = {
            'title': 'New Task',
            'description': 'New task description',
            'status': 'todo',
            'priority': 'high',
            'project': project.id,
            'assigned_to': user.id,
        }
        serializer = TaskCreateSerializer(data=data)
        assert serializer.is_valid()
        
        task = serializer.save(created_by=user)
        assert task.title == 'New Task'

    def test_task_create_serializer_invalid_title(self, user, project):
        """Test TaskCreateSerializer with invalid title."""
        data = {
            'title': '',
            'project': project.id,
        }
        serializer = TaskCreateSerializer(data=data)
        assert not serializer.is_valid()
        assert 'title' in serializer.errors
```

### 2.5 API View Tests

```python
# tests/test_views/test_task_views.py
import pytest
from django.urls import reverse
from rest_framework import status
from apps.tasks.models import Task

@pytest.mark.django_db
class TestTaskViews:
    def test_list_tasks_unauthenticated(self, api_client):
        """Test that unauthenticated users cannot list tasks."""
        url = reverse('task-list')
        response = api_client.get(url)
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_list_tasks_authenticated(self, auth_client, task):
        """Test that authenticated users can list tasks."""
        url = reverse('task-list')
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data['results']) >= 1

    def test_create_task(self, auth_client, user, project):
        """Test creating a task."""
        url = reverse('task-list')
        data = {
            'title': 'New Test Task',
            'description': 'Test description',
            'status': 'todo',
            'priority': 'high',
            'project': project.id,
            'assigned_to': user.id,
        }
        response = auth_client.post(url, data)
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data['title'] == 'New Test Task'

    def test_retrieve_task(self, auth_client, task):
        """Test retrieving a single task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        response = auth_client.get(url)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['id'] == task.id

    def test_update_task(self, auth_client, task):
        """Test updating a task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Updated Task Title'}
        response = auth_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK
        assert response.data['title'] == 'Updated Task Title'

    def test_delete_task(self, auth_client, task):
        """Test deleting a task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        response = auth_client.delete(url)
        assert response.status_code == status.HTTP_204_NO_CONTENT
        assert not Task.objects.filter(id=task.id).exists()
```

### 2.6 Permission Tests

```python
# tests/test_permissions/test_task_permissions.py
import pytest
from django.urls import reverse
from rest_framework import status
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient

User = get_user_model()

@pytest.mark.django_db
class TestTaskPermissions:
    def test_owner_can_edit_task(self, auth_client, task):
        """Test that task owner can edit their task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Updated by Owner'}
        response = auth_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK

    def test_non_owner_cannot_edit_task(self, user, task):
        """Test that non-owner cannot edit a task."""
        other_client = APIClient()
        other_client.force_authenticate(user=user)
        
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Attempted Update'}
        response = other_client.patch(url, data)
        assert response.status_code == status.HTTP_403_FORBIDDEN

    def test_admin_can_edit_any_task(self, admin_client, task):
        """Test that admin can edit any task."""
        url = reverse('task-detail', kwargs={'pk': task.id})
        data = {'title': 'Updated by Admin'}
        response = admin_client.patch(url, data)
        assert response.status_code == status.HTTP_200_OK
```

---

## Section 3: Frontend Testing

### 3.1 Jest Setup

```javascript
// jest.config.js
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

### 3.2 Test Utilities

```tsx
// tests/setup/test-utils.tsx
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

### 3.3 Component Tests

```tsx
// tests/unit/components/Button.test.tsx
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
});
```

### 3.4 Form Tests

```tsx
// tests/integration/forms/LoginForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@/tests/setup/test-utils';
import { LoginForm } from '@/components/auth/LoginForm';
import { useAuth } from '@/lib/auth/AuthContext';

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
});
```

### 3.5 E2E Tests with Playwright

```typescript
// tests/e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {
  test('user can login', async ({ page }) => {
    await page.goto('/login');
    
    await page.fill('input[type="email"]', 'test@example.com');
    await page.fill('input[type="password"]', 'password123');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('h1')).toContainText('Welcome back');
  });

  test('user can register', async ({ page }) => {
    await page.goto('/register');
    
    await page.fill('#email', 'newuser@example.com');
    await page.fill('#username', 'newuser');
    await page.fill('#password', 'Password123!');
    await page.fill('#confirm_password', 'Password123!');
    await page.click('button[type="submit"]');
    
    await expect(page).toHaveURL('/dashboard');
  });
});
```

---

## Section 4: Mocking

### 4.1 API Mocking with MSW

```typescript
// tests/setup/msw.ts
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.post('http://localhost:8000/api/v1/token/', async ({ request }) => {
    const body = await request.json();
    if (body.email === 'test@example.com' && body.password === 'password123') {
      return HttpResponse.json({
        access: 'mock-access-token',
        refresh: 'mock-refresh-token',
        user: { id: 1, email: 'test@example.com' },
      });
    }
    return new HttpResponse(null, { status: 401 });
  }),

  http.get('http://localhost:8000/api/v1/tasks/', () => {
    return HttpResponse.json({
      results: [
        { id: 1, title: 'Test Task 1', status: 'todo' },
        { id: 2, title: 'Test Task 2', status: 'in_progress' },
      ],
      count: 2,
    });
  }),
];

export const server = setupServer(...handlers);
```

### 4.2 Mocking React Hooks

```tsx
// Mock useRouter
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    refresh: jest.fn(),
    back: jest.fn(),
  }),
  usePathname: () => '/',
  useSearchParams: () => new URLSearchParams(),
}));

// Mock custom hook
jest.mock('@/hooks/useAuth', () => ({
  useAuth: () => ({
    user: { id: 1, name: 'Test User' },
    isAuthenticated: true,
    logout: jest.fn(),
  }),
}));
```

---

## Section 5: Testing Best Practices

### 5.1 Test Naming

```python
# ✅ Good
def test_user_can_login_with_valid_credentials():
    pass

def test_returns_404_when_task_not_found():
    pass

# ❌ Bad
def test_login():
    pass

def test_task():
    pass
```

### 5.2 Test Structure (AAA)

```python
# Arrange - Set up test data
user = User.objects.create_user(email='test@example.com', password='pass123')
client = APIClient()
client.force_authenticate(user=user)

# Act - Perform the action
response = client.get('/api/v1/tasks/')

# Assert - Verify the result
assert response.status_code == 200
assert len(response.data) > 0
```

### 5.3 Test Isolation

```python
# ✅ Each test is independent
def test_user_creation():
    user = User.objects.create_user(email='test@example.com')
    assert user.email == 'test@example.com'

def test_user_deletion():
    user = User.objects.create_user(email='test@example.com')
    user.delete()
    assert not User.objects.filter(email='test@example.com').exists()

# ✅ Use fixtures for setup
@pytest.fixture
def user():
    return User.objects.create_user(email='test@example.com')

def test_user_creation(user):
    assert user.email == 'test@example.com'
```

### 5.4 Testing Edge Cases

```python
# ✅ Test edge cases
def test_create_task_with_empty_title():
    data = {'title': '', 'project': 1}
    serializer = TaskCreateSerializer(data=data)
    assert not serializer.is_valid()
    assert 'title' in serializer.errors

def test_get_task_with_invalid_id():
    response = client.get('/api/v1/tasks/999/')
    assert response.status_code == 404
```

---

## Quick Reference Cards

### Testing Commands

```bash
# Backend (pytest)
pytest                          # Run all tests
pytest -v                       # Verbose output
pytest --cov=apps               # Coverage report
pytest tests/test_views/        # Run specific directory
pytest test_task.py             # Run specific file
pytest -k "test_create"         # Run tests matching name

# Frontend (Jest)
npm test                        # Run all tests
npm test -- --watch             # Watch mode
npm test -- --coverage          # Coverage report
npm test -- tests/unit/         # Run specific directory
npm test -- Button.test.tsx     # Run specific file

# Frontend (Playwright)
npx playwright test             # Run all E2E tests
npx playwright test --ui        # UI mode
npx playwright test auth.spec.ts # Run specific file
npx playwright test --headed    # Headed mode
```

### Assertion Types

| Backend (pytest) | Frontend (Jest) |
|------------------|-----------------|
| `assert x == y` | `expect(x).toEqual(y)` |
| `assert x is True` | `expect(x).toBe(true)` |
| `assert x is None` | `expect(x).toBeNull()` |
| `assert x in list` | `expect(list).toContain(x)` |
| `assert len(list) == n` | `expect(list).toHaveLength(n)` |
| `assert obj.field == value` | `expect(obj.field).toBe(value)` |
| `assert response.status_code == 200` | `expect(status).toBe(200)` |

---

*This concludes Primer 7. You now have the essential testing knowledge needed for the masterclass.*
