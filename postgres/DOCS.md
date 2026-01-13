# Vi-Memory (PostgreSQL with pgvector)

The "Hippocampus" of the Sovereign Stack. A production-grade relational database with pgvector extension for semantic search and vector embeddings storage.

## Features

- **PostgreSQL 16** with full stability and performance
- **pgvector extension** for semantic search and embedding storage
- **Home Assistant Recorder compatible** with optimized schema for history tracking
- **Persistent storage** via Home Assistant volumes (data persists across restarts)
- **Configurable performance tuning** (shared buffers, connections, work memory)
- **Automatic initialization** with sensible defaults
- **Structured logging** for debugging and monitoring

## Use Cases

- **Home Assistant Event History**: Replaces SQLite recorder with a robust, high-performance backend
- **Vector Embeddings**: Store and search semantic embeddings for documents, chat histories, and contextual data
- **Financial Context**: Store and query financial data, transactions, and derived analytics
- **Long-term Memory**: Persistent storage for Vi0 personal assistant interactions and learned patterns

## Installation

1. Add the repository URL to Home Assistant Add-ons:
   ```
   https://github.com/Viotic/hassio-vilabs-private
   ```
2. Install "Vi-Memory (PostgreSQL)" from the Add-ons Store
3. Configure the addon settings (see Configuration section)
4. Start the addon

## Configuration

### Basic Options

| Option              | Default         | Description                                  |
| ------------------- | --------------- | -------------------------------------------- |
| `postgres_user`     | `postgres`      | PostgreSQL superuser username                |
| `postgres_password` | `changeme`      | PostgreSQL superuser password (CHANGE THIS!) |
| `postgres_db`       | `homeassistant` | Default database created on first run        |

### Performance Tuning

These settings affect database performance based on available memory:

| Option                 | Default | Description                                           |
| ---------------------- | ------- | ----------------------------------------------------- |
| `max_connections`      | `200`   | Maximum concurrent database connections               |
| `shared_buffers`       | `256MB` | Buffer pool for caching (typically 25% of system RAM) |
| `effective_cache_size` | `1GB`   | Tells query planner how much memory is available      |
| `work_mem`             | `4MB`   | Memory per sort/hash operation                        |
| `maintenance_work_mem` | `64MB`  | Memory for VACUUM, CREATE INDEX, ALTER TABLE          |

### Logging

| Option          | Default | Description                                             |
| --------------- | ------- | ------------------------------------------------------- |
| `log_level`     | `info`  | Minimum log level (debug, info, notice, warning, error) |
| `log_statement` | `none`  | Log SQL statements (none, ddl, mod, all)                |

## Integration with Home Assistant

### Configure Home Assistant Recorder

Add to your `configuration.yaml`:

```yaml
recorder:
  db_url: postgresql://postgres:changeme@localhost/homeassistant
  auto_purge: true
  auto_purge_days: 90
  exclude:
    entities:
      - sun.sun
      - sensor.time_*
```

**Replace `changeme` with your configured `postgres_password`.**

### Verify Connection

Once running, test the connection:

```bash
docker exec addon_vi_postgres psql -U postgres -d homeassistant -c "SELECT version();"
```

## Advanced Usage

### Installing Additional Extensions

Connect to PostgreSQL and install extensions:

```bash
docker exec addon_vi_postgres psql -U postgres -d homeassistant \
  -c "CREATE EXTENSION IF NOT EXISTS pgrouting;"
```

### Backup and Restore

#### Backup

```bash
docker exec addon_vi_postgres pg_dump -U postgres homeassistant > homeassistant_backup.sql
```

#### Restore

```bash
docker exec addon_vi_postgres psql -U postgres homeassistant < homeassistant_backup.sql
```

### Querying Vector Embeddings

Example: Store and search embeddings

```sql
-- Create a table for document embeddings
CREATE TABLE document_embeddings (
    id SERIAL PRIMARY KEY,
    document_name VARCHAR(255),
    embedding vector(1536),  -- e.g., OpenAI embeddings
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for fast similarity search
CREATE INDEX ON document_embeddings USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Search similar embeddings
SELECT document_name, content, embedding <-> '[0.1, 0.2, ...]'::vector AS distance
FROM document_embeddings
ORDER BY embedding <-> '[0.1, 0.2, ...]'::vector
LIMIT 5;
```

## Troubleshooting

### PostgreSQL Won't Start

Check logs:

```bash
docker logs addon_vi_postgres
```

Common issues:

- **Data directory already exists but corrupt**: Remove the volume and reinitialize
- **Port 5432 already in use**: Change port in config or stop conflicting service
- **Insufficient disk space**: Ensure `/share` has at least 1GB free

### Connection Refused

Verify:

1. Addon is running: `docker ps | grep vi_postgres`
2. Port is listening: `netstat -ln | grep 5432`
3. Authentication: Check `postgres_user` and `postgres_password` in config

### Slow Queries

Check `effective_cache_size` and `shared_buffers`:

- For 3.7GB available RAM (i7 laptop):
  - `shared_buffers: 1GB`
  - `effective_cache_size: 2GB`
- Monitor with: `SELECT query, calls, total_time FROM pg_stat_statements ORDER BY total_time DESC;`

## Performance Notes

For the **vx-synapse (i7 laptop, 32GB RAM)** configuration:

**Recommended settings:**

```yaml
max_connections: 200
shared_buffers: 8GB
effective_cache_size: 20GB
work_mem: 20MB
maintenance_work_mem: 2GB
```

For **Home Assistant nodes with 4GB RAM:**

```yaml
max_connections: 100
shared_buffers: 1GB
effective_cache_size: 2GB
work_mem: 4MB
maintenance_work_mem: 64MB
```

## Architecture Notes

This addon is designed as part of the **Sovereign Stack**:

- **Storage Tier**: Uses Home Assistant volume mounts (persistent across restarts)
- **Inter-addon Communication**:
  - **n8n (Vi-Orchestrator)** connects to write embeddings and query context
  - **Redis (Vi-Cache)** can cache frequently accessed data
  - **Home Assistant Core** uses as recorder backend for events and states
- **Security**: Listens on `localhost:5432` by default (accessible only from HAOS container network)

## Support

Issues or questions?

- Check Home Assistant logs: `Settings → System → Logs`
- PostgreSQL logs: `docker logs addon_vi_postgres`
- Open an issue: [GitHub Issues](https://github.com/Viotic/hassio-vilabs-private/issues)
