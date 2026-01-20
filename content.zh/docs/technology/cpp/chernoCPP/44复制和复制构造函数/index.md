---
title: 44复制和复制构造函数
description: 44复制和复制构造函数
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-14T21:56:11+08:00
lastmod: 2026-01-14T21:56:11+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
了解在C++中复制的实际运作方式，以及如何让它工作，如何避免它工作，避免在不想复制时复制    

当你把变量赋值给另一个变量时，都是在使用复制。如果是指针，则是复制指针的地址（一串数字，而不是指针指向的内容）

```cpp
#include <iostream>
#include <string>

struct Vector2
{
	float x, y;
};

int main()
{
	int a1 = 2;
	int b1 = a1;
	//a，b是两个不同的变量，互不影响
	b1 = 3;
	std::cout << a1 << std::endl;//2
	std::cout << b1 << std::endl;//2

	Vector2 a = { 2,3 };
	Vector2 b = a;
	b.x = 5;
	std::cout << a.x << std::endl;//2
	std::cout << b.x << std::endl;//5

	Vector2* aP = new Vector2();
	//复制了指针，没有复制实际数据，复制的是地址
	Vector2* bP = aP;
	bP->x = 2;
	std::cout << aP->x << std::endl;//2
	std::cout << bP->x << std::endl;//2

	bP++;//aP没有被影响到
	std::cout << aP << std::endl;//000002A2946D9EC0
	std::cout << bP << std::endl;//000002A2946D9EC8

	std::cin.get();
	return 0;
}
```

# 