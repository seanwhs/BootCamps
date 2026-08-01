# Part 4: Detection Engineering, Security Operations & Operational Resilience
## Section 4.1: SIEM/XDR Architecture

## The Target: Complete SIEM/XDR Architecture for Nexus Global Industries

In this section, we'll implement a comprehensive SIEM/XDR architecture for Nexus Global Industries, including:

1. **Centralized Logging** - ELK Stack (Elasticsearch, Logstash, Kibana)
2. **Log Ingestion Pipelines** - Collecting logs from all sources
3. **XDR Integration** - Endpoint detection and response
4. **Log Retention & Storage** - Tiered storage strategy
5. **Dashboard & Visualization** - Security monitoring dashboards

**What specific file(s) are we building?**
- `siem/01_elasticsearch.yaml` - Elasticsearch cluster configuration
- `siem/02_logstash_pipelines.yaml` - Logstash ingestion pipelines
- `siem/03_kibana_dashboards.yaml` - Kibana security dashboards
- `siem/04_xdr_integration.yaml` - XDR integration configuration
- `siem/05_log_retention.yaml` - Log retention policies

---

## The Concept: SIEM/XDR in Plain English

Think of SIEM/XDR like **a security command center with cameras and sensors everywhere**:

**SIEM (Security Information & Event Management):** "A central room where all security cameras, alarms, and sensors feed into one screen." This aggregates and analyzes logs from all sources.

**XDR (Extended Detection & Response):** "Specialized cameras at endpoints (servers, workstations) that can detect threats and automatically respond." This extends detection to endpoints.

**Logstash:** "The cables and wiring that bring all camera feeds to the command center." This ingests and processes logs.

**Elasticsearch:** "The storage system that organizes all video feeds for quick retrieval." This indexes and stores logs.

**Kibana:** "The display screen that security analysts watch." This provides dashboards and visualization.

---

## Implementation Phase

### Step 1: Create the Project Structure

```bash
# Create the siem directory
cd ~/nexus_security_architecture
mkdir -p siem

# Verify the structure
ls -la
# Expected: siem directory appears
```

---

### Step 2: Elasticsearch Cluster Configuration

**File:** `siem/01_elasticsearch.yaml`

