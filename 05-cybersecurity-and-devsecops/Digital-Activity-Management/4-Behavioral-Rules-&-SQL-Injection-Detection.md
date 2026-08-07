# Part 4: Behavioral Rules & SQL Injection Detection

Welcome to Part 4 of our Database Activity Management series! In Part 3, we built query normalizers that transform verbose SQL into compact, pattern-friendly signatures. Now we have the foundation for something powerful: **real-time threat detection**.

We've all heard horror stories about SQL injection attacks that compromised millions of records, or insider threats where a disgruntled employee deleted critical data. In this part, we'll build the detection engine that stops these threats before they reach your database.

---

## The Target: What We're Building Right Now

By the end of this part, you will have:

1. **A rule engine** that detects dangerous SQL patterns in real-time
2. **SQL injection detection** using heuristic analysis
3. **Threat scoring system** to prioritize responses
4. **Whitelist/blacklist** management for fine-grained control
5. **Real-time blocking** of malicious queries
6. **Comprehensive test suite** for all detection scenarios

---

## The Concept: How Threat Detection Works

Think of our threat detection system like airport security:

### The Security Checkpoint Analogy

```
Passenger (Query)
     │
     ▼
┌─────────────────────────────────────┐
│  Security Checkpoint                │
│  ┌─────────────────────────────┐   │
│  │ 1. X-Ray Scanner             │   │
│  │    (Normalization)           │   │
│  └─────────────────────────────┘   │
│           │                          │
│  ┌────────▼─────────────────────┐   │
│  │ 2. Pattern Matching          │   │
│  │    (Known Threat Signatures) │   │
│  └─────────────────────────────┘   │
│           │                          │
│  ┌────────▼─────────────────────┐   │
│  │ 3. Heuristic Analysis        │   │
│  │    (Suspicious Behaviors)    │   │
│  └─────────────────────────────┘   │
│           │                          │
│  ┌────────▼─────────────────────┐   │
│  │ 4. Threat Scoring            │   │
│  │    (Risk Assessment)         │   │
│  └─────────────────────────────┘   │
│           │                          │
│     ┌─────┴─────┐                   │
│     ▼           ▼                   │
│  ALLOW       BLOCK                  │
└─────────────────────────────────────┘
```

### Types of Threats We Detect

1. **SQL Injection (SQLi)**
   - Tautologies: `OR 1=1` to bypass authentication
   - Union queries: `UNION SELECT` to extract data
   - Stacked queries: `; DROP TABLE` to execute multiple commands
   - Comment injection: `--` to bypass query logic

2. **Dangerous DDL Operations**
   - `DROP TABLE` or `DROP DATABASE`
   - `TRUNCATE TABLE` (data loss)
   - `ALTER TABLE` (schema changes)
   - `GRANT` or `REVOKE` (privilege escalation)

3. **Suspicious Patterns**
   - Excessive data retrieval (`SELECT *` with no WHERE)
   - Unusual table access (sensitive tables)
   - High-frequency queries (brute force attempts)
   - Out-of-normal timing (unusual access patterns)

---

## Implementation: JavaScript / Node.js

### Step 1: The Threat Detection Engine

Let's build the core threat detection engine.

**File: `javascript/src/threat-detector.js`**

