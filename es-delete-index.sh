#!/bin/bash

if [[ $# != 1 ]] ; then
  echo "Usage: ${0} <index name>"
  exit
fi

INDEX_NAME="${1}"

curl -X DELETE "localhost:9200/${INDEX_NAME}"