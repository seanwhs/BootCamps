# Part 5: TypeScript in Next.js

## 5.1 Setting Up Next.js with TypeScript

Now we'll transform our React application into a production-ready Next.js app with full-stack TypeScript support.

### The Concept: Type-Safe Full-Stack Development

Next.js with TypeScript creates a unified type system across your entire application—from the database to the frontend. This means you get end-to-end type safety: the same types that validate your server logic also power your React components.

### Step 1: Create the Next.js Project

```bash
# Navigate to your project folder
cd ~/taskflow-tutorial

# Create a new Next.js project with TypeScript and the App Router
npx create-next-app@latest taskflow-next --typescript --tailwind --eslint --app

# Navigate into the project
cd taskflow-next

# Install additional dependencies
npm install prisma @prisma/client zod react-hook-form @hookform/resolvers
npm install @types/node --save-dev
```

### Step 2: Configure TypeScript for Next.js

**File:** `taskflow-next/tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@types/*": ["./src/types/*"],
      "@lib/*": ["./src/lib/*"],
      "@server/*": ["./src/server/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@utils/*": ["./src/utils/*"],
      "@validations/*": ["./src/validations/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### Step 3: Create the Project Structure

```bash
cd taskflow-next
mkdir -p src/app
mkdir -p src/components
mkdir -p src/lib
mkdir -p src/server
mkdir -p src/validations
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/types
mkdir -p prisma
```

Your Next.js project structure should look like:

```
taskflow-next/
├── src/
│   ├── app/
│   │   ├── api/
│   │   ├── dashboard/
│   │   ├── projects/
│   │   └── tasks/
│   ├── components/
│   ├── lib/
│   ├── server/
│   ├── validations/
│   ├── hooks/
│   ├── utils/
│   └── types/
├── prisma/
│   └── schema.prisma
├── public/
├── .env.local
├── next.config.js
├── package.json
├── tsconfig.json
└── tailwind.config.js
```

## 5.2 Setting Up Database with Prisma

Let's set up a type-safe database layer using Prisma ORM.

### Step 1: Initialize Prisma

```bash
cd taskflow-next
npx prisma init
```

### Step 2: Define the Database Schema

**File:** `prisma/schema.prisma`

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  password  String   // Hashed password
  avatarUrl String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  projectsCreated Project[] @relation("ProjectOwner")
  projectMembers  ProjectMember[]
  tasksAssigned   Task[]     @relation("TaskAssignee")
  tasksCreated    Task[]     @relation("TaskCreator")
  comments        Comment[]

  @@map("users")
}

model Project {
  id          String   @id @default(cuid())
  name        String
  description String?
  status      ProjectStatus @default(active)
  ownerId     String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relations
  owner    User           @relation("ProjectOwner", fields: [ownerId], references: [id])
  members  ProjectMember[]
  tasks    Task[]
  activity Activity[]

  @@map("projects")
}

model ProjectMember {
  id        String @id @default(cuid())
  projectId String
  userId    String
  role      Role   @default(member)
  joinedAt  DateTime @default(now())

  // Relations
  project Project @relation(fields: [projectId], references: [id])
  user    User    @relation(fields: [userId], references: [id])

  @@unique([projectId, userId])
  @@map("project_members")
}

model Task {
  id          String   @id @default(cuid())
  title       String
  description String?
  status      TaskStatus @default(todo)
  priority    TaskPriority @default(medium)
  projectId   String
  assigneeId  String?
  createdBy   String
  dueDate     DateTime?
  tags        Json     @default("[]") // Store as JSON array
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // Relations
  project  Project  @relation(fields: [projectId], references: [id])
  assignee User?    @relation("TaskAssignee", fields: [assigneeId], references: [id])
  creator  User     @relation("TaskCreator", fields: [createdBy], references: [id])
  comments Comment[]

  @@map("tasks")
}

model Comment {
  id        String   @id @default(cuid())
  content   String
  taskId    String
  userId    String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  // Relations
  task Task @relation(fields: [taskId], references: [id])
  user User @relation(fields: [userId], references: [id])

  @@map("comments")
}

model Activity {
  id        String   @id @default(cuid())
  type      ActivityType
  userId    String
  taskId    String?
  projectId String
  metadata  Json     @default("{}")
  createdAt DateTime @default(now())

  // Relations
  user    User    @relation(fields: [userId], references: [id])
  project Project @relation(fields: [projectId], references: [id])

  @@map("activities")
}

// --- Enums ---
enum ProjectStatus {
  active
  archived
  completed
}

enum TaskStatus {
  todo
  in_progress
  review
  done
}

enum TaskPriority {
  low
  medium
  high
  urgent
}

enum Role {
  owner
  admin
  member
}

enum ActivityType {
  task_created
  task_updated
  task_completed
  comment_added
  user_assigned
  project_created
}
```

