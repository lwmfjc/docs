---
title: 11DataStreams
description: 11DataStreams
categories: 
tags: 
date: 2024-12-23T12:12:45+08:00
lastmod: 2024-12-23T12:12:45+08:00
---
> **下面的输出中，涉及到标准输出的，有十几行的那些，只列举了其中四五行**  
# 概念
- 标准输入，标准输出，标准错误  
- 标准输出：打印到屏幕上的输出  
```shell
╭─ ~                   ly@vmmin 12:31:44
╰─❯ ls
content.zh  index.html  myfile
dufs.log    install.sh  shellTest
╭─ ~                   ly@vmmin 12:32:21
╰─❯ echo $?
0
```
- 标准错误  
```shell
╭─ ~                   ly@vmmin 12:30:27
╰─❯ ls /notexist
ls: cannot access '/notexist': No such file or directory
╭─ ~                   ly@vmmin 12:30:59
╰─❯ echo $?
2
```

# 标准输出和标准错误
## 部分重定向
### 标准错误重定向 2>
> find，文件系统  
> find /etc -type f


```shell
## 下面是附加知识，最后没用到
#新建一个用户，-m 让用户具有默认主目录，-d指定目录，-s指定用户登入后所使用的shell
sudo useradd -d /home/ly1 -s /bin/bash -m ly1
#设置密码
sudo passwd ly1
```

为了演示错误，先创建几个文件   
```shell
root@vmmin:/home/ly# mkdir a && touch a/a1.txt a/a2.txt
root@vmmin:/home/ly# mkdir b && touch b/b1.txt b/b2.txt 
#去除所在组和其他人的所有权限
root@vmmin:/home/ly# chmod 700 a
root@vmmin:/home/ly# chmod 700 b
╭─ ~                          ly@vmmin 17:02:36
╰─❯ ls -l
total 80
drwx------ 2 root root  4096 Dec 23 16:13 a
-rw-r--r-- 1 ly   ly   17006 Dec 23 16:04 abc.txt
drwx------ 2 root root  4096 Dec 23 16:13 b
drwxr-xr-x 3 ly   ly    4096 Dec 18 17:33 content.zh
-rw-r--r-- 1 ly   ly      90 Dec 20 11:20 dufs.log
-rw-r--r-- 1 ly   ly   19786 Dec 17 23:54 index.html
-rw-r--r-- 1 ly   ly   18369 Dec 19 15:01 install.sh
-rw-r--r-- 1 ly   ly       0 Dec 20 22:27 myfile
drwxr-xr-x 3 ly   ly    4096 Dec 23 10:34 shellTest
```
用root账号，在/home/ly下面创建了a，b文件夹，以及a1.txt，a2.txt，b1.txt，b2.txt  
，a，b文件夹的权限均为```700```  

使用find查找，会出现Permission错误  
这里使用``` -not -path "/home/ly/.**" ```忽略点开头的文件
```shell
╭─ ~                                     ly@vmmin 17:02:38
╰─❯ find ~ -type f -not -path "/home/ly/.**"          
find: ‘/home/ly/a’: Permission denied
/home/ly/dufs.log
find: ‘/home/ly/b’: Permission denied
/home/ly/index.html
/home/ly/abc.txt
/home/ly/shellTest/2myscript_cls.sh
/home/ly/shellTest/82myscript_cls.sh
/home/ly/shellTest/62myscript_cls.sh
/home/ly/shellTest/31myscript_cls.sh
/home/ly/shellTest/92myscript_cls.sh  
```
忽略显示错误的信息  
```shell
╭─ ~                             ly@vmmin 17:05:37
╰─❯ find ~ -type f -not -path "/home/ly/.**" 2> /dev/null
/home/ly/dufs.log
/home/ly/index.html
/home/ly/abc.txt
/home/ly/shellTest/2myscript_cls.sh
/home/ly/shellTest/82myscript_cls.sh
/home/ly/shellTest/62myscript_cls.sh
/home/ly/shellTest/31myscript_cls.sh
/home/ly/shellTest/92myscript_cls.sh
/home/ly/shellTest/61myscript_cls.sh
/home/ly/shellTest/32myscript_cls.sh
/home/ly/shellTest/64myscript_cls.sh
/home/ly/shellTest/65myscript_cls.sh
/home/ly/shellTest/53myscript_cls.sh
/home/ly/shellTest/72myscript_cls.sh
/home/ly/shellTest/52myscript_cls.sh
/home/ly/shellTest/81myscript_cls.sh
╭─ ~                                                                        ly@vmmin 17:05:47
╰─❯ echo $?
1
```

