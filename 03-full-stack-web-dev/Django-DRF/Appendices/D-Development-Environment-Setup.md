# Appendix D: Development Environment Setup

## Complete Guide to Setting Up Your Development Environment

Welcome to **Appendix D** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive guide to setting up your local development environment, including all tools, configurations, and extensions needed to follow the masterclass effectively.

---

## Section 1: System Requirements

### Minimum Specifications

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 8 GB | 16+ GB |
| **Storage** | 20 GB free | 50+ GB free |
| **OS** | macOS, Linux, Windows 10+ | macOS/Linux |
| **Internet** | Broadband | High-speed |

### Required Software Versions

| Software | Minimum Version | Recommended Version |
|----------|-----------------|---------------------|
| **Python** | 3.12 | 3.12+ |
| **Node.js** | 20.0 | 20+ LTS |
| **PostgreSQL** | 15 | 16 |
| **Redis** | 7.0 | 7.2+ |
| **Docker** | 24.0 | Latest |
| **Docker Compose** | 2.20 | Latest |
| **Git** | 2.40 | Latest |
| **VS Code** | 1.80 | Latest |

---

## Section 2: Installing Core Tools

### 2.1 Python Installation

**macOS:**
```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python
brew install python@3.12

# Verify installation
python3 --version
```

**Ubuntu/Debian:**
```bash
# Update package list
sudo apt update

# Install Python 3.12
sudo apt install python3.12 python3.12-venv python3.12-dev

# Create alias
sudo ln -s /usr/bin/python3.12 /usr/local/bin/python3

# Verify
python3 --version
```

**Windows:**
```bash
# Download Python installer from python.org
# Run installer and check "Add Python to PATH"

# Verify in PowerShell
python --version
```

### 2.2 Node.js Installation

**All Platforms:**
```bash
# Use nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
source ~/.bashrc

# Install Node.js
nvm install 20
nvm use 20

# Verify
node --version
npm --version
```

### 2.3 PostgreSQL Installation

**macOS:**
```bash
brew install postgresql@16
brew services start postgresql@16

# Create database user
createuser -s postgres
```

**Ubuntu/Debian:**
```bash
# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Switch to postgres user
sudo -i -u postgres

# Create database user
createuser --interactive
```

**Windows:**
```bash
# Download PostgreSQL installer from postgresql.org
# Run installer and follow prompts
# Note: Remember the password you set
```

### 2.4 Redis Installation

**macOS:**
```bash
brew install redis
brew services start redis
```

**Ubuntu/Debian:**
```bash
# Install Redis
sudo apt install redis-server

# Start Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

**Windows:**
```bash
# Use Docker for Windows
docker run -d -p 6379:6379 --name redis redis:alpine
```

### 2.5 Docker Installation

**All Platforms:**
Visit [docker.com](https://docker.com) to download Docker Desktop for:
- macOS
- Windows
- Linux

**Linux (Ubuntu/Debian):**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin

# Verify
docker --version
docker compose version
```

---

## Section 3: IDE Setup (VS Code)

### 3.1 VS Code Installation

