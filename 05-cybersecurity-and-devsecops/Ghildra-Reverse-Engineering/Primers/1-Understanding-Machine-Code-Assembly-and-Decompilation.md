# Primer 1: Understanding Machine Code, Assembly, and Decompilation

Welcome to the first primer of our "Zero to Hero" series. This primer is designed as a standalone, beginner-friendly deep dive into the fundamental concepts that underpin all reverse engineering work. Before you can analyze binaries effectively, you need to understand what binaries actually are, how they're structured, and how they relate to the code we write as programmers.

Think of this primer as the "physics" of reverse engineering—the foundational principles that explain everything else. You'll return to these concepts again and again as you progress through the series.

---

## P1.1: What Is Machine Code?

### P1.1.1: The Language of the Computer

When you write a program in a high-level language like Python, C, or Java, you're writing instructions that are meant to be readable by humans. But computers don't understand these languages directly. They only understand **machine code**.

**Machine code** is the lowest-level representation of a program. It consists of sequences of binary numbers (1s and 0s) that the CPU interprets as instructions. Each instruction tells the CPU to perform a specific operation, like:

- Load a value from memory
- Add two numbers together
- Compare two values
- Jump to a different part of the program

**Think of it like this:**

Imagine you're giving instructions to someone who only understands a very limited, precise set of commands:
- "Pick up the box" → Machine code instruction
- "Move the box to the left" → Another instruction
- "Put the box down" → Another instruction

The CPU is like that person—it only understands its own specific set of commands, and each command is encoded as a number.

**Real-world example:**

Here's what a simple machine code instruction looks like in binary, hexadecimal, and human-readable form:

| Binary | Hexadecimal | Meaning |
|--------|-------------|---------|
| `10111000 00000001 00000000 00000000 00000000` | `B8 01 00 00 00` | Move the value 1 into the EAX register |
| `10111000 00000010 00000000 00000000 00000000` | `B8 02 00 00 00` | Move the value 2 into the EAX register |
| `11000011` | `C3` | Return from the current function |

### P1.1.2: Why Machine Code Matters

When we reverse engineer, we don't see the original source code. We only see the compiled machine code. Understanding machine code allows us to:

1. **Understand what the program actually does**—not what the programmer intended
2. **Find bugs and vulnerabilities** that aren't visible in the source code
3. **Modify program behavior** by changing instructions
4. **Recover algorithms and secrets** that the programmer thought were hidden

### P1.1.3: The Compilation Pipeline

To understand why reverse engineering works, you need to understand the compilation pipeline:

```
High-Level Code (C, C++, Rust, etc.)
        ↓
    Compiler
        ↓
   Assembly Code (Human-readable mnemonics)
        ↓
    Assembler
        ↓
  Machine Code (Binary/hexadecimal)
        ↓
   Executable File (ELF, PE, etc.)
```

**Each stage explained:**

1. **Source Code:** Written by humans. Easy to read. Contains comments, meaningful variable names, and logical structure.

2. **Compiler:** Translates source code into assembly language. The compiler optimizes the code, reorders instructions, and removes unnecessary constructs.

3. **Assembly Code:** A human-readable representation of machine code. Uses mnemonics like `MOV`, `ADD`, `JMP` instead of binary numbers. Still specific to the CPU architecture.

4. **Assembler:** Converts assembly code into raw machine code (binary numbers). Each assembly instruction maps to one or more machine code bytes.

5. **Executable File:** The final binary. Contains machine code plus metadata (headers, section information, import/export tables).

---

## P1.2: Understanding Assembly Language

### P1.2.1: What Is Assembly?

**Assembly language** is the human-readable version of machine code. Instead of writing raw binary numbers, we use short words called **mnemonics**:

| Machine Code (Hex) | Assembly (Intel Syntax) | Meaning |
|--------------------|-------------------------|---------|
| `B8 01 00 00 00` | `MOV EAX, 1` | Move the value 1 into the EAX register |
| `83 C0 02` | `ADD EAX, 2` | Add 2 to the EAX register |
| `3B C1` | `CMP EAX, ECX` | Compare EAX with ECX |
| `74 10` | `JE label` | Jump to label if EAX equals ECX |

**Think of assembly as a "code for code":**

Imagine you have a secret language that consists entirely of numbers. Assembly is like a translation dictionary that turns those numbers into simple English commands. It doesn't make the commands easier to understand conceptually—they're still very low-level—but it makes them readable to humans.

