# Comprehensive Slide Deck Outline: Zero to Hero - Practical Reverse Engineering with Ghidra

## Complete Course Presentation Structure

---

## SECTION 0: COURSE INTRODUCTION AND OVERVIEW

### Slide 0.1: Title Slide
- **Course Title:** Zero to Hero: Practical Reverse Engineering with Ghidra
- **Subtitle:** From Complete Beginner to Professional Reverse Engineer
- **Duration:** Full course series (4 Parts + Appendices + Primers)
- **Instructor Name**
- **Date**

### Slide 0.2: What is Reverse Engineering?
- **Definition:** The process of analyzing a system to understand its components, behavior, and functionality without access to its source code
- **Analogy:** Like taking apart a clock to understand how it works
- **Key Concept:** Starting from the compiled output and working backwards
- **Real-World Applications:**
  - Malware analysis
  - Vulnerability research
  - CTF competitions
  - Software interoperability
  - Legacy system understanding

### Slide 0.3: Why Learn Reverse Engineering?
- **Career Opportunities:**
  - Malware Analyst
  - Security Researcher
  - Incident Responder
  - Vulnerability Researcher
  - Exploit Developer
- **Skill Benefits:**
  - Deep understanding of how software works
  - Ability to find security vulnerabilities
  - Capability to analyze malicious code
  - Independence from source code availability
- **Industry Demand:** High and growing

### Slide 0.4: Course Learning Objectives
- **By the end of this course, you will be able to:**
  - Install and configure Ghidra for professional workflows
  - Navigate Ghidra's interface efficiently
  - Analyze binaries using disassembly and decompilation
  - Solve CTF reverse engineering challenges
  - Analyze malware without executing it
  - Identify security vulnerabilities in compiled code
  - Automate analysis using Ghidra's Python API
  - Create YARA rules and detection signatures
  - Generate comprehensive analysis reports

### Slide 0.5: Course Structure Overview
- **Part 1:** Foundations, Tooling, and Your First Binary
- **Part 2:** CTF Challenges and Binary Logic Analysis
- **Part 3:** Malware Analysis and Payload Dissection
- **Part 4:** Vulnerability Research and Secure Code Auditing
- **Appendices:** Comprehensive reference materials
- **Primers:** Foundational concepts

### Slide 0.6: Target Audience
- **Cybersecurity Students** - Building practical skills
- **Software Developers** - Understanding compiled code
- **CTF Players** - Leveling up reverse engineering skills
- **Malware Analysts** - Adding Ghidra to the toolkit
- **Complete Beginners** - No prior reverse engineering experience

### Slide 0.7: Prerequisites
- **Minimum Requirements:**
  - Basic programming experience (any language)
  - Command-line comfort
  - Understanding of basic computer architecture
- **Nice to Have:**
  - C programming knowledge
  - x86/x64 assembly familiarity
  - Linux or Windows system administration
- **Not Required:**
  - Prior reverse engineering experience
  - Assembly expertise
  - Deep operating system knowledge

### Slide 0.8: What You'll Build Throughout This Course
- **Part 1:** Complete Ghidra environment + first binary analysis
- **Part 2:** CTF challenge solutions + binary patching skills
- **Part 3:** Malware analysis pipeline + IOC extraction
- **Part 4:** Vulnerability scanner + security audit capabilities
- **Every Part:** Production-grade Python automation scripts

### Slide 0.9: Tools and Technologies
- **Primary Tools:**
  - Ghidra (Software Reverse Engineering Framework)
  - Java Development Kit (JDK 17+)
  - Python 3
  - Text editor or IDE
  - C compiler (GCC, MinGW, or MSVC)
- **Additional Tools:**
  - readelf / dumpbin
  - objdump
  - hexdump / xxd
  - YARA
  - strace / ltrace (optional)
  - GDB (optional)

### Slide 0.10: Course Philosophy
- **Code-Heavy:** Every concept reinforced with complete, working code
- **No Shortcuts:** No "implement this yourself" placeholders
- **Beginner-Friendly:** Clear explanations with analogies
- **Expert Inside:** Production-quality code and techniques
- **Hands-On:** You'll build everything yourself
- **Progressive:** Each section builds on previous knowledge

### Slide 0.11: How to Get the Most Out of This Course
- **Do the Work:** Perform every step yourself
- **Don't Skip Verification:** Test each phase before moving on
- **Experiment:** Try techniques on different binaries
- **Keep Notes:** Document your observations and patterns
- **Join the Community:** Participate in reverse engineering forums
- **Practice Regularly:** Skills improve with consistent use

### Slide 0.12: Ethics and Legality
- **Key Principle:** Only analyze software you own or have explicit permission to analyze
- **Legal Considerations:**
  - Many countries have laws restricting reverse engineering
  - End-User License Agreements (EULAs) often prohibit it
  - CTF challenges are explicitly designed for education
- **Ethical Responsibility:**
  - Use skills for defense, not offense
  - Report vulnerabilities responsibly
  - Respect intellectual property
- **Our Focus:** Educational malware samples and CTF challenges

### Slide 0.13: Course Roadmap
- **Part 0:** Introduction (You are here)
- **Part 1:** Foundations and Your First Binary
- **Part 2:** CTF Challenges and Logic Analysis
- **Part 3:** Malware Analysis and Payload Dissection
- **Part 4:** Vulnerability Research and Auditing
- **Appendices:** Comprehensive Reference
- **Primers:** Foundational Deep Dives

---

## SECTION 1: PART 1 - FOUNDATIONS, TOOLING, AND YOUR FIRST BINARY

