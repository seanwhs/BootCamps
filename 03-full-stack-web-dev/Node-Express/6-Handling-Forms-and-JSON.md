# Part 6: Handling Forms and JSON

Welcome to Part 6! In Part 5, we mastered middleware and learned how it powers Express applications. Now we're going to focus on one of the most common tasks in web development: **handling user input**.

Users interact with your application by submitting forms, sending JSON data, uploading files, and more. In this part, you'll learn how to receive, validate, and process all types of user input.

By the end of this part, you'll understand:
- How to process form submissions (URL-encoded data)
- How to handle JSON requests (REST APIs)
- How to validate user input
- How to manage file uploads
- How to build a complete feature that accepts user input

---

## Types of User Input

When users interact with web applications, they send data in various formats:

| Format | Content-Type | When Used | Example |
|--------|--------------|-----------|---------|
| **URL-encoded** | `application/x-www-form-urlencoded` | HTML forms (default) | `name=Alice&email=alice@example.com` |
| **JSON** | `application/json` | REST APIs, JavaScript fetch | `{"name":"Alice","email":"alice@example.com"}` |
| **Multipart form** | `multipart/form-data` | File uploads | Binary data with boundary separators |
| **Text** | `text/plain` | Plain text submissions | `Hello world!` |
| **Raw** | Various | Custom formats | XML, CSV, etc. |

---

## Processing URL-Encoded Form Data

HTML forms use `application/x-www-form-urlencoded` by default. Express provides middleware to parse this format.

### Basic Form Handling

Create a new file called `server-forms.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-forms.js
// DESCRIPTION: Handling form submissions
// =====================================================

const express = require('express');
const app = express();
const PORT = 3000;

// =====================================================
// MIDDLEWARE SETUP
// =====================================================

// 1. Parse URL-encoded form data (HTML forms)
// extended: true allows parsing of nested objects
app.use(express.urlencoded({ extended: true }));

// 2. Parse JSON data (for API requests)
app.use(express.json());

// 3. Serve static files (CSS, images, etc.)
app.use(express.static('public'));

// =====================================================
// STORAGE (in-memory for demo)
// =====================================================

let users = [
    { id: 1, name: 'Alice', email: 'alice@example.com', age: 25 },
    { id: 2, name: 'Bob', email: 'bob@example.com', age: 30 },
];

// =====================================================
// ROUTES - HTML FORMS
// =====================================================

// 1. Display the form
app.get('/form', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>User Form</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; }
                .form-group { margin-bottom: 15px; }
                label { display: block; margin-bottom: 5px; font-weight: bold; }
                input, select { width: 100%; padding: 8px; box-sizing: border-box; border: 1px solid #ddd; border-radius: 4px; }
                button { padding: 10px 20px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; }
                button:hover { background: #2980b9; }
                .error { color: #e74c3c; font-size: 14px; }
                .success { color: #2ecc71; font-size: 14px; }
                .user-list { margin-top: 30px; }
                .user-item { background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 4px; }
            </style>
        </head>
        <body>
            <h1>📝 Add New User</h1>
            
            <!-- The form submits to /form using POST -->
            <form action="/form" method="POST">
                <div class="form-group">
                    <label for="name">Name:</label>
                    <input type="text" id="name" name="name" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" id="email" name="email" required>
                </div>
                
                <div class="form-group">
                    <label for="age">Age:</label>
                    <input type="number" id="age" name="age" min="1" max="150">
                </div>
                
                <div class="form-group">
                    <label for="role">Role:</label>
                    <select id="role" name="role">
                        <option value="user">User</option>
                        <option value="admin">Admin</option>
                        <option value="guest">Guest</option>
                    </select>
                </div>
                
                <button type="submit">Add User</button>
            </form>
            
            <div class="user-list">
                <h2>📋 Existing Users</h2>
                ${users.map(user => `
                    <div class="user-item">
                        <strong>${user.name}</strong> 
                        (${user.email}) 
                        ${user.age ? `- Age: ${user.age}` : ''}
                        ${user.role ? `- Role: ${user.role}` : ''}
                    </div>
                `).join('')}
            </div>
        </body>
        </html>
    `);
});

