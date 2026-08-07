# References and Resources

## Complete Reference Guide for Software Supply Chain Security

---

## 1. OFFICIAL DOCUMENTATION & STANDARDS

### Software Composition Analysis (SCA) Standards

| Resource | Description | Link/Reference |
|----------|-------------|----------------|
| **CVE Database** | Common Vulnerabilities and Exposures - the industry standard for vulnerability identifiers | cve.mitre.org |
| **NVD** | National Vulnerability Database - U.S. government repository of vulnerability data | nvd.nist.gov |
| **SBOM Standards** | Software Bill of Materials - formal specification for listing dependencies | cisa.gov/sbom |
| **OWASP SCA Guide** | Comprehensive guide to component analysis | owasp.org/www-community/Component_Analysis |
| **EU Cyber Resilience Act** | Regulatory requirements for software supply chain security | ec.europa.eu |

### npm Official Documentation

| Resource | Description |
|----------|-------------|
| **npm CLI Docs** | Official npm command-line documentation | docs.npmjs.com/cli |
| **npm Security Best Practices** | Official security guidance from npm | docs.npmjs.com/security |
| **npm Audit** | Built-in vulnerability scanning tool | docs.npmjs.com/auditing-package-dependencies |
| **npm Package.json** | Complete package.json specification | docs.npmjs.com/creating-a-package-json-file |

---

## 2. SECURITY TOOLS & INTEGRATIONS

### SCA Platforms

| Tool | Type | Description |
|------|------|-------------|
| **Socket** | Behavioral SCA | Capability-based security analysis for npm packages. Detects supply chain attacks through behavioral analysis rather than just CVE matching . |
| **Snyk** | Comprehensive SCA | Developer-first security platform with CVE coverage, remediation advice, and CI/CD integration  . |
| **Trivy** | Open Source Scanner | Comprehensive vulnerability scanner for containers and dependencies . |
| **Grype** | Open Source Scanner | Vulnerability scanner for container images and filesystems . |
| **OWASP Dependency-Check** | Open Source Scanner | Detects publicly disclosed vulnerabilities in project dependencies  . |

### Integration Tools

| Tool | Purpose |
|------|---------|
| **pysnyk** | Python client for Snyk API - supports organizations, projects, and vulnerability testing . |
| **snyk-api-ts-client** | TypeScript client for Snyk API (v1 only) . |
| **Socket Python SDK v3.0.3** | Full coverage of Socket.dev API v0 . |
| **@lavamoat/allow-scripts** | Create allowlists for package lifecycle scripts . |

---

## 3. SUPPLY CHAIN INCIDENT CASE STUDIES

### Major Incidents

#### Event-Stream (2018)
A critical case study in supply chain security. The attacker gained maintainer access by simply asking for it, then introduced a malicious dependency (flatmap-stream) that stole Bitcoin wallet keys  .

**Key Details:**
- Attacker gained publish rights through legitimate maintainer handoff 
- Malicious code was hidden in `flatmap-stream` dependency, not in `event-stream` itself  
- Payload only activated when installed alongside Copay Bitcoin wallet  
- Targeted wallets with $100-$1,000,000 in cryptocurrency 
- Approximately 2 million weekly downloads at time of incident 
- **Sat undetected for ~10 weeks** before discovery  

**Timeline:**
- July 31, 2015: `@devinus` comments on event-stream about flatmap functionality 
- August-September 2018: `@right9ctrl` offers to take over maintenance 
- September 9, 2018: `@right9ctrl` publishes event-stream 3.3.6 with flatmap-stream dependency 
- September 2018: flatmap-stream 0.1.1 published with encrypted malicious payload 
- November 20, 2018: Developer flags flatmap-stream as suspicious in GitHub issue 
- November 2018: npm removes flatmap-stream; event-stream 4.0.0 published 

**Lessons Learned:**
- **Transitive dependencies are dangerous**: "Most organizations audit the packages they add to `package.json` far more carefully than the transitive dependencies those packages bring along" 
- **Maintainer identity is attack surface**: No mechanism existed to flag unvetted transfer of publish rights  
- **Malicious code can be targeted**: "Malicious code can be built to stay invisible to anyone who isn't the intended victim" 

#### Shai-Hulud Campaigns (2025)
The most sophisticated npm supply chain attack to date .

**Shai-Hulud 1.0 (September 2025):**
- Self-replicating worm exploiting npm `postinstall` hooks
- Injected `shai-hulud-workflow.yml` into `.github/workflows/`
- Exfiltrated credentials via curl/wget
- 180+ packages compromised 

