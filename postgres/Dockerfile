ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install PostgreSQL 16 and pgvector
RUN apt-get update && apt-get install -y \
    postgresql-16 \
    postgresql-contrib-16 \
    postgresql-16-pgvector \
    postgresql-16-pgrouting \
    && rm -rf /var/lib/apt/lists/*

# Create postgres system user if not exists
RUN useradd -m -s /bin/bash -u 999 postgres || true

# Create necessary directories with proper permissions
RUN mkdir -p /var/lib/postgresql/16/main \
    && mkdir -p /var/run/postgresql \
    && mkdir -p /var/log/postgresql \
    && chown -R postgres:postgres /var/lib/postgresql \
    && chown -R postgres:postgres /var/run/postgresql \
    && chown -R postgres:postgres /var/log/postgresql \
    && chmod 2700 /var/lib/postgresql/16/main

# Copy service supervision files
COPY rootfs /

# Make scripts executable
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run \
    && chmod +x /etc/s6-overlay/s6-rc.d/*/finish 2>/dev/null || true \
    && chmod +x /usr/local/bin/*.sh

# Setup entrypoint
ENTRYPOINT ["/init"]
