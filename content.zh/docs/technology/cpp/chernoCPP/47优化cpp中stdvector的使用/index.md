---
title: 47优化cpp中stdvector的使用
description: 47优化cpp中stdvector的使用
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-02-07T07:47:28+08:00
lastmod: 2026-02-07T07:47:28+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

*预习*  


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
	//vertices.push_back({ 1,2,3 });
	//std::cout << "==0===" << std::endl;
	//vertices.push_back({ 4,5,6 });

	//对上面两行代码优化
	// 1. 预先分配内存，防止搬家
	vertices.reserve(1);
	// 2. 原地构造，防止临时拷贝
	vertices.emplace_back(1, 2, 3);
	std::cout << "==0===" << std::endl;
	//超出容量，会拷贝原来的{1,2,3}到新数组，并且销毁
	// 原数组中的{1,2,3}
	vertices.emplace_back(4, 5, 6);


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
copied constructor handled //第一个临时对象复制到vector中之后，马上又销毁了
destructor handled
==0===
copied constructor handled //空间不够了，需要把第一个元素复制到新数组中。第二个元素创建临时对象，并复制到新数组中
copied constructor handled
destructor handled  //旧的数组中的第一个元素被销毁了
destructor handled  //第二个元素的临时对象被销毁了
==1===
==2===
destructor handled
==3===
1,2,3
*/

/*优化后不需要把临时对象复制到vector中，也不需要销毁临时对象了
==1===
==2===
destructor handled
==3===
1,2,3
*/
```


------  


了解环境是优化过程中最重要的事情之一  
- 环境，即这个过程造成运行慢的原因、流程。当下，是对复制操作进行优化

```cpp
#include <iostream>
#include <vector>

struct Vertex
{
	float x, y, z;
	Vertex(float x, float y, float z)
		:x(x), y(y), z(z)
	{


	}

	Vertex(const Vertex& vertex)
		:x(vertex.x), y(vertex.y), z(vertex.z)
	{
		std::cout << "Copied!" << x << y << z << std::endl;
	}
};

int main()
{
	//它的意图：它不是在“预留空间”，而是在创建对象。它告诉编译器：“请立刻为我创建 3 个 Vertex 对象，并把它们放进 vector 里。”
	//矛盾点：由于你没有给这 3 个对象提供初始值，编译器会尝试调用
	//vertex 的无参构造函数（Default Constructor）。
	//死胡同：在你的代码里，你定义了一个 Vertex(float x, float y, float z)。根据 C++ 规则，如果你定义了任何有参数的构造函数，编译器就不会再自动为你生成那个默认的空构造函数了。
	//std::vector<Vertex> vertices(3);

	std::vector<Vertex> vertices;
	////问题11： 这里先在主函数的栈帧中构造Vertex，然后再复制到vector中
	////问题22：vertices的大小默认为1 
	//vertices.push_back(Vertex(1, 2, 3));
	////为了再加一个元素，vertices的大小调整为2
	//vertices.push_back(Vertex(4, 5, 6));
	////为了再加一个元素，vertices的大小调整为3
	//vertices.push_back(Vertex(7, 8, 9));

	//优化
	//预留3个容量
	vertices.reserve(3);
	//直接在vector中构造vertice，而不是先在栈中
	//构造vertice再复制到vector中
	//告诉vector，在实际的vector内存中，用以下参数（1,2,3）构造
	//Vertex对象
	vertices.emplace_back(1, 2, 3);
	vertices.emplace_back(4, 5, 6);
	vertices.emplace_back(7, 8, 9); 

	std::cin.get();
}
```

