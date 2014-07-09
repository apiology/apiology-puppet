#!/bin/sh

if [ n$1 = n ]
then
  echo "Provide an argument already!"
  exit 1
fi

mkdir -p $1/manifests
cat > $1/manifests/init.pp <<EOF
class $1 {
  package {
    "$1":
      ensure => installed;
  }
}
EOF
