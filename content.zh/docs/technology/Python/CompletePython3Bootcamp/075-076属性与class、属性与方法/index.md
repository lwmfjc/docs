---
title: "075-076属性与class、属性与方法"
description: "075-076属性与class、属性与方法"
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-20T22:12:20+08:00
lastmod: 2026-09-20T22:12:20+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 属性与class 关键字

```python
In [2]: mylist=[1,2,3]

In [3]: myset=set()

In [4]: type(myset)
Out[4]: set

In [5]: type(mylist)
Out[5]: list

In [6]: class SampleWord():
   ...:     pass
   ...:

In [7]: sample_word=SampleWord()

In [8]: type(sample_word)
Out[8]: __main__.SampleWord #这个类是在当前正在运行的 Python 主程序/交互环境中定义的。
```

> 类定义也有作用域

```python
def test():
    class SampleWord:
        pass

    a = SampleWord()   # 可以

a = SampleWord()       # NameError

#因为 SampleWord 只存在于 test() 的局部作用域。
```

函数在类内部被特成为“方法”  

```python
In [10]: class Dog():
    ...:     #大多数面向对象语言将其作为隐藏参数传递给对象上定义的方法，但是Python中必须显示声明它
    ...:     def __init__(self,breed):
    ...:         self.breed=breed
    ...:

In [11]: my_dog=Dog()
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[11], line 1
----> 1 my_dog=Dog()

TypeError: Dog.__init__() missing 1 required positional argument: 'breed'

In [12]: my_dog=Dog(breed='Lab')

In [13]: type(my_dog)
Out[13]: __main__.Dog

In [14]: my_dog.breed
Out[14]: 'Lab'

In [15]: my_dog2=Dog('heih')

In [16]: my_dog2.breed
Out[16]: 'heih'
```

> 第一个参数不一定叫是self，也可以叫其他任意名字

```python
In [17]: class DogTest():
    ...:     def __init__(abc,breed):
    ...:         abc.breed=breed
    ...:

In [18]: dog_test=DogTest()
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[18], line 1
----> 1 dog_test=DogTest()

TypeError: DogTest.__init__() missing 1 required positional argument: 'breed'

In [19]: dog_test=DogTest('heihei2')

In [20]: type(dog_test)
Out[20]: __main__.DogTest

In [21]: dog_test.breed
Out[21]: 'heihei2'
```

```python
In [26]: class Dog():
    ...:     #当创建实例时，Python将调用这个__init__方法，将使用
    ...:     #self代表对象实例本身
    ...:     def __init__(self,mybreed):
    ...:         #使用参数来赋值对象属性 self.attribute_name
    ...:         self.my_attribute=mybreed
    ...:

In [27]: my_dog=Dog(mybreed='Huskie')

In [28]: type(my_dog)
Out[28]: __main__.Dog

In [29]: my_dog.my_attribute
Out[29]: 'Huskie'
```

多个参数  

```python
In [35]: class Dog():
    ...:     #当创建实例时，Python将调用这个__init__方法，将使用
    ...:     #self代表对象实例本身
    ...:     def __init__(self,breed,name,spots):
    ...:         #使用参数来赋值对象属性 self.attribute_name
    ...:         self.breed=breed
    ...:         self.name=name
    ...:         #期望是布尔值
    ...:         self.spots=spots
    ...:

In [36]: my_dog=Dog(breed='Huskie',name='Sammy',spots=False)

In [37]: type(my_dog)
Out[37]: __main__.Dog

In [38]: my_dog.breed
Out[38]: 'Huskie'

In [39]: my_dog.name
Out[39]: 'Sammy'

In [40]: my_dog.spots
Out[40]: False

#不能直接传入元组，会被当做仅一个参数
In [41]: my_dog2=Dog(('heiha','en?',True))
---------------------------------------------------------------------------
TypeError                                 Traceback (most recent call last)
Cell In[41], line 1
----> 1 my_dog2=Dog(('heiha','en?',True))

TypeError: Dog.__init__() missing 2 required positional arguments: 'name' and 'spots'

```

# 类对象属性与方法

