#!/bin/sh

echo 'mirror'

set -e

SOURCE=$1
DESTINATIONS=$2

echo "
SOURCE=${SOURCE}
DESTINATIONS=${DESTINATIONS}
"

git clone --mirror "$SOURCE" source && cd source || exit

for DESTINATION in $(echo "${DESTINATIONS}" | sed "s/,/\n/g"); do

  echo "mirror to ${DESTINATION}"

  git remote set-url --push origin "$DESTINATION"

  # Exclude refs created by GitHub for pull request.
  git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin
  git push --mirror

done

echo 'mirror successfully'
