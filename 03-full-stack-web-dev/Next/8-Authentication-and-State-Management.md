# Part 8: Authentication and State Management

LaunchPad currently validates input, but it does not identify callers or restrict records by ownership.

Anyone who can reach the application can currently create, update, and delete projects. That is not safe for a public deployment.

In this part, we will add credentials-based authentication with server-managed database sessions.

By the end of Part 8, LaunchPad will include:

- User accounts
- Password hashing
- Registration and sign-in forms
- Cryptographically random session tokens
- Hashed session-token storage
- Secure, HTTP-only cookies
- Protected workspace routes
- Authenticated JSON APIs
- User-owned projects
- Owner-scoped database queries
- Owner-scoped mutations
- Sign-out controls
- Server, URL, and local state boundaries
- Cross-user authorization verification
- Production-mode authentication checks

> Authentication code is security-sensitive. Follow the implementation exactly, keep dependencies updated, and use HTTPS in production.

---

# Step 1: Design the Authentication Architecture

## The Target

Understand how credentials, sessions, cookies, ownership, authentication, and authorization will work before changing the database.

## The Concept

Authentication answers:

> Who is making this request?

Authorization answers:

> Is that user allowed to perform this operation?

LaunchPad will use a server-managed session flow:

```text
User submits email and password
            ↓
Server finds the account
            ↓
Server verifies the password hash
            ↓
Server creates a random session token
            ↓
Database stores only the token hash
            ↓
Browser receives the original token in an HTTP-only cookie
            ↓
Future requests send the cookie automatically
            ↓
Server hashes the cookie value and finds the session
            ↓
Server loads the authenticated user
```

An **HTTP-only cookie** cannot be read through ordinary browser JavaScript. That reduces exposure if application JavaScript is compromised.

The database will store a hash of the session token rather than the original token. If the session table is leaked, the stored value cannot be copied directly into a browser cookie.

Project access will be scoped by owner in SQL:

```sql
WHERE project_id = $project_id
  AND owner_id = $authenticated_user_id
```

Hiding another user’s project in the interface is not sufficient. Every read and mutation must enforce ownership on the server.

## The Implementation

No files change in this planning step.

The authentication boundary will become:

```text
Browser cookie
      ↓
src/lib/auth/session.ts
      ↓
Authenticated user
      ↓
Workspace layout, Server Actions, and Route Handlers
      ↓
Owner-scoped query or mutation
      ↓
PostgreSQL
```

State will be divided into three categories:

| State | Owner | Examples |
|---|---|---|
| Server state | PostgreSQL and server session | User, projects, tasks |
| URL state | Browser URL | Project status filter |
| Local client state | One Client Component | Search text, disclosure state |

## The Verification

Confirm the Part 7 application still builds before changing its security model:

```bash
npm run db:start
npm run typecheck
npm run lint
npm run build
```

[GENERATED: Part 8, Step 1: Authentication Architecture] [STARTING: Part 8, Step 2: User and Session Migration]

---

# Step 2: Add Users, Sessions, and Project Ownership

## The Target

Create a database migration that adds user accounts, authentication sessions, and required project ownership.

## The Concept

Authentication requires persistent records.

The new relationships will be:

```text
User
├── owns many Projects
└── owns many Sessions

Project
└── belongs to one User

Session
└── belongs to one User
```

Deleting a user will remove that user’s sessions and projects. Deleting a project will continue removing its tasks.

We will also create one development account and assign the existing seeded projects to it.

## The Implementation

Create the migration.

### `database/migrations/002_add_users_sessions_and_ownership.sql`

```sql
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  email VARCHAR(320) NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT users_name_not_blank
    CHECK (length(trim(name)) > 0),

  CONSTRAINT users_email_not_blank
    CHECK (length(trim(email)) > 0),

  CONSTRAINT users_email_normalized
    CHECK (email = lower(trim(email)))
);

CREATE UNIQUE INDEX users_email_unique_index
  ON users(lower(email));

CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT sessions_user_foreign_key
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);

CREATE UNIQUE INDEX sessions_token_hash_unique_index
  ON sessions(token_hash);

CREATE INDEX sessions_user_id_index
  ON sessions(user_id);

CREATE INDEX sessions_expires_at_index
  ON sessions(expires_at);

INSERT INTO users (
  id,
  name,
  email,
  password_hash
)
VALUES (
  '30000000-0000-4000-8000-000000000001',
  'Demo User',
  'demo@launchpad.local',
  crypt(
    'LaunchPadDemo123!',
    gen_salt('bf', 12)
  )
);

ALTER TABLE projects
  ADD COLUMN owner_id UUID;

UPDATE projects
SET owner_id = '30000000-0000-4000-8000-000000000001';

ALTER TABLE projects
  ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE projects
  ADD CONSTRAINT projects_owner_foreign_key
    FOREIGN KEY (owner_id)
    REFERENCES users(id)
    ON DELETE CASCADE;

CREATE INDEX projects_owner_id_index
  ON projects(owner_id);

CREATE INDEX projects_owner_status_index
  ON projects(owner_id, status);

COMMIT;
```

Apply the migration:

```bash
docker compose exec -T db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --set=ON_ERROR_STOP=1 \
  < database/migrations/002_add_users_sessions_and_ownership.sql
```

PowerShell:

```powershell
Get-Content `
  -Raw `
  database/migrations/002_add_users_sessions_and_ownership.sql |
  docker compose exec -T db `
    psql `
    --username=launchpad `
    --dbname=launchpad `
    --set=ON_ERROR_STOP=1
```

### Update the migration script

Replace the existing database migration script in `package.json` with:

```json
"db:migrate": "docker compose exec -T db psql --username=launchpad --dbname=launchpad --set=ON_ERROR_STOP=1 < database/migrations/001_create_projects_and_tasks.sql && docker compose exec -T db psql --username=launchpad --dbname=launchpad --set=ON_ERROR_STOP=1 < database/migrations/002_add_users_sessions_and_ownership.sql"
```

This script remains intended for a new database. It does not yet track applied migrations.

### Update the development seed

In `database/seeds/development.sql`, add `owner_id` to the project insert columns:

```sql
INSERT INTO projects (
  id,
  owner_id,
  name,
  description,
  status,
  created_at,
  updated_at
)
```

Then add this owner UUID as the second value in every project tuple:

```sql
'30000000-0000-4000-8000-000000000001',
```

For example, the first tuple must begin:

```sql
(
  '10000000-0000-4000-8000-000000000001',
  '30000000-0000-4000-8000-000000000001',
  'Website redesign',
  'Refresh the marketing website with clearer messaging, faster pages, and an accessible component system.',
  'ACTIVE',
  CURRENT_TIMESTAMP - INTERVAL '30 days',
  CURRENT_TIMESTAMP - INTERVAL '2 days'
),
```

Apply the updated seed:

```bash
npm run db:seed
```

## The Verification

Inspect the user:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT id, name, email
    FROM users;
  "
```

Expected output contains:

```text
Demo User | demo@launchpad.local
```

Verify every project has an owner:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      p.name,
      u.email AS owner_email
    FROM projects AS p
    INNER JOIN users AS u
      ON u.id = p.owner_id
    ORDER BY p.name;
  "
```

All four projects should belong to:

```text
demo@launchpad.local
```

Inspect the tables:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="\d users"

docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="\d sessions"

docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="\d projects"
```

[GENERATED: Part 8, Step 2: User and Session Migration] [STARTING: Part 8, Step 3: Authentication Types and Validation]

---

# Step 3: Add Authentication Types and Validation

## The Target

Define safe public-user types and runtime schemas for registration and sign-in.

## The Concept

A user record contains both public and private information.

Safe application data:

```text
id
name
email
```

Private authentication data:

```text
passwordHash
sessionTokenHash
```

The private fields must never be passed to Client Components or returned by APIs.

We will define a `User` type that intentionally excludes password data.

## The Implementation

Install the password-hashing package:

```bash
npm install bcryptjs
```

Create authentication types.

### `src/lib/auth-types.ts`

```ts
export type User = {
  id: string;
  name: string;
  email: string;
};

export type SessionUser = User & {
  sessionExpiresAt: string;
};
```

Create authentication input schemas.

### `src/lib/auth-inputs.ts`

```ts
import { z } from "zod";

const emailSchema = z
  .string()
  .trim()
  .toLowerCase()
  .email("Enter a valid email address.")
  .max(320, "Email addresses must contain at most 320 characters.");

const passwordSchema = z
  .string()
  .min(12, "Passwords must contain at least 12 characters.")
  .max(128, "Passwords must contain at most 128 characters.")
  .regex(
    /[a-z]/,
    "Passwords must contain a lowercase letter.",
  )
  .regex(
    /[A-Z]/,
    "Passwords must contain an uppercase letter.",
  )
  .regex(
    /\d/,
    "Passwords must contain a number.",
  )
  .regex(
    /[^A-Za-z0-9]/,
    "Passwords must contain a symbol.",
  );

export const signInInputSchema = z.object({
  email: emailSchema,
  password: z
    .string()
    .min(1, "Enter your password.")
    .max(128, "Passwords must contain at most 128 characters."),
});

export const signUpInputSchema = z
  .object({
    name: z
      .string()
      .trim()
      .min(1, "Enter your name.")
      .max(100, "Names must contain at most 100 characters."),
    email: emailSchema,
    password: passwordSchema,
    confirmPassword: z.string(),
  })
  .refine(
    (input) => input.password === input.confirmPassword,
    {
      path: ["confirmPassword"],
      message: "The passwords do not match.",
    },
  );

export type SignInInput = z.infer<
  typeof signInInputSchema
>;

export type SignUpInput = z.infer<
  typeof signUpInputSchema
>;
```

## The Verification

Run:

```bash
npm ls bcryptjs
npm run typecheck
npm run lint
```

Confirm that the safe user type has no password property:

```bash
cat src/lib/auth-types.ts
```

[GENERATED: Part 8, Step 3: Authentication Types] [STARTING: Part 8, Step 4: User and Session Database Layer]

---

# Step 4: Build the User and Session Database Layer

## The Target

Create protected database functions for account lookup, registration, session creation, session lookup, and session deletion.

## The Concept

The raw session token exists only in the browser cookie and briefly in server memory.

PostgreSQL stores:

```text
SHA-256(raw token)
```

SHA-256 is a one-way hashing function. The same input produces the same hash, but the original input cannot practically be recovered from the hash.

Passwords use bcrypt rather than plain SHA-256 because bcrypt is intentionally expensive and salted. Password hashing and session-token hashing solve different problems.

## The Implementation

Create the authentication directory:

```bash
mkdir -p src/lib/auth
```

Create the account database module.

### `src/lib/auth/accounts.ts`

```ts
import "server-only";

import { compare, hash } from "bcryptjs";

import { database } from "@/lib/database/client";
import type { SignUpInput } from "@/lib/auth-inputs";
import type { User } from "@/lib/auth-types";

type AccountRow = User & {
  passwordHash: string;
};

export async function verifyCredentials(
  email: string,
  password: string,
): Promise<User | null> {
  const rows = await database<AccountRow[]>`
    SELECT
      id,
      name,
      email,
      password_hash AS "passwordHash"
    FROM users
    WHERE email = ${email}
    LIMIT 1
  `;

  const account = rows[0];

  if (!account) {
    /*
     * Perform a comparison even when the account is absent. This reduces the
     * timing difference between unknown-email and wrong-password responses.
     */
    await compare(
      password,
      "$2b$12$X3JqV4F4E8Bh58bXvYwz6OLpPVfYb5hB1l8GkPKn1xC9MMjRzXzVu",
    );

    return null;
  }

  const passwordMatches = await compare(
    password,
    account.passwordHash,
  );

  if (!passwordMatches) {
    return null;
  }

  return {
    id: account.id,
    name: account.name,
    email: account.email,
  };
}

