# Appendix T: Common Error Messages & Solutions

## Complete Error Reference Guide

Welcome to **Appendix T** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for common error messages and their solutions.

---

## Section 1: Django Errors

### 1.1 Configuration Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `django.core.exceptions.ImproperlyConfigured` | Missing settings or environment variables | Check `settings.py` and `.env` file |
| `ModuleNotFoundError: No module named 'apps'` | Python path issues | Run from correct directory or check `PYTHONPATH` |
| `django.db.utils.OperationalError: FATAL: role "user" does not exist` | Database user not created | Create database user with correct permissions |
| `django.db.utils.OperationalError: database "dbname" does not exist` | Database not created | Create database or run migrations |
| `django.core.exceptions.AppRegistryNotReady` | Apps not loaded | Ensure `INSTALLED_APPS` is correct |

### 1.2 Migration Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `django.db.migrations.exceptions.InconsistentMigrationHistory` | Migration conflicts | Check migration status, use `--fake` if needed |
| `django.db.migrations.exceptions.MigrationSchemaMissing` | Database not ready | Run `migrate` command |
| `RunPython: django.db.utils.OperationalError: no such table` | Migration order issue | Check migration dependencies |
| `ValueError: The field 'field_name' was declared with a lazy reference to 'app.model'` | Circular import | Use string references in `ForeignKey` |

### 1.3 Model Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `django.db.models.fields.FieldDoesNotExist` | Field doesn't exist | Check model definition |
| `django.core.exceptions.ValidationError` | Validation failed | Check validation rules and input data |
| `django.db.utils.IntegrityError: duplicate key value violates unique constraint` | Duplicate data | Remove duplicate or update unique constraint |
| `django.db.utils.IntegrityError: null value in column "column" violates not-null constraint` | Required field missing | Provide value for required field |
| `django.db.utils.DataError: value too long for type character varying(255)` | Field too short | Increase field length or shorten value |

### 1.4 Admin Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `django.contrib.admin.sites.AlreadyRegistered` | Model already registered | Use `@admin.register` with unique model |
| `django.core.exceptions.ImproperlyConfigured: 'module' does not define a 'Model' class` | Wrong import | Check model import path |

---

## Section 2: DRF Errors

### 2.1 Serializer Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `serializers.ValidationError` | Data validation failed | Check `is_valid()` errors |
| `AttributeError: 'NoneType' object has no attribute 'field'` | Serializer field issue | Check field definitions |
| `TypeError: Object of type Model is not JSON serializable` | Custom object in response | Use serializer or convert to dict |
| `KeyError: 'field_name'` | Field missing in data | Provide required field or set `required=False` |
| `serializers.ValidationError: {'non_field_errors': ['Invalid data']}` | Object-level validation | Check `validate()` method |

### 2.2 View Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `django.core.exceptions.ImproperlyConfigured: 'view' does not define attribute` | View missing required attribute | Add required attribute (e.g., `queryset`) |
| `AssertionError: 'view' should either include a `queryset` attribute` | Missing queryset | Add `queryset` attribute |
| `django.http.response.Http404: No Task matches the given query` | Object not found | Check ID or add `get_object_or_404` |
| `rest_framework.exceptions.ValidationError` | Invalid input | Check serializer errors |
| `rest_framework.exceptions.PermissionDenied` | Permission denied | Check permissions and authentication |

### 2.3 Authentication Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `rest_framework.exceptions.AuthenticationFailed: Invalid token` | Token expired or invalid | Refresh token or re-login |
| `rest_framework.exceptions.NotAuthenticated` | No authentication credentials | Provide token or login |
| `django.contrib.auth.models.User.DoesNotExist` | User not found | Check user existence |
| `django.core.exceptions.ValidationError: ['Password must be at least 8 characters']` | Password too weak | Use stronger password |

---

## Section 3: Next.js Errors

### 3.1 Build Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Error: Cannot find module '@/components/Button'` | Path alias issue | Check `tsconfig.json` paths |
| `TypeError: Cannot read properties of undefined (reading 'map')` | Undefined data | Add null check or default value |
| `Error: Module not found: Can't resolve 'fs'` | Node.js module in client | Use `'use client'` or import dynamically |
| `Error: `useState` is not allowed in Server Components` | Hook in server component | Add `'use client'` directive |
| `Error: `window` is not defined` | Browser API in server | Use `'use client'` or check `typeof window` |

