# Appendix D: Complete Reference Data Models

## Overview

This appendix provides the complete reference data models for the Enterprise Cybersecurity Program, including entity-relationship diagrams, data schemas, and standard taxonomies used across all components. These models ensure consistency and interoperability across the entire program.

---

## D.1: Core Entity Data Models

### D.1.1: User and Identity Data Model

**File:** `data-models/user-model.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "User and Identity Data Model",
  "description": "Comprehensive user identity data model for the enterprise cybersecurity program",
  "type": "object",
  "properties": {
    "user_id": {
      "type": "string",
      "description": "Unique user identifier",
      "pattern": "^[a-zA-Z0-9\\-]{8,36}$"
    },
    "username": {
      "type": "string",
      "description": "Login username",
      "minLength": 3,
      "maxLength": 64,
      "pattern": "^[a-zA-Z0-9._-]+$"
    },
    "email": {
      "type": "string",
      "description": "Email address",
      "format": "email"
    },
    "full_name": {
      "type": "string",
      "description": "Full legal name",
      "minLength": 2,
      "maxLength": 100
    },
    "department": {
      "type": "string",
      "description": "Department or business unit",
      "enum": [
        "Executive",
        "Finance",
        "Human Resources",
        "Information Technology",
        "Security",
        "Legal",
        "Operations",
        "Sales",
        "Marketing",
        "Engineering",
        "Product",
        "Customer Support",
        "Research & Development",
        "Facilities",
        "Procurement",
        "Other"
      ]
    },
    "title": {
      "type": "string",
      "description": "Job title",
      "maxLength": 100
    },
    "manager": {
      "type": "string",
      "description": "Manager's user ID",
      "pattern": "^[a-zA-Z0-9\\-]{8,36}$"
    },
    "roles": {
      "type": "array",
      "description": "Assigned roles",
      "items": {
        "type": "string",
        "enum": [
          "admin",
          "security_engineer",
          "security_analyst",
          "it_engineer",
          "developer",
          "business_user",
          "viewer",
          "contractor",
          "system"
        ]
      }
    },
    "permissions": {
      "type": "array",
      "description": "Granular permissions",
      "items": {
        "type": "string"
      }
    },
    "mfa": {
      "type": "object",
      "description": "MFA configuration",
      "properties": {
        "enabled": {
          "type": "boolean",
          "default": false
        },
        "methods": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["totp", "sms", "email", "push", "webauthn", "biometric"]
          }
        },
        "totp_secret": {
          "type": "string",
          "description": "TOTP secret (encrypted)",
          "maxLength": 100
        },
        "backup_codes": {
          "type": "array",
          "description": "Backup codes (encrypted)",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "account_status": {
      "type": "object",
      "description": "Account status information",
      "properties": {
        "enabled": {
          "type": "boolean",
          "default": true
        },
        "locked": {
          "type": "boolean",
          "default": false
        },
        "locked_until": {
          "type": "string",
          "format": "date-time"
        },
        "failed_attempts": {
          "type": "integer",
          "minimum": 0,
          "default": 0
        },
        "last_login": {
          "type": "string",
          "format": "date-time"
        },
        "last_password_change": {
          "type": "string",
          "format": "date-time"
        }
      }
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "readOnly": true
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "readOnly": true
    },
    "attributes": {
      "type": "object",
      "description": "Additional user attributes",
      "additionalProperties": true
    }
  },
  "required": ["user_id", "username", "email", "full_name", "department"],
  "examples": [
    {
      "user_id": "usr_12345678",
      "username": "jdoe",
      "email": "john.doe@company.com",
      "full_name": "John Doe",
      "department": "Engineering",
      "title": "Senior Developer",
      "roles": ["developer", "security_champion"],
      "mfa": {
        "enabled": true,
        "methods": ["totp", "push"]
      },
      "account_status": {
        "enabled": true,
        "locked": false,
        "last_login": "2024-03-15T10:30:00Z"
      }
    }
  ]
}
```

### D.1.2: Asset and CMDB Data Model

