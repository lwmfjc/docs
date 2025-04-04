---
title: 平板安装linuxDeploy的问题简记
description: 平板安装linuxDeploy的问题简记
categories:
  - 学习
tags: 
date: 2025-03-31T23:43:10+08:00
lastmod: 2025-03-31T23:43:10+08:00
cssAttach:
  - book01
cssclasses:
  - book01
---
# 关于系统服务
```shell
ly@tabs8:~$ ls -l /etc/systemd/system/sshd.service
lrwxrwxrwx. 1 root root 31 Apr  3 14:16 /etc/systemd/system/sshd.service（用户自定义service存放地址） -> /lib/systemd/system/ssh.service（系统安装软件后的service存放地址）

但是sudo service hello status，chroot容器中查找的只是/etc/init.d/这个路径下的hello（不查找/etc/systemd和lib/systemd中的），但是如果使用systemctl disable hello，则/etc/init.d中的hello服务不会被运行，并且会删除/etc/systemd/system/multi-user.target.wants文件夹下的软连接。如果systemctl enable hello，则会在/etc/systemd/system/multi-user.target.wants文件夹下生成一个软连接。
执行完/etc/init.d/hello就不会再操作其他东西了(hello.service没有用)
```
建议linuxdeploy的自动化开启Sysv模式，然后在/etc/init.d/里头编写脚本就可以了，如果要开机启动，使用systemctl enable xxx即可。

## 问题1
chroot容器中，sudo systemctl enable hello.service后，开机启动时并没有执行。但是如果服务名hello在/etc/init.d/文件中存在对应名的SysV Init 脚本，就会执行，这是为什么呢  

> 在普通 chroot 中，SysV Init 脚本能执行是因为其不依赖 PID 1 管理器，而 systemd 服务需要完整的初始化环境。若需 systemd 功能，应优先使用 systemd-nspawn。
## 问题2 ★
chroot容器中，默认情况下，系统启动时会执行/etc/init.d/hello脚本（SysV Init 脚本），但是如果sudo systemctl disable hello.service后，开机启动时就不会执行了，这是为什么呢

 ```shell
  Debian 12（即使使用 systemd）默认保留了 SysV Init 兼容性，通过systemd-sysv-generator 工具动态生成 .service 文件来管理 /etc/init.d/ 中的脚本。当执行 systemctl disable hello.service 时：①删除符号链接：会移除 /etc/systemd/system/<target>.wants/ 中指向自动生成的 hello.service 的符号链接（如 multi-user.target.wants/hello.service）。②禁用服务：即使 /etc/init.d/hello 存在，systemd 也不会在开机时触发其执行，因为兼容层已被禁用。
```

## systemctl enable
```shell
ly@tabs8:~$ sudo systemctl disable ssh
Synchronizing state of ssh.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable ssh
Removed "/etc/systemd/system/multi-user.target.wants/ssh.service".
Removed "/etc/systemd/system/sshd.service".
#=================================
ly@tabs8:~$ ls -l /etc/systemd/system/multi-user.target.wants | grep ssh
ly@tabs8:~$ ls -l /etc/systemd/system/ | grep ssh
#================开机自启动========
ly@tabs8:~$ sudo systemctl enable ssh
Synchronizing state of ssh.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable ssh
#创建了两个符号链接
#保证兼容性，十几年前一直是用sshd
Created symlink /etc/systemd/system/sshd.service → /lib/systemd/system/ssh.service.
#multi-user.target.wants下: 开机自启动
Created symlink /etc/systemd/system/multi-user.target.wants/ssh.service → /lib/systemd/system/ssh.service.
#开机自启动其实是直接链接到系统（软件）自己的service
ly@tabs8:~$ ls -l /etc/systemd/system/multi-user.target.wants | grep ssh
lrwxrwxrwx. 1 root root 31 Apr  3 15:05 ssh.service -> /lib/systemd/system/ssh.service
ly@tabs8:~$ ls -l /etc/systemd/system/ | grep ssh
lrwxrwxrwx. 1 root root   31 Apr  3 15:05 sshd.service -> /lib/systemd/system/ssh.service

#====总的来说，我只要在/etc/systemd/system/下创建自己的服务S，然后systemctl enable S即可
```
## service编写(这里没用上)
```shell
vim /etc/systemd/system/vncser

[Unit]
Description=TigerVncService  # 服务描述
After=network.target          # 定义启动顺序（在网络就绪后启动）

[Service]
Type=simple                  # 服务类型（simple/forking/oneshot等）
ExecStart=/usr/local/bin/tigervnc.sh    # 启动命令（绝对路径）
Restart=on-failure           # 失败时自动重启
User=ly                  # 运行用户（可选）
#Group=nogroup                # 运行组（可选）
#WorkingDirectory=/path/to    # 工作目录（可选）

[Install]
WantedBy=multi-user.target   # 定义服务所属的“目标”（开机自启）
```

