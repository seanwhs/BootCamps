# Primer 19: APIs, HTTP Requests, and Webhook Basics

GitHub is more than a website. It also provides an **API**: an Application Programming Interface.

An API lets software communicate with GitHub programmatically.

For example, the GitHub CLI (`gh`) uses GitHub’s API when it creates:

```bash
gh issue create
gh pr create
gh release create
```

GitHub Actions can also use APIs to create releases, add comments, update labels, or report deployment status.

This primer explains the basics of web APIs and HTTP requests so later automation, integrations, and GitHub CLI commands feel less mysterious.

You will learn:

- What an API is.
- What HTTP requests and responses are.
- The meaning of common HTTP methods and status codes.
- How authentication tokens fit into API access.
- What JSON is.
- What webhooks are.
- Why incoming webhook data must be treated as untrusted.

---

# P19.1 Understand What an API Is

## The Target

Understand how software communicates with GitHub and other online services.

## The Concept

An **API** is a documented interface that lets one program request information or actions from another program.

Think of a restaurant:

```text
Customer        → asks for food
Waiter          → carries the request
Kitchen         → prepares the result
Waiter          → returns the result
```

In API terms:

```text
Your script or CLI       → client
API request              → order
GitHub API               → service
API response             → result
```

For example, GitHub CLI can ask GitHub:

```text
“List the open pull requests in this repository.”
```

The CLI command is:

```bash
gh pr list
```

Behind the scenes, GitHub CLI sends an API request and formats GitHub’s response for your terminal.

## The Implementation

Run this read-only GitHub CLI command from a GitHub-connected repository:

```bash
gh repo view --json name,owner,url,visibility
```

If GitHub CLI is not installed or authenticated, review Primer 5 and Appendix S first.

## The Verification

Expected output resembles:

```json
{
  "name": "release-notes-manager",
  "owner": {
    "login": "YOUR_GITHUB_USERNAME"
  },
  "url": "https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager",
  "visibility": "PUBLIC"
}
```

This is API data displayed as JSON.

---

# P19.2 Understand HTTP Requests

## The Target

Learn the basic parts of an HTTP request.

## The Concept

**HTTP** is the protocol—an agreed set of communication rules—used by web browsers, APIs, and many online services.

An HTTP request usually includes:

```text
Method
URL
Headers
Optional body
```

Example conceptual request:

```text
GET https://api.github.com/repos/OWNER/REPOSITORY
Authorization: Bearer TOKEN
Accept: application/vnd.github+json
```

Breakdown:

| Part | Meaning |
|---|---|
| `GET` | Request data without changing it |
| URL | The API location being requested |
| `Authorization` header | Credential proving the caller has access |
| `Accept` header | Requested response format |

The request body is typically used when creating or changing something.

For example, creating an issue may send a JSON body:

```json
{
  "title": "Add export documentation",
  "body": "Document how to save generated Markdown."
}
```

## The Implementation

Use `gh api` to make a safe read-only request.

Replace `YOUR_GITHUB_USERNAME`:

```bash
gh api repos/YOUR_GITHUB_USERNAME/release-notes-manager \
  --jq '{name: .name, default_branch: .default_branch, visibility: .visibility}'
```

## The Verification

Expected output resembles:

```json
{
  "default_branch": "main",
  "name": "release-notes-manager",
  "visibility": "public"
}
```

The command requested repository data. It did not modify the repository.

---

# P19.3 Understand HTTP Methods

## The Target

Recognize the common HTTP methods used by APIs.

## The Concept

An HTTP method tells the API what kind of operation you are requesting.

| Method | Typical purpose | Everyday analogy |
|---|---|---|
| `GET` | Read information | Read a record |
| `POST` | Create something or trigger an action | Submit a new form |
| `PUT` | Replace a resource | Replace a full document |
| `PATCH` | Update part of a resource | Edit selected fields |
| `DELETE` | Remove a resource | Discard a record |

GitHub API examples:

```text
GET
    List pull requests.

POST
    Create an issue.

PATCH
    Update an issue title or state.

DELETE
    Delete a release asset.
```

Methods that change data deserve more caution than read-only `GET` requests.

## The Implementation

Inspect open pull requests with a safe `GET` request:

```bash
gh api repos/YOUR_GITHUB_USERNAME/release-notes-manager/pulls \
  --jq '.[] | {number: .number, title: .title, state: .state}'
```

Do not run destructive API requests as a learning exercise.

