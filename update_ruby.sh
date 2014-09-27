#!/bin/bash -e

RUBY_VERSION=2.1.3

echo Running ubuntu_provision_rvm.sh as $0

rvm requirements run
rvm get staple
rvm reload
rvm cleanup all


if [[ -s "$HOME/.rvm/scripts/rvm" ]]
then
  . "$HOME/.rvm/scripts/rvm"
elif [ -f /etc/profile.d/rvm.sh ]
then
  . /etc/profile.d/rvm.sh
fi

interrogate_ubuntu() {
  OS_VERSION=`lsb_release -r -s`
  OS_NAME=ubuntu
}

interrogate_osx() {
  OS_VERSION=`sw_vers -productVersion | cut -d\. -f1-2`
  OS_NAME=osx
}

interrogate_os() {
  echo "Checking OS"
  if [ -x /usr/bin/lsb_release ]
  then
    interrogate_ubuntu
  elif [ `uname` = Darwin ]
  then
    interrogate_osx
  else
    echo "Could not figure out type of OS!"
    exit 1
  fi
}

interrogate_arch() {
  ARCH=`uname -m` # uname -p on osx returns i386 even on x86_64 machines
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
  interrogate_os
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
fi

rvm alias delete default
rvm alias create default ruby-${RUBY_VERSION}
rvm use default
rvm uninstall ruby-2.1.2
#  rvmsudo rvm install --default $PREFERRED_VERSION
ruby -v
type bundle 2>/dev/null || gem install bundler
