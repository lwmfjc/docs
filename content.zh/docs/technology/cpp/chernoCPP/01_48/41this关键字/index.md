---
title: 41this关键字
description: 41this关键字
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-11T23:07:21+08:00
lastmod: 2026-01-11T23:07:21+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
this： 是一个指针，指向当前对象实例  

```cpp
#include <iostream> 

class Entity;//必要的，视频没有加上
void PrintEntity(Entity* e);
void PrintEntity2(const Entity& e);

class Entity
{
public:
	int x, y;

	Entity(int x, int y)
	{
		//这里会报错，this是指针常量
		//this = nullptr;
		
		//this是指针常量
		//这里如果不加const不会报错,
		//视频教程中必须加否则报错，不知道为啥
		Entity* const e = this; 
		
		//或者//(*e).x = x;
		e->x = x;

		this->x = x;
		this->y = y;

		PrintEntity(this);
		PrintEntity2(*this);
		delete e;
 	}

	int GetX() const
	{
		//没有const修饰会报错
		//Entity* e = this;
		const Entity* e = this;
		return x;
	}
};


void PrintEntity(Entity* e)
{
	//Print
}
void PrintEntity2(const Entity& e)
{
	//Print
}

int main()
{

	std::cin.get();
}
```