export async function createUser(
  input: SignUpInput,
): Promise<User | null> {
  const passwordHash = await hash(input.password, 12);

  const rows = await database<User[]>`
    INSERT INTO users (
      name,
      email,
      password_hash
    )
    VALUES (
      ${input.name},
      ${input.email},
      ${passwordHash}
    )
    ON CONFLICT (lower(email))
    DO NOTHING
    RETURNING
      id,
      name,
      email
  `;

  return rows[0] ?? null;
}
```

Create the session database module.

### `src/lib/auth/session-store.ts`

```ts
import "server-only";

import { database } from "@/lib/database/client";
import type { SessionUser } from "@/lib/auth-types";

export async function insertSession(
  userId: string,
  tokenHash: string,
  expiresAt: Date,
): Promise<void> {
  await database`
    INSERT INTO sessions (
      user_id,
      token_hash,
      expires_at
    )
    VALUES (
      ${userId},
      ${tokenHash},
      ${expiresAt}
    )
  `;
}

export async function findSessionUser(
  tokenHash: string,
): Promise<SessionUser | null> {
  const rows = await database<SessionUser[]>`
    SELECT
      u.id,
      u.name,
      u.email,
      s.expires_at::text AS "sessionExpiresAt"
    FROM sessions AS s
    INNER JOIN users AS u
      ON u.id = s.user_id
    WHERE s.token_hash = ${tokenHash}
      AND s.expires_at > CURRENT_TIMESTAMP
    LIMIT 1
  `;

  return rows[0] ?? null;
}

export async function deleteSession(
  tokenHash: string,
): Promise<void> {
  await database`
    DELETE FROM sessions
    WHERE token_hash = ${tokenHash}
  `;
}

export async function deleteExpiredSessions(): Promise<number> {
  const rows = await database<{ id: string }[]>`
    DELETE FROM sessions
    WHERE expires_at <= CURRENT_TIMESTAMP
    RETURNING id
  `;

  return rows.length;
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Verify the development password hash works through PostgreSQL:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      email,
      password_hash = crypt(
        'LaunchPadDemo123!',
        password_hash
      ) AS password_matches
    FROM users
    WHERE email = 'demo@launchpad.local';
  "
```

Expected output:

```text
password_matches
----------------
t
```

[GENERATED: Part 8, Step 4: Authentication Database Layer] [STARTING: Part 8, Step 5: Secure Cookie Sessions]

---

# Step 5: Create Secure Cookie Session Utilities

## The Target

Generate random session tokens, hash them for database storage, write secure cookies, and load the current user.

## The Concept

A session token is a bearer credential. Anyone possessing it can act as that session’s user.

It must therefore be:

- Random
- Long enough to resist guessing
- Stored in an HTTP-only cookie
- Sent over HTTPS in production
- Protected with an appropriate SameSite policy
- Expired and deleted deliberately

We will use 32 random bytes, producing 256 bits of entropy.

## The Implementation

Create the session module.

### `src/lib/auth/session.ts`

```ts
import "server-only";

import {
  createHash,
  randomBytes,
} from "node:crypto";
import { cache } from "react";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import type { User } from "@/lib/auth-types";
import {
  deleteSession,
  findSessionUser,
  insertSession,
} from "@/lib/auth/session-store";

const SESSION_COOKIE_NAME = "launchpad_session";
const SESSION_DURATION_MILLISECONDS =
  1000 * 60 * 60 * 24 * 7;

function hashSessionToken(token: string): string {
  return createHash("sha256")
    .update(token)
    .digest("hex");
}

export async function createUserSession(
  userId: string,
): Promise<void> {
  const token = randomBytes(32).toString("base64url");
  const tokenHash = hashSessionToken(token);
  const expiresAt = new Date(
    Date.now() + SESSION_DURATION_MILLISECONDS,
  );

  await insertSession(userId, tokenHash, expiresAt);

  const cookieStore = await cookies();

  cookieStore.set(SESSION_COOKIE_NAME, token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    expires: expiresAt,
  });
}

export async function destroyCurrentSession(): Promise<void> {
  const cookieStore = await cookies();
  const token = cookieStore.get(SESSION_COOKIE_NAME)?.value;

  if (token) {
    await deleteSession(hashSessionToken(token));
  }

  cookieStore.set(SESSION_COOKIE_NAME, "", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    expires: new Date(0),
  });
}

/**
 * React cache deduplicates session lookup calls made during one server
 * rendering request.
 */
export const getCurrentUser = cache(
  async (): Promise<User | null> => {
    const cookieStore = await cookies();
    const token = cookieStore.get(SESSION_COOKIE_NAME)?.value;

    if (!token) {
      return null;
    }

    const sessionUser = await findSessionUser(
      hashSessionToken(token),
    );

    if (!sessionUser) {
      return null;
    }

    return {
      id: sessionUser.id,
      name: sessionUser.name,
      email: sessionUser.email,
    };
  },
);

export async function requireUser(): Promise<User> {
  const user = await getCurrentUser();

  if (!user) {
    redirect("/sign-in");
  }

  return user;
}

export async function requireApiUser(): Promise<User | null> {
  return getCurrentUser();
}
```

### Why `secure` depends on the environment

Local development commonly uses:

```text
http://localhost:3000
```

A Secure cookie is not sent over ordinary HTTP.

Production must use HTTPS, so the cookie becomes Secure when:

```ts
process.env.NODE_ENV === "production"
```

### Why SameSite is `lax`

`SameSite=Lax` limits many cross-site cookie submissions while preserving normal top-level navigation.

SameSite is useful defense in depth, but mutation endpoints must still be designed carefully. JSON APIs should verify authentication and accept only expected content types.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Confirm the cookie is protected:

```bash
grep -n \
  'httpOnly\|secure\|sameSite' \
  src/lib/auth/session.ts
```

[GENERATED: Part 8, Step 5: Secure Cookie Sessions] [STARTING: Part 8, Step 6: Authentication Server Actions]

---

# Step 6: Build Sign-In, Sign-Up, and Sign-Out Actions

## The Target

Create Server Actions that register users, verify credentials, create sessions, and destroy sessions.

## The Concept

Authentication errors should avoid revealing whether a specific email address exists.

Sign-in therefore returns one general failure message:

```text
The email or password is incorrect.
```

Registration also avoids exposing unnecessary database details.

After successful authentication, the server creates a session and redirects to the workspace.

## The Implementation

Create the auth route group and action file:

```bash
mkdir -p 'src/app/(auth)'
```

### `src/app/(auth)/actions.ts`

```ts
"use server";

import { redirect } from "next/navigation";

import {
  createFieldErrors,
  type FormActionState,
} from "@/lib/action-state";
import {
  createUser,
  verifyCredentials,
} from "@/lib/auth/accounts";
import {
  createUserSession,
  destroyCurrentSession,
} from "@/lib/auth/session";
import {
  signInInputSchema,
  signUpInputSchema,
} from "@/lib/auth-inputs";

