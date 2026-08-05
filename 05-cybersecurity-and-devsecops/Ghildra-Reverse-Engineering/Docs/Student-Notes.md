# Zero to Hero: Practical Reverse Engineering with Ghidra

## Complete Student Notes - Comprehensive Reference

### Your Personal Reverse Engineering Journal

---

# Table of Contents

**Part 1: Foundations and Environment**  
1.1 Installation Notes  
1.2 Ghidra Interface Overview  
1.3 First Binary Analysis  
1.4 Ghidra Scripting Basics  

**Part 2: Core Analysis Techniques**  
2.1 Control Flow Analysis  
2.2 Cross-References (XREFs)  
2.3 XOR Decryption  
2.4 Binary Patching  

**Part 3: Advanced Topics**  
3.1 Malware Analysis  
3.2 Vulnerability Research  
3.3 Complete Project Notes  

**Part 4: Quick Reference**  
4.1 Shortcuts  
4.2 API Reference  
4.3 Pattern Reference  
4.4 Troubleshooting  

---

# PART 1: FOUNDATIONS AND ENVIRONMENT

---

## 1.1 Installation Notes

### Java Development Kit (JDK) Installation

**Why JDK 17 is Required:**
- Ghidra compiles scripts at runtime
- Uses Java development tools internally
- JRE (Java Runtime Environment) is NOT sufficient

**My Installation Path:**

```
Operating System: [  ]
JDK Version: [  ]
JAVA_HOME: [  ]
```

**Installation Commands:**

```
Windows:
[Write your commands here]

Linux/macOS:
[Write your commands here]
```

**Verification Output:**

```
java -version:
[Paste output here]

javac -version:
[Paste output here]
```

---

### Ghidra Installation

**Download Location:**
```
https://ghidra-sre.org/
```

**Installation Path:**
```
[Your Ghidra path]
```

**Memory Configuration:**

Default: -Xmx2048m (2GB)
Recommended: -Xmx4096m (4GB) or -Xmx8192m (8GB)

My Configuration:
```
[ -Xmx____m ]
```

**Launch Command:**

```
Windows: ghidraRun.bat
Linux/macOS: ./ghidraRun
```

**First Launch Checklist:**
- [ ] Splash screen appears
- [ ] Project Manager opens
- [ ] No Java exceptions
- [ ] .ghidra directory created in home folder

---

### Troubleshooting Notes

| Issue | Solution | Status |
|-------|----------|--------|
| Java not found | Set JAVA_HOME | [ ] |
| Out of memory | Increase -Xmx | [ ] |
| Unsupported Java | Install JDK 17 | [ ] |
| Plugin not loading | Check compatibility | [ ] |

**Additional Notes:**
```
[Write your troubleshooting notes here]












```

---

## 1.2 Ghidra Interface Overview

### The Five Primary Windows

**1. Listing Window**
- Shows disassembled code
- Addresses, bytes, mnemonics
- Color coding: Black=code, Blue=functions, Red=data, Green=comments

**My Observations:**
```
[What do you notice about the Listing Window?]





```

---

**2. Decompiler Window**
- Shows C-like code
- Generic variable names (iVar1, uVar2)
- Shows program logic

**My Observations:**
```
[What do you notice about the Decompiler?]





```

---

**3. Symbol Tree**
- Shows all functions
- Library imports
- Labels and data symbols

**My Observations:**
```
[What do you notice about the Symbol Tree?]





```

---

**4. Data Type Manager**
- Shows data types
- System types
- User-defined types

**My Observations:**
```
[What do you notice about the Data Type Manager?]





```

---

**5. Program Trees**
- Shows file structure
- Sections (.text, .data, etc.)
- Headers (PE/ELF)

**My Observations:**
```
[What do you notice about Program Trees?]





```

---

### Essential Navigation Shortcuts

| Shortcut | Action | I Remember? |
|----------|--------|-------------|
| `G` | Go to address/function | [ ] |
| `F` | Search for function | [ ] |
| `Ctrl+F` | Find text | [ ] |
| `X` | Show cross-references | [ ] |
| `Ctrl+E` | Show decompiler | [ ] |
| `F11` | Toggle focus | [ ] |
| `B` | Set bookmark | [ ] |
| `N` | Rename symbol | [ ] |
| `;` | Add comment | [ ] |
| `Alt+Left/Right` | Back/Forward | [ ] |
| `Ctrl+S` | Save program | [ ] |

