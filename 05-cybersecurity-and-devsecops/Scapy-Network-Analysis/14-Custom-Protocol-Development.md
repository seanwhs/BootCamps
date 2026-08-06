# Mastering Network Packet Crafting with Scapy
## Module 6: Automation, Performance & Custom Protocols
### Part 2: Custom Protocol Development

## The Target: Building Custom Protocol Dissectors

In this part, we'll extend Scapy with custom protocols. By the end, you'll be able to:

1. Understand Scapy's protocol architecture
2. Create custom Packet classes
3. Implement field types and bindings
4. Build custom dissectors for proprietary protocols
5. Add protocol analysis tools
6. Create a complete custom protocol implementation

---

## The Concept: Protocols as Classes in Scapy

Think of Scapy's protocol implementation as a **class hierarchy** where each protocol is a class that knows how to:

```
┌─────────────────────────────────────────────────────────────────┐
│                    PACKET CLASS                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              Protocol Layer Class                        │  │
│  │  • Fields defined (name, type, length)                  │  │
│  │  • Methods for dissection (extract, build)              │  │
│  │  • Bindings to other layers                             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                             │                                 │
│                             ▼                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │              Protocol Instance                          │  │
│  │  • Field values from packet                             │  │
│  │  • Methods for analysis (show, summary)                │  │
│  │  • Payload handling                                     │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Key insight**: Custom protocols are implemented by creating new classes that inherit from `Packet` and define their fields using Scapy's `Field` system.

---

## The Implementation: Building Custom Protocols

### Step 1: Understanding Scapy's Packet Architecture

Create `src/custom_protocol_basics.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 2: Custom Protocol Basics

This script demonstrates the basics of creating custom protocols
in Scapy.
"""

from scapy.all import *
from scapy.packet import Packet
from scapy.fields import *
import sys
import struct

# 1. Simple Custom Protocol - MyProtocol
class MyProtocol(Packet):
    """A simple custom protocol with a few fields."""
    name = "MyProtocol"
    fields_desc = [
        ByteField("version", 1),      # 1 byte
        ByteField("type", 0),         # 1 byte
        ShortField("length", 0),      # 2 bytes
        IntField("sequence", 0),      # 4 bytes
        StrFixedLenField("data", "", 10)  # 10 bytes
    ]
    
    def mysummary(self):
        """Custom summary for the protocol."""
        return f"MyProtocol v{self.version} type={self.type} seq={self.sequence}"

# 2. Protocol with Variable Length
class VariableProtocol(Packet):
    """A protocol with variable-length fields."""
    name = "VariableProtocol"
    fields_desc = [
        ByteField("type", 0),
        ByteField("length", 0),       # Length of data field
        StrLenField("data", "", length_from=lambda p: p.length)
    ]

# 3. Protocol with Nested Fields
class NestedProtocol(Packet):
    """A protocol with nested/structured fields."""
    name = "NestedProtocol"
    fields_desc = [
        ByteField("flags", 0),
        ThreeBytesField("address", 0),  # 3-byte address
        IntField("value", 0)
    ]

def demonstrate_custom_protocols():
    """Demonstrate custom protocol usage."""
    
    print("\n" + "=" * 60)
    print("CUSTOM PROTOCOL DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # 1. Create and inspect MyProtocol
    print("1. MyProtocol - Basic Protocol:")
    print("-" * 40)
    
    # Create packet
    pkt = MyProtocol(version=2, type=5, sequence=12345, data=b"HelloScapy")
    pkt.show()
    print(f"  Summary: {pkt.mysummary()}")
    print(f"  Length: {len(pkt)} bytes")
    print(f"  Hex: {bytes(pkt).hex()}\n")
    
    # 2. Modify fields
    print("2. Modifying Fields:")
    print("-" * 40)
    pkt[MyProtocol].type = 10
    pkt[MyProtocol].sequence = 99999
    print(f"  Modified: {pkt.mysummary()}\n")
    
    # 3. Variable length protocol
    print("3. VariableProtocol:")
    print("-" * 40)
    data = b"This is variable data"
    var_pkt = VariableProtocol(type=1, length=len(data), data=data)
    var_pkt.show()
    print(f"  Data: {var_pkt.data}\n")
    
    # 4. Nested protocol
    print("4. NestedProtocol:")
    print("-" * 40)
    nested = NestedProtocol(flags=0x07, address=0x123456, value=0xDEADBEEF)
    nested.show()
    print(f"  Address: {nested.address:06x}")
    print(f"  Value: {nested.value:08x}\n")
    
    # 5. Packet stacking
    print("5. Stacking with Other Protocols:")
    print("-" * 40)
    stacked = Ether() / IP(dst="8.8.8.8") / MyProtocol(version=1, type=5) / Raw(b"Custom data")
    stacked.show()
    print(f"  Summary: {stacked.summary()}")

def field_types_demo():
    """Demonstrate different Scapy field types."""
    
    print("\n" + "=" * 60)
    print("FIELD TYPES DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Define a packet with various field types
    class FieldDemo(Packet):
        name = "FieldDemo"
        fields_desc = [
            # Basic integer fields
            ByteField("byte", 0),           # 1 byte
            ShortField("short", 0),         # 2 bytes
            IntField("int", 0),             # 4 bytes
            LongField("long", 0),           # 8 bytes
            
            # Signed fields
            SignedByteField("sbyte", 0),    # 1 byte signed
            SignedShortField("sshort", 0),  # 2 bytes signed
            
            # Bit fields
            BitField("bit1", 0, 4),         # 4 bits
            BitField("bit2", 0, 4),         # 4 bits
            
            # String fields
            StrFixedLenField("fixed_str", "", 10),  # Fixed length
            StrLenField("var_str", "", length_from=lambda p: p.var_len),
            ByteField("var_len", 0),        # Length for var_str
            
            # Special fields
            IPField("ip_addr", "0.0.0.0"),  # IP address
            MACField("mac_addr", "00:00:00:00:00:00"),  # MAC
            MACField("ether", "ff:ff:ff:ff:ff:ff"),
            
            # Flags
            FlagsField("flags", 0, 8, ["FLAG1", "FLAG2", "FLAG3", "FLAG4"]),
            
            # Conditional fields
            ConditionalField(
                ByteField("conditional_byte", 0),
                lambda p: p.flags & 1  # Only present if FLAG1 is set
            )
        ]
    
    # Create instance
    demo = FieldDemo(
        byte=255,
        short=65535,
        int=0xDEADBEEF,
        long=0x1234567890ABCDEF,
        sbyte=-128,
        sshort=-32768,
        bit1=15,
        bit2=8,
        fixed_str=b"HelloWorld",
        var_len=5,
        var_str=b"Scapy",
        ip_addr="192.168.1.100",
        mac_addr="00:11:22:33:44:55",
        flags=1,  # Set FLAG1
        conditional_byte=0x42
    )
    
    print("FieldDemo Packet:")
    print("-" * 40)
    demo.show()
    print(f"\n  Raw bytes: {bytes(demo).hex()}")
    print(f"  Length: {len(demo)} bytes")

def protocol_binding_demo():
    """Demonstrate protocol binding."""
    
    print("\n" + "=" * 60)
    print("PROTOCOL BINDING DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # Define a custom protocol
    class MyCustomProtocol(Packet):
        name = "MyCustomProtocol"
        fields_desc = [
            ByteField("version", 1),
            ByteField("type", 0),
            ShortField("payload_len", 0)
        ]
    
    # Bind to IP protocol number 250
    bind_layers(IP, MyCustomProtocol, proto=250)
    
    # Create IP packet with custom protocol
    pkt = IP(src="192.168.1.100", dst="192.168.1.1", proto=250) / \
          MyCustomProtocol(version=2, type=3) / \
          Raw(b"Custom protocol payload")
    
    print("Bound Protocol Packet:")
    print("-" * 40)
    pkt.show()
    print(f"\n  IP Protocol: {pkt[IP].proto} (250 = custom)")
    print(f"  Custom Protocol: {pkt[MyCustomProtocol].name}")
    print(f"  Payload: {bytes(pkt[Raw])}\n")
    
    # Demonstrate dissection
    print("Dissecting from raw bytes:")
    raw = bytes(pkt)
    dissected = IP(raw)
    print(f"  Dissected: {dissected.summary()}")
    if dissected.haslayer(MyCustomProtocol):
        print(f"  Custom protocol found: {dissected[MyCustomProtocol].mysummary()}")

def main():
    """Main function for custom protocol basics."""
    
    print("=" * 60)
    print("CUSTOM PROTOCOL BASICS")
    print("=" * 60)
    
    demonstrate_custom_protocols()
    field_types_demo()
    protocol_binding_demo()
    
    print("\n" + "=" * 60)
    print("CUSTOM PROTOCOL BASICS COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### Step 2: Building a Complete Custom Protocol

Create `src/custom_protocol_complete.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 2: Complete Custom Protocol Implementation

This script implements a complete custom protocol with
dissection, analysis, and tool support.
"""

