# Primer 5: Reverse Engineering Workflows and Methodology

Welcome to the fifth and final primer of our "Zero to Hero" series. This primer provides a comprehensive, beginner-friendly guide to developing effective reverse engineering workflows and methodologies. Having learned the tools (Ghidra), the languages (assembly), and the formats (PE/ELF), you now need a systematic approach to applying these skills. Think of this primer as learning how to be a detective—not just having the forensic tools, but knowing how to use them in the right order to solve the case.

---

## P5.1: The Reverse Engineering Mindset

### P5.1.1: Thinking Like a Detective

**Reverse engineering is detective work.** You have a piece of evidence (the binary) and you need to understand what happened (what it does, how it works, who wrote it).

**The Detective's Process:**
1. **Assess the scene:** What are you dealing with? (File type, size, packing)
2. **Collect evidence:** Extract strings, imports, and surface-level information
3. **Form hypotheses:** What might this program do?
4. **Investigate:** Deep analysis to confirm or refute hypotheses
5. **Build a case:** Document findings, create IOCs, generate reports

**The Detective's Mindset:**
- **Curiosity:** Always ask "why" and "how"
- **Skepticism:** Don't trust surface-level information
- **Patience:** Some investigations take hours or days
- **Methodical:** Follow a systematic process
- **Documentation:** Write everything down

### P5.1.2: Levels of Understanding

**Level 1: What does it do?**
- High-level behavior
- Purpose of the program
- Major functions

**Level 2: How does it work?**
- Algorithms and logic
- Data flow
- Control flow

**Level 3: Why was it written this way?**
- Programmer intent
- Security measures
- Obfuscation techniques

**Level 4: How can it be defeated?**
- Vulnerabilities
- Patching opportunities
- Exploitation vectors

### P5.1.3: Common Goals

| Goal | Approach | Output |
|------|----------|--------|
| **Malware Analysis** | Identify malicious behavior, extract IOCs | YARA rules, detection signatures |
| **CTF Challenges** | Find the flag or secret | The flag itself |
| **Vulnerability Research** | Find security flaws | Exploit primitives, patch information |
| **Software Auditing** | Verify security of compiled code | Security assessment report |
| **Interoperability** | Understand undocumented functionality | API documentation, protocol decryption |
| **Patching** | Modify program behavior | Patched binary, keygen |

---

## P5.2: The Analysis Pipeline

### P5.2.1: Overview

```
+------------------+
|  Phase 1: Triage |  <- 5-15 minutes
+------------------+
         ↓
+------------------+
|  Phase 2: Scoping|  <- 15-30 minutes
+------------------+
         ↓
+------------------+
| Phase 3: Deep Dive|  <- Hours to days
+------------------+
         ↓
+------------------+
| Phase 4: Reporting|  <- 30 minutes to hours
+------------------+
```

### P5.2.2: Phase 1: Triage

**Goal:** Quickly understand what you're dealing with.

**Activities:**
1. **File identification:** `file`, `readelf`, or Ghidra import
2. **String extraction:** `strings`, Ghidra's Defined Strings
3. **Basic analysis:** Size, entropy, sections, imports
4. **Initial hypothesis:** What kind of program is this?

**Triage Checklist:**

| Item | Tool | What to Look For |
|------|------|------------------|
| File type | `file` | ELF, PE, Mach-O, script |
| File size | `ls -lh` | Large = may contain embedded data |
| Stripped | `file` | Stripped = harder to analyze |
| Strings | `strings` | URLs, domains, error messages, function names |
| Imports | `readelf -d`, `dumpbin /IMPORTS` | System functions used |
| Sections | `readelf -S`, `dumpbin /SECTIONS` | Suspicious section names |
| Entropy | Custom script | > 7.5 = likely packed |

**Output:** Triage report (1 page)

### P5.2.3: Phase 2: Scoping

**Goal:** Identify key areas for deeper analysis.

**Activities:**
1. **Initial Ghidra import:** Run full analysis
2. **Find entry point:** Where does execution start?
3. **Find main function:** Where is the program logic?
4. **Identify interesting functions:** Strings, imports, suspicious patterns
5. **Map program structure:** Call graph, data flow

**Scoping Checklist:**

| Item | Ghidra Feature | What to Look For |
|------|----------------|------------------|
| Entry point | Program Trees | Where execution starts |
| Main function | Symbol Tree, XREFs | Program's core logic |
| Interesting strings | Defined Strings | URLs, domains, passwords |
| Suspicious functions | Symbol Tree | Anti-analysis, networking, registry |
| Call graph | Window → Call Graph | Function relationships |
| Data flow | XREFs | How data moves through the program |

