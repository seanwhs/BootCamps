# PRIMER 1: JavaScript Fundamentals for Backend

## Welcome to the JavaScript Primer!

Before we dive into building servers with Node.js and Express, we need to make sure you're comfortable with JavaScript — the language we'll be writing all our server code in.

If you already know JavaScript from frontend development, this primer will help you understand the differences between browser JavaScript and Node.js JavaScript. If you're completely new to JavaScript, this primer will give you everything you need to get started.

### What This Primer Covers

| Section | Topic | What You'll Learn |
|---------|-------|-------------------|
| 1 | Variables and Data Types | `let`, `const`, strings, numbers, booleans |
| 2 | Functions | Declarations, arrow functions, parameters |
| 3 | Objects and Arrays | Creating, accessing, modifying data structures |
| 4 | Control Flow | `if/else`, `switch`, loops |
| 5 | Asynchronous JavaScript | Callbacks, Promises, async/await |
| 6 | Node.js Module System | `require()`, `module.exports`, `import/export` |
| 7 | ES6+ Features | Destructuring, spread, template literals |
| 8 | Error Handling | `try/catch`, throwing errors |

---

## Section 1: Variables and Data Types

### Declaring Variables

In JavaScript, we have three ways to declare variables:

```javascript
// var - The old way (avoid this)
var oldWay = "Don't use me";

// let - Use for values that change
let mutable = "I can change";
mutable = "See? I changed!";

// const - Use for values that NEVER change
const immutable = "I cannot change";
// immutable = "This would cause an error"; // ❌ TypeError
```

**Rule of thumb:** Always use `const` unless you know the variable will need to change, then use `let`. Never use `var`.

### Data Types

```javascript
// 1. Strings - Text
const name = "Alice";
const greeting = 'Hello, world!';
const multiline = `This is a
multiline string`;

// 2. Numbers - Integers and floating point
const age = 25;
const price = 19.99;
const negative = -10;

// 3. Booleans - true or false
const isLoggedIn = true;
const isActive = false;

// 4. Arrays - Lists of items
const fruits = ['apple', 'banana', 'orange'];
const mixed = [1, 'hello', true]; // Mixed types are allowed

// 5. Objects - Key-value pairs
const person = {
    name: 'Alice',
    age: 25,
    city: 'New York'
};

// 6. Null and Undefined
let empty = null; // Intentionally empty
let notDefined; // undefined
```

### Type Checking

```javascript
// Check the type of a value
console.log(typeof 'hello'); // 'string'
console.log(typeof 42); // 'number'
console.log(typeof true); // 'boolean'
console.log(typeof undefined); // 'undefined'
console.log(typeof null); // 'object' (this is a JavaScript quirk)
console.log(typeof {}); // 'object'
console.log(typeof []); // 'object' (arrays are objects in JavaScript)
console.log(typeof function() {}); // 'function'
```

---

## Section 2: Functions

### Function Declarations

```javascript
// Traditional function declaration
function greet(name) {
    return `Hello, ${name}!`;
}

console.log(greet('Alice')); // "Hello, Alice!"
```

### Function Expressions

```javascript
// Function expression (stored in a variable)
const greet = function(name) {
    return `Hello, ${name}!`;
};

console.log(greet('Bob')); // "Hello, Bob!"
```

### Arrow Functions (ES6+)

```javascript
// Arrow function - shorter syntax
const greet = (name) => {
    return `Hello, ${name}!`;
};

// If only one parameter, parentheses are optional
const greetShort = name => `Hello, ${name}!`;

console.log(greetShort('Charlie')); // "Hello, Charlie!"
```

### Functions with Multiple Parameters

```javascript
// Multiple parameters
function add(a, b) {
    return a + b;
}

// Default parameters (ES6+)
function greetUser(name, greeting = 'Hello') {
    return `${greeting}, ${name}!`;
}

console.log(greetUser('Alice')); // "Hello, Alice!"
console.log(greetUser('Bob', 'Hi')); // "Hi, Bob!"
```

### Rest Parameters

```javascript
// Rest parameters - collect all remaining arguments
function sum(...numbers) {
    let total = 0;
    for (const num of numbers) {
        total += num;
    }
    return total;
}

console.log(sum(1, 2, 3)); // 6
console.log(sum(1, 2, 3, 4, 5)); // 15
```

