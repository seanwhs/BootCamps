# APPENDIX T — Complete CI/CD Pipeline Implementation

## Automated Build, Test, and Deployment for ScaleCart

---

## T.1 Introduction

This appendix provides a complete CI/CD pipeline implementation for the ScaleCart platform. It covers:

1. **GitHub Actions** – Complete workflow configurations
2. **GitLab CI** – GitLab pipeline configurations
3. **Jenkins** – Jenkins pipeline scripts
4. **ArgoCD** – GitOps continuous deployment
5. **Quality Gates** – Automated validation
6. **Release Management** – Versioning and rollbacks

---

## T.2 GitHub Actions Workflow

### T.2.1 Complete CI/CD Pipeline

```yaml
# File: .github/workflows/ci-cd.yml
# Complete CI/CD pipeline for ScaleCart

name: ScaleCart CI/CD Pipeline

on:
  push:
    branches:
      - main
      - develop
      - release/*
    tags:
      - v*
  pull_request:
    branches:
      - main
      - develop

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  PYTHON_VERSION: '3.10'

jobs:
  # ============================================
  # 1. CODE QUALITY & LINTING
  # ============================================
  lint:
    name: Code Quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements-dev.txt
      
      - name: Run Black
        run: black --check src/ tests/
      
      - name: Run isort
        run: isort --check-only src/ tests/
      
      - name: Run flake8
        run: flake8 src/ tests/
      
      - name: Run mypy
        run: mypy src/

  # ============================================
  # 2. UNIT & INTEGRATION TESTS
  # ============================================
  test:
    name: Tests
    runs-on: ubuntu-latest
    needs: lint
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: scalecart
          POSTGRES_PASSWORD: scalecart_password
          POSTGRES_DB: scalecart_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      mongodb:
        image: mongo:7.0
        env:
          MONGO_INITDB_ROOT_USERNAME: scalecart
          MONGO_INITDB_ROOT_PASSWORD: scalecart_password
          MONGO_INITDB_DATABASE: scalecart_test
        ports:
          - 27017:27017
        options: >-
          --health-cmd "mongosh --eval 'db.runCommand({ping:1})'"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
          pip install -r requirements-test.txt
      
      - name: Run migrations
        run: |
          alembic upgrade head
        env:
          DATABASE_URL: postgresql://scalecart:scalecart_password@localhost:5432/scalecart_test
          REDIS_URL: redis://localhost:6379/0
          MONGODB_URI: mongodb://scalecart:scalecart_password@localhost:27017/scalecart_test
      
      - name: Run unit tests
        run: pytest tests/unit -v --cov=src --cov-report=xml --cov-report=html
        env:
          DATABASE_URL: postgresql://scalecart:scalecart_password@localhost:5432/scalecart_test
          REDIS_URL: redis://localhost:6379/0
          MONGODB_URI: mongodb://scalecart:scalecart_password@localhost:27017/scalecart_test
      
      - name: Run integration tests
        run: pytest tests/integration -v
        env:
          DATABASE_URL: postgresql://scalecart:scalecart_password@localhost:5432/scalecart_test
          REDIS_URL: redis://localhost:6379/0
          MONGODB_URI: mongodb://scalecart:scalecart_password@localhost:27017/scalecart_test
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-umbrella
      
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: htmlcov/

  # ============================================
  # 3. SECURITY SCANNING
  # ============================================
  security:
    name: Security Scanning
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          ignore-unfixed: true
      
      - name: Upload Trivy results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: Run Snyk security scan
        uses: snyk/actions/python-3.10@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high --sarif-file-output=snyk.sarif
      
      - name: Upload Snyk results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: snyk.sarif
      
      - name: Run dependency check
        run: |
          pip install safety
          safety check -r requirements.txt --full-report

  # ============================================
  # 4. BUILD & PUBLISH
  # ============================================
  build:
    name: Build & Publish
    runs-on: ubuntu-latest
    needs: [test, security]
    if: github.event_name == 'push' && (github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v'))
    
    permissions:
      contents: read
      packages: write
      id-token: write
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,format=long
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: Build and push API image
        uses: docker/build-push-action@v4
        with:
          context: .
          target: production
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64
      
      - name: Build and push Worker image
        uses: docker/build-push-action@v4
        with:
          context: .
          target: production-worker
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}-worker:${{ steps.meta.outputs.version }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64
      
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          path: .
          format: spdx-json
          output-file: sbom.spdx.json
      
      - name: Upload SBOM
        uses: actions/upload-artifact@v3
        with:
          name: sbom
          path: sbom.spdx.json

  # ============================================
  # 5. DEPLOYMENT
  # ============================================
  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN_STAGING }}
          aws-region: us-east-1
      
      - name: Update ECS service
        run: |
          aws ecs update-service \
            --cluster scalecart-staging \
            --service scalecart-api \
            --task-definition ${{ secrets.ECS_TASK_DEFINITION_STAGING }} \
            --force-new-deployment
      
      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster scalecart-staging \
            --services scalecart-api
      
      - name: Run database migrations
        run: |
          aws ecs run-task \
            --cluster scalecart-staging \
            --task-definition ${{ secrets.ECS_MIGRATION_TASK_STAGING }} \
            --overrides '{"containerOverrides":[{"name":"migrate","command":["alembic","upgrade","head"]}]}'
      
      - name: Smoke tests
        run: |
          ./scripts/smoke-tests.sh https://staging-api.scalecart.com

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [build, deploy-staging]
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v')
    environment: production
    concurrency: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN_PRODUCTION }}
          aws-region: us-east-1
      
      - name: Update ECS service
        run: |
          aws ecs update-service \
            --cluster scalecart-production \
            --service scalecart-api \
            --task-definition ${{ secrets.ECS_TASK_DEFINITION_PRODUCTION }} \
            --force-new-deployment
      
      - name: Wait for deployment (Canary)
        run: |
          # Canary deployment - 10% traffic first
          aws ecs update-service \
            --cluster scalecart-production \
            --service scalecart-api \
            --desired-count 1
          
          sleep 60
          
          # Health check
          curl -f https://api.scalecart.com/health || exit 1
          
          # Scale to full
          aws ecs update-service \
            --cluster scalecart-production \
            --service scalecart-api \
            --desired-count 3
          
          aws ecs wait services-stable \
            --cluster scalecart-production \
            --services scalecart-api
      
      - name: Run database migrations (production)
        run: |
          aws ecs run-task \
            --cluster scalecart-production \
            --task-definition ${{ secrets.ECS_MIGRATION_TASK_PRODUCTION }} \
            --overrides '{"containerOverrides":[{"name":"migrate","command":["alembic","upgrade","head"]}]}'
      
      - name: Smoke tests
        run: |
          ./scripts/smoke-tests.sh https://api.scalecart.com
      
      - name: Notify success
        uses: slackapi/slack-github-action@v1.24.0
        if: success()
        with:
          channel-id: '#deployments'
          slack-message: '✅ ScaleCart Production deployed successfully\nVersion: ${{ github.sha }}\nEnvironment: Production\nDeployed by: ${{ github.actor }}'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
      
      - name: Notify failure
        uses: slackapi/slack-github-action@v1.24.0
        if: failure()
        with:
          channel-id: '#alerts'
          slack-message: '❌ ScaleCart Production deployment failed!\nVersion: ${{ github.sha }}\nEnvironment: Production\nDeployed by: ${{ github.actor }}\nCheck logs: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}

  # ============================================
  # 6. ROLLBACK
  # ============================================
  rollback:
    name: Rollback
    runs-on: ubuntu-latest
    if: failure() && github.ref == 'refs/heads/main'
    needs: deploy-production
    environment: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN_PRODUCTION }}
          aws-region: us-east-1
      
      - name: Rollback ECS service
        run: |
          # Get previous task definition
          PREVIOUS_TASK=$(aws ecs describe-services \
            --cluster scalecart-production \
            --services scalecart-api \
            --query 'services[0].taskDefinition' \
            --output text)
          
          aws ecs update-service \
            --cluster scalecart-production \
            --service scalecart-api \
            --task-definition $PREVIOUS_TASK \
            --force-new-deployment
          
          aws ecs wait services-stable \
            --cluster scalecart-production \
            --services scalecart-api
      
      - name: Rollback database migrations
        if: failure()
        run: |
          aws ecs run-task \
            --cluster scalecart-production \
            --task-definition ${{ secrets.ECS_MIGRATION_TASK_PRODUCTION }} \
            --overrides '{"containerOverrides":[{"name":"migrate","command":["alembic","downgrade","-1"]}]}'
      
      - name: Notify rollback
        uses: slackapi/slack-github-action@v1.24.0
        with:
          channel-id: '#alerts'
          slack-message: '🔄 ScaleCart Production rollback completed!\nVersion: ${{ github.sha }}\nAction: Automated rollback due to deployment failure'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

---

## T.3 GitLab CI Pipeline

### T.3.1 Complete GitLab CI Configuration

```yaml
# File: .gitlab-ci.yml
# GitLab CI/CD pipeline for ScaleCart

