# Part 6: Architecture, Testing, and Debugging

## 6.1 Introduction: Bringing It All Together

Welcome to the final part of our TypeScript journey! In this comprehensive conclusion, we'll cover everything you need to ship production-grade TypeScript applications with confidence. We'll focus on three pillars of professional software development: **Testing**, **Debugging**, and **Architecture**.

### The Concept: Production-Ready TypeScript

Writing TypeScript that compiles is just the beginning. Production-ready TypeScript is:
- **Tested:** Your types and runtime behavior work correctly
- **Debuggable:** You can quickly find and fix issues
- **Architected:** Your codebase scales cleanly with your team
- **Maintainable:** Types evolve gracefully with your application

## 6.2 Type-Safe Testing with Vitest

Let's set up and write comprehensive tests for our TaskFlow application.

### Step 1: Install Testing Dependencies

```bash
cd taskflow-next
npm install --save-dev vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event jsdom
npm install --save-dev @vitejs/plugin-react
```

### Step 2: Configure Vitest

**File:** `vitest.config.ts`

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
    plugins: [react()],
    test: {
        environment: 'jsdom',
        globals: true,
        setupFiles: ['./test/setup.ts'],
        include: ['src/**/*.test.{ts,tsx}'],
        coverage: {
            provider: 'v8',
            reporter: ['text', 'json', 'html'],
            exclude: [
                'node_modules/',
                'test/',
                '**/*.d.ts',
                '**/*.test.{ts,tsx}',
                '**/index.ts',
            ],
        },
    },
    resolve: {
        alias: {
            '@': path.resolve(__dirname, './src'),
        },
    },
});
```

### Step 3: Create Test Setup File

**File:** `test/setup.ts`

```typescript
import '@testing-library/jest-dom';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

// Clean up after each test
afterEach(() => {
    cleanup();
});

// Mock Next.js router
vi.mock('next/navigation', () => ({
    useRouter: () => ({
        push: vi.fn(),
        replace: vi.fn(),
        refresh: vi.fn(),
        back: vi.fn(),
        forward: vi.fn(),
    }),
    usePathname: () => '/',
    useSearchParams: () => new URLSearchParams(),
}));

// Mock Next.js cache
vi.mock('next/cache', () => ({
    revalidatePath: vi.fn(),
}));
```

### Step 4: Write Type-Safe Unit Tests

**File:** `src/lib/validation.test.ts`

```typescript
/**
 * Testing Zod Validation Schemas
 */

import { describe, it, expect } from 'vitest';
import { TaskSchema, ProjectSchema } from '@/validations/taskValidation';

describe('TaskSchema', () => {
    const validTask = {
        title: 'Test Task',
        status: 'todo' as const,
        priority: 'medium' as const,
        projectId: 'proj_123',
        createdBy: 'user_123',
        tags: ['test', 'validation']
    };

    it('should validate a valid task', () => {
        const result = TaskSchema.safeParse(validTask);
        expect(result.success).toBe(true);
        if (result.success) {
            expect(result.data.title).toBe('Test Task');
            expect(result.data.status).toBe('todo');
            expect(result.data.tags).toEqual(['test', 'validation']);
        }
    });

    it('should reject a task with short title', () => {
        const invalidTask = { ...validTask, title: 'Hi' };
        const result = TaskSchema.safeParse(invalidTask);
        expect(result.success).toBe(false);
        if (!result.success) {
            expect(result.error.issues[0].message).toContain('at least 3 characters');
        }
    });

    it('should reject a task with invalid status', () => {
        const invalidTask = { ...validTask, status: 'invalid' };
        const result = TaskSchema.safeParse(invalidTask);
        expect(result.success).toBe(false);
    });

    it('should accept optional fields', () => {
        const taskWithoutOptional = {
            title: 'Test Task',
            status: 'todo' as const,
            priority: 'medium' as const,
            projectId: 'proj_123',
            createdBy: 'user_123'
        };
        const result = TaskSchema.safeParse(taskWithoutOptional);
        expect(result.success).toBe(true);
        if (result.success) {
            expect(result.data.description).toBeUndefined();
            expect(result.data.dueDate).toBeUndefined();
            expect(result.data.tags).toEqual([]);
        }
    });

    it('should reject future due date', () => {
        const pastDate = new Date('2020-01-01');
        const invalidTask = { ...validTask, dueDate: pastDate };
        const result = TaskSchema.safeParse(invalidTask);
        expect(result.success).toBe(false);
    });
});

describe('ProjectSchema', () => {
    const validProject = {
        name: 'Test Project',
        status: 'active' as const,
        ownerId: 'user_123',
        memberIds: ['user_123', 'user_456']
    };

    it('should validate a valid project', () => {
        const result = ProjectSchema.safeParse(validProject);
        expect(result.success).toBe(true);
        if (result.success) {
            expect(result.data.name).toBe('Test Project');
            expect(result.data.memberIds).toHaveLength(2);
        }
    });

    it('should reject a project with short name', () => {
        const invalidProject = { ...validProject, name: 'A' };
        const result = ProjectSchema.safeParse(invalidProject);
        expect(result.success).toBe(false);
    });

    it('should accept empty memberIds', () => {
        const projectWithoutMembers = {
            ...validProject,
            memberIds: []
        };
        const result = ProjectSchema.safeParse(projectWithoutMembers);
        expect(result.success).toBe(true);
        if (result.success) {
            expect(result.data.memberIds).toEqual([]);
        }
    });
});
```

### Step 5: Write Type-Safe Component Tests

**File:** `src/components/tasks/TaskList.test.tsx`

```typescript
/**
 * Testing TaskList Component
 */

import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { TaskList } from './TaskList';

// Mock the server actions
vi.mock('@/server/actions/taskActions', () => ({
    updateTaskStatus: vi.fn().mockResolvedValue({ success: true }),
    deleteTask: vi.fn().mockResolvedValue({ success: true }),
}));

// Mock next/navigation
vi.mock('next/navigation', () => ({
    useRouter: () => ({
        refresh: vi.fn(),
        push: vi.fn(),
    }),
}));

