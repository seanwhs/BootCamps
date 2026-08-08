# Appendix G: Redis Reference

## Complete Redis Reference Guide

Welcome to **Appendix G** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for Redis, covering commands, data structures, caching patterns, and troubleshooting used throughout the masterclass.

---

## Section 1: Redis Commands

### 1.1 Connection Commands

```bash
# Connect to Redis
redis-cli

# Connect with host and port
redis-cli -h localhost -p 6379

# Connect with password
redis-cli -h localhost -p 6379 -a your_password

# Connect with database selection
redis-cli -n 1

# Test connection
redis-cli ping
# Response: PONG

# Select database
SELECT 1

# Show info
INFO

# Show memory info
INFO memory

# Show stats
INFO stats

# Show clients
INFO clients
```

### 1.2 Key Commands

```bash
# List all keys (DANGER: Avoid in production)
KEYS *

# List keys with pattern
KEYS task:*

# Check if key exists
EXISTS key_name

# Delete key
DEL key_name

# Delete multiple keys
DEL key1 key2 key3

# Delete keys by pattern (scan approach)
redis-cli --scan --pattern "prefix:*" | xargs redis-cli DEL

# Set key with expiration
SET key_name value EX 60

# Set key with expiration (milliseconds)
SET key_name value PX 60000

# Get key TTL (time to live)
TTL key_name

# Get key TTL in milliseconds
PTTL key_name

# Set key to never expire
PERSIST key_name

# Get key type
TYPE key_name

# Rename key
RENAME old_name new_name

# Rename key if new key doesn't exist
RENAMENX old_name new_name

# Random key
RANDOMKEY

# Get key size
STRLEN key_name

# Move key to different database
MOVE key_name 1

# Copy key
COPY key_name new_key_name

# Touch key (update expiration)
TOUCH key_name
```

### 1.3 String Commands

```bash
# Set string
SET key_name value

# Set with expiration
SET key_name value EX 60

# Set if not exists
SETNX key_name value

# Set with multiple options
SET key_name value EX 60 NX

# Get string
GET key_name

# Get and delete
GETDEL key_name

# Get and set
GETSET key_name new_value

# Append to string
APPEND key_name " additional text"

# Get length
STRLEN key_name

# Increment integer
INCR key_name
INCRBY key_name 5

# Decrement integer
DECR key_name
DECRBY key_name 5

# Increment float
INCRBYFLOAT key_name 1.5

# Set multiple keys
MSET key1 value1 key2 value2

# Get multiple keys
MGET key1 key2 key3

# Set with expire (milliseconds)
PSETEX key_name 60000 value

# Get only part of string
GETRANGE key_name 0 10

# Overwrite part of string
SETRANGE key_name 5 "new_text"

# Get string as bit
BITCOUNT key_name
BITOP AND dest_key key1 key2
```

### 1.4 Hash Commands

```bash
# Set hash field
HSET hash_name field value

# Set multiple hash fields
HMSET hash_name field1 value1 field2 value2

# Get hash field
HGET hash_name field

# Get all hash fields and values
HGETALL hash_name

# Get all hash fields
HKEYS hash_name

# Get all hash values
HVALS hash_name

# Get hash length
HLEN hash_name

# Check if field exists
HEXISTS hash_name field

# Delete hash field
HDEL hash_name field1 field2

# Increment hash field
HINCRBY hash_name field 5

# Set if field doesn't exist
HSETNX hash_name field value

# Get multiple fields
HMGET hash_name field1 field2

# Scan hash fields
HSCAN hash_name 0 MATCH "field:*"
```

### 1.5 List Commands

```bash
# Push to left (front)
LPUSH list_name value1 value2

# Push to right (back)
RPUSH list_name value1 value2

# Push if list exists
LPUSHX list_name value
RPUSHX list_name value

# Pop from left
LPOP list_name

# Pop from right
RPOP list_name

# Blocking pop from left
BLPOP list_name 10

# Blocking pop from right
BRPOP list_name 10

# Get range
LRANGE list_name 0 -1

# Get by index
LINDEX list_name 2

# Insert before/after
LINSERT list_name BEFORE pivot_value new_value
LINSERT list_name AFTER pivot_value new_value

# Set value at index
LSET list_name 2 new_value

# Remove elements
LREM list_name count value

# Trim list
LTRIM list_name 0 100

# Get list length
LLEN list_name
```

