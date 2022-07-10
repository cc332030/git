#!/bin/sh

echo 'mirror'

set -e

SOURCE=$1
DESTINATION=$2

echo "SOURCE=$SOURCE"
echo "DESTINATION=$DESTINATION"

git clone --mirror "$SOURCE" source && cd source || exit
git remote set-url --push origin "$DESTINATION"

git fetch -p origin

# Exclude refs created by GitHub for pull request.
git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin
git push --mirror

echo 'mirror successfully'
