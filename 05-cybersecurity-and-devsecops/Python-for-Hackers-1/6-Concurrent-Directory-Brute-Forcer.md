# Phase 2: Web Reconnaissance & Automated Enumeration
## Part 2: Concurrent Directory Brute-Forcer

### The Target: High-Performance Directory Brute-Forcer

By the end of this part, you will:
- Understand directory enumeration techniques
- Build a multi-threaded/asynchronous directory brute-forcer
- Implement intelligent wordlist management
- Create filtering and result analysis capabilities
- Optimize performance using concurrency patterns

### The Concept: What is Directory Brute-Forcing?

Think of directory brute-forcing like trying all possible keys to find the one that opens a door:

- **The Building** = A website (e.g., `example.com`)
- **The Doors** = Directories and files (e.g., `/admin`, `/login.php`)
- **The Key Ring** = A wordlist of common directory names
- **Finding an Open Door** = Discovering a valid directory

**Why We Do It:**
- Discover hidden admin panels (`/admin`, `/cpanel`)
- Find backup files (`/backup`, `/old`)
- Identify sensitive directories (`/config`, `/database`)
- Uncover API endpoints (`/api`, `/v1`)
- Find development artifacts (`/test`, `/dev`)

### The Implementation: Directory Brute-Forcer

#### File: `~/hacking-toolkit/web-attack/brute_forcer.py`

