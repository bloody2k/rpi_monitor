#!/bin/bash

FIRST_RUN_CHECK="NOT_FIRST_RUN"
if [ ! -e $FIRST_RUN_CHECK ]; then
    touch $FIRST_RUN_CHECK    
    echo "-- First start - Installing Monitor --"
    # YOUR_JUST_ONCE_LOGIC_HERE
    git clone git://github.com/andrewjfreyer/monitor /monitor
    chmod +x /monitor/monitor.sh
fi

#set -e

# inspired from https://github.com/moby/moby/issues/16208#issuecomment-161770118
service dbus start
service bluetooth start
hciconfig hci0 up

echo "-- Starting Monitor --"
cd monitor
( echo n ) | ./monitor.sh $MON_OPT -D /config
