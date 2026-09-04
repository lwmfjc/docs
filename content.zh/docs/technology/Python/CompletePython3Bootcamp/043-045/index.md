---
title: 043-045
description: 043-045
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


```

```shell
#split深究

#split() 会把 a 去掉，然后看 a 两边(左边直到上一个a或者字符串开头，右边直到下一个a或者结尾)分别有什么：
>>> st2='aa234aaa324aaaa54'
>>> st2.split('a')
['', '', '234', '', '', '324', '', '', '', '54']
>>> st2='  234   324    54' #'(2空格)234(3空格)324(4空格)54'
>>> st2.split('')
Traceback (most recent call last):
  File "<python-input-7>", line 1, in <module>
    st2.split('')
    ~~~~~~~~~^^^^
ValueError: empty separator
>>> st2.split() #比较特殊，如果是多个空格，并不会在空格与空格之间切分成空字符串
['234', '324', '54']
>>> st2.split(' ')
['', '', '234', '', '', '324', '', '', '', '54']
>>> 'sf  \n \t  a\tb'.split()
['sf', 'a', 'b']


>>> "aaa".split("a")
['', '', '', '']
>>> "123a456".split("a")
['123', '456']
>>> "a123".split("a")
['', '123']
>>> "123a".split("a")
['123', '']

```

```shell
>>> st='Print  only the words that start with s in his sentence'
>>> for word in st.split():
...     if(word.startswith('s')):
...         print(word)
...         
start
s
sentence
>>> for word in st.split():
...     if(word[0]=='s'):
...         print(word)
...         
start
s
sentence
```

```shell
>>> for x in range(0,11):
...     if(x%2==0):
...         print(x)
...         
0
2
4
6
8
10

>>> print([x for x in range(1,51) if x%3 == 0])
[3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48]

>>> st='Print  only the words that start with s in his sentence'
>>> for word in st.split():
...     if(len(word)%2==0):
...         print(word+' is even')
...     else:
...         print(word)
...         
Print
only is even
the
words
that is even
start
with is even
s
in is even
his
sentence is even

```

```shell
>>> st='Create a list of the first letters of every word in this string'
>>> [x[0] for x in st.split()]
['C', 'a', 'l', 'o', 't', 'f', 'l', 'o', 'e', 'w', 'i', 't', 's']

#fizzbuzz问题
>>> for num in range(1,101):
...     if (num%3==0 and num%5==0):
...         print('fizzbuzz')
...     elif (num%3==0):
...         print('fizz')
...     elif (num%5==0):
...         print('buzz')
...     else:
...         print(num)
...         
1
2
fizz
4
buzz
fizz
7
8
fizz
buzz
11
fizz
13
14
fizzbuzz
16
17
fizz
19
buzz
fizz
22
23
fizz
buzz
26
fizz
28
29
fizzbuzz
31
32
fizz
34
buzz
fizz
37
38
fizz
buzz
41
fizz
43
44
fizzbuzz
46
47
fizz
49
buzz
fizz
52
53
fizz
buzz
56
fizz
58
59
fizzbuzz
61
62
fizz
64
buzz
fizz
67
68
fizz
buzz
71
fizz
73
74
fizzbuzz
76
77
fizz
79
buzz
fizz
82
83
fizz
buzz
86
fizz
88
89
fizzbuzz
91
92
fizz
94
buzz
fizz
97
98
fizz
buzz

```

