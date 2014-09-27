#!/bin/bash -e

echo Running ubuntu_provision_rvm.sh as $0
. /etc/profile.d/rvm.sh
rvm requirements run

RUBY_VERSION=2.1.3

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

HAS_RUBY=`rvmsudo rvm list | grep ruby-$RUBY_VERSION | wc -l`
if [ $HAS_RUBY == 0 ]
then
  # If this doesn't work, see 'Ruby' simplenote on how to upload binary.
  interrogate_arch
  interrogate_ubuntu
  RVM_FILE=ruby-${RUBY_VERSION}.tar.bz2
  BINARY=binaries/${OS_NAME}/${OS_VERSION}/${ARCH}/${RVM_FILE}
  if ! rvmsudo rvm mount -r http://rvm-binaries-apiology.s3.amazonaws.com/$BINARY
  then
    echo "Need to install a new binary ruby into http://rvm-binaries-apiology.s3.amazonaws.com/"
    echo "Please put the following into an issue report at https://github.com/apiology/apiology-puppet/issues:"
    echo
    echo "Need binary ruby installed as $BINARY"
    exit 1
    # or just uncomment the next line and get rid of the 'exit 1'
    # rvm install $RUBY_VERSION
  fi
  rvm alias create default ruby-${RUBY_VERSION}
  rvm use default
#  rvmsudo rvm install --default $PREFERRED_VERSION
fi
ruby -v
type bundle 2>/dev/null || gem install bundler
