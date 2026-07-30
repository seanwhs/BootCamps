# Phase 2: Web Reconnaissance & Automated Enumeration
## Part 3: HTML Parsing & Analysis

### The Target: HTML/XML Analysis Framework

By the end of this part, you will:
- Master BeautifulSoup and lxml for HTML/XML parsing
- Build a comprehensive HTML analysis framework
- Extract metadata, comments, forms, and potential vulnerabilities
- Identify exposed credentials and sensitive information
- Automate web content analysis

### The Concept: Understanding HTML Parsing

Think of HTML parsing like being a detective examining a crime scene:

- **HTML Document** = The crime scene (the webpage)
- **Tags** = Different rooms (div, section, header)
- **Attributes** = Items in each room (id, class, src)
- **Comments** = Hidden notes left behind
- **Forms** = Entry/exit points
- **JavaScript** = Security systems and traps

**Why We Parse HTML:**
- Extract hidden information from comments
- Find forms and their parameters for testing
- Discover API endpoints in JavaScript
- Identify metadata about the application
- Detect exposed credentials or sensitive data

### The Implementation: HTML Analysis Framework

#### File: `~/hacking-toolkit/web-attack/html_analyzer.py`

```python
#!/usr/bin/env python3
"""
html_analyzer.py - Advanced HTML/XML Analysis Framework
Provides comprehensive parsing and analysis of HTML content for security reconnaissance.
"""

import sys
import re
import json
from typing import List, Dict, Optional, Set, Tuple, Any
from urllib.parse import urljoin, urlparse, parse_qs
from dataclasses import dataclass, field
from datetime import datetime
import hashlib

# HTML Parsing Libraries
try:
    from bs4 import BeautifulSoup
    import lxml
    HAS_BS4 = True
except ImportError:
    HAS_BS4 = False
    print("[-] BeautifulSoup4 or lxml not installed. Install with: pip install beautifulsoup4 lxml")
    sys.exit(1)

# Import our HTTP client
try:
    from http_client import HTTPClient
except ImportError:
    print("[-] http_client.py not found. Please ensure it's in the same directory.")
    sys.exit(1)

@dataclass
class HTMLAnalysis:
    """Container for HTML analysis results"""
    url: str
    title: str = ''
    meta_data: Dict[str, str] = field(default_factory=dict)
    forms: List[Dict] = field(default_factory=list)
    links: List[Dict] = field(default_factory=list)
    scripts: List[Dict] = field(default_factory=list)
    styles: List[Dict] = field(default_factory=list)
    images: List[Dict] = field(default_factory=list)
    comments: List[str] = field(default_factory=list)
    emails: List[str] = field(default_factory=list)
    phone_numbers: List[str] = field(default_factory=list)
    potential_sensitive: List[Dict] = field(default_factory=list)
    endpoints: List[str] = field(default_factory=list)
    csp: Dict = field(default_factory=dict)
    iframes: List[Dict] = field(default_factory=list)
    vulnerabilities: List[Dict] = field(default_factory=list)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary"""
        return {
            'url': self.url,
            'title': self.title,
            'meta_data': self.meta_data,
            'forms': self.forms,
            'links': self.links[:10],  # Limit for readability
            'scripts': self.scripts[:10],
            'styles': self.styles[:10],
            'images': self.images[:10],
            'comments': self.comments[:10],
            'emails': self.emails,
            'phone_numbers': self.phone_numbers,
            'potential_sensitive': self.potential_sensitive,
            'endpoints': self.endpoints[:10],
            'csp': self.csp,
            'iframes': self.iframes,
            'vulnerabilities': self.vulnerabilities
        }

class HTMLAnalyzer:
    """
    Comprehensive HTML/XML analyzer with security focus
    Parses web pages to extract useful information for reconnaissance
    """
    
    # Common sensitive patterns
    SENSITIVE_PATTERNS = {
        'api_key': re.compile(r'(api[_-]?key|apikey|key)\s*[:=]\s*["\']?([a-zA-Z0-9_\-]+)["\']?', re.IGNORECASE),
        'secret': re.compile(r'(secret|token|password|passwd)\s*[:=]\s*["\']?([a-zA-Z0-9_\-]+)["\']?', re.IGNORECASE),
        'username': re.compile(r'(user(name)?|login|admin)\s*[:=]\s*["\']?([a-zA-Z0-9_\-@]+)["\']?', re.IGNORECASE),
        'email': re.compile(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
        'phone': re.compile(r'(\+?\d{1,3}[-.]?)?\(?\d{3}\)?[-.]?\d{3}[-.]?\d{4}'),
        'credit_card': re.compile(r'\b(?:\d[ -]*?){13,16}\b'),
        'aws_key': re.compile(r'AKIA[0-9A-Z]{16}'),
        'google_api_key': re.compile(r'AIza[0-9A-Za-z\-_]{35}'),
        'jwt': re.compile(r'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+'),
        'ip_address': re.compile(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b'),
        'url': re.compile(r'(https?://[^\s<>"\'{}|\\^`\[\]]+)')
    }
    
    # Common vulnerability indicators
    VULNERABILITY_INDICATORS = {
        'sql_injection': [
            'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'UNION',
            'FROM', 'WHERE', 'ORDER BY', 'GROUP BY'
        ],
        'xss': [
            '<script', 'alert(', 'onerror=', 'onload=',
            'javascript:', 'document.cookie', 'document.write'
        ],
        'path_traversal': [
            '../', '..\\', '/etc/passwd', 'C:\\', '/proc/'
        ],
        'file_inclusion': [
            'include(', 'require(', 'file_get_contents',
            'fopen(', 'readfile('
        ],
        'command_injection': [
            'exec(', 'system(', 'shell_exec(', 'passthru(',
            '`', '$('
        ]
    }
    
    def __init__(self, client: Optional[HTTPClient] = None):
        """
        Initialize the HTML analyzer
        
        Args:
            client: HTTP client instance (creates new if None)
        """
        self.client = client or HTTPClient(timeout=15)
        self.analyzed_urls = set()
        self.analysis_results = []
        
    def analyze_url(self, url: str, fetch_content: bool = True) -> Optional[HTMLAnalysis]:
        """
        Analyze a URL
        
        Args:
            url: URL to analyze
            fetch_content: Whether to fetch the content
            
        Returns:
            HTMLAnalysis object or None
        """
        if url in self.analyzed_urls:
            return None
        
        self.analyzed_urls.add(url)
        
        # Fetch content if needed
        html_content = None
        if fetch_content:
            try:
                response = self.client.get(url)
                html_content = response.text
                status_code = response.status_code
            except Exception as e:
                print(f"[-] Error fetching {url}: {e}")
                return None
        else:
            status_code = 200
        
        # Parse HTML
        return self.analyze_html(html_content, url, status_code)
    
    def analyze_html(self, html_content: str, url: str = '',
                     status_code: int = 200) -> HTMLAnalysis:
        """
        Analyze HTML content
        
        Args:
            html_content: HTML content to analyze
            url: URL of the content
            status_code: HTTP status code
            
        Returns:
            HTMLAnalysis object
        """
        analysis = HTMLAnalysis(url=url)
        
        if not html_content:
            return analysis
        
        try:
            # Parse with BeautifulSoup
            soup = BeautifulSoup(html_content, 'lxml')
            
            # Extract title
            if soup.title:
                analysis.title = soup.title.string.strip() if soup.title.string else ''
            
            # Extract metadata
            analysis.meta_data = self._extract_meta(soup)
            
            # Extract forms
            analysis.forms = self._extract_forms(soup, url)
            
            # Extract links
            analysis.links = self._extract_links(soup, url)
            
            # Extract scripts
            analysis.scripts = self._extract_scripts(soup, url)
            
            # Extract styles
            analysis.styles = self._extract_styles(soup, url)
            
            # Extract images
            analysis.images = self._extract_images(soup, url)
            
            # Extract comments
            analysis.comments = self._extract_comments(soup)
            
            # Extract emails
            analysis.emails = self._find_emails(html_content)
            
            # Extract phone numbers
            analysis.phone_numbers = self._find_phone_numbers(html_content)
            
            # Extract sensitive information
            analysis.potential_sensitive = self._find_sensitive(html_content)
            
            # Extract API endpoints
            analysis.endpoints = self._extract_endpoints(soup, html_content, url)
            
            # Extract CSP
            analysis.csp = self._extract_csp(soup)
            
            # Extract iframes
            analysis.iframes = self._extract_iframes(soup, url)
            
            # Find vulnerabilities
            analysis.vulnerabilities = self._find_vulnerabilities(html_content)
            
        except Exception as e:
            print(f"[-] Error parsing HTML: {e}")
        
        return analysis
    
    def _extract_meta(self, soup: BeautifulSoup) -> Dict[str, str]:
        """Extract metadata from HTML"""
        meta_data = {}
        
        # Get standard meta tags
        meta_tags = soup.find_all('meta')
        
        for tag in meta_tags:
            name = tag.get('name', '')
            property_name = tag.get('property', '')
            content = tag.get('content', '')
            
            if name:
                meta_data[name] = content
            elif property_name:
                meta_data[property_name] = content
        
        # Get generator
        generator = soup.find('meta', {'name': 'generator'})
        if generator:
            meta_data['generator'] = generator.get('content', '')
        
        return meta_data
    
    def _extract_forms(self, soup: BeautifulSoup, base_url: str) -> List[Dict]:
        """Extract and analyze forms"""
        forms = []
        
        for form in soup.find_all('form'):
            form_data = {
                'action': form.get('action', ''),
                'method': form.get('method', 'GET').upper(),
                'enctype': form.get('enctype', 'application/x-www-form-urlencoded'),
                'inputs': [],
                'has_file_upload': False,
                'has_submit': False,
                'has_hidden': False,
                'has_password': False,
                'action_url': urljoin(base_url, form.get('action', ''))
            }
            
            # Parse inputs
            for input_tag in form.find_all(['input', 'select', 'textarea']):
                input_data = {
                    'name': input_tag.get('name', ''),
                    'type': input_tag.get('type', 'text'),
                    'value': input_tag.get('value', ''),
                    'required': input_tag.get('required', False) is not False,
                }
                
                # Check for hidden inputs
                if input_data['type'] == 'hidden':
                    form_data['has_hidden'] = True
                
                # Check for password
                if input_data['type'] == 'password':
                    form_data['has_password'] = True
                
                # Check for file upload
                if input_data['type'] == 'file':
                    form_data['has_file_upload'] = True
                
                # Check for submit
                if input_data['type'] in ['submit', 'image']:
                    form_data['has_submit'] = True
                
                # Handle select options
                if input_tag.name == 'select':
                    options = []
                    for option in input_tag.find_all('option'):
                        options.append({
                            'value': option.get('value', ''),
                            'text': option.string
                        })
                    input_data['options'] = options
                
                form_data['inputs'].append(input_data)
            
            forms.append(form_data)
        
        return forms
    
    def _extract_links(self, soup: BeautifulSoup, base_url: str) -> List[Dict]:
        """Extract and analyze links"""
        links = []
        
        for a in soup.find_all('a', href=True):
            href = a.get('href', '')
            absolute_url = urljoin(base_url, href)
            
            link_data = {
                'href': href,
                'absolute_url': absolute_url,
                'text': a.string or '',
                'rel': a.get('rel', ''),
                'target': a.get('target', '')
            }
            
            # Check if it's an external link
            parsed_absolute = urlparse(absolute_url)
            parsed_base = urlparse(base_url)
            if parsed_absolute.netloc and parsed_absolute.netloc != parsed_base.netloc:
                link_data['external'] = True
            else:
                link_data['external'] = False
            
            links.append(link_data)
        
        return links
    
    def _extract_scripts(self, soup: BeautifulSoup, base_url: str) -> List[Dict]:
        """Extract and analyze scripts"""
        scripts = []
        
        for script in soup.find_all('script'):
            script_data = {
                'src': script.get('src', ''),
                'type': script.get('type', 'application/javascript'),
                'inline': False
            }
            
            if script.string:
                script_data['inline'] = True
                script_data['content'] = script.string[:500]  # Truncate for analysis
            elif script.get('src'):
                script_data['absolute_src'] = urljoin(base_url, script.get('src'))
            
            scripts.append(script_data)
        
        return scripts
    
    def _extract_styles(self, soup: BeautifulSoup, base_url: str) -> List[Dict]:
        """Extract and analyze styles"""
        styles = []
        
        for style in soup.find_all('link', rel='stylesheet'):
            style_data = {
                'href': style.get('href', ''),
                'type': style.get('type', 'text/css'),
                'media': style.get('media', 'all')
            }
            if style.get('href'):
                style_data['absolute_href'] = urljoin(base_url, style.get('href'))
            styles.append(style_data)
        
        # Inline styles
        for style in soup.find_all('style'):
            if style.string:
                styles.append({
                    'inline': True,
                    'content': style.string[:200]  # Truncate
                })
        
        return styles
    
    def _extract_images(self, soup: BeautifulSoup, base_url: str) -> List[Dict]:
        """Extract and analyze images"""
        images = []
        
        for img in soup.find_all('img'):
            img_data = {
                'src': img.get('src', ''),
                'alt': img.get('alt', ''),
                'width': img.get('width', ''),
                'height': img.get('height', '')
            }
            
            if img.get('src'):
                img_data['absolute_src'] = urljoin(base_url, img.get('src'))
            
            images.append(img_data)
        
        return images
    
    def _extract_comments(self, soup: BeautifulSoup) -> List[str]:
        """Extract HTML comments"""
        comments = []
        
        for comment in soup.find_all(string=lambda text: isinstance(text, str) and text.startswith('<!--')):
            comment_text = comment.strip()
            # Remove <!-- and -->
            comment_text = comment_text[4:-3].strip()
            
            if comment_text:
                comments.append(comment_text)
        
        return comments
    
    def _extract_iframes(self, soup: BeautifulSoup, base_url: str) -> List[Dict]:
        """Extract iframes"""
        iframes = []
        
        for iframe in soup.find_all('iframe'):
            iframe_data = {
                'src': iframe.get('src', ''),
                'width': iframe.get('width', ''),
                'height': iframe.get('height', ''),
                'sandbox': iframe.get('sandbox', '')
            }
            
            if iframe.get('src'):
                iframe_data['absolute_src'] = urljoin(base_url, iframe.get('src'))
            
            iframes.append(iframe_data)
        
        return iframes
    
    def _extract_csp(self, soup: BeautifulSoup) -> Dict:
        """Extract Content Security Policy"""
        csp = {}
        
        # Check meta tag
        meta_csp = soup.find('meta', {'http-equiv': 'Content-Security-Policy'})
        if meta_csp:
            csp['meta'] = meta_csp.get('content', '')
        
        # Check header (would need to be passed from client)
        # CSP headers are not in the HTML, they'd be in the response headers
        
        return csp
    
    def _extract_endpoints(self, soup: BeautifulSoup, html_content: str,
                          base_url: str) -> List[str]:
        """Extract potential API endpoints"""
        endpoints = set()
        
        # Look for endpoints in URLs within the page
        url_patterns = [
            r'api/[a-zA-Z0-9_\-/]+',
            r'v[0-9]+/[a-zA-Z0-9_\-/]+',
            r'endpoint/[a-zA-Z0-9_\-/]+',
            r'services/[a-zA-Z0-9_\-/]+',
            r'ajax/[a-zA-Z0-9_\-/]+',
            r'\.(json|xml|rss|feed)',
            r'[a-zA-Z0-9_\-]+\.(php|asp|aspx|jsp|do|action)'
        ]
        
        for pattern in url_patterns:
            matches = re.findall(pattern, html_content, re.IGNORECASE)
            for match in matches:
                # Convert to absolute URL
                if match.startswith('http'):
                    endpoints.add(match)
                else:
                    absolute = urljoin(base_url, match)
                    endpoints.add(absolute)
        
        return list(endpoints)
    
    def _find_emails(self, content: str) -> List[str]:
        """Find email addresses in content"""
        emails = set()
        pattern = self.SENSITIVE_PATTERNS['email']
        
        for match in pattern.finditer(content):
            emails.add(match.group(0))
        
        return list(emails)
    
    def _find_phone_numbers(self, content: str) -> List[str]:
        """Find phone numbers in content"""
        phone_numbers = set()
        pattern = self.SENSITIVE_PATTERNS['phone']
        
        for match in pattern.finditer(content):
            phone_numbers.add(match.group(0))
        
        return list(phone_numbers)
    
    def _find_sensitive(self, content: str) -> List[Dict]:
        """Find sensitive information in content"""
        sensitive = []
        
        for key, pattern in self.SENSITIVE_PATTERNS.items():
            if key in ['email', 'phone', 'url']:
                continue
            
            for match in pattern.finditer(content):
                sensitive.append({
                    'type': key,
                    'match': match.group(0),
                    'context': content[max(0, match.start()-50):match.end()+50]
                })
        
        return sensitive
    
    def _find_vulnerabilities(self, content: str) -> List[Dict]:
        """Find potential vulnerabilities in content"""
        vulnerabilities = []
        
        for vuln_type, indicators in self.VULNERABILITY_INDICATORS.items():
            for indicator in indicators:
                if indicator.lower() in content.lower():
                    # Find context
                    index = content.lower().find(indicator.lower())
                    if index != -1:
                        context = content[max(0, index-50):index+len(indicator)+50]
                        vulnerabilities.append({
                            'type': vuln_type,
                            'indicator': indicator,
                            'context': context
                        })
        
        return vulnerabilities
    
    def analyze_page_for_vulnerabilities(self, html_content: str) -> Dict[str, Any]:
        """
        Perform vulnerability analysis on HTML content
        
        Args:
            html_content: HTML content to analyze
            
        Returns:
            Dictionary with vulnerability findings
        """
        analysis = {
            'sql_injection_vectors': [],
            'xss_vectors': [],
            'path_traversal_vectors': [],
            'file_inclusion_vectors': [],
            'command_injection_vectors': [],
            'sensitive_data': [],
            'insecure_forms': []
        }
        
        # Check for SQL injection patterns
        for pattern in self.VULNERABILITY_INDICATORS['sql_injection']:
            if pattern in html_content:
                analysis['sql_injection_vectors'].append(pattern)
        
        # Check for XSS patterns
        for pattern in self.VULNERABILITY_INDICATORS['xss']:
            if pattern in html_content:
                analysis['xss_vectors'].append(pattern)
        
        # Check for sensitive data
        for key, pattern in self.SENSITIVE_PATTERNS.items():
            if key in ['email', 'phone']:
                continue
            matches = pattern.findall(html_content)
            if matches:
                analysis['sensitive_data'].extend(matches)
        
        return analysis

