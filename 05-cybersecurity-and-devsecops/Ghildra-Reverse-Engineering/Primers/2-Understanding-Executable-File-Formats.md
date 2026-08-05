# Primer 2: Understanding Executable File Formats (PE and ELF)

Welcome to the second primer of our "Zero to Hero" series. This primer provides a comprehensive, beginner-friendly deep dive into executable file formats. Before you can effectively analyze binaries in Ghidra, you need to understand what's actually inside those binary files. Think of this primer as learning how to read the "table of contents" and "chapter structure" of a book before you start reading the actual content.

---

## P2.1: Why Executable File Formats Matter

### P2.1.1: The Big Picture

When you write a program and compile it, the compiler doesn't just produce raw machine code. It creates a structured file that contains:

1. **Headers:** Information about the file itself (what kind of file it is, where things are located)
2. **Code:** The actual machine instructions to execute
3. **Data:** Constants, strings, and initialized variables
4. **Metadata:** Information for the operating system about how to load and run the program
5. **Debug Information:** (Optional) Symbols, line numbers, and type information for debugging

**Think of it like a shipping container:**

Imagine you're shipping furniture across the ocean. You don't just throw the furniture onto a ship—you pack it in a container with:
- A manifest listing what's inside (header)
- Properly secured furniture in specific locations (code and data sections)
- Instructions for unloading (metadata)
- Labels for delivery (import/export information)

An executable file is exactly the same concept. The operating system needs this structure to load the program into memory and run it.

### P2.1.2: The Two Major Formats

There are two dominant executable formats you'll encounter:

| Format | Operating System | Common File Extensions |
|--------|------------------|----------------------|
| **PE** (Portable Executable) | Windows | `.exe`, `.dll`, `.sys`, `.cpl` |
| **ELF** (Executable and Linkable Format) | Linux, Unix-like | No extension (or `.so`, `.o`) |

**Why two formats?** Historical and architectural reasons. Windows and Linux have different loading mechanisms, system call interfaces, and memory management models. The executable format reflects these differences.

**Mac users:** macOS uses the Mach-O format, which is similar in concept to ELF but with different specifics. We won't cover Mach-O in detail, but many of the ELF concepts apply.

---

## P2.2: The PE (Portable Executable) Format

### P2.2.1: PE Overview

The PE format is used by Windows for executables, DLLs, drivers, and other binary types. It's derived from the older COFF (Common Object File Format) and was introduced with Windows NT.

**Key components of a PE file:**

```
+---------------------------+
|     DOS Header            |  <- First 64 bytes
+---------------------------+
|     DOS Stub              |  <- Program that prints "This program cannot be run in DOS mode"
+---------------------------+
|     NT Headers            |  <- "PE\0\0" signature + File Header + Optional Header
|     - File Header         |
|     - Optional Header     |
+---------------------------+
|     Section Headers       |  <- Descriptions of each section
+---------------------------+
|     Sections              |  <- Actual code and data
|     - .text (code)        |
|     - .data (data)        |
|     - .rdata (read-only)  |
|     - .rsrc (resources)   |
+---------------------------+
|     Import/Export Data    |  <- Function imports and exports
+---------------------------+
```

### P2.2.2: DOS Header

The PE file starts with a 64-byte **DOS Header**. This exists for backward compatibility with MS-DOS.

**Think of it like a time capsule:** When Windows runs a PE file, it ignores the DOS header. But if you try to run a PE file in DOS, the DOS header contains a small program that prints an error message.

**Key fields in the DOS Header:**

| Field | Offset | Size | Meaning |
|-------|--------|------|---------|
| `e_magic` | 0 | 2 bytes | Magic number: `MZ` (0x4D5A) |
| `e_lfanew` | 60 | 4 bytes | Offset to the NT Headers |

**Viewing the DOS Header in Ghidra:**

When you import a PE file, Ghidra shows the DOS Header in the Program Trees. You can see:
- The `MZ` signature
- The DOS stub program
- The offset to the NT Headers

### P2.2.3: NT Headers

