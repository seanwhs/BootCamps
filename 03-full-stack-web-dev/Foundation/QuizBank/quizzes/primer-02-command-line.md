# Primer 2 Quiz — Command-Line Fundamentals  
## Terminals, Shells, Files, Processes, Pipes, Environment Variables, cURL, and Command-Line Safety

This quiz reviews:

- Terminals
- Shells
- Commands
- Options and arguments
- Current working directories
- Relative and absolute paths
- Files and directories
- Reading and searching files
- Pipes and redirection
- Standard input, output, and errors
- Exit codes
- Processes
- Ports
- Environment variables
- cURL
- Shell scripts
- Command-line safety

---

## Instructions

- Complete the quiz before reading the answer key.
- Explain your reasoning for short-answer and scenario questions.
- Use only a safe practice directory for practical exercises.
- Do not run destructive commands on important files or systems.
- Do not use real production credentials in command examples.
- Command syntax may vary slightly between Bash, Zsh, Fish, PowerShell, and Command Prompt.

---

## Learning Objectives

After completing this quiz, you should be able to:

- Explain the difference between a terminal and a shell.
- Understand basic command syntax.
- Identify commands, options, and arguments.
- Navigate directories.
- Use relative and absolute paths.
- Create, copy, move, and inspect files.
- Use pipes and output redirection.
- Explain standard input, standard output, and standard error.
- Interpret exit codes.
- Inspect processes and ports.
- Use environment variables.
- Make basic HTTP requests with cURL.
- Send JSON data with cURL.
- Recognize command-line security risks.

---

# Part 1 — Multiple-Choice Quiz

Choose the best answer.

## Question 1

What is a terminal?

- [ ] A database server
- [ ] A text-based interface for interacting with a computer
- [ ] A programming language
- [ ] A network protocol

---

## Question 2

What is a shell?

- [ ] A program that interprets and executes commands
- [ ] A physical storage device
- [ ] A browser cache
- [ ] A database table

---

## Question 3

Which of the following is an example of a shell?

- [ ] Bash
- [ ] PostgreSQL
- [ ] HTML
- [ ] Ethernet

---

## Question 4

Which structure best represents a command?

- [ ] `file = server + browser`
- [ ] `command [options] [arguments]`
- [ ] `HTML > CSS > JavaScript`
- [ ] `database / process / port`

---

## Question 5

In the following command, what is `project`?

```bash
cd project
```

- [ ] The command
- [ ] An option
- [ ] An argument
- [ ] An exit code

---

## Question 6

What does `pwd` commonly do on Unix-like systems?

- [ ] Prints the current working directory
- [ ] Deletes the current directory
- [ ] Starts a server
- [ ] Lists all running processes

---

## Question 7

What does `cd` commonly do?

- [ ] Changes the current directory
- [ ] Copies a file
- [ ] Creates a database
- [ ] Stops a process

---

## Question 8

What does `ls` commonly do?

- [ ] Lists files and directories
- [ ] Sends an HTTP request
- [ ] Changes file permissions
- [ ] Prints environment variables only

---

## Question 9

What does this command usually do?

```bash
ls -la
```

- [ ] Lists detailed information, including hidden files
- [ ] Deletes hidden files
- [ ] Starts a local server
- [ ] Searches for a process

---

## Question 10

What does this command do?

```bash
mkdir project
```

- [ ] Creates a directory named `project`
- [ ] Deletes the `project` directory
- [ ] Opens the project in a browser
- [ ] Creates a database table

---

## Question 11

What does this command usually do?

```bash
touch notes.txt
```

- [ ] Creates an empty file if it does not exist
- [ ] Deletes `notes.txt`
- [ ] Searches the file
- [ ] Uploads the file

---

## Question 12

What does `cat` commonly do?

- [ ] Displays file contents
- [ ] Changes directories
- [ ] Lists open ports
- [ ] Stops a process

---

## Question 13

What does this command do?

```bash
cd ..
```

- [ ] Moves into a child directory
- [ ] Moves into the parent directory
- [ ] Deletes the current directory
- [ ] Moves to a random directory

---

## Question 14

Which symbol commonly represents the current directory?

- [ ] `.`
- [ ] `..`
- [ ] `~`
- [ ] `#`

---

## Question 15

Which symbol commonly represents the parent directory?

