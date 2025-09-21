#!/bin/sh

echo 'mirror'

set -e

echo "
SOURCE=${SOURCE}
REMOTES=${REMOTES}
"

if expr "${SOURCE}" : '^https\?://' >/dev/null; then
    # 移除协议部分（http://或https://）
    path=$(expr "${SOURCE}" : '^https\?://[^/]*//*\(.*\)')
    # 提取用户名（第一个/之前的部分）
    OWNER=$(expr "${path}" : '^\([^/]*\)/')
    # 提取仓库名（用户名之后的部分）
    REPOSITORY=$(expr "${path}" : "^${OWNER}/\(.*\)")
# 处理SSH格式: git@任意域名:用户/仓库
elif expr "${SOURCE}" : '^git@' >/dev/null; then
    # 提取冒号后的路径部分
    path=$(expr "${SOURCE}" : '^git@[^:]*:\(.*\)')
    # 提取用户名
    OWNER=$(expr "${path}" : '^\([^/]*\)/')
    # 提取仓库名
    REPOSITORY=$(expr "${path}" : "^${OWNER}/\(.*\)")
else
    echo "无法识别的格式: ${SOURCE}"
    exit 1
fi

echo "
OWNER=${OWNER}
REPOSITORY=${REPOSITORY}
"

write_hosts() {

  DOMAIN=$(echo "$1" |
           cut -d @ -f 2 |
           cut -d : -f 1)
  IP=$(nslookup "${DOMAIN}" 8.8.8.8 |
                    grep "Address: " |
                    cut -d ' ' -f 2)

  IP_DOMAIN="${IP} ${DOMAIN}"
  echo "${IP_DOMAIN}" >> ~/.hosts

}

mirror() {

  REMOTE=$1

  if [ "${REMOTE}" = "${REMOTE#git@}" ]; then
    DESTINATION="git@${REMOTE}:${OWNER}/${REPOSITORY}"
  else
    DESTINATION=${REMOTE}
  fi

  echo "mirror to ${DESTINATION}"
  git remote set-url --push origin "$DESTINATION"

  # Exclude refs created by GitHub for pull request.
  git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin
  git push --mirror

}

git clone --mirror "${SOURCE}" source && cd source || exit

for REMOTE in $(echo "${REMOTES}" | sed "s/,/\n/g"); do

  echo ""
  echo "REMOTE: ${REMOTE}"

  write_hosts "${REMOTE}"
  mirror "${REMOTE}"


done

cd ..
rm -rf source

echo 'mirror successfully'
