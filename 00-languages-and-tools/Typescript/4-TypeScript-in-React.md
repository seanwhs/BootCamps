# Part 4: TypeScript in React

## 4.1 Setting Up React with TypeScript

Now we'll transform our TypeScript knowledge into a real React application. We'll use Vite for fast development and create a fully typed React frontend for TaskFlow.

### The Concept: Type Safety in the Component Tree

React with TypeScript creates a safety net across your entire component hierarchy. When you type a component's props correctly, TypeScript ensures that:
- You can't pass the wrong type of data to a component
- You'll get autocomplete for props in your IDE
- Refactoring becomes safer and easier

### Step 1: Create the React Project

```bash
# Navigate to your project folder
cd ~/taskflow-tutorial

# Create a new Vite project with React and TypeScript
npm create vite@latest frontend -- --template react-ts

# Navigate into the frontend directory
cd frontend

# Install dependencies
npm install

# Install additional packages we'll need
npm install @hookform/resolvers react-hook-form zod
npm install @types/react @types/react-dom --save-dev
```

### Step 2: Configure TypeScript for React

**File:** `frontend/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,

    /* Path Aliases */
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"],
      "@components/*": ["src/components/*"],
      "@types/*": ["src/types/*"],
      "@hooks/*": ["src/hooks/*"],
      "@utils/*": ["src/utils/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### Step 3: Create Project Structure

```bash
cd frontend
mkdir -p src/components
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/types
mkdir -p src/context
mkdir -p src/services
```

Your frontend structure should look like:

```
frontend/
├── src/
│   ├── components/
│   │   ├── common/
│   │   ├── tasks/
│   │   └── projects/
│   ├── hooks/
│   ├── utils/
│   ├── types/
│   ├── context/
│   ├── services/
│   ├── App.tsx
│   └── main.tsx
├── public/
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## 4.2 Typing React Components

Let's start building our TaskFlow components with full type safety.

### The Concept: Props as Contracts

In React, props are the interface between parent and child components. TypeScript makes these interfaces explicit and enforceable.

**File:** `frontend/src/components/common/Button.tsx`

```typescript
/**
 * A fully typed Button component
 * Demonstrates: Props types, event handling, and styled components
 */

import { ButtonHTMLAttributes, ReactNode } from 'react';

// --- Type Definitions ---

// We extend ButtonHTMLAttributes to include all native button props
// but we make some of them required and add our own variants
type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'success' | 'ghost';
type ButtonSize = 'sm' | 'md' | 'lg';

// Custom props for our button
interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    /** The button content */
    children: ReactNode;
    /** Visual style variant */
    variant?: ButtonVariant;
    /** Button size */
    size?: ButtonSize;
    /** If true, shows loading state */
    isLoading?: boolean;
    /** If true, button fills container width */
    fullWidth?: boolean;
    /** Optional icon to display before children */
    leftIcon?: ReactNode;
    /** Optional icon to display after children */
    rightIcon?: ReactNode;
}

// --- Component Implementation ---

export function Button({
    // Destructure our props with defaults
    children,
    variant = 'primary',
    size = 'md',
    isLoading = false,
    fullWidth = false,
    leftIcon,
    rightIcon,
    disabled,
    className = '',
    ...props // Rest of the native button props
}: ButtonProps) {
    // Base styles that always apply
    const baseStyles = `
        inline-flex items-center justify-center
        font-medium rounded-lg
        transition-colors duration-200
        focus:outline-none focus:ring-2 focus:ring-offset-2
        disabled:opacity-50 disabled:cursor-not-allowed
    `;

    // Styles that depend on variant
    const variantStyles = {
        primary: 'bg-blue-600 hover:bg-blue-700 text-white focus:ring-blue-500',
        secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-800 focus:ring-gray-400',
        danger: 'bg-red-600 hover:bg-red-700 text-white focus:ring-red-500',
        success: 'bg-green-600 hover:bg-green-700 text-white focus:ring-green-500',
        ghost: 'bg-transparent hover:bg-gray-100 text-gray-700 focus:ring-gray-400'
    };

    // Styles that depend on size
    const sizeStyles = {
        sm: 'px-3 py-1.5 text-sm',
        md: 'px-4 py-2 text-base',
        lg: 'px-6 py-3 text-lg'
    };

    // Conditional styles
    const widthStyles = fullWidth ? 'w-full' : '';
    const loadingStyles = isLoading ? 'opacity-75 cursor-wait' : '';

    // Combine all styles
    const combinedClassName = `
        ${baseStyles}
        ${variantStyles[variant]}
        ${sizeStyles[size]}
        ${widthStyles}
        ${loadingStyles}
        ${className}
    `.trim();

    // Determine button content
    const buttonContent = isLoading ? (
        // Loading spinner
        <span className="flex items-center gap-2">
            <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                <circle 
                    className="opacity-25" 
                    cx="12" 
                    cy="12" 
                    r="10" 
                    stroke="currentColor" 
                    strokeWidth="4" 
                    fill="none"
                />
                <path 
                    className="opacity-75" 
                    fill="currentColor" 
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                />
            </svg>
            Loading...
        </span>
    ) : (
        // Normal content with optional icons
        <span className="flex items-center gap-2">
            {leftIcon && <span className="flex-shrink-0">{leftIcon}</span>}
            {children}
            {rightIcon && <span className="flex-shrink-0">{rightIcon}</span>}
        </span>
    );

    return (
        <button
            className={combinedClassName}
            disabled={disabled || isLoading}
            {...props} // Spread remaining props (onClick, type, etc.)
        >
            {buttonContent}
        </button>
    );
}

// --- Verification: Type safety in action ---

// This would pass type checking:
// <Button variant="primary" size="lg" onClick={() => {}}>
//     Click Me
// </Button>

// This would cause a TypeScript error:
// <Button variant="invalid">Error</Button>
// <Button size="xl">Error</Button>
```

### Typing Input Components

**File:** `frontend/src/components/common/Input.tsx`

