# Appendix Y: Debugging & Profiling Reference

## Complete Debugging & Profiling Guide

Welcome to **Appendix Y** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive guide to debugging and profiling tools and techniques for both backend and frontend.

---

## Section 1: Django Debugging Tools

### 1.1 Django Debug Toolbar

**Installation:**
```bash
pip install django-debug-toolbar
```

**Settings:**
```python
# settings.py
INSTALLED_APPS += ['debug_toolbar']
MIDDLEWARE = ['debug_toolbar.middleware.DebugToolbarMiddleware'] + MIDDLEWARE
INTERNAL_IPS = ['127.0.0.1', 'localhost']

DEBUG_TOOLBAR_PANELS = [
    'debug_toolbar.panels.versions.VersionsPanel',
    'debug_toolbar.panels.timer.TimerPanel',
    'debug_toolbar.panels.settings.SettingsPanel',
    'debug_toolbar.panels.headers.HeadersPanel',
    'debug_toolbar.panels.request.RequestPanel',
    'debug_toolbar.panels.sql.SQLPanel',
    'debug_toolbar.panels.staticfiles.StaticFilesPanel',
    'debug_toolbar.panels.templates.TemplatesPanel',
    'debug_toolbar.panels.cache.CachePanel',
    'debug_toolbar.panels.signals.SignalsPanel',
    'debug_toolbar.panels.logging.LoggingPanel',
    'debug_toolbar.panels.redirects.RedirectsPanel',
    'debug_toolbar.panels.profiling.ProfilingPanel',
]
```

**Usage:**
- Click debug toolbar icon in browser
- Check SQL queries count and time
- View cache hits/misses
- Check template rendering time
- View request headers
- Profile performance

### 1.2 Django Silk

**Installation:**
```bash
pip install django-silk
```

**Settings:**
```python
INSTALLED_APPS += ['silk']
MIDDLEWARE = ['silk.middleware.SilkyMiddleware'] + MIDDLEWARE

SILKY_PYTHON_PROFILER = True
SILKY_AUTHENTICATION = True
SILKY_AUTHORISATION = True
SILKY_PERMISSIONS = lambda user: user.is_superuser
```

**Usage:**
```bash
# Access Silk dashboard
http://localhost:8000/silk/

# Profile specific requests
# View SQL queries
# View request/response details
# View profiler traces
```

### 1.3 Django Extensions

**Installation:**
```bash
pip install django-extensions
```

**Settings:**
```python
INSTALLED_APPS += ['django_extensions']
```

**Commands:**
```bash
# Generate UML diagram
python manage.py graph_models -a -o models.png

# Show URLs
python manage.py show_urls

# Access Django shell with auto-imports
python manage.py shell_plus

# Reset database
python manage.py reset_db

# Show model structure
python manage.py print_user_models
```

---

## Section 2: Python Debugging Tools

### 2.1 Logging

```python
import logging

# Setup
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
)

logger = logging.getLogger(__name__)

# Usage
logger.debug('Debug message')
logger.info('Info message')
logger.warning('Warning message')
logger.error('Error message')
logger.critical('Critical message')

# Exception logging
try:
    risky_operation()
except Exception as e:
    logger.exception('Operation failed: %s', e)
```

### 2.2 Print Debugging

```python
# Basic
print(f"Variable: {variable}")

# With color (using termcolor)
from termcolor import colored
print(colored(f"User: {user}", 'green'))

# With pprint
from pprint import pprint
pprint(complex_object)

# With traceback
import traceback
traceback.print_stack()
```

### 2.3 PDB (Python Debugger)

```python
# Set breakpoint
import pdb; pdb.set_trace()  # Python 3.7+
breakpoint()                  # Python 3.7+

# Commands
# n - next line
# s - step into
# c - continue
# q - quit
# p variable - print variable
# pp variable - pretty print variable
# l - list source code
# ! - execute command
# h - help

# Interactive shell
import IPython; IPython.embed()
```

### 2.4 PyCharm/VS Code Debugging

**VS Code launch.json:**
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Django",
            "type": "python",
            "request": "launch",
            "program": "${workspaceFolder}/manage.py",
            "args": ["runserver"],
            "django": true,
            "justMyCode": true
        },
        {
            "name": "Python File",
            "type": "python",
            "request": "launch",
            "program": "${file}",
            "console": "integratedTerminal"
        }
    ]
}
```

---

## Section 3: Database Debugging

### 3.1 Django Query Logging

```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django.db.backends': {
            'level': 'DEBUG',
            'handlers': ['console'],
        },
    },
}
```

### 3.2 Query Counting

```python
from django.db import connection

def count_queries(func):
    def wrapper(*args, **kwargs):
        initial = len(connection.queries)
        result = func(*args, **kwargs)
        final = len(connection.queries)
        print(f"Queries: {final - initial}")
        return result
    return wrapper

@count_queries
def get_data():
    return list(Task.objects.all())

# Get all queries
print(connection.queries)

# Reset query log
connection.queries_log.clear()
```

### 3.3 PostgreSQL Debugging

```sql
-- Show active queries
SELECT pid, usename, query, state, query_start
FROM pg_stat_activity
WHERE state = 'active';

-- Show query performance
SELECT 
    query,
    calls,
    total_time / 1000 as total_seconds,
    mean_time as avg_ms,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Show locks