### 3.2 Runtime Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Hydration failed because the initial UI does not match what was rendered on the server` | Server/client mismatch | Check for browser-only code, use `useEffect` |
| `Warning: Each child in a list should have a unique "key" prop` | Missing key in list | Add `key` prop |
| `TypeError: Cannot read properties of null (reading 'xxx')` | Null/undefined data | Add optional chaining or default values |
| `Error: No router instance found` | `useRouter` outside router | Ensure router context is available |

### 3.3 API Route Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Error: Route `api/tasks` is not a valid HTTP method` | Wrong method export | Export `GET`, `POST`, etc. |
| `Error: Cannot find module '../models/Task'` | Wrong import path | Check file path |
| `Error: connect ECONNREFUSED 127.0.0.1:8000` | Backend not running | Start backend server |

---

## Section 4: Database Errors

### 4.1 PostgreSQL Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `FATAL: database "dbname" does not exist` | Database not created | Create database |
| `FATAL: password authentication failed` | Wrong password | Reset password or update credentials |
| `FATAL: role "user" does not exist` | User doesn't exist | Create user |
| `ERROR: permission denied for table table_name` | Insufficient permissions | Grant permissions |
| `ERROR: relation "table_name" does not exist` | Table doesn't exist | Run migrations |
| `ERROR: duplicate key value violates unique constraint` | Duplicate data | Remove duplicate or handle conflict |

### 4.2 Redis Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Error: Redis connection to localhost:6379 failed` | Redis not running | Start Redis service |
| `Error: WRONGPASS invalid password` | Wrong Redis password | Check password in configuration |
| `Error: MISCONF Redis is configured to save RDB snapshots` | Disk space issue | Check disk space and Redis config |
| `Error: OOM command not allowed when used memory > 'maxmemory'` | Memory limit reached | Increase memory or clean data |

---

## Section 5: Docker Errors

### 5.1 Build Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `failed to compute cache key: "/requirements.txt" not found` | Missing file | Check Dockerfile paths |
| `failed to solve: rpc error: code = Unknown desc = failed to compute cache key` | Build context issue | Check `.dockerignore` |
| `ERROR: Cannot connect to the Docker daemon` | Docker not running | Start Docker |
| `permission denied while trying to connect to the Docker daemon socket` | Permission issue | Add user to docker group |

### 5.2 Runtime Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Error response from daemon: Conflict. The container name "/name" is already in use` | Container name conflict | Stop/remove existing container |
| `Error response from daemon: driver failed programming external connectivity` | Port conflict | Change port mapping |
| `ERROR: Couldn't connect to Docker daemon` | Docker not running | Start Docker daemon |
| `Error: No such container` | Container doesn't exist | Check container name |

---

## Section 6: Frontend/Backend Communication Errors

### 6.1 CORS Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Access-Control-Allow-Origin` missing | CORS not configured | Configure CORS in Django |
| `The value of the 'Access-Control-Allow-Origin' header in the response must not be the wildcard '*'` | Credentials with wildcard | Set specific origin |
| `No 'Access-Control-Allow-Origin' header is present on the requested resource` | CORS not configured | Add CORS headers |

### 6.2 API Communication Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `net::ERR_CONNECTION_REFUSED` | Backend not running | Start backend |
| `Failed to fetch` | Network error or wrong URL | Check URL and network |
| `401 Unauthorized` | Invalid/expired token | Refresh token or re-login |
| `403 Forbidden` | Permission denied | Check user permissions |
| `404 Not Found` | Wrong endpoint | Check URL path |
| `429 Too Many Requests` | Rate limit exceeded | Wait and retry |
| `500 Internal Server Error` | Server error | Check logs |

---

## Section 7: Quick Troubleshooting Flowchart

### Backend Issues

1. **Check logs**: `docker-compose logs backend`
2. **Check database**: `docker-compose exec db psql -U user -d db`
3. **Check Redis**: `docker-compose exec redis redis-cli ping`
4. **Check migrations**: `python manage.py showmigrations`
5. **Check environment variables**: `docker-compose exec backend env`

### Frontend Issues

1. **Check dev tools**: Console and Network tabs
2. **Check API URL**: `process.env.NEXT_PUBLIC_API_URL`
3. **Check build**: `npm run build`
4. **Check type errors**: `npx tsc --noEmit`

### Docker Issues

1. **Check running containers**: `docker ps`
2. **Check logs**: `docker-compose logs`
3. **Check disk space**: `docker system df`
4. **Check network**: `docker network ls`

---

*This concludes Appendix T. Use this error reference to quickly identify and resolve common issues.*
