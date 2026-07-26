# PRIMER 3: Command Line and Terminal Basics

## Welcome to the Command Line Primer!

The terminal (also called command line or shell) is where you'll run your Node.js applications, install packages, and manage your projects. If you've never used the terminal before, this primer will get you comfortable with all the essential commands you'll need.

### What This Primer Covers

| Section | Topic | What You'll Learn |
|---------|-------|-------------------|
| 1 | What Is the Terminal? | Understanding the command line |
| 2 | Navigation Commands | `cd`, `ls`, `pwd` - moving around |
| 3 | File Management | `touch`, `mkdir`, `rm`, `cp`, `mv` |
| 4 | Node.js Commands | `node`, `npm`, `npx` |
| 5 | Process Management | Starting, stopping, background processes |
| 6 | Environment Variables | Setting and using environment variables |
| 7 | Common Workflows | Typical development tasks |
| 8 | Tips and Shortcuts | Making your terminal workflow faster |

---

## Section 1: What Is the Terminal?

The **terminal** (or **command line interface**) is a text-based way to interact with your computer. Instead of clicking on icons and menus, you type commands.

### Opening the Terminal

| Operating System | How to Open |
|------------------|-------------|
| **Windows** | Search for "Command Prompt" or "PowerShell" (or use Windows Terminal) |
| **macOS** | Search for "Terminal" in Spotlight (Cmd+Space) |
| **Linux** | Usually Ctrl+Alt+T or search for "Terminal" |

### Terminal Anatomy

```
┌─────────────────────────────────────────────────────────────┐
│ username@computer-name:~$ _                                 │
│ └─────┘ └──────┘ └─┘ └─┘ └─┘                               │
│   User    Computer   │   │   │                              │
│   name      name     │   │   └── Prompt character          │
│                       │   │      (cursor location)         │
│                       │   └── Current directory            │
│                       │      (~ = home directory)          │
│                       └── Command prompt                   │
└─────────────────────────────────────────────────────────────┘
```

### Your First Command

```bash
# Print a message to the terminal
echo "Hello, Terminal!"

# Output: Hello, Terminal!
```

---

## Section 2: Navigation Commands

### Where Am I?

```bash
# Print working directory (where you are right now)
pwd
# Output: /Users/yourname/projects

# On Windows (Command Prompt)
cd
# Output: C:\Users\yourname\projects
```

### Listing Files and Directories

```bash
# List files and directories in the current folder
ls

# List with details (permissions, size, date)
ls -l

# List all files (including hidden files)
ls -a

# List with human-readable sizes
ls -lh

# Sort by date (newest first)
ls -lt

# On Windows (Command Prompt)
dir
dir /w  # Wide format
```

### Changing Directories

```bash
# Go to a specific directory
cd Documents/projects

# Go to your home directory
cd ~
cd ~/Documents

# Go up one directory level
cd ..

# Go up two levels
cd ../..

# Go to the previous directory
cd -

# On Windows
cd "C:\Users\YourName\Documents"
```

### Creating Directories

```bash
# Create a new directory
mkdir my-project

# Create nested directories
mkdir -p projects/my-app/src
# Creates: projects/ → projects/my-app/ → projects/my-app/src/

# On Windows
mkdir my-project
mkdir projects\my-app\src
```

---

## Section 3: File Management

### Creating Files

```bash
# Create an empty file
touch server.js

# Create multiple files
touch index.js package.json README.md

# Create a file with content
echo "console.log('Hello World');" > hello.js

# Append to a file
echo "console.log('Goodbye');" >> hello.js

# On Windows
echo. > server.js
echo console.log('Hello World'); > hello.js
```

### Viewing Files

```bash
# View file content in terminal
cat server.js

# View with line numbers
cat -n server.js

# View a file page by page (press space to scroll, q to quit)
less server.js

# View first 10 lines
head server.js

# View last 10 lines
tail server.js

# Follow a file as it grows (great for logs)
tail -f logs/app.log
```

### Copying Files and Directories

```bash
# Copy a file
cp server.js server-backup.js

# Copy a file to a directory
cp server.js src/backup/

# Copy a directory recursively
cp -r src/ src-backup/

# Copy with prompt before overwriting
cp -i server.js backup/

# On Windows
copy server.js server-backup.js
xcopy src src-backup /E
```

### Moving and Renaming

```bash
# Move a file (renames it if in same directory)
mv server.js index.js

# Move a file to a directory
mv index.js src/

# Move a directory
mv src-backup/ archive/

# Rename a directory
mv old-name/ new-name/
```

### Deleting Files and Directories

```bash
# Delete a file (⚠️ Cannot be undone!)
rm server.js

# Delete with confirmation prompt
rm -i server.js

# Delete a directory recursively (⚠️ Dangerous!)
rm -rf my-project/

# Delete empty directory
rmdir empty-folder/

# On Windows
del server.js
rmdir /s my-project
```

### Wildcards

