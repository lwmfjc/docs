---
title: "121压缩、解压"
description: "121压缩、解压"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-27T11:03:38+08:00
lastmod: 2026-09-27T11:03:38+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 1. 将创建一个zip文件，压缩文本文件，然后将它们插入到zip文件中，关闭它
> 2. 将信息解压回选择的文件夹


# zip file模块

## 内置模块

> Python内置

> IPython中，按ctrl+O 新建一行

```python

In [8]: f=open('filetwo.txt','w+')#文件不存在则创建
   ...: f.write('two file')
   ...: f.close()
   ...:
   
In [9]: f=open('fileone.txt','w+')#文件不存在则创建
   ...: f.write('one file')
   ...: f.close()
   

```

> 压缩单个文件

```python
In [10]: import zipfile

#先创建压缩文件.zip
#取名，并以写入模式打开
In [11]: comp_file=zipfile.ZipFile('comp_file.zip','w')

```

```bash
#bash中执行
╭─ ~/python_test/mydir121 main ?2
╰─❯ ls
comp_file.zip  fileone.txt  filetwo.txt


```

> 压缩文本文件然后插入到zip文件中

```python
In [10]: import zipfile

In [11]: comp_file=zipfile.ZipFile('comp_file.zip','w')

In [13]: comp_file.write('fileone.txt',compress_type=zipfile.ZIP_DEFLATED)

In [14]: comp_file.write('filetwo.txt',compress_type=zipfile.ZIP_DEFLATED)

In [15]: comp_file.close()
```

> 查看

```bash
╭─ ~/python_test/mydir121 main ?2
╰─❯ ls -lh
total 12K
-rw-r--r-- 1 ly ly 238 Sep 27 11:18 comp_file.zip
-rw-r--r-- 1 ly ly   8 Sep 27 11:12 fileone.txt
-rw-r--r-- 1 ly ly   8 Sep 27 11:11 filetwo.txt
```

> 解压到指定文件夹

```python
In [19]: zip_obj=zipfile.ZipFile('comp_file.zip','r')

In [20]: zip_obj.extractall('extracted_content')

In [21]: zip_obj.close()

In [22]: pwd
Out[22]: '/home/ly/python_test/mydir121'
```

> 查看

```bash
╭─ ~/python_test/mydir121 main ?2
╰─❯ tree
.
├── comp_file.zip
├── extracted_content
│   ├── fileone.txt
│   └── filetwo.txt
├── fileone.txt
└── filetwo.txt

2 directories, 5 files
```

## shell utility库

> 归档整个文件夹或提取整个文件夹

### 压缩

```python
In [24]: import shutil

In [25]: dir_to_zip='/home/ly/python_test/mydir121/extracted_content'

In [26]: output_filename='example'

In [27]: shutil.make_archive(output_filename,'zip',dir_to_zip)
Out[27]: '/home/ly/python_test/mydir121/example.zip'
```

```bash
╭─ ~/python_test/mydir121 main ?2
╰─❯ ls -lh
total 20K
-rw-r--r-- 1 ly ly  238 Sep 27 11:18 comp_file.zip
-rw-r--r-- 1 ly ly  238 Sep 27 11:27 example.zip #新文件
drwxr-xr-x 2 ly ly 4.0K Sep 27 11:20 extracted_content
-rw-r--r-- 1 ly ly    8 Sep 27 11:12 fileone.txt
-rw-r--r-- 1 ly ly    8 Sep 27 11:11 filetwo.txt
```

### 提取

```python
In [28]: shutil.unpack_archive('example.zip','final_unzip','zip')
```

```bash
╭─ ~/python_test/mydir121 main ?2
╰─❯ tree
.
├── comp_file.zip
├── example.zip
├── extracted_content
│   ├── fileone.txt
│   └── filetwo.txt
├── fileone.txt
├── filetwo.txt
└── final_unzip #这里
    ├── fileone.txt
    └── filetwo.txt

3 directories, 8 files
```

