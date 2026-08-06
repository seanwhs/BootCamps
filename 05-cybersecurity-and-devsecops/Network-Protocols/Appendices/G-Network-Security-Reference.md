# Appendix G: Network Security Reference

## Comprehensive Security Guide for Network Engineers and Security Professionals

---

## Overview

This appendix provides a complete reference for network security concepts, threats, mitigation strategies, and security best practices. It covers everything from fundamental security principles to advanced threat detection and response techniques.

**Purpose**: Serve as a comprehensive security reference for network engineers, security analysts, and system administrators to build and maintain secure networks.

**Organization**: Organized by security domain, from foundational concepts to advanced threat detection and response.

---

## Table of Contents

1. [Security Fundamentals](#1-security-fundamentals)
2. [Network Security Architecture](#2-network-security-architecture)
3. [Authentication and Authorization](#3-authentication-and-authorization)
4. [Access Control](#4-access-control)
5. [Network Encryption](#5-network-encryption)
6. [Threat Detection and Monitoring](#6-threat-detection-and-monitoring)
7. [Common Attacks and Mitigations](#7-common-attacks-and-mitigations)
8. [Security Best Practices](#8-security-best-practices)
9. [Incident Response](#9-incident-response)
10. [Compliance and Standards](#10-compliance-and-standards)

---

## 1. Security Fundamentals

### The CIA Triad

```
┌─────────────────────────────────────────────────────────────┐
│                    THE CIA TRIAD                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Confidentiality                       │    │
│  │  ──────────────────────────────────────────────    │    │
│  │  Ensure data is only accessible to authorized     │    │
│  │  users.                                          │    │
│  │  Controls: Encryption, Access Control, AuthN      │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │                  Integrity                        │    │
│  │  ──────────────────────────────────────────────    │    │
│  │  Ensure data is accurate and unaltered.          │    │
│  │  Controls: Hashing, Digital Signatures, Logging   │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │                Availability                       │    │
│  │  ──────────────────────────────────────────────    │    │
│  │  Ensure data and services are accessible.         │    │
│  │  Controls: Redundancy, DDoS Protection, Backups   │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Security Principles

| Principle | Description | Example |
|-----------|-------------|---------|
| **Defense in Depth** | Multiple layers of security | Firewall + IDS + Encryption + Access Control |
| **Least Privilege** | Minimum access required | Users have only necessary permissions |
| **Separation of Duties** | No single person has all power | Split admin roles |
| **Fail Secure** | Fail to a secure state | Deny all by default |
| **Economy of Mechanism** | Keep security simple | Simple, auditable systems |
| **Compromise Recording** | Detect and log violations | Comprehensive logging |
| **Zero Trust** | Never trust, always verify | Continuous authentication |

### Security Controls

| Control Type | Description | Examples |
|--------------|-------------|----------|
| **Physical** | Physical access controls | Locks, biometrics, cameras |
| **Technical** | Technology-based controls | Firewalls, encryption, IDS |
| **Administrative** | Policy and procedure controls | Security policies, training |
| **Preventive** | Prevent incidents | Firewall rules, access controls |
| **Detective** | Detect incidents | IDS/IPS, logging, monitoring |
| **Corrective** | Correct incidents | Backup, restoration, patch management |

---

## 2. Network Security Architecture

### Defense in Depth

```
┌─────────────────────────────────────────────────────────────┐
│                    DEFENSE IN DEPTH                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Internet                                         │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Perimeter Firewall (Layer 3/4)                   │    │
│  │  ├─ Ingress filtering                             │    │
│  │  ├─ Egress filtering                              │    │
│  │  └─ NAT/DMZ                                       │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  DMZ (Demilitarized Zone)                         │    │
│  │  ├─ Web servers                                   │    │
│  │  ├─ Mail servers                                  │    │
│  │  └─ DNS servers                                   │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Web Application Firewall (WAF)                   │    │
│  │  ├─ SQL injection prevention                      │    │
│  │  ├─ XSS prevention                               │    │
│  │  └─ Bot protection                               │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Internal Firewall                                │    │
│  │  ├─ Segmentation controls                         │    │
│  │  ├─ Internal routing                              │    │
│  │  └─ VLAN isolation                                │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Internal Network (Zero Trust)                    │    │
│  │  ├─ Micro-segmentation                           │    │
│  │  ├─ East-west security                            │    │
│  │  └─ Continuous monitoring                        │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Data Layer                                       │    │
│  │  ├─ Encryption (at rest)                         │    │
│  │  ├─ Access control                                │    │
│  │  └─ Data loss prevention (DLP)                   │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Network Segmentation

```
┌─────────────────────────────────────────────────────────────┐
│                    NETWORK SEGMENTATION                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Management VLAN (10.0.0.0/24)                    │    │
│  │  ├─ Network management                            │    │
│  │  ├─ Monitoring tools                              │    │
│  │  └─ Admin access                                  │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Production VLAN (10.0.1.0/24)                    │    │
│  │  ├─ Application servers                            │    │
│  │  ├─ Database servers                               │    │
│  │  └─ Web servers                                    │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Development VLAN (10.0.2.0/24)                   │    │
│  │  ├─ Development servers                            │    │
│  │  ├─ Testing servers                                │    │
│  │  └─ Dev tools                                      │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Guest VLAN (10.0.3.0/24)                         │    │
│  │  ├─ Internet-only access                          │    │
│  │  ├─ Isolated from internal                        │    │
│  │  └─ Rate-limited                                 │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  DMZ VLAN (10.0.4.0/24)                           │    │
│  │  ├─ Public-facing services                         │    │
│  │  ├─ Web applications                              │    │
│  │  └─ Firewall protected                            │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Zero Trust Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ZERO TRUST ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Core Principles:                                           │
│  ├─ Never trust, always verify                             │
│  ├─ Assume breach                                          │
│  ├─ Least privilege access                                 │
│  └─ Verify explicitly                                      │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Identity Layer                                   │    │
│  │  ├─ MFA (Multi-Factor Authentication)             │    │
│  │  ├─ SSO (Single Sign-On)                         │    │
│  │  └─ IDP (Identity Provider) integration           │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Access Layer                                     │    │
│  │  ├─ Policy Enforcement Points (PEPs)              │    │
│  │  ├─ Policy Decision Points (PDPs)                 │    │
│  │  └─ Dynamic access policies                       │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Network Layer                                    │    │
│  │  ├─ Micro-segmentation                           │    │
│  │  ├─ Encrypted traffic (mTLS)                     │    │
│  │  └─ Network Access Control                       │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Device Layer                                     │    │
│  │  ├─ Device compliance checks                     │    │
│  │  ├─ Endpoint detection                           │    │
│  │  └─ Threat monitoring                            │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Authentication and Authorization

### Authentication Methods

| Method | Strength | Description |
|--------|----------|-------------|
| **Password** | Weak | Something you know |
| **OAuth/OpenID** | Medium | Delegated authentication |
| **SAML** | Medium | Enterprise SSO |
| **TLS Client Certificate** | Strong | Something you have |
| **MFA** | Strong | Multiple factors |
| **Biometric** | Strong | Something you are |
| **Hardware Token** | Strong | Something you have |

### Multi-Factor Authentication

```
┌─────────────────────────────────────────────────────────────┐
│                    MFA FACTORS                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Factor 1: Something You Know                              │
│  ├─ Password                                               │
│  ├─ PIN                                                    │
│  └─ Security questions                                     │
│                                                             │
│  Factor 2: Something You Have                              │
│  ├─ Mobile phone (SMS, TOTP)                              │
│  ├─ Hardware token                                        │
│  ├─ Smart card                                             │
│  └─ YubiKey                                               │
│                                                             │
│  Factor 3: Something You Are                               │
│  ├─ Fingerprint                                            │
│  ├─ Face recognition                                       │
│  ├─ Iris scan                                              │
│  └─ Voice recognition                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Authorization Models

| Model | Description | Use Case |
|-------|-------------|----------|
| **RBAC** | Role-Based Access Control | Employees with specific roles |
| **ABAC** | Attribute-Based Access Control | Dynamic, contextual access |
| **PBAC** | Policy-Based Access Control | Fine-grained policies |
| **ReBAC** | Relationship-Based Access Control | Social networks, permissions |

### Password Security Best Practices

```bash
# Generate strong password
openssl rand -base64 32

# Check password complexity
cat /etc/security/pwquality.conf

# Set password policy (Linux)
authconfig --passalgo=sha512 --enablereqpass --enablefaillock \
    --faillockargs="fail_interval=60, deny=5, unlock_time=300"

# Check password aging
chage -l username

# Set password expiration
chage -M 90 username

# Enforce password history
pam_tally2 -u username
```

---

## 4. Access Control

### Firewall Rules

**iptables Rule Structure**:
```bash
iptables [-t table] [command] [chain] [rule] [target]

# Common tables: filter (default), nat, mangle
# Common chains: INPUT, OUTPUT, FORWARD
# Common targets: ACCEPT, DROP, REJECT, LOG
```

**Example Rules**:
```bash
# Allow SSH from specific IP
iptables -A INPUT -p tcp --dport 22 -s 192.168.1.0/24 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m state --state INVALID -j DROP

# Log dropped packets
iptables -A INPUT -j LOG --log-prefix "FW-DROP: " --log-level 4

# Default policy
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# NAT (Source NAT)
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

# Port forwarding
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.5:80
```

### Access Control Lists (ACLs)

```
┌─────────────────────────────────────────────────────────────┐
│                    ACL EXAMPLE (Cisco)                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ! Standard ACL (IP-based)                                 │
│  access-list 10 permit 192.168.1.0 0.0.0.255               │
│  access-list 10 permit 10.0.0.0 0.255.255.255              │
│  access-list 10 deny any                                   │
│                                                             │
│  ! Extended ACL (Protocol, Port-based)                     │
│  access-list 100 permit tcp 192.168.1.0 0.0.0.255 any eq 22│
│  access-list 100 permit tcp 10.0.0.0 0.255.255.255 any eq 80│
│  access-list 100 deny any any                              │
│                                                             │
│  ! Apply to interface                                      │
│  interface GigabitEthernet0/1                              │
│   ip access-group 100 in                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Network Access Control (NAC)

```
┌─────────────────────────────────────────────────────────────┐
│                    NAC ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Pre-Connect Phase                                 │    │
│  │  ├─ Device connects to network                    │    │
│  │  ├─ Authentication (802.1X)                       │    │
│  │  └─ Device profiling                             │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Post-Connect Phase                                │    │
│  │  ├─ Device posture check                          │    │
│  │  ├─ Vulnerability assessment                      │    │
│  │  └─ Compliance validation                        │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Remediation Phase                                 │    │
│  │  ├─ Quarantine non-compliant devices              │    │
│  │  ├─ Apply remediation policies                    │    │
│  │  └─ Re-assess compliance                         │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Monitoring Phase                                  │    │
│  │  ├─ Continuous monitoring                         │    │
│  │  ├─ Alerts for anomalies                          │    │
│  │  └─ Logging and auditing                          │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### VPN Configuration

```bash
# OpenVPN Server Configuration
# /etc/openvpn/server.conf

port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
cipher AES-256-GCM
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 1.1.1.1"
keepalive 10 120
cipher AES-256-GCM
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3

# Generate certificates
# 1. Build CA
./easyrsa build-ca

# 2. Build server certificate
./easyrsa build-server-full server nopass

# 3. Build client certificates
./easyrsa build-client-full client1 nopass

# 4. Generate Diffie-Hellman parameters
./easyrsa gen-dh

# 5. Generate TLS Authentication key
openvpn --genkey --secret ta.key
```

---

## 5. Network Encryption

### Encryption Protocols

| Protocol | Layer | Strength | Use Case |
|----------|-------|----------|----------|
| **TLS 1.3** | Transport | Strong | Web, email, API |
| **IPsec** | Network | Strong | VPN, site-to-site |
| **WireGuard** | Network | Strong | Modern VPN |
| **SSH** | Application | Strong | Secure shell, SFTP |
| **HTTPS** | Application | Strong | Web traffic |
| **SRTP** | Application | Strong | VoIP encryption |
| **DNSSEC** | Application | Strong | DNS security |

### TLS Configuration

```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Generate Certificate Signing Request (CSR)
openssl req -new -newkey rsa:2048 -nodes -keyout domain.key -out domain.csr

# Verify certificate
openssl x509 -in cert.pem -text -noout

# Check certificate expiration
openssl x509 -in cert.pem -noout -dates

# Test TLS connection
openssl s_client -connect example.com:443 -tls1_3

# Show supported ciphers
openssl ciphers -v

# Nginx TLS Configuration
# /etc/nginx/ssl.conf
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:...
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
```

### IPsec Configuration

```bash
# StrongSwan Configuration
# /etc/ipsec.conf

config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=no

conn %default
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    keyexchange=ikev2
    authby=secret
    mobike=no

conn vpn-to-site
    left=203.0.113.10
    leftsubnet=10.0.0.0/16
    leftcert=server-cert.pem
    right=192.168.1.100
    rightsubnet=192.168.1.0/24
    auto=start

# IPSec Secrets
# /etc/ipsec.secrets

: RSA server-key.pem
: PSK "my-strong-psk"

# StrongSwan VPN (pre-shared key)
# /etc/ipsec.conf
conn myvpn
    keyexchange=ikev1
    authby=secret
    type=tunnel
    left=192.168.1.100
    leftsubnet=192.168.1.0/24
    right=203.0.113.10
    rightsubnet=10.0.0.0/16
    auto=add
```

### SSH Hardening

```bash
# /etc/ssh/sshd_config

# Disable root login
PermitRootLogin no

# Use key-based authentication
PubkeyAuthentication yes
PasswordAuthentication no

# Disable empty passwords
PermitEmptyPasswords no

# Use strong ciphers
Ciphers aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512,hmac-sha2-256

# Protocol versions
Protocol 2

# Login grace time
LoginGraceTime 60

# Max authentication attempts
MaxAuthTries 3

# Disable X11 forwarding
X11Forwarding no

# Enable logging
SyslogFacility AUTH
LogLevel INFO

# Change default port (optional)
Port 2222

# Allow only specific users
AllowUsers alice bob

# Restrict SSH access
AllowGroups ssh-users

# Set idle timeout
ClientAliveInterval 300
ClientAliveCountMax 2
```

---

## 6. Threat Detection and Monitoring

### Intrusion Detection/Prevention Systems

```
┌─────────────────────────────────────────────────────────────┐
│                    IDS/IPS ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Network IDS (NIDS)                                │    │
│  │  ├─ Snort                                          │    │
│  │  ├─ Suricata                                       │    │
│  │  └─ Zeek (Bro)                                    │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Host IDS (HIDS)                                   │    │
│  │  ├─ OSSEC                                          │    │
│  │  ├─ Wazuh                                          │    │
│  │  └─ Tripwire                                      │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Signature-Based Detection                        │    │
│  │  ├─ Pattern matching                              │    │
│  │  ├─ Known threat signatures                       │    │
│  │  └─ Regular updates                              │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Anomaly-Based Detection                          │    │
│  │  ├─ Baseline establishment                        │    │
│  │  ├─ Statistical analysis                          │    │
│  │  └─ Machine learning                             │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Response Actions                                  │    │
│  │  ├─ Alert                                         │    │
│  │  ├─ Block                                         │    │
│  │  ├─ Rate limit                                    │    │
│  │  └─ Log                                           │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Snort/Suricata Rules

```bash
# Snort Rule Format
# action protocol src_ip src_port direction dst_ip dst_port (msg:"message"; ...)

# Example Snort rules
# Alert on SSH brute force
alert tcp $HOME_NET any -> $EXTERNAL_NET 22 \
  (msg:"SSH Brute Force"; \
   flow:to_server,established; \
   detection_filter:track by_src, count 20, seconds 60; \
   sid:1000001; \
   classtype:attempted-recon;)

# Alert on SQL injection attempt
alert tcp $EXTERNAL_NET any -> $HOME_NET 80 \
  (msg:"SQL Injection Attempt"; \
   content:"' OR 1=1"; \
   http_uri; \
   nocase; \
   sid:1000002; \
   classtype:web-application-attack;)

# Alert on port scan
alert icmp $EXTERNAL_NET any -> $HOME_NET any \
  (msg:"Port Scan Detected"; \
   itype:8; \
   threshold:type threshold, track by_src, count 20, seconds 60; \
   sid:1000003; \
   classtype:attempted-recon;)
```

### Logging and Monitoring

```bash
# Syslog configuration
# /etc/rsyslog.conf
# Send logs to remote server
*.* @192.168.1.100:514

# Audit configuration
# /etc/audit/audit.rules
# Monitor file changes
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-w /var/log/auth.log -p wa -k auth

# Monitor system calls
-a always,exit -S execve -k process-execution

# Monitor network connections
-a always,exit -S connect -S accept -S bind -k network

# Create audit report
auditctl -l
ausearch -k identity
aureport -f

# Journald configuration
# /etc/systemd/journald.conf
SystemMaxUse=5G
SystemMaxFileSize=100M
ForwardToSyslog=yes
ForwardToKMsg=yes
ForwardToConsole=no
MaxRetentionSec=30day
```

### SIEM Integration

```python
#!/usr/bin/env python3
"""
siem_integration.py - SIEM integration and log forwarding
"""

import json
import logging
import requests
import socket
import sys
from datetime import datetime

class SIEMLogger:
    """
    SIEM integration for log forwarding
    """
    
    def __init__(self, config):
        self.config = config
        self.logger = logging.getLogger(__name__)
        
        # Configure logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s'
        )
    
    def send_to_syslog(self, message: str, facility: int = 14, severity: int = 5):
        """Send log to syslog server"""
        # RFC 3164 syslog format
        timestamp = datetime.now().strftime('%b %d %H:%M:%S')
        hostname = socket.gethostname()
        
        priority = (facility * 8) + severity
        syslog_message = f"<{priority}>{timestamp} {hostname} {message}"
        
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            sock.sendto(syslog_message.encode(), (self.config['syslog_server'], 514))
            sock.close()
            self.logger.info(f"Sent to syslog: {message[:100]}")
        except Exception as e:
            self.logger.error(f"Error sending to syslog: {e}")
    
    def send_to_elasticsearch(self, data: dict):
        """Send log to Elasticsearch"""
        if not self.config.get('elasticsearch_host'):
            return
        
        try:
            url = f"http://{self.config['elasticsearch_host']}:9200/{self.config.get('index', 'logs')}/_doc"
            response = requests.post(
                url,
                json=data,
                headers={'Content-Type': 'application/json'}
            )
            
            if response.status_code == 201:
                self.logger.info("Sent to Elasticsearch")
            else:
                self.logger.error(f"Elasticsearch error: {response.status_code}")
                
        except Exception as e:
            self.logger.error(f"Error sending to Elasticsearch: {e}")
    
    def log_security_event(self, event_type: str, event_data: dict):
        """Log security event"""
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'event_type': event_type,
            'source_ip': event_data.get('source_ip'),
            'destination_ip': event_data.get('destination_ip'),
            'user': event_data.get('user'),
            'action': event_data.get('action'),
            'status': event_data.get('status'),
            'details': event_data.get('details'),
            'hostname': socket.gethostname()
        }
        
        # Format message
        message = f"SECURITY: {event_type} - User: {event_data.get('user', 'Unknown')} - {event_data.get('action', 'Unknown')}"
        
        # Send to syslog
        self.send_to_syslog(message)
        
        # Send to Elasticsearch
        self.send_to_elasticsearch(log_entry)
        
        return log_entry

def main():
    """Example usage"""
    config = {
        'syslog_server': '192.168.1.100',
        'elasticsearch_host': '192.168.1.101',
        'index': 'security-logs'
    }
    
    siem = SIEMLogger(config)
    
    # Log security events
    events = [
        {
            'type': 'auth',
            'data': {
                'user': 'admin',
                'action': 'login',
                'status': 'failed',
                'source_ip': '192.168.1.50',
                'details': 'Invalid password'
            }
        },
        {
            'type': 'network',
            'data': {
                'source_ip': '203.0.113.50',
                'destination_ip': '10.0.0.5',
                'action': 'port_scan',
                'details': 'Scanning port 22'
            }
        },
        {
            'type': 'file_integrity',
            'data': {
                'file': '/etc/passwd',
                'action': 'modified',
                'user': 'root',
                'details': 'File checksum changed'
            }
        }
    ]
    
    for event in events:
        siem.log_security_event(event['type'], event['data'])

if __name__ == "__main__":
    main()
```

---

## 7. Common Attacks and Mitigations

### Attack Types and Mitigations

| Attack | Description | Mitigation |
|--------|-------------|------------|
| **DDoS** | Distributed Denial of Service | Rate limiting, DDoS protection, CDN |
| **Man-in-the-Middle** | Intercepting communications | TLS, mutual authentication, VPN |
| **ARP Spoofing** | ARP cache poisoning | Static ARP, DAI, port security |
| **DNS Poisoning** | DNS cache poisoning | DNSSEC, validation, caching |
| **Phishing** | Deceptive emails/websites | User training, SPF/DKIM/DMARC |
| **Malware** | Malicious software | Antivirus, EDR, patching |
| **Ransomware** | File encryption extortion | Backups, EDR, user training |
| **SQL Injection** | Database attack | Parameterized queries, WAF |
| **XSS** | Cross-site scripting | Input validation, CSP |
| **CSRF** | Cross-site request forgery | Anti-CSRF tokens, SameSite cookies |

### DDoS Protection

```bash
# Basic DDoS mitigation with iptables
# Rate limit SYN packets
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --syn -j DROP

# Rate limit ICMP
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

# Rate limit UDP (DNS amplification)
iptables -A INPUT -p udp --dport 53 -m limit --limit 10/s -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j DROP

# Drop invalid packets
iptables -A INPUT -m state --state INVALID -j DROP

# Limit connections per IP
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 100 -j DROP

# Nginx rate limiting
# /etc/nginx/nginx.conf
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;
limit_req zone=one burst=5 nodelay;

limit_conn_zone $binary_remote_addr zone=addr:10m;
limit_conn addr 10;

# /etc/nginx/sites-available/default
location / {
    limit_req zone=one burst=5;
    limit_conn addr 10;
    proxy_pass http://backend;
}
```

### DDoS Response Plan

```
┌─────────────────────────────────────────────────────────────┐
│                    DDoS RESPONSE PLAN                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Phase 1: Detection (0-5 minutes)                          │
│  ├─ Monitoring alerts triggered                            │
│  ├─ Confirm attack                                         │
│  └─ Identify attack type                                   │
│                                                             │
│  Phase 2: Mitigation (5-15 minutes)                        │
│  ├─ Activate DDoS protection                               │
│  ├─ Rate limiting                                          │
│  ├─ Filter malicious traffic                               │
│  └─ Redirect to scrubbing center                          │
│                                                             │
│  Phase 3: Restoration (15-30 minutes)                      │
│  ├─ Restore normal service                                 │
│  ├─ Monitor for residual threats                          │
│  └─ Continue rate limiting                                │
│                                                             │
│  Phase 4: Investigation (30-60 minutes)                    │
│  ├─ Analyze attack vectors                                 │
│  ├─ Identify source                                       │
│  ├─ Collect evidence                                      │
│  └─ Document lessons learned                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### SQL Injection Prevention

```python
#!/usr/bin/env python3
"""
sql_injection_prevention.py - SQL injection prevention examples
"""

import sqlite3
import re
from typing import Dict, List, Any

class SQLInjectionPrevention:
    """
    SQL injection prevention techniques
    """
    
    def __init__(self, db_path: str = 'example.db'):
        self.db_path = db_path
        self.connection = sqlite3.connect(db_path)
        self.cursor = self.connection.cursor()
    
    # DO NOT DO THIS - Vulnerable to SQL injection
    def vulnerable_query(self, user_id: str) -> List:
        """Vulnerable to SQL injection"""
        query = f"SELECT * FROM users WHERE id = '{user_id}'"
        print(f"DANGEROUS: {query}")
        return self.cursor.execute(query).fetchall()
    
    # Safe method 1: Parameterized queries
    def safe_parameterized(self, user_id: str) -> List:
        """Safe using parameterized queries"""
        query = "SELECT * FROM users WHERE id = ?"
        print(f"SAFE: {query} with param {user_id}")
        return self.cursor.execute(query, (user_id,)).fetchall()
    
    # Safe method 2: Input validation
    def safe_validated(self, user_id: str) -> List:
        """Safe using input validation"""
        # Validate that user_id is numeric
        if not re.match(r'^\d+$', user_id):
            raise ValueError("Invalid user_id format")
        
        query = f"SELECT * FROM users WHERE id = {user_id}"
        print(f"SAFE: {query}")
        return self.cursor.execute(query).fetchall()
    
    # Safe method 3: Stored procedures (SQLite doesn't support)
    # Use your database's stored procedure feature
    
    # Safe method 4: ORM
    def safe_orm(self, user_id: str) -> List:
        """Safe using ORM (simulated)"""
        # In real ORM: User.objects.filter(id=user_id)
        print(f"SAFE: ORM handling {user_id}")
        return self.safe_parameterized(user_id)

def main():
    """Example usage"""
    prevention = SQLInjectionPrevention()
    
    # Test with valid input
    user_id = "123"
    print("\nValid input:")
    print(f"Vulnerable: {prevention.vulnerable_query(user_id)}")
    print(f"Parameterized: {prevention.safe_parameterized(user_id)}")
    
    # Test with malicious input
    malicious_id = "123' OR '1'='1"
    print(f"\nMalicious input: {malicious_id}")
    try:
        print(f"Parameterized: {prevention.safe_parameterized(malicious_id)}")
    except sqlite3.OperationalError as e:
        print(f"Safe: Parameterized query prevented injection ({e})")

if __name__ == "__main__":
    main()
```

---

## 8. Security Best Practices

### Network Security Checklist

```
┌─────────────────────────────────────────────────────────────┐
│                    NETWORK SECURITY CHECKLIST               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ☐ Perimeter Security                                      │
│    ☐ Firewall implemented and configured                   │
│    ☐ Default deny policy                                   │
│    ☐ Regular rule review                                  │
│    ☐ DMZ configured                                       │
│                                                             │
│  ☐ Network Segmentation                                    │
│    ☐ VLAN segregation                                     │
│    ☐ Micro-segmentation                                   │
│    ☐ Management network separated                          │
│    ☐ Guest network isolated                                │
│                                                             │
│  ☐ Authentication                                          │
│    ☐ MFA enabled for all users                             │
│    ☐ Strong password policy                               │
│    ☐ Account lockout                                       │
│    ☐ Centralized identity management                      │
│                                                             │
│  ☐ Encryption                                              │
│    ☐ TLS 1.2/1.3 for all services                          │
│    ☐ Encryption at rest                                    │
│    ☐ VPN for remote access                                 │
│    ☐ SSH hardening                                       │
│                                                             │
│  ☐ Monitoring                                              │
│    ☐ SIEM implemented                                     │
│    ☐ Logs centralized                                     │
│    ☐ Real-time alerts                                     │
│    ☐ Incident response plan                               │
│                                                             │
│  ☐ Patching                                               │
│    ☐ Regular vulnerability scans                          │
│    ☐ Patch management                                     │
│    ☐ Security updates                                     │
│    ☐ Configuration hardening                              │
│                                                             │
│  ☐ Access Control                                          │
│    ☐ Least privilege                                      │
│    ☐ Regular access reviews                               │
│    ☐ Session management                                  │
│    ☐ API security                                         │
│                                                             │
│  ☐ Data Protection                                         │
│    ☐ Data classification                                  │
│    ☐ Data loss prevention                                 │
│    ☐ Backup and recovery                                  │
│    ☐ Data retention policy                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Security Hardening Script

```bash
#!/bin/bash
# security_hardening.sh - Automated security hardening

echo "Starting security hardening..."

# 1. Update system
echo "1. Updating packages..."
apt-get update && apt-get upgrade -y

# 2. Firewall configuration
echo "2. Configuring firewall..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 3. SSH hardening
echo "3. Hardening SSH..."
cat > /etc/ssh/sshd_config.d/99-hardening.conf <<EOF
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
Protocol 2
EOF

systemctl restart sshd

# 4. Disable unnecessary services
echo "4. Disabling unnecessary services..."
systemctl disable rpcbind
systemctl disable avahi-daemon
systemctl disable bluetooth

# 5. Install security tools
echo "5. Installing security tools..."
apt-get install -y fail2ban snort clamav rkhunter

# 6. Configure fail2ban
echo "6. Configuring fail2ban..."
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl restart fail2ban

# 7. Enable auditing
echo "7. Enabling auditing..."
cat >> /etc/audit/rules.d/audit.rules <<EOF
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-a always,exit -S execve -k process-execution
EOF

service auditd restart

# 8. Disable IPv6 if not needed
echo "8. Configuring IPv6..."
echo "net.ipv6.conf.all.disable_ipv6=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6=1" >> /etc/sysctl.conf
sysctl -p

# 9. Set file permissions
echo "9. Setting file permissions..."
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 644 /etc/group

# 10. Logging configuration
echo "10. Configuring logging..."
cat >> /etc/rsyslog.conf <<EOF
# Security logs
auth,authpriv.*    /var/log/auth.log
cron.*             /var/log/cron.log
kern.*             /var/log/kern.log
mail.*             /var/log/mail.log
user.*             /var/log/user.log
EOF

systemctl restart rsyslog

# 11. Install and configure ClamAV
echo "11. Configuring ClamAV..."
freshclam

echo "Security hardening complete!"
```

### Security Monitoring Dashboard

```python
#!/usr/bin/env python3
"""
security_dashboard.py - Simple security monitoring dashboard
"""

import json
import time
import socket
from datetime import datetime, timedelta
from typing import Dict, List
import requests

class SecurityDashboard:
    """
    Simple security monitoring dashboard
    """
    
    def __init__(self):
        self.data = {
            'alerts': [],
            'stats': {
                'total_alerts': 0,
                'critical': 0,
                'high': 0,
                'medium': 0,
                'low': 0
            },
            'events': []
        }
        self.hostname = socket.gethostname()
    
    def add_alert(self, severity: str, message: str, source: str = None):
        """Add a security alert"""
        alert = {
            'timestamp': datetime.now().isoformat(),
            'severity': severity,
            'message': message,
            'source': source or self.hostname
        }
        
        self.data['alerts'].append(alert)
        self.data['stats']['total_alerts'] += 1
        self.data['stats'][severity] = self.data['stats'].get(severity, 0) + 1
        
        # Keep only last 100 alerts
        if len(self.data['alerts']) > 100:
            self.data['alerts'] = self.data['alerts'][-100:]
    
    def add_event(self, event_type: str, event_data: Dict):
        """Add a security event"""
        event = {
            'timestamp': datetime.now().isoformat(),
            'type': event_type,
            'data': event_data,
            'source': self.hostname
        }
        
        self.data['events'].append(event)
        
        # Keep only last 1000 events
        if len(self.data['events']) > 1000:
            self.data['events'] = self.data['events'][-1000:]
    
    def get_stats(self) -> Dict:
        """Get current statistics"""
        return self.data['stats']
    
    def get_recent_alerts(self, limit: int = 10) -> List:
        """Get recent alerts"""
        return self.data['alerts'][-limit:]
    
    def get_recent_events(self, limit: int = 20) -> List:
        """Get recent events"""
        return self.data['events'][-limit:]
    
    def generate_report(self) -> str:
        """Generate security report"""
        report = []
        report.append("=" * 60)
        report.append("Security Dashboard Report")
        report.append("=" * 60)
        report.append(f"Host: {self.hostname}")
        report.append(f"Generated: {datetime.now().isoformat()}")
        report.append("")
        
        stats = self.get_stats()
        report.append("Alert Summary:")
        for severity in ['critical', 'high', 'medium', 'low']:
            count = stats.get(severity, 0)
            report.append(f"  {severity.upper()}: {count}")
        report.append(f"  TOTAL: {stats.get('total_alerts', 0)}")
        report.append("")
        
        if self.data['alerts']:
            report.append("Recent Alerts:")
            for alert in self.data['alerts'][-5:]:
                report.append(f"  [{alert['timestamp']}] {alert['severity'].upper()}: {alert['message']}")
        
        return '\n'.join(report)
    
    def display_dashboard(self):
        """Display live dashboard"""
        import os
        import time
        
        while True:
            os.system('clear' if os.name == 'posix' else 'cls')
            
            print("=" * 60)
            print("SECURITY MONITORING DASHBOARD")
            print("=" * 60)
            print(f"Last Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"Host: {self.hostname}")
            print("")
            
            stats = self.get_stats()
            print("Alert Statistics:")
            print(f"  CRITICAL: {stats.get('critical', 0)}")
            print(f"  HIGH: {stats.get('high', 0)}")
            print(f"  MEDIUM: {stats.get('medium', 0)}")
            print(f"  LOW: {stats.get('low', 0)}")
            print(f"  TOTAL: {stats.get('total_alerts', 0)}")
            print("")
            
            print("Recent Alerts:")
            for alert in self.data['alerts'][-5:]:
                print(f"  [{alert['timestamp'][:19]}] {alert['severity'].upper()}: {alert['message']}")
            print("")
            
            print("Recent Events:")
            for event in self.data['events'][-3:]:
                print(f"  {event['type']}: {event['data'].get('details', '')}")
            
            time.sleep(5)

def main():
    """Example usage"""
    dashboard = SecurityDashboard()
    
    # Add sample data
    dashboard.add_alert('critical', 'Unauthorized SSH login attempt from 203.0.113.50', 'firewall')
    dashboard.add_alert('high', 'Suspicious outbound connection to 185.165.29.125', 'ids')
    dashboard.add_alert('medium', 'Port scan detected on port 22', 'ids')
    dashboard.add_alert('low', 'Failed login attempt for user admin', 'auth')
    
    # Add events
    dashboard.add_event('auth', {
        'user': 'admin',
        'action': 'login',
        'status': 'failed',
        'source_ip': '192.168.1.50'
    })
    
    dashboard.add_event('network', {
        'source_ip': '10.0.0.5',
        'destination_ip': '203.0.113.50',
        'port': 4444,
        'action': 'outbound'
    })
    
    # Generate report
    print(dashboard.generate_report())
    
    # Start dashboard
    # dashboard.display_dashboard()

if __name__ == "__main__":
    main()
```

---

## 9. Incident Response

### Incident Response Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                    INCIDENT RESPONSE LIFECYCLE              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Phase 1: Preparation                              │    │
│  │  ├─ Develop IR plan                                │    │
│  │  ├─ Train team                                     │    │
│  │  ├─ Set up tools                                   │    │
│  │  └─ Conduct exercises                              │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Phase 2: Detection and Analysis                   │    │
│  │  ├─ Detect incident                                │    │
│  │  ├─ Triage alerts                                  │    │
│  │  ├─ Collect evidence                               │    │
│  │  └─ Determine scope                                │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Phase 3: Containment, Eradication, Recovery       │    │
│  │  ├─ Isolate affected systems                       │    │
│  │  ├─ Remove malware                                 │    │
│  │  ├─ Patch vulnerabilities                          │    │
│  │  └─ Restore systems                                │    │
│  └────────────────────────────────────────────────────┘    │
│                         │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  Phase 4: Post-Incident Activity                   │    │
│  │  ├─ Document incident                              │    │
│  │  ├─ Conduct lessons learned                        │    │
│  │  ├─ Update IR plan                                 │    │
│  │  └─ Improve controls                               │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Incident Response Toolkit

```python
#!/usr/bin/env python3
"""
incident_response.py - Incident response toolkit
"""

import subprocess
import json
import socket
import os
import datetime
from typing import Dict, List, Optional
import psutil
import netifaces

class IncidentResponse:
    """
    Incident response tools and utilities
    """
    
    def __init__(self):
        self.timestamp = datetime.datetime.now().isoformat()
        self.hostname = socket.gethostname()
        self.data = {
            'timestamp': self.timestamp,
            'hostname': self.hostname,
            'evidence': {}
        }
    
    def collect_system_info(self) -> Dict:
        """Collect system information"""
        info = {
            'hostname': socket.gethostname(),
            'ip_addresses': self.get_ip_addresses(),
            'os': os.uname(),
            'uptime': self.get_uptime(),
            'cpu': psutil.cpu_percent(interval=1),
            'memory': psutil.virtual_memory()._asdict(),
            'disk': psutil.disk_usage('/')._asdict(),
            'running_processes': self.get_running_processes()
        }
        
        self.data['evidence']['system_info'] = info
        return info
    
    def get_ip_addresses(self) -> List[str]:
        """Get all IP addresses"""
        addresses = []
        for interface in netifaces.interfaces():
            addrs = netifaces.ifaddresses(interface)
            if netifaces.AF_INET in addrs:
                for addr in addrs[netifaces.AF_INET]:
                    addresses.append(addr['addr'])
        return addresses
    
    def get_uptime(self) -> str:
        """Get system uptime"""
        try:
            with open('/proc/uptime', 'r') as f:
                uptime_seconds = float(f.read().split()[0])
                days = int(uptime_seconds // 86400)
                hours = int((uptime_seconds % 86400) // 3600)
                minutes = int((uptime_seconds % 3600) // 60)
                return f"{days}d {hours}h {minutes}m"
        except:
            return "Unknown"
    
    def get_running_processes(self) -> List[Dict]:
        """Get running processes"""
        processes = []
        for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'connections']):
            try:
                proc_info = proc.info
                processes.append({
                    'pid': proc_info['pid'],
                    'name': proc_info['name'],
                    'cmdline': ' '.join(proc_info['cmdline']) if proc_info['cmdline'] else '',
                    'connections': len(proc_info['connections']) if proc_info['connections'] else 0
                })
            except:
                pass
        return processes[:100]  # Return top 100
    
    def collect_network_connections(self) -> List[Dict]:
        """Collect network connections"""
        connections = []
        for conn in psutil.net_connections(kind='inet'):
            connections.append({
                'fd': conn.fd,
                'family': conn.family,
                'type': conn.type,
                'local_addr': f"{conn.laddr.ip}:{conn.laddr.port}" if conn.laddr else '',
                'remote_addr': f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else '',
                'status': conn.status,
                'pid': conn.pid
            })
        
        self.data['evidence']['network_connections'] = connections
        return connections
    
    def collect_logs(self, log_file: str, lines: int = 100) -> List[str]:
        """Collect logs from a file"""
        try:
            result = subprocess.run(['tail', '-n', str(lines), log_file], 
                                  capture_output=True, text=True)
            logs = result.stdout.split('\n')
            self.data['evidence']['logs'] = logs
            return logs
        except Exception as e:
            return [f"Error collecting logs: {e}"]
    
    def run_forensic_commands(self) -> Dict:
        """Run forensic commands"""
        commands = {
            'netstat': ['netstat', '-tulpn'],
            'last': ['last'],
            'users': ['users'],
            'who': ['who'],
            'lastlog': ['lastlog'],
            'ps': ['ps', 'aux'],
            'systemd': ['systemctl', 'list-units', '--all'],
        }
        
        results = {}
        for name, cmd in commands.items():
            try:
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
                results[name] = result.stdout
            except Exception as e:
                results[name] = f"Error: {e}"
        
        self.data['evidence']['forensic_commands'] = results
        return results
    
    def generate_report(self) -> str:
        """Generate incident report"""
        report = []
        report.append("=" * 80)
        report.append("INCIDENT RESPONSE REPORT")
        report.append("=" * 80)
        report.append(f"Hostname: {self.hostname}")
        report.append(f"Timestamp: {self.timestamp}")
        report.append("")
        
        # System info
        if 'system_info' in self.data['evidence']:
            info = self.data['evidence']['system_info']
            report.append("SYSTEM INFORMATION:")
            report.append(f"  OS: {info['os']}")
            report.append(f"  Uptime: {info.get('uptime', 'Unknown')}")
            report.append(f"  CPU: {info.get('cpu', 'Unknown')}%")
            report.append(f"  Memory: {info.get('memory', {}).get('percent', 'Unknown')}%")
            report.append("")
        
        # Network connections
        if 'network_connections' in self.data['evidence']:
            report.append("NETWORK CONNECTIONS:")
            for conn in self.data['evidence']['network_connections'][:20]:
                report.append(f"  {conn.get('local_addr', '')} -> {conn.get('remote_addr', '')} [{conn.get('status', '')}]")
            report.append("")
        
        # Running processes
        if 'system_info' in self.data['evidence']:
            report.append("RUNNING PROCESSES:")
            for proc in self.data['evidence']['system_info'].get('running_processes', [])[:20]:
                report.append(f"  {proc['pid']}: {proc['name']} [{proc['cmdline'][:50]}]")
            report.append("")
        
        return '\n'.join(report)
    
    def save_report(self, filename: str = None):
        """Save report to file"""
        if not filename:
            filename = f"incident_report_{self.timestamp.replace(':', '-')}.txt"
        
        with open(filename, 'w') as f:
            f.write(self.generate_report())
        
        print(f"Report saved to {filename}")
        return filename

def main():
    """Example usage"""
    ir = IncidentResponse()
    
    print("Collecting incident data...")
    
    # Collect system info
    ir.collect_system_info()
    
    # Collect network connections
    ir.collect_network_connections()
    
    # Run forensic commands
    ir.run_forensic_commands()
    
    # Generate report
    report = ir.generate_report()
    print(report)
    
    # Save report
    ir.save_report()

if __name__ == "__main__":
    main()
```

### Incident Response Checklist

```
┌─────────────────────────────────────────────────────────────┐
│                    INCIDENT RESPONSE CHECKLIST              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ☐ Preparation                                            │
│    ☐ Incident response plan documented                    │
│    ☐ Incident response team identified                    │
│    ☐ Communication channels established                   │
│    ☐ Tools and resources available                        │
│    ☐ Regular drills conducted                             │
│                                                             │
│  ☐ Detection and Analysis                                 │
│    ☐ Incident detected via monitoring                     │
│    ☐ Alert triaged                                        │
│    ☐ Initial investigation conducted                      │
│    ☐ Scope and impact assessed                            │
│    ☐ Evidence collected                                   │
│    ☐ Severity determined                                  │
│                                                             │
│  ☐ Containment                                            │
│    ☐ Affected systems isolated                            │
│    ☐ Network segmentation applied                         │
│    ☐ Forensic image captured                              │
│    ☐ Temporary fixes implemented                          │
│    ☐ Business continuity engaged                          │
│                                                             │
│  ☐ Eradication                                            │
│    ☐ Root cause identified                                │
│    ☐ Malware removed                                      │
│    ☐ Patches applied                                      │
│    ☐ Vulnerabilities addressed                            │
│    ☐ Security controls enhanced                           │
│                                                             │
│  ☐ Recovery                                               │
│    ☐ Systems restored from clean backups                  │
│    ☐ Data integrity verified                              │
│    ☐ Systems tested                                       │
│    ☐ Normal operations resumed                            │
│    ☐ Monitoring enhanced                                  │
│                                                             │
│  ☐ Post-Incident                                          │
│    ☐ Lessons learned documented                           │
│    ☐ Incident report created                              │
│    ☐ IR plan updated                                      │
│    ☐ Recommendations implemented                          │
│    ☐ Team debrief conducted                               │
│    ☐ Compliance requirements met                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 10. Compliance and Standards

### Compliance Frameworks

| Framework | Focus | Key Requirements |
|-----------|-------|------------------|
| **ISO 27001** | Information Security Management | Risk assessment, controls, monitoring |
| **NIST Cybersecurity Framework** | Risk Management | Identify, Protect, Detect, Respond, Recover |
| **GDPR** | Data Protection | Privacy, consent, breach notification |
| **HIPAA** | Healthcare Data Security | PHI protection, access controls, audits |
| **PCI DSS** | Payment Card Security | Network segmentation, encryption, logging |
| **SOC 2** | Service Organization Controls | Security, availability, processing integrity |
| **CIS Controls** | Cybersecurity Best Practices | 18 critical security controls |

### Security Standards

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY STANDARDS                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Network Security Standards:                                │
│  ├─ IEEE 802.1X - Port-based Network Access Control        │
│  ├─ IEEE 802.1AE - MAC Security (MACsec)                   │
│  ├─ IEEE 802.1AR - Secure Device Identity                  │
│  ├─ TLS 1.2/1.3 - Transport Layer Security                 │
│  └─ IPsec - IP Security                                    │
│                                                             │
│  Authentication Standards:                                  │
│  ├─ SAML - Security Assertion Markup Language              │
│  ├─ OAuth 2.0 - Authorization Framework                    │
│  ├─ OpenID Connect - Authentication                        │
│  ├─ RADIUS - Remote Authentication                         │
│  └─ LDAP - Lightweight Directory Access Protocol           │
│                                                             │
│  Cryptographic Standards:                                   │
│  ├─ AES - Advanced Encryption Standard                     │
│  ├─ RSA - Rivest-Shamir-Adleman                           │
│  ├─ ECC - Elliptic Curve Cryptography                      │
│  ├─ SHA-256/384/512 - Secure Hash Algorithm                │
│  └─ HMAC - Hash-based Message Authentication Code          │
│                                                             │
│  Security Frameworks:                                       │
│  ├─ NIST SP 800-53 - Security and Privacy Controls         │
│  ├─ NIST SP 800-171 - Protecting CUI                       │
│  ├─ CIS Benchmarks - Configuration Guidelines              │
│  └─ OWASP - Web Application Security                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Security Audit Script

```python
#!/usr/bin/env python3
"""
security_audit.py - Automated security audit
"""

import subprocess
import json
import socket
import os
import datetime
from typing import Dict, List, Tuple

class SecurityAudit:
    """
    Automated security audit
    """
    
    def __init__(self):
        self.hostname = socket.gethostname()
        self.timestamp = datetime.datetime.now().isoformat()
        self.results = {
            'timestamp': self.timestamp,
            'hostname': self.hostname,
            'checks': {},
            'pass': 0,
            'fail': 0,
            'warning': 0
        }
    
    def add_check(self, name: str, passed: bool, message: str, severity: str = 'medium'):
        """Add a check result"""
        self.results['checks'][name] = {
            'passed': passed,
            'message': message,
            'severity': severity
        }
        
        if passed:
            self.results['pass'] += 1
        else:
            self.results['fail'] += 1
    
    def run_checks(self):
        """Run all security checks"""
        print("Running security audit...")
        
        # 1. Check firewall
        self.check_firewall()
        
        # 2. Check SSH configuration
        self.check_ssh()
        
        # 3. Check password policies
        self.check_password_policy()
        
        # 4. Check software updates
        self.check_updates()
        
        # 5. Check open ports
        self.check_open_ports()
        
        # 6. Check file permissions
        self.check_file_permissions()
        
        # 7. Check audit logging
        self.check_audit_logging()
        
        # 8. Check SELinux/AppArmor
        self.check_mandatory_access_control()
    
    def check_firewall(self):
        """Check firewall configuration"""
        try:
            result = subprocess.run(['iptables', '-L', '-n'], capture_output=True, text=True)
            if 'Chain INPUT (policy DROP)' in result.stdout or 'Chain INPUT (policy ACCEPT)' not in result.stdout:
                self.add_check('Firewall', True, 'Firewall is configured', 'low')
            else:
                self.add_check('Firewall', False, 'Firewall default policy is ACCEPT', 'high')
        except:
            self.add_check('Firewall', False, 'iptables not available', 'high')
    
    def check_ssh(self):
        """Check SSH configuration"""
        try:
            with open('/etc/ssh/sshd_config', 'r') as f:
                config = f.read()
            
            checks = []
            
            if 'PermitRootLogin no' in config:
                checks.append('Root login disabled')
            else:
                checks.append('Root login NOT disabled')
            
            if 'PasswordAuthentication no' in config:
                checks.append('Password authentication disabled')
            else:
                checks.append('Password authentication NOT disabled')
            
            if 'PubkeyAuthentication yes' in config:
                checks.append('Public key authentication enabled')
            else:
                checks.append('Public key authentication NOT enabled')
            
            failed = [c for c in checks if 'NOT' in c]
            
            if failed:
                self.add_check('SSH', False, f'SSH hardening issues: {", ".join(failed)}', 'high')
            else:
                self.add_check('SSH', True, 'SSH properly configured', 'low')
                
        except:
            self.add_check('SSH', False, 'SSH configuration not found', 'high')
    
    def check_password_policy(self):
        """Check password policies"""
        try:
            with open('/etc/login.defs', 'r') as f:
                config = f.read()
            
            issues = []
            
            if 'PASS_MAX_DAYS' not in config:
                issues.append('No password expiration')
            else:
                # Extract value
                for line in config.split('\n'):
                    if line.startswith('PASS_MAX_DAYS'):
                        days = line.split()[1]
                        if int(days) > 90:
                            issues.append(f'Password expiration > 90 days ({days})')
            
            if 'PASS_MIN_LEN' in config:
                for line in config.split('\n'):
                    if line.startswith('PASS_MIN_LEN'):
                        length = line.split()[1]
                        if int(length) < 8:
                            issues.append(f'Password length < 8 ({length})')
            
            if issues:
                self.add_check('Password Policy', False, f'Issues: {", ".join(issues)}', 'medium')
            else:
                self.add_check('Password Policy', True, 'Password policy meets requirements', 'low')
                
        except:
            self.add_check('Password Policy', False, 'Unable to check password policy', 'medium')
    
    def check_updates(self):
        """Check for system updates"""
        try:
            # Check for available updates (Ubuntu/Debian)
            result = subprocess.run(['apt', 'list', '--upgradable'], capture_output=True, text=True, timeout=30)
            lines = result.stdout.split('\n')
            upgradable = [l for l in lines if l and l.startswith('...')]
            
            if upgradable:
                self.add_check('Updates', False, f'{len(upgradable)} updates available', 'medium')
            else:
                self.add_check('Updates', True, 'System is up to date', 'low')
                
        except:
            # Try for different package managers
            try:
                result = subprocess.run(['yum', 'check-update'], capture_output=True, text=True, timeout=30)
                if result.returncode == 100:  # Updates available
                    self.add_check('Updates', False, 'Updates available', 'medium')
                else:
                    self.add_check('Updates', True, 'System is up to date', 'low')
            except:
                self.add_check('Updates', False, 'Unable to check for updates', 'medium')
    
    def check_open_ports(self):
        """Check for unnecessary open ports"""
        try:
            result = subprocess.run(['ss', '-tuln'], capture_output=True, text=True)
            lines = result.stdout.split('\n')[1:]  # Skip header
            
            open_ports = []
            for line in lines:
                if line:
                    parts = line.split()
                    if len(parts) >= 4:
                        port = parts[3].split(':')[-1]
                        if port.isdigit():
                            open_ports.append(int(port))
            
            # Check for unnecessary ports
            dangerous_ports = [23, 21, 111, 515, 1701, 1723, 2049, 3306, 5432]
            open_dangerous = [p for p in open_ports if p in dangerous_ports]
            
            if open_dangerous:
                self.add_check('Open Ports', False, f'Dangerous ports open: {open_dangerous}', 'high')
            else:
                self.add_check('Open Ports', True, 'No dangerous ports open', 'medium')
                
        except Exception as e:
            self.add_check('Open Ports', False, f'Unable to check open ports: {e}', 'medium')
    
    def check_file_permissions(self):
        """Check critical file permissions"""
        try:
            critical_files = [
                ('/etc/passwd', '644'),
                ('/etc/shadow', '600'),
                ('/etc/sudoers', '440'),
                ('/etc/ssh/sshd_config', '600'),
                ('/etc/security/access.conf', '600')
            ]
            
            issues = []
            for file_path, expected in critical_files:
                if os.path.exists(file_path):
                    import stat
                    perms = oct(stat.S_IMODE(os.stat(file_path).st_mode))[2:]
                    if perms != expected:
                        issues.append(f'{file_path}: {perms} (expected {expected})')
            
            if issues:
                self.add_check('File Permissions', False, f'Issues: {", ".join(issues)}', 'high')
            else:
                self.add_check('File Permissions', True, 'Critical file permissions correct', 'low')
                
        except Exception as e:
            self.add_check('File Permissions', False, f'Unable to check permissions: {e}', 'medium')
    
    def check_audit_logging(self):
        """Check audit logging configuration"""
        try:
            result = subprocess.run(['auditctl', '-l'], capture_output=True, text=True)
            rules = result.stdout.split('\n')
            
            if len(rules) > 5:  # Some basic rules
                self.add_check('Audit Logging', True, 'Audit logging is configured', 'low')
            else:
                self.add_check('Audit Logging', False, 'Audit logging not configured', 'high')
                
        except FileNotFoundError:
            self.add_check('Audit Logging', False, 'auditd not installed', 'medium')
        except Exception as e:
            self.add_check('Audit Logging', False, f'Unable to check auditd: {e}', 'medium')
    
    def check_mandatory_access_control(self):
        """Check SELinux/AppArmor"""
        try:
            # Check SELinux
            result = subprocess.run(['getenforce'], capture_output=True, text=True)
            status = result.stdout.strip()
            
            if status in ['Enforcing', 'Permissive']:
                self.add_check('MAC', True, f'SELinux is {status}', 'low')
            else:
                self.add_check('MAC', False, f'SELinux is {status}', 'medium')
                
        except FileNotFoundError:
            try:
                # Check AppArmor
                result = subprocess.run(['apparmor_status'], capture_output=True, text=True)
                if 'profiles are in enforce mode' in result.stdout:
                    self.add_check('MAC', True, 'AppArmor is enforcing', 'low')
                else:
                    self.add_check('MAC', False, 'AppArmor not enforcing', 'medium')
            except:
                self.add_check('MAC', False, 'No mandatory access control found', 'high')
    
    def generate_report(self) -> str:
        """Generate audit report"""
        report = []
        report.append("=" * 80)
        report.append("SECURITY AUDIT REPORT")
        report.append("=" * 80)
        report.append(f"Host: {self.hostname}")
        report.append(f"Timestamp: {self.timestamp}")
        report.append("")
        report.append(f"Summary:")
        report.append(f"  Pass: {self.results['pass']}")
        report.append(f"  Fail: {self.results['fail']}")
        report.append(f"  Total Checks: {len(self.results['checks'])}")
        report.append("")
        report.append("Detailed Results:")
        report.append("-" * 80)
        
        for name, check in self.results['checks'].items():
            status = "PASS" if check['passed'] else "FAIL"
            severity = f"[{check['severity'].upper()}]"
            report.append(f"{status:>8} {severity:>8} {name:>20}: {check['message']}")
        
        report.append("-" * 80)
        
        # Overall assessment
        fail_percentage = (self.results['fail'] / max(1, len(self.results['checks']))) * 100
        
        if fail_percentage == 0:
            assessment = "EXCELLENT - No issues found"
        elif fail_percentage < 20:
            assessment = "GOOD - Minor issues found"
        elif fail_percentage < 50:
            assessment = "FAIR - Several issues found"
        else:
            assessment = "POOR - Critical issues found"
        
        report.append("")
        report.append(f"Overall Assessment: {assessment}")
        report.append("")
        report.append("=" * 80)
        
        return '\n'.join(report)
    
    def save_report(self, filename: str = None):
        """Save audit report to file"""
        if not filename:
            filename = f"security_audit_{self.timestamp.replace(':', '-')}.txt"
        
        with open(filename, 'w') as f:
            f.write(self.generate_report())
        
        print(f"Audit report saved to {filename}")

def main():
    """Main entry point"""
    audit = SecurityAudit()
    audit.run_checks()
    
    # Print report
    report = audit.generate_report()
    print(report)
    
    # Save report
    audit.save_report()

if __name__ == "__main__":
    main()
```

---

## Summary

This appendix has covered comprehensive network security topics:

1. **Security Fundamentals** - CIA triad, principles, controls
2. **Network Security Architecture** - Defense in depth, segmentation, zero trust
3. **Authentication and Authorization** - Methods, MFA, access models
4. **Access Control** - Firewalls, ACLs, NAC, VPNs
5. **Network Encryption** - Protocols, TLS, IPsec, SSH
6. **Threat Detection and Monitoring** - IDS/IPS, SIEM, logging
7. **Common Attacks and Mitigations** - DDoS, SQL injection, malware
8. **Security Best Practices** - Checklists, hardening
9. **Incident Response** - Lifecycle, tools, procedures
10. **Compliance and Standards** - Frameworks, standards, auditing

**Key Takeaways**:

1. **Defense in depth** - Multiple layers of security
2. **Zero trust** - Never trust, always verify
3. **Least privilege** - Minimum necessary access
4. **Continuous monitoring** - Detect threats early
5. **Regular auditing** - Verify security controls
6. **Incident response plan** - Be prepared
7. **Stay updated** - Threats and defenses evolve
8. **Compliance matters** - Follow regulations

---

**[END OF APPENDIX G]**
