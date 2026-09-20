---
title: 074
description: 074
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-20T18:30:06+08:00
lastmod: 2026-09-20T18:30:06+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 面向对象编程简介

- ***面向对象编程，简称OOP。允许程序员创建具有方法和属性的自定义对象***
- 允许我们创建可重复使用且组织有序的代码

类名：驼峰命名法  

```python
class NameOfClass():

    def __init__(self, param1, param2):
        self.param1 = param1
        self.param2 = param2

    def some_method(self):
        # perform some action
        print(self.param1) 
```

当：

```
p = Person("Tom", 20)
```

时，`__init__` 会自动执行，把：

```
name → self.name
age  → self.age
```

## 1. `self` 到底是什么？

普通实例方法：

```python
class Person:

    def say_hello(self):
        print("hello")
```

创建对象：

```python
p = Person()
p.say_hello()
```

这里：

```python
p.say_hello()
```

Python 会自动把 `p` 传给 `self`。

可以近似理解成：

```python
Person.say_hello(p)
```

所以：

```python
class Person:

    def say_hello(self):
        print(self)
```

```python
p = Person()
p.say_hello()
```

打印的就是 `p` 这个对象。

---

## 2. 如果方法没有 `self` 呢？

比如：

```python
class Person:

    def say_hello():
        print("hello")
```

然后：

```python
p = Person()
p.say_hello()
```

会报错。

因为：

```python
p.say_hello()
```

仍然会自动把 `p` 传进去。

相当于：

```python
Person.say_hello(p)
```

但你的函数：

```python
def say_hello():
```

一个参数都没定义。

所以会类似：

```text
TypeError: ... takes 0 positional arguments but 1 was given
```

---

## 3. 那什么时候可以没有 `self`？

这就是**静态方法 `staticmethod`**。

```python
class Math:

    @staticmethod
    def add(a, b):
        return a + b
```

调用：

```python
Math.add(10, 20)
```

得到：

```text
30
```

也可以：

```python
m = Math()
m.add(10, 20)
```

同样可以调用。

这里：

```python
@staticmethod
```

告诉 Python：

> 这个方法不需要自动接收实例对象。

所以：

```python
def add(a, b):
```

这里没有 `self` 是正常的。

---

## 4. 静态方法到底有什么用？

例如：

```python
class Math:

    @staticmethod
    def add(a, b):
        return a + b

    @staticmethod
    def multiply(a, b):
        return a * b
```

这些函数：

```python
add()
multiply()
```

并不需要访问某个具体对象的数据。

所以放在 `Math` 类里面，可以表达一种**归类/组织关系**：

```python
Math.add(1, 2)
Math.multiply(3, 4)
```

你可以暂时把它理解成：

> **属于这个类的一组工具函数，但不依赖具体对象。**

## 5. `self` 和 `staticmethod` 对比

这是非常重要的一组对比：

### 实例方法

```python
class Person:

    def say_name(self):
        print(self.name)
```

依赖对象：

```python
p = Person()
p.name = "Tom"

p.say_name()
```

这里必须有：

```python
self
```

因为需要知道：

> **到底是哪个 Person？**

---

### 静态方法

```python
class Math:

    @staticmethod
    def add(a, b):
        return a + b
```

完全不需要对象：

```python
Math.add(1, 2)
```

因此不需要：

```python
self
```

## 6. 还有一个 `classmethod`

Python 类里面还有：

```python
@classmethod
```

例如：

```python
class Person:

    count = 0

    @classmethod
    def get_count(cls):
        return cls.count
```

这里不是：

```python
self
```

而是：

```python
cls
```

`cls` 可以理解成：

> **当前这个类本身**

例如：

```python
Person.get_count()
```

相当于 Python 自动把：

```python
Person
```

传给：

```python
cls
```

所以：

```python
@classmethod
def get_count(cls):
```

和：

```python
@staticmethod
def xxx():
```