### Returning Values

```javascript
// Functions can return values
function add(a, b) {
    return a + b;
}

// Functions without a return statement return undefined
function doNothing() {
    // No return
}
console.log(doNothing()); // undefined

// Functions can return other functions (closures)
function createCounter() {
    let count = 0;
    return function() {
        count++;
        return count;
    };
}

const counter = createCounter();
console.log(counter()); // 1
console.log(counter()); // 2
console.log(counter()); // 3
```

---

## Section 3: Objects and Arrays

### Objects

```javascript
// Creating objects
const user = {
    id: 1,
    name: 'Alice',
    email: 'alice@example.com',
    isActive: true
};

// Accessing properties
console.log(user.name); // "Alice"
console.log(user['email']); // "alice@example.com"

// Adding new properties
user.age = 25;
user['city'] = 'New York';

// Modifying properties
user.name = 'Alice Updated';

// Deleting properties
delete user.isActive;

// Nested objects
const userWithAddress = {
    id: 1,
    name: 'Alice',
    address: {
        street: '123 Main St',
        city: 'New York',
        country: 'USA'
    }
};

console.log(userWithAddress.address.city); // "New York"
```

### Object Methods

```javascript
// Methods are functions inside objects
const calculator = {
    add: function(a, b) {
        return a + b;
    },
    // Shorthand method syntax
    subtract(a, b) {
        return a - b;
    },
    multiply: (a, b) => a * b
};

console.log(calculator.add(5, 3)); // 8
console.log(calculator.subtract(10, 4)); // 6
console.log(calculator.multiply(3, 4)); // 12

// 'this' keyword refers to the object
const person = {
    name: 'Alice',
    greet() {
        console.log(`Hello, I'm ${this.name}`);
    }
};

person.greet(); // "Hello, I'm Alice"
```

### Arrays

```javascript
// Creating arrays
const numbers = [1, 2, 3, 4, 5];
const mixed = ['hello', 42, true, null];

// Accessing elements (zero-indexed)
console.log(numbers[0]); // 1
console.log(numbers[2]); // 3
console.log(numbers[numbers.length - 1]); // 5 (last element)

// Adding elements
numbers.push(6); // Add to end
numbers.unshift(0); // Add to beginning

// Removing elements
numbers.pop(); // Remove from end
numbers.shift(); // Remove from beginning

// Finding elements
console.log(numbers.indexOf(3)); // 2
console.log(numbers.includes(5)); // true

// Iterating over arrays
// 1. for loop
for (let i = 0; i < numbers.length; i++) {
    console.log(numbers[i]);
}

// 2. for...of loop
for (const num of numbers) {
    console.log(num);
}

// 3. forEach method
numbers.forEach((num, index) => {
    console.log(`Index ${index}: ${num}`);
});
```

### Array Methods (Important!)

```javascript
const numbers = [1, 2, 3, 4, 5];

// map - Transform each element
const doubled = numbers.map(num => num * 2);
console.log(doubled); // [2, 4, 6, 8, 10]

// filter - Keep elements that pass a test
const evenNumbers = numbers.filter(num => num % 2 === 0);
console.log(evenNumbers); // [2, 4]

// reduce - Reduce array to a single value
const sum = numbers.reduce((total, num) => total + num, 0);
console.log(sum); // 15

// find - Find the first element that matches
const firstEven = numbers.find(num => num % 2 === 0);
console.log(firstEven); // 2

// some - Check if any element matches
const hasEven = numbers.some(num => num % 2 === 0);
console.log(hasEven); // true

// every - Check if all elements match
const allEven = numbers.every(num => num % 2 === 0);
console.log(allEven); // false
```

---

## Section 4: Control Flow

### Conditionals (if/else)

```javascript
const age = 25;

if (age < 18) {
    console.log('You are a minor');
} else if (age >= 18 && age < 65) {
    console.log('You are an adult');
} else {
    console.log('You are a senior');
}

// Ternary operator (short form of if/else)
const status = age >= 18 ? 'Adult' : 'Minor';
console.log(status); // "Adult"
```

### Switch Statement

```javascript
const day = 'Monday';

