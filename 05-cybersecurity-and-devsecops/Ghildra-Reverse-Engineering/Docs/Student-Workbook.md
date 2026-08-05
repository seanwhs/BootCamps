# Zero to Hero: Practical Reverse Engineering with Ghidra

## Student Workbook

### A Comprehensive Hands-On Guide with Exercises, Labs, and Projects

---

# Table of Contents

**Introduction to the Workbook**

**Module 1: Foundations and Environment Setup**
- Lesson 1.1: Installing the JDK
- Lesson 1.2: Installing Ghidra
- Lesson 1.3: Understanding Executable Formats
- Lesson 1.4: Your First Ghidra Project
- Exercise Set 1: Environment Check

**Module 2: Ghidra Interface and Navigation**
- Lesson 2.1: The Listing Window
- Lesson 2.2: The Decompiler Window
- Lesson 2.3: The Symbol Tree
- Lesson 2.4: Program Trees
- Lesson 2.5: Navigation Shortcuts
- Exercise Set 2: Interface Mastery

**Module 3: Your First Binary Analysis**
- Lesson 3.1: Creating a Sample Program
- Lesson 3.2: Importing and Analyzing
- Lesson 3.3: Renaming and Annotating
- Exercise Set 3: Analyzing the Calculator

**Module 4: Ghidra Scripting Basics**
- Lesson 4.1: Your First Script
- Lesson 4.2: Working with Functions
- Lesson 4.3: Reading Memory
- Exercise Set 4: Scripting Challenges

**Module 5: Control Flow Analysis**
- Lesson 5.1: Basic Blocks
- Lesson 5.2: Conditional Branches
- Lesson 5.3: Loops
- Lesson 5.4: Function Graph
- Exercise Set 5: Control Flow Exercises

**Module 6: Cross-References (XREFs)**
- Lesson 6.1: Finding Strings
- Lesson 6.2: Tracing Function Calls
- Lesson 6.3: Data References
- Exercise Set 6: XREF Challenges

**Module 7: XOR Decryption**
- Lesson 7.1: Understanding XOR
- Lesson 7.2: Manual Decryption
- Lesson 7.3: Automated Decryption
- Exercise Set 7: XOR Challenges

**Module 8: Binary Patching**
- Lesson 8.1: Patch Types
- Lesson 8.2: Patching in Ghidra
- Lesson 8.3: Saving Patched Binaries
- Exercise Set 8: Patching Exercises

**Module 9: Malware Analysis**
- Lesson 9.1: Static Triage
- Lesson 9.2: Behavior Analysis
- Lesson 9.3: IOC Extraction
- Exercise Set 9: Malware Lab

**Module 10: Vulnerability Research**
- Lesson 10.1: Memory Corruption
- Lesson 10.2: Data Flow Analysis
- Lesson 10.3: Vulnerability Discovery
- Exercise Set 10: Vulnerability Lab

**Module 11: Comprehensive Projects**
- Project 1: CTF Challenge - XOR Guardian
- Project 2: CTF Challenge - Serial Validator
- Project 3: Malware Analysis - Simulated
- Project 4: Vulnerability Research - Network Service

**Appendix A: Quick Reference Cards**
**Appendix B: Ghidra API Cheat Sheet**
**Appendix C: Assembly Pattern Reference**
**Appendix D: Lab Solution Guide**

---

# Introduction to the Workbook

## Welcome!

Welcome to the Zero to Hero: Practical Reverse Engineering with Ghidra Student Workbook. This workbook is designed to be your companion throughout the course, providing structured exercises, detailed lab instructions, and practical projects to reinforce your learning.

## How to Use This Workbook

### For Students

1. **Read Before Watching:** Review the lesson material before watching the corresponding video
2. **Follow Along:** Complete the exercises as you progress through the lessons
3. **Document Your Work:** Use the space provided to take notes and record findings
4. **Review Solutions:** Check your work against the solution guide when available

### For Instructors

1. **Assign Exercises:** Use the exercise sets for homework or in-class labs
2. **Check Progress:** Review completed workbooks to assess understanding
3. **Customize:** Adapt exercises to your specific teaching needs
4. **Supplement:** Use additional resources suggested in each module

## Workbook Organization

Each module contains:
- **Learning Objectives:** What you'll achieve
- **Key Concepts:** Important terms and ideas
- **Lesson Content:** Step-by-step instructions
- **Exercise Set:** Practical problems to solve
- **Check Your Understanding:** Self-assessment questions
- **Notes Section:** Space for your observations

## Prerequisites

- Basic programming experience (any language)
- Command-line comfort
- A computer with:
  - 8GB+ RAM (16GB recommended)
  - 64-bit operating system
  - 10GB+ free disk space

---

# Module 1: Foundations and Environment Setup

## Learning Objectives

By the end of this module, you will be able to:
- Install the Java Development Kit (JDK)
- Install Ghidra
- Verify your installation
- Understand the difference between JDK and JRE
- Create your first Ghidra project

## Key Concepts

| Term | Definition |
|------|------------|
| **JDK** | Java Development Kit - Required for Ghidra |
| **JRE** | Java Runtime Environment - Not sufficient |
| **Ghidra** | Software Reverse Engineering framework |
| **Project** | Container for binaries and analysis |
| **Image Base** | Preferred load address of a binary |

---

## Lesson 1.1: Installing the JDK

### Video Companion Notes

**Why JDK 17?**

Ghidra requires JDK 17 or later. The JDK (not just JRE) is required because Ghidra:
- Compiles scripts at runtime
- Analyzes binary structures
- Uses Java development tools internally

**Installation Steps:**

**Windows:**
1. Download JDK 17 from Adoptium: https://adoptium.net/
2. Run the installer
3. Set JAVA_HOME environment variable
4. Add %JAVA_HOME%\bin to PATH
5. Verify: `java -version` and `javac -version`

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
# Verify
java -version
javac -version
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install java-17-openjdk-devel -y
# Verify
java -version
javac -version
```

**macOS:**
```bash
brew install openjdk@17
sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
# Verify
java -version
javac -version
```

### 📝 Your Notes:

*Write down your installation process, any issues encountered, and how you resolved them.*

```
[Your notes here]




```

---

## Lesson 1.2: Installing Ghidra

### Video Companion Notes

**Download Steps:**

1. Go to https://ghidra-sre.org/
2. Click Download (redirects to GitHub)
3. Download the ZIP for your platform

**Installation:**

**Windows:**
1. Extract ZIP to `C:\Tools\ghidra_X.X_PUBLIC`
2. Run `ghidraRun.bat`

**Linux/macOS:**
```bash
# Extract
unzip ghidra_X.X_PUBLIC_YYYYMMDD.zip -d ~/tools/

# Make executable
chmod +x ~/tools/ghidra_X.X_PUBLIC/ghidraRun

# Run
./ghidraRun
```

**Memory Configuration:**

Edit `ghidraRun.bat` (Windows) or `ghidraRun` (Linux/macOS):
```
-Xmx4096m  # 4GB heap (recommended)
-Xmx8192m  # 8GB heap (for large binaries)
```

### 📝 Your Notes:

*Document your installation process, including any troubleshooting.*

```
[Your notes here]




```

---

## Lesson 1.3: Understanding Executable Formats

### Video Companion Notes

**PE (Portable Executable) - Windows:**

```
+-------------------+
| DOS Header (MZ)   |  <- First 64 bytes
+-------------------+
| DOS Stub          |  <- "This program cannot be run in DOS mode"
+-------------------+
| NT Headers        |  <- "PE\0\0"
| - File Header     |
| - Optional Header |
+-------------------+
| Section Headers   |
+-------------------+
| Sections          |
| - .text (code)    |
| - .data (data)    |
| - .rdata (read-only)|
| - .rsrc (resources)|
+-------------------+
```

**ELF (Executable and Linkable Format) - Linux:**

```
+-------------------+
| ELF Header        |  <- \x7FELF
+-------------------+
| Program Headers   |  <- Segments (for loading)
+-------------------+
| Sections          |
| - .text (code)    |
| - .data (data)    |
| - .rodata (read-only)|
| - .bss (uninit)   |
| - .plt (dynamic)  |
| - .got (dynamic)  |
+-------------------+
| Section Headers   |  <- For linking/debugging
+-------------------+
```

### 📝 Your Notes:

*Draw a diagram comparing PE and ELF structure:*

```
[Your diagram here]




