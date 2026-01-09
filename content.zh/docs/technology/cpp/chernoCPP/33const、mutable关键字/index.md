---
title: 33-34const、mutable关键字
description: 33-34const、mutable关键字
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-01-04T00:44:12+08:00
lastmod: 2026-01-04T00:44:12+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---

# 常量折叠、类型强转

```cpp
#include <iostream>

int main()
{
	//当你定义 const int MAX_AGE = 90; 时，编译器通常会进行常量折叠（Constant Folding）。这意味着在编译阶段，代码中所有出现 MAX_AGE 的地方都会被直接替换为数字 90;
	//所以最下面的 std::cout << MAX_AGE << std::endl; 打印90
	const  int MAX_AGE = 90;
	std::cout << MAX_AGE << std::endl;//90

	int* a = new int;

	*a = 2;
	std::cout << *a << std::endl;//2

	//如果不加 (int*)类型强转,提示 a value of type "const int *"cannot beassigned to an entity of type "int *"
	//报错原因：1. 如果你能直接把 const int* 赋值给 int*，那么你就可以通过 *a = 100; 来修改 MAX_AGE 的值。这违背了 const 的初衷。为了保证代码的健壮性，编译器禁止这种**“权限扩大”**的行为（从“只读”变成“可读写”）。
	//	2. 为什么加上(int*) 就不报错了？
	//	当你加上(int*) 时，你正在使用强制类型转换（C - style Cast）。
	//	这相当于你对编译器说：“我知道 MAX_AGE 是常数，我也知道我在把只读指针转成可读写指针，出了问题我负责，请闭嘴。” 编译器接收到了你的强制指令，于是停止报错。
	a = (int*)&MAX_AGE;
	std::cout << *a << std::endl;//90
	*a = 5;

	//如果MAX_AGE加了volatile关键字修饰，即	const volatile int MAX_AGE = 90;那
	//么不会发生常量折叠，这里应该打印的是5
	std::cout << MAX_AGE << std::endl;//90
	//MAX_AGE 对应的内存空间，通过指针非法修改成了 5
	std::cout << *a << std::endl;//5

	std::cin.get();
}
```

# const的修饰位置

## 变量中

```cpp
#include <iostream>

int main()
{
	const int MAX_AGE = 90;

	//不能修改指针指向的地址里的值(但可以修改指针指向)
	const int* a = new int;
	//int const* a = new int;//跟上一句一个意思,const都是在*前面
	//*a = 2;//报错

	//由于a已经是const int*了，
	//所以这里编译器没有像int* a时报错
	a = &MAX_AGE;

	std::cout << *a << std::endl;//90 

	//不能修改指针指向的地址里的值(但可以修改指针指向)
	int* const  b = new int;
	*b = 2; //可修改地址里的值
	//不可重新分配b指向其他地址
	//b = &MAX_AGE;//报错


	const int* const  c = new int;
	int const* const  d = new int;
	/*以下均编译不通过*/
	//*c = 2;
	//c = &MAX_AGE;
	//*d = 2;
	//d = &MAX_AGE;
	/*以上均编译不通过*/

	std::cin.get();
}
```

## class中


```cpp
#include <iostream>

class Entity
{
private:
	int m_X, m_Y;
	static int s_X;
	int* m_XP;
public:

	//const: 在该方法中不允许修改成员变量
	//禁止修改成员变量： 在该函数内部，你不能对任何非 static 成员变量进行赋值操作。
	//禁止调用非 const 函数
	int GetX() const
	{
		//m_X = 3;
		s_X = 5;
		//test();//会报错
		return m_X;
	}

	//返回一个int指针，且该指针不能改变所存地址
	//指向的值，也不能指向其他地址
	const int* const GetXP() const
	{

		return m_XP;
	}

	void test() //const
	{

	}
};
int main()
{

	std::cin.get();
}
```

## 形参中

```cpp
#include <iostream>

class Entity
{
private:
	int m_X, m_Y;
	int m_X1;
	mutable int var;
public:

	int GetX1()  
	{
		return m_X1;
	}

	int GetX() const
	{
		//var是一个mutable变量,在const方法中可以修改它
		var = 3;
		return m_X;
	}

	void SetX(int x)
	{
		m_X = x;
	}
};

void PrintEntity1(const Entity* e)
{
	e = nullptr;//允许编译，允许指向其他
	//(*e).SetX(2);//报错，不允许修改值
	std::cout << (*e).GetX() << std::endl;
}

void PrintEntity2(const Entity& e)
{
	//e = nullptr;//不允许编译，因为是引用，不允许重新指向其他
	//e.SetX(2);//报错，不允许修改值
	std::cout << e.GetX() << std::endl;
	//不允许调用非const修饰的函数，下面会报错,
	//因为无法保证GetX1()是否修改了e，而e是const修饰的
	//std::cout << e.GetX1() << std::endl;
}

int main()
{

	std::cin.get();
}
```

# mutable

## class成员变量

```cpp
#include <iostream>
#include <string>

class Entity
{
private:
	std::string m_Name;

	//允许标记为const的方法修改该变量
	mutable int m_DebugCount = 0;

public:

	//1.如果是 const std::string，则返回的是一个副本
	//返回一个引用
	//2.最后的const表示该函数内部不允许修改类的非static成员变量
	const std::string& GetName() const
	{
		//m_Name = "a";//非法
		m_DebugCount++;//编译通过

		//由于返回的是引用，所以这里返回了成员变
		//量 m_Name 的一个“地址”或“别名”
		return m_Name;
	}

	void MyTest()
	{

	}
};

int main()
{
	const Entity e;
	e.GetName();//调用const方法
	//e.MyTest();//不允许调用非const方法


	Entity e1;
	e1.GetName();//调用const方法
	e1.MyTest();//调用非const方法 

	std::cin.get();
}
```

## lambda表达式中

```cpp
#include <iostream> 

int main()
{
	//lamda表达式

	int x = 1;
	int y = 8;
	const int z = 5;

	//按引用捕获所有变量
	auto f1 = [&]()
		{
			y = 3;//合法,和原变量一样
			//z = 5;//不合法,和原变量一样是const
			std::cout << "Hello" << std::endl;
		};

	//mutable 不能直接修饰普通的局部变量或全局变量,只能
	//是类成员变量
	//mutable int m2 = 0;//没这种写法，会报错

	//按值捕获所有变量
	auto f2 = [=]()
		{
			//y = 3;//不合法,默认是const
			std::cout << "Hello" << std::endl;
		};

	//按值捕获所有变量
	//默认情况下，Lambda 内部的 operator() 是 const 的，不允
	//许修改捕获的副本。加上 mutable 后，Lambda 内部就可以修改这些副本了。
	auto f2_1 = [=]() mutable
		{
			y = 3;
			std::cout << "Lambda 内部 y = " << y << std::endl;//3
		};

	std::cout << "外部原变量 y = " << y << std::endl;//8

	//按值捕获x变量
	auto f3 = [x]()
		{
			//y = 3;//不合法,默认是const
			std::cout << "Hello" << std::endl;
		};

	f1();
	f2();
	f3();
	std::cin.get();
}
```