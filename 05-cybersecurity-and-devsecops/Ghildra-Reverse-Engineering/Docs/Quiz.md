# Zero to Hero: Practical Reverse Engineering with Ghidra

## Comprehensive Quiz and Test Bank with Answer Keys

### Instructor Assessment Resources

---

# Table of Contents

**Section 1: Module Quizzes**
- Module 1 Quiz: Foundations and Environment
- Module 2 Quiz: Ghidra Interface and Navigation
- Module 3 Quiz: First Binary Analysis
- Module 4 Quiz: Ghidra Scripting Basics
- Module 5 Quiz: Control Flow Analysis
- Module 6 Quiz: Cross-References (XREFs)
- Module 7 Quiz: XOR Decryption
- Module 8 Quiz: Binary Patching
- Module 9 Quiz: Malware Analysis
- Module 10 Quiz: Vulnerability Research

**Section 2: Module Tests**
- Module 1 Test: Foundations and Environment
- Module 2 Test: Ghidra Interface and Navigation
- Module 3 Test: First Binary Analysis
- Module 4 Test: Ghidra Scripting Basics
- Module 5 Test: Control Flow Analysis
- Module 6 Test: Cross-References (XREFs)
- Module 7 Test: XOR Decryption
- Module 8 Test: Binary Patching
- Module 9 Test: Malware Analysis
- Module 10 Test: Vulnerability Research

**Section 3: Comprehensive Exams**
- Midterm Examination
- Final Examination
- Practical Skills Assessment

**Section 4: Answer Keys**
- Module Quiz Answer Keys
- Module Test Answer Keys
- Comprehensive Exam Answer Keys

**Section 5: Grading Rubrics**
- Written Response Rubric
- Practical Skills Rubric
- Project Rubric

---

# Section 1: Module Quizzes

---

## Module 1 Quiz: Foundations and Environment

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. Which Java version is required for Ghidra?**
- A) Java 8
- B) Java 11
- C) Java 17
- D) Java 21

**2. What is the difference between JDK and JRE?**
- A) JDK is for Windows, JRE is for Linux
- B) JDK includes development tools, JRE only runs programs
- C) JDK is older than JRE
- D) There is no difference

**3. Which of the following is NOT a valid executable format?**
- A) PE
- B) ELF
- C) Mach-O
- D) EXE

**4. Where does Ghidra store its configuration files?**
- A) In the installation directory
- B) In the user's home directory (.ghidra)
- C) In the Windows registry
- D) In the system temp folder

**5. What is the purpose of the `-Xmx` parameter?**
- A) To enable debugging
- B) To set the maximum memory allocation
- C) To specify the Java version
- D) To configure the network settings

---

### True/False (1 point each)

**6.** Ghidra can only analyze Windows executables.  
☐ True ☐ False

**7.** The Java Development Kit (JDK) is required to run Ghidra.  
☐ True ☐ False

**8.** PE is the executable format used by Windows.  
☐ True ☐ False

**9.** Ghidra projects can only contain one binary.  
☐ True ☐ False

**10.** The entry point is where program execution starts.  
☐ True ☐ False

---

### Short Answer (1 point each)

**11.** What does the acronym "PE" stand for?

**12.** What is the name of the Linux executable format?

**13.** What command is used to verify Java installation?

**14.** Where is the `e_lfanew` field located?

**15.** What is the purpose of the Image Base?

---

## Module 2 Quiz: Ghidra Interface and Navigation

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. Which window shows the disassembled code?**
- A) Decompiler Window
- B) Listing Window
- C) Symbol Tree
- D) Program Trees

**2. Which shortcut is used to go to a specific address?**
- A) `Ctrl+F`
- B) `G`
- C) `F`
- D) `X`

**3. What color are functions in the Listing Window?**
- A) Black
- B) Blue
- C) Red
- D) Green

**4. What does the Decompiler Window show?**
- A) Machine code bytes
- B) Assembly instructions
- C) C-like code
- D) File structure

**5. Which window shows all functions in the program?**
- A) Listing Window
- B) Decompiler Window
- C) Symbol Tree
- D) Program Trees

---

### True/False (1 point each)

**6.** The Decompiler Window shows machine code in hexadecimal.  
☐ True ☐ False

**7.** `F11` toggles focus between Listing and Decompiler.  
☐ True ☐ False

**8.** The Symbol Tree shows imported functions.  
☐ True ☐ False

**9.** Program Trees show the file structure of the binary.  
☐ True ☐ False

**10.** `Ctrl+S` saves the current analysis.  
☐ True ☐ False

---

### Matching (1 point each)

**Match the shortcut to its action:**

| Shortcut | Action |
|----------|--------|
| 11. `X` | A. Rename symbol |
| 12. `N` | B. Add comment |
| 13. `;` | C. Show cross-references |
| 14. `B` | D. Set bookmark |
| 15. `Ctrl+E` | E. Show decompiler |

---

### Short Answer (1 point each)

**16.** What is the purpose of the Program Trees window?

**17.** How do you find a function by name?

**18.** What color represents data references in the Listing Window?

**19.** What does the Function Graph show?

**20.** What is a bookmark used for?

---

## Module 3 Quiz: First Binary Analysis

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. What is the first step after importing a binary?**
- A) Rename variables
- B) Run analysis
- C) Add comments
- D) Set data types

**2. What are generic variable names like `iVar1` called?**
- A) User-defined names
- B) Compiler names
- C) Decompiler-generated names
- D) Assembly names

**3. How do you rename a variable in Ghidra?**
- A) Double-click and type
- B) Right-click → Rename Variable
- C) Press `R` on the keyboard
- D) Use the Symbol Tree

**4. What is the purpose of setting correct data types?**
- A) To make the decompiler more accurate
- B) To change the binary
- C) To add new functions
- D) To remove variables

**5. Which function in the calculator program contains a vulnerability?**
- A) main
- B) add
- C) validate_access
- D) multiply

---

### True/False (1 point each)

**6.** The `main` function is always named `main` in Ghidra.  
☐ True ☐ False

**7.** Comments in Ghidra are only visible to the current user.  
☐ True ☐ False

**8.** Data types must be set manually by the analyst.  
☐ True ☐ False

**9.** The `validate_access` function contains a buffer overflow vulnerability.  
☐ True ☐ False

**10.** Renaming variables changes the executable file.  
☐ True ☐ False

---

### Short Answer (2 points each)

**11.** What is the vulnerability in the `validate_access` function and why is it dangerous?

**12.** Explain the XOR validation logic in `validate_access` and what key would be valid.

**13.** Why is it important to rename variables and add comments during analysis?

**14.** What is the difference between `strcpy` and `strncpy` in terms of security?

**15.** How does the decompiler help in understanding compiled code?

---

## Module 4 Quiz: Ghidra Scripting Basics

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. Which language is most commonly used for Ghidra scripting?**
- A) Java
- B) Python
- C) JavaScript
- D) C++

**2. What is the name of the pre-loaded object representing the current program?**
- A) `currentProgram`
- B) `program`
- C) `binary`
- D) `executable`

**3. How do you get all functions in the current program?**
- A) `currentProgram.getFunctions()`
- B) `currentProgram.getFunctionManager().getFunctions(True)`
- C) `currentProgram.getAllFunctions()`
- D) `currentProgram.functions`

**4. Which function is used to read bytes from memory?**
- A) `readBytes()`
- B) `getBytes()`
- C) `memoryRead()`
- D) `bytesRead()`

**5. How do you run a script in Ghidra?**
- A) Click "Run" in the Script Manager
- B) Press `Ctrl+R`
- C) Double-click the script file
- D) Use the command line

---

### True/False (1 point each)

**6.** Scripts must be written in Java to work in Ghidra.  
☐ True ☐ False

**7.** The Script Manager is used to create and run scripts.  
☐ True ☐ False

**8.** `currentProgram` is always available in a Ghidra script.  
☐ True ☐ False

**9.** Error handling is not necessary in Ghidra scripts.  
☐ True ☐ False

**10.** `setByte()` can be used to write data to memory.  
☐ True ☐ False

---

### Fill in the Blank (1 point each)

**11.** The Script Manager can be opened with the shortcut ____.

**12.** The function to get the number of functions is `func_manager._______()`.

**13.** The `toAddr()` function creates an __________ object.

**14.** `MemoryAccessException` occurs when reading ________ memory.

**15.** The `setName()` method is used to ________ a function.

---

## Module 5 Quiz: Control Flow Analysis

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. What is a basic block?**
- A) A sequence of code with one entry and one exit
- B) The smallest unit of code
- C) A single instruction
- D) A function

**2. Which instruction is used for an unconditional jump?**
- A) `JMP`
- B) `JE`
- C) `JNE`
- D) `CALL`

**3. What does the Function Graph show?**
- A) Memory layout
- B) Visual control flow
- C) Function parameters
- D) Data types

**4. Which jump instruction means "jump if less than"?**
- A) `JG`
- B) `JL`
- C) `JA`
- D) `JB`

**5. What is the difference between `JG` and `JA`?**
- A) `JG` is signed, `JA` is unsigned
- B) `JA` is signed, `JG` is unsigned
- C) They are the same
- D) `JG` is for jumps, `JA` is for calls

---

### True/False (1 point each)

**6.** A basic block can have multiple entry points.  
☐ True ☐ False

**7.** The Function Graph is only available for ELF binaries.  
☐ True ☐ False

**8.** `JNE` and `JNZ` are the same instruction.  
☐ True ☐ False

**9.** Loops are identified by backward jumps.  
☐ True ☐ False

