# Sovereign Stack: Complete Architecture & Integration

## Overview

The **Sovereign Stack** is a "Contextual Appliance" running on Home Assistant OS (HAOS), enabling local intelligence with complete data ownership. It consists of four interconnected components working together to provide a comprehensive AI experience on your local network.

---

## The Four Components

### 1. vi-redis (Cache) 🔴

**Role**: Short-term Memory & Session Cache

**Responsibilities**:

- Session management (user logins, tokens)
- Temporary data caching
- Real-time data synchronization
- Performance optimization layer

**Technology**: Redis 7.x
**Port**: 6379 (internal only)
**Storage**: In-memory + disk persistence
**Data Retention**: Ephemeral (automatic cleanup)

**Integrations**:

- vi-openwebui: Session caching
- vi-n8n: Workflow state cache
- vi-postgres: Query result caching

### 2. vi-postgres (Memory) 🟦

**Role**: Long-term Memory & Data Persistence

**Responsibilities**:

- Structured data storage
- Vector embeddings (pgvector)
- Semantic search capability
- Conversation history archival
- User profiles and settings

**Technology**: PostgreSQL 16 + pgvector
**Port**: 5432 (internal only)
**Storage**: `/data` directory
**Data Retention**: Permanent (manual backup required)

**Integrations**:

- vi-openwebui: Conversation storage
- vi-n8n: Workflow data persistence
- Vector search: Semantic conversation lookup

### 3. vi-n8n (Orchestrator) 🟧

**Role**: Workflow Automation & Integration Hub

**Responsibilities**:

- Workflow automation (triggered by events)
- Integration with external services
- Complex decision logic
- Data transformation pipelines
- Event-driven processing

**Technology**: n8n (Node-based automation)
**Port**: 5678 (via Ingress)
**Storage**: `/data` directory
**Data Retention**: Workflow history

**Integrations**:

- vi-openwebui: Workflow triggers from chat
- vi-postgres: Store workflow results
- vi-redis: Cache workflow state
- External APIs: REST, webhooks, integrations

### 4. vi-openwebui (Face) 🟨

**Role**: User Interface & Chat Interaction

**Responsibilities**:

- Web-based chat interface
- Model selection and management
- User authentication
- Conversation management
- Optional features (web search, image gen)

**Technology**: Open WebUI (Python-based)
**Port**: 8080 (via Ingress)
**Storage**: `/data` directory
**Data Retention**: Permanent (chat history)

**Integrations**:

- Ollama (external): LLM inference
- vi-postgres: Conversation archival
- vi-n8n: Workflow triggers
- vi-redis: Session caching

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Home Assistant OS (i7 Host)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Web Browser / Home Assistant UI         │  │
│  │                    (User Interaction Layer)              │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                           │                                     │
│                    Ingress (127.0.0.1)                         │
│                           │                                     │
│        ┌──────────────────┼──────────────────────┐             │
│        │                  │                      │             │
│        ▼                  ▼                      ▼             │
│  ┌──────────────┐   ┌──────────────┐    ┌──────────────┐    │
│  │  vi-openwebui│───│  vi-n8n      │───│ vi-postgres  │    │
│  │   (Face)     │   │ (Orchestrator)│    │  (Memory)   │    │
│  │              │   │               │    │             │    │
│  │ Port: 8080   │   │ Port: 5678    │    │ Port: 5432  │    │
│  │              │   │               │    │             │    │
│  └──────────────┘   └──────────────┘    └──────────────┘    │
│        │                  │                      │             │
│        └──────────────────┼──────────────────────┘             │
│                           │                                     │
│                    vi-redis (Cache)                            │
│                    Port: 6379                                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
        │                                  │
        │                                  │
        ▼                                  ▼
  ┌───────────────┐            ┌───────────────────┐
  │ Ollama GPU    │            │  External APIs    │
  │  (v37-gpu-01) │            │  Services         │
  │ LLM Inference │            │  Integrations     │
  │ Port: 11434   │            │                   │
  └───────────────┘            └───────────────────┘
```

## Data Flow Diagram

### User-Initiated Chat

```
User Types Message in Open WebUI
     │
     ▼
vi-openwebui (Chat Interface)
     │
     ├─→ Check vi-redis for session cache
     │
     ├─→ Store conversation in vi-postgres
     │
     ├─→ Send to Ollama (via v37-gpu-01:11434)
     │
     ├─→ Receive LLM response
     │
     └─→ Display to user + archive in vi-postgres