**Output:** List of key functions and areas of interest

### P5.2.4: Phase 3: Deep Dive

**Goal:** Understand the program in detail.

**Activities:**
1. **Analyze key functions:** Decompile, rename, annotate
2. **Trace data flow:** From input to output
3. **Understand algorithms:** Recover encryption, validation, etc.
4. **Identify vulnerabilities:** Buffer overflows, format strings, etc.
5. **Extract secrets:** Passwords, keys, flags
6. **Create automation:** Scripts for IOCs, decryption, etc.

**Deep Dive Checklist:**

| Activity | Approach | Output |
|----------|----------|--------|
| Function Analysis | Decompile, rename variables, add comments | Annotated code |
| Data Flow | XREFs, taint tracking | Data flow diagrams |
| Algorithm Recovery | Reverse engineer logic | Algorithm documentation |
| Vulnerability Discovery | Manual review, automated scanning | Vulnerability list |
| Secret Extraction | Manual analysis, scripts | Keys, passwords, flags |
| Automation | Ghidra Python scripts | Reusable scripts |

**Output:** Detailed analysis of each key function

### P5.2.5: Phase 4: Reporting

**Goal:** Document findings for yourself or others.

**Activities:**
1. **Summarize findings:** What does the program do?
2. **Document key functions:** What each major function does
3. **List IOCs:** Domains, IPs, file paths, registry keys
4. **Create YARA rules:** Detection signatures
5. **Generate final report:** Structured documentation

**Report Template:**

```
EXECUTIVE SUMMARY
- What the program does
- Major findings
- Risk level

DETAILED ANALYSIS
- File information
- Entry point and main function
- Key functions with annotations
- Algorithm descriptions
- Vulnerability details

INDICATORS OF COMPROMISE
- Domains
- IPs
- File paths
- Registry keys
- YARA rules

RECOMMENDATIONS
- Mitigation steps
- Detection guidance
- Next steps
```

---

## P5.3: Analysis Techniques

### P5.3.1: Top-Down Analysis

**Start from the entry point and follow execution.**

```
Entry Point → _start → main → function_calls → ...
```

**Pros:**
- Understands the program flow
- Catches hidden initialization code
- Natural flow of execution

**Cons:**
- May be complex for large programs
- Can get lost in deep call stacks

**When to use:** When you need to understand the full program flow

### P5.3.2: Bottom-Up Analysis

**Start from interesting points and work backward.**

```
Interesting String → XREFs → Function → Callers → ...
```

**Pros:**
- Focuses on suspicious areas
- Faster for malware analysis
- Directly addresses the hypothesis

**Cons:**
- May miss important context
- Can lead to tunnel vision

**When to use:** When you have a specific area of interest (e.g., a suspicious string)

### P5.3.3: Hybrid Approach

**Combine both techniques:**

1. **Top-down:** Understand overall program flow
2. **Bottom-up:** Investigate interesting areas
3. **Iterate:** Deepen understanding of key functions

**Recommended for most analyses.**

### P5.3.4: Function-Level Analysis

For each important function, analyze:

1. **Purpose:** What does the function do?
2. **Parameters:** What inputs does it take?
3. **Return value:** What does it return?
4. **Dependencies:** What other functions does it call?
5. **Callers:** What functions call it?
6. **Key logic:** What's the core algorithm?

**Template for Function Analysis:**

```
=== FUNCTION: [NAME] ===
Address: 0x00401120
Purpose: [What it does]
Parameters:
  - int: [Description]
  - char*: [Description]
Returns: int ([Description])

Key Logic:
  [Summary of algorithm]

Calls:
  - [Function1] (Purpose)
  - [Function2] (Purpose)

Called By:
  - [Function3] (Purpose)
  - [Function4] (Purpose)

Notes:
  [Any additional observations]
```

---

## P5.4: CTF Challenge Workflow

### P5.4.1: The CTF Lifecycle

```
+------------------+
|  Read Challenge  |  <- Understand the problem
+------------------+
         ↓
+------------------+
|  Download Binary |  <- Get the file
+------------------+
         ↓
+------------------+
|    Initial Scan  |  <- Triage
+------------------+
         ↓
+------------------+
| Import to Ghidra |  <- Analysis
+------------------+
         ↓
+------------------+
|   Find the Flag  |  <- Solve
+------------------+
         ↓
+------------------+
|   Submit Flag    |  <- Victory!
+------------------+
```

### P5.4.2: CTF-Specific Techniques

