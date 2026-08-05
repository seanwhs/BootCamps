# Appendix A: Complete Ghidra Python API Reference

Welcome to the comprehensive Ghidra Python API reference. This appendix serves as your definitive guide to Ghidra's scripting capabilities, providing detailed documentation for every major API class, method, and pattern you'll encounter during reverse engineering automation. Think of this as your programming dictionary—keep it handy whenever you're writing Ghidra scripts.

---

## A.1: Getting Started with Ghidra Scripting

### A.1.1: Script Execution Environment

When you run a script in Ghidra, it executes within the Ghidra scripting environment, which pre-loads several important modules and objects:

**Pre-loaded Global Objects:**
| Object | Type | Description |
|--------|------|-------------|
| `currentProgram` | `Program` | The currently open program/ binary |
| `currentAddress` | `Address` | The current cursor position in the listing |
| `currentSelection` | `AddressSetView` | The currently selected address range |
| `currentHighlight` | `AddressSetView` | The currently highlighted address range |
| `currentLocation` | `ProgramLocation` | The current location in the program |

**Script Types:**
| Extension | Language | Use Case |
|-----------|----------|----------|
| `.py` | Python | Most common; best for general-purpose scripting |
| `.java` | Java | For performance-critical scripts or when using Java libraries |
| `.js` | JavaScript | For lightweight scripts |

### A.1.2: Script Template

Every Ghidra Python script should follow this basic structure:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script Name: [Your Script Name]
Author: [Your Name]
Date: [Date]
Purpose: [Brief description of what the script does]

