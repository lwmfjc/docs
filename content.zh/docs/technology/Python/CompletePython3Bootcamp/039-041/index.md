---
title: 039-041
description: 039-041
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-08-31T10:05:54+08:00
lastmod: 2026-08-31T10:05:54+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# if,elif,else

- 控制流：只在需要时才执行代码
- 靠缩进控制层级

```shell
if some_condition:
	# method1
	# method2
elif some_other_condition:
	#method3
	#method4
else:
	#method5
	#method6
#method7
```

- 所有处于if下的==*缩进*==层级 ~~method1,method2~~ 的代码，只有在条件 ~~some_condition~~ 为真时才会执行  
- method7永远都会执行，而其他的则依据条件而论

```shell
>>> a=3;b=4;
>>> a
3
>>> b
4
>>> if a<b:
...     print('a<b')
... elif a==5:
...     print('a=5')
... else:
...     print('other')
... print('hello world')
... 
a<b
hello world
>>> a=5;b=2;
>>> if a<b:
...     print('a<b')
... elif a==5:
...     print('a=5')
... else:
...     print('other')
... print('hello world')
... 
a=5
hello world
```

## 补充，一些快捷键：  

| 功能     | 快捷键              |
| ------ | ---------------- |
| 接受行内建议 | `Ctrl + →`       |
| 传统补全列表 | `Tab`            |
| 退缩进    | `Ctrl + U`（你的环境） |

![](img/ly-20260831165159995.png)  

这种情况按ctrl+ -> 就会补全行内建议  

## 例子

```shell
>>> if True:
...     print('its true!')
...     
its true!
>>> hungry = True 
>>> if hungry:
...     print('feed me!')
...     
feed me!
>>> hungry=False
>>> if hungry:
...     print('feed me!')
...  
#if-elif
>>> hungry = False
>>> if hungry:
...     print('feed me!')
... else:
...     print('im not hungry')
...     
im not hungry

```

## if-elif-else

```shell
>>> loc='bank'
>>> if loc=='auto shop':
...     print('cars are cool!')
... elif loc == 'bank':
...     print("money is cool!")
... elif loc=='store':
...     print("welcome to the store!")
... else:
...     print('i do not know much.')
...     
money is cool!

#另一个例子
>>> loc='game'
>>> if loc=='auto shop':
...     print('cars are cool!')
... elif loc == 'bank':
...     print("money is cool!")
... elif loc=='store':
...     print("welcome to the store!")
... else:
...     print('i do not know much.')
...     
i do not know much.

```

# for

- 对于可迭代 ~~iterable~~ 的东西
	- 遍历列表中的元素
	- 遍历字符串中的每个字符

> 
> print的定义：`print(*objects, sep=' ', end='\n' , file=None, flush=False)`   ~~表示print可以接收多个对象，打印时对象之间以sep(默认为空格)字符串隔开，end表示结尾(默认是换行符)~~
> 

```python
#注意##之后就没有任何字符了，没有空格也没有换行符
>>> print('a','b','c',sep='xx',end='##')
axxbxxc##
```

## 基本语法

```
```shell
>>> my_iterable=[1,2,3]
>>> for item_name in my_iterable:
...     print(item_name)
...     
1
2
3

```

## 其他例子

```shell
>>> mylist=[1,2,3,4,5,6,7,8,9,10]
>>> list=[]

>>> list
[]
#del 是 Python 的删除语句（delete statement），用于删除变量、对象里的元素等。
>>> del list
#这个是list真正的内置含义，是一个类，可以用来创建list
>>> list
<class 'list'>
>>> list('helo')
['h', 'e', 'l', 'o']


```

```shell
>>> mylist=[1,2,3,4,5,6,7,8,9,10]
>>> for num in mylist:
...     print(num,end=',')
...     
1,2,3,4,5,6,7,8,9,10,>>> for jelly  in mylist:
                     ...     print(jelly,end=',')
                     ...     
1,2,3,4,5,6,7,8,9,10,>>> None
>>> for num in mylist:
...     print('hello')
...     
hello
hello
hello
hello
hello
hello
hello
hello
hello
hello

```

### 和if结合

```shell
>>> for num in mylist:
...     # check for even
...     if num%2 == 0:
...         print(num)
...     else:
...         print(f'oll Number: {num}')
...         
oll Number: 1
2
oll Number: 3
4
oll Number: 5
6
oll Number: 7
8
oll Number: 9
10

```

### 常用场景

#### 求和

```shell
>>> mylist=[1,2,3,4,5,6,7,8,9,10]
>>> list_num=0
>>> for num in mylist:
...     list_num = list_num + num
... print(list_num)
... 
55
#Python中，缩进是相当重要的东西
#下面的print语句，和list_sum=list_num+num在同一个代码块运行
>>> list_num=0
>>> for num in mylist:
...     list_num = list_num + num
...     
...     print(list_num)
...     
1
3
6
10
15
21
28
36
45
55

#注意下面的缩进问题，p要么和上面的list_num的'l'对齐，要么和for num的'f'对齐。否则都会报错
>>> for num in mylist:
...     list_num = list_num + num
...     
...    print(list_num)
...    
  File "<python-input-45>", line 4
    print(list_num)
                   ^
