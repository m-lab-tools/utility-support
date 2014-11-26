#!/bin/bash

source /etc/mlab/slice-functions
set -e

export PATH=$PATH:$SLICEHOME/bin:$SLICEHOME/sbin
export LD_LIBRARY_PATH=$SLICEHOME/lib:$LD_LIBRARY_PATH

# NOTE: start the service if it is not already running.
source $SLICEHOME/init/common.sh
echo "Starting servers:"
for port in $UDP_PORT_LIST ; do
    start_ncat $port --udp
done
for port in $TCP_PORT_LIST ; do
    start_ncat $port 
done

# DISABLED until we have the resources to restart development on the prototype
# of the "push" data collection pipeline apparatus (which is what this is)
#echo "Starting pipeline:"
#$SLICEHOME/pipeline -port=4242 -output_dir=/var/spool/$SLICENAME &