The NT Headers are the main metadata for the PE file. They start at the offset specified by `e_lfanew`.

**NT Headers Structure:**

```c
typedef struct {
    uint32_t Signature;              // "PE\0\0"
    IMAGE_FILE_HEADER FileHeader;    // Basic file information
    IMAGE_OPTIONAL_HEADER OptionalHeader;  // Advanced information
} IMAGE_NT_HEADERS;
```

**File Header:**

| Field | Size | Meaning |
|-------|------|---------|
| `Machine` | 2 bytes | CPU architecture (0x14C = x86, 0x8664 = x64) |
| `NumberOfSections` | 2 bytes | How many sections in the file |
| `TimeDateStamp` | 4 bytes | Compilation timestamp |
| `Characteristics` | 2 bytes | Flags (executable, DLL, etc.) |

**Optional Header (Key Fields):**

| Field | Size (32-bit) | Size (64-bit) | Meaning |
|-------|---------------|---------------|---------|
| `Magic` | 2 | 2 | 0x10B = 32-bit, 0x20B = 64-bit |
| `AddressOfEntryPoint` | 4 | 4 | Entry point (RVA) |
| `ImageBase` | 4 | 8 | Preferred load address |
| `SectionAlignment` | 4 | 4 | Memory alignment |
| `FileAlignment` | 4 | 4 | File alignment |
| `SizeOfImage` | 4 | 4 | Total size in memory |
| `Subsystem` | 2 | 2 | GUI, Console, Native, etc. |
| `NumberOfRvaAndSizes` | 4 | 4 | Number of data directories |
| `DataDirectory[16]` | 16 each | 16 each | 16 directories (import, export, resources, etc.) |

**What is an RVA?** RVA stands for Relative Virtual Address. It's an offset from the ImageBase. For example, if ImageBase is 0x00400000 and AddressOfEntryPoint is 0x1000, the entry point is at 0x00401000.

**Viewing NT Headers in Ghidra:**

In the Program Trees, expand "PE Headers" to see:
- File Header
- Optional Header
- Data Directories

### P2.2.4: Sections

After the NT Headers come the Section Headers. Each section in the PE file has a corresponding Section Header.

**Section Header Structure:**

```c
typedef struct {
    uint8_t Name[8];          // Section name (e.g., ".text")
    uint32_t VirtualSize;     // Size in memory
    uint32_t VirtualAddress;  // RVA in memory
    uint32_t SizeOfRawData;   // Size in file
    uint32_t PointerToRawData;// File offset
    uint32_t Characteristics; // Flags (read, write, execute)
} IMAGE_SECTION_HEADER;
```

**Common PE Sections:**

| Section | Purpose | Typical Permissions |
|---------|---------|---------------------|
| `.text` | Executable code | Read + Execute |
| `.data` | Initialized global data | Read + Write |
| `.rdata` | Read-only data (strings, constants) | Read only |
| `.bss` | Uninitialized global data | Read + Write |
| `.rsrc` | Resources (icons, dialogs, manifests) | Read only |
| `.reloc` | Base relocation table | Read only |
| `.pdata` | Exception handling | Read only |
| `.idata` | Import data | Read + Write |
| `.edata` | Export data | Read only |
| `.tls` | Thread Local Storage | Read + Write |

**Section Characteristics Flags:**

| Flag | Meaning |
|------|---------|
| 0x00000020 | Contains executable code |
| 0x00000040 | Contains initialized data |
| 0x00000080 | Contains uninitialized data |
| 0x20000000 | Executable |
| 0x40000000 | Readable |
| 0x80000000 | Writable |

**Viewing Sections in Ghidra:**

In the Program Trees, expand "Sections" to see all sections. Click on a section to see:
- Its start and end addresses
- Its permissions
- The data it contains

### P2.2.5: Imports and Exports

**Import Table:**
The import table lists all the functions the program uses from other DLLs (Dynamic Link Libraries).

**Think of it like a shopping list:** The program needs to use functions from Windows system libraries. The import table is the list of what it needs to buy from those stores.

**Key import-related structures:**