```bash
# * matches any characters
rm *.log          # Delete all .log files
ls *.js           # List all .js files
cp *.txt backup/  # Copy all .txt files

# ? matches exactly one character
ls file?.txt      # Matches file1.txt, fileA.txt, etc.

# [] matches a range
ls file[1-3].txt  # Matches file1.txt, file2.txt, file3.txt
```

---

## Section 4: Node.js Commands

### Node.js Commands

```bash
# Check if Node.js is installed
node -v
# Output: v18.17.0

# Run a JavaScript file
node server.js

# Run with a specific module
node --require dotenv/config server.js

# Start Node.js REPL (interactive mode)
node
> console.log('Hello')
Hello
> .exit

# Run a script from package.json
npm start
npm run dev

# Run a script without installing (npx)
npx nodemon server.js
```

### npm Commands

```bash
# Check npm version
npm -v

# Initialize a new project
npm init
npm init -y  # Use defaults

# Install dependencies
npm install express
npm install express --save

# Install development dependencies
npm install nodemon --save-dev

# Install all dependencies from package.json
npm install

# Install globally
npm install -g nodemon

# List installed packages
npm list
npm list --depth=0  # Only top-level

# Update packages
npm update
npm update express

# Uninstall packages
npm uninstall express

# Check for outdated packages
npm outdated

# Run tests
npm test
```

### Common package.json Scripts

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest",
    "lint": "eslint .",
    "format": "prettier --write .",
    "build": "webpack --mode production",
    "migrate": "knex migrate:latest",
    "seed": "knex seed:run"
  }
}
```

```bash
# Run scripts
npm start          # npm run start
npm run dev        # npm run dev (must use 'run' for non-standard names)
npm run test
```

---

## Section 5: Process Management

### Starting and Stopping Processes

```bash
# Run a process in the foreground
node server.js
# Press Ctrl+C to stop

# Run a process in the background (add &)
node server.js &

# List running processes
ps aux | grep node
ps aux | grep node | grep -v grep

# Kill a process by PID
kill 12345
kill -9 12345  # Force kill

# On Windows (Task List)
tasklist | findstr node
taskkill /PID 12345 /F
```

### Using PM2 (Process Manager)

```bash
# Install PM2 globally
npm install -g pm2

# Start your app with PM2
pm2 start server.js --name my-app

# List running processes
pm2 list

# Stop a process
pm2 stop my-app

# Restart a process
pm2 restart my-app

# Reload (zero downtime)
pm2 reload my-app

# Delete a process
pm2 delete my-app

# View logs
pm2 logs
pm2 logs my-app

# Save the current process list
pm2 save

# Start saved processes on system boot
pm2 startup
```

### Using Nodemon (Development)

```bash
# Install nodemon
npm install -g nodemon

# Run with nodemon (auto-restarts on file changes)
nodemon server.js

# Run with nodemon and watch specific files
nodemon --watch src --ext js,json server.js

# Using nodemon with npm scripts
# In package.json:
{
  "scripts": {
    "dev": "nodemon server.js"
  }
}
```

---

## Section 6: Environment Variables

### Setting Environment Variables

```bash
# Set a variable for the current command
PORT=3000 node server.js

# Set multiple variables
PORT=3000 NODE_ENV=development node server.js

# Set a variable for the current session
export PORT=3000
export NODE_ENV=development

# On Windows (Command Prompt)
set PORT=3000
set NODE_ENV=development

# On Windows (PowerShell)
$env:PORT=3000
$env:NODE_ENV="development"
```

### Using Environment Variables in Node.js

```javascript
// Access environment variables
const port = process.env.PORT || 3000;
const nodeEnv = process.env.NODE_ENV || 'development';
const apiKey = process.env.API_KEY;

console.log(`Running on port ${port}`);
console.log(`Environment: ${nodeEnv}`);

// Using dotenv (for .env files)
require('dotenv').config();

console.log(process.env.DB_HOST);
console.log(process.env.DB_PASSWORD);
```

### .env File

```bash
# .env file
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=secret123
JWT_SECRET=super-secret-key
```

```bash
# .env.example (commit this, not .env)
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=your-db-password
JWT_SECRET=your-jwt-secret
```

---

## Section 7: Common Workflows

### Setting Up a New Project

```bash
# 1. Create project directory
mkdir my-express-app
cd my-express-app

# 2. Initialize npm
npm init -y

# 3. Install dependencies
npm install express
npm install dotenv

# 4. Install development dependencies
npm install nodemon --save-dev

# 5. Create project structure
mkdir src
mkdir src/routes
mkdir src/controllers
mkdir src/models
mkdir src/middleware

# 6. Create main files
touch server.js
touch .env
touch .gitignore

# 7. Add to .gitignore
echo "node_modules/" >> .gitignore
echo ".env" >> .gitignore

# 8. Initialize git
git init
git add .
git commit -m "Initial commit"
```

### Development Workflow

```bash
# 1. Start development server
npm run dev
# or
nodemon server.js

# 2. Make changes to code (server auto-restarts)

# 3. Run tests
npm test

