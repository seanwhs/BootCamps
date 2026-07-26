# PRIMER 4: JSON and Data Formats

## Welcome to the JSON Primer!

JSON (JavaScript Object Notation) is the universal language of web APIs. Every modern web application uses JSON to send and receive data between the client and server. Understanding JSON is essential for backend development with Node.js and Express.

### What This Primer Covers

| Section | Topic | What You'll Learn |
|---------|-------|-------------------|
| 1 | What Is JSON? | The basics of JSON syntax and structure |
| 2 | JSON vs JavaScript Objects | Key differences between JSON and JS objects |
| 3 | Working with JSON in Node.js | `JSON.parse()` and `JSON.stringify()` |
| 4 | Reading and Writing JSON Files | File-based JSON storage |
| 5 | Advanced JSON Features | Nested objects, arrays, edge cases |
| 6 | API Response Patterns | Common JSON response structures |
| 7 | JSON Schema Validation | Validating JSON data |
| 8 | Performance and Best Practices | Optimizing JSON operations |

---

## Section 1: What Is JSON?

**JSON** (JavaScript Object Notation) is a lightweight data format that's easy for humans to read and write, and easy for machines to parse and generate.

### Why JSON?

| Feature | Why It's Great |
|---------|----------------|
| **Human-readable** | Easy to understand and debug |
| **Language-independent** | Works with any programming language |
| **Lightweight** | Minimal overhead compared to XML |
| **JavaScript-native** | Built into Node.js and browsers |
| **Universal** | The standard for web APIs |

### Basic JSON Structure

JSON is built on two structures:

1. **Object** — A collection of key-value pairs (like a JavaScript object)
2. **Array** — An ordered list of values (like a JavaScript array)

### JSON Syntax Rules

```
┌─────────────────────────────────────────────────────────────┐
│                    JSON Syntax Rules                        │
├─────────────────────────────────────────────────────────────┤
│ ✓ Keys must be in double quotes ("key")                    │
│ ✓ Strings must be in double quotes ("value")               │
│ ✓ Numbers don't need quotes (42, 3.14, -10)               │
│ ✓ Booleans are true or false (no quotes)                  │
│ ✓ Null is null (no quotes)                                │
│ ✓ Objects use curly braces {}                             │
│ ✓ Arrays use square brackets []                           │
│ ✓ Use commas to separate items (but not after last item)  │
│ ✗ No trailing commas                                      │
│ ✗ No comments                                             │
│ ✗ No functions                                            │
│ ✗ No undefined                                            │
└─────────────────────────────────────────────────────────────┘
```

### JSON Examples

```json
// Simple object
{
    "name": "Alice",
    "age": 25,
    "isActive": true
}

// Array of objects
[
    {
        "name": "Alice",
        "age": 25
    },
    {
        "name": "Bob",
        "age": 30
    }
]

// Nested objects
{
    "user": {
        "name": "Alice",
        "address": {
            "street": "123 Main St",
            "city": "New York",
            "country": "USA"
        }
    }
}

// Mixed arrays
{
    "name": "Alice",
    "hobbies": ["reading", "swimming", "coding"],
    "scores": [95, 87, 92],
    "isActive": true
}

// Null values
{
    "name": "Alice",
    "phone": null,
    "email": "alice@example.com"
}
```

---

## Section 2: JSON vs JavaScript Objects

JSON is **based on** JavaScript object syntax, but they're not exactly the same.

### Key Differences

| Feature | JavaScript Object | JSON |
|---------|-------------------|------|
| **Keys** | Can be unquoted, single-quoted, or double-quoted | Must be double-quoted |
| **Strings** | Can be single-quoted or double-quoted | Must be double-quoted |
| **Functions** | ✅ Supported | ❌ Not supported |
| **Comments** | ✅ Supported | ❌ Not supported |
| **Trailing Commas** | ✅ Allowed | ❌ Not allowed |
| **undefined** | ✅ Supported | ❌ Not supported (use null) |
| **Date objects** | ✅ Supported | ❌ Not supported (use strings) |
| **Symbols** | ✅ Supported | ❌ Not supported |
| **BigInt** | ✅ Supported | ❌ Not supported |