```echo $?```结果为1说明其实出错了，但是没有显示。  
> \>号用来重定向
> /dev/null  dev null  
> 构成错误-标准错误的每一行将被发送到Dev null而不是屏幕

### 标准输出重定向1>或>
```shell
╭─ ~                                  ly@vmmin 17:12:43
╰─❯ find ~ -type f -not -path "/home/ly/.**" > /dev/null 
find: ‘/home/ly/a’: Permission denied
find: ‘/home/ly/b’: Permission denied
```
1> 和 > 是一样的结果，都是重定向标准输出
```shell
╭─ ~                                  ly@vmmin 17:12:43
╰─❯ find ~ -type f -not -path "/home/ly/.**" 1> /dev/null 
find: ‘/home/ly/a’: Permission denied
find: ‘/home/ly/b’: Permission denied
```
#### 重定向到文件
```shell
╭─ ~                               ly@vmmin 17:15:07
╰─❯ find ~ -type f -not -path "/home/ly/.**" 1> file.txt  
find: ‘/home/ly/a’: Permission denied
find: ‘/home/ly/b’: Permission denied
╭─ ~                                         ly@vmmin 17:16:35
╰─❯ cat file.txt 
/home/ly/dufs.log
/home/ly/index.html
/home/ly/file.txt
/home/ly/abc.txt
/home/ly/shellTest/2myscript_cls.sh
/home/ly/shellTest/82myscript_cls.sh
/home/ly/shellTest/62myscript_cls.sh
/home/ly/shellTest/31myscript_cls.sh
/home/ly/shellTest/92myscript_cls.sh
/home/ly/shellTest/61myscript_cls.sh
/home/ly/shellTest/32myscript_cls.sh
/home/ly/shellTest/64myscript_cls.sh
/home/ly/shellTest/65myscript_cls.sh
/home/ly/shellTest/53myscript_cls.sh 
```

## 同时重定向标准输出和标准错误
### 同时重定向到一个
> 在Shell中，标准错误写法为 2>, 标准输出为 1> 或者 >。如要要将标准输出和标准错误合二为一，都重定向到同一个文件，可以使用下面两种方式:  
#### &>
```shell
╭─ ~                                         ly@vmmin 17:22:07
╰─❯ find ~ -type f -not -path "/home/ly/.**" &> file.txt
╭─ ~                                        ly@vmmin 17:22:14
╰─❯ cat file.txt 
find: ‘/home/ly/a’: Permission denied
/home/ly/dufs.log
find: ‘/home/ly/b’: Permission denied
/home/ly/index.html
/home/ly/file.txt
/home/ly/abc.txt
/home/ly/shellTest/2myscript_cls.sh
/home/ly/shellTest/82myscript_cls.sh
/home/ly/shellTest/62myscript_cls.sh
/home/ly/shellTest/31myscript_cls.sh
/home/ly/shellTest/92myscript_cls.sh
/home/ly/shellTest/61myscript_cls.sh
```
#### 2>&1
```shell
╭─ ~                                                                        ly@vmmin 17:24:41
╰─❯ find ~ -type f -not -path "/home/ly/.**" > file.txt 2>&1
╭─ ~                                                                        ly@vmmin 17:24:57
╰─❯ cat file.txt 
find: ‘/home/ly/a’: Permission denied
/home/ly/dufs.log
find: ‘/home/ly/b’: Permission denied
/home/ly/index.html
/home/ly/file.txt
/home/ly/abc.txt
/home/ly/shellTest/2myscript_cls.sh
/home/ly/shellTest/82myscript_cls.sh
/home/ly/shellTest/62myscript_cls.sh
/home/ly/shellTest/31myscript_cls.sh
/home/ly/shellTest/92myscript_cls.sh
```

