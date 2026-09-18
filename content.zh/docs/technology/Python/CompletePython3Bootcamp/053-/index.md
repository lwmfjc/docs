---
title: 053-
description: 053-
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-18T11:08:36+08:00
lastmod: 2026-09-18T11:08:36+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 函数之间的交互

```python
In [1]: example=[1,2,3,4,5]

In [2]: from random import shuffle #shuffle函数会原地打乱列表，即不返回任何东西

In [3]: shuffle(example)

In [4]: example
Out[4]: [2, 3, 1, 4, 5]

In [5]: shuffle(example)

In [6]: example
Out[6]: [5, 1, 3, 4, 2]
```

```python
In [7]: result =shuffle(example)

In [8]: result

In [9]: type(result)
Out[9]: NoneType

```

由于shuffle函数没有任何返回值，所以教程要求创建一个函数可以返回打乱后的列表  

```python
In [16]: example
Out[16]: [4, 2, 5, 1, 3]

In [17]: def shuffle_list(mylist):
    ...:     shuffle(mylist)
    ...:     return mylist
    ...:

In [18]: shuffle_list(example)
Out[18]: [1, 4, 3, 2, 5]
```

## 菜单游戏

下面会玩一个猜彩蛋的游戏，字符串列表表示彩蛋在其中之一，'O'表示彩蛋。

### 函数定义

```python
In [20]: mylist=[' ','O',' ']

In [21]: shuffle_list(mylist)
Out[21]: [' ', ' ', 'O']

#1接收用户输入
In [25]: def player_guess():
    ...:     guess=''
    ...:     while guess not in ['0','1','2']:
    			 #input总会返回一个字符串，所以接受后return要把它转为整数
    ...:         guess=input("pick a number: 0 , 1 or 2---")
    ...:     return int(guess)
    ...:

In [26]: player_guess()
pick a number: 0 , 1 or 2---34
pick a number: 0 , 1 or 2---2
Out[26]: 2

#2判断是否猜中
In [27]: def check_guess(mylist,guess):
    ...:     if mylist[guess] == 'O':
    ...:         print("Correct!")
    ...:     else:
    ...:         print("Wrong guess!")
    ...:         print(mylist)
    ...:

In [28]: myindex=player_guess()
pick a number: 0 , 1 or 2---d
pick a number: 0 , 1 or 2---323
pick a number: 0 , 1 or 2---1

In [29]: myindex
Out[29]: 1

```

### 函数使用

```python
#初始化列表
In [35]: mylist=[' ','O',' ']

#打乱列表
In [36]: mixedup_list=shuffle_list(mylist)

#得到用户猜测
In [37]: guess=player_guess()
pick a number: 0 , 1 or 2---r
pick a number: 0 , 1 or 2---e
pick a number: 0 , 1 or 2---2

#检验猜测
In [38]: check_guess(mixedup_list,guess)
Correct!

In [39]: guess=player_guess()
pick a number: 0 , 1 or 2---1

In [40]: check_guess(mixedup_list,guess)
Wrong guess!
[' ', ' ', 'O']
```

# Python中的`*args`和`**kwargs`

分别代表arguments（参数）以及 keyword arguments（关键字参数）  
***用来接收任意数量的参数***  