from scapy.all import *
from scapy.packet import Packet
from scapy.fields import *
import struct
import time
from datetime import datetime
import os
import sys

class CustomHeader(Packet):
    """
    Custom Protocol Header.
    
    Structure:
    - Version (1 byte): Protocol version
    - Type (1 byte): Message type
    - Flags (1 byte): Control flags
    - Reserved (1 byte): Reserved for future use
    - Length (2 bytes): Total payload length
    - Sequence (4 bytes): Sequence number
    - Timestamp (4 bytes): Unix timestamp
    """
    name = "CustomHeader"
    fields_desc = [
        ByteField("version", 1),
        ByteField("type", 0),
        ByteField("flags", 0),
        ByteField("reserved", 0),
        ShortField("length", 0),
        IntField("sequence", 0),
        IntField("timestamp", 0)
    ]
    
    def mysummary(self):
        """Custom summary for the protocol."""
        ts = datetime.fromtimestamp(self.timestamp).strftime('%Y-%m-%d %H:%M:%S')
        return (f"CustomHeader v{self.version} type={self.type} "
                f"seq={self.sequence} ts={ts}")
    
    def extract_timestamp(self):
        """Extract timestamp as datetime object."""
        return datetime.fromtimestamp(self.timestamp)

class CustomData(Packet):
    """
    Custom Data Payload.
    
    Structure:
    - Data Type (1 byte): Type of data
    - Data Length (2 bytes): Length of data
    - Data (variable): Actual data
    """
    name = "CustomData"
    fields_desc = [
        ByteField("data_type", 0),
        ShortField("data_length", 0),
        StrLenField("data", "", length_from=lambda p: p.data_length)
    ]
    
    def mysummary(self):
        """Custom summary for data."""
        return f"CustomData type={self.data_type} len={self.data_length}"

class CustomResponse(Packet):
    """
    Custom Response Protocol.
    
    Structure:
    - Status (1 byte): Response status
    - Error Code (1 byte): Error code
    - Response Length (2 bytes): Length of response data
    - Response Data (variable): Response data
    """
    name = "CustomResponse"
    fields_desc = [
        ByteField("status", 0),  # 0=Success, 1=Error
        ByteField("error_code", 0),
        ShortField("response_length", 0),
        StrLenField("response_data", "", length_from=lambda p: p.response_length)
    ]
    
    def mysummary(self):
        """Custom summary for response."""
        status = "Success" if self.status == 0 else f"Error {self.error_code}"
        return f"CustomResponse status={status}"
    
    def is_success(self):
        """Check if response indicates success."""
        return self.status == 0