**File:** `data-models/asset-model.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Asset and CMDB Data Model",
  "description": "Comprehensive asset and configuration management data model",
  "type": "object",
  "properties": {
    "asset_id": {
      "type": "string",
      "description": "Unique asset identifier",
      "pattern": "^[a-zA-Z0-9\\-]{8,36}$"
    },
    "asset_type": {
      "type": "string",
      "description": "Type of asset",
      "enum": [
        "server",
        "workstation",
        "network_device",
        "cloud_instance",
        "container",
        "database",
        "application",
        "service",
        "storage",
        "security_device",
        "iot_device",
        "mobile_device",
        "virtual_machine",
        "serverless_function",
        "kubernetes_cluster",
        "s3_bucket",
        "load_balancer",
        "firewall",
        "vpn_gateway",
        "dns_server",
        "email_server",
        "web_server",
        "api_gateway",
        "identity_provider"
      ]
    },
    "name": {
      "type": "string",
      "description": "Human-readable name",
      "minLength": 1,
      "maxLength": 255
    },
    "description": {
      "type": "string",
      "description": "Asset description",
      "maxLength": 1000
    },
    "location": {
      "type": "object",
      "description": "Asset location information",
      "properties": {
        "site": {
          "type": "string",
          "description": "Site or data center name"
        },
        "region": {
          "type": "string",
          "description": "Cloud region or geographic location"
        },
        "timezone": {
          "type": "string",
          "description": "Time zone",
          "maxLength": 50
        }
      }
    },
    "owner": {
      "type": "object",
      "description": "Asset ownership information",
      "properties": {
        "user_id": {
          "type": "string",
          "description": "Owner user ID"
        },
        "department": {
          "type": "string",
          "description": "Department of owner"
        },
        "contact": {
          "type": "string",
          "description": "Contact email or phone"
        }
      }
    },
    "status": {
      "type": "string",
      "description": "Current asset status",
      "enum": ["active", "stopped", "terminated", "maintenance", "unknown"]
    },
    "lifecycle": {
      "type": "object",
      "description": "Asset lifecycle information",
      "properties": {
        "created_at": {
          "type": "string",
          "format": "date-time"
        },
        "last_updated": {
          "type": "string",
          "format": "date-time"
        },
        "last_discovered": {
          "type": "string",
          "format": "date-time"
        },
        "deprecated_at": {
          "type": "string",
          "format": "date-time"
        },
        "retired_at": {
          "type": "string",
          "format": "date-time"
        }
      }
    },
    "security": {
      "type": "object",
      "description": "Security configuration",
      "properties": {
        "classification_level": {
          "type": "string",
          "enum": ["public", "internal", "confidential", "highly_confidential", "critical"]
        },
        "encryption_status": {
          "type": "string",
          "enum": ["encrypted", "partial", "not_encrypted", "unknown"]
        },
        "mfa_required": {
          "type": "boolean",
          "default": false
        },
        "compliance": {
          "type": "object",
          "description": "Compliance status",
          "properties": {
            "compliant": {
              "type": "boolean",
              "default": false
            },
            "compliance_score": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100
            }
          }
        },
        "last_patch_date": {
          "type": "string",
          "format": "date-time"
        },
        "vulnerabilities": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {"type": "string"},
              "severity": {"type": "string", "enum": ["critical", "high", "medium", "low"]},
              "description": {"type": "string"},
              "status": {"type": "string", "enum": ["open", "in_progress", "resolved"]}
            }
          }
        }
      }
    },
    "relationships": {
      "type": "array",
      "description": "Asset relationships",
      "items": {
        "type": "object",
        "properties": {
          "target_id": {
            "type": "string",
            "description": "Related asset ID"
          },
          "relationship_type": {
            "type": "string",
            "enum": ["depends_on", "runs_on", "hosts", "contains", "connects_to", "uses", "managed_by"]
          },
          "description": {
            "type": "string"
          }
        }
      }
    },
    "attributes": {
      "type": "object",
      "description": "Asset-specific attributes",
      "additionalProperties": true
    }
  },
  "required": ["asset_id", "asset_type", "name"],
  "examples": [
    {
      "asset_id": "asst_abc123",
      "asset_type": "cloud_instance",
      "name": "production-web-server-01",
      "description": "Primary production web server",
      "location": {
        "region": "us-east-1",
        "site": "AWS"
      },
      "owner": {
        "user_id": "usr_12345678",
        "department": "Engineering"
      },
      "status": "active",
      "lifecycle": {
        "created_at": "2024-01-15T08:00:00Z",
        "last_updated": "2024-03-15T10:30:00Z",
        "last_discovered": "2024-03-15T10:30:00Z"
      },
      "security": {
        "classification_level": "confidential",
        "encryption_status": "encrypted",
        "mfa_required": true,
        "compliance": {
          "compliant": true,
          "compliance_score": 95
        }
      },
      "relationships": [
        {
          "target_id": "asst_def456",
          "relationship_type": "depends_on",
          "description": "Depends on database server"
        }
      ],
      "attributes": {
        "instance_type": "t3.large",
        "ami_id": "ami-12345678",
        "vpc_id": "vpc-12345678",
        "subnet_id": "subnet-12345678"
      }
    }
  ]
}
```

### D.1.3: Risk Data Model

**File:** `data-models/risk-model.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Risk Data Model",
  "description": "Comprehensive risk management data model",
  "type": "object",
  "properties": {
    "risk_id": {
      "type": "string",
      "description": "Unique risk identifier",
      "pattern": "^RISK-[0-9]{4}-[0-9]{3}$"
    },
    "title": {
      "type": "string",
      "description": "Risk title",
      "minLength": 5,
      "maxLength": 200
    },
    "description": {
      "type": "string",
      "description": "Detailed risk description",
      "minLength": 10,
      "maxLength": 2000
    },
    "category": {
      "type": "string",
      "description": "Risk category",
      "enum": [
        "governance",
        "compliance",
        "data_security",
        "operational",
        "third_party",
        "physical",
        "financial",
        "reputational",
        "strategic",
        "cybersecurity",
        "insider_threat",
        "supply_chain",
        "infrastructure",
        "application",
        "cloud_security"
      ]
    },
    "source": {
      "type": "string",
      "description": "Risk source",
      "enum": ["external", "internal", "third_party", "natural", "human_error", "system_failure"]
    },
    "owner": {
      "type": "object",
      "description": "Risk ownership",
      "properties": {
        "user_id": {
          "type": "string"
        },
        "department": {
          "type": "string"
        },
        "title": {
          "type": "string"
        }
      }
    },
    "assessment": {
      "type": "object",
      "description": "Risk assessment metrics",
      "properties": {
        "likelihood": {
          "type": "integer",
          "description": "Likelihood score (1-5)",
          "minimum": 1,
          "maximum": 5
        },
        "impact": {
          "type": "integer",
          "description": "Impact score (1-5)",
          "minimum": 1,
          "maximum": 5
        },
        "velocity": {
          "type": "integer",
          "description": "Velocity score (1-5)",
          "minimum": 1,
          "maximum": 5
        },
        "risk_score": {
          "type": "integer",
          "description": "Calculated risk score",
          "minimum": 1,
          "maximum": 125
        },
        "risk_level": {
          "type": "string",
          "enum": ["critical", "high", "medium", "low"]
        },
        "assessment_date": {
          "type": "string",
          "format": "date-time"
        }
      }
    },
    "mitigation": {
      "type": "object",
      "description": "Risk mitigation information",
      "properties": {
        "controls": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {"type": "string"},
              "name": {"type": "string"},
              "description": {"type": "string"},
              "status": {"type": "string", "enum": ["planned", "in_progress", "implemented", "effective"]}
            }
          }
        },
        "action_plan": {
          "type": "string",
          "description": "Mitigation action plan"
        },
        "timeline": {
          "type": "object",
          "properties": {
            "target_date": {"type": "string", "format": "date-time"},
            "review_date": {"type": "string", "format": "date-time"}
          }
        },
        "status": {
          "type": "string",
          "enum": ["open", "in_progress", "mitigated", "accepted", "avoided", "transferred"]
        }
      }
    },
    "residual_risk": {
      "type": "object",
      "description": "Residual risk after mitigation",
      "properties": {
        "score": {
          "type": "integer",
          "minimum": 1,
          "maximum": 125
        },
        "level": {
          "type": "string",
          "enum": ["critical", "high", "medium", "low"]
        },
        "acceptance": {
          "type": "object",
          "properties": {
            "approved": {"type": "boolean"},
            "approved_by": {"type": "string"},
            "approval_date": {"type": "string", "format": "date-time"}
          }
        }
      }
    },
    "history": {
      "type": "array",
      "description": "Risk history and audit trail",
      "items": {
        "type": "object",
        "properties": {
          "timestamp": {"type": "string", "format": "date-time"},
          "user_id": {"type": "string"},
          "action": {"type": "string"},
          "details": {"type": "object"}
        }
      }
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    }
  },
  "required": ["risk_id", "title", "description", "category", "owner"],
  "examples": [
    {
      "risk_id": "RISK-2024-001",
      "title": "Unauthorized access to customer PII",
      "description": "Risk of unauthorized access to customer PII due to insufficient access controls",
      "category": "data_security",
      "source": "internal",
      "owner": {
        "user_id": "usr_12345678",
        "department": "Security",
        "title": "Security Manager"
      },
      "assessment": {
        "likelihood": 3,
        "impact": 4,
        "velocity": 3,
        "risk_score": 36,
        "risk_level": "high",
        "assessment_date": "2024-01-15T10:00:00Z"
      },
      "mitigation": {
        "controls": [
          {
            "id": "CTRL-001",
            "name": "Access Control Review",
            "description": "Quarterly access reviews",
            "status": "implemented"
          }
        ],
        "action_plan": "Implement DLP and data masking",
        "timeline": {
          "target_date": "2024-06-30T23:59:59Z",
          "review_date": "2024-07-15T10:00:00Z"
        },
        "status": "in_progress"
      },
      "residual_risk": {
        "score": 18,
        "level": "medium"
      },
      "history": [
        {
          "timestamp": "2024-01-15T10:00:00Z",
          "user_id": "usr_12345678",
          "action": "RISK_CREATED",
          "details": {"initial_assessment": "high"}
        }
      ],
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-03-15T14:30:00Z"
    }
  ]
}
```

