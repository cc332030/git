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



if [ ! "$DESTINATION" ]; then
  DESTINATION=gitee
  echo
  echo "default DESTINATION: $DESTINATION"
else
  echo
  echo "DESTINATION: $DESTINATION"
fi

mirror(){

  REMOTE=$1

  # if REMOTE not starts with git@
  if test "${REMOTE}" = "${REMOTE#git@}"; then
   REMOTE="git@$REMOTE.com:$GITHUB_ACTOR/$REPOSITORY.git"
  fi

  echo
  echo "REMOTE: $REMOTE"

  git remote set-url --push origin "$REMOTE"
  git push --mirror

}

REMOTES=$(echo $DESTINATION | sed "s/,/\n/g")
for REMOTE in $REMOTES; do
  mirror "$REMOTE"
done

echo 'mirror-github successfully'
