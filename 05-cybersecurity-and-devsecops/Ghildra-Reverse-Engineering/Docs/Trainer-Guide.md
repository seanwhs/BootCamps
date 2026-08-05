# Zero to Hero: Practical Reverse Engineering with Ghidra

## Comprehensive Trainer Guide

### Complete Instructor Resource for Delivering the Course

---

# Table of Contents

**Section 1: Course Overview and Planning**
- 1.1 Course at a Glance
- 1.2 Course Philosophy
- 1.3 Target Audience and Prerequisites
- 1.4 Learning Objectives by Module
- 1.5 Schedule and Pacing Guide
- 1.6 Materials and Equipment Checklist

**Section 2: Course Delivery Guide**
- 2.1 Teaching Methodology
- 2.2 Module-by-Module Delivery Notes
- 2.3 Common Student Challenges and Solutions
- 2.4 Classroom Management Tips
- 2.5 Remote/Online Teaching Adaptations

**Section 3: Hands-On Lab Guide**
- 3.1 Lab Setup Instructions
- 3.2 Lab Execution Guide
- 3.3 Lab Solutions and Common Pitfalls
- 3.4 Alternative Lab Configurations

**Section 4: Assessment Guide**
- 4.1 Formative Assessment Strategies
- 4.2 Summative Assessment Guide
- 4.3 Practical Skills Assessment
- 4.4 Grading Rubrics

**Section 5: Supplementary Resources**
- 5.1 Recommended Reading and References
- 5.2 Additional Exercises and Challenges
- 5.3 Sample Binaries and CTF Challenges
- 5.4 Scripts and Automation Tools

**Section 6: Troubleshooting and Support**
- 6.1 Common Technical Issues
- 6.2 Student Support Strategies
- 6.3 Frequently Asked Questions

**Appendices**
- A. Sample Course Syllabus
- B. Student Evaluation Forms
- C. Certificates and Completion Materials
- D. Quick Reference for Trainers

---

# Section 1: Course Overview and Planning

## 1.1 Course at a Glance

### Course Title
Zero to Hero: Practical Reverse Engineering with Ghidra

### Course Description
This comprehensive course takes students from complete beginners to proficient reverse engineers using Ghidra, the powerful open-source software reverse engineering framework developed by the NSA. Through hands-on labs, CTF challenges, and real-world case studies, students develop the skills needed to analyze, understand, and manipulate compiled software with confidence.

### Duration
- **Full Course:** 4 modules (approximately 8-12 hours of instruction)
- **Workshop Format:** 5 days (full-day sessions)
- **Bootcamp Format:** 2 weeks (half-day sessions)
- **Self-Paced:** 4-6 weeks (3-5 hours per week)

### Format Options
| Format | Duration | Best For |
|--------|----------|----------|
| **Full Course** | 8-12 hours | Comprehensive training |
| **5-Day Workshop** | 5 full days | Immersive, hands-on experience |
| **Weekly Classes** | 8-12 weeks | Working professionals |
| **Bootcamp** | 2 weeks (half-days) | Intensive, rapid learning |
| **Self-Paced** | 4-6 weeks | Independent learners |

### Prerequisites for Students
- Basic programming experience (any language)
- Command-line comfort
- Understanding of basic computer architecture
- (Recommended) C programming knowledge
- (Recommended) x86/x64 assembly familiarity

### Course Outcomes
By the end of this course, participants will be able to:
- Install and configure Ghidra for professional reverse engineering workflows
- Navigate Ghidra's interface efficiently
- Analyze simple binaries using disassembly and decompilation
- Solve CTF challenges and understand binary logic
- Perform static malware analysis
- Identify security vulnerabilities in compiled code
- Automate analysis tasks using Ghidra's Python API

---

## 1.2 Course Philosophy

### The "Zero to Hero" Approach
This course is built on the principle that reverse engineering is a learnable skill, not an innate talent. The approach is:

1. **Code-Heavy:** Every concept is reinforced with complete, working code
2. **Beginner-Friendly:** Complex terms defined the first time they appear
3. **Expert Inside:** Production-quality code and techniques
4. **Hands-On:** Students build everything themselves
5. **Progressive:** Each section builds on previous knowledge

### Teaching Philosophy
- **Practice Over Theory:** 70% hands-on, 30% explanation
- **Learn by Doing:** Students complete every exercise
- **Fail Fast, Learn Fast:** Mistakes are opportunities
- **Real-World Relevance:** Exercises mirror professional scenarios
- **Community Learning:** Encourage collaboration and discussion

### The "Manual-First" Principle
Industry expert courses emphasize starting with foundational manual skills before introducing advanced automation or AI assistance . This training follows that principle—students learn to understand and navigate binaries by hand before automating tasks with scripts.

---

## 1.3 Target Audience and Prerequisites

### Audience Profile
| Type | Characteristics | Motivation |
|------|-----------------|------------|
| **Cybersecurity Students** | Building practical skills | Career preparation |
| **Software Developers** | Understanding compiled code | Security awareness |
| **CTF Players** | Leveling up RE skills | Competition |
| **Malware Analysts** | Adding Ghidra to toolkit | Professional development |
| **Complete Beginners** | No prior RE experience | New skill acquisition |

### Prerequisites by Module

| Module | Programming | System Knowledge | Tools |
|--------|-------------|------------------|-------|
| 1: Foundations | Basic | Basic OS knowledge | JDK, Ghidra |
| 2: Interface | None | File navigation | Ghidra |
| 3: First Binary | Basic C | Compilation basics | Ghidra, GCC |
| 4: Scripting | Python basics | Scripting environment | Ghidra, Python |
| 5: Control Flow | Assembly (nice) | CPU architecture | Ghidra |
| 6: XREFs | None | Binary structure | Ghidra |
| 7: XOR | None | Binary operations | Ghidra, Python |
| 8: Patching | Assembly (nice) | Binary modification | Ghidra |
| 9: Malware | Assembly (nice) | OS security | Ghidra, YARA |
| 10: Vulnerabilities | C programming | Memory management | Ghidra |