// 2. Handle the form submission
app.post('/form', (req, res) => {
    // req.body contains the parsed form data
    const { name, email, age, role } = req.body;
    
    console.log('📨 Form data received:', { name, email, age, role });
    
    // Create new user
    const newUser = {
        id: users.length + 1,
        name: name.trim(),
        email: email.trim(),
        age: age ? parseInt(age) : undefined,
        role: role || 'user'
    };
    
    users.push(newUser);
    
    console.log('✅ User added:', newUser);
    
    // Redirect to the form page to show the updated list
    // 303 See Other: Redirect with GET
    res.redirect(303, '/form');
});

// 3. Form with validation and error handling
app.get('/form-advanced', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Advanced Form</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; }
                .form-group { margin-bottom: 15px; }
                label { display: block; margin-bottom: 5px; font-weight: bold; }
                input, textarea, select { width: 100%; padding: 8px; box-sizing: border-box; border: 1px solid #ddd; border-radius: 4px; }
                textarea { resize: vertical; }
                button { padding: 10px 20px; background: #2ecc71; color: white; border: none; border-radius: 4px; cursor: pointer; }
                button:hover { background: #27ae60; }
                .error { color: #e74c3c; font-size: 14px; padding: 10px; background: #fdf0ef; border-radius: 4px; }
                .success { color: #2ecc71; font-size: 14px; padding: 10px; background: #f0fdf0; border-radius: 4px; }
            </style>
        </head>
        <body>
            <h1>✉️ Contact Form</h1>
            
            <form action="/form-advanced" method="POST">
                <div class="form-group">
                    <label for="name">Name *</label>
                    <input type="text" id="name" name="name">
                </div>
                
                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email">
                </div>
                
                <div class="form-group">
                    <label for="subject">Subject *</label>
                    <input type="text" id="subject" name="subject">
                </div>
                
                <div class="form-group">
                    <label for="message">Message *</label>
                    <textarea id="message" name="message" rows="5"></textarea>
                </div>
                
                <button type="submit">Send Message</button>
            </form>
            
            <p><a href="/form">← Back to User Form</a></p>
        </body>
        </html>
    `);
});

// Handle advanced form with validation
app.post('/form-advanced', (req, res) => {
    const { name, email, subject, message } = req.body;
    
    // Validation
    const errors = [];
    
    if (!name || name.trim() === '') {
        errors.push('Name is required');
    }
    
    if (!email || !email.includes('@')) {
        errors.push('Valid email is required');
    }
    
    if (!subject || subject.trim() === '') {
        errors.push('Subject is required');
    }
    
    if (!message || message.trim().length < 10) {
        errors.push('Message must be at least 10 characters');
    }
    
    // If there are errors, return the form with error messages
    if (errors.length > 0) {
        return res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Form Errors</title>
                <style>
                    body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; }
                    .error { color: #e74c3c; font-size: 14px; padding: 10px; background: #fdf0ef; border-radius: 4px; margin: 5px 0; }
                </style>
            </head>
            <body>
                <h1>❌ Validation Errors</h1>
                ${errors.map(err => `<div class="error">${err}</div>`).join('')}
                <p><a href="/form-advanced">← Go Back</a></p>
            </body>
            </html>
        `);
    }
    
    // Success - store the message
    console.log('✅ Message received:', { name, email, subject, message });
    
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Success</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; text-align: center; }
                .success { color: #2ecc71; font-size: 20px; padding: 20px; background: #f0fdf0; border-radius: 4px; }
            </style>
        </head>
        <body>
            <div class="success">
                ✅ Message sent successfully!
            </div>
            <p><a href="/form-advanced">← Send Another</a></p>
        </body>
        </html>
    `);
});

// =====================================================
// ROUTES - JSON API
// =====================================================

// 1. POST /api/users - Create a user via JSON
app.post('/api/users', (req, res) => {
    const { name, email, age } = req.body;
    
    // Validation
    if (!name || name.trim() === '') {
        return res.status(400).json({
            success: false,
            error: 'Name is required'
        });
    }
    
    if (!email || !email.includes('@')) {
        return res.status(400).json({
            success: false,
            error: 'Valid email is required'
        });
    }
    
    // Create user
    const newUser = {
        id: users.length + 1,
        name: name.trim(),
        email: email.trim(),
        age: age ? parseInt(age) : undefined,
        createdAt: new Date().toISOString()
    };
    
    users.push(newUser);
    
    res.status(201).json({
        success: true,
        message: 'User created successfully',
        data: newUser
    });
});

// 2. POST /api/contact - Contact form API
app.post('/api/contact', (req, res) => {
    const { name, email, subject, message } = req.body;
    
    // Validation
    const errors = [];
    if (!name) errors.push('Name required');
    if (!email || !email.includes('@')) errors.push('Valid email required');
    if (!subject) errors.push('Subject required');
    if (!message || message.length < 10) errors.push('Message must be at least 10 characters');
    
    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            errors: errors
        });
    }
    
    // Process the message...
    console.log('📨 Contact message:', { name, email, subject, message });
    
    res.json({
        success: true,
        message: 'Message sent successfully',
        data: {
            name,
            email,
            subject,
            messageLength: message.length,
            timestamp: new Date().toISOString()
        }
    });
});

// =====================================================
// ROUTE - Multiple input formats
// =====================================================

// This route accepts both form data and JSON
app.post('/api/echo', (req, res) => {
    // req.body works for both JSON and URL-encoded data
    console.log('📨 Echo request:', req.body);
    
    res.json({
        success: true,
        received: req.body,
        contentType: req.headers['content-type'],
        timestamp: new Date().toISOString()
    });
});

// =====================================================
// START THE SERVER
// =====================================================

app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Forms and JSON Demo Server`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available forms:`);
    console.log(`   GET  /form              - User form (HTML)`);
    console.log(`   POST /form              - Submit user form`);
    console.log(`   GET  /form-advanced     - Contact form (HTML)`);
    console.log(`   POST /form-advanced     - Submit contact form`);
    console.log(`📋 API endpoints:`);
    console.log(`   POST /api/users         - Create user (JSON)`);
    console.log(`   POST /api/contact       - Contact form (JSON)`);
    console.log(`   POST /api/echo          - Echo input (both formats)`);
    console.log(`===================================`);
});
```

Run this server:

```bash
node server-forms.js
```

Now test it:

1. Open http://localhost:3000/form in your browser
2. Fill out and submit the form
3. See the user added to the list

Test the API:

```bash
# Test JSON API
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Charlie","email":"charlie@example.com","age":28}'

# Test form data (URL-encoded)
curl -X POST http://localhost:3000/api/echo \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d 'name=Test&email=test@example.com&message=Hello%20World'

# Test with validation errors
curl -X POST http://localhost:3000/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"Test"}'
```

---

## Handling File Uploads

File uploads require a different approach because they use `multipart/form-data`. We'll use the `multer` middleware, which is the most popular file upload handler for Express.

### Installing Multer

```bash
npm install multer
```

### Basic File Upload

Create `server-uploads.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-uploads.js
// DESCRIPTION: Handling file uploads with Multer
// =====================================================

const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

// =====================================================
// CONFIGURE MULTER
// =====================================================

// Create upload directory if it doesn't exist
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
    console.log('📁 Created uploads directory');
}

// 1. Configure storage
const storage = multer.diskStorage({
    // Where to save files
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    // What to name the file
    filename: (req, file, cb) => {
        // Create unique filename: timestamp-randomname.extension
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const extension = path.extname(file.originalname);
        cb(null, file.fieldname + '-' + uniqueSuffix + extension);
    }
});

// 2. Configure file filter (optional)
const fileFilter = (req, file, cb) => {
    // Allow only images and PDFs
    const allowedTypes = /jpeg|jpg|png|gif|pdf/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
        return cb(null, true);
    } else {
        cb(new Error('Only images and PDFs are allowed'));
    }
};

// 3. Create multer instance
const upload = multer({
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB limit
    },
    fileFilter: fileFilter
});

// =====================================================
// ROUTES
// =====================================================

// 1. Upload form
app.get('/upload', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>File Upload</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; }
                .form-group { margin-bottom: 15px; }
                label { display: block; margin-bottom: 5px; font-weight: bold; }
                input[type="file"] { display: block; margin: 10px 0; }
                button { padding: 10px 20px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; }
                button:hover { background: #2980b9; }
                .file-list { margin-top: 30px; }
                .file-item { background: #f8f9fa; padding: 10px; margin: 5px 0; border-radius: 4px; }
            </style>
        </head>
        <body>
            <h1>📁 Upload a File</h1>
            
            <form action="/upload" method="POST" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="name">File Description:</label>
                    <input type="text" id="name" name="description" placeholder="Describe your file">
                </div>
                
                <div class="form-group">
                    <label for="file">Choose File:</label>
                    <input type="file" id="file" name="file" required>
                </div>
                
                <button type="submit">Upload</button>
            </form>
            
            <div class="file-list">
                <h2>📋 Uploaded Files</h2>
                ${getFileList()}
            </div>
            
            <p><a href="/">← Home</a></p>
        </body>
        </html>
    `);
});

