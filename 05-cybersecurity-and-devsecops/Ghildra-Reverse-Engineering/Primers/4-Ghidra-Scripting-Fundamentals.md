# Primer 4: Ghidra Scripting Fundamentals

Welcome to the fourth primer of our "Zero to Hero" series. This primer provides a comprehensive, beginner-friendly introduction to scripting in Ghidra using Python. Ghidra's scripting API allows you to automate virtually every aspect of reverse engineering—from simple tasks like renaming functions to complex operations like building vulnerability scanners and decrypting encrypted data. Think of scripting as having a tireless assistant who can perform repetitive, tedious, or complex tasks while you focus on the big picture.

---

## P4.1: Introduction to Ghidra Scripting

### P4.1.1: Why Script?

**Think of it like cooking:**

| Approach | Description | Analogy |
|----------|-------------|---------|
| **Manual Analysis** | Doing everything by hand in the GUI | Cooking one meal at a time, chopping each vegetable individually |
| **Scripting** | Automating repetitive tasks | Using a food processor to chop all vegetables at once |
| **Advanced Scripting** | Building complex analysis pipelines | Having a fully automated kitchen that preps, cooks, and plates |

**Common Use Cases:**

| Task | Script Benefits |
|------|-----------------|
| **Batch Renaming** | Rename 100 functions in seconds instead of minutes |
| **IOC Extraction** | Extract all domains, IPs, and URLs from a binary instantly |
| **Pattern Detection** | Find all instances of a specific code pattern (e.g., XOR loops) |
| **Report Generation** | Create comprehensive analysis reports automatically |
| **Batch Analysis** | Analyze 100 binaries overnight instead of manually processing each |

### P4.1.2: Python vs. Other Languages

| Language | Pros | Cons | When to Use |
|----------|------|------|-------------|
| **Python** | Easy to learn, large ecosystem, readable | Slower than Java | General-purpose scripting |
| **Java** | Faster, full Ghidra API access | More verbose, steeper learning curve | Performance-critical scripts |
| **JavaScript** | Familiar for web developers | Limited Ghidra support | Lightweight UI scripting |

**Recommendation:** Start with Python. It's the most common language for Ghidra scripting and has the most community support.

### P4.1.3: Scripting Environment Setup

**Your Scripting Workspace:**

```
~/.ghidra/.ghidra_X.X_PUBLIC/
├── Scripts/          # Your custom scripts go here
│   ├── MyScript.py
│   └── utilities/
├── Extensions/       # Plugins (JAR files)
└── temp/             # Temporary files
```

**Setting Up Your Script Directory:**

1. Launch Ghidra
2. Go to `Edit` → `Options` → `Scripting`
3. Add your script directory
4. Click `OK`

**Test Your Environment:**

Open the Script Manager (`Window` → `Script Manager`) and look for your script directory in the list.

---

## P4.2: Basic Script Structure

### P4.2.1: The Minimal Script

