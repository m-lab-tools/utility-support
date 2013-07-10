#!/bin/bash

set -e
source /etc/mlab/slice-functions

export PATH=$PATH:$SLICEHOME/bin:$SLICEHOME/sbin
export LD_LIBRARY_PATH=$SLICEHOME/lib:$LD_LIBRARY_PATH

# NOTE: start the service if it is not already running.

CMD="ncat -l 3000 --keep-open --exec /bin/cat"
TCPLOG=/var/log/tcpecho.log
UDPLOG=/var/log/udpecho.log

# Rotate logs
[[ -f ${TCPLOG}.1 ]] && mv ${TCPLOG}.1 ${TCPLOG}.2
[[ -f ${TCPLOG} ]] && mv ${TCPLOG} ${TCPLOG}.1

[[ -f ${UDPLOG}.1 ]] && mv ${UDPLOG}.1 ${UDPLOG}.2
[[ -f ${UDPLOG} ]] && mv ${UDPLOG} ${UDPLOG}.1

if ! pgrep -f "$CMD" &> /dev/null ; then
    echo "Starting servers:"
    $CMD &> ${TCPLOG} &
    $CMD --udp &> ${UDPLOG} &
fi   
