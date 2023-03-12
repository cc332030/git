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



if [ ! "$DESTINATION" ]; then
  DESTINATION=gitlab.com,gitee.com,gitcode.net,jihulab.com
  echo
  echo "default DESTINATION: $DESTINATION"
else
  echo
  echo "DESTINATION: $DESTINATION"
fi

write_hosts() {
  DOMAIN=$(echo "$1" |
           cut -d @ -f 2 |
           cut -d : -f 1)
  IP=$(nslookup "$DOMAIN" 8.8.8.8 |
                    grep "Address: " |
                    cut -d ' ' -f 2)

  ip_domain="$IP $DOMAIN"
  echo "ip domain: ${ip_domain}"
  echo "$ip_domain" >> ~/.hosts

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
    --mirror

}

REMOTES=$(echo $DESTINATION | sed "s/,/\n/g")
for REMOTE in $REMOTES; do
  mirror "$REMOTE"
done

echo 'mirror-github successfully'
