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
        
RUN mkdir /monitor \
    cd /monitor \
    && touch .pids \
    && touch .previous_version \
    # make things executable
    # link the public name cache to the config directory ... i think there's a bug in monitor.sh where it doesn't consistently reference the same path to this...sometimes it looks in $base_directory (which we have as /config) and sometimes its in the app root (i.e. /monitor)
    ### && ln -s /config/.public_name_cache .public_name_cache \
    # no systemctl ... this keeps the error out about it
    && sed -i 's|systemctl is-active.*|SERVICE_ACTIVE=false|' support/init \
    # default config directory to come from an environment variable
    ###&& sed -i 's|PREF_CONFIG_DIR='"''"'|PREF_CONFIG_DIR="${PREF_CONFIG_DIR}"|' support/argv \
    # Setting up openrc to work in docker ... https://github.com/dockage/alpine/blob/master/3.9/openrc/Dockerfile
    # Start copy/paste from dockage
    # Disable getty's
    && sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
    && sed -i \
        # Change subsystem type to "docker"
        -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
        # Allow all variables through
        -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
        # Start crashed services
        -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
        -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
        # Define extra dependencies for services
        -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
        /etc/rc.conf \
    # Remove unnecessary services
    && rm -f /etc/init.d/hwdrivers \
            /etc/init.d/hwclock \
            /etc/init.d/hwdrivers \
            /etc/init.d/modules \
            /etc/init.d/modules-load \
            /etc/init.d/modloop \
    # Can't do cgroups
    && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
    && sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh \
    # END copy/paste from dockage
    # don't set hostname since docker sets it
    && sed -i 's/hostname $opts/# hostname $opts/g' /etc/init.d/hostname \
    # don't mount tmpfs since not privileged
    && sed -i 's/mount -t tmpfs/# mount -t tmpfs/g' /lib/rc/sh/init.sh \
    # Start up openrc
    && mkdir /run/openrc \
    && touch /run/openrc/softlevel \
    && openrc
        
COPY startup.sh /startup.sh
RUN ["chmod", "+x", "/startup.sh"]

COPY health.sh /usr/local/bin/health
RUN ["chmod", "+x", "/usr/local/bin/health"]

ENTRYPOINT ["dumb-init", "--", "/startup.sh"]
HEALTHCHECK CMD health
