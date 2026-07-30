# Appendix C: Complete API Documentation

## REST API Reference for the Orchestrator System

This appendix provides comprehensive documentation for all API endpoints in the Orchestrator system. Think of this as the user manual for your API - showing exactly how to interact with every feature.

### 1. API Overview

#### Base URL
```
http://localhost:3000
https://your-api-gateway-url.com
```

#### Authentication
Most endpoints require authentication via JWT token:
```
Authorization: Bearer <your-jwt-token>
```

#### Common Response Formats

**Success Response:**
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Error message",
  "statusCode": 400,
  "requestId": "req_123456"
}
```

#### HTTP Status Codes
| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 422 | Validation Error |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

### 2. Health & Monitoring Endpoints

#### Health Check

**Endpoint:** `GET /health`

**Description:** Basic service health check

**Response:**
```json
{
  "status": "ok",
  "service": "gateway",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:50.123Z"
}
```

#### Readiness Probe

**Endpoint:** `GET /health/ready`

**Description:** Service readiness check (for Kubernetes)

**Response:**
```json
{
  "status": "ready",
  "service": "gateway",
  "version": "1.0.0",
  "uptime": "1m 32s"
}
```

#### Liveness Probe

**Endpoint:** `GET /health/live`

**Description:** Service liveness check (for Kubernetes)

**Response:**
```json
{
  "status": "alive",
  "timestamp": "2024-01-15T10:30:55.456Z"
}
```

#### Metrics

**Endpoint:** `GET /metrics`

**Description:** Service performance metrics

**Response:**
```json
{
  "service": "gateway",
  "version": "1.0.0",
  "requestCount": 1523,
  "errorCount": 12,
  "errorRate": 0.79,
  "averageDuration": 45,
  "statusCodes": {
    "200": 1400,
    "404": 100,
    "500": 23
  },
  "uptime": 86400
}
```

#### Detailed Status (Development)

**Endpoint:** `GET /status`

**Description:** Detailed service status (development only)

**Response:**
```json
{
  "service": "gateway",
  "version": "1.0.0",
  "environment": "development",
  "uptime": "2h 15m",
  "process": {
    "pid": 12345,
    "memory": {
      "rss": 52707328,
      "heapTotal": 40894464,
      "heapUsed": 35123456
    },
    "cpu": { "user": 120000, "system": 45000 },
    "versions": {
      "node": "20.10.0",
      "v8": "11.3.244.8-node.16"
    }
  },
  "runtime": {
    "eventLoop": { "lag": 0.023 }
  }
}
```

### 3. User Management Endpoints

#### Create User

**Endpoint:** `POST /api/users`

**Description:** Register a new user

**Request Body:**
```json
{
  "email": "john@example.com",
  "username": "john_doe",
  "password": "SecurePass123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Validation Rules:**
- `email`: Valid email format, max 255 chars
- `username`: 3-30 chars, alphanumeric + underscore
- `password`: 8-100 chars
- `firstName`: 1-50 chars (optional)
- `lastName`: 1-50 chars (optional)

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john@example.com",
    "username": "john_doe",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "createdAt": "2024-01-15T10:30:50.123Z",
    "updatedAt": "2024-01-15T10:30:50.123Z",
    "isActive": true,
    "lastLoginAt": null
  },
  "message": "User created successfully"
}
```

#### Get User

**Endpoint:** `GET /api/users/:userId`

**Description:** Get user by ID

**Parameters:**
- `userId` (path): UUID of the user

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john@example.com",
    "username": "john_doe",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "createdAt": "2024-01-15T10:30:50.123Z",
    "updatedAt": "2024-01-15T10:30:50.123Z",
    "isActive": true,
    "lastLoginAt": null
  }
}
```

**Error (404 Not Found):**
```json
{
  "success": false,
  "message": "User not found"
}
```

#### Update User

**Endpoint:** `PUT /api/users/:userId`

**Description:** Update user profile