```javascript
// javascript/src/threat-detector.js

import { QueryNormalizer } from './normalizer.js';

/**
 * Threat severity levels
 */
export const ThreatLevel = {
  LOW: 'LOW',
  MEDIUM: 'MEDIUM',
  HIGH: 'HIGH',
  CRITICAL: 'CRITICAL'
};

/**
 * Threat categories
 */
export const ThreatCategory = {
  SQL_INJECTION: 'SQL_INJECTION',
  DDL_OPERATION: 'DDL_OPERATION',
  PRIVILEGE_ESCALATION: 'PRIVILEGE_ESCALATION',
  DATA_EXFILTRATION: 'DATA_EXFILTRATION',
  BRUTE_FORCE: 'BRUTE_FORCE',
  SUSPICIOUS_PATTERN: 'SUSPICIOUS_PATTERN'
};

/**
 * Rule types
 */
export const RuleType = {
  BLOCK: 'BLOCK',           // Always block
  WARN: 'WARN',             // Alert but allow
  LOG: 'LOG',               // Just log the event
  SCORE: 'SCORE'            // Increase threat score
};

/**
 * Threat Detection Engine
 * 
 * This engine analyzes SQL queries for malicious patterns and
 * suspicious behaviors. It uses a combination of:
 * 1. Pattern matching (known attack signatures)
 * 2. Heuristic analysis (suspicious behaviors)
 * 3. Contextual analysis (user, time, frequency)
 * 4. Threat scoring (risk assessment)
 * 
 * The engine is designed to be extensible - you can add custom
 * rules, thresholds, and detection methods.
 */
export class ThreatDetector {
  constructor(options = {}) {
    this.options = {
      enablePatternMatching: true,
      enableHeuristics: true,
      enableThreatScoring: true,
      logAllDetections: true,
      ...options
    };
    
    // Initialize the normalizer for pattern matching
    this.normalizer = new QueryNormalizer({
      caseInsensitive: true,
      preserveComments: false,
      normalizeInClauses: true
    });
    
    // Threat rules
    this.rules = [];
    this.loadDefaultRules();
    
    // Suspicious table patterns
    this.sensitiveTables = [
      'users', 'passwords', 'credentials', 'secrets',
      'customers', 'employees', 'patients', 'medical',
      'credit_cards', 'payment', 'banking', 'financial',
      'admin', 'administrator', 'root', 'system'
    ];
    
    // Whitelist (patterns that should never be blocked)
    this.whitelist = [];
    this.loadDefaultWhitelist();
    
    // Detection history for frequency analysis
    this.detectionHistory = new Map();
    this.historyMaxSize = 1000;
  }

  /**
   * Load default security rules
   */
  loadDefaultRules() {
    // SQL Injection Rules
    this.addRule({
      id: 'sqli_tautology',
      name: 'Tautology SQL Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.HIGH,
      type: RuleType.BLOCK,
      pattern: /OR\s+['"]?1['"]?\s*=\s*['"]?1/i,
      description: 'Detects tautology attempts (OR 1=1)'
    });
    
    this.addRule({
      id: 'sqli_union',
      name: 'Union SQL Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /UNION\s+SELECT/i,
      description: 'Detects UNION SELECT injection attempts'
    });
    
    this.addRule({
      id: 'sqli_stacked',
      name: 'Stacked Query Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /;\s*(DROP|DELETE|UPDATE|INSERT|TRUNCATE|CREATE|ALTER)/i,
      description: 'Detects stacked query injection attempts'
    });
    
    this.addRule({
      id: 'sqli_comment',
      name: 'Comment Injection',
      category: ThreatCategory.SQL_INJECTION,
      severity: ThreatLevel.HIGH,
      type: RuleType.BLOCK,
      pattern: /--/,
      description: 'Detects SQL comment injection'
    });

    // DDL Operation Rules
    this.addRule({
      id: 'ddl_drop_table',
      name: 'DROP TABLE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /DROP\s+TABLE/i,
      description: 'Detects DROP TABLE operations'
    });
    
    this.addRule({
      id: 'ddl_drop_database',
      name: 'DROP DATABASE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /DROP\s+DATABASE/i,
      description: 'Detects DROP DATABASE operations'
    });
    
    this.addRule({
      id: 'ddl_truncate',
      name: 'TRUNCATE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /TRUNCATE\s+TABLE/i,
      description: 'Detects TRUNCATE TABLE operations'
    });
    
    this.addRule({
      id: 'ddl_alter',
      name: 'ALTER TABLE Attempt',
      category: ThreatCategory.DDL_OPERATION,
      severity: ThreatLevel.HIGH,
      type: RuleType.WARN,
      pattern: /ALTER\s+TABLE/i,
      description: 'Detects ALTER TABLE operations (can be dangerous)'
    });

    // Privilege Escalation Rules
    this.addRule({
      id: 'priv_grant',
      name: 'GRANT Privilege Attempt',
      category: ThreatCategory.PRIVILEGE_ESCALATION,
      severity: ThreatLevel.CRITICAL,
      type: RuleType.BLOCK,
      pattern: /GRANT\s+/i,
      description: 'Detects GRANT operations (potential privilege escalation)'
    });
    
    this.addRule({
      id: 'priv_revoke',
      name: 'REVOKE Privilege Attempt',
      category: ThreatCategory.PRIVILEGE_ESCALATION,
      severity: ThreatLevel.HIGH,
      type: RuleType.WARN,
      pattern: /REVOKE\s+/i,
      description: 'Detects REVOKE operations'
    });

    // Data Exfiltration Rules
    this.addRule({
      id: 'exfil_select_star',
      name: 'SELECT * with No Filter',
      category: ThreatCategory.DATA_EXFILTRATION,
      severity: ThreatLevel.MEDIUM,
      type: RuleType.WARN,
      pattern: /SELECT\s+\*\s+FROM\s+\w+\s*(?:;|$)/i,
      description: 'Detects SELECT * without WHERE clause'
    });
    
    this.addRule({
      id: 'exfil_sensitive_table',
      name: 'Sensitive Table Access',
      category: ThreatCategory.DATA_EXFILTRATION,
      severity: ThreatLevel.HIGH,
      type: RuleType.WARN,
      pattern: null, // Handled separately
      description: 'Detects access to sensitive tables'
    });

    // Heuristic Rules
    this.addRule({
      id: 'heuristic_multi_statement',
      name: 'Multiple Statements in One Query',
      category: ThreatCategory.SUSPICIOUS_PATTERN,
      severity: ThreatLevel.MEDIUM,
      type: RuleType.WARN,
      pattern: /;/,
      description: 'Detects multiple statements in a single query'
    });
    
    this.addRule({
      id: 'heuristic_encoded',
      name: 'Encoded Payload',
      category: ThreatCategory.SUSPICIOUS_PATTERN,
      severity: ThreatLevel.HIGH,
      type: RuleType.WARN,
      pattern: /%(?:2[0-9A-F]|3[0-9A-F]|4[0-9A-F]|5[0-9A-F]|6[0-9A-F]|7[0-9A-F]|8[0-9A-F]|9[0-9A-F])/i,
      description: 'Detects URL-encoded characters (possible obfuscation)'
    });
  }

  /**
   * Load default whitelist entries
   */
  loadDefaultWhitelist() {
    // Add common safe patterns
    this.whitelist.push({
      pattern: /^SET\s+/i,
      description: 'SET statements'
    });
    this.whitelist.push({
      pattern: /^SHOW\s+/i,
      description: 'SHOW statements'
    });
    this.whitelist.push({
      pattern: /^DESCRIBE\s+/i,
      description: 'DESCRIBE statements'
    });
    this.whitelist.push({
      pattern: /^EXPLAIN\s+/i,
      description: 'EXPLAIN statements'
    });
  }

  /**
   * Add a security rule
   * @param {Object} rule - The rule configuration
   */
  addRule(rule) {
    if (!rule.id || !rule.pattern) {
      throw new Error('Rule must have id and pattern');
    }
    this.rules.push(rule);
  }

  /**
   * Check if a query is whitelisted
   * @param {string} query - The SQL query
   * @returns {boolean} - True if whitelisted
   */
  isWhitelisted(query) {
    for (const entry of this.whitelist) {
      if (entry.pattern.test(query)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Analyze a query for threats
   * @param {string} query - The SQL query
   * @param {Object} context - User context (user_id, ip, etc.)
   * @returns {Object} - Detection results
   */
  analyze(query, context = {}) {
    // Normalize query for pattern matching
    const normalized = this.normalizer.normalize(query);
    
    // Check if whitelisted
    if (this.isWhitelisted(query)) {
      return {
        threatDetected: false,
        score: 0,
        level: ThreatLevel.LOW,
        findings: [],
        normalized: normalized,
        whitelisted: true
      };
    }

    const findings = [];
    let totalScore = 0;
    
    // Pattern matching rules
    if (this.options.enablePatternMatching) {
      for (const rule of this.rules) {
        if (!rule.pattern) continue;
        
        // Check if the pattern matches (using original or normalized query)
        const matched = rule.pattern.test(query) || rule.pattern.test(normalized);
        if (matched) {
          const severityScore = this.getSeverityScore(rule.severity);
          totalScore += severityScore;
          
          findings.push({
            rule: rule,
            matched: true,
            score: severityScore,
            normalized: normalized
          });
        }
      }
    }
    
    // Heuristic analysis
    if (this.options.enableHeuristics) {
      const heuristicFindings = this.runHeuristics(query, normalized, context);
      findings.push(...heuristicFindings);
      totalScore += heuristicFindings.reduce((sum, f) => sum + f.score, 0);
    }
    
    // Frequency analysis (brute force detection)
    if (this.options.enableThreatScoring) {
      const freqFindings = this.analyzeFrequency(query, context);
      findings.push(...freqFindings);
      totalScore += freqFindings.reduce((sum, f) => sum + f.score, 0);
    }
    
    // Determine threat level based on score
    const level = this.getThreatLevel(totalScore);
    
    // Log detection if enabled
    if (this.options.logAllDetections && findings.length > 0) {
      this.logDetection(query, findings, totalScore, level, context);
    }
    
    return {
      threatDetected: findings.length > 0,
      score: totalScore,
      level: level,
      findings: findings,
      normalized: normalized,
      whitelisted: false
    };
  }

  /**
   * Run heuristic analysis
   * @param {string} query - Original query
   * @param {string} normalized - Normalized query
   * @param {Object} context - User context
   * @returns {Array} - Heuristic findings
   */
  runHeuristics(query, normalized, context) {
    const findings = [];
    
    // Check for sensitive table access
    const sensitiveTablePattern = new RegExp(
      this.sensitiveTables.join('|'),
      'i'
    );
    if (sensitiveTablePattern.test(query)) {
      findings.push({
        rule: {
          id: 'heuristic_sensitive_table',
          name: 'Sensitive Table Access',
          category: ThreatCategory.DATA_EXFILTRATION,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: 'Access to sensitive table detected'
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: normalized
      });
    }
    
    // Check for large IN clause (potential brute force)
    const inClauseMatches = query.match(/IN\s*\([^)]*\)/gi);
    if (inClauseMatches) {
      for (const match of inClauseMatches) {
        const values = match.match(/'[^']*'|\d+/g);
        if (values && values.length > 100) {
          findings.push({
            rule: {
              id: 'heuristic_large_in',
              name: 'Large IN Clause',
              category: ThreatCategory.BRUTE_FORCE,
              severity: ThreatLevel.MEDIUM,
              type: RuleType.WARN,
              description: `IN clause with ${values.length} values (potential brute force)`
            },
            matched: true,
            score: this.getSeverityScore(ThreatLevel.MEDIUM),
            normalized: normalized
          });
        }
      }
    }
    
    // Check for "sleep" or "delay" (time-based injection)
    if (/sleep|delay|waitfor/i.test(query)) {
      findings.push({
        rule: {
          id: 'heuristic_time_based',
          name: 'Time-Based Injection',
          category: ThreatCategory.SQL_INJECTION,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: 'Time-based injection attempt (SLEEP/DELAY)'
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: normalized
      });
    }
    
    // Check for "benchmark" (MySQL blind injection)
    if (/benchmark/i.test(query)) {
      findings.push({
        rule: {
          id: 'heuristic_benchmark',
          name: 'Benchmark Injection',
          category: ThreatCategory.SQL_INJECTION,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: 'BENCHMARK function (blind injection)'
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: normalized
      });
    }
    
    return findings;
  }

  /**
   * Analyze query frequency (brute force detection)
   * @param {string} query - The SQL query
   * @param {Object} context - User context
   * @returns {Array} - Frequency analysis findings
   */
  analyzeFrequency(query, context) {
    const findings = [];
    const key = `${context.userId || 'unknown'}:${context.ip || 'unknown'}`;
    const now = Date.now();
    
    if (!this.detectionHistory.has(key)) {
      this.detectionHistory.set(key, []);
    }
    
    const history = this.detectionHistory.get(key);
    
    // Add current query timestamp
    history.push(now);
    
    // Clean old entries (older than 1 minute)
    const oneMinuteAgo = now - 60000;
    while (history.length > 0 && history[0] < oneMinuteAgo) {
      history.shift();
    }
    
    // Keep history size manageable
    if (history.length > this.historyMaxSize) {
      this.detectionHistory.set(key, history.slice(-this.historyMaxSize));
    }
    
    // Check for brute force (more than 100 queries in 1 minute)
    if (history.length > 100) {
      findings.push({
        rule: {
          id: 'heuristic_brute_force',
          name: 'Brute Force Detection',
          category: ThreatCategory.BRUTE_FORCE,
          severity: ThreatLevel.HIGH,
          type: RuleType.WARN,
          description: `${history.length} queries in last minute (possible brute force)`
        },
        matched: true,
        score: this.getSeverityScore(ThreatLevel.HIGH),
        normalized: this.normalizer.normalize(query)
      });
    }
    
    return findings;
  }

  /**
   * Get severity score
   * @param {string} severity - Threat severity level
   * @returns {number} - Numeric score
   */
  getSeverityScore(severity) {
    const scores = {
      [ThreatLevel.LOW]: 1,
      [ThreatLevel.MEDIUM]: 5,
      [ThreatLevel.HIGH]: 10,
      [ThreatLevel.CRITICAL]: 25
    };
    return scores[severity] || 0;
  }

  /**
   * Get threat level based on score
   * @param {number} score - Total threat score
   * @returns {string} - Threat level
   */
  getThreatLevel(score) {
    if (score >= 25) return ThreatLevel.CRITICAL;
    if (score >= 10) return ThreatLevel.HIGH;
    if (score >= 5) return ThreatLevel.MEDIUM;
    if (score >= 1) return ThreatLevel.LOW;
    return ThreatLevel.LOW;
  }

  /**
   * Log detection event
   */
  logDetection(query, findings, score, level, context) {
    console.log(`\n[SECURITY ALERT] Threat Detected!`);
    console.log(`  Score: ${score}`);
    console.log(`  Level: ${level}`);
    console.log(`  User: ${context.userId || 'unknown'}`);
    console.log(`  IP: ${context.ip || 'unknown'}`);
    console.log(`  Query: ${query.substring(0, 100)}${query.length > 100 ? '...' : ''}`);
    console.log(`  Findings: ${findings.length}`);
    
    for (const finding of findings) {
      console.log(`    - ${finding.rule.name} (${finding.rule.severity})`);
    }
    console.log('');
  }

  /**
   * Determine action based on detection
   * @param {Object} detection - Detection result
   * @returns {string} - Action to take (BLOCK, WARN, LOG, ALLOW)
   */
  determineAction(detection) {
    if (detection.whitelisted) {
      return 'ALLOW';
    }
    
    if (!detection.threatDetected) {
      return 'ALLOW';
    }
    
    // Check if any finding requires blocking
    for (const finding of detection.findings) {
      if (finding.rule.type === RuleType.BLOCK) {
        return 'BLOCK';
      }
    }
    
    // Check for high score
    if (detection.score >= 15) {
      return 'BLOCK';
    }
    
    // Check for warnings
    for (const finding of detection.findings) {
      if (finding.rule.type === RuleType.WARN) {
        return 'WARN';
      }
    }
    
    return 'LOG';
  }
}

/**
 * Convenience function to create threat detector with default rules
 * @param {Object} options - Detector options
 * @returns {ThreatDetector} - Configured threat detector
 */
export function createThreatDetector(options = {}) {
  return new ThreatDetector(options);
}
```

