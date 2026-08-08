# Primer 10: Development Tools & Workflow

## Essential Development Tools and Workflow Knowledge for the Masterclass

Welcome to **Primer 10** of the Django REST Framework & Next.js 16 masterclass. This primer provides a comprehensive overview of the development tools and workflow patterns used throughout the series.

---

## Section 1: Code Editors & IDEs

### 1.1 VS Code (Recommended)

**Installation:**
```bash
# macOS
brew install --cask visual-studio-code

# Ubuntu/Debian
sudo snap install --classic code

# Windows
# Download from https://code.visualstudio.com/
```

**Essential Extensions:**

```bash
# Install via command line
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.black-formatter
code --install-extension ms-python.flake8
code --install-extension bradlc.vscode-tailwindcss
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension eamodio.gitlens
code --install-extension ms-azuretools.vscode-docker
code --install-extension cweijan.vscode-postgresql-client2
code --install-extension redhat.vscode-yaml
```

**User Settings (settings.json):**
```json
{
    // Editor
    "editor.fontSize": 14,
    "editor.tabSize": 2,
    "editor.formatOnSave": true,
    "editor.renderWhitespace": "all",
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "explicit"
    },
    
    // Python
    "python.defaultInterpreterPath": "${workspaceFolder}/backend/venv/bin/python",
    "python.terminal.activateEnvironment": true,
    "python.linting.enabled": true,
    "python.linting.flake8Enabled": true,
    "python.linting.flake8Args": ["--max-line-length=120"],
    "python.formatting.provider": "black",
    "python.formatting.blackArgs": ["--line-length=120"],
    "python.testing.pytestEnabled": true,
    
    // JavaScript/TypeScript
    "typescript.preferences.importModuleSpecifier": "relative",
    "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
    "prettier.singleQuote": true,
    "prettier.trailingComma": "es5",
    "prettier.printWidth": 100,
    
    // Tailwind
    "tailwindCSS.experimental.classRegex": [
        ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
        ["cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
    ],
    
    // File handling
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

### 1.2 Other IDEs

| IDE | Best For | Pros | Cons |
|-----|----------|------|------|
| **PyCharm** | Python/Django development | Powerful Python features | Heavy, paid |
| **WebStorm** | JavaScript/React development | Great JS/TS support | Paid |
| **Vim/Neovim** | Terminal lovers | Fast, customizable | Steep learning curve |
| **Sublime Text** | Lightweight editing | Fast, simple | Limited features |

---

## Section 2: Terminal & Shell

### 2.1 Recommended Terminal Setup

**macOS (iTerm2 + Oh My Zsh):**
```bash
# Install iTerm2
brew install --cask iterm2

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Add to ~/.zshrc
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

**Useful Aliases:**
```bash
# ~/.bashrc or ~/.zshrc
alias ll="ls -la"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias gm="git merge"
alias dcu="docker-compose up -d"
alias dcd="docker-compose down"
alias dcl="docker-compose logs -f"
```

### 2.2 VS Code Integrated Terminal

```json
// settings.json
{
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.cursorStyle": "line",
    "terminal.integrated.enableMultiLinePasteWarning": false,
    "terminal.integrated.profiles.windows": {
        "PowerShell": {
            "source": "PowerShell",
            "icon": "terminal-powershell"
        },
        "Command Prompt": {
            "path": ["${env:windir}\\Sysnative\\cmd.exe", "${env:windir}\\System32\\cmd.exe"],
            "args": [],
            "icon": "terminal-cmd"
        },
        "Git Bash": {
            "source": "Git Bash"
        }
    }
}
```

---

## Section 3: Version Control Workflows

### 3.1 Feature Branch Workflow

```bash
# Start a new feature
git checkout main
git pull origin main
git checkout -b feature/user-authentication

# Work on feature
git add .
git commit -m "feat(auth): Add login form"
git commit -m "feat(auth): Implement JWT authentication"

# Push and create PR
git push -u origin feature/user-authentication

# After PR approval
git checkout main
git pull origin main
git merge --no-ff feature/user-authentication
git push origin main
git branch -d feature/user-authentication
```