### D.1.4: Incident Data Model

**File:** `data-models/incident-model.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Incident Data Model",
  "description": "Comprehensive security incident data model",
  "type": "object",
  "properties": {
    "incident_id": {
      "type": "string",
      "description": "Unique incident identifier",
      "pattern": "^INC-[0-9]{4}-[0-9]{3}$"
    },
    "title": {
      "type": "string",
      "description": "Incident title",
      "minLength": 5,
      "maxLength": 200
    },
    "description": {
      "type": "string",
      "description": "Detailed incident description",
      "minLength": 10,
      "maxLength": 5000
    },
    "severity": {
      "type": "string",
      "description": "Incident severity",
      "enum": ["critical", "high", "medium", "low"]
    },
    "status": {
      "type": "string",
      "description": "Current incident status",
      "enum": [
        "open",
        "investigating",
        "contained",
        "eradicating",
        "recovering",
        "resolved",
        "closed",
        "false_positive"
      ]
    },
    "type": {
      "type": "string",
      "description": "Incident type",
      "enum": [
        "malware",
        "ransomware",
        "phishing",
        "data_breach",
        "unauthorized_access",
        "ddos",
        "insider_threat",
        "supply_chain",
        "account_compromise",
        "system_compromise",
        "physical_breach",
        "misconfiguration",
        "policy_violation"
      ]
    },
    "phase": {
      "type": "object",
      "description": "Incident response phase information",
      "properties": {
        "detection": {
          "type": "object",
          "properties": {
            "source": {"type": "string", "enum": ["SIEM", "EDR", "User_Report", "Threat_Intel", "Other"]},
            "timestamp": {"type": "string", "format": "date-time"},
            "method": {"type": "string"}
          }
        },
        "containment": {
          "type": "object",
          "properties": {
            "started_at": {"type": "string", "format": "date-time"},
            "completed_at": {"type": "string", "format": "date-time"},
            "actions": {"type": "array", "items": {"type": "string"}},
            "effectiveness": {"type": "string", "enum": ["successful", "partial", "failed"]}
          }
        },
        "eradication": {
          "type": "object",
          "properties": {
            "started_at": {"type": "string", "format": "date-time"},
            "completed_at": {"type": "string", "format": "date-time"},
            "actions": {"type": "array", "items": {"type": "string"}},
            "root_cause_found": {"type": "boolean"}
          }
        },
        "recovery": {
          "type": "object",
          "properties": {
            "started_at": {"type": "string", "format": "date-time"},
            "completed_at": {"type": "string", "format": "date-time"},
            "systems_restored": {"type": "array", "items": {"type": "string"}},
            "business_impact_restored": {"type": "boolean"}
          }
        },
        "lessons_learned": {
          "type": "object",
          "properties": {
            "conducted_at": {"type": "string", "format": "date-time"},
            "findings": {"type": "array", "items": {"type": "string"}},
            "improvements": {"type": "array", "items": {"type": "string"}},
            "playbook_updated": {"type": "boolean"}
          }
        }
      }
    },
    "metrics": {
      "type": "object",
      "description": "Incident metrics",
      "properties": {
        "mttd": {
          "type": "number",
          "description": "Mean Time To Detect (hours)"
        },
        "mtta": {
          "type": "number",
          "description": "Mean Time To Acknowledge (hours)"
        },
        "mttc": {
          "type": "number",
          "description": "Mean Time To Contain (hours)"
        },
        "mtte": {
          "type": "number",
          "description": "Mean Time To Eradicate (hours)"
        },
        "mttr": {
          "type": "number",
          "description": "Mean Time To Recover (hours)"
        },
        "total_duration": {
          "type": "number",
          "description": "Total incident duration (hours)"
        }
      }
    },
    "affected": {
      "type": "object",
      "description": "Affected assets and data",
      "properties": {
        "systems": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "asset_id": {"type": "string"},
              "name": {"type": "string"},
              "severity": {"type": "string", "enum": ["critical", "high", "medium", "low"]}
            }
          }
        },
        "data": {
          "type": "object",
          "properties": {
            "classification": {"type": "string", "enum": ["public", "internal", "confidential", "highly_confidential", "critical"]},
            "records_affected": {"type": "integer"},
            "data_types": {"type": "array", "items": {"type": "string"}}
          }
        },
        "users": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    },
    "response_team": {
      "type": "object",
      "description": "Incident response team",
      "properties": {
        "incident_commander": {"type": "string"},
        "team_members": {"type": "array", "items": {"type": "string"}},
        "external_involved": {"type": "boolean"},
        "external_parties": {"type": "array", "items": {"type": "string"}}
      }
    },
    "communications": {
      "type": "object",
      "description": "Communication records",
      "properties": {
        "internal_communications": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "timestamp": {"type": "string", "format": "date-time"},
              "audience": {"type": "string"},
              "message": {"type": "string"}
            }
          }
        },
        "external_communications": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "timestamp": {"type": "string", "format": "date-time"},
              "stakeholder": {"type": "string"},
              "message": {"type": "string"}
            }
          }
        },
        "regulatory_reporting": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "authority": {"type": "string"},
              "report_date": {"type": "string", "format": "date-time"},
              "status": {"type": "string", "enum": ["pending", "submitted", "acknowledged"]}
            }
          }
        }
      }
    },
    "evidence": {
      "type": "object",
      "description": "Incident evidence",
      "properties": {
        "collection": {
          "type": "object",
          "properties": {
            "started_at": {"type": "string", "format": "date-time"},
            "completed_at": {"type": "string", "format": "date-time"},
            "collected_by": {"type": "string"}
          }
        },
        "items": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "type": {"type": "string"},
              "location": {"type": "string"},
              "hash": {"type": "string"},
              "description": {"type": "string"}
            }
          }
        },
        "preservation_method": {"type": "string"}
      }
    },
    "lessons_learned": {
      "type": "object",
      "description": "Post-incident lessons learned",
      "properties": {
        "findings": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "area": {"type": "string"},
              "issue": {"type": "string"},
              "impact": {"type": "string"},
              "recommendation": {"type": "string"}
            }
          }
        },
        "improvements": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "action": {"type": "string"},
              "owner": {"type": "string"},
              "target_date": {"type": "string", "format": "date-time"},
              "status": {"type": "string", "enum": ["planned", "in_progress", "completed", "pending"]}
            }
          }
        },
        "playbook_updates": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    },
    "timeline": {
      "type": "array",
      "description": "Incident timeline",
      "items": {
        "type": "object",
        "properties": {
          "timestamp": {"type": "string", "format": "date-time"},
          "event": {"type": "string"},
          "actor": {"type": "string"},
          "details": {"type": "string"}
        }
      }
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    }
  },
  "required": ["incident_id", "title", "description", "severity", "status", "type"],
  "examples": [
    {
      "incident_id": "INC-2024-001",
      "title": "Ransomware incident on production servers",
      "description": "Ransomware detected on 5 production servers affecting customer data",
      "severity": "critical",
      "status": "contained",
      "type": "ransomware",
      "phase": {
        "detection": {
          "source": "EDR",
          "timestamp": "2024-03-15T08:30:00Z"
        },
        "containment": {
          "started_at": "2024-03-15T09:00:00Z",
          "completed_at": "2024-03-15T10:30:00Z",
          "actions": ["network_isolation", "endpoint_isolation"],
          "effectiveness": "successful"
        }
      },
      "metrics": {
        "mttd": 1.5,
        "mtta": 0.5,
        "mttc": 2.5
      },
      "affected": {
        "systems": [
          {"asset_id": "asst_123", "name": "prod-server-01", "severity": "critical"}
        ],
        "data": {
          "classification": "highly_confidential",
          "records_affected": 10000
        }
      },
      "created_at": "2024-03-15T08:30:00Z",
      "updated_at": "2024-03-15T15:00:00Z"
    }
  ]
}
```