### JavaScript Object vs JSON

```javascript
// JavaScript Object (valid JS syntax)
const user = {
    name: "Alice",              // Unquoted key
    age: 25,
    isActive: true,
    greet: function() {         // Function
        return "Hello!";
    },
    "last-name": "Smith",       // Quoted key (needed for special chars)
    comments: "This is valid",  // Trailing comma is allowed
};

// The same data as JSON (strict syntax)
{
    "name": "Alice",            // Keys must be quoted
    "age": 25,
    "isActive": true,
    "last-name": "Smith",
    "comments": "This is valid"
}
// ❌ No functions, no trailing commas
```

### Converting Between JSON and JavaScript Objects

```javascript
// JavaScript Object → JSON string
const user = {
    name: "Alice",
    age: 25,
    isActive: true
};

const jsonString = JSON.stringify(user);
console.log(jsonString);
// Output: {"name":"Alice","age":25,"isActive":true}

// JSON string → JavaScript Object
const jsonString = '{"name":"Alice","age":25,"isActive":true}';
const user = JSON.parse(jsonString);
console.log(user.name); // "Alice"
console.log(user.age); // 25
```

---

## Section 3: Working with JSON in Node.js

### JSON.parse() - Parsing JSON Strings

```javascript
// Basic parsing
const jsonString = '{"name":"Alice","age":25}';
const user = JSON.parse(jsonString);
console.log(user.name); // "Alice"

// Parsing arrays
const jsonArray = '[{"name":"Alice"},{"name":"Bob"}]';
const users = JSON.parse(jsonArray);
console.log(users[0].name); // "Alice"

// Parsing with nested objects
const jsonNested = '{"user":{"name":"Alice","address":{"city":"New York"}}}';
const data = JSON.parse(jsonNested);
console.log(data.user.address.city); // "New York"

// Error handling
try {
    const invalid = JSON.parse('{"name": "Alice"}'); // Missing closing brace
} catch (error) {
    console.error("Invalid JSON:", error.message);
}
```

### JSON.stringify() - Converting to JSON Strings

```javascript
// Basic conversion
const user = { name: "Alice", age: 25, isActive: true };
const jsonString = JSON.stringify(user);
console.log(jsonString);
// {"name":"Alice","age":25,"isActive":true}

// Pretty printing (with indentation)
const prettyJson = JSON.stringify(user, null, 2);
console.log(prettyJson);
// {
//   "name": "Alice",
//   "age": 25,
//   "isActive": true
// }

// Formatting with 4 spaces
const prettyJson4 = JSON.stringify(user, null, 4);

// Excluding specific fields
const userWithPassword = {
    name: "Alice",
    email: "alice@example.com",
    password: "secret123"
};

// Custom replacer function
const safeUser = JSON.stringify(userWithPassword, (key, value) => {
    if (key === "password") {
        return undefined; // Exclude password
    }
    return value;
});
console.log(safeUser);
// {"name":"Alice","email":"alice@example.com"}

// Using an array of allowed keys
const safeUser2 = JSON.stringify(userWithPassword, ["name", "email"]);
console.log(safeUser2);
// {"name":"Alice","email":"alice@example.com"}
```

### Handling Dates and Special Types

```javascript
// Dates become strings
const user = {
    name: "Alice",
    createdAt: new Date("2024-01-15T10:30:00Z")
};

const json = JSON.stringify(user);
console.log(json);
// {"name":"Alice","createdAt":"2024-01-15T10:30:00.000Z"}

// Reconstructing dates
const parsed = JSON.parse(json);
parsed.createdAt = new Date(parsed.createdAt);
console.log(parsed.createdAt.getFullYear()); // 2024

// Custom reviver function for JSON.parse
const jsonWithDates = '{"name":"Alice","createdAt":"2024-01-15T10:30:00.000Z"}';

const userWithDate = JSON.parse(jsonWithDates, (key, value) => {
    // Check if the value is a date string (in ISO format)
    if (key === "createdAt" && typeof value === "string") {
        return new Date(value);
    }
    return value;
});

console.log(userWithDate.createdAt instanceof Date); // true
```

