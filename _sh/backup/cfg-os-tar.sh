#!/bin/bash
#"pcc"--->"pc上备份配置"
#"pcx"--->"pc上解压配置"
#"mbc"--->"手机上备份配置"
#"mbx"--->"手机上解压配置"
n=$#
if [ $n -ne 1 ] ; then
   echo -e "Please set one params.  \npcc-->pc-create\npcx-->pc-unzip\nmbc-->mobile-create\nmbx-->mobile-unzip\n"
    exit 0
fi
x=$1
#注意下面的文件路径问题
if [ $x == "pcc" ] ; then 
    echo "pcc1"
    #压缩pc上的source的obsidian配置
    tar -cvf pc-cfg-obsidian-source.tar source/.obsidian
elif [ $x == "pcx" ] ; then 
    echo "pcx1"
    rm -rf source/.obsidian
    #解压pc上的source的obsidian配置
    tar -xvf pc-cfg-obsidian-source.tar source/.obsidian
elif [ $x == "mbc" ] ; then 
    echo "mbc1"
    #压缩mobile上的source的obsidian配置
    tar -cvf mb-cfg-obsidian-source.tar source/.obsidian
elif [ $x == "mbx" ] ; then 
    echo "mbx1"
    rm -rf source/.obsidian
    #解压mobile上的source的obsidian配置
    tar -xvf mb-cfg-obsidian-source.tar source/.obsidian
fi
exit 1