export async function signInAction(
  _previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const parsedInput = signInInputSchema.safeParse({
    email: formData.get("email"),
    password: formData.get("password"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted sign-in fields.",
      fieldErrors: createFieldErrors(parsedInput.error.issues),
    };
  }

  let userId: string;

  try {
    const user = await verifyCredentials(
      parsedInput.data.email,
      parsedInput.data.password,
    );

    if (!user) {
      return {
        status: "error",
        message: "The email or password is incorrect.",
      };
    }

    userId = user.id;
    await createUserSession(userId);
  } catch (error) {
    console.error("Sign-in failed.", error);

    return {
      status: "error",
      message: "Sign-in is temporarily unavailable.",
    };
  }

  redirect("/dashboard");
}

export async function signUpAction(
  _previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const parsedInput = signUpInputSchema.safeParse({
    name: formData.get("name"),
    email: formData.get("email"),
    password: formData.get("password"),
    confirmPassword: formData.get("confirmPassword"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted registration fields.",
      fieldErrors: createFieldErrors(parsedInput.error.issues),
    };
  }

  let userId: string;

  try {
    const user = await createUser(parsedInput.data);

    if (!user) {
      return {
        status: "error",
        message:
          "An account cannot be created with that email address.",
      };
    }

    userId = user.id;
    await createUserSession(userId);
  } catch (error) {
    console.error("Registration failed.", error);

    return {
      status: "error",
      message: "Registration is temporarily unavailable.",
    };
  }

  redirect("/dashboard");
}

export async function signOutAction(): Promise<void> {
  await destroyCurrentSession();
  redirect("/sign-in");
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

The actions need forms before they can be tested.

[GENERATED: Part 8, Step 6: Authentication Actions] [STARTING: Part 8, Step 7: Authentication Pages]

---

# Step 7: Build Sign-In and Registration Pages

## The Target

Create accessible sign-in and registration forms and a separate authentication layout.

## The Concept

Authentication pages should not use the protected workspace shell.

They need a simple structure:

```text
LaunchPad brand
Authentication form
Public recovery navigation
```

Only the forms need client behavior for pending and validation state. Their pages and layout remain Server Components.

## The Implementation

Create the form components.

### `src/components/sign-in-form.tsx`

```tsx
"use client";

import { useActionState } from "react";

import { signInAction } from "@/app/(auth)/actions";
import { INITIAL_FORM_ACTION_STATE } from "@/lib/action-state";

export function SignInForm() {
  const [state, formAction, isPending] = useActionState(
    signInAction,
    INITIAL_FORM_ACTION_STATE,
  );

  return (
    <form className="stack-form auth-form" action={formAction}>
      <div className="form-field">
        <label htmlFor="sign-in-email">Email address</label>
        <input
          id="sign-in-email"
          name="email"
          type="email"
          autoComplete="email"
          required
          maxLength={320}
          aria-invalid={
            state.fieldErrors?.email ? true : undefined
          }
        />
        {state.fieldErrors?.email?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      <div className="form-field">
        <label htmlFor="sign-in-password">Password</label>
        <input
          id="sign-in-password"
          name="password"
          type="password"
          autoComplete="current-password"
          required
          maxLength={128}
          aria-invalid={
            state.fieldErrors?.password ? true : undefined
          }
        />
        {state.fieldErrors?.password?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      {state.message ? (
        <p className="form-message form-message--error" role="alert">
          {state.message}
        </p>
      ) : null}

      <button
        className="primary-button"
        type="submit"
        disabled={isPending}
      >
        {isPending ? "Signing in…" : "Sign in"}
      </button>
    </form>
  );
}
```

### `src/components/sign-up-form.tsx`

```tsx
"use client";

import { useActionState } from "react";

import { signUpAction } from "@/app/(auth)/actions";
import { INITIAL_FORM_ACTION_STATE } from "@/lib/action-state";

export function SignUpForm() {
  const [state, formAction, isPending] = useActionState(
    signUpAction,
    INITIAL_FORM_ACTION_STATE,
  );

  return (
    <form className="stack-form auth-form" action={formAction}>
      <div className="form-field">
        <label htmlFor="sign-up-name">Name</label>
        <input
          id="sign-up-name"
          name="name"
          type="text"
          autoComplete="name"
          required
          maxLength={100}
          aria-invalid={
            state.fieldErrors?.name ? true : undefined
          }
        />
        {state.fieldErrors?.name?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      <div className="form-field">
        <label htmlFor="sign-up-email">Email address</label>
        <input
          id="sign-up-email"
          name="email"
          type="email"
          autoComplete="email"
          required
          maxLength={320}
          aria-invalid={
            state.fieldErrors?.email ? true : undefined
          }
        />
        {state.fieldErrors?.email?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      <div className="form-field">
        <label htmlFor="sign-up-password">Password</label>
        <input
          id="sign-up-password"
          name="password"
          type="password"
          autoComplete="new-password"
          required
          minLength={12}
          maxLength={128}
          aria-invalid={
            state.fieldErrors?.password ? true : undefined
          }
        />
        <p className="field-help">
          Use at least 12 characters with uppercase, lowercase, number, and
          symbol characters.
        </p>
        {state.fieldErrors?.password?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      <div className="form-field">
        <label htmlFor="confirm-password">Confirm password</label>
        <input
          id="confirm-password"
          name="confirmPassword"
          type="password"
          autoComplete="new-password"
          required
          maxLength={128}
          aria-invalid={
            state.fieldErrors?.confirmPassword ? true : undefined
          }
        />
        {state.fieldErrors?.confirmPassword?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      {state.message ? (
        <p className="form-message form-message--error" role="alert">
          {state.message}
        </p>
      ) : null}

      <button
        className="primary-button"
        type="submit"
        disabled={isPending}
      >
        {isPending ? "Creating account…" : "Create account"}
      </button>
    </form>
  );
}
```

Create the authentication layout.

### `src/app/(auth)/layout.tsx`

```tsx
import Link from "next/link";
import type { ReactNode } from "react";

type AuthLayoutProps = Readonly<{
  children: ReactNode;
}>;

export default function AuthLayout({
  children,
}: AuthLayoutProps) {
  return (
    <div className="auth-shell">
      <header className="auth-header">
        <Link className="brand-link" href="/">
          LaunchPad
        </Link>
      </header>

      <div id="main-content" tabIndex={-1}>
        {children}
      </div>
    </div>
  );
}
```

Create the sign-in page:

```bash
mkdir -p 'src/app/(auth)/sign-in'
```

### `src/app/(auth)/sign-in/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";

import { SignInForm } from "@/components/sign-in-form";
import { getCurrentUser } from "@/lib/auth/session";

export const metadata: Metadata = {
  title: "Sign in",
  description: "Sign in to the LaunchPad workspace.",
};

export default async function SignInPage() {
  const user = await getCurrentUser();

  if (user) {
    redirect("/dashboard");
  }

  return (
    <main className="auth-page">
      <div className="auth-panel">
        <header className="auth-heading">
          <p className="eyebrow">Welcome back</p>
          <h1>Sign in to LaunchPad</h1>
          <p>
            Use your account credentials to access your private workspace.
          </p>
        </header>

        <div className="demo-credentials">
          <h2>Development account</h2>
          <p>
            Email: <code>demo@launchpad.local</code>
          </p>
          <p>
            Password: <code>LaunchPadDemo123!</code>
          </p>
        </div>

        <SignInForm />

        <p className="auth-alternate">
          Need an account?{" "}
          <Link href="/sign-up">Create one</Link>.
        </p>
      </div>
    </main>
  );
}
```

Create the sign-up page:

```bash
mkdir -p 'src/app/(auth)/sign-up'
```

### `src/app/(auth)/sign-up/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";
import { redirect } from "next/navigation";

import { SignUpForm } from "@/components/sign-up-form";
import { getCurrentUser } from "@/lib/auth/session";

export const metadata: Metadata = {
  title: "Create account",
  description: "Create a private LaunchPad account.",
};

export default async function SignUpPage() {
  const user = await getCurrentUser();

  if (user) {
    redirect("/dashboard");
  }

  return (
    <main className="auth-page">
      <div className="auth-panel">
        <header className="auth-heading">
          <p className="eyebrow">Create an account</p>
          <h1>Build your private workspace.</h1>
          <p>
            Your projects will be scoped to your account at every server and
            database boundary.
          </p>
        </header>

        <SignUpForm />

        <p className="auth-alternate">
          Already have an account?{" "}
          <Link href="/sign-in">Sign in</Link>.
        </p>
      </div>
    </main>
  );
}
```

## The Verification

Start the application:

```bash
npm run dev
```

Open:

```text
http://localhost:3000/sign-in
http://localhost:3000/sign-up
```

Confirm both forms render.

Try signing in with an incorrect password. The form should display:

```text
The email or password is incorrect.
```

Sign in with:

```text
Email: demo@launchpad.local
Password: LaunchPadDemo123!
```

Expected behavior:

1. A session is created.
2. A cookie is written.
3. The browser redirects to `/dashboard`.

Inspect the cookie in browser developer tools. It should be:

- Named `launchpad_session`
- HTTP-only
- SameSite Lax
- Scoped to `/`

[GENERATED: Part 8, Step 7: Authentication Pages] [STARTING: Part 8, Step 8: Protect the Workspace]

---

# Step 8: Protect the Workspace and Add Account Controls

## The Target

Require authentication for every workspace route and add a sign-out control.

## The Concept

The workspace layout surrounds:

```text
/dashboard
/projects
/projects/new
/projects/:projectId
```

Requiring a user in that layout protects the complete route group.

This is convenient, but it is not the only authorization layer. Server Actions, APIs, queries, and mutations must still enforce identity independently.

Layouts protect navigation. Database conditions protect data.

## The Implementation

Create the account menu.

### `src/components/account-menu.tsx`

```tsx
import { signOutAction } from "@/app/(auth)/actions";
import type { User } from "@/lib/auth-types";

type AccountMenuProps = {
  user: User;
};

export function AccountMenu({
  user,
}: AccountMenuProps) {
  return (
    <div className="account-menu">
      <div>
        <strong>{user.name}</strong>
        <span>{user.email}</span>
      </div>

      <form action={signOutAction}>
        <button className="secondary-button" type="submit">
          Sign out
        </button>
      </form>
    </div>
  );
}
```

Completely replace the workspace layout.

### `src/app/(workspace)/layout.tsx`

```tsx
import type { Metadata } from "next";
import type { ReactNode } from "react";

import { AccountMenu } from "@/components/account-menu";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { WorkspaceNavigation } from "@/components/workspace-navigation";
import { requireUser } from "@/lib/auth/session";

export const metadata: Metadata = {
  robots: {
    index: false,
    follow: false,
  },
};

type WorkspaceLayoutProps = Readonly<{
  children: ReactNode;
}>;

export default async function WorkspaceLayout({
  children,
}: WorkspaceLayoutProps) {
  const user = await requireUser();

  return (
    <div className="application-shell">
      <SiteHeader />

      <div className="workspace-account-bar">
        <div className="site-shell">
          <AccountMenu user={user} />
        </div>
      </div>

      <div className="workspace-shell">
        <aside className="workspace-sidebar">
          <WorkspaceNavigation />
        </aside>

        <div
          className="workspace-main"
          id="main-content"
          tabIndex={-1}
        >
          {children}
        </div>
      </div>

      <SiteFooter message="Private project workspace" />
    </div>
  );
}
```

## The Verification

While signed in, open:

```text
http://localhost:3000/dashboard
```

Confirm the account bar displays:

- Demo User
- `demo@launchpad.local`
- Sign out

Select **Sign out**.

Expected behavior:

1. The session is deleted from PostgreSQL.
2. The browser cookie expires.
3. The browser redirects to `/sign-in`.

Now request a protected route:

```text
http://localhost:3000/projects
```

You should be redirected to `/sign-in`.

Inspect session rows after signing in:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      user_id,
      length(token_hash) AS token_hash_length,
      expires_at
    FROM sessions;
  "
```

The hash length should be:

```text
64
```

The raw cookie token must not appear in the table.

[GENERATED: Part 8, Step 8: Protected Workspace] [STARTING: Part 8, Step 9: Owner-Scoped Queries]

---

# Step 9: Scope Every Read Query to the Authenticated User

## The Target

Require a user ID in every project, task, and dashboard query.

## The Concept

This query is unsafe in a multi-user application:

```sql
SELECT *
FROM projects
WHERE id = $project_id;
```

A signed-in user could request another user’s UUID.

The query must include ownership:

```sql
WHERE id = $project_id
  AND owner_id = $user_id;
```

When a record belongs to someone else, LaunchPad will behave as though it does not exist. This avoids revealing whether another user’s private identifier is valid.

## The Implementation

Completely replace the query module.

### `src/lib/database/project-queries.ts`

```ts
import "server-only";

import { cache } from "react";

import { database } from "@/lib/database/client";
import {
  dashboardMetricsSchema,
  projectSummaryListSchema,
  projectSummarySchema,
  taskListSchema,
  type DashboardMetrics,
} from "@/lib/database/schemas";
import type {
  ProjectStatus,
  ProjectSummary,
} from "@/lib/project-types";
import type { Task } from "@/lib/task-types";

type ProjectSummaryRow = ProjectSummary;

type DashboardMetricsRow = {
  projectCount: number;
  activeProjectCount: number;
  taskCount: number;
  completedTaskCount: number;
};

export async function getProjects(
  userId: string,
  status?: ProjectStatus,
): Promise<ProjectSummary[]> {
  const rows = status
    ? await database<ProjectSummaryRow[]>`
        SELECT
          p.id,
          p.name,
          p.description,
          p.status,
          COUNT(t.id)::integer AS "taskCount",
          COUNT(t.id) FILTER (
            WHERE t.status = 'COMPLETED'
          )::integer AS "completedTaskCount"
        FROM projects AS p
        LEFT JOIN tasks AS t
          ON t.project_id = p.id
        WHERE p.owner_id = ${userId}
          AND p.status = ${status}
        GROUP BY p.id
        ORDER BY p.updated_at DESC, p.name ASC
      `
    : await database<ProjectSummaryRow[]>`
        SELECT
          p.id,
          p.name,
          p.description,
          p.status,
          COUNT(t.id)::integer AS "taskCount",
          COUNT(t.id) FILTER (
            WHERE t.status = 'COMPLETED'
          )::integer AS "completedTaskCount"
        FROM projects AS p
        LEFT JOIN tasks AS t
          ON t.project_id = p.id
        WHERE p.owner_id = ${userId}
        GROUP BY p.id
        ORDER BY p.updated_at DESC, p.name ASC
      `;

  return projectSummaryListSchema.parse(rows);
}

export const getProjectById = cache(
  async (
    userId: string,
    projectId: string,
  ): Promise<ProjectSummary | null> => {
    const rows = await database<ProjectSummaryRow[]>`
      SELECT
        p.id,
        p.name,
        p.description,
        p.status,
        COUNT(t.id)::integer AS "taskCount",
        COUNT(t.id) FILTER (
          WHERE t.status = 'COMPLETED'
        )::integer AS "completedTaskCount"
      FROM projects AS p
      LEFT JOIN tasks AS t
        ON t.project_id = p.id
      WHERE p.id = ${projectId}
        AND p.owner_id = ${userId}
      GROUP BY p.id
      LIMIT 1
    `;

    const row = rows[0];

    return row ? projectSummarySchema.parse(row) : null;
  },
);

export async function getDashboardMetrics(
  userId: string,
): Promise<DashboardMetrics> {
  const rows = await database<DashboardMetricsRow[]>`
    SELECT
      COUNT(DISTINCT p.id)::integer AS "projectCount",
      COUNT(DISTINCT p.id) FILTER (
        WHERE p.status = 'ACTIVE'
      )::integer AS "activeProjectCount",
      COUNT(t.id)::integer AS "taskCount",
      COUNT(t.id) FILTER (
        WHERE t.status = 'COMPLETED'
      )::integer AS "completedTaskCount"
    FROM projects AS p
    LEFT JOIN tasks AS t
      ON t.project_id = p.id
    WHERE p.owner_id = ${userId}
  `;

  return dashboardMetricsSchema.parse(
    rows[0] ?? {
      projectCount: 0,
      activeProjectCount: 0,
      taskCount: 0,
      completedTaskCount: 0,
    },
  );
}

export async function getActiveProjects(
  userId: string,
  limit = 4,
): Promise<ProjectSummary[]> {
  if (!Number.isInteger(limit) || limit < 1 || limit > 20) {
    throw new RangeError(
      "Active project limit must be an integer between 1 and 20.",
    );
  }

  const rows = await database<ProjectSummaryRow[]>`
    SELECT
      p.id,
      p.name,
      p.description,
      p.status,
      COUNT(t.id)::integer AS "taskCount",
      COUNT(t.id) FILTER (
        WHERE t.status = 'COMPLETED'
      )::integer AS "completedTaskCount"
    FROM projects AS p
    LEFT JOIN tasks AS t
      ON t.project_id = p.id
    WHERE p.owner_id = ${userId}
      AND p.status = 'ACTIVE'
    GROUP BY p.id
    ORDER BY p.updated_at DESC, p.name ASC
    LIMIT ${limit}
  `;

  return projectSummaryListSchema.parse(rows);
}

export async function getTasksForProject(
  userId: string,
  projectId: string,
): Promise<Task[]> {
  const rows = await database<Task[]>`
    SELECT
      t.id,
      t.project_id AS "projectId",
      t.title,
      t.description,
      t.status,
      t.priority,
      to_char(t.due_date, 'YYYY-MM-DD') AS "dueDate",
      t.created_at::text AS "createdAt",
      t.updated_at::text AS "updatedAt"
    FROM tasks AS t
    INNER JOIN projects AS p
      ON p.id = t.project_id
    WHERE t.project_id = ${projectId}
      AND p.owner_id = ${userId}
    ORDER BY
      CASE t.status
        WHEN 'IN_PROGRESS' THEN 1
        WHEN 'TODO' THEN 2
        WHEN 'COMPLETED' THEN 3
      END,
      t.due_date ASC NULLS LAST,
      t.created_at ASC
  `;

  return taskListSchema.parse(rows);
}
```

### Update query callers

Apply these changes:

#### `src/app/(workspace)/projects/page.tsx`

Add:

```tsx
import { requireUser } from "@/lib/auth/session";
```

Before the query, add:

```tsx
const user = await requireUser();
```

Change:

```tsx
const projects = await getProjects(selectedStatus);
```

to:

```tsx
const projects = await getProjects(user.id, selectedStatus);
```

#### `src/components/dashboard-metrics.tsx`

Add:

```tsx
import { requireUser } from "@/lib/auth/session";
```

Change the component body to:

```tsx
export async function DashboardMetrics() {
  const user = await requireUser();
  const metrics = await getDashboardMetrics(user.id);

  const overallProgress =
    metrics.taskCount === 0
      ? 0
      : Math.round(
          (metrics.completedTaskCount / metrics.taskCount) * 100,
        );

  return (
    <section
      className="dashboard-stat-grid"
      aria-label="Workspace statistics"
    >
      <article className="dashboard-stat">
        <span>Projects</span>
        <strong>{metrics.projectCount}</strong>
        <p>{metrics.activeProjectCount} currently active</p>
      </article>

      <article className="dashboard-stat">
        <span>Total tasks</span>
        <strong>{metrics.taskCount}</strong>
        <p>Across every project</p>
      </article>

      <article className="dashboard-stat">
        <span>Completed tasks</span>
        <strong>{metrics.completedTaskCount}</strong>
        <p>{overallProgress}% overall progress</p>
      </article>
    </section>
  );
}
```

#### `src/components/dashboard-active-projects.tsx`

Add:

```tsx
import { requireUser } from "@/lib/auth/session";
```

Change:

```tsx
const activeProjects = await getActiveProjects(4);
```

to:

```tsx
const user = await requireUser();
const activeProjects = await getActiveProjects(user.id, 4);
```

#### Dynamic project page

Add:

```tsx
import { requireUser } from "@/lib/auth/session";
```

Change metadata lookup to:

```tsx
const user = await requireUser();
const project = await getProjectById(user.id, projectId);
```

Update `findProject` to accept a user ID:

```tsx
async function findProject(
  userId: string,
  projectId: string,
) {
  const parsedProjectId = projectIdSchema.safeParse(projectId);

  if (!parsedProjectId.success) {
    return null;
  }

  return getProjectById(userId, parsedProjectId.data);
}
```

In the page, add:

```tsx
const user = await requireUser();
```

Then change its parallel queries to:

```tsx
const [project, tasks] = await Promise.all([
  getProjectById(user.id, parsedProjectId.data),
  getTasksForProject(user.id, parsedProjectId.data),
]);
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

TypeScript will identify any old query call missing `userId`. Fix every reported caller before continuing.

Sign in as the demo user and verify:

```text
/dashboard
/projects
/projects/10000000-0000-4000-8000-000000000001
```

All seeded records should remain visible.

[GENERATED: Part 8, Step 9: Owner-Scoped Queries] [STARTING: Part 8, Step 10: Owner-Scoped Mutations]

---

# Step 10: Scope Every Mutation to the Authenticated User

## The Target

Require a user ID for project and task writes and enforce ownership in SQL.

## The Concept

Authorization should occur in the same database statement that changes the record.

Unsafe sequence:

```text
1. Check project owner
2. Another operation changes ownership
3. Update project
```

Safer operation:

```sql
UPDATE projects
SET ...
WHERE id = $project_id
  AND owner_id = $user_id
```

The authorization condition and mutation execute together.

## The Implementation

Completely replace the mutation module.

### `src/lib/database/project-mutations.ts`

```ts
import "server-only";

import { database } from "@/lib/database/client";
import {
  projectSummarySchema,
  taskSchema,
} from "@/lib/database/schemas";
import type {
  CreateProjectInput,
  CreateTaskInput,
  UpdateProjectInput,
  UpdateTaskStatusInput,
} from "@/lib/project-inputs";
import type { ProjectSummary } from "@/lib/project-types";
import type { Task } from "@/lib/task-types";

async function readOwnedProject(
  userId: string,
  projectId: string,
): Promise<ProjectSummary | null> {
  const rows = await database<ProjectSummary[]>`
    SELECT
      p.id,
      p.name,
      p.description,
      p.status,
      COUNT(t.id)::integer AS "taskCount",
      COUNT(t.id) FILTER (
        WHERE t.status = 'COMPLETED'
      )::integer AS "completedTaskCount"
    FROM projects AS p
    LEFT JOIN tasks AS t
      ON t.project_id = p.id
    WHERE p.id = ${projectId}
      AND p.owner_id = ${userId}
    GROUP BY p.id
    LIMIT 1
  `;

  const row = rows[0];

  return row ? projectSummarySchema.parse(row) : null;
}

export async function createProject(
  userId: string,
  input: CreateProjectInput,
): Promise<ProjectSummary> {
  const rows = await database<{ id: string }[]>`
    INSERT INTO projects (
      owner_id,
      name,
      description,
      status
    )
    VALUES (
      ${userId},
      ${input.name},
      ${input.description},
      ${input.status}
    )
    RETURNING id
  `;

  const projectId = rows[0]?.id;

  if (!projectId) {
    throw new Error("The project insert returned no identifier.");
  }

  const project = await readOwnedProject(userId, projectId);

  if (!project) {
    throw new Error("The created project could not be read.");
  }

  return project;
}

export async function updateProject(
  userId: string,
  projectId: string,
  input: UpdateProjectInput,
): Promise<ProjectSummary | null> {
  const rows = await database<{ id: string }[]>`
    UPDATE projects
    SET
      name = COALESCE(${input.name ?? null}, name),
      description = COALESCE(
        ${input.description ?? null},
        description
      ),
      status = COALESCE(${input.status ?? null}, status),
      updated_at = CURRENT_TIMESTAMP
    WHERE id = ${projectId}
      AND owner_id = ${userId}
    RETURNING id
  `;

  if (!rows[0]) {
    return null;
  }

  return readOwnedProject(userId, projectId);
}

export async function deleteProject(
  userId: string,
  projectId: string,
): Promise<boolean> {
  const rows = await database<{ id: string }[]>`
    DELETE FROM projects
    WHERE id = ${projectId}
      AND owner_id = ${userId}
    RETURNING id
  `;

  return rows.length === 1;
}

export async function createTask(
  userId: string,
  projectId: string,
  input: CreateTaskInput,
): Promise<Task | null> {
  const rows = await database<Task[]>`
    INSERT INTO tasks (
      project_id,
      title,
      description,
      priority,
      due_date
    )
    SELECT
      p.id,
      ${input.title},
      ${input.description},
      ${input.priority},
      ${input.dueDate}
    FROM projects AS p
    WHERE p.id = ${projectId}
      AND p.owner_id = ${userId}
    RETURNING
      id,
      project_id AS "projectId",
      title,
      description,
      status,
      priority,
      to_char(due_date, 'YYYY-MM-DD') AS "dueDate",
      created_at::text AS "createdAt",
      updated_at::text AS "updatedAt"
  `;

  const row = rows[0];

  if (!row) {
    return null;
  }

  await database`
    UPDATE projects
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = ${projectId}
      AND owner_id = ${userId}
  `;

  return taskSchema.parse(row);
}

export async function updateTaskStatus(
  userId: string,
  projectId: string,
  taskId: string,
  input: UpdateTaskStatusInput,
): Promise<Task | null> {
  const rows = await database<Task[]>`
    UPDATE tasks AS t
    SET
      status = ${input.status},
      updated_at = CURRENT_TIMESTAMP
    FROM projects AS p
    WHERE t.id = ${taskId}
      AND t.project_id = ${projectId}
      AND p.id = t.project_id
      AND p.owner_id = ${userId}
    RETURNING
      t.id,
      t.project_id AS "projectId",
      t.title,
      t.description,
      t.status,
      t.priority,
      to_char(t.due_date, 'YYYY-MM-DD') AS "dueDate",
      t.created_at::text AS "createdAt",
      t.updated_at::text AS "updatedAt"
  `;

  const row = rows[0];

  if (!row) {
    return null;
  }

  await database`
    UPDATE projects
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = ${projectId}
      AND owner_id = ${userId}
  `;

  return taskSchema.parse(row);
}
```

### Why a missing owned record returns `null`

These conditions intentionally produce the same result:

- The project does not exist.
- The project belongs to another user.
- The task does not exist.
- The task belongs to a project owned by another user.

Returning the same result avoids revealing whether another user’s private resource exists.

### Update the project creation action

In:

```text
src/app/(workspace)/projects/actions.ts
```

add:

```ts
import { requireUser } from "@/lib/auth/session";
```

Then add this line at the beginning of `createProjectAction`:

```ts
const user = await requireUser();
```

Change:

```ts
const project = await createProject(parsedInput.data);
```

to:

```ts
const project = await createProject(
  user.id,
  parsedInput.data,
);
```

The complete action should now be:

### `src/app/(workspace)/projects/actions.ts`

```ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import {
  createFieldErrors,
  type FormActionState,
} from "@/lib/action-state";
import { requireUser } from "@/lib/auth/session";
import { createProject } from "@/lib/database/project-mutations";
import { createProjectInputSchema } from "@/lib/project-inputs";

export async function createProjectAction(
  _previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const user = await requireUser();

  const parsedInput = createProjectInputSchema.safeParse({
    name: formData.get("name"),
    description: formData.get("description"),
    status: formData.get("status"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted project fields.",
      fieldErrors: createFieldErrors(parsedInput.error.issues),
    };
  }

  let projectId: string;

  try {
    const project = await createProject(
      user.id,
      parsedInput.data,
    );

    projectId = project.id;
  } catch (error) {
    console.error("Project creation action failed.", error);

    return {
      status: "error",
      message:
        "The project could not be created. Please try again.",
    };
  }

  revalidatePath("/dashboard");
  revalidatePath("/projects");

  redirect(`/projects/${projectId}`);
}
```

### Update the task actions

Completely replace the task action file.

### `src/app/(workspace)/projects/[projectId]/actions.ts`

```ts
"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";

import {
  createFieldErrors,
  type FormActionState,
} from "@/lib/action-state";
import { requireUser } from "@/lib/auth/session";
import {
  createTask,
  updateTaskStatus,
} from "@/lib/database/project-mutations";
import {
  createTaskInputSchema,
  updateTaskStatusInputSchema,
} from "@/lib/project-inputs";

const identifierSchema = z.string().uuid();

export async function createTaskAction(
  projectId: string,
  _previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const user = await requireUser();
  const parsedProjectId = identifierSchema.safeParse(projectId);

  if (!parsedProjectId.success) {
    return {
      status: "error",
      message: "The project identifier is invalid.",
    };
  }

  const parsedInput = createTaskInputSchema.safeParse({
    title: formData.get("title"),
    description: formData.get("description"),
    priority: formData.get("priority"),
    dueDate: formData.get("dueDate"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted task fields.",
      fieldErrors: createFieldErrors(parsedInput.error.issues),
    };
  }

  try {
    const task = await createTask(
      user.id,
      parsedProjectId.data,
      parsedInput.data,
    );

    if (!task) {
      return {
        status: "error",
        message: "The project could not be found.",
      };
    }

    revalidatePath("/dashboard");
    revalidatePath("/projects");
    revalidatePath(`/projects/${parsedProjectId.data}`);

    return {
      status: "success",
      message: "Task created.",
    };
  } catch (error) {
    console.error("Task creation action failed.", error);

    return {
      status: "error",
      message: "The task could not be created.",
    };
  }
}

export async function updateTaskStatusAction(
  projectId: string,
  taskId: string,
  formData: FormData,
): Promise<void> {
  const user = await requireUser();
  const parsedProjectId = identifierSchema.safeParse(projectId);
  const parsedTaskId = identifierSchema.safeParse(taskId);
  const parsedInput = updateTaskStatusInputSchema.safeParse({
    status: formData.get("status"),
  });

  if (
    !parsedProjectId.success ||
    !parsedTaskId.success ||
    !parsedInput.success
  ) {
    throw new Error("The task status request is invalid.");
  }

  const task = await updateTaskStatus(
    user.id,
    parsedProjectId.data,
    parsedTaskId.data,
    parsedInput.data,
  );

  if (!task) {
    throw new Error("The requested task could not be found.");
  }

  revalidatePath("/dashboard");
  revalidatePath("/projects");
  revalidatePath(`/projects/${parsedProjectId.data}`);
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

If TypeScript reports a mutation call with too few arguments, locate every caller:

```bash
grep -R \
  'createProject(\|updateProject(\|deleteProject(\|createTask(\|updateTaskStatus(' \
  src \
  --include="*.ts" \
  --include="*.tsx"
```

Every database mutation must now receive `user.id` as its first argument.

Sign in, create a project, add a task, and update its status. Confirm all operations still work.

Sign out and try to open:

```text
http://localhost:3000/projects/new
```

You should be redirected to `/sign-in`.

[GENERATED: Part 8, Step 10: Owner-Scoped Mutations] [STARTING: Part 8, Step 11: Authenticate the JSON API]

---

# Step 11: Authenticate and Authorize the JSON API

## The Target

Require a valid session for every project API operation and scope all API data to the authenticated user.

## The Concept

Protecting browser pages does not protect API endpoints.

A caller can bypass the interface and request:

```text
/api/projects
```

directly.

Each Route Handler must independently authenticate the request before reading or mutating data.

Unauthenticated API requests should receive:

```text
401 Unauthorized
```

An authenticated request for a project the user does not own should receive:

```text
404 Not Found
```

Using `404` avoids confirming that another user’s private project exists.

## The Implementation

Completely replace the project collection handler.

### `src/app/api/projects/route.ts`

```ts
import { revalidatePath } from "next/cache";

import {
  apiError,
  apiSuccess,
  readJsonBody,
  zodErrorDetails,
} from "@/lib/api-response";
import { requireApiUser } from "@/lib/auth/session";
import { createProject } from "@/lib/database/project-mutations";
import { getProjects } from "@/lib/database/project-queries";
import { createProjectInputSchema } from "@/lib/project-inputs";
import {
  isProjectStatus,
  type ProjectStatus,
} from "@/lib/project-types";

export async function GET(request: Request) {
  const user = await requireApiUser();

  if (!user) {
    return apiError(
      401,
      "UNAUTHORIZED",
      "Authentication is required.",
    );
  }

  const url = new URL(request.url);
  const requestedStatus = url.searchParams.get("status");

  let status: ProjectStatus | undefined;

  if (requestedStatus !== null) {
    const normalizedStatus = requestedStatus.toUpperCase();

    if (!isProjectStatus(normalizedStatus)) {
      return apiError(
        400,
        "VALIDATION_ERROR",
        "The status query parameter is invalid.",
        [
          {
            path: "status",
            message:
              "Status must be PLANNED, ACTIVE, or COMPLETED.",
          },
        ],
      );
    }

    status = normalizedStatus;
  }

  try {
    const projects = await getProjects(user.id, status);

    return apiSuccess(projects);
  } catch (error) {
    console.error("GET /api/projects failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "Projects could not be retrieved.",
    );
  }
}

export async function POST(request: Request) {
  const user = await requireApiUser();

  if (!user) {
    return apiError(
      401,
      "UNAUTHORIZED",
      "Authentication is required.",
    );
  }

  const body = await readJsonBody(request);

  if (!body.success) {
    return body.response;
  }

  const parsedInput = createProjectInputSchema.safeParse(body.data);

  if (!parsedInput.success) {
    return apiError(
      422,
      "VALIDATION_ERROR",
      "The project input is invalid.",
      zodErrorDetails(parsedInput.error),
    );
  }

  try {
    const project = await createProject(
      user.id,
      parsedInput.data,
    );

    revalidatePath("/dashboard");
    revalidatePath("/projects");

    return apiSuccess(project, {
      status: 201,
      headers: {
        Location: `/api/projects/${project.id}`,
      },
    });
  } catch (error) {
    console.error("POST /api/projects failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be created.",
    );
  }
}
```

The new error code must be added to the API utility.

In:

```text
src/lib/api-response.ts
```

change `ApiErrorCode` to:

```ts
type ApiErrorCode =
  | "BAD_REQUEST"
  | "INVALID_JSON"
  | "VALIDATION_ERROR"
  | "UNAUTHORIZED"
  | "FORBIDDEN"
  | "NOT_FOUND"
  | "METHOD_NOT_ALLOWED"
  | "INTERNAL_ERROR"
  | "SERVICE_UNAVAILABLE";
```

Now completely replace the individual project handler.

### `src/app/api/projects/[projectId]/route.ts`

```ts
import { revalidatePath } from "next/cache";
import { z } from "zod";

import {
  apiError,
  apiSuccess,
  readJsonBody,
  zodErrorDetails,
} from "@/lib/api-response";
import { requireApiUser } from "@/lib/auth/session";
import {
  deleteProject,
  updateProject,
} from "@/lib/database/project-mutations";
import { getProjectById } from "@/lib/database/project-queries";
import { updateProjectInputSchema } from "@/lib/project-inputs";

type ProjectRouteContext = {
  params: Promise<{
    projectId: string;
  }>;
};

const projectIdSchema = z.string().uuid();

async function readProjectId(context: ProjectRouteContext) {
  const { projectId } = await context.params;

  return projectIdSchema.safeParse(projectId);
}

export async function GET(
  _request: Request,
  context: ProjectRouteContext,
) {
  const user = await requireApiUser();

  if (!user) {
    return apiError(
      401,
      "UNAUTHORIZED",
      "Authentication is required.",
    );
  }

  const parsedProjectId = await readProjectId(context);

  if (!parsedProjectId.success) {
    return apiError(
      400,
      "VALIDATION_ERROR",
      "The project identifier is invalid.",
    );
  }

  try {
    const project = await getProjectById(
      user.id,
      parsedProjectId.data,
    );

    if (!project) {
      return apiError(
        404,
        "NOT_FOUND",
        "The requested project does not exist.",
      );
    }

    return apiSuccess(project);
  } catch (error) {
    console.error("GET /api/projects/:projectId failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be retrieved.",
    );
  }
}

export async function PATCH(
  request: Request,
  context: ProjectRouteContext,
) {
  const user = await requireApiUser();

  if (!user) {
    return apiError(
      401,
      "UNAUTHORIZED",
      "Authentication is required.",
    );
  }

  const parsedProjectId = await readProjectId(context);

  if (!parsedProjectId.success) {
    return apiError(
      400,
      "VALIDATION_ERROR",
      "The project identifier is invalid.",
    );
  }

  const body = await readJsonBody(request);

  if (!body.success) {
    return body.response;
  }

  const parsedInput = updateProjectInputSchema.safeParse(body.data);

  if (!parsedInput.success) {
    return apiError(
      422,
      "VALIDATION_ERROR",
      "The project update is invalid.",
      zodErrorDetails(parsedInput.error),
    );
  }

  try {
    const project = await updateProject(
      user.id,
      parsedProjectId.data,
      parsedInput.data,
    );

    if (!project) {
      return apiError(
        404,
        "NOT_FOUND",
        "The requested project does not exist.",
      );
    }

    revalidatePath("/dashboard");
    revalidatePath("/projects");
    revalidatePath(`/projects/${project.id}`);

    return apiSuccess(project);
  } catch (error) {
    console.error("PATCH /api/projects/:projectId failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be updated.",
    );
  }
}

export async function DELETE(
  _request: Request,
  context: ProjectRouteContext,
) {
  const user = await requireApiUser();

  if (!user) {
    return apiError(
      401,
      "UNAUTHORIZED",
      "Authentication is required.",
    );
  }

  const parsedProjectId = await readProjectId(context);

  if (!parsedProjectId.success) {
    return apiError(
      400,
      "VALIDATION_ERROR",
      "The project identifier is invalid.",
    );
  }

  try {
    const deleted = await deleteProject(
      user.id,
      parsedProjectId.data,
    );

    if (!deleted) {
      return apiError(
        404,
        "NOT_FOUND",
        "The requested project does not exist.",
      );
    }

    revalidatePath("/dashboard");
    revalidatePath("/projects");

    return new Response(null, {
      status: 204,
    });
  } catch (error) {
    console.error("DELETE /api/projects/:projectId failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be deleted.",
    );
  }
}
```

## The Verification

Sign out in the browser or use a fresh terminal without a cookie.

Request the API:

```bash
curl --silent \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected response includes:

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication is required."
  }
}
```

Expected status:

```text
401
```

The health endpoint should remain public:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/health
```

Expected output:

```text
200
```

Authenticated API verification will use a cookie jar in Step 14.

[GENERATED: Part 8, Step 11: Authenticated JSON API] [STARTING: Part 8, Step 12: Authentication Styles]

---

# Step 12: Style Authentication and Account Interfaces

## The Target

Add responsive styles for the authentication shell, credentials panel, and signed-in account bar.

## The Concept

Authentication pages should communicate trust and clarity without adding unnecessary visual complexity.

Password forms need:

- Visible labels
- Browser autocomplete attributes
- Clear validation messages
- Readable password requirements
- Strong focus states

The account bar should make the current identity and sign-out action obvious.

## The Implementation

Append the following styles to:

### `src/app/globals.css`

```css
/* Part 8: authentication and account interfaces */

.auth-shell {
  min-height: 100vh;
  background:
    radial-gradient(
      circle at top,
      rgb(52 87 213 / 14%),
      transparent 34rem
    ),
    var(--color-background);
}

.auth-header {
  display: flex;
  width: min(100% - 2rem, var(--content-width));
  min-height: 4.5rem;
  margin-inline: auto;
  align-items: center;
}

.auth-page {
  display: grid;
  width: min(100% - 2rem, 42rem);
  min-height: calc(100vh - 4.5rem);
  margin-inline: auto;
  padding-block: var(--space-12);
  align-items: start;
}

.auth-panel {
  padding: clamp(
    var(--space-6),
    6vw,
    var(--space-12)
  );
  border: 0.0625rem solid var(--color-border);
  border-radius: var(--radius-large);
  background: rgb(255 255 255 / 92%);
  box-shadow: var(--shadow-raised);
}

.auth-heading {
  margin-bottom: var(--space-8);
}

.auth-heading h1 {
  margin: 0;
  font-size: clamp(2.25rem, 7vw, 4rem);
  line-height: var(--line-height-tight);
  letter-spacing: -0.05em;
}

.auth-heading > p:last-child {
  margin: var(--space-4) 0 0;
  color: var(--color-text-muted);
  font-size: var(--font-size-lead);
}

.auth-form {
  max-width: none;
  padding: 0;
  border: 0;
  box-shadow: none;
}

.demo-credentials {
  margin-bottom: var(--space-8);
  padding: var(--space-4);
  border: 0.0625rem solid var(--color-border);
  border-left: 0.3rem solid var(--color-primary);
  border-radius: var(--radius-medium);
  background: var(--color-primary-soft);
}

.demo-credentials h2 {
  margin: 0;
  font-size: var(--font-size-heading-small);
}

.demo-credentials p {
  margin: var(--space-2) 0 0;
  color: var(--color-text-muted);
  overflow-wrap: anywhere;
}

.auth-alternate {
  margin: var(--space-6) 0 0;
  color: var(--color-text-muted);
  text-align: center;
}

.auth-alternate a {
  color: var(--color-primary);
  font-weight: 800;
  text-underline-offset: 0.2rem;
}

.workspace-account-bar {
  border-bottom: 0.0625rem solid var(--color-border);
  background: var(--color-surface);
}

.account-menu {
  display: flex;
  min-height: 4rem;
  align-items: center;
  justify-content: flex-end;
  gap: var(--space-4);
}

.account-menu > div {
  display: grid;
  text-align: right;
}

.account-menu strong {
  line-height: 1.2;
}

.account-menu span {
  color: var(--color-text-muted);
  font-size: var(--font-size-small);
}

@media (max-width: 36rem) {
  .auth-page {
    padding-block: var(--space-6);
  }

  .auth-panel {
    padding: var(--space-5);
  }

  .account-menu {
    padding-block: var(--space-3);
    align-items: stretch;
    flex-direction: column;
  }

  .account-menu > div {
    text-align: left;
  }

  .account-menu form,
  .account-menu button {
    width: 100%;
  }
}

@media print {
  .workspace-account-bar {
    display: none !important;
  }
}
```

## The Verification

Open:

```text
http://localhost:3000/sign-in
http://localhost:3000/sign-up
```

Test at:

```text
1440px
768px
390px
320px
```

Confirm:

- No horizontal page overflow occurs.
- Password guidance wraps correctly.
- Form controls remain full width.
- Validation messages remain readable.
- The development credentials panel is visually distinct.

After signing in, inspect the account bar on a narrow screen. Confirm that the sign-out control remains usable.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 8, Step 12: Authentication Styles] [STARTING: Part 8, Step 13: Session and Redirect Verification]

---

# Step 13: Verify Sessions, Redirects, and Sign-Out

## The Target

Verify protected-page redirects, sign-in cookies, authenticated access, session storage, and sign-out behavior with `curl`.

## The Concept

A browser automatically stores and sends cookies. A command-line HTTP client needs an explicit **cookie jar**.

A cookie jar is a file in which `curl` records cookies from one response and sends them with later requests.

The flow will be:

```text
POST authentication action through browser for UI testing
or create a test session through the browser
            ↓
Save cookie
            ↓
Request protected routes
            ↓
Sign out
            ↓
Protected access fails again
```

Server Actions use framework-generated request details, so direct `curl` submission to an action endpoint is deliberately not a stable public API contract.

For command-line authentication testing, we will use the browser’s cookie value or add a development-only API. We will not add a development authentication bypass. The safer verification is to use browser sign-in, then copy the cookie into `curl`.

## The Implementation

Sign in through the browser as:

```text
demo@launchpad.local
LaunchPadDemo123!
```

In browser developer tools:

1. Open Application or Storage.
2. Open Cookies.
3. Select `http://localhost:3000`.
4. Copy the value of `launchpad_session`.

In the terminal, assign it without committing or saving it:

```bash
SESSION_TOKEN='paste-the-cookie-value-here'
```

Request a protected page:

```bash
curl --silent \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/dashboard
```

Expected output:

```text
200
```

Request the authenticated API:

```bash
curl --fail --silent \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  http://localhost:3000/api/projects |
  python -m json.tool
```

The response should contain the demo user’s projects.

Request without the cookie:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected output:

```text
401
```

### Verify the protected-page redirect

Run:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code} %{redirect_url}\n" \
  http://localhost:3000/dashboard
```

Expected output resembles:

```text
307 http://localhost:3000/sign-in
```

Next.js may use another redirect status appropriate to the framework version, but the destination must be `/sign-in`.

## The Verification

In the browser:

1. Sign in.
2. Open `/dashboard`.
3. Refresh and confirm the session persists.
4. Open `/sign-in`; confirm it redirects back to `/dashboard`.
5. Sign out.
6. Confirm `/sign-in` appears.
7. Open `/dashboard`; confirm it redirects to `/sign-in`.
8. Confirm the session cookie is absent or expired.
9. Confirm the corresponding session row was removed.

Inspect active sessions:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      u.email,
      s.created_at,
      s.expires_at
    FROM sessions AS s
    INNER JOIN users AS u
      ON u.id = s.user_id
    ORDER BY s.created_at DESC;
  "
```

[GENERATED: Part 8, Step 13: Session Verification] [STARTING: Part 8, Step 14: Authenticated API Verification]

---

# Step 14: Verify Authenticated API Ownership

## The Target

Use an authenticated cookie to verify API reads and writes while confirming anonymous requests remain blocked.

## The Concept

The cookie authenticates the caller, but the server determines ownership.

When the demo user creates a project, the API does not accept an `ownerId` field. It derives ownership from the authenticated session:

```ts
createProject(user.id, input)
```

This prevents callers from assigning records to arbitrary users.

## The Implementation

Sign in through the browser and assign the current cookie value:

```bash
SESSION_TOKEN='paste-the-current-cookie-value-here'
```

Create an authenticated project:

```bash
PROJECT_RESPONSE="$(
  curl --fail --silent \
    --request POST \
    --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
    --header "Content-Type: application/json" \
    --data '{
      "name": "Authenticated API verification",
      "description": "A temporary project created by the signed-in demo user.",
      "status": "PLANNED"
    }' \
    http://localhost:3000/api/projects
)"

printf "%s\n" "${PROJECT_RESPONSE}" |
  python -m json.tool

PROJECT_ID="$(
  printf "%s" "${PROJECT_RESPONSE}" |
    python -c '
import json, sys
print(json.load(sys.stdin)["data"]["id"])
'
)"
```

Verify database ownership:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      p.name,
      u.email
    FROM projects AS p
    INNER JOIN users AS u
      ON u.id = p.owner_id
    WHERE p.id = '${PROJECT_ID}';
  "
```

Expected owner:

```text
demo@launchpad.local
```

Update the project:

```bash
curl --fail --silent \
  --request PATCH \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  --header "Content-Type: application/json" \
  --data '{
    "status": "ACTIVE"
  }' \
  "http://localhost:3000/api/projects/${PROJECT_ID}" |
  python -m json.tool
```

Try to update it anonymously:

```bash
curl --silent \
  --request PATCH \
  --header "Content-Type: application/json" \
  --data '{
    "status": "COMPLETED"
  }' \
  --write-out "\nStatus: %{http_code}\n" \
  "http://localhost:3000/api/projects/${PROJECT_ID}"
```

Expected status:

```text
401
```

Delete the temporary project with the authenticated cookie:

```bash
curl --silent \
  --request DELETE \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  "http://localhost:3000/api/projects/${PROJECT_ID}"
```

Expected output:

```text
204
```

## The Verification

Confirm no API accepts a client-supplied owner:

```bash
grep -R \
  'ownerId\|owner_id' \
  src/app/api \
  --include="*.ts" || true
```

The API route handlers should not read an owner ID from JSON or query strings.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 8, Step 14: Authenticated API Ownership] [STARTING: Part 8, Step 15: Cross-User Authorization Verification]

---

# Step 15: Verify Cross-User Isolation

## The Target

Create a second account and prove that it cannot read or mutate the demo user’s projects.

## The Concept

The strongest authorization test uses two distinct users.

We will verify:

- User A can access User A’s project.
- User B cannot access User A’s project.
- User B’s project list excludes User A’s project.
- User B cannot update or delete User A’s project through the API.

This tests actual data isolation rather than merely checking that a button is hidden.

## The Implementation

Create a second user through:

```text
http://localhost:3000/sign-up
```

Use:

```text
Name: Second User
Email: second@launchpad.local
Password: SecondUser123!
Confirm password: SecondUser123!
```

After registration, the browser signs in as the second user.

The second user’s dashboard should show:

```text
0 projects
0 tasks
```

Copy the second user’s session cookie from browser developer tools:

```bash
SECOND_SESSION_TOKEN='paste-second-user-cookie-here'
```

The demo user owns this seeded project:

```text
10000000-0000-4000-8000-000000000001
```

Attempt to read it:

```bash
curl --silent \
  --header "Cookie: launchpad_session=${SECOND_SESSION_TOKEN}" \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects/10000000-0000-4000-8000-000000000001
```

Expected output:

```text
404
```

Attempt to update it:

```bash
curl --silent \
  --request PATCH \
  --header "Cookie: launchpad_session=${SECOND_SESSION_TOKEN}" \
  --header "Content-Type: application/json" \
  --data '{
    "status": "COMPLETED"
  }' \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects/10000000-0000-4000-8000-000000000001
```

Expected output:

```text
404
```

Attempt to delete it:

```bash
curl --silent \
  --request DELETE \
  --header "Cookie: launchpad_session=${SECOND_SESSION_TOKEN}" \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects/10000000-0000-4000-8000-000000000001
```

Expected output:

```text
404
```

Verify the original record remains:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT name, status
    FROM projects
    WHERE id = '10000000-0000-4000-8000-000000000001';
  "
```

Expected output still contains:

```text
Website redesign | ACTIVE
```

Create a project while signed in as the second user. Confirm only that project appears in the second user’s workspace.

## The Verification

Inspect project ownership directly:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      u.email,
      COUNT(p.id) AS project_count
    FROM users AS u
    LEFT JOIN projects AS p
      ON p.owner_id = u.id
    GROUP BY u.id
    ORDER BY u.email;
  "
```

Expected result:

- Demo user owns the seeded projects.
- Second user owns only projects created while signed in as the second user.

Test the browser route directly:

```text
http://localhost:3000/projects/10000000-0000-4000-8000-000000000001
```

While signed in as the second user, it should return the not-found interface.

This is intentional: LaunchPad does not disclose another user’s private record.

[GENERATED: Part 8, Step 15: Cross-User Authorization] [STARTING: Part 8, Step 16: State Management Verification]

---

# Step 16: Verify State Ownership

## The Target

Confirm that LaunchPad uses server state, URL state, and local client state for appropriate responsibilities.

## The Concept

State management is not synonymous with adding a global state library.

State should live as close as possible to its authoritative owner.

### Server state

PostgreSQL owns:

- Users
- Sessions
- Projects
- Tasks
- Ownership
- Task status

The server renders current authoritative values.

### URL state

The URL owns shareable project filtering:

```text
/projects?status=ACTIVE
```

It survives refresh, supports browser history, and can be shared.

### Local client state

Client Components own temporary interface behavior:

- Project search text
- Disclosure open or closed state
- Copy-link feedback
- Pending form state

These values do not need a global store.

## The Implementation

No new files are required.

Verify the project status filter remains URL-backed:

```text
http://localhost:3000/projects?status=ACTIVE
```

Verify project search remains local:

1. Enter `website`.
2. Refresh.
3. Confirm the search resets.
4. Confirm `status=ACTIVE` remains in the URL.

Verify session state remains server-owned:

1. Open browser developer tools.
2. Confirm the cookie is HTTP-only.
3. Confirm no password or user object is stored in `localStorage`.
4. Confirm signing out deletes the server session.

Inspect local storage from the browser console:

```js
Object.keys(localStorage)
```

LaunchPad should not store credentials or session tokens there.

## The Verification

Confirm no global client state package was added:

```bash
npm ls redux zustand jotai recoil 2>/dev/null || true
```

It is valid for the command to report that none are installed.

Confirm browser code does not read the session cookie:

```bash
grep -R \
  'document.cookie\|localStorage.*session\|launchpad_session' \
  src \
  --include="*.ts" \
  --include="*.tsx" || true
```

The cookie name should appear only in the server-only session module.

[GENERATED: Part 8, Step 16: State Ownership] [STARTING: Part 8, Step 17: Reset and Repeatable Seed]

---

# Step 17: Make the Development Seed Authentication-Aware

## The Target

Ensure reseeding restores the demo account, clears sessions, removes test users, and recreates deterministic owned projects.

## The Concept

The Part 5 seed assumed the user migration had already created the demo account. Authentication testing added users and sessions, so the seed should now reset those records deliberately.

The correct deletion order is:

```text
sessions
tasks
projects
non-demo users
```

The demo user remains because deterministic projects reference it.

We will reset the demo user’s password and profile so the documented credentials always work.

## The Implementation

At the beginning of:

### `database/seeds/development.sql`

replace the existing opening deletion section:

```sql
BEGIN;

DELETE FROM tasks;
DELETE FROM projects;
```

with:

```sql
BEGIN;

DELETE FROM sessions;
DELETE FROM tasks;
DELETE FROM projects;

DELETE FROM users
WHERE id <> '30000000-0000-4000-8000-000000000001';

INSERT INTO users (
  id,
  name,
  email,
  password_hash
)
VALUES (
  '30000000-0000-4000-8000-000000000001',
  'Demo User',
  'demo@launchpad.local',
  crypt(
    'LaunchPadDemo123!',
    gen_salt('bf', 12)
  )
)
ON CONFLICT (id)
DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  updated_at = CURRENT_TIMESTAMP;
```

Keep the updated project inserts with `owner_id` from Step 2.

Run:

```bash
npm run db:seed
```

## The Verification

Verify deterministic counts:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      (SELECT COUNT(*) FROM users) AS users,
      (SELECT COUNT(*) FROM sessions) AS sessions,
      (SELECT COUNT(*) FROM projects) AS projects,
      (SELECT COUNT(*) FROM tasks) AS tasks;
  "
```

Expected output:

```text
1 | 0 | 4 | 12
```

Verify the documented password:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      password_hash = crypt(
        'LaunchPadDemo123!',
        password_hash
      ) AS password_matches
    FROM users
    WHERE email = 'demo@launchpad.local';
  "
```

Expected output:

```text
t
```

Because sessions were deleted, any previously signed-in browser should be treated as signed out on its next authenticated request.

[GENERATED: Part 8, Step 17: Authentication-Aware Seed] [STARTING: Part 8, Step 18: End-to-End Security Verification]

---

# Step 18: Run the End-to-End Security Verification

## The Target

Verify anonymous access, authenticated access, ownership, session persistence, and protected mutations from a clean seed.

## The Concept

Security checks must cover both positive and negative cases.

Positive case:

```text
Authenticated owner → operation succeeds
```

Negative cases:

```text
Anonymous caller → rejected
Authenticated non-owner → hidden or rejected
Invalid session → rejected
Expired session → rejected
```

## The Implementation

Reset the database and start the application:

```bash
npm run db:seed
npm run dev
```

### Anonymous page access

```bash
for path in \
  "/dashboard" \
  "/projects" \
  "/projects/new"
do
  result="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code} %{redirect_url}" \
      "http://localhost:3000${path}"
  )"

  printf "%-30s %s\n" "${path}" "${result}"
done
```

Each route should redirect to `/sign-in`.

### Anonymous API access

```bash
for path in \
  "/api/projects" \
  "/api/projects/10000000-0000-4000-8000-000000000001"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-75s %s\n" "${path}" "${status_code}"
done
```

Expected status:

```text
401
```

### Public routes

```bash
for path in \
  "/" \
  "/about" \
  "/features" \
  "/sign-in" \
  "/sign-up" \
  "/api/health"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-30s %s\n" "${path}" "${status_code}"
done
```

Expected status:

```text
200
```

### Authenticated browser flow

In the browser:

1. Sign in with the demo account.
2. Confirm `/dashboard` loads.
3. Confirm four projects appear.
4. Create a project.
5. Confirm the project belongs to the demo user.
6. Add a task.
7. Update the task status.
8. Sign out.
9. Confirm protected routes redirect.

### Expired-session test

Sign in, then expire sessions directly:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    UPDATE sessions
    SET expires_at = CURRENT_TIMESTAMP - INTERVAL '1 minute';
  "
```

Refresh `/dashboard`.

Expected behavior:

```text
Redirect to /sign-in
```

The expired cookie may remain in the browser until its cookie expiration time, but the server must reject it because the database session has expired.

Clean expired sessions:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    DELETE FROM sessions
    WHERE expires_at <= CURRENT_TIMESTAMP;
  "
```

## The Verification

Run static checks for ownership conditions:

```bash
grep -R \
  'owner_id = \${userId}' \
  src/lib/database \
  --include="*.ts"
```

Expected matches should appear across project reads and mutations.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 8, Step 18: End-to-End Security Verification] [STARTING: Part 8, Step 19: Production Build]

---

# Step 19: Verify the Production Build

## The Target

Build and run the authenticated application in production mode.

## The Concept

Production mode changes session-cookie behavior:

```ts
secure: process.env.NODE_ENV === "production"
```

A Secure cookie is intended for HTTPS. When testing `npm run start` at plain `http://localhost`, browser handling can vary by environment.

The production build can still verify compilation, public routes, redirects, and anonymous API behavior locally. Complete authenticated cookie verification should occur on an HTTPS deployment in Part 10.

## The Implementation

Stop the development server:

```text
Ctrl+C
```

Reset deterministic data:

```bash
npm run db:seed
```

Run:

```bash
npm run typecheck
npm run lint
npm run build
```

Start the production server:

```bash
npm run start
```

## The Verification

Verify public routes:

```bash
for path in \
  "/" \
  "/about" \
  "/sign-in" \
  "/sign-up" \
  "/api/health"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-30s %s\n" "${path}" "${status_code}"
done
```

Every route should return:

```text
200
```

Verify protected pages redirect:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code} %{redirect_url}\n" \
  http://localhost:3000/dashboard
