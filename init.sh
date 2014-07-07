#!/bin/sh

echo "Checking apiology-puppet..."
git pull
git status --porcelain
UNPUSHED_CHANGES=`git log origin/master..HEAD 2>&1 | wc -l`
if [ $UNPUSHED_CHANGES != 0 ]
then
  CLEAR=0
  echo "Unpushed commits in `pwd`"
fi