describe('TaskList', () => {
    const mockTasks = [
        {
            id: 'task_1',
            title: 'Test Task 1',
            status: 'todo' as const,
            priority: 'high' as const,
            projectId: 'proj_1',
            createdBy: 'user_1',
            createdAt: new Date('2026-01-01'),
            updatedAt: new Date('2026-01-01'),
            tags: ['test'],
            description: 'Test description',
            dueDate: new Date('2026-02-01'),
            assigneeId: null,
        },
        {
            id: 'task_2',
            title: 'Test Task 2',
            status: 'done' as const,
            priority: 'low' as const,
            projectId: 'proj_1',
            createdBy: 'user_1',
            createdAt: new Date('2026-01-02'),
            updatedAt: new Date('2026-01-02'),
            tags: [],
            description: null,
            dueDate: null,
            assigneeId: null,
        },
    ];

    const mockProjects = [
        { id: 'proj_1', name: 'Project 1' },
        { id: 'proj_2', name: 'Project 2' },
    ];

    it('should render tasks', () => {
        render(<TaskList initialTasks={mockTasks} projects={mockProjects} />);

        expect(screen.getByText('Test Task 1')).toBeInTheDocument();
        expect(screen.getByText('Test Task 2')).toBeInTheDocument();
    });

    it('should filter tasks by status', async () => {
        render(<TaskList initialTasks={mockTasks} projects={mockProjects} />);

        // Open dropdown and select 'done'
        const select = screen.getByLabelText(/status/i);
        await userEvent.selectOptions(select, 'done');

        // Only 'done' tasks should be visible
        expect(screen.getByText('Test Task 2')).toBeInTheDocument();
        expect(screen.queryByText('Test Task 1')).not.toBeInTheDocument();
    });

    it('should search tasks by title', async () => {
        render(<TaskList initialTasks={mockTasks} projects={mockProjects} />);

        const searchInput = screen.getByPlaceholderText(/search tasks/i);
        await userEvent.type(searchInput, 'Task 1');

        expect(screen.getByText('Test Task 1')).toBeInTheDocument();
        expect(screen.queryByText('Test Task 2')).not.toBeInTheDocument();
    });

    it('should expand task to show description', async () => {
        render(<TaskList initialTasks={mockTasks} projects={mockProjects} />);

        const task = screen.getByText('Test Task 1');
        await userEvent.click(task);

        expect(screen.getByText('Test description')).toBeInTheDocument();
    });

    it('should handle status change', async () => {
        render(<TaskList initialTasks={mockTasks} projects={mockProjects} />);

        const statusButton = screen.getAllByRole('button')[0]; // First status button
        await userEvent.click(statusButton);

        await waitFor(() => {
            // The status should have changed (optimistic update)
            // We can't easily test the actual change in a unit test,
            // but we can verify the action was called
            const { updateTaskStatus } = await import('@/server/actions/taskActions');
            expect(updateTaskStatus).toHaveBeenCalled();
        });
    });

    it('should handle task deletion', async () => {
        window.confirm = vi.fn(() => true);

        render(<TaskList initialTasks={mockTasks} projects={mockProjects} />);

        const deleteButtons = screen.getAllByText('Delete');
        await userEvent.click(deleteButtons[0]);

        await waitFor(() => {
            const { deleteTask } = await import('@/server/actions/taskActions');
            expect(deleteTask).toHaveBeenCalled();
        });
    });

    it('should show empty state when no tasks', () => {
        render(<TaskList initialTasks={[]} projects={mockProjects} />);

        expect(screen.getByText('No tasks found')).toBeInTheDocument();
        expect(screen.getByText('Create your first task to get started!')).toBeInTheDocument();
    });
});
```

### Step 6: Write Type-Safe API Tests

**File:** `src/app/api/tasks/route.test.ts`

```typescript
/**
 * Testing API Routes
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { GET, POST } from './route';
import { prisma } from '@/lib/prisma';

// Mock Prisma
vi.mock('@/lib/prisma', () => ({
    prisma: {
        task: {
            findMany: vi.fn(),
            create: vi.fn(),
        },
    },
}));

describe('Tasks API', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('GET /api/tasks', () => {
        it('should return tasks', async () => {
            const mockTasks = [
                { id: '1', title: 'Task 1', status: 'todo' },
                { id: '2', title: 'Task 2', status: 'done' },
            ];

            (prisma.task.findMany as any).mockResolvedValue(mockTasks);

            const request = new Request('http://localhost:3000/api/tasks');
            const response = await GET(request);
            const data = await response.json();

            expect(response.status).toBe(200);
            expect(data.success).toBe(true);
            expect(data.data).toEqual(mockTasks);
            expect(data.timestamp).toBeDefined();
        });

        it('should filter tasks by projectId', async () => {
            const request = new Request(
                'http://localhost:3000/api/tasks?projectId=proj_1'
            );
            await GET(request);

            expect(prisma.task.findMany).toHaveBeenCalledWith(
                expect.objectContaining({
                    where: expect.objectContaining({
                        projectId: 'proj_1',
                    }),
                })
            );
        });

        it('should handle errors gracefully', async () => {
            (prisma.task.findMany as any).mockRejectedValue(new Error('Database error'));

            const request = new Request('http://localhost:3000/api/tasks');
            const response = await GET(request);
            const data = await response.json();

            expect(response.status).toBe(500);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Failed to fetch tasks');
        });
    });

    describe('POST /api/tasks', () => {
        const validTask = {
            title: 'New Task',
            status: 'todo',
            priority: 'medium',
            projectId: 'proj_1',
            createdBy: 'user_1',
            tags: ['test'],
        };

        it('should create a task', async () => {
            const createdTask = { ...validTask, id: 'new_1', createdAt: new Date(), updatedAt: new Date() };
            (prisma.task.create as any).mockResolvedValue(createdTask);

            const request = new Request('http://localhost:3000/api/tasks', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(validTask),
            });

            const response = await POST(request);
            const data = await response.json();

            expect(response.status).toBe(201);
            expect(data.success).toBe(true);
            expect(data.data).toEqual(createdTask);
        });

        it('should reject invalid task data', async () => {
            const invalidTask = { ...validTask, title: 'Hi' }; // Too short

            const request = new Request('http://localhost:3000/api/tasks', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(invalidTask),
            });

            const response = await POST(request);
            const data = await response.json();

            expect(response.status).toBe(400);
            expect(data.success).toBe(false);
            expect(data.error).toBe('Validation failed');
        });

        it('should handle missing fields', async () => {
            const invalidTask = { title: 'Test' }; // Missing required fields

            const request = new Request('http://localhost:3000/api/tasks', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(invalidTask),
            });

            const response = await POST(request);
            const data = await response.json();

            expect(response.status).toBe(400);
            expect(data.success).toBe(false);
        });
    });
});
```

### Step 7: Write Integration Tests for Server Actions

**File:** `src/server/actions/taskActions.test.ts`

```typescript
/**
 * Testing Server Actions
 */

import { describe, it, expect, vi, beforeEach } from 'vitest';
import { createTask, getTasks, updateTask, deleteTask } from './taskActions';
import { prisma } from '@/lib/prisma';

// Mock Prisma
vi.mock('@/lib/prisma', () => ({
    prisma: {
        task: {
            create: vi.fn(),
            findMany: vi.fn(),
            findUnique: vi.fn(),
            update: vi.fn(),
            delete: vi.fn(),
        },
    },
}));

// Mock Next.js cache
vi.mock('next/cache', () => ({
    revalidatePath: vi.fn(),
}));

describe('Task Actions', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    describe('createTask', () => {
        const validInput = {
            title: 'Test Task',
            status: 'todo' as const,
            priority: 'medium' as const,
            projectId: 'proj_1',
            createdBy: 'user_1',
            tags: ['test'],
        };

        it('should create a task with valid input', async () => {
            const mockTask = { ...validInput, id: 'new_1', createdAt: new Date(), updatedAt: new Date() };
            (prisma.task.create as any).mockResolvedValue(mockTask);

            const result = await createTask(validInput);

            expect(result.success).toBe(true);
            expect(result.data).toEqual(mockTask);
            expect(prisma.task.create).toHaveBeenCalledWith(
                expect.objectContaining({
                    data: expect.objectContaining({
                        title: validInput.title,
                        status: validInput.status,
                    }),
                })
            );
        });

        it('should reject invalid input', async () => {
            const invalidInput = { ...validInput, title: 'Hi' };
            const result = await createTask(invalidInput);

            expect(result.success).toBe(false);
            expect(result.error?.code).toBe('VALIDATION_ERROR');
        });

        it('should handle database errors', async () => {
            (prisma.task.create as any).mockRejectedValue(new Error('Database error'));

            const result = await createTask(validInput);

            expect(result.success).toBe(false);
            expect(result.error?.code).toBe('CREATE_TASK_ERROR');
        });
    });

    describe('getTasks', () => {
        it('should return all tasks', async () => {
            const mockTasks = [
                { id: '1', title: 'Task 1' },
                { id: '2', title: 'Task 2' },
            ];
            (prisma.task.findMany as any).mockResolvedValue(mockTasks);

            const result = await getTasks();

            expect(result.success).toBe(true);
            expect(result.data).toEqual(mockTasks);
        });

        it('should filter tasks by projectId', async () => {
            await getTasks('proj_1');

            expect(prisma.task.findMany).toHaveBeenCalledWith(
                expect.objectContaining({
                    where: expect.objectContaining({
                        projectId: 'proj_1',
                    }),
                })
            );
        });
    });

    describe('updateTask', () => {
        const validUpdate = {
            id: 'task_1',
            title: 'Updated Task',
            status: 'in_progress' as const,
        };

        it('should update a task', async () => {
            const existingTask = { id: 'task_1', title: 'Old Task' };
            const updatedTask = { ...existingTask, ...validUpdate };

            (prisma.task.findUnique as any).mockResolvedValue(existingTask);
            (prisma.task.update as any).mockResolvedValue(updatedTask);

            const result = await updateTask(validUpdate);

            expect(result.success).toBe(true);
            expect(result.data).toEqual(updatedTask);
        });

        it('should return error if task not found', async () => {
            (prisma.task.findUnique as any).mockResolvedValue(null);

            const result = await updateTask(validUpdate);

            expect(result.success).toBe(false);
            expect(result.error?.code).toBe('TASK_NOT_FOUND');
        });
    });

    describe('deleteTask', () => {
        it('should delete a task', async () => {
            const existingTask = { id: 'task_1', projectId: 'proj_1' };
            (prisma.task.findUnique as any).mockResolvedValue(existingTask);
            (prisma.task.delete as any).mockResolvedValue(existingTask);

            const result = await deleteTask('task_1');

            expect(result.success).toBe(true);
            expect(result.data).toEqual({ id: 'task_1', deleted: true });
        });

        it('should return error if task not found', async () => {
            (prisma.task.findUnique as any).mockResolvedValue(null);

            const result = await deleteTask('task_1');

            expect(result.success).toBe(false);
            expect(result.error?.code).toBe('TASK_NOT_FOUND');
        });
    });
});
```

### Step 8: Run Tests

**File:** `package.json` (add to scripts)

```json
{
    "scripts": {
        "test": "vitest",
        "test:ui": "vitest --ui",
        "test:coverage": "vitest --coverage",
        "test:run": "vitest run"
    }
}
```

```bash
# Run all tests
npm run test

