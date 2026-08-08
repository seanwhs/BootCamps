# Part 32: CI/CD

## Automating Your Deployment Pipeline

Welcome to **Part 32** of the Django REST Framework & Next.js 16 masterclass. Now that we have a complete production-ready application, it's time to set up Continuous Integration and Continuous Deployment (CI/CD). We'll automate testing, building, and deployment so that every code change is automatically validated and deployed.

In this part, we'll:
- Set up GitHub Actions for CI/CD
- Automate testing on every push
- Build and publish Docker images
- Deploy to production automatically
- Implement environment-specific workflows
- Add security scanning and notifications

Think of CI/CD as your **automated quality control and delivery system**. Just as a factory assembly line automatically tests and packages products, CI/CD automatically tests, builds, and deploys your application.

---

## The Target

We'll create a complete CI/CD pipeline:

```
.github/
├── workflows/
│   ├── ci.yml                  # Continuous Integration
│   ├── cd.yml                  # Continuous Deployment
│   ├── security.yml            # Security scanning
│   └── staging.yml             # Staging deployment
├── dependabot.yml              # Dependency updates
└── CODEOWNERS                  # Code ownership
```

---

## The Concept

### CI/CD Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline Flow                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Push Code ──▶ Build ──▶ Test ──▶ Security Scan ──▶ Deploy        │
│                                                                     │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │  Lint   │─▶│  Unit   │─▶│ E2E     │─▶│  Scan   │─▶│ Deploy  │ │
│  │  Check  │  │  Tests  │  │ Tests   │  │         │  │         │ │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### CI/CD Principles

1. **Automate Everything**: No manual steps
2. **Fail Fast**: Stop on first failure
3. **Test in Production-Like Environment**: Avoid surprises
4. **Rollback Ready**: Always be able to revert
5. **Monitor Everything**: Know what's happening

### Workflow Triggers

| Trigger | Purpose |
|---------|---------|
| **Push to main** | Deploy to production |
| **Push to staging** | Deploy to staging |
| **Pull Request** | Run tests |
| **Schedule** | Security updates |
| **Manual** | Custom deployments |

---

## The Implementation

### Step 1: Create CI Workflow

**.github/workflows/ci.yml** (create)

```yaml
name: CI - Continuous Integration

on:
  push:
    branches: [main, develop, staging]
  pull_request:
    branches: [main, develop]

env:
  PYTHON_VERSION: 3.12
  NODE_VERSION: 20
  POSTGRES_VERSION: 15

jobs:
  lint-backend:
    name: Lint Backend
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          cd backend
          python -m pip install --upgrade pip
          pip install -r requirements/development.txt
          pip install flake8 black mypy

      - name: Run flake8
        run: |
          cd backend
          flake8 apps/ config/ --count --max-complexity=10 --max-line-length=120 --statistics

      - name: Run black (check)
        run: |
          cd backend
          black --check apps/ config/

      - name: Run mypy
        run: |
          cd backend
          mypy apps/ config/ --ignore-missing-imports

  lint-frontend:
    name: Lint Frontend
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        run: |
          cd frontend
          npm ci

      - name: Run ESLint
        run: |
          cd frontend
          npm run lint

      - name: Run TypeScript check
        run: |
          cd frontend
          npx tsc --noEmit

  test-backend:
    name: Test Backend
    runs-on: ubuntu-latest
    needs: lint-backend
    services:
      postgres:
        image: postgres:${{ env.POSTGRES_VERSION }}-alpine
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Install dependencies
        run: |
          cd backend
          python -m pip install --upgrade pip
          pip install -r requirements/development.txt

      - name: Run backend tests
        run: |
          cd backend
          cp .env.example .env
          python manage.py migrate
          pytest --cov=apps --cov-report=term --cov-report=xml
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379/1
          DJANGO_SETTINGS_MODULE: config.settings

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          file: ./backend/coverage.xml
          flags: backend
          name: backend-coverage

  test-frontend:
    name: Test Frontend
    runs-on: ubuntu-latest
    needs: lint-frontend
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json

      - name: Install dependencies
        run: |
          cd frontend
          npm ci

      - name: Run frontend tests
        run: |
          cd frontend
          npm run test -- --coverage

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v4
        with:
          flags: frontend
          name: frontend-coverage
          directory: frontend/coverage

  e2e-tests:
    name: E2E Tests
    runs-on: ubuntu-latest
    needs: [test-backend, test-frontend]
    services:
      postgres:
        image: postgres:${{ env.POSTGRES_VERSION }}-alpine
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install backend dependencies
        run: |
          cd backend
          python -m pip install --upgrade pip
          pip install -r requirements/development.txt

      - name: Install frontend dependencies
        run: |
          cd frontend
          npm ci

      - name: Build frontend
        run: |
          cd frontend
          npm run build

      - name: Install Playwright browsers
        run: |
          cd frontend
          npx playwright install --with-deps

      - name: Start backend
        run: |
          cd backend
          cp .env.example .env
          python manage.py migrate
          python manage.py runserver 0.0.0.0:8000 &
        env:
          DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379/1

      - name: Start frontend
        run: |
          cd frontend
          npm run start &
        env:
          NEXT_PUBLIC_API_URL: http://localhost:8000/api/v1

      - name: Wait for services
        run: |
          sleep 10
          curl -f http://localhost:3000/api/health
          curl -f http://localhost:8000/health/

      - name: Run E2E tests
        run: |
          cd frontend
          npx playwright test

      - name: Upload Playwright report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: frontend/playwright-report/
```

