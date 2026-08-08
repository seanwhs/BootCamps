# Appendix V: Environment Variables Reference

## Complete Environment Variables Reference

Welcome to **Appendix V** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for all environment variables used throughout the application.

---

## Section 1: Django Backend Variables

### 1.1 Core Settings

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `SECRET_KEY` | Django secret key for cryptographic signing | Yes | None | `django-insecure-xyz123` |
| `DEBUG` | Enable debug mode | Yes (Dev) | False | `True` / `False` |
| `DJANGO_ENV` | Environment name | No | `development` | `production` |
| `ALLOWED_HOSTS` | Comma-separated list of allowed hosts | Yes (Prod) | `localhost` | `api.example.com,app.example.com` |
| `CSRF_TRUSTED_ORIGINS` | Comma-separated list of trusted origins | No | None | `https://api.example.com` |
| `INTERNAL_IPS` | Comma-separated list of internal IPs | No | None | `127.0.0.1` |

### 1.2 Database Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `DATABASE_URL` | Database connection URL | Yes | `sqlite:///db.sqlite3` | `postgresql://user:pass@localhost:5432/db` |
| `DB_NAME` | Database name | If using individual vars | `taskflow_db` | `taskflow_db` |
| `DB_USER` | Database username | If using individual vars | `taskflow_user` | `taskflow_user` |
| `DB_PASSWORD` | Database password | If using individual vars | None | `secure_password` |
| `DB_HOST` | Database host | If using individual vars | `localhost` | `db` |
| `DB_PORT` | Database port | If using individual vars | `5432` | `5432` |
| `DB_CONN_MAX_AGE` | Connection max age in seconds | No | `600` | `600` |

### 1.3 Redis Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `REDIS_URL` | Redis connection URL | Yes (if using Redis) | `redis://localhost:6379/1` | `redis://:password@redis:6379/1` |
| `REDIS_HOST` | Redis host | If using individual vars | `localhost` | `redis` |
| `REDIS_PORT` | Redis port | If using individual vars | `6379` | `6379` |
| `REDIS_DB` | Redis database index | If using individual vars | `1` | `1` |
| `REDIS_PASSWORD` | Redis password | If using individual vars | None | `secure_password` |

### 1.4 JWT Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `JWT_SECRET_KEY` | JWT signing key | Yes | None | `your-jwt-secret-key` |
| `ACCESS_TOKEN_LIFETIME` | Access token lifetime (minutes) | No | `15` | `15` |
| `REFRESH_TOKEN_LIFETIME` | Refresh token lifetime (days) | No | `7` | `7` |
| `JWT_ALGORITHM` | JWT signing algorithm | No | `HS256` | `HS256` |

### 1.5 Email Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `EMAIL_HOST` | SMTP server host | No | None | `smtp.gmail.com` |
| `EMAIL_PORT` | SMTP server port | No | `587` | `587` |
| `EMAIL_HOST_USER` | SMTP username | No | None | `email@gmail.com` |
| `EMAIL_HOST_PASSWORD` | SMTP password | No | None | `app-password` |
| `EMAIL_USE_TLS` | Use TLS | No | `True` | `True` |
| `EMAIL_USE_SSL` | Use SSL | No | `False` | `False` |
| `DEFAULT_FROM_EMAIL` | Default sender email | No | `webmaster@localhost` | `noreply@example.com` |

### 1.6 CORS Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `CORS_ALLOWED_ORIGINS` | Comma-separated list of allowed origins | Yes (Prod) | None | `https://app.example.com,https://www.example.com` |
| `CORS_ALLOW_ALL_ORIGINS` | Allow all origins | No | `False` | `True` / `False` |
| `CORS_ALLOW_CREDENTIALS` | Allow credentials | No | `False` | `True` |