class WebContentScanner(HTMLAnalyzer):
    """
    Extended analyzer for scanning multiple pages
    Performs comprehensive website reconnaissance
    """
    
    def __init__(self, base_url: str, **kwargs):
        """
        Initialize the web content scanner
        
        Args:
            base_url: Base URL to scan
            **kwargs: Additional arguments for HTMLAnalyzer
        """
        super().__init__(**kwargs)
        self.base_url = base_url
        self.scanned_pages = {}
        
    def scan_site(self, max_pages: int = 50) -> Dict[str, HTMLAnalysis]:
        """
        Scan the entire website
        
        Args:
            max_pages: Maximum number of pages to scan
            
        Returns:
            Dictionary of URL -> analysis
        """
        print(f"[*] Starting website scan of {self.base_url}")
        print(f"[*] Max pages: {max_pages}")
        
        # Start with homepage
        to_scan = [self.base_url]
        scanned = set()
        results = {}
        
        while to_scan and len(scanned) < max_pages:
            url = to_scan.pop(0)
            
            if url in scanned:
                continue
            
            scanned.add(url)
            print(f"[*] Scanning: {url}")
            
            # Analyze page
            analysis = self.analyze_url(url)
            if analysis:
                results[url] = analysis
                
                # Add links to scan
                if analysis.links:
                    for link in analysis.links:
                        link_url = link.get('absolute_url')
                        if link_url and not link.get('external', True):
                            parsed = urlparse(link_url)
                            if parsed.netloc == urlparse(self.base_url).netloc:
                                to_scan.append(link_url)
        
        self.scanned_pages = results
        print(f"[*] Scanned {len(results)} pages")
        
        return results
    
    def generate_report(self) -> Dict[str, Any]:
        """
        Generate a comprehensive security report
        
        Returns:
            Dictionary with report data
        """
        report = {
            'base_url': self.base_url,
            'pages_scanned': len(self.scanned_pages),
            'total_forms': 0,
            'total_links': 0,
            'total_scripts': 0,
            'emails_found': [],
            'sensitive_data': [],
            'vulnerabilities': [],
            'forms_with_password': [],
            'pages_with_comments': [],
            'pages_with_csp': []
        }
        
        for url, analysis in self.scanned_pages.items():
            # Count forms
            report['total_forms'] += len(analysis.forms)
            
            # Count links
            report['total_links'] += len(analysis.links)
            
            # Count scripts
            report['total_scripts'] += len(analysis.scripts)
            
            # Collect emails
            for email in analysis.emails:
                if email not in report['emails_found']:
                    report['emails_found'].append(email)
            
            # Collect sensitive data
            for sensitive in analysis.potential_sensitive:
                report['sensitive_data'].append({
                    'url': url,
                    'data': sensitive
                })
            
            # Collect vulnerabilities
            for vuln in analysis.vulnerabilities:
                report['vulnerabilities'].append({
                    'url': url,
                    'vulnerability': vuln
                })
            
            # Check for password fields
            for form in analysis.forms:
                if form.get('has_password'):
                    report['forms_with_password'].append({
                        'url': url,
                        'form': form
                    })
            
            # Check for comments
            if analysis.comments:
                report['pages_with_comments'].append({
                    'url': url,
                    'comments': analysis.comments
                })
            
            # Check for CSP
            if analysis.csp:
                report['pages_with_csp'].append({
                    'url': url,
                    'csp': analysis.csp
                })
        
        return report