### Slide 1.0: Part 1 Overview
- **Title:** Foundations, Tooling, and Your First Binary
- **Duration:** Approximately 2-3 hours of content
- **Learning Objectives:**
  - Install and configure Ghidra
  - Understand machine code, assembly, and decompilation
  - Navigate Ghidra's interface
  - Analyze a simple C program
  - Write your first Ghidra Python script

### Slide 1.1: Phase 1.1 - Installing Ghidra
- **Target:** Set up complete Ghidra development environment
- **What You'll Need:**
  - JDK 17 or later (not just JRE!)
  - Ghidra distribution (ZIP archive)
  - Proper environment variables
- **Installation Steps:**
  1. Install JDK 17
  2. Set JAVA_HOME
  3. Download Ghidra
  4. Extract to desired location
  5. Launch and verify
- **Memory Configuration:**
  - Default: 2GB
  - Recommended: 4GB or more
  - Adjust via -Xmx parameter

### Slide 1.2: JDK Installation Walkthrough
- **Why JDK, not JRE?**
  - Ghidra needs development tools
  - Compiles scripts
  - Performs complex analyses
- **Installation Commands:**
  - **Windows:** Download Adoptium installer, set environment variables
  - **Linux:** `sudo apt install openjdk-17-jdk`
  - **macOS:** `brew install openjdk@17`
- **Verification:**
  ```bash
  java -version
  javac -version
  ```

### Slide 1.3: Ghidra Installation and First Launch
- **Download Location:** https://ghidra-sre.org/
- **Installation:**
  - Extract ZIP to preferred location
  - No installer required (portable)
- **First Launch Behavior:**
  - Creates .ghidra configuration directory
  - Splash screen appears
  - Project Manager opens
- **Troubleshooting:**
  - "Java not found" → Set JAVA_HOME
  - "Out of Memory" → Increase -Xmx
  - "Unsupported Java" → Install JDK 17

### Slide 1.4: Phase 1.2 - Understanding Executable Formats
- **Two Major Formats:**
  - **PE** (Portable Executable) - Windows
    - `.exe`, `.dll`, `.sys`, `.cpl`
  - **ELF** (Executable and Linkable Format) - Linux
    - Executables, `.so`, `.o`
- **Analogy:** Like shipping containers with manifests
- **Key Components:**
  - Headers: File metadata
  - Sections: Code and data grouping
  - Imports: External functions used
  - Entry point: Where execution starts

### Slide 1.5: Anatomy of an Executable File
- **PE Structure:**
  ```
  DOS Header (MZ)
  DOS Stub
  NT Headers (PE\0\0)
    - File Header
    - Optional Header
  Section Headers
  Sections (.text, .data, .rdata, .rsrc)
  Import/Export Data
  ```
- **ELF Structure:**
  ```
  ELF Header (\x7FELF)
  Program Headers (Segments)
  Sections
    - .text, .data, .rodata, .bss
    - .plt, .got, .dynamic
  Section Headers
  ```

### Slide 1.6: Phase 1.3 - Creating Your First Ghidra Project
- **What is a Ghidra Project?**
  - Like a case file for detectives
  - Holds binary + analysis results
  - Saves renamed functions, comments, data types
- **Creating a Project:**
  1. Launch Ghidra
  2. Click "New Project"
  3. Choose "Non-shared Project"
  4. Name it (e.g., "GhidraTraining")
  5. Select directory
- **Importing a Binary:**
  1. Click "Import File"
  2. Browse to binary
  3. Auto-detect format
  4. Click "OK"

### Slide 1.7: Compiling a Sample Program
- **The Calculator Program:**
  ```c
  #include <stdio.h>
  int add(int a, int b) { return a + b; }
  // ... more functions ...
  int main() {
      // Calculator logic with "secret" validation
  }
  ```
- **Compilation Commands:**
  - **Linux:** `gcc -g -o calculator calculator.c`
  - **Windows:** `gcc -g -o calculator.exe calculator.c`
  - **Both:** Also compile stripped version: `gcc -s -o calculator_stripped calculator.c`

### Slide 1.8: Running Initial Analysis
- **Analysis Process:**
  1. Open imported binary
  2. Click "Yes" to analyze
  3. Select all analyzers
  4. Wait for completion
- **What Analysis Does:**
  - Disassembles code
  - Identifies functions
  - Finds strings and data
  - Resolves imports
  - Builds call graph
- **Time:** 10-30 seconds for simple binaries

### Slide 1.9: Phase 1.4 - Navigating the Ghidra Interface
- **The Five Primary Panels:**
  1. **Listing Window:** Raw disassembly
  2. **Decompiler Window:** C-like representation
  3. **Symbol Tree:** Functions and labels
  4. **Data Type Manager:** Data types
  5. **Program Trees:** Sections and headers
- **Additional Windows:**
  - Function Graph (visual control flow)
  - Program Manager (project view)

### Slide 1.10: Listing Window Deep Dive
- **What It Shows:**
  - Addresses
  - Machine code bytes
  - Assembly mnemonics
  - Operands
  - Comments and annotations
- **Color Coding:**
  - Black: Regular code
  - Blue: Functions and entry points
  - Red: Data references
  - Green: Comments
- **Key Shortcuts:**
  - `Ctrl+F`: Search
  - `G`: Go to address
  - `Up/Down`: Navigate

### Slide 1.11: Decompiler Window Deep Dive
- **What It Shows:**
  - C-like code representation
  - Function logic
  - Variable names (generic)
  - Control flow structures
- **Why It's Powerful:**
  - Translates assembly to readable code
  - Highlights complex logic
  - Makes analysis accessible
- **Limitations:**
  - Obfuscated code is harder
  - Variable names are generic (`iVar1`, `uVar2`)
  - Requires manual annotation

### Slide 1.12: Symbol Tree Deep Dive
- **What It Shows:**
  - All functions (user and library)
  - Labels and data symbols
  - Imports (external symbols)
  - Exports (DLLs only)
