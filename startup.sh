#!/bin/bash

FIRST_RUN_CHECK="NOT_FIRST_RUN"
if [ ! -e $FIRST_RUN_CHECK ]; then
    touch $FIRST_RUN_CHECK
    echo "-- First container startup --"
    # YOUR_JUST_ONCE_LOGIC_HERE
    cd /
    git clone git://github.com/andrewjfreyer/monitor
    chmod +x /monitor/monitor.sh
    bash /monitor/monitor.sh
else
    echo "-- Not first container startup --"
fi
