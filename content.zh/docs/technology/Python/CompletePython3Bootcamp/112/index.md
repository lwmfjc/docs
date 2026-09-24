---
title: "112"
description: "112"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-24T17:13:57+08:00
lastmod: 2026-09-24T17:13:57+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***打开或读取文件、文件夹***

- Shutil  ~~shell utilities~~ 
- OS

> 接下来所有操作都在 `~/python_test/mydir112 `目录下操作

```python
In [2]: f=open('practice.txt','w+') #w+ 可读可写

In [3]: f.write('This is a test string')
Out[3]: 21

In [4]: f.close()
```

```bash
╭─ ~/python_test/mydir112 main ?1
╰─❯ ls
practice.txt

╭─ ~/python_test/mydir112 main ?1
╰─❯ cat practice.txt
This is a test string%  
```

> 当前工作目录

```python
In [6]: import os

#current work dir 
In [7]: os.getcwd()
Out[7]: '/home/ly/python_test/mydir112'
```

> 当前目录所有内容

```python
In [8]: os.listdir()
Out[8]: ['practice.txt']

In [14]: os.listdir("/home/ly/python_test")
Out[14]:
['.gitignore',
 'mydir112',
 'mydir3',
 'mydir4',
 'dk.py',
 'mydir',
 'mydir093',
 '.git',
 'testfile',
 'mydir2',
 'mydir1']
```

> 移动文件

```bash
╭─ ~/python_test/mydir112 main ?1
╰─❯ mkdir testmv

╭─ ~/python_test/mydir112 main ?1
╰─❯ ls
practice.txt  testmv
```

```python
In [16]: import shutil

In [17]: shutil.move("practice.txt","/home/ly/python_test/mydir112/testmv")
Out[17]: '/home/ly/python_test/mydir112/testmv/practice.txt'
```

```bash
╭─ ~/python_test/mydir112 main ?1
╰─❯ tree
.
└── testmv
    └── practice.txt
```

> 支持相对路径

```python
In [18]: f=open('practice1.txt','w+') #w+ 可读可写

In [19]: f.close()

In [20]: os.listdir()
Out[20]: ['testmv', 'practice1.txt'] 

In [22]: shutil.move("practice1.txt","testmv")
Out[22]: 'testmv/practice1.txt'
```

> move，listdir 均不支持通配符*

```python
In [24]: f=open('practice2.txt','w+') #w+ 可读可写

In [25]: f.close()

In [26]: os.listdir()
Out[26]: ['testmv', 'practice2.txt']

#这里是失败的，他把 "practice2.txt" 重命名成了 "*mv"
In [27]: shutil.move("practice2.txt","/home/ly/python_test/mydir112/*mv")
Out[27]: '/home/ly/python_test/mydir112/*mv'

In [28]: os.listdir('*mv')
---------------------------------------------------------------------------
NotADirectoryError                        Traceback (most recent call last)
Cell In[28], line 1
----> 1 os.listdir('*mv')

NotADirectoryError: [Errno 20] Not a directory: '*mv'

In [29]: os.listdir('testmv')
Out[29]: ['practice.txt', 'practice1.txt']
```

> os模块有很多功能，这里主要教一些基础知识，比如如何移动文件、如何打开文件、如何列出目录、如何删除文件

- os.unlink(path)，删除提供的路径处的文件
- os.rmdir(path)，删除提供的路径处的文件夹（文件夹必须是空的） ~~即先把文件夹里的文件都unlink掉再删除~~ 
- shutil.rmtree(path)，删除路径下包含的所有文件和文件夹
    - 由于无法恢复太过危险，建议使用 `send2trash` (会把文件送到回收站) `pip install send2trash`

```python

#删除文件
In [3]: import os

In [4]: os.unlink('*mv')

In [6]: import shutil

#移动文件
In [8]: shutil.move("testmv/practice.txt",".")
Out[8]: './practice.txt'

#恢复只剩一个文件

In [10]: os.listdir()
Out[10]: ['testmv', 'practice.txt']

In [11]: os.unlink('testmv/practice1.txt')

In [12]: os.rmdir('testmv')

In [13]: os.listdir()
Out[13]: ['practice.txt']

#移动到回收站
In [17]: import send2trash

In [18]: send2trash.send2trash('practice.txt')

In [19]: os.listdir()
Out[19]: []

#在回收站查看
In [24]: os.listdir('/home/ly/.local/share/Trash/files')
Out[24]: ['practice.txt']

#从回收站移回来
In [25]: shutil.move("/home/ly/.local/share/Trash/files/practice.txt",".")
Out[25]: './practice.txt'

In [26]: os.listdir()
Out[26]: ['practice.txt']
```

> os.walk：只接受一个参数top，是一个目录树生成器

```python
#文件结构
╭─ ~/python_test/mydir112 main ?1
╰─❯ ls
Example_Top_Level  Example_Top_Level-bak  practice.txt

╭─ ~/python_test/mydir112 main ?1
╰─❯ tree Example_Top_Level
Example_Top_Level
├── Mid-Example-One
│   ├── Bottom-Level-One
│   │   └── One_Text.txt
│   ├── Bottom-Level-Two
│   │   └── Bottom-Text-Two.txt
│   └── Mid-Level-Doc.txt
├── Mid-Example-Two
└── Mid-Example.txt
```

> 先遍历第一层目录的所有  直接子文件夹，直接子文件 
> 然后遍历第二层目录的所有 直接子文件夹，直接子文件
> ....
> 

```python
#这里是元组解包
In [31]: for folder,sub_folders,files in os.walk(file_path):
    ...:     print(f"Currently looking at {folder}")
    ...:     print("\n")
    ...:     print('The subfolders are: ')
    ...:     for sub_fold in sub_folders:
    ...:         print(f'Subfolder: {sub_fold}')
    ...:     print('\n')
    ...:     print("the files are: ")
    ...:     for f in files:
    ...:         print(f"file: {f}")
    ...:     print('\n')
    ...:
Currently looking at /home/ly/python_test/mydir112/Example_Top_Level


The subfolders are:
Subfolder: Mid-Example-One
Subfolder: Mid-Example-Two


the files are:
file: Mid-Example.txt


Currently looking at /home/ly/python_test/mydir112/Example_Top_Level/Mid-Example-One


The subfolders are:
Subfolder: Bottom-Level-One
Subfolder: Bottom-Level-Two


the files are:
file: Mid-Level-Doc.txt


Currently looking at /home/ly/python_test/mydir112/Example_Top_Level/Mid-Example-One/Bottom-Level-One


The subfolders are:


the files are:
file: One_Text.txt


Currently looking at /home/ly/python_test/mydir112/Example_Top_Level/Mid-Example-One/Bottom-Level-Two


The subfolders are:


the files are:
file: Bottom-Text-Two.txt


Currently looking at /home/ly/python_test/mydir112/Example_Top_Level/Mid-Example-Two


The subfolders are:


the files are:


```

> 原因`os.walk(file_path)`返回的是元组，元组第一个元素是当前文件夹路径，第二个元素是`直接子目录`列表，第三个元素是`直接子文件`列表

```python
In [40]: a=os.walk(file_path)

In [41]: next_a1=next(a)

In [42]: next_a1
Out[42]:
('/home/ly/python_test/mydir112/Example_Top_Level',
 ['Mid-Example-One', 'Mid-Example-Two'],
 ['Mid-Example.txt'])
```