# 一些命令暂记
```shell
#镜像下载 https://mirrors-i.tuna.tsinghua.edu.cn/lxc-images/images/debian/bookworm/arm64/
#发行版 [rootfs.tar]
#源地址 ${EXTERNAL_STORAGE}/linuxdeploy/....tar.xz
#安装类型[ 目录]
#安装路径[ ${ENV_DIR}/rootfs/bookworm ] --> [ /data/data/ru.meefik.linuxdeploy/files/rootfs/bookworm ]
#用户名--用户密码--特权用户--本地化--DNS--networktrigger--powertrigger--随便弃用
#(弃用)初始化-启用-run-parts--路径/etc/rc.local--初始用户root
#!!!!初始化我这里使用sysv，通过systemctl enable ssh可以让ssh开机自启动，但是systemctl start ssh不能使用，需要用service ssh start替代
#其他都不需要

#设置 telnet守护模式打开
```


```

telnet 192.168.1.106 5023
su
/data/user/0/ru.meefik.linuxdeploy/files/bin/linuxdeploy shell -u root
#修改默认密码
passwd
```
安装证书并重启
```shell
#修复dns
rm /etc/resolv.conf
touch /etc/resolv.conf && chmod 755 /etc/resolv.conf
#重启
#重新连接
telnet 192.168.1.106 5023
su
/data/user/0/ru.meefik.linuxdeploy/files/bin/linuxdeploy shell -u root
#更新
apt update
apt install -y ca-certificates
```

修改源（debian-bookworm）
``` shell
cp -i /etc/apt/sources.list /etc/apt/sources.list.bak
vim /etc/apt/sources.list
#清华源
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

#===========或者阿里云源=================== 

deb https://mirrors.aliyun.com/debian/ bookworm main contrib non-free non-free-firmware
#deb-src https://mirrors.aliyun.com/debian/ bookworm main contrib non-free non-free-firmware

deb https://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free non-free-firmware
#deb-src https://mirrors.aliyun.com/debian/ bookworm-updates main contrib non-free non-free-firmware

deb https://mirrors.aliyun.com/debian/ bookworm-backports main contrib non-free non-free-firmware
#deb-src https://mirrors.aliyun.com/debian/ bookworm-backports main contrib non-free non-free-firmware

deb https://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
#deb-src https://mirrors.aliyun.com/debian-security/ bookworm-security main contrib non-free non-free-firmware
```
修改源（debian-bullseye）
```shell
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free

deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
# deb-src https://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free
```

修改源（ubuntu）
```shell
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-backports main restricted universe multiverse

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-security main restricted universe multiverse
# deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-proposed main restricted universe multiverse
# # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ noble-proposed main restricted universe multiverse
```

run-parts(指定/etc/rc.local或目录)  

SysV Init(/etc/init.d中存放服务管理脚本，推荐⭐)  

systemd(systemctl现代化,chroot中不可用)  