def main():
    """Interactive HTML analysis demonstration"""
    print("="*60)
    print("  HTML ANALYSIS FRAMEWORK")
    print("="*60)
    
    # Create analyzer
    analyzer = HTMLAnalyzer()
    
    # Example 1: Analyze a single page
    print("\n[Example 1: Analyzing a Single Page]")
    url = input("Enter URL to analyze (default: https://example.com): ").strip()
    if not url:
        url = "https://example.com"
    
    analysis = analyzer.analyze_url(url)
    
    if analysis:
        print(f"\n[*] Analysis Results for {url}")
        print(f"Title: {analysis.title}")
        print(f"Meta data: {analysis.meta_data}")
        print(f"Forms found: {len(analysis.forms)}")
        print(f"Links found: {len(analysis.links)}")
        print(f"Scripts found: {len(analysis.scripts)}")
        print(f"Comments: {len(analysis.comments)}")
        print(f"Emails found: {analysis.emails}")
        
        if analysis.potential_sensitive:
            print(f"Potential sensitive data: {len(analysis.potential_sensitive)}")
            for item in analysis.potential_sensitive[:3]:
                print(f"  - {item['type']}: {item['match']}")
        
        if analysis.vulnerabilities:
            print(f"Potential vulnerabilities: {len(analysis.vulnerabilities)}")
            for vuln in analysis.vulnerabilities[:3]:
                print(f"  - {vuln['type']}: {vuln['indicator']}")
        
        # Save detailed results
        with open('analysis_results.json', 'w') as f:
            json.dump(analysis.to_dict(), f, indent=2)
        print("\n[*] Detailed results saved to analysis_results.json")
    
    # Example 2: Website scan
    print("\n[Example 2: Website Scan]")
    base_url = input("Enter base URL to scan (default: https://example.com): ").strip()
    if not base_url:
        base_url = "https://example.com"
    
    scanner = WebContentScanner(base_url)
    results = scanner.scan_site(max_pages=10)
    
    if results:
        print(f"\n[*] Scan Results Summary")
        print(f"Pages scanned: {len(results)}")
        
        # Generate report
        report = scanner.generate_report()
        print(f"Total forms: {report['total_forms']}")
        print(f"Total links: {report['total_links']}")
        print(f"Total scripts: {report['total_scripts']}")
        print(f"Emails found: {report['emails_found']}")
        print(f"Pages with comments: {len(report['pages_with_comments'])}")
        
        if report['sensitive_data']:
            print(f"Potential sensitive data: {len(report['sensitive_data'])}")
        
        if report['vulnerabilities']:
            print(f"Potential vulnerabilities: {len(report['vulnerabilities'])}")
        
        # Save report
        with open('website_scan_report.json', 'w') as f:
            json.dump(report, f, indent=2)
        print("\n[*] Full report saved to website_scan_report.json")