```

### Workflow-Triggered Automation

```
Chat Mentions "Run Workflow"
     │
     ▼
vi-openwebui (Detects trigger)
     │
     ▼
vi-n8n (Receives webhook)
     │
     ├─→ Query vi-postgres for context
     │
     ├─→ Check vi-redis for cached state
     │
     ├─→ Execute automation logic
     │
     ├─→ Call external APIs
     │
     └─→ Store results in vi-postgres
```

### Semantic Search Workflow

```
User: "Find similar conversations"
     │
     ▼
vi-openwebui (Query interface)
     │
     ▼
vi-postgres (Vector Search)
     │
     ├─→ Compute embeddings for query
     │
     ├─→ pgvector similarity search
     │
     └─→ Return ranked results to OpenWebUI
```

---

## Component Communication

### vi-openwebui ↔ Ollama (External GPU)

**Purpose**: LLM Inference
**Protocol**: HTTP REST (OpenAI-compatible API)
**Typical Flow**:

```
openwebui: POST /api/generate
  {
    "model": "neural-chat:7b",
    "prompt": "User message...",
    "stream": true
  }
ollama: Stream response back
```

**Network**: Direct HTTP to v37-gpu-01:11434
**Latency**: <100ms (same subnet)
**Throughput**: 5-60s per response (depends on model)

### vi-openwebui ↔ vi-postgres (Persistence)

**Purpose**: Store conversations and user data
**Protocol**: PostgreSQL wire protocol
**Typical Flow**:

```
openwebui: INSERT INTO conversations (user_id, message, response)
openwebui: SELECT * FROM conversations WHERE user_id = X
```

**Network**: Docker bridge (internal only)
**Latency**: <10ms
**Throughput**: Millisecond-scale queries

### vi-openwebui ↔ vi-redis (Caching)

**Purpose**: Session management and performance
**Protocol**: Redis RESP protocol
**Typical Flow**:

```
openwebui: SET session:user123 "token=abc123..."
openwebui: GET session:user123
```

**Network**: Docker bridge (internal only)
**Latency**: <1ms
**Throughput**: Microsecond-scale operations

### vi-openwebui ↔ vi-n8n (Orchestration)

**Purpose**: Trigger workflows from chat
**Protocol**: HTTP webhooks
**Typical Flow**:

```
openwebui: POST /webhook/chat-action
  {
    "message": "Run analysis workflow",
    "context": "...",
    "user_id": 123
  }
n8n: Process workflow
n8n: POST /webhook/callback
  {
    "result": "...",
    "timestamp": "2024-01-15T..."
  }