### Step 2: Create CD Workflow

**.github/workflows/cd.yml** (create)

```yaml
name: CD - Continuous Deployment

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  DOCKER_REGISTRY: ghcr.io
  DOCKER_IMAGE_BACKEND: ${{ github.repository }}-backend
  DOCKER_IMAGE_FRONTEND: ${{ github.repository }}-frontend
  REGISTRY_USERNAME: ${{ github.actor }}
  REGISTRY_PASSWORD: ${{ secrets.GITHUB_TOKEN }}

jobs:
  build-and-push:
    name: Build and Push Docker Images
    runs-on: ubuntu-latest
    outputs:
      backend_image: ${{ steps.backend-image.outputs.image }}
      frontend_image: ${{ steps.frontend-image.outputs.image }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to Docker Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ env.REGISTRY_USERNAME }}
          password: ${{ env.REGISTRY_PASSWORD }}

      - name: Extract metadata for Backend
        id: backend-meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE_BACKEND }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,format=short
            latest

      - name: Build and push Backend image
        uses: docker/build-push-action@v5
        with:
          context: ./backend
          file: ./backend/Dockerfile
          push: true
          tags: ${{ steps.backend-meta.outputs.tags }}
          labels: ${{ steps.backend-meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Extract metadata for Frontend
        id: frontend-meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE_FRONTEND }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,format=short
            latest

      - name: Build and push Frontend image
        uses: docker/build-push-action@v5
        with:
          context: ./frontend
          file: ./frontend/Dockerfile
          push: true
          tags: ${{ steps.frontend-meta.outputs.tags }}
          labels: ${{ steps.frontend-meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Set image tags output
        id: backend-image
        run: |
          echo "image=${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE_BACKEND }}:${{ steps.backend-meta.outputs.version }}" >> $GITHUB_OUTPUT

      - name: Set image tags output
        id: frontend-image
        run: |
          echo "image=${{ env.DOCKER_REGISTRY }}/${{ env.DOCKER_IMAGE_FRONTEND }}:${{ steps.frontend-meta.outputs.version }}" >> $GITHUB_OUTPUT

  deploy:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build-and-push
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install SSH key
        uses: shimataro/ssh-key-action@v2
        with:
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          name: id_rsa
          known_hosts: ${{ secrets.SSH_KNOWN_HOSTS }}

      - name: Deploy to server
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} << 'EOF'
            cd ~/taskflow
            docker-compose -f docker-compose.prod.yml pull
            docker-compose -f docker-compose.prod.yml down
            docker-compose -f docker-compose.prod.yml up -d
            docker system prune -f
          EOF

  notify:
    name: Send Notification
    runs-on: ubuntu-latest
    needs: [build-and-push, deploy]
    if: always()
    steps:
      - name: Send Slack notification
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload: |
            {
              "text": "Deployment status: ${{ needs.deploy.result }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "🚀 *TaskFlow Deployment*\nStatus: ${{ needs.deploy.result == 'success' && '✅ Success' || '❌ Failed' }}\nCommit: ${{ github.sha }}\nBranch: ${{ github.ref_name }}\nAction: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Step 3: Create Security Workflow

**.github/workflows/security.yml** (create)

```yaml
name: Security Scan

