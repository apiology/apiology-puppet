#!/bin/bash

echo Running ubuntu_provision_puppet.sh as $0
sudo apt-get install -y libaugeas0 libaugeas-dev
if ! type puppet >/dev/null 2>&1
then
  rvmsudo gem install puppet ruby-augeas
fi
