# Appendix B: Complete API Reference & Documentation

Welcome to Appendix B of the FastAPI Masterclass series! This comprehensive reference provides complete API documentation for all endpoints, including request/response schemas, authentication requirements, and example usage. Use this as your API handbook when building client applications or extending the API.

## API Overview

### Base URL
```
http://localhost:8000/api/v1
```

### Authentication
All endpoints except registration and login require JWT authentication via Bearer token:
```
Authorization: Bearer <your_access_token>
```

### Response Format
All responses follow a consistent format:

**Success Response:**
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "abc-123-def"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": {
    "status_code": 400,
    "detail": "Validation error",
    "error_code": "VALIDATION_ERROR",
    "data": {
      "validation_errors": [...]
    }
  },
  "meta": {
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "abc-123-def"
  }
}
```

### Common Status Codes
| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful delete) |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Validation Error |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

---

## Authentication Endpoints

### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "full_name": "John Doe",
  "password": "SecurePass123!",
  "role": "developer"  // optional, default: viewer
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "johndoe",
  "full_name": "John Doe",
  "role": "developer",
  "is_active": true,
  "is_verified": false,
  "created_at": "2024-01-15T10:30:00Z"
}
```

**Error Responses:**
- `409 CONFLICT` - Email or username already taken
- `422 UNPROCESSABLE_ENTITY` - Validation error

---

### POST /auth/login
Authenticate and get access/refresh tokens.

**Request Body (form data):**
```
username: user@example.com
password: SecurePass123!
```
*Note: Username field accepts either email or username*

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 1800,
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "johndoe",
    "full_name": "John Doe",
    "role": "developer"
  }
}
```

**Error Responses:**
- `401 UNAUTHORIZED` - Invalid credentials

---

### POST /auth/refresh
Refresh access token using refresh token.

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 1800
}
```

**Error Responses:**
- `401 UNAUTHORIZED` - Invalid refresh token

---

### POST /auth/logout
Logout and revoke refresh token.

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (204 No Content)**

---

### GET /auth/me
Get current authenticated user profile.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "johndoe",
  "full_name": "John Doe",
  "role": "developer",
  "bio": "Software engineer",
  "phone_number": "+1-555-123-4567",
  "avatar_url": "https://example.com/avatar.jpg",
  "is_active": true,
  "is_verified": true,
  "is_superuser": false,
  "last_login": "2024-01-15T10:00:00Z",
  "login_count": 42,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

### POST /auth/change-password
Change current user's password.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "current_password": "OldPass123!",
  "new_password": "NewPass456!"
}
```

**Response (200 OK):**
```json
{
  "message": "Password changed successfully"
}
```

---

### POST /auth/reset-password
Request password reset email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset email sent if account exists"
}
```

---

### POST /auth/reset-password/confirm
Confirm password reset with token.

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "new_password": "NewSecurePass123!"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset successfully"
}
```

---

## User Management Endpoints

### GET /users
Get list of users (admin only).

**Headers:**
```
Authorization: Bearer <admin_access_token>
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Page number (default: 1) |
| size | int | Items per page (default: 10, max: 100) |
| role | string | Filter by role |
| search | string | Search in username, email, full_name |
| sort_by | string | Sort field (created_at, username, email) |
| sort_order | string | asc or desc |

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": 1,
      "email": "user@example.com",
      "username": "johndoe",
      "full_name": "John Doe",
      "role": "developer",
      "is_active": true,
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 42,
  "page": 1,
  "size": 10,
  "pages": 5
}
```

---

### GET /users/{user_id}
Get user by ID.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "johndoe",
  "full_name": "John Doe",
  "role": "developer",
  "bio": "Software engineer",
  "phone_number": "+1-555-123-4567",
  "avatar_url": "https://example.com/avatar.jpg",
  "is_active": true,
  "is_verified": true,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

### PUT /users/{user_id}
Update user.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (all fields optional):**
```json
{
  "email": "newemail@example.com",
  "username": "newusername",
  "full_name": "Johnathan Doe",
  "role": "manager",
  "bio": "Updated bio",
  "phone_number": "+1-555-999-9999",
  "avatar_url": "https://example.com/new-avatar.jpg"
}
```

**Response (200 OK):** Same as GET /users/{user_id}

---

### DELETE /users/{user_id}
Deactivate user (admin only).

**Headers:**
```
Authorization: Bearer <admin_access_token>
```

**Response (204 No Content)**

---

## Task Management Endpoints

### GET /tasks
Get list of tasks with filtering and pagination.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Page number (default: 1) |
| size | int | Items per page (default: 10, max: 100) |
| status | string | Filter by status (todo, in_progress, review, done, archived) |
| priority | string | Filter by priority (low, medium, high, critical) |
| project_id | int | Filter by project ID |
| assignee_id | int | Filter by assignee |
| created_by_id | int | Filter by creator |
| tag | string | Filter by tag |
| search | string | Search in title and description |
| due_before | datetime | Tasks due before this date (ISO format) |
| due_after | datetime | Tasks due after this date (ISO format) |
| sort_by | string | Sort field (created_at, updated_at, due_date, title, priority) |
| sort_order | string | asc or desc |

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": 1,
      "title": "Implement JWT authentication",
      "description": "Add OAuth2 with JWT tokens",
      "status": "in_progress",
      "priority": "high",
      "due_date": "2024-12-31T23:59:59Z",
      "project_id": 1,
      "assignee_id": 42,
      "created_by_id": 1,
      "tags": ["backend", "security", "jwt"],
      "estimated_hours": 8.5,
      "actual_hours": 12.0,
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z",
      "completed_at": null,
      "is_overdue": false
    }
  ],
  "total": 42,
  "page": 1,
  "size": 10,
  "pages": 5
}
```

