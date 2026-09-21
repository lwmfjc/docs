---
title: "077"
description: "077"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-21T13:08:09+08:00
lastmod: 2026-09-21T13:08:09+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 继承与多态

```python
In [2]: class Animal():
   ...:     def __init__(self):
   ...:         print("ANIMAL CREATED!")
   ...:

In [3]: myanimal=Animal()
ANIMAL CREATED! 

In [5]: class Animal():
   ...:     def __init__(self):
   ...:         print("ANIMAL CREATED!")
   ...:     def who_am_i(self):
   ...:         print("I am an animal")
   ...:     def eat(self):
   ...:         print("i am eating")
   ...:

In [6]: myanimal=Animal()
ANIMAL CREATED!

In [7]: myanimal.eat()
i am eating 

In [9]: myanimal.who_am_i()
I am an animal
```

## 继承

```python
In [10]: class Dog(Animal):
    ...:     def __init__(self):
    ...:         Animal.__init__(self)
    ...:         print("Dog Created")
    ...:

In [11]: mydog=Dog()
ANIMAL CREATED!
Dog Created

In [13]: mydog.eat()
i am eating

In [14]: mydog.who_am_i()
I am an animal
```

重写/覆盖方法：

```python
In [15]: class Dog(Animal):
    ...:     def __init__(self):
    ...:         Animal.__init__(self)
    ...:         print("Dog Created")
    ...:     #覆盖原来基类的方法
    ...:     def who_am_i(self):
    ...:         print("I am a dog")
    ...:

#这是因为mydog是在原来的类定义创建的实例
In [16]: mydog.who_am_i()
I am an animal

#使用修改后的类定义创建实例
In [17]: mydog=Dog()
ANIMAL CREATED!
Dog Created

In [18]: mydog.who_am_i()
I am a dog
```

> 添加新方法

```python
In [23]: class Dog(Animal):
    ...:     def __init__(self):
    ...:         Animal.__init__(self)
    ...:         print("Dog Created")
    ...:     #覆盖
    ...:     def eat(self):
    ...:         print("I am a dog and eating")
    ...:     #新方法
    ...:     def bark(self):
    ...:         print("WOOF!")
    ...:

In [24]: mydog=Dog()
ANIMAL CREATED!
Dog Created

In [25]: mydog.eat()
I am a dog and eating

In [26]: mydog.bark()
WOOF!
```

> 测试没有`Animal.__init__`

```python
In [27]: class Dog(Animal):
    ...:     def __init__(self):
    ...:         #Animal.__init__(self)
    ...:         print("Dog Created")
    ...:

In [28]: testDog=Dog()
Dog Created

#即使没有在__init__调用Animal.__init__也可以复用父类的方法
In [29]: testDog.eat()
i am eating

In [30]: testDog.who_am_i()
I am an animal
```

## 多态

**不同对象类可以共享相同的方法名，这些方法可以从同一个地方被调用，即使传入的是各种不同的对象。**  

```python

In [1]: class Dog():
   ...:     def __init__(self,name):
   ...:         self.name=name
   ...:     def speak(self):
   ...:         return self.name + " says woof!"
   ...:

In [2]: class Cat():
   ...:     def __init__(self,name):
   ...:         self.name=name
   ...:     def speak(self):
   ...:         return self.name + " says meow!"
   ...:

In [3]: niko=Dog("niko")

In [4]: felix=Cat("felix")

In [5]: print(niko.speak())
niko says woof!

In [6]: print(felix.speak())
felix says meow!
```

> 演示多态

```python
#遍历
In [8]: for pet in [niko,felix]:
   ...:     print(type(pet))
   ...:     print(pet.speak())
   ...:
<class '__main__.Dog'>
niko says woof!
<class '__main__.Cat'>
felix says meow!
```

> 函数

```python
In [9]: def pet_speak(pet):
   ...:     #这里它只关心是否有该函数，并不关心pet是啥类型
   ...:     print(pet.speak())
   ...:

In [10]: pet_speak(niko)
niko says woof!

In [11]: pet_speak(felix)
felix says meow!
```

> 使用抽象类和继承

```python
In [13]: class Animal():
    ...:     def __init__(self,name):
    ...:         self.name=name
    ...:     #抽象方法
    ...:     def speak(self):raise NotImplementedError("Subclass must implement this
       ⋮ abstract method")
    ...:
    
#其实这里并不能彻底禁止实例化，但是早期大量使用这种方式
#这里实例化是成功的，只是不能调用父类方法罢了
In [15]: a=Animal('abc')

In [16]: a.speak()
---------------------------------------------------------------------------
NotImplementedError                       Traceback (most recent call last)
Cell In[16], line 1
----> 1 a.speak()

Cell In[13], line 4, in Animal.speak(self)
      2 def __init__(self,name):
      3     self.name=name
----> 4 def speak(self):raise NotImplementedError("Subclass must implement this abstract method")

NotImplementedError: Subclass must implement this abstract method
```

> 使用ABC真正禁止实例化

```python
In [21]: from abc import ABC,abstractmethod

In [22]: class Animal1(ABC):
    ...:     def __init__(self,name):
    ...:         self.name=name
    ...:     @abstractmethod
    ...:     def speak(self):
    ...:         pass
    ...:

In [23]: lala1=Animal1()
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[23], line 1
----> 1 lala1=Animal1()

TypeError: Can't instantiate abstract class Animal1 without an implementation for abstract method 'speak'
```

实验  