```shell
#更新
sudo apt update
#/data/user/0/ru.meefik.linuxdeploy/files/bin/linuxdeploy shell -u root
#手动安装ssh
sudo apt install openssh-server -y
vim /etc/ssh/sshd_config #Port修改为9022
 
/etc/init.d/ssh restart
 

#不用默认用户，新增一个用户
useradd -d /home/ly -s /bin/bash -m ly 

#将ly加入soduer组
#vim /etc/hosts #localhost后添加 tabs8
sudo usermod -aG sudo ly
passwd ly #设置密码
su - ly -c 'touch /home/ly/.Xauthority'
 ```
 需要手动安装桌面
```shell
#sudo apt install tasksel -y
#su
#tasksel #建议xfce
#sudo apt install task-xfce-desktop 
sudo apt install dbus-x11 -y
sudo apt install  xfce4 -y
sudo apt install xfce4-terminal -y #终端安装
#sudo mv /etc/init.d/udev /etc/init.d/.udev #隐藏开机自启动
#安装后重启
$ systemctl get-default
graphical.target
```
# tigervnc使用
```shell
sudo apt install tigervnc-standalone-server -y
#tigervnc-common tightvncserver -y
vncpasswd
#vncserver连接
#vncserver -localhost no 
#vncserver -list
#vncserver -kill :1

#编写用户独立配置文件
mkdir -p $HOME/.vnc/
ls /usr/share/xsessions

#===========配置1============
vim ~/.vnc/config
#session=xfce  #ls /usr/share/xsessions
#session=lightdm-xsession
geometry=1920x1080
localhost=no
#autostart=false	
alwaysshared

#=========配置2-start======
su ly
mkdir -p ~/.vnc
vim ~/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 #&

#添加权限
chmod +x ~/.vnc/xstartup
#=========配置2--end======

# sudo service vncserver restart
#===================
sudo vim /etc/tigervnc/vncserver.users
:1=ly
#:2=root

#sudo systemctl enable tigervncserver@:1.service
#Created symlink /etc/systemd/system/multi-user.target.wants/tigervncserver@:1.service → /lib/systemd/system/tigervncserver@.service.
#======1. Sysv模式下，@不能用。所以应该修改连接名
#======2. 但是在Sysv模式下，/etc/systemd/system没办法触发，改了也没用改为在/etc/init.d/下写脚本hello，然后以脚本名hello作为服务名启动服务 sudo systemctl enable hello


#重新建立软连接
#sudo ln -sf /lib/systemd/system/tigervnc.service /etc/systemd/system/multi-user.target.wants/tigervnc.service


 #查看vncserver列表
vncserver -list
#vncserver -kill :1

```
vncserver脚本
```shell
ly@localhost:~$ sudo vim /etc/init.d/vncserver 
sudo chmod +x /etc/init.d/vncserver 
sudo systemctl enable vncserver
sudo service vncserver restart
#!/bin/bash
### BEGIN INIT INFO
# Provides:          tigervnc
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     3 4 5
# Default-Stop:      0 1 2 6
# Short-Description: TigerVNC server (SysV init script)
# Description:       Starts TigerVNC server per-instance (e.g., tigervnc :1)
### END INIT INFO

# 配置变量（根据实际路径调整）
VNC_EXEC="/usr/libexec/tigervncsession-start"
VNC_INSTANCE=":1"  # 默认实例，可通过命令行参数覆盖
PIDFILE="/run/tigervncsession-${VNC_INSTANCE}.pid"
CLEANFILE='/root/bin/vncserver-clean'
SELINUX_CONTEXT="system_u:system_r:vnc_session_t:s0"
MY_PROCESS_NAME='/usr/bin/Xtigervnc'

# 检查 root 权限
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: This script must be run as root." >&2
        exit 1
    fi
}

# 设置 SELinux 上下文
set_selinux_context() {
    if command -v runcon >/dev/null && [ -n "$SELINUX_CONTEXT" ]; then
        runcon -u system_u -r system_r -t vnc_session_t -- "$@"
    else
        "$@"
    fi
}

# 启动服务
start() {
    #sudo bash "$CLEANFILE"
    check_root
    if [ -e "$PIDFILE" ]; then
        echo "Error: PID file $PIDFILE already exists. Is the server already running?" >&2
        return 1
    fi

    echo "Starting TigerVNC server (instance: $VNC_INSTANCE)..."
    #set_selinux_context
    sudo "$VNC_EXEC" "$VNC_INSTANCE" # &
    sleep 1
    #echo "$VNC_EXEC"
    #echo "$VNC_INSTANCE"
    #PID=$!
    #MY_PROCESS_NAME='/usr/bin/Xtigervnc'
    #echo $MY_PROCESS_NAME
    PID=$(pgrep -f "$MY_PROCESS_NAME")
    #echo "$PID"
    echo $PID > "$PIDFILE"
    sleep 1  # 等待进程稳定

    if ! kill -0 $PID 2>/dev/null; then
        echo "Error: Failed to start TigerVNC server." >&2
        rm -f "$PIDFILE"
        return 1
    fi
    echo "Started with PID $PID."
}

# 停止服务
stop() {
    check_root
    if [ ! -e "$PIDFILE" ]; then
        echo "Error: PID file $PIDFILE not found. Is the server running?" >&2
        return 1
    fi

    PID=$(cat "$PIDFILE")
    echo "Stopping TigerVNC server (PID: $PID)..."
    kill -TERM "$PID" 2>/dev/null || true
    sleep 1

    if kill -0 "$PID" 2>/dev/null; then
        echo "Warning: Process did not exit gracefully. Force killing..."
        kill -KILL "$PID" 2>/dev/null || true
    fi

    rm -f "$PIDFILE"
    #sudo bash "$CLEANFILE"
    echo "Stopped."
}

# 重启服务
restart() {
    stop
    sleep 1
    start
}

# 查看状态
status() {
    if [ ! -e "$PIDFILE" ]; then
        echo "TigerVNC server (instance: $VNC_INSTANCE) is not running."
        return 3  # LSB 标准: 服务未运行
    fi

    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
        echo "TigerVNC server (instance: $VNC_INSTANCE) is running with PID $PID."
        return 0  # LSB 标准: 服务运行中
    else
        echo "TigerVNC server (instance: $VNC_INSTANCE) PID file exists but process is dead."
        return 1  # LSB 标准: 服务异常
    fi
}

# 处理命令行参数
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status} [INSTANCE]"
        echo "Example: $0 start :1"
        exit 1
        ;;
esac

exit 0

```
清理vnc过往连接数据（备用）  
```shell
vim /home/bin/vncserver-clean.sh
#!/bin/bash
#
ids=$(vncserver -list | awk '{if (NR>4)print $1}')
for id in $ids;
do
   #id=${id/:/}
   #echo $id
   vncserver -kill :$id
done

for (( i=0; i<=10; i++ )); do
    #file1="$HOME/.vnc/localhost:590$i.log"
    #file2="$HOME/.vnc/localhost:590$i.pid"
    file1="$HOME/.vnc/localhost:$i.log"
    file2="$HOME/.vnc/localhost:$i.pid"
    file3="/tmp/.X$i-lock"
    file4="/tmp/.X11-unix/X$i"
    file5="/run/tigervncsession-:$i.pid"

    if [[ -f "$file1" ]]; then
        rm -rf "$file1"
    fi
    
    if [[ -f "$file2" ]]; then
        rm -rf "$file2"
    fi
    
    if [[ -f "$file3" ]]; then
        rm -rf "$file3"
    fi
    if [[ -f "$file4" || -S "$file4" ]]; then
        #echo "$file4"
        rm -rf "$file4"
    fi
    if [[ -f "$file5" ]];then 
	rm -rf "$file5"
    fi
done

chmod +x ~/_sh/*.sh
```
# 应用处理
## 音频
```shell
#sudo apt remove pulseaudio -y
#sudo apt purge pulseaudio -y
#sudo apt autoremove -y
sudo apt install pulseaudio -y
sudo apt install psmisc -y

vim ~/.vimrc
set nu
vim /etc/pulse/default.pa
#注释115行 load-module module-console-kit 
#运行 pactl list | grep 'Name\|Description' 并标识监视系统音频的模块。看看有没有auto_null.monitor

#===========================
sudo vim /etc/init.d/pashare 

#!/bin/bash
### BEGIN INIT INFO
# Provides:          tigervnc
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     3 4 5
# Default-Stop:      0 1 2 6
# Short-Description: TigerVNC server (SysV init script)
# Description:       Starts TigerVNC server per-instance (e.g., tigervnc :1)
### END INIT INFO

# 启动服务
start() {
	mkdir -p /home/ly/hello-hahahahah
	stop
	#change to normal user
	su - ly -c 'pulseaudio --start'
	su - ly -c 'pactl load-module module-simple-protocol-tcp rate=44100 format=s16le channels=2 source=auto_null.monitor record=true port=8000'
	echo "Started."
}

# 停止服务
stop() {
	su - ly -c 'pactl unload-module `pactl list | grep tcp -B1 | grep M | sed 's/[^0-9]//g'`'
	su - ly -c 'killall pulseaudio'
	echo "Stopped."
}

# 重启服务
restart() {
	stop
	sleep 1
	start
}

# 查看状态
status() {
	echo "hello-status"
}

# 处理命令行参数
case "$1" in
start)
	start
	;;
stop)
	stop
	;;
restart)
	restart
	;;
status)
	status
	;;
*)
	echo "Usage: $0 {start|stop|restart|status} [INSTANCE]"
	echo "Example: $0 start :1"
	exit 1
	;;
esac

exit 0

sudo chmod +x /etc/init.d/pashare 
sudo systemctl enable pashare

#测试
#sudo service pashare stop
#sudo service pashare start

```

