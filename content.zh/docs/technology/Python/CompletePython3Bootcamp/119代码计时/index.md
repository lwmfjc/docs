---
title: "119代码计时"
description: "119代码计时"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-26T19:23:45+08:00
lastmod: 2026-09-26T19:23:45+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
本节介绍三种方法计时（用来测量代码效率）

1. 简单地记录调用函数之前和之后经过的时间
2. 使用timeit模块
3. 特殊的`%%timeit`魔术函数（jupyter特有）

```python
In [2]: def func_one(n):
   ...:     return [str(num) for num in range(n)]
   ...:

In [3]: func_one(10)
Out[3]: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

#map(函数f,列表)  
#使用函数映射列表中每一个元素
#map返回的是一个迭代器，接收一个函数，和一个可迭代对象
In [4]: def func_two(n):
   ...:     return list(map(str,range(n)))
   ...:

In [5]: func_two(10)
Out[5]: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
```