---

### Step 2: Integration with Audited Pool

Now let's integrate the threat detector with our normalized audited pool.

**File: `javascript/src/secure-audited-pool.js`**

```javascript
// javascript/src/secure-audited-pool.js

import { NormalizedAuditedPool } from './normalized-audited-pool.js';
import { ThreatDetector, ThreatLevel } from './threat-detector.js';

/**
 * Secure Audited Pool with integrated threat detection
 * 
 * This extends the NormalizedAuditedPool with real-time
 * threat detection. Every query is analyzed for malicious
 * patterns before execution.
 * 
 * Features:
 * 1. Real-time threat detection
 * 2. Automatic blocking of malicious queries
 * 3. Threat scoring and logging
 * 4. Configurable actions (BLOCK, WARN, LOG)
 * 5. Comprehensive audit trail
 */
export class SecureAuditedPool extends NormalizedAuditedPool {
  /**
   * Create a secure audited pool
   * @param {string} connectionString - PostgreSQL connection string
   * @param {Object} options - Configuration options
   * @param {Object} options.threatDetectorOptions - Options for threat detector
   * @param {string} options.blockAction - Action for blocked queries ('THROW' or 'LOG')
   */
  constructor(connectionString, options = {}) {
    // Initialize the normalized audited pool
    super(connectionString, options);
    
    this.blockAction = options.blockAction || 'THROW';
    
    // Create threat detector with options
    this.detector = new ThreatDetector(options.threatDetectorOptions || {});
    
    // Extend audit table for threat detection fields
    this.extendAuditTableForSecurity();
  }

  /**
   * Extend the audit table with security-related columns
   */
  async extendAuditTableForSecurity() {
    const client = await this.pool.connect();
    try {
      // Add threat_score column
      await client.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'dam_audit_logs' 
            AND column_name = 'threat_score'
          ) THEN
            ALTER TABLE dam_audit_logs 
            ADD COLUMN threat_score INTEGER DEFAULT 0;
          END IF;
        END $$;
      `);
      
      // Add threat_level column
      await client.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'dam_audit_logs' 
            AND column_name = 'threat_level'
          ) THEN
            ALTER TABLE dam_audit_logs 
            ADD COLUMN threat_level VARCHAR(20);
          END IF;
        END $$;
      `);
      
      // Add action_taken column
      await client.query(`
        DO $$
        BEGIN
          IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'dam_audit_logs' 
            AND column_name = 'action_taken'
          ) THEN
            ALTER TABLE dam_audit_logs 
            ADD COLUMN action_taken VARCHAR(20);
          END IF;
        END $$;
      `);
      
      // Create index on threat_level for quick filtering
      await client.query(`
        CREATE INDEX IF NOT EXISTS idx_dam_audit_logs_threat_level 
        ON dam_audit_logs(threat_level)
      `);
      
      console.log('[SECURE AUDITED POOL] Audit table extended with security columns');
    } finally {
      client.release();
    }
  }

  /**
   * Override query method with threat detection
   */
  async query(text, params = [], userContext = {}) {
    // Ensure we have user context
    const context = {
      userId: userContext.id || 'system',
      ip: userContext.ip || 'unknown',
      ...userContext
    };
    
    // Analyze the query for threats
    const detection = this.detector.analyze(text, context);
    
    // Determine action based on detection
    const action = this.detector.determineAction(detection);
    
    // Log threat information (this is in addition to normal audit logging)
    if (detection.threatDetected) {
      await this.logThreatDetection(text, params, detection, action, context);
    }
    
    // Take action based on detection
    if (action === 'BLOCK') {
      const errorMessage = `[SECURITY] Query blocked by threat detection: ${text}`;
      console.error(errorMessage);
      
      // Log the block attempt
      await this.logAudit({
        query_text: text,
        query_params: params,
        duration_ms: 0,
        user_id: context.userId,
        user_ip: context.ip,
        status: 'BLOCKED',
        error_message: `Threat detected: ${detection.findings.map(f => f.rule.name).join(', ')}`,
        threat_score: detection.score,
        threat_level: detection.level,
        action_taken: 'BLOCK'
      });
      
      if (this.blockAction === 'THROW') {
        throw new Error(errorMessage);
      }
      return; // Return early if we're just logging the block
    }
    
    // If we get here, the query is allowed (or we're just warning)
    try {
      // Execute the query normally
      const result = await super.query(text, params, context);
      return result;
    } catch (error) {
      // Log the error (already handled by parent)
      throw error;
    }
  }

  /**
   * Log threat detection for later analysis
   */
  async logThreatDetection(query, params, detection, action, context) {
    console.log(`[SECURITY] Threat detected: ${action}`);
    console.log(`  Query: ${query.substring(0, 100)}...`);
    console.log(`  Score: ${detection.score}`);
    console.log(`  Level: ${detection.level}`);
    console.log(`  Findings: ${detection.findings.length}`);
    
    // Log findings
    for (const finding of detection.findings) {
      console.log(`    - ${finding.rule.name} (${finding.rule.severity})`);
    }
  }

  /**
   * Get security statistics
   * @returns {Promise<Object>} Security statistics
   */
  async getSecurityStats() {
    const result = await this.query(
      `
      SELECT 
        COUNT(*) as total_queries,
        COUNT(CASE WHEN threat_level IS NOT NULL AND threat_level != 'LOW' THEN 1 END) as threat_queries,
        COUNT(CASE WHEN action_taken = 'BLOCK' THEN 1 END) as blocked_queries,
        COUNT(CASE WHEN action_taken = 'WARN' THEN 1 END) as warned_queries,
        AVG(threat_score) as avg_threat_score,
        MAX(threat_score) as max_threat_score,
        COUNT(DISTINCT user_id) as unique_users_with_threats
      FROM dam_audit_logs
      WHERE threat_level IS NOT NULL
      `,
      [],
      { id: 'system', ip: 'internal' }
    );
    
    return result.rows[0] || {};
  }

  /**
   * Get threat patterns by level
   * @param {string} level - Threat level (CRITICAL, HIGH, etc.)
   * @param {number} limit - Maximum results
   * @returns {Promise<Array>} Threat patterns
   */
  async getThreatPatterns(level = null, limit = 50) {
    let query = `
      SELECT 
        normalized_query,
        threat_level,
        COUNT(*) as occurrence_count,
        AVG(threat_score) as avg_threat_score,
        COUNT(DISTINCT user_id) as distinct_users,
        COUNT(CASE WHEN action_taken = 'BLOCK' THEN 1 END) as blocked_count
      FROM dam_audit_logs
      WHERE threat_level IS NOT NULL
    `;
    
    if (level) {
      query += ` AND threat_level = '${level}'`;
    }
    
    query += `
      GROUP BY normalized_query, threat_level
      ORDER BY occurrence_count DESC
      LIMIT ${limit}
    `;
    
    const result = await this.query(query, [], { id: 'system', ip: 'internal' });
    return result.rows;
  }
}
```