**10.** The Function Graph can be opened with the `G` shortcut.  
☐ True ☐ False

---

### Short Answer (2 points each)

**11.** What are the three types of loops found in compiled code?

**12.** Describe the if-else pattern in assembly.

**13.** How does a `for` loop differ from a `while` loop in assembly?

**14.** What is the purpose of the `cmp` instruction?

**15.** How does the Function Graph help in understanding complex code?

---

## Module 6 Quiz: Cross-References (XREFs)

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. What does XREF stand for?**
- A) Execute Reference
- B) External Reference
- C) Cross-Reference
- D) Code Reference

**2. How do you show cross-references in Ghidra?**
- A) Right-click → Show Cross-References
- B) Press `X`
- C) Both A and B
- D) Neither

**3. What are incoming references?**
- A) References to a location
- B) References from a location
- C) References to other files
- D) References to system libraries

**4. Which window shows all defined strings?**
- A) Listing Window
- B) Defined Strings
- C) Symbol Tree
- D) Program Trees

**5. What type of reference is a function call?**
- A) Data reference
- B) Code reference
- C) External reference
- D) Internal reference

---

### True/False (1 point each)

**6.** XREFs only show code references.  
☐ True ☐ False

**7.** The `X` shortcut shows cross-references.  
☐ True ☐ False

**8.** Defined Strings shows all strings in the binary.  
☐ True ☐ False

**9.** Data references point to strings and variables.  
☐ True ☐ False

**10.** Incoming references show what a function calls.  
☐ True ☐ False

---

### Short Answer (2 points each)

**11.** How do you find who calls a specific function?

**12.** What is the difference between incoming and outgoing references?

**13.** How can XREFs help find validation logic?

**14.** What is the purpose of the Defined Strings window?

**15.** How do you follow a string to its usage?

---

## Module 7 Quiz: XOR Decryption

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. What does XOR stand for?**
- A) Exclusive OR
- B) Extended Operation Register
- C) Execute Output Read
- D) Extended Output Range

**2. Which of the following is a property of XOR?**
- A) A XOR B = B XOR A
- B) (A XOR B) XOR B = A
- C) A XOR 0 = A
- D) All of the above

**3. If encrypted data is XORed with the same key, what do you get?**
- A) The original plaintext
- B) Different ciphertext
- C) The key
- D) Nothing

**4. Which instruction performs XOR in x86 assembly?**
- A) `AND`
- B) `OR`
- C) `XOR`
- D) `NOT`

**5. In the validate_access function, what is the XOR key?**
- A) 0x1A
- B) 0x40
- C) 0x5A
- D) 0x10

---

### True/False (1 point each)

**6.** XOR encryption is symmetric.  
☐ True ☐ False

**7.** The XOR key can only be a single byte.  
☐ True ☐ False

**8.** XOR is commonly used for obfuscation in CTF challenges.  
☐ True ☐ False

**9.** XOR can be used for both encryption and decryption.  
☐ True ☐ False

**10.** If you know the plaintext and ciphertext, you can find the key.  
☐ True ☐ False

---

### Short Answer (2 points each)

**11.** Given `Encrypted = 0x3B 0x52 0x4D 0x52` and key `0x5A`, what is the plaintext?

**12.** If `Plaintext ^ Key = Ciphertext`, what is the formula to find `Key`?

**13.** Why is XOR commonly used in reverse engineering challenges?

**14.** How can you identify an XOR encryption routine in disassembly?

**15.** What is the valid key for `validate_access` and why?

---

## Module 8 Quiz: Binary Patching

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. What is binary patching?**
- A) Modifying the source code
- B) Modifying the compiled binary
- C) Creating a new binary
- D) Decompiling the binary

**2. Which instruction is a NOP?**
- A) `JMP`
- B) `RET`
- C) `NOP`
- D) `CALL`

**3. What does NOP stand for?**
- A) No Operation
- B) New Operation
- C) Negative Operation
- D) Null Operation

**4. What is the hex value for a NOP instruction?**
- A) 0x00
- B) 0x01
- C) 0x90
- D) 0xFF

**5. Which method is NOT used for patching in Ghidra?**
- A) Patch Instruction
- B) Patch Bytes
- C) Patch Script
- D) Memory Editor

---

### True/False (1 point each)

**6.** Patching changes the original binary file.  
☐ True ☐ False

**7.** You can export a patched binary from Ghidra.  
☐ True ☐ False

**8.** `JNE` can be changed to `JMP` to always take a branch.  
☐ True ☐ False

**9.** NOP instructions can be used to remove function calls.  
☐ True ☐ False

**10.** Patching is only used for bypassing authentication.  
☐ True ☐ False

---

### Short Answer (2 points each)

**11.** What is the difference between "Patch Instruction" and "Patch Bytes"?

**12.** How would you bypass a conditional jump?

**13.** What is the purpose of exporting a patched binary?

**14.** How can NOP instructions be used in patching?

**15.** What are the risks of binary patching?

---

## Module 9 Quiz: Malware Analysis

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. What does IOC stand for?**
- A) Internal Operation Code
- B) Indicator of Compromise
- C) Instruction Operation Control
- D) Input Output Command

**2. Which is NOT a type of IOC?**
- A) Domain
- B) IP Address
- C) File Path
- D) Variable Name

**3. What does C2 stand for?**
- A) Control Channel
- B) Command and Control
- C) Code to Code
- D) Call and Connect

**4. What is YARA used for?**
- A) Debugging
- B) Binary patching
- C) Malware detection
- D) Decompilation

**5. Which API is commonly used for process injection?**
- A) `CreateFile`
- B) `VirtualAllocEx`
- C) `RegOpenKeyEx`
- D) `socket`

---

### True/False (1 point each)

**6.** Packed malware has high entropy.  
☐ True ☐ False

**7.** YARA rules can only detect strings.  
☐ True ☐ False

**8.** Static analysis involves executing the malware.  
☐ True ☐ False

**9.** The `.text` section typically contains executable code.  
☐ True ☐ False

**10.** `IsDebuggerPresent` is an anti-analysis technique.  
☐ True ☐ False

---

### Short Answer (2 points each)

**11.** What is static malware triage?

**12.** What are the indicators of a packed binary?

**13.** What is the purpose of a YARA rule?

**14.** What is persistence in malware?

**15.** How can IOCs be used in incident response?

---

## Module 10 Quiz: Vulnerability Research

**Duration:** 15 minutes
**Total Points:** 20

---

### Multiple Choice (2 points each)

**1. What is a stack buffer overflow?**
- A) Writing beyond the stack buffer
- B) Writing beyond the heap buffer
- C) Overflowing the CPU cache
- D) Overflowing the disk buffer

**2. Which function is considered unsafe?**
- A) `strncpy`
- B) `strcpy`
- C) `strlen`
- D) `strcmp`

**3. What is a format string vulnerability?**
- A) User input as a format string
- B) User input as a number
- C) User input as a string
- D) User input as a character

**4. What is a sink in data flow analysis?**
- A) Where input enters
- B) Where dangerous function is called
- C) Where data is validated
- D) Where data is stored

**5. What is the source in data flow analysis?**
- A) Where input enters
- B) Where dangerous function is called
- C) Where data is validated
- D) Where data is stored

---

### True/False (1 point each)

**6.** `sprintf` is a safe function.  
☐ True ☐ False

**7.** Stack canaries detect buffer overflows.  
☐ True ☐ False

**8.** User input always reaches a sink.  
☐ True ☐ False

**9.** Integer overflow is a type of vulnerability.  
☐ True ☐ False

**10.** Use-After-Free occurs when accessing freed memory.  
☐ True ☐ False

---

### Short Answer (2 points each)

**11.** What is the difference between a stack and heap overflow?

**12.** How can you detect unsafe function calls?

**13.** What is data flow analysis and why is it important?

**14.** What is a use-after-free vulnerability?

**15.** How can integer overflows be exploited?

---

# Section 2: Module Tests

---

## Module 1 Test: Foundations and Environment

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. Which of the following is required to run Ghidra?**
- A) JRE 8
- B) JDK 11
- C) JDK 17
- D) JRE 17

**2. What is the purpose of the `JAVA_HOME` environment variable?**
- A) To set the default Java version
- B) To point to the Java installation directory
- C) To configure Java memory settings
- D) To specify the Java classpath

**3. Which executable format is used by Windows?**
- A) ELF
- B) Mach-O
- C) PE
- D) COFF

**4. What does the `-Xmx` parameter control?**
- A) Java version
- B) Maximum heap size
- C) Minimum heap size
- D) Garbage collection

**5. Where does Ghidra store its projects?**
- A) In the installation directory
- B) In a user-specified directory
- C) In the system temp folder
- D) In the Windows registry

**6. Which of the following is NOT a component of a PE file?**
- A) DOS Header
- B) NT Headers
- C) ELF Header
- D) Section Headers

**7. What does the e_lfanew field point to?**
- A) The DOS Header
- B) The NT Headers
- C) The Section Headers
- D) The entry point

**8. Which architecture does ELF support?**
- A) x86 only
- B) ARM only
- C) x86, x64, ARM, and more
- D) Only 64-bit

**9. What is the entry point?**
- A) The start of the file
- B) The start of program execution
- C) The end of the file
- D) The data section

**10. What is the Image Base?**
- A) The entry point address
- B) The preferred load address
- C) The image size
- D) The image checksum

---

### True/False (1 point each)

**11.** Ghidra can analyze both PE and ELF files.  
☐ True ☐ False

