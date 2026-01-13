ARG BUILD_FROM
ARG BUILD_DATE
ARG BUILD_ARCH
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_DESCRIPTION
ARG BUILD_VERSION

FROM ${BUILD_FROM}

# Install system dependencies and Python
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    libffi-dev \
    libssl-dev \
    libpq-dev \
    build-essential \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Open WebUI
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel \
    && pip3 install --no-cache-dir open-webui

# Create openwebui user and directories and set permissions
RUN useradd -m -s /bin/bash -u 1000 openwebui || true \
    && mkdir -p /data \
    && chown -R openwebui:openwebui /data

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
    org.opencontainers.image.source="https://github.com/Vidoxlabs/vilabs-hassio/tree/main/open-webui" \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.vendor="Vidoxlabs"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://127.0.0.1:8080/ || exit 1

# Setup entrypoint
ENTRYPOINT ["/init"]
