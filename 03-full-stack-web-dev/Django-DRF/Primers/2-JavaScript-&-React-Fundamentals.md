# Primer 2: JavaScript & React Fundamentals

## Essential JavaScript and React Knowledge for the Masterclass

Welcome to **Primer 2** of the Django REST Framework & Next.js 16 masterclass. This primer is designed for developers who need a quick refresh or introduction to JavaScript and React fundamentals before diving into the main series.

---

## Section 1: JavaScript Fundamentals

### 1.1 Variables and Data Types

```javascript
// Variables (ES6+)
let name = "John Doe";        // Block-scoped, can be reassigned
const email = "john@example.com"; // Block-scoped, cannot be reassigned
var oldStyle = "avoid this";   // Function-scoped

// Strings
const greeting = "Hello";
const message = `${greeting}, ${name}!`; // Template literals

// Numbers
const age = 30;
const price = 19.99;
const isInteger = Number.isInteger(age); // true

// Booleans
const isActive = true;
const isDeleted = false;

// Null and Undefined
let result = null;        // Explicitly empty
let notDefined;           // undefined

// Objects
const user = {
    id: 1,
    name: "John",
    email: "john@example.com",
    address: {
        city: "New York",
        country: "USA"
    }
};

// Object destructuring
const { name, email } = user;
const { city } = user.address;

// Spread operator
const userWithAge = { ...user, age: 30 };

// Arrays
const tasks = ["Task 1", "Task 2", "Task 3"];
tasks.push("Task 4");       // Add to end
const firstTask = tasks[0];
const taskCount = tasks.length;

// Array destructuring
const [first, second] = tasks;

// Spread operator for arrays
const newTasks = [...tasks, "Task 5"];

// Array methods
const filtered = tasks.filter(task => task.includes("Task"));
const mapped = tasks.map(task => task.toUpperCase());
const found = tasks.find(task => task === "Task 1");
const hasTask = tasks.some(task => task === "Task 1");
const allHaveTask = tasks.every(task => task.includes("Task"));

// Sets (unique values)
const tags = new Set(["python", "django", "api"]);
tags.add("rest");

// Maps (key-value pairs)
const userMap = new Map();
userMap.set("name", "John");
userMap.set("age", 30);
```

### 1.2 Functions

```javascript
// Function declaration
function greet(name) {
    return `Hello, ${name}!`;
}

// Function expression
const greetUser = function(name) {
    return `Hello, ${name}!`;
};

// Arrow functions (ES6)
const greetArrow = (name) => {
    return `Hello, ${name}!`;
};

// Implicit return
const greetShort = name => `Hello, ${name}!`;

// Default parameters
function greetUser(name, greeting = "Hello") {
    return `${greeting}, ${name}!`;
}

// Rest parameters
function sumAll(...numbers) {
    return numbers.reduce((total, num) => total + num, 0);
}

// Callback functions
function processData(data, callback) {
    const result = data.map(item => item * 2);
    callback(result);
}

// Higher-order functions
const multiplyBy = (factor) => (number) => number * factor;
const double = multiplyBy(2);
const result = double(5); // 10

// Immediately Invoked Function Expression (IIFE)
(function() {
    console.log("IIFE executed");
})();
```

### 1.3 Objects and Prototypes

```javascript
// Object literal
const user = {
    name: "John",
    age: 30,
    greet() {
        return `Hello, I'm ${this.name}`;
    }
};

// Constructor function
function User(name, age) {
    this.name = name;
    this.age = age;
    this.greet = function() {
        return `Hello, I'm ${this.name}`;
    };
}

// Class syntax (ES6)
class User {
    constructor(name, age) {
        this.name = name;
        this.age = age;
        this._id = User._idCounter++;
    }
    
    // Getter
    get id() {
        return this._id;
    }
    
    // Static property
    static _idCounter = 1;
    
    // Static method
    static create(name, age) {
        return new User(name, age);
    }
    
    // Instance method
    greet() {
        return `Hello, I'm ${this.name}`;
    }
    
    // Inheritance
    class Admin extends User {
        constructor(name, age, permissions) {
            super(name, age);
            this.permissions = permissions;
        }
        
