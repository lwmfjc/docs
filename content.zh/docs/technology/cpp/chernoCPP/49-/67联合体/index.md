---
title: 67联合体
description: 67联合体
categories:
  - 学习
tags:
  - cherno
  - app
date: 2026-02-21T09:40:10+08:00
lastmod: 2026-02-21T09:40:10+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
- 联合体有点像结构体，不过一次只能占用一个成员的内存，即每个成员都共享同一块内存
	- 如果我们有一个结构体，我们在里面声明四个浮点数，那就意味着我们有4个4字节，即那个结构体共有16个字节
	- 联合体只能有一个成员，如果声明4个浮点数(float)，如A、B、C、D，联合体的大小仍为4个字节。当尝试访问A或B或C或D时，他们实际上是同一块内存，即把A改成5，马上访问D时值也是5
- Struct 会为每个成员分配独立空间，而 Union 里的所有成员起始地址相同。
- 使用联合体的方式和使用结构体或类完全一样，也能添加静态函数、普通函数和方法 ~~不能有虚方法；静态成员不占 Union 实例空间~~ 
- 类型双关（Type Punning）：用不同的名称或类型查看同一块原始内存。
	- 当要给同一个变量取两个不同名字时，可以用联合体
- 通常联合体匿名使用、也不添加方法
# 联合体不能有虚方法的原因

虚函数的工作原理依赖于虚函数表指针（vptr）。

- Class/Struct 的做法：编译器会在对象内存的开头插入一个隐藏的指针（vptr），指向该类的虚函数表（vtable）。
- Union 的冲突：Union 的所有成员都必须从偏移量 0 开始共享内存。
	- 如果 Union 有虚函数，那么它必须有一个 vptr。
	- 这个 vptr 会占用内存。由于 Union 成员共享空间，你的数据成员（比如 int 或 float）会和这个 vptr 重叠。
	- 一旦你给成员赋值，就会覆盖掉 vptr，导致程序在调用虚函数时崩溃；反之，虚函数机制也会破坏你的数据。

# 例子：类型双关

```cpp
#ifdef LY_EP67_
#include <iostream>
 

int main()
{
	struct Union
	{
		union
		{
			float a;
			int b;
		};
	};

	Union u;

	//在 C++ 中，如果你在一个 struct 或 class 内部定义了一个
	//_没有名字_的 union，编译器会把这个联合体的成员直接注
	//入（Injected）到外层结构体的作用域中。
	u.a = 2.0f;//0x00F6FE20  00 00 00 40
	//40 00 00 00 为 0100 0000 0000 0000 0000 0000 0000 0000
	//u.b：0表示正数，所以这个值为2^30次方，即 10,7374,1824 
	//也就是我们拿到了构成那个浮点数的内存，然后把它当做int来解释(
	//类型双关）
	std::cout << u.a << "," << u.b << std::endl;

	std::cin.get();
}
#endif
```

# 相对拙劣的做法

```cpp
#ifdef LY_EP67
#include <iostream>

struct Vector2
{
	float x, y;
};

struct Vector4
{
	float x, y, z, w;

	Vector2& GetA()
	{
		//把&x当成一个Vector2的地址来解释
		//*表示取值的时候连续取两个float的值来构成一个Vector2
		return *(Vector2*)&x;
	}

	//尝试把Vector4看成是两个Vector2
	//Vector2 GetA()
	//{
	//	//..
	//	//添加一些成员并返回，这里省略了
	//	return Vector2();
	//}
};

void PrintVector2(const Vector2& v)
{
	std::cout << "Vector2: (" << v.x << ", " << v.y << ")\n";
}

int main()
{
	std::cin.get();
}
#endif
```





