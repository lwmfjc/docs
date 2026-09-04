---
title: 046-047
description: 046-047
categories:
  - 学习
tags:
  - Python
  - CompletePython3Bootcamp
date: 2026-09-04T17:07:32+08:00
lastmod: 2026-09-04T17:07:32+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 方法

- 方法本质上就是类似于对象的函数
- 后续会学习如何使用面向对象编程和类，来创建我们自己的对象和方法
- 本节讲解如何查询Python内置对象的方法，以及如何获取它们的相关信息

```shell
>>> mylist=[1,2,3]
>>> mylist.append(4)
>>> mylist
[1, 2, 3, 4]
>>> mylist.pop()
4
>>> mylist
[1, 2, 3]
#mylist.输入之后，按多次tab键就可以看到该对象可用的方法
>>> mylist.
mylist.append(    mylist.count(     mylist.insert(    mylist.reverse()                    
mylist.clear()    mylist.extend(    mylist.pop(       mylist.sort(                        
mylist.copy()     mylist.index(     mylist.remove(
```

在jupyter中，光标放到左括号`(`之后，然后按shift+tab 即可查看函数使用方法    
![](img/ly-20260904194830068.png)  

```shell
help(mylist.insert)
```

help函数调用后出现下图所示  

![](img/ly-20260904195014003.png)  
# 文档  

https://docs.python.org  

![](img/ly-20260904195347295.png)  

本文重点讲一下库参考文档  

![](img/ly-20260904195510042.png)

https://docs.python.org/zh-cn/3.14/library/index.html  

都是之前讲解过的东西  

![](img/ly-20260904195700860.png)


点击list，更详细讲解方法：  

![](img/ly-20260904195808320.png)

