
set -e

ORIGIN_BRANCH=master

git checkout $ORIGIN_BRANCH
git pull

git fetch -p

git branch -r --merged \
  | grep -v 'master' \
  | grep -v 'release' \
  | grep -v 'ops' \
  | grep -v '^$' \
  | cut -d '/' -f 2 \
  | while read -r branch; do git push origin --delete "$branch"; done

# 删除「远程已删、本地还残留」的追踪分支，不会删除任何本地实际分支，也不会修改远程仓库。
git remote prune origin
