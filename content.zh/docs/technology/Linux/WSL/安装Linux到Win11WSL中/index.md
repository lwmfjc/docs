---
title: 安装Linux到Win11WSL中
description: 安装Linux到Win11WSL中
categories:
  - 学习
tags:
  - CMake
  - ChatGPTGuides
date: 2026-09-13T15:12:42+08:00
lastmod: 2026-09-13T15:12:42+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# Debian13

下载地址： https://raw.githubusercontent.com/debuerreotype/docker-debian-artifacts/dist-amd64/trixie/oci/blobs/rootfs.tar.gz  

```bash
#安装
wsl --import Debian13_1 E:\WSL\Debian13_1 D:\software\WSLInstall\debian13-rootfs.tar.gz  --version 2
#查看有哪些发行版
PS C:\Users\ly\MyHello> wsl -l -v
  NAME         STATE           VERSION
* Debian13_1    Stopped         2
#进入wsl的debian系统
PS C:\Users\ly\MyHello> wsl -d Debian13_1
root@DESKTOP-F0V2VF4:/mnt/c/Users/ly/MyHello#
```

## 修改源

修改一下源为清华源(http)

```bash
#root用户下
cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
cat > /etc/apt/sources.list.d/debian.sources <<'EOF'
Types: deb
URIs: http://mirrors.tuna.tsinghua.edu.cn/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://mirrors.tuna.tsinghua.edu.cn/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

apt update
apt upgrade -y

```

## 证书处理

```
apt install -y ca-certificates
update-ca-certificates
sed -i 's#http://mirrors.tuna.tsinghua.edu.cn#https://mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list.d/debian.sources

apt update
apt upgrade -y
```

## 新增用户

```shell
#备用命令，通过命令行直接用root（无密码）进入系统
wsl -d Debian-13 -u root

#新增用户
apt install -y sudo
apt install -y adduser
adduser ly
#这里会输入一堆东西，都可以enter跳过（我输入了FullName）
usermod -aG sudo ly

apt install nano vim -y
nano /etc/wsl.conf
#写入
#修改为  
[user]
default=ly

[boot]
systemd=true

[network]
hostname=debian13
generateHosts=false


#修改主机名
echo debian13 | sudo tee /etc/hostname 

#解决unable to resolve host debian13: Name or service not known
sudo vim /etc/hosts
#添加一行：
127.0.1.1       debian13

#关机然后重进
wsl --shutdown
wsl -d Debian

wsl -d Debian13_1

#修改bashrc修改默认进入时的目录
vim ~/.bashrc

最后一行添加：cd ~


```

## 可以ping
`
```bash
sudo apt install -y iputils-ping
sudo apt install -y libcap2-bin
sudo setcap cap_net_raw+ep $(which ping)
#debconf: falling back to frontend: Teletype #表示因为没有界面所以显示文字提示
```

## 安装其他东西

```bash
sudo apt install -y \
    iputils-ping \
    iproute2 \
    dnsutils \
    net-tools \
    curl \
    wget
```

```bash
sudo apt update

sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    gdb \
    git \
    pkg-config \
    make \
    gcc \
    g++ \
    libc6-dev \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    curl \
    wget \
    unzip \
    zip \
    tree \
    file \
    vim \
    nano
```

| 软件                | 用途                   |
| ----------------- | -------------------- |
| `gcc`             | C 编译器                |
| `g++`             | C++ 编译器              |
| `make`            | Make 构建工具            |
| `build-essential` | C/C++ 基础开发工具集合       |
| `cmake`           | CMake 构建系统           |
| `ninja-build`     | Ninja 构建工具，CMake 很常用 |
| `gdb`             | C/C++ 调试器            |
| `git`             | Git 版本控制             |
| `pkg-config`      | 查找和配置依赖库             |
| `libc6-dev`       | C 标准库开发文件            |
| `python3`         | Python               |
| `python3-pip`     | Python 包管理           |
| `python3-venv`    | Python 虚拟环境          |
| `curl` / `wget`   | 下载工具                 |
| `tree`            | 查看项目目录结构             |


## python安装

```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv
```

给项目创建虚拟环境  

```bash
cd ~
python3 -m venv .venv
source ~/.venv/bin/activate #激活 
python -m pip install openai
deactivate

