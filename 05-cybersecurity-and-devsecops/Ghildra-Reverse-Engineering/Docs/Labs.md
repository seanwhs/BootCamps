# Zero to Hero: Practical Reverse Engineering with Ghidra

## Complete Lab Book

### Hands-On Exercises, Challenges, and Solutions

---

# Table of Contents

**Lab 1: Environment Setup and Verification**  
Lab 1.1: JDK Installation  
Lab 1.2: Ghidra Installation  
Lab 1.3: First Launch Verification  

**Lab 2: Ghidra Interface Exploration**  
Lab 2.1: The Listing Window  
Lab 2.2: The Decompiler Window  
Lab 2.3: Symbol Tree and Program Trees  
Lab 2.4: Navigation Challenge  

**Lab 3: Your First Binary Analysis**  
Lab 3.1: Creating and Importing a Binary  
Lab 3.2: Analyzing the Calculator Program  
Lab 3.3: Renaming and Annotating  
Lab 3.4: Final Analysis Challenge  

**Lab 4: Ghidra Scripting**  
Lab 4.1: Function Enumerator  
Lab 4.2: String Extractor  
Lab 4.3: Memory Dumper  
Lab 4.4: Scripting Challenge  

**Lab 5: Control Flow Analysis**  
Lab 5.1: Identifying Basic Blocks  
Lab 5.2: Conditional Branch Analysis  
Lab 5.3: Loop Detection  
Lab 5.4: Function Graph Challenge  

**Lab 6: Cross-References (XREFs)**  
Lab 6.1: String Discovery  
Lab 6.2: Function Call Tracing  
Lab 6.3: Data Flow Tracing  
Lab 6.4: XREF Challenge  

**Lab 7: XOR Decryption**  
Lab 7.1: Manual XOR Decryption  
Lab 7.2: Automated XOR Decryption  
Lab 7.3: Real-World XOR Challenge  
Lab 7.4: XOR CTF Challenge  

**Lab 8: Binary Patching**  
Lab 8.1: Bypassing Authentication  
Lab 8.2: NOP-ing Function Calls  
Lab 8.3: Modifying Constants  
Lab 8.4: Patching Challenge  

**Lab 9: Malware Analysis**  
Lab 9.1: Static Triage  
Lab 9.2: IOC Extraction  
Lab 9.3: YARA Rule Creation  
Lab 9.4: Malware Analysis Challenge  

**Lab 10: Vulnerability Research**  
Lab 10.1: Unsafe Function Detection  
Lab 10.2: Data Flow Tracing  
Lab 10.3: Vulnerability Scanner  
Lab 10.4: Vulnerability Research Challenge  

**Lab 11: Comprehensive Project**  
Lab 11.1: XOR Guardian  
Lab 11.2: Serial Validator  
Lab 11.3: Malware Analysis  
Lab 11.4: Vulnerability Research  

**Lab 12: Final Challenge**  
The Enigma Protocol - Complete Analysis  

**Solutions**  
Lab Solutions  

---

# Lab 1: Environment Setup and Verification

## Lab 1.1: JDK Installation

### Objective
Install and verify the Java Development Kit (JDK) required for Ghidra.

### Materials Needed
- Computer with internet access
- Administrator/sudo privileges

### Time
15 minutes

---

### Instructions

**Step 1: Download JDK 17**
1. Navigate to https://adoptium.net/
2. Click "Latest Releases" and select "Java 17"
3. Choose your operating system and architecture
4. Download the installer

**Step 2: Install JDK**

**Windows:**
1. Run the MSI installer
2. Follow the wizard
3. Note the installation path

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install java-17-openjdk-devel -y
```

**macOS:**
```bash
brew install openjdk@17
sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
```

**Step 3: Set Environment Variables**

**Windows:**
1. Open System Properties → Advanced → Environment Variables
2. Create `JAVA_HOME` pointing to JDK directory
3. Add `%JAVA_HOME%\bin` to PATH

**Linux/macOS:**
```bash
# Add to ~/.bashrc or ~/.zshrc
export JAVA_HOME=/path/to/jdk
export PATH=$JAVA_HOME/bin:$PATH
source ~/.bashrc
```

**Step 4: Verify Installation**

Open a terminal/command prompt:
```bash
java -version
javac -version
```

---

### Verification Checklist

- [ ] `java -version` shows "openjdk version 17"
- [ ] `javac -version` shows "javac 17"
- [ ] `JAVA_HOME` environment variable is set
- [ ] `JAVA_HOME/bin` is in PATH

---

### Troubleshooting

| Issue | Solution |
|-------|----------|
| `'java' is not recognized` | Add Java to PATH |
| `JAVA_HOME not found` | Create environment variable |
| Wrong Java version | Install JDK 17, not JRE |

---

### Your Results

```
java -version output:
[Paste here]

javac -version output:
[Paste here]

JAVA_HOME:
[Paste here]

PATH:
[Paste relevant part here]
```

---

## Lab 1.2: Ghidra Installation

### Objective
Install Ghidra and verify it runs correctly.

### Materials Needed
- JDK 17 installed
- Internet connection
- 4GB+ free disk space

### Time
20 minutes

---

### Instructions

**Step 1: Download Ghidra**
1. Navigate to https://ghidra-sre.org/
2. Click "Download"
3. Download the latest stable release ZIP

**Step 2: Install Ghidra**

**Windows:**
1. Extract ZIP to `C:\Tools\ghidra_X.X_PUBLIC`
2. (Optional) Create a shortcut to `ghidraRun.bat`

**Linux/macOS:**
```bash
# Extract
unzip ghidra_X.X_PUBLIC_YYYYMMDD.zip -d ~/tools/

# Make executable
chmod +x ~/tools/ghidra_X.X_PUBLIC/ghidraRun
```

**Step 3: Configure Memory**

Edit the launch script:

**Windows (ghidraRun.bat):**
```batch
set GHIDRA_OPTIONS=-Xmx4096m
```

**Linux/macOS (ghidraRun):**
```bash
GHIDRA_OPTIONS="-Xmx4096m"
```

**Step 4: Launch Ghidra**
```bash
# Navigate to Ghidra directory
cd ~/tools/ghidra_X.X_PUBLIC

# Launch
./ghidraRun
```

---

### Verification Checklist

- [ ] Ghidra launches without errors
- [ ] Splash screen appears
- [ ] Project Manager window opens
- [ ] No Java exceptions in console
- [ ] `.ghidra` directory created in home folder

---

### Troubleshooting

| Issue | Solution |
|-------|----------|
| "Java not found" | Set JAVA_HOME correctly |
| "Out of memory" | Increase -Xmx value |
| "Unsupported Java" | Install JDK 17 |

---

### Your Results

```
Ghidra Installation Path:
[Paste here]

Memory Configuration:
[Paste here]

Launch Output:
[Paste here]
```

---

## Lab 1.3: First Launch Verification

### Objective
Verify Ghidra is properly installed by creating a test project.

### Materials Needed
- Ghidra installed
- Sample binary (Hello World program)

### Time
15 minutes

---

### Instructions

**Step 1: Create a Test Project**
1. Launch Ghidra
2. Click "New Project"
3. Select "Non-shared Project"
4. Name: `TestProject`
5. Click "Finish"

**Step 2: Create a Simple Binary**

Create `hello.c`:
```c
#include <stdio.h>
int main() {
    printf("Hello, Ghidra!\n");
    return 0;
}
```

Compile:
```bash
# Linux
gcc -g -o hello hello.c

# Windows (MinGW)
gcc -g -o hello.exe hello.c
```

**Step 3: Import the Binary**
1. In Project Manager, click "Import File"
2. Select your `hello` binary
3. Click "OK"
4. Click "Yes" to analyze
5. Select all analyzers
6. Click "Analyze"

**Step 4: Verify Analysis**
1. Double-click the binary to open it
2. Check that code appears in Listing Window
3. Verify Decompiler shows main function
4. Confirm no error messages

---

### Verification Checklist

- [ ] Project created successfully
- [ ] Binary imported without errors
- [ ] Analysis completed
- [ ] Code appears in Listing Window
- [ ] Decompiler shows main function

---

### Your Results

```
Project Name: TestProject
Binary Name: hello
Analysis Status: [Completed / Error]

