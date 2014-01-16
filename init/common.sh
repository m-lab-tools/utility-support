#!/bin/bash

# TODO: wait on these other ports until we find a better solution than ncat.
#UDP_PORT_LIST="27015 27005 9899 7082 7078 5060 5005 5004 4500 1701 1434 1194 500 138 137 123"
#TCP_PORT_LIST="9001 6881 5060 1947 1723 1194 995 993 587 585 465 445 443 161 143 139 135 110 80 25 22 21"

# NOTE: minimal viable list for fathom
UDP_PORT_LIST=
TCP_PORT_LIST="143 80"

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
    shift
    local extra_args=$*

    CMD="ncat -l $port $NCAT_OPTIONS"
    if test -n "$extra_args" ; then
        CMD="ncat $extra_args -l $port $NCAT_OPTIONS"
    fi
    echo $CMD
}

function start_cmd() {
    if ! pgrep -f "$CMD" &> /dev/null ; then
        rotate_log ${LOG}
        echo starting: $CMD
        $CMD &> ${LOG} &
    else
        echo NOT starting: $CMD
    fi
}

function stop_cmd() {
    if pgrep -f "$CMD" &> /dev/null ; then
        echo stopping: $CMD
        pkill -KILL -f "$CMD"
    else
        echo NOT killing: $CMD
    fi
}

function start_ncat_tcp4() {
  local port=$1
  LOG=$LOGFILE.tcp.v4.$port.log
  CMD=$( ncat_command $port -4 )
  start_cmd
}

function start_ncat_tcp6() {
  local port=$1
  LOG=$LOGFILE.tcp.v6.$port.log
  CMD=$( ncat_command $port -6 )
  start_cmd
}

function start_ncat_udp4() {
  local port=$1
  LOG=$LOGFILE.udp.v4.$port.log
  CMD=$( ncat_command $port -u -4 )
  start_cmd
}

function start_ncat_udp6() {
  local port=$1
  LOG=$LOGFILE.udp.v6.$port.log
  CMD=$( ncat_command $port -u -6 )
  start_cmd
}