### D.1.5: Vendor and Third-Party Data Model

**File:** `data-models/vendor-model.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Vendor and Third-Party Data Model",
  "description": "Comprehensive vendor and third-party management data model",
  "type": "object",
  "properties": {
    "vendor_id": {
      "type": "string",
      "description": "Unique vendor identifier",
      "pattern": "^VND-[0-9]{4}-[0-9]{3}$"
    },
    "name": {
      "type": "string",
      "description": "Vendor name",
      "minLength": 2,
      "maxLength": 200
    },
    "description": {
      "type": "string",
      "description": "Vendor description",
      "maxLength": 1000
    },
    "category": {
      "type": "string",
      "description": "Vendor category",
      "enum": ["critical", "high", "medium", "low"]
    },
    "tier": {
      "type": "integer",
      "description": "Vendor tier (1=critical to 4=low)",
      "minimum": 1,
      "maximum": 4
    },
    "status": {
      "type": "string",
      "description": "Vendor status",
      "enum": ["onboarding", "active", "under_review", "non_compliant", "terminated"]
    },
    "contact": {
      "type": "object",
      "description": "Vendor contact information",
      "properties": {
        "name": {"type": "string"},
        "email": {"type": "string", "format": "email"},
        "phone": {"type": "string"},
        "title": {"type": "string"},
        "department": {"type": "string"}
      }
    },
    "company_info": {
      "type": "object",
      "description": "Company information",
      "properties": {
        "website": {"type": "string", "format": "uri"},
        "industry": {"type": "string"},
        "headquarters": {"type": "string"},
        "size": {"type": "string"},
        "year_founded": {"type": "integer"},
        "duns_number": {"type": "string"}
      }
    },
    "contract": {
      "type": "object",
      "description": "Contract information",
      "properties": {
        "contract_id": {"type": "string"},
        "start_date": {"type": "string", "format": "date"},
        "end_date": {"type": "string", "format": "date"},
        "renewal_date": {"type": "string", "format": "date"},
        "value": {"type": "number"},
        "currency": {"type": "string"},
        "terms": {"type": "string"},
        "sla": {
          "type": "object",
          "properties": {
            "uptime": {"type": "number"},
            "response_time": {"type": "number"},
            "security_requirements": {"type": "array", "items": {"type": "string"}}
          }
        }
      }
    },
    "security": {
      "type": "object",
      "description": "Security information",
      "properties": {
        "risk_score": {
          "type": "number",
          "description": "Overall risk score (0-100)",
          "minimum": 0,
          "maximum": 100
        },
        "security_rating": {
          "type": "number",
          "description": "Security rating (0-100)",
          "minimum": 0,
          "maximum": 100
        },
        "certifications": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
              "status": {"type": "string", "enum": ["active", "pending", "expired"]},
              "valid_from": {"type": "string", "format": "date"},
              "valid_to": {"type": "string", "format": "date"}
            }
          }
        },
        "assessments": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {"type": "string"},
              "type": {"type": "string", "enum": ["questionnaire", "audit", "penetration_test", "security_score"]},
              "date": {"type": "string", "format": "date"},
              "score": {"type": "number"},
              "status": {"type": "string", "enum": ["pending", "complete", "failed", "in_progress"]}
            }
          }
        },
        "issues": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "id": {"type": "string"},
              "description": {"type": "string"},
              "severity": {"type": "string", "enum": ["critical", "high", "medium", "low"]},
              "status": {"type": "string", "enum": ["open", "in_progress", "resolved", "accepted"]},
              "remediation_date": {"type": "string", "format": "date"}
            }
          }
        },
        "security_scorecard": {
          "type": "object",
          "properties": {
            "identity_security": {"type": "number"},
            "data_protection": {"type": "number"},
            "access_control": {"type": "number"},
            "security_operations": {"type": "number"},
            "incident_response": {"type": "number"},
            "business_continuity": {"type": "number"},
            "vulnerability_management": {"type": "number"},
            "software_supply_chain": {"type": "number"},
            "third_party_security": {"type": "number"}
          }
        }
      }
    },
    "services": {
      "type": "object",
      "description": "Services provided",
      "properties": {
        "service_types": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "name": {"type": "string"},
              "description": {"type": "string"},
              "criticality": {"type": "string", "enum": ["critical", "high", "medium", "low"]},
              "data_types": {"type": "array", "items": {"type": "string"}}
            }
          }
        },
        "data_handling": {
          "type": "object",
          "properties": {
            "handles_sensitive_data": {"type": "boolean"},
            "data_classification": {"type": "array", "items": {"type": "string"}},
            "data_residency": {"type": "array", "items": {"type": "string"}},
            "data_retention": {"type": "string"}
          }
        }
      }
    },
    "monitoring": {
      "type": "object",
      "description": "Continuous monitoring",
      "properties": {
        "last_assessment": {"type": "string", "format": "date-time"},
        "next_assessment": {"type": "string", "format": "date-time"},
        "monitoring_frequency": {"type": "string", "enum": ["daily", "weekly", "monthly", "quarterly"]},
        "alerts": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "timestamp": {"type": "string", "format": "date-time"},
              "type": {"type": "string"},
              "severity": {"type": "string"},
              "message": {"type": "string"},
              "status": {"type": "string", "enum": ["open", "investigating", "resolved"]}
            }
          }
        }
      }
    },
    "history": {
      "type": "array",
      "description": "Vendor history",
      "items": {
        "type": "object",
        "properties": {
          "timestamp": {"type": "string", "format": "date-time"},
          "action": {"type": "string"},
          "user_id": {"type": "string"},
          "details": {"type": "object"}
        }
      }
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    }
  },
  "required": ["vendor_id", "name", "category", "tier"],
  "examples": [
    {
      "vendor_id": "VND-2024-001",
      "name": "Cloud Infrastructure Provider",
      "description": "Primary cloud infrastructure provider for all production workloads",
      "category": "critical",
      "tier": 1,
      "status": "active",
      "contact": {
        "name": "Jane Doe",
        "email": "jane.doe@cloudprovider.com",
        "phone": "+1-555-123-4567",
        "title": "Security Manager"
      },
      "security": {
        "risk_score": 25.0,
        "security_rating": 85.0,
        "certifications": [
          {
            "name": "SOC 2 Type II",
            "status": "active",
            "valid_from": "2023-01-01",
            "valid_to": "2024-12-31"
          },
          {
            "name": "ISO 27001",
            "status": "active",
            "valid_from": "2022-06-01",
            "valid_to": "2025-05-31"
          }
        ],
        "security_scorecard": {
          "identity_security": 90,
          "data_protection": 85,
          "access_control": 88,
          "security_operations": 82,
          "incident_response": 90,
          "business_continuity": 85,
          "vulnerability_management": 80,
          "software_supply_chain": 75,
          "third_party_security": 80
        }
      },
      "services": {
        "service_types": [
          {
            "name": "Infrastructure as a Service",
            "description": "IaaS including compute, storage, and networking",
            "criticality": "critical",
            "data_types": ["customer_data", "application_data", "system_data"]
          }
        ],
        "data_handling": {
          "handles_sensitive_data": true,
          "data_classification": ["confidential", "highly_confidential"],
          "data_residency": ["us-east-1", "eu-west-1"],
          "data_retention": "7 years"
        }
      },
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-03-15T14:30:00Z"
    }
  ]
}
```

