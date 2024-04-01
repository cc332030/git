#!/bin/sh

echo 'mirror-github'

set -e

USER=$(whoami)
if [ "root" = "$USER" ]
then
  USER_HOME=/root
else
  USER_HOME=/home/$USER
fi
echo "USER_HOME: ${USER_HOME}"

WORK_PATH=~/.hosts
echo "" >> $WORK_PATH
if [ ! ~ = "$USER_HOME" ]
then
  ln -s $WORK_PATH "$USER_HOME"
fi


REPOSITORY="$(basename "$GITHUB_REPOSITORY")"
SOURCE="git@github.com:$GITHUB_REPOSITORY.git"

echo "SOURCE: $SOURCE"

git clone --mirror "$SOURCE" source && cd source || exit
git fetch -p origin

# Exclude refs created by GitHub for pull request.
git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin


DEFAULT_DESTINATION=gitea.c332030.com,gitlab.com,gitee.com,gitcode.net

if [ ! "$DESTINATION" ]; then
  DESTINATION=${DEFAULT_DESTINATION}
  echo
  echo "default DESTINATION: $DESTINATION"
elif [ "," = "$(echo "$DESTINATION" | cut -c -1)" ]; then
  DESTINATION=${DEFAULT_DESTINATION}${DESTINATION}
fi

echo
echo "DESTINATION: $DESTINATION"

write_hosts() {
  DOMAIN=$(echo "$1" |
           cut -d @ -f 2 |
           cut -d : -f 1)
  IP=$(nslookup "$DOMAIN" 8.8.8.8 |
                    grep "Address: " |
                    cut -d ' ' -f 2)

  echo "$IP $DOMAIN" >> ~/.hosts

}

mirror(){

  REMOTE=$1

  # if REMOTE not starts with git@
  if test "${REMOTE}" = "${REMOTE#git@}"; then
   REMOTE="git@$REMOTE:$GITHUB_ACTOR/$REPOSITORY.git"
  fi

  echo
  echo "REMOTE: $REMOTE"

  write_hosts "$REMOTE"

  git remote set-url --push origin "$REMOTE"
  git push \
    --progress \
    --porcelain  \
    --mirror || true

}

REMOTES=$(echo $DESTINATION | sed "s/,/\n/g")
for REMOTE in $REMOTES; do
  mirror "$REMOTE"
done

echo 'mirror-github successfully'