```typescript
/**
 * A fully typed Input component with validation state
 */

import { InputHTMLAttributes, forwardRef, ReactNode } from 'react';

// Extend native input props
interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
    /** Label text for the input */
    label?: string;
    /** Error message to display */
    error?: string;
    /** Helper text to display below the input */
    helper?: string;
    /** Left icon or element */
    leftElement?: ReactNode;
    /** Right icon or element */
    rightElement?: ReactNode;
    /** If true, input takes full width */
    fullWidth?: boolean;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
    ({
        label,
        error,
        helper,
        leftElement,
        rightElement,
        fullWidth = false,
        className = '',
        id,
        ...props
    }, ref) => {
        // Generate a unique ID if not provided
        const inputId = id || `input-${Math.random().toString(36).substr(2, 9)}`;

        // Base styles
        const baseStyles = `
            block w-full px-4 py-2
            border border-gray-300 rounded-lg
            bg-white text-gray-900
            focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent
            transition-colors duration-200
            disabled:bg-gray-100 disabled:cursor-not-allowed
        `;

        // Error styles
        const errorStyles = error 
            ? 'border-red-500 focus:ring-red-500' 
            : '';

        // Width styles
        const widthStyles = fullWidth ? 'w-full' : '';

        // Input with left/right elements needs padding adjustments
        const leftPadding = leftElement ? 'pl-10' : '';
        const rightPadding = rightElement ? 'pr-10' : '';

        const combinedClassName = `
            ${baseStyles}
            ${errorStyles}
            ${widthStyles}
            ${leftPadding}
            ${rightPadding}
            ${className}
        `.trim();

        return (
            <div className={fullWidth ? 'w-full' : ''}>
                {label && (
                    <label 
                        htmlFor={inputId}
                        className="block text-sm font-medium text-gray-700 mb-1"
                    >
                        {label}
                        {props.required && <span className="text-red-500 ml-1">*</span>}
                    </label>
                )}
                
                <div className="relative">
                    {leftElement && (
                        <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
                            {leftElement}
                        </div>
                    )}
                    
                    <input
                        ref={ref}
                        id={inputId}
                        className={combinedClassName}
                        {...props}
                    />
                    
                    {rightElement && (
                        <div className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400">
                            {rightElement}
                        </div>
                    )}
                </div>
                
                {helper && !error && (
                    <p className="mt-1 text-sm text-gray-500">{helper}</p>
                )}
                
                {error && (
                    <p className="mt-1 text-sm text-red-600">{error}</p>
                )}
            </div>
        );
    }
);

Input.displayName = 'Input';
```

### Typing Card and Layout Components

**File:** `frontend/src/components/common/Card.tsx`

```typescript
/**
 * A typed Card component with multiple variations
 */

import { ReactNode } from 'react';

interface CardProps {
    /** Card content */
    children: ReactNode;
    /** Card title */
    title?: string;
    /** Optional subtitle */
    subtitle?: string;
    /** If true, removes padding */
    noPadding?: boolean;
    /** Additional CSS classes */
    className?: string;
    /** Header action buttons or elements */
    headerActions?: ReactNode;
    /** Footer content */
    footer?: ReactNode;
}

export function Card({
    children,
    title,
    subtitle,
    noPadding = false,
    className = '',
    headerActions,
    footer
}: CardProps) {
    return (
        <div className={`bg-white rounded-lg shadow-sm border border-gray-200 ${className}`}>
            {/* Header */}
            {(title || headerActions) && (
                <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
                    <div>
                        {title && (
                            <h3 className="text-lg font-semibold text-gray-900">
                                {title}
                            </h3>
                        )}
                        {subtitle && (
                            <p className="text-sm text-gray-500">{subtitle}</p>
                        )}
                    </div>
                    {headerActions && (
                        <div className="flex items-center gap-2">
                            {headerActions}
                        </div>
                    )}
                </div>
            )}
            
            {/* Body */}
            <div className={noPadding ? '' : 'px-6 py-4'}>
                {children}
            </div>
            
            {/* Footer */}
            {footer && (
                <div className="px-6 py-4 border-t border-gray-200 bg-gray-50 rounded-b-lg">
                    {footer}
                </div>
            )}
        </div>
    );
}
```

## 4.3 Typing React Hooks

Let's create custom hooks with full type safety.

### The Concept: Hooks as Type-Safe State Containers

Custom hooks encapsulate stateful logic. When typed correctly, they become reusable, safe, and predictable.

**File:** `frontend/src/hooks/useLocalStorage.ts`

```typescript
/**
 * A type-safe localStorage hook
 * Demonstrates: Generic hooks, event handling, and error boundaries
 */

import { useState, useEffect, useCallback } from 'react';

// Generic hook that works with any type
export function useLocalStorage<T>(
    key: string,
    initialValue: T
): [T, (value: T | ((val: T) => T)) => void, () => void] {
    // Get stored value from localStorage
    const readStoredValue = useCallback((): T => {
        if (typeof window === 'undefined') {
            return initialValue;
        }

        try {
            const item = window.localStorage.getItem(key);
            if (item) {
                return JSON.parse(item) as T;
            }
        } catch (error) {
            console.warn(`Error reading localStorage key "${key}":`, error);
        }

        return initialValue;
    }, [key, initialValue]);

    // State to hold the value
    const [storedValue, setStoredValue] = useState<T>(readStoredValue);

    // Update localStorage and state
    const setValue = useCallback(
        (value: T | ((val: T) => T)) => {
            try {
                // Allow value to be a function for updater pattern
                const valueToStore = value instanceof Function
                    ? value(storedValue)
                    : value;

                // Save to state
                setStoredValue(valueToStore);

                // Save to localStorage
                if (typeof window !== 'undefined') {
                    window.localStorage.setItem(key, JSON.stringify(valueToStore));
                }
            } catch (error) {
                console.warn(`Error setting localStorage key "${key}":`, error);
            }
        },
        [key, storedValue]
    );

    // Remove from localStorage
    const removeValue = useCallback(() => {
        try {
            if (typeof window !== 'undefined') {
                window.localStorage.removeItem(key);
            }
            setStoredValue(initialValue);
        } catch (error) {
            console.warn(`Error removing localStorage key "${key}":`, error);
        }
    }, [key, initialValue]);

    // Listen for changes from other tabs/windows
    useEffect(() => {
        const handleStorageChange = (event: StorageEvent) => {
            if (event.key === key && event.newValue) {
                try {
                    const newValue = JSON.parse(event.newValue) as T;
                    setStoredValue(newValue);
                } catch {
                    // Handle parse error silently
                }
            }
        };

        window.addEventListener('storage', handleStorageChange);
        return () => window.removeEventListener('storage', handleStorageChange);
    }, [key]);

    return [storedValue, setValue, removeValue];
}

// --- Usage Example ---
// const [tasks, setTasks] = useLocalStorage<Task[]>('tasks', []);
// setTasks([...tasks, newTask]);
```