switch (day) {
    case 'Monday':
        console.log('Start of work week');
        break;
    case 'Friday':
        console.log('TGIF!');
        break;
    case 'Saturday':
    case 'Sunday':
        console.log('Weekend!');
        break;
    default:
        console.log('Midweek');
}
```

### Loops

```javascript
// for loop
for (let i = 0; i < 5; i++) {
    console.log(`Iteration ${i}`);
}

// while loop
let i = 0;
while (i < 5) {
    console.log(`Iteration ${i}`);
    i++;
}

// do...while loop (runs at least once)
let j = 0;
do {
    console.log(`Iteration ${j}`);
    j++;
} while (j < 5);

// for...in loop (for object properties)
const user = { name: 'Alice', age: 25, city: 'New York' };
for (const key in user) {
    console.log(`${key}: ${user[key]}`);
}

// for...of loop (for arrays and iterables)
const numbers = [1, 2, 3, 4, 5];
for (const num of numbers) {
    console.log(num);
}
```

---

## Section 5: Asynchronous JavaScript

### Understanding Asynchronous Code

JavaScript is single-threaded, meaning it can only do one thing at a time. However, it can handle asynchronous operations using callbacks, Promises, and async/await.

**Analogy:** Think of a restaurant:
- **Synchronous:** The waiter waits for the kitchen to cook the food before taking the next order
- **Asynchronous:** The waiter takes orders, gives them to the kitchen, and continues taking more orders. When food is ready, the kitchen calls the waiter.

### Callbacks

```javascript
// A callback is a function passed to another function
function fetchData(callback) {
    setTimeout(() => {
        const data = { id: 1, name: 'Alice' };
        callback(data);
    }, 1000);
}

// Using the callback
fetchData((data) => {
    console.log('Data received:', data);
});

console.log('This runs before the callback');
```

**Problem with Callbacks:** Callback Hell (nested callbacks)

```javascript
// Callback Hell - Hard to read and maintain
fetchUser(1, (user) => {
    fetchPosts(user.id, (posts) => {
        fetchComments(posts[0].id, (comments) => {
            console.log(comments);
        });
    });
});
```

### Promises

Promises solve the callback hell problem.

```javascript
// Creating a Promise
function fetchData() {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            const data = { id: 1, name: 'Alice' };
            // Success: call resolve
            resolve(data);
            // Failure: call reject
            // reject(new Error('Failed to fetch data'));
        }, 1000);
    });
}

// Using a Promise
fetchData()
    .then((data) => {
        console.log('Data:', data);
        return data.id;
    })
    .then((id) => {
        console.log('ID:', id);
    })
    .catch((error) => {
        console.error('Error:', error);
    })
    .finally(() => {
        console.log('Promise completed');
    });
```

### Async/Await (The Modern Way)

Async/await makes asynchronous code look synchronous.

```javascript
// Async function
async function getData() {
    try {
        const data = await fetchData();
        console.log('Data:', data);
        return data;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}

// Using async/await
async function main() {
    try {
        const result = await getData();
        console.log('Result:', result);
    } catch (error) {
        console.error('Failed:', error);
    }
}

main();

// Multiple async operations in parallel
async function fetchAll() {
    const [user, posts, comments] = await Promise.all([
        fetchUser(1),
        fetchPosts(1),
        fetchComments(1)
    ]);
    console.log('All done:', { user, posts, comments });
}

// Multiple async operations sequentially
async function fetchSequential() {
    const user = await fetchUser(1);
    const posts = await fetchPosts(user.id);
    const comments = await fetchComments(posts[0].id);
    console.log({ user, posts, comments });
}
```

### Common Async Patterns

```javascript
// 1. Timeout with Promise
function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function waitAndLog() {
    await delay(2000);
    console.log('2 seconds later...');
}

// 2. Retry logic
async function fetchWithRetry(fn, retries = 3) {
    for (let i = 0; i < retries; i++) {
        try {
            return await fn();
        } catch (error) {
            if (i === retries - 1) throw error;
            await delay(1000 * (i + 1));
        }
    }
}

// 3. Timeout with race
async function fetchWithTimeout(fn, timeoutMs = 5000) {
    const timeout = new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Timeout')), timeoutMs)
    );
    return Promise.race([fn(), timeout]);
}
```

---

## Section 6: Node.js Module System

### CommonJS (require/module.exports)

```javascript
// file: math.js
function add(a, b) {
    return a + b;
}