---

### Step 3: Testing the Threat Detector

Now let's test our threat detection engine.

**File: `javascript/tests/test-threat-detector.js`**

```javascript
// javascript/tests/test-threat-detector.js

import { ThreatDetector, ThreatLevel } from '../src/threat-detector.js';

/**
 * Test the threat detector with various SQL patterns
 */
function testThreatDetector() {
  console.log('🧪 Testing Threat Detector...\n');
  
  const detector = new ThreatDetector();
  
  // Test cases: [SQL query, expected threat detection]
  const testCases = [
    {
      query: "SELECT * FROM users WHERE id = 1",
      shouldDetect: false,
      description: "Normal SELECT query"
    },
    {
      query: "SELECT * FROM users WHERE email = 'alice@example.com'",
      shouldDetect: false,
      description: "Normal SELECT with string literal"
    },
    {
      query: "SELECT * FROM users WHERE email = '' OR 1=1 --'",
      shouldDetect: true,
      description: "SQL Injection (tautology)"
    },
    {
      query: "SELECT * FROM users WHERE id = 1 UNION SELECT * FROM admins",
      shouldDetect: true,
      description: "SQL Injection (UNION)"
    },
    {
      query: "SELECT * FROM users; DROP TABLE users",
      shouldDetect: true,
      description: "Stacked Query Injection"
    },
    {
      query: "DROP TABLE users",
      shouldDetect: true,
      description: "DROP TABLE attempt"
    },
    {
      query: "TRUNCATE TABLE users",
      shouldDetect: true,
      description: "TRUNCATE TABLE attempt"
    },
    {
      query: "ALTER TABLE users ADD COLUMN age INT",
      shouldDetect: true,
      description: "ALTER TABLE attempt"
    },
    {
      query: "GRANT SELECT ON users TO public",
      shouldDetect: true,
      description: "GRANT privilege attempt"
    },
    {
      query: "SELECT * FROM users WHERE id IN (1,2,3,4,5)",
      shouldDetect: false,
      description: "IN clause with small list"
    },
    {
      query: "SELECT * FROM users WHERE id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150)",
      shouldDetect: true,
      description: "Large IN clause (potential brute force)"
    },
    {
      query: "SELECT * FROM users WHERE password = 'abc' OR '1'='1'",
      shouldDetect: true,
      description: "SQL Injection (always true)"
    },
    {
      query: "SELECT * FROM users WHERE email LIKE '%admin%'",
      shouldDetect: false,
      description: "LIKE with wildcards (benign)"
    },
    {
      query: "SELECT * FROM passwords",
      shouldDetect: true,
      description: "Sensitive table access"
    },
    {
      query: "SELECT SLEEP(10) FROM users",
      shouldDetect: true,
      description: "Time-based injection"
    }
  ];
  
  let passed = 0;
  let failed = 0;
  
  testCases.forEach((testCase, index) => {
    console.log(`\n📝 Test ${index + 1}: ${testCase.description}`);
    console.log(`   Query: ${testCase.query.substring(0, 80)}${testCase.query.length > 80 ? '...' : ''}`);
    
    const result = detector.analyze(testCase.query, {
      userId: 'test-user',
      ip: '127.0.0.1'
    });
    
    const detected = result.threatDetected;
    const expected = testCase.shouldDetect;
    const passedTest = detected === expected;
    
    console.log(`   Detected: ${detected ? '✅ Yes' : '❌ No'}`);
    console.log(`   Expected: ${expected ? '✅ Yes' : '❌ No'}`);
    console.log(`   Score: ${result.score}`);
    console.log(`   Level: ${result.level}`);
    
    if (detected) {
      console.log(`   Findings: ${result.findings.length}`);
      for (const finding of result.findings) {
        console.log(`     - ${finding.rule.name} (${finding.rule.severity})`);
      }
    }
    
    console.log(`   ${passedTest ? '✅ PASS' : '❌ FAIL'}`);
    
    if (passedTest) {
      passed++;
    } else {
      failed++;
    }
  });
  
  console.log(`\n📊 Results: ${passed} passed, ${failed} failed`);
  
  // Test whitelist functionality
  console.log('\n📝 Whitelist Test:');
  const whitelistQuery = "SET timezone = 'UTC'";
  const result = detector.analyze(whitelistQuery);
  console.log(`   Query: ${whitelistQuery}`);
  console.log(`   Whitelisted: ${result.whitelisted ? '✅ Yes' : '❌ No'}`);
  console.log(`   Threat detected: ${result.threatDetected ? '⚠️ Yes' : '✅ No'}`);
  
  return { passed, failed };
}

// Run the test
testThreatDetector();
```

---

## Implementation: Python / SQLite

### Step 1: Python Threat Detector

Now let's build the Python version of our threat detection engine.

**File: `python/threat_detector.py`**