| Technique | Description | When to Use |
|-----------|-------------|-------------|
| **String Search** | Look for flag patterns | Always first |
| **XOR Decryption** | Find XOR loops | Obfuscated strings |
| **Algorithm Recovery** | Reverse complex logic | Serial validation |
| **Binary Patching** | Modify program behavior | Authentication bypass |
| **Keygen Creation** | Generate valid inputs | Software protection |

### P5.4.3: CTF Example Workflow

**Challenge:** "Find the flag in this binary"

**Step 1: Triage**
```bash
file challenge
strings challenge | grep FLAG
```

**Step 2: Ghidra Import**
- Import binary
- Run analysis
- Find main function

**Step 3: Locate Flag Logic**
- Search for "FLAG" or "flag"
- Find where it's printed
- Trace back to generation logic

**Step 4: Understand Encryption**
- Identify XOR/key operations
- Reverse the algorithm
- Write decryption script

**Step 5: Extract Flag**
```python
# Decryption script
encrypted = [...]
key = 0x5A
flag = ''.join(chr(b ^ key) for b in encrypted)
print(flag)
```

---

## P5.5: Malware Analysis Workflow

### P5.5.1: Safety First

**Critical Safety Rules:**

| Rule | Why | What to Do |
|------|-----|------------|
| **Never execute** | Malware can infect your system | Use static analysis only |
| **Isolated environment** | Prevent accidental execution | Use a VM |
| **No network** | Prevent C2 communication | Disable VM networking |
| **No USB passthrough** | Prevent infection spread | Block USB access |
| **Hash everything** | Track samples | `md5sum`, `sha256sum` |

### P5.5.2: Malware Analysis Pipeline

**Phase 1: Triage**
- File type, size, entropy
- Strings, imports, sections
- Determine if malicious

**Phase 2: Static Analysis**
- Import to Ghidra
- Identify suspicious functions
- Extract IOCs
- Understand behavior

**Phase 3: Behavior Analysis**
- What does it do?
- How does it persist?
- How does it communicate?

**Phase 4: Detection Engineering**
- Create YARA rules
- Generate IOCs
- Write detection guidance

### P5.5.3: Malware-Specific Patterns

| Pattern | What to Look For | Why |
|---------|------------------|-----|
| **String Obfuscation** | XOR loops, decryption routines | Hides C2 domains |
| **Process Injection** | `VirtualAllocEx`, `WriteProcessMemory`, `CreateRemoteThread` | Hides in other processes |
| **Persistence** | Registry Run keys, scheduled tasks | Survives reboot |
| **C2 Communication** | `socket`, `connect`, `send`, `recv` | Talks to attacker |
| **Anti-Analysis** | `IsDebuggerPresent`, timing checks | Evades detection |
| **Packing** | High entropy, strange sections | Hides true code |

---

## P5.6: Vulnerability Research Workflow

### P5.6.1: The Vulnerability Discovery Process

```
+------------------+
|  Identify Surface |  <- What inputs can the attacker control?
+------------------+
         ↓
+------------------+
|  Trace Data Flow  |  <- Where does the input go?
+------------------+
         ↓
+------------------+
|  Identify Sinks   |  <- Dangerous functions (strcpy, etc.)
+------------------+
         ↓
+------------------+
|  Verify Exploitable| <- Can we control execution?
+------------------+
         ↓
+------------------+
|  Build Exploit    |  <- Proof of concept
+------------------+
```

### P5.6.2: Common Vulnerability Patterns

| Vulnerability | Assembly Pattern | Ghidra Detection |
|---------------|------------------|------------------|
| **Buffer Overflow** | `strcpy` to small buffer | Decompiler shows unsafe function |
| **Format String** | `printf(user_input)` | User input as format string |
| **Integer Overflow** | `imul` without bounds | Multiplication with user input |
| **Use-After-Free** | `free` then `mov` to freed memory | Free followed by use |
| **Race Condition** | Multiple threads accessing shared data | Complex multithreading |

### P5.6.3: Vulnerability Research Example

**Step 1: Identify Input Surface**
- Network input (`recv`, `read`)
- File input (`fread`, `fgets`)
- Command-line arguments (`argv`)

**Step 2: Trace Data Flow**
```python
# Find all data sources
sources = ['recv', 'read', 'fgets', 'scanf']
# Find all dangerous sinks
sinks = ['strcpy', 'sprintf', 'strcat', 'gets']
# Trace from sources to sinks
```

**Step 3: Analyze Sinks**
- Where is user input copied?
- Is there bounds checking?
- What's the buffer size?
- Can we overflow?

