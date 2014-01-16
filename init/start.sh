#!/bin/bash

source /etc/mlab/slice-functions
set -e

export PATH=$PATH:$SLICEHOME/bin:$SLICEHOME/sbin
export LD_LIBRARY_PATH=$SLICEHOME/lib:$LD_LIBRARY_PATH

# NOTE: start the service if it is not already running.
source $SLICEHOME/init/common.sh
echo "Starting servers:"
for port in $UDP_PORT_LIST ; do
    start_ncat_udp4 $port
    start_ncat_udp6 $port
done
for port in $TCP_PORT_LIST ; do
    start_ncat_tcp4 $port
    start_ncat_tcp6 $port
done

echo "Starting pipeline:"
$SLICEHOME/pipeline -port=4242 -output_dir=/var/spool/$SLICENAME &
