# Primer 3: Common Assembly Patterns for Reverse Engineers

Welcome to the third primer of our "Zero to Hero" series. This primer provides a comprehensive, beginner-friendly guide to recognizing and understanding common assembly patterns. When you're reverse engineering in Ghidra, you'll see the same patterns again and again—function prologues, loops, conditional branches, and more. Learning to recognize these patterns is like learning to read the "grammar" of assembly language. Once you know the grammar, you can understand any sentence, even if you don't know every word.

---

## P3.1: Introduction to Pattern Recognition

### P3.1.1: Why Patterns Matter

**Think of it like learning a new language:** When you first start learning a language, you focus on individual words. But as you become fluent, you start recognizing entire phrases and sentence structures. You don't need to think about every word—you understand the pattern.

Reverse engineering is the same way. You don't need to understand every single instruction. You just need to recognize common patterns and understand what they represent at a higher level.

**Three levels of understanding:**

| Level | Description | Example |
|-------|-------------|---------|
| **Word Level** | Understanding individual instructions | "MOV" means move data |
| **Phrase Level** | Understanding common sequences | "PUSH RBP; MOV RBP, RSP" = function prologue |
| **Sentence Level** | Understanding entire constructs | "CMP EAX, 0; JNE label" = if statement |

### P3.1.2: The Pattern Recognition Process

1. **See the pattern:** Recognize the sequence of instructions
2. **Understand the pattern:** Know what it does
3. **Apply the pattern:** Recognize it in other contexts
4. **Combine patterns:** Understand how patterns work together

---

## P3.2: Function Patterns

### P3.2.1: The Function Prologue

Every function begins with a **prologue** that sets up the stack frame.

**The Standard x86_64 Prologue:**
```assembly
push rbp          ; Save the caller's frame pointer
mov rbp, rsp      ; Set up a new frame pointer
sub rsp, 0x20     ; Allocate space for local variables (32 bytes)
```

**The Standard x86 Prologue:**
```assembly
push ebp          ; Save the caller's frame pointer
mov ebp, esp      ; Set up a new frame pointer
sub esp, 0x20     ; Allocate space for local variables (32 bytes)
```

**What's happening:**
1. Save the current frame pointer (so we can restore it later)
2. Point the frame pointer at the current stack position
3. Reserve space on the stack for local variables

**In Ghidra's Decompiler:**
```c
void function_name(int param1, char* param2) {
    int local1;
    char local2[32];
    // Function body
}
```

### P3.2.2: The Function Epilogue

Every function ends with an **epilogue** that cleans up the stack.

**The Standard x86_64 Epilogue:**
```assembly
mov rsp, rbp      ; Deallocate local variables (or use leave)
pop rbp           ; Restore the caller's frame pointer
ret               ; Return to the caller
```

**Simplified x86_64 Epilogue:**
```assembly
leave             ; Equivalent to: mov rsp, rbp; pop rbp
ret               ; Return to the caller
```

**The Standard x86 Epilogue:**
```assembly
mov esp, ebp      ; Deallocate local variables
pop ebp           ; Restore the caller's frame pointer
ret               ; Return to the caller
```

**Pattern Recognition Tip:** If you see `leave` followed by `ret`, you're looking at a standard function epilogue.

### P3.2.3: Function Parameters

**Parameter Access in x86_64 (Linux System V):**

| Parameter | Location | Access Example |
|-----------|----------|----------------|
| 1 | RDI | `mov eax, [rdi]` |
| 2 | RSI | `mov eax, [rsi]` |
| 3 | RDX | `mov eax, [rdx]` |
| 4 | RCX | `mov eax, [rcx]` |
| 5+ | Stack (RBP+ offset) | `mov eax, [rbp+0x10]` |

**Parameter Access in Windows x64:**

| Parameter | Location | Access Example |
|-----------|----------|----------------|
| 1 | RCX | `mov eax, [rcx]` |
| 2 | RDX | `mov eax, [rdx]` |
| 3 | R8 | `mov eax, [r8]` |
| 4 | R9 | `mov eax, [r9]` |
| 5+ | Stack | `mov eax, [rsp+0x28]` |