**Step 4: Verify Exploitability**
- Calculate overflow size
- Determine offset to return address
- Test with controlled input

**Step 5: Build Exploit**
```python
# Generate exploit payload
payload = b'A' * 80        # Fill buffer
payload += b'\x01'         # Overwrite authenticated flag
payload += b'B' * 7        # Padding
payload += b'C' * 8        # Overwrite RBP
payload += struct.pack('<Q', shellcode_address)  # Overwrite return address
```

---

## P5.7: Documentation and Reporting

### P5.7.1: Why Document?

| Reason | Benefit |
|--------|---------|
| **Memory** | You won't remember everything |
| **Shareability** | Others can use your work |
| **Professionalism** | Required for reports |
| **Legal** | Evidence for investigations |

### P5.7.2: What to Document

**For Each Binary:**
- File hashes (MD5, SHA256)
- File size, type, architecture
- Compilation timestamp
- Packer information (if any)

**For Each Function:**
- Name (renamed if possible)
- Address
- Purpose
- Parameters and return type
- Key logic
- Dependencies

**For Each IOC:**
- Domain or IP address
- File path or registry key
- When it was observed
- How it's used

**For Each Vulnerability:**
- Location (file, function, address)
- Type (buffer overflow, format string, etc.)
- Severity (High/Medium/Low)
- Exploitability (Easy/Moderate/Hard)
- Proof of concept

### P5.7.3: Report Templates

**Executive Summary Template:**
```
== EXECUTIVE SUMMARY ==

Binary: [name]
Type: [ELF/PE/Mach-O]
Size: [size]
Hash: [SHA256]

Overview:
[1-2 sentence description of what the program does]

Key Findings:
- Finding 1
- Finding 2
- Finding 3

Risk Level: [High/Medium/Low]

Recommendations:
- Recommendation 1
- Recommendation 2
```

**Detailed Analysis Template:**
```
== DETAILED ANALYSIS ==

[Program Name]
[Date]

=== FILE INFORMATION ===
- Type: [ELF 64-bit]
- Size: [45K]
- SHA256: [hash]
- Stripped: [Yes/No]

=== ENTRY POINT ===
- Address: [0x00401000]
- Description: [What happens at entry point]

=== MAIN FUNCTION ===
- Address: [0x00401120]
- Purpose: [Core program logic]

=== KEY FUNCTIONS ===
[Function 1]
- Address: [0x00401200]
- Purpose: [Description]
- Parameters: [List]
- Returns: [Type]

[Function 2]
- Address: [0x00401300]
- Purpose: [Description]
- Parameters: [List]
- Returns: [Type]

=== INDICATORS OF COMPROMISE ===
- Domains: [list]
- IPs: [list]
- File paths: [list]
- Registry keys: [list]

=== YARA RULES ===
[Rule content]

=== RECOMMENDATIONS ===
1. [Recommendation]
2. [Recommendation]
```

---

## P5.8: Time Management and Prioritization

### P5.8.1: The 80/20 Rule

**80% of results come from 20% of the effort.**

| Effort | Result | Example |
|--------|--------|---------|
| 20% | 80% of understanding | Triage, main functions |
| 80% | 20% of understanding | Obscure edge cases |

**Apply the Rule:**
1. Focus on high-impact areas
2. Don't get lost in details
3. Revisit later if time permits

### P5.8.2: Prioritization Matrix

| | High Impact | Low Impact |
|--|-------------|------------|
| **High Effort** | Deep dive key functions | Skip or postpone |
| **Low Effort** | Quick wins (strings, IOCs) | Note and move on |

### P5.8.3: When to Stop

**Signs you should stop analyzing a function:**
- It's a library function
- It's not relevant to your goal
- It's heavily obfuscated
- You've already extracted the key information

**Signs you should continue:**
- It's critical to program logic
- It contains suspicious behavior
- It's been identified as a vulnerability

---

## P5.9: Common Mistakes and How to Avoid Them

### P5.9.1: Analysis Mistakes

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| **Tunnel Vision** | Focusing on one area too long | Step back, reassess |
| **Overcomplicating** | Assuming it's more complex than it is | Start with simple explanations |
| **Underestimating** | Dismissing something as "just a library function" | Check everything |
| **Skipping Triage** | Going straight to Ghidra | Always start with strings and file info |
| **Ignoring Context** | Analyzing in isolation | Consider what the program does |