**12.** The JDK is optional for running Ghidra.  
☐ True ☐ False

**13.** ELF is the executable format used by Linux.  
☐ True ☐ False

**14.** A Ghidra project can contain multiple binaries.  
☐ True ☐ False

**15.** The entry point address is the same for all binaries.  
☐ True ☐ False

---

### Matching (1 point each)

**Match the file format to its description:**

| Format | Description |
|--------|-------------|
| 16. PE | A. Linux executable format |
| 17. ELF | B. Windows executable format |
| 18. Mach-O | C. macOS executable format |
| 19. COFF | D. Common Object File Format |
| 20. EXE | E. Common name for PE executable |

---

### Short Answer (3 points each)

**21.** Explain the steps required to install Ghidra on a Windows system.

**22.** What is the difference between a JDK and a JRE, and why is the JDK required for Ghidra?

**23.** Describe the structure of an ELF file.

**24.** What is the purpose of the `-Xmx` parameter and how do you configure it?

**25.** Why is it important to understand executable file formats in reverse engineering?

---

## Module 2 Test: Ghidra Interface and Navigation

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. Which window shows the decompiled code?**
- A) Listing Window
- B) Decompiler Window
- C) Symbol Tree
- D) Program Trees

**2. What color represents functions in the Listing Window?**
- A) Black
- B) Blue
- C) Red
- D) Green

**3. Which shortcut is used to rename a symbol?**
- A) `R`
- B) `N`
- C) `G`
- D) `X`

**4. What does the Symbol Tree display?**
- A) File structure
- B) Data types
- C) Functions and labels
- D) Memory blocks

**5. Which window shows the file structure of the binary?**
- A) Listing Window
- B) Decompiler Window
- C) Symbol Tree
- D) Program Trees

**6. What is the shortcut to show cross-references?**
- A) `R`
- B) `N`
- C) `G`
- D) `X`

**7. What does the Function Graph show?**
- A) Function call hierarchy
- B) Visual control flow
- C) Data types
- D) Memory layout

**8. Which shortcut is used to add a comment?**
- A) `;`
- B) `:`
- C) `#`
- D) `//`

**9. What is the purpose of a bookmark?**
- A) To mark important locations
- B) To rename symbols
- C) To add comments
- D) To run scripts

**10. Which shortcut toggles focus between Listing and Decompiler?**
- A) `F5`
- B) `F10`
- C) `F11`
- D) `F12`

---

### True/False (1 point each)

**11.** The Decompiler Window shows assembly code.  
☐ True ☐ False

**12.** `Ctrl+F` is used to search within the current window.  
☐ True ☐ False

**13.** The Symbol Tree only shows user-defined functions.  
☐ True ☐ False

**14.** Program Trees show the PE/ELF structure.  
☐ True ☐ False

**15.** `Alt+Left` navigates backward in the history.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** Describe the Layout of the Listing Window and what each part displays.

**17.** What information can be found in the Symbol Tree?

**18.** How do you find a specific function by name?

**19.** What is the Function Graph and how is it used?

**20.** List and describe three important navigation shortcuts in Ghidra.

---

## Module 3 Test: First Binary Analysis

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. What is the first step after importing a binary into Ghidra?**
- A) Rename variables
- B) Run analysis
- C) Add comments
- D) Export the binary

**2. What generic name does the decompiler use for variables?**
- A) `var1`
- B) `local_x`
- C) `iVar1`
- D) `param_x`

**3. What is the purpose of renaming variables?**
- A) To change the binary
- B) To improve readability
- C) To fix bugs
- D) To add new functionality

**4. How do you set a data type in Ghidra?**
- A) Right-click → Set Data Type
- B) Double-click the variable
- C) Press `T`
- D) Use the Symbol Tree

**5. What is the vulnerability in the calculator program?**
- A) Integer overflow
- B) Format string vulnerability
- C) Buffer overflow in strcpy
- D) Use-after-free

**6. What does the `validate_access` function do?**
- A) Adds two numbers
- B) Validates a key using XOR
- C) Multiplies two numbers
- D) Compares two strings

**7. What is the valid key for `validate_access`?**
- A) 0x1A
- B) 0x40
- C) 0x5A
- D) 0x10

**8. What is the secret message in the calculator program?**
- A) "SECRET"
- B) "ACCESS"
- C) "RE_MASTER"
- D) "FLAG"

**9. What is the purpose of adding comments?**
- A) To change the binary
- B) To document findings
- C) To fix bugs
- D) To add new functionality

**10. What is the benefit of setting correct data types?**
- A) The decompiler shows better code
- B) The binary runs faster
- C) The file size is reduced
- D) The entry point changes

---

### True/False (1 point each)

**11.** The `validate_access` function is called from `main`.  
☐ True ☐ False

**12.** `strcpy` is a safe function to use.  
☐ True ☐ False

**13.** Renaming variables changes the actual binary file.  
☐ True ☐ False

**14.** Comments are visible to other analysts.  
☐ True ☐ False

**15.** The decompiler always shows the original source code.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** Explain the steps to analyze the `main` function in the calculator program.

**17.** What is the vulnerability in `validate_access` and how could it be exploited?

**18.** How does the XOR validation logic work in `validate_access`?

**19.** Why is it important to rename variables and add comments during analysis?

**20.** What is the difference between `strcpy` and `strncpy` and why does it matter?

---

## Module 4 Test: Ghidra Scripting Basics

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. Which language is most commonly used for Ghidra scripting?**
- A) Python
- B) Java
- C) JavaScript
- D) C++

**2. What object represents the current program?**
- A) `program`
- B) `currentProgram`
- C) `binary`
- D) `executable`

**3. How do you get all functions in a program?**
- A) `currentProgram.getFunctions()`
- B) `currentProgram.getFunctionManager().getFunctions(True)`
- C) `currentProgram.getAllFunctions()`
- D) `currentProgram.functions`

**4. What does `getBytes(addr, length)` do?**
- A) Reads bytes from memory
- B) Writes bytes to memory
- C) Deletes bytes from memory
- D) Copies bytes to memory

**5. What is the Script Manager used for?**
- A) Creating and running scripts
- B) Debugging binaries
- C) Analyzing malware
- D) Patching binaries

**6. How do you handle memory access errors?**
- A) Ignore them
- B) Use try/except
- C) Use if statements
- D) Use while loops

**7. What is the purpose of `setByte()`?**
- A) To read a byte
- B) To write a byte
- C) To delete a byte
- D) To copy a byte

**8. How do you run a script?**
- A) Click "Run" in Script Manager
- B) Press `Ctrl+R`
- C) Double-click the script
- D) All of the above

**9. What is a common use of Ghidra scripting?**
- A) Renaming functions
- B) Extracting strings
- C) Generating reports
- D) All of the above

**10. What should you check before reading memory?**
- A) The file size
- B) The address is valid
- C) The script name
- D) The Java version

---

### True/False (1 point each)

**11.** Scripts can be written in multiple languages in Ghidra.  
☐ True ☐ False

**12.** `currentProgram` is always available in a script.  
☐ True ☐ False

**13.** Error handling is optional in scripts.  
☐ True ☐ False

**14.** The Script Manager can be opened with `Ctrl+Shift+P`.  
☐ True ☐ False

**15.** `setBytes()` can write multiple bytes at once.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** Write a script that enumerates all functions in the current program.

**17.** Explain the difference between `getBytes()` and `getByte()`.

**18.** What are the steps to create and run a new script?

**19.** How do you handle a `MemoryAccessException`?

**20.** Write a script that extracts all strings longer than 4 characters.

---

## Module 5 Test: Control Flow Analysis

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. What is a basic block?**
- A) A sequence of code with one entry, one exit
- B) The smallest unit of code
- C) A single instruction
- D) A function

**2. Which jump instruction means "jump if not equal"?**
- A) `JE`
- B) `JNE`
- C) `JG`
- D) `JL`

**3. What is the difference between `JG` and `JA`?**
- A) `JG` is signed, `JA` is unsigned
- B) `JA` is signed, `JG` is unsigned
- C) They are the same
- D) `JG` is for jumps, `JA` is for calls

**4. What does the Function Graph show?**
- A) Visual control flow
- B) Memory layout
- C) Function parameters
- D) Data types

**5. What is a conditional branch?**
- A) An unconditional jump
- B) A jump that depends on a condition
- C) A function call
- D) A return instruction

**6. What is the purpose of the `cmp` instruction?**
- A) To compare two values
- B) To copy a value
- C) To jump to a location
- D) To call a function

**7. How does a `for` loop differ from a `while` loop in assembly?**
- A) `for` loops have initialization and increment
- B) `while` loops have initialization and increment
- C) They are exactly the same
- D) `for` loops are not used

**8. What is a loop in assembly?**
- A) A series of jumps- B) A backward jump
- C) A forward jump
- D) A call instruction

**9. What does the Function Graph color green represent?**
- A) Entry point
- B) Exit point
- C) Data reference
- D) Function call

**10. What does the Function Graph color red represent?**
- A) Entry point
- B) Exit point
- C) Data reference
- D) Function call

---

### True/False (1 point each)

**11.** A basic block can have multiple exit points.  
☐ True ☐ False

**12.** `JNE` and `JNZ` are the same instruction.  
☐ True ☐ False

**13.** The Function Graph is only available for functions.  
☐ True ☐ False

**14.** Loops are identified by backward jumps.  
☐ True ☐ False

**15.** `CMP` sets the flags for conditional jumps.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** Describe the structure of a basic block.

**17.** Explain the difference between a conditional and unconditional jump.

