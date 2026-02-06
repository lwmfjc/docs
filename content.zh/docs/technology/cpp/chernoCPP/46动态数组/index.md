---
title:
description:
categories:
tags:
date: 2026-02-06T14:21:51+08:00
lastmod: 2026-02-06T14:21:51+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 动态数组，特别是讨论标准向量类
- 要习惯CPP的标准库（标准模版库）
- 标准模版库包含了各种容器、迭代器、算法、仿函数

------  


- 容器的数据类型由程序员自己决定  
- cpp提供了一个Vector的类，在std命名空间中，可以调整大小，也可以不指定初始大小  
- 本系列会重写C++中的数据结构，优化后比标准模版库中的快很多  

`std::vector` 的实际工作方式：  

当超出实际的分配大小时。当创建一个向量，可能会先分配10个元素大小的空间，当超出这个大小时，会在内存中创建一个比原来更大的数组，并把所有内容复制过去，然后删除旧数组。这样就有了一个更大存储空间的新数组  

# cpp中的聚合初始化

```cpp
struct Test
{

};
struct Vertex 
{  
	float x, y, z;
	/*virtual*/ void test()
	{

	}
};

//main()中
Vertex v = { 1,2,3 };


```

聚合初始化（Aggregate Initialization），Vertex 结构体是一个聚合类型（Aggregate Type）。在 C++ 中，如果一个类或结构体满足以下条件：

- 没有显式定义的构造函数。
- 成员变量是公有的（public）。
- 没有基类（没有继承）。
- 没有虚函数。

那么你可以使用大括号 {} 直接按顺序为成员变量赋值。

# vector的基本使用

```cpp
#include <iostream>
#include <string>
#include <vector>

struct Test
{

};
struct Vertex
{
	float x, y, z;

	//有了其他的构造函数，如果需要用到无参构造函数，
	//就必须手动写一个
	Vertex()
	{

	}

	//因为有构造函数了，所以Vertex 结构体不是一个聚合类型(
	// 有构造函数)，所以要使用显示构造函数
	// 使 Vertex v = { 1,2,3 }; 编译通过
	Vertex(float x, float y, float z)
	{
		this->x = x;
		this->y = y;
		this->z = z;
	}

	//参数必须是&，原因如下:
	//1. 当你尝试通过 Vertex a = b; 调用复制构造函数时，你需要将 b 传递给参数 other。
	//2. 在 C++ 中，按值传递（Pass by Value）参数本身就会触发一次复制。
	//3. 为了复制 b 到 other，编译器又需要调用复制构造函数。[死循环了]
	//因为main中使用 vector.push({1,2,3}) 需要将临时对象拷贝到vector中，所以这里的参数
	//必须是const
	Vertex(const Vertex& vertex)
	{
		std::cout << "copied constructor handled" << std::endl;
		this->x = vertex.x;
		this->y = vertex.y;
		this->z = vertex.z;
	}
	/*virtual*/ void test()
	{

	}

	~Vertex()
	{
		std::cout << "destructor handled" << std::endl;
	}
};

std::ostream& operator<<(std::ostream& stream, const Vertex& vertex)
{
	stream << vertex.x << "," << vertex.y << "," << vertex.z;
	return stream;
}

int main()
{
	Vertex vertices1[5];
	Vertex* vertices2 = new Vertex[5];

	std::vector<int> myarray;
	//存储Vertex对象，则动态数组的内存是连续的，
	//其中的Vertext对象会按行排列
	//问题是：实际要调整向量大小时得复制所有(类)数据，但内存连续性
	// 带来的读取速度提升通常远超扩容时的开销
	std::vector<Vertex> vertices;
	//存储Vertext指针,实际要调整向量大小是只是复制指针地址(一个数字)
	//，即实际数据的内存地址
	std::vector<Vertex*> vertices4;

	std::cout << "---1---" << std::endl;
	Vertex v = { 1,2,3 };
	//这里演示vertices的使用
	std::cout << "---2---" << std::endl;
	vertices.push_back({ 1,2,3 });
	std::cout << "---3---" << std::endl;
	vertices.push_back({ 4,5,6 });

	std::cout << "---4---" << std::endl;
	for (int i = 0; i < vertices.size(); i++)
	{
		//c++对[]进行了重载
		std::cout << vertices[i] << std::endl;
	}
	std::cout << "---5---" << std::endl;
	//这里会把每个Vertex复制到v
	for (Vertex v : vertices)
		std::cout << v << std::endl;
	std::cout << "---6---" << std::endl;
	//避免复制
	for (Vertex& v : vertices)
		std::cout << v << std::endl;

	//clear() 会移除容器中的所有元素，但通常不一定会立即释放底层内存（容量不变），它只是销毁现有的对象。
	vertices.clear();

	std::cin.get();
}
```

## 解释一下`vertices.push_back({1, 2, 3});`  

当你执行 `vertices.push_back({1, 2, 3});` 时，逻辑确实是：在 vector 内部的内存中，通过调用复制构造函数来构造一个属于 vector 自己的对象。

具体的“接力”过程如下：