```python

In [45]: class Dog():
    ...:     #类对象属性
    ...:     #对于所有类实例都是相同的
    ...:     species='mammal'
    ...:     #当创建实例时，Python将调用这个__init__方法，将使用
    ...:     #self代表对象实例本身
    ...:     def __init__(self,breed,name,spots):
    ...:         #使用参数来赋值对象属性 self.attribute_name
    ...:         self.breed=breed
    ...:         self.name=name
    ...:         #期望是布尔值
    ...:         self.spots=spots
    ...:

In [46]: my_dog=Dog(breed='Lab',name='Sam',spots=False)

In [47]: my_dog.species
Out[47]: 'mammal'

In [48]: Dog.species
Out[48]: 'mammal'

#实例对象.类对象属性 无法直接修改类对象属性值
In [49]: my_dog.species='change_species'

In [50]: Dog.species
Out[50]: 'mammal'

In [51]: my_dog.species
Out[51]: 'change_species'

In [52]: my_dog1=Dog(breed='Lab1',name='Sam1',spots=True)

In [53]: my_dog1.species
Out[53]: 'mammal'

In [54]: Dog.species='change2_species'

In [55]: my_dog1.species
Out[55]: 'change2_species'

In [56]: Dog.species
Out[56]: 'change2_species'
```

## 说明访问实例对象属性的顺序

这个测试非常典型，它正好说明了 **“类属性”和“实例属性”之间的关系**。

你这段代码最关键的是：

```python
class Dog():
    species = 'mammal'

    def __init__(self, breed, name, spots):
        self.breed = breed
        self.name = name
        self.spots = spots
```

这里：

```python
species = 'mammal'
```

是**类属性**。

而：

```python
self.breed
self.name
self.spots
```

是**实例属性**。

---

### 1. 刚创建 `my_dog` 时发生了什么？

```python
my_dog = Dog(breed='Lab', name='Sam', spots=False)
```

可以理解成创建了一个对象：

```text
my_dog
 ├── breed = 'Lab'
 ├── name = 'Sam'
 └── spots = False
```

注意：

```text
my_dog
```

里面**没有**：

```text
species
```

`species` 仍然在 `Dog` 类里面：

```text
Dog
 └── species = 'mammal'
```

所以此时结构大概是：

```text
              Dog
               │
        species='mammal'
               │
               │
             my_dog
          ┌────┼────┐
          ↓    ↓    ↓
       breed  name spots
        Lab   Sam  False
```

---

### 2. 为什么 `my_dog.species` 能访问？

你执行：

```python
my_dog.species
```

得到：

```python
'mammal'
```

这并不意味着：

```python
my_dog
```

里面真的有一个 `species`。

Python 查找属性时，可以简单理解成：

```text
my_dog.species
       ↓
先找 my_dog 自己有没有 species
       ↓
没有
       ↓
再去 my_dog 的类 Dog 里面找
       ↓
Dog.species
       ↓
'mammal'
```

所以：

```python
my_dog.species
```

能够找到类属性。

这也是为什么我上一条说：

> **实例也可以访问类属性。**

---

### 3. 为什么 `Dog.species` 也是 `'mammal'`？

这个就简单了：

```python
Dog.species
```

直接在 `Dog` 类里面找：

```python
species = 'mammal'
```

所以：

```python
Dog.species
# 'mammal'
```

---

### 4. 真正关键的是这里

然后你执行：

```python
my_dog.species = 'change_species'
```

很多刚学 Python 的人会误以为：

> “是不是把 Dog.species 修改了？”

**不是。**

它实际上创建了一个新的**实例属性**。

原来：

```text
Dog
 └── species = 'mammal'

my_dog
 ├── breed = 'Lab'
 ├── name = 'Sam'
 └── spots = False
```

执行：

```python
my_dog.species = 'change_species'
```

之后变成：

```text
Dog
 └── species = 'mammal'

my_dog
 ├── breed = 'Lab'
 ├── name = 'Sam'
 ├── spots = False
 └── species = 'change_species'
```

也就是说：

```python
my_dog.species = 'change_species'
```

**不是修改 `Dog.species`，而是在 `my_dog` 身上创建了一个叫 `species` 的实例属性。**

---

### 5. 这就解释了后面的结果

现在：

```python
Dog.species
```

还是：

```python
'mammal'
```

因为：

```text
Dog.species
    ↓
直接找 Dog
    ↓
'mammal'
```

没有任何变化。

但是：

```python
my_dog.species
```

现在变成：

```python
'change_species'
```

因为现在 `my_dog` 自己已经有：

```text
species = 'change_species'
```

所以查找：

```python
my_dog.species
```

时：

```text
先找 my_dog
    ↓
找到了 species
    ↓
直接返回 'change_species'
```

不会再去 `Dog` 里面找。

---

### 6. 你可以把它理解成“覆盖”

这里的概念非常重要：

```python
class Dog:
    species = 'mammal'
```

相当于给所有 Dog 提供了一个**默认的类属性**：

```text
Dog.species
       ↓
    mammal
```

正常情况下：

```python
dog1 = Dog(...)
dog2 = Dog(...)
dog3 = Dog(...)
```

它们都可以：

```python
dog1.species
dog2.species
dog3.species
```

得到：

```text
mammal
```

但是如果：

```python
dog1.species = 'something'
```

