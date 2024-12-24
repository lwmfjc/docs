---
title: 16-18
description: 16-18
categories:
  - 学习
tags:
  - Linux
  - SHELL
date: 2024-12-24T09:46:52+08:00
lastmod: 2024-12-24T09:46:52+08:00
---
# 向bash脚本添加参数
## basic
```shell
─ ~/shellTest                   ly@vmmin 10:37:24
╰─❯ cat ./16myscript_cls.sh 
#!/bin/bash

echo "You entered the argument: $1,$2,$3, and $4."
```
结果  
```shell
╭─ ~/shellTest               16s ly@vmmin 10:37:18
╰─❯ ./16myscript_cls.sh Linux1 Linux2
You entered the argument: Linux1,Linux2,, and .
```
## 示例1
```shell
╭─ ~/shellTest                      ly@vmmin 10:41:45
╰─❯ cat ./16myscript_cls.sh 
#!/bin/bash

ls -lh $1

#echo "You entered the argument: $1,$2,$3, and $4."
╭─ ~/shellTest                        ly@vmmin 10:41:28
╰─❯ ./16myscript_cls.sh /etc
total 792K
-rw-r--r-- 1 root root   3.0K May 25  2023 adduser.conf
-rw-r--r-- 1 root root     44 Dec 17 15:26 adjtime
-rw-r--r-- 1 root root    194 Dec 23 22:38 aliases
drwxr-xr-x 2 root root   4.0K Dec 23 22:38 alternatives
drwxr-xr-x 2 root root   4.0K Dec 17 15:24 apparmor
drwxr-xr-x 8 root root   4.0K Dec 17 15:25 apparmor.d
drwxr-xr-x 9 root root   4.0K Dec 17 15:30 apt
-rw-r----- 1 root daemon  144 Oct 16  2022 at.deny
-rw-r--r-- 1 root root   2.0K Mar 30  2024 bash.bashrc
```
## 示例2
```shell
#!/bin/bash

lines=$(ls -lh $1 | wc -l) #行计数

echo "You hava $(($lines-1)) objects in the $1 directory."
#$(($lines-1))这里用到了子shell

#echo "You entered the argument: $1,$2,$3, and $4."

```