- **Navigation:**
  - Expand folders to explore
  - Double-click to navigate
  - Right-click for options
- **Key Shortcuts:**
  - `F`: Jump to function
  - `L`: Show all labels

### Slide 1.13: Program Trees Deep Dive
- **What It Shows:**
  - ELF sections or PE headers
  - Memory blocks
  - File structure
- **PE Views:**
  - DOS Header
  - NT Headers
  - Sections (.text, .data, etc.)
  - Data Directories
- **ELF Views:**
  - ELF Header
  - Program Headers
  - Sections (.text, .data, etc.)
- **Key Use:** Understanding file structure

### Slide 1.14: Phase 1.5 - Analyzing Your First Binary
- **The Process:**
  1. **Observe:** Look at decompiled code
  2. **Hypothesize:** Guess what variables/functions do
  3. **Verify:** Check assembly for confirmation
  4. **Rename:** Give meaningful names
  5. **Comment:** Add explanatory notes
- **Example:**
  - `param_1` → `argc`
  - `local_4` → `a`
  - `local_8` → `b`
  - `FUN_00401250` → `validate_access`

### Slide 1.15: Renaming Variables
- **Before:**
  ```c
  undefined8 main(int param_1, long param_2) {
      int local_4;
      int local_8;
      // ...
  }
  ```
- **After:**
  ```c
  int main(int argc, char** argv) {
      int a;
      int b;
      // ...
  }
  ```
- **How to Rename:**
  - Right-click on variable
  - Select "Rename Variable"
  - Type new name
  - Press Enter
- **Best Practices:**
  - Use meaningful names
  - Be consistent
  - Rename parameters first

### Slide 1.16: Adding Comments
- **Why Comments Matter:**
  - Document discoveries
  - Explain complex logic
  - Track analysis progress
- **Types of Comments:**
  - **Function Comments:** Purpose, parameters, returns
  - **Instruction Comments:** What specific code does
  - **Data Comments:** What data represents
- **How to Add:**
  - Right-click on instruction/data
  - Select "Comment"
  - Type explanation
  - Press Enter

### Slide 1.17: Setting Data Types
- **Why Correct Types Matter:**
  - Improves decompiler output
  - Makes code more readable
  - Enables further analysis
- **Common Types:**
  - `int`, `char*`, `void`
  - Structure definitions
  - Pointer types
- **How to Set:**
  - Right-click on function
  - Select "Edit Function"
  - Modify return type/parameters
  - Click "OK"

### Slide 1.18: Phase 1.6 - Writing Your First Ghidra Python Script
- **Why Script?**
  - Automate repetitive tasks
  - Process thousands of items
  - Build analysis pipelines
- **The Script:**
  ```python
  # Enumerate all functions
  func_manager = currentProgram.getFunctionManager()
  functions = func_manager.getFunctions(True)
  for func in functions:
      print(f"Function: {func.getName()}")
  ```

### Slide 1.19: Understanding the Ghidra Python API
- **Key Objects:**
  - `currentProgram` - The open binary
  - `FunctionManager` - Access all functions
  - `Function` - Individual function
  - `Listing` - Instructions and data
  - `SymbolTable` - Symbols and labels
- **Common Patterns:**
  ```python
  program = currentProgram
  func_manager = program.getFunctionManager()
  for func in func_manager.getFunctions(True):
      # Do something with func
  ```

### Slide 1.20: Complete Script Example
- **Script Purpose:** Enumerate all functions with statistics
- **Key Components:**
  1. Get program
  2. Get function manager
  3. Iterate through functions
  4. Get function properties
  5. Print formatted output
- **Demonstrates:**
  - API usage
  - Iteration
  - Data formatting
  - Error handling
  - Categorization (user vs. library)

### Slide 1.21: Phase 1.7 - Essential Navigation Shortcuts
- **Navigation:**
  - `G`: Go to address
  - `F`: Search for function
  - `Ctrl+F`: Find text
  - `Alt+Left/Right`: Back/forward
- **Analysis:**
  - `X`: Show cross-references
  - `Ctrl+E`: Show decompiler
  - `F11`: Toggle Listing/Decompiler focus
- **Annotating:**
  - `N`: Rename symbol
  - `;` (semicolon): Add comment
  - `B`: Set bookmark

### Slide 1.22: Part 1 Summary
- **You've Achieved:**
  - ✅ Installed and configured Ghidra
  - ✅ Created first project
  - ✅ Compiled and imported a binary
  - ✅ Navigated the interface
  - ✅ Renamed variables and functions
  - ✅ Added comments and annotations
  - ✅ Wrote first Python script
  - ✅ Mastered navigation shortcuts
- **Next Step:** Part 2 - CTF Challenges

---

## SECTION 2: PART 2 - CTF CHALLENGES AND BINARY LOGIC ANALYSIS

### Slide 2.0: Part 2 Overview
- **Title:** CTF Challenges and Binary Logic Analysis
- **Duration:** Approximately 2-3 hours of content
- **Learning Objectives:**
  - Understand control flow analysis
  - Use cross-references effectively
  - Recover XOR-encrypted secrets
  - Patch binaries to modify behavior
  - Recover complex algorithms

### Slide 2.1: Phase 2.1 - Control Flow Analysis
- **What is Control Flow?**
  - Order of instruction execution
  - Decision points and branches
  - Loops and repetitions
  - Function calls and returns
- **Key Concepts:**
  - **Basic Block:** Straight-line code with one entry/exit
  - **Conditional Branch:** `if`, `switch`
  - **Loop:** `for`, `while`, `do-while`
  - **Function Call:** Call and return