# Run tests with coverage
npm run test:coverage

# Run tests once (for CI)
npm run test:run
```

## 6.3 Debugging TypeScript Applications

### The Concept: Effective Debugging Strategies

Debugging TypeScript is different from debugging JavaScript. You have two layers to debug:
1. **Compile-time errors:** Type errors caught by the compiler
2. **Runtime errors:** JavaScript errors that occur during execution

### Step 1: Understanding TypeScript Errors

**File:** `src/utils/debugging.ts`

```typescript
/**
 * Debugging Utilities and Patterns
 */

import { ZodError } from 'zod';

// --- 1. Type Error Debugging ---

// Helper to debug complex types
type Debug<T> = T extends any ? { [K in keyof T]: T[K] } : never;

// Example: Debug a complex type
interface ComplexType {
    nested: {
        deeply: {
            nested: {
                value: string;
            };
        };
    };
    array: Array<{
        id: number;
        name: string;
    }>;
}

// Use Debug to see the resolved type
type ResolvedComplex = Debug<ComplexType>;

// --- 2. Runtime Error Handling ---

export class AppError extends Error {
    constructor(
        public code: string,
        message: string,
        public statusCode: number = 500,
        public details?: any
    ) {
        super(message);
        this.name = 'AppError';
    }
}

// --- 3. Error Boundary with Type Safety ---

export function safeExecute<T>(
    fn: () => T,
    fallback: T
): T {
    try {
        return fn();
    } catch (error) {
        console.error('Execution failed:', error);
        return fallback;
    }
}

// --- 4. Zod Error Formatter ---

export function formatZodError(error: ZodError): string {
    return error.errors
        .map(err => `[${err.path.join('.')}] ${err.message}`)
        .join('\n');
}

// --- 5. Logging with Context ---

type LogLevel = 'debug' | 'info' | 'warn' | 'error';

interface LoggerContext {
    component?: string;
    action?: string;
    userId?: string;
    [key: string]: any;
}

export class Logger {
    constructor(private context: LoggerContext = {}) {}

    log(level: LogLevel, message: string, meta?: any) {
        const timestamp = new Date().toISOString();
        const logEntry = {
            timestamp,
            level,
            message,
            context: this.context,
            meta,
        };

        // In development, pretty print
        if (process.env.NODE_ENV === 'development') {
            console.log(`[${timestamp}] ${level.toUpperCase()}:`, {
                ...logEntry,
                // Colorize for readability
            });
        } else {
            // In production, send to logging service
            // This could be sent to services like Sentry, Datadog, etc.
        }
    }

    debug(message: string, meta?: any) {
        this.log('debug', message, meta);
    }

    info(message: string, meta?: any) {
        this.log('info', message, meta);
    }

    warn(message: string, meta?: any) {
        this.log('warn', message, meta);
    }

    error(message: string, meta?: any) {
        this.log('error', message, meta);
    }

    child(newContext: Partial<LoggerContext>): Logger {
        return new Logger({
            ...this.context,
            ...newContext,
        });
    }
}

// --- 6. Assertion Utilities ---

export function assertNonNull<T>(
    value: T | null | undefined,
    message?: string
): asserts value is T {
    if (value === null || value === undefined) {
        throw new Error(message || 'Value is null or undefined');
    }
}

export function assertNever(value: never): never {
    throw new Error(`Unexpected value: ${value}`);
}

// --- 7. Type Guard with Detailed Information ---

export function isObject(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null;
}

export function hasProperty<T extends string>(
    obj: unknown,
    prop: T
): obj is Record<T, unknown> {
    return isObject(obj) && prop in obj;
}

export function assertProperty<T extends string>(
    obj: unknown,
    prop: T
): asserts obj is Record<T, unknown> {
    if (!hasProperty(obj, prop)) {
        throw new Error(`Object missing property: ${prop}`);
    }
}

// --- 8. Performance Debugging ---

export function measurePerformance<T>(
    fn: () => T,
    label: string
): T {
    if (process.env.NODE_ENV === 'development') {
        console.time(label);
        try {
            return fn();
        } finally {
            console.timeEnd(label);
        }
    }
    return fn();
}

export async function measurePerformanceAsync<T>(
    fn: () => Promise<T>,
    label: string
): Promise<T> {
    if (process.env.NODE_ENV === 'development') {
        console.time(label);
        try {
            return await fn();
        } finally {
            console.timeEnd(label);
        }
    }
    return fn();
}

// --- 9. Stack Trace Utilities ---

export function getErrorStack(error: Error): string {
    return error.stack || error.message;
}

export function formatError(error: unknown): string {
    if (error instanceof Error) {
        return `${error.name}: ${error.message}\n${error.stack || ''}`;
    }
    return String(error);
}

// --- 10. Type-Safe Environment Check ---

export function isDevelopment(): boolean {
    return process.env.NODE_ENV === 'development';
}

export function isProduction(): boolean {
    return process.env.NODE_ENV === 'production';
}

export function isTest(): boolean {
    return process.env.NODE_ENV === 'test';
}

// --- Usage Examples ---

export function demonstrateDebugging() {
    const logger = new Logger({ component: 'TaskService' });

    // 1. Type-safe logging
    logger.info('Creating task', { taskId: 'task_123' });

    // 2. Error handling with context
    try {
        const result = JSON.parse('invalid json');
        logger.error('Parse error', { input: 'invalid json' });
    } catch (error) {
        const childLogger = logger.child({ error: formatError(error) });
        childLogger.error('Failed to parse JSON');
    }

    // 3. Assertion usage
    const value: string | undefined = 'hello';
    assertNonNull(value, 'Value must exist');
    // TypeScript now knows value is string

    // 4. Performance measurement
    const result = measurePerformance(() => {
        // Some expensive operation
        return Array.from({ length: 1000 }, (_, i) => i);
    }, 'Array creation');

    console.log('Performance test result:', result.length);
}
```

### Step 2: Advanced TypeScript Debugging Tools

**File:** `.vscode/launch.json` (VS Code debug configuration)

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Next.js",
            "type": "node",
            "request": "launch",
            "runtimeExecutable": "npm",
            "runtimeArgs": ["run", "dev"],
            "console": "integratedTerminal",
            "sourceMaps": true,
            "skipFiles": ["<node_internals>/**"],
            "env": {
                "NODE_OPTIONS": "--inspect"
            }
        },
        {
            "name": "Debug Tests",
            "type": "node",
            "request": "launch",
            "runtimeExecutable": "npm",
            "runtimeArgs": ["run", "test", "--", "--run"],
            "console": "integratedTerminal",
            "sourceMaps": true,
            "skipFiles": ["<node_internals>/**"]
        },
        {
            "name": "Debug Current Test File",
            "type": "node",
            "request": "launch",
            "runtimeExecutable": "npm",
            "runtimeArgs": ["run", "test", "--", "${relativeFile}"],
            "console": "integratedTerminal",
            "sourceMaps": true,
            "skipFiles": ["<node_internals>/**"]
        }
    ]
}
```