**Parameter Access in x86 (cdecl/stdcall):**
```assembly
mov eax, [ebp+0x8]   ; First parameter
mov eax, [ebp+0xC]   ; Second parameter
mov eax, [ebp+0x10]  ; Third parameter
```

**Pattern Recognition Tip:** In x86, parameters are always at `[ebp+offset]` where offset > 0. Local variables are at `[ebp-offset]` where offset > 0.

### P3.2.4: Function Calls

**A Simple Function Call:**
```assembly
mov rdi, 0x10      ; First argument: 0x10
mov rsi, 0x20      ; Second argument: 0x20
call my_function   ; Call the function
```

**After the call:**
```assembly
; The return value is in EAX/RAX
cmp eax, 0x0       ; Compare return value to 0
je label_zero      ; Branch if return value is 0
```

**Pattern Recognition Tip:** Any `call` instruction is a function call. Look at what's in the registers before the `call` to see the arguments.

### P3.2.5: Tail Calls

A **tail call** is when a function calls another function and immediately returns its result.

**Before Optimization:**
```c
int func_a(int x) {
    return func_b(x);
}
```

**Assembly:**
```assembly
func_a:
    mov rdi, [rbp+0x8]    ; Get the argument
    jmp func_b            ; Jump to func_b (doesn't return here)
```

**Pattern Recognition Tip:** A `jmp` instruction instead of `call` at the end of a function usually indicates a tail call.

---

## P3.3: Branching Patterns

### P3.3.1: If-Else Statements

**C Code:**
```c
if (a > 0) {
    result = 1;
} else {
    result = 0;
}
```

**Assembly (x86_64):**
```assembly
cmp eax, 0x0        ; Compare a to 0
jle label_else      ; Jump to else if a <= 0
mov ecx, 0x1        ; result = 1
jmp label_end       ; Jump to end
label_else:
    mov ecx, 0x0    ; result = 0
label_end:
    mov eax, ecx    ; Return result
```

**Pattern Recognition:**
1. `CMP` compares two values
2. A conditional jump (`JLE`, `JG`, `JE`, etc.) branches to the else block
3. The true block executes
4. A jump goes to the end
5. The else block executes
6. The end label

**In Ghidra's Decompiler:**
```c
if (a > 0) {
    result = 1;
} else {
    result = 0;
}
```

### P3.3.2: Switch Statements

**C Code:**
```c
switch (value) {
    case 1:
        do_case_1();
        break;
    case 2:
        do_case_2();
        break;
    case 3:
        do_case_3();
        break;
    default:
        do_default();
}
```

**Assembly (Using Jump Table):**
```assembly
; Check if value is in range
cmp eax, 0x3
ja label_default      ; If value > 3, go to default

; Jump using the jump table
lea rdi, [jump_table] ; Load the address of the jump table
mov rax, [rdi + rax*8] ; Get the address from the table
jmp rax               ; Jump to it

jump_table:
    quad case1_addr   ; Address for case 1
    quad case2_addr   ; Address for case 2
    quad case3_addr   ; Address for case 3

case1_addr:
    ; Case 1 code
    jmp label_end
case2_addr:
    ; Case 2 code
    jmp label_end
case3_addr:
    ; Case 3 code
    jmp label_end
label_default:
    ; Default case
label_end:
```

**Pattern Recognition:**
1. Compare the value with the maximum case
2. Jump to default if out of range
3. Load an address from a jump table
4. Jump to that address

**In Ghidra's Decompiler:**
```c
switch(value) {
    case 1:
        ...
    case 2:
        ...
    case 3:
        ...
    default:
        ...
}
```

### P3.3.3: Ternary Operators

**C Code:**
```c
result = (a > 0) ? 1 : 0;
```

**Assembly:**
```assembly
cmp eax, 0x0
mov ecx, 0x1
mov edx, 0x0
cmovg ecx, edx    ; If a > 0, move 0 into ecx
; Actually, this is more common:
xor edx, edx      ; result = 0
cmp eax, 0x0
setg dl           ; Set dl to 1 if a > 0
mov eax, edx      ; Return result
```