### P5.9.2: Scripting Mistakes

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| **No Error Handling** | Memory access can fail | Use try/except |
| **Overengineering** | Writing complex scripts for simple tasks | Start simple, add complexity as needed |
| **Undocumented** | No comments or docstrings | Comment your code |
| **One-Time Use** | Not reusable | Write general-purpose scripts |
| **Performance Issues** | Inefficient code | Use profiling, optimize hot spots |

---

## P5.10: Practice Exercise

### P5.10.1: The Exercise

You've been given a binary. Apply the full workflow to analyze it.

**Binary:** `analysis_practice` (ELF 64-bit)

**Goal:** Determine what it does and find the hidden secret.

### P5.10.2: Your Workflow

**Step 1: Triage (5 minutes)**

```bash
# File information
file analysis_practice

# Strings
strings analysis_practice | head -50

# Entropy
python3 -c "
import sys, math
data = open('analysis_practice', 'rb').read()
entropy = -sum((data.count(b)/len(data)) * math.log2(data.count(b)/len(data)) for b in set(data))
print(f'Entropy: {entropy:.3f}')
"
```

**Step 2: Scoping (15 minutes)**
1. Import to Ghidra
2. Find entry point and main function
3. Identify interesting strings and functions
4. Map the call graph

**Step 3: Deep Dive (45 minutes)**
1. Analyze main function
2. Analyze interesting functions
3. Trace data flow for secrets
4. Write decryption script if needed

**Step 4: Reporting (15 minutes)**
1. Document findings
2. Extract IOCs
3. Create a short report

---

## P5.11: Summary and Key Takeaways

### P5.11.1: The Core Workflow

1. **Triage:** Understand what you're dealing with
2. **Scope:** Identify key areas
3. **Deep Dive:** Analyze in detail
4. **Report:** Document findings

### P5.11.2: Key Principles

1. **Be methodical:** Follow a systematic process
2. **Be flexible:** Adapt to what you find
3. **Be skeptical:** Verify everything
4. **Be curious:** Always ask "why"
5. **Be patient:** Some analyses take time

### P5.11.3: Essential Tools

| Tool | Use |
|------|-----|
| `file` | File identification |
| `strings` | String extraction |
| `readelf` / `dumpbin` | Header inspection |
| `hexdump` / `xxd` | Hex viewing |
| **Ghidra** | Main analysis |
| **Python** | Automation and scripting |
| **YARA** | Detection rule creation |

---

## P5.12: Quick Reference Card

### Analysis Workflow Summary

| Phase | Activities | Duration |
|-------|------------|----------|
| **Triage** | `file`, `strings`, `readelf`, entropy | 5-15 min |
| **Scoping** | Ghidra import, main function, interesting areas | 15-30 min |
| **Deep Dive** | Function analysis, data flow, algorithm recovery | Hours-days |
| **Reporting** | Document, IOCs, YARA rules | 30 min-hours |

### When to Use Different Approaches

| Approach | Use Case | Description |
|----------|----------|-------------|
| **Top-Down** | Understanding full program | Start at entry point, follow execution |
| **Bottom-Up** | Investigating specific area | Start at interesting string/function |
| **Hybrid** | Most analyses | Combine both techniques |

### Common Analysis Priorities

| Priority | What to Analyze | Why |
|----------|-----------------|-----|
| **High** | Main function | Core logic |
| **High** | Interesting strings | User-visible behavior |
| **High** | Suspicious imports | Malicious behavior |
| **Medium** | Cryptography | Secret recovery |
| **Medium** | Data sections | Hidden data |
| **Low** | Library functions | Usually known |

---

**[END OF PRIMER 5]**

**[END OF ALL PRIMERS]**

---

## Series Conclusion

Congratulations! You've completed all five primers of the "Zero to Hero" series:

1. **Primer 1:** Understanding Machine Code, Assembly, and Decompilation
2. **Primer 2:** Understanding Executable File Formats (PE and ELF)
3. **Primer 3:** Common Assembly Patterns for Reverse Engineers
4. **Primer 4:** Ghidra Scripting Fundamentals
5. **Primer 5:** Reverse Engineering Workflows and Methodology

You now have a comprehensive foundation in reverse engineering. You understand:

- What machine code and assembly are
- How executables are structured
- Common assembly patterns
- How to script in Ghidra
- How to approach reverse engineering systematically

**What's Next?**

Return to the main series: **Part 1: Foundations, Tooling, and Your First Binary** and apply everything you've learned in the primers. The primers have given you the theory—now it's time to practice.

**Remember:** Reverse engineering is a skill that improves with practice. Start with simple programs, gradually tackle more complex binaries, and never stop learning.

**Happy reversing!**
