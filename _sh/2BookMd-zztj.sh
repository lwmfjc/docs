mv images img
sed -Ei "s/^##(.*?\s)/\1/g" index.txt 
# sed不支持PCRE
# \\\\\[用来取 \[ 
sed -Ei "s/\\\\\[([0-9]+)\\\\\]/[\1]/g"  index.txt 

#替换图片地址
sed -Ei "s/(\!\[.*\])\(images/\1\(img/g"  index.txt 