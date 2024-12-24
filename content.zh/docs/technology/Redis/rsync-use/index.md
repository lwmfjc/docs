---
title: rsync使用
description: 
categories: 
tags:  
date: 2024-12-01 19:07:54  
updated: 2024-12-01 19:07:54  
---
其实就是linux的cp功能（带增量复制）
#推送到rsync-k40
rsync -avz --progress --delete source-rsync -e 'ssh -p 8022' ly@192.168.1.101:/storage/emulated/0/000Ly/git/blog.source/source/attachments/rsync-k40
#推送到rsync-tabs8
rsync -avz --progress --delete source-rsync -e 'ssh -p 8022' ly@192.168.1.106:/storage/emulated/0/000Ly/git/blog.source/source/attachments/rsync-tabs8
#推送到rsync-pc
rsync -avz --progress --delete source-rsync -e 'ssh -p 22' ly@192.168.1.206:/mnt/hgfs/gitRepo/blog.source/source/attachments/rsync-pc

#从手机上拉取
rsync -avz --progress --delete -e 'ssh -p 8022' ly@192.168.1.101:/storage/emulated/0/000Ly/git/blog.source/source/attachments/rsync-k40 source-rsync 