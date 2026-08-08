# Django REST Framework & Next.js 16: Trainer Guide

## Comprehensive Instructor's Manual for the Masterclass

---

## Table of Contents

1. [Course Overview](#course-overview)
2. [Teaching Philosophy](#teaching-philosophy)
3. [Course Structure](#course-structure)
4. [Session Plans](#session-plans)
5. [Classroom Setup](#classroom-setup)
6. [Teaching Tips](#teaching-tips)
7. [Common Issues & Solutions](#common-issues--solutions)
8. [Assessment & Evaluation](#assessment--evaluation)
9. [Appendices](#appendices)

---

## Course Overview

### Course Description

The **Django REST Framework & Next.js 16: From Scratch to Production** masterclass is a comprehensive 4-phase program designed to take students from foundational concepts to production-ready applications. Students will build a complete decoupled full-stack application using Django 6.x, Django REST Framework 3.15.x, Next.js 16, React 19, PostgreSQL, Redis, and Docker.

### Target Audience

This course is designed for:
- Python developers moving into API development
- Django developers learning DRF
- Backend developers learning modern React/Next.js
- Full-stack developers building decoupled applications
- Developers migrating from server-rendered Django to API-driven architectures
- Developers preparing for production SaaS development

### Prerequisites

Students should have working knowledge of:
- Python (variables, functions, classes, modules, virtual environments)
- Django (projects, apps, URL routing, views, models, migrations, ORM)
- Web Development (HTML, CSS, HTTP, JSON, basic JavaScript, basic Git)

### Learning Objectives

By the end of this course, students will be able to:

**Backend:**
- Build production-quality APIs with Django REST Framework
- Design RESTful resources and URL structures
- Build serializers and validation rules
- Implement authentication and authorization systems
- Optimize Django ORM queries
- Implement Redis caching
- Test APIs automatically
- Generate OpenAPI documentation

**Frontend:**
- Build applications with Next.js 16 and React 19
- Understand Server Components and Client Components
- Build App Router applications
- Implement dynamic routes
- Consume external DRF APIs
- Implement authenticated frontend flows
- Implement pagination, search, and filtering

**Production:**
- Containerize Django and Next.js with Docker
- Configure Nginx as reverse proxy
- Build CI/CD pipelines
- Implement monitoring and logging

---

## Teaching Philosophy

### The Architecture-First Approach

This course emphasizes **separation of concerns** and **designing the contract first**. Students should understand:

> Django owns the data and business rules.
> DRF exposes the application through a secure API.
> Next.js delivers the modern frontend experience.
> React powers interactive interfaces.
> PostgreSQL stores the data.
> Redis accelerates frequently accessed information.
> Docker makes the environment reproducible.
> Automated tests and CI/CD make the system maintainable.

### Code-First Teaching

The course is **code-heavy and unabbreviated**. Students should:
- See complete, copy-pasteable code
- Never see placeholders like `# implement the rest here`
- Understand every line of code before moving on

### Beginner-Friendly Outside, Expert Inside

- Explain concepts using simple, everyday analogies
- Define technical terms inline
- Write clean, secure, production-grade code
- Students must be able to build the entire application flawlessly by following the text step-by-step

### Logical Progression

Every code step should **directly depend on the previous one**. Never introduce a variable, package, directory structure, or configuration without explaining why it is required *before* writing the code.

---

## Course Structure

### Phase 1: REST API & Next.js Foundations (Parts 0-7)

| Part | Topic | Duration | Key Deliverable |
|------|-------|----------|-----------------|
| 0 | Introduction & Course Overview | 1 hour | Architecture understanding |
| 1 | REST Architecture & HTTP Fundamentals | 2 hours | HTTP/JSON knowledge |
| 2 | Django 6 Backend Foundations | 4 hours | Models & migrations |
| 3 | DRF Serializers | 3 hours | Serializers & validation |
| 4 | Building API Views | 3 hours | CRUD endpoints |
| 5 | Next.js 16 Foundations | 3 hours | App Router setup |
| 6 | Connecting Next.js to DRF | 3 hours | API integration |
| 7 | CRUD Operations Across the Stack | 3 hours | Complete CRUD |

**Phase 1 Total: ~22 hours**

### Phase 2: Advanced DRF & Next.js Data Flow (Parts 8-13)

| Part | Topic | Duration | Key Deliverable |
|------|-------|----------|-----------------|
| 8 | Generic Views, ViewSets & Routers | 3 hours | ViewSet refactoring |
| 9 | Advanced Querying | 3 hours | Filtering & search |
| 10 | Pagination | 2 hours | Paginated APIs |
| 11 | Next.js Routing & Navigation | 2 hours | Dynamic routes |
| 12 | Frontend Data Architecture | 3 hours | React Query |
| 13 | Searchable Data Interfaces | 3 hours | Data tables |

**Phase 2 Total: ~16 hours**

### Phase 3: Authentication, Authorization & Security (Parts 14-20)

| Part | Topic | Duration | Key Deliverable |
|------|-------|----------|-----------------|
| 14 | Authentication Architecture | 2 hours | JWT concepts |
| 15 | JWT with SimpleJWT | 3 hours | Frontend auth |
| 16 | DRF Permissions | 2 hours | Custom permissions |
| 17 | Role-Based Access Control | 2 hours | RBAC system |
| 18 | Next.js Authentication | 2 hours | Auth integration |
| 19 | Next.js Request Interception | 2 hours | API interceptors |
| 20 | API Security | 2 hours | Security hardening |

**Phase 3 Total: ~15 hours**

### Phase 4: Performance, Testing, Documentation & Production (Parts 21-33)

| Part | Topic | Duration | Key Deliverable |
|------|-------|----------|-----------------|
| 21 | Django ORM Performance | 3 hours | Query optimization |
| 22 | Redis Caching | 2 hours | Caching system |
| 23 | API Performance | 2 hours | Performance tuning |
| 24 | Automated Backend Testing | 3 hours | Test suite |
| 25 | Frontend Testing | 3 hours | Frontend tests |
| 26 | API Documentation | 2 hours | OpenAPI |
| 27 | Dockerizing Django | 3 hours | Django container |
| 28 | Dockerizing Next.js | 2 hours | Next.js container |
| 29 | Docker Compose | 2 hours | Service orchestration |
| 30 | Production Configuration | 2 hours | Production settings |
| 31 | Reverse Proxy & Networking | 2 hours | Nginx setup |
| 32 | CI/CD | 2 hours | Pipeline |
| 33 | Observability & Production Operations | 2 hours | Monitoring |

**Phase 4 Total: ~30 hours**

### Total Course Duration: ~83 hours

---

## Session Plans

### Session 1: Introduction & REST Fundamentals (Parts 0-1)

#### Learning Objectives
- Understand the course architecture
- Set up the development environment
- Understand REST principles
- Know HTTP methods and status codes

#### Materials
- Course slides
- Development environment checklist
- HTTP cheat sheet

#### Agenda
1. **Introduction (30 min)**
   - Course overview
   - Architecture diagram
   - Technology stack
   - Prerequisites check
   - Environment setup verification

2. **REST Architecture (45 min)**
   - What is an API?
   - 6 REST constraints
   - Resource-oriented design
   - Activity: Design REST URLs for a blog API

3. **HTTP Fundamentals (45 min)**
   - HTTP methods (GET, POST, PUT, PATCH, DELETE)
   - HTTP status codes (2xx, 3xx, 4xx, 5xx)
   - HTTP headers
   - Activity: Test HTTP methods with curl

4. **Hands-On Exercise (60 min)**
   - Students test the JSONPlaceholder API
   - Students design REST URLs for TaskFlow
   - Q&A and review

#### Common Questions
- "Why use REST instead of GraphQL?" → Discuss trade-offs
- "What's the difference between PUT and PATCH?" → Full vs partial update
- "Why should URLs use nouns instead of verbs?" → Resources, not actions

---

### Session 2: Django Backend Foundations (Part 2)

#### Learning Objectives
- Set up a Django project
- Create Django models
- Run migrations
- Create a superuser

#### Materials
- Django project template
- Model relationship diagram
- Migration cheat sheet

#### Agenda
1. **Django Setup (30 min)**
   - Virtual environment
   - Project creation
   - Settings configuration
   - Environment variables

2. **Data Modeling (60 min)**
   - Custom User model
   - Project model
   - Task model
   - Comment model
   - Relationships

3. **Migrations (30 min)**
   - makemigrations
   - migrate
   - inspectdb
   - showmigrations

4. **Hands-On Exercise (60 min)**
   - Students create all models
   - Students run migrations
   - Students create a superuser
   - Students explore the admin interface

#### Common Issues
- "Migration conflicts" → Check migration history
- "Database connection failed" → Check DATABASE_URL
- "Custom User model not found" → Check AUTH_USER_MODEL setting

---

### Session 3: DRF Serializers (Part 3)

#### Learning Objectives
- Understand serializers
- Create ModelSerializers
- Implement validation
- Handle nested relationships

#### Materials
- Serializer types comparison
- Validation examples
- Nested serializer patterns

#### Agenda
1. **What are Serializers? (30 min)**
   - Serialization vs deserialization
   - Serializer vs ModelSerializer
   - HyperlinkedModelSerializer

2. **Creating Serializers (45 min)**
   - User serializers
   - Project serializers
   - Task serializers
   - Comment serializers

3. **Validation (30 min)**
   - Field-level validation
   - Object-level validation
   - Custom validators

4. **Nested Serializers (30 min)**
   - Read-only nested
   - Writable nested
   - Performance considerations

5. **Hands-On Exercise (45 min)**
   - Students create all serializers
   - Students add validation
   - Students test serializers in shell

---

### Session 4: Building API Views (Part 4)

#### Learning Objectives
- Create API views with @api_view
- Implement CRUD endpoints
- Handle HTTP methods
- Return proper status codes

#### Materials
- View type comparison
- CRUD endpoint map
- Status code reference

#### Agenda
1. **View Types (30 min)**
   - @api_view
   - APIView
   - Generic views
   - ViewSets

2. **CRUD Views (60 min)**
   - List and create views
   - Detail views (retrieve, update, delete)
   - URL configuration

3. **Status Codes (30 min)**
   - 200 OK, 201 Created, 204 No Content
   - 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found
   - 500 Internal Server Error

4. **Hands-On Exercise (60 min)**
   - Students create all views
   - Students configure URLs
   - Students test endpoints with curl

---

### Session 5: Next.js 16 Foundations (Part 5)

#### Learning Objectives
- Set up Next.js with App Router
- Understand Server vs Client Components
- Create pages and layouts
- Configure Tailwind CSS

#### Materials
- Next.js project template
- Server vs Client Component comparison
- Tailwind cheat sheet

#### Agenda
1. **Next.js Setup (30 min)**
   - Project creation
   - Directory structure
   - Configuration

2. **App Router (45 min)**
   - Page routing
   - Dynamic routes
   - Route groups
   - Layouts

3. **Server vs Client Components (45 min)**
   - Server Component features
   - Client Component features
   - When to use which

4. **Tailwind CSS (30 min)**
   - Utility-first CSS
   - Configuration
   - Custom theming

5. **Hands-On Exercise (60 min)**
   - Students create Next.js project
   - Students build layouts
   - Students create pages

---

### Session 6: Connecting Next.js to DRF (Part 6)

#### Learning Objectives
- Create an API client
- Fetch data in Server Components
- Handle errors and loading states
- Submit data from forms

#### Materials
- API client template
- Data fetching patterns
- Form handling examples

#### Agenda
1. **API Client (30 min)**
   - fetch API
   - Error handling
   - TypeScript types

2. **Server Component Fetching (30 min)**
   - async/await in Server Components
   - Data caching
   - Revalidation

3. **Client Component Fetching (30 min)**
   - useEffect + useState
   - Loading states
   - Error states

4. **Form Handling (30 min)**
   - Controlled forms
   - Form submission
   - Validation errors

5. **Hands-On Exercise (60 min)**
   - Students build API client
   - Students create data fetching pages
   - Students build forms

---

### Session 7: CRUD Operations Across the Stack (Part 7)

#### Learning Objectives
- Implement complete CRUD operations
- Handle form validation
- Display toast notifications
- Implement delete with confirmation

#### Materials
- CRUD endpoint map
- Toast notification code
- Confirmation modal code

#### Agenda
1. **Complete CRUD (45 min)**
   - Create, Read, Update, Delete
   - Endpoint patterns
   - Data flow

2. **Toast Notifications (30 min)**
   - Context API for toasts
   - Toast types (success, error, warning, info)
   - Auto-dismiss

3. **Confirmation Modals (30 min)**
   - Modal component
   - Confirmation dialog
   - Delete handling

4. **Hands-On Exercise (75 min)**
   - Students implement complete CRUD
   - Students add toast notifications
   - Students implement delete confirmation

---

### Session 8: Generic Views, ViewSets & Routers (Part 8)

#### Learning Objectives
- Replace function-based views with ViewSets
- Use DefaultRouter for consistent URLs
- Add custom actions with @action

#### Materials
- ViewSet action map
- Router URL generation
- Custom action examples

#### Agenda
1. **ViewSets Overview (30 min)**
   - ModelViewSet
   - ReadOnlyModelViewSet
   - GenericViewSet

2. **Converting to ViewSets (45 min)**
   - Task ViewSet
   - Project ViewSet
   - Comment ViewSet

3. **Router Configuration (30 min)**
   - DefaultRouter
   - URL generation
   - Custom actions

4. **Custom Actions (30 min)**
   - @action decorator
   - Detail vs list actions
   - Custom endpoints

5. **Hands-On Exercise (45 min)**
   - Students convert to ViewSets
   - Students configure routers
   - Students add custom actions

---

### Session 9: Advanced Querying (Part 9)

#### Learning Objectives
- Implement filtering with django-filter
- Add search functionality
- Implement ordering
- Create custom filter methods

#### Materials
- django-filter configuration
- FilterSet examples
- Query parameter reference

#### Agenda
1. **django-filter Setup (30 min)**
   - Installation
   - Configuration
   - FilterSet

2. **Filtering (45 min)**
   - Basic filters (exact, contains, etc.)
   - Choice filters
   - Date filters

3. **Search (30 min)**
   - SearchFilter
   - Search fields
   - Custom search

4. **Ordering (30 min)**
   - OrderingFilter
   - Ordering fields
   - Default ordering

5. **Hands-On Exercise (45 min)**
   - Students create FilterSets
   - Students implement search
   - Students configure ordering

---

### Session 10: Pagination (Part 10)

#### Learning Objectives
- Implement page number pagination
- Create custom pagination classes
- Add pagination controls to frontend
- Implement page size selector

#### Materials
- Pagination types comparison
- Custom pagination class
- Frontend pagination component

#### Agenda
1. **Pagination Strategies (30 min)**
   - PageNumberPagination
   - LimitOffsetPagination
   - CursorPagination

2. **Custom Pagination (30 min)**
   - Custom pagination class
   - Response format
   - Page size parameter

3. **Frontend Pagination (45 min)**
   - Pagination component
   - Page size selector
   - Navigation controls

4. **Hands-On Exercise (45 min)**
   - Students implement custom pagination
   - Students build pagination components

---

### Session 11: Next.js Routing & Navigation (Part 11)

#### Learning Objectives
- Master dynamic routes
- Use route groups
- Implement nested layouts
- Add loading and error states

#### Materials
- Route types reference
- Layout patterns
- Loading/error examples

#### Agenda
1. **Dynamic Routes (30 min)**
   - [param] syntax
   - Catch-all routes
   - Optional routes

2. **Route Groups (30 min)**
   - (group) syntax
   - Organization
   - URL impact

3. **Layouts (30 min)**
   - Root layout
   - Nested layouts
   - Route group layouts

4. **Loading & Error States (30 min)**
   - loading.tsx
   - error.tsx
   - not-found.tsx

5. **Hands-On Exercise (60 min)**
   - Students build dynamic routes
   - Students implement layouts
   - Students add loading/error states

---

### Session 12: Frontend Data Architecture (Part 12)

#### Learning Objectives
- Set up React Query
- Create data fetching hooks
- Implement optimistic updates
- Handle cache invalidation

#### Materials
- React Query setup
- Query/mutation patterns
- Optimistic update examples

#### Agenda
1. **React Query Setup (30 min)**
   - Installation
   - QueryClient
   - QueryProvider

2. **Data Fetching Hooks (45 min)**
   - useQuery
   - useMutation
   - Query keys

3. **Optimistic Updates (45 min)**
   - onMutate
   - setQueryData
   - Rollback on error

4. **Cache Invalidation (30 min)**
   - invalidateQueries
   - Cache strategies
   - Revalidation

5. **Hands-On Exercise (60 min)**
   - Students set up React Query
   - Students create data hooks
   - Students implement optimistic updates

---

### Session 13: Searchable Data Interfaces (Part 13)

#### Learning Objectives
- Implement URL-based state management
- Build data tables with sorting
- Add search with debouncing
- Combine filters and pagination

#### Materials
- useUrlState hook
- Data table components
- Debouncing implementation

#### Agenda
1. **URL State Management (30 min)**
   - useSearchParams
   - useRouter
   - URL synchronization

2. **Data Tables (45 min)**
   - Table components
   - Sorting
   - Column configuration

3. **Search with Debouncing (30 min)**
   - Debouncing implementation
   - Performance optimization
   - Search UX

4. **Combined Features (45 min)**
   - Search + Filters + Pagination
   - URL sync
   - State management

5. **Hands-On Exercise (60 min)**
   - Students implement URL state
   - Students build data tables
   - Students add search and filters

---

### Session 14: Authentication Architecture (Part 14)

#### Learning Objectives
- Understand JWT architecture
- Install and configure SimpleJWT
- Create authentication endpoints

#### Materials
- JWT structure diagram
- SimpleJWT configuration
- Authentication flow

#### Agenda
1. **Authentication vs Authorization (30 min)**
   - Identity vs permissions
   - Authentication factors
   - Common methods

2. **JWT Architecture (45 min)**
   - JWT structure (Header, Payload, Signature)
   - Access vs Refresh tokens
   - Token lifecycle

3. **SimpleJWT Setup (30 min)**
   - Installation
   - Configuration
   - Endpoints

4. **Hands-On Exercise (45 min)**
   - Students install SimpleJWT
   - Students test authentication endpoints

---

### Session 15: JWT with SimpleJWT (Part 15)

#### Learning Objectives
- Implement frontend authentication
- Build token management
- Add route protection

#### Materials
- Token management code
- Auth context
- Route protection

#### Agenda
1. **Token Management (30 min)**
   - Storage (memory, cookies, localStorage)
   - Token helpers
   - Security considerations

2. **Auth Context (45 min)**
   - AuthProvider
   - useAuth hook
   - Login/logout flow

3. **Route Protection (45 min)**
   - Middleware
   - ProtectedRoute component
   - Redirect handling

4. **Hands-On Exercise (60 min)**
   - Students implement token management
   - Students build auth context
   - Students add route protection

---

### Session 16: DRF Permissions (Part 16)

#### Learning Objectives
- Implement permission classes
- Create custom permissions
- Use object-level permissions

#### Materials
- Permission class examples
- Custom permission patterns
- Permission flow diagram

#### Agenda
1. **Permission System Overview (30 min)**
   - has_permission
   - has_object_permission
   - Permission classes

2. **Custom Permissions (45 min)**
   - IsProjectOwner
   - IsTaskAssignee
   - IsAdminOrManager

3. **Object-Level Permissions (30 min)**
   - Ownership checks
   - Access control
   - Permission in views

4. **Hands-On Exercise (45 min)**
   - Students create custom permissions
   - Students apply to views

---

### Session 17: Role-Based Access Control (Part 17)

#### Learning Objectives
- Define user roles
- Implement RBAC on backend
- Build role-based UI components

#### Materials
- Role definitions
- RBAC patterns
- Role guard component

#### Agenda
1. **Role Definitions (30 min)**
   - Admin, Manager, Member, Viewer
   - Role hierarchy
   - Role methods

2. **Backend RBAC (45 min)**
   - Permission checking
   - Role-based filtering
   - ViewSet permissions

3. **Frontend RBAC (45 min)**
   - RoleGuard component
   - Role-based navigation
   - Conditional rendering

4. **Hands-On Exercise (60 min)**
   - Students implement roles
   - Students build RBAC system
   - Students add role-based UI

---

### Session 18: Next.js Authentication (Part 18)

#### Learning Objectives
- Implement middleware for route protection
- Add server-side authentication
- Build complete auth flows

#### Materials
- Middleware configuration
- Server auth utilities
- Auth flows

#### Agenda
1. **Next.js Middleware (30 min)**
   - middleware.ts
   - Route protection
   - Redirect logic

2. **Server-Side Auth (45 min)**
   - getServerUser
   - requireAuth
   - Server Component auth

3. **Complete Auth Flows (45 min)**
   - Login flow
   - Registration flow
   - Logout flow

4. **Hands-On Exercise (60 min)**
   - Students implement middleware
   - Students add server auth
   - Students build complete auth

---

### Session 19: Request Interception (Part 19)

#### Learning Objectives
- Implement request interceptors
- Handle token refresh automatically
- Add CSRF protection

#### Materials
- Interceptor patterns
- Token refresh flow
- CSRF implementation

#### Agenda
1. **Request Interceptors (30 min)**
   - Auth interceptor
   - Error interceptor
   - Logger interceptor

2. **Token Refresh (45 min)**
   - Automatic refresh
   - Retry logic
   - Refresh failure handling

3. **CSRF Protection (30 min)**
   - CSRF tokens
   - Header injection
   - Cookie handling

4. **Hands-On Exercise (45 min)**
   - Students build interceptors
   - Students implement token refresh

---

### Session 20: API Security (Part 20)

#### Learning Objectives
- Implement rate limiting
- Configure CORS
- Add security headers
- Protect against common vulnerabilities

#### Materials
- Rate limiting configuration
- CORS settings
- Security headers

#### Agenda
1. **Rate Limiting (30 min)**
   - django-ratelimit
   - Configuration
   - Per-endpoint limits

2. **CORS Configuration (30 min)**
   - Allowed origins
   - Allowed methods
   - Allowed headers

3. **Security Headers (30 min)**
   - HSTS
   - X-Frame-Options
   - X-Content-Type-Options
   - X-XSS-Protection
   - Content-Security-Policy

4. **Hands-On Exercise (45 min)**
   - Students implement rate limiting
   - Students configure CORS
   - Students add security headers

---

### Session 21: Django ORM Performance (Part 21)

#### Learning Objectives
- Identify the N+1 query problem
- Use select_related and prefetch_related
- Add database indexes
- Optimize serialization

#### Materials
- Query optimization patterns
- Database index examples
- Profiling tools

#### Agenda
1. **Query Optimization (45 min)**
   - N+1 query problem
   - select_related
   - prefetch_related

2. **Database Indexes (30 min)**
   - Single column indexes
   - Composite indexes
   - Partial indexes

3. **Profiling Tools (30 min)**
   - Django Debug Toolbar
   - Query counting
   - Performance monitoring

4. **Hands-On Exercise (45 min)**
   - Students optimize queries
   - Students add indexes
   - Students profile queries

---

### Session 22: Redis Caching (Part 22)

#### Learning Objectives
- Configure Redis with Django
- Implement view caching
- Add low-level caching
- Build cache invalidation strategies

#### Materials
- Redis configuration
- Caching patterns
- Invalidation strategies

#### Agenda
1. **Redis Setup (30 min)**
   - Installation
   - Configuration
   - Django integration

2. **View Caching (30 min)**
   - cache_page decorator
   - Cached API responses
   - TTL configuration

3. **Low-Level Caching (30 min)**
   - cache.get/set
   - Key generation
   - Cache expiration

4. **Cache Invalidation (30 min)**
   - On-demand invalidation
   - Event-based invalidation
   - Cache clearing

5. **Hands-On Exercise (60 min)**
   - Students configure Redis
   - Students implement caching
   - Students add invalidation

---

### Session 23: API Performance (Part 23)

#### Learning Objectives
- Optimize serializers
- Implement response compression
- Use connection pooling
- Monitor performance

#### Materials
- Serializer optimization patterns
- Compression configuration
- Performance monitoring

#### Agenda
1. **Serializer Optimization (30 min)**
   - List vs detail serializers
   - Field selection
   - Nested serializer optimization

2. **Response Compression (30 min)**
   - GZipMiddleware
   - Compression benefits
   - Configuration

3. **Connection Pooling (30 min)**
   - CONN_MAX_AGE
   - Connection reuse
   - Health checks

4. **Hands-On Exercise (45 min)**
   - Students optimize serializers
   - Students enable compression
   - Students monitor performance

---

### Session 24: Automated Backend Testing (Part 24)

#### Learning Objectives
- Set up pytest and pytest-django
- Write model tests
- Create serializer tests
- Build API view tests

#### Materials
- pytest configuration
- Fixture patterns
- Test examples

#### Agenda
1. **Testing Setup (30 min)**
   - pytest installation
   - Configuration
   - Fixtures

2. **Model Tests (30 min)**
   - Testing models
   - Testing methods
   - Testing constraints

3. **Serializer Tests (30 min)**
   - Validation testing
   - Create/update testing
   - Error testing

4. **API View Tests (45 min)**
   - CRUD tests
   - Authentication tests
   - Permission tests

5. **Hands-On Exercise (60 min)**
   - Students write model tests
   - Students write serializer tests
   - Students write API tests

---

### Session 25: Frontend Testing (Part 25)

#### Learning Objectives
- Set up React Testing Library
- Write component tests
- Implement integration tests
- Build E2E tests with Playwright

#### Materials
- Testing library setup
- Component test examples
- E2E test examples

#### Agenda
1. **Testing Setup (30 min)**
   - Jest configuration
   - React Testing Library
   - MSW for API mocking

2. **Component Tests (45 min)**
   - Rendering tests
   - Interaction tests
   - Form tests

3. **Integration Tests (30 min)**
   - Page tests
   - API integration tests
   - Auth flow tests

4. **E2E Tests (45 min)**
   - Playwright setup
   - User flow tests
   - Cross-browser testing

5. **Hands-On Exercise (60 min)**
   - Students write component tests
   - Students write integration tests
   - Students write E2E tests

---

### Session 26: API Documentation (Part 26)

#### Learning Objectives
- Generate OpenAPI schema
- Add schema annotations
- Configure Swagger UI and ReDoc

#### Materials
- drf-spectacular configuration
- Schema annotations
- Documentation URLs

#### Agenda
1. **OpenAPI Setup (30 min)**
   - drf-spectacular installation
   - Configuration
   - Schema generation

2. **Schema Annotations (45 min)**
   - @extend_schema
   - Parameters
   - Responses
   - Examples

3. **Documentation Views (30 min)**
   - Swagger UI
   - ReDoc
   - Schema export

4. **Hands-On Exercise (45 min)**
   - Students generate schema
   - Students add annotations
   - Students view documentation

---

### Session 27: Dockerizing Django (Part 27)

#### Learning Objectives
- Create multi-stage Dockerfile
- Configure Gunicorn
- Add health checks

#### Materials
- Dockerfile template
- Gunicorn configuration
- Health check examples

#### Agenda
1. **Dockerfile (45 min)**
   - Multi-stage builds
   - Layer optimization
   - Non-root user

2. **Gunicorn Configuration (30 min)**
   - Workers
   - Timeouts
   - Logging

3. **Health Checks (30 min)**
   - Health check endpoint
   - Docker health checks
   - Container monitoring

4. **Hands-On Exercise (45 min)**
   - Students create Dockerfile
   - Students configure Gunicorn
   - Students add health checks

---

### Session 28: Dockerizing Next.js (Part 28)

#### Learning Objectives
- Create Next.js Dockerfile
- Enable standalone output
- Optimize production builds

#### Materials
- Standalone output configuration
- Dockerfile template
- Build optimization

#### Agenda
1. **Next.js Configuration (30 min)**
   - Standalone output
   - Build optimization
   - Environment variables

2. **Dockerfile (45 min)**
   - Multi-stage builds
   - Standalone copy
   - Non-root user

3. **Image Optimization (30 min)**
   - Image size reduction
   - Build time optimization
   - Production vs development

4. **Hands-On Exercise (45 min)**
   - Students create Dockerfile
   - Students configure standalone
   - Students build and test

---

### Session 29: Docker Compose (Part 29)

#### Learning Objectives
- Configure complete Docker Compose
- Set up Nginx reverse proxy
- Orchestrate all services

#### Materials
- Docker Compose configuration
- Nginx configuration
- Service orchestration

#### Agenda
1. **Docker Compose (45 min)**
   - Service definitions
   - Networks
   - Volumes

2. **Nginx Configuration (45 min)**
   - Reverse proxy
   - Routing
   - Static files

3. **Service Orchestration (30 min)**
   - Dependencies
   - Environment variables
   - Health checks

4. **Hands-On Exercise (60 min)**
   - Students create compose file
   - Students configure Nginx
   - Students test orchestration

---

### Session 30: Production Configuration (Part 30)

#### Learning Objectives
- Create production settings
- Configure security
- Set up logging

#### Materials
- Production settings template
- Security configuration
- Logging setup

#### Agenda
1. **Production Settings (45 min)**
   - Environment separation
   - Security settings
   - Performance settings

2. **Security Configuration (30 min)**
   - HTTPS
   - Secure cookies
   - CORS

3. **Logging (30 min)**
   - Structured logging
   - Log rotation
   - Log aggregation

4. **Hands-On Exercise (45 min)**
   - Students create production settings
   - Students configure security
   - Students set up logging

---

### Session 31: Reverse Proxy & Networking (Part 31)

#### Learning Objectives
- Configure Nginx as reverse proxy
- Set up SSL/TLS
- Implement rate limiting

#### Materials
- Nginx configuration
- SSL certificate setup
- Rate limiting configuration

#### Agenda
1. **Nginx Configuration (45 min)**
   - Reverse proxy
   - Routing
   - Static files

2. **SSL/TLS (30 min)**
   - Let's Encrypt
   - SSL configuration
   - HSTS

3. **Rate Limiting (30 min)**
   - Rate limiting zones
   - Per-endpoint limits
   - Responses

4. **Hands-On Exercise (45 min)**
   - Students configure Nginx
   - Students set up SSL
   - Students implement rate limiting

---

### Session 32: CI/CD (Part 32)

#### Learning Objectives
- Set up GitHub Actions
- Automate testing
- Build and push Docker images
- Deploy to production

#### Materials
- GitHub Actions workflow
- Deployment scripts
- Environment configuration

#### Agenda
1. **GitHub Actions (45 min)**
   - Workflow configuration
   - Jobs and steps
   - Secrets

2. **Testing Pipeline (30 min)**
   - Backend tests
   - Frontend tests
   - Integration tests

3. **Build Pipeline (30 min)**
   - Docker image building
   - Registry push
   - Versioning

4. **Deploy Pipeline (30 min)**
   - Deployment automation
   - Rollback strategy
   - Health checks

5. **Hands-On Exercise (45 min)**
   - Students create workflow
   - Students implement CI/CD
   - Students test pipeline

---

### Session 33: Observability & Production Operations (Part 33)

#### Learning Objectives
- Implement structured logging
- Set up monitoring
- Add error tracking
- Configure alerts

#### Materials
- Logging configuration
- Monitoring setup
- Alert configuration

#### Agenda
1. **Structured Logging (30 min)**
   - structlog
   - Log formats
   - Log aggregation

2. **Monitoring (45 min)**
   - Prometheus
   - Metrics collection
   - Dashboards

3. **Error Tracking (30 min)**
   - Sentry setup
   - Error monitoring
   - Performance monitoring

4. **Alerting (30 min)**
   - Alert rules
   - Alert routing
   - Notification channels

5. **Hands-On Exercise (45 min)**
   - Students implement logging
   - Students set up monitoring
   - Students configure alerts

---

## Classroom Setup

### Hardware Requirements

| Item | Specification | Quantity |
|------|---------------|----------|
| **Instructor Machine** | 16GB RAM, 4+ cores, 50GB free | 1 |
| **Student Machine** | 8GB RAM, 2+ cores, 20GB free | Per student |
| **Projector/Display** | HD or higher | 1 |
| **Network** | Stable internet connection | 1 |

### Software Requirements (Pre-installed)

| Software | Version | Purpose |
|----------|---------|---------|
| Python | 3.12+ | Backend development |
| Node.js | 20+ | Frontend development |
| PostgreSQL | 15+ | Database |
| Redis | 7+ | Cache |
| Docker | 24+ | Containerization |
| Docker Compose | 2.20+ | Container orchestration |
| Git | Latest | Version control |
| VS Code | Latest | IDE |
| Postman | Latest | API testing |

### Classroom Configuration

```bash
# Verify installations
python --version
node --version
postgres --version
redis-server --version
docker --version
docker-compose --version
git --version
```

### Sample Project Setup

```bash
# Clone the project
git clone https://github.com/yourusername/taskflow.git
cd taskflow

# Setup backend
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements/development.txt

# Setup frontend
cd ../frontend
npm install
```

---

## Teaching Tips

### Before the Course

1. **Verify all student machines** - Test the environment setup beforehand
2. **Prepare sample solutions** - Have working code ready for each part
3. **Create a backup plan** - Prepare offline materials in case of connectivity issues
4. **Set up a shared repository** - Use a private GitHub repo for code sharing

### During the Course

1. **Start with the architecture** - Ensure students understand the big picture
2. **Code along with students** - Type code live, don't just show slides
3. **Use pair programming** - Have students work in pairs for complex labs
4. **Check understanding** - Use the quiz questions as formative assessment
5. **Encourage questions** - Create a safe space for asking questions
6. **Record sessions** - Record lectures for students to review
7. **Provide feedback** - Review code submissions promptly

### Common Traps to Avoid

1. **Don't rush** - Give students time to type and understand code
2. **Don't assume knowledge** - Explain concepts even if they seem basic
3. **Don't skip testing** - Always verify that code works before moving on
4. **Don't ignore errors** - Use errors as teaching moments
5. **Don't provide all answers** - Guide students to find solutions themselves

### Time Management

| Part | Lecture | Lab | Total |
|------|---------|-----|-------|
| Part 0 | 45 min | 15 min | 1 hour |
| Parts 1-7 | 3 hours each | 3 hours each | 6 hours each |
| Parts 8-13 | 2 hours each | 2 hours each | 4 hours each |
| Parts 14-20 | 1.5 hours each | 1.5 hours each | 3 hours each |
| Parts 21-33 | 1 hour each | 1 hour each | 2 hours each |

---

## Common Issues & Solutions

### Environment Setup Issues

| Issue | Solution |
|-------|----------|
| Python not found | Install Python 3.12+ |
| Node.js not found | Install Node.js 20+ |
| PostgreSQL not running | Start PostgreSQL service |
| Redis not running | Start Redis service |
| Docker not installed | Install Docker Desktop |
| Port already in use | Change port or kill process |

### Database Issues

| Issue | Solution |
|-------|----------|
| Database doesn't exist | Create database |
| User doesn't exist | Create user |
| Permission denied | Grant permissions |
| Connection refused | Check connection string |
| Migration conflicts | Reset migrations |

### Code Issues

| Issue | Solution |
|-------|----------|
| Syntax errors | Check code carefully |
| Import errors | Check import paths |
| Logic errors | Use debugger/print statements |
| Validation errors | Check serializer validation |
| 404 errors | Check URL patterns |

### Docker Issues

| Issue | Solution |
|-------|----------|
| Build fails | Check Dockerfile syntax |
| Container won't start | Check logs |
| Port conflict | Change port mapping |
| Volume permission | Check volume permissions |
| Image size too large | Optimize Dockerfile |

---

## Assessment & Evaluation

### Formative Assessment (Throughout Course)

1. **Quiz Questions** - Use at the start of each session
2. **Code Review** - Review student code during labs
3. **Pair Programming** - Observe pair programming sessions
4. **Exit Tickets** - Ask students to write key takeaways
5. **Mini Projects** - Small deliverables at the end of each phase

### Summative Assessment (End of Course)

#### Project: Complete TaskFlow Application

**Criteria:**
- ✅ Backend API with all CRUD operations
- ✅ Authentication and authorization
- ✅ Frontend with all CRUD operations
- ✅ Search, filter, and pagination
- ✅ Testing (backend and frontend)
- ✅ Documentation (OpenAPI)
- ✅ Docker deployment
- ✅ CI/CD pipeline

#### Grading Rubric

| Criteria | Excellent (90-100%) | Good (70-89%) | Satisfactory (50-69%) | Needs Work (<50%) |
|----------|---------------------|---------------|----------------------|-------------------|
| **Backend API** | All endpoints working, proper status codes | Most endpoints working | Some endpoints working | Few endpoints working |
| **Authentication** | JWT fully implemented | Basic JWT working | Partial implementation | Not implemented |
| **Frontend** | All features working, responsive | Most features working | Some features working | Few features working |
| **Testing** | Comprehensive tests passing | Most tests passing | Some tests passing | Few tests passing |
| **Documentation** | Complete OpenAPI doc | Good documentation | Partial documentation | No documentation |
| **Deployment** | Docker + CI/CD working | Docker working | Partial deployment | Not deployed |

### Certification

Students who complete the course and pass the project assessment receive:
- Certificate of Completion
- Badge (optional)
- Letter of Recommendation (optional)

---

## Appendices

### Appendix A: Sample Schedule (5-Day Bootcamp)

| Day | Morning (4 hours) | Afternoon (4 hours) |
|-----|-------------------|---------------------|
| **Day 1** | Parts 0-1: Introduction & REST | Parts 2-3: Django & Serializers |
| **Day 2** | Parts 4-5: API Views & Next.js | Parts 6-7: Connect & CRUD |
| **Day 3** | Parts 8-9: ViewSets & Querying | Parts 10-11: Pagination & Routing |
| **Day 4** | Parts 12-13: Data Architecture & Search | Parts 14-15: Auth & JWT |
| **Day 5** | Parts 16-17: Permissions & RBAC | Parts 18-20: Security |

### Appendix B: Sample Schedule (10-Week Course)

| Week | Topics |
|------|--------|
| **Week 1** | Parts 0-1: Introduction & REST |
| **Week 2** | Parts 2-3: Django & Serializers |
| **Week 3** | Parts 4-5: API Views & Next.js |
| **Week 4** | Parts 6-7: Connect & CRUD |
| **Week 5** | Parts 8-9: ViewSets & Querying |
| **Week 6** | Parts 10-11: Pagination & Routing |
| **Week 7** | Parts 12-13: Data Architecture & Search |
| **Week 8** | Parts 14-15: Auth & JWT |
| **Week 9** | Parts 16-17: Permissions & RBAC |
| **Week 10** | Parts 18-20: Security |

### Appendix C: Sample Schedule (Weekly, 12 Weeks)

| Week | Topics |
|------|--------|
| **Week 1** | Part 0: Introduction, Part 1: REST |
| **Week 2** | Part 2: Django Backend |
| **Week 3** | Part 3: Serializers |
| **Week 4** | Part 4: API Views |
| **Week 5** | Part 5: Next.js Foundations |
| **Week 6** | Part 6: Connect Next.js to DRF |
| **Week 7** | Part 7: CRUD Operations |
| **Week 8** | Parts 8-9: ViewSets & Querying |
| **Week 9** | Parts 10-11: Pagination & Routing |
| **Week 10** | Parts 12-13: Data Architecture & Search |
| **Week 11** | Parts 14-15: Auth & JWT |
| **Week 12** | Parts 16-20: Permissions, RBAC & Security |

---

## Final Notes

### Key Success Factors

1. **Clear Communication** - Explain concepts clearly and patiently
2. **Hands-On Practice** - Maximize lab time for students
3. **Real-World Examples** - Connect concepts to real-world scenarios
4. **Code Quality** - Emphasize clean, production-grade code
5. **Problem Solving** - Help students develop problem-solving skills

### Instructor Preparation

1. **Review each part thoroughly** before teaching
2. **Prepare sample solutions** for all labs
3. **Create a reference project** with all completed code
4. **Set up your own environment** to demonstrate
5. **Prepare for common questions** and issues

### Continuous Improvement

1. **Collect feedback** after each session
2. **Update materials** based on feedback
3. **Stay current** with latest technology updates
4. **Share resources** for continued learning
5. **Build a community** among students

---

*This concludes the Trainer Guide for the Django REST Framework & Next.js 16: From Scratch to Production masterclass.*
