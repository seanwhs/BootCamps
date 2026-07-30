# Appendix B: API Reference and Endpoint Documentation

## Overview

This appendix provides complete documentation for all API endpoints, request/response schemas, WebSocket events, and error codes. Use this as a reference when integrating with the RAG Agent System or debugging API interactions.

---

## B.1 API Base Information

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication
For production use, the API supports JWT Bearer token authentication:

```
Authorization: Bearer <your_jwt_token>
```

### Content Type
All requests and responses use `application/json` unless otherwise specified.

### Common Response Format

#### Success Response
```json
{
  "data": {
    // Response data varies by endpoint
  },
  "metadata": {
    "timestamp": "2026-07-30T12:00:00.000Z",
    "traceId": "trace-123456789",
    "duration": 150
  }
}
```

#### Error Response
```json
{
  "error": "Error Message",
  "details": ["Additional details"],
  "timestamp": "2026-07-30T12:00:00.000Z",
  "traceId": "trace-123456789"
}
```

### HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

---

## B.2 Query Endpoints

### Execute a Query

**Endpoint:** `POST /api/v1/queries`

Execute a RAG query or agent workflow.

#### Request Body

```json
{
  "query": "string (required) - The question to ask",
  "topK": 5, // Optional, default: 5, min: 1, max: 20
  "includeSources": true, // Optional, default: true
  "promptStyle": "detailed", // Optional: "concise" | "detailed" | "reasoning" | "socratic" | "expert"
  "useAgent": false, // Optional, default: false
  "maxIterations": 5, // Optional, default: 5, min: 1, max: 10
  "metadataFilters": { // Optional
    "department": "engineering",
    "accessLevel": "internal"
  }
}
```

#### Response

**Standard Pipeline Response:**
```json
{
  "answer": "RAG stands for Retrieval-Augmented Generation. It enhances LLMs by providing external context...",
  "confidence": 0.85,
  "sources": [
    {
      "content": "RAG is a technique that combines retrieval and generation...",
      "score": 0.92,
      "source": "docs/sample.txt"
    }
  ],
  "metadata": {
    "traceId": "trace-123456789",
    "duration": 250,
    "agent": false,
    "timestamp": "2026-07-30T12:00:00.000Z"
  }
}
```

**Agent Response:**
```json
{
  "answer": "RAG reduces hallucinations by grounding responses in actual data...",
  "confidence": 0.78,
  "sources": [
    {
      "content": "Benefits of RAG include reducing hallucinations...",
      "relevance": 0.85,
      "source": "doc/sample.txt"
    }
  ],
  "metadata": {
    "traceId": "trace-123456789",
    "iteration": 2,
    "status": "completed",
    "duration": 350,
    "agent": true,
    "timestamp": "2026-07-30T12:00:00.000Z"
  }
}
```

#### Error Response
```json
{
  "error": "Validation Error",
  "details": ["query: Query cannot be empty"],
  "timestamp": "2026-07-30T12:00:00.000Z",
  "traceId": "trace-123456789"
}
```

### Stream a Query

**Endpoint:** `GET /api/v1/queries/stream`

Stream real-time updates for a query using Server-Sent Events (SSE).

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| query | string | Required - The question to ask |
| useAgent | boolean | Optional, default: true |
| maxIterations | number | Optional, default: 5 |

#### Event Stream Format

```
data: {"type":"agent_event","data":{"status":"searching"},"timestamp":"2026-07-30T12:00:00.000Z"}

data: {"type":"agent_event","data":{"status":"evaluating"},"timestamp":"2026-07-30T12:00:00.000Z"}

data: {"type":"agent_event","data":{"status":"generating"},"timestamp":"2026-07-30T12:00:00.000Z"}

data: {"type":"agent_event","data":{"status":"completed"},"timestamp":"2026-07-30T12:00:00.000Z"}

data: [DONE]
```

#### Event Types

| Event Type | Description |
|------------|-------------|
| agent_event | Agent status update or result |
| token | Individual token from streaming generation |
| error | Error occurred |
| [DONE] | Stream complete |

### Get Query History

**Endpoint:** `GET /api/v1/queries/history`

Retrieve query history for the current user.

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| limit | number | 10 | Number of queries to return |
| offset | number | 0 | Pagination offset |

