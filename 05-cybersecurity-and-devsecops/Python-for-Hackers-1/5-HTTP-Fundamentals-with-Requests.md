# Phase 2: Web Reconnaissance & Automated Enumeration
## Part 1: HTTP Fundamentals with Requests

### The Target: HTTP Client Framework

By the end of this part, you will:
- Understand HTTP protocol fundamentals
- Master the Python Requests library for web interactions
- Build a robust HTTP client with session management
- Implement authentication handling and cookie management
- Create a framework for automated web reconnaissance

### The Concept: Understanding HTTP

Think of HTTP (Hypertext Transfer Protocol) like ordering food at a restaurant:

- **Client** = You (the customer)
- **Server** = The restaurant kitchen
- **Request** = Your order (what you want)
- **Response** = Your food (what you get)
- **Headers** = Special instructions (no onions, extra sauce)
- **Cookies** = Your loyalty card (remembering you from last time)
- **Session** = Your entire dining experience from start to finish

**HTTP Methods (What you want to do):**
- **GET** = "I want to see the menu" (retrieve data)
- **POST** = "I want to order food" (send data)
- **PUT** = "I want to update my order" (update data)
- **DELETE** = "I want to cancel my order" (delete data)

**HTTP Status Codes (The response you get):**
- **2xx (Success)** = "Your order is ready"
- **3xx (Redirection)** = "The restaurant moved"
- **4xx (Client Error)** = "You made a mistake" (404 = page not found)
- **5xx (Server Error)** = "The kitchen is on fire"

### The Implementation: HTTP Client Framework

#### File: `~/hacking-toolkit/web-attack/http_client.py`

