---
title: "087-090"
description: "087-090"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-22T12:41:51+08:00
lastmod: 2026-09-22T12:41:51+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 错误和异常处理

目前，程序中如果出现任何错误，整个脚本都会停止  

> 三个关键字：**try**，**except** ~~捕捉错误，当try中出现错误就会执行~~ ，**finally** ~~无论是否异常都会执行的代码块~~ 

> int和str相加是会报错的

```python
In [14]: def add(n1,n2):
    ...:     print("start add")
    ...:     print(n1+n2)
    ...:     print("end add")
    ...:

In [15]: number1=10

In [16]: number2=input("Please provide a number:")
Please provide a number:11

In [17]: add(number1,number2)
start add
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[17], line 1
----> 1 add(number1,number2)

Cell In[14], line 3, in add(n1, n2)
      1 def add(n1,n2):
      2     print("start add")
----> 3     print(n1+n2)
      4     print("end add")

TypeError: unsupported operand type(s) for +: 'int' and 'str'
```

> 如上，打印了"stat"没有打印"end"，因为抛出异常之后程序就结束了，没有执行后面的语句

```python
In [22]: try:
    ...:     #想尝试执行这段代码，
    ...:     #然而他可能有错误
    ...:     result = 10 + 10
    ...: except:
    ...:     print("Hey it looks like you aren't adding correctly!")
    ...: print('end....')
end....

In [23]: try:
    ...:     #想尝试执行这段代码，
    ...:     #然而他可能有错误
    ...:     result = 10 + '10'
    ...: except:
    ...:     print("Hey it looks like you aren't adding correctly!")
    ...: print('end....')
Hey it looks like you aren't adding correctly!
end.... #由于捕捉了异常，所以继续执行了
```


> else：没有异常时就执行另一个代码块

```python
In [24]: try:
    ...:     #想尝试执行这段代码，
    ...:     #然而他可能有错误
    ...:     result = 10 + '10'
    ...: except:
    ...:     print("Hey it looks like you aren't adding correctly!")
    ...: else:
    ...:     print("Add went well!")
    ...:     print(result)
    ...: print('end....')
Hey it looks like you aren't adding correctly!
end....

In [25]: try:
    ...:     #想尝试执行这段代码，
    ...:     #然而他可能有错误
    ...:     result = 10 + 10
    ...: except:
    ...:     print("Hey it looks like you aren't adding correctly!")
    ...: else:
    ...:     print("Add went well!")
    ...:     print(result)
    ...: print('end....')
Add went well! #没有错误才会执行这个
20
end....
```

> finally：无论是否抛出异常，都会执行的代码块

> 没有错误，finally运行了：

```python
In [28]: try:
    ...:     #打开文件并写入，如果文件不存在则创建他
    ...:     f=open('testfile','w')
    ...:     f.write("Write a test line")
    ...: #错误，是一个类型错误
    ...: except TypeError:
    ...:     print("There was a type error!")
    ...: #如果打开没有权限写入的文件，是个操作系统错误
    ...: except OSError:
    ...:     print('Hey you have an OS Error')
    ...: finally:
    ...:     f.close()
    ...:     print("I always run")
    ...:
I always run
```

> 抛出异常了，finally运行了

```python
In [29]: try:
    ...:     #打开文件并写入，如果文件不存在则创建他
    ...:     f=open('testfile','r')
    ...:     f.write("Write a test line")
    ...: #错误，是一个类型错误
    ...: except TypeError:
    ...:     print("There was a type error!")
    ...: #如果打开没有权限写入的文件，是个操作系统错误
    ...: except OSError:
    ...:     print('Hey you have an OS Error')
    ...: finally:
    ...:     f.close()
    ...:     print("I always run")
    ...:
Hey you have an OS Error
I always run
```

