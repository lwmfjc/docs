---
title: "105"
description: "105"
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

## 基础

函数可以被分配给其他变量，通过该变量执行

