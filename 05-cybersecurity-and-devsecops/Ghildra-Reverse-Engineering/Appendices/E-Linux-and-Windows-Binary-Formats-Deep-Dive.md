# Appendix E: Linux and Windows Binary Formats Deep Dive

Welcome to the comprehensive deep dive into executable binary formats. This appendix provides an exhaustive examination of the PE (Portable Executable) and ELF (Executable and Linkable Format) file structures. Understanding these formats is crucial for reverse engineering, as it allows you to navigate binaries with confidence, understand how they're loaded into memory, and identify anomalies that may indicate packing or obfuscation.

---

## E.1: ELF (Executable and Linkable Format)

### E.1.1: ELF Overview

**What is ELF?**  
ELF is the standard binary format for Unix-like operating systems including Linux, FreeBSD, and Solaris. It was designed as a flexible, extensible format that supports:
- Executable files (programs)
- Shared libraries (.so files)
- Object files (.o files)
- Core dumps

**Key Design Principles:**
- **Extensibility:** New section types can be added without breaking compatibility
- **Endian-neutral:** Supports both little-endian and big-endian architectures
- **Address independence:** Supports position-independent code (PIC)

### E.1.2: ELF Header Structure

The ELF header is the first 64 bytes of the file. It identifies the file as ELF and describes the rest of the file's structure.

**Complete ELF Header (64-bit):**

```c
typedef struct {
    unsigned char e_ident[16];    // ELF identification
    uint16_t      e_type;         // Object file type
    uint16_t      e_machine;      // Architecture
    uint32_t      e_version;      // Object file version
    uint64_t      e_entry;        // Entry point virtual address
    uint64_t      e_phoff;        // Program header table file offset
    uint64_t      e_shoff;        // Section header table file offset
    uint32_t      e_flags;        // Processor-specific flags
    uint16_t      e_ehsize;       // ELF header size in bytes
    uint16_t      e_phentsize;    // Program header table entry size
    uint16_t      e_phnum;        // Program header table entry count
    uint16_t      e_shentsize;    // Section header table entry size
    uint16_t      e_shnum;        // Section header table entry count
    uint16_t      e_shstrndx;     // Section header string table index
} Elf64_Ehdr;
```

**e_ident Field Breakdown:**

| Byte | Name | Description | Common Values |
|------|------|-------------|---------------|
| 0 | EI_MAG0 | Magic number | 0x7F |
| 1 | EI_MAG1 | Magic number | 'E' (0x45) |
| 2 | EI_MAG2 | Magic number | 'L' (0x4C) |
| 3 | EI_MAG3 | Magic number | 'F' (0x46) |
| 4 | EI_CLASS | File class | 1=32-bit, 2=64-bit |
| 5 | EI_DATA | Data encoding | 1=little-endian, 2=big-endian |
| 6 | EI_VERSION | ELF version | 1 (current) |
| 7 | EI_OSABI | OS ABI | 0=System V, 3=Linux |
| 8 | EI_ABIVERSION | ABI version | Usually 0 |
| 9-15 | EI_PAD | Padding | 0 |

**e_type Values:**

| Value | Name | Description |
|-------|------|-------------|
| 0 | ET_NONE | No file type |
| 1 | ET_REL | Relocatable file (.o) |
| 2 | ET_EXEC | Executable file |
| 3 | ET_DYN | Shared object (.so) |
| 4 | ET_CORE | Core dump |

**e_machine Values:**

| Value | Architecture |
|-------|--------------|
| 0x03 | Intel 386 |
| 0x06 | Intel 486 |
| 0x3E | AMD x86-64 |
| 0x28 | ARM |
| 0xB7 | ARM64 (AArch64) |

**Viewing ELF Header:**

```bash
# Using readelf
readelf -h /bin/ls

# Using objdump
objdump -f /bin/ls
```

### E.1.3: Program Headers (Segments)

Program headers describe how the file should be loaded into memory. They're used by the dynamic loader.

**Program Header Structure:**

```c
typedef struct {
    uint32_t   p_type;    // Segment type
    uint32_t   p_flags;   // Segment flags (read/write/execute)
    uint64_t   p_offset;  // File offset
    uint64_t   p_vaddr;   // Virtual address in memory
    uint64_t   p_paddr;   // Physical address (usually same as vaddr)
    uint64_t   p_filesz;  // Size in file
    uint64_t   p_memsz;   // Size in memory
    uint64_t   p_align;   // Alignment
} Elf64_Phdr;
```

