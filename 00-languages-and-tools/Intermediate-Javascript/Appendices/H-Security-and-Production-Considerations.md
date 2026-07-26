# Appendix H: Security and Production Considerations

The Async Task Manager is a client-side learning application. It demonstrates important engineering practices, but a production application requires additional security controls.

This appendix explains:

- What browser code can and cannot protect.
- How to prevent unsafe HTML injection.
- How to validate untrusted data.
- How browser storage affects security.
- Why client-side validation is insufficient by itself.
- How to protect API requests.
- How to configure security headers.
- How to handle secrets.
- How to prepare the application for production deployment.

Security is not a single feature. It is a collection of habits that reduce the chance and impact of failure.

---

# 1. The Application Security Model

The final project runs entirely in the browser:

```text
Browser
├── HTML
├── CSS
├── JavaScript
├── localStorage
└── sessionStorage
```

This means the user controls the execution environment.

A user can:

- Open Developer Tools.
- Change JavaScript variables.
- Modify browser storage.
- Call application functions manually.
- Replay network requests.
- Disable JavaScript.
- Change form values.
- Use a modified browser.

Therefore, browser code can improve user experience and protect against accidental invalid input, but it cannot enforce server-side security rules.

---

# 2. Client-Side Validation Is Not Authorization

Client-side validation improves usability:

```javascript
function validateTaskTitle(title) {
  if (title.trim().length === 0) {
    throw new Error("Task title cannot be empty.");
  }
}
```

However, a user can bypass it:

```javascript
fetch("/api/tasks", {
  method: "POST",
  body: JSON.stringify({
    title: "",
  }),
});
```

If a server exists, it must validate independently.

The server must enforce:

- Required fields.
- Data types.
- Maximum lengths.
- User permissions.
- Ownership.
- Authentication.
- Authorization.
- Business rules.

A useful rule is:

```text
Client validation improves the experience.
Server validation protects the system.
```

---

# 3. Authentication Versus Authorization

These terms are related but different.

## Authentication

Authentication answers:

> Who is this user?

Examples:

- Password login.
- Passkey.
- Single sign-on.
- OAuth provider.
- Session cookie.

## Authorization

Authorization answers:

> What is this user allowed to do?

Examples:

- Can this user edit this task?
- Can this user delete this project?
- Can this user access this organization?
- Can this user view administrative settings?

Never assume that because a user is authenticated, they can perform every operation.

The server must verify resource ownership:

```text
User requests task 123
        ↓
Server authenticates the user
        ↓
Server checks whether task 123 belongs to that user
        ↓
Server allows or rejects the operation
```

---

# 4. Do Not Store Secrets in Browser Storage

Never store secrets in:

```javascript
localStorage
sessionStorage
```

Avoid storing:

- Passwords.
- Private API keys.
- Database credentials.
- Encryption keys.
- Long-lived access tokens.
- Payment card information.
- Private personal data.

Any JavaScript running in the page may be able to access these values.

An attacker who achieves cross-site scripting may read:

```javascript
localStorage.getItem("secret");
```

## Safer Pattern

Keep sensitive credentials on the server.

Use a server-managed session with appropriately configured cookies:

```text
HttpOnly
Secure
SameSite
```

An `HttpOnly` cookie cannot be read through ordinary JavaScript.

Cookie configuration is application- and framework-specific, but a production session cookie commonly requires:

- `HttpOnly`
- `Secure` over HTTPS
- Appropriate `SameSite`
- A narrow `Path`
- A controlled expiration

---

# 5. Cross-Site Scripting

Cross-site scripting, commonly abbreviated **XSS**, occurs when attacker-controlled content is interpreted as executable HTML or JavaScript.

## Unsafe Rendering

```javascript
taskElement.innerHTML = task.title;
```

If the task title contains:

```html
<img src="invalid" onerror="alert('XSS')">
```

the browser may interpret it as markup.

## Safe Plain-Text Rendering

```javascript
taskElement.textContent = task.title;
```

The final application correctly uses:

```javascript
title.textContent = task.title;
```

This displays the value as text.

---

# 6. Safe Attribute Assignment

Use DOM properties and attribute methods carefully.

This is safe for a normal text value:

```javascript
button.setAttribute(
  "aria-label",
  `Delete task: ${task.title}`
);
```

Avoid constructing large HTML strings with user input:

```javascript
container.innerHTML = `
  <button aria-label="Delete ${task.title}">
    Delete
  </button>
`;
```

If HTML must be generated dynamically:

- Avoid inserting untrusted values into HTML strings.
- Create elements with `document.createElement()`.
- Assign text with `textContent`.
- Assign attributes with `setAttribute()`.
- Sanitize trusted markup with a well-maintained sanitizer when necessary.

---

# 7. Avoid Dangerous DOM APIs

Be cautious with:

```javascript
element.innerHTML = untrustedValue;
element.outerHTML = untrustedValue;
document.write(untrustedValue);
```

Also avoid dynamically creating executable code:

```javascript
eval(userInput);
new Function(userInput);
setTimeout(userInput, 1000);
```

Use function callbacks instead:

```javascript
setTimeout(() => {
  performOperation();
}, 1000);
```

---

# 8. HTML Injection Test

Enter this task title:

```html
<script>alert("unexpected script")</script>
```

Then enter:

```html
<img src="invalid" onerror="alert('unexpected handler')">
```

## Expected Result

The application should display the characters as ordinary text.

It should not:

- Execute a script.
- Create an image element.
- Display an alert.
- Change the page structure.

Inspect the rendered element:

```javascript
document.querySelector(".task-title").innerHTML;
```

It may display escaped text or the browser’s serialized representation, but it should not contain an executable element created from the title.

---

# 9. Content Security Policy

A **Content Security Policy**, or CSP, tells the browser which resources and behaviors are allowed.

A basic policy might look like:

```http
Content-Security-Policy:
  default-src 'self';
  script-src 'self';
  style-src 'self';
  img-src 'self' data:;
  connect-src 'self';
  object-src 'none';
  base-uri 'self';
  frame-ancestors 'none';
```

This policy says, in simplified terms:

- Load resources from the same origin by default.
- Allow scripts only from the same origin.
- Allow styles only from the same origin.
- Allow same-origin images and data images.
- Allow network connections only to the same origin.
- Disallow plugin objects.
- Restrict the document base URL.
- Prevent framing by other pages.

CSP is defense in depth. It does not replace safe DOM handling.

---

# 10. CSP Meta Tag for Development

A CSP can be placed in HTML during development:

```html
<meta
  http-equiv="Content-Security-Policy"
  content="
    default-src 'self';
    script-src 'self';
    style-src 'self';
    img-src 'self' data:;
    connect-src 'self';
    object-src 'none';
    base-uri 'self';
    frame-ancestors 'none';
  "
/>
```

However, an HTTP response header is generally more flexible and authoritative for production deployment.

Use a header when you control the web server or hosting platform.

---

# 11. CSP and Inline Scripts

This is discouraged under a strict CSP:

```html
<button onclick="addTask()">Add task</button>
```

Use an external module instead:

```html
<button id="add-button" type="button">
  Add task
</button>
```

```javascript
const addButton =
  document.querySelector("#add-button");

addButton.addEventListener("click", addTask);
```

The final project already uses external JavaScript modules:

```html
<script type="module" src="./js/main.js"></script>
```

This is easier to maintain and works well with a strict policy.

---

# 12. CSP and Inline Styles

Avoid inline styles:

```html
<p style="color: red">Error</p>
```

Use CSS classes:

```html
<p class="status-error">Error</p>
```

```css
.status-error {
  color: #8c1f2d;
}
```

This allows a stricter `style-src` policy.

---

# 13. Trusted Types

Trusted Types can reduce DOM injection risks in supporting browsers.

A policy can create approved HTML:

```javascript
const policy = trustedTypes.createPolicy(
  "task-manager-policy",
  {
    createHTML(value) {
      return sanitizeTrustedMarkup(value);
    },
  }
);
```

Then:

```javascript
element.innerHTML = policy.createHTML(
  trustedMarkup
);
```

Do not create a policy that simply returns arbitrary user input:

```javascript
createHTML(value) {
  return value;
}
```

That defeats the purpose.

For the task manager, the safest and simplest approach is to avoid `innerHTML` and use:

```javascript
element.textContent = value;
```

---

# 14. Input Validation

Validation should happen at multiple boundaries.

## Form Boundary

Validate user input:

```javascript
const normalizedTitle = title.trim();

if (normalizedTitle.length === 0) {
  throw new ValidationError(
    "Task title cannot be empty."
  );
}
```