---

## 1.4 Learning Objectives by Module

### Module 1: Foundations, Tooling, and Your First Binary
**Duration:** 2-3 hours

| Objective | Assessment |
|-----------|------------|
| Install and configure Ghidra | Successful launch and project creation |
| Understand executable formats (PE/ELF) | Identify format of given binary |
| Navigate Ghidra's interface | Complete navigation challenge |
| Analyze a simple C program | Rename variables and add comments |
| Write first Python script | Enumerate functions in a binary |

### Module 2: CTF Challenges and Binary Logic Analysis
**Duration:** 2-3 hours

| Objective | Assessment |
|-----------|------------|
| Analyze control flow | Identify basic blocks and branches |
| Use cross-references (XREFs) | Trace function calls and string usage |
| Recover XOR-encrypted secrets | Decrypt a hidden flag |
| Patch binaries | Bypass authentication check |
| Recover complex algorithms | Generate a valid serial number |

### Module 3: Malware Analysis and Payload Dissection
**Duration:** 2-3 hours

| Objective | Assessment |
|-----------|------------|
| Perform static triage | Complete triage checklist |
| Identify packing | Detect high entropy and suspicious sections |
| Extract IOCs | Document domains, IPs, registry keys |
| Analyze C2 communication | Identify C2 domain and protocol |
| Create YARA rules | Write detection rule for sample |

### Module 4: Vulnerability Research and Secure Code Auditing
**Duration:** 2-3 hours

| Objective | Assessment |
|-----------|------------|
| Understand memory corruption | Identify stack/ heap overflow |
| Trace data flow | Map source to sink |
| Detect unsafe functions | Find strcpy, sprintf, gets calls |
| Automate discovery | Write vulnerability scanner script |
| Evaluate mitigations | Recommend security fixes |

---

## 1.5 Schedule and Pacing Guide

### 5-Day Workshop Schedule

| Day | Morning (3 hours) | Afternoon (3 hours) |
|-----|-------------------|---------------------|
| **Day 1** | Module 1: Foundations (Installation, Interface) | Module 1: First Binary Analysis |
| **Day 2** | Module 2: Control Flow, XREFs | Module 2: XOR Decryption, Patching |
| **Day 3** | Module 3: Malware Triage, Packing | Module 3: IOC Extraction, YARA |
| **Day 4** | Module 4: Memory Corruption, Data Flow | Module 4: Vulnerability Discovery, Automation |
| **Day 5** | Comprehensive Project: "The Enigma Protocol" | Project Completion, Review, Q&A |

### 8-Week Class Schedule (2 hours/week)

| Week | Module | Focus |
|------|--------|-------|
| 1 | Introduction + Module 1.1 | Ghidra installation, JDK setup |
| 2 | Module 1.2-1.3 | Interface navigation, executable formats |
| 3 | Module 1.4-1.5 | First binary analysis, scripting basics |
| 4 | Module 2.1-2.3 | Control flow, XREFs, XOR decryption |
| 5 | Module 2.4-2.5 | Binary patching, algorithm recovery |
| 6 | Module 3.1-3.3 | Malware triage, behavior analysis, IOCs |
| 7 | Module 4.1-4.3 | Memory corruption, data flow, vulnerability discovery |
| 8 | Final Project | "The Enigma Protocol" challenge |

### 2-Week Bootcamp Schedule

| Day | Morning (3 hrs) | Afternoon (3 hrs) |
|-----|-----------------|-------------------|
| 1 | Foundation I: Installation, Interface | Foundation II: First Binary Analysis |
| 2 | Core Analysis I: Control Flow, XREFs | Core Analysis II: XOR Decryption |
| 3 | Core Analysis III: Binary Patching | CTF Challenge Lab |
| 4 | Malware Analysis I: Triage, Packing | Malware Analysis II: IOCs, YARA |
| 5 | Vulnerability Research I: Memory Corruption | Vulnerability Research II: Discovery |
| 6 | Advanced Scripting | Malware Analysis III: Advanced |
| 7 | CTF Challenge Lab | Vulnerability Research Lab |
| 8 | Comprehensive Project | Final Review and Assessment |
| 9 | Capstone Project Work | Capstone Project Work |
| 10 | Capstone Presentations | Course Wrap-up |

---

## 1.6 Materials and Equipment Checklist

### Instructor Materials

**Hardware:**
- [ ] Computer with 16GB+ RAM (Ghidra requires significant memory)
- [ ] Secondary monitor (for demonstration)
- [ ] Projector or large display
- [ ] Audio system (for remote sessions)
- [ ] Backup computer (recommended)

**Software:**
- [ ] JDK 17 or later installed
- [ ] Ghidra (latest stable version)
- [ ] Python 3 installed
- [ ] IDE/Text Editor (VS Code, Sublime, etc.)
- [ ] Virtualization software (VMWare, VirtualBox)
- [ ] Sample binaries (calculator, malware, CTF challenges)

**Documentation:**
- [ ] Slide decks for all modules
- [ ] Student workbooks (printed or digital)
- [ ] Lab guide and solutions
- [ ] Quiz and test bank
- [ ] Student notes template
- [ ] Evaluation forms

**Backup Materials:**
- [ ] USB drive with all course materials
- [ ] Cloud backup of materials
- [ ] Virtual machine images with pre-configured Ghidra
- [ ] Printed copies of key reference materials

### Student Materials (Per Student)

**Software Required:**
- [ ] JDK 17 or later
- [ ] Ghidra installation
- [ ] Python 3
- [ ] Text editor/IDE
- [ ] C compiler (GCC/MinGW)
- [ ] Command line/terminal access

**Hardware Required:**
- [ ] Computer with 8GB+ RAM (16GB recommended)
- [ ] 64-bit operating system
- [ ] 10GB+ free disk space
- [ ] Internet access (for downloads)

**Resources Provided:**
- [ ] Student workbook
- [ ] Quick reference cards
- [ ] Cheat sheets (assembly, API, shortcuts)
- [ ] Sample binaries
- [ ] Virtual machine image (optional)

