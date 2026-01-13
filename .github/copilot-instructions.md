# **GitHub Copilot Instructions for vilabs-home**

This repository hosts a "Sovereign Stack" of Home Assistant add-ons designed for local intelligence and data ownership. When generating code or configurations for this project, please adhere to the following guidelines.

## **1\. Project Context & Architecture**

* **Goal:** Create a "Contextual Appliance" on Home Assistant OS (HAOS) running on a Lenovo i7.
* **Philosophy:** Local-first, privacy-focused, "Sovereign Stack".
* **Target OS:** Home Assistant OS (HAOS).
* **Key Add-ons:**
  * PostgreSQL 16 \+ pgvector (Long-term Memory).
  * n8n Workflow Automation (Orchestrator).
  * Redis (Caching/Short-term Memory).
* **Hardware Awareness:** The host has an i7 processor (good for burst loads) and 16GB RAM. Configurations should be tuned accordingly (e.g., generous Postgres shared buffers).

## **2\. Coding Standards for Home Assistant Add-ons**

Always follow these patterns, derived from the hassio-addon-example best practices:

### **Configuration (config.yaml)**

* **Format:** Use YAML.
* **Schema:** Define a schema for every option listed in options.
* **Architecture:** Explicitly list supported architectures (aarch64, amd64).
* **Ingress:** Use ingress: true for web-based tools.
* **Ports:** Map ports explicitly if external access is needed.
* **Init:** Set init: false to disable the legacy custom init system (we use S6).

### **Dockerfile**

* **Base Image:** Use ARG BUILD\_FROM and FROM ${BUILD\_FROM}. Defaults should point to ghcr.io/hassio-addons/base or debian-base.
* **File Structure:** Use the **RootFS** pattern.
  * Place all config files, scripts, and S6 configs in a local rootfs/ folder.
  * In Dockerfile: COPY rootfs /.
* **Labels & Meta:** Include the standard build arguments and labels found in the example:
  ARG BUILD\_ARCH
  ARG BUILD\_DATE
  ARG BUILD\_DESCRIPTION
  ARG BUILD\_NAME
  ARG BUILD\_REF
  ARG BUILD\_REPOSITORY
  ARG BUILD\_VERSION

  LABEL \\
      io.hass.name="${BUILD\_NAME}" \\
      io.hass.description="${BUILD\_DESCRIPTION}" \\
      io.hass.arch="${BUILD\_ARCH}" \\
      io.hass.type="addon" \\
      io.hass.version=${BUILD\_VERSION} \\
      maintainer="Vidoxlabs" \\
      \# ... other opencontainers labels

### **Shell Scripts (run.sh / Binaries)**

* **Shebang:** Use \#\!/command/with-contenv bashio for all scripts to ensure Bashio availability.
* **Logging:** ALWAYS use bashio::log.info, bashio::log.warning, bashio::log.error. Do not use echo.
* **Config:** Access options via bashio::config 'option\_name'.
* **Structure:**
  * Place main executable logic in rootfs/usr/bin/.
  * Make scripts executable in the Dockerfile (chmod \+x /usr/bin/\*.sh).

### **S6 Overlay (Process Management)**

Use the modern **S6-RC** format located in rootfs/etc/s6-overlay/s6-rc.d/.

* **Directory Name:** Create a folder for each service (e.g., vi-n8n).
* **Files Required inside the service folder:**
  * type: usually longrun for services or oneshot for init tasks.
  * run: The script that starts the service. Shebang: \#\!/command/with-contenv bashio.
  * finish (Optional): Clean up logic.
* **Dependencies:** If a service depends on initialization, use a dependencies.d folder or init stage.

### **Translations**

* Create translations/en.yaml for every add-on.
* Map configuration options to readable names and descriptions:
  configuration:
    log\_level:
      name: Log level
      description: Controls the verbosity of the logs.

## **3\. "Sovereign Context" Specifics**

When asked to "reference sources" or "enable context":

* **Filesystem Access:**
  * Ensure add-ons map the /share directory (map: \["share:rw"\] in config.yaml).
  * This is the shared "Context Lake".
* **Persistence:**
  * ALWAYS map /data for persistent storage.
  * In run scripts, ensure the application writes to /data (e.g., export N8N\_USER\_FOLDER="/data").

## **4\. Documentation Awareness**

* **Blueprints:** Refer to Obsidian/vi0-assistant-blueprint.md for architectural decisions.
* **Role Definition:**
  * n8n: Orchestrator.
  * postgres: Memory.
  * redis: Cache.

## **5\. Example Pattern (n8n access to local files)**

If asked to configure n8n to read local files, ensure the config.yaml maps the share:

map:
  \- share:rw

And the run script (in rootfs/etc/s6-overlay/s6-rc.d/n8n/run) exports:

export N8N\_BLOCK\_ENV\_ACCESS\_IN\_NODE=false