Listing Window:
[Describe what you see]

Decompiler Window:
[Describe what you see]
```

---

# Lab 2: Ghidra Interface Exploration

## Lab 2.1: The Listing Window

### Objective
Navigate and understand the Listing Window in Ghidra.

### Materials Needed
- Ghidra with imported Hello World binary
- 15 minutes

---

### Instructions

**Step 1: Open the Listing Window**
1. Open your Hello World binary in Ghidra
2. Ensure the Listing Window is visible
3. Navigate to the main function

**Step 2: Explore the Listing**

**Find the Entry Point:**
1. Note the address where the program starts
2. What is the first instruction?

**Find the Main Function:**
1. Use `G` (go to) and type "main"
2. What address is main at?
3. What are the first few instructions?

**Explore Color Coding:**
1. Find a blue instruction (function)
2. Find a red instruction (data reference)
3. Find a green instruction (comment)

**Step 3: Practice Navigation**
1. Use `G` to jump to address `0x401000` (adjust for your binary)
2. Use `Ctrl+F` to find "Hello"
3. Use `Alt+Left` and `Alt+Right` to navigate back and forward

---

### Verification Questions

1. What is the entry point address?

```
[Your answer]
```

2. What is the first instruction in main?

```
[Your answer]
```

3. What color is a function call?

```
[Your answer]
```

4. How do you jump to an address?

```
[Your answer]
```

---

## Lab 2.2: The Decompiler Window

### Objective
Use the Decompiler Window to understand program logic.

### Materials Needed
- Ghidra with Hello World binary
- 15 minutes

---

### Instructions

**Step 1: Open Decompiler**
1. Ensure Decompiler Window is visible (right panel)
2. Navigate to main function
3. Observe the decompiled code

**Step 2: Analyze Decompiled Code**

**Find the Printf Call:**
1. Identify the printf function call
2. What is the string being printed?

**Examine Variable Names:**
1. What generic names does the decompiler use?
2. Notice the parameter names (`param_1`, `param_2`)
3. Notice local variable names (`local_4`, `local_8`)

**Step 3: Toggle Views**
1. Press `F11` to switch focus between Listing and Decompiler
2. Click an instruction in the Listing
3. Watch the Decompiler update
4. Click a line in the Decompiler
5. Watch the Listing update

---

### Verification Questions

1. What does the decompiled main function look like?

```
[Paste or describe]
```

2. What generic names does the decompiler use for parameters?

```
[Your answer]
```

3. How does the decompiler represent the printf call?

```
[Your answer]
```

---

## Lab 2.3: Symbol Tree and Program Trees

### Objective
Explore the Symbol Tree and Program Trees.

### Materials Needed
- Ghidra with Hello World binary
- 15 minutes

---

### Instructions

**Step 1: Explore the Symbol Tree**
1. Locate the Symbol Tree (left panel)
2. Expand "Functions"
3. List all functions found
4. Find "main" in the list
5. Double-click to navigate

**Step 2: Explore Imports**
1. Expand "Imports" (PE) or "External" (ELF)
2. What libraries/functions are imported?
3. Find `printf` in the list

**Step 3: Explore Program Trees**
1. Locate Program Trees (bottom-left)
2. Expand sections:
   - PE: DOS Header, NT Headers, Sections
   - ELF: ELF Header, Program Headers, Sections
3. Find the `.text` section
4. Note the address range

**Step 4: Compare Views**
1. Open Symbol Tree and Program Trees simultaneously
2. How do they organize information differently?
3. Which is more useful for finding functions?

---

### Verification Questions

1. How many functions are in the binary?

```
[Your answer]
```

2. What libraries are imported?

```
[Your answer]
```

3. Where does the `.text` section start?

```
[Your answer]
```

---

## Lab 2.4: Navigation Challenge

### Objective
Practice navigation shortcuts and techniques.

### Materials Needed
- Ghidra with any binary
- 10 minutes

---

### Instructions

**Complete the following tasks as quickly as possible:**

1. Jump to main function (use `G` then type "main")
2. Find the string "Hello" (use `Ctrl+F`)
3. Rename a variable (use `N`)
4. Add a comment (use `;`)
5. Set a bookmark (use `B`)
6. Show cross-references (use `X`)
7. Go back to previous location (`Alt+Left`)

**Time Yourself:**

Start time: ______
End time: ______
Total time: ______

---

### Challenge Results

| Task | Completed? | Time |
|------|------------|------|
| Jump to main | [ ] | |
| Find "Hello" | [ ] | |
| Rename variable | [ ] | |
| Add comment | [ ] | |
| Set bookmark | [ ] | |
| Show XREFs | [ ] | |
| Go back | [ ] | |

---

# Lab 3: Your First Binary Analysis

## Lab 3.1: Creating and Importing a Binary

### Objective
Create a custom binary and import it into Ghidra.

### Materials Needed
- C compiler (gcc)
- Text editor
- 15 minutes

---

### Instructions

**Step 1: Create the Calculator Program**

Create `calculator.c`:
```c
#include <stdio.h>
#include <string.h>

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

**Step 2: Compile**
```bash
# Linux
gcc -g -o calculator calculator.c

# Windows (MinGW)
gcc -g -o calculator.exe calculator.c
```

**Step 3: Import to Ghidra**
1. Create new project
2. Import calculator binary
3. Run full analysis

---

### Verification Questions

1. What functions does Ghidra identify?

```
[Your answer]
```

2. What strings are present?

```
[Your answer]
```

---

## Lab 3.2: Analyzing the Calculator Program

### Objective
Analyze the calculator program's main function.

### Materials Needed
- Calculator binary imported in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Locate Main Function**
1. Use Symbol Tree or `G` to find main
2. Observe the decompiled code

**Step 2: Identify Operations**
1. What arithmetic operations are performed?
2. How many functions are called from main?

**Step 3: Trace Execution**
1. What happens when main starts?
2. What is the secret call at the end?
3. What does the validate_access function do?

**Step 4: Document Your Findings**
Create a function map:

| Function | Purpose | Parameters | Return |
|----------|---------|------------|--------|
| main | | | |
| add | | | |
| subtract | | | |
| multiply | | | |
| divide | | | |
| validate_access | | | |

---

### Verification Questions

1. What does the main function do step by step?

```
[Your answer]
```

2. What is the purpose of validate_access?

```
[Your answer]
```

3. What is the vulnerability in validate_access?

```
[Your answer]
```

---

## Lab 3.3: Renaming and Annotating

### Objective
Rename variables and add comments for better understanding.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Rename main Variables**

| Original | New Name | Why |
|----------|----------|-----|
| param_1 | argc | Standard main parameter |
| param_2 | argv | Standard main parameter |
| local_4 | a | First operand |
| local_8 | b | Second operand |
| local_12 | result | Result variable |
| local_16 | choice | Menu choice |

**Step 2: Rename validate_access Variables**

| Original | New Name | Why |
|----------|----------|-----|
| param_1 | key | XOR key input |
| param_2 | message | Secret message |
| local_38 | buffer | Buffer for copy |
| local_18 | validation | XOR validation result |

**Step 3: Add Comments**

Add comments to:
1. `validation = key ^ 0x5A`: "XOR key with 0x5A"
2. `if (validation == 0x40)`: "Check if key = 0x5A"
3. `strcpy(buffer, message)`: "VULNERABILITY: Buffer overflow risk"
4. `printf("Access granted!")`: "Successful authentication path"
5. `printf("Access denied!")`: "Failed authentication path"

**Step 4: Set Data Types**