if __name__ == "__main__":
    main()
```

### The Verification: Testing HTML Analysis

#### Test 1: Basic Analysis

```bash
cd ~/hacking-toolkit/web-attack
python3 html_analyzer.py
```

**Expected Output:**
```
============================================================
  HTML ANALYSIS FRAMEWORK
============================================================

[Example 1: Analyzing a Single Page]
Enter URL to analyze (default: https://example.com): 

[*] Analysis Results for https://example.com
Title: Example Domain
Meta data: {'viewport': 'width=device-width, initial-scale=1', 'generator': '...'}
Forms found: 0
Links found: 1
Scripts found: 0
Comments: 1
Emails found: []
Potential sensitive data: 0
Potential vulnerabilities: 0

[*] Detailed results saved to analysis_results.json
```

#### Test 2: Website Scanner

```bash
python3 html_analyzer.py
# Select example 2 when prompted
```

**Expected Output:**
```
[Example 2: Website Scan]
Enter base URL to scan (default: https://example.com): 

[*] Starting website scan of https://example.com
[*] Max pages: 10
[*] Scanning: https://example.com
[*] Scanning: https://example.com/page1
[*] Scanning: https://example.com/page2
[*] Scanned 10 pages

[*] Scan Results Summary
Pages scanned: 10
Total forms: 3
Total links: 45
Total scripts: 12
Emails found: ['admin@example.com', 'contact@example.com']
Pages with comments: 2
Potential sensitive data: 0
Potential vulnerabilities: 2

[*] Full report saved to website_scan_report.json
```

#### Test 3: Programmatic Analysis

```python
# Create an analysis script
cat > analyze_page.py << 'EOF'
#!/usr/bin/env python3
from html_analyzer import HTMLAnalyzer
from http_client import HTTPClient
import json

# Create HTTP client with custom headers
client = HTTPClient()
client.set_header('User-Agent', 'Mozilla/5.0 (Compatible; SecurityScanner/1.0)')

# Create analyzer
analyzer = HTMLAnalyzer(client)

# URLs to analyze
urls = [
    'https://example.com',
    'https://httpbin.org/forms/post',
    'https://httpbin.org/html'
]

for url in urls:
    print(f"\n[*] Analyzing: {url}")
    analysis = analyzer.analyze_url(url)
    
    if analysis:
        print(f"  Title: {analysis.title}")
        print(f"  Forms: {len(analysis.forms)}")
        print(f"  Links: {len(analysis.links)}")
        print(f"  Comments: {len(analysis.comments)}")
        
        # Check for sensitive data
        if analysis.potential_sensitive:
            print(f"  [!] Potential sensitive data found!")
            for item in analysis.potential_sensitive:
                print(f"    - {item['type']}: {item['match'][:50]}")
        
        # Check for vulnerability indicators
        if analysis.vulnerabilities:
            print(f"  [!] Potential vulnerabilities detected!")
            for vuln in analysis.vulnerabilities[:3]:
                print(f"    - {vuln['type']}: {vuln['indicator']}")
EOF

python3 analyze_page.py
```

#### Test 4: Advanced Form Analysis

```python
# Form analysis script
cat > analyze_forms.py << 'EOF'
#!/usr/bin/env python3
from html_analyzer import HTMLAnalyzer

analyzer = HTMLAnalyzer()

# Analyze a page with forms
url = 'https://httpbin.org/forms/post'
analysis = analyzer.analyze_url(url)

if analysis and analysis.forms:
    print(f"[*] Found {len(analysis.forms)} forms\n")
    
    for i, form in enumerate(analysis.forms, 1):
        print(f"Form {i}:")
        print(f"  Action: {form['action']}")
        print(f"  Method: {form['method']}")
        print(f"  Action URL: {form['action_url']}")
        print(f"  Has file upload: {form['has_file_upload']}")
        print(f"  Has password: {form['has_password']}")
        print(f"  Inputs: {len(form['inputs'])}")
        
        for input_field in form['inputs']:
            print(f"    - {input_field['name']} ({input_field['type']})")
            if input_field.get('options'):
                print(f"      Options: {[opt['value'] for opt in input_field['options']]}")
        
        print()
EOF

python3 analyze_forms.py
```

### Advanced Usage: Automated Vulnerability Detection

```python
# Vulnerability detection script
cat > detect_vulnerabilities.py << 'EOF'
#!/usr/bin/env python3
from html_analyzer import HTMLAnalyzer
import json

analyzer = HTMLAnalyzer()

# URL to test
url = input("Enter URL to test for vulnerabilities: ").strip()
if not url:
    url = 'https://example.com'

print(f"[*] Scanning {url} for vulnerabilities...")
analysis = analyzer.analyze_url(url)

if analysis:
    vulns = analysis.vulnerabilities
    
    if vulns:
        print(f"\n[!] Found {len(vulns)} potential vulnerabilities:")
        for vuln in vulns:
            print(f"\n  Type: {vuln['type']}")
            print(f"  Indicator: {vuln['indicator']}")
            print(f"  Context: ...{vuln['context']}...")
    else:
        print("\n[*] No obvious vulnerabilities detected")
    
    # Check for security headers
    print("\n[*] Security Headers Analysis:")
    meta_headers = analysis.meta_data
    security_headers = ['X-Frame-Options', 'Content-Security-Policy', 'X-Content-Type-Options']
    
    for header in security_headers:
        if header in meta_headers:
            print(f"  [+] {header}: {meta_headers[header]}")
        else:
            print(f"  [-] {header}: Missing")
    
    print(f"\n[*] CSP: {'Found' if analysis.csp else 'Not found'}")
    print(f"[*] Iframes: {len(analysis.iframes)}")
    
    if analysis.comments:
        print(f"\n[*] HTML Comments Found:")
        for comment in analysis.comments[:5]:
            print(f"  // {comment[:100]}")
EOF

python3 detect_vulnerabilities.py
```

### Troubleshooting Common Issues

#### 1. BeautifulSoup Installation

```bash
# Install required libraries
pip install beautifulsoup4 lxml html5lib

# For parsing issues
pip install html5lib
```

#### 2. Memory Issues with Large Pages

```python
# Limit parsing size
from bs4 import BeautifulSoup
soup = BeautifulSoup(html_content[:1000000], 'lxml')  # Limit to 1MB
```

#### 3. Handling Dynamic Content

```python
# Use selenium for JavaScript-heavy pages
from selenium import webdriver
driver = webdriver.Chrome()
driver.get(url)
html_content = driver.page_source
driver.quit()
```

### Reference: Common HTML Parsing Patterns

| What to Find | BeautifulSoup Pattern | Example |
|-------------|----------------------|---------|
| Title | `soup.title.string` | "Home Page" |
| All Links | `soup.find_all('a')` | `<a href="/page">` |
| Forms | `soup.find_all('form')` | `<form action="/login">` |
| Inputs | `form.find_all('input')` | `<input type="text">` |
| Comments | `soup.find_all(string=comment)` | `<!-- admin login -->` |
| Meta Data | `soup.find_all('meta')` | `<meta name="description">` |
| Scripts | `soup.find_all('script')` | `<script src="app.js">` |
| Styles | `soup.find_all('style')` | `<style>.class{...}` |
| Images | `soup.find_all('img')` | `<img src="logo.png">` |
