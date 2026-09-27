---
title: "122-123高级模块解答"
description: "122-123高级模块解答"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-27T11:31:31+08:00
lastmod: 2026-09-27T11:31:31+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 解压文件

```python
In [2]: import shutil

In [3]: shutil.unpack_archive('/home/ly/python_test/mydir122/unzip_me_for_instructions.zip','','zip') #直接在当前目录下解压
```

```bash
╭─ ~/python_test/mydir122 main ?3
╰─❯ ls
extracted_content  unzip_me_for_instructions.zip

╭─ ~/python_test/mydir122 main ?3
╰─❯ tree
#extracted_content下有5个文件夹，每个文件夹下有几十个文件

7 directories, 122 files

╭─ ~/python_test/mydir122 main ?3
╰─❯ cat extracted_content/Instructions.txt
Good work on unzipping the file!
You should now see 5 folders, each with a lot of random .txt files.
Within one of these text files is a telephone number formated ###-###-####
Use the Python os module and regular expressions to iterate through each file, open it, and search for a telephone number.
Good luck!% 
```

```python
In [4]: with open('extracted_content/Instructions.txt') as f:
   ...:     content=f.read()
   ...:     print(content)
   ...:
Good work on unzipping the file!
You should now see 5 folders, each with a lot of random .txt files.
Within one of these text files is a telephone number formated ###-###-####
Use the Python os module and regular expressions to iterate through each file, open it, and search for a telephone number.
Good luck!
```

> 使用Python的OS模块以及正则表达式，来遍历所有的文本文件，打开它并搜索电话号码

> 测试正则表达式

```python
In [5]: import re

In [6]: pattern=r'\d{3}-\d{3}-\d{4}'

In [7]: test_string='here is 123-123-1234'

In [8]: re.findall(pattern,test_string)
Out[8]: ['123-123-1234']
```

> ***复习：*** `os.walk(file_path)`返回的是元组，元组第一个元素是当前文件夹路径，第二个元素是`直接子目录`列表，第三个元素是`直接子文件`列表

> 以下40-42的代码块不完整，不能从上面接上，只是其他地方拷贝过来用来说明os.walk(file_path)返回了啥

```python
In [40]: a=os.walk(file_path)

In [41]: next_a1=next(a)

In [42]: next_a1
Out[42]:
('/home/ly/python_test/mydir112/Example_Top_Level',
 ['Mid-Example-One', 'Mid-Example-Two'],
 ['Mid-Example.txt'])
```

> 也就是for里面的files就会一次次遍历所有层级下的file文件

> 遍历并搜索

```python
In [9]: def search(file,pattern=r'\d{3}-\d{3}-\d{4}'):
   ...:     f=open(file,'r')
   ...:     text=f.read()
   ...:     #这里只查找第一个
   ...:     if re.search(pattern,text):
   ...:         return re.search(pattern,text)
   ...:     else:
   ...:         #如果是pass替代return ''则默认return None
   ...:         #pass
   ...:         return ''
   ...:

In [10]: import os

In [11]: results=[]

In [12]: for folder,sub_folders,files in os.walk(os.getcwd()+'/extracted_content'):
    ...:     for f in files:
    ...:         full_path=folder+'/'+f
    ...:
    ...:         results.append(search(full_path))
    ...:

In [29]: len(results)
Out[29]: 121

In [31]: for r in results:
    ...:     if r != '':
    ...:         print(r.group())
    ...:
719-266-2837
```