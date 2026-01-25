#!/bin/sh

echo ''
echo 'mirror-github'

set -e

CCC=c332030
CCCC=cc332030

CNB_COOL=cnb.cool

USER=$(whoami)
if [ "root" = "${USER}" ]
then
  USER_HOME=/root
else
  USER_HOME=/home/${USER}
fi
echo "USER_HOME: ${USER_HOME}"

WORK_PATH=~/.hosts
echo "" >> $WORK_PATH
if [ ! ~ = "$USER_HOME" ]
then
  ln -s $WORK_PATH "$USER_HOME"
fi


OWNER=$(echo "${GITHUB_REPOSITORY}" | cut -d / -f 1)
REPOSITORY="$(basename "${GITHUB_REPOSITORY}")"
SOURCE="git@github.com:${GITHUB_REPOSITORY}.git"

echo "SOURCE: $SOURCE"

git clone --mirror "$SOURCE" source && cd source || exit
git fetch -p origin

# Exclude refs created by GitHub for pull request.
git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin

DEFAULT_DESTINATION=${CNB_COOL},gitea.c332030.com,gitlab.com,gitee.com,gitcode.net,atomgit.com

if [ ! "${DESTINATION}" ]; then
  DESTINATION=${DEFAULT_DESTINATION}
  echo ''
  echo "default DESTINATION: ${DESTINATION}"
elif [ "," = "$(echo "${DESTINATION}" | cut -c -1)" ]; then
  DESTINATION=${DEFAULT_DESTINATION}${DESTINATION}
fi

echo ''
echo "DESTINATION: ${DESTINATION}"

write_hosts() {

  DOMAIN=$(echo "$1" |
           cut -d @ -f 2 |
           cut -d : -f 1)
  IP=$(nslookup "$DOMAIN" 8.8.8.8 |
                    grep "Address: " |
                    cut -d ' ' -f 2)

  IP_DOMAIN="${IP} ${DOMAIN}"
  echo "${IP_DOMAIN}" >> ~/.hosts

}

mirror(){

  REMOTE=$1
  echo ''
  echo "mirror to <${REMOTE}>"

  if [ "${REMOTE}" = "${CNB_COOL}" ]; then

    echo ''
    echo "check CNB_SYNC_TOKEN"
    if [ -n "${CNB_SYNC_TOKEN}" ]; then

      if [ "${OWNER}" = "${CCC}" ]; then
        CNB_OWNER=${CCCC}
      else
        CNB_OWNER=${OWNER}
      fi

      echo ''
      echo "check exists ${GITHUB_REPOSITORY}"
      # 仓库不存在时创建
      GET_RESULT=$(curl -sS -X 'GET' \
                "https://api.cnb.cool/${GITHUB_REPOSITORY}" \
                -H "Authorization: Bearer ${CNB_SYNC_TOKEN}" \
                -H 'accept: application/json')

      echo ''
      echo "GET_RESULT: ${GET_RESULT}"

      if ! echo "${GET_RESULT}" | grep -q 'name'; then

          CREATE_RESULT=$(curl -sS -X 'POST' \
                        "https://api.cnb.cool/${CNB_OWNER}/-/repos" \
                        -H "Authorization: Bearer ${CNB_SYNC_TOKEN}" \
                        -H 'accept: application/json' \
                        -H 'Content-Type: application/json' \
                        -d "
                          {
                            \"name\": \"${REPOSITORY}\",
                            \"visibility\": \"private\"
                          }
                        ")
        echo ''
        echo "CREATE_RESULT: ${CREATE_RESULT}"
      fi

      REMOTE="https://cnb:${CNB_SYNC_TOKEN}@${REMOTE}/${CNB_OWNER}/${REPOSITORY}"

    else
      echo ''
      echo "skip <${REMOTE}> because of no CNB_SYNC_TOKEN"
      REMOTE=
    fi

  elif [ "${REMOTE}" = "${REMOTE#git@}" ]; then
    echo ''
    echo "REMOTE startsWith git"
    REMOTE="git@${REMOTE}:${GITHUB_ACTOR}/${REPOSITORY}.git"
  else
    echo ''
    echo "REMOTE else"
  fi

  echo ''
  echo "REMOTE: ${REMOTE}"

  if [ -n "${REMOTE}" ]; then

    write_hosts "${REMOTE}"

    git remote set-url --push origin "${REMOTE}"
    git push \
      --progress \
      --porcelain  \
      --mirror \
      --force || true
  fi

}

REMOTES=$(echo "${DESTINATION}" | sed "s/,/\n/g")
for REMOTE in ${REMOTES}; do
  mirror "${REMOTE}"
done

echo ''
echo 'mirror-github successfully'
