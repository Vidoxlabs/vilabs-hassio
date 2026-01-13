#!/command/with-contenv bashio

bashio::log.info "Starting Vi-Orchestrator (n8n)..."
bashio::log.info "Node.js version: $(node --version)"
bashio::log.info "n8n version: $(npm list -g n8n 2>/dev/null | grep n8n | head -1)"

# Source environment configuration
[[ -f /data/.env ]] && export $(cat /data/.env | xargs)

# Change to n8n user and start service
exec n8n start