1. **Import Lookup Table (ILT):** Contains function names or ordinals
2. **Import Address Table (IAT):** Contains addresses that the loader fills in
3. **Import Descriptor:** One per imported DLL

**Viewing Imports in Ghidra:**

In the Symbol Tree, expand "Imports" to see all imported functions. You can also see them in the Program Trees under "Data Directories" → "Import Directory".

**Export Table:**

The export table is used by DLLs to list the functions they make available to other programs.

**Think of it like a menu:** The DLL is a restaurant, and the export table is the menu showing what dishes (functions) it offers.

**Viewing Exports in Ghidra:**

In the Symbol Tree, expand "Exports" to see all exported functions. This is primarily used when analyzing DLLs.

---

## P2.3: The ELF (Executable and Linkable Format)

### P2.3.1: ELF Overview

ELF is the standard executable format for Linux and other Unix-like systems. It's more flexible than PE and supports various file types: executables, shared libraries (.so), object files (.o), and core dumps.

**Key components of an ELF file:**

```
+---------------------------+
|     ELF Header            |  <- First 64 bytes
+---------------------------+
|     Program Headers       |  <- For executables (segments)
|     (Segments)            |
+---------------------------+
|     Sections              |  <- For linking and debugging
|     - .text (code)        |
|     - .data (data)        |
|     - .rodata (read-only) |
|     - .bss (uninitialized)|
|     - .symtab (symbols)   |
|     - .strtab (strings)   |
+---------------------------+
|     Section Headers       |  <- Descriptions of each section
+---------------------------+
```

### P2.3.2: ELF Header

The ELF header is the first 64 bytes of the file. It identifies the file as ELF and describes the rest of the structure.

**ELF Header Structure:**

```c
typedef struct {
    uint8_t e_ident[16];     // ELF identification
    uint16_t e_type;         // Object file type
    uint16_t e_machine;      // Architecture
    uint32_t e_version;      // Object file version
    uint64_t e_entry;        // Entry point address
    uint64_t e_phoff;        // Program header offset
    uint64_t e_shoff;        // Section header offset
    uint32_t e_flags;        // Processor-specific flags
    uint16_t e_ehsize;       // ELF header size
    uint16_t e_phentsize;    // Program header entry size
    uint16_t e_phnum;        // Number of program headers
    uint16_t e_shentsize;    // Section header entry size
    uint16_t e_shnum;        // Number of section headers
    uint16_t e_shstrndx;     // Section header string table index
} Elf64_Ehdr;
```

**e_ident Magic Bytes:**

| Byte | Value | Meaning |
|------|-------|---------|
| 0 | 0x7F | Magic number |
| 1 | 0x45 | 'E' |
| 2 | 0x4C | 'L' |
| 3 | 0x46 | 'F' |
| 4 | 1 or 2 | 32-bit or 64-bit |
| 5 | 1 or 2 | Little-endian or Big-endian |
| 6 | 1 | ELF version |
| 7 | 0 or 3 | System V or Linux |

**e_type (File Types):**

| Value | Name | Meaning |
|-------|------|---------|
| 1 | ET_REL | Relocatable file (.o) |
| 2 | ET_EXEC | Executable file |
| 3 | ET_DYN | Shared library (.so) |
| 4 | ET_CORE | Core dump |

**e_machine (Architecture):**

| Value | Architecture |
|-------|--------------|
| 0x03 | Intel 386 |
| 0x3E | AMD x86-64 |
| 0x28 | ARM |
| 0xB7 | ARM64 (AArch64) |

**Viewing the ELF Header:**

```bash
readelf -h binary
```

**Example Output:**
```
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              DYN (Position-Independent Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x5a30
  Start of program headers:          64 (bytes into file)
  Start of section headers:          171352 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         13
  Size of section headers:           64 (bytes)
  Number of section headers:         31
  Section header string table index: 30
```

### P2.3.3: Program Headers (Segments)

Program headers describe how the file should be loaded into memory. They're used by the operating system's loader.

**Think of it like a moving company's inventory:** Each program header describes a "segment" of the file that should be loaded into a specific location in memory.