### 1.7 Security Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `SECURE_SSL_REDIRECT` | Redirect HTTP to HTTPS | No | `False` | `True` |
| `SECURE_HSTS_SECONDS` | HSTS max age in seconds | No | `0` | `31536000` |
| `SESSION_COOKIE_SECURE` | Secure session cookie | No | `False` | `True` |
| `CSRF_COOKIE_SECURE` | Secure CSRF cookie | No | `False` | `True` |
| `SESSION_COOKIE_HTTPONLY` | HTTP-only session cookie | No | `True` | `True` |
| `SESSION_COOKIE_SAMESITE` | SameSite cookie policy | No | `Lax` | `Lax` / `Strict` |

### 1.8 Cache Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `CACHE_TTL_SHORT` | Short cache TTL in seconds | No | `60` | `60` |
| `CACHE_TTL_MEDIUM` | Medium cache TTL in seconds | No | `300` | `300` |
| `CACHE_TTL_LONG` | Long cache TTL in seconds | No | `3600` | `3600` |
| `CACHE_TTL_VERY_LONG` | Very long cache TTL in seconds | No | `86400` | `86400` |

### 1.9 Monitoring Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `SENTRY_DSN` | Sentry DSN for error tracking | No | None | `https://xxx@xxx.ingest.sentry.io/xxx` |
| `SENTRY_ENVIRONMENT` | Sentry environment | No | `production` | `production` |
| `SENTRY_TRACES_SAMPLE_RATE` | Sentry trace sample rate | No | `0.1` | `0.1` |
| `LOGGING_LEVEL` | Logging level | No | `INFO` | `DEBUG` / `INFO` / `WARNING` |

### 1.10 Performance Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `GUNICORN_WORKERS` | Number of Gunicorn workers | No | `4` | `4` |
| `GUNICORN_TIMEOUT` | Gunicorn timeout in seconds | No | `30` | `30` |
| `GUNICORN_LOG_LEVEL` | Gunicorn log level | No | `info` | `info` |

---

## Section 2: Next.js Frontend Variables

### 2.1 Public Variables (Exposed to Browser)

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `NEXT_PUBLIC_API_URL` | API base URL | Yes | None | `https://api.example.com/api/v1` |
| `NEXT_PUBLIC_APP_URL` | Application URL | No | None | `https://app.example.com` |
| `NEXT_PUBLIC_SITE_NAME` | Site name | No | `TaskFlow` | `TaskFlow` |
| `NEXT_PUBLIC_GA_ID` | Google Analytics ID | No | None | `G-XXXXXXXXXX` |

### 2.2 Server-Side Variables (Server Only)

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `API_SECRET_KEY` | API secret key for server-side requests | No | None | `your-api-secret` |
| `NEXTAUTH_SECRET` | NextAuth.js secret | No | None | `your-nextauth-secret` |
| `NEXTAUTH_URL` | NextAuth.js URL | No | None | `https://app.example.com` |

---

## Section 3: Database Variables

### 3.1 PostgreSQL Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `POSTGRES_DB` | Database name | Yes | `taskflow_db` | `taskflow_db` |
| `POSTGRES_USER` | Database username | Yes | `taskflow_user` | `taskflow_user` |
| `POSTGRES_PASSWORD` | Database password | Yes | None | `secure_password` |
| `POSTGRES_HOST` | Database host | Yes | `db` | `db` |
| `POSTGRES_PORT` | Database port | No | `5432` | `5432` |
| `POSTGRES_MAX_CONNECTIONS` | Max connections | No | `100` | `100` |

### 3.2 Redis Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `REDIS_PASSWORD` | Redis password | No | None | `secure_password` |
| `REDIS_MAX_MEMORY` | Max memory in bytes | No | `1gb` | `1gb` |
| `REDIS_EVICTION_POLICY` | Eviction policy | No | `allkeys-lru` | `allkeys-lru` |

---

## Section 4: Docker Variables

### 4.1 Compose Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `COMPOSE_PROJECT_NAME` | Compose project name | No | `taskflow` | `taskflow` |
| `DOCKER_REGISTRY` | Docker registry URL | No | None | `ghcr.io/username` |
| `DOCKER_IMAGE_TAG` | Image tag | No | `latest` | `v1.0.0` |

