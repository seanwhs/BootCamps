# Primer 35: Nginx for Serverless GraphQL

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for serverless GraphQL implementations. Understanding these concepts is essential for building scalable, cost-effective GraphQL APIs with serverless functions.

## P35.1 Serverless GraphQL Architecture

### Serverless GraphQL Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SERVERLESS GRAPHQL ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX GRAPHQL GATEWAY                          │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    QUERY ROUTING                          │ │      │
│  │  │  • Query Parsing   • Field Selection   • Federation       │ │      │
│  │  │  • Lambda Routing  • Cold Start Mgmt   • Function Pool   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    FUNCTION EXECUTION                     │ │      │
│  │  │  • AWS Lambda       • Azure Functions   • GCP Cloud Run  │ │      │
│  │  │  • Cloudflare Workers • Vercel Edge    • Deno Deploy     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PERFORMANCE OPTIMIZATION               │ │      │
│  │  │  • Query Batching   • Response Caching   • Dataloader    │ │      │
│  │  │  • Persistent Queries • Cold Start Warm  • Function Pool │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    SERVERLESS PROVIDERS                          │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ AWS Lambda │  │ Azure      │  │ GCP Cloud  │  │Cloudflare│ │      │
│  │  │ GraphQL    │  │ Functions  │  │ Functions  │  │ Workers  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Serverless GraphQL Configuration

