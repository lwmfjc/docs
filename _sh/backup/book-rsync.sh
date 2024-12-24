#!/bin/bash
#"plk40"--->"从k40s拉取最新"
#"psk40"--->"推送到k40s"
#"pstb"--->"推送到tabs8"
#"pspc"--->"推送到pc笔记本"
n=$#
if [ $n -ne 1 ] ; then
   echo -e "Please set one params.  \nplk40-->pull from k40s\npsk40-->push to k40s\npstb-->push to tabs8\npspc-->push to pc\n"
    exit 0
fi
x=$1
#注意下面的文件路径问题
if [ $x == "plk40" ] ; then 
    echo "plk40--start"
    #从k40上拉取
    rsync -avz --progress --delete -e 'ssh -p 8022' ly@192.168.1.101:/storage/emulated/0/000Ly/git/blog.source/source/attachments/test-rsync  source/attachments 
    echo "plk40--end"
elif [ $x == "psk40" ] ; then 
    echo "psk40--start"
    #推送到k40
    rsync -avz --progress --delete  source/attachments/test-rsync   -e 'ssh -p 8022' ly@192.168.1.101:/storage/emulated/0/000Ly/git/blog.source/source/attachments
    echo "psk40--end"
#elif [ $x == "pstb" ] ; then 
#    echo "pstb--start"
#    #推送到tabs8
#    rsync -avz --progress --delete  source/attachments/test-rsync   -e 'ssh -p 8022' ly@192.168.1.106:/storage/emulated/0/000Ly/git/blog.source/source/attachments
#    echo "pstb--end"
#elif [ $x == "pspc" ] ; then 
#    echo "pspc--start"
#    #推送到pc
#    rsync -avz --progress --delete  source/attachments/test-rsync   -e 'ssh -p 22' ly@192.168.1.206:/mnt/hgfs/gitRepo/blog.source/source/attachments 
#    echo "pspc--end"
fi
exit 1