openwebui: Display result to user
```

**Network**: Docker bridge (internal only)
**Latency**: 100-1000ms (workflow dependent)
**Throughput**: Seconds to minutes

### vi-n8n ↔ vi-postgres (Data Storage)

**Purpose**: Persist workflow results
**Protocol**: PostgreSQL queries
**Typical Flow**:

```
n8n: Query conversation history
n8n: Store automation results
n8n: Update user preferences
```

**Network**: Docker bridge (internal only)
**Latency**: <10ms
**Throughput**: Millisecond-scale

### vi-n8n ↔ vi-redis (State Caching)

**Purpose**: Cache workflow state for performance
**Protocol**: Redis RESP
**Typical Flow**:

```
n8n: SET workflow:abc "state=running..."
n8n: GET workflow:abc
n8n: DEL workflow:abc (on completion)
```

**Network**: Docker bridge (internal only)
**Latency**: <1ms
**Throughput**: Microsecond-scale

---

## Integration Scenarios

### Scenario 1: Intelligent Chat with Persistent Memory

**User Goal**: Chat with AI that remembers context

**Flow**:

1. User sends message in vi-openwebui
2. vi-openwebui loads conversation history from vi-postgres
3. vi-openwebui sends message + history to Ollama
4. Ollama generates response using context
5. vi-openwebui stores conversation in vi-postgres
6. User sees response

**Components Involved**: vi-openwebui, vi-postgres, Ollama
**Storage**: vi-postgres (permanent chat history)
**Caching**: vi-redis (optional session cache)

### Scenario 2: Automated Workflow Triggered by Chat

**User Goal**: "Summarize my emails" → triggers automation

**Flow**:

1. User types "run email summary" in vi-openwebui
2. vi-openwebui detects trigger keyword
3. vi-openwebui calls vi-n8n webhook
4. vi-n8n reads user's email API credentials
5. vi-n8n fetches emails and generates summary
6. vi-n8n stores summary in vi-postgres
7. vi-n8n sends summary back to vi-openwebui
8. User sees result in chat

**Components Involved**: vi-openwebui, vi-n8n, vi-postgres
**Storage**: vi-postgres (workflow results)
**Caching**: vi-redis (workflow state)
**External**: Email provider APIs

### Scenario 3: Semantic Search of Conversations

**User Goal**: "Find discussions about AI safety"

**Flow**:

1. User types query in vi-openwebui
2. vi-openwebui sends query to vi-postgres
3. vi-postgres computes query embedding (pgvector)
4. vi-postgres performs vector similarity search
5. vi-postgres returns ranked results
6. vi-openwebui displays similar conversations
7. User clicks to view full conversation

**Components Involved**: vi-openwebui, vi-postgres
**Storage**: vi-postgres (pgvector indexes)
**Performance**: ~100-500ms for large databases

### Scenario 4: Multi-Turn Workflow with Caching

**User Goal**: Fast repeated queries on same data

**Flow**:

1. User sends first query
2. vi-n8n processes query and caches result in vi-redis
3. User sends similar query
4. vi-n8n checks vi-redis cache (hit!)
5. vi-n8n returns cached result immediately
6. User sees instant response

**Components Involved**: vi-n8n, vi-redis, vi-openwebui
**Caching**: vi-redis (workflow result cache)
**Performance**: 10x faster with cache hit

---

## Configuration for Integration

### Step 1: Enable vi-postgres Connection in vi-openwebui

```yaml
# vi-openwebui config.yaml (add in future)
postgres_enabled: true
postgres_host: vi-postgres
postgres_port: 5432
postgres_database: openwebui
postgres_user: openwebui
postgres_password: secure_password
```

### Step 2: Connect vi-n8n to vi-postgres

```
n8n UI → Credentials → PostgreSQL
  Host: vi-postgres
  Port: 5432
  Database: openwebui
  Username: openwebui
  Password: (from HA secrets)
```

### Step 3: Create n8n Webhook for Chat Integration

```
n8n Workflow:
  [Webhook Trigger] → [Process Message] → [Query PostgreSQL] → [Send Response]

Webhook URL: http://vi-n8n:5678/webhook/chat-action
```

### Step 4: Configure vi-openwebui to Trigger Workflows

```javascript
// In Open WebUI plugin
if (message.includes("run")) {
  fetch("http://vi-n8n:5678/webhook/chat-action", {
    method: "POST",
    body: JSON.stringify({
      message: message,
      user_id: user.id,
      context: conversationHistory,
    }),
  });
}
```

---

## Data Storage & Backup Strategy

### Storage Layout

```
/usr/share/hassio/homeassistant/
├── data/
│   ├── vi-redis/                    # Redis data
│   │   └── dump.rdb
│   ├── vi-postgres/                 # PostgreSQL data
│   │   └── postgresql/
│   │       └── pg_data/
│   ├── vi-n8n/                      # n8n workflows
│   │   └── .n8n/
│   └── vi-openwebui/                # Chat history
│       └── open-webui-data/
│           ├── chroma/              # Embeddings
│           └── files/               # Uploaded docs
```

### Backup Strategy

**Home Assistant Automatic Backup**:

- Settings → System → Backups
- Backs up entire `/data` directory
- Encrypted at rest
- Includes all component data

**Manual Backup** (Optional):

```bash
# SSH to HA host
tar -czf sovereign-backup.tar.gz \
  /usr/share/hassio/homeassistant/data/vi-*

# Copy to external storage
scp sovereign-backup.tar.gz backup@server:/backups/
```

**Recovery**:

```bash
# From Home Assistant backup
Settings → System → Backups → [Select] → Restore

