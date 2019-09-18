#!/bin/bash

source /etc/mlab/slice-functions
source $SLICEHOME/conf/config.sh

set -e
HOSTNAME=`hostname`

chkconfig rsyncd off
service rsyncd stop

ENABLE_DONAR=
if grep -q $HOSTNAME $SLICEHOME/conf/donar.txt ; then
    ENABLE_DONAR="yes"
fi
PACKAGES="nmap collectd-mlab"
# NOTE: update configuration specific to this node.
if ! test -f $SLICEHOME/.yumdone ; then
    if test x"$ENABLE_DONAR" = x"yes" ; then
        PACKAGES="${PACKAGES} pdns pdns-backend-pipe bind-utils"
    fi

    yum install -y $PACKAGES

    # NOTE: if there was an error installing, 'set -e' would stop us.
    # NOTE: so signal success.
    touch $SLICEHOME/.yumdone
fi

# NOTE: Create DONAR config if appropriate.
if test x"$ENABLE_DONAR" = x"yes" ; then
    # setup pdns
    cp /etc/pdns/pdns.conf /etc/pdns/pdns.conf.bak
    cp $SLICEHOME/conf/pdns.conf /etc/pdns/pdns.conf
    cp $SLICEHOME/conf/donar.txt /etc/donar.txt
    cp $SLICEHOME/resolve-by-mlabns.py /usr/sbin/
    chkconfig pdns on
    service pdns start
fi

yum update -y
