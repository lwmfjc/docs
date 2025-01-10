dir='.obsidian/snippets'
cp -r static/css/*.css "$dir"
files=$(ls "$dir")
 
#临时修改SHELL中的分隔符
oldIFS=$IFS
IFS=$'\n'
for file in $files; do
	# echo $file 
	#如果是.css结尾
	if [[ $(expr "$file" : ".\+\.css$") > 0 ]]; then
		fullPathFile="$dir/$file";
		echo $fullPathFile
		perl -i -pe 's/\/\*(.*?)cssstart\*\//$1/gp' "$fullPathFile"
		perl -i -pe 's/\/\*(.*?)cssend\*\//$1/gp' "$fullPathFile"
		perl -i -pe 's/(.*\@import.*;)/\/\*$1\*\//gp' "$fullPathFile" 
	fi
done 
IFS=$oldIFS 