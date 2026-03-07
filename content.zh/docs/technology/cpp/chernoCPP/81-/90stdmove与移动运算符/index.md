---
title: 90stdmove与移动运算符
description: 90stdmove与移动运算符
categories:
  - 学习
tags:
  - cherno
  - cpp
date: 2026-03-07T16:53:59+08:00
lastmod: 2026-03-07T16:53:59+08:00
cssAttach:
  - book03
cssclasses:
  - book03
---
#  `std::move` 到底是什么？

- ==核心真相==：`std::move` ==并不移动任何东西==。它只是一个简单的类型转换（Casting）。
- ==底层逻辑==：它把一个左值（Lvalue）强制转换为右值引用（Rvalue Reference）。它的作用仅仅是告诉编译器：“嘿，==我知道这个变量原本是个持久的对象，但现在我不再需要它了，请把它当成一个临时对象，允许别人‘偷’走它的资源==。”
- ==代码本质==：`std::move(x)` 基本上等同于 `static_cast<T&&>(x)`。

#  移动赋值运算符 (Move Assignment Operator)

- ==场景引入==：第 89 集讲的是构造新对象，而这一集讲的是==给已有对象重新赋值==。

```cpp
String dest = "Hello";

//如果你只写了移动构造，没写移动赋值：编译器会“退而求其
//次”，去调用拷贝赋值运算符 operator=(const String& other)。
dest = String("World"); // 这里会涉及移动赋值
```

- ==手写实现步骤==：
    
    1.  ==清理旧资源==：在接管别人的资源前，必须先 `delete[] m_Data` 释放自己当前的内存（否则会内存泄漏）。
    2.  ==接管资源==：像移动构造函数一样，把对方的指针和大小拷过来。
    3.  ==置空对方==：将源对象的指针设为 `nullptr`。
    4.  ==返回自身==：`return *this;` 以支持链式赋值。

#  为什么 `std::move` 是必需的？

- ==实战演示==：Cherno 展示了当你想==把一个已命名的变量移动到另一个地方==时，必须显式使用 `std::move`。
- ==原因==：即使一个变量的类型是 `String&&`，只要它有名字，它就是一个==左值==。
- ==安全性==：这种设计是为了防止你无意中移动了以后还要用到的数据。使用 `std::move` 是一种显式的“主权放弃”。

#  常见的错误用法与陷阱

- ==不要移动 `const` 对象==：如果你尝试 `std::move` 一个 `const` 对象，它会默默地退化回==拷贝==。因为移动语义需要修改原对象（将其置空），而 `const` 禁止修改。
- ==自赋值检查==：在移动赋值运算符中，通常建议检查 `if (this != &other)`，防止自己移动给自己导致资源被意外提前释放。


# (例子1)移动构造函数与移动赋值函数
 

```cpp
#ifdef LY_EP90

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
	//如果手动定义了“移动构造函数”，编译器就不再为你自动生成“默认赋值运算符”了。
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

	// 移动赋值运算符
	String& operator=(String&& other) noexcept
	{
		printf("Move Assigned!\n");

		// 1. 自赋值检查 (防止自己移动给自己，如 a = std::move(a))
		if (this != &other)
		{
			// 2. 释放旧资源 (dest 已经有内存了，必须先删掉，否则内存泄漏)
			delete[] m_Data;

			// 3. 窃取资源
			m_Size = other.m_Size;
			m_Data = other.m_Data;

			// 4. 将原对象置空 (让它变成空壳)
			other.m_Data = nullptr;
			other.m_Size = 0;
		}

		return *this;
	}

	//拷贝赋值运算符
	String& operator=(const String& other)
	{
		printf("Copy Assigned!\n");
		if (this != &other)
		{
			delete[] m_Data;
			m_Size = other.m_Size;
			m_Data = new char[m_Size]; // 必须申请新内存
			memcpy(m_Data, other.m_Data, m_Size);
		}
		return *this;
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
	//这里将"Cherno"隐式调用构造函数构造了一个String
	//之后move给了Entity（Entity内部的m_Name接管了这个临时String指针指向的堆内存）
	Entity entity("Cherno");
	entity.PrintName();
	std::cout << "===0==" << std::endl;
	String string = "Hello";
	std::cout << "===1==" << std::endl;
	String dest = string;//这是复制
	std::cout << "===2==" << std::endl;
	String dest1 = std::move(string);//调用移动构造函数
	dest1.Print();
	std::cout << "===3==" << std::endl;
	//如果没写移动赋值,编译器会“退而求其次”，去调用拷贝赋值运算符 operator=(const String & other)
	dest = "abc";
	std::cout << "===4==" << std::endl;
	 
	dest = std::move(string);
	dest.Print();//string已经被移动了，变成了空壳，所以dest打印出来是空的

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
===0==
Created!
String(const char* string)
===1==
Copied!
String(const String& other)
===2==
Moved!
String(String&& other)
Hello
===3==
Created!
String(const char* string)
Move Assigned!
Destroyed!
~String()
===4==
Move Assigned!

*/
#endif
```

# (例子2)详细解释

