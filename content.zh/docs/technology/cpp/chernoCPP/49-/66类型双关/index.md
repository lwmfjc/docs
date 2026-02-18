---
title: 66类型双关
description: 66类型双关
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-17T08:59:40+08:00
lastmod: 2026-02-17T08:59:40+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 类型双关指的是，C++绕过类型系统的一种方式，C++是强类型语言，不会把所有东西都设置为auto（可以，但不推荐）  
- C++中类型在一定程度上==由编译器强制限定==，但你可以==直接访问内存==
- 本章节实例会访问某个int数值的内存，并把它当做双精度数来处理

