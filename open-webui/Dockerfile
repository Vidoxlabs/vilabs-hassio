# hadolint ignore=DL3006
ARG BUILD_FROM=ghcr.io/hassio-addons/base:2024.06.0

FROM ${BUILD_FROM}

ARG BUILD_DATE
ARG BUILD_ARCH
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_DESCRIPTION
ARG BUILD_VERSION

# Install system dependencies and Python
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3=3.11.* \
    python3-pip=23.0.* \
    python3-dev=3.11.* \
    libffi-dev=3.4.* \
    libssl-dev=3.0.* \
    libpq-dev=15.* \
    build-essential=12.9* \
    curl=7.* \
    git=1:2.* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir --upgrade pip==23.3.1 setuptools==68.0.0 wheel==0.41.2 \
    && pip3 install --no-cache-dir open-webui==0.1.140 \
    && useradd -m -s /bin/bash -u 1000 openwebui || true \
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
    maintainer="vidoxlabs" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.authors="vidoxlabs" \
    org.opencontainers.image.url="https://github.com/vidoxlabs/vilabs-hassio" \
    org.opencontainers.image.source="https://github.com/vidoxlabs/vilabs-hassio/tree/main/open-webui" \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.vendor="vidoxlabs"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://127.0.0.1:8080/ || exit 1

# Setup user
USER openwebui

# Setup entrypoint
ENTRYPOINT ["/init"]
