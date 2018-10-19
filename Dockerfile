FROM resin/rpi-raspbian:stretch

# Build environment variables
ENV MONITOR_VERSION=0.1.675 \
    CREATED="BLOODY2k"

RUN apt-get update && apt-get -y install apt-transport-https

# GET Mosquitto key for apt
ADD http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key /mosquitto-repo.gpg.key
RUN apt-key add /mosquitto-repo.gpg.key
ADD http://repo.mosquitto.org/debian/mosquitto-stretch.list /etc/apt/sources.list.d/mosquitto-stretch.list
RUN apt-cache search mosquitto
 
# Install Monitor dependencies
RUN apt-get update && \
    apt-get install -y \
       pi-bluetooth \
        build-essential \
        bluez \
        bluez-tools \
        libbluetooth-dev \
        libmosquitto-dev \
        mosquitto \
        mosquitto-clients \
        dbus \
        bc \
        bluez-hcidump \
        git \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD startup.sh /startup.sh

# Install Monitor
#WORKDIR /
#RUN git clone git://github.com/andrewjfreyer/monitor
RUN ["chmod", "+x", "/startup.sh"]
ENTRYPOINT ["/startup.sh"]