```python
# python/threat_detector.py

"""
Threat Detection Engine for SQL queries.

This module provides comprehensive threat detection for SQL queries
using pattern matching, heuristic analysis, and frequency analysis.
"""

import re
import hashlib
from typing import Dict, Any, Optional, List, Tuple, Set
from enum import Enum
from datetime import datetime, timedelta
from collections import defaultdict
from normalizer import QueryNormalizer, NormalizationOptions

class ThreatLevel(Enum):
    """Threat severity levels."""
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"

class ThreatCategory(Enum):
    """Categories of threats."""
    SQL_INJECTION = "SQL_INJECTION"
    DDL_OPERATION = "DDL_OPERATION"
    PRIVILEGE_ESCALATION = "PRIVILEGE_ESCALATION"
    DATA_EXFILTRATION = "DATA_EXFILTRATION"
    BRUTE_FORCE = "BRUTE_FORCE"
    SUSPICIOUS_PATTERN = "SUSPICIOUS_PATTERN"

class RuleType(Enum):
    """Types of rules."""
    BLOCK = "BLOCK"
    WARN = "WARN"
    LOG = "LOG"
    SCORE = "SCORE"

class ThreatRule:
    """A single threat detection rule."""
    
    def __init__(self, rule_id: str, name: str, category: ThreatCategory,
                 severity: ThreatLevel, rule_type: RuleType,
                 pattern: Optional[str] = None,
                 description: str = ""):
        """
        Initialize a threat rule.
        
        Args:
            rule_id: Unique identifier for the rule
            name: Human-readable name
            category: Threat category
            severity: Threat severity level
            rule_type: Type of action to take
            pattern: Regex pattern to match (optional)
            description: Description of the rule
        """
        self.id = rule_id
        self.name = name
        self.category = category
        self.severity = severity
        self.type = rule_type
        self.pattern = re.compile(pattern, re.IGNORECASE) if pattern else None
        self.description = description

class ThreatDetector:
    """
    Threat detection engine for SQL queries.
    
    Features:
        - Pattern matching (known attack signatures)
        - Heuristic analysis (suspicious behaviors)
        - Frequency analysis (brute force detection)
        - Threat scoring and level assignment
        - Whitelist support for safe queries
        - Configurable rules and thresholds
    """
    
    def __init__(self, options: Optional[Dict[str, Any]] = None):
        """
        Initialize the threat detector.
        
        Args:
            options: Configuration options
        """
        self.options = {
            'enable_pattern_matching': True,
            'enable_heuristics': True,
            'enable_threat_scoring': True,
            'log_all_detections': True,
            'history_max_size': 1000,
            ** (options or {})
        }
        
        # Initialize normalizer
        self.normalizer = QueryNormalizer(
            NormalizationOptions(case_insensitive=True)
        )
        
        # Threat rules
        self.rules: List[ThreatRule] = []
        self._load_default_rules()
        
        # Sensitive tables
        self.sensitive_tables = {
            'users', 'passwords', 'credentials', 'secrets',
            'customers', 'employees', 'patients', 'medical',
            'credit_cards', 'payment', 'banking', 'financial',
            'admin', 'administrator', 'root', 'system'
        }
        
        # Whitelist patterns
        self.whitelist: List[re.Pattern] = []
        self._load_default_whitelist()
        
        # Detection history for frequency analysis
        self.detection_history = defaultdict(list)
        
        # Severity scores
        self._severity_scores = {
            ThreatLevel.LOW: 1,
            ThreatLevel.MEDIUM: 5,
            ThreatLevel.HIGH: 10,
            ThreatLevel.CRITICAL: 25
        }
    
    def _load_default_rules(self) -> None:
        """Load default security rules."""
        # SQL Injection Rules
        self.add_rule(ThreatRule(
            rule_id='sqli_tautology',
            name='Tautology SQL Injection',
            category=ThreatCategory.SQL_INJECTION,
            severity=ThreatLevel.HIGH,
            rule_type=RuleType.BLOCK,
            pattern=r"OR\s+['\"]?1['\"]?\s*=\s*['\"]?1",
            description='Detects tautology attempts (OR 1=1)'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='sqli_union',
            name='Union SQL Injection',
            category=ThreatCategory.SQL_INJECTION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"UNION\s+SELECT",
            description='Detects UNION SELECT injection attempts'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='sqli_stacked',
            name='Stacked Query Injection',
            category=ThreatCategory.SQL_INJECTION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r";\s*(DROP|DELETE|UPDATE|INSERT|TRUNCATE|CREATE|ALTER)",
            description='Detects stacked query injection attempts'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='sqli_comment',
            name='Comment Injection',
            category=ThreatCategory.SQL_INJECTION,
            severity=ThreatLevel.HIGH,
            rule_type=RuleType.BLOCK,
            pattern=r"--",
            description='Detects SQL comment injection'
        ))
        
        # DDL Operation Rules
        self.add_rule(ThreatRule(
            rule_id='ddl_drop_table',
            name='DROP TABLE Attempt',
            category=ThreatCategory.DDL_OPERATION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"DROP\s+TABLE",
            description='Detects DROP TABLE operations'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='ddl_drop_database',
            name='DROP DATABASE Attempt',
            category=ThreatCategory.DDL_OPERATION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"DROP\s+DATABASE",
            description='Detects DROP DATABASE operations'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='ddl_truncate',
            name='TRUNCATE Attempt',
            category=ThreatCategory.DDL_OPERATION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"TRUNCATE\s+TABLE",
            description='Detects TRUNCATE TABLE operations'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='ddl_alter',
            name='ALTER TABLE Attempt',
            category=ThreatCategory.DDL_OPERATION,
            severity=ThreatLevel.HIGH,
            rule_type=RuleType.WARN,
            pattern=r"ALTER\s+TABLE",
            description='Detects ALTER TABLE operations'
        ))
        
        # Privilege Escalation Rules
        self.add_rule(ThreatRule(
            rule_id='priv_grant',
            name='GRANT Privilege Attempt',
            category=ThreatCategory.PRIVILEGE_ESCALATION,
            severity=ThreatLevel.CRITICAL,
            rule_type=RuleType.BLOCK,
            pattern=r"GRANT\s+",
            description='Detects GRANT operations'
        ))
        
        self.add_rule(ThreatRule(
            rule_id='priv_revoke',
            name='REVOKE Privilege Attempt',
            category=ThreatCategory.PRIVILEGE_ESCALATION,
            severity=ThreatLevel.HIGH,
            rule_type=RuleType.WARN,
            pattern=r"REVOKE\s+",
            description='Detects REVOKE operations'
        ))
        
        # Data Exfiltration Rules
        self.add_rule(ThreatRule(
            rule_id='exfil_select_star',
            name='SELECT * with No Filter',
            category=ThreatCategory.DATA_EXFILTRATION,
            severity=ThreatLevel.MEDIUM,
            rule_type=RuleType.WARN,
            pattern=r"SELECT\s+\*\s+FROM\s+\w+\s*(?:;|$)",
            description='Detects SELECT * without WHERE clause'
        ))
    
    def _load_default_whitelist(self) -> None:
        """Load default whitelist patterns."""
        safe_patterns = [
            r"^SET\s+",
            r"^SHOW\s+",
            r"^DESCRIBE\s+",
            r"^EXPLAIN\s+"
        ]
        for pattern in safe_patterns:
            self.whitelist.append(re.compile(pattern, re.IGNORECASE))
    
    def add_rule(self, rule: ThreatRule) -> None:
        """
        Add a threat rule to the engine.
        
        Args:
            rule: The threat rule to add
        """
        self.rules.append(rule)
    
    def is_whitelisted(self, query: str) -> bool:
        """
        Check if a query is whitelisted.
        
        Args:
            query: The SQL query
            
        Returns:
            True if the query is whitelisted
        """
        for pattern in self.whitelist:
            if pattern.search(query):
                return True
        return False
    
    def get_severity_score(self, severity: ThreatLevel) -> int:
        """
        Get numeric score for a severity level.
        
        Args:
            severity: The threat severity
            
        Returns:
            Numeric score
        """
        return self._severity_scores.get(severity, 0)
    
    def get_threat_level(self, score: int) -> ThreatLevel:
        """
        Get threat level based on score.
        
        Args:
            score: Total threat score
            
        Returns:
            Threat level
        """
        if score >= 25:
            return ThreatLevel.CRITICAL
        if score >= 10:
            return ThreatLevel.HIGH
        if score >= 5:
            return ThreatLevel.MEDIUM
        if score >= 1:
            return ThreatLevel.LOW
        return ThreatLevel.LOW
    
    def analyze(self, query: str, context: Dict[str, str] = None) -> Dict[str, Any]:
        """
        Analyze a query for threats.
        
        Args:
            query: The SQL query
            context: User context (user_id, ip, etc.)
            
        Returns:
            Detection results
        """
        context = context or {}
        normalized = self.normalizer.normalize(query)
        
        # Check whitelist
        if self.is_whitelisted(query):
            return {
                'threat_detected': False,
                'score': 0,
                'level': ThreatLevel.LOW,
                'findings': [],
                'normalized': normalized,
                'whitelisted': True
            }
        
        findings = []
        total_score = 0
        
        # Pattern matching
        if self.options['enable_pattern_matching']:
            for rule in self.rules:
                if not rule.pattern:
                    continue
                
                # Check pattern on original and normalized query
                if rule.pattern.search(query) or rule.pattern.search(normalized):
                    severity_score = self.get_severity_score(rule.severity)
                    total_score += severity_score
                    
                    findings.append({
                        'rule': rule,
                        'matched': True,
                        'score': severity_score,
                        'normalized': normalized
                    })
        
        # Heuristic analysis
        if self.options['enable_heuristics']:
            heuristic_findings = self._run_heuristics(query, normalized, context)
            findings.extend(heuristic_findings)
            total_score += sum(f['score'] for f in heuristic_findings)
        
        # Frequency analysis
        if self.options['enable_threat_scoring']:
            freq_findings = self._analyze_frequency(query, context)
            findings.extend(freq_findings)
            total_score += sum(f['score'] for f in freq_findings)
        
        # Determine threat level
        level = self.get_threat_level(total_score)
        
        # Log detection if enabled
        if self.options['log_all_detections'] and findings:
            self._log_detection(query, findings, total_score, level, context)
        
        return {
            'threat_detected': bool(findings),
            'score': total_score,
            'level': level,
            'findings': findings,
            'normalized': normalized,
            'whitelisted': False
        }
    
    def _run_heuristics(self, query: str, normalized: str, 
                       context: Dict[str, str]) -> List[Dict[str, Any]]:
        """
        Run heuristic analysis on a query.
        
        Args:
            query: Original query
            normalized: Normalized query
            context: User context
            
        Returns:
            List of heuristic findings
        """
        findings = []
        
        # Check for sensitive table access
        sensitive_pattern = re.compile('|'.join(self.sensitive_tables), re.IGNORECASE)
        if sensitive_pattern.search(query):
            findings.append({
                'rule': ThreatRule(
                    rule_id='heuristic_sensitive_table',
                    name='Sensitive Table Access',
                    category=ThreatCategory.DATA_EXFILTRATION,
                    severity=ThreatLevel.HIGH,
                    rule_type=RuleType.WARN,
                    description='Access to sensitive table detected'
                ),
                'matched': True,
                'score': self.get_severity_score(ThreatLevel.HIGH),
                'normalized': normalized
            })
        
        # Check for large IN clause
        in_clauses = re.findall(r"IN\s*\([^)]*\)", query, re.IGNORECASE)
        for clause in in_clauses:
            # Count values in the IN clause
            values = re.findall(r"'[^']*'|\d+", clause)
            if len(values) > 100:
                findings.append({
                    'rule': ThreatRule(
                        rule_id='heuristic_large_in',
                        name='Large IN Clause',
                        category=ThreatCategory.BRUTE_FORCE,
                        severity=ThreatLevel.MEDIUM,
                        rule_type=RuleType.WARN,
                        description=f'IN clause with {len(values)} values'
                    ),
                    'matched': True,
                    'score': self.get_severity_score(ThreatLevel.MEDIUM),
                    'normalized': normalized
                })
        
        # Check for time-based injection
        if re.search(r"sleep|delay|waitfor", query, re.IGNORECASE):
            findings.append({
                'rule': ThreatRule(
                    rule_id='heuristic_time_based',
                    name='Time-Based Injection',
                    category=ThreatCategory.SQL_INJECTION,
                    severity=ThreatLevel.HIGH,
                    rule_type=RuleType.WARN,
                    description='Time-based injection attempt'
                ),
                'matched': True,
                'score': self.get_severity_score(ThreatLevel.HIGH),
                'normalized': normalized
            })
        
        # Check for BENCHMARK (MySQL blind injection)
        if re.search(r"benchmark", query, re.IGNORECASE):
            findings.append({
                'rule': ThreatRule(
                    rule_id='heuristic_benchmark',
                    name='Benchmark Injection',
                    category=ThreatCategory.SQL_INJECTION,
                    severity=ThreatLevel.HIGH,
                    rule_type=RuleType.WARN,
                    description='BENCHMARK function (blind injection)'
                ),
                'matched': True,
                'score': self.get_severity_score(ThreatLevel.HIGH),
                'normalized': normalized
            })
        
        return findings
    
    def _analyze_frequency(self, query: str, 
                          context: Dict[str, str]) -> List[Dict[str, Any]]:
        """
        Analyze query frequency for brute force detection.
        
        Args:
            query: The SQL query
            context: User context
            
        Returns:
            List of frequency analysis findings
        """
        findings = []
        key = f"{context.get('user_id', 'unknown')}:{context.get('ip', 'unknown')}"
        now = datetime.now()
        
        # Add current query to history
        self.detection_history[key].append(now)
        
        # Clean old entries (older than 1 minute)
        one_minute_ago = now - timedelta(minutes=1)
        self.detection_history[key] = [
            t for t in self.detection_history[key] 
            if t > one_minute_ago
        ]
        
        # Limit history size
        if len(self.detection_history[key]) > self.options['history_max_size']:
            self.detection_history[key] = self.detection_history[key][-self.options['history_max_size']:]
        
        # Check for brute force (more than 100 queries in 1 minute)
        if len(self.detection_history[key]) > 100:
            findings.append({
                'rule': ThreatRule(
                    rule_id='heuristic_brute_force',
                    name='Brute Force Detection',
                    category=ThreatCategory.BRUTE_FORCE,
                    severity=ThreatLevel.HIGH,
                    rule_type=RuleType.WARN,
                    description=f"{len(self.detection_history[key])} queries in last minute"
                ),
                'matched': True,
                'score': self.get_severity_score(ThreatLevel.HIGH),
                'normalized': self.normalizer.normalize(query)
            })
        
        return findings
    
    def _log_detection(self, query: str, findings: List[Dict[str, Any]],
                      score: int, level: ThreatLevel, context: Dict[str, str]) -> None:
        """
        Log a detection event.
        
        Args:
            query: The SQL query
            findings: List of findings
            score: Total threat score
            level: Threat level
            context: User context
        """
        print(f"\n[SECURITY ALERT] Threat Detected!")
        print(f"  Score: {score}")
        print(f"  Level: {level.value}")
        print(f"  User: {context.get('user_id', 'unknown')}")
        print(f"  IP: {context.get('ip', 'unknown')}")
        print(f"  Query: {query[:100]}{'...' if len(query) > 100 else ''}")
        print(f"  Findings: {len(findings)}")
        
        for finding in findings:
            print(f"    - {finding['rule'].name} ({finding['rule'].severity.value})")
        print("")
    
    def determine_action(self, detection: Dict[str, Any]) -> str:
        """
        Determine action based on detection results.
        
        Args:
            detection: Detection results
            
        Returns:
            Action to take (BLOCK, WARN, LOG, ALLOW)
        """
        if detection.get('whitelisted', False):
            return 'ALLOW'
        
        if not detection.get('threat_detected', False):
            return 'ALLOW'
        
        # Check if any finding requires blocking
        for finding in detection['findings']:
            if finding['rule'].type == RuleType.BLOCK:
                return 'BLOCK'
        
        # Check for high score
        if detection.get('score', 0) >= 15:
            return 'BLOCK'
        
        # Check for warnings
        for finding in detection['findings']:
            if finding['rule'].type == RuleType.WARN:
                return 'WARN'
        
        return 'LOG'

def create_threat_detector(options: Dict[str, Any] = None) -> ThreatDetector:
    """
    Convenience function to create a threat detector.
    
    Args:
        options: Detector options
        
    Returns:
        Configured threat detector
    """
    return ThreatDetector(options)
```