**File:** `frontend/src/hooks/useFetch.ts`

```typescript
/**
 * A type-safe data fetching hook
 * Demonstrates: Generic hooks, async operations, and error handling
 */

import { useState, useEffect, useCallback } from 'react';

// --- Types ---
type FetchStatus = 'idle' | 'loading' | 'success' | 'error';

interface FetchState<T> {
    data: T | null;
    error: Error | null;
    status: FetchStatus;
}

interface FetchOptions {
    /** If true, automatically fetch on mount */
    autoFetch?: boolean;
    /** Headers to include in the request */
    headers?: HeadersInit;
    /** Callback on successful fetch */
    onSuccess?: (data: any) => void;
    /** Callback on error */
    onError?: (error: Error) => void;
}

// --- Hook Implementation ---
export function useFetch<T>(
    url: string,
    options: FetchOptions = {}
): FetchState<T> & { refetch: () => Promise<void> } {
    const { autoFetch = true, headers = {}, onSuccess, onError } = options;

    const [state, setState] = useState<FetchState<T>>({
        data: null,
        error: null,
        status: 'idle'
    });

    const fetchData = useCallback(async () => {
        setState(prev => ({ ...prev, status: 'loading' }));

        try {
            const response = await fetch(url, { headers });
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json() as T;
            
            setState({
                data,
                error: null,
                status: 'success'
            });

            onSuccess?.(data);
        } catch (error) {
            const err = error instanceof Error ? error : new Error('Unknown error');
            
            setState({
                data: null,
                error: err,
                status: 'error'
            });

            onError?.(err);
        }
    }, [url, headers, onSuccess, onError]);

    // Auto-fetch on mount
    useEffect(() => {
        if (autoFetch) {
            fetchData();
        }
    }, [autoFetch, fetchData]);

    return {
        ...state,
        refetch: fetchData
    };
}

// --- Usage Example ---
// interface Task {
//     id: string;
//     title: string;
// }
//
// const { data, status, error, refetch } = useFetch<Task[]>('/api/tasks');
// 
// if (status === 'loading') return <Spinner />;
// if (status === 'error') return <Error message={error.message} />;
// return <TaskList tasks={data} />;
```

**File:** `frontend/src/hooks/useDebounce.ts`

```typescript
/**
 * A type-safe debounce hook for search inputs
 */

import { useState, useEffect, useCallback } from 'react';

export function useDebounce<T>(
    value: T,
    delay: number = 500
): T {
    const [debouncedValue, setDebouncedValue] = useState<T>(value);

    useEffect(() => {
        const handler = setTimeout(() => {
            setDebouncedValue(value);
        }, delay);

        return () => {
            clearTimeout(handler);
        };
    }, [value, delay]);

    return debouncedValue;
}

// --- Usage Example ---
// const [searchTerm, setSearchTerm] = useState('');
// const debouncedSearch = useDebounce(searchTerm, 300);
// 
// useEffect(() => {
//     if (debouncedSearch) {
//         fetchTasks(debouncedSearch);
//     }
// }, [debouncedSearch]);
```

## 4.4 Typing Forms with React Hook Form and Zod

Let's build type-safe forms for TaskFlow using React Hook Form and Zod.

### The Concept: Unifying Runtime and Compile-Time Validation

Zod schemas define validation at runtime AND generate TypeScript types automatically. This means your validation logic and type definitions always stay in sync.

### Step 1: Install Required Packages

```bash
cd frontend
npm install react-hook-form @hookform/resolvers zod
npm install @types/react --save-dev
```

### Step 2: Create Validation Schemas

**File:** `frontend/src/types/validation.ts`

```typescript
/**
 * Zod validation schemas for TaskFlow forms
 * These generate types AND validate at runtime
 */

import { z } from 'zod';

// --- Task Validation ---

// Base task schema
export const TaskSchema = z.object({
    id: z.string().optional(),
    title: z.string()
        .min(3, 'Title must be at least 3 characters')
        .max(100, 'Title must be at most 100 characters'),
    description: z.string()
        .max(500, 'Description must be at most 500 characters')
        .optional(),
    priority: z.enum(['low', 'medium', 'high', 'urgent']),
    status: z.enum(['todo', 'in-progress', 'review', 'done']),
    projectId: z.string(),
    assigneeId: z.string().optional(),
    dueDate: z.coerce.date()
        .optional()
        .refine(
            (date) => !date || date > new Date(), 
            'Due date must be in the future'
        ),
    tags: z.array(z.string()).default([])
});

// Infer type from schema
export type TaskFormData = z.infer<typeof TaskSchema>;

// --- Project Validation ---

export const ProjectSchema = z.object({
    id: z.string().optional(),
    name: z.string()
        .min(2, 'Project name must be at least 2 characters')
        .max(50, 'Project name must be at most 50 characters'),
    description: z.string()
        .max(200, 'Description must be at most 200 characters')
        .optional(),
    status: z.enum(['active', 'archived', 'completed']),
    ownerId: z.string(),
    memberIds: z.array(z.string()).default([])
});

export type ProjectFormData = z.infer<typeof ProjectSchema>;

// --- User Registration Validation ---

export const RegistrationSchema = z.object({
    email: z.string()
        .email('Please enter a valid email address'),
    password: z.string()
        .min(8, 'Password must be at least 8 characters')
        .regex(
            /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
            'Password must contain at least one uppercase letter, one lowercase letter, and one number'
        ),
    confirmPassword: z.string(),
    name: z.string()
        .min(2, 'Name must be at least 2 characters')
        .max(50, 'Name must be at most 50 characters'),
    termsAccepted: z.boolean()
        .refine(val => val === true, 'You must accept the terms')
}).refine((data) => data.password === data.confirmPassword, {
    message: "Passwords don't match",
    path: ['confirmPassword'] // Attach error to confirmPassword field
});

export type RegistrationFormData = z.infer<typeof RegistrationSchema>;

// --- Login Validation ---

export const LoginSchema = z.object({
    email: z.string().email('Please enter a valid email address'),
    password: z.string().min(1, 'Password is required')
});

export type LoginFormData = z.infer<typeof LoginSchema>;
```

