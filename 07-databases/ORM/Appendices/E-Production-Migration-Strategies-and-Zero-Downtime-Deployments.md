# Appendix E: Production Migration Strategies and Zero-Downtime Deployments

### Purpose of This Appendix

Migrations are a critical part of evolving your database schema, but applying them in production without downtime requires careful planning and execution. In the main series and Part 2, we covered the basics of migrations with Prisma and Drizzle. This appendix dives deep into **zero‑downtime migration strategies**—how to add, modify, and remove columns and tables while your application continues serving traffic.

**What you'll find here:**
- The core principles of zero‑downtime migrations.
- Step‑by‑step guides for common migration scenarios (add column, rename column, change type, add constraint, etc.).
- Detailed implementation for both Prisma and Drizzle.
- Strategies for backfilling data safely.
- Handling rollbacks.
- Automation and CI/CD integration.
- Checklist for production migrations.

---

## Appendix E, Section 1: Core Principles of Zero‑Downtime Migrations

The golden rule: **old code must work with the new schema, and new code must work with the old schema** (at least during the transition). This is achieved by following a phased approach.

### The Four Phases

1. **Expand** – Add new columns, tables, indexes (without breaking existing code).
2. **Migrate Data** – Backfill new columns or tables in the background.
3. **Switch** – Deploy code that uses the new structure; optionally stop writing to the old structure.
4. **Cleanup** – Remove old columns, tables, or constraints.

For each phase, we must ensure the application remains functional and performant.

### Safety Rules

- **Never drop a column or table before step 4.**
- **Never make a column `NOT NULL` without first backfilling.**
- **Never add a foreign key without `NOT VALID` first, then validate.**
- **Always have a rollback plan.**
- **Test migrations on a staging environment with production‑like data.**

---

## Appendix E, Section 2: Common Migration Scenarios

We'll walk through the most frequent schema changes and how to execute them safely.

### Scenario 1: Adding a New Column

**Goal:** Add a `priority_rank` integer column to the `tasks` table.

#### Phase 1: Expand

**Prisma:**

```prisma
model Task {
  // ...
  priorityRank Int? @map("priority_rank") @db.Integer
}
```

Then generate a migration. Prisma will add the column as nullable (because `?` indicates optional). No code changes needed yet.

**Drizzle:**

```typescript
export const tasks = pgTable('tasks', {
  // ...
  priorityRank: integer('priority_rank'),
})
```

Generate migration with `drizzle-kit generate:pg`; it will add the column nullable.

#### Phase 2: Migrate Data

Backfill the new column with a default value based on existing data.

**Prisma script (`scripts/backfill-priority-rank.ts`):**

```typescript
import { prisma } from '../packages/database/src/prisma/client'

async function backfill() {
  // We'll batch update to avoid locking long
  const batchSize = 1000
  let processed = 0
  let hasMore = true

  while (hasMore) {
    const tasks = await prisma.task.findMany({
      where: { priorityRank: null },
      take: batchSize,
    })
    if (tasks.length === 0) {
      hasMore = false
      break
    }

    await prisma.$transaction(
      tasks.map(task => {
        let rank = 4 // low
        if (task.priority === 'urgent') rank = 1
        else if (task.priority === 'high') rank = 2
        else if (task.priority === 'medium') rank = 3
        return prisma.task.update({
          where: { id: task.id },
          data: { priorityRank: rank },
        })
      })
    )
    processed += tasks.length
    console.log(`Backfilled ${processed} tasks`)
  }
}

backfill()
```

**Drizzle backfill script (`scripts/backfill-drizzle.ts`):**

```typescript
import { db } from '../packages/database/src/drizzle/client'
import { tasks } from '../packages/database/src/drizzle/schema'
import { eq, isNull, sql } from 'drizzle-orm'

async function backfill() {
  const batchSize = 1000
  let processed = 0

  while (true) {
    const batch = await db
      .select()
      .from(tasks)
      .where(isNull(tasks.priorityRank))
      .limit(batchSize)

    if (batch.length === 0) break

    // Update each task individually, or use a case statement for bulk
    const updates = batch.map(task => {
      const rank = task.priority === 'urgent' ? 1
        : task.priority === 'high' ? 2
        : task.priority === 'medium' ? 3
        : 4
      return db.update(tasks)
        .set({ priorityRank: rank })
        .where(eq(tasks.id, task.id))
    })

    await db.transaction(async (tx) => {
      for (const update of updates) {
        await update
      }
    })

    processed += batch.length
    console.log(`Backfilled ${processed} tasks`)
  }
}

backfill()
```

