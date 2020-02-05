ARG BUILD_FROM=hassioaddons/debian-base:latest
# hadolint ignore=DL3006
FROM arm32v7/debian:buster

# Build environment variables
ENV VER=0.0.8 \
    BUILDON="debian-buster" \
    CREATED="BLOODY2k" \
    MON_OPT=""

#RUN apt-get update && apt-get -y install gnupg apt-transport-https

# GET Mosquitto key for apt
#ADD http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key /mosquitto-repo.gpg.key
#RUN apt-key add /mosquitto-repo.gpg.key
#ADD http://repo.mosquitto.org/debian/mosquitto-buster.list /etc/apt/sources.list.d/mosquitto-buster.list
#RUN apt-cache search mosquitto

# Install required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bc \
        bluetooth \
        bluez \
        bluez-hcidump \
        ca-certificates \
        git \
        libmosquitto-dev=1.6.4-0mosquitto1 \
        libmosquitto1=1.6.4-0mosquitto1 \
        mosquitto=1.6.4-0mosquitto1 \
        mosquitto-clients=1.6.4-0mosquitto1 \
        procps \
        usbutils \
    && apt-mark hold libmosquitto1 libmosquitto-dev mosquitto mosquitto-clients \
    && git clone --branch "0.2.1" --depth=1 https://github.com/andrewjfreyer/monitor.git /monitor \
    && cd /monitor 
    # && git checkout tag/0.2.1 -f

RUN ["chmod", "+x", "/monitor/monitor.sh"]

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
    org.label-schema.schema-version="BETA" \
    org.label-schema.vendor="B2k's Docker Image - Debian"
