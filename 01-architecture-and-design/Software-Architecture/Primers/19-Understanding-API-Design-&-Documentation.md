# Primer 19: Understanding API Design & Documentation

## A Comprehensive Guide to Building Great APIs

Welcome to the nineteenth primer! This is a comprehensive deep dive into API design and documentation - the art and science of creating interfaces that other developers love to use. Think of this like designing the menu and ordering system for your restaurant chain - it needs to be clear, consistent, and easy for customers (developers) to understand and use.

### 1. The Big Picture

#### API Design Principles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    API DESIGN PRINCIPLES                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    API-FIRST DESIGN                                  │   │
│  │  • Design before implementation                                    │   │
│  │  • Contract-driven development                                     │   │
│  │  • Consumer-focused                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    RESTFUL PRINCIPLES                               │   │
│  │  • Resource-based                                                  │   │
│  │  • HTTP methods (GET, POST, PUT, DELETE)                          │   │
│  │  • Stateless                                                       │   │
│  │  • Cacheable                                                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DOCUMENTATION                                    │   │
│  │  • OpenAPI/Swagger                                                 │   │
│  │  • Examples                                                        │   │
│  │  • Interactive docs                                                │   │
│  │  • Versioning                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. API Design Principles

#### Resource Naming

```typescript
// Resource naming conventions
const ResourcePatterns = {
    // ✅ GOOD: Plural nouns
    'GET /users': 'List users',
    'GET /users/:id': 'Get a user',
    'POST /users': 'Create a user',
    'PUT /users/:id': 'Update a user',
    'DELETE /users/:id': 'Delete a user',
    
    // ❌ BAD: Verb-based
    'GET /getUsers': '❌ Avoid verbs in URLs',
    'POST /createUser': '❌ Use HTTP methods instead',
    
    // ✅ GOOD: Nested resources
    'GET /users/:userId/tasks': 'Get user tasks',
    'POST /users/:userId/tasks': 'Create task for user',
    'GET /users/:userId/tasks/:taskId': 'Get user task',
    
    // ✅ GOOD: Resource relationships
    'GET /tasks/:taskId/assignees': 'Get task assignees',
    'POST /tasks/:taskId/assignees': 'Assign task',
};
```

#### HTTP Methods & Status Codes

```typescript
// HTTP Method Guide
const HTTPMethods = {
    GET: {
        purpose: 'Retrieve a resource',
        safety: 'Safe (no side effects)',
        idempotent: true,
        cacheable: true,
        body: 'No',
    },
    POST: {
        purpose: 'Create a new resource',
        safety: 'Not safe',
        idempotent: false,
        cacheable: false,
        body: 'Yes',
    },
    PUT: {
        purpose: 'Replace a resource (full update)',
        safety: 'Not safe',
        idempotent: true,
        cacheable: false,
        body: 'Yes',
    },
    PATCH: {
        purpose: 'Partial update',
        safety: 'Not safe',
        idempotent: false,
        cacheable: false,
        body: 'Yes',
    },
    DELETE: {
        purpose: 'Delete a resource',
        safety: 'Not safe',
        idempotent: true,
        cacheable: false,
        body: 'No',
    },
};

// Status Code Guide
const StatusCodes = {
    '200 OK': {
        purpose: 'Request succeeded',
        useCases: ['GET successful', 'PUT/PATCH success'],
    },
    '201 Created': {
        purpose: 'Resource created',
        useCases: ['POST successful', 'Resource creation'],
    },
    '202 Accepted': {
        purpose: 'Request accepted, processing async',
        useCases: ['Batch operations', 'Long-running tasks'],
    },
    '204 No Content': {
        purpose: 'Request succeeded, no content',
        useCases: ['DELETE success', 'PUT/PATCH with no body'],
    },
    '400 Bad Request': {
        purpose: 'Invalid request',
        useCases: ['Validation errors', 'Malformed request'],
    },
    '401 Unauthorized': {
        purpose: 'Authentication required',
        useCases: ['Missing or invalid credentials'],
    },
    '403 Forbidden': {
        purpose: 'Insufficient permissions',
        useCases: ['User lacks required role'],
    },
    '404 Not Found': {
        purpose: 'Resource not found',
        useCases: ['Invalid ID', 'Resource doesn\'t exist'],
    },
    '409 Conflict': {
        purpose: 'Conflict with current state',
        useCases: ['Duplicate resource', 'Version conflict'],
    },
    '422 Unprocessable Entity': {
        purpose: 'Validation failed',
        useCases: ['Business rule violation'],
    },
    '429 Too Many Requests': {
        purpose: 'Rate limited',
        useCases: ['API rate limit exceeded'],
    },
    '500 Internal Server Error': {
        purpose: 'Server error',
        useCases: ['Unhandled server errors'],
    },
};
```