Set correct data types:
1. main: `return int`, `argc int`, `argv char**`
2. validate_access: `key int`, `message char*`
3. Add: `return int`, `a int`, `b int`

---

### Verification Questions

1. What did renaming help you understand?

```
[Your answer]
```

2. How do comments improve the analysis?

```
[Your answer]
```

3. What is the importance of correct data types?

```
[Your answer]
```

---

## Lab 3.4: Final Analysis Challenge

### Objective
Complete a full analysis of the calculator program.

### Materials Needed
- Calculator binary in Ghidra
- 30 minutes

---

### Instructions

**Complete the following analysis:**

**1. Function Analysis:**
- [ ] All functions identified and renamed
- [ ] Parameters documented
- [ ] Return types set correctly

**2. Vulnerability Identification:**
- [ ] strcpy vulnerability identified
- [ ] Location noted
- [ ] Impact assessed

**3. Logic Understanding:**
- [ ] XOR operation understood
- [ ] Validation logic documented
- [ ] Authentication bypass identified

**4. Documentation:**
- [ ] Comments added to key sections
- [ ] Bookmark set at vulnerability
- [ ] Function descriptions added

**5. Analysis Report:**

```
=== CALCULATOR PROGRAM ANALYSIS ===

Program: calculator
Type: [ELF/PE]
Functions: [List]

Key Findings:
1. Secret validation function (validate_access)
2. XOR-based authentication (key ^ 0x5A == 0x40)
3. Buffer overflow vulnerability (strcpy without bounds)

How to Bypass:
- Valid key is 0x5A
- Secret message is "RE_MASTER"

Vulnerability:
- Location: validate_access strcpy call
- Risk: Buffer overflow
- Mitigation: Replace with strncpy
```

---

### Verification Checklist

- [ ] All functions renamed
- [ ] Variables renamed
- [ ] Comments added
- [ ] Data types set
- [ ] Vulnerability identified
- [ ] Report created

---

# Lab 4: Ghidra Scripting

## Lab 4.1: Function Enumerator

### Objective
Write a script to enumerate all functions in a binary.

### Materials Needed
- Ghidra with any binary
- 20 minutes

---

### Instructions

**Step 1: Create Script**
1. Window → Script Manager
2. Click "New Script"
3. Select Python
4. Name: `EnumFunctions.py`

**Step 2: Write Script**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: EnumFunctions.py
Purpose: Enumerate all functions with their entry points
"""

from __future__ import print_function

def main():
    """Main entry point."""
    print("\n" + "=" * 80)
    print("[*] Function Enumerator")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("=" * 80 + "\n")
    
    # Get function manager
    func_manager = currentProgram.getFunctionManager()
    
    # Get total functions
    total = func_manager.getFunctionCount()
    print("[*] Total functions: {}\n".format(total))
    
    # Get all functions
    functions = func_manager.getFunctions(True)
    
    # Iterate and print
    print("{:<40} {:<15}".format("Function", "Entry Point"))
    print("-" * 80)
    
    for func in functions:
        name = func.getName()
        entry = func.getEntryPoint().getOffset()
        print("{:<40} 0x{:08x}".format(name, entry))
    
    print("-" * 80)
    print("[*] Complete!")

if __name__ == "__main__":
    main()
```

**Step 3: Run the Script**
1. Click "Run"
2. Observe the output
3. Compare to Symbol Tree

---

### Verification Questions

1. How many functions were found?

```
[Your answer]
```

2. List 5 functions with their entry points:

```
[Your answer]
```

---

## Lab 4.2: String Extractor

### Objective
Write a script to extract all strings from a binary.

### Materials Needed
- Ghidra with any binary
- 20 minutes

---

### Instructions

**Step 1: Create Script**
1. New script: `StringExtractor.py`

**Step 2: Write Script**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: StringExtractor.py
Purpose: Extract all strings from the binary
"""

from __future__ import print_function

def main():
    """Main entry point."""
    print("\n" + "=" * 80)
    print("[*] String Extractor")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("=" * 80 + "\n")
    
    # Get listing
    listing = currentProgram.getListing()
    
    # Get all defined data
    data = listing.getDefinedData(True)
    
    strings_found = 0
    
    while data.hasNext():
        d = data.next()
        try:
            value = str(d.getValue())
            if len(value) >= 4:  # Skip very short strings
                addr = d.getAddress().getOffset()
                print("0x{:08x}: {}".format(addr, value))
                strings_found += 1
        except:
            continue
    
    print("\n[*] Total strings found: {}".format(strings_found))
    print("=" * 80)

if __name__ == "__main__":
    main()
```

**Step 3: Run the Script**
1. Run the script
2. Compare with Defined Strings window

---

### Verification Questions

1. How many strings were found?

```
[Your answer]
```

2. What interesting strings did you find?

```
[Your answer]
```

---

## Lab 4.3: Memory Dumper

### Objective
Write a script to dump memory to a file.

### Materials Needed
- Ghidra with any binary
- 20 minutes

---

### Instructions

**Step 1: Create Script**
1. New script: `MemoryDumper.py`

**Step 2: Write Script**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: MemoryDumper.py
Purpose: Dump memory regions to files
"""

from __future__ import print_function
import os

def main():
    """Main entry point."""
    print("\n" + "=" * 80)
    print("[*] Memory Dumper")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("=" * 80 + "\n")
    
    # Get memory
    memory = currentProgram.getMemory()
    blocks = memory.getBlocks()
    
    # Create output directory
    output_dir = "{}_dump".format(
        currentProgram.getName().replace('.', '_'))
    try:
        os.makedirs(output_dir)
    except:
        pass
    
    while blocks.hasNext():
        block = blocks.next()
        name = block.getName()
        start = block.getStart()
        end = block.getEnd()
        size = block.getSize()
        
        print("[*] Dumping: {}".format(name))
        print("    Start: 0x{:08x}".format(start.getOffset()))
        print("    Size: {} bytes".format(size))
        
        try:
            data = getBytes(start, size)
            filename = os.path.join(output_dir, "{}.bin".format(name))
            with open(filename, 'wb') as f:
                f.write(data)
            print("    Saved to: {}".format(filename))
        except Exception as e:
            print("    Error: {}".format(str(e)))
        
        print("")
    
    print("[*] Complete!")

if __name__ == "__main__":
    main()
```

**Step 3: Run the Script**
1. Run the script
2. Check output directory

---

### Verification Questions

1. What memory blocks were dumped?

```
[Your answer]
```

2. Where were the files saved?

```
[Your answer]
```

---

## Lab 4.4: Scripting Challenge

### Objective
Write a custom script to solve a specific problem.

### Materials Needed
- Ghidra with calculator binary
- 30 minutes

---

### Instructions

**The Challenge:**
Write a script that:
1. Finds the validate_access function
2. Extracts the XOR key
3. Determines the correct password