```

---

## Lesson 1.4: Your First Ghidra Project

### Video Companion Notes

**Creating a Project:**

1. Launch Ghidra
2. Click "New Project"
3. Choose "Non-shared Project"
4. Name: `GhidraTraining`
5. Choose directory
6. Click "Finish"

**Creating a Sample Binary:**

Create `hello.c`:
```c
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
    return 0;
}
```

**Compile:**
```bash
# Linux
gcc -g -o hello hello.c

# Windows (with MinGW)
gcc -g -o hello.exe hello.c
```

**Importing to Ghidra:**

1. Click "Import File"
2. Select your binary
3. Click "OK"
4. Click "Yes" to analyze
5. Select all analyzers
6. Click "Analyze"

### 📝 Your Notes:

*Document the import process and what you observe.*

```
[Your notes here]




```

---

## Exercise Set 1: Environment Check

### Exercise 1.1: Verify Java Installation

**Task:** Confirm Java is properly installed and configured.

**Commands to run:**
```bash
java -version
javac -version
echo $JAVA_HOME  # Linux/macOS
echo %JAVA_HOME% # Windows
```

**Expected Output:**
```
java version "17.0.11" 2024-04-16 LTS
javac 17.0.11
```

**Your Results:**
```
[Paste your output here]



```

### Exercise 1.2: Verify Ghidra Installation

**Task:** Launch Ghidra and verify it runs.

**Checklist:**
- [ ] Ghidra launches without errors
- [ ] Splash screen appears
- [ ] Project Manager opens
- [ ] No Java exceptions in console

**Your Results:**
```
[Describe what you see when Ghidra launches]



```

### Exercise 1.3: Import a Simple Binary

**Task:** Write, compile, and import a simple "Hello, World!" program.

**Your Code:**
```c
[Write your code here]



```

**Compilation Command:**
```
[Your command here]

```

**Screenshot Path:**
```
[Describe the import screen]

```

### Exercise 1.4: Create a Project

**Task:** Create a Ghidra project called "MyFirstProject" and import your Hello World binary.

**Project Location:**
```
[Your project path]

```

**Binary Imported:**
```
[Binary name and path]

```

---

## Module 1: Check Your Understanding

**Question 1:** Why does Ghidra require JDK instead of just JRE?

**Your Answer:**
```




```

**Question 2:** What is the purpose of the `-Xmx` parameter in Ghidra's launch script?

**Your Answer:**
```




```

**Question 3:** What are the two major executable formats covered in this module?

**Your Answer:**
```




```

**Question 4:** What is a Ghidra project?

**Your Answer:**
```




```

---

## Module 1: Additional Resources

| Resource | Description |
|----------|-------------|
| [Adoptium JDK](https://adoptium.net/) | JDK downloads |
| [Ghidra Official Site](https://ghidra-sre.org/) | Download and documentation |
| [PE Format](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format) | Official documentation |
| [ELF Format](https://refspecs.linuxbase.org/elf/elf.pdf) | Official specification |

---

# Module 2: Ghidra Interface and Navigation

## Learning Objectives

By the end of this module, you will be able to:
- Navigate the Listing Window effectively
- Use the Decompiler Window
- Understand the Symbol Tree
- Work with Program Trees
- Use essential navigation shortcuts

## Key Concepts

| Term | Definition |
|------|------------|
| **Listing** | Disassembled code view |
| **Decompiler** | C-like representation |
| **Symbol Tree** | Functions and labels |
| **Program Trees** | File structure view |
| **Function Graph** | Visual control flow |
| **Bookmark** | Marked location for later reference |

---

## Lesson 2.1: The Listing Window

### Video Companion Notes

**What You See:**
- Addresses (left column)
- Machine code bytes
- Assembly mnemonics
- Operands
- Comments

**Color Coding:**
- **Black:** Regular code
- **Blue:** Functions/entry points
- **Red:** Data references
- **Green:** Comments

**Key Operations:**
- Click to select instruction
- Double-click to navigate references
- Right-click for context menu

### 📝 Your Notes:

*What do you notice about the Listing Window when you open a binary?*

```
[Your notes here]




```

---

## Lesson 2.2: The Decompiler Window

### Video Companion Notes

**What It Shows:**
- C-like code representation
- Function logic
- Control flow (if, for, while)
- Variable names (generic)

**Benefits:**
- Easier to understand than assembly
- Shows program logic
- Highlights complex operations

**Limitations:**
- Generic variable names
- May be inaccurate for obfuscated code
- Doesn't show low-level details

**Operations:**
- Click variables to rename
- Right-click for options
- Double-click to navigate

### 📝 Your Notes:

*Compare the decompiled code to the original source code (if available):*

```
[Your notes here]




```

---

## Lesson 2.3: The Symbol Tree

### Video Companion Notes

**What You See:**
- **Functions:** All functions in the binary
- **Labels:** Data and code labels
- **Imports:** External functions
- **Exports:** Functions made available

**Operations:**
- Expand/collapse folders
- Double-click to navigate
- Right-click for options

**Categories:**
- User-defined (renamed)
- Library functions
- Auto-named (FUN_00401000)

### 📝 Your Notes:

*List the categories of symbols you see in your binary:*

```
[Your notes here]




```

---

## Lesson 2.4: Program Trees

### Video Companion Notes

**PE Structure:**
- DOS Header
- NT Headers
- Sections
- Data Directories

**ELF Structure:**
- ELF Header
- Program Headers
- Sections

**What It's Used For:**
- Understanding file structure
- Finding sections
- Checking header information
- Identifying packed binaries

### 📝 Your Notes:

*Draw the program tree structure you see in your binary:*

```
[Your diagram here]




```

---

## Lesson 2.5: Navigation Shortcuts

### Video Companion Notes

**Essential Shortcuts:**

| Shortcut | Action |
|----------|--------|
| `G` | Go to address/function |
| `F` | Search for function |
| `Ctrl+F` | Find text |
| `X` | Show cross-references |
| `Ctrl+E` | Show decompiler |
| `F11` | Toggle focus |
| `B` | Set bookmark |
| `N` | Rename |
| `;` (semicolon) | Add comment |
| `Alt+Left/Right` | Back/Forward |

### 📝 Your Notes:

*Practice each shortcut. Which ones are most useful for your workflow?*

```
[Your notes here]




```

---

## Exercise Set 2: Interface Mastery

### Exercise 2.1: Explore the Listing Window

**Task:** Open your Hello World binary and explore the Listing Window.

**Answer these questions:**

1. What is the first instruction after the entry point?

```
[Your answer]

```

2. Where is the main function located (address)?

```
[Your answer]

```

3. What color is the entry point?

```
[Your answer]

```

### Exercise 2.2: Use the Decompiler Window

**Task:** Navigate to main and examine the decompiled code.

**Question:** What does the decompiler show for the printf call?

```
[Your answer]

```

**Question:** What generic names does the decompiler use for variables?

```
[Your answer]

```

### Exercise 2.3: Explore the Symbol Tree

**Task:** Examine the Symbol Tree and answer:

1. How many functions are in the binary?

```
[Your answer]

```

2. List three imported functions (if any):

```
[Your answer]

```

3. What functions are named in the user-defined section?

```
[Your answer]

```

### Exercise 2.4: Use Program Trees

**Task:** Open Program Trees and answer:

1. What sections does your binary have?

```
[Your answer]

```

2. What's the entry point address?

```
[Your answer]

```

3. If PE: What's the ImageBase? If ELF: What's the ELF type?

```
[Your answer]

```

### Exercise 2.5: Navigation Drill

**Task:** Practice these shortcuts (time yourself):

| Shortcut | Task | Completed? |
|----------|------|------------|
| `G` | Jump to main | [ ] |
| `Ctrl+F` | Find "Hello" | [ ] |
| `X` | Show references to printf | [ ] |
| `B` | Set a bookmark | [ ] |
| `N` | Rename a variable | [ ] |
| `Alt+Left` | Go back | [ ] |

---

## Module 2: Check Your Understanding

**Question 1:** What is the primary difference between the Listing Window and the Decompiler Window?

**Your Answer:**
```




```

**Question 2:** How do you find a function by name?

**Your Answer:**
```




```

**Question 3:** What does the Symbol Tree show?

**Your Answer:**
```




```

**Question 4:** What shortcut do you use to rename a variable?

**Your Answer:**
```




