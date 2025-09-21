#!/bin/bash
#"pcb"--->"pc上备份配置"
#"pcr"--->"pc上恢复配置"
#"mbb"--->"手机上备份配置"
#"mbr"--->"手机上恢复配置"
n=$#
if [ $n -ne 1 ] ; then
	echo -e "Please set one params.  \npcb-->pc-backup(beifen)\npcr-->pc-recover(huifu)\nmbb-->mobile-backup(beifen)\nmbr-->mobile-recover(huifu)\n"
    exit 0
fi
x=$1
#注意下面的文件路径问题
if [ $x == "pcb" ] ; then 
    echo "pcb1"
    rm -rf  _os_pc_backup
    #备份pc上的source的obsidian配置
    cp -a  .obsidian  _os_pc_backup
elif [ $x == "pcr" ] ; then 
    echo "pcr1"
    rm -rf  .obsidian
    #恢复pc上的source的obsidian配置
    cp -a  _os_pc_backup  .obsidian
    bash '_sh/cfg-os-css.sh'
elif [ $x == "mbb" ] ; then 
    echo "mbb1"
    rm -rf  _os_mobile_backup
    #备份mobile上的source的obsidian配置
   cp -a  .obsidian  _os_mobile_backup
elif [ $x == "mbr" ] ; then 
    echo "mbr1"
    rm -rf  .obsidian
    #恢复mobile上的source的obsidian配置
    cp -a  _os_mobile_backup  .obsidian
    bash '_sh/cfg-os-css.sh'
fi
exit 1