### Step 3: Generate TypeScript Types

```bash
npx prisma generate
```

### Step 4: Create Database and Seed Data

**File:** `prisma/seed.ts`

```typescript
import { PrismaClient } from '@prisma/client';
import { hash } from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding database...');

    // Create users
    const hashedPassword = await hash('password123', 12);
    
    const user1 = await prisma.user.upsert({
        where: { email: 'alice@example.com' },
        update: {},
        create: {
            email: 'alice@example.com',
            name: 'Alice',
            password: hashedPassword,
            avatarUrl: 'https://ui-avatars.com/api/?name=Alice'
        }
    });

    const user2 = await prisma.user.upsert({
        where: { email: 'bob@example.com' },
        update: {},
        create: {
            email: 'bob@example.com',
            name: 'Bob',
            password: hashedPassword,
            avatarUrl: 'https://ui-avatars.com/api/?name=Bob'
        }
    });

    // Create a project
    const project = await prisma.project.create({
        data: {
            name: 'TaskFlow Development',
            description: 'Building the next generation task manager',
            status: 'active',
            ownerId: user1.id,
            members: {
                create: [
                    { userId: user1.id, role: 'owner' },
                    { userId: user2.id, role: 'member' }
                ]
            }
        }
    });

    // Create tasks
    await prisma.task.createMany({
        data: [
            {
                title: 'Setup Prisma Database',
                description: 'Configure Prisma and create the database schema',
                status: 'done',
                priority: 'high',
                projectId: project.id,
                createdBy: user1.id,
                assigneeId: user1.id,
                tags: ['setup', 'database'],
                dueDate: new Date('2026-02-01')
            },
            {
                title: 'Build Type-Safe API',
                description: 'Create API routes with TypeScript and Zod validation',
                status: 'in_progress',
                priority: 'high',
                projectId: project.id,
                createdBy: user1.id,
                assigneeId: user2.id,
                tags: ['api', 'typescript'],
                dueDate: new Date('2026-02-15')
            },
            {
                title: 'Design UI Components',
                description: 'Create reusable React components with Tailwind CSS',
                status: 'todo',
                priority: 'medium',
                projectId: project.id,
                createdBy: user1.id,
                assigneeId: user2.id,
                tags: ['ui', 'design'],
                dueDate: new Date('2026-02-20')
            }
        ]
    });

    console.log(`✅ Seeded project: ${project.name}`);
    console.log(`✅ Users created: ${user1.name}, ${user2.name}`);
    console.log('✅ Seeding complete!');
}

main()
    .catch((e) => {
        console.error('❌ Seeding failed:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
```

**File:** `package.json` (add to scripts)

```json
{
  "scripts": {
    "db:push": "prisma db push",
    "db:seed": "tsx prisma/seed.ts",
    "db:studio": "prisma studio"
  }
}
```

### Step 5: Configure Environment Variables

**File:** `.env.local`

```env
# Database
DATABASE_URL="file:./dev.db"

# Next.js
NODE_ENV="development"

# JWT Secret (for auth)
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"

# API Base URL (for client-side API calls)
NEXT_PUBLIC_API_URL="http://localhost:3000"
```

## 5.3 Creating Type-Safe Server Actions

Server Actions in Next.js App Router allow you to run server-side code directly from your React components with full type safety.

### Step 1: Create Server Action Utilities

**File:** `src/server/actions/types.ts`

```typescript
/**
 * Server Action Types and Utilities
 */

import { z } from 'zod';
import type { Task, Project, User } from '@prisma/client';

// --- Action Response Types ---

export type ActionResult<T = any> = {
    success: boolean;
    data?: T;
    error?: {
        code: string;
        message: string;
        details?: unknown;
    };
};

export type ActionHandler<TInput, TOutput> = (
    input: TInput
) => Promise<ActionResult<TOutput>>;

// --- Validation Utilities ---

export function validateInput<T>(
    schema: z.ZodSchema<T>,
    input: unknown
): { success: true; data: T } | { success: false; error: string } {
    try {
        const result = schema.parse(input);
        return { success: true, data: result };
    } catch (error) {
        if (error instanceof z.ZodError) {
            return {
                success: false,
                error: error.errors.map(e => e.message).join(', ')
            };
        }
        return {
            success: false,
            error: 'Invalid input provided'
        };
    }
}

// --- Error Handling ---

export function createErrorResponse(
    code: string,
    message: string,
    details?: unknown
): ActionResult {
    return {
        success: false,
        error: { code, message, details }
    };
}

export function createSuccessResponse<T>(data: T): ActionResult<T> {
    return {
        success: true,
        data
    };
}
```