```python
In [25]: class Animal():
    ...:     def __init__(self,name):
    ...:         self.name=name
    ...:     def speak(self):raise NotImplementedError("Subclass must implement this
       ⋮ abstract method")
    ...:

In [26]: class Animal():
    ...:     def __init__(self,name):
    ...:         print("Animal __init__!")
    ...:         self.name=name
    ...:     def speak(self):raise NotImplementedError("Subclass must implement this
       ⋮ abstract method")
    ...:

In [27]: class Cat(Animal):
    ...:     def speak(self):
    ...:         return self.name + " says meow!"
    ...:

In [28]: class Dog(Animal):
    ...:     def speak(self):
    ...:         return self.name + " says woof!"
    ...:

In [29]: fido=Dog("Fido")
Animal __init__!

In [30]: isis=Cat("Isis")
Animal __init__!

In [31]: print(fido.speak())
Fido says woof!

In [32]: print(isis.speak())
Isis says meow!
```

> 子类是否默认调用父类的`__init__`

```python
In [38]: class Animal():
    ...:     def __init__(self,name):
    ...:         print("Animal __init__!")
    ...:         self.name=name
    ...:     def speak(self):raise NotImplementedError("Subclass must implement this
       ⋮ abstract method")
    ...:

#如果重写了父类的__init__，那么除非显示写出Animal.__init(self),否则不会自动调用
In [39]: class Dog(Animal):
    ...:     def __init__(self,name):
    ...:         #Animal.__init__(self,name)
    ...:         print("haha")
    ...:     def speak(self):
    ...:         return self.name + " says woof!"
    ...:

In [40]: Dog("hei").speak()
haha
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Cell In[40], line 1
----> 1 Dog("hei").speak()

Cell In[39], line 5, in Dog.speak(self)
      4 def speak(self):
----> 5     return self.name + " says woof!"

AttributeError: 'Dog' object has no attribute 'name'
```

```python
In [48]: class Animal():
    ...:     def __init__(self,name):
    ...:         print("Animal __init__!")
    ...:         self.name=name
    ...:     def speak(self):raise NotImplementedError("Subclass must implement this
       ⋮ abstract method")
    ...:

In [49]: class Dog(Animal):
    ...:     #没有重写父类的__init__，
    ...:     def speak(self):
    ...:         return self.name + " says woof!"
    ...:

In [50]: Dog("hei").speak()
Animal __init__!
Out[50]: 'hei says woof!'
```

### 原因


> **子类没有自己的 `__init__()` 方法时，Python会直接继承父类的 `__init__()` 方法。**

也就是说：

```python
class Cat(Animal):
    def speak(self):
        return self.name + " says meow!"
```

等价于：

```python
class Cat(Animal):
    def __init__(self, name):
        print("Animal __init__!")
        self.name = name

    def speak(self):
        return self.name + " says meow!"
```

但注意：这不是复制代码，而是**方法查找机制**。

---

例如：

```python
isis = Cat("Isis")
```

Python执行：

1. 查找 `Cat` 有没有 `__init__`

```python
Cat.__dict__
```

发现没有：

```python
{}
```

2. 按继承链查找：

```
Cat
 ↓
Animal
 ↓
object
```

找到：

```python
Animal.__init__
```

3. 调用：

```python
Animal.__init__(isis, "Isis")
```

所以输出：

```
Animal __init__!
```

并设置：

```python
isis.name = "Isis"
```

---

可以验证：

```python
print(Cat.__dict__)
print(Animal.__dict__)
```

输出类似：

```python
In [55]: Cat.__dict__
Out[55]:
mappingproxy({'__module__': '__main__',
              'speak': <function __main__.Cat.speak(self)>,
              '__doc__': None})

In [56]: Animal.__dict__
Out[56]:
mappingproxy({'__module__': '__main__',
              '__init__': <function __main__.Animal.__init__(self, name)>,
              'speak': <function __main__.Animal.speak(self)>,
              '__dict__': <attribute '__dict__' of 'Animal' objects>,
              '__weakref__': <attribute '__weakref__' of 'Animal' objects>,
              '__doc__': None})
```

你会发现：

```python
Cat
```

里面根本没有：

```python
__init__
```

但是：

```python
Cat("Isis")
```

仍然能运行。

原因就是继承。

---

#### 如果子类自己写了 `__init__()` 呢？

例如：

```python
class Cat(Animal):
    def __init__(self,name):
        self.name=name

    def speak(self):
        return self.name+" says meow!"
```

现在：

```python
isis=Cat("Isis")
```

不会输出：

```
Animal __init__!
```

因为父类初始化被覆盖了。

此时：

```python
Animal.__init__
```

不会自动执行。

---

如果想调用父类初始化，需要：

```python
class Cat(Animal):
    def __init__(self,name):
        super().__init__(name)

    def speak(self):
        return self.name+" says meow!"
```

执行：

```python
isis=Cat("Isis")
```

输出：

```
Animal __init__!
```

---

所以总结：

| 情况                  | 结果                      |
| ------------------- | ----------------------- |
| 子类没有 `__init__()`   | 直接继承父类 `__init__()`     |
| 子类有自己的 `__init__()` | 覆盖父类，不会自动调用             |
| 想执行父类初始化            | 使用 `super().__init__()` |

这也是 Python 和 Java 一个明显区别：

Java 子类构造器里会隐式调用 `super()`（如果没有写），而 Python **不会自动调用父类构造器**，只是进行方法继承。

### 基本思想

***你有两个独立的类，他们恰好共享相同的方法名，这样你就可以调用这些相同的方法名而无需担心传入的具体是哪个类***