For reference, creating an issue with an API request would use `POST`:

```bash
gh api \
  --method POST \
  repos/YOUR_GITHUB_USERNAME/release-notes-manager/issues \
  -f title="Example issue title" \
  -f body="Example issue body"
```

Use `gh issue create` for ordinary issue creation because it is easier to read and less error-prone.

## The Verification

Confirm this safety distinction:

```text
GET:
Usually reads data.

POST, PUT, PATCH, DELETE:
May create, change, or remove GitHub resources.
Review endpoint and parameters carefully.
```

---

# P19.4 Understand HTTP Status Codes

## The Target

Interpret the common numeric response codes returned by web services.

## The Concept

An HTTP response includes a status code that summarizes the result.

| Status range | Meaning |
|---:|---|
| `200–299` | Request succeeded |
| `300–399` | Redirect or related response |
| `400–499` | Problem with request, authentication, authorization, or missing resource |
| `500–599` | Server-side service problem |

Common codes:

| Code | Meaning | Typical cause |
|---:|---|---|
| `200 OK` | Successful read or update | Request succeeded |
| `201 Created` | Resource created successfully | New issue, release, or comment created |
| `204 No Content` | Successful action with no response body | Some delete or update operations |
| `400 Bad Request` | Request format is invalid | Invalid JSON or missing required field |
| `401 Unauthorized` | Missing or invalid authentication | Expired or absent token |
| `403 Forbidden` | Authenticated but not allowed | Token lacks permission or rate limit reached |
| `404 Not Found` | Resource does not exist or is inaccessible | Wrong URL or insufficient access |
| `422 Unprocessable Entity` | Valid request structure but invalid requested change | Duplicate tag, invalid field, unmet rule |
| `500 Internal Server Error` | Service-side failure | Retry later or inspect service status |

## The Implementation

Make a read-only request while showing response headers:

```bash
gh api -i repos/YOUR_GITHUB_USERNAME/release-notes-manager
```

The `-i` option includes HTTP response headers.

## The Verification

Look near the top of output for a response line similar to:

```text
HTTP/2.0 200 OK
```

This confirms the request succeeded.

If you receive:

```text
HTTP 401
```

review GitHub CLI authentication:

```bash
gh auth status
```

If you receive:

```text
HTTP 404
```

verify the repository owner and name.

---

# P19.5 Understand JSON

## The Target

Read the JSON format commonly used by APIs.

## The Concept

**JSON**, JavaScript Object Notation, is a text format for structured data.

Example:

```json
{
  "title": "Add release note export",
  "state": "open",
  "labels": ["enhancement", "documentation"]
}
```

JSON uses:

| Syntax | Meaning |
|---|---|
| `{ }` | Object: named fields and values |
| `[ ]` | Array: ordered list of values |
| `"text"` | String |
| `true` / `false` | Boolean value |
| `null` | Explicitly no value |
| `:` | Separates field name from value |
| `,` | Separates fields or array items |

Unlike JavaScript objects, JSON requires double quotes around keys and string values.

Invalid JSON:

```js
{
  title: 'Missing required quotes'
}
```

Valid JSON:

```json
{
  "title": "Uses double quotes"
}
```

## The Implementation

Request issue data as JSON:

```bash
gh issue list --json number,title,state,labels
```

If the repository has no open issues, the output may be:

```json
[]
```

Use GitHub CLI’s `--jq` filter to display selected values more simply:

```bash
gh issue list --json number,title,state \
  --jq '.[] | "#\(.number) [\(.state)] \(.title)"'
```

## The Verification

Expected output resembles:

```text
#12 [OPEN] Document release note file export example
```

You should now recognize that GitHub CLI often receives JSON, then formats it for a human-readable terminal display.

---

# P19.6 Understand Authentication Headers and Tokens

## The Target

Understand why API access needs credentials and why those credentials must remain secret.

## The Concept

An API often needs to know:

```text
Who is making this request?
What are they allowed to do?
```

Authentication proves identity.

Authorization determines allowed actions.

For example:

```text
Token belongs to Jordan.
    ↓
GitHub checks token permissions.
    ↓
Jordan may read this repository.
Jordan may create issues.
Jordan may not change organization settings.
```

A common API pattern is:

```text
Authorization: Bearer TOKEN_VALUE
```

Never paste a real token directly into scripts, source files, or terminal history.

Use secure tools instead:

```text
GitHub CLI authentication
GitHub Actions secrets
Operating-system credential manager
Password manager
Environment variables for temporary local use
```

