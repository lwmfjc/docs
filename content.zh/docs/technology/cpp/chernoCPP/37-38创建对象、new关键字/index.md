---
title: 37-38创建对象、new关键字
description: 37-38创建对象、new关键字
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-10T22:39:57+08:00
lastmod: 2026-01-10T22:39:57+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 创建对象

两种方式，取决于我们在内存的哪个位置创建对象(堆heap或栈stack)  

C++ 有一条基本准则：任何不同的对象在内存中都必须有唯一的地址。所以如果创建了两个对象`class Empty {};Empty e1;Empty e2;`，只有他们都有1字节大小的情况下，e1和e2才会有不同的内存地址  

- 栈上创建的对象，有自动的生命周期，由他们的作用域决定的，离开作用域则消失    
- 堆上创建的对象，会一直在，直到你手动释放它
