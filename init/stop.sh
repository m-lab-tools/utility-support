#!/bin/bash

source /etc/mlab/slice-functions
set -e

# NOTE: kill the service if it is running.
source $SLICEHOME/init/common.sh
echo "Stopping servers:"
for port in $UDP_PORT_LIST ; do
    stop_ncat_udp4 $port
    stop_ncat_udp6 $port
done
for port in $TCP_PORT_LIST ; do
    stop_ncat_tcp4 $port
    stop_ncat_tcp6 $port
done

echo "Stopping pipeline:"
killall pipeline