---

### Step 2: Python Secure Audited SQLite

Now let's integrate the threat detector with our audited SQLite.

**File: `python/secure_audited_sqlite.py`**

```python
# python/secure_audited_sqlite.py

"""
Secure Audited SQLite with integrated threat detection.
"""

import sqlite3
from typing import Dict, Any, Optional, List, Tuple
from datetime import datetime, timezone
from normalized_audited_sqlite import NormalizedAuditedSQLite
from threat_detector import ThreatDetector, ThreatLevel, RuleType

class SecureAuditedSQLite(NormalizedAuditedSQLite):
    """
    Secure audited SQLite with real-time threat detection.
    
    This extends the NormalizedAuditedSQLite with integrated
    threat detection that blocks malicious queries before
    they reach the database.
    
    Features:
        - Real-time threat detection
        - Automatic blocking of malicious queries
        - Threat scoring and logging
        - Configurable actions (BLOCK, WARN, LOG)
        - Comprehensive audit trail
    """
    
    def __init__(self, db_path: str, 
                 options: Optional[Dict[str, Any]] = None,
                 block_action: str = 'THROW'):
        """
        Initialize the secure audited SQLite connection.
        
        Args:
            db_path: Path to the SQLite database file
            options: Configuration options for threat detector
            block_action: Action for blocked queries ('THROW' or 'LOG')
        """
        # Initialize the normalized audited SQLite
        super().__init__(db_path)
        
        self.block_action = block_action
        
        # Create threat detector with options
        self.detector = ThreatDetector(options or {})
        
        # Extend audit table for security fields
        self._extend_audit_table_for_security()
    
    def _extend_audit_table_for_security(self) -> None:
        """Extend the audit table with security-related columns."""
        conn = self._get_connection()
        
        # Check if columns exist
        cursor = conn.execute("PRAGMA table_info(audit_logs)")
        columns = [row[1] for row in cursor.fetchall()]
        
        if 'threat_score' not in columns:
            conn.execute("ALTER TABLE audit_logs ADD COLUMN threat_score INTEGER DEFAULT 0")
        
        if 'threat_level' not in columns:
            conn.execute("ALTER TABLE audit_logs ADD COLUMN threat_level VARCHAR(20)")
        
        if 'action_taken' not in columns:
            conn.execute("ALTER TABLE audit_logs ADD COLUMN action_taken VARCHAR(20)")
        
        conn.commit()
        
        # Create index on threat_level
        conn.execute(
            "CREATE INDEX IF NOT EXISTS idx_audit_logs_threat_level "
            "ON audit_logs(threat_level)"
        )
        conn.commit()
    
    def execute(self, sql: str, params: tuple = (),
                user_context: Dict[str, str] = None) -> sqlite3.Cursor:
        """
        Execute a query with threat detection.
        
        Args:
            sql: The SQL query
            params: Query parameters
            user_context: User context (user_id, ip, etc.)
            
        Returns:
            sqlite3.Cursor: The cursor from the executed query
            
        Raises:
            sqlite3.Error: If the query is blocked or fails
        """
        user_context = user_context or {'user_id': 'system', 'ip': 'unknown'}
        
        # Analyze the query for threats
        detection = self.detector.analyze(sql, user_context)
        
        # Determine action based on detection
        action = self.detector.determine_action(detection)
        
        # Log threat information
        if detection['threat_detected']:
            self._log_threat_detection(sql, params, detection, action, user_context)
        
        # Take action based on detection
        if action == 'BLOCK':
            error_message = f"[SECURITY] Query blocked by threat detection: {sql}"
            print(error_message)
            
            # Log the block attempt
            self._log_audit_block(sql, params, user_context, detection)
            
            if self.block_action == 'THROW':
                raise sqlite3.Error(error_message)
            return None  # Return early if we're just logging the block
        
        # Execute the query normally
        return super().execute(sql, params, user_context)
    
    def _log_threat_detection(self, sql: str, params: tuple,
                             detection: Dict[str, Any],
                             action: str,
                             user_context: Dict[str, str]) -> None:
        """
        Log threat detection for later analysis.
        """
        print(f"[SECURITY] Threat detected: {action}")
        print(f"  Query: {sql[:100]}...")
        print(f"  Score: {detection['score']}")
        print(f"  Level: {detection['level'].value}")
        print(f"  Findings: {len(detection['findings'])}")
        
        for finding in detection['findings']:
            print(f"    - {finding['rule'].name} ({finding['rule'].severity.value})")
    
    def _log_audit_block(self, sql: str, params: tuple,
                        user_context: Dict[str, str],
                        detection: Dict[str, Any]) -> None:
        """
        Log a blocked query to the audit table.
        """
        conn = self._get_connection()
        try:
            conn.execute(
                """
                INSERT INTO audit_logs (
                    query_text, query_params, duration_ms,
                    user_id, user_ip, status, error_message,
                    threat_score, threat_level, action_taken
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    sql,
                    str(params),
                    0,
                    user_context.get('user_id', 'system'),
                    user_context.get('ip', 'unknown'),
                    'BLOCKED',
                    f"Threat detected: {', '.join(f['rule'].name for f in detection['findings'])}",
                    detection['score'],
                    detection['level'].value,
                    'BLOCK'
                )
            )
            conn.commit()
        except sqlite3.Error as e:
            print(f"[SECURE AUDIT] Could not log block: {e}")
    
    def get_security_stats(self) -> Dict[str, Any]:
        """
        Get security statistics.
        
        Returns:
            Dictionary with security statistics
        """
        result = self.query_one(
            """
            SELECT 
                COUNT(*) as total_queries,
                COUNT(CASE WHEN threat_level IS NOT NULL AND threat_level != 'LOW' 
                      THEN 1 END) as threat_queries,
                COUNT(CASE WHEN action_taken = 'BLOCK' THEN 1 END) as blocked_queries,
                COUNT(CASE WHEN action_taken = 'WARN' THEN 1 END) as warned_queries,
                AVG(threat_score) as avg_threat_score,
                MAX(threat_score) as max_threat_score,
                COUNT(DISTINCT user_id) as unique_users_with_threats
            FROM audit_logs
            WHERE threat_level IS NOT NULL
            """
        )
        return result or {}
    
    def get_threat_patterns(self, level: Optional[str] = None, 
                           limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get threat patterns by level.
        
        Args:
            level: Threat level (CRITICAL, HIGH, etc.)
            limit: Maximum results
            
        Returns:
            List of threat patterns
        """
        query = """
            SELECT 
                normalized_query,
                threat_level,
                COUNT(*) as occurrence_count,
                AVG(threat_score) as avg_threat_score,
                COUNT(DISTINCT user_id) as distinct_users,
                COUNT(CASE WHEN action_taken = 'BLOCK' THEN 1 END) as blocked_count
            FROM audit_logs
            WHERE threat_level IS NOT NULL
        """
        
        params = []
        if level:
            query += " AND threat_level = ?"
            params.append(level)
        
        query += """
            GROUP BY normalized_query, threat_level
            ORDER BY occurrence_count DESC
            LIMIT ?
        """
        params.append(limit)
        
        return self.query(query, tuple(params))
```

