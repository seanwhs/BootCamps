# Appendix A: SQLite CLI Essential Commands

This appendix provides a comprehensive reference for the most useful "dot‑commands" (commands that start with a dot) inside the SQLite command‑line shell. These commands control the shell's behavior, display metadata, and help you inspect your database without writing full SQL queries.

## Core Dot‑Commands

| Command | Description | Example |
|---------|-------------|---------|
| `.databases` | List all attached databases and their file paths. | `.databases` |
| `.tables` | Show all tables in the current database. | `.tables` |
| `.schema [table]` | Show the `CREATE` statement for a specific table (or all tables if no argument). | `.schema contacts` |
| `.dump [table]` | Output SQL statements to recreate the table and its data. Useful for backups. | `.dump contacts` |
| `.headers on\|off` | Show or hide column headers in query output. | `.headers on` |
| `.mode MODE` | Set the output display mode. Common modes: `column`, `list`, `csv`, `json`, `html`. | `.mode column` |
| `.width n1 n2 ...` | Set column widths for `column` mode. | `.width 12 25 10` |
| `.exit` or `.quit` | Exit the SQLite shell. | `.exit` |

## Output Formatting

| Command | Description |
|---------|-------------|
| `.mode column` | Display results in a column‑aligned table (best for readability). |
| `.mode list` | Display results separated by a delimiter (default: `\|`). |
| `.mode csv` | Output as comma‑separated values. |
| `.mode json` | Output as JSON array of objects. |
| `.mode html` | Output as an HTML table. |
| `.separator CHAR` | Change the field separator (used in `list` mode). |
| `.nullvalue STRING` | Replace `NULL` values with a custom string. |

**Example:**
```bash
sqlite3 mydb.db
.headers on
.mode column
.nullvalue '(NULL)'
SELECT * FROM contacts;
```

## Database Inspection

| Command | Description |
|---------|-------------|
| `.dbinfo` | Show metadata about the database file (page size, number of pages, etc.). |
| `.indexes [table]` | List all indexes, or indexes for a specific table. |
| `.stats` | Display statistics about the database (cache hits, etc.). |
| `.profile on\|off` | Enable or disable query profiling (shows execution time for each query). |
| `.trace on\|off` | Enable or disable SQL statement tracing (shows each statement as it runs). |

## Import / Export

| Command | Description |
|---------|-------------|
| `.import FILE TABLE` | Import data from a CSV file into a table. |
| `.output FILE` | Redirect all subsequent query output to a file. |
| `.once FILE` | Redirect output for the next single query to a file. |
| `.read FILE` | Execute SQL commands from a file. |
| `.backup TARGET` | Create a backup of the current database to a new file (uses online backup API). |
| `.restore TARGET` | Restore a database from a backup file. |

**Example: Export to CSV:**
```bash
sqlite3 mydb.db
.headers on
.mode csv
.once contacts.csv
SELECT * FROM contacts;
```

**Example: Import from CSV:**
```bash
sqlite3 mydb.db
.mode csv
.import contacts.csv contacts
```

## Shell and Environment

| Command | Description |
|---------|-------------|
| `.help` | Show all available dot‑commands. |
| `.shell CMD` | Execute a system shell command (e.g., `.shell ls`). |
| `.system CMD` | Same as `.shell`. |
| `.cd DIR` | Change the working directory. |
| `.prompt MAIN CONTINUE` | Change the SQLite prompt strings. |

## Working with Multiple Databases

| Command | Description |
|---------|-------------|
| `.open FILE` | Open or create a database file (closes the current connection). |
| `.attach FILE AS ALIAS` | Attach an additional database file to the current connection. |
| `.detach ALIAS` | Detach a previously attached database. |

**Example:**
```bash
sqlite3 main.db
ATTACH 'archive.db' AS archive;
SELECT * FROM main.contacts UNION SELECT * FROM archive.contacts;
DETACH archive;
```

## Quick Reference Card

For everyday use, these are the commands you will reach for most often:

```bash
# Open a database
sqlite3 mydb.db

# Inside the shell:
.tables                 # See all tables
.schema contacts        # See table structure
.headers on             # Show column names
.mode column            # Pretty formatting
SELECT * FROM contacts; # Run a query
.exit                   # Quit
```

---

This appendix serves as your quick reference for the SQLite command‑line interface. Keep it handy as you work through the tutorials and build your own projects.