### 1.6 Set Commands

```bash
# Add to set
SADD set_name member1 member2

# Remove from set
SREM set_name member1 member2

# Check if member exists
SISMEMBER set_name member

# Get all members
SMEMBERS set_name

# Get random member
SRANDMEMBER set_name

# Get and remove random member
SPOP set_name

# Get set size
SCARD set_name

# Move member to another set
SMOVE source_set destination_set member

# Set union
SUNION set1 set2

# Set union (store)
SUNIONSTORE dest_set set1 set2

# Set intersection
SINTER set1 set2

# Set intersection (store)
SINTERSTORE dest_set set1 set2

# Set difference
SDIFF set1 set2

# Set difference (store)
SDIFFSTORE dest_set set1 set2
```

### 1.7 Sorted Set Commands

```bash
# Add to sorted set
ZADD sorted_set score1 member1 score2 member2

# Add with options
ZADD sorted_set NX 100 member
ZADD sorted_set XX 100 member
ZADD sorted_set CH 100 member
ZADD sorted_set INCR 100 member

# Get score
ZSCORE sorted_set member

# Get rank (0-based)
ZRANK sorted_set member

# Get reverse rank
ZREVRANK sorted_set member

# Get range by index
ZRANGE sorted_set 0 -1
ZREVRANGE sorted_set 0 -1

# Get range by score
ZRANGEBYSCORE sorted_set 0 100
ZREVRANGEBYSCORE sorted_set 100 0

# Get range with scores
ZRANGE sorted_set 0 -1 WITHSCORES

# Get count in score range
ZCOUNT sorted_set 0 100

# Increment score
ZINCRBY sorted_set 5 member

# Remove member
ZREM sorted_set member

# Remove by rank
ZREMRANGEBYRANK sorted_set 0 10

# Remove by score
ZREMRANGEBYSCORE sorted_set 0 10

# Get sorted set size
ZCARD sorted_set
```

---

## Section 2: Advanced Redis Features

### 2.1 Pub/Sub Commands

```bash
# Publish message
PUBLISH channel_name "message"

# Subscribe to channel
SUBSCRIBE channel_name

# Subscribe to pattern
PSUBSCRIBE pattern*

# Unsubscribe
UNSUBSCRIBE channel_name

# Unsubscribe pattern
PUNSUBSCRIBE pattern*

# List active channels
PUBSUB CHANNELS

# List channel subscribers
PUBSUB NUMSUB channel_name

# List pattern subscriptions
PUBSUB NUMPAT
```

### 2.2 Scripting (Lua)

```lua
-- Simple script
EVAL "return redis.call('GET', KEYS[1])" 1 key_name

-- Script with arguments
EVAL "return redis.call('SET', KEYS[1], ARGV[1])" 1 key_name value

-- Atomic increment
EVAL "local current = redis.call('GET', KEYS[1]) or 0; return redis.call('SET', KEYS[1], current + ARGV[1])" 1 key_name 5

-- Script with conditional
EVAL "
    local current = redis.call('GET', KEYS[1]) or 0
    if current + ARGV[1] > ARGV[2] then
        return redis.error_reply('Limit exceeded')
    end
    return redis.call('SET', KEYS[1], current + ARGV[1])
" 1 key_name 5 100

-- Load script (returns SHA)
SCRIPT LOAD "return redis.call('GET', KEYS[1])"

-- Execute loaded script
EVALSHA script_sha 1 key_name

-- List loaded scripts
SCRIPT LIST

-- Flush script cache
SCRIPT FLUSH
```

### 2.3 Transactions

```bash
# Start transaction
MULTI

# Queue commands
SET key1 value1
SET key2 value2
INCR counter

# Execute transaction
EXEC

# Discard transaction
DISCARD

# Watch key for optimistic locking
WATCH key_name

# Unwatch
UNWATCH

# Transaction with conditional
WATCH key_name
MULTI
SET key_name new_value
EXEC
```

---

## Section 3: Redis with Django

### 3.1 Django Cache Configuration