## API Boundary

Validate data received from a server:

```javascript
function validateApiTask(value) {
  if (
    typeof value !== "object" ||
    value === null ||
    typeof value.title !== "string" ||
    typeof value.completed !== "boolean"
  ) {
    throw new Error("The API returned an invalid task.");
  }

  return value;
}
```

## Storage Boundary

Validate data read from browser storage:

```javascript
const parsed = JSON.parse(rawValue);

if (!Array.isArray(parsed)) {
  throw new StorageError(
    "Stored tasks must be an array."
  );
}
```

Validation should not be performed only when the user submits a form.

---

# 15. Validation Is Not Sanitization

These concepts are different.

## Validation

Validation asks:

> Is this value acceptable?

```javascript
if (title.length > 120) {
  throw new Error("Title is too long.");
}
```

## Sanitization

Sanitization transforms a value into a safer form.

```javascript
const normalizedTitle = title.trim();
```

Removing or transforming data can have surprising effects. Prefer rejecting invalid values when possible.

For HTML, use text rendering instead of attempting to manually remove dangerous tags.

---

# 16. URL Construction

Never concatenate untrusted query values directly into URLs.

Risky:

```javascript
const url = `/api/tasks?search=${searchInput.value}`;
```

If the value contains spaces, `&`, or special characters, the URL may not mean what you expect.

Use `URLSearchParams`:

```javascript
const parameters = new URLSearchParams({
  search: searchInput.value,
});

const url = `/api/tasks?${parameters}`;
```

This safely encodes the query value.

Example:

```javascript
const parameters = new URLSearchParams({
  search: "JavaScript & APIs",
});

console.log(parameters.toString());
```

---

# 17. URL Path Parameters

Use `encodeURIComponent()` for a dynamic path segment:

```javascript
const taskId = encodeURIComponent(userProvidedId);

const url = `/api/tasks/${taskId}`;
```

However, identifiers should ideally be validated as identifiers before being placed in paths:

```javascript
if (!Number.isInteger(taskId)) {
  throw new Error("Invalid task ID.");
}
```

Use both validation and encoding where appropriate.

---

# 18. Fetch Security

A production fetch helper should:

- Use HTTPS in production.
- Check `response.ok`.
- Validate response data.
- Avoid logging sensitive values.
- Use an abort signal when appropriate.
- Handle network failures.
- Handle authentication failures.
- Handle rate limits.
- Handle unexpected content types.

Example:

```javascript
export async function requestJSON(
  url,
  { signal, ...options } = {}
) {
  const response = await fetch(url, {
    ...options,
    signal,
    credentials: "same-origin",
    headers: {
      Accept: "application/json",
      ...options.headers,
    },
  });

  if (!response.ok) {
    throw new Error(
      `Request failed with HTTP ${response.status}.`
    );
  }

  const contentType =
    response.headers.get("content-type") ?? "";

  if (!contentType.includes("application/json")) {
    throw new Error(
      "The server returned an unexpected content type."
    );
  }

  return response.json();
}
```

Use `credentials: "same-origin"` only when same-origin cookies are intentionally required. Configure credentials according to the application’s authentication architecture.

---

# 19. CSRF

Cross-site request forgery, or **CSRF**, tricks a user’s browser into sending an unwanted authenticated request.

This risk is especially important when authentication uses cookies.

Possible defenses include:

- `SameSite` cookies.
- CSRF tokens.
- Origin checks.
- Referer checks where appropriate.
- Server-side request validation.
- Avoiding state-changing actions through `GET`.

A state-changing request should generally use an appropriate method:

```javascript
await fetch("/api/tasks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    title,
  }),
});
```

Do not use:

```javascript
fetch("/api/delete-task?id=123");
```

for destructive operations if the endpoint changes state through `GET`.

The server must implement CSRF defenses. A browser-only application cannot solve CSRF alone.

---

# 20. CORS

Cross-Origin Resource Sharing, or **CORS**, controls whether a browser permits JavaScript from one origin to read responses from another origin.

Example origins:

```text
Application: https://app.example.com
API: https://api.example.com
```

These are different origins.

The API must explicitly allow the application origin:

```http
Access-Control-Allow-Origin: https://app.example.com
```

Avoid using:

```http
Access-Control-Allow-Origin: *
```

for authenticated private APIs.

Do not solve CORS by disabling browser security in the user’s browser. Configure the server correctly.