### Safe Parsing with Fallbacks

```javascript
// Safe JSON parse with default value
function safeJsonParse(jsonString, defaultValue = null) {
    try {
        return JSON.parse(jsonString);
    } catch (error) {
        console.warn("Failed to parse JSON:", jsonString);
        return defaultValue;
    }
}

// Usage
const user = safeJsonParse('{"name":"Alice","age":25}', {});
console.log(user.name); // "Alice"

const invalid = safeJsonParse('{"name": "Alice"}', { fallback: true });
console.log(invalid); // { fallback: true }
```

---

## Section 4: Reading and Writing JSON Files

### Node.js File System Basics

```javascript
// Import the file system module
const fs = require('fs');
const path = require('path');

// Path to the JSON file
const filePath = path.join(__dirname, 'data.json');
```

### Reading JSON Files (Synchronous)

```javascript
const fs = require('fs');

try {
    // Read the file
    const data = fs.readFileSync('data.json', 'utf-8');
    
    // Parse the JSON
    const users = JSON.parse(data);
    
    console.log(`Loaded ${users.length} users`);
    console.log(users);
} catch (error) {
    if (error.code === 'ENOENT') {
        console.log('File not found, using default data');
    } else {
        console.error('Error reading file:', error);
    }
}
```

### Reading JSON Files (Asynchronous)

```javascript
const fs = require('fs');

// Using callbacks
fs.readFile('data.json', 'utf-8', (err, data) => {
    if (err) {
        console.error('Error reading file:', err);
        return;
    }
    
    try {
        const users = JSON.parse(data);
        console.log(`Loaded ${users.length} users`);
    } catch (parseError) {
        console.error('Error parsing JSON:', parseError);
    }
});

// Using Promises
const fs = require('fs').promises;

async function loadData() {
    try {
        const data = await fs.readFile('data.json', 'utf-8');
        const users = JSON.parse(data);
        console.log(`Loaded ${users.length} users`);
        return users;
    } catch (error) {
        console.error('Error loading data:', error);
        return [];
    }
}

// Using the function
loadData().then(users => {
    console.log('Users loaded:', users.length);
});
```

### Writing JSON Files

```javascript
const fs = require('fs');

const data = {
    users: [
        { id: 1, name: "Alice", email: "alice@example.com" },
        { id: 2, name: "Bob", email: "bob@example.com" }
    ]
};

// Synchronous write
try {
    const jsonString = JSON.stringify(data, null, 2);
    fs.writeFileSync('data.json', jsonString, 'utf-8');
    console.log('Data written successfully');
} catch (error) {
    console.error('Error writing file:', error);
}

// Asynchronous write with Promises
const fs = require('fs').promises;

async function writeData(data) {
    try {
        const jsonString = JSON.stringify(data, null, 2);
        await fs.writeFile('data.json', jsonString, 'utf-8');
        console.log('Data written successfully');
    } catch (error) {
        console.error('Error writing file:', error);
    }
}

writeData(data);
```

### Complete CRUD Operations for JSON Files

