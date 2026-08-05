# Security and Encryption Primer 7: Protecting Your SQLite Database

You've built your database, written your queries, and connected your app. Now the bad guys are out there. This primer covers the essential security practices for SQLite: defending against SQL injection, encrypting data at rest, managing file permissions, and handling sensitive information responsibly.

---

## 1. Why Security Matters

SQLite databases are just files. If someone gains access to that file, they can read or modify your data. If your application accepts user input, an attacker might inject malicious SQL. You need **defense in depth**:

- **Prevent injection** – Never trust user input.
- **Restrict access** – Use file permissions and application‑level controls.
- **Encrypt data** – Protect sensitive information even if the file is stolen.
- **Audit changes** – Track who did what (optional but recommended).

---

## 2. SQL Injection: The Number One Threat

SQL injection happens when an attacker injects malicious SQL into your query through unsanitized input.

### The Vulnerability
```python
# Dangerous code
user_input = request.GET.get('name')
cursor.execute(f"SELECT * FROM users WHERE name = '{user_input}'")
```
If `user_input` is `' OR '1'='1`, the query becomes:
```sql
SELECT * FROM users WHERE name = '' OR '1'='1'
```
That returns all rows. Worse: `' DROP TABLE users; --` will delete your table.

### The Solution: Parameterized Queries

**Always** use placeholders. Never use string concatenation or f‑strings.

```python
# Safe
cursor.execute("SELECT * FROM users WHERE name = ?", (user_input,))
```
This ensures `user_input` is treated as data, not executable code.

### In Different Languages

| Language | Safe Pattern |
|----------|--------------|
| Python (`sqlite3`) | `cursor.execute("SELECT * FROM t WHERE col = ?", (value,))` |
| Node.js (`better-sqlite3`) | `db.prepare("SELECT * FROM t WHERE col = ?").get(value)` |
| Java (JDBC) | `pstmt.setString(1, value)` |
| PHP (PDO) | `$stmt->bindParam(':col', $value)` |

### Dynamic Table/Column Names

Placeholders cannot be used for table or column names. In that case, **validate against a whitelist**:

```python
allowed_tables = ['users', 'products', 'orders']
if user_table not in allowed_tables:
    raise ValueError('Invalid table name')
cursor.execute(f"SELECT * FROM {user_table}")  # now safe
```

---

## 3. File Permissions

Since the database is a file, control access at the OS level.

### On Linux/macOS
```bash
# Only the owner can read/write
chmod 600 mydb.db

# Or allow group read/write
chown user:group mydb.db
chmod 640 mydb.db
```

### In a Web Application
The web server user (e.g., `www-data`, `nginx`) should own the file. Other users should have no access.

**Example:**
```bash
chown www-data:www-data /var/data/mydb.db
chmod 640 /var/data/mydb.db
```

### On Windows
Use file properties → Security tab to restrict permissions.

---

## 4. Encryption with SQLCipher

SQLite itself does not include encryption. For data at rest, use **SQLCipher**—an open‑source fork of SQLite that provides transparent 256‑bit AES encryption.

### Installing SQLCipher

- **Linux**: `sudo apt install sqlcipher`
- **macOS**: `brew install sqlcipher`
- **Windows**: Download from https://www.zetetic.net/sqlcipher/

### Creating an Encrypted Database
```bash
sqlcipher myencrypted.db
PRAGMA key = 'my_strong_password';
CREATE TABLE users (id INTEGER, name TEXT);
INSERT INTO users VALUES (1, 'Alice');
.exit
```
Now `myencrypted.db` is unreadable by standard `sqlite3`.

### Opening the Database
```bash
sqlcipher myencrypted.db
PRAGMA key = 'my_strong_password';
SELECT * FROM users;
```

### Using SQLCipher in Python
```bash
pip install pysqlcipher3
```
```python
from pysqlcipher3 import dbapi2 as sqlite

conn = sqlite.connect('myencrypted.db')
conn.execute("PRAGMA key = 'my_strong_password'")
# Use normally
```

**Important:** Never hard‑code the password. Use environment variables or a secrets manager.

```python
import os
password = os.environ.get('DB_PASSWORD')
if not password:
    raise RuntimeError('DB_PASSWORD not set')
```

---

## 5. Key Management Best Practices

- **Do not store keys in source code** – use environment variables, Vault, or AWS Secrets Manager.
- **For mobile apps**, store keys in the platform's secure storage (Android Keystore, iOS Keychain).
- **Rotate keys** periodically (if your application supports re‑encryption).
- **Use strong passwords** – at least 12 characters, mix of letters, numbers, symbols.
- **Consider key derivation** – SQLCipher's `PRAGMA kdf_iter` can be increased for better security (but slower).

