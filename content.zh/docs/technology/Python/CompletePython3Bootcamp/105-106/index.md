---
title: "105-106"
description: "105-106"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-23T18:10:45+08:00
lastmod: 2026-09-23T18:10:45+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 装饰器

```python
def simple_func():
    #Do simple stuff
    something = ''
    return something
```

如果已经有一个函数，想修改它，传统的方式是重写，但基本都会对原函数产生副作用 ~~即无法再恢复原来的效果了~~ 。或者写一个新函数，然后把原函数的内容全复制过来 ~~过于麻烦~~   

> 装饰器：快速为已存在的函数附加额外功能

```python
#如果删除这行，则装饰器就没法用了
@some_decorator
def simple_func():
    #Do simple stuff
    something = ''
    return something
```

## 知识补充

> 函数对象和普通对象一样，可以被多个变量引用。b=a只是复制了引用，因此 a 和 b 指向同一个 greet 函数对象，所以 id(a) 和 id(b) 相同。

```python

In [70]: def hello():
    ...:     def greet():
    ...:         return "hello"
    ...:     return greet
    ...:

In [71]: a=hello()

In [72]: b=a

In [73]: print(a)
<function hello.<locals>.greet at 0x7213259c6ac0>

In [74]: print(b)
<function hello.<locals>.greet at 0x7213259c6ac0>

#id() 是 Python 内置函数，用来返回一个对象的唯一标识。
In [75]: id(a)
Out[75]: 125426560953024

In [77]: id(b)
Out[77]: 125426560953024

```

这里不是 **a 和 b 各自返回了 greet**，而是：

```python
a = hello()
b = a
```

过程是：

第一次：

```python
a = hello()
```

调用 `hello()`：

1. 创建一个 `greet` 函数对象：

```
[greet函数对象]
        ↑
        |
   hello内部名字 greet
```

2. `return greet`

把这个函数对象的引用交给外部：

```
a
|
v
[greet函数对象]
```

---

然后：

```python
b = a
```

不是再次调用 `hello()`，也不是创建新的 `greet`。

只是复制引用：

```
a ----\
       \
        ---> [greet函数对象]
       /
b ----/
```

所以：

```python
print(a)
print(b)
```

都是：

```
<function hello.<locals>.greet at 0x7213259c6ac0>
```

地址一样。

---

如果这样：

```python
a = hello()
b = hello()
```

才是两个不同的 `greet`：

```
a ---> [greet对象①] 0x1111

b ---> [greet对象②] 0x2222
```

因为执行了两次：

```python
def greet():
    ...
```

这个函数定义语句。

---

你可以再验证一个细节：

```python
a.__code__ is b.__code__
```

这里会：

```python
True
```

因为：

虽然：

```python
a
b
```

是同一个函数对象，

但是函数对象内部还有一个：

```
函数对象
 ├── code对象（代码）
 ├── globals
 ├── name
 ├── closure
 └── ...
```

大概结构：

```
a
 |
 v
+----------------+
| function对象   |
|                |
| code ----------+----> greet代码
| globals        |
| closure        |
+----------------+
```

---

所以总结你的话：

> 函数也是对象。同一个函数对象引用，里面定义的函数，地址就是一样的。

更精确地说：

> 函数对象和普通对象一样，可以被多个变量引用。`b=a`只是复制了引用，因此 `a` 和 `b` 指向同一个 `greet` 函数对象，所以 `id(a)` 和 `id(b)` 相同。

你现在这个理解已经接近 Python 装饰器需要的对象模型了。装饰器后面大量依赖这个机制：**函数可以被保存、传递、包装、替换。**

### \_\_code\_\_

```python

In [82]: a=hello()

In [83]: b=hello()

In [84]: a.__code__
Out[84]: <code object greet at 0x72132729f430, file "<ipython-input-70-314e94ed185d>", line 2>

In [85]: b.__code__
Out[85]: <code object greet at 0x72132729f430, file "<ipython-input-70-314e94ed185d>", line 2>

In [86]: a.__code__ is b.__code__
Out[86]: True

In [87]: a is b
Out[87]: False
```

Python：

```
函数对象 ≈ 实例对象

code对象 ≈ 类定义
```

 
__code__ 相等是因为：

- `__code__` 返回的是一个真实的代码对象引用；
- 两个函数对象内部引用了同一个代码对象；
- is 比较的是对象身份，不经过字符串转换。


## 基础1


```python
In [20]: def hello(name='Jose'):
    ...:     print('The hello() function has been executed!')
    ...:     def greet():
    ...:         return '\t This is the greet() func inside hello!'
    ...:     return greet
    ...:

In [21]: a=hello()
The hello() function has been executed!

In [22]: a()
Out[22]: '\t This is the greet() func inside hello!'

#它不是删除函数代码。它只是删除名字，即删除hello来引用该函数
In [23]: del hello

In [24]: a()
Out[24]: '\t This is the greet() func inside hello!'
```