```

The destination must be:

```text
/sign-in
```

Verify protected API rejection:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected output:

```text
401
```

Verify the health endpoint remains dynamic and available:

```bash
curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 8, Step 19: Production Build] [STARTING: Part 8, Step 20: Git Checkpoint]

---

# Step 20: Create the Part 8 Git Checkpoint

## The Target

Commit user accounts, sessions, protected routes, authorization conditions, authentication forms, and owner-scoped APIs.

## The Concept

This checkpoint adds a security boundary across the complete application.

The commit should include:

- User and session migration
- Authentication-aware seed updates
- `bcryptjs`
- Account and session modules
- Sign-in and registration actions
- Authentication pages
- Protected workspace layout
- Owner-scoped queries
- Owner-scoped mutations
- Authenticated APIs
- Authentication styles

It must not contain a session token or `.env.local`.

## The Implementation

Inspect the repository:

```bash
git status
git diff --stat
git diff
```

Search for accidentally pasted session tokens:

```bash
git grep 'SESSION_TOKEN=' || true
```

No real token should appear.

Run the final quality gate:

```bash
npm run typecheck
npm run lint
npm run build
```

Stage the changes:

```bash
git add \
  database \
  package.json \
  package-lock.json \
  src
```

Inspect staged files:

```bash
git diff --cached --stat
git status --short
```