- [ ] `.`
- [ ] `..`
- [ ] `/`
- [ ] `@`

---

## Question 16

What does this command do?

```bash
cp source.txt destination.txt
```

- [ ] Copies `source.txt` to `destination.txt`
- [ ] Moves and deletes `source.txt`
- [ ] Compares the files
- [ ] Compresses the files

---

## Question 17

What does `mv` commonly do?

- [ ] Moves or renames files
- [ ] Displays file contents
- [ ] Starts a database
- [ ] Searches processes

---

## Question 18

What does this command do?

```bash
rm notes.txt
```

- [ ] Deletes `notes.txt`
- [ ] Renames `notes.txt`
- [ ] Displays `notes.txt`
- [ ] Uploads `notes.txt`

---

## Question 19

What does `>` generally do?

- [ ] Redirects output to a file, usually replacing its contents
- [ ] Appends output to a file
- [ ] Searches a directory
- [ ] Changes the current user

---

## Question 20

What does `>>` generally do?

- [ ] Appends output to a file
- [ ] Deletes a file
- [ ] Starts a background process
- [ ] Displays the previous command

---

## Question 21

What does the pipe symbol do?

```bash
command1 | command2
```

- [ ] Sends the output of `command1` to `command2`
- [ ] Encrypts the output
- [ ] Runs both commands on different computers
- [ ] Deletes the output

---

## Question 22

What does this command do?

```bash
grep "error" server.log
```

- [ ] Searches `server.log` for lines containing `error`
- [ ] Deletes error messages
- [ ] Starts the server
- [ ] Renames the log file

---

## Question 23

What does this command do?

```bash
tail -f server.log
```

- [ ] Follows new lines added to the log
- [ ] Deletes the end of the log
- [ ] Copies the log
- [ ] Compresses the log

---

## Question 24

What does exit code `0` usually mean?

- [ ] The command succeeded
- [ ] The command failed
- [ ] The process is still running
- [ ] The command was skipped

---

## Question 25

What does a nonzero exit code generally indicate?

- [ ] Failure or another special condition
- [ ] Guaranteed success
- [ ] The command was never parsed
- [ ] The file is empty

---

## Question 26

What is a process?

- [ ] A running instance of a program
- [ ] A directory path
- [ ] A shell option
- [ ] A file extension

---

## Question 27

Which command commonly lists running processes on Unix-like systems?

- [ ] `ps aux`
- [ ] `pwd`
- [ ] `mkdir`
- [ ] `curl`

---

## Question 28

What does this command help identify?

```bash
lsof -i :3000
```

- [ ] Files containing the number `3000`
- [ ] The process using network port `3000`
- [ ] The current directory
- [ ] The current Git branch

---

## Question 29

What is an environment variable?

- [ ] A named configuration value available to a process
- [ ] An image format
- [ ] A database table
- [ ] A CSS rule

---

## Question 30

What does this command do?

```bash
export PORT=3000
```

- [ ] Sets the `PORT` environment variable
- [ ] Automatically starts a server on port `3000`
- [ ] Deletes port `3000`
- [ ] Opens a firewall rule

---

## Question 31

What does cURL commonly do?

- [ ] Makes network requests from the command line
- [ ] Compiles HTML
- [ ] Changes file ownership only
- [ ] Creates database tables

---

## Question 32

What does this command usually do?

```bash
curl -I https://example.com
```

- [ ] Displays response headers without the normal response body
- [ ] Downloads every file from the site
- [ ] Deletes the website
- [ ] Opens an interactive shell

---

## Question 33

What does this command usually do?

```bash
curl -v https://example.com
```

- [ ] Displays verbose connection and HTTP diagnostics
- [ ] Scans the computer for viruses
- [ ] Starts a web server
- [ ] Validates a database schema

---

## Question 34

What does `curl -L` usually do?

- [ ] Follows redirects
- [ ] Limits the request to localhost
- [ ] Lists files
- [ ] Logs the user out

---

## Question 35

Why should URLs containing `&` often be quoted?

- [ ] The shell may interpret `&` specially
- [ ] URLs cannot contain ampersands
- [ ] Quoting encrypts the URL
- [ ] cURL accepts only quoted URLs

---

## Question 36

Which command is potentially destructive?

- [ ] `pwd`
- [ ] `ls`
- [ ] `rm -rf project`
- [ ] `echo hello`

---

## Question 37