**Additional Shortcuts I Discovered:**
```
[Write your own shortcuts here]





```

---

## 1.3 First Binary Analysis

### The Calculator Program

**My Understanding of the Program:**

```
[What does this program do?]










```

**Key Functions Identified:**

| Function | Purpose | My Notes |
|----------|---------|----------|
| main | | |
| add | | |
| subtract | | |
| multiply | | |
| divide | | |
| validate_access | | |

---

### Renaming Variables

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

**My Renaming Decisions:**

| Original | New Name | Why I Chose This |
|----------|----------|------------------|
| param_1 | | |
| param_2 | | |
| local_4 | | |
| local_8 | | |
| local_12 | | |

---

### Adding Comments

**Function-Level Comments:**

```
validate_access: 
[What does this function do?]





strcpy vulnerability:
[Why is this dangerous?]





XOR operation:
[What is the XOR key and what does it do?]





```

**Instruction-Level Comments:**
```
[Document key instructions here]





```

---

### My Analysis Process

1. **Observation:**
```
[What did you observe first?]

```

2. **Hypothesis:**
```
[What did you think the program did?]

```

3. **Verification:**
```
[How did you confirm your hypothesis?]

```

4. **Conclusion:**
```
[What did you learn?]

```

---

## 1.4 Ghidra Scripting Basics

