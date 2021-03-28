
# Git

## init
```shell script
git init
```

## clone
```shell script
git clone https://github.com/c332030/SpringBoot
```

## remote
```shell script
git remote add origin https://github.com/c332030/common-element-ui-ts
git remote remove origin
```

## push
```shell script
git push

git push -u origin master

# 最好不要用，会重置远程仓库
git push --force
```

## add
```shell script
git add 1.txt

# 添加所有文件
git add -A
```

## commit
```shell script
# -a 自动添加，不需要 git add
git commit -am "提交修改"

git commit -m "提交修改"
git commit index.html -m "提交修改"

```

## delete
删除文件夹，那么请在 git rm --cached 命令后面添加 -r 命令
```shell script

git filter-branch --force --index-filter "git rm --cached -r --ignore-unmatch pcre" --prune-empty --tag-name-filter cat -- --all

git filter-branch --force --index-filter "git rm --cached --ignore-unmatch zlib-1.2.11.tar.gz" --prune-empty --tag-name-filter cat -- --all

```

## log
```shell script
git log
```

## diff
```shell script
# 显示文件内容变更
git diff hash1 hash2

# 只显示文件名
git diff hash1 hash2 --stat
```

## archive
导出
```shell script
# 导出最新的
git archive -o ../latest.zip HEAD

# 导出某个版本
git archive -o ../latest.zip hash

# 导出某个版本的某个文件或目录
git archive -o ../latest.zip hash dir/file.md
```
