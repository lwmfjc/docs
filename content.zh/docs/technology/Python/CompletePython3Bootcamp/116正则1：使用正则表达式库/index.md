---
title: "116正则1：使用正则表达式库"
description: "116正则1：使用正则表达式库"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-26T17:03:54+08:00
lastmod: 2026-09-26T17:03:54+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

> Regular Expressions(regex) 

> regex (ˈrɛɡɛks)，简称RE，读  /riː/ 或者 读作两个字母：R + E：/ɑːr iː/

> 有时候我们不知道确定搜索字符串，只知道模糊的。比如`xxx@163.com`，或者知道是`text+@+text+.com`，或者是某位数数字

> Python自带RE库，允许我们创建专门的模式字符串，然后在文本中搜索匹配项

- re 库允许我们创建特定的模式字符串，然后在文本中搜索匹配项。
- 正则表达式的核心技能是理解这些模式字符串的特殊语法。

> 了解如何使用***正则表达式库***在文本中搜索模式，然后我们将重点理解正则表达式的实际语法代码

> 简单查找

```python
In [2]: text="The agent's phone number is 408-555-1234. Call soon!"

In [3]: 'phone' in text
Out[3]: True

In [4]: import re

In [5]: pattern='phone'

In [7]: reresult=re.search(pattern,text)

In [24]: reresult==None
Out[24]: False

In [25]: reresult
Out[25]: <re.Match object; span=(12, 17), match='phone'>

In [27]: text
Out[27]: "The agent's phone number is 408-555-1234. Call soon!"

In [28]: pattern='NOT IN TEXT'

In [29]: re.search(pattern,text)

In [30]: re.search(pattern,text) == None
Out[30]: True

In [31]: reresult1=re.search(pattern,text)

In [32]: reresult1

```

> 一些方法

```python
In [34]: pattern='phone'

In [35]: text
Out[35]: "The agent's phone number is 408-555-1234. Call soon!"

In [36]: match=re.search(pattern,text)

In [37]: match
Out[37]: <re.Match object; span=(12, 17), match='phone'>

#获取实际的索引位置
In [38]: match.span()
Out[38]: (12, 17)

In [39]: match.start()
Out[39]: 12

In [40]: match.end()
Out[40]: 17

```

> 查找多个

```python
In [41]: text='my phone once,my phone twice'

In [42]: match=re.search('phone',text)

#只查找了第一个匹配项
In [43]: match
Out[43]: <re.Match object; span=(3, 8), match='phone'>

#返回包含匹配项的列表（不是无意义，因为这里是固定字符串，而很多时候是模糊的正则匹配）
In [44]: matches=re.findall('phone',text)

In [45]: matches
Out[45]: ['phone', 'phone']

In [46]: type(matches)
Out[46]: list
```

> 迭代器

```python
In [48]: for match in re.finditer('phone',text):
    ...:     print(match)
    ...:
<re.Match object; span=(3, 8), match='phone'>
<re.Match object; span=(17, 22), match='phone'>

#这是个迭代器
In [49]: re.finditer('phone',text)
Out[49]: <callable_iterator at 0x758389c29180>

In [50]: type(re.finditer('phone',text))
Out[50]: callable_iterator

In [51]: for match in re.finditer('phone',text):
    ...:     print(match.span())
    ...:
(3, 8)
(17, 22)

In [52]: for match in re.finditer('phone',text):
    ...:     print(match.group())
    ...:
phone
phone
```

> 接下来讨论 通用模式的特殊***正则表达式语法***

