# Vi-Cache (Redis)

## Overview

Vi-Cache is a persistent Redis instance designed as the short-term memory layer for the Sovereign Stack. It provides:

- **Session State Caching**: Stores n8n workflow execution states and results
- **LLM Context Storage**: Caches embeddings and context windows for efficient semantic searches
- **Rate Limiting**: Tracks API call rates for local services
- **Temporary Data**: Fast access to temporary computed values
- **Pub/Sub Messaging**: Enables real-time communication between add-ons

## Architecture

Redis operates as a high-performance in-memory cache, backed by persistent storage (RDB + AOF) to survive restarts. The i7 processor handles burst cache operations, while 4GB allocated to Redis leaves room for Home Assistant, n8n, and PostgreSQL.

## Features

- **Persistent Storage**: Both RDB (snapshots) and AOF (append-only) enabled
- **LRU Eviction**: Automatically removes least-recently-used keys when maxmemory is reached
- **Pub/Sub**: Real-time messaging for Sovereign Stack services
- **Replication Ready**: Architecture supports future master-replica setups
- **Hardware Tuned**: Optimized for i7-1355U with 16GB RAM

## Configuration

### Memory Management

- **maxmemory**: Set to 4GB by default (adjust based on available RAM)
- **maxmemory_policy**: LRU eviction policy for intelligent cache management
- **databases**: 16 databases available (select 0-15 per use case)

### Persistence

- **RDB Snapshots**: Save interval (default: 15 minutes)
- **AOF (Append-Only File)**: Write-ahead logging enabled with everysec fsync
- Both are stored in `/data/redis/` and persist across reboots

### Networking

- **Port**: 6379 (default Redis port)
- **Local Only**: Access restricted to Sovereign Stack add-ons
- **Authentication**: Optional password support (empty by default for internal network)

## Usage

### Connecting from n8n

```javascript
// In n8n workflows, use Redis nodes:
{
  "host": "vi-redis",
  "port": 6379,
  "db": 0,
  "operation": "set",
  "key": "workflow:execution:${$node.previous.id}",
  "value": "${JSON.stringify($node.previous.json)}",
  "ttl": 86400  // 24 hours
}
```

### Via CLI

```bash
docker exec <redis_container> redis-cli
> KEYS *
> GET key_name
> FLUSHDB  # Clear current database
> DBSIZE   # Check memory usage
```

### Python Integration

```python
import redis

cache = redis.Redis(host='vi-redis', port=6379, db=0, decode_responses=True)
cache.set('context:user123', json.dumps(embeddings), ex=3600)
context = json.loads(cache.get('context:user123'))
```

## Use Cases in Sovereign Stack

### 1. n8n Workflow State

Store in-progress workflow states and intermediate results:

```markdown
Database 1: n8n:workflows:*
Database 2: n8n:executions:*
TTL: 24-48 hours
```

### 2. LLM Context Window

Cache recent embeddings and semantic search results from vi-postgres:

```markdown
Database 3: llm:embeddings:*
Database 4: llm:context:*
TTL: 1-8 hours
```

### 3. Session Management

Track Home Assistant sessions and n8n credentials:

```markdown
Database 5: session:*
Database 6: credentials:*
TTL: Session duration (24 hours default)
```

### 4. Rate Limiting

Implement rate limits for external API calls:

```markdown
Database 7: ratelimit:api:*
TTL: Per-endpoint (typically 1 minute)
```

## Performance Tuning

```markdown
# Reasonable Redis allocation
maxmemory: 4gb                    # 25% of total RAM
maxmemory_policy: allkeys-lru     # Smart eviction
tcp_keepalive: 300                # Prevent idle timeouts
save_interval: 900                # 15-min snapshots
appendfsync: everysec             # Balance safety vs performance
```

Monitor memory usage:

```bash
docker exec <redis_container> redis-cli INFO memory
docker exec <redis_container> redis-cli DBSIZE
```

## Data Safety

### Backup Strategy

Redis data is backed up as part of Home Assistant snapshots (in `/data/redis/`).

### Recovery

If Redis becomes corrupted:

1. Stop the Redis addon
2. Delete `/data/redis/dump.rdb` and `/data/redis/appendonly.aof`
3. Restart the addon (fresh empty database)
4. Restore from Home Assistant snapshot if needed

## Troubleshooting

### High Memory Usage

Check which keys consume the most memory:

```bash
redis-cli DEBUG OBJECT key_name
redis-cli --bigkeys
```

Lower `maxmemory` or reduce cache TTL values.

### Connection Refused

Verify Redis is running:

```bash
docker logs <redis_container>
redis-cli PING  # Should return PONG
```

### Slow Performance

Monitor with:

```bash
redis-cli SLOWLOG GET 10
redis-cli INFO stats
```

Check for large values or too many keys in a single database.

## Integration Points

- **n8n**: Redis nodes for state caching and temp storage
- **vi-postgres**: Cache frequently queried embeddings
- **Home Assistant**: Redis integration for session storage
- **Custom Scripts**: Python/Node.js Redis clients for automation

## References

- [Redis Official Documentation](https://redis.io/docs/)
- [Sovereign Stack Blueprint](../docs/vi0-assistant-blueprint.md)
- [Redis Configuration](https://redis.io/docs/management/config/)