### Step 3: TypeScript Performance Optimization

**File:** `src/utils/performance.ts`

```typescript
/**
 * TypeScript Performance Utilities
 */

// --- 1. Lazy Evaluation ---

export function lazy<T>(factory: () => T): () => T {
    let instance: T | null = null;
    return () => {
        if (instance === null) {
            instance = factory();
        }
        return instance;
    };
}

// --- 2. Memoization with Type Safety ---

export function memoize<T extends (...args: any[]) => any>(
    fn: T
): T {
    const cache = new Map<string, ReturnType<T>>();
    
    return ((...args: Parameters<T>) => {
        const key = JSON.stringify(args);
        if (cache.has(key)) {
            return cache.get(key)!;
        }
        const result = fn(...args);
        cache.set(key, result);
        return result;
    }) as T;
}

// --- 3. Debounce with Type Safety ---

export function debounce<T extends (...args: any[]) => any>(
    fn: T,
    delay: number
): (...args: Parameters<T>) => void {
    let timeoutId: NodeJS.Timeout | null = null;
    
    return (...args: Parameters<T>) => {
        if (timeoutId) {
            clearTimeout(timeoutId);
        }
        timeoutId = setTimeout(() => {
            fn(...args);
            timeoutId = null;
        }, delay);
    };
}

// --- 4. Throttle with Type Safety ---

export function throttle<T extends (...args: any[]) => any>(
    fn: T,
    limit: number
): (...args: Parameters<T>) => void {
    let inThrottle: boolean = false;
    
    return (...args: Parameters<T>) => {
        if (!inThrottle) {
            fn(...args);
            inThrottle = true;
            setTimeout(() => {
                inThrottle = false;
            }, limit);
        }
    };
}

// --- 5. Type-Safe Cache ---

export class Cache<K, V> {
    private cache = new Map<K, V>();
    
    constructor(private ttl: number = 60000) {}
    
    set(key: K, value: V): void {
        this.cache.set(key, value);
        setTimeout(() => {
            this.cache.delete(key);
        }, this.ttl);
    }
    
    get(key: K): V | undefined {
        return this.cache.get(key);
    }
    
    has(key: K): boolean {
        return this.cache.has(key);
    }
    
    delete(key: K): boolean {
        return this.cache.delete(key);
    }
    
    clear(): void {
        this.cache.clear();
    }
}

// --- Usage Example ---

export function demonstratePerformance() {
    // Lazy initialization
    const getExpensiveResource = lazy(() => {
        console.log('Creating expensive resource...');
        return Array.from({ length: 10000 }, (_, i) => i);
    });
    
    // Only created when first accessed
    const resource = getExpensiveResource();
    console.log('Resource length:', resource.length);
    
    // Memoized function
    const expensiveFn = memoize((n: number) => {
        console.log(`Computing for ${n}...`);
        return n * n;
    });
    
    console.log(expensiveFn(5)); // Computes
    console.log(expensiveFn(5)); // Returns cached
    
    // Debounced function
    const debouncedLog = debounce((message: string) => {
        console.log('Debounced:', message);
    }, 1000);
    
    debouncedLog('Hello');
    debouncedLog('World'); // Only "World" will be logged
    
    // Cache
    const cache = new Cache<string, number>(5000);
    cache.set('key', 42);
    console.log(cache.get('key')); // 42
    
    setTimeout(() => {
        console.log(cache.get('key')); // undefined after TTL
    }, 6000);
}
```

## 6.4 Architecture Patterns for Large Applications

### The Concept: Scalable TypeScript Architecture

As your application grows, maintaining type safety becomes more challenging. Here are proven patterns for scalable TypeScript architecture.

### Step 1: Clean Architecture with TypeScript

**File:** `src/lib/architecture.md` (Architecture documentation)

```typescript
/**
 * Clean Architecture Implementation
 * Separating concerns for maintainability and testability
 */

// --- Domain Layer (Entities) ---

// Domain models are pure TypeScript types
export interface DomainTask {
    id: string;
    title: string;
    status: 'todo' | 'in_progress' | 'done';
    priority: 'low' | 'medium' | 'high';
    dueDate?: Date;
}

// Domain services contain business logic
export class TaskDomainService {
    canCompleteTask(task: DomainTask): boolean {
        // Business rule: Only high priority tasks with due date can be auto-completed
        if (task.priority === 'high' && task.dueDate) {
            return true;
        }
        return false;
    }

    estimateCompletionTime(task: DomainTask): number {
        // Business logic for estimating completion time
        const baseTime = 1; // hours
        const priorityMultipliers = {
            low: 0.5,
            medium: 1,
            high: 2,
        };
        return baseTime * priorityMultipliers[task.priority];
    }
}

// --- Application Layer (Use Cases) ---

// DTOs (Data Transfer Objects)
export interface CreateTaskDTO {
    title: string;
    description?: string;
    priority: 'low' | 'medium' | 'high';
    dueDate?: Date;
}

export interface TaskResponseDTO {
    id: string;
    title: string;
    status: string;
    priority: string;
    createdBy: string;
    createdAt: Date;
    estimatedCompletion: number;
}

// Use case interfaces
export interface ITaskUseCases {
    createTask(dto: CreateTaskDTO, userId: string): Promise<TaskResponseDTO>;
    getTask(id: string): Promise<TaskResponseDTO>;
    getTasks(filters: TaskFilters): Promise<TaskResponseDTO[]>;
    completeTask(id: string): Promise<TaskResponseDTO>;
    deleteTask(id: string): Promise<void>;
}

export interface TaskFilters {
    status?: 'todo' | 'in_progress' | 'done';
    priority?: 'low' | 'medium' | 'high';
    assignee?: string;
}

// --- Infrastructure Layer ---

// Repository interfaces (abstract the data layer)
export interface ITaskRepository {
    create(task: Omit<DomainTask, 'id'>): Promise<DomainTask>;
    findById(id: string): Promise<DomainTask | null>;
    findMany(filters: TaskFilters): Promise<DomainTask[]>;
    update(id: string, task: Partial<DomainTask>): Promise<DomainTask>;
    delete(id: string): Promise<void>;
}

// Implementation with Prisma
export class PrismaTaskRepository implements ITaskRepository {
    constructor(private prisma: PrismaClient) {}

    async create(task: Omit<DomainTask, 'id'>): Promise<DomainTask> {
        const created = await this.prisma.task.create({
            data: {
                title: task.title,
                status: task.status,
                priority: task.priority,
                dueDate: task.dueDate,
                // Map to database fields
            },
        });
        return this.toDomain(created);
    }

    async findById(id: string): Promise<DomainTask | null> {
        const task = await this.prisma.task.findUnique({ where: { id } });
        return task ? this.toDomain(task) : null;
    }

    async findMany(filters: TaskFilters): Promise<DomainTask[]> {
        const where: any = {};
        if (filters.status) where.status = filters.status;
        if (filters.priority) where.priority = filters.priority;
        
        const tasks = await this.prisma.task.findMany({ where });
        return tasks.map(this.toDomain);
    }

    async update(id: string, task: Partial<DomainTask>): Promise<DomainTask> {
        const updated = await this.prisma.task.update({
            where: { id },
            data: {
                title: task.title,
                status: task.status,
                priority: task.priority,
                dueDate: task.dueDate,
            },
        });
        return this.toDomain(updated);
    }

    async delete(id: string): Promise<void> {
        await this.prisma.task.delete({ where: { id } });
    }

    private toDomain(prismaTask: any): DomainTask {
        return {
            id: prismaTask.id,
            title: prismaTask.title,
            status: prismaTask.status,
            priority: prismaTask.priority,
            dueDate: prismaTask.dueDate,
        };
    }
}

// --- Use Case Implementation ---

export class TaskUseCases implements ITaskUseCases {
    constructor(
        private taskRepo: ITaskRepository,
        private domainService: TaskDomainService
    ) {}

    async createTask(dto: CreateTaskDTO, userId: string): Promise<TaskResponseDTO> {
        const task = await this.taskRepo.create({
            title: dto.title,
            status: 'todo',
            priority: dto.priority,
            dueDate: dto.dueDate,
        });

        const estimatedCompletion = this.domainService.estimateCompletionTime(task);

        return this.toResponse(task, estimatedCompletion);
    }

    async getTask(id: string): Promise<TaskResponseDTO> {
        const task = await this.taskRepo.findById(id);
        if (!task) {
            throw new Error('Task not found');
        }
        
        const estimatedCompletion = this.domainService.estimateCompletionTime(task);
        return this.toResponse(task, estimatedCompletion);
    }

    async getTasks(filters: TaskFilters): Promise<TaskResponseDTO[]> {
        const tasks = await this.taskRepo.findMany(filters);
        return tasks.map(task => {
            const estimatedCompletion = this.domainService.estimateCompletionTime(task);
            return this.toResponse(task, estimatedCompletion);
        });
    }

    async completeTask(id: string): Promise<TaskResponseDTO> {
        const task = await this.taskRepo.findById(id);
        if (!task) {
            throw new Error('Task not found');
        }

        if (!this.domainService.canCompleteTask(task)) {
            throw new Error('Task cannot be completed automatically');
        }

        const updated = await this.taskRepo.update(id, { status: 'done' });
        const estimatedCompletion = this.domainService.estimateCompletionTime(updated);
        return this.toResponse(updated, estimatedCompletion);
    }

    async deleteTask(id: string): Promise<void> {
        await this.taskRepo.delete(id);
    }

    private toResponse(task: DomainTask, estimatedCompletion: number): TaskResponseDTO {
        return {
            id: task.id,
            title: task.title,
            status: task.status,
            priority: task.priority,
            createdBy: 'system', // In real app, fetch from context
            createdAt: new Date(), // In real app, fetch from DB
            estimatedCompletion,
        };
    }
}

// --- Dependency Injection Container ---

export class Container {
    private static instance: Container;
    private services = new Map<string, any>();

    private constructor() {}

    static getInstance(): Container {
        if (!Container.instance) {
            Container.instance = new Container();
        }
        return Container.instance;
    }

    register<T>(key: string, instance: T): void {
        this.services.set(key, instance);
    }

    get<T>(key: string): T {
        const service = this.services.get(key);
        if (!service) {
            throw new Error(`Service ${key} not found`);
        }
        return service;
    }

    // Configure dependencies
    static configure(): void {
        const container = Container.getInstance();
        
        // Register repositories
        const prisma = new PrismaClient();
        const taskRepo = new PrismaTaskRepository(prisma);
        container.register('ITaskRepository', taskRepo);
        
        // Register domain services
        const domainService = new TaskDomainService();
        container.register('TaskDomainService', domainService);
        
        // Register use cases
        const taskUseCases = new TaskUseCases(taskRepo, domainService);
        container.register('ITaskUseCases', taskUseCases);
    }
}

// --- Usage in Next.js App Router ---

// In your page.tsx:
// const container = Container.getInstance();
// const taskUseCases = container.get<ITaskUseCases>('ITaskUseCases');
// const tasks = await taskUseCases.getTasks({});

export default Container;
```