IndentationError: unindent does not match any outer indentation level #取消缩进后，没有匹配到任何已有的外层缩进层级。
>>> for num in mylist:
...     list_num = list_num + num
...     
...      print(list_num)
...      
  File "<python-input-50>", line 4
    print(list_num)
IndentationError: unexpected indent #Python 本来不期待这里有缩进，但是你加了。
```

#### 字符串

```shell
>>> mystring='hello world'
>>> for letter in mystring:
...     print(letter,end=',')
... print()
... 
h,e,l,l,o, ,w,o,r,l,d,
>>> for letter in "Hello":
...     print(letter,end=',')
... print()
... 
H,e,l,l,o,
>>> for le23tter in "Hello":
...     print(le23tter,end=',')
... print()
... 
H,e,l,l,o,
#_ 就是一个普通变量名。不过当你不关心变量时才会用

#不常用
>>> for _ in "Hello":
...     print(_,end=',')
... print()
... 
H,e,l,l,o,

#常用
>>> for _ in "Hello":
...     print('abc',end=',')
... print()
... 
abc,abc,abc,abc,abc,

#不论要遍历的对象是啥，没有特殊处理的情况下，永远只遍历外层的对象(这个是元组)的元素个数次数
>>> for item in (1,2,['t','e'],'a',(5,6)):
...     print(item)
...     
1
2
['t', 'e']
a
(5, 6)
```

#### 元组解包

tuple unpacking

```shell

mylist=[(1,2),(3,4),(5,6),(7,8)]
>>> for item in mylist:
...     print(item)
...     
(1, 2)
(3, 4)
(5, 6)
(7, 8)
#用变量单独访问元组单个的项
>>> for (a,b) in mylist:
...     print(f'{a}xx{b}')
...     
1xx2
3xx4
5xx6
7xx8
#省略左括号和右括号
>>> for a,b in mylist:
...     print(f'{a}xx{b}')
...     
1xx2
3xx4
5xx6
7xx8


>>> mylist=[(1,2,3),(5,6,7),(8,9,10)]
>>> for a,b,c in mylist:
...     print(f'a={a},b={b},c={c}')
...     
a=1,b=2,c=3
a=5,b=6,c=7
a=8,b=9,c=10
```

#### 字典-迭代解包

 ~~默认字典是无序的，下面只是看起来好像有序~~   

```shell
#默认情况下只遍历键
>>> for a in {'name':'kankan','age':12}:
...     print(a)
...     
name
age
#只遍历值
>>> for a in {'name':'kankan','age':12}.values():
...     print(a)
...     
kankan
12
#遍历项
>>> for item in {'name':'kankan','age':12}.items():
...     print(item)
...     
('name', 'kankan')
('age', 12)
#解包
>>> for a,b in {'name':'kankan','age':12}.items():
...     print(f'{a}xx{b}')
...     
namexxkankan
agexx12
```

# while

while:  

```shell
>>> i=0
>>> while i<10:
...     print(i,end=',')
...     i+=1
...     
0,1,2,3,4,5,6,7,8,9,>>> i
10
```

while-else:  

```shell
>>> i=0;
>>> while i<4:
...     print(i)
...     i+=1
... else:
...     print(f'end--i={i}')
...     
0
1
2
3
end--i=4
#while和else不是顺序关系，更像是while里面嵌套了 if-else ，然后else隐藏了break，类似
i=0
while(True):
	if(i<4):
		print(i)
		i+=1
	else:
		print(f'end--i={i}')
		break
	
#下面这个会直接打印end--i=50并退出
>>> i=50
>>> while(True):
...     if(i<4):
...             print(i)
...             i+=1
...     else:
...             print(f'end--i={i}')
...             break
... 
end--i=50
#while-else一样的结果
>>> i=50
>>> while i<4:
...     print(i)
...     i+=1
... else:
...     print(f'end--i={i}')
...  
... 
end--i=50
```

附（模拟do-while）：  

```shell
>>> while True:
...     value = input("请输入：")
... 
...     if value == "quit":
...         break
...         
请输入：2
请输入：3
请输入：quit
```


## break，continue，pass

- pass相当于什么都不做
- 占位语法，空操作（no-op，no operation）

```shell

>>> x = [1,2,3]
>>> for item in x:
...     # comment
...     print('ha')
...     pass
...     print('b')
... print('end of my script')
... 
ha
b
ha
b
ha
b
end of my script

```

continue: 跳过当前循环的余下部分，继续下一次迭代  

```shell
>>> for item in x:
...     # comment
...     print('ha')
...     continue
...     print('b')
... print('end of my script')
... 
ha
ha
ha
end of my script

```

break: 跳出该层循环体 ~~外层的迭代继续~~   

```shell
>>> for item in x:
...     for _ in [1,2]:
...          # comment
...          print('ha')
...          break
...          print('b')
... print('end of my script')
... 
ha
ha
ha
end of my script

```

whiel中使用break：  

```shell
>>> while x<5:
...     if x == 2:
...         break #遍历到2就跳出whle循环
...     print(x)
...     x+=1
...     
0
1

```