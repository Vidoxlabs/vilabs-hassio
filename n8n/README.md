# Vi-Orchestrator (n8n)

## Overview

Vi-Orchestrator is a custom n8n installation designed as the workflow automation engine for the Sovereign Stack. It provides direct access to the `/share` directory (Context Lake) and `/media` for processing local documents, managing Home Assistant automations, and orchestrating LLM workflows without cloud dependency.

## Features

- **Local-First Workflows**: All automation rules stored locally in `/data`, persisted across reboots
- **Direct File Access**: Read/write access to `/share` for document processing and context management
- **Context Integration**: Direct integration with vi-postgres for semantic search and embeddings
- **Media Processing**: Full access to `/media` for document ingestion and archival
- **Home Assistant Native**: Full HA integration via REST API and native nodes
- **Sovereign Stack**: Part of the privacy-first, local-only digital brain

## Configuration

### Basic Settings

- **Log Level**: Control verbosity (debug, info, warn, error)
- **Execution Mode**: regular (immediate) or queue (asynchronous)
- **Max Parallel Executions**: Limit concurrent workflow runs (1-16)
- **Execution Timeout**: Maximum workflow duration in seconds

### Advanced Configuration

- **Database Type**: sqlite (default) or postgres (for external vi-postgres)
- **Custom Extensions**: Place custom nodes in `/data/custom-extensions`

## Usage

### Accessing n8n

The add-on provides web UI access via Home Assistant Ingress at `/addon/vi-n8n/`.

### Key Directories

- `/data` - Persistent workflows, credentials, and node configurations
- `/data/custom-extensions` - Custom node packages
- `/share` - Shared Context Lake (documents, metadata)
- `/media` - Media files and archival storage

### Example: Document Processing Workflow

```
File Trigger (on /share/inbox/)
  → Extract Text (OCR)
  → Generate Embeddings (call vi-postgres pgvector)
  → Store Metadata in vi-postgres
  → Move to /share/processed/
```

### Environment Variables

The addon automatically sets:

- `N8N_USER_FOLDER=/data` - Persistent storage location
- `N8N_BLOCK_ENV_ACCESS_IN_NODE=false` - Allow access to environment and filesystem
- `NODE_OPTIONS=--max-old-space-size=1024` - Memory tuning for i7 hardware

## Hardware Considerations

- **i7-1355U**: Suitable for parallel workflow execution (4-8 workflows)
- **16GB RAM**: Configured for 1GB Node.js heap, leaving headroom for Home Assistant and postgres

## Persistence

All workflows, credentials, executions, and custom extensions persist in `/data`:

- Survives addon restarts
- Survives Home Assistant upgrades
- Backed up with Home Assistant snapshots

## Integration with Sovereign Stack

### With vi-postgres

Query embeddings and semantics for intelligent automation:

```json
{
  "db_connection": "postgres://user:pass@vi-postgres:5432/homeassistant",
  "query": "SELECT content FROM documents WHERE embedding <-> $1 < 0.3"
}
```

### With vi-redis

Cache frequently accessed workflow state and context:

```json
{
  "redis_connection": "redis://vi-redis:6379",
  "cache_ttl": 3600
}
```

### With Home Assistant

Full HA node integration:

```json
{
  "trigger": "ha.state_changed",
  "entity_id": "sensor.living_room_temperature",
  "condition": "temperature > 25",
  "action": "call_service"
}
```

## Troubleshooting

### Workflows Not Triggering

1. Check logs: `docker logs <addon_container>`
2. Verify `/share` permissions: `ls -la /share`
3. Check webhook configuration if using external triggers

### Memory Issues

Increase `NODE_OPTIONS` in addon config if OOM occurs. Monitor with:

```bash
docker stats <addon_container>
```

### File Access Issues

Ensure proper permissions on `/share` and `/media`:

```bash
chmod 755 /share /media
chown 1000:1000 /data
```

## References

- [n8n Documentation](https://docs.n8n.io/)
- [Sovereign Stack Blueprint](../docs/vi0-assistant-blueprint.md)
- [Home Assistant Automations](https://www.home-assistant.io/docs/automation/)