### Step 3: Create Type-Safe Form Components

**File:** `frontend/src/components/tasks/TaskForm.tsx`

```typescript
/**
 * A type-safe task form using React Hook Form and Zod
 */

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { TaskSchema, TaskFormData } from '@/types/validation';
import { Input } from '@/components/common/Input';
import { Button } from '@/components/common/Button';
import { Card } from '@/components/common/Card';

// Props for the form
interface TaskFormProps {
    /** Initial data for editing, or undefined for new task */
    initialData?: Partial<TaskFormData>;
    /** Project ID to assign the task to */
    projectId: string;
    /** Called on successful submit */
    onSubmit: (data: TaskFormData) => Promise<void> | void;
    /** Called when user cancels */
    onCancel?: () => void;
    /** If true, shows loading state */
    isLoading?: boolean;
}

export function TaskForm({
    initialData,
    projectId,
    onSubmit,
    onCancel,
    isLoading = false
}: TaskFormProps) {
    // Initialize the form with React Hook Form
    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
        watch,
        setValue
    } = useForm<TaskFormData>({
        resolver: zodResolver(TaskSchema),
        defaultValues: {
            title: initialData?.title || '',
            description: initialData?.description || '',
            priority: initialData?.priority || 'medium',
            status: initialData?.status || 'todo',
            projectId: projectId,
            assigneeId: initialData?.assigneeId || '',
            dueDate: initialData?.dueDate || undefined,
            tags: initialData?.tags || []
        }
    });

    // Watch fields for conditional rendering
    const priority = watch('priority');
    const status = watch('status');

    // Handle form submission
    const handleFormSubmit = async (data: TaskFormData) => {
        try {
            await onSubmit(data);
        } catch (error) {
            console.error('Form submission error:', error);
            // Handle error (show toast, etc.)
        }
    };

    return (
        <Card title={initialData?.id ? 'Edit Task' : 'Create New Task'}>
            <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
                {/* Title */}
                <Input
                    label="Title"
                    placeholder="Enter task title..."
                    error={errors.title?.message}
                    {...register('title')}
                    required
                />

                {/* Description */}
                <Input
                    label="Description"
                    placeholder="Enter task description..."
                    error={errors.description?.message}
                    {...register('description')}
                />

                {/* Priority - Select input */}
                <div className="flex flex-col gap-1">
                    <label className="text-sm font-medium text-gray-700">
                        Priority
                        <span className="text-red-500 ml-1">*</span>
                    </label>
                    <select
                        className={`
                            block w-full px-4 py-2
                            border border-gray-300 rounded-lg
                            bg-white text-gray-900
                            focus:outline-none focus:ring-2 focus:ring-blue-500
                            ${errors.priority ? 'border-red-500' : ''}
                        `}
                        {...register('priority')}
                    >
                        <option value="low">Low 🟢</option>
                        <option value="medium">Medium 🟡</option>
                        <option value="high">High 🔴</option>
                        <option value="urgent">Urgent 🔥</option>
                    </select>
                    {errors.priority && (
                        <p className="text-sm text-red-600">{errors.priority.message}</p>
                    )}
                </div>

                {/* Status - Select input */}
                <div className="flex flex-col gap-1">
                    <label className="text-sm font-medium text-gray-700">
                        Status
                        <span className="text-red-500 ml-1">*</span>
                    </label>
                    <select
                        className={`
                            block w-full px-4 py-2
                            border border-gray-300 rounded-lg
                            bg-white text-gray-900
                            focus:outline-none focus:ring-2 focus:ring-blue-500
                            ${errors.status ? 'border-red-500' : ''}
                        `}
                        {...register('status')}
                    >
                        <option value="todo">📝 To Do</option>
                        <option value="in-progress">🔄 In Progress</option>
                        <option value="review">🔍 Review</option>
                        <option value="done">✅ Done</option>
                    </select>
                    {errors.status && (
                        <p className="text-sm text-red-600">{errors.status.message}</p>
                    )}
                </div>

                {/* Due Date */}
                <Input
                    label="Due Date"
                    type="date"
                    error={errors.dueDate?.message}
                    {...register('dueDate')}
                />

                {/* Tags Input */}
                <Input
                    label="Tags (comma separated)"
                    placeholder="design, development, review"
                    error={errors.tags?.message}
                    {...register('tags', {
                        setValueAs: (value: string) => {
                            if (!value) return [];
                            return value.split(',').map(tag => tag.trim()).filter(Boolean);
                        }
                    })}
                />

                {/* Action Buttons */}
                <div className="flex items-center justify-end gap-3 pt-4 border-t border-gray-200">
                    {onCancel && (
                        <Button
                            type="button"
                            variant="ghost"
                            onClick={onCancel}
                            disabled={isSubmitting || isLoading}
                        >
                            Cancel
                        </Button>
                    )}
                    <Button
                        type="submit"
                        variant="primary"
                        isLoading={isSubmitting || isLoading}
                        disabled={isSubmitting || isLoading}
                    >
                        {initialData?.id ? 'Update Task' : 'Create Task'}
                    </Button>
                </div>
            </form>
        </Card>
    );
}
```

**File:** `frontend/src/components/auth/LoginForm.tsx`