```python
#!/usr/bin/env python3
"""
http_client.py - Advanced HTTP Client Framework
Provides robust HTTP client functionality with session management,
authentication, and request/response manipulation.
"""

import requests
import json
import time
import hashlib
import base64
from typing import Dict, Optional, Any, List, Tuple, Union
from urllib.parse import urljoin, urlparse, parse_qs
from requests.cookies import RequestsCookieJar
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
import threading
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class HTTPClient:
    """
    Advanced HTTP client with session management, retry logic,
    authentication, and request/response manipulation.
    """
    
    def __init__(self, base_url: str = None, timeout: int = 30,
                 max_retries: int = 3, user_agent: str = None,
                 verify_ssl: bool = False):
        """
        Initialize the HTTP client
        
        Args:
            base_url: Base URL for all requests
            timeout: Request timeout in seconds
            max_retries: Number of retries for failed requests
            user_agent: Custom User-Agent string
            verify_ssl: Whether to verify SSL certificates
        """
        self.base_url = base_url
        self.timeout = timeout
        self.verify_ssl = verify_ssl
        self.session = requests.Session()
        
        # Set default headers
        self.default_headers = {
            'User-Agent': user_agent or self._get_default_user_agent(),
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1'
        }
        self.session.headers.update(self.default_headers)
        
        # Setup retry strategy
        retry_strategy = Retry(
            total=max_retries,
            backoff_factor=0.5,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS", "POST", "PUT", "DELETE"]
        )
        
        adapter = HTTPAdapter(max_retries=retry_strategy)
        self.session.mount("http://", adapter)
        self.session.mount("https://", adapter)
        
        # Request history for analysis
        self.request_history = []
        self.last_request = None
        self.last_response = None
        
        # Statistics
        self.request_count = 0
        self.bytes_sent = 0
        self.bytes_received = 0
        self.lock = threading.Lock()
    
    def _get_default_user_agent(self) -> str:
        """
        Get a realistic default User-Agent
        
        Returns:
            User-Agent string
        """
        user_agents = [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/121.0'
        ]
        return user_agents[0]
    
    def set_header(self, name: str, value: str):
        """
        Set a default header for all requests
        
        Args:
            name: Header name
            value: Header value
        """
        self.default_headers[name] = value
        self.session.headers.update({name: value})
    
    def set_cookie(self, name: str, value: str, domain: str = None):
        """
        Set a cookie for the session
        
        Args:
            name: Cookie name
            value: Cookie value
            domain: Cookie domain
        """
        self.session.cookies.set(name, value, domain=domain)
    
    def set_auth_basic(self, username: str, password: str):
        """
        Set Basic authentication
        
        Args:
            username: Username
            password: Password
        """
        self.session.auth = (username, password)
        auth_string = base64.b64encode(f"{username}:{password}".encode()).decode()
        self.set_header('Authorization', f'Basic {auth_string}')
    
    def set_auth_bearer(self, token: str):
        """
        Set Bearer token authentication
        
        Args:
            token: Bearer token
        """
        self.set_header('Authorization', f'Bearer {token}')
    
    def set_auth_api_key(self, key: str, header_name: str = 'X-API-Key'):
        """
        Set API key authentication
        
        Args:
            key: API key
            header_name: Header name for the key
        """
        self.set_header(header_name, key)
    
    def _prepare_url(self, url: str) -> str:
        """
        Prepare URL by joining with base URL if needed
        
        Args:
            url: URL or path
            
        Returns:
            Full URL
        """
        if url.startswith(('http://', 'https://')):
            return url
        
        if self.base_url:
            return urljoin(self.base_url, url)
        
        return url
    
    def _log_request(self, method: str, url: str, headers: Dict,
                     data: Any = None, params: Dict = None):
        """
        Log request information
        
        Args:
            method: HTTP method
            url: Request URL
            headers: Request headers
            data: Request data
            params: Query parameters
        """
        log_entry = {
            'timestamp': datetime.now().isoformat(),
            'method': method,
            'url': url,
            'headers': headers,
            'data': data,
            'params': params
        }
        
        with self.lock:
            self.request_history.append(log_entry)
            self.request_count += 1
            self.last_request = log_entry
        
        logger.debug(f"[{method}] {url}")
        if data:
            logger.debug(f"Data: {data[:200]}")
    
    def _log_response(self, response: requests.Response):
        """
        Log response information
        
        Args:
            response: Response object
        """
        with self.lock:
            self.bytes_received += len(response.content)
            self.last_response = response
        
        logger.debug(f"Status: {response.status_code}")
        logger.debug(f"Size: {len(response.content)} bytes")
    
    def request(self, method: str, url: str, params: Dict = None,
                data: Any = None, json_data: Dict = None,
                headers: Dict = None, cookies: Dict = None,
                files: Dict = None, allow_redirects: bool = True,
                stream: bool = False, timeout: int = None) -> requests.Response:
        """
        Make an HTTP request with full control
        
        Args:
            method: HTTP method
            url: URL or path
            params: Query parameters
            data: Form data
            json_data: JSON data
            headers: Custom headers
            cookies: Custom cookies
            files: Files to upload
            allow_redirects: Follow redirects
            stream: Stream response
            timeout: Custom timeout
            
        Returns:
            Response object
        """
        # Prepare URL
        full_url = self._prepare_url(url)
        
        # Merge headers
        request_headers = self.default_headers.copy()
        if headers:
            request_headers.update(headers)
        
        # Log request
        self._log_request(method, full_url, request_headers, data or json_data, params)
        
        try:
            # Make request
            response = self.session.request(
                method=method,
                url=full_url,
                params=params,
                data=data,
                json=json_data,
                headers=request_headers,
                cookies=cookies,
                files=files,
                allow_redirects=allow_redirects,
                stream=stream,
                timeout=timeout or self.timeout,
                verify=self.verify_ssl
            )
            
            # Log response
            self._log_response(response)
            
            return response
            
        except requests.exceptions.Timeout:
            logger.error(f"Request timeout: {full_url}")
            raise
        except requests.exceptions.ConnectionError:
            logger.error(f"Connection error: {full_url}")
            raise
        except requests.exceptions.RequestException as e:
            logger.error(f"Request error: {e}")
            raise
    
    def get(self, url: str, params: Dict = None, **kwargs) -> requests.Response:
        """GET request"""
        return self.request('GET', url, params=params, **kwargs)
    
    def post(self, url: str, data: Dict = None, json_data: Dict = None,
             **kwargs) -> requests.Response:
        """POST request"""
        return self.request('POST', url, data=data, json_data=json_data, **kwargs)
    
    def put(self, url: str, data: Dict = None, json_data: Dict = None,
            **kwargs) -> requests.Response:
        """PUT request"""
        return self.request('PUT', url, data=data, json_data=json_data, **kwargs)
    
    def delete(self, url: str, **kwargs) -> requests.Response:
        """DELETE request"""
        return self.request('DELETE', url, **kwargs)
    
    def head(self, url: str, **kwargs) -> requests.Response:
        """HEAD request"""
        return self.request('HEAD', url, **kwargs)
    
    def options(self, url: str, **kwargs) -> requests.Response:
        """OPTIONS request"""
        return self.request('OPTIONS', url, **kwargs)
    
    def patch(self, url: str, data: Dict = None, json_data: Dict = None,
              **kwargs) -> requests.Response:
        """PATCH request"""
        return self.request('PATCH', url, data=data, json_data=json_data, **kwargs)
    
    def follow_redirects(self, url: str, max_redirects: int = 10,
                         **kwargs) -> List[requests.Response]:
        """
        Follow all redirects manually
        
        Args:
            url: Initial URL
            max_redirects: Maximum redirects to follow
            
        Returns:
            List of responses from each redirect
        """
        responses = []
        current_url = url
        redirect_count = 0
        
        while redirect_count < max_redirects:
            response = self.get(current_url, allow_redirects=False, **kwargs)
            responses.append(response)
            
            # Check if redirect
            if response.status_code in [301, 302, 303, 307, 308]:
                location = response.headers.get('Location')
                if location:
                    current_url = urljoin(current_url, location)
                    redirect_count += 1
                    continue
            
            break
        
        return responses
    
    def get_redirect_chain(self, url: str, **kwargs) -> List[str]:
        """
        Get the full redirect chain for a URL
        
        Args:
            url: Initial URL
            
        Returns:
            List of URLs in the redirect chain
        """
        responses = self.follow_redirects(url, **kwargs)
        return [r.url for r in responses]
    
    def parse_response(self, response: requests.Response) -> Dict[str, Any]:
        """
        Parse response and extract useful information
        
        Args:
            response: Response object
            
        Returns:
            Dictionary with parsed information
        """
        info = {
            'url': response.url,
            'status_code': response.status_code,
            'headers': dict(response.headers),
            'cookies': {k: v for k, v in response.cookies.items()},
            'size': len(response.content),
            'content_type': response.headers.get('content-type', ''),
            'encoding': response.encoding,
            'history': [r.url for r in response.history]
        }
        
        # Try to parse JSON
        try:
            if 'application/json' in info['content_type']:
                info['json'] = response.json()
        except:
            pass
        
        # Try to extract title
        try:
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(response.text, 'html.parser')
            title = soup.find('title')
            if title:
                info['title'] = title.string.strip()
        except:
            pass
        
        return info
    
    def get_stats(self) -> Dict[str, Any]:
        """
        Get client statistics
        
        Returns:
            Dictionary with statistics
        """
        return {
            'request_count': self.request_count,
            'bytes_sent': self.bytes_sent,
            'bytes_received': self.bytes_received,
            'history_size': len(self.request_history)
        }
    
    def save_history(self, filename: str = 'request_history.json'):
        """
        Save request history to file
        
        Args:
            filename: Output filename
        """
        with open(filename, 'w') as f:
            json.dump(self.request_history, f, indent=2, default=str)
        logger.info(f"History saved to {filename}")

class WebRecon(HTTPClient):
    """
    Extended HTTP client with web reconnaissance capabilities
    """
    
    def __init__(self, base_url: str, **kwargs):
        """
        Initialize web reconnaissance client
        
        Args:
            base_url: Base URL for all requests
            **kwargs: Additional arguments for HTTPClient
        """
        super().__init__(base_url, **kwargs)
        self.discovered_paths = []
        self.discovered_parameters = []
        
    def analyze_headers(self, response: requests.Response) -> Dict[str, Any]:
        """
        Analyze response headers for security information
        
        Args:
            response: Response object
            
        Returns:
            Dictionary with header analysis
        """
        analysis = {
            'server': response.headers.get('Server', 'Unknown'),
            'powered_by': response.headers.get('X-Powered-By', 'Unknown'),
            'security_headers': {},
            'missing_security_headers': []
        }
        
        # Check for security headers
        security_headers = {
            'Strict-Transport-Security': 'HSTS header',
            'X-Frame-Options': 'Clickjacking protection',
            'X-Content-Type-Options': 'MIME sniffing protection',
            'Content-Security-Policy': 'XSS protection',
            'X-XSS-Protection': 'Legacy XSS protection',
            'Referrer-Policy': 'Referrer policy',
            'Permissions-Policy': 'Feature policy'
        }
        
        for header, description in security_headers.items():
            if header in response.headers:
                analysis['security_headers'][header] = response.headers[header]
            else:
                analysis['missing_security_headers'].append(description)
        
        return analysis
    
    def discover_parameters(self, response: requests.Response,
                           base_url: str = None) -> List[Dict]:
        """
        Discover parameters from forms and URLs
        
        Args:
            response: Response object
            base_url: Base URL for absolute URLs
            
        Returns:
            List of discovered parameters
        """
        parameters = []
        
        # Parse parameters from URL
        parsed = urlparse(response.url)
        if parsed.query:
            query_params = parse_qs(parsed.query)
            for param, values in query_params.items():
                parameters.append({
                    'source': 'url',
                    'name': param,
                    'value': values[0] if values else '',
                    'type': 'query'
                })
        
        # Parse parameters from forms
        try:
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(response.text, 'html.parser')
            forms = soup.find_all('form')
            
            for form in forms:
                form_data = {
                    'action': form.get('action'),
                    'method': form.get('method', 'get').lower(),
                    'parameters': []
                }
                
                # Get form inputs
                inputs = form.find_all(['input', 'select', 'textarea'])
                for input_tag in inputs:
                    param = {
                        'name': input_tag.get('name'),
                        'type': input_tag.get('type', 'text'),
                        'value': input_tag.get('value', ''),
                        'required': input_tag.get('required', False)
                    }
                    if param['name']:
                        form_data['parameters'].append(param)
                        parameters.append({
                            'source': 'form',
                            'form_action': form_data['action'],
                            'form_method': form_data['method'],
                            'name': param['name'],
                            'type': param['type'],
                            'required': param['required']
                        })
                
                self.discovered_parameters.append(form_data)
                
        except:
            pass
        
        return parameters
    
    def discover_links(self, response: requests.Response,
                      base_url: str = None) -> List[str]:
        """
        Discover links from HTML content
        
        Args:
            response: Response object
            base_url: Base URL for absolute URLs
            
        Returns:
            List of discovered links
        """
        links = []
        
        try:
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find all <a> and <link> tags
            for tag in soup.find_all(['a', 'link']):
                href = tag.get('href')
                if href:
                    # Convert to absolute URL
                    if base_url:
                        absolute_url = urljoin(base_url, href)
                    else:
                        absolute_url = urljoin(response.url, href)
                    links.append(absolute_url)
            
        except:
            pass
        
        return links
    
    def check_common_paths(self, paths: List[str],
                           expected_statuses: List[int] = [200, 301, 302, 403]) -> Dict:
        """
        Check multiple paths for existence
        
        Args:
            paths: List of paths to check
            expected_statuses: Status codes considered successful
            
        Returns:
            Dictionary with found paths
        """
        results = {}
        
        for path in paths:
            try:
                response = self.get(path, allow_redirects=False)
                if response.status_code in expected_statuses:
                    results[path] = {
                        'status': response.status_code,
                        'size': len(response.content),
                        'title': self.parse_response(response).get('title', '')
                    }
                    self.discovered_paths.append(path)
            except:
                continue
        
        return results
    
    def spider(self, start_path: str = '/', max_depth: int = 3,
               allowed_domains: List[str] = None) -> List[str]:
        """
        Simple web spider to discover pages
        
        Args:
            start_path: Starting path
            max_depth: Maximum depth to crawl
            allowed_domains: Domains to stay within
            
        Returns:
            List of discovered URLs
        """
        discovered = set()
        to_visit = [(start_path, 0)]  # (path, depth)
        visited = set()
        
        if allowed_domains is None:
            allowed_domains = [urlparse(self.base_url).netloc]
        
        while to_visit and len(discovered) < 500:
            path, depth = to_visit.pop(0)
            
            if path in visited or depth > max_depth:
                continue
            
            visited.add(path)
            
            try:
                response = self.get(path)
                discovered.add(response.url)
                
                # Discover links
                links = self.discover_links(response)
                
                # Process links
                for link in links:
                    parsed = urlparse(link)
                    
                    # Check if link is within allowed domains
                    if parsed.netloc and parsed.netloc not in allowed_domains:
                        continue
                    
                    # Convert to path
                    if parsed.path and parsed.path not in visited:
                        to_visit.append((parsed.path, depth + 1))
                        
            except:
                continue
        
        return list(discovered)

def main():
    """Demonstrate HTTP client functionality"""
    print("="*60)
    print("  HTTP CLIENT FRAMEWORK DEMONSTRATION")
    print("="*60)
    
    # Create client
    client = HTTPClient(timeout=10)
    
    # Test 1: GET request
    print("\n[Test 1: GET Request]")
    try:
        response = client.get('https://httpbin.org/get', params={'test': 'value'})
        print(f"Status: {response.status_code}")
        data = response.json()
        print(f"URL: {data.get('url')}")
        print(f"Headers: {data.get('headers', {}).get('User-Agent', '')[:50]}...")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 2: POST with JSON
    print("\n[Test 2: POST with JSON]")
    try:
        data = {'name': 'Hacker', 'title': 'Python for Hackers'}
        response = client.post('https://httpbin.org/post', json_data=data)
        print(f"Status: {response.status_code}")
        json_response = response.json()
        print(f"JSON data: {json_response.get('json')}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 3: Basic authentication
    print("\n[Test 3: Basic Authentication]")
    try:
        client.set_auth_basic('user', 'pass')
        response = client.get('https://httpbin.org/basic-auth/user/pass')
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 4: Web reconnaissance
    print("\n[Test 4: Web Reconnaissance]")
    recon = WebRecon('https://example.com')
    
    try:
        # Get homepage
        response = recon.get('/')
        print(f"Status: {response.status_code}")
        
        # Analyze headers
        header_analysis = recon.analyze_headers(response)
        print(f"Server: {header_analysis['server']}")
        print(f"Missing security headers: {header_analysis['missing_security_headers']}")
        
        # Discover links
        links = recon.discover_links(response)
        print(f"Found {len(links)} links")
        
        # Discover parameters
        params = recon.discover_parameters(response)
        print(f"Found {len(params)} parameters")
        
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 5: Custom headers
    print("\n[Test 5: Custom Headers]")
    client.set_header('X-Custom-Header', 'MyCustomValue')
    try:
        response = client.get('https://httpbin.org/headers')
        headers = response.json().get('headers', {})
        print(f"Custom header: {headers.get('X-Custom-Header', 'Not found')}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n[*] HTTP Client framework ready for use")
    print("[*] Try: python3 http_client.py --interactive")

if __name__ == "__main__":
    # Parse command line arguments
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == '--interactive':
        # Interactive mode - will be implemented in the next part
        print("[*] Interactive mode coming soon!")
    else:
        main()
```

