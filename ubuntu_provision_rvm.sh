#!/bin/bash

echo Running ubuntu_provision_rvm.sh as $0
. /etc/profile.d/rvm.sh
rvm requirements run

RUBY_VERSION=2.1.2

HAS_RUBY=`rvmsudo rvm list | grep ruby-$RUBY_VERSION | wc -l`
if [ $HAS_RUBY == 0 ]
then
  # If this doesn't work, see 'Ruby' simplenote on how to upload binary.
  UBUNTU_VERSION=`lsb_release -r -s`
  ARCH=`uname -p`
  if [ $ARCH = i686 ]
  then
    ARCH=i386
  fi
  rvmsudo rvm mount -r http://rvm-binaries-apiology.s3.amazonaws.com/binaries/ubuntu/${UBUNTU_VERSION}/${ARCH}/ruby-${RUBY_VERSION}.tar.bz2
  rvm alias create default ruby-${RUBY_VERSION}
  rvm use default
#  rvmsudo rvm install --default $PREFERRED_VERSION
fi
ruby -v
