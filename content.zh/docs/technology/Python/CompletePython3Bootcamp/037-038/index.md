---
title: 037-038
description: 037-038
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-08-30T23:22:39+08:00
lastmod: 2026-08-30T23:22:39+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 比较运算符

```shell
#检查相等性
>>> 2==2
True
>>> 2==1
False
>>> 'hello'=='bye'
False
>>> 'hi'=='hi'
True
>>> 2=='2'
False
>>> 2.0==2 #数值
True
>>> 3!=3
False
>>> 4!=5
True
>>> 2>1
True
>>> 1>2
False
>>> 1<2
True
>>> 2<5
True
>>> 2>=2
True
>>> 4<=1
False

```

# 使用逻辑运算符(连接比较运算符)

- and
- or
- not
## and

```shell
>>> 1<2
True
>>> 2<3
True
>>> 1<2<3 #直接串联
True
>>> 1<2>3
False
#使用逻辑运算符连接
 
>>> 1<2 and 2<3
True 
>>> 'h' == 'h' and 2==2
True
>>> ('h' == 'h') and (2==2)
True

>>> 1<2 && 2<3
  File "<python-input-23>", line 1
    1<2 && 2<3
         ^
SyntaxError: invalid syntax

#注意，这是按位与运算符，且优先级高于<，>
>>> 3 < 4 & 4 < 5  #相当于  3< (4&4) <5，3 < 4 < 5
True
```

## or

```shell
>>> 1==1 or 2==2
True
>>> 100==1 or 2==2
True
```

## not

```shell
>>> 1==1
True
>>> not(1==1)
False
>>> not 1==1
False
>>> not 400>5000
True
>>> 1!=1
False
>>> not 1==1 #相比1!=1，逻辑更清晰点  
False

```

