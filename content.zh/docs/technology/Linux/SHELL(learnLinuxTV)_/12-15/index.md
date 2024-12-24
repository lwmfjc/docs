---
title: 12-15
description: 12-15
categories:
  - 学习
tags:
  - SHELL
  - Linux
date: 2024-12-23T21:03:03+08:00
lastmod: 2024-12-23T21:03:03+08:00
---
# functions 函数
以```update```这个脚本为基础编改  
作用  
- 减少重复代码

```shell
#!/bin/bash

release_file=/etc/os-release
logfile=/var/log/updater.log
errorlog=/var/log/updater_errors.log

check_exit_status(){
    if [ $? -ne 0 ]
    then
        echo "An error occured,please check the $errorlog file."
    fi
}

if  grep -q "Arch" $release_file 
then
    sudo pacman -Syu 1>>$logfile 2>>$errorlog
    check_exit_status
fi

if grep -q "Ubuntu" $release_file ||  grep -q "Debian" $release_file 
then
    sudo apt update 1>>$logfile 2>>$errorlog
    check_exit_status
    #默认yes
    sudo apt dist-upgrade -y 1>>$logfile 2>>$errorlog
    check_exit_status
fi
```
# CaseStatements
## 脚本
```shell
╭─ ~/shellTest                                                              ly@vmmin 22:32:52
╰─❯ cat ./13myscript_cls.sh 
#!/bin/bash

finished=0

while [ $finished -ne 1 ]
do
    echo "What is your favorite Linux distribution?"
    
    echo "1 - Arch"
    echo "2 - CentOS"
    echo "3 - Debian"
    echo "4 - Mint"
    echo "5 - Something else.."
    echo "6 - exit"
    
    read distro;
    case $distro in 
      1) echo "Arch is xxx";;
      2) echo "CentOS is xbxxx";;
      3) echo "Debian is bbbxx";;
      4) echo "Mint is xxxxsss";;
      5) echo "Something els.xxxxx";;
      6) finished=1
         echo "now will exit"
         ;;
      *) echo "you didn't enter an xxxx choice."
    esac
done

echo "Thanks for using this script."
```

## 脚本执行
```shell
╭─ ~/shellTest                                                              ly@vmmin 22:32:11
╰─❯ ./13myscript_cls.sh   
What is your favorite Linux distribution?
1 - Arch
2 - CentOS
3 - Debian
4 - Mint
5 - Something else..
6 - exit
3
Debian is bbbxx
What is your favorite Linux distribution?
1 - Arch
2 - CentOS
3 - Debian
4 - Mint
5 - Something else..
6 - exit
u
you didn't enter an xxxx choice.
What is your favorite Linux distribution?
1 - Arch
2 - CentOS
3 - Debian
4 - Mint
5 - Something else..
6 - exit
6
now will exit
Thanks for using this script. 
```

# ScheduleJobs
## 作用
脚本在特定时间运行  
## 安装
```shell
─ ~/shellTest                                 ly@vmmin 22:37:20
╰─❯ which at
at not found
╭─ ~/shellTest                                 ly@vmmin 22:37:23
╰─❯ sudo apt install at
```
## 查看
```shell
─ ~/shellTest                                 28s ly@vmmin 22:38:59
╰─❯ which at
/usr/bin/at
```
## 示例
```shell
╰─❯ cat 14myscript_cls.sh
#!/bin/bash

logfile=job_results.log

echo "The script ran at the following time: $(date)" > $logfile
╭─ ~/shellTest                                      ly@vmmin 23:06:05
╰─❯ date
Mon Dec 23 11:06:06 PM CST 2024
╭─ ~/shellTest                                      ly@vmmin 23:06:06
╰─❯ at 23:07 -f /home/ly/shellTest/14myscript_cls.sh 
warning: commands will be executed using /bin/sh
job 1 at Mon Dec 23 23:07:00 2024
╭─ ~/shellTest                                         ly@vmmin 23:06:34
╰─❯ cat job_results.log 
The script ran at the following time: Mon Dec 23 11:01:23 PM CST 2024
╭─ ~/shellTest                                       ly@vmmin 23:06:46
╰─❯ cat job_results.log
The script ran at the following time: Mon Dec 23 11:07:00 PM CST 2024
╭─ ~/shellTest                                   ly@vmmin 23:07:03
╰─❯ date
Mon Dec 23 11:07:10 PM CST 2024

```