```yaml
# Elasticsearch Cluster - Nexus Global Industries
# File: siem/01_elasticsearch.yaml
# Version: 1.0

# ====================================================================
# ELASTICSEARCH NAMESPACE
# ====================================================================

---
apiVersion: v1
kind: Namespace
metadata:
  name: siem
  labels:
    pod-security.kubernetes.io/enforce: "baseline"

# ====================================================================
# ELASTICSEARCH SECRETS
# ====================================================================

---
apiVersion: v1
kind: Secret
metadata:
  name: elasticsearch-secrets
  namespace: siem
type: Opaque
data:
  # In production, use sealed secrets or external vault
  elastic-password: "ZWxhc3RpYy1wYXNzd29yZA=="  # elastic-password
  kibana-password: "a2liYW5hLXBhc3N3b3Jk"       # kibana-password

# ====================================================================
# ELASTICSEARCH CONFIGMAP
# ====================================================================

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: elasticsearch-config
  namespace: siem
data:
  elasticsearch.yml: |
    cluster.name: "nexus-siem"
    network.host: 0.0.0.0
    discovery.seed_hosts: ["elasticsearch-0.elasticsearch", "elasticsearch-1.elasticsearch", "elasticsearch-2.elasticsearch"]
    cluster.initial_master_nodes: ["elasticsearch-0", "elasticsearch-1", "elasticsearch-2"]
    
    # Security configuration
    xpack.security.enabled: true
    xpack.security.transport.ssl.enabled: true
    xpack.security.transport.ssl.verification_mode: certificate
    xpack.security.transport.ssl.keystore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    xpack.security.transport.ssl.truststore.path: /usr/share/elasticsearch/config/certs/elastic-certificates.p12
    
    # Monitoring
    xpack.monitoring.collection.enabled: true
    
    # Performance tuning
    indices.fielddata.cache.size: 20%
    indices.queries.cache.size: 10%
    indices.memory.index_buffer_size: 15%

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: elasticsearch-jvm
  namespace: siem
data:
  jvm.options: |
    -Xms4g
    -Xmx4g
    -XX:+UseG1GC
    -XX:G1ReservePercent=25
    -XX:InitiatingHeapOccupancyPercent=30
    -Djava.io.tmpdir=${ES_TMPDIR}
    -XX:+HeapDumpOnOutOfMemoryError
    -XX:HeapDumpPath=/var/log/elasticsearch
    -XX:ErrorFile=/var/log/elasticsearch/hs_err_pid%p.log

# ====================================================================
# ELASTICSEARCH STATE FUL SET
# ====================================================================

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: siem
  labels:
    app: elasticsearch
spec:
  serviceName: elasticsearch
  replicas: 3
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
        securityContext:
          runAsUser: 1000
          capabilities:
            add:
            - IPC_LOCK
            - SYS_RESOURCE
        env:
        - name: ES_JAVA_OPTS
          valueFrom:
            configMapKeyRef:
              name: elasticsearch-jvm
              key: jvm.options
        - name: ELASTIC_PASSWORD
          valueFrom:
            secretKeyRef:
              name: elasticsearch-secrets
              key: elastic-password
        - name: KIBANA_PASSWORD
          valueFrom:
            secretKeyRef:
              name: elasticsearch-secrets
              key: kibana-password
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        ports:
        - containerPort: 9200
          name: http
        - containerPort: 9300
          name: transport
        volumeMounts:
        - name: config
          mountPath: /usr/share/elasticsearch/config/elasticsearch.yml
          subPath: elasticsearch.yml
        - name: data
          mountPath: /usr/share/elasticsearch/data
        - name: certs
          mountPath: /usr/share/elasticsearch/config/certs
        livenessProbe:
          httpGet:
            path: /_cluster/health?local=true
            port: 9200
            scheme: HTTPS
          initialDelaySeconds: 60
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /_cluster/health?local=true
            port: 9200
            scheme: HTTPS
          initialDelaySeconds: 30
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
        resources:
          requests:
            memory: "6Gi"
            cpu: "1000m"
          limits:
            memory: "8Gi"
            cpu: "2000m"
      volumes:
      - name: config
        configMap:
          name: elasticsearch-config
      - name: certs
        emptyDir: {}
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 100Gi

# ====================================================================
# ELASTICSEARCH SERVICES
# ====================================================================

---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: siem
  labels:
    app: elasticsearch
spec:
  clusterIP: None
  selector:
    app: elasticsearch
  ports:
  - name: http
    port: 9200
    targetPort: 9200
  - name: transport
    port: 9300
    targetPort: 9300

---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch-lb
  namespace: siem
  labels:
    app: elasticsearch
spec:
  selector:
    app: elasticsearch
  ports:
  - name: http
    port: 9200
    targetPort: 9200
  type: LoadBalancer

# ====================================================================
# ELASTICSEARCH INDEX TEMPLATES
# ====================================================================

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: elasticsearch-templates
  namespace: siem
data:
  security-logs-template.json: |
    {
      "index_patterns": ["security-logs-*"],
      "template": {
        "settings": {
          "number_of_shards": 2,
          "number_of_replicas": 1,
          "index.lifecycle.name": "security-logs-policy"
        },
        "mappings": {
          "properties": {
            "timestamp": { "type": "date" },
            "event_type": { "type": "keyword" },
            "severity": { "type": "keyword" },
            "source": { "type": "keyword" },
            "user": { "type": "keyword" },
            "source_ip": { "type": "ip" },
            "destination_ip": { "type": "ip" },
            "message": { "type": "text" },
            "raw": { "type": "text" },
            "tags": { "type": "keyword" }
          }
        }
      }
    }

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: elasticsearch-lifecycle
  namespace: siem
data:
  ilm-policy.json: |
    {
      "policy": {
        "phases": {
          "hot": {
            "min_age": "0ms",
            "actions": {
              "rollover": {
                "max_primary_shard_size": "50gb",
                "max_age": "30d"
              },
              "set_priority": {
                "priority": 100
              }
            }
          },
          "warm": {
            "min_age": "30d",
            "actions": {
              "shrink": {
                "number_of_shards": 1
              },
              "forcemerge": {
                "max_num_segments": 1
              },
              "set_priority": {
                "priority": 50
              }
            }
          },
          "cold": {
            "min_age": "90d",
            "actions": {
              "freeze": {},
              "set_priority": {
                "priority": 0
              }
            }
          },
          "delete": {
            "min_age": "365d",
            "actions": {
              "delete": {}
            }
          }
        }
      }
    }
```

**Verification:**

```bash
# Verify Elasticsearch file
ls -la siem/01_elasticsearch.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('siem/01_elasticsearch.yaml'))"
# Expected: No error output
```

---

### Step 3: Logstash Ingestion Pipelines

**File:** `siem/02_logstash_pipelines.yaml`

