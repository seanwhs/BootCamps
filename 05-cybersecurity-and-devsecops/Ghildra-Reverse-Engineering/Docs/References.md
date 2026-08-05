# References and Resources

## Complete Reference Guide for Reverse Engineering with Ghidra

---

## Part 1: Official Ghidra Resources

### Ghidra Project Home and Official Documentation

The primary source for Ghidra is maintained by the National Security Agency Research Directorate. Ghidra is a software reverse engineering framework that includes full-featured analysis tools for disassembly, assembly, decompilation, graphing, and scripting across multiple platforms.

**Official Resources:**

| Resource | Description | URL |
|----------|-------------|-----|
| **Ghidra Official Site** | Main project page and downloads | https://ghidra-sre.org/ |
| **GitHub Repository** | Source code, issues, releases | https://github.com/NationalSecurityAgency/ghidra |
| **Security Advisories** | Known vulnerabilities in Ghidra versions | Read before installation |
| **Getting Started Guide** | Installation and basic usage | Included in Ghidra distribution |

**Installation Requirements:**
- JDK 21 64-bit (latest requirement)
- Download the official multi-platform release file named `ghidra_<version>_<release>_<date>.zip`
- Launch with `./ghidraRun` (Linux/macOS) or `ghidraRun.bat` (Windows)

**Security Warning:** There are known security vulnerabilities within certain versions of Ghidra. Before proceeding, review Ghidra's Security Advisories.

---

### Ghidra Scripting and API Documentation

**Official API Resources:**

| Resource | Description |
|----------|-------------|
| **Ghidra API Javadoc** | Complete Java API reference |
| **GhidraDev Eclipse Plugin** | Development environment for scripting |
| **Python Scripting (Jython)** | Python 2.7 scripting support |
| **PyGhidra** | Native Python 3 scripting with full API access |

**Python Scripting in Ghidra:**

Ghidra supports Python through two mechanisms:

1. **Jython (Python 2.7):** Traditional Ghidra scripting, automatically available

2. **PyGhidra (Python 3):** Modern native CPython 3 with JPype for Java interoperability

**Script Metadata Example:**
```python
## ###
# Description of what this script does
# @category Examples
# @author Your Name
# @keybinding F6
# @runtime Jython  # or PyGhidra
```

**Available State Variables:**
- `currentProgram` - The active program
- `currentAddress` - Current cursor location
- `currentLocation` - Current program location
- `currentSelection` - Current selection
- `currentHighlight` - Current highlight

**Java Interoperability (PyGhidra):**
```python
# Import Java classes
from java.util import LinkedList, ArrayList
from ghidra.program.flatapi import FlatProgramAPI
from ghidra.program.model.listing import CodeUnit
from ghidra.program.model.symbol import SourceType
```

**Memory Access Examples:**
```python
# Read bytes
bytes_array = getBytes(addr, 16)
for b in bytes_array:
    print("%02x" % (b & 0xff))

# Write data (requires transaction)
tx_id = currentProgram.startTransaction("Write Data")
try:
    setByte(addr, 0x90)
    setInt(addr, 0x12345678)
    currentProgram.endTransaction(tx_id, True)
except:
    currentProgram.endTransaction(tx_id, False)
    raise
```

**FlatProgramAPI Methods:** All FlatProgramAPI methods are available directly in PyGhidra scripts, including `createLabel`, `createFunction`, `setEOLComment`, `disassemble`, `find`, and `findStrings`.

---

### Building Ghidra from Source

For advanced development, Ghidra can be built from source:

**Build Tools Required:**
- JDK 21 64-bit
- Gradle 8.5+
- Python3 (versions 3.9 to 3.14) with bundled pip
- GCC or Clang and make (Linux/macOS)
- Microsoft Visual Studio 2017+ or C++ Build Tools (Windows)

**Build Steps:**
```bash
# Clone repository
git clone https://github.com/NationalSecurityAgency/ghidra.git
cd ghidra

# Download dependencies
gradle -I gradle/support/fetchDependencies.gradle

# Create development build
gradle buildGhidra
```

---

## Part 2: Essential Books and Learning Resources

### Recommended Books

| Book | Author(s) | Focus | Level |
|------|-----------|-------|-------|
| **Ghidra Software Reverse-Engineering for Beginners, 2nd Edition** | David Álvarez Pérez, Ravikant Tiwari | Complete beginner-friendly guide with real-world malware analysis | Beginner to Intermediate |
| **The Complete Guide to Ghidra Reverse Engineering** | Jason K. Benitez | Disassembling, vulnerability discovery, and automation | All levels |
| **Ghidra Unleashed: Open-Source Reverse Engineering for Hackers** | Various | Fun, accessible approach with practical case studies | Beginner to Intermediate |

**Key Content from "Ghidra Software Reverse-Engineering for Beginners - 2nd Edition":**
- Mastering Ghidra on Linux, Windows, and macOS
- Creating and utilizing plugins and custom scripting
- Analyzing complex malware and ransomware
- Binary diffing and headless mode
- Automated vulnerability detection in executable binaries

**Key Content from "The Complete Guide to Ghidra Reverse Engineering":**
- Navigating and mastering Ghidra's interface
- Step-by-step disassembly and decompilation
- Analyzing real-world malware and obfuscated binaries
- Scripting with Python and Java
- Patching and modifying executables