Which is the safest place for a production API secret?

- [ ] Public frontend JavaScript
- [ ] A public URL
- [ ] A protected secret-management system
- [ ] A screenshot

---

## Question 38

What does `Ctrl + C` usually do in a terminal?

- [ ] Interrupts the foreground process
- [ ] Copies the entire filesystem
- [ ] Changes the current directory
- [ ] Opens a database

---

## Question 39

How can you display a variable named `PORT` in many Unix-like shells?

- [ ] `echo "$PORT"`
- [ ] `show PORT`
- [ ] `print-port`
- [ ] `read-port PORT`

---

## Question 40

What does this do?

```bash
command1 && command2
```

- [ ] Runs `command2` only if `command1` succeeds
- [ ] Runs `command2` only if `command1` fails
- [ ] Deletes both commands
- [ ] Sends both commands to a remote server

---

# Part 2 — True or False

## Question 41

A terminal and a shell are exactly the same thing.

- [ ] True
- [ ] False

---

## Question 42

A shell interprets commands and starts programs.

- [ ] True
- [ ] False

---

## Question 43

Relative paths depend on the current working directory.

- [ ] True
- [ ] False

---

## Question 44

The `>` operator normally appends to a file.

- [ ] True
- [ ] False

---

## Question 45

The `>>` operator normally appends to a file.

- [ ] True
- [ ] False

---

## Question 46

A pipe can send one command’s output into another command.

- [ ] True
- [ ] False

---

## Question 47

A nonzero exit code always means the command did nothing.

- [ ] True
- [ ] False

---

## Question 48

`curl -I` is commonly used to inspect response headers.

- [ ] True
- [ ] False

---

## Question 49

Verbose cURL output may contain cookies or authorization headers.

- [ ] True
- [ ] False

---

## Question 50

A background process may continue running after the shell returns to the prompt.

- [ ] True
- [ ] False

---

## Question 51

`npm run dev` normally starts a process.

- [ ] True
- [ ] False

---

## Question 52

An environment variable is automatically private even if it is included in browser JavaScript.

- [ ] True
- [ ] False

---

## Question 53

`rm -rf` can delete directories recursively.

- [ ] True
- [ ] False

---

## Question 54

Commands should be understood before being run with elevated privileges.

- [ ] True
- [ ] False

---

## Question 55

cURL enforces browser CORS restrictions exactly as a browser does.

- [ ] True
- [ ] False

---

# Part 3 — Short-Answer Quiz

Answer in complete sentences.

## Question 56

What is the difference between a terminal and a shell?

---

## Question 57

Explain this command:

```bash
curl -I https://example.com
```

Identify:

```text
Command:
Option:
Argument:
```

---

## Question 58

What is the current working directory?

---

## Question 59

Why do relative paths depend on the current working directory?

---

## Question 60

What is the difference between `>` and `>>`?

---

## Question 61

What is a pipe? Give an example.

---

## Question 62

What are standard input, standard output, and standard error?

---

## Question 63

Why are exit codes useful in scripts?

---

## Question 64

What is the difference between a foreground process and a background process?

---

## Question 65

What is an environment variable?

---

## Question 66

Why might an application need to restart after an environment variable changes?

---

## Question 67

What is the difference between a process and a port?

---

## Question 68

Why is cURL useful when debugging an API?

---

## Question 69

Why should passwords not be placed directly in shell commands?

---

## Question 70

Why should you inspect your current directory before running a destructive command?

---

# Part 4 — Path and File Exercises

Assume the current directory is:

```text
/home/alex/web-learning
```

## Question 71

What absolute path does this represent?

```text
frontend/src/app.js
```

---

## Question 72

What does this command do?

```bash
cd frontend
```

---

## Question 73

What does this command do from:

```text
/home/alex/web-learning/frontend
```

```bash
cd ..
```

---

## Question 74

What does this command do?

```bash
mkdir -p backend/src/services
```

---

## Question 75

What does this command do?

```bash
touch backend/src/server.js
```

---

## Question 76

What does this command do?

```bash
cp backend/src/server.js backend/src/server.backup.js
```

---

## Question 77

What does this command do?

```bash
mv server.js app.js
```

---

## Question 78

What is the risk of this command?

```bash
rm *.log
```

---

## Question 79

What is the risk of this command?

```bash
rm -rf .
```

---

