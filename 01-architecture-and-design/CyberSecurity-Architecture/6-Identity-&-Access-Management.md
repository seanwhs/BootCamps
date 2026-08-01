# Part 2: Zero Trust & Identity-Centric Enterprise Architecture
## Section 2.2: Identity & Access Management (IAM)

## The Target: Complete IAM System for Nexus Global Industries

In this section, we'll implement a comprehensive Identity and Access Management system for Nexus Global Industries, including:

1. **Identity Provider** - Keycloak with OAuth 2.1/OIDC
2. **Federated Identity** - SAML 2.0 and OIDC federation
3. **SCIM 2.0** - Automated Joiner-Mover-Leaver (JML)
4. **RBAC/ABAC** - Role and attribute-based access control

**What specific file(s) are we building?**
- `iam/01_keycloak_configuration.yaml` - Keycloak deployment configuration
- `iam/02_realm_configuration.json` - Keycloak realm export
- `iam/03_scim_automation.py` - SCIM 2.0 JML automation
- `iam/04_rbac_policies.rego` - RBAC/ABAC policies
- `iam/05_iam_integration.md` - Integration guide

---

## The Concept: IAM in Plain English

Think of IAM like **a corporate building's security system**:

**Identity Provider (Keycloak):** "The main security desk where everyone gets their ID badge." This centralizes all identities.

**OAuth 2.1/OIDC:** "The standardized protocol that lets your ID badge work at any door in the building." This enables single sign-on.

**SCIM 2.0:** "The automated system that creates, updates, and deletes badges when people join, move, or leave." This automates identity lifecycle.

**RBAC (Role-Based Access Control):** "You have a badge that says 'Manager' which lets you access the manager's lounge." This grants permissions based on role.

**ABAC (Attribute-Based Access Control):** "Your badge lets you into the R&D lab, but only if you're wearing safety goggles (device) and it's between 9 AM and 5 PM (context)." This grants permissions based on multiple attributes.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the IAM directory
cd ~/nexus_security_architecture
mkdir -p iam

# Verify the structure
ls -la
# Expected: iam directory appears
```

---

### Step 2: Keycloak Deployment Configuration

**File:** `iam/01_keycloak_configuration.yaml`

```yaml
# Keycloak Deployment Configuration - Nexus Global Industries
# File: iam/01_keycloak_configuration.yaml
# Version: 1.0

# ====================================================================
# PART 1: KEYCLOAK DEPLOYMENT
# ====================================================================

---
# Namespace for Keycloak
apiVersion: v1
kind: Namespace
metadata:
  name: keycloak
  labels:
    name: keycloak
    security.istio.io/tlsMode: "istio"

---
# ConfigMap for Keycloak configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: keycloak-config
  namespace: keycloak
data:
  KEYCLOAK_IMPORT: /opt/keycloak/data/import/realm.json
  KEYCLOAK_HOSTNAME: auth.nexus.com
  KEYCLOAK_HTTPS_PORT: "8443"
  KEYCLOAK_ADMIN: admin
  KEYCLOAK_METRICS_ENABLED: "true"
  KEYCLOAK_LOG_LEVEL: INFO
  PROXY_ADDRESS_FORWARDING: "true"

---
# Secret for Keycloak admin credentials
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-admin
  namespace: keycloak
type: Opaque
data:
  # In production, use sealed secrets or external secret management
  # These are base64-encoded values
  admin-password: "bmV4dXMtY2xvdWQtMjAyNiEh"  # nexus-cloud-2026!!
  admin-user: "YWRtaW4="                    # admin

---
# PostgreSQL Database for Keycloak
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-db
  namespace: keycloak
type: Opaque
data:
  database-user: "a2V5Y2xvYWs="           # keycloak
  database-password: "cG9zdGdyZXMta2V5Y2xvYWs="  # postgres-keycloak

---
# Service for PostgreSQL
apiVersion: v1
kind: Service
metadata:
  name: keycloak-db
  namespace: keycloak
  labels:
    app: keycloak-db
spec:
  selector:
    app: keycloak-db
  ports:
  - name: postgres
    port: 5432
    targetPort: 5432

---
# StatefulSet for PostgreSQL
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: keycloak-db
  namespace: keycloak
spec:
  serviceName: keycloak-db
  replicas: 1
  selector:
    matchLabels:
      app: keycloak-db
  template:
    metadata:
      labels:
        app: keycloak-db
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          value: keycloak
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: keycloak-db
              key: database-user
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: keycloak-db
              key: database-password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi

---
# Service for Keycloak
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
  annotations:
    # Required for Istio mTLS
    "security.istio.io/tlsMode": "istio"
spec:
  selector:
    app: keycloak
  ports:
  - name: http
    port: 8080
    targetPort: 8080
  - name: https
    port: 8443
    targetPort: 8443

---
# Deployment for Keycloak
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  namespace: keycloak
  labels:
    app: keycloak
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
      annotations:
        # Enable Istio sidecar injection
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak:23.0.7
        args: ["start", "--optimized"]
        env:
        - name: KEYCLOAK_ADMIN
          valueFrom:
            secretKeyRef:
              name: keycloak-admin
              key: admin-user
        - name: KEYCLOAK_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: keycloak-admin
              key: admin-password
        - name: KC_DB
          value: "postgres"
        - name: KC_DB_URL
          value: "jdbc:postgresql://keycloak-db:5432/keycloak"
        - name: KC_DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: keycloak-db
              key: database-user
        - name: KC_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: keycloak-db
              key: database-password
        - name: KC_HOSTNAME
          value: "auth.nexus.com"
        - name: KC_HTTPS_CERTIFICATE_FILE
          value: "/etc/x509/https/tls.crt"
        - name: KC_HTTPS_CERTIFICATE_KEY_FILE
          value: "/etc/x509/https/tls.key"
        - name: KC_SPI_TRUSTSTORE_FILE
          value: "/etc/ssl/certs/java/cacerts"
        - name: KC_SPI_TRUSTSTORE_PASSWORD
          value: "changeit"
        - name: KC_PROXY
          value: "edge"
        - name: KC_HTTP_ENABLED
          value: "true"
        - name: KC_METRICS_ENABLED
          value: "true"
        - name: KC_HEALTH_ENABLED
          value: "true"
        - name: KC_LOG_LEVEL
          value: "INFO"
        ports:
        - name: http
          containerPort: 8080
        - name: https
          containerPort: 8443
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        volumeMounts:
        - name: keycloak-import
          mountPath: /opt/keycloak/data/import
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
      volumes:
      - name: keycloak-import
        configMap:
          name: keycloak-realm
      # TLS certificates mounted from Istio
      - name: istio-certs
        secret:
          secretName: istio-ingressgateway-certs
          optional: true

---
# Istio VirtualService for Keycloak
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: keycloak
  namespace: keycloak
spec:
  hosts:
  - "auth.nexus.com"
  gateways:
  - istio-system/ingress-gateway
  http:
  - match:
    - uri:
        prefix: "/"
    route:
    - destination:
        host: keycloak
        port:
          number: 8080

---
# Istio DestinationRule for Keycloak
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: keycloak
  namespace: keycloak
