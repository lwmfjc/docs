---
title: 042
description: 042
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-01T11:16:37+08:00
lastmod: 2026-09-01T11:16:37+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 内置函数和运算符关键字

## 内置函数

### range

- 生成器是一种特殊类型的函数
- 他会一个个的生成信息 ~~数据~~ ，而不是一次性将所有东西生成到内存中

```shell
#range函数，返回一个range对象（可迭代对象）【是一个生成器】
>>> type(range(10))
<class 'range'>
#只可以迭代0,1,2
>>> for num in range(3):
...     print(num)
...     
0
1
2
#只可以迭代[3,6) 包括左边界，不包括右边界
>>> for num in range(3,6):
...     print(num)
...     
3
4
5
#步长2表示每次增加2
>>> for num in range(3,10,2):
...     print(num)
...     
3
5
7
9

#将生成器装换为列表
>>> list(range(3,6))
[3, 4, 5]


```

### enumerate

```shell
>>> word='abcde'
>>> for letter in word:
...     print(word[index_count])
...     index_count+=1
...     
a
b
c
d
e
#使用内置行数，获取可遍历对象的 下标和内容（以元组形式表示）
>>> word='abcde'
>>> for item in enumerate(word):
...     print(item)
...     
(0, 'a')
(1, 'b')
(2, 'c')
(3, 'd')
(4, 'e')

#使用enumerate并在迭代时将(下标，内容)这样的元组解包
>>> word='abcde'
>>> for index,letter in enumerate(word):
...     print(f'index={index},letter={letter}')
...     
index=0,letter=a
index=1,letter=b
index=2,letter=c
index=3,letter=d
index=4,letter=e
>>> type(enumerate(word))
<class 'enumerate'>

```

### zip

这也是一个生成器  

```shell
>>> mylist1=[1,2,3]
>>> mylist2=['a','b','c']
>>> for item in zip(mylist1,mylist2):
...     print(item)
...     
(1, 'a')
(2, 'b')
(3, 'c')
>>> zip(mylist1,mylist2)
<zip object at 0x7ff1e4def480>
>>> type(zip(mylist1,mylist2))
<class 'zip'>
#三个组合
>>> mylist1=[1,2,3]
>>> mylist2=['a','b','c']
>>> mylist3=[3.4,'haha',2.0]
>>> for item in zip(mylist1,mylist2,mylist3):
...     print(item)
...     
(1, 'a', 3.4)
(2, 'b', 'haha')
(3, 'c', 2.0)
#zip只能压缩到最短的那个列表
>>> mylist1=[1,2,3]
>>> mylist2=['a','b']
>>> mylist3=[3.4,'haha',2.0,5]
>>> for item in zip(mylist1,mylist2,mylist3):
...     print(item)
...     
(1, 'a', 3.4)
(2, 'b', 'haha')
#list函数把zip的结果放进转化成列表
>>> list(zip(mylist1,mylist2,mylist3))
[(1, 'a', 3.4), (2, 'b', 'haha')]

#解包
>>> for a,b,c in zip(mylist1,mylist2,mylist3):
...     print(f'a={a}')
...     
a=1
a=2
#解包的时候，元组的元素个数一定要一致，否则会报错
>>> for a,c in zip(mylist1,mylist2,mylist3):
...     print(f'c={c}')
...     
Traceback (most recent call last):
  File "<python-input-56>", line 1, in <module>
    for a,c in zip(mylist1,mylist2,mylist3):
        ^^^
ValueError: too many values to unpack (expected 2)
```

## 运算符关键字

```shell
#列表
>>> 'x' in [1,2,3]
False
>>> 'x' in ['x','y','z']
True
>>> 2 in [2.0,1]
True
#字符串
>>> 'a' in 'a world'
True
#字典
>>> 'mykey' in {'mykey':123}
True
>>> 123 in {'mykey':123}
False

```

### 字典视图对象：  

| 方法           | 返回类型          | 中文常叫法   |
| ------------ | ------------- | ------- |
| `d.keys()`   | `dict_keys`   | 字典键视图   |
| `d.values()` | `dict_values` | 字典值视图   |
| `d.items()`  | `dict_items`  | 字典键值对视图 |

```shell
>>> d={'mykey':345,'LiKan':12}
>>> d.keys()
dict_keys(['mykey', 'LiKan'])
>>> mykeys=d.keys()
>>> mykeys
dict_keys(['mykey', 'LiKan'])
>>> d['new']=54
>>> mykeys
dict_keys(['mykey', 'LiKan', 'new'])

#in的使用
>>> d={'mykey':345,'LiKan':12}
>>> 345 in d.keys()
False
>>> 345 in d.values()


```

因为 d.keys() 返回的是字典视图（dict_keys），它不是复制一份数据，而是指向原字典的一个动态窗口  

```shell
#如果你想要固定不变的副本：
>>> o_mykeys=mykeys
>>> d['new_2']=54
#一样都是视图
>>> o_mykeys
dict_keys(['mykey', 'LiKan', 'new', 'new_2'])
#转换为列表后就不是视图了，不是动态窗口也不动态跟踪了
>>> o_mykeys=list(mykeys)
>>> o_mykeys
['mykey', 'LiKan', 'new', 'new_2']
>>> d['new_3']=99
>>> o_mykeys
['mykey', 'LiKan', 'new', 'new_2']
>>> mykeys
dict_keys(['mykey', 'LiKan', 'new', 'new_2', 'new_3'])

```

## 数学函数
### min,max,shuffle

```shell
>>> mylist=[10,20,303,50]
>>> min(mylist)
10
>>> max(mylist)
303
# 从random模块导入shuffle函数
>>> from random import shuffle
>>> mylist = [1,2,3,4,5,6,7]
#原地操作，不返回任何东西
>>> shuffle(mylist)
>>> mylist
[3, 2, 5, 7, 4, 1, 6]
>>> shuffle(mylist)
>>> mylist
[7, 2, 6, 1, 5, 3, 4]
#导入整个random模块
import random
random.shuffle(mylist)
#什么都不返回
>>> random_list
Traceback (most recent call last):
  File "<python-input-99>", line 1, in <module>
    random_list
NameError: name 'random_list' is not defined
>>> random_list=shuffle(mylist)
>>> type(random_list)
<class 'NoneType'>
>>> type(shuffle(mylist))
<class 'NoneType'>

```

- module（模块） → random
- package（包） → 一组模块的集合
- library（库） → 更大的概念，可能包含多个包/模块

```shell
#补充，None是NoneType唯一的实例,使用的是单例模式
>>> None
>>> a=None
>>> b=None
>>> a==b
True
>>> mylist
[4, 6, 3, 1, 7, 5, 2]
```

### randint

```shell
#上下限之间取一个随机值（包括1，也包括100）
>>> random.randint(1,100)
41

```

## 接收用户输入

```shell
#接收输入到result中input返回值永远为str
>>> input('enter a number here:')
enter a number here:123
'123'
>>> result=input('enter a number here:')
enter a number here:34
>>> type(result)
<class 'str'>
#类型转换
>>> int(result)
34
>>> result
'34'
>>> float(result)
34.0


```


```shell
#不确定输入是否为用户类型，则用try except
>>> try:
...     result=float(result)
... except ValueError:
...     pass
... print(result)
... 
34.0
>>> result='3se'
>>> try:
...     result=float(result)
... except ValueError:
...     pass
... print(result)
... 
3se

```