## Question 80

Which command is safest for inspecting a directory before deleting files?

- [ ] `ls -la`
- [ ] `rm -rf`
- [ ] `chmod 777`
- [ ] `kill -9`

Explain your answer.

---

# Part 5 — Command Interpretation

Explain each command.

## Question 81

```bash
pwd
```

## Question 82

```bash
ls -la
```

## Question 83

```bash
mkdir -p project/frontend/src
```

## Question 84

```bash
echo "Hello" > greeting.txt
```

## Question 85

```bash
echo "Another line" >> greeting.txt
```

## Question 86

```bash
cat greeting.txt
```

## Question 87

```bash
grep -Rni "error" .
```

## Question 88

```bash
tail -f server.log
```

## Question 89

```bash
ps aux | grep node
```

## Question 90

```bash
curl -i https://api.example.com/products
```

## Question 91

```bash
curl \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Keyboard"}' \
  https://api.example.com/products
```

## Question 92

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://example.com
```

## Question 93

```bash
export API_URL="http://localhost:4000"
```

## Question 94

```bash
echo "$API_URL"
```

## Question 95

```bash
command1 || echo "The first command failed"
```

---

# Part 6 — Scenario Quiz

## Question 96 — Port Conflict

A development server reports:

```text
Port 3000 is already in use.
```

What does this mean?

What would you inspect?

---

## Question 97 — Wrong Directory

You run:

```bash
npm run dev
```

but the project configuration cannot be found.

What might be wrong?

---

## Question 98 — Missing Command

You run:

```bash
node
```

and receive:

```text
command not found
```

What could cause this?

---

## Question 99 — Localhost Failure

You open:

```text
http://localhost:3000
```

and receive a connection-refused error.

What could be wrong?

---

## Question 100 — DNS Failure

You run:

```bash
curl https://api.example.com
```

and receive:

```text
Could not resolve host
```

Which layer is probably failing?

---

## Question 101 — cURL `401`

You run:

```bash
curl https://api.example.com/account
```

and receive:

```http
401 Unauthorized
```

What may be missing?

---

## Question 102 — cURL `500`

You send a valid-looking request and receive:

```http
500 Internal Server Error
```

What evidence should you collect?

---

## Question 103 — Browser and cURL Differ

A browser request succeeds, but the equivalent cURL request fails.

What might differ?

---

## Question 104 — CORS

cURL succeeds, but browser JavaScript fails with a CORS error.

Why can this happen?

---

## Question 105 — Secret in Command History

A developer runs:

```bash
curl \
  -H "Authorization: Bearer real-secret-token" \
  https://api.example.com
```

What risks exist?

What should happen if the token was real?

---

## Question 106 — Dangerous Wildcard

A developer runs:

```bash
rm *.log
```

What could happen?

What should they do first?

---

## Question 107 — Environment Scope

A developer runs:

```bash
export API_URL=http://localhost:4000
```

Then opens a new terminal and the variable is missing.

Why?

---

## Question 108 — Service Configuration

An application works when started manually but uses the wrong database when started by a service manager.

What could explain this?

---

## Question 109 — Background Process

A developer starts:

```bash
npm run dev &
```

Later, another attempt produces a port conflict.

What probably happened?

---

## Question 110 — Log Following

A developer runs:

```bash
tail -f app.log
```

and cannot enter another command.

What is happening?

How do they stop it?

---

# Part 7 — Practical Exercises

Use a safe practice directory.

## Exercise 1 — Create a Workspace

```bash
mkdir cli-practice
cd cli-practice
mkdir frontend backend logs
touch README.md
```

Verify:

```bash
pwd
ls -la
```

---

## Exercise 2 — Create and Read Files

```bash
echo "Frontend notes" > frontend/README.md
echo "Backend notes" > backend/README.md
echo "INFO server started" > logs/app.log
```

Read them:

```bash
cat frontend/README.md
cat backend/README.md
cat logs/app.log
```

---

## Exercise 3 — Append Log Entries

```bash
echo "INFO request received" >> logs/app.log
echo "WARN slow response" >> logs/app.log
echo "ERROR database unavailable" >> logs/app.log
```

Search:

```bash
grep -i "error" logs/app.log
```

---

## Exercise 4 — Use a Pipe

```bash
cat logs/app.log | grep -i "warn"
```

Write matching errors to another file:

```bash
cat logs/app.log | grep -i "error" > logs/errors.txt
```

Inspect:

```bash
cat logs/errors.txt
```

---

## Exercise 5 — Start a Local Server

```bash
python -m http.server 8000
```

In another terminal:

```bash
curl -i http://localhost:8000
```

Inspect the listener:

```bash
ss -ltnp
```

or:

```bash
lsof -i :8000
```

Stop the server with:

```text
Ctrl + C
```

---

## Exercise 6 — Use Environment Variables

```bash
export APP_ENV=practice
echo "$APP_ENV"
```

Run a command with a temporary variable:

```bash
APP_PORT=8000 sh -c 'echo "Port is $APP_PORT"'
```

Explain the difference between the two variable scopes.

---

## Exercise 7 — Test an API

```bash
curl -i https://httpbin.org/get
```

Inspect:

```text
Status code
Content-Type
Response body
Request URL
```

Add query data:

```bash
curl -G https://httpbin.org/get \
  --data-urlencode "q=web fundamentals"
