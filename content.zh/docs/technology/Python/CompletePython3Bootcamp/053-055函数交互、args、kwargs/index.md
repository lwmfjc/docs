---
title: "053-055函数交互、args、kwargs"
description: "053-055函数交互、args、kwargs"
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

## 可扩展的固定参数

```python
In [2]: def myfunc(a,b):
   ...:     # Return 5% of the sum of a and b
   ...:     pass
   ...:     pass
   ...:     return sum((a,b))*0.05
   ...:

In [3]: myfunc(10,20)
Out[3]: 1.5

In [4]: def myfunc(a,b,c=0,d=0):
   ...:     # Return 5% of the sum of a and b
   ...:     pass
   ...:     pass
   ...:     return sum((a,b,c,d))*0.05
   ...:

In [5]: myfunc(10,20)
Out[5]: 1.5

In [6]: myfunc(10,20,30,40)
Out[6]: 5.0

#只能添加2-4个参数
In [8]: myfunc(10,20,30,40,4)
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[8], line 1
----> 1 myfunc(10,20,30,40,4)

TypeError: myfunc() takes from 2 to 4 positional arguments but 5 were given
```

## 可扩展的任意数量参数`*args`

```python
#*args，允许将传入的参数作为一个元组来处理，即参数元组
In [10]: def myfunc(*args):
    ...:     return sum(args)*0.05
    ...:

In [11]: myfunc(10,20,30,40,4)
Out[11]: 5.2

In [12]: myfunc(10,20)
Out[12]: 1.5

In [13]: myfunc(10,20,4,3,2,11,2)
Out[13]: 2.6
```

- 如果args前面有固定参数，他是不接收的：  
- 只要前面是星号就行，不一定是args这个字符串 ~~也可以是abc~~ 

```python
In [14]: def myfunc(a1,*args):
    ...:     return sum(args)*0.05
    ...:

In [15]: myfunc(10)
Out[15]: 0.0

In [16]: myfunc(10,100)
Out[16]: 5.0

In [17]: myfunc(10,100,900)
Out[17]: 50.0

In [18]: def myfunc(a1,*args):
    ...:     print(args)
    ...:

In [19]: myfunc(10,100,900)
(100, 900)

#这里把*args修改成*abc
In [20]: def myfunc(a1,*abc):
    ...:     print(abc)
    ...:

In [21]: myfunc(10,100,900)
(100, 900)

In [22]: def myfunc(a1,*a1):
    ...:     print(a1)
  Cell In[22], line 1
    def myfunc(a1,*a1):
                   ^
SyntaxError: duplicate argument 'a1' in function definition
```

其他错误：  

```python
#如果这样定义，永远接收不到b3
In [54]: def myfunc78(a1,*abc,b3):
    ...:     print(abc)
    ...:

In [55]: myfunc78(1,2,3,4)
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[55], line 1
----> 1 myfunc78(1,2,3,4)

TypeError: myfunc78() missing 1 required keyword-only argument: 'b3'

In [56]: myfunc78(1,2,3,(3,4,5))
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[56], line 1
----> 1 myfunc78(1,2,3,(3,4,5))

TypeError: myfunc78() missing 1 required keyword-only argument: 'b3'
```

## 键值对字典`**kwargs`

```python
In [26]: def myfunc(**kwargs):
    ...:     if 'fruit' in kwargs:
    ...:         print(f'my fruit of choice is {kwargs['fruit']}')
    ...:     else:
    ...:         print('I did not find any fruit here')
    ...:

In [27]: myfunc(fruit='apple',veggie='lettuce')
my fruit of choice is apple

In [28]: myfunc(fruit1='apple',veggie='lettuce')
I did not find any fruit here
```

探索：  

```python
In [29]: def myfunc1(**kwargs):
    ...:     print(kwargs)
    ...:

In [31]: myfunc1(fruit1='apple',veggie='lettuce')
{'fruit1': 'apple', 'veggie': 'lettuce'} 

In [33]: 123 in {'a':123,'b':345}
Out[33]: False

In [34]: 123 in {'123':123,'b':345}
Out[34]: False

In [35]: 123 in {123:'1dre','b':345}
Out[35]: True

```

```python
#可以是任意参数名，只要参数名前面是**即可
In [43]: def myfunc1(**iuiewr):
    ...:     print(iuiewr)
    ...:

In [44]: myfunc1(fruit1='apple',veggie='lettuce')
{'fruit1': 'apple', 'veggie': 'lettuce'}

In [45]: myfunc1(1,fruit1='apple')
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[45], line 1
----> 1 myfunc1(1,fruit1='apple')

TypeError: myfunc1() takes 0 positional arguments but 1 was given

In [46]: myfunc1(fruit1='apple',2)
  Cell In[46], line 1
    myfunc1(fruit1='apple',2)
                            ^
SyntaxError: positional argument follows keyword argument


In [47]: myfunc1(fruit1='apple')
{'fruit1': 'apple'}
```

同`*args`，前面还允许有参数，后面不允许

```python
In [48]: def myfunc1(a,**iuiewr,c=0):
    ...:     print(iuiewr)
  Cell In[48], line 1
    def myfunc1(a,**iuiewr,c=0):
                           ^
SyntaxError: arguments cannot follow var-keyword argument


In [49]: def myfunc1(a,**iuiewr):
    ...:     print(iuiewr)
    ...:

In [50]: myfunc1(fruit1='apple')
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[50], line 1
----> 1 myfunc1(fruit1='apple')

TypeError: myfunc1() missing 1 required positional argument: 'a'

In [51]: myfunc1(123,fruit1='apple')
{'fruit1': 'apple'}

In [52]: myfunc1(123,b='34',fruit1='apple')
{'b': '34', 'fruit1': 'apple'}
```

## 结合使用

```bash
In [58]: def myfunc(*args,**kwargs):
    ...:     print(f'I would like {args[0]} {kwargs['food']}')
    ...:

In [59]: myfunc(10,20,30,fruit='orange',food='eggs',animal='dog')
I would like 10 eggs

```

***不能穿插使用！！***  

```

In [60]: myfunc(10,20,fruit='orange',food='eggs',animal='dog',3)
  Cell In[60], line 1
    myfunc(10,20,fruit='orange',food='eggs',animal='dog',3)
                                                          ^
SyntaxError: positional argument follows keyword argument


In [61]: myfunc(fruit='orange',food='eggs',animal='dog',3)
  Cell In[61], line 1
    myfunc(fruit='orange',food='eggs',animal='dog',3)
                                                    ^
SyntaxError: positional argument follows keyword argument


In [62]: myfunc(fruit='orange',food='eggs',animal='dog')
---------------------------------------------------------------------------
IndexError                                Traceback (most recent call last)
Cell In[62], line 1
----> 1 myfunc(fruit='orange',food='eggs',animal='dog')

Cell In[58], line 2, in myfunc(*args, **kwargs)
      1 def myfunc(*args,**kwargs):
----> 2     print(f'I would like {args[0]} {kwargs['food']}')

IndexError: tuple index out of range
```