```yaml
# Logstash Ingestion Pipelines - Nexus Global Industries
# File: siem/02_logstash_pipelines.yaml
# Version: 1.0

# ====================================================================
# LOGSTASH CONFIGMAP
# ====================================================================

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-config
  namespace: siem
data:
  pipelines.yml: |
    - pipeline.id: main
      path.config: "/usr/share/logstash/pipeline/main.conf"
    - pipeline.id: security
      path.config: "/usr/share/logstash/pipeline/security.conf"
    - pipeline.id: audit
      path.config: "/usr/share/logstash/pipeline/audit.conf"
    - pipeline.id: app
      path.config: "/usr/share/logstash/pipeline/app.conf"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-pipelines
  namespace: siem
data:
  main.conf: |
    # Main Logstash Pipeline
    input {
      beats {
        port => 5044
        host => "0.0.0.0"
      }
      
      tcp {
        port => 5000
        codec => json
      }
      
      udp {
        port => 5001
        codec => json
      }
      
      http {
        port => 8080
        codec => json
      }
    }
    
    filter {
      # Parse timestamp
      date {
        match => [ "timestamp", "ISO8601" ]
        target => "@timestamp"
      }
      
      # GeoIP lookup
      geoip {
        source => "source_ip"
        target => "geoip"
        database => "/usr/share/logstash/geoip/GeoLite2-City.mmdb"
      }
      
      # Normalize event types
      mutate {
        rename => { "event_type" => "event.type" }
        rename => { "severity" => "event.severity" }
      }
      
      # Add tags for security events
      if [event.type] in ["login", "logout", "authentication"] {
        mutate {
          add_tag => ["authentication"]
        }
      }
      
      if [event.severity] == "CRITICAL" or [event.severity] == "HIGH" {
        mutate {
          add_tag => ["high_severity"]
        }
      }
      
      # Add custom fields
      mutate {
        add_field => {
          "[event][ingested]" => "%{@timestamp}"
          "[event][source]" => "logstash"
        }
      }
    }
    
    output {
      elasticsearch {
        hosts => ["elasticsearch:9200"]
        user => "elastic"
        password => "elastic-password"
        ssl => true
        ssl_certificate_verification => false
        index => "logs-%{+YYYY.MM.dd}"
      }
      
      stdout {
        codec => rubydebug
      }
    }

  security.conf: |
    # Security Logs Pipeline
    input {
      beats {
        port => 5045
        host => "0.0.0.0"
      }
    }
    
    filter {
      # Parse security logs (Keycloak, Vault, etc.)
      json {
        source => "message"
        target => "security"
      }
      
      # Extract authentication events
      if [security][event_type] == "login" {
        mutate {
          add_tag => ["auth", "login"]
        }
      }
      
      # Extract privileged access events
      if [security][event_type] == "privileged_access" {
        mutate {
          add_tag => ["pam", "privileged"]
        }
      }
      
      # Anomaly detection tags
      if [security][risk_score] > 70 {
        mutate {
          add_tag => ["anomaly", "high_risk"]
        }
      }
    }
    
    output {
      elasticsearch {
        hosts => ["elasticsearch:9200"]
        user => "elastic"
        password => "elastic-password"
        ssl => true
        ssl_certificate_verification => false
        index => "security-logs-%{+YYYY.MM.dd}"
      }
    }

  audit.conf: |
    # Audit Logs Pipeline
    input {
      beats {
        port => 5046
        host => "0.0.0.0"
      }
    }
    
    filter {
      # Parse audit logs (CloudTrail, Activity Logs, etc.)
      json {
        source => "message"
        target => "audit"
      }
      
      # Extract IAM events
      if [audit][event_type] in ["iam", "authorization"] {
        mutate {
          add_tag => ["iam", "audit"]
        }
      }
      
      # Extract change events
      if [audit][event_type] in ["create", "update", "delete"] {
        mutate {
          add_tag => ["change", "configuration"]
        }
      }
    }
    
    output {
      elasticsearch {
        hosts => ["elasticsearch:9200"]
        user => "elastic"
        password => "elastic-password"
        ssl => true
        ssl_certificate_verification => false
        index => "audit-logs-%{+YYYY.MM.dd}"
      }
    }

  app.conf: |
    # Application Logs Pipeline
    input {
      beats {
        port => 5047
        host => "0.0.0.0"
      }
    }
    
    filter {
      # Parse application logs
      json {
        source => "message"
        target => "app"
      }
      
      # Error detection
      if [app][level] == "ERROR" or [app][level] == "FATAL" {
        mutate {
          add_tag => ["application_error", "high_severity"]
        }
      }
      
      # Performance metrics
      if [app][duration_ms] > 1000 {
        mutate {
          add_tag => ["slow_request", "performance"]
        }
      }
    }
    
    output {
      elasticsearch {
        hosts => ["elasticsearch:9200"]
        user => "elastic"
        password => "elastic-password"
        ssl => true
        ssl_certificate_verification => false
        index => "app-logs-%{+YYYY.MM.dd}"
      }
    }

# ====================================================================
# LOGSTASH DEPLOYMENT
# ====================================================================

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logstash
  namespace: siem
  labels:
    app: logstash
spec:
  replicas: 3
  selector:
    matchLabels:
      app: logstash
  template:
    metadata:
      labels:
        app: logstash
    spec:
      containers:
      - name: logstash
        image: docker.elastic.co/logstash/logstash:8.10.0
        env:
        - name: LOGSTASH_JAVA_OPTS
          value: "-Xmx2g -Xms1g"
        ports:
        - containerPort: 5044
          name: beats
        - containerPort: 5000
          name: tcp
        - containerPort: 5001
          name: udp
        - containerPort: 8080
          name: http
        volumeMounts:
        - name: config
          mountPath: /usr/share/logstash/config
        - name: pipelines
          mountPath: /usr/share/logstash/pipeline
        - name: geoip
          mountPath: /usr/share/logstash/geoip
        livenessProbe:
          httpGet:
            path: /
            port: 9600
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 9600
          initialDelaySeconds: 15
          periodSeconds: 5
        resources:
          requests:
            memory: "2Gi"
            cpu: "500m"
          limits:
            memory: "4Gi"
            cpu: "1000m"
      volumes:
      - name: config
        configMap:
          name: logstash-config
      - name: pipelines
        configMap:
          name: logstash-pipelines
      - name: geoip
        emptyDir: {}

---
apiVersion: v1
kind: Service
metadata:
  name: logstash
  namespace: siem
  labels:
    app: logstash
spec:
  selector:
    app: logstash
  ports:
  - name: beats
    port: 5044
    targetPort: 5044
  - name: tcp
    port: 5000
    targetPort: 5000
  - name: udp
    port: 5001
    targetPort: 5001
    protocol: UDP
  - name: http
    port: 8080
    targetPort: 8080
```