This script demonstrates [key concepts or techniques].
"""

from __future__ import print_function

# Import necessary Ghidra modules
from ghidra.program.model.listing import Function
from ghidra.program.model.symbol import SourceType
from ghidra.program.model.mem import MemoryAccessException
from ghidra.program.model.data import DataTypeManager

def main():
    """
    Main script execution function.
    This is called when the script is run.
    """
    print("=" * 80)
    print("[*] Script Starting")
    print("[*] Current Program: {}".format(currentProgram.getName()))
    print("=" * 80)
    
    # Your code here
    
    print("\n[*] Script Complete")

# Script entry point
if __name__ == "__main__":
    main()
```

---

## A.2: Core API Classes

### A.2.1: The Program Class

The `Program` class is your entry point to everything in the binary.

```python
# Get the current program
program = currentProgram

# Get program information
program_name = program.getName()        # e.g., "calculator_elf"
program_language = program.getLanguage() # CPU architecture
program_executable = program.getExecutable()  # File path

# Get the program's address space
address_space = program.getAddressFactory()
default_space = address_space.getDefaultAddressSpace()

# Get the program's memory
memory = program.getMemory()
```

**Key Program Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `getFunctionManager()` | `FunctionManager` | Access to all functions |
| `getListing()` | `Listing` | Access to disassembled instructions and data |
| `getSymbolTable()` | `SymbolTable` | Access to symbols (functions, labels, etc.) |
| `getDataTypeManager()` | `DataTypeManager` | Access to data types |
| `getMemory()` | `Memory` | Access to memory blocks |
| `getAddressFactory()` | `AddressFactory` | For creating/manipulating addresses |
| `getName()` | `String` | Program name |
| `getExecutable()` | `String` | Original file path |
| `getLanguage()` | `Language` | Architecture details |

**Example: Iterating through memory blocks**

```python
def enumerate_memory_blocks():
    """Print information about all memory blocks."""
    memory = currentProgram.getMemory()
    blocks = memory.getBlocks()
    
    print("[*] Memory Blocks:")
    print("-" * 80)
    print("{:<20} {:<15} {:<15} {:<10}".format(
        "Name", "Start", "End", "Size"))
    print("-" * 80)
    
    while blocks.hasNext():
        block = blocks.next()
        print("{:<20} {:<15} {:<15} {:<10}".format(
            block.getName(),
            "0x{:08x}".format(block.getStart().getOffset()),
            "0x{:08x}".format(block.getEnd().getOffset()),
            block.getSize()
        ))
```

---

### A.2.2: The FunctionManager Class

The `FunctionManager` provides access to all functions in the program.

```python
# Get the function manager
func_manager = currentProgram.getFunctionManager()

# Get all functions
functions = func_manager.getFunctions(True)  # True = forward order
# or
functions = func_manager.getFunctions(False) # False = reverse order

# Get a specific function
function = func_manager.getFunctionAt(address)  # Address object
function = func_manager.getFunctionNamed("main") # Function name

# Get function count
count = func_manager.getFunctionCount()

# Get the function containing an address
func = func_manager.getFunctionContaining(address)

# Get all functions in a range
funcs = func_manager.getFunctions(address_set, True)
```

**Key FunctionManager Methods:**
| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getFunctions(forward)` | `boolean` | `Iterator<Function>` | All functions |
| `getFunctionAt(address)` | `Address` | `Function` | Function at address |
| `getFunctionNamed(name)` | `String` | `Function` | Function by name |
| `getFunctionCount()` | None | `int` | Total functions |
| `getFunctionContaining(address)` | `Address` | `Function` | Function containing address |
| `getFunctions(addrSet, forward)` | `AddressSetView, boolean` | `Iterator<Function>` | Functions in range |

### A.2.3: The Function Class

The `Function` class represents a single function in the program.

```python
# Common Function operations
function_name = func.getName()
entry_point = func.getEntryPoint()
return_type = func.getReturnType()
params = func.getParameters()
param_count = func.getParameterCount()

# Function body
body = func.getBody()  # Returns an AddressSet

# Function comments
comment = func.getComment()
func.setComment("This function validates access")

# Rename function
func.setName("authenticate_user", SourceType.USER_DEFINED)

# Get all called functions (outgoing references)
called_funcs = func.getCalledFunctions(my_program)

# Get calling functions (incoming references)
callers = func.getCallingFunctions(my_program)
```

**Key Function Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `getName()` | `String` | Function name |
| `setName(name, source)` | `void` | Rename function |
| `getEntryPoint()` | `Address` | Function start address |
| `getBody()` | `AddressSet` | Function address range |
| `getReturnType()` | `DataType` | Return value type |
| `getParameters()` | `List<Parameter>` | Function parameters |
| `getParameterCount()` | `int` | Number of parameters |
| `getComment()` | `String` | Function comment |
| `setComment(comment)` | `void` | Add/update comment |
| `getCalledFunctions(program)` | `Set<Function>` | Functions called by this one |
| `getCallingFunctions(program)` | `Set<Function>` | Functions that call this one |

**Example: Analyzing all functions**

```python
def analyze_all_functions():
    """Analyze and categorize all functions."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    categories = {
        'user_defined': [],
        'library': [],
        'auto_named': [],
        'imported': []
    }
    
    for func in functions:
        name = func.getName()
        symbol = func.getSymbol()
        source_type = symbol.getSourceType()
        
        if source_type == SourceType.USER_DEFINED:
            categories['user_defined'].append(name)
        elif name.startswith('__') or name.startswith('_'):
            categories['library'].append(name)
        elif name.startswith('FUN_'):
            categories['auto_named'].append(name)
        elif symbol.isExternal():
            categories['imported'].append(name)
    
    # Print results
    print("\n[*] Function Categories:")
    for category, funcs in categories.items():
        print("  {:<15}: {}".format(category, len(funcs)))
        if len(funcs) <= 10:
            print("    {}".format(", ".join(funcs)))
        else:
            print("    {} (showing first 10): {}".format(
                len(funcs), ", ".join(funcs[:10])))
    
    return categories
```

---

### A.2.4: The Listing Class

The `Listing` class provides access to disassembled instructions and defined data.

```python
# Get the listing
listing = currentProgram.getListing()

# Get instructions
instr = listing.getInstructionAt(address)  # Single instruction
instructions = listing.getInstructions(body, True)  # Iterator
instructions = listing.getInstructions(address, True)  # From address

# Get data (strings, variables, etc.)
data = listing.getDataAt(address)
data_iterator = listing.getDefinedData(True)  # All data

# Get comments
comment = listing.getCommentAt(address)
listing.setComment(address, "This is a comment")

# Get code units (instructions or data)
code_unit = listing.getCodeUnitAt(address)
code_units = listing.getCodeUnits(body, True)
```

**Key Listing Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `getInstructionAt(address)` | `Instruction` | Instruction at address |
| `getInstructions(addrSet, forward)` | `Iterator<Instruction>` | Instructions in range |
| `getDataAt(address)` | `Data` | Data at address |
| `getDefinedData(forward)` | `Iterator<Data>` | All defined data |
| `getCommentAt(address)` | `String` | Comment at address |
| `setComment(address, comment)` | `void` | Add comment |
| `getCodeUnitAt(address)` | `CodeUnit` | Instruction or data |

### A.2.5: The Instruction Class

The `Instruction` class represents a single assembly instruction.

```python
# Get instruction properties
address = instr.getAddress()
mnemonic = instr.getMnemonicString()  # e.g., "mov", "call"
operands = instr.getDefaultOperandRepresentation(0)  # First operand
num_operands = instr.getNumOperands()
length = instr.getLength()