```nginx
# nginx-serverless-graphql.conf - Serverless GraphQL
# ============================================================================
# NGINX SERVERLESS GRAPHQL GATEWAY
# Complete production-ready serverless GraphQL configuration
# ============================================================================

http {
    # =========================================================================
    # GRAPHQL SPECIFIC SETTINGS
    # =========================================================================
    large_client_header_buffers 4 16k;
    client_header_buffer_size 8k;
    client_max_body_size 10M;
    client_body_buffer_size 128k;
    
    # Long timeouts for serverless
    proxy_read_timeout 30s;
    proxy_connect_timeout 10s;
    proxy_send_timeout 30s;
    
    # =========================================================================
    # SERVERLESS PROVIDER MAPPING
    # =========================================================================
    map $http_x_provider $provider_endpoint {
        default "http://aws-lambda";
        "aws" "http://aws-lambda";
        "azure" "http://azure-functions";
        "gcp" "http://gcp-functions";
        "cloudflare" "http://cloudflare-workers";
    }
    
    # Function mapping
    map $request_uri $function_name {
        default "default";
        ~^/graphql/users "users-function";
        ~^/graphql/orders "orders-function";
        ~^/graphql/products "products-function";
        ~^/graphql/auth "auth-function";
        ~^/graphql/analytics "analytics-function";
    }
    
    # Function version mapping
    map $http_x_function_version $function_version {
        default "latest";
        "v1" "v1";
        "v2" "v2";
        "v3" "v3";
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=graphql:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=free_graphql:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=premium_graphql:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=enterprise_graphql:10m rate=500r/m;
    
    # Tier mapping
    map $http_x_api_key $api_tier {
        default "free";
        "~^free_" "free";
        "~^basic_" "basic";
        "~^premium_" "premium";
        "~^enterprise_" "enterprise";
    }
    
    # =========================================================================
    # GRAPHQL CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/graphql_cache
        levels=1:2
        keys_zone=graphql_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    proxy_cache_path /var/cache/nginx/graphql_persistent
        levels=1:2
        keys_zone=graphql_persistent:50m
        max_size=500m
        inactive=30d
        use_temp_path=off;
    
    # =========================================================================
    # SERVERLESS UPSTREAMS
    # =========================================================================
    # AWS Lambda
    upstream aws_lambda {
        server lambda.us-east-1.amazonaws.com:443;
        keepalive 32;
        keepalive_requests 1000;
        keepalive_timeout 60s;
    }
    
    # Azure Functions
    upstream azure_functions {
        server functions.azure.com:443;
        keepalive 32;
        keepalive_requests 1000;
        keepalive_timeout 60s;
    }
    
    # GCP Cloud Functions
    upstream gcp_functions {
        server cloudfunctions.googleapis.com:443;
        keepalive 32;
        keepalive_requests 1000;
        keepalive_timeout 60s;
    }
    
    # Cloudflare Workers
    upstream cloudflare_workers {
        server workers.cloudflare.com:443;
        keepalive 32;
        keepalive_requests 1000;
        keepalive_timeout 60s;
    }
    
    # =========================================================================
    # GRAPHQL PERSISTENT QUERIES
    # =========================================================================
    location /graphql/persistent {
        # Store and retrieve persistent queries
        proxy_cache graphql_persistent;
        proxy_cache_key $arg_id;
        proxy_cache_valid 200 30d;
        proxy_cache_valid 404 1h;
        
        proxy_pass http://query_store/persistent;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        
        add_header X-Cache-Status $upstream_cache_status;
    }
    
    # =========================================================================
    # MAIN SERVERLESS GRAPHQL GATEWAY
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name graphql-serverless.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/graphql-serverless.crt;
        ssl_certificate_key /etc/nginx/ssl/graphql-serverless.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # GraphQL headers
        add_header X-GraphQL-Gateway "serverless" always;
        
        # CORS
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-Provider, X-Function-Version, X-API-Key" always;
        add_header Access-Control-Expose-Headers "X-Request-ID, X-GraphQL-Trace, X-Function-Execution-Time" always;
        
        # Preflight
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID, X-Provider, X-Function-Version, X-API-Key" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Length 0;
            return 204;
        }
        
        # =========================================================================
        # TIER-BASED RATE LIMITING
        # =========================================================================
        set $rate_limit_zone "graphql";
        if ($api_tier = "free") {
            set $rate_limit_zone "free_graphql";
        }
        if ($api_tier = "premium") {
            set $rate_limit_zone "premium_graphql";
        }
        if ($api_tier = "enterprise") {
            set $rate_limit_zone "enterprise_graphql";
        }
        
        # =========================================================================
        # GRAPHQL ENDPOINT
        # =========================================================================
        location /graphql {
            # API key validation
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Rate limiting
            limit_req zone=$rate_limit_zone burst=10 nodelay;
            
            # Query validation
            if ($content_type !~ "application/json") {
                return 415 '{"error":"Content-Type must be application/json"}';
                add_header Content-Type application/json;
            }
            
            # Extract query for caching
            set $graphql_query_hash "";
            
            # Route to appropriate provider
            set $provider $http_x_provider;
            if ($provider = "") {
                set $provider "aws";  # Default provider
            }
            
            # Provider-specific configuration
            if ($provider = "aws") {
                # AWS Lambda specific headers
                proxy_set_header X-Amz-Invocation-Type RequestResponse;
                proxy_set_header X-Amz-Log-Type Tail;
                proxy_set_header X-Amz-Client-Context $http_x_amz_client_context;
                
                # Function configuration
                proxy_pass https://aws_lambda/2015-03-31/functions/$function_name/invocations;
            }
            
            if ($provider = "azure") {
                # Azure Functions specific headers
                proxy_set_header x-functions-key $http_x_azure_functions_key;
                proxy_set_header x-ms-client-session-id $http_x_ms_client_session_id;
                proxy_set_header x-ms-client-request-id $request_id;
                
                proxy_pass https://azure_functions/api/$function_name;
            }
            
            if ($provider = "gcp") {
                # GCP Functions specific headers
                proxy_set_header Authorization "Bearer $http_x_gcp_id_token";
                proxy_set_header x-goog-user-project $http_x_goog_user_project;
                
                proxy_pass https://gcp_functions/v1/projects/$project/locations/$location/functions/$function_name:execute;
            }
            
            if ($provider = "cloudflare") {
                # Cloudflare Workers specific headers
                proxy_set_header CF-Access-Client-Id $http_x_cf_client_id;
                proxy_set_header CF-Access-Client-Secret $http_x_cf_client_secret;
                
                proxy_pass https://cloudflare_workers/$function_name;
            }
            
            # Common headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header Content-Type application/json;
            
            # Function version
            proxy_set_header X-Function-Version $function_version;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
            
            # Serverless function timeout
            proxy_read_timeout 30s;
            proxy_connect_timeout 10s;
            proxy_send_timeout 30s;
            
            # Cache response
            if ($request_method = POST) {
                proxy_cache graphql_cache;
                proxy_cache_key $scheme$host$request_uri$http_x_api_key$http_x_provider$function_version$request_body;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            # Buffer for large responses
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            
            # Error handling
            proxy_intercept_errors on;
            error_page 502 503 504 = @function_error;
        }
        
        # =========================================================================
        # BATCH GRAPHQL OPERATIONS
        # =========================================================================
        location /graphql/batch {
            # API key validation
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Higher limits for batch
            if ($api_tier = "free") {
                limit_req zone=free_graphql burst=20 nodelay;
            }
            if ($api_tier = "premium") {
                limit_req zone=premium_graphql burst=100 nodelay;
            }
            if ($api_tier = "enterprise") {
                limit_req zone=enterprise_graphql burst=500 nodelay;
            }
            
            # Large batch payloads
            client_max_body_size 20M;
            
            # Disable caching for batch
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            # Route to batch processor
            proxy_pass http://batch_processor/batch;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_read_timeout 60s;
            proxy_connect_timeout 10s;
            proxy_send_timeout 60s;
            
            # Buffer for large responses
            proxy_buffering on;
            proxy_buffer_size 32k;
            proxy_buffers 32 32k;
            proxy_busy_buffers_size 64k;
        }
        
        # =========================================================================
        # INTROSPECTION
        # =========================================================================
        location /graphql/introspection {
            # Only allow in development or with proper auth
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Premium feature
            if ($api_tier = "free") {
                return 403 '{"error":"Introspection requires premium tier"}';
                add_header Content-Type application/json;
            }
            
            # Cache introspection results
            proxy_cache graphql_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://introspection_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-API-Key $http_x_api_key;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # FUNCTION ERROR HANDLER
        # =========================================================================
        location @function_error {
            return 503 '{"error":"Function temporarily unavailable"}';
            add_header Content-Type application/json;
            add_header Retry-After 30;
        }
        
        # =========================================================================
        # COLD START MANAGEMENT
        # =========================================================================
        location /graphql/warm {
            # Warm up serverless functions
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            # Invoke functions with lightweight request
            proxy_pass http://warmup_service/warm;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Warmup "true";
            
            proxy_read_timeout 5s;
            proxy_connect_timeout 3s;
            
            return 200 '{"status":"warming"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # GRAPHQL STATUS
        # =========================================================================
        location /graphql/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "provider":"$provider",
                "function":"$function_name",
                "version":"$function_version",
                "tier":"$api_tier",
                "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
                "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P35.2 Serverless Function Examples

### AWS Lambda GraphQL Handler

```javascript
// lambda-graphql.js - AWS Lambda GraphQL Handler
// ============================================================================
// AWS LAMBDA GRAPHQL HANDLER
// Serverless GraphQL function for AWS Lambda
// ============================================================================

