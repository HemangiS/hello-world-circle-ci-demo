#!/bin/bash

JSON_SRC=`git diff HEAD^ HEAD --name-only -- '*.json' --diff-filter=ACMRTXB`;

for f in ${JSON_SRC};
do
  jsonlint $f -q
  retval=$?
  if [[ $retval -eq 0 ]]
  then
    echo 'passed'
  else
    echo 'failed'
    exit 1;
  fi;
done;

exit 0;