        canDelete() {
            return this.permissions.includes("delete");
        }
    }
}
```

### 1.4 Arrays and Iteration

```javascript
const numbers = [1, 2, 3, 4, 5];

// Traditional for loop
for (let i = 0; i < numbers.length; i++) {
    console.log(numbers[i]);
}

// for...of loop
for (const num of numbers) {
    console.log(num);
}

// for...in (for objects)
const obj = { a: 1, b: 2, c: 3 };
for (const key in obj) {
    console.log(key, obj[key]);
}

// forEach
numbers.forEach(num => console.log(num));

// map - transform array
const doubled = numbers.map(num => num * 2);

// filter - create new array with filtered items
const evens = numbers.filter(num => num % 2 === 0);

// reduce - accumulate values
const sum = numbers.reduce((total, num) => total + num, 0);

// find - find first matching item
const found = numbers.find(num => num > 3);

// findIndex - find index of matching item
const index = numbers.findIndex(num => num > 3);

// some - check if any match condition
const hasLarge = numbers.some(num => num > 10);

// every - check if all match condition
const allSmall = numbers.every(num => num < 10);

// includes - check if array contains value
const hasThree = numbers.includes(3);

// sort - sort array
const sorted = [...numbers].sort((a, b) => a - b);

// reverse - reverse array
const reversed = [...numbers].reverse();
```

### 1.5 Promises and Async/Await

```javascript
// Promise
const fetchData = () => {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            const success = true;
            if (success) {
                resolve({ data: "Data fetched successfully" });
            } else {
                reject(new Error("Failed to fetch data"));
            }
        }, 1000);
    });
};

// Promise chaining
fetchData()
    .then(response => {
        console.log(response);
        return processData(response);
    })
    .then(processed => {
        console.log(processed);
    })
    .catch(error => {
        console.error(error);
    })
    .finally(() => {
        console.log("Promise completed");
    });

// Async/Await (ES8)
async function getData() {
    try {
        const response = await fetchData();
        const processed = await processData(response);
        return processed;
    } catch (error) {
        console.error(error);
        throw error;
    } finally {
        console.log("Function completed");
    }
}

// Parallel execution with Promise.all
async function fetchMultiple() {
    const [data1, data2] = await Promise.all([
        fetchData(),
        fetchOtherData()
    ]);
    return { data1, data2 };
}

// Race condition with Promise.race
async function fetchWithTimeout() {
    const result = await Promise.race([
        fetchData(),
        new Promise((_, reject) => 
            setTimeout(() => reject(new Error("Timeout")), 5000)
        )
    ]);
    return result;
}
```

### 1.6 Error Handling

```javascript
// Try-catch
try {
    const result = riskyOperation();
    console.log(result);
} catch (error) {
    console.error("Error:", error.message);
} finally {
    console.log("This always runs");
}

// Custom error classes
class ValidationError extends Error {
    constructor(message, field) {
        super(message);
        this.name = "ValidationError";
        this.field = field;
    }
}

// Async error handling
async function safeOperation() {
    try {
        await riskyAsyncOperation();
    } catch (error) {
        if (error instanceof ValidationError) {
            console.error("Validation failed:", error.field);
        } else {
            console.error("Unexpected error:", error);
        }
    }
}

// Global error handling (browser)
window.addEventListener("error", (event) => {
    console.error("Global error:", event.error);
});

// Unhandled promise rejection
window.addEventListener("unhandledrejection", (event) => {
    console.error("Unhandled rejection:", event.reason);
});
```

### 1.7 Modules

```javascript
// Named exports (utils.js)
export const formatDate = (date) => {
    return new Date(date).toLocaleDateString();
};

export const formatCurrency = (amount) => {
    return `$${amount.toFixed(2)}`;
};

// Default export (api.js)
export default function fetchData() {
    return fetch("/api/data").then(res => res.json());
}

// Import (app.js)
import fetchData, { formatDate, formatCurrency } from './utils';

// Import all
import * as Utils from './utils';

// Dynamic import
async function loadModule() {
    const module = await import('./heavy-module.js');
    return module.default();
}