### 3.2 Commit Message Conventions

```bash
# Format
<type>(<scope>): <subject>

# Types
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Code style changes
refactor: Code refactoring
perf:     Performance improvements
test:     Adding/updating tests
chore:    Maintenance tasks
ci:       CI/CD changes

# Examples
feat(auth): Add JWT authentication
fix(api): Fix task creation validation
docs(readme): Update installation instructions
refactor(serializers): Optimize task list serializer
perf(queries): Add database indexes
test(tasks): Add unit tests for task model
ci(github): Update CI workflow for Python 3.12
```

### 3.3 .gitignore Template

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Django
*.log
*.pot
*.pyc
local_settings.py
db.sqlite3
db.sqlite3-journal
media/
staticfiles/
coverage/
htmlcov/

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*
.next/
out/
dist/
.vercel

# Environment
.env
.env.local
.env.*.local
*.secret

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Docker
*.pid
docker-compose.override.yml
.dockerignore

# Testing
.coverage
.pytest_cache/
.tox/
.mypy_cache/
.ruff_cache/
.cypress/
cypress/videos/
cypress/screenshots/

# Other
*.log
*.bak
*.tmp
```

---

## Section 4: Package Managers

### 4.1 Python (pip)

```bash
# Install package
pip install package_name

# Install specific version
pip install package_name==1.2.3

# Install from requirements file
pip install -r requirements.txt

# Generate requirements file
pip freeze > requirements.txt

# Upgrade package
pip install --upgrade package_name

# Uninstall package
pip uninstall package_name

# List installed packages
pip list

# Show package info
pip show package_name

# Search for package
pip search package_name
```

### 4.2 Node.js (npm)

```bash
# Install package
npm install package_name

# Install as dev dependency
npm install --save-dev package_name

# Install globally
npm install -g package_name

# Install from package.json
npm install

# Update package
npm update package_name

# Uninstall package
npm uninstall package_name

# List installed packages
npm list

# List globally installed packages
npm list -g --depth=0

# Check for outdated packages
npm outdated
```

---

## Section 5: Development Workflows

### 5.1 Full Stack Development Workflow

```bash
# Terminal 1: Backend
cd backend
source venv/bin/activate
python manage.py runserver

# Terminal 2: Frontend
cd frontend
npm run dev

# Terminal 3: Docker services (if needed)
docker-compose up -d db redis

# Terminal 4: Git
git add .
git commit -m "feat: Add new feature"
git push origin feature/your-feature
```

### 5.2 Database Workflow

```bash
# Run migrations
python manage.py makemigrations
python manage.py migrate

# Reset database (development)
python manage.py reset_db  # django-extensions
python manage.py migrate

# Load fixtures
python manage.py loaddata fixtures/initial_data.json

# Dump data
python manage.py dumpdata > fixtures/data.json

# Export database
pg_dump -U user -h host dbname > backup.sql

# Import database
psql -U user -h host dbname < backup.sql
```

### 5.3 Testing Workflow

```bash
# Backend tests
pytest
pytest -v
pytest --cov=apps
pytest tests/test_views/

# Frontend unit tests
npm test
npm test -- --watch
npm test -- --coverage

# Frontend E2E tests
npx playwright test
npx playwright test --ui
npx playwright test auth.spec.ts
```

---

## Section 6: Debugging Workflow

### 6.1 Backend Debugging

```python
# 1. Print statements
print(f"Variable: {variable}")
print("DEBUG: User is", user)

# 2. Logging
import logging
logger = logging.getLogger(__name__)
logger.info("User logged in: %s", user.email)

# 3. PDB
import pdb; pdb.set_trace()
breakpoint()  # Python 3.7+

# 4. Django Debug Toolbar
# Add to settings, use in browser