**Program Header Structure:**

```c
typedef struct {
    uint32_t p_type;     // Segment type
    uint32_t p_flags;    // Segment permissions
    uint64_t p_offset;   // File offset
    uint64_t p_vaddr;    // Virtual address in memory
    uint64_t p_paddr;    // Physical address (usually same)
    uint64_t p_filesz;   // Size in file
    uint64_t p_memsz;    // Size in memory
    uint64_t p_align;    // Alignment
} Elf64_Phdr;
```

**Common Segment Types:**

| Type | Name | Meaning |
|------|------|---------|
| PT_LOAD | Loadable Segment | Code or data loaded into memory |
| PT_DYNAMIC | Dynamic Segment | Information for dynamic linking |
| PT_INTERP | Interpreter | Path to dynamic linker |
| PT_NOTE | Note Segment | Extra information (ABI, Build ID) |
| PT_PHDR | Program Header | Location of program headers themselves |
| PT_GNU_STACK | GNU Stack | Stack permissions (executable or not) |
| PT_GNU_RELRO | GNU RelRO | Relocation Read-Only (security feature) |

**Viewing Program Headers:**

```bash
readelf -l binary
```

**Example Output:**
```
Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  PHDR           0x0000000000000040 0x0000000000000040 0x0000000000000040
                 0x00000000000002d8 0x00000000000002d8  R      0x8
  INTERP         0x0000000000000318 0x0000000000000318 0x0000000000000318
                 0x000000000000001c 0x000000000000001c  R      0x1
      [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
  LOAD           0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000022a00 0x0000000000022a00  R E    0x200000
  LOAD           0x0000000000022a00 0x0000000000022a00 0x0000000000022a00
                 0x0000000000001d30 0x0000000000002a70  RW     0x200000
  DYNAMIC        0x0000000000022a28 0x0000000000022a28 0x0000000000022a28
                 0x00000000000001a0 0x00000000000001a0  RW     0x8
  NOTE           0x0000000000000338 0x0000000000000338 0x0000000000000338
                 0x0000000000000020 0x0000000000000020  R      0x8
  GNU_STACK      0x0000000000000000 0x0000000000000000 0x0000000000000000
                 0x0000000000000000 0x0000000000000000  RW     0x10
  GNU_RELRO      0x0000000000022a00 0x0000000000022a00 0x0000000000022a00
                 0x00000000000005d0 0x00000000000005d0  R      0x1
```

### P2.3.4: Sections

Sections are used primarily for linking and debugging. The operating system doesn't use them directly for loading (it uses program headers instead).

**Section Header Structure:**

```c
typedef struct {
    uint32_t sh_name;       // Section name (string table index)
    uint32_t sh_type;       // Section type
    uint64_t sh_flags;      // Section flags
    uint64_t sh_addr;       // Virtual address (0 if not loaded)
    uint64_t sh_offset;     // File offset
    uint64_t sh_size;       // Section size
    uint32_t sh_link;       // Link to another section
    uint32_t sh_info;       // Additional information
    uint64_t sh_addralign;  // Alignment
    uint64_t sh_entsize;    // Entry size (for arrays)
} Elf64_Shdr;
```

**Common ELF Sections:**

| Section | Purpose | Type |
|---------|---------|------|
| `.text` | Executable code | SHT_PROGBITS |
| `.data` | Initialized global data | SHT_PROGBITS |
| `.bss` | Uninitialized global data | SHT_NOBITS |
| `.rodata` | Read-only data (strings, constants) | SHT_PROGBITS |
| `.plt` | Procedure Linkage Table (dynamic calls) | SHT_PROGBITS |
| `.got` | Global Offset Table (dynamic data) | SHT_PROGBITS |
| `.dynamic` | Dynamic linking information | SHT_DYNAMIC |
| `.dynsym` | Dynamic symbol table | SHT_DYNSYM |
| `.dynstr` | Dynamic string table | SHT_STRTAB |
| `.symtab` | Symbol table | SHT_SYMTAB |
| `.strtab` | String table | SHT_STRTAB |
| `.shstrtab` | Section header string table | SHT_STRTAB |
| `.debug_info` | DWARF debugging information | SHT_PROGBITS |
| `.eh_frame` | Exception handling frame | SHT_PROGBITS |

