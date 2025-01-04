n=$#
if [ $n -ne 1 ] ; then
   echo -e "Please set the dir. "
   exit 0
fi

#待处理的txtz文件目录
bookDir=$1;
# echo $bookDir

#处理目录下的文件
handleDir(){ 
	local dir=$1;
	local files=$(ls "$dir")
	#echo "$files"
	#临时修改SHELL中的分隔符
	oldIFS=$IFS
	IFS=$'\n'
	for file in $files; do
		# echo "$file"
		# echo "$file"
		#如果是.txtz结尾
		if [[ $(expr "$file" : ".\+\.txtz$") > 0 ]]; then
			local fullPathFile="$dir/$file";
			cp -r "$fullPathFile" "$fullPathFile.zip"
			echo "$fullPathFile"
			unzip -o  "$fullPathFile" -d $dir
			rm "$fullPathFile.zip"

			#处理解压后的文件
			#sed -Ei "s/^##(.*?\s)/\1/g" index.txt 
			# sed不支持PCRE
			# \\\\\[用来取 \[ 
			#sed -Ei "s/\\\\\[([0-9]+)\\\\\]/[\1]/g"  index.txt 

			#替换图片地址
			sed -Ei "s/(\!\[.*\])\(images/\1\(img/g"  "$dir/index.txt"
			mv  "$dir/images" "$dir/img"  
		fi
	done
	IFS=$oldIFS

}
handleDir "$bookDir"