```python
#!/usr/bin/env python3
"""
brute_forcer.py - High-performance concurrent directory brute-forcer
Performs efficient directory and file enumeration using multiple threads
and intelligent wordlist management.
"""

import sys
import os
import time
import threading
import queue
import argparse
import json
from datetime import datetime
from typing import List, Dict, Optional, Set, Tuple
from urllib.parse import urljoin, urlparse
from dataclasses import dataclass, field
from concurrent.futures import ThreadPoolExecutor, as_completed

# Import our HTTP client
try:
    from http_client import HTTPClient
except ImportError:
    print("[-] http_client.py not found. Please ensure it's in the same directory.")
    sys.exit(1)

# Try to import colorama
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    HAS_COLOR = True
except ImportError:
    class Fore:
        RED = GREEN = YELLOW = BLUE = CYAN = MAGENTA = WHITE = RESET = ''
    Style = Fore
    HAS_COLOR = False

@dataclass
class BruteForceResult:
    """Result of a directory/file brute force attempt"""
    path: str
    status_code: int
    content_length: int
    content_type: str = ''
    title: str = ''
    redirect_location: str = ''
    found_at: str = field(default_factory=lambda: datetime.now().isoformat())
    
    def __str__(self):
        """String representation with color"""
        color = Fore.GREEN if self.status_code == 200 else Fore.YELLOW
        if self.status_code >= 400:
            color = Fore.RED
        elif self.status_code == 403:
            color = Fore.MAGENTA
        
        return f"{color}{self.status_code:<6} {self.path:<50} {self.content_length}"

class DirectoryBruteForcer:
    """
    High-performance concurrent directory brute-forcer
    Uses thread pooling for efficient enumeration with wordlist management
    """
    
    def __init__(self, target_url: str, wordlist: List[str] = None,
                 extensions: List[str] = None, threads: int = 50,
                 timeout: int = 10, follow_redirects: bool = False,
                 recursive: bool = False, max_depth: int = 3,
                 exclude_statuses: List[int] = None,
                 user_agent: str = None):
        """
        Initialize the brute-forcer
        
        Args:
            target_url: Base URL to enumerate
            wordlist: List of paths to test
            extensions: File extensions to append (e.g., ['.php', '.html'])
            threads: Number of concurrent threads
            timeout: Request timeout in seconds
            follow_redirects: Follow HTTP redirects
            recursive: Perform recursive enumeration
            max_depth: Maximum recursion depth
            exclude_statuses: Status codes to ignore
            user_agent: Custom User-Agent
        """
        self.target_url = target_url.rstrip('/')
        self.wordlist = wordlist or []
        self.extensions = extensions or []
        self.threads = threads
        self.timeout = timeout
        self.follow_redirects = follow_redirects
        self.recursive = recursive
        self.max_depth = max_depth
        self.exclude_statuses = exclude_statuses or [404]
        
        # Results storage
        self.results: List[BruteForceResult] = []
        self.discovered_paths: Set[str] = set()
        self.visited_paths: Set[str] = set()
        
        # Client
        self.client = HTTPClient(
            base_url=target_url,
            timeout=timeout,
            user_agent=user_agent
        )
        
        # Statistics
        self.stats = {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'start_time': None,
            'end_time': None
        }
        
        # Thread safety
        self.lock = threading.Lock()
        self.results_queue = queue.Queue()
        self.progress = 0
        self.total = 0
        
        # Common status code meanings
        self.status_meanings = {
            200: "OK",
            301: "Moved Permanently",
            302: "Found",
            303: "See Other",
            307: "Temporary Redirect",
            400: "Bad Request",
            401: "Unauthorized",
            403: "Forbidden",
            404: "Not Found",
            405: "Method Not Allowed",
            500: "Internal Server Error",
            502: "Bad Gateway",
            503: "Service Unavailable"
        }
    
    def _generate_paths(self, base_path: str = '', depth: int = 0) -> List[str]:
        """
        Generate all paths to test based on wordlist and extensions
        
        Args:
            base_path: Base path for recursion
            depth: Current recursion depth
            
        Returns:
            List of paths to test
        """
        paths = []
        
        # Add base wordlist entries
        for word in self.wordlist:
            # Clean up path
            path = f"{base_path}/{word}" if base_path else word
            
            # Add without extension
            if path not in self.visited_paths:
                paths.append(path)
                self.visited_paths.add(path)
            
            # Add with extensions
            if self.extensions:
                for ext in self.extensions:
                    ext_path = f"{path}{ext}"
                    if ext_path not in self.visited_paths:
                        paths.append(ext_path)
                        self.visited_paths.add(ext_path)
        
        return paths
    
    def _check_path(self, path: str) -> Optional[BruteForceResult]:
        """
        Check a single path
        
        Args:
            path: Path to check
            
        Returns:
            BruteForceResult if successful, None otherwise
        """
        try:
            # Make request
            response = self.client.get(
                path,
                allow_redirects=self.follow_redirects
            )
            
            # Update statistics
            with self.lock:
                self.stats['total_requests'] += 1
                
                if response.status_code < 400:
                    self.stats['successful_requests'] += 1
                else:
                    self.stats['failed_requests'] += 1
            
            # Skip excluded status codes
            if response.status_code in self.exclude_statuses:
                return None
            
            # Parse response
            parsed = self.client.parse_response(response)
            
            # Create result
            result = BruteForceResult(
                path=path,
                status_code=response.status_code,
                content_length=len(response.content),
                content_type=parsed.get('content_type', ''),
                title=parsed.get('title', ''),
                redirect_location=response.headers.get('Location', '')
            )
            
            return result
            
        except requests.exceptions.RequestException:
            with self.lock:
                self.stats['failed_requests'] += 1
            return None
        except Exception as e:
            return None
    
    def _process_results(self):
        """
        Process results from the queue
        """
        while True:
            try:
                result = self.results_queue.get(timeout=1)
                if result is None:
                    break
                
                # Store result
                with self.lock:
                    self.results.append(result)
                    self.discovered_paths.add(result.path)
                    
                    # Print result
                    if HAS_COLOR:
                        print(f"{Fore.GREEN}[+] {Fore.WHITE}{result}")
                    else:
                        print(f"[+] {result}")
                
                # Handle recursion
                if self.recursive and result.status_code == 200:
                    depth = result.path.count('/')
                    if depth < self.max_depth:
                        self._recursive_scan(result.path, depth)
                
            except queue.Empty:
                continue
    
    def _recursive_scan(self, base_path: str, depth: int):
        """
        Perform recursive scanning of discovered directories
        
        Args:
            base_path: Base path to scan
            depth: Current depth
        """
        # Generate paths for this directory
        paths = self._generate_paths(base_path, depth + 1)
        
        # Add to queue
        for path in paths:
            self.scan_queue.put(path)
            with self.lock:
                self.total += 1
    
    def _worker(self):
        """
        Worker thread function
        """
        while not self.stop_scan:
            try:
                # Get next path from queue
                path = self.scan_queue.get(timeout=1)
                
                # Check path
                result = self._check_path(path)
                
                # Add result to queue if found
                if result:
                    self.results_queue.put(result)
                
                # Update progress
                with self.lock:
                    self.progress += 1
                    
                    # Print progress occasionally
                    if self.progress % 10 == 0 or self.progress == self.total:
                        percent = (self.progress / self.total) * 100 if self.total > 0 else 0
                        sys.stdout.write(f"\r[*] Progress: {self.progress}/{self.total} ({percent:.1f}%)")
                        sys.stdout.flush()
                
                self.scan_queue.task_done()
                
            except queue.Empty:
                continue
            except Exception as e:
                print(f"[-] Worker error: {e}")
                continue
    
    def scan(self) -> List[BruteForceResult]:
        """
        Execute the brute force scan
        
        Returns:
            List of results
        """
        print(f"[*] Starting directory brute force on {self.target_url}")
        print(f"[*] Wordlist: {len(self.wordlist)} entries")
        print(f"[*] Extensions: {self.extensions or 'None'}")
        print(f"[*] Threads: {self.threads}")
        print(f"[*] Timeout: {self.timeout}s")
        print(f"[*] Recursive: {self.recursive}")
        print(f"[*] Follow Redirects: {self.follow_redirects}")
        print(f"[*] Excluding statuses: {self.exclude_statuses}")
        print("-" * 60)
        
        # Initialize queues
        self.scan_queue = queue.Queue()
        self.results_queue = queue.Queue()
        self.stop_scan = False
        
        # Generate initial paths
        initial_paths = self._generate_paths()
        
        # Add paths to queue
        for path in initial_paths:
            self.scan_queue.put(path)
            self.total += 1
        
        # Record start time
        self.stats['start_time'] = time.time()
        
        # Start result processing thread
        result_thread = threading.Thread(target=self._process_results)
        result_thread.daemon = True
        result_thread.start()
        
        # Start worker threads
        workers = []
        for _ in range(self.threads):
            worker = threading.Thread(target=self._worker)
            worker.daemon = True
            worker.start()
            workers.append(worker)
        
        try:
            # Wait for queue to complete
            self.scan_queue.join()
            
            # Signal workers to stop
            self.stop_scan = True
            
            # Wait for all workers
            for worker in workers:
                worker.join(timeout=2)
            
            # Signal result processor to stop
            self.results_queue.put(None)
            result_thread.join(timeout=2)
            
        except KeyboardInterrupt:
            print("\n[!] Scan interrupted by user")
            self.stop_scan = True
            self.scan_queue.join()
        
        # Record end time
        self.stats['end_time'] = time.time()
        duration = self.stats['end_time'] - self.stats['start_time']
        
        print(f"\n\n[*] Scan completed in {duration:.2f} seconds")
        print(f"[*] Total requests: {self.stats['total_requests']}")
        print(f"[*] Successful: {self.stats['successful_requests']}")
        print(f"[*] Failed: {self.stats['failed_requests']}")
        print(f"[*] Discovered: {len(self.results)}")
        
        return self.results
    
    def print_results(self, sort_by: str = 'status', show_titles: bool = False,
                     min_status: int = 200, max_status: int = 399,
                     show_redirects: bool = False):
        """
        Print formatted results
        
        Args:
            sort_by: Sort field ('status', 'path', 'size')
            show_titles: Show page titles
            min_status: Minimum status code to display
            max_status: Maximum status code to display
            show_redirects: Show redirect locations
        """
        if not self.results:
            print("\n[*] No results found")
            return
        
        # Filter results
        filtered = [r for r in self.results 
                   if min_status <= r.status_code <= max_status]
        
        if not filtered:
            print(f"\n[*] No results found in status range {min_status}-{max_status}")
            return
        
        # Sort results
        if sort_by == 'status':
            filtered.sort(key=lambda x: x.status_code)
        elif sort_by == 'path':
            filtered.sort(key=lambda x: x.path)
        elif sort_by == 'size':
            filtered.sort(key=lambda x: x.content_length)
        
        print("\n" + "="*80)
        print(f"  DIRECTORY BRUTE FORCE RESULTS")
        print("="*80)
        print(f"Target: {self.target_url}")
        print(f"Found: {len(filtered)} items")
        print("-"*80)
        
        print(f"{'STATUS':<8} {'PATH':<50} {'SIZE':<10} {'TYPE'}")
        print("-"*80)
        
        for result in filtered:
            # Color based on status
            if HAS_COLOR:
                if result.status_code == 200:
                    status_color = Fore.GREEN
                elif 300 <= result.status_code < 400:
                    status_color = Fore.YELLOW
                elif 400 <= result.status_code < 500:
                    status_color = Fore.MAGENTA
                else:
                    status_color = Fore.RED
                
                # Path color
                path_color = Fore.WHITE
                if result.path.endswith('/'):
                    path_color = Fore.CYAN
                
                output = f"{status_color}{result.status_code:<8}{Fore.RESET}"
                output += f"{path_color}{result.path[:50]:<50}{Fore.RESET}"
                output += f"{result.content_length:<10}"
                output += f"{result.content_type[:20]}"
            else:
                output = f"{result.status_code:<8} {result.path[:50]:<50} {result.content_length:<10} {result.content_type[:20]}"
            
            print(output)
            
            # Show title
            if show_titles and result.title:
                print(f"  Title: {result.title[:80]}")
            
            # Show redirect
            if show_redirects and result.redirect_location:
                print(f"  Redirects to: {result.redirect_location}")
        
        print("="*80)
        print(f"Total: {len(filtered)} items found")
    
    def save_results(self, filename: str = None):
        """
        Save results to a file
        
        Args:
            filename: Output filename (auto-generated if None)
        """
        if not filename:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"bruteforce_{timestamp}.json"
        
        data = {
            'target': self.target_url,
            'timestamp': datetime.now().isoformat(),
            'stats': self.stats,
            'results': [
                {
                    'path': r.path,
                    'status_code': r.status_code,
                    'content_length': r.content_length,
                    'content_type': r.content_type,
                    'title': r.title,
                    'redirect_location': r.redirect_location,
                    'found_at': r.found_at
                }
                for r in self.results
            ]
        }
        
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)
        
        print(f"[*] Results saved to {filename}")

class WordlistManager:
    """
    Manages and loads wordlists for directory brute forcing
    """
    
    # Built-in wordlists
    BUILTIN_WORDLISTS = {
        'common': [
            'admin', 'login', 'wp-admin', 'administrator', 'backup',
            'config', 'database', 'phpmyadmin', 'cpanel', 'webmail',
            'test', 'dev', 'stage', 'api', 'v1', 'v2', 'docs',
            'images', 'css', 'js', 'assets', 'static', 'media',
            'downloads', 'uploads', 'files', 'data', 'logs'
        ],
        'admin': [
            'admin', 'administrator', 'manage', 'control', 'root',
            'sysadmin', 'webadmin', 'manager', 'dashboard', 'panel',
            'cp', 'cpanel', 'plesk', 'webmin', 'cacti', 'nagios'
        ],
        'backup': [
            'backup', 'bak', 'old', 'orig', 'original', 'save',
            'tmp', 'temp', 'test', 'dev', 'stage', 'staging',
            'copy', 'backup.zip', 'backup.tar.gz', 'backup.sql'
        ],
        'api': [
            'api', 'v1', 'v2', 'v3', 'rest', 'graphql', 'graphiql',
            'swagger', 'docs', 'documentation', 'endpoints', 'services'
        ],
        'web': [
            'html', 'css', 'js', 'javascript', 'images', 'img',
            'assets', 'static', 'media', 'files', 'uploads',
            'downloads', 'fonts', 'icons', 'screenshots'
        ],
        'php': [
            'index', 'index.php', 'index.html', 'default', 'main',
            'home', 'homepage', 'page', 'pages', 'view', 'list'
        ],
        'config': [
            'config', 'configuration', 'settings', 'setup', 'install',
            'env', '.env', 'config.php', 'settings.php', 'wp-config.php'
        ]
    }
    
    @classmethod
    def get_wordlist(cls, name: str) -> List[str]:
        """
        Get a built-in wordlist
        
        Args:
            name: Wordlist name
            
        Returns:
            List of words
        """
        return cls.BUILTIN_WORDLISTS.get(name, [])
    
    @classmethod
    def list_wordlists(cls) -> List[str]:
        """
        List available built-in wordlists
        
        Returns:
            List of wordlist names
        """
        return list(cls.BUILTIN_WORDLISTS.keys())
    
    @classmethod
    def load_from_file(cls, filename: str) -> List[str]:
        """
        Load wordlist from file
        
        Args:
            filename: Path to wordlist file
            
        Returns:
            List of words
        """
        try:
            with open(filename, 'r') as f:
                words = [line.strip() for line in f if line.strip()]
            return words
        except FileNotFoundError:
            print(f"[-] Wordlist file not found: {filename}")
            return []
        except Exception as e:
            print(f"[-] Error loading wordlist: {e}")
            return []
    
    @classmethod
    def create_wordlist(cls, words: List[str], name: str = 'custom',
                       save: bool = False) -> List[str]:
        """
        Create a custom wordlist
        
        Args:
            words: List of words
            name: Name for the wordlist
            save: Whether to save to file
            
        Returns:
            List of words
        """
        if save:
            filename = f"wordlist_{name}.txt"
            with open(filename, 'w') as f:
                for word in words:
                    f.write(f"{word}\n")
            print(f"[*] Wordlist saved to {filename}")
        
        return words

def main():
    """Main entry point with argument parsing"""
    parser = argparse.ArgumentParser(
        description="Concurrent Directory Brute-Forcer",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 brute_forcer.py https://example.com
  python3 brute_forcer.py https://example.com -w common -e .php,.html
  python3 brute_forcer.py https://example.com -w common -t 100 -r
  python3 brute_forcer.py https://example.com -w admin -e .php -T 5
  python3 brute_forcer.py https://example.com -w custom.txt
        """
    )
    
    parser.add_argument('url', help='Target URL')
    parser.add_argument('-w', '--wordlist', default='common',
                       help='Wordlist to use (built-in or file path)')
    parser.add_argument('-e', '--extensions', help='File extensions to try (comma-separated)')
    parser.add_argument('-t', '--threads', type=int, default=50,
                       help='Number of threads (default: 50)')
    parser.add_argument('-T', '--timeout', type=int, default=10,
                       help='Request timeout in seconds (default: 10)')
    parser.add_argument('-r', '--recursive', action='store_true',
                       help='Enable recursive scanning')
    parser.add_argument('-d', '--max-depth', type=int, default=3,
                       help='Maximum recursion depth (default: 3)')
    parser.add_argument('-f', '--follow-redirects', action='store_true',
                       help='Follow HTTP redirects')
    parser.add_argument('-x', '--exclude', default='404',
                       help='Status codes to exclude (comma-separated)')
    parser.add_argument('-s', '--sort', default='status',
                       choices=['status', 'path', 'size'],
                       help='Sort results by (default: status)')
    parser.add_argument('--show-titles', action='store_true',
                       help='Show page titles in results')
    parser.add_argument('--show-redirects', action='store_true',
                       help='Show redirect locations')
    parser.add_argument('--min-status', type=int, default=200,
                       help='Minimum status code to display (default: 200)')
    parser.add_argument('--max-status', type=int, default=399,
                       help='Maximum status code to display (default: 399)')
    parser.add_argument('--user-agent', help='Custom User-Agent')
    parser.add_argument('-o', '--output', help='Output file for results')
    parser.add_argument('--list-wordlists', action='store_true',
                       help='List available built-in wordlists')
    
    args = parser.parse_args()
    
    # List wordlists if requested
    if args.list_wordlists:
        print("Available built-in wordlists:")
        for name in WordlistManager.list_wordlists():
            words = WordlistManager.get_wordlist(name)
            print(f"  {name}: {len(words)} words")
        sys.exit(0)
    
    # Load wordlist
    wordlist = []
    
    # Check if it's a file
    if os.path.isfile(args.wordlist):
        wordlist = WordlistManager.load_from_file(args.wordlist)
    else:
        # Try built-in wordlist
        builtin = WordlistManager.get_wordlist(args.wordlist)
        if builtin:
            wordlist = builtin
        else:
            print(f"[-] Unknown wordlist: {args.wordlist}")
            print(f"[*] Available wordlists: {', '.join(WordlistManager.list_wordlists())}")
            sys.exit(1)
    
    if not wordlist:
        print("[-] Wordlist is empty")
        sys.exit(1)
    
    # Parse extensions
    extensions = []
    if args.extensions:
        extensions = [ext.strip() for ext in args.extensions.split(',')]
        if not extensions[0].startswith('.'):
            # Add dot if missing
            extensions = [f".{ext}" if not ext.startswith('.') else ext for ext in extensions]
    
    # Parse exclude statuses
    exclude_statuses = []
    if args.exclude:
        exclude_statuses = [int(s.strip()) for s in args.exclude.split(',')]
    
    # Create brute-forcer
    forcer = DirectoryBruteForcer(
        target_url=args.url,
        wordlist=wordlist,
        extensions=extensions,
        threads=args.threads,
        timeout=args.timeout,
        follow_redirects=args.follow_redirects,
        recursive=args.recursive,
        max_depth=args.max_depth,
        exclude_statuses=exclude_statuses,
        user_agent=args.user_agent
    )
    
    try:
        # Run scan
        results = forcer.scan()
        
        # Print results
        forcer.print_results(
            sort_by=args.sort,
            show_titles=args.show_titles,
            min_status=args.min_status,
            max_status=args.max_status,
            show_redirects=args.show_redirects
        )
        
        # Save results if requested
        if args.output:
            forcer.save_results(args.output)
        elif len(results) > 0:
            # Auto-save if results found
            forcer.save_results()
            
    except KeyboardInterrupt:
        print("\n[!] Scan interrupted")
        sys.exit(1)
    except Exception as e:
        print(f"[-] Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### The Implementation: Wordlist Generator

#### File: `~/hacking-toolkit/web-attack/wordlist_generator.py`

```python
#!/usr/bin/env python3
"""
wordlist_generator.py - Advanced wordlist generator for directory brute forcing
Creates custom wordlists based on patterns, known sources, and mutations.
"""

