# hadolint ignore=DL3006
ARG BUILD_FROM=ghcr.io/hassio-addons/base:2024.01.1
ARG BUILD_DATE
ARG BUILD_ARCH
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_DESCRIPTION
ARG BUILD_VERSION

FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Node.js and n8n dependencies and create n8n user and directories
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl=7.* \
    gnupg=2.* \
    ca-certificates=20* \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs=20.* \
    && npm install -g n8n@1.0.0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash -u 1000 n8n || true \
    && mkdir -p /data/custom-extensions \
    && mkdir -p /data/.n8n \
    && chown -R n8n:n8n /data

# Copy service supervision files
COPY rootfs /

# Make scripts executable
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/*/finish 2>/dev/null || true \
    && chmod +x /usr/bin/*.sh 2>/dev/null || true

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:5678 || exit 1

# Declare ARG for labels stage
ARG BUILD_NAME
ARG BUILD_DESCRIPTION
ARG BUILD_ARCH
ARG BUILD_VERSION
ARG BUILD_DATE
ARG BUILD_REF

# Labels
LABEL io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="vidoxlabs" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.authors="vidoxlabs" \
    org.opencontainers.image.url="https://github.com/vidoxlabs/vilabs-hassio" \
    org.opencontainers.image.source="https://github.com/vidoxlabs/vilabs-hassio/tree/main/n8n" \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.vendor="vidoxlabs"

# Setup user
USER n8n

# Setup entrypoint
ENTRYPOINT ["/init"]