---

## D.2: Log and Event Data Models

### D.2.1: Security Event Data Model

**File:** `data-models/security-event-model.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Security Event Data Model",
  "description": "Comprehensive security event and log data model",
  "type": "object",
  "properties": {
    "event_id": {
      "type": "string",
      "description": "Unique event identifier",
      "pattern": "^[a-zA-Z0-9\\-]{8,36}$"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "Event timestamp (UTC)"
    },
    "source": {
      "type": "object",
      "description": "Event source",
      "properties": {
        "type": {
          "type": "string",
          "enum": [
            "firewall",
            "ids",
            "edr",
            "iam",
            "dns",
            "web",
            "email",
            "cloud",
            "application",
            "database",
            "operating_system",
            "network",
            "siem"
          ]
        },
        "system": {
          "type": "string",
          "description": "Source system name"
        },
        "ip": {
          "type": "string",
          "format": "ipv4",
          "description": "Source IP address"
        },
        "hostname": {
          "type": "string",
          "description": "Source hostname"
        },
        "port": {
          "type": "integer",
          "description": "Source port"
        }
      }
    },
    "destination": {
      "type": "object",
      "description": "Event destination",
      "properties": {
        "ip": {
          "type": "string",
          "format": "ipv4",
          "description": "Destination IP address"
        },
        "hostname": {
          "type": "string",
          "description": "Destination hostname"
        },
        "port": {
          "type": "integer",
          "description": "Destination port"
        },
        "resource": {
          "type": "string",
          "description": "Resource accessed"
        }
      }
    },
    "user": {
      "type": "object",
      "description": "User associated with event",
      "properties": {
        "user_id": {"type": "string"},
        "username": {"type": "string"},
        "email": {"type": "string", "format": "email"},
        "role": {"type": "string"},
        "department": {"type": "string"}
      }
    },
    "action": {
      "type": "object",
      "description": "Event action",
      "properties": {
        "type": {
          "type": "string",
          "enum": [
            "login",
            "logout",
            "access",
            "create",
            "update",
            "delete",
            "modify",
            "read",
            "write",
            "execute",
            "connect",
            "disconnect",
            "authenticate",
            "authorize",
            "encrypt",
            "decrypt"
          ]
        },
        "result": {
          "type": "string",
          "enum": ["success", "failure", "blocked", "denied", "pending"]
        },
        "status_code": {
          "type": "string",
          "description": "Status code (HTTP, syslog, etc.)"
        }
      }
    },
    "event_type": {
      "type": "string",
      "description": "Event type",
      "enum": [
        "login_attempt",
        "logout",
        "access_request",
        "file_access",
        "data_export",
        "data_import",
        "system_start",
        "system_stop",
        "configuration_change",
        "user_management",
        "permission_change",
        "security_alert",
        "network_connection",
        "dns_lookup",
        "email_sent",
        "email_received",
        "malware_detected",
        "intrusion_detected",
        "policy_violation",
        "privilege_escalation"
      ]
    },
    "severity": {
      "type": "string",
      "description": "Event severity",
      "enum": ["debug", "info", "warning", "error", "critical"]
    },
    "data": {
      "type": "object",
      "description": "Event-specific data",
      "properties": {
        "protocol": {"type": "string"},
        "bytes_sent": {"type": "integer"},
        "bytes_received": {"type": "integer"},
        "duration": {"type": "number"},
        "request": {"type": "object"},
        "response": {"type": "object"},
        "message": {"type": "string"},
        "additional_info": {"type": "object"}
      }
    },
    "tags": {
      "type": "array",
      "description": "Event tags",
      "items": {"type": "string"}
    },
    "correlation": {
      "type": "object",
      "description": "Correlation information",
      "properties": {
        "correlation_id": {"type": "string"},
        "related_events": {"type": "array", "items": {"type": "string"}},
        "rule_id": {"type": "string"},
        "rule_name": {"type": "string"}
      }
    },
    "raw_data": {
      "type": "string",
      "description": "Original raw log data"
    }
  },
  "required": ["event_id", "timestamp", "source", "event_type", "action"],
  "examples": [
    {
      "event_id": "evt_12345678",
      "timestamp": "2024-03-15T10:30:00Z",
      "source": {
        "type": "edr",
        "system": "endpoint-server-01",
        "hostname": "server-01.company.com"
      },
      "destination": {
        "resource": "C:\\Windows\\System32\\config"
      },
      "user": {
        "username": "admin",
        "role": "administrator"
      },
      "action": {
        "type": "access",
        "result": "blocked"
      },
      "event_type": "access_request",
      "severity": "warning",
      "data": {
        "message": "Unauthorized access attempt to system directory",
        "additional_info": {
          "process": "powershell.exe",
          "command": "Get-ChildItem C:\\Windows\\System32\\config"
        }
      },
      "tags": ["access_attempt", "privileged"],
      "correlation": {
        "rule_id": "CR-003",
        "rule_name": "Privilege Escalation"
      }
    }
  ]
}
```