### Slide 2.2: Control Flow Graph (CFG)
- **What is a CFG?**
  - Visual representation of execution paths
  - Nodes = Basic Blocks
  - Edges = Jumps/Branches
- **In Ghidra:**
  - Click "Function Graph" button
  - Shows visual flow
  - Click blocks to navigate
  - Color-coded: Entry (green), Exit (red)
- **Benefits:**
  - Understand complex logic quickly
  - Identify loops and recursion
  - Spot obfuscation patterns

### Slide 2.3: Basic Block Analysis
- **Identifying Basic Blocks:**
  1. Find function entry point
  2. Follow instructions until branch
  3. Branch ends the block
  4. Branch target starts new block
- **Block Characteristics:**
  - One entry point
  - One exit point (or fall-through)
  - No jumps inside
- **Manual Identification Example:**
  ```
  Block 1: Entry
    push rbp; mov rbp, rsp
    sub rsp, 0x20
    cmp eax, 0x10
    jg block_2
  Block 2: True branch
    add eax, ebx
    jmp block_3
  Block 3: Merge
    leave; ret
  ```

### Slide 2.4: Conditional Branch Patterns
- **Common Conditions:**
  - `cmp a, b; jg label` → if (a > b)
  - `cmp a, b; jl label` → if (a < b)
  - `cmp a, b; je label` → if (a == b)
  - `test a, a; jz label` → if (a == 0)
- **Jump Instructions:**
  - `JE/JZ`: Equal/Zero
  - `JNE/JNZ`: Not Equal
  - `JG/JL`: Greater/Less (signed)
  - `JA/JB`: Above/Below (unsigned)

### Slide 2.5: Phase 2.2 - Cross-References (XREFs)
- **What Are XREFs?**
  - Relationships between code/data
  - Shows who uses what
  - Traces data flow
- **Types:**
  - **Code References:** Function calls, jumps
  - **Data References:** String usage, variable access
  - **Incoming (XREFs To):** Who calls this?
  - **Outgoing (XREFs From):** What does this call?
- **Analogy:** Detective investigation board

### Slide 2.6: Finding Interesting Strings
- **Why Strings Matter:**
  - Error messages reveal validation paths
  - URLs/domains indicate C2
  - "Correct!" points to flag logic
  - "Access granted" shows authentication
- **In Ghidra:**
  - `Window` → `Defined Strings`
  - Browse all strings
  - Double-click to navigate
  - Press `X` for references
- **Common Patterns:**
  - "Invalid password" → Validation check
  - "FLAG{" → Flag location
  - "http://" → Network communication

### Slide 2.7: Tracing Function Calls with XREFs
- **Finding Who Calls a Function:**
  1. Navigate to function
  2. Right-click → "Show References to Function"
  3. View all callers
  4. Click to navigate
- **Finding What a Function Calls:**
  1. Navigate to function
  2. Right-click → "Show References from Function"
  3. View all callees
- **Application:**
  - Find validation function callers
  - Trace flag generation flow
  - Understand attack chain

### Slide 2.8: Phase 2.3 - XOR Decryption
- **What is XOR?**
  - Bitwise exclusive OR
  - Symmetric (encrypt/decrypt same)
  - Common in CTF challenges
- **Properties:**
  - A XOR B = B XOR A
  - (A XOR B) XOR B = A
  - A XOR 0 = A
  - A XOR A = 0
- **Example:**
  - Encrypted: [0x35, 0x2B, 0x32]
  - Key: 0x42
  - Decrypt: 0x35 ^ 0x42 = 0x77 ('w')

### Slide 2.9: Identifying XOR Patterns
- **In Assembly:**
  - `xor eax, 0x5A` → XOR with constant
  - `xor eax, ebx` → XOR with register
  - Loop over bytes with XOR
- **In Decompiler:**
  ```c
  for (i = 0; i < len; i++) {
      decrypted[i] = encrypted[i] ^ 0x5A;
  }
  ```
- **Indicators:**
  - Loop with XOR operation
  - Hardcoded byte arrays
  - Strings that look random

### Slide 2.10: XOR Decryption Script
- **Manual Decryption:**
  ```python
  encrypted = [0x35, 0x2B, 0x32]
  key = 0x42
  decrypted = ''.join(chr(b ^ key) for b in encrypted)
  ```
- **Automated in Ghidra:**
  ```python
  addr = toAddr(0x00402000)
  length = 32
  data = getBytes(addr, length)
  key = 0x5A
  decrypted = ''.join(chr(b ^ key) for b in data)
  print(decrypted)
  ```

### Slide 2.11: Phase 2.4 - Binary Patching
- **What is Patching?**
  - Modifying compiled binary code
  - Change program behavior
  - Bypass authentication
  - Enable hidden features
- **Why Patch?**
  - CTF challenges (bypass checks)
  - Software protection analysis
  - Malware disabling
  - Vulnerability demonstration

### Slide 2.12: Types of Patches
- **Conditional Jump Modification:**
  - `jne` → `jmp` (always take branch)
  - `jne` → `nop` (remove branch)
  - `jne` → `je` (invert condition)
- **Constant Modification:**
  - `cmp eax, 0x40` → `cmp eax, 0x00`
  - Change comparison target
- **Instruction Replacement:**
  - `call exit` → `nop`
  - `add eax, 0x10` → `sub eax, 0x10`

### Slide 2.13: How to Patch in Ghidra
- **Method 1: Patch Instruction**
  1. Right-click instruction
  2. Select "Patch Instruction"
  3. Modify mnemonic/operands
  4. Click "OK"
- **Method 2: Patch Bytes**
  1. Right-click address
  2. Select "Patch Bytes"
  3. Enter new bytes (hex)
  4. Click "OK"