### Step 2: Create Task Server Actions

**File:** `src/server/actions/taskActions.ts`

```typescript
/**
 * Type-safe Task Server Actions
 */

'use server';

import { prisma } from '@/lib/prisma';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import { validateInput, createSuccessResponse, createErrorResponse } from './types';
import { TaskSchema } from '@/validations/taskValidation';

// --- Types ---

type CreateTaskInput = z.infer<typeof TaskSchema>;
type UpdateTaskInput = Partial<CreateTaskInput> & { id: string };

// --- Action: Get All Tasks ---

export async function getTasks(projectId?: string) {
    try {
        const tasks = await prisma.task.findMany({
            where: projectId ? { projectId } : undefined,
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            },
            orderBy: {
                updatedAt: 'desc'
            }
        });

        return createSuccessResponse(tasks);
    } catch (error) {
        console.error('Error fetching tasks:', error);
        return createErrorResponse(
            'FETCH_TASKS_ERROR',
            'Failed to fetch tasks',
            error
        );
    }
}

// --- Action: Get Task by ID ---

export async function getTaskById(id: string) {
    try {
        const task = await prisma.task.findUnique({
            where: { id },
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                },
                comments: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                name: true,
                                avatarUrl: true
                            }
                        }
                    },
                    orderBy: {
                        createdAt: 'desc'
                    }
                }
            }
        });

        if (!task) {
            return createErrorResponse(
                'TASK_NOT_FOUND',
                `Task with ID ${id} not found`
            );
        }

        return createSuccessResponse(task);
    } catch (error) {
        console.error('Error fetching task:', error);
        return createErrorResponse(
            'FETCH_TASK_ERROR',
            'Failed to fetch task',
            error
        );
    }
}

// --- Action: Create Task ---

export async function createTask(input: CreateTaskInput) {
    try {
        // Validate input
        const validation = validateInput(TaskSchema, input);
        if (!validation.success) {
            return createErrorResponse(
                'VALIDATION_ERROR',
                validation.error
            );
        }

        // Create task
        const task = await prisma.task.create({
            data: {
                title: validation.data.title,
                description: validation.data.description,
                status: validation.data.status,
                priority: validation.data.priority,
                projectId: validation.data.projectId,
                createdBy: validation.data.createdBy,
                assigneeId: validation.data.assigneeId,
                dueDate: validation.data.dueDate,
                tags: validation.data.tags || []
            },
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            }
        });

        // Revalidate the tasks page
        revalidatePath('/tasks');
        revalidatePath(`/projects/${task.projectId}`);

        return createSuccessResponse(task);
    } catch (error) {
        console.error('Error creating task:', error);
        return createErrorResponse(
            'CREATE_TASK_ERROR',
            'Failed to create task',
            error
        );
    }
}

// --- Action: Update Task ---

export async function updateTask(input: UpdateTaskInput) {
    try {
        const { id, ...updates } = input;

        // Check if task exists
        const existingTask = await prisma.task.findUnique({
            where: { id }
        });

        if (!existingTask) {
            return createErrorResponse(
                'TASK_NOT_FOUND',
                `Task with ID ${id} not found`
            );
        }

        // Validate updates
        const validation = validateInput(TaskSchema.partial(), updates);
        if (!validation.success) {
            return createErrorResponse(
                'VALIDATION_ERROR',
                validation.error
            );
        }

        // Update task
        const task = await prisma.task.update({
            where: { id },
            data: {
                ...validation.data,
                updatedAt: new Date()
            },
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            }
        });

        // Revalidate paths
        revalidatePath('/tasks');
        revalidatePath(`/projects/${task.projectId}`);
        revalidatePath(`/tasks/${id}`);

        return createSuccessResponse(task);
    } catch (error) {
        console.error('Error updating task:', error);
        return createErrorResponse(
            'UPDATE_TASK_ERROR',
            'Failed to update task',
            error
        );
    }
}

// --- Action: Delete Task ---

export async function deleteTask(id: string) {
    try {
        // Check if task exists
        const existingTask = await prisma.task.findUnique({
            where: { id }
        });

        if (!existingTask) {
            return createErrorResponse(
                'TASK_NOT_FOUND',
                `Task with ID ${id} not found`
            );
        }

        // Delete task
        await prisma.task.delete({
            where: { id }
        });

        // Revalidate paths
        revalidatePath('/tasks');
        revalidatePath(`/projects/${existingTask.projectId}`);

        return createSuccessResponse({ id, deleted: true });
    } catch (error) {
        console.error('Error deleting task:', error);
        return createErrorResponse(
            'DELETE_TASK_ERROR',
            'Failed to delete task',
            error
        );
    }
}

// --- Action: Update Task Status ---

export async function updateTaskStatus(id: string, status: 'todo' | 'in_progress' | 'review' | 'done') {
    try {
        const task = await prisma.task.update({
            where: { id },
            data: {
                status,
                updatedAt: new Date()
            },
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                }
            }
        });

        revalidatePath('/tasks');
        revalidatePath(`/projects/${task.projectId}`);

        return createSuccessResponse(task);
    } catch (error) {
        console.error('Error updating task status:', error);
        return createErrorResponse(
            'UPDATE_STATUS_ERROR',
            'Failed to update task status',
            error
        );
    }
}
```

