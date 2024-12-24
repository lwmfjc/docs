#!/bin/bash
#切换origin为本机
git remote set-url origin ssh://git@localhost:8022/storage/emulated/0/000ly/git/server/blog.source.git 
git pull origin main #从本机更新