```

---

## Module 2: Additional Resources

| Resource | Description |
|----------|-------------|
| Ghidra Help → Contents | Built-in documentation |
| Ghidra → Window → Bookmarked | Manage bookmarks |
| Ghidra → Window → Function Graph | Visual control flow |

---

# Module 3: Your First Binary Analysis

## Learning Objectives

By the end of this module, you will be able to:
- Analyze a simple C program in Ghidra
- Rename variables for readability
- Add comments to document your findings
- Set correct data types
- Understand function signatures

## Key Concepts

| Term | Definition |
|------|------------|
| **Function Signature** | Return type, name, parameters |
| **Parameter** | Input to a function |
| **Local Variable** | Variable within a function |
| **Data Type** | Kind of data (int, char*, etc.) |
| **Annotation** | Comments and renamed variables |

---

## Lesson 3.1: Creating a Sample Program

### Video Companion Notes

**The Calculator Program:**

```c
#include <stdio.h>
#include <stdlib.h>

int add(int a, int b) { return a + b; }
int subtract(int a, int b) { return a - b; }
int multiply(int a, int b) { return a * b; }
int divide(int a, int b) { 
    if (b == 0) return 0;
    return a / b; 
}

void validate_access(int key, char* message) {
    char buffer[32];
    int validation = key ^ 0x5A;
    if (validation == 0x40) {
        printf("Access granted! %s\n", message);
    } else {
        printf("Access denied!\n");
    }
    strcpy(buffer, message);
    printf("Buffer content: %s\n", buffer);
}

int main() {
    int a = 10, b = 5;
    printf("Result: %d\n", add(a, b));
    validate_access(0x5A, "RE_MASTER");
    return 0;
}
```

### 📝 Your Notes:

*What do you think this program does at a high level?*

```
[Your notes here]




```

---

## Lesson 3.2: Importing and Analyzing

### Video Companion Notes

**Import Steps:**

1. Create new project
2. Import calculator binary
3. Run full analysis
4. Navigate to main

**What Ghidra Shows:**

After analysis, Ghidra identifies:
- Functions (add, subtract, multiply, divide, validate_access, main)
- Strings ("Access granted!", "Access denied!", etc.)
- Library functions (printf, strcpy)

### 📝 Your Notes:

*List the functions Ghidra identified:*

```
[Your notes here]




```

---

## Lesson 3.3: Renaming and Annotating

### Video Companion Notes

**Before Renaming:**
```c
undefined8 main(int param_1, long param_2) {
    int local_4;
    int local_8;
    // ...
}
```

**After Renaming:**
```c
int main(int argc, char** argv) {
    int a;
    int b;
    // ...
}
```

**Renaming Process:**

1. Right-click on variable
2. Select "Rename Variable"
3. Type new name
4. Press Enter

**Adding Comments:**

1. Right-click on instruction
2. Select "Comment"
3. Type explanation
4. Press Enter

### 📝 Your Notes:

*Document the process of renaming variables in validate_access:*

```
[Your notes here]




```

---

## Exercise Set 3: Analyzing the Calculator

### Exercise 3.1: Import and Analyze

**Task:** Import the calculator binary and run analysis.

**Checklist:**
- [ ] Created new project
- [ ] Imported binary
- [ ] Ran analysis
- [ ] Located main function

**Screenshot Path:**
```
[Describe what you see]

```

### Exercise 3.2: Identify Functions

**Task:** Using the Symbol Tree, list all functions:

| Function Name | Purpose (guess) |
|---------------|-----------------|
|               |                 |
|               |                 |
|               |                 |
|               |                 |
|               |                 |

### Exercise 3.3: Rename Variables

**Task:** Rename variables in the main function:

| Original Name | New Name | Why? |
|---------------|----------|------|
| param_1 | | |
| param_2 | | |
| local_4 | | |
| local_8 | | |

### Exercise 3.4: Add Comments

**Task:** Add comments to the validate_access function.

**Comment 1 - Function Purpose:**
```
[Your comment]

```

**Comment 2 - The XOR Operation:**
```
[Your comment]

```

**Comment 3 - The strcpy Vulnerability:**
```
[Your comment]

```

### Exercise 3.5: Set Data Types

**Task:** Correct data types for functions.

**main function:**
- Return type: `undefined8` → `int`
- Parameter 1: `param_1` → `argc` (int)

**validate_access function:**
- Parameter 1: `key` (int)
- Parameter 2: `message` (char*)

---

## Module 3: Check Your Understanding

**Question 1:** Why is renaming variables important in reverse engineering?

**Your Answer:**
```




```

**Question 2:** What does the XOR operation in validate_access do?

**Your Answer:**
```




```

**Question 3:** What is the vulnerability in validate_access and where does it occur?

**Your Answer:**
```




```

**Question 4:** How do you add a comment in Ghidra?

**Your Answer:**
```




```

---

# Module 4: Ghidra Scripting Basics

## Learning Objectives

By the end of this module, you will be able to:
- Write basic Python scripts in Ghidra
- Enumerate functions
- Read and write memory
- Use the FunctionManager API
- Create reusable analysis scripts

## Key Concepts

| Term | Definition |
|------|------------|
| **Script Manager** | Ghidra's interface for scripts |
| **currentProgram** | The open binary |
| **FunctionManager** | API for function operations |
| **Memory** | API for memory operations |
| **API** | Application Programming Interface |

---

## Lesson 4.1: Your First Script

### Video Companion Notes

**Script Template:**
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: My First Script
Purpose: Enumerate all functions
"""

from __future__ import print_function

def main():
    """Main entry point."""
    print("[*] Script started")
    
    if not currentProgram:
        print("[!] No program loaded")
        return
    
    print("[*] Program: {}".format(currentProgram.getName()))
    print("[*] Script complete!")

if __name__ == "__main__":
    main()
```

**Creating a Script:**

1. Window → Script Manager
2. Click "New Script"
3. Select Python
4. Name your script
5. Write the code
6. Save and run

### 📝 Your Notes:

*Document your first script creation:*

```
[Your notes here]




```

---

## Lesson 4.2: Working with Functions

### Video Companion Notes

**Key API Calls:**
```python
# Get function manager
func_manager = currentProgram.getFunctionManager()

# Get all functions
functions = func_manager.getFunctions(True)

# Iterate through functions
for func in functions:
    name = func.getName()
    entry = func.getEntryPoint()
    print(name, entry)
```

**Complete Function Enumerator:**
```python
def enumerate_functions():
    """List all functions with their entry points."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    print("[*] Functions:")
    for func in functions:
        name = func.getName()
        addr = func.getEntryPoint().getOffset()
        print("  {} at 0x{:08x}".format(name, addr))
```

### 📝 Your Notes:

*What functions did your script find in the calculator binary?*

```
[Your notes here]




```

---

## Lesson 4.3: Reading Memory

### Video Companion Notes

**Reading Bytes:**
```python
# Read 16 bytes from address
addr = toAddr(0x00401000)
data = getBytes(addr, 16)

# Display as hex
hex_str = " ".join(["{:02x}".format(b) for b in data])
print("Bytes: {}".format(hex_str))
```

**Reading Strings:**
```python
# Find strings in the program
listing = currentProgram.getListing()
defined_data = listing.getDefinedData(True)

while defined_data.hasNext():
    data = defined_data.next()
    try:
        value = str(data.getValue())
        if len(value) > 3:
            print("String at 0x{:08x}: {}".format(
                data.getAddress().getOffset(), value))
    except:
        pass
```

### 📝 Your Notes:

*What strings did your script find in the calculator binary?*

```
[Your notes here]




```

---

## Exercise Set 4: Scripting Challenges

### Exercise 4.1: Hello, Ghidra!

**Task:** Write a script that prints "Hello, Ghidra!" and the current program name.

**Your Code:**
```python
[Your code here]



```

**Output:**
```
[Paste your output here]



```

### Exercise 4.2: Function Counter

**Task:** Write a script that counts and reports the number of functions.

**Your Code:**
```python
[Your code here]



```

**Output:**
```
[Paste your output here]



```

### Exercise 4.3: Function Lister

**Task:** Write a script that lists all functions with their entry points.

**Your Code:**
```python
[Your code here]



```

**Output (Partial):**
```
[Paste your output here]



```

### Exercise 4.4: String Extractor

**Task:** Write a script that extracts and prints all strings longer than 3 characters.

**Your Code:**
```python
[Your code here]



```

**Output (Partial):**
```
[Paste your output here]



```

### Exercise 4.5: Memory Dumper

**Task:** Write a script that dumps 32 bytes from address 0x00401000 to a file.

**Your Code:**
```python
[Your code here]



```

---

## Module 4: Check Your Understanding

**Question 1:** What is the purpose of `currentProgram` in a Ghidra script?

**Your Answer:**
```




```

**Question 2:** How do you get all functions in the current program?