- **Method 3: Scripting**
  ```python
  setByte(addr, 0x90)  # Write NOP
  ```

### Slide 2.14: Saving Patched Binary
- **Export Patched Program:**
  1. `File` → `Export Program`
  2. Select "Original File" (overwrite)
  3. Or "ELF/PE" (new file)
  4. Choose filename
  5. Click "OK"
- **Testing:**
  - Run patched binary
  - Verify behavior change
  - Compare with original
- **Note:** Patched binary only in Ghidra until exported

### Slide 2.15: Phase 2.5 - Algorithm Recovery
- **The Process:**
  1. Identify validation function
  2. Understand input expectations
  3. Trace data flow
  4. Reconstruct algorithm
  5. Generate valid input (keygen)
- **Common Algorithms:**
  - Checksums
  - Hashing functions
  - XOR chains
  - Custom encryption
  - Complex mathematical operations

### Slide 2.16: Complex Algorithm Example
- **Validation Algorithm:**
  - Input must be 16 characters
  - Even positions: (char ^ 0x55)
  - Odd positions: char * 2
  - Sum must equal 0x4A6
- **Recovery Process:**
  1. Extract algorithm from decompiler
  2. Understand constraints
  3. Write keygen script
  4. Test generated serial

### Slide 2.17: Keygen Creation
- **Purpose:** Generate valid serial numbers
- **Approach:**
  1. Understand validation constraints
  2. Work backwards from target
  3. Generate characters that meet conditions
  4. Verify with binary
- **Script Example:**
  ```python
  def generate_serial():
      # Build serial character by character
      # Each position must meet specific criteria
      # Sum must equal target
      return serial
  ```

---

## SECTION 3: PART 3 - MALWARE ANALYSIS AND PAYLOAD DISSECTION

### Slide 3.0: Part 3 Overview
- **Title:** Malware Analysis and Payload Dissection
- **Duration:** Approximately 2-3 hours of content
- **Learning Objectives:**
  - Perform static malware triage
  - Identify packed executables
  - Extract Indicators of Compromise (IOCs)
  - Analyze C2 communication
  - Create YARA detection rules

### Slide 3.1: Phase 3.1 - Static Malware Triage
- **What is Triage?**
  - Initial assessment of suspicious binary
  - Determine threat level
  - Identify next steps
  - No execution involved
- **Key Components:**
  - File information
  - String extraction
  - Import analysis
  - Entropy checking
  - Section inspection

### Slide 3.2: Triage Checklist
- **File Identification:**
  - `file` command → ELF, PE, or Mach-O
  - Architecture (x86, x64, ARM)
  - Stripped or debug symbols
- **Size Analysis:**
  - Small → Could be packed
  - Large → May contain embedded data
  - Compare to expected size
- **Entropy:**
  - > 7.5 → Likely packed
  - < 7.0 → Unpacked
  - Use entropy tool or script

### Slide 3.3: Identifying Packing
- **Packing Indicators:**
  - High entropy sections
  - Small .text section (but .data large)
  - Strange section names (UPX0, UPX1)
  - Suspicious entry point (not in .text)
  - Few imports (typically unpacker only)
- **Common Packers:**
  - UPX (Unpack by UPX -d)
  - Themida, ASPack, Armadillo
  - Custom packers

### Slide 3.4: Phase 3.2 - Malware Behavior Analysis
- **What Does Malware Do?**
  - Initial Execution
  - Persistence installation
  - C2 Communication
  - Malicious Actions
  - Anti-Analysis
- **The Attack Chain:**
  1. Infection vector
  2. Execution
  3. Persistence
  4. C2 communication
  5. Command execution
  6. Data exfiltration

### Slide 3.5: Common Malicious Behaviors
- **Process Injection:**
  - `VirtualAllocEx`, `WriteProcessMemory`, `CreateRemoteThread`
  - Injects code into other processes
- **Persistence:**
  - Registry Run keys (Windows)
  - Systemd services (Linux)
  - Scheduled tasks
- **C2 Communication:**
  - `socket`, `connect`, `send`, `recv`
  - HTTP/HTTPS
  - DNS tunneling
- **Anti-Analysis:**
  - `IsDebuggerPresent`
  - Timing checks
  - VM detection

### Slide 6.0: Phase 4.1 - Memory Corruption Vulnerabilities
- **What Are They?**
  - Bugs that allow overwriting memory
  - Can lead to code execution
  - Critical security issues
- **Types:**
  1. **Stack Buffer Overflow:** Overwriting local variables
  2. **Heap Buffer Overflow:** Overwriting dynamically allocated memory
  3. **Format String:** Using user input as format specifier
  4. **Integer Overflow:** Arithmetic overflow leading to undersized allocation
  5. **Use-After-Free:** Accessing freed memory

### Slide 6.1: Understanding the Stack
- **Stack Layout:**
  ```
  Higher Addresses:
  +-------------------+
  |  Arguments        |
  +-------------------+
  |  Return Address   |
  +-------------------+
  |  Saved Frame Ptr  |
  +-------------------+
  |  Local Variables  |
  +-------------------+
  |  Stack Growth     |
  Lower Addresses:
  ```
- **Why It Matters:**
  - Overwriting return address changes execution
  - Overwriting local variables changes program logic
- **Stack Protection:**
  - Stack canaries
  - Non-executable stack

### Slide 6.2: Phase 4.2 - Data Flow Analysis
- **What is Data Flow?**
  - How data moves through the program
  - From source to sink
  - Transformations along the way
- **Key Concepts:**
  - **Source:** Where input enters (recv, read, fgets)
  - **Sink:** Dangerous function (strcpy, sprintf, system)
  - **Propagation:** How data moves
  - **Sanitization:** Validation/cleaning

