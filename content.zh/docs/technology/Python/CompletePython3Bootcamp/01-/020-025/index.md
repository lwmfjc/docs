---
title: 020-025
description: 020-025
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-08-29T11:22:25+08:00
lastmod: 2026-08-29T11:22:25+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

# 字符串简介

```shell
#接下来使用ipython

In [2]: print('hello')
hello

In [3]: print("Hello")
Hello

In [4]: print("I don't know")
I don't know

In [5]: print(' hah "hai"')
 hah "hai"

```

- 字符串是有序序列，可以使用 indexing 或 slicing 来获取字符串子集  
- 索引和java、c/cpp一样从0开始
- 可以使用反向索引
  ![](img/ly-20260829104529449.png)  
- 切片 [start:stop:step]
	- start （包括）
	- stop （不包括）
	- step （跳跃幅度）


```shell
#返回字符串（不是打印字符串），所以这里还显示了''表示这是一个字符串
In [1]: 'hello'
Out[1]: 'hello'

In [2]: "world"
Out[2]: 'world'

In [3]: 'this is a "Test'
Out[3]: 'this is a "Test'

In [4]: 'this is a "Test"'
Out[4]: 'this is a "Test"'
```

## 例子1

![](img/ly-20260829105617812.png)  

- 创建/取得一个对象 → 用完 → 丢弃  
- 这个例子其实没有什么实际意义，在.py文件中然后被 `python xx.py`时，这个代码出现在文件中，是会被合并成"hello1hello2"的，而且没人引用它，最终也会被丢弃

## 例子2

![](img/ly-20260829105814642.png)

有明显含义，打印了两行

```shell
#转义字符
In [8]: print('hello\nworld')
hello
world

In [9]: print('helloworld')
helloworld

```


## 例子3

```shell
In [10]: len('hah')
Out[10]: 3

In [11]: len('你好')
Out[11]: 2

In [12]: len('hi h')
Out[12]: 4

```

# 字符串的索引与切片

## 索引

```shell
>>> len('I am');
4
>>> mystring = "hello world"
>>> mystring
'hello world'
>>> mystring[0]
'h'
>>> mystring[-2]
'l'
>>> len(mystring)
11
>>> mystring[11]
Traceback (most recent call last):
  File "<python-input-6>", line 1, in <module>
    mystring[11]
    ~~~~~~~~^^^^
IndexError: string index out of range
>>> mystring[10]
'd'

```

## 切片

```shell
>>> mystring="0123456789"
>>> len(mystring)
10
>>> mystring[2:6] #[2,6) 不包括6
'2345'
>>> mystring[2:6:2] #[2,6) 不包括6，从范围第1个开始取，每2个取一次字符
'24'
>>> mystring[2:-1]
'2345678'
>>> mystring[2:-1:3]
'258'
>>> mystring
'0123456789'
>>> mystring[2:] #从[2]到结束
'23456789'
>>> mystring[:3] #从最前面到3（不包括3）
'012'
>>> mystring[::2]
'02468'
>>> mystring[::]
'0123456789'
>>> mystring[::-1]#从开头到末尾，以向后1步的方式遍历
'9876543210'
>>> step=2
>>> mystring[::step]
'02468'

```

# 字符串的属性与方法

## 字符串具有不可变性  

```shell
ly@dba13:~$ python3
>>> name="Sam"
#修改字符串失败
>>> name[0]='p'
Traceback (most recent call last):
  File "<python-input-1>", line 1, in <module>
    name[0]='p'
    ~~~~^^^
TypeError: 'str' object does not support item assignment

#修改字符串
>>> # name[0]='p'
>>> name[1:]
'am'
#字符串连接
>>> 'p'+name[1:]
'pam'
>>> name='p'+name[1:]
>>> name
'pam'

```

## 字符串加法和乘法

