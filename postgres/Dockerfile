# hadolint ignore=DL3006
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.18

FROM ${BUILD_FROM}

# Set SHELL option and add PostgreSQL Global Development Group (PGDG) repository
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008,DL3015
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    wget \
    && install -d /usr/share/keyrings \
    && wget --quiet -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgres.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/postgres.gpg] http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    postgresql-16=16.* \
    postgresql-contrib-16=16.* \
    postgresql-16-pgvector=16.* \
    postgresql-16-pgrouting=16.* \
    && apt-get purge -y --auto-remove ca-certificates gnupg wget \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash -u 999 postgres || true \
    && mkdir -p /var/lib/postgresql/16/main \
    && mkdir -p /var/run/postgresql \
    && mkdir -p /var/log/postgresql \
    && chown -R postgres:postgres /var/lib/postgresql \
    && chown -R postgres:postgres /var/run/postgresql \
    && chown -R postgres:postgres /var/log/postgresql \
    && chmod 2700 /var/lib/postgresql/16/main

# Copy service supervision files
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 CMD pg_isready -U postgres

COPY rootfs /

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="vidoxlabs" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="vidoxlabs" \
    org.opencontainers.image.authors="vidoxlabs" \
    org.opencontainers.image.url="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

# Make scripts executable
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/*/finish 2>/dev/null || true \
    && chmod +x /usr/local/bin/*.sh
USER postgres


# Setup entrypoint
ENTRYPOINT ["/init"]