### Step 2: Type-Safe Event System

**File:** `src/lib/events.ts`

```typescript
/**
 * Type-Safe Event System
 * For decoupled communication between components
 */

// --- Event Definitions ---

type EventMap = {
    'TASK_CREATED': {
        taskId: string;
        userId: string;
        timestamp: Date;
    };
    'TASK_UPDATED': {
        taskId: string;
        userId: string;
        changes: Record<string, any>;
        timestamp: Date;
    };
    'TASK_DELETED': {
        taskId: string;
        userId: string;
        timestamp: Date;
    };
    'TASK_COMPLETED': {
        taskId: string;
        userId: string;
        completedAt: Date;
    };
    'COMMENT_ADDED': {
        taskId: string;
        userId: string;
        commentId: string;
        timestamp: Date;
    };
    'USER_ASSIGNED': {
        taskId: string;
        assigneeId: string;
        assignedBy: string;
        timestamp: Date;
    };
};

type EventKey = keyof EventMap;
type EventPayload<K extends EventKey> = EventMap[K];

// --- Event Handler Types ---

type EventHandler<K extends EventKey> = (payload: EventPayload<K>) => void | Promise<void>;

// --- Event Bus ---

export class EventBus {
    private handlers = new Map<EventKey, Set<EventHandler<any>>>();

    // Subscribe to an event
    subscribe<K extends EventKey>(
        event: K,
        handler: EventHandler<K>
    ): () => void {
        if (!this.handlers.has(event)) {
            this.handlers.set(event, new Set());
        }

        const handlers = this.handlers.get(event)!;
        handlers.add(handler);

        // Return unsubscribe function
        return () => {
            handlers.delete(handler);
            if (handlers.size === 0) {
                this.handlers.delete(event);
            }
        };
    }

    // Subscribe once
    subscribeOnce<K extends EventKey>(
        event: K,
        handler: EventHandler<K>
    ): () => void {
        const wrappedHandler: EventHandler<K> = async (payload) => {
            await handler(payload);
            unsubscribe();
        };
        
        const unsubscribe = this.subscribe(event, wrappedHandler);
        return unsubscribe;
    }

    // Publish an event
    async publish<K extends EventKey>(
        event: K,
        payload: EventPayload<K>
    ): Promise<void> {
        const handlers = this.handlers.get(event);
        if (!handlers) return;

        const promises = Array.from(handlers).map(async (handler) => {
            try {
                await handler(payload);
            } catch (error) {
                console.error(`Error in event handler for ${event}:`, error);
                // You might want to log this to an error tracking service
            }
        });

        await Promise.all(promises);
    }

    // Clear all handlers (useful for testing)
    clear(): void {
        this.handlers.clear();
    }
}

// --- Singleton Event Bus ---

export const eventBus = new EventBus();

// --- Event Subscribers (Domain Logic) ---

export function setupEventSubscribers(): void {
    // When a task is completed, send notification
    eventBus.subscribe('TASK_COMPLETED', async (payload) => {
        console.log(`Task ${payload.taskId} completed by ${payload.userId}`);
        // Send notification logic here
    });

    // When a user is assigned to a task, send email
    eventBus.subscribe('USER_ASSIGNED', async (payload) => {
        console.log(`User ${payload.assigneeId} assigned to task ${payload.taskId}`);
        // Send email logic here
    });

    // When a comment is added, update task activity
    eventBus.subscribe('COMMENT_ADDED', async (payload) => {
        console.log(`Comment ${payload.commentId} added to task ${payload.taskId}`);
        // Update activity log logic here
    });
}

// --- Event-Safe API Route ---

export async function handleTaskCompletion(taskId: string, userId: string) {
    // Update database
    // ...

    // Publish event
    await eventBus.publish('TASK_COMPLETED', {
        taskId,
        userId,
        completedAt: new Date(),
    });
}

// --- Usage in Components ---

// In a React component:
// useEffect(() => {
//     const unsubscribe = eventBus.subscribe('TASK_CREATED', (payload) => {
//         console.log('Task created:', payload);
//     });
//     return unsubscribe;
// }, []);
```

### Step 3: Type-Safe API Client

**File:** `src/lib/api-client.ts`

