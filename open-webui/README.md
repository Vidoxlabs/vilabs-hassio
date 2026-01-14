# Vi-Face (Open WebUI)

## Overview

**Vi-Face** is the primary user-facing chat interface for the Sovereign Stack. It provides a web-based UI for conversing with local LLMs via an external **Ollama GPU node**, enabling powerful AI conversations while maintaining complete data privacy and local control.

## Role in Sovereign Stack

```markdown
Home Assistant User
    ↓
Vi-Face (Open WebUI)  ← You are here
    ↓ (REST API)
External Ollama GPU Node (v37-gpu-01:11434)
    ↓ (LLM inference)
Local Model (mistral, llama2, etc.)
    ↑
    └─ Results returned to Open WebUI
```

## Features

- **Chat Interface**: Beautiful, responsive web UI for conversing with local LLMs
- **Multi-Model Support**: Switch between different models in real-time
- **Web Search Integration**: Optional web search for current information (privacy-respecting search engines)
- **Image Generation**: Optional integration with Stable Diffusion or ComfyUI
- **User Management**: Multi-user support with login/signup, or single-user mode
- **Model Filtering**: Control which models are available to users
- **External Ollama**: Connects to GPU node for inference (not local, saves resources)
- **Chat History**: All conversations saved locally in `/data`
- **Home Assistant Integration**: Seamless access via Home Assistant Ingress

## Architecture

### Lightweight Design

Unlike traditional Open WebUI deployments, **vi-openwebui** is configured specifically for Home Assistant:

```markdown
Home Assistant OS (i7 CPU)
├─ Home Assistant Core
├─ vi-n8n (workflows)
├─ vi-redis (caching)
├─ vi-postgres (storage)
└─ vi-openwebui (chat UI) ← Lightweight, uses external Ollama
    └─ Ollama GPU Node (remote) ← Heavy lifting happens here
```

The i7 in your Lenovo handles:

- Web UI serving
- Chat history management
- User authentication

The GPU node (v37-gpu-01) handles:

- Model inference
- Token generation
- Embedding computation

## Configuration

### Critical Setting: Ollama URL

The most important configuration is the **Ollama base URL**. This defaults to `http://v37-gpu-01:11434`.

If you're using a different GPU node:

1. In Home Assistant, go to **Settings → Add-ons & Backups → Vi-Face**
2. Click **Settings**
3. Change **Ollama server URL** to your node (e.g., `http://my-gpu-node:11434`)
4. Click **Save**
5. Restart the add-on

### Recommended Configuration

```yaml
Log Level: info
Ollama URL: http://v37-gpu-01:11434  (adjust to your GPU node)
Default Models: mistral,llama2-uncensored
Enable Signup: true (or false for single-user)
Enable Login Form: true
Web Search: false (unless desired)
Image Generation: false (unless you have Stable Diffusion)
```

### All Configuration Options

| Option                   | Default    | Description                                     |
| ------------------------ | ---------- | ----------------------------------------------- |
| **Log Level**            | info       | Verbosity (debug, info, notice, warning, error) |
| **Default Models**       | (empty)    | Models to pre-load (comma-separated)            |
| **Allow Signup**         | true       | Permit new user registration                    |
| **Login Form**           | true       | Show login UI                                   |
| **Web Search**           | false      | Enable web search in conversations              |
| **Search Engine**        | duckduckgo | Engine for web search                           |
| **Image Generation**     | false      | Enable image synthesis                          |
| **Stable Diffusion URL** | (empty)    | WebUI endpoint for images                       |
| **ComfyUI URL**          | (empty)    | ComfyUI endpoint for images                     |
| **OpenAI API URL**       | (empty)    | Alternative LLM endpoint                        |
| **OpenAI API Key**       | (empty)    | API key for alternative endpoint                |
| **Model Filter**         | false      | Restrict available models                       |
| **Filter List**          | (empty)    | Models to allow/restrict                        |

## Getting Started

### 1. Verify Ollama is Running

Before starting vi-openwebui, ensure your Ollama GPU node is running:

```bash
curl http://v37-gpu-01:11434/api/tags
# Should return: {"models":[...]}
```

If this fails, vi-openwebui will start but won't have models available.

### 2. Install Add-on

1. **Settings → Add-ons & Backups → Create Add-on**
2. Or use existing local repository
3. Click **Vi-Face (Open WebUI)**
4. Click **Install**
5. Click **Settings** and verify Ollama URL
6. Click **Start**