**Verification:**

```bash
# Verify Logstash pipelines file
ls -la siem/02_logstash_pipelines.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('siem/02_logstash_pipelines.yaml'))"
# Expected: No error output
```

---

### Step 4: Kibana Dashboards

**File:** `siem/03_kibana_dashboards.yaml`

```yaml
# Kibana Dashboards - Nexus Global Industries
# File: siem/03_kibana_dashboards.yaml
# Version: 1.0

# ====================================================================
# KIBANA DEPLOYMENT
# ====================================================================

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: siem
  labels:
    app: kibana
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana:8.10.0
        env:
        - name: ELASTICSEARCH_HOSTS
          value: "https://elasticsearch:9200"
        - name: ELASTICSEARCH_USERNAME
          value: "elastic"
        - name: ELASTICSEARCH_PASSWORD
          valueFrom:
            secretKeyRef:
              name: elasticsearch-secrets
              key: elastic-password
        - name: SERVER_NAME
          value: "siem.nexus.com"
        - name: XPACK_SECURITY_ENABLED
          value: "true"
        - name: XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY
          value: "min-32-characters-encryption-key-for-kibana"
        ports:
        - containerPort: 5601
        livenessProbe:
          httpGet:
            path: /api/status
            port: 5601
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/status
            port: 5601
          initialDelaySeconds: 15
          periodSeconds: 5
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"

---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: siem
  labels:
    app: kibana
spec:
  selector:
    app: kibana
  ports:
  - port: 5601
    targetPort: 5601
  type: LoadBalancer

# ====================================================================
# KIBANA DASHBOARD CONFIGURATION
# ====================================================================

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kibana-dashboards
  namespace: siem
data:
  security-overview.ndjson: |
    {
      "attributes": {
        "title": "Security Overview Dashboard",
        "hits": 0,
        "description": "Overall security posture overview",
        "panelsJSON": "[
          {
            \"gridData\": {\"x\":0,\"y\":0,\"w\":24,\"h\":15,\"i\":\"1\"},
            \"panelIndex\": \"1\", 
            \"version\": \"8.10.0\",
            \"panelConfig\": {
              \"id\": \"security-events-over-time\",
              \"type\": \"visualization\",
              \"params\": {
                \"query\": {
                  \"language\": \"kuery\",
                  \"query\": \"\"
                },
                \"aggs\": [
                  {
                    \"id\": \"1\",
                    \"params\": {
                      \"field\": \"@timestamp\",
                      \"interval\": \"auto\",
                      \"timeRange\": {
                        \"from\": \"now-7d\",
                        \"to\": \"now\"
                      }
                    },
                    \"type\": \"count\"
                  }
                ]
              }
            }
          },
          {
            \"gridData\": {\"x\":24,\"y\":0,\"w\":24,\"h\":15,\"i\":\"2\"},
            \"panelIndex\": \"2\",
            \"version\": \"8.10.0\",
            \"panelConfig\": {
              \"id\": \"security-events-by-severity\",
              \"type\": \"visualization\",
              \"params\": {
                \"query\": {
                  \"language\": \"kuery\",
                  \"query\": \"\"
                },
                \"aggs\": [
                  {
                    \"id\": \"1\",
                    \"params\": {
                      \"field\": \"event.severity\"
                    },
                    \"type\": \"terms\"
                  }
                ]
              }
            }
          },
          {
            \"gridData\": {\"x\":0,\"y\":15,\"w\":32,\"h\":20,\"i\":\"3\"},
            \"panelIndex\": \"3\",
            \"version\": \"8.10.0\",
            \"panelConfig\": {
              \"id\": \"top-attack-sources\",
              \"type\": \"visualization\",
              \"params\": {
                \"query\": {
                  \"language\": \"kuery\",
                  \"query\": \"\"
                },
                \"aggs\": [
                  {
                    \"id\": \"1\",
                    \"params\": {
                      \"field\": \"source_ip\"
                    },
                    \"type\": \"terms\"
                  }
                ]
              }
            }
          },
          {
            \"gridData\": {\"x\":32,\"y\":15,\"w\":16,\"h\":20,\"i\":\"4\"},
            \"panelIndex\": \"4\",
            \"version\": \"8.10.0\",
            \"panelConfig\": {
              \"id\": \"security-alerts-count\",
              \"type\": \"visualization\",
              \"params\": {
                \"query\": {
                  \"language\": \"kuery\",
                  \"query\": \"\"
                },
                \"metric\": {
                  \"count\": {
                    \"id\": \"1\"
                  }
                }
              }
            }
          }
        ]",
        "timeRestore": false,
        "optionsJSON": "{\"useMargins\":false}",
        "version": 1,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"query\":{\"language\":\"kuery\",\"query\":\"\"},\"filter\":[]}"
        }
      },
      "id": "security-overview",
      "type": "dashboard"
    }

  incident-response.ndjson: |
    {
      "attributes": {
        "title": "Incident Response Dashboard",
        "hits": 0,
        "description": "Real-time incident tracking",
        "panelsJSON": "[
          {
            \"gridData\": {\"x\":0,\"y\":0,\"w\":48,\"h\":10,\"i\":\"1\"},
            \"panelIndex\": \"1\",
            \"version\": \"8.10.0\",
            \"panelConfig\": {
              \"id\": \"incident-timeline\",
              \"type\": \"visualization\",
              \"params\": {
                \"query\": {
                  \"language\": \"kuery\",
                  \"query\": \"\"
                },
                \"aggs\": [
                  {
                    \"id\": \"1\",
                    \"params\": {
                      \"field\": \"@timestamp\",
                      \"interval\": \"auto\"
                    },
                    \"type\": \"count\"
                  }
                ]
              }
            }
          },
          {
            \"gridData\": {\"x\":0,\"y\":10,\"w\":48,\"h\":15,\"i\":\"2\"},
            \"panelIndex\": \"2\",
            \"version\": \"8.10.0\",
            \"panelConfig\": {
              \"id\": \"recent-incidents\",
              \"type\": \"discover\",
              \"params\": {
                \"query\": {
                  \"language\": \"kuery\",
                  \"query\": \"event.type:incident\"
                },
                \"columns\": [\"@timestamp\", \"message\", \"severity\", \"source\"],
                \"sort\": [[\"@timestamp\", \"desc\"]],
                \"rowCount\": 50
              }
            }
          }
        ]",
        "timeRestore": false,
        "optionsJSON": "{\"useMargins\":false}",
        "version": 1,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"query\":{\"language\":\"kuery\",\"query\":\"\"},\"filter\":[]}"
        }
      },
      "id": "incident-response",
      "type": "dashboard"
    }

  threat-hunting.ndjson: |
    {
      "attributes": {
        "title": "Threat Hunting Workspace",
        "hits": 0,
        "description": "Threat hunting analysis",
        "panelsJSON": "[
          {
            \"gridData\": {\"x\":0,\"y\":0,\"w\":48,\"h\":20,\"i\":\"1\"},
            \"panelIndex\": \"1\",
            \"version\": \"8.10.0\",
            \"panelConfig\": {
              \"id\": \"hunt-discovery\",
              \"type\": \"discover\",
              \"params\": {
                \"query\": {
                  \"language\": \"kuery\",
                  \"query\": \"\"
                },
                \"columns\": [\"@timestamp\", \"event.type\", \"source_ip\", \"user\", \"message\"],
                \"sort\": [[\"@timestamp\", \"desc\"]],
                \"rowCount\": 100
              }
            }
          }
        ]",
        "timeRestore": true,
        "timeRange": {
          "from": "now-30d",
          "to": "now"
        },
        "optionsJSON": "{\"useMargins\":false}",
        "version": 1,
        "kibanaSavedObjectMeta": {
          "searchSourceJSON": "{\"query\":{\"language\":\"kuery\",\"query\":\"\"},\"filter\":[]}"
        }
      },
      "id": "threat-hunting",
      "type": "dashboard"
    }
```