```

---

## Exercise 8 — Send JSON

```bash
curl \
  -i \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Alex","topic":"web"}' \
  https://httpbin.org/post
```

Find the JSON body in the response.

---

# Answer Key

# Part 1 — Multiple-Choice Answers

| Question | Answer | Explanation |
|---:|---|---|
| 1 | A text-based interface for interacting with a computer | A terminal provides a place to enter commands and view output. |
| 2 | A program that interprets and executes commands | A shell parses commands and starts programs. |
| 3 | Bash | Bash is a command shell. |
| 4 | `command [options] [arguments]` | This is the common command structure. |
| 5 | An argument | `project` is the directory passed to `cd`. |
| 6 | Prints the current working directory | `pwd` means “print working directory.” |
| 7 | Changes the current directory | `cd` means “change directory.” |
| 8 | Lists files and directories | `ls` displays directory contents. |
| 9 | Lists detailed information, including hidden files | `-l` enables long format; `-a` includes hidden files. |
| 10 | Creates a directory named `project` | `mkdir` creates directories. |
| 11 | Creates an empty file if it does not exist | `touch` creates a file or updates its timestamp. |
| 12 | Displays file contents | `cat` writes file contents to standard output. |
| 13 | Moves to the parent directory | `..` means the parent directory. |
| 14 | `.` | A single dot means the current directory. |
| 15 | `..` | Two dots mean the parent directory. |
| 16 | Copies `source.txt` to `destination.txt` | `cp` copies files. |
| 17 | Moves or renames files | `mv` performs both operations. |
| 18 | Deletes `notes.txt` | `rm` removes files. |
| 19 | Redirects output to a file, replacing contents | `>` creates or truncates the destination. |
| 20 | Appends output to a file | `>>` writes after existing contents. |
| 21 | Sends the output of `command1` to `command2` | A pipe connects standard output to standard input. |
| 22 | Searches `server.log` for lines containing `error` | `grep` searches text. |
| 23 | Follows new lines added to the log | `tail -f` watches a growing file. |
| 24 | The command succeeded | Exit code `0` conventionally means success. |
| 25 | Failure or another special condition | Nonzero codes generally indicate a problem or alternate result. |
| 26 | A running instance of a program | A process is a program currently executing. |
| 27 | `ps aux` | This commonly lists running processes. |
| 28 | The process using port `3000` | `lsof -i` displays network-related open files and processes. |
| 29 | A named configuration value available to a process | Environment variables provide runtime values. |
| 30 | Sets the `PORT` environment variable | It does not itself start a server. |
| 31 | Makes network requests from the command line | cURL can make HTTP and other protocol requests. |
| 32 | Displays response headers without the normal response body | `-I` is commonly used for header inspection. |
| 33 | Displays verbose connection and HTTP diagnostics | `-v` shows detailed request, response, and connection information. |
| 34 | Follows redirects | `-L` follows `Location` headers. |
| 35 | The shell may interpret `&` specially | Quoting prevents unintended shell interpretation. |
| 36 | `rm -rf project` | It can recursively delete a directory and its contents. |
| 37 | A protected secret-management system | Production secrets should not be exposed to clients or repositories. |
| 38 | Interrupts the foreground process | `Ctrl + C` sends an interrupt signal. |
| 39 | `echo "$PORT"` | It expands and prints the variable value. |
| 40 | Runs `command2` only if `command1` succeeds | `&&` conditionally chains commands. |

---

# Part 2 — True-or-False Answers

| Question | Answer | Explanation |
|---:|---|---|
| 41 | False | A terminal is an interface; a shell interprets commands. |
| 42 | True | Shells parse commands and start programs. |
| 43 | True | Relative paths depend on the current working directory. |
| 44 | False | `>` normally replaces or creates the file. |
| 45 | True | `>>` appends output. |
| 46 | True | A pipe connects one command’s output to another’s input. |
| 47 | False | A nonzero code may indicate failure or another special condition; it does not prove nothing happened. |
| 48 | True | `curl -I` is commonly used to inspect response headers. |
| 49 | True | Verbose output may contain credentials, cookies, and private data. |
| 50 | True | Background processes can continue after the prompt returns. |
| 51 | True | A development command normally starts a process. |
| 52 | False | A frontend build may include an environment value in browser-visible code. |
| 53 | True | `rm -rf` recursively removes files and directories. |
| 54 | True | Elevated commands can cause serious damage if misunderstood. |
| 55 | False | cURL does not enforce browser CORS restrictions. |

---

# Part 3 — Short-Answer Model Answers

## Question 56

A terminal is the interface window where commands are entered. A shell is the program that interprets those commands and asks the operating system to execute them.

---

## Question 57

```bash
curl -I https://example.com
```

```text
Command:
  curl