---

### POST /tasks
Create a new task.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "title": "Implement JWT authentication",
  "description": "Add OAuth2 with JWT tokens and refresh flow",
  "status": "todo",
  "priority": "high",
  "due_date": "2024-12-31T23:59:59Z",
  "project_id": 1,
  "assignee_id": 42,
  "tags": ["backend", "security", "jwt"],
  "estimated_hours": 8.5
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "title": "Implement JWT authentication",
  "description": "Add OAuth2 with JWT tokens and refresh flow",
  "status": "todo",
  "priority": "high",
  "due_date": "2024-12-31T23:59:59Z",
  "project_id": 1,
  "assignee_id": 42,
  "created_by_id": 1,
  "tags": ["backend", "security", "jwt"],
  "estimated_hours": 8.5,
  "actual_hours": null,
  "created_at": "2024-01-15T10:00:00Z",
  "updated_at": "2024-01-15T10:00:00Z",
  "completed_at": null,
  "is_overdue": false
}
```

---

### GET /tasks/{task_id}
Get task by ID.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):** Same as task item above

---

### PUT /tasks/{task_id}
Update a task.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (all fields optional):**
```json
{
  "title": "Updated: JWT auth with refresh tokens",
  "description": "Add refresh token rotation",
  "status": "review",
  "priority": "critical",
  "due_date": "2025-01-15T23:59:59Z",
  "project_id": 2,
  "assignee_id": 43,
  "tags": ["backend", "security", "jwt", "refresh"],
  "estimated_hours": 10.0,
  "actual_hours": 12.5
}
```

**Response (200 OK):** Same as GET /tasks/{task_id}

---

### DELETE /tasks/{task_id}
Delete a task.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (204 No Content)**

---

### POST /tasks/{task_id}/complete
Mark a task as complete.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):** Same as GET /tasks/{task_id} with status="done"

---

### POST /tasks/{task_id}/assign
Assign a task to a user.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "assignee_id": 43
}
```

**Response (200 OK):** Same as GET /tasks/{task_id} with updated assignee

---

### GET /tasks/stats
Get task statistics.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| project_id | int | Filter by project |
| assignee_id | int | Filter by assignee |

**Response (200 OK):**
```json
{
  "total": 42,
  "by_status": {
    "todo": 10,
    "in_progress": 15,
    "review": 5,
    "done": 12,
    "archived": 0
  },
  "overdue": 3,
  "completed_today": 2,
  "completion_rate": 28.57
}
```

---

## Project Management Endpoints

### GET /projects
Get list of projects.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Page number |
| size | int | Items per page |
| status | string | active, paused, completed, archived |
| owner_id | int | Filter by owner |
| search | string | Search in name and description |

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": 1,
      "name": "FastAPI Project",
      "description": "Building a production API",
      "status": "active",
      "is_public": false,
      "owner_id": 1,
      "owner": {
        "id": 1,
        "username": "johndoe",
        "full_name": "John Doe"
      },
      "member_count": 5,
      "task_count": 42,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 10,
  "page": 1,
  "size": 10,
  "pages": 1
}
```

---

### POST /projects
Create a new project.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "name": "FastAPI Masterclass Project",
  "description": "Building a production-ready API",
  "status": "active",
  "is_public": false
}
```

**Response (201 Created):** Same as project item above

---

### GET /projects/{project_id}
Get project by ID.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):** Same as project item above

---

### PUT /projects/{project_id}
Update a project.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (all fields optional):**
```json
{
  "name": "Updated Project Name",
  "description": "Updated description",
  "status": "paused",
  "is_public": true
}
```

**Response (200 OK):** Same as GET /projects/{project_id}

---

### DELETE /projects/{project_id}
Delete a project.

