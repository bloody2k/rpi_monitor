#!/bin/bash

FIRST_RUN_CHECK="NOT_FIRST_RUN"
if [ ! -e $FIRST_RUN_CHECK ]; then
    touch $FIRST_RUN_CHECK
    echo "-- First start - Installing Monitor --"
    # YOUR_JUST_ONCE_LOGIC_HERE
    cd /
    git clone git://github.com/andrewjfreyer/monitor
    chmod +x /monitor/monitor.sh
    echo "-- Starting Monitor --"
    ( echo n ) | bash /monitor/monitor.sh
else
    echo "-- Starting Monitor --"
    ( echo n ) | bash /monitor/monitor.sh
fi
