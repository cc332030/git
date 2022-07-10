#!/bin/sh

echo 'mirror-github'

set -e

REPOSITORY="$(basename "$GITHUB_REPOSITORY")"
SOURCE="git@github.com:$GITHUB_REPOSITORY.git"

echo "SOURCE: $SOURCE"

git clone --mirror "$SOURCE" source && cd source || exit
git fetch -p origin

# Exclude refs created by GitHub for pull request.
git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin



# if DESTINATION not starts with git@
if test ${DESTINATION} = ${DESTINATION#git@}; then
  DESTINATION="git@$DESTINATION.com:$GITHUB_ACTOR/$REPOSITORY.git"
else
  DESTINATION=$DESTINATION
fi

echo "DESTINATION: $DESTINATION"

git remote set-url --push origin "$DESTINATION"
git push --mirror

echo 'mirror-github successfully'
