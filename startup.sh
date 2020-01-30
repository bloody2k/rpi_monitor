#!/bin/bash
# ==============================================================================
# Limych's Hass.io Add-ons: Bluetooth Presence Monitor
# Run Bluetooth Presence Monitor
# ==============================================================================

echo "Starting required services..."

cleanup() {
    echo "Finishing services..."

    service bluetooth stop
    service dbus stop

    exec echo
}

trap "cleanup" EXIT INT TERM

service dbus start
service bluetooth start

# echo "Updating Bluetooth Presence Monitor to latest version..."

# git fetch --depth=1
# git checkout origin/master -f
# git pull -f

echo "Starting Bluetooth Presence Monitor..."

# write out the timestamp of the last msg received
date +%s > last_msg
while true; do [[ -e main_pipe ]] && read line < main_pipe && date +%s > last_msg; done &

while monitor -D /config $MON_OPT >&2; do
    echo "Restarting Bluetooth Presence Monitor..."
done
exit $?