// Helper to get list of uploaded files
function getFileList() {
    try {
        const files = fs.readdirSync(uploadDir);
        if (files.length === 0) {
            return '<p>No files uploaded yet.</p>';
        }
        return files.map(file => `
            <div class="file-item">
                <strong>${file}</strong>
                <br>
                <small>${(fs.statSync(path.join(uploadDir, file)).size / 1024).toFixed(2)} KB</small>
            </div>
        `).join('');
    } catch (error) {
        return '<p>Error reading files</p>';
    }
}

// 2. Handle single file upload
app.post('/upload', upload.single('file'), (req, res) => {
    // req.file contains the uploaded file info
    // req.body contains text fields
    console.log('📨 Upload received:');
    console.log('  File:', req.file);
    console.log('  Body:', req.body);
    
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Upload Success</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 500px; margin: 50px auto; padding: 20px; }
                .success { padding: 20px; background: #f0fdf0; border-radius: 4px; text-align: center; }
                .details { background: #f8f9fa; padding: 15px; border-radius: 4px; margin: 20px 0; }
            </style>
        </head>
        <body>
            <div class="success">
                ✅ File uploaded successfully!
            </div>
            
            <div class="details">
                <h3>File Details</h3>
                <p><strong>Original name:</strong> ${req.file.originalname}</p>
                <p><strong>Saved as:</strong> ${req.file.filename}</p>
                <p><strong>Size:</strong> ${(req.file.size / 1024).toFixed(2)} KB</p>
                <p><strong>Description:</strong> ${req.body.description || 'No description'}</p>
            </div>
            
            <p><a href="/upload">← Upload Another</a></p>
        </body>
        </html>
    `);
}, (error, req, res, next) => {
    // Error handling for multer
    if (error instanceof multer.MulterError) {
        if (error.code === 'FILE_TOO_LARGE') {
            return res.status(400).send('File too large. Maximum size is 5MB.');
        }
        return res.status(400).send(`Upload error: ${error.message}`);
    }
    res.status(400).send(`Error: ${error.message}`);
});

// 3. Handle multiple file uploads
app.post('/upload-multiple', upload.array('files', 5), (req, res) => {
    // req.files is an array of uploaded files
    console.log('📨 Multiple uploads received:', req.files.length);
    
    const fileDetails = req.files.map(file => ({
        originalName: file.originalname,
        savedAs: file.filename,
        size: file.size
    }));
    
    res.json({
        success: true,
        message: `${req.files.length} files uploaded`,
        files: fileDetails
    });
});

// 4. API endpoint for file upload
app.post('/api/upload', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({
            success: false,
            error: 'No file uploaded'
        });
    }
    
    res.json({
        success: true,
        message: 'File uploaded successfully',
        data: {
            originalName: req.file.originalname,
            filename: req.file.filename,
            size: req.file.size,
            description: req.body.description || null,
            url: `/uploads/${req.file.filename}`
        }
    });
});

// 5. Serve uploaded files
app.use('/uploads', express.static(uploadDir));

// =====================================================
// START THE SERVER
// =====================================================

app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ File Upload Demo Server`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available routes:`);
    console.log(`   GET  /upload              - Upload form`);
    console.log(`   POST /upload              - Upload single file`);
    console.log(`   POST /upload-multiple     - Upload multiple files`);
    console.log(`   POST /api/upload          - Upload via API`);
    console.log(`   GET  /uploads/*           - View uploaded files`);
    console.log(`📁 Upload directory: ${uploadDir}`);
    console.log(`===================================`);
});
```

Run this server:

```bash
node server-uploads.js
```

Test it:

1. Open http://localhost:3000/upload in your browser
2. Upload a file
3. See the file appear in the list

Test the API:

```bash
# Create a test file
echo "Hello World" > test.txt

# Upload via API
curl -X POST http://localhost:3000/api/upload \
  -F "file=@test.txt" \
  -F "description=Test file"
```

---

## Data Validation Deep Dive

Validating user input is critical for security and data integrity. Let's build a robust validation system.

### Manual Validation

```javascript
// Basic validation functions
const validators = {
    required: (value) => value && value.trim() !== '',
    email: (value) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value),
    minLength: (min) => (value) => value && value.length >= min,
    maxLength: (max) => (value) => value && value.length <= max,
    numeric: (value) => !isNaN(value) && value !== '',
    min: (min) => (value) => value && parseFloat(value) >= min,
    max: (max) => (value) => value && parseFloat(value) <= max
};

// Validation middleware
const validate = (rules) => {
    return (req, res, next) => {
        const errors = {};
        
        for (const [field, fieldRules] of Object.entries(rules)) {
            const value = req.body[field];
            const fieldErrors = [];
            
            for (const [rule, params] of Object.entries(fieldRules)) {
                let isValid = true;
                
                switch (rule) {
                    case 'required':
                        if (!validators.required(value)) {
                            fieldErrors.push(`${field} is required`);
                        }
                        break;
                    case 'email':
                        if (value && !validators.email(value)) {
                            fieldErrors.push(`${field} must be a valid email`);
                        }
                        break;
                    case 'minLength':
                        if (value && !validators.minLength(params)(value)) {
                            fieldErrors.push(`${field} must be at least ${params} characters`);
                        }
                        break;
                    case 'maxLength':
                        if (value && !validators.maxLength(params)(value)) {
                            fieldErrors.push(`${field} must be at most ${params} characters`);
                        }
                        break;
                    case 'numeric':
                        if (value && !validators.numeric(value)) {
                            fieldErrors.push(`${field} must be a number`);
                        }
                        break;
                    case 'min':
                        if (value && !validators.min(params)(value)) {
                            fieldErrors.push(`${field} must be at least ${params}`);
                        }
                        break;
                    case 'max':
                        if (value && !validators.max(params)(value)) {
                            fieldErrors.push(`${field} must be at most ${params}`);
                        }
                        break;
                }
            }
            
            if (fieldErrors.length > 0) {
                errors[field] = fieldErrors;
            }
        }
        
        if (Object.keys(errors).length > 0) {
            return res.status(400).json({
                success: false,
                errors: errors
            });
        }
        
        next();
    };
};

// Usage:
app.post('/api/register', 
    validate({
        name: { required: true, minLength: 2, maxLength: 50 },
        email: { required: true, email: true },
        password: { required: true, minLength: 8 },
        age: { numeric: true, min: 18, max: 100 }
    }),
    (req, res) => {
        // Validated data is in req.body
        res.json({ success: true, data: req.body });
    }
);
```

### Using Joi for Validation

Joi is a popular validation library that provides a clean API:

```bash
npm install joi
```

```javascript
const Joi = require('joi');

// Define a schema
const userSchema = Joi.object({
    name: Joi.string().min(2).max(50).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
    age: Joi.number().integer().min(18).max(100),
    role: Joi.string().valid('user', 'admin', 'guest').default('user')
});

// Validation middleware
const validateWithJoi = (schema) => {
    return (req, res, next) => {
        const { error, value } = schema.validate(req.body, {
            abortEarly: false, // Return all errors, not just the first
            stripUnknown: true // Remove unknown fields
        });
        
        if (error) {
            const errors = error.details.map(detail => ({
                field: detail.path[0],
                message: detail.message
            }));
            
            return res.status(400).json({
                success: false,
                errors: errors
            });
        }
        
        // Replace req.body with validated and cleaned data
        req.body = value;
        next();
    };
};

// Usage:
app.post('/api/register', validateWithJoi(userSchema), (req, res) => {
    res.json({ success: true, data: req.body });
});
```

---

## Building a Complete Feature: User Registration

Let's combine everything we've learned into a complete user registration feature.

Create `server-registration.js`:

```javascript
// =====================================================
// FILE: /node-express-tutorial/server-registration.js
// DESCRIPTION: Complete user registration with forms, validation, and API
// =====================================================

const express = require('express');
const Joi = require('joi');
const bcrypt = require('bcryptjs');
const app = express();
const PORT = 3000;

// Middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// =====================================================
// STORAGE
// =====================================================

const users = [
    { id: 1, name: 'Alice', email: 'alice@example.com', password: 'hashed_password_1', role: 'admin' },
];

// =====================================================
// VALIDATION SCHEMA
// =====================================================

const registrationSchema = Joi.object({
    name: Joi.string().min(2).max(50).required()
        .messages({
            'string.min': 'Name must be at least 2 characters',
            'string.max': 'Name must be at most 50 characters',
            'any.required': 'Name is required'
        }),
    email: Joi.string().email().required()
        .messages({
            'string.email': 'Please provide a valid email address',
            'any.required': 'Email is required'
        }),
    password: Joi.string().min(8).required()
        .messages({
            'string.min': 'Password must be at least 8 characters',
            'any.required': 'Password is required'
        }),
    confirmPassword: Joi.string().valid(Joi.ref('password')).required()
        .messages({
            'any.only': 'Passwords do not match',
            'any.required': 'Please confirm your password'
        }),
    age: Joi.number().integer().min(18).max(120).optional(),
    role: Joi.string().valid('user', 'admin', 'guest').default('user')
});

// =====================================================
// MIDDLEWARE
// =====================================================

// Check if email is already taken
const checkDuplicateEmail = async (req, res, next) => {
    const { email } = req.body;
    const existingUser = users.find(u => u.email === email);
    
    if (existingUser) {
        return res.status(400).json({
            success: false,
            error: 'Email already registered'
        });
    }
    
    next();
};

// =====================================================
// ROUTES
// =====================================================

// 1. Registration form
app.get('/register', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Register</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 400px; margin: 50px auto; padding: 20px; }
                .form-group { margin-bottom: 15px; }
                label { display: block; margin-bottom: 5px; font-weight: bold; }
                input { width: 100%; padding: 8px; box-sizing: border-box; border: 1px solid #ddd; border-radius: 4px; }
                button { width: 100%; padding: 10px; background: #3498db; color: white; border: none; border-radius: 4px; cursor: pointer; }
                button:hover { background: #2980b9; }
                .error { color: #e74c3c; font-size: 14px; margin-top: 5px; }
            </style>
        </head>
        <body>
            <h1>📝 Register</h1>
            
            <form action="/register" method="POST">
                <div class="form-group">
                    <label for="name">Name:</label>
                    <input type="text" id="name" name="name" required>
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" id="email" name="email" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password:</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password:</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required>
                </div>
                
                <div class="form-group">
                    <label for="age">Age (optional):</label>
                    <input type="number" id="age" name="age" min="18" max="120">
                </div>
                
                <button type="submit">Register</button>
            </form>
            
            <p style="text-align: center; margin-top: 20px;">
                <a href="/api/users">API Users</a>
            </p>
        </body>
        </html>
    `);
});

// 2. Handle registration form submission
app.post('/register', async (req, res) => {
    try {
        // Validate with Joi
        const { error, value } = registrationSchema.validate(req.body, {
            abortEarly: false
        });
        
        if (error) {
            const errors = error.details.map(d => d.message);
            return res.send(`
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Registration Errors</title>
                    <style>
                        body { font-family: Arial, sans-serif; max-width: 400px; margin: 50px auto; padding: 20px; }
                        .error { color: #e74c3c; padding: 10px; background: #fdf0ef; border-radius: 4px; margin: 5px 0; }
                    </style>
                </head>
                <body>
                    <h1>❌ Validation Errors</h1>
                    ${errors.map(err => `<div class="error">${err}</div>`).join('')}
                    <p><a href="/register">← Go Back</a></p>
                </body>
                </html>
            `);
        }
        
        // Check if email exists
        const existingUser = users.find(u => u.email === value.email);
        if (existingUser) {
            return res.send(`
                <!DOCTYPE html>
                <html>
                <head>
                    <title>Registration Error</title>
                    <style>
                        body { font-family: Arial, sans-serif; max-width: 400px; margin: 50px auto; padding: 20px; }
                        .error { color: #e74c3c; padding: 10px; background: #fdf0ef; border-radius: 4px; }
                    </style>
                </head>
                <body>
                    <div class="error">❌ Email already registered</div>
                    <p><a href="/register">← Go Back</a></p>
                </body>
                </html>
            `);
        }
        
        // Hash password (in a real app)
        // const hashedPassword = await bcrypt.hash(value.password, 10);
        
        // Create user
        const newUser = {
            id: users.length + 1,
            name: value.name,
            email: value.email,
            password: 'hashed_' + value.password, // Simplified for demo
            age: value.age,
            role: value.role,
            createdAt: new Date().toISOString()
        };
        
        users.push(newUser);
        
        console.log('✅ User registered:', newUser.email);
        
        res.send(`
            <!DOCTYPE html>
            <html>
            <head>
                <title>Registration Success</title>
                <style>
                    body { font-family: Arial, sans-serif; max-width: 400px; margin: 50px auto; padding: 20px; text-align: center; }
                    .success { padding: 20px; background: #f0fdf0; border-radius: 4px; }
                </style>
            </head>
            <body>
                <div class="success">
                    ✅ Registration successful!
                    <p>Welcome, ${newUser.name}!</p>
                </div>
                <p><a href="/register">← Register Another</a></p>
                <p><a href="/api/users">← View Users (API)</a></p>
            </body>
            </html>
        `);
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).send('Internal server error');
    }
});

// 3. API registration endpoint
app.post('/api/register', 
    (req, res, next) => {
        // Validate with Joi
        const { error, value } = registrationSchema.validate(req.body, {
            abortEarly: false
        });
        
        if (error) {
            return res.status(400).json({
                success: false,
                errors: error.details.map(d => ({
                    field: d.path[0],
                    message: d.message
                }))
            });
        }
        
        req.validatedData = value;
        next();
    },
    (req, res) => {
        const { name, email, password, age, role } = req.validatedData;
        
        // Check if email exists
        const existingUser = users.find(u => u.email === email);
        if (existingUser) {
            return res.status(409).json({
                success: false,
                error: 'Email already registered'
            });
        }
        
        // Create user
        const newUser = {
            id: users.length + 1,
            name,
            email,
            password: 'hashed_' + password,
            age,
            role,
            createdAt: new Date().toISOString()
        };
        
        users.push(newUser);
        
        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
                id: newUser.id,
                name: newUser.name,
                email: newUser.email,
                age: newUser.age,
                role: newUser.role
            }
        });
    }
);

// 4. Get all users (for testing)
app.get('/api/users', (req, res) => {
    // Don't send passwords
    const safeUsers = users.map(({ password, ...user }) => user);
    res.json({
        success: true,
        count: safeUsers.length,
        data: safeUsers
    });
});

// =====================================================
// START THE SERVER
// =====================================================

app.listen(PORT, () => {
    console.log(`===================================`);
    console.log(`✅ Registration Demo Server`);
    console.log(`📡 http://localhost:${PORT}`);
    console.log(`===================================`);
    console.log(`📋 Available routes:`);
    console.log(`   GET  /register          - Registration form`);
    console.log(`   POST /register          - Register via form`);
    console.log(`   POST /api/register      - Register via API`);
    console.log(`   GET  /api/users         - List users (API)`);
    console.log(`===================================`);
});
```

Run this server:

```bash
node server-registration.js
```

Test it:

1. Open http://localhost:3000/register in your browser
2. Fill out the form and submit
3. Try with invalid data to see validation
4. Test the API:

```bash
# Register via API
curl -X POST http://localhost:3000/api/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","confirmPassword":"password123","age":25}'

# Get users
curl http://localhost:3000/api/users
```

---

## Security Best Practices for User Input

When handling user input, always follow these security best practices:

### 1. Validate Everything
Never trust user input. Always validate data on the server-side.

### 2. Sanitize Input
Remove or escape dangerous characters:

```javascript
const sanitizeInput = (input) => {
    if (typeof input !== 'string') return input;
    return input
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;');
};
```

### 3. Use Parameterized Queries
When using databases, use parameterized queries to prevent SQL injection.

### 4. Set Size Limits
Limit the size of request bodies and files:

```javascript
// Limit JSON body size
app.use(express.json({ limit: '10mb' }));

// Limit URL-encoded body size
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Limit file size in multer
const upload = multer({
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});
```

### 5. Validate Content-Type
Ensure you're parsing the expected content type:

```javascript
app.post('/api/data', (req, res, next) => {
    if (!req.is('application/json')) {
        return res.status(415).json({
            error: 'Content-Type must be application/json'
        });
    }
    next();
});
```

### 6. Use Security Headers
Use `helmet` middleware for security headers:

```bash
npm install helmet
```

```javascript
const helmet = require('helmet');
app.use(helmet());
```

### 7. Rate Limiting
Prevent brute force attacks:

```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100 // Limit each IP to 100 requests
});
app.use('/api', limiter);
```

---

## What We've Learned

In this part, we covered:

1. **Types of user input** — URL-encoded, JSON, multipart, text
2. **Processing forms** — Using `express.urlencoded()` middleware
3. **Processing JSON** — Using `express.json()` middleware
4. **File uploads** — Using `multer` middleware
5. **Data validation** — Manual validation and Joi schemas
6. **Complete feature** — User registration with validation
7. **Security best practices** — Validation, sanitization, size limits

---

## Practice Exercises

### Exercise 1: Contact Form with Attachments
Create a contact form that accepts name, email, subject, message, and an optional file attachment. Store the messages with file references.

### Exercise 2: API Key Validation
Create a middleware that validates an API key from the request headers. Allow different API keys with different permissions.

### Exercise 3: Bulk Upload
Create an endpoint that accepts multiple files and processes them as a batch. Return a summary of the upload.

### Exercise 4: Input Sanitization
Create a middleware that sanitizes all string fields in the request body, removing HTML tags and dangerous characters.

---

## Summary

Handling user input is a core part of web development. With Express, you can:

- **Parse forms** with `express.urlencoded()`
- **Parse JSON** with `express.json()`
- **Handle file uploads** with `multer`
- **Validate data** with Joi or manual validation
- **Secure input** with validation, sanitization, and size limits

In Part 7, we'll focus on **structuring a real application** with a professional folder structure, environment variables, and configuration management. You'll learn how to organize your code for maintainability and scalability.

---

## Quick Reference: Input Handling

| Format | Middleware | Access | Example |
|--------|------------|--------|---------|
| URL-encoded | `express.urlencoded()` | `req.body` | Forms |
| JSON | `express.json()` | `req.body` | APIs |
| Multipart | `multer` | `req.file`, `req.files` | File uploads |
| Text | `express.text()` | `req.body` | Plain text |