```javascript
// =====================================================
// FILE: json-storage.js
// DESCRIPTION: Complete JSON file storage utility
// =====================================================

const fs = require('fs').promises;
const path = require('path');

class JsonStorage {
    constructor(filename) {
        this.filename = filename;
        this.filePath = path.join(__dirname, filename);
    }

    // Read all data
    async read() {
        try {
            const data = await fs.readFile(this.filePath, 'utf-8');
            return JSON.parse(data);
        } catch (error) {
            if (error.code === 'ENOENT') {
                return [];
            }
            throw error;
        }
    }

    // Write data
    async write(data) {
        const jsonString = JSON.stringify(data, null, 2);
        await fs.writeFile(this.filePath, jsonString, 'utf-8');
    }

    // Create (add new item)
    async create(item) {
        const data = await this.read();
        // Generate ID
        const maxId = data.reduce((max, i) => Math.max(max, i.id || 0), 0);
        const newItem = { ...item, id: maxId + 1 };
        data.push(newItem);
        await this.write(data);
        return newItem;
    }

    // Read all
    async findAll() {
        return await this.read();
    }

    // Read one by ID
    async findById(id) {
        const data = await this.read();
        return data.find(item => item.id === id) || null;
    }

    // Update by ID
    async update(id, updates) {
        const data = await this.read();
        const index = data.findIndex(item => item.id === id);
        
        if (index === -1) {
            return null;
        }
        
        data[index] = { ...data[index], ...updates };
        await this.write(data);
        return data[index];
    }

    // Delete by ID
    async delete(id) {
        const data = await this.read();
        const index = data.findIndex(item => item.id === id);
        
        if (index === -1) {
            return false;
        }
        
        data.splice(index, 1);
        await this.write(data);
        return true;
    }

    // Search by field
    async findByField(field, value) {
        const data = await this.read();
        return data.filter(item => item[field] === value);
    }
}

// Usage
const storage = new JsonStorage('users.json');

// Create a user
async function example() {
    const newUser = await storage.create({
        name: "Alice",
        email: "alice@example.com",
        age: 25
    });
    console.log('Created:', newUser);

    // Find all users
    const users = await storage.findAll();
    console.log('All users:', users);

    // Find by ID
    const user = await storage.findById(1);
    console.log('User 1:', user);

    // Update
    const updated = await storage.update(1, { age: 26 });
    console.log('Updated:', updated);

    // Delete
    await storage.delete(1);
}

example();
```

---

## Section 5: Advanced JSON Features

### Nested Objects

```javascript
// Deeply nested JSON
const data = {
    user: {
        profile: {
            name: "Alice",
            address: {
                street: "123 Main St",
                city: "New York",
                country: {
                    name: "USA",
                    code: "US"
                }
            }
        }
    }
};

// Accessing nested values
console.log(data.user.profile.address.country.code); // "US"

// Using optional chaining for safety
console.log(data.user?.profile?.address?.street); // "123 Main St"
console.log(data.user?.profile?.phone?.number); // undefined (no error)
```

### Arrays of Objects

```javascript
const data = {
    users: [
        { id: 1, name: "Alice", age: 25 },
        { id: 2, name: "Bob", age: 30 },
        { id: 3, name: "Charlie", age: 35 }
    ]
};

// Finding in array
const alice = data.users.find(u => u.name === "Alice");
console.log(alice); // { id: 1, name: "Alice", age: 25 }

// Filtering
const over30 = data.users.filter(u => u.age > 30);
console.log(over30); // [{ id: 3, name: "Charlie", age: 35 }]

// Mapping
const names = data.users.map(u => u.name);
console.log(names); // ["Alice", "Bob", "Charlie"]
```

### Handling Special Characters

```javascript
// JSON with special characters
const data = {
    name: "Alice & Bob",
    description: "It's a great day!",
    html: "<div>Hello</div>",
    unicode: "🚀"
};

const jsonString = JSON.stringify(data);
console.log(jsonString);
// {"name":"Alice & Bob","description":"It's a great day!","html":"<div>Hello</div>","unicode":"🚀"}

// Parsing back
const parsed = JSON.parse(jsonString);
console.log(parsed.name); // "Alice & Bob"
console.log(parsed.unicode); // "🚀"
```

### JSON with Non-JSON Values

```javascript
// JavaScript values that don't exist in JSON
const data = {
    name: "Alice",
    age: 25,
    // Functions are not supported in JSON
    // greet: function() { return "Hello"; },
    
    // undefined becomes null in JSON
    optionalValue: undefined,
    
    // Symbols are not supported
    // id: Symbol("id"),
    
    // BigInt becomes a string
    bigNumber: 12345678901234567890n,
    
    // Date becomes a string
    createdAt: new Date()
};

const jsonString = JSON.stringify(data);
console.log(jsonString);
// {"name":"Alice","age":25,"optionalValue":null,"bigNumber":12345678901234567890,"createdAt":"2024-01-15T10:30:00.000Z"}
```