# Bind protocols
bind_layers(IP, CustomHeader, proto=251)
bind_layers(CustomHeader, CustomData, length=0)  # Default
bind_layers(CustomHeader, CustomResponse, type=2)  # Response type

class CustomProtocolAnalyzer:
    """
    Analyzer for custom protocol traffic.
    """
    
    def __init__(self):
        """Initialize custom protocol analyzer."""
        self.packets = []
        self.stats = {
            'total': 0,
            'requests': 0,
            'responses': 0,
            'types': defaultdict(int),
            'versions': defaultdict(int),
            'data_types': defaultdict(int),
            'status_codes': defaultdict(int),
            'errors': defaultdict(int)
        }
    
    def analyze_packet(self, packet):
        """Analyze a custom protocol packet."""
        
        if not packet.haslayer(CustomHeader):
            return
        
        self.packets.append(packet)
        self.stats['total'] += 1
        
        header = packet[CustomHeader]
        
        # Update statistics
        self.stats['types'][header.type] += 1
        self.stats['versions'][header.version] += 1
        
        # Check if request or response
        if packet.haslayer(CustomData):
            self.stats['requests'] += 1
            data = packet[CustomData]
            self.stats['data_types'][data.data_type] += 1
            
        elif packet.haslayer(CustomResponse):
            self.stats['responses'] += 1
            response = packet[CustomResponse]
            self.stats['status_codes'][response.status] += 1
            if response.status != 0:
                self.stats['errors'][response.error_code] += 1
    
    def generate_report(self):
        """Generate analysis report."""
        
        print("\n" + "=" * 60)
        print("CUSTOM PROTOCOL ANALYSIS REPORT")
        print("=" * 60)
        print(f"Total packets: {self.stats['total']}")
        print(f"Requests: {self.stats['requests']}")
        print(f"Responses: {self.stats['responses']}")
        
        print("\nMessage Types:")
        print("-" * 40)
        for msg_type, count in sorted(self.stats['types'].items()):
            type_name = ["Data", "Response", "Heartbeat", "Error"][msg_type] if msg_type < 4 else f"Type{msg_type}"
            print(f"  {type_name}: {count}")
        
        print("\nVersions:")
        print("-" * 40)
        for version, count in sorted(self.stats['versions'].items()):
            print(f"  v{version}: {count}")
        
        if self.stats['data_types']:
            print("\nData Types:")
            print("-" * 40)
            for dtype, count in sorted(self.stats['data_types'].items()):
                type_names = ["Text", "Binary", "JSON", "XML", "Image", "Other"]
                name = type_names[dtype] if dtype < len(type_names) else f"Type{dtype}"
                print(f"  {name}: {count}")
        
        if self.stats['status_codes']:
            print("\nResponse Status:")
            print("-" * 40)
            for status, count in sorted(self.stats['status_codes'].items()):
                status_name = "Success" if status == 0 else f"Error{status}"
                print(f"  {status_name}: {count}")
        
        if self.stats['errors']:
            print("\nErrors:")
            print("-" * 40)
            for error, count in sorted(self.stats['errors'].items()):
                error_names = ["Unknown", "Invalid Format", "Timeout", "Not Found", "Permission", "Other"]
                name = error_names[error] if error < len(error_names) else f"Error{error}"
                print(f"  {name}: {count}")
        
        print("\n" + "=" * 60)

def build_custom_packet(version=1, msg_type=0, flags=0, sequence=0, 
                        data_type=0, data=b"Custom data", timestamp=None):
    """
    Build a custom protocol packet.
    
    Args:
        version: Protocol version
        msg_type: Message type (0=Data, 1=Response, 2=Heartbeat)
        flags: Control flags
        sequence: Sequence number
        data_type: Type of data
        data: Payload data
        timestamp: Unix timestamp (auto if None)
    """
    if timestamp is None:
        timestamp = int(time.time())
    
    # Build header
    header = CustomHeader(
        version=version,
        type=msg_type,
        flags=flags,
        length=len(data) + 3,  # Data header size
        sequence=sequence,
        timestamp=timestamp
    )
    
    # Build data payload
    custom_data = CustomData(
        data_type=data_type,
        data_length=len(data),
        data=data
    )
    
    return header / custom_data

def build_response(status=0, error_code=0, response_data=b"OK"):
    """Build a response packet."""
    
    header = CustomHeader(
        version=1,
        type=1,  # Response type
        sequence=0,
        timestamp=int(time.time())
    )
    
    response = CustomResponse(
        status=status,
        error_code=error_code,
        response_length=len(response_data),
        response_data=response_data
    )
    
    return header / response