```python
# settings.py
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://localhost:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'CONNECTION_POOL_CLASS': 'redis.BlockingConnectionPool',
            'CONNECTION_POOL_CLASS_KWARGS': {
                'max_connections': 50,
                'timeout': 20,
            },
            'SERIALIZER': 'django_redis.serializers.json.JSONSerializer',
            'PASSWORD': 'your_password',
            'SOCKET_CONNECT_TIMEOUT': 5,
            'SOCKET_TIMEOUT': 5,
        },
        'KEY_PREFIX': 'taskflow',
        'TIMEOUT': 300,
    }
}
```

### 3.2 Using Redis in Django

```python
from django.core.cache import cache

# Basic operations
cache.set('key', 'value', timeout=60)
value = cache.get('key')
cache.delete('key')
cache.clear()

# Get or set
value = cache.get('key', 'default')
value = cache.get_or_set('key', expensive_function(), timeout=60)

# Increment
cache.incr('counter')
cache.incr('counter', 5)
cache.decr('counter')

# Batch operations
cache.set_many({
    'key1': 'value1',
    'key2': 'value2',
})
values = cache.get_many(['key1', 'key2'])
cache.delete_many(['key1', 'key2'])

# Touch (update expiration)
cache.touch('key', timeout=60)

# Get with default
cache.get('key', 'default_value')

# Using Redis directly
from django_redis import get_redis_connection
redis_conn = get_redis_connection('default')

# Raw Redis commands
redis_conn.set('key', 'value')
redis_conn.expire('key', 60)
redis_conn.hset('hash', 'field', 'value')
```

---

## Section 4: Caching Patterns

### 4.1 Cache-Aside Pattern

```python
def get_user_profile(user_id):
    cache_key = f'user_profile:{user_id}'
    profile = cache.get(cache_key)
    
    if profile is None:
        profile = UserProfile.objects.get(user_id=user_id)
        cache.set(cache_key, profile, timeout=3600)
    
    return profile
```

### 4.2 Write-Through Pattern

```python
def update_user_profile(user_id, data):
    # Update database
    profile = UserProfile.objects.get(user_id=user_id)
    profile.update(data)
    profile.save()
    
    # Update cache
    cache_key = f'user_profile:{user_id}'
    cache.set(cache_key, profile, timeout=3600)
```

### 4.3 Cache Invalidation

```python
def invalidate_user_cache(user_id):
    cache_key = f'user_profile:{user_id}'
    cache.delete(cache_key)
    
    # Invalidate list cache
    cache.delete('user_list')
```

### 4.4 Rate Limiting

```python
def rate_limit(key, max_requests, window_seconds):
    """
    Rate limiting using Redis.
    """
    redis_conn = get_redis_connection('default')
    current = redis_conn.get(key)
    
    if current is None:
        # First request
        pipeline = redis_conn.pipeline()
        pipeline.set(key, 1)
        pipeline.expire(key, window_seconds)
        pipeline.execute()
        return True
    
    if int(current) >= max_requests:
        return False
    
    redis_conn.incr(key)
    return True

# Usage
if not rate_limit(f'ratelimit:{user_id}', 10, 60):
    return Response({'error': 'Rate limit exceeded'}, status=429)
```

### 4.5 Cache Stampede Protection

```python
def get_with_stampede_protection(key, fetch_function, timeout=300):
    """
    Prevent cache stampede by using a lock.
    """
    redis_conn = get_redis_connection('default')
    lock_key = f'{key}:lock'
    
    # Try to get cached value
    value = cache.get(key)
    if value is not None:
        return value
    
    # Try to acquire lock
    if redis_conn.setnx(lock_key, 'locked'):
        redis_conn.expire(lock_key, 30)
        try:
            # Only one process regenerates the cache
            value = fetch_function()
            cache.set(key, value, timeout=timeout)
            return value
        finally:
            redis_conn.delete(lock_key)
    else:
        # Wait for the value to be generated
        import time
        for _ in range(10):  # Wait up to 5 seconds
            time.sleep(0.5)
            value = cache.get(key)
            if value is not None:
                return value
        # Fallback: generate anyway (slow but avoids deadlock)
        return fetch_function()
```

---

## Section 5: Redis Optimization

### 5.1 Memory Optimization

