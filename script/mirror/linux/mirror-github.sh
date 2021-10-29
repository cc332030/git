#!/bin/sh

set -e

DESTINATION=$1

if [ ! "$DESTINATION" ]; then
  DESTINATION=gitee
  echo
  echo "default DESTINATION: $DESTINATION"
fi

REPOSITORY="$(basename "$GITHUB_REPOSITORY")"

SOURCE_REPO="git@github.com:$GITHUB_REPOSITORY.git"

# if DESTINATION not starts with git@
if test ${DESTINATION} = ${DESTINATION#git@}; then
  DESTINATION_REPO="git@$DESTINATION.com:$GITHUB_ACTOR/$REPOSITORY.git"
else
  DESTINATION_REPO=$DESTINATION
fi

echo "SOURCE_REPO: $SOURCE_REPO"
echo "DESTINATION_REPO: $DESTINATION_REPO"

git clone --mirror "$SOURCE_REPO" source && cd source || exit
git remote set-url --push origin "$DESTINATION_REPO"

git fetch -p origin

# Exclude refs created by GitHub for pull request.
git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin
git push --mirror