Every Ghidra Python script starts with this structure:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script Name: My First Script
Author: Your Name
Date: 2026-03-15
Purpose: Demonstrates basic Ghidra scripting
"""

from __future__ import print_function

def main():
    """Main script entry point."""
    print("[*] Hello, Ghidra!")
    print("[*] Current program: {}".format(currentProgram.getName()))
    
    if not currentProgram:
        print("[!] No program loaded!")
        return
    
    # Your code here
    print("[*] Script complete!")

if __name__ == "__main__":
    main()
```

### P4.2.2: Essential Pre-Loaded Objects

When your script runs, Ghidra automatically provides these objects:

| Object | Type | Description |
|--------|------|-------------|
| `currentProgram` | `Program` | The currently open binary |
| `currentAddress` | `Address` | The cursor position in the listing |
| `currentSelection` | `AddressSetView` | The selected address range |
| `currentLocation` | `ProgramLocation` | The current location |
| `currentHighlight` | `AddressSetView` | The highlighted range |

### P4.2.3: Running Scripts

**Method 1: Script Manager**
1. `Window` → `Script Manager` (or `Ctrl + Shift + P`)
2. Find your script in the list
3. Double-click or click "Run"

**Method 2: Quick Run**
1. Write your script and save it
2. Press `Ctrl + Shift + R` to run the last script
3. Or click the "Run Script" button in the toolbar

**Method 3: Headless**
```bash
./support/analyzeHeadless /path/to/project project_name \
    -import binary \
    -postScript /path/to/script.py
```

---

## P4.3: Core API Concepts

### P4.3.1: The `Program` Class

The `Program` class is your entry point to everything.

```python
# Get the current program
program = currentProgram

# Basic information
name = program.getName()
path = program.getExecutable()
lang = program.getLanguage()

# Get the address factory
factory = program.getAddressFactory()
default_space = factory.getDefaultAddressSpace()
image_base = program.getImageBase()

# Get the memory
memory = program.getMemory()
```

### P4.3.2: The `Address` Class

Addresses represent memory locations in the binary.

```python
# Creating addresses
addr = toAddr(0x00401000)           # From integer
addr = currentAddress               # From GUI cursor
addr = program.getImageBase()       # Image base

# Address operations
new_addr = addr.add(0x10)           # Add offset
new_addr = addr.subtract(0x10)      # Subtract offset

# Getting information
offset = addr.getOffset()           # Numeric offset
hex_string = "0x{:08x}".format(offset)  # Hex string
```

### P4.3.3: The `Memory` Class

Reading from and writing to memory.

```python
# Reading memory
try:
    # Read bytes
    bytes_data = getBytes(addr, 16)
    
    # Read specific types
    byte_val = getByte(addr)
    short_val = getShort(addr)
    int_val = getInt(addr)
    long_val = getLong(addr)
    
except MemoryAccessException as e:
    print("[!] Memory access error: {}".format(str(e)))

# Writing memory
try:
    setByte(addr, 0x90)             # Write a NOP
    setBytes(addr, [0x90, 0x90])    # Write multiple bytes
except MemoryAccessException as e:
    print("[!] Memory access error: {}".format(str(e)))
```

### P4.3.4: The `Listing` Class

Access to disassembled instructions and data.

```python
# Get the listing
listing = currentProgram.getListing()

# Get instructions
instr = listing.getInstructionAt(addr)
instructions = listing.getInstructions(addr, True)  # True = forward

# Iterate through instructions
while instructions.hasNext():
    instr = instructions.next()
    mnemonic = instr.getMnemonicString()
    address = instr.getAddress()

# Get defined data (strings, variables)
data = listing.getDefinedData(True)
while data.hasNext():
    d = data.next()
    try:
        value = str(d.getValue())
        if len(value) > 3:
            print("String at 0x{:08x}: {}".format(
                d.getAddress().getOffset(), value))
    except:
        pass

# Get data at a specific address
data = listing.getDataAt(addr)
```

### P4.3.5: The `FunctionManager` Class

Access to functions in the program.

```python
# Get the function manager
func_manager = currentProgram.getFunctionManager()

# Get all functions
functions = func_manager.getFunctions(True)  # True = forward order
for func in functions:
    print("Function: {}".format(func.getName()))

# Get a specific function
func = func_manager.getFunctionAt(addr)
func = func_manager.getFunctionNamed("main")

# Get function count
count = func_manager.getFunctionCount()
```

### P4.3.6: The `Function` Class

Working with individual functions.

```python
# Function properties
name = func.getName()
entry = func.getEntryPoint()
body = func.getBody()
params = func.getParameters()
param_count = func.getParameterCount()
return_type = func.getReturnType()

# Rename a function
func.setName("new_name", SourceType.USER_DEFINED)

# Get called functions (outgoing)
called = func.getCalledFunctions(currentProgram)
for target in called:
    print("  Calls: {}".format(target.getName()))

# Get calling functions (incoming)
callers = func.getCallingFunctions(currentProgram)
for caller in callers:
    print("  Called by: {}".format(caller.getName()))

# Get comments
comment = func.getComment()
func.setComment("This is a comment")
```

---

## P4.4: Common Scripting Tasks

### P4.4.1: Enumerating Functions

```python
def enumerate_functions():
    """List all functions with their entry points."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    print("\n[*] Functions:")
    print("-" * 80)
    print("{:<40} {:<20} {:<10}".format(
        "Name", "Entry Point", "Parameters"))
    print("-" * 80)
    
    for func in functions:
        print("{:<40} 0x{:08x} {:<10}".format(
            func.getName()[:40],
            func.getEntryPoint().getOffset(),
            func.getParameterCount()))
    
    print("-" * 80)
    print("Total functions: {}".format(func_manager.getFunctionCount()))