---

# 21. HTTPS

Production applications should use HTTPS.

HTTPS protects data in transit from being read or modified by network attackers.

Use HTTPS for:

- Application pages.
- API requests.
- Authentication.
- Form submissions.
- Browser storage access containing sensitive state.
- Third-party resources.

Avoid mixed content:

```text
HTTPS page → HTTP API
```

Browsers may block the request or create a security weakness.

Use:

```text
HTTPS page → HTTPS API
```

---

# 22. Secure Headers

A production server should consider headers such as:

```http
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

## `X-Content-Type-Options`

```http
X-Content-Type-Options: nosniff
```

Prevents browsers from guessing content types in certain situations.

## `Referrer-Policy`

```http
Referrer-Policy: strict-origin-when-cross-origin
```

Limits how much referring URL information is sent to other origins.

## `Permissions-Policy`

```http
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

Disables browser capabilities the application does not need.

## HSTS

```http
Strict-Transport-Security:
  max-age=31536000;
  includeSubDomains
```

Tells browsers to use HTTPS for the domain.

Only enable HSTS when HTTPS is correctly configured for the domain and its subdomains.

---

# 23. Subresource Integrity

If loading a third-party script, use Subresource Integrity where possible:

```html
<script
  src="https://cdn.example.com/library.min.js"
  integrity="sha384-HASH_VALUE"
  crossorigin="anonymous"
></script>
```

The browser verifies that the downloaded file matches the expected hash.

For this project, the preferred approach is to avoid unnecessary third-party scripts and serve application code from the same origin.

---

# 24. Third-Party Dependencies

Every dependency adds:

- Code.
- Maintenance.
- Supply-chain risk.
- Possible vulnerabilities.
- Build complexity.
- A potential source of unexpected behavior.

Before adding a dependency, ask:

1. Is it necessary?
2. Can the browser platform provide the feature?
3. Is it actively maintained?
4. Is its license suitable?
5. Does it have known vulnerabilities?
6. Does it collect data?
7. Does it increase bundle size significantly?
8. Does it introduce another third-party origin?

Use dependency scanning in production projects.

---

# 25. Dependency Security

When a project uses a package manager:

- Lock dependency versions.
- Review lockfile changes.
- Apply security updates.
- Remove unused dependencies.
- Run automated vulnerability scans.
- Avoid installing packages with unclear ownership.
- Review install scripts carefully.
- Keep direct and transitive dependencies visible.

Even if this browser-only project does not require packages, the same principles apply when it grows.

---

# 26. Error Messages and Information Disclosure

User-facing errors should be useful without revealing sensitive internals.

Avoid displaying:

```text
Database connection failed at 10.0.0.15 using password xyz.
```

Prefer:

```text
The task could not be saved. Please try again.
```

Log technical details securely on the server or in a controlled development environment.

For the client:

```javascript
this.status.show(
  "The task could not be saved.",
  "error"
);
```

For development logging:

```javascript
console.error("Task save failure:", error);
```

Do not log:

- Passwords.
- Access tokens.
- Session cookies.
- Private personal data.
- Full payment details.
- Sensitive request bodies.

---

# 27. Production Logging

Client-side console logs can expose implementation details to users.

Before production deployment:

- Remove temporary debug logs.
- Disable verbose diagnostics.
- Avoid logging sensitive values.
- Use a controlled error-monitoring system if necessary.
- Redact personally identifiable information.
- Include correlation IDs rather than private payloads.

A safe error event might include:

```javascript
{
  name: "StorageError",
  feature: "task-save",
  timestamp: "2026-07-23T12:00:00.000Z"
}
```

It should not include secrets or full user data.

---

# 28. Browser Storage Security

Browser storage is controlled by the user and accessible to same-origin JavaScript.

Therefore:

- Never treat it as authoritative.
- Never store secrets.
- Validate it after reading.
- Version the format.
- Handle user deletion.
- Handle malformed values.
- Consider privacy requirements.
- Avoid storing unnecessary personal data.

The final project correctly treats storage as an application cache and persistence mechanism, not a security boundary.

---

# 29. Privacy and Data Minimization

Store only what the application needs.

Instead of storing:

```javascript
{
  title,
  createdAt,
  userAgent,
  screenResolution,
  ipAddress,
  fullProfile,
  internalDebugData
}
```

store only:

```javascript
{
  id,
  title,
  completed,
  createdAt
}
```

Data minimization reduces:

- Privacy risk.
- Storage usage.
- Breach impact.
- Maintenance complexity.

Delete data that is no longer needed.

---

# 30. Content Security and User-Generated Data

If the application later supports formatted task descriptions, do not simply switch from:

```javascript
textContent
```

to:

```javascript
innerHTML
```

Rich text requires:

- A defined allowed markup policy.
- Sanitization.
- Safe URL handling.
- Safe attribute handling.
- Removal of scripts and event handlers.
- Testing against malicious input.

A plain-text task title is much easier to secure.

---

# 31. Safe File Downloads

If the application later exports tasks, avoid creating unsafe filenames directly from user input.

Unsafe:

```javascript
const filename = `${task.title}.json`;
```

A title may include:

- Path separators.
- Control characters.
- Very long text.
- Reserved names.
- Unexpected extensions.

Use a safe fixed filename:

```javascript
const filename = "async-task-manager-export.json";
```

Or sanitize strictly:

```javascript
function createSafeFilename(value) {
  return value
    .replace(/[^a-z0-9-_]+/gi, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80) || "export";
}
```

---

# 32. Safe JSON Export

A task export feature could use:

```javascript
function exportTasks(tasks) {
  const payload = {
    version: 1,
    exportedAt: new Date().toISOString(),
    tasks: tasks.map((task) => task.toJSON()),
  };

  const blob = new Blob(
    [JSON.stringify(payload, null, 2)],
    {
      type: "application/json",
    }
  );

  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");

  link.href = url;
  link.download = "async-task-manager-export.json";
  link.click();

  URL.revokeObjectURL(url);
}
```

Validate imported files before adding their data to the application.

---

# 33. Import Validation

Never trust imported JSON.

```javascript
function parseTaskExport(rawText) {
  let parsed;

  try {
    parsed = JSON.parse(rawText);
  } catch (error) {
    throw new Error(
      "The selected file is not valid JSON.",
      { cause: error }
    );
  }

  if (
    typeof parsed !== "object" ||
    parsed === null ||
    !Array.isArray(parsed.tasks)
  ) {
    throw new Error(
      "The selected file does not contain a task list."
    );
  }

  return parsed.tasks.map((value) => {
    return Task.fromJSON(value);
  });
}
```

For user-friendly behavior, report which records are invalid instead of accepting the entire file blindly.

---

# 34. Rate Limiting and Abuse

If the application gains a backend, users may submit requests repeatedly.

The server should consider:

- Rate limiting.
- Request size limits.
- Authentication limits.
- Abuse detection.
- Pagination.
- Maximum task counts.
- Maximum title lengths.
- Logging and monitoring.

Client-side button disabling improves user experience but does not prevent malicious clients from sending requests directly.

---

# 35. Request Size Limits

Never assume a request body is small.

The server should reject excessively large payloads before expensive processing.

The client can limit input:

```html
<input maxlength="120" />
```

The server must enforce the same or stricter limit.

For arrays:

```javascript
if (tasks.length > 1000) {
  throw new Error(
    "Too many tasks in one request."
  );
}
```

---

# 36. Security-Focused API Validation

A server-side task endpoint should validate data conceptually like this:

```javascript
function validateCreateTaskInput(body) {
  if (
    typeof body !== "object" ||
    body === null
  ) {
    throw new Error("Request body must be an object.");
  }

  if (typeof body.title !== "string") {
    throw new Error("Task title must be a string.");
  }

  const title = body.title.trim();

  if (title.length === 0) {
    throw new Error("Task title cannot be empty.");
  }

  if (title.length > 120) {
    throw new Error(
      "Task title cannot exceed 120 characters."
    );
  }

  return {
    title,
  };
}
```

The server should not accept client-supplied privileged fields such as:

```javascript
{
  ownerId: "another-user",
  isAdmin: true,
  createdAt: "arbitrary-date"
}
```

unless those fields are explicitly controlled and validated by the server.

---

# 37. Avoid Mass Assignment

Mass assignment occurs when an application copies every client-provided property into a model.

Risky:

```javascript
Object.assign(task, requestBody);
```

A client could submit:

```javascript
{
  "title": "Changed title",
  "ownerId": "another-user",
  "isAdmin": true
}
```

Prefer an allowlist:

```javascript
const task = {
  title: requestBody.title,
};
```

Only copy fields that the operation is allowed to modify.

---

# 38. Production Build Considerations

Before deployment:

- Serve through HTTPS.
- Use a production CSP.
- Remove test files.
- Remove debug code.
- Validate all API responses.
- Configure secure headers.
- Minify assets if appropriate.
- Enable compression.
- Set cache headers carefully.
- Use a clear versioning strategy.
- Monitor runtime errors.
- Test the deployed origin.
- Verify storage behavior.
- Test browser compatibility.

Do not deploy temporary files such as:

```text
prototype-demo.html
promise-demo.html
task-model.test.js
storage-diagnostic.html
```

unless they are intentionally part of the product.

---

# 39. Source Maps

Source maps help developers debug minified production code by mapping it back to source files.

They are useful, but consider whether exposing source maps reveals sensitive implementation details.

Never place secrets in frontend source files. Minification and source-map decisions cannot make a secret safe.

If the application contains only public client logic, source maps may be acceptable. If source maps expose proprietary details, restrict access while preserving error-monitoring capability.

---

# 40. Environment Configuration

Frontend environment values are public.

This is safe only for non-secret configuration:

```javascript
const API_BASE_URL = "https://api.example.com";
```

Do not put private credentials in:

```javascript
const PRIVATE_API_KEY = "...";
```

Any value shipped to the browser can be inspected.

Use the server for secrets.

For a simple application, configuration may be centralized:

### `js/config.js`

```javascript
"use strict";

export const config = Object.freeze({
  apiBaseUrl: "https://api.example.com",
  requestTimeoutMilliseconds: 5000,
});
```

This improves organization but does not hide the values.

---

# 41. Security Monitoring

A production application should monitor:

- JavaScript errors.
- Failed API requests.
- Authentication failures.
- Repeated validation failures.
- Storage failures if they affect user workflows.
- CSP violations.
- Unexpected response formats.
- Performance degradation.

CSP reporting can identify attempted or accidental violations. Configure reporting carefully and avoid sending sensitive data unnecessarily.

---

# 42. Security Review Checklist

## Input and Output

- [ ] User input is validated.
- [ ] API data is validated.
- [ ] Storage data is validated.
- [ ] User text uses `textContent`.
- [ ] No unsafe `innerHTML` usage exists.
- [ ] Dynamic URLs use encoding.
- [ ] Imported files are validated.

## Authentication and Authorization

- [ ] No secrets are embedded in frontend code.
- [ ] Authorization is enforced by the server.
- [ ] Resource ownership is checked server-side.
- [ ] Cookies are configured securely.
- [ ] CSRF defenses are implemented where needed.

## Network

- [ ] Production uses HTTPS.
- [ ] API responses check `response.ok`.
- [ ] CORS allows only intended origins.
- [ ] Sensitive data is not logged.
- [ ] Requests have sensible timeouts or cancellation.

## Browser

- [ ] Browser storage contains no secrets.
- [ ] Storage writes handle failures.
- [ ] Storage values are versioned where appropriate.
- [ ] Multiple-tab behavior is considered.
- [ ] No unsafe inline scripts exist.

## Headers

- [ ] Content Security Policy is configured.
- [ ] `X-Content-Type-Options` is configured.
- [ ] `Referrer-Policy` is configured.
- [ ] `Permissions-Policy` is configured.
- [ ] HSTS is enabled only after HTTPS is ready.
- [ ] Framing protections are configured.

## Dependencies and Deployment

- [ ] Dependencies are reviewed.
- [ ] Vulnerability scans run.
- [ ] Test files are excluded.
- [ ] Debug logging is removed or disabled.
- [ ] Production errors are monitored.
- [ ] Browser compatibility is tested.

---

# 43. Security Definition of Done

The application should not be considered production-ready until:

1. User input is rendered safely.
2. All external data is validated.
3. Browser storage is treated as untrusted.
4. No secrets are shipped to the browser.
5. Server-side authorization exists for protected operations.
6. API errors are handled safely.
7. HTTPS is enabled.
8. Security headers are configured.
9. CSP is tested without breaking the application.
10. Error messages avoid sensitive information.
11. Dependencies are reviewed.
12. Production logging is controlled.
13. Malformed data has been tested.
14. Cross-site scripting tests have passed.
15. The application has been tested in supported browsers.