```shell
apt install firefox-esr -y
#c++开发环境安装
sudo apt install build-essential gdb -y
1. vscode
#这里遇到了个问题，vscode配合leetcode插件0.18.4。 1.81.1< vscode_version <= 1.97.2没法用"code now"自动生成题目代码功能,nodejs_version 18.9
#目前vscode1.81.1可用
2. 中文环境 

#xfce4设置中文
#①. 安装并配置locales
sudo apt install locales
sudo dpkg-reconfigure locales
#②. 选择语言编码 zh相关, 第二个环境选英文
#!!③.配置当前用户默认语言 #!!这步骤不要
nano ~/.bashrc
在.bashrc最后添加一行
export LANG=zh_CN.UTF-8
#④. 安装中文字体
sudo apt install fonts-wqy-zenhei  

3.安装中文输入法
#sudo apt install fcitx5 fcitx5-chinese-addons fcitx5-frontend-gtk4 fcitx5-frontend-gtk3 fcitx5-frontend-gtk2  fcitx5-frontend-qt5 
sudo apt install fcitx5 fcitx5-chinese-addons
#修改XTerm字体大小
#Ctrl+鼠标Right Click。


#环境变量添加
sudo vim /etc/profile
#==============
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx

im-config #配置使用fcitx5 
#退出root用户权限，使用普通用户权限再终端
fcitx5-configtool #取消勾选Only show current language配置中文输入法即可
#附加组件-经典用户界面--这里可以修改字体及大小

#fcitx5自动开启
mkdir -p ~/.config/autostart && cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart
#安装火狐
sudo apt install firefox-esr
#git安装
sudo apt install git -y
#生成密钥并添加到github
ssh-keygen -t RSA -C "lwmfjc@gmail.com"
git config --global user.name "lwmfjc"
git config --global user.email lwmfjc@gmail.com
#.gitignore
#只上传cpp、java文件
*
!*.gitignore
?*.cpp
!*.java

```
