# Appendix B: Complete API Reference

## Full API Documentation with Examples

Welcome to **Appendix B** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for all API endpoints, including request/response examples, error codes, and authentication requirements.

---

## Base Information

### API Overview

| Property | Value |
|----------|-------|
| **Base URL** | `https://api.taskflow.com/api/v1/` |
| **Version** | 1.0.0 |
| **Authentication** | JWT (Bearer Token) |
| **Rate Limiting** | 100 requests/hour (general) |
| **Rate Limiting (Auth)** | 10 requests/minute |
| **Response Format** | JSON |

### Authentication

All endpoints require authentication except where noted.

**Token Endpoints:**

```
POST /token/            # Get access + refresh tokens
POST /token/refresh/    # Refresh access token
POST /token/verify/     # Verify token validity
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

---

## Endpoint Reference

### 1. Authentication Endpoints

#### 1.1 Obtain Token

**POST** `/api/v1/token/`

**Request:**
```json
{
    "email": "user@example.com",
    "password": "yourpassword"
}
```

**Response (200 OK):**
```json
{
    "refresh": "eyJhbGciOiJIUzI1NiIs...",
    "access": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Errors:**
- `401 Unauthorized`: Invalid credentials
- `400 Bad Request`: Missing required fields

---

#### 1.2 Refresh Token

**POST** `/api/v1/token/refresh/`

**Request:**
```json
{
    "refresh": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{
    "access": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Errors:**
- `401 Unauthorized`: Invalid or expired refresh token

---

#### 1.3 Verify Token

**POST** `/api/v1/token/verify/`

**Request:**
```json
{
    "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```json
{}
```

**Errors:**
- `401 Unauthorized`: Invalid token

---

#### 1.4 Register User

**POST** `/api/v1/users/register/`

**Request:**
```json
{
    "email": "newuser@example.com",
    "username": "newuser",
    "first_name": "New",
    "last_name": "User",
    "password": "SecurePass123!",
    "confirm_password": "SecurePass123!",
    "bio": "Optional user biography",
    "role": "member"
}
```

**Response (201 Created):**
```json
{
    "user": {
        "id": 123,
        "email": "newuser@example.com",
        "username": "newuser",
        "first_name": "New",
        "last_name": "User",
        "full_name": "New User",
        "bio": "Optional user biography",
        "role": "member",
        "role_display": "Member",
        "created_at": "2026-01-15T12:00:00Z",
        "updated_at": "2026-01-15T12:00:00Z"
    },
    "refresh": "eyJhbGciOiJIUzI1NiIs...",
    "access": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

### 2. User Endpoints

#### 2.1 List Users

**GET** `/api/v1/users/`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `role` | string | Filter by role (admin, manager, member, viewer) |
| `search` | string | Search in email, username, first_name, last_name |
| `ordering` | string | Order by fields (prefix - for descending) |

**Response (200 OK):**
```json
{
    "count": 10,
    "next": "http://api.taskflow.com/api/v1/users/?page=2",
    "previous": null,
    "results": [
        {
            "id": 1,
            "email": "admin@example.com",
            "username": "admin",
            "first_name": "Admin",
            "last_name": "User",
            "full_name": "Admin User",
            "bio": null,
            "role": "admin",
            "role_display": "Administrator",
            "is_active": true,
            "is_staff": true,
            "is_superuser": true,
            "created_at": "2026-01-15T12:00:00Z",
            "updated_at": "2026-01-15T12:00:00Z"
        }
    ]
}
```

#### 2.2 Get User Profile

**GET** `/api/v1/users/profile/`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
    "id": 1,
    "email": "user@example.com",
    "username": "testuser",
    "first_name": "Test",
    "last_name": "User",
    "bio": "I'm a developer",
    "role": "member",
    "created_at": "2026-01-15T12:00:00Z"
}
```

#### 2.3 Get User Detail

**GET** `/api/v1/users/{id}/`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
    "id": 1,
    "email": "user@example.com",
    "username": "testuser",
    "first_name": "Test",
    "last_name": "User",
    "full_name": "Test User",
    "bio": "I'm a developer",
    "role": "member",
    "role_display": "Member",
    "is_active": true,
    "is_staff": false,
    "is_superuser": false,
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 2.4 Update User

**PUT/PATCH** `/api/v1/users/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Admin or Manager (for non-admin users)

**Request:**
```json
{
    "first_name": "Updated",
    "last_name": "Name",
    "bio": "Updated bio",
    "role": "manager"
}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "email": "user@example.com",
    "username": "testuser",
    "first_name": "Updated",
    "last_name": "Name",
    "full_name": "Updated Name",
    "bio": "Updated bio",
    "role": "manager",
    "role_display": "Manager",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 2.5 Set User Role

**POST** `/api/v1/users/{id}/set_role/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Admin or Manager

**Request:**
```json
{
    "role": "manager"
}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "email": "user@example.com",
    "role": "manager",
    "role_display": "Manager"
}
```

#### 2.6 Delete User

**DELETE** `/api/v1/users/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Admin only

**Response (204 No Content)**

---

### 3. Project Endpoints

#### 3.1 List Projects

**GET** `/api/v1/projects/`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `search` | string | Search in name and description |
| `created_by` | integer | Filter by creator ID |
| `has_tasks` | boolean | Filter projects with tasks |
| `created_after` | datetime | Filter projects created after |
| `created_before` | datetime | Filter projects created before |
| `ordering` | string | Order by fields (prefix - for descending) |
| `page` | integer | Page number |
| `page_size` | integer | Items per page |

**Response (200 OK):**
```json
{
    "count": 5,
    "next": "http://api.taskflow.com/api/v1/projects/?page=2",
    "previous": null,
    "results": [
        {
            "id": 1,
            "name": "Masterclass Project",
            "description": "The main project for the masterclass",
            "created_by": 1,
            "created_by_username": "admin",
            "task_count": 10,
            "completed_task_count": 6,
            "created_at": "2026-01-15T12:00:00Z",
            "updated_at": "2026-01-15T12:00:00Z"
        }
    ]
}
```

#### 3.2 Create Project

**POST** `/api/v1/projects/`

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
    "name": "New Project",
    "description": "Project description"
}
```

**Response (201 Created):**
```json
{
    "id": 2,
    "name": "New Project",
    "description": "Project description",
    "created_by": 1,
    "created_by_username": "admin",
    "task_count": 0,
    "completed_task_count": 0,
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 3.3 Get Project Detail

**GET** `/api/v1/projects/{id}/`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
    "id": 1,
    "name": "Masterclass Project",
    "description": "The main project for the masterclass",
    "created_by": 1,
    "created_by_username": "admin",
    "task_count": 10,
    "completed_task_count": 6,
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 3.4 Update Project

**PUT/PATCH** `/api/v1/projects/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Project owner or Admin

**Request:**
```json
{
    "name": "Updated Project Name",
    "description": "Updated description"
}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "name": "Updated Project Name",
    "description": "Updated description",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 3.5 Delete Project

**DELETE** `/api/v1/projects/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Project owner or Admin

**Response (204 No Content)**

#### 3.6 Get Project Tasks

**GET** `/api/v1/projects/{id}/tasks/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Project access required

**Query Parameters:** Same as task list filters

**Response (200 OK):**
```json
{
    "count": 10,
    "results": [
        {
            "id": 1,
            "title": "Complete API documentation",
            "status": "in_progress",
            "status_display": "In Progress",
            "priority": "high",
            "priority_display": "High",
            "due_date": "2026-02-01T12:00:00Z",
            "assigned_to_username": "admin",
            "created_at": "2026-01-15T12:00:00Z"
        }
    ]
}
```

#### 3.7 Add Task to Project

**POST** `/api/v1/projects/{id}/add_task/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Project access required

**Request:**
```json
{
    "title": "New Task",
    "description": "Task description",
    "status": "todo",
    "priority": "high",
    "due_date": "2026-02-15T12:00:00Z",
    "assigned_to": 2
}
```

**Response (201 Created):**
```json
{
    "id": 11,
    "title": "New Task",
    "description": "Task description",
    "status": "todo",
    "status_display": "To Do",
    "priority": "high",
    "priority_display": "High",
    "due_date": "2026-02-15T12:00:00Z",
    "project": 1,
    "project_name": "Masterclass Project",
    "assigned_to": 2,
    "assigned_to_username": "manager",
    "created_by": 1,
    "created_by_username": "admin",
    "comment_count": 0,
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 3.8 Get Project Stats

**GET** `/api/v1/projects/{id}/stats/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Project access required

**Response (200 OK):**
```json
{
    "total_tasks": 10,
    "completed": 6,
    "in_progress": 2,
    "todo": 1,
    "review": 1,
    "by_priority": {
        "low": 2,
        "medium": 4,
        "high": 3,
        "urgent": 1
    },
    "completion_rate": 60.0
}
```

---

### 4. Task Endpoints

#### 4.1 List Tasks

**GET** `/api/v1/tasks/`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | todo, in_progress, review, done |
| `priority` | string | low, medium, high, urgent |
| `search` | string | Search in title and description |
| `project` | integer | Filter by project ID |
| `assigned_to` | integer | Filter by assignee ID |
| `created_by` | integer | Filter by creator ID |
| `created_after` | datetime | Tasks created after |
| `created_before` | datetime | Tasks created before |
| `due_after` | datetime | Tasks due after |
| `due_before` | datetime | Tasks due before |
| `is_overdue` | boolean | Filter overdue tasks |
| `has_comments` | boolean | Filter tasks with comments |
| `ordering` | string | Order by fields (prefix - for descending) |
| `page` | integer | Page number |
| `page_size` | integer | Items per page |

**Response (200 OK):**
```json
{
    "count": 25,
    "next": "http://api.taskflow.com/api/v1/tasks/?page=2",
    "previous": null,
    "results": [
        {
            "id": 1,
            "title": "Complete API documentation",
            "status": "in_progress",
            "status_display": "In Progress",
            "priority": "high",
            "priority_display": "High",
            "due_date": "2026-02-01T12:00:00Z",
            "project_name": "Masterclass Project",
            "assigned_to_username": "admin",
            "created_at": "2026-01-15T12:00:00Z"
        }
    ]
}
```

#### 4.2 Create Task

**POST** `/api/v1/tasks/`

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
    "title": "New Task",
    "description": "Task description",
    "status": "todo",
    "priority": "medium",
    "due_date": "2026-02-15T12:00:00Z",
    "project": 1,
    "assigned_to": 2
}
```

**Response (201 Created):**
```json
{
    "id": 12,
    "title": "New Task",
    "description": "Task description",
    "status": "todo",
    "status_display": "To Do",
    "priority": "medium",
    "priority_display": "Medium",
    "due_date": "2026-02-15T12:00:00Z",
    "is_overdue": false,
    "project": 1,
    "project_name": "Masterclass Project",
    "assigned_to": 2,
    "assigned_to_username": "manager",
    "created_by": 1,
    "created_by_username": "admin",
    "comment_count": 0,
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 4.3 Get Task Detail

**GET** `/api/v1/tasks/{id}/`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
    "id": 1,
    "title": "Complete API documentation",
    "description": "Write comprehensive API documentation",
    "status": "in_progress",
    "status_display": "In Progress",
    "priority": "high",
    "priority_display": "High",
    "due_date": "2026-02-01T12:00:00Z",
    "is_overdue": false,
    "project": 1,
    "project_name": "Masterclass Project",
    "assigned_to": 1,
    "assigned_to_username": "admin",
    "created_by": 1,
    "created_by_username": "admin",
    "comment_count": 3,
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 4.4 Update Task

**PUT/PATCH** `/api/v1/tasks/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Task owner, assignee, or Admin

**Request:**
```json
{
    "title": "Updated Task Title",
    "status": "done",
    "priority": "high"
}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "title": "Updated Task Title",
    "status": "done",
    "status_display": "Done",
    "priority": "high",
    "priority_display": "High",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 4.5 Update Task Status

**PATCH** `/api/v1/tasks/{id}/status/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Task access required

**Request:**
```json
{
    "status": "in_progress"
}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "title": "Complete API documentation",
    "status": "in_progress",
    "status_display": "In Progress",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 4.6 Delete Task

**DELETE** `/api/v1/tasks/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Task owner, project owner, or Admin

**Response (204 No Content)**

#### 4.7 Get Task Comments

**GET** `/api/v1/tasks/{id}/comments/`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `search` | string | Search in content |
| `author` | integer | Filter by author ID |
| `created_after` | datetime | Comments created after |
| `created_before` | datetime | Comments created before |
| `ordering` | string | Order by fields |

**Response (200 OK):**
```json
{
    "count": 3,
    "results": [
        {
            "id": 1,
            "content": "Great progress on this!",
            "author": 1,
            "author_username": "admin",
            "author_email": "admin@example.com",
            "created_at": "2026-01-15T12:00:00Z",
            "updated_at": "2026-01-15T12:00:00Z"
        }
    ]
}
```

#### 4.8 Get Task Stats

**GET** `/api/v1/tasks/stats/`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
    "total": 25,
    "todo": 5,
    "in_progress": 8,
    "review": 4,
    "done": 8,
    "overdue": 3,
    "by_priority": {
        "low": 5,
        "medium": 10,
        "high": 8,
        "urgent": 2
    }
}
```

---

### 5. Comment Endpoints

#### 5.1 List Comments

**GET** `/api/v1/comments/`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `task` | integer | Filter by task ID |
| `author` | integer | Filter by author ID |
| `search` | string | Search in content |
| `created_after` | datetime | Comments created after |
| `created_before` | datetime | Comments created before |
| `ordering` | string | Order by fields |

**Response (200 OK):**
```json
{
    "count": 15,
    "results": [
        {
            "id": 1,
            "content": "Great progress on this!",
            "task": 1,
            "task_title": "Complete API documentation",
            "author": 1,
            "author_username": "admin",
            "author_email": "admin@example.com",
            "created_at": "2026-01-15T12:00:00Z",
            "updated_at": "2026-01-15T12:00:00Z"
        }
    ]
}
```

#### 5.2 Create Comment

**POST** `/api/v1/comments/`

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
    "content": "This is a comment",
    "task": 1
}
```

**Response (201 Created):**
```json
{
    "id": 16,
    "content": "This is a comment",
    "task": 1,
    "task_title": "Complete API documentation",
    "author": 1,
    "author_username": "admin",
    "author_email": "admin@example.com",
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 5.3 Get Comment Detail

**GET** `/api/v1/comments/{id}/`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
    "id": 1,
    "content": "Great progress on this!",
    "task": 1,
    "task_title": "Complete API documentation",
    "author": 1,
    "author_username": "admin",
    "author_email": "admin@example.com",
    "created_at": "2026-01-15T12:00:00Z",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 5.4 Update Comment

**PUT/PATCH** `/api/v1/comments/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Comment author or Admin

**Request:**
```json
{
    "content": "Updated comment content"
}
```

**Response (200 OK):**
```json
{
    "id": 1,
    "content": "Updated comment content",
    "updated_at": "2026-01-15T12:00:00Z"
}
```

#### 5.5 Delete Comment

**DELETE** `/api/v1/comments/{id}/`

**Headers:** `Authorization: Bearer <token>`
**Permissions:** Comment author, project manager, or Admin

**Response (204 No Content)**

#### 5.6 Get Comments by Task

**GET** `/api/v1/comments/by_task/?task_id={task_id}`

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `task_id` | integer | Required - Task ID |
| `search` | string | Search in content |
| `author` | integer | Filter by author ID |

**Response (200 OK):**
```json
{
    "count": 3,
    "results": [
        {
            "id": 1,
            "content": "Comment 1",
            "author_username": "admin",
            "created_at": "2026-01-15T12:00:00Z"
        }
    ]
}
```

---

## Error Response Format

### Validation Errors (400 Bad Request)

```json
{
    "title": ["This field is required."],
    "due_date": ["Date must be in the future."],
    "non_field_errors": ["A task with this title already exists."]
}
```

### Authentication Error (401 Unauthorized)

```json
{
    "detail": "Authentication credentials were not provided."
}
```

### Permission Error (403 Forbidden)

```json
{
    "detail": "You do not have permission to perform this action."
}
```

### Not Found Error (404 Not Found)

```json
{
    "detail": "Task not found."
}
```

### Rate Limit Error (429 Too Many Requests)

```json
{
    "detail": "Rate limit exceeded. Please try again later.",
    "error": "RATE_LIMIT_EXCEEDED"
}
```

### Server Error (500 Internal Server Error)

```json
{
    "detail": "Internal server error."
}
```

---

## Role-Based Permission Matrix

| Action | Admin | Manager | Member | Viewer |
|--------|-------|---------|--------|--------|
| **Users** |
| List users | ✅ | ✅ | ❌ | ❌ |
| Get user profile | ✅ | ✅ | ✅ | ✅ |
| Create user | ✅ | ✅ | ❌ | ❌ |
| Update user | ✅ | ✅ | ❌ | ❌ |
| Delete user | ✅ | ❌ | ❌ | ❌ |
| Set user role | ✅ | ✅ | ❌ | ❌ |
| **Projects** |
| List projects | ✅ | ✅ | ✅ | ✅ |
| Create project | ✅ | ✅ | ❌ | ❌ |
| Update project | ✅ | ✅ | ❌ | ❌ |
| Delete project | ✅ | ✅ | ❌ | ❌ |
| **Tasks** |
| List tasks | ✅ | ✅ | ✅ | ✅ |
| Create task | ✅ | ✅ | ✅ | ❌ |
| Update task | ✅ | ✅ | ✅ | ❌ |
| Delete task | ✅ | ✅ | ✅ | ❌ |
| Update status | ✅ | ✅ | ✅ | ❌ |
| **Comments** |
| List comments | ✅ | ✅ | ✅ | ✅ |
| Create comment | ✅ | ✅ | ✅ | ❌ |
| Update comment | ✅ | ✅ | ✅ | ❌ |
| Delete comment | ✅ | ✅ | ✅ | ❌ |

---

*This concludes Appendix B. Use this API reference as your guide when integrating with the TaskFlow API.*