**18.** How can you identify a loop in assembly code?

**19.** What is the difference between a `for` loop and a `while` loop in assembly?

**20.** How does the Function Graph help in reverse engineering?

---

## Module 6 Test: Cross-References (XREFs)

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. What does XREF stand for?**
- A) Execute Reference
- B) External Reference
- C) Cross-Reference
- D) Code Reference

**2. How do you show cross-references?**
- A) Right-click → Show Cross-References
- B) Press `X`
- C) Both A and B
- D) Neither

**3. What are incoming references?**
- A) References to a location
- B) References from a location
- C) References to other files
- D) References to system libraries

**4. What are outgoing references?**
- A) References to a location
- B) References from a location
- C) References to other files
- D) References to system libraries

**5. What type of reference is a function call?**
- A) Data reference
- B) Code reference
- C) External reference
- D) Internal reference

**6. What is a data reference?**
- A) A reference to a function
- B) A reference to a string or variable
- C) A reference to a system library
- D) A reference to a file

**7. What is the Defined Strings window?**
- A) A list of all strings in the binary
- B) A list of all functions
- C) A list of all variables
- D) A list of all imports

**8. How do you trace a string to its usage?**
- A) Double-click and press `X`
- B) Right-click and select "Follow"
- C) Press `F` and type the string
- D) Use the Listing Window

**9. What is the purpose of XREFs?**
- A) To find relationships between code and data
- B) To rename functions
- C) To add comments
- D) To set bookmarks

**10. What does an XREF from a string show?**
- A) Where the string is used
- B) Where the string is stored
- C) The length of the string
- D) The type of the string

---

### True/False (1 point each)

**11.** XREFs only show code references.  
☐ True ☐ False

**12.** The `X` shortcut shows cross-references.  
☐ True ☐ False

**13.** Defined Strings shows all strings in the binary.  
☐ True ☐ False

**14.** Data references point to strings and variables.  
☐ True ☐ False

**15.** Incoming references show what a function calls.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** Explain how to find who calls a specific function.

**17.** What is the difference between incoming and outgoing references?

**18.** How can XREFs help in understanding program behavior?

**19.** How do you find all uses of a string?

**20.** What is the purpose of the Defined Strings window in malware analysis?

---

## Module 7 Test: XOR Decryption

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. What does XOR stand for?**
- A) Exclusive OR
- B) Extended Operation Register
- C) Execute Output Read
- D) Extended Output Range

**2. Which of the following is a property of XOR?**
- A) A XOR B = B XOR A
- B) (A XOR B) XOR B = A
- C) A XOR 0 = A
- D) All of the above

**3. If encrypted data is XORed with the same key, what do you get?**
- A) The original plaintext
- B) Different ciphertext
- C) The key
- D) Nothing

**4. Which instruction performs XOR in x86 assembly?**
- A) `AND`
- B) `OR`
- C) `XOR`
- D) `NOT`

**5. In the validate_access function, what is the XOR key?**
- A) 0x1A
- B) 0x40
- C) 0x5A
- D) 0x10

**6. What is the valid key for validate_access?**
- A) 0x1A
- B) 0x40
- C) 0x5A
- D) 0x10

**7. What is the secret message in validate_access?**
- A) "SECRET"
- B) "ACCESS"
- C) "RE_MASTER"
- D) "FLAG"

**8. How do you decrypt XOR-encrypted data?**
- A) XOR it with the same key
- B) ADD the key
- C) SUBTRACT the key
- D) AND the key

**9. What is the formula to find the key?**
- A) Key = Plaintext ^ Ciphertext
- B) Key = Plaintext + Ciphertext
- C) Key = Plaintext - Ciphertext
- D) Key = Plaintext * Ciphertext

**10. Why is XOR commonly used in reverse engineering?**
- A) It's simple and fast
- B) It's complex
- C) It's insecure
- D) It's difficult to reverse

---

### True/False (1 point each)

**11.** XOR encryption is symmetric.  
☐ True ☐ False

**12.** The XOR key can only be a single byte.  
☐ True ☐ False

**13.** XOR is commonly used for obfuscation in CTF challenges.  
☐ True ☐ False

**14.** XOR can be used for both encryption and decryption.  
☐ True ☐ False

**15.** If you know the plaintext and ciphertext, you can find the key.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** Explain the XOR operation and its properties.

**17.** Given `Encrypted = 0x3B 0x52 0x4D 0x52` and key `0x5A`, what is the plaintext?

**18.** If `Plaintext ^ Key = Ciphertext`, what is the formula to find `Key`?

**19.** How can you identify an XOR encryption routine in disassembly?

**20.** What is the valid key for `validate_access` and why?

---

## Module 8 Test: Binary Patching

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. What is binary patching?**
- A) Modifying the source code
- B) Modifying the compiled binary
- C) Creating a new binary
- D) Decompiling the binary

**2. Which instruction is a NOP?**
- A) `JMP`
- B) `RET`
- C) `NOP`
- D) `CALL`

**3. What does NOP stand for?**
- A) No Operation
- B) New Operation
- C) Negative Operation
- D) Null Operation

**4. What is the hex value for a NOP instruction?**
- A) 0x00
- B) 0x01
- C) 0x90
- D) 0xFF

**5. Which method is used for patching in Ghidra?**
- A) Patch Instruction
- B) Patch Bytes
- C) Patch Script
- D) All of the above

**6. How do you bypass a conditional jump?**
- A) Change it to `JMP`
- B) Change it to `NOP`
- C) Change the comparison
- D) All of the above

**7. What is the purpose of exporting a patched binary?**
- A) To save the changes
- B) To analyze further
- C) To debug
- D) To share with others

**8. What is a common use of binary patching?**
- A) Bypassing authentication
- B) Fixing bugs
- C) Removing features
- D) All of the above

**9. What should you consider before patching?**
- A) The impact on the program
- B) The length of the instruction
- C) The permissions
- D) All of the above

**10. How do you patch in Ghidra?**
- A) Right-click → Patch Instruction
- B) Right-click → Patch Bytes
- C) Using a script
- D) All of the above

---

### True/False (1 point each)

**11.** Patching changes the original binary file.  
☐ True ☐ False

**12.** You can export a patched binary from Ghidra.  
☐ True ☐ False

**13.** `JNE` can be changed to `JMP` to always take a branch.  
☐ True ☐ False

**14.** NOP instructions can be used to remove function calls.  
☐ True ☐ False

**15.** Patching is only used for bypassing authentication.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** Explain the process of patching an instruction in Ghidra.

**17.** How would you bypass a conditional jump?

**18.** What is the purpose of NOP instructions in patching?

**19.** What are the risks of binary patching?

**20.** Write a script that patches the `validate_access` function to always grant access.

---

## Module 9 Test: Malware Analysis

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. What does IOC stand for?**
- A) Internal Operation Code
- B) Indicator of Compromise
- C) Instruction Operation Control
- D) Input Output Command

**2. Which is NOT a type of IOC?**
- A) Domain
- B) IP Address
- C) File Path
- D) Variable Name

**3. What does C2 stand for?**
- A) Control Channel
- B) Command and Control
- C) Code to Code
- D) Call and Connect

**4. What is YARA used for?**
- A) Debugging
- B) Binary patching
- C) Malware detection
- D) Decompilation

**5. Which API is commonly used for process injection?**
- A) `CreateFile`
- B) `VirtualAllocEx`
- C) `RegOpenKeyEx`
- D) `socket`

**6. What is a packed binary?**
- A) A compressed binary
- B) A binary with debug symbols
- C) A binary with no code
- D) A binary with multiple entry points

**7. What is persistence in malware?**
- A) The malware survives reboot
- B) The malware runs once
- C) The malware deletes itself
- D) The malware is encrypted

**8. What is anti-analysis in malware?**
- A) Techniques to evade analysis
- B) Techniques to run faster
- C) Techniques to encrypt data
- D) Techniques to delete files

**9. What is static analysis?**
- A) Analyzing without executing
- B) Analyzing during execution
- C) Analyzing network traffic
- D) Analyzing memory dumps

**10. What is dynamic analysis?**
- A) Analyzing without executing
- B) Analyzing during execution
- C) Analyzing file headers
- D) Analyzing strings

---

### True/False (1 point each)

**11.** Packed malware has high entropy.  
☐ True ☐ False

**12.** YARA rules can only detect strings.  
☐ True ☐ False

**13.** Static analysis involves executing the malware.  
☐ True ☐ False

**14.** The `.text` section typically contains executable code.  
☐ True ☐ False

**15.** `IsDebuggerPresent` is an anti-analysis technique.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** What is static malware triage and what steps are involved?

**17.** What are the indicators of a packed binary?

**18.** What is a YARA rule and how is it used?

**19.** What is Command and Control (C2) in malware?

**20.** Explain the difference between static and dynamic analysis in malware analysis.

---

## Module 10 Test: Vulnerability Research

**Duration:** 30 minutes
**Total Points:** 50

---

### Multiple Choice (2 points each)

**1. What is a stack buffer overflow?**
- A) Writing beyond the stack buffer
- B) Writing beyond the heap buffer
- C) Overflowing the CPU cache
- D) Overflowing the disk buffer

**2. Which function is considered unsafe?**
- A) `strncpy`
- B) `strcpy`
- C) `strlen`
- D) `strcmp`

**3. What is a format string vulnerability?**
- A) User input as a format string
- B) User input as a number
- C) User input as a string
- D) User input as a character

