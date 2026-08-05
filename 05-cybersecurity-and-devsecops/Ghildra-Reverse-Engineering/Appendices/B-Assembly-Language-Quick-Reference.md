# Appendix B: Assembly Language Quick Reference

Welcome to the Assembly Language Quick Reference. This appendix serves as your cheat sheet for understanding x86/x64 assembly instructions commonly encountered during reverse engineering. Think of this as your decoder ring—when you see unfamiliar instructions in the Listing window, refer back here to understand what's happening.

---

## B.1: x86/x64 Architecture Overview

### B.1.1: Register Reference

**General Purpose Registers (x86 - 32-bit):**

| 32-bit | 16-bit | 8-bit (Low) | 8-bit (High) | Purpose |
|--------|--------|-------------|--------------|---------|
| EAX | AX | AL | AH | Accumulator (math operations, return values) |
| EBX | BX | BL | BH | Base (pointers, indexing) |
| ECX | CX | CL | CH | Counter (loops, shifts) |
| EDX | DX | DL | DH | Data (math, I/O) |
| ESI | SI | - | - | Source Index (string operations) |
| EDI | DI | - | - | Destination Index (string operations) |
| EBP | BP | - | - | Base Pointer (stack frames) |
| ESP | SP | - | - | Stack Pointer (top of stack) |
| EIP | IP | - | - | Instruction Pointer (current instruction) |

**General Purpose Registers (x86_64 - 64-bit):**

| 64-bit | 32-bit | 16-bit | 8-bit | Purpose |
|--------|--------|--------|-------|---------|
| RAX | EAX | AX | AL/AH | Accumulator |
| RBX | EBX | BX | BL/BH | Base |
| RCX | ECX | CX | CL/CH | Counter |
| RDX | EDX | DX | DL/DH | Data |
| RSI | ESI | SI | SIL | Source Index |
| RDI | EDI | DI | DIL | Destination Index |
| RBP | EBP | BP | BPL | Base Pointer |
| RSP | ESP | SP | SPL | Stack Pointer |
| RIP | EIP | IP | - | Instruction Pointer |
| R8-R15 | R8D-R15D | R8W-R15W | R8B-R15B | Additional registers |

**Segment Registers:**
| Register | Purpose |
|----------|---------|
| CS | Code Segment |
| DS | Data Segment |
| SS | Stack Segment |
| ES | Extra Segment |
| FS | Extra Segment (Windows TLS) |
| GS | Extra Segment (Linux thread-local) |

**Flags Register (EFLAGS):**

| Flag | Bit | Description |
|------|-----|-------------|
| CF | 0 | Carry Flag (unsigned overflow) |
| PF | 2 | Parity Flag (even parity) |
| AF | 4 | Auxiliary Carry Flag (BCD) |
| ZF | 6 | Zero Flag (result is zero) |
| SF | 7 | Sign Flag (result is negative) |
| TF | 8 | Trap Flag (single-step) |
| IF | 9 | Interrupt Enable Flag |
| DF | 10 | Direction Flag (string operations) |
| OF | 11 | Overflow Flag (signed overflow) |

### B.1.2: Calling Conventions

**x86 (32-bit) Calling Conventions:**

| Convention | Parameter Order | Stack Cleanup | Return Value |
|------------|-----------------|---------------|--------------|
| **cdecl** (C) | Right to left (push) | Caller | EAX |
| **stdcall** (Windows) | Right to left (push) | Callee | EAX |
| **fastcall** | ECX, EDX, then stack | Callee | EAX |
| **thiscall** (C++) | ECX (this), then stack | Callee | EAX |

**x86_64 (64-bit) Calling Conventions:**

| Convention | Parameter Registers | Additional Parameters | Return Value |
|------------|---------------------|----------------------|--------------|
| **System V** (Linux) | RDI, RSI, RDX, RCX, R8, R9 | Stack | RAX, RDX |
| **Microsoft x64** (Windows) | RCX, RDX, R8, R9 | Stack | RAX |

**Linux x86_64 System V Example:**
```c
int func(int a, int b, int c, int d, int e, int f, int g) {
    return a + b + c + d + e + f + g;
}
```
Becomes:
```assembly
func:
    push rbp
    mov rbp, rsp
    
    ; Arguments: a=RDI, b=RSI, c=RDX, d=RCX, e=R8, f=R9
    ; g is on the stack at [RBP+0x10]
    
    add eax, edi      ; a
    add eax, esi      ; + b
    add eax, edx      ; + c
    add eax, ecx      ; + d
    add eax, r8d      ; + e
    add eax, r9d      ; + f
    add eax, [rbp+0x10] ; + g
    
    pop rbp
    ret
```

