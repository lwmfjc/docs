time=`date '+%Y-%m-%dT%H:%M:%S%:z'`
mydate=`date '+%Y%m%d'`
today=$(echo $time | sed -e 's/T.\+//g' -e 's/-//g' )

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
title: $mydate-
description: $mydate-
categories:
  - 生活
tags: 
  - 随想
cssAttach: 
  - book03
cssclasses: 
  - book03
date: $time
lastmod: $time
---
_EOF_
echo "创建$fileName成功"