### Script Template

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script Name: [Your Script Name]
Author: [Your Name]
Date: [Date]
Purpose: [Description]
"""

from __future__ import print_function

def main():
    """Main entry point."""
    print("[*] Script started")
    
    if not currentProgram:
        print("[!] No program loaded")
        return
    
    print("[*] Program: {}".format(currentProgram.getName()))
    
    # Your code here
    
    print("[*] Script complete!")

if __name__ == "__main__":
    main()
```

---

### My Scripts Collection

**Script 1: Function Enumerator**
```python
# Purpose: List all functions with entry points
# Created: [Date]
# Used for: [What you use it for]

[Your code here]




```

**Script 2: String Extractor**
```python
# Purpose: Extract all strings
# Created: [Date]
# Used for: [What you use it for]

[Your code here]




```

**Script 3: Memory Dumper**
```python
# Purpose: Dump memory to file
# Created: [Date]
# Used for: [What you use it for]

[Your code here]




```

**Script 4: Custom Script**
```python
# Purpose: [Description]
# Created: [Date]

[Your code here]




```

---

### API Functions I've Used

| API Function | Purpose | Example |
|--------------|---------|---------|
| `currentProgram` | Get open binary | `program = currentProgram` |
| `getFunctionManager()` | Access functions | `func_manager = program.getFunctionManager()` |
| `getFunctions(True)` | Iterate functions | `for func in func_manager.getFunctions(True):` |
| `getBytes(addr, len)` | Read memory | `data = getBytes(addr, 16)` |
| `setByte(addr, val)` | Write memory | `setByte(addr, 0x90)` |
| `getListing()` | Access instructions/data | `listing = program.getListing()` |

---

### Python Scripting Tips

**Error Handling:**
```python
try:
    data = getBytes(addr, length)
except MemoryAccessException as e:
    print("[!] Error: {}".format(str(e)))
```

**Progress Reporting:**
```python
for i, func in enumerate(functions):
    if i % 10 == 0:
        print("[*] Processing {}/{}".format(i, total))
```

**Debugging:**
```python
print("[DEBUG] Address: 0x{:08x}".format(addr.getOffset()))
print("[DEBUG] Value: {}".format(value))
```

---

# PART 2: CORE ANALYSIS TECHNIQUES

---

## 2.1 Control Flow Analysis

### Basic Blocks

**Definition:** A sequence of instructions with one entry point and one exit point.

**How to Identify Basic Blocks:**
1. Start at function entry
2. Follow instructions until branch
3. Branch target starts new block

**Example from validate_access:**
```
Block 1 (Entry):
    push rbp
    mov rbp, rsp
    sub rsp, 0x30
    mov [rbp-0x24], edi
    ; ...
    cmp [rbp-0x4], 0x40
    jne Block_3

Block 2 (True):
    lea rdi, [msg_granted]
    call printf
    jmp Block_4

Block 3 (False):
    lea rdi, [msg_denied]
    call printf

Block 4 (Merge):
    mov rdx, [rbp-0x28]
    lea rax, [rbp-0x20]
    call strcpy
    ; ...
    leave
    ret
```

**My Basic Block Identification Practice:**
```
[Identify basic blocks in a function you analyzed]









```

---

### Conditional Branches

**Common Branch Types:**

| Assembly | Meaning | C Equivalent |
|----------|---------|--------------|
| `cmp a, b; jg label` | Jump if a > b | `if (a > b)` |
| `cmp a, b; jl label` | Jump if a < b | `if (a < b)` |
| `cmp a, b; je label` | Jump if a == b | `if (a == b)` |
| `cmp a, b; jne label` | Jump if a != b | `if (a != b)` |
| `test a, a; jz label` | Jump if a == 0 | `if (a == 0)` |
| `test a, a; jnz label` | Jump if a != 0 | `if (a != 0)` |

**Conditional Branch Examples I Found:**
```
[Document conditional branches you've encountered]






```

---

### Loops

**For Loop Pattern:**
```assembly
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
```assembly
loop_start:
cmp ecx, 0x0A
jge loop_end
    ; loop body
inc ecx
jmp loop_start
loop_end:
```

**Do-While Loop Pattern:**
```assembly
loop_start:
    ; loop body
inc ecx
cmp ecx, 0x0A
jl loop_start
```

**Loop Examples I Found:**
```
[Document loops you've encountered]






```

---

### Function Graph

**How to Access:**
1. Navigate to function
2. Click Function Graph button (or press `G`)
3. View visual control flow

**What to Observe:**
- **Green blocks:** Entry points
- **Red blocks:** Exit points
- **Arrows:** Flow direction
- **Colors:** Different paths

**My Function Graph Observations:**
```
[Document what you see in Function Graphs]








```

---

## 2.2 Cross-References (XREFs)

### Finding Strings

**How to Find Strings:**
1. `Window` → `Defined Strings`
2. Browse list
3. Double-click to navigate
4. Press `X` for references

**Interesting Strings Found:**

| String | Address | Where Used | Significance |
|--------|---------|------------|--------------|
| | | | |
| | | | |
| | | | |
| | | | |

---

### Tracing Function Calls

**Finding Callers (Incoming XREFs):**
1. Navigate to function
2. Right-click → "Show References to Function"
3. View all callers

**Finding Callees (Outgoing XREFs):**
1. Navigate to function
2. Right-click → "Show References from Function"
3. View all callees

**Call Graph for validate_access:**

```
Who Calls validate_access?
[Callers]

Who Does validate_access Call?
[Callees]

```

---

### Data References

**Tracing Data Usage:**
1. Find data/string
2. Right-click → "Show References"
3. Follow to code

**Data Flow Example:**
```
String: "Access granted!"
    ↓ (XREF)
Instruction: lea rdi, [rip+0x0d6d]
    ↓
Instruction: call printf
    ↓
Function: validate_access
```

**My Data Flow Tracing:**
```
[Document your tracing here]





```

---

## 2.3 XOR Decryption

### XOR Fundamentals

**Properties of XOR:**
- A XOR B = B XOR A (Commutative)
- (A XOR B) XOR B = A (Self-inverse)
- A XOR 0 = A (Identity)
- A XOR A = 0 (Zero)

**XOR as Encryption:**
```
Plaintext  ^ Key = Ciphertext
Ciphertext ^ Key = Plaintext
(Plaintext ^ Key) ^ Key = Plaintext
```

---

### Manual XOR Decryption

**Example from validate_access:**
```
key ^ 0x1A = 0x40
key = 0x40 ^ 0x1A
key = 0x5A

Secret message: "RE_MASTER"
```

**My XOR Decryption Practice:**

| Encrypted | Key | Decrypted |
|-----------|-----|-----------|
| | | |
| | | |
| | | |

---

### XOR Decryptor Script

**Base Script:**
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
print(decrypted)
```

**My Extended XOR Script:**
```python
# [Your custom XOR script here]





```

---

## 2.4 Binary Patching

### Patch Types

| Type | Effect | Example |
|------|--------|---------|
| **Jump Modification** | Change branch behavior | `jne` → `jmp` |
| **NOP Out** | Remove instruction | `call` → `nop nop...` |
| **Constant Change** | Modify value | `cmp eax,0x40` → `cmp eax,0x00` |
| **Data Change** | Modify string | "Access denied" → "Access granted" |

---

### Patch Methods

**Method 1: Patch Instruction (GUI)**
1. Right-click instruction
2. Select "Patch Instruction"
3. Modify
4. Click "OK"

**Method 2: Patch Bytes (GUI)**
1. Right-click address
2. Select "Patch Bytes"
3. Enter new bytes
4. Click "OK"

**Method 3: Scripting**
```python
# Write NOPs
setByte(addr, 0x90)
setBytes(addr, [0x90, 0x90, 0x90])
```

---

### My Patches

**Patch 1: Bypass Authentication**
```
Function: [Name]
Address: [Address]
Original: [Original bytes]
Patched: [New bytes]
Result: [What changed?]
```

**Patch 2: [Description]**
```
Function: [Name]
Address: [Address]
Original: [Original bytes]
Patched: [New bytes]
Result: [What changed?]
```

**Patch 3: [Description]**
```
Function: [Name]
Address: [Address]
Original: [Original bytes]
Patched: [New bytes]
Result: [What changed?]
```

---

### Saving Patched Binaries

**Export Steps:**
1. `File` → `Export Program`
2. Select format (Original, ELF, PE)
3. Choose filename
4. Click "OK"

**My Patched Binaries:**
```
[Document your patched binaries]





```

---

# PART 3: ADVANCED TOPICS

---

## 3.1 Malware Analysis

### Static Triage Checklist

| Step | Tool | Result |
|------|------|--------|
| File Type | `file` | |
| File Size | `ls -lh` | |
| Entropy | Custom script | |
| Strings | `strings` | |
| Imports | `readelf -d` | |
| Sections | `readelf -S` | |

**Packing Indicators Found:**
- [ ] High entropy (> 7.5)
- [ ] Strange section names
- [ ] Small .text section
- [ ] Few imports

---

### Common Malware Behaviors

| Behavior | Indicators | Found? |
|----------|------------|--------|
| Process Injection | `VirtualAllocEx`, `WriteProcessMemory` | [ ] |
| Persistence | Registry Run keys | [ ] |
| C2 Communication | `socket`, `connect` | [ ] |
| Anti-Analysis | `IsDebuggerPresent` | [ ] |
| File Operations | `CreateFile`, `WriteFile` | [ ] |

---

### IOC Extraction

**Domains Found:**
```
[Domain list]
```

**IP Addresses Found:**
```
[IP list]
```

**Registry Paths Found:**
```
[Registry list]
```

**File Paths Found:**
```
[File list]
```

---

### YARA Rule Template

```yara
/*
 * YARA Rule: [Rule Name]
 * Author: [Your Name]
 * Date: [Date]
 * Description: [Description]
 */

rule [Rule_Name] {
    meta:
        author = "[Your Name]"
        description = "[Description]"
        version = "1.0"
        confidence = "Medium"
        
    strings:
        $string1 = "[String 1]"
        $string2 = "[String 2]"
        $hex1 = { [Hex Pattern] }
        
    condition:
        $string1 or $string2 or $hex1
}
```

---

### My YARA Rules

**Rule 1:**
```yara
[Your rule here]



```

**Rule 2:**
```yara
[Your rule here]



```

---

## 3.2 Vulnerability Research

### Memory Corruption Types

| Type | Description | Example |
|------|-------------|---------|
| Stack Overflow | Overwriting stack variables | `strcpy(buffer, input)` |
| Heap Overflow | Overwriting heap memory | `malloc` + `strcpy` |
| Format String | User input as format | `printf(user_input)` |
| Integer Overflow | Arithmetic wrap | `size * 2` overflow |
| Use-After-Free | Accessing freed memory | `free(ptr); ptr[0] = 0;` |

**My Vulnerability Notes:**
```
[Document vulnerabilities you've found]





```

---

### Data Flow Analysis

**Source (Input):**
```
[Where does input enter?]
```

**Propagation:**
```
[How does data move?]
```

**Sink (Dangerous Function):**
```
[Where is the vulnerable function?]
```

**Sanitization:**
```
[Is input validated?]
```

---

### Vulnerability Discovery Script

```python
# Dangerous functions to detect
dangerous = ['strcpy', 'sprintf', 'gets', 'printf']

def find_vulnerabilities():
    """Find dangerous function calls."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    for func in functions:
        body = func.getBody()
        instructions = listing.getInstructions(body, True)
        
        while instructions.hasNext():
            instr = instructions.next()
            if instr.isCall():
                for target in instr.getFlows():
                    target_func = getFunctionAt(target)
                    if target_func and target_func.getName() in dangerous:
                        print("VULNERABILITY: {} at 0x{:08x}".format(
                            target_func.getName(),
                            instr.getAddress().getOffset()
                        ))
