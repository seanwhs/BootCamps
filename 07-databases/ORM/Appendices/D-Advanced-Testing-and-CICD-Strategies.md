# Appendix D: Advanced Testing and CI/CD Strategies

### Purpose of This Appendix

Testing is the bedrock of reliable software. In the main series and earlier appendices, we touched on unit tests, integration tests with Testcontainers, and end‑to‑end tests. This appendix elevates those concepts to a professional level, covering:

- **Unit testing** – mocking ORM clients effectively.
- **Integration testing** – using Testcontainers with PostgreSQL, managing test databases, and seed data.
- **Testing transactions and rollbacks** – ensuring atomicity.
- **Testing with both ORMs** – running the same test suite against Prisma and Drizzle.
- **End‑to‑end testing** – full‑stack tests with Playwright and a real database.
- **Performance and load testing** – using k6 to simulate traffic.
- **CI/CD pipelines** – GitHub Actions with matrix strategies to test both ORMs in parallel.

By the end of this appendix, you'll have a robust testing strategy that works for both ORMs, ensuring your application is production‑ready.

---

## Appendix D, Section 1: Unit Testing – Mocking ORM Clients

Unit tests should be fast and isolated. We mock the ORM client to avoid hitting a real database.

### Prisma Unit Tests with Vitest

**Example: Testing a service that uses Prisma.**

```typescript
// packages/services/src/__tests__/project.service.unit.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { ProjectService } from '../project.service'
import { prisma } from '@taskflow/database/prisma/client'

// Mock the entire Prisma client
vi.mock('@taskflow/database/prisma/client', () => ({
  prisma: {
    project: {
      findMany: vi.fn(),
      create: vi.fn(),
      delete: vi.fn(),
    },
    // mock other models if needed
  },
}))

describe('ProjectService (Prisma)', () => {
  let service: ProjectService
  const mockOrgId = 'org-123'
  const mockUserId = 'user-456'

  beforeEach(() => {
    service = new ProjectService(mockUserId, mockOrgId)
    // Reset mocks before each test
    vi.clearAllMocks()
  })

  it('should return projects for the organization', async () => {
    const mockProjects = [
      { id: '1', name: 'Project A', organizationId: mockOrgId },
      { id: '2', name: 'Project B', organizationId: mockOrgId },
    ]
    ;(prisma.project.findMany as any).mockResolvedValue(mockProjects)

    const result = await service.getProjects()
    expect(result).toEqual(mockProjects)
    expect(prisma.project.findMany).toHaveBeenCalledWith({
      where: { organizationId: mockOrgId },
      include: { tasks: true },
    })
  })

  it('should create a project', async () => {
    const data = { name: 'New Project', description: 'Test' }
    const mockCreated = { id: '3', ...data, organizationId: mockOrgId, createdBy: mockUserId }
    ;(prisma.project.create as any).mockResolvedValue(mockCreated)

    const result = await service.createProject(data)
    expect(result).toEqual(mockCreated)
    expect(prisma.project.create).toHaveBeenCalledWith({
      data: { ...data, organizationId: mockOrgId, createdBy: mockUserId },
    })
  })
})
```

### Drizzle Unit Tests with Vitest

Mocking Drizzle is similar, but because Drizzle uses a functional API, we can mock the `db` object.

```typescript
// packages/services/src/__tests__/project.service.drizzle.unit.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { DrizzleProjectService } from '../project.service.drizzle'
import { db } from '@taskflow/database/drizzle/client'
import { projects } from '@taskflow/database/drizzle/schema'

vi.mock('@taskflow/database/drizzle/client', () => ({
  db: {
    query: {
      projects: {
        findMany: vi.fn(),
        findFirst: vi.fn(),
      },
    },
    insert: vi.fn().mockReturnValue({
      values: vi.fn().mockReturnValue({
        returning: vi.fn().mockResolvedValue([{ id: 'new-id' }]),
      }),
    }),
  },
}))

describe('DrizzleProjectService', () => {
  let service: DrizzleProjectService
  const mockOrgId = 'org-123'
  const mockUserId = 'user-456'

  beforeEach(() => {
    service = new DrizzleProjectService(mockOrgId)
    vi.clearAllMocks()
  })

  it('should return projects for the organization', async () => {
    const mockProjects = [
      { id: '1', name: 'Project A', organizationId: mockOrgId },
      { id: '2', name: 'Project B', organizationId: mockOrgId },
    ]
    ;(db.query.projects.findMany as any).mockResolvedValue(mockProjects)

    const result = await service.getProjects()
    expect(result).toEqual(mockProjects)
    expect(db.query.projects.findMany).toHaveBeenCalledWith({
      where: expect.anything(),
      with: { tasks: true },
    })
  })
})
```