**4. What is a sink in data flow analysis?**
- A) Where input enters
- B) Where dangerous function is called
- C) Where data is validated
- D) Where data is stored

**5. What is a source in data flow analysis?**
- A) Where input enters
- B) Where dangerous function is called
- C) Where data is validated
- D) Where data is stored

**6. What is integer overflow?**
- A) When a value exceeds its maximum
- B) When a value is zero
- C) When a value is negative
- D) When a value is divided

**7. What is use-after-free?**
- A) Accessing freed memory
- B) Freeing memory twice
- C) Allocating memory twice
- D) Not freeing memory

**8. What is a stack canary?**
- A) A security feature to detect overflows
- B) A debugging tool
- C) A compiler flag
- D) A type of exploit

**9. What does DEP stand for?**
- A) Data Execution Prevention
- B) Data Encryption Protocol
- C) Dynamic Execution Protection
- D) Direct Execution Permission

**10. What is the purpose of ASLR?**
- A) To randomize memory addresses
- B) To encrypt memory
- C) To compress memory
- D) To protect memory

---

### True/False (1 point each)

**11.** `sprintf` is a safe function.  
☐ True ☐ False

**12.** Stack canaries detect buffer overflows.  
☐ True ☐ False

**13.** User input always reaches a sink.  
☐ True ☐ False

**14.** Integer overflow is a type of vulnerability.  
☐ True ☐ False

**15.** Use-After-Free occurs when accessing freed memory.  
☐ True ☐ False

---

### Short Answer (3 points each)

**16.** What is the difference between a stack and heap overflow?

**17.** How can you detect unsafe function calls in a binary?

**18.** What is data flow analysis and why is it important?

**19.** What is a use-after-free vulnerability and how can it be exploited?

**20.** How can integer overflows be exploited and how are they prevented?

---

# Section 3: Comprehensive Exams

---

## Midterm Examination

**Duration:** 2 hours
**Total Points:** 100

---

### Part I: Multiple Choice (2 points each - 20 questions)

**1. Which version of Java is required for Ghidra?**
- A) Java 8
- B) Java 11
- C) Java 17
- D) Java 21

**2. What is the purpose of the `JAVA_HOME` environment variable?**
- A) To set the default Java version
- B) To point to the Java installation directory
- C) To configure Java memory settings
- D) To specify the Java classpath

**3. Which executable format is used by Linux?**
- A) ELF
- B) PE
- C) Mach-O
- D) COFF

**4. What does `-Xmx` control?**
- A) Maximum heap size
- B) Minimum heap size
- C) Java version
- D) Garbage collection

**5. Which window shows the decompiled code?**
- A) Listing Window
- B) Decompiler Window
- C) Symbol Tree
- D) Program Trees

**6. What shortcut is used to go to a specific address?**
- A) `Ctrl+F`
- B) `G`
- C) `F`
- D) `X`

**7. What color represents functions in the Listing Window?**
- A) Black
- B) Blue
- C) Red
- D) Green

**8. What is a basic block?**
- A) A sequence of code with one entry, one exit
- B) The smallest unit of code
- C) A single instruction
- D) A function

**9. Which jump instruction means "jump if not equal"?**
- A) `JE`
- B) `JNE`
- C) `JG`
- D) `JL`

**10. What is an incoming reference?**
- A) A reference to a location
- B) A reference from a location
- C) A reference to a file
- D) A reference to a system library

**11. What is a property of XOR?**
- A) A XOR B = B XOR A
- B) (A XOR B) XOR B = A
- C) A XOR 0 = A
- D) All of the above

**12. What is binary patching?**
- A) Modifying the source code
- B) Modifying the compiled binary
- C) Creating a new binary
- D) Decompiling the binary

**13. What does NOP stand for?**
- A) No Operation
- B) New Operation
- C) Negative Operation
- D) Null Operation

**14. What does IOC stand for?**
- A) Internal Operation Code
- B) Indicator of Compromise
- C) Instruction Operation Control
- D) Input Output Command

**15. Which API is commonly used for process injection?**
- A) `CreateFile`
- B) `VirtualAllocEx`
- C) `RegOpenKeyEx`
- D) `socket`

**16. What is a stack buffer overflow?**
- A) Writing beyond the stack buffer
- B) Writing beyond the heap buffer
- C) Overflowing the CPU cache
- D) Overflowing the disk buffer

**17. Which function is considered unsafe?**
- A) `strncpy`
- B) `strcpy`
- C) `strlen`
- D) `strcmp`

**18. What is the purpose of YARA?**
- A) Debugging
- B) Binary patching
- C) Malware detection
- D) Decompilation

**19. What is the purpose of the Symbol Tree?**
- A) Showing functions and labels
- B) Showing file structure
- C) Showing decompiled code
- D) Showing memory blocks

**20. What is the valid key for `validate_access`?**
- A) 0x1A
- B) 0x40
- C) 0x5A
- D) 0x10

---

### Part II: True/False (1 point each - 20 questions)

**21.** Ghidra can analyze both PE and ELF files.  
☐ True ☐ False

**22.** The JDK is optional for running Ghidra.  
☐ True ☐ False

**23.** The Decompiler Window shows assembly code.  
☐ True ☐ False

**24.** The `X` shortcut shows cross-references.  
☐ True ☐ False

**25.** A basic block can have multiple entry points.  
☐ True ☐ False

**26.** `JNE` and `JNZ` are the same instruction.  
☐ True ☐ False

**27.** XOR encryption is symmetric.  
☐ True ☐ False

**28.** Patching changes the original binary file.  
☐ True ☐ False

**29.** Packed malware has high entropy.  
☐ True ☐ False

**30.** YARA rules can only detect strings.  
☐ True ☐ False

**31.** Static analysis involves executing the malware.  
☐ True ☐ False

**32.** `sprintf` is a safe function.  
☐ True ☐ False

**33.** Stack canaries detect buffer overflows.  
☐ True ☐ False

**34.** The Symbol Tree shows imported functions.  
☐ True ☐ False

**35.** Program Trees show the file structure.  
☐ True ☐ False

**36.** The Function Graph shows memory layout.  
☐ True ☐ False

**37.** Data references point to strings and variables.  
☐ True ☐ False

**38.** The XOR key can only be a single byte.  
☐ True ☐ False

**39.** NOP instructions can be used to remove function calls.  
☐ True ☐ False

**40.** Use-After-Free occurs when accessing freed memory.  
☐ True ☐ False

---

### Part III: Short Answer (2 points each - 10 questions)

**41.** What are the steps to install Ghidra?

**42.** Describe the Layout of the Listing Window.

**43.** What is the vulnerability in `validate_access` and why?

**44.** Explain the XOR validation logic in `validate_access`.

**45.** Write a script to enumerate all functions.

**46.** What is the difference between `JG` and `JA`?

**47.** How do you trace a string to its usage?

**48.** What is the valid key for `validate_access` and why?

**49.** What are the indicators of a packed binary?

**50.** What is the difference between a stack and heap overflow?

---

### Part IV: Practical (10 points)

**51.** Given the following assembly code, identify the conditional branch, determine the condition, and explain what the code does.

```assembly
cmp eax, 0x10
jg label_greater
mov ebx, 0
jmp label_end
label_greater:
mov ebx, 1
label_end:
mov eax, ebx
ret
```

---

## Final Examination

**Duration:** 3 hours
**Total Points:** 150

---

### Part I: Multiple Choice (2 points each - 25 questions)

**1. What is required to run Ghidra?**
- A) JRE 8
- B) JDK 11
- C) JDK 17
- D) JRE 17

**2. Which executable format is used by Windows?**
- A) ELF
- B) PE
- C) Mach-O
- D) COFF

**3. Where does Ghidra store its configuration?**
- A) Installation directory
- B) User home directory (.ghidra)
- C) Windows registry
- D) System temp folder

**4. What is the purpose of the `-Xmx` parameter?**
- A) To enable debugging
- B) To set maximum memory
- C) To specify Java version
- D) To configure network

**5. Which window shows the disassembled code?**
- A) Decompiler Window
- B) Listing Window
- C) Symbol Tree
- D) Program Trees

**6. What shortcut is used to show cross-references?**
- A) `R`
- B) `N`
- C) `G`
- D) `X`

**7. What does the Decompiler Window show?**
- A) Machine code bytes
- B) Assembly instructions
- C) C-like code
- D) File structure

**8. What is a basic block?**
- A) Code with one entry, one exit
- B) A single instruction
- C) A function
- D) A file

**9. Which jump instruction means "jump if less than"?**
- A) `JG`
- B) `JL`
- C) `JA`
- D) `JB`

**10. What are outgoing references?**
- A) References to a location
- B) References from a location
- C) References to files
- D) References to libraries

**11. What is a property of XOR?**
- A) A XOR B = B XOR A
- B) (A XOR B) XOR B = A
- C) A XOR 0 = A
- D) All of the above

**12. What is the hex value for a NOP instruction?**
- A) 0x00
- B) 0x01
- C) 0x90
- D) 0xFF

**13. What does C2 stand for?**
- A) Control Channel
- B) Command and Control
- C) Code to Code
- D) Call and Connect

**14. What is YARA used for?**
- A) Debugging
- B) Binary patching
- C) Malware detection
- D) Decompilation

**15. What is a format string vulnerability?**
- A) User input as a format string
- B) User input as a number
- C) User input as a string
- D) User input as a character

**16. What is a sink in data flow analysis?**
- A) Where input enters
- B) Where dangerous function is called
- C) Where data is validated
- D) Where data is stored