---

# Section 2: Course Delivery Guide

## 2.1 Teaching Methodology

### The "4-Step Learning Cycle"

| Step | Description | Time Allocation |
|------|-------------|-----------------|
| **1. Explain** | Present concept with analogy and examples | 20% |
| **2. Demonstrate** | Live demo in Ghidra | 20% |
| **3. Practice** | Students follow along step-by-step | 40% |
| **4. Apply** | Independent exercise or challenge | 20% |

### Effective Teaching Techniques

**For Concept Explanation:**
- Use real-world analogies (e.g., "Think of memory like library shelves")
- Define all technical terms the first time they appear
- Connect new concepts to previously learned material
- Use diagrams and visual aids

**For Demonstrations:**
- Walk through examples slowly
- Narrate each action and explain why it's being done
- Show both success and failure cases
- Pause for questions after each major step

**For Practice Sessions:**
- Provide clear step-by-step instructions
- Circulate to help struggling students
- Encourage peer-to-peer support
- Address common mistakes proactively

**For Application Exercises:**
- Start with simpler challenges and increase difficulty
- Allow students to work independently or in pairs
- Provide hints rather than full solutions
- Review solutions together as a class

### Classroom Management Tips

**For Live Instruction:**
- Start each session with a 5-minute review
- Ask "check-in" questions to gauge understanding
- Use a "parking lot" for off-topic questions
- Schedule short breaks every 50-60 minutes

**For Remote Instruction:**
- Use chat for questions (less disruptive)
- Use polls for quick comprehension checks
- Share screen with clear, large text
- Record sessions for students to review
- Use breakout rooms for pair programming

**For Mixed-Level Classes:**
- Provide extension challenges for advanced students
- Offer additional support for beginners
- Use peer mentoring when appropriate
- Adjust pacing based on class progress

---

## 2.2 Module-by-Module Delivery Notes

### Module 1: Foundations, Tooling, and Your First Binary

**Key Points to Emphasize:**
- Ghidra requires JDK, not just JRE
- Projects save all analysis work
- Understand the difference between PE and ELF
- The decompiler is a tool, not magic

**Common Student Questions:**
- "Why do I need the JDK, not just JRE?" (Development tools needed for scripting)
- "Can I use an older version of Java?" (No, JDK 17+ required)
- "Why can't I see source code?" (The code is compiled)

**Demonstration Tips:**
- Show the Hello World program compilation
- Import and analyze with all options
- Navigate between Listing and Decompiler
- Rename a variable and show the effect

### Module 2: CTF Challenges and Binary Logic Analysis

**Key Points to Emphasize:**
- Control flow is the roadmap of execution
- XREFs reveal hidden relationships
- XOR is symmetric encryption/decryption
- Patching is surgery on the binary

**Common Student Questions:**
- "How do I know if it's a loop or branch?" (Look for backward jumps)
- "What's the difference between JG and JA?" (Signed vs. unsigned)
- "How do I find the XOR key?" (Look for XOR with constant)
- "Will patching break the binary?" (Possibly, test carefully)

**Demonstration Tips:**
- Show basic blocks in validate_access
- Trace "Access granted!" to validate_access
- Decrypt the XOR-protected flag
- Patch the authentication check

### Module 3: Malware Analysis

**Key Points to Emphasize:**
- Never execute malware samples
- Triage is the first line of defense
- IOCs are the breadcrumbs of an attack
- YARA rules are the fingerprints of malware

**Common Student Questions:**
- "Can I analyze malware on my main machine?" (No, use a VM)
- "How do I know if it's packed?" (Check entropy, section names)
- "What's the difference between static and dynamic analysis?" (Execution vs. no execution)
- "How do I create a YARA rule?" (Extract unique strings/patterns)

**Demonstration Tips:**
- Show file command, strings, entropy
- Import malware into Ghidra
- Extract IOCs from the sample
- Write a YARA rule

### Module 4: Vulnerability Research

**Key Points to Emphasize:**
- Memory corruption is a class of vulnerabilities
- Data flow is the journey of input
- Unsafe functions are the enemy
- Automation is the future

**Common Student Questions:**
- "What's the difference between stack and heap overflow?" (Memory location)
- "How do I find unsafe functions?" (Look for strcpy, sprintf, gets)
- "What's a format string vulnerability?" (User input as format specifier)
- "Can I automate vulnerability discovery?" (Yes, with scripts)

**Demonstration Tips:**
- Show stack overflow in validate_access
- Trace data flow from source to sink
- Write a vulnerability scanner script
- Show the difference between strcpy and strncpy

---

## 2.3 Common Student Challenges and Solutions

### Challenge 1: Java Installation Issues

| Issue | Solution |
|-------|----------|
| **"java: command not found"** | Install JDK and set PATH |
| **"javac: command not found"** | Install JDK (not just JRE) |
| **"Wrong Java version"** | Check with `java -version` |
| **"JAVA_HOME not set"** | Set environment variable |

**Instructor Tip:** Show students how to verify Java with `java -version` and `javac -version` before installing Ghidra.

### Challenge 2: Ghidra Won't Launch

| Issue | Solution |
|-------|----------|
| **"Out of memory"** | Increase -Xmx in launch script |
| **"Java not found"** | Set JAVA_HOME correctly |
| **"Permission denied"** | Make script executable (Linux/macOS) |
| **"No program loaded"** | Import a binary first |

**Instructor Tip:** Provide a pre-configured launch script with appropriate memory settings.

### Challenge 3: Understanding the Decompiler

| Issue | Solution |
|-------|----------|
| **"What are iVar1, uVar2?"** | These are decompiler-generated names |
| **"Why doesn't it look like my code?"** | Compiler optimizations |
| **"How do I make it better?"** | Rename variables and set data types |

**Instructor Tip:** Show the same program compiled with and without optimizations.

### Challenge 4: Scripting Errors

