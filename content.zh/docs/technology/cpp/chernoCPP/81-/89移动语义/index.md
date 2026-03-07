---
title: 89移动语义
description: 89移动语义
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-07T12:53:20+08:00
lastmod: 2026-03-07T12:53:20+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
#  为什么要引入移动语义？

- ==核心痛点==：在 C++11 之前，将对象从一处转移到另一处通常只能通过“拷贝”。
	- 向一个函数传递一个对象
	- 从函数返回一个对象  
		- 如果有返回值优化==RVO (Return Value Optimization)==。==编译器直接在调用者（Caller）的栈帧中构造该对象==，而不是在函数内部构造再拷贝出来。结果：既没有拷贝构造，也没有移动构造，性能损耗为零。
		- 当编译器因为逻辑复杂（例如根据条件返回不同的局部变量）而无法进行 RVO 时，移动语义就成了“二号救兵”。
			- 旧时代 (C++11 之前)：==如果 RVO 失效，必须调用拷贝构造函数==，这涉及昂贵的深拷贝。
			- 现代 C++ (C++11 之后)：编译器会==尝试调用移动构造函数==。1. 因为返回的对象是一个即将销毁的右值，它可以被“掠夺”。2. 你不需要手动写 return std::move(obj);，编译器会==自动处理局部变量的返回==。
			  
- ==性能代价==：如果对象持有堆内存（如字符串或数组），拷贝意味着：==申请新内存 -> 复制所有数据 -> 销毁旧对象==。这在处理临时对象（扔掉的对象）时是非常巨大的浪费。
- ==解决方案==：如果我们可以直接“移动”对象——即把旧对象的内存指针直接交给新对象，就能省去内存分配和数据复制的开销。

#  基础：构建实验用的 `String` 类

- ==模拟场景==：Cherno 编写了一个简易的 `String` 类，包含一个 `char*` 指针和 `size`。
- ==可视化调试==：在构造函数中加入 `printf("Created")`，在拷贝构造函数中加入 `printf("Copied")`，以便观察内存分配发生的时机。

#  拷贝的代价演示

- ==实验代码==：创建一个 `Entity` 类，它拥有一个 `String` 成员。当通过构造函数传入一个字符串字面量时，会发现控制台打印了 ==“Created”== 然后是 ==“Copied”==。
- ==问题分析==：即便传入的是一个临时字符串（右值），`Entity` 仍然会调用拷贝构造函数进行深拷贝。明明临时对象马上就要销毁了，我们却还要复制它，这很不科学。

```cpp
#ifdef LY_EP89

//c++11才引入了右值引用
#include <iostream>   

class String
{
public:
	String() = default;

	//构造函数
	String(const char* string)
	{
		printf("Created!\n");
		//不包括\0
		m_Size = strlen(string);
		m_Data = new char[m_Size];
		memcpy(m_Data, string, m_Size);
		std::cout << "String(const char* string)" << std::endl;
	}
	
	//复制构造函数
	String(const String& other)
	{
		printf("Copied!\n");
		//不包括\0
		m_Size = other.m_Size;
		m_Data = new char[m_Size];

		//在 C++ 中，访问控制（public/private）是基于“类（Class）”层面的，而不是基于“对象（Object）”层面的。
		//简单来说：只要是在 String 类的成员函数内部，你就可以访问任何 String 对象的私有成员。
		memcpy(m_Data, other.m_Data, m_Size);

		std::cout << "String(const String& other)" << std::endl;
	}
	 

	~String()
	{
		delete[] m_Data;
		printf("Destroyed!\n");
		std::cout << "~String()" << std::endl;
	}

	void Print()
	{
		for (uint32_t i = 0; i < m_Size; i++)
			printf("%c", m_Data[i]);
		printf("\n");
	}
private:
	char* m_Data;

	//这是一个通过 typedef 或 using 定义的类型，表示
	//无符号整型32位数。
	// int 在某些古老的 16 位系统上可能是 2 字节，在现代系统上通常是 4 字节，uint32_t 强制规定在任何符合标准的编译器上，它永远是 32 位（4 字节）
	uint32_t m_Size;
};

class Entity
{
public:
	Entity(const String& name)
		:m_Name(name)
	{
		std::cout << "Entity(const String& name)" << std::endl;
	}  

	void PrintName()
	{
		m_Name.Print();
	}

private:
	String m_Name;
};

int main()
{
	//隐式构造函数构造String对象，调用String(const char* string)构造函数
	//Entity entity("Cherno");

	//临时对象String("Cherno")的生命周期直到支持它的那个“完整表达式”计算完成为止，即该行代码分号结束时
	//!!现在main函数创建这个(临时)对象后，传(复制)给Entity构造函数的当参数使用，又马上销毁了这个临时对象(只留下复制的)
	Entity entity(String("Cherno"));

	entity.PrintName();

	std::cin.get();
	return 0;
}
/*
Created!
String(const char* string)
Copied!
String(const String& other)
Entity(const String& name)
Destroyed!
~String()
Cherno
*/
#endif
```

#  编写移动构造函数 (Move Constructor)

- ==核心语法==：使用右值引用 `String(String&& other)`。注意要加上 `noexcept` 关键字。
- ==实现逻辑（偷走资源）==：
    1.  直接将 `this->m_Data` 指向 `other.m_Data`（浅拷贝指针）。
    2.  将 `this->m_Size` 设为 `other.m_Size`。
