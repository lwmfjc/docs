---
title: "151-高级操作_数字_"
description: "151-高级操作_数字_"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-28T19:48:33+08:00
lastmod: 2026-09-28T19:48:33+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 高级数字操作

```python
#转换为16进制表示
In [1]: hex(12)
Out[1]: '0xc'

In [2]: hex(512)
Out[2]: '0x200'

#转换为2进制表示
In [3]: bin(123)
Out[3]: '0b1111011'

In [4]: bin(128)
Out[4]: '0b10000000'

In [5]: 2**4
Out[5]: 16

#阶乘
In [6]: pow(2,4)
Out[6]: 16

#相当于2**4%3=1
In [7]: pow(2,4,3)
Out[7]: 1

In [8]: abs(-3)
Out[8]: 3

#绝对值
In [9]: abs(2)
Out[9]: 2

#四舍五入（.5时向偶数设）
In [10]: round(3.1)
Out[10]: 3

In [11]: round(3.9)
Out[11]: 4

In [12]: round(2.5)
Out[12]: 2

In [13]: round(3.141592,2)
Out[13]: 3.14

```

# 高级字符串操作

