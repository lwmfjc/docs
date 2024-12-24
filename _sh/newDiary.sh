time=`date '+%Y-%m-%d %H:%M:%S'` 
today=$(echo $time | sed -e 's/\s\+.\+//g' -e 's/-//g' )

dir="content.zh/docs/life/$today" 
if [[ !( -d $dir ) ]] ;then
  mkdir -p $dir
  echo "创建$dir成功"
else 
  echo "$dir已存在,跳过文件夹创建"
fi

fileName="$dir/index.md"
if [[  -f $fileName  ]] ;then
  echo "$fileName已存在,跳过文件创建"
  exit 1
fi
cat >> $fileName <<-_EOF_
---
title: 
description: 
categories:
  - 生活
tags: 
date: $time
lastmod: $time
---
_EOF_
echo "创建$fileName成功"