**Your Script:**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: XORKeyFinder.py
Purpose: Find XOR key in validate_access
"""

from __future__ import print_function

def main():
    print("[*] XOR Key Finder")
    
    # TODO: Find validate_access function
    # TODO: Extract XOR constant
    # TODO: Calculate correct key
    
    print("[*] Complete!")

if __name__ == "__main__":
    main()
```

**Complete the Script:**
```




```

---

### Verification Checklist

- [ ] Script finds validate_access
- [ ] Script extracts XOR key
- [ ] Script calculates correct password
- [ ] Script works on calculator binary

---

# Lab 5: Control Flow Analysis

## Lab 5.1: Identifying Basic Blocks

### Objective
Identify basic blocks in the validate_access function.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Open validate_access**
1. Navigate to validate_access function
2. Open the Listing Window

**Step 2: Identify Basic Blocks**

**Block 1 (Entry):**
```
[Instructions]
```

**Block 2 (True Branch):**
```
[Instructions]
```

**Block 3 (False Branch):**
```
[Instructions]
```

**Block 4 (Merge):**
```
[Instructions]
```

**Step 3: Draw Flow Diagram**
```
[Drawing here]
```

---

### Verification Questions

1. How many basic blocks are in validate_access?

```
[Your answer]
```

2. What triggers the branch between blocks?

```
[Your answer]
```

---

## Lab 5.2: Conditional Branch Analysis

### Objective
Analyze conditional branches in a function.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Find a Conditional Branch**
1. Navigate to validate_access
2. Find the comparison instruction
3. Find the conditional jump

**Step 2: Document the Branch**

```
Comparison Instruction:
[Address and instruction]

Conditional Jump:
[Address and instruction]

True Path:
[What happens]

False Path:
[What happens]
```

**Step 3: Convert to C**

Write the C equivalent:
```c
[Your C code]
```

---

### Verification Questions

1. What condition causes the branch?

```
[Your answer]
```

2. What is the C equivalent?

```
[Your answer]
```

---

## Lab 5.3: Loop Detection

### Objective
Find and analyze loops in the binary.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Search for Loops**
1. Look for backward jumps (jumps to lower addresses)
2. Check for loops in other functions

**Step 2: Document a Loop**

```
Loop Type: [For/While/Do-While]

Initialize:
[Instructions]

Condition:
[Instructions]

Body:
[Instructions]

Update:
[Instructions]
```

**Step 3: Convert to C**

Write the C equivalent:
```c
[Your C code]
```

---

### Verification Questions

1. What loops did you find?

```
[Your answer]
```

2. What is the purpose of the loop?

```
[Your answer]
```

---

## Lab 5.4: Function Graph Challenge

### Objective
Use the Function Graph to understand control flow.

### Materials Needed
- Calculator binary in Ghidra
- 15 minutes

---

### Instructions

**Step 1: Open Function Graph**
1. Navigate to validate_access
2. Click Function Graph button
3. Zoom to view entire function

**Step 2: Analyze the Graph**

**Number of Nodes (Blocks):**
```
[Count]
```

**Edges (Branches):**
```
[Count]
```

**Entry Point:**
```
[Which block?]
```

**Exit Points:**
```
[Which blocks?]
```

**Step 3: Compare to Listing**

How does the graph compare to the disassembly?

```
[Your observations]
```

---

### Verification Questions

1. How does the Function Graph help understanding?

```
[Your answer]
```

2. What is the structure of the control flow?

```
[Your answer]
```

---

# Lab 6: Cross-References (XREFs)

## Lab 6.1: String Discovery

### Objective
Find interesting strings and their usage.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Open Defined Strings**
1. Window → Defined Strings
2. Sort by address or length

**Step 2: Document Interesting Strings**

| String | Address | Where Used |
|--------|---------|------------|
| | | |
| | | |
| | | |

**Step 3: Trace a String**
1. Double-click a string
2. Press `X` to see references
3. Navigate to the usage
4. Document the context

---

### Verification Questions

1. What strings did you find?

```
[Your answer]
```

2. Where is "Access granted!" used?

```
[Your answer]
```

---

## Lab 6.2: Function Call Tracing

### Objective
Trace function calls using XREFs.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Find Callers of validate_access**
1. Navigate to validate_access
2. Right-click → Show References to Function
3. Who calls it?

**Step 2: Find What it Calls**
1. Right-click → Show References from Function
2. What does it call?

**Step 3: Create Call Graph**

```
[Draw the call graph]
```

**Step 4: Analyze Parameters**
What parameters are passed?

```
[Document]
```

---

### Verification Questions

1. Who calls validate_access?

```
[Your answer]
```

2. What does validate_access call?

```
[Your answer]
```

---

## Lab 6.3: Data Flow Tracing

### Objective
Trace data from source to sink.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Find the Source**
Where does the data in validate_access come from?

```
[Source]
```

**Step 2: Trace the Flow**
Follow the data through the function:

```
Source → [Variable] → [Operation] → [Sink]
```

**Step 3: Document the Path**

```
[Document the complete data flow]
```

---

### Verification Questions

1. What is the data flow path?

```
[Your answer]
```

2. What is the sink (dangerous function)?

```
[Your answer]
```

---

## Lab 6.4: XREF Challenge

### Objective
Use XREFs to find hidden functionality.

### Materials Needed
- Calculator binary in Ghidra
- 30 minutes

---

### Instructions

**The Challenge:**
Find the hidden validation function and understand how it works.

**Step 1: Find Suspicious Strings**
1. Search for "secret" or "hidden" strings
2. Look for "RE_MASTER"

**Step 2: Trace References**
1. Find where "RE_MASTER" is used
2. Follow to the calling function
3. Understand the context

**Step 3: Document Findings**

```
String Found: [String]
Used In: [Function]
Called By: [Caller]
Purpose: [Purpose]
```

---

### Verification Questions

1. What hidden functionality did you find?

```
[Your answer]
```

2. How is it triggered?

```
[Your answer]
```

---

# Lab 7: XOR Decryption

## Lab 7.1: Manual XOR Decryption

### Objective
Manually decrypt XOR-encrypted data.

### Materials Needed
- Pen and paper
- Calculator (optional)
- 15 minutes

---

### Instructions

**Given the following encrypted data, find the key and decrypt:**

**Challenge 1:**
```
Encrypted: 0x3B 0x52 0x4D 0x52
Plaintext: "KEY"
```

Find the XOR key:
```
[Your work]
```

**Challenge 2:**
```
Encrypted: 0x45 0x5A 0x41 0x47
Plaintext: "FLAG"
```

Find the XOR key:
```
[Your work]
```

**Challenge 3:**
```
Encrypted: 0x35 0x2B 0x32 0x24 0x4D 0x2E
Key: 0x42
```

Decrypt:
```
[Your work]
```

---

### Verification

1. Key for Challenge 1:
```
[Your answer]
```

2. Key for Challenge 2:
```
[Your answer]
```

3. Decrypted for Challenge 3:
```
[Your answer]
```

---

## Lab 7.2: Automated XOR Decryption

### Objective
Write a script for XOR decryption.

### Materials Needed
- Ghidra
- 20 minutes

---

### Instructions

**Step 1: Write XOR Decryptor**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: XORDecryptor.py
Purpose: Decrypt XOR-encrypted data
"""

from __future__ import print_function

def xor_decrypt(data, key):
    """Decrypt data using XOR with a single-byte key."""
    result = []
    for byte in data:
        if byte == 0:
            break
        result.append(chr(byte ^ key))
    return ''.join(result)

def main():
    print("\n" + "=" * 80)
    print("[*] XOR Decryptor")
    print("=" * 80 + "\n")
    
    # Example data
    encrypted = [0x35, 0x2B, 0x32, 0x24, 0x4D, 0x2E]
    key = 0x42
    
    decrypted = xor_decrypt(encrypted, key)
    print("[*] Encrypted: {}".format(
        " ".join(["0x{:02x}".format(b) for b in encrypted])))
    print("[*] Key: 0x{:02x}".format(key))
    print("[*] Decrypted: {}".format(decrypted))
    print("=" * 80)

if __name__ == "__main__":
    main()
