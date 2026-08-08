# Appendix X: Complete File-by-File Project Structure

## Comprehensive Project Structure Reference

Welcome to **Appendix X** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a complete file-by-file breakdown of the final project structure, with descriptions of each file's purpose.

---

## Section 1: Project Root

```
project-root/
├── backend/                    # Django backend
├── frontend/                   # Next.js frontend
├── nginx/                      # Nginx configuration
├── docker-compose.yml          # Development compose
├── docker-compose.prod.yml     # Production compose
├── .env.example                # Environment variables example
├── .gitignore                  # Git ignore file
├── README.md                   # Project documentation
└── LICENSE                     # License file
```

---

## Section 2: Backend Structure

```
backend/
├── config/                     # Django project configuration
│   ├── __init__.py
│   ├── settings/               # Settings modules
│   │   ├── __init__.py
│   │   ├── base.py             # Shared settings
│   │   ├── development.py      # Development overrides
│   │   └── production.py       # Production settings
│   ├── urls.py                 # Root URL configuration
│   ├── wsgi.py                 # WSGI entry point
│   └── asgi.py                 # ASGI entry point
│
├── apps/                       # Django applications
│   ├── api/                    # API app
│   │   ├── __init__.py
│   │   ├── urls.py             # API URL routing
│   │   ├── views.py            # API views
│   │   ├── serializers.py      # API serializers
│   │   ├── permissions.py      # Custom permissions
│   │   ├── pagination.py       # Custom pagination
│   │   ├── middleware.py       # Custom middleware
│   │   ├── cache.py            # Cache utilities
│   │   └── decorators.py       # Custom decorators
│   │
│   ├── users/                  # User management app
│   │   ├── __init__.py
│   │   ├── admin.py            # Admin configuration
│   │   ├── apps.py             # App configuration
│   │   ├── models.py           # User model
│   │   ├── managers.py         # Custom managers
│   │   ├── serializers.py      # User serializers
│   │   ├── views.py            # User views
│   │   └── urls.py             # User URLs
│   │
│   ├── projects/               # Project management app
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── models.py           # Project model
│   │   ├── serializers.py      # Project serializers
│   │   ├── views.py            # Project views
│   │   ├── urls.py             # Project URLs
│   │   └── filters.py          # Project filters
│   │
│   ├── tasks/                  # Task management app
│   │   ├── __init__.py
│   │   ├── admin.py
│   │   ├── apps.py
│   │   ├── models.py           # Task model
│   │   ├── serializers.py      # Task serializers
│   │   ├── views.py            # Task views
│   │   ├── urls.py             # Task URLs
│   │   └── filters.py          # Task filters
│   │
│   └── comments/               # Comment management app
│       ├── __init__.py
│       ├── admin.py
│       ├── apps.py
│       ├── models.py           # Comment model
│       ├── serializers.py      # Comment serializers
│       ├── views.py            # Comment views
│       ├── urls.py             # Comment URLs
│       └── filters.py          # Comment filters
│
├── requirements/               # Python dependencies
│   ├── base.txt                # Core dependencies
│   ├── development.txt         # Development dependencies
│   └── production.txt          # Production dependencies
│
├── tests/                      # Backend tests
│   ├── __init__.py
│   ├── conftest.py             # pytest fixtures
│   ├── factories.py            # Test factories
│   ├── test_models/            # Model tests
│   │   ├── test_user.py
│   │   ├── test_project.py
│   │   ├── test_task.py
│   │   └── test_comment.py
│   ├── test_serializers/       # Serializer tests
│   │   ├── test_user_serializer.py
│   │   ├── test_project_serializer.py
│   │   ├── test_task_serializer.py
│   │   └── test_comment_serializer.py
│   ├── test_views/             # View tests
│   │   ├── test_user_views.py
│   │   ├── test_project_views.py
│   │   ├── test_task_views.py
│   │   └── test_comment_views.py
│   ├── test_permissions/       # Permission tests
│   │   ├── test_project_permissions.py
│   │   └── test_task_permissions.py
│   └── test_integration/       # Integration tests
│       └── test_api_flow.py
│
├── scripts/                    # Utility scripts
│   ├── build.sh               # Docker build script
│   ├── deploy.sh              # Deployment script
│   └── backup.sh              # Backup script
│
├── logs/                       # Log files
│   ├── app.log
│   ├── api.log
│   └── security.log
│
├── fixtures/                   # Test fixtures
│   └── initial_data.json
│
├── staticfiles/               # Collected static files
├── media/                     # User uploaded files
│
├── Dockerfile                 # Production Docker image
├── Dockerfile.dev            # Development Docker image
├── .dockerignore             # Docker ignore file
├── entrypoint.sh             # Container entrypoint
├── gunicorn.conf.py          # Gunicorn configuration
├── manage.py                 # Django management script
├── .env.example              # Environment variables example
├── .env                      # Environment variables (gitignored)
├── .env.production           # Production env vars (gitignored)
├── pytest.ini               # pytest configuration
└── README.md                # Backend documentation
```