function subtract(a, b) {
    return a - b;
}

// Export multiple functions
module.exports = {
    add,
    subtract
};

// OR export individually
exports.add = add;
exports.subtract = subtract;

// file: app.js
// Import the module
const math = require('./math.js');

console.log(math.add(5, 3)); // 8
console.log(math.subtract(10, 4)); // 6

// OR destructure
const { add, subtract } = require('./math.js');
console.log(add(5, 3)); // 8
```

### ES6 Modules (import/export)

```javascript
// file: math.js
export function add(a, b) {
    return a + b;
}

export const subtract = (a, b) => a - b;

export default function multiply(a, b) {
    return a * b;
}

// file: app.js
import multiply, { add, subtract } from './math.js';

console.log(add(5, 3)); // 8
console.log(multiply(5, 3)); // 15

// Import all as a namespace
import * as math from './math.js';
console.log(math.add(5, 3)); // 8
```

### Node.js Built-in Modules

```javascript
// File system module
const fs = require('fs');

// Read a file
const data = fs.readFileSync('file.txt', 'utf-8');

// Read a file asynchronously
fs.readFile('file.txt', 'utf-8', (err, data) => {
    if (err) {
        console.error('Error:', err);
        return;
    }
    console.log('Data:', data);
});

// Write a file
fs.writeFileSync('output.txt', 'Hello, world!');

// Path module
const path = require('path');

console.log(path.join('folder', 'subfolder', 'file.txt'));
console.log(path.extname('file.txt')); // '.txt'
console.log(path.basename('/path/to/file.txt')); // 'file.txt'

// HTTP module (covered in the main series)
const http = require('http');
```

---

## Section 7: ES6+ Features

### Destructuring

```javascript
// Object destructuring
const user = {
    name: 'Alice',
    age: 25,
    city: 'New York'
};

// Old way
const name = user.name;
const age = user.age;

// New way (destructuring)
const { name, age, city } = user;
console.log(name, age, city);

// Renaming during destructuring
const { name: userName, age: userAge } = user;
console.log(userName, userAge);

// Default values
const { country = 'USA' } = user;
console.log(country); // 'USA'

// Array destructuring
const numbers = [1, 2, 3, 4, 5];
const [first, second, ...rest] = numbers;
console.log(first); // 1
console.log(second); // 2
console.log(rest); // [3, 4, 5]

// Function parameter destructuring
function greet({ name, age }) {
    console.log(`Hello ${name}, age ${age}`);
}
greet({ name: 'Alice', age: 25 });
```

### Spread and Rest Operators

```javascript
// Spread operator (...) - expands an array/object
// Arrays
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const combined = [...arr1, ...arr2]; // [1, 2, 3, 4, 5, 6]

// Objects
const user = { name: 'Alice', age: 25 };
const userWithCity = { ...user, city: 'New York' };
console.log(userWithCity); // { name: 'Alice', age: 25, city: 'New York' }

// Rest operator (...) - collects remaining items
function sum(...numbers) {
    return numbers.reduce((total, num) => total + num, 0);
}
console.log(sum(1, 2, 3, 4)); // 10

// Rest in destructuring
const [first, second, ...rest] = [1, 2, 3, 4, 5];
console.log(first); // 1
console.log(second); // 2
console.log(rest); // [3, 4, 5]
```

### Template Literals

```javascript
// Template literals use backticks (`)
const name = 'Alice';
const age = 25;

// String interpolation
console.log(`Hello, ${name}! You are ${age} years old.`);

// Multi-line strings
const message = `
    Hello ${name},
    
    Thank you for signing up!
    
    Your age is ${age}.
`;

// Expressions inside template literals
const total = 100;
const discount = 0.2;
console.log(`Total: $${total}, Discounted: $${total * (1 - discount)}`);
```

### Optional Chaining

```javascript
const user = {
    name: 'Alice',
    address: {
        street: '123 Main St',
        city: 'New York'
    }
};