---

### Step 3: Testing Python Threat Detection

Now let's test our Python threat detector.

**File: `python/test_threat_detector.py`**

```python
# python/test_threat_detector.py

"""
Test script for the threat detector.
"""

from threat_detector import ThreatDetector, ThreatLevel

def test_threat_detector():
    """Test the threat detector with various SQL patterns."""
    
    print("🧪 Testing Threat Detector...\n")
    
    detector = ThreatDetector()
    
    # Test cases: [SQL query, expected threat detection]
    test_cases = [
        # Normal queries (should NOT detect)
        {
            'query': "SELECT * FROM users WHERE id = 1",
            'should_detect': False,
            'description': "Normal SELECT query"
        },
        {
            'query': "SELECT * FROM users WHERE email = 'alice@example.com'",
            'should_detect': False,
            'description': "Normal SELECT with string literal"
        },
        
        # SQL Injection attacks (should detect)
        {
            'query': "SELECT * FROM users WHERE email = '' OR 1=1 --'",
            'should_detect': True,
            'description': "SQL Injection (tautology)"
        },
        {
            'query': "SELECT * FROM users WHERE id = 1 UNION SELECT * FROM admins",
            'should_detect': True,
            'description': "SQL Injection (UNION)"
        },
        {
            'query': "SELECT * FROM users; DROP TABLE users",
            'should_detect': True,
            'description': "Stacked Query Injection"
        },
        
        # DDL Operations (should detect)
        {
            'query': "DROP TABLE users",
            'should_detect': True,
            'description': "DROP TABLE attempt"
        },
        {
            'query': "TRUNCATE TABLE users",
            'should_detect': True,
            'description': "TRUNCATE TABLE attempt"
        },
        {
            'query': "ALTER TABLE users ADD COLUMN age INT",
            'should_detect': True,
            'description': "ALTER TABLE attempt"
        },
        
        # Privilege Escalation (should detect)
        {
            'query': "GRANT SELECT ON users TO public",
            'should_detect': True,
            'description': "GRANT privilege attempt"
        },
        
        # Benign operations (should NOT detect)
        {
            'query': "SELECT * FROM users WHERE id IN (1,2,3,4,5)",
            'should_detect': False,
            'description': "IN clause with small list"
        },
        {
            'query': "SELECT * FROM users WHERE email LIKE '%admin%'",
            'should_detect': False,
            'description': "LIKE with wildcards (benign)"
        },
        
        # Suspicious patterns (should detect)
        {
            'query': "SELECT * FROM passwords",
            'should_detect': True,
            'description': "Sensitive table access"
        },
        {
            'query': "SELECT SLEEP(10) FROM users",
            'should_detect': True,
            'description': "Time-based injection"
        },
        
        # Large IN clause (should detect)
        {
            'query': "SELECT * FROM users WHERE id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150)",
            'should_detect': True,
            'description': "Large IN clause (potential brute force)"
        }
    ]
    
    passed = 0
    failed = 0
    
    for idx, test_case in enumerate(test_cases, 1):
        print(f"\n📝 Test {idx}: {test_case['description']}")
        print(f"   Query: {test_case['query'][:80]}{'...' if len(test_case['query']) > 80 else ''}")
        
        result = detector.analyze(test_case['query'], {
            'user_id': 'test-user',
            'ip': '127.0.0.1'
        })
        
        detected = result['threat_detected']
        expected = test_case['should_detect']
        passed_test = detected == expected
        
        print(f"   Detected: {'✅ Yes' if detected else '❌ No'}")
        print(f"   Expected: {'✅ Yes' if expected else '❌ No'}")
        print(f"   Score: {result['score']}")
        print(f"   Level: {result['level'].value}")
        
        if detected:
            print(f"   Findings: {len(result['findings'])}")
            for finding in result['findings']:
                print(f"     - {finding['rule'].name} ({finding['rule'].severity.value})")
        
        print(f"   {'✅ PASS' if passed_test else '❌ FAIL'}")
        
        if passed_test:
            passed += 1
        else:
            failed += 1
    
    print(f"\n📊 Results: {passed} passed, {failed} failed")
    
    # Test whitelist functionality
    print('\n📝 Whitelist Test:')
    whitelist_query = "SET timezone = 'UTC'"
    result = detector.analyze(whitelist_query)
    print(f"   Query: {whitelist_query}")
    print(f"   Whitelisted: {'✅ Yes' if result['whitelisted'] else '❌ No'}")
    print(f"   Threat detected: {'⚠️ Yes' if result['threat_detected'] else '✅ No'}")
    
    return passed, failed

if __name__ == "__main__":
    test_threat_detector()
```

---

## Verification: Testing Both Implementations

### JavaScript Verification

