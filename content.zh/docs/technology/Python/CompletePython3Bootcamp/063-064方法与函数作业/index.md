---
title: "063-064方法与函数作业"
description: "063-064方法与函数作业"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-19T10:10:35+08:00
lastmod: 2026-09-19T10:10:35+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 方法与函数作业解答

> 计算4/3xπxr^3

```python
#计算4/3xπxr^3
In [1]: import math

In [2]: def vol(rad):
   ...:     return 4/3*math.pi*rad**3
   ...:
 
In [4]: vol(2)
Out[4]: 33.510321638291124
```

------

> 判断一个数是否在给定的上下界之间

```python
In [2]: def ran_check(num,low,high):
   ...:     if(num>=low and num <= high):
   ...:         return True
   ...:     else:
   ...:         return False
   ...:

In [3]: ran_check(5,2,7)
Out[3]: True

In [4]: def ran_check(num,low,high):
   ...:     return num in range(low,high+1)
   ...:

In [5]: ran_check(5,2,7)
Out[5]: True
```

------

> 判断字符串的大小字符个数(方法1)

```python
In [10]: def up_low(s):
    ...:     lowercase=0
    ...:     uppercase=0
    ...:     for char in s:
    ...:         if char.isupper():
    ...:             uppercase+=1
    ...:         elif(char.islower()):
    ...:             lowercase+=1
    ...:     print(f'uppercase num:{uppercase}')
    ...:     print(f'lowercase num:{lowercase}')
    ...:

In [11]: up_low('Hello Mr. Rogers, how are you this fine Tuesday?')
uppercase num:4
lowercase num:33
```

------

> 判断字符串的大小字符个数(方法2)

```python
In [12]: def up_low(s):
    ...:     d={'upper':0,'lower':0}
    ...:     for char in s:
    ...:         if char.isupper():
    ...:             d['upper']+=1
    ...:         elif(char.islower()):
    ...:             d['lower']+=1
    ...:     print(f'uppercase num:{d['upper']}')
    ...:     print(f'lowercase num:{d['lower']}')
    ...:

In [13]: up_low('Hello Mr. Rogers, how are you this fine Tuesday?')
uppercase num:4
lowercase num:33
```

------

> 写一个Python函数，接收一个列表，返回新列表（只包含原列表唯一元素）

```python
In [17]: def unique_list(lst):
    ...:     return set(lst)
    ...:

In [18]: unique_list([1,1,1,1,2,2,3,3,3,4,4,5,6])
Out[18]: {1, 2, 3, 4, 5, 6}

#或者遍历
In [20]: def unique_list(lst):
    ...:     result_lst=[]
    ...:     for item in lst:
    ...:         if(item not in result_lst):
    ...:             result_lst.append(item)
    ...:     return result_lst
    ...:

In [21]: unique_list([1,1,1,1,2,2,3,3,3,4,4,5,6])
Out[21]: [1, 2, 3, 4, 5, 6]
```

------

> 将列表所有数字相乘

```python
In [22]: def multiply(numbers):
    ...:     total=1
    ...:     for num in numbers:
    ...:         total=total*num
    ...:     return total
    ...:

In [23]: multiply([1,2,3,-4])
Out[23]: -24
```

------

用 Python 编写一个函数，用来判断一个单词或短语是否为回文（palindrome）。   

题目核心要求：

- 定义：回文是指正着读和倒着读都一样的单词、短语或序列。例如：   
    - 单词：madam、kayak、racecar   
    - 短语（包含空格）：nurses run   
- 提示（Hint）：   
    - 可以使用字符串的 .replace() 方法来处理空格等字符。
    - 可以利用 Python 的切片（slice）语法来巧妙地反转字符串。

```python
In [26]: def palindrome(s):
    ...:     s=s.replace(' ','')
    ...:     if(s[::-1]==s):
    ...:         return True
    ...:     else:
    ...:         return False
    ...:

In [27]: palindrome('123a')
Out[27]: False

In [28]: palindrome('12321')
Out[28]: True
```

------

> 编写一个 Python 函数，用来检查给定的字符串是否为“全字母句”（Pangram，即包含从 a 到 z 所有字母的句子），并假设传入的字符串不包含任何标点符号。

> string.ascii_lowercase 是 Python 内置 string 模块中的常量，值为全小写字母 abcdefghijklmnopqrstuvwxyz。


```python
In [60]: set('abcd')
Out[60]: {'a', 'b', 'c', 'd'}


In [55]: import string

In [56]: def ispangram(str1,alphabet=string.ascii_lowercase):
    ...:     #创建集合
    ...:     alphaset=set(alphabet)
    ...:     #去除空格
    ...:     str1=str1.replace(' ','')
    ...:     #转换为小写
    ...:     str1=str1.lower()
    ...:     #字符串转换为set
    ...:     str1=set(str1)
    ...:     #两个set是否相等（set之间不比较顺序）
    ...:     return str1==alphaset
    ...:

In [57]: ispangram('abcd')
Out[57]: False

In [58]: ispangram('abfghijklmnopqrstuvwx y zcde')
Out[58]: True

In [59]: ispangram('abfghijklmnopqrstuvwx y zce')
Out[59]: False
```