def demonstrate_custom_protocol():
    """Demonstrate the complete custom protocol."""
    
    print("\n" + "=" * 60)
    print("COMPLETE CUSTOM PROTOCOL DEMONSTRATION")
    print("=" * 60 + "\n")
    
    # 1. Build request packets
    print("1. Building Request Packets:")
    print("-" * 40)
    
    # Data request
    pkt1 = build_custom_packet(
        version=1,
        msg_type=0,  # Data
        sequence=1001,
        data_type=0,  # Text
        data=b"Hello Custom Protocol!"
    )
    print(f"  Data Request: {pkt1.summary()}")
    pkt1.show()
    print()
    
    # Heartbeat
    pkt2 = build_custom_packet(
        version=1,
        msg_type=2,  # Heartbeat
        sequence=1002,
        data_type=3,  # Other
        data=b"PING"
    )
    print(f"  Heartbeat: {pkt2.summary()}")
    pkt2.show()
    print()
    
    # 2. Build response packets
    print("2. Building Response Packets:")
    print("-" * 40)
    
    # Success response
    resp1 = build_response(
        status=0,
        response_data=b"Request processed successfully"
    )
    print(f"  Success Response: {resp1.summary()}")
    resp1.show()
    print()
    
    # Error response
    resp2 = build_response(
        status=1,
        error_code=2,  # Timeout
        response_data=b"Request timed out"
    )
    print(f"  Error Response: {resp2.summary()}")
    resp2.show()
    print()
    
    # 3. Stack with IP
    print("3. Stacking with IP:")
    print("-" * 40)
    ip_pkt = IP(src="192.168.1.100", dst="192.168.1.1", proto=251) / pkt1
    ip_pkt.show()
    print(f"  IP Protocol: {ip_pkt[IP].proto} (custom)")
    print(f"  Custom Header: {ip_pkt[CustomHeader].mysummary()}")
    print(f"  Custom Data: {ip_pkt[CustomData].mysummary()}\n")
    
    # 4. Analyze traffic
    print("4. Analyzing Traffic:")
    print("-" * 40)
    analyzer = CustomProtocolAnalyzer()
    
    # Add packets to analyzer
    for pkt in [pkt1, pkt2, resp1, resp2, ip_pkt]:
        analyzer.analyze_packet(pkt)
    
    analyzer.generate_report()
    
    # 5. Save to PCAP
    print("\n5. Saving to PCAP:")
    print("-" * 40)
    packets = [pkt1, pkt2, resp1, resp2, ip_pkt]
    output_file = "output/custom_protocol.pcap"
    os.makedirs("output", exist_ok=True)
    wrpcap(output_file, packets)
    print(f"  Saved {len(packets)} packets to: {output_file}")
    
    # 6. Load and dissect
    print("\n6. Loading and Dissecting:")
    print("-" * 40)
    loaded = rdpcap(output_file)
    for pkt in loaded:
        if pkt.haslayer(CustomHeader):
            print(f"  {pkt.summary()}")
            if pkt.haslayer(CustomHeader):
                print(f"    Header: {pkt[CustomHeader].mysummary()}")
            if pkt.haslayer(CustomData):
                print(f"    Data: {pkt[CustomData].mysummary()}")
            if pkt.haslayer(CustomResponse):
                print(f"    Response: {pkt[CustomResponse].mysummary()}")