**Common Segment Types:**

| Type | Name | Description |
|------|------|-------------|
| PT_LOAD | Loadable Segment | Actual code/data that's loaded into memory |
| PT_DYNAMIC | Dynamic Segment | Dynamic linking information |
| PT_INTERP | Interpreter | Path to dynamic linker (/ld-linux.so) |
| PT_NOTE | Note Segment | Extra information (ABI, build ID) |
| PT_PHDR | Program Header | Location of program headers themselves |
| PT_GNU_STACK | GNU Stack | Stack permissions (executable or not) |
| PT_GNU_RELRO | GNU RelRO | Relocation Read-Only (security) |

**Viewing Program Headers:**

```bash
# Using readelf
readelf -l /bin/ls

# Using objdump
objdump -p /bin/ls
```

### E.1.4: Section Headers

Section headers describe the sections within the file. They're used by linkers and debuggers.

**Section Header Structure:**

```c
typedef struct {
    uint32_t   sh_name;      // Section name (string table index)
    uint32_t   sh_type;      // Section type
    uint64_t   sh_flags;     // Section flags
    uint64_t   sh_addr;      // Virtual address (0 if not loaded)
    uint64_t   sh_offset;    // File offset
    uint64_t   sh_size;      // Section size
    uint32_t   sh_link;      // Link to another section
    uint32_t   sh_info;      // Additional information
    uint64_t   sh_addralign; // Alignment
    uint64_t   sh_entsize;   // Entry size (for arrays)
} Elf64_Shdr;
```

**Common Section Types:**

