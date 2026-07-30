# Phase 3: Offensive Tooling & Payload Crafting
## Part 1: API Interaction & Intelligence Gathering

### The Target: API Interaction & Intelligence Framework

By the end of this part, you will:
- Master REST and GraphQL API interaction
- Build automated data collection and intelligence gathering tools
- Implement API authentication and rate limiting handling
- Create parsing and analysis pipelines for JSON/XML responses
- Develop a framework for automated reconnaissance and target profiling

### The Concept: Understanding APIs

Think of APIs (Application Programming Interfaces) like a restaurant's ordering system:

- **REST API** = A standard menu with specific items you can order
- **GraphQL API** = A customizable menu where you can ask for exactly what you want
- **Endpoint** = A specific dish on the menu
- **JSON/XML** = The order format (like a written list)
- **API Key** = Your loyalty card (identifies you)
- **Rate Limiting** = "No more than 5 orders per minute"

**Why We Interact with APIs:**
- Extract intelligence about target infrastructure
- Automate data collection and analysis
- Discover vulnerabilities in API implementations
- Gather information for social engineering
- Identify exposed sensitive data

### The Implementation: API Interaction Framework

#### File: `~/hacking-toolkit/exploit/api_client.py`

```python
#!/usr/bin/env python3
"""
api_client.py - Advanced API Interaction & Intelligence Gathering Framework
Provides comprehensive REST and GraphQL API interaction capabilities.
"""

import sys
import json
import time
import base64
import hashlib
import re
from typing import Dict, List, Optional, Any, Tuple, Union
from urllib.parse import urljoin, urlparse, parse_qs
from datetime import datetime
from dataclasses import dataclass, field
import xml.etree.ElementTree as ET

# Import our HTTP client
try:
    from http_client import HTTPClient
except ImportError:
    print("[-] http_client.py not found. Please ensure it's in the same directory.")
    sys.exit(1)

@dataclass
class APIEndpoint:
    """Represents an API endpoint"""
    path: str
    method: str
    description: str = ''
    parameters: List[Dict] = field(default_factory=list)
    responses: Dict[str, Any] = field(default_factory=dict)
    requires_auth: bool = False
    discovered_at: str = field(default_factory=lambda: datetime.now().isoformat())

@dataclass
class APIIntel:
    """Container for API intelligence gathered"""
    base_url: str
    endpoints: List[APIEndpoint] = field(default_factory=list)
    resources: List[str] = field(default_factory=list)
    exposed_data: Dict[str, Any] = field(default_factory=dict)
    vulnerabilities: List[Dict] = field(default_factory=list)
    total_requests: int = 0
    average_response_time: float = 0.0
    
    def to_dict(self) -> Dict:
        """Convert to dictionary"""
        return {
            'base_url': self.base_url,
            'endpoints': [e.__dict__ for e in self.endpoints[:20]],
            'resources': self.resources[:20],
            'exposed_data': self.exposed_data,
            'vulnerabilities': self.vulnerabilities,
            'total_requests': self.total_requests,
            'average_response_time': self.average_response_time
        }

class APIClient:
    """
    Comprehensive API client with REST and GraphQL support
    Includes intelligence gathering and analysis capabilities
    """
    
    def __init__(self, base_url: str, api_key: str = None,
                 timeout: int = 30, verify_ssl: bool = False):
        """
        Initialize the API client
        
        Args:
            base_url: Base URL for the API
            api_key: API key for authentication
            timeout: Request timeout
            verify_ssl: Whether to verify SSL certificates
        """
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.client = HTTPClient(base_url, timeout=timeout, verify_ssl=verify_ssl)
        
        if api_key:
            self.client.set_auth_api_key(api_key)
        
        self.intel = APIIntel(base_url=base_url)
        self.rate_limit_info = {
            'limit': 0,
            'remaining': 0,
            'reset': 0
        }
        self.request_count = 0
        self.response_times = []
        
    def _parse_rate_limit(self, response) -> None:
        """
        Parse rate limit information from response headers
        
        Args:
            response: HTTP response
        """
        headers = response.headers
        
        # Common rate limit headers
        for key in ['X-RateLimit-Limit', 'RateLimit-Limit']:
            if key in headers:
                self.rate_limit_info['limit'] = int(headers[key])
        
        for key in ['X-RateLimit-Remaining', 'RateLimit-Remaining']:
            if key in headers:
                self.rate_limit_info['remaining'] = int(headers[key])
        
        for key in ['X-RateLimit-Reset', 'RateLimit-Reset']:
            if key in headers:
                self.rate_limit_info['reset'] = int(headers[key])
    
    def _log_request(self, method: str, endpoint: str,
                     response_time: float, status_code: int):
        """
        Log request details for intelligence gathering
        
        Args:
            method: HTTP method
            endpoint: API endpoint
            response_time: Response time in seconds
            status_code: HTTP status code
        """
        self.request_count += 1
        self.response_times.append(response_time)
        
        self.intel.total_requests = self.request_count
        self.intel.average_response_time = sum(self.response_times) / len(self.response_times)
    
    def rest_request(self, method: str, endpoint: str,
                     params: Dict = None, data: Dict = None,
                     json_data: Dict = None, **kwargs) -> Optional[requests.Response]:
        """
        Make a REST API request
        
        Args:
            method: HTTP method (GET, POST, PUT, DELETE, etc.)
            endpoint: API endpoint
            params: Query parameters
            data: Form data
            json_data: JSON data
            **kwargs: Additional arguments for HTTPClient
            
        Returns:
            Response object or None
        """
        start_time = time.time()
        
        try:
            # Make the request
            response = self.client.request(
                method=method,
                url=endpoint,
                params=params,
                data=data,
                json_data=json_data,
                **kwargs
            )
            
            # Record timing
            response_time = time.time() - start_time
            self._log_request(method, endpoint, response_time, response.status_code)
            
            # Parse rate limits
            self._parse_rate_limit(response)
            
            return response
            
        except Exception as e:
            print(f"[-] API request failed: {e}")
            return None
    
    def get(self, endpoint: str, params: Dict = None, **kwargs) -> Optional[requests.Response]:
        """GET request"""
        return self.rest_request('GET', endpoint, params=params, **kwargs)
    
    def post(self, endpoint: str, data: Dict = None, json_data: Dict = None,
             **kwargs) -> Optional[requests.Response]:
        """POST request"""
        return self.rest_request('POST', endpoint, data=data, json_data=json_data, **kwargs)
    
    def put(self, endpoint: str, data: Dict = None, json_data: Dict = None,
            **kwargs) -> Optional[requests.Response]:
        """PUT request"""
        return self.rest_request('PUT', endpoint, data=data, json_data=json_data, **kwargs)
    
    def delete(self, endpoint: str, **kwargs) -> Optional[requests.Response]:
        """DELETE request"""
        return self.rest_request('DELETE', endpoint, **kwargs)
    
    def patch(self, endpoint: str, data: Dict = None, json_data: Dict = None,
              **kwargs) -> Optional[requests.Response]:
        """PATCH request"""
        return self.rest_request('PATCH', endpoint, data=data, json_data=json_data, **kwargs)
    
    def graphql_query(self, query: str, variables: Dict = None,
                      operation_name: str = None) -> Optional[Dict]:
        """
        Execute a GraphQL query
        
        Args:
            query: GraphQL query string
            variables: Query variables
            operation_name: Operation name
            
        Returns:
            JSON response or None
        """
        graphql_data = {
            'query': query,
            'variables': variables or {}
        }
        
        if operation_name:
            graphql_data['operationName'] = operation_name
        
        response = self.post('/graphql', json_data=graphql_data)
        
        if response and response.status_code == 200:
            try:
                return response.json()
            except:
                print("[-] Failed to parse GraphQL response")
        
        return None
    
    def graphql_introspection(self) -> Optional[Dict]:
        """
        Perform GraphQL introspection query
        
        Returns:
            Introspection results or None
        """
        introspection_query = """
        query IntrospectionQuery {
            __schema {
                queryType { name }
                mutationType { name }
                subscriptionType { name }
                types {
                    ...FullType
                }
                directives {
                    name
                    description
                    locations
                    args {
                        ...InputValue
                    }
                }
            }
        }
        
        fragment FullType on __Type {
            kind
            name
            description
            fields(includeDeprecated: true) {
                name
                description
                args {
                    ...InputValue
                }
                type {
                    ...TypeRef
                }
                isDeprecated
                deprecationReason
            }
            inputFields {
                ...InputValue
            }
            interfaces {
                ...TypeRef
            }
            enumValues(includeDeprecated: true) {
                name
                description
                isDeprecated
                deprecationReason
            }
            possibleTypes {
                ...TypeRef
            }
        }
        
        fragment InputValue on __InputValue {
            name
            description
            type { ...TypeRef }
            defaultValue
        }
        
        fragment TypeRef on __Type {
            kind
            name
            ofType {
                kind
                name
                ofType {
                    kind
                    name
                    ofType {
                        kind
                        name
                        ofType {
                            kind
                            name
                            ofType {
                                kind
                                name
                                ofType {
                                    kind
                                    name
                                    ofType {
                                        kind
                                        name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        """
        
        return self.graphql_query(introspection_query)
    
    def discover_endpoints_from_swagger(self, swagger_url: str = '/swagger/v1/swagger.json') -> List[APIEndpoint]:
        """
        Discover API endpoints from Swagger/OpenAPI specification
        
        Args:
            swagger_url: Swagger specification URL
            
        Returns:
            List of discovered endpoints
        """
        endpoints = []
        
        try:
            response = self.get(swagger_url)
            if not response or response.status_code != 200:
                return endpoints
            
            spec = response.json()
            
            # Parse OpenAPI 3.0 or Swagger 2.0
            paths = spec.get('paths', {})
            
            for path, methods in paths.items():
                for method, details in methods.items():
                    if method not in ['get', 'post', 'put', 'delete', 'patch', 'options', 'head']:
                        continue
                    
                    endpoint = APIEndpoint(
                        path=path,
                        method=method.upper(),
                        description=details.get('summary', '') or details.get('description', ''),
                        parameters=details.get('parameters', []),
                        responses=details.get('responses', {}),
                        requires_auth=bool(spec.get('security', {}))
                    )
                    
                    endpoints.append(endpoint)
            
            self.intel.endpoints.extend(endpoints)
            print(f"[*] Discovered {len(endpoints)} endpoints from Swagger")
            
        except Exception as e:
            print(f"[-] Failed to parse Swagger: {e}")
        
        return endpoints
    
    def discover_resources(self, base_endpoint: str = '/api') -> List[str]:
        """
        Discover resources by testing common paths
        
        Args:
            base_endpoint: Base API endpoint
            
        Returns:
            List of discovered resources
        """
        common_resources = [
            'users', 'user', 'admin', 'login', 'auth', 'register',
            'profile', 'account', 'settings', 'config', 'info',
            'status', 'health', 'version', 'ping',
            'products', 'orders', 'customers', 'payments',
            'files', 'uploads', 'images', 'media',
            'posts', 'comments', 'messages', 'notifications'
        ]
        
        discovered = []
        
        for resource in common_resources:
            try:
                response = self.get(f'{base_endpoint}/{resource}')
                if response and response.status_code in [200, 201, 403, 401]:
                    discovered.append(resource)
                    print(f"[+] Found resource: {resource}")
            except:
                continue
        
        self.intel.resources.extend(discovered)
        return discovered
    
    def analyze_response(self, response: requests.Response) -> Dict[str, Any]:
        """
        Analyze API response for intelligence gathering
        
        Args:
            response: HTTP response
            
        Returns:
            Analysis results
        """
        analysis = {
            'status_code': response.status_code,
            'headers': dict(response.headers),
            'content_type': response.headers.get('content-type', ''),
            'size': len(response.content),
            'response_time': 0
        }
        
        # Try to parse JSON
        try:
            if 'application/json' in analysis['content_type']:
                json_data = response.json()
                analysis['json'] = json_data
                
                # Look for sensitive data
                if isinstance(json_data, dict):
                    for key in ['token', 'password', 'secret', 'key', 'credit']:
                        if key in json_data:
                            analysis['sensitive_data'] = {
                                'type': key,
                                'value': json_data[key][:20] + '...' if len(str(json_data[key])) > 20 else json_data[key]
                            }
                            print(f"[!] Potential sensitive data found: {key}")
        except:
            pass
        
        return analysis
    
    def brute_force_endpoints(self, base_endpoint: str = '/api',
                              wordlist: List[str] = None) -> List[str]:
        """
        Brute force API endpoints
        
        Args:
            base_endpoint: Base API endpoint
            wordlist: List of paths to try
            
        Returns:
            List of discovered endpoints
        """
        if wordlist is None:
            wordlist = [
                'users', 'admin', 'login', 'auth', 'profile',
                'config', 'settings', 'info', 'status', 'health',
                'products', 'orders', 'payments', 'files', 'upload'
            ]
        
        discovered = []
        
        print(f"[*] Brute forcing API endpoints at {base_endpoint}")
        
        for path in wordlist:
            try:
                response = self.get(f'{base_endpoint}/{path}')
                if response and response.status_code not in [404, 405]:
                    discovered.append(path)
                    print(f"[+] Found endpoint: {path} ({response.status_code})")
                    
                    # Add to intel
                    endpoint = APIEndpoint(
                        path=f'{base_endpoint}/{path}',
                        method='GET',
                        description=f'Discovered through brute force',
                        responses={str(response.status_code): {}}
                    )
                    self.intel.endpoints.append(endpoint)
            except:
                continue
            
            # Small delay to avoid rate limiting
            time.sleep(0.1)
        
        return discovered

class APIIntelligence(APIClient):
    """
    Extended API client with advanced intelligence gathering
    """
    
    def __init__(self, base_url: str, **kwargs):
        super().__init__(base_url, **kwargs)
        self.intel_report = {}
    
    def gather_intelligence(self, full_scan: bool = True) -> APIIntel:
        """
        Gather comprehensive API intelligence
        
        Args:
            full_scan: Perform full scan including brute force
            
        Returns:
            APIIntel object with gathered intelligence
        """
        print(f"[*] Gathering intelligence for API at {self.base_url}")
        print("="*60)
        
        # 1. Discover Swagger/OpenAPI
        print("\n[1] Discovering Swagger/OpenAPI...")
        swagger_paths = [
            '/swagger/v1/swagger.json',
            '/swagger.json',
            '/swagger',
            '/api-docs',
            '/docs',
            '/openapi.json',
            '/openapi',
            '/api/v1/swagger.json'
        ]
        
        for path in swagger_paths:
            endpoints = self.discover_endpoints_from_swagger(path)
            if endpoints:
                break
        
        # 2. Discover resources
        print("\n[2] Discovering resources...")
        self.discover_resources('/api')
        
        # 3. Brute force endpoints if full scan
        if full_scan:
            print("\n[3] Brute forcing endpoints...")
            self.brute_force_endpoints('/api')
        
        # 4. Test authentication
        print("\n[4] Testing authentication...")
        self.test_auth_requirements()
        
        # 5. Analyze exposed data
        print("\n[5] Analyzing exposed data...")
        self.analyze_exposed_data()
        
        print("\n" + "="*60)
        print(f"[*] Intelligence gathering complete")
        print(f"[*] Found {len(self.intel.endpoints)} endpoints")
        print(f"[*] Found {len(self.intel.resources)} resources")
        
        return self.intel
    
    def test_auth_requirements(self) -> Dict[str, bool]:
        """
        Test which endpoints require authentication
        
        Returns:
            Dictionary of endpoint -> auth_required
        """
        results = {}
        
        for endpoint in self.intel.endpoints[:10]:  # Test first 10 endpoints
            try:
                # First, try without auth
                response_without = self.client.request(
                    method=endpoint.method,
                    url=endpoint.path,
                    allow_redirects=False
                )
                
                # Then try with auth
                if self.api_key:
                    response_with = self.get(endpoint.path)
                    
                    # Compare responses
                    auth_required = response_without.status_code in [401, 403]
                    
                    results[endpoint.path] = {
                        'auth_required': auth_required,
                        'status_without_auth': response_without.status_code,
                        'status_with_auth': response_with.status_code if response_with else None
                    }
                else:
                    # Just check if endpoint requires auth
                    auth_required = response_without.status_code in [401, 403]
                    results[endpoint.path] = {
                        'auth_required': auth_required,
                        'status_code': response_without.status_code
                    }
            except:
                results[endpoint.path] = {'error': True}
        
        return results
    
    def analyze_exposed_data(self) -> Dict[str, Any]:
        """
        Analyze API responses for exposed data
        
        Returns:
            Dictionary of exposed data findings
        """
        exposed = {}
        
        for resource in self.intel.resources[:5]:  # Check first 5 resources
            try:
                response = self.get(f'/api/{resource}')
                if response and response.status_code == 200:
                    analysis = self.analyze_response(response)
                    
                    if 'sensitive_data' in analysis:
                        exposed[resource] = analysis['sensitive_data']
                        
            except:
                continue
        
        self.intel.exposed_data = exposed
        return exposed

class DataParser:
    """
    Utility for parsing different data formats (JSON, XML, etc.)
    """
    
    @staticmethod
    def parse_json(data: str) -> Optional[Dict]:
        """Parse JSON data"""
        try:
            return json.loads(data)
        except:
            return None
    
    @staticmethod
    def parse_xml(data: str) -> Optional[Dict]:
        """Parse XML data"""
        try:
            root = ET.fromstring(data)
            return DataParser._xml_to_dict(root)
        except:
            return None
    
    @staticmethod
    def _xml_to_dict(element) -> Dict:
        """Convert XML element to dictionary"""
        result = {}
        
        for child in element:
            if len(child) == 0:
                result[child.tag] = child.text
            else:
                if child.tag not in result:
                    result[child.tag] = []
                result[child.tag].append(DataParser._xml_to_dict(child))
        
        return result
    
    @staticmethod
    def flatten_dict(data: Dict, prefix: str = '') -> Dict:
        """Flatten nested dictionary"""
        result = {}
        
        for key, value in data.items():
            new_key = f"{prefix}.{key}" if prefix else key
            
            if isinstance(value, dict):
                result.update(DataParser.flatten_dict(value, new_key))
            elif isinstance(value, list):
                for i, item in enumerate(value):
                    if isinstance(item, dict):
                        result.update(DataParser.flatten_dict(item, f"{new_key}[{i}]"))
                    else:
                        result[f"{new_key}[{i}]"] = item
            else:
                result[new_key] = value
        
        return result
    
    @staticmethod
    def extract_ips(data: Union[Dict, str]) -> List[str]:
        """Extract IP addresses from data"""
        ip_pattern = re.compile(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b')
        
        if isinstance(data, dict):
            data = json.dumps(data)
        elif not isinstance(data, str):
            data = str(data)
        
        return list(set(ip_pattern.findall(data)))
    
    @staticmethod
    def extract_urls(data: Union[Dict, str]) -> List[str]:
        """Extract URLs from data"""
        url_pattern = re.compile(r'https?://[^\s<>"\'{}|\\^`\[\]]+')
        
        if isinstance(data, dict):
            data = json.dumps(data)
        elif not isinstance(data, str):
            data = str(data)
        
        return list(set(url_pattern.findall(data)))
    
    @staticmethod
    def extract_emails(data: Union[Dict, str]) -> List[str]:
        """Extract email addresses from data"""
        email_pattern = re.compile(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')
        
        if isinstance(data, dict):
            data = json.dumps(data)
        elif not isinstance(data, str):
            data = str(data)
        
        return list(set(email_pattern.findall(data)))

def main():
    """Interactive API client demonstration"""
    print("="*60)
    print("  API INTERACTION & INTELLIGENCE GATHERING")
    print("="*60)
    
    # Get target API URL
    base_url = input("\nEnter API base URL (e.g., https://api.example.com): ").strip()
    if not base_url:
        print("[*] Using demo URL: https://jsonplaceholder.typicode.com")
        base_url = "https://jsonplaceholder.typicode.com"
    
    # Get API key if needed
    api_key = input("Enter API key (optional): ").strip()
    if not api_key:
        api_key = None
    
    # Create API client
    client = APIIntelligence(base_url, api_key=api_key)
    
    # Demonstrate API requests
    print("\n" + "="*60)
    print("  API REQUEST DEMONSTRATION")
    print("="*60)
    
    # 1. GET request
    print("\n[1] GET Request")
    response = client.get('/posts/1')
    if response and response.status_code == 200:
        data = response.json()
        print(f"  Post: {data.get('title', 'No title')[:50]}...")
        print(f"  User: {data.get('userId')}")
    
    # 2. POST request
    print("\n[2] POST Request")
    new_post = {
        'title': 'Test Post',
        'body': 'This is a test post',
        'userId': 1
    }
    response = client.post('/posts', json_data=new_post)
    if response and response.status_code == 201:
        data = response.json()
        print(f"  Created post ID: {data.get('id')}")
    
    # 3. GraphQL (if supported)
    print("\n[3] GraphQL Query (if available)")
    # Try GraphQL introspection
    result = client.graphql_introspection()
    if result:
        print("  GraphQL introspection successful!")
        schema = result.get('data', {}).get('__schema', {})
        print(f"  Query types: {schema.get('queryType', {}).get('name', 'N/A')}")
    else:
        print("  GraphQL not available")
    
    # 4. Intelligence gathering
    print("\n" + "="*60)
    print("  INTELLIGENCE GATHERING")
    print("="*60)
    
    intel = client.gather_intelligence(full_scan=False)
    
    # Display results
    print(f"\n[*] Intelligence Summary")
    print(f"  Endpoints discovered: {len(intel.endpoints)}")
    print(f"  Resources discovered: {len(intel.resources)}")
    print(f"  Total requests made: {intel.total_requests}")
    print(f"  Average response time: {intel.average_response_time:.2f}s")
    
    if intel.exposed_data:
        print(f"\n[!] Exposed sensitive data found!")
        for resource, data in intel.exposed_data.items():
            print(f"  {resource}: {data}")
    
    # Save intelligence report
    with open('api_intelligence.json', 'w') as f:
        json.dump(intel.to_dict(), f, indent=2)
    print("\n[*] Intelligence report saved to api_intelligence.json")
    
    print("\n[*] API Client ready for further interaction")
    print("[*] Use the client.get(), client.post(), etc. methods programmatically")

if __name__ == "__main__":
    # Parse command line arguments
    import argparse
    
    parser = argparse.ArgumentParser(
        description="API Interaction & Intelligence Gathering",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic API request
  python3 api_client.py https://api.example.com -e /users
  
  # GraphQL query
  python3 api_client.py https://graphql.example.com -g "query { users { id name } }"
  
  # Intelligence gathering
  python3 api_client.py https://api.example.com --intel
  
  # With API key
  python3 api_client.py https://api.example.com -k YOUR_API_KEY
        """
    )
    
    parser.add_argument('url', help='API base URL')
    parser.add_argument('-e', '--endpoint', help='Endpoint to request')
    parser.add_argument('-m', '--method', default='GET', help='HTTP method')
    parser.add_argument('-d', '--data', help='JSON data to send')
    parser.add_argument('-k', '--api-key', help='API key')
    parser.add_argument('-g', '--graphql', help='GraphQL query')
    parser.add_argument('--intel', action='store_true', help='Perform intelligence gathering')
    
    args = parser.parse_args()
    
    # Create client
    client = APIIntelligence(args.url, api_key=args.api_key)
    
    if args.intel:
        # Intelligence gathering
        intel = client.gather_intelligence()
        print(f"\n[*] Intelligence gathered")
        print(f"  Endpoints: {len(intel.endpoints)}")
        print(f"  Resources: {len(intel.resources)}")
    
    elif args.graphql:
        # GraphQL query
        result = client.graphql_query(args.graphql)
        if result:
            print(json.dumps(result, indent=2))
    
    elif args.endpoint:
        # REST request
        if args.data:
            data = json.loads(args.data)
            response = client.rest_request(args.method, args.endpoint, json_data=data)
        else:
            response = client.rest_request(args.method, args.endpoint)
        
        if response:
            print(f"Status: {response.status_code}")
            try:
                print(json.dumps(response.json(), indent=2))
            except:
                print(response.text)
    
    else:
        main()
```

### The Verification: Testing API Client

#### Test 1: Basic API Request

```bash
cd ~/hacking-toolkit/exploit
python3 api_client.py https://jsonplaceholder.typicode.com -e /posts/1
```

**Expected Output:**
```
Status: 200
{
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
  "body": "quia et suscipit..."
}
```

#### Test 2: Intelligence Gathering

```bash
python3 api_client.py https://jsonplaceholder.typicode.com --intel
```

**Expected Output:**
```
[*] Gathering intelligence for API at https://jsonplaceholder.typicode.com
============================================================

[1] Discovering Swagger/OpenAPI...
[*] Discovered 0 endpoints from Swagger

[2] Discovering resources...
[+] Found resource: users
[+] Found resource: admin
[+] Found resource: posts
[+] Found resource: comments
[+] Found resource: todos

[3] Brute forcing endpoints...
[+] Found endpoint: users (200)
[+] Found endpoint: admin (404)
...

[4] Testing authentication...
[5] Analyzing exposed data...

============================================================
[*] Intelligence gathering complete
[*] Found 15 endpoints
[*] Found 6 resources

[*] Intelligence Summary
  Endpoints discovered: 15
  Resources discovered: 6
  Total requests made: 45
  Average response time: 0.15s
```

#### Test 3: GraphQL Query

```python
# Create GraphQL test script
cat > graphql_test.py << 'EOF'
#!/usr/bin/env python3
from api_client import APIClient
import json

# Create client
client = APIClient('https://graphql.org/graphql')

# Test introspection
print("[*] Testing GraphQL introspection...")
result = client.graphql_introspection()

if result:
    print("[+] GraphQL introspection successful")
    schema = result.get('data', {}).get('__schema', {})
    print(f"  Types: {len(schema.get('types', []))}")
    print(f"  Directives: {len(schema.get('directives', []))}")
    
    # Save schema info
    with open('graphql_schema.json', 'w') as f:
        json.dump(result, f, indent=2)
    print("[*] Schema saved to graphql_schema.json")
else:
    print("[-] GraphQL introspection failed")

# Example GraphQL query
print("\n[*] Testing GraphQL query...")
query = """
{
  __schema {
    queryType {
      name
      fields {
        name
        type {
          name
          kind
        }
      }
    }
  }
}
"""

result = client.graphql_query(query)
if result:
    print("[+] Query successful")
    data = result.get('data', {})
    schema = data.get('__schema', {})
    query_type = schema.get('queryType', {})
    print(f"  Query type: {query_type.get('name')}")
    print(f"  Fields: {len(query_type.get('fields', []))}")
EOF

python3 graphql_test.py
```

#### Test 4: API Brute Forcing

```python
# Create API brute force script
cat > api_bruteforce.py << 'EOF'
#!/usr/bin/env python3
from api_client import APIClient
import json

# Target API
url = input("Enter API base URL: ").strip()
if not url:
    url = "https://jsonplaceholder.typicode.com"

# Create client
client = APIClient(url)

# Custom wordlist
wordlist = [
    'users', 'posts', 'comments', 'todos', 'albums',
    'photos', 'users', 'admin', 'login', 'auth',
    'profile', 'settings', 'config', 'status', 'health'
]

print(f"\n[*] Brute forcing API at {url}")
print(f"[*] Wordlist: {len(wordlist)} paths")

# Perform brute force
discovered = client.brute_force_endpoints('/api', wordlist)

print(f"\n[*] Found {len(discovered)} endpoints:")
for endpoint in discovered:
    print(f"  /api/{endpoint}")
EOF

python3 api_bruteforce.py
```

### Advanced Usage: Data Parsing Pipeline

```python
# Data parsing pipeline example
cat > data_pipeline.py << 'EOF'
#!/usr/bin/env python3
from api_client import APIClient, DataParser
import json

# Create client
client = APIClient('https://jsonplaceholder.typicode.com')

# Fetch data
print("[*] Fetching data...")
response = client.get('/posts')
if not response:
    print("[-] Failed to fetch data")
    sys.exit(1)

data = response.json()

# Parse and analyze data
print(f"[*] Analyzing {len(data)} records...")

# Flatten data structure
flat_data = DataParser.flatten_dict({'posts': data})

# Extract useful information
emails = DataParser.extract_emails(data)
urls = DataParser.extract_urls(data)
ips = DataParser.extract_ips(data)

print(f"\n[*] Extracted Information:")
print(f"  Emails: {len(emails)}")
for email in emails[:5]:
    print(f"    {email}")

print(f"  URLs: {len(urls)}")
for url in urls[:5]:
    print(f"    {url}")

print(f"  IPs: {len(ips)}")
for ip in ips[:5]:
    print(f"    {ip}")

# Save parsed data
analysis = {
    'record_count': len(data),
    'emails': emails,
    'urls': urls,
    'ips': ips,
    'flat_data': flat_data
}

with open('data_analysis.json', 'w') as f:
    json.dump(analysis, f, indent=2)
    
print("\n[*] Analysis saved to data_analysis.json")
EOF

python3 data_pipeline.py
```

### Troubleshooting Common Issues

#### 1. Rate Limiting

```python
# Handle rate limiting
def rate_limited_request(client, endpoint, max_retries=3):
    for attempt in range(max_retries):
        response = client.get(endpoint)
        
        if response and response.status_code == 429:
            wait_time = int(response.headers.get('Retry-After', 5))
            print(f"[*] Rate limited, waiting {wait_time}s...")
            time.sleep(wait_time)
            continue
        
        return response
    
    return None
```

#### 2. Authentication Issues

```python
# Handle different auth types
def setup_auth(client, auth_type, credentials):
    if auth_type == 'basic':
        client.client.set_auth_basic(
            credentials['username'],
            credentials['password']
        )
    elif auth_type == 'bearer':
        client.client.set_auth_bearer(credentials['token'])
    elif auth_type == 'api_key':
        client.client.set_auth_api_key(credentials['key'])
```

### Reference: Common API Patterns

| Pattern | Detection | Example |
|---------|-----------|---------|
| REST | `/api/v1/resource` | `/api/v1/users` |
| GraphQL | `/graphql` | `query { users { id } }` |
| WebSocket | `/ws` or `ws://` | WebSocket connections |
| RPC | `/rpc` or `/jsonrpc` | `{"method": "getUser"}` |
| SOAP | `/soap` or `.wsdl` | XML-based services |

---

**[GENERATED: Phase 3, Part 1: API Interaction & Intelligence Gathering]**

**[STARTING: Phase 3, Part 2: Custom Exploit Development]**