**Your Answer:**
```




```

**Question 3:** What does `getBytes(addr, length)` do?

**Your Answer:**
```




```

**Question 4:** How do you run a script in Ghidra?

**Your Answer:**
```




```

---

# Module 5: Control Flow Analysis

## Learning Objectives

By the end of this module, you will be able to:
- Identify basic blocks
- Analyze conditional branches
- Understand loops
- Use the Function Graph
- Reconstruct control flow

## Key Concepts

| Term | Definition |
|------|------------|
| **Basic Block** | Code with one entry, one exit |
| **Control Flow Graph** | Visual representation of paths |
| **Conditional Branch** | Decision point (if, switch) |
| **Loop** | Repeated execution |
| **Function Graph** | Ghidra's visual CFG |

---

## Lesson 5.1: Basic Blocks

### Video Companion Notes

**What is a Basic Block?**

A sequence of instructions with:
- One entry point
- One exit point
- No branches inside

**Identifying Basic Blocks:**

1. Start at function entry
2. Follow instructions
3. Stop at branch (jump, conditional)
4. Branch target starts new block

**Example:**
```
Block 1:
    push rbp
    mov rbp, rsp
    sub rsp, 0x20
    cmp eax, 0x10
    jg block_2
Block 2:
    add eax, ebx
    jmp block_3
Block 3:
    leave
    ret
```

### 📝 Your Notes:

*Draw the basic blocks for the validate_access function:*

```
[Your diagram here]




```

---

## Lesson 5.2: Conditional Branches

### Video Companion Notes

**Common Branch Patterns:**

| Assembly | C Code |
|----------|--------|
| `cmp a, b; jg label` | `if (a > b) goto label` |
| `cmp a, b; jl label` | `if (a < b) goto label` |
| `cmp a, b; je label` | `if (a == b) goto label` |
| `test a, a; jz label` | `if (a == 0) goto label` |

**If-Else Pattern:**

```assembly
cmp eax, 0x10
jg label_else
    ; if (eax <= 0x10)
    mov ebx, 1
    jmp label_end
label_else:
    ; else
    mov ebx, 0
label_end:
    mov eax, ebx
    ret
```

### 📝 Your Notes:

*How does the validate_access function use conditional branches?*

```
[Your notes here]




```

---

## Lesson 5.3: Loops

### Video Companion Notes

**For Loop Pattern:**
```
xor ecx, ecx        ; i = 0
loop_start:
cmp ecx, 0x0A       ; i < 10?
jge loop_end
    ; loop body
inc ecx             ; i++
jmp loop_start
loop_end:
```

**While Loop Pattern:**
```
loop_start:
cmp ecx, 0x0A
jge loop_end
    ; loop body
inc ecx
jmp loop_start
loop_end:
```

**Do-While Loop Pattern:**
```
loop_start:
    ; loop body
inc ecx
cmp ecx, 0x0A
jl loop_start
```

### 📝 Your Notes:

*What types of loops might you find in malware?*

```
[Your notes here]




```

---

## Lesson 5.4: Function Graph

### Video Companion Notes

**Using Function Graph:**

1. Navigate to a function
2. Click Function Graph button (or press `G`)
3. See visual control flow
4. Click blocks to navigate
5. Zoom in/out with mouse wheel

**What It Shows:**
- **Green blocks:** Entry points
- **Red blocks:** Exit points
- **Edges:** Jumps and branches
- **Arrows:** Direction of flow

**Benefits:**
- Quick understanding of flow
- Identify complex logic
- Spot obfuscation patterns

### 📝 Your Notes:

*Describe the Function Graph for validate_access:*

```
[Your notes here]




```

---

## Exercise Set 5: Control Flow Exercises

### Exercise 5.1: Identify Basic Blocks

**Task:** In the validate_access function, identify all basic blocks.

**Block 1:**
```
[Instructions and entry point]



```

**Block 2:**
```
[Instructions and entry point]



```

**Block 3:**
```
[Instructions and entry point]



```

**Block 4:**
```
[Instructions and entry point]



```

### Exercise 5.2: Analyze Conditional Branches

**Task:** Locate the conditional branch in validate_access.

**Condition:**
```
[CMP or TEST instruction]

```

**Jump Instruction:**
```
[Conditional jump]

```

**True Branch:**
```
[Instructions]

```

**False Branch:**
```
[Instructions]

```

### Exercise 5.3: Find Loops

**Task:** Search for loops in the calculator binary.

**Loop Found?:** [ ] Yes / [ ] No

**If yes, describe it:**
```
[Loop description]



```

### Exercise 5.4: Use Function Graph

**Task:** Open Function Graph for validate_access.

**Screenshot Path:**
```
[Describe what you see]

```

**Number of Blocks:**
```
[Count]

```

**Number of Edges:**
```
[Count]

```

### Exercise 5.5: Reconstruct Control Flow

**Task:** Draw a control flow diagram for validate_access.

```
[Your diagram here]





```

---

## Module 5: Check Your Understanding

**Question 1:** What is a basic block?

**Your Answer:**
```




```

**Question 2:** How does a `for` loop look in assembly?

**Your Answer:**
```




```

**Question 3:** What does the Function Graph show?

**Your Answer:**
```




```

**Question 4:** What is the difference between a conditional and unconditional jump?

**Your Answer:**
```




```

---

# Module 6: Cross-References (XREFs)

## Learning Objectives

By the end of this module, you will be able to:
- Find interesting strings
- Trace function calls
- Follow data references
- Identify code and data relationships
- Use XREFs to find validation logic

## Key Concepts

| Term | Definition |
|------|------------|
| **XREF** | Cross-reference |
| **Incoming** | References to a location |
| **Outgoing** | References from a location |
| **Code Reference** | Function call or jump |
| **Data Reference** | String or variable access |

---

## Lesson 6.1: Finding Strings

### Video Companion Notes

**Defined Strings:**

1. Window → Defined Strings
2. Browse all strings
3. Double-click to navigate
4. Press `X` for references

**Common String Patterns:**

| String | Implication |
|--------|-------------|
| "Access granted" | Validation success |
| "Access denied" | Validation failure |
| "FLAG{" | Flag location |
| "http://" | Network communication |
| "password" | Authentication |

### 📝 Your Notes:

*What interesting strings did you find in the calculator binary?*

```
[Your notes here]




```

---

## Lesson 6.2: Tracing Function Calls

### Video Companion Notes

**Finding Who Calls a Function:**

1. Navigate to function
2. Right-click → Show References to Function
3. View callers
4. Click to navigate

**Finding What a Function Calls:**

1. Navigate to function
2. Right-click → Show References from Function
3. View callees
4. Click to navigate

**Trace Pattern:**
```
main() → validate_access() → printf()
                    → strcpy()
```

### 📝 Your Notes:

*Who calls validate_access? What does validate_access call?*

```
[Your notes here]




```

---

## Lesson 6.3: Data References

### Video Companion Notes

**Finding String Usage:**

1. Find string in Defined Strings
2. Double-click to navigate
3. Press `X`
4. See all references

**Following Data Flow:**
```
String Address → XREFs → Instructions → Function
```

**Example:**
```
"Access granted!" at 0x00402028
    ↓ (XREF)
    lea rdi, [rip+0x0d6d] ; load string
    call printf
    ↓ (Function)
    validate_access()
```

### 📝 Your Notes:

*Follow the references for "Access granted!"*

```
[Your trace]




```

---

## Exercise Set 6: XREF Challenges

### Exercise 6.1: Find the Flag

**Task:** In the calculator binary, find where "RE_MASTER" is used.

**String Found At:**
```
[Address]

```

**Reference Location:**
```
[Address/Function]

```

### Exercise 6.2: Trace Validation Logic

**Task:** Find who calls validate_access and follow the data flow.

**Caller:**
```
[Function name and address]

```

**Calling Instruction:**
```
[Assembly]

```

**Parameters Passed:**
```
[Values]

```

### Exercise 6.3: Find All Printf Calls

**Task:** Use XREFs to find all printf calls.

**Number of printf calls:**
```
[Count]

```

**Functions that use printf:**
```
[Function names]

```

### Exercise 6.4: Trace String Usage

**Task:** Trace "Access denied!" from string to usage.

**String Address:**
```
[Address]

```

**First Reference:**
```
[Address/Instruction]

```

**Calling Function:**
```
[Function name]

```

### Exercise 6.5: Find Suspicious Calls

**Task:** Find all calls to strcpy (vulnerable function).

**Number of strcpy calls:**
```
[Count]

```