# Or manual recovery
tar -xzf sovereign-backup.tar.gz -C /usr/share/hassio/homeassistant/
```

### Data Retention

| Component    | Data Type              | Retention | Size      | Notes           |
| ------------ | ---------------------- | --------- | --------- | --------------- |
| vi-redis     | Sessions, cache        | 24 hours  | 100-500MB | Ephemeral       |
| vi-postgres  | Conversations, vectors | Permanent | 1-10GB    | Requires backup |
| vi-n8n       | Workflows, results     | Permanent | 500MB-2GB | Requires backup |
| vi-openwebui | Chat history, users    | Permanent | 100-500MB | Requires backup |

---

## Performance Characteristics

### Component Latencies

| Operation         | Latency    | Component    |
| ----------------- | ---------- | ------------ |
| LLM response      | 5-60s      | Ollama (GPU) |
| Chat message save | <10ms      | vi-postgres  |
| Session lookup    | <1ms       | vi-redis     |
| Workflow trigger  | 100-1000ms | vi-n8n       |
| Vector search     | 100-500ms  | vi-postgres  |
| Web UI render     | <500ms     | vi-openwebui |

### Typical Response Times

**Fast Path** (cached):

- vi-redis cache hit → <1ms
- Send to UI → <500ms
- **Total**: <2s

**Slow Path** (new LLM call):

- LLM inference → 5-60s
- Save to vi-postgres → <10ms
- Send to UI → <500ms
- **Total**: 5-61s

**Workflow Path**:

- vi-n8n processing → 100-5000ms
- vi-postgres operations → <10ms each
- Send to UI → <500ms
- **Total**: 1-10s typical

---

## Hardware Tuning for Sovereign Stack

### CPU (i7-1355U)

- **10 cores** available
- Most workload: <5% (lightweight)
- Spike usage: 10-20% during processing
- **Tuning**: Default settings work well, plenty of headroom

### Memory (16GB)

- **vi-openwebui**: 300-400MB
- **vi-n8n**: 400-600MB
- **vi-postgres**: 500MB-1GB
- **vi-redis**: 100-500MB
- **System overhead**: ~3-4GB
- **Total used**: ~5-8GB typical
- **Available**: ~8GB buffer for user apps

### Storage

- **System**: 10GB (OS + add-ons code)
- **vi-postgres**: 1-5GB (conversations, vectors)
- **vi-redis**: 100-500MB (ephemeral)
- **vi-n8n**: 500MB-2GB (workflows)
- **vi-openwebui**: 100-500MB (chat history)
- **Reserve**: 5GB free space minimum
- **Recommended**: 20GB total allocation

### Network (to GPU)

- **Bandwidth**: 1Gbps+ recommended
- **Latency**: <100ms preferred
- **Connection**: Ethernet preferred over WiFi
- **Bandwidth estimate**: 10-50MB per inference call

---

## Scaling Considerations

### Single GPU Node (v37-gpu-01)

**Current configuration**: Sufficient for:

- Single user chatting
- Periodic workflow automation
- Concurrent model inference queuing

**Scaling limits**:

- 3-5 concurrent users on 7B models
- 1-2 concurrent users on 13B models
- Sequential inference on 70B models

### Multiple GPU Nodes (Future)

**Planned enhancement**:

- Load balancing across multiple Ollama instances
- Model sharding (different models on different GPUs)
- Fallback GPU node if primary unavailable
- Cost optimization through model selection

### Database Scaling

**Current postgres setup**: Sufficient for:

- 1-5 million conversations
- Vector embeddings with pgvector

**Scaling beyond**:

- Partition conversations by time
- Archive old conversations
- Dedicated vector DB (Pinecone, Weaviate)

---

## Security Architecture

### Network Isolation

```
Internet
  │
  ├─→ (NOT ACCESSIBLE)
  │
Home Assistant OS (Firewall)
  │
  ├─→ Ingress (Port 80/443) ← User browser
  │     │
  │     └─→ vi-openwebui (127.0.0.1:8080)
  │           │
  │           ├─→ vi-postgres (Docker bridge)
  │           ├─→ vi-n8n (Docker bridge)
  │           └─→ vi-redis (Docker bridge)
  │
  └─→ Ollama (External network, GPU node)
        └─→ (Restricted to HA host access)