// Export from another module
export { formatDate } from './date-utils';
export { default as api } from './api';
```

### 1.8 JSON and Fetch API

```javascript
// Converting to JSON
const data = { name: "John", age: 30 };
const jsonString = JSON.stringify(data);

// Parsing JSON
const parsed = JSON.parse(jsonString);

// Fetch API (GET)
fetch('https://api.example.com/data')
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => console.log(data))
    .catch(error => console.error('Error:', error));

// Fetch API (POST)
fetch('https://api.example.com/data', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer token'
    },
    body: JSON.stringify({ name: "John", age: 30 })
})
.then(response => response.json())
.then(data => console.log(data));

// AbortController (cancel request)
const controller = new AbortController();
const signal = controller.signal;

fetch('https://api.example.com/data', { signal })
    .then(response => response.json())
    .catch(error => {
        if (error.name === 'AbortError') {
            console.log('Request cancelled');
        }
    });

// Cancel after 5 seconds
setTimeout(() => controller.abort(), 5000);
```

---

## Section 2: React Fundamentals

### 2.1 React Components

```jsx
// Functional Component
function Welcome(props) {
    return <h1>Hello, {props.name}</h1>;
}

// Functional Component with destructuring
function Welcome({ name }) {
    return <h1>Hello, {name}</h1>;
}

// Arrow function component
const Welcome = ({ name }) => {
    return <h1>Hello, {name}</h1>;
};

// Component with children
function Layout({ children }) {
    return (
        <div className="layout">
            <header>Header</header>
            <main>{children}</main>
            <footer>Footer</footer>
        </div>
    );
}

// React.memo (memoization)
const MemoizedComponent = React.memo(({ data }) => {
    return <div>{data}</div>;
});
```

### 2.2 JSX Syntax

```jsx
// Basic JSX
const element = <h1 className="title">Hello World</h1>;

// JSX with expressions
const name = "John";
const element = <h1>Hello, {name}</h1>;

// Conditional rendering
function Greeting({ isLoggedIn }) {
    return (
        <div>
            {isLoggedIn ? (
                <h1>Welcome back!</h1>
            ) : (
                <h1>Please sign in.</h1>
            )}
        </div>
    );
}

// Conditional with && operator
function Greeting({ isLoggedIn }) {
    return (
        <div>
            {isLoggedIn && <h1>Welcome back!</h1>}
            {!isLoggedIn && <h1>Please sign in.</h1>}
        </div>
    );
}

// Lists and keys
function TaskList({ tasks }) {
    return (
        <ul>
            {tasks.map(task => (
                <li key={task.id}>{task.title}</li>
            ))}
        </ul>
    );
}

// Fragments
function FragmentExample() {
    return (
        <>
            <h1>Title</h1>
            <p>Content</p>
        </>
    );
}

// Inline styles
const divStyle = {
    color: 'blue',
    fontSize: '14px'
};
const element = <div style={divStyle}>Styled content</div>;
```

### 2.3 Props and State

```jsx
// Props
function UserCard({ user, onEdit, className }) {
    return (
        <div className={className}>
            <h2>{user.name}</h2>
            <p>{user.email}</p>
            <button onClick={() => onEdit(user.id)}>Edit</button>
        </div>
    );
}

// Default props
function UserCard({ user, className = 'default-card' }) {
    return (
        <div className={className}>
            <h2>{user.name}</h2>
        </div>
    );
}

// State (useState)
function Counter() {
    const [count, setCount] = React.useState(0);
    
    const increment = () => {
        setCount(count + 1);
        // or
        setCount(prev => prev + 1);
    };
    
    return (
        <div>
            <p>Count: {count}</p>
            <button onClick={increment}>Increment</button>
        </div>
    );
}

// Complex state
function UserForm() {
    const [formData, setFormData] = React.useState({
        name: '',
        email: '',
        age: 0
    });
    
    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };
    
    return (
        <form>
            <input
                name="name"
                value={formData.name}
                onChange={handleChange}
            />
            <input
                name="email"
                value={formData.email}
                onChange={handleChange}
            />
        </form>
    );
}
```

### 2.4 Lifecycle and Hooks

```jsx
// useEffect (lifecycle)
import { useEffect, useState } from 'react';