# 4. Commit changes
git add .
git commit -m "Add new feature"

# 5. Push to remote
git push origin main
```

### Debugging

```bash
# Run with debugging enabled
node --inspect server.js

# Run with debugging and break on first line
node --inspect-brk server.js

# Run with debugging in Chrome DevTools
node --inspect --inspect-brk server.js

# Using nodemon with debugging
nodemon --inspect server.js
```

### Checking Port Usage

```bash
# Check what's using port 3000
lsof -i :3000
# Output: Shows PID and process name

# Kill process using port 3000
kill -9 $(lsof -t -i :3000)

# On Windows
netstat -ano | findstr :3000
taskkill /PID 12345 /F
```

---

## Section 8: Tips and Shortcuts

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Stop the current process |
| `Ctrl+Z` | Suspend the current process |
| `Ctrl+D` | Exit the terminal |
| `Ctrl+L` | Clear the screen |
| `Tab` | Auto-complete command/filename |
| `Up Arrow` | Previous command |
| `Down Arrow` | Next command |
| `Ctrl+R` | Search command history |
| `Ctrl+A` | Go to start of line |
| `Ctrl+E` | Go to end of line |
| `Ctrl+U` | Clear from cursor to start |
| `Ctrl+K` | Clear from cursor to end |
| `Ctrl+W` | Delete word before cursor |
| `!!` | Repeat last command |
| `!$` | Last argument of previous command |

### Aliases

```bash
# Create an alias (temporary)
alias gs='git status'
alias gcm='git commit -m'
alias serve='node server.js'

# Make aliases permanent (add to ~/.bashrc or ~/.zshrc)
echo 'alias gs="git status"' >> ~/.bashrc
echo 'alias gcm="git commit -m"' >> ~/.bashrc
source ~/.bashrc

# On Windows (PowerShell)
Set-Alias gs git status
Set-Alias serve node server.js
```

### Common Aliases for Node.js Development

```bash
# Add these to your ~/.bashrc or ~/.zshrc
alias ns='npm start'
alias nd='npm run dev'
alias ni='npm install'
alias nig='npm install -g'
alias nid='npm install --save-dev'
alias nu='npm update'
alias nr='npm run'
alias npx='npx'

# Git aliases
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph'
alias gb='git branch'
alias gco='git checkout'
```

### Pipe and Redirect

```bash
# Pipe (|) - Send output of one command to another
ls -la | grep server.js
cat server.js | grep "console.log"

# Redirect (>) - Save output to a file
ls -la > files.txt
echo "Hello" > greeting.txt

# Append (>>) - Add to the end of a file
echo "World" >> greeting.txt

# Redirect error (2>)
node server.js 2> error.log

# Redirect both output and error (&>)
node server.js &> output.log
```

### Searching

```bash
# Search for text in files
grep "express" server.js
grep -r "express" ./src/
grep -i "express" server.js  # Case-insensitive

# Search and replace
sed -i 's/old-text/new-text/g' server.js

# Find files
find . -name "*.js"
find . -name "server.js"
find . -type d -name "src"
```

---

## Practice Exercises

### Exercise 1: Project Setup

```bash
# Complete the following tasks using terminal commands:
# 1. Create a directory called "my-api"
# 2. Navigate into it
# 3. Initialize a new npm project
# 4. Install express and dotenv
# 5. Create a server.js file
# 6. Write "console.log('Server starting...')" to server.js
# 7. Run server.js with node

# Your commands here:
```

### Exercise 2: File Management

```bash
# Complete the following tasks:
# 1. Create the following directory structure:
#    my-app/
#    ├── src/
#    │   ├── routes/
#    │   ├── controllers/
#    │   └── models/
#    └── tests/
# 2. Create a file called index.js in the root
# 3. Copy index.js to src/routes/
# 4. Rename the copy to routes.js
# 5. Delete the original index.js
# 6. List all files in the src directory recursively

# Your commands here:
```

### Exercise 3: Environment Variables

```bash
# Complete the following tasks:
# 1. Create a .env file with:
#    - PORT=4000
#    - NODE_ENV=development
#    - API_KEY=test-key-123
# 2. Create a script that reads these variables
# 3. Run the script with the environment variables

# Your commands here:
```

### Exercise 4: Process Management

```bash
# Complete the following tasks:
# 1. Start a Node.js process in the background
# 2. List all running Node.js processes
# 3. Find the PID of your Node.js process
# 4. Send a SIGTERM signal to gracefully stop it
# 5. Verify it's stopped

# Your commands here:
```

---

## Summary

You now know the essential terminal commands for Node.js development:

| Category | Key Commands |
|----------|--------------|
| **Navigation** | `cd`, `ls`, `pwd` |
| **Files** | `touch`, `mkdir`, `rm`, `cp`, `mv` |
| **Node.js** | `node`, `npm`, `npx` |
| **Processes** | `Ctrl+C`, `ps`, `kill` |
| **Environment** | `export`, `set`, `.env` |
| **Search** | `grep`, `find` |