**Pattern Recognition:** Look for `SET` or `CMOV` instructions after a comparison.

---

## P3.4: Loop Patterns

### P3.4.1: For Loop

**C Code:**
```c
for (int i = 0; i < 10; i++) {
    sum += i;
}
```

**Assembly:**
```assembly
xor ecx, ecx      ; i = 0
xor eax, eax      ; sum = 0
loop_start:
cmp ecx, 0xA      ; Compare i with 10
jge loop_end      ; Exit if i >= 10
add eax, ecx      ; sum += i
inc ecx           ; i++
jmp loop_start    ; Repeat
loop_end:
```

**Pattern Recognition:**
1. Initialize counter to 0
2. Compare counter with limit
3. Jump to end if counter >= limit
4. Execute loop body
5. Increment counter
6. Jump back to start

**In Ghidra's Decompiler:**
```c
for (int i = 0; i < 10; i++) {
    sum += i;
}
```

### P3.4.2: While Loop

**C Code:**
```c
while (i < 10) {
    i++;
}
```

**Assembly:**
```assembly
loop_start:
cmp ecx, 0xA      ; Compare i with 10
jge loop_end      ; Exit if i >= 10
inc ecx           ; i++
jmp loop_start    ; Repeat
loop_end:
```

**Pattern Recognition:**
1. Check condition at the start
2. Execute body if condition is true
3. Jump back to check condition again

**In Ghidra's Decompiler:**
```c
while (i < 10) {
    i++;
}
```

### P3.4.3: Do-While Loop

**C Code:**
```c
do {
    i++;
} while (i < 10);
```

**Assembly:**
```assembly
loop_start:
inc ecx           ; i++
cmp ecx, 0xA      ; Compare i with 10
jl loop_start     ; Repeat if i < 10
```

**Pattern Recognition:**
1. Execute body first
2. Check condition at the end
3. Jump back if condition is true

**In Ghidra's Decompiler:**
```c
do {
    i++;
} while (i < 10);
```

### P3.4.4: Loop Pattern Recognition Summary

| Loop Type | Assembly Pattern | Ghidra Decompiler |
|-----------|------------------|-------------------|
| **For** | Initialization → condition check at start → increment at end | `for (init; cond; inc)` |
| **While** | Condition check at start | `while (cond)` |
| **Do-While** | Body first, condition at end | `do { } while (cond)` |

---

## P3.5: Data Movement Patterns

### P3.5.1: String Operations

**C Code:**
```c
strcpy(buffer, input);
```

**Assembly:**
```assembly
; Using REP MOVS (fast string copy)
mov rsi, input    ; Source address
mov rdi, buffer   ; Destination address
mov rcx, 32       ; Count
rep movsb         ; Copy 32 bytes

; Or using a loop
xor ecx, ecx
loop_start:
mov al, [rsi + rcx]
mov [rdi + rcx], al
inc rcx
cmp rcx, 32
jne loop_start
```

**Pattern Recognition:** Look for `REP MOVS` or a sequence of `MOV` instructions in a loop.

### P3.5.2: Buffer Initialization

**C Code:**
```c
memset(buffer, 0, 100);
```

**Assembly:**
```assembly
; Using REP STOS
mov rdi, buffer   ; Destination address
mov rax, 0        ; Value to store
mov rcx, 100      ; Count
rep stosb         ; Fill 100 bytes with 0

; Using a loop
xor ecx, ecx
loop_start:
mov [rdi + rcx], 0
inc rcx
cmp rcx, 100
jne loop_start
```

**Pattern Recognition:** Look for `REP STOS` or a loop that writes zeros.

### P3.5.3: Loading Constants

**C Code:**
```c
int x = 0x12345678;
```

**Assembly:**
```assembly
mov eax, 0x12345678    ; Load immediate value
```

**Larger Constants:**
```assembly
; Load 64-bit constant into RAX
movabs rax, 0x123456789ABCDEF0
```

---