### Slide 6.3: Taint Tracking
- **What is Taint?**
  - Marking user-controlled data
  - Tracking its journey through program
  - Identifying if it reaches dangerous function
- **In Practice:**
  - Manual: Follow data flow in decompiler
  - Automated: Scripts to trace sources to sinks
- **Vulnerability Pattern:**
  ```
  Source (recv) → Propagation (assignment) → Sink (strcpy)
  ```

### Slide 6.4: Phase 4.3 - Automated Vulnerability Discovery
- **What to Automate:**
  - Finding unsafe functions
  - Detecting buffer overflow candidates
  - Identifying format string vulnerabilities
  - Integer overflow patterns
- **Script Approach:**
  1. Find all function calls
  2. Check for dangerous functions
  3. Trace data flow to sources
  4. Report vulnerability candidates

### Slide 6.5: Unsafe Function Detection
- **Functions to Watch For:**
  - `strcpy`, `strcat`, `sprintf`, `gets`
  - `scanf` (with %s)
  - `system`, `popen`, `exec`
  - `printf`, `fprintf`, `vprintf`
- **Script Pattern:**
  ```python
  dangerous = ['strcpy', 'strcat', 'sprintf', 'gets']
  for func in functions:
      if func.getName() in dangerous:
          print(f"Found dangerous function: {func.getName()}")
  ```

### Slide 6.6: Phase 4.4 - Exploitation Concepts
- **The Exploit Chain:**
  1. Identify vulnerability
  2. Craft input to trigger it
  3. Overwrite return address
  4. Redirect execution
  5. Execute shellcode
- **Mitigations to Bypass:**
  - Stack canaries
  - ASLR (Address Space Layout Randomization)
  - NX (Non-Executable memory)
  - DEP (Data Execution Prevention)

### Slide 6.7: Exploit Example
- **Vulnerable Code:**
  ```c
  char buffer[64];
  strcpy(buffer, user_input);
  ```
- **Exploit Payload:**
  - 64 bytes to fill buffer
  - 8 bytes to overwrite RBP
  - 8 bytes to overwrite return address
- **In Python:**
  ```python
  payload = b'A' * 64          # Fill buffer
  payload += b'B' * 8          # Overwrite RBP
  payload += struct.pack('<Q', shellcode_addr)  # Overwrite return address
  ```

### Slide 6.8: Modern Mitigations
- **ASLR:** Randomizes addresses
  - Prevents knowing exact address
  - Can be bypassed with leaks
- **DEP/NX:** Prevents code execution in data
  - Requires ROP (Return-Oriented Programming)
  - Using existing code sequences
- **Stack Canaries:** Detect overflow
  - Random value before return address
  - Corrupted = program exits
- **CFG:** Control Flow Guard
  - Validates indirect calls
  - Prevents jumping to arbitrary code

---

## SECTION 4: APPENDICES OVERVIEW

### Slide A.0: Appendices Introduction
- **Purpose:** Comprehensive reference material
- **Format:** Standalone reference documents
- **When to Use:** Throughout your reverse engineering journey
- **List of Appendices:**
  - Appendix A: Ghidra Python API Reference
  - Appendix B: Assembly Language Quick Reference
  - Appendix C: Complete CTF Challenge Walkthroughs
  - Appendix D: Ghidra Installation and Configuration Guide
  - Appendix E: Linux and Windows Binary Formats Deep Dive
  - Appendix F: Ghidra Scripting Cookbook
  - Appendix G: Complete Project Walkthrough

### Slide A.1: Appendix A - Ghidra Python API Reference
- **What's Covered:**
  - Core API classes (Program, Address, Memory, Listing)
  - FunctionManager and Function
  - SymbolTable and Symbol
  - Data types and structures
  - Common script patterns
  - Error handling
- **When to Use:**
  - Writing Ghidra scripts
  - Understanding API capabilities
  - Debugging script issues

### Slide A.2: Appendix B - Assembly Language Quick Reference
- **What's Covered:**
  - x86/x64 register reference
  - Instruction set reference
  - Calling conventions
  - Common code patterns
  - System call tables
  - Operand types and syntax
- **When to Use:**
  - Reading disassembly
  - Understanding decompiler output
  - Writing patches

### Slide A.3: Appendix C - Complete CTF Challenge Walkthroughs
- **What's Covered:**
  - Challenge 1: XOR Guardian (Easy)
  - Challenge 2: Serial Validator (Medium)
  - Challenge 3: Malware Analysis (Hard)
  - Challenge 4: Buffer Overflow Exploitation (Hard)
  - Challenge 5: Format String Exploitation (Medium)
- **For Each Challenge:**
  - Full solution
  - Step-by-step reasoning
  - Complete scripts
  - Verification steps

### Slide A.4: Appendix D - Installation and Configuration Guide
- **What's Covered:**
  - JDK installation (all platforms)
  - Ghidra installation
  - Memory configuration
  - Plugin installation
  - Troubleshooting common issues
  - Headless analysis setup
- **When to Use:**
  - Setting up new environment
  - Troubleshooting installation issues
  - Headless analysis deployment

### Slide A.5: Appendix E - Binary Formats Deep Dive
- **What's Covered:**
  - ELF format (complete structure)
  - PE format (complete structure)
  - Comparing ELF and PE
  - Packing indicators
  - Malware indicators
  - Practical analysis commands
- **When to Use:**
  - Understanding binary structure
  - Identifying packing
  - Analyzing malware

### Slide A.6: Appendix F - Ghidra Scripting Cookbook
- **What's Covered:**
  - Function Analysis Suite
  - Cross-Reference Analyzer
  - String Analyzer and Extractor
  - IOC Extractor
  - YARA Rule Generator
  - Anti-Analysis Detector
  - XOR Decryptor
  - Serial Key Generator
  - Batch Renamer
  - Function Exporter
  - Memory Dumper
