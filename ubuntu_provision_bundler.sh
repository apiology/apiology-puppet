#!/bin/sh -e

#  $RVM install --default $PREFERRED_VERSION
ruby -v
type bundle 2>/dev/null || gem install bundler