### 3. API Versioning Strategies

#### Versioning Implementation

```typescript
class APIVersioning {
    private logger: Logger;

    constructor() {
        this.logger = createLogger({ service: 'api-versioning' });
    }

    // Strategy 1: URL Path Versioning
    versionByPath(request: FastifyRequest): string | null {
        const path = request.url;
        const match = path.match(/^\/v(\d+)\//);
        return match ? `v${match[1]}` : null;
    }

    // Strategy 2: Header Versioning
    versionByHeader(request: FastifyRequest): string | null {
        return request.headers['api-version'] as string || null;
    }

    // Strategy 3: Query Parameter Versioning
    versionByQuery(request: FastifyRequest): string | null {
        const query = request.query as { api_version?: string };
        return query.api_version || null;
    }

    // Strategy 4: Content Negotiation
    versionByAccept(request: FastifyRequest): string | null {
        const accept = request.headers.accept;
        if (!accept) return null;
        
        const match = accept.match(/application\/vnd\.orchestrator\.v(\d+)\+json/);
        return match ? `v${match[1]}` : null;
    }

    // Version routing middleware
    versionMiddleware(versions: Map<string, any>) {
        return async (request: FastifyRequest, reply: FastifyReply) => {
            let version = this.versionByPath(request) || 
                          this.versionByHeader(request) ||
                          this.versionByQuery(request) ||
                          this.versionByAccept(request) ||
                          'v1'; // Default version

            const handler = versions.get(version);
            if (!handler) {
                reply.status(400).send({
                    error: 'Unsupported API version',
                    supportedVersions: Array.from(versions.keys()),
                });
                return;
            }

            // Store version for downstream use
            (request as any).apiVersion = version;
            await handler(request, reply);
        };
    }
}

// Example version handlers
class UserAPI {
    // v1: Simple user
    static v1 = {
        async getUser(request: FastifyRequest): Promise<any> {
            return {
                id: 'user-123',
                name: 'John Doe',
                email: 'john@example.com',
            };
        },
    };

    // v2: Enhanced user
    static v2 = {
        async getUser(request: FastifyRequest): Promise<any> {
            return {
                id: 'user-123',
                firstName: 'John',
                lastName: 'Doe',
                email: 'john@example.com',
                profile: {
                    avatar: 'https://example.com/avatar.jpg',
                    bio: 'Software Developer',
                },
                createdAt: '2024-01-01T00:00:00Z',
            };
        },
    };
}
```

### 4. Request/Response Design

#### Request Validation

```typescript
import { z } from 'zod';

class RequestValidator {
    // Define schemas
    static schemas = {
        createUser: z.object({
            email: z.string().email(),
            username: z.string().min(3).max(30),
            password: z.string().min(8),
            firstName: z.string().optional(),
            lastName: z.string().optional(),
        }),

        updateUser: z.object({
            firstName: z.string().optional(),
            lastName: z.string().optional(),
            email: z.string().email().optional(),
        }),

        createTask: z.object({
            title: z.string().min(3).max(255),
            description: z.string().min(10).max(5000),
            priority: z.enum(['low', 'medium', 'high', 'critical']),
            dueDate: z.string().datetime().optional(),
        }),

        updateTask: z.object({
            title: z.string().min(3).max(255).optional(),
            description: z.string().min(10).max(5000).optional(),
            priority: z.enum(['low', 'medium', 'high', 'critical']).optional(),
            status: z.enum(['pending', 'in_progress', 'completed', 'failed', 'cancelled']).optional(),
            dueDate: z.string().datetime().optional(),
        }),
    };

    // Validation middleware
    static validate(schema: z.ZodSchema) {
        return async (request: FastifyRequest, reply: FastifyReply) => {
            try {
                const validated = await schema.parseAsync(request.body);
                request.body = validated;
            } catch (error) {
                if (error instanceof z.ZodError) {
                    reply.status(422).send({
                        error: 'Validation Error',
                        details: error.errors.map(e => ({
                            field: e.path.join('.'),
                            message: e.message,
                        })),
                    });
                } else {
                    reply.status(400).send({ error: 'Invalid request' });
                }
            }
        };
    }
}
```

