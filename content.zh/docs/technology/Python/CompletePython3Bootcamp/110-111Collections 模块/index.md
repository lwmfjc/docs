---
title: "110-111Collections 模块"
description: "110-111Collections 模块"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-24T12:52:39+08:00
lastmod: 2026-09-24T12:52:39+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 高级模块简介

- 内置模块
- 涵盖`Collections，Os module and Date，Math and Random，Python Debugger，Timeit，Regular Expressions，Unzipping and Zipping`

## Collections

### Counter

> Python自带的，实现了专门的容器数据类型。是Python内置通用容器 ~~比如字典、元组~~ 的替代方案

```python
In [2]: from collections import Counter

In [3]: mylist=[1,1,1,1,1,2,2,2,2,3,3,3,3,3,3]

In [4]: Counter(mylist)
Out[4]: Counter({3: 6, 1: 5, 2: 4})

In [5]: mylist=['a','a',10,10,10]

In [6]: Counter(mylist)
Out[6]: Counter({10: 3, 'a': 2})
```

> 1. Counter从技术上讲是字典的一个子类，主要用于统计可哈希对象
> 2. 如上，元素 ~~对象~~ 被存储为字典的键，而对象的计数则作为值存储

------
------

```python
#对字符串有效
In [7]: Counter('aaabbbccshdjshsj')
Out[7]: Counter({'a': 3, 'b': 3, 's': 3, 'c': 2, 'h': 2, 'j': 2, 'd': 1})

#统计单词：先转成数组再统计
In [9]: sentence="How many times does each word show up in this sentence with a word" 

In [10]: Counter(sentence.lower().split())
Out[10]:
Counter({'word': 2,
         'how': 1,
         'many': 1,
         'times': 1,
         'does': 1,
         'each': 1,
         'show': 1,
         'up': 1,
         'in': 1,
         'this': 1,
         'sentence': 1,
         'with': 1,
         'a': 1})
```


```python
In [19]: letters='aaabbbbccccccccddddddddddd'

In [20]: c=Counter(letters)

In [21]: c
Out[21]: Counter({'d': 11, 'c': 8, 'b': 4, 'a': 3})

#以元组列表的形式，从高到底返回结果
In [22]: c.most_common()
Out[22]: [('d', 11), ('c', 8), ('b', 4), ('a', 3)]

#指定返回几个结果
In [23]: c.most_common(2)
Out[23]: [('d', 11), ('c', 8)]

In [24]: c.clear()

In [25]: c
Out[25]: Counter()

In [26]: c.most_common()
Out[26]: []
```

```python
#列出所有唯一的元素
In [27]: c=Counter(letters)

In [28]: c
Out[28]: Counter({'d': 11, 'c': 8, 'b': 4, 'a': 3})

In [29]: list(c)
Out[29]: ['a', 'b', 'c', 'd']


```

### defaultdict

> 在循环或常规操作中访问一个不存在的键，它不会报错，而是会自动为这个新键创建一个默认值

```python
In [31]: from collections import defaultdict

In [32]: d={'a':10}

In [33]: d['a']
Out[33]: 10

In [34]: d['WRONG']
---------------------------------------------------------------------------
KeyError                                  Traceback (most recent call last)
Cell In[34], line 1
----> 1 d['WRONG']

KeyError: 'WRONG'

In [36]: d=defaultdict(lambda:0)

In [37]: d['correct']=100

In [38]: d['correct']
Out[38]: 100

In [39]: d['WRONG KEY!']
Out[39]: 0

In [40]: d
Out[40]: defaultdict(<function __main__.<lambda>()>, {'correct': 100, 'WRONG KEY!': 0})

```

### 具名元组

> namedtuple，通过为元组中的元素提供命名索引 ~~也就是原来得通过mytuple[0]，mytuple[1]这样，现在可以通过mytuple.name之类~~ 来扩展普通元组

```python
In [43]: mytuple=(10,20,30)

In [44]: mytuple[0]
Out[44]: 10
```

```python
In [50]: from collections import namedtuple

In [51]: Dog=namedtuple('Dog',['age','breed','name'])

In [52]: sammy=Dog(age=5,name='Sam',breed='Husky')

In [53]: type(sammy)
Out[53]: __main__.Dog

In [54]: class LyClass:
    ...:     pass
    ...:

In [55]: type(LyClass())
Out[55]: __main__.LyClass

In [56]: sammy
Out[56]: Dog(age=5, breed='Husky', name='Sam')

#属性不可修改
In [57]: sammy.age=11
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Cell In[57], line 1
----> 1 sammy.age=11

AttributeError: can't set attribute
```

> 对比

```python
In [58]: simple_dog=(5,'Husky','Sam')

In [59]: Dog=namedtuple('Dog',['age','breed','name'])

In [60]: namedtuple_dog=Dog(age=5,breed='Husky',name='Sam')

In [61]: namedtuple_dog.age
Out[61]: 5
```

> 其他例子

坐标：

```python
Point = namedtuple('Point',['x','y'])

p = Point(10,20)
```

配置：

```python
Config = namedtuple('Config',['host','port'])

c = Config('localhost',3306)
```

数据库返回结果：

```python
User = namedtuple('User',['id','name'])

u = User(1,'Tom')

#访问
u.id
u.name
```

这些对象只是：

```
存几个值，并且希望通过名字访问。
```