#### Phase 3: Switch

Deploy code that uses the new column (e.g., sorting by `priorityRank`). The column is now populated, so queries can rely on it.

#### Phase 4: Cleanup

If the old `priority` column is no longer needed (unlikely, but possible), you could drop it in a later migration. But it's safer to keep it until you're sure.

---

### Scenario 2: Renaming a Column

Renaming a column is tricky because old code may still reference the old name.

**Strategy:**
1. Add a new column with the new name (expand).
2. Backfill the new column with values from the old column (migrate data).
3. Deploy code that writes to both columns (or uses the new one).
4. After all code uses the new column, drop the old column (cleanup).

**Prisma:** You can use `@map` to rename the underlying column while keeping the model field name. For a true rename, you'd do the above.

**Drizzle:** Similarly, you can rename the column in the schema and generate a migration, but that would be a breaking change. Use the expand‑backfill‑switch‑cleanup pattern.

**Example: Rename `full_name` to `display_name` in `users`.**

- Add `display_name` column (nullable).
- Backfill: `UPDATE users SET display_name = full_name;`
- Deploy code that reads `display_name` (and maybe still writes to both).
- After all code is updated, remove `full_name`.

---

### Scenario 3: Changing Column Type (e.g., from `TEXT` to `VARCHAR(255)`)

Changing a column type can lock the table. Use a two‑step approach:

1. Add a new column with the new type.
2. Backfill data (converting as needed).
3. Drop the old column.
4. Rename the new column to the original name.

Alternatively, use PostgreSQL's `ALTER TABLE ALTER COLUMN ... TYPE ... USING ...` in a transaction, but it may lock the table. For large tables, it's safer to use the add‑backfill‑drop pattern.

---

### Scenario 4: Adding a `NOT NULL` Constraint

**Wrong:** `ALTER TABLE tasks ALTER COLUMN priority_rank SET NOT NULL;` – this will fail if any null exists.

**Correct:**
1. Ensure all rows have a non‑null value (backfill).
2. Then add the constraint:
   - In Prisma, change the field from `Int?` to `Int` (remove `?`) and generate a migration. Prisma will add a `NOT NULL` constraint after ensuring no nulls (you should verify first).
   - In Drizzle, change `.nullable()` to `.notNull()` and run a migration.

Always run this as a separate migration after backfilling.

---

### Scenario 5: Adding an Index

Adding an index is safe, but can lock the table if done without `CONCURRENTLY`.

**Prisma:** In the schema, add `@@index([column])`; Prisma generates a migration that creates the index. You can manually edit the migration to add `CONCURRENTLY`.

Example migration SQL:

```sql
CREATE INDEX CONCURRENTLY "tasks_priority_rank_idx" ON "tasks" ("priority_rank");
```

**Drizzle:** In the table definition, add an index with `.using('btree')` or specify `concurrently` via the SQL builder:

```typescript
export const tasks = pgTable('tasks', {
  // ...
}, (table) => ({
  idx: index('tasks_priority_rank_idx').on(table.priorityRank),
}));
```

You can edit the generated SQL to add `CONCURRENTLY`.

---

### Scenario 6: Adding a Foreign Key Constraint

Adding a foreign key can lock the table. Use `NOT VALID` to avoid locking:

```sql
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "projects"("id") NOT VALID;
ALTER TABLE "tasks" VALIDATE CONSTRAINT "tasks_project_id_fkey";
```

The validation step will scan the table but won't lock it for writes.

**Prisma:** You can add the foreign key via schema, but Prisma's migration will generate a standard `ADD CONSTRAINT ... REFERENCES ...`. Edit the migration to include `NOT VALID` and add a subsequent `VALIDATE` statement.

**Drizzle:** The `references` method generates a foreign key constraint. Edit the migration SQL similarly.

---

## Appendix E, Section 3: Prisma‑Specific Migration Features

Prisma provides some built‑in tools to help with zero‑downtime migrations.

### 3.1 `--create-only` Flag

Generate a migration without applying it, so you can edit the SQL.

```bash
prisma migrate dev --create-only --name add_priority_rank
```

Edit the generated SQL in the `migrations` folder, then apply it with `prisma migrate deploy`.

### 3.2 Shadow Database

Prisma uses a shadow database to detect drift. In zero‑downtime scenarios, ensure the shadow database is in sync.

### 3.3 Using `prisma migrate resolve`