### Step 3: Create Zod Validation Schemas

**File:** `src/validations/taskValidation.ts`

```typescript
/**
 * Task Validation Schemas
 * Used for both server-side validation and client-side forms
 */

import { z } from 'zod';

export const TaskSchema = z.object({
    id: z.string().optional(),
    title: z.string()
        .min(3, 'Title must be at least 3 characters')
        .max(100, 'Title must be at most 100 characters'),
    description: z.string()
        .max(500, 'Description must be at most 500 characters')
        .optional(),
    status: z.enum(['todo', 'in_progress', 'review', 'done']),
    priority: z.enum(['low', 'medium', 'high', 'urgent']),
    projectId: z.string(),
    assigneeId: z.string().optional(),
    createdBy: z.string(),
    dueDate: z.coerce.date()
        .optional()
        .refine(
            (date) => !date || date > new Date(),
            'Due date must be in the future'
        ),
    tags: z.array(z.string()).default([])
});

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
```

## 5.4 Creating Type-Safe API Routes

Let's create REST API endpoints with proper TypeScript types.

**File:** `src/app/api/tasks/route.ts`

```typescript
/**
 * Type-safe API Route: GET and POST tasks
 */

import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaskSchema } from '@/validations/taskValidation';
import type { Task } from '@prisma/client';

// --- GET: Fetch all tasks ---

export async function GET(request: Request) {
    try {
        // Parse query parameters
        const { searchParams } = new URL(request.url);
        const projectId = searchParams.get('projectId');
        const status = searchParams.get('status');
        const priority = searchParams.get('priority');

        // Build filter
        const where: any = {};
        if (projectId) where.projectId = projectId;
        if (status) where.status = status as Task['status'];
        if (priority) where.priority = priority as Task['priority'];

        // Fetch tasks
        const tasks = await prisma.task.findMany({
            where,
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            },
            orderBy: {
                updatedAt: 'desc'
            }
        });

        return NextResponse.json({
            success: true,
            data: tasks,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('GET /api/tasks error:', error);
        return NextResponse.json(
            {
                success: false,
                error: 'Failed to fetch tasks',
                timestamp: new Date().toISOString()
            },
            { status: 500 }
        );
    }
}

// --- POST: Create a new task ---

export async function POST(request: Request) {
    try {
        // Parse and validate request body
        const body = await request.json();
        
        const validation = TaskSchema.safeParse(body);
        if (!validation.success) {
            return NextResponse.json(
                {
                    success: false,
                    error: 'Validation failed',
                    details: validation.error.errors,
                    timestamp: new Date().toISOString()
                },
                { status: 400 }
            );
        }

        // Create task
        const task = await prisma.task.create({
            data: {
                title: validation.data.title,
                description: validation.data.description,
                status: validation.data.status,
                priority: validation.data.priority,
                projectId: validation.data.projectId,
                createdBy: validation.data.createdBy,
                assigneeId: validation.data.assigneeId,
                dueDate: validation.data.dueDate,
                tags: validation.data.tags || []
            },
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            }
        });

        return NextResponse.json({
            success: true,
            data: task,
            timestamp: new Date().toISOString()
        }, { status: 201 });
    } catch (error) {
        console.error('POST /api/tasks error:', error);
        return NextResponse.json(
            {
                success: false,
                error: 'Failed to create task',
                timestamp: new Date().toISOString()
            },
            { status: 500 }
        );
    }
}
```

**File:** `src/app/api/tasks/[id]/route.ts`