```

### P4.4.2: Finding Cross-References

```python
def find_xrefs(address):
    """Find all cross-references to an address."""
    ref_manager = currentProgram.getReferenceManager()
    
    # References to this address
    refs_to = ref_manager.getReferencesTo(address)
    print("\n[*] References TO 0x{:08x}:".format(address.getOffset()))
    
    while refs_to.hasNext():
        ref = refs_to.next()
        print("  {} at 0x{:08x} ({})".format(
            ref.getSourceAddress(),
            ref.getSourceAddress().getOffset(),
            "CALL" if ref.getReferenceType().isCall() else "DATA"
        ))
    
    # References from this address
    refs_from = ref_manager.getReferencesFrom(address)
    print("\n[*] References FROM 0x{:08x}:".format(address.getOffset()))
    
    while refs_from.hasNext():
        ref = refs_from.next()
        print("  -> 0x{:08x} ({})".format(
            ref.getToAddress().getOffset(),
            "CALL" if ref.getReferenceType().isCall() else "DATA"
        ))
```

### P4.4.3: Searching for Strings

```python
def find_strings(pattern, case_sensitive=True):
    """Find strings matching a pattern."""
    listing = currentProgram.getListing()
    data = listing.getDefinedData(True)
    
    results = []
    
    while data.hasNext():
        d = data.next()
        try:
            value = str(d.getValue())
            if len(value) < 3:
                continue
            
            if not case_sensitive:
                value_lower = value.lower()
                pattern_lower = pattern.lower()
                if pattern_lower in value_lower:
                    results.append((d.getAddress(), value))
            else:
                if pattern in value:
                    results.append((d.getAddress(), value))
        except:
            continue
    
    return results