const { ApolloServer, gql } = require('apollo-server-lambda');
const { ApolloServerPluginLandingPageLocalDefault } = require('apollo-server-core');

// Type definitions
const typeDefs = gql`
  type Query {
    hello: String!
    user(id: ID!): User
    users: [User!]!
    orders(userId: ID!): [Order!]!
  }

  type Mutation {
    createUser(input: CreateUserInput!): User!
    updateUser(id: ID!, input: UpdateUserInput!): User!
    deleteUser(id: ID!): Boolean!
  }

  type User {
    id: ID!
    name: String!
    email: String!
    role: String!
    createdAt: String!
    updatedAt: String!
  }

  type Order {
    id: ID!
    userId: ID!
    total: Float!
    status: String!
    items: [OrderItem!]!
    createdAt: String!
  }

  type OrderItem {
    id: ID!
    productId: ID!
    quantity: Int!
    price: Float!
  }

  input CreateUserInput {
    name: String!
    email: String!
    password: String!
    role: String
  }

  input UpdateUserInput {
    name: String
    email: String
    role: String
  }
`;

// Resolvers
const resolvers = {
  Query: {
    hello: () => 'Hello from serverless GraphQL!',
    
    user: async (_, { id }, context) => {
      // Fetch user from database
      const user = await context.db.users.findById(id);
      if (!user) {
        throw new Error('User not found');
      }
      return user;
    },
    
    users: async (_, __, context) => {
      // Fetch all users
      const users = await context.db.users.findAll();
      return users;
    },
    
    orders: async (_, { userId }, context) => {
      // Fetch orders for user
      const orders = await context.db.orders.findByUserId(userId);
      return orders;
    }
  },
  
  Mutation: {
    createUser: async (_, { input }, context) => {
      // Create new user
      const user = await context.db.users.create({
        ...input,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      });
      return user;
    },
    
    updateUser: async (_, { id, input }, context) => {
      // Update user
      const user = await context.db.users.update(id, {
        ...input,
        updatedAt: new Date().toISOString()
      });
      return user;
    },
    
    deleteUser: async (_, { id }, context) => {
      // Delete user
      await context.db.users.delete(id);
      return true;
    }
  }
};

