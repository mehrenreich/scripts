#!/bin/bash

if [[ $# != 2 ]] ; then
  echo "Usage: ${0} <index name> <new index name>"
  exit
fi

INDEX_NAME="${1}"
NEW_INDEX_NAME="${2}"

curl -X POST "localhost:9200/_reindex" -H 'Content-Type: application/json' -d"
{
  \"source\": {
    \"index\": \"${INDEX_NAME}\"
  },
  \"dest\": {
    \"index\": \"${NEW_INDEX_NAME}\"
  }
}
"