| Issue | Solution |
|-------|----------|
| **"NameError: currentProgram not defined"** | Run inside Ghidra, not standalone |
| **"MemoryAccessException"** | Check address validity first |
| **"AttributeError: 'NoneType'"** | Object doesn't exist |

**Instructor Tip:** Provide a template script with error handling.

---

## 2.4 Classroom Management Tips

### For Mixed-Skill Classes

1. **Pre-Assessment:** Give a short diagnostic at the start
2. **Tiered Exercises:** Provide basic, intermediate, and advanced tracks
3. **Peer Mentoring:** Pair more advanced students with beginners
4. **Flexible Pacing:** Allow advanced students to skip ahead

### For Large Classes

1. **Breakout Groups:** For labs and discussions
2. **TAs or Co-Instructors:** Help with student questions
3. **Live Coding:** Demo then let students follow
4. **Q&A Queue:** Use a queue system for questions

### For Remote Classes

1. **Screen Sharing:** Use for demos and walkthroughs
2. **Chat for Questions:** Less disruptive
3. **Polls and Quizzes:** Check understanding
4. **Breakout Rooms:** For lab work
5. **Session Recording:** For student review

---

## 2.5 Remote/Online Teaching Adaptations

### Platform Recommendations

| Platform | Best For | Key Features |
|----------|----------|--------------|
| **Zoom** | Live instruction | Breakout rooms, chat, screen share |
| **Teams** | Corporate training | Integrated with Office 365 |
| **Discord** | Community learning | Voice channels, screen share |
| **Slack** | Asynchronous | Threads, file sharing |

### Adaptation Strategies

**For Lectures:**
- Pre-record to allow students to watch at their own pace
- Use interactive elements (polls, quizzes)
- Keep sessions under 90 minutes
- Provide slide decks for reference

**For Labs:**
- Provide pre-configured virtual machines
- Offer cloud-based Ghidra instances
- Use shared screen for troubleshooting
- Provide step-by-step written guides

**For Assessments:**
- Use online quiz platforms (Kahoot, Quizlet)
- Provide take-home lab assignments
- Use discussion forums for Q&A

---

# Section 3: Hands-On Lab Guide

## 3.1 Lab Setup Instructions

### Virtual Machine Setup

**Option 1: Pre-configured VM (Recommended)**

Provide students with a virtual machine containing:
- Ubuntu 22.04 LTS
- JDK 17
- Ghidra
- Python 3
- Sample binaries
- Course materials

**Option 2: Student Machine Setup**

Provide instructions for setting up on their own machine:

**Windows:**
1. Install JDK 17
2. Set JAVA_HOME
3. Download and extract Ghidra
4. Install Python 3
5. Install GCC/MinGW

**Linux:**
```bash
sudo apt update
sudo apt install openjdk-17-jdk
wget https://ghidra-sre.org/ghidra_X.X_PUBLIC.zip
unzip ghidra_X.X_PUBLIC.zip
sudo apt install python3 gcc
```

**macOS:**
```bash
brew install openjdk@17 python3 gcc
```

### Lab Materials Distribution

**Files to Provide:**
- `calculator.c` - Sample C program
- `hello.c` - Hello World program
- `enigma_protocol` - Challenge binary
- `xor_guardian` - CTF challenge
- `serial_validator` - CTF challenge
- `malware_simulator` - Simulated malware sample

**Scripts to Provide:**
- `EnumFunctions.py` - Scripting example
- `StringExtractor.py` - Scripting example
- `XORDecryptor.py` - Scripting example
- `VulnerabilityScanner.py` - Scripting example

---

## 3.2 Lab Execution Guide

### Lab Flow: Calculator Binary

**Lab 1: Import and Analyze**
1. Create new Ghidra project
2. Import `calculator` binary
3. Run full analysis
4. Verify functions are identified

**Lab 2: Rename and Annotate**
1. Locate `main` function
2. Rename variables (param_1 → argc, local_4 → a)
3. Set data types
4. Add comments to key sections

**Lab 3: Scripting**
1. Write `EnumFunctions.py`
2. Verify output matches Symbol Tree
3. Extend script to count functions by category

### Lab Flow: CTF Challenges

**XOR Guardian:**
1. Import binary
2. Find validation logic
3. Identify XOR operation
4. Recover key
5. Extract flag

**Serial Validator:**
1. Import binary
2. Find validation function
3. Understand algorithm
4. Write keygen
5. Test with generated serial

---

## 3.3 Lab Solutions and Common Pitfalls

### Calculator Binary Solutions

**Functions Found:**
- main, add, subtract, multiply, divide, validate_access

**validate_access Vulnerability:**
- strcpy without bounds checking
- Buffer overflow risk

**XOR Validation:**
- Key ^ 0x5A == 0x40
- Valid key: 0x5A

**Common Pitfalls:**
- Forgetting to run analysis after import
- Not setting data types
- Misidentifying the XOR operation

### CTF Challenge Solutions

**XOR Guardian:**
- XOR Key: 0x5A
- Flag: FLAG{X0R_1s_7r1v14l}

**Serial Validator:**
- Algorithm: Alternating operations based on position
- Valid serial: Depends on implementation
- Keygen required: Work backwards from target

**Common Pitfalls:**
- Misunderstanding the algorithm
- Incorrectly calculating the target sum
- Not testing the generated serial

---

## 3.4 Alternative Lab Configurations

### Windows-Focused Labs

Use PE binaries instead of ELF:
- Compile with MinGW
- Use Windows API examples
- Focus on PE format specifics

### Linux-Focused Labs

Use ELF binaries:
- Compile with GCC
- Use Linux system calls
- Focus on ELF format specifics

### Advanced Labs

**Unpacking Packed Binaries:**
- UPX-packed samples
- Custom packers
- Entropy analysis

**Real Malware Analysis:**
- Simulated malware
- IOC extraction
- YARA rule creation

---

# Section 4: Assessment Guide

## 4.1 Formative Assessment Strategies

### Classroom Polls and Quick Checks