```shell
>>> x='hello world'
>>> x+"it is beautiful outs"
'hello worldit is beautiful outs'
>>> x
'hello world'
>>> x=x+" it is beautiful outs"
>>> letter='z'
>>> letter*10
'zzzzzzzzzz'
>>> 2+3
5
>>> '2'+3
Traceback (most recent call last):
  File "<python-input-14>", line 1, in <module>
    '2'+3
    ~~~^~
TypeError: can only concatenate str (not "int") to str
>>> '2'+'3'
'23'

```

## 一些方法

```shell
>>> x='hello world'
>>> x.title
<built-in method title of str object at 0x7fd7e37aaf30>
>>> x.upper() #并非原地操作
'HELLO WORLD'
>>> x
'hello world'
>>> x=x.upper() #非原地操作，需要赋值回去
>>> x
'HELLO WORLD'
>>> x.upper
<built-in method upper of str object at 0x7fd7e37aaab0>
>>> x.lower()
'hello world'
>>> x.split()
['HELLO', 'WORLD']
>>> x
'HELLO WORLD'
>>> x='Hi this is a string'
>>> x.split()
['Hi', 'this', 'is', 'a', 'string']
>>> x.split('i')
['H', ' th', 's ', 's a str', 'ng']
>>> abc=x.split('i') #使用split快速创建了列表
>>> type(abc)
<class 'list'>

```

# 字符串的打印格式化

传统方法  

```shell
>>> my_name="Jose"
>>> print("hello "+my_name)
hello Jose
```


字符串插值  
- .format() ~~python2.6引入~~ 
- f-strings  ~~Python3较新版的写法~~ 
## .format()

```shell
>>> print('This is a string {}'.format('INSERT'))
This is a string INSERT
>>> lystr='abc {}d'
>>> lystr
'abc {}d'
>>> lystr.format('123')
'abc 123d'
>>> print('The {} {} {}'.format('fox','brown','quick'))
The fox brown quick
>>> print('The {} {} {}'.format('fox','brown','quick','haha'))
The fox brown quick
>>> print('The {2} {1} {1}'.format('fox','brown','quick','haha'))
The quick brown brown
>>> print('The {2} {1} {3}'.format('fox','brown','quick','haha'))
The quick brown haha

```

### 位置参数与关键字参数  

```shell
#位置参数要放在关键字参数前面
>>> print('The {q} {b} {2}'.format(f='fox',b='brown',q='quick','hi'))
  File "<python-input-9>", line 1
    print('The {q} {b} {2}'.format(f='fox',b='brown',q='quick','hi'))
                                                                   ^
SyntaxError: positional argument follows keyword argument
#位置参数这里只有两个，2就越界了
>>> print('The {q} {b} {1} {2}'.format('hi','hello',f='fox',b='brown',q='quick'))
Traceback (most recent call last):
  File "<python-input-10>", line 1, in <module>
    print('The {q} {b} {1} {2}'.format('hi','hello',f='fox',b='brown',q='quick'))
          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
IndexError: Replacement index 2 out of range for positional args tuple
#位置参数和关键字参数是分开使用的，位置参数这里只有2个
>>> print('The {q} {b} {1} {0}'.format('hi','hello',f='fox',b='brown',q='quick'))
The quick brown hello hi


```

### 浮点数格式化  

```shell
>>> result=100/777
>>> result
0.1287001287001287
>>> print("Th result was {r}".format(r=result))
Th result was 0.1287001287001287
>>> print("Th result was {r:1.3f}".format(r=result)) #保留小数点3位，并四舍五入
Th result was 0.129
>>> print("Th result was {r:6.3f}".format(r=result)) #只有5位，但是要求宽度6，所以前面多了个空格
Th result was  0.129
>>> print("Th result was {r:6.6f}".format(r=result))
Th result was 0.128700
```

## f-strings

```shell
>>> name="Jose"
>>> print('Helo,his name is {}'.format('kankan'))
Helo,his name is kankan
>>> print(f'Helo,his name is {name}')
Helo,his name is Jose
>>> print('Helo,his name is {}'.format(name))
Helo,his name is Jose

>>> name="Sam";age=3
>>> print(f'{name} is {age} years old.')
Sam is 3 years old.


```