Option:
  -I

Argument:
  https://example.com
```

The command makes an HTTP request and commonly displays response headers without the normal response body.

---

## Question 58

The current working directory is the directory from which the shell is currently operating. Relative paths and many commands are interpreted from this location.

---

## Question 59

A relative path does not begin at the filesystem root. It is interpreted from the current directory, so the same relative path can refer to different files depending on where the command is run.

---

## Question 60

```text
>:
  Redirects output to a file, usually replacing existing contents.

>>:
  Redirects output and appends it to the file.
```

---

## Question 61

A pipe sends the standard output of one command to the standard input of another command.

Example:

```bash
cat server.log | grep -i error
```

---

## Question 62

```text
stdin:
  Standard input, such as keyboard input or another command’s output.

stdout:
  Normal program output.

stderr:
  Error and diagnostic output.
```

These streams can be redirected separately.

---

## Question 63

Exit codes allow scripts to determine whether a command succeeded and decide whether to continue, retry, or stop.

---

## Question 64

A foreground process occupies the current terminal until it finishes or is interrupted. A background process can continue while the shell returns to the prompt.

---

## Question 65

An environment variable is a named value provided to a process, commonly used for runtime configuration such as ports, API URLs, environment names, and credentials.

---

## Question 66

Many applications read configuration only at startup. Restarting the application allows it to load the new value.

---

## Question 67

A process is a running program. A port is a network endpoint through which a process may accept connections.

---

## Question 68

cURL can send requests independently of the browser and frontend. It helps determine whether a problem belongs to the API or to browser-specific behavior.

---

## Question 69

Passwords may be stored in shell history, terminal recordings, process listings, CI logs, screenshots, or shared command transcripts.

---

## Question 70

Relative paths and wildcards operate based on the current directory. Inspecting first reduces the risk of modifying or deleting the wrong files.

---

# Part 4 — Path and File Answers

## Question 71

```text
/home/alex/web-learning/frontend/src/app.js
```

---

## Question 72

It changes into the `frontend` directory relative to the current working directory.

---

## Question 73

It moves to:

```text
/home/alex/web-learning
```

---

## Question 74

It creates:

```text
backend/
└── src/
    └── services/
