#!/bin/bash

set -e
source /etc/mlab/slice-functions

# NOTE: kill the service if it is running.

CMD="ncat -l 3000 --keep-open --exec /bin/cat"
if pgrep -f "$CMD" &> /dev/null ; then
    echo "Stopping server:"
    pkill -KILL -f ncat
fi
