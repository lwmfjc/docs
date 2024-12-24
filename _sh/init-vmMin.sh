#!/bin/bash
#如果执行下面这个dufs命令，之后再执行hugo server ，ctrl c会把两个命令全关了
if [[ $( tasklist | grep dufs | wc -l ) == 0  ]] ; then
   # dufs --enable-cors "d:/Users/ly/Documents/git/" --log-format='' & 
   dufs --enable-cors "/mnt/hgfs/gitrepo/" --log-format='' & 
fi 
# if [[ $(tasklist | grep hugo | wc -l) == 0 ]] ; then 
# nohup hugo server --environment books-local --minify --bind 0.0.0.0 --logLevel error &  > ~/hugo.log
# fi 
#clear
#cd没效果，不知道原因
#cd d:/Users/ly/Documents/git/docs/assets 

#alias hugostart="hugo server --minify --environment books-local --bind 0.0.0.0 --buildFuture "
#alias dufsstart="dufs --enable-cors d:/Users/ly/Documents/git/ --log-format='' & > ~/dufs.log " 
#进程号，如果先获取，好像有时候对不上，因为获取的是之前的pid
#pIdDufs=$( tasklist | grep dufs  | awk '{print $2}' )
#pIdhugo=$( tasklist | grep hugo  | awk '{print $2}' )  
#alias hugostop="taskkill -f -pid $( tasklist | grep hugo  | awk '{print $2}' ) " 
#alias dufsstop="taskkill -f -pid $( tasklist | grep dufs  | awk '{print $2}' ) " 
#alias exit="taskkill -f -pid $pIdDufs ; exit " # ; taskkill -f -pid $pIdhugo ; exit "
# alias docstart="dufs --enable-cors d:/Users/ly/Documents/git/ --log-format='' & > ~/dufs.log ;
#  hugo server --minify --environment books-local --bind 0.0.0.0 --buildFuture "
alias hugostart="hugo server --minify --environment books-local --bind 0.0.0.0 --buildFuture "
alias exit="taskkill -f -pid $( tasklist | grep dufs  | awk '{print $2}' )  
; taskkill -f -pid $( tasklist | grep dufs  | awk '{print $2}' )  ; exit "