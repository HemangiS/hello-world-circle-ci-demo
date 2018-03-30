#!/bin/bash

JSON_SRC=`git diff HEAD^ HEAD --name-only -- '*.json'`;

for f in ${JSON_SRC};
do
  jsonlint $f
done;

exit 0;