import sys
import itertools
import hashlib
from typing import List, Set, Dict, Optional

class WordlistGenerator:
    """
    Generates custom wordlists for directory brute forcing
    """
    
    # Common directory patterns
    COMMON_PREFIXES = ['', 'admin', 'web', 'site', 'app', 'api', 'v1', 'v2']
    COMMON_SUFFIXES = ['', 'admin', 'panel', 'dashboard', 'manager', 'control']
    COMMON_NAMES = ['admin', 'root', 'sys', 'www', 'data', 'files', 'uploads']
    
    def __init__(self):
        """Initialize the wordlist generator"""
        self.words = set()
    
    def add_base_words(self, words: List[str]):
        """
        Add base words to the wordlist
        
        Args:
            words: List of base words
        """
        self.words.update(words)
    
    def generate_permutations(self, base_words: List[str],
                              prefixes: List[str] = None,
                              suffixes: List[str] = None,
                              separators: List[str] = ['', '_', '-']) -> Set[str]:
        """
        Generate permutations of words with prefixes and suffixes
        
        Args:
            base_words: Base words to permute
            prefixes: List of prefixes
            suffixes: List of suffixes
            separators: List of separators
            
        Returns:
            Set of generated words
        """
        generated = set()
        
        prefixes = prefixes or self.COMMON_PREFIXES
        suffixes = suffixes or self.COMMON_SUFFIXES
        
        for word in base_words:
            # Add original word
            generated.add(word)
            
            # Add with prefixes
            for prefix in prefixes:
                if prefix:
                    for sep in separators:
                        generated.add(f"{prefix}{sep}{word}")
                        generated.add(f"{word}{sep}{prefix}")
            
            # Add with suffixes
            for suffix in suffixes:
                if suffix:
                    for sep in separators:
                        generated.add(f"{word}{sep}{suffix}")
                        generated.add(f"{suffix}{sep}{word}")
        
        return generated
    
    def generate_year_variations(self, base_words: List[str],
                                 years: List[int] = None) -> Set[str]:
        """
        Generate variations with years
        
        Args:
            base_words: Base words
            years: List of years
            
        Returns:
            Set of generated words
        """
        generated = set()
        
        if years is None:
            years = list(range(2020, 2026))
        
        for word in base_words:
            for year in years:
                generated.add(f"{word}{year}")
                generated.add(f"{year}{word}")
                generated.add(f"{word}_{year}")
                generated.add(f"{word}-{year}")
        
        return generated
    
    def generate_number_variations(self, base_words: List[str],
                                   max_number: int = 10) -> Set[str]:
        """
        Generate variations with numbers
        
        Args:
            base_words: Base words
            max_number: Maximum number to append
            
        Returns:
            Set of generated words
        """
        generated = set()
        
        for word in base_words:
            for i in range(max_number):
                generated.add(f"{word}{i}")
                generated.add(f"{word}_{i}")
                generated.add(f"{word}-{i}")
                generated.add(f"{word}{i}{i}")
                generated.add(f"{word}{i}{i}{i}")
        
        return generated
    
    def generate_common_names(self, names: List[str] = None) -> Set[str]:
        """
        Generate common usernames/directory names
        
        Args:
            names: List of names
            
        Returns:
            Set of generated names
        """
        generated = set()
        
        names = names or self.COMMON_NAMES
        
        for name in names:
            generated.add(name)
            generated.add(name.capitalize())
            generated.add(name.upper())
            generated.add(name.lower())
            
            # Add common variations
            generated.add(f"{name}_admin")
            generated.add(f"{name}_panel")
            generated.add(f"{name}_dashboard")
            generated.add(f"{name}_control")
            
            # Add with common suffixes
            for suffix in ['_backup', '_old', '_new', '_test', '_dev']:
                generated.add(f"{name}{suffix}")
        
        return generated
    
    def generate_technology_specific(self, tech_type: str) -> Set[str]:
        """
        Generate technology-specific paths
        
        Args:
            tech_type: Type of technology ('wordpress', 'php', 'python', 'ruby', 'node')
            
        Returns:
            Set of generated paths
        """
        generated = set()
        
        if tech_type == 'wordpress':
            wordpress_paths = [
                'wp-admin', 'wp-content', 'wp-includes', 'wp-config.php',
                'wp-login.php', 'wp-signup.php', 'wp-activate.php',
                'wp-cron.php', 'wp-links-opml.php', 'wp-mail.php',
                'wp-settings.php', 'wp-trackback.php', 'xmlrpc.php',
                'wp-admin/admin.php', 'wp-content/plugins', 'wp-content/themes',
                'wp-content/uploads', 'wp-content/cache', 'wp-content/languages'
            ]
            generated.update(wordpress_paths)
            
        elif tech_type == 'php':
            php_paths = [
                'index.php', 'admin.php', 'login.php', 'register.php',
                'dashboard.php', 'config.php', 'settings.php', 'install.php',
                'setup.php', 'info.php', 'phpinfo.php', 'test.php',
                'config.inc.php', 'database.php', 'functions.php',
                'includes/', 'classes/', 'lib/', 'vendor/'
            ]
            generated.update(php_paths)
            
        elif tech_type == 'python':
            python_paths = [
                'manage.py', 'wsgi.py', 'settings.py', 'urls.py',
                'views.py', 'models.py', 'admin.py', 'forms.py',
                'static/', 'templates/', 'media/', 'staticfiles/',
                'venv/', 'env/', 'requirements.txt', 'Pipfile',
                'Dockerfile', 'docker-compose.yml', 'setup.py'
            ]
            generated.update(python_paths)
            
        elif tech_type == 'node':
            node_paths = [
                'index.js', 'app.js', 'server.js', 'main.js',
                'package.json', 'package-lock.json', 'node_modules/',
                'dist/', 'build/', 'public/', 'src/', 'test/',
                'config/', 'routes/', 'controllers/', 'models/',
                'views/', 'middleware/', 'utils/', 'helpers/'
            ]
            generated.update(node_paths)
            
        elif tech_type == 'ruby':
            ruby_paths = [
                'config.ru', 'Gemfile', 'Gemfile.lock', 'Rakefile',
                'app/', 'config/', 'db/', 'lib/', 'log/', 'public/',
                'test/', 'tmp/', 'vendor/', 'views/', 'controllers/',
                'models/', 'helpers/', 'assets/', 'stylesheets/'
            ]
            generated.update(ruby_paths)
        
        return generated
    
    def generate_common_backups(self) -> Set[str]:
        """
        Generate common backup file patterns
        
        Returns:
            Set of backup patterns
        """
        backups = set()
        
        base_files = [
            'config', 'settings', 'database', 'db', 'data',
            'backup', 'dump', 'export', 'sql', 'tar', 'zip'
        ]
        
        extensions = ['.zip', '.gz', '.tar.gz', '.sql', '.dump', '.bkp', '.old']
        
        for base in base_files:
            for ext in extensions:
                backups.add(f"{base}{ext}")
                backups.add(f"{base}_backup{ext}")
                backups.add(f"{base}.{ext}")
                backups.add(f"{base}.backup{ext}")
        
        # Add common backup names
        backups.update([
            'backup.zip', 'backup.tar.gz', 'backup.sql', 'backup.tar',
            'database.zip', 'database.sql', 'db.sql', 'db.zip',
            'site_backup.zip', 'site_backup.sql', 'config_backup.zip',
            'wp_backup.zip', 'wp_backup.sql'
        ])
        
        return backups
    
    def generate_api_paths(self) -> Set[str]:
        """
        Generate common API paths
        
        Returns:
            Set of API paths
        """
        api_paths = set()
        
        versions = ['', 'v1', 'v2', 'v3', 'v4', 'latest']
        methods = ['get', 'post', 'put', 'delete', 'patch']
        resources = [
            'users', 'user', 'admin', 'login', 'auth', 'register',
            'status', 'health', 'ping', 'info', 'version',
            'products', 'orders', 'customers', 'payments',
            'upload', 'download', 'files', 'images'
        ]
        
        for version in versions:
            for resource in resources:
                # API base
                api_paths.add(f"api/{resource}")
                if version:
                    api_paths.add(f"api/{version}/{resource}")
                
                # REST-style
                api_paths.add(f"/{resource}")
                api_paths.add(f"{resource}s")
                if version:
                    api_paths.add(f"/{version}/{resource}")
            
            # Common API endpoints
            api_paths.add(f"api")
            if version:
                api_paths.add(f"api/{version}")
                api_paths.add(f"{version}")
            
            # Documentation
            api_paths.add(f"api/docs")
            api_paths.add(f"api/documentation")
            api_paths.add(f"api/swagger")
            api_paths.add(f"api/graphql")
        
        return api_paths
    
    def generate_all(self) -> List[str]:
        """
        Generate a comprehensive wordlist
        
        Returns:
            List of all generated words
        """
        all_words = set()
        
        # Add base words
        base = self.COMMON_NAMES + self.COMMON_PREFIXES
        all_words.update(base)
        
        # Generate permutations
        all_words.update(self.generate_permutations(base))
        
        # Generate year variations
        all_words.update(self.generate_year_variations(base))
        
        # Generate number variations
        all_words.update(self.generate_number_variations(base))
        
        # Generate common names
        all_words.update(self.generate_common_names())
        
        # Generate technology-specific
        for tech in ['wordpress', 'php', 'python', 'node', 'ruby']:
            all_words.update(self.generate_technology_specific(tech))
        
        # Generate backups
        all_words.update(self.generate_common_backups())
        
        # Generate API paths
        all_words.update(self.generate_api_paths())
        
        # Add common web paths
        web_paths = [
            'admin', 'administrator', 'login', 'signin', 'signup',
            'register', 'dashboard', 'panel', 'control', 'manage',
            'profile', 'account', 'settings', 'config', 'configuration',
            'help', 'support', 'faq', 'about', 'contact',
            'terms', 'privacy', 'legal', 'security', 'admin',
            'dev', 'development', 'stage', 'staging', 'test',
            'demo', 'sample', 'example', 'backup', 'cache'
        ]
        all_words.update(web_paths)
        
        return sorted(all_words)
    
    def save_wordlist(self, filename: str, words: List[str]):
        """
        Save wordlist to file
        
        Args:
            filename: Output filename
            words: List of words to save
        """
        with open(filename, 'w') as f:
            for word in words:
                f.write(f"{word}\n")
        print(f"[*] Wordlist saved to {filename} ({len(words)} words)")