```

**Step 2: Run the Script**

What is the output?
```
[Your output]
```

**Step 3: Extend the Script**

Add support for multiple keys:
```
[Your code]
```

---

### Verification Questions

1. What does the script output?

```
[Your answer]
```

2. How can you extend the script?

```
[Your answer]
```

---

## Lab 7.3: Real-World XOR Challenge

### Objective
Find and decrypt XOR-encrypted data in a real binary.

### Materials Needed
- Calculator binary in Ghidra
- 30 minutes

---

### Instructions

**Step 1: Find XOR Operation**
1. In validate_access, find the XOR operation
2. What is the XOR key?
3. What is being XORed?

**Step 2: Extract Data**
1. Find the data being XORed
2. What is the decrypted result?

**Step 3: Document the XOR**

```
XOR Location: [Address]
XOR Key: [0x__]
Encrypted Data: [Bytes]
Decrypted Data: [String]
```

---

### Verification Questions

1. What is the XOR key in validate_access?

```
[Your answer]
```

2. What is the decrypted message?

```
[Your answer]
```

---

## Lab 7.4: XOR CTF Challenge

### Objective
Solve a CTF-style XOR challenge.

### Materials Needed
- Custom binary provided by instructor
- 30 minutes

---

### Instructions

**Challenge Binary:**
A program contains an XOR-encrypted flag.

**Step 1: Triage**
```
file [binary]
strings [binary]
```

**Step 2: Find XOR Logic**
1. Import to Ghidra
2. Locate encryption/decryption function
3. Find the XOR key

**Step 3: Decrypt the Flag**
1. Extract encrypted data
2. Apply XOR key
3. Recover flag

**Your Work:**
```
[Document your process]
```

---

### Verification

1. XOR Key:
```
[Your answer]
```

2. Flag:
```
[Your answer]
```

---

# Lab 8: Binary Patching

## Lab 8.1: Bypassing Authentication

### Objective
Patch the validate_access function to always grant access.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Find the Conditional Jump**
1. Navigate to validate_access
2. Find the `jne` instruction
3. Note the address

**Step 2: Apply the Patch**

**Method 1: Patch Instruction**
1. Right-click the `jne` instruction
2. Select "Patch Instruction"
3. Change to `jmp` (always take branch)
4. Click "OK"

**Method 2: Patch Bytes**
1. Right-click the address
2. Select "Patch Bytes"
3. Replace with NOPs (`90 90 ...`)
4. Click "OK"

**Step 3: Test**

1. Export patched binary:
   - File → Export Program
   - Save as `calculator_patched`
2. Run the patched binary:
   ```bash
   ./calculator_patched
   ```

---

### Verification Questions

1. What did you change?

```
[Your answer]
```

2. Does the patched binary work differently?

```
[Your answer]
```

---

## Lab 8.2: NOP-ing Function Calls

### Objective
Remove a function call using NOP instructions.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Find a Function Call**
1. Locate a call instruction
2. Note the address and length

**Step 2: Calculate NOP Length**
1. How many bytes is the call instruction?
2. How many NOPs are needed?

**Step 3: Apply the Patch**
1. Right-click → Patch Bytes
2. Replace with NOPs
3. Export and test

**Step 4: Document**

```
Original Call:
[Address and instruction]

Bytes Replaced:
[Original bytes]

NOPs Applied:
[Patched bytes]
```

---

### Verification Questions

1. What call did you NOP?

```
[Your answer]
```

2. What was the effect?

```
[Your answer]
```

---

## Lab 8.3: Modifying Constants

### Objective
Change a constant value in the binary.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Find the Constant**
1. Locate the XOR key in validate_access
2. Find where it's used

**Step 2: Modify the Constant**
1. Find the instruction with the constant
2. Right-click → Patch Bytes
3. Change the value

**Step 3: Test**
1. Export patched binary
2. What happens when you run it?

**Step 4: Document**

```
Original Constant: [Value]
New Constant: [Value]
Effect: [What happened?]
```

---

### Verification Questions

1. What constant did you modify?

```
[Your answer]
```

2. What was the effect?

```
[Your answer]
```

---

## Lab 8.4: Patching Challenge

### Objective
Patch a binary to achieve a specific goal.

### Materials Needed
- Challenge binary provided by instructor
- 30 minutes

---

### Instructions

**The Challenge:**
Patch the binary so that it prints "ACCESS GRANTED" regardless of input.

**Step 1: Analyze the Binary**
1. Import to Ghidra
2. Find the validation logic
3. Identify the branch

**Step 2: Apply the Patch**
1. Choose the best patch method
2. Apply the patch
3. Test your result

**Step 3: Document Your Solution**

```
Challenge Binary: [Name]
Validation Location: [Address]
Original Behavior: [Description]
Patched Behavior: [Description]
Patch Method: [Description]
```

---

### Verification

1. How did you solve the challenge?

```
[Your answer]
```

2. What patch did you apply?

```
[Your answer]
```

---

# Lab 9: Malware Analysis

## Lab 9.1: Static Triage

### Objective
Perform static triage on a suspicious binary.

### Materials Needed
- Malware sample (provided by instructor)
- 30 minutes

---

### Instructions

**Step 1: File Information**
```bash
file [binary]
```

**Step 2: String Extraction**
```bash
strings [binary] | head -50
```

**Step 3: Entropy Check**
```bash
# Use your entropy script
```

**Step 4: Import in Ghidra**
1. Import binary
2. Run initial analysis
3. Check imports and sections

---

### Triage Report

```
=== STATIC TRIAGE REPORT ===

File Name: [Name]
File Type: [ELF/PE]
File Size: [Size]
Entropy: [Value]

Suspicious Indicators:
1. [Indicator]
2. [Indicator]
3. [Indicator]

Interesting Strings:
1. [String]
2. [String]
3. [String]

Suspicious Imports:
1. [Import]
2. [Import]

Packed? [Yes/No]

Assessment: [Brief summary]
```

---

### Verification Questions

1. What suspicious indicators did you find?

```
[Your answer]
```

2. Is the binary packed?

```
[Your answer]
```

---

## Lab 9.2: IOC Extraction

### Objective
Extract Indicators of Compromise from a malware sample.

### Materials Needed
- Malware sample in Ghidra
- 30 minutes

---

### Instructions

**Step 1: Extract Strings**
1. Window → Defined Strings
2. Look for suspicious strings

**Step 2: Categorize IOCs**

**Domains:**
```
[Domain list]
```

**IP Addresses:**
```
[IP list]
```

**File Paths:**
```
[File paths]
```

**Registry Keys:**
```
[Registry keys]
```

**Other Suspicious Strings:**
```
[Other strings]
```

**Step 3: Document IOCs**

```
=== IOCs ===

Domains:
- [Domain 1]

IPs:
- [IP 1]

File Paths:
- [Path 1]

Registry:
- [Key 1]
```

---

### Verification Questions

1. What IOCs did you extract?

```
[Your answer]
```

2. How could these be used for detection?

```
[Your answer]
```

---

## Lab 9.3: YARA Rule Creation

### Objective
Create a YARA rule to detect the malware.

### Materials Needed
- Malware sample
- 30 minutes

---

### Instructions

**Step 1: Select Indicators**
1. Choose unique strings
2. Choose unique byte patterns
3. Choose file characteristics

**Step 2: Write YARA Rule**

```yara
/*
 * YARA Rule: [Rule Name]
 * Author: [Your Name]
 * Date: [Date]
 * Description: Detects [Malware Name]
 */

rule [Rule_Name] {
    meta:
        author = "[Your Name]"
        description = "[Description]"
        version = "1.0"
        confidence = "Medium"
        
    strings:
        $s1 = "[Unique String 1]"
        $s2 = "[Unique String 2]"
        $h1 = { [Hex Pattern] }
        
    condition:
        $s1 or $s2 or $h1
}
```

**Step 3: Test the Rule**
```bash
yara [rule_file] [binary]
```

---

### Verification Questions

1. What strings did you use in your YARA rule?

```
[Your answer]
```

2. Does the rule detect the sample?

```
[Your answer]
```

---

## Lab 9.4: Malware Analysis Challenge

### Objective
Complete a full malware analysis.

### Materials Needed
- Malware sample provided by instructor
- 45 minutes

---

### Instructions

**Complete Analysis:**
1. Perform static triage
2. Import to Ghidra
3. Extract IOCs
4. Understand behavior
5. Create YARA rule
6. Write report

**Report Template:**

```
=== MALWARE ANALYSIS REPORT ===

Sample: [Name]
Type: [ELF/PE]
Size: [Size]
MD5: [Hash]
SHA256: [Hash]

SUMMARY:
[Brief description]

BEHAVIOR:
[What it does]

IOCs:
[Indicators]

