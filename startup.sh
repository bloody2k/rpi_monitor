#!/bin/bash

FIRST_RUN_CHECK="NOT_FIRST_RUN"
if [ ! -e $FIRST_RUN_CHECK ]; then
    touch $FIRST_RUN_CHECK    
    echo "-- First start - Installing Monitor --"
    # YOUR_JUST_ONCE_LOGIC_HERE
    cd /monitor
    git clone git://github.com/andrewjfreyer/monitor
    chmod +x /monitor/monitor.sh
fi

cleanup() {
    if [[ $pid -gt 0 ]]; then
        kill $pid
    fi
    service bluetooth stop
    service dbus stop
    exec echo
}

trap "cleanup" EXIT INT TERM

service dbus start
service bluetooth start

#write out the timestamp of the last msg received
date +%s > last_msg
while true; do [[ -e main_pipe ]] && read line < main_pipe && date +%s > last_msg; done &

echo "-- Starting Monitor --"
cd /monitor
( echo n ) | ./monitor.sh $MON_OPT -D /config