---

## D.3: Response and Playbook Data Models

### D.3.1: Incident Response Playbook Model

**File:** `data-models/playbook-model.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Incident Response Playbook Data Model",
  "description": "Comprehensive incident response playbook data model",
  "type": "object",
  "properties": {
    "playbook_id": {
      "type": "string",
      "description": "Unique playbook identifier",
      "pattern": "^PB-[0-9]{4}-[0-9]{3}$"
    },
    "name": {
      "type": "string",
      "description": "Playbook name",
      "minLength": 3,
      "maxLength": 200
    },
    "description": {
      "type": "string",
      "description": "Playbook description",
      "maxLength": 1000
    },
    "version": {
      "type": "string",
      "description": "Playbook version",
      "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$"
    },
    "status": {
      "type": "string",
      "description": "Playbook status",
      "enum": ["draft", "review", "approved", "deprecated"]
    },
    "incident_type": {
      "type": "array",
      "description": "Incident types this playbook covers",
      "items": {
        "type": "string",
        "enum": [
          "malware",
          "ransomware",
          "phishing",
          "data_breach",
          "unauthorized_access",
          "ddos",
          "insider_threat",
          "supply_chain",
          "account_compromise",
          "system_compromise",
          "physical_breach",
          "misconfiguration",
          "policy_violation"
        ]
      }
    },
    "severity_levels": {
      "type": "array",
      "description": "Severity levels this playbook covers",
      "items": {
        "type": "string",
        "enum": ["critical", "high", "medium", "low"]
      }
    },
    "phases": {
      "type": "object",
      "description": "Incident response phases",
      "properties": {
        "detection": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "steps": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "step_id": {"type": "integer"},
                  "action": {"type": "string"},
                  "owner": {"type": "string"},
                  "tools": {"type": "array", "items": {"type": "string"}},
                  "timeout": {"type": "number"},
                  "success_criteria": {"type": "string"},
                  "notes": {"type": "string"}
                }
              }
            }
          }
        },
        "assessment": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "steps": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "step_id": {"type": "integer"},
                  "action": {"type": "string"},
                  "owner": {"type": "string"},
                  "tools": {"type": "array", "items": {"type": "string"}},
                  "timeout": {"type": "number"},
                  "success_criteria": {"type": "string"},
                  "notes": {"type": "string"}
                }
              }
            }
          }
        },
        "containment": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "steps": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "step_id": {"type": "integer"},
                  "action": {"type": "string"},
                  "owner": {"type": "string"},
                  "tools": {"type": "array", "items": {"type": "string"}},
                  "timeout": {"type": "number"},
                  "success_criteria": {"type": "string"},
                  "notes": {"type": "string"}
                }
              }
            }
          }
        },
        "eradication": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "steps": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "step_id": {"type": "integer"},
                  "action": {"type": "string"},
                  "owner": {"type": "string"},
                  "tools": {"type": "array", "items": {"type": "string"}},
                  "timeout": {"type": "number"},
                  "success_criteria": {"type": "string"},
                  "notes": {"type": "string"}
                }
              }
            }
          }
        },
        "recovery": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "steps": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "step_id": {"type": "integer"},
                  "action": {"type": "string"},
                  "owner": {"type": "string"},
                  "tools": {"type": "array", "items": {"type": "string"}},
                  "timeout": {"type": "number"},
                  "success_criteria": {"type": "string"},
                  "notes": {"type": "string"}
                }
              }
            }
          }
        },
        "lessons_learned": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "steps": {
              "type": "array",
              "items": {
                "type": "object",
                "properties": {
                  "step_id": {"type": "integer"},
                  "action": {"type": "string"},
                  "owner": {"type": "string"},
                  "tools": {"type": "array", "items": {"type": "string"}},
                  "timeout": {"type": "number"},
                  "success_criteria": {"type": "string"},
                  "notes": {"type": "string"}
                }
              }
            }
          }
        }
      }
    },
    "communication_plan": {
      "type": "object",
      "description": "Communication plan",
      "properties": {
        "internal": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "time": {"type": "string"},
              "audience": {"type": "string"},
              "channel": {"type": "string"},
              "message_template": {"type": "string"}
            }
          }
        },
        "external": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "stakeholder": {"type": "string"},
              "timing": {"type": "string"},
              "message_template": {"type": "string"},
              "approved_by": {"type": "string"}
            }
          }
        },
        "regulatory": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "authority": {"type": "string"},
              "requirement": {"type": "string"},
              "timeframe": {"type": "string"},
              "notification_template": {"type": "string"}
            }
          }
        }
      }
    },
    "escalation_matrix": {
      "type": "object",
      "description": "Escalation matrix",
      "properties": {
        "levels": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "level": {"type": "integer"},
              "criteria": {"type": "string"},
              "role": {"type": "string"},
              "contact": {"type": "string"},
              "timeframe": {"type": "string"}
            }
          }
        }
      }
    },
    "tools_and_resources": {
      "type": "object",
      "description": "Tools and resources",
      "properties": {
        "detection_tools": {"type": "array", "items": {"type": "string"}},
        "containment_tools": {"type": "array", "items": {"type": "string"}},
        "analysis_tools": {"type": "array", "items": {"type": "string"}},
        "recovery_tools": {"type": "array", "items": {"type": "string"}},
        "documentation_templates": {"type": "array", "items": {"type": "string"}}
      }
    },
    "roles_responsibilities": {
      "type": "object",
      "description": "Roles and responsibilities",
      "properties": {
        "incident_commander": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "responsibilities": {"type": "array", "items": {"type": "string"}}
          }
        },
        "security_analyst": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "responsibilities": {"type": "array", "items": {"type": "string"}}
          }
        },
        "it_operations": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "responsibilities": {"type": "array", "items": {"type": "string"}}
          }
        },
        "legal_counsel": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "responsibilities": {"type": "array", "items": {"type": "string"}}
          }
        },
        "pr_manager": {
          "type": "object",
          "properties": {
            "description": {"type": "string"},
            "responsibilities": {"type": "array", "items": {"type": "string"}}
          }
        }
      }
    },
    "checklists": {
      "type": "object",
      "description": "Checklists",
      "properties": {
        "pre_incident": {
          "type": "array",
          "items": {"type": "string"}
        },
        "during_incident": {
          "type": "array",
          "items": {"type": "string"}
        },
        "post_incident": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    },
    "created_at": {
      "type": "string",
      "format": "date-time"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time"
    },
    "last_test_date": {
      "type": "string",
      "format": "date-time"
    },
    "test_results": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "test_id": {"type": "string"},
          "date": {"type": "string", "format": "date-time"},
          "status": {"type": "string", "enum": ["success", "partial", "failed"]},
          "issues": {"type": "array", "items": {"type": "string"}},
          "improvements": {"type": "array", "items": {"type": "string"}}
        }
      }
    }
  },
  "required": ["playbook_id", "name", "description", "incident_type"],
  "examples": [
    {
      "playbook_id": "PB-2024-001",
      "name": "Ransomware Incident Response Playbook",
      "description": "Comprehensive playbook for responding to ransomware incidents",
      "version": "2.0.0",
      "status": "approved",
      "incident_type": ["ransomware"],
      "severity_levels": ["critical", "high"],
      "phases": {
        "detection": {
          "description": "Initial detection and triage",
          "steps": [
            {
              "step_id": 1,
              "action": "Confirm ransomware activity",
              "owner": "SOC Analyst",
              "tools": ["EDR", "SIEM"],
              "timeout": 5,
              "success_criteria": "Ransomware confirmed",
              "notes": "Look for file extensions, ransom notes, encryption activity"
            }
          ]
        }
      },
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-03-15T14:30:00Z",
      "last_test_date": "2024-03-01T09:00:00Z"
    }
  ]
}
```

