#!/bin/bash

source /etc/mlab/slice-functions
source $SLICEHOME/conf/config.sh

# NOTE: update configuration specific to this node.
[ -f $SLICEHOME/.yumdone ] || \
  (
    rm -f $SLICEHOME/.yumdone
    yum install -y nmap
    touch $SLICEHOME/.yumdone
  )
yum update -y

# rsync
sed -e "s;RSYNCDIR_FATHOM;/var/spool/$SLICENAME/$RSYNCDIR_FATHOM;" \
  $SLICEHOME/conf/rsyncd.conf.in > /etc/rsyncd.conf
mkdir -p /var/spool/$SLICENAME/$RSYNCDIR_FATHOM
chown -R $SLICENAME:slices /var/spool/$SLICENAME/$RSYNCDIR_FATHOM
service rsyncd restart