### P1.2.2: Key Assembly Concepts

**1. Registers**

Registers are tiny, super-fast storage locations inside the CPU. Think of them as the CPU's "hands"—they hold the values the CPU is currently working with.

| Register (64-bit) | 32-bit version | 16-bit version | 8-bit version | Typical Use |
|-------------------|----------------|----------------|---------------|-------------|
| RAX | EAX | AX | AL/AH | Accumulator (math, return values) |
| RBX | EBX | BX | BL/BH | Base pointer (data access) |
| RCX | ECX | CX | CL/CH | Counter (loops) |
| RDX | EDX | DX | DL/DH | Data (I/O, math) |
| RSI | ESI | SI | SIL | Source index (string ops) |
| RDI | EDI | DI | DIL | Destination index (string ops) |
| RBP | EBP | BP | BPL | Base pointer (stack frames) |
| RSP | ESP | SP | SPL | Stack pointer (top of stack) |
| RIP | EIP | IP | - | Instruction pointer (current instruction) |

**2. The Stack**

The stack is a region of memory used for temporary storage. Think of it like a stack of plates:
- You can only add or remove plates from the top
- When you add a plate, you "push" it
- When you remove a plate, you "pop" it

**Stack operations:**
```assembly
PUSH RAX    ; Push the value of RAX onto the stack
POP RAX     ; Pop the top value from the stack into RAX
```

**3. Instruction Types**

| Category | Example Instructions | Purpose |
|----------|---------------------|---------|
| **Data Movement** | `MOV`, `LEA`, `PUSH`, `POP` | Move data between registers, memory, and the stack |
| **Arithmetic** | `ADD`, `SUB`, `MUL`, `DIV` | Perform mathematical operations |
| **Logic** | `AND`, `OR`, `XOR`, `SHIFT` | Perform bitwise operations |
| **Comparison** | `CMP`, `TEST` | Compare values (sets flags for conditional jumps) |
| **Control Flow** | `JMP`, `JE`, `CALL`, `RET` | Change the flow of execution |
| **System** | `INT`, `SYSCALL`, `SYSENTER` | Call the operating system |

### P1.2.3: A Simple Assembly Program

Let's look at a complete assembly program and its C equivalent:

**C Program:**
```c
int add_numbers(int a, int b) {
    return a + b;
}

int main() {
    int result = add_numbers(5, 3);
    return result;
}
```

**x86_64 Assembly (Linux System V calling convention):**
```assembly
add_numbers:
    push rbp                ; Save the base pointer
    mov rbp, rsp            ; Set up a new frame
    mov eax, edi            ; First argument (a) is in EDI
    add eax, esi            ; Add second argument (b) in ESI
    pop rbp                 ; Restore the base pointer
    ret                     ; Return (result is in EAX)

main:
    push rbp                ; Save the base pointer
    mov rbp, rsp            ; Set up a new frame
    mov edi, 5              ; First argument: 5
    mov esi, 3              ; Second argument: 3
    call add_numbers        ; Call the function
    pop rbp                 ; Restore the base pointer
    ret                     ; Return
```

**Dissecting the Assembly:**

1. **Function Prologue:**
   ```assembly
   push rbp
   mov rbp, rsp
   ```
   This sets up a new stack frame. It saves the old base pointer and creates a new one.

2. **Parameter Passing:**
   ```assembly
   mov edi, 5    ; First argument goes in EDI
   mov esi, 3    ; Second argument goes in ESI
   ```
   In the x86_64 System V calling convention, the first two integer arguments are passed in EDI and ESI.

3. **Function Call:**
   ```assembly
   call add_numbers
   ```
   This jumps to the function and pushes the return address onto the stack.

4. **Function Body:**
   ```assembly
   mov eax, edi    ; Move argument 'a' to EAX
   add eax, esi    ; Add argument 'b' to EAX
   ```
   The result accumulates in EAX (the default return register).

5. **Function Epilogue:**
   ```assembly
   pop rbp
   ret
   ```
   This cleans up the stack and returns to the caller.

6. **Return Value:**
   ```assembly
   ret
   ```
   The value in EAX is returned to the caller.

---

## P1.3: Understanding Decompilation

### P1.3.1: What Is Decompilation?

