---
title: "062嵌套语句与作用域"
description: "062嵌套语句与作用域"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-18T22:39:30+08:00
lastmod: 2026-09-18T22:39:30+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 闭包的解释

“闭包”这个名字确实容易让人觉得高深，但它本质上是一个**函数 + 它能够访问的外部变量环境**。

先说名字，再说 Python 和 JavaScript。

---

## 1. 为什么叫“闭包”（Closure）？

英文叫 **Closure**。

它来自数学里的概念：

> 一个集合对于某种运算是“闭合的”（closed），运算后的结果仍然属于这个集合。

例如：

整数集合：

```
1 + 2 = 3
```

结果还是整数，所以整数对加法是闭合的。

---

程序语言借用了这个思想：

一个函数如果把它需要的外部变量“封闭”起来，形成一个完整的东西：

```
函数
+
它引用的外部环境
=
闭包
```

也就是说：

> 函数把外部依赖的变量一起“包”起来了，所以叫 Closure（闭合、封闭）。

中文翻译成“闭包”，其实不是很好理解。

更直白：

> **带着记忆的函数**

可能更容易理解。

---

## 2. 普通函数的问题

看一个普通函数：

```python
def add(x, y):
    return x + y


print(add(1, 2))
```

调用：

```
add(1,2)
```

函数执行完：

```
x = 1
y = 2
```

这些局部变量消失。

---

但是如果函数想“记住”一些东西呢？

例如：

创建一个加 5 的函数：

```python
add5(10)  # 15
add5(20)  # 25
```

你可能写：

```python
def add5(x):
    return x + 5
```

没问题。

但是如果想动态创建：

```python
add10 = create_adder(10)

add10(3)
# 13

add100 = create_adder(100)

add100(3)
# 103
```

怎么办？

---

## 3. Python闭包

先看：

```python
def create_adder(n):

    def adder(x):
        return x + n

    return adder
```

调用：

```python
add10 = create_adder(10)

print(add10(5))
```

输出：

```
15
```

这里发生了什么？

---

执行：

```python
add10 = create_adder(10)
```

进入：

```
create_adder
```

里面：

```
n = 10
```

创建：

```python
adder(x)
```

然后返回：

```python
return adder
```

注意：

函数返回了。

按普通理解：

```
create_adder结束

n应该消失
```

但是：

```python
add10(5)
```

还能访问：

```
n = 10
```

为什么？

因为 Python 创建了闭包：

```
add10
 |
 |
 +---- adder函数
 |
 +---- n=10
```

这个 `n` 被函数“带走”了。

---

可以查看：

```python
print(add10.__closure__)
```

可能看到：

```
(<cell at 0x...: int object at ...>,)
```

里面保存了：

```
10
```

---

## 4. Python闭包的三个条件

通常认为：

一个闭包需要：

### ① 有嵌套函数

```python
def outer():

    def inner():
        pass
```

---

### ② 内层函数引用外层变量

例如：

```python
def outer(x):

    def inner():
        print(x)
```

这里：

```
inner使用x
```

---

### ③ 外层函数返回内层函数

```python
return inner
```

完整：

```python
def outer(x):

    def inner():
        print(x)

    return inner
```

---

## 5. Python闭包有什么用？

### 用途1：保存状态

例如计数器：

```python
def counter():

    count = 0

    def add():

        nonlocal count
        count += 1
        return count

    return add
```

使用：

```python
c = counter()

print(c())
print(c())
print(c())
```

输出：

```
1
2
3
```

这里：

```
count
```

一直存在。

---

### 用途2：装饰器

Python大量使用闭包。

例如：

```python
def logger(func):

    def wrapper():

        print("before")

        func()

        print("after")

    return wrapper
```

这个：

```
wrapper
```

记住：

```
func
```

所以形成闭包。

---

## 6. JavaScript里的闭包

JavaScript的闭包概念和 Python 几乎一样。

看：

```javascript
function createAdder(n){

    return function(x){

        return x + n;

    }

}


let add10 = createAdder(10);


console.log(add10(5));
```

输出：

```
15
```

---

执行过程：

调用：

```javascript
createAdder(10)
```

产生：

```
n = 10
```

返回匿名函数：

```javascript
function(x){
    return x+n;
}
```

函数离开：

```
createAdder结束
```

但是：

```javascript
add10(5)
```

仍然可以访问：

```
n
```

因为闭包保存了环境。

结构：

```
add10
 |
 |
 +--- function(x)
 |
 +--- n=10
```

---

## 一句话总结

**闭包 = 一个函数 + 它创建时捕获的外部变量环境。** 

> **函数离开了原来的作用域，但它仍然记得当时的变量。**

所以叫 **Closure（闭合/封闭）**。它不是高级魔法，本质就是“函数携带了一份自己的小环境”。


# 嵌套语句与作用域

理解Python如何处理变量名赋值非常重要。在Python中创建变量名时，该名称会被存储在所谓的**命名空间**中，变量名还具有**作用域**，作用域决定了**变量名在代码其他部分的可见性**  

```python
In [1]: x=25

In [2]: def printer():
   ...:     x=50
   ...:     return x
   ...:

#x为何是50
In [3]: print(x)
25

In [4]: print(printer())
50

```