### 4.2 Service Variables

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `SERVICE_PORT` | Service port | No | `8000` | `8000` |
| `SERVICE_HOST` | Service host | No | `0.0.0.0` | `0.0.0.0` |
| `SERVICE_WORKERS` | Number of workers | No | `4` | `4` |
| `SERVICE_TIMEOUT` | Service timeout | No | `30` | `30` |

---

## Section 5: CI/CD Variables

### 5.1 GitHub Actions Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `GITHUB_TOKEN` | GitHub token for authentication | Yes | `github_pat_xxx` |
| `DOCKER_REGISTRY` | Docker registry URL | Yes | `ghcr.io` |
| `DOCKER_USERNAME` | Docker registry username | Yes | `username` |
| `DOCKER_PASSWORD` | Docker registry password | Yes | `password` |

### 5.2 Deployment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `SSH_PRIVATE_KEY` | SSH private key for deployment | Yes | `-----BEGIN RSA PRIVATE KEY-----` |
| `SSH_USER` | SSH username | Yes | `deploy` |
| `SSH_HOST` | SSH host | Yes | `example.com` |
| `SSH_KNOWN_HOSTS` | SSH known hosts | Yes | `example.com ssh-rsa xxx` |
| `DEPLOY_PATH` | Deployment path | Yes | `/var/www/app` |

---

## Section 6: Example .env Files

### 6.1 Development .env

```bash
# Django
DJANGO_ENV=development
DEBUG=True
SECRET_KEY=django-insecure-dev-key-12345
ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=postgresql://taskflow_user:password@localhost:5432/taskflow_db
REDIS_URL=redis://localhost:6379/1
CORS_ALLOWED_ORIGINS=http://localhost:3000

# JWT
JWT_SECRET_KEY=dev-jwt-secret-key

# Next.js
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1

# Docker
COMPOSE_PROJECT_NAME=taskflow
```

### 6.2 Production .env.production

```bash
# Django
DJANGO_ENV=production
DEBUG=False
SECRET_KEY=${DJANGO_SECRET_KEY}
ALLOWED_HOSTS=api.taskflow.com,www.api.taskflow.com
CSRF_TRUSTED_ORIGINS=https://api.taskflow.com
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
REDIS_URL=redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/1
CORS_ALLOWED_ORIGINS=https://app.taskflow.com,https://www.taskflow.com

# Security
SECURE_SSL_REDIRECT=True
SECURE_HSTS_SECONDS=31536000
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SESSION_COOKIE_HTTPONLY=True

# JWT
JWT_SECRET_KEY=${JWT_SECRET_KEY}

# Email
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=${EMAIL_USER}
EMAIL_HOST_PASSWORD=${EMAIL_PASSWORD}

# Monitoring
SENTRY_DSN=${SENTRY_DSN}
SENTRY_ENVIRONMENT=production

# Gunicorn
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=30

# Next.js
NEXT_PUBLIC_API_URL=https://api.taskflow.com/api/v1
NEXT_PUBLIC_APP_URL=https://app.taskflow.com
```

---

## Section 7: Environment Variables Checklist

### Pre-Deployment Checklist

- [ ] All required variables are set
- [ ] `SECRET_KEY` is secure (not `django-insecure-*`)
- [ ] `DEBUG` is `False` in production
- [ ] `ALLOWED_HOSTS` includes production domains
- [ ] `CSRF_TRUSTED_ORIGINS` includes production domains
- [ ] `CORS_ALLOWED_ORIGINS` includes frontend domains
- [ ] Database credentials are secure
- [ ] Redis password is set
- [ ] JWT secret key is set
- [ ] Email configuration is set (if applicable)
- [ ] Monitoring configuration is set
- [ ] `NEXT_PUBLIC_API_URL` points to production API
- [ ] No variables use `example.com` in production

### Security Considerations

- [ ] Never commit `.env` files to version control
- [ ] Use different secrets for different environments
- [ ] Rotate secrets periodically
- [ ] Use strong passwords (generated)
- [ ] Limit access to `.env` files
- [ ] Use secrets management tools (Vault, AWS Secrets Manager)

---

*This concludes Appendix V. Use this reference to properly configure your environment variables across all environments.*
