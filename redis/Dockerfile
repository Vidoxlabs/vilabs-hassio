ARG BUILD_FROM
ARG BUILD_DATE
ARG BUILD_ARCH
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_DESCRIPTION
ARG BUILD_VERSION

FROM ${BUILD_FROM}

# Install Redis server and utilities
RUN apt-get update && apt-get install -y \
    redis-server \
    redis-tools \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create redis user and directories
RUN useradd -m -s /bin/bash -u 999 redis || true \
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
    maintainer="Viotic" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.authors="Viotic" \
    org.opencontainers.image.url="https://github.com/Viotic/hassio-vilabs-private" \
    org.opencontainers.image.source="https://github.com/Viotic/hassio-vilabs-private/tree/main/vi-redis" \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.vendor="Viotic"

# Setup entrypoint
ENTRYPOINT ["/init"]