// Old way (would cause error if address is null)
const city = user && user.address && user.address.city;

// Optional chaining
const city2 = user?.address?.city;
console.log(city2); // "New York"

const postalCode = user?.address?.postalCode;
console.log(postalCode); // undefined (no error)
```

### Nullish Coalescing

```javascript
// Nullish coalescing (??) - returns right side only if left is null or undefined
const name = null;
const displayName = name ?? 'Guest';
console.log(displayName); // "Guest"

// Difference from || (logical OR)
const count = 0;
console.log(count || 10); // 10 (0 is falsy)
console.log(count ?? 10); // 0 (0 is not nullish)
```

---

## Section 8: Error Handling

### Try/Catch

```javascript
// Synchronous error handling
try {
    const result = riskyOperation();
    console.log('Result:', result);
} catch (error) {
    console.error('Error:', error.message);
    console.error('Stack trace:', error.stack);
} finally {
    console.log('This always runs');
}

// Asynchronous error handling with try/catch (async/await)
async function fetchData() {
    try {
        const data = await apiCall();
        console.log('Data:', data);
    } catch (error) {
        console.error('API error:', error);
    }
}

// Asynchronous error handling with .catch()
fetchData()
    .catch(error => {
        console.error('Error:', error);
    });
```

### Throwing Errors

```javascript
// Throw a built-in error
function validateAge(age) {
    if (age < 0) {
        throw new Error('Age cannot be negative');
    }
    if (age < 18) {
        throw new Error('Must be 18 or older');
    }
    return true;
}

// Custom error classes
class ValidationError extends Error {
    constructor(message) {
        super(message);
        this.name = 'ValidationError';
        this.statusCode = 400;
    }
}

class NotFoundError extends Error {
    constructor(resource) {
        super(`${resource} not found`);
        this.name = 'NotFoundError';
        this.statusCode = 404;
    }
}

// Using custom errors
function findUser(id) {
    const user = users.find(u => u.id === id);
    if (!user) {
        throw new NotFoundError('User');
    }
    return user;
}

try {
    const user = findUser(999);
} catch (error) {
    if (error instanceof NotFoundError) {
        console.error('Not found:', error.message);
    } else if (error instanceof ValidationError) {
        console.error('Validation error:', error.message);
    } else {
        console.error('Unknown error:', error);
    }
}
```

---

## Practice Exercises

### Exercise 1: Simple Calculator

```javascript
// Create a calculator object with methods
// add, subtract, multiply, divide, and power
// Each method should take two parameters and return the result

// Your code here

// Test your code
console.log(calculator.add(5, 3)); // 8
console.log(calculator.multiply(4, 3)); // 12
```

### Exercise 2: User Management

```javascript
// Create a function that takes an array of users and returns:
// 1. All active users
// 2. All inactive users
// 3. Average age of active users

const users = [
    { id: 1, name: 'Alice', age: 25, active: true },
    { id: 2, name: 'Bob', age: 30, active: false },
    { id: 3, name: 'Charlie', age: 35, active: true },
    { id: 4, name: 'Diana', age: 28, active: false },
];

// Your code here
```

### Exercise 3: Async Data Fetching

```javascript
// Write an async function that:
// 1. Fetches user data from an API (simulate with setTimeout)
// 2. Fetches posts for that user (simulate with setTimeout)
// 3. Returns an object with user and posts

async function getUserWithPosts(userId) {
    // Your code here
}

// Test
getUserWithPosts(1).then(result => console.log(result));
```

---

## Summary

You now have a solid foundation in JavaScript for backend development. Here's what you've learned:

| Concept | Key Points |
|---------|------------|
| Variables | `let` for mutable, `const` for immutable |
| Functions | Declarations, expressions, arrow functions |
| Objects | Key-value pairs, methods, `this` context |
| Arrays | Methods: `map`, `filter`, `reduce`, `find` |
| Async | Callbacks → Promises → Async/Await |
| Modules | `require`/`module.exports` for Node.js |
| ES6+ | Destructuring, spread, template literals |
| Errors | `try/catch`, custom error classes |