## 解释
```at 23:07 -f /home/ly/shellTest/14myscript_cls.sh ```  
23:07没给日期说明是今天，-f表示运行的是一个文件  
## 查看待运行任务
```shell
╭─ ~/shellTest                                   ly@vmmin 23:10:53
╰─❯ at 23:12 -f ./14myscript_cls.sh
warning: commands will be executed using /bin/sh
job 2 at Mon Dec 23 23:12:00 2024
╭─ ~/shellTest                              ly@vmmin 23:11:02
╰─❯ atq                            
2	Mon Dec 23 23:12:00 2024 a ly
╭─ ~/shellTest                                      ly@vmmin 23:11:04
╰─❯ at 23:13 -f ./14myscript_cls.sh
warning: commands will be executed using /bin/sh
job 3 at Mon Dec 23 23:13:00 2024
╭─ ~/shellTest                                           ly@vmmin 23:11:12
╰─❯ atq                            
3	Mon Dec 23 23:13:00 2024 a ly
2	Mon Dec 23 23:12:00 2024 a ly

```
## 删除作业
```shell
╭─ ~/shellTest                                     ly@vmmin 23:13:09
╰─❯ at 23:15 -f ./14myscript_cls.sh
warning: commands will be executed using /bin/sh
job 4 at Mon Dec 23 23:15:00 2024
╭─ ~/shellTest                                       ly@vmmin 23:13:14
╰─❯ at 23:16 -f ./14myscript_cls.sh
warning: commands will be executed using /bin/sh
job 5 at Mon Dec 23 23:16:00 2024
╭─ ~/shellTest                                      ly@vmmin 23:13:20
╰─❯ atq
5	Mon Dec 23 23:16:00 2024 a ly
4	Mon Dec 23 23:15:00 2024 a ly
╭─ ~/shellTest                                    ly@vmmin 23:13:24
╰─❯ atrm 4
╭─ ~/shellTest                                    ly@vmmin 23:13:31
╰─❯ atq   
5	Mon Dec 23 23:16:00 2024 a ly
```
## 日期
```shell
╭─ ~/shellTest                                        ly@vmmin 23:13:33
╰─❯ atq   
5	Mon Dec 23 23:16:00 2024 a ly
╭─ ~/shellTest                                            ly@vmmin 23:14:52
╰─❯ at 23:16 122424 -f ./14myscript_cls.sh
warning: commands will be executed using /bin/sh
job 6 at Tue Dec 24 23:16:00 2024
╭─ ~/shellTest                                             ly@vmmin 23:15:08
╰─❯ atq                                   
5	Mon Dec 23 23:16:00 2024 a ly
6	Tue Dec 24 23:16:00 2024 a ly
```
# CronJobs
## 命令的完整路径
安排你的bash脚本，在将来的某个时间执行  
下面使用完全限定名  
```shell
╭─ ~/shellTest               19s ly@vmmin 09:08:02
╰─❯ cat 15myscript_cls.sh 
#!/bin/bash

logfile=job_results.log

/usr/bin/echo "The script ran at the following time: $(/uar/bin/date)" > $logfile
╭─ ~/shellTest                   ly@vmmin 09:08:06
╰─❯ 
```

which查看命令   
```shell
ly@vmmin:~/shellTest$ which echo
/usr/bin/echo
ly@vmmin:~/shellTest$ which date
/usr/bin/date
```
能够保持**安全性**，还有涉及到路径变量（**没法找到，或者找错**）  
## 编辑任务
```shell
╭─ ~/shellTest                   ly@vmmin 09:17:35
╰─❯ crontab -e
no crontab for ly - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny

Choose 1-3 [1]: 1
#之后会进入nano编辑器并编辑/tmp/crontab.I0AOMk/crontab这个文件（用户自己的，不会干扰其他用户）(crontab.I0AOMk这个文件夹每次都不确定，每次运行crontab -e都是不同文件夹，不过crontab文件内容会跟上次的一样)
```
编辑内容  
```shell
# For more information see the manual pages of cro>
# 
# m h  dom mon dow   command
30 1 * * 5 /home/ly/shellTest/15myscript_cls.sh
```
- 30分钟时执行(每一个小时，即0:30,1:30,2:30），后面两个星号，表示一个月中几号，每年的哪个月，最后这个5表示每星期几（这里是星期五，0跟7都代表星期日）。  
- 这个脚本的意思，每周五凌晨1点30分运行  
```30 1 10 7 4 /home/ly/shellTest/15myscript_cls.sh```，如果改成这样，则运行的概率极低。即 每年7月10号且星期四，那天里每一个小时到达30分时执行
```shell
#用root用户为某个用户创建任务，不存在则创建新文件并编辑任务，存在则继续编辑之前的任务文件  
sudo crontab -u ly -e
```