### 3. Access the UI

Once running:

1. Home Assistant Sidebar → **Open WebUI** (if visible)
2. Or navigate to **Settings → Add-ons & Backups → Vi-Face → Open**
3. Or manually go to `http://<home-assistant-ip>:8080`

### 4. Create User Account (if enabled)

- If signup is enabled, create your account
- If signup is disabled, use default credentials or environment variables

### 5. Select a Model

1. Click the **Model dropdown** (top of chat)
2. Choose a model that's loaded in Ollama (e.g., mistral)
3. Start chatting!

## Using with Ollama

### Verify Available Models

```bash
# From your GPU node
curl http://v37-gpu-01:11434/api/tags | jq '.models[].name'

# Should show: mistral, llama2, etc.
```

### Load a New Model

```bash
# SSH into GPU node
ssh v37-gpu-01
ollama pull mistral
ollama pull neural-chat
```

The models will immediately appear in Open WebUI.

### Performance Tips

- **Default Models**: Specify frequently-used models in config to pre-warm them
- **Model Timeout**: Ollama has a timeout before unloading unused models
- **GPU Memory**: Monitor your GPU node's memory usage
- **Concurrent Users**: Each chat session uses model memory; limit users accordingly

## Integration Examples

### With vi-n8n Workflows

You can call vi-openwebui from n8n workflows:

```javascript
// In n8n workflow
const response = await fetch(
  "http://vi-openwebui:8080/api/v1/chat/completions",
  {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "mistral",
      messages: [{ role: "user", content: "Hello!" }],
    }),
  },
);
```

### With Home Assistant Automations

Trigger Open WebUI from HA automations (create workflows in vi-n8n that use Open WebUI API).

### With External Services

Open WebUI exposes OpenAI-compatible API endpoints for external integrations:

```bash
curl http://vi-openwebui:8080/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistral",
    "messages": [{"role": "user", "content": "What is 2+2?"}]
  }'
```

## Troubleshooting

### "No Models Available"

**Problem**: Chat shows no models to select.

**Solutions**:

1. Verify Ollama is running: `curl http://v37-gpu-01:11434/api/tags`
2. Check Ollama URL in vi-openwebui config
3. Check firewall/network between Home Assistant and GPU node
4. Check logs: **Settings → Add-ons & Backups → Vi-Face → Logs**

```bash
# Expected log output:
[init] Initializing Vi-Face (Open WebUI)...
[start] Attempting to connect to Ollama at: http://v37-gpu-01:11434
[start] ✓ Ollama is reachable
```

### Slow Responses

**Problem**: Chat responses are slow or timeout.

**Solutions**:

1. Check GPU node load: `nvidia-smi` on GPU server
2. Reduce model size (use `neural-chat` instead of `mistral`)
3. Increase timeout in Ollama config
4. Reduce concurrent users/sessions

### Connection Refused

**Problem**: "Connection refused" when opening chat.

**Solutions**:

1. Verify add-on is running: Check green checkmark in sidebar
2. Check logs for errors
3. Ensure port 8080 is not in use
4. Try restarting the add-on

### Login Issues

**Problem**: Can't create account or login fails.

**Solutions**:

1. If signup is disabled, enable it temporarily
2. Check if default user exists
3. Clear browser cookies and try again
4. Check logs for authentication errors

## Data Storage

All chat history and user data is stored in `/data`:

```markdown
/data/
├─ open-webui.db       # SQLite database (chat history, users, models)
├─ uploads/            # User-uploaded files
└─ models/             # Downloaded models (if any)
```

This persists across:

- ✅ Add-on restart
- ✅ Home Assistant update
- ✅ Home Assistant snapshot/restore
- ❌ Will NOT persist if `/data` is deleted

## Backup & Recovery

### Backup Chat History

```bash
# Create backup
tar -czf openwebui-backup.tar.gz /data/

# Restore backup
tar -xzf openwebui-backup.tar.gz -C /
```

### Home Assistant Snapshots

Open WebUI data is included in Home Assistant snapshots:

1. **Settings → System → Snapshots**
2. Click **Create Snapshot**
3. Data is backed up automatically

## Hardware Considerations

### CPU Usage

- Low idle (~1-2% per core)
- Moderate during chat serving (5-10%)
- Depends on Ollama response processing

### Memory Usage