**Decompilation** is the process of taking machine code (or assembly) and converting it back into a high-level language (like C). This is what Ghidra does when you look at the Decompiler window.

**Think of it like translating a foreign language:**

- Machine code is like a foreign language you don't understand
- Assembly is like a rough transcription of that language
- Decompiled code is like a fluent translation into English

Ghidra's decompiler is incredibly sophisticated. It analyzes the control flow, data types, and function calls to produce readable C-like code.

### P1.3.2: How Decompilation Works

**Step 1: Disassembly**

The first step is disassembly—converting machine code to assembly.

**Machine Code:**
```
0x00401123: 55
0x00401124: 48 89 E5
0x00401127: 89 7D FC
0x0040112A: 89 75 F8
0x0040112D: 8B 45 FC
0x00401130: 03 45 F8
0x00401133: 5D
0x00401134: C3
```

**Assembly:**
```
push rbp
mov rbp, rsp
mov [rbp-0x4], edi
mov [rbp-0x8], esi
mov eax, [rbp-0x4]
add eax, [rbp-0x8]
pop rbp
ret
```

**Step 2: Basic Block Analysis**

The decompiler identifies **basic blocks**—sequences of instructions with no branches in or out.

```
Block 1:
    push rbp
    mov rbp, rsp
    mov [rbp-0x4], edi
    mov [rbp-0x8], esi
    mov eax, [rbp-0x4]
    add eax, [rbp-0x8]
    pop rbp
    ret
```

**Step 3: Control Flow Analysis**

The decompiler analyzes branches and jumps to understand the program's structure.

**Step 4: Variable Analysis**

The decompiler identifies:
- Function parameters (passed in registers or on the stack)
- Local variables (allocated on the stack)
- Return values

**Step 5: Data Type Inference**

The decompiler attempts to determine data types:
- Integers (signed/unsigned, size)
- Pointers
- Arrays
- Structures

**Step 6: High-Level Code Generation**

Finally, the decompiler produces C-like code:

```c
int add_numbers(int a, int b) {
    int local_a;
    int local_b;
    int result;
    
    local_a = a;
    local_b = b;
    result = local_a + local_b;
    return result;
}
```

### P1.3.3: Decompilation Example: Then vs. Now

Let's look at a slightly more complex example to see what the decompiler reveals:

**Assembly:**
```assembly
cmp eax, 0x10
jg label_overflow
add eax, ebx
mov ecx, eax
jmp label_end

label_overflow:
mov ecx, 0xFFFFFFFF

label_end:
mov eax, ecx
ret
```

**Decompiler Output:**
```c
int safe_add(int a, int b) {
    if (a > 0x10) {
        return -1;  // Overflow
    }
    return a + b;
}
```

The decompiler has recognized:
- The comparison as a conditional check
- The jump as an error path
- `0xFFFFFFFF` as `-1` in two's complement
- The overall function as a safe addition with bounds checking

### P1.3.4: Why the Decompiler Isn't Perfect

Ghidra's decompiler is incredible, but it has limitations:

| Limitation | Example | Mitigation |
|------------|---------|------------|
| **Obfuscation** | Code purposely made complex | Manual analysis |
| **Missing Types** | Variables appear as `iVar1`, `uVar2` | Manual renaming |
| **Indirect Calls** | Function pointers and virtual calls | XREF analysis |
| **Self-Modifying Code** | Code that modifies itself | Dynamic analysis |
| **Packed Code** | Compressed/encrypted code | Unpacking first |

---

## P1.4: From High-Level to Low-Level: A Detailed Transformation

### P1.4.1: The Original C Code

Let's track a simple C program through compilation to see exactly what changes:

```c
#include <stdio.h>
#include <string.h>

void process_string(char* input) {
    char buffer[32];
    int length;
    
    length = strlen(input);
    if (length < 32) {
        strcpy(buffer, input);
        printf("Processed: %s\n", buffer);
    } else {
        printf("Error: Input too long!\n");
    }
}

int main() {
    char user_input[100];
    
    printf("Enter string: ");
    fgets(user_input, 100, stdin);
    user_input[strcspn(user_input, "\n")] = '\0';
    
    process_string(user_input);
    return 0;
}
```

### P1.4.2: Compiled Assembly (x86_64)

Here's the assembly for the `process_string` function (slightly simplified):