# Get flow information
flows = instr.getFlows()  # Where this instruction can jump
flow_type = instr.getFlowType()

# Get all registers used
registers = instr.getRegisters()

# Check if it's a branch
is_branch = instr.isBranch()
is_call = instr.isCall()
is_return = instr.isReturn()
```

**Key Instruction Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `getAddress()` | `Address` | Instruction address |
| `getMnemonicString()` | `String` | Assembly mnemonic |
| `getNumOperands()` | `int` | Number of operands |
| `getDefaultOperandRepresentation(index)` | `String` | Operand as string |
| `getLength()` | `int` | Instruction length in bytes |
| `getFlows()` | `Set<Address>` | Branch targets |
| `getFlowType()` | `FlowType` | Type of flow |
| `isBranch()` | `boolean` | Is branch instruction? |
| `isCall()` | `boolean` | Is call instruction? |
| `isReturn()` | `boolean` | Is return instruction? |
| `getRegisters()` | `List<Register>` | Registers used |

**Example: Analyzing instructions in a function**

```python
def analyze_instructions_in_function(func):
    """Analyze all instructions in a function."""
    body = func.getBody()
    listing = currentProgram.getListing()
    instructions = listing.getInstructions(body, True)
    
    stats = {
        'total': 0,
        'calls': 0,
        'branches': 0,
        'returns': 0,
        'mov': 0,
        'push': 0,
        'pop': 0
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
        
        mnemonic = instr.getMnemonicString()
        if mnemonic == 'MOV':
            stats['mov'] += 1
        elif mnemonic == 'PUSH':
            stats['push'] += 1
        elif mnemonic == 'POP':
            stats['pop'] += 1
    
    print("\n[*] Instruction Statistics for {}".format(func.getName()))
    print("-" * 40)
    for stat, count in stats.items():
        print("  {:<12}: {}".format(stat, count))
    print("-" * 40)
    
    return stats
```

---

### A.2.6: The SymbolTable Class

The `SymbolTable` provides access to all symbols (labels) in the program.

```python
# Get the symbol table
symbol_table = currentProgram.getSymbolTable()

# Get symbols
symbols = symbol_table.getSymbols(True)  # All symbols
symbol = symbol_table.getSymbol(address)  # Symbol at address
symbol = symbol_table.getPrimarySymbol(address)  # Primary symbol

# Get external symbols (imports)
external_symbols = symbol_table.getExternalSymbols()

# Get namespace symbols
global_symbols = symbol_table.getGlobalSymbols()
```

**Key SymbolTable Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `getSymbols(forward)` | `Iterator<Symbol>` | All symbols |
| `getSymbol(address)` | `Symbol` | Symbol at address |
| `getPrimarySymbol(address)` | `Symbol` | Primary symbol |
| `getExternalSymbols()` | `Iterator<Symbol>` | Imported symbols |
| `getGlobalSymbols()` | `Iterator<Symbol>` | Global symbols |
| `getSymbols(addrSet)` | `Iterator<Symbol>` | Symbols in range |
| `getSymbolNames()` | `Set<String>` | All symbol names |

### A.2.7: The Symbol Class

The `Symbol` class represents a single symbol.

```python
# Get symbol properties
name = symbol.getName()
address = symbol.getAddress()
symbol_type = symbol.getSymbolType()  # e.g., FUNCTION, LABEL
source_type = symbol.getSourceType()  # USER_DEFINED, IMPORTED, etc.
is_external = symbol.isExternal()
is_global = symbol.isGlobal()

# Get the associated object
object = symbol.getObject()  # Could be a Function, Data, etc.
```

**Key Symbol Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `getName()` | `String` | Symbol name |
| `setName(name, source)` | `void` | Rename symbol |
| `getAddress()` | `Address` | Symbol address |
| `getSymbolType()` | `SymbolType` | Type of symbol |
| `getSourceType()` | `SourceType` | Where symbol came from |
| `isExternal()` | `boolean` | Is imported? |
| `isGlobal()` | `boolean` | Is global? |
| `getObject()` | `Object` | Associated object |

---

### A.2.8: The Memory Class

The `Memory` class provides access to the binary's memory.

```python
# Get memory
memory = currentProgram.getMemory()

# Read bytes
try:
    bytes = getBytes(address, length)
    byte = getByte(address)
    short = getShort(address)
    int_val = getInt(address)
    long_val = getLong(address)
    
    # Write bytes
    setByte(address, value)
    setBytes(address, byte_array)
except MemoryAccessException as e:
    print("[!] Memory access error: {}".format(str(e)))

# Get memory blocks
blocks = memory.getBlocks()
block = memory.getBlock(address)

# Check if address is in memory
is_mapped = memory.contains(address)
```

**Key Memory Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `getBytes(address, length)` | `byte[]` | Read bytes |
| `getByte(address)` | `byte` | Read byte |
| `getShort(address)` | `short` | Read 16-bit value |
| `getInt(address)` | `int` | Read 32-bit value |
| `getLong(address)` | `long` | Read 64-bit value |
| `setByte(address, value)` | `void` | Write byte |
| `setBytes(address, bytes)` | `void` | Write bytes |
| `contains(address)` | `boolean` | Is address in memory? |
| `getBlocks()` | `Iterator<MemoryBlock>` | All memory blocks |

**Convenience Functions (Global):**
| Function | Parameters | Return Type |
|----------|------------|-------------|
| `getBytes(addr, length)` | `Address, int` | `byte[]` |
| `getByte(addr)` | `Address` | `byte` |
| `getInt(addr)` | `Address` | `int` |
| `getLong(addr)` | `Address` | `long` |
| `setByte(addr, value)` | `Address, byte` | `void` |
| `setBytes(addr, bytes)` | `Address, byte[]` | `void` |

**Example: Reading and analyzing binary data**

```python
def analyze_binary_data(start_addr, length):
    """Read and analyze binary data from the program."""
    try:
        data = getBytes(start_addr, length)
        
        print("\n[*] Binary Data Analysis at 0x{:08x}".format(
            start_addr.getOffset()))
        print("-" * 80)
        
        # Hex dump
        for i in range(0, length, 16):
            hex_str = " ".join(["{:02x}".format(b) for b in data[i:i+16]])
            ascii_str = "".join([chr(b) if 32 <= b <= 126 else "." for b in data[i:i+16]])
            print("  {:08x}: {:<48} {}".format(
                start_addr.getOffset() + i, hex_str, ascii_str))
        
        print("-" * 80)
        
        # Basic statistics
        nulls = sum(1 for b in data if b == 0)
        printable = sum(1 for b in data if 32 <= b <= 126)
        
        print("\n[*] Statistics:")
        print("  Total bytes: {}".format(length))
        print("  NULL bytes: {} ({:.1f}%)".format(nulls, 100 * nulls / length))
        print("  Printable: {} ({:.1f}%)".format(printable, 100 * printable / length))
        
        return data
        
    except MemoryAccessException as e:
        print("[!] Failed to read memory: {}".format(str(e)))
        return None
```

---

## A.3: Data Types and Structures

### A.3.1: The DataTypeManager Class

The `DataTypeManager` provides access to data types.

```python
# Get the data type manager
dt_manager = currentProgram.getDataTypeManager()

# Get all data types
types = dt_manager.getAllDataTypes()

# Get a specific data type
data_type = dt_manager.getDataType("char")
data_type = dt_manager.getDataType("/int")

# Create custom types
from ghidra.program.model.data import StructureDataType
struct = StructureDataType("MyStruct", 0)
struct.add(ByteDataType.dataType, 1, "field1", None)
struct.add(IntDataType.dataType, 4, "field2", None)
```

### A.3.2: Common Data Types

| Data Type | Class | Size (bytes) |
|-----------|-------|--------------|
| `char` | `CharDataType` | 1 |
| `short` | `ShortDataType` | 2 |
| `int` | `IntDataType` | 4 |
| `long` | `LongDataType` | 8 |
| `float` | `FloatDataType` | 4 |
| `double` | `DoubleDataType` | 8 |
| `pointer` | `PointerDataType` | 4/8 |
| `byte` | `ByteDataType` | 1 |
| `boolean` | `BooleanDataType` | 1 |

**Example: Applying data types**

```python
def apply_structures():
    """Apply known structures to binary data."""
    from ghidra.program.model.data import StructureDataType, ByteDataType, IntDataType
    
    # Create a simple structure
    struct = StructureDataType("PacketHeader", 0)
    struct.add(ByteDataType.dataType, 1, "version", "Protocol version")
    struct.add(IntDataType.dataType, 4, "length", "Packet length")
    struct.add(IntDataType.dataType, 4, "checksum", "Packet checksum")
    
    # Apply at a specific address
    base_addr = toAddr(0x00402000)
    currentProgram.getListing().setDataType(base_addr, struct)
    
    print("[*] Applied structure at 0x{:08x}".format(
        base_addr.getOffset()))
```

---

## A.4: Address Manipulation

### A.4.1: The Address Class

The `Address` class represents a memory address.

```python
# Create addresses
addr = toAddr(0x00401000)          # Create from hex
addr = currentAddress               # Current cursor position
addr = currentProgram.getImageBase()  # Program entry point

# Compare addresses
addr1 = toAddr(0x00401000)
addr2 = toAddr(0x00401010)
is_less = addr1.compareTo(addr2) < 0  # True if addr1 < addr2

# Add/subtract
new_addr = addr1.add(0x10)  # +16 bytes
new_addr = addr1.subtract(0x10)  # -16 bytes

# Get offset
offset = addr.getOffset()  # Decimal offset
hex_string = "0x{:08x}".format(offset)  # Hex format
```

**Key Address Methods:**
| Method | Return Type | Description |
|--------|-------------|-------------|
| `add(offset)` | `Address` | Add offset |
| `subtract(offset)` | `Address` | Subtract offset |
| `compareTo(other)` | `int` | Compare addresses |
| `getOffset()` | `long` | Offset as number |
| `toString()` | `String` | Address as string |
| `isExternalAddress()` | `boolean` | External address? |

**Convenience Functions:**
| Function | Parameters | Return Type |
|----------|------------|-------------|
| `toAddr(string)` | `String` | `Address` |
| `toAddr(long)` | `long` | `Address` |
| `getCurrentAddress()` | None | `Address` |
| `getImageBase()` | None | `Address` |

---

## A.5: Advanced Scripting Techniques

### A.5.1: Working with Cross-References

```python
from ghidra.program.model.symbol import ReferenceManager

def find_xrefs(address, direction='both'):
    """Find cross-references for an address."""
    ref_manager = currentProgram.getReferenceManager()
    
    if direction == 'to' or direction == 'both':
        # References to this address
        refs_to = ref_manager.getReferencesTo(address)
        print("\n[*] References TO 0x{:08x}:".format(address.getOffset()))
        while refs_to.hasNext():
            ref = refs_to.next()
            print("  {} at 0x{:08x} ({}: {})".format(
                ref.getSourceAddress(),
                ref.getSourceAddress().getOffset(),
                ref.getReferenceType(),
                "call" if ref.getReferenceType().isCall() else "data"
            ))
    
    if direction == 'from' or direction == 'both':
        # References from this address
        refs_from = ref_manager.getReferencesFrom(address)
        print("\n[*] References FROM 0x{:08x}:".format(address.getOffset()))
        while refs_from.hasNext():
            ref = refs_from.next()
            print("  -> 0x{:08x} ({}: {})".format(
                ref.getToAddress().getOffset(),
                ref.getReferenceType(),
                "call" if ref.getReferenceType().isCall() else "data"
            ))
```

### A.5.2: Searching for Patterns

```python
def search_for_pattern(pattern, search_type='string'):
    """Search for patterns in the binary."""
    from ghidra.app.util.bin import BinaryReader
    
    results = []
    
    if search_type == 'string':
        # Search for strings
        listing = currentProgram.getListing()
        data = listing.getDefinedData(True)
        
        while data.hasNext():
            d = data.next()
            try:
                value = str(d.getValue())
                if pattern in value:
                    results.append({
                        'address': d.getAddress(),
                        'value': value,
                        'type': 'string'
                    })
            except:
                continue
    
    elif search_type == 'hex':
        # Search for hex patterns
        memory = currentProgram.getMemory()
        # Implementation would iterate through memory blocks
        pass
    
    return results
```

### A.5.3: Working with Decompiler

```python
# Get decompiler interface
decompiler = currentProgram.getDecompilerInterface()

# Decompile a function
decomp = decompiler.decompileFunction(func, 30, None)  # 30 second timeout
decompiled_code = decomp.getDecompiledFunction().getC()

# Get variables from decompiler
vars = decomp.getHighFunction().getLocalSymbolMap()

# Get call graph
call_graph = decomp.getCallGraph()
```

---

## A.6: Common Script Patterns

### A.6.1: Batch Renaming Functions

```python
def batch_rename_functions():
    """Rename all functions starting with 'FUN_' based on their context."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    renamed_count = 0
    
    for func in functions:
        name = func.getName()
        if name.startswith('FUN_'):
            # Analyze the function to suggest a better name
            new_name = suggest_function_name(func)
            if new_name and new_name != name:
                func.setName(new_name, SourceType.USER_DEFINED)
                renamed_count += 1
                print("[*] Renamed {} -> {}".format(name, new_name))
    
    print("[*] Batch rename complete. Renamed {} functions.".format(
        renamed_count))

def suggest_function_name(func):
    """Suggest a meaningful name for a function."""
    # This is a simplified example
    # In practice, you'd use heuristics like:
    # - Imported calls in the function
    # - Strings referenced
    # - Return type and parameters
    # - Control flow structure
    
    body = func.getBody()
    listing = currentProgram.getListing()
    instructions = listing.getInstructions(body, True)
    
    called_functions = set()
    while instructions.hasNext():
        instr = instructions.next()
        if instr.isCall():
            for target in instr.getFlows():
                target_func = currentProgram.getFunctionManager().getFunctionAt(target)
                if target_func:
                    called_functions.add(target_func.getName())
    
    if 'strcpy' in called_functions:
        return "string_copy_" + func.getName().lower()
    elif 'printf' in called_functions or 'puts' in called_functions:
        return "print_" + func.getName().lower()
    elif 'free' in called_functions:
        return "cleanup_" + func.getName().lower()
    
    return None
```

### A.6.2: Exporting Analysis Results

```python
import json
import datetime

def export_analysis_report():
    """Export comprehensive analysis report as JSON."""
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    report = {
        'metadata': {
            'program': currentProgram.getName(),
            'export_date': datetime.datetime.now().isoformat(),
            'architecture': str(currentProgram.getLanguage())
        },
        'functions': []
    }
    
    for func in functions:
        func_info = {
            'name': func.getName(),
            'entry_point': "0x{:08x}".format(func.getEntryPoint().getOffset()),
            'parameters': [p.getName() for p in func.getParameters()],
            'return_type': str(func.getReturnType()),
            'calls': [],
            'called_by': []
        }
        
        # Get called functions
        called = func.getCalledFunctions(currentProgram)
        for target in called:
            func_info['calls'].append(target.getName())
        
        # Get callers
        callers = func.getCallingFunctions(currentProgram)
        for caller in callers:
            func_info['called_by'].append(caller.getName())
        
        report['functions'].append(func_info)
    
    # Save to file
    filename = "{}_analysis.json".format(currentProgram.getName())
    with open(filename, 'w') as f:
        json.dump(report, f, indent=2)
    
    print("[*] Report exported to: {}".format(filename))
    return report
```

---

## A.7: Troubleshooting Common Scripting Issues

### A.7.1: Common Errors and Solutions

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| `NameError: name 'currentProgram' is not defined` | Not running in Ghidra environment | Run script through Ghidra's Script Manager |
| `AttributeError: 'NoneType' object has no attribute ...` | Object doesn't exist (e.g., no function at address) | Add null checks |
| `MemoryAccessException` | Reading invalid memory | Check `memory.contains(address)` first |
| `IllegalArgumentException` | Invalid parameter | Check parameter types and values |
| `TimeoutException` | Decompiler timeout | Increase timeout or simplify analysis |

### A.7.2: Debugging Tips

1. **Use print statements:**
```python
print("[DEBUG] Address: 0x{:08x}".format(addr.getOffset()))
print("[DEBUG] Function: {}".format(func.getName()))
```

2. **Use try/except for error handling:**
```python
try:
    data = getBytes(addr, length)
except MemoryAccessException as e:
    print("[!] Error: {}".format(str(e)))
    continue
```

3. **Check for null:**
```python
if func is None:
    print("[!] Function not found")
    continue
```

4. **Use the Ghidra Console:**
   - All script output appears in the Console window
   - Use `print()` to see results
   - The Console also shows error traces

---

## A.8: Complete Script Examples

### A.8.1: Full Binary Analysis Script

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Complete Binary Analysis Script
Analyzes a binary and generates comprehensive report
"""

from __future__ import print_function
import json
import datetime
from ghidra.program.model.listing import Function
from ghidra.program.model.symbol import SourceType
from ghidra.program.model.mem import MemoryAccessException

class BinaryAnalyzer:
    """Complete binary analysis class."""
    
    def __init__(self, program):
        self.program = program
        self.results = {
            'program_info': {},
            'statistics': {},
            'functions': [],
            'strings': [],
            'imports': [],
            'vulnerabilities': []
        }
        
    def analyze_program_info(self):
        """Analyze basic program information."""
        self.results['program_info'] = {
            'name': self.program.getName(),
            'executable': self.program.getExecutable(),
            'language': str(self.program.getLanguage()),
            'image_base': "0x{:08x}".format(self.program.getImageBase().getOffset())
        }
    
    def analyze_statistics(self):
        """Calculate program statistics."""
        func_manager = self.program.getFunctionManager()
        listing = self.program.getListing()
        
        # Count functions
        func_count = func_manager.getFunctionCount()
        
        # Count instructions
        all_functions = func_manager.getFunctions(True)
        instr_count = 0
        for func in all_functions:
            body = func.getBody()
            instrs = listing.getInstructions(body, True)
            while instrs.hasNext():
                instrs.next()
                instr_count += 1
        
        self.results['statistics'] = {
            'total_functions': func_count,
            'total_instructions': instr_count,
            'memory_blocks': len(list(self.program.getMemory().getBlocks()))
        }
    
    def analyze_functions(self):
        """Analyze all functions."""
        func_manager = self.program.getFunctionManager()
        functions = func_manager.getFunctions(True)
        
        for func in functions:
            func_data = {
                'name': func.getName(),
                'address': "0x{:08x}".format(func.getEntryPoint().getOffset()),
                'parameters': func.getParameterCount(),
                'is_user_defined': func.getSymbol().getSourceType() == SourceType.USER_DEFINED
            }
            self.results['functions'].append(func_data)
    
    def extract_strings(self):
        """Extract all strings from the program."""
        listing = self.program.getListing()
        data = listing.getDefinedData(True)
        
        while data.hasNext():
            d = data.next()
            try:
                value = str(d.getValue())
                if len(value) >= 3:
                    self.results['strings'].append({
                        'address': "0x{:08x}".format(d.getAddress().getOffset()),
                        'value': value
                    })
            except:
                continue
    
    def generate_report(self):
        """Generate the final report."""
        self.analyze_program_info()
        self.analyze_statistics()
        self.analyze_functions()
        self.extract_strings()
        
        # Print summary
        print("\n" + "="*80)
        print("BINARY ANALYSIS REPORT")
        print("="*80)
        print("\nProgram: {}".format(self.results['program_info']['name']))
        print("Executable: {}".format(self.results['program_info']['executable']))
        print("Architecture: {}".format(self.results['program_info']['language']))
        print("Image Base: {}".format(self.results['program_info']['image_base']))
        
        print("\nSTATISTICS:")
        for key, value in self.results['statistics'].items():
            print("  {}: {}".format(key.replace('_', ' ').title(), value))
        
        print("\nFUNCTIONS: {}".format(len(self.results['functions'])))
        print("  User Defined: {}".format(
            sum(1 for f in self.results['functions'] if f['is_user_defined'])))
        
        print("\nSTRINGS: {}".format(len(self.results['strings'])))
        for s in self.results['strings'][:10]:
            print("  0x{}: {}".format(s['address'], s['value'][:50]))
        if len(self.results['strings']) > 10:
            print("  ... and {} more strings".format(len(self.results['strings']) - 10))
        
        # Save to file
        filename = "{}_complete_analysis.json".format(
            self.program.getName().replace('.', '_'))
        with open(filename, 'w') as f:
            json.dump(self.results, f, indent=2)
        print("\n[*] Full report saved to: {}".format(filename))

def main():
    if not currentProgram:
        print("[!] No program loaded!")
        return
    
    analyzer = BinaryAnalyzer(currentProgram)
    analyzer.generate_report()
    print("\n[*] Analysis complete!")

if __name__ == "__main__":
    main()
```

---

This appendix provides comprehensive documentation for Ghidra's Python API. Keep it close whenever you're writing scripts, and don't hesitate to refer back to it when you encounter unfamiliar API calls or patterns. Happy scripting!
