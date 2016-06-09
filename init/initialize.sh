#!/bin/bash

source /etc/mlab/slice-functions
source $SLICEHOME/conf/config.sh

set -e
HOSTNAME=`hostname`

# Perform rsync configuration first.
# NOTE: This is overwriting a pre-existing rsyncd.conf from the slicebase.
sed -e "s;RSYNCDIR_FATHOM;/var/spool/$SLICENAME/$RSYNCDIR_FATHOM;" \
    -e "s;RSYNCDIR_UTILIZATION;/var/spool/$SLICENAME/$RSYNCDIR_UTILIZATION;" \
    -e "s;RSYNCDIR_SWITCH;/var/spool/$SLICENAME/$RSYNCDIR_SWITCH;" \
    $SLICEHOME/conf/rsyncd.conf.in > /etc/rsyncd.conf

mkdir -p /var/spool/$SLICENAME/$RSYNCDIR_FATHOM
mkdir -p /var/spool/$SLICENAME/$RSYNCDIR_UTILIZATION
mkdir -p /var/spool/$SLICENAME/$RSYNCDIR_SWITCH

chown -R $SLICENAME:slices /var/spool/$SLICENAME/$RSYNCDIR_FATHOM
chown -R $SLICENAME:slices /var/spool/$SLICENAME/$RSYNCDIR_UTILIZATION
chown -R $SLICENAME:slices /var/spool/$SLICENAME/$RSYNCDIR_SWITCH

service rsyncd restart

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