---

## D.4: Standard Reference Tables

### D.4.1: Security Classification Matrix

**File:** `data-models/classification-matrix.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Security Classification Matrix",
  "description": "Standard security classification levels with requirements",
  "type": "object",
  "properties": {
    "classification_levels": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "level": {
            "type": "string",
            "enum": ["public", "internal", "confidential", "highly_confidential", "critical"]
          },
          "name": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "impact": {
            "type": "object",
            "properties": {
              "confidentiality": {"type": "string", "enum": ["low", "medium", "high", "critical"]},
              "integrity": {"type": "string", "enum": ["low", "medium", "high", "critical"]},
              "availability": {"type": "string", "enum": ["low", "medium", "high", "critical"]}
            }
          },
          "requirements": {
            "type": "object",
            "properties": {
              "encryption_at_rest": {"type": "boolean"},
              "encryption_in_transit": {"type": "boolean"},
              "access_control": {"type": "string", "enum": ["none", "basic", "role_based", "strict"]},
              "mfa_required": {"type": "boolean"},
              "dlp_monitoring": {"type": "boolean"},
              "audit_logging": {"type": "string", "enum": ["none", "basic", "full"]},
              "secure_destruction": {"type": "boolean"},
              "retention_period": {"type": "string"}
            }
          },
          "examples": {
            "type": "array",
            "items": {"type": "string"}
          }
        }
      }
    }
  },
  "examples": [
    {
      "level": "public",
      "name": "Public",
      "description": "Information that can be freely shared with the public",
      "impact": {
        "confidentiality": "low",
        "integrity": "low",
        "availability": "low"
      },
      "requirements": {
        "encryption_at_rest": false,
        "encryption_in_transit": false,
        "access_control": "none",
        "mfa_required": false,
        "dlp_monitoring": false,
        "audit_logging": "none",
        "secure_destruction": false,
        "retention_period": "indefinite"
      },
      "examples": [
        "Public website content",
        "Marketing materials",
        "Press releases",
        "Annual reports"
      ]
    },
    {
      "level": "internal",
      "name": "Internal",
      "description": "Information intended for internal use only",
      "impact": {
        "confidentiality": "medium",
        "integrity": "medium",
        "availability": "low"
      },
      "requirements": {
        "encryption_at_rest": false,
        "encryption_in_transit": true,
        "access_control": "basic",
        "mfa_required": false,
        "dlp_monitoring": false,
        "audit_logging": "basic",
        "secure_destruction": false,
        "retention_period": "7 years"
      },
      "examples": [
        "Internal policies",
        "Internal communications",
        "Employee directories",
        "Training materials"
      ]
    }
  ]
}
```

