#FROM golang:buster AS builder
# ... my go build steps (removed from this example) 
#WORKDIR /builder/working/directory
#RUN curl -L https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz | tar zxvf - -C . && mv qemu-3.0.0+resin-arm/qemu-arm-static .

#FROM arm32v7/debian:stretch

FROM balenalib/armv7hf-debian:latest

# Copy across the qemu binary that was downloaded in the previous build step
#COPY --from=builder /builder/working/directory/qemu-arm-static /usr/bin
# Now you can tun ARM docker steps.. yay!

#COPY qemu-arm-static /usr/bin

#FROM arm32v7/alpine:latest
# Build environment variables
ENV VER=0.0.8 \
    CREATED="BLOODY2k" \
    MON_OPT="" \

VOLUME /config

# Install Monitor dependencies
RUN apt-get update && apt-get install -y \
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
        bluez-tools \
        bluez-hcidump \
        dumb-init

COPY startup.sh /startup.sh
RUN ["chmod", "+x", "/startup.sh"]

COPY health.sh /usr/local/bin/health
RUN ["chmod", "+x", "/usr/local/bin/health"]

ENTRYPOINT ["dumb-init", "--", "/startup.sh"]
HEALTHCHECK CMD health