### The Verification: Testing HTTP Client

#### Test 1: Basic HTTP Operations

```bash
cd ~/hacking-toolkit/web-attack
python3 http_client.py
```

**Expected Output:**
```
============================================================
  HTTP CLIENT FRAMEWORK DEMONSTRATION
============================================================

[Test 1: GET Request]
Status: 200
URL: https://httpbin.org/get?test=value
Headers: Mozilla/5.0 (Windows NT 10.0; Win64; x64) A...

[Test 2: POST with JSON]
Status: 200
JSON data: {'name': 'Hacker', 'title': 'Python for Hackers'}

[Test 3: Basic Authentication]
Status: 200
Response: {'authenticated': True, 'user': 'user'}

[Test 4: Web Reconnaissance]
Status: 200
Server: ECS (lga/14B8)
Missing security headers: ['HSTS header', 'Clickjacking protection', ...]
Found 12 links
Found 0 parameters

[Test 5: Custom Headers]
Custom header: MyCustomValue

[*] HTTP Client framework ready for use
```

#### Test 2: Interactive Web Reconnaissance

```python
# Create a reconnaissance script
cat > recon_website.py << 'EOF'
#!/usr/bin/env python3
from http_client import WebRecon
from urllib.parse import urlparse

# Target website
target = input("Enter target URL (e.g., https://example.com): ").strip()
if not target.startswith(('http://', 'https://')):
    target = 'https://' + target

# Create client
client = WebRecon(target, timeout=15, verify_ssl=False)

print(f"\n[*] Reconnaissance on {target}")
print("="*60)

# 1. GET home page
print("\n[1] Homepage Analysis")
response = client.get('/')
info = client.parse_response(response)
print(f"Status: {response.status_code}")
print(f"Title: {info.get('title', 'No title found')}")
print(f"Content Type: {info.get('content_type', 'Unknown')}")
print(f"Size: {info.get('size', 0)} bytes")

# 2. Header analysis
print("\n[2] Security Headers")
analysis = client.analyze_headers(response)
print(f"Server: {analysis['server']}")
print(f"Powered By: {analysis['powered_by']}")
print(f"Missing Security Headers: {len(analysis['missing_security_headers'])}")
for missing in analysis['missing_security_headers'][:5]:
    print(f"  - {missing}")

# 3. Link discovery
print("\n[3] Link Discovery")
links = client.discover_links(response)[:10]
print(f"Found {len(links)} links total")
print(f"Sample: {links[:3]}")

# 4. Parameter discovery
print("\n[4] Parameter Discovery")
params = client.discover_parameters(response)
print(f"Found {len(params)} parameters")
for param in params[:5]:
    print(f"  - {param.get('name', 'Unknown')} ({param.get('source', 'unknown')})")

# 5. Check common paths
print("\n[5] Common Path Checks")
common_paths = ['admin', 'login', 'wp-admin', 'administrator', 'backup', 'config']
results = client.check_common_paths(common_paths)
print(f"Found {len(results)} accessible paths:")
for path, info in results.items():
    print(f"  - {path}: Status {info['status']}")

print("\n[*] Reconnaissance complete!")
print(f"[*] Discovered {len(client.discovered_paths)} paths")
EOF

python3 recon_website.py
```

