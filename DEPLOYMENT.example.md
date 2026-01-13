# 🚀 Deployment Guide: Home Assistant Sovereign Stack

## System Overview

**Hardware:** Your hardware specifications (e.g., Lenovo i7, 16GB RAM)
**OS:** Home Assistant OS
**Network:** `192.168.x.x` (Local) | `https://your-domain.example/` (Secure Access)
**SSH Access:** `ssh root@your-hassio-ip`

## Pre-Deployment Checklist

- [ ] GitHub Account with access to add-on repository
- [ ] Repository cloned or add-on repository URL ready
- [ ] Container Registry access configured (if private)
- [ ] GitHub Actions: CI/CD pipeline enabled
- [ ] Personal Access Token (PAT) with `write:packages` scope (if using private registry)

## Installation Sequence

### 1. Build & Push Images

If self-hosting, commit and push to trigger GitHub Actions:

```bash
git add .
git commit -m "Sovereign Stack deployment"
git push origin main
```

Monitor builds at your GitHub Actions page.

### 2. Add Repository to Home Assistant

1. Navigate to Home Assistant Supervisor → Add-on Store
2. Click **⋮ (three dots) → Repositories**
3. Add this repository URL: `https://github.com/YourOrg/hassio-vilabs-private`
4. Click **Create**

### 3. Install Add-ons (In Order)

**Critical:** Install dependencies first!

```
1. vi-postgres   (Database - foundational)
2. vi-redis      (Cache - n8n dependency)
3. vi-n8n        (Orchestrator)
4. vi-open-webui (Brain)
5. vi-silverbullet (Notations)
```

### 4. Configuration

#### vi-postgres

- **Password:** Change from default `changeme` to a strong password
- **Memory:** Default `shared_buffers: 4GB` is tuned for 16GB systems
- **Port:** `5432` (exposed for local access)

#### vi-redis

- **Memory:** Default `4gb` maxmemory
- **Password:** Leave empty for local-only access (or set for remote access)

#### vi-n8n

- **Database:** Set to `postgres`
- **Postgres Host:** `vi-postgres` (auto-configured)
- **Redis Host:** `vi-redis` (optional, for queue mode)
- **Webhook URL:** `https://your-domain.example/api/webhook/n8n`

#### vi-open-webui

- **Ollama URL:** Point to your GPU node (e.g., `http://192.168.x.x:11434`)
- **Ingress:** Pre-configured with CSRF fix for your domain

#### vi-silverbullet

- No configuration needed
- Notes stored in: `/share/silverbullet`

## Verification Commands (via SSH)

```bash
# SSH into HAOS (replace with your IP)
ssh root@192.168.x.x

# Check running containers
docker ps | grep addon_vi

# View logs
docker logs addon_vi_postgres
docker logs addon_vi_n8n
docker logs addon_vi_openwebui
docker logs addon_vi_silverbullet

# Verify networking
docker exec -it addon_vi_n8n ping vi-postgres
docker exec -it addon_vi_n8n ping vi-redis

# Database connection test
docker exec -it addon_vi_postgres psql -U postgres -c '\l'
```

## Network Topology

```
vi-open-webui ─┬─> vi-postgres (semantic memory)
               │
vi-n8n ────────┴─> vi-redis (cache/queue)
               │
vi-silverbullet ──> /share (filesystem context)
```

## Backup Strategy

- **Postgres:** Auto-dumps to `/share/postgres-backups` daily (last 7 retained)
- **n8n Workflows:** Stored in Postgres
- **SilverBullet Notes:** Plain `.md` files in `/share/silverbullet`
- **Redis:** AOF persistence to `/data/redis`

## Troubleshooting

### "Unable to pull image"

- Ensure repository visibility settings allow package access
- Verify authentication token (if applicable)
- Check GitHub Actions build succeeded

### "Connection refused" (Postgres/Redis)

- Verify add-on slugs match: `vi-postgres`, `vi-redis`
- Check add-on startup order
- Review logs via Home Assistant UI

### Open WebUI CSRF errors

- Verify CSRF settings in configuration
- Restart add-on if needed
- Check Home Assistant logs

### n8n can't access files

- Check `/share` mapping in config
- Verify environment variables are set correctly

## Security Notes

- This is a **private** stack with local-first networking
- Change all default passwords immediately
- Use strong passwords for database access
- Enable SSH key-based authentication (disable password auth)
- Keep Home Assistant and add-ons updated
- Monitor logs for suspicious activity

## Post-Install: First Steps

1. **Create Admin User** in Open WebUI
2. **Import n8n Templates** from workflow library
3. **Initialize SilverBullet** by creating your first note
4. **Configure Postgres Extensions** (optional):
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   CREATE EXTENSION IF NOT EXISTS pgcrypto;
   ```

---

**Note:** Replace placeholder values (`192.168.x.x`, `your-domain.example`, etc.) with your actual system configuration.
