#!/bin/bash

source /etc/mlab/slice-functions

# NOTE: kill the service if it is running.

if pgrep -f mecho &> /dev/null ; then
    echo "Stopping server:"
    pkill -KILL -f mecho
fi
