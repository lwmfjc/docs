#!/bin/bash
git remote set-url origin git@github.com:lwmfjc/blog.source.git #先从github更新
git pull origin main 
git remote set-url origin ssh://git@localhost:8022/storage/emulated/0/000ly/git/server/blog.source.git 
git add .
git commit -m 'github commit'
git push origin main #推送到本机服务器