```

### P4.4.4: Batch Renaming

```python
def batch_rename_functions():
    """Rename functions based on their called functions."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    renamed_count = 0
    
    for func in functions:
        name = func.getName()
        
        # Skip already renamed functions
        if func.getSymbol().getSourceType() == SourceType.USER_DEFINED:
            continue
        
        # Analyze called functions
        called = func.getCalledFunctions(currentProgram)
        called_names = [f.getName() for f in called]
        
        # Suggest a name
        new_name = None
        
        if 'strcpy' in called_names:
            new_name = "copy_string"
        elif 'strcmp' in called_names:
            new_name = "compare_string"
        elif 'printf' in called_names or 'puts' in called_names:
            new_name = "print_output"
        elif 'malloc' in called_names or 'calloc' in called_names:
            new_name = "allocate_memory"
        elif 'free' in called_names:
            new_name = "free_memory"
        elif 'socket' in called_names:
            new_name = "create_socket"
        elif 'connect' in called_names:
            new_name = "connect_socket"
        elif 'recv' in called_names:
            new_name = "receive_data"
        elif 'send' in called_names:
            new_name = "send_data"
        
        if new_name:
            try:
                func.setName(new_name, SourceType.USER_DEFINED)
                renamed_count += 1
                print("[*] Renamed {} -> {}".format(name, new_name))
            except:
                pass
    
    print("\n[*] Renamed {} functions".format(renamed_count))
```

### P4.4.5: Creating Address Sets

```python
from ghidra.program.model.address import AddressSet

def analyze_range(start_addr, end_addr):
    """Analyze a range of addresses."""
    address_set = AddressSet(start_addr, end_addr)
    
    listing = currentProgram.getListing()
    instructions = listing.getInstructions(address_set, True)
    
    stats = {
        'total': 0,
        'calls': 0,
        'branches': 0,
        'returns': 0
    }
    
    while instructions.hasNext():
        instr = instructions.next()
        stats['total'] += 1
        
        if instr.isCall():
            stats['calls'] += 1
        elif instr.isBranch():
            stats['branches'] += 1
        elif instr.isReturn():
            stats['returns'] += 1
    
    print("[*] Range Analysis:")
    print("  Total instructions: {}".format(stats['total']))
    print("  Calls: {}".format(stats['calls']))
    print("  Branches: {}".format(stats['branches']))
    print("  Returns: {}".format(stats['returns']))
```

---

## P4.5: Advanced Scripting Techniques

### P4.5.1: Working with the Decompiler

```python
def decompile_function(func):
    """Get decompiled code for a function."""
    try:
        # Get the decompiler
        decompiler = currentProgram.getDecompilerInterface()
        
        # Decompile with 30 second timeout
        decomp_result = decompiler.decompileFunction(func, 30, None)
        
        if decomp_result:
            # Get the decompiled code
            decompiled = decomp_result.getDecompiledFunction().getC()
            print("\n[*] Decompiled {}:".format(func.getName()))
            print("-" * 80)
            print(decompiled)
            print("-" * 80)
            return decompiled
    except Exception as e:
        print("[!] Failed to decompile: {}".format(str(e)))
        return None
```

### P4.5.2: Analyzing Data Types

```python
from ghidra.program.model.data import DataTypeManager, StructureDataType

def create_structure():
    """Create and apply a custom structure."""
    # Create a structure
    struct = StructureDataType("MyStruct", 0)
    struct.add(IntDataType.dataType, 4, "field1", "First field")
    struct.add(IntDataType.dataType, 4, "field2", "Second field")
    struct.add(PointerDataType.dataType, 8, "field3", "Pointer field")
    
    # Apply at an address
    addr = toAddr(0x00402000)
    data_type_manager = currentProgram.getDataTypeManager()
    data_type_manager.addDataType(struct, None)
    
    try:
        listing = currentProgram.getListing()
        listing.setDataType(addr, struct)
        print("[*] Applied structure at 0x{:08x}".format(addr.getOffset()))
    except Exception as e:
        print("[!] Failed to apply structure: {}".format(str(e)))
```

### P4.5.3: Working with Symbols

```python
def enumerate_symbols():
    """List all symbols in the program."""
    symbol_table = currentProgram.getSymbolTable()
    symbols = symbol_table.getSymbols(True)
    
    print("\n[*] Symbols:")
    print("-" * 80)
    print("{:<40} {:<15} {:<15}".format(
        "Name", "Address", "Type"))
    print("-" * 80)
    
    while symbols.hasNext():
        symbol = symbols.next()
        print("{:<40} 0x{:08x} {:<15}".format(
            symbol.getName()[:40],
            symbol.getAddress().getOffset() if symbol.getAddress() else 0,
            symbol.getSymbolType().name() if symbol.getSymbolType() else "UNKNOWN"
        ))
```

### P4.5.4: Memory Dumping

```python
def dump_memory_region(start_addr, length, filename):
    """Dump a memory region to a file."""
    try:
        data = getBytes(start_addr, length)
        with open(filename, 'wb') as f:
            f.write(data)
        print("[*] Dumped {} bytes to {}".format(length, filename))
        return True
    except MemoryAccessException as e:
        print("[!] Failed to dump: {}".format(str(e)))
        return False

def dump_all_sections():
    """Dump all sections to files."""
    memory = currentProgram.getMemory()
    blocks = memory.getBlocks()
    
    output_dir = "{}_dump".format(
        currentProgram.getName().replace('.', '_'))
    
    import os
    try:
        os.makedirs(output_dir)
    except:
        pass
    
    while blocks.hasNext():
        block = blocks.next()
        start = block.getStart()
        end = block.getEnd()
        size = block.getSize()
        
        filename = os.path.join(output_dir, "{}.bin".format(block.getName()))
        dump_memory_region(start, size, filename)
        
        print("  Block: {}, Size: {} bytes".format(
            block.getName(), size))
```

---

## P4.6: Error Handling

### P4.6.1: Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `NameError: name 'currentProgram' is not defined` | Running outside Ghidra environment | Run script through Script Manager |
| `MemoryAccessException` | Invalid memory access | Check if address is valid |
| `AttributeError: 'NoneType' object has no attribute...` | Object is None | Add null checks |
| `IllegalArgumentException` | Invalid parameter | Validate parameters before calling |

### P4.6.2: Defensive Programming

```python
def safe_get_function(func_name):
    """Safely get a function by name."""
    try:
        func_manager = currentProgram.getFunctionManager()
        func = func_manager.getFunctionNamed(func_name)
        
        if func is None:
            print("[!] Function '{}' not found".format(func_name))
            return None
        
        return func
    except Exception as e:
        print("[!] Error getting function: {}".format(str(e)))
        return None

def safe_read_memory(addr, length):
    """Safely read memory with error handling."""
    if not currentProgram:
        return None
    
    memory = currentProgram.getMemory()
    
    # Check if the address is valid
    if not memory.contains(addr):
        print("[!] Address 0x{:08x} not in memory".format(
            addr.getOffset()))
        return None
    
    try:
        return getBytes(addr, length)
    except MemoryAccessException as e:
        print("[!] Memory read failed: {}".format(str(e)))
        return None
```

---

## P4.7: Script Optimization

### P4.7.1: Performance Tips

| Tip | Example | Why It Helps |
|-----|---------|--------------|
| **Cache objects** | `func_manager = currentProgram.getFunctionManager()` | Avoid repeated lookups |
| **Use iterators** | `while instructions.hasNext():` | More efficient than indexing |
| **Limit operations** | Process only what you need | Faster execution |
| **Batch operations** | Collect data then process | Reduce API calls |

### P4.7.2: Timing Your Scripts

```python
import time

def time_function(func):
    """Time the execution of a function."""
    start = time.time()
    result = func()
    elapsed = time.time() - start
    print("[*] {} took {:.3f} seconds".format(
        func.__name__, elapsed))
    return result
```

### P4.7.3: Progress Reporting

```python
def process_functions():
    """Process functions with progress reporting."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    total = func_manager.getFunctionCount()
    
    processed = 0
    for func in functions:
        processed += 1
        if processed % 10 == 0:  # Report every 10 functions
            print("[*] Processed {}/{} functions ({:.1f}%)".format(
                processed, total, 100 * processed / total))
        # Process function...
    
    print("[*] Complete! Processed {} functions".format(processed))