## P3.6: Arithmetic Patterns

### P3.6.1: Basic Arithmetic

**C Code:**
```c
int result = a + b * 2;
```

**Assembly:**
```assembly
mov eax, b        ; Load b
shl eax, 1        ; Multiply by 2 (shift left)
add eax, a        ; Add a
```

**Pattern Recognition:**
- `ADD` = addition
- `SUB` = subtraction
- `MUL` / `IMUL` = multiplication
- `DIV` / `IDIV` = division
- `SHL` / `SHR` = shift (multiply/divide by powers of 2)

### P3.6.2: Bitwise Operations

**C Code:**
```c
int result = a & 0xFF;    // Mask low byte
int result = a | 0x80;    // Set high bit
int result = a ^ 0x5A;    // XOR with key
int result = ~a;          // Bitwise NOT
```

**Assembly:**
```assembly
and eax, 0xFF    ; Mask low byte
or eax, 0x80     ; Set high bit
xor eax, 0x5A    ; XOR with key
not eax          ; Bitwise NOT
```

**Pattern Recognition:** Bitwise operations are often used for:
- Masking (AND with a mask)
- Setting bits (OR with a mask)
- Encryption/decryption (XOR)
- Flags and permissions (AND/OR/TEST)

### P3.6.3: Pointer Arithmetic

**C Code:**
```c
int* ptr = array;
int value = ptr[5];  // Same as *(ptr + 5)
```

**Assembly:**
```assembly
mov rax, ptr      ; Load pointer
mov eax, [rax + 5*4] ; Access element 5 (4 bytes per int)
```

**Pattern Recognition:** Look for memory access with a base + index * scale pattern.

---

## P3.7: Memory Access Patterns

### P3.7.1: Stack Access

**Local Variables:**
```assembly
mov eax, [rbp-0x4]    ; Access local variable at RBP-4
mov [rbp-0x8], eax    ; Store to local variable at RBP-8
```

**Pattern Recognition:** Negative offsets from RBP/EBP are local variables.

**Parameters:**
```assembly
mov eax, [rbp+0x8]    ; Access first parameter
mov eax, [rbp+0xC]    ; Access second parameter
```

**Pattern Recognition:** Positive offsets from RBP/EBP are parameters.

### P3.7.2: Global Data Access

**C Code:**
```c
extern int global_var;
global_var = 100;
```

**Assembly (Position-Dependent):**
```assembly
mov eax, 0x64
mov [global_var], eax   ; Direct address
```

**Assembly (Position-Independent):**
```assembly
lea rdi, [rip+offset]   ; Load address relative to RIP
mov eax, 0x64
mov [rdi], eax          ; Store to global
```

**Pattern Recognition:** 
- Direct addresses (e.g., `[0x00401000]`) = position-dependent
- RIP-relative addressing = position-independent

### P3.7.3: Heap Access

**C Code:**
```c
int* ptr = malloc(100);
ptr[0] = 10;
```

**Assembly:**
```assembly
mov rdi, 100       ; Size argument
call malloc        ; Allocate memory
mov [rax], 0xA     ; Store to heap
```

**Pattern Recognition:** `malloc` calls followed by memory access through the return value.

---

## P3.8: Compiler-Specific Patterns

### P3.8.1: GCC vs. MSVC

| Pattern | GCC (Linux) | MSVC (Windows) |
|---------|-------------|----------------|
| **Parameter Order** | RDI, RSI, RDX, RCX, R8, R9 | RCX, RDX, R8, R9 |
| **Stack Frame** | Standard prologue/epilogue | Shadow space (32 bytes) |
| **Local Variables** | `[rbp-offset]` | `[rbp-offset]` or `[rsp+offset]` |
| **Function Names** | `function` | `_function` (underscore prefix) |

### P3.8.2: Optimization Patterns

| Optimization | Assembly Pattern | Ghidra Decompiler |
|--------------|------------------|-------------------|
| **Inlining** | Function code appears inline | No separate function |
| **Tail Call** | `jmp` instead of `call` | Single expression return |
| **Strength Reduction** | `SHL` instead of `MUL` for powers of 2 | Same mathematical result |
| **Loop Unrolling** | Repeated code instead of loop | Expanded code |
| **Constant Propagation** | Constants baked in | Values appear directly |