stages:
  - lint
  - test
  - security
  - build
  - deploy-staging
  - deploy-production
  - rollback

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""
  DOCKER_HOST: tcp://docker:2375
  IMAGE_NAME: ${CI_REGISTRY_IMAGE}
  PYTHON_VERSION: "3.10"

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - .cache/pip
    - .cache/pytest

# ============================================
# LINTING STAGE
# ============================================
lint:
  stage: lint
  image: python:${PYTHON_VERSION}-slim
  script:
    - pip install -r requirements-dev.txt
    - black --check src/ tests/
    - isort --check-only src/ tests/
    - flake8 src/ tests/
    - mypy src/
  only:
    - merge_requests
    - main
    - develop

# ============================================
# TEST STAGE
# ============================================
test:
  stage: test
  image: python:${PYTHON_VERSION}-slim
  services:
    - postgres:15
    - redis:7-alpine
    - mongo:7.0
  variables:
    POSTGRES_USER: scalecart
    POSTGRES_PASSWORD: scalecart_password
    POSTGRES_DB: scalecart_test
    DATABASE_URL: postgresql://scalecart:scalecart_password@postgres:5432/scalecart_test
    REDIS_URL: redis://redis:6379/0
    MONGODB_URI: mongodb://scalecart:scalecart_password@mongo:27017/scalecart_test
  script:
    - pip install -r requirements.txt -r requirements-dev.txt -r requirements-test.txt
    - alembic upgrade head
    - pytest tests/unit -v --cov=src --cov-report=term --cov-report=html
    - pytest tests/integration -v
  coverage: '/TOTAL.+ ([0-9]{1,3}%)/'
  artifacts:
    paths:
      - htmlcov/
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
  only:
    - merge_requests
    - main
    - develop