**Locations:**
```
[Addresses and functions]

```

---

## Module 6: Check Your Understanding

**Question 1:** What is a cross-reference (XREF)?

**Your Answer:**
```




```

**Question 2:** How do you find who calls a specific function?

**Your Answer:**
```




```

**Question 3:** What's the difference between incoming and outgoing references?

**Your Answer:**
```




```

**Question 4:** How can XREFs help find validation logic?

**Your Answer:**
```




```

---

# Module 7: XOR Decryption

## Learning Objectives

By the end of this module, you will be able to:
- Understand XOR encryption
- Manually decrypt XOR-encrypted data
- Write scripts for XOR decryption
- Identify XOR patterns in assembly
- Recover encrypted secrets

## Key Concepts

| Term | Definition |
|------|------------|
| **XOR** | Bitwise exclusive OR |
| **Key** | The value used for encryption |
| **Ciphertext** | Encrypted data |
| **Plaintext** | Decrypted data |
| **Symmetric** | Same operation encrypts/decrypts |

---

## Lesson 7.1: Understanding XOR

### Video Companion Notes

**XOR Properties:**

| Property | Example |
|----------|---------|
| A XOR B = B XOR A | 5 XOR 3 = 3 XOR 5 |
| (A XOR B) XOR B = A | (5 XOR 3) XOR 3 = 5 |
| A XOR 0 = A | 5 XOR 0 = 5 |
| A XOR A = 0 | 5 XOR 5 = 0 |

**XOR as Encryption:**
```
Plaintext:  "HELLO"
Key:        0x42
Ciphertext: H^0x42, E^0x42, L^0x42, L^0x42, O^0x42
```

**XOR as Decryption:**
```
Ciphertext ^ Key = Plaintext
(Plaintext ^ Key) ^ Key = Plaintext
```

### 📝 Your Notes:

*Why is XOR commonly used for obfuscation in CTF challenges?*

```
[Your notes here]




```

---

## Lesson 7.2: Manual Decryption

### Video Companion Notes

**Example from validate_access:**

```c
int key = 0x5A;
int validation = key ^ 0x1A;
if (validation == 0x40) {
    // Access granted
}
```

**Solving for key:**
```
key ^ 0x1A = 0x40
key = 0x40 ^ 0x1A
key = 0x5A
```

**Manual Decryption Steps:**

1. Identify the XOR operation
2. Extract encrypted data
3. Find or guess the key
4. XOR each byte with the key
5. Verify the result

### 📝 Your Notes:

*Work through the XOR operation in validate_access:*

```
[Your work]




```

---

## Lesson 7.3: Automated Decryption

### Video Companion Notes

**XOR Decryptor Script:**
```python
def xor_decrypt(data, key):
    """Decrypt data using XOR with a single-byte key."""
    result = []
    for byte in data:
        if byte == 0:
            break
        result.append(chr(byte ^ key))
    return ''.join(result)

# Usage
encrypted = [0x35, 0x2B, 0x32]
key = 0x42
decrypted = xor_decrypt(encrypted, key)
print(decrypted)  # "HELLO"
```

**Finding Encrypted Data:**
```python
# Look for byte arrays in the program
listing = currentProgram.getListing()
data = listing.getDefinedData(True)

while data.hasNext():
    d = data.next()
    data_type = d.getDataType()
    if "array" in str(data_type):
        addr = d.getAddress()
        length = data_type.getLength()
        bytes_data = getBytes(addr, length)
        # Try to decrypt with common keys
```

### 📝 Your Notes:

*What common XOR keys might you find in CTF challenges?*

```
[Your notes here]




```

---

## Exercise Set 7: XOR Challenges

### Exercise 7.1: Manual XOR Decryption

**Task:** Decrypt the following XOR-encrypted data.

```
Encrypted: 0x3B 0x52 0x4D 0x52
Key: 0x5A

Plaintext:
[Your calculation]

```

### Exercise 7.2: Find the XOR Key

**Task:** The following encrypted data decrypts to "FLAG". Find the key.

```
Encrypted: 0x37 0x2B 0x32 0x24
Plaintext:  F    L    A    G

Key:
[Your calculation]

```

### Exercise 7.3: Identify XOR Pattern

**Task:** In the calculator binary, find the XOR operation in validate_access.

**XOR Location:**
```
[Address/Instruction]

```

**XOR Operands:**
```
[What's being XORed?]

```

### Exercise 7.4: Write XOR Decryptor

**Task:** Write a script to decrypt data from a file or memory.

**Your Code:**
```python
[Your code here]



```

**Test Data:**
```
Encrypted: [0x35, 0x2B, 0x32]
Key: 0x42
Expected: "HELLO"
```

**Your Results:**
```
[Paste your output]

```

### Exercise 7.5: Recover the Flag

**Task:** Use XOR to recover the flag hidden in validate_access.

**What is the validation key?**
```
[Your answer]

```

**What is the secret message?**
```
[Your answer]

```

---

## Module 7: Check Your Understanding

**Question 1:** What are the properties of XOR that make it useful for encryption?

**Your Answer:**
```




```

**Question 2:** How do you decrypt data that was XOR-encrypted with a key?

**Your Answer:**
```




```

**Question 3:** What is the XOR key in the validate_access function?

**Your Answer:**
```




```

**Question 4:** Why might a CTF challenge use XOR encryption?

**Your Answer:**
```




```

---

# Module 8: Binary Patching

## Learning Objectives

By the end of this module, you will be able to:
- Understand different patch types
- Patch instructions in Ghidra
- Patch data and constants
- Save patched binaries
- Bypass authentication checks

## Key Concepts

| Term | Definition |
|------|------------|
| **Patch** | Modification to binary code |
| **NOP** | No Operation instruction |
| **Bypass** | Circumvent a check |
| **Patch Instruction** | Modify an instruction |
| **Patch Bytes** | Modify raw bytes |

---

## Lesson 8.1: Patch Types

### Video Companion Notes

**Conditional Jump Modification:**

| Original | Modified | Effect |
|----------|----------|--------|
| `jne label` | `jmp label` | Always take branch |
| `jne label` | `nop`* | Remove branch |
| `jne label` | `je label` | Invert condition |

*Must replace with same number of bytes

**Constant Modification:**
```
cmp eax, 0x40 → cmp eax, 0x00
```

**Instruction Replacement:**
```
call exit → nop; nop; nop; ...
```

**Data Modification:**
```
"Access denied" → "Access granted"
```

### 📝 Your Notes:

*What kind of patch would bypass the authentication in validate_access?*

```
[Your notes here]




```

---

## Lesson 8.2: Patching in Ghidra

### Video Companion Notes

**Method 1: Patch Instruction**

1. Right-click instruction
2. Select "Patch Instruction"
3. Modify mnemonic/operands
4. Click "OK"

**Method 2: Patch Bytes**

1. Right-click address
2. Select "Patch Bytes"
3. Enter new bytes (hex)
4. Click "OK"

**Method 3: Scripting**

```python
# Write NOPs at address
setByte(addr, 0x90)  # NOP instruction
```

### 📝 Your Notes:

*Practice each method. Which is easiest for you?*

```
[Your notes here]




```

---

## Lesson 8.3: Saving Patched Binaries

### Video Companion Notes

**Exporting Patched Program:**

1. File → Export Program
2. Choose format (Original File, ELF, PE)
3. Select filename
4. Click "OK"

**Testing:**

1. Run patched binary
2. Verify behavior change
3. Compare to original

### 📝 Your Notes:

*How do you test a patched binary?*

```
[Your notes here]




```

---

## Exercise Set 8: Patching Exercises

### Exercise 8.1: Bypass Authentication

**Task:** Patch validate_access to always grant access.

**Patch Location:**
```
[Address/Instruction]

```

**Original Instruction:**
```
[Assembly]

```

**Patched Instruction:**
```
[Assembly]

```

**Method Used:**
```
[Patch Instruction / Patch Bytes / Script]

```

### Exercise 8.2: NOP Out a Function Call

**Task:** Find a function call and NOP it out.

**Original Code:**
```
[Address and instruction]

```

**Bytes to Replace:**
```
[Original bytes]

```

**Patched Bytes:**
```
[New bytes]

```

### Exercise 8.3: Change a Constant

**Task:** Modify the XOR key in validate_access.

**Original Constant:**
```
[Value and location]

```

**New Constant:**
```
[Value]

```

### Exercise 8.4: Patch Script

**Task:** Write a script to automatically patch validate_access.

**Your Code:**
```python
[Your code here]



```

