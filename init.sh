#!/bin/sh -e

echo "Checking apiology-puppet..."
git pull
git status --porcelain
if [ ! -d puppet-wget ]
then
  git clone https://github.com/maestrodev/puppet-wget
fi
#
# To add more modules to sync, add them to modules/.gitignore--this
# script will automatically figure out where to copy them in from.  To
# make changes, change them in the source directory and re-run this
# script.
#
MODULES=`cat modules/.gitignore | sed -e 's@/@@g' `
for module in $MODULES
do
    if [ -d puppet-$module ]
    then
        rsync -a --delete puppet-$module/ modules/$module
    fi
done
UNPUSHED_CHANGES=`git log origin/master..HEAD 2>&1 | wc -l`
if [ $UNPUSHED_CHANGES != 0 ]
then
  CLEAR=0
  echo "Unpushed commits in `pwd`"
fi
