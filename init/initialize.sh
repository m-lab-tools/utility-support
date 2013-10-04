#!/bin/bash

source /etc/mlab/slice-functions
source $SLICEHOME/conf/config.sh

set -e

# NOTE: update configuration specific to this node.
if ! test -f $SLICEHOME/.yumdone ; then 
    yum install -y nmap pdns pdns-backend-pipe bind-utils
    # NOTE: if there was an error installing, 'set -e' would stop us.
    # NOTE: so signal success.
    touch $SLICEHOME/.yumdone
fi
yum update -y

# setup pdns 
cp /etc/pdns/pdns.conf /etc/pdns/pdns.conf.bak
cp $SLICEHOME/conf/pdns.conf /etc/pdns/pdns.conf
cp $SLICEHOME/resolve-by-mlabns.py /usr/sbin/
chkconfig pdns on
service pdns start

# rsync
sed -e "s;RSYNCDIR_FATHOM;/var/spool/$SLICENAME/$RSYNCDIR_FATHOM;" \
  $SLICEHOME/conf/rsyncd.conf.in > /etc/rsyncd.conf
mkdir -p /var/spool/$SLICENAME/$RSYNCDIR_FATHOM
chown -R $SLICENAME:slices /var/spool/$SLICENAME/$RSYNCDIR_FATHOM
service rsyncd restart