### P3.8.3: Debug vs. Release Builds

**Debug Build:**
- No optimizations
- Full debug symbols
- Unrolled code is rare
- Clear prologue/epilogue

**Release Build:**
- Aggressive optimizations
- No debug symbols (or minimal)
- Inlined functions
- Complex control flow

---

## P3.9: Pattern Recognition in Ghidra

### P3.9.1: Using the Decompiler

The decompiler automatically recognizes patterns and presents them as high-level code. Here's how patterns map:

| Assembly Pattern | Decompiler Output |
|------------------|-------------------|
| `CMP` + conditional jump | `if` statement |
| `CMP` + `JMP` + labels | `if-else` statement |
| Jump table | `switch` statement |
| Loop with counter | `for` loop |
| Loop with condition at start | `while` loop |
| Loop with condition at end | `do-while` loop |

### P3.9.2: Manual Pattern Recognition

When the decompiler doesn't show the pattern clearly (due to obfuscation or optimization), you need to recognize patterns manually:

1. **Look for the prologue:** Function setup code
2. **Find the epilogue:** Function cleanup code
3. **Identify branches:** `JMP`, conditional jumps
4. **Identify loops:** Jumps that go backward
5. **Identify function calls:** `CALL` instructions

### P3.9.3: Using the Function Graph

The Function Graph visualizes the control flow, making patterns easier to spot:

- **If-else:** Two branches that merge
- **Switch:** Multiple branches from a single point
- **Loops:** A branch that goes backward (upward in the graph)
- **Functions:** A node that calls another function

---

## P3.10: Practice Exercises

### P3.10.1: Exercise 1 - Identify the Pattern

Given this assembly, what does it do?

```assembly
mov eax, 0
mov ecx, 10
loop_start:
    add eax, ecx
    dec ecx
    jnz loop_start
```

**Answer:** This is a for loop that sums numbers from 10 down to 1. In C:
```c
int sum = 0;
for (int i = 10; i > 0; i--) {
    sum += i;
}
```

### P3.10.2: Exercise 2 - Reconstruct the C Code

Reconstruct the C code from this assembly:

```assembly
cmp eax, 0
jg label_positive
mov ecx, 0
jmp label_end
label_positive:
mov ecx, 1
label_end:
mov eax, ecx
ret
```

**Answer:**
```c
int is_positive(int a) {
    if (a > 0) {
        return 1;
    } else {
        return 0;
    }
}
```

### P3.10.3: Exercise 3 - Identify the Loop Type

What kind of loop is this?

```assembly
mov eax, 0
mov ecx, 0
loop_start:
    cmp ecx, 10
    jge loop_end
    add eax, ecx
    inc ecx
    jmp loop_start
loop_end:
```

**Answer:** This is a `for` loop (or equivalently, a `while` loop). In C:
```c
for (int i = 0; i < 10; i++) {
    sum += i;
}
```

### P3.10.4: Exercise 4 - Recognize Function Parameters

Given this x86 function, what are its parameters?

```assembly
push ebp
mov ebp, esp
mov eax, [ebp+0x8]    ; What is this?
mov ecx, [ebp+0xC]    ; What is this?
add eax, ecx
pop ebp
ret
```

**Answer:** This function has two parameters. In C:
```c
int add(int a, int b) {
    return a + b;
}
```
- `[ebp+0x8]` = first parameter (`a`)
- `[ebp+0xC]` = second parameter (`b`)

### P3.10.5: Exercise 5 - Spot the Compiler

What compiler (GCC or MSVC) likely produced this x86_64 assembly?

```assembly
push rbp
mov rbp, rsp
sub rsp, 0x20
mov [rbp-0x4], edi
mov [rbp-0x8], esi
mov eax, [rbp-0x4]
add eax, [rbp-0x8]
leave
ret
```