#### Response Envelopes

```typescript
class APIResponse {
    static success<T>(data: T, message?: string, meta?: Record<string, any>) {
        return {
            success: true,
            data,
            message,
            meta,
            timestamp: new Date().toISOString(),
            requestId: RequestContextManager.getRequestId(),
        };
    }

    static error(
        message: string,
        code: string = 'INTERNAL_ERROR',
        statusCode: number = 500,
        details?: any
    ) {
        return {
            success: false,
            error: {
                code,
                message,
                details,
            },
            timestamp: new Date().toISOString(),
            requestId: RequestContextManager.getRequestId(),
        };
    }

    static paginated<T>(
        data: T[],
        total: number,
        page: number,
        limit: number,
        message?: string
    ) {
        return {
            success: true,
            data,
            message,
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
                hasNext: page * limit < total,
                hasPrevious: page > 1,
            },
            timestamp: new Date().toISOString(),
            requestId: RequestContextManager.getRequestId(),
        };
    }

    static created<T>(data: T, location?: string, message?: string) {
        const response = this.success(data, message || 'Resource created');
        if (location) {
            return {
                ...response,
                location,
            };
        }
        return response;
    }
}

// Usage in controller
class UserController {
    async getUsers(request: FastifyRequest, reply: FastifyReply) {
        const { page = 1, limit = 10 } = request.query as { page: number; limit: number };
        
        const users = await this.userService.getUsers(page, limit);
        const total = await this.userService.countUsers();
        
        reply.send(APIResponse.paginated(users, total, page, limit));
    }

    async createUser(request: FastifyRequest, reply: FastifyReply) {
        const user = await this.userService.createUser(request.body);
        reply.code(201).send(APIResponse.created(
            user,
            `/api/users/${user.id}`,
            'User created successfully'
        ));
    }

    async getUser(request: FastifyRequest, reply: FastifyReply) {
        const { id } = request.params as { id: string };
        const user = await this.userService.getUser(id);
        
        if (!user) {
            reply.code(404).send(APIResponse.error(
                'User not found',
                'NOT_FOUND',
                404
            ));
            return;
        }
        
        reply.send(APIResponse.success(user));
    }
}
```

### 5. API Documentation

#### OpenAPI/Swagger Configuration

```typescript
import swagger from '@fastify/swagger';
import swaggerUI from '@fastify/swagger-ui';

class APIDocumentation {
    static setup(server: FastifyInstance) {
        // Swagger configuration
        server.register(swagger, {
            swagger: {
                info: {
                    title: 'Orchestrator API',
                    description: 'API documentation for the Orchestrator system',
                    version: '1.0.0',
                    contact: {
                        name: 'API Support',
                        email: 'support@orchestrator.com',
                    },
                    license: {
                        name: 'MIT',
                        url: 'https://opensource.org/licenses/MIT',
                    },
                },
                host: 'api.orchestrator.com',
                schemes: ['https'],
                consumes: ['application/json'],
                produces: ['application/json'],
                tags: [
                    { name: 'Users', description: 'User management endpoints' },
                    { name: 'Tasks', description: 'Task management endpoints' },
                    { name: 'Health', description: 'Health check endpoints' },
                ],
                securityDefinitions: {
                    Bearer: {
                        type: 'apiKey',
                        name: 'Authorization',
                        in: 'header',
                        description: 'JWT Bearer token',
                    },
                },
            },
        });

        // Swagger UI
        server.register(swaggerUI, {
            routePrefix: '/docs',
            uiConfig: {
                docExpansion: 'list',
                deepLinking: true,
            },
        });
    }

    // Documentation decorators
    static apiOperation(
        summary: string,
        description?: string,
        tags?: string[]
    ) {
        return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
            // Metadata for OpenAPI generation
            // Implementation depends on your OpenAPI generator
        };
    }

    static apiResponse(status: number, description: string, schema?: any) {
        return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
            // Metadata for OpenAPI generation
        };
    }
}

// Example controller with documentation
class DocumentedUserController {
    @APIDocumentation.apiOperation(
        'Get users',
        'Retrieves a paginated list of users'
    )
    @APIDocumentation.apiResponse(200, 'Users retrieved successfully')
    @APIDocumentation.apiResponse(401, 'Unauthorized')
    @APIDocumentation.apiResponse(500, 'Internal server error')
    async getUsers(request: FastifyRequest, reply: FastifyReply) {
        // Implementation
    }
}
```