```shell
╭─ ~/shellTest                                 ly@vmmin 10:48:06
╰─❯ ls -lh logfiles 
total 12K
-rw-r--r-- 1 ly ly   0 Dec 22 23:07 a.log
-rw-r--r-- 1 ly ly 120 Dec 22 23:17 a.log.tar.gz
-rw-r--r-- 1 ly ly   0 Dec 22 23:07 b.log
-rw-r--r-- 1 ly ly 121 Dec 22 23:17 b.log.tar.gz
-rw-r--r-- 1 ly ly   0 Dec 22 23:07 c.log
-rw-r--r-- 1 ly ly 121 Dec 22 23:17 c.log.tar.gz
-rw-r--r-- 1 ly ly   0 Dec 22 23:15 xx.txt
-rw-r--r-- 1 ly ly   0 Dec 22 23:15 y.txt
╭─ ~/shellTest                                  ly@vmmin 10:48:10
╰─❯ ./16myscript_cls.sh logfiles
You hava 8 objects in the logfiles directory.
```
head，表示前十行，可以看出total这些被算作一行了，所以上面的shell中-1  
```shell
─ ~/shellTest                         ly@vmmin 10:57:19
╰─❯ ls -l /etc | head
total 792
-rw-r--r-- 1 root root    3040 May 25  2023 adduser.conf
-rw-r--r-- 1 root root      44 Dec 17 15:26 adjtime
-rw-r--r-- 1 root root     194 Dec 23 22:38 aliases
drwxr-xr-x 2 root root    4096 Dec 23 22:38 alternatives
drwxr-xr-x 2 root root    4096 Dec 17 15:24 apparmor
drwxr-xr-x 8 root root    4096 Dec 17 15:25 apparmor.d
drwxr-xr-x 9 root root    4096 Dec 17 15:30 apt
-rw-r----- 1 root daemon   144 Oct 16  2022 at.deny
-rw-r--r-- 1 root root    1994 Mar 30  2024 bash.bashrc
```
### 不输入参数的情形  
可以看出，其实就是应用到**当前文件夹**了  
```shell
╭─ ~/shellTest                                         ly@vmmin 11:02:35
╰─❯ ./16myscript_cls.sh logfiles
You hava 8 objects in the logfiles directory.
╭─ ~/shellTest                                        ly@vmmin 11:02:39
╰─❯ ./16myscript_cls.sh         
You hava 29 objects in the  directory.
╭─ ~/shellTest                                       ly@vmmin 11:02:44
╰─❯ ls -l | wc -l
30
```
### 参数判断
```shell
#!/bin/bash
#  $#表示用户传到脚本中的参数数量
if [ $# -ne 1 ] #[]左右两边都一定要有空格
then
    echo "This script requires xxxxone directory path passed to it."
    echo "Please try again."
    exit 1
fi

lines=$(ls -lh $1 | wc -l)

echo "You hava $(($lines-1)) objects in the $1 directory."

#echo "You entered the argument: $1,$2,$3, and $4."

```
执行  
```shell
╭─ ~/shellTest                                  4m 3s ly@vmmin 11:09:41
╰─❯ ./16myscript_cls.sh 
This script requires xxxxone directory path passed to it.
Please try again.
╭─ ~/shellTest                                    ly@vmmin 11:09:45
╰─❯ ./16myscript_cls.sh logfiles 
You hava 8 objects in the logfiles directory.
╭─ ~/shellTest                                    ly@vmmin 11:09:55
╰─❯ ./16myscript_cls.sh logfiles x b
This script requires xxxxone directory path passed to it.
Please try again.

```
# 创建备份脚本  
```shell
╭─ ~/shellTest                                    ly@vmmin 12:41:11
╰─❯ cat ./17myscript_cls.sh
#!/bin/bash
#如果参数个数不是2则退出，并指定exitCode为1
if [ $# -ne 2 ]
then
    echo "Usage: backup.sh <source_directory> <target_directory>"
    echo "Please try again."
    exit 1
fi

# check rsync installed
#发送标准错误和标准输出到/dev/null
#command -v rsync > /dev/null 2>&1 这条命令，若rsync存在则返回零（真），否则返回非零（假）
if ! command -v rsync > /dev/null 2>&1
then
    echo "This script requires rsync to be installed."
    echo "Please use your distribution's package manager to install it and try again."
    #指定exitCode
    exit 2
fi

#格式化date输出，即YYYY-MM-DD
current_date=$(date +%Y-%m-%d)

# -a 保留所有元数据，权限等
# -v 详细显示输出
#-b、--backup参数指定在删除或更新目标目录已经存在的文件时，将该文件更名后进行备份，默认行为是删除。更名规则是添加由--suffix参数指定的文件后缀名，默认是~。

#--backup-dir参数指定文件备份时存放的目录，比如--backup-dir=/path/to/backups
# --delete 确保目标目录是源目录的克隆（完全克隆，不多不少）
# --dry-run 尝试执行操作
rsync_options="-avb --backup-dir $2/$current_date --delete --dry-run"
#rsync_options="-avb --backup-dir $2/$current_date --delete "
# $1是源目录
$(which rsync) $rsync_options $1 $2/current >> backup_$current_date.log
```
## 运行脚本
会提示rsync还没有安装，需要安装  
```shell
╭─ ~/shellTest                                       ly@vmmin 14:41:04
╰─❯ nano 17myscript_cls.sh 
╭─ ~/shellTest                                    27s ly@vmmin 14:41:35
╰─❯ ./17myscript_cls.sh logfiles backup
╭─ ~/shellTest                                        ly@vmmin 14:41:45
╰─❯ ./17myscript_cls.sh logfiles/ backup
╭─ ~/shellTest                                        ly@vmmin 14:41:49
╰─❯ cat backup_2024-12-24.log 
sending incremental file list
created directory backup/current
logfiles/
logfiles/a.log
logfiles/a.log.tar.gz
logfiles/b.log
logfiles/b.log.tar.gz
logfiles/c.log
logfiles/c.log.tar.gz
logfiles/xx.txt
logfiles/y.txt

sent 279 bytes  received 81 bytes  720.00 bytes/sec
total size is 362  speedup is 1.01 (DRY RUN)
sending incremental file list
created directory backup/current
./
a.log
a.log.tar.gz
b.log
b.log.tar.gz
c.log
c.log.tar.gz
xx.txt
y.txt

sent 254 bytes  received 80 bytes  668.00 bytes/sec
total size is 362  speedup is 1.08 (DRY RUN)

```

backup是空白，因为这只是试运行  
```./17myscript_cls.sh logfiles backup```和```./17myscript_cls.sh logfiles/ backup```的区别，后者备份文件夹logfiles下所有文件，而前者备份```logfiles```(包括文件夹自身)整个文件夹  