function DataFetcher() {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    
    // ComponentDidMount + ComponentDidUpdate
    useEffect(() => {
        // Effect runs after render
        console.log('Component mounted or updated');
        
        return () => {
            // Cleanup (ComponentWillUnmount)
            console.log('Component will unmount');
        };
    }, []); // Empty array = only on mount
    
    // Data fetching
    useEffect(() => {
        let isMounted = true;
        
        const fetchData = async () => {
            try {
                const response = await fetch('/api/data');
                const result = await response.json();
                if (isMounted) {
                    setData(result);
                    setLoading(false);
                }
            } catch (error) {
                if (isMounted) {
                    setLoading(false);
                }
            }
        };
        
        fetchData();
        
        return () => {
            isMounted = false;
        };
    }, []); // Only on mount
    
    return (
        <div>
            {loading ? <p>Loading...</p> : <pre>{JSON.stringify(data, null, 2)}</pre>}
        </div>
    );
}

// useMemo (memoization)
function ExpensiveComponent({ data, filter }) {
    const processedData = useMemo(() => {
        console.log('Processing data...');
        return data.filter(item => item.value > filter);
    }, [data, filter]);
    
    return <div>{processedData.length} items</div>;
}

// useCallback (memoized callback)
function ParentComponent() {
    const [count, setCount] = useState(0);
    
    const handleClick = useCallback(() => {
        console.log('Button clicked');
    }, []);
    
    return <ChildComponent onClick={handleClick} />;
}

// useRef (reference)
function InputFocus() {
    const inputRef = useRef(null);
    
    const focusInput = () => {
        inputRef.current.focus();
    };
    
    return (
        <div>
            <input ref={inputRef} type="text" />
            <button onClick={focusInput}>Focus</button>
        </div>
    );
}

// useReducer (complex state)
function Counter() {
    const [state, dispatch] = useReducer(reducer, { count: 0 });
    
    function reducer(state, action) {
        switch (action.type) {
            case 'increment':
                return { count: state.count + 1 };
            case 'decrement':
                return { count: state.count - 1 };
            case 'reset':
                return { count: 0 };
            default:
                return state;
        }
    }
    
    return (
        <div>
            <p>Count: {state.count}</p>
            <button onClick={() => dispatch({ type: 'increment' })}>+</button>
            <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
            <button onClick={() => dispatch({ type: 'reset' })}>Reset</button>
        </div>
    );
}

// useContext (context)
const ThemeContext = React.createContext('light');

function ThemedComponent() {
    const theme = useContext(ThemeContext);
    return <div className={`theme-${theme}`}>Themed content</div>;
}

function App() {
    return (
        <ThemeContext.Provider value="dark">
            <ThemedComponent />
        </ThemeContext.Provider>
    );
}
```

### 2.5 Forms and Events

```jsx
// Controlled form
function LoginForm() {
    const [formData, setFormData] = useState({
        email: '',
        password: ''
    });
    
    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };
    
    const handleSubmit = (e) => {
        e.preventDefault();
        console.log('Form submitted:', formData);
    };
    
    return (
        <form onSubmit={handleSubmit}>
            <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                placeholder="Email"
            />
            <input
                type="password"
                name="password"
                value={formData.password}
                onChange={handleChange}
                placeholder="Password"
            />
            <button type="submit">Login</button>
        </form>
    );
}

// Event handlers
function EventDemo() {
    const handleClick = (e) => {
        console.log('Clicked:', e.target);
    };
    
    const handleInputChange = (e) => {
        console.log('Value:', e.target.value);
    };
    
    const handleKeyDown = (e) => {
        if (e.key === 'Enter') {
            console.log('Enter pressed');
        }
    };
    
    return (
        <div>
            <button onClick={handleClick}>Click me</button>
            <input onChange={handleInputChange} onKeyDown={handleKeyDown} />
            <div onMouseEnter={() => console.log('Mouse entered')}>
                Hover me
            </div>
        </div>
    );
}
```

### 2.6 Custom Hooks

```jsx
// Custom hook for data fetching
function useFetch(url) {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    
    useEffect(() => {
        let isMounted = true;
        
        const fetchData = async () => {
            try {
                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error(`HTTP error: ${response.status}`);
                }
                const result = await response.json();
                if (isMounted) {
                    setData(result);
                    setLoading(false);
                }
            } catch (error) {
                if (isMounted) {
                    setError(error);
                    setLoading(false);
                }
            }
        };
        
        fetchData();
        
        return () => {
            isMounted = false;
        };
    }, [url]);
    
    return { data, loading, error };
}