1. `del hello`不是删除函数代码。它只是删除名字，即删除hello来引用该函数
2. `return greet`已经把 greet 函数对象返回到外部了。它从“局部名字”变成了“外部引用”。

## 基础2

- 函数可以被分配给其他变量，通过该变量执行
- 函数是可以传递给其他对象的对象

```python

In [2]: def func():
   ...:     return 1
   ...:

In [3]: func()
Out[3]: 1

In [4]: func
Out[4]: <function __main__.func()>

In [5]: def hello():
   ...:     return "hello!"
   ...:

In [6]: hello()
Out[6]: 'hello!'

In [7]: hello
Out[7]: <function __main__.hello()>

In [8]: greet=hello

In [9]: greet
Out[9]: <function __main__.hello()>

In [10]: greet()
Out[10]: 'hello!'

In [11]: del hello

In [12]: hello
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[12], line 1
----> 1 hello

NameError: name 'hello' is not defined

In [13]: greet()
Out[13]: 'hello!'

#即使删除了hello，greet仍然指向原始的函数对象。
In [14]: greet
Out[14]: <function __main__.hello()>
```

> 在另一个函数中传递函数/调用函数

## 基础3

```python
In [7]: def hello(name='Jose'):
   ...:     print('The hello() function has been executed!')
   ...:     def greet():
   ...:         return '\t This is the greet() func inside hello!'
   ...:     def welcome():
   ...:         return '\t This is the welcome() inside hello!'
   ...:     print(greet())
   ...:     print(welcome())
   ...:     print('This is the end of the hello func')
   ...:

In [8]: hello()
The hello() function has been executed!
         This is the greet() func inside hello!
         This is the welcome() inside hello!
This is the end of the hello func

#greet和welcome的作用域仅限于hello
In [9]: welcome
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[9], line 1
----> 1 welcome

NameError: name 'welcome' is not defined
```

> 拥有一个函数，然后再函数内部定义一个函数，然后返回函数

```python
In [17]: def hello(name='Jose'):
    ...:     print('The hello() function has been executed!')
    ...:     def greet():
    ...:         return '\t This is the greet() func inside hello!'
    ...:     def welcome():
    ...:         return '\t This is the welcome() inside hello!'
    ...:     print('I am going to return a function!')
    ...:     if name == 'Jose':
    ...:         return greet
    ...:     else:
    ...:         return welcome
    ...:

In [18]: my_new_func=hello('Jose')
The hello() function has been executed!
I am going to return a function!

In [19]: print(my_new_func())
         This is the greet() func inside hello!
```

```python
In [21]: def cool():
    ...:     def super_cool():
    ...:         return 'I am very cool!'
    ...:     return super_cool
    ...:

In [22]: some_func=cool()

In [23]: some_func
Out[23]: <function __main__.cool.<locals>.super_cool()>

In [24]: some_func()
Out[24]: 'I am very cool!'
```

## 基础4

```python
In [2]: def other(some_def_func):
   ...:     print('Other code runs here!')
   ...:     print(some_def_func())
   ...:

In [3]: hello
Out[3]: <function __main__.hello()>

In [4]: hello()
Out[4]: 'Hi Jose!'

In [5]: other(hello)
Other code runs here!
Hi Jose!
```

> 实际的原始函数是礼物，我们要把它放在一个盒子里包装起来

```python
#接收那个想要装饰器的函数，用额外的东西包装他，然后返回那个函数的包装版本(wrap_func)
In [6]: def new_decorator(original_func):
   ...:     def wrap_func():
   ...:         print('some extra code,before the original function')
   ...:         #原始函数
   ...:         original_func()
   ...:         print('som extra code ,after the original function')
   ...:     return wrap_func
   ...:
```

```python
In [6]: def new_decorator(original_func):
   ...:     def wrap_func():
   ...:         print('some extra code,before the original function')
   ...:         original_func()
   ...:         print('som extra code ,after the original function')
   ...:     return wrap_func
   ...:

In [7]: def func_needs_decorator():
   ...:     print("I want to be decorated!")
   ...:

In [8]: func_needs_decorator()
I want to be decorated!

In [9]: decorated_func=new_decorator(func_needs_decorator)

In [10]: decorated_func()
some extra code,before the original function
I want to be decorated!
som extra code ,after the original function
```

> 简化（语法糖）

```python
In [16]: @new_decorator
    ...: def func_needs_decorator():
    ...:     print("I want to be decorated!")
    ...:

In [17]: func_needs_decorator()
some extra code,before the original function
I want to be decorated!
som extra code ,after the original function
```

> 当你附加这个装饰器时，它只是用一些额外代码装饰你的函数