| Question Type | Example | Use Case |
|---------------|---------|----------|
| **Concept Check** | "What does XOR stand for?" | After module introduction |
| **Tool Check** | "What shortcut goes to address?" | During interface navigation |
| **Application Check** | "What's the key in validate_access?" | During binary analysis |

### In-Class Exercises

**Module 1:**
- Identify file type of given binary (5 min)
- Locate main function in Hello World (5 min)

**Module 2:**
- Identify basic blocks in a function (10 min)
- Trace an XREF to its source (10 min)

**Module 3:**
- Extract IOCs from a sample (15 min)
- Write a YARA rule (15 min)

**Module 4:**
- Find unsafe function calls (10 min)
- Trace data flow from source to sink (15 min)

### Exit Tickets

At the end of each session, ask:

1. "What was the most important thing you learned today?"
2. "What was the most confusing concept?"
3. "What would you like to learn more about?"

---

## 4.2 Summative Assessment Guide

### Module Quizzes

| Module | Format | Duration | Points |
|--------|--------|----------|--------|
| 1 | 15 MCQ | 15 min | 20 |
| 2 | 15 MCQ | 15 min | 20 |
| 3 | 15 MCQ | 15 min | 20 |
| 4 | 15 MCQ | 15 min | 20 |
| 5 | 15 MCQ | 15 min | 20 |
| 6 | 15 MCQ | 15 min | 20 |
| 7 | 15 MCQ | 15 min | 20 |
| 8 | 15 MCQ | 15 min | 20 |
| 9 | 15 MCQ | 15 min | 20 |
| 10 | 15 MCQ | 15 min | 20 |

### Module Tests

| Module | Format | Duration | Points |
|--------|--------|----------|--------|
| 1 | MCQ, True/False, Short Answer | 30 min | 50 |
| 2 | MCQ, True/False, Short Answer | 30 min | 50 |
| 3 | MCQ, True/False, Short Answer | 30 min | 50 |
| 4 | MCQ, True/False, Short Answer | 30 min | 50 |
| 5 | MCQ, True/False, Short Answer | 30 min | 50 |
| 6 | MCQ, True/False, Short Answer | 30 min | 50 |
| 7 | MCQ, True/False, Short Answer | 30 min | 50 |
| 8 | MCQ, True/False, Short Answer | 30 min | 50 |
| 9 | MCQ, True/False, Short Answer | 30 min | 50 |
| 10 | MCQ, True/False, Short Answer | 30 min | 50 |

### Comprehensive Exams

| Exam | Format | Duration | Points |
|------|--------|----------|--------|
| **Midterm** | MCQ, True/False, Short Answer, Practical | 2 hours | 100 |
| **Final** | MCQ, True/False, Short Answer, Practical | 3 hours | 150 |
| **Practical Skills** | Hands-on tasks | 2 hours | 100 |

---

## 4.3 Practical Skills Assessment

### Assessment Tasks

**Task 1: Binary Analysis (40 points)**
1. Triage: File type, size, packing (10 points)
2. Ghidra Analysis: Main function, purpose, functions (15 points)
3. IOC Extraction: Domains, IPs, registry (10 points)
4. Report: Summary of findings (5 points)

**Task 2: Scripting (30 points)**
1. Function Enumerator (10 points)
2. Vulnerability Scanner (10 points)
3. XOR Decryptor (10 points)

**Task 3: Patching (20 points)**
1. Bypass Authentication (10 points)
2. Export Patched Binary (10 points)

**Task 4: Report (10 points)**
Comprehensive report covering methodology, findings, IOCs, patches, recommendations

### Scoring Criteria

| Criteria | Excellent (90-100%) | Good (70-89%) | Satisfactory (50-69%) | Needs Improvement (<50%) |
|----------|---------------------|---------------|----------------------|--------------------------|
| **Analysis** | Complete, accurate, insightful | Good with minor gaps | Basic analysis | Incomplete |
| **Scripting** | Well-written, functional | Good code | Basic working code | Non-functional |
| **Patching** | Successful, correct | Mostly working | Partial success | Failed |
| **Reporting** | Professional, clear | Good report | Adequate | Poor |

---

## 4.4 Grading Rubrics

### Written Response Rubric

| Criteria | 4 (Excellent) | 3 (Good) | 2 (Satisfactory) | 1 (Needs Improvement) |
|----------|---------------|----------|------------------|----------------------|
| **Accuracy** | Correct, complete | Mostly correct | Partially correct | Incorrect |
| **Completeness** | Covers all aspects | Covers most | Covers some | Barely addresses |
| **Clarity** | Clear, organized | Mostly clear | Somewhat confusing | Unclear |
| **Depth** | Deep understanding | Good understanding | Surface-level | No understanding |
| **Examples** | Relevant, accurate | Good examples | Generic | No examples |

### Practical Skills Rubric

| Criteria | 5 (Excellent) | 4 (Good) | 3 (Satisfactory) | 2 (Needs Improvement) | 1 (Poor) |
|----------|---------------|----------|------------------|----------------------|----------|
| **Tool Proficiency** | Expert use | Good use | Basic use | Struggles | Cannot use |
| **Analysis Quality** | Thorough | Good | Basic | Incomplete | No analysis |
| **Scripting** | Well-written | Good code | Basic working | Major issues | No code |
| **Problem Solving** | Innovative | Good solutions | Basic solutions | Poor solutions | No solutions |
| **Reporting** | Professional | Good | Basic | Incomplete | No report |

### Project Rubric

| Criteria | 10-9 (Excellent) | 8-7 (Good) | 6-5 (Satisfactory) | 4-3 (Needs Improvement) | 2-0 (Poor) |
|----------|------------------|------------|-------------------|------------------------|------------|
| **Analysis** | Complete, insightful | Good | Basic | Incomplete | No analysis |
| **Documentation** | Professional | Good | Basic | Poor | No docs |
| **Scripts** | Well-structured | Good | Basic | Issues | No scripts |
| **Results** | All objectives met | Most met | Some met | Few met | None met |
| **Presentation** | Professional | Good | Adequate | Poor | No presentation |

---

# Section 5: Supplementary Resources

