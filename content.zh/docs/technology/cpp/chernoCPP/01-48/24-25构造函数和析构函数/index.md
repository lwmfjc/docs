---
title: 24-25构造函数和析构函数
description: 24-25构造函数和析构函数
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2025-12-31T15:31:53+08:00
lastmod: 2025-12-31T15:31:53+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
# 构造函数

我们每次实例化一个对象时都会运行的一个特殊函数  

## 例子

```cpp
#include <iostream>

class Entity
{
public:
	//C++中不处理的话默认不初始化任何成员变量
	float X, Y;

	//默认的构造函数，什么都不做
	//不写任何构造函数是会默认添加这个
	//Entity()
	//{

	//}

	//构造函数
	Entity()
	{
		X = 0.00f;
		Y = 0.00f;
	}

	//带参数的构造函数
	Entity(float x, float y) {
		X = x;
		Y = y;
	}

	void  Print() {
		std::cout << X << "," << Y << std::endl;
	}
};

int main()
{

	//Entity e;
	Entity e(10.0f, 5.0f);//栈上分配
	//Entity* e=new Entity(10.0f, 5.0f);//堆上分配
	std::cout << e.X << std::endl;
	e.Print();

	std::cin.get();
}
```

## 不希望其他人使用构造函数

```cpp
class Log
{
private:
	Log()
	{
	}
	//或者
	/*
	Log() = delete;
	*/
public:
	static void Write()
	{
	
	}
}

int main(){
	
	Log l;//这里会报错
}
```

# 析构函数


- 当你摧毁一个对象时，会调用析构函数，析构函数主要用来清楚任何不再需要的内存  
- 最典型的例子，如果在构造对象时在堆上分配内存，则必须在析构函数中手动清理它

```cpp
#include <iostream>

class Entity
{
public:
	//C++中不处理的话默认不初始化任何成员变量
	float X, Y;

	//默认的构造函数，什么都不做
	//不写任何构造函数是会默认添加这个
	//Entity()
	//{

	//}

	//构造函数
	Entity()
	{
		X = 0.00f;
		Y = 0.00f;
		std::cout << "Created Entity!" << std::endl;

	}

	//带参数的构造函数
	Entity(float x, float y) {
		X = x;
		Y = y;
	}


	~Entity()
	{
		std::cout << "Destroyed Entity!" << std::endl;
	}

	void  Print() {
		std::cout << X << "," << Y << std::endl;
	}
};

void Function()
{
	Entity e;//栈上分配
	e.Print();
}

int main()
{
	Function();
   /*
Created Entity!
0,0
Destroyed Entity!

   */

	std::cin.get();
}
```