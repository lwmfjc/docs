---
title: 01基础知识
description: 01基础知识
categories:
  - 学习
tags:
  - 施磊
  - MySQL高级
date: 2025-03-15T19:46:15+08:00
lastmod: 2025-03-15T19:46:15+08:00
cssclasses:
  - book01
cssAttach:
  - book01
---
# 本课程大纲
![](img/ly-20250315194748427.png)  
# 部分扩展知识
MySQL分为服务端和客户端（两进程），SQLite是进程程序，客户端和服务端都在同一个进程操作数据
# 安装(windows)
安装目录下包括数据目录(Data/)和配置文件(my.ini)
# 安装(debian)
## 数据目录
```shell
root@db211:/etc/mysql# ls -l /var/lib/mysql | awk '{print $1,$3,$4,$9}'
total   
-rw-r----- mysql mysql auto.cnf
-rw------- mysql mysql ca-key.pem
-rw-r--r-- mysql mysql ca.pem
-rw-r--r-- mysql mysql client-cert.pem
-rw------- mysql mysql client-key.pem
-rw-r----- mysql mysql ib_buffer_pool
-rw-r----- mysql mysql ibdata1
-rw-r----- mysql mysql ib_logfile0
-rw-r----- mysql mysql ib_logfile1
-rw-r----- mysql mysql ibtmp1
drwxr-x--- mysql mysql mysql
drwxr-x--- mysql mysql performance_schema
-rw------- mysql mysql private_key.pem
-rw-r--r-- mysql mysql public_key.pem
-rw-r--r-- mysql mysql server-cert.pem
-rw------- mysql mysql server-key.pem
drwxr-x--- mysql mysql sys
drwxr-x--- mysql mysql xx
```
## 配置目录
```shell
root@db211:/etc/mysql# ls -l | awk '{print $1,$9,$10,$11}'
total   
drwxr-xr-x conf.d  
lrwxrwxrwx my.cnf -> /etc/alternatives/my.cnf
-rw-r--r-- my.cnf.fallback  
-rw-r--r-- mysql.cnf  
drwxr-xr-x mysql.conf.d
```
再进一步查看  
```shell
ls -l /etc/alternatives/my.cnf | awk '{print $1,$9,$10,$11}'
lrwxrwxrwx /etc/alternatives/my.cnf -> /etc/mysql/mysql.cnf
```
也就是说，`/etc/mysql/my.cnf`最终指向了`/etc/mysql/mysql.cnf`文件  
```shell
root@db211:/etc/mysql# ls conf.d
mysql.cnf
root@db211:/etc/mysql# ls mysql.conf.d/
mysqld.cnf
root@db211:/etc/mysql# cat mysql.cnf 
# Copyright (c) 2016, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2.0,
# as published by the Free Software Foundation.
#
# This program is also distributed with certain software (including
# but not limited to OpenSSL) that is licensed under separate terms,
# as designated in a particular file or component or in included license
# documentation.  The authors of MySQL hereby grant you an additional
# permission to link the program and your derivative works with the
# separately licensed software that they have included with MySQL.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License, version 2.0, for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
```
而my.cnf这个文件，包含了`/etc/mysql/conf.d`和`/etc/mysql/mysql.conf.d`这两个目录下所有的配置文件  
查看一下这两个目录下的文件  
第一个，没东西  
```shell
root@db211:/etc/mysql# cat /etc/mysql/conf.d/mysql.cnf 
# Copyright (c) 2015, 2016, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2.0,
# as published by the Free Software Foundation.
#
# This program is also distributed with certain software (including
# but not limited to OpenSSL) that is licensed under separate terms,
# as designated in a particular file or component or in included license
# documentation.  The authors of MySQL hereby grant you an additional
# permission to link the program and your derivative works with the
# separately licensed software that they have included with MySQL.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License, version 2.0, for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Client configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysql]
```
第二个，包括了部分配置  
```shell
root@db211:/etc/mysql# cat /etc/mysql/mysql.conf.d/mysqld.cnf 
# Copyright (c) 2014, 2016, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2.0,
# as published by the Free Software Foundation.
#
# This program is also distributed with certain software (including
# but not limited to OpenSSL) that is licensed under separate terms,
# as designated in a particular file or component or in included license
# documentation.  The authors of MySQL hereby grant you an additional
# permission to link the program and your derivative works with the
# separately licensed software that they have included with MySQL.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License, version 2.0, for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file	= /var/run/mysqld/mysqld.pid
socket		= /var/run/mysqld/mysqld.sock
datadir		= /var/lib/mysql
log-error	= /var/log/mysql/error.log
# By default we only accept connections from localhost
#bind-address	= 127.0.0.1
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
```
猜测一个是客户端配置，一个是服务端配置。且之所以设置了`/etc/mysql/my.cnf`链接文件，可能是为了兼容旧版本代码
# 完整性约束
![](img/ly-20250316000306769.png)  
# 三大范式

> 视频内容来自 https://www.cnblogs.com/CareySon/archive/2010/02/16/1668803.html#!comments 
## 1NF 
原子性
一列只能表示一个意思  
- 列值不可再分（含义上）  
- 数据类型一致
## 2NF 
针对联合主键：属性完全依赖（全部）的联合主键，而不是只依赖其中一个  
![](img/ly-20250316135910147.png)
## 3NF
非主属性不依赖于其他非主属性  
![](img/ly-20250316140001950.png)
## BCNF(不常用)
问题：非主属性决定了主属性（主属性依赖于其他非主属性）   ![](img/ly-20250316140246606.png)
![](img/ly-20250316131354594.png)    
![](img/ly-20250316162246207.png)
学生和科目，共同决定了任课老师。但是任课老师也决定了科目，但是任课老师并不是主键，拆分  
![](img/ly-20250316131500120.png)
## 4NF 
消除表中多值依赖  
- 单行改多行存储
![](img/ly-20250316165408866.png)
- 无关的列分表  
![](img/ly-20250316163831471.png)