**Request Body:**
```json
{
  "firstName": "Jonathan",
  "lastName": "Smith"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "firstName": "Jonathan",
    "lastName": "Smith",
    "fullName": "Jonathan Smith"
  },
  "message": "User updated successfully"
}
```

#### Deactivate User

**Endpoint:** `DELETE /api/users/:userId`

**Description:** Deactivate user account

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User deactivated successfully"
}
```

#### Reactivate User

**Endpoint:** `POST /api/users/:userId/reactivate`

**Description:** Reactivate a deactivated user

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User reactivated successfully"
}
```

### 4. Task Management Endpoints

#### Create Task

**Endpoint:** `POST /api/tasks`

**Description:** Create a new task

**Request Body:**
```json
{
  "title": "Build the API",
  "description": "Complete the Hexagonal Architecture implementation",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "priority": "high",
  "dueDate": "2024-12-31T23:59:59Z"
}
```

**Validation Rules:**
- `title`: 3-255 chars
- `description`: 10-5000 chars
- `userId`: Valid UUID
- `priority`: low, medium, high, critical (default: medium)
- `dueDate`: Future date (optional)

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "title": "Build the API",
    "description": "Complete the Hexagonal Architecture implementation",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "status": "pending",
    "priority": "high",
    "dueDate": "2024-12-31T23:59:59.000Z",
    "createdAt": "2024-01-15T10:30:50.123Z",
    "updatedAt": "2024-01-15T10:30:50.123Z",
    "completedAt": null
  },
  "message": "Task created successfully"
}
```

#### Get Task

**Endpoint:** `GET /api/tasks/:taskId?userId=<userId>`

**Description:** Get a task by ID (requires userId query param)

**Query Parameters:**
- `userId` (required): UUID of the task owner

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "title": "Build the API",
    "description": "Complete the Hexagonal Architecture implementation",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "status": "pending",
    "priority": "high",
    "dueDate": "2024-12-31T23:59:59.000Z",
    "createdAt": "2024-01-15T10:30:50.123Z",
    "updatedAt": "2024-01-15T10:30:50.123Z",
    "completedAt": null,
    "isOverdue": false
  }
}
```

#### Update Task

**Endpoint:** `PUT /api/tasks/:taskId`

**Description:** Update a task

**Request Body:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Build the API - Updated",
  "description": "Complete the Hexagonal Architecture implementation with tests",
  "priority": "critical",
  "dueDate": "2025-01-15T23:59:59Z",
  "status": "in_progress"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "title": "Build the API - Updated",
    "status": "in_progress",
    "priority": "critical"
  },
  "message": "Task updated successfully"
}
```

#### Delete Task

**Endpoint:** `DELETE /api/tasks/:taskId?userId=<userId>`

**Description:** Delete a task (requires userId query param)

**Query Parameters:**
- `userId` (required): UUID of the task owner

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Task deleted successfully"
}
```

#### Start Task

**Endpoint:** `POST /api/tasks/:taskId/start`

**Description:** Start working on a task

**Request Body:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "status": "in_progress"
  },
  "message": "Task started successfully"
}
```

#### Complete Task

**Endpoint:** `POST /api/tasks/:taskId/complete`

**Description:** Mark a task as completed

**Request Body:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "status": "completed",
    "completedAt": "2024-01-15T10:30:50.123Z"
  },
  "message": "Task completed successfully"
}
```

#### Fail Task

**Endpoint:** `POST /api/tasks/:taskId/fail`

**Description:** Mark a task as failed

