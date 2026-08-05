# APPENDIX Y — Complete Installation & Setup Guide

## The Definitive Guide to Getting ScaleCart Running

---

## Y.1 Introduction

This appendix provides the most comprehensive, step-by-step installation and setup guide for the ScaleCart platform. It covers:

1. **System Requirements** – What you need
2. **Quick Install** – 10-minute setup
3. **Development Environment** – Full dev setup
4. **Production Environment** – Production deployment
5. **Cloud Deployment** – AWS, GCP, Azure
6. **Troubleshooting** – Common issues and solutions

---

## Y.2 System Requirements

### Y.2.1 Hardware Requirements

| Environment | CPU | RAM | Storage | Network |
|-------------|-----|-----|---------|---------|
| **Development** | 2 cores | 8 GB | 20 GB SSD | 100 Mbps |
| **Staging** | 4 cores | 16 GB | 50 GB SSD | 1 Gbps |
| **Production** | 8+ cores | 32+ GB | 200+ GB SSD | 10 Gbps |

### Y.2.2 Software Requirements

```bash
# Required Software
Docker: 20.10+
Docker Compose: 2.0+
Python: 3.10+
Git: 2.30+
Make: (optional but recommended)

# Optional Software (for development)
VS Code: 1.80+
Postman: 10.0+
DBeaver: 23.0+
```

### Y.2.3 Port Requirements

| Service | Port | Required | Notes |
|---------|------|----------|-------|
| API | 8000 | Yes | Main application |
| PostgreSQL | 5432 | Yes | Primary database |
| Redis | 6379 | Yes | Cache and sessions |
| MongoDB | 27017 | Yes | Document cache |
| Neo4j HTTP | 7474 | No | Graph DB browser |
| Neo4j Bolt | 7687 | Yes | Graph DB connection |
| Prometheus | 9090 | No | Monitoring |
| Grafana | 3000 | No | Dashboards |
| TimescaleDB | 5433 | No | Time-series DB |

---

## Y.3 Quick Install (10 Minutes)

### Y.3.1 Automated Installation

```bash
# One-command installation
curl -fsSL https://raw.githubusercontent.com/scalecart/scalecart/main/scripts/install.sh | bash

# Or if you prefer manual steps:
git clone https://github.com/scalecart/scalecart.git
cd scalecart
make env
make up
make db-init
make db-seed
make db-migrate
```

### Y.3.2 Verify Installation

```bash
# Check all services are running
docker compose ps

# Check API health
curl http://localhost:8000/health

# Check products endpoint
curl http://localhost:8000/api/v1/products

# Open API documentation
open http://localhost:8000/docs
```

### Y.3.3 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| API | - | - |
| Grafana | admin | admin |
| Neo4j | neo4j | scalecart_neo4j_password |
| PostgreSQL | scalecart | scalecart_password |
| MongoDB | scalecart | scalecart_password |
| Redis | - | scalecart_password |

---

## Y.4 Development Environment Setup

### Y.4.1 Step-by-Step Installation

```bash
# 1. Clone the repository
git clone https://github.com/scalecart/scalecart.git
cd scalecart

# 2. Set up Python virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt
pip install -r requirements-dev.txt  # Optional: development tools

# 4. Configure environment
cp .env.example .env
# Edit .env to customize settings

# 5. Start services
docker compose up -d

# 6. Initialize database
docker compose exec postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/01-schema.sql
docker compose exec postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/02-indexes.sql

# 7. Run migrations
docker compose exec api alembic upgrade head

# 8. Seed database (optional)
docker compose exec postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/04-seed-data.sql

# 9. Verify installation
curl http://localhost:8000/health

# 10. View logs
docker compose logs -f
```

### Y.4.2 IDE Setup (VS Code)

```bash
# Install recommended extensions
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.black-formatter
code --install-extension ms-python.isort
code --install-extension ms-azuretools.vscode-docker
code --install-extension cweijan.vscode-mysql-client2

# Create .vscode/settings.json
cat > .vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.mypyEnabled": true,
    "python.formatting.provider": "black",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    },
    "files.watcherExclude": {
        "**/venv/**": true,
        "**/.git/**": true,
        "**/__pycache__/**": true
    }
}
EOF
```

### Y.4.3 Database Clients

```bash
# Install DBeaver (Database GUI)
# macOS:
brew install --cask dbeaver-community

# Ubuntu:
sudo snap install dbeaver-ce

# Windows:
# Download from https://dbeaver.io/download/

# Connection details:
# PostgreSQL: localhost:5432, scalecart/scalecart_password
# MongoDB: localhost:27017, scalecart/scalecart_password
# Redis: localhost:6379, scalecart_password
# Neo4j: localhost:7687, neo4j/scalecart_neo4j_password
```

---

## Y.5 Production Environment Setup

### Y.5.1 Server Preparation

```bash
#!/bin/bash
# Server setup script

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Install AWS CLI (for S3 backups)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Create directories
mkdir -p /app /data /backups /logs
cd /app

# Clone application
git clone https://github.com/scalecart/scalecart.git .
```

