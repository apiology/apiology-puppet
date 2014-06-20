#!/bin/bash

echo Running ubuntu_provision_puppet.sh as $0
if ! type puppet >/dev/null 2>&1
then
  gem install puppet
fi