**All Platforms:**
Visit [code.visualstudio.com](https://code.visualstudio.com/) to download and install VS Code.

### 3.2 Essential Extensions

**Backend Development:**
```bash
# Install via command line
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.black-formatter
code --install-extension ms-python.flake8
code --install-extension ms-python.isort
code --install-extension kevinrose.vsc-python-indent
code --install-extension njpwerner.autodocstring
code --install-extension littlefoxteam.vscode-python-test-adapter
```

**Frontend Development:**
```bash
# Install via command line
code --install-extension bradlc.vscode-tailwindcss
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension eamodio.gitlens
code --install-extension wix.vscode-import-cost
```

**Database Tools:**
```bash
code --install-extension cweijan.vscode-postgresql-client2
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode-remote.remote-containers
```

**Git:**
```bash
code --install-extension eamodio.gitlens
code --install-extension mhutchie.git-graph
```

**Other Useful Extensions:**
```bash
code --install-extension redhat.vscode-yaml
code --install-extension ms-vscode.makefile-tools
code --install-extension streetsidesoftware.code-spell-checker
code --install-extension oderwat.indent-rainbow
```

### 3.3 VS Code Configuration

**.vscode/settings.json:**
```json
{
    // Python settings
    "python.defaultInterpreterPath": "${workspaceFolder}/backend/venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.terminal.activateEnvInCurrentTerminal": true,
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.flake8Args": [
        "--max-line-length=120"
    ],
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": [
        "--line-length=120"
    ],
    "python.testing.pytestEnabled": true,
    "python.testing.unittestEnabled": false,
    "python.testing.pytestArgs": [
        "tests"
    ],
    
    // JavaScript/TypeScript settings
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "explicit"
    },
    "typescript.preferences.importModuleSpecifier": "relative",
    
    // Tailwind CSS
    "tailwindCSS.experimental.classRegex": [
        ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
        ["cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
    ],
    
    // General settings
    "editor.tabSize": 2,
    "editor.renderWhitespace": "all",
    "files.exclude": {
        "**/__pycache__": true,
        "**/*.pyc": true,
        "**/node_modules": true,
        "**/.next": true,
        "**/dist": true
    },
    "[python]": {
        "editor.tabSize": 4,
        "editor.codeActionsOnSave": {
            "source.organizeImports": "explicit"
        }
    }
}
```

**.vscode/extensions.json:**
```json
{
    "recommendations": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "bradlc.vscode-tailwindcss",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "eamodio.gitlens",
        "cweijan.vscode-postgresql-client2",
        "ms-azuretools.vscode-docker",
        "redhat.vscode-yaml"
    ]
}
```

---

## Section 4: Project Setup Script

### 4.1 Complete Setup Script

**scripts/setup-dev.sh** (create in project root):

```bash
#!/bin/bash

# Master development environment setup script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 TaskFlow Development Environment Setup${NC}"
echo "============================================"
echo ""

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    echo "Please install Python 3.12 or higher"
    exit 1
fi
echo -e "${GREEN}✅ Python: $(python3 --version)${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed${NC}"
    echo "Please install Node.js 20 or higher"
    exit 1
fi
echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Please install Docker Desktop or Docker Engine"
    exit 1
fi
echo -e "${GREEN}✅ Docker: $(docker --version)${NC}"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed${NC}"
    echo "Please install Docker Compose"
    exit 1
fi
echo -e "${GREEN}✅ Docker Compose: $(docker-compose --version)${NC}"

echo ""
echo -e "${YELLOW}🔧 Setting up backend...${NC}"

# Backend setup
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements/development.txt

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cp .env.example .env
fi

# Run migrations
echo "Running database migrations..."
python manage.py migrate

# Create superuser
echo "Creating superuser..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='admin@example.com').exists():
    User.objects.create_superuser(
        email='admin@example.com',
        username='admin',
        password='admin123'
    )
    print('✅ Superuser created: admin@example.com / admin123')
"

cd ..

echo ""
echo -e "${YELLOW}🔧 Setting up frontend...${NC}"

# Frontend setup
cd frontend

# Install dependencies
echo "Installing Node dependencies..."
npm ci

# Create .env.local if it doesn't exist
if [ ! -f ".env.local" ]; then
    echo "Creating .env.local file..."
    cp .env.local.example .env.local
fi

cd ..

echo ""
echo -e "${YELLOW}🐳 Starting Docker services...${NC}"

# Start Docker Compose
docker-compose up -d db redis

echo ""
echo -e "${GREEN}✅ Development environment setup complete!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "  1. Start the backend:"
echo "     cd backend && source venv/bin/activate && python manage.py runserver"
echo ""
echo "  2. Start the frontend:"
echo "     cd frontend && npm run dev"
echo ""
echo "  3. Access the application:"
echo "     Frontend:  http://localhost:3000"
echo "     Backend:   http://localhost:8000"
echo "     Admin:     http://localhost:8000/admin"
echo "     API Docs:  http://localhost:8000/api/docs/"
echo ""
echo "  4. Credentials:"
echo "     Email: admin@example.com"
echo "     Password: admin123"
echo ""
echo -e "${YELLOW}💡 Tip: Use 'docker-compose logs -f' to see service logs${NC}"
```

Make it executable:

```bash
chmod +x scripts/setup-dev.sh
```

---

## Section 5: Common Development Commands

### 5.1 Backend Commands

```bash
# Activate virtual environment
cd backend
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Run development server
python manage.py runserver

# Run with different port
python manage.py runserver 8001

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create a new app
python manage.py startapp app_name apps/app_name

# Create superuser
python manage.py createsuperuser

# Run tests
pytest
pytest -v
pytest --cov=apps

# Run specific test
pytest tests/test_views/test_task_views.py

# Open Django shell
python manage.py shell

# Generate OpenAPI schema
python manage.py spectacular --file schema.yaml

# Clear cache
python manage.py clear_cache

# Warm cache
python manage.py warm_cache
```

### 5.2 Frontend Commands

```bash
# Start development server
cd frontend
npm run dev

# Build for production
npm run build

# Run tests
npm run test
npm run test:watch
npm run test:coverage

# Run linter
npm run lint

# Run TypeScript check
npx tsc --noEmit

# Format code
npx prettier --write .

# Run E2E tests
npx playwright test
npx playwright test --ui

# Update dependencies
npm update
npm outdated
```

### 5.3 Docker Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f
docker-compose logs -f backend
docker-compose logs -f frontend

# Rebuild a service
docker-compose build backend

# Access a container
docker-compose exec backend bash
docker-compose exec db psql -U taskflow_user taskflow_db
docker-compose exec redis redis-cli

# Clear all containers
docker-compose down -v

# Check health
curl http://localhost/health/
```

---

## Section 6: Database Management

### 6.1 PostgreSQL Commands

```bash
# Connect to database
docker-compose exec db psql -U taskflow_user taskflow_db

# Or with local PostgreSQL
psql -U taskflow_user -h localhost taskflow_db

# Common queries:
SELECT * FROM users_user;
SELECT * FROM projects_project;
SELECT * FROM tasks_task;

# Show table schema
\d tasks_task

# Show indexes
\di

# Show database size
SELECT pg_database_size('taskflow_db')/1024/1024 as size_mb;

# Show table sizes
SELECT tablename, pg_table_size(tablename)/1024/1024 as size_mb 
FROM pg_tables WHERE schemaname='public';
```

### 6.2 Redis Commands

```bash
# Connect to Redis
docker-compose exec redis redis-cli

# Common commands:
ping                    # Test connection
info                    # Show server info
monitor                 # Monitor commands

# Keys:
KEYS *                  # List all keys
FLUSHALL                # Clear all keys
GET key_name            # Get a value
SET key_name value      # Set a value
EXPIRE key_name 60      # Set expiration

# Cache management:
SCAN 0                  # Scan keys (production safe)
TTL key_name           # Get remaining TTL
DEL key_name           # Delete a key
```

---

## Section 7: VS Code Debugging Configuration

### 7.1 Django Debug Configuration

**.vscode/launch.json:**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Django Backend",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/backend/manage.py",
            "args": [
                "runserver",
                "0.0.0.0:8000"
            ],
            "django": true,
            "justMyCode": true,
            "env": {
                "DJANGO_SETTINGS_MODULE": "config.settings"
            },
            "cwd": "${workspaceFolder}/backend"
        },
        {
            "name": "Django Test - Current File",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/backend/manage.py",
            "args": [
                "test",
                "${file}"
            ],
            "django": true,
            "cwd": "${workspaceFolder}/backend"
        },
        {
            "name": "Next.js Frontend",
            "type": "node",
            "request": "launch",
            "runtimeExecutable": "npm",
            "runtimeArgs": [
                "run",
                "dev"
            ],
            "cwd": "${workspaceFolder}/frontend",
            "console": "integratedTerminal"
        },
        {
            "name": "Playwright E2E",
            "type": "node",
            "request": "launch",
            "program": "${workspaceFolder}/frontend/node_modules/.bin/playwright",
            "args": [
                "test",
                "${file}"
            ],
            "cwd": "${workspaceFolder}/frontend",
            "console": "integratedTerminal"
        }
    ],
    "compounds": [
        {
            "name": "Full Stack",
            "configurations": ["Django Backend", "Next.js Frontend"]
        }
    ]
}
```

### 7.2 Pre-commit Hooks

**.pre-commit-config.yaml:**
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files

  - repo: https://github.com/psf/black
    rev: 23.9.1
    hooks:
      - id: black
        args: [--line-length=120]

  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
        args: [--max-line-length=120]

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: [--line-length=120]

  - repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.0.3
    hooks:
      - id: prettier
        files: \.(js|ts|jsx|tsx|css|html|json|md)$
```

**Install pre-commit:**
```bash
pip install pre-commit
pre-commit install
```

---

## Section 8: Troubleshooting Common Setup Issues

### 8.1 Python Issues

**Issue: "python: command not found"**
```bash
# On macOS/Linux, create alias
alias python='python3'

# Or add to .bashrc/.zshrc
echo "alias python='python3'" >> ~/.zshrc
source ~/.zshrc
```

**Issue: Virtual environment not activating**
```bash
# macOS/Linux
source venv/bin/activate

# Windows (Command Prompt)
venv\Scripts\activate

# Windows (PowerShell)
venv\Scripts\Activate.ps1
```

### 8.2 Node.js Issues

**Issue: "npm: command not found"**
```bash
# Install nvm and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

**Issue: "Cannot find module"**
```bash
# Clear node modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### 8.3 Docker Issues

**Issue: "Port already in use"**
```bash
# Find process using port
sudo lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 PID  # macOS/Linux
taskkill /PID PID /F  # Windows

# Change port in docker-compose.yml
ports:
  - "8001:8000"
```

**Issue: "Permission denied"**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Or use sudo
sudo docker-compose up
```

### 8.4 Database Issues

**Issue: "FATAL: database does not exist"**
```bash
# Create database
docker-compose exec db psql -U postgres -c "CREATE DATABASE taskflow_db;"

# Or recreate
docker-compose down -v
docker-compose up -d db
```

**Issue: "Connection refused"**
```bash
# Check if database is running
docker-compose ps db

# Check logs
docker-compose logs db

# Wait for database to be ready
sleep 10
docker-compose exec db pg_isready
```

---

## Section 9: Performance Optimization Tips

### 9.1 VS Code Performance

```json
{
    // Disable unnecessary features
    "editor.minimap.enabled": false,
    "editor.renderIndentGuides": false,
    "editor.hideCursorInOverviewRuler": true,
    "workbench.startupEditor": "none",
    "extensions.autoUpdate": false,
    "files.autoSave": "onFocusChange",
    
    // Python language server
    "python.analysis.typeCheckingMode": "basic",
    "python.analysis.indexing": true,
    "python.analysis.autoSearchPaths": false,
    "python.analysis.useLibraryCodeForTypes": false
}
```

### 9.2 Docker Performance

```yaml
# docker-compose.yml performance settings
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
    environment:
      - PYTHONUNBUFFERED=1
      - PYTHONOPTIMIZE=1
      - DEBUG=False

  frontend:
    environment:
      - NODE_OPTIONS="--max-old-space-size=4096"
```

---

*This concludes Appendix D. You now have everything you need to set up a complete development environment for the masterclass.*
