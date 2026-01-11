---
title: 38new关键字
description: 38new关键字
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-11T12:46:30+08:00
lastmod: 2026-01-11T12:46:30+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- `new 指定数据类型`，数据类型包括类、原始类型、数组，根据数据类型确定必要的大小，以字节为单位
- `new int`，4字节。向操作系统找到连续的4字节大小的内存，然后返回指向该内存地址的指针    
- 有一个空闲列表维护具体可用字节的地址，不需要一个个地址扫描是否可用

