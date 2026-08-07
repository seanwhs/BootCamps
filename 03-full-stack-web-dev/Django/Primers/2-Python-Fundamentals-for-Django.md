# Primer 2: Python Fundamentals for Django

## Welcome to the Python Primer!

This primer is designed for beginners who want to learn the Python concepts you'll need for Django development. If you're already comfortable with Python, you can skip this. But if you're new to Python or need a refresher, this primer will give you exactly what you need to succeed with Django.

Think of this as your "Python bootcamp" before diving into Django. We'll cover the essential concepts with practical examples that relate to web development.

---

## P.1: What is Python?

### The Quick Answer

Python is a programming language that's known for being:
- **Readable**: Code looks like plain English
- **Versatile**: Used for web, data science, automation, and more
- **Popular**: One of the most widely-used languages
- **Beginner-friendly**: Easy to learn and understand

### Why Python for Django?

Django is built with Python, so understanding Python is essential:

```python
# Python is clean and readable
def greet_user(username):
    return f"Hello, {username}!"

# Compare to other languages (e.g., Java)
# public String greetUser(String username) {
#     return "Hello, " + username + "!";
# }
```

---

## P.2: Variables and Data Types

### Variables

Variables are like labeled boxes that store data:

```python
# Storing data in variables
name = "Alice"              # String (text)
age = 25                    # Integer (whole number)
height = 5.9                # Float (decimal number)
is_active = True            # Boolean (True/False)
```

### Simple Data Types

```python
# Strings - Text
first_name = "John"
last_name = 'Doe'
message = "Hello, World!"

# Integers - Whole numbers
age = 30
year = 2026
count = -5

# Floats - Decimal numbers
price = 19.99
pi = 3.14159
temperature = -2.5

# Booleans - True or False
is_authenticated = True
is_admin = False

# None - No value (like null in other languages)
result = None
```

### Type Checking

```python
# Check the type of a variable
name = "Alice"
age = 25

print(type(name))  # <class 'str'>
print(type(age))   # <class 'int'>

# Type conversion
age_string = "25"
age_number = int(age_string)  # Convert string to integer

price_string = "19.99"
price_number = float(price_string)  # Convert string to float

number = 100
number_string = str(number)  # Convert number to string
```

---

## P.3: Collections (Data Structures)

### Lists

Lists store ordered collections of items:

```python
# Creating lists
fruits = ["apple", "banana", "orange"]
mixed = [1, "hello", 3.14, True]
empty = []

# Accessing items (index starts at 0)
first_fruit = fruits[0]          # "apple"
last_fruit = fruits[-1]          # "orange"

# Adding items
fruits.append("grape")           # ["apple", "banana", "orange", "grape"]
fruits.insert(1, "pear")         # ["apple", "pear", "banana", "orange", "grape"]

# Removing items
fruits.remove("banana")          # ["apple", "pear", "orange", "grape"]
last = fruits.pop()              # removes and returns "grape"

# List slicing
numbers = [1, 2, 3, 4, 5, 6, 7]
first_three = numbers[:3]        # [1, 2, 3]
last_three = numbers[-3:]        # [5, 6, 7]
middle = numbers[2:5]            # [3, 4, 5]

# List length
count = len(fruits)              # 3

# Looping through lists
for fruit in fruits:
    print(fruit)
```

### Dictionaries

Dictionaries store key-value pairs (like a real dictionary):

```python
# Creating dictionaries
user = {
    "username": "alice123",
    "email": "alice@example.com",
    "age": 25,
    "is_active": True
}

# Accessing values
username = user["username"]      # "alice123"
email = user.get("email")        # "alice@example.com"
phone = user.get("phone")        # None (doesn't exist)

# Adding/updating values
user["phone"] = "555-1234"       # Add new key
user["age"] = 26                 # Update existing key

# Removing values
del user["phone"]                # Remove key
email = user.pop("email")        # Remove and return value

# Checking if key exists
if "username" in user:
    print("Username exists")

# Looping through dictionaries
for key, value in user.items():
    print(f"{key}: {value}")

for key in user.keys():
    print(key)

for value in user.values():
    print(value)
```