### Y.5.2 Production Configuration

```bash
# Create production .env file
cat > .env.prod << 'EOF'
# Production Environment Variables

# Database
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
MONGO_PASSWORD=$(openssl rand -base64 32)
NEO4J_PASSWORD=$(openssl rand -base64 32)
TIMESCALE_PASSWORD=$(openssl rand -base64 32)

# Application
APP_ENV=production
DEBUG=false
SECRET_KEY=$(openssl rand -base64 48)
JWT_SECRET_KEY=$(openssl rand -base64 48)
ALLOWED_HOSTS=api.yourdomain.com

# External Services
OPENAI_API_KEY=your_key
STRIPE_SECRET_KEY=your_key
SENTRY_DSN=your_dsn

# AWS (for backups)
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_S3_BUCKET=scalecart-backups

# Logging
LOG_LEVEL=INFO
EOF
```

### Y.5.3 Deploy Production

```bash
# Start production environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.prod up -d

# Check services
docker compose ps

# Health check
curl http://localhost:8000/health

# View logs
docker compose logs -f

# Scale API service (if needed)
docker compose up -d --scale api=3
```

### Y.5.4 SSL/TLS Configuration

```bash
# Install Certbot
sudo apt install certbot -y

# Obtain certificate
sudo certbot certonly --standalone -d api.yourdomain.com

# Configure Nginx (or use Docker with Let's Encrypt)
# See docker-compose.prod.yml for SSL configuration
```

---

## Y.6 Cloud Deployment

### Y.6.1 AWS Deployment

```bash
# Install AWS CLI
brew install awscli  # macOS
# or
sudo apt install awscli  # Ubuntu

# Configure AWS
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Output (json)

# Create ECR repository
aws ecr create-repository --repository-name scalecart-api

# Build and push image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker build -t scalecart-api .
docker tag scalecart-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/scalecart-api:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/scalecart-api:latest

# Deploy using ECS (see Appendix P for full configuration)
aws ecs create-cluster --cluster-name scalecart-prod
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json
aws ecs create-service --cluster scalecart-prod --service-name scalecart-api --task-definition scalecart-api --desired-count 3
```

### Y.6.2 GCP Deployment

```bash
# Install gcloud CLI
brew install google-cloud-sdk  # macOS
# or
sudo apt install google-cloud-sdk  # Ubuntu

# Authenticate
gcloud auth login
gcloud config set project scalecart-prod

# Enable services
gcloud services enable compute.googleapis.com container.googleapis.com sqladmin.googleapis.com

# Create GKE cluster
gcloud container clusters create scalecart-cluster \
  --zone us-central1-a \
  --machine-type n2-standard-4 \
  --num-nodes 3

# Deploy using kubectl
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/postgres-statefulset.yaml
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/api-service.yaml
kubectl apply -f k8s/ingress.yaml
```

### Y.6.3 Azure Deployment

```bash
# Install Azure CLI
brew install azure-cli  # macOS
# or
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash  # Ubuntu

# Login
az login

# Create resource group
az group create --name scalecart-prod --location eastus

# Create AKS cluster
az aks create \
  --resource-group scalecart-prod \
  --name scalecart-cluster \
  --node-count 3 \
  --enable-addons monitoring \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group scalecart-prod --name scalecart-cluster

# Deploy using kubectl
kubectl apply -f k8s/
```

---

## Y.7 Troubleshooting Guide

### Y.7.1 Common Issues

#### Issue: Docker Not Starting

```bash
# Check Docker status
sudo systemctl status docker  # Linux
docker info  # All platforms

# Start Docker
sudo systemctl start docker  # Linux
open /Applications/Docker.app  # macOS
# Start Docker Desktop  # Windows

# Check logs
sudo journalctl -u docker  # Linux
```

#### Issue: Port Already in Use

```bash
# Find process using port
sudo lsof -i :5432  # Linux/macOS
netstat -ano | findstr :5432  # Windows

# Change port in .env
POSTGRES_PORT=5433

# Or kill the process
sudo kill -9 <PID>  # Linux/macOS
taskkill /PID <PID> /F  # Windows
```

#### Issue: Database Connection Refused

```bash
# Check PostgreSQL is running
docker compose ps postgres

# Check logs
docker compose logs postgres

# Check connection settings
docker compose exec postgres psql -U scalecart -c "SHOW listen_addresses;"
docker compose exec postgres psql -U scalecart -c "SHOW port;"

# Restart PostgreSQL
docker compose restart postgres
```

#### Issue: Migration Fails

```bash
# Check current version
docker compose exec api alembic current

# Check migration history
docker compose exec api alembic history

# Reset to base (dangerous!)
docker compose exec api alembic stamp base
docker compose exec api alembic upgrade head

# Or rollback
docker compose exec api alembic downgrade -1
```

#### Issue: API Not Responding

```bash
# Check API container
docker compose ps api

# Check API logs
docker compose logs api

# Check if port is mapped
docker compose port api 8000

# Test from inside container
docker compose exec api curl http://localhost:8000/health

# Restart API
docker compose restart api
```