**Viewing Sections:**

```bash
readelf -S binary
```

### P2.3.5: Dynamic Linking

ELF supports two types of linking:
1. **Static Linking:** Everything is in one file (no shared libraries needed)
2. **Dynamic Linking:** Uses shared libraries (libc.so, etc.)

**Dynamic linking components:**

1. **Program Header INTERP:** Points to `/lib64/ld-linux-x86-64.so.2` (the dynamic linker)
2. **.dynamic Section:** Contains information for the dynamic linker
3. **.plt (Procedure Linkage Table):** Stubs for calling library functions
4. **.got (Global Offset Table):** Addresses of library functions and data

**Viewing Dynamic Information:**

```bash
readelf -d binary
```

**Example Output:**
```
Dynamic section at offset 0x2a28 contains 25 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x000000000000000c (INIT)               0x401000
 0x000000000000000d (FINI)               0x402000
 0x0000000000000019 (INIT_ARRAY)         0x402a28
 0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
 0x000000000000001a (FINI_ARRAY)         0x402a30
 0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
 0x0000000000000004 (HASH)               0x4002b0
 0x0000000000000005 (STRTAB)             0x400418
 0x0000000000000006 (SYMTAB)             0x4002d8
 0x000000000000000a (STRSZ)              94 (bytes)
 0x000000000000000b (SYMENT)             24 (bytes)
 0x0000000000000015 (DEBUG)              0x0
 0x0000000000000003 (PLTGOT)             0x402c00
 0x0000000000000002 (PLTRELSZ)           48 (bytes)
 0x0000000000000014 (PLTREL)             RELA
 0x0000000000000017 (JMPREL)             0x4004b0
 0x0000000000000007 (RELA)               0x4004a0
 0x0000000000000008 (RELASZ)             12 (bytes)
 0x0000000000000009 (RELAENT)            24 (bytes)
 0x000000000000001e (FLAGS)              BIND_NOW
 0x000000000000001f (RELACOUNT)          1
 0x000000006ffffffe (VERNEED)            0x400490
 0x000000006fffffff (VERNEEDNUM)         1
 0x0000000000000000 (NULL)               0x0
```

---

## P2.4: PE vs ELF Comparison

### P2.4.1: Structural Comparison

| Aspect | PE | ELF |
|--------|-----|-----|
| **Magic Number** | 0x4D5A ("MZ") then "PE\0\0" | 0x7F454C46 ("\x7FELF") |
| **Header Style** | DOS + NT Headers | ELF Header |
| **Load Information** | Optional Header | Program Headers |
| **Component Descriptions** | Section Headers | Section Headers |
| **Dynamic Information** | Import/Export Tables | .dynamic Section |
| **Entry Point** | AddressOfEntryPoint (RVA) | e_entry (VA) |

### P2.4.2: Memory Layout Comparison

**PE Memory Layout:**
```
Higher addresses:
+---------------------------+
| Stack                     |
+---------------------------+
| Heap                      |
+---------------------------+
| DLLs (shared libraries)   |
+---------------------------+
| Data Section              |
| - .data, .bss, .rdata     |
+---------------------------+
| Code Section              |
| - .text                   |
+---------------------------+
| NT Headers                |
+---------------------------+
| DOS Header                |
Lower addresses:
```

**ELF Memory Layout:**
```
Higher addresses:
+---------------------------+
| Stack                     |
+---------------------------+
| Shared Libraries          |
+---------------------------+
| Heap                      |
+---------------------------+
| Data Segment              |
| - .data, .bss             |
+---------------------------+
| Code Segment              |
| - .text, .rodata          |
+---------------------------+
| ELF Header                |
Lower addresses:
```

### P2.4.3: Similarities

Despite their differences, PE and ELF share many concepts:

| Concept | PE | ELF |
|---------|-----|-----|
| **Header** | DOS + NT Headers | ELF Header |
| **Sections** | Section Headers | Section Headers |
| **Dynamic Linking** | Import/Export Tables | .dynamic section |
| **Entry Point** | AddressOfEntryPoint | e_entry |
| **Relocations** | Base Relocation Table | Relocation Sections |
| **Debug Information** | Debug Directory | DWARF Sections |

---

## P2.5: Analyzing Executables in Ghidra

### P2.5.1: Import Process

When you import a binary into Ghidra:

1. **For PE files:**
   - Ghidra reads the DOS Header and finds the NT Headers
   - It parses the File Header and Optional Header
   - It maps sections to memory blocks
   - It reads the Import Directory to identify DLLs and functions
   - It reads the Export Directory (if present)

2. **For ELF files:**
   - Ghidra reads the ELF Header
   - It parses the Program Headers to identify segments
   - It maps segments to memory blocks
   - It reads the .dynamic section for dynamic linking information
   - It reads the symbol table (if present)

### P2.5.2: What Ghidra Shows

**In the Program Trees:**

| PE Views | ELF Views |
|----------|-----------|
| DOS Header | ELF Header |
| NT Headers | Program Headers |
| - File Header | Sections |
| - Optional Header | - .text, .data, etc. |
| Sections | |
| - .text, .data, etc. | |
| Data Directories | |
| - Import Directory | |
| - Export Directory | |

**In the Symbol Tree:**

| Symbols | Meaning |
|---------|---------|
| Functions | User code functions |
| Imports (PE) / External (ELF) | Library functions |
| Labels | Data and code labels |
| Strings | Defined strings |

### P2.5.3: Common Ghidra Tasks

**Finding the Entry Point:**
1. In Program Trees, look for the entry point address
2. For PE: Optional Header → AddressOfEntryPoint
3. For ELF: ELF Header → e_entry
4. Navigate to that address in the Listing

**Locating Imports:**
1. In Symbol Tree, expand "Imports" (PE) or "External" (ELF)
2. See all imported functions grouped by library

**Finding Strings:**
1. Window → Defined Strings
2. Search for specific strings or patterns
3. Right-click → Show References to trace usage

**Viewing Section Information:**
1. In Program Trees, expand "Sections" (PE) or "Sections" (ELF)
2. Click on a section to see details
3. Use the Listing to view the contents

---

## P2.6: Practical Exercises

### P2.6.1: Exercise 1 - PE Headers

1. Find any `.exe` file on your system (e.g., `notepad.exe`)
2. Open it in Ghidra (import it)
3. In Program Trees, examine:
   - DOS Header: Find the `e_magic` and `e_lfanew` values
   - NT Headers: Find the File Header and Optional Header
   - Sections: Find the `.text` and `.data` sections
   - Imports: Find what DLLs and functions it imports

**Questions to answer:**
- What's the entry point address?
- What subsystem does it use (GUI or Console)?
- What's the ImageBase?
- How many sections does it have?

### P2.6.2: Exercise 2 - ELF Headers

1. Find any ELF binary on your system (e.g., `/bin/ls`)
2. Open it in Ghidra
3. In Program Trees, examine:
   - ELF Header: Find the magic bytes and entry point
   - Program Headers: Find the PT_LOAD segments
   - Sections: Find the `.text` and `.data` sections
   - External Symbols: Find what library functions it uses

**Questions to answer:**
- What's the entry point address?
- How many PT_LOAD segments are there?
- What's the ImageBase (use `readelf -l` to see)?
- What shared libraries does it need?

### P2.6.3: Exercise 3 - PE vs ELF Comparison

Take a simple C program and compile it for both Windows (PE) and Linux (ELF):

```c
#include <stdio.h>
int main() {
    printf("Hello, World!\n");
    return 0;
}
```

**Compilation:**
```bash
# Linux (ELF)
gcc -o hello_elf hello.c

# Windows (PE) - using MinGW
gcc -o hello_pe.exe hello.c
```