---

## B.2: Instruction Set Reference

### B.2.1: Data Movement Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `MOV dest, src` | Copy data | `mov eax, 0x10` |
| `MOVSX dest, src` | Move with sign extension | `movsx eax, byte ptr [ecx]` |
| `MOVZX dest, src` | Move with zero extension | `movzx eax, byte ptr [ecx]` |
| `XCHG a, b` | Exchange values | `xchg eax, ebx` |
| `LEA dest, src` | Load Effective Address | `lea eax, [ebx+0x10]` |
| `PUSH src` | Push onto stack | `push eax` |
| `POP dest` | Pop from stack | `pop eax` |
| `PUSHA` | Push all registers | - |
| `POPA` | Pop all registers | - |
| `MOVS` | Move string (byte) | `movs byte ptr [edi], [esi]` |
| `MOVSD` | Move string (dword) | `movs dword ptr [edi], [esi]` |
| `MOVSB` | Move string (byte) | - |
| `MOVSW` | Move string (word) | - |

**LEA vs MOV Example:**
```assembly
; LEA computes address without accessing memory
lea eax, [ebx + ecx*4]  ; eax = ebx + ecx*4

; MOV would access memory at that address
mov eax, [ebx + ecx*4]  ; eax = *((ebx + ecx*4))
```