**Headers:**
```
Authorization: Bearer <access_token>

**Response (204 No Content)**

---

### GET /projects/{project_id}/members
Get project members.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "items": [
    {
      "user_id": 1,
      "username": "johndoe",
      "full_name": "John Doe",
      "role": "owner",
      "joined_at": "2024-01-01T00:00:00Z"
    },
    {
      "user_id": 2,
      "username": "janedoe",
      "full_name": "Jane Doe",
      "role": "member",
      "joined_at": "2024-01-02T00:00:00Z"
    }
  ],
  "total": 2
}
```

---

### POST /projects/{project_id}/members
Add member to project.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "user_id": 3,
  "role": "member"
}
```

**Response (201 Created):**
```json
{
  "message": "User added to project",
  "user_id": 3,
  "role": "member"
}
```

---

### DELETE /projects/{project_id}/members/{user_id}
Remove member from project.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (204 No Content)**

---

## Comment Endpoints

### GET /tasks/{task_id}/comments
Get comments for a task.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Page number |
| size | int | Items per page |

**Response (200 OK):**
```json
{
  "items": [
    {
      "id": 1,
      "content": "Great work on this task!",
      "author_id": 2,
      "author": {
        "id": 2,
        "username": "janedoe",
        "full_name": "Jane Doe"
      },
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    }
  ],
  "total": 5,
  "page": 1,
  "size": 10,
  "pages": 1
}
```

---

### POST /tasks/{task_id}/comments
Add comment to task.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "content": "This is my comment on the task."
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "content": "This is my comment on the task.",
  "author_id": 1,
  "author": {
    "id": 1,
    "username": "johndoe",
    "full_name": "John Doe"
  },
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

---

### PUT /comments/{comment_id}
Update a comment.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "content": "Updated comment content."
}
```

**Response (200 OK):** Same as POST /tasks/{task_id}/comments

---

### DELETE /comments/{comment_id}
Delete a comment.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (204 No Content)**

---

## File Upload Endpoints

### POST /upload
Upload a single file.

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Form Data:**
```
file: [binary file content]
```

**Allowed File Types:**
- image/jpeg, image/png, image/gif
- application/pdf
- Max size: 10MB

**Response (200 OK):**
```json
{
  "message": "File uploaded successfully",
  "file_name": "document.pdf",
  "file_url": "/uploads/users/1/20240115_103000_abc123.pdf",
  "file_size": 1024,
  "content_type": "application/pdf"
}
```

---

### POST /upload/multiple
Upload multiple files.

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Form Data:**
```
files: [binary file contents]
```

**Response (200 OK):**
```json
{
  "message": "Upload complete",
  "results": [
    {
      "file_name": "image1.jpg",
      "file_url": "/uploads/users/1/20240115_103000_def456.jpg",
      "status": "success"
    },
    {
      "file_name": "large-file.pdf",
      "error": "File too large (max 10MB)",
      "status": "failed"
    }
  ]
}
```

---

### DELETE /upload/{file_path}
Delete a file.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "message": "File deleted successfully"
}
```

---

## Health & Monitoring Endpoints

### GET /health
Health check endpoint.

**Response (200 OK):**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "service": "FastAPI Masterclass",
  "version": "1.0.0",
  "environment": "production"
}
```

---

### GET /ready
Readiness probe for Kubernetes.

**Response (200 OK):**
```json
{
  "status": "ready",
  "timestamp": "2024-01-15T10:30:00Z",
  "database": "connected"
}
```

---

### GET /metrics
Prometheus metrics endpoint.

**Response (200 OK):**
```
# TYPE http_requests_total counter
http_requests_total{method="GET",endpoint="/api/v1/tasks",status_code="200"} 42
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{method="GET",endpoint="/api/v1/tasks",le="0.005"} 10
```

---

## WebSocket Endpoint

### WS /ws/{client_id}
WebSocket connection for real-time communication.

**Connection:**
```javascript
const ws = new WebSocket('ws://localhost:8000/ws/1');
```

**Message Types:**

**1. Ping/Pong:**
```json
// Send
{"type": "ping"}
// Receive
{"type": "pong", "timestamp": "2024-01-15T10:30:00Z"}
```

**2. Join Room:**
```json
// Send
{"type": "join_room", "room": "project_1"}
// Receive
{"type": "room_joined", "room": "project_1"}
```

**3. Leave Room:**
```json
// Send
{"type": "leave_room", "room": "project_1"}
// Receive
{"type": "room_left", "room": "project_1"}
```

**4. Send Message:**
```json
// Send to user
{"type": "message", "to": 2, "content": "Hello!"}
// Send to room
{"type": "message", "room": "project_1", "content": "Hello team!"}
```