### Best Practices

- Use `vi.mock` at the top level to mock the entire module.
- Use `vi.clearAllMocks()` between tests to prevent leakage.
- Test both success and error paths.
- Use `expect.anything()` when the exact argument is not important.

---

## Appendix D, Section 2: Integration Testing with Testcontainers

Integration tests use a real database in a container. We'll set up a test environment that runs migrations, seeds data, and executes queries.

### Setting Up Testcontainers for Prisma

**Install dependencies:**

```bash
pnpm add -D @testcontainers/postgresql vitest
```

**Test file:**

```typescript
// packages/database/src/__tests__/integration.prisma.test.ts
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { PostgreSqlContainer } from '@testcontainers/postgresql'
import { PrismaClient } from '@prisma/client'
import { exec } from 'child_process'
import { promisify } from 'util'

const execAsync = promisify(exec)

describe('Prisma Integration Tests', () => {
  let container: any
  let prisma: PrismaClient
  let databaseUrl: string

  beforeAll(async () => {
    // Start PostgreSQL container
    container = await new PostgreSqlContainer()
      .withDatabase('testdb')
      .withUsername('testuser')
      .withPassword('testpass')
      .start()

    databaseUrl = container.getConnectionUri()
    process.env.DATABASE_URL = databaseUrl

    // Run Prisma migrations
    await execAsync(
      `pnpm prisma migrate deploy --schema src/prisma/schema.prisma`,
      {
        env: { ...process.env, DATABASE_URL: databaseUrl },
        cwd: process.cwd(),
      }
    )

    // Create Prisma client
    prisma = new PrismaClient({ datasourceUrl: databaseUrl })
    await prisma.$connect()
  })

  afterAll(async () => {
    await prisma.$disconnect()
    await container.stop()
  })

  beforeEach(async () => {
    // Clean up data between tests
    await prisma.task.deleteMany()
    await prisma.project.deleteMany()
    await prisma.organizationMember.deleteMany()
    await prisma.user.deleteMany()
    await prisma.organization.deleteMany()
  })

  it('should create a user and an organization with membership', async () => {
    // Create organization
    const org = await prisma.organization.create({
      data: { name: 'Test Org', slug: 'test-org' },
    })

    // Create user
    const user = await prisma.user.create({
      data: {
        email: 'test@example.com',
        passwordHash: 'hashed',
        fullName: 'Test User',
      },
    })

    // Add membership
    const membership = await prisma.organizationMember.create({
      data: {
        organizationId: org.id,
        userId: user.id,
        role: 'owner',
      },
    })

    // Verify
    const foundUser = await prisma.user.findUnique({
      where: { id: user.id },
      include: { organizationMembers: true },
    })
    expect(foundUser).toBeDefined()
    expect(foundUser?.organizationMembers).toHaveLength(1)
    expect(foundUser?.organizationMembers[0].role).toBe('owner')
  })

  // Test transactions
  it('should rollback on error in transaction', async () => {
    await expect(
      prisma.$transaction(async (tx) => {
        await tx.organization.create({
          data: { name: 'Org', slug: 'org' },
        })
        // This will fail (slug duplicate) – transaction should rollback
        await tx.organization.create({
          data: { name: 'Org2', slug: 'org' },
        })
      })
    ).rejects.toThrow()

    const orgs = await prisma.organization.findMany()
    expect(orgs).toHaveLength(0)
  })
})
```

### Integration Testing for Drizzle

Similar setup, but using Drizzle's client.