---

## Section 3: Frontend Structure

```
frontend/
├── app/                        # Next.js App Router
│   ├── (auth)/                # Authentication routes (group)
│   │   ├── layout.tsx         # Auth layout
│   │   ├── login/
│   │   │   └── page.tsx       # Login page
│   │   └── register/
│   │       └── page.tsx       # Registration page
│   │
│   ├── (dashboard)/           # Dashboard routes (group)
│   │   ├── layout.tsx         # Dashboard layout
│   │   ├── loading.tsx        # Dashboard loading
│   │   ├── error.tsx          # Dashboard error
│   │   │
│   │   ├── dashboard/
│   │   │   └── page.tsx       # Dashboard page
│   │   │
│   │   ├── projects/
│   │   │   ├── page.tsx       # Projects list
│   │   │   ├── loading.tsx    # Projects loading
│   │   │   ├── error.tsx      # Projects error
│   │   │   ├── create/
│   │   │   │   └── page.tsx   # Create project
│   │   │   ├── [id]/
│   │   │   │   ├── page.tsx   # Project detail
│   │   │   │   ├── not-found.tsx
│   │   │   │   ├── edit/
│   │   │   │   │   └── page.tsx # Edit project
│   │   │   │   └── tasks/
│   │   │   │       └── create/
│   │   │   │           └── page.tsx # Create task in project
│   │   │   └── components/
│   │   │       ├── ProjectList.tsx
│   │   │       ├── ProjectForm.tsx
│   │   │       └── ProjectCard.tsx
│   │   │
│   │   ├── tasks/
│   │   │   ├── page.tsx       # Tasks list
│   │   │   ├── loading.tsx    # Tasks loading
│   │   │   ├── error.tsx      # Tasks error
│   │   │   ├── create/
│   │   │   │   └── page.tsx   # Create task
│   │   │   ├── [id]/
│   │   │   │   ├── page.tsx   # Task detail
│   │   │   │   ├── not-found.tsx
│   │   │   │   ├── edit/
│   │   │   │   │   └── page.tsx # Edit task
│   │   │   │   └── components/
│   │   │   │       ├── CommentList.tsx
│   │   │   │       └── TaskStatusUpdate.tsx
│   │   │   └── components/
│   │   │       ├── TaskList.tsx
│   │   │       └── TaskForm.tsx
│   │   │
│   │   ├── users/
│   │   │   └── page.tsx       # Users list
│   │   │
│   │   ├── admin/
│   │   │   └── page.tsx       # Admin dashboard
│   │   │
│   │   └── settings/
│   │       └── page.tsx       # Settings page
│   │
│   ├── api/                   # API routes (proxy)
│   │   ├── health/
│   │   │   └── route.ts       # Health check
│   │   └── proxy/
│   │       └── [...path]/
│   │           └── route.ts   # API proxy
│   │
│   ├── layout.tsx             # Root layout
│   ├── page.tsx               # Landing page
│   ├── globals.css            # Global styles
│   ├── loading.tsx            # Global loading
│   └── error.tsx              # Global error
│
├── components/                # React components
│   ├── ui/                    # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Textarea.tsx
│   │   ├── Card.tsx
│   │   ├── Badge.tsx
│   │   ├── Modal.tsx
│   │   ├── Toast.tsx
│   │   ├── LoadingSpinner.tsx
│   │   ├── Pagination.tsx
│   │   └── PageSizeSelector.tsx
│   │
│   ├── auth/                  # Authentication components
│   │   ├── LoginForm.tsx
│   │   ├── RegisterForm.tsx
│   │   ├── ProtectedRoute.tsx
│   │   └── RoleGuard.tsx
│   │
│   ├── layout/                # Layout components
│   │   ├── Header.tsx
│   │   └── Footer.tsx
│   │
│   ├── data/                  # Data display components
│   │   ├── DataTable.tsx
│   │   ├── DataTableHeader.tsx
│   │   ├── DataTableRow.tsx
│   │   ├── DataTablePagination.tsx
│   │   ├── SearchBar.tsx
│   │   ├── FilterPanel.tsx
│   │   └── DataTableToolbar.tsx
│   │
│   └── providers/             # Context providers
│       ├── QueryProvider.tsx
│       └── AppProvider.tsx
│
├── lib/                       # Libraries and utilities
│   ├── api/                   # API client
│   │   ├── client.ts          # HTTP client
│   │   ├── endpoints.ts       # API endpoints
│   │   ├── hooks.ts           # Data fetching hooks
│   │   └── interceptors/      # Request interceptors
│   │       ├── auth-interceptor.ts
│   │       ├── error-interceptor.ts
│   │       ├── csrf-interceptor.ts
│   │       └── logger-interceptor.ts
│   │
│   ├── auth/                  # Authentication
│   │   ├── AuthContext.tsx    # Auth context
│   │   ├── token.ts           # Token management
│   │   ├── csrf.ts            # CSRF protection
│   │   ├── roles.ts           # Role definitions
│   │   └── server-auth.ts     # Server-side auth
│   │
│   ├── cache/                 # Cache management
│   │   ├── cache.ts
│   │   └── revalidate.ts
│   │
│   ├── context/               # React contexts
│   │   ├── AppContext.tsx
│   │   └── ToastContext.tsx
│   │
│   ├── store/                 # State management
│   │   ├── index.ts
│   │   └── slices/
│   │       └── tasks.ts
│   │
│   └── utils/                 # Utility functions
│       ├── constants.ts       # Constants
│       ├── helpers.ts         # Helper functions
│       └── validators.ts      # Validation functions
│
├── hooks/                     # Custom React hooks
│   ├── useAuth.ts
│   ├── usePermissions.ts
│   ├── useDataSync.ts
│   ├── useOptimisticUpdate.ts
│   └── useUrlState.ts
│
├── types/                     # TypeScript types
│   ├── index.ts               # Main types
│   └── api.ts                 # API types
│
├── public/                    # Static assets
│   ├── favicon.ico
│   ├── robots.txt
│   └── images/
│       └── logo.png
│
├── tests/                     # Frontend tests
│   ├── unit/                  # Unit tests
│   │   ├── components/
│   │   │   ├── Button.test.tsx
│   │   │   ├── Input.test.tsx
│   │   │   └── Card.test.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.test.ts
│   │   └── utils/
│   │       └── helpers.test.ts
│   │
│   ├── integration/           # Integration tests
│   │   ├── forms/
│   │   │   ├── LoginForm.test.tsx
│   │   │   └── TaskForm.test.tsx
│   │   └── pages/
│   │       ├── TasksPage.test.tsx
│   │       └── ProjectPage.test.tsx
│   │
│   ├── e2e/                   # E2E tests
│   │   ├── auth.spec.ts
│   │   ├── tasks.spec.ts
│   │   └── projects.spec.ts
│   │
│   └── setup/                 # Test setup
│       ├── jest.setup.ts
│       ├── test-utils.tsx
│       ├── msw.ts
│       └── msw-setup.js
│
├── scripts/                   # Utility scripts
│   ├── build.sh
│   └── deploy.sh
│
├── Dockerfile                 # Production Docker image
├── Dockerfile.dev            # Development Docker image
├── .dockerignore             # Docker ignore file
├── entrypoint.sh             # Container entrypoint
├── next.config.js            # Next.js configuration
├── tailwind.config.js        # Tailwind configuration
├── postcss.config.js         # PostCSS configuration
├── package.json              # NPM dependencies
├── package-lock.json         # Lockfile
├── tsconfig.json             # TypeScript configuration
├── .eslintrc.json            # ESLint configuration
├── .prettierrc               # Prettier configuration
├── jest.config.js            # Jest configuration
├── jest.setup.js             # Jest setup
├── playwright.config.ts      # Playwright configuration
├── .env.example              # Environment variables example
├── .env.local                # Local env vars (gitignored)
├── .env.production           # Production env vars (gitignored)
├── .eslintignore             # ESLint ignore
├── .prettierignore           # Prettier ignore
├── README.md                 # Frontend documentation
└── middleware.ts             # Next.js middleware
```

