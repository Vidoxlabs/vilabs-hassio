# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this Home Assistant add-on repository, please report it responsibly:

1. **Do NOT** create a public GitHub issue
2. **Email** security concerns to: vio@vidoxlabs.dev (or your designated security contact)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

We will:

- Acknowledge receipt within 48 hours
- Work with you to understand the scope
- Release a patched version if needed
- Credit you for responsible disclosure

## Security Best Practices for Users

### Installation

- Only add this repository from the official GitHub URL
- Verify repository signatures when available
- Use HTTPS for all Home Assistant communications

### Configuration

- **Change default passwords immediately** after installation
- Never commit `secrets.yaml` to version control
- Use strong, unique passwords for all services
- Enable authentication on all exposed services

### Network Security

- Run Home Assistant on a private, trusted network
- Use a VPN or firewall to protect remote access
- Keep Home Assistant and add-ons updated
- Monitor logs for suspicious activity

### Secrets Management

- Store sensitive data in Home Assistant secrets, not in code
- Use environment variables for API keys
- Rotate credentials regularly
- Never share database passwords or API tokens

## Sensitive Data Handling

This repository does NOT contain:

- Real IP addresses or domain names
- Default credentials (except for configuration examples marked as `changeme`)
- Private keys or SSH credentials
- API tokens or secrets
- Personal information

All examples use placeholder values (e.g., `10.10.10.x`, `your-domain.example`).

## Container Security

All Docker images in this repository:

- Use minimal base images to reduce attack surface
- Run services with appropriate privilege levels
- Include security labels in Dockerfiles
- Follow Home Assistant add-on security standards

## Updates and Patches

- Security updates are released as soon as available
- Critical vulnerabilities may be fast-tracked
- Users are encouraged to enable automatic updates
- Changelog documents all security fixes

---

**Last Updated:** January 13, 2026
**Maintainer:** Vioxniv