If a migration failed or you applied it manually, you can mark it as applied:

```bash
prisma migrate resolve --applied "20250101000000_add_priority_rank"
```

This helps keep Prisma's migration history consistent.

---

## Appendix E, Section 4: Drizzle‑Specific Migration Features

Drizzle gives you full control over SQL.

### 4.1 Customizing Migration Files

After `drizzle-kit generate:pg`, you'll find SQL files in the `migrations` folder. Edit them freely.

### 4.2 Snapshot Management

Drizzle stores a `snapshot.json` file that tracks the schema state. If you manually modify the database, you may need to update the snapshot or regenerate migrations. Use `drizzle-kit push` with caution, but for production, always use generated migrations.

### 4.3 Using `drizzle-orm` Migrator

The `migrate` function applies migrations in order. You can wrap it in a transaction if needed.

---

## Appendix E, Section 5: Rollback Strategies

Even with careful planning, things can go wrong. Always have a rollback plan.

### 5.1 Database Rollback

- **For Prisma:** Use `prisma migrate diff` to generate a rollback migration, or manually revert changes by applying a previous migration's SQL in reverse. You can also use `prisma migrate reset` (dev only).

- **For Drizzle:** Since Drizzle migrations are plain SQL, you can write a corresponding `down` migration or simply revert the SQL statements manually (e.g., drop a column, rename back, etc.). Keep a `down` file alongside each migration.

### 5.2 Application Rollback

If you need to roll back code, ensure it still works with the new schema. This is why the **expand** phase is critical: old code must work with the new schema. If you deploy code that depends on a new column, and you need to roll back, the old code won't break because the column exists (and is nullable).

Always:
- Keep the old code compatible until the cleanup phase is complete.
- Use feature flags to toggle new functionality.

---

## Appendix E, Section 6: Automating Zero‑Downtime Migrations in CI/CD

### 6.1 Prisma in CI/CD

- Run `prisma migrate deploy` as part of your deployment pipeline.
- For zero‑downtime, you may want to split migration and code deployment: first run migrations, then deploy code. This works if the migrations are backward‑compatible.

**Example GitHub Actions step:**

```yaml
- name: Run Prisma migrations
  run: pnpm prisma migrate deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

### 6.2 Drizzle in CI/CD

```yaml
- name: Apply Drizzle migrations
  run: pnpm drizzle:migrate
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

### 6.3 Blue‑Green Deployments

In a blue‑green setup, you have two environments. You apply migrations to the green environment, deploy the new code, then switch traffic. This gives you a safe rollback by switching back to blue.

### 6.4 Canary Deployments

Gradually roll out changes to a subset of users. This reduces the blast radius if a migration has an issue.

---

## Appendix E, Section 7: Case Study – Zero‑Downtime Migration in TaskFlow Pro

Let's walk through a real migration we might perform on TaskFlow Pro: adding a `project_priority` column to `projects` and using it to rank projects.

### Step 1: Add Column (Expand)

**Prisma:** Add `priorityRank Int?` to `Project` model, generate migration, apply.

**Drizzle:** Add `priorityRank: integer('priority_rank')` to `projects` table, generate migration, apply.

### Step 2: Backfill Data

Write a script to compute a priority rank based on task completion rate and number of tasks. Run it in the background.

### Step 3: Deploy Code Using New Column

Update the API and UI to sort projects by `priorityRank`.

### Step 4: (Optional) Cleanup

If we no longer need the old ranking logic, we can remove it from code.

### Rollback Plan

If the new sorting causes issues, we can revert the code change without rolling back the migration (the column still exists). The old code will ignore it.

---

## Appendix E, Section 8: Checklist for Production Migrations

Use this checklist before any production migration:

- [ ] **Backup the database** – take a snapshot or pg_dump.
- [ ] **Test in staging** – use a copy of production data.
- [ ] **Plan rollback** – know how to revert both schema and code.
- [ ] **Notify team** – schedule maintenance window if needed (but with zero‑downtime, it may be unnecessary).
- [ ] **Monitor performance** – watch for slow queries or locks.
- [ ] **Verify data integrity** – after migration, run checks.
- [ ] **Update documentation** – reflect changes in your data model.

---

## Appendix E, Section 9: Conclusion

Zero‑downtime migrations are achievable with Prisma and Drizzle, but they require discipline and a phased approach. By following the expand‑backfill‑switch‑cleanup pattern, you can evolve your schema safely without interrupting service. Both ORMs provide the tools to generate and customize migrations, giving you control over the SQL execution.