### B.2.2: Arithmetic Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `ADD dest, src` | Add | `add eax, 0x10` |
| `SUB dest, src` | Subtract | `sub eax, 0x10` |
| `INC dest` | Increment by 1 | `inc eax` |
| `DEC dest` | Decrement by 1 | `dec eax` |
| `MUL src` | Unsigned multiply (EAX * src) | `mul ebx` |
| `IMUL src` | Signed multiply | `imul ebx` |
| `DIV src` | Unsigned divide (EAX / src) | `div ebx` |
| `IDIV src` | Signed divide | `idiv ebx` |
| `NEG dest` | Negate (two's complement) | `neg eax` |
| `ADC dest, src` | Add with carry | `adc eax, ebx` |
| `SBB dest, src` | Subtract with borrow | `sbb eax, ebx` |

**Division Example:**
```assembly
; Divide EAX by EBX
mov eax, 0x100
mov ebx, 0x10
xor edx, edx      ; Clear EDX (for unsigned division)
div ebx           ; EAX = 0x10, EDX = 0x0 (remainder)

; For signed division, use CDQ first
mov eax, -0x100
cdq               ; Sign extend EAX into EDX:EAX
idiv ebx          ; EAX = -0x10
```

### B.2.3: Logical Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `AND dest, src` | Bitwise AND | `and eax, 0x0F` |
| `OR dest, src` | Bitwise OR | `or eax, 0xF0` |
| `XOR dest, src` | Bitwise XOR | `xor eax, eax` (zero) |
| `NOT dest` | Bitwise NOT | `not eax` |
| `SHL dest, count` | Shift Left | `shl eax, 2` |
| `SHR dest, count` | Shift Right | `shr eax, 2` |
| `SAR dest, count` | Arithmetic Shift Right | `sar eax, 2` |
| `ROL dest, count` | Rotate Left | `rol eax, 1` |
| `ROR dest, count` | Rotate Right | `ror eax, 1` |
| `RCL dest, count` | Rotate through Carry Left | `rcl eax, 1` |
| `RCR dest, count` | Rotate through Carry Right | `rcr eax, 1` |
| `TEST a, b` | AND without storing result | `test eax, eax` |

**XOR Zeroing Trick:**
```assembly
; These are equivalent, but XOR is faster
mov eax, 0         ; 5 bytes
xor eax, eax       ; 2 bytes (faster, smaller)
```

### B.2.4: Control Transfer Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `JMP dest` | Unconditional jump | `jmp 0x401000` |
| `CALL dest` | Call function | `call printf` |
| `RET` | Return from function | `ret` |
| `RET n` | Return and pop n bytes | `ret 0x10` |
| `INT n` | Software interrupt | `int 0x80` (Linux syscall) |
| `IRET` | Return from interrupt | - |

**Conditional Jumps (Based on EFLAGS):**

| Instruction | Condition | When it Jumps |
|-------------|-----------|---------------|
| `JE` / `JZ` | Equal / Zero | ZF = 1 |
| `JNE` / `JNZ` | Not Equal / Not Zero | ZF = 0 |
| `JG` / `JNLE` | Greater (signed) | ZF=0 and SF=OF |
| `JGE` / `JNL` | Greater or Equal (signed) | SF = OF |
| `JL` / `JNGE` | Less (signed) | SF != OF |
| `JLE` / `JNG` | Less or Equal (signed) | ZF=1 or SF!=OF |
| `JA` / `JNBE` | Above (unsigned) | CF=0 and ZF=0 |
| `JAE` / `JNB` | Above or Equal (unsigned) | CF = 0 |
| `JB` / `JC` / `JNAE` | Below / Carry (unsigned) | CF = 1 |
| `JBE` / `JNA` | Below or Equal (unsigned) | CF=1 or ZF=1 |
| `JS` | Sign | SF = 1 |
| `JNS` | Not Sign | SF = 0 |
| `JO` | Overflow | OF = 1 |
| `JNO` | No Overflow | OF = 0 |
| `JP` / `JPE` | Parity / Even | PF = 1 |
| `JNP` / `JPO` | No Parity / Odd | PF = 0 |
| `JCXZ` | CX register zero | CX = 0 |
| `JECXZ` | ECX register zero | ECX = 0 |

**Example: Condition Checking**
```assembly
; if (a > b) goto label
cmp eax, ebx      ; Compare EAX and EBX
jg greater_label   ; Jump if EAX > EBX (signed)

; if (a == b) goto label
cmp eax, ebx
je equal_label

; if (a != 0) goto label
test eax, eax
jne not_zero
```

### B.2.5: Comparison Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `CMP a, b` | Compare (sets flags) | `cmp eax, ebx` |
| `TEST a, b` | AND without storing | `test eax, eax` |
| `CMPXCHG dest, src` | Compare and exchange | `cmpxchg [eax], ebx` |

### B.2.6: Stack Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `PUSH src` | Push onto stack | `push eax` |
| `POP dest` | Pop from stack | `pop eax` |
| `PUSHAD` | Push all registers (32-bit) | - |
| `POPAD` | Pop all registers (32-bit) | - |
| `PUSHA` | Push all registers (16-bit) | - |
| `POPA` | Pop all registers (16-bit) | - |
| `ENTER` | Create stack frame | `enter 0x10, 0` |
| `LEAVE` | Destroy stack frame | `leave` |

### B.2.7: System Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `SYSENTER` | Fast system call (x86) | - |
| `SYSCALL` | Fast system call (x64) | - |
| `INT 0x80` | Linux system call (x86) | - |
| `HLT` | Halt processor | - |
| `NOP` | No operation | `nop` |
| `IN` | Input from port | `in eax, dx` |
| `OUT` | Output to port | `out dx, eax` |

### B.2.8: Special Instructions

| Instruction | Description | Example |
|-------------|-------------|---------|
| `XCHG` | Exchange operands | `xchg eax, ebx` |
| `BSF` | Bit Scan Forward | `bsf eax, ebx` |
| `BSR` | Bit Scan Reverse | `bsr eax, ebx` |
| `BT` | Bit Test | `bt eax, 5` |
| `BTS` | Bit Test and Set | `bts eax, 5` |
| `BTR` | Bit Test and Reset | `btr eax, 5` |
| `BTC` | Bit Test and Complement | `btc eax, 5` |

---

## B.3: Operand Types

### B.3.1: Register Operands

```assembly
; Direct register usage
mov eax, ebx     ; Copy EBX to EAX

; Using specific parts of a register
mov al, byte ptr [ecx]   ; AL = lower 8 bits of EAX
mov ax, word ptr [ecx]   ; AX = lower 16 bits of EAX
mov eax, dword ptr [ecx] ; EAX = all 32 bits
mov rax, qword ptr [rcx] ; RAX = all 64 bits
```

### B.3.2: Memory Operands

```assembly
; Direct memory address
mov eax, [0x00401000]

; Register indirect
mov eax, [ebx]           ; Address in EBX

; Base + offset
mov eax, [ebx + 0x10]    ; EBX + 0x10

; Base + index * scale
mov eax, [ebx + ecx*4]   ; EBX + ECX*4

; Base + index * scale + offset
mov eax, [ebx + ecx*4 + 0x10]

; Full form
mov eax, [ebp - 0x10]    ; Local variable
mov eax, [ebp + 0x10]    ; Parameter
```

### B.3.3: Size Specifiers

| Size | Specifier | Example |
|------|-----------|---------|
| 1 byte | `byte ptr` | `mov al, byte ptr [eax]` |
| 2 bytes | `word ptr` | `mov ax, word ptr [eax]` |
| 4 bytes | `dword ptr` | `mov eax, dword ptr [eax]` |
| 8 bytes | `qword ptr` (x64) | `mov rax, qword ptr [rax]` |
| 10 bytes | `tbyte ptr` | `fld tbyte ptr [eax]` |

---

## B.4: Common Code Patterns

### B.4.1: Function Prologue

**x86:**
```assembly
push ebp          ; Save previous frame pointer
mov ebp, esp      ; Set new frame pointer
sub esp, 0x20     ; Allocate local variables (32 bytes)
```

**x86_64:**
```assembly
push rbp          ; Save previous frame pointer
mov rbp, rsp      ; Set new frame pointer
sub rsp, 0x30     ; Allocate local variables (48 bytes)
```

### B.4.2: Function Epilogue

**x86:**
```assembly
mov esp, ebp      ; Deallocate locals (or use leave)
pop ebp           ; Restore previous frame pointer
ret               ; Return to caller
```

**x86_64:**
```assembly
leave             ; mov rsp, rbp; pop rbp
ret               ; Return to caller
```

### B.4.3: If-Else Pattern

**C Code:**
```c
if (a > b) {
    result = a;
} else {
    result = b;
}
```

**x86_64 Assembly:**
```assembly
cmp eax, ebx      ; Compare a and b
jle else_label    ; If a <= b, jump to else
mov ecx, eax      ; result = a
jmp end_label
else_label:
mov ecx, ebx      ; result = b
end_label:
```

### B.4.4: Loop Pattern

**C Code:**
```c
for (int i = 0; i < 10; i++) {
    sum += i;
}
```

**x86_64 Assembly:**
```assembly
xor eax, eax      ; sum = 0
xor ecx, ecx      ; i = 0
loop_start:
cmp ecx, 0x0A     ; Compare i with 10
jge loop_end      ; Exit if i >= 10
add eax, ecx      ; sum += i
inc ecx           ; i++
jmp loop_start
loop_end:
```

### B.4.5: Switch Statement Pattern

**C Code:**
```c
switch (value) {
    case 1: do_case1(); break;
    case 2: do_case2(); break;
    case 3: do_case3(); break;
    default: do_default();
}
```

**Assembly (Jump Table):**
```assembly
; Jump table at address table_addr
mov eax, [value]
cmp eax, 3
ja default_case
jmp [table_addr + eax*4]

; Jump table entries:
; table_addr:   dd case1, case2, case3, default
```

### B.4.6: String Operations

**C Code:**
```c
strcpy(dest, src);
```

**Assembly:**
```assembly
; Using REP MOVS (fast string copy)
mov esi, src      ; Source pointer
mov edi, dest     ; Destination pointer
mov ecx, length   ; Length in bytes
rep movsb         ; Copy ECX bytes

; Using a loop
xor ecx, ecx
loop_start:
mov al, [esi + ecx]
mov [edi + ecx], al
inc ecx
cmp ecx, length
jne loop_start
```

---

## B.5: Common System Calls (Linux x86_64)

### B.5.1: Linux x86_64 System Call Table

| System Call | Number | Arguments |
|-------------|--------|-----------|
| `read` | 0 | RDI (fd), RSI (buf), RDX (count) |
| `write` | 1 | RDI (fd), RSI (buf), RDX (count) |
| `open` | 2 | RDI (pathname), RSI (flags), RDX (mode) |
| `close` | 3 | RDI (fd) |
| `socket` | 41 | RDI (domain), RSI (type), RDX (protocol) |
| `connect` | 42 | RDI (sockfd), RSI (addr), RDX (addrlen) |
| `execve` | 59 | RDI (filename), RSI (argv), RDX (envp) |
| `exit` | 60 | RDI (status) |

**System Call Example:**
```assembly
; Write "Hello" to stdout
mov rax, 1        ; syscall number (write)
mov rdi, 1        ; file descriptor (stdout)
lea rsi, [hello]  ; buffer address
mov rdx, 5        ; length
syscall           ; invoke syscall

hello: db 'Hello', 0x0A
```

---

## B.6: Common Windows API Calls

### B.6.1: Windows API Categories

| Category | Example APIs | Description |
|----------|--------------|-------------|
| **File** | `CreateFileA`, `ReadFile`, `WriteFile`, `DeleteFileA` | File operations |
| **Registry** | `RegOpenKeyExA`, `RegSetValueExA`, `RegGetValueA` | Registry operations |
| **Process** | `CreateProcessA`, `OpenProcess`, `TerminateProcess` | Process management |
| **Thread** | `CreateThread`, `TerminateThread`, `SuspendThread` | Thread management |
| **Memory** | `VirtualAlloc`, `VirtualFree`, `VirtualProtect` | Memory management |
| **Network** | `WSAStartup`, `socket`, `connect`, `send`, `recv` | Networking |
| **Window** | `FindWindowA`, `SendMessageA`, `PostMessageA` | UI operations |
| **Security** | `IsDebuggerPresent`, `CheckRemoteDebuggerPresent` | Anti-debugging |

### B.6.2: Windows x64 API Calling Convention

```assembly
; Windows x64 API Call Example
; MessageBox(NULL, "Hello", "Title", MB_OK)

push rbp
mov rbp, rsp
sub rsp, 0x20     ; Shadow space

xor rcx, rcx      ; hWnd = NULL (first param)
lea rdx, [hello]  ; lpText (second param)
lea r8, [title]   ; lpCaption (third param)
mov r9, 0         ; uType = MB_OK (fourth param)
call MessageBoxA

; ... after call, RAX contains result
```

---

## B.7: Ghidra Decompiler Patterns

### B.7.1: Common Decompiler Patterns

| Assembly Pattern | Decompiler Output | Meaning |
|------------------|-------------------|---------|
| `cmp eax, 0; je label` | `if (eax == 0) { ... }` | Equality check |
| `test eax, eax; jnz label` | `if (eax != 0) { ... }` | Non-zero check |
| `mov eax, [ebp+0x8]` | `param_1` | Parameter access |
| `mov eax, [ebp-0x4]` | `local_4` | Local variable access |
| `call func` | `func();` | Function call |
| `push 0x10; pop eax` | `eax = 0x10` | Constant assignment |
| `lea eax, [edx+ecx*2]` | `eax = edx + ecx * 2` | Arithmetic expression |

### B.7.2: Decompiler Variables

| Naming Pattern | Meaning |
|----------------|---------|
| `param_1`, `param_2` | Function parameters (from right to left) |
| `local_x` | Local variables (x = offset) |
| `iVar1` | Integer variable (i = int) |
| `uVar2` | Unsigned variable (u = unsigned) |
| `lVar3` | Long variable |
| `bVar4` | Boolean variable |
| `ppVar5` | Pointer to pointer |
| `FUN_00401000` | Unnamed function |

### B.7.3: Common Decompiler Constructs

**While Loop:**
```c
while (local_4 < 10) {
    sum = sum + local_4;
    local_4 = local_4 + 1;
}
```

**If/Else:**
```c
if (local_4 == 0) {
    local_8 = 1;
} else {
    local_8 = 2;
}
```

**Switch:**
```c
switch(local_4) {
    case 0:
        local_8 = 1;
        break;
    case 1:
        local_8 = 2;
        break;
    default:
        local_8 = 3;
}
```

**Structure Access:**
```c
// Raw pointer access
*(int *)(param_1 + 0x10)

// After applying structure
param_1->field_name
```

---

## B.8: Quick Reference Tables

### B.8.1: Operand Size and Encoding

| Operand Size | Suffix | Example |
|--------------|--------|---------|
| 1 byte (8-bit) | `b` | `movb` |
| 2 bytes (16-bit) | `w` | `movw` |
| 4 bytes (32-bit) | `l` | `movl` |
| 8 bytes (64-bit) | `q` | `movq` |

### B.8.2: AT&T vs Intel Syntax

| AT&T Syntax | Intel Syntax | Description |
|-------------|--------------|-------------|
| `movl $0x10, %eax` | `mov eax, 0x10` | Move immediate |
| `movl -0x10(%ebp), %eax` | `mov eax, [ebp-0x10]` | Memory access |
| `movl (%eax), %ebx` | `mov ebx, [eax]` | Register indirect |
| `call *%eax` | `call eax` | Call register |
| `jmp *0x401000` | `jmp [0x401000]` | Jump to address |
| `ret` | `ret` | Return |
| `leave` | `leave` | Leave frame |

---

This appendix provides essential assembly knowledge for reverse engineering. Keep it handy as a quick reference, and don't hesitate to refer back to it when analyzing unfamiliar code patterns. Understanding assembly is the foundation of effective reverse engineering—with practice, reading assembly becomes second nature.
