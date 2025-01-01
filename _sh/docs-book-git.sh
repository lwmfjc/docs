#!/bin/bash
#"pl"--->"拉取blog和books"
#"ps"--->"推送blog和books"
n=$#
if [ $n -ne 1 ] ; then
   echo -e "Please set one params.  \npl-->blog pull from github,books pull from k40s\nps-->blog ps to github,books  ps to k40s\n"
    exit 0
fi
x=$1
#注意下面的文件路径问题
if [ $x == "pl" ] ; then 
    echo "plgithub--start"
    #git pull ||
    proxychains git pull || proxychains4 git pull || git pull
    echo "plgithub--end"
    #blog推送到github
    echo "plk40--start"
    #从k40拉取
    cd  attachments/books
    proxychains git pull || proxychains4 git pull || git pull
    echo "plk40--end"
elif [ $x == "ps" ] ; then 
    #blog推送到github
    echo "psgithub--start"
    git add .
    git commit -m "commit_auto massage"
    #git push || 
    proxychains git push || proxychains4 git push || git push
    echo "psgithub--end"
    #推送到k40
    echo "psk40--start"
    cd  attachments/books
    git add .
    git commit -m "commit_auto massage"
    proxychains git push || proxychains4 git push || git push
    echo "psk40--end" 
fi
exit 1
