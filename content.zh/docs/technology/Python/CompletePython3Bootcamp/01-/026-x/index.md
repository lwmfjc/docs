---
title: 026-x
description: 026-x
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-08-29T14:12:39+08:00
lastmod: 2026-08-29T14:12:39+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# List 列表

## 索引和切片

列表支持索引和切片，还支持嵌套 ~~混合~~    

```shell
>>> [1,"2",3.5,['a','b']]
[1, '2', 3.5, ['a', 'b']]
>>> a=[1,"2",3.5,['a','b']]
>>> a[3]
['a', 'b']
>>> a[3][1]
'b'
```

## 混合，相加  

```shell
>>> my_list=[1,2,3]
>>> my_list=['STRING',100,23.2]
>>> len(my_list)
3
>>> my_list[1:]
[100, 23.2]
>>> my_list[:1]
['STRING']
>>> mylist=['one','two','three']
>>> another_list=['four','five']
>>> mylist+another_list
['one', 'two', 'three', 'four', 'five']
>>> mylist
['one', 'two', 'three']
>>> another_list
['four', 'five']
>>> new_list=mylist+another_list
>>> new_list
['one', 'two', 'three', 'four', 'five']
```

## 可修改

```shell
>>> new_list[0]='One All Caps'
>>> new_list
['One All Caps', 'two', 'three', 'four', 'five']
>>> new_list.append('six') #向后添加元素
>>> new_list
['One All Caps', 'two', 'three', 'four', 'five', 'six']
>>> new_list[-1]='heihei' #修改最后一个元素
>>> new_list
['One All Caps', 'two', 'three', 'four', 'five', 'heihei']
>>> len(new_list)
6
>>> new_list[6]='heihei'  #向后添加元素不能用下标方式
Traceback (most recent call last):
  File "<python-input-23>", line 1, in <module>
    new_list[6]='heihei'
    ~~~~~~~~^^^
IndexError: list assignment index out of range
>>> new_list.pop
<built-in method pop of list object at 0x7f7a558dfb80>
#移除元素
>>> new_list.pop() #弹出并返回最后一个元素
'heihei'
>>> new_list
['One All Caps', 'two', 'three', 'four', 'five']
>>> popped_item=new_list.pop()
>>> popped_item
'five'
>>> new_list
['One All Caps', 'two', 'three', 'four']
#弹出指定索引的元素
>>> new_list
['One All Caps', 'two', 'three', 'four']
>>> new_list.pop(0)
'One All Caps'
>>> new_list
['two', 'three', 'four']
#弹出列表最后一个元素
>>> new_list.pop(-1)
'four'
>>> new_list
['two', 'three']

```

## sort 和 reverse：（原地操作)

sort 不返回任何类型  

```shell
>>> new_list=['a','e','x','b','c']
>>> num_list=[4,1,8,3]
>>> new_list.sort()
>>> new_list
['a', 'b', 'c', 'e', 'x']
>>> num_list.sort()
>>> num_list
[1, 3, 4, 8]
>>> type(num_list.sort())
<class 'NoneType'>  #不返回任何内容的函数/方法的返回值
>>> new_list.sort();hello_list=new_list;
>>> hello_list
['a', 'b', 'c', 'e', 'x']
>>> num_list
[8, 4, 3, 1]
```

# Dictionary 字典

- 字典通过==键==名来检索对象；字典是无序的
- 列表是有序的

```shell
>>> my_dict={'key1':'value1','key2':'value2'}
>>> my_dict
{'key1': 'value1', 'key2': 'value2'}
>>> my_dict['key2']
'value2'
>>> prices_lookup={'apple':2.99,'oranges':1.99,'milk':5.80}
>>> prices_lookup['apple']
2.99
>>> prices_lookup={'oranges':3.0,'apple':2.99,'oranges':1.99,'milk':5.80} #Python 字典（dict）的键必须唯一。如果创建字典时出现重复键，后面的键值对会覆盖前面的键值对。
>>> prices_lookup['oranges']
1.99
>>> prices_lookup['oranges'] 
1.99

```

## 可以嵌套

```shell
>>> d={'k1':123,'k2':[0,1,2],'k3':{'insideKey':200}}
>>> d['k3']
{'insideKey': 200}
>>> d['k2']
[0, 1, 2]
>>> d['k3']['insideKey']
200
```

叠加调用，一步操作到位

``` shell
>>> d={'k1':123,'k2':['a','b','c'],'k3':{'insideKey':200}}
>>> mylist=d['k2']
>>> mylist
['a', 'b', 'c']
>>> mylist[2]
'c'
>>> d['k2'][2].upper()
'C'
>>> d['k2'][2]
'c'

```

## 添加，其他方法

```shell
>>> d={'k1':100,'k2':200}
>>> d['k3']=300
>>> d
{'k1': 100, 'k2': 200, 'k3': 300}
>>> d['k1']=1100
>>> d
{'k1': 1100, 'k2': 200, 'k3': 300}

>>> d.keys()
dict_keys(['k1', 'k2', 'k3'])
>>> type(d.keys())
<class 'dict_keys'> #字典键视图对象（dictionary keys view）
>>> type(d)
<class 'dict'> 
#怎么理解视图对象
>>> d
{'k1': 1100, 'k2': 200, 'k3': 300}
>>> mykeys=d.keys()
>>> mykeys
dict_keys(['k1', 'k2', 'k3'])
#表示 Python 返回了一个字典键的动态视图对象，不是存储数据的普通列表。
>>> type(mykeys)
<class 'dict_keys'>

>>> print(mykeys)
dict_keys(['k1', 'k2', 'k3'])
>>> d['c']=1234
>>> d
{'k1': 1100, 'k2': 200, 'k3': 300, 'c': 1234}
>>> mykeys #它像一个窗口，直接看字典里的数据。所以叫视图对象，即使这里没有再更新mykeys
dict_keys(['k1', 'k2', 'k3', 'c'])

#以下也都是视图
>>> d.values()
dict_values([1100, 200, 300, 1234])
>>> d.items()
dict_items([('k1', 1100), ('k2', 200), ('k3', 300), ('c', 1234)])
>>> d.keys()
dict_keys(['k1', 'k2', 'k3', 'c'])

```

# Tuples 元组

元组是不可变的  

## 元组和列表极其相似

```shell
>>> t=(1,2,3)
>>> mylist=[1,2,3]
>>> t
(1, 2, 3)
>>> type(t)
<class 'tuple'>
>>> type(mylist)
<class 'list'>
>>> len(t)
3
>>> t=('one',2)
>>> t[0]
'one'
```