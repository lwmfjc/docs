n=$#
if [ $n -ne 2 ] ; then
   echo -e "Please set the dir(source)(book目录) dir(dest)(md目录). "
   exit 0
fi

#待处理的txtz文件目录
bookDir=$1;
dirMd=$2; 

initDirMd(){
fileName="$1/_index.md" 
cat >> $fileName <<-_EOF_
---
bookCollapseSection: true
weight: 20
title:
---
_EOF_
# echo "创建$fileName成功"
}
initContentMd(){
fileName="$1/index.md"
time=`date '+%Y-%m-%dT%H:%M:%S%:z'`
cat >> $fileName <<-_EOF_
---
title: 
description: 
categories:
  - 学习
tags: 
  - 左传
  - 文化
cssAttach: 
  - book01
cssclasses: 
  - book01
date: $time
lastmod: $time
---
_EOF_
# echo "创建$fileName成功"
}

#遍历books目录并在相应位置创建目录
iterateBooks(){

	local dirBook=$1;
	local dirMd=$2;
	local files=$(ls "$dirBook")
	#echo "$files"
	#临时修改SHELL中的分隔符
	oldIFS=$IFS
	IFS=$'\n'
	initDirMd "$dirMd"
	for file in $files; do
		local fullPathFile="$dirBook/$file";
		if [[ -d $fullPathFile ]]; then
			# echo $file 
			#如果是目录则在目录创建对应的目录
			mkdir -p "$dirMd/$file" 
			initContentMd "$dirMd/$file" 
			#处理目录下文件
			handleDir "$fullPathFile" "$dirMd/$file"
		fi
	done
	IFS=$oldIFS
}

#处理目录下的文件
handleDir(){ 
	local dirBook=$1;
	local dirMd=$2;
	local files=$(ls "$dirBook")
	#echo "$files"
	#临时修改SHELL中的分隔符
	oldIFS=$IFS
	IFS=$'\n'
	for file in $files; do
		#如果是.txtz结尾
		if [[ $(expr "$file" : ".\+\.txtz$") > 0 ]]; then
			local fullPathFile="$dirBook/$file";
			cp -r "$fullPathFile" "$fullPathFile.zip"
		    echo "$fullPathFile"
			unzip -qo  "$fullPathFile" -d $dirBook
			rm "$fullPathFile.zip"

			#处理解压后的文件
			#sed -Ei "s/^##(.*?\s)/\1/g" index.txt 
			# sed不支持PCRE
			# \\\\\[用来取 \[ 
			#sed -Ei "s/\\\\\[([0-9]+)\\\\\]/[\1]/g"  index.txt 

			#替换图片地址
			# 这里-i -pe 一个不能去掉，且顺序不能改。且p去掉没效果，不知道原因
			# perl命令行加上"-e"选项，就能在perl命令行中直接写perl表达式
			# -i：对输入的每一行执行一次代码，并进行原地编辑（覆盖原文件）
			# -p：对输入的每一行执行一次Perl代码，并打印输出结果。 
			# g是全局,p：保存匹配的字符串到${^PREMATCH} ${^MATCH} ${^POSTMATCH}中，它们在结果上对应$` $& $'
			perl -i -pe 's/(\!\[.*?\])\(images/$1\(img/gp' "$dirBook/index.txt"
			#perl中$&表示整个字符串
			# perl -i -pe 's/(\!\[.*?\])\(img.*?\)/$&  \n/gp' "$dirBook/index.txt"
			#替换\(\) \[\]之类的默认转义（不需要）
			perl -i -pe 's/\\\[(.*?)\\\]/\[$1\]/gp' "$dirBook/index.txt"
			perl -i -pe 's/\\\((.*?)\\\)/\($1\)/gp' "$dirBook/index.txt"
			# 反引号`，星号*，下划线_
			perl -i -pe 's/\\`/`/gp' "$dirBook/index.txt"
			perl -i -pe 's/\\\*/\*/gp' "$dirBook/index.txt"
			perl -i -pe 's/\\_/_/gp' "$dirBook/index.txt"
			#标题降1级(#\s+)\*{2}(.*?)\*{4}
			perl -i -pe 's/^#(.*?\s)/$1/gp' "$dirBook/index.txt" 
			#标题后面左边带了星号(这里有点问题，下次遇到再说)
			# perl -i -pe 's/(#.*?)\*.*\*/$1/gp' "$dirBook/index.txt" 
			#标题后面左右两边都带了星号
			perl -i -pe 's/(#.*?)\*{2}(.*)\*{2}/$1$2/gp' "$dirBook/index.txt"
			#处理!(images/000002.jpg)
			perl -i -pe 's/\!\(images\//\![]\(img\//gp' "$dirBook/index.txt"


			#去除#号后面4个星号(#\s+)(.*?)\s*\n\*{4}\s*\n\*{2}(.*)
			#perl -i -0 -pe 's/(#\s+)\*{2}(.*?)\*{4}.*\n\*{4}.*\n\*{2}(.*)\n.*\n/$1$2 $3/gp' "$dirBook/index.txt" 
			


			#去除#后面连续的4个星号
			#perl -i -pe 's/^(#.*?\s)\*{4}/$1/gp' "$dirBook/index.txt" 
			#去除#号后面4个星号(#\s+)\*{2}(.*?)\*{4}
			#perl -i -pe 's/(#\s+)\*{2}(.*?)\*{4}/$1$2/gp' "$dirBook/index.txt"
			#处理img图片
			# sed -Ei "s/(\!\[\.*?\])\(images/\1\(img/g"  "$dirBook/index.txt"
			#替换\(\) \[\]之类的默认转义（不需要）
			# sed -Ei "s/\\\\\[/[/g"  "$dirBook/index.txt"
			# sed -Ei "s/\\\\\]/]/g"  "$dirBook/index.txt"
			# sed -Ei "s/\\\\\(/(/g"  "$dirBook/index.txt"
			# sed -Ei "s/\\\\\)/)/g"  "$dirBook/index.txt"			
			#去除#后面连续的4个星号
			# sed -Ei "s/\*{4}//g"  "$dirBook/index.txt"
			# sed -Ei "s/\\\\\[(.*?)\\\\\]/[\1]/g"  "$dirBook/index.txt"
			# sed -Ei "s/\\\\\((.*?)\\\\\)/(\1)/g"  "$dirBook/index.txt"			
			#标题降1级
			# sed -Ei  "s/^#(.*?\s)/\1/g"  "$dirBook/index.txt"
			mkdir -p "$dirMd/img" 
			cp -r "$dirBook"/images/* "$dirMd/img"
			rm -rf "$dirBook"/images
			echo -ne "\n" >>  "$dirMd/index.md"
			# echo "23" >>  "$dirMd/index.md"
			cat "$dirBook/index.txt" >>  "$dirMd/index.md"
			rm -rf "$dirBook"/index.txt
		fi
	done
	IFS=$oldIFS

}
iterateBooks "$bookDir" "$dirMd"
# handleDir "$bookDir" "$dirMd"