```typescript
/**
 * A type-safe login form
 */

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { LoginSchema, LoginFormData } from '@/types/validation';
import { Input } from '@/components/common/Input';
import { Button } from '@/components/common/Button';
import { Card } from '@/components/common/Card';

interface LoginFormProps {
    onLogin: (data: LoginFormData) => Promise<void>;
    isLoading?: boolean;
}

export function LoginForm({ onLogin, isLoading = false }: LoginFormProps) {
    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting }
    } = useForm<LoginFormData>({
        resolver: zodResolver(LoginSchema),
        defaultValues: {
            email: '',
            password: ''
        }
    });

    const handleLogin = async (data: LoginFormData) => {
        await onLogin(data);
    };

    return (
        <Card title="Login to TaskFlow" className="max-w-md mx-auto">
            <form onSubmit={handleSubmit(handleLogin)} className="space-y-4">
                <Input
                    label="Email"
                    type="email"
                    placeholder="you@example.com"
                    error={errors.email?.message}
                    {...register('email')}
                    required
                />

                <Input
                    label="Password"
                    type="password"
                    placeholder="Enter your password"
                    error={errors.password?.message}
                    {...register('password')}
                    required
                />

                <Button
                    type="submit"
                    variant="primary"
                    fullWidth
                    isLoading={isSubmitting || isLoading}
                    disabled={isSubmitting || isLoading}
                >
                    Login
                </Button>

                <p className="text-sm text-gray-600 text-center">
                    Don't have an account?{' '}
                    <button
                        type="button"
                        className="text-blue-600 hover:text-blue-700 font-medium"
                        onClick={() => {/* Navigate to register */}}
                    >
                        Sign up
                    </button>
                </p>
            </form>
        </Card>
    );
}
```

## 4.5 Typing Context and State Management

Let's build a type-safe context for global state management.

**File:** `frontend/src/context/TaskContext.tsx`

```typescript
/**
 * A type-safe React Context for Task management
 * Demonstrates: Context with generics, type-safe reducers, and providers
 */

import { createContext, useContext, useReducer, useMemo, ReactNode } from 'react';
import type { Task } from '@/types/taskflow';

// --- State Type ---

interface TaskState {
    tasks: Task[];
    selectedTaskId: string | null;
    isLoading: boolean;
    error: string | null;
    filter: {
        status?: Task['status'];
        priority?: Task['priority'];
        search?: string;
    };
}

// --- Action Types ---

type TaskAction =
    | { type: 'SET_TASKS'; payload: Task[] }
    | { type: 'ADD_TASK'; payload: Task }
    | { type: 'UPDATE_TASK'; payload: Task }
    | { type: 'DELETE_TASK'; payload: string }
    | { type: 'SELECT_TASK'; payload: string | null }
    | { type: 'SET_LOADING'; payload: boolean }
    | { type: 'SET_ERROR'; payload: string | null }
    | { type: 'SET_FILTER'; payload: Partial<TaskState['filter']> };

// --- Context Type ---

interface TaskContextType {
    state: TaskState;
    dispatch: React.Dispatch<TaskAction>;
    // Convenience methods
    setTasks: (tasks: Task[]) => void;
    addTask: (task: Task) => void;
    updateTask: (task: Task) => void;
    deleteTask: (id: string) => void;
    selectTask: (id: string | null) => void;
    setFilter: (filter: Partial<TaskState['filter']>) => void;
}

// --- Reducer ---

function taskReducer(state: TaskState, action: TaskAction): TaskState {
    switch (action.type) {
        case 'SET_TASKS':
            return { ...state, tasks: action.payload };
        
        case 'ADD_TASK':
            return { ...state, tasks: [...state.tasks, action.payload] };
        
        case 'UPDATE_TASK':
            return {
                ...state,
                tasks: state.tasks.map(task =>
                    task.id === action.payload.id ? action.payload : task
                )
            };
        
        case 'DELETE_TASK':
            return {
                ...state,
                tasks: state.tasks.filter(task => task.id !== action.payload),
                selectedTaskId: state.selectedTaskId === action.payload 
                    ? null 
                    : state.selectedTaskId
            };
        
        case 'SELECT_TASK':
            return { ...state, selectedTaskId: action.payload };
        
        case 'SET_LOADING':
            return { ...state, isLoading: action.payload };
        
        case 'SET_ERROR':
            return { ...state, error: action.payload };
        
        case 'SET_FILTER':
            return { ...state, filter: { ...state.filter, ...action.payload } };
        
        default:
            return state;
    }
}

// --- Initial State ---

const initialState: TaskState = {
    tasks: [],
    selectedTaskId: null,
    isLoading: false,
    error: null,
    filter: {}
};

// --- Context ---

const TaskContext = createContext<TaskContextType | undefined>(undefined);

// --- Provider Component ---

interface TaskProviderProps {
    children: ReactNode;
    initialTasks?: Task[];
}

export function TaskProvider({ children, initialTasks = [] }: TaskProviderProps) {
    const [state, dispatch] = useReducer(taskReducer, {
        ...initialState,
        tasks: initialTasks
    });

    // Convenience methods
    const contextValue = useMemo((): TaskContextType => ({
        state,
        dispatch,
        setTasks: (tasks) => dispatch({ type: 'SET_TASKS', payload: tasks }),
        addTask: (task) => dispatch({ type: 'ADD_TASK', payload: task }),
        updateTask: (task) => dispatch({ type: 'UPDATE_TASK', payload: task }),
        deleteTask: (id) => dispatch({ type: 'DELETE_TASK', payload: id }),
        selectTask: (id) => dispatch({ type: 'SELECT_TASK', payload: id }),
        setFilter: (filter) => dispatch({ type: 'SET_FILTER', payload: filter })
    }), [state]);

    return (
        <TaskContext.Provider value={contextValue}>
            {children}
        </TaskContext.Provider>
    );
}

// --- Custom Hook for Consuming Context ---

export function useTasks(): TaskContextType {
    const context = useContext(TaskContext);
    
    if (context === undefined) {
        throw new Error('useTasks must be used within a TaskProvider');
    }
    
    return context;
}

// --- Usage Example ---

// In your App.tsx:
// <TaskProvider initialTasks={fetchedTasks}>
//     <TaskList />
// </TaskProvider>

// In TaskList.tsx:
// const { state, setFilter, selectTask } = useTasks();
// const filteredTasks = state.tasks.filter(task => {
//     if (state.filter.status && task.status !== state.filter.status) return false;
//     if (state.filter.priority && task.priority !== state.filter.priority) return false;
//     if (state.filter.search && !task.title.includes(state.filter.search)) return false;
//     return true;
// });
```