1. 第一棒：创建临时对象
编译器先在栈上创建一个临时对象（假设叫 temp）。此时会调用你的普通构造函数 `Vertex(float x, float y, float z)`。
2. 第二棒：传参给 push_back
push_back 函数需要接收这个 temp。由于 temp 是个临时对象，它==只能传递给带有 const 的引用`（const Vertex&`）==。
3. 第三棒：在 vector 内部“克隆”
这是最关键的一步。vector 已经在堆（Heap）上为你找好了空位。它会拿着刚才传进来的 temp 作为参考，在那个空位上调用你的复制构造函数。

复制构造函数做的事：它把 temp.x 拷到新位子的 x，temp.y 拷到 y……

结果：此时 vector 内部就有了一个完整的 Vertex 对象。
4. 第四棒：临时对象自毁
这行代码结束，栈上的 temp 任务完成，被自动销毁。  

## 对输出解释

```cpp
//输出为：
/*
---1---
---2---
copied constructor handled  	vertices.push_back({ 1,2,3 });
destructor handled              push{1,2,3}时的那个临时对象被销毁了
---3---
copied constructor handled  	vertices.push_back({ 4,5,6 });导致vector内部数组扩容,1: 复制{1,2,3}到新扩容空间  2. 复制{4,5,6}到新扩容空间 所以包括下面是两次copied
copied constructor handled  	
destructor handled      旧的 {1,2,3} 被销毁了
destructor handled      栈上的临时对象 {4,5,6} 被销毁了。
---4---
1,2,3
4,5,6
---5---
copied constructor    handled vertices有两个元素，每个元素都要复制到临时的v一次(第1次)
1,2,3
destructor handled    for运行结束后v被销毁了
copied constructor    handled vertices有两个元素，每个元素都要复制到临时的v一次(第2次)
4,5,6
destructor handled    for运行结束后v被销毁了
---6---
1,2,3
4,5,6
destructor handled
destructor handled
*/
```

*---3--- 为什么输出了 2 次？*  

Vector 扩容（Reallocation） 机制：

- 创建新空间：vector 在堆上分配一块足以容纳 2 个对象的新内存。
- 搬迁老居民（拷贝 1）：将旧内存位置的 `{1, 2, 3}` 拷贝到新内存的第一个格子里。输出： copied constructor handled
- 迎接新成员（拷贝 2）：将栈上的临时对象 `{4, 5, 6}` 拷贝到新内存的第二个格子里。输出： copied constructor handled
- 善后工作：销毁旧内存里的对象并释放旧空间，以及销毁栈上的临时对象`{4，5，6}`

结果：一共 2 次。不过拷贝新旧的顺序不固定，能确定的是一定会拷贝两次  

## 避免复制整个vector

==主要看Function函数==

```cpp
#include <iostream>
#include <string>
#include <vector>

struct Test
{

};
struct Vertex
{
	float x, y, z;

	//有了其他的构造函数，如果需要用到无参构造函数，
	//就必须手动写一个
	Vertex()
	{

	}

	//因为有构造函数了，所以Vertex 结构体不是一个聚合类型(
	// 有构造函数)，所以要使用显示构造函数
	// 使 Vertex v = { 1,2,3 }; 编译通过
	Vertex(float x, float y, float z)
	{
		this->x = x;
		this->y = y;
		this->z = z;
	}

	//参数必须是&，原因如下:
	//1. 当你尝试通过 Vertex a = b; 调用复制构造函数时，你需要将 b 传递给参数 other。
	//2. 在 C++ 中，按值传递（Pass by Value）参数本身就会触发一次复制。
	//3. 为了复制 b 到 other，编译器又需要调用复制构造函数。[死循环了]
	//因为main中使用 vector.push({1,2,3}) 需要将临时对象拷贝到vector中，所以这里的参数
	//必须是const
	Vertex(const Vertex& vertex)
	{
		std::cout << "copied constructor handled" << std::endl;
		this->x = vertex.x;
		this->y = vertex.y;
		this->z = vertex.z;
	}
	/*virtual*/ void test()
	{

	}

	~Vertex()
	{
		std::cout << "destructor handled" << std::endl;
	}
};

std::ostream& operator<<(std::ostream& stream, const Vertex& vertex)
{
	stream << vertex.x << "," << vertex.y << "," << vertex.z;
	return stream;
}

//使用引用避免复制整个数组
void Function(const std::vector<Vertex>& vertices)
{

}

int main()
{ 
	std::vector<Vertex> vertices;
	vertices.push_back({ 1,2,3 });
	vertices.push_back({ 4,5,6 });
	std::cout << "==1===" << std::endl;
	Function(vertices);
	std::cout << "==2===" << std::endl;
	vertices.erase(vertices.begin() + 1);
	std::cout << "==3===" << std::endl;
	for (Vertex& v : vertices)
		std::cout << v << std::endl;
	std::cin.get();
}
/*
copied constructor handled
destructor handled
copied constructor handled
copied constructor handled
destructor handled
destructor handled
==1===
==2===
destructor handled
==3===
1,2,3
*/
```

这里简单解释一下迭代器，后面视频会详解：  

迭代器是一个对象（类），它的设计目的是为了让你能够像使用“指针”一样去访问容器里的元素。
- 它内部保存了容器中某个元素的内存地址。 ~~我的理解是，这样就决定了从哪里进行迭代容器（的所有元素）~~ 
- 它重载了各种运算符（比如 ++、+、*、->），让你可以通过简单的数学运算来移动它。