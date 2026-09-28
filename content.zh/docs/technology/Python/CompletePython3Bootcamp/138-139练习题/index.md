---
title: "138-139练习题"
description: "138-139练习题"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-28T12:44:44+08:00
lastmod: 2026-09-28T12:44:44+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
结合两张图片  

![](img/ly-20260928124711435.png)  
![](img/ly-20260928125028218.png)  

```python
In [1]: from PIL import Image

In [2]: words=Image.open('word_matrix.png')

In [3]: mask=Image.open('mask.png')

In [4]: words.mode
Out[4]: 'RGBA'

In [5]: mask.mode
Out[5]: 'RGBA'

In [6]: words.size
Out[6]: (1015, 559)

#尺寸不同
In [7]: mask.size
Out[7]: (505, 251)
```

> 直接paste的结果

![](img/ly-20260928125055017.png)  
> 1. 放大mask
> 2. 给mask添加透明度

```python
In [8]: mask=mask.resize((1015,559))

In [9]: mask.size
Out[9]: (1015, 559)


In [10]: mask.putalpha(200)

In [11]: words.paste(mask,(0,0),mask)

In [12]: words.show()
```

![](img/ly-20260928125329695.png)