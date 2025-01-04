n=$#
if [ $n -ne 2 ] ; then
   echo -e "Please set the dir(source)(book目录) dir(dest)(md目录). "
   exit 0
fi

#待处理的txtz文件目录
bookDir=$1;
dirMd=$2; 

createAndInitMd(){
fileName="$1/index.md"
time=`date '+%Y-%m-%d %H:%M:%S'` 
cat >> $fileName <<-_EOF_
---
title: 
description: 
categories:
  - 学习
tags: 
  - 文化
cssAttach: 
  - book
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
	for file in $files; do
		local fullPathFile="$dirBook/$file";
		if [[ -d $fullPathFile ]]; then
			# echo $file 
			#如果是目录则在目录创建对应的目录
			mkdir -p "$dirMd/$file" 
			createAndInitMd "$dirMd/$file" 
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
			sed -Ei "s/(\!\[\.*?\])\(images/\1\img/g"  "$dirBook/index.txt"
			mkdir -p "$dirMd/img" 
			cp -r "$dirBook"/images/* "$dirMd/img"
			rm -rf "$dirBook"/images
			echo -ne "\n\n" >>  "$dirMd/index.md"
			# echo "23" >>  "$dirMd/index.md"
			cat "$dirBook/index.txt" >>  "$dirMd/index.md"
			rm -rf "$dirBook"/index.txt
		fi
	done
	IFS=$oldIFS

}
iterateBooks "$bookDir" "$dirMd"
# handleDir "$bookDir" "$dirMd"