```typescript
/**
 * Type-safe API Route: GET, PUT, DELETE individual tasks
 */

import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { TaskSchema } from '@/validations/taskValidation';

// --- GET: Fetch a single task ---

export async function GET(
    request: Request,
    { params }: { params: { id: string } }
) {
    try {
        const task = await prisma.task.findUnique({
            where: { id: params.id },
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                },
                comments: {
                    include: {
                        user: {
                            select: {
                                id: true,
                                name: true,
                                avatarUrl: true
                            }
                        }
                    },
                    orderBy: {
                        createdAt: 'desc'
                    }
                }
            }
        });

        if (!task) {
            return NextResponse.json(
                {
                    success: false,
                    error: 'Task not found',
                    timestamp: new Date().toISOString()
                },
                { status: 404 }
            );
        }

        return NextResponse.json({
            success: true,
            data: task,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('GET /api/tasks/[id] error:', error);
        return NextResponse.json(
            {
                success: false,
                error: 'Failed to fetch task',
                timestamp: new Date().toISOString()
            },
            { status: 500 }
        );
    }
}

// --- PUT: Update a task ---

export async function PUT(
    request: Request,
    { params }: { params: { id: string } }
) {
    try {
        // Check if task exists
        const existingTask = await prisma.task.findUnique({
            where: { id: params.id }
        });

        if (!existingTask) {
            return NextResponse.json(
                {
                    success: false,
                    error: 'Task not found',
                    timestamp: new Date().toISOString()
                },
                { status: 404 }
            );
        }

        // Parse and validate request body
        const body = await request.json();
        const validation = TaskSchema.partial().safeParse(body);

        if (!validation.success) {
            return NextResponse.json(
                {
                    success: false,
                    error: 'Validation failed',
                    details: validation.error.errors,
                    timestamp: new Date().toISOString()
                },
                { status: 400 }
            );
        }

        // Update task
        const task = await prisma.task.update({
            where: { id: params.id },
            data: {
                ...validation.data,
                updatedAt: new Date()
            },
            include: {
                assignee: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        avatarUrl: true
                    }
                },
                creator: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            }
        });

        return NextResponse.json({
            success: true,
            data: task,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('PUT /api/tasks/[id] error:', error);
        return NextResponse.json(
            {
                success: false,
                error: 'Failed to update task',
                timestamp: new Date().toISOString()
            },
            { status: 500 }
        );
    }
}

// --- DELETE: Delete a task ---

export async function DELETE(
    request: Request,
    { params }: { params: { id: string } }
) {
    try {
        // Check if task exists
        const existingTask = await prisma.task.findUnique({
            where: { id: params.id }
        });

        if (!existingTask) {
            return NextResponse.json(
                {
                    success: false,
                    error: 'Task not found',
                    timestamp: new Date().toISOString()
                },
                { status: 404 }
            );
        }

        // Delete task
        await prisma.task.delete({
            where: { id: params.id }
        });

        return NextResponse.json({
            success: true,
            data: { id: params.id, deleted: true },
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error('DELETE /api/tasks/[id] error:', error);
        return NextResponse.json(
            {
                success: false,
                error: 'Failed to delete task',
                timestamp: new Date().toISOString()
            },
            { status: 500 }
        );
    }
}
```

## 5.5 Creating Type-Safe Pages with App Router

Now let's create the frontend pages that consume our API and server actions.

### Step 1: Create a Type-Safe Data Fetching Hook

**File:** `src/hooks/useTasks.ts`

```typescript
/**
 * Type-safe hook for fetching tasks
 */

import { useState, useEffect, useCallback } from 'react';
import type { Task } from '@prisma/client';

interface UseTasksOptions {
    projectId?: string;
    status?: Task['status'];
    priority?: Task['priority'];
    autoFetch?: boolean;
}

interface UseTasksResult {
    tasks: Task[];
    isLoading: boolean;
    error: string | null;
    refetch: () => Promise<void>;
}

export function useTasks(options: UseTasksOptions = {}): UseTasksResult {
    const { projectId, status, priority, autoFetch = true } = options;

    const [tasks, setTasks] = useState<Task[]>([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const fetchTasks = useCallback(async () => {
        setIsLoading(true);
        setError(null);

        try {
            // Build query string
            const params = new URLSearchParams();
            if (projectId) params.append('projectId', projectId);
            if (status) params.append('status', status);
            if (priority) params.append('priority', priority);

            const url = `/api/tasks${params.toString() ? `?${params}` : ''}`;
            const response = await fetch(url);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const result = await response.json();
            
            if (!result.success) {
                throw new Error(result.error || 'Failed to fetch tasks');
            }

            setTasks(result.data);
        } catch (err) {
            const message = err instanceof Error ? err.message : 'Unknown error';
            setError(message);
            console.error('Error fetching tasks:', err);
        } finally {
            setIsLoading(false);
        }
    }, [projectId, status, priority]);

    useEffect(() => {
        if (autoFetch) {
            fetchTasks();
        }
    }, [autoFetch, fetchTasks]);

    return { tasks, isLoading, error, refetch: fetchTasks };
}
```