```typescript
// packages/database/src/__tests__/integration.drizzle.test.ts
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { PostgreSqlContainer } from '@testcontainers/postgresql'
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { migrate } from 'drizzle-orm/node-postgres/migrator'
import { schema } from '../drizzle/schema'

describe('Drizzle Integration Tests', () => {
  let container: any
  let db: any
  let pool: Pool
  let databaseUrl: string

  beforeAll(async () => {
    container = await new PostgreSqlContainer()
      .withDatabase('testdb')
      .withUsername('testuser')
      .withPassword('testpass')
      .start()

    databaseUrl = container.getConnectionUri()
    pool = new Pool({ connectionString: databaseUrl })
    db = drizzle(pool, { schema })

    // Run Drizzle migrations
    await migrate(db, { migrationsFolder: './src/drizzle/migrations' })
  })

  afterAll(async () => {
    await pool.end()
    await container.stop()
  })

  beforeEach(async () => {
    // Clean up using raw SQL
    await db.execute(`TRUNCATE TABLE tasks, projects, organization_members, users, organizations CASCADE`)
  })

  it('should create a user and organization', async () => {
    const [org] = await db.insert(organizations).values({
      name: 'Test Org',
      slug: 'test-org',
    }).returning()
    const [user] = await db.insert(users).values({
      email: 'test@example.com',
      passwordHash: 'hashed',
      fullName: 'Test User',
    }).returning()
    await db.insert(organizationMembers).values({
      organizationId: org.id,
      userId: user.id,
      role: 'owner',
    })

    const foundUser = await db.query.users.findFirst({
      where: eq(users.id, user.id),
      with: { organizationMembers: true },
    })
    expect(foundUser).toBeDefined()
    expect(foundUser?.organizationMembers).toHaveLength(1)
  })
})
```

---

## Appendix D, Section 3: End‑to‑End Testing with Playwright

E2E tests simulate real user interactions in a browser, with a full Next.js application running against a test database.

**Setup:**

```bash
pnpm create playwright
```

**Playwright configuration (`playwright.config.ts`):**

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
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
  ],
  webServer: {
    command: 'pnpm dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    env: {
      DATABASE_URL: process.env.TEST_DATABASE_URL, // use test DB
    },
  },
})
```

**E2E test example (`e2e/projects.spec.ts`):**

```typescript
import { test, expect } from '@playwright/test'
import { PrismaClient } from '@prisma/client'

test.describe('Projects', () => {
  let prisma: PrismaClient

  test.beforeAll(async () => {
    prisma = new PrismaClient({
      datasourceUrl: process.env.TEST_DATABASE_URL,
    })
    await prisma.$connect()
  })

  test.beforeEach(async () => {
    // Clean database before each test
    await prisma.task.deleteMany()
    await prisma.project.deleteMany()
    await prisma.organizationMember.deleteMany()
    await prisma.user.deleteMany()
    await prisma.organization.deleteMany()

    // Seed a test user and organization
    const org = await prisma.organization.create({
      data: { name: 'E2E Org', slug: 'e2e-org' },
    })
    const user = await prisma.user.create({
      data: {
        email: 'e2e@example.com',
        passwordHash: 'hashed', // we'll use a fixed password for login
        fullName: 'E2E User',
      },
    })
    await prisma.organizationMember.create({
      data: { organizationId: org.id, userId: user.id, role: 'owner' },
    })
    // We'll need a way to log in; we'll use NextAuth's API directly or use a test user.
  })

  test.afterAll(async () => {
    await prisma.$disconnect()
  })

  test('should create a new project', async ({ page }) => {
    // Log in (we'll use a helper)
    await page.goto('/login')
    await page.fill('input[name="email"]', 'e2e@example.com')
    await page.fill('input[name="password"]', 'password123')
    await page.click('button[type="submit"]')
    await page.waitForURL('/dashboard')

    // Navigate to projects
    await page.click('text=Projects')
    await page.waitForURL('/projects')

    // Click "New Project"
    await page.click('text=New Project')
    await page.fill('input[name="name"]', 'Playwright Project')
    await page.fill('textarea[name="description"]', 'Created during E2E test')
    await page.click('button[type="submit"]')

    // Verify project appears
    await expect(page.locator('text=Playwright Project')).toBeVisible()
  })
})
```

**Login helper:**

We can create a utility that logs in via the API to avoid UI login for every test.

```typescript
// e2e/helpers/auth.ts
import { Page } from '@playwright/test'

