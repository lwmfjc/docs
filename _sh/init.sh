#!/bin/bash 
#用来启动dufs，一级给dufs和hugos启动终止都加上别名
#对于手机，得先使用`sudo hostname k40s`或`sudo hostname tabs8`
#source "/mnt/hgfs/gitrepo/docs/_sh/vmMin/init.sh"
#用source来包含这个文件，不要直接bash执行
#git clone ssh://git@192.168.1.101:8022/storage/emulated/0/000ly/git/server/books.git
#myhostname=$(hostname)
clear;
docsDir="";
hugostart_cmd="";
dufsstart_cmd="";
dufsShareDir="";
hugoParams="env HUGO_PARAMS_showPdf=true HUGO_PARAMS_booksUrl=http://localhost:5000";

#正则学习 (?<=\()\S+(?=\))
# (?<=exp)是以exp开头的字符串, 但不包含本身.
# (?=exp)就匹配为exp结尾的字符串, 但不包含本身.

# (?<=\() 也就是以括号开头, 但不包含括号.

# (?=\)) 就是以括号结尾，但不包括括号

#有ip的时候用ip，没有则用默认127.0.0.1
# pc获取ip
# ip a | grep -Po "192(\.\d+){3}(?=\/)"
# 手机获取ip
# ifconfig | grep -P "192(\.\d+){3}" | awk '{print $2}'

#如果是在Linux环境下运行
if [[ $(uname -a | awk '{print $1}') == 'Linux' ]]; then

   #如果是在linux环境下运行
   #shell里字符串拼接就是直接写在一起(中间没有空格)
   #windows系统中vmwareDebian系统
   if [[ $(uname -m) == "x86_64" ]]; then
      docsDir="/mnt/hgfs/gitrepo/docs"; 
      # docsDir="D:/Users/ly/Documents/git/docs";
      myip=$(ip a | grep -Po "192(\.\d+){3}(?=\/)")
      if [[ $myip != "" ]]; then
        hugoParams=${hugoParams/'localhost'/$myip}
      fi
      hugostart_cmd="(cd $docsDir;"' if [[ $(pgrep hugo | wc -l) == 0  ]] ; then '" $hugoParams "' hugo server --minify --environment vmMin --bind 0.0.0.0  ; else echo "hugo 已经在运行" ; fi)' 
   #手机或平板上的termux
   elif [[ $(uname -m) == "aarch64"  ]]; then
      docsDir="/storage/emulated/0/000Ly/git/docs";
      myip=$( ifconfig | grep -P "192(\.\d+){3}" | awk '{print $2}')
      #clear #这里清除了ifconfig的没权限提示
      if [[ $myip != "" ]]; then
        hugoParams=${hugoParams/'localhost'/$myip}
      fi
      hugostart_cmd="(cd $docsDir;"' if [[ $(pgrep hugo | wc -l) == 0  ]] ; then '" $hugoParams "' hugo server --minify --environment aarch --bind 0.0.0.0 --noBuildLock ; else echo "hugo 已经在运行" ; fi)' 
   elif [[ $(uname -m) == "armv7l" ]]; then
      docsDir="/data/data/com.termux/files/home/000Ly/git/docs";
      myip=$( ifconfig | grep -P "192(\.\d+){3}" | awk '{print $2}')
      #clear #这里清除了ifconfig的没权限提示
      if [[ $myip != "" ]]; then
        hugoParams=${hugoParams/'localhost'/$myip}
      fi
      hugostart_cmd="(cd $docsDir;"' if [[ $(pgrep hugo | wc -l) == 0  ]] ; then '" $hugoParams "' hugo server --minify --environment armv7l --bind 0.0.0.0 --noBuildLock ; else echo "hugo 已经在运行" ; fi)' 
   fi  


   dufsShareDir="$docsDir/attachments";  
   #下面加了()使得&符号不会被解析成其他意思
   dufsstart_cmd="(cd $docsDir;"' if [[ $(pgrep dufs | wc -l) == 0  ]] ; then (dufs --enable-cors '"$dufsShareDir"' --log-format="" > ~/dufs.log &) ; echo "dufs启动成功";  else echo "dufs 已经在运行" ; fi)'
 

   #设置别名
   #1. 单引号不需要转义 2.单引号不会把里面的命令先执行后存，不会变成：(kill -9 75857) && echo '终止dufs成功'
   #3. 实在不行的情况下也许要用到反引号
   alias hugost="$dufsstart_cmd ; $hugostart_cmd"
   alias hugokl=' (kill -9 $(pgrep hugo)) && echo '终止hugo成功' '

   alias dufsst="$dufsstart_cmd"
   alias dufskl='(kill -9 $(pgrep dufs)) && echo '终止dufs成功' '

   #执行更新脚本
   alias allpl="cd $docsDir ;bash $docsDir/_sh/docs-book-git.sh pl"
   alias allps="cd $docsDir ;bash $docsDir/_sh/docs-book-git.sh ps"
#windows系统中使用Cmder
else #windows平台下
 
   docsDir="/d/Users/ly/Documents/git/docs";
   myip=$( ipconfig | grep -aEo "192\.[0-9]+\.[0-9]\.[^1][0-9]+" )
   #clear #这里清除了ifconfig的没权限提示
   if [[ $myip != "" ]]; then
     hugoParams=${hugoParams/'localhost'/$myip}
   fi
   hugostart_cmd="(cd $docsDir;"' if [[ $(tasklist | grep hugo | wc -l) == 0  ]] ; then '" $hugoParams "' hugo server --minify --environment cmderWin --bind 0.0.0.0 --noBuildLock ; else echo "hugo 已经在运行" ; fi)' 
 

   dufsShareDir="$docsDir/attachments";  
   #下面加了()使得&符号不会被解析成其他意思
   dufsstart_cmd="(cd $docsDir;"' if [[ $(tasklist | grep dufs | wc -l) == 0  ]] ; then (dufs --enable-cors '"$dufsShareDir"' --log-format="" > ~/dufs.log &) ; echo "dufs启动成功";  else echo "dufs 已经在运行" ; fi)'
   #设置别名
   #1. 单引号不需要转义 2.单引号不会把里面的命令先执行后存，不会变成：(kill -9 75857) && echo '终止dufs成功'
   #3. 实在不行的情况下也许要用到反引号
   alias hugost="$dufsstart_cmd ; $hugostart_cmd"
   alias hugokl='taskkill -f -pid $( tasklist | grep hugo  | awk '\''{print $2}'\'' )'

   alias dufsst="$dufsstart_cmd"
   alias dufskl='taskkill -f -pid $( tasklist | grep dufs  | awk '\''{print $2}'\'' )'

   #执行更新脚本
   alias allpl="cd $docsDir ;bash $docsDir/_sh/docs-book-git.sh pl"
   alias allps="cd $docsDir ;bash $docsDir/_sh/docs-book-git.sh ps"
fi

cd $docsDir
git status 