### Tuples

Tuples are like lists but can't be changed (immutable):

```python
# Creating tuples
colors = ("red", "green", "blue")
coordinates = (10, 20)

# Accessing items (like lists)
first_color = colors[0]          # "red"

# Tuples are immutable (can't be changed)
# colors[0] = "yellow"          # This would cause an error

# Useful for returning multiple values
def get_user_info():
    return "Alice", 25, "alice@example.com"

name, age, email = get_user_info()
```

### Sets

Sets store unique items (no duplicates):

```python
# Creating sets
tags = {"python", "django", "web", "python"}  # Duplicate "python" is ignored
# Result: {"python", "django", "web"}

# Adding items
tags.add("tutorial")

# Removing items
tags.remove("web")

# Set operations
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}

union = a | b                  # {1, 2, 3, 4, 5, 6}
intersection = a & b           # {3, 4}
difference = a - b             # {1, 2}
```

---

## P.4: Control Flow

### If Statements

Conditional logic in Python:

```python
# Basic if
age = 18
if age >= 18:
    print("You can vote")

# If-else
score = 85
if score >= 90:
    grade = "A"
else:
    grade = "B"

# If-elif-else
score = 75
if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
elif score >= 70:
    grade = "C"
else:
    grade = "F"

# Multiple conditions
age = 25
has_license = True
if age >= 18 and has_license:
    print("You can drive")

# Comparing to None
user = None
if user is None:
    print("No user found")

# Checking if in list
fruits = ["apple", "banana", "orange"]
if "apple" in fruits:
    print("Yes, we have apples")
```

### For Loops

Iterating over collections:

```python
# Loop through a list
fruits = ["apple", "banana", "orange"]
for fruit in fruits:
    print(fruit)

# Loop through a string
name = "Alice"
for char in name:
    print(char)  # A, l, i, c, e

# Loop with index
for i, fruit in enumerate(fruits):
    print(f"{i}: {fruit}")

# Loop through a range
for i in range(5):          # 0, 1, 2, 3, 4
    print(i)

for i in range(2, 5):       # 2, 3, 4
    print(i)

for i in range(0, 10, 2):   # 0, 2, 4, 6, 8
    print(i)

# Loop through dictionary
user = {"name": "Alice", "age": 25}
for key, value in user.items():
    print(f"{key}: {value}")

# Break and continue
for i in range(10):
    if i == 5:
        break                # Stops the loop
    if i % 2 == 0:
        continue             # Skips to next iteration
    print(i)
```

### While Loops

Loop until a condition is met:

```python
# Basic while loop
count = 0
while count < 5:
    print(count)
    count += 1

# While with break
while True:
    user_input = input("Enter 'quit' to stop: ")
    if user_input == "quit":
        break

# While with continue
count = 0
while count < 10:
    count += 1
    if count % 2 == 0:
        continue
    print(count)  # Prints odd numbers
```

---

## P.5: Functions

### Defining Functions

Functions are reusable blocks of code:

```python
# Basic function
def greet():
    print("Hello, World!")

greet()  # Call the function

# Function with parameters
def greet_user(username):
    print(f"Hello, {username}!")

greet_user("Alice")  # Hello, Alice!

# Function with return value
def add_numbers(a, b):
    return a + b

result = add_numbers(5, 3)    # 8

# Function with default parameters
def greet_user(username, greeting="Hello"):
    print(f"{greeting}, {username}!")

greet_user("Alice")           # Hello, Alice!
greet_user("Bob", "Hi")       # Hi, Bob!

# Function with multiple returns
def get_user_info():
    return "Alice", 25

name, age = get_user_info()

# Function with *args (variable arguments)
def sum_all(*numbers):
    total = 0
    for num in numbers:
        total += num
    return total

result = sum_all(1, 2, 3, 4, 5)  # 15

# Function with **kwargs (keyword arguments)
def print_user_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")

print_user_info(name="Alice", age=25, city="New York")

# Lambda functions (one-liners)
square = lambda x: x ** 2
result = square(5)  # 25
```

