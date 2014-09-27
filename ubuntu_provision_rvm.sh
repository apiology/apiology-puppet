#!/bin/bash

echo Running ubuntu_provision_rvm.sh as $0
. /etc/profile.d/rvm.sh
rvm requirements run

interrogate_ubuntu() {
  OS_VERSION=`lsb_release -r -s`
  OS_NAME=ubuntu
}

interrogate_arch() {
  ARCH=`uname -p`
  if [ $ARCH = i686 ]
  then
    ARCH=i386
  fi
}

RUBY_VERSION=2.1.2

HAS_RUBY=`rvmsudo rvm list | grep ruby-$RUBY_VERSION | wc -l`
if [ $HAS_RUBY == 0 ]
then
  # If this doesn't work, see 'Ruby' simplenote on how to upload binary.
  interrogate_arch
  interrogate_ubuntu
  rvmsudo rvm mount -r http://rvm-binaries-apiology.s3.amazonaws.com/binaries/${OS_NAME}/${OS_VERSION}/${ARCH}/ruby-${RUBY_VERSION}.tar.bz2
  rvm alias create default ruby-${RUBY_VERSION}
  rvm use default
#  rvmsudo rvm install --default $PREFERRED_VERSION
fi
ruby -v
type bundle 2>/dev/null || gem install bundler
