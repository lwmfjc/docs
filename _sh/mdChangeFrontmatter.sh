n=$#
if [ $n -ne 1 ] ; then
   echo -e "Please set one dir(md目录). "
   exit 0
fi


#├─史记
#│  ├─001第一卷五帝本纪第一
#│  │  └─index.md
#│  ├─002第二卷夏本纪第二
#│  │  └─index.md
#│  ├─003第三卷殷本纪第三
#│  │  └─index.md
#│  ├─004第四卷周本纪第四
#│  │  └─index.md
 
#dirRoot:待处理的md文件所在文件夹，所在的文件夹 

dirRoot=$1;  

#处理根目录(史记)下的文件夹
handleRoot(){

	local dirRoot=$1;  
	# echo "$dirRoot"
	local dirs=$(ls "$dirRoot")
	#echo "$files"
	#临时修改SHELL中的分隔符
	oldIFS=$IFS
	IFS=$'\n'
	for dir in $dirs; do
		local fullPath="$dirRoot/$dir" 
		if [ -d "$fullPath" ]; then
			 handleDir "$fullPath" "$dir"
		fi
	done
	IFS=$oldIFS

	# echo "end "

}

#处理目录下的文件
#参数1 完整目录
#参数2 目录名
handleDir(){ 
	local dirRoot=$1;
	local title=$2;
	local files=$(ls "$dirRoot")
	#echo "$files"
	#临时修改SHELL中的分隔符
	oldIFS=$IFS
	IFS=$'\n'
	for file in $files; do
		#如果是.md结尾
		 if [[ $(expr "$file" : ".\+\.md$") > 0 ]]; then
			 # echo $file
			 local fullPathFile="$dirRoot/$file";

			 local oldStr='title: .*'
			 local newStr='title: '$title
			 # echo $replaceStr
			 perl -i -pe "s/$oldStr/$newStr/gp" "$fullPathFile"


			 local oldStr='description: .*'
			 local newStr='description: '$title
			 perl -i -pe "s/$oldStr/$newStr/gp" "$fullPathFile"

			 echo "$fullPathFile"文件处理完毕!
		 fi
	done
	IFS=$oldIFS

}
handleRoot "$dirRoot"  
# handleDir "$bookDir" "$dirMd"