### Scope

Understanding where variables are accessible:

```python
# Global scope
global_var = "I'm global"

def my_function():
    # Local scope
    local_var = "I'm local"
    print(global_var)    # Can access global
    print(local_var)     # Can access local

my_function()
# print(local_var)      # Error! Local variable not accessible

# Modifying global variables
count = 0

def increment():
    global count  # Declare that we're using the global variable
    count += 1

increment()
print(count)  # 1
```

### Docstrings

Documenting functions:

```python
def add_numbers(a, b):
    """
    Add two numbers together.
    
    Args:
        a: First number
        b: Second number
    
    Returns:
        The sum of a and b
    
    Example:
        >>> add_numbers(5, 3)
        8
    """
    return a + b

help(add_numbers)  # Shows the documentation
```

---

## P.6: Classes and Object-Oriented Programming

### Defining Classes

Classes are blueprints for objects:

```python
# Simple class
class User:
    def __init__(self, username, email):
        """Constructor - called when creating a new user"""
        self.username = username
        self.email = email
        self.is_active = True
    
    def greet(self):
        """Instance method"""
        return f"Hello, {self.username}!"

    def deactivate(self):
        """Method that modifies the object"""
        self.is_active = False

# Creating instances
alice = User("alice123", "alice@example.com")
bob = User("bob456", "bob@example.com")

print(alice.username)       # "alice123"
print(alice.greet())        # "Hello, alice123!"
alice.deactivate()
print(alice.is_active)      # False
```

### Class Variables

```python
class User:
    # Class variable (shared by all instances)
    total_users = 0
    
    def __init__(self, username, email):
        self.username = username
        self.email = email
        # Increment class variable
        User.total_users += 1
    
    @classmethod
    def get_total_users(cls):
        """Class method - called on the class, not instances"""
        return cls.total_users

alice = User("alice", "alice@example.com")
bob = User("bob", "bob@example.com")
print(User.get_total_users())  # 2
```

### Inheritance

Creating subclasses:

```python
class User:
    def __init__(self, username):
        self.username = username
    
    def greet(self):
        return f"Hello, {self.username}!"

class Admin(User):
    def __init__(self, username, permissions):
        super().__init__(username)  # Call parent constructor
        self.permissions = permissions
    
    # Override parent method
    def greet(self):
        return f"Hello, Admin {self.username}!"
    
    # New method
    def manage_users(self):
        return "Managing users..."

admin = Admin("admin", ["read", "write"])
print(admin.greet())           # "Hello, Admin admin!"
print(admin.manage_users())    # "Managing users..."
```

---

## P.7: Modules and Imports

### Importing Modules

Modules are Python files that contain reusable code:

```python
# Import entire module
import math
print(math.pi)                # 3.14159...
print(math.sqrt(16))          # 4.0

# Import specific functions
from math import pi, sqrt
print(pi)                     # 3.14159...
print(sqrt(25))               # 5.0

# Import with alias
import datetime as dt
today = dt.date.today()

# Import all functions (not recommended)
from math import *
print(sin(0))                 # 0.0
```

### Creating Modules

**File: `utils.py`**

```python
# This is a module
def greet(name):
    return f"Hello, {name}!"

def add(a, b):
    return a + b

PI = 3.14159
```

**File: `main.py`**

```python
# Import the module
import utils

print(utils.greet("Alice"))   # "Hello, Alice!"
print(utils.add(5, 3))        # 8
print(utils.PI)               # 3.14159

# Or import specific items
from utils import greet, PI
print(greet("Bob"))           # "Hello, Bob!"
```

---

## P.8: Error Handling

### Try-Except

Handling errors gracefully:

```python
# Basic try-except
try:
    number = int("hello")
except ValueError:
    print("That's not a valid number!")

# Multiple exceptions
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero!")
except ValueError:
    print("Value error occurred!")

# Catch all exceptions
try:
    # Some risky code
    pass
except Exception as e:
    print(f"An error occurred: {e}")

# Try-except-else-finally
try:
    number = int("42")
except ValueError:
    print("Conversion failed")
else:
    print(f"Conversion successful: {number}")
finally:
    print("This always runs")

# Raising exceptions
def validate_age(age):
    if age < 0:
        raise ValueError("Age cannot be negative")
    if age > 150:
        raise ValueError("Age seems too high")
    return age

try:
    validate_age(-5)
except ValueError as e:
    print(e)  # "Age cannot be negative"
```

---

## P.9: File I/O

### Reading and Writing Files

```python
# Writing to a file
with open("data.txt", "w") as file:
    file.write("Hello, World!\n")
    file.write("This is line 2\n")

# Appending to a file
with open("data.txt", "a") as file:
    file.write("This is appended\n")

# Reading a file
with open("data.txt", "r") as file:
    content = file.read()
    print(content)

# Reading line by line
with open("data.txt", "r") as file:
    for line in file:
        print(line.strip())

# Reading into a list
with open("data.txt", "r") as file:
    lines = file.readlines()
    print(lines)  # ['Hello, World!\n', 'This is line 2\n', ...]
```

---

## P.10: Common Python Patterns for Django

### List Comprehensions

```python
# Traditional loop
squares = []
for i in range(10):
    squares.append(i ** 2)

# List comprehension
squares = [i ** 2 for i in range(10)]

# With condition
even_squares = [i ** 2 for i in range(10) if i % 2 == 0]

# For dictionaries
user_data = [
    {"name": "Alice", "age": 25},
    {"name": "Bob", "age": 30}
]

names = [user["name"] for user in user_data]  # ["Alice", "Bob"]
```

### Dictionary Comprehensions

```python
# Create dictionary from two lists
keys = ["name", "age", "city"]
values = ["Alice", 25, "New York"]
user = {k: v for k, v in zip(keys, values)}

# Filter dictionary
ages = {"Alice": 25, "Bob": 30, "Charlie": 35}
over_30 = {name: age for name, age in ages.items() if age > 30}
```

### F-Strings (String Formatting)

```python
# Python 3.6+ (recommended)
name = "Alice"
age = 25
message = f"Hello, {name}! You are {age} years old."

# Calculations in f-strings
price = 19.99
tax = 0.08
total = f"Total: ${price * (1 + tax):.2f}"  # "Total: $21.59"

# Multiple lines
email = f"""
Name: {name}
Age: {age}
Status: Active
"""

# Older methods (still used)
# % formatting
message = "Hello, %s!" % name  # "Hello, Alice!"
# .format() method
message = "Hello, {}!".format(name)  # "Hello, Alice!"
```

### The Walrus Operator (:=)

```python
# Python 3.8+
# Assign and use in one expression
data = [1, 2, 3, 4, 5]
if (count := len(data)) > 0:
    print(f"List has {count} items")

# In while loop
while (line := input("Enter something: ")) != "quit":
    print(f"You entered: {line}")
```

---

## P.11: Python in Django Context

### How Python Concepts Map to Django

| Python Concept | Django Equivalent |
|----------------|-------------------|
| **Class** | Model, Form, View |
| **Function** | View function |
| **Import** | `from .models import Post` |
| **List** | QuerySet (list of objects) |
| **Dictionary** | Context data, request.GET/request.POST |
| **String** | CharField, TextField values |
| **Boolean** | BooleanField |
| **Try-Except** | Form validation, error handling |
| **Decorators** | `@login_required`, `@csrf_exempt` |

### Real Django Code Examples