### D.4.2: Security Control Reference Table

**File:** `data-models/controls-reference.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Security Control Reference Table",
  "description": "Standard security controls mapped to frameworks",
  "type": "object",
  "properties": {
    "controls": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "control_id": {
            "type": "string"
          },
          "name": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "category": {
            "type": "string",
            "enum": [
              "access_control",
              "identity_management",
              "data_protection",
              "network_security",
              "endpoint_security",
              "vulnerability_management",
              "incident_response",
              "business_continuity",
              "supply_chain",
              "awareness_training",
              "security_operations",
              "governance",
              "compliance",
              "physical_security",
              "cloud_security"
            ]
          },
          "implementation_priority": {
            "type": "string",
            "enum": ["critical", "high", "medium", "low"]
          },
          "framework_mappings": {
            "type": "object",
            "properties": {
              "nist_csf": {
                "type": "array",
                "items": {"type": "string"}
              },
              "iso_27001": {
                "type": "array",
                "items": {"type": "string"}
              },
              "cis_controls": {
                "type": "array",
                "items": {"type": "string"}
              }
            }
          },
          "implementation_guidance": {
            "type": "object",
            "properties": {
              "description": {"type": "string"},
              "steps": {"type": "array", "items": {"type": "string"}},
              "tools": {"type": "array", "items": {"type": "string"}},
              "evidence": {"type": "array", "items": {"type": "string"}}
            }
          }
        }
      }
    }
  },
  "examples": [
    {
      "control_id": "CTRL-001",
      "name": "Multi-Factor Authentication",
      "description": "Require MFA for all user and administrative access",
      "category": "identity_management",
      "implementation_priority": "critical",
      "framework_mappings": {
        "nist_csf": ["PR.AC-7", "PR.AC-8"],
        "iso_27001": ["A.9.4.2", "A.9.4.3"],
        "cis_controls": ["Control 6", "Control 16"]
      },
      "implementation_guidance": {
        "description": "Deploy MFA for all users, prioritizing privileged and external access",
        "steps": [
          "Inventory all user accounts",
          "Identify MFA requirements by role",
          "Select MFA solution",
          "Phase rollout with communication",
          "Enforce MFA policy"
        ],
        "tools": ["Azure AD", "Okta", "Google Authenticator", "Yubikey"],
        "evidence": ["MFA adoption reports", "MFA enforcement policy", "User training records"]
      }
    }
  ]
}
```

### D.4.3: Incident Severity Matrix

**File:** `data-models/severity-matrix.json`

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Incident Severity Matrix",
  "description": "Incident severity definitions and criteria",
  "type": "object",
  "properties": {
    "severity_levels": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "level": {
            "type": "string",
            "enum": ["critical", "high", "medium", "low"]
          },
          "name": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "criteria": {
            "type": "object",
            "properties": {
              "business_impact": {"type": "string"},
              "data_sensitivity": {"type": "string"},
              "systems_affected": {"type": "string"},
              "regulatory_impact": {"type": "string"},
              "reputation_impact": {"type": "string"},
              "scope": {"type": "string"}
            }
          },
          "response_requirements": {
            "type": "object",
            "properties": {
              "response_time": {"type": "string"},
              "escalation": {"type": "string"},
              "notification": {"type": "array", "items": {"type": "string"}},
              "resources": {"type": "array", "items": {"type": "string"}}
            }
          }
        }
      }
    }
  },
  "examples": [
    {
      "level": "critical",
      "name": "Critical",
      "description": "Severe incident requiring immediate executive attention",
      "criteria": {
        "business_impact": "Significant business disruption affecting multiple critical functions",
        "data_sensitivity": "Critical or highly confidential data exposed",
        "systems_affected": "Multiple critical systems compromised",
        "regulatory_impact": "Mandatory regulatory reporting required",
        "reputation_impact": "Significant public/regulatory attention expected",
        "scope": "Organization-wide impact"
      },
      "response_requirements": {
        "response_time": "Immediate (0-15 minutes)",
        "escalation": "CEO/Board within 1 hour",
        "notification": ["CISO", "CEO", "Board", "Legal", "PR"],
        "resources": ["Full incident response team", "External forensics", "Legal counsel"]
      }
    },
    {
      "level": "high",
      "name": "High",
      "description": "Significant incident requiring senior management attention",
      "criteria": {
        "business_impact": "Moderate business disruption affecting critical functions",
        "data_sensitivity": "Confidential or sensitive data involved",
        "systems_affected": "Critical systems affected",
        "regulatory_impact": "Potential regulatory reporting",
        "reputation_impact": "Moderate public attention expected",
        "scope": "Department or business unit impact"
      },
      "response_requirements": {
        "response_time": "15-30 minutes",
        "escalation": "Executive Council within 2 hours",
        "notification": ["CISO", "Executive Council", "Legal"],
        "resources": ["Incident response team", "Security architects"]
      }
    }
  ]
}
```

---

This concludes Appendix D: Complete Reference Data Models. These models provide the data foundation for the entire Enterprise Cybersecurity Program, ensuring consistency across all components and systems.
