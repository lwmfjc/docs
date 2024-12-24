#!/bin/bash 
#1. obsidian 附件与链接那里要设置好，内部链接形式为 相对当前笔记的相对路径
#2. 先用obsidian的CustomAttachmentLocationV4.28版本，命令那里，使用collect
#指令把所有要处理的文件，里面的文件都处理成 "文件名/img/xxxx.png" 形式
#3. 之后使用该sh移动.md文件
#4. 最后用EmEditor，在文件中查找替换，使用 \(.+/img/ 正则，替换成左括号 (img/即可
#"设置唯一一个参数，指定处理的目录" 
n=$#
if [ $n -ne 1 ] ; then
   echo -e "Please set the dir. "
   exit 0
fi

readDir(){ 
	local dir=$1;
	local files=$(ls "$dir")
	#echo "$files"
	for file in $files; do
		local fullPathFile="$dir/$file";
		#echo "$fullPathFile"
		# 如果是一个目录
		if [[ -d $fullPathFile ]]; then  
			#如果是文件夹，则递归该文件夹
			readDir $fullPathFile 
		#如果是以.md结尾的markdown文件
		elif [[ $(expr "$fullPathFile" : ".\+\.md") > 0 ]]; then
			#打印文件名(不包括文件夹)
			#echo ${fullPathFile##*[/\\]}
			#打印文件名(不包括文件后缀，如x/y/01.md->x/y/01)
			#echo ${fullPathFile%.*}
			local fileName=${fullPathFile##*[/\\]}; 
			if [[ "index.md" == $fileName || "_index.md"  == $fileName ]]; then
				return 1
			fi 
			#获取文件名的同名文件夹
			local fileNamePath=${fullPathFile%.*};
			#如果该文件夹不存在
			if [[ !(-d $fileNamePath) ]]; then 
				echo "$fileNamePath文件夹不存在" 
				#创建文件夹
				mkdir -p $fileNamePath
			fi
			#将文件夹移入
			mv $fullPathFile "$fileNamePath/index.md"
			
		fi 
	done
}
 
curDir=$(pwd);
#echo "20--$curDir"
readDir $curDir/$1