***LEGB规则体系：LEGB代表局域作用域、闭包函数作用域、全局作用域和内建作用域。***  

LEGB 规则：   
- L: Local（局部作用域） — 在**函数（def 或 lambda）内部以任何方式赋值且未在该函数中声明为全局（global）的名称**。   
- E: Enclosing function locals（嵌套/闭包作用域） — 任何及所有**外层嵌套函数（def 或 lambda）的局部作用域中的名称**，按由内到外的顺序查找。   
- G: Global (module)（全局/模块作用域） — 在**模块文件的最顶层**赋值的名称，或在**文件内的 def 函数中明确声明为全局（global）**的名称。   
- B: Built-in (Python)（内置作用域） — **内置名称模块中预先赋值的名称**，例如：open、range、SyntaxError 等。   

## 局部作用域

```python
#这里的num只作用域lambda表达式
In [2]: lambda num:num**2
Out[2]: <function __main__.<lambda>(num)>

In [3]: num
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[3], line 1
----> 1 num

NameError: name 'num' is not defined

In [4]: type(num)
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[4], line 1
----> 1 type(num)

NameError: name 'num' is not defined
```

------

```python
#GLOBAL
In [6]: name='This is a global string'

In [16]: def greet():
    ...:     #ENCLOSING
    ...:     name='sammy'
    ...:     def hello():
    ...:         #LOCAL
    ...:         name='IM A LOCAL'
    ...:         print('Hello ' + name)
    ...:     hello()
    ...:

In [17]: greet()
Hello IM A LOCAL
```

1. 先查找局部命名空间（嵌套的hello函数定义中是否有name）
2. 查找闭包函数作用域，即闭包函数greet是否定义了
3. 如果注释掉name='Sammy'，接下来会去全局层级查找定义 ~~特征：无缩进格式~~ 

------

```python
#通过help()查看是否是内建函数
In [19]: help(len)


In [20]: help(len1)
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[20], line 1
----> 1 help(len1)

NameError: name 'len1' is not defined
```

### 重赋值例子

```python

In [4]: x=50

In [5]: def func(x):
   ...:     print(f'x is {x}')
   ...:     #这里的重赋值只发生在函数内部的局部命名空间，不会影响更高层级的作用域
   ...:     #LOCAL RESSIGNMENT!
   ...:     x=200
   ...:     print(f'I JUST LOCALLY CHANGED X TO {x}')
   ...:

In [6]: func(x)
x is 50
I JUST LOCALLY CHANGED X TO 200

In [7]: print(x)
50
```

## 错误

```python
In [10]: def func1(x):
    ...:
    ...:     print(f'x is {x}')
    ...:     global x
    ...:     #LOCAL RESSIGNMENT!
    ...:     x=200
    ...:     print(f'I JUST LOCALLY CHANGED X TO {x}')
  Cell In[10], line 4
    global x
    ^
#x已经是局部变量（参数）了，不允许重名
SyntaxError: name 'x' is parameter and global
```

```python
#不能同时声明同名的Local变量：在声明 x 是全局变量之前，已经把 x 当成局部变量使用了
In [11]: def func():
    ...:     x=123
    ...:     print(f'x is {x}')
    ...:     global x
    ...:     #LOCAL RESSIGNMENT!
    ...:     print(f'now x is {x}')
  Cell In[11], line 4
    global x
    ^
SyntaxError: name 'x' is used prior to global declaration
```

```python

In [12]: def func():
    ...:     global x
    ...:     #在局部修改了全局变量x
    ...:     x=123
    ...:     print(f'x is {x}')
    ...:     #LOCAL RESSIGNMENT!
    ...:     print(f'now x is {x}')
    ...:

In [13]: x
Out[13]: 50

In [14]: func()
x is 123
now x is 123

In [15]: x
Out[15]: 123

#删除全局变量
In [16]: del x

In [17]: x
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[17], line 1
----> 1 x

NameError: name 'x' is not defined

#创建了全局变量
In [18]: func()
x is 123
now x is 123

In [19]: x
Out[19]: 123
```

> global 不能改变一个已经存在的变量的作用域，它的作用是告诉 Python：函数内部这个名字不要创建局部绑定，而是引用（并允许修改）模块级的全局变量，当然如果该全局变量不存在就创建他。

## 赋值全局变量的推荐做法

- **在函数中使用传入的值 ~~全局变量~~ 再修改后传出，然后在全局中重新赋值全局变量**
- 而且易于调试

```python

In [22]: x=50

In [23]: def func(x):
    ...:     print(f'X is {x}')
    ...:     #LOCAL RESSIAGMENT ON A GLOBAL VARIABLE!
    ...:     x='NEW VALUE'
    ...:     print(f'change x in local: {x}')
    ...:     return x
    ...:

In [24]: x
Out[24]: 50

In [25]: func(x)
X is 50
change x in local: NEW VALUE
Out[25]: 'NEW VALUE'

In [26]: x
Out[26]: 50

#必须重新赋值才会生效
In [27]: x=func(x)
X is 50
change x in local: NEW VALUE

In [28]: x
Out[28]: 'NEW VALUE'
```