## 5.1 Recommended Reading and References

### Books

| Book | Author | Focus | Level |
|------|--------|-------|-------|
| Ghidra Software Reverse-Engineering for Beginners, 2nd Edition | David Álvarez Pérez, Ravikant Tiwari | Complete Ghidra guide | Beginner to Intermediate |
| Ghidra Unleashed | Various | Practical RE guide | All levels |
| Mastering Ghidra for Professionals | Xyla Perry | Advanced workflows | Intermediate to Advanced |
| Reverse Engineering for Beginners | Dennis Yurichev | General RE concepts | Beginner |

### Online Courses

| Course | Provider | Focus | Format |
|--------|----------|-------|--------|
| Reverse Engineer with Ghidra  | Pluralsight | Static analysis fundamentals | Video |
| Ghidra Concepts and Basic Functionality  | Pluralsight | Getting started | Video |
| Advanced Malware Reverse Engineering with Ghidra | Kaspersky | Advanced RE | Video |
| A Beginner's Guide to Reversing with Ghidra | Black Hat | Hands-on training | Workshop |

### Reference Websites

| Resource | Description | URL |
|----------|-------------|-----|
| Ghidra Official | Documentation, download | https://ghidra-sre.org/ |
| Ghidra GitHub | Source code, issues | https://github.com/NationalSecurityAgency/ghidra |
| Ghidra API | API reference | https://ghidra.re/ |
| PE Format | Microsoft documentation | https://learn.microsoft.com/en-us/windows/win32/debug/pe-format |
| ELF Format | Linux documentation | https://refspecs.linuxbase.org/elf/elf.pdf |

---

## 5.2 Additional Exercises and Challenges

### Beginner Challenges

**Challenge 1: Simple Binary**
- Binary: `hello_world`
- Task: Find the main function and change the message
- Difficulty: Easy

**Challenge 2: XOR Obfuscation**
- Binary: `xor_hide`
- Task: Find the XOR key and decrypt the hidden string
- Difficulty: Easy-Medium

### Intermediate Challenges

**Challenge 3: Serial Validator**
- Binary: `serial_check`
- Task: Understand validation algorithm and create keygen
- Difficulty: Medium

**Challenge 4: Password Checker**
- Binary: `password_checker`
- Task: Bypass authentication with patching
- Difficulty: Medium

### Advanced Challenges

**Challenge 5: Custom Packer**
- Binary: `packed_sample`
- Task: Identify packer, unpack, and analyze
- Difficulty: Advanced

**Challenge 6: Real Malware**
- Binary: `malware_sim`
- Task: Full malware analysis, IOC extraction, YARA rule
- Difficulty: Advanced

---

## 5.3 Sample Binaries and CTF Challenges

### CTF Challenge: XOR Guardian

```
=== XOR GUARDIAN ===

Description:
A binary guards a flag using XOR encryption.

Solution:
1. Import to Ghidra
2. Find validation logic
3. Identify XOR key (0x5A)
4. Decrypt flag

Flag: FLAG{X0R_1s_7r1v14l}
```

### CTF Challenge: Serial Validator

```
=== SERIAL VALIDATOR ===

Description:
A program validates serial numbers using a complex algorithm.

Solution:
1. Locate validation function
2. Understand algorithm (alternating operations)
3. Write keygen
4. Generate valid serial
```

### CTF Challenge: The Enigma Protocol

```
=== ENIGMA PROTOCOL ===

Description:
A sophisticated malware with C2 communication.

Solution:
1. Triage: ELF 64-bit
2. Analyze: Multi-layer decryption
3. Decrypt C2 domain
4. Extract flag

Flag: FLAG{Enigma_Protocol_Is_Defeated}
```

---

## 5.4 Scripts and Automation Tools

### Essential Ghidra Scripts

**Function Enumerator:**
```python
def main():
    func_manager = currentProgram.getFunctionManager()
    for func in func_manager.getFunctions(True):
        print(f"{func.getName()} at 0x{func.getEntryPoint().getOffset():08x}")
```

**String Extractor:**
```python
def main():
    listing = currentProgram.getListing()
    data = listing.getDefinedData(True)
    while data.hasNext():
        d = data.next()
        try:
            value = str(d.getValue())
            if len(value) > 4:
                print(f"0x{d.getAddress().getOffset():08x}: {value}")
        except:
            pass
```

**XOR Decryptor:**
```python
def xor_decrypt(data, key):
    return ''.join(chr(b ^ key) for b in data if b != 0)
def main():
    data = getBytes(toAddr(0x00402000), 32)
    key = 0x5A
    print(xor_decrypt(data, key))
```

**Vulnerability Scanner:**
```python
dangerous = ['strcpy', 'sprintf', 'gets', 'printf']
def main():
    for func in currentProgram.getFunctionManager().getFunctions(True):
        for instr in currentProgram.getListing().getInstructions(func.getBody(), True):
            if instr.isCall():
                for target in instr.getFlows():
                    target_func = getFunctionAt(target)
                    if target_func and target_func.getName() in dangerous:
                        print(f"VULNERABILITY: {target_func.getName()} at {instr.getAddress()}")
```

---

# Section 6: Troubleshooting and Support

## 6.1 Common Technical Issues

### Installation Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Ghidra won't launch | Java not found | Set JAVA_HOME |
| Out of Memory | Insufficient heap | Increase -Xmx |
| Can't find JDK | Wrong path | Verify JAVA_HOME |
| Script errors | Python not found | Install Python 3 |

### Analysis Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| No functions found | Analysis not run | Run analysis |
| Wrong imports | Missing libraries | Import system libraries |
| Decompiler errors | Obfuscated code | Manual analysis |
| Memory access errors | Invalid address | Check address validity |

### Scripting Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| currentProgram not defined | Running outside Ghidra | Use Script Manager |
| AttributeError | Object is None | Check object existence |
| TypeError | Wrong parameter type | Check API docs |
| MemoryAccessException | Invalid address | Use memory.contains() |

---

## 6.2 Student Support Strategies

### Pre-Course Support

