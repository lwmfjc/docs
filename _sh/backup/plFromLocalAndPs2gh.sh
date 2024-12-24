#!/bin/bash
git remote set-url origin ssh://git@localhost:8022/storage/emulated/0/000ly/git/server/blog.source.git
git pull origin main #先从手机上更新
git remote set-url origin git@github.com:lwmfjc/blog.source.git #切换origin到github
git add .
git commit -m 'k40s commit'
git push origin main #推送到github
