---
title: "135图像处理"
description: "135图像处理"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-28T10:14:17+08:00
lastmod: 2026-09-28T10:14:17+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 使用pillow库

```bash
╭─ ~                                                             19s Py ly
╰─❯ pip install pillow

```

如果处理大图像时出现下面情况：  

```text
IOPub data rate exceeded.
The notebook server will temporarily stop sending output
to the client in order to avoid crashing it.
To change this limit, set the config variable
```

可以在启动jupyter时使用 `jupyter notebook --NotebookApp.iopub_data_rate_limit=1.0e10   `  

> 确保当前目录有这些文件

```python
In [2]: import os

In [3]: os.getcwd()
Out[3]: '/home/ly/python_test/mydir135'

In [5]: os.listdir()
Out[5]:
['blue_color.png',
 'bak',
 'red_color.jpg',
 'mask.png',
 'purple.png',
 'example.jpg',
 'word_matrix.png',
 'pencils.jpg']
```

```python
In [7]: from PIL import Image

In [8]: mac=Image.open('example.jpg')

#这是一个来自PIL的专用JPEG图像文件
In [9]: type(mac)
Out[9]: PIL.JpegImagePlugin.JpegImageFile
```