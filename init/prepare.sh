#!/bin/bash

set -x 
set -e

if [ -z "$SOURCE_DIR" ] ; then
    echo "Expected SOURCE_DIR in environment"
    exit 1
fi
if [ -z "$BUILD_DIR" ] ; then
    echo "Expected BUILD_DIR in environment"
    exit 1
fi

if test -d $BUILD_DIR ; then
    rm -rf $BUILD_DIR/*
fi

# install dependencies such as development tools
yum groupinstall -y 'Development tools'

mkdir $BUILD_DIR/conf
cat <<\EOF > $BUILD_DIR/conf/config.sh
RSYNCDIR_FATHOM=fathom
RSYNCDIR_UTILIZATION=utilization
RSYNCDIR_SWITCH=switch
EOF

# Set up pipeline
# GO_VERSION=go1.0.3.linux-386.tar.gz
# export GOROOT=$SOURCE_DIR/go
# export GOPATH=$SOURCE_DIR/m-lab.pipeline/standalone
# export PATH=$SOURCE_DIR/go/bin:$PATH

# pushd $SOURCE_DIR
#   [ -f $GO_VERSION ] || curl -O https://go.googlecode.com/files/$GO_VERSION
#   [ -d go ] || tar xzf $GO_VERSION
#   go get github.com/gorilla/mux
#   go build pipeline
# popd

# install -D -m 0755 $SOURCE_DIR/pipeline $BUILD_DIR/pipeline
install -D -m 0755 $SOURCE_DIR/init/initialize.sh $BUILD_DIR/init/initialize.sh
install -D -m 0755 $SOURCE_DIR/init/start.sh $BUILD_DIR/init/start.sh
install -D -m 0755 $SOURCE_DIR/init/stop.sh $BUILD_DIR/init/stop.sh
install -D -m 0644 $SOURCE_DIR/init/common.sh $BUILD_DIR/init/common.sh
install -D -m 0644 $SOURCE_DIR/conf/donar.txt $BUILD_DIR/conf
install -D -m 0644 $SOURCE_DIR/conf/pdns.conf $BUILD_DIR/conf
install -D -m 0755 $SOURCE_DIR/resolve-by-mlabns.py $BUILD_DIR/
