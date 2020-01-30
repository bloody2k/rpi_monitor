ARG BUILD_FROM=hassioaddons/debian-base:latest
# hadolint ignore=DL3006
FROM debian:buster-slim

# Build environment variables
ENV VER=0.0.8 \
    BUILDON="alpine" \
    CREATED="BLOODY2k" \
    MON_OPT=""

# Install required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bc \
        bluetooth \
        bluez \
        bluez-hcidump \
        git \
        mosquitto-clients \
        procps \
        usbutils \
    && git clone --branch "master" --depth=1 https://github.com/andrewjfreyer/monitor.git /monitor \
    && cd /monitor \
    && git checkout origin/master -f

# Copy root filesystem
COPY startup.sh /startup.sh
RUN ["chmod", "+x", "/startup.sh"]

COPY health.sh /health.sh
RUN ["chmod", "+x", "/health.sh"]

# Configure system
RUN install -d /config \
    && touch \
        /monitor/.pids \
        /monitor/.previous_version \
        /config/.public_name_cache \
    # link the public name cache to the config directory ... i think there's a bug in monitor.sh
    # where it doesn't consistently reference the same path to this... sometimes it looks in
    # $base_directory (which we have as /opt/monitor) and sometimes its in the app root (i.e. /monitor)
    && ln -s /config/.public_name_cache /monitor/.public_name_cache \
    # make things executable
    && chmod +x /*.sh \
    && ln -s /monitor/monitor.sh /usr/local/bin/monitor

WORKDIR /monitor

CMD /startup.sh
HEALTHCHECK CMD /health.sh

# Labels
LABEL \
    maintainer="Andrey Khrolenok <andrey@khrolenok.ru>" \
    org.label-schema.description="Passive Bluetooth presence detection of beacons, cell phones, and other Bluetooth devices." \
    org.label-schema.name="Bluetooth Presence Monitor" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vendor="B2k's Hass.io Addons"