```

The `-p` option creates missing parent directories.

---

## Question 75

It creates an empty file named:

```text
backend/src/server.js
```

---

## Question 76

It copies:

```text
backend/src/server.js
```

to:

```text
backend/src/server.backup.js
```

---

## Question 77

It renames `server.js` to `app.js`, or moves it if `app.js` is located in another directory.

---

## Question 78

It may delete every `.log` file in the current directory.

Inspect first:

```bash
ls *.log
```

---

## Question 79

It may recursively delete the contents of the current directory. This is extremely dangerous and should not be run casually.

---

## Question 80

Correct answer:

```text
ls -la
```

It inspects directory contents without modifying them. The other commands may change permissions, delete data, or terminate processes.

---

# Part 5 — Command Interpretation Answers

## Question 81

```bash
pwd
```

Prints the current working directory.

---

## Question 82

```bash
ls -la
```

Lists files and directories in detailed format, including hidden files.

---

## Question 83

```bash
mkdir -p project/frontend/src
```

Creates the nested directory structure, including missing parent directories.

---

## Question 84

```bash
echo "Hello" > greeting.txt
```

Writes `Hello` to `greeting.txt`, replacing any existing contents.

---

## Question 85

```bash
echo "Another line" >> greeting.txt
```

Appends `Another line` to the end of the file.

---

## Question 86

```bash
cat greeting.txt
```

Displays the file’s contents.

---

## Question 87

```bash
grep -Rni "error" .
```

Recursively searches from the current directory, ignoring case and showing line numbers for matching lines.

---

## Question 88

```bash
tail -f server.log
```

Displays the end of the file and continues showing new lines as they are appended.

Press `Ctrl + C` to stop following it.

---

## Question 89

```bash
ps aux | grep node
```

Lists running processes and filters the output for lines containing `node`.

---

## Question 90

```bash
curl -i https://api.example.com/products
```

Makes an HTTP request and includes response headers in the terminal output.

---

## Question 91

This sends a JSON `POST` request:

```text
Method:
  POST

Content-Type:
  application/json

Body:
  {"name":"Keyboard"}

Destination:
  https://api.example.com/products
```

---

## Question 92

```bash
curl -s -o /dev/null -w "%{http_code}\n" https://example.com
```

```text
-s:
  Silent mode.

-o /dev/null:
  Discards the response body.

-w "%{http_code}\n":
  Prints the HTTP status code.
```

---

## Question 93

```bash
export API_URL="http://localhost:4000"
```

Sets `API_URL` for the current shell and child processes started from it.

---

## Question 94

```bash
echo "$API_URL"
```

Prints the current value of the `API_URL` variable.

---

## Question 95

```bash
command1 || echo "The first command failed"
```

Runs the `echo` command only if `command1` exits with a nonzero status.

---

# Part 6 — Scenario Model Answers

## Question 96 — Port Conflict

Another process is already listening on port `3000`.

Inspect it with:

```bash
lsof -i :3000
```

or:

```bash
ss -ltnp
```

Then stop the correct process or configure the new application to use another port.

---

## Question 97 — Wrong Directory

The command is probably running outside the project directory.

Check:

```bash
pwd
ls -la
```

Look for project configuration files such as:

```text
package.json
pyproject.toml
Cargo.toml
```

Then use `cd` to enter the correct directory.

---

## Question 98 — Missing Command

Possible causes:

- The runtime is not installed.
- The executable is not in `PATH`.
- The command is misspelled.
- A version manager is not active.
- The shell has not loaded updated configuration.

Check:

```bash
which node
```

On PowerShell:

```powershell
Get-Command node
```

---

## Question 99 — Localhost Failure

Possible causes:

```text
Development server is not running.
Wrong port.
Process crashed.
HTTP/HTTPS mismatch.
Service is bound to another address.
Firewall or local policy.
```

Useful checks:

```bash
curl -v http://localhost:3000
lsof -i :3000
```

---

## Question 100 — DNS Failure

The hostname-resolution layer is probably failing.

Test:

```bash
nslookup api.example.com
```

or:

```bash
dig api.example.com
```

Also check the hostname for spelling errors and inspect DNS configuration.

---

## Question 101 — cURL `401`

Authentication may be missing, invalid, expired, or incorrectly formatted.

For a bearer-token API:

```bash
curl \
  -H "Authorization: Bearer REDACTED" \
  https://api.example.com/account
```

If the browser normally uses cookies, cURL may also need a cookie:

```bash
curl \
  -b "session_id=REDACTED" \
  https://api.example.com/account