Example:
```sql
PRAGMA kdf_iter = 100000;  -- default is 64000
```

---

## 6. Application‑Level Encryption

Even with SQLCipher, you may want to encrypt specific fields (e.g., credit card numbers, SSNs) **before** storing them, and decrypt them in your application.

### Python Example with `cryptography`
```python
from cryptography.fernet import Fernet
import os

key = os.environ.get('ENCRYPTION_KEY')
cipher = Fernet(key)

# Encrypt before insert
encrypted_ssn = cipher.encrypt(b'123-45-6789')
cursor.execute('INSERT INTO users (ssn) VALUES (?)', (encrypted_ssn,))

# Decrypt after select
encrypted_ssn = row[0]
ssn = cipher.decrypt(encrypted_ssn).decode()
```

This way, even if someone gets the database file and the SQLCipher key (theoretically), they still can't read the field.

---

## 7. Column‑Level vs. Whole‑Database Encryption

| Approach | Pros | Cons |
|----------|------|------|
| **Whole‑database (SQLCipher)** | Easy, transparent, protects all data. | Slight performance overhead; all or nothing. |
| **Column‑level (app code)** | Allows selective encryption; faster for non‑sensitive columns. | More complex; keys must be managed in app. |
| **Both** | Maximum security. | Adds complexity. |

Recommendation: **Use SQLCipher for the entire database**, and add column‑level encryption for the most sensitive fields (e.g., credit card numbers).

---

## 8. Auditing and Logging

Track who accessed or changed data. Use triggers (covered in the main series) to log operations.

```sql
CREATE TABLE audit_log (
    id INTEGER PRIMARY KEY,
    table_name TEXT,
    action TEXT,
    row_id INTEGER,
    old_values TEXT,
    new_values TEXT,
    user TEXT,
    timestamp TEXT DEFAULT (datetime('now'))
);

CREATE TRIGGER users_audit
AFTER UPDATE ON users
BEGIN
    INSERT INTO audit_log (table_name, action, row_id, old_values, new_values, user)
    VALUES ('users', 'UPDATE', OLD.id,
            json_object('name', OLD.name, 'email', OLD.email),
            json_object('name', NEW.name, 'email', NEW.email),
            'system');
END;
```

---

## 9. Preventing Accidental Data Exposure

- **Use `PRAGMA secure_delete = ON`** to overwrite deleted data with zeros (prevents recovery).
  ```sql
  PRAGMA secure_delete = ON;
  ```
- **Disable `.dump` in production** – attackers could read the entire database via the CLI.
- **Avoid logging sensitive data** – don't print query parameters or full row contents.
- **Use `VIEW`** to restrict columns visible to certain users (if you have multiple application roles).

---

## 10. Summary Checklist

- [ ] **Use parameterized queries** everywhere (no string concatenation).
- [ ] **Restrict file permissions** (`chmod 600` or `640`).
- [ ] **Enable WAL mode** (for concurrency, but also reduces lock‑based attacks).
- [ ] **Encrypt the database** with SQLCipher (or similar).
- [ ] **Store encryption keys securely** (environment variables, secrets manager).
- [ ] **Consider column‑level encryption** for ultra‑sensitive data.
- [ ] **Set `PRAGMA secure_delete = ON`** to overwrite deleted data.
- [ ] **Implement audit logging** for sensitive tables.
- [ ] **Validate dynamic table/column names** against a whitelist.
- [ ] **Never log passwords or personal data.**
- [ ] **Regularly update SQLite** to the latest version (security patches).

---

## 11. Quick Reference: SQLCipher Commands

| Task | Command |
|------|---------|
| Create encrypted database | `sqlcipher my.db; PRAGMA key = 'pwd'` |
| Open encrypted database | `sqlcipher my.db; PRAGMA key = 'pwd'` |
| Change key (re‑encrypt) | `PRAGMA rekey = 'new_pwd'` |
| Set KDF iterations | `PRAGMA kdf_iter = 100000` |
| Export to plain SQLite | `.dump` (but requires key) |

---

## 12. What About SQLite's Built‑in `sqlite3_key()`?

SQLite has a commercial encryption extension (`sqlite3_key`) but it's not open source. SQLCipher is the recommended open‑source alternative.

---

## Next Steps

- Implement **backup and restore** (secure backups are encrypted).
- Learn about **production deployment** (security in a live environment).
- Explore **compliance** (GDPR, HIPAA) and how SQLite fits.
- Dive into **full‑text search** (FTS5) and **JSON** in the main series.

---

**Security is a mindset, not a one‑time task.** Apply these principles from day one, and they'll become second nature. Keep your keys safe, your queries parameterized, and your permissions tight.

Stay safe!