```assembly
process_string:
    ; Function prologue
    push rbp
    mov rbp, rsp
    sub rsp, 0x30             ; Allocate 48 bytes (32 for buffer, 16 for locals)
    
    ; Save parameters
    mov [rbp-0x28], rdi       ; Save input pointer
    
    ; strlen(input)
    mov rdi, [rbp-0x28]       ; Load input pointer
    call strlen               ; Call strlen
    mov [rbp-0x4], eax        ; Store length
    
    ; Compare length < 32
    cmp [rbp-0x4], 0x20       ; 0x20 = 32
    jge label_error           ; Jump if length >= 32
    
    ; strcpy(buffer, input)
    lea rax, [rbp-0x20]       ; Get address of buffer
    mov rdi, rax              ; Destination: buffer
    mov rsi, [rbp-0x28]       ; Source: input
    call strcpy               ; Call strcpy
    
    ; printf("Processed: %s\n", buffer)
    lea rax, [rbp-0x20]       ; Get address of buffer
    mov rsi, rax              ; Second argument: buffer
    lea rdi, [msg_processed]  ; First argument: format string
    mov eax, 0                ; No vector registers
    call printf               ; Call printf
    jmp label_end
    
label_error:
    ; printf("Error: Input too long!\n")
    lea rdi, [msg_error]      ; Format string
    mov eax, 0                ; No vector registers
    call printf               ; Call printf
    
label_end:
    ; Function epilogue
    mov rsp, rbp
    pop rbp
    ret

msg_processed:
    db "Processed: %s\n", 0
msg_error:
    db "Error: Input too long!\n", 0
```

### P1.4.3: What the Decompiler Shows

Now let's see what Ghidra's decompiler produces from this assembly:

```c
void process_string(char* input) {
    char buffer[32];
    int length;
    
    length = strlen(input);
    if (length < 0x20) {
        strcpy(buffer, input);
        printf("Processed: %s\n", buffer);
    } else {
        printf("Error: Input too long!\n");
    }
    return;
}
```

**Notice the differences from the original:**

| Original C | Decompiled | Reason |
|------------|------------|--------|
| `length < 32` | `length < 0x20` | Decimal vs. hexadecimal (same value) |
| `strcpy(buffer, input)` | `strcpy(buffer, input)` | Unchanged (C library function) |
| - | `return;` | Implicit in original, explicit in decompiler |

### P1.4.4: What's Lost in Compilation

**Information that's completely lost:**

1. **Variable Names:** `buffer` becomes just a memory address; the decompiler calls it something like `local_20`
2. **Comments:** All comments are removed
3. **Function Names:** Without debug symbols, functions appear as `FUN_00401120`
4. **Data Types:** `int` vs. `long` vs. `short` can be ambiguous
5. **Structure Definitions:** Structures become raw offsets
6. **Control Flow Constructs:** `for` loops become `while` loops or `goto` statements

**Information that's transformed:**

1. **Optimizations:** The compiler may reorder code, inline functions, or eliminate unused code
2. **Constants:** May be stored differently or computed at compile time
3. **String Literals:** Stored in the `.rodata` section with addresses

**Information that's preserved:**

1. **Program Logic:** The core algorithm is still present (though obfuscated)
2. **Function Parameters:** The number and order of parameters are usually preserved
3. **Control Flow:** The sequence of operations is preserved

---

## P1.5: Key Terminology Explained

### P1.5.1: Essential Terms for Reverse Engineering

| Term | Definition | Simple Analogy |
|------|------------|----------------|
| **Machine Code** | Binary instructions the CPU executes | The electrical impulses that make a machine work |
| **Assembly** | Human-readable version of machine code | A translation of electrical impulses into simple commands |
| **Decompilation** | Converting assembly back to high-level code | Translating simple commands back into English |
| **Disassembly** | Converting machine code to assembly | Translating electrical impulses into simple commands |
| **Register** | A storage location inside the CPU | The CPU's "hands"—what it holds while working |
| **Stack** | A region of memory for temporary storage | A stack of plates—LIFO (Last In, First Out) |
| **Frame** | A section of the stack for a function | A shelf in the stack for a specific function |
| **Instruction** | A single CPU operation | A single step in a recipe |
| **Basic Block** | A sequence of instructions without branches | A straight path in a flowchart |
| **Control Flow** | The order in which instructions execute | The path a program takes through its logic |
| **Function Prologue** | Setup code at the start of a function | Punching in before starting a task |
| **Function Epilogue** | Cleanup code at the end of a function | Clocking out after finishing a task |
| **Calling Convention** | The rules for calling functions | The social etiquette of passing notes |