**Shai-Hulud 2.0 (November 2025):**
- Shifted to `preinstall` execution for broader blast radius 
- 700+ npm packages compromised (Zapier, ENS Domains, PostHog, Postman) 
- 25,000+ repositories affected across ~500 GitHub users 
- Propagation rate: ~1,000 new repos every 30 minutes 
- Multi-cloud credential harvesting: AWS, Azure, GCP 
- Backdoor workflow `discussion.yaml` enabling remote command injection 

**Kill Chain Coverage:**
```
1. Initial Access: Compromised/malicious npm package installed
2. Execution: preinstall/postinstall lifecycle hook executes
3. Persistence: Malicious workflow injection, self-hosted runner backdoor
4. Credential Access: Cloud credential harvesting (AWS/Azure/GCP)
5. Exfiltration: Secrets pushed to attacker repositories / C2
6. Defense Evasion: Audit log tampering, branch protection bypass 
```

#### Other Notable Incidents

| Incident | Year | Type | Impact |
|----------|------|------|--------|
| **ua-parser-js** | 2021 | Cryptominer/Credential Stealer | Compromised maintainer account  |
| **node-ipc** | 2022 | Protestware | Destructive payloads, political messaging  |
| **colors.js** | 2022 | Protestware | Intentional breakage, malicious code  |
| **ansi-regex** | 2021 | ReDoS Vulnerability | Catastrophic backtracking in regex, Stalled event loop  |
| **Log4Shell** | 2021 | Critical Vulnerability | Affected millions of Java applications, CVE-2021-44228  |

---

## 4. SECURITY BEST PRACTICES

### npm Configuration

Based on industry-leading security practices  :

#### .npmrc Security Settings
```ini
# DISABLE all lifecycle scripts (postinstall, preinstall, etc.)
# PRIMARY DEFENSE against supply chain attacks
ignore-scripts=true

# BLOCK git-based dependencies - bypasses registry security controls
allow-git=none

# COOLDOWN PERIOD - only install packages older than 30 days
# Allows time for community to discover and report malicious versions
min-release-age=30
```

**Why These Settings Matter:**
- **`ignore-scripts=true`**: `postinstall` scripts are the most common attack vector for npm supply chain attacks  
- **`allow-git=none`**: Git-sourced dependencies bypass registry security scanning, provenance attestations, and signature verification 
- **`min-release-age=30`**: Newly published malicious versions are often discovered within hours or days and subsequently unpublished 

### pnpm Security Configuration

```yaml
# pnpm-workspace.yaml

# SECURITY: block packages newer than 30 days
minimumReleaseAge: 43200

# SECURITY: fail if package trust level decreased
trustPolicy: no-downgrade

# SECURITY: block exotic subdependencies (git sources)
blockExoticSubdeps: true

# SECURITY: strict control over lifecycle scripts
allowBuilds:
  esbuild: true
  rolldown: true

# SECURITY: fail install if unapproved build script runs
strictDepBuilds: true
```

### Secure Package Publishing Checklist 

- [ ] **Enable trusted publishing with provenance** - Use OIDC-based publishing from CI, never long-lived tokens
- [ ] **Require 2FA** on npm account AND package publish settings
- [ ] **Use `files` allowlist** in package.json to publish minimum files
- [ ] **Remove unnecessary `postinstall` and `preinstall` scripts**
- [ ] **Commit lockfile** - Ensures deterministic builds
- [ ] **Run `npm audit` in CI** - Catch vulnerabilities early
- [ ] **Pin CI actions by commit SHA** - Not by mutable tags
- [ ] **Test parsers against ReDoS attacks** - Bound input length, avoid nested regex quantifiers

---

## 5. ACADEMIC RESEARCH

### Supply Chain Security Research

| Paper | Authors | Key Findings |
|-------|---------|--------------|
| **"A Systematic Analysis of the Event-Stream Incident"** | Arvanitis et al., EUROSEC '22  | • Attack activated only on specific environments<br>• Conventional analysis would miss the attack<br>• Manual vetting inadequate given scale of dependencies |
| **"Security and Quality in LLM-Generated Code"** | IEEE TDSC  | • Language effects: Python/Java have fewer security findings than C/C++<br>• Models fail to use modern security features (e.g., Java 17)<br>• Outdated methods remain common, particularly in C++ |

### Advanced Detection Research

| Topic | Description |
|-------|-------------|
| **Graph + LLM for Malware Detection** | Graph-centric attention pipeline enhances LLM ability to detect malicious behavior fragmented across files  |
| **Graph Neural Network + LLM** | GNN performs initial detection, identifies key code sections for focused LLM analysis  |

