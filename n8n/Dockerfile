FROM ${BUILD_FROM}

ARG BUILD_DATE
ARG BUILD_ARCH
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_DESCRIPTION
ARG BUILD_VERSION

# Install Node.js and n8n dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g n8n \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create n8n user and directories and set permissions
RUN useradd -m -s /bin/bash -u 1000 n8n || true \
    && mkdir -p /data/custom-extensions \
    && mkdir -p /data/.n8n \
    && chown -R n8n:n8n /data

# Copy service supervision files
COPY rootfs /

# Make scripts executable
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/*/finish 2>/dev/null || true \
    && chmod +x /usr/bin/*.sh 2>/dev/null || true

# Labels
LABEL io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Vidoxlabs" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.authors="Vidoxlabs" \
    org.opencontainers.image.url="https://github.com/Vidoxlabs/vilabs-hassio" \
    org.opencontainers.image.source="https://github.com/Vidoxlabs/vilabs-hassio/tree/main/n8n" \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.vendor="Vidoxlabs"

# Setup entrypoint
ENTRYPOINT ["/init"]
