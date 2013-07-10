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

# build tool
pushd $SOURCE_DIR/echo
    cmake .
    make
popd 

mkdir -p $BUILD_DIR/bin/
cp $SOURCE_DIR/echo/bin/mecho $BUILD_DIR/bin/

# NOTE: copy any files needed by the installed package
cp -r $SOURCE_DIR/init           $BUILD_DIR/
