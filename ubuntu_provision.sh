#!/bin/bash

set -e
echo Running ubuntu_provision.sh as $0
export PATH=/usr/local/bin/:$PATH
set +e
# would be needed for next step
sudo apt-get update -y
sudo apt-get dist-upgrade -y
if [ ! -f /usr/bin/curl ]
then
  sudo apt-get install -y curl
fi
if [ ! -f /usr/bin/gpg ]
then
  sudo apt-get install -y gpg
fi
set -e

if ! grep ubuntu /etc/passwd >/dev/null 2>&1
then
    /usr/sbin/useradd -m -r -c "Ubuntu" ubuntu
fi
mkdir -p src
cd src

if [ ! -f /etc/profile.d/rvm.sh ]
then
  echo "Installing rvm..."
  gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
  \curl -L https://get.rvm.io | sudo bash -s stable
  sudo usermod -a -G rvm ubuntu
fi

if ! grep '. /etc/profile.d/rvm.sh' ~/.bashrc
then
  (echo '. /etc/profile.d/rvm.sh'; cat ~/.bashrc) >> ~/.bashrc.tmp
  mv ~/.bashrc.tmp ~/.bashrc
fi

if ! sudo grep '. /etc/profile.d/rvm.sh' /root/.bashrc
then
  echo "Installing rvm for root"
  sudo sh -c "(echo '. /etc/profile.d/rvm.sh'; cat /root/.bashrc) >> /root/.bashrc.tmp"
  sudo mv /root/.bashrc.tmp /root/.bashrc
  echo "Installed rvm for root"
fi

# Jenkins, who hates me, wants to stick a whole bunch of stuff in
# /run, my ram disk.
sudo mount -o remount,rw,noexec,nosuid,size=20%,mode=0755 /run