### 一条语句分别重定向到多个
```shell
╭─ ~                                        ly@vmmin 17:30:48
╰─❯ find ~ -type f -not -path "/home/ly/.**" 1>find_results.txt 2>find_errors.txt
╭─ ~                                        ly@vmmin 17:31:06
╰─❯ cat find_results.txt 
/home/ly/dufs.log
/home/ly/index.html
/home/ly/file.txt
/home/ly/abc.txt
/home/ly/shellTest/2myscript_cls.sh
/home/ly/shellTest/82myscript_cls.sh
/home/ly/shellTest/62myscript_cls.sh
/home/ly/shellTest/31myscript_cls.sh
/home/ly/shellTest/92myscript_cls.sh
/home/ly/shellTest/61myscript_cls.sh
/home/ly/shellTest/32myscript_cls.sh
/home/ly/shellTest/64myscript_cls.sh 
╭─ ~                                                                        ly@vmmin 17:31:24
╰─❯ cat find_errors.txt 
find: ‘/home/ly/a’: Permission denied
find: ‘/home/ly/b’: Permission denied

```

也可以使用```find ~ -type f -not -path "/home/ly/.**" >find_results.txt 2>find_errors.txt```  
# update脚本（之前的）

```shell
╭─ ~                                    ly@vmmin 17:36:08
╰─❯ cat /usr/local/bin/update 
#!/bin/bash

release_file=/etc/os-release

if  grep -q "Arch" $release_file 
then
    sudo pacman -Syu
fi

if grep -q "Ubuntu" $release_file ||  grep -q "Debian" $release_file 
then
    sudo apt update
    sudo apt dist-upgrade
fi 
```
修改  
```shell
╭─ ~/shellTest                                  ly@vmmin 17:46:55
╰─❯ cat 11_1_1myscript_cls.sh 
#!/bin/bash 
release_file=/etc/os-release
logfile=/var/log/updater.log
errorlog=/var/log/updater_errors.log
if  grep -q "Arch" $release_file 
then
    sudo pacman -Syu 1>>$logfile 2>>$errorlog
    if [ $? -ne 0 ]
    then
        echo "An error occured,please check the $errorlog file."
    fi
fi

if grep -q "Ubuntu" $release_file ||  grep -q "Debian" $release_file 
then
    sudo apt update 1>>$logfile 2>>$errorlog
    if [ $? -ne 0 ]
    then
        echo "An error occured,please check the $errorlog file."
    fi

    sudo apt dist-upgrade -y 1>>$logfile 2>>$errorlog
    if [ $? -ne 0 ]
    then
        echo "An error occured,please check the $errorlog file."
    fi
fi 
```

切换到root用户并执行  
```shell
╭─ ~/shellTest                                     ly@vmmin 17:50:25
╰─❯ su root -
Password: 
root@vmmin:/home/ly/shellTest# ./11_1_1myscript_cls.sh 
```
查看  
```shell
#root用户下
root@vmmin:/home/ly/shellTest# cat /var/log/updater.log
Hit:1 https://mirrors.tuna.tsinghua.edu.cn/debian bookworm InRelease
Hit:2 https://mirrors.tuna.tsinghua.edu.cn/debian bookworm-updates InRelease
Hit:3 https://mirrors.tuna.tsinghua.edu.cn/debian bookworm-backports InRelease
Hit:4 https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security InRelease
Hit:5 https://security.debian.org/debian-security bookworm-security InRelease
Reading package lists...
Building dependency tree...
Reading state information...
All packages are up to date.
Reading package lists...
Building dependency tree...
Reading state information...
Calculating upgrade...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
root@vmmin:/home/ly/shellTest# cat var/log/updater_errors.log
cat: var/log/updater_errors.log: No such file or directory
#这里没有出错，所以甚至连错误文件都没有  
```
附加知识，监听文本文件  
```shell
╭─  ~                 ly@vmmin 18:00:17
╰─❯ sudo tail -f /var/log/updater.log
Hit:5 https://security.debian.org/debian-security bookworm-security InRelease
Reading package lists...
Building dependency tree...
Reading state information...
All packages are up to date.
Reading package lists...
Building dependency tree...
Reading state information...
Calculating upgrade...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.

```
# 标准输入
```shell
╭─ ~/shellTest                            5s ly@vmmin 18:07:53
╰─❯ cat 11_2myscript_cls.sh 
#!/bin/bash

echo "Please enter your name:"
read myname
echo "Your name is: $myname"

╭─ ~/shellTest                            1m 6s ly@vmmin 18:07:42
╰─❯ ./11_2myscript_cls.sh 
Please enter your name:
JayH
Your name is: JayH

```