---

## Section 4: Nginx Structure

```
nginx/
├── nginx.conf                 # Main Nginx configuration
├── conf.d/
│   ├── default.conf          # Site configuration
│   └── security.conf         # Security configuration
├── snippets/
│   ├── security-headers.conf # Security headers
│   └── ssl-params.conf      # SSL configuration
├── ssl/                      # SSL certificates
│   ├── cert.pem
│   └── key.pem
└── scripts/
    ├── ssl-setup.sh         # SSL setup script
    └── ssl-renewal.sh      # SSL renewal script
```

---

## Section 5: Observability Structure

```
observability/
├── prometheus/
│   ├── prometheus.yml        # Prometheus configuration
│   └── rules.yml             # Alert rules
├── grafana/
│   ├── dashboards/
│   │   ├── api.json          # API dashboard
│   │   └── database.json     # Database dashboard
│   └── datasources/
│       └── prometheus.yml    # Data source configuration
├── loki/
│   └── loki-config.yml      # Loki configuration
└── alerts/
    └── alertmanager.yml     # Alert configuration
```

---

## Section 6: Documentation Structure

```
docs/
├── api/                      # API documentation
│   ├── README.md             # API overview
│   └── openapi.yaml          # OpenAPI specification
├── guides/                   # User guides
│   ├── getting-started.md
│   └── deployment.md
├── runbooks/                 # Operations runbooks
│   ├── production-issues.md
│   └── rollback.md
└── architecture/             # Architecture documentation
    ├── system-design.md
    └── data-flow.md
```

---

## Section 7: File Purpose Quick Reference

| File | Purpose |
|------|---------|
| `manage.py` | Django management entry point |
| `next.config.js` | Next.js configuration |
| `package.json` | Frontend dependencies |
| `requirements.txt` | Backend dependencies |
| `Dockerfile` | Container build instructions |
| `docker-compose.yml` | Multi-container orchestration |
| `nginx.conf` | Reverse proxy configuration |
| `gunicorn.conf.py` | WSGI server configuration |
| `pytest.ini` | Python test configuration |
| `jest.config.js` | JavaScript test configuration |
| `tailwind.config.js` | Tailwind CSS configuration |
| `tsconfig.json` | TypeScript configuration |
| `.env` | Environment variables |
| `.gitignore` | Git ignored files |
| `README.md` | Project documentation |
| `LICENSE` | Project license |

---

*This concludes Appendix X. Use this as a reference when navigating the project structure.*