```

### Authentication Layers

1. **Home Assistant Login**: Protects entire sidebar
2. **vi-openwebui Login**: Optional, can be disabled
3. **Database Access**: Internal Docker network only
4. **API Keys**: Stored in HA secrets (encrypted)

### Data Encryption

- **At Rest**: HA backup encryption
- **In Transit**: HTTPS via Ingress (HA handles TLS)
- **Database**: Optional PostgreSQL encryption
- **Redis**: Optional password protection

---

## Troubleshooting Integration Issues

### "Cannot connect to vi-postgres"

**Diagnosis**:

1. Check vi-postgres is running: HA Add-ons → vi-postgres → Check status
2. Verify network connectivity: Docker logs for vi-openwebui
3. Check credentials in config

**Solution**:

1. Restart vi-postgres
2. Verify hostname: `vi-postgres` (not localhost)
3. Check port: 5432 (default)

### "Workflow webhook timeout"

**Diagnosis**:

1. Check vi-n8n is running
2. Verify webhook URL is correct
3. Check n8n logs for errors

**Solution**:

1. Increase webhook timeout in n8n
2. Check network connectivity between components
3. Restart vi-n8n

### "Redis cache not working"

**Diagnosis**:

1. Check vi-redis is running
2. Test connection: `redis-cli` from vi-openwebui container
3. Check memory available

**Solution**:

1. Increase Redis memory limit if needed
2. Clear old cache: `FLUSHDB` (caution: clears all sessions)
3. Restart vi-redis

### "Slow vector search"

**Diagnosis**:

1. Check pgvector index exists
2. Run `EXPLAIN ANALYZE` on search query
3. Check disk I/O on host

**Solution**:

1. Create index: `CREATE INDEX ON conversations USING ivfflat (embedding)`
2. Increase work_mem in postgres
3. Archive old conversations

---

## Monitoring & Observability

### Health Checks

**vi-openwebui**:

```bash
curl http://localhost:8080/health
# Expected: 200 OK
```

**vi-n8n**:

```bash
curl http://vi-n8n:5678/api/v1/workflows
# Expected: 200 OK with workflow list
```

**vi-postgres**:

```bash
psql -U openwebui -d openwebui -c "SELECT NOW();"
# Expected: Returns current timestamp
```

**vi-redis**:

```bash
redis-cli -h vi-redis PING
# Expected: PONG
```

### Metrics to Monitor

- **CPU usage**: Should be <20% idle
- **Memory usage**: Should be <8GB of 16GB
- **Disk usage**: Monitor `/data` growth
- **Ollama GPU**: Monitor VRAM usage on v37-gpu-01
- **Response latencies**: Track LLM response times
- **Error rates**: Monitor component logs

### Logging

All components log to Home Assistant:

- Settings → Add-ons → [Component] → Logs
- Search for errors, warnings
- Grep logs for specific issues

---

## Next Steps for Full Stack

1. ✅ **Deploy vi-redis** (Cache layer)
2. ✅ **Deploy vi-postgres** (Memory layer)
3. ✅ **Deploy vi-n8n** (Orchestrator layer)
4. ✅ **Deploy vi-openwebui** (Face layer)
5. 🔲 **Enable vi-postgres in vi-openwebui** (Persistence)
6. 🔲 **Create n8n webhooks** (Workflow automation)
7. 🔲 **Configure vector search** (Semantic queries)
8. 🔲 **Set up monitoring** (Health checks)
9. 🔲 **Document custom workflows** (Use cases)
10. 🔲 **Plan capacity scaling** (Future growth)

---

## Architecture Evolution

### Phase 1 (Current): Core Stack

- ✅ Individual components running
- ✅ Isolated data storage
- ✅ Basic functionality

### Phase 2 (Next): Integration

- 🔲 Components communicate seamlessly
- 🔲 Shared knowledge graph
- 🔲 Workflow automation

### Phase 3 (Future): Intelligence

- 🔲 Long-term memory with vectors
- 🔲 Semantic understanding
- 🔲 Proactive suggestions

### Phase 4 (Vision): Autonomy

- 🔲 Self-optimizing workflows
- 🔲 Multi-agent coordination
- 🔲 Continuous learning

---

## References

- [VI-OPENWEBUI-IMPLEMENTATION-SUMMARY.md](VI-OPENWEBUI-IMPLEMENTATION-SUMMARY.md) - Detailed component overview
- [VI-OPENWEBUI-DEPLOYMENT-GUIDE.md](VI-OPENWEBUI-DEPLOYMENT-GUIDE.md) - Installation and configuration
- [VI-OPENWEBUI-VERIFICATION-CHECKLIST.md](VI-OPENWEBUI-VERIFICATION-CHECKLIST.md) - Deployment verification
- [vi0-assistant-blueprint.md](docs/vi0-assistant-blueprint.md) - Original Sovereign Stack vision

---

**Last Updated**: 2024-01-15
**Version**: 1.0
**Status**: Architecture Complete
**Components**: 4/4 Deployed
**Integration Level**: Phase 1 (Ready for Phase 2)
