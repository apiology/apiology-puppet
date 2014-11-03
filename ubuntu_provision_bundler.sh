#!/bin/sh -e

. /etc/profile.d/rvm.sh

#  $RVM install --default $PREFERRED_VERSION
rvm user gemsets
rvm @ubuntu
ruby -v
type bundle 2>/dev/null || gem install bundler
