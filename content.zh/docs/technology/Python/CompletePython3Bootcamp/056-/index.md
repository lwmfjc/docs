---
title: 056-
description: 056-
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-18T12:52:05+08:00
lastmod: 2026-09-18T12:52:05+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# Python练习题

## 热身问题

```python
#两偶数则取最小，否则取最大
In [9]: def lesser_of_two_evens(a,b):
   ...:     if(a%2==0 and b%2==0):
   ...:         return min(a,b)
   ...:     else:
   ...:         return max(a,b)
   ...:

In [10]: lesser_of_two_evens(1,2)
Out[10]: 2

In [11]: lesser_of_two_evens(4,2)
Out[11]: 2
```

```python
#接收2单词的字符串，如果他们以同样字符开头则返回True，否则false
In [18]: def animal_crackers(str):
    ...:     words=str.lower().split()
    ...:     if(len(words)>=2 and words[0][0] == words[1][0]):
    ...:         return True
    ...:     else:
    ...:         return False
    ...:

In [19]: animal_crackers('Levelhelkd Ldkfjks')
Out[19]: True

In [20]: animal_crackers('Levelhelkd Kdkfjks')
Out[20]: False
```

```python

```

## 一级问题



## 二级问题

