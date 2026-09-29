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

```python

In [2]: s='hello world'

#非原地操作
In [3]: s.upper()
Out[3]: 'HELLO WORLD'

In [4]: s
Out[4]: 'hello world'

In [6]: s.lower()
Out[6]: 'hello world'

#非原地操作
In [7]: s.capitalize()
Out[7]: 'Hello world'

In [9]: s.count('o')
Out[9]: 2

In [10]: s.find('o')
Out[10]: 4
```

> 将s居中，放置到某个字符 ~~必须是单个~~ 中间

```python
In [12]: s
Out[12]: 'hello world'

In [13]: s.center(20,'z')
Out[13]: 'zzzzhello worldzzzzz'

In [14]: s.center(21,'z')
Out[14]: 'zzzzzhello worldzzzzz'

In [15]: s.center(22,'z')
Out[15]: 'zzzzzhello worldzzzzzz'

```

> 制表符

```python
In [20]: print('hello\thi')
hello   hi

In [21]: 'hello\thi'.expandtabs()
Out[21]: 'hello   hi'

In [22]: 'hello\nhi'.expandtabs()
Out[22]: 'hello\nhi'

```


```python
In [23]: s='hello'

#字符串中所有字符是否都是字母数字
#al：代表 alphabetic（字母的，包含 A-Z、a-z 以及其他语言的字符）
#num：代表 numeric（数字的，即 0-9）
In [24]: s.isalnum()
Out[24]: True

In [25]: s.isalpha()
Out[25]: True

#下划线不算
In [26]: '_aA'.isalpha()
Out[26]: False

In [27]: 'aA'.isalpha()
Out[27]: True

In [28]: '_aA'.isalnum()
Out[28]: False

In [29]: '_123'.isalnum()
Out[29]: False

#所有字符都是小写字符（不包括数字，但包括下划线）
In [30]: '123'.islower()
Out[30]: False

In [31]: '_abc'.islower()
Out[31]: True

In [32]: 'c'.islower()
Out[32]: True

#所有字符都是空白字符
In [34]: ' '.isspace()
Out[34]: True

In [35]: ' \t'.isspace()
Out[35]: True

In [36]: ' \t\n'.isspace()
Out[36]: True

In [37]: ' \t\n1'.isspace()
Out[37]: False

#首字母大写其他全部小写
In [39]: 'Abc'.istitle()
Out[39]: True

In [40]: 'Abc aB'.istitle()
Out[40]: False

In [41]: ' Abc aB'.istitle()
Out[41]: False

#也不允许中间有空白
In [42]: 'Abc a'.istitle()
Out[42]: False


In [43]: 'Abca'.istitle()
Out[43]: True

#允许左右两边有空白
In [44]: 'Abca '.istitle()
Out[44]: True

In [45]: ' Abca '.istitle()
Out[45]: True


```

```python
In [47]: 'Abc'.isupper()
Out[47]: False

In [48]: 'AB'.isupper()
Out[48]: True

```

```python
In [51]: s
Out[51]: 'hello'

In [52]: s.endswith('o')
Out[52]: True

In [53]: s[-1]=='o'
Out[53]: True

#注意，字符串是不可变的
In [54]: s[1]='a'
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[54], line 1
----> 1 s[1]='a'

TypeError: 'str' object does not support item assignment
```


```python
In [56]: s
Out[56]: 'hello'

In [57]: s.split('e')
Out[57]: ['h', 'llo']

In [58]: s='hiihihhissisiih'

In [59]: s.split('i')
Out[59]: ['h', '', 'h', 'hh', 'ss', 's', '', 'h']

#只会在第一个i出现时分割
In [60]: s.partition('i')
Out[60]: ('h', 'i', 'ihihhissisiih')
```

# 高级集合

```python
In [2]: s=set()

In [3]: s.add(1)

In [4]: s.add(2)

In [5]: s
Out[5]: {1, 2}

In [6]: s.add(1)

In [7]: s
Out[7]: {1, 2}

In [8]: s.clear()

In [9]: s
Out[9]: set()

#返回副本
In [11]: s1={1,2,3}

In [12]: s2=s1.copy()

In [13]: s1.add(4)

In [14]: s1
Out[14]: {1, 2, 3, 4}

In [15]: s2
Out[15]: {1, 2, 3}

#s2中，查找s1没有的部分(集合)
In [16]: s2.difference(s1)
Out[16]: set()

#s1中，查找s2没有的部分(集合)
In [17]: s1.difference(s2)
Out[17]: {4}

In [30]: s1={1,2,3}

In [31]: s2={1,4,5}

#s1中，查找s2没有的部分(集合)
In [32]: s1.difference(s2)
Out[32]: {2, 3}

#s1中，只留下s2没有的部分
In [33]: s1.difference_update(s2)

In [34]: s1
Out[34]: {2, 3}

In [35]: s2
Out[35]: {1, 4, 5}
```

```python
In [38]: s
Out[38]: {1, 2, 3, 4}

In [39]: s.discard(2)

In [40]: s
Out[40]: {1, 3, 4}

#移除集合中的元素，如果元素不在则什么都不做
In [41]: s.discard(22)

In [42]: s
Out[42]: {1, 3, 4}

#交集
In [44]: s1={1,2,3}

In [45]: s2={1,2,4}

In [46]: s1.intersection(s2)
Out[46]: {1, 2}

#s1只留下两集合的交集
In [47]: s1.intersection_update(s2)

In [48]: s1
Out[48]: {1, 2}

In [49]: s2
Out[49]: {1, 2, 4}


```

> 交集

```python
In [51]: s1={1,2}
    ...: s2={1,2,4}
    ...: s3={5}
    ...:
    ...:

#交集为空则True，有交集则是False
In [52]: s1.isdisjoint(s2)
Out[52]: False

In [53]: s1.isdisjoint(s3)
Out[53]: True

#s1是s2的子集(≤)
In [54]: s1.issubset(s2)
Out[54]: True

In [59]: s1.issubset(s1)
Out[59]: True

In [55]: s3.issubset(s2)
Out[55]: False

#s2是否是s1的超集（≥)
In [56]: s2.issuperset(s1)
Out[56]: True

In [58]: s2.issuperset(s2)
Out[58]: True


```