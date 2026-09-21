---
title: "078"
description: "078"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-21T16:51:09+08:00
lastmod: 2026-09-21T16:51:09+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 特殊方法

```python

In [63]: mylist=[1,2,3]

In [64]: len(mylist)
Out[64]: 3

In [65]: class Sample():
    ...:     pass
    ...:

In [66]: mysample=Sample()

In [67]: len(mysample)
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[67], line 1
----> 1 len(mysample)

TypeError: object of type 'Sample' has no len()

#print测试
In [68]: print(mysample)
<__main__.Sample object at 0x712fd8c5ee10>

In [69]: print(mylist)
[1, 2, 3]

```

> 特殊方法，也称为 ***魔法方法或双下划线方法 （dunder methods）***，因为他们使用双下划线  

```python
In [73]: class Book():
    ...:     def __init__(self,title,author,pages):
    ...:         self.title=title
    ...:         self.author=author
    ...:         self.pages=pages
    ...:

In [74]: b=Book('Python rocks','Jose',200)

#默认打印的是对象在内存中的位置
#当调用print函数时实际上是在为，b的字符串表示形式是什么
In [75]: print(b)
<__main__.Book object at 0x712fda7cb1d0>

In [76]: str(b)
Out[76]: '<__main__.Book object at 0x712fda7cb1d0>'
```

> 修改与字符串调用相关的特殊方法

```python
In [82]: class Book():
    ...:     def __init__(self,title,author,pages):
    ...:         self.title=title
    ...:         self.author=author
    ...:         self.pages=pages
    ...:     def __str__(self):
    ...:         return f'{self.title} by {self.author}'
    ...:     def __len__(self):
    ...:         return self.pages
    ...:

In [83]: b=Book('Python rocks','Jose',200)

In [84]: str(b)
Out[84]: 'Python rocks by Jose'

In [85]: print(b)
Python rocks by Jose

In [86]: len(b)
Out[86]: 200
```

> del b 的作用是删除变量名 b 与对象之间的引用关系。但是对象有没有被删除？这里要注意：del b 不一定删除对象本身。Python 使用**引用计数（reference counting）** 管理对象。**引用计数变成0**时 Python 垃圾回收机制才会回收这个对象。

```python
In [87]: b
Out[87]: <__main__.Book at 0x712fd83efe60>

In [88]: del b

In [89]: b
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[89], line 1
----> 1 b

NameError: name 'b' is not defined
```

> 不管内存对象是否被回收，`del b`之后照样是不能再使用b变量

```python
In [93]: a=Book('Python rocks','Jose',200)

In [96]: b=a

In [97]: a
Out[97]: <__main__.Book at 0x712fd84a93d0>

In [98]: b
Out[98]: <__main__.Book at 0x712fd84a93d0>

In [99]: del b

In [100]: b
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[100], line 1
----> 1 b

NameError: name 'b' is not defined
```

> 特殊指定del时的操作 ~~注意，只有引用计数为0时才会触发__del__~~ 


```python
In [102]: class Book():
     ...:     def __init__(self,title,author,pages):
     ...:         self.title=title
     ...:         self.author=author
     ...:         self.pages=pages
     ...:     def __str__(self):
     ...:         return f'{self.title} by {self.author}'
     ...:     def __len__(self):
     ...:         return self.pages
     ...:     def __del__(self):
     ...:         print("A book object has been deleted!")
     ...:

In [103]: a=Book('Python rocks','Jose',200)

In [104]: b=a

In [105]: del a

In [106]: del b
A book object has been deleted!
```