```python
In [39]: try:
    ...:     #打开文件并写入，如果文件不存在则创建他
    ...:     a=[1,2,3]
    ...:     #抛出异常后，不会再继续try块里的其他语句
    ...:     print(a[3])
    ...:     f=open('testfile','r')
    ...:     f.write("Write a test line")
    ...: #错误，是一个类型错误
    ...: except TypeError:
    ...:     print("There was a type error!")
    ...: #如果打开没有权限写入的文件，是个操作系统错误
    ...: except OSError:
    ...:     print('Hey you have an OS Error')
    ...: #没有指定的特别异常类型就走这里
    ...: except: 
    ...:     print("All other exceptions!")
    ...: finally:
    ...:     f.close()
    ...:     print("I always run")
    ...:
All other exceptions!
I always run
```

> 获取用户输入为数字

```python
In [41]: def ask_for_int():
    ...:     try:
    ...:         result=int(input("Please provide number:"))
    ...:     except:
    ...:         print("Whoops!That is not a number")
    ...:     finally:
    ...:         print("End of try/except/finally")
    ...:

In [42]: ask_for_int()
Please provide number:1
End of try/except/finally

In [43]: ask_for_int()
Please provide number:b
Whoops!That is not a number
End of try/except/finally
```

> 添加循环
>  ~~即使break，continue，return 都不能绕过finnaly~~ 

```python
In [45]: def ask_for_int():
    ...:     while True:
    ...:         try:
    ...:             result=int(input("Please provide number:"))
    ...:         except:
    ...:             print("Whoops!That is not a number")
    ...:             #continue = 准备跳过循环余下部分，但必须先完成当前代码块的清理工作
    ...:             continue
    ...:         else:
    ...:             print("Yes thank you")
    ...:             #break = 准备离开循环，但必须先完成当前代码块的清理工作
    ...:             break
    ...:         finally:
    ...:             print("End of try/except/finally")
    ...:             print("I will always run at the end!")
    ...:

In [46]: ask_for_int()
Please provide number:e
Whoops!That is not a number
End of try/except/finally
I will always run at the end!  #注意，continue没有跳过finally，而是先执行finally，然后才是continue
Please provide number:1
Yes thank you
End of try/except/finally
I will always run at the end!#注意，break没有跳过finally，而是先执行finally，然后才是break跳出循环
```

常用的是`try-except-else`，偶尔会用到`try-except-else-finally`  

# 练习题

> 捕获异常

```python
In [3]: for i in ['a','b','c']:
   ...:     try:
   ...:         print(i**2)
   ...:     #或者#except TypeError:
   ...:     except:
   ...:         print(f' "{i}" 不是数字')
   ...:
 "a" 不是数字
 "b" 不是数字
 "c" 不是数字
```

> 捕获异常

```python
n [7]: try:
   ...:     z=x/y
   #...: 或者#except ZeroDivisionError:
   ...: except:
   ...:     print("除法出错了!")
   ...: finally:
   ...:     print('all done!')
   ...:
除法出错了!
all done!
```

> 输入一个整数（要求捕获异常），计算他的平方

```python

In [8]: def ask():
   ...:     while True:
   ...:         try:
   ...:             number=int(input("输入一个整数，我会计算他的平方"))
   ...:         except:
   ...:             print("请输入一个整数")
   ...:             continue
   ...:         else:
   ...:             break
   ...:     print(f'{number} 的平方是{number**2}')
   ...:
   ...:

In [9]: ask()
输入一个整数，我会计算他的平方s
请输入一个整数
输入一个整数，我会计算他的平方d
请输入一个整数
输入一个整数，我会计算他的平方0-
请输入一个整数
输入一个整数
```

> 或者使用变量

```python
In [12]: def ask():
    ...:     waiting=True
    ...:     while waiting:
    ...:         try:
    ...:             number=int(input("输入一个整数，我会计算他的平方"))
    ...:         except:
    ...:             print("请输入一个整数")
    ...:         else:
    ...:             waiting=False
    ...:     print(f'{number} 的平方是{number**2}')
    ...:

In [13]: ask()
输入一个整数，我会计算他的平方s
请输入一个整数
输入一个整数，我会计算他的平方c
请输入一个整数
输入一个整数，我会计算他的平方2
2 的平方是4
```