```typescript
/**
 * Type-Safe API Client
 * For making type-safe HTTP requests
 */

import { z } from 'zod';

// --- API Client Configuration ---

interface APIClientOptions {
    baseURL: string;
    headers?: HeadersInit;
    timeout?: number;
}

// --- API Response Types ---

type APIResponse<T> = {
    success: true;
    data: T;
    timestamp: string;
} | {
    success: false;
    error: string;
    details?: unknown;
    timestamp: string;
};

// --- API Client ---

export class APIClient {
    constructor(private options: APIClientOptions) {}

    private async request<T, V = undefined>(
        method: 'GET' | 'POST' | 'PUT' | 'DELETE',
        path: string,
        options?: {
            body?: V;
            query?: Record<string, string>;
            headers?: HeadersInit;
            schema?: z.ZodSchema<T>;
        }
    ): Promise<T> {
        // Build URL with query parameters
        const url = new URL(path, this.options.baseURL);
        if (options?.query) {
            Object.entries(options.query).forEach(([key, value]) => {
                url.searchParams.append(key, value);
            });
        }

        // Build request options
        const requestOptions: RequestInit = {
            method,
            headers: {
                'Content-Type': 'application/json',
                ...this.options.headers,
                ...options?.headers,
            },
        };

        if (options?.body) {
            requestOptions.body = JSON.stringify(options.body);
        }

        // Make the request
        const response = await fetch(url.toString(), requestOptions);
        const data = await response.json() as APIResponse<T>;

        // Validate response with Zod if schema provided
        if (options?.schema && data.success) {
            const validation = options.schema.safeParse(data.data);
            if (!validation.success) {
                throw new Error(`Invalid response structure: ${validation.error.message}`);
            }
            data.data = validation.data;
        }

        // Handle error responses
        if (!data.success) {
            throw new APIError(data.error, response.status, data.details);
        }

        if (!response.ok) {
            throw new APIError(
                data.error || 'Request failed',
                response.status,
                data.details
            );
        }

        return data.data;
    }

    // HTTP Methods with Type Safety
    async get<T>(
        path: string,
        options?: {
            query?: Record<string, string>;
            headers?: HeadersInit;
            schema?: z.ZodSchema<T>;
        }
    ): Promise<T> {
        return this.request<T>('GET', path, options);
    }

    async post<T, V = any>(
        path: string,
        body: V,
        options?: {
            query?: Record<string, string>;
            headers?: HeadersInit;
            schema?: z.ZodSchema<T>;
        }
    ): Promise<T> {
        return this.request<T, V>('POST', path, { ...options, body });
    }

    async put<T, V = any>(
        path: string,
        body: V,
        options?: {
            query?: Record<string, string>;
            headers?: HeadersInit;
            schema?: z.ZodSchema<T>;
        }
    ): Promise<T> {
        return this.request<T, V>('PUT', path, { ...options, body });
    }

    async delete<T>(
        path: string,
        options?: {
            query?: Record<string, string>;
            headers?: HeadersInit;
            schema?: z.ZodSchema<T>;
        }
    ): Promise<T> {
        return this.request<T>('DELETE', path, options);
    }
}

// --- Custom Error Class ---

export class APIError extends Error {
    constructor(
        message: string,
        public statusCode: number = 500,
        public details?: unknown
    ) {
        super(message);
        this.name = 'APIError';
    }
}

// --- Create Singleton Instance ---

export const apiClient = new APIClient({
    baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json',
    },
});

// --- Type-Safe API Functions ---

import { TaskSchema } from '@/validations/taskValidation';
import type { Task } from '@prisma/client';

export const taskAPI = {
    // GET /api/tasks
    getTasks: (filters?: {
        projectId?: string;
        status?: Task['status'];
        priority?: Task['priority'];
    }) => {
        return apiClient.get<Task[]>('/api/tasks', {
            query: filters as Record<string, string>,
        });
    },

    // GET /api/tasks/:id
    getTask: (id: string) => {
        return apiClient.get<Task>(`/api/tasks/${id}`);
    },

    // POST /api/tasks
    createTask: (data: z.infer<typeof TaskSchema>) => {
        return apiClient.post<Task, z.infer<typeof TaskSchema>>(
            '/api/tasks',
            data,
            { schema: TaskSchema }
        );
    },

    // PUT /api/tasks/:id
    updateTask: (
        id: string,
        data: Partial<z.infer<typeof TaskSchema>>
    ) => {
        return apiClient.put<Task, Partial<z.infer<typeof TaskSchema>>>(
            `/api/tasks/${id}`,
            data
        );
    },

    // DELETE /api/tasks/:id
    deleteTask: (id: string) => {
        return apiClient.delete<{ id: string; deleted: boolean }>(
            `/api/tasks/${id}`
        );
    },
};

// --- Usage in Components ---

// In a React component:
// const tasks = await taskAPI.getTasks({ status: 'in_progress' });
// const newTask = await taskAPI.createTask({ title: 'New Task', ... });
```

## 6.5 Production Readiness Checklist

### The Concept: Everything You Need for Production

Here's a comprehensive checklist for shipping your TypeScript application.

### Step 1: Performance Optimization

**File:** `next.config.js`

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
    // TypeScript settings
    typescript: {
        // !! WARN !!
        // Dangerously allow production builds to successfully complete even if
        // your project has type errors.
        // This is NOT recommended for production!
        ignoreBuildErrors: false,
    },

    // ESLint settings
    eslint: {
        // Warn on eslint errors in production
        ignoreDuringBuilds: false,
    },

    // Build optimization
    swcMinify: true,
    compiler: {
        removeConsole: process.env.NODE_ENV === 'production' ? {
            exclude: ['error', 'warn'],
        } : undefined,
    },

    // Image optimization
    images: {
        domains: ['avatars.githubusercontent.com', 'ui-avatars.com'],
        formats: ['image/avif', 'image/webp'],
    },

    // Experimental features
    experimental: {
        typedRoutes: true,
    },

    // Environment variables
    env: {
        APP_VERSION: process.env.npm_package_version,
    },

    // Webpack configuration
    webpack: (config, { isServer }) => {
        // Optimize bundle size
        if (!isServer) {
            config.resolve.fallback = {
                fs: false,
                net: false,
                tls: false,
            };
        }
        return config;
    },
};

module.exports = nextConfig;
```

### Step 2: Environment Validation Script

**File:** `scripts/validate-env.ts`

```typescript
/**
 * Environment Variable Validation Script
 * Run this during CI/CD to ensure all required env vars are present
 */

import { z } from 'zod';
import { config } from 'dotenv';
import path from 'path';

// Load environment variables from .env.local
config({ path: path.resolve(process.cwd(), '.env.local') });

const envSchema = z.object({
    DATABASE_URL: z.string().min(1),
    JWT_SECRET: z.string().min(32),
    NODE_ENV: z.enum(['development', 'production', 'test']),
    
    // Optional but recommended for production
    NEXT_PUBLIC_API_URL: z.string().url().optional(),
    NEXT_PUBLIC_APP_NAME: z.string().default('TaskFlow'),
    
    // Database connection pooling (production only)
    DATABASE_CONNECTION_LIMIT: z.string().optional().default('10'),
    DATABASE_TIMEOUT: z.string().optional().default('30000'),
    
    // Redis for caching (optional)
    REDIS_URL: z.string().optional(),
    
    // Sentry for error tracking (optional)
    SENTRY_DSN: z.string().url().optional(),
    
    // Monitoring (optional)
    DATADOG_API_KEY: z.string().optional(),
});

function validateEnvironment() {
    console.log('🔍 Validating environment variables...');

    const result = envSchema.safeParse(process.env);

    if (!result.success) {
        console.error('❌ Invalid environment variables:');
        result.error.errors.forEach((err) => {
            console.error(`  - ${err.path.join('.')}: ${err.message}`);
        });
        process.exit(1);
    }

    console.log('✅ Environment variables valid!');
    console.log(`   APP_NAME: ${result.data.NEXT_PUBLIC_APP_NAME}`);
    console.log(`   NODE_ENV: ${result.data.NODE_ENV}`);
    
    // Warn about missing optional but recommended variables
    if (!process.env.SENTRY_DSN) {
        console.warn('⚠️  SENTRY_DSN not set - error tracking disabled');
    }
    if (!process.env.REDIS_URL) {
        console.warn('⚠️  REDIS_URL not set - caching disabled');
    }
}