```python
# Models (Python classes)
from django.db import models

class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return self.title

# Views (Functions)
def post_list(request):
    posts = Post.objects.all()  # Queryset (like a list)
    context = {'posts': posts}  # Dictionary for templates
    return render(request, 'blog/post_list.html', context)

# Forms (Classes with validation)
from django import forms

class ContactForm(forms.Form):
    name = forms.CharField(max_length=100)
    email = forms.EmailField()
    message = forms.CharField(widget=forms.Textarea)
    
    def clean_email(self):
        email = self.cleaned_data['email']
        if not email.endswith('@example.com'):
            raise forms.ValidationError("Only example.com emails allowed")
        return email
```

---

## P.12: Common Pitfalls for Beginners

### Pitfall 1: Forgetting the Colon

```python
# Wrong
def greet(name)
    print("Hello")

# Correct
def greet(name):
    print("Hello")
```

### Pitfall 2: Indentation Errors

```python
# Wrong (mixed indentation)
def greet(name):
  print("Hello")
    print("World")  # Indentation error

# Correct (consistent indentation)
def greet(name):
    print("Hello")
    print("World")
```

### Pitfall 3: Mutable Default Arguments

```python
# Wrong (default list persists between calls)
def add_item(item, items=[]):
    items.append(item)
    return items

print(add_item(1))  # [1]
print(add_item(2))  # [1, 2]  # Unexpected!

# Correct
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### Pitfall 4: Modifying Lists While Iterating

```python
# Wrong
numbers = [1, 2, 3, 4, 5]
for num in numbers:
    if num % 2 == 0:
        numbers.remove(num)  # Modifying while iterating

# Correct
numbers = [1, 2, 3, 4, 5]
numbers = [num for num in numbers if num % 2 != 0]
```

### Pitfall 5: String vs Integer

```python
# Wrong
age = input("Enter age: ")  # age is a string
if age > 18:                # Error: comparing string to int
    print("Adult")

# Correct
age = int(input("Enter age: "))
if age > 18:
    print("Adult")
```

---

## P.13: Quick Reference: Python Cheat Sheet

### Common Operations

```python
# Strings
name.upper()           # Uppercase
name.lower()           # Lowercase
name.title()           # Title Case
name.replace('a', 'b') # Replace characters
name.split(',')        # Split into list
','.join(list)         # Join list into string

# Lists
list.append(item)      # Add item
list.extend(iterable)  # Add multiple items
list.insert(index, item) # Insert at index
list.remove(item)      # Remove item
list.pop(index)        # Remove and return item
list.index(item)       # Find index
list.sort()            # Sort in place
sorted(list)           # Return sorted list

# Dictionaries
dict[key]              # Access value
dict.get(key, default) # Safe access
dict.keys()            # Get keys
dict.values()          # Get values
dict.items()           # Get key-value pairs

# Common Functions
len(collection)        # Length
type(variable)         # Get type
str(variable)          # Convert to string
int(variable)          # Convert to integer
float(variable)        # Convert to float
list(iterable)         # Convert to list
dict(iterable)         # Convert to dictionary

# Type Checking
isinstance(obj, Class) # Check type
type(obj) == str       # Compare type
```

---

## P.14: Recommended Learning Path

### For Absolute Beginners

1. **Start with a Python course**
   - Codecademy: Learn Python
   - Python.org tutorial
   - Real Python tutorials

2. **Practice with small projects**
   - Calculator
   - To-do list
   - Number guessing game
   - Password generator

3. **Move to Django (Parts 1-3)**
   - Build the blog
   - Learn by doing

### For Self-Assessment

Ask yourself:

- Can I write variables and use basic data types?
- Can I create and use functions?
- Can I work with lists and dictionaries?
- Can I write if statements and loops?
- Can I create a simple class?
- Can I handle errors with try-except?

If yes, you're ready for Django!

---

This primer gives you all the Python you need to start building with Django. The key is to practice — try writing small Python scripts to reinforce these concepts. When you're comfortable with the basics, you're ready to start the Django series!