就相当于：

```text
Dog
 └── species = mammal

dog1
 └── species = something  ← 自己有了一个
     
dog2
 └── 没有 species
     
dog3
 └── 没有 species
```

于是：

```python
dog1.species
# something

dog2.species
# mammal

dog3.species
# mammal

Dog.species
# mammal
```

---

### 7. 这实际上揭示了一个非常重要的 Python 属性查找规则

可以先记成：

```text
obj.attribute
     ↓
① 先找 obj 自己有没有
     ↓
② 没有的话，再找 obj 的类有没有
```

所以你的例子：

```python
my_dog.species
```

第一次：

```text
my_dog 没有 species
       ↓
Dog 有 species
       ↓
'mammal'
```

执行：

```python
my_dog.species = 'change_species'
```

之后：

```text
my_dog 有 species
       ↓
直接使用 my_dog 自己的
       ↓
'change_species'
```

而：

```python
Dog.species
```

始终直接访问：

```text
Dog 自己的 species
       ↓
'mammal'
```

---

### 最核心的一句话

```python
my_dog.species = 'change_species'
```

**不是修改类属性，而是在 `my_dog` 实例上创建了一个同名的实例属性，从而“遮住/覆盖”了通过 `my_dog.species` 对类属性的访问。**

这也是为什么**类属性和实例属性可以同名**。

## 可以在类定义外操作属性

```python
In [132]: my_dog.xx
Out[132]: 1

In [133]: del my_dog.xx

In [134]: my_dog.xx
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Cell In[134], line 1
----> 1 my_dog.xx

AttributeError: 'Dog' object has no attribute 'xx'
```

> slog限制动态增加

```python
In [136]: class Dog:
     ...:     __slots__ = ("name",)
     ...:

In [137]: dog = Dog()

In [138]: dog.name
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Cell In[138], line 1
----> 1 dog.name

AttributeError: 'Dog' object has no attribute 'name'

In [139]: dog.name="hei"

In [140]: dog.name
Out[140]: 'hei'

In [141]: dog.age=12
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Cell In[141], line 1
----> 1 dog.age=12

AttributeError: 'Dog' object has no attribute 'age'

#但是不限制删除，允许删除slot中的属性
In [142]: del dog.name

In [143]: dog.name
---------------------------------------------------------------------------
AttributeError                            Traceback (most recent call last)
Cell In[143], line 1
----> 1 dog.name

AttributeError: 'Dog' object has no attribute 'name'
```

## 方法及对象属性、类对象属性

```python
In [56]: class Dog():
    ...:     #类对象属性
    ...:     #对于所有类实例都是相同的
    ...:     species='mammal'
    ...:     #当创建实例时，Python将调用这个__init__方法，将使用
    ...:     #self代表对象实例本身
    ...:     def __init__(self,breed,name):
    ...:         #使用参数来赋值对象属性 self.attribute_name
    ...:         self.breed=breed
    ...:         self.name=name
    ...:     #操作/动作---->方法
    ...:     def bark(self):
    ...:         print(f'WOOF!my name:{self.name}')
    ...:         #print(f'WOOF!my name:{name}') #错误，不允许省略self.
    ...:

#没有再传递实际参数名（但得按顺序）
In [57]: my_dog=Dog('Lab','Frankie')

In [58]: type(my_dog)
Out[58]: __main__.Dog

In [59]: my_dog.species
Out[59]: 'mammal'

In [60]: my_dog.bark()
WOOF!

In [61]: my_dog.bark
#这是一个绑定到Dog对象的方法
Out[61]: <bound method Dog.bark of <__main__.Dog object at 0x7cf573ea61e0>>

```

> 普通方法中不能直接通过属性名访问类对象属性

```python

In [69]: class Dog():
    ...:     #类对象属性
    ...:     #对于所有类实例都是相同的
    ...:     species='mammal'
    ...:     #当创建实例时，Python将调用这个__init__方法，将使用
    ...:     #self代表对象实例本身
    ...:     def __init__(self,breed,name):
    ...:         #使用参数来赋值对象属性 self.attribute_name
    ...:         self.breed=breed
    ...:         self.name=name
    ...:     #操作/动作---->方法
    ...:     def bark(self):
    ...:         #直接访问类对象属性，会报错
    ...:         print(f'WOOF!{species}')
    ...:         #print(f'WOOF!{Dog.species}') #正确的写法
    ...:

In [70]: my_dog=Dog('Lab','Frankie')

In [71]: my_dog.species
Out[71]: 'mammal'

In [72]: my_dog.bark()
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[72], line 1
----> 1 my_dog.bark()

Cell In[69], line 13, in Dog.bark(self)
     12 def bark(self):
---> 13     print(f'WOOF!{species}')

NameError: name 'species' is not defined
```

