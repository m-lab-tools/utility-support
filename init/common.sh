#!/bin/bash

# TODO: wait on these other ports until we find a better solution than ncat.
#UDP_PORT_LIST="27015 27005 9899 7082 7078 5060 5005 5004 4500 1701 1434 1194 500 138 137 123"
#TCP_PORT_LIST="9001 6881 5060 1947 1723 1194 995 993 587 585 465 445 443 161 143 139 135 110 80 25 22 21"

# NOTE: minimal viable list for fathom
UDP_PORT_LIST=
TCP_PORT_LIST=

# TODO: find a more suitable binary than 'ncat' and 'cat'
NCAT_OPTIONS="--verbose --max-conns 10 --keep-open --exec /bin/cat"
LOGFILE=/var/log/echo

function rotate_log () {
    local filename=$1
    test -f ${filename}.1 && mv ${filename}.1 ${filename}.2 || :
    test -f ${filename}   && mv ${filename}   ${filename}.1 || :
}

function ncat_command () {
    local port=$1
    local extra_args=$2
    local ipv6_support=''

    ping6 -c1 ks.measurementlab.net &> /dev/null && NCAT_OPTIONS="-6 $NCAT_OPTIONS"
    CMD="ncat -l $port $NCAT_OPTIONS"
    if test -n "$extra_args" ; then
        CMD="ncat $extra_args -l $port $NCAT_OPTIONS"
    fi
    echo $CMD
}

function start_ncat () {
    local port=$1
    local extra_args=$2
    LOG=$LOGFILE.tcp.$port.log

    CMD=$( ncat_command $port $extra_args )
    if ! pgrep -f "$CMD" &> /dev/null ; then
        rotate_log ${LOG}
        $CMD &> ${LOG} &
    else
        echo NOT starting: $CMD
    fi   
}

function stop_ncat () {
    local port=$1
    local extra_args=$2
    LOG=$LOGFILE.udp.$port.log

    CMD=$( ncat_command $port $extra_args )
    if pgrep -f "$CMD" &> /dev/null ; then
        pkill -KILL -f "$CMD"
    else
        echo NOT killing: $CMD
    fi
}