YARA RULE:
[Rule]

RECOMMENDATIONS:
[Recommendations]
```

---

### Verification Checklist

- [ ] Triage complete
- [ ] IOCs extracted
- [ ] Behavior documented
- [ ] YARA rule created
- [ ] Report written

---

# Lab 10: Vulnerability Research

## Lab 10.1: Unsafe Function Detection

### Objective
Find unsafe function calls in a binary.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Identify Unsafe Functions**
List common unsafe C functions:
```
[Your list]
```

**Step 2: Search in Ghidra**
1. Search for function calls
2. Look for unsafe functions

**Step 3: Document Findings**

| Function | Location | Risk |
|----------|----------|------|
| strcpy | validate_access | High |
| | | |
| | | |

---

### Verification Questions

1. What unsafe functions did you find?

```
[Your answer]
```

2. What is the risk of each?

```
[Your answer]
```

---

## Lab 10.2: Data Flow Tracing

### Objective
Trace user-controlled data to dangerous sinks.

### Materials Needed
- Calculator binary in Ghidra
- 20 minutes

---

### Instructions

**Step 1: Find the Source**
1. Where does user input enter?
2. Is there any input validation?

**Step 2: Trace the Flow**
```
Source → [Variable] → [Function] → [Sink]
```

**Step 3: Document the Path**

```
Source: [Location]
Propagation: [Path]
Sink: [Location]
Sanitization: [Yes/No]
```

---

### Verification Questions

1. What is the data flow path?

```
[Your answer]
```

2. Is there any input sanitization?

```
[Your answer]
```

---

## Lab 10.3: Vulnerability Scanner

### Objective
Write a script to detect vulnerabilities.

### Materials Needed
- Ghidra with any binary
- 30 minutes

---

### Instructions

**Step 1: Write Vulnerability Scanner**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: VulnerabilityScanner.py
Purpose: Detect unsafe function calls
"""

from __future__ import print_function

dangerous_functions = ['strcpy', 'strcat', 'sprintf', 'gets', 'printf']

def main():
    print("\n" + "=" * 80)
    print("[*] Vulnerability Scanner")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("=" * 80 + "\n")
    
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    vulnerabilities = []
    
    for func in functions:
        body = func.getBody()
        listing = currentProgram.getListing()
        instructions = listing.getInstructions(body, True)
        
        while instructions.hasNext():
            instr = instructions.next()
            if instr.isCall():
                for target in instr.getFlows():
                    target_func = currentProgram.getFunctionManager().getFunctionAt(target)
                    if target_func and target_func.getName() in dangerous_functions:
                        vulnerabilities.append({
                            'function': func.getName(),
                            'address': instr.getAddress(),
                            'api': target_func.getName()
                        })
    
    if vulnerabilities:
        print("[!] Found vulnerabilities:")
        print("-" * 40)
        for vuln in vulnerabilities:
            print("  {} at 0x{:08x} in {}".format(
                vuln['api'],
                vuln['address'].getOffset(),
                vuln['function']))
    else:
        print("[*] No vulnerabilities found")
    
    print("=" * 80)

if __name__ == "__main__":
    main()
```

**Step 2: Run the Scanner**
1. Run on calculator binary
2. What vulnerabilities are found?

---

### Verification Questions

1. What vulnerabilities did the scanner find?

```
[Your answer]
```

2. How could you extend the scanner?

```
[Your answer]
```

---

## Lab 10.4: Vulnerability Research Challenge

### Objective
Find and document vulnerabilities in a binary.

### Materials Needed
- Challenge binary provided by instructor
- 30 minutes

---

### Instructions

**Challenge Binary:**
A network service contains multiple vulnerabilities.

**Step 1: Identify Input Points**
1. Find where input enters
2. Document sources

**Step 2: Trace Data Flow**
1. Follow user data through program
2. Identify propagation paths

**Step 3: Identify Vulnerabilities**

| Vulnerability | Location | Severity |
|---------------|----------|----------|
| | | |
| | | |

**Step 4: Write Report**

```
=== VULNERABILITY REPORT ===

Application: [Name]
Date: [Date]

SUMMARY:
[Brief description]

VULNERABILITIES:
1. [Description]
   Location: [Function:Address]
   Risk: [High/Medium/Low]
   Mitigation: [Fix]

2. [Description]
   Location: [Function:Address]
   Risk: [High/Medium/Low]
   Mitigation: [Fix]

RECOMMENDATIONS:
[Recommendations]
```

---

### Verification Questions

1. What vulnerabilities did you find?

```
[Your answer]
```

2. What mitigations would you recommend?

```
[Your answer]
```

---

# Lab 11: Comprehensive Projects

## Lab 11.1: XOR Guardian

### Objective
Solve the XOR Guardian CTF challenge.

### Materials Needed
- XOR Guardian binary (provided by instructor)
- 45 minutes

---

### Instructions

**Challenge Description:**
A binary guards a flag using XOR encryption.

**Step 1: Triage**
```bash
file xor_guardian
strings xor_guardian
```

**Step 2: Ghidra Analysis**
1. Import to Ghidra
2. Find validation logic
3. Identify XOR operation

**Step 3: Recover the Key**
1. Find the XOR key
2. Decrypt the flag

**Step 4: Document Solution**

```
=== XOR GUARDIAN SOLUTION ===

XOR Key: [Key]
Encrypted Flag: [Data]
Decrypted Flag: [Flag]

Solution Script:
[Script]
```

---

### Verification

1. XOR Key:
```
[Your answer]
```

2. Flag:
```
[Your answer]
```

---

## Lab 11.2: Serial Validator

### Objective
Solve the Serial Validator challenge.

### Materials Needed
- Serial Validator binary (provided by instructor)
- 45 minutes

---

### Instructions

**Challenge Description:**
A program validates serial numbers using a complex algorithm.

**Step 1: Find Validation Function**
1. Import to Ghidra
2. Locate validation logic

**Step 2: Understand Algorithm**
1. Document the algorithm
2. Identify constraints

**Step 3: Create Keygen**
1. Write a script to generate valid serials
2. Test your keygen

**Step 4: Document Solution**

```
=== SERIAL VALIDATOR SOLUTION ===

Algorithm:
[Description]

Valid Serial Example: [Serial]

Keygen Script:
[Script]
```

---

### Verification

1. Valid Serial:
```
[Your answer]
```

2. Does your keygen work?

```
[Yes/No]
```

---

## Lab 11.3: Malware Analysis

### Objective
Complete a full malware analysis project.

### Materials Needed
- Malware sample (provided by instructor)
- 1 hour

---

### Instructions

**Complete Analysis:**
1. Perform static triage
2. Import to Ghidra
3. Extract IOCs
4. Understand behavior
5. Create YARA rule
6. Write report

---

### Report Format

```
=== MALWARE ANALYSIS REPORT ===

Sample: [Name]
Type: [ELF/PE]
Size: [Size]
MD5: [Hash]
SHA256: [Hash]

TRIAGE:
[Results]

BEHAVIOR:
[Description]

IOCs:
[Indicators]

YARA RULE:
[Rule]

RECOMMENDATIONS:
[Recommendations]
```

---

### Verification Checklist

- [ ] Triage complete
- [ ] IOCs extracted
- [ ] Behavior documented
- [ ] YARA rule created
- [ ] Report complete

---

## Lab 11.4: Vulnerability Research

### Objective
Find and document vulnerabilities in a binary.

### Materials Needed
- Vulnerable binary (provided by instructor)
- 1 hour

---

### Instructions

**Complete Vulnerability Research:**
1. Identify input points
2. Trace data flow
3. Find vulnerabilities
4. Write report

---

### Report Format

```
=== VULNERABILITY RESEARCH REPORT ===

Target: [Name]
Date: [Date]

SUMMARY:
[Overview]

VULNERABILITIES:
1. [Vulnerability 1]
   - Location: [Function:Address]
   - Type: [Type]
   - Severity: [High/Medium/Low]
   - Impact: [Impact]
   - Mitigation: [Fix]

2. [Vulnerability 2]
   ...

RECOMMENDATIONS:
[Recommendations]
```