**5. Receive Message:**
```json
{
  "type": "direct_message",
  "from": 1,
  "content": "Hello!",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**6. Receive Notification:**
```json
{
  "type": "notification",
  "title": "Task Assigned",
  "message": "You have been assigned task: Implement JWT",
  "metadata": {
    "task_id": 1,
    "task_title": "Implement JWT"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## Error Codes Reference

| Error Code | Description | HTTP Status |
|------------|-------------|-------------|
| INTERNAL_ERROR | Unexpected server error | 500 |
| BAD_REQUEST | Invalid request format | 400 |
| UNAUTHORIZED | Authentication required | 401 |
| FORBIDDEN | Insufficient permissions | 403 |
| NOT_FOUND | Resource not found | 404 |
| CONFLICT | Resource conflict | 409 |
| VALIDATION_ERROR | Data validation failed | 422 |
| RATE_LIMIT_EXCEEDED | Too many requests | 429 |
| INVALID_CREDENTIALS | Invalid username/password | 401 |
| INVALID_TOKEN | Invalid or expired token | 401 |
| ACCOUNT_INACTIVE | User account is inactive | 401 |
| EMAIL_TAKEN | Email already registered | 409 |
| USERNAME_TAKEN | Username already taken | 409 |
| WEAK_PASSWORD | Password doesn't meet requirements | 400 |
| PERMISSION_DENIED | User lacks required permission | 403 |
| RESOURCE_NOT_FOUND | Requested resource doesn't exist | 404 |
| TASK_NOT_FOUND | Task not found | 404 |
| USER_NOT_FOUND | User not found | 404 |
| PROJECT_NOT_FOUND | Project not found | 404 |
| COMMENT_NOT_FOUND | Comment not found | 404 |
| INVALID_REFRESH_TOKEN | Refresh token invalid | 401 |
| API_KEY_REQUIRED | API key missing | 401 |
| INVALID_API_KEY | API key invalid | 401 |

## Rate Limiting Headers

All API responses include rate limiting headers:

| Header | Description |
|--------|-------------|
| X-RateLimit-Limit | Maximum requests allowed in the window |
| X-RateLimit-Window | Time window in seconds |
| X-RateLimit-Remaining | Remaining requests in the current window |
| X-RateLimit-Reset | Time when the rate limit resets (Unix timestamp) |

---

## Pagination & Filtering

### Pagination Parameters
- `page`: Page number (default: 1)
- `size`: Items per page (default: 10, max: 100)

### Sorting Parameters
- `sort_by`: Field to sort by
- `sort_order`: `asc` or `desc` (default: desc)

### Common Filters
- `status`: Filter by status field
- `priority`: Filter by priority
- `search`: Full-text search
- `date` filters: `due_before`, `due_after`, `created_before`, `created_after`

## API Versioning

The API uses URI versioning: `/api/v1/...`

### Version History
| Version | Status | Changes |
|---------|--------|---------|
| v1 | Current | Initial release |
| v2 | Planned | GraphQL support, improved performance |

## Authentication Flows

### OAuth2 Password Flow (Standard)
```
1. POST /api/v1/auth/register
2. POST /api/v1/auth/login → get access_token + refresh_token
3. Use access_token in Authorization header
4. When expired, POST /api/v1/auth/refresh → get new access_token
5. POST /api/v1/auth/logout to invalidate refresh_token
```

### OAuth2 Password Flow (Mobile/SPA)
```
1. Same as above
2. Store refresh_token securely (HttpOnly cookie recommended)
3. Use access_token in API requests
4. When expired, automatically refresh using refresh_token
```

### API Key Flow (Service-to-Service)
```
1. Generate API key
2. Include in request header: X-API-Key: your-api-key
3. Used for server-to-server authentication
```

---

## Webhook Configuration

### Available Webhook Events

**Task Events:**
- `task.created` - When a task is created
- `task.updated` - When a task is updated
- `task.completed` - When a task is completed
- `task.deleted` - When a task is deleted
- `task.assigned` - When a task is assigned
- `task.overdue` - When a task becomes overdue

**User Events:**
- `user.created` - When a user registers
- `user.updated` - When a user profile is updated
- `user.deleted` - When a user is deactivated

**Project Events:**
- `project.created` - When a project is created
- `project.updated` - When a project is updated
- `project.deleted` - When a project is deleted
- `project.member_added` - When a member is added
- `project.member_removed` - When a member is removed

### Webhook Payload Format
```json
{
  "event": "task.completed",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "id": 1,
    "title": "Implement JWT authentication",
    "status": "done",
    "completed_at": "2024-01-15T10:30:00Z",
    "assignee_id": 42
  }
}
```

---

This comprehensive API reference should serve as your go-to documentation when building clients, integrating with third-party services, or extending the API. The examples provided cover the most common use cases, and the error code reference helps with troubleshooting.

**[END OF APPENDIX B]**