**Patch Applied:**
```
[Description of what your script does]

```

### Exercise 8.5: Test Patched Binary

**Task:** Export and test your patched binary.

**Export Settings:**
```
[Format and filename]

```

**Test Result:**
```
[What happened when you ran it?]

```

---

## Module 8: Check Your Understanding

**Question 1:** What is a NOP instruction and why is it used in patching?

**Your Answer:**
```




```

**Question 2:** How do you bypass an authentication check?

**Your Answer:**
```




```

**Question 3:** What's the difference between "Patch Instruction" and "Patch Bytes"?

**Your Answer:**
```




```

**Question 4:** How do you save a patched binary?

**Your Answer:**
```




```

---

# Module 9: Malware Analysis

## Learning Objectives

By the end of this module, you will be able to:
- Perform static malware triage
- Identify packed executables
- Extract Indicators of Compromise (IOCs)
- Understand malware behavior
- Create detection rules

## Key Concepts

| Term | Definition |
|------|------------|
| **Triage** | Initial assessment |
| **IOC** | Indicator of Compromise |
| **C2** | Command and Control |
| **YARA** | Pattern-matching language |
| **Packed** | Compressed/encrypted binary |

---

## Lesson 9.1: Static Triage

### Video Companion Notes

**Triage Checklist:**

| Item | Tool | What to Look For |
|------|------|------------------|
| File type | `file` | ELF, PE, script |
| File size | `ls -lh` | Unusually small/large |
| Stripped | `file` | No debug symbols |
| Strings | `strings` | URLs, domains, APIs |
| Entropy | Custom script | > 7.5 = packed |
| Imports | `readelf -d` | Suspicious functions |

**Packing Indicators:**
- High entropy sections
- Strange section names (UPX0, UPX1)
- Small .text section
- Few imports

### 📝 Your Notes:

*What steps would you take to triage a suspicious binary?*

```
[Your notes here]




```

---

## Lesson 9.2: Behavior Analysis

### Video Companion Notes

**Common Malware Behaviors:**

| Behavior | Indicators |
|----------|------------|
| **Process Injection** | `VirtualAllocEx`, `WriteProcessMemory` |
| **Persistence** | Registry Run keys, scheduled tasks |
| **C2 Communication** | `socket`, `connect`, HTTP strings |
| **Anti-Analysis** | `IsDebuggerPresent`, timing checks |
| **File Operations** | `CreateFile`, `WriteFile`, `DeleteFile` |

**The Attack Chain:**

1. Initial Execution
2. Anti-Analysis Checks
3. C2 Communication
4. Command Execution
5. Persistence Installation

### 📝 Your Notes:

*What suspicious behaviors would you look for in a malware sample?*

```
[Your notes here]




```

---

## Lesson 9.3: IOC Extraction

### Video Companion Notes

**Types of IOCs:**

| Type | Examples |
|------|----------|
| **Domains** | malicious-server.com |
| **IPs** | 192.168.1.100 |
| **URLs** | http://bad.com/payload.exe |
| **Registry** | HKCU\Run\Malware |
| **Files** | C:\Windows\system32\malware.exe |
| **Hashes** | MD5, SHA1, SHA256 |

**YARA Rule Example:**

```yara
rule Malware_Detector {
    meta:
        author = "Your Name"
        description = "Detects malware"
    strings:
        $c2_domain = "malicious-server.com"
        $registry = "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\Malware"
    condition:
        $c2_domain or $registry
}
```

### 📝 Your Notes:

*What IOCs would you extract from a suspicious binary?*

```
[Your notes here]




```

---

## Exercise Set 9: Malware Lab

### Exercise 9.1: Triage a Suspected Malware

**Task:** Given a binary, perform initial triage.

**File Type:**
```
[Result of `file` command]

```

**File Size:**
```
[Result]

```

**Entropy:**
```
[Result]

```

**Suspicious Strings:**
```
[List at least 5]

```

**Suspicious Imports:**
```
[List at least 3]

```

### Exercise 9.2: Identify Packing

**Task:** Determine if the binary is packed.

**Packing Indicators Found:**
```
[List with explanations]

```

**Likely Packer:**
```
[Your guess]

```

### Exercise 9.3: Extract IOCs

**Task:** Extract IOCs from the binary.

**Domains:**
```
[List]

```

**IPs:**
```
[List]

```

**Registry Paths:**
```
[List]

```

**File Paths:**
```
[List]

```

### Exercise 9.4: Analyze Behavior

**Task:** Describe the malware's behavior based on static analysis.

**Anti-Analysis Techniques:**
```
[Describe]

```

**C2 Communication:**
```
[Describe]

```

**Persistence:**
```
[Describe]

```

**Potential Damage:**
```
[Describe]

```

### Exercise 9.5: Create YARA Rule

**Task:** Write a YARA rule to detect the malware.

```yara
[Your YARA rule]



```

---

## Module 9: Check Your Understanding

**Question 1:** What is the difference between packed and unpacked malware?

**Your Answer:**
```




```

**Question 2:** What are Indicators of Compromise (IOCs)?

**Your Answer:**
```




```

**Question 3:** What is a YARA rule and what is it used for?

**Your Answer:**
```




```

**Question 4:** What are the key steps in static malware triage?

**Your Answer:**
```




```

---

# Module 10: Vulnerability Research

## Learning Objectives

By the end of this module, you will be able to:
- Identify memory corruption vulnerabilities
- Perform data flow analysis
- Detect unsafe function calls
- Automate vulnerability discovery
- Understand exploit development basics

## Key Concepts

| Term | Definition |
|------|------------|
| **Memory Corruption** | Overwriting memory improperly |
| **Buffer Overflow** | Writing beyond buffer bounds |
| **Format String** | Using user input as format |
| **Data Flow** | How data moves through program |
| **Sink** | Dangerous function |

---

## Lesson 10.1: Memory Corruption

### Video Companion Notes

**Types of Memory Corruption:**

| Type | Description | Example |
|------|-------------|---------|
| **Stack Overflow** | Overwriting stack variables | `strcpy(buffer, input)` |
| **Heap Overflow** | Overwriting heap memory | `malloc` + `strcpy` |
| **Format String** | User input as format | `printf(user_input)` |
| **Integer Overflow** | Arithmetic wrap | `size * 2` overflow |
| **Use-After-Free** | Accessing freed memory | `free(ptr); ptr[0] = 0;` |

**Stack Layout:**
```
Higher Addresses:
+-------------------+
| Arguments         |
+-------------------+
| Return Address    |  <- Overwrite to redirect
+-------------------+
| Saved Frame Ptr   |
+-------------------+
| Local Variables   |  <- Overflow point
+-------------------+
Lower Addresses:
```

### 📝 Your Notes:

*Describe how a stack buffer overflow works:*

```
[Your notes here]




```

---

## Lesson 10.2: Data Flow Analysis

### Video Companion Notes

**Data Flow Concepts:**

- **Source:** Where input enters (recv, read, fgets)
- **Sink:** Where dangerous function is called (strcpy, sprintf)
- **Propagation:** How data moves (assignments, calls)
- **Sanitization:** Validation/cleaning of data

**Tracing Data Flow:**

```
Source (recv)
    ↓
Propagation (assignment)
    ↓
Propagation (function call)
    ↓
Sink (strcpy)
```

### 📝 Your Notes:

*Trace the data flow in validate_access:*

```
[Your trace]




```

---

## Lesson 10.3: Vulnerability Discovery

### Video Companion Notes

**Automated Detection:**

```python
# Find dangerous functions
dangerous = ['strcpy', 'sprintf', 'gets']

for func in functions:
    body = func.getBody()
    instructions = listing.getInstructions(body, True)
    
    for instr in instructions:
        if instr.isCall():
            for target in instr.getFlows():
                target_func = getFunctionAt(target)
                if target_func and target_func.getName() in dangerous:
                    print("Vulnerability: {} at 0x{:08x}".format(
                        target_func.getName(),
                        instr.getAddress().getOffset()
                    ))
```

### 📝 Your Notes:

*What vulnerabilities exist in the calculator program?*

```
[Your notes here]




```

---

## Exercise Set 10: Vulnerability Lab

### Exercise 10.1: Identify Unsafe Functions

**Task:** Find all unsafe function calls in the calculator binary.

| Function | Location | Vulnerability Type |
|----------|----------|-------------------|
|          |          |                   |
|          |          |                   |
|          |          |                   |

### Exercise 10.2: Trace Data Flow

**Task:** Trace data flow from source to sink in validate_access.