| Type | Name | Description |
|------|------|-------------|
| SHT_NULL | NULL | Null section |
| SHT_PROGBITS | Program Bits | Code or initialized data |
| SHT_SYMTAB | Symbol Table | Symbol table for debugging |
| SHT_STRTAB | String Table | String table for symbol names |
| SHT_RELA | Relocation (with addend) | Relocation information |
| SHT_DYNAMIC | Dynamic | Dynamic linking information |
| SHT_NOTE | Note | Extra information |
| SHT_NOBITS | No Bits | Uninitialized data (doesn't take file space) |
| SHT_REL | Relocation (without addend) | Relocation information |

**Common Section Names:**

| Section | Purpose |
|---------|---------|
| .text | Executable code |
| .data | Initialized global data |
| .bss | Uninitialized global data |
| .rodata | Read-only data (strings, constants) |
| .plt | Procedure Linkage Table (imported functions) |
| .got | Global Offset Table (dynamic linking) |
| .got.plt | GOT for PLT |
| .dynamic | Dynamic linking information |
| .dynsym | Dynamic symbol table |
| .dynstr | Dynamic string table |
| .shstrtab | Section header string table |
| .comment | Compiler version string |
| .debug_info | DWARF debugging information |
| .eh_frame | Exception handling frame |

**Viewing Sections:**

```bash
# List all sections
readelf -S /bin/ls

# Show section contents
objdump -s -j .rodata /bin/ls
```

### E.1.5: Dynamic Linking in ELF

**The Dynamic Section:**

The `.dynamic` section contains information needed for dynamic linking:

```bash
# View dynamic section
readelf -d /bin/ls
```

**Key Dynamic Tags:**

| Tag | Description |
|-----|-------------|
| DT_NEEDED | Required shared library (e.g., "libc.so.6") |
| DT_SONAME | Shared library name |
| DT_INIT | Initialization function address |
| DT_FINI | Finalization function address |
| DT_RPATH | Runtime search path |
| DT_RUNPATH | Runtime search path (preferred) |
| DT_STRTAB | String table address |
| DT_SYMTAB | Symbol table address |
| DT_REL / DT_RELA | Relocation table |
| DT_JMPREL | PLT relocation table |
| DT_VERNEED | Version dependencies |

**Global Offset Table (GOT):**

The GOT is used for position-independent code. It holds addresses of symbols that are resolved at runtime.

**Procedure Linkage Table (PLT):**

The PLT is used to call functions from shared libraries. On the first call, the PLT resolves the function address via the dynamic linker.

### E.1.6: ELF Analysis in Ghidra

**Importing ELF:**

When you import an ELF file into Ghidra:
1. Ghidra parses the ELF header
2. Identifies the entry point
3. Maps program headers to memory blocks
4. Analyzes sections and symbols
5. Applies appropriate processor module

**Key Ghidra Views for ELF:**

| View | Purpose |
|------|---------|
| Program Trees | Shows ELF sections and segments |
| Symbol Table | Shows functions and global variables |
| Memory Map | Shows loaded memory layout |

---

## E.2: PE (Portable Executable)

### E.2.1: PE Overview

**What is PE?**  
PE is the executable format used by Windows. It's derived from the Common Object File Format (COFF). PE files include:
- Executables (.exe)
- Dynamic Link Libraries (.dll)
- Kernel drivers (.sys)
- Control Panel files (.cpl)

**Key Components:**
- **DOS Header:** Legacy stub for backward compatibility
- **NT Headers:** Main executable information
- **Section Headers:** Describe each section
- **Sections:** Code, data, resources, etc.

### E.2.2: DOS Header

The DOS header is the first 64 bytes of the PE file. It contains a DOS program stub that prints "This program cannot be run in DOS mode."

**DOS Header Structure:**

```c
typedef struct {
    uint16_t e_magic;      // Magic number ("MZ")
    uint16_t e_cblp;       // Bytes on last page of file
    uint16_t e_cp;         // Pages in file
    uint16_t e_crlc;       // Relocations
    uint16_t e_cparhdr;    // Size of header in paragraphs
    uint16_t e_minalloc;   // Minimum extra paragraphs needed
    uint16_t e_maxalloc;   // Maximum extra paragraphs needed
    uint16_t e_ss;         // Initial SS value
    uint16_t e_sp;         // Initial SP value
    uint16_t e_csum;       // Checksum
    uint16_t e_ip;         // Initial IP value
    uint16_t e_cs;         // Initial CS value
    uint16_t e_lfarlc;     // File address of relocation table
    uint16_t e_ovno;       // Overlay number
    uint16_t e_res[4];     // Reserved
    uint16_t e_oemid;      // OEM identifier
    uint16_t e_oeminfo;    // OEM information
    uint16_t e_res2[10];   // Reserved
    uint32_t e_lfanew;     // File address of NT headers
} IMAGE_DOS_HEADER;
```

**Viewing DOS Header:**

```bash
# Using hexdump
hexdump -C -n 64 program.exe

# Using Ghidra's Program Trees
```

### E.2.3: NT Headers

The NT headers contain the main executable information. They're located at the offset specified by `e_lfanew`.

**NT Headers Structure:**

```c
typedef struct {
    uint32_t Signature;  // PE signature ("PE\x00\x00")
    IMAGE_FILE_HEADER FileHeader;
    IMAGE_OPTIONAL_HEADER OptionalHeader;
} IMAGE_NT_HEADERS;
```

**File Header:**

```c
typedef struct {
    uint16_t Machine;           // Target machine
    uint16_t NumberOfSections;  // Number of sections
    uint32_t TimeDateStamp;     // Compilation timestamp
    uint32_t PointerToSymbolTable;
    uint32_t NumberOfSymbols;
    uint16_t SizeOfOptionalHeader;
    uint16_t Characteristics;   // File characteristics (flags)
} IMAGE_FILE_HEADER;
```

**Machine Types:**

| Value | Architecture |
|-------|--------------|
| 0x014C | Intel 386 |
| 0x0200 | Intel Itanium |
| 0x8664 | AMD x86-64 |
| 0xAA64 | ARM64 |
| 0x01C0 | ARM Thumb |

**Characteristics Flags:**

| Flag | Description |
|------|-------------|
| 0x0001 | Relocation info stripped |
| 0x0002 | Executable image |
| 0x0200 | Debug info stripped |
| 0x2000 | DLL (vs. executable) |

**Optional Header:**

```c
typedef struct {
    // Standard fields
    uint16_t Magic;              // 0x10B (32-bit) or 0x20B (64-bit)
    uint8_t MajorLinkerVersion;
    uint8_t MinorLinkerVersion;
    uint32_t SizeOfCode;
    uint32_t SizeOfInitializedData;
    uint32_t SizeOfUninitializedData;
    uint32_t AddressOfEntryPoint;
    uint32_t BaseOfCode;
    
    // Windows-specific (64-bit: BaseOfData is omitted)
    uint64_t ImageBase;
    uint32_t SectionAlignment;
    uint32_t FileAlignment;
    uint16_t MajorOperatingSystemVersion;
    uint16_t MinorOperatingSystemVersion;
    uint16_t MajorImageVersion;
    uint16_t MinorImageVersion;
    uint16_t MajorSubsystemVersion;
    uint16_t MinorSubsystemVersion;
    uint32_t Win32VersionValue;
    uint32_t SizeOfImage;
    uint32_t SizeOfHeaders;
    uint32_t CheckSum;
    uint16_t Subsystem;
    uint16_t DllCharacteristics;
    uint64_t SizeOfStackReserve;
    uint64_t SizeOfStackCommit;
    uint64_t SizeOfHeapReserve;
    uint64_t SizeOfHeapCommit;
    uint32_t LoaderFlags;
    uint32_t NumberOfRvaAndSizes;
    IMAGE_DATA_DIRECTORY DataDirectory[16];
} IMAGE_OPTIONAL_HEADER64;
```

**Subsystem Values:**

| Value | Subsystem |
|-------|-----------|
| 1 | Native (no subsystem) |
| 2 | Windows GUI |
| 3 | Windows Console |
| 7 | POSIX subsystem |

**Data Directories:**

| Index | Directory |
|-------|-----------|
| 0 | Export Table |
| 1 | Import Table |
| 2 | Resource Table |
| 3 | Exception Table |
| 4 | Security Table |
| 5 | Base Relocation Table |
| 6 | Debug Table |
| 7 | Architecture-specific |
| 8 | Global Pointer |
| 9 | TLS Table |
| 10 | Load Configuration |
| 11 | Bound Import |
| 12 | Import Address Table (IAT) |
| 13 | Delay Import |
| 14 | CLR Runtime Header |

**Viewing NT Headers:**

```bash
# Using dumpbin (Visual Studio)
dumpbin /HEADERS program.exe

# Using Ghidra's Program Trees
```

### E.2.4: Section Headers

Section headers describe the sections of the PE file.

**Section Header Structure:**

```c
typedef struct {
    uint8_t Name[8];          // Section name
    uint32_t VirtualSize;      // Size when loaded
    uint32_t VirtualAddress;   // RVA (Relative Virtual Address)
    uint32_t SizeOfRawData;    // Size in file
    uint32_t PointerToRawData; // File offset
    uint32_t PointerToRelocations;
    uint32_t PointerToLinenumbers;
    uint16_t NumberOfRelocations;
    uint16_t NumberOfLinenumbers;
    uint32_t Characteristics;  // Section flags
} IMAGE_SECTION_HEADER;
```

**Common Sections:**

| Section | Purpose |
|---------|---------|
| .text | Executable code (most common) |
| .rdata | Read-only data (strings, constants) |
| .data | Initialized global data |
| .bss | Uninitialized global data |
| .reloc | Base relocation table |
| .pdata | Exception handling information |
| .rsrc | Resources (icons, dialogs, manifests) |
| .edata | Export data |
| .idata | Import data |
| .tls | Thread Local Storage |
| .crt | C runtime initialization |

**Section Characteristics:**

| Flag | Description |
|------|-------------|
| 0x00000020 | Contains executable code |
| 0x00000040 | Contains initialized data |
| 0x00000080 | Contains uninitialized data |
| 0x02000000 | Discardable |
| 0x10000000 | Shared |
| 0x20000000 | Executable |
| 0x40000000 | Readable |
| 0x80000000 | Writable |

**Viewing Sections:**

```bash
# Using dumpbin
dumpbin /SECTIONS program.exe

# Using Ghidra's Program Trees
```

### E.2.5: Imports and Exports

**Import Table:**

The import table lists functions imported from other DLLs.

**Import Descriptor Structure:**

```c
typedef struct {
    uint32_t OriginalFirstThunk; // RVA of import lookup table (ILT)
    uint32_t TimeDateStamp;
    uint32_t ForwarderChain;
    uint32_t Name;               // RVA of DLL name
    uint32_t FirstThunk;         // RVA of Import Address Table (IAT)
} IMAGE_IMPORT_DESCRIPTOR;
```

**Import Lookup Table (ILT):**

The ILT contains hint/name pairs for imported functions. Each entry is:
- If bit 31/63 is set: ordinal import
- Otherwise: RVA of a hint/name structure

**Import Address Table (IAT):**

The IAT is a writable section that is patched by the loader with the actual function addresses.

**Export Table:**

The export table lists functions exported by a DLL.

**Export Directory Structure:**

```c
typedef struct {
    uint32_t Characteristics;
    uint32_t TimeDateStamp;
    uint16_t MajorVersion;
    uint16_t MinorVersion;
    uint32_t Name;               // RVA of DLL name
    uint32_t Base;               // Ordinal base
    uint32_t NumberOfFunctions;
    uint32_t NumberOfNames;
    uint32_t AddressOfFunctions; // RVA of function addresses
    uint32_t AddressOfNames;     // RVA of function names
    uint32_t AddressOfNameOrdinals; // RVA of ordinals
} IMAGE_EXPORT_DIRECTORY;
```

**Viewing Imports/Exports:**

```bash
# View imports
dumpbin /IMPORTS program.exe

# View exports (for DLLs)
dumpbin /EXPORTS library.dll
```

### E.2.6: PE Analysis in Ghidra

**Importing PE:**

When you import a PE file into Ghidra:
1. Ghidra parses DOS and NT headers
2. Maps sections to memory blocks
3. Identifies entry point
4. Parses import/export tables
5. Loads system libraries for function labels

**Key Ghidra Views for PE:**

| View | Purpose |
|------|---------|
| Program Trees | Shows PE sections and headers |
| Symbol Table | Shows imports and exports |
| Memory Map | Shows loaded memory layout |

---

## E.3: Comparing ELF and PE

### E.3.1: Structural Comparison

| Aspect | ELF | PE |
|--------|-----|-----|
| **Magic Number** | 0x7F, 'E', 'L', 'F' | 'M', 'Z' (DOS) then 'P', 'E' |
| **Header Location** | Start of file | After DOS header |
| **Table Type** | Program headers (segments) | Section headers |
| **Entry Point** | `e_entry` | `AddressOfEntryPoint` |
| **Dynamic Linking** | `.dynamic` section | Import tables |
| **Relocations** | Relocation sections | Base relocation table |

### E.3.2: Memory Layout Comparison

**ELF Memory Layout:**

```
+------------------+
| Stack            | (High addresses)
+------------------+
| Shared Libraries |
+------------------+
| Heap             |
+------------------+
| Data Segment     |
| - .data          |
| - .bss           |
+------------------+
| Code Segment     |
| - .text          |
| - .rodata        |
+------------------+
| ELF Header       | (Low addresses)
+------------------+
```

**PE Memory Layout:**

```
+------------------+
| Stack            | (High addresses)
+------------------+
| Heap             |
+------------------+
| DLLs             |
+------------------+
| Data Section     |
| - .data          |
| - .bss           |
+------------------+
| Code Section     |
| - .text          |
| - .rdata         |
+------------------+
| NT Headers       |
| DOS Header       | (Low addresses)
+------------------+
```

### E.3.3: Similarities

Both formats:
- Have a header describing the file
- Divide code/data into sections/segments
- Support dynamic linking
- Have entry points
- Support debugging information

---

## E.4: Common Anomalies in Binary Formats

### E.4.1: Packing Indicators

| Indicator | ELF | PE |
|-----------|-----|-----|
| **High Entropy** | All sections | All sections |
| **Small .text** | .text small, .data large | .text small, .data large |
| **Strange Entry Point** | Entry point in unusual section | Entry point outside .text |
| **Strange Section Names** | UPX, pack0, pack1 | UPX0, UPX1, .aspack |
| **Few Imports** | Very few dynamic symbols | Very few imports |

**Detecting Packing with Entropy:**

```bash
# Using binexplorer (Linux)
binexplorer -e -p /path/to/binary

# Using Ghidra's entropy analysis
# Analyze → Analyze → Entropy Analysis
```

### E.4.2: Obfuscation Techniques

| Technique | Description | Detection |
|-----------|-------------|-----------|
| **String Encryption** | Strings are XORed or encrypted | Look for decryption loops |
| **Control Flow Flattening** | Obfuscated control flow | Complex jump tables |
| **API Hashing** | APIs resolved by hash | Look for hash functions |
| **Dynamic API Resolution** | APIs resolved at runtime | Few imports in IAT |

### E.4.3: Malware Indicators

| Indicator | Description |
|-----------|-------------|
| **Suspicious Import Patterns** | LoadLibrary, GetProcAddress |
| **Packed Sections** | High entropy, strange section names |
| **Anti-Analysis Code** | IsDebuggerPresent, NtQueryInformationProcess |
| **Suspicious Entry Point** | Entry point not at main |
| **Strange Overlay** | Additional data after file end |

---

## E.5: Practical Analysis Commands

### E.5.1: ELF Analysis Commands

```bash
# View ELF header
readelf -h binary

# View program headers (segments)
readelf -l binary

# View section headers
readelf -S binary

# View dynamic section
readelf -d binary

# View symbol table
readelf -s binary

# View string table
readelf -p .strtab binary

# View raw bytes of a section
objdump -s -j .text binary

# Disassemble the entire binary
objdump -d binary

# Disassemble with source code (if available)
objdump -S binary

# View imported libraries
ldd binary

# View build ID
readelf -n binary | grep "Build ID"
```

### E.5.2: PE Analysis Commands

```bash
# View DOS and NT headers
dumpbin /HEADERS program.exe

# View sections
dumpbin /SECTION program.exe

# View imports
dumpbin /IMPORTS program.exe

# View exports
dumpbin /EXPORTS program.exe

# View resources
dumpbin /RESOURCES program.exe

# View base relocations
dumpbin /RELOCS program.exe

# View all headers (comprehensive)
dumpbin /ALL program.exe

# Disassemble (using objdump/objconv)
objdump -d program.exe

# View strings
strings program.exe

# Calculate entropy (using Ghidra or custom tools)
```

---

## E.6: Ghidra Scripts for Format Analysis

### E.6.1: ELF Analysis Script

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ELF Format Analysis Script
Extracts and displays ELF header information
"""

from __future__ import print_function

def analyze_elf_header():
    """Analyze ELF header information."""
    if not currentProgram:
        print("[!] No program loaded.")
        return
    
    # Get the ELF header from program memory
    memory = currentProgram.getMemory()
    
    # ELF magic is at address 0
    # In Ghidra, programs are loaded at image base
    image_base = currentProgram.getImageBase()
    
    try:
        # Check magic
        magic = getBytes(image_base, 4)
        if magic != b'\x7fELF':
            print("[!] Not an ELF file!")
            return
        
        print("\n" + "="*80)
        print("ELF HEADER ANALYSIS")
        print("="*80)
        print("[*] File: {}".format(currentProgram.getName()))
        
        # Read ELF header fields
        # e_ident[EI_CLASS] at offset 4
        elf_class = getByte(image_base.add(4))
        print("[*] Class: {}".format("64-bit" if elf_class == 2 else "32-bit"))
        
        # e_ident[EI_DATA] at offset 5
        data_encoding = getByte(image_base.add(5))
        print("[*] Data Encoding: {}".format(
            "Little-endian" if data_encoding == 1 else "Big-endian"))
        
        # e_ident[EI_OSABI] at offset 7
        osabi = getByte(image_base.add(7))
        print("[*] OS ABI: {}".format("Linux" if osabi == 3 else "System V"))
        
        # e_type at offset 16 (16-bit)
        e_type = getShort(image_base.add(16))
        type_map = {
            0: "ET_NONE", 1: "ET_REL", 2: "ET_EXEC", 
            3: "ET_DYN", 4: "ET_CORE"
        }
        print("[*] File Type: {}".format(type_map.get(e_type, "Unknown")))
        
        # e_machine at offset 18 (16-bit)
        e_machine = getShort(image_base.add(18))
        machine_map = {
            0x03: "Intel 386", 0x06: "Intel 486",
            0x3E: "AMD x86-64", 0x28: "ARM", 0xB7: "ARM64"
        }
        print("[*] Architecture: {}".format(
            machine_map.get(e_machine, "Unknown")))
        
        # e_entry at offset 24 (64-bit) or 24 (32-bit)
        if elf_class == 2:  # 64-bit
            entry = getLong(image_base.add(24))
        else:  # 32-bit
            entry = getInt(image_base.add(24))
        print("[*] Entry Point: 0x{:08x}".format(entry))
        
        # e_phoff at offset 32
        if elf_class == 2:
            phoff = getLong(image_base.add(32))
        else:
            phoff = getInt(image_base.add(32))
        print("[*] Program Header Offset: 0x{:08x}".format(phoff))
        
        # e_shoff at offset 40
        if elf_class == 2:
            shoff = getLong(image_base.add(40))
        else:
            shoff = getInt(image_base.add(40))
        print("[*] Section Header Offset: 0x{:08x}".format(shoff))
        
        # e_phnum at offset 56 (16-bit)
        phnum = getShort(image_base.add(56))
        print("[*] Number of Program Headers: {}".format(phnum))
        
        # e_shnum at offset 58 (16-bit)
        shnum = getShort(image_base.add(58))
        print("[*] Number of Section Headers: {}".format(shnum))
        
        print("="*80 + "\n")
        
    except MemoryAccessException:
        print("[!] Failed to read memory.")

def main():
    analyze_elf_header()

if __name__ == "__main__":
    main()
```

### E.6.2: PE Analysis Script

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
PE Format Analysis Script
Extracts and displays PE header information
"""

from __future__ import print_function

def analyze_pe_header():
    """Analyze PE header information."""
    if not currentProgram:
        print("[!] No program loaded.")
        return
    
    image_base = currentProgram.getImageBase()
    
    try:
        # Check DOS header
        dos_magic = getBytes(image_base, 2)
        if dos_magic != b'MZ':
            print("[!] Not a PE file!")
            return
        
        print("\n" + "="*80)
        print("PE HEADER ANALYSIS")
        print("="*80)
        print("[*] File: {}".format(currentProgram.getName()))
        
        # Read e_lfanew (offset 0x3C)
        nt_offset = getInt(image_base.add(0x3C))
        print("[*] NT Headers at offset: 0x{:08x}".format(nt_offset))
        
        # Check PE signature
        pe_sig = getBytes(image_base.add(nt_offset), 4)
        if pe_sig != b'PE\x00\x00':
            print("[!] Invalid PE signature!")
            return
        print("[*] PE Signature: Found")
        
        # Read File Header
        offset = nt_offset + 4
        machine = getShort(image_base.add(offset))
        machine_map = {
            0x014C: "Intel 386",
            0x8664: "AMD x86-64",
            0xAA64: "ARM64"
        }
        print("[*] Machine: {}".format(machine_map.get(machine, "Unknown")))
        
        num_sections = getShort(image_base.add(offset + 2))
        print("[*] Number of Sections: {}".format(num_sections))
        
        timestamp = getInt(image_base.add(offset + 4))
        import datetime
        print("[*] Timestamp: {}".format(
            datetime.datetime.fromtimestamp(timestamp).strftime(
                '%Y-%m-%d %H:%M:%S')))
        
        # Read Optional Header
        offset += 20  # Skip rest of File Header
        magic = getShort(image_base.add(offset))
        is_64bit = (magic == 0x20B)
        print("[*] Optional Header: {}".format("PE32+" if is_64bit else "PE32"))
        
        offset += 2
        entry_point = getInt(image_base.add(offset))
        print("[*] Entry Point RVA: 0x{:08x}".format(entry_point))
        print("[*] Entry Point VA: 0x{:08x}".format(image_base.getOffset() + entry_point))
        
        offset += 4
        image_base_va = getLong(image_base.add(offset)) if is_64bit else getInt(image_base.add(offset))
        print("[*] Image Base: 0x{:08x}".format(image_base_va))
        
        # Section Alignment
        offset += 8 if is_64bit else 4
        section_align = getInt(image_base.add(offset))
        print("[*] Section Alignment: 0x{:08x}".format(section_align))
        
        # Subsystem
        # Move to Subsystem (offset depends on field count)
        # For simplicity, we'll use Ghidra's analysis
        print("="*80 + "\n")
        
    except MemoryAccessException:
        print("[!] Failed to read memory.")

def main():
    analyze_pe_header()

if __name__ == "__main__":
    main()
```

---

## Summary

This appendix has provided an in-depth exploration of ELF and PE binary formats. You now understand:

- **ELF Format:** Headers, program headers, sections, and dynamic linking
- **PE Format:** DOS headers, NT headers, sections, imports, and exports
- **Format Comparison:** Key differences and similarities between ELF and PE
- **Anomaly Detection:** Identifying packing, obfuscation, and malware indicators
- **Practical Analysis:** Commands and scripts for format analysis

With this knowledge, you can navigate any binary with confidence, understanding exactly what each part does and how it contributes to the program's execution.

---

**[END OF APPENDIX E]**