// Context function
const context = ({ event, context }) => ({
  headers: event.headers,
  functionName: context.functionName,
  awsRequestId: context.awsRequestId,
  // Database connection
  db: {
    users: {
      findById: async (id) => {
        // Simulate database query
        return { id, name: `User ${id}`, email: `user${id}@example.com` };
      },
      findAll: async () => {
        // Simulate database query
        return [
          { id: '1', name: 'User 1', email: 'user1@example.com' },
          { id: '2', name: 'User 2', email: 'user2@example.com' }
        ];
      },
      create: async (input) => {
        // Simulate database insert
        return { id: '3', ...input };
      },
      update: async (id, input) => {
        // Simulate database update
        return { id, ...input };
      },
      delete: async (id) => {
        // Simulate database delete
        return true;
      }
    },
    orders: {
      findByUserId: async (userId) => {
        // Simulate database query
        return [
          { id: '1', userId, total: 100.50, status: 'completed', items: [] },
          { id: '2', userId, total: 50.25, status: 'pending', items: [] }
        ];
      }
    }
  }
});

// Create Apollo Server
const server = new ApolloServer({
  typeDefs,
  resolvers,
  context,
  cache: 'bounded',
  plugins: [
    ApolloServerPluginLandingPageLocalDefault({ embed: true })
  ],
  // Enable introspection
  introspection: true,
  // Enable playground
  playground: true,
  // Enable tracing
  tracing: true
});

// Export handler
exports.handler = server.createHandler({
  cors: {
    origin: '*',
    credentials: true,
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Authorization', 'Content-Type', 'X-Request-ID', 'X-Provider', 'X-Function-Version', 'X-API-Key']
  }
});
```

## P35.3 Cold Start Mitigation

### Cold Start Warmup Script

```bash
#!/bin/bash
# cold-start-warmup.sh - Lambda cold start mitigation

echo "=== Cold Start Warmup ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions to warm
FUNCTIONS=(
    "users-function"
    "orders-function"
    "products-function"
    "auth-function"
    "analytics-function"
)

# Providers
PROVIDERS=("aws" "azure" "gcp" "cloudflare")

# Warmup interval (seconds)
INTERVAL=300

# Function: Warm a specific function
warm_function() {
    local function=$1
    local provider=$2
    
    echo -e "${BLUE}Warming $function on $provider...${NC}"
    
    # Send lightweight request
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "X-Provider: $provider" \
        -H "X-API-Key: warmup-key" \
        -d '{"query":"{ __typename }"}' \
        "https://graphql-serverless.example.com/graphql" 2>/dev/null)
    
    if [ "$response" -eq 200 ] || [ "$response" -eq 201 ]; then
        echo -e "${GREEN}✓ $function on $provider warmed (HTTP $response)${NC}"
    else
        echo -e "${YELLOW}⚠ $function on $provider failed (HTTP $response)${NC}"
    fi
}

# Function: Warm all functions
warm_all_functions() {
    echo "Warming all functions..."
    echo ""
    
    for provider in "${PROVIDERS[@]}"; do
        for function in "${FUNCTIONS[@]}"; do
            warm_function "$function" "$provider"
        done
    done
}

# Main loop
echo "Starting cold start warmup..."
echo "Interval: $INTERVAL seconds"
echo ""

while true; do
    warm_all_functions
    echo ""
    echo "Next warmup in $INTERVAL seconds..."
    sleep $INTERVAL
done
```

---

This primer provides a comprehensive deep dive into using Nginx for serverless GraphQL implementations. Use these techniques to build scalable, cost-effective GraphQL APIs with serverless functions.