**Key Content from "Ghidra Unleashed":**
- Malware and packed binary analysis
- Firmware and IoT device reversing
- Vulnerability research and exploitation
- Custom plugin development
- Integration with Frida, IDA Pro, and Radare2

---

## Part 3: CTF Platforms and Practice Challenges

### Recommended CTF Resources

**PUXSY Reverse-Engineering CTF:**
- Repository: https://github.com/PUXSY/Reverse-Engineering-CTF
- 10 levels (Easy → Hard)
- Topics: string obfuscation, control flow, stack analysis, pointer math, import resolution, anti-debugging, loop unrolling, multi-layer obfuscation

**Recommended Tools for CTF Challenges:**
| Tool | Purpose |
|------|---------|
| **Ghidra** | Primary reverse engineering |
| **IDA Pro** | Alternative disassembler |
| **x64dbg** | Windows debugger |
| **GDB** | Linux debugger |

**picoCTF Writeup - Zero to Hero:**
A comprehensive heap exploitation challenge demonstrating:
- Tcache poisoning via poison null byte
- Arbitrary write through double-free
- `__free_hook` redirection to `win()` function
- Complete exploit walkthrough available on CTFtime

---

## Part 4: Malware Analysis Resources

### Malware Analysis Practice

**MetaCTF Flash CTF Examples:**

1. **License to Rev** - Binary license validation challenge:
   - ELF 64-bit analysis
   - Embedded ZIP extraction with `binwalk`
   - License file modification
   - Time manipulation with `libfaketime`

2. **Carrot** - Malware analysis challenge:
   - Stripped ELF binary with PIE enabled
   - Anti-debugging techniques (ptrace, timing checks)
   - RSA/AES encryption functions
   - Binary patching techniques

**Anti-Debugging Techniques Found in Carrot:**
- `ptrace` self-debugging detection
- Timing checks with `sleep()` and `time()`
- Check returns `true` only if elapsed time matches expected

**Patching Strategy:**
1. Locate the target instruction in Listing Window
2. Press `Ctrl+Shift+G` to patch
3. Change operand values or conditional jumps
4. Save changes

---

## Part 5: Online Courses and Training

### Cybersecurity and Reverse Engineering Courses

**Zero to Hero: Complete Cybersecurity Bootcamp 2025 (Part 1):**
- Udemy course covering:
  - Core cybersecurity concepts and threat types
  - Network traffic analysis using Wireshark
  - Linux and command-line tools
  - **Basic malware analysis and reverse engineering using Ghidra and PEStudio**
  - Ethical hacking with Metasploit and Burp Suite
  - Python automation for security tasks

**Course Features:**
- 8 lectures, 1 hour 15 minutes duration
- Designed for absolute beginners
- Practical, hands-on content
- Quizzes, coding exercises, and labs

---

## Part 6: Reference Sheets and Quick Access

### Ghidra Python Scripting Quick Reference

| Operation | Code |
|-----------|------|
| **Get current program** | `program = currentProgram` |
| **Get function manager** | `func_mgr = currentProgram.functionManager` |
| **Iterate functions** | `for func in func_mgr.getFunctions(True):` |
| **Get instruction at address** | `instr = getInstructionAt(addr)` |
| **Read bytes from memory** | `bytes_array = getBytes(addr, 16)` |
| **Write bytes to memory** | `setByte(addr, 0x90)` |
| **Create label** | `createLabel(addr, "my_label", True)` |
| **Get function at address** | `func = getFunctionAt(addr)` |
| **Find strings** | `strings = findStrings(None, 5, 1, True, False)` |

### Ghidra Script Metadata

| Directive | Description |
|-----------|-------------|
| `@category` | Organizes scripts in Script Manager |
| `@author` | Script author |
| `@keybinding` | Keyboard shortcut |
| `@menupath` | Menu location |
| `@runtime Jython` | Python 2.7 (default) |
| `@runtime PyGhidra` | Python 3 (native) |

---

## Part 7: Community and Additional Resources

### Community Forums and Discussion

| Platform | Purpose |
|----------|---------|
| **Ghidra GitHub Discussions** | User forum, Q&A |
| **r/ReverseEngineering** | Reddit community |
| **CTFtime** | CTF challenges and writeups |
| **MalwareBazaar** | Malware samples for practice |

### Additional Tools for Reverse Engineering

| Tool | Purpose |
|------|---------|
| **binwalk** | Extract embedded files from binaries |
| **libfaketime** | Manipulate system time for malware analysis |
| **x64dbg** | Windows debugger |
| **GDB** | Linux debugger |

---

## Part 8: Summary of Key Links

### Most Important Links

| Resource | Link |
|----------|------|
| **Ghidra Official** | https://ghidra-sre.org/ |
| **Ghidra GitHub** | https://github.com/NationalSecurityAgency/ghidra |
| **Ghidra API Docs** | Included in Ghidra installation |
| **PyGhidra Documentation** | https://mintlify.com/NationalSecurityAgency/ghidra/llms.txt |
| **CTF Challenge Repository** | https://github.com/PUXSY/Reverse-Engineering-CTF |

---

**[END OF REFERENCES AND RESOURCES]**