```

**My Vulnerability Scanner Extensions:**
```
[Add your own checks]



```

---

### Exploit Calculation

**For Stack Overflow:**
```
Buffer Size: [ ] bytes
Saved RBP: [ ] bytes
Return Address: [ ] bytes
Offset to Return: [ ] bytes
```

**Payload Structure:**
```
[Define the exploit payload]
```

**My Exploit Notes:**
```
[Document exploit calculations]





```

---

## 3.3 Complete Project Notes

### Project 1: XOR Guardian

**My Approach:**
```
[Describe your approach]




```

**Key Findings:**
```
[Document key findings]




```

**Flag:**
```
[Write the flag here]

```

---

### Project 2: Serial Validator

**My Approach:**
```
[Describe your approach]




```

**Validation Algorithm:**
```
[Document the algorithm]




```

**Keygen Code:**
```python
[Write your keygen here]



```

---

### Project 3: Malware Analysis

**My Approach:**
```
[Describe your approach]




```

**IOCs Found:**
```
[Document IOCs]




```

**YARA Rule:**
```yara
[Write your YARA rule here]



```

---

### Project 4: Vulnerability Research

**My Approach:**
```
[Describe your approach]




```

**Vulnerabilities Found:**
```
[Document vulnerabilities]




```

**Mitigations:**
```
[Document fixes]




