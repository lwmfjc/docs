---
title: "118正则3：or_通配符_量词_排除"
description: "118正则3：or_通配符_量词_排除"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-26T18:48:44+08:00
lastmod: 2026-09-26T18:48:44+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

```python
In [3]: import re

#or
In [4]: re.search(r'cat|dog','the cat is here')
Out[4]: <re.Match object; span=(4, 7), match='cat'>

In [5]: re.findall(r'at','The cat in the hat sat there.')
Out[5]: ['at', 'at', 'at']

#通配符
In [6]: re.findall(r'.at','The cat in the hat sat there.')
Out[6]: ['cat', 'hat', 'sat']

In [8]: re.findall(r'...at','The cat in the hat went splat.')
Out[8]: ['e cat', 'e hat', 'splat']
```

```python
#以数字开头的匹配项（这里说的开头指的是整个文本开头）
In [10]: re.findall(r'^\d','1 is a number')
Out[10]: ['1']

In [11]: re.findall(r'^\d','the 1 is a number')
Out[11]: []

In [14]: re.findall(r'\d$','the number is 2')
Out[14]: ['2']
```

- `^`	整个字符串开头
- `$`	整个字符串结尾

```python
In [16]: phrase='there are 3 numbers 34 inside 5 this sentence'

In [17]: pattern=r'[^\d]'

#得到一个列表，包含每一个不是数字的字符
In [18]: re.findall(pattern,phrase)
Out[18]:
['t',
 'h',
 'e',
 'r',
 'e',
 ' ',
 'a',
 'r',
 'e',
 ' ',
 ' ',
 'n',
 'u',
 'm',
 'b',
 'e',
 'r',
 's',
 ' ',
 ' ',
 'i',
 'n',
 's',
 'i',
 'd',
 'e',
 ' ',
 ' ',
 't',
 'h',
 'i',
 's',
 ' ',
 's',
 'e',
 'n',
 't',
 'e',
 'n',
 'c',
 'e']
```

> 查找所有没有数字的字符(串)

```python
In [28]: phrase='there are 3 numbers 34 inside 5 this sentence'

In [29]: pattern=r'[^\d]+'

In [30]: re.findall(pattern,phrase)
Out[30]: ['there are ', ' numbers ', ' inside ', ' this sentence']
```

> 也可以用来排除标点符号

```python
In [32]: test_phrase='This is a string! But it has puntuation. How can we remove it ?

In [33]: re.findall(r'[^!.?]+',test_phrase)
Out[33]: ['This is a string', ' But it has puntuation', ' How can we remove it ']

#空格也移除
In [34]: re.findall(r'[^!.? ]+',test_phrase)
Out[34]:
['This',
 'is',
 'a',
 'string',
 'But',
 'it',
 'has',
 'puntuation',
 'How',
 'can',
 'we',
 'remove',
 'it']
 
 #连接
In [35]: clean=re.findall(r'[^!.? ]+',test_phrase)

In [36]: ''.join(clean)
Out[36]: 'ThisisastringButithaspuntuationHowcanweremoveit'
```

> 包含的分组

```python
In [38]: text='only find the hypen-words in this sentence.But you do not know how lon
       ⋮ g-ish the are'

In [39]: pattern=r'[\w]+'

In [40]: re.findall(pattern,text)
Out[40]:
['only',
 'find',
 'the',
 'hypen',
 'words',
 'in',
 'this',
 'sentence',
 'But',
 'you',
 'do',
 'not',
 'know',
 'how',
 'long',
 'ish',
 'the',
 'are']
 
 
```

> 找到破折号的单词

```python
In [43]: pattern=r'[\w]+-[\w]+'

In [44]: re.findall(pattern,text)
Out[44]: ['hypen-words', 'long-ish']
```

> 没有方块号也不影响结果。但是方括号可以用来分割组，还可以将多个组合在一起

```python
In [45]: pattern=r'\w+-\w+'

In [46]: re.findall(pattern,text)
Out[46]: ['hypen-words', 'long-ish']


```

> 括号里放or表示多种可能

> 允许or将其他文本片段结合起来

```python
In [50]: text = 'Hello, would you like some catfish?'

In [51]: texttwo = "Hello, would you like to take a catnap?"

In [52]: textthree = "Hello, have you seen this caterpillar?"

In [53]: re.search(r'cat(fish|nap|claw)',text)
Out[53]: <re.Match object; span=(27, 34), match='catfish'>

In [54]: re.search(r'cat(fish|nap|claw)',texttwo)
Out[54]: <re.Match object; span=(32, 38), match='catnap'>

In [55]: re.search(r'cat(fish|nap|claw)',textthree)

In [56]: re.search(r'cat(fish|nap|erpillar)',textthree)
Out[56]: <re.Match object; span=(26, 37), match='caterpillar'>
```

> 主要思想，就是你有某种字符标识符，然后如果需要的话，附加某种量词