// Usage
function UserList() {
    const { data, loading, error } = useFetch('/api/users');
    
    if (loading) return <div>Loading...</div>;
    if (error) return <div>Error: {error.message}</div>;
    
    return <ul>{data.map(user => <li key={user.id}>{user.name}</li>)}</ul>;
}

// Custom hook for local storage
function useLocalStorage(key, initialValue) {
    const [storedValue, setStoredValue] = useState(() => {
        try {
            const item = localStorage.getItem(key);
            return item ? JSON.parse(item) : initialValue;
        } catch (error) {
            return initialValue;
        }
    });
    
    const setValue = (value) => {
        try {
            const valueToStore = value instanceof Function ? value(storedValue) : value;
            setStoredValue(valueToStore);
            localStorage.setItem(key, JSON.stringify(valueToStore));
        } catch (error) {
            console.log(error);
        }
    };
    
    return [storedValue, setValue];
}
```

### 2.7 Error Boundaries

```jsx
// Error Boundary Component
class ErrorBoundary extends React.Component {
    constructor(props) {
        super(props);
        this.state = { hasError: false, error: null };
    }
    
    static getDerivedStateFromError(error) {
        return { hasError: true, error };
    }
    
    componentDidCatch(error, errorInfo) {
        console.error('Error caught by boundary:', error, errorInfo);
    }
    
    render() {
        if (this.state.hasError) {
            return (
                <div className="error-boundary">
                    <h2>Something went wrong</h2>
                    <p>{this.state.error?.message}</p>
                    <button onClick={() => window.location.reload()}>
                        Refresh
                    </button>
                </div>
            );
        }
        
        return this.props.children;
    }
}

// Usage
function App() {
    return (
        <ErrorBoundary>
            <MyComponent />
        </ErrorBoundary>
    );
}
```

### 2.8 React Router (Browser Router)

```jsx
import { BrowserRouter, Routes, Route, Link, useParams, useNavigate } from 'react-router-dom';

function App() {
    return (
        <BrowserRouter>
            <nav>
                <Link to="/">Home</Link>
                <Link to="/tasks">Tasks</Link>
                <Link to="/about">About</Link>
            </nav>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/tasks" element={<TaskList />} />
                <Route path="/tasks/:id" element={<TaskDetail />} />
                <Route path="/about" element={<About />} />
                <Route path="*" element={<NotFound />} />
            </Routes>
        </BrowserRouter>
    );
}

function TaskDetail() {
    const { id } = useParams();
    const navigate = useNavigate();
    
    return (
        <div>
            <h2>Task {id}</h2>
            <button onClick={() => navigate('/tasks')}>Back</button>
        </div>
    );
}
```

---

## Quick Reference Cards

### JavaScript Cheat Sheet

```javascript
// Array methods
arr.map()      // Transform
arr.filter()   // Filter
arr.reduce()   // Accumulate
arr.find()     // Find first
arr.some()     // Check any
arr.every()    // Check all

// Object methods
Object.keys()    // Get keys
Object.values()  // Get values
Object.entries() // Get entries

// String methods
str.includes()   // Check contains
str.startsWith() // Starts with
str.endsWith()   // Ends with
str.split()      // Split string
str.join()       // Join array
str.trim()       // Remove spaces
```

### React Cheat Sheet

```jsx
// Hooks
useState()        // State
useEffect()      // Side effects
useContext()     // Context
useReducer()     // Complex state
useMemo()        // Memoized value
useCallback()    // Memoized callback
useRef()         // DOM reference

// Component patterns
React.memo()     // Memoize component
React.lazy()     // Lazy load
ErrorBoundary    // Error handling
```

---

*This concludes Primer 2. You now have the essential JavaScript and React knowledge needed for the masterclass.*