# 5. Django Shell
python manage.py shell
from apps.tasks.models import Task
task = Task.objects.get(id=1)
```

### 6.2 Frontend Debugging

```javascript
// 1. Console logging
console.log('Value:', value)
console.debug('Debug:', data)
console.warn('Warning:', error)
console.error('Error:', error)

// 2. React DevTools
// Install browser extension
// Inspect component tree, props, state

// 3. Network tab
// Check API requests/responses
// Check status codes, headers, payloads

// 4. React Query DevTools
// Install @tanstack/react-query-devtools
// Monitor queries, mutations, cache

// 5. VS Code Debugging
// Use launch.json configuration
```

---

## Section 7: Performance Monitoring

### 7.1 Backend Monitoring

```python
# Query count
from django.db import connection
print(f"Queries: {len(connection.queries)}")

# Query time
import time
start = time.time()
result = expensive_operation()
duration = time.time() - start
print(f"Duration: {duration:.3f}s")

# Memory usage
import psutil
process = psutil.Process()
print(f"Memory: {process.memory_info().rss / 1024 / 1024:.1f}MB")
```

### 7.2 Frontend Monitoring

```javascript
// Performance timing
console.time('Operation')
expensiveOperation()
console.timeEnd('Operation')

// Core Web Vitals
import { onCLS, onFID, onLCP } from 'web-vitals'
onCLS(console.log)
onFID(console.log)
onLCP(console.log)

// React DevTools Profiler
// Record and analyze component render times
```

---

## Section 8: Troubleshooting

### 8.1 Common Issues

**Backend:**
```bash
# "Module not found"
# Check import paths, PYTHONPATH

# "Database connection failed"
# Check DATABASE_URL, service running

# "Permission denied"
# Check file permissions, user roles
```

**Frontend:**
```bash
# "Module not found"
# Check import paths, install dependencies

# "CORS error"
# Check backend CORS configuration

# "Hydration failed"
# Check client/server mismatch
```

**Docker:**
```bash
# "Port already in use"
# Find and kill process using port

# "No space left on device"
# docker system prune -a

# "Permission denied"
# Add user to docker group
```

### 8.2 Quick Fix Commands

```bash
# Clear Python cache
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find . -type f -name "*.pyc" -delete

# Clear npm cache
npm cache clean --force

# Rebuild container
docker-compose build --no-cache
docker-compose up -d

# Reset git
git clean -fd
git reset --hard HEAD

# Reset database
python manage.py reset_db  # django-extensions
python manage.py migrate
```

---

## Quick Reference Cards

### VS Code Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + Shift + P` | Command Palette |
| `Cmd/Ctrl + P` | Quick Open |
| `Cmd/Ctrl + Shift + E` | Explorer |
| `Cmd/Ctrl + Shift + F` | Search |
| `Cmd/Ctrl + ` ` | Terminal |
| `Cmd/Ctrl + Shift + D` | Debug |
| `Cmd/Ctrl + Shift + X` | Extensions |
| `Alt + Up/Down` | Move line |
| `Cmd/Ctrl + D` | Select next occurrence |
| `Cmd/Ctrl + /` | Toggle comment |

### Terminal Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl + C` | Kill process |
| `Ctrl + Z` | Suspend process |
| `Ctrl + L` | Clear screen |
| `Ctrl + A` | Move to line start |
| `Ctrl + E` | Move to line end |
| `Ctrl + U` | Delete from cursor to start |
| `Ctrl + K` | Delete from cursor to end |
| `Tab` | Autocomplete |
| `↑/↓` | Command history |

### Git Shortcuts

| Shortcut | Action |
|----------|--------|
| `git st` | Status |
| `git co` | Checkout |
| `git br` | Branch |
| `git ci` | Commit |
| `git lg` | Log graph |
| `git unstage` | Unstage file |
| `git last` | Last commit |

---

*This concludes Primer 10. You now have the essential development tools and workflow knowledge needed for the masterclass.*