是不同的。

你现在可以先记：

| 类型   | 第一个参数  | 代表       |
| ---- | ------ | -------- |
| 实例方法 | `self` | 当前对象     |
| 类方法  | `cls`  | 当前类      |
| 静态方法 | 没有     | 不自动传对象/类 |

## 7. `__init__` 参数可以不固定吗？

可以。

比如：

```python
class Person:

    def __init__(self, name, age):
        self.name = name
        self.age = age
```

这是固定两个参数：

```python
Person("Tom", 20)
```

但是 Python 支持：

```python
*args
```

和：

```python
**kwargs
```

### `*args`

例如：

```python
class Person:

    def __init__(self, *args):
        self.args = args
```

现在：

```python
p1 = Person()
p2 = Person(1)
p3 = Person(1, 2, 3)
p4 = Person("Tom", 20, "China")
```

都可以。

例如：

```python
p4.args
```

得到：

```python
("Tom", 20, "China")
```

因为 `*args` 会把多余的位置参数收集成一个 **tuple**。

## 8. `**kwargs`

还可以：

```python
class Person:

    def __init__(self, **kwargs):
        self.info = kwargs
```

然后：

```python
p = Person(
    name="Tom",
    age=20,
    city="Guangzhou"
)
```

此时：

```python
p.info
```

是：

```python
{
    "name": "Tom",
    "age": 20,
    "city": "Guangzhou"
}
```

因为：

```python
**kwargs
```

会把额外的**关键字参数**收集成 `dict`。

## 9. `*args + **kwargs` 可以同时使用

例如：

```python
class Person:

    def __init__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs
```

可以：

```python
p = Person(
    10,
    20,
    30,
    name="Tom",
    age=20
)
```

得到：

```python
p.args
```

```text
(10, 20, 30)
```

而：

```python
p.kwargs
```

是：

```text
{
    "name": "Tom",
    "age": 20
}
```

## 10. 还有一种更实用的写法：默认参数

实际上你以后会经常看到：

```python
class Person:

    def __init__(self, name, age=18):
        self.name = name
        self.age = age
```

于是：

```python
p1 = Person("Tom")
```

年龄自动：

```text
18
```

也可以：

```python
p2 = Person("Jack", 25)
```

年龄就是：

```text
25
```

## 11. `__init__` 其实也不是“真正的构造函数”

这里顺便纠正一个 Python 初学者很容易形成的概念。

你经常会看到：

```python
def __init__(self):
```

然后教材说：

> 构造函数

这种说法用于入门没问题，但严格来说，Python 中：

```python
__new__()
```

负责**创建对象**，

而：

```python
__init__()
```

负责**初始化已经创建好的对象**。

所以：

```python
p = Person()
```

背后可以粗略理解成：

```text
__new__()  → 创建对象
     ↓
__init__() → 初始化对象
```

不过你目前学类，**暂时不用深入 `__new__`**。

## 12. classmethod 和 staticmethod 区别

| 方法              | 自动传入   | 能访问实例属性 | 能访问类属性 |
| --------------- | ------ | ------: | -----: |
| 普通实例方法          | `self` |       ✅ |      ✅ |
| `@classmethod`  | `cls`  |       ❌ |      ✅ |
| `@staticmethod` | 什么都不传  |       ❌ |     ❌* |

## 13. Python中创建对象的几种方法

**Python 没有 Java/C++ 那种显式的 `new` 关键字**。

你在 Python 里通常直接写：

```python
p = Person("Tom", 20)
```

这句话就同时完成了“创建对象 + 初始化对象”。

---

### 1. 最常见：直接调用类

```python
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

p = Person("Tom", 20)
```

这是 **99% 的日常写法**。

可以粗略理解为：

```text
Person("Tom", 20)
       ↓
Python 内部创建对象
       ↓
调用 __init__
       ↓
返回对象
```

你不需要写：