---

## Section 6: API Response Patterns

### Standard Success Response

```javascript
// Single item
{
    "success": true,
    "data": {
        "id": 1,
        "name": "Alice",
        "email": "alice@example.com"
    }
}

// Collection
{
    "success": true,
    "data": [
        { "id": 1, "name": "Alice" },
        { "id": 2, "name": "Bob" }
    ],
    "count": 2
}

// Paginated response
{
    "success": true,
    "data": [
        { "id": 1, "name": "Alice" },
        { "id": 2, "name": "Bob" }
    ],
    "pagination": {
        "page": 1,
        "limit": 10,
        "total": 42,
        "totalPages": 5,
        "next": "/api/users?page=2&limit=10",
        "prev": null
    }
}
```

### Standard Error Response

```javascript
// Simple error
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Invalid email format",
        "status": 400
    }
}

// Multiple errors
{
    "success": false,
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Validation failed",
        "details": [
            { "field": "email", "message": "Email is required" },
            { "field": "password", "message": "Password must be at least 8 characters" }
        ],
        "status": 400
    }
}

// Not found
{
    "success": false,
    "error": {
        "code": "NOT_FOUND",
        "message": "User with ID 123 not found",
        "status": 404
    }
}
```

### Creating Response Helpers

```javascript
// Response helper functions
const ResponseHelper = {
    // Success responses
    success(data, message = 'Success', status = 200) {
        return {
            success: true,
            message,
            data,
            timestamp: new Date().toISOString()
        };
    },

    // Created response
    created(data, message = 'Created') {
        return this.success(data, message, 201);
    },

    // Paginated response
    paginated(data, pagination) {
        return {
            success: true,
            data,
            pagination: {
                page: pagination.page || 1,
                limit: pagination.limit || 10,
                total: pagination.total || 0,
                totalPages: Math.ceil((pagination.total || 0) / (pagination.limit || 10))
            },
            timestamp: new Date().toISOString()
        };
    },

    // Error responses
    error(message, code = 'ERROR', status = 500, details = null) {
        const response = {
            success: false,
            error: {
                code,
                message,
                status
            },
            timestamp: new Date().toISOString()
        };

        if (details) {
            response.error.details = details;
        }

        return response;
    },

    // Validation error
    validationError(details) {
        return this.error('Validation failed', 'VALIDATION_ERROR', 400, details);
    },

    // Not found
    notFound(resource = 'Resource') {
        return this.error(`${resource} not found`, 'NOT_FOUND', 404);
    },

    // Unauthorized
    unauthorized(message = 'Authentication required') {
        return this.error(message, 'UNAUTHORIZED', 401);
    },

    // Forbidden
    forbidden(message = 'Insufficient permissions') {
        return this.error(message, 'FORBIDDEN', 403);
    }
};

// Usage in Express
app.get('/api/users', (req, res) => {
    const users = [{ id: 1, name: 'Alice' }];
    res.json(ResponseHelper.success(users, 'Users retrieved successfully'));
});

app.post('/api/users', (req, res) => {
    // ... create user
    res.status(201).json(ResponseHelper.created(newUser));
});

app.get('/api/users/:id', (req, res) => {
    const user = findUser(req.params.id);
    if (!user) {
        return res.status(404).json(ResponseHelper.notFound('User'));
    }
    res.json(ResponseHelper.success(user));
});
```

---

## Section 7: JSON Schema Validation

### What is JSON Schema?

JSON Schema is a vocabulary that allows you to validate JSON data structure and content.

### Simple JSON Schema

```javascript
const userSchema = {
    type: "object",
    required: ["name", "email", "password"],
    properties: {
        name: {
            type: "string",
            minLength: 2,
            maxLength: 50
        },
        email: {
            type: "string",
            format: "email"
        },
        password: {
            type: "string",
            minLength: 8
        },
        age: {
            type: "integer",
            minimum: 18,
            maximum: 120
        },
        isActive: {
            type: "boolean"
        },
        hobbies: {
            type: "array",
            items: {
                type: "string"
            },
            minItems: 0,
            maxItems: 10
        }
    }
};
```