**Answer:** GCC (Linux). Evidence:
- Parameters are in `edi` and `esi` (Linux System V convention)
- Standard prologue/epilogue
- No shadow space

---

## P3.11: Common Anti-Analysis Patterns

### P3.11.1: Debugger Detection

**Windows:**
```assembly
call IsDebuggerPresent
test eax, eax
jnz debugger_detected
```

**Linux:**
```assembly
mov rax, 0x0
mov rdi, 0x0
syscall          ; This might be ptrace
test rax, rax
jnz debugger_detected
```

**Pattern Recognition:** Calls to `IsDebuggerPresent` or system calls that check for debuggers.

### P3.11.2: Timing Checks

```assembly
rdtsc            ; Read Time Stamp Counter (x86)
mov ecx, eax
; ... do something ...
rdtsc
sub eax, ecx
cmp eax, 0x100
jl emulator_detected
```

**Pattern Recognition:** `RDTSC` or `GetTickCount` calls used to measure elapsed time.

### P3.11.3: Anti-Disassembly

```assembly
jmp label1      ; Jump over the junk
data:           ; This will look like code to the disassembler
    db 0xE8    ; Call instruction (but it's actually data)
label1:
    ; Real code continues
```

**Pattern Recognition:** Unusual control flow that jumps over data, or instructions that overlap.

---

## P3.12: Summary and Key Takeaways

### P3.12.1: Core Patterns to Know

1. **Function Prologue:** `push rbp; mov rbp, rsp; sub rsp, N`
2. **Function Epilogue:** `leave; ret` or `mov rsp, rbp; pop rbp; ret`
3. **If Statement:** `cmp` + conditional jump
4. **If-Else:** `cmp` + conditional jump + `jmp`
5. **For Loop:** Init + condition at start + increment at end
6. **While Loop:** Condition at start
7. **Do-While:** Body first, condition at end
8. **Switch:** Jump table

### P3.12.2: Pattern Recognition Tips

1. **Start with the decompiler** - It does most of the pattern recognition for you
2. **Look for prologue/epilogue** - They mark function boundaries
3. **Look for backward jumps** - They're loops
4. **Look for comparisons with branches** - They're conditionals
5. **Practice** - The more you see, the more you recognize

### P3.12.3: The Pattern Recognition Hierarchy

```
Instruction Level:
    CMP, MOV, ADD, etc.

Phrase Level:
    push rbp; mov rbp, rsp           (prologue)
    cmp eax, 0; jnz label            (conditional)

Sentence Level:
    push rbp; mov rbp, rsp; sub rsp  (function setup)

Paragraph Level:
    Entire function body              (algorithm)
```

---

## P3.13: Quick Reference Card

### Common Instruction Sequences

| Sequence | Pattern | High-Level Meaning |
|----------|---------|-------------------|
| `push rbp; mov rbp, rsp; sub rsp, N` | Prologue | Function setup |
| `leave; ret` | Epilogue | Function cleanup |
| `cmp X, Y; jg label` | Conditional | If X > Y |
| `cmp X, Y; jl label` | Conditional | If X < Y |
| `cmp X, Y; je label` | Conditional | If X == Y |
| `cmp X, Y; jne label` | Conditional | If X != Y |
| `test X, X; jz label` | Conditional | If X == 0 |
| `test X, X; jnz label` | Conditional | If X != 0 |
| `call func` | Function Call | Call function |
| `jmp label` | Unconditional Jump | Go to label |
| `xor eax, eax` | Zero | Set to 0 |
| `mov eax, 0` | Zero | Set to 0 |
| `shl eax, 1` | Multiply | Multiply by 2 |
| `shr eax, 1` | Divide | Divide by 2 |

---

**[END OF PRIMER 3]**

This primer has given you a comprehensive understanding of common assembly patterns. You should now be able to:

- Recognize function prologues and epilogues
- Identify if-else statements and switch statements
- Spot for, while, and do-while loops
- Understand data movement patterns
- Recognize compiler-specific patterns
- Spot anti-analysis techniques

**[PRIMER 3 COMPLETE]**