SELECT * FROM pg_locks WHERE NOT granted;

-- Show table stats
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    n_tup_ins,
    n_tup_upd,
    n_tup_del
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;
```

---

## Section 4: Next.js Debugging

### 4.1 Browser DevTools

**Chrome DevTools Shortcuts:**
```
F12                  - Open DevTools
Ctrl+Shift+I         - Open DevTools
Ctrl+Shift+C         - Inspect element
Ctrl+Shift+J         - Console
Ctrl+Shift+P         - Command palette
```

**Console Commands:**
```javascript
// Debug logs
console.log('Message', variable)
console.dir(object)
console.table(array)
console.warn('Warning')
console.error('Error')
console.group('Group')
console.groupEnd()
console.time('Timer')
console.timeEnd('Timer')

// Network debugging
// Check Network tab for:
// - Request/response
// - Status codes
// - Response times
// - Headers

// React DevTools
// - Component tree
// - Props and state
// - Hooks
// - Performance profiling
```

### 4.2 Next.js Logging

```javascript
// next.config.js
module.exports = {
    logging: {
        fetches: {
            fullUrl: true,
        },
    },
};

// Server logging
console.log('Server-side log');  // Shows in terminal

// Client logging
console.log('Client-side log');  // Shows in browser console

// API route logging
export async function GET(request) {
    console.log('API route called');
    // ...
}
```

### 4.3 Next.js Error Pages

```tsx
// app/error.tsx
'use client';

import { useEffect } from 'react';

export default function Error({
    error,
    reset,
}: {
    error: Error & { digest?: string };
    reset: () => void;
}) {
    useEffect(() => {
        console.error('Error:', error);
    }, [error]);

    return (
        <div>
            <h2>Something went wrong!</h2>
            <p>{error.message}</p>
            <button onClick={reset}>Try again</button>
        </div>
    );
}

// app/not-found.tsx
export default function NotFound() {
    return (
        <div>
            <h2>404 - Page Not Found</h2>
            <p>The page you're looking for doesn't exist.</p>
        </div>
    );
}
```

---

## Section 5: Performance Profiling

### 5.1 Django Profiling

```python
# Using cProfile
import cProfile
import pstats

def profile_view(request):
    profiler = cProfile.Profile()
    profiler.enable()
    
    result = expensive_operation()
    
    profiler.disable()
    stats = pstats.Stats(profiler)
    stats.sort_stats('cumulative').print_stats(10)
    
    return result

# Using Django-debug-toolbar profiling
# Enable ProfilingPanel in DEBUG_TOOLBAR_PANELS
```

### 5.2 Next.js Bundle Analysis

```bash
# Install bundle analyzer
npm install -D @next/bundle-analyzer

# Analyze
ANALYZE=true npm run build

# Check bundle size
npm run build

# View .next/analysis directory
```

### 5.3 React Performance Tools

```tsx
// React DevTools Profiler
// Record and analyze component render times

// useMemo and useCallback
const memoizedValue = useMemo(() => expensive(value), [value])
const memoizedCallback = useCallback(() => { ... }, [deps])

// React.memo
const MemoizedComponent = React.memo(Component)

// Why Did You Render
import whyDidYouRender from '@welldone-software/why-did-you-render';
whyDidYouRender(React, {
    trackAllPureComponents: true,
});
```

---

## Section 6: Memory Profiling

### 6.1 Python Memory Profiling

```python
# Using memory_profiler
from memory_profiler import profile

@profile
def memory_heavy_function():
    data = [i for i in range(1000000)]
    return data

# Using tracemalloc
import tracemalloc

tracemalloc.start()
snapshot = tracemalloc.take_snapshot()
top_stats = snapshot.statistics('lineno')
print("[ Top 10 ]")
for stat in top_stats[:10]:
    print(stat)
```

### 6.2 React Memory Leaks

```tsx
'use client';

import { useEffect } from 'react';

export function Component() {
    useEffect(() => {
        // Clean up to prevent memory leaks
        const subscription = subscribe();
        return () => {
            subscription.unsubscribe();
        };
    }, []);
}

// Check memory usage in Chrome DevTools
// 1. Memory tab
// 2. Take heap snapshots
// 3. Compare snapshots
// 4. Check for detached DOM nodes
```

---

## Section 7: Debugging Checklist

### Common Issues & Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Slow queries** | Long response times | Add indexes, use select_related |
| **N+1 queries** | Too many database queries | Use select_related, prefetch_related |
| **Memory leak** | Memory grows over time | Check for unsubscribed events |
| **CORS error** | Browser blocks requests | Configure CORS headers |
| **401 Unauthorized** | Authentication fails | Check token validity |
| **403 Forbidden** | Permission denied | Check user permissions |
| **404 Not Found** | Resource missing | Check URL, data exists |
| **500 Server Error** | Application error | Check logs, debug mode |

### Debugging Workflow

1. **Identify the problem**
2. **Check logs** (backend, frontend, database)
3. **Reproduce locally**
4. **Add logging/debug statements**
5. **Isolate the issue**
6. **Fix and test**
7. **Add tests to prevent regression**

---

*This concludes Appendix Y. Use these debugging and profiling tools to quickly identify and resolve issues.*