def main():
    """Main function for complete custom protocol."""
    
    print("=" * 60)
    print("CUSTOM PROTOCOL COMPLETE IMPLEMENTATION")
    print("=" * 60)
    
    demonstrate_custom_protocol()
    
    print("\n" + "=" * 60)
    print("CUSTOM PROTOCOL IMPLEMENTATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

### Step 3: Protocol Fuzzing with Custom Protocols

Create `src/protocol_fuzzing.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 2: Protocol Fuzzing

This script implements fuzzing for custom protocols
to test robustness and security.
"""

from scapy.all import *
import random
import sys
import time
from datetime import datetime
import os
from collections import defaultdict

class ProtocolFuzzer:
    """
    Protocol fuzzing engine for custom protocols.
    
    Features:
    - Field mutation
    - Malformed packet generation
    - Boundary testing
    - Random packet generation
    - Regression testing
    """
    
    def __init__(self, protocol_class, target="127.0.0.1", port=0,
                 seed=None, iterations=100):
        """
        Initialize protocol fuzzer.
        
        Args:
            protocol_class: Custom protocol class
            target: Target IP address
            port: Target port
            seed: Random seed
            iterations: Number of fuzzing iterations
        """
        self.protocol_class = protocol_class
        self.target = target
        self.port = port
        self.iterations = iterations
        
        if seed is not None:
            random.seed(seed)
        
        self.packets = []
        self.results = []
        self.fuzzing_stats = defaultdict(int)
        
        print(f"\n[Fuzzer] Initialized:")
        print(f"  Protocol: {protocol_class.__name__}")
        print(f"  Target: {target}:{port}")
        print(f"  Iterations: {iterations}")
        print(f"  Seed: {seed or 'random'}")
    
    def mutate_field(self, field_name, field_value, field_type):
        """
        Mutate a field value.
        
        Args:
            field_name: Field name
            field_value: Current field value
            field_type: Field type class
        
        Returns:
            Mutated value
        """
        # Random mutations based on field type
        if isinstance(field_type, ByteField):
            if random.random() < 0.3:
                return random.randint(0, 255)
            return field_value ^ (1 << random.randint(0, 7))
        
        elif isinstance(field_type, ShortField):
            if random.random() < 0.3:
                return random.randint(0, 65535)
            return field_value + random.randint(-100, 100)
        
        elif isinstance(field_type, IntField):
            if random.random() < 0.3:
                return random.randint(0, 0xFFFFFFFF)
            return field_value + random.randint(-1000, 1000)
        
        elif isinstance(field_type, StrFixedLenField):
            if random.random() < 0.3:
                return bytes(random.getrandbits(8) for _ in range(field_type.length))
            return field_value
        
        elif isinstance(field_type, IPField):
            if random.random() < 0.3:
                return f"{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(0,255)}"
            return field_value
        
        elif isinstance(field_type, MACField):
            if random.random() < 0.3:
                return ":".join(f"{random.randint(0,255):02x}" for _ in range(6))
            return field_value
        
        elif isinstance(field_type, FlagsField):
            if random.random() < 0.3:
                return random.randint(0, (1 << field_type.size) - 1)
            return field_value ^ (1 << random.randint(0, field_type.size - 1))
        
        else:
            # Default: return random value
            return bytes(random.getrandbits(8) for _ in range(random.randint(1, 10)))
    
    def fuzz_packet(self, base_packet=None):
        """
        Generate a fuzzed packet.
        
        Args:
            base_packet: Base packet to mutate (None for random)
        
        Returns:
            Fuzzed packet
        """
        if base_packet is None:
            # Create random packet
            pkt = self.protocol_class()
            # Set random values for all fields
            for field_name, field_value in pkt.fields_desc:
                if hasattr(pkt, field_name):
                    setattr(pkt, field_name, self.mutate_field(
                        field_name, 
                        getattr(pkt, field_name),
                        field_value
                    ))
        else:
            # Mutate base packet
            pkt = base_packet.copy()
            # Mutate a random field
            field_names = [f.name for f in pkt.fields_desc]
            if field_names:
                field_name = random.choice(field_names)
                field_desc = pkt.get_field(field_name)
                current_value = getattr(pkt, field_name)
                new_value = self.mutate_field(
                    field_name,
                    current_value,
                    field_desc
                )
                setattr(pkt, field_name, new_value)
        
        return pkt
    
    def generate_malformed_packet(self):
        """
        Generate a malformed packet (truncated, overlong, etc.)
        
        Returns:
            Malformed packet bytes
        """
        # Start with valid packet
        pkt = self.protocol_class()
        raw = bytes(pkt)
        
        # Apply malformation
        malformation_type = random.choice([
            'truncate',
            'insert',
            'overwrite',
            'length_mismatch'
        ])
        
        if malformation_type == 'truncate':
            # Truncate packet
            if len(raw) > 10:
                raw = raw[:random.randint(1, len(raw) - 1)]
        
        elif malformation_type == 'insert':
            # Insert random data
            pos = random.randint(0, len(raw))
            insert_data = bytes(random.getrandbits(8) for _ in range(random.randint(1, 20)))
            raw = raw[:pos] + insert_data + raw[pos:]
        
        elif malformation_type == 'overwrite':
            # Overwrite section with random data
            if len(raw) > 0:
                pos = random.randint(0, len(raw) - 1)
                length = random.randint(1, min(10, len(raw) - pos))
                raw = raw[:pos] + bytes(random.getrandbits(8) for _ in range(length)) + raw[pos+length:]
        
        elif malformation_type == 'length_mismatch':
            # Overwrite length field
            # Find length field and set to incorrect value
            for field_name, field_desc in pkt.fields_desc:
                if 'length' in field_name.lower():
                    if hasattr(pkt, field_name):
                        current_len = getattr(pkt, field_name)
                        new_len = random.randint(0, 65535)
                        # Override in raw bytes
                        pos = pkt._offset(field_name)
                        if pos is not None and pos < len(raw):
                            raw = raw[:pos] + struct.pack('>H', new_len) + raw[pos+2:]
                        break
        
        return raw
    
    def run_fuzzing(self):
        """Run the fuzzing campaign."""
        
        print("\n" + "=" * 60)
        print("PROTOCOL FUZZING CAMPAIGN")
        print("=" * 60)
        
        # Track results
        results = {
            'valid': 0,
            'malformed': 0,
            'errors': 0,
            'crashes': 0,
            'packets': []
        }
        
        for i in range(self.iterations):
            # Choose fuzzing strategy
            strategy = random.choice([
                'mutate',
                'random',
                'malformed'
            ])
            
            try:
                if strategy == 'mutate':
                    # Start with previous packet or create new one
                    if results['packets']:
                        base = random.choice(results['packets'])
                        pkt = self.fuzz_packet(base)
                    else:
                        pkt = self.fuzz_packet()
                    raw = bytes(pkt)
                    is_malformed = False
                
                elif strategy == 'random':
                    pkt = self.fuzz_packet()
                    raw = bytes(pkt)
                    is_malformed = False
                
                else:  # malformed
                    raw = self.generate_malformed_packet()
                    is_malformed = True
                    try:
                        pkt = self.protocol_class(raw)
                    except:
                        pkt = None
                
                # Store result
                results['packets'].append(raw)
                if is_malformed:
                    results['malformed'] += 1
                else:
                    results['valid'] += 1
                
                # Log progress
                if (i + 1) % 10 == 0:
                    print(f"  Iteration {i+1}/{self.iterations}: "
                          f"Valid={results['valid']}, "
                          f"Malformed={results['malformed']}")
            
            except Exception as e:
                results['errors'] += 1
                print(f"  Error at iteration {i+1}: {e}")
        
        self.display_results(results)
        return results
    
    def display_results(self, results):
        """Display fuzzing results."""
        
        print("\n" + "=" * 60)
        print("FUZZING RESULTS")
        print("=" * 60)
        print(f"Total iterations: {self.iterations}")
        print(f"Valid packets: {results['valid']}")
        print(f"Malformed packets: {results['malformed']}")
        print(f"Errors: {results['errors']}")
        print(f"Success rate: {results['valid'] / self.iterations * 100:.1f}%")
        
        # Save sample packets
        if results['packets']:
            output_dir = "output/fuzzing_samples"
            os.makedirs(output_dir, exist_ok=True)
            
            # Save raw packets
            for i, raw in enumerate(results['packets'][:10]):  # First 10
                filename = f"{output_dir}/sample_{i+1}.bin"
                with open(filename, 'wb') as f:
                    f.write(raw)
            
            print(f"\nSample packets saved to: {output_dir}")
            
            # Save malformed packets separately
            malformed = results['packets'][results['valid']:]
            if malformed:
                malformed_file = f"{output_dir}/malformed_samples.bin"
                with open(malformed_file, 'wb') as f:
                    for raw in malformed[:100]:  # First 100
                        f.write(raw)
                        f.write(b'\n')
                print(f"Malformed samples saved to: {malformed_file}")
        
        print("\n" + "=" * 60)

def main():
    """Main function for protocol fuzzing."""
    
    import argparse
    
    parser = argparse.ArgumentParser(description='Protocol Fuzzing')
    parser.add_argument('-p', '--protocol', default='CustomHeader',
                        help='Protocol class name')
    parser.add_argument('-t', '--target', default='127.0.0.1',
                        help='Target IP address')
    parser.add_argument('--port', type=int, default=0,
                        help='Target port')
    parser.add_argument('-i', '--iterations', type=int, default=100,
                        help='Number of iterations')
    parser.add_argument('-s', '--seed', type=int,
                        help='Random seed')
    
    args = parser.parse_args()
    
    # Get protocol class
    protocol_class = None
    if args.protocol == 'CustomHeader':
        from custom_protocol_complete import CustomHeader
        protocol_class = CustomHeader
    else:
        # Try to find class in globals
        if args.protocol in globals():
            protocol_class = globals()[args.protocol]
        else:
            print(f"Protocol class not found: {args.protocol}")
            sys.exit(1)
    
    # Create fuzzer
    fuzzer = ProtocolFuzzer(
        protocol_class=protocol_class,
        target=args.target,
        port=args.port,
        seed=args.seed,
        iterations=args.iterations
    )
    
    # Run fuzzing
    try:
        fuzzer.run_fuzzing()
    except KeyboardInterrupt:
        print("\nFuzzing interrupted by user")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=" * 60)
        print("PROTOCOL FUZZER")
        print("=" * 60)
        
        protocol_name = input("Protocol class name (default: CustomHeader): ").strip()
        protocol_name = protocol_name if protocol_name else "CustomHeader"
        
        iterations = input("Iterations (default: 100): ").strip()
        iterations = int(iterations) if iterations else 100
        
        # Import custom protocol
        from custom_protocol_complete import CustomHeader
        protocol_class = CustomHeader
        
        fuzzer = ProtocolFuzzer(
            protocol_class=protocol_class,
            target="127.0.0.1",
            iterations=iterations
        )
        
        fuzzer.run_fuzzing()
    else:
        main()
```

### Step 4: Custom Protocol Tool Suite

Create `src/custom_protocol_tools.py`:

```python
#!/usr/bin/env python3
"""
Module 6, Part 2: Custom Protocol Tool Suite

This script provides a complete tool suite for custom protocols
including generation, analysis, fuzzing, and visualization.
"""

from scapy.all import *
import sys
import os
import time
import json
from datetime import datetime
import argparse
import base64
import hashlib

# Import custom protocol
from custom_protocol_complete import CustomHeader, CustomData, CustomResponse

class CustomProtocolTools:
    """
    Complete tool suite for custom protocol analysis.
    
    Features:
    - Packet generation
    - Analysis and statistics
    - Visualization
    - Fuzzing
    - Export/Import
    """
    
    def __init__(self):
        """Initialize custom protocol tools."""
        self.packets = []
        self.stats = {
            'total': 0,
            'types': defaultdict(int),
            'versions': defaultdict(int),
            'data_types': defaultdict(int),
            'status': defaultdict(int)
        }
    
    def generate_packet(self, type=0, version=1, sequence=0, data=b"", data_type=0):
        """
        Generate a custom protocol packet.
        
        Returns:
            Scapy packet
        """
        # Build header
        header = CustomHeader(
            version=version,
            type=type,
            length=len(data) + 3,  # Data header size
            sequence=sequence,
            timestamp=int(time.time())
        )
        
        # Build data
        custom_data = CustomData(
            data_type=data_type,
            data_length=len(data),
            data=data
        )
        
        return header / custom_data
    
    def generate_response(self, status=0, error_code=0, data=b"OK"):
        """Generate a response packet."""
        
        header = CustomHeader(
            version=1,
            type=1,  # Response
            sequence=0,
            timestamp=int(time.time())
        )
        
        response = CustomResponse(
            status=status,
            error_code=error_code,
            response_length=len(data),
            response_data=data
        )
        
        return header / response
    
    def analyze_packet(self, packet):
        """
        Analyze a custom protocol packet.
        
        Returns:
            Analysis results dict
        """
        results = {
            'valid': False,
            'type': None,
            'version': None,
            'sequence': None,
            'timestamp': None,
            'length': None,
            'has_data': False,
            'has_response': False
        }
        
        if packet.haslayer(CustomHeader):
            header = packet[CustomHeader]
            results['valid'] = True
            results['type'] = header.type
            results['version'] = header.version
            results['sequence'] = header.sequence
            results['timestamp'] = header.timestamp
            results['length'] = header.length
            
            self.stats['total'] += 1
            self.stats['types'][header.type] += 1
            self.stats['versions'][header.version] += 1
            
            if packet.haslayer(CustomData):
                data = packet[CustomData]
                results['has_data'] = True
                results['data_type'] = data.data_type
                results['data_length'] = data.data_length
                results['data'] = data.data
                self.stats['data_types'][data.data_type] += 1
            
            if packet.haslayer(CustomResponse):
                response = packet[CustomResponse]
                results['has_response'] = True
                results['status'] = response.status
                results['error_code'] = response.error_code
                results['response_data'] = response.response_data
                self.stats['status'][response.status] += 1
        
        return results
    
    def generate_report(self):
        """Generate a comprehensive report."""
        
        print("\n" + "=" * 60)
        print("CUSTOM PROTOCOL ANALYSIS REPORT")
        print("=" * 60)
        print(f"Total Packets: {self.stats['total']}")
        
        print("\nMessage Types:")
        print("-" * 40)
        type_names = ["Data", "Response", "Heartbeat", "Error"]
        for type_val, count in sorted(self.stats['types'].items()):
            name = type_names[type_val] if type_val < len(type_names) else f"Type{type_val}"
            print(f"  {name}: {count}")
        
        print("\nVersions:")
        print("-" * 40)
        for version, count in sorted(self.stats['versions'].items()):
            print(f"  v{version}: {count}")
        
        if self.stats['data_types']:
            print("\nData Types:")
            print("-" * 40)
            type_names = ["Text", "Binary", "JSON", "XML", "Image", "Other"]
            for dtype, count in sorted(self.stats['data_types'].items()):
                name = type_names[dtype] if dtype < len(type_names) else f"Type{dtype}"
                print(f"  {name}: {count}")
        
        if self.stats['status']:
            print("\nResponse Status:")
            print("-" * 40)
            for status, count in sorted(self.stats['status'].items()):
                status_name = "Success" if status == 0 else "Error"
                print(f"  {status_name}: {count}")
        
        print("\n" + "=" * 60)
    
    def export_to_json(self, filename=None):
        """Export analysis results to JSON."""
        
        if filename is None:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f"output/custom_protocol_analysis_{timestamp}.json"
        
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        
        export_data = {
            'timestamp': datetime.now().isoformat(),
            'stats': dict(self.stats),
            'packets': [self.analyze_packet(p) for p in self.packets]
        }
        
        with open(filename, 'w') as f:
            json.dump(export_data, f, indent=2, default=str)
        
        print(f"\nAnalysis exported to: {filename}")
    
    def visualize_flow(self, packets):
        """Visualize protocol flow."""
        
        print("\n" + "=" * 60)
        print("PROTOCOL FLOW VISUALIZATION")
        print("=" * 60 + "\n")
        
        print("Legend:")
        print("  ▶  Request/Data")
        print("  ◀  Response")
        print("  ●  Heartbeat")
        print("-" * 40 + "\n")
        
        for i, packet in enumerate(packets):
            if packet.haslayer(CustomHeader):
                header = packet[CustomHeader]
                msg_type = header.type
                
                if msg_type == 0:
                    print(f"{i+1:2}. ▶  Data Packet (seq={header.sequence})")
                    if packet.haslayer(CustomData):
                        data = packet[CustomData]
                        print(f"     Data: {data.data[:50]}")
                elif msg_type == 1:
                    print(f"{i+1:2}. ◀  Response Packet")
                    if packet.haslayer(CustomResponse):
                        resp = packet[CustomResponse]
                        status = "✓" if resp.status == 0 else f"✗({resp.error_code})"
                        print(f"     Status: {status}")
                        print(f"     Response: {resp.response_data[:50]}")
                elif msg_type == 2:
                    print(f"{i+1:2}. ●  Heartbeat (seq={header.sequence})")
                else:
                    print(f"{i+1:2}. ?  Unknown Type {msg_type}")

def main():
    """Main function for custom protocol tools."""
    
    parser = argparse.ArgumentParser(description='Custom Protocol Tools')
    parser.add_argument('-g', '--generate', action='store_true',
                        help='Generate sample packets')
    parser.add_argument('-a', '--analyze', help='PCAP file to analyze')
    parser.add_argument('-f', '--fuzz', action='store_true',
                        help='Run fuzzing')
    parser.add_argument('-v', '--visualize', help='PCAP file to visualize')
    parser.add_argument('-e', '--export', action='store_true',
                        help='Export analysis to JSON')
    
    args = parser.parse_args()
    
    tools = CustomProtocolTools()
    
    if args.generate:
        # Generate sample packets
        print("\nGenerating sample packets...")
        
        # Data packets
        pkt1 = tools.generate_packet(
            type=0,  # Data
            version=1,
            sequence=1001,
            data=b"Hello Custom Protocol!",
            data_type=0  # Text
        )
        
        pkt2 = tools.generate_packet(
            type=2,  # Heartbeat
            version=1,
            sequence=1002,
            data=b"PING",
            data_type=3  # Other
        )
        
        # Response packets
        resp1 = tools.generate_response(
            status=0,
            data=b"Request processed successfully"
        )
        
        resp2 = tools.generate_response(
            status=1,
            error_code=2,
            data=b"Request timed out"
        )
        
        # Save to PCAP
        packets = [pkt1, pkt2, resp1, resp2]
        output_file = "output/custom_protocol_samples.pcap"
        os.makedirs("output", exist_ok=True)
        wrpcap(output_file, packets)
        
        print(f"Generated {len(packets)} packets")
        print(f"Saved to: {output_file}")
        
        # Display packets
        for pkt in packets:
            print(f"  {pkt.summary()}")
    
    elif args.analyze:
        # Analyze PCAP
        print(f"\nAnalyzing PCAP: {args.analyze}")
        
        packets = rdpcap(args.analyze)
        for pkt in packets:
            if pkt.haslayer(CustomHeader):
                tools.packets.append(pkt)
                tools.analyze_packet(pkt)
        
        tools.generate_report()
        
        if args.export:
            tools.export_to_json()
    
    elif args.visualize:
        # Visualize PCAP
        print(f"\nVisualizing PCAP: {args.visualize}")
        
        packets = rdpcap(args.visualize)
        tools.visualize_flow(packets)
    
    elif args.fuzz:
        # Run fuzzing
        from protocol_fuzzing import ProtocolFuzzer
        fuzzer = ProtocolFuzzer(
            protocol_class=CustomHeader,
            target="127.0.0.1",
            iterations=50
        )
        fuzzer.run_fuzzing()
    
    else:
        # Interactive mode
        print("=" * 60)
        print("CUSTOM PROTOCOL TOOLS - INTERACTIVE MODE")
        print("=" * 60)
        print("\nOptions:")
        print("  1. Generate sample packets")
        print("  2. Analyze PCAP")
        print("  3. Visualize PCAP")
        print("  4. Run fuzzing")
        print("  5. Exit")
        
        choice = input("\nSelect option: ").strip()
        
        if choice == '1':
            tools.main_generate()
        elif choice == '2':
            file_path = input("Enter PCAP file path: ").strip()
            if file_path:
                packets = rdpcap(file_path)
                for pkt in packets:
                    if pkt.haslayer(CustomHeader):
                        tools.packets.append(pkt)
                        tools.analyze_packet(pkt)
                tools.generate_report()
        elif choice == '3':
            file_path = input("Enter PCAP file path: ").strip()
            if file_path:
                packets = rdpcap(file_path)
                tools.visualize_flow(packets)
        elif choice == '4':
            from protocol_fuzzing import ProtocolFuzzer
            iterations = input("Iterations (default: 50): ").strip()
            iterations = int(iterations) if iterations else 50
            fuzzer = ProtocolFuzzer(
                protocol_class=CustomHeader,
                iterations=iterations
            )
            fuzzer.run_fuzzing()

if __name__ == "__main__":
    main()
```

---

## The Verification: Testing Custom Protocol Tools

### Verification 1: Test Custom Protocol Basics

```bash
cd ~/scapy-tutorial
python3 src/custom_protocol_basics.py
```

**Expected output**: Demonstration of custom protocol creation, field types, and protocol binding.

### Verification 2: Test Complete Custom Protocol

```bash
python3 src/custom_protocol_complete.py
```

**Expected output**: Complete protocol implementation with packet generation, analysis, and PCAP export.

### Verification 3: Test Protocol Fuzzing

```bash
python3 src/protocol_fuzzing.py -i 50
```

**Expected output**: Fuzzing campaign with statistics and saved samples.

### Verification 4: Test Custom Protocol Tools

```bash
# Generate sample packets
python3 src/custom_protocol_tools.py -g

# Analyze the generated packets
python3 src/custom_protocol_tools.py -a output/custom_protocol_samples.pcap -e

# Visualize the flow
python3 src/custom_protocol_tools.py -v output/custom_protocol_samples.pcap
```

**Expected output**: Complete tool suite with generation, analysis, and visualization.

---

## Reference: Scapy Protocol Development Guide

### Field Types

| Field Type | Description | Size |
|------------|-------------|------|
| ByteField | Single byte | 1 byte |
| ShortField | 16-bit integer | 2 bytes |
| IntField | 32-bit integer | 4 bytes |
| LongField | 64-bit integer | 8 bytes |
| SignedByteField | Signed byte | 1 byte |
| SignedShortField | Signed 16-bit | 2 bytes |
| StrFixedLenField | Fixed-length string | Variable |
| StrLenField | Length-prefixed string | Variable |
| IPField | IP address | 4 bytes |
| MACField | MAC address | 6 bytes |
| FlagsField | Bit flags | Variable |
| ConditionalField | Conditional field | Variable |

### Protocol Binding

```python
# Bind two layers
bind_layers(IP, CustomHeader, proto=250)

# Bind based on field value
bind_layers(CustomHeader, CustomData, type=0)
bind_layers(CustomHeader, CustomResponse, type=1)

# Remove binding
unbind_layers(IP, CustomHeader)
```

### Packet Methods

| Method | Description |
|--------|-------------|
| `show()` | Display packet fields |
| `summary()` | One-line summary |
| `mysummary()` | Custom summary |
| `haslayer()` | Check layer presence |
| `getlayer()` | Get layer |
| `remove_payload()` | Remove payload |
| `copy()` | Deep copy |
| `build()` | Build raw bytes |

---

## Common Pitfalls and Best Practices

### Pitfall 1: Incorrect Field Sizes

```python
# DON'T: Mismatched field sizes
class BadProtocol(Packet):
    fields_desc = [
        IntField("value", 0),      # 4 bytes
        ByteField("flag", 0)       # 1 byte
    ]

# DO: Match field sizes to protocol specification
class GoodProtocol(Packet):
    fields_desc = [
        ByteField("flag", 0),      # 1 byte
        IntField("value", 0)       # 4 bytes
    ]
```

### Pitfall 2: Not Handling Payload

```python
# DON'T: Ignore payload
class BadProtocol(Packet):
    fields_desc = [...]
    # No payload handling

# DO: Handle payload
class GoodProtocol(Packet):
    fields_desc = [...]
    def guess_payload_class(self, payload):
        # Determine next layer
        if payload.startswith(b'\x00'):
            return CustomData
        return Raw
```

### Best Practice: Use Bound Layers

```python
# Better: Use bind_layers for automatic dissection
bind_layers(IP, MyProtocol, proto=250)

# Then packets are automatically dissected
pkt = IP(proto=250) / MyProtocol()
```

### Best Practice: Implement Custom Summary

```python
class MyProtocol(Packet):
    fields_desc = [...]
    
    def mysummary(self):
        """Provide meaningful summary."""
        return f"MyProtocol v{self.version} type={self.type}"
```

---

## What We've Accomplished

By completing this part, you've mastered:

1. ✅ Custom protocol creation in Scapy
2. ✅ Field types and field definitions
3. ✅ Protocol binding and dissection
4. ✅ Complete protocol implementation
5. ✅ Protocol fuzzing techniques
6. ✅ Protocol analysis tools
7. ✅ Protocol visualization

---

## Module 6 Complete!

**Congratulations!** You've completed Module 6. You now have the skills to create custom protocols, optimize performance, and build production-ready packet processing systems.

---

## Series Complete!

You've completed the entire **Mastering Network Packet Crafting with Scapy** series. You now have:

- **Foundational knowledge** of network protocols
- **Practical skills** in packet crafting and analysis
- **Professional tools** for network security and analysis
- **Custom protocol development** capabilities
- **Production-ready** packet processing systems

---

```
─────────────────────────────────────────────────────────────────────────
│  STATUS: SERIES COMPLETE!                                            │
│  ✅ All 6 modules completed                                         │
│  ✅ Custom protocol development mastered                            │
│  ✅ Performance optimization applied                                │
│  ✅ Production-ready tools built                                    │
│  ✅ Professional skill set developed                                │
│                                                                     │
│  Next Steps:                                                        │
│  • Practice with real-world PCAPs                                   │
│  • Build your own custom tools                                      │
│  • Contribute to Scapy development                                  │
│  • Apply skills in authorized environments                         │
└─────────────────────────────────────────────────────────────────────────
```

**Thank you** for completing this comprehensive journey into network packet crafting with Scapy. You are now equipped with professional-grade skills for network analysis, security testing, and protocol development. Remember to always practice responsibly and within authorized environments.