#### Test 3: Response Analysis

```python
# Create response analysis script
cat > analyze_response.py << 'EOF'
#!/usr/bin/env python3
from http_client import HTTPClient
import json

client = HTTPClient()

# Test URL
url = input("Enter URL to analyze: ").strip()
if not url:
    url = "https://httpbin.org/anything"

# Make request
print(f"[*] Analyzing {url}")
response = client.get(url)

# Parse response
info = client.parse_response(response)

print("\n" + "="*60)
print("  RESPONSE ANALYSIS")
print("="*60)

print(f"\nStatus: {info['status_code']}")
print(f"URL: {info['url']}")
print(f"Content Type: {info['content_type']}")
print(f"Size: {info['size']} bytes")

print("\nHeaders:")
for key, value in list(info['headers'].items())[:10]:
    print(f"  {key}: {value}")

print("\nCookies:")
for key, value in info['cookies'].items():
    print(f"  {key}: {value}")

# Save full info
with open('response_analysis.json', 'w') as f:
    json.dump(info, f, indent=2)
print("\n[*] Full analysis saved to response_analysis.json")
EOF

python3 analyze_response.py
```

### Advanced Usage: Session Management

```python
# Session management example
cat > session_manager.py << 'EOF'
#!/usr/bin/env python3
from http_client import HTTPClient
import time

# Create client with session
client = HTTPClient('https://httpbin.org')

# Start a session
print("[*] Starting session")
response = client.post('/post', data={'action': 'login', 'user': 'hacker'})
print(f"Login: {response.status_code}")

# Session persists across requests
for i in range(3):
    response = client.get(f'/get?session_id={i}')
    print(f"Request {i}: {response.status_code}")
    time.sleep(0.5)

# Clear cookies
client.session.cookies.clear()

# After clearing cookies
response = client.get('/get')
print(f"After clearing cookies: {response.status_code}")
EOF

python3 session_manager.py
```

