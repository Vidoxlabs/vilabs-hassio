# **Home Assistant Add-ons Repository**

A collection of production-ready Home Assistant add-ons for local intelligence, data ownership, and workflow automation.

## ⚠️ **Security Notice**

**Never commit sensitive information to this repository:**

- ❌ Do NOT commit `secrets.yaml`, `.env`, or similar files
- ❌ Do NOT commit SSH keys, private keys, or credentials
- ❌ Do NOT commit real IP addresses, domain names, or personal information
- ✅ DO use placeholder values for examples (e.g., `192.168.x.x`, `your-domain.example`)
- ✅ DO store sensitive data in Home Assistant secrets, not in code
- ✅ DO use strong, unique passwords for all services
- ✅ DO enable key-based SSH authentication

See [SECURITY.md](.github/SECURITY.md) for complete security guidelines.

## **About**

This repository provides a suite of Home Assistant add-ons designed for local-first deployments. These services are pre-configured to work together within the Home Assistant OS ecosystem, enabling local file access, vector database storage, and complex workflow orchestration.

The add-ons enable a fully private, locally-hosted system that respects your data privacy while providing advanced automation capabilities. By leveraging Home Assistant's robust add-on system, you can extend functionality far beyond basic home automation, creating a central hub for your digital life including document management, data processing, and intelligent automation.

## **Installation**

Adding this add-ons repository to your Home Assistant instance:

1. Navigate to **Settings** > **Add-ons** > **Add-on Store**
2. Click the **three dots** in the top right corner and select **Repositories**
3. Add the following URL:

`https://github.com/Viotic/hassio-vilabs-private`

Once added, you will see the new add-ons available for installation in the store. Each add-on is designed to be self-contained with minimal configuration required to get started.

## **Add-ons**

This repository contains the following core services:

### **n8n - Workflow Orchestration**

A powerful workflow automation and orchestration tool with direct access to local storage and Home Assistant integration capabilities.

- **Features:** Complex logic, API orchestration, file processing, multi-service automation
- **Documentation:** See [n8n README](n8n/README.md)

### **PostgreSQL - Vector Database**

A production-grade relational database with pgvector extension for semantic search and vector embeddings.

- **Features:** High-performance history recording, semantic search, vector embeddings storage, pgvector support
- **Documentation:** See [PostgreSQL README](postgres/README.md)

### **Redis - In-Memory Cache**

A high-speed in-memory data store for caching, session state, and workflow execution buffers.

- **Features:** Fast caching, session storage, message queue support, execution state buffering
- **Documentation:** See [Redis README](redis/README.md)

### **Open WebUI - LLM Chat Interface**

Chat interface for local and external LLMs with flexible model integration.

- **Features:** Multiple model support, local LLM integration, Ollama compatibility, web-based interface
- **Documentation:** See [Open WebUI README](open-webui/README.md)

## **Quick Start**

1. Install Home Assistant OS on your device
2. Add this repository via the Add-on Store
3. Install desired add-ons (typically postgres first, then redis, then other services)
4. Configure each add-on according to your needs
5. Access services via their web interfaces or integrate with Home Assistant automations

## **Configuration**

Each add-on includes comprehensive configuration options. See individual README files for detailed setup instructions.

### **Recommended Setup Order**

1. **PostgreSQL** - Database backend
2. **Redis** - Cache and session store
3. **n8n** - Workflow automation
4. **Open WebUI** - LLM interface (requires external Ollama or API)

## **Security & Best Practices**

### **Installation Security**

- Only add this repository from the official GitHub URL
- Verify you're adding from: `https://github.com/Viotic/hassio-vilabs-private`
- Use HTTPS for all Home Assistant communications
- Enable two-factor authentication on your GitHub account

### **Configuration Security**

- **Change default passwords immediately** after installation
- Use strong, unique passwords for:
  - PostgreSQL (`postgres_password`)
  - Any exposed services
  - SSH access credentials
- Enable authentication on all exposed services
- Use Home Assistant secrets for sensitive values:

  ```yaml
  # ✅ Correct - use secrets
  postgres_password: !secret postgres_password

  # ❌ Wrong - never hardcode
  postgres_password: "my-password-here"
  ```

### **Network Security**

- Run Home Assistant on a private, trusted network
- Use VPN or firewall to protect remote access
- Keep Home Assistant and add-ons updated
- Use SSH key-based authentication (disable password auth)
- Monitor logs for suspicious activity

### **Deployment Safety**

For detailed deployment instructions with security best practices, see [DEPLOYMENT.example.md](DEPLOYMENT.example.md).

**Remember:** Replace all placeholder values:

- `192.168.x.x` → Your actual local IP
- `your-domain.example` → Your actual domain
- `root@your-hassio-ip` → Your actual SSH connection

## **Support**

- Open an issue on [GitHub](https://github.com/Viotic/hassio-vilabs-private/issues)
- Check the [Home Assistant Community Forum](https://community.home-assistant.io)

## **Contributing**

Contributions are welcome! Please submit pull requests with improvements, bug fixes, or new add-ons.

## **License**

This project is licensed under the MIT License. See LICENSE file for details.

## **Security Policy**

For security policies, vulnerability reporting, and best practices, see [SECURITY.md](.github/SECURITY.md).

Copyright (c) Viotic