# ============================================
# SECURITY STAGE
# ============================================
security:
  stage: security
  image: docker:latest
  services:
    - docker:dind
  script:
    - apk add --no-cache python3 py3-pip
    - pip3 install safety
    - pip3 install -r requirements.txt
    - safety check -r requirements.txt --full-report
    - docker run --rm -v $(pwd):/app aquasec/trivy fs --no-progress /app
  only:
    - main
    - develop

# ============================================
# BUILD STAGE
# ============================================
build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
  script:
    - docker build --target production -t ${IMAGE_NAME}:${CI_COMMIT_SHA} .
    - docker build --target production-worker -t ${IMAGE_NAME}-worker:${CI_COMMIT_SHA} .
    - docker tag ${IMAGE_NAME}:${CI_COMMIT_SHA} ${IMAGE_NAME}:latest
    - docker push ${IMAGE_NAME}:${CI_COMMIT_SHA}
    - docker push ${IMAGE_NAME}:latest
    - docker push ${IMAGE_NAME}-worker:${CI_COMMIT_SHA}
  only:
    - main
    - develop
    - tags

# ============================================
# DEPLOYMENT STAGES
# ============================================
deploy-staging:
  stage: deploy-staging
  image: registry.gitlab.com/gitlab-org/cloud-deploy:latest
  script:
    - cloud-deploy deploy --environment staging --image ${IMAGE_NAME}:${CI_COMMIT_SHA}
    - kubectl set image deployment/scalecart-api api=${IMAGE_NAME}:${CI_COMMIT_SHA} -n staging
    - kubectl rollout status deployment/scalecart-api -n staging
    - kubectl run smoke-test --image=curlimages/curl -i --rm --restart=Never -- curl -f https://staging-api.scalecart.com/health
  environment:
    name: staging
    url: https://staging-api.scalecart.com
  only:
    - develop