**17. What is the secret message in the calculator program?**
- A) "SECRET"
- B) "ACCESS"
- C) "RE_MASTER"
- D) "FLAG"

**18. Which method is used for patching in Ghidra?**
- A) Patch Instruction
- B) Patch Bytes
- C) Patch Script
- D) All of the above

**19. What is the purpose of the Symbol Tree?**
- A) Showing functions and labels
- B) Showing file structure
- C) Showing decompiled code
- D) Showing memory blocks

**20. What does the Function Graph show?**
- A) Visual control flow
- B) Memory layout
- C) Function parameters
- D) Data types

**21. What is the valid key for `validate_access`?**
- A) 0x1A
- B) 0x40
- C) 0x5A
- D) 0x10

**22. What is the purpose of ASLR?**
- A) To randomize memory addresses
- B) To encrypt memory
- C) To compress memory
- D) To protect memory

**23. What is the difference between `JG` and `JA`?**
- A) `JG` is signed, `JA` is unsigned
- B) `JA` is signed, `JG` is unsigned
- C) They are the same
- D) `JG` is for jumps, `JA` is for calls

**24. What is use-after-free?**
- A) Accessing freed memory
- B) Freeing memory twice
- C) Allocating memory twice
- D) Not freeing memory

**25. What does NOP stand for?**
- A) No Operation
- B) New Operation
- C) Negative Operation
- D) Null Operation

---

### Part II: True/False (1 point each - 25 questions)

**26.** Ghidra can analyze both PE and ELF files.  
☐ True ☐ False

**27.** The Decompiler Window shows assembly code.  
☐ True ☐ False

**28.** `Ctrl+F` is used to search within the current window.  
☐ True ☐ False

**29.** A basic block can have multiple exit points.  
☐ True ☐ False

**30.** `JNE` and `JNZ` are the same instruction.  
☐ True ☐ False

**31.** XOR encryption is symmetric.  
☐ True ☐ False

**32.** Patching changes the original binary file.  
☐ True ☐ False

**33.** Packed malware has high entropy.  
☐ True ☐ False

**34.** Static analysis involves executing the malware.  
☐ True ☐ False

**35.** `sprintf` is a safe function.  
☐ True ☐ False

**36.** Stack canaries detect buffer overflows.  
☐ True ☐ False

**37.** The Symbol Tree shows imported functions.  
☐ True ☐ False

**38.** Program Trees show the file structure.  
☐ True ☐ False

**39.** The Function Graph shows memory layout.  
☐ True ☐ False

**40.** Data references point to strings and variables.  
☐ True ☐ False

**41.** The XOR key can only be a single byte.  
☐ True ☐ False

**42.** NOP instructions can be used to remove function calls.  
☐ True ☐ False

**43.** Use-After-Free occurs when accessing freed memory.  
☐ True ☐ False

**44.** The `.text` section contains executable code.  
☐ True ☐ False

**45.** `IsDebuggerPresent` is an anti-analysis technique.  
☐ True ☐ False

**46.** Integer overflow is a type of vulnerability.  
☐ True ☐ False

**47.** The Script Manager can be opened with `Ctrl+Shift+P`.  
☐ True ☐ False

**48.** Renaming variables changes the actual binary file.  
☐ True ☐ False

**49.** The entry point is where program execution starts.  
☐ True ☐ False

**50.** `strcpy` is a safe function to use.  
☐ True ☐ False

---

### Part III: Short Answer (3 points each - 10 questions)

**51.** Explain the structure of a PE file.

**52.** Describe the difference between the Listing Window and the Decompiler Window.

**53.** Explain the vulnerability in the calculator program and how it can be fixed.

**54.** Write a script that extracts all strings from a binary.

**55.** Explain the differences between `for`, `while`, and `do-while` loops in assembly.

**56.** How can you use XREFs to find hidden functionality?

**57.** Explain the XOR operation and its properties.

**58.** What are the steps to bypass an authentication check in a binary?

**59.** What are the indicators of malware and how do you extract them?

**60.** Explain the differences between stack and heap overflows.

---

### Part IV: Practical (25 points)

**61.** Given the following binary analysis scenario:

You have imported a binary into Ghidra and found the following function:

```c
void process_input(char* input) {
    char buffer[64];
    int authenticated = 0;
    
    strcpy(buffer, input);
    
    if (authenticated != 0) {
        printf("Access granted!\n");
    } else {
        printf("Access denied!\n");
    }
}
```

**a)** What is the vulnerability in this code? (5 points)

**b)** How could it be exploited? (5 points)

**c)** What is the offset to the return address? (5 points)

**d)** How would you patch the binary to bypass authentication? (5 points)

**e)** How would you fix the vulnerability in the source code? (5 points)

---

## Practical Skills Assessment

**Duration:** 2 hours
**Total Points:** 100

---

### Task 1: Binary Analysis (40 points)

You are given a binary file called `challenge.bin`. Perform a complete analysis:

**1. Triage (10 points)**
- What is the file type?
- What is the file size?
- Is it packed?
- What interesting strings did you find?

**2. Ghidra Analysis (15 points)**
- Where is the main function?
- What is the purpose of the program?
- What functions are present?
- What is the hidden functionality?

**3. IOC Extraction (10 points)**
- Extract all IOCs
- Categorize them
- Document your findings

**4. Report (5 points)**
- Write a brief report summarizing your findings

---

### Task 2: Scripting (30 points)

**1. Function Enumerator (10 points)**
Write a script that enumerates all functions in the current program and prints their names and entry points.

**2. Vulnerability Scanner (10 points)**
Write a script that detects dangerous function calls (strcpy, sprintf, gets) in the current program.

**3. XOR Decryptor (10 points)**
Write a script that decrypts XOR-encrypted data found at a specific address.

---

### Task 3: Patching (20 points)

**1. Bypass Authentication (10 points)**
Patch the binary to bypass authentication.

**2. Export Patched Binary (10 points)**
Export the patched binary and verify it works.

---

### Task 4: Report (10 points)

Write a comprehensive report covering:
- Analysis methodology
- Findings
- IOCs
- Patches applied
- Recommendations

---

# Section 4: Answer Keys

---

## Module Quiz Answer Keys

### Module 1 Quiz Answers