validateEnvironment();
```

### Step 3: TypeScript Build Script

**File:** `package.json` (production scripts)

```json
{
    "scripts": {
        "build": "next build",
        "build:types": "tsc --noEmit",
        "build:validate": "npm run build:types && npm run build",
        "start": "next start",
        "start:prod": "NODE_ENV=production node scripts/validate-env.ts && npm start",
        "predeploy": "npm run lint && npm run test:run && npm run build:validate",
        "deploy": "npm run predeploy && npm run start:prod"
    }
}
```

### Step 4: Monitoring and Error Tracking

**File:** `src/lib/monitoring.ts`

```typescript
/**
 * Production Monitoring and Error Tracking
 */

// --- Metrics Interface ---

interface Metrics {
    name: string;
    value: number;
    tags?: Record<string, string>;
    timestamp?: Date;
}

interface ErrorReport {
    error: Error;
    context?: Record<string, any>;
    severity: 'info' | 'warning' | 'error' | 'critical';
    timestamp: Date;
}

// --- Monitoring Service ---

export class MonitoringService {
    private static instance: MonitoringService;
    private enabled: boolean = true;

    private constructor() {
        this.enabled = process.env.NODE_ENV === 'production';
    }

    static getInstance(): MonitoringService {
        if (!MonitoringService.instance) {
            MonitoringService.instance = new MonitoringService();
        }
        return MonitoringService.instance;
    }

    // Record a metric
    recordMetric(metric: Metrics): void {
        if (!this.enabled) return;

        try {
            // Send to monitoring service (DataDog, NewRelic, etc.)
            if (process.env.DATADOG_API_KEY) {
                // Send to DataDog
                console.log('📊 Metric:', {
                    ...metric,
                    timestamp: metric.timestamp || new Date(),
                });
            } else {
                // Log locally in development
                console.log('📊 Metric:', metric);
            }
        } catch (error) {
            console.error('Failed to record metric:', error);
        }
    }

    // Record an error
    reportError(report: ErrorReport): void {
        if (!this.enabled) return;

        try {
            // Send to error tracking service (Sentry, Rollbar, etc.)
            if (process.env.SENTRY_DSN) {
                // Send to Sentry
                console.log('🚨 Error:', {
                    message: report.error.message,
                    stack: report.error.stack,
                    context: report.context,
                    severity: report.severity,
                    timestamp: report.timestamp,
                });
            } else {
                // Log locally
                console.error('🚨 Error:', {
                    message: report.error.message,
                    stack: report.error.stack,
                    context: report.context,
                    severity: report.severity,
                });
            }
        } catch (error) {
            console.error('Failed to report error:', error);
        }
    }

    // Track API performance
    trackAPI(endpoint: string, duration: number, status: number): void {
        this.recordMetric({
            name: 'api.request.duration',
            value: duration,
            tags: {
                endpoint,
                status: String(status),
            },
        });
    }

    // Track user actions
    trackUserAction(action: string, userId: string, metadata?: Record<string, any>): void {
        this.recordMetric({
            name: 'user.action',
            value: 1,
            tags: {
                action,
                userId,
            },
            ...metadata,
        });
    }

    // Track performance of critical operations
    trackOperation<T>(
        operation: string,
        fn: () => Promise<T>
    ): Promise<T> {
        const start = performance.now();
        
        return fn()
            .then((result) => {
                const duration = performance.now() - start;
                this.recordMetric({
                    name: 'operation.duration',
                    value: duration,
                    tags: { operation },
                });
                return result;
            })
            .catch((error) => {
                const duration = performance.now() - start;
                this.recordMetric({
                    name: 'operation.error',
                    value: duration,
                    tags: { operation },
                });
                this.reportError({
                    error: error instanceof Error ? error : new Error(String(error)),
                    context: { operation },
                    severity: 'error',
                    timestamp: new Date(),
                });
                throw error;
            });
    }
}

// --- Performance Monitoring HOC ---

export function withPerformanceTracking<T extends (...args: any[]) => any>(
    fn: T,
    name: string
): T {
    if (process.env.NODE_ENV !== 'production') {
        return fn;
    }

    return (async (...args: Parameters<T>) => {
        const monitoring = MonitoringService.getInstance();
        const start = performance.now();

        try {
            const result = await fn(...args);
            const duration = performance.now() - start;
            monitoring.recordMetric({
                name: `function.${name}.duration`,
                value: duration,
            });
            return result;
        } catch (error) {
            const duration = performance.now() - start;
            monitoring.recordMetric({
                name: `function.${name}.error`,
                value: duration,
            });
            monitoring.reportError({
                error: error instanceof Error ? error : new Error(String(error)),
                context: { function: name, args },
                severity: 'error',
                timestamp: new Date(),
            });
            throw error;
        }
    }) as T;
}
```

### Step 5: Health Check Endpoint

**File:** `src/app/api/health/route.ts`

```typescript
/**
 * Health Check API Endpoint
 * For monitoring and load balancer health checks
 */

import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { env } from '@/lib/env';

export async function GET() {
    const healthCheck = {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: env.NODE_ENV,
        version: process.env.npm_package_version || 'unknown',
        checks: {
            database: await checkDatabase(),
            memory: checkMemory(),
        },
    };

    const statusCode = healthCheck.checks.database.status === 'ok' ? 200 : 503;

    return NextResponse.json(healthCheck, { status: statusCode });
}

async function checkDatabase() {
    try {
        // Simple database query
        await prisma.$queryRaw`SELECT 1`;
        return { status: 'ok' };
    } catch (error) {
        return {
            status: 'error',
            error: error instanceof Error ? error.message : 'Database connection failed',
        };
    }
}

function checkMemory() {
    const memory = process.memoryUsage();
    const threshold = 512 * 1024 * 1024; // 512MB
    
    const isHealthy = memory.heapUsed < threshold;
    
    return {
        status: isHealthy ? 'ok' : 'warning',
        used: memory.heapUsed,
        limit: threshold,
        ratio: memory.heapUsed / threshold,
    };
}
```

## 6.6 The Capstone: Complete TaskFlow Feature

Now let's build a complete feature from end-to-end, demonstrating everything we've learned.

### Feature: Task Assignment with Notifications

**File:** `src/features/task-assignment/index.ts`

```typescript
/**
 * Task Assignment Feature
 * End-to-end implementation showing all TypeScript patterns
 */

import { z } from 'zod';
import { prisma } from '@/lib/prisma';
import { eventBus } from '@/lib/events';
import { MonitoringService } from '@/lib/monitoring';
import { taskAPI } from '@/lib/api-client';
import { TaskSchema } from '@/validations/taskValidation';

// --- 1. Domain Layer ---

// Domain entity
export interface AssignedTask {
    taskId: string;
    assigneeId: string;
    assignedBy: string;
    assignedAt: Date;
    notificationSent: boolean;
}

// Domain service
export class TaskAssignmentService {
    constructor(private monitoring: MonitoringService) {}

    async assignTask(
        taskId: string,
        assigneeId: string,
        assignedBy: string
    ): Promise<AssignedTask> {
        // Validate that task exists
        const task = await prisma.task.findUnique({
            where: { id: taskId },
            include: { project: true },
        });

        if (!task) {
            throw new Error(`Task ${taskId} not found`);
        }

        // Validate that assignee is a project member
        const isMember = await prisma.projectMember.findFirst({
            where: {
                projectId: task.projectId,
                userId: assigneeId,
            },
        });

        if (!isMember) {
            throw new Error(`User ${assigneeId} is not a member of the project`);
        }

        // Update the task
        const updatedTask = await prisma.task.update({
            where: { id: taskId },
            data: {
                assigneeId,
                updatedAt: new Date(),
            },
        });

        // Create assignment record
        const assignment: AssignedTask = {
            taskId,
            assigneeId,
            assignedBy,
            assignedAt: new Date(),
            notificationSent: false,
        };

        // Publish event
        await eventBus.publish('USER_ASSIGNED', {
            taskId,
            assigneeId,
            assignedBy,
            timestamp: assignment.assignedAt,
        });

        // Track metric
        this.monitoring.recordMetric({
            name: 'task.assigned',
            value: 1,
            tags: {
                taskId,
                assigneeId,
                projectId: task.projectId,
            },
        });

        return assignment;
    }