**Request Body:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "reason": "Unable to complete due to missing requirements"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "status": "failed"
  },
  "message": "Task failed successfully"
}
```

#### Cancel Task

**Endpoint:** `POST /api/tasks/:taskId/cancel`

**Description:** Cancel a task

**Request Body:**
```json
{
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "reason": "No longer needed"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "status": "cancelled"
  },
  "message": "Task cancelled successfully"
}
```

### 5. Task Collection Endpoints

#### Get User Tasks

**Endpoint:** `GET /api/users/:userId/tasks`

**Description:** Get all tasks for a user

**Parameters:**
- `userId` (path): UUID of the user

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "title": "Build the API",
      "description": "Complete the Hexagonal Architecture implementation",
      "status": "pending",
      "priority": "high",
      "dueDate": "2024-12-31T23:59:59.000Z",
      "createdAt": "2024-01-15T10:30:50.123Z"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "title": "Write Tests",
      "description": "Add comprehensive test coverage",
      "status": "completed",
      "priority": "medium",
      "dueDate": "2024-01-15T23:59:59.000Z",
      "completedAt": "2024-01-14T15:30:00.000Z"
    }
  ],
  "count": 2
}
```

#### Get Overdue Tasks

**Endpoint:** `GET /api/users/:userId/tasks/overdue`

**Description:** Get overdue tasks for a user

**Parameters:**
- `userId` (path): UUID of the user

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "title": "Submit Report",
      "description": "Weekly status report",
      "status": "pending",
      "priority": "high",
      "dueDate": "2024-01-10T23:59:59.000Z",
      "isOverdue": true
    }
  ],
  "count": 1
}
```

### 6. Monitoring & Management Endpoints

#### Queue Statistics

**Endpoint:** `GET /queue/stats`

**Description:** Get task queue statistics

**Response:**
```json
{
  "success": true,
  "stats": {
    "tasks": {
      "size": 0,
      "processing": true
    },
    "dead-letter": {
      "size": 0,
      "processing": false
    }
  }
}
```

#### Tracing Statistics

**Endpoint:** `GET /tracing/stats`

**Description:** Get distributed tracing statistics

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalSpans": 1523,
    "currentTraces": 12,
    "traces": {
      "trace_1705300000000_abc123": {
        "spanCount": 5,
        "duration": 245
      }
    }
  }
}
```

### 7. AI Agent Endpoints

#### Process Task with AI

**Endpoint:** `POST /api/agents/task`

**Description:** Process a task using the AI agent

**Request Body:**
```json
{
  "taskId": "550e8400-e29b-41d4-a716-446655440001",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "action": "process",
  "instructions": "Review and approve the task"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "taskId": "550e8400-e29b-41d4-a716-446655440001",
    "status": "processed",
    "agentResponse": "Task has been reviewed and approved",
    "suggestions": [
      "Add more test coverage",
      "Update documentation"
    ]
  }
}
```

### 8. Admin Endpoints

#### Health Check Admin Tool

**Endpoint:** `GET /admin/health`

**Description:** Admin health check

**Response:**
```json
{
  "status": "healthy",
  "services": {
    "database": "connected",
    "redis": "connected",
    "queue": "running"
  }
}
```

#### Rebuild Projection

**Endpoint:** `POST /admin/projections/rebuild`

**Description:** Rebuild read model projections

**Request Body:**
```json
{
  "projection": "user" // or "task" or "all"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Projection rebuild started",
  "projection": "user"
}
```

### 9. Rate Limiting

Rate limits are applied per user/IP address:

| Endpoint Category | Limit |
|-------------------|-------|
| Public endpoints | 100 requests/minute |
| Authenticated endpoints | 1000 requests/minute |
| Admin endpoints | 50 requests/minute |
| Task processing | 500 requests/minute |