spec:
  host: keycloak
  trafficPolicy:
    tls:
      mode: DISABLE
    connectionPool:
      tcp:
        maxConnections: 100
    loadBalancer:
      simple: ROUND_ROBIN
```

**Verification:**

```bash
# Verify Keycloak configuration file
ls -la iam/01_keycloak_configuration.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('iam/01_keycloak_configuration.yaml'))"
# Expected: No error output

# Count Kubernetes resources
grep -c "apiVersion:" iam/01_keycloak_configuration.yaml
# Expected: Shows 8+ resources
```

---

### Step 3: Keycloak Realm Configuration

**File:** `iam/02_realm_configuration.json`

```json
{
  "realm": "nexus",
  "displayName": "Nexus Global Industries",
  "displayNameHtml": "<b>Nexus</b> Global Industries",
  "enabled": true,
  "loginWithEmailAllowed": true,
  "duplicateEmailsAllowed": false,
  "resetPasswordAllowed": true,
  "editUsernameAllowed": false,
  "rememberMe": true,
  "sslRequired": "external",
  "registrationAllowed": false,
  "registrationEmailAsUsername": true,
  "defaultRoles": ["offline_access", "uma_authorization"],
  "defaultDefaultClientScopes": ["openid", "profile", "email", "roles"],
  "defaultOptionalClientScopes": ["address", "phone", "offline_access"],
  "browserFlow": "browser",
  "registrationFlow": "registration",
  "directGrantFlow": "direct grant",
  "resetCredentialsFlow": "reset credentials",
  "clientAuthenticationFlow": "clients",
  "dummyClientScopes": [],
  "otpPolicyType": "totp",
  "otpPolicyAlgorithm": "HmacSHA1",
  "otpPolicyDigits": 6,
  "otpPolicyPeriod": 30,
  "otpPolicyOtpHashAlgorithm": "SHA1",
  "otpPolicyCodeReusable": false,
  "bruteForceProtected": true,
  "failureFactor": 5,
  "waitIncrementSeconds": 60,
  "maxFailureWaitSeconds": 900,
  "minimumQuickLoginWaitSeconds": 60,
  "quickLoginCheckMilliSeconds": 1000,
  "maxDeltaTimeSeconds": 43200,

  "passwordPolicy": "length(12) and digits and lowerCase and upperCase and specialChars and notUsername",
  
  "requiredCredentials": ["password", "otp"],
  
  "authenticationFlows": [
    {
      "id": "browser-flow",
      "alias": "browser",
      "description": "Browser based authentication",
      "providerId": "basic-flow",
      "topLevel": true,
      "builtIn": true,
      "authenticationExecutions": [
        {
          "authenticator": "auth-cookie",
          "requirement": "ALTERNATIVE",
          "priority": 10
        },
        {
          "authenticator": "auth-spnego",
          "requirement": "DISABLED",
          "priority": 20
        },
        {
          "authenticator": "identity-provider-redirector",
          "requirement": "ALTERNATIVE",
          "priority": 25
        },
        {
          "authenticator": "forms",
          "requirement": "REQUIRED",
          "priority": 30
        }
      ]
    }
  ],

  "authenticatorConfig": [
    {
      "alias": "otp-form",
      "config": {
        "otpLabel": "Nexus Global"
      }
    }
  ],

  "clients": [
    {
      "clientId": "customer-portal",
      "name": "Customer Portal",
      "description": "B2B Customer Portal Application",
      "enabled": true,
      "alwaysDisplayInConsole": false,
      "clientAuthenticatorType": "client-secret",
      "secret": "customer-portal-secret-12345",
      "redirectUris": [
        "https://portal.nexus.com/*",
        "https://portal.nexus.com/api/*",
        "https://staging.portal.nexus.com/*"
      ],
      "webOrigins": [
        "https://portal.nexus.com",
        "https://staging.portal.nexus.com"
      ],
      "notBefore": 0,
      "bearerOnly": false,
      "consentRequired": false,
      "standardFlowEnabled": true,
      "implicitFlowEnabled": false,
      "directAccessGrantsEnabled": true,
      "serviceAccountsEnabled": true,
      "authorizationServicesEnabled": true,
      "publicClient": false,
      "frontchannelLogout": true,
      "protocol": "openid-connect",
      "attributes": {
        "saml.assertion.signature": "false",
        "saml.force.post.binding": "false",
        "saml.multivalued.roles": "false",
        "saml.encrypt": "false",
        "saml.server.signature": "false",
        "saml.server.signature.keyinfo.ext": "false",
        "exclude.session.state.from.auth.response": "false",
        "saml_force_name_id_format": "false",
        "saml.client.signature": "false",
        "tls.client.certificate.bound.access.tokens": "false",
        "saml.authnstatement": "false",
        "display.on.consent.screen": "false",
        "saml.onetimeuse.condition": "false",
        "access.token.lifespan": "900",
        "saml.metadata.name.id.format": "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
        "client.secret.creation.time": "2026-08-02T00:00:00Z"
      },
      "authenticationFlowBindingOverrides": {},
      "fullScopeAllowed": true,
      "nodeReRegistrationTimeout": -1,
      "protocolMappers": [
        {
          "name": "email",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-usermodel-property-mapper",
          "consentRequired": false,
          "config": {
            "userinfo.token.claim": "true",
            "user.attribute": "email",
            "id.token.claim": "true",
            "access.token.claim": "true",
            "claim.name": "email",
            "jsonType.label": "String"
          }
        },
        {
          "name": "roles",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-usermodel-realm-role-mapper",
          "consentRequired": false,
          "config": {
            "user.attribute": "foo",
            "access.token.claim": "true",
            "claim.name": "roles",
            "jsonType.label": "String",
            "multivalued": "true"
          }
        },
        {
          "name": "groups",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-group-membership-mapper",
          "consentRequired": false,
          "config": {
            "access.token.claim": "true",
            "claim.name": "groups",
            "id.token.claim": "true",
            "jsonType.label": "String",
            "multivalued": "true"
          }
        },
        {
          "name": "full name",
          "protocol": "openid-connect",
          "protocolMapper": "oidc-full-name-mapper",
          "consentRequired": false,
          "config": {
            "id.token.claim": "true",
            "access.token.claim": "true",
            "userinfo.token.claim": "true"
          }
        }
      ]
    },
    {
      "clientId": "rd-systems",
      "name": "R&D Systems",
      "description": "R&D Code Repository and CI/CD Systems",
      "enabled": true,
      "clientAuthenticatorType": "client-secret",
      "secret": "rd-systems-secret-67890",
      "redirectUris": [
        "https://gitlab.nexus.com/*",
        "https://jenkins.nexus.com/*"
      ],
      "webOrigins": [
        "https://gitlab.nexus.com",
        "https://jenkins.nexus.com"
      ],
      "notBefore": 0,
      "bearerOnly": false,
      "consentRequired": false,
      "standardFlowEnabled": true,
      "implicitFlowEnabled": false,
      "directAccessGrantsEnabled": true,
      "serviceAccountsEnabled": true,
      "publicClient": false,
      "frontchannelLogout": true,
      "protocol": "openid-connect"
    },
    {
      "clientId": "api-gateway",
      "name": "API Gateway",
      "description": "Kong API Gateway for Zero Trust Enforcement",
      "enabled": true,
      "clientAuthenticatorType": "client-secret",
      "secret": "api-gateway-secret-abcde",
      "redirectUris": [],
      "notBefore": 0,
      "bearerOnly": false,
      "consentRequired": false,
      "standardFlowEnabled": false,
      "implicitFlowEnabled": false,
      "directAccessGrantsEnabled": false,
      "serviceAccountsEnabled": true,
      "publicClient": false,
      "frontchannelLogout": false,
      "protocol": "openid-connect"
    }
  ],

  "users": [
    {
      "username": "jdoe",
      "email": "jdoe@nexus.com",
      "firstName": "John",
      "lastName": "Doe",
      "enabled": true,
      "emailVerified": true,
      "credentials": [
        {
          "type": "password",
          "value": "Nexus2026!Secure",
          "temporary": false
        },
        {
          "type": "otp",
          "value": "totp-verification"
        }
      ],
      "realmRoles": ["admin", "rd-engineer"],
      "groups": ["rd-team", "security-team"],
      "attributes": {
        "department": ["R&D"],
        "clearance": ["restricted"],
        "mfa_enabled": ["true"]
      }
    },
    {
      "username": "asmith",
      "email": "asmith@nexus.com",
      "firstName": "Alice",
      "lastName": "Smith",
      "enabled": true,
      "emailVerified": true,
      "credentials": [
        {
          "type": "password",
          "value": "Nexus2026!Secure",
          "temporary": false
        },
        {
          "type": "otp",
          "value": "totp-verification"
        }
      ],
      "realmRoles": ["finance"],
      "groups": ["finance-team"],
      "attributes": {
        "department": ["Finance"],
        "clearance": ["confidential"],
        "mfa_enabled": ["true"]
      }
    },
    {
      "username": "rpatel",
      "email": "rpatel@nexus.com",
      "firstName": "Raj",
      "lastName": "Patel",
      "enabled": true,
      "emailVerified": true,
      "credentials": [
        {
          "type": "password",
          "value": "Nexus2026!Secure",
          "temporary": false
        },
        {
          "type": "otp",
          "value": "totp-verification"
        }
      ],
      "realmRoles": ["rd-manager"],
      "groups": ["rd-team"],
      "attributes": {
        "department": ["R&D"],
        "clearance": ["restricted"],
        "mfa_enabled": ["true"]
      }
    }
  ],

  "groups": [
    {
      "name": "rd-team",
      "path": "/rd-team",
      "attributes": {
        "access_level": ["restricted"],
        "department": ["R&D"]
      }
    },
    {
      "name": "security-team",
      "path": "/security-team",
      "attributes": {
        "access_level": ["restricted"],
        "department": ["Security"]
      }
    },
    {
      "name": "finance-team",
      "path": "/finance-team",
      "attributes": {
        "access_level": ["confidential"],
        "department": ["Finance"]
      }
    },
    {
      "name": "engineering-team",
      "path": "/engineering-team",
      "attributes": {
        "access_level": ["internal"],
        "department": ["Engineering"]
      }
    }
  ],

  "roles": {
    "realm": [
      {
        "name": "admin",
        "description": "Full administrative access",
        "composite": true,
        "composites": {
          "realm": ["security-team"]
        }
      },
      {
        "name": "security-team",
        "description": "Security team members"
      },
      {
        "name": "rd-engineer",
        "description": "R&D engineers with code access"
      },
      {
        "name": "rd-manager",
        "description": "R&D managers with approval privileges"
      },
      {
        "name": "finance",
        "description": "Finance team members"
      },
      {
        "name": "hr",
        "description": "HR team members"
      },
      {
        "name": "support",
        "description": "Customer support team"
      },
      {
        "name": "customer",
        "description": "External customers with portal access"
      }
    ]
  },

  "identityProviders": [
    {
      "alias": "azure-ad",
      "displayName": "Azure AD",
      "providerId": "saml",
      "enabled": true,
      "firstBrokerLoginFlowAlias": "first broker login",
      "config": {
        "singleSignOnServiceUrl": "https://login.microsoftonline.com/tenant-id/saml2",
        "nameIDPolicyFormat": "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
        "principalType": "ATTRIBUTE",
        "principalAttribute": "email",
        "emailAttribute": "email",
        "userAttribute": "email",
        "validateSignature": "true",
        "allowCreate": "true"
      }
    }
  ],

  "components": {
    "org.keycloak.services.clientregistration.policy.ClientRegistrationPolicy": [
      {
        "name": "Allowed Protocol Mapper Types",
        "providerId": "allowed-protocol-mappers",
        "subType": "anonymous",
        "subComponents": {},
        "config": {
          "allowed-protocol-mapper-types": [
            "oidc-address-mapper",
            "oidc-full-name-mapper",
            "oidc-sha256-pairwise-sub-mapper",
            "saml-role-list-mapper",
            "saml-user-attribute-mapper",
            "saml-user-property-mapper",
            "oidc-usermodel-attribute-mapper",
            "oidc-group-membership-mapper",
            "oidc-usermodel-property-mapper"
          ]
        }
      }
    ]
  },

  "userFederation": [
    {
      "name": "LDAP Federation",
      "providerId": "ldap",
      "config": {
        "enabled": ["true"],
        "priority": ["10"],
        "fullSyncPeriod": ["604800"],
        "changedSyncPeriod": ["3600"],
        "connectionUrl": ["ldap://ldap.nexus.com:389"],
        "usersDn": ["ou=users,dc=nexus,dc=com"],
        "authType": ["simple"],
        "bindDn": ["cn=admin,dc=nexus,dc=com"],
        "bindCredential": ["ldap-admin-password"],
        "customUserSearchFilter": ["(objectClass=person)"],
        "userObjectClasses": ["person,organizationalPerson,user"],
        "usernameLDAPAttribute": ["uid"],
        "rdnLDAPAttribute": ["uid"],
        "uuidLDAPAttribute": ["entryUUID"],
        "userPasswordLDAPAttribute": ["userPassword"],
        "editMode": ["READ_ONLY"],
        "vendor": ["other"],
        "useTruststoreSpi": ["ldapsOnly"],
        "connectionTimeout": ["5000"],
        "readTimeout": ["5000"],
        "pagination": ["true"],
        "batchSizeForSync": ["1000"],
        "fullSyncPeriod": ["604800"],
        "changedSyncPeriod": ["3600"],
        "cachePolicy": ["DEFAULT"],
        "evictionDay": [],
        "evictionHour": [],
        "evictionMinute": [],
        "maxLifespan": []
      }
    }
  ],

  "samlSpi": {
    "defaultSignatureAlgorithm": "RSA_SHA256",
    "defaultCanonicalizationMethod": "http://www.w3.org/2001/10/xml-exc-c14n#",
    "defaultNameIdFormat": "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  },

  "oidcSpi": {
    "defaultSignatureAlgorithm": "RS256",
    "userInfoToken": "true"
  },

  "smtpServer": {
    "host": "smtp.nexus.com",
    "port": "587",
    "auth": true,
    "ssl": false,
    "starttls": true,
    "user": "security@nexus.com",
    "password": "smtp-password-secret"
  }
}
```

**Verification:**

```bash
# Verify Keycloak realm configuration
ls -la iam/02_realm_configuration.json
# Expected: File exists

# Validate JSON syntax
python3 -c "import json; json.load(open('iam/02_realm_configuration.json'))"
# Expected: No error output

# Check for clients
grep -c '"clientId"' iam/02_realm_configuration.json
# Expected: Shows 3+ clients

# Check for users
grep -c '"username"' iam/02_realm_configuration.json
# Expected: Shows 3+ users
```

---

### Step 4: SCIM 2.0 Automation for JML

**File:** `iam/03_scim_automation.py`

```python
#!/usr/bin/env python3
"""
SCIM 2.0 Automation for Joiner-Mover-Leaver (JML) - Nexus Global Industries
File: iam/03_scim_automation.py
Version: 1.0

This service automates identity lifecycle management using SCIM 2.0 protocol.
It integrates with Workday HRIS and Keycloak IdP.
"""

import os
import json
import logging
import hashlib
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from enum import Enum

import requests
import redis
from flask import Flask, request, jsonify
from flask_cors import CORS
import schedule
import time
import threading

# ====================================================================
# Configuration
# ====================================================================

CONFIG = {
    "WORKDAY_API_URL": os.getenv("WORKDAY_API_URL", "https://workday.nexus.com/api/v1"),
    "WORKDAY_API_KEY": os.getenv("WORKDAY_API_KEY", "workday-api-key"),
    "KEYCLOAK_URL": os.getenv("KEYCLOAK_URL", "https://auth.nexus.com"),
    "KEYCLOAK_ADMIN_USER": os.getenv("KEYCLOAK_ADMIN_USER", "admin"),
    "KEYCLOAK_ADMIN_PASSWORD": os.getenv("KEYCLOAK_ADMIN_PASSWORD", "nexus-cloud-2026!!"),
    "KEYCLOAK_REALM": os.getenv("KEYCLOAK_REALM", "nexus"),
    "SCIM_ENDPOINT": os.getenv("SCIM_ENDPOINT", "https://auth.nexus.com/admin/realms/nexus/scim/v2"),
    "REDIS_URL": os.getenv("REDIS_URL", "redis://redis.default.svc.cluster.local:6379/0"),
    "SYNC_INTERVAL": int(os.getenv("SYNC_INTERVAL", "300")),  # 5 minutes
    "LOG_LEVEL": os.getenv("LOG_LEVEL", "INFO"),
}

# ====================================================================
# Logging Setup
# ====================================================================

logging.basicConfig(
    level=getattr(logging, CONFIG["LOG_LEVEL"]),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ====================================================================
# Data Models
# ====================================================================

class EventType(Enum):
    JOINER = "JOINER"
    MOVER = "MOVER"
    LEAVER = "LEAVER"
    UPDATE = "UPDATE"

@dataclass
class UserEvent:
    """User lifecycle event from HRIS."""
    event_type: EventType
    employee_id: str
    email: str
    first_name: str
    last_name: str
    roles: List[str]
    department: str
    manager_email: Optional[str]
    start_date: datetime
    end_date: Optional[datetime]
    attributes: Dict[str, Any]

@dataclass
class SCIMUser:
    """SCIM 2.0 user representation."""
    schemas: List[str]
    userName: str
    name: Dict[str, str]
    emails: List[Dict[str, Any]]
    groups: List[Dict[str, str]]
    roles: List[Dict[str, Any]]
    active: bool
    meta: Dict[str, Any]

@dataclass
class SCIMGroup:
    """SCIM 2.0 group representation."""
    schemas: List[str]
    displayName: str
    members: List[Dict[str, str]]

# ====================================================================
# SCIM Automation Service
# ====================================================================

class SCIMAutomation:
    """
    SCIM 2.0 automation for Joiner-Mover-Leaver (JML) lifecycle management.
    """
    
    def __init__(self):
        """Initialize the SCIM automation service."""
        # Redis connection for caching
        self.redis_client = redis.from_url(CONFIG["REDIS_URL"])
        
        # Keycloak admin token
        self.keycloak_token = None
        self.token_expiry = None
        
        # Get initial token
        self._refresh_keycloak_token()
        
        # Start background sync thread
        self._start_sync_thread()
        
        logger.info("SCIM Automation Service initialized")
    
    def _refresh_keycloak_token(self) -> None:
        """Refresh Keycloak admin token."""
        try:
            token_url = f"{CONFIG['KEYCLOAK_URL']}/realms/master/protocol/openid-connect/token"
            data = {
                "client_id": "admin-cli",
                "username": CONFIG["KEYCLOAK_ADMIN_USER"],
                "password": CONFIG["KEYCLOAK_ADMIN_PASSWORD"],
                "grant_type": "password"
            }
            response = requests.post(token_url, data=data, timeout=10)
            response.raise_for_status()
            token_data = response.json()
            self.keycloak_token = token_data["access_token"]
            self.token_expiry = datetime.utcnow() + timedelta(seconds=token_data["expires_in"] - 60)
            logger.info("Keycloak token refreshed")
        except Exception as e:
            logger.error(f"Failed to refresh Keycloak token: {e}")
            raise
    
    def _ensure_token_valid(self) -> None:
        """Ensure Keycloak token is valid, refresh if needed."""
        if not self.keycloak_token or datetime.utcnow() >= self.token_expiry:
            self._refresh_keycloak_token()
    
    def _get_scim_headers(self) -> Dict[str, str]:
        """Get headers for SCIM API calls."""
        self._ensure_token_valid()
        return {
            "Authorization": f"Bearer {self.keycloak_token}",
            "Content-Type": "application/scim+json",
            "Accept": "application/scim+json"
        }
    
    # ====================================================================
    # SCIM User Operations
    # ====================================================================
    
    def create_user(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new user via SCIM.
        
        Args:
            user_data: User data in SCIM format
            
        Returns:
            Created user data
        """
        self._ensure_token_valid()
        url = f"{CONFIG['SCIM_ENDPOINT']}/Users"
        headers = self._get_scim_headers()
        
        try:
            response = requests.post(url, json=user_data, headers=headers, timeout=10)
            response.raise_for_status()
            result = response.json()
            logger.info(f"User created: {result.get('userName')}")
            
            # Cache user ID
            user_id = result.get("id")
            username = result.get("userName")
            self.redis_client.setex(f"scim:user:{username}", 3600, user_id)
            
            return result
        except Exception as e:
            logger.error(f"Failed to create user: {e}")
            raise
    
    def update_user(self, user_id: str, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Update an existing user via SCIM.
        
        Args:
            user_id: User ID
            user_data: Updated user data in SCIM format
            
        Returns:
            Updated user data
        """
        self._ensure_token_valid()
        url = f"{CONFIG['SCIM_ENDPOINT']}/Users/{user_id}"
        headers = self._get_scim_headers()
        
        try:
            response = requests.put(url, json=user_data, headers=headers, timeout=10)
            response.raise_for_status()
            result = response.json()
            logger.info(f"User updated: {result.get('userName')}")
            return result
        except Exception as e:
            logger.error(f"Failed to update user {user_id}: {e}")
            raise
    
    def delete_user(self, user_id: str) -> None:
        """
        Delete a user via SCIM.
        
        Args:
            user_id: User ID to delete
        """
        self._ensure_token_valid()
        url = f"{CONFIG['SCIM_ENDPOINT']}/Users/{user_id}"
        headers = self._get_scim_headers()
        
        try:
            response = requests.delete(url, headers=headers, timeout=10)
            response.raise_for_status()
            logger.info(f"User deleted: {user_id}")
        except Exception as e:
            logger.error(f"Failed to delete user {user_id}: {e}")
            raise
    
    def get_user(self, username: str) -> Optional[Dict[str, Any]]:
        """
        Get a user by username via SCIM.
        
        Args:
            username: Username to lookup
            
        Returns:
            User data or None if not found
        """
        self._ensure_token_valid()
        
        # Check cache first
        cached_id = self.redis_client.get(f"scim:user:{username}")
        if cached_id:
            # User exists
            return {"id": cached_id.decode(), "userName": username}
        
        # Query SCIM
        url = f"{CONFIG['SCIM_ENDPOINT']}/Users"
        params = {"filter": f'userName eq "{username}"'}
        headers = self._get_scim_headers()
        
        try:
            response = requests.get(url, params=params, headers=headers, timeout=10)
            response.raise_for_status()
            result = response.json()
            
            if result.get("totalResults", 0) > 0:
                user = result["Resources"][0]
                # Cache user ID
                user_id = user.get("id")
                self.redis_client.setex(f"scim:user:{username}", 3600, user_id)
                return user
            return None
        except Exception as e:
            logger.error(f"Failed to get user {username}: {e}")
            return None
    
    # ====================================================================
    # JML Workflows
    # ====================================================================
    
    def process_joiner(self, event: UserEvent) -> Dict[str, Any]:
        """
        Process a joiner event - create new user with appropriate roles.
        
        Args:
            event: UserEvent with joiner data
            
        Returns:
            Created SCIM user data
        """
        logger.info(f"Processing joiner: {event.email}")
        
        # Build SCIM user
        scim_user = {
            "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
            "userName": event.email,
            "name": {
                "givenName": event.first_name,
                "familyName": event.last_name
            },
            "emails": [
                {
                    "value": event.email,
                    "primary": True
                }
            ],
            "active": True,
            "groups": [
                {"display": group} for group in event.roles
            ],
            "roles": [
                {"value": role, "display": role} for role in event.roles
            ],
            "attributes": {
                "department": event.department,
                "employee_id": event.employee_id,
                "start_date": event.start_date.isoformat(),
                "manager_email": event.manager_email
            }
        }
        
        # Create user in Keycloak via SCIM
        created_user = self.create_user(scim_user)
        
        # Log to SIEM
        self._log_jml_event(event, "CREATED", created_user)
        
        # Send welcome email (simulated)
        self._send_welcome_email(event)
        
        return created_user
    
    def process_mover(self, event: UserEvent) -> Dict[str, Any]:
        """
        Process a mover event - update user roles and attributes.
        
        Args:
            event: UserEvent with mover data
            
        Returns:
            Updated SCIM user data
        """
        logger.info(f"Processing mover: {event.email}")
        
        # Get existing user
        existing_user = self.get_user(event.email)
        if not existing_user:
            logger.warning(f"User not found for mover: {event.email}")
            return self.process_joiner(event)
        
        # Update user data
        user_id = existing_user["id"]
        scim_user = {
            "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
            "userName": event.email,
            "name": {
                "givenName": event.first_name,
                "familyName": event.last_name
            },
            "emails": [
                {
                    "value": event.email,
                    "primary": True
                }
            ],
            "active": True,
            "groups": [
                {"display": group} for group in event.roles
            ],
            "roles": [
                {"value": role, "display": role} for role in event.roles
            ],
            "attributes": {
                "department": event.department,
                "employee_id": event.employee_id,
                "manager_email": event.manager_email
            }
        }
        
        # Update user
        updated_user = self.update_user(user_id, scim_user)
        
        # Log to SIEM
        self._log_jml_event(event, "UPDATED", updated_user)
        
        return updated_user
    
    def process_leaver(self, event: UserEvent) -> None:
        """
        Process a leaver event - deactivate or delete user.
        
        Args:
            event: UserEvent with leaver data
        """
        logger.info(f"Processing leaver: {event.email}")
        
        # Get existing user
        existing_user = self.get_user(event.email)
        if not existing_user:
            logger.warning(f"User not found for leaver: {event.email}")
            return
        
        user_id = existing_user["id"]
        
        # Option 1: Deactivate user (retain data)
        if event.attributes.get("deactivate_only", True):
            # Deactivate user
            scim_user = {
                "schemas": ["urn:ietf:params:scim:schemas:core:2.0:User"],
                "active": False
            }
            self.update_user(user_id, scim_user)
            logger.info(f"User deactivated: {event.email}")
        else:
            # Delete user
            self.delete_user(user_id)
            logger.info(f"User deleted: {event.email}")
        
        # Log to SIEM
        self._log_jml_event(event, "DEACTIVATED" if event.attributes.get("deactivate_only", True) else "DELETED", None)
        
        # Remove from cache
        self.redis_client.delete(f"scim:user:{event.email}")
        
        # Send offboarding notification
        self._send_offboarding_notification(event)
    
    # ====================================================================
    # HRIS Integration
    # ====================================================================
    
    def sync_from_hris(self) -> List[Dict[str, Any]]:
        """
        Sync user lifecycle events from Workday HRIS.
        
        Returns:
            List of processed user events
        """
        logger.info("Syncing from HRIS...")
        processed_events = []
        
        try:
            # Fetch events from Workday
            events = self._fetch_hris_events()
            
            for event_data in events:
                event = self._parse_hris_event(event_data)
                
                if event.event_type == EventType.JOINER:
                    self.process_joiner(event)
                elif event.event_type == EventType.MOVER:
                    self.process_mover(event)
                elif event.event_type == EventType.LEAVER:
                    self.process_leaver(event)
                elif event.event_type == EventType.UPDATE:
                    # General update
                    self.process_mover(event)
                
                processed_events.append(asdict(event))
            
            logger.info(f"HRIS sync complete: {len(processed_events)} events processed")
            return processed_events
            
        except Exception as e:
            logger.error(f"Error syncing from HRIS: {e}")
            return []
    
    def _fetch_hris_events(self) -> List[Dict[str, Any]]:
        """Fetch employee lifecycle events from Workday."""
        # In production, this would call Workday API
        # For demo, return sample events since last sync
        
        last_sync = self.redis_client.get("hris:last_sync")
        last_sync_time = datetime.fromisoformat(last_sync.decode()) if last_sync else datetime.utcnow() - timedelta(days=1)
        
        # Simulated events from Workday
        sample_events = [
            {
                "event_type": "JOINER",
                "employee_id": "EMP-2026-001",
                "email": "newhire@nexus.com",
                "first_name": "New",
                "last_name": "Hire",
                "roles": ["engineer"],
                "department": "Engineering",
                "manager_email": "manager@nexus.com",
                "start_date": datetime.utcnow().isoformat()
            }
        ]
        
        # Filter events since last sync
        filtered_events = [
            event for event in sample_events
            if datetime.fromisoformat(event.get("start_date", datetime.utcnow().isoformat())) > last_sync_time
        ]
        
        # Update last sync time
        self.redis_client.setex("hris:last_sync", 86400, datetime.utcnow().isoformat())
        
        return filtered_events
    
    def _parse_hris_event(self, event_data: Dict[str, Any]) -> UserEvent:
        """Parse HRIS event data into UserEvent object."""
        event_type_map = {
            "JOINER": EventType.JOINER,
            "MOVER": EventType.MOVER,
            "LEAVER": EventType.LEAVER,
            "UPDATE": EventType.UPDATE
        }
        
        return UserEvent(
            event_type=event_type_map.get(event_data.get("event_type"), EventType.UPDATE),
            employee_id=event_data.get("employee_id", ""),
            email=event_data.get("email", ""),
            first_name=event_data.get("first_name", ""),
            last_name=event_data.get("last_name", ""),
            roles=event_data.get("roles", []),
            department=event_data.get("department", ""),
            manager_email=event_data.get("manager_email"),
            start_date=datetime.fromisoformat(event_data.get("start_date", datetime.utcnow().isoformat())),
            end_date=datetime.fromisoformat(event_data.get("end_date")) if event_data.get("end_date") else None,
            attributes=event_data.get("attributes", {})
        )
    
    # ====================================================================
    # Audit and Logging
    # ====================================================================
    
    def _log_jml_event(self, event: UserEvent, action: str, user_data: Optional[Dict[str, Any]]) -> None:
        """Log JML event to SIEM."""
        log_data = {
            "event_type": "jml_event",
            "action": action,
            "employee_id": event.employee_id,
            "email": event.email,
            "first_name": event.first_name,
            "last_name": event.last_name,
            "roles": event.roles,
            "department": event.department,
            "timestamp": datetime.utcnow().isoformat(),
            "user_data": user_data
        }
        
        logger.info(f"JML Event: {json.dumps(log_data)}")
        
        # In production, send to SIEM
        # requests.post(CONFIG["SIEM_ENDPOINT"], json=log_data)
    
    def _send_welcome_email(self, event: UserEvent) -> None:
        """Send welcome email to new hire."""
        # In production, this would send via SMTP
        logger.info(f"Welcome email sent to: {event.email}")
        
        # Simulate email content
        email_content = f"""
        Welcome to Nexus Global Industries, {event.first_name}!
        
        Your account has been created with the following roles: {', '.join(event.roles)}
        
        Please set up your MFA at: {CONFIG['KEYCLOAK_URL']}
        
        Department: {event.department}
        Manager: {event.manager_email}
        
        Welcome to the team!
        """
        logger.debug(f"Email content: {email_content}")
    
    def _send_offboarding_notification(self, event: UserEvent) -> None:
        """Send offboarding notification."""
        # In production, this would send via SMTP
        logger.info(f"Offboarding notification sent for: {event.email}")
    
    # ====================================================================
    # Background Sync
    # ====================================================================
    
    def _start_sync_thread(self) -> None:
        """Start background thread for periodic sync."""
        def sync_loop():
            while True:
                try:
                    self.sync_from_hris()
                    time.sleep(CONFIG["SYNC_INTERVAL"])
                except Exception as e:
                    logger.error(f"Error in sync loop: {e}")
                    time.sleep(60)
        
        thread = threading.Thread(target=sync_loop, daemon=True)
        thread.start()
        logger.info("Background sync thread started")

# ====================================================================
# Flask Web API
# ====================================================================

app = Flask(__name__)
CORS(app)
scim_service = SCIMAutomation()

@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint."""
    return jsonify({"status": "healthy", "service": "scim-automation"})

@app.route("/api/scim/users", methods=["POST"])
def create_user():
    """Create a new user via SCIM."""
    try:
        user_data = request.json
        result = scim_service.create_user(user_data)
        return jsonify(result), 201
    except Exception as e:
        logger.error(f"Error creating user: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/scim/users/<user_id>", methods=["PUT"])
def update_user(user_id: str):
    """Update an existing user via SCIM."""
    try:
        user_data = request.json
        result = scim_service.update_user(user_id, user_data)
        return jsonify(result), 200
    except Exception as e:
        logger.error(f"Error updating user: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/scim/users/<user_id>", methods=["DELETE"])
def delete_user(user_id: str):
    """Delete a user via SCIM."""
    try:
        scim_service.delete_user(user_id)
        return jsonify({"deleted": True}), 204
    except Exception as e:
        logger.error(f"Error deleting user: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/sync/hris", methods=["POST"])
def sync_hris():
    """Trigger HRIS sync."""
    try:
        events = scim_service.sync_from_hris()
        return jsonify({"events_processed": len(events), "events": events}), 200
    except Exception as e:
        logger.error(f"Error syncing HRIS: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/api/users/<username>", methods=["GET"])
def get_user(username: str):
    """Get user by username."""
    try:
        user = scim_service.get_user(username)
        if user:
            return jsonify(user), 200
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        logger.error(f"Error getting user: {e}")
        return jsonify({"error": str(e)}), 500

# ====================================================================
# Main Entry Point
# ====================================================================

def main():
    """Main entry point for the service."""
    app.run(host="0.0.0.0", port=8080)

if __name__ == "__main__":
    main()
```

**Verification:**

```bash
# Verify SCIM automation service
ls -la iam/03_scim_automation.py
# Expected: File exists

# Check Python syntax
python3 -m py_compile iam/03_scim_automation.py
# Expected: No syntax errors

# Check for Flask endpoints
grep -c "@app.route" iam/03_scim_automation.py
# Expected: Shows 6+ endpoints

# Check for JML workflows
grep -c "process_joiner" iam/03_scim_automation.py
grep -c "process_mover" iam/03_scim_automation.py
grep -c "process_leaver" iam/03_scim_automation.py
# Expected: Each shows at least 1 occurrence
```

---

### Step 5: RBAC/ABAC Policies

**File:** `iam/04_rbac_policies.rego`

```rego
# RBAC/ABAC Policies - Nexus Global Industries
# File: iam/04_rbac_policies.rego
# Version: 1.0

package nexus.iam

import future.keywords.in

# ====================================================================
# ROLE-BASED ACCESS CONTROL (RBAC)
# ====================================================================

# Role definitions
role_permissions := {
    "admin": {"allowed_resources": ["*"], "allowed_actions": ["*"]},
    "security-team": {"allowed_resources": ["security/*", "audit/*", "incident/*"], "allowed_actions": ["read", "write", "execute"]},
    "rd-engineer": {"allowed_resources": ["rd/*", "repositories/*", "ci-cd/*"], "allowed_actions": ["read", "write"]},
    "rd-manager": {"allowed_resources": ["rd/*", "repositories/*", "ci-cd/*", "approvals/*"], "allowed_actions": ["read", "write", "approve"]},
    "finance": {"allowed_resources": ["finance/*", "payments/*", "accounting/*"], "allowed_actions": ["read", "write"]},
    "hr": {"allowed_resources": ["hr/*", "employees/*", "benefits/*"], "allowed_actions": ["read", "write"]},
    "support": {"allowed_resources": ["support/*", "tickets/*"], "allowed_actions": ["read", "write"]},
    "customer": {"allowed_resources": ["portal/*", "orders/*", "support/*"], "allowed_actions": ["read", "write"]},
}

# Check if user has role
has_role(user, role) := true if {
    role in user.roles
}

# RBAC allow rule
allow_rbac := true if {
    user := input.user
    resource := input.resource
    action := input.action
    
    # Check each role the user has
    some role in user.roles
    permission := role_permissions[role]
    
    # Check if resource is allowed
    resource_allowed := [pattern | pattern in permission.allowed_resources; glob.match(pattern, [], resource)]
    count(resource_allowed) > 0
    
    # Check if action is allowed
    action_allowed := [pattern | pattern in permission.allowed_actions; glob.match(pattern, [], action)]
    count(action_allowed) > 0
}

# ====================================================================
# ATTRIBUTE-BASED ACCESS CONTROL (ABAC)
# ====================================================================

# User attributes
user_attributes := {
    "jdoe": {"department": "R&D", "clearance": "restricted", "mfa_enabled": true, "device_compliant": true},
    "asmith": {"department": "Finance", "clearance": "confidential", "mfa_enabled": true, "device_compliant": true},
    "rpatel": {"department": "R&D", "clearance": "restricted", "mfa_enabled": true, "device_compliant": true},
}

# Resource attributes
resource_attributes := {
    "rd-repository": {"classification": "restricted", "sensitivity": "high", "owner": "rd-team"},
    "finance-data": {"classification": "confidential", "sensitivity": "high", "owner": "finance-team"},
    "customer-portal": {"classification": "internal", "sensitivity": "medium", "owner": "customer-team"},
    "public-docs": {"classification": "public", "sensitivity": "low", "owner": "marketing"},
}

# ABAC allow rule - based on clearance level
allow_abac_clearance := true if {
    user_attr := user_attributes[input.user.username]
    resource_attr := resource_attributes[input.resource.name]
    
    # MFA required for restricted data
    if resource_attr.classification == "restricted" {
        user_attr.mfa_enabled == true
    }
    
    # Clearance level check
    clearance_levels := {"public": 1, "internal": 2, "confidential": 3, "restricted": 4}
    clearance_levels[user_attr.clearance] >= clearance_levels[resource_attr.classification]
}

# ABAC allow rule - based on time and location
allow_abac_context := true if {
    user_attr := user_attributes[input.user.username]
    context := input.context
    
    # Working hours check (for restricted data)
    if user_attr.clearance == "restricted" {
        context.time in working_hours
    }
    
    # Location check (for confidential data)
    if user_attr.clearance == "confidential" {
        context.location == "office" or context.location == "vpn"
    }
}

# Working hours definition
working_hours := {"start": "09:00", "end": "18:00", "days": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]}

# ====================================================================
# COMBINED ACCESS CONTROL
# ====================================================================

# Combined allow rule - requires both RBAC and ABAC for restricted data
allow := true if {
    input.resource.classification == "restricted"
    allow_rbac == true
    allow_abac_clearance == true
    allow_abac_context == true
}

# For non-restricted data, RBAC is sufficient
allow := true if {
    input.resource.classification != "restricted"
    allow_rbac == true
}

# ====================================================================
# PRIVILEGED ACCESS (JIT)
# ====================================================================

# JIT access request
jit_allow := true if {
    input.jit_approved == true
    input.jit_reason != ""
    input.jit_approver in ["rd-manager", "security-team", "admin"]
    input.jit_expiry - time.now_ns() < 900 * 1000000000  # 15 minutes max
}

# Audit rule - all access decisions logged
audit_decision(decision) := true if {
    input.audit.enabled == true
    input.audit.destination == "siem"
    decision in ["allow", "deny"]
}

# ====================================================================
# DEFAULT DENY
# ====================================================================

# Default deny - all requests not explicitly allowed are denied
default allow = false
```

**Verification:**

```bash
# Verify RBAC/ABAC policies
ls -la iam/04_rbac_policies.rego
# Expected: File exists

# Check for RBAC rules
grep -c "allow_rbac" iam/04_rbac_policies.rego
# Expected: Shows at least 1

# Check for ABAC rules
grep -c "allow_abac" iam/04_rbac_policies.rego
# Expected: Shows 2+ ABAC rules

# Validate syntax
# opa check iam/04_rbac_policies.rego
```

---

### Step 6: IAM Integration Guide

**File:** `iam/05_iam_integration.md`

```markdown
# IAM Integration Guide - Nexus Global Industries

## Overview

This document provides integration guidance for the Identity and Access Management system at Nexus Global Industries.

## Components

| Component | Purpose | Technology |
|-----------|---------|------------|
| Identity Provider | Centralized identity management | Keycloak |
| Federation | SSO and identity brokering | SAML 2.0, OIDC |
| SCIM Automation | Identity lifecycle management | SCIM 2.0 |
| Access Control | Authorization policies | RBAC/ABAC |

## Integration Workflows

### Application Integration

#### 1. OIDC Integration (Recommended)

```yaml
# Application OIDC Configuration
client_id: "customer-portal"
client_secret: "customer-portal-secret-12345"
authorization_endpoint: "https://auth.nexus.com/realms/nexus/protocol/openid-connect/auth"
token_endpoint: "https://auth.nexus.com/realms/nexus/protocol/openid-connect/token"
userinfo_endpoint: "https://auth.nexus.com/realms/nexus/protocol/openid-connect/userinfo"
end_session_endpoint: "https://auth.nexus.com/realms/nexus/protocol/openid-connect/logout"
redirect_uris:
  - "https://portal.nexus.com/*"
  - "https://portal.nexus.com/api/*"
scopes:
  - "openid"
  - "profile"
  - "email"
  - "roles"
  - "groups"
```

#### 2. SAML 2.0 Integration

```xml
<!-- SAML Service Provider Configuration -->
<EntityDescriptor entityID="https://portal.nexus.com/saml2">
  <SPSSODescriptor>
    <AssertionConsumerService>
      <Location>https://portal.nexus.com/saml2/acs</Location>
    </AssertionConsumerService>
    <AttributeConsumingService>
      <Attribute Name="email"/>
      <Attribute Name="firstName"/>
      <Attribute Name="lastName"/>
      <Attribute Name="roles"/>
    </AttributeConsumingService>
  </SPSSODescriptor>
</EntityDescriptor>
```

### SCIM Integration

#### Webhook Configuration

```yaml
# SCIM Endpoints
base_url: "https://auth.nexus.com/admin/realms/nexus/scim/v2"
auth_header: "Authorization: Bearer <token>"

# User Operations
create_user: "POST /Users"
update_user: "PUT /Users/{id}"
delete_user: "DELETE /Users/{id}"
get_user: "GET /Users?filter=userName eq '{username}'"

# Group Operations
create_group: "POST /Groups"
update_group: "PUT /Groups/{id}"
delete_group: "DELETE /Groups/{id}"
```

### API Gateway Integration (Kong)

```yaml
# Kong OIDC Plugin Configuration
plugins:
  - name: oidc
    config:
      client_id: "api-gateway"
      client_secret: "api-gateway-secret-abcde"
      discovery: "https://auth.nexus.com/realms/nexus/.well-known/openid-configuration"
      scope: "openid profile email"
      redirect_uri: "https://api.nexus.com/callback"
      logout_uri: "https://api.nexus.com/logout"
```

## Deployment Checklist

### Phase 1: Core IAM Deployment

- [ ] Keycloak deployed (3 replicas)
- [ ] PostgreSQL database configured
- [ ] Realm configuration imported
- [ ] Admin credentials secured
- [ ] TLS certificates configured
- [ ] Istio integration enabled

### Phase 2: Application Integration

- [ ] OIDC clients configured
- [ ] SAML applications configured
- [ ] SCIM endpoints configured
- [ ] API Gateway OIDC enabled
- [ ] Test applications integrated

### Phase 3: SCIM Automation

- [ ] SCIM service deployed
- [ ] HRIS integration configured
- [ ] JML workflows tested
- [ ] Welcome emails configured
- [ ] Offboarding notifications enabled

### Phase 4: Access Control

- [ ] RBAC roles defined
- [ ] ABAC attributes configured
- [ ] OPA policies deployed
- [ ] Access reviews scheduled
- [ ] Audit logging enabled

## User Lifecycle Workflow

### Joiner (New Employee)

```
HRIS → Workday → SCIM Automation → Keycloak → Groups/Roles → Email/Slack
1. Employee created in Workday
2. SCIM polls or receives webhook
3. User created in Keycloak
4. Groups and roles assigned
5. Welcome email sent
6. MFA enrollment initiated
```

### Mover (Role Change)

```
HRIS → Workday → SCIM Automation → Keycloak → Groups/Roles → Audit
1. Employee role change in Workday
2. SCIM receives update
3. User updated in Keycloak
4. New groups/roles assigned
5. Old permissions revoked
6. Access audit triggered
```

### Leaver (Offboarding)

```
HRIS → Workday → SCIM Automation → Keycloak → Groups/Roles → Audit
1. Employee terminated in Workday
2. SCIM receives event
3. User deactivated in Keycloak
4. All sessions revoked
5. Access revoked
6. Offboarding notification sent
```

## Security Hardening

### Password Policy

```
Password Requirements:
- Length: 12+ characters
- Uppercase letters: 1+
- Lowercase letters: 1+
- Numbers: 1+
- Special characters: 1+
- No common passwords
- No sequential characters
- Password history: 5
- Password expiration: 90 days
```

### MFA Requirements

```
MFA Methods:
- WebAuthn (FIDO2): Recommended
- TOTP (Authenticator App): Required
- SMS (Fallback): Not recommended
- Backup Codes: 10 codes, store securely

MFA Enforcement:
- All users: Required
- Exceptions: Service accounts only
- Frequency: First login, admin access, high-risk access
```

### Session Management

```
Session Settings:
- Max session: 8 hours
- Idle timeout: 15 minutes
- Remember me: 30 days (with MFA)
- Concurrent sessions: 1 (with override)
- Session revocation: Immediate on user/role change
```

## Monitoring and Auditing

### Audit Events to SIEM

```
Audit Events:
- Login attempts (success/failure)
- User creation/update/deletion
- Role assignment changes
- MFA enrollment
- Permission changes
- Admin actions
```

### Key Metrics

```
IAM Metrics:
- MFA coverage: Target 100%
- JML automation: Target 95%
- Access review completion: Target 100%
- Password reset requests: Target < 5/day
- Support tickets: Target < 10/month
```

---

**Document Owner**: Lead Security Architect  
**Last Updated**: 2026-08-02  
**Version**: 1.0
```

**Verification:**

```bash
# Verify IAM integration guide
ls -la iam/05_iam_integration.md
# Expected: File exists

# Check for integration sections
grep -c "##" iam/05_iam_integration.md
# Expected: Shows 10+ sections

# Check for code blocks
grep -c "```" iam/05_iam_integration.md
# Expected: Shows multiple code blocks
```

---

### Step 7: IAM Summary

**File:** `iam/README.md`

```markdown
# Identity & Access Management - Nexus Global Industries

## Overview

This directory contains the complete Identity and Access Management (IAM) implementation for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_keycloak_configuration.yaml` | Keycloak | Deployment configuration for Keycloak |
| `02_realm_configuration.json` | Realm | Keycloak realm export with users/clients |
| `03_scim_automation.py` | SCIM | SCIM 2.0 JML automation service |
| `04_rbac_policies.rego` | Policies | RBAC/ABAC policies |
| `05_iam_integration.md` | Guide | IAM integration guide |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    IAM ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           HRIS (Workday)                               │   │
│  │           Employee lifecycle events                    │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │           SCIM Automation Service                       │   │
│  │           JML workflows, sync, logging                 │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │           Keycloak Identity Provider                    │   │
│  │           OIDC, SAML, SCIM, MFA                       │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │           RBAC/ABAC Policies (OPA)                      │   │
│  │           Authorization decisions                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

- **Federated Identity**: SAML 2.0 and OIDC federation with Azure AD
- **SCIM 2.0**: Automated Joiner-Mover-Leaver (JML) lifecycle
- **MFA**: WebAuthn and TOTP support for all users
- **SSO**: Single Sign-On for all applications
- **RBAC/ABAC**: Role and attribute-based access control
- **Audit Logging**: Complete audit trail for compliance

## Integration Points

| Integration | Protocol | Status |
|-------------|----------|--------|
| Customer Portal | OIDC | ✅ Active |
| R&D Systems | OIDC | ✅ Active |
| API Gateway | OIDC | ✅ Active |
| Azure AD | SAML | ✅ Active |
| Workday HRIS | SCIM | In Progress |
| Internal Apps | OIDC | In Progress |

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la iam/README.md
# Expected: File exists

echo "✅ Identity & Access Management Complete!"
echo "   - Keycloak deployment configuration"
echo "   - Realm configuration with users/clients"
echo "   - SCIM 2.0 JML automation service"
echo "   - RBAC/ABAC policies"
echo "   - Integration guide"
```

---

**[GENERATED: Part 2, Section 2.2 - Identity & Access Management]**

**[COMPLETED: IAM System for Nexus Global Industries]**
- ✅ Keycloak Deployment - Configuration and deployment
- ✅ Realm Configuration - Users, clients, groups, roles
- ✅ SCIM Automation - JML workflows with Workday integration
- ✅ RBAC/ABAC Policies - Comprehensive access control
- ✅ Integration Guide - Application and API integration

---

## End of Section 2.2: Identity & Access Management

### Key Takeaway

You've implemented a complete Identity and Access Management system for Nexus Global Industries. The system includes Keycloak as the identity provider with OIDC and SAML federation, SCIM 2.0 automation for JML, and comprehensive RBAC/ABAC policies. This provides the foundation for Zero Trust identity verification.

### What's Next

In **Section 2.3**, we'll implement **Privileged Access Management (PAM)** , including:
- HashiCorp Vault deployment
- JIT/JEA access workflows
- Session recording
- Credential rotation
- Break-glass access

The implementation continues with complete Vault configuration and privileged access workflows.
