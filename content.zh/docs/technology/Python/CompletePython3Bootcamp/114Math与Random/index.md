---
title: "114Math与Random"
description: "114Math与Random"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-26T12:45:22+08:00
lastmod: 2026-09-26T12:45:22+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
***Math 与 Random***

- math模块：本质上就是一个包含大量实用数学函数的模块
- random模块：包含许多数学随机函数，及从Python列表中随机抽取元素的函数

# floor,ceil

```python
In [3]: import math

In [4]: help(math)

In [5]: value=4.35

#向下取整小于等于他的整数
In [6]: math.floor(value)
Out[6]: 4

In [7]: math.floor(4)
Out[7]: 4

#向上取整大于等于他的整数
In [8]: math.ceil(value)
Out[9]: 5

In [9]: math.ceil(5)
Out[9]: 5


```

# round

> round遇到.5这种中间值时，统一向偶数或奇数方向取整 ~~这里是偶数~~

> 它采用的是 银行家舍入（Banker's rounding / round half to even）。规则：当小数部分刚好是 0.5 时，向最近的偶数取整。

> 原因：如果你总是向下取整那么长期累积下来你的估算结果会系统性偏低；如果总是向上取整那么又会系统性偏高。但如果根据数字是奇数或者偶数（这里是偶数），误差就能相互抵消

```python
In [10]: round(4.35)
Out[10]: 4

#向上是5奇数，向下是4是偶数
In [11]: round(4.5)
Out[11]: 4

#向下是5奇数，向上是6偶数
In [12]: round(5.5)
Out[12]: 6
```

如果指定保留位数：

```
round(4.35, 1)
```

你可能期待：

```
4.4
```

但是：

```
round(4.35,1)
4.3
```

原因是 ***浮点数存储误差***。

计算机里：

```
4.35
```

实际存储可能接近：

```
4.3499999999999996
```

于是它认为：

```
4.349999...
```

更接近 4.3。

可以看：

```
format(4.35, '.20f')
'4.34999999999999964473'
```

如果想要传统数学里的“四舍五入”，可以用 Decimal：

```python
from decimal import Decimal, ROUND_HALF_UP

Decimal("4.35").quantize(
    Decimal("0.1"),
    rounding=ROUND_HALF_UP
)
```

结果：

```
Decimal('4.4')
```

# 获取数学常数

```
infinity

读音：/ɪnˈfɪnəti/
```

```python
#圆周率常数
In [15]: math.pi
Out[15]: 3.141592653589793

#或者
In [16]: from math import pi

In [17]: pi
Out[17]: 3.141592653589793

In [18]: math.e
Out[18]: 2.718281828459045

#无穷大
#用途:1. 初始化最大值 2.路径规划、图搜索 3.表示没有上限 
In [20]: math.inf
Out[20]: inf

#非数字，not a num
#用途：1. 表示缺失数据(比如大家都是数字，某些人没有成绩) 2. 非法数学结果（比如math.sqrt(-1) 
#说明一下，nan 不等于自己
In [21]: math.nan
Out[21]: nan
```

> 如果经常需要用到math.inf或者math.nan，可以考虑numpy库，专为数值计算设计的库

```python
#对meth.e取以e为底的对数
In [25]: math.e
Out[25]: 2.718281828459045

In [26]: math.log(math.e)
Out[26]: 1.0

#求解：10的几次方等于100
In [27]: math.log(100,10)
Out[27]: 2.0

#默认是弧度
In [29]: math.sin(10)
Out[29]: -0.5440211108893698

#弧度转换为角度
In [30]: math.degrees(pi/2)
Out[30]: 90.0

#度数转换为弧度
In [31]: math.radians(100)
Out[31]: 1.7453292519943295
```

# random

> 可以去看看两个文章：1 伪随机数生成器 2 随机种子

> 获取范围内的随机数(包括那两个边界)

```python
In [2]: import random

In [3]: random.randint(0,100)
Out[3]: 55

In [4]: random.randint(0,1)
Out[4]: 1

In [5]: random.randint(0,1)
Out[5]: 0
```

> 设置种子后，伪随机数生成器就会从同一个起点开始，从而产生相同的随机数序列


```python
#固定的随机数生成序列：74,24,69
In [6]: random.seed(101)

#由于设置了101，这里必然是74
#如果在jupyter中，In[6]和In[7]必须写同一个单元格
In [7]: random.randint(0,100)
Out[7]: 74

In [8]: random.randint(0,100)
Out[8]: 24

In [9]: random.randint(0,100)
Out[9]: 69

#重新设置随机状态
In [10]: random.seed()

In [11]: random.randint(0,100)
Out[11]: 41

In [12]: random.randint(0,100)
Out[12]: 78
```

> 随机选择一个元素

```python
In [14]: mylist=list(range(0,20))

In [15]: mylist
Out[15]: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]

In [16]: random.choice(mylist)
Out[16]: 14
```

> 随机抽样：包括有放回抽样和无放回抽样

```python
In [18]: mylist
Out[18]: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]

#随机抽取十次，每次抽取后再放回
In [19]: random.choices(population=mylist,k=10)
Out[19]: [19, 10, 13, 0, 19, 11, 19, 3, 14, 14]

##随机抽取十次，每次抽取后不放回，然后继续抽
In [20]: random.sample(population=mylist,k=10)
Out[20]: [3, 15, 1, 5, 6, 19, 0, 14, 12, 4]

In [21]: mylist
Out[21]: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
```

> 复制列表而不是添加新变量指定同一个列表

```python
In [30]: mylist
Out[30]: [14, 17, 13, 6, 8, 12, 15, 11, 1, 19, 10, 3, 5, 4, 9, 18, 0, 16, 2, 7]

In [31]: copylist=mylist

In [32]: id(copylist)
Out[32]: 139291114022592 #相同

In [33]: id(mylist)
Out[33]: 139291114022592  #相同

In [34]: copylist1=mylist[::] 

In [36]: id(copylist1)
Out[36]: 139291137113664

In [37]: copylist1=list(mylist)

In [38]: id(copylist1)
Out[38]: 139291112856384


```

> 原地打乱

```python
In [41]: mylist=list(range(0,20))

In [42]: random.shuffle(mylist)

In [43]: mylist
Out[43]: [5, 6, 15, 4, 13, 1, 12, 9, 3, 14, 17, 16, 2, 18, 8, 19, 11, 10, 7, 0]
```

> 概率分布

```python
#均匀分布
In [46]: random.uniform(a=0,b=100)
Out[46]: 5.386212702482318

In [47]: random.uniform(a=0,b=100)
Out[47]: 60.096569854933776

In [48]: random.uniform(a=0,b=1)
Out[48]: 0.9632959296226136

#高斯分布
In [53]: random.gauss(mu=0,sigma=1)
Out[53]: -0.3785553832230575
```