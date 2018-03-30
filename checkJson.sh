#!/bin/bash

make all;
retval=$?
echo $retval;
if [[ $retval -eq 0 ]]
then
  echo "---success---";
else
  echo "---failure---";
  exit 1;
fi;
exit 0;