**Verification:**

```bash
# Verify Kibana dashboards file
ls -la siem/03_kibana_dashboards.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('siem/03_kibana_dashboards.yaml'))"
# Expected: No error output
```

---

### Step 5: XDR Integration

**File:** `siem/04_xdr_integration.yaml`

```yaml
# XDR Integration - Nexus Global Industries
# File: siem/04_xdr_integration.yaml
# Version: 1.0

# ====================================================================
# CROWDSTRIKE XDR INTEGRATION
# ====================================================================

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: crowdstrike-config
  namespace: siem
data:
  crowdstrike.yml: |
    # CrowdStrike Falcon XDR Configuration
    config:
      client_id: "crowdstrike-client-id"
      client_secret: "crowdstrike-client-secret"
      base_url: "https://api.crowdstrike.com"
      region: "us-1"
    
    # Detection rules mapping
    detection_mapping:
      - crowdstrike_rule: "CredentialDumping"
        mitre_technique: "T1003"
        severity: "HIGH"
      
      - crowdstrike_rule: "PrivilegeEscalation"
        mitre_technique: "T1068"
        severity: "HIGH"
      
      - crowdstrike_rule: "RansomwareActivity"
        mitre_technique: "T1486"
        severity: "CRITICAL"
    
    # Telemetry to collect
    telemetry:
      - "endpoint-detections"
      - "process-events"
      - "network-events"
      - "file-events"
      - "registry-events"

# ====================================================================
# SENTINEL XDR INTEGRATION
# ====================================================================

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sentinel-config
  namespace: siem
data:
  sentinel.yml: |
    # Microsoft Sentinel XDR Configuration
    workspace_id: "sentinel-workspace-id"
    tenant_id: "azure-tenant-id"
    client_id: "sentinel-client-id"
    client_secret: "sentinel-client-secret"
    
    # Data connectors
    connectors:
      - type: "azure_activity"
        enabled: true
      
      - type: "azure_ad"
        enabled: true
      
      - type: "defender"
        enabled: true
      
      - type: "office365"
        enabled: true

# ====================================================================
# XDR EVENT COLLECTOR
# ====================================================================

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: xdr-collector
  namespace: siem
  labels:
    app: xdr-collector
spec:
  replicas: 2
  selector:
    matchLabels:
      app: xdr-collector
  template:
    metadata:
      labels:
        app: xdr-collector
    spec:
      containers:
      - name: collector
        image: python:3.11-slim
        command:
        - python
        - /app/collector.py
        env:
        - name: CROWDSTRIKE_CLIENT_ID
          valueFrom:
            secretKeyRef:
              name: crowdstrike-secrets
              key: client-id
        - name: CROWDSTRIKE_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: crowdstrike-secrets
              key: client-secret
        - name: SENTINEL_WORKSPACE_ID
          valueFrom:
            secretKeyRef:
              name: sentinel-secrets
              key: workspace-id
        - name: SENTINEL_CLIENT_SECRET
          valueFrom:
            secretKeyRef:
              name: sentinel-secrets
              key: client-secret
        - name: LOGSTASH_URL
          value: "http://logstash:5044"
        volumeMounts:
        - name: app
          mountPath: /app
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "250m"
      volumes:
      - name: app
        configMap:
          name: xdr-collector-app

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: xdr-collector-app
  namespace: siem
data:
  collector.py: |
    # XDR Event Collector
    import os
    import json
    import time
    import logging
    import requests
    from datetime import datetime
    from threading import Thread
    
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    class XDRCollector:
        """XDR event collector for SIEM"""
        
        def __init__(self):
            self.crowdstrike_client_id = os.environ.get('CROWDSTRIKE_CLIENT_ID')
            self.crowdstrike_client_secret = os.environ.get('CROWDSTRIKE_CLIENT_SECRET')
            self.sentinel_workspace_id = os.environ.get('SENTINEL_WORKSPACE_ID')
            self.sentinel_client_secret = os.environ.get('SENTINEL_CLIENT_SECRET')
            self.logstash_url = os.environ.get('LOGSTASH_URL', 'http://logstash:5044')
        
        def collect_crowdstrike_events(self):
            """Collect events from CrowdStrike Falcon"""
            try:
                # Authenticate with CrowdStrike
                token_url = "https://api.crowdstrike.com/oauth2/token"
                data = {
                    'client_id': self.crowdstrike_client_id,
                    'client_secret': self.crowdstrike_client_secret
                }
                response = requests.post(token_url, data=data)
                token = response.json().get('access_token')
                
                # Fetch detections
                headers = {'Authorization': f'Bearer {token}'}
                detections_url = "https://api.crowdstrike.com/detects/entities/detects/v1"
                params = {'limit': 100}
                response = requests.get(detections_url, headers=headers, params=params)
                
                detections = response.json().get('resources', [])
                for detection in detections:
                    event = {
                        'timestamp': datetime.utcnow().isoformat(),
                        'event_type': 'xdr_detection',
                        'source': 'crowdstrike',
                        'severity': detection.get('severity', 'MEDIUM'),
                        'message': detection.get('name', ''),
                        'detection_id': detection.get('id'),
                        'host': detection.get('hostinfo', {}),
                        'raw': detection
                    }
                    self.send_to_siem(event)
                
                logger.info(f"Collected {len(detections)} CrowdStrike events")
                
            except Exception as e:
                logger.error(f"Error collecting CrowdStrike events: {e}")
        
        def collect_sentinel_events(self):
            """Collect events from Microsoft Sentinel"""
            try:
                # Fetch Sentinel alerts
                url = f"https://api.loganalytics.io/v1/workspaces/{self.sentinel_workspace_id}/query"
                headers = {
                    'Authorization': f'Bearer {self.sentinel_client_secret}',
                    'Content-Type': 'application/json'
                }
                query = {
                    'query': 'SecurityAlert | take 100'
                }
                response = requests.post(url, json=query, headers=headers)
                
                alerts = response.json().get('tables', [])
                for alert in alerts:
                    event = {
                        'timestamp': datetime.utcnow().isoformat(),
                        'event_type': 'sentinel_alert',
                        'source': 'sentinel',
                        'severity': alert.get('severity', 'MEDIUM'),
                        'message': alert.get('title', ''),
                        'alert_id': alert.get('id'),
                        'raw': alert
                    }
                    self.send_to_siem(event)
                
                logger.info(f"Collected {len(alerts)} Sentinel events")
                
            except Exception as e:
                logger.error(f"Error collecting Sentinel events: {e}")
        
        def send_to_siem(self, event):
            """Send event to SIEM via Logstash"""
            try:
                response = requests.post(
                    self.logstash_url,
                    json=event,
                    timeout=5
                )
                if response.status_code != 200:
                    logger.warning(f"Failed to send event: {response.status_code}")
            except Exception as e:
                logger.error(f"Error sending event to SIEM: {e}")
        
        def run(self):
            """Main collection loop"""
            logger.info("Starting XDR collector")
            
            while True:
                try:
                    self.collect_crowdstrike_events()
                    self.collect_sentinel_events()
                    time.sleep(60)  # Collect every minute
                except Exception as e:
                    logger.error(f"Error in collection loop: {e}")
                    time.sleep(10)
    
    if __name__ == '__main__':
        collector = XDRCollector()
        collector.run()
```