Create the commit:

```bash
git commit -m "feat: add authentication and owner authorization"
```

## The Verification

Inspect the commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
e5f6a7b feat: add authentication and owner authorization
```

Confirm a clean working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 8, Step 20: Git Checkpoint] [STARTING: Part 8 Reference Sections]

---

# Part 8 Reference A: Authentication Versus Authorization

Authentication establishes identity:

```text
Cookie → Session → User
```

Authorization applies rules to that identity:

```text
User + Project → May this user read or change it?
```

A user may be correctly authenticated but unauthorized to access another user’s project.

Every protected operation needs both checks.

---

# Part 8 Reference B: Why Passwords Are Hashed

Passwords must not be stored as plaintext.

Incorrect:

```text
password = LaunchPadDemo123!
```

Correct conceptual storage:

```text
password_hash = bcrypt(password, salt, work factor)
```

A password hash is:

- One-way
- Salted
- Intentionally expensive to calculate
- Verified by comparison rather than decryption

The bcrypt cost used here is:

```text
12
```

Higher cost increases attack expense but also increases legitimate server work. Production teams should benchmark password hashing on their infrastructure and revisit the cost over time.

---

# Part 8 Reference C: Password Hashing Versus Session Hashing

Passwords and random session tokens have different properties.

## Password

Human-created passwords may have limited entropy. They need a slow password-hashing algorithm such as bcrypt, Argon2id, or scrypt.

## Session token

A session token is generated from 32 cryptographically random bytes. It already has high entropy.

SHA-256 is appropriate for creating a database lookup hash for such a token:

```ts
createHash("sha256")
  .update(token)
  .digest("hex");