> 静态方法和类对象方法，也都不可以直接访问类对象属性

```python

In [80]: class Dog():
    ...:     #类对象属性
    ...:     #对于所有类实例都是相同的
    ...:     species='mammal'
    ...:     #当创建实例时，Python将调用这个__init__方法，将使用
    ...:     #self代表对象实例本身
    ...:     def __init__(self,breed,name):
    ...:         #使用参数来赋值对象属性 self.attribute_name
    ...:         self.breed=breed
    ...:         self.name=name
    ...:     #操作/动作---->方法
    ...:     def bark(self):
    ...:         print(f'WOOF!{Dog.species}')
    ...:     @staticmethod
    ...:     def s():
    ...:         print(f'{species}')
    ...:     @classmethod
    ...:     def c(cls):
    ...:         print(f'{species}')
    ...:
    
In [83]: my_dog=Dog('Lab','Frankie')

In [84]: my_dog.s()
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[84], line 1
----> 1 my_dog.s()

Cell In[81], line 16, in Dog.s()
     14 @staticmethod
     15 def s():
---> 16     print(f'{species}')

NameError: name 'species' is not defined

In [85]: my_dog.c()
---------------------------------------------------------------------------
NameError                                 Traceback (most recent call last)
Cell In[85], line 1
----> 1 my_dog.c()

Cell In[81], line 19, in Dog.c(cls)
     17 @classmethod
     18 def c(cls):
---> 19     print(f'{species}')

NameError: name 'species' is not defined
species
```

> 要么通过`cls`，要么通过`类名.属性`，还可以`self.属性`  

```python
In [86]: class Dog():
     ...:     #类对象属性 
     ...:     #对于所有类实例都是相同的
     ...:     species='mammal'
     ...:     #当创建实例时，Python将调用这个__init__方法，将使用
     ...:     #self代表对象实例本身
     ...:     def __init__(self,breed,name):
     ...:         #使用参数来赋值对象属性 self.attribute_name
     ...:         self.breed=breed
     ...:         self.name=name
     ...:     #操作/动作---->方法
     ...:     def bark(self):
     ...:         print(f'WOOF!{Dog.species}--self:{self.species}')
     ...:     @staticmethod
     ...:     def s():
     ...:         print(f'{Dog.species}')
     ...:     @classmethod
     ...:     def c(cls):
     ...:         print(f'{cls.species}')

In [101]: my_dog=Dog('Lab','Frankie')

In [102]: my_dog.s()
mammal

In [103]: my_dog.c()
mammal

In [104]: my_dog.bark()
WOOF!mammal--self:mammal
```

### 总结

| 属性                  | 本质   | 常见访问方式                          |
| ------------------- | ---- | ------------------------------- |
| `class_property`    | 属于类  | `Dog.class_property`            |
|                     |      | `cls.class_property`            |
|                     |      | `self.class_property` 也可以       |
| `instance_property` | 属于实例 | `self.instance_property`        |
|                     |      | `dog.instance_property`         |
|                     |      | `another_dog.instance_property` |

> ***类属性可以通过类或实例访问；实例属性必须通过实例访问。***

## 方法的其他使用

```python
In [106]: class Dog():
     ...:     #类对象属性
     ...:     #对于所有类实例都是相同的
     ...:     species='mammal'
     ...:     #当创建实例时，Python将调用这个__init__方法，将使用
     ...:     #self代表对象实例本身
     ...:     def __init__(self,breed,name):
     ...:         #使用参数来赋值对象属性 self.attribute_name
     ...:         self.breed=breed
     ...:         self.name=name
     ...:     #操作/动作---->方法
     ...:     def bark(self,number):
     ...:         print(f'WOOF!Myname is {self.name},number is {number}')
     ...:

In [107]: my_dog=Dog('Lab','Frankie')

In [108]: type(my_dog)
Out[108]: __main__.Dog 

In [111]: my_dog.bark(123)
WOOF!Myname is Frankie,number is 123
```

```python
In [147]: class Circle():
     ...:     #CLASS OBJECT ATTRIBUTE
     ...:     pi=3.14
     ...:     def __init__(self,radius=1):
     ...:         self.radius=radius
     ...:         self.area=radius*radius*self.pi #也可以不用通过参数直接定义属性
     ...:     #方法
     ...:     def get_circumFerence(self):
     ...:         #return self.radius * self.pi * 2
     ...:         return self.radius * Circle.pi * 2 #建议用Circle.pi
     ...:

In [148]: my_circle=Circle()

In [149]: my_circle.get_circumFerence()
Out[149]: 6.28

In [150]: my_circle.pi
Out[150]: 3.14
```