## 4.6 Practical Application: TaskFlow Task List

Let's combine everything to build a complete task list component.

**File:** `frontend/src/components/tasks/TaskList.tsx`

```typescript
/**
 * A fully typed task list component
 * Demonstrates: Component composition, event handling, and state management
 */

import { useState } from 'react';
import { useTasks } from '@/context/TaskContext';
import { Button } from '@/components/common/Button';
import { Card } from '@/components/common/Card';
import { TaskForm } from './TaskForm';
import type { Task, TaskStatus, TaskPriority } from '@/types/taskflow';

// --- Subcomponent: TaskItem ---

interface TaskItemProps {
    task: Task;
    onSelect: (id: string) => void;
    onDelete: (id: string) => void;
    onStatusChange: (id: string, status: TaskStatus) => void;
}

function TaskItem({ task, onSelect, onDelete, onStatusChange }: TaskItemProps) {
    const [isExpanded, setIsExpanded] = useState(false);

    // Priority color mapping
    const priorityColors: Record<TaskPriority, string> = {
        low: 'bg-green-100 text-green-800',
        medium: 'bg-yellow-100 text-yellow-800',
        high: 'bg-red-100 text-red-800',
        urgent: 'bg-purple-100 text-purple-800'
    };

    // Status emoji mapping
    const statusEmojis: Record<TaskStatus, string> = {
        todo: '📝',
        'in-progress': '🔄',
        review: '🔍',
        done: '✅'
    };

    return (
        <div className="border border-gray-200 rounded-lg hover:shadow-md transition-shadow">
            {/* Main row */}
            <div className="flex items-center gap-3 px-4 py-3">
                {/* Status indicator */}
                <button
                    onClick={() => {
                        const nextStatus: Record<TaskStatus, TaskStatus> = {
                            todo: 'in-progress',
                            'in-progress': 'review',
                            review: 'done',
                            done: 'todo'
                        };
                        onStatusChange(task.id, nextStatus[task.status]);
                    }}
                    className="text-2xl hover:scale-110 transition-transform"
                    title="Click to change status"
                >
                    {statusEmojis[task.status]}
                </button>

                {/* Title */}
                <div
                    className="flex-1 cursor-pointer"
                    onClick={() => setIsExpanded(!isExpanded)}
                >
                    <h4 className={`font-medium ${task.status === 'done' ? 'line-through text-gray-400' : 'text-gray-900'}`}>
                        {task.title}
                    </h4>
                    <div className="flex items-center gap-2 text-sm text-gray-500">
                        <span className={`px-2 py-0.5 rounded-full text-xs ${priorityColors[task.priority]}`}>
                            {task.priority}
                        </span>
                        {task.dueDate && (
                            <span>
                                Due: {new Date(task.dueDate).toLocaleDateString()}
                            </span>
                        )}
                    </div>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-2">
                    <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => onSelect(task.id)}
                    >
                        Edit
                    </Button>
                    <Button
                        size="sm"
                        variant="danger"
                        onClick={() => onDelete(task.id)}
                    >
                        Delete
                    </Button>
                </div>
            </div>

            {/* Expanded details */}
            {isExpanded && task.description && (
                <div className="px-4 py-3 border-t border-gray-200 bg-gray-50 rounded-b-lg">
                    <p className="text-gray-700">{task.description}</p>
                    {task.tags && task.tags.length > 0 && (
                        <div className="flex flex-wrap gap-1 mt-2">
                            {task.tags.map((tag, index) => (
                                <span
                                    key={index}
                                    className="px-2 py-0.5 bg-blue-100 text-blue-800 text-xs rounded-full"
                                >
                                    #{tag}
                                </span>
                            ))}
                        </div>
                    )}
                </div>
            )}
        </div>
    );
}

// --- Main Component: TaskList ---

interface TaskListProps {
    onEditTask: (task: Task) => void;
}

export function TaskList({ onEditTask }: TaskListProps) {
    const { state, setFilter, selectTask, deleteTask, updateTask } = useTasks();
    const [showCreateForm, setShowCreateForm] = useState(false);
    const [filterStatus, setFilterStatus] = useState<TaskStatus | 'all'>('all');
    const [searchTerm, setSearchTerm] = useState('');

    // Filter tasks
    const filteredTasks = state.tasks.filter(task => {
        // Status filter
        if (filterStatus !== 'all' && task.status !== filterStatus) {
            return false;
        }
        
        // Search filter
        if (searchTerm && !task.title.toLowerCase().includes(searchTerm.toLowerCase())) {
            return false;
        }
        
        return true;
    });

    // Sort tasks: In-progress first, then by priority
    const sortedTasks = [...filteredTasks].sort((a, b) => {
        // Status priority
        const statusOrder = { todo: 0, 'in-progress': 1, review: 2, done: 3 };
        const aStatus = statusOrder[a.status];
        const bStatus = statusOrder[b.status];
        
        if (aStatus !== bStatus) return aStatus - bStatus;
        
        // Priority order
        const priorityOrder = { urgent: 0, high: 1, medium: 2, low: 3 };
        return priorityOrder[a.priority] - priorityOrder[b.priority];
    });

    const handleCreateTask = async (data: any) => {
        // This would normally call an API
        console.log('Creating task:', data);
        // Add task to context
        // onTaskCreated(data);
        setShowCreateForm(false);
    };

    const handleStatusChange = (id: string, status: TaskStatus) => {
        const task = state.tasks.find(t => t.id === id);
        if (task) {
            updateTask({ ...task, status });
        }
    };

    return (
        <div className="space-y-4">
            {/* Header */}
            <div className="flex items-center justify-between">
                <h2 className="text-2xl font-bold text-gray-900">Tasks</h2>
                <Button
                    variant="primary"
                    onClick={() => setShowCreateForm(true)}
                >
                    + New Task
                </Button>
            </div>

            {/* Filters */}
            <div className="flex flex-wrap items-center gap-3">
                <div className="flex items-center gap-2">
                    <label className="text-sm font-medium text-gray-700">Status:</label>
                    <select
                        className="px-3 py-1.5 border border-gray-300 rounded-lg text-sm"
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value as TaskStatus | 'all')}
                    >
                        <option value="all">All</option>
                        <option value="todo">To Do</option>
                        <option value="in-progress">In Progress</option>
                        <option value="review">Review</option>
                        <option value="done">Done</option>
                    </select>
                </div>

                <div className="flex-1 min-w-[200px]">
                    <input
                        type="text"
                        placeholder="Search tasks..."
                        className="w-full px-3 py-1.5 border border-gray-300 rounded-lg text-sm"
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>

                <span className="text-sm text-gray-500">
                    {sortedTasks.length} tasks
                </span>
            </div>

            {/* Create Task Form */}
            {showCreateForm && (
                <TaskForm
                    projectId="default-project"
                    onSubmit={handleCreateTask}
                    onCancel={() => setShowCreateForm(false)}
                />
            )}

            {/* Task List */}
            <div className="space-y-2">
                {sortedTasks.length === 0 ? (
                    <Card>
                        <div className="text-center py-8 text-gray-500">
                            <p className="text-lg">No tasks found</p>
                            <p className="text-sm">Create your first task to get started!</p>
                        </div>
                    </Card>
                ) : (
                    sortedTasks.map(task => (
                        <TaskItem
                            key={task.id}
                            task={task}
                            onSelect={(id) => {
                                const task = state.tasks.find(t => t.id === id);
                                if (task) onEditTask(task);
                            }}
                            onDelete={(id) => {
                                if (window.confirm('Delete this task?')) {
                                    deleteTask(id);
                                }
                            }}
                            onStatusChange={handleStatusChange}
                        />
                    ))
                )}
            </div>
        </div>
    );
}
```