```java
new Person("Tom", 20)
```

Python 没有这个 `new` 关键字。

---

### 2. `__new__()`：手动参与对象创建

Python 实际上有：

```python
__new__()
```

例如：

```python
class Person:

    def __new__(cls, name, age):
        print("创建对象")
        return super().__new__(cls)

    def __init__(self, name, age):
        print("初始化对象")
        self.name = name
        self.age = age
```

然后：

```python
p = Person("Tom", 20)
```

流程是：

```text
Person("Tom", 20)
        ↓
     __new__()
        ↓
   创建 Person 对象
        ↓
     __init__()
        ↓
   初始化 Person 对象
        ↓
        p
```

所以严格来说：

```text
__new__  → 创建对象
__init__ → 初始化对象
```

---

### 3. `classmethod`：另一种创建对象的入口

这就是我们刚才讲的：

```python
class Person:

    def __init__(self, name, age):
        self.name = name
        self.age = age

    @classmethod
    def from_name(cls, name):
        return cls(name, 0)
```

可以：

```python
p = Person.from_name("Tom")
```

这里实际上还是：

```python
Person("Tom", 0)
```

所以 `classmethod` **不是另一种底层的对象创建机制**。

它只是提供了一个：

> **方便创建对象的额外入口**

这种方法通常叫 **alternative constructor（替代构造方式）**。

---

### 4. 继承时也可以直接创建

```python
class Animal:
    pass

class Dog(Animal):
    pass

d = Dog()
```

这里同样不需要：

```text
new Dog()
```

直接：

```python
Dog()
```

---

### 5. 还有一些特殊的对象创建方式

Python 内置了一些机制，例如：

```python
list()
dict()
set()
tuple()
```

它们也是在创建对象：

```python
a = list()
b = dict()
c = set()
d = tuple()
```

甚至：

```python
a = []
b = {}
c = set()
```

这些都是创建相应对象的方式。

---

### 你可以把 Python 和 Java 对照起来

#### Java

```java
Person p = new Person("Tom", 20);
```

大致对应：

#### Python

```python
p = Person("Tom", 20)
```

区别在于：

```text
Java
new
 ↓
创建对象
 ↓
构造函数

Python
类名(...)
 ↓
__new__()
 ↓
__init__()
```

所以不要形成：

> “Python 没有 `new`，所以 Python 没有创建对象的机制。”

正确理解是：

> **Python 有 `__new__()`，但日常创建对象时不需要显式调用它，也没有 `new` 这个关键字。**

你现在学习类的话，优先掌握这三个层次就够了：

```text
Person(...)             ← 日常创建对象
    ↓
__new__()               ← 真正创建对象（暂时不用深入）
    ↓
__init__()              ← 初始化对象
```

以及：

```text
Person.from_xxx(...)    ← classmethod 提供的另一种创建入口
```


## 14. 你现在学类，可以先形成这张图

```text
class
│
├── 实例属性
│      self.name
│      self.age
│
├── 实例方法
│      def xxx(self):
│
├── 类属性
│      count = 0
│
├── 类方法
│      @classmethod
│      def xxx(cls):
│
├── 静态方法
│      @staticmethod
│      def xxx():
│
└── 特殊方法
       __init__
       __str__
       __len__
       __eq__
       ...
```

而参数方面：

```text
普通参数
    ↓
def __init__(self, name, age)

默认参数
    ↓
def __init__(self, name, age=18)

可变位置参数
    ↓
def __init__(self, *args)

可变关键字参数
    ↓
def __init__(self, **kwargs)

两者结合
    ↓
def __init__(self, *args, **kwargs)
```

**你现在最值得搞懂的是 `self` → 实例属性 → 实例方法 → `@classmethod` → `@staticmethod` → `*args/**kwargs` 这一条线。**

等你把这几个搞清楚，再学**继承、封装、魔术方法、property**，Python 的类基本框架就完整了。