- ==关键的一步（置空原对象）==：必须将 `other.m_Data` 设为 `nullptr`，并将 `other.m_Size` 设为 `0`。
- ==原理==：这把旧对象变成了一个“空壳”。当旧对象析构时，`delete nullptr` 不会做任何事，从而保证了内存所有权的完美转移。

```cpp
#ifdef LY_EP89

//c++11才引入了右值引用
#include <iostream>   
#include <utility> // std::move 在这个头文件里

class String
{
public:
	String() = default;

	//构造函数
	String(const char* string)
	{
		printf("Created!\n");
		//不包括\0
		m_Size = strlen(string);
		m_Data = new char[m_Size];
		memcpy(m_Data, string, m_Size);
		std::cout << "String(const char* string)" << std::endl;
	}

	//复制构造函数
	String(const String& other)
	{
		printf("Copied!\n");
		//不包括\0
		m_Size = other.m_Size;
		m_Data = new char[m_Size];

		//在 C++ 中，访问控制（public/private）是基于“类（Class）”层面的，而不是基于“对象（Object）”层面的。
		//简单来说：只要是在 String 类的成员函数内部，你就可以访问任何 String 对象的私有成员。
		memcpy(m_Data, other.m_Data, m_Size);

		std::cout << "String(const String& other)" << std::endl;
	}


	//移动构造函数
	//接收一个右值引用参数，表示可以从一个将要被销毁的临时对象中“窃取”资源，而不是复制资源。
	String(String&& other) noexcept
	{
		printf("Moved!\n");
		//不包括\0
		m_Size = other.m_Size;
		m_Data = other.m_Data;

		other.m_Size = 0;//将原对象的大小置为0，表示它不再拥有资源

		//把被接管控制权的资源指针置空，防止原对象的析构函数删除已经被移动的资源
		other.m_Data = nullptr;


		std::cout << "String(String&& other)" << std::endl;
	}

	~String()
	{
		delete[] m_Data;
		printf("Destroyed!\n");
		std::cout << "~String()" << std::endl;
	}

	void Print()
	{
		for (uint32_t i = 0; i < m_Size; i++)
			printf("%c", m_Data[i]);
		printf("\n");
	}
private:
	char* m_Data;

	//这是一个通过 typedef 或 using 定义的类型，表示
	//无符号整型32位数。
	// int 在某些古老的 16 位系统上可能是 2 字节，在现代系统上通常是 4 字节，uint32_t 强制规定在任何符合标准的编译器上，它永远是 32 位（4 字节）
	uint32_t m_Size;
};

class Entity
{
public:


	Entity(const String& name) 
		:m_Name(name)
	{
		std::cout << "Entity(const String& name)" << std::endl;
	}



	//Entity(String&& name)
	//	//一旦右值引用有了名字，它在后续表达式中就变成了左值。
	//	//编译器会想：“这个 name 虽然是引用进来的，但它现在是有名有姓的变量，为了安全起见，我必须调用 复制构造函数 来保护它。
	//	:m_Name(name)
	//{
	//	std::cout << "Entity( String&& name)" << std::endl;
	//}
	


	//接收一个临时对象作为参数，使用移动语义来构造 Entity 对象，避免不必要的复制，提高性能。
	Entity(String&& name)
		//强转为右值引用，告诉编译器：我知道 name 是一个左值，但我想把它当作一个将要被销毁的临时对象来处理，所以请调用 移动构造函数 来构造 m_Name。
		//:m_Name((String&&)name) //这种写法也行
		:m_Name(std::move(name))  // 将左值 name 强行转回右值
	{
		std::cout << "Entity( String&& name)" << std::endl;
	}

	void PrintName()
	{
		m_Name.Print();
	}

private:
	String m_Name;
};

int main()
{
	//隐式构造函数构造String对象，调用String(const char* string)构造函数
	//Entity entity("Cherno");

	//临时对象String("Cherno")的生命周期直到支持它的那个“完整表达式”计算完成为止，即该行代码分号结束时
	//!!现在main函数创建这个(临时)对象后，传(复制)给Entity构造函数的当参数使用，又马上销毁了这个临时对象(只留下复制的)
	Entity entity(String("Cherno"));

	entity.PrintName();

	std::cin.get();
	return 0;
}
/*
Created!
String(const char* string)
Moved!
String(String&& other)
Entity( String&& name)
Destroyed!
~String()
Cherno
*/
#endif
```

#  激活移动语义：`std::move`

- ==常见误区==：即便写了移动构造函数，编译器在==某些情况下（如成员变量赋值）==可能仍会选择拷贝。
- ==解决方法==：在 `Entity` 的构造函数中使用 `m_Name(std::move(name))`。
- ==效果验证==：再次运行程序，你会发现 ==“Copied”== 变成了 ==“Moved”==。这意味着没有发生新的内存分配，程序运行得更快了。

```cpp
#ifdef LY_EP89_

//#include <utility> //不加的话，std::move编译报错

int main()
{
	//int a=std::move(3);
	return 0;
}

#endif
```



#  结尾 | 总结与展望

- ==核心价值==：移动语义让你在不损失代码可读性的前提下，极大地提升了处理大型对象和临时对象的性能。