- ~200-300MB base
- Additional memory for chat history
- Grows with number of concurrent users

### Network

- Requires network access to Ollama node
- Bandwidth for model responses (typically small, ~1KB per token)
- Low latency preferred (LAN recommended)

## Advanced Configuration

### Single-User Mode

To use as a personal chat without login:

1. Set **Allow Signup**: false
2. Set **Login Form**: false
3. Set **Default Models**: specify models (optional)

All users will access the same chat history.

### External LLM Providers

To use OpenAI or compatible API instead of Ollama:

1. Set **OpenAI API URL**: your endpoint
2. Set **OpenAI API Key**: your API key
3. Models from OpenAI will appear alongside local models

Note: This uses external services, reducing privacy.

### Model Filtering

To restrict which models users can access:

1. Set **Model Filter**: true
2. Set **Filter List**: `mistral,llama2` (only allow these)

Helpful for controlling costs or preventing model misuse.

## Performance Optimization

### For i7-1355U (Your Hardware)

The i7 handles the chat UI efficiently. To optimize:

1. Keep **Default Models** empty to avoid pre-loading unused models
2. Use smaller models on GPU node when possible
3. Limit concurrent users to 2-4 simultaneously
4. Monitor RAM usage on Home Assistant system

### For Ollama GPU Node

- Monitor `nvidia-smi` on GPU server
- Pre-warm frequently-used models
- Adjust `OLLAMA_NUM_PARALLEL` if needed (set in init-openwebui.sh)
- Use quantized models (q4_0, q5_0) for faster inference

## Security Notes

### Local Network Only

- vi-openwebui is bound to `127.0.0.1`
- Access via Home Assistant Ingress only (secure)
- Not exposed directly to internet (unless you explicitly configure Ingress)

### User Authentication

- Passwords stored in `/data/open-webui.db`
- Simple authentication, not enterprise-grade
- Use `admin` account for management

### API Access

- OpenAI-compatible API is available
- No API key required for local access
- Consider adding API authentication for external calls

## Persistence & Restart

All data persists in `/data`:

```markdown
Service Restart:      ✅ Chat history retained
Add-on Update:        ✅ Chat history retained
Home Assistant Update: ✅ Chat history retained
Home Assistant Restart: ✅ Chat history retained
Home Assistant Snapshot/Restore: ✅ Restored
```

Data is permanently deleted only if:

- ❌ `/data` directory is manually deleted
- ❌ Docker volume is removed
- ❌ Home Assistant is uninstalled

## Integration with Sovereign Stack

### With vi-n8n (Workflows)

Create workflows that:

- Call Open WebUI API for LLM inference
- Store conversation summaries in vi-postgres
- Cache frequent queries in vi-redis

### With vi-postgres (Memory)

Store:

- Chat summaries in vi-postgres
- User conversation metadata
- Embeddings for semantic search

### With vi-redis (Cache)

Cache:

- Recently used models
- Conversation context
- User session data

## Future Enhancements

Potential additions:

- [ ] Voice input/output (STT/TTS)
- [ ] Vision models support
- [ ] Multi-GPU load balancing
- [ ] Advanced prompt engineering UI
- [ ] Function calling / plugins
- [ ] Mobile app integration
- [ ] Knowledge base RAG integration
- [ ] Analytics dashboard

## References

- [Open WebUI Documentation](https://docs.openwebui.com/)
- [Ollama Documentation](https://github.com/ollama/ollama)
- [Home Assistant Add-on Development](https://developers.home-assistant.io/docs/add-ons_configuration/)
- [Sovereign Stack Blueprint](../docs/vi0-assistant-blueprint.md)

## Support

### Getting Help

1. Check **Logs** in Home Assistant UI
2. Review this README's Troubleshooting section
3. Verify Ollama connectivity from Home Assistant network
4. Check vi-openwebui service status

### Common Issues

| Issue         | Solution                               |
| ------------- | -------------------------------------- |
| No models     | Check Ollama URL config & connectivity |
| Slow chat     | Check GPU node load, try smaller model |
| Won't start   | Check logs, verify Python installed    |
| Login fails   | Enable signup temporarily, check DB    |
| Port conflict | Change port if 8080 is in use          |

## License

MIT License - See LICENSE.md

---

**Vi-Face is the face of your Sovereign Stack.** 🤖

It's the bridge between you and your AI, fully local, fully private, fully yours.