## 把 ``` --dry-run```去掉后运行   
文件查看  
```shell
╭─ ~/shellTest                                        ly@vmmin 14:42:53
╰─❯ ls backup
╭─ ~/shellTest                                         ly@vmmin 14:43:03
╰─❯ nano 17myscript_cls.sh 
#第一次备份
╭─ ~/shellTest                                       8s ly@vmmin 14:43:17
╰─❯ ./17myscript_cls.sh logfiles/ backup
╭─ ~/shellTest                                           ly@vmmin 14:43:28
╰─❯ ls backup                
current
╭─ ~/shellTest                                            ly@vmmin 14:43:42
╰─❯ ls backup/current 
a.log  a.log.tar.gz  b.log  b.log.tar.gz  c.log  c.log.tar.gz  xx.txt  y.txt

```
日志查看  
```shell
╭─ ~/shellTest                                           ly@vmmin 14:43:46
╰─❯ cat backup_2024-12-24.log 
sending incremental file list
created directory backup/current
logfiles/
logfiles/a.log
logfiles/a.log.tar.gz
logfiles/b.log
logfiles/b.log.tar.gz
logfiles/c.log
logfiles/c.log.tar.gz
logfiles/xx.txt
logfiles/y.txt

sent 279 bytes  received 81 bytes  720.00 bytes/sec
total size is 362  speedup is 1.01 (DRY RUN)
sending incremental file list
created directory backup/current
./
a.log
a.log.tar.gz
b.log
b.log.tar.gz
c.log
c.log.tar.gz
xx.txt
y.txt

sent 254 bytes  received 80 bytes  668.00 bytes/sec
total size is 362  speedup is 1.08 (DRY RUN)
sending incremental file list
created directory backup/current
./
a.log
a.log.tar.gz
b.log
b.log.tar.gz
c.log
c.log.tar.gz
xx.txt
y.txt

sent 916 bytes  received 208 bytes  2,248.00 bytes/sec
total size is 362  speedup is 0.32
```
此时在logfiles里新建一个文件以及更新一个文件  
```shell
╭─ ~/shellTest                                   ly@vmmin 14:43:50
╰─❯ touch logfiles/testfile.txt
╭─ ~/shellTest                                   ly@vmmin 14:46:48
╰─❯ touch logfiles/a.log 
╭─ ~/shellTest                                   ly@vmmin 14:47:20
╰─❯ rm backup_2024-12-24.log 
#第二次备份
╭─ ~/shellTest                                   ly@vmmin 14:48:22
╰─❯ ./17myscript_cls.sh logfiles/ backup
╭─ ~/shellTest                                    ly@vmmin 14:49:16
╰─❯ cat backup_2024-12-24.log 
sending incremental file list
./
a.log
testfile.txt

sent 339 bytes  received 57 bytes  792.00 bytes/sec
total size is 362  speedup is 0.91

```
查看此时真实目录  
```shell
╭─ ~/shellTest                                         ly@vmmin 14:54:58
╰─❯ ls  
10_1myscript_cls.sh  17myscript_cls.sh  62myscript_cls.sh  91myscript_cls.sh
11_1myscript_cls.sh  2myscript_cls.sh   63myscript_cls.sh  92myscript_cls.sh
11_2myscript_cls.sh  31myscript_cls.sh  64myscript_cls.sh  backup
12myscript_cls.sh    32myscript_cls.sh  65myscript_cls.sh  backup_2024-12-24.log
13myscript_cls.sh    51myscript_cls.sh  71myscript_cls.sh  logfiles
14myscript_cls.sh    52myscript_cls.sh  72myscript_cls.sh  package_install_results.log
15myscript_cls.sh    53myscript_cls.sh  81myscript_cls.sh  package_isntall_failure.log
16myscript_cls.sh    61myscript_cls.sh  82myscript_cls.sh
╭─ ~/shellTest                                          ly@vmmin 14:55:37
╰─❯ ls backup/current 
a.log         backup  b.log.tar.gz  c.log.tar.gz  xx.txt
a.log.tar.gz  b.log   c.log         testfile.txt  y.txt
#这里会发现，他在替换成新文件前，把旧的文件拷贝到备份文件夹中了
╭─ ~/shellTest                                          ly@vmmin 14:55:42
╰─❯ ls backup/current/backup/2024-12-24 
a.log

```

我又修改了一次a.log，变成了这样(深层次)  
```shell
╭─ ~/shellTest                                        ly@vmmin 14:55:53
╰─❯ touch logfiles/a.log                
╭─ ~/shellTest                                           ly@vmmin 14:57:52
╰─❯ ./17myscript_cls.sh logfiles/ backup
╭─ ~/shellTest                                           ly@vmmin 14:57:57
╰─❯ cat backup_2024-12-24.log           
sending incremental file list
./
a.log
testfile.txt

sent 336 bytes  received 57 bytes  786.00 bytes/sec
total size is 362  speedup is 0.92
sending incremental file list
deleting backup/2024-12-24/a.log
cannot delete non-empty directory: backup/2024-12-24
cannot delete non-empty directory: backup
a.log

sent 295 bytes  received 165 bytes  920.00 bytes/sec
total size is 362  speedup is 0.79
╭─ ~/shellTest                                       ly@vmmin 14:58:00
╰─❯ ls backup/current/backup/2024-12-24 
a.log  backup #注意，这里对a.log又进行了backup备份
╭─ ~/shellTest                                       ly@vmmin 14:58:17
╰─❯ ls backup/current/backup/2024-12-24/backup 
2024-12-24
╭─ ~/shellTest                                                              ly@vmmin 14:58:23
╰─❯ ls backup/current/backup/2024-12-24/backup/2024-12-24 
a.log
```
# 继续Linux的学习
1. https://ubuntuserverbook.com/ 作者写的书
2. https://www.youtube.com/c/LearnLinuxTV 作者的y2b
3. https://learnlinux.tv 作者的网站