```

Do not use plain SHA-256 as a replacement for password hashing.

---

# Part 8 Reference D: Cookie Attributes

LaunchPad’s session cookie uses:

```ts
{
  httpOnly: true,
  secure: process.env.NODE_ENV === "production",
  sameSite: "lax",
  path: "/",
  expires: expiresAt,
}
```

## `httpOnly`

Prevents ordinary browser JavaScript from reading the cookie.

It helps reduce session theft through some cross-site scripting attacks, but it does not make XSS harmless. Malicious JavaScript may still send authenticated requests from the compromised page.

## `secure`

Restricts transmission to HTTPS.

Production must use HTTPS.

## `sameSite`

Controls cross-site cookie sending. `lax` provides useful CSRF resistance while supporting ordinary top-level navigation.

## `path`

`/` makes the cookie available throughout the application.

## `expires`

Creates a persistent cookie with a defined expiration date.

The database expiration remains authoritative.

---

# Part 8 Reference E: Session Expiration and Rotation

LaunchPad sessions last seven days.

Production systems may also need:

- Idle expiration
- Absolute expiration
- Session rotation after privilege changes
- Rotation after password changes
- Revocation of all sessions
- Device and session management
- Suspicious-login detection

A session should be replaced after sensitive identity transitions to reduce session-fixation risk.

LaunchPad creates a fresh random session after sign-in and registration.

---

# Part 8 Reference F: Why Sessions Are Stored in PostgreSQL

Database sessions support:

- Immediate revocation
- Server-side expiration
- Sign-out
- Multi-device session tracking
- Administrative invalidation
- Audit extensions

Trade-offs include:

- A database lookup during authenticated requests
- Session-table cleanup
- Database availability requirements

Signed self-contained tokens can reduce lookup requirements but make immediate revocation and state changes more complex.

Neither architecture is universally best. LaunchPad chooses database sessions because correctness and revocation clarity are more important than eliminating a small indexed lookup.

---

# Part 8 Reference G: Owner-Scoped SQL

Authorization belongs in read and write queries.

Read:

```sql
SELECT *
FROM projects
WHERE id = $project_id
  AND owner_id = $user_id;