Rate limit headers are included in responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 2024-01-15T10:35:00Z
```

### 10. Error Codes Reference

| Code | Message | Description |
|------|---------|-------------|
| 4001 | VALIDATION_ERROR | Request validation failed |
| 4002 | INVALID_EMAIL | Email format is invalid |
| 4003 | INVALID_PASSWORD | Password doesn't meet requirements |
| 4004 | INVALID_UUID | Invalid UUID format |
| 4005 | DUPLICATE_EMAIL | Email already registered |
| 4006 | DUPLICATE_USERNAME | Username already taken |
| 4007 | INVALID_STATUS | Invalid task status |
| 4008 | INVALID_PRIORITY | Invalid task priority |
| 4009 | PAST_DUE_DATE | Due date must be in the future |
| 4041 | USER_NOT_FOUND | User does not exist |
| 4042 | TASK_NOT_FOUND | Task does not exist |
| 4043 | RESOURCE_NOT_FOUND | Requested resource not found |
| 4091 | CONFLICT | Resource conflict |
| 4291 | RATE_LIMITED | Rate limit exceeded |
| 5001 | INTERNAL_ERROR | Internal server error |
| 5002 | DATABASE_ERROR | Database operation failed |
| 5003 | CACHE_ERROR | Cache operation failed |
| 5004 | QUEUE_ERROR | Queue operation failed |
| 5005 | AI_SERVICE_ERROR | AI service error |

### 11. API Testing Examples

#### Test Script (Bash)

```bash
#!/bin/bash

# Configuration
BASE_URL="http://localhost:3000"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Testing Orchestrator API..."

# 1. Health Check
echo -n "Health Check: "
response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health)
if [ "$response" = "200" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ (HTTP $response)${NC}"
    exit 1
fi

# 2. Create User
echo -n "Create User: "
response=$(curl -s -X POST $BASE_URL/api/users \
    -H "Content-Type: application/json" \
    -d '{
        "email": "test@example.com",
        "username": "testuser",
        "password": "SecurePass123",
        "firstName": "Test",
        "lastName": "User"
    }')
status=$(echo $response | jq -r '.success')
if [ "$status" = "true" ]; then
    echo -e "${GREEN}✓${NC}"
    USER_ID=$(echo $response | jq -r '.data.id')
else
    echo -e "${RED}✗${NC}"
    echo $response | jq '.'
    exit 1
fi

# 3. Create Task
echo -n "Create Task: "
response=$(curl -s -X POST $BASE_URL/api/tasks \
    -H "Content-Type: application/json" \
    -d "{
        \"title\": \"Test Task\",
        \"description\": \"API test task\",
        \"userId\": \"$USER_ID\",
        \"priority\": \"high\"
    }")
status=$(echo $response | jq -r '.success')
if [ "$status" = "true" ]; then
    echo -e "${GREEN}✓${NC}"
    TASK_ID=$(echo $response | jq -r '.data.id')
else
    echo -e "${RED}✗${NC}"
    echo $response | jq '.'
    exit 1
fi

echo -e "\n${GREEN}✓ All tests passed!${NC}"
echo "User ID: $USER_ID"
echo "Task ID: $TASK_ID"
```

#### JavaScript Test Example

```javascript
import axios from 'axios';

const BASE_URL = 'http://localhost:3000';

async function testAPI() {
  try {
    // 1. Health Check
    const health = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Health Check:', health.data.status);

    // 2. Create User
    const user = await axios.post(`${BASE_URL}/api/users`, {
      email: 'test@example.com',
      username: 'testuser',
      password: 'SecurePass123',
      firstName: 'Test',
      lastName: 'User'
    });
    console.log('✅ User Created:', user.data.data.id);
    const userId = user.data.data.id;

    // 3. Create Task
    const task = await axios.post(`${BASE_URL}/api/tasks`, {
      title: 'Test Task',
      description: 'API test task',
      userId: userId,
      priority: 'high'
    });
    console.log('✅ Task Created:', task.data.data.id);
    const taskId = task.data.data.id;

    // 4. Complete Task
    await axios.post(`${BASE_URL}/api/tasks/${taskId}/complete`, {
      userId: userId
    });
    console.log('✅ Task Completed');

    // 5. Get User Tasks
    const tasks = await axios.get(`${BASE_URL}/api/users/${userId}/tasks`);
    console.log('✅ User Tasks:', tasks.data.count);

  } catch (error) {
    console.error('❌ Test Failed:', error.response?.data || error.message);
  }
}

testAPI();
```

---

This API documentation provides a complete reference for all endpoints in the Orchestrator system. Use it when building clients, testing the API, or debugging integration issues.
