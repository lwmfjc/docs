---
title: "107-109生成器"
description: "107-109生成器"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-24T11:38:52+08:00
lastmod: 2026-09-24T11:38:52+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 生成器

> 允许我们根据时间推移生成一个值的序列，而不需要一次性构建整个序列将其保存在内存中

> 当生成器函数被编译，会变成一个支持某种迭代协议的对象。他们在代码中被实际调用时，并不会返回一个值然后退出。生成器函数会自动暂停和恢复他们的执行状态，围绕最后一个值生成点进行

> 生成器计算一个值，然后等待下一个值被请求时再计算，而不是必须预先计算整个系列的值并存在内存中

> range本身是生成器，所以如果需要一个列表，就必须将它转换为list

```python
In [1]: range(0,4)
Out[1]: range(0, 4)

In [2]: list(range(0,4))
Out[2]: [0, 1, 2, 3]

In [3]: list(range(0,10,3))
Out[3]: [0, 3, 6, 9]

```

```python
In [5]: def create_cubes(n):
   ...:     result=[]
   ...:     for x in range(n):
   ...:         result.append(x**3)
   ...:     return result
   ...:

n [7]: for x in create_cubes(10):
   ...:     print(x)
   ...:
0
1
8
27
64
125
216
343
512
729

```

> 使用生成器

```python
#在需要的时候，才生成值
In [8]: def create_cubes(n):
   ...:     for x in range(n):
   ...:         yield x**3
   ...:

In [9]: for x in create_cubes(10):
   ...:     print(x)
   ...:
0
1
8
27
64
125
216
343
512
729

In [10]: create_cubes(10)
Out[10]: <generator object create_cubes at 0x752d0f331cb0>
```

> 斐波那契数列

```python
In [12]: def gen_fibon(n):
    ...:     a=1
    ...:     b=1
    ...:     for i in range(n):
    ...:         yield a
    ...:         a,b = b,a+b
    ...:

In [13]: for number in gen_fibon(10):
    ...:     print(number)
    ...:
1
1
2
3
5
8
13
21
34
55
```

> 下面是一样的结果，但这种方式内存效率低得多，因为将所有内容提前保存在了内存中，而不是在需要时yield它们

```python
In [14]: def gen_fibon(n):
    ...:     a=1
    ...:     b=1
    ...:     output=[]
    ...:     for i in range(n):
    ...:         output.append(a)
    ...:         a,b = b,a+b
    ...:     return output
    ...:

In [15]: for number in gen_fibon(10):
    ...:     print(number)
    ...:
1
1
2
3
5
8
13
21
34
55
```

> next 

```python
In [17]: def simple_gen():
    ...:     for x in range(3):
    ...:         yield x
    ...:

In [18]: for number in simple_gen():
    ...:     print(number)
    ...:
0
1
2

In [19]: g=simple_gen()

#这是要给生成器对象
In [20]: g
Out[20]: <generator object simple_gen at 0x752d0df74880>

In [21]: print(next(g))
0

In [22]: print(next(g))
1

In [23]: print(next(g))
2

#这个错误通知我们所有的值已经被yield（翻译：产量）
#for循环中自动捕获了这个错误并停止调用next
In [24]: print(next(g))
---------------------------------------------------------------------------
StopIteration                             Traceback (most recent call last)
Cell In[24], line 1
----> 1 print(next(g))

StopIteration:
```

> iter


```python
In [26]: s='hello'

In [27]: for letter in s:
    ...:     print(letter)
    ...:
h
e
l
l
o

#将可迭代对象转换为迭代器
In [32]: s_iter=iter(s)

In [33]: next(s_iter)
Out[33]: 'h'

In [34]: next(s_iter)
Out[34]: 'e'

```

## 练习题

```python
In [38]: def gensqures(N):
    ...:     for x in range(N):
    ...:         yield x**2
    ...:

In [39]: for x in gensqures(10):
    ...:     print(x)
    ...:
0
1
4
9
16
25
36
49
64
81
```

- randint → int + range 全包含
- range() / randrange() → 左闭右开

```python
In [46]: import random

In [47]: random.randint(1,10)
Out[47]: 4 

In [49]: def rand_num(low,high,n):
    ...:     for x in range(n):
    ...:         yield random.randint(low,high)
    ...:

In [50]: for num in rand_num(1,10,12):
    ...:     print(num)
    ...:
4
9
1
5
2
9
7
7
10
2
10
5
```

> 将字符串转换为迭代器

```python
In [52]: s='hello'

In [53]: s=iter(s)

In [54]: print(next(s))
h
```

> 使用生成器的场景：如果输出结果可能占用大量内存，而你只想逐个遍历它，并不需要一次性获取全部内容，那么使用生成器就非常合理

```python
In [56]: mylist=[1,2,3,4,5]

#类似列表式推导式(他是方括号[])，而生成器推导式是圆括号()
In [57]: gencomp=(item for item in mylist if item>3)

In [58]: type(gencomp)
Out[58]: generator

In [59]: for item in gencomp:
    ...:     print(item)
    ...:
4
5
```