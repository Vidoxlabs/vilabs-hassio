ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV DENO_INSTALL=/usr/local
ENV PATH=${DENO_INSTALL}/bin:${PATH}

# Install dependencies and applications
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    && curl -fsSL https://deno.land/x/install/install.sh | sh \
    && deno install -f --name silverbullet --unstable-kv --unstable-worker-options -A https://get.silverbullet.md \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs /

# Ensure scripts are executable
RUN chmod +x /etc/s6-overlay/s6-rc.d/*/run 2>/dev/null || true

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Vidoxlabs"
