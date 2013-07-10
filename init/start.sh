#!/bin/bash

source /etc/mlab/slice-functions

export PATH=$PATH:$SLICEHOME/bin:$SLICEHOME/sbin
export LD_LIBRARY_PATH=$SLICEHOME/lib:$LD_LIBRARY_PATH

# NOTE: start the service if it is not already running.

if ! pgrep -f mecho &> /dev/null ; then
    echo "Starting server:"
    $SLICEHOME/bin/mecho 1313 1313 > /dev/null 2>&1 &
fi   