### P1.5.2: Real-World Analogy: A Coffee Shop

Let's use a coffee shop analogy to make these concepts more concrete:

**The Program:**
- The manager writes a recipe book (source code) for making coffee
- The chef translates the recipe into specific hand movements (assembly)
- The barista executes the hand movements (machine code)

**The Stack:**
- The counter where they prepare drinks is the stack
- Each drink order is a function
- The barista pushes a drink onto the counter when they start
- They pop it off when finished

**Registers:**
- The barista's hands are registers
- They can only hold a few items at a time (a cup, a lid, a sleeve)
- They're always using their hands for the current task

**Function Call:**
- The barista asks a coworker for help (calls a function)
- The coworker takes over part of the task
- The coworker returns the completed part to the barista

**Decompilation:**
- Someone watches the barista make coffee (observes machine code)
- They write down the hand movements (creates assembly)
- They translate the movements back into the original recipe (decompilation)
- It may not match the manager's original recipe exactly, but it produces the same coffee

---

## P1.6: Practical Exercise

### P1.6.1: Your First Assembly Analysis

Here's a small C program and its compiled assembly. Practice identifying the different parts:

**C Program:**
```c
int multiply(int a, int b) {
    int result = a * b;
    if (result > 100) {
        return result;
    } else {
        return 0;
    }
}
```

**Compiled Assembly (x86_64):**
```assembly
multiply:
    push rbp
    mov rbp, rsp
    mov [rbp-0x4], edi
    mov [rbp-0x8], esi
    mov eax, [rbp-0x4]
    imul eax, [rbp-0x8]
    mov [rbp-0xC], eax
    cmp [rbp-0xC], 0x64
    jle label_return_zero
    mov eax, [rbp-0xC]
    jmp label_return
label_return_zero:
    mov eax, 0
label_return:
    pop rbp
    ret
```

**Questions to answer:**

1. **Where are the parameters stored?**
   - Answer: In `[rbp-0x4]` (a) and `[rbp-0x8]` (b)

2. **Where is `result` stored?**
   - Answer: In `[rbp-0xC]`

3. **What's the comparison value for 100?**
   - Answer: `0x64` (hexadecimal for 100)

4. **What instruction performs the multiplication?**
   - Answer: `imul eax, [rbp-0x8]`

5. **What's the conditional jump for the "else" branch?**
   - Answer: `jle label_return_zero` (jump if result <= 100)

6. **What register holds the return value?**
   - Answer: `eax` (the standard return register)

### P1.6.2: Practice with Ghidra

If you have Ghidra installed:

1. Write a simple C program with `main()` and `add()`
2. Compile it with `gcc -g` (debug symbols)
3. Import it into Ghidra
4. Find the `main` function in the Symbol Tree
5. Look at the decompiled code
6. Compare it to your original source code
7. Rename variables to make it more readable

**What to look for:**
- How parameters are passed to functions
- How local variables are allocated
- How the return value is handled
- How the control flow matches your original code

---

## P1.7: Common Misconceptions

### P1.7.1: "Assembly is the same as machine code"

**Misconception:** Assembly and machine code are the same thing.

**Reality:** Assembly is the human-readable representation of machine code. Each machine code instruction has a corresponding assembly mnemonic, but they're different formats.

### P1.7.2: "The decompiler produces perfect C code"

**Misconception:** Ghidra's decompiler produces perfect, compile-ready C code.

**Reality:** The decompiler produces an approximation of the original code. It's incredibly useful, but it may have:
- Missing variable names
- Incorrect data types
- Simplified control flow
- Missing context

### P1.7.3: "You need to know assembly to reverse engineer"

**Misconception:** You can't reverse engineer without being an assembly expert.

**Reality:** While assembly knowledge is helpful, Ghidra's decompiler does most of the heavy lifting. You can start reverse engineering with a basic understanding of assembly and learn more as you go.

### P1.7.4: "Compiled code is too hard to understand"

**Misconception:** Compiled code is incomprehensible.