- **When to Use:**
  - Need ready-to-run scripts
  - Learning API usage patterns
  - Building larger scripts

### Slide A.7: Appendix G - Complete Project Walkthrough
- **The Challenge:** "The Enigma Protocol"
  - Full analysis walkthrough
  - From triage to flag
  - All techniques combined
- **What's Covered:**
  - Initial triage
  - Static analysis in Ghidra
  - Decryption implementation
  - Malware behavior analysis
  - YARA rule creation
  - IOC report generation

---

## SECTION 5: PRIMERS OVERVIEW

### Slide P.0: Primers Introduction
- **Purpose:** Standalone deep dives into foundational concepts
- **When to Read:** Before starting main series or as needed
- **Format:** Comprehensive, beginner-friendly explanations
- **List of Primers:**
  - Primer 1: Understanding Machine Code, Assembly, and Decompilation
  - Primer 2: Understanding Executable File Formats (PE and ELF)
  - Primer 3: Common Assembly Patterns for Reverse Engineers
  - Primer 4: Ghidra Scripting Fundamentals
  - Primer 5: Reverse Engineering Workflows and Methodology

### Slide P.1: Primer 1 - Machine Code, Assembly, and Decompilation
- **What's Covered:**
  - What is machine code?
  - Understanding assembly language
  - The decompilation process
  - From source to binary
  - What's lost in compilation
- **Key Concepts:**
  - Registers, stack, instructions
  - Calling conventions
  - Function prologue/epilogue
  - Data types in assembly

### Slide P.2: Primer 2 - Executable File Formats
- **What's Covered:**
  - PE format (Windows)
  - ELF format (Linux)
  - Headers and sections
  - Imports and exports
  - Dynamic linking
  - Comparing PE and ELF
- **Key Concepts:**
  - DOS/ELF headers
  - Program headers vs. section headers
  - Import Address Table (IAT)
  - Global Offset Table (GOT)

### Slide P.3: Primer 3 - Common Assembly Patterns
- **What's Covered:**
  - Function patterns (prologue, epilogue)
  - Branching patterns (if, if-else, switch)
  - Loop patterns (for, while, do-while)
  - Data movement patterns
  - Arithmetic patterns
  - Compiler-specific patterns
- **Key Concepts:**
  - Pattern recognition
  - Decompiler output mapping
  - Manual disassembly reading

### Slide P.4: Primer 4 - Ghidra Scripting Fundamentals
- **What's Covered:**
  - Basic script structure
  - Core API objects
  - Common scripting tasks
  - Error handling
  - Script optimization
  - Complete script examples
- **Key Concepts:**
  - Python in Ghidra
  - Program, Address, Memory
  - FunctionManager, Function
  - Listing, SymbolTable
  - Headless execution

### Slide P.5: Primer 5 - Reverse Engineering Workflows
- **What's Covered:**
  - The reverse engineering mindset
  - The analysis pipeline
  - CTF-specific workflows
  - Malware analysis workflows
  - Vulnerability research workflows
  - Documentation and reporting
- **Key Concepts:**
  - Triage → Scope → Deep Dive → Report
  - Top-down vs. bottom-up analysis
  - Time management
  - When to stop

---

## SECTION 6: CONCLUSION AND NEXT STEPS

### Slide 6.1: Course Summary
- **You've Learned:**
  - Ghidra installation and configuration
  - Binary analysis fundamentals
  - CTF challenge solving techniques
  - Malware analysis skills
  - Vulnerability research methods
  - Automation with Python
  - Complete analysis workflows

### Slide 6.2: Skills You've Acquired
- **Technical Skills:**
  - Ghidra navigation and analysis
  - Assembly language understanding
  - Binary patching
  - XOR decryption
  - IOC extraction
  - YARA rule creation
  - Python scripting
- **Methodological Skills:**
  - Systematic analysis approach
  - Documentation and reporting
  - Time management
  - Hypothesis testing

### Slide 6.3: Where to Go From Here
- **Practice:**
  - CTF platforms (HTB, TryHackMe)
  - MalwareBazaar (real samples)
  - Exploit-DB (vulnerability research)
- **Specialize:**
  - Malware analysis
  - Vulnerability research
  - Exploit development
  - Threat intelligence
- **Community:**
  - r/ReverseEngineering
  - Ghidra Discord
  - CTF teams
  - Security conferences

### Slide 6.4: Recommended Resources
- **Books:**
  - "Practical Reverse Engineering" by Bruce Dang
  - "The IDA Pro Book" by Chris Eagle
  - "Reverse Engineering for Beginners" by Dennis Yurichev
- **Online:**
  - Ghidra official documentation
  - OpenSecurityTraining.info
  - LiveOverflow YouTube
  - MalwareAnalysisForHedgehogs
- **Tools:**
  - Ghidra plugins
  - YARA
  - Binary Ninja
  - IDA Free

### Slide 6.5: Final Message
- **Remember:**
  - Reverse engineering is a skill that improves with practice
  - Everyone starts somewhere
  - The community is helpful and welcoming
  - Use your skills ethically and responsibly
- **Keep Learning:**
  - New techniques emerge constantly
  - Different architectures require different approaches
  - The fundamentals never change
- **Happy Reversing!**

### Slide 6.6: Q&A Session
- **Common Questions:**
  - "How long does it take to become proficient?"
  - "What's the best first project?"
  - "Do I need to know C?"
  - "What's the difference between static and dynamic analysis?"
  - "Can I use Ghidra for commercial work?"
- **Discussion Points:**
  - Personal experiences
  - Challenges faced
  - Success stories
  - Career paths

---