```

---

## P4.8: Practical Script Examples

### P4.8.1: Complete Function Reporter

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Function Reporter
Generates a comprehensive report on all functions
"""

from __future__ import print_function
import csv
import datetime

def generate_function_report():
    """Generate a complete function report."""
    if not currentProgram:
        print("[!] No program loaded!")
        return
    
    print("\n" + "=" * 80)
    print("[*] Function Report Generator")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("[*] Date: {}".format(datetime.datetime.now()))
    print("=" * 80 + "\n")
    
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    # Collect data
    report_data = []
    
    for func in functions:
        body = func.getBody()
        listing = currentProgram.getListing()
        instructions = listing.getInstructions(body, True)
        
        # Count instructions
        instr_count = 0
        branch_count = 0
        call_count = 0
        
        while instructions.hasNext():
            instr = instructions.next()
            instr_count += 1
            
            if instr.isBranch():
                branch_count += 1
            elif instr.isCall():
                call_count += 1
        
        # Get function info
        func_data = {
            'name': func.getName(),
            'address': "0x{:08x}".format(func.getEntryPoint().getOffset()),
            'parameters': func.getParameterCount(),
            'instructions': instr_count,
            'branches': branch_count,
            'calls': call_count,
            'is_user_defined': func.getSymbol().getSourceType() == SourceType.USER_DEFINED
        }
        report_data.append(func_data)
    
    # Sort by instruction count (largest first)
    report_data.sort(key=lambda x: x['instructions'], reverse=True)
    
    # Print summary
    print("[*] Summary:")
    print("  Total functions: {}".format(len(report_data)))
    print("  User defined: {}".format(
        sum(1 for f in report_data if f['is_user_defined'])))
    print("  Total instructions: {}".format(
        sum(f['instructions'] for f in report_data)))
    print("")
    
    # Print top 10 functions by size
    print("[*] Top 10 Largest Functions:")
    print("-" * 80)
    print("{:<40} {:<12} {:<8} {:<6}".format(
        "Function", "Address", "Instr", "Branches"))
    print("-" * 80)
    
    for func in report_data[:10]:
        print("{:<40} {:<12} {:<8} {:<6}".format(
            func['name'][:40],
            func['address'],
            func['instructions'],
            func['branches']))
    
    print("-" * 80)
    
    # Save to CSV
    filename = "{}_functions.csv".format(
        currentProgram.getName().replace('.', '_'))
    
    with open(filename, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=report_data[0].keys())
        writer.writeheader()
        writer.writerows(report_data)
    
    print("\n[*] Report saved to: {}".format(filename))
    print("=" * 80)

if __name__ == "__main__":
    generate_function_report()
```

