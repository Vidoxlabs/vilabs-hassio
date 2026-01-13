#!/command/with-contenv bashio

bashio::log.info "Starting Vi-Face (Open WebUI)..."
bashio::log.info "Python version: $(python3 --version)"

# Source environment configuration
if [[ -f /data/.env ]]; then
    set -a
    source /data/.env
    set +a
    bashio::log.info "Environment configuration loaded"
fi

# Verify Ollama connectivity
OLLAMA_URL="${OLLAMA_BASE_URL:-http://v37-gpu-01:11434}"
bashio::log.info "Attempting to connect to Ollama at: $OLLAMA_URL"

# Simple connectivity check (non-blocking)
if timeout 5 curl -s "$OLLAMA_URL/api/tags" > /dev/null 2>&1; then
    bashio::log.info "✓ Ollama is reachable"
else
    bashio::log.warning "⚠ Ollama may not be reachable at $OLLAMA_URL"
    bashio::log.warning "  Chat will still start but may not have models available"
    bashio::log.warning "  Verify your Ollama GPU node is running and accessible"
fi

bashio::log.info "Starting Open WebUI server on port 8080..."
bashio::log.info "Access via Home Assistant Ingress or http://127.0.0.1:8080"

# Start Open WebUI
cd /data
exec open-webui serve --host 127.0.0.1 --port 8080