### 6. API Testing

#### Contract Testing

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { ServiceClient } from '../src/infrastructure/services/service-client.js';

describe('API Contract Tests', () => {
    let client: ServiceClient;

    beforeAll(() => {
        client = new ServiceClient({
            baseUrl: 'http://localhost:3000',
            serviceName: 'gateway',
        });
    });

    it('should match user API contract', async () => {
        // Test structure of user response
        const response = await client.get('/api/users/123');
        
        expect(response).toHaveProperty('success');
        expect(response).toHaveProperty('data');
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('email');
        expect(response.data).toHaveProperty('username');
        expect(response.data).toHaveProperty('firstName');
        expect(response.data).toHaveProperty('lastName');
        expect(response.data).toHaveProperty('createdAt');
        expect(response.data).toHaveProperty('updatedAt');
        expect(response.data).toHaveProperty('isActive');
    });

    it('should match task API contract', async () => {
        const response = await client.get('/api/tasks/123?userId=456');
        
        expect(response).toHaveProperty('success');
        expect(response).toHaveProperty('data');
        expect(response.data).toHaveProperty('id');
        expect(response.data).toHaveProperty('title');
        expect(response.data).toHaveProperty('description');
        expect(response.data).toHaveProperty('status');
        expect(response.data).toHaveProperty('priority');
        expect(response.data).toHaveProperty('createdAt');
        expect(response.data).toHaveProperty('updatedAt');
    });

    it('should match error contract', async () => {
        try {
            await client.get('/api/users/nonexistent');
        } catch (error) {
            expect(error).toBeInstanceOf(ServiceError);
            expect(error).toHaveProperty('statusCode');
            expect(error).toHaveProperty('message');
            
            if (error instanceof ServiceError) {
                expect(error.statusCode).toBe(404);
                expect(error.message).toContain('User not found');
            }
        }
    });

    it('should match validation error contract', async () => {
        try {
            await client.post('/api/users', {
                email: 'invalid-email',
                username: 'a',
                password: 'short',
            });
        } catch (error) {
            expect(error).toBeInstanceOf(ServiceError);
            if (error instanceof ServiceError) {
                expect(error.statusCode).toBe(422);
                expect(error.responseBody).toContain('Validation Error');
            }
        }
    });
});
```

### 7. Key Takeaways

1. **API-First Design:**
   - Design contract before implementation
   - Consumer-focused
   - Document as you design

2. **RESTful Principles:**
   - Use resources, not verbs
   - Proper HTTP methods
   - Stateless communication
   - Cache appropriately

3. **Versioning Strategy:**
   - Choose consistent approach
   - Maintain backward compatibility
   - Deprecate gracefully

4. **Request/Response Design:**
   - Validate all inputs
   - Consistent response envelope
   - Meaningful error messages
   - Include correlation IDs

5. **Documentation:**
   - OpenAPI/Swagger
   - Interactive examples
   - Authentication details
   - Error codes

6. **Testing:**
   - Contract tests
   - Integration tests
   - Consumer-driven tests

---

This primer provides a comprehensive understanding of API design and documentation. Well-designed APIs are the foundation of successful distributed systems, enabling easy integration and great developer experience.