## 4.7 Typing Event Handlers

Let's create type-safe event handler utilities.

**File:** `frontend/src/utils/eventHandlers.ts`

```typescript
/**
 * Type-safe event handler utilities
 */

import { ChangeEvent, FormEvent, KeyboardEvent, MouseEvent } from 'react';

// --- Generic Event Handlers ---

export function handleInputChange<T>(
    setValue: (value: T) => void
): (event: ChangeEvent<HTMLInputElement>) => void {
    return (event) => {
        setValue(event.target.value as unknown as T);
    };
}

export function handleCheckboxChange(
    setValue: (value: boolean) => void
): (event: ChangeEvent<HTMLInputElement>) => void {
    return (event) => {
        setValue(event.target.checked);
    };
}

export function handleSelectChange<T>(
    setValue: (value: T) => void
): (event: ChangeEvent<HTMLSelectElement>) => void {
    return (event) => {
        setValue(event.target.value as T);
    };
}

export function handleFormSubmit<T>(
    onSubmit: (data: T) => void,
    getData: () => T
): (event: FormEvent<HTMLFormElement>) => void {
    return (event) => {
        event.preventDefault();
        onSubmit(getData());
    };
}

// --- Keyboard Event Handlers ---

export function handleKeyPress(
    callback: () => void,
    key: string = 'Enter'
): (event: KeyboardEvent) => void {
    return (event) => {
        if (event.key === key) {
            event.preventDefault();
            callback();
        }
    };
}

export function handleEscape(
    callback: () => void
): (event: KeyboardEvent) => void {
    return (event) => {
        if (event.key === 'Escape') {
            callback();
        }
    };
}

// --- Mouse Event Handlers ---

export function handleClickOutside(
    ref: React.RefObject<HTMLElement>,
    callback: () => void
): (event: MouseEvent) => void {
    return (event) => {
        if (ref.current && !ref.current.contains(event.target as Node)) {
            callback();
        }
    };
}

// --- Form Event Utilities ---

export function getFormData<T extends Record<string, any>>(
    form: HTMLFormElement
): T {
    const formData = new FormData(form);
    const data: Record<string, any> = {};
    
    for (const [key, value] of formData.entries()) {
        // Handle multiple values (like checkboxes with same name)
        if (key in data) {
            if (Array.isArray(data[key])) {
                data[key].push(value);
            } else {
                data[key] = [data[key], value];
            }
        } else {
            data[key] = value;
        }
    }
    
    return data as T;
}

export function serializeFormData<T>(formData: FormData): T {
    const data: Record<string, any> = {};
    
    for (const [key, value] of formData.entries()) {
        // Handle multiple values
        if (key in data) {
            if (Array.isArray(data[key])) {
                data[key].push(value);
            } else {
                data[key] = [data[key], value];
            }
        } else {
            data[key] = value;
        }
    }
    
    return data as T;
}

// --- Type Guards for Events ---

export function isInputEvent(event: any): event is ChangeEvent<HTMLInputElement> {
    return event && event.target && 'value' in event.target;
}

export function isFormEvent(event: any): event is FormEvent<HTMLFormElement> {
    return event && event.target && event.target.tagName === 'FORM';
}

// --- Usage Example ---

// const [searchTerm, setSearchTerm] = useState('');
// const handleSearch = handleInputChange(setSearchTerm);
// 
// return <input 
//     type="text" 
//     value={searchTerm} 
//     onChange={handleSearch}
//     onKeyDown={handleKeyPress(() => console.log('Searching...'))}
// />;
```

## 4.8 Verification

Let's create a simple app to test our components.

**File:** `frontend/src/App.tsx`

