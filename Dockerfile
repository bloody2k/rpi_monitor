FROM alpine:latest

# Build environment variables
ENV VER=0.0.8 \
    BUILDON="alpine" \
    CREATED="BLOODY2k" \
    MON_OPT=""

VOLUME /config

# Install Monitor dependencies
RUN apk add --no-cache \
        openrc \
        coreutils \
        procps \
        gawk \
        git \
        bash \
        curl \
        mosquitto \
        mosquitto-clients \
        bc \
        bluez \
        bluez-deprecated \
        bluez-btmon \
        dumb-init 
        
COPY startup.sh /startup.sh
RUN ["chmod", "+x", "/startup.sh"]

COPY health.sh /usr/local/bin/health
RUN ["chmod", "+x", "/usr/local/bin/health"]

ENTRYPOINT ["dumb-init", "--", "/startup.sh"]
HEALTHCHECK CMD health
