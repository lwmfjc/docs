---
title: 45箭头运算符
description: 45箭头运算符
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-04T11:24:32+08:00
lastmod: 2026-02-04T11:24:32+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
在 C++ 中，-> 运算符有一个独特的“递归”特性。当你写下 entity->Print() 时，编译器会查看 entity 的类型：
- 如果 entity 是原生指针：它直接解引用并访问成员。
- 如果 entity 是一个对象（类实例）：
	1. 编译器会调用你重载的 operator->()。
	2. 这个函数必须返回两样东西之一：要么是一个原生指针，要么是另一个重载了 -> 的对象。
	3. 编译器拿到返回的指针后，自动再次对它使用箭头操作，直到找到最终的成员。

# 箭头运算符的使用及重载

```cpp
#include <iostream>
#include <string>

class Entity
{
public:
	int x;
public:
	void Print() const
	{
		std::cout << "Hello!x=" << x << std::endl;
	}
};

//创建这个类的对象时传入一个堆上的对象，
//可以使用堆对象，且堆对象会被自动释放
class ScopePtr
{
private:
	Entity* m_Obj;
public:
	ScopePtr(Entity* entity)
		:m_Obj(entity)
	{

	}
	~ScopePtr()
	{
		std::cout << "release m_Obj" << std::endl;
		delete m_Obj;
	}

	Entity* GetObject()
	{
		return m_Obj;
	} 
};

int main()
{
	Entity e;
	e.Print();

	//取消引用后用 .函数
	Entity* ptr = &e;
	Entity& entity = *ptr;
	//entity.Print();
	//(*ptr).Print();
	ptr->x = 2;
	ptr->Print();
	{
		ScopePtr entity = new Entity();
		entity.GetObject()->Print(); 
	}

	std::cin.get();
}
```

## 重载箭头运算符

```cpp
#include <iostream>
#include <string>

class Entity
{
public:
	int x;
public:
	void Print() const
	{
		std::cout << "Hello!x=" << x << std::endl;
	}
};

//创建这个类的对象时传入一个堆上的对象，
//可以使用堆对象，且堆对象会被自动释放
class ScopePtr
{
private:
	Entity* m_Obj;
public:
	ScopePtr(Entity* entity)
		:m_Obj(entity)
	{

	}
	~ScopePtr()
	{
		std::cout << "release m_Obj" << std::endl;
		delete m_Obj;
	}

	Entity* GetObject()
	{
		return m_Obj;
	}

	//1. 告诉编译器：“我把内部的指针给你用，但你只能
	// 看，不能改指针指向的那个 Entity。”
	//2. 右边的const：“这个函数是一个‘只读’函数，它不会修改
	// ScopedPtr 对象内部的任何成员变量。”，而且，他的返回值
	//不能调用非const函数
	const Entity* operator->() const 
	{
		return m_Obj;
	}
};

int main()
{
	Entity e;
	e.Print();

	//取消引用后用 .函数
	Entity* ptr = &e;
	Entity& entity = *ptr;
	//entity.Print();
	//(*ptr).Print();
	ptr->x = 2;
	ptr->Print();
	{
		//隐式转换，编译器会寻找匹配的构造函数
		//等同于：ScopePtr entity(new Entity()); // 直接初始化
		// 或者 ScopePtr entity = ScopePtr(new Entity()); // 显式转换
		ScopePtr entity = new Entity();
		entity.GetObject()->Print();
		entity->Print();
	}

	std::cin.get();
}
```

对于`ScopePtr entity = new Entity();`，编译器的逻辑
- 右侧 new Entity() 的结果是一个 Entity* 类型的指针。
- 左侧需要一个 ScopePtr 类型的对象。
- 编译器检查 ScopePtr 类，发现它正好有一个构造函数 ScopePtr(Entity* entity)。
- 编译器自动调用这个构造函数，将 new 出来的地址传进去，生成了一个临时的 ScopePtr 对象。

# 利用箭头运算符计算偏移量

```cpp
#include <iostream>
#include <string>

struct Vector3
{
	float x, y, z;
};

int main()
{
	std::cout << (Vector3*)0 << std::endl;
	
	//内存访问报错
	//std::cout << ((Vector3*)0)->z << std::endl;

	//int offset = (int)&((Vector3*)3)->z;//3+8=11
	//当编译器看到 & ( ptr->z ) 时，它会把这一整串代码看作一个
	// 单一的定位指令，而不是两个连续的动作。编译器内部的操作逻辑是：
	//第一步：算出 z 的内存地址应该是多少？（计算结果：ptr的地址 + z的偏移量）。
	//第二步：既然外面套着 & ，那我就直接把刚才算出来的地址数值交出去。
	int offset = (int)&((Vector3*)0)->z;

	std::cout << offset << std::endl;


	std::cin.get();
}
```