### Using Ajv (Another JSON Schema Validator)

```bash
npm install ajv
```

```javascript
// Validation with Ajv
const Ajv = require('ajv');
const ajv = new Ajv({ allErrors: true });

const userSchema = {
    type: "object",
    required: ["name", "email", "password"],
    properties: {
        name: {
            type: "string",
            minLength: 2,
            maxLength: 50
        },
        email: {
            type: "string",
            format: "email"
        },
        password: {
            type: "string",
            minLength: 8
        },
        age: {
            type: "integer",
            minimum: 18,
            maximum: 120
        }
    }
};

// Validate function
const validateUser = ajv.compile(userSchema);

// Test validation
const validUser = {
    name: "Alice",
    email: "alice@example.com",
    password: "secret123",
    age: 25
};

const invalidUser = {
    name: "A", // Too short
    email: "invalid-email",
    password: "short"
};

// Validate
console.log(validateUser(validUser)); // true
console.log(validateUser(invalidUser)); // false
console.log(validateUser.errors); // Array of error details
```

### Custom Validators

```javascript
// Simple validation without schema
function validateUser(user) {
    const errors = [];

    if (!user.name || user.name.length < 2) {
        errors.push({
            field: 'name',
            message: 'Name must be at least 2 characters'
        });
    }

    if (user.name && user.name.length > 50) {
        errors.push({
            field: 'name',
            message: 'Name must be at most 50 characters'
        });
    }

    if (!user.email) {
        errors.push({
            field: 'email',
            message: 'Email is required'
        });
    }

    if (user.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user.email)) {
        errors.push({
            field: 'email',
            message: 'Invalid email format'
        });
    }

    if (user.password && user.password.length < 8) {
        errors.push({
            field: 'password',
            message: 'Password must be at least 8 characters'
        });
    }

    if (user.age && (user.age < 18 || user.age > 120)) {
        errors.push({
            field: 'age',
            message: 'Age must be between 18 and 120'
        });
    }

    return {
        valid: errors.length === 0,
        errors
    };
}

// Usage
const result = validateUser(invalidUser);
if (!result.valid) {
    console.log('Validation errors:', result.errors);
}
```

---

## Section 8: Performance and Best Practices

### Performance Tips

```javascript
// 1. Use reviver functions for large datasets
const data = JSON.parse(largeJsonString, (key, value) => {
    if (key === 'createdAt') {
        return new Date(value);
    }
    return value;
});

// 2. Use replacer functions to remove unnecessary data
const safeData = JSON.stringify(largeData, (key, value) => {
    if (key === 'password' || key === 'token') {
        return undefined;
    }
    return value;
});

// 3. Use Buffer for faster serialization
const buffer = Buffer.from(JSON.stringify(data));

// 4. Stream large JSON files
const fs = require('fs');
const readline = require('readline');

async function processLargeJSON(filename) {
    const rl = readline.createInterface({
        input: fs.createReadStream(filename),
        crlfDelay: Infinity
    });

    for await (const line of rl) {
        // Process line by line (for NDJSON format)
        const data = JSON.parse(line);
        // Handle each item...
    }
}
```

### Best Practices

#### 1. Always Validate JSON Before Using

```javascript
function safeParseJSON(str) {
    try {
        return JSON.parse(str);
    } catch (e) {
        console.error('Invalid JSON:', str);
        return null;
    }
}

// Or using a validation library
const isValidJSON = (str) => {
    try {
        JSON.parse(str);
        return true;
    } catch {
        return false;
    }
};
```

#### 2. Use Pretty Printing in Development

```javascript
const isDevelopment = process.env.NODE_ENV === 'development';
const jsonString = JSON.stringify(data, null, isDevelopment ? 2 : 0);
```

#### 3. Handle Circular References

```javascript
const data = { name: 'Alice' };
data.self = data; // Circular reference

// This would throw an error
// JSON.stringify(data);

// Use a replacer to handle circular references
function safeStringify(obj) {
    const seen = new WeakSet();
    return JSON.stringify(obj, (key, value) => {
        if (typeof value === 'object' && value !== null) {
            if (seen.has(value)) {
                return '[Circular]';
            }
            seen.add(value);
        }
        return value;
    });
}

console.log(safeStringify(data));
// {"name":"Alice","self":"[Circular]"}
```

