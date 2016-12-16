#!/bin/bash

source /etc/mlab/slice-functions
source $SLICEHOME/conf/config.sh

set -e
HOSTNAME=`hostname`

# Perform rsync configuration first.
# NOTE: This is overwriting a pre-existing rsyncd.conf from the slicebase.
# A list of Google Cloud netblocks. Generated from DNS-based SPF records.  To
# regenerate this list from DNS, you can run the command:
#   nslookup -q=TXT _cloud-netblocks.googleusercontent.com  8.8.8.8 \
#    | grep text \
#    | sed -e 's/.*=spf1 //' -e 's/?all.*//' -e 's/include://g' -e 's/ /\n/g'  \
#    | while read; do nslookup -q=TXT $REPLY 8.8.8.8; done \
#    | grep 'text = ' \
#    | sed -e 's/.*spf1 //' -e 's/ ?all.*//' -e 's/ /\n/g' \
#    | grep ^ip4 \
#    | sed -e 's/ip4://' \
#    | xargs \
#    | sed -e 's/ /, /g'
GOOGLE_NETBLOCKS="8.34.208.0/20, 8.35.192.0/21, 8.35.200.0/23, 108.59.80.0/20, 108.170.192.0/20, 108.170.208.0/21, 108.170.216.0/22, 108.170.220.0/23, 108.170.222.0/24, 162.216.148.0/22, 162.222.176.0/21, 173.255.112.0/20, 192.158.28.0/22, 199.192.112.0/22, 199.223.232.0/22, 199.223.236.0/23, 23.236.48.0/20, 23.251.128.0/19, 107.167.160.0/19, 107.178.192.0/18, 146.148.2.0/23, 146.148.4.0/22, 146.148.8.0/21, 146.148.16.0/20, 146.148.32.0/19, 146.148.64.0/18, 130.211.4.0/22, 130.211.8.0/21, 130.211.16.0/20, 130.211.32.0/19, 130.211.64.0/18, 130.211.128.0/17, 104.154.0.0/15, 104.196.0.0/14, 208.68.108.0/23, 35.184.0.0/14, 35.188.0.0/16"
sed -e "s;RSYNCDIR_FATHOM;/var/spool/$SLICENAME/$RSYNCDIR_FATHOM;" \
    -e "s;RSYNCDIR_UTILIZATION;/var/spool/$SLICENAME/$RSYNCDIR_UTILIZATION;" \
    -e "s;RSYNCDIR_SWITCH;/var/spool/$SLICENAME/$RSYNCDIR_SWITCH;" \
    -e "s;GOOGLE_NETBLOCKS;$GOOGLE_NETBLOCKS;" \
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
