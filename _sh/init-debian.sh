#!/bin/bash

#修改apt源为阿里云源
#判断是否没有备份过
#&& $(grep -c 'aliyun' /etc/apt/sources.list.bak ) == 0
file='/home/ly/lytemp/a.txt'
#file='/etc/apt/sources.list' 
if [[ -f $file'.bak' 
	&& $(grep -c 'aliyun' $file ) != 0
	]]; then
	#statements
	echo '已经处理过源了'
	
else
	echo '没有处理过源'
	cp -f $file $file'.bak'
	cat > $file <<-_EOF_
deb https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib
deb-src https://mirrors.aliyun.com/debian/ bookworm main non-free non-free-firmware contrib
deb https://mirrors.aliyun.com/debian-security/ bookworm-security main
deb-src https://mirrors.aliyun.com/debian-security/ bookworm-security main
deb https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib
deb-src https://mirrors.aliyun.com/debian/ bookworm-updates main non-free non-free-firmware contrib
deb https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib
deb-src https://mirrors.aliyun.com/debian/ bookworm-backports main non-free non-free-firmware contrib
_EOF_
	echo '源处理完毕'
fi
# cp /etc/apt/sources.list /etc/apt/sources.list.bak
