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

# inspired from https://github.com/moby/moby/issues/16208#issuecomment-161770118
service dbus start
service bluetooth start
hciconfig hci0 up

#write out the timestamp of the last msg received
date +%s > last_msg
while true; do [[ -e main_pipe ]] && read line < main_pipe && date +%s > last_msg; done &

echo "-- Starting Monitor --"
cd /monitor
( echo n ) | ./monitor.sh $MON_OPT -D /config