---

## 6. COMMUNITY & GOVERNMENT GUIDANCE

### Government Resources

| Resource | Organization | Description |
|----------|--------------|-------------|
| **CISA SBOM Guidance** | CISA | Software Bill of Materials requirements and best practices  |
| **TR-03183-2** | BSI (Germany) | Technical guideline for SBOM  |
| **Secure by Design Principles** | BSI et al. (2023) | Latest security principles for design  |
| **NIST SP Series** | NIST | Cryptography and security standards  |
| **FDA Requirements** | FDA | SBOM and vulnerability management mandatory  |

### OWASP Resources

| Resource | Description |
|----------|-------------|
| **OWASP Dependency-Check** | Open source SCA tool  |
| **OWASP Component Analysis** | Community guide for SCA  |
| **OWASP Source Code Analysis Tools** | Comprehensive list of SAST tools  |

---

## 7. ESSENTIAL BLOG POSTS & ARTICLES

### Security Best Practices

| Title | Description |
|-------|-------------|
| **"How to Set Up Software Composition Analysis (SCA)"** | Practical step-by-step guide to implementing SCA  |
| **"How to Build a Secure npm Package (2026)"** | Provenance, hardening, and secure publishing checklist  |
| **"npm Security Best Practices"** | Curated list from lirantal - includes TL;DR copy/paste configs  |

### Incident Analysis

| Title | Description |
|-------|-------------|
| **"event-stream npm package backdoor incident"** | Complete analysis of the event-stream backdoor  |
| **"npm Supply Chain Compromise & Lifecycle Hook Abuse"** | Splunk security content for detecting npm attacks  |

---

## 8. QUICK REFERENCE CARDS

### TL;DR: Secure npm Configuration

Copy and paste this `.npmrc` configuration:

```ini
# SECURITY: Disable all lifecycle scripts
ignore-scripts=true

# SECURITY: Block git-source dependencies
allow-git=none

# SECURITY: Only install packages older than 30 days
min-release-age=30
```

### TL;DR: Secure pnpm Configuration

Copy and paste this `pnpm-workspace.yaml`:

```yaml
# SECURITY: Minimum release age (30 days)
minimumReleaseAge: 43200

# SECURITY: No trust downgrades
trustPolicy: no-downgrade

# SECURITY: Block exotic subdependencies
blockExoticSubdeps: true

# SECURITY: Strict build script control
strictDepBuilds: true

allowBuilds:
  esbuild: true
  rolldown: true
```

### TL;DR: Secure Package Publishing

```yaml
# .github/workflows/publish.yml
permissions:
  id-token: write   # Required for OIDC
  contents: read

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          registry-url: https://registry.npmjs.org
      - run: npm ci
      - run: npm publish --provenance --access public
```

---

## 9. CONTINUOUS LEARNING

### Recommended Reading

1. **CISA Secure by Design Principles** - cisa.gov/secure-by-design
2. **NVD Vulnerability Database** - nvd.nist.gov
3. **OWASP Top 10** - owasp.org/Top10/
4. **npm Documentation** - docs.npmjs.com

### Monitoring Resources

- **npm Security Advisories** - github.com/advisories?query=ecosystem%3Anpm
- **Snyk Vulnerability DB** - snyk.io/vuln
- **CVE Database** - cve.mitre.org

### Tools to Explore Further

- **Trivy** - github.com/aquasecurity/trivy
- **Grype** - github.com/anchore/grype
- **OWASP Dependency-Check** - owasp.org/www-project-dependency-check
- **Socket** - socket.dev
- **Snyk** - snyk.io

---

## 10. GLOSSARY OF KEY TERMS

| Term | Definition |
|------|------------|
| **SCA** | Software Composition Analysis - analyzing open-source dependencies for security risks  |
| **CVE** | Common Vulnerabilities and Exposures - standardized identifier for security vulnerabilities  |
| **SBOM** | Software Bill of Materials - comprehensive list of dependencies in a software product  |
| **Provenance** | Signed attestation linking published package to source commit and build  |
| **Trusted Publishing** | OIDC-based publishing from CI, eliminates long-lived tokens  |
| **Supply Chain Attack** | Attack targeting software dependencies rather than directly targeting the victim  |
| **Transitive Dependency** | Dependency of a dependency  |
| **ReDoS** | Regular Expression Denial of Service - catastrophic backtracking attack  |
| **Typosquatting** | Publishing packages with names similar to popular packages  |
| **Dependency Confusion** | Publishing public versions of internal package names  |

---

**[END OF REFERENCES]**