#### Issue: Redis Connection Failed

```bash
# Check Redis is running
docker compose ps redis

# Check Redis logs
docker compose logs redis

# Test Redis
docker compose exec redis redis-cli -a scalecart_password ping

# Check Redis config
docker compose exec redis redis-cli -a scalecart_password CONFIG GET requirepass
```

#### Issue: MongoDB Connection Failed

```bash
# Check MongoDB is running
docker compose ps mongodb

# Check MongoDB logs
docker compose logs mongodb

# Test MongoDB
docker compose exec mongodb mongosh -u scalecart -p scalecart_password --authenticationDatabase admin --eval "db.runCommand({ping:1})"
```

### Y.7.2 Diagnostic Script

```bash
#!/bin/bash
# diagnostics.sh
echo "🔍 ScaleCart Diagnostic Report"
echo "================================"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -n "1. Docker Status: "
if docker info &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "2. Docker Compose: "
if docker compose version &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "3. Services Running: "
if docker compose ps --quiet &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "4. PostgreSQL: "
if docker compose exec -T postgres pg_isready -U scalecart &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "5. Redis: "
if docker compose exec -T redis redis-cli -a scalecart_password ping &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "6. MongoDB: "
if docker compose exec -T mongodb mongosh -u scalecart -p scalecart_password --authenticationDatabase admin --eval "db.runCommand({ping:1})" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "7. Neo4j: "
if docker compose exec -T neo4j cypher-shell -u neo4j -p scalecart_neo4j_password "RETURN 1" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "8. API Health: "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health | grep -q 200; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "9. Database Tables: "
if docker compose exec -T postgres psql -U scalecart -d scalecart -c "SELECT COUNT(*) FROM products;" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo -n "10. API Response: "
if curl -s http://localhost:8000/api/v1/products | grep -q '"data"'; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
fi

echo ""
echo "================================"
echo "Disk Usage:"
df -h | grep -E "Filesystem|/dev/"
echo ""
echo "Memory Usage:"
free -h
echo ""
echo "Container Stats:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPct}}\t{{.MemUsage}}"
echo ""
```

### Y.7.3 Recovery Commands

```bash
# Full reset
docker compose down -v
docker compose up -d
sleep 10
make db-init
make db-seed
make db-migrate

# Restart all services
docker compose restart

# Rebuild and restart
docker compose up -d --build

# View logs
docker compose logs -f

# Export logs
docker compose logs > logs.txt
```

---

## Y.8 Post-Installation Checklist

```markdown
# Post-Installation Checklist

## Services
- [ ] All Docker containers running (`docker compose ps`)
- [ ] PostgreSQL accepting connections (`make psql`)
- [ ] Redis responding (`make redis`)
- [ ] MongoDB responding (`make mongo`)
- [ ] Neo4j responding (`make neo4j`)

## Database
- [ ] Schema created (`docker compose exec postgres psql -U scalecart -d scalecart -c "\dt"`)
- [ ] Migrations applied (`docker compose exec api alembic current`)
- [ ] Sample data available (`docker compose exec postgres psql -U scalecart -d scalecart -c "SELECT COUNT(*) FROM products;"`)

## API
- [ ] API responding (`curl http://localhost:8000/health`)
- [ ] API documentation accessible (`open http://localhost:8000/docs`)
- [ ] Products endpoint working (`curl http://localhost:8000/api/v1/products`)
- [ ] Authentication working (`curl -X POST http://localhost:8000/api/v1/auth/login`)

## Monitoring
- [ ] Grafana accessible (`open http://localhost:3000`)
- [ ] Prometheus accessible (`open http://localhost:9090`)
- [ ] Neo4j browser accessible (`open http://localhost:7474`)

## Security
- [ ] Environment variables set
- [ ] Default passwords changed
- [ ] Firewall configured
- [ ] SSL/TLS configured (production)

## Backup
- [ ] Backup script tested
- [ ] Backup schedule configured
- [ ] S3/cloud backup configured

## Documentation
- [ ] README updated
- [ ] API documentation deployed
- [ ] Runbooks prepared
- [ ] Team trained
```

---

## Y.9 Quick Reference

### Y.9.1 One-Line Commands

```bash
# Start all services
make up

# Stop all services
make down

# View logs
make logs

# Run tests
make test

# Format code
make format

# Lint code
make lint

# Connect to database
make psql

# Connect to Redis
make redis

# Connect to MongoDB
make mongo

# Connect to Neo4j
make neo4j

# Open API docs
open http://localhost:8000/docs

# Open Grafana
open http://localhost:3000
```

### Y.9.2 Service URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| API | http://localhost:8000 | - |
| API Docs | http://localhost:8000/docs | - |
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | - |
| Neo4j | http://localhost:7474 | neo4j/scalecart_neo4j_password |

---

**[END OF APPENDIX Y]**

*This comprehensive installation guide provides everything needed to get ScaleCart running on any platform. Use it to set up development, staging, or production environments quickly and reliably.*