deploy-production:
  stage: deploy-production
  image: registry.gitlab.com/gitlab-org/cloud-deploy:latest
  before_script:
    - apk add --no-cache curl jq
  script:
    - |
      # Canary deployment
      kubectl set image deployment/scalecart-api api=${IMAGE_NAME}:${CI_COMMIT_SHA} -n production
      kubectl rollout status deployment/scalecart-api -n production
      
      # Smoke tests
      curl -f https://api.scalecart.com/health || exit 1
      
      # Run database migrations
      kubectl run migration --image=${IMAGE_NAME}:${CI_COMMIT_SHA} -n production --restart=Never -- /bin/sh -c "alembic upgrade head"
      kubectl wait --for=condition=complete job/migration -n production --timeout=300s
      
      # Full rollout
      kubectl rollout restart deployment/scalecart-api -n production
      kubectl rollout status deployment/scalecart-api -n production
  environment:
    name: production
    url: https://api.scalecart.com
  only:
    - main
  when: manual
  allow_failure: false

rollback-production:
  stage: rollback
  image: bitnami/kubectl:latest
  script:
    - kubectl rollout undo deployment/scalecart-api -n production
    - kubectl rollout status deployment/scalecart-api -n production
  environment:
    name: production
    action: rollback
  only:
    - main
  when: manual
  allow_failure: false
```

---

## T.4 Jenkins Pipeline

### T.4.1 Jenkins Declarative Pipeline

```groovy
// File: Jenkinsfile
// Declarative Jenkins pipeline for ScaleCart