**Source:**
```
[Where does input come from?]

```

**Sink:**
```
[Where is the vulnerable function?]

```

**Path:**
```
[Trace the data flow]

```

### Exercise 10.3: Vulnerability Scanner

**Task:** Write a script to detect unsafe function calls.

**Your Code:**
```python
[Your code here]



```

**Found Vulnerabilities:**
```
[Output]

```

### Exercise 10.4: Exploit Calculation

**Task:** Calculate the overflow size for validate_access.

**Buffer Size:**
```
[Size in bytes]

```

**Offset to Return Address:**
```
[Calculate]

```

**Payload Size:**
```
[Calculate]

```

### Exercise 10.5: Mitigation Analysis

**Task:** How would you fix the vulnerability in validate_access?

**Vulnerable Code:**
```c
[Identify the vulnerable line]

```

**Fixed Code:**
```c
[Write fixed version]

```

---

## Module 10: Check Your Understanding

**Question 1:** What is a stack buffer overflow?

**Your Answer:**
```




```

**Question 2:** What is a format string vulnerability?

**Your Answer:**
```




```

**Question 3:** How can you automate vulnerability discovery?

**Your Answer:**
```




```

**Question 4:** What are common unsafe functions in C?

**Your Answer:**
```




```

---

# Module 11: Comprehensive Projects

## Project 1: CTF Challenge - XOR Guardian

### Challenge Description

A mysterious binary guards a secret flag. The program asks for a password and validates it using a simple XOR operation.

**Your Task:** Reverse engineer the binary to find the password and recover the flag.

### Project Steps

**Step 1: Triage**
- File type: ____
- Interesting strings: ____
- Likely purpose: ____

**Step 2: Import and Analyze**
- Locate main function
- Find validation logic
- Identify XOR operation

**Step 3: Recover the Password**
- What is the XOR key? ____
- What is the hidden string? ____
- Recovered password: ____

**Step 4: Test**
- Password works? [ ] Yes [ ] No
- Flag recovered? ____

### 📝 Your Notes:

*Document your process here:*

```




```

---

## Project 2: CTF Challenge - Serial Validator

### Challenge Description

A program implements a complex serial validation algorithm. Your task is to reverse engineer the algorithm and generate a valid serial number.

**Your Task:** Analyze the serial validation function and create a keygen.

### Project Steps

**Step 1: Locate Validation Function**

Function name: ____

**Step 2: Understand Algorithm**

What does the algorithm do?
```

```

**Step 3: Create Keygen**

Your keygen code:
```python



```

**Step 4: Test Generated Serial**

Serial generated: ____

Does it work? [ ] Yes [ ] No

### 📝 Your Notes:

*Document your analysis:*

```




```

---

## Project 3: Malware Analysis - Simulated Sample

### Challenge Description

You've been given a binary that appears to be malware. Your task is to analyze it statically and extract all IOCs.

**Your Task:** Perform complete malware analysis.

### Project Steps

**Step 1: Triage**

| Item | Result |
|------|--------|
| File Type | |
| Size | |
| Entropy | |
| Packed? | |

**Step 2: IOCs Extracted**

| Type | IOC |
|------|-----|
| Domains | |
| IPs | |
| Registry | |
| Files | |

**Step 3: Behavior Analysis**

What does the malware do?
```

```

**Step 4: YARA Rule**

Your YARA rule:
```yara



```

### 📝 Your Notes:

*Document your findings:*

```




```

---

## Project 4: Vulnerability Research - Network Service

### Challenge Description

A network service contains multiple vulnerabilities. Your task is to identify them and understand the attack vectors.

**Your Task:** Find and document all vulnerabilities.

### Project Steps

**Step 1: Identify Input Surface**

Where does user input enter?
```

```

**Step 2: Trace Data Flow**

Trace data from input to sink:
```

```

**Step 3: Identify Vulnerabilities**

| Vulnerability | Location | Severity |
|---------------|----------|----------|
|               |          |          |
|               |          |          |
|               |          |          |

**Step 4: Mitigation Recommendations**

How would you fix each vulnerability?
```

```

### 📝 Your Notes:

*Document your analysis:*

```




```

---

# Appendix A: Quick Reference Cards

## Ghidra Navigation Shortcuts

| Shortcut | Action |
|----------|--------|
| `G` | Go to address/function |
| `F` | Search for function |
| `Ctrl+F` | Find text |
| `X` | Show cross-references |
| `Ctrl+E` | Show decompiler |
| `F11` | Toggle focus |
| `B` | Set/clear bookmark |
| `N` | Rename symbol |
| `;` (semicolon) | Add comment |
| `Alt+Left/Right` | Back/Forward |
| `Ctrl+S` | Save program |

## Common Assembly Mnemonics

| Mnemonic | Meaning |
|----------|---------|
| `MOV` | Move data |
| `PUSH` | Push onto stack |
| `POP` | Pop from stack |
| `ADD` | Add |
| `SUB` | Subtract |
| `MUL` | Multiply (unsigned) |
| `IMUL` | Multiply (signed) |
| `CMP` | Compare |
| `TEST` | Test (AND without storing) |
| `JMP` | Unconditional jump |
| `JZ/JE` | Jump if zero/equal |
| `JNZ/JNE` | Jump if not zero/not equal |
| `JG/JNLE` | Jump if greater (signed) |
| `JL/JNGE` | Jump if less (signed) |
| `CALL` | Call function |
| `RET` | Return from function |
| `NOP` | No operation |

## Ghidra Python API Quick Reference

| Object | How to Get | Key Methods |
|--------|------------|-------------|
| `Program` | `currentProgram` | `getName()`, `getFunctionManager()` |
| `FunctionManager` | `currentProgram.getFunctionManager()` | `getFunctions()`, `getFunctionAt()` |
| `Function` | `func_manager.getFunctions()` | `getName()`, `getEntryPoint()` |
| `Address` | `toAddr()` | `getOffset()`, `add()` |
| `Listing` | `currentProgram.getListing()` | `getInstructions()`, `getDefinedData()` |
| `SymbolTable` | `currentProgram.getSymbolTable()` | `getSymbols()`, `getExternalSymbols()` |

## Common Useful Ghidra Commands

| Command | Purpose |
|---------|---------|
| `Window → Defined Strings` | View all strings |
| `Window → Symbol Tree` | View symbols |
| `Window → Function Graph` | Visual CFG |
| `Window → Script Manager` | Run scripts |
| `File → Export Program` | Save patched binary |
| `Search → For Strings` | Find strings |
| `Analyze → Auto Analyze` | Run analysis |

---

# Appendix B: Ghidra API Cheat Sheet

## Getting Started

```python
# Get the current program
program = currentProgram

# Get the current address
addr = currentAddress

# Create an address
addr = toAddr(0x00401000)
```

## Working with Functions

```python
# Get function manager
func_manager = currentProgram.getFunctionManager()

# Get all functions
functions = func_manager.getFunctions(True)

# Get a specific function
func = func_manager.getFunctionAt(addr)
func = func_manager.getFunctionNamed("main")

# Get function properties
name = func.getName()
entry = func.getEntryPoint()
body = func.getBody()
params = func.getParameters()

# Rename a function
func.setName("new_name", SourceType.USER_DEFINED)
```

## Working with Memory

```python
# Read bytes
data = getBytes(addr, length)

# Read specific types
byte_val = getByte(addr)
short_val = getShort(addr)
int_val = getInt(addr)
long_val = getLong(addr)

# Write bytes
setByte(addr, 0x90)
setBytes(addr, [0x90, 0x90, 0x90])

# Check memory
memory = currentProgram.getMemory()
if memory.contains(addr):
    # Read it
```

## Working with Listing

```python
# Get listing
listing = currentProgram.getListing()

# Get instructions
instr = listing.getInstructionAt(addr)
instructions = listing.getInstructions(addr, True)

# Iterate instructions
while instructions.hasNext():
    instr = instructions.next()
    mnemonic = instr.getMnemonicString()
    address = instr.getAddress()

# Get defined data
data = listing.getDefinedData(True)
while data.hasNext():
    d = data.next()
    value = str(d.getValue())
```

## Working with XREFs

```python
# Get reference manager
ref_manager = currentProgram.getReferenceManager()

# References to address
refs_to = ref_manager.getReferencesTo(addr)
while refs_to.hasNext():
    ref = refs_to.next()
    source = ref.getSourceAddress()

# References from address
refs_from = ref_manager.getReferencesFrom(addr)
while refs_from.hasNext():
    ref = refs_from.next()
    target = ref.getToAddress()
```