    async getTaskAssignments(userId: string): Promise<AssignedTask[]> {
        const tasks = await prisma.task.findMany({
            where: { assigneeId: userId },
            select: {
                id: true,
                assigneeId: true,
                updatedAt: true,
            },
        });

        return tasks.map((task) => ({
            taskId: task.id,
            assigneeId: task.assigneeId!,
            assignedBy: 'system', // In real app, this would be stored
            assignedAt: task.updatedAt,
            notificationSent: false,
        }));
    }
}

// --- 2. API Layer ---

// Validation schema for assignment
const AssignTaskSchema = z.object({
    taskId: z.string(),
    assigneeId: z.string(),
});

// API Route handler
export async function handleTaskAssignment(
    body: unknown,
    userId: string
) {
    const monitoring = MonitoringService.getInstance();
    
    return monitoring.trackOperation('task.assignment', async () => {
        // Validate input
        const validation = AssignTaskSchema.safeParse(body);
        if (!validation.success) {
            return {
                success: false,
                error: 'Invalid assignment data',
                details: validation.error.errors,
            };
        }

        // Execute assignment
        const service = new TaskAssignmentService(monitoring);
        
        try {
            const assignment = await service.assignTask(
                validation.data.taskId,
                validation.data.assigneeId,
                userId
            );

            return {
                success: true,
                data: assignment,
            };
        } catch (error) {
            const message = error instanceof Error ? error.message : 'Assignment failed';
            return {
                success: false,
                error: message,
            };
        }
    });
}

// --- 3. React Component ---

import { useState } from 'react';
import { useRouter } from 'next/navigation';

interface TaskAssignmentProps {
    taskId: string;
    currentAssignee?: string;
    projectMembers: Array<{ id: string; name: string }>;
}

export function TaskAssignment({
    taskId,
    currentAssignee,
    projectMembers,
}: TaskAssignmentProps) {
    const router = useRouter();
    const [selectedUser, setSelectedUser] = useState(currentAssignee || '');
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const handleAssign = async () => {
        if (!selectedUser) {
            setError('Please select a user');
            return;
        }

        setIsLoading(true);
        setError(null);

        try {
            const result = await taskAPI.updateTask(taskId, {
                assigneeId: selectedUser,
            });

            // Refresh the page
            router.refresh();
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Assignment failed');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="space-y-4">
            <div className="flex items-center gap-3">
                <select
                    value={selectedUser}
                    onChange={(e) => setSelectedUser(e.target.value)}
                    className="flex-1 px-3 py-2 border border-gray-300 rounded-lg"
                    disabled={isLoading}
                >
                    <option value="">Select assignee...</option>
                    {projectMembers.map((member) => (
                        <option key={member.id} value={member.id}>
                            {member.name}
                        </option>
                    ))}
                </select>

                <button
                    onClick={handleAssign}
                    disabled={isLoading || !selectedUser}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
                >
                    {isLoading ? 'Assigning...' : 'Assign'}
                </button>
            </div>

            {error && (
                <p className="text-sm text-red-600">{error}</p>
            )}
        </div>
    );
}

// --- 4. Server Action ---

'use server';

export async function assignTaskAction(
    taskId: string,
    assigneeId: string
) {
    const monitoring = MonitoringService.getInstance();
    
    return monitoring.trackOperation('server.action.assign', async () => {
        const service = new TaskAssignmentService(monitoring);
        
        try {
            const assignment = await service.assignTask(
                taskId,
                assigneeId,
                'system' // In real app, get from session
            );

            // Revalidate relevant paths
            const { revalidatePath } = await import('next/cache');
            revalidatePath(`/tasks/${taskId}`);
            revalidatePath('/tasks');

            return {
                success: true,
                data: assignment,
            };
        } catch (error) {
            const message = error instanceof Error ? error.message : 'Assignment failed';
            return {
                success: false,
                error: message,
            };
        }
    });
}

// --- 5. Test for the Feature ---

import { describe, it, expect, vi } from 'vitest';

describe('TaskAssignment', () => {
    it('should validate assignment data', async () => {
        const invalidData = { taskId: 'task_1' }; // Missing assigneeId
        const result = await handleTaskAssignment(invalidData, 'user_1');
        
        expect(result.success).toBe(false);
        expect(result.error).toBe('Invalid assignment data');
    });

    it('should handle successful assignment', async () => {
        const validData = {
            taskId: 'task_1',
            assigneeId: 'user_2',
        };

        // Mock the service
        const mockAssignment = {
            taskId: 'task_1',
            assigneeId: 'user_2',
            assignedBy: 'user_1',
            assignedAt: new Date(),
            notificationSent: false,
        };

        vi.mock('./domain', () => ({
            TaskAssignmentService: vi.fn().mockImplementation(() => ({
                assignTask: vi.fn().mockResolvedValue(mockAssignment),
            })),
        }));

        const result = await handleTaskAssignment(validData, 'user_1');
        
        expect(result.success).toBe(true);
        expect(result.data).toEqual(mockAssignment);
    });
});
```

## 6.7 Final Verification and Deployment

### Step 1: Run Production Build

```bash
cd taskflow-next

# Run type checking
npm run build:types

# Run tests
npm run test:run

# Run ESLint
npm run lint

# Build the application
npm run build

# Validate environment
node scripts/validate-env.ts
```

### Step 2: Deploy to Production

```bash
# Deploy to Vercel (recommended for Next.js)
vercel --prod

# Or build and start
npm run build
npm run start
```

### Step 3: Monitor Production

```bash
# Check health endpoint
curl http://your-domain.com/api/health

# Should return:
# {
#   "status": "ok",
#   "timestamp": "2026-01-27T12:00:00.000Z",
#   "uptime": 123.45,
#   "environment": "production",
#   "checks": {
#     "database": { "status": "ok" },
#     "memory": { "status": "ok" }
#   }
# }
```

## 6.8 Summary: What You've Learned

Congratulations on completing the entire TypeScript master series! Here's everything you've learned:

### Part 1: Core Mental Model
- TypeScript as compile-time type checking
- Basic types and type inference
- Union and intersection types
- Type narrowing techniques
- The difference between `any`, `unknown`, and `never`

### Part 2: Objects and Utility Types
- Interfaces vs. type aliases
- Generics for reusable code
- Utility types (`Partial`, `Pick`, `Omit`, `Record`, etc.)
- Advanced `tsconfig.json` configuration

### Part 3: Advanced Types- Conditional types for type-level logic
- Mapped types for transforming object types
- Indexed access types and template literal types
- The `infer` keyword for type extraction
- Built a complete form validation system

### Part 4: TypeScript in React
- Typing React components and props
- Custom hooks with generics
- Type-safe context and state management
- Form validation with React Hook Form and Zod
- Built a complete TaskFlow React frontend

### Part 5: TypeScript in Next.js
- App Router with server and client components
- Server actions for type-safe mutations
- API routes with Zod validation
- Type-safe database access with Prisma
- Environment variable validation

### Part 6: Architecture, Testing, and Debugging
- Type-safe testing with Vitest
- Comprehensive debugging strategies
- Clean architecture patterns
- Type-safe event system
- Production monitoring and optimization
- End-to-end feature implementation

## What's Next?

You now have the skills to:

1. **Build Production Applications:** You can create full-stack applications with end-to-end type safety
2. **Contribute to Open Source:** You understand TypeScript at a deep level
3. **Lead Teams:** You can guide teams in adopting TypeScript best practices
4. **Ship with Confidence:** Your applications will have fewer bugs and better maintainability
5. **Continue Learning:** You're ready for advanced TypeScript topics and patterns

## Resources for Continued Learning

- **Official TypeScript Handbook:** https://www.typescriptlang.org/docs/
- **TypeScript Deep Dive:** https://basarat.gitbook.io/typescript/
- **Advanced TypeScript Patterns:** https://github.com/typescript-cheatsheets/react
- **Next.js TypeScript Documentation:** https://nextjs.org/docs/app/building-your-application/configuring/typescript
- **Prisma TypeScript Documentation:** https://www.prisma.io/docs/concepts/components/prisma-client/type-safety