```

---

## Question 102 — cURL `500`

Collect:

```text
Exact URL
HTTP method
Request headers
Request body
Response body
Timestamp
Request ID
Server logs
Database logs
Recent deployment information
```

Reproduce the request consistently and inspect backend logs.

---

## Question 103 — Browser and cURL Differ

Possible differences include:

```text
Cookies
Authorization headers
Origin
Referer
Content-Type
Request body
Redirect behavior
Environment
Proxy
Service worker behavior
```

Compare the actual requests rather than assuming they are identical.

---

## Question 104 — CORS

Browsers enforce CORS rules that cURL does not.

The server may return a response, but the browser may prevent frontend JavaScript from reading it unless the server provides appropriate CORS headers.

Inspect:

```text
Origin
OPTIONS preflight
Access-Control-Allow-Origin
Access-Control-Allow-Methods
Access-Control-Allow-Headers
Access-Control-Allow-Credentials
```

---

## Question 105 — Secret in Command History

Risks include:

```text
Shell history
Terminal recordings
Process inspection
CI logs
Screenshots
Shared command transcripts
```

If the token was real:

```text
1. Revoke or rotate it.
2. Inspect logs for misuse.
3. Replace it securely.
4. Remove the exposed value from active configuration.
5. Review the process that exposed it.
```

---

## Question 106 — Dangerous Wildcard

The command may delete every `.log` file in the current directory.

Inspect first:

```bash
pwd
ls *.log
```

Use a specific verified path or filename where possible.

---

## Question 107 — Environment Scope

The variable was exported only in the first shell session. A new terminal starts a separate shell environment and does not automatically inherit the variable.

To make it persistent, configure it through the appropriate shell profile or environment-management system, while protecting secrets.

---

## Question 108 — Service Configuration

The service manager may use a different:

```text
Working directory
User
PATH
Environment variables
Runtime version
Configuration file
Permission set
```

Inspect:

```bash
systemctl status my-app
journalctl -u my-app
```

Compare service configuration with the manual command.

---

## Question 109 — Background Process

The original process may still be running in the background and still listening on the port.

Find it:

```bash
lsof -i :3000
```

or:

```bash
ps aux | grep node
```

Stop the correct process carefully.

---

## Question 110 — Log Following

`tail -f` intentionally remains active and waits for new lines.

Stop it with:

```text
Ctrl + C
```

---

# Part 7 — Practical Exercise Guidance

## Exercise 1

Expected structure:

```text
cli-practice/
├── frontend/
├── backend/
├── logs/
└── README.md
```

---

## Exercise 2

The commands create three files containing short text messages. `cat` displays their contents.

---

## Exercise 3

The `>>` operator appends lines to the log rather than replacing it.

This command should find the error line:

```bash
grep -i "error" logs/app.log
```

---

## Exercise 4

The pipe passes the output of `cat` into `grep`.

The second command writes matching error lines to:

```text
logs/errors.txt
```

---

## Exercise 5

The Python process listens on port `8000`.

The cURL request should receive an HTTP response while the server is running.

After `Ctrl + C`, the server stops and the request should fail unless another service is listening on that port.

---

## Exercise 6

```bash
export APP_ENV=practice
```

sets the variable in the current shell.

```bash
APP_PORT=8000 sh -c 'echo "Port is $APP_PORT"'
```

sets `APP_PORT` only for the command that starts the child shell.

---

## Exercise 7

`httpbin.org` returns request information. Inspect:

```text
Status code
Content-Type
Response body
Query parameters
```

---

## Exercise 8

The response should show that the endpoint received:

```json
{
  "name": "Alex",
  "topic": "web"
}
```

---

# Review Rubric

## Excellent

The learner:

```text
Explains command behavior accurately.
Distinguishes terminal, shell, and process.
Understands path context.
Recognizes destructive operations.
Can use cURL effectively.
Identifies browser-specific issues such as CORS.
Protects secrets.
```

## Good

The learner:

```text
Understands the main concepts.
Can explain common commands.
May need additional practice with process, shell, or error handling details.
```

## Developing

The learner:

```text
Recognizes some commands but confuses options, arguments, paths, or output streams.
Needs more guided practice.
```

## Needs Review

The learner:

```text
Cannot distinguish a shell from a terminal.
Does not understand current directories.
Does not recognize destructive commands.
Confuses network errors with HTTP responses.
```

---

# Completion Criteria

You are ready to continue when you can:

```text
Explain terminal versus shell.
Read basic command syntax.
Navigate directories.
Use absolute and relative paths.
Create, copy, move, and inspect files.
Use pipes and redirection.
Interpret exit codes.
Inspect processes and ports.
Set and read environment variables.
Start a local server.
Use cURL for GET and POST requests.
Send JSON.
Inspect response headers and status codes.
Explain command-line safety risks.
```