```typescript
/**
 * TaskFlow App - Main Application
 */

import { useState } from 'react';
import { TaskProvider, useTasks } from '@/context/TaskContext';
import { TaskList } from '@/components/tasks/TaskList';
import { Button } from '@/components/common/Button';
import { Card } from '@/components/common/Card';
import type { Task } from '@/types/taskflow';

// --- Mock Data ---

const mockTasks: Task[] = [
    {
        id: '1',
        title: 'Setup TypeScript in React',
        description: 'Configure TypeScript with Vite and React',
        status: 'done',
        priority: 'high',
        projectId: 'project-1',
        createdBy: 'user-1',
        tags: ['setup', 'typescript'],
        createdAt: new Date('2026-01-15'),
        updatedAt: new Date('2026-01-20')
    },
    {
        id: '2',
        title: 'Build Task Form',
        description: 'Create a fully typed form with React Hook Form and Zod',
        status: 'in-progress',
        priority: 'high',
        projectId: 'project-1',
        createdBy: 'user-1',
        tags: ['forms', 'validation'],
        createdAt: new Date('2026-01-20'),
        updatedAt: new Date('2026-01-25')
    },
    {
        id: '3',
        title: 'Write Documentation',
        description: 'Document the task management API',
        status: 'todo',
        priority: 'medium',
        projectId: 'project-1',
        createdBy: 'user-1',
        dueDate: new Date('2026-02-01'),
        tags: ['docs'],
        createdAt: new Date('2026-01-25'),
        updatedAt: new Date('2026-01-25')
    }
];

// --- App Component ---

function AppContent() {
    const { state, addTask } = useTasks();
    const [editingTask, setEditingTask] = useState<Task | null>(null);

    const handleEditTask = (task: Task) => {
        setEditingTask(task);
        console.log('Editing task:', task);
    };

    const handleAddTask = (task: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => {
        const newTask: Task = {
            ...task,
            id: String(Date.now()),
            createdAt: new Date(),
            updatedAt: new Date()
        };
        addTask(newTask);
        console.log('Task added:', newTask);
    };

    return (
        <div className="min-h-screen bg-gray-50 p-6">
            <div className="max-w-6xl mx-auto">
                {/* Header */}
                <header className="mb-8">
                    <h1 className="text-4xl font-bold text-gray-900">TaskFlow</h1>
                    <p className="text-gray-600">Manage your tasks efficiently</p>
                </header>

                {/* Stats */}
                <div className="grid grid-cols-4 gap-4 mb-8">
                    <Card noPadding>
                        <div className="p-4">
                            <div className="text-2xl font-bold">{state.tasks.length}</div>
                            <div className="text-sm text-gray-500">Total Tasks</div>
                        </div>
                    </Card>
                    <Card noPadding>
                        <div className="p-4">
                            <div className="text-2xl font-bold text-yellow-600">
                                {state.tasks.filter(t => t.status === 'in-progress').length}
                            </div>
                            <div className="text-sm text-gray-500">In Progress</div>
                        </div>
                    </Card>
                    <Card noPadding>
                        <div className="p-4">
                            <div className="text-2xl font-bold text-green-600">
                                {state.tasks.filter(t => t.status === 'done').length}
                            </div>
                            <div className="text-sm text-gray-500">Completed</div>
                        </div>
                    </Card>
                    <Card noPadding>
                        <div className="p-4">
                            <div className="text-2xl font-bold text-red-600">
                                {state.tasks.filter(t => t.priority === 'urgent').length}
                            </div>
                            <div className="text-sm text-gray-500">Urgent</div>
                        </div>
                    </Card>
                </div>

                {/* Task List */}
                <TaskList onEditTask={handleEditTask} />

                {/* Debug info (remove in production) */}
                <div className="mt-8 p-4 bg-gray-100 rounded-lg text-xs font-mono">
                    <details>
                        <summary className="cursor-pointer font-bold text-gray-700">
                            Debug: {state.tasks.length} tasks loaded
                        </summary>
                        <pre className="mt-2 overflow-auto max-h-40">
                            {JSON.stringify(state, null, 2)}
                        </pre>
                    </details>
                </div>
            </div>
        </div>
    );
}

export default function App() {
    return (
        <TaskProvider initialTasks={mockTasks}>
            <AppContent />
        </TaskProvider>
    );
}
```

**File:** `frontend/src/main.tsx`

```typescript
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <App />
    </React.StrictMode>
);
```

**File:** `frontend/src/index.css`

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom styles */
body {
    @apply antialiased;
}

/* Scrollbar styling */
::-webkit-scrollbar {
    width: 8px;
}

::-webkit-scrollbar-track {
    @apply bg-gray-100;
}

::-webkit-scrollbar-thumb {
    @apply bg-gray-400 rounded-full;
}

::-webkit-scrollbar-thumb:hover {
    @apply bg-gray-500;
}
```

### The Verification

```bash
cd frontend

# Start the development server
npm run dev

# Open http://localhost:5173 in your browser
# You should see the TaskFlow app with mock tasks

# To build for production:
npm run build

# To preview the build:
npm run preview
```

## 4.9 Summary: Part 4

You've completed Part 4! Here's what you've learned:

### React Components with TypeScript
- **Typing Props:** Using interfaces and types for component props
- **Event Handling:** Type-safe event handlers for common events
- **Component Composition:** Building reusable, typed components
- **Forward Refs:** Using `forwardRef` with proper types

### Custom Hooks
- **Generic Hooks:** Creating reusable hooks that work with any type
- **State Management:** Type-safe state hooks with `useState` and `useReducer`
- **Side Effects:** Typed `useEffect` with proper dependencies
- **Local Storage:** Type-safe persistence with `useLocalStorage`

### Forms and Validation
- **React Hook Form:** Type-safe form management
- **Zod:** Runtime validation that generates TypeScript types
- **Schema-Driven Types:** Single source of truth for validation and types
- **Error Handling:** Proper error display and management

### Context and State
- **Type-Safe Context:** Creating and consuming context with proper types
- **Reducers:** Typed state management with `useReducer`
- **Custom Hooks:** Creating hooks for context consumption

### Practical Application
- Built a complete task management interface
- Created reusable, typed components
- Implemented filtering and searching
- Managed state with context and reducers

### What's Next: Preview of Part 5

In Part 5, we'll take our React application and integrate it with Next.js:
- **App Router:** Server components and client components
- **Data Fetching:** Type-safe data fetching in Next.js
- **Server Actions:** Type-safe server-side mutations
- **API Routes:** Typed API endpoints
- **Environment Variables:** Type-safe env configuration
- **Practical Application:** Complete TaskFlow with Next.js

## Verification Checklist

Before moving to Part 5, ensure:

- [ ] `npm run dev` runs without errors
- [ ] TaskFlow app displays with mock data
- [ ] Form validation works correctly
- [ ] Task list filters and searches work
- [ ] Context state updates properly
- [ ] All TypeScript checks pass (`npm run build`)