### Step 2: Create the Task List Page (Server Component)

**File:** `src/app/tasks/page.tsx`

```typescript
/**
 * Tasks Page - Server Component
 * Fetches data on the server and passes it to client components
 */

import { prisma } from '@/lib/prisma';
import { TaskList } from '@/components/tasks/TaskList';
import { CreateTaskButton } from '@/components/tasks/CreateTaskButton';
import type { Task } from '@prisma/client';

// This is a Server Component - it runs on the server
export default async function TasksPage() {
    // Fetch tasks on the server
    const tasks = await prisma.task.findMany({
        include: {
            assignee: {
                select: {
                    id: true,
                    name: true,
                    email: true,
                    avatarUrl: true
                }
            },
            creator: {
                select: {
                    id: true,
                    name: true,
                    email: true
                }
            }
        },
        orderBy: {
            updatedAt: 'desc'
        }
    });

    // Get unique projects for filter dropdown
    const projects = await prisma.project.findMany({
        select: {
            id: true,
            name: true
        }
    });

    return (
        <div className="container mx-auto px-4 py-8">
            <div className="flex items-center justify-between mb-8">
                <div>
                    <h1 className="text-3xl font-bold text-gray-900">Tasks</h1>
                    <p className="text-gray-600 mt-1">
                        Manage and track your tasks
                    </p>
                </div>
                <CreateTaskButton projects={projects} />
            </div>

            {/* Pass data to client component */}
            <TaskList 
                initialTasks={tasks as Task[]} 
                projects={projects}
            />
        </div>
    );
}
```

### Step 3: Create Task List Client Component

**File:** `src/components/tasks/TaskList.tsx`

