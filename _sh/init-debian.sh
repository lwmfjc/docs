#!/bin/bash


#修改apt源为阿里云源 
handleSources(){
	file_sources=$1
	if [[ -f $file_sources'.bak' 
	&& $(grep -c 'aliyun' $file_sources ) != 0
	]]; then
		#statements
		echo '已经处理过源了'
	
	else
		echo '没有处理过源'
		cp -f $file_sources $file_sources'.bak'
		cat > $file_sources <<-_EOF_
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
}

updateSource(){ 
	sudo apt update
	sudo apt upgrade
}

#修改ip
handleip(){
	file_ip=$1 
	cp -f $file_ip $file_ip'.bak'
	cat > $file_ip <<-_EOF_
#ly-update
auto ens32
iface ens32 inet static
address 192.168.1.210
netmask 255.255.255.0
gateway 192.168.1.1
dns-nameservers 223.5.5.5 223.6.6.6
_EOF_
	echo 'ip文件'$file_ip'处理完毕' 
# cp /etc/apt/sources.list /etc/apt/sources.list.bak
}

handleOthes(){
	# 把ly从sudo组移出
	sudo deluser ly sudo
	echo '把ly从sudo组移出'
	# 添加ly到sudo组
	echo '添加ly到sudo组'
	sudo usermod -aG sudo ly 
}

file_sources='/etc/apt/sources.list' 
# file_sources='/home/ly/lytemp/a.txt'
file_ip='/etc/network/interfaces'
# file_ip='/home/ly/lytemp/a.txt'

handleSources $file_sources
handleip $file_ip
handleOthes
updateSource