```

Update:

```sql
UPDATE projects
SET status = $status
WHERE id = $project_id
  AND owner_id = $user_id;
```

Delete:

```sql
DELETE FROM projects
WHERE id = $project_id
  AND owner_id = $user_id;
```

Task update through project ownership:

```sql
UPDATE tasks AS t
SET status = $status
FROM projects AS p
WHERE t.id = $task_id
  AND t.project_id = $project_id
  AND p.id = t.project_id
  AND p.owner_id = $user_id;
```

This is stronger than checking only in page code.

---

# Part 8 Reference H: Why Unauthorized Private Records Return 404

Suppose a user requests another user’s project.

Returning:

```text
403 Forbidden
```

confirms that the project exists.

Returning:

```text
404 Not Found
```

does not distinguish between:

- A nonexistent project
- A project the caller may not discover

This is useful for private resources.

Not every system should hide every resource’s existence. Public resources with restricted operations may appropriately return `403`. Choose based on the product’s disclosure rules.

---

# Part 8 Reference I: Protected Layouts Are Not Enough

The workspace layout calls:

```ts
await requireUser();
```

That protects normal route rendering, but it does not replace checks in:

- Route Handlers
- Server Actions
- Database query functions
- Database mutation functions
- Background jobs
- Future integrations

Attackers do not need to use the application’s visible navigation.

Defense in depth means every server entry point authenticates and every protected data operation authorizes.

---

# Part 8 Reference J: State Management Decisions

LaunchPad does not need a global browser state library yet.

## Server state

Keep authoritative records on the server:

- User identity
- Sessions
- Project ownership
- Projects
- Tasks

## URL state

Use URLs for shareable navigation state:

```text
/projects?status=ACTIVE
```

## Local state

Use component state for temporary interaction:

```tsx
const [query, setQuery] = useState("");
```

## When a client state library may become useful

A client state library may help when:

- Many distant Client Components coordinate ephemeral state
- Complex client-only workflows need reducers or stores
- Offline editing requires a synchronized local model
- Optimistic updates span several components

Do not add global state merely because an application is large. First identify which state is duplicated and who should own it.

---

# Part 8 Reference K: CSRF Considerations

**Cross-Site Request Forgery**, or CSRF, causes a browser to send an authenticated request from an untrusted site.

LaunchPad uses several defenses:

- `SameSite=Lax` cookies
- JSON content-type requirements on mutation APIs
- Server Actions integrated with Next.js request handling
- No state-changing GET routes

A high-risk production application may additionally require explicit CSRF tokens or strict origin verification, especially when:

- Cross-site cookie behavior is required
- Forms are exposed across origins
- Legacy clients submit form-encoded API mutations
- Browser compatibility requirements weaken SameSite protection

Authentication cookies should never make GET requests mutate data.

---

# Part 8 Reference L: Brute-Force Protection

The tutorial validates credentials but does not yet implement distributed sign-in rate limiting.

A public production system needs controls such as:

- Per-IP rate limits
- Per-account throttling
- Progressive delays
- Suspicious-login monitoring
- Abuse detection
- Optional multi-factor authentication

Rate limits must work across application instances. In-memory counters inside one Node.js process are insufficient when production runs several instances.

Part 10 will identify this as a production requirement rather than falsely presenting the current sign-in flow as abuse-resistant.

---

# Part 8 Reference M: Account Enumeration

Account enumeration occurs when responses reveal whether an account exists.

Unsafe sign-in messages:

```text
No account exists for that email.
The password is incorrect.
```

Safer response:

```text
The email or password is incorrect.
```

Registration is harder because duplicate email addresses must be handled. LaunchPad uses a restrained message:

```text
An account cannot be created with that email address.
```

Production systems may send account-related guidance by email rather than disclosing details in the browser.

---

# Part 8 Reference N: Session Cleanup

Expired sessions remain in the database until removed.

LaunchPad includes:

```ts
deleteExpiredSessions()
```

A production system should run cleanup on a schedule:

```sql
DELETE FROM sessions
WHERE expires_at <= CURRENT_TIMESTAMP;
```

Possible scheduling mechanisms include:

- Deployment-platform cron
- A database scheduler
- A background worker
- A managed job service

Do not run a full cleanup synchronously on every request.

---

# Part 8 Reference O: Authentication Libraries

This tutorial implements database sessions directly to expose the underlying architecture.

Production teams should also evaluate maintained authentication libraries and managed identity providers.

Potential capabilities include:

- OAuth and OpenID Connect
- Passwordless sign-in
- Email verification
- Multi-factor authentication
- Account recovery
- Session rotation
- Provider linking
- Enterprise identity integration

Using a library does not eliminate architectural responsibility. You still need:

- Correct authorization
- Secure configuration
- Database ownership rules
- Error handling
- Operational monitoring
- Dependency updates

---

# Part 8 Reference P: Current Project Structure

After Part 8, important additions include:

```text
database/
└── migrations/
    └── 002_add_users_sessions_and_ownership.sql

