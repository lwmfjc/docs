---
title: "117正则2：标识符语法构建实际模式"
description: "117正则2：标识符语法构建实际模式"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-26T18:00:44+08:00
lastmod: 2026-09-26T18:00:44+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
> 上一篇讲了使用正则表达式库，以及如何使用常规字符串（固定字符串），进行模式搜索。本讲构建自己模式序列的特殊模式代码

| 字符  | 描述                    | 示例模式代码       | 示例匹配    |
| --- | --------------------- | ------------ | ------- |
| \d  | 一个数字                  | file_\d\d    | file_25 |
| \w  | 字母数字字符<br>（下划线或大小写英文） | \w-\w\w\w\w  | A-b_1   |
| \s  | 空白字符                  | a\sb\sc      | a b c   |
| \D  | 非数字                   | \D\D\D       | ABC     |
| \W  | 非字母数字字符               | \W\W\W\W\W   | *+=)    |
| \S  | 非空白字符                 | \S\S\S\S\S\S | Yoyo    |

> 字符串开头加一个 r ，表示字符串里的\d不是真正的 \t制表符或者\n换行符，而只是将它用于正则表达式的模式

```python
In [5]: import re

In [6]: text='My phone number is 408-555-1234'

In [7]: phone=re.search('408-555-1234',text)

In [8]: phone
Out[8]: <re.Match object; span=(19, 31), match='408-555-1234'>

In [9]: phone=re.search(r'\d\d\d-\d\d\d-\d\d\d\d',text)

In [10]: phone
Out[10]: <re.Match object; span=(19, 31), match='408-555-1234'>

In [11]: phone.group()
Out[11]: '408-555-1234'

#phone.group() 只是读取已经保存下来的 Match 对象里的匹配结果，不会再次执行正则匹配。
In [12]: phone.group()
Out[12]: '408-555-1234'

In [13]: phone.group()
Out[13]: '408-555-1234'
```

> 使用量词

| 字符 | 描述 | 示例模式代码 | 示例匹配 |
| ---- | ---- | ------------ | -------- |
| + | 出现一次或多次 | Version \w-\w+ | Version A-b1_1 |
| {3} | 恰好出现 3 次 | \D{3} | abc |
| {2,4} | 出现 2 到 4 次 | \d{2,4} | 123 |
| {3,} | 出现至少 3 次 | \w{3,} | anycharacters |
| * | 出现零次或多次 | ABC* | AAACC |
| ? | 出现一次或零次 | plurals? | plural |

```python
In [15]: text
Out[15]: 'My phone number is 408-555-1234'

In [16]: phone=re.search(r'\d{3}-\d{3}-\d{4}',text)

In [17]: phone
Out[17]: <re.Match object; span=(19, 31), match='408-555-1234'>
```

# 使用compile

```python

In [18]: phone_pattern=re.compile(r'(\d{3})-(\d{3})-(\d{4})')

In [19]: results=re.search(phone_pattern,text)

In [20]: results.group()
Out[20]: '408-555-1234'

In [21]: results.group(1) #从1开始索引
Out[21]: '408'

In [22]: results.group(2) #从1开始索引
Out[22]: '555'

In [23]: results.group(3) #从1开始索引
Out[23]: '1234'

In [24]: results.group(-1) #从1开始索引
---------------------------------------------------------------------------
IndexError                                Traceback (most recent call last)
Cell In[24], line 1
----> 1 results.group(-1) #从1开始索引

IndexError: no such group

#这是一个正则对象
In [25]: type(phone_pattern)
Out[25]: re.Pattern

In [26]: phone_pattern
Out[26]: re.compile(r'(\d{3})-(\d{3})-(\d{4})', re.UNICODE)
```

> 也可以不使用re.compile编译而是直接用字符串

```python
In [27]: phone_1=re.search(r'(\d{3})-(\d{3})-(\d{4})',text)

In [28]: phone_1
Out[28]: <re.Match object; span=(19, 31), match='408-555-1234'>

In [29]: phone_1.group()
Out[29]: '408-555-1234'

In [30]: phone_1.group(1)
Out[30]: '408'

In [31]: phone_1.group(2)
Out[31]: '555'

In [32]: phone_1.group(3)
Out[32]: '1234'
```

> re.search() 可以接受字符串，也可以接受 Pattern。传字符串时，它会先把字符串编译成 Pattern；传 Pattern 时，直接使用已经编译好的规则。