## ADDITIONAL TEACHING SLIDES

### Teaching Slide 1: Ghidra vs. Other Tools

| Feature | Ghidra | IDA Pro | Binary Ninja | Radare2 |
|---------|--------|---------|--------------|---------|
| **Price** | Free | Expensive | Paid | Free/Paid |
| **Decompiler** | Excellent | Excellent | Good | Good |
| **Scripting** | Python/Java | Python/IDC | Python | Python |
| **Open Source** | Yes | No | Partial | Yes |
| **Learning Curve** | Moderate | Steep | Moderate | Very Steep |
| **Platforms** | Windows/Linux/macOS | Windows/Linux/macOS | Windows/Linux/macOS | All |

### Teaching Slide 2: The Ghidra Scripting Ecosystem

```
┌─────────────────────────────────────┐
│         Ghidra Scripting            │
├─────────────────────────────────────┤
│  Python (Most Common)               │
│    - Easy to learn                  │
│    - Rich ecosystem                 │
│    - Good for automation            │
├─────────────────────────────────────┤
│  Java                               │
│    - Full API access                │
│    - Faster execution               │
│    - More verbose                   │
├─────────────────────────────────────┤
│  JavaScript                         │
│    - Lightweight                    │
│    - UI scripting                   │
│    - Limited Ghidra access          │
└─────────────────────────────────────┘
```

### Teaching Slide 3: Analysis Priority Matrix

| | High Impact | Low Impact |
|--|-------------|------------|
| **High Effort** | Deep dive key functions | Consider skipping |
| **Low Effort** | Quick wins (strings, IOCs) | Note and move on |

**Decision Guide:**
- If high effort + high impact → Do it
- If high effort + low impact → Consider skipping
- If low effort + high impact → Do it immediately
- If low effort + low impact → Note for later

### Teaching Slide 4: The Malware Analysis Pipeline in Detail

```
┌─────────────────────────────────────────────────────────────┐
│              Malware Analysis Pipeline                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Phase 1: Triage (5-15 min)                                │
│    - file, strings, entropy, imports                       │
│    - Is it packed?                                         │
│    - What's the file type?                                 │
│                                                             │
│  Phase 2: Static Analysis (30 min - 2 hours)              │
│    - Import to Ghidra                                      │
│    - Find suspicious functions                             │
│    - Extract IOCs                                          │
│    - Understand behavior                                   │
│                                                             │
│  Phase 3: Behavior Analysis (Hours - Days)                │
│    - What does it do?                                      │
│    - How does it persist?                                  │
│    - How does it communicate?                              │
│                                                             │
│  Phase 4: Detection Engineering (30 min - 1 hour)         │
│    - Create YARA rules                                     │
│    - Generate IOCs                                         │
│    - Write detection guidance                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Teaching Slide 5: Vulnerability Research Decision Tree

```
                 +--------------------------+
                 |  User-controlled input?  |
                 +--------------------------+
                           |
            Yes            |            No
              |            |              |
              v            |              v
    +-----------------+    |    +-----------------+
    |  Trace to sink  |    |    |   Not likely    |
    +-----------------+    |    |   vulnerable    |
              |            |    +-----------------+
              v            |
    +-----------------+    |
    |  Dangerous      |    |
    |  function?      |    |
    +-----------------+    |
              |            |
       Yes    |    No      |
        |     |     |      |
        v     |     v      |
    +-----------------+    |
    |   Is there      |    |
    |   bounds        |    |
    |   checking?     |    |
    +-----------------+    |
              |            |
      No      |      Yes   |
        |     |     |      |
        v     |     v      |
    +-----------------+    |
    |   Vulnerable!   |    |
    |   Exploit       |    |
    +-----------------+    |
```

---

## APPENDIX: SLIDE TIMING RECOMMENDATIONS

### Full Course (4 Parts + Appendices + Primers)
- **Total Duration:** 8-12 hours of instruction
- **Breakdown:**
  - Part 1: 2-3 hours
  - Part 2: 2-3 hours
  - Part 3: 2-3 hours
  - Part 4: 2-3 hours
  - Appendices: 1-2 hours (reference)
  - Primers: 2-3 hours (foundational)

### Workshop Format (5 Days)
- **Day 1:** Introduction + Part 1
- **Day 2:** Part 2
- **Day 3:** Part 3
- **Day 4:** Part 4
- **Day 5:** Primers + Appendices + Practice

### Lecture Format (Per Session)
- **Each Part:** 2-3 sessions of 50 minutes each
- **Session Structure:**
  - 10 min: Review previous concepts
  - 30 min: New material
  - 10 min: Live demonstration
  - 10 min: Q&A

---

## COMPLETE SLIDE INDEX

### Section 0: Introduction (Slides 0.1-0.13)
### Section 1: Part 1 (Slides 1.0-1.22)
### Section 2: Part 2 (Slides 2.0-2.17)
### Section 3: Part 3 (Slides 3.0-3.37)
### Section 4: Part 4 (Slides 4.0-4.31)
### Section 5: Appendices (Slides A.0-A.7)
### Section 6: Primers (Slides P.0-P.5)
### Section 7: Conclusion (Slides 7.0-7.6)

**Total Slides: Approximately 200+**

---

## READY TO USE CONTENT

This slide outline is designed to be:
- **Comprehensive:** Covers every major topic in the series
- **Extensive:** Each slide provides complete information
- **Expanded:** Additional teaching materials and resources
- **Flexible:** Can be adapted for different formats and audiences
- **Practical:** Includes examples, analogies, and teaching aids

**Using This Outline:**
1. Create slides from each point
2. Add screenshots from Ghidra
3. Include code snippets as shown
4. Add speaker notes for complex topics
5. Include interactive examples

**Happy Teaching!**