**Verification:**

```bash
# Verify XDR integration file
ls -la siem/04_xdr_integration.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('siem/04_xdr_integration.yaml'))"
# Expected: No error output
```

---

### Step 6: Log Retention Policies

**File:** `siem/05_log_retention.yaml`

```yaml
# Log Retention Policies - Nexus Global Industries
# File: siem/05_log_retention.yaml
# Version: 1.0

# ====================================================================
# RETENTION POLICIES
# ====================================================================

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: retention-policies
  namespace: siem
data:
  policies.yaml: |
    # Log retention policies
    retention:
      # Hot storage (fast access)
      hot:
        - index_pattern: "security-logs-*"
          duration: "90d"
          min_primary_shard_size: "50gb"
        
        - index_pattern: "audit-logs-*"
          duration: "90d"
          min_primary_shard_size: "50gb"
        
        - index_pattern: "app-logs-*"
          duration: "30d"
          min_primary_shard_size: "30gb"
        
        - index_pattern: "system-logs-*"
          duration: "30d"
          min_primary_shard_size: "30gb"
      
      # Warm storage (slower access)
      warm:
        - index_pattern: "security-logs-*"
          duration: "180d"
        
        - index_pattern: "audit-logs-*"
          duration: "180d"
        
        - index_pattern: "app-logs-*"
          duration: "90d"
      
      # Cold storage (archive)
      cold:
        - index_pattern: "security-logs-*"
          duration: "365d"
        
        - index_pattern: "audit-logs-*"
          duration: "365d"
        
        - index_pattern: "app-logs-*"
          duration: "180d"
      
      # Delete after retention period
      delete:
        - index_pattern: "security-logs-*"
          duration: "365d"
        
        - index_pattern: "audit-logs-*"
          duration: "365d"
        
        - index_pattern: "app-logs-*"
          duration: "180d"
        
        - index_pattern: "system-logs-*"
          duration: "90d"

# ====================================================================
# BACKUP CONFIGURATION
# ====================================================================

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: elasticsearch-backup
  namespace: siem
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
            command:
            - /bin/sh
            - -c
            - |
              # Create snapshot repository
              curl -k -X PUT "https://elasticsearch:9200/_snapshot/nexus-backup" \
                -H "Content-Type: application/json" \
                -d '{
                  "type": "s3",
                  "settings": {
                    "bucket": "nexus-es-backup",
                    "region": "us-east-1",
                    "role_arn": "arn:aws:iam::123456789012:role/es-backup-role"
                  }
                }'
              
              # Take snapshot
              SNAPSHOT_NAME="snapshot-$(date +%Y%m%d-%H%M%S)"
              curl -k -X PUT "https://elasticsearch:9200/_snapshot/nexus-backup/${SNAPSHOT_NAME}" \
                -H "Content-Type: application/json" \
                -d '{
                  "indices": "security-logs-*,audit-logs-*,app-logs-*",
                  "ignore_unavailable": true,
                  "include_global_state": false
                }'
              
              echo "Backup created: ${SNAPSHOT_NAME}"
            env:
            - name: ELASTIC_USER
              value: "elastic"
            - name: ELASTIC_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: elasticsearch-secrets
                  key: elastic-password
          restartPolicy: OnFailure

# ====================================================================
# LOG ROTATION AND CLEANUP
# ====================================================================

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: elasticsearch-cleanup
  namespace: siem
spec:
  schedule: "0 1 * * *"  # Daily at 1 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cleanup
            image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
            command:
            - /bin/sh
            - -c
            - |
              # Delete indices older than retention period
              curl -k -X DELETE "https://elasticsearch:9200/*-$(date -d '365 days ago' +%Y.%m.dd)" \
                -H "Content-Type: application/json"
              
              echo "Old indices deleted"
            env:
            - name: ELASTIC_USER
              value: "elastic"
            - name: ELASTIC_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: elasticsearch-secrets
                  key: elastic-password
          restartPolicy: OnFailure
```

