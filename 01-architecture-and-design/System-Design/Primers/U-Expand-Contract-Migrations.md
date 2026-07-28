# Primer U: Expand/Contract Migrations

Changing the structure of data or APIs in a running system is one of the most common sources of production incidents. The **expand/contract** pattern (also called parallel change or expand-and-contract) is the standard safe way to make these changes without downtime or broken clients. This primer explains the pattern and how to apply it.

### 1. The Core Problem

If you change a database schema, message format, or API in one step while old code is still running, you get one of these failures:

- Old code cannot read the new schema or format.
- New code cannot read the old data that still exists.
- Clients expecting the old API response suddenly break.

A single “big bang” migration requires perfect coordination and usually causes downtime or errors.

### 2. The Expand/Contract Idea

Instead of changing everything at once, you make changes in **phases** that keep both old and new versions working at the same time.

**Mental model**  
You need to replace a bridge. You first build the new bridge *beside* the old one (expand), move traffic to the new bridge, and only then demolish the old bridge (contract). At no point is there no bridge.

### 3. The Classic Database Column Rename Example

Suppose you want to rename `username` to `display_name`.

**Phase 1 – Expand**  
Add the new column. Do not remove the old one yet.

```text
ALTER TABLE users ADD COLUMN display_name TEXT;
```

**Phase 2 – Dual write**  
Deploy code that writes to **both** columns.

```text
user.username = value
user.display_name = value
```

**Phase 3 – Backfill**  
Copy existing data from the old column to the new column (in batches).

**Phase 4 – Dual read / switch reads**  
Deploy code that reads from the new column (with optional fallback to the old column during transition).

**Phase 5 – Contract**  
Once you are confident nothing still depends on the old column, remove it.

```text
ALTER TABLE users DROP COLUMN username;
```

At every step the system remains compatible with both old and new code.

### 4. The Same Pattern Applies More Broadly

| Kind of change | Expand step | Contract step |
|----------------|-------------|---------------|
| Column rename or type change | Add new column / dual write | Remove old column |
| New required field | Add as optional, backfill, then enforce | — |
| API field rename | Emit both old and new fields | Stop emitting the old field |
| Event / message schema change | Publish both versions or a superset | Stop producing the old version |
| Moving data to a new store | Write to both stores | Stop writing to the old store and decommission it |
| Splitting a service | New service takes partial traffic / dual write | Old service stops handling that responsibility |

The principle is identical: **make the change additive first, migrate readers and writers, then remove the old form**.

### 5. Why Dual Writes Are Important

During the transition window you usually have:

- Old instances still running
- New instances already running
- In-flight requests and background jobs

If only the new code writes to the new location, any work performed by old code is invisible to the new path (and vice versa). Dual writing (or an equivalent dual-publish) keeps both representations up to date until the transition is complete.

### 6. Practical Tips

- **Keep the transition window as short as is safely possible**, but never rush the contract step.
- **Monitor both old and new paths** while they coexist.
- **Backfills should be throttled** so they do not overwhelm the database.
- **Feature flags** pair very well with expand/contract — you can control which code path is active without further deployments.
- **Idempotent backfills** are much safer; they can be restarted if interrupted.
- Document the phases and the exact criteria for moving to the next phase.

### 7. What Happens If You Skip the Pattern

Common failure modes:

- Deploy new code that reads a column that does not exist yet → widespread 500s.
- Remove a column that old code still writes to or reads from → data loss or crashes.
- Change an event schema without dual publishing → downstream consumers break.
- Migrate a service in one cutover without dual running → hard, long outage if anything goes wrong.

Almost all of these are avoided by expand/contract discipline.

### 8. Relationship to Other Practices

- **Deployment strategies** (rolling, canary, blue-green) decide how new *code* is introduced. Expand/contract decides how *data and contracts* stay compatible while that happens.
- **Feature flags** can control which read or write path is active during the transition.
- **Observability** is required so you know when the old path is truly unused and safe to remove.
- **Idempotency** makes backfills and dual writes safer.

### 9. What You Should Be Able to Do After This Primer

- Explain the expand/contract pattern with the bridge analogy.
- Walk through the phases of a safe column rename.
- Apply the same thinking to an API field change or an event schema change.
- Argue why dual writes (or dual publishing) are usually required during the transition.
- Recognize a “big bang” migration plan and propose a safer phased alternative.
- List the main risks of removing the old form too early.

This primer supports the production-engineering and safe-evolution topics in Part 6 and is essential for any design that will live long enough to need schema or API changes.

**[END OF PRIMER U]**
