---
title: 使用PaperMode
description: 使用PaperMode
categories:
  - 学习
tags:
  - hugo
  - PaperMod 
date: 2024-12-11 08:23:34  
updated: 2024-12-11 08:23:34  
---
# 地址
官方： https://github.com/adityatelange/hugo-PaperMod/wiki/Installation （有些东西没有同hugo官方同步）
非官方： https://github.com/vanitysys28/hugo-papermod-wiki/blob/master/Home.md （与hugo官方更同步）
# 安装
``` shell
hugo new site blog.source --format yaml
cd blog.source
git init
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod 
git submodule update --init --recursive # needed when you reclone your repo (submodules may not get cloned automatically) 
git submodule update --remote --merge
```