#!/bin/bash

RUBY_VERSION=2.1.5

echo Running update_ruby.sh as $0

gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
echo gpg key installed
if [[ -s "$HOME/.rvm/scripts/rvm" ]]
then
  . "$HOME/.rvm/scripts/rvm"
  RVM="rvm"
elif [ -f /etc/profile.d/rvm.sh ]
then
  . /etc/profile.d/rvm.sh
  RVM="rvmsudo rvm"
else
  exit 1
fi

$RVM reload
$RVM requirements run
$RVM get staple
$RVM cleanup all

interrogate_ubuntu() {
  OS_VERSION=`lsb_release -r -s`
  OS_NAME=ubuntu
}

interrogate_osx() {
  OS_VERSION=`sw_vers -productVersion | cut -d\. -f1-2`
  OS_NAME=osx
}

interrogate_cygwin() {
  OS_VERSION=unknown
  OS_NAME=cygwin
}

interrogate_os() {
  echo "Checking OS"
  if [ -x /usr/bin/lsb_release ]
  then
    interrogate_ubuntu
  elif [ `uname` = Darwin ]
  then
    interrogate_osx
  elif [ `uname` = CYGWIN_NT-6.1 ]
  then
    interrogate_cygwin
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

HAS_RUBY=`$RVM list | grep ruby-$RUBY_VERSION | wc -l`
if [ $HAS_RUBY == 0 ]
then
  # If this doesn't work, see 'Ruby' simplenote on how to upload binary.
  interrogate_arch
  interrogate_os
  RVM_FILE=ruby-${RUBY_VERSION}.tar.bz2
  BINARY=binaries/${OS_NAME}/${OS_VERSION}/${ARCH}/${RVM_FILE}
  if ! $RVM mount --verify-downloads 2 -r http://rvm-binaries-apiology.s3.amazonaws.com/$BINARY
  then
    echo      
    echo
    echo "===================================================================================================="
    echo "Vince needs to install a new binary ruby into http://rvm-binaries-apiology.s3.amazonaws.com/"
    echo "Please put the following into an issue report at https://github.com/apiology/apiology-puppet/issues:"
    echo
    echo "Need binary ruby installed as $BINARY"
    exit 1
    # or just uncomment the next line and get rid of the 'exit 1'
    # rvm install $RUBY_VERSION
  fi
fi

$RVM alias delete default
$RVM alias create default ruby-${RUBY_VERSION}
$RVM use default
$RVM uninstall ruby-2.1.2
$RVM uninstall ruby-2.1.3
$RVM uninstall ruby-2.1.4
rvm user gemsets
rvm use $RUBY_VERSION@ubuntu --default
rvm reload