on:
  schedule:
    - cron: '0 0 * * *'  # Daily
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  sast:
    name: SAST (Static Application Security Testing)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/django
            p/javascript
            p/typescript
            p/react

  dependency-scan:
    name: Dependency Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install Safety
        run: pip install safety

      - name: Scan Python dependencies
        run: |
          cd backend
          pip install -r requirements/base.txt
          safety check --full-report

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Scan npm dependencies
        run: |
          cd frontend
          npm audit --audit-level=moderate

  secrets-scan:
    name: Secrets Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run TruffleHog
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: HEAD^
          head: HEAD
```

### Step 4: Create Dependabot Configuration

**.github/dependabot.yml** (create)

```yaml
version: 2
updates:
  # Python dependencies
  - package-ecosystem: pip
    directory: /backend
    schedule:
      interval: weekly
      day: monday
      time: '09:00'
    open-pull-requests-limit: 10
    reviewers:
      - team-maintainers
    labels:
      - dependencies
      - python

  # Node.js dependencies
  - package-ecosystem: npm
    directory: /frontend
    schedule:
      interval: weekly
      day: monday
      time: '09:00'
    open-pull-requests-limit: 10
    reviewers:
      - team-maintainers
    labels:
      - dependencies
      - javascript

  # GitHub Actions
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
      day: monday
      time: '09:00'
    open-pull-requests-limit: 5
    reviewers:
      - team-maintainers
    labels:
      - dependencies
      - ci-cd
```

### Step 5: Create Staging Workflow

**.github/workflows/staging.yml** (create)

```yaml
name: Deploy to Staging

on:
  push:
    branches: [staging]
  workflow_dispatch:

jobs:
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install SSH key
        uses: shimataro/ssh-key-action@v2
        with:
          key: ${{ secrets.STAGING_SSH_PRIVATE_KEY }}
          name: id_rsa
          known_hosts: ${{ secrets.STAGING_SSH_KNOWN_HOSTS }}

      - name: Deploy to staging server
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.STAGING_SSH_USER }}@${{ secrets.STAGING_SSH_HOST }} << 'EOF'
            cd ~/taskflow-staging
            git pull origin staging
            docker-compose -f docker-compose.staging.yml pull
            docker-compose -f docker-compose.staging.yml down
            docker-compose -f docker-compose.staging.yml up -d
            docker system prune -f
          EOF

  notify-staging:
    name: Send Staging Notification
    runs-on: ubuntu-latest
    needs: deploy-staging
    if: always()
    steps:
      - name: Send Slack notification
        uses: slackapi/slack-github-action@v1.24.0
        with:
          payload: |
            {
              "text": "Staging deployment: ${{ needs.deploy-staging.result }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "🧪 *TaskFlow Staging*\nStatus: ${{ needs.deploy-staging.result == 'success' && '✅ Success' || '❌ Failed' }}\nCommit: ${{ github.sha }}\nBranch: staging"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Step 6: Create CODEOWNERS

**.github/CODEOWNERS** (create)

```markdown
# Code ownership for pull request reviews

# Backend
/backend/ @team-backend
/backend/apps/users/ @user-team
/backend/apps/projects/ @project-team
/backend/apps/tasks/ @task-team
/backend/apps/comments/ @task-team

# Frontend
/frontend/ @team-frontend
/frontend/app/ @ui-team
/frontend/components/ @ui-team

# DevOps
/docker-compose*.yml @devops-team
/.github/ @devops-team
/nginx/ @devops-team

# Root files
/*.md @docs-team
```

### Step 7: Create Deployment Status Badge

**README.md** (add badges)

```markdown
# TaskFlow

[![CI](https://github.com/yourusername/taskflow/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/taskflow/actions/workflows/ci.yml)
[![CD](https://github.com/yourusername/taskflow/actions/workflows/cd.yml/badge.svg)](https://github.com/yourusername/taskflow/actions/workflows/cd.yml)
[![Security](https://github.com/yourusername/taskflow/actions/workflows/security.yml/badge.svg)](https://github.com/yourusername/taskflow/actions/workflows/security.yml)
[![codecov](https://codecov.io/gh/yourusername/taskflow/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/taskflow)

## Description

TaskFlow is a modern task management platform built with Django REST Framework and Next.js.

## Status

- **Production**: https://app.taskflow.com
- **Staging**: https://staging.taskflow.com
- **API**: https://api.taskflow.com
```

### Step 8: Create Rollback Script

**scripts/rollback.sh** (create)

```bash
#!/bin/bash

# Rollback script

set -e

echo "🔄 Rolling back deployment..."

# Get the previous image tag
PREVIOUS_TAG=$(cat .previous-tag)

if [ -z "$PREVIOUS_TAG" ]; then
    echo "❌ No previous tag found"
    exit 1
fi

echo "Rolling back to: $PREVIOUS_TAG"

# Update docker-compose to use previous tag
export BACKEND_TAG=$PREVIOUS_TAG
export FRONTEND_TAG=$PREVIOUS_TAG

# Deploy previous version
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

echo "✅ Rollback complete"

# Send notification
curl -X POST $SLACK_WEBHOOK_URL \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"🔄 Rollback complete to $PREVIOUS_TAG\"}"
```

---

## The Verification

### Step 1: Test CI Workflow

```bash
# Push a change to a branch
git checkout -b feature/test-ci
git add .
git commit -m "Test CI workflow"
git push origin feature/test-ci

# Create a pull request
# The CI workflow should run automatically
```

### Step 2: Check Workflow Status

1. Go to GitHub Actions
2. Check the CI workflow
3. ✅ Should run all jobs
4. ✅ Should pass or fail appropriately

### Step 3: Test CD Workflow

```bash
# Merge to main
git checkout main
git merge feature/test-ci
git push origin main

# The CD workflow should deploy to production
```

### Step 4: Check Security Scanning

1. Go to GitHub Actions
2. Check the Security workflow
3. ✅ Should run daily
4. ✅ Should scan dependencies

### Step 5: Test Dependabot

1. Go to GitHub Insights > Dependency graph
2. ✅ Should show Dependabot configuration
3. ✅ Should have open PRs for updates

---

## Key Takeaways

1. **CI/CD automates** testing, building, and deployment.

2. **Multiple workflows** handle different stages and environments.

3. **Security scanning** identifies vulnerabilities early.

4. **Automated testing** catches issues before deployment.

5. **Dependabot** keeps dependencies up to date.

6. **Environment-specific workflows** enable staging and production.

7. **Notifications** keep the team informed.

8. **Rollback scripts** enable quick recovery.

---

## What's Next

In **Part 33**, we'll implement observability and production operations:

- Structured logging
- Application monitoring
- Error tracking
- Performance metrics
- Alerting

---

**End of Part 32**

*Next: Part 33 - Observability & Production Operations*