```typescript
/**
 * Task List - Client Component
 * Handles interactivity while receiving server-fetched data
 */

'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import type { Task, Project } from '@prisma/client';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { updateTaskStatus, deleteTask } from '@/server/actions/taskActions';

interface TaskListProps {
    initialTasks: Task[];
    projects: Pick<Project, 'id' | 'name'>[];
}

export function TaskList({ initialTasks, projects }: TaskListProps) {
    const router = useRouter();
    const [tasks, setTasks] = useState(initialTasks);
    const [filterStatus, setFilterStatus] = useState<Task['status'] | 'all'>('all');
    const [searchTerm, setSearchTerm] = useState('');

    // Handle status update with optimistic UI
    const handleStatusChange = async (taskId: string, newStatus: Task['status']) => {
        // Optimistic update
        const previousTasks = tasks;
        setTasks(tasks.map(task =>
            task.id === taskId ? { ...task, status: newStatus } : task
        ));

        try {
            const result = await updateTaskStatus(taskId, newStatus);
            if (!result.success) {
                // Revert on error
                setTasks(previousTasks);
                console.error('Failed to update status:', result.error);
            } else {
                // Revalidate the page
                router.refresh();
            }
        } catch (error) {
            // Revert on error
            setTasks(previousTasks);
            console.error('Error updating status:', error);
        }
    };

    // Handle delete with optimistic UI
    const handleDelete = async (taskId: string) => {
        if (!window.confirm('Are you sure you want to delete this task?')) {
            return;
        }

        // Optimistic update
        const previousTasks = tasks;
        setTasks(tasks.filter(task => task.id !== taskId));

        try {
            const result = await deleteTask(taskId);
            if (!result.success) {
                // Revert on error
                setTasks(previousTasks);
                console.error('Failed to delete:', result.error);
            } else {
                router.refresh();
            }
        } catch (error) {
            // Revert on error
            setTasks(previousTasks);
            console.error('Error deleting:', error);
        }
    };

    // Filter tasks
    const filteredTasks = tasks.filter(task => {
        if (filterStatus !== 'all' && task.status !== filterStatus) {
            return false;
        }
        if (searchTerm && !task.title.toLowerCase().includes(searchTerm.toLowerCase())) {
            return false;
        }
        return true;
    });

    // Sort tasks
    const sortedTasks = [...filteredTasks].sort((a, b) => {
        const statusOrder = { todo: 0, in_progress: 1, review: 2, done: 3 };
        const priorityOrder = { urgent: 0, high: 1, medium: 2, low: 3 };
        
        const aStatus = statusOrder[a.status];
        const bStatus = statusOrder[b.status];
        if (aStatus !== bStatus) return aStatus - bStatus;
        
        return priorityOrder[a.priority] - priorityOrder[b.priority];
    });

    return (
        <div className="space-y-4">
            {/* Filters */}
            <div className="flex flex-wrap items-center gap-3 bg-white p-4 rounded-lg shadow-sm">
                <div className="flex items-center gap-2">
                    <label className="text-sm font-medium text-gray-700">Status:</label>
                    <select
                        className="px-3 py-1.5 border border-gray-300 rounded-lg text-sm"
                        value={filterStatus}
                        onChange={(e) => setFilterStatus(e.target.value as any)}
                    >
                        <option value="all">All</option>
                        <option value="todo">📝 To Do</option>
                        <option value="in_progress">🔄 In Progress</option>
                        <option value="review">🔍 Review</option>
                        <option value="done">✅ Done</option>
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

            {/* Task List */}
            <div className="space-y-2">
                {sortedTasks.length === 0 ? (
                    <Card>
                        <div className="text-center py-12 text-gray-500">
                            <p className="text-lg font-medium">No tasks found</p>
                            <p className="text-sm">Create your first task to get started!</p>
                        </div>
                    </Card>
                ) : (
                    sortedTasks.map(task => (
                        <TaskItem
                            key={task.id}
                            task={task}
                            onStatusChange={handleStatusChange}
                            onDelete={handleDelete}
                        />
                    ))
                )}
            </div>
        </div>
    );
}

// --- Subcomponent: TaskItem ---

interface TaskItemProps {
    task: Task;
    onStatusChange: (id: string, status: Task['status']) => void;
    onDelete: (id: string) => void;
}

function TaskItem({ task, onStatusChange, onDelete }: TaskItemProps) {
    const [isExpanded, setIsExpanded] = useState(false);

    const priorityColors = {
        low: 'bg-green-100 text-green-800',
        medium: 'bg-yellow-100 text-yellow-800',
        high: 'bg-red-100 text-red-800',
        urgent: 'bg-purple-100 text-purple-800'
    };

    const statusEmojis = {
        todo: '📝',
        in_progress: '🔄',
        review: '🔍',
        done: '✅'
    };

    const statusDisplay = {
        todo: 'To Do',
        in_progress: 'In Progress',
        review: 'Review',
        done: 'Done'
    };

    // Status cycle for quick update
    const statusCycle: Task['status'][] = ['todo', 'in_progress', 'review', 'done'];

    const handleStatusClick = () => {
        const currentIndex = statusCycle.indexOf(task.status);
        const nextIndex = (currentIndex + 1) % statusCycle.length;
        onStatusChange(task.id, statusCycle[nextIndex]);
    };

    return (
        <div className="bg-white border border-gray-200 rounded-lg hover:shadow-md transition-shadow">
            <div className="flex items-start gap-3 px-4 py-3">
                {/* Status button */}
                <button
                    onClick={handleStatusClick}
                    className="mt-1 text-2xl hover:scale-110 transition-transform"
                    title={`Status: ${statusDisplay[task.status]}`}
                >
                    {statusEmojis[task.status]}
                </button>

                {/* Task content */}
                <div
                    className="flex-1 cursor-pointer"
                    onClick={() => setIsExpanded(!isExpanded)}
                >
                    <h4 className={`font-medium ${
                        task.status === 'done' ? 'line-through text-gray-400' : 'text-gray-900'
                    }`}>
                        {task.title}
                    </h4>
                    <div className="flex flex-wrap items-center gap-2 text-sm mt-1">
                        <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${priorityColors[task.priority]}`}>
                            {task.priority}
                        </span>
                        {task.dueDate && (
                            <span className="text-gray-500">
                                Due: {new Date(task.dueDate).toLocaleDateString()}
                            </span>
                        )}
                        {task.assignee && (
                            <span className="text-gray-500">
                                👤 {typeof task.assignee === 'object' && 'name' in task.assignee 
                                    ? task.assignee.name 
                                    : 'Assigned'}
                            </span>
                        )}
                        {task.tags && task.tags.length > 0 && (
                            <span className="text-gray-400">
                                #{task.tags.join(', #')}
                            </span>
                        )}
                    </div>
                </div>

                {/* Actions */}
                <div className="flex items-center gap-2">
                    <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => {
                            // Navigate to edit page
                            window.location.href = `/tasks/${task.id}/edit`;
                        }}
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
                    <p className="text-gray-700 whitespace-pre-wrap">{task.description}</p>
                    {task.updatedAt && (
                        <p className="text-xs text-gray-400 mt-2">
                            Updated: {new Date(task.updatedAt).toLocaleString()}
                        </p>
                    )}
                </div>
            )}
        </div>
    );
}
```

## 5.6 Environment Variables with Type Safety

Let's create type-safe environment variables for our Next.js app.

**File:** `src/lib/env.ts`

```typescript
/**
 * Type-safe Environment Variables
 * Validates and provides type-safe access to env vars
 */

