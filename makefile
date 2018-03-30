# SHELL := /bin/bash

.PHONY: lint
JSON_SRC= $(shell git diff HEAD^ HEAD --name-only -- '*.json')

jsonlint:
	[[ -z "${JSON_SRC}" ]] && echo "No json files committed" || jsonlint ${JSON_SRC}

all: jsonlint