```bash
# Configure memory policy
redis-cli CONFIG SET maxmemory-policy allkeys-lru

# Set maximum memory
redis-cli CONFIG SET maxmemory 1GB

# Check memory usage
redis-cli INFO memory

# View memory stats
redis-cli MEMORY STATS

# Analyze key memory usage
redis-cli --bigkeys

# Find memory hotspots
redis-cli MEMORY USAGE key_name
```

### 5.2 Performance Tuning

```bash
# Check slow queries
redis-cli SLOWLOG GET 10

# View slow log length
redis-cli SLOWLOG LEN

# Reset slow log
redis-cli SLOWLOG RESET

# Configure slow log
redis-cli CONFIG SET slowlog-log-slower-than 10000  # 10ms
redis-cli CONFIG SET slowlog-max-len 128

# Monitor Redis in real-time
redis-cli MONITOR

# Check client connections
redis-cli CLIENT LIST

# Kill client connection
redis-cli CLIENT KILL addr:port
```

### 5.3 Redis Configuration (redis.conf)

```ini
# Memory
maxmemory 1GB
maxmemory-policy allkeys-lru

# Persistence
appendonly yes
appendfsync everysec
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# Performance
tcp-backlog 511
timeout 0
tcp-keepalive 300
loglevel notice
databases 16

# Security
requirepass your_strong_password
rename-command CONFIG ""
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command KEYS ""

# Limits
maxclients 10000
maxmemory-policy allkeys-lru
```

---

## Section 6: Redis Sentinel (High Availability)

### 6.1 Sentinel Configuration

```ini
# sentinel.conf
port 26379
sentinel monitor mymaster 127.0.0.1 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
sentinel auth-pass mymaster your_password
```

### 6.2 Sentinel Commands

```bash
# Connect to Sentinel
redis-cli -p 26379

# Get master info
SENTINEL master mymaster

# Get slaves
SENTINEL slaves mymaster

# Get sentinels
SENTINEL sentinels mymaster

# Monitor new master
SENTINEL monitor myothermaster 192.168.1.100 6379 2

# Failover
SENTINEL failover mymaster

# Reset master
SENTINEL reset mymaster
```

---

## Section 7: Redis Cluster

### 7.1 Cluster Setup

```bash
# Create cluster nodes
redis-server /path/to/redis.conf --port 7000 --cluster-enabled yes
redis-server /path/to/redis.conf --port 7001 --cluster-enabled yes
redis-server /path/to/redis.conf --port 7002 --cluster-enabled yes
redis-server /path/to/redis.conf --port 7003 --cluster-enabled yes
redis-server /path/to/redis.conf --port 7004 --cluster-enabled yes
redis-server /path/to/redis.conf --port 7005 --cluster-enabled yes

# Create cluster
redis-cli --cluster create \
    127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 \
    127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \
    --cluster-replicas 1

# Check cluster
redis-cli -c -p 7000 CLUSTER NODES
redis-cli -c -p 7000 CLUSTER INFO

# Add node
redis-cli --cluster add-node new_ip:7000 existing_ip:7000

# Reshard
redis-cli --cluster reshard host:port --cluster-from node_id --cluster-to node_id --cluster-slots count
```

---

## Quick Reference Cards

### Redis Data Types

| Type | Commands | Use Case |
|------|----------|----------|
| **String** | GET, SET, INCR | Simple values, counters |
| **Hash** | HSET, HGET, HGETALL | Objects, user sessions |
| **List** | LPUSH, RPUSH, LRANGE | Queues, timelines |
| **Set** | SADD, SREM, SMEMBERS | Tags, unique items |
| **Sorted Set** | ZADD, ZRANGE, ZSCORE | Rankings, leaderboards |
| **Stream** | XADD, XREAD | Event sourcing, logging |

### Common Use Cases

| Use Case | Redis Type | Pattern |
|----------|-----------|---------|
| **Caching** | String | `SET key value EX 60` |
| **Session storage** | String | `SET session:${id} data` |
| **User profiles** | Hash | `HSET user:${id} name "John"` |
| **Queue** | List | `LPUSH queue task; RPOP queue` |
| **Leaderboard** | Sorted Set | `ZADD scores 100 "user1"` |
| **Rate limiting** | String | `INCR rate:${ip}; EXPIRE rate:${ip} 60` |
| **Task status** | Set | `SADD active_tasks ${task_id}` |

---

*This concludes Appendix G. Use this Redis reference to implement efficient caching and data storage patterns.*