```

---

# PART 4: QUICK REFERENCE

---

## 4.1 Shortcuts

### Navigation Shortcuts

| Shortcut | Action |
|----------|--------|
| `G` | Go to address/function |
| `F` | Search for function |
| `Ctrl+F` | Find text |
| `Alt+Left` | Go back |
| `Alt+Right` | Go forward |
| `Ctrl+Home` | Top of program |
| `Ctrl+End` | Bottom of program |
| `Ctrl+G` | Specific address |

### Analysis Shortcuts

| Shortcut | Action |
|----------|--------|
| `X` | Show cross-references |
| `Ctrl+E` | Show decompiler |
| `F11` | Toggle focus |
| `B` | Set bookmark |
| `N` | Rename symbol |
| `;` | Add comment |
| `H` | Highlight flow |
| `Ctrl+I` | Identify instruction |

### Scripting Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+R` | Run last script |
| `Ctrl+Shift+P` | Open Script Manager |
| `Ctrl+Shift+S` | Stop script |

---

## 4.2 API Reference

### Program Object

| Method | Description |
|--------|-------------|
| `getName()` | Get program name |
| `getFunctionManager()` | Access functions |
| `getListing()` | Access instructions/data |
| `getSymbolTable()` | Access symbols |
| `getMemory()` | Access memory |
| `getAddressFactory()` | Create addresses |
| `getImageBase()` | Get base address |

### Function Object