#### 4. Use Date Handling Utilities

```javascript
// Custom reviver for dates
function parseJSONWithDates(jsonString) {
    const datePattern = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/;
    
    return JSON.parse(jsonString, (key, value) => {
        if (typeof value === 'string' && datePattern.test(value)) {
            return new Date(value);
        }
        return value;
    });
}

// Custom stringifier for dates
function stringifyWithDates(obj) {
    return JSON.stringify(obj, (key, value) => {
        if (value instanceof Date) {
            return value.toISOString();
        }
        return value;
    });
}
```

#### 5. Compress Large JSON Payloads

```javascript
const zlib = require('zlib');

// Compress JSON
const jsonString = JSON.stringify(largeData);
const compressed = zlib.gzipSync(jsonString);
// Send compressed to client (with Content-Encoding: gzip)

// Decompress JSON (in Express with compression middleware)
app.use(require('compression')());
```

---

## Practice Exercises

### Exercise 1: JSON Parser

```javascript
// Write a function that parses JSON and handles common errors
// Return { valid: true, data: parsedData } or { valid: false, error: message }

function safeParse(jsonString) {
    // Your code here
}

// Test
console.log(safeParse('{"name":"Alice"}')); // { valid: true, data: { name: 'Alice' } }
console.log(safeParse('{"name": "Alice"}')); // { valid: false, error: ... }
```

### Exercise 2: JSON Schema Validator

```javascript
// Create a validator for a task object
// Requirements: title (required, string, min 1), completed (boolean), priority (low/medium/high)

const taskSchema = {
    // Define your schema here
};

function validateTask(task) {
    // Your code here
    // Return { valid: boolean, errors: [] }
}

// Test
const validTask = { title: 'Learn JSON', priority: 'high' };
const invalidTask = { title: '', priority: 'urgent' };

console.log(validateTask(validTask)); // { valid: true, errors: [] }
console.log(validateTask(invalidTask)); // { valid: false, errors: [...] }
```

### Exercise 3: JSON File Manager

```javascript
// Create a class that manages a JSON file
// Methods: read(), write(), getById(), create(), update(), delete()

class JsonFileManager {
    constructor(filename) {
        // Your code here
    }
    
    async read() {
        // Your code here
    }
    
    async write(data) {
        // Your code here
    }
    
    async getById(id) {
        // Your code here
    }
    
    async create(item) {
        // Your code here
    }
    
    async update(id, updates) {
        // Your code here
    }
    
    async delete(id) {
        // Your code here
    }
}

// Test
const manager = new JsonFileManager('tasks.json');
await manager.create({ title: 'Learn JSON' });
const tasks = await manager.findAll();
console.log(tasks);
```

### Exercise 4: API Response Formatter

```javascript
// Create a response formatter that handles:
// - Success responses
// - Paginated responses
// - Error responses
// - Validation error responses

class ResponseFormatter {
    // Your code here
}

// Usage
const formatter = new ResponseFormatter();
res.json(formatter.success({ name: 'Alice' }));
res.json(formatter.paginated(users, { page: 1, limit: 10, total: 42 }));
res.json(formatter.error('Not found', 404));
```

---

## Summary

You now have a comprehensive understanding of JSON and working with it in Node.js:

| Topic | Key Concepts |
|-------|--------------|
| **JSON Basics** | Objects, arrays, key-value pairs, syntax rules |
| **JS vs JSON** | Differences and conversions |
| **Parsing** | `JSON.parse()`, error handling, reviver functions |
| **Stringifying** | `JSON.stringify()`, replacer functions, pretty printing |
| **File Storage** | Reading/writing JSON files, CRUD operations |
| **API Patterns** | Standard response formats, error handling |
| **Validation** | JSON Schema, Ajv, custom validators |
| **Best Practices** | Performance, security, error handling |
