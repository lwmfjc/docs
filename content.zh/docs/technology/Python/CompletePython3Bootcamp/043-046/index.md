---
title: 043-046
description: 043-046
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-01T16:45:25+08:00
lastmod: 2026-09-01T16:45:25+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 列表多种添加元素的办法  

```shell
>>> mylist=[1,2,3]
#在末尾添加
>>> mylist.append(4)
>>> mylist
[1, 2, 3, 4]
#把另一个列表中元素一个个添加（保持原顺序）
>>> mylist.extend([4,5,6])
>>> mylist
[1, 2, 3, 4, 4, 5, 6]
#在位置1（0是首位）放置元素200
>>> mylist.insert(1,200)
>>> mylist
[1, 200, 2, 3, 4, 4, 5, 6]
#列表相加（非原地操作）
>>> mylist+[500,600]
[1, 200, 2, 3, 4, 4, 5, 6, 500, 600]

```

# 列表推导式

列表推导式，用来替代这样的情景：需要使用for循环或append语句反复遍历来创建列表   

```shell
>>> for letter in mystring:
...     mylist.append(letter)
...     
>>> mylist
['h', 'e', 'l', 'l', 'o']

>>> mylist=[]
#从某个可迭代对象(另一个列表)中，按元素逐个取出
>>> mylist=[letter for letter in mystring] #和上面的for in 语句差不多的效率
>>> mylist
['h', 'e', 'l', 'l', 'o']
```

~~range(start, stop, step)，当range只有一个参数时，参数指的是stop，此时start为0，step为1；range函数是一个生成器：可迭代对象~~    

```shell
>>> mylist=[]
>>> mylist=[x for x in range(0,11)]
>>> mylist
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
>>> range(0,11)
range(0, 11)

```

## 进阶

```shell
>>> mylist=[x**2 for x in range(0,11)]
>>> mylist
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
>>> mylist=[x for x in range(0,11)]
#加条件，对[0,11)取数，仅当x%2 == 0 才取
>>> mylist = [x for x in range(0,11) if x%2==0 ]
>>> mylist
[0, 2, 4, 6, 8, 10]

```

更复杂的表达式  

```shell
>>> celcius=[0,10,20,34.5]
>>> fahrenheit=[(9/5*temp+32) for temp in celcius]
>>> fahrenheit
[32.0, 50.0, 68.0, 94.1]

>>> fahrenheit=[ 9 / 5 * temp + 32 for temp in celcius]
>>> fahrenheit
[32.0, 50.0, 68.0, 94.1]
#空格不是必须的
>>> fahrenheit=[9/5*temp+32 for temp in celcius]
>>> fahrenheit
[32.0, 50.0, 68.0, 94.1]
#相当于
>>> fahrenheit2=[]
>>> for temp in celcius:
...     fahrenheit2.append(((9/5)*temp+32))
...     
>>> fahrenheit2
[32.0, 50.0, 68.0, 94.1]

```

## 使用if-else（不推荐）

```shell
#遍历(0,10]，如果x为偶数则输出它自己；如果x为奇数，则输出0DD
>>> results=[x if x%2==0 else '0DD' for x in range(0,11)]
>>> results
[0, '0DD', 2, '0DD', 4, '0DD', 6, '0DD', 8, '0DD', 10]

```

## 嵌套（不推荐）

```shell
>>> mylist=[x*y for x in [2,4,6] for y in [1,10,1000]]
>>> mylist
[2, 20, 2000, 4, 40, 4000, 6, 60, 6000]

```

# 小测试

```shell
>>> st='Print only the words that start with s in his sentence'
>>> st.split() #默认以空格分割
['Print', 'only', 'the', 'words', 'that', 'start', 'with', 's', 'in', 'his', 'sentence']

>>> st='Print  only the words that start with s in his sentence'
>>> st.split()
['Print', 'only', 'the', 'words', 'that', 'start', 'with', 's', 'in', 'his', 'sentence']
>>> st.split()
KeyboardInterrupt
>>> st2='aa234aaa324aaaa54'
>>> st2.split('a')
['', '', '234', '', '', '324', '', '', '', '54']
>>> st2='  234   324    54'
>>> st2.split('')
Traceback (most recent call last):
  File "<python-input-7>", line 1, in <module>
    st2.split('')
    ~~~~~~~~~^^^^
ValueError: empty separator
>>> st2.split() #比较特殊，如果是多个空格，并不会在空格与空格之间切分成空字符串
['234', '324', '54']

```