| Method | Description |
|--------|-------------|
| `getName()` / `setName()` | Get/set name |
| `getEntryPoint()` | Get entry address |
| `getBody()` | Get address range |
| `getParameters()` | Get parameters |
| `getParameterCount()` | Get parameter count |
| `getCalledFunctions()` | Get called functions |
| `getCallingFunctions()` | Get callers |

### Address Object

| Method | Description |
|--------|-------------|
| `getOffset()` | Get numeric offset |
| `add(offset)` | Add offset |
| `subtract(offset)` | Subtract offset |
| `compareTo(other)` | Compare addresses |

### Memory Functions

| Function | Description |
|----------|-------------|
| `getBytes(addr, len)` | Read bytes |
| `getByte(addr)` | Read byte |
| `getInt(addr)` | Read integer |
| `getLong(addr)` | Read long |
| `setByte(addr, val)` | Write byte |
| `setBytes(addr, data)` | Write bytes |

---

## 4.3 Pattern Reference

### Function Prologue

**x86_64:**
```assembly
push rbp
mov rbp, rsp
sub rsp, 0x20
```

**x86:**
```assembly
push ebp
mov ebp, esp
sub esp, 0x20
```

### Function Epilogue

**x86_64:**
```assembly
leave
ret
```

**x86:**
```assembly
mov esp, ebp
pop ebp
ret
```

### Conditional Jumps

| Instruction | Condition |
|-------------|-----------|
| `JE` / `JZ` | Equal / Zero |
| `JNE` / `JNZ` | Not Equal / Not Zero |
| `JG` / `JNLE` | Greater (signed) |
| `JL` / `JNGE` | Less (signed) |
| `JA` / `JNBE` | Above (unsigned) |
| `JB` / `JC` | Below / Carry (unsigned) |

### Common NOP Sequences

| Instruction | Bytes |
|-------------|-------|
| `nop` | `90` |
| `mov rbp, rbp` | `48 89 ED` |
| `lea rsp, [rsp+0]` | `48 8D 64 24 00` |

---

## 4.4 Troubleshooting

### Common Errors

| Error | Solution |
|-------|----------|
| Java not found | Set JAVA_HOME |
| Out of memory | Increase -Xmx |
| Unsupported Java | Install JDK 17 |
| MemoryAccessException | Check address validity |
| AttributeError | Verify object exists |

### Debugging Tips

1. **Use print statements:**
```python
print("[DEBUG] Value: {}".format(value))
```

2. **Check for None:**
```python
if func is None:
    print("[!] Function not found")
    return
```

3. **Use try/except:**
```python
try:
    data = getBytes(addr, 16)
except MemoryAccessException as e:
    print("[!] Error: {}".format(str(e)))
```

---

# Personal Notes Section

## Additional Techniques I've Learned

```
[Document additional techniques here]
















```

---

## Questions I Want to Research

```
[Document questions here]
















```

---

## Resources and References

```
[Document resources here]
















```

---

## Key Takeaways

```
[Document key takeaways here]
















```

---

# Final Checklist

## Environment
- [ ] JDK 17 installed
- [ ] Ghidra installed
- [ ] Memory configured
- [ ] Script directory set up

## Basic Skills
- [ ] Can navigate Ghidra interface
- [ ] Can use Listing Window
- [ ] Can use Decompiler Window
- [ ] Can use Symbol Tree
- [ ] Can use Program Trees

## Analysis Skills
- [ ] Can find main function
- [ ] Can rename variables
- [ ] Can add comments
- [ ] Can set data types
- [ ] Can use XREFs
- [ ] Can identify XOR patterns
- [ ] Can patch binaries

## Scripting Skills
- [ ] Can write basic Python scripts
- [ ] Can enumerate functions
- [ ] Can read memory
- [ ] Can write memory
- [ ] Can handle errors

## Advanced Skills
- [ ] Can analyze malware
- [ ] Can extract IOCs
- [ ] Can create YARA rules
- [ ] Can identify vulnerabilities
- [ ] Can trace data flow

## Projects Completed
- [ ] XOR Guardian
- [ ] Serial Validator
- [ ] Malware Analysis
- [ ] Vulnerability Research

---

# End of Student Notes

---

**These notes are your personal reference. Keep them updated and organized for quick access during analysis.**

**Happy Reversing!**