### P4.8.2: Complete IOC Extractor

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
IOC Extractor
Extracts domains, IPs, URLs, and registry keys from the binary
"""

from __future__ import print_function
import re
import json
import datetime

def extract_iocs():
    """Extract Indicators of Compromise."""
    if not currentProgram:
        print("[!] No program loaded!")
        return
    
    print("\n" + "=" * 80)
    print("[*] IOC Extractor")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("=" * 80 + "\n")
    
    # Patterns
    patterns = {
        'domain': re.compile(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$'),
        'ip': re.compile(r'^(\d{1,3}\.){3}\d{1,3}$'),
        'url': re.compile(r'^https?://[^\s]+$'),
        'registry': re.compile(r'^[A-Z]{2,4}\\.*'),
        'email': re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    }
    
    suspicious_keywords = [
        'malicious', 'exploit', 'payload', 'backdoor', 'rootkit',
        'keylog', 'steal', 'c2', 'command', 'control', 'inject'
    ]
    
    iocs = {
        'domains': set(),
        'ips': set(),
        'urls': set(),
        'registry_paths': set(),
        'email_addresses': set(),
        'suspicious_strings': set()
    }
    
    # Extract strings
    listing = currentProgram.getListing()
    data = listing.getDefinedData(True)
    
    while data.hasNext():
        d = data.next()
        try:
            value = str(d.getValue())
            if len(value) < 3:
                continue
            
            if patterns['domain'].match(value):
                iocs['domains'].add(value)
            elif patterns['ip'].match(value):
                iocs['ips'].add(value)
            elif patterns['url'].match(value):
                iocs['urls'].add(value)
            elif patterns['registry'].match(value):
                iocs['registry_paths'].add(value)
            elif patterns['email'].match(value):
                iocs['email_addresses'].add(value)
            elif any(kw in value.lower() for kw in suspicious_keywords):
                iocs['suspicious_strings'].add(value)
                
        except:
            continue
    
    # Convert sets to lists for JSON serialization
    iocs = {k: list(v) for k, v in iocs.items()}
    
    # Print results
    total_iocs = sum(len(v) for v in iocs.values())
    print("[*] Found {} IOCs:".format(total_iocs))
    
    for category, items in iocs.items():
        if items:
            print("\n[+] {}:".format(category.upper()))
            for item in items:
                print("    - {}".format(item))
    
    # Save to JSON
    report = {
        'timestamp': datetime.datetime.now().isoformat(),
        'program': currentProgram.getName(),
        'iocs': iocs
    }
    
    filename = "{}_iocs.json".format(
        currentProgram.getName().replace('.', '_'))
    with open(filename, 'w') as f:
        json.dump(report, f, indent=2)
    
    print("\n[*] IOC report saved to: {}".format(filename))
    print("=" * 80)
    
    return iocs

if __name__ == "__main__":
    extract_iocs()
```

---

## P4.9: Debugging Scripts

### P4.9.1: Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| **Script won't run** | Check for syntax errors, ensure running in Ghidra |
| **`AttributeError`** | Object doesn't have that attribute, check spelling |
| **`TypeError`** | Wrong parameter type, check API documentation |
| **`MemoryAccessException`** | Invalid address, use `memory.contains()` first |
| **Script too slow** | Optimize with caching, reduce operations |

### P4.9.2: Debugging Techniques

```python
# Print debug information
def debug_print(msg, data=None):
    print("[DEBUG] {}".format(msg))
    if data is not None:
        print("  Data: {}".format(data))

# Try/except for error handling
try:
    result = dangerous_operation()
except Exception as e:
    print("[!] Error: {}".format(str(e)))
    import traceback
    traceback.print_exc()

# Log to file
import logging
logging.basicConfig(filename='script.log', level=logging.DEBUG)
logging.debug("Starting script...")
```

---

## P4.10: Summary and Key Takeaways

### P4.10.1: Core Concepts

1. **Scripting automates analysis:** Save time and avoid errors
2. **Python is the preferred language:** Easy to learn, powerful
3. **The API provides access to everything:** Functions, memory, symbols, decompiler
4. **Error handling is essential:** Memory access can fail
5. **Test incrementally:** Build scripts step by step

### P4.10.2: Key API Objects

| Object | Purpose | How to Get It |
|--------|---------|---------------|
| `Program` | Current binary | `currentProgram` |
| `Address` | Memory address | `toAddr()`, `currentAddress` |
| `Listing` | Instructions and data | `currentProgram.getListing()` |
| `FunctionManager` | Functions | `currentProgram.getFunctionManager()` |
| `Function` | Single function | `func_manager.getFunctionAt()` |
| `SymbolTable` | Symbols/labels | `currentProgram.getSymbolTable()` |
| `ReferenceManager` | Cross-references | `currentProgram.getReferenceManager()` |

### P4.10.3: Scripting Workflow

1. **Identify the task:** What do you want to automate?
2. **Find the API:** What objects and methods do you need?
3. **Write incrementally:** Test each part as you go
4. **Handle errors:** Add try/except blocks
5. **Document:** Add comments and docstrings
6. **Test:** Run on different binaries to verify

---

## P4.11: Quick Reference Card

### Common API Calls

| Task | Code |
|------|------|
| Get current program | `program = currentProgram` |
| Create address | `addr = toAddr(0x00401000)` |
| Read memory | `data = getBytes(addr, length)` |
| Write memory | `setByte(addr, value)` |
| Get instructions | `listing.getInstructions(addr, True)` |
| Get functions | `func_manager.getFunctions(True)` |
| Get function | `func_manager.getFunctionAt(addr)` |
| Rename function | `func.setName(name, SourceType.USER_DEFINED)` |
| Get XREFs | `ref_manager.getReferencesTo(addr)` |
| Get decompiled code | `decompiler.decompileFunction(func, 30, None)` |

### Common Imports

```python
from __future__ import print_function
from ghidra.program.model.listing import Function
from ghidra.program.model.symbol import SourceType
from ghidra.program.model.mem import MemoryAccessException
from ghidra.program.model.address import AddressSet
```

### Script Template

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script Name: [Name]
Author: [Your Name]
Date: [Date]
Purpose: [Description]
"""

from __future__ import print_function

def main():
    """Main function."""
    if not currentProgram:
        print("[!] No program loaded!")
        return
    
    # Your code here
    print("[*] Script complete!")

if __name__ == "__main__":
    main()
```

---

**[END OF PRIMER 4]**

This primer has given you a comprehensive introduction to Ghidra scripting. You should now be able to:

- Write and run basic Python scripts in Ghidra
- Access the program, functions, and memory
- Read and write memory
- Rename functions and annotate code
- Extract strings and IOCs
- Generate reports
- Handle errors gracefully

**[PRIMER 4 COMPLETE]**