1. **Pre-Assessment:** Identify skill gaps
2. **Environment Check:** Verify installations
3. **Orientation:** Ghidra basics
4. **Resource Review:** Provide reading materials

### During-Course Support

1. **Office Hours:** Regular availability
2. **Discussion Forums:** Q&A platform
3. **Peer Support:** Encourage collaboration
4. **Tutoring:** One-on-one help

### Post-Course Support

1. **Follow-up:** Check progress
2. **Additional Resources:** Suggest further learning
3. **Community:** Connect with RE community
4. **Certification:** Guide for certification prep

---

## 6.3 Frequently Asked Questions

### General Questions

**Q: How long does it take to become proficient in Ghidra?**
A: Basic proficiency: 1-2 months. Professional proficiency: 6-12 months with regular practice.

**Q: Is Ghidra better than IDA Pro?**
A: Ghidra is free and open-source with a great decompiler. IDA Pro has more plugins and commercial support. Both are excellent tools.

**Q: Do I need to know C programming?**
A: Recommended but not required. C knowledge helps with understanding decompiled code.

**Q: Can I use Ghidra for commercial work?**
A: Yes, Ghidra is open-source under the Apache 2.0 license.

### Technical Questions

**Q: Why does Ghidra need so much memory?**
A: Complex binaries require significant memory for analysis. 8GB+ recommended.

**Q: Can I analyze malware on my main machine?**
A: Only in a sandbox or VM. Never execute malware on a production system.

**Q: How do I add plugins to Ghidra?**
A: File → Install Extensions → Add JAR file.

**Q: Can I script Ghidra in languages other than Python?**
A: Yes, Java and JavaScript are also supported. Python is the most common.

### Assessment Questions

**Q: What's the best way to practice reverse engineering?**
A: CTF challenges, malware samples, and analyzing your own programs.

**Q: What certifications are available?**
A: GREM (SANS), eCRE, and vendor-specific certifications.

**Q: How do I build a reverse engineering career?**
A: Practice, build portfolio, network, pursue certifications.

---

# Appendix A: Sample Course Syllabus

## Course Syllabus

### Zero to Hero: Practical Reverse Engineering with Ghidra

**Course Title:** Zero to Hero: Practical Reverse Engineering with Ghidra
**Duration:** 8-12 hours (full course)
**Prerequisites:** Basic programming experience, command-line comfort
**Format:** Lecture + Hands-on Labs

### Course Description
This course provides comprehensive training in reverse engineering using Ghidra. Students learn to install and configure Ghidra, navigate its interface, analyze binaries, solve CTF challenges, perform malware analysis, and identify security vulnerabilities.

### Learning Objectives
- Install and configure Ghidra
- Navigate Ghidra's interface
- Analyze compiled binaries
- Solve CTF reverse engineering challenges
- Perform static malware analysis
- Identify security vulnerabilities
- Automate analysis with Python scripting

### Course Schedule

| Week | Topic | Readings | Assignments |
|------|-------|----------|-------------|
| 1 | Introduction & Environment Setup | Primer 1, 2 | Install Ghidra |
| 2 | Ghidra Interface & Navigation | Appendix B | Interface exercise |
| 3 | First Binary Analysis | Module 1 | Calculator analysis |
| 4 | Ghidra Scripting | Primer 4 | Function enumerator |
| 5 | Control Flow Analysis | Module 2.1 | Basic block exercise |
| 6 | Cross-References (XREFs) | Module 2.2 | XREF challenge |
| 7 | XOR Decryption | Module 2.3 | XOR decryptor |
| 8 | Binary Patching | Module 2.4 | Patch challenge |
| 9 | Malware Analysis | Module 3 | IOC extraction |
| 10 | Vulnerability Research | Module 4 | Vulnerability scanner |
| 11-12 | Final Project | - | Complete analysis |

### Grading

| Component | Percentage |
|-----------|------------|
| Module Quizzes | 20% |
| Labs and Exercises | 30% |
| Midterm | 20% |
| Final Project | 30% |

### Required Materials
- Computer with 8GB+ RAM
- JDK 17+
- Ghidra (latest version)
- Python 3
- Course materials (provided)

---

# Appendix B: Student Evaluation Forms

## Student Self-Assessment

### Pre-Course Self-Assessment

| Skill | 1 (Novice) | 2 (Basic) | 3 (Intermediate) | 4 (Advanced) |
|-------|------------|-----------|------------------|--------------|
| Programming experience | ☐ | ☐ | ☐ | ☐ |
| Command-line proficiency | ☐ | ☐ | ☐ | ☐ |
| Understanding of computer architecture | ☐ | ☐ | ☐ | ☐ |
| Assembly language knowledge | ☐ | ☐ | ☐ | ☐ |
| C programming knowledge | ☐ | ☐ | ☐ | ☐ |

### Post-Course Self-Assessment

| Skill | 1 (Novice) | 2 (Basic) | 3 (Intermediate) | 4 (Advanced) |
|-------|------------|-----------|------------------|--------------|
| Ghidra installation and configuration | ☐ | ☐ | ☐ | ☐ |
| Ghidra interface navigation | ☐ | ☐ | ☐ | ☐ |
| Binary analysis with Ghidra | ☐ | ☐ | ☐ | ☐ |
| Control flow analysis | ☐ | ☐ | ☐ | ☐ |
| XOR decryption | ☐ | ☐ | ☐ | ☐ |
| Binary patching | ☐ | ☐ | ☐ | ☐ |
| Malware analysis | ☐ | ☐ | ☐ | ☐ |
| Ghidra scripting | ☐ | ☐ | ☐ | ☐ |

### Course Feedback

**What was the most valuable part of this course?**
```

```

**What could be improved?**
```

```

**What topics would you like to learn more about?**
```

```

**Rate the course overall:** 1 2 3 4 5

---

## Instructor Evaluation Form

### Student Name: _____________________