---

### Verification Checklist

- [ ] All input points identified
- [ ] Data flow traced
- [ ] Vulnerabilities documented
- [ ] Mitigations proposed
- [ ] Report complete

---

# Lab 12: Final Challenge - The Enigma Protocol

## Challenge Description

You've been given a binary that appears to be sophisticated malware. Your task is to analyze it completely:

1. Understand what it does
2. Extract the C2 domain
3. Decrypt the hidden flag
4. Create detection rules
5. Write a comprehensive report

**Time:** 2 hours

---

## Instructions

### Phase 1: Triage (15 minutes)

**Step 1: File Information**
```bash
file enigma_protocol
```

**Step 2: String Extraction**
```bash
strings enigma_protocol | head -50
```

**Step 3: Entropy Analysis**
```bash
# Use your entropy script
```

**Triage Results:**
```
[Your findings]
```

---

### Phase 2: Ghidra Analysis (45 minutes)

**Step 1: Import and Analyze**
1. Import to Ghidra
2. Run full analysis
3. Find main function

**Step 2: Identify Key Functions**
1. Find C2 decryption
2. Find flag decryption
3. Find network functions

**Step 3: Analyze C2 Decryption**

```
Algorithm:
[Description]

Encrypted Data:
[Data]

Key:
[Key]

Decrypted Domain:
[Domain]
```

**Step 4: Analyze Flag Decryption**

```
Algorithm:
[Description]

Encrypted Flag:
[Data]

Decrypted Flag:
[Flag]
```

---

### Phase 3: IOC Extraction (20 minutes)

**IOCs Found:**

| Type | IOC |
|------|-----|
| Domains | |
| IPs | |
| File Paths | |
| Registry Keys | |

---

### Phase 4: YARA Rule (15 minutes)

```yara
[Your YARA rule]
```

---

### Phase 5: Report (25 minutes)

```
=== ENIGMA PROTOCOL ANALYSIS ===

Sample: enigma_protocol
Type: ELF 64-bit
Size: [Size]

EXECUTIVE SUMMARY:
[Brief summary of the malware]

TECHNICAL ANALYSIS:
[Detailed analysis]

IOCs:
[List of IOCs]

YARA RULE:
[Rule]

RECOMMENDATIONS:
[Mitigations]
```

---

## Verification Checklist

- [ ] Triage complete
- [ ] C2 domain decrypted
- [ ] Flag decrypted
- [ ] IOCs extracted
- [ ] YARA rule created
- [ ] Report complete

---

# Solutions

## Lab 1 Solutions

### Lab 1.1: JDK Installation

**Expected Output:**
```
java version "17.0.11" 2024-04-16 LTS
OpenJDK Runtime Environment ...
OpenJDK 64-Bit Server VM ...
javac 17.0.11
```

**Common Issues:**
- "javac not found" → Only JRE installed
- "Wrong Java version" → Need JDK 17 exactly

---

### Lab 1.2: Ghidra Installation

**Verification:**
- Ghidra launches
- Project Manager opens
- No errors

**Memory Configuration:**
- Default: 2GB
- Recommended: 4GB+

---

### Lab 1.3: First Launch

**Hello World Program:**
```c
#include <stdio.h>
int main() {
    printf("Hello, Ghidra!\n");
    return 0;
}
```

---

## Lab 2 Solutions

### Lab 2.1: Listing Window

**Entry Point:**
- PE: `start` or `_WinMain@16`
- ELF: `_start`

**Main Function:**
- Address varies by binary
- Found using `G` → "main"

**Color Coding:**
- Blue: Functions
- Red: Data references
- Green: Comments

---

### Lab 2.2: Decompiler Window

**Generic Names:**
- `param_1`, `param_2`: Parameters
- `local_4`, `local_8`: Local variables
- `iVar1`, `uVar2`: Generic ints

---

### Lab 2.3: Symbol Tree

**Functions Found:**
- main
- Library functions (printf, etc.)

**Imports:**
- Standard C library functions

---

### Lab 2.4: Navigation Challenge

**Typical Times:**
- Expert: < 1 minute
- Intermediate: 1-3 minutes
- Beginner: 3-5 minutes

---

## Lab 3 Solutions

### Lab 3.1: Calculator Program

**Functions Identified:**
- main
- add
- subtract
- multiply
- divide
- validate_access

**Strings Found:**
- "Result: %d\n"
- "Access granted! %s\n"
- "Access denied!\n"
- "Buffer content: %s\n"
- "RE_MASTER"

---

### Lab 3.2: Calculator Analysis

**Main Function Steps:**
1. Initialize variables (a=10, b=5)
2. Call add function
3. Print result
4. Call validate_access with key=0x5A, message="RE_MASTER"
5. Return

**validate_access Purpose:**
- Validates a key using XOR
- Prints access message
- Contains buffer overflow vulnerability

---

### Lab 3.3: Renaming

**Main Variables:**
- param_1 → argc
- param_2 → argv
- local_4 → a
- local_8 → b
- local_12 → result
- local_16 → choice

**validate_access Variables:**
- param_1 → key
- param_2 → message
- local_38 → buffer
- local_18 → validation

---

### Lab 3.4: Analysis Report

**Vulnerability:**
- Location: validate_access → strcpy(buffer, message)
- Risk: Buffer overflow
- Mitigation: Use strncpy with bounds checking

**Authentication Bypass:**
- Valid key: 0x5A
- XOR operation: key ^ 0x5A == 0x40

---

## Lab 4 Solutions

### Lab 4.1: Function Enumerator

**Script Output:**
```
================================================================================
[*] Function Enumerator
[*] Program: calculator
================================================================================

[*] Total functions: 12

Function                                    Entry Point
--------------------------------------------------------------------------------
main                                        0x00401120
add                                         0x00401200
subtract                                    0x00401210
multiply                                    0x00401220
divide                                      0x00401230
validate_access                             0x00401240
printf                                      0x00401300
strcpy                                      0x00401310
...
```

---

### Lab 4.2: String Extractor

**Script Output:**
```
0x00402000: Result: %d
0x00402010: Access granted! %s
0x00402030: Access denied!
0x00402050: Buffer content: %s
0x00402070: RE_MASTER
```

---

### Lab 4.3: Memory Dumper

**Output Directory:**
```
calculator_dump/
├── .text.bin
├── .data.bin
├── .rodata.bin
└── .bss.bin
```

---

### Lab 4.4: Scripting Challenge

**XOR Key Finder Script:**
```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script: XORKeyFinder.py
Purpose: Find XOR key in validate_access
"""

from __future__ import print_function

def main():
    print("\n" + "=" * 80)
    print("[*] XOR Key Finder")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("=" * 80 + "\n")
    
    # Find validate_access
    func_manager = currentProgram.getFunctionManager()
    func = func_manager.getFunctionNamed("validate_access")
    
    if not func:
        print("[!] validate_access not found")
        return
    
    print("[*] Found validate_access at 0x{:08x}".format(
        func.getEntryPoint().getOffset()))
    
    # Find the XOR operation
    body = func.getBody()
    listing = currentProgram.getListing()
    instructions = listing.getInstructions(body, True)
    
    while instructions.hasNext():
        instr = instructions.next()
        if instr.getMnemonicString() == 'XOR':
            print("[*] Found XOR at 0x{:08x}".format(
                instr.getAddress().getOffset()))
            # Extract operands
            op = instr.getDefaultOperandRepresentation(1)
            if '0x' in op:
                key = int(op, 16)
                print("[*] XOR Key: 0x{:02x}".format(key))
                print("[*] Valid key: 0x{:02x}".format(key))
    
    print("=" * 80)

if __name__ == "__main__":
    main()
```

---

## Lab 5 Solutions