#### Response

```json
{
  "queries": [
    {
      "id": "query-123",
      "query": "What is RAG?",
      "answer": "RAG stands for Retrieval-Augmented Generation...",
      "confidence": 0.85,
      "status": "completed",
      "timestamp": "2026-07-30T12:00:00.000Z",
      "duration": 250
    }
  ],
  "total": 42,
  "limit": 10,
  "offset": 0
}
```

### Get Query Details

**Endpoint:** `GET /api/v1/queries/:id`

Retrieve detailed information about a specific query.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Query ID |

#### Response

```json
{
  "id": "query-123",
  "query": "What is RAG?",
  "answer": "RAG stands for Retrieval-Augmented Generation...",
  "confidence": 0.85,
  "status": "completed",
  "sources": [
    {
      "id": "doc-456",
      "content": "RAG is a technique that combines retrieval and generation...",
      "score": 0.92
    }
  ],
  "metadata": {
    "traceId": "trace-123456789",
    "duration": 250,
    "agent": false
  },
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

---

## B.3 Ingestion Endpoints

### Ingest Documents

**Endpoint:** `POST /api/v1/ingestion`

Ingest documents from a directory or file path.

#### Request Body

```json
{
  "path": "./docs", // Required - Directory or file path
  "extensionFilter": ["txt", "md", "pdf"], // Optional
  "dryRun": false // Optional - Test without storing
}
```

#### Response

```json
{
  "documentsLoaded": 5,
  "chunksCreated": 42,
  "chunksStored": 42,
  "jobId": "ingest-123456789"
}
```

#### Error Response
```json
{
  "error": "Path not found",
  "details": ["The specified path does not exist"],
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

### Get Ingestion Status

**Endpoint:** `GET /api/v1/ingestion/:jobId`

Get the status of an ingestion job.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| jobId | string | Job ID from ingestion request |

#### Response

```json
{
  "jobId": "ingest-123456789",
  "status": "completed", // pending, processing, completed, failed
  "progress": 100,
  "result": {
    "documentsLoaded": 5,
    "chunksStored": 42
  },
  "error": null,
  "createdAt": "2026-07-30T12:00:00.000Z",
  "completedAt": "2026-07-30T12:01:00.000Z"
}
```

### List Sources

**Endpoint:** `GET /api/v1/ingestion/sources`

List all ingested document sources.

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| limit | number | 50 | Number of sources to return |
| offset | number | 0 | Pagination offset |
| type | string | - | Filter by source type (file, url, s3) |

#### Response

```json
{
  "sources": [
    {
      "id": "src-123",
      "name": "sample.txt",
      "path": "./docs/sample.txt",
      "type": "file",
      "documentCount": 42,
      "createdAt": "2026-07-30T12:00:00.000Z"
    }
  ],
  "total": 5,
  "limit": 50,
  "offset": 0
}
```

### Delete Source

**Endpoint:** `DELETE /api/v1/ingestion/sources/:sourceId`

Delete an ingested source and all its documents.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| sourceId | string | Source ID |

#### Response

```json
{
  "success": true,
  "sourceId": "src-123",
  "documentsDeleted": 42,
  "deletedAt": "2026-07-30T12:00:00.000Z"
}
```

---

## B.4 Checkpoint Endpoints

### List Checkpoints

**Endpoint:** `GET /api/v1/checkpoints`

List all agent checkpoints.

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| limit | number | 20 | Number of checkpoints to return |
| offset | number | 0 | Pagination offset |
| status | string | - | Filter by status |

#### Response

```json
{
  "checkpoints": [
    {
      "id": "cp-123",
      "threadId": "thread-456",
      "metadata": {
        "node": "evaluate",
        "iteration": 2,
        "status": "searching"
      },
      "timestamp": "2026-07-30T12:00:00.000Z"
    }
  ],
  "total": 10,
  "limit": 20,
  "offset": 0
}
```

### Get Checkpoint

**Endpoint:** `GET /api/v1/checkpoints/:id`

Get detailed information about a checkpoint.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Checkpoint ID |

#### Response

```json
{
  "id": "cp-123",
  "threadId": "thread-456",
  "state": {
    "query": "What is RAG?",
    "iteration": 2,
    "evidenceQuality": 0.65,
    "evidence": [
      {
        "content": "RAG reduces hallucinations...",
        "relevance": 0.85
      }
    ]
  },
  "metadata": {
    "node": "evaluate",
    "iteration": 2,
    "status": "searching"
  },
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

### Resume from Checkpoint

**Endpoint:** `POST /api/v1/checkpoints/:id/resume`

Resume an agent workflow from a checkpoint.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Checkpoint ID |

#### Response

```json
{
  "success": true,
  "checkpointId": "cp-123",
  "result": {
    "status": "completed",
    "iteration": 3,
    "finalAnswer": "RAG is a technique that..."
  }
}
```

### Delete Checkpoint

**Endpoint:** `DELETE /api/v1/checkpoints/:id`

Delete a checkpoint.

#### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | string | Checkpoint ID |

#### Response

```json
{
  "success": true,
  "checkpointId": "cp-123",
  "deletedAt": "2026-07-30T12:00:00.000Z"
}
```

---

## B.5 Admin Endpoints

### System Status

**Endpoint:** `GET /api/v1/admin/status`

Get overall system health and status.

#### Response

```json
{
  "status": "operational",
  "timestamp": "2026-07-30T12:00:00.000Z",
  "uptime": 3600,
  "components": {
    "database": {
      "healthy": true,
      "stats": {
        "total_documents": 420,
        "avg_content_length": 512,
        "oldest_document": "2026-07-29T10:00:00.000Z",
        "newest_document": "2026-07-30T11:00:00.000Z"
      }
    },
    "reranker": {
      "loaded": true
    },
    "telemetry": {
      "status": "healthy",
      "totalTraces": 123,
      "errorRate": 0.05,
      "avgLatencyMs": 250
    }
  },
  "checkpoints": {
    "total": 15
  }
}
```

### Clear Cache

**Endpoint:** `POST /api/v1/admin/cache/clear`

Clear system caches (reranker model, etc.).

#### Response

```json
{
  "success": true,
  "message": "Cache cleared successfully",
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

### Clean Up Data

**Endpoint:** `POST /api/v1/admin/cleanup`

Clean up old data and checkpoints.

#### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| maxAgeHours | number | 24 | Maximum age of data to keep |

#### Response

```json
{
  "success": true,
  "deletedCheckpoints": 10,
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

### Reload BM25 Index

**Endpoint:** `POST /api/v1/admin/index/reload`

Force reload the BM25 lexical index.

#### Response

```json
{
  "success": true,
  "message": "BM25 index reloaded",
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

---

## B.6 Health and Metrics

### Health Check

**Endpoint:** `GET /health`

Simple health check endpoint for load balancers.

#### Response

```json
{
  "status": "healthy",
  "timestamp": "2026-07-30T12:00:00.000Z",
  "uptime": 3600
}
```

### Metrics

**Endpoint:** `GET /metrics`

Get system metrics (Prometheus compatible).

#### Response

```json
{
  "traces": [
    // Recent traces
  ],
  "aggregated": {
    "avgLatency": 250,
    "totalQueries": 123,
    "errorRate": 0.05
  }
}
```

---

## B.7 WebSocket Events

### WebSocket Connection

**Endpoint:** `ws://localhost:3000/ws`

Connect to the WebSocket server for real-time updates.

#### Connection Request

```json
{
  "type": "connect",
  "sessionId": "session-123",
  "authToken": "jwt-token" // Optional
}
```

### Events

#### Agent Progress Event

```json
{
  "type": "agent_progress",
  "data": {
    "status": "searching",
    "iteration": 1,
    "message": "Searching for relevant documents..."
  },
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

#### Query Result Event

```json
{
  "type": "query_result",
  "data": {
    "answer": "RAG is a technique that...",
    "confidence": 0.85,
    "sources": [...]
  },
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

#### Token Stream Event

```json
{
  "type": "token",
  "data": {
    "token": "RAG",
    "complete": false
  },
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

#### Error Event

```json
{
  "type": "error",
  "data": {
    "error": "Something went wrong",
    "recoverable": true
  },
  "timestamp": "2026-07-30T12:00:00.000Z"
}
```

### Subscribing to Events

```json
{
  "type": "subscribe",
  "events": ["agent_progress", "query_result"],
  "queryId": "query-123"
}
```

---

## B.8 Error Codes Reference

| Error Code | Description | HTTP Status |
|------------|-------------|-------------|
| `VALIDATION_ERROR` | Request validation failed | 400 |
| `AUTH_REQUIRED` | Authentication required | 401 |
| `ACCESS_DENIED` | Insufficient permissions | 403 |
| `NOT_FOUND` | Resource not found | 404 |
| `RATE_LIMITED` | Too many requests | 429 |
| `RETRIEVAL_FAILED` | Search failed | 500 |
| `GENERATION_FAILED` | LLM generation failed | 500 |
| `INGESTION_FAILED` | Document ingestion failed | 500 |
| `CHECKPOINT_ERROR` | Checkpoint operation failed | 500 |
| `DATABASE_ERROR` | Database operation failed | 500 |
| `TIMEOUT_ERROR` | Operation timed out | 504 |

### Error Response Example

```json
{
  "error": "RETRIEVAL_FAILED",
  "message": "Failed to retrieve documents for the query",
  "details": ["OpenAI API rate limit exceeded"],
  "timestamp": "2026-07-30T12:00:00.000Z",
  "traceId": "trace-123456789"
}
```

---

## B.9 Rate Limiting

| Endpoint Type | Rate Limit |
|---------------|------------|
| Queries | 100 requests per minute |
| Ingestion | 10 requests per minute |
| Admin | 20 requests per minute |
| Health | 100 requests per minute |

**Rate Limit Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 2026-07-30T12:01:00.000Z
```

---

## B.10 API Examples

### cURL Examples

#### Execute a Query
```bash
curl -X POST http://localhost:3000/api/v1/queries \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What are the benefits of RAG?",
    "useAgent": true,
    "maxIterations": 3
  }'
```

#### Stream a Query
```bash
curl -N http://localhost:3000/api/v1/queries/stream?query="What is RAG?"&useAgent=true
```

#### Ingest Documents
```bash
curl -X POST http://localhost:3000/api/v1/ingestion \
  -H "Content-Type: application/json" \
  -d '{
    "path": "./docs",
    "extensionFilter": ["txt", "md"]
  }'
```

#### Resume from Checkpoint
```bash
curl -X POST http://localhost:3000/api/v1/checkpoints/cp-123/resume
```

### JavaScript Examples

```javascript
// Execute a query
const response = await fetch('http://localhost:3000/api/v1/queries', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    query: 'What is RAG?',
    useAgent: true,
    maxIterations: 3,
  }),
});

const data = await response.json();
console.log(data.answer);

// Stream a query
const eventSource = new EventSource(
  'http://localhost:3000/api/v1/queries/stream?query=What is RAG?&useAgent=true'
);

eventSource.onmessage = (event) => {
  if (event.data === '[DONE]') {
    eventSource.close();
    return;
  }
  const data = JSON.parse(event.data);
  console.log(data);
};
```

### Python Examples

```python
import requests
import json

# Execute a query
response = requests.post(
    'http://localhost:3000/api/v1/queries',
    json={
        'query': 'What is RAG?',
        'useAgent': True,
        'maxIterations': 3
    }
)

data = response.json()
print(data['answer'])

# Stream a query
import sseclient

response = requests.get(
    'http://localhost:3000/api/v1/queries/stream',
    params={'query': 'What is RAG?', 'useAgent': True},
    stream=True
)

client = sseclient.SSEClient(response)
for event in client.events():
    if event.data == '[DONE]':
        break
    data = json.loads(event.data)
    print(data)
```

---

## B.11 Authentication (Optional)

### JWT Token Endpoint

**Endpoint:** `POST /api/v1/auth/login`

Login and receive a JWT token.

#### Request Body
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Response
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": "7d",
  "user": {
    "id": "user-123",
    "email": "user@example.com",
    "role": "admin"
  }
}
```

### Using the Token
```bash
curl -X POST http://localhost:3000/api/v1/queries \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"query": "What is RAG?"}'
```

---

## B.12 Swagger Documentation

The API includes interactive Swagger documentation at:

```
http://localhost:3000/docs
```

Features:
- Browse all endpoints
- Test requests directly from the browser
- View request/response schemas
- Download OpenAPI specification

---

**[APPENDIX B — COMPLETE]**