**Verification:**

```bash
# Verify log retention file
ls -la siem/05_log_retention.yaml
# Expected: File exists

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('siem/05_log_retention.yaml'))"
# Expected: No error output
```

---

### Step 7: SIEM/XDR Summary

**File:** `siem/README.md`

```markdown
# SIEM/XDR Architecture - Nexus Global Industries

## Overview

This directory contains the complete SIEM/XDR architecture for Nexus Global Industries.

## Directory Structure

| File | Component | Description |
|------|-----------|-------------|
| `01_elasticsearch.yaml` | Storage | Elasticsearch cluster |
| `02_logstash_pipelines.yaml` | Ingestion | Logstash pipelines |
| `03_kibana_dashboards.yaml` | Visualization | Kibana dashboards |
| `04_xdr_integration.yaml` | XDR | XDR integration |
| `05_log_retention.yaml` | Retention | Log retention policies |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       SIEM/XDR ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  DATA SOURCES                                          │   │
│  │  • Application logs                                  │   │
│  │  • System logs                                       │   │
│  │  • Security logs (Keycloak, Vault)                  │   │
│  │  • Cloud logs (AWS, Azure)                          │   │
│  │  • XDR telemetry (CrowdStrike, Sentinel)            │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  LOGSTASH (Ingestion)                                 │   │
│  │  • Parse, enrich, normalize logs                     │   │
│  │  • GeoIP lookups                                     │   │
│  │  • Tagging and classification                       │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  ELASTICSEARCH (Storage)                              │   │
│  │  • Hot (90 days)                                     │   │
│  │  • Warm (180 days)                                   │   │
│  │  • Cold (365 days)                                   │   │
│  │  • Delete (365+ days)                                │   │
│  └─────────────────────┬───────────────────────────────────┘   │
│                        │                                        │
│  ┌─────────────────────▼───────────────────────────────────┐   │
│  │  KIBANA (Visualization)                               │   │
│  │  • Security overview dashboard                       │   │
│  │  • Incident response dashboard                      │   │
│  │  • Threat hunting workspace                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Key Features

| Feature | Description |
|---------|-------------|
| **Centralized Logging** | All logs in one place |
| **Real-time Ingestion** | Logstash pipelines |
| **Tiered Storage** | Hot/Warm/Cold/Delete |
| **XDR Integration** | CrowdStrike + Sentinel |
| **Dashboards** | Security overview, incident response |
| **Retention** | 90-365 days based on log type |

## Deployment Instructions

### 1. Deploy Elasticsearch

```bash
kubectl apply -f siem/01_elasticsearch.yaml
```

### 2. Deploy Logstash

```bash
kubectl apply -f siem/02_logstash_pipelines.yaml
```

### 3. Deploy Kibana

```bash
kubectl apply -f siem/03_kibana_dashboards.yaml
```

### 4. Deploy XDR Integration

```bash
kubectl apply -f siem/04_xdr_integration.yaml
```

### 5. Configure Retention

```bash
kubectl apply -f siem/05_log_retention.yaml
```

## Verification Checklist

- [ ] Elasticsearch cluster healthy
- [ ] Logstash pipelines running
- [ ] Kibana accessible
- [ ] Logs flowing into SIEM
- [ ] XDR integration working
- [ ] Retention policies configured
- [ ] Dashboards loaded

---

**Maintained By**: Lead Security Architect  
**Version**: 1.0  
**Last Updated**: 2026-08-02
```

**Verification:**

```bash
# Verify README
ls -la siem/README.md
# Expected: File exists

echo "✅ SIEM/XDR Architecture Complete!"
echo "   - Elasticsearch cluster (3 nodes)"
echo "   - Logstash pipelines (4 pipelines)"
echo "   - Kibana dashboards (3 dashboards)"
echo "   - XDR integration (CrowdStrike, Sentinel)"
echo "   - Log retention policies"
```

---

## End of Section 4.1: SIEM/XDR Architecture

### Key Takeaway

You've implemented a complete SIEM/XDR architecture for Nexus Global Industries, including an Elasticsearch cluster with tiered storage, Logstash ingestion pipelines, Kibana security dashboards, XDR integration with CrowdStrike and Sentinel, and comprehensive log retention policies. This provides the foundation for detection engineering and security operations.

### What's Next

**Section 4.2** will cover **Detection Engineering (MITRE ATT&CK)** , including:
- Detection rules in Sigma format
- MITRE ATT&CK technique mapping
- Rule testing and validation
- Detection lifecycle management
- False positive reduction