### Lab 5.1: Basic Blocks

**validate_access Basic Blocks:**

Block 1 (Entry):
```
push rbp
mov rbp, rsp
sub rsp, 0x30
mov [rbp-0x24], edi
mov [rbp-0x28], rsi
...
cmp [rbp-0x4], 0x40
jne Block_3
```

Block 2 (True):
```
lea rdi, [msg_granted]
call printf
jmp Block_4
```

Block 3 (False):
```
lea rdi, [msg_denied]
call printf
```

Block 4 (Merge):
```
mov rdx, [rbp-0x28]
lea rax, [rbp-0x20]
call strcpy
...
leave
ret
```

---

### Lab 5.2: Conditional Branches

**Branch Analysis:**
```
Comparison: cmp [rbp-0x4], 0x40
Jump: jne Block_3 (jump if not equal)
True Path: Access granted
False Path: Access denied
```

**C Equivalent:**
```c
if (validation == 0x40) {
    printf("Access granted! %s\n", message);
} else {
    printf("Access denied!\n");
}
```

---

### Lab 5.3: Loops

**Loops Found:**
- No loops in calculator program
- Simple straight-line execution

---

### Lab 5.4: Function Graph

**validate_access Graph:**
- 4 nodes (blocks)
- 3 edges (branches)
- 1 entry (Block 1)
- 1 exit (Block 4)

---

## Lab 6 Solutions

### Lab 6.1: String Discovery

**Interesting Strings:**
| String | Address | Where Used |
|--------|---------|------------|
| Access granted! %s\n | 0x00402010 | validate_access |
| Access denied!\n | 0x00402030 | validate_access |
| Buffer content: %s\n | 0x00402050 | validate_access |
| RE_MASTER | 0x00402070 | main |

---

### Lab 6.2: Function Call Tracing

**Callers of validate_access:**
- main (at address 0x00401195)

**Callees of validate_access:**
- printf (2 calls)
- strcpy

---

### Lab 6.3: Data Flow Tracing

**Data Flow Path:**
```
Source: main → validates_access call
Propagation: key (0x5A) → validation variable
Operation: validation = key ^ 0x5A
Sink: conditional check (if validation == 0x40)
```

---

### Lab 6.4: XREF Challenge

**Hidden Functionality:**
- validate_access is called from main
- Uses XOR for authentication
- Contains strcpy vulnerability

---

## Lab 7 Solutions

### Lab 7.1: Manual XOR

**Challenge 1:**
```
Encrypted: 0x3B 0x52 0x4D 0x52
Plaintext: "KEY"
Key: 0x7B
```

**Challenge 2:**
```
Encrypted: 0x45 0x5A 0x41 0x47
Plaintext: "FLAG"
Key: 0x20
```

**Challenge 3:**
```
Encrypted: 0x35 0x2B 0x32 0x24 0x4D 0x2E
Key: 0x42
Decrypted: "HELLO"
```

---

### Lab 7.2: Automated XOR

**Script Output:**
```
Encrypted: 0x35 0x2b 0x32 0x24 0x4d 0x2e
Key: 0x42
Decrypted: HELLO
```

---

### Lab 7.3: Real-World XOR

**validate_access XOR:**
```
XOR Location: 0x00401264
XOR Key: 0x5A
Encrypted Data: None (operation is inline)
Decrypted: validation = key ^ 0x5A
```

---

### Lab 7.4: CTF Challenge

**XOR Key:**
```
0x5A
```

**Flag:**
```
FLAG{X0R_1s_Tr1v14l}
```

---

## Lab 8 Solutions

### Lab 8.1: Bypassing Authentication

**Patch:**
```
Original: jne 0x004012c0 (conditional jump)
Patched: jmp 0x004012c0 (unconditional jump)
Effect: Always grants access
```

---

### Lab 8.2: NOP-ing Calls

**Example Patch:**
```
Original: call 0x00401300 (5 bytes)
Patched: 90 90 90 90 90 (NOPs)
Effect: Call is removed
```

---

### Lab 8.3: Modifying Constants

**Example Patch:**
```
Original: cmp [rbp-0x4], 0x40
Patched: cmp [rbp-0x4], 0x00
Effect: Different comparison value
```

---

### Lab 8.4: Patching Challenge

**Solution:**
```
Patch the conditional jump to always take the "granted" path
```

---

## Lab 9 Solutions

### Lab 9.1: Static Triage

**Triage Report:**
```
File Type: ELF 64-bit
Entropy: 7.8 (likely packed)
Suspicious Strings: C2 domains, registry paths
Suspicious Imports: socket, connect, send, recv
Assessment: Likely malware with C2 communication
```

---

### Lab 9.2: IOC Extraction

**IOCs:**
```
Domains: c2-server.example.com
IPs: 192.168.1.100
Registry: HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Malware
Files: C:\Windows\system32\malware.exe
```

---

### Lab 9.3: YARA Rule

```yara
rule Malware_Detector {
    meta:
        author = "Student"
        description = "Detects sample malware"
        version = "1.0"
        
    strings:
        $domain = "c2-server.example.com"
        $registry = "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\Malware"
        $api = "socket"
        
    condition:
        $domain or ($registry and $api)
}
```

---

### Lab 9.4: Analysis Challenge

**Report should include:**
- Triage results
- IOCs
- Behavior description
- YARA rule
- Recommendations

---

## Lab 10 Solutions

### Lab 10.1: Unsafe Functions

**Unsafe Functions Found:**
```
strcpy in validate_access (buffer overflow)
```

---

### Lab 10.2: Data Flow Tracing

**Data Flow:**
```
Source: main → validate_access call
Propagation: message parameter → strcpy
Sink: strcpy(buffer, message)
Risk: Buffer overflow
```

---

### Lab 10.3: Vulnerability Scanner

**Scanner Output:**
```
Found vulnerabilities:
strcpy at 0x004012d9 in validate_access
```

---

### Lab 10.4: Challenge

**Report should include:**
- All vulnerabilities found
- Severity assessment
- Mitigation recommendations

---

## Lab 11 Solutions

### Lab 11.1: XOR Guardian

**Solution:**
```
XOR Key: 0x5A
Flag: FLAG{X0R_1s_7r1v14l}
```

---

### Lab 11.2: Serial Validator

**Solution:**
```
Algorithm: Alternating XOR and multiplication
Valid Serial Example: X9#K@2!$pA1B2C3D4
```

---

### Lab 11.3: Malware Analysis

**Report should include:**
- Complete triage
- IOCs
- Behavior analysis
- YARA rule
- Recommendations

---

### Lab 11.4: Vulnerability Research

**Report should include:**
- All vulnerabilities
- Data flow analysis
- Risk assessment
- Mitigations

---

## Lab 12: Final Challenge

### The Enigma Protocol - Complete Solution

**C2 Domain:**
```
true.engine.industry.ctf.malware.domain
```

**Flag:**
```
FLAG{Enigma_Protocol_Is_Defeated}
```

**IOCs Extracted:**
```
Domains: true.engine.industry.ctf.malware.domain
Port: 4444
Files: /tmp/enigma.conf, /etc/systemd/system/enigma.service
```

**YARA Rule:**
```yara
rule Enigma_Protocol {
    meta:
        author = "Student"
        description = "Detects Enigma Protocol malware"
        version = "1.0"
        
    strings:
        $s1 = "=== Enigma Protocol ==="
        $s2 = "key: 0x5A"
        $s3 = "encrypt"
        $s4 = "decrypt"
        $domain = "true.engine.industry.ctf.malware.domain"
        
    condition:
        $s1 and ($s2 or $s3 or $s4) or $domain
}
```

---

# End of Lab Book

---

**Congratulations on completing the Zero to Hero: Practical Reverse Engineering with Ghidra Lab Book!**

**Remember:**
- Practice regularly
- Document your work
- Share your knowledge
- Use your skills ethically

**Happy Reversing!**