export async function login(page: Page, email: string, password: string) {
  await page.goto('/api/auth/signin')
  await page.fill('input[name="email"]', email)
  await page.fill('input[name="password"]', password)
  await page.click('button[type="submit"]')
  await page.waitForURL('/dashboard')
}
```

---

## Appendix D, Section 4: Performance and Load Testing with k6

We can use k6 to simulate concurrent users and measure API performance.

**Install k6** (standalone binary) or use Docker.

**Test script (`load-test.js`):**

```javascript
import http from 'k6/http'
import { check, sleep } from 'k6'

export const options = {
  stages: [
    { duration: '30s', target: 20 }, // ramp up
    { duration: '1m', target: 20 },  // stay at 20
    { duration: '30s', target: 0 },  // ramp down
  ],
}

const BASE_URL = 'http://localhost:3000'

export default function () {
  // Login
  const loginRes = http.post(`${BASE_URL}/api/auth/callback/credentials`, {
    email: 'test@example.com',
    password: 'password123',
  })
  check(loginRes, { 'login success': (r) => r.status === 200 })
  const cookies = loginRes.headers['Set-Cookie']
  const headers = { Cookie: cookies }

  // Get projects
  const projectsRes = http.get(`${BASE_URL}/api/projects`, { headers })
  check(projectsRes, { 'projects status 200': (r) => r.status === 200 })

  sleep(1)
}
```

Run with:

```bash
k6 run load-test.js
```

Integrate with CI by running k6 in a container.

---

## Appendix D, Section 5: CI/CD Pipeline with GitHub Actions

We'll set up a comprehensive GitHub Actions workflow that tests both ORMs in parallel.

**File:** `.github/workflows/test.yml`

```yaml
name: Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-prisma:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: testuser
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - name: Generate Prisma Client
        run: pnpm prisma:generate
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
      - name: Run Prisma Migrations
        run: pnpm prisma:migrate deploy
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
      - name: Run Unit Tests (Prisma)
        run: pnpm test:unit -- --project prisma
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
      - name: Run Integration Tests (Prisma)
        run: pnpm test:integration -- --project prisma
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
      - name: Run E2E Tests (Prisma)
        run: pnpm test:e2e
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb

  test-drizzle:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: testuser
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - name: Generate Drizzle Migrations
        run: pnpm drizzle:generate
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
      - name: Run Drizzle Migrations
        run: pnpm drizzle:migrate
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
      - name: Run Unit Tests (Drizzle)
        run: pnpm test:unit -- --project drizzle
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
      - name: Run Integration Tests (Drizzle)
        run: pnpm test:integration -- --project drizzle
        env:
          DATABASE_URL: postgresql://testuser:testpass@localhost:5432/testdb
```

**Note:** You may need to configure your test script to accept a `--project` flag to run specific tests. Alternatively, you can run all tests and rely on environment variables to switch ORM (e.g., `USE_DRIZZLE=true`).

---

## Appendix D, Section 6: Test Data Management – Factories and Seeders

Creating test data manually is tedious. Use factories to generate data.

**Using `@faker-js/faker`:**

```typescript
// packages/database/src/test/factories.ts
import { faker } from '@faker-js/faker'
import { prisma } from '../prisma/client'

export async function createUser(overrides = {}) {
  return prisma.user.create({
    data: {
      email: faker.internet.email(),
      fullName: faker.person.fullName(),
      passwordHash: 'hashed',
      ...overrides,
    },
  })
}

export async function createOrganization(overrides = {}) {
  return prisma.organization.create({
    data: {
      name: faker.company.name(),
      slug: faker.helpers.slugify(faker.company.name()).toLowerCase(),
      ...overrides,
    },
  })
}

export async function createProject(orgId: string, overrides = {}) {
  return prisma.project.create({
    data: {
      name: faker.commerce.productName(),
      organizationId: orgId,
      createdBy: (await createUser()).id,
      ...overrides,
    },
  })
}
```

Use these in your tests to quickly set up data.

---

## Conclusion of Appendix D

You now have a comprehensive testing and CI/CD strategy that works for both Prisma and Drizzle. You can run fast unit tests, reliable integration tests with real databases, and end‑to‑end tests that simulate user behavior. Your GitHub Actions pipeline runs these tests automatically on every push, ensuring your application remains stable.