src/
├── app/
│   ├── (auth)/
│   │   ├── actions.ts
│   │   ├── layout.tsx
│   │   ├── sign-in/
│   │   │   └── page.tsx
│   │   └── sign-up/
│   │       └── page.tsx
│   ├── (workspace)/
│   │   └── layout.tsx
│   └── api/
│       └── projects/
├── components/
│   ├── account-menu.tsx
│   ├── sign-in-form.tsx
│   ├── sign-up-form.tsx
│   └── ...
└── lib/
    ├── auth/
    │   ├── accounts.ts
    │   ├── session-store.ts
    │   └── session.ts
    ├── auth-inputs.ts
    ├── auth-types.ts
    └── database/
        ├── project-mutations.ts
        └── project-queries.ts
```

The security flow is:

```text
HTTP-only cookie
      ↓
Hashed session lookup
      ↓
Authenticated user
      ↓
User ID passed to query or mutation
      ↓
owner_id condition in SQL
```

---

# Part 8 Reference Q: Common Authentication Mistakes

## Mistake 1: Storing plaintext passwords

Always use a maintained password-hashing algorithm.

## Mistake 2: Storing raw session tokens

Store a token hash so database contents cannot be copied directly into cookies.

## Mistake 3: Putting session tokens in local storage

HTTP-only cookies reduce direct JavaScript access.

## Mistake 4: Protecting only pages

APIs and Server Actions remain directly callable.

## Mistake 5: Hiding unauthorized buttons without protecting writes

Interface state is not a server authorization boundary.

## Mistake 6: Querying by resource ID without owner ID

Every private-resource query must include its ownership scope.

## Mistake 7: Trusting an `ownerId` from the client

Ownership comes from the authenticated session.

## Mistake 8: Returning different sign-in messages for unknown email and wrong password

That supports account enumeration.

## Mistake 9: Logging passwords or raw cookies

Credentials and bearer tokens must not enter logs.

## Mistake 10: Treating SameSite as complete CSRF protection

Use layered controls appropriate to the application’s risk.

## Mistake 11: Ignoring session revocation

A database-backed session should be deleted on sign-out and rejected after expiration.

## Mistake 12: Using authentication as authorization

Knowing who the user is does not prove they own a requested resource.

---

# Part 8 Completion Checklist

Before continuing, confirm every item:

- [ ] The user migration creates `users` and `sessions`.
- [ ] Projects have a required `owner_id`.
- [ ] Existing seeded projects belong to the demo user.
- [ ] Passwords are stored as bcrypt hashes.
- [ ] Session tokens use cryptographically random bytes.
- [ ] PostgreSQL stores only session-token hashes.
- [ ] Session cookies are HTTP-only.
- [ ] Production session cookies are Secure.
- [ ] Session cookies use SameSite Lax.
- [ ] Sign-in validates credentials on the server.
- [ ] Sign-in uses a generic invalid-credentials message.
- [ ] Registration normalizes email addresses.
- [ ] Duplicate registration fails safely.
- [ ] Successful authentication redirects to `/dashboard`.
- [ ] Signed-in users are redirected away from auth pages.
- [ ] Sign-out deletes the database session.
- [ ] Sign-out expires the browser cookie.
- [ ] Anonymous workspace access redirects to `/sign-in`.
- [ ] Anonymous project API access returns `401`.
- [ ] The health endpoint remains public.
- [ ] Every project read query requires `userId`.
- [ ] Every task read query verifies project ownership.
- [ ] Every mutation requires `userId`.
- [ ] Project writes include `owner_id` authorization.
- [ ] Task writes authorize through the owning project.
- [ ] A user cannot supply an arbitrary owner ID.
- [ ] Cross-user reads return `404`.
- [ ] Cross-user updates return `404`.
- [ ] Cross-user deletes return `404`.
- [ ] The second user sees only their own records.
- [ ] URL state remains shareable.
- [ ] Temporary search remains local state.
- [ ] Authoritative records remain server state.
- [ ] No credentials are stored in local storage.
- [ ] The authentication-aware seed restores one user, zero sessions, four projects, and twelve tasks.
- [ ] Expired database sessions are rejected.
- [ ] `npm run typecheck` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] Anonymous production-mode security checks succeed.
- [ ] Git contains the Part 8 checkpoint.
- [ ] No session token or `.env.local` is committed.
- [ ] `git status` reports a clean working tree.

LaunchPad now identifies users, stores revocable server-side sessions, protects workspace routes and APIs, and enforces project ownership in SQL. State is kept at the appropriate boundary: PostgreSQL owns authoritative records, URLs own shareable filters, and focused Client Components own temporary interaction state.