pipeline {
    agent any
    
    tools {
        python 'Python-3.10'
    }
    
    environment {
        REGISTRY = 'docker.io'
        IMAGE_NAME = 'scalecart/api'
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        AWS_CREDENTIALS = credentials('aws-credentials')
        SONAR_HOST_URL = 'https://sonarqube.scalecart.com'
    }
    
    stages {
        // ============================================
        // 1. CODE QUALITY
        // ============================================
        stage('Code Quality') {
            parallel {
                stage('Black') {
                    steps {
                        sh 'black --check src/ tests/'
                    }
                }
                stage('isort') {
                    steps {
                        sh 'isort --check-only src/ tests/'
                    }
                }
                stage('Flake8') {
                    steps {
                        sh 'flake8 src/ tests/'
                    }
                }
                stage('Mypy') {
                    steps {
                        sh 'mypy src/'
                    }
                }
            }
        }
        
        // ============================================
        // 2. UNIT TESTS
        // ============================================
        stage('Unit Tests') {
            steps {
                sh '''
                    pip install -r requirements.txt
                    pip install -r requirements-dev.txt
                    pytest tests/unit -v --cov=src --cov-report=xml
                '''
            }
            post {
                always {
                    junit 'test-results/**/*.xml'
                    publishHTML([
                        target: [
                            allowMissing: false,
                            alwaysLinkToLastBuild: true,
                            reportDir: 'htmlcov',
                            reportFiles: 'index.html',
                            reportName: 'Coverage Report'
                        ]
                    ])
                }
            }
        }
        
        // ============================================
        // 3. INTEGRATION TESTS
        // ============================================
        stage('Integration Tests') {
            steps {
                sh '''
                    docker-compose -f docker-compose.test.yml up -d
                    sleep 10
                    pytest tests/integration -v
                    docker-compose -f docker-compose.test.yml down
                '''
            }
        }
        
        // ============================================
        // 4. SECURITY SCAN
        // ============================================
        stage('Security Scan') {
            steps {
                sh '''
                    pip install safety bandit
                    safety check -r requirements.txt
                    bandit -r src/ -f json -o bandit-report.json
                '''
            }
            post {
                always {
                    publishHTML([
                        target: [
                            allowMissing: true,
                            reportDir: '.',
                            reportFiles: 'bandit-report.json',
                            reportName: 'Bandit Security Report'
                        ]
                    ])
                }
            }
        }
        
        // ============================================
        // 5. SONARQUBE ANALYSIS
        // ============================================
        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonarqube-token')
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner -Dsonar.login=$SONAR_TOKEN'
                }
            }
        }
        
        // ============================================
        // 6. BUILD & PUBLISH
        // ============================================
        stage('Build & Publish') {
            when {
                branch 'main'
            }
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY}", 'docker-hub-credentials') {
                        def apiImage = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                        apiImage.push()
                        apiImage.push('latest')
                    }
                }
            }
        }
        
        // ============================================
        // 7. DEPLOY TO STAGING
        // ============================================
        stage('Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                sh '''
                    kubectl set image deployment/scalecart-api \
                        api=${IMAGE_NAME}:${BUILD_NUMBER} \
                        -n staging
                    kubectl rollout status deployment/scalecart-api -n staging
                '''
            }
        }
        
        // ============================================
        // 8. DEPLOY TO PRODUCTION
        // ============================================
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            input {
                message "Deploy to Production?"
                ok "Yes, deploy"
            }
            steps {
                sh '''
                    kubectl set image deployment/scalecart-api \
                        api=${IMAGE_NAME}:${BUILD_NUMBER} \
                        -n production
                    kubectl rollout status deployment/scalecart-api -n production
                '''
            }
        }
        
        // ============================================
        // 9. SMOKE TESTS
        // ============================================
        stage('Smoke Tests') {
            steps {
                sh '''
                    curl -f https://api.scalecart.com/health || exit 1
                    curl -f https://api.scalecart.com/api/v1/products?limit=1 || exit 1
                '''
            }
        }
    }
    
    // ============================================
    // POST-ACTIONS
    // ============================================
    post {
        success {
            emailext (
                subject: "✅ ScaleCart Pipeline Succeeded - ${env.BUILD_NUMBER}",
                body: "Pipeline ${env.JOB_NAME} build ${env.BUILD_NUMBER} succeeded.\n\n" +
                      "Changes: ${env.GIT_COMMIT}\n" +
                      "URL: ${env.BUILD_URL}",
                to: 'engineering@scalecart.com'
            )
        }
        failure {
            emailext (
                subject: "❌ ScaleCart Pipeline Failed - ${env.BUILD_NUMBER}",
                body: "Pipeline ${env.JOB_NAME} build ${env.BUILD_NUMBER} failed.\n\n" +
                      "Changes: ${env.GIT_COMMIT}\n" +
                      "URL: ${env.BUILD_URL}\n\n" +
                      "Check logs for details.",
                to: 'engineering@scalecart.com'
            )
        }
    }
}
```

---

## T.5 ArgoCD GitOps Configuration

### T.5.1 ArgoCD Application

```yaml
# File: argocd/applications/scalecart.yaml
# ArgoCD application for GitOps

apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scalecart
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/scalecart/scalecart.git
    targetRevision: HEAD
    path: k8s/overlays/production
    directory:
      recurse: true
      jsonnet: {}
  destination:
    server: https://kubernetes.default.svc
    namespace: scalecart
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - Validate=true
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
      - ApplyOutOfSyncOnly=false
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m

---
# File: argocd/applications/scalecart-staging.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scalecart-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/scalecart/scalecart.git
    targetRevision: develop
    path: k8s/overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: staging
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### T.5.2 Kustomize Overlays

```yaml
# File: k8s/overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

patches:
  - path: patch-replicas.yaml
  - path: patch-resources.yaml
  - path: patch-ingress.yaml
  - path: patch-secrets.yaml

images:
  - name: scalecart/api
    newName: ghcr.io/scalecart/api
    newTag: latest

namespace: scalecart

configMapGenerator:
  - name: scalecart-config
    behavior: merge
    literals:
      - APP_ENV=production
      - DEBUG=false
      - LOG_LEVEL=INFO
      - ENABLE_METRICS=true

secretGenerator:
  - name: scalecart-secrets
    behavior: merge
    envs:
      - .env.production

resources:
  - namespace.yaml
  - pvcs.yaml
```

---

## T.6 Quality Gates

### T.6.1 Quality Gate Configuration

```yaml
# File: .quality-gates.yaml
# Quality gate thresholds

quality_gates:
  test_coverage:
    threshold: 80
    metric: coverage
    action: fail
  
  test_success:
    threshold: 100
    metric: pass_rate
    action: fail
  
  security:
    high_issues: 0
    critical_issues: 0
    action: fail
  
  performance:
    p95_response_time: 500ms
    error_rate: 1%
    action: warn
  
  linting:
    errors: 0
    warnings: 10
    action: fail
  
  dependency:
    outdated: 5
    vulnerable: 0
    action: fail
```

### T.6.2 Quality Gate Validation

```python
# File: scripts/quality-gate.py
"""
Quality gate validation script.
"""

import sys
import json
from typing import Dict, Any

class QualityGate:
    """Quality gate validation."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.failures = []
        self.warnings = []
    
    def check_coverage(self, coverage: float):
        """Check test coverage threshold."""
        threshold = self.config.get('test_coverage', {}).get('threshold', 80)
        if coverage < threshold:
            self.failures.append(f"Coverage {coverage}% below threshold {threshold}%")
    
    def check_test_success(self, pass_rate: float):
        """Check test success rate."""
        threshold = self.config.get('test_success', {}).get('threshold', 100)
        if pass_rate < threshold:
            self.failures.append(f"Test pass rate {pass_rate}% below threshold {threshold}%")
    
    def check_security(self, high_issues: int, critical_issues: int):
        """Check security issues."""
        config = self.config.get('security', {})
        if high_issues > config.get('high_issues', 0):
            self.failures.append(f"High security issues: {high_issues}")
        if critical_issues > config.get('critical_issues', 0):
            self.failures.append(f"Critical security issues: {critical_issues}")
    
    def check_performance(self, p95_response_time: float, error_rate: float):
        """Check performance thresholds."""
        config = self.config.get('performance', {})
        if p95_response_time > config.get('p95_response_time', 500):
            self.warnings.append(f"p95 response time {p95_response_time}ms above threshold")
        if error_rate > config.get('error_rate', 1.0):
            self.warnings.append(f"Error rate {error_rate}% above threshold")
    
    def validate(self) -> bool:
        """Run all quality gates."""
        if self.failures:
            print("❌ Quality Gates Failed:")
            for failure in self.failures:
                print(f"  - {failure}")
            return False
        
        if self.warnings:
            print("⚠️ Quality Gates Warnings:")
            for warning in self.warnings:
                print(f"  - {warning}")
        
        print("✅ All Quality Gates Passed!")
        return True

# Usage
if __name__ == "__main__":
    # Load configuration
    with open('.quality-gates.yaml', 'r') as f:
        import yaml
        config = yaml.safe_load(f)
    
    # Load test results
    with open('test-results.json', 'r') as f:
        results = json.load(f)
    
    # Validate
    gate = QualityGate(config)
    gate.check_coverage(results.get('coverage', 0))
    gate.check_test_success(results.get('pass_rate', 0))
    gate.check_security(results.get('high_issues', 0), results.get('critical_issues', 0))
    gate.check_performance(results.get('p95_response_time', 0), results.get('error_rate', 0))
    
    sys.exit(0 if gate.validate() else 1)
```

---

## T.7 Release Management

### T.7.1 Semantic Versioning

```yaml
# File: .release-please-config.json
{
  "release-type": "python",
  "bump-minor-pre-major": true,
  "bump-patch-for-minor-pre-major": true,
  "draft": false,
  "prerelease": false,
  "packages": {
    ".": {
      "package-name": "scalecart",
      "extra-files": [
        "pyproject.toml",
        "src/__init__.py"
      ]
    }
  },
  "changelog-sections": [
    {"type": "feat", "section": "Features"},
    {"type": "fix", "section": "Bug Fixes"},
    {"type": "perf", "section": "Performance Improvements"},
    {"type": "docs", "section": "Documentation"},
    {"type": "style", "section": "Styles"},
    {"type": "refactor", "section": "Code Refactoring"},
    {"type": "test", "section": "Tests"},
    {"type": "build", "section": "Build System"},
    {"type": "ci", "section": "CI/CD"}
  ]
}
```

### T.7.2 Release Script

```bash
#!/bin/bash
# File: scripts/release.sh
# Automated release script

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}ScaleCart Release Script${NC}"
echo "=========================="

# 1. Get version
read -p "Enter version (e.g., 1.2.3): " VERSION
if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Invalid version format${NC}"
    exit 1
fi

# 2. Update version
echo -e "${YELLOW}Updating version to ${VERSION}...${NC}"
sed -i "s/version = .*/version = \"${VERSION}\"/" pyproject.toml
sed -i "s/__version__ = .*/__version__ = \"${VERSION}\"/" src/__init__.py

# 3. Run tests
echo -e "${YELLOW}Running tests...${NC}"
pytest tests/ -v --cov=src

# 4. Build distribution
echo -e "${YELLOW}Building distribution...${NC}"
python -m build

# 5. Update CHANGELOG
echo -e "${YELLOW}Updating CHANGELOG...${NC}"
cat > CHANGELOG.md.new << EOF
## [${VERSION}] - $(date +%Y-%m-%d)

### Added
- New features

### Changed
- Changes

### Fixed
- Bug fixes

---
EOF
cat CHANGELOG.md >> CHANGELOG.md.new
mv CHANGELOG.md.new CHANGELOG.md

# 6. Git commit
echo -e "${YELLOW}Committing changes...${NC}"
git add pyproject.toml src/__init__.py CHANGELOG.md
git commit -m "chore: release v${VERSION}"
git tag -a "v${VERSION}" -m "Release v${VERSION}"

# 7. Push
echo -e "${YELLOW}Pushing to remote...${NC}"
git push origin main
git push origin "v${VERSION}"

echo -e "${GREEN}✅ Release v${VERSION} created${NC}"
```

---

## T.8 CI/CD Quick Reference

### T.8.1 Common Commands

```bash
# ============================================
# GITHUB ACTIONS
# ============================================

# Run workflow locally
act -j test

# List workflows
gh workflow list

# Trigger workflow
gh workflow run ci-cd.yml --ref main

# ============================================
# GITLAB CI
# ============================================

# Run pipeline locally
gitlab-ci-local

# Trigger pipeline
curl -X POST -F token=$CI_JOB_TOKEN -F ref=main https://gitlab.com/api/v4/projects/1/trigger/pipeline

# ============================================
# JENKINS
# ============================================

# Trigger build
curl -X POST http://jenkins:8080/job/scalecart/build --user user:password

# Get build status
curl http://jenkins:8080/job/scalecart/lastBuild/api/json --user user:password

# ============================================
# ARGOCD
# ============================================

# Sync application
argocd app sync scalecart

# Get application status
argocd app get scalecart

# Rollback
argocd app rollback scalecart

# ============================================
# KUBERNETES
# ============================================

# Deploy
kubectl apply -f k8s/overlays/production/

# Rollback
kubectl rollout undo deployment/scalecart-api -n scalecart

# Get status
kubectl rollout status deployment/scalecart-api -n scalecart
```

---

**[END OF APPENDIX T]**

*This comprehensive CI/CD appendix provides everything needed to automate build, test, and deployment for the ScaleCart platform. Use these configurations to implement a robust, automated delivery pipeline.*
