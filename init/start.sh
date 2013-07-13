#!/bin/bash

source /etc/mlab/slice-functions
set -e

export PATH=$PATH:$SLICEHOME/bin:$SLICEHOME/sbin
export LD_LIBRARY_PATH=$SLICEHOME/lib:$LD_LIBRARY_PATH

# NOTE: start the service if it is not already running.
source config.sh
echo "Starting servers:"
for port in $UDP_PORT_LIST ; do
    start_ncat $port --udp
done
for port in $TCP_PORT_LIST ; do
    start_ncat $port 
done