```

## 拷贝远程机器的目录到本机

```bash
scp -P 22 -r ly@192.168.6.208:/home/ly/ly_vscode .
```

## 语言问题

```bash
sudo apt update
sudo apt install -y locales

sudo vim /etc/locale.gen
# en_US.UTF-8 UTF-8
# zh_CN.UTF-8 UTF-8
#上面的两行取消注释

sudo locale-gen 
locale -a
C
C.utf8
en_US.utf8
POSIX
zh_CN.utf8
ly@debian13:~$ sudo update-locale LANG=en_US.UTF-8

```

## ssh

如果还没安装：

```
sudo apt install -y openssh-server
```

启动：

```
sudo service ssh start
systemctl is-enabled ssh
```

检查：

```
ss -tlnp | grep ':22'
```

应该看到类似：

```
LISTEN 0 128 0.0.0.0:22
```


### 修改端口

可以不做 ~~推荐，以免和物理机主机冲突~~ 

```bash
sudo vim /etc/ssh/sshd_config
#Port 22
#修改为
Port 2201
```

## 修改为DHCP分配ip

让局域网内其他机器访问虚拟机及其开放的端口

```bash
#修改C:\Users\你的用户名\.wslconfig
[wsl2]

# 让 WSL 使用镜像网络模式，使 WSL 能够更直接地参与宿主机网络
networkingMode=mirrored

[experimental]

# 允许 WSL 使用 Windows 主机的 IP 地址访问 WSL 中的服务
hostAddressLoopback=true


#然后重启虚拟机
#此时已经获取到了动态ip

```

## http端口访问限制

```shell
#以下都在window powershell的管理员权限下访问
#添加
New-NetFirewallHyperVRule `
    -Name "WSL-HTTP-8080" `
    -DisplayName "WSL HTTP 8080" `
    -Direction Inbound `
    -VMCreatorId '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' `
    -Protocol TCP `
    -LocalPorts 8080
    
    
#查看某一条
Get-NetFirewallHyperVRule -Name "WSL-HTTP-8080" |
    Format-List *
    
#按端口查
Get-NetFirewallHyperVRule |
    Where-Object { $_.LocalPorts -contains "8080" } |
    Format-List *
    
#删除某个端口规则
Remove-NetFirewallHyperVRule -Name "WSL-HTTP-8080"

#一次性查清所有WSL-开头的规则
Get-NetFirewallHyperVRule |
    Where-Object {
        $_.Name -like "WSL-*"
    } |
    Format-Table Name,DisplayName,Direction,Protocol,LocalPorts,Action,Enabled
    
#端口测试
Test-NetConnection 192.168.6.201 -Port 8080

#开放所有端口
New-NetFirewallHyperVRule `
    -Name "WSL-All-TCP" `
    -DisplayName "WSL All TCP Ports" `
    -Direction Inbound `
    -VMCreatorId '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' `
    -Protocol TCP `
    -LocalPorts 1-65535
    #范围 -LocalPorts 2201,8080,3000,5000
    
#查看VMWAREid（有规则的情况下）
Get-NetFirewallHyperVRule |
    Select-Object -ExpandProperty VMCreatorId -Unique
#查看目前虚拟机有哪些规则
Get-NetFirewallHyperVRule |
    Where-Object {
        $_.VMCreatorId -eq "{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}"
    } |
    Format-Table Name,DisplayName,Direction,Protocol,LocalPorts,RemoteAddresses,Action,Enabled
    
#查看VMWARE ID--多个 WSL 发行版共用一个 VMCreatorId
Get-NetFirewallHyperVVMCreator

```


# Ubuntu

到这里下载wsl镜像： https://releases.ubuntu.com/noble/?utm_source=chatgpt.com  

```
wsl --install --from-file D:\software\WSLInstall\ubuntu-24.04.5-wsl-amd64.wsl --location E:\WSL\Ubuntu-24.04
```