**Analysis:**
1. Open both in Ghidra
2. Compare the headers
3. Find the `printf` call in both
4. Compare how the string "Hello, World!" is stored
5. Compare the entry point code

### P2.6.4: Exercise 4 - Packed Binary Detection

Download a UPX-packed binary or pack a simple program:

```bash
# Pack an ELF binary with UPX
upx hello_elf -o hello_packed

# Or for PE
upx hello_pe.exe -o hello_packed.exe
```

**Analysis:**
1. Open the packed binary in Ghidra
2. Check the sections:
   - For UPX, you'll see sections like `.UPX0` and `.UPX1`
   - The .text section will be small
   - The .data section will be large (contains the unpacked code)
3. Check the entropy (high = packed)
4. Check the imports (few, suggests it's packed)

---

## P2.7: Common Pitfalls and Tips

### P2.7.1: Pitfalls

| Pitfall | Explanation | Solution |
|---------|-------------|----------|
| **Assuming all executables are the same** | PE and ELF are different | Learn both formats |
| **Ignoring the entry point** | Entry point is where execution starts | Always check the entry point first |
| **Assuming sections are loaded as-is** | Sections may have different alignments | Check VirtualSize vs. SizeOfRawData |
| **Ignoring imports** | Imports tell you what the program needs | Always check imports |
| **Not checking for packing** | Packing hides the real code | Check entropy, section names |

### P2.7.2: Tips

| Tip | Description |
|-----|-------------|
| **Use `readelf` / `dumpbin`** | Quick analysis without Ghidra |
| **Check the timestamp** | Can tell you when the binary was compiled |
| **Look for suspicious sections** | UPX, pack0, pack1 suggest packing |
| **Check the entry point** | Should be in .text (or near it) |
| **Use the Program Trees** | Ghidra's Program Trees show everything |
| **Check the imports** | Tells you what system functions are used |

---

## P2.8: Summary and Key Takeaways

### P2.8.1: Core Concepts

1. **PE is Windows**: DOS Header → NT Headers → Sections
2. **ELF is Linux**: ELF Header → Program Headers → Sections
3. **Headers describe the file**: Type, architecture, entry point, sections
4. **Sections contain code and data**: .text, .data, .rodata, .bss
5. **Imports show dependencies**: What system functions are used

### P2.8.2: Key Commands

| Command | Purpose |
|---------|---------|
| `readelf -h binary` | View ELF header |
| `readelf -l binary` | View ELF program headers |
| `readelf -S binary` | View ELF sections |
| `readelf -d binary` | View ELF dynamic section |
| `dumpbin /HEADERS binary.exe` | View PE headers |
| `dumpbin /IMPORTS binary.exe` | View PE imports |
| `strings binary` | Extract human-readable strings |
| `file binary` | Identify file type |

---

## P2.9: Quick Reference Card

### PE Structure

```
+---------------+
| DOS Header    | 64 bytes
+---------------+
| DOS Stub      | Variable
+---------------+
| NT Headers    |
| - Signature   | 4 bytes
| - File Header | 20 bytes
| - Opt Header  | 96/112 bytes
+---------------+
| Section Headers | 40 bytes each
+---------------+
| Sections      |
| - .text       |
| - .data       |
| - .rdata      |
| - .rsrc       |
+---------------+
```

### ELF Structure

```
+---------------+
| ELF Header    | 64 bytes
+---------------+
| Program Headers | 56 bytes each
+---------------+
| Sections      |
| - .text       |
| - .data       |
| - .rodata     |
| - .bss        |
| - .plt        |
| - .got        |
| - .dynamic    |
+---------------+
| Section Headers | 64 bytes each
+---------------+
```

---

**[END OF PRIMER 2]**

This primer has given you a comprehensive understanding of PE and ELF executable formats. You should now be able to:

- Identify PE and ELF files
- Understand the structure of both formats
- Navigate the headers and sections in Ghidra
- Recognize packing indicators
- Use command-line tools to analyze executables

**[PRIMER 2 COMPLETE]**

**[NEXT: Primer 3 - Common Assembly Patterns for Reverse Engineers]**
