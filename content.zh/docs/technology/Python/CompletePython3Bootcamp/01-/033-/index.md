---
title: 033-
description: 033-
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-08-29T18:38:44+08:00
lastmod: 2026-08-29T18:38:44+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 基本的文件输入输出

## 编辑并保存一个测试文件

在jupyter中输入并运行  

```shell
%%writefile myfile.txt
Hello this is a text file
this is the second line
this is the third line
```

得到文件  

![](img/ly-20260829192133979.png)  

注意，最后一行（第三行）最后还有一个换行符`\n`  

也就是说，在jupyter输入的文本，都会以一个换行符结束输入  

另一种情况，在linux下使用ipython命令行输入  

```shell
In [2]: %%writefile myfile_linux.txt
   ...: a
   ...: b
   ...: 
   ...: 
Overwriting myfile_linux.txt

```

在系统中查看，发现jupyter是没有空行的，而myfile_linux.txt则多了一个空行    

```shell
(myenv) ly@dba13:~$ cat myfile_linux.txt
a
b

(myenv) ly@dba13:~$ cat myfile.txt #这个是我保存的jupyter编辑的文件
Hello this is a text file
this is the second line
this is the third line
(myenv) ly@dba13:~$ 

```

![](img/ly-20260829193000299.png)  

所以如果实在linux跟着教程做，建议直接在linux中使用nano或者vim编辑即可，编辑后保持和视频一致  

```shell
#$表示换行符
ly@dba13:~$ cat -A  myfile.txt 
Hello this is a text file$
this is the second line$
this is the third line$
```

## 输入输出

```shell
#查看当前目录
>>> import os
>>> os.getcwd()
'/home/ly'
#pwd只有在ipython里才有用
>>> os.listdir()
['myfile.txt', '.Xauthority', '.python_history', '.config', '.bash_logout', '.viminfo', '.sudo_as_admin_successful', 'python-env', '.bash_history', '.bashrc', '.profile', '.ipython', '.local', '.cache']

>>> myfile=open('myfile.txt')
>>> type(myfile)
<class '_io.TextIOWrapper'>
>>> content=myfile.read()
>>> type(content)
<class 'str'>
>>> content
'Hello this is a text file\nthis is the second line\nthis is the third line\n'
>>> myfile.read() #再次读取，发现是空字符串
''

```