**Module 1: Foundations**
| Criteria | 1 | 2 | 3 | 4 |
|----------|---|---|---|---|
| Installation completion | ☐ | ☐ | ☐ | ☐ |
| Interface understanding | ☐ | ☐ | ☐ | ☐ |
| First binary analysis | ☐ | ☐ | ☐ | ☐ |

**Module 2: CTF Challenges**
| Criteria | 1 | 2 | 3 | 4 |
|----------|---|---|---|---|
| Control flow analysis | ☐ | ☐ | ☐ | ☐ |
| XREF usage | ☐ | ☐ | ☐ | ☐ |
| XOR decryption | ☐ | ☐ | ☐ | ☐ |
| Binary patching | ☐ | ☐ | ☐ | ☐ |

**Module 3: Malware Analysis**
| Criteria | 1 | 2 | 3 | 4 |
|----------|---|---|---|---|
| Static triage | ☐ | ☐ | ☐ | ☐ |
| IOC extraction | ☐ | ☐ | ☐ | ☐ |
| YARA rule creation | ☐ | ☐ | ☐ | ☐ |

**Module 4: Vulnerability Research**
| Criteria | 1 | 2 | 3 | 4 |
|----------|---|---|---|---|
| Memory corruption understanding | ☐ | ☐ | ☐ | ☐ |
| Data flow analysis | ☐ | ☐ | ☐ | ☐ |
| Vulnerability discovery | ☐ | ☐ | ☐ | ☐ |

### Comments
```

```

---

# Appendix C: Certificates and Completion Materials

## Certificate of Completion

```
====================================================================

                      CERTIFICATE OF COMPLETION

This certifies that

                    [STUDENT NAME]

has successfully completed

        Zero to Hero: Practical Reverse Engineering with Ghidra

A comprehensive course covering:
    • Ghidra installation and configuration
    • Binary analysis and disassembly
    • CTF challenge solving
    • Malware analysis
    • Vulnerability research
    • Ghidra scripting with Python

Date of Completion: ________________

Instructor: ________________
Institution: ________________

====================================================================
```

---

## Student Achievement Badges

**Ghidra Foundation Badge**
- Complete Module 1
- Install and configure Ghidra
- Analyze first binary

**Binary Analysis Badge**
- Complete Module 2
- Demonstrate control flow analysis
- Use XREFs effectively

**CTF Solver Badge**
- Complete Module 3
- Solve XOR challenge
- Create keygen

**Malware Analyst Badge**
- Complete Module 4
- Extract IOCs
- Create YARA rule

**Vulnerability Researcher Badge**
- Complete Module 5
- Identify vulnerabilities
- Write vulnerability scanner

**Ghidra Master Badge**
- Complete all modules
- Complete final project
- Demonstrate all skills

---

# Appendix D: Quick Reference for Trainers

## Teaching Session Checklist

**Before Session:**
- [ ] Verify all technology works
- [ ] Load slide deck
- [ ] Prepare demonstration binaries
- [ ] Test scripts and code samples
- [ ] Have backup materials ready

**During Session:**
- [ ] Start with review of previous session
- [ ] State learning objectives
- [ ] Explain concepts with analogies
- [ ] Demonstrate in Ghidra
- [ ] Guide students through practice
- [ ] Answer questions throughout
- [ ] Summarize key takeaways

**After Session:**
- [ ] Assign homework/practice
- [ ] Provide additional resources
- [ ] Address any remaining questions
- [ ] Collect feedback

---

## Key Teaching Points by Module

### Module 1: Foundations
- **Key Message:** Ghidra is a powerful, free RE framework
- **Demo:** Hello World import and analysis
- **Practice:** Navigate to main and rename variables
- **Check:** Students can import and analyze a binary

### Module 2: CTF Challenges
- **Key Message:** Control flow and XREFs are essential skills
- **Demo:** XOR validation in validate_access
- **Practice:** Decrypt XOR-protected flag
- **Check:** Students can recover XOR key and flag

### Module 3: Malware Analysis
- **Key Message:** Static analysis is safe and effective
- **Demo:** Triage a suspicious binary
- **Practice:** Extract IOCs from malware sample
- **Check:** Students can create YARA rule

### Module 4: Vulnerability Research
- **Key Message:** Find vulnerabilities before attackers do
- **Demo:** Stack overflow in validate_access
- **Practice:** Write vulnerability scanner script
- **Check:** Students can identify unsafe functions

---

## Resources for Trainers

### Additional Training Materials

| Type | Description | Location |
|------|-------------|----------|
| **Slides** | Complete presentation deck | Course materials |
| **Workbooks** | Student exercise workbooks | Course materials |
| **Labs** | Hands-on lab guides | Course materials |
| **Quizzes** | Module quizzes with answers | Course materials |
| **Tests** | Module tests with answers | Course materials |
| **Exams** | Midterm and final exams | Course materials |
| **Scripts** | Example Ghidra scripts | Course materials |
| **Binaries** | Sample binaries for analysis | Course materials |

### Community Resources

| Resource | Description | Link |
|----------|-------------|------|
| **Ghidra Community** | User forum | https://github.com/NationalSecurityAgency/ghidra/discussions |
| **r/ReverseEngineering** | RE subreddit | https://www.reddit.com/r/ReverseEngineering/ |
| **CTFTime** | CTF challenges | https://ctftime.org/ |
| **MalwareBazaar** | Malware samples | https://bazaar.abuse.ch/ |
| **YARA Rules** | Detection rules | https://yara.readthedocs.io/ |

---

# End of Trainer Guide

---

**About This Guide**

This trainer guide was developed as a comprehensive resource for instructors delivering the "Zero to Hero: Practical Reverse Engineering with Ghidra" course. It incorporates:
- Proven teaching methodologies from industry experts 
- Hands-on lab designs based on successful RE training programs 
- Assessment strategies aligned with professional certification standards 
- Best practices from academic and corporate training environments 

**Contact and Support**

For additional support, please contact:
- Course author: [Author Name]
- Technical support: [Support Email]
- Community forum: [Forum URL]

**Last Updated:**
August 2026

---

**[END OF TRAINER GUIDE]**