def main():
    """Generate and save a comprehensive wordlist"""
    print("="*60)
    print("  WORDLIST GENERATOR")
    print("="*60)
    
    generator = WordlistGenerator()
    
    # Generate wordlist
    print("[*] Generating comprehensive wordlist...")
    words = generator.generate_all()
    
    print(f"[*] Generated {len(words)} words")
    
    # Ask for filename
    filename = input("Enter filename to save (default: custom_wordlist.txt): ").strip()
    if not filename:
        filename = "custom_wordlist.txt"
    
    # Save wordlist
    generator.save_wordlist(filename, words)
    
    print("\n[*] Wordlist generation complete!")
    print(f"[*] Word count: {len(words)}")
    
    # Print some examples
    print("\n[*] Examples:")
    for word in words[:20]:
        print(f"  {word}")
    if len(words) > 20:
        print(f"  ... and {len(words) - 20} more")

if __name__ == "__main__":
    main()
```

### The Verification: Testing the Brute-Forcer

#### Test 1: Basic Scan

```bash
cd ~/hacking-toolkit/web-attack
python3 brute_forcer.py https://example.com -w common -t 20
```

**Expected Output:**
```
[*] Starting directory brute force on https://example.com
[*] Wordlist: 25 entries
[*] Extensions: None
[*] Threads: 20
[*] Timeout: 10s
[*] Recursive: False
[*] Follow Redirects: False
[*] Excluding statuses: [404]
------------------------------------------------------------
[+] 200    /                                                 12345
[+] 403    /admin                                            567
[+] 301    /admin/                                           234
[+] 200    /login                                            4567