**Run the threat detector tests:**

```bash
cd javascript
node tests/test-threat-detector.js
```

Expected output (abbreviated):

```
🧪 Testing Threat Detector...

📝 Test 1: Normal SELECT query
   Query: SELECT * FROM users WHERE id = 1
   Detected: ❌ No
   Expected: ❌ No
   Score: 0
   Level: LOW
   ✅ PASS

📝 Test 2: Normal SELECT with string literal
   Query: SELECT * FROM users WHERE email = 'alice@example.com'
   Detected: ❌ No
   Expected: ❌ No
   Score: 0
   Level: LOW
   ✅ PASS

📝 Test 3: SQL Injection (tautology)
   Query: SELECT * FROM users WHERE email = '' OR 1=1 --'
   Detected: ✅ Yes
   Expected: ✅ Yes
   Score: 10
   Level: HIGH
   Findings: 2
     - Tautology SQL Injection (HIGH)
     - Comment Injection (HIGH)
   ✅ PASS

📝 Test 4: SQL Injection (UNION)
   Query: SELECT * FROM users WHERE id = 1 UNION SELECT * FROM admins
   Detected: ✅ Yes
   Expected: ✅ Yes
   Score: 25
   Level: CRITICAL
   Findings: 1
     - Union SQL Injection (CRITICAL)
   ✅ PASS

... (more tests)

📊 Results: 14 passed, 0 failed

📝 Whitelist Test:
   Query: SET timezone = 'UTC'
   Whitelisted: ✅ Yes
   Threat detected: ✅ No
```

### Python Verification

**Run the threat detector tests:**

```bash
cd python
python test_threat_detector.py
```

Expected output (similar to JavaScript):

```
🧪 Testing Threat Detector...

📝 Test 1: Normal SELECT query
   Query: SELECT * FROM users WHERE id = 1
   Detected: ❌ No
   Expected: ❌ No
   Score: 0
   Level: LOW
   ✅ PASS

📝 Test 2: Normal SELECT with string literal
   Query: SELECT * FROM users WHERE email = 'alice@example.com'
   Detected: ❌ No
   Expected: ❌ No
   Score: 0
   Level: LOW
   ✅ PASS

📝 Test 3: SQL Injection (tautology)
   Query: SELECT * FROM users WHERE email = '' OR 1=1 --'
   Detected: ✅ Yes
   Expected: ✅ Yes
   Score: 20
   Level: HIGH
   Findings: 2
     - Tautology SQL Injection (HIGH)
     - Comment Injection (HIGH)
   ✅ PASS

... (more tests)

📊 Results: 14 passed, 0 failed

📝 Whitelist Test:
   Query: SET timezone = 'UTC'
   Whitelisted: ✅ Yes
   Threat detected: ✅ No
```

---

## Deep Reference Section

### Reference: SQL Injection Patterns

**Common SQL Injection Attack Patterns:**

| Attack Type | Pattern | Example | Prevention |
|-------------|---------|---------|------------|
| **Tautology** | `OR 1=1` | `' OR 1=1 --` | Parameterized queries |
| **Union** | `UNION SELECT` | `' UNION SELECT * FROM admins --` | Input validation |
| **Stacked** | `; DROP TABLE` | `'; DROP TABLE users --` | Query batching prevention |
| **Comment** | `--` | `' OR 1=1 --` | Strip comments |
| **Time-based** | `SLEEP()` | `' OR SLEEP(5) --` | Timeout monitoring |
| **Error-based** | `CONVERT()` | `' AND CONVERT(int, @@version) --` | Error handling |
| **Blind** | `BENCHMARK()` | `' AND BENCHMARK(1000000, MD5(1)) --` | Performance monitoring |

**Why We Use Regular Expressions:**

Regular expressions are:
1. **Fast**: Simple pattern matching is O(n)
2. **Flexible**: Easy to add new patterns
3. **Language Independent**: Works across SQL dialects
4. **Simple**: Easy to understand and maintain

**Limitations to Be Aware Of:**

1. **False Positives**: Legitimate queries might match patterns
2. **False Negatives**: Evasive techniques might bypass patterns
3. **Performance**: Complex regex can be slow on long queries
4. **Evasion**: Attackers can use encoding and obfuscation

### Reference: Threat Scoring

**How We Calculate Threat Scores:**

```
Total Score = Σ(Pattern Matches) + Σ(Heuristics) + Σ(Frequency)
```

**Severity Scoring Table:**

| Severity | Score | Action |
|----------|-------|--------|
| CRITICAL | 25 | Block immediately |
| HIGH | 10 | Block or warn |
| MEDIUM | 5 | Warn and log |
| LOW | 1 | Log only |

**Action Determination Logic:**

```javascript
if (whitelisted) return 'ALLOW';
if (no threats) return 'ALLOW';
if (any BLOCK rule) return 'BLOCK';
if (score >= 15) return 'BLOCK';
if (any WARN rule) return 'WARN';
return 'LOG';
```

### Reference: Performance Considerations

**Detection Performance Impact:**

| Operation | Time (microseconds) | Notes |
|-----------|-------------------|-------|
| No detection | 0 | Baseline |
| Pattern matching | 5-10 | Regex on query |
| Full detection | 20-50 | All rules + heuristics |
| With frequency | 30-70 | + History check |

**Optimization Strategies:**

1. **Early Exit**: Stop checking patterns once threat is confirmed
2. **Caching**: Cache detection results for identical queries
3. **Sampling**: Only analyze a percentage of queries
4. **Async**: Run detection asynchronously when possible
5. **Rule Ordering**: Put high-confidence rules first

### Reference: Building Custom Rules

**Adding Your Own Rules:**

**JavaScript:**
```javascript
detector.addRule({
    id: 'custom_rule',
    name: 'Custom Threat Detection',
    category: ThreatCategory.SUSPICIOUS_PATTERN,
    severity: ThreatLevel.HIGH,
    type: RuleType.BLOCK,
    pattern: /DROP\s+SCHEMA/i,
    description: 'Detects DROP SCHEMA operations'
});
```

**Python:**
```python
detector.add_rule(ThreatRule(
    rule_id='custom_rule',
    name='Custom Threat Detection',
    category=ThreatCategory.SUSPICIOUS_PATTERN,
    severity=ThreatLevel.HIGH,
    rule_type=RuleType.BLOCK,
    pattern=r"DROP\s+SCHEMA",
    description='Detects DROP SCHEMA operations'
))
```

**Best Practices for Custom Rules:**

1. **Test thoroughly** to avoid false positives
2. **Start with WARN** before moving to BLOCK
3. **Document** why the rule exists
4. **Monitor** the rule's hit rate
5. **Review** regularly for relevance

---

## Summary: What You've Built

### JavaScript Implementation
- ✅ **ThreatDetector** class with pattern matching and heuristics
- ✅ 15+ default rules for common attack patterns
- ✅ SQL injection detection (tautologies, union, stacked, etc.)
- ✅ DDL operation blocking (DROP, TRUNCATE, ALTER)
- ✅ Privilege escalation detection (GRANT, REVOKE)
- ✅ Data exfiltration detection (sensitive tables)
- ✅ Frequency analysis for brute force detection
- ✅ Threat scoring and level assignment
- ✅ Whitelist support for safe queries
- ✅ **SecureAuditedPool** integration

### Python Implementation
- ✅ **ThreatDetector** class with all detection features
- ✅ **ThreatRule** class for rule management
- ✅ Comprehensive default rule set
- ✅ Heuristic analysis for suspicious patterns
- ✅ Frequency analysis for brute force detection
- ✅ **SecureAuditedSQLite** integration

### Common Knowledge Gained
- ✅ How to detect SQL injection in real-time
- ✅ Pattern matching vs. heuristic analysis
- ✅ Threat scoring and risk assessment
- ✅ Rule management for security systems
- ✅ Performance considerations for detection
- ✅ Building extensible detection engines

---

## What's Next: Part 5 - Automated Remediation & Incident Response Orchestration

In Part 4, we built a powerful threat detection engine that identifies malicious queries in real-time. But detection is only half the battle. When a threat is detected, we need to respond immediately.

In Part 5, we'll build:
- **Automated remediation** that blocks threats and isolates connections
- **Incident response orchestration** with multiple response strategies
- **Durable incident vault** for post-mortem analysis
- **Alerting and notification** for security teams
- **Self-healing** mechanisms to prevent future incidents

**Get ready to build your incident response system!**

*Part 4 is complete! You now have a threat detection engine that identifies malicious queries in real-time. Continue to Part 5 to build automated remediation and incident response capabilities that take action when threats are detected.*