**Reality:** Compiled code follows predictable patterns. With practice, you'll learn to recognize:
- Function prologues and epilogues
- Common calling conventions
- Standard control flow patterns
- C library function calls

---

## P1.8: Summary and Key Takeaways

### P1.8.1: Core Concepts

1. **Machine Code:** The binary instructions that CPUs execute
2. **Assembly:** Human-readable machine code using mnemonics
3. **Decompilation:** Converting assembly/ machine code back to high-level code
4. **Registers:** The CPU's storage locations for current data
5. **Stack:** Memory used for temporary storage in LIFO order
6. **Calling Convention:** Rules for passing arguments and returning values

### P1.8.2: The Reverse Engineering Mindset

When you're reverse engineering, you're not reading code—you're reading traces of the programmer's intent that have been processed through a compiler. You need to:

1. **Think like the compiler:** Understand how high-level constructs translate to assembly
2. **Think like the CPU:** Understand how instructions execute
3. **Think like the programmer:** Understand what they were trying to accomplish
4. **Think like an analyst:** Look for patterns, anomalies, and hidden functionality

### P1.8.3: What's Next?

This primer has given you the theoretical foundation. Now you're ready to:

1. **Return to Part 1** of the main series and start working with Ghidra
2. **Practice reading assembly** with simple programs
3. **Experiment with Ghidra's decompiler** on small binaries
4. **Build your confidence** by analyzing increasingly complex code

---

## P1.9: Additional Resources

### P1.9.1: Recommended Reading

| Topic | Resource | Where to Find |
|-------|----------|---------------|
| **x86 Assembly** | "Programming from the Ground Up" | Free online book |
| **x86_64 Assembly** | "x86-64 Assembly Language Programming" | Various sources |
| **Calling Conventions** | "System V AMD64 ABI" | Official specification |
| **Ghidra Decompiler** | Ghidra documentation | Ghidra official site |

### P1.9.2: Interactive Learning

- **Ghidra's Built-in Tutorial:** `Help` → `Ghidra Tutorial`
- **Online Assembly Puzzles:** Various CTF platforms
- **Practice with `objdump`:** Disassemble your own programs

### P1.9.3: Key Commands to Remember

```bash
# Disassemble a binary
objdump -d binary

# View assembly with source code (if available)
objdump -S binary

# View strings in a binary
strings binary

# View ELF header (Linux)
readelf -h binary

# View PE header (Windows)
dumpbin /HEADERS binary
```

---

## P1.10: Quick Reference Card

### Assembly Mnemonics (Most Common)

| Mnemonic | Meaning |
|----------|---------|
| `MOV` | Move data |
| `PUSH` | Push onto stack |
| `POP` | Pop from stack |
| `ADD` | Add |
| `SUB` | Subtract |
| `MUL` | Multiply (unsigned) |
| `IMUL` | Multiply (signed) |
| `DIV` | Divide (unsigned) |
| `IDIV` | Divide (signed) |
| `AND` | Bitwise AND |
| `OR` | Bitwise OR |
| `XOR` | Bitwise XOR |
| `SHL` | Shift left |
| `SHR` | Shift right |
| `CMP` | Compare |
| `TEST` | Test (AND without storing) |
| `JMP` | Unconditional jump |
| `JE` / `JZ` | Jump if equal / zero |
| `JNE` / `JNZ` | Jump if not equal / not zero |
| `JG` / `JNLE` | Jump if greater (signed) |
| `JL` / `JNGE` | Jump if less (signed) |
| `CALL` | Call function |
| `RET` | Return from function |

### Stack Operations

```assembly
; Allocate space on the stack
sub rsp, 0x20

; Deallocate space on the stack
add rsp, 0x20
```

### Common Calling Conventions (x86_64)

| Argument Number | Linux System V | Windows x64 |
|-----------------|----------------|-------------|
| 1 | RDI | RCX |
| 2 | RSI | RDX |
| 3 | RDX | R8 |
| 4 | RCX | R9 |
| 5+ | Stack (right-to-left) | Stack (right-to-left) |
| Return | RAX | RAX |

---

**[END OF PRIMER 1]**

This primer has given you the foundational knowledge needed to understand machine code, assembly, and decompilation. You should now have a clear picture of what happens when code is compiled, what the compiler preserves and discards, and how Ghidra can help you reverse the process. Take time to practice with small programs before moving on to the main series.

**[PRIMER 1 COMPLETE]**