## Common Script Patterns

```python
# Iterate through all functions
for func in currentProgram.getFunctionManager().getFunctions(True):
    print(func.getName())

# Find strings
listing = currentProgram.getListing()
data = listing.getDefinedData(True)
while data.hasNext():
    d = data.next()
    try:
        value = str(d.getValue())
        if "flag" in value.lower():
            print("Flag found!")
    except:
        pass

# Safe memory reading
try:
    data = getBytes(addr, 16)
except MemoryAccessException as e:
    print("Memory access error: {}".format(str(e)))
```

---

# Appendix C: Assembly Pattern Reference

## Function Prologue/Epilogue

### x86_64
```assembly
; Prologue
push rbp
mov rbp, rsp
sub rsp, 0x20

; Epilogue
mov rsp, rbp
pop rbp
ret

; Or simply:
leave
ret
```

### x86
```assembly
; Prologue
push ebp
mov ebp, esp
sub esp, 0x20

; Epilogue
mov esp, ebp
pop ebp
ret
```

## If-Else Patterns

```assembly
; if (a > b) { ... } else { ... }
cmp eax, ebx
jle else_label
    ; if true block
    jmp end_label
else_label:
    ; else block
end_label:
```

## Loop Patterns

### For Loop
```assembly
xor ecx, ecx     ; i = 0
loop_start:
cmp ecx, 0x0A    ; i < 10?
jge loop_end
    ; loop body
inc ecx          ; i++
jmp loop_start
loop_end:
```

### While Loop
```assembly
loop_start:
cmp ecx, 0x0A
jge loop_end
    ; loop body
inc ecx
jmp loop_start
loop_end:
```

### Do-While Loop
```assembly
loop_start:
    ; loop body
inc ecx
cmp ecx, 0x0A
jl loop_start
```

## Parameter Access

### x86_64 (Linux System V)
```assembly
; Arguments: rdi, rsi, rdx, rcx, r8, r9
mov eax, edi     ; First argument
mov eax, esi     ; Second argument
```

### x86_64 (Windows x64)
```assembly
; Arguments: rcx, rdx, r8, r9
mov eax, ecx     ; First argument
mov eax, edx     ; Second argument
```

### x86
```assembly
; Arguments on stack (ebp+8, ebp+12, etc.)
mov eax, [ebp+0x8]  ; First argument
mov eax, [ebp+0xC]  ; Second argument
```

---

# Appendix D: Lab Solution Guide

## Module 1 Solutions

### Exercise 1.1
```
java version "17.0.11" 2024-04-16 LTS
OpenJDK Runtime Environment ...
OpenJDK 64-Bit Server VM ...
```

### Exercise 1.2
Ghidra launches with:
- Project Manager window
- No error messages
- Splash screen

### Exercise 1.3
```c
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
    return 0;
}
```

## Module 2 Solutions

### Exercise 2.1
1. Entry point varies but typically:
   - PE: `start` or `_WinMain@16`
   - ELF: `_start`
2. Main function address: Depends on binary
3. Entry point is typically blue

### Exercise 2.2
Decompiler shows printf call with string literal.

### Exercise 2.3
Number of functions depends on binary and compilation.

### Exercise 2.4
Sections typically include:
- PE: .text, .data, .rdata, .rsrc
- ELF: .text, .data, .rodata, .bss

## Module 3 Solutions

### Exercise 3.1
Import and analysis completed when you see:
- Functions in Symbol Tree
- Code in Listing
- Decompiler output

### Exercise 3.2
Functions in calculator:
1. `main` - Main program logic
2. `add` - Addition operation
3. `subtract` - Subtraction
4. `multiply` - Multiplication
5. `divide` - Division
6. `validate_access` - Hidden validation

### Exercise 3.3
| Original | New | Why |
|----------|-----|-----|
| param_1 | argc | Command-line arguments count |
| param_2 | argv | Command-line arguments |
| local_4 | a | First operand |
| local_8 | b | Second operand |

### Exercise 3.4
Comments should explain:
1. Purpose: Validate access with XOR
2. XOR Operation: key ^ 0x1A == 0x40
3. Vulnerability: strcpy without bounds checking

## Module 4 Solutions

### Exercise 4.1
```python
def main():
    print("[*] Hello, Ghidra!")
    print("[*] Program: {}".format(currentProgram.getName()))
```

### Exercise 4.2
```python
def main():
    func_manager = currentProgram.getFunctionManager()
    count = func_manager.getFunctionCount()
    print("[*] Total functions: {}".format(count))
```

### Exercise 4.3
```python
def main():
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    for func in functions:
        print("{} at 0x{:08x}".format(
            func.getName(),
            func.getEntryPoint().getOffset()))
```

### Exercise 4.4
```python
def main():
    listing = currentProgram.getListing()
    data = listing.getDefinedData(True)
    while data.hasNext():
        d = data.next()
        try:
            value = str(d.getValue())
            if len(value) > 3:
                print(value)
        except:
            pass
```

## Module 8 Solutions

### Exercise 8.1
To bypass authentication, patch the conditional jump:
```
jne label  →  nop; nop; ...
```
or change to:
```
jne label  →  jmp label  (always take branch)
```

### Exercise 8.2
NOP out a call by replacing with NOP instructions:
```
call function  →  90 90 90 90 90
```

### Exercise 8.3
Change the XOR key from 0x5A to something else.

---

# Student Notes Section

## Important Observations

```
[Document key observations from your reverse engineering journey]








```

## Questions for Further Study

```
[List questions you want to research further]








```

## Resources and References

```
[Document useful resources, links, and references]








```

## Key Learnings

```
[Summarize the most important things you've learned]








```

---

# Workbook Completion Checklist

## Module 1
- [ ] JDK installed
- [ ] Ghidra installed
- [ ] First project created
- [ ] All exercises completed

## Module 2
- [ ] Listing Window explored
- [ ] Decompiler Window used
- [ ] Symbol Tree understood
- [ ] Program Trees examined
- [ ] Navigation shortcuts practiced

## Module 3
- [ ] Calculator binary analyzed
- [ ] Variables renamed
- [ ] Comments added
- [ ] Data types set

## Module 4
- [ ] First script written
- [ ] Function enumeration script
- [ ] Memory read script
- [ ] All exercises completed

## Module 5
- [ ] Basic blocks identified
- [ ] Branches analyzed
- [ ] Loops found
- [ ] Function Graph used

## Module 6
- [ ] Strings found
- [ ] Function calls traced
- [ ] XREFs used effectively

## Module 7
- [ ] XOR decryption performed
- [ ] XOR decryptor script written
- [ ] Flag recovered

## Module 8
- [ ] Binary patches applied
- [ ] Patched binary exported
- [ ] Bypass achieved

## Module 9
- [ ] Malware triage performed
- [ ] IOCs extracted
- [ ] YARA rule created

## Module 10
- [ ] Vulnerabilities identified
- [ ] Data flow traced
- [ ] Vulnerability scanner script written

## Module 11
- [ ] XOR Guardian completed
- [ ] Serial Validator completed
- [ ] Malware Analysis completed
- [ ] Vulnerability Research completed

---

# Instructor Notes

## Grading Guide

| Module | Points | Key Items |
|--------|--------|-----------|
| Module 1 | 10 | Installation, project creation |
| Module 2 | 10 | Interface navigation |
| Module 3 | 15 | Binary analysis, renaming |
| Module 4 | 15 | Scripting |
| Module 5 | 10 | Control flow |
| Module 6 | 10 | XREFs |
| Module 7 | 15 | XOR decryption |
| Module 8 | 15 | Patching |
| Module 9 | 10 | Malware analysis |
| Module 10 | 15 | Vulnerability research |
| Module 11 | 20 | Projects |
| **Total** | **145** | |

## Common Student Challenges

1. **Java Installation:** Ensure JAVA_HOME is set correctly
2. **Ghidra Memory:** Remind students to adjust -Xmx for large binaries
3. **Decompiler Understanding:** Explain that generic names are normal
4. **Scripting:** Review Python basics before advanced scripting
5. **XREFs:** Practice tracing references on simple binaries first

## Recommended Solutions Repository

Create a solution repository with:
- All code samples
- Complete scripts
- Patched binaries
- YARA rules
- IOC reports
- Answer keys for exercises

---

# End of Workbook

**Congratulations on completing the Zero to Hero: Practical Reverse Engineering with Ghidra Student Workbook!**

Remember:
- Practice regularly
- Join the community
- Keep learning
- Use your skills ethically

Happy Reversing!