## The Implementation

Inspect GitHub CLI authentication without exposing token values:

```bash
gh auth status
```

Inspect the scopes available to the current authentication session:

```bash
gh auth status --show-token
```

Do **not** run `--show-token` in shared terminals, screen recordings, public logs, or screenshots. Prefer ordinary `gh auth status`.

## The Verification

Confirm the difference:

```text
Authentication:
Who are you?

Authorization:
What may you do?

Token:
A sensitive credential used to authenticate API access.
```

---

# P19.7 Understand Rate Limits

## The Target

Recognize why repeated API requests may eventually be limited.

## The Concept

APIs often limit how many requests an account or application can make within a time window.

This is called **rate limiting**.

Rate limits help protect services from accidental loops, abusive automation, and overload.

GitHub API responses commonly include headers such as:

```text
X-RateLimit-Limit
X-RateLimit-Remaining
X-RateLimit-Reset
```

If a script makes too many requests, GitHub may return:

```text
403 Forbidden
```

with information indicating a rate limit was exceeded.

## The Implementation

Inspect current API rate-limit information:

```bash
gh api rate_limit \
  --jq '.resources.core | {limit: .limit, remaining: .remaining, reset: .reset}'
```

The `reset` value is a Unix timestamp.

To display it as a date on macOS or Linux:

```bash
date -r "$(gh api rate_limit --jq '.resources.core.reset')"
```

On Linux systems where `date -r` is unavailable:

```bash
date -d "@$(gh api rate_limit --jq '.resources.core.reset')"
```

On Windows PowerShell:

```powershell
$reset = gh api rate_limit --jq '.resources.core.reset'
[DateTimeOffset]::FromUnixTimeSeconds([int64]$reset).LocalDateTime
```

## The Verification

Expected JSON resembles:

```json
{
  "limit": 5000,
  "remaining": 4990,
  "reset": 1780000000
}
```

The exact values differ.

If automation must make many API calls, design it to:

```text
Use pagination.
Avoid unnecessary repeated requests.
Respect rate-limit responses.
Retry with backoff when appropriate.
```

---

# P19.8 Understand Webhooks

## The Target

Understand how GitHub can notify another service when repository events happen.

## The Concept

A **webhook** is an outgoing notification sent by one service to another service’s URL.

For example:

```text
A pull request opens on GitHub
    ↓
GitHub sends an HTTP POST request
    ↓
Your external service receives event data
    ↓
The service performs a related action
```

Possible webhook events include:

```text
push
pull_request
issues
release
workflow_run
```

Think of a webhook as a doorbell:

```text
GitHub event happens
    ↓
GitHub rings your service's endpoint
    ↓
Your service decides what to do
```

Webhooks differ from polling.

```text
Polling:
Your application repeatedly asks GitHub, “Did anything change?”

Webhook:
GitHub tells your application when something changes.
```

## The Implementation

Do not create a public webhook endpoint for practice unless you understand network exposure and signature verification.

Inspect repository webhooks through GitHub:

```text
Repository → Settings → Webhooks
```

If GitHub CLI authentication has sufficient permission, inspect hooks read-only:

```bash
gh api repos/YOUR_GITHUB_USERNAME/release-notes-manager/hooks \
  --jq '.[] | {id: .id, active: .active, events: .events, url: .config.url}'
```

Do not print private endpoint URLs in public logs if they contain sensitive information.

## The Verification

Confirm you can explain:

```text
GitHub Actions:
Automation runs inside GitHub's hosted environment.

Webhook:
GitHub sends an event notification to an external service you operate.
```

---

# P19.9 Verify Webhook Signatures

## The Target

Understand why incoming webhook requests must be authenticated.

## The Concept

A public endpoint can receive requests from anyone on the internet.

Without verification, an attacker could send a fake request that looks like:

```text
“GitHub says a release was published.”
```

A webhook secret lets GitHub sign the request.

Your receiving service verifies the signature before trusting the event.

The safe flow:

```text
GitHub sends webhook payload
    +
Signature header
    ↓
Your service calculates expected signature using shared secret
    ↓
Compare signatures safely
    ↓
Process event only if they match
```

Never trust:

- Event JSON alone.
- A claimed username in a payload.
- A request merely because it came from a familiar-looking IP address.
- A webhook endpoint that has no signature verification.

## The Implementation

A conceptual Node.js signature-verification function looks like this:

### `verifyWebhookSignature.js`

