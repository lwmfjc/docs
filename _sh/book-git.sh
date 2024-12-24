#!/bin/bash
#"pl"--->"从k40s拉取最新"
#"ps"--->"推送到k40s"
cd  attachments/books
n=$#
if [ $n -ne 1 ] ; then
   echo -e "Please set one params.  \npl-->pull from k40s\nps-->push to k40s\n"
    exit 0
fi
x=$1
#注意下面的文件路径问题
if [ $x == "pl" ] ; then 
    echo "plk40--start"
    #从k40拉取
    git pull # || proxychains git pull
    echo "plk40--end" 
elif [ $x == "ps" ] ; then 
    echo "psk40--start"
    #推送到k40
    git add .
    git commit -m "commit_auto massage"
    git push # || proxychains git push
    echo "psk40--end" 
fi
exit 1