import { z } from 'zod';

// Define the schema for environment variables
const envSchema = z.object({
    // Next.js
    NODE_ENV: z.enum(['development', 'production', 'test']),
    NEXT_PUBLIC_API_URL: z.string().url().optional(),
    
    // Database
    DATABASE_URL: z.string().min(1),
    
    // Authentication
    JWT_SECRET: z.string().min(32),
    
    // Optional: Add more as needed
    NEXT_PUBLIC_APP_NAME: z.string().default('TaskFlow'),
});

// Parse and validate environment variables
const env = envSchema.safeParse(process.env);

if (!env.success) {
    console.error('❌ Invalid environment variables:', env.error.format());
    throw new Error('Invalid environment variables');
}

// Export type-safe env variables
export const env = env.data;

// Export types for use in other files
export type Env = z.infer<typeof envSchema>;
```

**File:** `src/lib/prisma.ts`

```typescript
/**
 * Prisma Client with type safety
 */

import { PrismaClient } from '@prisma/client';
import { env } from './env';

// Global variable for Prisma client (for development hot reloading)
declare global {
    var prisma: PrismaClient | undefined;
}

export const prisma = global.prisma || new PrismaClient({
    log: env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

if (env.NODE_ENV !== 'production') {
    global.prisma = prisma;
}
```

## 5.7 Verification

### Step 1: Set Up Database

```bash
cd taskflow-next

# Generate Prisma client
npx prisma generate

# Push schema to database
npm run db:push

# Seed the database
npm run db:seed
```

### Step 2: Start the Development Server

```bash
npm run dev
```

### Step 3: Test the Application

Open http://localhost:3000 and you should see:

1. **Tasks Page:** Shows all tasks from the database
2. **Task Creation:** Create new tasks (if you've implemented the form)
3. **Status Updates:** Click the status emoji to cycle through statuses
4. **Deletion:** Delete tasks with confirmation
5. **Search and Filter:** Filter by status and search by title

### API Testing

```bash
# GET all tasks
curl http://localhost:3000/api/tasks

# GET a specific task
curl http://localhost:3000/api/tasks/your-task-id

# POST create a task
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "status": "todo",
    "priority": "medium",
    "projectId": "your-project-id",
    "createdBy": "your-user-id"
  }'
```

## 5.8 Summary: Part 5

You've completed Part 5! Here's what you've learned:

### Next.js with TypeScript
- **App Router:** Server and client components with full type safety
- **Server Components:** Fetch data directly from the database on the server
- **Client Components:** Interactive components with type-safe props

### Server Actions
- **Type-Safe Mutations:** Server actions with Zod validation
- **Optimistic UI:** Immediate updates with rollback on error
- **Revalidation:** Automatic cache invalidation with `revalidatePath`

### API Routes
- **REST Endpoints:** Fully typed GET, POST, PUT, DELETE handlers
- **Request Validation:** Type-safe request body parsing with Zod
- **Response Types:** Consistent API response structure

### Database Layer
- **Prisma ORM:** Type-safe database access with generated types
- **Schema Validation:** Zod schemas that work on both client and server
- **Seed Data:** Type-safe database seeding

### Environment Variables
- **Type Safety:** Runtime validation with Zod
- **Type Inference:** Type-safe access to environment variables
- **Error Handling:** Clear errors for missing or invalid env vars

### What's Next: Preview of Part 6

In Part 6, we'll bring everything together with:
- **Testing:** Type-safe tests with Vitest
- **Error Handling:** Comprehensive error handling patterns
- **Architecture:** Clean architecture patterns for large applications
- **Debugging:** Techniques for debugging TypeScript applications
- **Production Readiness:** Performance, deployment, and monitoring

## Verification Checklist

Before moving to Part 6, ensure:

- [ ] `npx prisma generate` runs successfully
- [ ] `npm run db:push` creates the database
- [ ] `npm run db:seed` populates with test data
- [ ] `npm run dev` starts without errors
- [ ] Tasks page loads with seeded data
- [ ] API routes return correct responses
- [ ] Server actions work correctly
- [ ] Environment variables pass validation