**Multiple Choice:**
1. C (Java 17)
2. B (JDK includes development tools, JRE only runs programs)
3. D (EXE is not a format, it's an extension)
4. B (In the user's home directory - .ghidra)
5. B (To set the maximum memory allocation)

**True/False:**
6. False (Ghidra can analyze multiple formats)
7. True
8. True
9. False (Projects can contain multiple binaries)
10. True

**Short Answer:**
11. Portable Executable
12. ELF (Executable and Linkable Format)
13. `java -version` and `javac -version`
14. In the DOS Header
15. The preferred load address of the binary

---

### Module 2 Quiz Answers

**Multiple Choice:**
1. B (Listing Window)
2. B (G)
3. B (Blue)
4. C (C-like code)
5. C (Symbol Tree)

**True/False:**
6. False (It shows C-like code)
7. True
8. True
9. True
10. True

**Matching:**
11. C (X → Show cross-references)
12. A (N → Rename symbol)
13. B (; → Add comment)
14. D (B → Set bookmark)
15. E (Ctrl+E → Show decompiler)

**Short Answer:**
16. Shows the file structure of the binary (PE/ELF headers, sections)
17. Press `F` and type the function name
18. Red (data references)
19. Visual control flow of a function
20. Marks important locations for later reference

---

### Module 3 Quiz Answers

**Multiple Choice:**
1. B (Run analysis)
2. C (Decompiler-generated names)
3. B (Right-click → Rename Variable)
4. A (To make the decompiler more accurate)
5. C (validate_access)

**True/False:**
6. False (It may have different names in some binaries)
7. False (Comments are saved in the project)
8. True
9. True (strcpy vulnerability)
10. False (Only changes the analysis, not the file)

**Short Answer:**
11. strcpy without bounds checking; allows buffer overflow
12. key ^ 0x5A == 0x40; valid key is 0x5A
13. Makes the code more readable and understandable
14. strcpy doesn't check bounds; strncpy does with a length parameter
15. Shows high-level logic instead of low-level assembly

---

### Module 4 Quiz Answers

**Multiple Choice:**
1. B (Python)
2. A (currentProgram)
3. B (currentProgram.getFunctionManager().getFunctions(True))
4. B (getBytes())
5. A (Click "Run" in the Script Manager)

**True/False:**
6. False (Python, Java, JavaScript are supported)
7. True
8. True
9. False (Error handling is important)
10. True

**Fill in the Blank:**
11. Ctrl+Shift+P
12. getFunctionCount()
13. Address
14. invalid/inaccessible
15. rename

---

### Module 5 Quiz Answers

**Multiple Choice:**
1. A (A sequence of code with one entry and one exit)
2. A (JMP)
3. B (Visual control flow)
4. B (JL)
5. A (JG is signed, JA is unsigned)

**True/False:**
6. False (One entry point)
7. False (Available for any function)
8. True
9. True
10. False (G opens Function Graph)

**Short Answer:**
11. For, while, do-while
12. cmp + conditional jump + jmp + label
13. For has init, condition, increment; while just has condition
14. Compare two values and set flags
15. Visualizes complex control flow

---

### Module 6 Quiz Answers

**Multiple Choice:**
1. C (Cross-Reference)
2. C (Both A and B)
3. A (References to a location)
4. B (Defined Strings)
5. B (Code reference)

**True/False:**
6. False (Data references too)
7. True
8. True
9. True
10. False (Incoming shows who calls the function)

**Short Answer:**
11. Navigate to function → Right-click → Show References to Function
12. Incoming = to a location, Outgoing = from a location
13. Find strings like "Access granted" and trace to validation
14. Shows all strings in the binary
15. Double-click string → Press X → View references

---

### Module 7 Quiz Answers

**Multiple Choice:**
1. A (Exclusive OR)
2. D (All of the above)
3. A (The original plaintext)
4. C (XOR)
5. C (0x5A)

**True/False:**
6. True
7. False (Can be multiple bytes)
8. True
9. True
10. True

**Short Answer:**
11. "KEY"
12. Key = Plaintext ^ Ciphertext
13. Simple, fast, symmetric, easy to implement
14. Look for XOR instruction with constants
15. 0x5A, because 0x5A ^ 0x1A = 0x40

---

### Module 8 Quiz Answers

**Multiple Choice:**
1. B (Modifying the compiled binary)
2. C (NOP)
3. A (No Operation)
4. C (0x90)
5. D (Memory Editor is not a patching method)

**True/False:**
6. True
7. True
8. True
9. True
10. False (Many other uses)

**Short Answer:**
11. Patch Instruction modifies the instruction directly; Patch Bytes modifies raw bytes
12. Change conditional jump to JMP or NOP
13. To save the changes to a new binary file
14. To replace instructions with no-ops to remove functionality
15. Can break the program or create unintended behavior

---

### Module 9 Quiz Answers

**Multiple Choice:**
1. B (Indicator of Compromise)
2. D (Variable Name)
3. B (Command and Control)
4. C (Malware detection)
5. B (VirtualAllocEx)

**True/False:**
6. True
7. False (Can detect hex patterns too)
8. False (Static analysis does not execute)
9. True
10. True

**Short Answer:**
11. Initial assessment of a suspicious binary without executing
12. High entropy, strange section names, small .text section, few imports
13. Detect malware using patterns
14. Malware survives reboot by installing itself
15. Detect and respond to malware infections

---

### Module 10 Quiz Answers

**Multiple Choice:**
1. A (Writing beyond the stack buffer)
2. B (strcpy)
3. A (User input as a format string)
4. B (Where dangerous function is called)
5. A (Where input enters)

**True/False:**
6. False (It is unsafe)
7. True
8. False (May not reach a sink)
9. True
10. True

**Short Answer:**
11. Stack overflow overwrites stack variables; heap overflow overwrites heap
12. Look for calls to functions like strcpy, sprintf, gets
13. Tracks user input through program to find vulnerabilities
14. Accessing memory after it has been freed
15. Causes allocation of too small buffers; prevented by bounds checking

---

## Module Test Answer Keys

### Module 1 Test Answers

**Multiple Choice:**
1. C (JDK 17)
2. B (Point to Java installation directory)
3. C (PE)
4. B (Maximum heap size)
5. B (User-specified directory)
6. C (ELF Header - that's Linux)
7. B (The NT Headers)
8. C (x86, x64, ARM, and more)
9. B (The start of program execution)
10. B (The preferred load address)

**True/False:**
11. True
12. False (JDK is required)
13. True
14. True
15. False (Different for each binary)

**Matching:**
16. B (PE - Windows)
17. A (ELF - Linux)
18. C (Mach-O - macOS)
19. D (COFF - Common Object File Format)
20. E (EXE - Common name for PE executable)

**Short Answer Answers:**

21. Install JDK 17, set JAVA_HOME, download Ghidra ZIP, extract, run ghidraRun.bat

22. JDK includes development tools (compiler, debugger); JRE only runs programs. Ghidra needs JDK to compile scripts.

23. ELF Header, Program Headers (segments), Sections, Section Headers

24. Controls maximum heap memory; edit launch script to add -Xmx4096m

25. Understanding how files are structured helps navigate analysis and identify anomalies

---

### Module 2 Test Answers

**Multiple Choice:**
1. B (Decompiler Window)
2. B (Blue)
3. B (N)
4. C (Functions and labels)
5. D (Program Trees)
6. D (X)
7. B (Visual control flow)
8. A (;)
9. A (To mark important locations)
10. C (F11)

**True/False:**
11. False (Shows C-like code)
12. True
13. False (Shows all functions)
14. True
15. True

**Short Answer Answers:**

16. Addresses on left, bytes, mnemonics, operands, comments

17. Functions (user and library), labels, imports, exports

18. Press F, type name, press Enter

19. Visual control flow of a function; helps understand complex logic

20. G (go to address), X (cross-references), N (rename)

---

### Module 3 Test Answers

**Multiple Choice:**
1. B (Run analysis)
2. C (iVar1)
3. B (To improve readability)
4. A (Right-click → Set Data Type)
5. C (Buffer overflow in strcpy)
6. B (Validates a key using XOR)
7. C (0x5A)
8. C ("RE_MASTER")
9. B (To document findings)
10. A (The decompiler shows better code)

**True/False:**
11. True
12. False (It's unsafe)
13. False (Only changes analysis)
14. True
15. False (Decompiler approximation)

**Short Answer Answers:**

16. Locate main, examine decompiled code, identify operations, trace execution

17. strcpy without bounds checking; overwrite buffer to change execution

18. XOR with 0x5A; if result is 0x40, access granted

19. Makes code readable, documents reasoning, helps others

20. strcpy doesn't check bounds; strncpy has length parameter

---

### Module 4 Test Answers

**Multiple Choice:**
1. A (Python)
2. B (currentProgram)
3. B (currentProgram.getFunctionManager().getFunctions(True))
4. A (Reads bytes from memory)
5. A (Creating and running scripts)
6. B (Use try/except)
7. B (To write a byte)
8. D (All of the above)
9. D (All of the above)
10. B (The address is valid)

**True/False:**
11. True
12. True
13. False (It's important)
14. True
15. True

**Short Answer Answers:**

16. 
```python
def main():
    func_manager = currentProgram.getFunctionManager()
    for func in func_manager.getFunctions(True):
        print(func.getName())
```

17. getBytes() reads multiple bytes; getByte() reads one byte

18. Window → Script Manager, click New Script, write code, click Run

19. Use try/except to catch MemoryAccessException

20. 
```python
def main():
    listing = currentProgram.getListing()
    data = listing.getDefinedData(True)
    while data.hasNext():
        d = data.next()
        try:
            value = str(d.getValue())
            if len(value) > 4:
                print(value)
        except:
            pass
```

---

### Module 5 Test Answers

**Multiple Choice:**
1. A (One entry, one exit)
2. B (JNE)
3. A (JG signed, JA unsigned)
4. A (Visual control flow)
5. B (Jump depends on condition)
6. A (Compare two values)
7. A (For has init, condition, increment)
8. B (Backward jump)
9. A (Entry point)
10. B (Exit point)

**True/False:**
11. False (One exit point)
12. True
13. True
14. True
15. True

**Short Answer Answers:**

16. Sequence of instructions with one entry point and one exit point

17. Conditional jump depends on flags; unconditional jump always taken

18. Backward jumps (jumps to lower addresses)

19. For has init, condition, increment; while just has condition

20. Visualizes control flow, helps understand complex code

---

### Module 6 Test Answers

**Multiple Choice:**
1. C (Cross-Reference)
2. C (Both A and B)
3. A (References to a location)
4. B (References from a location)
5. B (Code reference)
6. B (Reference to string or variable)
7. A (All strings in the binary)
8. A (Double-click and press X)
9. A (Find relationships between code and data)
10. A (Where the string is used)

**True/False:**
11. False (Data references too)
12. True
13. True
14. True
15. False (Incoming shows who calls the function)

**Short Answer Answers:**

16. Navigate to function → Right-click → Show References to Function

17. Incoming = to a location; Outgoing = from a location

18. Reveals relationships, shows callers and callees

19. Double-click string → Press X to see references

20. Quickly find suspicious strings like domains, URLs, registry keys

---

### Module 7 Test Answers

**Multiple Choice:**
1. A (Exclusive OR)
2. D (All of the above)
3. A (Original plaintext)
4. C (XOR)
5. C (0x5A)
6. C (0x5A)
7. C ("RE_MASTER")
8. A (XOR it with the same key)
9. A (Key = Plaintext ^ Ciphertext)
10. A (Simple and fast)

**True/False:**
11. True
12. False (Can be multiple bytes)
13. True
14. True
15. True

**Short Answer Answers:**

16. A XOR B = B XOR A, (A XOR B) XOR B = A, A XOR 0 = A

17. "KEY"

18. Key = Plaintext ^ Ciphertext

19. Look for XOR instruction with constants

20. 0x5A, because 0x5A ^ 0x1A = 0x40

---

### Module 8 Test Answers

**Multiple Choice:**
1. B (Modifying the compiled binary)
2. C (NOP)
3. A (No Operation)
4. C (0x90)
5. D (All of the above)
6. D (All of the above)
7. A (To save the changes)
8. D (All of the above)
9. D (All of the above)
10. D (All of the above)

**True/False:**
11. True
12. True
13. True
14. True
15. False (Many other uses)

**Short Answer Answers:**

16. Right-click instruction → Patch Instruction or Patch Bytes

17. Change conditional jump to JMP or NOP

18. To remove instructions without changing binary length

19. Can break the program or create unintended behavior

20. Script should find the conditional jump and replace with JMP

---

### Module 9 Test Answers

**Multiple Choice:**
1. B (Indicator of Compromise)
2. D (Variable Name)
3. B (Command and Control)
4. C (Malware detection)
5. B (VirtualAllocEx)
6. A (A compressed binary)
7. A (The malware survives reboot)
8. A (Techniques to evade analysis)
9. A (Analyzing without executing)
10. B (Analyzing during execution)

**True/False:**
11. True
12. False (Can detect hex patterns too)
13. False (Static analysis does not execute)
14. True
15. True

**Short Answer Answers:**

16. Initial assessment: file type, size, entropy, strings, imports

17. High entropy, strange section names, small .text section, few imports

18. Pattern-matching language for malware detection

19. Server that malware communicates with for commands

20. Static = without executing; Dynamic = during execution

---

### Module 10 Test Answers

**Multiple Choice:**
1. A (Writing beyond the stack buffer)
2. B (strcpy)
3. A (User input as a format string)
4. B (Where dangerous function is called)
5. A (Where input enters)
6. A (When a value exceeds its maximum)
7. A (Accessing freed memory)
8. A (A security feature to detect overflows)
9. A (Data Execution Prevention)
10. A (To randomize memory addresses)

**True/False:**
11. False (It's unsafe)
12. True
13. False (May not reach a sink)
14. True
15. True

**Short Answer Answers:**

16. Stack overflow overwrites stack variables; heap overflow overwrites heap memory

17. Look for calls to strcpy, sprintf, gets, etc.

18. Tracks user input through program to find vulnerabilities

19. Accessing freed memory; can be exploited for code execution

20. Causes allocation of too small buffers; prevented by bounds checking

---

## Comprehensive Exam Answer Keys

### Midterm Examination Answers

**Part I: Multiple Choice**
1. C
2. B
3. A
4. A
5. B
6. B
7. B
8. A
9. B
10. A
11. D
12. B
13. A
14. B
15. B
16. A
17. B
18. C
19. A
20. C

**Part II: True/False**
21. T
22. F
23. F
24. T
25. F
26. T
27. T
28. T
29. T
30. F
31. F
32. F
33. T
34. T
35. T
36. F
37. T
38. F
39. T
40. T

**Part III: Short Answer (Sample Answers)**

41. Install JDK 17, set JAVA_HOME, download Ghidra ZIP, extract, run launch script

42. Shows addresses, bytes, mnemonics, operands, and comments

43. strcpy without bounds checking; allows buffer overflow

44. XOR with 0x5A; if result is 0x40, access granted

45. Script enumerates all functions in the program

46. JG is signed comparison; JA is unsigned comparison

47. Double-click string, press X to see references

48. 0x5A; because 0x5A ^ 0x1A = 0x40

49. High entropy, strange section names, small .text section

50. Stack overflow overwrites stack; heap overflow overwrites heap

**Part IV: Practical**
51. The code checks if eax > 0x10. If so, ebx = 1; else ebx = 0. Return value is ebx.

---

### Final Examination Answers

**Part I: Multiple Choice**
1. C
2. B
3. B
4. B
5. B
6. D
7. C
8. A
9. B
10. B
11. D
12. C
13. B
14. C
15. A
16. B
17. C
18. D
19. A
20. A
21. C
22. A
23. A
24. A
25. A

**Part II: True/False**
26. T
27. F
28. T
29. F
30. T
31. T
32. T
33. T
34. F
35. F
36. T
37. T
38. T
39. F
40. T
41. F
42. T
43. T
44. T
45. T
46. T
47. T
48. F
49. T
50. F

**Part III: Short Answer (Sample Answers)**

51. DOS Header, NT Headers (File Header + Optional Header), Section Headers, Sections

52. Listing shows disassembly; Decompiler shows C-like code

53. strcpy without bounds checking; replace with strncpy

54. Use listing.getDefinedData(True) to iterate through strings

55. For has init, condition, increment; while just condition; do-while condition at end

56. Find interesting strings, trace XREFs to validation logic

57. XOR properties: commutative, associative, self-inverse, identity

58. Find conditional jump, change to JMP or NOP

59. Check file properties, strings, imports, entropy; extract domains, IPs, registry

60. Stack overflow writes beyond stack buffer; heap overflow writes beyond heap

**Part IV: Practical**

61a) strcpy without bounds checking (buffer overflow)

61b) Overwrite buffer to corrupt return address

61c) Buffer(64) + authenticated(1) + padding(7) + RBP(8) = 80 bytes

61d) Patch the conditional jump to always take the "Access granted" path

61e) Replace strcpy with strncpy and check buffer bounds

---

### Practical Skills Assessment Answers

**Task 1: Binary Analysis**

*(Sample answers based on typical challenges)*

**1. Triage (10 points)**
- File type: ELF 64-bit
- File size: ~45K
- Packed? No (entropy ~6.2)
- Strings: "Access granted", "Access denied", "FLAG{...}"

**2. Ghidra Analysis (15 points)**
- Main function located at 0x00401120
- Program validates a serial number
- Functions: main, validate_serial, print_flag
- Hidden functionality: XOR decryption of flag

**3. IOC Extraction (10 points)**
- No IOCs in this CTF challenge

**4. Report (5 points)**
Brief summary of findings

---

**Task 2: Scripting**

**1. Function Enumerator (10 points)**
```python
def main():
    func_manager = currentProgram.getFunctionManager()
    for func in func_manager.getFunctions(True):
        print(f"{func.getName()} at 0x{func.getEntryPoint().getOffset():08x}")
```

**2. Vulnerability Scanner (10 points)**
```python
dangerous = ['strcpy', 'sprintf', 'gets', 'printf']
def main():
    for func in currentProgram.getFunctionManager().getFunctions(True):
        body = func.getBody()
        for instr in currentProgram.getListing().getInstructions(body, True):
            if instr.isCall():
                for target in instr.getFlows():
                    target_func = getFunctionAt(target)
                    if target_func and target_func.getName() in dangerous:
                        print(f"Vulnerability: {target_func.getName()} at {instr.getAddress()}")
```

**3. XOR Decryptor (10 points)**
```python
def xor_decrypt(data, key):
    return ''.join(chr(b ^ key) for b in data if b != 0)
def main():
    data = getBytes(toAddr(0x00402000), 32)
    key = 0x5A
    print(xor_decrypt(data, key))
```

---

**Task 3: Patching**

**1. Bypass Authentication (10 points)**
Patch the conditional jump from JNE to JMP

**2. Export Patched Binary (10 points)**
File → Export Program → Save as new binary

---

**Task 4: Report (10 points)**

Report should include:
- Analysis methodology
- Findings and vulnerabilities
- IOCs
- Patches applied
- Recommendations

---

# Section 5: Grading Rubrics

---

## Written Response Rubric

| Criteria | Excellent (4) | Good (3) | Satisfactory (2) | Needs Improvement (1) |
|----------|---------------|----------|------------------|----------------------|
| **Accuracy** | Correct answer with complete technical accuracy | Mostly correct with minor errors | Partially correct with some errors | Incorrect or missing |
| **Completeness** | Covers all aspects of the question | Covers most aspects | Covers some aspects | Barely addresses the question |
| **Clarity** | Clear, well-organized, easy to follow | Mostly clear, minor confusion | Somewhat confusing, hard to follow | Unclear, disorganized |
| **Depth** | Deep understanding, detailed explanation | Good understanding, adequate detail | Surface-level understanding | No understanding demonstrated |
| **Examples** | Relevant, accurate examples provided | Good examples with minor issues | Generic examples | No examples |

---

## Practical Skills Rubric

| Criteria | Excellent (5) | Good (4) | Satisfactory (3) | Needs Improvement (2) | Poor (1) |
|----------|---------------|----------|------------------|----------------------|----------|
| **Tool Proficiency** | Expert use of all tools | Good use of most tools | Basic tool usage | Struggles with tools | Cannot use tools |
| **Analysis Quality** | Thorough, accurate analysis | Good analysis with minor gaps | Basic analysis | Incomplete analysis | No meaningful analysis |
| **Scripting** | Well-written, functional code | Good code with minor issues | Basic working code | Code with major issues | No code or non-functional |
| **Problem Solving** | Innovative, effective solutions | Good solutions | Basic solutions | Poor solutions | No solutions |
| **Reporting** | Comprehensive, professional report | Good report with minor issues | Basic report | Incomplete report | No report |

---

## Project Rubric

| Criteria | Excellent (10-9) | Good (8-7) | Satisfactory (6-5) | Needs Improvement (4-3) | Poor (2-0) |
|----------|------------------|------------|-------------------|------------------------|------------|
| **Analysis** | Complete, accurate, insightful | Good analysis with minor gaps | Basic analysis | Incomplete analysis | No meaningful analysis |
| **Documentation** | Comprehensive, professional | Good documentation | Basic documentation | Poor documentation | No documentation |
| **Scripts** | Well-structured, functional | Good scripts | Basic scripts | Scripts with issues | No scripts |
| **Results** | All objectives met | Most objectives met | Some objectives met | Few objectives met | No objectives met |
| **Presentation** | Professional, clear | Good presentation | Adequate presentation | Poor presentation | No presentation |

---

# End of Quiz and Test Bank

---

**Instructor Notes:**

**Recommended Use:**
- Module Quizzes: After each module for review
- Module Tests: At the end of each module for assessment
- Midterm: After Module 5
- Final: After all modules
- Practical Skills Assessment: Final practical exam

**Grading Scale:**
- A: 90-100%
- B: 80-89%
- C: 70-79%
- D: 60-69%
- F: Below 60%

**Additional Resources:**
- Solution scripts for practical problems
- Sample binaries for practical tests
- Answer keys for all questions

---

**End of Quiz and Test Bank**