### Troubleshooting Common Issues

#### 1. SSL Certificate Errors

```python
# Disable SSL verification
client = HTTPClient(verify_ssl=False)

# Or use a custom certificate
client.session.verify = '/path/to/cert.pem'
```

#### 2. Timeout Issues

```python
# Increase timeout for slow sites
client = HTTPClient(timeout=60)

# Or set per-request timeout
response = client.get(url, timeout=120)
```

#### 3. Proxy Configuration

```python
# Configure proxy
proxies = {
    'http': 'http://proxy:8080',
    'https': 'https://proxy:8080'
}
client.session.proxies.update(proxies)
```

#### 4. Rate Limiting

```python
import time

def rate_limited_request(client, url, delay=1):
    """Make request with rate limiting"""
    time.sleep(delay)
    return client.get(url)

# Use it
for url in urls:
    response = rate_limited_request(client, url, delay=0.5)
```

### Reference: Common HTTP Headers

| Header | Purpose | Example |
|--------|---------|---------|
| User-Agent | Identify client | `Mozilla/5.0 (Windows NT 10.0; ...)` |
| Authorization | Authentication | `Bearer token123` |
| Content-Type | Data format | `application/json` |
| Cookie | Session data | `session_id=abc123` |
| Referer | Referring page | `https://example.com/page` |
| X-Forwarded-For | Client IP (proxy) | `192.168.1.100` |
| Accept | Accepted response types | `text/html,application/json` |