```js
import crypto from "node:crypto";

/**
 * Verifies a GitHub webhook signature using HMAC SHA-256.
 *
 * The raw request body must be used exactly as received. Parsing and then
 * re-serializing JSON can change whitespace or key ordering, producing a
 * different signature.
 *
 * @param {string} rawBody - The unmodified incoming request body.
 * @param {string | undefined} signatureHeader - The X-Hub-Signature-256 value.
 * @param {string} webhookSecret - The shared webhook secret.
 * @returns {boolean} Whether the signature is valid.
 */
export function verifyWebhookSignature(
  rawBody,
  signatureHeader,
  webhookSecret
) {
  if (
    typeof rawBody !== "string" ||
    typeof signatureHeader !== "string" ||
    typeof webhookSecret !== "string" ||
    webhookSecret.length === 0
  ) {
    return false;
  }

  const expectedSignature = `sha256=${crypto
    .createHmac("sha256", webhookSecret)
    .update(rawBody, "utf8")
    .digest("hex")}`;

  const receivedBuffer = Buffer.from(signatureHeader, "utf8");
  const expectedBuffer = Buffer.from(expectedSignature, "utf8");

  // timingSafeEqual prevents early-exit comparison behavior that could reveal
  // partial signature information through timing differences.
  return (
    receivedBuffer.length === expectedBuffer.length &&
    crypto.timingSafeEqual(receivedBuffer, expectedBuffer)
  );
}
```

Do not commit a webhook secret. Supply it through protected environment configuration.

## The Verification

Confirm the security rule:

```text
A webhook payload is untrusted until its signature is verified.
```

For a production webhook receiver, add tests for:

```text
[ ] Valid signature accepted.
[ ] Missing signature rejected.
[ ] Incorrect signature rejected.
[ ] Missing secret rejected.
[ ] Malformed payload handled safely.
```

---

# P19.10 Understand API and Webhook Safety Rules

## The Target

Use APIs and webhooks without exposing secrets or trusting unverified data.

## The Concept

API integrations combine code, credentials, and external input. Treat them as security-sensitive.

## The Implementation

Use this checklist:

```text
API requests
[ ] Use read-only GET requests when investigating.
[ ] Review POST, PATCH, PUT, and DELETE requests before running them.
[ ] Use least-privilege tokens.
[ ] Do not place tokens in source code, URLs, logs, or commit messages.
[ ] Handle 401, 403, 404, and 429 responses intentionally.
[ ] Respect rate limits.

Webhooks
[ ] Use a long random webhook secret.
[ ] Store the secret in protected configuration.
[ ] Verify signatures using the raw request body.
[ ] Reject invalid signatures.
[ ] Treat payload fields as untrusted input.
[ ] Log safe event metadata, not credentials or private payload contents.
[ ] Design webhook handlers to safely handle retries and duplicate events.
```

## The Verification

Before enabling an integration, answer:

```text
[ ] What API permissions does it need?
[ ] Where is its token stored?
[ ] What happens if the token is exposed?
[ ] What external input does it accept?
[ ] How does it verify webhook authenticity?
[ ] How does it handle API failure or rate limiting?
```

---

# Primer 19 Reference: GitHub API and CLI Commands

## Inspect Repository Metadata

```bash
gh repo view --json name,owner,url,visibility
```

## Make a Read-Only API Request

```bash
gh api repos/OWNER/REPOSITORY
```

## Include Response Headers

```bash
gh api -i repos/OWNER/REPOSITORY
```

## List Open Pull Requests Through the API

```bash
gh api repos/OWNER/REPOSITORY/pulls
```

## Inspect API Rate Limits

```bash
gh api rate_limit
```

## List Workflow Runs

```bash
gh run list
```

## Inspect CLI Authentication

```bash
gh auth status
```

---

# Primer 19 Completion Check

Before building GitHub integrations or automation that uses APIs, confirm that you can:

- [ ] Explain what an API is.
- [ ] Identify the method, URL, headers, and body of an HTTP request.
- [ ] Distinguish `GET` from changing methods such as `POST`, `PATCH`, and `DELETE`.
- [ ] Interpret common HTTP status codes.
- [ ] Read simple JSON objects and arrays.
- [ ] Explain authentication versus authorization.
- [ ] Treat API tokens as sensitive credentials.
- [ ] Explain API rate limiting.
- [ ] Explain the difference between polling and webhooks.
- [ ] State that webhook payloads must be verified with a signature before being trusted.
