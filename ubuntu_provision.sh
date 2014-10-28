#!/bin/bash

set -e
echo Running ubuntu_provision.sh as $0
export PATH=/usr/local/bin/:$PATH
set +e
# would be needed for next step
if [ ! -f /var/cache/apt/pkgcache.bin ] || \
     /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | \
     /bin/grep . > /dev/null
then
  sudo apt-get update -y
fi
sudo apt-get upgrade -y
if [ ! -f /usr/bin/curl ]
then
  sudo apt-get install -y curl
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