```cpp
#ifdef LY_EP90

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
	//如果手动定义了“移动构造函数”，编译器就不再为你自动生成“默认赋值运算符”了。
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

	// 移动赋值运算符：将另一个对象，移入当前这个对象自身
	//语义契约（Semantic Contract）。	C++ 的设计哲学是：让自定义类型的行为表现得像内置类型（如 int）一样。标准做法始终是返回非 const 的 *this 引用
	String& operator=(String&& other) noexcept
	{
		printf("Move Assigned!\n");

		// 1. 自赋值检查 (防止自己移动给自己，如 a = std::move(a)，
		// 因为如下是会释放旧资源的，所以移动给自己就什么都没有了)
		if (this != &other)
		{
			// 2. 释放旧资源 (dest[当前对象] 已经有内存了，必须先删掉，否则内存泄漏)
			delete[] m_Data;

			// 3. 窃取资源
			m_Size = other.m_Size;
			m_Data = other.m_Data;

			// 4. 将原对象置空 (让它变成空壳)
			other.m_Data = nullptr;
			other.m_Size = 0;
		}

		//找到 this 指向的对象，返回它的引用（别名），
		// 而不是创建一个新的副本
		return *this;
	}

	//拷贝赋值运算符
	String& operator=(const String& other)
	{
		printf("Copy Assigned!\n");
		if (this != &other)
		{
			delete[] m_Data;
			m_Size = other.m_Size;
			m_Data = new char[m_Size]; // 必须申请新内存
			memcpy(m_Data, other.m_Data, m_Size);
		}
		return *this;
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
	//临时对象经历了:Created! -> Moved! -> Destroyed!
	Entity entity("Cherno");
	//打印字符串
	entity.PrintName();
	std::cout << "=====0=====" << std::endl;

	//隐式调用构造函数String(const char* string)，Created! 
	String string = "Hello";
	std::cout << "=====1=====" << std::endl;

	//隐式调用(复制)构造函数， 本质上就是“通过复制一个已有的对象来创建一个新对象”，这就是所谓的“复制构造”。
	String dest = string;
	std::cout << "=====2.1=====" << std::endl;
	//使用接受字符串右值引用的构造函数，来构造一个String
	String dest1 = (String&&)string;
	std::cout << "=====2.2=====" << std::endl;
	String dest2((String&&)string);//这个string内部的指针已经被dest1接管了，所以dest2构造的时候，string已经是空壳了，所以dest2也是空的
	std::cout << "=====2.3=====" << std::endl;

	//这样写无需知道string是什么类型的
	//remove_reference_t<_Ty>&& move(_Ty&& _Arg)  ，查看源码可知返回的是右值引用
	//这里是移动构造，而非移动赋值，因为dest3是第一次定义并使用
	String dest3 = std::move(string);
	std::cout << "=====3=====" << std::endl;

	//当将一个变量(数值、表达式)赋给一个已有变量时，使用的是赋值
	//就像这里是移动赋值
	dest = std::move(string);


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
=====0=====
Created!
String(const char* string)
=====1=====
Copied!
String(const String& other)
=====2.1=====
Moved!
String(String&& other)
=====2.2=====
Moved!
String(String&& other)
=====2.3=====
Moved!
String(String&& other)
=====3=====
Move Assigned!
*/
#endif
```

# (例子3)视频举的

```cpp
#ifdef LY_EP90

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
	//如果手动定义了“移动构造函数”，编译器就不再为你自动生成“默认赋值运算符”了。
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

	// 移动赋值运算符：将另一个对象，移入当前这个对象自身
	//语义契约（Semantic Contract）。	C++ 的设计哲学是：让自定义类型的行为表现得像内置类型（如 int）一样。标准做法始终是返回非 const 的 *this 引用
	String& operator=(String&& other) noexcept
	{
		printf("Move Assigned!\n");

		// 1. 自赋值检查 (防止自己移动给自己，如 a = std::move(a)，
		// 因为如下是会释放旧资源的，所以移动给自己就什么都没有了)
		if (this != &other)
		{
			// 2. 释放旧资源 (dest[当前对象] 已经有内存了，必须先删掉，否则内存泄漏)
			delete[] m_Data;

			// 3. 窃取资源
			m_Size = other.m_Size;
			m_Data = other.m_Data;

			// 4. 将原对象置空 (让它变成空壳)
			other.m_Data = nullptr;
			other.m_Size = 0;
		}

		//找到 this 指向的对象，返回它的引用（别名），
		// 而不是创建一个新的副本
		return *this;
	}

	//拷贝赋值运算符
	String& operator=(const String& other)
	{
		printf("Copy Assigned!\n");
		if (this != &other)
		{
			delete[] m_Data;
			m_Size = other.m_Size;
			m_Data = new char[m_Size]; // 必须申请新内存
			memcpy(m_Data, other.m_Data, m_Size);
		}
		return *this;
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
	{
		std::cout << "=====0=====" << std::endl;


		//使用String(const char* string)构造String对象，Created!
		String apple = "Apple";
		//使用默认构造函数构造String对象
		String dest;

		std::cout << "=====1=====" << std::endl;
		std::cout << "Apple: ";
		apple.Print();
		std::cout << "Dest: ";
		dest.Print();
		std::cout << "=====1=====" << std::endl;

		//使用移动赋值运算符将apple的资源移入dest，Move Assigned!
		//相当于dest.operator=(std::move(apple));
		dest = std::move(apple);

		std::cout << "=====2=====" << std::endl;
		std::cout << "Apple: ";
		apple.Print();
		std::cout << "Dest: ";
		dest.Print();
		std::cout << "=====2=====" << std::endl;

		//综上，没有任何复制就移动了整个字符数组的所有权，交换了两个
		//变量
	}
	

	std::cin.get();
	return 0;
}
/* 
=====0=====
Created!
String(const char* string)
=====1=====
Apple: Apple
Dest:
=====1=====
Move Assigned!
=====2=====
Apple:
Dest: Apple
=====2=====
Destroyed!
~String()
Destroyed!
~String()
*/
#endif
```

#  结尾 | 总结：拷贝 vs 移动

- ==拷贝 (Copy)==：两份独立的资源，安全但慢。
- ==移动 (Move)==：一份资源的所有权转移，极快。
- ==金句==：如果你希望你的 C++ 程序拥有极致性能，学会何时及如何使用 `std::move` 是必修课。
- 当包含移动构造函数时，应该也包含移动赋值函数