[*] Scan completed in 2.34 seconds
[*] Total requests: 25
[*] Successful: 4
[*] Failed: 21
[*] Discovered: 4

============================================================
  DIRECTORY BRUTE FORCE RESULTS
============================================================
Target: https://example.com
Found: 4 items
------------------------------------------------------------
STATUS   PATH                                               SIZE       TYPE
------------------------------------------------------------
200      /                                                  12345      text/html
403      /admin                                             567        text/html
301      /admin/                                            234        text/html
200      /login                                             4567       text/html
============================================================
Total: 4 items found
[*] Results saved to bruteforce_20240115_143025.json
```

#### Test 2: With Extensions

```bash
python3 brute_forcer.py https://example.com -w common -e .php,.html,.txt -t 30
```

#### Test 3: Recursive Scan

```bash
python3 brute_forcer.py https://example.com -w common -r -d 2 -t 50
```

#### Test 4: Custom Wordlist

```bash
# Generate a custom wordlist
python3 wordlist_generator.py

# Use the generated wordlist
python3 brute_forcer.py https://example.com -w custom_wordlist.txt -t 100
```

#### Test 5: Advanced Filtering

```bash
# Only show redirects and 200 status codes
python3 brute_forcer.py https://example.com -w admin --min-status 200 --max-status 399 --show-redirects
```

### Performance Optimization Tips

1. **Thread Tuning:**
   ```bash
   # Increase threads for faster scanning (use with caution)
   python3 brute_forcer.py https://example.com -t 200
   ```

2. **Timeout Adjustment:**
   ```bash
   # Decrease timeout for faster scanning
   python3 brute_forcer.py https://example.com -T 3
   ```

3. **Smart Wordlisting:**
   ```bash
   # Use targeted wordlists for better results
   python3 brute_forcer.py https://example.com -w wordpress
   ```

4. **Parallel Execution:**
   ```python
   # Run multiple scans in parallel
   from concurrent.futures import ThreadPoolExecutor
   
   targets = ['https://site1.com', 'https://site2.com']
   with ThreadPoolExecutor(max_workers=2) as executor:
       futures = [executor.submit(
           scan_target, target
       ) for target in targets]
   ```

### Advanced Usage: Integration with HTTP Client

```python
# Advanced scanning with custom headers and cookies
cat > advanced_scan.py << 'EOF'
#!/usr/bin/env python3
from brute_forcer import DirectoryBruteForcer
from http_client import HTTPClient

# Create authenticated client
client = HTTPClient('https://example.com')
client.set_header('X-API-Key', 'secretkey123')
client.set_cookie('session', 'abcdef123456')

# Create brute-forcer with custom client
forcer = DirectoryBruteForcer(
    target_url='https://example.com',
    wordlist=['admin', 'dashboard', 'api'],
    threads=30
)

# Override client
forcer.client = client

# Run scan
results = forcer.scan()
forcer.print_results()
EOF

python3 advanced_scan.py
```
