#!/bin/sh

echo 'push-github-https'

set -e

# 必须提供 GITHUB_TOKEN 用于 https 认证
if [ -z "${GITHUB_TOKEN}" ]; then
  echo "ERROR: GITHUB_TOKEN is required" >&2
  exit 1
fi

# 默认取当前仓库的 origin 远程地址，也可通过 SOURCE 显式指定
if [ -z "${SOURCE}" ]; then
  SOURCE=$(git remote get-url origin)
  if [ -z "${SOURCE}" ]; then
    echo "ERROR: origin remote not found, please set SOURCE" >&2
    exit 1
  fi
fi
echo "SOURCE: ${SOURCE}"

# 从远程地址解析归属用户（用户名）和仓库名
if expr "${SOURCE}" : '^https\?://' >/dev/null; then
  # https://cnb.cool/cc332030/git.git
  path=$(expr "${SOURCE}" : '^https\?://[^/]*//*\(.*\)')
  OWNER=$(expr "${path}" : '^\([^/]*\)/')
  REPOSITORY=$(expr "${path}" : "^${OWNER}/\(.*\)" | sed 's/\.git$//')
elif expr "${SOURCE}" : '^git@' >/dev/null; then
  # git@cnb.cool:cc332030/git.git
  path=$(expr "${SOURCE}" : '^git@[^:]*:\(.*\)')
  OWNER=$(expr "${path}" : '^\([^/]*\)/')
  REPOSITORY=$(expr "${path}" : "^${OWNER}/\(.*\)" | sed 's/\.git$//')
else
  echo "ERROR: unsupported SOURCE format: ${SOURCE}" >&2
  exit 1
fi

echo ''
echo "OWNER: ${OWNER}"
echo "REPOSITORY: ${REPOSITORY}"

# 两边用户名相同（人工保证），直接取当前归属用户
GITHUB_OWNER=${OWNER}

# 注意：切勿把含凭据的完整 URL 打印到日志，否则会泄露 GITHUB_TOKEN。
# 只打印不含 token 的域名/仓库信息。
DESTINATION="https://github.com/${GITHUB_OWNER}/${REPOSITORY}.git"
echo "DESTINATION: ${DESTINATION}"

# 使用 git credential store 注入凭据，避免 URL 中携带 token 而泄露。
# ~/.git-credentials 需设置为仅当前用户可读写。
CREDENTIAL_FILE="${HOME}/.git-credentials"
echo "https://${GITHUB_OWNER}:${GITHUB_TOKEN}@github.com" > "${CREDENTIAL_FILE}"
chmod 600 "${CREDENTIAL_FILE}"
git config --global credential.helper "store --file=${CREDENTIAL_FILE}"

write_hosts() {

  DOMAIN=$(echo "$1" |
           sed -E 's#^[a-zA-Z][a-zA-Z0-9+.-]*://##' |
           cut -d @ -f 2 |
           cut -d / -f 1 |
           cut -d : -f 1)
  IP=$(nslookup "$DOMAIN" 1.1.1.1 |
                    grep "Address: " |
                    cut -d ' ' -f 2)

  IP_DOMAIN="${IP} ${DOMAIN}"
  echo "${IP_DOMAIN}" >> ~/.hosts

}

write_hosts "${DESTINATION}"

git remote set-url --push origin "${DESTINATION}"

# Exclude refs created by GitHub for pull request.
git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin

# 只推送当前分支（HEAD），并同步其相关的所有引用（tags）。
# 不再使用 --mirror：那会把所有分支/引用都推上去，属于全量镜像。
BRANCH=$(git branch --show-current)
if [ -z "${BRANCH}" ]; then
  echo "ERROR: unable to determine current branch (detached HEAD?)" >&2
  exit 1
fi
echo "BRANCH: ${BRANCH}"

git push --progress --tags origin "HEAD:${BRANCH}"

echo ''
echo 'push-github-https successfully'
