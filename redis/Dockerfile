# hadolint ignore=DL3006
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:2023.12.0

FROM ${BUILD_FROM}

ARG BUILD_DATE
ARG BUILD_ARCH
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_DESCRIPTION
ARG BUILD_VERSION

# Install Redis server and utilities
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    redis-server=7:7.0.8-1 \
    redis-tools=7:7.0.8-1 \
    curl=7.88.1-10+deb12u5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash -u 999 redis || true \
    && mkdir -p /data/redis \
    && chown -R redis:redis /data

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
    org.opencontainers.image.source="https://github.com/vidoxlabs/vilabs-hassio/tree/main/redis" \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.vendor="vidoxlabs"

# Setup entrypoint
ENTRYPOINT ["/init"]
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD redis-cli ping

USER redis
