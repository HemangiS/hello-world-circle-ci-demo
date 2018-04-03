#!/bin/bash

JSON_SRC=`git diff HEAD^ HEAD --name-only --diff-filter=ACMRTXBU '*.json'`;
# JSON_SRC=`find . -name "*.json"`;
# JSON_SRC='package.json';
# JSON_SRC='./data/new.json';
# JSON_SRC='./data/info.json ./data/new.json ./package.json';
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo $JSON_SRC;

TESTSTRING="";

apply_json_linter() {
  jsonlint $1 -q
  retval=$?
  if [[ $retval -eq 0 ]]
  then
    echo -e "${GREEN}PASSED through jsonlint check${NC}"
  else
    echo -e "${RED}FAILED through jsonlint check${NC}"
    exit 1;
  fi;
}

truncate_quotes() {
  echo $1 | cut -d "\"" -f 2;
}

find_type_of_data() {
  echo $1 | jq type;
}

find_length_of_data() {
  echo $1 | jq length;
}

parse_array_type_json() {
  # echo "<<<<<----this is array type JSON---->>>>>"

  while [[ $MYFIRSTVAR -lt $2 ]]; do
    KEYLENGTH=`echo $1 | jq ".[$MYFIRSTVAR]|keys|length"`
    MYSECONDVAR=0
    while [[ $MYSECONDVAR -lt $KEYLENGTH ]]; do
      # echo "\"abcdefg\"" | cut -d "\"" -f 2
      KEYNAME=`echo $1 | jq ".[$MYFIRSTVAR]|keys|.[$MYSECONDVAR]"`
      # echo ${KEYNAME}
      # echo ${#KEYNAME}
      TRUNCATEDKEYNAME=`truncate_quotes ${KEYNAME}`
      # echo ${TRUNCATEDKEYNAME}
      # echo ${#TRUNCATEDKEYNAME}

      if [[ "$TRUNCATEDKEYNAME" == "$TESTSTRING" ]]; then
        echo -e "${RED}FAILED${NC}"
        echo "Some Key name is empty"
        exit 1;
      else
        KEYVALUE=`echo $1 | jq ".[$MYFIRSTVAR].$KEYNAME"`
        # echo ${KEYVALUE}
        # echo ${#KEYVALUE}
        TRUNCATEDKEYVALUE=`truncate_quotes ${KEYVALUE}`
        KEYVALUETYPE=`find_type_of_data "${KEYVALUE}"`
        TRUNCATEDKEYVALUETYPE=`truncate_quotes ${KEYVALUETYPE}`
        # echo ${TRUNCATEDKEYVALUE}
        # echo ${#TRUNCATEDKEYVALUE}
        OBJLENGTH=`find_length_of_data "${KEYVALUE}"`
        if [[ "$TRUNCATEDKEYVALUETYPE" == "object" ]]; then
          parse_object_type_json "${KEYVALUE}" "${OBJLENGTH}"
        elif [[ "$TRUNCATEDKEYVALUETYPE" == "array" ]]; then
          parse_array_type_json "${KEYVALUE}" "${OBJLENGTH}"
        elif [[ "$TRUNCATEDKEYVALUE" == "$TESTSTRING" ]]; then
          echo -e "${RED}FAILED${NC}"
          echo "Some Key value is empty"
          exit 1;
        fi
      fi
      MYSECONDVAR=$(expr $MYSECONDVAR + 1)
    done
    MYFIRSTVAR=$(expr $MYFIRSTVAR + 1)
  done
}

parse_object_type_json() {
  # echo "<<<<<----this is object type JSON---->>>>>"

  while [[ $MYFIRSTVAR -lt $2 ]]; do # $2 is object length
    # echo "\"abcdefg\"" | cut -d "\"" -f 2
    KEYNAME=`echo $1 | jq "keys[$MYFIRSTVAR]"`
    # echo ${KEYNAME}
    # echo ${#KEYNAME}
    TRUNCATEDKEYNAME=`truncate_quotes ${KEYNAME}`
    # echo ${TRUNCATEDKEYNAME}
    # echo ${#TRUNCATEDKEYNAME}

    if [[ "$TRUNCATEDKEYNAME" == "$TESTSTRING" ]]; then
      echo -e "${RED}FAILED${NC}"
      echo "Some Key name is empty"
      exit 1;
    else
      KEYVALUE=`echo $1 | jq ".$KEYNAME"`
      # echo ${KEYVALUE};
      KEYVALUETYPE=`echo ${KEYVALUE} | jq type`
      TRUNCATEDKEYVALUETYPE=`truncate_quotes ${KEYVALUETYPE}`
      # echo ${TRUNCATEDKEYVALUETYPE}
      TRUNCATEDKEYVALUE=`truncate_quotes ${KEYVALUE}`
      # echo ${TRUNCATEDKEYVALUE}
      # echo ${#TRUNCATEDKEYVALUE}
      OBJLENGTH=`find_length_of_data "${KEYVALUE}"`
      if [[ "$TRUNCATEDKEYVALUETYPE" == "object" ]]; then
        parse_object_type_json "${KEYVALUE}" "${OBJLENGTH}"
        # exit 1;
      elif [[ "$TRUNCATEDKEYVALUETYPE" == "array" ]]; then
        parse_array_type_json "${KEYVALUE}" "${OBJLENGTH}"
      elif [[ "$TRUNCATEDKEYVALUE" == "$TESTSTRING" ]]; then
        echo -e "${RED}FAILED${NC}"
        echo "Some Key value is empty"
        exit 1;
      fi
    fi
    MYFIRSTVAR=$(expr $MYFIRSTVAR + 1)
  done
}

COUNTER=1

for JSONFILE in $JSON_SRC; do
  MYJSONFILE=`cat ${JSONFILE}`;
  echo "Loop number ${COUNTER} for file named ((( ${JSONFILE} ))) ====>>>"
  apply_json_linter "${JSONFILE}"
  MYFILEDATATYPE=`find_type_of_data "${MYJSONFILE}"`;
  echo ${MYFILEDATATYPE}
  MYFILELENGTH=`find_length_of_data "${MYJSONFILE}"`;
  echo ${MYFILELENGTH}

  MYFIRSTVAR=0
  if [[ `truncate_quotes ${MYFILEDATATYPE}` == "array" ]]; then
    parse_array_type_json "${MYJSONFILE}" "${MYFILELENGTH}"
  else
    parse_object_type_json "${MYJSONFILE}" "${MYFILELENGTH}"
  fi
  echo -e "${GREEN}PASSED schema test${NC}"
  COUNTER=$(expr $COUNTER + 1)
done

exit 0;
